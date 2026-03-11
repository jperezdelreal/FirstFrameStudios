# Decision: ralph-watch v3 Night/Day Mode Scheduling

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #167
**PR:** #169
**Status:** Pending Review

## Context

ralph-watch.ps1 ran a single copilot session per round at a fixed 15-minute interval regardless of time of day. Nights and weekends were wasted capacity; daytime sessions competed with the user's VS Code.

## Decision

Implement automatic night/day mode scheduling:

- **Night mode** (weeknights 21:00-07:00, weekends 24h): 2 parallel Start-Job copilot sessions, 5 issues/session, 2-minute intervals. Each session scoped to exactly 1 repo.
- **Day mode** (weekdays 07:00-21:00): 1 session, 3 issues/round, 10-minute intervals.
- **Auto-detect** via system clock (Get-Date). Manual override via -Mode param.

### Governance Filter
- T0: skip (founder approval required)
- T1: skip unless labeled "approved"
- T2/T3: auto-assign

### Scheduling Algorithm
1. Sort by priority label (P0 > P1 > P2 > P3)
2. Then by repo open issue count (busiest repo first)
3. Then game repos over hub (more user-facing work)

## Rationale

- Nights/weekends have no user competition -- maximize throughput
- 1 session per repo prevents cross-repo prompt confusion
- Governance filter prevents autonomous agents from touching high-stakes work
- Priority scheduling ensures critical issues get worked first

## Alternatives Considered

1. **Fixed schedule table** -- Rejected; clock-based auto-detection is simpler and self-maintaining
2. **Single session with larger issue count at night** -- Rejected; parallel sessions reduce round time by ~50%
3. **No governance filter** -- Rejected; T0/T1 issues need human judgment

## Consequences

- Night throughput roughly doubles (2 sessions vs 1)
- Day mode is gentler on system resources and git contention
- Mode transitions are logged, making it auditable
- Start-Job introduces PowerShell job cleanup complexity (mitigated with Wait/Remove patterns)
