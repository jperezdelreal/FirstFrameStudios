# SKILL: Procedural Audio for Browser Games

> Reusable patterns for building a complete game audio system using the Web Audio API with zero audio files.

---

## When to Use This Skill

- Building a browser game that needs SFX, music, and ambient audio
- Want zero-asset audio (no WAV/MP3 files to load)
- Targeting retro/chiptune aesthetic or need instant audio with no load time
- Project uses HTML5 Canvas or similar rendering (no engine audio system available)

## Prerequisites

- Web Audio API support (all modern browsers)
- ES module or similar module system
- A game loop that ticks per frame

---

## Architecture: Audio Module Pattern

### 1. Bus Topology (Set Up First)

```javascript
constructor() {
    this.context = new (window.AudioContext || window.webkitAudioContext)();

    // Mix buses — all route to master, master routes to speakers
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

    // Default loudness hierarchy
    this.sfxBus.gain.value = 0.7;      // SFX dominant
    this.musicBus.gain.value = 0.5;    // Music under SFX
    this.uiBus.gain.value = 1.0;       // UI full for responsiveness
    this.ambienceBus.gain.value = 0.08; // Ambience subliminal
    this.masterBus.gain.value = 1.0;   // Master at unity
}
```

**Rule**: Build this first. Every sound connects to a bus, never directly to `context.destination`.

### 2. AudioContext Resume (Day-1 Requirement)

```javascript
resume() {
    if (!this._resumed && this.context.state === 'suspended') {
        this.context.resume();
        this._resumed = true;
    }
}

// In your entry point (main.js):
['keydown', 'click', 'touchstart'].forEach(evt =>
    document.addEventListener(evt, () => audio.resume(), { once: true })
);
```

**Rule**: Create AudioContext eagerly, resume lazily on first user gesture. Never defer construction.

---

## Core Synthesis Patterns

### Pattern 1: Tonal Impact (Punch, Kick, Thud)

Frequency sweep downward + exponential decay = weight.

```javascript
playImpact(freq = 80, duration = 0.1) {
    const now = this.context.currentTime;
    const osc = this.context.createOscillator();
    const gain = this.context.createGain();
    osc.connect(gain);
    gain.connect(this.sfxBus);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, now);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.5, now + duration);
    gain.gain.setValueAtTime(0.3, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + duration);
    osc.start(now);
    osc.stop(now + duration);
}
```

**Variations**:
- Higher start freq (150Hz) + shorter duration (0.05s) + square wave = punch
- Lower start freq (80Hz) + longer duration (0.1s) + sine = kick
- Very low (300→50Hz) + long decay (0.3s) = KO/death

### Pattern 2: Noise Burst (Crack, Snap, Texture)

Noise buffer through bandpass filter = transient crack.

```javascript
playNoiseBurst(centerFreq = 1400, duration = 0.04, Q = 1.5) {
    const now = this.context.currentTime;
    const bufSize = Math.floor(this.context.sampleRate * duration);
    const buf = this.context.createBuffer(1, bufSize, this.context.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;

    const src = this.context.createBufferSource();
    src.buffer = buf;
    const bp = this.context.createBiquadFilter();
    bp.type = 'bandpass';
    bp.frequency.value = centerFreq;
    bp.Q.value = Q;
    const gain = this.context.createGain();
    src.connect(bp);
    bp.connect(gain);
    gain.connect(this.sfxBus);
    gain.gain.setValueAtTime(0.2, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + duration);
    src.start(now);
    src.stop(now + duration);
}
```

**Variations**:
- High centerFreq (7000Hz) + highpass = hi-hat / shimmer
- Low centerFreq (200Hz) + lowpass = rumble / distant noise
- Sweeping centerFreq (800→200Hz) = vocal/formant sound

### Pattern 3: Layered Hit (Multi-Band Impact)

Three simultaneous layers at different frequency bands = richness.

```javascript
playLayeredHit(intensity = 1.0) {
    const now = this.context.currentTime;

    // Layer 1: Bass body (sine, ~70Hz, 80ms)
    // Layer 2: Mid crack (noise burst, bandpass ~1400Hz, 40ms)
    // Layer 3: High sparkle (sine, ~2500Hz, 20ms) — only above 0.5 intensity

    // [See full implementation in audio.js playLayeredHit()]
}
```

