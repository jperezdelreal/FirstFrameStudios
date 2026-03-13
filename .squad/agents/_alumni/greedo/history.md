# Greedo — History

## Core Context (Summarized)

**Role:** Audio engineer for firstPunch game; procedural synthesis specialist.

**Key Contributions:**
1. **17 Procedural Game Sounds** — Complete gameplay audio (punch, hit [layered], KO, kick, jump, grunt, exertion, oof, landing) wired to gameplay methods
   - Variation system (light/medium/heavy) + priority dedup (MAX_SAME_TYPE=3)
   - Adaptive combo scaling: Combo 5-7 uses heavy hit + sub-bass layer; Combo 8+ adds 80ms delay reverb feedback
2. **Mix Bus Architecture** — 5-bus topology (sfxBus, musicBus, uiBus, ambienceBus → masterBus → destination)
   - Volume controls, bus routing, spatial panning via sfxBus swap
3. **Audio Features:**
   - UI Sounds: Menu select (1200Hz triangle blip) + confirm (ascending C5→E5 two-note)
   - Environmental Ambience: 3-layer system (traffic rumble, bird chirps, wind swells) with fade in/out
   - Voice Barks: Formant synthesis (descending grunt, ascending cheer with LFO tremolo, hum, exclaim)
4. **Universal Game Audio Design Skill** — Created 32.5KB engine-agnostic reference covering game audio across all genres
   - 10 sections: audio as game design, sound principles, adaptive music, spatial audio, categories/budget, implementation, platform, genres, testing, anti-patterns

**Key Insight:** 21 procedural sounds + buses + spatial panning is a legitimate creative choice for retro beat 'em up, not just limitation.

**Archived Skills:** Procedural audio, Web Audio API, formant synthesis, mix architecture, game audio design, audio excellence research

---

*Archived history; sessions details from various dates summarized above.*
