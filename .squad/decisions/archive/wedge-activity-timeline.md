# Decision: Swim-Lane Timeline Pattern for Agent Monitoring

**Author:** Wedge (UI/UX Developer)
**Date:** 2025-07-25
**Scope:** ffs-squad-monitor — timeline visualization

## Decision

The agent activity timeline uses a **swim-lane layout** (horizontal bars per agent) rather than the previous dot grid. Each round is a proportionally-sized bar, color-coded by outcome (green=success, red=error), clickable to expand a detail panel with full round metadata.

## Rationale

- Swim lanes scale naturally from 1 agent to N agents — no redesign needed when monitoring expands
- Bar width encodes duration visually, making long-running rounds immediately visible
- Click-to-expand detail panel avoids page navigation while showing full round context (metrics, exit codes, consecutive failures)
- The `/api/timeline` endpoint is separate from `/api/logs` to keep response shapes optimized for each view

## Impact

- Frontend components that reference the old `.timeline-track` / `.timeline-dot` classes no longer exist — use `.swim-lane` / `.swim-bar` instead
- The timeline now fetches from `/api/timeline` rather than `/api/logs`
- Detail panel uses DOM expando properties (`_roundData`) for click data — keep this pattern for similar expandable UI
