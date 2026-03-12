# Decision: Standard Project Lifecycle with Issue Generation

**By:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-12  
**Status:** Proposed — awaiting Founder approval  
**Tier:** T1 (Lead authority — ceremony/process design)  
**Supersedes:** Issue #190 (backlog grooming ceremony)

---

## Problem Statement

FFS ceremonies are **introspective but not productive**. They generate `.md` documentation (GDDs, skill assessments, lessons learned) but never create GitHub issues. This means the work pipeline dries up: Ralph has nothing to consume because nobody is converting design docs into executable work items.

Additionally, two bugs compound the problem:
1. **`squad-triage.yml` line 207** blindly applies `go:needs-research` to every new issue regardless of content — even issues that are already well-specified and ready for implementation.
2. **`ralph-watch.ps1` line 686** treats `go:needs-research` as a hard skip — issues with that label are permanently invisible to Ralph. Combined with bug #1, this means *every triaged issue* gets stuck in limbo.

The result: even when issues exist, the triage→execution pipeline is broken.

---

## Design: Standard Project Lifecycle

### Core Principle

**Every ceremony MUST produce GitHub issues as its primary output.** A ceremony that only produces `.md` files is incomplete. The `.md` is the analysis; the issues are the work.

### Terminology

- **Design doc**: The project's source of truth for what to build. Could be a GDD (`docs/GDD.md`) for games, a PRD (`docs/PRD.md`) for tools, or a spec (`docs/SPEC.md`) for infrastructure. The lifecycle doesn't care which — it reads whatever the repo's design doc is.
- **Sprint**: A batch of issues that represent one increment of progress. Sprints end when their issues are closed, not on a calendar date.
- **Lifecycle state**: Which phase the project is in (kickoff → sprinting → evaluation → closeout).

### Lifecycle State Machine

```
                    ┌────────────────────────────────────┐
                    │                                    │
                    ▼                                    │
    ┌──────────┐   ┌───────────────┐   ┌────────────┐  │
    │ KICKOFF  │──▶│ SPRINT PLAN N │──▶│  SPRINTING  │──┘
    └──────────┘   └───────────────┘   └─────┬──────┘
                          ▲                  │
                          │    sprint done    │
                          │                  ▼
                          │          ┌──────────────┐
                          └──────────│ MID-PROJECT  │
                          more       │  EVALUATION  │
                          sprints    └──────┬───────┘
                                            │
                                      mature / founder says done
                                            │
                                            ▼
                                    ┌──────────────┐
                                    │   CLOSEOUT   │◀─┐
                                    │  (cont. imp) │──┘
                                    └──────────────┘
                                     evaluate → issues → resolve → loop
```

### State Tracking

Each repo tracks its lifecycle state via a **label on its milestone** or a simple file:

```
.squad/project-state.json
{
  "lifecycle": "sprinting",       // kickoff | sprint-planning | sprinting | evaluating | closeout
  "current_sprint": 2,
  "total_sprints_planned": 4,
  "design_doc": "docs/GDD.md",   // path to the repo's design doc
  "sprints_completed": [1]
}
```

This file is machine-readable by Ralph and the scheduler.

---

## Ceremony Definitions

### 1. Kickoff

| Field | Value |
|-------|-------|
| **Trigger** | Auto: new repo created with `.squad/` structure, OR manual founder directive |
| **Condition** | `project-state.json` does not exist or `lifecycle == null` |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo + Yoda (Game Designer, if game) |
| **Time budget** | Focused |
| **Enabled** | ✅ yes |

**Inputs:**
- Design doc (`docs/GDD.md`, `docs/PRD.md`, or `docs/SPEC.md`)
- Team roster (`.squad/team.md`)

**Process:**
1. Read the design doc end-to-end
2. Decompose the project into 3-6 sprints (each sprint = one shippable increment)
3. For each sprint, define scope in 1-2 sentences
4. Create `project-state.json` with lifecycle = `sprint-planning`, sprint count, design doc path

**Outputs (ALL are GitHub issues):**
- **1 roadmap issue** titled `[ROADMAP] {Project Name} Sprint Plan` with a table of sprints, their scope, and rough ordering
- **1 trigger issue** titled `[CEREMONY] Sprint Planning — Sprint 1` with label `ceremony:sprint-planning` — this kicks off the first sprint planning

**State transition:** `null → sprint-planning`

---

### 2. Sprint Planning (N)

