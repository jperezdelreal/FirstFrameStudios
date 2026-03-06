// Sound priority levels — higher number = higher priority
const PRIORITY = { AMBIENT: 0, ENEMY: 1, PLAYER: 2 };
const MAX_SAME_TYPE = 3;

export class Audio {
    constructor() {
        this.context = new (window.AudioContext || window.webkitAudioContext)();
        this._resumed = false;

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
        bassGain.connect(this.context.destination);
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
        noiseGain.connect(this.context.destination);
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
            sparkleGain.connect(this.context.destination);
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

    playHit() {
        // P1-3: Randomly choose between 3 variations via the layered engine
        const roll = Math.random();
        if (roll < 0.33) {
            this.playHitLight();
        } else if (roll < 0.66) {
            this.playLayeredHit(0.85);
        } else {
            this.playHitHeavy();
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
        gain.connect(this.context.destination);
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
        noiseGain.connect(this.context.destination);
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
        gain.connect(this.context.destination);
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
        gain.connect(this.context.destination);

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
        gain.connect(this.context.destination);

        osc.type = type;
        osc.frequency.value = frequency;

        gain.gain.setValueAtTime(volume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + duration);

        osc.start(now);
        osc.stop(now + duration);
    }
}
