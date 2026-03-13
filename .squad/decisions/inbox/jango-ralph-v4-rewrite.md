# Decision: ralph-watch v4 Rewrite (Tamir-style Simplification)

**By:** Jango (Tool Engineer)
**Date:** 2026-07-25
**Status:** Implemented
**Tier:** T1

## Context

ralph-watch v3 was 1397 lines with extensive complexity: night/day mode scheduling, issue pre-fetching with priority sorting, per-repo session assignment, activity monitors, PR dedup tracking, remote URL validation, and more. The Founder requested a radical simplification following Tamir Dresher's approach.

## Decision

Rewrote ralph-watch.ps1 from v3 (1397 lines) to v4 (726 lines, 48% reduction).

**Key architectural change:** Multi-repo via prompt scope, not via script-level iteration. A single static prompt tells the squad agent to scan all 4 FFS repos. The agent handles parallelism, issue scheduling, and dedup internally.

**Dropped:** Night/day mode, issue pre-fetching, Get-ScheduledIssues/Get-SessionAssignments, activity monitors, PR dedup tracking, remote URL validation, repo branch validation, Build-SessionPrompt, mode transitions.

**Kept:** Lock file, JSONL logging, heartbeat, failure alerts, session timeout (Start-Job + Wait-Job), circuit breaker, Invoke-GitPull, Invoke-Scheduler, Invoke-UpstreamSync, Check-ProjectLifecycle, Test-HasSquadRoster, Get-RepoName.

**Simplified params:** 4 params (IntervalMinutes, SessionTimeout, DryRun, MaxRounds) instead of 9.

## Consequences

- Simpler to maintain and reason about
- Squad agent has full autonomy over issue selection and parallelism
- No more mode transitions or time-of-day logic to debug
- Session timeout (Start-Job) retained as safety net (not in Tamir's script)
- Heartbeat/log format slightly changed (no mode/sessions fields) -- squad-monitor should handle gracefully
