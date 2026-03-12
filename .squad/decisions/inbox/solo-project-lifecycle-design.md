# Decision: Standard Project Lifecycle (Final)

**By:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-12  
**Status:** ✅ Implemented — T1 authority, Founder-authorized  
**Tier:** T1 (Lead authority — ceremony/process design)  
**Supersedes:** Issue #190 (backlog grooming ceremony), previous 400-line draft

---

## Self-Review

The Founder reviewed my initial 400-line design and said: "Solo should review his own document and make the decisions HE considers best." He was right — I over-engineered it.

**What I cut and why:**

| Original (400 lines) | Final (~120 lines) | Why |
|---|---|---|
| 4 ceremonies (Kickoff, Sprint Planning N, Mid-Project Eval, Closeout) | **2 ceremonies** (Sprint Planning, Closeout) | Kickoff is just first Sprint Planning. Mid-Project Eval is a health check that happens at every sprint boundary. Separate ceremonies are bureaucracy. |
| `project-state.json` with 5 fields | **3 fields** (`phase`, `sprint`, `design_doc`) | `total_sprints_planned` and `sprints_completed` are over-tracking. |
| Ralph detection rules + `Check-ProjectLifecycle` function design | **Noted, not designed here** | Ralph integration is implementation, not architecture. Tracked separately. |
| Bug fix designs (squad-triage.yml + ralph-watch.ps1) | **Extracted to separate issues** | Real bugs, but orthogonal to ceremony design. Mixing them inflated the doc. |
| 7-day closeout timer | **Event-driven closeout** | Fixed timers create noise. Re-evaluate on meaningful events. |

---

## Final Design

### Two Lifecycle Ceremonies

1. **Sprint Planning** — One ceremony that adapts by context. First sprint = kickoff (read full design doc, create roadmap). Subsequent sprints = review + plan next batch. Always produces labeled GitHub issues as output. Health check built into every sprint boundary.

2. **Closeout** — For shipped/mature projects. Evaluate live project against design doc, create improvement issues. Re-triggered by meaningful events, not a timer. Archived when founder closes the roadmap issue.

### State Tracking

```json
{
  "phase": "sprinting",
  "sprint": 2,
  "design_doc": "docs/GDD.md"
}
```

Three fields. Machine-readable by Ralph. Template at `.squad/templates/project-state.json`.

### Lifecycle Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Sprints: calendar or issue-based? | **Issue-based.** | Calendar sprints are overhead for a studio this size. |
| Closeout re-eval: 7-day timer? | **No. Event-driven.** | Timers create noise when there's nothing to improve. |
| Hub lifecycle? | **No. Permanent maintenance.** | Hub is infrastructure, not a project. |
| Archive signal? | **Close the roadmap issue.** | Simplest native GitHub action. |

### Hub Exception

The Hub repo does NOT use this lifecycle. Hub improvements flow from downstream needs.

---

## Core Principle

**Every ceremony produces GitHub issues.** A ceremony that only produces `.md` files is incomplete. The `.md` is the analysis; the issues are the work.

---

## Implementation

- `.squad/ceremonies.md` — Updated with lifecycle ceremonies section
- `.squad/templates/project-state.json` — Template for new repos
- `.squad/identity/now.md` — Updated to reflect lifecycle system
- Issue #190 — Closed, superseded by this design

---

*A simpler system is a system people actually use. The previous 400-line draft was thorough but would have been ignored. Two ceremonies and three JSON fields close the "pipeline dries up" gap without drowning the studio in process.*
