# Audio Excellence Research — firstPunch

*Compiled by Greedo, Sound Designer | June 2025*

---

## 1. Procedural Audio Patterns for Synthesized Game SFX

### What Works

**Subtractive synthesis** (our primary technique): Generate a full-spectrum source (noise buffer or harmonically rich oscillator like square/sawtooth), then shape it with filters. This is the backbone of every impact, vocal, and ambience sound in our codebase.

**Frequency sweeps for motion**: Rapid pitch drops convey impacts (KO: 300→50Hz over 0.3s). Ascending sweeps convey upward motion (jump: 200→400Hz). The brain interprets pitch direction as physical direction — this is one of the most reliable procedural techniques.

**Noise + filter = texture**: White noise through a bandpass filter at ~1400Hz with Q=1.5 creates convincing "crack" textures for impacts. Through a highpass at 7kHz it becomes hi-hats. Through a lowpass at 200Hz it becomes traffic rumble. Noise is the single most versatile procedural building block.

**Layered synthesis for richness**: Our `playLayeredHit()` fires 3 simultaneous components at different frequency bands (bass body, mid crack, high sparkle). This is the key insight — single oscillators sound thin and synthetic; multi-layer sounds with different timbres per band sound designed.

**Formant synthesis for "vocals"**: Bandpass-filtered noise with frequency sweeps approximates vowel sounds. Our Ugh (800→200Hz descent) and Woohoo (300→1200Hz ascent) demonstrate that directional formant sweeps convey emotional character even without real speech.

### Techniques That Scale Well

| Technique | Use Case | Our Example |
|-----------|----------|-------------|
| Sine + exponential decay | Thuds, drops, bass | Kick (80→40Hz), landing (55→30Hz) |
| Square wave + short envelope | Staccato, retro, alerts | Punch (150Hz, 0.05s), fanfares |
| Noise burst + bandpass | Cracks, snaps, transients | Hit mid layer (1400Hz), grunt (800Hz) |
| Noise + lowpass | Rumble, wind, ambient | Traffic (200Hz cutoff), kick texture |
| Noise + highpass | Shimmer, hats, air | Hi-hat (7kHz), wind layer |
| LFO modulation | Vibrato, tremolo, swells | Woohoo tremolo (12Hz), wind LFO (0.15Hz) |
| Multi-note sequencing | Fanfares, melodies, UI feedback | WaveStart (3 notes), MenuConfirm (2 notes) |

### What Doesn't Work Well Procedurally

- **Realistic speech**: Formant synthesis approximates vowels but can't produce consonants, sibilants, or recognizable words
- **String/pluck instruments**: Karplus-Strong synthesis exists but requires careful tuning and still sounds obviously synthetic
- **Complex timbres**: Real instruments have time-varying harmonic spectra that oscillators can't reproduce
- **Room acoustics**: Our delay-feedback "reverb" in `_playMassiveComboHit()` is crude compared to convolution reverb

---

## 2. Web Audio API Mastery — Advanced Techniques

### What We Use Well

- **OscillatorNode**: All 4 waveform types (sine, square, sawtooth, triangle). Frequency automation via `setValueAtTime`, `exponentialRampToValueAtTime`, `linearRampToValueAtTime`.
- **GainNode**: Amplitude envelopes, mix buses, LFO targets. `setTargetAtTime` for exponential crossfades.
- **BiquadFilterNode**: lowpass, highpass, bandpass with Q control. Frequency sweeps for formants.
- **BufferSource**: Runtime-generated noise buffers for texture. Pre-computed buffers (hi-hat) for performance.
- **StereoPannerNode**: Spatial positioning in `playAtPosition()`.
- **DelayNode + feedback**: Primitive reverb in massive combo hits.
- **Audio parameter automation**: All envelope shaping done through k-rate parameter scheduling — zero JavaScript per-sample overhead.

### Advanced Techniques We Should Know

**ConvolverNode** — Applies impulse response (IR) reverb to any sound. A recorded IR of a room/hall/cathedral can make procedural sounds feel like they exist in a physical space. This is the single biggest upgrade we could make — it transforms flat synthesizer output into spatial, convincing audio. Limitation: requires loading a WAV/audio file as the IR buffer.

