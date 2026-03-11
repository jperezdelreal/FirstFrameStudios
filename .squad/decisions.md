# Squad Decisions

## Active Decisions

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
