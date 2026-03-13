# Audio Excellence Research — firstPunch

> Compressed from 26KB. Full: audio-excellence-research-archive.md

*Compiled by Greedo, Sound Designer | June 2025*
---

## 1. Procedural Audio Patterns for Synthesized Game SFX
### What Works
**Subtractive synthesis** (our primary technique): Generate a full-spectrum source (noise buffer or harmonically rich oscillator like square/sawtooth), then shape it with filters. This is the backbone of every impact, vocal, and ambience sound in our codebase.
### Techniques That Scale Well
| Technique | Use Case | Our Example |
| Sine + exponential decay | Thuds, drops, bass | Kick (80→40Hz), landing (55→30Hz) |
| Square wave + short envelope | Staccato, retro, alerts | Punch (150Hz, 0.05s), fanfares |
| Noise burst + bandpass | Cracks, snaps, transients | Hit mid layer (1400Hz), grunt (800Hz) |
| Noise + lowpass | Rumble, wind, ambient | Traffic (200Hz cutoff), kick texture |
---

## 2. Web Audio API Mastery — Advanced Techniques
### What We Use Well
- **OscillatorNode**: All 4 waveform types (sine, square, sawtooth, triangle). Frequency automation via `setValueAtTime`, `exponentialRampToValueAtTime`, `linearRampToValueAtTime`.
### Advanced Techniques We Should Know
### Performance Considerations
---

## 3. Dynamic Music Systems — Industry Leaders
### Hades (Supergiant Games / Darren Korb)
- **Stem-based adaptive music**: Full pre-recorded tracks split into stems (bass, drums, melody, pads). Stems are added/removed based on game state.
### Celeste (Lena Raine)
### Streets of Rage 4 (Yuzo Koshiro / Olivier Deriviere)
### Common Patterns Across All Three
---

## 4. Sound Design for Combat — Making Hits FEEL Impactful
### The Three Pillars of Impact Audio
**1. Frequency Layering (Low + Mid + High)**
### Combat Sound Design Principles
| Principle | Implementation | Our Status |
| Bass for weight | Sub-60Hz sine layer | ✅ Implemented |
| Transient for sharpness | Noise burst < 40ms | ✅ Implemented |
| Pitch variation | ±20% per play | ✅ Implemented |
| Combo escalation | Volume + layers increase | ✅ Implemented (AAA-A4) |
---

## 5. Mix Engineering — Balancing SFX / Music / Ambient
### Our Current Bus Architecture
```
### What We Got Right
### Mix Engineering Best Practices We Should Adopt
### Loudness Hierarchy (Correct Priority)
---

## 6. Limitations of Pure Synthesis vs. Real Samples
### What We CAN'T Do
| Limitation | Why | Impact |
| **Realistic speech** | Formant synthesis approximates vowels but not consonants, words, or recognizable character voices | Voice barks are abstract "vocal sounds" — players won't hear "Ugh!" as speech |
| **Instrument realism** | Oscillators produce static harmonic spectra; real instruments have time-varying harmonic content, resonance, and physical modeling nuances | Music sounds intentionally retro/chiptune rather than "real" |
| **Room/hall reverb** | ConvolverNode requires an impulse response file (audio sample). Our delay-feedback is a comb filter, not true reverb | Sounds feel "dry" and disconnected from any physical space |
| **Timbral richness** | Even with 3-layer hits, the component waveforms are mathematically perfect — lacking the noise floor, harmonic drift, and microvariation of recorded samples | Sounds are "clean" in a way that reads as synthetic |
| **One-shot complexity** | A recorded sword clash or glass break has thousands of micro-events in sub-100ms. We'd need dozens of simultaneous oscillators to approximate this | Our impacts are "suggestive" rather than "realistic" |
| **Dynamic range of vocals** | Real voice acting provides pitch contour, emotion, timing variation, character personality that synthesis can't achieve | Character barks work as abstract audio cues, not as performances |
---

## 7. Future: Audio Middleware for Web
### Tone.js
- **What**: High-level Web Audio API wrapper with synthesizers, effects, transport/scheduling
### Howler.js
### Pizzicato.js
### FMOD / Wwise — No Web Equivalent
---

## 8. firstPunch-Specific Learnings
### 21 Procedural Sounds — Assessment
| Sound | Method | Technique | Rating | Notes |
| Punch | `playPunch()` | Square wave, 150Hz, 0.05s | ⭐⭐⭐ | Snappy, good pitch variation. Could use noise transient layer. |
| Hit (layered) | `playLayeredHit()` | 3-band synthesis | ⭐⭐⭐⭐⭐ | Best sound in the system. True multi-layer design. |
| Hit Light | `playHitLight()` | Layered at 0.4 intensity | ⭐⭐⭐⭐ | Effective contrast with heavy hits. |
| Hit Heavy | `playHitHeavy()` | Layered at 1.0 + sparkle | ⭐⭐⭐⭐ | Satisfying with high combo. |
| Heavy Combo | `_playHeavyComboHit()` | Full layers + sub-bass (45→25Hz) | ⭐⭐⭐⭐⭐ | Extra sub-bass sells the power. |
| Massive Combo | `_playMassiveComboHit()` | Heavy + delay feedback reverb | ⭐⭐⭐⭐ | Reverb tail is a great touch. Delay time could be randomized slightly. |
---