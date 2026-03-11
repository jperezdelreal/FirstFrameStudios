# Decision: ralph-watch README ASCII-safe and v2-accurate

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #152

## Context
tools/README.md was out of date -- it documented ralph-watch v1 defaults (single repo) and omitted v2 features (failure alerts, activity monitor, metrics parsing, multi-repo).

## Decision
Rewrote README to accurately reflect ralph-watch v2:
- Default `-Repos` is all 4 FFS repos, not just `.`
- Documented failure alerts (alerts.json after 3+ consecutive failures)
- Documented activity monitor (background runspace)
- Documented metrics parsing (issues closed, PRs merged/opened)
- Added prerequisites section (gh CLI, copilot extension)
- All text ASCII-safe (no emojis, no Unicode dashes) for PS 5.1 compatibility

## Impact
- Any agent or human reading tools/README.md now gets accurate activation instructions
- Startup is one command: `.\tools\ralph-watch.ps1`
