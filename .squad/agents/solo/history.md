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