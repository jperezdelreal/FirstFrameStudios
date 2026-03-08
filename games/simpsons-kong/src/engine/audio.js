// Sound priority levels — higher number = higher priority
const PRIORITY = { AMBIENT: 0, ENEMY: 1, PLAYER: 2 };
const MAX_SAME_TYPE = 3;

export class Audio {
    constructor() {
        this.context = new (window.AudioContext || window.webkitAudioContext)();
        this._resumed = false;

        // EX-G2: Mix bus architecture — SFX, Music, UI → Master → destination
        this.masterBus = this.context.createGain();
        this.sfxBus = this.context.createGain();
        this.musicBus = this.context.createGain();
        this.uiBus = this.context.createGain();

        this.ambienceBus = this.context.createGain();

        this.sfxBus.connect(this.masterBus);
        this.musicBus.connect(this.masterBus);
        this.uiBus.connect(this.masterBus);
        this.ambienceBus.connect(this.masterBus);
        this.masterBus.connect(this.context.destination);

        // Default volumes
        this.masterBus.gain.value = 1.0;
        this.sfxBus.gain.value = 0.7;
        this.musicBus.gain.value = 0.5;
        this.uiBus.gain.value = 1.0;
        this.ambienceBus.gain.value = 0.08;

        // AAA-A2: Ambience state
        this._ambienceNodes = [];
        this._ambienceTimers = [];
        this._ambienceActive = false;

        // EX-G4: Sound priority & deduplication tracking
        this.activeSounds = 0;
        this._typeCounts = {};   // { 'hit': 2, 'punch': 1, ... }
        this._frameId = 0;
        this._framePlays = {};   // tracks plays-per-type this frame for pitch spread
    }

    resume() {
        if (!this._resumed && this.context.state === 'suspended') {
            this.context.resume();
            this._resumed = true;
        }
    }

    // --- P1-3: Pitch randomization helper ---
    randomPitch(baseFreq, variance = 0.2) {
        return baseFreq * (1 + (Math.random() - 0.5) * 2 * variance);
    }

    // --- EX-G4: Priority gate ---
    canPlay(type, priority) {
        const count = this._typeCounts[type] || 0;
        if (count >= MAX_SAME_TYPE) {
            // Player sounds always play; others get dropped
            return priority >= PRIORITY.PLAYER;
        }
        return true;
    }

    // Returns pitch spread offset for deduplication within a frame
    _pitchSpread(type) {
        const idx = this._framePlays[type] || 0;
        this._framePlays[type] = idx + 1;
        return [0, 0.05, 0.10][idx] || 0;
    }

    _trackSound(type, duration) {
        this._typeCounts[type] = (this._typeCounts[type] || 0) + 1;
        this.activeSounds++;
        setTimeout(() => {
            this._typeCounts[type] = Math.max(0, (this._typeCounts[type] || 1) - 1);
            this.activeSounds = Math.max(0, this.activeSounds - 1);
        }, duration * 1000 + 50);
    }

    // Call once per game frame to reset per-frame dedup tracking
    beginFrame() {
        this._frameId++;
        this._framePlays = {};
    }

    // --- EX-G3: Layered hit engine ---
    playLayeredHit(intensity = 1.0) {
        const type = 'hit';
        if (!this.canPlay(type, PRIORITY.ENEMY)) return;

        const now = this.context.currentTime;
        const spread = this._pitchSpread(type);

        // Layer 1: Bass body thud (sine 60-80Hz, 0.08s)
        const bassFreq = this.randomPitch(70, 0.15) * (1 + spread);
        const bassOsc = this.context.createOscillator();
        const bassGain = this.context.createGain();
        bassOsc.connect(bassGain);
        bassGain.connect(this.sfxBus);
        bassOsc.type = 'sine';
        bassOsc.frequency.setValueAtTime(bassFreq, now);
        bassGain.gain.setValueAtTime(0.3 * intensity, now);
        bassGain.gain.exponentialRampToValueAtTime(0.01, now + 0.08);
        bassOsc.start(now);
        bassOsc.stop(now + 0.08);

        // Layer 2: Mid impact crack (noise burst, bandpass 800-2000Hz, 0.04s)
        const bufSize = this.context.sampleRate * 0.04;
        const noiseBuf = this.context.createBuffer(1, bufSize, this.context.sampleRate);
        const data = noiseBuf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) {
            data[i] = (Math.random() * 2 - 1);
        }
        const noise = this.context.createBufferSource();
        const bandpass = this.context.createBiquadFilter();
        const noiseGain = this.context.createGain();
        noise.buffer = noiseBuf;
        bandpass.type = 'bandpass';
        bandpass.frequency.value = this.randomPitch(1400, 0.2) * (1 + spread);
        bandpass.Q.value = 1.5;
        noise.connect(bandpass);
        bandpass.connect(noiseGain);
        noiseGain.connect(this.sfxBus);
        noiseGain.gain.setValueAtTime(0.2 * intensity, now);
        noiseGain.gain.exponentialRampToValueAtTime(0.01, now + 0.04);
        noise.start(now);
        noise.stop(now + 0.04);

