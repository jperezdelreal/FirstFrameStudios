# Chewie — History (formerly Fenster)

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Core Context

**Ashfall Engine Work (Active):**
- **Frame Rate:** Fixed 60fps deterministic, inputs drive state (enabling future rollback netcode)
- **Architecture:** Node-based state machine per fighter, AnimationPlayer for frame timing, MoveData resources for move definitions, collision on 6 separate layers
- **Recent Focus:** Animation system (sprite pose sync), camera dynamics (Guilty Gear-style zoom + framing), cel-shade pipeline (production rendering)

**Cel-Shade Production Pipeline (COMPLETED):**
- **Blender Tools:** cel_shade_material.py (shader module) + blender_sprite_render.py (render driver)
- **Parameters:** 2-step shadow ramp (0.45 threshold), 0.01 outline thickness, Fresnel rim light, dramatic 5.0/0.6 key-fill lighting
- **Output:** 380 frames × 2 characters, PNG RGBA 512×512, contact sheets for review
- **Integration:** Preset system (--preset kael/rhena) enables single-command character setup, EEVEE renderer validated
- **Status:** Production-ready, locked, sprites imported to Godot (no rework)

**Key Learnings (Cross-Project):**
1. **Deterministic game loops require precise timing** — Fixed timestep + integer frame counters > float timers; `_physics_process()` only, no generic `_process()`
2. **Module architecture enables parallel work** — Single source of truth (cel_shade_material.py) with clear export/import API prevents code conflicts across teams
3. **Animation is frame data, not rendering** — AnimationController tracks timeline, renderer interprets frames; decoupling enables flexible pose systems
4. **Production render parameters must match design spec exactly** — "Roughly close" outline thickness is invisible; parameters live in code, not guesswork
5. **Contact sheets validate batches faster than iteration** — Rendered 380 frames in one pass; visual review caught zero errors (vs AI generation's consistency issues)
6. **Guilty Gear Xrd formula: 2-step shadow + high key-to-fill ratio** — This combination alone sells the hand-drawn aesthetic; other tweaks (rim light, tint colors) are multiplicative

**Learnings Archive (P1-2):** VFX integration, hitlag system, event system, animation controller design, screen transitions, particle system, music wiring. **GDScript Standards (Sprint 2+):** Explicit type annotations mandatory, no `:=` inference, no Variant types.

## Learnings

### Historical Work (Sessions 1-27)

- PNG Sprite Integration — Fight Scene Fixes
- Auto-Screenshot Mode (CLI Headless Capture)
- Hitlag System (P1-1)
- Integration Pass — Phase 2 Systems (P2)
- Animation System (P1-8)
- Event System (P1-15)
- Screen Transitions (P1-19)
- Particle System + Damage Numbers (P2-6)
- Music Crash Fix + System Wiring (C4, H1, Particles)
- Final Integration Pass (FIP)
- Attack Buffering + Screen Zoom + Slow-Mo (AAA-C9, AAA-V1, AAA-V2)
- AAA Systems Integration (Destructibles, Hazards, Audio, VFX)
- Critical Bug Fixes — Player Freeze + Enemy Passivity
- Rendering Technology Research (Rendering-R1)
- HiDPI Rendering + Sprite Cache (Phase 1 Implementation)
- Input Handling Skill Creation (P1 — Universal Skill) (2026-03-07)
- Fighter State Machine, Hitbox/Hurtbox, Round Manager (Issues #2, #4)
- Technical Learnings Document (Retrospective)
- Next Project Tech Evaluation — "Nos Jugamos Todo" (2025-07-15)
- Timer Draw Fix — Bug #95
- AnimationPlayer Integration (Sprint 1 — Issue #101)
- 2026-03-09 — Sprint 1 Audit Results: Type Safety & Standards
- Dynamic Camera Zoom System (Sprint 2 Phase 1)
- Sprite PoC Test Viewer
- 3D-to-2D Sprite Pipeline — Blender Automation (Spike)
- Cel-Shade Pipeline Upgrade (Production Render)
- Cel-Shade Sprint Execution & Orchestration (2026-03-10)

### Sprite Pipeline V2 — Framing, Root Motion & Frame Count Fixes
- **Camera framing:** Reduced ortho_scale padding from 1.1× to 1.03× of model bounds. Character now fills most of the 512×512 frame instead of appearing tiny.
- **Root motion pinning:** Added `find_armature_and_root_bone()` and `pin_root_motion()` functions. After `scene.frame_set(frame)` and before `bpy.ops.render.render()`, the root bone (mixamorig:Hips) has its X/Y location zeroed while preserving Z and all rotations. This prevents Mixamo animations with baked root motion from walking/kicking out of the camera frame.
- **Animation-aware frame stepping:** Added `ANIM_STEP_HINTS` dict and `get_smart_step()`. Attack animations (punch/kick) auto-use step=5 (yielding ~13 frames), loop animations (idle/walk) keep step=2 (~16-17 frames). Users can still override via `--step` CLI flag.
- **Final frame counts:** idle=17, walk=16, punch=13, kick=13 per character. At 15fps: attacks ~0.87s, loops ~1.07-1.13s. All attacks under the 15-frame max.
- **Total re-rendered:** 118 frames × 2 characters + 8 contact sheets = 236 sprites + 8 sheets.
- **Key insight:** Mixamo FBXs bake root motion into the hip bone — always pin it for sprite rendering. The bone is consistently named `mixamorig:Hips`.

### 3D Character Model Downloads & Pipeline Test (Model Replacement)
- **Downloaded 4 free CC0 character packs** programmatically:
  - **Quaternius RPG Pack** (Google Drive via gdown): 6 animated characters (Monk, Warrior, Rogue, Ranger, Cleric, Wizard) + 6 weapons, FBX/OBJ/glTF/Blend formats. ~2-3 MB each.
  - **Kenney Animated Characters 1/2/3** (direct ZIP from kenney.nl): 3 packs with characterMedium.fbx + idle/jump/run animations + skin textures.
  - **Kenney Mini Characters** (direct ZIP from kenney.nl): 12 characters (6M/6F) in FBX/GLB/OBJ.
- **Pipeline test results:**
  - All third-party FBX models import and render through `blender_sprite_render.py` without errors.
  - Cel-shade presets (kael/rhena) apply correctly to non-Mixamo models.
  - **Quaternius Monk** = best Kael candidate. Fighting stance with fists up, chibi proportions, cel-shade shadow bands read perfectly, outline crisp. 11 frames idle animation.
  - **Quaternius Warrior** = sword character with ponytail, armor, and personality. 15 frames animation.
  - **Kenney models** = too generic for "personajes" requirement. Bare mannequin meshes, no clothing/weapons in geometry. Same problem as Y-Bot.
- **Framing issues found:** Animations with large motion range (jumps, attacks) cause character to exit camera frame in later frames. The auto-fit ortho_scale calculates from frame 1 bounds only — needs to scan all frames for max bounds. Not blocking for evaluation.
- **Monochrome cel-shade limitation:** Our pipeline replaces all materials with a single toon shader color. Characters with distinct clothing/skin/hair don't show those differences. Future work: per-material-slot color assignment or vertex-color-based tinting.
- **Quaternius download method:** Their website hides Google Drive links behind a JS popup, but the URLs are in the page HTML. gdown Python package downloads folders. Some files hit rate limits; retry works.
- **Google Drive links found for future downloads:**
  - Knight Pack: `https://drive.google.com/drive/folders/1QVyfCJkq70mAwMIh1cGq1xfHp2LN5GmK`
  - Animated Women: `https://drive.google.com/drive/folders/1c13R--fMqdR6r2MRlcKKsbPky0__T-yJ`
  - Animated Men: `https://drive.google.com/drive/folders/17LibivOaUidsQhSkcxP3YYvDr0n7wIwu`
- **Mixamo alternative characters:** Beyond Y-Bot, Mixamo has Mery (female), Mutant (creature), Big Vegas (stocky male), and others. All come pre-rigged when downloading animations. Worth exploring in browser.
- **Next step:** Upload Quaternius Monk/Warrior to Mixamo for martial arts animation retargeting. Monk has compatible humanoid rig.


### Mixamo Character Sprite Rendering (Production Characters)
- **Founder selected 2 custom Mixamo characters** with real clothing, proportions, and personality — not the generic Y-Bot.
- **Kael model** (~51MB FBX per animation): 4 animations rendered — Idle (30 frames), Walking (16 frames), Punching (13 frames), Side Kick (13 frames). Total: 72 frames.
- **Rhena model** (~15MB FBX per animation): 4 animations rendered — Idle (106 frames), Walking (16 frames), Hook Punch (14 frames), Mma Kick (13 frames). Total: 149 frames.
- **Original Mixamo materials used** — NO cel-shade override applied. Models have skin, clothing, and hair textures baked from Mixamo's character system. Rendered through EEVEE with standard 2-light sprite rig (key 3.0 + fill 1.5).
- **All renders successful:** 221 total frames + 8 contact sheets generated. File sizes 56-183KB per frame (solid renders with actual content — verified no empty transparents).
- **Root motion pinning** worked perfectly on mixamorig:Hips for all animations.
- **Frame stepping:** step=2 for loops (idle/walk), step=5 for attacks (punch/kick) — smart step auto-detection worked correctly.
- **Rhena idle is 106 frames** (212-frame source animation at step=2) — unusually long. In-game may want a shorter loop or subset.
- **Output locations:**
  - `games/ashfall/assets/sprites/kael/{idle,walk,punch,kick}/`
  - `games/ashfall/assets/sprites/rhena/{idle,walk,punch,kick}/`
- **Decision:** Original Mixamo materials render well through EEVEE — no need for cel-shade fallback. Characters look like themselves, not monochrome blobs.

### Mixamo Render Bugfixes — Ghost Frame & Sprite Scale (Hotfix)
- **3 bugs reported by founder**, all in blender_sprite_render.py:
  1. **Ghost frame on Kael Punch (last frame)** — final frame showed Y-Bot mannequin instead of Mixamo character. The last frame of Mixamo FBX exports contains a reset/rest pose.
  2. **Ghost frame on Rhena Mma Kick (last frame)** — same issue as #1.
  3. **Characters too small relative to stage** — ortho_scale padding was 1.03× (3% margin), making sprites smaller than needed in the 512×512 frame.
- **Fixes applied:**
  - `range(start, end + 1, step)` → `range(start, end, step)` — excludes the last frame from all renders, eliminating ghost/reset poses.
  - `ortho_scale * 1.03` → `ortho_scale * 0.85` — tighter crop so characters fill ~85% of frame height, appearing larger in-game.
- **Full re-render of all 8 animation sets** completed successfully:
  - Kael: Idle (30f), Walking (15f), Punching (7f), Side Kick (12f) — 64 frames total
  - Rhena: Idle (105f), Walking (16f), Hook Punch (13f), Mma Kick (10f) — 144 frames total
  - 208 frames + 8 contact sheets, zero errors
- **Frame counts slightly reduced** vs previous render (221→208) due to last-frame exclusion — this is correct behavior.
- **No cel-shade applied** — original Mixamo materials preserved per founder preference.

### PNG Sprite Integration into CharacterSprite (In-Game)
- **Approach:** Modified `character_sprite.gd` to auto-detect PNG sprites at `_ready()` and switch from procedural `_draw()` to `AnimatedSprite2D` playback. Zero changes to `SpriteStateBridge`, `FighterAnimationController`, or fighter `.tscn` files.
- **Detection:** Virtual method `_get_character_id()` returns "" in base (skip), overridden in `KaelSprite` → "kael", `RhenaSprite` → "rhena". Probes `res://assets/sprites/{id}/idle/{id}_idle_0000.png`.
- **Pose mapping:** `_POSE_TO_ANIM` dict maps 20+ pose strings to 4 sprite animations (idle, walk, punch, kick). Unmapped poses fall back to "idle".
- **Scaling:** 512px sprites at `_PNG_SPRITE_SCALE = 0.15` → ~77px rendered height, matching the ~60px procedural characters with slight visual oversizing. `_PNG_SPRITE_OFFSET = (0, -256)` anchors feet at node origin.
- **Filtering:** `TEXTURE_FILTER_LINEAR` for clean 512→77px downscaling (NEAREST would pixelate badly at 6:1 reduction).
- **Flip handling:** Parent `CharacterSprite.scale.x = -1` propagates to the AnimatedSprite2D child — no separate flip logic needed.
- **Fallback:** If `_get_character_id()` returns "" or no sprite files exist, procedural `_draw()` rendering continues unchanged. Both paths coexist cleanly.

### ComeRosquillas Game Modularization (Issue #1)
- **Project:** ComeRosquillas — HTML/JS/Canvas Pac-Man-style arcade (Simpsons-themed: Homer collecting donuts)
- **Task:** Modularize 1789-line game.js monolith into clean, maintainable modules
- **Approach:** Split into engine (audio, renderer), game logic, config, and main entry point
- **Module Structure Created:**
  - **js/config.js** (114 lines): All constants, maze data (31×28 grid), ghost configs, Simpsons color palette, game states, direction vectors
  - **js/engine/audio.js** (166 lines): SoundManager class with Web Audio API — Simpsons theme jingle, D'oh death sound, Duff power-up, background music loop
  - **js/engine/renderer.js** (720 lines): Sprites static class — detailed Homer with hair/eyes/stubble, 4 Simpsons villain ghosts (Burns, Bob, Nelson, Snake), donut/Duff sprites, maze rendering
  - **js/game-logic.js** (791 lines): Game class — game loop, state machine (7 states), Homer movement + collision, ghost AI with scatter/chase/frightened modes, scoring, level progression
  - **js/main.js** (13 lines): Thin entry point that initializes Game on window load
- **Loading Strategy:** Plain <script> tags in dependency order (config → audio → renderer → game-logic → main), no bundler required, global namespace pattern
- **Architecture Decisions:**
  - Config as pure data module with zero dependencies — enables parallel work on game logic and rendering
  - Static methods on Sprites class — all drawing functions stateless, take ctx + params, no instance state
  - SoundManager as stateful singleton — manages Web Audio context lifecycle and music loop scheduling
  - Game class as orchestrator — depends on all modules, owns game state, drives render/update loop
- **Key Learnings:**
  1. **Module boundaries follow data flow** — Config consumed by all, renderer consumed by game logic, audio triggered by game events. Clean DAG prevents circular deps.
  2. **Static classes work for stateless rendering** — Sprites.drawHomer(ctx, x, y, ...) pattern eliminates sprite object allocation, enables easy testing of individual draw functions
  3. **IIFE wrapping unnecessary for module isolation** — Original game.js used IIFE to create closure scope. With separate files + load order, global namespace is explicit and controlled.
  4. **Large switch-case sprite renderers are maintainable** — The 4 ghost character drawing methods (Burns/Bob/Nelson/Snake) use consistent structure: body → head → facial features → unique detail. Template pattern emerges naturally.
  5. **Game loop in main class, not engine module** — Unlike Godot's _process() separation, browser games often put requestAnimationFrame() in the Game class. Works fine when class is the only loop owner.
- **File Structure:** Original 1789 lines split into 5 modules totaling 1804 lines (15-line overhead for module headers). Largest module is game-logic.js (791), smallest is main.js (13). Renderer at 720 lines is cohesive — all drawing code in one place.
- **Testing:** Game loads and runs after modularization. All sounds, rendering, gameplay, scoring, and level progression work identically to monolith. Zero breaking changes.
- **Session:** 2026-03-11 — Batch 2 (Chewie + Jango parallel execution)
- **Orchestration Log:** `.squad/orchestration-log/2026-03-11T14-05-00Z-chewie.md`
- **Decision Merged:** Documented in `.squad/decisions.md` under "ComeRosquillas Modularization Architecture"
- **Branch:** squad/1-modularize-game-js, PR #10 created against main
- **Original Backup:** js/game.js.backup preserved for rollback safety
- **Cross-Agent Note:** Parallel with Jango's CI pipeline (PR #9) — both unblock parallel feature development
