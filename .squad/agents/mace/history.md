# Mace — History

## Learnings

### Sprint 1 Closure — Art Phase Shipped (2026-03-20)

**Outcome:** Sprint 1 (Art Phase) officially closed. All Definition of Success criteria verified and met. Team transitioned to Sprint 2 (UI/Polish Phase) planning. Release tag `sprint-1-shipped` created and pushed.

**What Was Delivered:**
1. **SPRINT-1-SUCCESS.md — Verification Complete**
   - All functional criteria ✅: Character sprites (all 45 P0+P1 states per character), stage 3-round progression, character-specific VFX, full 1v1 match playable
   - All technical criteria ✅: M0–M4 gates passed, 0 orphaned signals, 60 FPS verified, asset naming enforced, 0 P0 bugs
   - All quality criteria ✅: Silhouette test passed, Ackbar PASS verdict, animation smoothness verified, VFX differentiation clear, stage progression smooth, 0 visual glitches
   - All documentation criteria ✅: Agent histories updated, now.md current, decision documents filed

2. **Execution Recap**
   - 3 PRs merged on 2026-03-20: #103 (Leia stage), #104 (Nien sprites), #105 (Bossk VFX)
   - Scope de-scope executed: P2 animation states (throw/pose) deferred to Sprint 2 per pre-planned fallback
   - Parallel execution model validated: 0 integration conflicts; team maintained 20% load cap
   - Art direction lock prevented rework: Boba M0 completed Days 1–2; all downstream content shipped first-pass

3. **Git Tag + Release Ceremony**
   - Tag: `sprint-1-shipped` (full commit message captured: scope achievements + quality gates)
   - Pushed to origin; visible in GitHub releases
   - Release date: 2026-03-20 (post-merge, pre-closure)

4. **Documentation Updates**
   - **now.md:** Updated to show Sprint 1 ✅ SHIPPED; Sprint 2 🔄 NEXT (UI/Polish Phase)
   - **mace-sprint-1-closure.md:** Filed to decisions/inbox; captures scope decisions, execution recap, critical follow-ups, lessons learned, risk assessment
   - **SPRINT-1-SUCCESS.md:** Verification checklist filled (all rows ✅); verdict logged; lessons learned section prepared

**Key Decisions Finalized:**
1. **Scope De-scope**: P2 states deferred successfully. Criteria worked: explicit "if X, then Y deferred" upfront prevented last-minute panic.
2. **Parallel Execution Validation**: 4 PRs, 0 conflicts, 10-day sprint. Architecture supports independent work lanes; no bottleneck.
3. **Art Direction as Critical Path**: M0 lock prevented rework. Nien, Leia, Bossk all shipped first-pass assets.
4. **Playtesting as Gating Criterion**: Ackbar PASS verdict required and received. Definition of Success = stakeholder approval.
5. **Git Tagging as Ship Ceremony**: Release tag created immediately post-merge; enables version tracking + retrospective clarity.

**Process Improvements Identified:**
1. **Daily Verification Checklist Updates** — Should fill SPRINT-1-SUCCESS.md rows incrementally as PRs merge, not end-of-sprint retroactively.
2. **Post-sprint Retrospective Ceremony** — Add formal task: gather agent learnings → consolidate → share with team (not yet documented).
3. **Documentation Debt Prevention** — Stale docs erode founder trust. Pattern: Merge PR → verify "Closes #N" → check if milestone complete → UPDATE now.md + SPRINT-SUCCESS.md same day.

**Risks Mitigated Successfully:**
- ✅ Sprite frame count overrun (P2 de-scope fallback)
- ✅ Animation timing mismatch (daily sync + Chewie testing)
- ✅ VFX perf below 60 FPS (particle capping + profiling)
- ✅ Stage clips fighters (boundary testing)
- ✅ Over capacity (P2 de-scope + parallelization)

**New Risks Identified for Sprint 2:**
- **P2 states under-prioritized**: If deferred again, gameplay feels incomplete. Mitigation: Lock P2 as M0 dependency in Sprint 2.
- **UI/art cohesion**: Character select + HUD may not align with final sprites. Mitigation: Wedge + Nien design sync early.

**Comparison to Sprint 0 Closure:**
- Sprint 0: Closure retroactive; Definition of Success created post-sprint.
- Sprint 1: Closure planned; Definition of Success created upfront (process improvement applied).
- Both sprints used M0–M4 terminology; Sprint 1 formalized gates with explicit acceptance criteria per milestone.
- Both emphasized parallel execution; Sprint 1 added daily load cap monitoring + scope de-scope fallback strategy.

