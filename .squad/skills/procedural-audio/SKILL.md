---
name: procedural-audio
version: 1.0
has_reference: true
---

# SKILL: Procedural Audio for Browser Games

> Zero-asset audio system using Web Audio API — SFX, music, and ambience with no WAV/MP3 files.

## Context

Build complete game audio using only the Web Audio API: oscillators for tones, noise buffers for texture, and gain nodes for envelopes. All sounds route through a bus topology (sfx/music/ui/ambience → master → destination) for mix control. AudioContext must be resumed on first user gesture — create eagerly, resume lazily.

## Core Patterns

### Bus Topology (Always Set Up First)

Create gain-node buses: `sfxBus`, `musicBus`, `uiBus`, `ambienceBus` → all connect to `masterBus` → `context.destination`. Default gains: SFX 0.7, music 0.5, UI 1.0, ambience 0.08. **Every sound connects to a bus, never directly to `context.destination`.**

### Synthesis Primitives

- **Tonal Impact** (punch/kick/thud): Oscillator with downward frequency sweep + `exponentialRampToValueAtTime` on gain. Vary freq (80–300Hz), duration (0.05–0.3s), and waveform (sine/square) for different impacts.
- **Noise Burst** (crack/snap/hi-hat): Create short noise buffer → bandpass `BiquadFilter` → gain envelope. Vary `centerFreq` (200–7000Hz) and `Q` for different textures.
- **Layered Hit**: Combine 3 layers (bass sine ~70Hz + mid noise burst ~1400Hz + high sine ~2500Hz) for rich combat sounds. Single oscillators sound thin.
- **Formant Vocal**: Base sine oscillator + noise through sweeping bandpass filter. Descending sweep = sad; ascending = excited.
- **Note Sequence**: Schedule oscillators at `currentTime + i * spacing` for fanfares/UI cues. Ascending notes = victory; descending = danger.
- **Ambience**: Looping noise buffers + LFO gain modulation on `ambienceBus`. Copy node arrays before clearing during fade-out cleanup.

### Procedural Generation Controls

- **Pitch randomization**: `baseFreq * (1 + (Math.random() - 0.5) * 2 * 0.2)` — ±20% variance on every play.
- **Priority/dedup**: Track per-type active sound count; enforce `MAX_SAME_TYPE` limit. Spread pitch +5%/+10% for same-frame overlaps.
- **Spatial panning**: Swap `sfxBus` reference to a `StereoPanner` node before calling a sound function, then restore. Synchronous node connections make this safe.
- **Adaptive music**: 100ms `setInterval` scheduler with 150ms lookahead using `currentTime` for sample-accurate beat timing. Layer intensity (bass → +percussion → +melody) with `setTargetAtTime()` crossfades (~170ms time constant).

## Key Examples

### Tonal Impact

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

### Noise Burst

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
    bp.type = 'bandpass'; bp.frequency.value = centerFreq; bp.Q.value = Q;
    const gain = this.context.createGain();
    src.connect(bp); bp.connect(gain); gain.connect(this.sfxBus);
    gain.gain.setValueAtTime(0.2, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + duration);
    src.start(now); src.stop(now + duration);
}
```

## Anti-Patterns

1. **Skipping AudioContext resume** — sounds silently fail without a user gesture; wire resume to `keydown`/`click`/`touchstart` on day 1.
2. **Connecting directly to `context.destination`** — bypasses all volume/mix control; always route through a bus.
3. **`exponentialRampToValueAtTime` targeting 0** — exponential ramps cannot reach zero; use 0.001 or 0.01 instead.
4. **Linear gain envelopes on impacts** — sounds artificial; always use `exponentialRamp` for natural decay.
5. **No sound priority system** — rapid combat spawns unbounded overlapping sounds; enforce `MAX_SAME_TYPE` limits.
6. **Allocating noise buffers per-call for looping sounds** — pre-compute and reuse buffers for continuous ambience.
7. **Unmanaged feedback loops** — delay→feedback→delay chains play forever; schedule `disconnect()` after expected duration.

---

*Full patterns, code, and frequency cheat sheet in REFERENCE.md. Derived from firstPunch's 21-sound procedural audio system, June 2025.*
