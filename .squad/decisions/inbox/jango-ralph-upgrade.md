# Decision: ralph-watch.ps1 v2 Upgrade

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Status:** IMPLEMENTED
**Requested by:** Joaquin

## Context

Joaquin reviewed Tamir Dresher's squad-personal-demo repo and found our `ralph-watch.ps1` was missing four production-grade features that Tamir's implementation had. Our script was 233 lines with the basics (mutex, heartbeat, git pull, scheduler, log rotation, dry run, multi-repo param). It needed failure alerting, background monitoring, smarter defaults, and metrics extraction.

## Decision

Upgrade `tools/ralph-watch.ps1` to v2 with all four missing features, keeping the script ASCII-safe for Windows PowerShell 5.1 compatibility.

## Changes Made

### 1. Failure Alerts
- Added `$consecutiveFailures` counter and `$alertThreshold = 3`
- `Write-FailureAlert` function writes structured JSON alerts to `tools/logs/alerts.json`
- Each alert includes timestamp, level, round, failure count, exit code, error detail
- Keeps last 50 alerts (rolling window)
- Counter resets to 0 on successful round
- Future upgrade path: swap file writes for Teams webhook calls when webhook URL is configured

### 2. Background Activity Monitor
- `Start-ActivityMonitor` creates a PowerShell runspace that prints status every 30 seconds
- Shows elapsed time and today's log entry count -- prevents silent terminal during long sessions
- `Stop-ActivityMonitor` cleanly disposes runspace on round completion or exception
- Used runspace (not background job) for lower overhead and same-process lifecycle

### 3. Multi-Repo Defaults
- Default `$Repos` now includes all 4 FFS repos: `.`, `../ComeRosquillas`, `../flora`, `../ffs-squad-monitor`
- Ralph prompt now includes `MULTI-REPO WATCH` section listing all repos
- Startup validates repo paths and shows which repos were skipped (not found)
- Falls back to current directory if no repos resolve

### 4. Metrics Parsing
- `Get-SessionMetrics` parses copilot output with regex for: issues closed, PRs merged, PRs opened, commits
- Handles multiple phrasings (e.g., "closed 3 issues", "3 issues closed", "issues closed: 3")
- Metrics included in JSONL log entries and heartbeat file
- Shown in round completion line: `[issues=N prs_merged=N prs_opened=N]`

## Trade-offs

| Choice | Alternative | Why |
|--------|------------|-----|
| File-based alerts (alerts.json) | Teams webhook directly | We don't have webhook URL configured yet; file alerts work offline and can be read by ffs-squad-monitor |
| PowerShell runspace | Background job | Runspace is lighter weight, same process, cleaner shutdown semantics |
| Regex metrics parsing | Structured copilot output | Copilot CLI doesn't emit structured data; regex is best-effort but captures common patterns |
| ASCII-only text | Unicode/emoji markers | Windows PowerShell 5.1 reads .ps1 files as Windows-1252 without UTF-8 BOM, breaking emoji bytes |

## Verification

```powershell
.\tools\ralph-watch.ps1 -DryRun -MaxRounds 1
```

Clean pass: all 4 repos resolved, scheduler ran, heartbeat written with metrics and repo list.

## Impact

- Script: 233 -> 454 lines
- No new dependencies
- Backward compatible (all new params have defaults)
- Heartbeat file format extended (new fields: repos, consecutiveFailures, metrics)
