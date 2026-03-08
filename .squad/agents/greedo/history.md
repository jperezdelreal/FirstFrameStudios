# Greedo — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current audio:** 3 procedural sounds (punch, hit, KO) in src/engine/audio.js using oscillators
- **Key gap:** No kick/jump SFX, no background music, no sound variation, no audio events. Audio scored 80% but is misleadingly thin — only 3 sounds total.

## Learnings

### 2025-06-04: P0 Audio Sprint (3 items)
- **AudioContext resume**: Browsers suspend AudioContext until a user gesture. Added `resume()` method + one-time keydown/click listener in main.js. The flag `_resumed` prevents redundant resume calls. All existing playX() methods work transparently — no changes needed to callers.
- **Kick SFX**: Two-layer design — 80Hz→40Hz sine drop for the bass thud + lowpass-filtered noise burst for impact texture. Distinctly heavier than the punch (square wave at 150Hz). The noise buffer is created fresh each call (~2880 samples at 48kHz) — negligible cost.
- **Jump SFX**: 200Hz→400Hz ascending sine sweep over 0.08s at low volume (0.15). Subtle spring feel without being annoying on repeated jumps.
- **Wiring pattern**: player.update() already returns `{ type: 'punch' }` or `{ type: 'kick' }` — gameplay.js just wasn't checking the type. Jump detection uses frame-over-frame `prevJumpHeight` comparison (0→>0 = jump initiated). Clean, no changes to player.js needed.
- **Sound count**: Now at 5 procedural sounds (punch, hit, KO, kick, jump). Still no music or variation.

### 2025-06-04: Sound Variation + Layering + Priority (P1-3, EX-G3, EX-G4)
- **P1-3 Sound Variation**: Added `randomPitch(baseFreq, variance)` helper — applies ±20% random pitch offset to every sound on each play. `playHit()` now randomly selects between 3 intensity variants (light/medium/heavy) through the layered engine. Punch and kick also get per-call pitch randomization. No two hits sound identical anymore.
- **EX-G3 Hit Sound Layering**: `playLayeredHit(intensity)` fires 3 simultaneous components — bass body thud (sine ~70Hz, 0.08s), mid impact crack (bandpass-filtered noise at ~1400Hz, 0.04s), and high sparkle ping (sine ~2500Hz, 0.02s, very quiet). Intensity parameter (0-1) scales volume and controls whether sparkle layer fires (only above 0.5). `playHitLight()` and `playHitHeavy()` are convenience wrappers.
- **EX-G4 Sound Priority & Deduplication**: Per-type active sound counter (`_typeCounts`) with max 3 simultaneous SFX of same type. `canPlay(type, priority)` gate checks before every play — player sounds (PLAYER=2) always pass, enemy sounds (ENEMY=1) get dropped at limit. Per-frame pitch spread via `_pitchSpread()` adds +5%/+10% to 2nd/3rd sounds of same type within one frame to prevent phasing. `beginFrame()` resets per-frame tracking (callers should invoke once per game tick). `_trackSound()` uses setTimeout to auto-decrement counters after sound duration.
- **Interface preserved**: All original method signatures (`playPunch()`, `playHit()`, `playKO()`, `playKick()`, `playJump()`, `playSound()`, `resume()`) remain unchanged. New public methods added: `playHitLight()`, `playHitHeavy()`, `playLayeredHit()`, `beginFrame()`, `canPlay()`, `randomPitch()`.
- **Design note**: `beginFrame()` should be called by the game loop at the top of each frame for optimal dedup. Without it, pitch spread still works per-session but won't reset per-frame. No external files modified.