**WaveShaperNode** — Nonlinear distortion curve applied to audio signal. Use cases:
- Soft clipping (tube amp warmth) — apply a `tanh` curve to add harmonic saturation
- Hard clipping for aggressive distortion on hit sounds
- Bit-crushing effect by quantizing the curve to discrete steps
- We could use this to add "grit" to our punch/kick sounds

**AudioWorkletNode** — Run custom DSP code per-sample in a dedicated thread. Use cases:
- Custom synthesis algorithms (Karplus-Strong for plucked strings)
- Granular synthesis for texture morphing
- Per-sample effects impossible with built-in nodes
- Limitation: requires separate worklet JS file, more complex setup, and may have latency on first load

**AnalyserNode** — FFT analysis of audio signal. Use cases:
- Visual audio meters for settings UI
- Beat detection for visual synchronization
- Frequency-reactive particle effects during combat

**ChannelSplitterNode / ChannelMergerNode** — Split stereo into L/R channels for independent processing. Enables true stereo effects beyond simple panning.

**DynamicsCompressorNode** — Automatic gain compression. Could add to masterBus to prevent clipping during intense combat with many simultaneous sounds. Built-in but we're not using it — a free win for mix stability.

### Performance Considerations

- OscillatorNodes and BufferSources are **one-shot** — can't be restarted, must create new ones each play. This is by design and works fine for SFX.
- Our per-call noise buffer creation (e.g., `playKick()` creates a fresh buffer every call) is fine for SFX but would be wasteful for continuous sources. Pre-creating buffers (like `_hihatBuffer` in Music) is the right pattern.
- `setTimeout` for cleanup is appropriate — Web Audio nodes are GC'd when disconnected, but explicit cleanup prevents leaked feedback loops.

---

## 3. Dynamic Music Systems — Industry Leaders

### Hades (Supergiant Games / Darren Korb)

- **Stem-based adaptive music**: Full pre-recorded tracks split into stems (bass, drums, melody, pads). Stems are added/removed based on game state.
- **Seamless room transitions**: Music crossfades between regions. When entering a combat room, drums and aggressive stems fade in over 1-2 seconds while ambient pads fade out.
- **Death/resurrection music continuity**: Music carries emotional weight by maintaining key and tempo across gameplay transitions.
- **Takeaway**: Stems > procedural for emotional depth. Our intensity system (bass-only → percussion → melody) mirrors this architecture but with synthesized sources instead of recordings.

### Celeste (Lena Raine)

- **Layer activation by game state**: Core loops persist, layers toggle on/off based on proximity to hazards, collectibles, or story beats.
- **Pitch/tempo scaling**: Music slows with the character during certain mechanics, maintaining synchronization between movement and score.
- **Emotional progression**: Each chapter's music evolves as the player progresses, with new layers unlocking at checkpoints.
- **Takeaway**: Layer activation is exactly our intensity model. Celeste proves it works at the highest level — the difference is production quality of the source material.

### Streets of Rage 4 (Yuzo Koshiro / Olivier Deriviere)

- **Retro synthesis meets modern production**: FM synthesis and chiptune-style sequences deliberately harken to the Genesis originals while being produced at modern fidelity.
- **Combat intensity tracking**: Music escalates with combo count and screen enemy density — almost exactly our model.
- **Genre awareness**: Beat 'em up music must maintain rhythmic drive without becoming fatiguing over long sessions. Percussion-forward, melodically restrained.
- **Takeaway**: SoR4 validates our musical approach for the genre. Simple melodic phrases that loop cleanly are preferable to complex arrangements that become tiresome.

### Common Patterns Across All Three

1. **Horizontal re-sequencing**: Same tempo, different sections triggered by game state
2. **Vertical mixing**: Layered stems faded in/out — exactly our bass/perc/melody architecture
3. **Musical key consistency**: All layers share the same key to allow any combination
4. **Beat-quantized transitions**: Changes happen on beat boundaries to maintain groove

### What We're Missing vs. Professional Implementations

- **Audio file stems**: Our oscillators can't match the richness of produced recordings
- **Section variation**: We loop 8 beats forever; professional games have A/B/C sections
- **Transition stingers**: Short musical phrases that bridge between intensity levels
- **Dynamic tempo**: Our BPM is fixed at 112; adaptive tempo could match action speed

---

## 4. Sound Design for Combat — Making Hits FEEL Impactful

### The Three Pillars of Impact Audio

