# Ceremonies

> Team meetings that happen before or after work. Each squad configures their own.

## Design Review

| Field | Value |
|-------|-------|
| **Trigger** | auto |
| **When** | before |
| **Condition** | multi-agent task involving 2+ agents modifying shared systems |
| **Facilitator** | lead |
| **Participants** | all-relevant |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**Agenda:**
1. Review the task and requirements
2. Agree on interfaces and contracts between components
3. Identify risks and edge cases
4. Assign action items

---

## Retrospective

| Field | Value |
|-------|-------|
| **Trigger** | auto |
| **When** | after |
| **Condition** | build failure, test failure, or reviewer rejection |
| **Facilitator** | lead |
| **Participants** | all-involved |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**Agenda:**
1. What happened? (facts only)
2. Root cause analysis
3. What should change?
4. Action items for next iteration

---

## Integration Gate

| Field | Value |
|-------|-------|
| **Trigger** | auto |
| **When** | after |
| **Condition** | parallel agent wave completes (2+ PRs merged from same wave) |
| **Facilitator** | Solo (Architect) |
| **Participants** | Solo |
| **Time budget** | focused |
| **Enabled** | ❌ no |

**Purpose:** After every parallel work wave, verify that systems connect before the next wave starts. This is a hard gate — no new feature work begins until integration is verified.

**Checklist:**
1. Pull latest main
2. Open the project in a browser — verify it loads without errors
3. Check browser console for module import errors, broken references, missing dependencies
4. Verify all modules initialize in correct dependency order
5. Verify event listeners are connected (defined ≠ connected)
6. Run through the primary game flow (page load → game init → core loop → state transitions)
7. Confirm cross-system wiring: animations trigger on events, audio plays on state changes, UI updates on game state changes
8. Document any integration failures as blocking issues before next wave starts

**Root cause (M1+M2):** 5 blockers reached code review because nobody verified systems worked together after parallel waves. Key managers were never instantiated, events were never wired, and the game couldn't run — but no ceremony existed to catch this.

---

## Spec Validation

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | before |
| **Condition** | any PR that implements a GDD-specified system (combat, input, UI, game flow) |
| **Facilitator** | Jango (Tool Engineer / PR Reviewer) |
| **Participants** | PR author + Jango |
| **Time budget** | focused |
| **Enabled** | ❌ no |

**Purpose:** Before merging any implementation PR, verify that the code matches the GDD specification. Catch spec drift at review time, not after milestone completion.

**Checklist:**
1. Identify the GDD section(s) relevant to this PR
2. Compare implementation against GDD requirements (button count, feature list, behavior spec)
3. Flag any deviations — even deliberate ones must be documented as decisions
4. If deviation is intentional, author must add a decision file to `.squad/decisions/inbox/` explaining why
5. If deviation is unintentional, PR is blocked until implementation matches spec or GDD is updated

**Root cause (M1+M2):** GDD specified 6-button layout (LP/MP/HP/LK/MK/HK) but only 4 buttons were implemented. Nobody compared the implementation against the GDD before merging. The deviation compounded silently across movesets, frame data, and combo routes.

---



## Sprint Planning

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | before |
| **Condition** | start of new sprint |
| **Facilitator** | Mace (Producer) |
| **Participants** | Mace + Solo |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**Purpose:** At the start of each sprint, the team aligns on scope, priorities, and assignments. Mace facilitates, Solo defines architecture constraints and provides technical guidance.

**Agenda:**
1. Review backlog — what issues are open, what's the priority order?
2. Define sprint scope — what ships this sprint?
3. Assign work to agents via `squad:{member}` labels
4. Identify dependencies and blockers
5. Set sprint milestone and deadline

---

## Art Review

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | after |
| **Condition** | art/sprite PRs merged or new visual assets integrated |
| **Facilitator** | — |
| **Participants** | — |
| **Time budget** | focused |
| **Enabled** | ❌ no (agents hibernated) |

**Purpose:** After visual asset integration, verify consistency across characters, animations, and environments. Catch style drift before it compounds.

**Note:** This ceremony is currently disabled as the relevant art agents (Boba, Nien) are hibernated.

**Checklist:**
1. Compare new visual assets against art style reference
2. Verify color palette consistency
3. Check animation frame counts and timing feel right
4. Verify asset positioning and scale relative to game viewport
5. Document any visual inconsistencies as issues

---

## Mandatory Project Ceremonies

Certain ceremonies are **required** at specific project milestones, regardless of repo type or team composition.

| Milestone | Ceremony | Content |
|-----------|----------|---------|
| **Project START** | Kickoff Review | Team assignment, skills assessment, architecture plan, upstream relationship verification. **G4:** Review quality-gates.md for current stack relevance. Update if the project uses a different stack than the gates were written for. |
| **Project MIDPOINT** | Mid-Project Health Check | Skills assessment, team member evaluation, course correction, hub alignment check |
| **Project END** | Closeout & Harvest | Final team member evaluation, skill harvest, lessons learned, hub skill promotion. **G6:** Clean up ceremonies.md — disable project-specific ceremonies that no longer apply. **G14:** Verify squad.config.ts has the correct project name (not a leftover from a previous project). |

**Skills Assessment:** At each mandatory ceremony, every active agent's skills are evaluated against the project's needs. Gaps are identified and addressed (training, reassignment, or skill creation).

**Team Member Evaluation:** Performance, collaboration quality, and growth trajectory are reviewed. Results inform future team composition decisions.
