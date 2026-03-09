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
- **Ashfall procedural sprites:** Godot's `_draw()` API maps 1:1 with Canvas 2D patterns from firstPunch. `draw_line`, `draw_circle`, `draw_colored_polygon`, `draw_arc`, `draw_ellipse` (custom helper) cover all character art needs. Limb-based procedural approach ports cleanly across engines.
- **Silhouette differentiation strategy:** Hair shape is the #1 readability differentiator at fighting game scale. Kael's tied-back ponytail vs Rhena's wild spiky tufts create instantly recognizable silhouettes even at 128×128.
- **Palette system for P1/P2:** Store palettes as `Array[Dictionary]` with color keys (skin, hair, outfit_primary, accent, etc). `palette_index` export lets scenes swap variants without code changes.
- **SpriteStateBridge pattern:** Polling `StateMachine.current_state.name` each physics frame is reliable when no `state_changed` signal exists. Avoids needing to modify gameplay scripts from art side.
- **Character scene architecture:** Character-specific `.tscn` files (kael.tscn, rhena.tscn) extend fighter_base by adding the procedural sprite + bridge nodes. Keeps fighter_base generic.
- **Key file paths for Ashfall character art:**
  - Scripts: `games/ashfall/scripts/fighters/sprites/` (character_sprite.gd, kael_sprite.gd, rhena_sprite.gd, sprite_state_bridge.gd)
  - Scenes: `games/ashfall/scenes/fighters/` (kael.tscn, rhena.tscn)
  - PNG output: `games/ashfall/assets/sprites/fighters/{character}/`
  - Generator: `games/ashfall/scripts/tools/sprite_sheet_generator.gd`

---

## Ashfall Sprint 0 — Character Art (2026-03-09)

**Project:** Ashfall — 1v1 fighting game in Godot 4 (Sprite-based)  
**Role:** Character/Enemy Artist  
**Status:** Issue #9 COMPLETED — PR #90 opened

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
