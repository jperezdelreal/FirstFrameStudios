# Studio Craft: The Meta-Skills of Game Studio Operation

> **Author:** Yoda (Game Designer) + Solo (Lead / Chief Architect)  
> **Date:** 2025-07  
> **Status:** Active  
> **Confidence:** `low`  
> **Source:** Supergiant, Team Cherry, Sandfall, Larian, ConcernedApe, Nintendo, academic meta-analyses, firstPunch  
> **has_reference:** true

---

## Context

This skill covers *running* the studio, not making games. It captures how we organize, decide, iterate, and compound knowledge across projects — the operating system that makes a studio ship consistently. Every agent should internalize these patterns before their first sprint. See `REFERENCE.md` for full rationale, examples, and implementation details.

---

## Core Patterns

### 1. Creative Vision Management
One Creative Director (Yoda default) acts as a **filter, not bottleneck** — attends cross-domain reviews, asks "does this feel like *this* game?", breaks aesthetic/design ties. Maintains coherence across art, audio, gameplay, and UI.

### 2. Feature Triage — "Kill Your Darlings"
Every feature passes **four tests** before greenlit (fail 2+ → cut immediately):
1. **Core loop** — strengthens or distracts?
2. **Player impact** — would a first-time player miss it?
3. **Cost-to-joy ratio** — dev hours vs. player delight
4. **Coherence** — feels native or bolted on?

Playtests are the final arbiter. Sunk cost is never justification. Cutting is celebrated.

### 3. Playtest-Driven Iteration
Core mechanics require **3+ iteration cycles**: `Build → Playtest → Measure → Revise`. Iteration count correlates with quality. "Feels right on first try" = hasn't been tested hard enough.

### 4. Postmortem Discipline
Mandatory after every milestone (Vertical Slice, Beta, Gold): individual reflection (5 right / 5 wrong, anonymous) → synthesis → documentation → follow-up. Findings stored in agent history and `decisions.md`.

### 5. Developer Joy Metric
1-5 excitement check every retrospective. Scores below 3 trigger a **design review, not a pep talk**. Team excitement is a leading indicator of game quality.

### 6. Decision Rights Matrix
Every decision type has explicit **Decides / Advises / Informed** roles. Key owners: Solo (architecture), Yoda (design), Boba (art), Greedo (audio), Ackbar (quality), Founder+Solo (scope). Prevents invisible hierarchies.

### 7. Scrumban Methodology
- **Pre-production:** Kanban — continuous flow, WIP limit 2/person, weekly playtests
- **Production:** 2-week Scrum sprints — playtest the build as sprint review, score principles in retros
- **Polish:** 1-week bug-fix sprints — P0 only, no new features, Ackbar assesses ship-readiness

### 8. 20% Load Cap
No agent carries >20% of phase backlog items. Exceeding triggers immediate redistribution. Anti-crunch insurance audited by Ralph every sprint.

### 9. Cross-Domain Review
Domain changes affecting other domains require a **5-minute review**: "Does this create work for me? Does this break my assumptions?"

### 10. Portfolio Thinking
Target 2-3 games in 5 years, 12-18 months each. Never bet the studio on one game. Build reusable infrastructure across projects.

### 11. Knowledge Capture
After every milestone: extract reusable modules, document lessons, update skills, tag insights by principle. Scribe owns the process. Skills are living documents.

---

## Key Examples

**Feature triage in action:** A realistic inventory system in a stylized cartoon beat 'em up fails the coherence test even if well-executed — cut it. A health-cost special move passes because it reinforces risk/reward theme — keep it.

**Scrumban phase gate:** Before any mechanic leaves pre-production, it must pass a team playtest. If the team can't articulate why it's fun, it goes back to prototyping ("find the fun" gate).

---

## Anti-Patterns

- **Skipping postmortems** — leads to invisibly repeating the same mistakes across projects
- **Sunk cost reasoning** — "we already spent two weeks on this" is never justification to keep a feature
- **Pure Scrum for creative work** — fixed sprints don't fit prototyping; playtest results invalidate estimates
- **Flat structure without explicit decision rights** — creates invisible hierarchies worse than explicit ones (Valve's cautionary tale)
- **Ignoring low developer excitement** — don't dismiss as mood; fix the design or scope, not the team's attitude
- **Single-game betting** — putting all resources into one project with a 70% industry failure rate
- **Agent overload (>20%)** — top predictor of crunch and burnout; redistribute immediately
