# Squad Decisions

## Active Decisions

### Cel-Shade Parameters for Fighting Game Sprite Quality (Boba)
**Author:** Boba (Art Director)  
**Date:** 2026-06-12  
**Status:** RECOMMENDED FOR IMPLEMENTATION  
**Audience:** Chewie (Engine Dev), Joaquin (Founder)

We will upgrade the Ashfall Blender sprite rendering pipeline to **Guilty Gear Xrd-inspired cel-shade parameters**, targeting fighting game visual quality (readable at 512×512, bold outlines, dramatic lighting, hand-painted color treatment).

**Current Problem:** Outline thickness (0.002) is invisible at 512×512 PNG export; reads as muddy. 3-step shading too soft for fighting game punch; needs hard-edged shadow/lit split.

**Guilty Gear Xrd Reference:** Arc System Works achieved iconic anime-style 3D NOT through photorealism, but through:
1. **Bold outlines** — visually dominant, define form
2. **Hard shadow edges** — 2-step banded shading, not gradual
3. **Dramatic directional lighting** — artist-chosen, non-physical
4. **Color restraint** — characters stay in hue family (no radical hue shifts)

**Specific Parameters:**
- **Outline Thickness:** 0.008 (4× thicker, ~2–3 pixels at 512×512)
- **Kael Outline:** (0.35, 0.15, 0.05) — burnt sienna, warm
- **Rhena Outline:** (0.08, 0.12, 0.20) — dark navy, cool
- **Shading:** 2-step (shadow + lit with hard edge at 0.5 diffuse threshold)
- **Lighting:** Key SUN 3.0 (50°, 10°, 30°) + Fill SUN 1.5 (60°, -20°, -30°) + Ambient (0.15, 0.15, 0.18) strength 0.5
- **Export:** PNG RGBA 8-bit, BLENDER_EEVEE renderer

**Impact:**
- Visual: Immediate character recognizability at all scales; arcade-game polish
- Technical: Minor code changes, no render time increase
- Schedule: 3–5 hours total (Chewie implementation + testing)

**Acceptance Criteria:**
1. Code updated: Thickness flag exposed in CLI, outline colors per character in PRESETS
2. Test renders: Kael idle, Rhena idle at 512×512 exported as PNG
3. Visual validation: In Godot viewport at game scale (screen-side-by-side with old renders)
4. Approval: Boba visual review; if quality acceptable, lock parameters for production sprite batch
5. Documentation: Spec updated with any parameter tweaks after testing

**Reference:** `games/ashfall/docs/CEL-SHADE-ART-SPEC.md` (comprehensive, implementation-ready)

---

### Cel-Shade Pipeline Standardization (Chewie)
**Author:** Chewie (Engine Developer)  
**Date:** 2026-07-22  
**Status:** Proposed  
**Scope:** Ashfall sprite rendering pipeline

Standardized the cel-shade sprite pipeline with production-quality parameters:

1. **2-step shadow bands as default** — Hard shadow/lit split at 0.45 (Guilty Gear Xrd style). 3-step available via `--steps 3` but 2-step is the fighting game standard.
2. **Outline thickness 0.01** — Visible at 512px. Previous 0.002 was invisible. Range 0.008-0.012 appropriate for Mixamo mannequin.
3. **Fresnel rim light always on** — Edge glow with per-character color. Disable with `--no-rim-light`.
4. **Dramatic single-key lighting** — Key=5.0, Fill=0.6, Ambient=0.3. High contrast drives the cel-shade look.
5. **Single source of truth** — `cel_shade_material.py` is the only shader module. `blender_sprite_render.py` imports it via `--preset` flag.
6. **EEVEE engine name** — Blender 5.0 uses `BLENDER_EEVEE` (not `BLENDER_EEVEE_NEXT`).

**Impact on Team:**
- Artists reviewing sprites: Files in `assets/sprites/{character}/{animation}/`
- Anyone rendering: Use `--preset kael` or `--preset rhena` — no manual color setup
- New characters: Add preset to `cel_shade_material.py` PRESETS dict
- Pipeline docs in `tools/BLENDER-SPRITE-PIPELINE.md` remain valid

**Why:** Founder wants Street Fighter / Guilty Gear Xrd style. The 2-step shadow + rim light + thick outline combination achieves that dramatic hand-drawn look from free Mixamo mannequins.

**Status:** Ready for production. 380 frames rendered (Kael 190 + Rhena 190) with contact sheets.

---

### Ashfall GDD v1.0 — Creative Foundation (Yoda)
**Author:** Yoda (Game Designer / Vision Keeper)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Ashfall project — all agents building on this game

Game Design Document for Ashfall (`games/ashfall/docs/GDD.md`), a 1v1 fighting game built in Godot 4. The GDD covers vision/pillars, core mechanics, 2 characters, 1 stage, game flow, controls, AI, art direction, audio direction, and scope boundary.

**Key Creative Decisions:**
1. **The Ember System** — Ashfall's signature mechanic. A visible, shared resource that replaces traditional hidden super meter. Both players can see and fight over it.
2. **6-Button Layout** — LP/MP/HP/LK/MK/HK with macro buttons for throw and dash. Street Fighter lineage, not Tekken.
3. **Kael & Rhena** — Balanced shoto vs rushdown. Classic archetype pairing that naturally teaches fighting game fundamentals.
4. **Deterministic Simulation from Day 1** — Fixed 60fps, seeded RNG, input-based state. Enables future rollback netcode without rewrite.
5. **Combo Proration** — Damage scales down per hit in combo (100% → 40% floor). Max combo damage ~35-45% HP.
6. **Scope Boundary** — MVP = 2 characters, 1 stage, local vs, arcade, training. Everything else deferred.

**Impact on Team:** Scene structure and deterministic game loop defined. Frame data and combat system spec ready. AI behavior tree and difficulty parameters defined. All teams have clear design direction.

**Why:** Design translation of founder directive ("1v1 fighting game, 1 stage + 2 characters"). Scope boundary prevents team from building features outside core loop.

---

### Ashfall Fighting Game Architecture (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-08-03  
**Status:** Proposed

Technical architecture defined in `games/ashfall/docs/ARCHITECTURE.md`. Key decisions:

1. **Frame-based timing** — Integer frame counters, not float timers. All gameplay in `_physics_process()` at 60 FPS fixed tick.
2. **Node-based state machine** — Each fighter state is separate Node with independent script.
3. **AnimationPlayer as frame data** — Hitbox activation driven by AnimationPlayer tracks (startup/active/recovery frames).
4. **MoveData as Resource** — Moves are `.tres` resource files with frame data, damage, hitstun, knockback. Pure data, no logic.
5. **AI uses input buffer** — AI injects synthetic inputs; same code path as human fighters.
6. **Six collision layers** — P1/P2 hitboxes, hurtboxes, pushboxes on separate layers. No self-hits.
7. **Six parallel work lanes** — File ownership ensures simultaneous work without conflicts.

**Impact:** All agents must read `games/ashfall/docs/ARCHITECTURE.md` before writing Ashfall code. Clear module boundaries enable 6 parallel work streams.

**Why:** Deterministic fighting games require frame-perfect timing. Module separation enables parallel development without cross-dependencies.

---

### Ashfall Sprint 0 Scope & Milestone Decisions (Mace)
**Author:** Mace (Producer)  
**Date:** 2026-[Sprint Start Date]  
**Status:** Active — Governing Sprint 0 execution

Complete Sprint 0 plan in `games/ashfall/docs/SPRINT-0.md` covering scope lock, deliverables, phased expansion, studio methodology, technology selection, feature triage, release gates, and knowledge capture.

**Scope Decisions:**
1. **MVP Scope (LOCKED):** 1 stage + 2 characters + basic AI + round system + game flow
2. **Sprint 0 Focus:** Architecture + playable prototype only; no content art, sound, menus
3. **Phased Content Expansion:** 5 phases (Foundation → Balance → Art → UI/Stage → Audio)
4. **Studio Methodology:** 20% load cap + Scrumban (3-task WIP limit) for 14-agent parallelism
5. **Technology Lock:** Godot 4 + GDScript (no re-evaluation this project)
6. **Feature Triage:** Four-Test Framework (core loop, player impact, cost-to-joy, coherence)
7. **Release Gates:** Definition of Done requires acceptance criteria, review, integration, docs, git, playtesting
8. **Knowledge Capture:** Sprint 0 outputs become reusable patterns for future FFS projects

**Governance:** joperezd (final approval), Mace (enforcement), Yoda (design), Solo (architecture), all agents (load discipline).

**Why:** Locked scope + parallel methodology prevents bottlenecks. 14-agent team can work truly parallel with clear role boundaries. Phased approach enables incremental delivery and playtesting feedback.

---

### User Directives (2026-03-08)

#### 2026-03-08T115537Z: Ashfall Game Type Pivot
**By:** joperezd (via Copilot)  

Ashfall pivots from action roguelike to 1v1 fighting game (Tekken/Street Fighter style) in Godot 4. Scope limited to 1 stage + 2 characters initially. Content expansion deferred.

#### 2026-03-08T10:37: Repository Structure
**By:** joperezd (via Copilot)  

First Frame Studios uses a single GitHub repository (monorepo). The .squad/ folder lives at root (studio-level). Each game is a subfolder containing its Godot project. Team has access to GitHub Actions, PRs, Dashboards, and all GitHub features.

**Why:** Centralizes studio knowledge, skills, and team state. Each game is a folder, not separate repo.

#### 2026-03-08T10:25: Tool & Skill Development Autonomy
**By:** joperezd (via Copilot)  

Agents should NOT be limited to existing tools and skills. When performing a task, if an agent detects a gap or needs a specific tool to do better work, they should have the ability to request it and have it developed on the spot.

---

### Game Architecture (McManus)
**Date:** 2026-06-03  
**Status:** Implemented

Complete beat 'em up game with modular ES6 architecture and no external dependencies. Fixed timestep (60 FPS), Canvas 2D renderer with camera system, keyboard state management, Web Audio API sound effects. Entity-component pattern for Player and AI enemies with state machines. Combat uses rectangle collision detection, knockback physics, hitstun. Wave-based progression with camera locks. All graphics procedurally drawn via Canvas API. File structure: index.html + styles.css for entry, src/engine/entities/systems/scenes/ui/ for modules.

**Why:** Simplicity (no frameworks), modularity (clean separation), performance (fixed timestep), and satisfying combat feedback (screen shake, knockback, hitstun).

### Core Gameplay Bug Fixes (Keaton)
**Date:** 2024  
**Status:** Implemented

Five critical bugs fixed:
1. **Input infinite recursion** — Renamed duplicate `isDown()` to `isMovingDown()` to prevent stack overflow
2. **Hit detection unreliability** — Moved `Combat.handlePlayerAttack()` to run every frame with `attackHitList` Set to prevent multi-hits
3. **Damage loop** — Added 500ms invulnerability frames (`invulnTime`) with blink effect for visual feedback
4. **Parallax direction** — Changed background scroll from 1.3x to 0.3x for proper depth perception
5. **Left boundary** — Added player boundary check `Math.max(player.x, cameraX + 10)` to keep player visible

**Why:** Surgical fixes to make game playable. Each addressed a specific bug without rewriting systems. Hit tracking and i-frames follow standard beat 'em up patterns.

### Team Expansion (Solo/Keaton, Lead)
**Date:** 2026-06-03  
**Status:** Implemented

Complete squad expansion from 4 core roles (Solo, Chewie, Lando, Wedge) to 9-member cross-game development team. VFX/Art Specialist (Boba) confirmed. Three new roles added:
- **Greedo (Sound Designer):** Owns Web Audio API expertise, procedural SFX library, music generation system. 7 backlog items (2×P0, 2×P1, 1×P2, 2×P3). Frees Chewie from audio work. Cross-game value: ★★★★★ (sound toolkit compounds across all projects).
- **Tarkin (Enemy/Content Dev):** Owns enemy AI, boss design, wave composition, pickups, difficulty scaling. 14 backlog items (1×P1, 6×P2, 7×P3). Reduces Lando from 26→12 items. Works in parallel on content while Lando builds player systems.
- **Ackbar (QA/Playtester):** Owns testing, balance tuning, feel verification across all items. Develops calibrated instincts for hitbox fairness, combo timing, input responsiveness. Cross-game value: ★★★★☆ (feel tuning expertise compounds).

Revised load distribution eliminates McManus bottleneck, enables parallel workstreams (Engine/Gameplay/Content/Presentation).

**Why:** Gap analysis on 52-item backlog revealed structural overload: Lando carrying 50%, Chewie juggling audio + engine. Three new roles distribute work, enable parallelism, and build compounding cross-game expertise.

### Phaser 3 & Future Tech (2026-03-06T20:05)
**By:** joperezd (via Copilot)  
**Status:** Pending — Future Project Planning

Phaser 3 and other "too late to implement" improvements should be captured as learnings for future projects, not implemented in firstPunch. The squad should conduct deep research across all game development disciplines, document everything, analyze the current game for what's easily implementable vs needs major refactoring, and work autonomously for 4 hours with excellence as the standard.

**Why:** Strategic learning capture for the game dev squad's growth across projects. Protects firstPunch from scope creep while building institutional knowledge for next project.

### Full Codebase Analysis & Learnings (Solo)
**Date:** 2026-03-06  
**Status:** Completed

Read all 28 source files (370KB) and categorized every remaining backlog item into 3 buckets:

**Key Findings:**
1. **13 AAA backlog items already shipped** (grab/throw, dodge roll, back attack, attack buffering, screen zoom, slow-mo kills, scene transitions, destructibles, hazards, boss intros, ambience, hit sound scaling, options menu, hitbox visualization). Active backlog should be ~85 items, not 101.

2. **3 complete infrastructure systems exist but unused**: EventBus (49 LOC), AnimationController (85 LOC), SpriteCache (35 LOC). Also CONFIG (45 LOC). Total: 214 LOC of working code gathering dust. Wiring these is highest-priority action.

3. **Bucket classification:**
   - **Quick Wins (< 1h):** 10 remaining actionable items
   - **Medium Effort (1-4h):** 30 actionable items
   - **Future/Migration:** 14 items requiring Phaser 3 or WebGL

4. **gameplay.js (695 LOC) = #1 technical debt** — touches every system, 40+ direct calls. EventBus wiring is the single most impactful refactor.

5. **Procedural art ceiling reached** — each character needs ~400 LOC Canvas code. Adding Kid/Defender/Prodigy = 1200+ LOC. Strongest argument for Phaser 3 + sprite sheets.

6. **Phaser 3 migration impact:** Replaces ~800 LOC infrastructure (game loop, renderer, input, camera, particles, animation) with GPU-accelerated equivalents. Keeps ~3500 LOC game-specific logic.

**Recommended Priority:** Wire unused infrastructure (CONFIG, EventBus, AnimationController, SpriteCache) → Quick Wins → Combat polish → Content/Visual quality → System polish → Phaser 3 migration.

### New Project Playbook Created (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Studio-wide — affects how every future project starts

Created `.squad/identity/new-project-playbook.md` — the definitive, repeatable process for starting any new project at First Frame Studios, regardless of genre, tech stack, IP, or platform.

**What It Contains:**
1. **Pre-Production Phase** — Genre research protocol (7-12 reference games, analytical play, skill extraction), IP assessment (original vs licensed), 9-dimension tech selection framework, team skill transfer audit, competitive analysis
2. **Sprint 0 Foundation** — Engine-agnostic repo checklist, squad adaptation guide, genre skill creation, architecture proposal requirements, minimum playable formula per genre, quality gates adaptation
3. **Production Phases** — P0-P3 priority system, parallel lane planning, skill capture rhythm, cross-project knowledge transfer
4. **Technology Transition Checklist** — What transfers/rewrites/needs evaluation, migration mapping (Canvas→Godot as template), repeatable training protocol
5. **Language/Stack Flexibility Matrix** — 12 tech stacks compared, T-shirt migration sizing, the 70/30 rule (70% of our effectiveness is tech-agnostic)
6. **Anti-Bottleneck Patterns** — 7 firstPunch bottlenecks with preventions, 6 common studio patterns, serialize/parallelize guide, add-role vs add-skill decision matrix

**Key Decisions Within:**
- **8-point migration threshold:** Require 8+ point lead in 9-dimension matrix to justify engine migration
- **20% load cap:** No agent carries more than 20% of any phase's items
- **Module boundaries in Sprint 0:** Architecture proposal required before Phase 2 code begins
- **Wiring requirement:** Every infrastructure PR must include connection to at least one consumer

**Why:** The founder wants solid foundations so starting any new project is clear, repeatable, and bottleneck-free. firstPunch taught us everything in this playbook through real bugs, real bottlenecks, and real breakthroughs. Documenting it ensures we never repeat the investigation.

**Impact:**
- Every future project follows this playbook from Day 1
- Pre-production becomes a structured process, not ad-hoc discovery
- Technology transitions follow a proven 4-phase pattern
- Bottleneck patterns are identified and mitigated proactively
- New team members can read this document and understand how we start projects

### Skills System Needs Structural Investment Before Next Project (Ackbar)
**Author:** Ackbar (QA Lead)  
**Date:** 2025-07-21  
**Status:** Proposed

Conducted comprehensive audit of all 12 skills in `.squad/skills/`. Quality of individual skills is strong (7/12 rated ⭐⭐⭐⭐+), but coverage (5/10) and growth-readiness (4/10) are the weaknesses.

**Decision:**
Three actions should be taken before the next project kicks off:

1. **Create `game-feel-juice` skill (P0)** — Our #1 principle ("Player Hands First") has no dedicated skill. Game feel patterns are scattered across 3 skills. A unified, engine-agnostic game feel reference should be the first skill any new agent reads. Assign to Yoda + Lando.

2. **Create `ui-ux-patterns` skill (P1)** — Wedge is a domain owner with zero skills. Every game needs UI. This is the largest single-agent gap on the team. Assign to Wedge.