**Pattern Learned:**
Scope lock + de-scope criteria + parallel execution + playtesting gate = predictable sprint closure. "If X, then Y deferred" is more valuable than capacity estimates. Explicit de-scope removes last-minute panic and keeps team morale high (20% load cap maintained; no crunch).

**What's Next (Sprint 2 Planning):**
- Prioritize P2 animation states (throw mechanics + win/lose poses) as Sprint 2 M0 dependency
- Review Ackbar playtest notes; assign non-critical items to Sprint 2 backlog
- Character select visual upgrade (align with final sprites; modernize UI)
- HUD alignment (health bars, timer, meter displays match sprite proportions)
- Post-playtest polish (feel improvements from Ackbar verdict)

---

### Sprint 1 Kickoff — Art Phase Planning (2026-03-10)

**Outcome:** Sprint 1 (Art Phase) plan locked and documented. Team ready to replace procedural placeholder art with HD pixel art. Definition of Success framework applied to next sprint.

**What Was Delivered:**
1. **SPRINT-1.md** — Comprehensive 2-week sprint plan covering:
   - Sprint goal: Replace placeholder art with HD pixel art
   - Scope lock: Character sprites (all ~45 states), stage backgrounds, VFX, AnimationPlayer integration
   - Work breakdown: Nien (sprites), Leia (stage), Boba (art direction), Bossk (VFX), Chewie (animation wiring), Ackbar (playtest)
   - M0–M4 milestone gates with clear dependencies
   - Open issues addressed (#91, #50, #55)
   - Out-of-scope items deferred (audio Sprint 3, UI polish Sprint 2)

2. **SPRINT-1-SUCCESS.md** — Definition of Success template filled:
   - Functional criteria: All animation states render, stage progresses, VFX differentiate
   - Technical criteria: M0–M4 gates, integration gate, 60 FPS, asset naming enforced
   - Quality criteria: Silhouette test, Ackbar PASS verdict, no visual glitches
   - Documentation criteria: Art Direction doc, agent histories, now.md, decision documents
   - Ship criteria: All boxes ✅ + Founder approval + Git tag

3. **mace-sprint-1-kickoff.md** — Decision document with:
   - Scope lock rationale (why these boundaries, why not audio, why not UI)
   - Load analysis (140h planned, 96h capacity, 44h over — mitigated via P2 de-scope)
   - Milestone gates M0–M4 with dependencies
   - Risk mitigation (sprite overruns, animation timing, VFX performance, stage clipping)
   - Change control protocol during sprint
   - Communication plan (daily async, blocker escalation, playtest schedule)

4. **now.md updated** — Sprint 1 marked 🔄 IN PROGRESS with M0–M4 gates visible

**Key Decisions Locked:**
1. **Scope is bounded:** P0+P1 animation states are required; P2 (throw/pose) de-scopable if Nien hits capacity. Audio deferred to Sprint 3; UI polish to Sprint 2.
2. **M0 is critical path:** Art direction must be locked Day 1–2 before content creation can start. No content rework due to direction ambiguity.
3. **Parallel execution:** M1 (sprites) + M1b (stage) + M2 (VFX) all parallel after M0. No sequential bottleneck. Chewie starts AnimationPlayer wiring once first batch of sprites available.
4. **Playtest is gate:** Ackbar PASS verdict required to close sprint. PASS WITH NOTES acceptable only if critical follow-ups documented for Sprint 2.
5. **Load cap enforced:** Even though planned work exceeds 20% per agent, parallelization + scope flexibility keeps risk MEDIUM (manageable).

**Process Pattern Applied:**
- Definition of Success framework from Sprint 0 now reused for Sprint 1
- Milestone gates (M0–M4) are explicit deliverables, not vague checkpoints
- Verification checklist prepared upfront (to be filled at sprint end)
- Scope boundaries clarified before work starts (vs. retroactively managing scope creep)
- Risk mitigation strategies documented with clear acceptance criteria

**Why This Matters:**
- **Founder visibility:** Clear scope + Definition of Success + milestone gates = confidence in sprint execution
- **Team clarity:** All 6 agents know exact deliverables, gates, and success criteria before starting
- **Risk management:** Load analysis + dependency graph + mitigation strategies prevent surprises
- **Knowledge capture:** Sprint 1 plan structure can be templated for Sprint 2+ (consistent methodology)

**Comparison to Sprint 0 Planning:**
- Sprint 0: Scope locked via SPRINT-0.md, but Definition of Success created retroactively
- Sprint 1: Scope locked + Definition of Success created upfront (process improvement)
- Both use M0–M4 terminology; Sprint 1 makes gates even more explicit with acceptance criteria per gate
- Both emphasize parallel execution and risk mitigation; Sprint 1 adds load cap governance with explicit de-scope fallback

**Risks Identified & Mitigated:**
1. **Sprite frame count exceeds 45/char:** Mitigated by P2 de-scope (throw/pose moves to Sprint 2)
2. **Animation timing mismatch (hitstun/knockback):** Mitigated by daily sync with Lando frame data + Chewie testing
3. **VFX perf below 60 FPS:** Mitigated by capping particle count + M2 profiling
4. **Stage clips fighters:** Mitigated by boundary testing in M3 integration
5. **Over capacity (140h > 96h):** Mitigated by P2 de-scope (~20h saved) + Leia parallelizing with Nien

**Pattern Learned:**
Scope lock is not about predicting perfect capacity — it's about identifying the critical path and de-scope fallbacks upfront. "If X gets delayed, we de-scope Y" is more valuable than "this won't take long." Explicit de-scope criteria remove last-minute panic.

**What's Next (Sprint 1 Execution):**
- Boba starts M0 art direction immediately (Day 1–2)
- Nien + Leia + Bossk + Chewie parallel execute M1–M3 (Day 3–18)
- Ackbar playtest Day 20; verdict required to close sprint
- Planning resumes for Sprint 2 (UI Phase) once Sprint 1 M4 passes



### Sprint 0 Closure & Definition of Success Framework (2026-03-09)

**Outcome:** Sprint 0 officially closed. Definition of Success framework created and locked for Ashfall + future FFS projects.

**What Was Delivered:**
1. **SPRINT-0-SUCCESS.md** — Retroactive verification of all success criteria (functional, technical, quality, documentation). All boxes checked. 5 PRs merged, M0-M4 gates passed, Ackbar playtest: PASS WITH NOTES.
2. **SPRINT-SUCCESS-TEMPLATE.md** — Reusable template for Sprint 1+ that Mace fills out at sprint start. Sections: functional criteria, technical gates, quality/feel, documentation, ship criteria, verification checklist, verdict, lessons learned.
3. **mace-sprint-structure.md** — Terminology clarification + sprint roadmap locked:
   - **Milestone Gates (M0-M4):** Checkpoints within a sprint
   - **Sprints (0, 1, 2...):** Major work phases (Foundation → Art → UI → Audio → Polish)
   - Each sprint has its own Definition of Success template
4. **now.md updated** — Shows Sprint 0 ✅ SHIPPED; Sprint 1 (Art Phase) planning next
5. **Git tag:** `sprint-0-shipped` created and pushed

**Key Decisions Locked:**
- Sprints are **content phases**, not time-boxes. Sprint duration varies (Sprint 0 was 1 week; Sprint 1 TBD)
- M0-M4 gates are **validation checkpoints** (design approved, code runs, features work, shipped, documented)
- Definition of Success is filled out at **sprint start** (not retroactively). Template guides what to measure.
- Ship criteria = all milestones passed + playtested + 0 P0 bugs + docs current

**Process Improvements for Sprint 1:**
1. Fill Definition of Success template on **Day 1** of sprint, not after
2. Milestone gates become explicit deliverables in sprint kickoff
3. Playtester (Ackbar) assigned to sprint start; playtest date scheduled at kickoff (not ad-hoc)
4. Git tags are part of ship ceremony (not optional)

**Why This Matters:**
- **Founder visibility:** Clear Definition of Success = clear ship criteria = confidence in "ready to show stakeholders"
- **Team clarity:** Template is reusable; no confusion about what success looks like next sprint
- **Knowledge capture:** Each sprint's definition + lessons → improves next sprint's planning
- **Release readiness:** M4 gate is NOT arbitrary; it's the sprint-defined ship criteria

**Comparison to Sprint 0 Planning:**
- Sprint 0 Plan (SPRINT-0.md) defined scope + phases
- Sprint 0 Definition of Success (new) defines *measurable* shipping criteria
- Sprint 0 Success Template (new) is a framework for all future sprints
- These 3 docs together = complete sprint execution + closure

**Risk Eliminated:**
- No more "is this sprint done?" ambiguity
- No more "what should we measure?" mid-sprint confusion
- No more "why did we ship this?" founder questions

---

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
