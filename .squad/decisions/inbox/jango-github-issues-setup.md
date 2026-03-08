# Decision: GitHub Issues Infrastructure for Ashfall Sprint 0

**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-24  
**Status:** Implemented  
**Scope:** Ashfall project tracking — affects all agents

## What Was Done

Set up GitHub Issues as the project management backbone for Ashfall Sprint 0 in `jperezdelreal/FirstFrameStudios`:

1. **Milestone:** "Ashfall Sprint 0" — groups all sprint work under one trackable milestone
2. **24 Labels** — structured labeling system for filtering and assignment:
   - `game:ashfall` — per-game filter (supports monorepo with multiple games)
   - `priority:p0/p1/p2` — priority tiers mapped to critical path
   - `type:feature/infrastructure/art/audio/design/qa` — work categories
   - `squad:{agent}` — one label per agent (14 agents) for ownership tracking
3. **13 Issues (#1–#13)** — critical path tasks from SPRINT-0.md with full descriptions and acceptance criteria

## Label Conventions

| Category | Color | Purpose |
|----------|-------|---------|
| `game:*` | Green (#0E8A16) | Filter by game in monorepo |
| `priority:p0` | Red (#B60205) | Critical path — blocks others |
| `priority:p1` | Orange (#D93F0B) | Sprint deliverable |
| `priority:p2` | Yellow (#FBCA04) | Nice-to-have / future phase |
| `type:*` | Blue/Purple/Pink | Work category |
| `squad:*` | Teal (#006B75) | Agent assignment |

## Issue Mapping

| # | Title | Agent | Priority |
|---|-------|-------|----------|
| 1 | Godot project scaffold | Jango | P0 |
| 2 | Fighter state machine base | Chewie | P0 |
| 3 | Fighter controller + input buffer | Lando | P0 |
| 4 | Hitbox/hurtbox collision system | Chewie | P0 |
| 5 | HUD — health bars, round counter | Wedge | P0 |
| 6 | Round manager system | Chewie | P0 |
| 7 | Basic AI opponent | Tarkin | P1 |
| 8 | Stage scene setup | Leia | P1 |
| 9 | Character sprite placeholders | Nien | P1 |
| 10 | Hit VFX | Bossk | P2 |
| 11 | Sound effects | Greedo | P2 |
| 12 | Main menu + character select | Wedge | P2 |
| 13 | Playtesting protocol | Ackbar | P1 |

## Why This Matters

- **Every agent can filter by their squad label** to see exactly what's assigned to them
- **Milestone view** shows sprint progress at a glance
- **Acceptance criteria checkboxes** let agents self-validate completion
- **`game:ashfall` label** future-proofs for when we add more games to the monorepo
- **Priority labels** map directly to the critical path from SPRINT-0.md

## Impact on Team

- All agents should reference their issue number when committing code (e.g., `fixes #2`)
- Mace can use the milestone view for sprint tracking
- Close issues when acceptance criteria are met
- Future sprints follow the same label structure
