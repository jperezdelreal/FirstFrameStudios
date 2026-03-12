# Solo — History (formerly Keaton)

## Core Context

**Solo's Core Expertise:** Architecture deep work, governance design, ecosystem audits, pre-mortem analysis. Discovers institutional patterns (monolithic files, activation gaps, context bloat) and designs multi-phase solutions. 

**Key Technical Learnings:**
- Quality gates must trace to real failures, not theory
- Monolithic files cascade into feature friction (firstPunch gameplay.js 695 LOC, ComeRosquillas game.js 1636 LOC = same P0 architectural blocker pattern)
- Infrastructure often 80% built; activation gap is the real bottleneck
- Tier ≠ Priority: approval authority (tiers T0-T3) is independent from execution order (priorities P0-P3)
- "Prepare-but-don't-merge" rule keeps velocity high while respecting blockers

**Studio Architecture:**
- **Multi-repo hub model:** Hub (FirstFrameStudios) = infrastructure/governance/skills only. Game repos (ComeRosquillas, Flora) autonomous, connected via upstream. ralph-watch multi-repo scheduler.
- **Autonomy Model (3 zones):** Zone A (Solo decides architecture), Zone B (Hub cascades), Zone C (Repos autonomous). Governance.md defines authority zones per change type.
- **Ceremonies:** Kickoff, Mid-Project Health, Closeout & Harvest. Skills assessment and team evaluation mandatory at critical gates.

**Key Decisions Authored:**
- Priority & Dependency System (P0-P3 + blocked-by:* labels, prepare-mode for blocked work)
- T1 Authority Restructure (Lead-only approvals, no founder at T1)
- Governance v2 (ultra-minimal T0, Zone A/B/C clarity)
- Skill Lifecycle (4 phases: discovery, proposal, approval, cascade)
- Guardrails G1-G14 (distributed across governance docs per domain)

**Important File Paths:**
- `.squad/identity/governance.md` — authority source for tiers, zones, ceremonies, guardrails
- `.squad/decisions.md` — active decisions only (<5KB per G1)
- `.squad/agents/scribe/charter.md` — Scribe tasks (G1 auto-archive, log cleanup)
- `.squad/agents/ralph/squad.agent.md` — Ralph configuration (scheduler, priority filtering)
- `.squad/identity/autonomy-model.md` — operational reference (how model works, not why)
- `games/*/` — Game-specific repos (ComeRosquillas, Flora) with upstream connection

**Common Pitfalls:**
- Architecture decisions need founder approval at T0 scope changes only; T1 work is Lead's authority
- Stale references (Godot, hibernated agents) in active configs block new agents from working
- Circular dependencies: break cycle, designate entry point, escalate if P0 involved
- Context bloat in history/decisions: G1 (5KB decisions), G3 (30d log cleanup) prevent agent context waste

---

## 2026-03-12: Pre-Autonomy Diagnostic (Pre-merge gate)

**Requested by:** Joaquín (Founder)  
**Scope:** Full ecosystem diagnostic before merging optimization branch and starting ralph-watch in autonomous mode.

**What was checked:**
- Squad infrastructure across all 4 repos (team.md, decisions.md, agents, gitattributes, upstream)
- Ralph-watch readiness: all 7 functions validated, dry-run successful
- GitHub state: issues, PRs, labels across all repos
- Stale references: Ashfall/Godot/hibernated agents in active config files
- Workflow health: all 25 workflows active, cron intervals G9-compliant

**Verdict:** 🟡 READY WITH CAVEATS — no blockers, but 10 recommended fixes documented in optimization-plan-check.md.

**Key findings:**
1. decisions.md exceeds G1 limit — needs Scribe archive pass
2. Hub issues #187-189 are DONE, should be closed
3. Stale Godot references in ceremonies.md, PR template, CONTRIBUTING.md
4. Downstream repos missing `blocked-by:*` and `tier:*` labels
5. Flora issue #9 assigned to hibernated `squad:wedge` instead of Flora agent
6. Flora/ffs-squad-monitor upstream.json never synced

**Status:** ✅ COMPLETE

---

## 2026-07-26: Priority & Dependency System — Documentation Implementation

