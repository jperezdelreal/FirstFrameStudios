# Nien — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current characters:** Brawler with bezier curves, M-hair, stubble, overbite. 4 enemy variants (normal/fast/heavy/tough) + Bruiser boss. All Canvas 2D procedural art.

## Learnings
- **Sprint 1 full animation pass (Issue #91, PR #104):** Added 33 new procedural poses per character, bringing total from 8 to 41 per fighter. Covers all GDD-spec states: crouch, jump phases, dash/backdash, 3 standing kicks, all 6 crouching attacks, all 6 jump attacks, both block types, throw execute/victim, wakeup, 4 specials each, ignition super, win, and lose poses.
- **Crouch offset pattern:** Using a `co` (crouch offset) variable to shift the entire body downward while keeping feet at FOOT_Y=0 creates consistent crouching poses without duplicating all the body math.
- **Jump lift pattern:** Similarly, a `lift` offset variable shifts the body upward for jump states while maintaining relative proportions.
- **SpriteStateBridge expanded:** Now handles jump velocity-based pose selection (up/peak/fall), crouch detection via state method, and full attack routing including kicks, crouching attacks, air attacks, specials, and ignition. The `_is_crouching()` helper checks the state for a method rather than assuming.
- **Attack routing order matters:** In `_get_attack_pose()`, checking "hk" before "lk" prevents "lk" substring matching on "heavy_kick". Special moves checked first since they take priority.
- **Character personality through pose exaggeration:** Kael's kicks use controlled side-kick technique; Rhena's use explosive roundhouses and axe kicks. Same functional hitbox, completely different read. Heavy attacks always get screaming head for Rhena but focused head for Kael.
- **Specials need unique VFX language:** Kael's Ember Shot uses concentric circles (projectile energy), Rising Cinder uses vertically-spaced trail dots (rising motion). Rhena's Blaze Rush uses trailing particles (forward rush), Flashpoint uses explosive burst (launcher impact). Each special reads differently even as procedural shapes.
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

- **Sprint 2 animation completion (Issues #99/#100, PR #115):** Added 6 final GDD-spec poses per character (throw_startup, throw_whiff, hit_heavy, hit_crouching, hit_air, knockdown_fall), bringing total from 41 to 47 per fighter. Each pose maintains character personality: Kael's are controlled/composed (open-hand grab, composed stumble, precise body curl), Rhena's are explosive/messy (predatory wide grab, angry stumble, ragdoll tumble).
- **Hit variant routing pattern:** SpriteStateBridge now routes hit poses contextually: airborne -> hit_air, crouching -> hit_crouching, heavy attack -> hit_heavy (via is_heavy_hit() method check), default -> hit. Same pattern for KO: airborne -> knockdown_fall, grounded -> ko. This lets one state machine state produce multiple visual poses.
- **Duplicate function cleanup:** character_sprite.gd and sprite_state_bridge.gd had duplicate function definitions from Sprint 1 merge artifacts. GDScript uses last-definition-wins, but duplicates create confusion and potential Godot parse issues. Cleaned up during this pass since the files were being modified anyway.
- **File I/O gotcha:** The edit tool's virtual filesystem may not sync to disk in all environments. When in doubt, use Python file I/O through PowerShell to make changes directly to the actual filesystem.

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
