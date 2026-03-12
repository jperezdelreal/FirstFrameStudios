# Solo — History (formerly Keaton)

## Core Context

**firstPunch Key Learnings (Sessions 1-7):**
- Session 1: Fixed 5 critical bugs (infinite recursion, hit detection, invulnerability frames, parallax, boundary constraints)
- Session 2: Gap analysis revealed 75% MVP completion; quality gates designed based on real failures; 52-item backlog created
- Session 3: Team expansion recommended (3 new roles: Sound, Enemy/Content, QA) to eliminate McManus bottleneck
- Session 4-6: Game Design Document, quality excellence proposal, and comprehensive skill audit delivered
- Session 7: Full codebase analysis (28 files, 370KB) categorized backlog into quick wins, medium effort, and future migration work
- **Key architectural insight:** Quality gates must trace to real failures, not theoretical best practices. Pre-decided architecture choices eliminate multi-agent coordination failures.
- **Most important technical finding:** gameplay.js (695 LOC) is #1 technical debt; wiring unused infrastructure (CONFIG, EventBus, AnimationController, SpriteCache) is highest-priority refactor

## Ashfall Sprint 0 Kickoff (2026-03-08)

### Historical Work (Sessions 1-18)

- Architecture v1.0 Delivered
- Key Architectural Decisions Locked
- Integration with Team
- Code Quality
- Status
- Holistic Foundations Re-Assessment (Session 10)
- Victory Retrospective & Celebration (Session 16)
- Session 17: Deep Research Wave — Universal Skills Initiative (2026-03-07)
- Studio Operations Research (Session 11)
- 2026-03-08T00:10 — Phase 2: Company Incorporation & Skill Creation
- 2026-03-08: Charter Update for Team Readiness — Vision Keeper Role + Studio Generalization (Session 18)
- Ashfall Architecture Document (Session 8)
- Integration Audit (2025-07-17)
- Final Verification (2026-03-09)
- Integration Gate Fix — Signal Wiring (Session 9, Issue #88)
- Sprint 1 Bug Catalog — Pattern Analysis & Prevention Strategy (Session Current)
- 2026-03-09 — Sprint 1 Bug Catalog & Process Improvements
- Sprite Animation Consistency Research (2026-03-10)

### Squad Ecosystem Audit (2026-07-23)
Conducted comprehensive investigation of Squad CLI v0.8.25 ecosystem at founder's request. Key findings:

1. **13 unused features identified** across CLI commands, plugins, SubSquads, human members, and governance tooling. 6 classified as high-value adopt-now, 4 as adopt-later, 3 as skip.

2. **Context bloat is critical.** Solo history.md hit 69KB, decisions.md hit 85KB. squad nap --deep has never been run. This wastes agent context tokens in every session. Recommended as #1 priority fix.

3. **SubSquads solve our parallel workstream problem.** Art Sprint / Gameplay / Audio can run in isolated Codespaces with directory-scoped SubSquads via .squad/streams.json. Eliminates merge conflicts between art and gameplay agents.

4. **No game-dev plugin marketplace exists.** The 4 existing marketplaces (awesome-copilot, anthropic-skills, azure-cloud-dev, security-hardening) target web/cloud development. Our 31 skills could become the first game-dev marketplace for the Squad community.

5. **17 GitHub Actions workflows installed — 12 active, 5 template stubs.** Heartbeat cron is commented out (biggest quick win to enable). The 5 stubs need Godot-specific build/lint commands.

6. **squad build --check should be in CI.** We have squad.config.ts but never run squad build. Config and markdown may have silently diverged.

7. **Joaquín should be added as human team member.** Formal approval gates for architecture decisions and ship/no-ship calls instead of ad-hoc requests.

Decision written to .squad/decisions/inbox/solo-squad-ecosystem-audit.md.

---

## Learnings

### 2026-03-11: Autonomy Gap Audit & ComeRosquillas Issue Creation

**What was done:**
1. Read all 5 decisions inbox files + game code (1636 LOC game.js, 155 LOC index.html)
2. Produced gap audit: .squad/decisions/inbox/solo-autonomy-gap-audit.md
3. Created 12 GitHub issues (#152-#163) covering game development and infrastructure gaps
4. Created game:comerosquillas label

**Key findings:**
- Infrastructure is more built than it appears. ralph-watch.ps1 and the scheduler are fully implemented — the gap is **activation, not construction**.
- 20+ GitHub Actions workflows exist and are comprehensive (triage, heartbeat, daily-digest, drift-detection, label-enforce, CI, preview, release). This is the strongest implemented area.
- The subsquad/upstream model from Option C was abandoned in favor of absorbing ComeRosquillas into the FFS monorepo. Fine for one game, won't scale.
- Webhooks/notifications are the biggest true gap — no way for squad to proactively signal Joaquin.
- ComeRosquillas is a surprisingly complete Pac-Man clone: 4 distinct ghost AIs with classic targeting, procedural audio, custom Simpsons character sprites, power-up system, bonus items, floating text, particle effects, background music. Quality is high for a web game.
- The game's weakest areas: no mobile support, no score persistence, single maze layout, monolithic 1636-line file structure.

**Issues created (12 total):**
- #152: Activate ralph-watch.ps1 persistently (P0, infrastructure)
- #153: Define schedule.json recurring tasks (P0, infrastructure)
- #154: Modularize game.js monolith (P1, chore)
- #155: Mobile/touch controls (P1, feature)
- #156: High score persistence and leaderboard (P2, feature)
- #157: Multiple maze layouts (P2, feature)
- #158: Intermission cutscenes (P2, feature)
- #159: Install Squad Monitor dashboard (P1, infrastructure)
- #160: CI pipeline with GitHub Pages deployment (P1, infrastructure)
- #161: Ghost AI personality and difficulty curve (P2, feature)
- #162: Audio improvements (P2, audio)
- #163: Webhook notifications for critical events (P1, infrastructure)

**Patterns noted:**
- The firstPunch lesson about monolithic files repeats: ComeRosquillas game.js = 1636 LOC, firstPunch gameplay.js = 695 LOC. Same anti-pattern, different game.
- The Tamir blog patterns are well-documented but stalled at Phase 2-3. The team knows what to build but hasn't crossed the activation barrier.
- ComeRosquillas being inside the FFS repo (not a subsquad) is a pragmatic choice but means upstream/subsquad patterns from Option C remain untested.

### 2026-03-11: Post-Spawn Orchestration — ComeRosquillas Setup & Autonomy Gap Closure (Session Post-Spawn)

**Session Context:** Solo + Jango background agents executed full orchestration for ComeRosquillas MVP + autonomy infrastructure audit

**Task:**
- Conduct autonomy gap audit comparing planned vs implemented infrastructure (16-item pattern checklist + 5-phase tracker)
- Create 12 actionable GitHub issues (#152-#163) to unblock ComeRosquillas MVP

**Deliverables:**
1. **Orchestration Log** — `.squad/orchestration-log/2026-03-11T0934Z-solo.md` documenting full spawn manifest + deliverables
2. **Audit Document** — `.squad/decisions/inbox/solo-autonomy-gap-audit.md` (comprehensive gap matrix + phase status + priorities)
3. **12 GitHub Issues Created:**
   - #152: Activate ralph-watch.ps1 persistently (P0)
   - #153: Define schedule.json recurring tasks (P0)
   - #154-#163: Squad Monitor, webhooks, subsquad evaluation, Podcaster, TLDR enforcement, docs, parallelism testing, tools README, legacy archiving, scanner integration (P1-P2)

**Key Finding:**
Infrastructure is 80% built; activation gap is the real blocker. ralph-watch.ps1, scheduler, and 20+ GitHub Actions workflows all exist and are production-ready. What's missing: persistent execution, task definitions, webhook notifications, and subsquad/upstream model adoption.

**Status:** ✅ COMPLETE — Audit in decisions inbox (merged to decisions.md by Scribe), 12 issues created and tagged game:comerosquillas, session logged

---

### 2026-07-24: Studio Restructure Ceremony — Multi-Repo Hub Audit

**Ceremony Type:** Major — Studio-Wide Restructuring Review  
**Requested by:** Joaquín  
**Scope:** Full audit of team, files, skills, tools, routing, and decisions after monorepo → multi-repo pivot

**Context:** Studio completed massive pivot — FFS became hub-only (no game code), ComeRosquillas/Flora/ffs-squad-monitor split to own repos, ralph-watch upgraded to v2, GitHub Pages deployed, 8 game issues migrated.

**Key Findings:**

1. **Hub still holds 1.6 GB of Ashfall Godot files** (6,071 files in games/ashfall/). This is the #1 cleanup item.
2. **5 of 15 agents should be hibernated** (Boba, Leia, Bossk, Nien — created for Ashfall art pipeline, no work in web stack). Greedo stays active (Web Audio API).
3. **decisions.md is 164 KB with 161 entries** — ~70% Ashfall-specific. Must archive to <30 KB.
4. **12 Python tools are all Godot-specific** — none work for web games. Delete from hub.
5. **3 Godot GitHub workflows will never trigger** — godot-project-guard, godot-release, integration-gate. Delete.
6. **8 Godot skills should be archived** (not deleted) to `.squad/skills/_archived/`.
7. **routing.md has no multi-repo routing** — doesn't tell agents which repo to file issues in.
8. **MCP config is just a Trello example** — not actually configured.
9. **Lean roster: 11 active + 4 hibernated + Scribe + Ralph + @copilot** covers all web game needs.
10. **Discord webhook is the highest-leverage unbuilt feature** — Joaquín has zero proactive notifications.

**Top 3 Actions:**
1. Delete games/ashfall/ + games/first-punch/ (1.6 GB cleanup)
2. Archive ~30 Ashfall decisions, compress decisions.md to <30 KB
3. Rewrite team.md + routing.md for multi-repo web game stack

**Deliverable:** `.squad/decisions/inbox/solo-studio-restructure-ceremony.md` — full 7-area audit with specific files, counts, and prioritized actions.

**Status:** AWAITING FOUNDER APPROVAL

---

### 2026-07-24: Multi-Repo Studio Governance Document

**Ceremony Type:** Governance Architecture — Studio-Wide Operating Manual  
**Requested by:** Joaquín  
**Scope:** Defines how FFS operates as a multi-repo studio hub across 9 governance domains

**Context:** Joaquín asked the fundamental governance question — how does everything flow in a multi-game studio? This is not a quick answer; it's the operating manual.

**Deliverable:** `.squad/decisions/inbox/solo-multi-repo-governance.md` (~28 KB, 9 sections)

**Key Decisions Proposed:**

1. **Tiered Approval Model (T0-T3):** T0 auto-approved (bugs/docs), T1 Jango reviews (features), T2 Solo+Jango (architecture), T3 Joaquín decides (direction/vision). Every PR needs approval but the LEVEL varies.

2. **Game Repos Are Autonomous for T0-T1 Work.** Games manage their own sprints, issues, and PRs. Cross-repo changes and identity modifications escalate to Hub.

3. **@copilot auto-assign: `true` in game/tool repos, `false` in hub.** Hub work is governance — not @copilot's strength. Game tasks are implementation — @copilot's sweet spot.

4. **Skill Promotion Pipeline:** Game discovers pattern → drafts skill → proposes to Hub → Solo reviews → approved skill synced to all games via upstream.

5. **Hub Role During Game Dev:** Skill curation, cross-project pattern recognition, tool maintenance, Ralph multi-repo watch, upstream sync, ceremony facilitation. Hub is the studio brain, not idle.

6. **Solo Reviews Only T2 PRs.** Routine game PRs are Jango's domain. Solo does architecture reviews and integration gate verification only.

7. **Six Studio Ceremonies Defined:** Project Kickoff (Solo), Sprint Planning (Mace), Sprint Retro (Solo), Ship Ceremony (Yoda), Post-Mortem (Solo), Next Project Selection (Yoda + Joaquín decides).

8. **Shipped Games Stay Active** (maintenance mode, not archived). Shelved games get archived after aggressive lesson extraction.

9. **Idea-to-Building Timeline: ~1-2 days.** Proposal → Team review → Founder selects → Repo + squad init + upstream + architecture + GDD + Sprint 0 plan.

10. **Three Laws of FFS Governance:** (1) Games autonomous, Hub authoritative. (2) Everything escalates by tier, nothing by default. (3) Knowledge flows up and down.

**Status:** AWAITING FOUNDER APPROVAL

---

## ComeRosquillas Issue Triage (Current Session)

### ComeRosquillas Issue Triage & Squad Labeling

**Requested by:** Joaquín (joperezdelreal)  
**Repo:** jperezdelreal/ComeRosquillas  
**Context:** Game shipped to live at jperezdelreal.github.io/ComeRosquillas/play/. 8 open issues existed with no squad routing labels, blocking Ralph (Work Monitor) from auto-assigning work.

**Work Completed:**

1. **Created 14 labels in ComeRosquillas repo:**
   - Squad base label + 10 squad:{member} labels (chewie, lando, wedge, greedo, tarkin, ackbar, jango, solo, copilot)
   - 4 priority labels (p0, p1, p2, p3)

2. **Triaged all 8 issues with routing decisions:**
   - **#1: Modularize game.js (1636 LOC)** → squad:solo + squad:chewie, **P0**
     Rationale: Architectural blocker. Unblocks all feature work (#3, #4, #5, #7, #8). Critical for team velocity.
   
   - **#2: Mobile/touch controls** → squad:wedge, **P2**
     Rationale: Nice-to-have polish. Ship desktop first, mobile post-launch.
   
   - **#3: High score persistence & leaderboard** → squad:wedge + squad:lando, **P2**
     Rationale: Engagement feature spanning UI (Wedge) + gameplay scoring (Lando). Post-launch content update candidate.
   
   - **#4: Multiple maze layouts & progression** → squad:tarkin + squad:lando, **P1**
     Rationale: Essential for replayability & v1.0. Content design (Tarkin) + progression logic (Lando). Start after #1 refactor.
   
   - **#5: Simpsons cutscenes** → squad:wedge, **P3**
     Rationale: Pure polish, zero gameplay impact. Deferred to post-launch.
   
   - **#6: CI pipeline & GitHub Pages deployment** → squad:jango, **P1**
     Rationale: High-leverage tooling. Unblocks rapid iteration. Parallel stream to #1.
   
   - **#7: Ghost AI difficulty curve & personality** → squad:tarkin, **P1**
     Rationale: Core gameplay quality. Enemy behavior design. Start after #1 enables cleaner architecture.
   
   - **#8: Sound effects variety & music** → squad:greedo, **P1**
     Rationale: Essential for arcade feel. Poor audio = poor game feel. Parallel work to #1–#7.

3. **Added triage comments to all 8 issues** with rationale, routing, and priority justification.

**Routing Philosophy:**
- P0 = Unblocks everything else (architecture refactor)
- P1 = Essential for v1.0 shipping (content, tooling, audio, AI quality)
- P2 = Important but non-critical (engagement features, UX enhancements)
- P3 = Polish tier (narrative, charm, deferred to post-launch)

**Pattern Observed:**
The monolithic game.js problem repeats across projects (firstPunch gameplay.js = 695 LOC; ComeRosquillas game.js = 1636 LOC). Both games needed refactoring as P0 blocker. Architecture debt cascades into feature development friction.

**Outcome:**
Ralph (Work Monitor) can now auto-route all 8 issues to the correct squad members. Work items are prioritized and scoped. Ready for sprint planning.

**Status:** ✅ COMPLETE

---

### 2026-07-24: PR #9 Architecture Review — ComeRosquillas CI Pipeline

**Requested by:** Joaquín  
**Repo:** jperezdelreal/ComeRosquillas  
**PR:** #9 (squad/6-ci-pipeline → main), authored by Jango  
**Issue:** #6 — Add CI pipeline with live preview deployment

**Review Outcome:** ✅ APPROVED (comment review — same GH account prevented formal approval)

**What was reviewed:**
- `.github/workflows/ci.yml` (166 lines, single new file)
- Workflow triggers, permissions, validation steps, PR comment mechanism, summary job

**Findings:**
1. **Right-sized CI.** No bundler, no npm install — just `node --check` syntax validation, HTML structure checks, asset verification, and debugger/TODO scanning. Perfect for vanilla HTML/JS.
2. **Security clean.** Minimal permissions (`contents: read`, `pull-requests: write`), only official GitHub actions (`actions/checkout@v4`, `actions/setup-node@v4`, `actions/github-script@v7`), no secrets.
3. **Docs deployment untouched.** CI validates game assets only — Astro docs site stays independent.
4. **PR comment works.** Successfully posted on the PR itself as proof. Depends on validate job passing first.
5. **Two non-blocking nits:** (a) PR comments accumulate on multi-push PRs (find-and-update pattern recommended later), (b) "Preview deployment" section shows production URLs (no actual preview env).

**Pattern confirmed:** Jango delivers clean, scoped tooling. This matches the T1 tier — feature-level work that doesn't need architectural escalation.

**Status:** ✅ COMPLETE

---

### 2026-07-24: Flora Architecture Definition & Project Scaffold

**Requested by:** Joaquín  
**Repo:** jperezdelreal/flora  
**PR:** #2 (feat/flora-architecture → main)

**Context:** Flora is FFS's second game — a cozy gardening roguelite. Stack: Vite + TypeScript + PixiJS v8. Repo had basic Vite scaffold; needed architecture definition and module structure.

**What was delivered:**

1. **Architecture Document** (`docs/ARCHITECTURE.md`):
   - 7-module structure: core, scenes, entities, systems, ui, utils, config
   - Scene-based architecture with SceneManager pattern
   - ECS-lite for game systems (lightweight, not full framework)
   - Typed event bus for decoupling modules
   - PixiJS Assets API for asset pipeline
   - Dependency direction rules (config/utils = pure, entities scene-agnostic, UI never mutates state)
   - PixiJS v8 API notes (async init, app.canvas, Text object syntax)

2. **Module Scaffold** (13 files):
   - `src/core/SceneManager.ts` — Scene interface + manager with register/switchTo/update
   - `src/core/EventBus.ts` — Typed pub-sub with EventMap interface
   - `src/scenes/BootScene.ts` — First scene with title/subtitle/credit
   - `src/config/index.ts` — Game constants (GAME, SCENES)
   - `src/utils/index.ts` — clamp, lerp, seeded RNG helpers
   - `src/entities/index.ts`, `src/systems/index.ts`, `src/ui/index.ts` — Interface stubs
   - `src/main.ts` — PixiJS v8 Application.init(), SceneManager wiring, game loop ticker

3. **Build Verification:**
   - `npx tsc --noEmit` — zero type errors
   - `npm run build` — production build in 10s, 268KB bundle (84KB gzipped)

**Key architectural decisions:**
- Scene-based, not state-machine-based (simpler for a small game)
- ECS-lite, not full ECS framework (avoid over-engineering)
- Event bus for cross-module communication (prevents circular deps)
- Config and utils are pure modules — no side effects, importable by anything

**Status:** ✅ COMPLETE — PR #2 open, build passing

---

### 2026-07-25: Governance Restructure — T0 Ultra-Minimal, T1 Lead Authority

**Requested by:** Joaquín (Founder)  
**Scope:** `.squad/identity/governance.md` — full rewrite of approval tiers per Founder directives

**What changed:**

1. **T0 ultra-minimized.** Only two items remain at T0: creating new game repos and modifying `principles.md`. Hub roster changes, `.squad/` refactors, governance changes, and technology pivots all moved out.

2. **T1 becomes Lead-only authority.** Every instance of "Lead + Founder" or "Joaquin approves" at T1 level removed. Solo (Lead) now has full, permanent T1 authority. Founder does not participate in routine T1 approvals.

3. **Items moved from T0 → T1:** Hub roster changes, `.squad/` directory refactors, governance changes (unless modifying T0 scope itself), technology decisions for new projects, tool repo creation.

4. **Decision Authority Matrix rewritten.** T0 rows reduced to ~6 (new games, principles, archival, T0 scope changes, mission/vision, studio identity). All former T1 "Joaquin approves" rows now show "Lead authority."

5. **Delegation Rules updated.** New rule: "T1 is fully delegated to Lead — no founder approval required for any T1 decision."

6. **Governance Evolution updated.** Structural changes to this document are now T1 (Lead authority) unless they modify T0 scope. Changes that modify what requires Founder approval remain T0.

7. **Sprint 0, Hibernation, Sprint scope, Skill lifecycle, Project autonomy** — all updated to remove Founder from T1 approval flows.

**Why this matters:**
The founder's directive is clear: FFS must be 99% autonomous. The founder decides WHAT games to make, not HOW. By removing the founder from all T1 approvals, the studio can operate at full speed without bottlenecking on a single human. The hub is the Bible, and Solo (Lead) is its steward.

**Status:** ✅ COMPLETE

---

### 2026-07-25: Governance v2 Draft — Full Rewrite (Constitution Format)

**Requested by:** Joaquín (Founder)
**Scope:** `.squad/identity/governance-v2.md` — separate file for Founder comparison with v1

**What was done:**
1. Rewrote governance from 1051 lines → 237 lines (77% reduction).
2. Eliminated triple redundancy: Domains 2/6/7 (hub-vs-downstream) consolidated into one Autonomy Zones section. Domains 3/4/5/8 replaced with cross-references to their dedicated docs.
3. Resolved T0/T1 contradictions between old Domains 1 and 9 — Decision Authority Matrix now matches Tier definitions exactly.
4. T0 expanded per latest Founder directive: new games + `principles.md` + 4 specific critical `.squad/` structural changes (routing.md tier defs, config.json schema, decisions pipeline, agent folder naming).
5. Hub roster changes confirmed at T1 per Founder directive.
6. Quick Reference tables placed FIRST for immediate agent use.
7. Structure: Quick Ref → Philosophy → Tiers → Zones → Authority → Ceremonies → Cross-refs → Appendix.

**Key design principle:** One source of truth per concept. Tables over prose. Constitution, not operating manual. Cross-reference dedicated docs instead of duplicating them.

**Status:** 📋 DRAFT — awaiting Founder comparison and approval

---

### 2025-07-25: Governance Extraction — Ceremonies & Skill Lifecycle

**Requested by:** Joaquín (Founder)

**What was done:**
1. Added "Mandatory Project Ceremonies" section to `.squad/ceremonies.md` — Kickoff Review (START), Mid-Project Health Check (MIDPOINT), Closeout & Harvest (END). Includes skills assessment and team evaluation requirements per governance v1 Domain 4.
2. Created `.squad/skills/SKILL-LIFECYCLE.md` — lean reference doc (tables over prose) covering skill categories, promotion rule, lifecycle phases, confidence levels, and cascade mechanics. Sourced from governance v1 Domain 3.

**Why this matters:** These were embedded in the 1051-line governance.md and not surfaced as standalone operational docs. Extracting them makes them discoverable by agents without reading the full governance document. The ceremonies are founder-mandated hard gates — missing them means skipping skills assessment and team evaluation at critical project milestones.

---

### 2025-07-25: Autonomy Model Reference Document

**Requested by:** Joaquín (Founder)

**What was done:**
Created `.squad/identity/autonomy-model.md` (147 lines) — rescued operational content from governance v1 Domains 2, 6, and 7 that was intentionally cut from governance-v2 for brevity but still needed as a reference.

**Content rescued:**
- Zone A/B/C detailed rationale tables (WHY each element is in its zone, not just WHAT)
- Flora TypeScript strict gate example for Zone B extension
- Configuration Inheritance tables (What Cascades + inheritance modes, What Stays Local)
- Inheritance Conflict Resolution rules (4 modes: mandatory, mandatory minimum, available, default)
- Hub Responsibilities (5 items) and Downstream Responsibilities (6 items)
- Autonomy by Repository table (4 repos with profiles)

**Design decision:** This is a reference doc, not governance. `governance.md` remains the authority on tiers and zones. `autonomy-model.md` explains HOW the model works operationally — tables over prose, zero philosophy paragraphs.

---

## Learnings

### 2026-07-25: Guardrails Implementation (Phase 6, Issue #188)

**Requested by:** Joaquín (Founder)  
**Scope:** Implement guardrails G1-G14 from the optimization plan into governance files

**What was done:**

1. **Scribe Charter (.squad/agents/scribe/charter.md)** — Added guardrails to Conditional Tasks section:
   - **G1:** decisions.md max 5KB auto-archive (verified present in task #4)
   - **G2:** SKILL.md max 5KB with overflow to REFERENCE.md per template
   - **G3:** Log cleanup — auto-purge files >30 days from .squad/log/ and .squad/orchestration-log/

2. **Governance (.squad/identity/governance.md)** — Added new "## 7. Guardrails" section before Appendix with lean rule table:
   - **G5:** Hub roster = infrastructure/tooling only. Game agents live in project repos.
   - **G7:** now.md single source of truth. Only .squad/identity/now.md authoritative. Coordinator checks freshness.
   - **G8:** squad.agent.md consistency check (hash comparison on commits).
   - **G9:** Cron workflows ≥1 hour intervals only.
   - **G12:** Identity docs = active decisions only. Archive rejected options to decisions-archive.md.

3. **Ceremonies (.squad/ceremonies.md)** — Updated Mandatory Project Ceremonies table with guardrail callouts:
   - **Kickoff Review → G4:** Review quality-gates.md for current stack relevance.
   - **Closeout & Harvest → G6:** Clean up ceremonies.md, disable obsolete project-specific ceremonies.
   - **Closeout & Harvest → G14:** Verify squad.config.ts has correct project name.

**Design principles:**
- Scribe changes: minimal additions to existing conditional task structure
- Governance: guardrails placed in lean rule table (not prose essays) to keep file <300 lines
- Ceremonies: guardrail notes embedded in table content, not new ceremony definitions
- No rewrites of existing content — surgical additions only

**Note on omitted guardrails:**
- **G4, G6, G14:** Embedded in ceremonies.md
- **G10, G11, G13:** Not implemented (ralph-watch and .squad/ periodic cleanup are operational, not governance document concerns)

**Status:** ✅ COMPLETE