**Type:** T1 Implementation (Lead authority)  
**Requested by:** Joaquín (Founder)

**What was implemented:**
1. governance.md §2.5 "Execution Priority" — priority levels, tier vs priority independence, assignment decision tree
2. governance.md §7 "Guardrails" — G13 (inflation advisory), G14 (dependencies section required), G15 (P0 escalation >3d)
3. routing.md "Lead Triage Guidance" — extended checklist with priority evaluation and dependency identification
4. routing.md "Priority-Aware Routing" — Ralph execution order, label definitions, default rule

**Design principles:**
- All 5 Founder decisions from design review incorporated
- Surgical insertions only, no content rewrites
- Exact approved text preserved

**Key architectural insight:** Tier and Priority are independent axes. Tier = who approves (authority delegation). Priority = when it runs (execution order). Conflating them creates governance confusion.

**Status:** ✅ COMPLETE

---

## 2026-07-25: Governance Restructure — T0 Ultra-Minimal, T1 Lead Authority

**Requested by:** Joaquín (Founder)  
**Scope:** governance.md full rewrite of approval tiers per Founder directives

**What changed:**
1. T0 ultra-minimized — only new games + principles.md remain (not T0 scope changes, hub roster changes, governance, tech decisions)
2. T1 becomes Lead-only authority — every "Founder approves" removed; Solo permanent authority at T1
3. Items moved T0→T1 — hub roster, .squad/ refactors, governance changes (unless modifying T0 itself), technology decisions, tool repos
4. Decision Authority Matrix rewritten (T0 rows reduced to ~6)
5. Delegation Rules updated — "T1 fully delegated to Lead, no founder approval needed"

**Why this matters:** Founder was over-involved in T1 (routine feature work). Frees Founder for vision/direction only, lets Lead move fast on architecture/tooling without escalation.

**Status:** ✅ COMPLETE

---

## 2026-07-24: ComeRosquillas Issue Triage & Squad Labeling

**Requested by:** Joaquín  
**Repo:** jperezdelreal/ComeRosquillas  
**Context:** Game shipped to live; 8 open issues with no squad routing labels blocking Ralph auto-assignment.

**Work Completed:**
1. Created 14 labels (squad base + 10 squad:{member} labels, 4 priority labels)
2. Triaged all 8 issues with routing decisions:
   - #1: Modularize game.js → squad:solo + squad:chewie, **P0** (architectural blocker)
   - #2: Mobile/touch → squad:wedge, **P2** (post-launch polish)
   - #3: High score persistence → squad:wedge + squad:lando, **P2** (engagement feature)
   - #4: Multiple maze layouts → squad:tarkin + squad:lando, **P1** (essential for replayability)
   - #5: Simpsons cutscenes → squad:wedge, **P3** (pure polish)
   - #6: CI pipeline → squad:jango, **P1** (high-leverage tooling)
   - #7: Ghost AI difficulty → squad:tarkin, **P1** (core quality)
   - #8: Sound effects → squad:greedo, **P1** (arcade feel essential)
3. Added triage comments explaining rationale, routing, priority to all 8 issues

**Pattern Observed:** Monolithic game.js problem repeats across projects. Same P0 blocker pattern.

**Status:** ✅ COMPLETE — Ralph can now auto-route work

---

## 2026-07-24: Flora Architecture Definition & Project Scaffold

**Requested by:** Joaquín  
**Repo:** jperezdelreal/flora  
**PR:** #2 (feat/flora-architecture → main)

**What was delivered:**
1. **Architecture Document** — 7-module structure (core, scenes, entities, systems, ui, utils, config), scene-based architecture, ECS-lite, typed event bus, PixiJS v8 patterns
2. **Module Scaffold** — 13 files (SceneManager, EventBus, BootScene, config, utils, entity/system/ui stubs, main.ts)
3. **Build Verification** — `tsc --noEmit` zero errors, `npm run build` 268KB bundle (84KB gzip)

**Key architectural decisions:**
- Scene-based, not state-machine (simpler for small game)
- ECS-lite, not full ECS framework (avoid over-engineering)
- Event bus for cross-module communication (prevents circular deps)
- Config/utils = pure modules

