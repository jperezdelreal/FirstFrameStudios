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



## Project Lifecycle Ceremonies

> **Decision:** Solo (Lead), 2026-03-12 — T1 authority. Supersedes issue #190.
>
> **Problem solved:** Ceremonies were introspective but not productive — they generated `.md` files but never created GitHub issues. Ralph starved because no ceremony fed the work pipeline.
>
> **Core rule:** Every lifecycle ceremony MUST produce GitHub issues as its primary output.

### Lifecycle State Machine

```
┌─────────────────┐     ┌────────────┐     ┌────────────┐
│ SPRINT PLANNING │────▶│  SPRINTING  │────▶│  CLOSEOUT   │
└────────┬────────┘     └─────┬──────┘     └─────┬──────┘
         ▲                    │                   │
         └────────────────────┘                   │
          all sprint issues closed                │
          (loops until project ships)       improvement issues
                                            (loops until archived)
```

**States:** `sprint-planning` → `sprinting` → `sprint-planning` (loop) → `closeout` (loop until archived)

**Tracked in:** `.squad/project-state.json` per repo (see template).

### Terminology

- **Design doc** — The project's source of truth. GDD for games, PRD for tools, SPEC for infrastructure. The lifecycle doesn't care which.
- **Sprint** — A batch of issues representing one increment of progress. **Sprints end when their issues are closed, not on a calendar date.**

---

### Sprint Planning

| Field | Value |
|-------|-------|
| **Trigger** | Auto: all `sprint:N` issues closed, OR first run (kickoff) |
| **Condition** | `project-state.json` has `phase: "sprint-planning"` or doesn't exist yet |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**This ceremony replaces Kickoff, Sprint Planning N, and Mid-Project Evaluation.** One ceremony, context-sensitive:

**If first sprint (kickoff):**
1. Read the design doc end-to-end
2. Decompose project into rough sprint count (3–6)
3. Create a `[ROADMAP]` issue with sprint overview
4. Create Sprint 1 implementation issues
5. Create `project-state.json` with `phase: "sprinting"`, `sprint: 1`

**If subsequent sprint:**
1. Review what shipped in the last sprint
2. Evaluate project health: are we on track? scope creep? tech debt?
3. Read design doc sections relevant to next sprint
4. Check existing open issues — avoid duplicates
5. Create implementation issues for Sprint N+1
6. If project is mature or founder says ship → transition to Closeout instead

**Every issue created must have:**
- Clear title and acceptance criteria
- Labels: `squad:{member}`, `priority:p{0-3}`, `sprint:N`
- `go:ready` label (not `go:needs-research` — these are design-doc-derived, fully specified)

**State transition:** `sprint-planning → sprinting`

---

### Closeout

| Field | Value |
|-------|-------|
| **Trigger** | Manual: founder directive, OR Sprint Planning decides project is mature |
| **Condition** | `project-state.json` has `phase: "closeout"` |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**Purpose:** For shipped or mature projects. Evaluate the live project against its design doc and create improvement issues.

**Process:**
1. Evaluate project against design doc — what's missing, what could be better?
2. Check for polish, performance, accessibility, user feedback
3. Create improvement issues (labeled, assigned, `go:ready`)
4. Skill harvest: identify reusable patterns worth promoting to hub skills

**Re-trigger:** On meaningful events — founder directive, user feedback, agent observation during routine work. **Not on a fixed timer.** A 7-day loop creates noise when there's nothing to improve.

**Archive signal:** Founder closes the `[ROADMAP]` issue. That stops the closeout loop. No new labels needed — it's a native GitHub action.

**State transition:** `closeout → closeout` (loops) or → archived (roadmap issue closed)

---

### Hub Exception

The Hub repo (FirstFrameStudios) does **not** use this lifecycle. It's infrastructure, not a project. Hub improvements flow from downstream needs — when a game repo needs something the hub doesn't have. The hub stays in permanent maintenance mode.

---

### Lifecycle Decisions (Solo, T1 Authority)

| Question | Decision | Rationale |
|----------|----------|-----------|
| Sprints end by issues closed or calendar? | **Issues closed.** | Calendar sprints are bureaucracy for a studio this size. Issue completion is the natural unit. |
| Closeout re-eval every 7 days? | **No. Event-driven.** | Fixed timers create noise. Re-evaluate when something meaningful happens. |
| Hub lifecycle? | **No. Maintenance mode.** | Hub is infrastructure, not a project. It doesn't sprint. |
| Archive signal? | **Close the roadmap issue.** | Simplest possible. Native GitHub action, no new labels. |
| Separate Kickoff ceremony? | **No. Merged into Sprint Planning.** | A kickoff is just Sprint Planning with `sprint: 0`. One ceremony, context-sensitive. |
| Separate Mid-Project Evaluation? | **No. Merged into Sprint Planning.** | Health check happens naturally at every sprint boundary. No dedicated ceremony needed. |