**Key insight**: Single oscillators sound thin. 3+ layers at bass/mid/high sound designed. Always build combat sounds in layers.

### Pattern 4: Formant Vocal (Character Barks)

Bandpass-filtered noise with frequency sweep = vowel-like sound.

```javascript
playVocalBark(startFreq, endFreq, duration, baseFreq = 120) {
    const now = this.context.currentTime;

    // Base tone (sine at baseFreq) for vocal body
    const baseOsc = this.context.createOscillator();
    const baseGain = this.context.createGain();
    baseOsc.connect(baseGain);
    baseGain.connect(this.sfxBus);
    baseOsc.type = 'sine';
    baseOsc.frequency.value = baseFreq;
    baseGain.gain.setValueAtTime(0.25, now);
    baseGain.gain.exponentialRampToValueAtTime(0.01, now + duration);
    baseOsc.start(now);
    baseOsc.stop(now + duration);

    // Formant layer (noise through sweeping bandpass)
    const nBuf = Math.floor(this.context.sampleRate * duration);
    const buf = this.context.createBuffer(1, nBuf, this.context.sampleRate);
    const d = buf.getChannelData(0);
    for (let i = 0; i < nBuf; i++) d[i] = Math.random() * 2 - 1;
    const src = this.context.createBufferSource();
    src.buffer = buf;
    const bp = this.context.createBiquadFilter();
    bp.type = 'bandpass';
    bp.frequency.setValueAtTime(startFreq, now);
    bp.frequency.exponentialRampToValueAtTime(endFreq, now + duration);
    bp.Q.value = 5;
    const fGain = this.context.createGain();
    src.connect(bp);
    bp.connect(fGain);
    fGain.connect(this.sfxBus);
    fGain.gain.setValueAtTime(0.3, now);
    fGain.gain.exponentialRampToValueAtTime(0.01, now + duration);
    src.start(now);
    src.stop(now + duration);
}

// Descending formant = sad/mournful (800→200Hz)
// Ascending formant = excited/surprised (300→1200Hz)
```

### Pattern 5: Multi-Note Sequence (Fanfares, UI Feedback)

Timed array of notes for musical cues.

```javascript
playFanfare(notes, spacing, waveType = 'sine', noteDur = 0.1) {
    const now = this.context.currentTime;
    notes.forEach((freq, i) => {
        const t = now + i * spacing;
        const osc = this.context.createOscillator();
        const gain = this.context.createGain();
        osc.connect(gain);
        gain.connect(this.sfxBus);
        osc.type = waveType;
        osc.frequency.setValueAtTime(freq, t);
        gain.gain.setValueAtTime(0, t);
        gain.gain.linearRampToValueAtTime(0.25, t + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.01, t + noteDur);
        osc.start(t);
        osc.stop(t + noteDur);
    });
}

// Ascending = victory: [523, 659, 784]     (C5→E5→G5)
// Descending = danger: [659, 523, 440]     (E5→C5→A4)
// UI confirm = 2 notes: [523, 659]         (C5→E5)
```

### Pattern 6: Continuous Ambience

Looping noise buffers + LFO modulation = environmental atmosphere.

```javascript
startAmbience() {
    // Traffic: looping noise buffer → lowpass (200Hz) → ambienceBus
    // Wind: looping noise buffer → bandpass (800Hz) → LFO-modulated gain → ambienceBus
    // Bird chirps: setTimeout chain scheduling random sine blips every 5-8s
}

stopAmbience() {
    // Fade ambienceBus to 0 over 1s via linearRampToValueAtTime
    // After fade, stop/disconnect all source nodes and clear timeout chain
    // Restore bus gain to default
}
```

**Key insight**: Copy node/timer arrays before clearing to avoid race conditions during fade-out cleanup.

---

## Sound Variation System

### Pitch Randomization
```javascript
randomPitch(baseFreq, variance = 0.2) {
    return baseFreq * (1 + (Math.random() - 0.5) * 2 * variance);
}
```
Apply to every sound on every play. ±20% is the sweet spot — enough variation to avoid repetition, not enough to feel wrong.