**Status:** ✅ COMPLETE — PR #2 open, build passing

---

## 2026-07-24: Multi-Repo Studio Governance Document

**Ceremony Type:** Governance Architecture — Studio-wide operating manual  
**Requested by:** Joaquín

**Deliverable:** `.squad/decisions/inbox/solo-multi-repo-governance.md` (~28 KB, 9 sections)

**Key Decisions Proposed:**
1. Tiered Approval Model (T0-T3) — varying approval levels, not all uniform
2. Game Repos Autonomous for T0-T1 work
3. @copilot auto-assign strategy (true in games, false in hub)
4. Skill Promotion Pipeline (discover → draft → propose → approve → sync)
5. Hub Role (skill curation, pattern recognition, tool maintenance, upstream sync)
6. Solo Reviews Only T2 PRs (Jango handles game PRs)
7. Six Studio Ceremonies (Kickoff, Planning, Retro, Ship, Post-Mortem, Next Project)
8. Shipped Games Stay Active (maintenance mode), Shelved games archived
9. Idea-to-Building Timeline ~1-2 days
10. Three Laws of FFS (Games autonomous, Hub authoritative; everything escalates by tier; knowledge flows up/down)

**Status:** AWAITING FOUNDER APPROVAL

---

## 2026-07-24: Multi-Repo Hub Audit

**Ceremony Type:** Major — Studio-wide Restructuring Review  
**Requested by:** Joaquín  
**Scope:** Full audit after monorepo → multi-repo pivot

**Context:** Studio completed massive pivot — FFS hub-only, ComeRosquillas/Flora/ffs-squad-monitor split to own repos, ralph-watch v2, GitHub Pages deployed.

**Key Findings:**
1. Hub holds 1.6 GB Ashfall Godot files (6,071 files) — #1 cleanup item
2. 5 of 15 agents should hibernate (Ashfall-specific for art pipeline)
3. decisions.md 164 KB with 161 entries (~70% Ashfall) — must archive to <30 KB
4. 12 Python tools all Godot-specific — delete from hub
5. 3 Godot workflows will never trigger — delete
6. 8 Godot skills should be archived (not deleted) to `.squad/skills/_archived/`
7. routing.md has no multi-repo routing
8. MCP config is just Trello example
9. Lean roster: 11 active + 4 hibernated covers web game needs
10. Discord webhook = highest-leverage unbuilt feature

**Top 3 Actions:**
1. Delete games/ashfall/ + games/first-punch/
2. Archive ~30 Ashfall decisions, compress decisions.md to <30 KB
3. Rewrite team.md + routing.md for multi-repo web game stack

**Status:** AWAITING FOUNDER APPROVAL

---

## Learnings

### 2026-03-12: Standard Project Lifecycle Design

**Architecture decision:** Designed a 4-ceremony lifecycle (Kickoff → Sprint Planning N → Mid-Project Evaluation → Closeout) that is standard across ALL FFS repos regardless of type. Key insight: ceremonies must produce GitHub issues as primary output — `.md`-only ceremonies are introspective but don't feed the work pipeline.

**Pattern — "vida propia" loop:** design doc → ceremony → issues → Ralph → sessions → work → ceremony re-evaluates → more issues. The loop is self-sustaining because Ralph detects lifecycle transitions via `project-state.json`.

**Bug discoveries:**
- `squad-triage.yml` line 207 blindly applies `go:needs-research` to every issue — fix: content-aware triage (check for acceptance criteria, ceremony-origin labels)
- `ralph-watch.ps1` line 686 hard-skips `go:needs-research` issues — fix: route to assigned agent for research, don't skip entirely

**Key file paths:**
- `.squad/decisions/inbox/solo-project-lifecycle-design.md` — full lifecycle design doc
- `.squad/project-state.json` — per-repo lifecycle tracking file (new convention)
- `tools/scheduler/schedule.json` — scheduler tasks (backlog-grooming to be replaced by Sprint Planning ceremony)

**User preference:** Joaquin wants repos to be self-sustaining ("vida propia"). Generic terminology ("design doc" not "GDD") so lifecycle works for games, tools, and infra equally. Sprint completion is issue-based, not calendar-based.