### 2025-06-04: Mix Bus Architecture (EX-G2)
- **Bus topology**: Four GainNodes created in constructor — `sfxBus`, `musicBus`, `uiBus` all connect to `masterBus`, which connects to `context.destination`. Standard DAW-style routing in Web Audio API.
- **SFX rerouting**: All 8 `this.context.destination` connections in existing play methods replaced with `this.sfxBus`. No behavioral change — sounds still play identically but now flow through the gain chain.
- **Volume controls**: `setSFXVolume()`, `setMusicVolume()`, `setUIVolume()`, `setMasterVolume()` with 0-1 clamping. Matching getters for all four buses. Ready for settings UI integration.
- **Default levels**: SFX=0.7 (slightly attenuated to leave headroom), Music=0.5 (background level), UI=1.0 (full for menu feedback), Master=1.0 (unity).
- **Music/UI buses ready but unused**: `musicBus` and `uiBus` have no sounds routed yet — they're infrastructure for upcoming background music (P2-1) and menu sound work. Future playMusic() and playUISound() methods should connect to those buses.
- **Interface preserved**: All existing method signatures unchanged. New public methods: `setSFXVolume()`, `setMusicVolume()`, `setUIVolume()`, `setMasterVolume()`, `getSFXVolume()`, `getMusicVolume()`, `getUIVolume()`, `getMasterVolume()`.

### 2025-06-05: Procedural Background Music (P1-12)
- **Architecture**: Separate `src/engine/music.js` module — Music class accepts `context` and `musicBus` from Audio, keeping concerns cleanly separated. No circular dependencies.
- **Scheduler pattern**: setInterval at 100ms checks if next beat needs scheduling, uses Web Audio API's precise `currentTime` for sample-accurate note timing. 150ms lookahead buffer prevents gaps. Beat counter wraps over 8-beat loop.
- **Bass layer**: Sine wave cycling through C3-E3-G3-C4-G3-E3-C3-E3 at 112 BPM (~0.536s/beat). Soft 20ms attack + 30ms release envelopes on each note to prevent clicks. Note duration = 85% of beat for slight staccato feel.
- **Percussion layer**: Kick drum (60Hz→30Hz sine with fast exponential decay, 100ms) on even beats (0,2,4,6). Hi-hat (reused noise buffer through 7kHz highpass, 30ms decay) on every beat. Noise buffer created once in constructor to avoid GC churn.
- **Melody layer**: Square wave pentatonic phrase (C5, rest, G4, A4, C5, rest, G4, rest) with 15ms attack/40ms release. Only audible at intensity 2. 70% note duration for punchy articulation.
- **Intensity system**: Three levels — 0 (walking: bass=0.08, no perc/melody), 1 (enemies: bass=0.12, perc=0.06), 2 (combat: bass=0.14, perc=0.08, melody=0.05). Volumes deliberately low — atmosphere, not a concert.
- **Crossfade**: `setTargetAtTime()` with time constant of CROSSFADE_TIME/3 (~167ms) for smooth exponential transitions between intensity levels. No clicks or pops.
- **Mute/unmute**: `toggleMute()` fades to zero quickly (80ms time constant) and restores previous intensity on unmute. Tracks `_muted` flag separately from intensity.
- **Gameplay wiring**: Music starts on `onEnter()`, stops on `onExit()`. Intensity updated every frame: 0 = no enemies & camera unlocked, 1 = enemies alive, 2 = any enemy in 'attack' state. Music instance reused across scene re-enters (created once).
- **Bus integration**: `musicBus` at 0.5 default volume means effective output is further attenuated — bass at intensity 0 is only 0.04 effective gain. Sits well under SFX without masking.