        // Layer 3: High sparkle ping — only on stronger hits (intensity > 0.5)
        if (intensity > 0.5) {
            const sparkleFreq = this.randomPitch(2500, 0.2) * (1 + spread);
            const sparkleOsc = this.context.createOscillator();
            const sparkleGain = this.context.createGain();
            sparkleOsc.connect(sparkleGain);
            sparkleGain.connect(this.sfxBus);
            sparkleOsc.type = 'sine';
            sparkleOsc.frequency.setValueAtTime(sparkleFreq, now);
            sparkleGain.gain.setValueAtTime(0.05 * intensity, now);
            sparkleGain.gain.exponentialRampToValueAtTime(0.01, now + 0.02);
            sparkleOsc.start(now);
            sparkleOsc.stop(now + 0.02);
        }

        this._trackSound(type, 0.08);
    }

    // --- Existing interface methods (signatures preserved) ---

    playPunch() {
        const type = 'punch';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const spread = this._pitchSpread(type);
        const freq = this.randomPitch(150, 0.2) * (1 + spread);
        this.playSound(freq, 0.05, 'square', 0.3);
        this._trackSound(type, 0.05);
    }

    playHit(comboCount = 0) {
        if (comboCount <= 0) {
            // Legacy random variation when no combo info provided
            const roll = Math.random();
            if (roll < 0.33) {
                this.playHitLight();
            } else if (roll < 0.66) {
                this.playLayeredHit(0.85);
            } else {
                this.playHitHeavy();
            }
            return;
        }

        // AAA-A4: Hit sound scaling by combo count
        if (comboCount <= 2) {
            this.playLayeredHit(0.35);
        } else if (comboCount <= 4) {
            this.playLayeredHit(0.65);
        } else if (comboCount <= 7) {
            this._playHeavyComboHit();
        } else {
            this._playMassiveComboHit();
        }
    }

    // P1-3: Light hit variant — lower intensity, skip sparkle
    playHitLight() {
        this.playLayeredHit(0.4);
    }

    // P1-3: Heavy hit variant — full intensity, slight bass boost
    playHitHeavy() {
        this.playLayeredHit(1.0);
    }

    // AAA-A4: Heavy combo hit — full 3-layer with extra sub-bass
    _playHeavyComboHit() {
        this.playLayeredHit(1.0);
        const now = this.context.currentTime;
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.sfxBus);
        osc.type = 'sine';
        osc.frequency.setValueAtTime(this.randomPitch(45, 0.15), now);
        osc.frequency.exponentialRampToValueAtTime(25, now + 0.1);
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.1);
        osc.start(now);
        osc.stop(now + 0.1);
    }

    // AAA-A4: Massive combo hit — all layers + reverb tail via delay feedback
    _playMassiveComboHit() {
        this._playHeavyComboHit();
        const now = this.context.currentTime;

        const delay = this.context.createDelay();
        delay.delayTime.value = 0.08;
        const feedback = this.context.createGain();
        feedback.gain.value = 0.3;
        const tailGain = this.context.createGain();
        tailGain.gain.setValueAtTime(0.15, now);
        tailGain.gain.exponentialRampToValueAtTime(0.01, now + 0.4);

        // Short burst feeds the delay network
        const osc = this.context.createOscillator();
        const burstGain = this.context.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(this.randomPitch(60, 0.2), now);
        osc.frequency.exponentialRampToValueAtTime(30, now + 0.05);
        burstGain.gain.setValueAtTime(0.2, now);
        burstGain.gain.exponentialRampToValueAtTime(0.01, now + 0.05);

        osc.connect(burstGain);
        burstGain.connect(delay);
        delay.connect(feedback);
        feedback.connect(delay);
        delay.connect(tailGain);
        tailGain.connect(this.sfxBus);

        osc.start(now);
        osc.stop(now + 0.05);

        setTimeout(() => {
            try { feedback.disconnect(); } catch (_) {}
            try { delay.disconnect(); } catch (_) {}
            try { tailGain.disconnect(); } catch (_) {}
        }, 500);
    }

    playKick() {
        const type = 'kick';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const spread = this._pitchSpread(type);
        const now = this.context.currentTime;

        // Low sine thud with pitch variation
        const baseFreq = this.randomPitch(80, 0.2) * (1 + spread);
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.sfxBus);
        osc.type = 'sine';
        osc.frequency.setValueAtTime(baseFreq, now);
        osc.frequency.exponentialRampToValueAtTime(baseFreq * 0.5, now + 0.1);
        gain.gain.setValueAtTime(0.35, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.1);
        osc.start(now);
        osc.stop(now + 0.1);

        // Noise burst for impact texture
        const bufferSize = this.context.sampleRate * 0.06;
        const noiseBuffer = this.context.createBuffer(1, bufferSize, this.context.sampleRate);
        const data = noiseBuffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = (Math.random() * 2 - 1) * 0.4;
        }
        const noise = this.context.createBufferSource();
        const noiseGain = this.context.createGain();
        const filter = this.context.createBiquadFilter();
        noise.buffer = noiseBuffer;
        filter.type = 'lowpass';
        filter.frequency.value = 500;
        noise.connect(filter);
        filter.connect(noiseGain);
        noiseGain.connect(this.sfxBus);
        noiseGain.gain.setValueAtTime(0.25, now);
        noiseGain.gain.exponentialRampToValueAtTime(0.01, now + 0.06);
        noise.start(now);
        noise.stop(now + 0.06);

        this._trackSound(type, 0.1);
    }

    playJump() {
        const type = 'jump';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const baseFreq = this.randomPitch(200, 0.1);
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.sfxBus);
        osc.type = 'sine';
        osc.frequency.setValueAtTime(baseFreq, now);
        osc.frequency.exponentialRampToValueAtTime(baseFreq * 2, now + 0.08);
        gain.gain.setValueAtTime(0.15, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.08);
        osc.start(now);
        osc.stop(now + 0.08);
        this._trackSound(type, 0.08);
    }

    playKO() {
        const type = 'ko';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();

        osc.connect(gain);
        gain.connect(this.sfxBus);

        osc.type = 'sine';
        osc.frequency.setValueAtTime(this.randomPitch(300, 0.1), now);
        osc.frequency.exponentialRampToValueAtTime(50, now + 0.3);

        gain.gain.setValueAtTime(0.3, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.3);

        osc.start(now);
        osc.stop(now + 0.3);
        this._trackSound(type, 0.3);
    }

    playSound(frequency, duration, type = 'sine', volume = 0.2) {
        const now = this.context.currentTime;
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();

        osc.connect(gain);
        gain.connect(this.sfxBus);

        osc.type = type;
        osc.frequency.value = frequency;

        gain.gain.setValueAtTime(volume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + duration);

        osc.start(now);
        osc.stop(now + duration);
    }

    // --- P2-11: Wave fanfares ---

    playWaveStart() {
        const type = 'fanfare';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const notes = [659, 523, 440]; // E5→C5→A4, descending danger cue
        notes.forEach((freq, i) => {
            const t = now + i * 0.1;
            const osc = this.context.createOscillator();
            const gain = this.context.createGain();
            osc.connect(gain);
            gain.connect(this.sfxBus);
            osc.type = 'square';
            osc.frequency.setValueAtTime(this.randomPitch(freq, 0.05), t);
            gain.gain.setValueAtTime(0, t);
            gain.gain.linearRampToValueAtTime(0.25, t + 0.01);
            gain.gain.exponentialRampToValueAtTime(0.01, t + 0.07);
            osc.start(t);
            osc.stop(t + 0.07);
        });
        this._trackSound(type, 0.3);
    }

    playWaveClear() {
        const type = 'fanfare';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const notes = [523, 659, 784]; // C5→E5→G5, ascending victory
        notes.forEach((freq, i) => {
            const t = now + i * 0.15;
            const osc = this.context.createOscillator();
            const gain = this.context.createGain();
            osc.connect(gain);
            gain.connect(this.sfxBus);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(this.randomPitch(freq, 0.03), t);
            gain.gain.setValueAtTime(0, t);
            gain.gain.linearRampToValueAtTime(0.3, t + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.01, t + 0.12);
            osc.start(t);
            osc.stop(t + 0.12);
        });
        this._trackSound(type, 0.45);
    }

    playLevelComplete() {
        const type = 'fanfare';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const notes = [523, 659, 784, 1047]; // C5→E5→G5→C6, ascending arpeggio
        notes.forEach((freq, i) => {
            const t = now + i * 0.1;
            const isLast = i === notes.length - 1;
            const dur = isLast ? 0.4 : 0.09;
            const osc = this.context.createOscillator();
            const gain = this.context.createGain();
            osc.connect(gain);
            gain.connect(this.sfxBus);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(this.randomPitch(freq, 0.02), t);
            gain.gain.setValueAtTime(0, t);
            gain.gain.linearRampToValueAtTime(0.3, t + 0.015);
            gain.gain.exponentialRampToValueAtTime(0.01, t + dur);
            osc.start(t);
            osc.stop(t + dur);
        });
        this._trackSound(type, 0.7);
    }

    // --- EX-G5: Player vocal sounds ---

    playGrunt() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const bufSize = Math.floor(this.context.sampleRate * 0.05);
        const buf = this.context.createBuffer(1, bufSize, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.value = this.randomPitch(800, 0.25);
        bp.Q.value = 3;
        const gain = this.context.createGain();
        src.connect(bp);
        bp.connect(gain);
        gain.connect(this.sfxBus);
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.05);
        src.start(now);
        src.stop(now + 0.05);
        this._trackSound(type, 0.05);
    }

    playExertion() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const dur = 0.12;
        const bufSize = Math.floor(this.context.sampleRate * dur);
        const buf = this.context.createBuffer(1, bufSize, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.setValueAtTime(this.randomPitch(600, 0.2), now);
        bp.frequency.exponentialRampToValueAtTime(350, now + dur);
        bp.Q.value = 4;
        const gain = this.context.createGain();
        src.connect(bp);
        bp.connect(gain);
        gain.connect(this.sfxBus);
        gain.gain.setValueAtTime(0.25, now);
        gain.gain.linearRampToValueAtTime(0.18, now + 0.04);
        gain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        src.start(now);
        src.stop(now + dur);
        this._trackSound(type, dur);
    }

    playOof() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const dur = 0.15;
        const bufSize = Math.floor(this.context.sampleRate * dur);
        const buf = this.context.createBuffer(1, bufSize, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.setValueAtTime(this.randomPitch(1000, 0.15), now);
        bp.frequency.exponentialRampToValueAtTime(400, now + dur);
        bp.Q.value = 3.5;
        const gain = this.context.createGain();
        src.connect(bp);
        bp.connect(gain);
        gain.connect(this.sfxBus);
        gain.gain.setValueAtTime(0.22, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        src.start(now);
        src.stop(now + dur);
        this._trackSound(type, dur);
    }

    playLanding() {
        const type = 'landing';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.sfxBus);
        osc.type = 'sine';
        osc.frequency.setValueAtTime(this.randomPitch(55, 0.15), now);
        osc.frequency.exponentialRampToValueAtTime(30, now + 0.06);
        gain.gain.setValueAtTime(0.25, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.06);
        osc.start(now);
        osc.stop(now + 0.06);
        this._trackSound(type, 0.06);
    }

    // --- AAA-A1: Character voice barks (procedural synthesis) ---

    // Homer's "D'oh!" — descending formant with low sine base
    playDoh() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const dur = 0.3;

        // Base tone: low sine ~120Hz for vocal body
        const baseOsc = this.context.createOscillator();
        const baseGain = this.context.createGain();
        baseOsc.connect(baseGain);
        baseGain.connect(this.sfxBus);
        baseOsc.type = 'sine';
        baseOsc.frequency.setValueAtTime(this.randomPitch(120, 0.1), now);
        baseGain.gain.setValueAtTime(0.25, now);
        baseGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        baseOsc.start(now);
        baseOsc.stop(now + dur);

        // Formant layer: bandpass sweep 800Hz→200Hz (descending mournful vowel)
        const nBuf = Math.floor(this.context.sampleRate * dur);
        const buf = this.context.createBuffer(1, nBuf, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < nBuf; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.setValueAtTime(800, now);
        bp.frequency.exponentialRampToValueAtTime(200, now + dur);
        bp.Q.value = 5;
        const fGain = this.context.createGain();
        src.connect(bp);
        bp.connect(fGain);
        fGain.connect(this.sfxBus);
        fGain.gain.setValueAtTime(0.3, now);
        fGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        src.start(now);
        src.stop(now + dur);

        this._trackSound(type, dur);
    }

    // Homer's "Woohoo!" — ascending formant with excitement tremolo
    playWoohoo() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const dur = 0.4;

        // Base tone with rising pitch
        const baseOsc = this.context.createOscillator();
        const baseGain = this.context.createGain();
        baseOsc.connect(baseGain);
        baseGain.connect(this.sfxBus);
        baseOsc.type = 'sine';
        baseOsc.frequency.setValueAtTime(this.randomPitch(150, 0.1), now);
        baseOsc.frequency.linearRampToValueAtTime(300, now + dur);
        baseGain.gain.setValueAtTime(0.2, now);
        baseGain.gain.setValueAtTime(0.2, now + dur * 0.7);
        baseGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        baseOsc.start(now);
        baseOsc.stop(now + dur);

        // Excitement oscillation: rapid volume tremolo via LFO
        const lfo = this.context.createOscillator();
        const lfoGain = this.context.createGain();
        lfo.type = 'sine';
        lfo.frequency.value = 12;
        lfoGain.gain.value = 0.08;
        lfo.connect(lfoGain);
        lfoGain.connect(baseGain.gain);
        lfo.start(now);
        lfo.stop(now + dur);

        // Ascending formant sweep 300Hz→1200Hz (excited vowel)
        const nBuf = Math.floor(this.context.sampleRate * dur);
        const buf = this.context.createBuffer(1, nBuf, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < nBuf; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.setValueAtTime(300, now);
        bp.frequency.exponentialRampToValueAtTime(1200, now + dur);
        bp.Q.value = 6;
        const fGain = this.context.createGain();
        src.connect(bp);
        bp.connect(fGain);
        fGain.connect(this.sfxBus);
        fGain.gain.setValueAtTime(0.25, now);
        fGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        src.start(now);
        src.stop(now + dur);

        this._trackSound(type, dur);
    }

    // Homer's "Mmm... donuts" — low sustained hum with pitch wobble
    playMmmDonuts() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const dur = 0.5;

        // Low sustained hum ~100Hz
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.sfxBus);
        osc.type = 'sine';
        osc.frequency.setValueAtTime(100, now);
        gain.gain.setValueAtTime(0, now);
        gain.gain.linearRampToValueAtTime(0.2, now + 0.05);
        gain.gain.setValueAtTime(0.2, now + dur * 0.7);
        gain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        osc.start(now);
        osc.stop(now + dur);

        // Pitch wobble LFO — satisfied lazy vibrato
        const lfo = this.context.createOscillator();
        const lfoGain = this.context.createGain();
        lfo.type = 'sine';
        lfo.frequency.value = 3;
        lfoGain.gain.value = 5;
        lfo.connect(lfoGain);
        lfoGain.connect(osc.frequency);
        lfo.start(now);
        lfo.stop(now + dur);

        // Soft nasal formant layer
        const nBuf = Math.floor(this.context.sampleRate * dur);
        const buf = this.context.createBuffer(1, nBuf, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < nBuf; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.value = 250;
        bp.Q.value = 8;
        const fGain = this.context.createGain();
        src.connect(bp);
        bp.connect(fGain);
        fGain.connect(this.sfxBus);
        fGain.gain.setValueAtTime(0, now);
        fGain.gain.linearRampToValueAtTime(0.1, now + 0.08);
        fGain.gain.setValueAtTime(0.1, now + dur * 0.65);
        fGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        src.start(now);
        src.stop(now + dur);

        this._trackSound(type, dur);
    }

    // Bart's "Ay Caramba!" — sharp ascending noise with high formant sweep
    playAyCaramba() {
        const type = 'vocal';
        if (!this.canPlay(type, PRIORITY.PLAYER)) return;
        const now = this.context.currentTime;
        const dur = 0.35;

        // Ascending noise burst with formant sweep
        const nBuf = Math.floor(this.context.sampleRate * dur);
        const buf = this.context.createBuffer(1, nBuf, this.context.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < nBuf; i++) d[i] = Math.random() * 2 - 1;
        const src = this.context.createBufferSource();
        src.buffer = buf;
        const bp = this.context.createBiquadFilter();
        bp.type = 'bandpass';
        bp.frequency.setValueAtTime(600, now);
        bp.frequency.exponentialRampToValueAtTime(2400, now + dur * 0.6);
        bp.frequency.setValueAtTime(2400, now + dur * 0.6);
        bp.frequency.exponentialRampToValueAtTime(1800, now + dur);
        bp.Q.value = 5;
        const fGain = this.context.createGain();
        src.connect(bp);
        bp.connect(fGain);
        fGain.connect(this.sfxBus);
        fGain.gain.setValueAtTime(0.3, now);
        fGain.gain.setValueAtTime(0.3, now + dur * 0.3);
        fGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        src.start(now);
        src.stop(now + dur);

        // High-pitched sawtooth sweep for excitement edge
        const osc = this.context.createOscillator();
        const oGain = this.context.createGain();
        osc.connect(oGain);
        oGain.connect(this.sfxBus);
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(this.randomPitch(400, 0.15), now);
        osc.frequency.exponentialRampToValueAtTime(1200, now + dur * 0.5);
        osc.frequency.exponentialRampToValueAtTime(800, now + dur);
        oGain.gain.setValueAtTime(0.08, now);
        oGain.gain.exponentialRampToValueAtTime(0.01, now + dur);
        osc.start(now);
        osc.stop(now + dur);

        this._trackSound(type, dur);
    }

    // --- EX-G7: Spatial audio panning ---

    playAtPosition(soundFn, worldX, cameraX, screenWidth) {
        const screenX = worldX - cameraX;
        const pan = Math.max(-1, Math.min(1, (screenX / screenWidth) * 2 - 1));
        const panner = this.context.createStereoPanner();
        panner.pan.value = pan;
        panner.connect(this.sfxBus);

        // Temporarily redirect sfxBus so play methods route through the panner
        const realBus = this.sfxBus;
        this.sfxBus = panner;
        soundFn();
        this.sfxBus = realBus;
    }

    // --- AAA-A2: Environmental ambience ---

    startAmbience(level = 1) {
        this.stopAmbience();
        this._ambienceActive = true;
        const now = this.context.currentTime;
        this.ambienceBus.gain.setValueAtTime(0.08, now);

        if (level === 1) {
            // Downtown Springfield

            // 1. Distant traffic: very low-pass filtered looping noise
            const trafficDur = 4;
            const trafficBuf = this.context.createBuffer(1,
                Math.floor(this.context.sampleRate * trafficDur), this.context.sampleRate);
            const td = trafficBuf.getChannelData(0);
            for (let i = 0; i < td.length; i++) td[i] = Math.random() * 2 - 1;
            const trafficSrc = this.context.createBufferSource();
            trafficSrc.buffer = trafficBuf;
            trafficSrc.loop = true;
            const trafficLP = this.context.createBiquadFilter();
            trafficLP.type = 'lowpass';
            trafficLP.frequency.value = 200;
            trafficLP.Q.value = 0.5;
            const trafficGain = this.context.createGain();
            trafficGain.gain.value = 0.06;
            trafficSrc.connect(trafficLP);
            trafficLP.connect(trafficGain);
            trafficGain.connect(this.ambienceBus);
            trafficSrc.start(now);
            this._ambienceNodes.push(trafficSrc, trafficGain);

            // 2. Bird chirps: high sine blips every 5-8s random interval
            const scheduleBird = () => {
                if (!this._ambienceActive) return;
                const t = this.context.currentTime;
                const freq = this.randomPitch(3200, 0.3);
                const osc = this.context.createOscillator();
                const g = this.context.createGain();
                osc.connect(g);
                g.connect(this.ambienceBus);
                osc.type = 'sine';
                osc.frequency.setValueAtTime(freq, t);
                osc.frequency.linearRampToValueAtTime(freq * 1.3, t + 0.04);
                osc.frequency.linearRampToValueAtTime(freq * 0.9, t + 0.08);
                g.gain.setValueAtTime(0.05, t);
                g.gain.exponentialRampToValueAtTime(0.01, t + 0.1);
                osc.start(t);
                osc.stop(t + 0.1);
                const next = 5000 + Math.random() * 3000;
                this._ambienceTimers.push(setTimeout(scheduleBird, next));
            };
            this._ambienceTimers.push(setTimeout(scheduleBird, 2000 + Math.random() * 3000));

            // 3. Wind: filtered noise with slow gain swell via LFO
            const windDur = 6;
            const windBuf = this.context.createBuffer(1,
                Math.floor(this.context.sampleRate * windDur), this.context.sampleRate);
            const wd = windBuf.getChannelData(0);
            for (let i = 0; i < wd.length; i++) wd[i] = Math.random() * 2 - 1;
            const windSrc = this.context.createBufferSource();
            windSrc.buffer = windBuf;
            windSrc.loop = true;
            const windBP = this.context.createBiquadFilter();
            windBP.type = 'bandpass';
            windBP.frequency.value = 800;
            windBP.Q.value = 0.3;
            const windGain = this.context.createGain();
            windGain.gain.value = 0;
            windSrc.connect(windBP);
            windBP.connect(windGain);
            windGain.connect(this.ambienceBus);
            windSrc.start(now);
            this._ambienceNodes.push(windSrc, windGain);

            // Wind swell LFO
            const windLfo = this.context.createOscillator();
            const windLfoGain = this.context.createGain();
            windLfo.type = 'sine';
            windLfo.frequency.value = 0.15;
            windLfoGain.gain.value = 0.04;
            windLfo.connect(windLfoGain);
            windLfoGain.connect(windGain.gain);
            windLfo.start(now);
            this._ambienceNodes.push(windLfo);
        }
    }

    stopAmbience() {
        this._ambienceActive = false;
        const now = this.context.currentTime;
        this.ambienceBus.gain.setValueAtTime(this.ambienceBus.gain.value, now);
        this.ambienceBus.gain.linearRampToValueAtTime(0, now + 1);

        // Clean up nodes after the 1s fade
        const nodesToClean = this._ambienceNodes.slice();
        const timersToClean = this._ambienceTimers.slice();
        this._ambienceNodes = [];
        this._ambienceTimers = [];

        setTimeout(() => {
            nodesToClean.forEach(node => {
                try { node.stop(); } catch (_) {}
                try { node.disconnect(); } catch (_) {}
            });
            timersToClean.forEach(t => clearTimeout(t));
            this.ambienceBus.gain.value = 0.08;
        }, 1100);
    }

    // --- UI sounds (routed through uiBus) ---

    playMenuSelect() {
        const now = this.context.currentTime;
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.uiBus);
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(1200, now);
        gain.gain.setValueAtTime(0.18, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.04);
        osc.start(now);
        osc.stop(now + 0.04);
    }

    playMenuConfirm() {
        const now = this.context.currentTime;
        // Two-note ascending confirmation: C5 → E5
        [523, 659].forEach((freq, i) => {
            const t = now + i * 0.06;
            const osc = this.context.createOscillator();
            const gain = this.context.createGain();
            osc.connect(gain);
            gain.connect(this.uiBus);
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(freq, t);
            gain.gain.setValueAtTime(0.22, t);
            gain.gain.exponentialRampToValueAtTime(0.01, t + 0.06);
            osc.start(t);
            osc.stop(t + 0.06);
        });
    }

    // --- EX-G2: Volume control methods ---

    setSFXVolume(v) {
        this.sfxBus.gain.value = Math.max(0, Math.min(1, v));
    }

    setMusicVolume(v) {
        this.musicBus.gain.value = Math.max(0, Math.min(1, v));
    }

    setUIVolume(v) {
        this.uiBus.gain.value = Math.max(0, Math.min(1, v));
    }

    setMasterVolume(v) {
        this.masterBus.gain.value = Math.max(0, Math.min(1, v));
    }

    setAmbienceVolume(v) {
        this.ambienceBus.gain.value = Math.max(0, Math.min(1, v));
    }

    getSFXVolume() {
        return this.sfxBus.gain.value;
    }

    getMusicVolume() {
        return this.musicBus.gain.value;
    }

    getUIVolume() {
        return this.uiBus.gain.value;
    }

    getMasterVolume() {
        return this.masterBus.gain.value;
    }

    getAmbienceVolume() {
        return this.ambienceBus.gain.value;
    }
}
