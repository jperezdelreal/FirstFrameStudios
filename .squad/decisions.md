# Squad Decisions

> Active decisions the team must respect. Historical decisions in `decisions-archive.md`.
> Format: see `templates/decision-record.md`.

---



## Studio Directives

### Joaquin never reviews code
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Jango handles all PR reviews. Founder focuses on vision, not implementation.

### GitHub-First Development
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Use GitHub's full potential — Issues, Projects, PRs, Actions. Everything active and visible.

### Repo Autonomy
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
Agents can create public repos on demand without prior approval. Full autonomy in repo management.

### Visual Quality Standard
**By:** Joaquin | **Date:** 2026-03-10 | **Status:** Active
Games must be visually impressive. No cheap-looking prototypes. Learn new frameworks, show off.

### No Podcaster / Text-to-Speech
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
No TTS integration. Out of scope for FFS.

### Tool Engineer Autonomy
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Jango has NO bandwidth limit. Full freedom to propose and create tools, scripts, automations.

### Wiki & Dev Diary Auto-Publish
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Wiki and devlog updates are automatic after each milestone. Mace's responsibility. Never manual.

### GitHub Pages Architecture
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
- FFS Hub Page: brand, identity, studio presentation (NOT game content)
- Game Pages: showcase, screenshots, changelog, playable demo
- Consistent Astro template, per-game branding. Push-to-main deploys.

### FFS Homepage Locked
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
FFS homepage is practically perfect. Do NOT redesign. Blog auto-publishes progress from game repos.

### Governance v2 — Tier Restructure
**By:** Joaquin | **Date:** 2026-03-12 | **Status:** Active
- T0 ultra-minimal: only new games + principles.md + critical .squad/ structural changes
- T1 Lead-only: no founder approval. Solo decides.
- No agent-to-founder escalation at T1. Chain: agents -> Solo -> Founder (T0 only).
- .squad/ refactors split: content refactors = T1, structural/workflow = T0

---

## Active Architecture Decisions

### Multi-Repo Hub Architecture
**By:** Solo | **Date:** 2026-03-11 | **Status:** Active
FFS is hub-and-spoke. Hub = no game code, only infrastructure. Each game/tool has its own repo with `squad upstream` to hub. Skills, quality gates, and governance cascade down.


---

## Active Process Decisions

### Autonomous Backlog Generation Vision
**By:** Joaquin Perez del Real | **Date:** 2026-03-12 | **Status:** Active (Strategic Vision)
Each game repo has "vida propia" — a life of its own. Ralph-watch provides autonomous session execution; the missing piece is autonomous backlog generation. Repos should self-generate issues by having their Lead read the GDD/PRD and create sprint issues automatically. This closes the loop: repos generate → Ralph consumes → sessions execute autonomously. Tracked by issue #190.

### Standard Project Lifecycle with Issue Generation
**By:** Joaquin Perez del Real (via Founder directive) | **Date:** 2026-03-12 | **Status:** Active (T1, Implemented)
Every ceremony (Kickoff, Sprint Planning, Mid-Project, Closeout) must produce GitHub issues as output, not just .md documentation. The lifecycle flows: Kickoff (roadmap + sprint definitions) → Sprint Planning N (create issues, define success criteria) → sprint ends when issues done → Mid-Project (evaluate, decide continue or closeout) → Closeout (continuous improvement loop: evaluate → create issues → resolve → re-evaluate). Non-game repos (Hub, Squad Monitor) don't have GDDs — they use PRDs or equivalent specs. The design must be standard across all FFS repos regardless of project type. This closes the "pipeline dries up" gap. Full design: `.squad/decisions.md` → Standard Project Lifecycle (Final).

### Solo Authority on Lifecycle Design
**By:** Joaquin Perez del Real | **Date:** 2026-03-12 | **Status:** Active (T1)
Solo has full T1 authority to make final lifecycle design decisions. The Lead should review critically, trim what's excessive, keep what's practical, then implement autonomously. Not all founder suggestions should be adopted directly.

### Priority & Dependency System (P0-P3)
**By:** Solo | **Date:** 2026-03-12 | **Status:** Active (T1, Founder-reviewed)
Priority (P0-P3) determines execution order; Tiers (T0-T3) determine approval authority. Independent axes.
- P0=Blocker, P1=Sprint-critical, P2=Normal (default), P3=Nice-to-have
- Dependencies tracked via `blocked-by:*` labels + issue body `## Dependencies` section
- Blocked work: prepare (tests, scaffold, draft PR) but don't merge until blocker resolved
- Emergency follow-up auto-labeled P1; Lead can bump to P0
- Ralph auto-unblocks after 24h when blocker closes; Lead can re-block
- G13: Advisory inflation warning at >20% P0/P1
- Full design: `.squad/decisions-archive.md`