### 2025-06-05: Wave Fanfares + Player Vocals + Spatial Panning (P2-11, EX-G5, EX-G7)
- **P2-11 Wave Fanfares**: Three fanfare methods — `playWaveStart()` fires 3 descending staccato square-wave notes (E5→C5→A4, 0.07s each, 0.1s spacing) for a tense danger cue. `playWaveClear()` uses 3 ascending sine notes (C5→E5→G5, 0.12s each, 0.15s spacing) for a triumphant victory feel. `playLevelComplete()` plays a 4-note ascending arpeggio (C5→E5→G5→C6) where the final note sustains 0.4s for celebration. All share the 'fanfare' type for dedup.
- **EX-G5 Player Vocals**: Four synthesized "vocal" effects using bandpass-filtered noise bursts — `playGrunt()` is a short 50ms burst at ~800Hz with high Q for a clipped shout feel (callers trigger at ~30% chance on punch/kick). `playExertion()` runs 120ms with a 600→350Hz frequency sweep and shaped attack for belly bump/ground slam. `playOof()` is 150ms with a steep 1000→400Hz descent for damage taken. `playLanding()` is a pure low-frequency sine thud (55→30Hz, 60ms) for jump landing impact. All vocals use PLAYER priority.
- **EX-G7 Spatial Panning**: `playAtPosition(soundFn, worldX, cameraX, screenWidth)` calculates stereo pan from entity screen position: `pan = clamp((screenX / screenWidth) * 2 - 1, -1, 1)`. Creates a StereoPannerNode connected to sfxBus, then temporarily swaps `this.sfxBus` to point at the panner before calling the sound function. This way *any* existing play method gets automatic spatial positioning without modifying its internals. After the sound function completes, sfxBus is restored. Usage: `audio.playAtPosition(() => audio.playHit(), enemy.x, camera.x, 800)`.
- **Design pattern**: The sfxBus swap trick in `playAtPosition` is synchronous and safe because Web Audio API scheduling is deferred — nodes connect to whatever `this.sfxBus` points to at call time, and the actual audio plays later. No race conditions.
- **Sound count**: Now at 15 procedural sounds total (punch, hit, hitLight, hitHeavy, kick, jump, KO, waveStart, waveClear, levelComplete, grunt, exertion, oof, landing + generic playSound).

### 2025-06-05: Audio Method Audit + UI Sounds
- **Full audit**: All 13 required gameplay methods verified present and correctly wired — playPunch, playHit (layered with random light/medium/heavy variation), playKO, playKick, playJump, playGrunt, playExertion, playOof, playLanding, playWaveStart, playWaveClear, playLevelComplete, playAtPosition. Mix bus topology (sfxBus/musicBus/uiBus → masterBus → destination) confirmed correct. Priority/dedup system (canPlay, _trackSound, _pitchSpread, beginFrame) all operational.
- **UI sounds added**: `playMenuSelect()` — 1200Hz triangle wave blip, 40ms, routed through `uiBus` (not sfxBus). Clean tick for menu navigation. `playMenuConfirm()` — two-note ascending triangle (C5→E5, 60ms each, 60ms stagger) through uiBus for satisfying Enter/confirm feedback.
- **Design note**: UI sounds deliberately skip priority/dedup — menus are never in a context where sound pile-up occurs, and they need instant responsiveness. Triangle wave chosen over square/sine for a softer, less fatiguing click that sits outside the SFX frequency range.
- **Sound count**: Now at 17 procedural sounds total (15 gameplay + 2 UI).