3. **Structural cleanup (P1)** — Split `godot-beat-em-up-patterns` (39KB, too large). Resolve overlaps: merge `canvas-2d-optimization` into `web-game-engine`, deduplicate `godot-tooling` vs `project-conventions`. Assign to Solo + Chewie.

**Impact:**
- **Yoda, Lando:** Create `game-feel-juice` skill
- **Wedge:** Create `ui-ux-patterns` skill  
- **Solo, Chewie:** Structural cleanup of overlapping skills
- **All agents:** 6 skills should have confidence bumped from `low` to `medium`
- **Full audit:** `.squad/analysis/skills-audit.md` contains per-skill ratings, gap analysis, and improvement recommendations

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

---

### Sprint 0 Milestone Status Update (Mace)
**Author:** Mace (Producer)  
**Date:** 2026-03-09  
**Status:** Active

M0-M3 gates have been passed and verified. M4 (stable build, balance tuning, ship) is now the active milestone gate.

**Milestone Status:**
- M0 ✅ GDD + Architecture approved (closed issues #1-#4 in Sprint 0)
- M1 ✅ Project buildable (scaffold + core systems implemented)
- M2 ✅ Movement + attacks working (fighter controller, hitbox system, AI opponent functional)
- M3 ✅ HUD integrated, game flow playable 1v1 (main menu, character select, fight scene, HUD, round manager, victory screen — all implemented and wired)
- M4 🔲 Stable build, balance tuning, ship Sprint 0 — **ACTIVE GATE**

**Current Blockers:**
- P0 Blocker: Issue #88 (Integration Gate failure — signal wiring in core systems)

**In Progress:**
- Issue #9 (character sprite placeholders — assigned to Nien, Phase 2 content prep, NOT M4 blocker)
- Ackbar playtesting and balance tuning (M4 ship gate activity)

**Scope Clarification:**
- Issues #50-#58 (Phase 2-5 content: VFX palettes, audio, cinematics, training mode) are NOT Sprint 0 blockers
- M4 gate focuses solely on: Integration stability, combat feel, deterministic 1v1 game flow
- Phase 2 content waits for M4 completion

---

### 2026-03-09T220139Z: Game Resolution is 1080p
**By:** joperezd (via Copilot)  
**What:** Game resolution is 1920×1080 (1080p), NOT 720p. This affects sprite dimension scaling: at 1080p, characters render larger, so 512×512 may need validation for proportions.  
**Why:** User correction — critical data for sprite sizing and oversampling calculation.

---

### 2026-03-09T215832Z: FLUX for Stage Backgrounds
**By:** joperezd (via Copilot)  
**What:** FLUX models are used for generating stage art (backgrounds, parallax layers, round progression visuals), not just character sprites. Stages are simpler: no frame-to-frame consistency required, only style coherence. ~10-15 images per stage vs ~1,000 for characters.  
**Why:** User insight — expands art sprint scope to cover full visual system, not isolated character assets.

---

### 2026-03-09T220815Z: FLUX for HUD Art + Inspiration References
**By:** joperezd (via Copilot)  
**What:** HUD elements are also FLUX-generated: life bar frames, character portraits, ember meter decorations, UI backgrounds. Text and dynamic data render in-engine. Founder added inspiration screenshots in `docs/screenshots/Inspiration` (Tekken, Street Fighter, etc.) for style reference in prompts.  
**Why:** User input — extends FLUX scope to complete visual ecosystem and provides real industry references for consistent AI generation.

---

### Sprite Brief v3 — Three-Model FLUX Pipeline Validated
**Author:** Boba (Art Director)  
**Date:** 2026-03-11  
**Status:** Final  
**Scope:** Ashfall art asset production — all FLUX-based generation

Complete specification for multi-model AI sprite production in `games/ashfall/docs/SPRITE-ART-BRIEF.md` v3. Three FLUX models validated end-to-end on Azure AI Foundry with confirmed authentication, rate limits, and capabilities.

**Key Decisions Locked:**

1. **Three-Model Pipeline:**
   - **FLUX 2 Pro** (4 req/min, 4.0 MP) → Hero frames only (1024×1024 identity reference per character)
   - **FLUX 1 Kontext Pro** (30 req/min, 1.0 MP) → Production sprites (512×512 with character consistency via reference images)
   - **FLUX 1.1 Pro** (30 req/min, 1.6 MP) → Non-character assets (backgrounds, VFX, projectiles, HUD, UI)

2. **512×512 Resolution Confirmed for 1080p:**
   - Game renders at 1920×1080
   - Sprites at 512×512 = 3.3× oversampling at typical viewport distance
   - Risk: LOW — proportions safe, no aliasing risk

3. **Character Consistency Upgrade:**
   - v2 used prompt anchoring only (weakest technique)
   - v3 uses Kontext Pro's `input_image` parameter for visual reference propagation (proven technique)
   - Risk assessment: proportions drift downgraded from High to Medium; costume detail loss from Medium to Low

4. **Hero Frame Gate (Single QC Point):**
   - No pose production begins without Boba approval of character hero frame
   - Hero frames generated at 1024×1024, downscaled to 512×512 for reference input
   - This is the pipeline's only quality control checkpoint

5. **Production Estimates:**
   - ~1,020 total frames (51 poses × 2 characters × ~10 avg frames/pose)
   - Raw generation: ~34 minutes at Kontext Pro's 30 req/min
   - With QA cycles: ~2 hours total
   - Tier: Modern Indie Fighter (510 frames/character equivalent)

6. **Infrastructure:**
   - All models on same Azure AI Foundry resource
   - Auth: Entra ID Bearer token (API key auth disabled by org policy)
   - Token refresh: ~1 hour expiry, auto-refresh for batch sessions

7. **Asset Scope (Full Visual System):**
   - Character sprites: ~1,020 frames (Kontext Pro, consistency critical)
   - Stage backgrounds: ~10-15 per stage (FLUX 1.1 Pro, style coherence only)
   - HUD elements: ~30-50 UI assets (FLUX 1.1 Pro with inspiration references)
   - Title screen: 1-2 cinematic frames (FLUX 2 Pro for quality)

**Impact on Team:**
- **All agents:** SPRITE-ART-BRIEF.md v3 is master reference for sprite generation. No further revisions needed for P0/P1.
- **Mace (Producer):** Production timeline confirmed realistic — 2 hours for full sprite set generation.
- **Chewie/Bossk (Gameplay/VFX):** File naming convention and Godot import settings locked. Can begin integration in parallel.
- **Coordinator:** Infrastructure validation complete. All three models tested end-to-end.

**Why:**
v1 and v2 were written against assumptions about FLUX capabilities. v3 is written against validated infrastructure — three models tested end-to-end with confirmed endpoints, rate limits, and capabilities. The three-model pipeline leverages each model's strengths rather than forcing one model to do everything.

**This document is the single source of truth for all art asset generation for the remainder of the Ashfall sprint.**

---

## Sprint 0 Closure Decisions (2026-03-09)

### M4 Gate Playtest Verdict (Ackbar)
**Author:** Ackbar (QA/Playtester)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall Sprint 0 M4 gate — ship verification

**Decision:** **PASS WITH NOTES** for M4 gate.

**Rationale:**
The Sprint 0 prototype passes because:
- Full game flow works end-to-end (main menu → character select → fight → victory → rematch/menu)
- 9 fighter states implemented and transitioning correctly with safety timeouts
- Frame-based determinism is solid (integer counters, 60 FPS locked)
- Input system uses proper FGC conventions (8f buffer, SOCD, motion priority)
- EventBus decoupling between all 7 autoloads is clean
- Balance data is reasonable for shoto vs rushdown archetypes
- Audio/VFX/HUD integration is correctly signal-wired

**Conditions (Must-Fix Before M5):**
1. **P0 #92:** Add hitbox geometry to fighter scenes (attacks currently deal no damage)
2. **P0 #93:** Fix take_damage signature (fight_scene passes 1 arg, needs 3)
3. **P1 #94:** Sync RoundManager scores to GameState (HUD/victory show 0-0)
4. **P1 #95:** Handle equal-HP timer draw (currently loops forever)

**Impact:** Sprint 0 M4 gate is cleared. The team can proceed to M5 planning. The 4 bugs above are blocking for any gameplay-focused milestone and should be the first items in the next sprint.

---

### P0 Combat Pipeline Integration Fix (Lando)
**Author:** Lando (Gameplay Developer)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall combat system — affects all agents touching hit/damage pipeline

**Decision:** The combat damage pipeline (hitbox → EventBus.hit_landed → fight_scene → take_damage) was broken at two independent points: missing collision geometry and mismatched function signatures. Both bugs existed since the initial implementation because hitbox.gd, fight_scene.gd, and fighter_base.gd were authored by different agents without a live integration test.

**Key Fixes:**
1. **Hitbox geometry** must be defined in the scene file, not left empty. CollisionShape2D with RectangleShape2D (36x24) added under Hitboxes/Hitbox.
2. **take_damage signature** aligned: fight_scene.gd now passes all 3 args (damage, knockback_force, hitstun_frames) from the hit_data dictionary.

**Team Impact:**
- **All agents:** When building cross-module pipelines (emitter → signal → consumer), the full chain must be tested end-to-end before the PR merges. Signal signatures and scene node hierarchies are the most common mismatch points.
- **Tarkin:** When wiring AnimationPlayer-driven hitbox activation, the Hitbox node + CollisionShape2D now exist in fighter_base.tscn. Per-move hitbox sizing can override the default 36x24 shape via MoveData or AnimationPlayer tracks.
- **Ackbar:** The hit_data dictionary keys used are `knockback_force` and `hitstun_duration` (matching hitbox.gd's emit). Any future additions to hit_data should be documented.

**Why:** Two P0 bugs blocking Sprint 0 ship. Both were integration seams — individually correct modules that failed when connected. This is our most common bug pattern in multi-agent development.

---

### Equal-HP Draw State Handling (Chewie)
**Author:** Chewie (Engine/Systems)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall RoundManager — draw state logic and signals

**Decision:** When both fighters reach 0 HP simultaneously, round_manager must declare round_draw (not loop forever). Dual new signals (round_draw, match_draw) clarify game rule implementation.

**Key Changes:**
1. **Draw State Logic:** RoundManager.check_round_end() now checks if both fighters' HP ≤ 0, emits `round_draw` signal instead of entering KO state.
2. **Signal Architecture:** New `round_draw` signal for per-round draws; new `match_draw` signal for full match draws (future tournament logic).
3. **GDD Alignment:** Per GDD: "Equal HP = mutual KO = draw round" — now correctly implemented.

**Team Impact:**
- Rules encoded as signals improve code clarity (testable, debuggable)
- New team members can read signals as game rule documentation
- Draw states properly handled for 1v1, tournament, and network play future

**Why:** Game rules must be explicit in code. The GDD said "equal HP = draw," but the round_manager logic only knew about KO.

---

### HUD Score Sync Architecture (Wedge)
**Author:** Wedge (UI/Frontend)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall UI — score tracking and GameState integration

**Decision:** GameState is the single source of truth for all score state. RoundManager syncs scores to GameState after each round, and FightHUD reads from GameState every frame.

**Key Architecture:**
1. **Score Sync:** After `round_end`, RoundManager calls `GameState.set_scores(scores)`.
2. **GameState Enhancement:** New `set_scores()` and `get_scores()` methods ensure persistence and read access.
3. **FightHUD Integration:** HUD reads from `GameState.scores` (not local copies), preventing drift.

**Team Impact:**
- Autoload state is the source of truth (prevents local state drift)
- HUD is data-driven (easier to test, debug, extend)
- Foundation for multiplayer sync (GameState → network replication path)

**Why:** Local state (RoundManager.scores) can drift from global state (GameState.scores). Always push updates to single source of truth.

---

### Procedural Sprite System for Ashfall Characters (Nien)
**Author:** Nien (Character Artist)
**Date:** 2026-03-09
**Status:** Proposed
**Scope:** Ashfall character art pipeline

**Decision:** Character placeholders use Godot's `_draw()` API via a `CharacterSprite` base class (Node2D) instead of pre-rendered PNG sprite sheets. Each character has its own sprite script (kael_sprite.gd, rhena_sprite.gd) that overrides pose methods.

**Key Points:**
1. **Procedural-first pipeline:** Characters are drawn at runtime using Godot draw primitives. A `SpriteSheetGenerator` @tool script can bake these into PNGs for AnimationPlayer when needed.
2. **Palette system:** P1/P2 variants are `Array[Dictionary]` of named colors. `palette_index` export swaps palettes without code changes. Extensible to additional costumes.
3. **State bridge pattern:** `SpriteStateBridge` polls `StateMachine.current_state.name` each physics frame to sync poses. No modifications to gameplay scripts required — respects ownership boundaries.
4. **Character-specific scenes:** `kael.tscn` and `rhena.tscn` extend fighter_base.tscn structure, adding procedural sprite + bridge as new nodes. `fight_scene.tscn` updated to instance these instead of generic fighter_base.
5. **Silhouette differentiation:** Kael = ponytail + lean upright stance + controlled extensions. Rhena = wild spiky hair + wide low stance + overshooting messy swings. Distinct at any scale.

**Impact:**
- **Boba (Art Director):** Review silhouettes and palettes for style guide compliance
- **Chewie/Lando (Engine/Gameplay):** fight_scene.tscn now instances kael.tscn/rhena.tscn instead of fighter_base.tscn. Sprite2D node preserved for future texture loading.
- **Solo (Architect):** New `scripts/fighters/sprites/` module. SpriteStateBridge adds polling load (one string comparison per fighter per frame — negligible).
- **Future characters:** Extend `CharacterSprite`, override 8 pose methods, add to palettes array. ~400-500 LOC per character.

**Why:** Procedural art eliminates the external tool dependency for placeholder iteration. The team can tweak proportions, palettes, and poses directly in GDScript without a pixel art editor. The bake-to-PNG path preserves compatibility with AnimationPlayer for production art later.

---

### Documentation & Terminology Clarity (2026-03-09T10:11Z)
**By:** joperezd (via Copilot)
**Date:** 2026-03-09
**Status:** Directive

**What:** All public-facing documentation (wiki, devblog, README) must clearly distinguish between Milestone Gates (M0-M4 within a sprint) and Sprints (Sprint 0 = Foundation, Sprint 1 = Art, etc.). No ambiguity — readers should understand at a glance where the project stands without confusing "M3" with "Sprint 3". Use consistent terminology everywhere.

**Why:** User experienced confusion from docs mixing milestone gate numbers with sprint/phase numbers. This caused incorrect assumptions about project status. Accuracy and clarity in documentation is a top priority.

---

### Sprint Definition of Success (2026-03-09T10:14Z)
**By:** joperezd (via Copilot)
**Date:** 2026-03-09
**Status:** Directive

**What:** Every sprint must have a clear "Definition of Success" — specific, measurable criteria that determine whether the sprint can be closed satisfactorily. This applies retroactively to Sprint 0 and must be defined upfront for all future sprints (Sprint 1+). The criteria should answer: "What must be true for us to close this sprint satisfied?" Not just "tasks done" but quality gates, feel checks, and ship readiness.

**Why:** Without explicit success criteria, sprints drift — you can't tell if you're done or just out of time. The founder wants clarity on what "done" means for each sprint so the team knows the goal and can celebrate when they hit it.

---

### Jango — M1+M2 Retrospective Action Items (2026-03-08)
**Author:** Jango (Lead)  
**Status:** Proposed  
**Scope:** Ashfall — Pre-M3 mandatory fixes

Top 3 action items from post-M2 review:

1. 🔴 **Cherry-pick AI Controller to Main (P0)** — ai_controller.gd (298 LOC) merged to wrong branch. Game has no single-player. Cherry-pick from remotes/origin/squad/7-ai-opponent or recreate PR from main-based branch.
2. 🔴 **Full Integration Pass in Godot (P0)** — All systems built in parallel, no end-to-end validation. Open project, walk Main Menu → Character Select → Fight → KO → Victory → Rematch. File bugs.
3. 🟡 **Add Medium Buttons to Input Map (P1)** — GDD specifies 6-button layout (LP/MP/HP/LK/MK/HK) but project.godot only maps 4 per player. No medium punch/kick. Add p1_medium_punch/kick and movesets.

**Process Change:** No M3 feature work begins until items 1 and 2 complete.

---

### Jango — Solo Role Split (2026-03-09)
**Author:** Joaquín (User)  
**Status:** Active  
**Scope:** Team role clarification — Solo & Mace

**Change:** Solo's role narrowed to pure architecture review. Operational tasks (blocker tracking, branch rebasing, stale issue management) moved to Mace.

**Why:** "Architecture review is deep work" — can't do it well while context-switching to ops. Solo does uninterrupted architecture design. Mace handles transactional ops (check, flag, resolve).

**Authority:**
- **Solo:** Pure architecture review, system design, integration patterns, code structure
- **Mace:** Ops backbone — blocker unblocking, branch validation, issue cleanup, rebase coordination

**Artifacts:** Solo's charter updated, Mace's charter updated, routing.md updated.

---

### Asset Naming Convention (2026-03-09)
**Author:** Joaquín (User)  
**Status:** Active  
**Scope:** Ashfall sprite asset naming

All game assets follow: `{character}_{action}_{variant}.png` in `assets/sprites/{character}/`

- **Characters:** lowercase, no spaces (kael, rhena)
- **Actions:** lowercase, match state names (idle, walk, jump, punch, kick, throw, hit, ko, block)
- **Variants:** attack strength suffix (lp, mp, hp, lk, mk, hk) — omit for non-attacks
- **Spritesheets:** `{character}_{action}_sheet.png`
- **Stages:** `assets/stages/{stage_name}/{element}.png`

**Why:** M3 will have Nien creating sprites while Chewie/Lando reference them in code. Shared naming prevents integration friction.

---

### Solo — Final Verification (2026-03-09)
**Agent:** Solo (Architect and Integration Gatekeeper)  
**Date:** 2026-03-09  
**Commit:** 05eafc6 (main, post-PR #28 + #32 merge)  
**Verdict:** **FAIL** ⛔ — 6 blocking issues prevent M3 launch

**Blocking Issues:**
1. **RoundManager Not Instantiated** — System exists (117 LOC) but never added to autoloads or fight_scene.tscn. No round timer, no "FIGHT!" announcement, no KO detection.
2. **Orphaned Combo Signals** — hit_confirmed and combo_ended defined in EventBus, connected in VFXManager, but never emitted anywhere. Combo counter has no data source.
3. **VFXManager Signal Orphans** — Defined connections to hit_confirmed / combo_ended / knockback_applied / player_blocked but systems don't emit them.
4. **Scene Initialization Order** — fight_scene.gd doesn't call round_manager.start_match(). Round system never activates.
5. **Autoload Registration Missing** — RoundManager should be registered as autoload (5th after SceneManager) per SKILL reference pattern.
6. **Null Safety Issues** — 8 get_node() calls lack null checks. Will crash if scene structure diverges.

**Root Cause:** Systems built but not wired together. Integration validation never ran before merge.

**Why This Matters:** Architecture looks solid on paper. Wiring is the gap. Next project: integration testing before milestone gate.

---

### Mace — GitHub Operations Setup (2026-03-08)
**Author:** Mace (Producer)  
**Status:** Implemented  
**Scope:** GitHub-centric project operations for FirstFrameStudios

What Was Done:

1. **README.md Development Section** — Links to Issues, Project, Wiki, workflow diagram, CONTRIBUTING.md
2. **CONTRIBUTING.md Created** — Complete workflow:
   - Branch naming: `squad/{issue-number}-{slug}`
   - Commit format with examples
   - Label system explanation (game, squad, type, priority, status)
   - How Squad agents pick up work (via labels)
   - PR process, code review standards, 20% load cap
3. **team.md Updated** — Issue Source section (jperezdelreal/FirstFrameStudios, game:ashfall filter for current sprint)
4. **GitHub Wiki Status** ⏳ — Wiki cannot be enabled via API. Manual action required: joperezd must enable in repo settings

**Why:** Centralized visibility, clear workflow, scalability, governance, discoverability.

**Decisions Made:**
- Label-driven work allocation (Squad agents query GitHub Issues by label, not manual assignment)
- Branch naming ties to issues (squad/{issue-number} enables auto-linking)
- Wiki optional, not critical (processes in CONTRIBUTING.md; Wiki hosts GDDs/ARCHs separately)
- Load cap governance in CONTRIBUTING.md (team understands 20% rule)
- Game-tagged filtering (game:ashfall current sprint, future games follow same model)

**Risk Mitigation:**
- Wiki not enabled immediately? No impact; critical docs in repo.
- Squad agents don't find issues? Daily standup in #ashfall clarifies ownership.
- Load cap enforcement? Mace monitors daily, blocks merges if agent exceeds 20%.

**Follow-Up Actions:**
- [ ] joperezd: Enable Wiki in repo settings
- [ ] joperezd: Create Wiki home page
- [ ] Solo: Train agents on branch naming + commit format
- [ ] Jango: (Optional) GitHub Actions validator for branch names
- [ ] Mace: Begin daily #ashfall standup

---

### Mace — Dev Diary Post Process (Post-Milestone)
**Author:** Mace (Producer)  
**Decision:** Create Dev Diary discussion post after each milestone

**Process:**
1. **Timing:** Post within 24 hours of milestone completion
2. **Category:** "General" discussion category
3. **Title Format:** `🔥 Dev Diary #X: [Milestone Title]` (e.g., "#2: Character Sprites & Polish")
4. **Content:** Pitch, What We Shipped, By The Numbers, What's Next, The Meta, CTA
5. **Tone:** Passionate, transparent, indie dev blog + behind-the-scenes documentary. NOT corporate.
6. **Visibility:** Public-facing marketing for First Frame Studios. Every post reminds readers this is AI-powered dev.

**Integration with Wiki:**
- Update `.squad/wiki/milestones.md` after each milestone
- Link Dev Diary discussion from milestone entry
- Track discussion URL for metrics

---

### Mace — Issue Creation Discipline (2026-03-09)
**Author:** Joaquín (User)  
**Decision:** All agents must create GitHub issues immediately when they find bugs, blockers, or unresolved questions

**Why:** Post-mortems revealed known problems never tracked. Tarkin's AI controller sat on dead branch with no issue. Solo's overload surfaced only in ceremony. Issues at discovery time, not retroactively.

---

### User Directives — March 8-9, 2026

#### 2026-03-08T12:42:49Z: GitHub-First Development
**By:** Joaquín (User)  
**What:** Use GitHub's full potential — Issues for task tracking, Projects for boards, PRs for code review. No empty repo; everything active and visible.

#### 2026-03-08T18:01:00Z: Joaquín Never Reviews Code
**By:** Joaquín (User)  
**What:** Joaquín is NOT a code reviewer. Jango (Lead) handles all PR reviews. Founder focuses on vision, not implementation.

#### 2026-03-08T18:05:00Z: Wiki Auto-Update Post-Milestone
**By:** Joaquín (User)  
**What:** Wiki updates automatically after each milestone as part of dev cycle. Mace responsibility. Integrate in post-milestone flow.

#### 2026-03-08T18:10:00Z: Dev Diary Auto-Post
**By:** Joaquín (User)  
**What:** El devlog (GitHub Discussions) se publica automáticamente tras cada milestone, igual que la wiki. Responsabilidad de Mace. No se pide manualmente.

#### 2026-03-08T21:22:00Z: Jango Unlimited on Tooling
**By:** Joaquín (User)  
**What:** Jango (Lead) has NO 20% bandwidth limit. Full freedom to propose and create tools, scripts, automations. Not just reviewer — tool engineer with carte blanche.

#### 2026-03-09T09:15:31Z: Backlog Automation, Team Autonomy, Role Overload
**By:** Joaquín (User)  
**What:** 
1. Backlog sync must be automated (CI/CD) — scan code for TODOs, docs for undocumented items, auto-create issues
2. Lead autonomy on bandwidth — Jango adjusts workload distribution independently, no CEO approval needed
3. Auto-wiki/devblog updates — Implement Jango's proposed automation
4. Solo overloaded — needs role split (architecture review ≠ ops tasks)
5. ADRs and integration testing — Evaluate and implement Solo's proposals

---

### Art Direction Lock — Sprint 1 M0 (Boba)

**Author:** Boba (Art Director)  
**Date:** 2026-03-09  
**Status:** Active  
**Scope:** Ashfall — all visual output

## Decision

Art direction for Ashfall is formally locked in `games/ashfall/docs/ART-DIRECTION.md` (PR #113, Issue #102).

## Key Visual Rules (Team-Binding)

1. **Silhouette First** — Characters must be identifiable by outline alone at 64×64px. Binary pass/fail.
2. **Accent color = identity** — Kael is blue (`#4073D9`), Rhena is orange (`#F28C1A`). This applies to VFX, damage numbers, ember aura, and any future UI elements.
3. **No pure black/white** — Darkest allowed: `#0D0D1A`. Brightest allowed: `#E0DBD1`. Keeps everything in the warm volcanic world.
4. **P1 palettes are canon.** P2 exists only for mirror matches.
5. **Procedural art only** — All character rendering is `_draw()` code. No external PNG sprites for fighters.
6. **Stage escalation is mandatory** — EmberGrounds must visually transform across rounds (Dormant → Warming → Eruption).
7. **VFX is character-tinted** — Hit sparks, KO bursts, damage numbers, and flash colors must use the attacker's character palette.
8. **Animation timing must match frame-data.csv** — No visual-only timing. If LP is 4+2+6 frames, the sprite must complete in exactly 12 frames at 60fps.

## Impact

- Nien, Leia, Bossk, Chewie all reference this document for their Sprint 1 deliverables
- Mace enforces naming convention and palette compliance at PR review
- No visual changes without Art Director sign-off after this lock

## Why

Art direction lock prevents rework. Sprint 1 has 4 parallel workstreams (sprites, stage, VFX, animation). If visual direction shifts mid-sprint, all 4 streams must restart. Locking early is the single highest-leverage production decision for art phase.

---

### Decision: Frame Data Authority and Base .tres Consolidation (Lando)

**Author:** Lando (Gameplay Developer)  
**Date:** 2026-03-09  
**Context:** Issues #108, #109, #110 — Sprint 1 playtest frame data bugs

## Decision

**Character moveset .tres files are the authoritative runtime source for frame data.** Base .tres files (fighter_base/, attack_state/) are reference/validation data only.

## Rationale

- fighter_base/ and attack_state/ contain identical data — redundancy invites drift
- Character movesets already contain character-specific tuning (e.g., Rhena HP active=5f vs Kael HP active=4f)
- FighterMoveset.get_normal() is the runtime lookup path — base .tres are never loaded at runtime

## Recommendation

1. Consolidate fighter_base/ and attack_state/ into a single directory (or remove one)
2. Add a validation script that checks character moveset values against GDD ranges
3. Consider auto-generating base .tres from frame-data.csv to prevent manual drift

## Impact

- Affects: Chewie (state machine references), Tarkin (animation frame data), Yoda (GDD updates)
- No runtime behavior change — this is a data organization decision

---

### Solo — Signal Wiring Validator Standards (2026-03-09)
**Author:** Solo (Lead / Chief Architect)  
**Status:** Implemented (PR #89)  
**Scope:** Ashfall project — all agents writing GDScript

**Decisions:**

1. **Godot built-in signals are excluded** from signal wiring validator. Signals like `area_entered`, `pressed`, `timeout`, `value_changed` emitted by engine should never be flagged as orphaned.

2. **Test files are excluded** from signal analysis. Test scripts use engine signals on programmatic UI and emit legacy test-only signals not part of game signal graph.

3. **Every EventBus signal must have both emitter and consumer.** Defining a signal on EventBus is not enough — must be `.emit()`ed somewhere and `.connect()`ed somewhere, or validator fails CI.

4. **integration-gate.py JSON report treats signal warnings as non-fatal,** matching console behavior. Prevents CI/console status divergence.

**Impact:**
- All agents must wire both sides of any new EventBus signal before merging
- Jango should update signal-related templates to include wiring reminders
- Future signals added to EventBus without emitters/consumers caught in CI

**Why:** Validator caught real wiring gaps (6 orphaned signals) mixed with false positives (4 Godot built-ins). Separation ensures CI catches real issues without noise.

---

### Sprint Structure & Terminology (2026-03-09) — Mace (Producer)

**Status:** APPROVED & DOCUMENTED

**Problem:** Terminology confusion between Milestone Gates (M0-M4) and Sprints. Causes ambiguous planning.

**Solution:** 
- **Milestone Gates** = checkpoints within a sprint
- **Sprints** = major work phases (Art Phase, UI Phase, Audio Phase)

**Key Decisions:**
1. Each sprint has M0-M4 milestone gates
2. M4 = ship criteria
3. Scope lock at sprint start

**Ashfall Sprint Structure:**
- Sprint 0: Foundation (shipped)
- Sprint 1: Art Phase (in progress)
- Sprint 2: UI/UX
- Sprint 3: Audio + VFX
- Sprint 4+: Polish & Expansion

---

### Sprint 1 (Art Phase) Kickoff Decision (2026-03-10) — Mace (Producer)

**Status:** ✅ APPROVED

**Decision: Sprint 1 Scope is LOCKED**

**What's IN Scope:**
1. Character Sprites (Nien) — Kael & Rhena, ~45 states each
2. Stage Background (Leia) — EmberGrounds 3-round progression
3. Art Direction (Boba) — Silhouettes, palettes, animation timing
4. Character VFX (Bossk) — Kael embers, Rhena bursts
5. AnimationPlayer Integration (Chewie) — Sprite loading, animation wiring
6. Visual Playtest (Ackbar) — PASS verdict required

**What's OUT of Scope:**
- Audio → Sprint 3
- UI/UX polish → Sprint 2
- Training mode, additional characters → Phase 5+

**Milestone Gates:**
- M0: Art Direction locked
- M1: Sprites drafted
- M2: VFX + AnimationPlayer wired
- M3: Visual integration complete
- M4: Ackbar visual playtest PASS (required to ship)

**Load Analysis:** 140h planned, 96h available. Over by 44h; mitigated via P2 de-scope if bottleneck hits.

---

### Sprint 1 Closure Decision (2026-03-20) — Mace (Producer)

**Status:** COMPLETE — Sprint 1 (Art Phase) Officially Shipped

**Sprint Duration:** 2026-03-10 to 2026-03-20 (10 days)

**PRs Merged (2026-03-20):**
1. PR #103 — Leia: EmberGrounds stage
2. PR #104 — Nien: Fighter animation states (P0+P1)
3. PR #105 — Bossk: Character-specific VFX

**All Milestone Gates Verified:**
- ✅ M0: Art Direction locked
- ✅ M1: Character sprites delivered
- ✅ M2: VFX + AnimationPlayer wired
- ✅ M3: Visual integration complete
- ✅ M4: Ackbar visual playtest PASS

**Quality Gates Passed:**
- ✅ Silhouette test: Kael vs Rhena visually distinct
- ✅ Ackbar playtest: PASS
- ✅ Animation smoothness: Frame-perfect transitions
- ✅ VFX differentiation: Particles identify character
- ✅ P0 bugs: 0 critical issues

**Key Decisions:**
1. P2 De-scope (throw/win/lose deferred to Sprint 2)
2. Parallel execution validated (4 PRs, 0 conflicts)
3. Art direction lock prevented rework
4. Playtesting as gating criterion

**Critical Follow-ups for Sprint 2:**
1. P2 animation states
2. Ackbar playtest notes triage
3. Character select visual upgrade

---

### Ackbar Sprint 1 Visual Playtest Verdict (2026-03-20) — Ackbar (QA Lead)

**Status:** ✅ PASS WITH NOTES

**Verdict:** Sprint 1 art deliverables meet quality bar. All animation states implemented per character with distinct art. VFX wired. Stage escalation functional. AnimationPlayer integrated. Characters visually distinct.

**Three P1 Issues Require Follow-up:**

1. **P1-001:** MP/MK startup frames 1f faster than GDD spec. Must align before combo tuning.

2. **P1-002:** Medium attacks missing from character moveset .tres. Only 6 moves per character.

3. **P1-003:** Frame data drift between base .tres and character .tres (HP: 10f vs 12f).

**Impact:**
- Yoda: Review GDD frame data vs implementation
- Solo/Chewie: Resolve .tres source authority
- Mace: Track P1 issues as Sprint 2 blockers

**Rationale:** PASS WITH NOTES acceptable per SPRINT-1-SUCCESS.md. All follow-ups documented.

---

### 2026-03-09T1247Z: User Directive — Viewport Resolution

**By:** joperezd (via Copilot)  
**Status:** IMPLEMENTED

**What:** Viewport should be 1920x1080 (1080p), not 720p.

**Why:** 1280x720 is too low for 2026 standards. 1080p provides better visual clarity for fighting game.

**Implementation:** `games/ashfall/project.godot` [display] section updated:
- `viewport_width`: 1280 → 1920
- `viewport_height`: 720 → 1080

**Status:** Complete.

---

### 2026-03-09T1253Z: User Directive — Auto-Release at Sprint End

**By:** joperezd (via Copilot)  
**Status:** PENDING IMPLEMENTATION

**What:** Releases should happen automatically at sprint end. When a sprint is shipped (tagged `sprint-N-shipped`), a versioned release (v0.N.0 or similar) should be created automatically with the built .exe.

**Why:** Zero-friction release flow tied to sprint cadence. Founder wants automatic versioning tied to sprint milestones.

**Implementation Approach:** 
- GitHub Actions workflow triggers on `sprint-N-shipped` tag push
- Automatically creates v0.N.0 release
- Builds .exe and attaches to release
- Integrates with existing godot-release.yml

**Status:** Captured for team memory. Requires workflow expansion after Sprint 1.



---

### 2026-03-09T1257Z: User Directive — Release Naming Convention

**By:** joperezd (via Copilot)

**What:** All releases (tags and downloadable GitHub Releases) must always reference the game name and version. 

**Format:**
- Tag: {game}-v{version} (e.g., shfall-v0.1.0)
- Release Title: {Game} v{version} (e.g., Ashfall v0.1.0)
- Zip: {Game}-v{version}-{platform}.zip (e.g., Ashfall-v0.1.0-windows.zip)

**Why:** User request — captured for team memory. The repo (FirstFrameStudios) may host multiple games, so releases must be unambiguous about which game they belong to.

**Governance:** Enforce in GitHub Actions workflows and release notes templates.

---

### 2026-03-09T1150Z: Build Pipeline — Automated Godot Releases (Jango)

**Status:** IMPLEMENTED — PR #111

**What:** Complete build pipeline architecture for Ashfall:

**Workflow:**
1. Developer pushes version tag (e.g., shfall-v0.1.0) to GitHub
2. GitHub Actions workflow triggers: .github/workflows/godot-release.yml
3. CI installs Godot 4.6 + export templates
4. Exports Windows .exe from games/ashfall/ directory
5. Creates GitHub Release with downloadable zip package

**Key Decisions:**
1. **Export Presets Versioned** — games/ashfall/export_presets.cfg committed to git (non-standard, but necessary for CI/CD reproducibility)
2. **Manual Godot Installation** — wget for explicit Godot 4.6 version control
3. **Tag-Triggered Releases** — Tag format {game}-v{version} per release naming directive
4. **Windows Desktop Only** — Initially. Linux/Mac/Web can be added later.
5. **Cross-Compilation on Ubuntu** — Linux runner exports Windows .exe for broad platform compatibility

**Architecture:**
`
Tag push (ashfall-v0.1.0) 
  → GitHub Actions detected
  → Download Godot 4.6 + templates
  → Export to .exe 
  → Package as zip 
  → Create GitHub Release with download
`

**Deliverables:**
- games/ashfall/export_presets.cfg — Windows Desktop export preset (Godot 4.6)
- .github/workflows/godot-release.yml — Automated build + release workflow
- Root .gitignore updated to allow export_presets.cfg, ignore builds/

**Impact:**
- Developers: Create releases by pushing tag (zero friction)
- Players: Download and play without Godot installed
- QA: Manual workflow dispatch for testing
- Future: Pipeline reusable template for additional projects

**Next Steps:**
- Test manual workflow dispatch
- Create v0.0.1-test tag to validate build output
- Document release process for team

# Decision: Sprite Art Brief Revised with Web Research

**Author:** Boba (Art Director)  
**Date:** 2026-03-10  
**Status:** Proposed  
**Scope:** Ashfall sprite production pipeline

## What Changed

Revised `games/ashfall/docs/SPRITE-ART-BRIEF.md` based on web research per founder directive ("que se informen bien de lo que implica este cambio").

### Key Revisions

1. **Canvas: 256×256 → 512×512.** Web research confirms 512 is the industry sweet spot for AI sprite generation. 256 is only for NES/SNES-era retro art. Joaquín's original instinct was correct.

2. **New Section 0 (Research & Best Practices).** Covers resolution standards, character consistency techniques, industry sprite count benchmarks, and the proven ControlNet + LoRA + img2img workflow.

3. **New Section 5 (FLUX on Azure: Capabilities & Limitations).** Honest assessment: our Azure deployment supports text-to-image ONLY. No ControlNet, no img2img, no LoRA, no seed control. All proven consistency techniques are unavailable.

4. **New Section 6 (Tool Evaluation).** Head-to-head comparison of FLUX on Azure vs Local SD + ComfyUI. Local SD is objectively superior for character consistency. FLUX advantage is zero setup + newer model.

5. **Infrastructure Decision Gate.** Added after P0 in production pipeline: if >30% of frames need regeneration due to consistency drift, we should evaluate pivoting to local SD + ComfyUI.

6. **Frame Count Analysis.** Our ~600 frames/character is in the Guilty Gear range. Ambitious but achievable — if we have the right tools.

## Decisions Requiring Founder Input

1. **Confirm 512×512** — Now aligned with research. No objection expected.
2. **After P0:** Evaluate consistency results and decide whether to continue with FLUX on Azure or invest in local SD + ComfyUI setup.
3. **Hybrid approach option:** Use FLUX for reference frames → train LoRA locally → use ComfyUI for production. Best of both worlds but requires GPU hardware.

## Impact on Team

- All agents referencing sprite dimensions must use 512×512
- Production timeline unchanged for P0 (same 48 frames, same generation process)
- Potential infrastructure pivot after P0 if consistency is unacceptable

## Why This Matters

The founder asked us to research before building. He was right. Without this research, we would have attempted 1,200 frames of prompt-only generation with no proven path to character consistency — and discovered the problem after weeks of wasted effort. Now we know the risks upfront and have a decision gate to course-correct early.


---

### 2026-03-09T210032Z: FLUX deployment status
**By:** joperezd (via Copilot)
**What:** Solo FLUX 1.1 Pro está desplegado actualmente. Los otros 3 modelos (Kontext Pro, FLUX 2 Pro, FLUX 2 Flex) pueden desplegarse en Azure AI Foundry y crear variables de entorno de sistema para cada uno. Despliegue pendiente antes de empezar producción de sprites.
**Why:** User input — estado real de infraestructura. No asumir que los modelos están disponibles hasta que Joaquín los despliegue.


---

### 2026-03-09T205438Z: Full FLUX model arsenal available
**By:** joperezd (via Copilot)
**What:** Four FLUX models available on Azure AI Foundry:
1. FLUX 1.1 Pro — text-to-image, 30 tokens/min
2. FLUX 1 Kontext Pro — text+image editing with CHARACTER CONSISTENCY, rate limit TBD
3. FLUX 2 Pro — text-to-image + img2img, 4/min
4. FLUX 2 Flex — text-to-image + img2img + NATIVE ControlNet + inpainting, rate limit TBD
**Why:** User input — complete model inventory for art sprint tool evaluation.


---

### 2026-03-09T205742Z: Complete FLUX rate limits confirmed
**By:** joperezd (via Copilot)
**What:** Rate limits confirmados para todos los modelos FLUX en Azure AI Foundry:
- FLUX 1.1 Pro (text-to-image): 30/min
- FLUX 1 Kontext Pro (text+image ref, character consistency): 30/min
- FLUX 2 Pro (text-to-image + img2img): 4/min
- FLUX 2 Flex (text + img2img + ControlNet nativo + inpainting): 4/min
**Why:** User input — rate limits finales para planificación de producción.


---

### 2026-03-09T212435Z: FLUX API validated — Entra ID auth works
**By:** joperezd + Squad (via Copilot)
**What:** FLUX 1.1 Pro API call validated successfully. Auth: Entra ID Bearer token (az account get-access-token --resource https://cognitiveservices.azure.com). API key auth disabled by org Azure Policy. BFL native path: providers/blackforestlabs/v1/flux-pro-1.1?api-version=preview. Response: 121KB PNG in b64_json. Sprint de arte desbloqueado para FLUX 1.1 Pro.
**Why:** Validation confirmed — pipeline is functional. Next: deploy Kontext Pro, FLUX 2 Pro, FLUX 2 Flex.


---

### 2026-03-09T205112Z: FLUX 2 Pro disponible con img2img
**By:** joperezd (via Copilot)
**What:** Además de FLUX 1.1 Pro (text-to-image, 30 tokens/min), hay disponible FLUX 2 Pro que soporta text-to-image E image-to-image. Rate limit: 4 calls por minuto.
**Why:** User input — cambia fundamentalmente la evaluación de herramientas. img2img permite propagación de consistencia entre frames sin necesitar ControlNet/LoRA.


---



---

### Sprite PoC Test Viewer (Chewie)
**Author:** Chewie (Engine Developer)  
**Date:** 2026-03-09  
**Status:** Implemented  
**Scope:** Test tooling — games/ashfall/scenes/test/ and games/ashfall/scripts/test/

Created a standalone test scene (sprite_poc_test.tscn + sprite_poc_test.gd) that loads and displays the PoC sprites generated for Kael. Plays idle (8fps), walk (10fps), and LP (60fps) animations over the Embergrounds background with keyboard controls.

**Files Created:**
- games/ashfall/scenes/test/sprite_poc_test.tscn — Minimal Node2D scene
- games/ashfall/scripts/test/sprite_poc_test.gd — All logic, data-driven animation config

**Design Choices:**
1. **Fully programmatic scene** — Script creates all nodes in _ready(). The .tscn is just a root Node2D with the script attached. Zero manual editor work needed; easy to diff and review.
2. **Data-driven ANIM_CONFIG** — Adding new animations (walk_back, MP, HP, etc.) requires only a new dictionary entry and the PNG files. No code changes.
3. **Runtime texture filter** — Set TEXTURE_FILTER_NEAREST on the AnimatedSprite2D node instead of modifying .import files. Keeps the viewer self-contained without affecting other scenes that might use these assets.
4. **Center-bottom origin** — offset = Vector2(0, -256) so the node position represents feet. Matches fighting game convention where character position = ground contact point.
5. **LP auto-return** — Non-looping animations return to idle via nimation_finished signal, driven by the loop flag in config.
6. **Scale 0.4** — Renders the 512×512 sprite at ~205px on a 1080p screen. Reasonable fighting game character size. The 30×60 collision box proportions (1:2 ratio) will be handled by the collision system, not the visual scale.

**How to Run:**
Set sprite_poc_test.tscn as the main scene in Godot editor (Project → Project Settings → Run → Main Scene), or run it directly via Scene → Run Current Scene (F6) with the scene open.

**Impact:**
Test-only. No production code affected. No autoloads required (the viewer is self-contained). Other agents can use this pattern for future sprite/animation test viewers.

**Why:** Validates FLUX sprite generation pipeline. Establishes data-driven animation pattern for Ashfall test suite. Enables visual iteration without manual sprite sheet assembly.


---

## Nien (Character Artist) — v2 Frame Generation
# PoC v2 Animation Frames — Complete

**Author:** Nien (Character Artist)  
**Date:** 2026-07-08  
**Status:** Complete  
**Scope:** Ashfall PoC v2 animation frames

## Summary

Generated 56 animation frames (28 per character) for Kael and Rhena using Kontext Pro with approved hero designs as input_image references. All frames saved to `games/ashfall/assets/poc/v2/` with RGBA transparency.

## Frames Generated

| Character | Action | Frames | Status |
|-----------|--------|--------|--------|
| Kael      | Idle   | 8      | ✅ All clean |
| Kael      | Walk   | 8      | ✅ All clean |
| Kael      | LP     | 12     | ✅ All clean |
| Rhena     | Idle   | 8      | ✅ All clean |
| Rhena     | Walk   | 8      | ✅ 3 required retry (content filter) |
| Rhena     | LP     | 12     | ✅ All clean |

## v1 Fixes Applied

1. **Walk leg alternation:** Each walk frame prompt explicitly specifies which leg is forward/back (e.g., "RIGHT foot forward, LEFT foot behind"). This addresses the v1 sliding/moonwalk issue.
2. **LP kata vocabulary:** All attack prompts use martial arts kata language instead of combat words. Zero content filter rejections across 24 LP frames.
3. **Approved hero references:** Used `kael_design_b.png` and `rhena_design_c.png` as Kontext Pro input_image, improving character consistency over v1.

## Post-Processing

- Green chroma key backgrounds removed with widened tolerance (handles dark/olive greens)
- Corner-based fallback detection for non-standard background colors
- All 56 frames verified RGBA with >5% transparent pixels
- Contact sheets: `contact_v2_kael.png`, `contact_v2_rhena.png`

## API Details

- **Deployment:** `flux.1-kontext-pro` (lowercase with dots)
- **Auth:** Bearer token via `az account get-access-token`
- **Rate:** 2.5s delay between calls, ~56 calls completed in ~4 minutes
- **Size:** 1024×1024 per frame

## Impact

- PoC v2 frames ready for founder review
- Walk cycle fix addresses primary v1 feedback
- Pipeline proven for future character animation generation


---

## 2026-03-10T08:55Z: User Directive — Audio Model Deployed
### 2026-03-10T08:55Z: User directive — Audio model deployed
**By:** Joaquín (via Copilot)
**What:** GPT-Audio-1.5 deployed on Azure AI Foundry for audio generation. Rate limit: 90,000 requests/min (extremely generous). Available for Sprint 3 (Audio) when ready.
**Why:** Founder deployed a new model for future audio sprint. Captured for team memory so Greedo (Sound Designer) knows what's available.


---

## Pipeline & Art Direction Decisions

### V2 Animation Consistency Audit (Boba)
**Author:** Boba (Art Director)  
**Date:** 2025-01-27  
**Status:** 🔴 CRITICAL FAILURE

**Executive Summary**

Joaquín's assessment is 100% correct. V2 frames are unusable for animation. Each frame looks like a different character — fundamentally incompatible with frame-by-frame animation which requires consistency between frames.

**V1 Analysis: KAEL IDLE (8 frames)**

| Metric | Score | Notes |
|--------|-------|-------|
| **Character Identity** | 10/10 | Same face, same proportions, same person across all 8 frames |
| **Outfit Consistency** | 10/10 | Identical grey-white gi, dark belt, brown boots, arm wraps |
| **Color Palette** | 10/10 | Exact same hex values frame-to-frame |
| **Pose Readability** | 9/10 | Clear breathing cycle, smooth transitions implied |

**V1 TOTAL: 39/40 — Production-ready**

**V2 Analysis: KAEL (28 frames, 3 rows)**

| Metric | Score | Notes |
|--------|-------|-------|
| **Character Identity** | 2/10 | Different faces, different body types. Frame 1 and Frame 5 are NOT the same person. |
| **Outfit Consistency** | 1/10 | Red gi → green gi → brown gi → purple gi → grey gi. Belt: yellow → orange → purple → red → blue. No two frames match. |
| **Color Palette** | 1/10 | Complete chaos. 7+ different outfit colors in Row 1 alone. |
| **Pose Readability** | 3/10 | Poses exist but you'd never notice them over the color/identity changes |

**V2 KAEL TOTAL: 7/40 — Unusable**

**V2 RHENA TOTAL: 7/40 — Unusable**

**Root Cause Analysis**

The v2 process appears to have:

1. **No reference anchoring** — Each frame generated independently without enforcing the previous frame's appearance
2. **High variation sampling** — The AI model was likely allowed too much creative freedom per-frame
3. **No color palette lock** — Hair, outfit, belt colors re-rolled each generation
4. **No identity preservation** — Face and body treated as "character" concept rather than "this specific character"

**V1 succeeded because:** Likely used stronger reference conditioning or multiple passes with same seed/parameters.

**Impact Assessment**

Can V2 be animated? **NO.** Playing these frames sequentially would create a flickering nightmare.

Can V2 be salvaged? **Maybe partial.** If we cherry-pick only frames that match (maybe 3-4 per character). But honestly? **Start over with v1's methodology.**

**Recommendations**

1. **Immediate:** Abandon v2 approach. Do not invest more time in this direction.
2. **V3 Direction:** Return to v1's methodology. Whatever constraint/conditioning made v1 consistent, restore it.
3. **Process Change:** Before generating 28 frames, generate 3 and verify consistency. Fail fast.
4. **Scope Reduction:** Maybe we don't need 28 frames per animation. V1's 8 frames looked great. Quality > quantity.

---

### Sprite Animation Consistency — Research & Recommendation (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-10  
**Status:** Proposed  
**Triggered by:** Founder (Joaquín) reports v2 animation frames worse than v1. ChatGPT research independently suggests skeleton-based pose conditioning.

**Root Cause Analysis: Why V2 Failed**

Boba's audit confirmed it: V2 scored 7/40 vs V1's 39/40. The character looks different in every frame. This is an **architectural failure** in how we generate frames.

**The fundamental error:** We used Kontext Pro to generate each frame independently from a text prompt. Kontext Pro is an image-editing model — it excels when you give it a source image and say "change this specific thing." We used it like a text-to-image model, asking it to generate "frame 2: anticipation pose" from scratch each time. Without structural conditioning (pose skeleton) or appearance anchoring (reference image fed per-frame), the model re-rolls identity on every generation.

**Why V1 worked:** V1 likely used tighter reference conditioning — same seed, same parameters, minimal pose variation (breathing cycle = subtle). The moment we asked for diverse poses (punches, kicks, jumps across 28 frames), the model had nothing to anchor identity to.

**Core insight:** Text prompts alone cannot enforce visual consistency across frames. You need **structural control** (what pose to take) AND **appearance control** (what the character looks like) as explicit inputs to every frame generation.

**Research Findings: All Viable Approaches**

I conducted 9 independent web searches across FLUX models, ControlNet, academic papers, indie game pipelines, and specialized tools.

**Approach A: ComfyUI + FLUX + ControlNet Pose + IP-Adapter**

How it works: Generate master sprite → create pose skeletons → feed both into ComfyUI with ControlNet (pose mode) and IP-Adapter (appearance locking) → generate each frame conditioned on both pose AND appearance.

**Consistency level:** High (8/10). Remaining 20% variation is in fine details requiring manual QA.

**Complexity:** HIGH. Requires local ComfyUI setup, model downloads (~20GB), workflow configuration, GPU with 12-24GB VRAM.

**Verdict:** This is what the ChatGPT research was pointing at. It's the right direction, but requires FLUX.2 Dev (open weights + ControlNet), NOT our current FLUX 1.1 Pro or Kontext Pro API.

**Approach B: PixelLab (Purpose-Built Tool)**

How it works: PixelLab is an AI tool built specifically for pixel art game assets. Has built-in **skeleton-based animation system** — you define joint positions, it generates consistent frames.

**Consistency level:** High (8/10) for pixel art style. Purpose-built for this exact problem.

**Complexity:** LOW. Web-based tool, no local setup.

**Verdict:** Best option IF our art direction is pixel art. Fast to test, low risk. Worth a spike.

**Approach C: 3D-to-2D Pipeline (Mixamo + Blender → Sprite Render)**

How it works: Get 3D humanoid model (Mixamo free library) → apply fighting animations from Mixamo's mocap library → In Blender: orthographic camera, side view, render each frame as PNG → Use SpriteStar or Spritesheet Renderer addon to batch-export sprite sheets → Post-process in Aseprite/Photoshop for style.

**Consistency level:** PERFECT (10/10). It's the same 3D model in every frame. Consistency is guaranteed by definition.

**Complexity:** MEDIUM. Blender setup is one-time. Mixamo animations are free and immediate.

**Verdict:** Most reliable approach for consistency. Zero AI randomness. Classic technique used by professional studios (Donkey Kong Country, Killer Instinct, many modern indie fighters).

**Approach D & E: Sprite Sheet Diffusion & SaaS Tools**

Sprite Sheet Diffusion (Academic research) and SaaS tools (Spritesheets.AI, AutoSprite, Scenario) are additional options but lower priority.

**Top 3 Alternatives — Ranked by Feasibility**

**🥇 Rank 1: 3D-to-2D Pipeline (Mixamo + Blender)**
- **Why first:** Guaranteed consistency. Zero randomness. Proven in professional fighting games.
- **Time to first result:** 2-4 hours
- **Ongoing cost:** Free (Blender + Mixamo are free)
- **Risk:** Art style gap needs post-processing. But a consistent ugly sprite is infinitely more useful than a beautiful inconsistent one.

**🥈 Rank 2: ComfyUI + FLUX.2 Dev + ControlNet + IP-Adapter**
- **Why second:** Best AI approach. Combines pose control with appearance locking.
- **Time to first result:** 1-2 days
- **Ongoing cost:** GPU time (local) or cloud GPU rental
- **Risk:** Complex pipeline. Requires 12-24GB VRAM. Still has ~20% variation requiring QA.

**🥉 Rank 3: PixelLab (if pixel art style)**
- **Why third:** Purpose-built for exactly this problem, but style-locked to pixel art.
- **Time to first result:** 30 minutes
- **Ongoing cost:** SaaS subscription
- **Risk:** Vendor lock-in, pixel art only

**Honest Assessment: Is AI Frame-by-Frame Animation Production-Ready?**

**Short answer: Not yet for fighting games, with our current approach.**

AI-generated sprites are production-ready for: concept art, simple animations with proper pipeline, prototyping, pixel art with dedicated tools.

AI-generated sprites are NOT yet reliable for: complex fighting game animations without structural conditioning, frame-data-precise combat sprites, prompt-only generation.

**My recommendation:** Use AI for concept art and style exploration. Use 3D-to-2D (Mixamo + Blender) for production animation frames. This is what professional indie studios actually do.

**Proposed Next Steps**

1. **Immediate:** Stop generating frames with current approach. It won't improve.
2. **This week:** Boba runs a spike — download Mixamo fighter model, apply punch animation, render 5 frames in Blender, evaluate quality.
3. **This week:** Boba tests PixelLab with Kael's master sprite — 30 min evaluation.
4. **If 3D-to-2D works:** Adopt as primary pipeline.
5. **If we still want AI:** Set up ComfyUI + FLUX.2 Dev + ControlNet locally.
6. **Art direction decision:** Yoda + Boba align on pixel art (PixelLab-friendly) vs cel-shaded (needs 3D-to-2D or ControlNet pipeline).

---

### Decision: 3D-to-2D Sprite Pipeline via Mixamo + Blender (Chewie)
**Author:** Chewie (Engine Dev)  
**Date:** 2026-07-22  
**Status:** Proposed (Spike complete, awaiting founder validation)  
**Scope:** Ashfall art pipeline — sprite generation for all characters

**Context**

AI sprite generation (Kontext Pro / FLUX) failed for animation frames. Individual frames looked great but had zero frame-to-frame consistency. Unusable as actual game animation.

The team researched alternatives. Top recommendation: **3D-to-2D pipeline using Mixamo (free 3D models + animations) + Blender (automated rendering).**

**Decision**

Adopt a 3D-to-2D sprite rendering pipeline:

1. **Source:** Free Mixamo models + animations (FBX format, manual download — no API)
2. **Render:** Blender 4.x Python script, CLI-driven, orthographic camera, transparent PNG output
3. **Style:** Cel-shade toon shader (Shader-to-RGB + ColorRamp) for 2D fighting game look
4. **Output:** Individual frames as {character}_{animation}_{NNNN}.png at 512×512

**What Was Built (Spike)**

| File | Purpose |
|---|---|
| games/ashfall/tools/blender_sprite_render.py | Main render script — FBX import, camera, lighting, frame rendering, contact sheet |
| games/ashfall/tools/cel_shade_material.py | Toon material toolkit with character presets (kael, rhena) and outline support |
| games/ashfall/tools/BLENDER-SPRITE-PIPELINE.md | Full documentation — prerequisites, step-by-step guide, customization, troubleshooting |

**Why**

| Criterion | AI Generation | 3D-to-2D Pipeline |
|---|---|---|
| Frame consistency | ❌ Zero | ✅ Perfect (same mesh) |
| Animation flow | ❌ Frames don't connect | ✅ Mocap-driven, smooth |
| Style control | ⚠️ Prompt-dependent | ✅ Material/shader control |
| Cost | ✅ Pay per generation | ✅ Free (Mixamo + Blender) |
| Speed per character | ✅ Fast | ⚠️ Setup time, then fast batch |

**Next Steps**

1. **Founder validates spike** — Download one Mixamo model, run the script, check output quality
2. **If validated:** Render full Kael animation set (idle, walk, all attacks, hit, KO)
3. **If validated:** Render Rhena with different preset colors
4. **Long-term:** Consider custom 3D models (replace Mixamo with bespoke characters)

**Risks**

- Mixamo models are generic — may need custom modeling later for unique character identity
- Blender must be installed on dev machines (it is — founder confirmed)
- FBX import quality varies — some Mixamo rigs need manual cleanup

---

### V2 Frames REJECTED — Pipeline Pivot Directive (2026-03-10T09:27Z)
**By:** Joaquín (via Copilot)

v2 animation frames are WORSE than v1. Zero consistency between frames — each frame looks like a different character. Kontext Pro cannot maintain character identity across different poses via text prompts alone. Founder says "no veo que estemos avanzando".

**New approach needed:** pose conditioning with skeleton images (per ChatGPT research). Stop generating frames until pipeline is redesigned with pose conditioning.

**Why:** Critical quality failure. Current approach of text-only pose descriptions to Kontext Pro is fundamentally flawed for animation frames. Need skeleton/ControlNet conditioning via FLUX 2 Flex or equivalent.


---

### Art Style Direction — Pixel Art Target (2026-03-10T10:15Z)
**By:** Joaquín (via Copilot)

**What:** Visual target is Street Fighter pixel art style (Ryu). Classic 2D fighting game sprites with hand-drawn pixel art look. Not generic 3D, not cel-shade — pixel art like SF2/SF3.

**Why:** Founder defined the visual target for production sprites. This constrains art pipeline choices: either pixel-art post-processing on 3D renders, PixelLab SaaS, or stylized 3D models rendered to look like pixel art.

**Impact:** Clarifies Rank 3 (PixelLab) becomes viable alternative. 3D-to-2D with pixel-art post-processing is primary path. Confirms this is NOT high-res cel-shade.

# Decision: Free 3D Model Selection for Ashfall Character Pipeline

**Date:** 2026-01-09  
**Decision Maker:** Boba (Art Director)  
**Category:** Asset sourcing  
**Priority:** High (blocks character sprite production)

---

## Context

The Mixamo Y-Bot default mannequin lacks personality. Founder directive: "yo no quiero unos maniquies feos, quiero que sean personajes" (I don't want ugly mannequins, I want characters).

**Constraint:** Zero budget — must use free models.  
**Target Characters:** Kael (fire monk, orange palette) + Rhena (ice warrior, blue palette)  
**Pipeline:** Existing Mixamo FBX → Blender cel-shade render → 512×512 PNG

---

## Decision

### Primary Recommendation
**Use Quaternius (Kael) + RenderHub Liv (Rhena) as base models.**

**Rationale:**
1. **Quaternius (Kael)**
   - CC0 license (zero IP complications)
   - Rigged for animation, FBX export ready
   - Stylized aesthetic aligns with cel-shade look
   - Game-tested across 500+ indie titles
   - Customization path clear: recolor orange, add cloth wraps
   - Estimated effort: 8-12 hours Blender work

2. **RenderHub Liv (Rhena)**
   - Designed specifically for fighting games
   - Female-form character (matches Rhena brief)
   - Pre-rigged, Mixamo-compatible
   - Silhouette already combat-ready
   - Customization path clear: recolor blue, enhance armor
   - Estimated effort: 8-10 hours Blender work

3. **Both Models**
   - FBX format (native to our pipeline)
   - Mixamo skeleton compatibility (upload for animation library)
   - No format conversion needed
   - Risk level: Low (quality pre-validated)

### Fallback (If Phase 1 evaluation fails)
1. **Ready Player Me** (professional pipeline, higher customization depth)
2. **Kenney Mini Characters** (quality consistency, simpler aesthetic)
3. **OpenGameArt martial arts models** (if Sketchfab/community options emerge)

---

## Alternatives Considered

| Option | Pros | Cons | Rank |
|---|---|---|---|
| **Quaternius + RenderHub** | CC0, game-tested, FBX-ready, low risk | Requires 16-22hr Blender work | ⭐⭐⭐ |
| **Ready Player Me** | Professional, highly customizable, standard rig | GLB→FBX conversion, higher complexity | ⭐⭐ |
| **Kenney** | Extremely consistent, CC0, well-documented | Less personality, higher customization needed | ⭐⭐ |
| **Sketchfab browsing** | Massive variety, unique models | Quality inconsistent, licensing risk, rigging variable | ⭐ |
| **Commission new models** | Perfect fit, original IP | $1000-5000+ cost, violates zero-budget constraint | ✗ |
| **Stay with Y-Bot** | No development time, pipeline proven | Founder rejected; lacks personality | ✗ |

**Conclusion:** Quaternius + RenderHub balance quality, effort, cost, and timeline constraints best.

---

## Implementation Plan

### Phase 1: Evaluation (2 hours)
**Objective:** Validate Blender pipeline and Mixamo compatibility.

1. Download Quaternius fighter + RenderHub Liv (FBX)
2. Import both to Blender (test scene)
3. Run through cel-shade material application
4. Render test PNG at 512×512
5. Upload to Mixamo, validate auto-rig + animation retargeting
6. **Decision Point:** Proceed to Phase 2 or adjust model selection

**Owner:** Boba (Art Director)  
**Timeline:** 2 hours  
**Success Criteria:**
- FBX imports cleanly
- Cel-shade material renders without topology issues
- Mixamo auto-rig succeeds (skeleton recognized)
- Test animation applies correctly

### Phase 2: Customization (16-22 hours)
**Objective:** Customize models to Kael/Rhena specifications.

#### Kael (Quaternius Base) — 8-12 hours
1. Material customization: orange palette (#FF8C00, #FFA500, #FFB347)
2. Model customization:
   - Add cloth wraps (geometry modeling)
   - Remove shoes → barefoot variant
   - Optional: enhance face/features for personality
3. Rig verification: Ensure Mixamo skeleton intact
4. FBX export with armature
5. Upload to Mixamo, tag for "meditation", "punch", "kick" animations
6. Contact sheet generation (4 key poses)

#### Rhena (RenderHub Liv Base) — 8-10 hours
1. Material customization: steel blue palette (#2E5C8A, #4A90E2, #1C3A5F)
2. Model customization:
   - Armor silhouette enhancement (if needed)
   - Adjust color contrast (armor vs. body)
   - Optional: weapon refinement
3. Rig verification: Ensure Mixamo skeleton intact
4. FBX export with armature
5. Upload to Mixamo, tag for "warrior stance", "punch", "kick" animations
6. Contact sheet generation (4 key poses)

**Owner:** Boba (Art Director)  
**Timeline:** 2-3 days elapsed (assuming 4-6 hours/day Blender work)  
**Success Criteria:**
- Contact sheets approved by Founder
- Models match character brief (personality, colors, silhouette)
- Mixamo animations apply cleanly

### Phase 3: Production Rendering (4-6 hours)
**Objective:** Generate full sprite library for Godot.

1. Mixamo animation download (100+ free martial arts animations)
2. Batch render sprites (512×512, RGBA)
3. Sprite sheet generation + naming convention alignment
4. Godot asset import
5. In-game testing + visual QA

**Owner:** Chewie (Engine) + Boba (Art Direction)  
**Timeline:** 1 day  
**Success Criteria:**
- All animations render without artifacts
- Sprite sheets match cel-shade spec (0.008 outline, 2-step shadow)
- In-game appearance matches contact sheets

---

## Resource Requirements

### Software
- **Blender 4.x** (existing; cel-shade material already configured)
- **Mixamo account** (free Adobe tier sufficient)
- **Python script** (existing render pipeline)

### Time Commitment
- **Art Director:** 18-24 hours (Phase 1 evaluation + Phase 2 customization + approval gates)
- **Engine (Chewie):** 2 hours (Phase 3 rendering + Godot import validation)
- **Total:** 20-26 hours

### Cost
- **Models:** $0 (CC0 + free)
- **Software:** $0 (existing licenses)
- **Timeline:** 5-7 days calendar time (assuming 4-6 hr/day work availability)

---

## Approval Gate

**Before Phase 2 begins:** Founder must approve model styles + color palettes from Phase 1 test renders.

**Decision Required:**
1. Quaternius stylized aesthetic acceptable? (vs. more realistic alternatives)
2. RenderHub Liv proportions match Rhena vision?
3. Timeline realistic for project schedule?

---

## Success Metrics

✅ **Phase 1 Complete:**
- Blender pipeline validated for both models
- Mixamo upload/animation retargeting verified
- Test PNG render quality acceptable

✅ **Phase 2 Complete:**
- Contact sheets approved by Founder
- Kael matches orange/cloth aesthetic
- Rhena matches blue/warrior aesthetic
- FBX exports clean (no topology/rig warnings)

✅ **Phase 3 Complete:**
- 100+ martial arts animation sprites rendered
- Godot asset integration successful
- In-game character appearance matches specs

---

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| Quaternius model doesn't customize well to orange | High | Low | Phase 1 testing; fallback to Kenney |
| RenderHub Liv rig incompatible with Mixamo | High | Low | Manual rig adjustment; fallback to CGTrader |
| Blender topology issues during rendering | Medium | Medium | Retopo or model swap; 2-4 hour delay |
| Founder rejects style after Phase 1 | High | Medium | Early approval gate; discuss alternatives now |
| Timeline overruns (Blender work slower than estimated) | Medium | Medium | Pare customization scope; focus on color only |

---

## Decision Record

**Approved By:** Boba (Art Director)  
**Reviewed By:** [Pending Founder feedback]  
**Date Decided:** 2026-01-09  
**Status:** Ready for Phase 1 execution

**Next Action:** Schedule Phase 1 evaluation; present test renders to Founder for style approval before proceeding to Phase 2.

---

## References

- **Research:** `games/ashfall/docs/FREE-3D-MODEL-RESEARCH.md`
- **Quaternius:** https://quaternius.com/characters.html
- **RenderHub Liv:** https://www.renderhub.com/hisqiefurqoni/stylized-female-fighting-character-liv
- **Mixamo:** https://mixamo.com
- **Blender Cel-Shade Pipeline:** `tools/scripts/cel_shade_material.py` (existing)

# Decision: Auto-Screenshot Mode for Sprite Viewer

**Author:** Chewie (Engine Developer)  
**Date:** 2026-10-03  
**Status:** IMPLEMENTED  
**Scope:** Ashfall sprite viewer test tooling

## Context
Joaquín was frustrated by the manual loop: agents tweak sprite viewer code → Joaquín opens Godot → runs scene → reports result. No agent could verify visual output independently.

## Decision
Added a `--screenshot` CLI mode to `sprite_poc_test.gd` that:
1. Parses `OS.get_cmdline_user_args()` for `--screenshot`, `--char=`, `--anim=`
2. Waits 5 render frames, captures viewport to PNG
3. Saves to both `user://screenshot.png` and project root `screenshot.png`
4. Prints paths to stdout and quits

Created `games/ashfall/tools/screenshot.bat` to wrap the Godot CLI call.

## Rationale
- **Zero impact on interactive mode** — `_process()` early-returns when not in screenshot mode
- **Dual save paths** — `user://` is always writable; project root is easy for agents/humans to find
- **Extensible** — same pattern works for any scene; just change `--scene` in the CLI call
- **Agent-friendly** — batch file can be invoked from any automation; stdout confirms paths

## Key Paths
- Script: `games/ashfall/scripts/test/sprite_poc_test.gd`
- Batch: `games/ashfall/tools/screenshot.bat`
- Output: `games/ashfall/screenshot.png`

# Decision: Mixamo Character Sprite Rendering

**Author:** Chewie (Engine Developer)
**Date:** 2025-07-08
**Status:** COMPLETED

## Context

The founder selected two custom Mixamo characters (Kael and Rhena) with real clothing, proportions, and personality — replacing the generic Y-Bot placeholder. These models come with their own materials/textures from Mixamo's character system.

## Decision

**Render with original Mixamo materials (no cel-shade override).**

The pipeline previously used `--cel-shade --preset kael/rhena` to apply monochrome toon shading. For these production characters, we tested rendering WITHOUT cel-shade first — letting the model's own skin, clothing, and hair textures come through EEVEE's standard renderer.

**Result: Original materials render cleanly.** The characters look like themselves, with distinct clothing, skin tones, and hair. No need for the cel-shade fallback.

## Render Summary

| Character | Animation   | Source FBX     | Frames | Step | Output Directory                    |
|-----------|-------------|----------------|--------|------|-------------------------------------|
| Kael      | Idle        | Idle.fbx       | 30     | 2    | sprites/kael/idle/                  |
| Kael      | Walk        | Walking.fbx    | 16     | 2    | sprites/kael/walk/                  |
| Kael      | Punch       | Punching.fbx   | 13     | 5    | sprites/kael/punch/                 |
| Kael      | Kick        | Side Kick.fbx  | 13     | 5    | sprites/kael/kick/                  |
| Rhena     | Idle        | Idle.fbx       | 106    | 2    | sprites/rhena/idle/                 |
| Rhena     | Walk        | Walking.fbx    | 16     | 2    | sprites/rhena/walk/                 |
| Rhena     | Punch       | Hook Punch.fbx | 14     | 5    | sprites/rhena/punch/                |
| Rhena     | Kick        | Mma Kick.fbx   | 13     | 5    | sprites/rhena/kick/                 |

**Totals:** 221 frames rendered, 8 contact sheets generated.

## Notes

- Rhena's idle animation is 106 frames (212 source frames at step=2) — unusually long. May want to trim for in-game use.
- Root motion pinning (mixamorig:Hips X/Y zeroed) worked on all animations — no character drift.
- Renderer: BLENDER_EEVEE (not EEVEE_NEXT), standard 2-light rig (key 3.0 + fill 1.5).
- Contact sheets generated for visual review in each output directory.
- If the art direction later calls for unified cel-shade style, the `--cel-shade --preset` flags remain available.

# Decision: 3D Character Models Downloaded & Tested

**Date:** 2025-07-08  
**Author:** Chewie (Engine)  
**Status:** Results ready for founder review

---

## What Happened

Downloaded free CC0 3D character models and ran them through our Blender cel-shade pipeline.

### Successfully Downloaded (automated)
| Pack | Source | Characters | Format | Size |
|------|--------|-----------|--------|------|
| **Quaternius RPG Pack** | Google Drive | Monk, Warrior, Rogue, Ranger, Cleric, Wizard + weapons | FBX/Blend/glTF | ~15 MB |
| **Kenney Animated Characters 1-3** | kenney.nl | 3× characterMedium + animations | FBX | ~2 MB |
| **Kenney Mini Characters** | kenney.nl | 12 characters (6M/6F) | FBX/GLB | ~2.3 MB |

All saved to: `games/ashfall/assets/3d/characters/`

### Pipeline Test Results

**Quaternius Monk** → **WINNER for Kael base.** Fighting stance with fists raised, chibi proportions, cel-shade looks great. Already animated with combat idle.

**Quaternius Warrior** → Sword character with ponytail and armor. Great silhouette and personality. Animation includes attack sequence.

**Kenney models** → Too generic. Same mannequin problem as Y-Bot. Not recommended.

### Test renders at:
- `games/ashfall/assets/sprites/test_quaternius_monk/` (11 frames + contact sheet)
- `games/ashfall/assets/sprites/test_quaternius_warrior/` (15 frames + contact sheet)
- `games/ashfall/assets/sprites/test_kenney_kael_side/` (Kenney with Kael colors)

---

## Known Limitations

1. **Monochrome rendering** — Our cel-shade pipeline paints everything one color (Kael orange). Clothes, skin, hair all same tone. Needs per-material color work for production.
2. **Animation framing** — Characters with big motion (jumps, swings) can exit the camera frame. Pipeline auto-fit uses frame-1 bounds only.
3. **Mixamo retargeting needed** — Quaternius models have their own animations (idle/attack), but we need Mixamo martial arts library (punch, kick, walk, etc.) for the full moveset.

---

## 30-Second Download Guide (for Joaquin)

### Priority 1: More Quaternius Packs (browser)
These have the best fighting-game characters. Open in browser → click "Download" → save ZIP:

1. **Knight Pack** (animated knight with swords/helmets):
   `https://drive.google.com/drive/folders/1QVyfCJkq70mAwMIh1cGq1xfHp2LN5GmK`

2. **Animated Women** (4 female characters with animations):
   `https://drive.google.com/drive/folders/1c13R--fMqdR6r2MRlcKKsbPky0__T-yJ`

3. **Universal Base Characters** (6 models, 3 body types, 20 hairstyles):
   Visit `https://quaternius.itch.io/universal-base-characters` → click "Download" (free)

Save FBX files to: `games/ashfall/assets/3d/characters/`

### Priority 2: KayKit Adventurers (browser)
5 rigged/animated dungeon characters with 25+ weapons. CC0 license.
1. Visit `https://kaylousberg.itch.io/kaykit-adventurers`
2. Click "Download" → "No thanks, just take me to the downloads"
3. Download the free ZIP
4. Extract FBX files to `games/ashfall/assets/3d/characters/kaykit-adventurers/`

### Priority 3: Mixamo Characters (browser)
Your existing Mixamo account has built-in characters beyond Y-Bot:
1. Go to `https://mixamo.com` → log in
2. Click "Characters" tab (top-left)
3. Try: **Mery** (female), **Big Vegas** (stocky male), **Mutant** (creature)
4. Select any animation → Download as FBX
5. These come pre-rigged — drop directly into pipeline

### Test any FBX in pipeline:
```
"C:\Program Files\Blender Foundation\Blender 5.0\blender.exe" --background --python games/ashfall/tools/blender_sprite_render.py -- --input YOUR_MODEL.fbx --output games/ashfall/assets/sprites/test_output/ --character test --animation idle --size 512 --step 2 --cel-shade --preset kael --outline --contact-sheet
```

---

## Recommendation

**Use Quaternius Monk as Kael's base mesh.** It's already in the repo, already renders through our pipeline, has a fighting stance, and the chibi proportions give it character. Upload to Mixamo for the full martial arts animation set, then customize colors in Blender.

For Rhena, download the Quaternius Animated Women pack or KayKit Adventurers — both have female warrior characters that could work as a base.

# Sprite Pipeline V2 — Root Motion Pinning & Animation-Aware Stepping

**Author:** Chewie (Engine Developer)  
**Date:** 2025-07-23  
**Status:** Implemented  
**Scope:** Ashfall sprite rendering pipeline (`blender_sprite_render.py`)

## Changes Made

### 1. Tighter Camera Framing
- Ortho scale padding: **1.1× → 1.03×** of model bounds
- Character now fills ~97% of the 512×512 frame vs ~90% before
- Still auto-fits; `--ortho-scale` CLI override still available

### 2. Root Motion Pinning (NEW)
- Mixamo animations bake root motion into `mixamorig:Hips` bone
- New `pin_root_motion()` zeros X/Y translation each frame, keeps Z + rotations
- Runs after `frame_set()`, before `render()` — character stays centered
- Auto-detects root bone with fallback chain: mixamorig:Hips → Hips → Root → first parentless bone

### 3. Animation-Aware Frame Stepping (NEW)
- `ANIM_STEP_HINTS` dict maps animation keywords to optimal steps
- Attacks (punch/kick/heavy/special): **step=5** → ~13 frames (was 31 with step=2)
- Loops (idle/walk/run): **step=2** → 16-17 frames (unchanged)
- Auto-applied via `get_smart_step()`; user `--step` still works as override
- Key metric met: **no attack exceeds 15 frames**

## Frame Count Summary
| Animation | Old Frames | New Frames | At 15fps |
|-----------|-----------|------------|----------|
| idle      | 17        | 17         | 1.13s    |
| walk      | 16        | 16         | 1.07s    |
| punch     | 31        | 13         | 0.87s    |
| kick      | 31        | 13         | 0.87s    |

## Impact on Team
- **Art (Boba):** Sprites are larger in frame, centered, and attack timing is game-appropriate. Review contact sheets.
- **Design (Yoda):** Frame data for moves can now reference 13-frame attacks for punch/kick — much snappier feel.
- **Godot integration:** Same output paths, same naming convention. Just re-import the updated PNGs.
- **Future characters:** Pipeline auto-handles any Mixamo FBX — root motion pinning and smart stepping are automatic.

# PNG Sprite Integration into CharacterSprite

**Author:** Chewie (Engine Developer)  
**Date:** 2026-07-24  
**Status:** Implemented  
**Scope:** Ashfall fighter rendering pipeline

## Decision

Modified `CharacterSprite` base class to auto-detect and render pre-rendered PNG sprites instead of procedural `_draw()` geometry. The system probes `res://assets/sprites/{character_id}/` at startup and creates an `AnimatedSprite2D` child if sprites are found.

## Key Design Choices

1. **Detection via virtual method** — `_get_character_id()` returns the character folder name. Base returns `""` (no sprites). Subclasses override with `"kael"` / `"rhena"`. Cleaner than class name parsing.

2. **Pose setter branches** — When `pose` changes, the setter calls `_update_sprite_animation()` (PNG mode) or `queue_redraw()` (procedural mode). No new signals, no polling.

3. **Graceful fallback** — If sprites aren't found, procedural rendering continues unchanged. Both Kael and Rhena can run with or without PNGs.

4. **Zero changes to downstream systems** — `SpriteStateBridge`, `FighterAnimationController`, fighter `.tscn` files, hitboxes, and HUD are all untouched. The integration is entirely inside `CharacterSprite`.

5. **Scale constant** — `_PNG_SPRITE_SCALE = 0.15` (512px → ~77px). Tunable constant, not buried in logic.

## Impact on Team

- **Boba:** New sprite animations (block, hit, jump, etc.) just need to follow the naming convention `{char}_{anim}_{NNNN}.png` in the correct folder. Add the animation name to `_SPRITE_ANIM_CONFIGS` and pose mappings to `_POSE_TO_ANIM`.
- **Wedge:** No gameplay changes. State machine and hitbox systems unaffected.
- **Joaquín:** Run the game normally — if PNGs exist, they render automatically.

## Files Changed

- `games/ashfall/scripts/fighters/sprites/character_sprite.gd` — PNG sprite system added
- `games/ashfall/scripts/fighters/sprites/kael_sprite.gd` — `_get_character_id()` override
- `games/ashfall/scripts/fighters/sprites/rhena_sprite.gd` — `_get_character_id()` override

# Squad Documentation Deep Audit — Complete Feature Inventory

**Author:** Jango (Tool Engineer)
**Date:** 2026-07-23
**Status:** Proposed
**Audience:** Joaquín (Founder), all agents

---

## Summary

Deep-crawled 25+ pages of the Squad docs site (bradygaster.github.io/squad). Read every Get Started, Concepts, Features, Guide, Reference, Scenarios, Cookbook, and What's New page. Cross-referenced against our `.squad/` directory, `squad.config.ts`, GitHub workflows, and identity files. This report covers **every documented feature** with our adoption status, value assessment, and specific next steps.

---

## Feature Inventory

### 1. CLI Installation & Distribution

**What it does:** Squad installs via `npm i -g @bradygaster/squad-cli`. Supports global install, npx one-off, and SDK library import.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — we have `squad.config.ts` and full `.squad/` directory |
| Value | 🤷 Low — already done |
| Effort | N/A |

---

### 2. Team Formation (Init Mode)

**What it does:** `squad init` scans your repo, proposes a 3-7 member team based on detected stack, lets you customize, then writes `.squad/` directory with charters, routing, and casting.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — 15 agents + Scribe + Ralph + @copilot on the roster |
| Value | 🤷 Low — already mature |
| Effort | N/A |

---

### 3. Parallel Fan-Out Execution

**What it does:** Saying "Team, ..." triggers parallel agent spawning. Multiple agents work simultaneously in separate context windows. Coordinator collects and synthesizes results.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — we use "Team, ..." pattern regularly |
| Value | 🔥 High — multiplies throughput on multi-domain tasks |
| Effort | N/A |

---

### 4. Response Modes (Direct / Lightweight / Standard / Full)

**What it does:** Squad auto-selects effort level. Direct (~2-3s) for status checks, Lightweight (~8-12s) for quick fixes, Standard (~25-35s) for normal work, Full (~40-60s) for multi-agent tasks.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — automatic, no config needed |
| Value | 💡 Medium — saves tokens on simple queries |
| Effort | N/A |

---

### 5. Work Routing (Named / Domain / Skill-Aware)

**What it does:** Three routing strategies: Named ("Chewie, fix X"), Domain (pattern matching in `routing.md`), and Skill-aware (agent with relevant skill preferred). First match wins.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — comprehensive `routing.md` with 13 work types |
| Value | 🔥 High — critical for correct agent assignment |
| Effort | N/A |

---

### 6. Reviewer Protocol & Lockout

**What it does:** When a reviewer (Lead, Tester) rejects work, the original agent gets locked out — no self-revision allowed. Prevents endless fix-retry loops. Deadlock handling escalates to user.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — Solo (Lead) and Ackbar (QA) have review authority |
| Value | 🔥 High — prevents infinite feedback loops |
| Effort | N/A |

---

### 7. Ceremonies (Design Review + Retrospective)

**What it does:** Structured meetings auto-triggered at key moments. Design Review before multi-agent tasks with shared systems. Retrospective after failures. Custom ceremonies supported.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — both Design Review and Retrospective configured in `ceremonies.md` |
| Value | 🔥 High — design reviews prevent conflicting implementations |
| Effort | N/A |

**Gap noted:** We have only the two default ceremonies. Docs mention you can add custom ceremonies (e.g., "security review", "sprint planning"). We could add:
- **Sprint Planning ceremony** — Mace facilitates, auto-triggers at sprint boundaries
- **Art Review ceremony** — Boba facilitates before sprite/animation integration

---

### 8. Decisions System (decisions.md + inbox)

**What it does:** Append-only shared memory all agents read before working. Decisions captured from agent work (inbox files), user directives, and Scribe merges.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — large `decisions.md` (85KB!), active inbox with 7 pending items |
| Value | 🔥 High — team alignment backbone |
| Effort | N/A |

**⚠️ Critical gap: Decision Archiving.** Docs say when `decisions.md` gets large, old decisions should archive to `decisions-archive.md` — "preserved for reference but no longer loaded into agent context." Our file is **85KB** — that's eating enormous context budget. We do NOT have a `decisions-archive.md`.

**Recommendation:** 🔥 HIGH PRIORITY — Archive stale sprint artifacts and one-time planning fragments. This could cut agent context usage dramatically.

---

### 9. Directives (Signal Word Detection)

**What it does:** Say "always", "never", "from now on", "remember to", "don't", "make sure to" and Squad captures it as a permanent team rule. Persists across all sessions.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Configured but underused — directives exist in `decisions.md` but we don't have a separate `directives.md` |
| Value | 🔥 High — fastest way to shape team behavior |
| Effort | Trivial (minutes) |

**Docs note:** The CLI reference mentions a separate `directives.md` file for permanent rules. We embed them in `decisions.md`. Either approach works, but a dedicated file prevents dilution.

---

### 10. Skills System (Starter + Earned, Confidence Lifecycle)

**What it does:** Reusable knowledge files at `.squad/skills/{name}/SKILL.md`. Team-wide (not per-agent). Earned skills have confidence lifecycle: Low → Medium → High. Skills are portable across projects via export/import.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — **31 skills** in `.squad/skills/`, covering game design, combat, audio, tools, workflow, etc. |
| Value | 🔥 High — massive knowledge base already |
| Effort | N/A |

**Gap noted:** We likely haven't assigned confidence levels to our earned skills. Docs say earned skills should have `**Confidence:** low|medium|high` in them. Worth auditing.

---

### 11. Personal History (history.md per agent)

**What it does:** Each agent has `.squad/agents/{name}/history.md`. After every session, agents append learnings. Only that agent reads its own history. Progressive summarization when >12KB.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — all agents have history files, some quite large |
| Value | 🔥 High — specialized per-agent memory |
| Effort | N/A |

**Gap noted:** Progressive summarization. Docs say when history exceeds ~12KB, older entries should be archived into a summary section. Some of our agent histories (like Jango's at 25KB) may be oversized.

---

### 12. Human Team Members

**What it does:** Add real people to the roster with 👤 Human badge. No charter, no history, never spawned as sub-agent. When work routes to them, Squad pauses and tells you someone needs to act. Stale reminders keep things moving.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no human members on roster |
| Value | 💡 Medium — useful for Joaquín as formal approval gate |
| Effort | Trivial (minutes) |

**Recommendation:** Consider adding Joaquín as a human member for approval gates on architecture decisions, sprint scope, and art direction sign-off. The docs' litmus test: "If you want agents to stop and wait for someone's input before proceeding, add them."

---

### 13. @copilot Coding Agent Integration

**What it does:** GitHub Copilot coding agent as autonomous squad member. Picks up issues, creates branches, opens PRs. Three-tier capability profile (🟢🟡🔴). Auto-assign via `COPILOT_ASSIGN_TOKEN` PAT.

| Aspect | Assessment |
|--------|------------|
| Our status | ⚠️ Partially set up — @copilot on roster, capability profile defined, `squad-issue-assign.yml` exists, BUT auto-assign is `false` and likely no `COPILOT_ASSIGN_TOKEN` secret |
| Value | 🔥 High — autonomous async work on well-defined tasks |
| Effort | Small (< 1 hour) |

**To fully enable:**
1. Set `copilot-auto-assign: true` in `team.md`
2. Create classic PAT with `repo` scope at github.com/settings/tokens/new
3. `gh secret set COPILOT_ASSIGN_TOKEN` on the repo
4. Ensure `copilot-setup-steps.yml` exists in `.github/`
5. Test by labeling an issue `squad:copilot`

---

### 14. Ralph — Work Monitor

**What it does:** Built-in agent that tracks the work queue, monitors CI status, auto-triages issues. Three layers: in-session ("Ralph, go"), local watchdog (`squad watch`), cloud heartbeat (GitHub Actions cron). Never stops while work remains.

| Aspect | Assessment |
|--------|------------|
| Our status | ⚠️ Partially set up — Ralph on roster, `squad-heartbeat.yml` exists, but likely not actively used for continuous monitoring |
| Value | 🔥 High — autonomous backlog processing |
| Effort | Small (< 1 hour) to fully activate |

**Untapped patterns:**
- "Ralph, go" — activates in-session work loop
- `squad watch --interval 5` — persistent local polling
- Heartbeat cron for fully unattended triage

---

### 15. GitHub Issues Integration

**What it does:** Connect to repo, view backlog, work on issues, agents create branches/PRs, handle review feedback, merge. Full issue-driven development workflow.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — issue source connected to `jperezdelreal/FirstFrameStudios`, routing labels configured |
| Value | 🔥 High — core workflow |
| Effort | N/A |

---

### 16. Plugin Marketplace

**What it does:** Community-curated bundles of agent templates, skills, and best practices. Available marketplaces include awesome-copilot, anthropic-skills, azure-cloud-dev, security-hardening. Install with `/plugin install`.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no plugins directory, no marketplace configured |
| Value | 💡 Medium — could bring pre-built patterns for game dev |
| Effort | Small (< 1 hour) |

**Recommendation:** Check if any marketplaces have game-dev-related plugins. We have `plugin-marketplace.md` in `.squad/` (docs template) but no actual marketplace configured. Try: `"Browse awesome-copilot marketplace"` in a session.

---

### 17. Export & Import

**What it does:** Export trained team to portable JSON. Import into any repo. Skills, casting state, agent histories included. Project-specific details stripped on import.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available but unused — `squad export` is a CLI command we haven't used |
| Value | 💡 Medium — useful when we start our second game project |
| Effort | Trivial (minutes) |

**When to use:** Before major refactors (backup), when starting the next game project (bring trained team), sharing with collaborators.

---

### 18. Personal Squad (Cross-Project)

**What it does:** `squad init --global` creates `~/.squad/` — a personal team root. All projects point to it. Agents remember conventions across all repos. Skills learned in one project carry to all others.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — `config.json` shows `teamRoot: "."` (local mode) |
| Value | 💡 Medium — becomes high when we have multiple game projects |
| Effort | Small (< 1 hour) |

**When to adopt:** When we start the second game project. For now, single-project local mode is correct.

---

### 19. Consult Mode

**What it does:** Bring your personal squad to projects you don't own (OSS, client work) without leaving traces. Team consults invisibly, then extracts generic learnings back to personal squad.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up (requires Personal Squad first) |
| Value | 🤷 Low for us — we're not contributing to other repos with Squad |
| Effort | N/A |

---

### 20. Upstream Inheritance

**What it does:** Declare external Squad sources (other repos, local dirs, exports) and inherit their context (skills, decisions, routing) at session start. Enables knowledge sharing across teams/orgs.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no `upstream.json` |
| Value | 💡 Medium — useful for multi-project studios (share game-dev skills across projects) |
| Effort | Small (< 1 hour) |

**When to adopt:** When we have 2+ game projects and want to share studio-level conventions without duplicating. Our `identity/` directory already captures studio-level wisdom — upstream inheritance would formalize sharing it.

---

### 21. SDK-First Mode (squad.config.ts)

**What it does:** Define your team in TypeScript using builder functions (`defineTeam`, `defineAgent`, `defineRouting`, `defineCeremony`, `defineHooks`, `defineCasting`, `defineTelemetry`). Typed, testable, version-controlled. Run `squad build` to generate `.squad/` files.

| Aspect | Assessment |
|--------|------------|
| Our status | ⚠️ Partially set up — we have `squad.config.ts` but it uses basic config format, not full builder functions |
| Value | 💡 Medium — typed config is nice but our markdown-based setup works |
| Effort | Medium (session) to fully migrate |

**Gap noted:** Our `squad.config.ts` routes everything to `@scribe` — this looks like a placeholder/template that was never customized. The routing rules in `routing.md` are the ones actually used. The config should either be fixed or removed to avoid confusion.

---

### 22. Governance Hooks (defineHooks)

**What it does:** File-write guards (allowedWritePaths), blocked commands, PII scrubbing, reviewer lockout enforcement, maxAskUser limit. Enforced in code, not just suggestions.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no hooks defined in `squad.config.ts` |
| Value | 🔥 High — prevents agents from writing outside their domain, scrubs PII |
| Effort | Small (< 1 hour) |

**Recommendation:** Add `defineHooks` to our config:
```ts
hooks: {
  allowedWritePaths: ['games/**', '.squad/**', 'tools/**', 'docs/**'],
  blockedCommands: ['rm -rf', 'DROP TABLE'],
  scrubPii: true,
  reviewerLockout: true,
  maxAskUser: 3,
}
```

---

### 23. Model Selection & Fallback Chains

**What it does:** Per-agent model selection based on task type. 16+ models across Premium/Standard/Fast tiers. Task-aware defaults (code → Sonnet, docs → Haiku, visual → Opus). Fallback chains for unavailability.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — `squad.config.ts` has full fallback chain config, default model `claude-sonnet-4.5` |
| Value | 🔥 High — cost optimization without quality loss |
| Effort | N/A |

---

### 24. Casting System (Universe Themes)

**What it does:** Agents named from fictional universes. Allowlist universes, overflow strategy, capacity limits. 33+ universes available.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — Star Wars universe, casting history/policy/registry files present |
| Value | 💡 Medium — team cohesion and personality |
| Effort | N/A |

**Note:** `squad.config.ts` lists different allowlist universes (Usual Suspects, Breaking Bad, The Wire, Firefly) than what we actually use (Star Wars). Config is mismatched — our actual casting uses Star Wars per `team.md`.

---

### 25. Identity Layer (wisdom.md, now.md)

**What it does:** `wisdom.md` stores reusable heuristics learned through work. `now.md` provides temporal awareness (current sprint, priorities).

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — `.squad/identity/` has wisdom.md, now.md, company.md, mission-vision.md, principles.md, quality-gates.md, growth-framework.md, new-project-playbook.md |
| Value | 🔥 High — deep studio identity beyond just project context |
| Effort | N/A |

---

### 26. Interactive Shell (squad command)

**What it does:** Persistent interactive session with `/status`, `/history`, `/agents`, `/sessions`, `/resume` commands. Session management with resume capability.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available — we primarily use `copilot --agent squad` instead |
| Value | 💡 Medium — `/sessions` and `/resume` could help with session continuity |
| Effort | Trivial (minutes) |

---

### 27. squad doctor (Setup Validation)

**What it does:** 9-check setup validation with clear pass/fail output. Validates `.squad/` structure, config files, agent definitions, file permissions, integrations.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available but likely not routinely run |
| Value | 💡 Medium — useful diagnostic after upgrades or problems |
| Effort | Trivial (minutes) — just run `squad doctor` |

---

### 28. squad upgrade

**What it does:** Upgrades Squad-owned files (templates, workflows) to latest version without touching team state (charters, decisions, history).

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available — unknown when last run |
| Value | 💡 Medium — keeps templates current |
| Effort | Trivial (minutes) |

---

### 29. squad nap (Context Hygiene)

**What it does:** Compress, prune, archive `.squad/` state. `--deep` for thorough cleanup, `--dry-run` to preview. Keeps context budget lean.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not used — never run |
| Value | 🔥 High — our 85KB decisions.md and 25KB+ history files scream for this |
| Effort | Trivial (minutes) |

**Recommendation:** Run `squad nap --dry-run` to preview, then `squad nap --deep` to clean up. This directly addresses our context bloat problem.

---

### 30. squad scrub-emails

**What it does:** Remove email addresses from Squad state files. PII protection.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available but unknown if needed |
| Value | 🤷 Low — small team, unlikely PII in state files |
| Effort | Trivial (minutes) |

---

### 31. Remote Control (squad start --tunnel)

**What it does:** Control Copilot CLI from phone via secure WebSocket tunnel. PTY + devtunnel + phone browser. 7-layer security model. Perfect for demos.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up |
| Value | 🤷 Low for us — no mobile workflow needed |
| Effort | Small (< 1 hour) |

---

### 32. OpenTelemetry / Aspire Dashboard

**What it does:** Observability for Squad operations. Traces, metrics, spans. Aspire dashboard for visualization.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up |
| Value | 🤷 Low — overkill for our team size |
| Effort | Medium (session) |

---

### 33. Git Worktrees Support

**What it does:** Two strategies — worktree-local (independent `.squad/` per worktree) or main-checkout (shared via symlink). `merge=union` for append-only files.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Merge rules likely configured via `.gitattributes` |
| Value | 🤷 Low — we don't use worktrees currently |
| Effort | N/A |

---

### 34. GitHub Workflows Suite

**What it does:** Squad installs/upgrades 11+ GitHub Actions workflows: heartbeat, triage, issue-assign, label-enforce, CI, docs, main-guard, preview, promote, release, insider-release.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — 11 squad-* workflows + sync-squad-labels.yml |
| Value | 🔥 High — automation backbone |
| Effort | N/A |

---

### 35. Decision Archiving

**What it does:** When `decisions.md` grows large, archive old decisions to `decisions-archive.md`. Active decisions stay lean; agents read less context.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no `decisions-archive.md` exists, main file is 85KB |
| Value | 🔥 High — directly reduces context waste |
| Effort | Small (< 1 hour) |

---

### 36. Scribe Agent

**What it does:** Silent decision logger. Periodically consolidates inbox files into canonical `decisions.md`, deduplicating overlapping entries. Always on roster.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — Scribe on roster with charter |
| Value | 🔥 High — maintains shared memory |
| Effort | N/A |

---

### 37. Concurrency Limits

**What it does:** Default 5 agents in parallel. Adjustable via prompt ("Run at most 2 agents at once to save costs").

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — default behavior |
| Value | 💡 Medium — cost control lever |
| Effort | N/A |

---

---

## Sample Prompts from the Docs We Should Try

### High-Value for Game Studio Context

```
Team, build the [feature] — include gameplay code, art integration, and tests.
```
Multi-agent fan-out tuned for our domain.

```
Ralph, go — start monitoring and process the backlog until it's clear.
```
Activate autonomous work processing.

```
Run a design review before we start the [feature] rebuild.
```
Formal ceremony before multi-agent architecture work.

```
Run a retro on why those tests failed.
```
Automated root-cause analysis.

```
Always use [convention]. From now on, [rule].
```
Directive capture for persistent team rules.

```
Yoda, do a 20-minute spike on [design question]. Write a decision.
```
Architectural spike pattern.

```
Show me what skills this team has learned.
```
Audit accumulated knowledge.

```
What did the team accomplish last session? Any blockers?
```
Quick status without spawning agents.

```
Team, design the [system]. Don't code yet. Write decisions to decisions.md.
```
Decision-first development pattern.

```
Export the current team.
```
Backup before major changes.

---

## Best Practices We're Not Following

### 1. Decision Archiving (CRITICAL)
Our `decisions.md` is **85KB**. The docs explicitly say to archive stale entries to `decisions-archive.md` so agents read a lean, current shared brain. This is likely our #1 context budget waste.

### 2. Progressive History Summarization
Agent history files should be summarized when >12KB. Some of ours are 25KB+. The docs say older entries should condense into a summary section.

### 3. Context Hygiene (`squad nap`)
Never used. Docs recommend periodic cleanup to compress, prune, and archive `.squad/` state.

### 4. Skill Confidence Levels
Our 31 skills likely don't have confidence metadata (Low/Medium/High). The docs say earned skills should track how battle-tested they are.

### 5. Directives in Dedicated File
The CLI reference shows a `directives.md` file for permanent rules separate from `decisions.md`. We mix everything together.

---

## Tips and Tricks We Haven't Adopted

1. **"Team" keyword for fan-out** — We may not consistently use this trigger word.
2. **"Keep working" / "Work until done"** — Activates Ralph's continuous loop.
3. **Stack decisions in your prompt** — Front-load conventions in the first prompt to reduce agent questions.
4. **Decision-first development** — "Don't code yet. Write decisions." before implementation.
5. **Spike → Decision → Build** — For hard problems, spike first, then decide, then build.
6. **Check `/status` before big asks** — Prevent overloading already-working agents.
7. **Reference decisions, not details** — "See the auth decision in decisions.md" instead of re-explaining.

---

## Common Mistakes from Docs We Might Be Making

| Mistake | Fix | Our Risk Level |
|---------|-----|----------------|
| Vague prompts → agents ask questions | Be specific about scope upfront | 💡 Medium |
| Interrupting parallel work | Let it finish, then review | 💡 Medium |
| Not using Ralph on full backlog | `Ralph, go` — let the bot grind | 🔥 High |
| Too many agents | Start with 4-5, add specialists later | 💡 Medium (we have 15) |
| Lost team knowledge | Commit `.squad/` to git | ✅ We do this |
| Contradicting old decisions | Ask Scribe to remind you of rules | 💡 Medium |
| 85KB decisions.md | Archive old decisions | 🔥 Critical |

---

## Personal Squad Patterns

The docs describe a "Personal Squad" concept (`squad init --global` → `~/.squad/`) that creates a cross-project team identity. **Not relevant for us yet** — we operate in a single repo. This becomes valuable when:

- We start the second game project (export skills → import to new repo)
- Joaquín wants consistent agent behavior across repos
- We want studio-level conventions separate from game-specific decisions

Our `identity/` directory already captures studio-level wisdom — it's a natural precursor to a personal squad setup.

---

## What We're Missing

### 🔴 Critical Gaps (Fix This Session)

1. **Decision Archiving** — 85KB `decisions.md` is burning context budget on every agent spawn. Run `squad nap --deep` or manually create `decisions-archive.md` and move old entries. This is the single highest-ROI fix available.

2. **History Summarization** — Agent histories over 12KB need progressive summarization. Multiple agents are over this threshold.

### 🟡 High-Value Gaps (Fix This Sprint)

3. **@copilot Auto-Assign** — It's on the roster but disabled. Create PAT, set secret, enable auto-assign. Unlocks autonomous issue processing for well-defined tasks.

4. **Governance Hooks** — No file-write guards, no PII scrubbing. Adding `defineHooks` to `squad.config.ts` prevents agents from writing outside their domain.

5. **squad.config.ts Cleanup** — Routing rules all point to `@scribe` (placeholder). Casting allowlist doesn't match actual universe (Star Wars). Fix or remove to avoid confusion.

6. **Custom Ceremonies** — Only have Design Review and Retrospective. Consider adding Sprint Planning (Mace facilitates) and Art Review (Boba facilitates).

### 🟢 Nice-to-Have Gaps (Future Sprints)

7. **Plugin Marketplace** — Browse for game-dev relevant plugins. May not exist yet, but worth checking.

8. **Personal Squad** — For when we start the next game project. Export current team, init global, connect both projects.

9. **Upstream Inheritance** — Share studio conventions across game projects. Natural extension of our identity layer.

10. **Skill Confidence Levels** — Audit all 31 skills and add confidence metadata.

11. **Dedicated directives.md** — Separate permanent rules from the decision log.

12. **Human Team Member** — Add Joaquín as formal approval gate for architecture/scope decisions.

### ⬜ Not Needed

- Remote Control (squad start --tunnel) — No mobile workflow
- OpenTelemetry/Aspire — Overkill for our scale
- Consult Mode — We don't contribute to external projects with Squad
- Git Worktrees — Not our workflow

---

## Priority Action Items

| # | Action | Owner | Effort | Impact |
|---|--------|-------|--------|--------|
| 1 | Run `squad nap --deep` (or manually archive decisions) | Jango | Small | 🔥 Critical — context budget |
| 2 | Enable @copilot auto-assign (PAT + secret) | Jango | Small | 🔥 High — autonomous work |
| 3 | Fix `squad.config.ts` (routing, casting mismatch) | Jango | Small | 💡 Medium — config hygiene |
| 4 | Add governance hooks to config | Jango | Small | 🔥 High — safety guardrails |
| 5 | Run `squad doctor` to validate setup | Jango | Trivial | 💡 Medium — diagnostic baseline |
| 6 | Summarize oversized agent histories | Scribe | Small | 💡 Medium — context budget |
| 7 | Add custom ceremonies (Sprint Planning, Art Review) | Jango | Small | 💡 Medium — process quality |
| 8 | Add Joaquín as human team member | Jango | Trivial | 💡 Medium — approval gates |

---

*This audit covers every documented feature as of 2026-07-23 across 25+ docs pages. Squad is alpha software — features may change. Re-audit recommended after major Squad version updates.*

# Squad Ecosystem Audit — Comprehensive Feature Investigation

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-23  
**Status:** PROPOSED  
**Scope:** Squad CLI v0.8.25, all features vs. current adoption

---

## Executive Summary

We're running Squad v0.8.25 with a mature 16-member team (14 AI agents + Ralph + @copilot), 31 skills, 5 ceremonies, and 17 GitHub Actions workflows. After a thorough investigation of the CLI, docs site, and upstream Squad repo, I found **6 high-value features we should adopt now**, **4 worth adopting later**, and **3 to skip**. Our biggest gaps are: no `squad nap` hygiene (our history files are 69KB+), no SubSquads for parallel workstreams, and unused plugin marketplace.

---

## TOP 5 RECOMMENDATIONS — ADOPT NOW

| # | Feature | Why | Effort |
|---|---------|-----|--------|
| 1 | **`squad nap --deep`** | Our `.squad/` state is bloated (Solo history alone is 69KB). Context hygiene prevents agent confusion and token waste. | Trivial — one command |
| 2 | **SubSquads (Workstreams)** | Split Art Sprint vs. Gameplay vs. Audio into isolated Codespace lanes. Prevents merge conflicts and rate-limit bottleneck. | Small — create `streams.json` |
| 3 | **Add Joaquín as Human Team Member** | Formal approval gates for architecture decisions and ship/no-ship calls. Agents stop-and-wait instead of guessing. | Trivial — one prompt |
| 4 | **Enable `squad-heartbeat.yml` cron** | Ralph runs every 30 min unattended. Untriaged issues get auto-processed even when we're AFK. | Trivial — uncomment cron line |
| 5 | **`squad build --check` in CI** | Catch config drift between `squad.config.ts` and `.squad/` markdown. Prevents silent divergence. | Small — add workflow step |

---

## Full Feature Audit

### 1. Squad CLI Commands

| Command | What It Does | Status | Value | Effort | Recommendation |
|---------|-------------|--------|-------|--------|----------------|
| `squad init` | Initialize Squad | ✅ Active (done long ago) | — | — | Already done |
| `squad upgrade` | Update Squad-owned files | ✅ Active | High | Trivial | Keep running on new releases |
| `squad status` | Show active squad info | ✅ Active | Low | Trivial | Already available |
| `squad triage` | Scan and categorize issues | 🟡 Configured (via workflow) | High | Trivial | Use `squad triage --interval 10` for local persistent triage |
| `squad loop` | Ralph continuous work loop | 🟡 Configured (in-session only) | High | Small | Enable for sprint execution sessions |
| `squad hire` | Team creation wizard | ✅ Active | Medium | Trivial | Already used for team building |
| `squad copilot` | Add/remove @copilot agent | ✅ Active | Medium | Trivial | Already configured |
| `squad plugin` | Manage plugin marketplaces | ❌ Not set up | Medium | Small | Adopt later — see Plugin section |
| `squad export` | Export squad to JSON snapshot | ❌ Not used | Medium | Trivial | Use before major migrations |
| `squad import` | Import from export file | ❌ Not used | Medium | Trivial | Paired with export |
| `squad start` | Copilot with remote access | ❌ Not set up | Low | Medium | Adopt later — see RC section |
| `squad nap` | Context hygiene/compression | ❌ Not used | **High** | Trivial | **ADOPT NOW** |
| `squad doctor` | Health checks | ✅ Active (8/8 passing) | Medium | Trivial | Run periodically |
| `squad consult` | Personal squad on foreign repos | ❌ N/A for us | Low | — | Skip — we own our repos |
| `squad extract` | Extract learnings from consult | ❌ N/A | Low | — | Skip — paired with consult |
| `squad subsquads` | Multi-Codespace scaling | ❌ Not set up | **High** | Small | **ADOPT NOW** |
| `squad link` | Link to remote team root | ❌ Not set up | Medium | Small | Adopt later — useful for multi-repo |
| `squad build` | Compile squad.config.ts | 🟡 Have config, never built | **High** | Small | **ADOPT NOW** |
| `squad aspire` | .NET Aspire dashboard | ❌ Not set up | Low | Medium | Skip — not .NET project |
| `squad rc` | Remote Control bridge | ❌ Not set up | Low | Medium | Adopt later — nice for demos |
| `squad upstream` | Manage upstream Squad sources | ❌ Not set up | Medium | Small | Adopt later — multi-repo synergy |
| `squad migrate` | Convert between formats | ❌ Not needed | Low | — | Skip — already on SDK mode |
| `squad scrub-emails` | Remove PII | ✅ Available | Low | Trivial | Run if needed |

---

### 2. Plugin Marketplace

**Status:** ❌ Not set up  
**Value:** Medium  
**Effort:** Small

**What it is:** Community-curated bundles of agent templates, skills, and conventions from GitHub repos. Four marketplaces exist:

| Marketplace | URL | Relevance to Us |
|-------------|-----|-----------------|
| awesome-copilot | `github/awesome-copilot` | 🟡 Low — frontend/backend web focus, not game dev |
| anthropic-skills | `anthropics/skills` | 🟢 Medium — Claude optimization patterns could help |
| azure-cloud-dev | `github/azure-cloud-development` | 🔴 None — we don't use Azure |
| security-hardening | `github/security-hardening` | 🟡 Low — game doesn't handle sensitive data |

**Game dev gap:** No game development marketplace exists yet. None of the existing marketplaces have Godot, GDScript, game design, or fighting game plugins.

**Recommendation:** Adopt later. Consider **creating our own marketplace** repo (`FirstFrameStudios/squad-gamedev-plugins`) packaging our 31 skills as reusable plugins. This would be the first game-dev Squad marketplace.

**How to adopt:**
1. `squad plugin marketplace add anthropics/skills` — get Claude optimization patterns
2. Long-term: Package our skills into a public marketplace for the Squad community

---

### 3. SubSquads (Workstreams)

**Status:** ❌ Not set up  
**Value:** **HIGH**  
**Effort:** Small

**What it is:** Partitions work into labeled SubSquads so multiple Codespaces can work in parallel on different parts of the project. Each SubSquad targets a GitHub label and optionally restricts to certain directories.

**Why we need it:** Our 14-agent team has natural workstream boundaries:
- **Art Sprint** (`team:art`) — Boba, Leia, Bossk, Nien → `games/ashfall/assets/`, `tools/blender/`
- **Gameplay** (`team:gameplay`) — Lando, Tarkin, Chewie → `games/ashfall/scripts/`, `games/ashfall/scenes/`
- **Audio** (`team:audio`) — Greedo → `games/ashfall/audio/`
- **QA** (`team:qa`) — Ackbar, Jango → `games/ashfall/test/`

**Recommendation:** **ADOPT NOW**

**How to adopt:**
1. Create `.squad/streams.json`:
```json
{
  "streams": [
    {
      "name": "art-sprint",
      "labelFilter": "team:art",
      "folderScope": ["games/ashfall/assets/", "tools/"],
      "workflow": "branch-per-issue"
    },
    {
      "name": "gameplay",
      "labelFilter": "team:gameplay",
      "folderScope": ["games/ashfall/scripts/", "games/ashfall/scenes/"],
      "workflow": "branch-per-issue"
    },
    {
      "name": "audio",
      "labelFilter": "team:audio",
      "folderScope": ["games/ashfall/audio/"],
      "workflow": "branch-per-issue"
    }
  ]
}
```
2. Create GitHub labels: `team:art`, `team:gameplay`, `team:audio`
3. In each Codespace, activate: `squad subsquads activate art-sprint`

---

### 4. Human Team Members

**Status:** ❌ Not set up  
**Value:** **HIGH**  
**Effort:** Trivial

**What it is:** Adds real people to the Squad roster with 👤 Human badge. When work routes to a human, Squad pauses and waits for their input. Humans can't be spawned as sub-agents but can serve as reviewers and approval gates.

**Why we need it:** Joaquín is the founder but has no formal roster entry. Adding him creates explicit approval gates for:
- Architecture decisions (currently ad-hoc)
- Ship/no-ship calls at milestones
- Art direction sign-off
- Design review participation in ceremonies

**Recommendation:** **ADOPT NOW**

**How to adopt:**
1. In a Squad session: `"Add Joaquín (joperezd) as Founder and Creative Director"`
2. He appears on roster with 👤 badge
3. Update ceremonies to add Joaquín as participant in Design Review and Integration Gate
4. Routing: architecture decisions and milestone sign-offs route to Joaquín

---

### 5. SDK-First Mode & `squad build`

**Status:** 🟡 Have `squad.config.ts`, never run `squad build`  
**Value:** **HIGH**  
**Effort:** Small

**What it is:** `squad.config.ts` is the single source of truth. `squad build` compiles it into `.squad/` markdown. `squad build --check` validates sync in CI.

**Current gap:** We have a `squad.config.ts` that defines models, routing, and casting — but our `.squad/` markdown files were created independently. The config and the markdown may have **silently diverged**. Our config is also incomplete — it doesn't define agents, ceremonies, hooks, or skills.

**Recommendation:** **ADOPT NOW** (partial — build validation, not full migration)

**How to adopt:**
1. Run `squad build --dry-run` to see what would be generated vs. what exists
2. Expand `squad.config.ts` to include all agents, ceremonies, hooks
3. Add `squad build --check` to CI workflow (add step to `squad-ci.yml`)
4. Optionally: `squad build --watch` for live rebuilds during development
5. Add `defineHooks()` for governance: allowed write paths, blocked commands, PII scrubbing

---

### 6. `squad watch` / Ralph Persistent Polling

**Status:** 🟡 Ralph exists on roster, no persistent polling  
**Value:** High  
**Effort:** Trivial

**What it is:** `squad watch --interval 10` runs Ralph as a local watchdog, checking GitHub every N minutes for untriaged issues, stale PRs, CI failures. Three layers: in-session (`Ralph, go`), local watchdog (`squad watch`), cloud heartbeat (GitHub Actions cron).

**Current gap:** We use Ralph in-session only. The heartbeat workflow exists but cron is commented out. No local watchdog.

**Recommendation:** Adopt now — enable heartbeat cron, use `squad watch` during sprint sessions.

**How to adopt:**
1. Edit `.github/workflows/squad-heartbeat.yml` — uncomment the cron schedule (e.g., `'*/30 * * * *'`)
2. During sprints, run `squad watch --interval 10` in a background terminal
3. Ensure `gh` CLI is authenticated with Classic PAT (scopes: `repo`, `project`)

---

### 7. `squad doctor` Deep Checks

**Status:** ✅ Active (8/8 passing)  
**Value:** Medium  
**Effort:** Trivial

**What it is:** Validates squad setup — checks files, config, health. Already passing all 8 checks.

**Recommendation:** Keep running periodically, especially after `squad upgrade`.

---

### 8. Ceremonies

**Status:** ✅ 5 configured (Design Review, Retrospective, Integration Gate, Spec Validation, Godot Smoke Test)  
**Value:** Medium  
**Effort:** Small

**What the docs offer:** The docs show ceremonies are flexible — any trigger, any schedule, custom agendas. Built-in types are Design Review and Retrospective, but you can create any custom ceremony.

**Ceremonies we could add:**

| Ceremony | Trigger | Value |
|----------|---------|-------|
| **Sprint Planning** | Manual, start of sprint | High — Mace + Yoda + Solo plan the sprint |
| **Daily Standup** | Schedule (cron `0 9 * * 1-5`) | Medium — agents report blockers |
| **Art Review** | After art PRs merged | Medium — Boba reviews visual consistency |
| **Security Review** | Before release builds | Low — less critical for single-player game |

**Recommendation:** Add Sprint Planning ceremony now; Daily Standup adopt later (requires `squad loop` active).

**How to adopt:** Add to `.squad/ceremonies.md`:
```markdown
## Sprint Planning

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | before |
| **Condition** | start of new sprint |
| **Facilitator** | Mace (Producer) |
| **Participants** | Mace + Yoda + Solo + Joaquín |
| **Time budget** | focused |
| **Enabled** | ✅ yes |
```

---

### 9. GitHub Actions Workflows

**Status:** 17 workflows installed — 12 active, 5 template stubs  
**Value:** High  
**Effort:** Varies

| Workflow | Status | Action Needed |
|----------|--------|---------------|
| **squad-heartbeat.yml** | 🟡 Active but cron disabled | **Uncomment cron** — enables unattended triage |
| **squad-triage.yml** | ✅ Active | Working — routes `squad`-labeled issues |
| **squad-issue-assign.yml** | ✅ Active | Working — acknowledges `squad:*` labels |
| **sync-squad-labels.yml** | ✅ Active | Working — syncs labels from roster |
| **squad-label-enforce.yml** | ✅ Active | Working — enforces mutual exclusivity |
| **pr-body-check.yml** | ✅ Active | Working — warns if no `Closes #N` |
| **branch-validation.yml** | ✅ Active | Working — PRs must target main |
| **squad-main-guard.yml** | ✅ Active | Working — blocks `.squad/` on protected branches |
| **squad-promote.yml** | ✅ Active | Working — dev→preview→main promotion |
| **integration-gate.yml** | ✅ Active | Working — GDScript linting on PRs to main |
| **godot-project-guard.yml** | ✅ Active | Working — warns on project.godot changes |
| **godot-release.yml** | ✅ Active | Working — exports Godot builds on tags |
| **squad-ci.yml** | ⚠️ Template stub | Needs build/test commands configured |
| **squad-docs.yml** | ⚠️ Template stub | Needs docs build configured |
| **squad-release.yml** | ⚠️ Template stub | Needs release process configured |
| **squad-insider-release.yml** | ⚠️ Template stub | Needs insider build configured |
| **squad-preview.yml** | ⚠️ Template stub | Needs preview validation configured |

**Recommendation:** Enable heartbeat cron now. The 5 template stubs need Godot-specific build commands — configure `squad-ci.yml` to run GDScript linting and Godot export checks on PRs.

---

### 10. Remote Squad Mode (`squad link`)

**Status:** ❌ Not set up  
**Value:** Medium (for future multi-repo)  
**Effort:** Small

**What it is:** Links project to a remote team root — shared team identity (casting, charters, decisions) across multiple repos while keeping project-specific state local.

**Relevance:** Useful when we have multiple game repos sharing the same studio team. Currently single-repo.

**Recommendation:** Adopt later — when we start a second game project, `squad link` lets the new repo inherit our team without duplicating configuration.

---

### 11. Skills System

**Status:** ✅ 31 skills active  
**Value:** High (already delivering value)  
**Effort:** N/A

**Current skills (31):** 2d-game-art, animation-for-games, beat-em-up-combat, canvas-2d-optimization, code-review-checklist, enemy-encounter-design, feature-triage, fighting-game-design, game-audio-design, game-design-fundamentals, game-feel-juice, game-qa-testing, gdscript-godot46, github-pr-workflow, godot-4-manual, godot-beat-em-up-patterns, godot-project-integration, godot-tooling, input-handling, integration-discipline, level-design-fundamentals, milestone-completion-checklist, multi-agent-coordination, parallel-agent-workflow, procedural-audio, project-conventions, squad-conventions, state-machine-patterns, studio-craft, ui-ux-patterns, web-game-engine

**Best practices from docs:**
- **Confidence lifecycle:** Low → Medium → High. Confidence only goes up.
- **Earned vs. Starter:** Starter skills (`squad-*`) get overwritten on upgrade. Earned skills are protected.
- **Team-wide:** All agents read all skills. Not per-agent.
- **Portable:** Skills survive export/import.

**Recommendation:** Audit confidence levels — ensure battle-tested skills are at High. Consider consolidating overlapping skills (e.g., `beat-em-up-combat` + `fighting-game-design`).

---

### 12. Adding Joaquín as Human Member

See **Item 4** above — full details in the Human Team Members section.

---

### 13. `squad rc` (Remote Control)

**Status:** ❌ Not set up  
**Value:** Low (for now)  
**Effort:** Medium

**What it is:** Spawns Copilot CLI in a PTY, mirrors terminal via WebSocket + devtunnel. Phone scans QR code → full terminal on mobile. 7-layer security (devtunnel auth, session tokens, ticket-based WS auth, rate limiting, secret redaction, connection limits, audit logging).

**Cool factor:** High. **Practical value for us:** Low. We work from desktop. Could be useful for demos or monitoring long runs from phone.

**Recommendation:** Skip for now. Adopt when doing live demos or conference talks.

**Prerequisites if adopted:** `winget install Microsoft.devtunnel` → `devtunnel user login` → `squad start --tunnel`

---

### 14. Upstream Inheritance (`squad upstream`)

**Status:** ❌ Not set up  
**Value:** Medium (future)  
**Effort:** Small

**What it is:** Declares external Squad sources to inherit skills, decisions, casting policy, and routing. Supports local paths, git repos, and export snapshots. "Closest-wins" — later entries override.

**Relevance:** If we publish our game-dev skills as a marketplace/upstream repo, other game studios could inherit our expertise. We could also inherit from a community game-dev Squad if one emerges.

**Recommendation:** Adopt later — after creating our marketplace repo.

---

### 15. Context Hygiene (`squad nap`)

**Status:** ❌ Never run  
**Value:** **HIGH**  
**Effort:** Trivial

**What it is:** Compresses, prunes, and archives `.squad/` state. `--deep` does thorough cleanup. `--dry-run` previews.

**Why critical:** Solo's history.md alone is 69KB. decisions.md is 85KB. These bloated files consume agent context tokens and slow down every session. `squad nap --deep` will compress old sessions, prune archived decisions, and keep only active state.

**Recommendation:** **ADOPT NOW — run immediately.**

**How to adopt:**
1. `squad nap --dry-run` — preview what gets cleaned
2. `squad nap --deep` — full cleanup
3. Commit the cleaned state
4. Run monthly or after major milestones

---

### 16. Export/Import

**Status:** ❌ Not used  
**Value:** Medium  
**Effort:** Trivial

**What it is:** `squad export` creates a portable JSON snapshot of the entire team. `squad import` restores it.

**Recommendation:** Run `squad export` before any major upgrade or restructuring. Keep as backup/portability insurance.

---

### 17. Consult Mode

**Status:** ❌ N/A  
**Value:** Low for us  
**Effort:** N/A

**What it is:** Brings personal squad to repos you don't own (OSS, client work) without leaving traces.

**Recommendation:** Skip — we own our repos. Possibly useful if Joaquín contributes to OSS Godot projects.

---

### 18. .NET Aspire Dashboard

**Status:** ❌ Not set up  
**Value:** Low  
**Effort:** Medium

**What it is:** OpenTelemetry observability dashboard. Designed for .NET projects.

**Recommendation:** Skip — we're a Godot/GDScript project, not .NET.

---

## Summary Matrix

| Feature | Status | Value | Effort | Action |
|---------|--------|-------|--------|--------|
| `squad nap --deep` | ❌ | HIGH | Trivial | **ADOPT NOW** |
| SubSquads | ❌ | HIGH | Small | **ADOPT NOW** |
| Human Members (Joaquín) | ❌ | HIGH | Trivial | **ADOPT NOW** |
| Heartbeat cron | 🟡 | HIGH | Trivial | **ADOPT NOW** |
| `squad build --check` CI | 🟡 | HIGH | Small | **ADOPT NOW** |
| Sprint Planning ceremony | ❌ | HIGH | Small | **ADOPT NOW** |
| Ralph `squad watch` | 🟡 | High | Trivial | Adopt soon |
| Plugin marketplace | ❌ | Medium | Small | Adopt later |
| `squad link` | ❌ | Medium | Small | Adopt later (multi-repo) |
| `squad upstream` | ❌ | Medium | Small | Adopt later |
| Export/import | ❌ | Medium | Trivial | Adopt later |
| Skill confidence audit | ✅ | Medium | Small | Adopt later |
| `squad rc` | ❌ | Low | Medium | Skip |
| Aspire dashboard | ❌ | Low | Medium | Skip |
| Consult mode | ❌ | Low | — | Skip |

---

## Implementation Order

**Phase 1 — This sprint (immediate):**
1. Run `squad nap --deep` to clean bloated state
2. Add Joaquín as human team member
3. Uncomment heartbeat cron in `squad-heartbeat.yml`
4. Add Sprint Planning ceremony to `ceremonies.md`
5. Run `squad build --dry-run` to assess config drift

**Phase 2 — Next sprint:**
6. Create `.squad/streams.json` for SubSquads
7. Set up `squad build --check` in CI
8. Run `squad export` as backup
9. Configure `squad-ci.yml` with GDScript lint commands

**Phase 3 — Future:**
10. Create `FirstFrameStudios/squad-gamedev-plugins` marketplace
11. Set up `squad link` when second game starts
12. Explore `squad upstream` for cross-studio knowledge sharing

---

*Solo — Lead / Chief Architect, First Frame Studios*

# Decision: Sprite Test Viewer Updated for Cel-Shade Sprites

**Author:** Wedge (UI Dev)
**Date:** 2025-01-XX
**File:** `games/ashfall/scripts/test/sprite_poc_test.gd`

## What changed

Updated the test viewer to load cel-shade rendered sprites from the new directory structure (`res://assets/sprites/kael/` and `res://assets/sprites/rhena/`) instead of the outdated `res://assets/poc/v2/` path.

## Key decisions

1. **Auto-detect frame count** — Instead of hardcoding frame counts per animation, the viewer now loads frames sequentially (0000, 0001, ...) until a file is missing. This means new renders with different frame counts just work without code changes.

2. **Frame rate: 12fps loops, 15fps attacks** — Idle/walk use 12fps for a smooth but readable loop. Punch/kick use 15fps for snappier attack feel. These are standard fighting game rates.

3. **Replaced "lp" animation with punch/kick** — Old viewer had 3 anims (idle, walk, lp). New viewer has 4 (idle, walk, punch, kick) mapped to keys 1-4. K/R keys are now character-only (no longer doubled on 4/5).

4. **Background path changed to v1** — The `embergrounds_bg.png` only exists in `assets/poc/v1/`, not v2. Pointed the viewer there. This is still a placeholder BG — will need a proper stage asset eventually.

5. **Contact sheets ignored** — Each animation dir contains a `_sheet.png` contact sheet. The auto-detect loop naturally skips these since they don't match the `_NNNN.png` naming pattern.

