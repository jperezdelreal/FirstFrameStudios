# Squad Decisions

## Active Decisions

### 2026-03-11: ComeRosquillas Modularization Architecture (Chewie)
**Date:** 2026-03-11  
**Author:** Chewie (Engine Developer)  
**Issue:** #1 — Modularize game.js monolith  
**Status:** ✅ Implemented (PR #10)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas shipped with a 1789-line game.js monolith containing all code: constants, audio, rendering, game logic, and initialization. This blocked parallel development and made code navigation difficult.

**Decision:**
Split game.js into 5 focused modules organized by responsibility with clean dependency flow.

**Module Structure:**
- **config.js** (114 lines): Constants, maze data (31×28), ghost configs, Simpsons colors, game states, direction vectors
- **engine/audio.js** (166 lines): SoundManager class — Simpsons theme, D'oh sound, Duff jingle, background music
- **engine/renderer.js** (720 lines): Sprites static class — Homer rendering, 4 ghost characters (Burns, Bob, Nelson, Snake), donut/Duff, maze
- **game-logic.js** (791 lines): Game class — game loop, state machine (7 states), player movement, ghost AI (scatter/chase/frightened), scoring, level progression
- **main.js** (13 lines): Entry point — thin instantiation of Game

**Load Order (Dependency DAG):**
```
config.js (no deps)
  ↓
audio.js (uses config)
  ↓
renderer.js (uses config)
  ↓
game-logic.js (uses all)
  ↓
main.js (instantiates Game)
```

**Rationale:**
1. **Config as Foundation** — Pure data, zero dependencies enables safe parallel work on rendering and game logic
2. **Engine Separation** — Audio and renderer are orthogonal concerns, separate files enable parallel development
3. **Static Renderer** — Sprites class uses static methods (no instance state), simplifies testing, eliminates object allocation
4. **No Bundler** — Vanilla JS project with simple DAG, `<script>` tags provide explicit load order, low development friction

**Alternatives Rejected:**
1. **ES Modules** — Would require export/import syntax changes. Global namespace approach simpler for vanilla JS.
2. **Split Renderer by Entity** (player.js, ghosts.js, maze.js) — Drawing code tightly coupled to config constants. 720-line cohesion preferable to fragmentation.
3. **Webpack/Vite Bundle** — Adds build step complexity. Browser handles 5 files efficiently.

**Consequences:**
- ✅ Clear module responsibilities, parallel development enabled, static methods easily testable
- ✅ Maintainability improved: code navigation easier, onboarding clearer
- ❌ Global namespace risk if naming conflicts arise (mitigated by discipline)
- ❌ Load order dependency — index.html must maintain correct script order (easy to break)

**Testing:**
- ✅ Game loads and plays after modularization
- ✅ All sounds, rendering, gameplay, scoring, level progression work identically
- ✅ Zero breaking changes

**Future Work:**
- Consider ES modules when browser support matures
- Extract maze data to JSON if editing becomes frequent
- Add JSDoc for IDE autocomplete
- Split game-logic.js if it grows beyond 1000 lines

---

### 2026-03-11: ComeRosquillas CI Pipeline Strategy (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Issue:** #6 — Add CI pipeline with validation and deploy checks  
**Status:** ✅ Implemented (PR #9)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas is a vanilla HTML/JS/Canvas game (no build step). Need lightweight CI that validates code quality and enables live PR preview without adding bundler complexity.

**Decision:**
Implemented GitHub Actions workflow (`ci.yml`) with JavaScript syntax validation, HTML structure checks, and automated PR preview comments.

**Workflow Details:**
- **Triggers:** All PRs and main pushes
- **Execution Time:** ~30 seconds
- **Validations:**
  - HTML structure (canvas element, script references)
  - JavaScript syntax (`node --check` on all .js files)
  - Game assets structure
  - Code quality (no debugger statements, TODO awareness)
- **Output:** Automated PR comment with validation results and deployment URLs

**Rationale:**
1. **Keep It Simple** — No build step for vanilla game. Bundlers (webpack, parcel) would slow development.
2. **Fast Feedback** — 30-second runs provide immediate validation on every commit.
3. **PR Experience** — Comments with validation + deploy links in one place improve developer workflow.
4. **Separation of Concerns** — CI validation (this) ≠ Deployment (existing deploy-pages.yml) ≠ Squad framework (squad-ci.yml)
5. **Node.js Native** — `node --check` for JS validation. Can extend with ESLint/Prettier later if needed.

**Alternatives Rejected:**
1. **Add ESLint/Prettier** — Too much config overhead for v1.0. Can add later if style becomes an issue.
2. **HTML Validator Service** — External dependency + network calls. Simple grep sufficient for now.
3. **Playwright/Puppeteer E2E Tests** — No test files exist yet. CI focuses on syntax first. E2E can be added in future sprints.
4. **Combine with squad-ci.yml** — Squad-ci.yml is squad-framework specific. Kept separate for clarity.

**Consequences:**
- ✅ Fast CI runs, zero dependencies beyond Node.js, clear validation messages, improves developer experience
- ✅ Does not interfere with existing Astro docs deployment
- ❌ No code style enforcement yet (no linter), no E2E tests, manual grep checks
- ✓ Can extend with ESLint, Prettier, Playwright later without major rearchitecture

**Follow-up:**
- Add ESLint + Prettier if code style issues arise
- Add Playwright E2E tests when game stabilizes
- Add Lighthouse CI for performance checks
- Monitor CI run times — optimize if they exceed 2 minutes

---

### 2026-03-11: ComeRosquillas Issue Triage & Squad Routing (Solo)
**Date:** 2026-03-11  
**Author:** Solo (Lead/Architect)  
**Scope:** Assign squad routing labels to all 8 open issues  
**Status:** ✅ Complete  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas shipped with 8 open GitHub issues. None had squad routing labels, blocking Ralph's auto-assignment workflow.

**Decision:**
Triaged all 8 issues with squad routing + priority labels, creating 14 labels in repo and applying them to each issue with rationale comments.

**Triage Results:**

| Issue | Title | Assigned To | Priority | Rationale |
|---|---|---|---|---|
| #1 | Modularize game.js | solo + chewie | P0 | Blocks everything downstream (cascades to #3, #4, #5, #7, #8) |
| #2 | Mobile/touch controls | wedge | P2 | Platform expansion, non-blocking for v1.0, post-launch polish |
| #3 | High score persistence | wedge + lando | P2 | Engagement feature, not critical for core loop, post-launch |
| #4 | Multiple maze layouts | tarkin + lando | P1 | Critical for replayability, v1.0 essential, start after #1 |
| #5 | Simpsons intermission cutscenes | wedge | P3 | Pure charm/narrative, deferred until core stable |
| #6 | CI pipeline | jango | P1 | Unblocks velocity, tooling investment, parallel stream |
| #7 | Ghost AI improvement | tarkin | P1 | Gameplay core (difficulty + personality), v1.0 essential |
| #8 | Sound effects variety | greedo | P1 | Sound IS gameplay feel, v1.0 essential |

**Routing Philosophy:**
- **P0 (Critical):** Unblocks everything downstream (only #1)
- **P1 (Ship-Blocking):** Must complete before v1.0 release (#4, #6, #7, #8). Can run in parallel.
- **P2 (Medium):** Valuable engagement features, ship after v1.0 stable (#2, #3)
- **P3 (Polish):** Pure charm/narrative, deferred (#5)

**Key Insight — Monolithic Anti-Pattern Repeats:**
- firstPunch: gameplay.js = 695 LOC → architecture refactor was P0
- ComeRosquillas: game.js = 1636 LOC → architecture refactor is P0

**Implication:** Studio should establish **architectural debt prevention pattern**:
- Max 300-400 LOC per module before auto-triggering refactor review
- Modular architecture designed upfront, not retrofitted
- Code organization as critical as feature completion

---

### 2026-03-11: Create ffs-squad-monitor Repository (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Requested by:** Joaquín  
**Status:** ✅ Implemented

**Context:**
Joaquín wants a real-time monitoring dashboard for the FFS squad, inspired by [Tamir Dresher's squad-monitor](https://github.com/tamirdresher/squad-monitor). We already have `ralph-watch.ps1` writing heartbeat data and structured logs — we need a visual frontend.

**Decision:**
Created a new public repo `jperezdelreal/ffs-squad-monitor` with:
- Vite + vanilla JS stack (lightweight, learning-friendly)
- Sprint 0 scaffolding: dashboard HTML, heartbeat polling script, mock data
- 5 roadmap issues covering heartbeat reader, log viewer, timeline, UI, and Actions integration
- Squad initialized with upstream link to FirstFrameStudios

**Rationale:**
- **Separate repo** keeps monitoring concerns out of the main FFS codebase
- **Vite + vanilla JS** is minimal, fast to iterate, and good for learning
- **Read-only observer pattern** — monitor reads heartbeat/logs but never writes to FFS
- **Sprint 0 = scaffolding only** — real implementation tracked via GitHub Issues

**Links:**
- Repo: https://github.com/jperezdelreal/ffs-squad-monitor
- Issues: https://github.com/jperezdelreal/ffs-squad-monitor/issues
- Inspiration: https://github.com/tamirdresher/squad-monitor

---

### 2026-03-11: Squad Upstream Setup — ComeRosquillas → FirstFrameStudios (Jango)
**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Status:** IMPLEMENTED  
**Scope:** Infrastructure / Squad Architecture

**Context:**
ComeRosquillas (Homer's Donut Quest) was absorbed into First Frame Studios at `games/comerosquillas/`. The standalone ComeRosquillas repo (jperezdelreal/ComeRosquillas) needs to inherit studio identity, skills, and process from the FFS hub.

The approved architecture is **Option C Hybrid**:
- **FirstFrameStudios** = Studio hub (parent squad with identity, skills, principles)
- **Game repos** = Subsquads inheriting via upstream connection

**Decision:**
Set up a manual upstream connection since `squad-cli v0.8.20` does not yet have native `upstream` commands.

**What Was Done:**
1. **Squad initialized** in ComeRosquillas via `squad-cli init --no-workflows`
2. **Upstream directory created** at `.squad/upstream/` with:
   - `manifest.json` — connection metadata, sync policy, inherited content list
   - `identity/` — copied identity files from FFS (principles, mission-vision, company, quality-gates, wisdom)
   - `skills/INDEX.md` — reference index of 41 FFS skills (categorized by applicability)
3. **Config updated** — `.squad/config.json` includes upstream hub reference
4. **upstream.json enriched** — added repo, relationship, last_synced, synced_content fields
5. **Committed and pushed** to `main`

**Sync Policy:**

| Content Type | Strategy | Notes |
|---|---|---|
| Identity files | Copy from hub | Upstream wins — these are studio-level |
| Skills | Reference index only | Full content stays in hub repo |
| Decisions | Reference only | Game-specific decisions stay local |
| Project config | Local only | Game-specific settings |

**How to Re-sync:**
When FFS identity or skills change, manually copy updated files:
```powershell
cd "C:\Users\joperezd\GitHub Repos\ComeRosquillas"
Copy-Item "C:\Users\joperezd\GitHub Repos\FirstFrameStudios\.squad\identity\{file}" ".squad\upstream\identity\{file}"
# Update last_synced in .squad/upstream.json
```

**Alternatives Considered:**
1. **Native `squad upstream` commands** — Not available in v0.8.20. When squad-cli adds this feature, migrate to native commands.
2. **Git submodules** — Too heavy for configuration inheritance. Submodules are for code, not squad metadata.
3. **Symlinks** — Don't work across repos on GitHub. Only viable for local development.

**Migration Path:**
When `squad-cli` ships `upstream add/sync/list`:
1. Run `squad upstream add` pointing to FFS
2. Run `squad upstream sync` to replace manual copies
3. Remove manual `.squad/upstream/` directory if native upstream uses a different structure
4. Update this decision document

**Risks:**
- **Manual sync drift** — If FFS identity changes and nobody syncs downstream, ComeRosquillas will have stale studio guidance. Mitigated by: checking sync date during ceremonies.
- **squad-cli breaking changes** — If a future version introduces native upstream with a different structure, migration will be needed.

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

### 2026-03-10: New Project Proposals Ceremony
**By:** Full Team (6 agents — Yoda, Chewie, Lando, Boba, Solo, Tarkin)  
**What:** 18 game proposals generated with internet research for post-Ashfall direction. Top 5 ranked by AI-friendliness, scope, and viral potential:
1. **LAST SIGNAL** (micro-horror radio routing, 2 wk MVP) — Yoda's pick
2. **FLORA** (cozy gardening roguelite with L-systems, 3 wk MVP) — Boba's pick
3. **RICOCHET RAMPAGE** (physics destruction arcade, 3 wk MVP) — Lando's pick
4. **FACTORY FLUX** (automation puzzle roguelite, 4 wk MVP) — Solo's pick
5. **SHADOW THIEF** (stealth platformer as shadow, 4 wk MVP) — Boba's runner-up

**Why:** Ashfall closure ceremony concluded the studio needs simpler, web-first games that leverage rapid prototyping strengths. All 18 proposals designed to avoid Ashfall's failure modes (subjective feel tuning, complex art pipelines, genre complexity).

**Status:** AWAITING FOUNDER DECISION — Joaquín to review and select direction.

---

### 2026-03-11: Upstream + SubSquad + Blog Patterns Architecture Proposal
**By:** Solo (Lead Architect) + Jango (Tool Engineer)  
**Status:** AWAITING FOUNDER APPROVAL  
**What:** Complete implementation plan for incorporating Tamir Dresher blog patterns + upstream + subsquad into FFS workflow.

**Architecture Decision: Option C — Hybrid (RECOMMENDED)**
- `FirstFrameStudios/` = Studio hub (parent squad with identity, skills, principles)
- `jperezdelreal/flora` = Game repo (subsquad, inherits via `squad upstream`)
- Scales to future games: new repo + `squad upstream add FirstFrameStudios`
- 11 FLORA agents active, 3 hibernated (Leia, Bossk, Nien)

**Implementation Phases:**
- Phase 0: Restructure studio hub, TLDR convention (Day 1)
- Phase 1: Create FLORA repo, squad init, squad upstream (Day 1-2)
- Phase 2: CI/CD, workflows, issue templates, project board (Day 2-3)
- Phase 3: ralph-watch + scheduler (Day 3-4)
- Phase 4: FLORA Sprint 0 — build the game! (Day 4+)
- Phase 5: Podcaster + Squad Monitor (Week 2+)

**Tooling Priority:**
- DO FIRST: Issue template, heartbeat cron, TLDR convention, archive/notify workflows (~5h)
- DO NEXT: ralph-watch.ps1, scheduler, daily-digest, drift-detection (~24h)
- DO LATER: Squad Monitor, Podcaster (~5h)

**Full plans available in session context. Awaiting Joaquín's go/no-go.**

---

### 2026-03-11: Autonomy Gap Audit — Planned vs Implemented
**By:** Solo (Lead Architect)  
**Requested by:** Joaquín  
**Status:** INFORMATIONAL — input to prioritization

**Context:**
Joaquín flagged frustration: the squad planned an autonomous execution model (from Tamir Dresher blog patterns, Option C hybrid architecture in `solo-upstream-subsquad-proposal.md`) but much of it remains unimplemented. This audit compares what was **planned** in the inbox decisions vs what **actually exists** in the repo.

**Source Documents Analyzed:**
1. `copilot-tamir-blog-learnings.md` — 16 operational patterns from Tamir's blog
2. `solo-upstream-subsquad-proposal.md` — Option C hybrid implementation plan (5 phases)
3. `copilot-directive-2026-03-11T0745-repo-autonomy.md` — Founder directive: agents can create repos autonomously

**Gap Matrix:**

| # | Pattern / Plan Item | Status | Evidence |
|---|---------------------|--------|----------|
| 1 | **GitHub Issues = Central Brain** | ✅ IMPLEMENTED | Issue templates exist (`.github/ISSUE_TEMPLATE/squad-task.yml`), triage workflow exists, labels created |
| 2 | **Ralph Outer Loop (`ralph-watch.ps1`)** | ⚠️ BUILT, NOT ACTIVATED | Script exists at `tools/ralph-watch.ps1` (fully implemented, single-instance guard, heartbeat, structured logging). **Never run persistently.** Heartbeat file exists but is likely stale. |
| 3 | **Maximize Parallelism in Ralph** | ❌ NOT TESTED | Ralph prompt exists but parallel agent spawning not validated in production runs |
| 4 | **Two-Way Communication via Webhooks** | ❌ NOT IMPLEMENTED | No webhook integration, no Teams/Slack adapter, no notification channel configured |
| 5 | **Auto-Scan External Inputs** | ❌ NOT IMPLEMENTED | No email/Teams/HackerNews scanning. No `teams-bridge` label usage. |
| 6 | **Podcaster for Long Content** | ❌ NOT IMPLEMENTED | No Edge TTS integration. Phase 5 item — correctly deferred. |
| 7 | **Self-Built Scheduler** | ⚠️ BUILT, NOT ACTIVATED | `tools/scheduler/Invoke-SquadScheduler.ps1` exists with cron evaluator. Needs `schedule.json` tasks defined and actual activation via ralph-watch. |
| 8 | **Squad Monitor Dashboard** | ❌ NOT IMPLEMENTED | Not installed (`dotnet tool install -g squad-monitor` never run). Phase 5 item. |
| 9 | **Side Project Repos** | ⚠️ AUTHORIZED, NOT USED | Founder directive grants autonomy for repo creation. No side repos created yet. |
| 10 | **GitHub Actions Ecosystem** | ✅ MOSTLY IMPLEMENTED | 20+ workflows exist: triage, heartbeat, daily-digest, drift-detection, archive-done, label-enforce, label-sync, CI, docs, preview, release. **Comprehensive.** |
| 11 | **Self-Approve PRs** | ❌ NOT CONFIGURED | No auto-merge setup. PRs require human review. |
| 12 | **Cross-Repo Contributions** | ❌ NOT STARTED | No upstream PRs to Squad repo or other tools |
| 13 | **`squad upstream` for inherited context** | ❌ NOT IMPLEMENTED | Option C planned studio-hub + game-repo inheritance. No `squad upstream` configured. ComeRosquillas lives inside FFS repo, not as a subsquad. |
| 14 | **Multi-repo management** | ❌ NOT IMPLEMENTED | ralph-watch supports `$Repos` param but only single repo in use |
| 15 | **TLDR Convention** | ⚠️ DOCUMENTED, NOT ENFORCED | Team knows the pattern. No automated enforcement. No CI check for TLDR in issue comments. |
| 16 | **Issue Template** | ✅ IMPLEMENTED | `.github/ISSUE_TEMPLATE/squad-task.yml` exists |

**Phase Tracking (from `solo-upstream-subsquad-proposal.md`):**

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 0** | Restructure studio hub, TLDR convention | ⚠️ PARTIAL — hub exists, TLDR not enforced |
| **Phase 1** | Create game repo, squad init, squad upstream | ❌ NOT STARTED — ComeRosquillas absorbed into FFS, no subsquad |
| **Phase 2** | CI/CD, workflows, issue templates, project board | ✅ MOSTLY DONE — workflows are comprehensive |
| **Phase 3** | ralph-watch + scheduler | ⚠️ BUILT, NOT ACTIVATED |
| **Phase 4** | Game Sprint 0 — build the game | ⚠️ IN PROGRESS — ComeRosquillas exists (1636 LOC, playable) but no sprint structure |
| **Phase 5** | Podcaster + Squad Monitor | ❌ NOT STARTED (correctly — Phase 5) |

**Summary: What's Actually Blocking Autonomy:**

The infrastructure is **more built than it appears**. The real gap is **activation, not construction**:

1. **ralph-watch.ps1 needs to be started and left running.** The script is production-ready with single-instance guards, heartbeat, logging, and multi-repo support. It just hasn't been turned on.

2. **Scheduler needs tasks defined.** `Invoke-SquadScheduler.ps1` works but `schedule.json` needs actual recurring tasks (daily playtest, weekly retro, drift detection triggers).

3. **TLDR enforcement is cultural, not technical.** Agents write TLDRs when reminded. Need a lightweight CI check or prompt-level convention reinforcement.

4. **The subsquad/upstream model was abandoned** in favor of absorbing ComeRosquillas directly into FFS. This is fine for a single game but won't scale. Decision needed: is this the permanent model or a temporary expedient?

5. **Webhooks/notifications are the biggest true gap.** No way for the squad to proactively signal Joaquín when something important happens. This is the highest-leverage unbuilt feature.

**Recommended Priority Order:**
1. **P0:** Activate ralph-watch persistently (DevBox or local machine)
2. **P0:** Define schedule.json with 3-5 recurring tasks
3. **P1:** Install Squad Monitor (`dotnet tool install -g squad-monitor`)
4. **P1:** Add webhook notification for critical events (CI failure, PR merged)
5. **P2:** Evaluate subsquad model for ComeRosquillas vs monorepo approach
6. **P2:** Podcaster integration for long reports

---

### 2026-03-11: Autonomous Infrastructure Pivot to ComeRosquillas
**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Status:** Implemented

**Context:**
The autonomous loop infrastructure (ralph-watch, scheduler, heartbeat) was built during the FLORA planning phase but never became operational. The studio focus has shifted to ComeRosquillas (Homer's Donut Quest), a web game at `games/comerosquillas/` using HTML/JS/Canvas.

**Decision:**
1. **now.md** points to ComeRosquillas as the active project (not FLORA)
2. **Scheduler tasks** reference web-game workflows (browser playtest, browser compat) instead of Godot builds
3. **Backlog grooming** is enabled (was disabled)
4. **tools/README.md** documents how to start the autonomous loop with one command
5. **Legacy Godot tools** remain in `tools/` for reference but are documented as archived

**Consequences:**
- Any agent reading `now.md` will know the active game is ComeRosquillas
- The scheduler will create web-game-appropriate issues when ralph-watch runs
- Joaquín can start the full loop with `.\tools\ralph-watch.ps1`

**Team Impact:**
- **All agents:** now.md context is current — no confusion about FLORA vs ComeRosquillas
- **Ackbar:** Playtest issues now include browser checklist instead of Godot build instructions
- **Mace:** Backlog grooming is back on the schedule (Wednesdays)
- **Ralph:** Loop is verified operational — just needs to be started

---

### 2026-03-11: Learnings from Tamir Dresher's "Organized by AI" blog
**By:** Joaquín (via Copilot) — team reading assignment  
**Source:** https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai  
**What:** Key patterns from a power-user who runs Squad as his daily productivity system.

**Operational Patterns We Should Adopt:**

1. **GitHub Issues = Central Brain.** All Squad discussion happens IN issue comments. Agents always write TLDR at top of every comment. The founder reviews TLDRs, writes instructions in comments, sets status back to "Todo." Everything is documented, searchable, nothing lost.

2. **Ralph Outer Loop (`ralph-watch.ps1`).** Wraps Ralph in a persistent PowerShell loop that: (a) pulls latest code before each round, (b) spawns fresh Copilot sessions each time, (c) has heartbeat files, structured logging, failure alerts. Runs on machine or DevBox unattended.

3. **Maximize Parallelism in Ralph.** Prompt explicitly says: "If there are 5 actionable issues, spawn 5 agents in one turn." Don't work issues one at a time.

4. **Two-Way Communication via Webhooks.** Squad sends Teams/Slack messages for critical events (CI failures, PR merges, blocking issues). Uses Adaptive Cards with styled formatting. Rule: only send when genuinely newsworthy, never spam.

5. **Auto-Scan External Inputs.** Squad reads emails (Outlook COM), Teams messages, and tech news (HackerNews, Reddit). Creates GitHub issues automatically for actionable items. Labels like `teams-bridge` distinguish auto-created from manual.

6. **Podcaster for Long Content.** Converts markdown reports to audio via Edge TTS. Listen to 3000-word reports while walking. Auto-triggered after significant deliverables (>500 words).

7. **Self-Built Scheduler.** `Invoke-SquadScheduler.ps1` — cron-based triggers for recurring tasks (daily scans, weekly reports). Maintains state file. Runs before each Ralph round.

8. **Squad Monitor Dashboard.** Real-time .NET tool showing agent activity, token usage, costs. Open-sourced at github.com/tamirdresher/squad-monitor. `dotnet tool install -g squad-monitor`.

9. **Side Project Repos.** Squad creates their own repos for tools/utilities that shouldn't clutter the main repo. Links back to main project.

10. **GitHub Actions Ecosystem.** Workflows for: triage, heartbeat (5 min), daily digest, docs auto-gen, drift detection (weekly), archive done issues (7 days), notifications, label enforcement, label sync from team.md.

11. **Self-Approve PRs (Personal Repos).** For personal repos, Squad creates, reviews, and merges their own PRs. Human only jumps in for areas they care about or flagged reviews.

12. **Cross-Repo Contributions.** Squad naturally contributes back upstream to tools they use (PRs to Squad repo itself).

**Philosophy Shifts:**

- **"I don't manage tasks anymore. I manage decisions."** — The human focuses on decisions, Squad does everything else.
- **"AI is the first approach that meets me where I am."** — AI adapts to human chaos, not the other way around.
- **"The boundary between using a tool and building a tool dissolved."** — Squad evolved its own tools (monitor, scheduler, tunnel) as needs arose.
- **Squad as brain extension, not replacement.** — User still makes all important decisions. AI remembers, does tedious work, keeps systems running.

**Multi-Repo & Upstream Patterns (Joaquín highlighted these):**

13. **`squad upstream` for inherited context.** Tamir used the `upstream` command to inherit decisions, skills, and team context from parent squads. His personal Squad connects to work repos so agents can scan and learn from them without copy-pasting context. This enables hierarchical squad organization — one parent Squad with shared knowledge, child Squads per project.

14. **Multi-repo management.** Squad agents create and manage their OWN repos when they need standalone tools (squad-monitor, cli-tunnel, squad-personal-demo). Ralph's prompt includes `MULTI-REPO WATCH` to scan multiple repos for actionable issues in a single round. Example: `"In addition to tamresearch1, also scan tamirdresher/squad-monitor for actionable issues."`

15. **Cross-repo contributions upstream.** Agents contributed PRs back to the Squad repo itself: ADO Platform Adapter (PR #191), CommunicationAdapter (PR #263), SubSquads (PR #272), Upstream & Watch commands (PR #280), test resilience (PR #283). The boundary between "using a tool" and "building a tool" dissolved completely.

16. **Side project repos as first-class workflow.** When agents need a standalone tool, they create a repo, build it there, and link back to the main project. Just like a real engineer saying "I'll build this separately so it doesn't clutter the main project." Examples: squad-monitor (real-time dashboard, open-sourced), cli-tunnel (remote terminal access).

**Applicable to First Frame Studios:**

- We should adopt the **GitHub Issues as backbone** pattern — all agent work documented in issue comments with TLDRs
- We should explore **ralph-watch.ps1** for unattended operation during long builds/sprints
- **Squad Monitor** could give Joaquín visibility into what agents are doing during long parallel spawns
- The **Podcaster** pattern could help Joaquín consume long analysis docs (we generate a LOT of analysis)
- **GitHub Actions workflows** (triage, heartbeat, daily digest) would automate our current manual processes
- The **self-built scheduler** pattern would enable recurring tasks (daily playtest, weekly retro)
- **`squad upstream`** could let FFS have a master Squad with studio-wide knowledge (principles, conventions, skills) inherited by each game project's Squad — shared wisdom without duplication
- **Multi-repo watch** in Ralph would let us monitor both the main FFS repo AND any game-specific repos (e.g., a separate `games/flora` repo) from a single Ralph loop
- **Cross-repo contributions** — our agents could contribute improvements back to Squad itself when they hit limitations, just like Tamir's team did

---

### 2026-03-11T07:45: User directive — Side Project Repo Autonomy
**By:** Joaquín (via Copilot)  
**What:** Los agentes pueden crear repos públicos bajo demanda sin aprobación previa. Ellos deciden el nombre, qué agentes asignar, y todo lo que haga falta para el side project. Autonomía total en gestión de repos.

**Why:** User request — captured for team memory. Enables Tamir-style "side project repos as first-class workflow" pattern.

---

### 2026-03-10T22:06: User directive — Visual Quality Standard
**By:** Joaquín (via Copilot)  
**What:** Los juegos propuestos deben ser VISTOSOS — nada de cutreces baratas. Visualmente impresionantes pero rápidos de hacer. El objetivo es aprender cosas nuevas (frameworks como Vite, etc.) y hacer show off. Explorar lo que hay en la web: gente usando Squad/AI para completar juegos tipo Pokémon, nuevos frameworks, ideas novedosas sin sobrecomplicaciones.

**Why:** User request — captured for team memory. Establishes visual quality as non-negotiable criteria for next project selection.

---

### 2026-03-10: Ashfall Project Closure
**By:** Full Team (closure ceremony)  
**What:** Ashfall (1v1 fighting game, Godot 4) officially shelved after 2 complete sprints. Key lessons: fighting games too complex for AI-only tuning, art pipeline needs validation before production, integration gates must be automated from Day 1, Lead Architect role must split at 10+ agents.

**Why:** Team consensus — the genre requires subjective feel-tuning that AI agents cannot deliver. Studio pivoting to simpler, faster-to-ship game genres.

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

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

### 2026-03-11T11:20: User directive
**By:** Joaquín (via Copilot)
**What:** No Podcaster. No queremos integración de text-to-speech ni conversión de reports a audio.
**Why:** User decision — out of scope for FFS.

---

### 2026-03-11T12:16Z: User directive — GitHub Pages architecture and purpose
**By:** Joaquin (via Copilot)
**What:** Each repo has its own GitHub Pages site with distinct purpose:
- **FFS Hub Page** → Brand, identity, studio presentation. "AI Gaming Studio Hub". NOT game content.
- **Game Pages** (ComeRosquillas, Flora, etc.) → Game showcase: screenshots, changelog, playable demo (Play button).
- All Pages share a consistent Astro template/theme from FFS but with per-game branding/colors.
- Updates are automated: push to main → Actions rebuild → Pages deploys.
**Why:** User request — defines the purpose and content structure of each GitHub Pages site across the multi-repo architecture.

---

### 2026-03-11T12:19Z: User directive — FFS homepage and blog strategy
**By:** Joaquin (via Copilot)
**What:** 
1. FFS homepage is practically perfect as-is — do NOT redesign it.
2. FFS blog should auto-publish summarized progress updates from game repos (advances, milestones, releases).
3. Push-to-main workflow is correct for both hub and game repos.
**Why:** User request — preserves current hub design and establishes blog as the living chronicle of studio activity.

---

# Multi-Repo Studio Governance — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-24  
**Requested by:** Joaquín (Founder)  
**Status:** ⏳ AWAITING FOUNDER APPROVAL  
**Scope:** Studio-wide — defines how FFS operates as a multi-repo studio hub

---

## Preamble

Joaquín asked the fundamental governance question: **how does everything flow in a multi-game studio?** This document answers that question across 9 domains. Once approved, it becomes the operating manual for First Frame Studios.

**Studio Topology:**
```
FirstFrameStudios (Hub)
├── jperezdelreal/ComeRosquillas  (Game repo — HTML/JS/Canvas)
├── jperezdelreal/flora            (Game repo — Vite/TS/PixiJS, on hold)
├── jperezdelreal/ffs-squad-monitor (Tool repo — Vite/JS)
└── [future repos]                 (Created on demand per Repo Autonomy directive)
```

**Key Actors:**
- **Joaquín** — Founder. Vision, direction, go/no-go decisions. Never reviews code.
- **Solo** — Hub Lead / Chief Architect. Architecture, integration, governance.
- **Jango** — Tool Engineer / PR Reviewer. All code reviews, CI/CD, tooling.
- **Mace** — Producer. Sprint planning, ops, blocker tracking.
- **Yoda** — Game Designer / Vision Keeper. Creative coherence per project.
- **@copilot** — Coding agent. Executes well-defined tasks autonomously.
- **Ralph** — Work Monitor. Heartbeat, scheduling, multi-repo watch.

---

## 1. APPROVAL FLOW

### 1.1 Tiered Approval Model

| Tier | What | Approver | Turnaround | Examples |
|------|------|----------|------------|----------|
| **T0 — Auto-Approved** | Routine work matching existing patterns | No human approval needed | Immediate | Bug fixes, test additions, dependency updates, docs updates, @copilot issue work |
| **T1 — Agent-Reviewed** | Implementation PRs, feature work | Jango (PR Reviewer) | Same session | New features, refactors, gameplay changes, UI work, audio additions |
| **T2 — Lead-Reviewed** | Architecture changes, cross-system work | Solo (Lead) + Jango | Same day | New systems, module restructuring, API changes, integration PRs |
| **T3 — Founder-Decided** | Direction, vision, go/no-go | Joaquín | Async (via issue comment) | New game selection, project closure, team changes, budget decisions, this document |

### 1.2 Per-Repo Approval Rules

**Hub (FirstFrameStudios):**
- Identity/principles/wisdom changes → T3 (Founder)
- Team/routing/ceremonies changes → T2 (Solo)
- Skills creation/updates → T1 (Jango reviews, domain expert authors)
- Tool scripts (ralph-watch, scheduler) → T1 (Jango)
- Decision documents → T2 (Solo proposes, Founder approves if T3)

**Game Repos (ComeRosquillas, Flora, future games):**
- Gameplay code PRs → T1 (Jango reviews)
- Architecture decisions → T2 (Solo reviews)
- Game-specific .squad/ config → T0 (auto-approved, game squad manages)
- New game milestones/sprints → T2 (Mace + Solo + Yoda plan)
- Ship/no-ship decision → T3 (Founder)

**Tool Repos (ffs-squad-monitor, future tools):**
- Implementation PRs → T1 (Jango reviews)
- Creation of new tool repo → T0 (per Repo Autonomy directive, 2026-03-11)
- Tool repo architecture → T1 (Jango, since tool repos are Jango's domain)

### 1.3 Does Every PR Need Approval?

**Yes, but the level varies:**
- **T0 PRs** (bug fixes, docs, tests): Jango can fast-track approve or @copilot can self-merge if `copilot-auto-assign: true` is set and CI passes.
- **T1 PRs** (features): Jango reviews. One approval required. No Joaquín involvement.
- **T2 PRs** (architecture): Solo + Jango both review. Two approvals required.
- **T3 PRs** (governance): Joaquín approves via issue comment. Squad implements.

### 1.4 Can Game Repos Self-Approve?

**Yes, within bounds.** Game squads operate autonomously for T0 and T1 work:
- Game-internal features, bugs, and content → self-approved by game squad's reviewer (Jango)
- Cross-repo changes (upstream sync, shared tool integration) → Hub review (Solo)
- Game closure/archival → Founder decision (T3)

**Rule:** If the change stays inside the game repo and doesn't affect studio identity, skills, or team structure, the game squad approves it. If it flows upstream, Hub reviews.

---

## 2. AUTONOMY LEVELS

### 2.1 Autonomy Matrix by Repo Type

| Autonomy Level | Hub | Game Repo | Tool Repo |
|----------------|-----|-----------|-----------|
| **Full Autonomy** (no ask needed) | Tool scripts, orchestration logs, session logs | Gameplay code, game-specific bugs, local .squad/ config, issue creation, sprint execution | All implementation, architecture, issues, releases |
| **Notify Hub** (do it, then tell) | Skill updates, ceremony changes | New milestone start, dependency on hub skill, architecture deviations | Integration points with other repos |
| **Ask Hub** (propose, wait for approval) | Identity/principle changes, team roster changes | Cross-repo PRs, requests for new hub skills, requests for team changes | N/A — tool repos are fully autonomous |
| **Ask Founder** (escalate to Joaquín) | New game selection, project closures, budget | Ship decisions, IP/brand decisions | N/A |

### 2.2 What Can a Game Squad Do WITHOUT Asking the Hub?

1. ✅ Create issues, plan sprints, assign work within the game repo
2. ✅ Implement features, fix bugs, write tests, ship builds
3. ✅ Create game-specific .squad/ config, skills, and decisions
4. ✅ Merge PRs after Jango review (T1)
5. ✅ Create side-tool repos if needed (per Repo Autonomy directive)
6. ✅ Run ceremonies (retrospectives, design reviews, playtests)
7. ✅ Update game-specific documentation and README
8. ✅ Deploy to GitHub Pages or other hosting

### 2.3 What MUST Escalate to the Hub?

1. 🔺 Changes to studio identity (principles, mission, company identity)
2. 🔺 Requests for new studio-wide skills or skill modifications
3. 🔺 Team roster changes (wake hibernated agents, create new agents)
4. 🔺 Cross-repo dependencies (game A needs something from game B)
5. 🔺 Architecture patterns that should become studio standards
6. 🔺 Project closure, archival, or significant scope changes
7. 🔺 Any change to upstream-inherited content

### 2.4 @copilot Auto-Assign

**Current state:** `copilot-auto-assign: false` in team.md.

**Recommended policy:**
- **Hub repo:** Keep `false`. Hub work is governance/architecture — not @copilot's strength (🔴 per capability profile).
- **Game repos:** Set to `true` for issues labeled `squad:copilot`. Well-defined game tasks (HTML/JS/Canvas, TypeScript/Vite, PixiJS) are @copilot's sweet spot (🟢).
- **Tool repos:** Set to `true`. Tool implementation is straightforward and well-scoped.

**Guard rail:** @copilot PRs still require Jango review before merge. Auto-assign means auto-pickup, not auto-merge. The Lead triages which issues get `squad:copilot` per the routing table in routing.md.

---

## 3. SKILL FLOW BETWEEN REPOS

### 3.1 How Skills Move Between Games

```
Game A discovers pattern → Game A writes draft skill → Hub reviews → Hub curates → All games inherit
```

**Step-by-step:**
1. **Discovery:** During game development, an agent identifies a reusable pattern (e.g., "procedural maze generation for arcade games").
2. **Draft:** The agent writes a draft skill in the game repo at `.squad/skills/{skill-name}/SKILL.md` (per Self-Improvement charter section).
3. **Proposal:** Agent creates an issue in the Hub repo: `[Skill Proposal] {skill-name}` with link to draft.
4. **Review:** Solo reviews for studio-wide applicability. Yoda validates game design relevance. Jango checks technical quality.
5. **Promotion:** If approved, the skill is moved to the Hub's `.squad/skills/` directory and added to the skills index.
6. **Inheritance:** All game repos receive the skill on next `squad upstream sync`.

### 3.2 Studio Skills (Hub-Curated)

The Hub maintains **studio skills** — patterns proven across 2+ projects or deemed universally applicable. These live in `.squad/skills/` and are indexed.

**Current studio skills:** 41 skills across game design, audio, animation, level design, enemy design, studio craft, engine patterns, and more.

**Categorization for inheritance:**

| Category | Inherited By | Examples |
|----------|-------------|---------|
| **Universal** (all games) | All game repos | game-feel-juice, studio-craft, ui-ux-patterns, procedural-audio |
| **Genre-Specific** (opt-in) | Games in that genre | beat-em-up-combat, arcade-game-patterns |
| **Tech-Specific** (opt-in) | Games using that stack | canvas-2d-optimization, vite-typescript-patterns |
| **Archived** | None (reference only) | godot-beat-em-up-patterns, godot-tooling |

### 3.3 When a Game Discovers a Pattern

**Threshold for promotion:** A pattern becomes a studio skill when:
1. It solved a real problem in a shipped game (not theoretical)
2. It's documented with examples (not just a vague principle)
3. It applies to at least one other game genre/stack (or is demonstrably universal)
4. An agent explicitly proposes it (patterns don't promote themselves)

**Anti-pattern:** "This pattern works in ComeRosquillas so let's make it a studio skill." → Does it apply to Flora? To a future 3D game? If it's Pac-Man-specific, it stays in ComeRosquillas.

### 3.4 `squad upstream sync` — When and How

**When to sync:**
- After Hub identity changes (principles, wisdom, quality-gates)
- After new studio skills are approved
- At project kickoff (fresh sync before Sprint 0)
- Monthly maintenance sync (drift prevention)

**How to sync (until squad-cli ships native upstream):**
```powershell
# From game repo root
cd "C:\Users\joperezd\GitHub Repos\ComeRosquillas"

# Sync identity (upstream wins)
Copy-Item "..\FirstFrameStudios\.squad\identity\principles.md" ".squad\upstream\identity\"
Copy-Item "..\FirstFrameStudios\.squad\identity\wisdom.md" ".squad\upstream\identity\"
Copy-Item "..\FirstFrameStudios\.squad\identity\quality-gates.md" ".squad\upstream\identity\"

# Update skills index
Copy-Item "..\FirstFrameStudios\.squad\skills\INDEX.md" ".squad\upstream\skills\"

# Update timestamp
# Edit .squad/upstream/manifest.json → last_synced: (current ISO 8601)
```

**Who syncs:** Jango (Tool Engineer) owns the sync process. Mace tracks sync dates in ceremony checklists.

---

## 4. HUB'S ROLE IN GAME DEVELOPMENT

### 4.1 What Does the Hub Squad DO During Active Game Dev?

The Hub is **not idle** during game development. It operates as the **studio brain**:

| Hub Activity | Owner | Cadence |
|-------------|-------|---------|
| Skill curation and growth | Solo + domain experts | Ongoing — as proposals arrive |
| Cross-project pattern recognition | Solo | Per milestone review |
| Team health monitoring | Mace | Weekly |
| Tool development and maintenance | Jango | As needed |
| Ralph multi-repo watch | Ralph | Continuous (when activated) |
| Studio ceremonies (kickoff, ship, postmortem) | Solo + Yoda + Mace | Per lifecycle event |
| Upstream sync to game repos | Jango | Monthly + on-change |
| Quality gate evolution | Solo + Ackbar | Post-milestone |
| Dashboard/monitor maintenance | Jango | As needed |

### 4.2 Does Solo Review Game PRs?

**Only T2 PRs** (architecture changes). Solo does NOT review routine game PRs:
- **Jango** reviews all T0 and T1 PRs (bug fixes, features, content)
- **Solo** reviews T2 PRs (new systems, module restructuring, cross-system integration)
- **Solo** performs integration gate verification after parallel agent waves

**Rationale:** Per the Jango-Solo role split decision (2026-03-09), Solo does deep architecture work. Routine PR review is Jango's domain. Context-switching between architecture and line-by-line review degrades both.

### 4.3 How Does Hub Identity/Wisdom Flow Downstream?

Three mechanisms:

1. **Upstream sync** — Identity files (principles, wisdom, quality-gates) copied to game repos. Upstream wins on conflicts.
2. **Agent charters** — All agents carry studio-scoped charters that reference hub principles. Charters travel with the agent regardless of which repo they work in.
3. **Ceremony outputs** — Kickoff ceremony includes "read the principles" step. Retrospective outputs flow back to hub as lessons. Skills flow through promotion pipeline.

### 4.4 Does the Hub Create Issues for Games?

**Both models coexist:**

| Issue Source | Where Filed | Examples |
|-------------|------------|---------|
| Game squad self-manages | Game repo | Bugs, features, sprint work, playtesting |
| Hub identifies cross-project issue | Hub repo (tagged `game:{name}`) | Upstream sync needed, skill gap identified, pattern to promote |
| Founder requests | Game repo (if game-specific) or Hub (if studio-wide) | "Add mobile controls", "Ship by Friday" |
| Ralph/Scheduler creates | Game repo | Recurring tasks (weekly playtest, backlog grooming) |

**Rule:** Games are self-managing by default. The Hub intervenes when it spots cross-project patterns, upstream drift, or quality gate failures that the game squad missed.

---

## 5. SIDE PROJECT LIFECYCLE

### 5.1 When a Game Needs a New Tool

**Per the Repo Autonomy directive (2026-03-11):** Any agent can create a public repo for a side project without prior approval. They decide the name, agent assignments, and everything needed.

**Process:**
1. Agent identifies need (e.g., "we need a sprite consistency checker")
2. Agent creates repo under `jperezdelreal/` (or proposes under `FirstFrameStudios/` org if created)
3. Agent runs `squad init` in the new repo
4. Agent sets up `squad upstream add FirstFrameStudios` for inherited context
5. Agent creates initial issues and starts building
6. Agent notifies Hub (issue in FFS: `[New Tool] {tool-name} created`)

### 5.2 Where Is Tool Development Tracked?

**In the tool repo itself.** The tool is a first-class project with its own issues, PRs, and milestones.

**Hub tracking:** The Hub maintains a reference in `team.md` (Active Projects table) and `routing.md` (Multi-Repo Issue Routing). Hub does NOT duplicate the tool's issue board.

**Cross-reference:**
- Tool repo README links back to FFS as parent studio
- FFS team.md lists the tool repo with status
- Ralph's multi-repo watch includes tool repos

### 5.3 How Tools Get Shared Across Games

1. **NPM/package:** If the tool is a library, publish to npm or use git submodule
2. **Script copy:** If the tool is a script (like integration-gate.py), copy to game repos that need it
3. **Studio skill:** If the tool embodies a pattern, promote the pattern to a hub skill
4. **Direct dependency:** If the tool is a standalone app (like squad-monitor), games don't depend on it — it reads from them

**Rule:** Tools should be **read-only observers** of game repos where possible (like squad-monitor reads heartbeat data but never writes to game repos). This prevents coupling.

---

## 6. CEREMONY SCHEDULE

### 6.1 Studio Ceremony Calendar

| Ceremony | When | Facilitator | Participants | Output |
|----------|------|-------------|-------------|--------|
| **Project Kickoff** | When Founder greenlights a new game | Solo (Lead) | Solo + Yoda + Mace + Jango + Joaquín | Repo created, squad initialized, Sprint 0 plan, architecture proposal, GDD skeleton |
| **Sprint Planning** | Start of each sprint (biweekly) | Mace (Producer) | Mace + Yoda + Solo | Sprint scope, assignments, milestone, success criteria |
| **Mid-Sprint Review** | Midpoint of sprint | Mace (Producer) | Mace + active agents | Progress check, blocker identification, scope adjustment |
| **Sprint Retrospective** | End of each sprint | Solo (Lead) | All involved agents | 5 went-right / 5 went-wrong, action items, lessons for hub |
| **Integration Gate** | After parallel agent waves | Solo (Architect) | Solo + Ackbar | Systems verified connected, blockers documented |
| **Ship Ceremony** | When a game is "done" | Yoda (Vision Keeper) | Full team + Joaquín | Ship decision, release checklist, launch announcement |
| **Post-Mortem** | After project closure | Solo (Lead) | Full team | Lessons document, skill proposals, process improvements |
| **Next Project Selection** | After post-mortem + cooldown | Yoda (Game Designer) | Full team proposals, Joaquín decides | Game proposals ranked, Founder selects, kickoff scheduled |
| **Monthly Upstream Sync** | First Monday of month | Jango (Tool Engineer) | Jango | All game repos synced with latest hub identity/skills |
| **Quarterly Studio Review** | Every 3 months | Mace (Producer) | Solo + Mace + Joaquín | Studio health metrics, team assessment, strategic direction |

### 6.2 Ceremony Details

#### Project Kickoff (Solo facilitates)

**Trigger:** Joaquín greenlights a new game from the proposals list.

**Agenda (Day 1-2):**
1. Create game repo under `jperezdelreal/`
2. Run `squad init --no-workflows` (or full init when CLI supports it)
3. Set up `squad upstream` connection to FFS hub
4. Yoda drafts Game Design Document skeleton
5. Solo delivers Architecture v1.0 (per New Project Playbook)
6. Mace creates Sprint 0 plan with milestones and success criteria
7. Jango sets up CI/CD, issue templates, labels, workflows
8. Team reads principles.md (required — Principle #12)
9. Hub issue: `[Kickoff Complete] {game-name}` with all links

**Output:** Playable repo with architecture locked, GDD skeleton, Sprint 0 plan, CI green, upstream connected.

#### Ship Ceremony (Yoda facilitates)

**Trigger:** Game meets ship criteria (defined in Sprint N's Definition of Success).

**Agenda:**
1. Yoda performs final Vision Keeper review: "Does this feel like THIS game?"
2. Ackbar runs full smoke test on target platform(s)
3. Solo verifies integration gate passes
4. Mace confirms all milestone issues closed
5. Joaquín gives ship/no-ship decision (T3)
6. If ship: Jango triggers release workflow, Mace posts Dev Diary, Mace updates Wiki
7. Celebration. The team earned it.

**Output:** Released game, Dev Diary post, Wiki milestone entry, release tag.

#### Post-Mortem (Solo facilitates)

**Trigger:** After Ship Ceremony or after project closure/archival.

**Agenda (per Principle #15):**
1. Each agent contributes "5 went right / 5 went wrong" (async, before ceremony)
2. Solo synthesizes into patterns
3. Identify skills to promote to hub
4. Identify process improvements for next project
5. Write lessons to `.squad/analysis/{game}-postmortem.md`
6. Create action items as Hub issues

**Output:** Postmortem document, skill proposals, process improvement issues, updated hub wisdom.

#### Next Project Selection (Yoda facilitates)

**Trigger:** After post-mortem cooldown (minimum 1 day, recommended 1 week).

**Agenda:**
1. Yoda calls for proposals: each agent may submit 1-3 game concepts
2. Proposals scored on: AI-friendliness, scope (MVP ≤ 4 weeks), visual impact, learning opportunity, viral potential
3. Top 5 presented to Joaquín with ranked recommendations
4. Joaquín selects (T3 decision)
5. Project Kickoff ceremony scheduled

**Output:** Ranked proposals document, Founder selection, kickoff date.

---

## 7. PROJECT LIFECYCLE

### 7.1 When a Game Is DONE

**"Done" means one of two states:**

#### State A: SHIPPED ✅
The game is released, playable, and the team is satisfied.

**Post-ship checklist:**
1. ✅ Release tag created (`v1.0.0`)
2. ✅ GitHub Pages deployment live (or other hosting)
3. ✅ All milestone issues closed with `Closes #N`
4. ✅ Post-Mortem ceremony completed
5. ✅ Lessons promoted to hub skills (where applicable)
6. ✅ Dev Diary final post published
7. ✅ Wiki updated with final status
8. ✅ Repo stays **ACTIVE** for patches and maintenance
9. ✅ README updated with "Released" badge and play link

**The repo does NOT get archived.** Shipped games may receive patches, community fixes, and minor updates. The repo goes into **maintenance mode** — new features are unlikely, but bugs get fixed.

#### State B: SHELVED 📦
The game is abandoned before shipping (like Ashfall).

**Post-shelve checklist:**
1. ✅ Post-Mortem ceremony completed (this is MORE important for shelved games)
2. ✅ Lessons promoted to hub skills aggressively (this is the game's legacy)
3. ✅ All useful patterns extracted before archival
4. ✅ Repo marked as archived on GitHub (Settings → Archive)
5. ✅ Hub team.md updated: project status → ✅ ARCHIVED
6. ✅ Final decision document explaining WHY it was shelved
7. ✅ Game-specific agents hibernated (if they have no cross-game role)

### 7.2 How Is the NEXT Game Selected?

**Who proposes:** Any agent on the team. Agents are encouraged to research trends, analyze what's working in the indie space, and propose games that match FFS strengths.

**Who decides:** Joaquín (Founder). Always. T3 decision. The team recommends, the Founder chooses.

**Game Jam option:** Yoda can propose a "48-hour game jam" ceremony where 3-4 agents each prototype a different game concept. The prototypes are played, and the best one becomes the next project. This is optional — Joaquín can also just pick from written proposals.

**Timeline from idea to repo:**

| Step | Time | Who |
|------|------|-----|
| Proposal written | 1-2 hours | Any agent |
| Team review & ranking | 1 session | Yoda facilitates, all agents vote |
| Founder selects | Async | Joaquín |
| Repo created + squad init | 30 minutes | Jango |
| Upstream connected | 15 minutes | Jango |
| Architecture v1.0 | 2-4 hours | Solo |
| GDD skeleton | 2-4 hours | Yoda |
| Sprint 0 plan | 1-2 hours | Mace |
| **Total: Idea → Building** | **~1-2 days** | — |

---

## 8. LOGGING AND OBSERVABILITY

### 8.1 Where Each Layer Logs

| Layer | Log Location | Format | Owner |
|-------|-------------|--------|-------|
| **Hub orchestration** | `.squad/orchestration-log/` | Markdown per session (`{date}-{agent}.md`) | Solo |
| **Hub tools** | `tools/logs/` | Structured JSON (ralph heartbeat, scheduler state) | Ralph / Jango |
| **Hub sessions** | `.squad/sessions/` | Session artifacts | Scribe |
| **Hub decisions** | `.squad/decisions/` + `.squad/decisions/inbox/` | Markdown decision docs | All agents |
| **Game repo squad** | Game's `.squad/log/` | Game-specific session logs | Game squad |
| **Game repo CI** | GitHub Actions logs | Standard CI output | Jango / GitHub |
| **Ralph heartbeat** | `tools/logs/heartbeat.json` | `{timestamp, repos_checked, issues_found, status}` | Ralph |
| **Ralph structured logs** | `tools/logs/ralph-{date}.jsonl` | One JSON object per line, per action | Ralph |

### 8.2 Cross-Repo Visibility

| Reader | Can Read | Cannot Read |
|--------|----------|-------------|
| **Hub agents** | All Hub logs, game repo public logs (via git clone/API) | Game repo local-only files |
| **Game agents** | Own repo logs, Hub upstream identity/skills (via sync) | Other game repo logs, Hub orchestration logs |
| **Ralph** | All repos (multi-repo watch), all heartbeat files | N/A — Ralph reads everything |
| **Joaquín** | Everything (founder access to all repos) | N/A |
| **Squad Monitor** | Hub + game heartbeat.json, ralph logs | Agent session content (too verbose) |

### 8.3 Monitor Dashboard Aggregation

**ffs-squad-monitor** aggregates by reading:
1. `heartbeat.json` from each repo (polling or webhook)
2. GitHub API for issue counts, PR status, CI status per repo
3. Ralph's structured logs for activity timeline

**Dashboard views (planned):**
- **Studio Overview:** All repos, their status, last activity
- **Agent Activity:** Who did what, when (from orchestration logs)
- **Issue Burndown:** Open/closed per repo over time
- **CI Health:** Green/red status per repo
- **Heartbeat Timeline:** When Ralph last checked each repo

---

## 9. BRAND AND QUALITY GUIDELINES

### 9.1 Studio-Level Rules (ALL Games Must Follow)

#### Code Standards
| Rule | Enforcement | Details |
|------|-------------|---------|
| **Branch naming** | CI check (label-enforce workflow) | `squad/{issue-number}-{slug}` |
| **Commit format** | Convention (CONTRIBUTING.md) | `type(scope): description` — types: feat, fix, chore, docs, style, refactor, test |
| **PR template** | Required | `Closes #N` MUST be in body. Agent name in description. |
| **PR review required** | Branch protection | Minimum 1 approval (Jango for T1, Solo+Jango for T2) |
| **CI must pass** | Branch protection | No merge with red CI |
| **No unused infrastructure** | PR review gate (Quality Gate C5) | Every system created must be wired to at least one consumer |

#### Issue Conventions
| Rule | Details |
|------|---------|
| **Labels** | `type:bug`, `type:feature`, `type:chore`, `priority:P0-P3`, `squad:{agent}`, `game:{name}` |
| **TLDR convention** | Every issue comment by an agent starts with a `**TLDR:**` line. Joaquín reads TLDRs only. |
| **Issue template** | Use `.github/ISSUE_TEMPLATE/squad-task.yml` for squad work |
| **Stale issue cleanup** | Issues untouched for 14 days get `status:stale` label (via workflow) |

#### README Structure (All Repos)
Every FFS repo README must include:
1. **Game/tool name + one-line description**
2. **Play/demo link** (GitHub Pages or equivalent)
3. **Screenshot or GIF** (visual-first — Principle #4: Ship the Playable)
4. **Tech stack badge(s)**
5. **"Part of First Frame Studios"** with link to hub repo
6. **Development section** (how to run locally, how to contribute)
7. **Squad section** (team members, how issues work)

#### Visual Identity
| Element | Standard |
|---------|----------|
| **Studio name** | "First Frame Studios" (always full name in READMEs and about pages) |
| **Tagline** | "Forged in Play" (optional, for marketing materials) |
| **Repo descriptions** | Include "First Frame Studios" or "FFS" for discoverability |
| **Dev Diary branding** | `🔥 Dev Diary #X:` format (Mace's established convention) |

### 9.2 How Are These Enforced?

| Mechanism | What It Enforces | Where |
|-----------|-----------------|-------|
| **Upstream sync** | Identity, principles, quality gates | All game repos (via .squad/upstream/) |
| **GitHub Actions workflows** | Branch naming, label enforcement, stale issues, CI, heartbeat | Per repo (copied from hub templates) |
| **PR review** | Code quality, commit format, PR template, TLDR | Jango reviews all PRs |
| **Ceremonies** | Process adherence, retrospective lessons | Solo/Mace facilitate |
| **Agent charters** | Domain expertise, skill references, self-improvement protocol | .squad/agents/{name}/charter.md |
| **CONTRIBUTING.md** | Workflow documentation, branch naming, commit format, label system | Per repo (synced from hub template) |

### 9.3 What's NOT Standardized (Game Autonomy)

Games have full freedom over:
- Art style and visual direction (per-game identity)
- Tech stack choice (HTML/Canvas, Vite/TS/PixiJS, future engines)
- Game-specific mechanics and design decisions
- Internal file structure and module organization
- Game-specific CI/CD beyond the baseline
- Marketing and community engagement approach

---

## Summary: The Three Laws of FFS Governance

1. **Games are autonomous, Hub is authoritative.** Games run their own sprints, merge their own PRs, and manage their own issues. The Hub owns identity, skills, quality standards, and team composition.

2. **Everything escalates by tier, nothing escalates by default.** T0 auto-approves. T1 goes to Jango. T2 goes to Solo. T3 goes to Joaquín. When in doubt, check the tier table.

3. **Knowledge flows up and down.** Patterns discovered in games flow UP to hub skills. Identity and standards flow DOWN via upstream sync. Ralph watches everything. The monitor shows everything. Nothing is siloed.

---

## Approval

This document requires Founder approval (T3) to become active.

**To approve:** Comment on the Hub issue with "APPROVED" or "APPROVED WITH CHANGES: {details}".

**Once approved:**
- This document moves from `.squad/decisions/inbox/` to `.squad/decisions/`
- All game repos receive a sync with the new governance rules
- routing.md and team.md are updated to reference this document
- Mace adds ceremony schedule to project board

---

*Written by Solo (Lead / Chief Architect) — First Frame Studios*  
*"The studio grows when the rules are clear enough to follow and flexible enough to not need exceptions."*

---

## 2026-03-11T14:28: User Directive — Auto-Delete Branches + Code Review Rulesets

**By:** Joaquín (via Copilot)  
**What:** When creating repos, always enable "Automatically delete head branches" and set up rulesets for code review.  
**Why:** User request — captured for team memory. Ensures clean branch hygiene and enforced PR reviews across all FFS repos.

---

## 2026-03-11: ComeRosquillas Ghost AI Architecture Decision

**Date:** 2026-03-11  
**Author:** Tarkin (Enemy/Content Designer)  
**Issue:** #7 — Improve ghost AI with difficulty curve and personality  
**Status:** ✅ Implemented (PR #11)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
Ghost AI in ComeRosquillas was functional but all four villains behaved nearly identically (classic Pac-Man Blinky/Pinky/Inky/Clyde targeting with no personality feel). No difficulty scaling beyond minimal speed increase.

**Decision:**
Implement personality-based targeting through the existing `getChaseTarget()` method + random direction overrides in `moveGhost()`, plus a 0..1 difficulty ramp that scales 6 parameters across 9 levels.

**Ghost Personality Mapping:**
- Burns → Ambush (targets ahead of Homer)
- Bob Patiño → Aggressive (direct chase, speed bonus)
- Nelson → Patrol/Guard (zone defense with proximity trigger)
- Snake → Erratic (random directions + random targets)

**Difficulty Scaling Parameters:**
Ghost speed, fright duration, scatter/chase time ratios, ghost house exit delays, frightened ghost speed, personality aggression values — all driven by single `getDifficultyRamp()` function.

**Rationale:**
1. Personality through target selection keeps one unified `moveGhost()` — no per-ghost state machines needed for a Pac-Man clone
2. Difficulty ramp as 0..1 float makes all scaling parameters easy to tune from one place
3. All changes confined to `js/game-logic.js` per the modularization architecture (Chewie's decision)

**Impact on other agents:**
- Lando: Scoring/progression unaffected — ghost point values unchanged
- Chewie: Engine untouched — no renderer or audio changes
- Wedge: UI/HUD untouched

---

## 2026-03-11: ComeRosquillas Audio Architecture (Greedo)

**Date:** 2026-03-11  
**Author:** Greedo (Sound Designer)  
**Issue:** #8 — Sound effects variety and improved music  
**PR:** #12  
**Repo:** jperezdelreal/ComeRosquillas

**Decision:**

Implemented mix bus architecture (sfxBus + musicBus → compressor → destination) and expanded procedural audio to 8 SFX types with variation systems. All sounds procedural via Web Audio API — no external audio files.

**Key Choices:**

1. **Mix bus with compressor:** DynamicsCompressor on master prevents clipping when SFX and music overlap. This is zero-cost and should be standard on all projects.
2. **Variation via cycling + pitch spread:** Chomp cycles through 4 patterns with ±8% random pitch. Death randomly picks from 3 variants. Ghost-eat pitch escalates with combo. These techniques prevent repetition fatigue without adding complexity.
3. **Backward-compatible API:** `play(type, data)` accepts optional second parameter. Existing `play('chomp')` calls work unchanged. Only 2 lines changed in game-logic.js.
4. **Smooth mute transitions:** `linearRampToValueAtTime` instead of hard gain cuts. Prevents audio pops.

**Impact on Other Agents:**

- **Lando/Tarkin:** If adding new game events (bonus collect, combo chain), call `this.sound.play('newType')` and add a case in audio.js. The API pattern is established.
- **Chewie:** Bus architecture is initialized in SoundManager constructor. No engine changes needed.
- **Wedge:** If adding audio settings UI, use `toggleMute()` for music and the bus gain values for volume sliders.

---

## 2026-03-11: ralph-watch README ASCII-safe and v2-accurate

**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Issue:** #152

**Context:**
tools/README.md was out of date -- it documented ralph-watch v1 defaults (single repo) and omitted v2 features (failure alerts, activity monitor, metrics parsing, multi-repo).

**Decision:**
Rewrote README to accurately reflect ralph-watch v2:
- Default `-Repos` is all 4 FFS repos, not just `.`
- Documented failure alerts (alerts.json after 3+ consecutive failures)
- Documented activity monitor (background runspace)
- Documented metrics parsing (issues closed, PRs merged/opened)
- Added prerequisites section (gh CLI, copilot extension)
- All text ASCII-safe (no emojis, no Unicode dashes) for PS 5.1 compatibility

**Impact:**
- Any agent or human reading tools/README.md now gets accurate activation instructions
- Startup is one command: `.\tools\ralph-watch.ps1`

---

## 2026-03-11: Flora Architecture — Module Structure & Patterns

**Author:** Solo (Lead Architect)  
**Date:** 2026-03-11  
**Repo:** jperezdelreal/flora  
**PR:** #2  
**Status:** PROPOSED (awaiting merge)

**Context:**

Flora is FFS's second game — a cozy gardening roguelite built on Vite + TypeScript + PixiJS v8. Needed a clean architecture from day one to avoid the monolithic anti-pattern that plagued ComeRosquillas (1636 LOC game.js) and firstPunch (695 LOC gameplay.js).

**Decision:**

### Module Structure (7 modules)

| Module | Responsibility | Rules |
|--------|---------------|-------|
| `core/` | SceneManager, EventBus, (future: input, asset loader) | Owns the game loop |
| `scenes/` | Individual game screens (boot, menu, garden, etc.) | One active at a time |
| `entities/` | Game objects (plants, player, tools) | Scene-agnostic |
| `systems/` | ECS-lite update loops (growth, weather, inventory) | Communicate via EventBus |
| `ui/` | HUD, menus, dialogs | Subscribe to events, never mutate state |
| `utils/` | Math, RNG, helpers | Pure functions, no imports from other src/ modules |
| `config/` | Constants, balance values, tuning | Pure data, no side effects |

### Key Patterns

1. **Scene-Based Architecture** — All game states are Scenes managed by SceneManager. One active at a time. Clean init/update/destroy lifecycle.

2. **ECS-Lite** — Not a full Entity-Component-System framework. Lightweight systems that iterate typed entity collections. Keeps complexity proportional to game scope.

3. **Typed Event Bus** — Pub-sub with EventMap type for compile-time safety. Prevents circular dependencies between systems, UI, and scenes.

4. **PixiJS v8 Patterns** — Async `Application.init()`, `app.canvas` (not `app.view`), `Text({text, style})` object syntax, `Assets.load()` API.

### Dependency Direction

```
main.ts → core → scenes → entities/systems/ui
config ← imported by anything
utils ← imported by anything
EventBus ← imported by scenes, systems, ui
```

**Rationale:**

- Modular from day one prevents the monolith anti-pattern (lesson from ComeRosquillas and firstPunch)
- Scene-based is simpler than FSM for a small-medium game
- ECS-lite avoids framework overhead while keeping separation of concerns
- Event bus is the standard decoupling pattern for game modules

**Implications:**

- All new features go in the appropriate module (no cross-cutting monoliths)
- New scenes implement the Scene interface
- New systems implement the System interface
- Inter-module communication goes through EventBus, not direct imports

---

## 2026-03-11: Flora Game Design Document (GDD v1.0)

**Date:** 2026-03-11  
**Decided By:** Yoda (Game Designer)  
**Status:** READY FOR ARCHITECTURE REVIEW  
**Artifact:** `jperezdelreal/flora/docs/GDD.md` (PR #1)

### Decision Summary

**What:** Approved Flora GDD v1.0 as the design foundation for Sprint 0 development.

**Why:** 
1. Aligns with "cozy first, challenge second" directive from Joaquín
2. MVP scope is realistic for AI-developed game (12 plants, one-season loop, basic hazards)
3. Roguelite elements are light (discovery-driven, not punishment-driven)
4. Design decisions support tech stack (Vite + TypeScript + PixiJS v8)
5. Clear progression loop ensures engagement without grinding

**Scope:** 
- Sprint 0 MVP: 8×8 garden, 12 plants, 20–40 min per run, 3–5 runs per session
- Post-MVP deferred: garden expansion, complex synergies, cosmetics, seasonal variety, save/load

### Key Design Pillars

1. **Cozy but Intentional** — Relaxing tone, meaningful choices, no punishment
2. **Every Run is Different** — Randomized seeds, unique scenarios each time
3. **Grow & Discover** — Incremental unlocks, botanical encyclopedia grows with playtime
4. **The Garden Reflects You** — Aesthetic choices are expressive; memories persist

### Core Loop

**One Run = 20–40 minutes**

1. **Seeding (3–5 min):** Choose from 4–6 random plants; arrange on 8×8 plot
2. **Tending (12–25 min):** Water, harvest, manage pests, adapt to weather (12 in-game days)
3. **Harvest & Reflection (2–5 min):** Collect new seeds, update encyclopedia, unlock rewards

**Each Season Resets:** Garden, weather, available seeds, plant states  
**Each Season Persists:** Encyclopedia, tools, garden upgrades, achievements

### Meta-Progression (Session Level)

Unlocks per run:
- **Runs 1–2:** Common seeds (8–10), basic tools
- **Runs 3–5:** Rare seeds, soil upgrades, compost system
- **Runs 6–10:** Heirloom seeds, garden structures, advanced tools

After 5–10 runs, player feels measurably more powerful and has discovered 15–20 unique plants.

### Garden Mechanics

#### Plant System
- **Growth Time:** 3–8 in-game days (varies per plant)
- **Water Need:** 1–5 waterings per cycle
- **Health:** 0–100% (affected by water, pests, weather)
- **Yield:** 1–3 seeds per harvest + bonus fruit (aesthetic)

#### Hazards (All Solvable, No Combat)
- **Pests:** Appear on day 6–8; player removes manually or uses tools
- **Drought:** Increases watering frequency (Summer hazard)
- **Frost:** Sensitive plants wilt if not harvested in time (Winter hazard)
- **Weeds:** Occupy space or slow growth; removable or compostable

### Art & Audio Direction

**Art:**
- Tilebase pixel art (16×16 grid, 32×32 plants/player)
- Warm earthy palette (soil browns, greens, sky blues, accent flower colors)
- Seasonal shifts (spring pastels → summer gold → fall rust → winter cool)
- Smooth growth animations; satisfying harvest pop

**Audio:**
- Ambient loops (60–90 BPM, cozy lo-fi style)
- Soft SFX (water pour, soil tap, harvest chime, pest rustle)
- No stressful cues; total mix encourages relaxation

### MVP Scope (Hard Boundary for Sprint 0)

#### IN MVP
- One-season loop (12 in-game days)
- 12 plant types (4 common, 4 uncommon, 2 rare, 2 heirloom)
- 8×8 garden plot
- Hazards: pests, drought
- Tools: basic watering can, hand, pest remover
- Encyclopedia (discover/unlock mechanic)
- Soil quality (basic feedback)
- One tool unlock per first harvest
- One plant unlock per season completion

#### OUT of MVP (Deferred)
- Garden expansion
- Complex synergies (polyculture bonus, shade mechanic)
- Advanced tools (soil tester, compost bin, trellis)
- Seasonal variety (MVP = same season all runs)
- Cosmetics / achievements
- Save/load (single session only)
- Mobile optimization

### Success Criteria

Players will:
1. ✓ Complete 3–5 runs in one session
2. ✓ Discover at least 1 new plant per run
3. ✓ Feel harvesting is rewarding (audio + visual works)
4. ✓ Play for 30–40 minutes without rushing
5. ✓ See encyclopedia growth; feel progression
6. ✓ No frustration; hazards solvable by restart

### Next Steps

1. **Architecture Review (Solo):** Validate tech stack feasibility; suggest data structures
2. **Sprint 0 Planning (Jango, Squad):** Timeline, asset needs, task breakdown
3. **Art Spike:** Plant sprite concepts (16×16, growth frames)
4. **Audio Spike:** Ambient track (90 sec loop) + 5 SFX

### Design Philosophy Reinforced

> *"Cozy First, Challenge Second."*

Every design decision prioritizes:
1. **Player agency** — Hazards are puzzles, not punishments
2. **Discovery** — Unlocking feels like loot drops in traditional roguelikes
3. **Accessibility** — Failed run = "next season, I'll try different" not "I lost progress"
4. **Visible progress** — Encyclopedia fills; tools appear; garden expands

**Approved by:** Yoda, Game Designer  
**For:** First Frame Studios Squad  
**Date:** 2026-03-11

**Related Decisions:**
- **Studio Philosophy:** "Player Hands First" (session 7)
- **Genre Pillars:** "Game Feel is Differentiator" (2026-03-08)
- **Tech Stack:** Vite + TypeScript + PixiJS v8 (from now.md)
- **Scope Governance:** MVP-lock principle (from Mace's Sprint 0 plan, Ashfall)
