# Mace — History

## Context
- **Project:** First Frame Studios — multi-genre game development studio
- **User:** joperezd (Founder)
- **Tech:** Godot 4 (GDScript), previously Canvas 2D (firstPunch)
- **Team:** 14 specialists (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien, Jango, Mace)
- **Hired:** 2026-03-08 — Role created based on team evaluation v3 (Ackbar) which identified Solo carrying dual Lead + Operations burden
- **Next project:** ASHFALL (action roguelike), CINDER (platformer), or PULSE (rhythm-action) — founder deciding

## Learnings

### Documentation Audit & Milestone Status Sync (2026-03-09)

**Outcome:** Documentation now reflects actual project state. M0-M3 gates are verified complete; M4 is the active target.

**What Was Outdated:**
1. `.squad/identity/now.md` — Said "M3 (Character Sprites): 🔜 NEXT" despite all M3 gate criteria being met (HUD integrated, game flow playable 1v1, character select, round management, victory screen all implemented)
2. `games/ashfall/docs/SPRINT-0.md` progress table — Showed Lando, Wedge, Tarkin as "Blocked" despite all being complete; Nien as Phase 2 with 0% load despite working on #9 character sprites
3. Agent status labeling — Confusing mix of "In Progress" (out of date) and "Blocked" (stale) for completed milestones
4. `.squad/decisions.md` — Sprint 0 decision had placeholder date "2026-[Sprint Start Date]"; no clarity on current M4 gate

**What Was Fixed:**
1. **now.md:** Updated to show M0-M3 ✅ complete, M4 🔲 in progress with P0 blocker #88 identified
2. **SPRINT-0.md:** Updated progress table with accurate milestone gates + load breakdown; clarified #9 is Phase 2 prep (not M3), added M4 ship gate criteria
3. **decisions.md:** Appended new "Sprint 0 Milestone Status Update" entry (2026-03-09) documenting M0-M3 completion and M4 activation

**Lesson Learned:** **Documentation debt grows silently.** When milestones complete, update living docs immediately. Stale docs → team confusion → slower decisions. The pattern:
- Merge PR → verify "Closes #N" → check if milestone complete → UPDATE now.md + SPRINT-0.md + decisions.md same day (not weeks later)
- Historical docs (retros, ceremonies, proposals) stay frozen; LIVING docs (now.md, progress tables, active decisions) must reflect current state
- Founder visibility depends on accurate status reporting. Contradictions (saying "M3 is next" while showing all M3 criteria met) erode trust.

**Process Improvement:** Add "update documentation" as explicit post-milestone task in Mace's checklist, before closing the milestone.



**Outcome:** GitHub is now the source of truth for all First Frame Studios work.

**What Was Built:**
1. **README.md Development Section** — Links to Issues, Projects, Wiki, and workflow diagram. Drives all new team members to CONTRIBUTING.md.
2. **CONTRIBUTING.md** — Complete workflow specification:
   - Branch naming: `squad/{issue-number}-{slug}`
   - Label system: `game:*`, `squad:*`, `type:*`, `priority:*`, `status:*`
   - Commit conventions with examples
   - PR process, code review standards, load governance
3. **team.md Issue Source Section** — Clarifies that FirstFrameStudios repo (jperezdelreal/FirstFrameStudios) is the issue source, filtered by `game:ashfall` for current sprint
4. **Decision Document** — `mace-github-ops-setup.md` captures decisions, risks, and follow-up actions

**Key Decisions:**
- **Label-driven allocation:** Squad agents pick up issues by label (`squad:gameplay`, `squad:engine`, etc.), not manual assignment
- **Load cap in process docs:** 20% rule codified in CONTRIBUTING.md; Mace enforces via PR review
- **Wiki optional:** All critical processes in CONTRIBUTING.md + repo docs; Wiki can host design docs separately
- **Game tagging enables multi-project:** `game:ashfall`, `game:cinder`, `game:pulse` allow same team, same repo, parallel sprints

**Patterns That Work:**
- Branch naming with issue number creates automatic GitHub linking without extra toil
- Squad labels (`squad:*`) are discovery mechanism; no need for manual assignment bot
- Commit format with "Fixes #XX" + co-authored-by enables history tracing and attribution across years
- Load capacity governance in process docs > separate tracking tool; keeps it visible to all agents

**Risks Identified:**
1. **Wiki not enabled:** GitHub API doesn't support wiki creation; joperezd must enable manually in settings
2. **Label inconsistency:** If agents don't use correct labels, label-driven filtering breaks; needs onboarding
3. **Branch naming not enforced:** Without GitHub Actions validator, some PRs will violate `squad/{issue}` convention; recommend adding pre-commit hook or GHA validation

**Comparison to firstPunch:**
- firstPunch used ad-hoc Slack tracking; didn't have central issue source. GitHub Issues brings clarity.
- firstPunch had no defined workflow; CONTRIBUTING.md standardizes for Ashfall + future games.
- firstPunch load tracking was manual (Solo + Keaton guessed); GitHub label + load-cap process makes it visible and auditable.

**Next Iteration (Post-Sprint-0):**
- [ ] Gather feedback from Solo, Yoda, Lando on label system; adjust if needed
- [ ] Build GitHub Actions workflow to validate commit format and branch naming
- [ ] Create Wiki home page linking to GDDs, ARCHITECTURE, playbooks (after Wiki enabled)
- [ ] Capture any label adjustments in CONTRIBUTING.md v1.1

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