**1. Frequency Layering (Low + Mid + High)**
Every impactful hit in professional games contains three simultaneous frequency bands:
- **Sub/bass (30-100Hz)**: The physical "punch" you feel. Our bass body layer at ~70Hz serves this role.
- **Mid (200-2000Hz)**: The identifying "crack" — tells the brain what KIND of impact. Our bandpass noise at ~1400Hz.
- **High (2000Hz+)**: The "sparkle" or "sizzle" — adds perceived loudness and sharpness. Our 2500Hz sine ping.

This is exactly what `playLayeredHit()` implements. The architecture is correct.

**2. Temporal Envelope**
- **Attack must be instantaneous** (< 5ms). Slow attacks feel mushy. All our impacts use `setValueAtTime` for instant onset — correct.
- **Decay shape matters**: Exponential decay (our approach) sounds natural. Linear decay sounds artificial.
- **Total duration 30-150ms**: Shorter = snappier, longer = heavier. Our bass layer at 80ms is in the sweet spot for beat 'em up hits.

**3. Variation (Anti-Machine-Gun Effect)**
Hearing the same hit sound twice in a row breaks immersion. Professional games use 5-10 recorded variations per impact type. We achieve this procedurally via:
- `randomPitch()` with ±20% variance on every play
- Random intensity selection (light/medium/heavy) in `playHit()`
- Per-frame pitch spread (`_pitchSpread()`) for simultaneous sounds
- Combo-based intensity scaling (AAA-A4)

### Combat Sound Design Principles

| Principle | Implementation | Our Status |
|-----------|---------------|------------|
| Bass for weight | Sub-60Hz sine layer | ✅ Implemented |
| Transient for sharpness | Noise burst < 40ms | ✅ Implemented |
| Pitch variation | ±20% per play | ✅ Implemented |
| Combo escalation | Volume + layers increase | ✅ Implemented (AAA-A4) |
| Hit confirmation | Distinct sound per attack type | ✅ punch ≠ kick ≠ hit |
| Reverb tail for "bigness" | Delay feedback on massive hits | ✅ Implemented |
| Screen-relative panning | StereoPannerNode | ✅ Implemented |
| Enemy death emphasis | KO sound is distinct, longer | ✅ 300→50Hz, 0.3s |
| Vocal reinforcement | Grunt/oof on attack/damage | ✅ Implemented |

### What We Could Improve

