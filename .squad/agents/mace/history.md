# Mace — History

## Context
- **Project:** First Frame Studios — multi-genre game development studio
- **User:** joperezd (Founder)
- **Tech:** Godot 4 (GDScript), previously Canvas 2D (firstPunch)
- **Team:** 14 specialists (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien, Jango, Mace)
- **Hired:** 2026-03-08 — Role created based on team evaluation v3 (Ackbar) which identified Solo carrying dual Lead + Operations burden
- **Next project:** ASHFALL (action roguelike), CINDER (platformer), or PULSE (rhythm-action) — founder deciding

## Learnings

### Ashfall Sprint 0 Plan (2026-[TBD])

#### Key Scope Decisions
1. **Locked MVP:** 1 stage + 2 characters + basic AI + round system. All subsequent content (additional characters, stages, online, story) explicitly out-of-scope for Phases 1-4. Owner enforcement by Mace.
2. **Phased delivery:** Architecture → Balance → Art → Audio → Expansion. Each phase unlocks the next; no sequential bottleneck.
3. **Studio methodology:** 20% load cap + Scrumban (3-task WIP limit) ensures 14-agent team can work truly parallel. Proven pattern from firstPunch.

#### Critical Path & Gates
- **M0 gate (Day 2):** Yoda GDD + Solo architecture must be approved before Chewie/Lando start coding. Design locks strategy upstream.
- **M1-M3 gates (Days 3-5):** Sequential but overlapping — each gate unblocks next team without creating waterfall.
- **M4 gate (Day 7):** Stable playable build required. Ackbar mid-sprint playtesting (Day 4) catches feel issues early (2-3 days for tuning before ship).

#### Risk Mitigation Priorities
1. **Godot physics behavior (Day 1 spike test):** RigidBody2D knockback must behave predictably. If not, pivot to kinematic approach early.
2. **GDD clarity (Day 1 completion):** Ambiguous mechanics cascade into delays. Yoda → Solo sign-off same-day prevents rework.
3. **Playtesting feedback loop:** Mid-sprint playtest prevents feeling-is-wrong surprises. If feel bad, Lando has 2-3 days to tune (fast iterations on hitstun, knockback values).

#### Team Composition Notes
- **14-agent team proved effective:** No single agent bottleneck; parallel work streams (Design, Engine, Gameplay, Art, Audio) can execute in parallel after architecture gate.
- **Blocked agents in Phase 0:** Nien, Leia, Bossk, Greedo intentionally parked (waiting for stable builds + art direction). Tarkin's AI is lightweight (Phase 4 extension, not blocking MVP).
- **Developer joy metric:** Added 1-5 survey mid-sprint + end-sprint to track morale. Load cap + clear scope = high joy expected.

#### Documentation & Knowledge Capture
- Created `.squad/decisions/inbox/mace-ashfall-sprint0.md` for scope governance
- SPRINT-0.md serves as single source of truth for project execution (deliverables, dependencies, risks)
- Phase 2+ planning deferred (Phase 0 gate required before Phase 1 planning)

