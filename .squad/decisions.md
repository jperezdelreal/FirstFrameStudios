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

### User Directive: GitHub Full Potential (2026-03-08T12:42:49Z)
**By:** joperezd (via Copilot)  
**Status:** Active  
**Scope:** Studio-wide operations

Use GitHub's full potential for game development — Issues for task tracking, Projects for boards, PRs for code review workflow. No empty repo; everything should be active and visible.

**Why:** User request — strategic guidance for GitHub-centric operations. Centralizes all work visibility, enables transparent sprint tracking, and leverages native GitHub features for coordination at scale.

---

### GitHub Issues Infrastructure for Ashfall Sprint 0 (Jango)
**Author:** Jango (Tool Engineer)  
**Date:** 2026-07-24  
**Status:** Implemented  
**Scope:** Ashfall project tracking — affects all agents

Set up GitHub Issues as the project management backbone for Ashfall Sprint 0 in `jperezdelreal/FirstFrameStudios`:

1. **Milestone:** "Ashfall Sprint 0" — groups all sprint work under one trackable milestone
2. **24 Labels** — structured labeling system for filtering and assignment:
   - `game:ashfall` — per-game filter (supports monorepo with multiple games)
   - `priority:p0/p1/p2` — priority tiers mapped to critical path
   - `type:feature/infrastructure/art/audio/design/qa` — work categories
   - `squad:{agent}` — one label per agent (14 agents) for ownership tracking