| Field | Value |
|-------|-------|
| **Trigger** | Auto: `ceremony:sprint-planning` issue exists AND is open |
| **Condition** | `lifecycle == sprint-planning` in `project-state.json` |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo |
| **Time budget** | Focused |
| **Enabled** | ✅ yes |

**Inputs:**
- Design doc
- Roadmap issue (for sprint scope reference)
- All open issues in the repo (to avoid duplicates)

**Process:**
1. Read the design doc sections relevant to this sprint's scope
2. Compare against existing open issues — identify gaps
3. For every untracked feature, task, or improvement: create a GitHub issue with:
   - Clear title and acceptance criteria
   - Labels: `squad`, `squad:{assigned-member}`, `priority:p{0-3}`, `type:{feature|bug|task|spike}`
   - Sprint milestone label: `sprint:N`
4. Define sprint success criteria (what "done" means for this sprint)
5. Close the `[CEREMONY] Sprint Planning — Sprint N` trigger issue

**Outputs (ALL are GitHub issues):**
- **N implementation issues** (the actual sprint backlog) — each properly labeled and assigned
- **1 sprint success criteria issue** titled `[SPRINT N] Success Criteria` listing what must be true for the sprint to be considered done
- Issues get `go:ready` label (not `go:needs-research`) because they were created from the design doc with full context

**State transition:** `sprint-planning → sprinting`, update `current_sprint` in `project-state.json`

---

### 3. Mid-Project Evaluation

| Field | Value |
|-------|-------|
| **Trigger** | Auto: all issues for current sprint are closed (sprint complete), AND `sprints_completed >= total_sprints_planned / 2` |
| **Condition** | `lifecycle == sprinting` AND midpoint reached |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo + Mace (Producer) |
| **Time budget** | Focused |
| **Enabled** | ✅ yes |

**Inputs:**
- Design doc
- All closed issues (what was accomplished)
- All open issues (what remains)
- Project state

**Process:**
1. **Functional evaluation:** Does what's built match the design doc intent? Are there gaps?
2. **Technical evaluation:** Architecture health, tech debt accumulated, performance concerns
3. **Scope evaluation:** Is the remaining design doc achievable in remaining sprints? Need to add/remove sprints?
4. **Decision point:**
   - More sprints needed → create `[CEREMONY] Sprint Planning — Sprint N+1` issue, state stays `sprint-planning`
   - Project is mature / founder says done → transition to closeout

**Outputs (ALL are GitHub issues):**
- **Course correction issues** (if any): scope changes, tech debt items, architecture fixes
- **1 evaluation summary issue** titled `[EVAL] Mid-Project Evaluation — {date}` documenting the decision
- **Either:** a new `[CEREMONY] Sprint Planning — Sprint N+1` trigger issue **OR** a `[CEREMONY] Closeout` trigger issue

**State transition:** `sprinting → sprint-planning` (more work) or `sprinting → closeout`

---

### 4. Closeout (Continuous Improvement Loop)

| Field | Value |
|-------|-------|
| **Trigger** | Auto: `ceremony:closeout` issue exists AND is open |
| **Condition** | `lifecycle == closeout` in `project-state.json` |
| **Facilitator** | Solo (Lead) |
| **Participants** | Solo + Yoda |
| **Time budget** | Focused |
| **Enabled** | ✅ yes |

**Inputs:**
- Design doc
- Current state of the live project
- User feedback (if any)
- Open issues

**Process:**
1. Evaluate the project against its design doc — what's missing, what could be better?
2. Identify improvement opportunities (polish, performance, accessibility, new features)
3. Create improvement issues
4. When those issues are resolved, re-evaluate — create more if needed
5. This loops indefinitely until the founder archives the project

**Outputs (ALL are GitHub issues):**
- **Improvement issues** with proper labels, assigned to appropriate agents
- **1 evaluation issue** titled `[CLOSEOUT] Improvement Cycle — {date}` documenting what was evaluated and what issues were created

**State transition:** `closeout → closeout` (loops). Only exits via founder archive decision.

---

## How Ralph Detects Transitions

Ralph already polls repos for issues. The lifecycle adds **machine-readable signals** Ralph can check:

### Detection Rules (for ralph-watch.ps1)