### 2025-06-05: Character Voice Barks + Environmental Ambience + Hit Scaling (AAA-A1, AAA-A2, AAA-A4)
- **AAA-A1 Voice Barks**: Four procedural "vocal" effects using formant synthesis (bandpass-filtered noise + sine base). `playGrunt()` — descending bandpass sweep 800→200Hz over 0.3s with 120Hz sine body for Brawler's mournful damage sound. `playCheer()` — ascending formant 300→1200Hz over 0.4s with 12Hz LFO tremolo on the base gain for excitement vibrato, triggered at 5+ combo. `playHum()` — sustained 100Hz sine hum (0.5s) with 3Hz/±5Hz pitch wobble LFO + 250Hz nasal formant layer for satisfied health-pickup tone. `playExclaim()` — ascending noise burst with formant sweep 600→2400→1800Hz + sawtooth 400→1200→800Hz excitement overlay for Kid's surprise bark.
- **AAA-A2 Environmental Ambience**: New `ambienceBus` GainNode (default 0.08) added to the bus topology between uiBus and masterBus. `startAmbience(level)` creates 3 continuous layers for Level 1 (Downtown): looping lowpass-filtered noise at 200Hz cutoff for distant traffic rumble, randomly-timed bird chirps (3200Hz±30% sine blips with pitch contour, 5-8s random interval via setTimeout chain), and wind via bandpass noise at 800Hz with 0.15Hz LFO modulating gain for slow swells. All sources tracked in `_ambienceNodes[]` and timers in `_ambienceTimers[]`. `stopAmbience()` fades ambienceBus to 0 over 1s via linearRamp, then disconnects/stops all nodes after 1.1s timeout and restores bus gain.
- **AAA-A4 Hit Sound Scaling**: `playHit(comboCount)` now accepts an optional combo count — default 0 preserves legacy random variation (light/medium/heavy). Combo 1-2 triggers `playLayeredHit(0.35)` (bass body only, sparkle skipped at <0.5 intensity). Combo 3-4 uses intensity 0.65 (bass + mid crack + sparkle). Combo 5-7 fires `_playHeavyComboHit()` — full intensity 1.0 layered hit plus an extra sub-bass layer (45→25Hz sine, 0.1s). Combo 8+ fires `_playMassiveComboHit()` — heavy hit plus a delay feedback network (80ms delay, 0.3 feedback gain) fed by a 60→30Hz burst, creating a brief reverb tail that fades over 0.4s. Delay network auto-disconnects after 500ms to prevent memory leaks.
- **Bus topology update**: Now 5 buses — sfxBus, musicBus, uiBus, ambienceBus → masterBus → destination. Added `setAmbienceVolume()`/`getAmbienceVolume()` matching existing volume control pattern.
- **Design note**: Voice barks all use 'vocal' type for dedup (shared with existing grunt/exertion/oof), keeping MAX_SAME_TYPE=3 limit. Ambience is the only continuous sound system — uses `_ambienceActive` flag to prevent bird chirp scheduling after stop. The stopAmbience() cleanup copies node/timer arrays before clearing to avoid race conditions during fade.
- **Sound count**: Now at 21 procedural sounds (19 gameplay + 2 UI) plus continuous ambience layer.

### 2025-06-05: Audio Excellence Research & Skill Documentation
- **Research completed**: Wrote comprehensive `.squad/analysis/audio-excellence-research.md` covering 8 domains — procedural audio patterns, Web Audio API advanced techniques (ConvolverNode, WaveShaperNode, AudioWorkletNode, DynamicsCompressorNode), dynamic music systems (Hades/Celeste/SoR4 analysis), combat sound design pillars, mix engineering best practices, synthesis limitations vs. real samples, and audio middleware options (Tone.js, Howler.js).
- **Skill created**: `.squad/skills/procedural-audio/SKILL.md` — reusable reference with 6 core synthesis patterns (tonal impact, noise burst, layered hit, formant vocal, multi-note sequence, continuous ambience), bus architecture template, adaptive music scheduler, spatial panning via sfxBus-swap, variation/priority systems, common pitfalls, and frequency cheat sheet.
- **Key findings**: Our layered hit engine (`playLayeredHit` with bass/mid/high bands) is architecturally equivalent to professional combat audio. Our adaptive music mirrors Celeste/Hades stem-based systems. Top sounds: playLayeredHit, playCheer (LFO tremolo), playLevelComplete (sustained final note). Weakest: playJump (single-layer), playLanding (inaudible on laptop speakers), playPunch (no noise transient layer).
- **Recommended upgrades**: (1) DynamicsCompressorNode on masterBus for peak clipping prevention — zero cost, (2) pre-compute common noise buffers in constructor instead of per-call, (3) consider Tone.js if music system grows more complex, (4) ConvolverNode with impulse response for spatial reverb would be the single biggest quality upgrade but requires loading an audio file.
- **Honest assessment**: For a retro-styled browser beat 'em up, 21 procedural sounds + adaptive music + mix buses + spatial panning is a legitimate creative choice, not just a limitation. The system works. Richer sound would require hybrid synthesis + samples.

