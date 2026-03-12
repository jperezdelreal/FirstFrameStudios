# Solo — History (formerly Keaton)

## Core Context

**Solo's Core Expertise:** Architecture deep work, governance design, ecosystem audits, pre-mortem analysis. Discovers institutional patterns (monolithic files, activation gaps, context bloat) and designs multi-phase solutions. 

**Key Technical Learnings:**
- Quality gates must trace to real failures, not theory
- Monolithic files cascade into feature friction (firstPunch gameplay.js 695 LOC, ComeRosquillas game.js 1636 LOC = same P0 architectural blocker pattern)
- Infrastructure often 80% built; activation gap is the real bottleneck
- Tier ≠ Priority: approval authority (tiers T0-T3) is independent from execution order (priorities P0-P3)
- "Prepare-but-don't-merge" rule keeps velocity high while respecting blockers
- Ceremonies must produce GitHub issues as output; .md-only ceremonies don't feed the work pipeline
- Architect's job is to distill founder brainstorms, not transcribe — apply judgment to simplify

**Studio Architecture:**
- **Multi-repo hub model:** Hub (FirstFrameStudios) = infrastructure/governance/skills only. Game repos (ComeRosquillas, Flora) autonomous, connected via upstream. ralph-watch multi-repo scheduler.
- **Autonomy Model (3 zones):** Zone A (Solo decides architecture), Zone B (Hub cascades), Zone C (Repos autonomous). Governance.md defines authority zones per change type.
- **Ceremonies:** Sprint Planning (kickoff + ongoing health), Closeout (event-driven). Standard lifecycle applies to all repos except Hub (infrastructure-only). Project-state.json tracks phase/sprint/design_doc.

**Key Decisions Authored:**
- Priority & Dependency System (P0-P3 + blocked-by:* labels, prepare-mode for blocked work)
- T1 Authority Restructure (Lead-only approvals, no founder at T1)
- Governance v2 (ultra-minimal T0, Zone A/B/C clarity)
- Skill Lifecycle (4 phases: discovery, proposal, approval, cascade)
- Guardrails G1-G14 (distributed across governance docs per domain)
- Standard Project Lifecycle (2 ceremonies, 3 JSON fields, issue-driven sprints)
- Lifecycle Integration in ralph-watch (automatic ceremony triggers via Check-ProjectLifecycle)
- Defense-in-Depth for PR Dedup (dual enforcement: server-side + prompt-side tracking)

**Important File Paths:**
- `.squad/identity/governance.md` — authority source for tiers, zones, ceremonies, guardrails
- `.squad/decisions.md` — active decisions only (<5KB per G1)
- `.squad/agents/scribe/charter.md` — Scribe tasks (G1 auto-archive, log cleanup)
- `.squad/agents/ralph/squad.agent.md` — Ralph configuration (scheduler, priority filtering)
- `.squad/identity/autonomy-model.md` — operational reference (how model works, not why)
- `.squad/ceremonies.md` — ceremony templates and execution guidance
- `games/*/project-state.json` — per-repo lifecycle tracking
- `games/*/` — Game-specific repos (ComeRosquillas, Flora) with upstream connection

**Common Pitfalls:**
- Architecture decisions need founder approval at T0 scope changes only; T1 work is Lead's authority
- Stale references (Godot, hibernated agents) in active configs block new agents from working
- Circular dependencies: break cycle, designate entry point, escalate if P0 involved
- Context bloat in history/decisions: G1 (5KB decisions), G3 (30d log cleanup) prevent agent context waste

**Session History (Pre-2026-02-27 archived):** Multi-repo hub audit and restructuring completed Q4 2025. ComeRosquillas triaged all 8 issues with squad routing; Flora architecture defined (scene-based, ECS-lite, PixiJS v8); Multi-repo governance doc drafted. Hub audit found 1.6GB Ashfall files, 161 archived decisions, 12 Godot-specific tools (all cleaned up). ffs-squad-monitor Sprint 0 completed with core monitoring features; Sprint 1 planning executed (5 issues, 4 sprints planned, backend extraction as P0 blocker)

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

**Status:** ✅ COMPLETE


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

### 2026-03-12: Lifecycle Self-Review — Simplification

**Self-review outcome:** My initial 400-line lifecycle design was over-engineered. The founder brainstormed out loud and I transcribed too faithfully instead of applying my own judgment. Revised from 4 ceremonies to 2, from 5 JSON fields to 3, and extracted bug fixes into separate concerns.

**Key simplifications:**
- Kickoff merged into Sprint Planning (kickoff = first sprint planning, nothing more)
- Mid-Project Evaluation merged into Sprint Planning (health check happens at every sprint boundary)
- Closeout changed from 7-day timer loop to event-driven (timers create noise)
- Hub explicitly excluded from lifecycle — it's infrastructure, not a project
- Bug fixes (squad-triage.yml, ralph-watch.ps1) extracted from design doc — real bugs but orthogonal to ceremony architecture

**Lesson learned:** When a stakeholder brainstorms, the architect's job is to distill, not transcribe. A 400-line ceremony spec for a small studio would be ignored. Two ceremonies and three JSON fields close the same gap.

**Decisions made (T1 authority, Founder-authorized):**
1. Sprints end by issues closed, not calendar — calendar sprints are overhead for this studio size
2. Closeout is event-driven, not timer-driven — 7-day loops create noise
3. Hub has no lifecycle — infrastructure doesn't sprint
4. Archive signal = close the roadmap issue — simplest native GitHub action
