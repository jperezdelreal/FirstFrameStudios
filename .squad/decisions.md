# Squad Decisions

## Active Decisions

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

### Chewie — Fighter Engine Infrastructure Decisions (2025-07-22)
**Author:** Chewie (Engine Developer)  
**Status:** Proposed  
**Scope:** Ashfall — fighter state machine, hitbox/hurtbox, round manager

Technical architecture decisions for Ashfall combat engine:

1. **Simplified Collision Layers (4 instead of 6)** — Using scaffold's existing 4 layers (Fighters, Hitboxes, Hurtboxes, Stage) for local play. Will expand to 6-layer per-player scheme when needed for 2v2 or complex self-hit prevention.
2. **Node Names Without "State" Suffix** — States named "Idle", "Walk", "Attack" (not "IdleState"). Makes transition calls clean: `transition_to("idle")`.
3. **Frame-Phase Attack State (Temporary)** — AttackState uses frame counters for hitbox timing. Will switch to AnimationPlayer-driven activation when Tarkin creates MoveData resources.
4. **Dual Signal Emission in RoundManager** — Both local signals (for FightScene wiring) AND EventBus global signals (for UI/VFX/audio decoupling). Slight redundancy for significant decoupling benefit.
5. **Input Wrappers (Not InputBuffer Yet)** — Placeholder thin wrappers over Input singleton, keyed by player_id. Lando will replace with full InputBuffer system per ARCHITECTURE.md.

**Impact:** Lando extends these with motion detection. Tarkin creates MoveData resources. Wedge wires signal connections. Solo reviews collision expansion path.

---

### Lando — Fighter Controller + Input Buffer Architecture (2025-07-21)
**Author:** Lando (Gameplay Developer)  
**Status:** Implemented  
**Scope:** Ashfall — input system and fighter gameplay layer

Core input system decisions:

1. **InputBuffer Routes ALL Input** — All fighter input flows through InputBuffer ring buffer (8-frame / 133ms leniency). Enables buffered inputs, motion detection, consume mechanics, AI injection, deterministic replay.
2. **Controller Handles Attacks, States Handle Movement** — FighterController owns attack priority (throw > specials > normals). States handle movement transitions (idle ↔ walk ↔ crouch ↔ jump). Separation prevents rewriting state logic.
3. **Motion Priority: Complex Beats Simple** — DP (→↓↘) beats QCF (↓↘→). Priority order: double_qcf > hcf/hcb > dp > qcf/qcb. Matches SF6/Guilty Gear standard.
4. **MoveData as Pure Resource** — Moves are `.tres` resource files. Designers tune frame data in Inspector without touching GDScript. Each character's moveset is exportable.
5. **8-Frame Input Leniency** — Sweet spot: generous enough for casual players, tight enough for precision-play pros. Tunable via `InputBuffer.INPUT_LENIENCY`.
6. **SOCD Resolution** — Left+Right = Neutral, Up+Down = Up (jump priority). FGC standard.

**Why:** "Player Hands First" — InputBuffer is the invisible engineering separating responsive from broken feeling.

---

### Lando — Integration Fixes (2025-07-17)
**Author:** Lando  
**Status:** PR Created  
**Scope:** Input & collision domain integration

Fixed integration issues:
1. **Removed Orphaned Throw Inputs** — p1_throw / p2_throw defined in project.godot but never read. Throws use LP+LK simultaneous press (fighter_controller.gd).
2. **Updated Collision Layer Documentation** — ARCHITECTURE.md documented 6-layer scheme never implemented. Updated to reflect actual 4-layer shared scheme in code.
3. **Fixed Stage Collision Layers** — Stage StaticBody2D now on Layer 4 (Stage), fighters detect Layer 4. Was working by accident with default Layer 1.
4. **Input Buffer Configuration Exported** — Converted BUFFER_SIZE, INPUT_LENIENCY, SIMULTANEOUS_WINDOW to @export for runtime Godot Inspector tuning.

**Impact:** Collision detection now explicit. Input buffer easily tunable for playtesting.

---

## Ashfall Art Sprint Directives (2026-03-09)

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

### Jango — GitHub Issues Infrastructure for Ashfall Sprint 0 (2025-07-24)
**Author:** Jango (Tool Engineer)  
**Status:** Implemented  
**Scope:** Ashfall project tracking — affects all agents

GitHub Issues setup as PM backbone for Sprint 0 in jperezdelreal/FirstFrameStudios:

1. **Milestone:** "Ashfall Sprint 0" groups all sprint work
2. **24 Labels:** Structured filtering system:
   - `game:ashfall` — per-game filter (monorepo support)
   - `priority:p0/p1/p2` — critical path tiers
   - `type:feature/infrastructure/art/audio/design/qa` — work categories
   - `squad:{agent}` — 14-agent ownership (one per agent)
3. **13 Issues (#1–#13):** Critical path tasks from SPRINT-0.md with full descriptions

**Why:** Every agent filters by their squad label. Milestone view shows sprint progress. Acceptance criteria self-validate completion. `game:ashfall` label future-proofs for multi-game monorepo.

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

### Solo — Integration Audit (2025-07-17)
**Agent:** Solo (Architect)  
**Status:** Completed  
**Verdict:** ⚠️ WARN — Project loads, no launch blockers, but issues need attention

**Autoload Check:** ✅ PASS — All 5 autoloads exist in dependency order (EventBus → GameState → VFXManager → AudioManager → SceneManager). Note: RoundManager exists but not registered as autoload.

**Scene References:** ✅ PASS — All 7 .tscn files have valid ext_resource references. Both .tres resource files valid.

**State Machine:** ✅ PASS — All 8 fighter states exist (Idle, Walk, Crouch, Jump, Attack, Block, Hit, KO). Base class inheritance correct.

**Input Map vs Controller:** ⚠️ WARN — Orphaned `p1_throw` / `p2_throw` in project.godot but never read (throws use LP+LK). Low impact, spec divergence.

**Collision Layers:** ⚠️ WARN — ARCHITECTURE.md documents 6-layer per-player scheme never implemented. Actual code uses 4-layer shared scheme. Alignment needed.

**Null Safety:** ⚠️ WARN — 8 `get_node()` calls without null checks. Should add defensive guards before M3.

**GDD Compliance:** ✅ SPOT CHECK PASS — Ember System, 6-button layout, deterministic simulation verified in code.

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

### Mace — Wiki Updates After Milestone Completion (2025-01-20)
**Author:** Mace (Producer)  
**Decision:** GitHub Wiki must be updated within 1 business day after each milestone completion

**Update Scope:**
1. **Home.md** — Milestone summary, completion status, merged PRs by category, infrastructure changes
2. **Ashfall-Sprint-0.md** — New milestone section, issue numbers, PR list, M3/M4 status
3. **Ashfall-Architecture.md** — New systems introduced, API docs, autoload details, scene links
4. **Ashfall-GDD.md** — Implementation notes, mechanics moved to "complete"
5. **Team.md** — Team size changes, review process updates

**Process:**
1. Assign one agent (Mace or Scribe) to wiki update task
2. Clone wiki repo to temp location
3. Update all pages in single commit
4. Push with: `docs: Update wiki for [Milestone Name] completion`
5. Verify wiki renders on GitHub

**Success Criteria:**
- ✅ All 5 pages updated
- ✅ Links correct, cross-references work
- ✅ Commit includes Co-authored-by trailer
- ✅ Push succeeds, wiki reflects changes within 5 minutes

**Owner:** Mace

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

### 2025-07-24: Godot Build Pipeline Architecture — Jango (Tool Engineer)

**Status:** Implemented (PR #111)

**Decision:** Automated builds and releases for Ashfall.

**Key Decisions:**

1. **Export Presets Versioned** — Needed for CI/CD (no credentials, only relative paths)
2. **Manual Godot Installation** — wget for Godot 4.6 (explicit version control)
3. **Tag-Triggered Releases** — Push v* tag → automatic build and GitHub Release
4. **Windows Desktop Only** — Initially. Can add Linux/Mac/Web later.
5. **Cross-Compilation on Ubuntu** — Linux runner exports Windows .exe

**Architecture:**
```
Tag push (v0.1.0) → GitHub Actions → Install Godot + templates 
  → Export to .exe → Zip → Create GitHub Release
```

**Deliverables:**
- `games/ashfall/export_presets.cfg` — Windows preset
- `.github/workflows/godot-release.yml` — Build workflow
- Root `.gitignore` updated

**Impact:**
- Developers: Create releases by pushing tag
- Players: Download and play without Godot
- QA: Test via manual workflow dispatch
- Future: Pipeline reusable for other projects

**Testing:** Merge PR #111 → test manual dispatch → create v0.0.1-test tag → validate

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