| Signal | What Ralph Does |
|--------|----------------|
| `project-state.json` has `lifecycle: "sprint-planning"` AND an open issue with label `ceremony:sprint-planning` | Trigger Sprint Planning session — Solo reads design doc, creates issues |
| `project-state.json` has `lifecycle: "sprinting"` AND all `sprint:N` issues are closed | Sprint is done. Check if mid-project eval is due. If yes, trigger Mid-Project Evaluation. If not, auto-create next `[CEREMONY] Sprint Planning — Sprint N+1` issue. |
| `project-state.json` has `lifecycle: "closeout"` AND open issue with label `ceremony:closeout` | Trigger Closeout evaluation session |
| `project-state.json` has `lifecycle: "closeout"` AND no open issues with `ceremony:*` labels AND last closeout eval was >7 days ago | Auto-create new `[CEREMONY] Closeout — Improvement Cycle` issue |

### Implementation in ralph-watch.ps1

Add a new function `Check-ProjectLifecycle` that runs before the issue scan loop:

```powershell
function Check-ProjectLifecycle {
    param($repo, $owner)
    # 1. Fetch .squad/project-state.json from the repo
    # 2. Read lifecycle state
    # 3. Check transition conditions (sprint issues all closed, etc.)
    # 4. If transition detected, create the appropriate ceremony trigger issue
    # 5. Log the transition
}
```

This keeps lifecycle detection **inside Ralph's existing loop**, not as a separate scheduler task.

---

## Bug Fixes Required

### Bug 1: `squad-triage.yml` — Blind `go:needs-research` Label (Line 207)

**Current behavior:** Every issue that gets the `squad` label automatically receives `go:needs-research`, regardless of content.

**Problem:** Well-specified issues (with acceptance criteria, clear scope, proper labels) don't need research. Issues created by Sprint Planning ceremonies are already fully specified from the design doc.

**Fix design:**

Replace the unconditional label application (lines 202-208) with content-aware triage:

```javascript
// Evaluate issue readiness instead of blindly labeling
const hasAcceptanceCriteria = issue.body && (
  issue.body.includes('acceptance criteria') ||
  issue.body.includes('## Criteria') ||
  issue.body.includes('- [ ]')  // has checklist
);
const hasCeremonyOrigin = issue.labels?.some(l => 
  l.name?.startsWith('ceremony:') || l.name === 'sprint-generated'
);
const isWellSpecified = hasAcceptanceCriteria || hasCeremonyOrigin;

const triageVerdict = isWellSpecified ? 'go:ready' : 'go:needs-research';

await github.rest.issues.addLabels({
  owner: context.repo.owner,
  repo: context.repo.repo,
  issue_number: issue.number,
  labels: [triageVerdict]
});
```

**Key change:** Issues with acceptance criteria or ceremony-origin labels get `go:ready`. Only vague issues get `go:needs-research`.

### Bug 2: `ralph-watch.ps1` — Hard Skip on `go:needs-research` (Line 686)

**Current behavior:** `go:needs-research` causes Ralph to skip the issue entirely with a `continue` statement. The issue sits forever unless someone manually removes the label.

**Problem:** Research IS work. An agent should be routed to investigate the issue, add findings, and then flip the label to `go:ready`.

**Fix design:**

Replace the hard skip (lines 685-689) with a research-routing behavior:

```powershell
# Instead of skipping, route to assigned agent for research
if ($labelNames -contains "go:needs-research") {
    # Find the squad:{member} label to identify who should research
    $researcher = $labelNames | Where-Object { $_ -match '^squad:' } | Select-Object -First 1
    if ($researcher) {
        Write-Host "      [research] Routing #$($issue.number) to $researcher for investigation" -ForegroundColor Cyan
        # Add to research queue instead of skipping
        # The session prompt tells the agent: "Research this issue, add findings as a comment,
        # then replace go:needs-research with go:ready if actionable, or close if not."
        $researchQueue += @{
            Issue = $issue
            Agent = $researcher
            Type = "research"
        }
    } else {
        Write-Host "      [research] #$($issue.number) needs research but has no squad assignment — skipping" -ForegroundColor DarkYellow
    }
    continue  # Don't process as normal work — it goes to the research queue
}
```

**Key change:** `go:needs-research` issues get routed to their assigned agent with a research-specific prompt. The agent investigates and either promotes the issue to `go:ready` or closes it as invalid.

---

## How This Closes Issue #190

Issue #190 asks for "backlog grooming ceremony for all repos." This lifecycle design **supersedes** #190 by solving the problem at a deeper level:

