# Decision: Daily Metrics Collector Script

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #164
**PR:** #168

## Decision

Created `tools/collect-daily-metrics.ps1` to collect daily studio productivity metrics across all 4 FFS repos. The script uses `gh` CLI exclusively for GitHub API calls and outputs structured JSON to `tools/metrics/YYYY-MM-DD.json`.

## Key Design Choices

1. **gh CLI over raw API** -- consistent with ralph-watch patterns, simpler auth
2. **Date search filters** -- uses `--search "created:DATE..DATE"` syntax for reliable date scoping
3. **JSONL log parsing** -- reads ralph-watch logs to extract round/duration/metrics data
4. **Parameterized** -- supports `-Date`, `-DryRun`, `-RepoNames`, `-Owner` for flexibility
5. **Day number from epoch** -- auto-calculates from 2026-03-11T16:31:48Z (same epoch as issue spec)
6. **ASCII-safe** -- no emojis or unicode, compatible with Windows PowerShell 5.1

## Open Questions

- Should this be integrated into ralph-watch as a post-round task, or run separately via scheduler?
- Should we add a rolling averages file (`tools/metrics/averages.json`) as mentioned in the issue?
- Should metrics JSON files be committed to the repo or gitignored?