### Defense-in-Depth for PR Dedup and Issue Triage
**By:** Jango | **Date:** 2026-03-12 | **Status:** Proposed
Ralph-watch had 5 interrelated bugs causing issues with triage labeling, needs-research handling, PR review quality, and PR comment loops.
- **Triage heuristic over blind defaults:** squad-triage.yml evaluates issue body quality (acceptance criteria, checklists, structured sections, 100+ char body) before assigning go:ready vs go:needs-research. Simple regex heuristic, not NLP.
- **needs-research is not a hard gate:** Issues with squad:{member} labels are included in sessions with [NEEDS-RESEARCH] marker. Agents can investigate and promote to go:ready.
- **PR review dedup uses dual enforcement:** Both server-side (PowerShell hashtable tracking PR#/SHA) and prompt-side (instructions). Defense in depth pattern from prepare-mode.
- **Formal review flags required:** --request-changes and --approve mandated in prompt. --comment reserved for non-blocking only.
- Consequences: Fewer issues stuck in needs-research limbo, cleaner PR review history, no more re-comment loops on PRs.

### PR Convention
All PRs must include `Closes #N` in body. Branch naming: `squad/{issue-number}-{slug}`.

### Integration Pass Required
After parallel agent work, Solo verifies systems connect before next wave. Hard gate.

### Backlog Automation
Scan code for TODOs, auto-create issues. Lead adjusts workload independently.

### Solo/Jango Role Split
**Date:** 2026-03-09 | Solo = architecture deep work. Jango = tooling + PR reviews + CI. Mace = ops, sprint planning, blocker tracking.

---

## Standard Project Lifecycle (Final)

**By:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-12  
**Status:** ✅ Implemented — T1 authority, Founder-authorized  
**Tier:** T1 (Lead authority — ceremony/process design)  
**Supersedes:** Issue #190 (backlog grooming ceremony)

### Design Summary

Two ceremonies with issue production:
1. **Sprint Planning** — Adapts by context. First sprint = kickoff (read design doc, create roadmap). Subsequent sprints = review + plan next batch. Always produces labeled GitHub issues. Health check built in.
2. **Closeout** — For shipped/mature projects. Evaluate live project against design doc, create improvement issues. Event-driven, not timed.

State tracked in `project-state.json`: `phase`, `sprint`, `design_doc` (3 fields, no over-tracking).

**Core Principle:** Every ceremony produces GitHub issues. A ceremony that only produces `.md` files is incomplete.

Implementation updates: `.squad/ceremonies.md`, `.squad/templates/project-state.json`, `.squad/identity/now.md`. Issue #190 closed, superseded by this design.

---






---

## 2026-03-12 Decisions (Evening Ceremony Block)

### Lifecycle Integration in ralph-watch
**By:** Jango (Tool Engineer)  
**Date:** 2026-03-12  
**Status:** Active (PR #193)  
**Tier:** T1

ralph-watch now has awareness of project-state.json. Added `Check-ProjectLifecycle` as Step 3.5 in ralph-watch's main loop. It runs every round, between the scheduler and the issue scan, checking each repo's lifecycle state and creating ceremony issues when transitions are needed.

**Key choices:**
- Hub exception hardcoded (skip `FirstFrameStudios` by name check)
- Dedup by title search (checks for existing open issues with `[CEREMONY]` or `[ROADMAP]` in title)
- Lead parsed from team.md via regex
- PowerShell pipe for stdin (cross-platform compatible)

**Consequences:** Repos with project-state.json now get automatic Sprint Planning ceremony triggers. Ralph's pipeline stays fed without manual intervention.

---

### ffs-squad-monitor Sprint 1 Planning
**By:** Solo (Lead)  
**Date:** 2026-03-12  
**Status:** Executed  
**Type:** T1 (Lead Authority)  
**Ceremony:** Sprint Planning (kickoff)

Completed Sprint Planning for ffs-squad-monitor. Project decomposed into 4 sprints (backend extraction → deployment → UX polish → performance). Sprint 1 focuses on backend extraction from 26KB vite.config.js (monolithic blocker) and testing foundation.

**Artifacts created:**
- docs/PRD.md (7.5 KB)
- Issue #20: [ROADMAP] Sprint overview
- Issues #21-25: 5 Sprint 1 implementation issues (all `sprint:1` and `go:ready`)
- PR #26: Sprint planning artifacts
- Label: sprint:1

**Team routing:** Lambert (backend extraction), Dallas (error handling + UX), Kane (testing), Ripley (coordination). Balanced workload across roles.

---

---

## 2026-03-13 Decisions (Ralph Acceleration Block)

### Ralph v4 — Per-Repo Parallel Architecture (Superseded)
**By:** Squad (Coordinator), requested by Joaquin  
**Date:** 2026-03-13  
**Status:** SUPERSEDED → See "ralph-watch v4 Rewrite (Tamir-style Simplification)"

Initial proposal for per-repo parallel architecture (separate worker processes, cross-repo priority eliminated, 3.4x throughput gain). Replaced by simpler Tamir-style approach: multi-repo via prompt scope instead of script complexity.

---

### Ralph-watch v4 Rewrite (Tamir-style Simplification)
**By:** Jango (Tool Engineer)  
**Date:** 2026-03-13  
**Status:** Implemented (Committed: cf6ad60)  
**Tier:** T1

Rewrote ralph-watch.ps1 from v3 (1261 lines) to v4 (641 lines, 49% reduction). Multi-repo via prompt scope, not script iteration. Single static prompt tells squad agent to scan all 4 FFS repos; agent handles parallelism internally.

**Dropped:** Night/day mode, issue pre-fetching, activity monitors, PR dedup tracking, Build-SessionPrompt.  
**Kept:** Lock file, JSONL logging, heartbeat, circuit breaker, session timeout (Start-Job), Invoke-GitPull, Invoke-Scheduler, Check-ProjectLifecycle.

Simpler to maintain, full squad autonomy over issue selection. Session timeout retained as safety net.

---

*Last cleaned: 2026-03-13. Previous content archived to `decisions-archive.md`.*
