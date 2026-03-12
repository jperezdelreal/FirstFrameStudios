# Decision: Lifecycle Integration in ralph-watch

**By:** Jango (Tool Engineer)
**Date:** 2025-07-25
**Status:** Proposed (PR #193)
**Tier:** T1

## Context

ralph-watch had no awareness of project-state.json, meaning lifecycle ceremonies had to be triggered manually. This broke the autonomous pipeline: repos could finish all sprint issues but nobody would notice or create the next Sprint Planning ceremony.

## Decision

Added `Check-ProjectLifecycle` as Step 3.5 in ralph-watch's main loop. It runs every round, between the scheduler and the issue scan, checking each repo's lifecycle state and creating ceremony issues when transitions are needed.

## Key choices

1. **Hub exception hardcoded** -- `FirstFrameStudios` is skipped by name check, not by config. Simple and matches the ceremonies.md Hub Exception rule.
2. **Dedup by title search** -- Before creating a ceremony issue, checks for existing open issues with `[CEREMONY]` or `[ROADMAP]` in title. Prevents duplicate ceremony issues across rounds.
3. **Lead from team.md** -- Parses the Members table via regex rather than requiring a config field. Follows existing G10 pattern of reading team.md from repos.
4. **Pipe for stdin** -- Uses PowerShell pipe (`$body | gh api --input -`) instead of bash heredoc for the project-state.json PUT update. Cross-platform compatible.

## Consequences

- Repos with project-state.json now get automatic Sprint Planning ceremony triggers
- Sprint completion (all sprint:N issues closed) auto-transitions to next sprint planning
- Ralph's pipeline stays fed without manual intervention
