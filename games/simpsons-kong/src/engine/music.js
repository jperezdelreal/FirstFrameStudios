// P1-12: Procedural background music via Web Audio API oscillators
// Routes through Audio's musicBus for volume control integration

const BPM = 112;
const BEAT_DURATION = 60 / BPM; // ~0.536s per beat
const SCHEDULE_AHEAD = 0.15;    // schedule notes 150ms ahead
const SCHEDULE_INTERVAL = 100;  // check every 100ms
const CROSSFADE_TIME = 0.5;

// Bass line — mellow 8-note loop (C3-E3-G3-C4-G3-E3-C3-E3)
const BASS_NOTES = [130.81, 164.81, 196.00, 261.63, 196.00, 164.81, 130.81, 164.81];

// Melody line — simple pentatonic phrase over 8 beats
const MELODY_NOTES = [523.25, 0, 392.00, 440.00, 523.25, 0, 392.00, 0];
// C5, rest, G4, A4, C5, rest, G4, rest

// Intensity level volumes
const INTENSITY = [
    { bass: 0.08, perc: 0,    melody: 0    }, // Level 0: walking — bass only, quiet
    { bass: 0.12, perc: 0.06, melody: 0    }, // Level 1: enemies nearby — add percussion
    { bass: 0.14, perc: 0.08, melody: 0.05 }, // Level 2: combat — add melody
];

export class Music {
    constructor(context, musicBus) {
        this.ctx = context;
        this.bus = musicBus;

        // Layer gain nodes for crossfading
        this.bassGain = this.ctx.createGain();
        this.percGain = this.ctx.createGain();
        this.melodyGain = this.ctx.createGain();

        this.bassGain.connect(this.bus);
        this.percGain.connect(this.bus);
        this.melodyGain.connect(this.bus);

        this.bassGain.gain.value = 0;
        this.percGain.gain.value = 0;
        this.melodyGain.gain.value = 0;

        this._intensity = 0;
        this._playing = false;
        this._muted = false;
        this._mutedIntensity = 0;
        this._beat = 0;
        this._nextBeatTime = 0;
        this._schedulerId = null;

        // AAA-V2: Pitch scale for slow-mo effect
        this._pitchScale = 1.0;

        // Pre-create a noise buffer for hi-hat (reuse to avoid GC churn)
        this._hihatBuffer = this._createNoiseBuffer(0.03);
    }

    _createNoiseBuffer(durationSec) {
        const length = Math.ceil(this.ctx.sampleRate * durationSec);
        const buf = this.ctx.createBuffer(1, length, this.ctx.sampleRate);
        const data = buf.getChannelData(0);
        for (let i = 0; i < length; i++) {
            data[i] = Math.random() * 2 - 1;
        }
        return buf;
    }

    start() {
        if (this._playing) return;
        this._playing = true;
        this._beat = 0;
        this._nextBeatTime = this.ctx.currentTime + 0.05;

        this._applyIntensity(this._intensity);

        this._schedulerId = setInterval(() => this._schedule(), SCHEDULE_INTERVAL);
    }

    stop() {
        if (!this._playing) return;
        this._playing = false;

        if (this._schedulerId !== null) {
            clearInterval(this._schedulerId);
            this._schedulerId = null;
        }

        // Fade out all layers quickly
        const now = this.ctx.currentTime;
        this.bassGain.gain.cancelScheduledValues(now);
        this.percGain.gain.cancelScheduledValues(now);
        this.melodyGain.gain.cancelScheduledValues(now);
        this.bassGain.gain.setTargetAtTime(0, now, 0.08);
        this.percGain.gain.setTargetAtTime(0, now, 0.08);
        this.melodyGain.gain.setTargetAtTime(0, now, 0.08);
    }

    setIntensity(level) {
        level = Math.max(0, Math.min(2, Math.floor(level)));
        if (level === this._intensity) return;
        this._intensity = level;
        if (this._playing && !this._muted) {
            this._applyIntensity(level);
        }
    }

    _applyIntensity(level) {
        const volumes = INTENSITY[level];
        const now = this.ctx.currentTime;

        this.bassGain.gain.cancelScheduledValues(now);
        this.percGain.gain.cancelScheduledValues(now);
        this.melodyGain.gain.cancelScheduledValues(now);

        this.bassGain.gain.setTargetAtTime(volumes.bass, now, CROSSFADE_TIME / 3);
        this.percGain.gain.setTargetAtTime(volumes.perc, now, CROSSFADE_TIME / 3);
        this.melodyGain.gain.setTargetAtTime(volumes.melody, now, CROSSFADE_TIME / 3);
    }

