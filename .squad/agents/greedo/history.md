# Greedo — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current audio:** 3 procedural sounds (punch, hit, KO) in src/engine/audio.js using oscillators
- **Key gap:** No kick/jump SFX, no background music, no sound variation, no audio events. Audio scored 80% but is misleadingly thin — only 3 sounds total.

## Learnings

### Historical Work (Sessions 1-5)

- 2025-06-04: P0 Audio Sprint (3 items)
- 2025-06-04: Sound Variation + Layering + Priority (P1-3, EX-G3, EX-G4)
- 2025-06-04: Mix Bus Architecture (EX-G2)
- 2025-06-05: Procedural Background Music (P1-12)
- 2025-06-05: Wave Fanfares + Player Vocals + Spatial Panning (P2-11, EX-G5, EX-G7)

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
