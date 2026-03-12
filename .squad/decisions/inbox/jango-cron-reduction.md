# Decision: Reduce GitHub Actions cron frequency

**Author:** Jango (Tool Engineer)
**Date:** 2025-07-16
**Issue:** #187 — Phase 5a + 5b

## Context

The repo was burning ~4,320 scheduled workflow runs/month across two cron-triggered workflows. GitHub Actions minutes are a shared resource and this volume was excessive for the actual work being done.

## Changes

| Workflow | Before | After | Runs/month |
|---|---|---|---|
| `squad-heartbeat.yml` | `*/15 * * * *` (every 15 min) | `0 * * * *` (every hour) | 2,880 → 720 |
| `squad-notify-ralph-heartbeat.yml` | `*/30 * * * *` (every 30 min) | `0 */4 * * *` (every 4 hours) | 1,440 → 180 |
| **Total** | | | **~4,320 → ~900** |

## Template sync

- `.squad/templates/workflows/squad-heartbeat.yml` — updated commented-out cron to `0 * * * *`
- `templates/workflows/squad-heartbeat.yml` (source) and `packages/squad-cli/templates/...` (CLI) — not present in this repo; no action needed

## Rationale

- Hourly triage is sufficient. Issues rarely need sub-hour response from an automated heartbeat.
- 4-hour notification checks are adequate since Ralph rounds complete infrequently.
- Event triggers (issues closed/labeled, PRs closed) still fire immediately — only the scheduled polling is reduced.

## Risk

Low. The heartbeat still runs hourly, and all event-driven triggers remain unchanged. If faster polling is needed later, the cron can be tightened back.
