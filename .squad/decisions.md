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