- **Pre-impact anticipation**: A very subtle rising noise just before a heavy hit lands (1-2 frames) increases perceived power
- **Post-impact silence**: Ducking all other audio for 30-50ms after a big hit creates dramatic emphasis
- **Low-frequency rumble**: Sub-bass sine at 20-30Hz for screen-shake-equivalent audio weight (many speakers can't reproduce this, but it adds "presence" on capable hardware)
- **Impact sweeteners**: Very short (5-10ms) filtered noise transients layered on top of the tonal body

---

## 5. Mix Engineering — Balancing SFX / Music / Ambient

### Our Current Bus Architecture

```
sfxBus (0.7) ────┐
musicBus (0.5) ───┤
uiBus (1.0) ──────┼── masterBus (1.0) ── destination
ambienceBus (0.08)┘
```

### What We Got Right

- **Bus separation**: 5 independent buses allow per-category volume control. This is professional-grade architecture.
- **Music below SFX**: Music at 0.5 × individual note volumes (0.05-0.14) = effective 0.025-0.07. SFX at 0.7 × individual volumes (0.15-0.35) = effective 0.1-0.25. SFX are 2-4× louder than music — correct priority for action games.
- **Ambience barely audible**: 0.08 bus gain ensures environmental sounds are subliminal, not distracting.
- **UI at unity**: Menu sounds need instant, clear feedback at full volume.

### Mix Engineering Best Practices We Should Adopt

**1. DynamicsCompressorNode on masterBus**
```javascript
const compressor = context.createDynamicsCompressor();
compressor.threshold.value = -12;  // Start compressing at -12dB
compressor.ratio.value = 4;        // 4:1 compression ratio
compressor.attack.value = 0.003;   // Fast attack for transients
compressor.release.value = 0.1;    // Quick release
// Insert between masterBus and destination
```
This prevents clipping during intense combat when many sounds fire simultaneously.

**2. Frequency separation between layers**
Our current approach works well:
- Ambience: 30-300Hz (traffic rumble, wind)
- Music bass: 130-260Hz (bass notes)
- SFX impacts: 40-2500Hz (full range but dominant in mid)
- Music melody: 390-530Hz (square wave)
- UI: 520-1200Hz (triangle wave)
- Vocals: 300-2400Hz (formant range)

Potential conflict zone: **130-260Hz** where music bass and SFX kick/landing overlap. The kick's lowpass filter at 500Hz and music's low volume prevent this from being a real problem, but a sidechain compression pattern (duck music when SFX plays) would be the professional solution.

**3. Headroom management**
Current peak scenario: 3× simultaneous hits + music at intensity 2 + ambience. With MAX_SAME_TYPE=3 and priority gating, we're managing peak polyphony — but we have no limiter. Adding a DynamicsCompressorNode is a zero-cost safety net.

### Loudness Hierarchy (Correct Priority)

1. **Player attack SFX** (punch, kick) — Loudest. Immediate gameplay feedback.
2. **Hit confirmation** — Must be clearly audible over music.
3. **UI sounds** — Full volume but short duration, non-competing.
4. **Wave fanfares** — Brief, attention-grabbing, sits above music.
5. **Vocals/barks** — Adds flavor, shouldn't dominate.
6. **Music** — Background groove, never competes with SFX.
7. **Ambience** — Subliminal atmosphere.

---

## 6. Limitations of Pure Synthesis vs. Real Samples

### What We CAN'T Do

| Limitation | Why | Impact |
|------------|-----|--------|
| **Realistic speech** | Formant synthesis approximates vowels but not consonants, words, or recognizable character voices | Voice barks are abstract "vocal sounds" — players won't hear "Ugh!" as speech |
| **Instrument realism** | Oscillators produce static harmonic spectra; real instruments have time-varying harmonic content, resonance, and physical modeling nuances | Music sounds intentionally retro/chiptune rather than "real" |
| **Room/hall reverb** | ConvolverNode requires an impulse response file (audio sample). Our delay-feedback is a comb filter, not true reverb | Sounds feel "dry" and disconnected from any physical space |
| **Timbral richness** | Even with 3-layer hits, the component waveforms are mathematically perfect — lacking the noise floor, harmonic drift, and microvariation of recorded samples | Sounds are "clean" in a way that reads as synthetic |
| **One-shot complexity** | A recorded sword clash or glass break has thousands of micro-events in sub-100ms. We'd need dozens of simultaneous oscillators to approximate this | Our impacts are "suggestive" rather than "realistic" |
| **Dynamic range of vocals** | Real voice acting provides pitch contour, emotion, timing variation, character personality that synthesis can't achieve | Character barks work as abstract audio cues, not as performances |

### What Pure Synthesis DOES Well

- **Zero loading time**: No audio files to fetch. Instant play on first interaction.
- **Infinite variation**: Every play call is unique due to randomization. No "heard the same sample 500 times" fatigue.
- **Tiny bundle size**: Zero bytes of audio assets. Critical for web games.
- **Dynamic parameters**: Can adjust any sound property in real-time (combo scaling, intensity, spatial position).
- **No licensing concerns**: Generated audio has no copyright issues.
- **Consistent across platforms**: No codec compatibility issues.

### The Honest Assessment

For a **retro-styled browser beat 'em up**, pure synthesis is a **legitimate creative choice**, not just a limitation. Streets of Rage on Genesis used FM synthesis throughout. Our 21 procedural sounds + adaptive music system would be impressive on 16-bit hardware. The question is whether we're making a stylistic choice or hitting a ceiling — and with our current feature set, it's genuinely both. The system works. It could be richer with hybrid synthesis + samples, but it functions as-is.

---

## 7. Future: Audio Middleware for Web

### Tone.js
- **What**: High-level Web Audio API wrapper with synthesizers, effects, transport/scheduling
- **Strengths**: Built-in synth types (FMSynth, AMSynth, MonoSynth), effect chains (reverb, chorus, delay, distortion), musical timing (Transport, Tone.Time), pattern generators
- **Our use case**: Could replace our manual oscillator/envelope code with `new Tone.Synth().triggerAttackRelease("C4", "8n")`. Would dramatically simplify the music system.
- **Trade-off**: ~70KB minified. Adds a dependency. But eliminates hundreds of lines of boilerplate.

### Howler.js
- **What**: Audio library focused on sample playback, not synthesis
- **Strengths**: Cross-browser audio sprite support, spatial audio, pooling, format fallback (WebAudio → HTML5 Audio), mobile handling
- **Our use case**: If we ever add recorded samples (voiceover, sampled instruments, recorded SFX), Howler.js handles loading, decoding, pooling, and playback better than raw Web Audio API
- **Trade-off**: ~10KB minified. Doesn't help with synthesis — it's complementary to our approach, not a replacement.

### Pizzicato.js
- **What**: Simplified Web Audio API with built-in effects
- **Strengths**: Easy reverb, delay, distortion, flanger, compressor via simple API
- **Our use case**: Could add effects processing (convolution reverb, compression) without manual node graph management
- **Trade-off**: Less maintained than Tone.js. Smaller community.

### FMOD / Wwise — No Web Equivalent
- FMOD and Wwise are native audio middleware for Unity/Unreal. No web ports exist.
- The closest web equivalent is **Tone.js** for synthesis or a custom engine on raw Web Audio API (which is what we built).
- For AAA-level adaptive music on the web, you'd build on Tone.js's Transport system or roll your own scheduler (as we did with Music's `setInterval` scheduler).

### Recommended Upgrade Path

1. **Immediate (no dependencies)**: Add `DynamicsCompressorNode` to masterBus — free safety net
2. **Short-term**: Pre-compute common noise buffers in constructor (kick, grunt, exertion) instead of per-call generation
3. **Medium-term**: If music becomes more complex, consider Tone.js for the music system only (keep SFX procedural)
4. **Long-term**: If we add character voice acting or sampled instruments, integrate Howler.js for sample management alongside our existing synthesis engine

---

## 8. firstPunch-Specific Learnings

### 21 Procedural Sounds — Assessment

| Sound | Method | Technique | Rating | Notes |
|-------|--------|-----------|--------|-------|
| Punch | `playPunch()` | Square wave, 150Hz, 0.05s | ⭐⭐⭐ | Snappy, good pitch variation. Could use noise transient layer. |
| Hit (layered) | `playLayeredHit()` | 3-band synthesis | ⭐⭐⭐⭐⭐ | Best sound in the system. True multi-layer design. |
| Hit Light | `playHitLight()` | Layered at 0.4 intensity | ⭐⭐⭐⭐ | Effective contrast with heavy hits. |
| Hit Heavy | `playHitHeavy()` | Layered at 1.0 + sparkle | ⭐⭐⭐⭐ | Satisfying with high combo. |
| Heavy Combo | `_playHeavyComboHit()` | Full layers + sub-bass (45→25Hz) | ⭐⭐⭐⭐⭐ | Extra sub-bass sells the power. |
| Massive Combo | `_playMassiveComboHit()` | Heavy + delay feedback reverb | ⭐⭐⭐⭐ | Reverb tail is a great touch. Delay time could be randomized slightly. |
| Kick | `playKick()` | Sine drop + lowpass noise | ⭐⭐⭐⭐ | Two-layer design is solid. Heavier than punch as intended. |
| Jump | `playJump()` | Ascending sine sweep, 200→400Hz | ⭐⭐⭐ | Functional but simple. Could add a short noise pop at onset. |
| KO | `playKO()` | Descending sine, 300→50Hz, 0.3s | ⭐⭐⭐⭐ | Long decay communicates finality. |
| Wave Start | `playWaveStart()` | 3 descending square notes | ⭐⭐⭐⭐ | Effective danger cue. |
| Wave Clear | `playWaveClear()` | 3 ascending sine notes | ⭐⭐⭐⭐ | Clear victory feel. |
| Level Complete | `playLevelComplete()` | 4-note ascending arpeggio | ⭐⭐⭐⭐⭐ | Sustained final note is satisfying. |
| Grunt | `playGrunt()` | Bandpass noise, 800Hz, 50ms | ⭐⭐⭐ | Short and punchy but fairly generic. |
| Exertion | `playExertion()` | Bandpass sweep 600→350Hz, 120ms | ⭐⭐⭐⭐ | Frequency descent sells effort. |
| Oof | `playOof()` | Bandpass sweep 1000→400Hz, 150ms | ⭐⭐⭐⭐ | Clear damage indicator. |
| Landing | `playLanding()` | Low sine thud, 55→30Hz, 60ms | ⭐⭐⭐ | Very subtle — might be inaudible on laptop speakers. |
| Ugh | `playGrunt()` | Dual-layer: sine base + formant descent | ⭐⭐⭐⭐ | Best vocal. Descending formant reads as dismay. |
| Woohoo | `playCheer()` | Ascending formant + LFO tremolo | ⭐⭐⭐⭐⭐ | Tremolo is inspired — excitement vibrato works. |
| Satisfied Hum | `playHum()` | Sustained hum + pitch wobble + nasal formant | ⭐⭐⭐⭐ | Wobble LFO is great. Nasal layer adds character. |
| Radical | `playExclaim()` | Ascending noise burst + sawtooth overlay | ⭐⭐⭐⭐ | Two-part design (noise + sawtooth) gives it energy. |
| Menu Select | `playMenuSelect()` | Triangle blip, 1200Hz, 40ms | ⭐⭐⭐⭐ | Clean, non-fatiguing. |
| Menu Confirm | `playMenuConfirm()` | Two ascending triangle notes | ⭐⭐⭐⭐ | Satisfying confirmation feel. |

**Top 5**: playLayeredHit, _playHeavyComboHit, playCheer, playLevelComplete, playGrunt
**Needs improvement**: playJump (too simple), playLanding (too quiet for laptop speakers), playGrunt (generic), playPunch (single-layer vs multi-layer hits)

### Mix Bus Architecture — Lessons Learned

1. **Build the bus topology first**: Having sfxBus/musicBus/uiBus/ambienceBus from the start meant every new sound just needed to connect to the right bus. Zero refactoring needed when adding categories.
2. **Default volume ratios matter**: SFX 0.7, Music 0.5, Ambience 0.08 established the loudness hierarchy immediately. We never had to re-balance after initial setup.
3. **The masterBus unity gain pattern**: Master at 1.0 means all bus volumes are absolute, not relative. Changing master scales everything proportionally. This is the correct architecture.
4. **Missing piece — compression**: No DynamicsCompressorNode on the master bus. During peak combat (3 simultaneous hits + music + ambience), we rely on the gain values staying under 1.0 total. A compressor would be a safety net.

### AudioContext User Gesture Issue — Definitive Solution

**The problem**: Browsers (Chrome, Safari, Firefox) suspend `AudioContext` at creation until a user gesture (click, keydown, touch). Any `start()` calls on suspended context are silently queued and may never play.

**Our solution** (audio.js + main.js):
1. `AudioContext` created in `Audio` constructor (starts suspended)
2. `resume()` method calls `this.context.resume()` once, sets `_resumed` flag
3. In main.js: one-time `keydown` and `click` event listeners call `audio.resume()`
4. All `playX()` methods work transparently — if context is suspended, sounds are silently dropped (no errors), and they start working once resume fires

**Key insight**: Don't try to defer `AudioContext` creation until first gesture. Create it eagerly, resume it lazily. This keeps the constructor synchronous and the API clean. The `_resumed` flag prevents redundant resume calls.

**Day-1 checklist for new Web Audio projects**:
- Create AudioContext immediately in audio module constructor
- Add `resume()` method with one-time flag
- Wire resume to first user gesture in entry point (main.js)
- Never gate sound playback on resume status — just let suspended sounds drop silently

### Spatial Panning — What Worked

The `playAtPosition()` sfxBus-swap technique is elegant:
1. Creates a StereoPannerNode positioned based on screen X
2. Temporarily replaces `this.sfxBus` with the panner node
3. Calls any existing sound function — it connects to the panner without knowing
4. Restores the real sfxBus after the synchronous call

**Why it works**: Web Audio API node connections are made at call time, but audio processing happens later. The swap is synchronous and completes before any audio renders.

**Limitation**: Only works for sounds triggered synchronously. If a sound function used `setTimeout` to schedule a second part (none currently do), that part would connect to the restored sfxBus, not the panner. This is safe with our current API but would break with async sound chains.

**Effective pan range**: `(screenX / screenWidth) * 2 - 1` maps left edge to -1, right edge to +1. Center-screen entities are at pan=0. This feels natural — enemies on the left of the screen sound from the left speaker.

---

*This document captures the state of audio engineering knowledge for firstPunch as of the completion of our 21-sound procedural audio system with adaptive music, mix bus architecture, spatial panning, and environmental ambience.*