### Priority & Deduplication
```javascript
// Per-type active sound counter with max simultaneous limit
canPlay(type, priority) {
    const count = this._typeCounts[type] || 0;
    if (count >= MAX_SAME_TYPE) return priority >= PRIORITY.PLAYER;
    return true;
}

// Per-frame pitch spread to prevent phasing when same sounds overlap
_pitchSpread(type) {
    const idx = this._framePlays[type] || 0;
    this._framePlays[type] = idx + 1;
    return [0, 0.05, 0.10][idx] || 0; // +5%, +10% for 2nd/3rd same-frame sounds
}
```

---

## Adaptive Music Pattern

### Scheduler Architecture
```javascript
// setInterval at 100ms checks if next beat needs scheduling
// Uses Web Audio API currentTime for sample-accurate timing
// 150ms lookahead prevents gaps between beats
_schedule() {
    while (this._nextBeatTime < this.ctx.currentTime + SCHEDULE_AHEAD) {
        this._scheduleBeat(this._beat, this._nextBeatTime);
        this._nextBeatTime += BEAT_DURATION;
        this._beat = (this._beat + 1) % LOOP_LENGTH;
    }
}
```

### Intensity Layers
- **Level 0 (exploration)**: Bass only, quiet
- **Level 1 (enemies nearby)**: Add percussion
- **Level 2 (combat)**: Add melody

Use `setTargetAtTime()` for smooth exponential crossfades between levels. Time constant of ~170ms feels natural.

---

## Spatial Audio

### sfxBus Swap Technique
```javascript
playAtPosition(soundFn, worldX, cameraX, screenWidth) {
    const screenX = worldX - cameraX;
    const pan = Math.max(-1, Math.min(1, (screenX / screenWidth) * 2 - 1));
    const panner = this.context.createStereoPanner();
    panner.pan.value = pan;
    panner.connect(this.sfxBus);

    const realBus = this.sfxBus;
    this.sfxBus = panner;
    soundFn();          // Sound connects to panner, thinking it's sfxBus
    this.sfxBus = realBus;
}
```

Works because Web Audio node connections are synchronous. Any sound function called within the swap period automatically gets spatial positioning.

---

## Common Pitfalls

1. **Forgetting AudioContext resume**: Sounds silently fail without user gesture. Add resume on day 1.
2. **Connecting to `context.destination`**: Always use a bus. Direct connections bypass volume control.
3. **Creating noise buffers per-call for continuous sounds**: Pre-compute and reuse for looping sources.
4. **Not cleaning up feedback loops**: Delay→feedback→delay chains will play forever if not disconnected. Use `setTimeout` to disconnect after expected duration.
5. **Using `exponentialRampToValueAtTime` to reach 0**: Exponential ramps can't reach 0. Use 0.001 or 0.01 as the target.
6. **Linear envelopes for impacts**: Exponential decay sounds natural; linear sounds artificial. Always use exponentialRamp for SFX.
7. **No priority system**: Without MAX_SAME_TYPE limiting, rapid combat creates an ear-piercing wall of overlapping sounds.

---

## Quick Reference: Frequency Cheat Sheet

| Sound | Frequency Range | Waveform | Duration |
|-------|----------------|----------|----------|
| Sub bass thud | 30-60Hz | sine | 60-100ms |
| Punch body | 100-200Hz | square | 30-60ms |
| Kick body | 60-100Hz → half | sine | 80-120ms |
| Impact crack | 800-2000Hz bandpass noise | noise+filter | 30-50ms |
| Sparkle/zing | 2000-4000Hz | sine | 15-25ms |
| Hi-hat | 7000Hz+ highpass noise | noise+filter | 20-40ms |
| Vocal formant | 300-1200Hz bandpass sweep | noise+filter | 100-400ms |
| Wind | 600-1000Hz bandpass noise | noise+filter+LFO | continuous |
| Traffic rumble | <200Hz lowpass noise | noise+filter | continuous |
| UI blip | 800-1500Hz | triangle | 30-60ms |
| Fanfare note | 400-1100Hz | sine/square | 60-120ms |

---

*Skill derived from firstPunch's 21-sound procedural audio system + adaptive music engine, June 2025.*