3. **13 Issues (#1–#13)** — critical path tasks from SPRINT-0.md with full descriptions and acceptance criteria

**Label Conventions:**

| Category | Color | Purpose |
|----------|-------|---------|
| `game:*` | Green (#0E8A16) | Filter by game in monorepo |
| `priority:p0` | Red (#B60205) | Critical path — blocks others |
| `priority:p1` | Orange (#D93F0B) | Sprint deliverable |
| `priority:p2` | Yellow (#FBCA04) | Nice-to-have / future phase |
| `type:*` | Blue/Purple/Pink | Work category |
| `squad:*` | Teal (#006B75) | Agent assignment |

**Impact on Team:**
- All agents should reference their issue number when committing code (e.g., `fixes #2`)
- Mace can use the milestone view for sprint tracking
- Close issues when acceptance criteria are met
- Future sprints follow the same label structure

**Why:** GitHub Issues as source of truth works if labels are consistent. Squad label filtering enables massive parallelism — 14-agent team can work simultaneously if they know their label space.

---

### GitHub Operations Setup (Mace, Producer)
**Date:** 2026-03-08  
**Status:** Implemented  
**Scope:** GitHub-centric project operations for FirstFrameStudios

**What Was Done:**

1. **README.md Development Section** ✅
   - Added "Development" section linking to Issues Board, Project Board creation guide, Wiki, and workflow diagram

2. **CONTRIBUTING.md Created** ✅
   - Complete workflow documentation
   - Branch naming convention: `squad/{issue-number}-{slug}`
   - Commit message format with examples
   - Label system explanation (game, squad, type, priority, status tags)
   - Squad agent work pickup (via labels and polling)
   - PR process standards, code review expectations
   - Load capacity governance (20% cap)

3. **team.md Updated** ✅
   - Added "Issue Source" section with repository connection and filters

4. **GitHub Wiki Status** ⏳
   - Wiki cannot be enabled via GitHub API
   - Manual action required: joperezd must enable in repo settings and create home page

**Decisions Made:**
- Label-driven work allocation — Squad agents query GitHub Issues by label
- Branch naming ties to issues — `squad/{issue-number}` enables automatic linking
- Wiki is optional, not critical — Processes in CONTRIBUTING.md; Wiki can host GDDs/ARCHs separately
- Load cap governance in CONTRIBUTING.md — Team understands 20% rule and enforcement
- Game-tagged filtering — Current sprint (`game:ashfall`) can be filtered; future games follow same model

**Why:** Centralizes visibility, removes ambiguity on workflow, supports multi-project parallelism, and enforces governance. Label system (`game:*`, `squad:*`, `priority:*`) scales with multi-agent teams.

---

### Heartbeat Reader Architecture (Jango, Tool Engineer)
**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-25  
**Status:** Implemented  
**Scope:** ffs-squad-monitor — monitoring infrastructure

**Decision:**  
The `/api/heartbeat` endpoint uses a **file-watch + cache** pattern rather than read-on-request:

1. **fs.watch on directory** — Watches parent directory of heartbeat file, survives file deletion/recreation cycles
2. **In-memory cache** — Heartbeat JSON parsed once on change and cached; requests serve from memory
3. **Configurable path** — `FFS_HEARTBEAT_PATH` env var enables deployment flexibility
4. **Graceful degradation** — File-not-found returns `{ status: 'offline' }` with HTTP 200 (not 404)
5. **BOM stripping** — All file reads strip UTF-8 BOM before JSON.parse (PowerShell generates files with BOM)

**Impact on Team:**
- Any agent writing heartbeat files should write plain UTF-8 without BOM, or consumers must strip it
- Vite plugin middleware pattern is how all dev-time APIs work; no separate server needed
- Offline state is first-class status (gray dot, not error); UI shows graceful degradation
- Solo/Chewie: Production deployment requires Node.js server equivalent (Vite middleware is dev-only)
- Ralph: Heartbeat file format is the contract; field name changes break the dashboard

**Why:** Avoids file I/O on every request. Atomic file rewriting ensures consistency. Environment configuration supports Docker deployment.

---

### Squad Monitor Dashboard Architecture (Wedge, UI/UX Developer)
**Author:** Wedge (UI/UX Developer)  
**Date:** 2025-07-24  
**Status:** Implemented  
**Scope:** ffs-squad-monitor project

**Decision:**  
Squad monitor dashboard uses component-based vanilla JS architecture without frameworks. Each UI section (heartbeat, log-viewer, repos, timeline, settings, connection-status) is an independent ES module under `src/components/`. Shared concerns live in `src/lib/`.

**Key Patterns:**
1. **Component contract:** Export `refresh*()` (async, called by scheduler) + optionally `init*()` (DOM event binding)
2. **Centralized API client** (`src/lib/api.js`): All fetch calls via `safeFetch()`. Connectivity tracked centrally; components subscribe via `onConnectionChange()`
3. **Configurable Scheduler** (`src/lib/scheduler.js`): Manages polling intervals with `register()`, `setInterval()`, `pause()`, `resume()`. UI settings wired to scheduler
4. **CSS custom properties** (`src/styles.css`): All colors/fonts/radii as `--tokens`. Dark theme matches GitHub. No CSS framework

**Impact on Team:**
- Any agent adding dashboard sections should follow component pattern (export `refresh*` + `init*`, use `lib/api.js`)
- CSS changes use existing custom properties, not hardcoded colors
- Monitor repo uses `master` as default branch (not `main`)
- Vanilla JS keeps bundle small (8KB gzipped), avoids framework lock-in

**Why:** Simplicity and modularity. Component pattern provides clear ownership boundaries and independent testability. Scheduler abstraction enables runtime polling configuration.

---

### localStorage Convention — Defensive Patterns (Ackbar, QA Lead)
**Author:** Ackbar (QA Lead)  
**Date:** 2025-07-24  
**Status:** Proposed  
**Scope:** Studio-wide localStorage usage

**Decision:**  
Formalize a studio convention for all localStorage usage based on patterns in Flora PR #22 (Encyclopedia) and ComeRosquillas PR #17 (High Scores). Both independently implemented identical defensive patterns:

- try/catch on load AND save
- Structure validation before trusting stored data
- Graceful degradation to empty state on corruption
- Console warnings (not errors) on failure

**Impact on Team:**
- All new games/features using localStorage must follow this pattern
- Consider extracting a shared `SafeStorage` utility if pattern is used in 3+ games
- Non-negotiable: console warnings should not escalate to errors; users should not see corruption as a fatal failure

**Why:** Data persistence is fragile (corruption, quota, deletion). Defensive patterns discovered independently by multiple agents should be standardized to prevent bugs in future projects.

---

### Flora Sprint 0 PR Review Outcomes (Solo, Lead/Chief Architect)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-11  
**Status:** Active  
**Scope:** Flora project — Sprint 0 integration and PR review gates

**Decisions Made:**

1. **PR #20 Hazard System — Approved** ✅
   - Architecturally sound, ready to merge
   - Clean config→entity→system separation
   - Integration wiring (tile state on pest spawn) handled by Solo in dedicated integration PR

2. **PR #21 Player Controller — Changes Requested**
   - Three must-fix issues before merge:
     - Movement must not consume action points (only tool use; per GDD §3)
     - ToolBar deselect callback bug (onToolSelect never fires with null on toggle)
     - System interface conformance (PlayerSystem needs `readonly name` property)
   - Lando assigned to fix in Round 2

3. **Integration Gap Identified: Pest ↔ Tile State**
   - Neither PR #20 nor #21 updates Tile.state to TileState.PEST when pests spawn
   - remove-pest tool checks tile.hasPest()
   - Solo will wire this in Sprint 0 integration PR

4. **Architecture Pattern Confirmation**
   - Flora Sprint 0 code correctly follows established patterns:
     - SceneContext injection (no singletons)
     - Fixed-timestep accumulator
     - Entity/System interfaces
     - Config-as-data for extensibility

**Impact on Team:**
- Tarkin: PR #20 can merge as-is
- Lando: PR #21 needs 3 targeted fixes + re-review
- Solo: Will create integration PR for HazardSystem ↔ GardenScene ↔ tile state
- Yoda: Should confirm pest spawn behavior (one-shot per season vs. ongoing pressure)

**Why:** Code review gates ensure architectural coherence. Pattern confirmation enables confident parallel work on future Flora features.

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