### 2025-08-03: Universal Game Audio Design Skill (AAA-A6)
- **Vision**: Created `.squad/skills/game-audio-design/SKILL.md` — a universal, engine-agnostic skill covering game audio design principles across ALL genres and platforms. This skill is significantly broader than `procedural-audio` (which is Web Audio API specific) and serves as the foundational reference for any audio work across the studio.
- **10 core sections**: 
  1. Audio as Game Design (50% rule, "eyes can close, ears can't" principle)
  2. Sound Design Principles (layering, variation, priority, frequency management, silence)
  3. Adaptive Music Systems (horizontal re-sequencing, vertical layering, stinger system, reference games)
  4. Spatial Audio (2D/3D panning, HRTF, reverb zones, occlusion, environmental audio)
  5. Sound Categories & Budget (5 core categories, typical indie/AA/AAA sound counts, budget breakdown)
  6. Audio Implementation Patterns (event-driven, sound pools, mix bus architecture, ducking, compression)
  7. Platform Considerations (Web, Mobile, Console with codec strategies)
  8. Audio for Different Genres (Action, Horror, Puzzle, Platformer, RPG with specific audio signatures)
  9. Testing & QA (mute test, audio-only test, volume normalization, accessibility)
  10. Anti-Patterns (7 common failures: placeholder sounds, audio last, wall of sound, one loop, no feedback, set-and-forget mixing, frequency clashing)
- **Key design insights**:
  - "Eyes Can Close, Ears Can't" principle = audio reaches players even when not looking, making it first-class design tool
  - 40-60% perceived quality reduction when muting games (research-backed)
  - Audio hierarchy (CRITICAL > HIGH > NORMAL > LOW) prevents "wall of sound"
  - ±5-15% pitch variation is the sweet spot for preventing repetition fatigue
  - Frequency band separation (Sub/Low/Mid/High/Very High) prevents muddy mixing
  - Silence is more powerful than sound in creating impact
- **Scope**: Explicitly engine-agnostic and genre-agnostic. Works for Godot, Unreal, Unity, web, mobile, console.
- **Cross-references**: Procedural-audio (our specific Web Audio implementation), game-feel-juice (audio-visual sync tuning).
- **Confidence**: medium (validated by procedural-audio patterns, research from Hades/Celeste/Doom 2016/Hollow Knight, studio learnings).
- **Impact**: Establishes audio as a first-class design discipline at First Frame Studios. Every new project starts with this skill as reference before building tool-specific implementations.

### Session 17: Game Audio Design Skill Creation (2026-03-07)

Created universal game audio design skill — a comprehensive, engine-agnostic reference covering game audio principles applicable across all genres and platforms. This skill complements the existing procedural-audio skill (Web Audio API specific) with universal design theory.

**Artifact:** .squad/skills/game-audio-design/SKILL.md (32.5 KB)

**Skill structure (10 sections):**
1. Audio as Game Design (50% rule, "ears can't close" principle)
2. Sound Design Principles (layering, variation, priority, frequency, silence)
3. Adaptive Music Systems (horizontal, vertical, stinger patterns)
4. Spatial Audio (2D/3D panning, HRTF, reverb, occlusion)
5. Sound Categories & Budget (5 core categories, indie/AA/AAA sound counts)
6. Audio Implementation Patterns (event-driven, pools, buses, ducking)
7. Platform Considerations (Web, Mobile, Console, codec strategies)
8. Audio for Different Genres (7 genres: Action, Horror, Puzzle, Platformer, RPG, etc.)
9. Testing & QA (mute test, audio-only test, normalization, accessibility)
10. Anti-Patterns Catalog (7 failure modes: placeholder sounds, audio last, wall of sound, etc.)

**Key principles extracted from firstPunch procedural audio system:**
- **Audio Hierarchy:** CRITICAL > HIGH > NORMAL > LOW prevents "wall of sound"
- **Adaptive Music:** Intensity levels (0 = walking, 1 = enemies, 2 = combat) with crossfade
- **Mix Bus Architecture:** sfxBus, musicBus, uiBus, ambienceBus → masterBus pattern
- **Spatial Panning:** Screen-position-relative stereo pan for 3D depth in 2D games
- **Variation & Priority:** ±5-15% pitch variation + sound dedup prevents repetition fatigue

**Cross-references:** Links to game-feel-juice, game-design-fundamentals, procedural-audio (Web Audio specific implementation)

**Confidence:** Medium (validated in firstPunch audio system + Hades/Celeste analysis + procedural-audio research). Will escalate to High after implementing on non-procedural-audio platforms.