    mute() {
        if (this._muted) return;
        this._muted = true;
        this._mutedIntensity = this._intensity;

        const now = this.ctx.currentTime;
        this.bassGain.gain.cancelScheduledValues(now);
        this.percGain.gain.cancelScheduledValues(now);
        this.melodyGain.gain.cancelScheduledValues(now);
        this.bassGain.gain.setTargetAtTime(0, now, 0.08);
        this.percGain.gain.setTargetAtTime(0, now, 0.08);
        this.melodyGain.gain.setTargetAtTime(0, now, 0.08);
    }

    unmute() {
        if (!this._muted) return;
        this._muted = false;
        if (this._playing) {
            this._applyIntensity(this._intensity);
        }
    }

    toggleMute() {
        if (this._muted) this.unmute();
        else this.mute();
    }

    get isMuted() { return this._muted; }
    get isPlaying() { return this._playing; }

    setTimeScale(scale) {
        this._pitchScale = Math.max(0.1, scale);
    }

    // --- Scheduler: runs on setInterval, schedules notes ahead ---
    _schedule() {
        if (!this._playing) return;

        while (this._nextBeatTime < this.ctx.currentTime + SCHEDULE_AHEAD) {
            this._scheduleBeat(this._beat, this._nextBeatTime);
            this._nextBeatTime += BEAT_DURATION;
            this._beat = (this._beat + 1) % BASS_NOTES.length;
        }
    }

    _scheduleBeat(beat, time) {
        this._scheduleBass(beat, time);
        this._schedulePercussion(beat, time);
        this._scheduleMelody(beat, time);
    }

    // --- Bass layer: sine wave, one note per beat ---
    _scheduleBass(beat, time) {
        const freq = BASS_NOTES[beat];
        const osc = this.ctx.createOscillator();
        const env = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq * this._pitchScale, time);
        osc.connect(env);
        env.connect(this.bassGain);

        // Soft attack/release to avoid clicks
        const noteDur = BEAT_DURATION * 0.85;
        env.gain.setValueAtTime(0.001, time);
        env.gain.exponentialRampToValueAtTime(1.0, time + 0.02);
        env.gain.setValueAtTime(1.0, time + noteDur - 0.03);
        env.gain.exponentialRampToValueAtTime(0.001, time + noteDur);

        osc.start(time);
        osc.stop(time + noteDur);
    }

    // --- Percussion layer: kick on 1,3,5,7; hihat on every beat ---
    _schedulePercussion(beat, time) {
        // Kick on even beats (0, 2, 4, 6)
        if (beat % 2 === 0) {
            this._scheduleKick(time);
        }
        this._scheduleHihat(time);
    }

    _scheduleKick(time) {
        const osc = this.ctx.createOscillator();
        const env = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(60, time);
        osc.frequency.exponentialRampToValueAtTime(30, time + 0.08);
        osc.connect(env);
        env.connect(this.percGain);

        env.gain.setValueAtTime(1.0, time);
        env.gain.exponentialRampToValueAtTime(0.001, time + 0.1);

        osc.start(time);
        osc.stop(time + 0.1);
    }

    _scheduleHihat(time) {
        const src = this.ctx.createBufferSource();
        const env = this.ctx.createGain();
        const hpf = this.ctx.createBiquadFilter();

        src.buffer = this._hihatBuffer;
        hpf.type = 'highpass';
        hpf.frequency.value = 7000;

        src.connect(hpf);
        hpf.connect(env);
        env.connect(this.percGain);

        env.gain.setValueAtTime(0.6, time);
        env.gain.exponentialRampToValueAtTime(0.001, time + 0.03);

        src.start(time);
        src.stop(time + 0.03);
    }

    // --- Melody layer: square wave, only at intensity 2 ---
    _scheduleMelody(beat, time) {
        const freq = MELODY_NOTES[beat];
        if (!freq) return; // 0 = rest

        const osc = this.ctx.createOscillator();
        const env = this.ctx.createGain();

        osc.type = 'square';
        osc.frequency.setValueAtTime(freq * this._pitchScale, time);
        osc.connect(env);
        env.connect(this.melodyGain);

        const noteDur = BEAT_DURATION * 0.7;
        env.gain.setValueAtTime(0.001, time);
        env.gain.exponentialRampToValueAtTime(1.0, time + 0.015);
        env.gain.setValueAtTime(1.0, time + noteDur - 0.04);
        env.gain.exponentialRampToValueAtTime(0.001, time + noteDur);

        osc.start(time);
        osc.stop(time + noteDur);
    }
}
