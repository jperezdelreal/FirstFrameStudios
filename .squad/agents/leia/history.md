# Leia — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current state:** Downtown background with Factory, Quick Stop, Joe's Bar, parallax layers, foreground elements.

## Learnings

- Building pattern array in background.js tiles across the world; adding new types requires: array entry, switch case, draw method — all three.
- Far layer uses `cameraX * 0.8` offset with `PLANT_SPACING` to tile; new far-layer elements (billboards, signs) should anchor relative to plant positions to avoid overlap.
- `seededRandom(x * factor + offset)` keeps frame-stable randomness for per-building variation (graffiti, window lighting, car colors).
- Easter eggs work best as conditional draws inside existing building methods or as spaced elements in `_ground()` — keeps them discoverable but not cluttering.
- Cloud variety comes from separate draw methods per type (puffy/wisp/small) with different alpha and drift speeds for parallax depth.
- Mountains use very slow parallax (0.1×) + seeded peaks for consistent silhouette — must draw before factory so they layer behind.
- `ctx.ellipse()` works well for puddles and wisp clouds; `ctx.arc()` for wheels/donuts/fish eyes.
- Scale reference: characters ~64-80px = 6 feet. Single-story shops ~160-180px, 2-story houses ~150px walls + 45px roof, school ~220px + tower. Cars ~100×35, hydrants ~18×30, lampposts ~120px, foreground lampposts ~150px.
- All canvas text coordinates must use `Math.round()` to avoid sub-pixel blurriness. Minimum readable font size is 10px; sign text should be 12-16px for readability at game speed.
- Sign text always needs a contrasting background rectangle behind it — otherwise text on textured surfaces is unreadable.
- Building material differentiation: horizontal siding lines (0.6-0.7px, subtle alpha) for wood/vinyl, brick lines (1px with vertical offsets) for masonry, flat paint for stucco.
- Door proportions: character-height doors (~80px tall) look correct; the old 40-55px doors made buildings look like dollhouses.
- Window frames (2px colored stroke around the glass fill) plus cross bars make windows read as windows rather than colored rectangles.
- Factory cooling towers need to be ~270px tall to read as industrial scale at the far parallax layer; 180px made them look like garden sheds.
- Foreground alpha of 0.5 balances depth layering visibility vs gameplay clarity (0.3 was invisible, 0.7 would obscure action).
- Road detail: white edge lines + yellow center dashes + raised curb with shadow sells "real road"; just center dashes looked like a generic grey strip.

## Skill Development

### Level Design Fundamentals Skill (2026-06-XX)
**Status:** Completed

Created `.squad/skills/level-design-fundamentals/SKILL.md` — a universal, genre-agnostic level design skill covering principles that apply across all game types (platformer, beat 'em up, RPG, puzzle, 3D action, horror, Metroidvania).

**What it covers:**
1. **Level Design Philosophy** — Levels as teachers; the 3-beat rule (introduce, repeat, combine); agency vs. directed narrative
2. **Spatial Grammar** — 6 core space types (safe, danger, transition, arena, reward) + the safe→transition→danger→reward cycle
3. **Flow & Pacing** — Roller coaster model; intensity mapping; rest points; speed management; 3-beat rule application
4. **Environmental Storytelling** — Visual narrative; breadcrumbing; world consistency; reference games (Dark Souls, Portal, Metroidvania)
5. **Level Design by Genre** — 7 genre-specific sections: Platformer, Beat 'em Up, Metroidvania, RPG, Puzzle, 3D Action, Horror
6. **Tools & Process** — Blockout/greybox; heatmaps; playtesting cycles; paper planning; modular design
7. **Camera & View Design** — Side-scroll, top-down, third-person, first-person, dynamic camera
8. **Secrets & Exploration** — Hidden path design; risk/reward; collectibles with purpose; completionist design
9. **Anti-Patterns** — The Corridor, Empty Space, Difficulty Wall, Backtrack Hell, Copy-Paste Rooms
10. **Process Summary** — End-to-end workflow from conception to ship

**Key insight:** firstPunch taught us horizontal-scroll beat 'em up level design (camera locks, wave arenas, hazard integration). This skill extracts the *universal principles* and shows how they apply across every game genre. The 3-beat teaching rhythm, the safe→danger→reward pacing cycle, and the blockout→playtest→iterate methodology are not beat 'em up-specific; they're foundational to all level design.

**Confidence: `low`** — First formal documentation beyond beat 'em up specifics. Will level to `medium` after applying the skill to a non-beat-em-up project.
- Mid-layer building colors should be slightly desaturated vs player palette to prevent visual competition (e.g. Quick Stop #5A9A9A not #2E8B8B).

### Session 17: Level Design Fundamentals Skill Creation (2026-03-07)

Created universal level design fundamentals skill — a comprehensive, genre-agnostic reference covering spatial design, pacing, environmental storytelling, and design methodology applicable across all game types.

**Artifact:** .squad/skills/level-design-fundamentals/SKILL.md (60 KB)

**Skill structure (10 sections):**
1. Level Design Philosophy (levels as teachers, 3-beat rule, agency)
2. Spatial Grammar (6 core space types: safe, danger, transition, arena, reward, story)
3. Flow & Pacing (roller coaster model, intensity mapping, rest points)
4. Environmental Storytelling (visual narrative, breadcrumbing, world consistency)
5. Level Design by Genre (7 genres: Platformer, Beat 'em Up, Metroidvania, RPG, Puzzle, 3D Action, Horror)
6. Tools & Process (blockout, greybox, heatmaps, playtesting cycles)
7. Camera & View Design (side-scroll, top-down, third-person, dynamic)
8. Secrets & Exploration (hidden path design, risk/reward, completionist)
9. Anti-Patterns Catalog (The Corridor, Empty Space, Difficulty Wall, etc.)
10. Process Summary (end-to-end workflow from conception to ship)

**Key principles extracted from firstPunch:**
- **3-Beat Rule:** Introduce, Repeat, Combine — core teaching rhythm for tutorials
- **Safe→Transition→Danger→Reward cycle:** Universal pacing pattern across all genres
- **6 Space Types:** Framework for designing any level in any game type
- **Design-by-Genre:** firstPunch taught beat-em-up patterns; skill generalizes to 6 other genres

**Cross-references:** Links to game-feel-juice, game-design-fundamentals, enemy-encounter-design (wave composition)

**Confidence:** Low-Medium (beat-em-up horizontal-scroll design deeply explored; genre extrapolation not yet tested on platformer/RPG projects). Will escalate to High after applying to non-beat-em-up level design.