#### Process Lessons
- **Async standup effectiveness:** Written daily updates (#ashfall) better than sync standups for distributed team. Enables flexibility while maintaining visibility.
- **Load tracking transparency:** Appendix in SPRINT-0.md shows each agent's % load. Mace monitors, reallocates if anyone exceeds 20%. Clear.
- **Blocker escalation path:** Any task stuck > 4 hours → #ashfall ping Mace → immediate unblock or reallocation. Prevents silent blockers.

---

## Ashfall Sprint 0 Kickoff (2026-03-08)

### Sprint 0 Plan Delivered
**Date:** 2026-03-08T120000Z  
**Artifact:** `games/ashfall/docs/SPRINT-0.md` (21KB)

Completed comprehensive Sprint 0 execution plan for Ashfall, a 1v1 fighting game in Godot 4. Plan covers:
- **MVP Scope (LOCKED):** 1 stage + 2 characters + basic AI + round system + game flow
- **Sprint 0 Focus (1 week):** Architecture + playable prototype; no content art, sound, menus
- **Phased Content Expansion:** 5 phases (Foundation → Balance → Art → UI/Stage → Audio) with parallel lanes
- **Studio Methodology:** 20% load cap + Scrumban (3-task WIP limit) ensures 14-agent true parallelism
- **Technology Lock:** Godot 4 + GDScript (no re-evaluation during project)
- **Feature Triage:** Four-Test Framework (core loop, player impact, cost-to-joy, coherence)
- **Release Gates:** Definition of Done with 6 checkpoints (acceptance criteria, review, integration, docs, git, playtesting)
- **Knowledge Capture:** Sprint 0 outputs become reusable patterns for future FFS projects

### Key Governance Decisions Locked
1. **Scope change protocol** — Any feature request follows: Request → Yoda triage (Four-Test) → Decision → joperezd approval → Document
2. **Load cap enforcement** — 20% max per agent per phase. Mace monitors daily. Exceeding 20% triggers immediate reallocation.
3. **Async standup culture** — Daily written updates in #ashfall (not sync meetings). Flexible scheduling, full visibility.
4. **Mid-sprint playtesting** — Day 4 playtest catch issues early. 2-3 days buffer before M4 ship gate (Day 7).
5. **Escalation path** — Task blocked >4 hours → #ashfall ping Mace → immediate unblock or reallocation. No silent blockers.

### Team Composition Notes
- **14-agent team:** Solo (Lead), Chewie (Engine), Lando (Gameplay), Wedge (UI), Boba (Art), Greedo (Audio), Tarkin (AI/Content), Ackbar (QA), Yoda (Creative Director), Jango (Infrastructure), Leia (Stage Art), Bossk (VFX), Nien (Character Art), Mace (Producer)
- **Parked in Phase 0:** Nien, Leia, Bossk, Greedo (waiting for stable builds + art direction). Tarkin's AI is lightweight (Phase 4 extension, not blocking MVP).

### Sprint 0 Deliverables
| Agent | Deliverable | Status |
|-------|-------------|--------|
| **Yoda** | Game Design Document | ✅ Completed |
| **Solo** | Architecture Proposal | ✅ Completed |
| **Jango** | Godot project scaffold | Blocked on M0 approval |
| **Chewie** | Core gameplay systems | Blocked on M0 approval |
| **Lando** | Fighter controller | Blocked on M0 approval |
| **Wedge** | HUD + game flow | Blocked on M0 approval |
| **Boba** | Art direction document | Blocked on M0 approval |
| **Tarkin** | Basic AI opponent | Blocked on M0 approval |
| **Ackbar** | Playtesting & feedback | Scheduled Day 4 |

### Critical Gates & Milestones
- **M0 (Day 2):** GDD + Architecture approval. Design locks strategy upstream.
- **M1-M3 (Days 3-5):** Sequential but overlapping gates. Each unblocks next team without waterfall.
- **M4 (Day 7):** Stable playable build required. Ship gate.

### Risk Mitigation
1. **Godot physics behavior** — Day 1 spike test on RigidBody2D knockback. If unpredictable, pivot to kinematic early.
2. **GDD clarity** — Day 1 completion. Yoda → Solo same-day sign-off prevents cascading rework.
3. **Playtesting feedback loop** — Mid-sprint (Day 4) testing catches feel issues. 2-3 day buffer before Day 7 ship.

### Integration with Yoda & Solo
- **Yoda (Creative Director):** Knows Mace's phased plan. Four-Test Framework will govern feature triage. Has Creative Director tie-breaker authority.
- **Solo (Lead Architect):** Knows Mace's load cap + Scrumban methodology. Architecture supports 6 parallel work lanes. M0 gate validates design + code contracts before Phase 1 code begins.

### Status
✅ Sprint 0 plan locked. All governance documented. Team ready for M0 approval and parallel execution.

---

## Yoda & Solo Partnership Notes

**Cross-team visibility:** Mace now aware of Yoda's GDD creative lock (Ember System, scope boundary, deterministic simulation requirement). Sprint 0 plan enforces this scope with governance protocol. No feature creep possible.

**Cross-team visibility:** Mace now aware of Solo's architecture (6 parallel work lanes, module boundaries, resource-driven design). Sprint 0 phased plan aligns with architectural parallelism. Phased expansion (Balance → Art → Audio) matches architecture's frame-locked determinism.
