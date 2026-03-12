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
2. Open the project in Godot — verify it loads without errors
3. Check Output console for null references, missing autoloads, broken scene references
4. Verify all autoloads initialize in correct dependency order
5. Verify EventBus signals are connected (defined ≠ connected)
6. Run through the primary game flow (menu → select → fight → KO → victory)
7. Confirm cross-system wiring: VFX triggers on hit, audio plays on events, HUD updates on state changes
8. Document any integration failures as blocking issues before next wave starts

**Root cause (M1+M2):** 5 blockers reached code review because nobody verified systems worked together after parallel waves. RoundManager was never instantiated, signals were never wired, and the game couldn't run — but no ceremony existed to catch this.

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

## Godot Smoke Test

| Field | Value |
|-------|-------|
| **Trigger** | auto |
| **When** | after |
| **Condition** | milestone declared complete (all milestone PRs merged) |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo |
| **Time budget** | focused |
| **Enabled** | ❌ no |

**Purpose:** After merging a milestone, verify the project opens in Godot and the basic game flow works end-to-end. A milestone is NOT complete until this passes.

**Checklist:**
1. `git checkout main && git pull` — clean working tree
2. Open project in Godot 4.x — no import errors, no missing autoloads
3. Press Play — main scene loads without crash
4. Navigate: Main Menu → Character Select → Fight Scene
5. Verify: both fighters spawn, HUD displays, timer counts, input works
6. Land a hit — verify VFX sparks, audio plays, health bar updates
7. Complete a round — verify KO sequence, round transition, score update
8. Complete a match — verify victory screen, rematch/menu navigation
9. Document any failures as P0 blocking issues

**Root cause (M1+M2):** Nobody opened Godot after merging 8 PRs across two milestones. The project was never verified to load or run. Integration failures were invisible until Jango's pre-M3 code review found 5 blockers that prevented the game from running at all.

---

## Sprint Planning

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | before |
| **Condition** | start of new sprint |
| **Facilitator** | Mace (Producer) |
| **Participants** | Mace + Yoda + Solo |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**Purpose:** At the start of each sprint, the team aligns on scope, priorities, and assignments. Mace facilitates, Yoda provides game design perspective, Solo defines architecture constraints.

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
| **Facilitator** | Boba (Art Director) |
| **Participants** | Boba + Nien |
| **Time budget** | focused |
| **Enabled** | ❌ no |

**Purpose:** After visual asset integration, verify consistency across characters, animations, and environments. Catch style drift before it compounds.

**Checklist:**
1. Compare new sprites against art style reference (cel-shade spec, proportions)
2. Verify color palette consistency across characters
3. Check animation frame counts and timing feel right
4. Verify sprite positioning and scale relative to game viewport
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