| #190 Asked For | This Design Provides |
|----------------|---------------------|
| Lead reads GDD and creates issues | Sprint Planning ceremony — Lead reads design doc, creates all sprint issues |
| Trigger when backlog < N issues | Ralph detects sprint completion (all sprint:N issues closed) and triggers next planning |
| Duplicate prevention | Sprint Planning checks existing open issues before creating new ones |
| Proper labels on generated issues | Ceremony output spec requires squad, priority, type, and sprint labels |
| Works for non-GDD repos | Design doc abstraction — GDD, PRD, or SPEC, lifecycle is the same |

**Recommendation:** Close #190 with a comment pointing to this decision document once approved.

---

## Files That Need Changes

This section documents WHAT needs to change but does NOT make the changes.

### 1. `.squad/ceremonies.md`
- **Replace** the current "Mandatory Project Ceremonies" section (lines 148-160) with the four lifecycle ceremonies defined above
- **Update** existing Sprint Planning ceremony (lines 100-120) to match the new Sprint Planning N definition
- **Add** ceremony trigger labels to the ceremonies table format
- **Disable** or remove Art Review (dead ceremony, agents hibernated)

### 2. `.github/workflows/squad-triage.yml`
- **Lines 202-208:** Replace unconditional `go:needs-research` with content-aware triage verdict (see Bug Fix #1 above)
- **Also update** `.squad/templates/workflows/squad-triage.yml` (the template copy)

### 3. `tools/ralph-watch.ps1`
- **Lines 685-689:** Replace hard skip with research-routing behavior (see Bug Fix #2 above)
- **Add** `Check-ProjectLifecycle` function for lifecycle state detection and ceremony triggering
- **Add** research queue processing alongside the existing work queue

### 4. `tools/scheduler/schedule.json`
- **Remove or disable** `backlog-grooming` task (replaced by Sprint Planning ceremony)
- **Consider adding** a lifecycle-check heartbeat task that ensures `project-state.json` is consistent

### 5. `.squad/templates/` (new)
- **Create** `.squad/templates/project-state.json` — template for new repos
- **Create** or update ceremony trigger issue templates

### 6. Per-repo files (downstream)
- Each active repo (ComeRosquillas, Flora, ffs-squad-monitor) needs:
  - `project-state.json` created with current lifecycle state
  - Design doc path confirmed (GDD.md, PRD.md, etc.)

---

## Universality: Same Lifecycle, Any Repo

| Repo | Type | Design Doc | Lifecycle | Notes |
|------|------|-----------|-----------|-------|
| ComeRosquillas | Game | `docs/GDD.md` | Full lifecycle | Currently active, would enter sprint-planning |
| Flora | Game | `docs/GDD.md` | Full lifecycle | Currently planned, would start at kickoff |
| ffs-squad-monitor | Tool | `docs/PRD.md` | Full lifecycle | Currently scaffold, would start at kickoff |
| FirstFrameStudios (Hub) | Infra | `docs/SPEC.md` or none | Closeout only | Hub is operational, continuous improvement mode |

The lifecycle is **identical** regardless of repo type. Only the design doc format changes.

---

## Implementation Priority

1. **P0:** Fix the two bugs (triage + ralph-watch) — the pipeline is broken without these
2. **P1:** Add `project-state.json` template and Sprint Planning ceremony definition
3. **P1:** Update `ceremonies.md` with the four lifecycle ceremonies
4. **P2:** Add `Check-ProjectLifecycle` to ralph-watch
5. **P2:** Create `project-state.json` in each active repo and run first Kickoff
6. **P3:** Remove stale scheduler tasks, clean up old ceremony definitions

---

## Open Questions for Founder

1. **Sprint duration flexibility:** Design says sprints end when issues close, not on calendar. Confirm this is the intent (vs. time-boxed sprints).
2. **Closeout loop frequency:** 7-day re-evaluation cycle for closeout repos — too frequent? Too slow?
3. **Hub lifecycle:** Should the Hub repo use this lifecycle or remain in permanent closeout/maintenance mode?
4. **Founder archive signal:** How does the founder signal "this project is done, stop the closeout loop"? Suggestion: a label `lifecycle:archived` or closing the roadmap issue.

---

*This decision was designed to give FFS repos "vida propia" — self-sustaining work pipelines where ceremonies generate the backlog that Ralph consumes. The loop closes: design doc → ceremonies → issues → Ralph → sessions → work done → ceremony re-evaluates → more issues.*
