---
has_reference: true
---

# SKILL: Game Audio Design

> Universal sound design principles for ANY game engine, ANY genre. Audio as a core pillar of game design, not an afterthought.

## Context

Audio is 50% of the player experience — ears can't close. This skill covers layered sound design, adaptive music, spatial audio, mix bus architecture, and event-driven systems. Patterns use Web Audio API but apply to any engine.

## Core Patterns

### Sound Layering: Base + Detail + Sweetener

- **Base**: Low-frequency core (150Hz square wave, 60ms)
- **Detail**: Mid-frequency texture (bandpass noise at 1400Hz, 40ms)
- **Sweetener**: High-frequency accent (sine at 3000Hz, 20ms)

Each layer in a different frequency band to avoid masking. 3+ layers feel designed.

### Variation (Prevent Repetition Fatigue)

Randomize per-play: pitch ±5-15%, volume ±10-20%. Never play identical sounds twice in a row.

### Priority System

1. **CRITICAL**: Player actions, enemy attacks — never suppress
2. **HIGH**: Combat feedback, stingers — drop other HIGH if queue full
3. **NORMAL**: Enemy idle, ambient — drop first when budget hit
4. **LOW**: UI clicks — lowest priority

Set `MAX_CONCURRENT` per priority. Player punch always plays, even if it cuts an enemy grunt.

### Mix Bus Architecture

```
Master → DynamicsCompressor → Destination
  ├─ SFX Bus (0.7)      → Player/Enemy/Ambient SFX
  ├─ Music Bus (0.5)     → Background/Combat/Stingers
  ├─ UI Bus (1.0)        → Menus, confirmations
  └─ Ambient Bus (0.08)  → Wind, rain, traffic
```

**Ducking**: When SFX plays, auto-lower music to 30-50% for 100-300ms, then fade back.

### Adaptive Music

- **Horizontal re-sequencing**: Swap sections by game state (calm→tense→climax). Crossfade 1-2s or wait for loop end.
- **Vertical layering**: Add/remove tracks as intensity rises (bass only → +drums → full orchestra). All layers share tempo/key.
- **Stingers**: Short phrases (<2s) for events — victory, danger, discovery. Queue FIFO, max 1 playing.

### Spatial Audio

- **2D panning**: `pan = (screenX / screenWidth) * 2 - 1`
- **Distance**: `volume = 1.0 / (1.0 + distance * 0.01)`
- **3D**: `PannerNode` with HRTF for elevation. Reverb zones by room size (300ms small, 3s hall).
- **Occlusion**: Attenuate high frequencies behind walls.

### Event-Driven Architecture

Decouple audio from gameplay — gameplay emits events, audio system listens:

```javascript
EventBus.on('player-attack', () => audio.playPunch());
EventBus.on('enemy-death', () => audio.playVictoryStinger());
```

### Web Audio API Essentials

- Resume `AudioContext` on first user gesture (browser policy)
- Synthesis = 0ms latency; MP3 playback = 20-50ms
- Codec strategy: OGG for quality, MP3 for compatibility
- `DynamicsCompressorNode` on master (threshold: -6dB, ratio: 4:1, attack: 10ms)

## Key Examples

### Layered Punch with Variation

```javascript
function playPunch(ctx, master) {
  const now = ctx.currentTime;
  const pVar = 0.9 + Math.random() * 0.2;
  const vVar = 0.8 + Math.random() * 0.4;

  // Base: low thud
  const bass = ctx.createOscillator();
  bass.type = 'square';
  bass.frequency.value = 150 * pVar;
  const bG = ctx.createGain();
  bG.gain.setValueAtTime(0.3 * vVar, now);
  bG.gain.exponentialRampToValueAtTime(0.001, now + 0.06);
  bass.connect(bG).connect(master);
  bass.start(now); bass.stop(now + 0.06);

  // Detail: bandpass noise crack
  const buf = ctx.createBuffer(1, ctx.sampleRate * 0.04, ctx.sampleRate);
  const d = buf.getChannelData(0);
  for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1;
  const noise = ctx.createBufferSource();
  noise.buffer = buf;
  const bp = ctx.createBiquadFilter();
  bp.type = 'bandpass'; bp.frequency.value = 1400 * pVar;
  const nG = ctx.createGain();
  nG.gain.setValueAtTime(0.2 * vVar, now);
  nG.gain.exponentialRampToValueAtTime(0.001, now + 0.04);
  noise.connect(bp).connect(nG).connect(master);
  noise.start(now); noise.stop(now + 0.04);
}
```

### Mix Bus Setup

```javascript
const ctx = new AudioContext();
const master = ctx.createGain();
const comp = ctx.createDynamicsCompressor();
comp.threshold.value = -6; comp.ratio.value = 4;
comp.connect(master); master.connect(ctx.destination);
const sfxBus = ctx.createGain(); sfxBus.gain.value = 0.7;
const musicBus = ctx.createGain(); musicBus.gain.value = 0.5;
[sfxBus, musicBus].forEach(b => b.connect(comp));
```

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| **Audio Last** | Design audio in parallel with gameplay |
| **Wall of Sound** | Priority system + frequency separation + ducking |
| **One Loop** | 3-4 variants (45-90s), layered intensity |
| **No Feedback Loop** | Every state change needs a sound |
| **Frequency Clash** | One sound per frequency band per moment |
| **Set-and-Forget Mix** | Re-test after every gameplay change |
| **Placeholder Sounds** | Procedural synthesis or custom originals |

---

*Skill by Greedo (Sound Designer). Cross-refs: procedural-audio, game-feel-juice.*
*Full reference: REFERENCE.md*
