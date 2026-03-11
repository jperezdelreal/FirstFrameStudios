# Decision: GitHub Actions Status Integration Pattern

**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Scope:** ffs-squad-monitor

## Decision

GitHub Actions workflow status is fetched using the `gh run list` CLI command with a 2-minute server-side cache. Results are served at `/api/workflows` and polled every 60s by the frontend.

## Rationale

- **`gh` CLI over raw GitHub REST API**: The CLI is already authenticated on dev machines — no token management, no env vars. Same proven pattern as `getOpenIssueCount()`.
- **2-minute cache TTL**: Workflow runs don't change every second. Caching reduces CLI invocations from 4/minute to 4 every 2 minutes, staying well within rate limits.
- **Per-repo error isolation**: One repo failing (e.g., permissions) doesn't break the entire endpoint — other repos still return data.

## Impact

- New API endpoint: `/api/workflows`
- New frontend component: `src/components/workflows.js`
- New scheduler task: `workflows` (60s default)
- No new dependencies added
