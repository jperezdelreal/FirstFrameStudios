# Nien — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current characters:** Brawler with bezier curves, M-hair, stubble, overbite. 4 enemy variants (normal/fast/heavy/tough) + Bruiser boss. All Canvas 2D procedural art.

## Learnings
- Added Brawler walk-cycle leg framing, expression-based face drawing, and enemy death spin/launch fades with X eyes.
- Upgraded Brawler's fists from plain circles to game-style 4-finger fists with palm, knuckle row, and thumb using ellipses.
- Added shoe soles (darker brown line at bottom) to both player and all enemy variants for grounding detail.
- Added belt with silver buckle at Brawler's shirt-pants transition for visual separation.
- Redesigned Brawler's ears from simple arcs to defined C-shaped ellipses with inner ear detail strokes.
- Enemy visual identity pass: normal gets purple baseball cap with brim, tough gets goatee, fast gets sneaker lace dots, heavy/boss get thick visible neck, boss gets open vest with lapels and white undershirt V-neck.
- All new shapes use smooth arcs, ellipses, and quadraticCurveTo for anti-aliased rendering. Existing round lineJoin/lineCap settings preserved.

---

## Ashfall Sprint 0 — Character Art (2026-03-09)

**Project:** Ashfall — 1v1 fighting game in Godot 4 (Sprite-based)  
**Role:** Character/Enemy Artist  
**Status:** Phase 2 Prep — Issue #9 In Progress  

**Context:** Ashfall started with placeholder character sprites (stick figures). Phase 2 will introduce polished character art. Nien assigned to create Kael and Rhena character sprites with proper animation states.

**Milestone Status Update (2026-03-09):**
M0-M3 have been completed and verified:
- M0 ✅ GDD + Architecture approved
- M1 ✅ Project buildable (scaffold + core systems)
- M2 ✅ Movement + attacks working (fighter controller, hitbox system, AI)
- M3 ✅ HUD integrated, game flow playable 1v1 (all criteria met)
- M4 🔲 Stable build & ship (ACTIVE, P0 blocker #88)

Issue #9 (character sprite placeholders) is Phase 2 prep work — NOT a M4 blocker. This work can proceed in parallel with M4 stabilization, enabling Phase 2 content pipeline once M4 ships.

**Asset Naming Convention (Active):**
All character assets follow: `{character}_{action}_{variant}.png` in `assets/sprites/{character}/`
- **Characters:** lowercase, no spaces (kael, rhena)
- **Actions:** lowercase, match state names (idle, walk, jump, punch, kick, throw, hit, ko, block)
- **Variants:** attack strength (lp, mp, hp, lk, mk, hk) — omit for non-attacks
- **Spritesheets:** `{character}_{action}_sheet.png`

This convention prevents naming mismatches between art and code (Nien creates sprites, Chewie/Lando reference them in code).
