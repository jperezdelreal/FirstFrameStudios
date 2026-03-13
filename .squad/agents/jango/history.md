# Jango — History

## Core Context

**Jango's Core Role:** Tool Engineer + PR Reviewer. Tooling autonomy (no bandwidth limits), multi-repo CI/CD infrastructure, automation for operational efficiency. GitHub Actions specialist.

**Key Technical Learnings:**
- ralph-watch v4: Tamir-style simplification. Multi-repo via prompt scope, not script iteration. Squad agent handles parallelism internally.
- Scheduler infrastructure works: dedup per-minute prevents duplicate issues. Task definitions must be web-game-relevant (not Godot).
- Tools requiring manual startup need dead-simple quickstart docs — one command, no setup. Pipeline-first means launchable.
- CI/CD pattern: validate-before-deploy, separate CI from deploy workflows, minimize build time for rapid iteration.

**Studio Infrastructure Owned:**
- **ralph-watch.ps1 v4** — Tamir-style simplified loop. Multi-repo via prompt scope (not script iteration). Static prompt, session timeout via Start-Job, circuit breaker, upstream sync, project lifecycle. 726 lines (was 1397).
- **GitHub Actions workflows** — 20+ workflows (triage, heartbeat, daily-digest, drift-detection, label-enforce, label-sync, CI, docs, preview, release, webhook notifications)
- **Scheduler tasks** — 4 enabled for ComeRosquillas (daily browser playtest, browser-compat-check, performance profiling, weekly backlog grooming)
- **Metrics collection** — daily metrics script for all repos (issues opened/closed, PRs merged, contributors, Ralph metrics)
- **Discord webhook notifications** — rate-limited, ASCII-safe, color-coded (red/green/blue/gray), for CI failures, PR merges, priority issues, Ralph heartbeats
- **Upstream sync** — G11 guardrail, syncs skills/quality-gates/governance/decisions from hub to downstream repos after git pull

**Important File Paths:**
- `tools/ralph-watch.ps1` — Main scheduler script (726 lines, v4 Tamir-style simplified)
- `tools/README.md` — ralph-watch activation docs (startup, prerequisites, flag reference, scheduler task table)
- `.github/workflows/*.yml` — 20+ GitHub Actions (triage, heartbeat, discord notifications, CI/CD, label sync)
- `schedule.json` — Ralph's scheduler task definitions (4 tasks, all enabled for web games)
- `tools/logs/` — Ralph JSONL logs (one per day), alerts.json (failure tracking), heartbeat.json
- `.squad/agents/jango/charter.md` — Jango's task list (CI/CD, PR reviews, tool maintenance)

**Decisions Implemented:**
- ralph-watch v3: night/day mode scheduling, governance filter (skip T0, require approval for T1), priority-aware execution order
- Prepare-mode for blocked issues: [PREPARE-ONLY] marker in prompts, defense-in-depth (scheduler + prompt layers)
- G10 Roster Check: Ralph skips repos without .squad/team.md ## Members section
- G11 Upstream Sync: Auto-sync skills/quality-gates/governance/decisions after git pull
- G8 squad.agent.md Drift Check: Added to upstream sync, Scribe monitors for divergence

**Common Pitfalls:**
- Label overlaps: sync-squad-labels.yml will revert labels on next run if workflow not updated. Config files only work if workflows consume them.
- PR review at same-owner repos: branch protection prevents formal approval, use --admin flag with gh pr merge
- Merge conflicts in shared index files: resolve by combining exports from multiple PRs, use GameLoop-based main.ts
- Ralph session assignment: power-of-two antipattern (start.ps1 job spawning cascades), use explicit array returns with `,@()` pattern
- Windows PowerShell 5.1 compatibility: ASCII-safe only (no emojis, em-dashes, unicode), encode output carefully

---
## Core Context (Sessions Summarized)

**Sessions 2026-03-11 to 2026-03-13 (archived):** Implemented ralph-watch v3 governance integration (Prepare-mode, G10 Roster Check, G11 Upstream Sync, Check-ProjectLifecycle, squad-triage body-quality heuristic, PR review dedup patterns). Executed R3 infrastructure cleanup (deleted merged branches, regenerated squad.labels.json with 7 categories, cleaned obsolete Star Wars labels from Flora/ComeRosquillas, updated squad.config.ts routing rules, completed branch master→main migration in Monitor). PR review Round 2: 5/5 merged (Flora, ComeRosquillas). Delivered collect-daily-metrics.ps1 for per-repo stats + Ralph metrics. Learned: defense-in-depth (scheduler + prompt) beats single-layer enforcement; Windows PowerShell 5.1 ASCII-safe required; GitHub Contents API needs SHA for PUT updates.

---

## Learnings

### 2026-07-25: Check-ProjectLifecycle in ralph-watch.ps1 (PR #193)

**Task:** Add autonomous lifecycle ceremony triggering to ralph-watch.

**What Changed:**
1. **Check-ProjectLifecycle function** -- Fetches `.squad/project-state.json` via GitHub API for each monitored repo (except Hub)
2. **sprint-planning detection** -- Creates `[CEREMONY] Sprint Planning` issue if none exists, with ceremony labels and go:ready
3. **sprinting transition** -- Detects when all `sprint:N` issues close, updates project-state.json via API (PUT with SHA), increments sprint, creates ceremony issue
4. **closeout skip** -- Event-driven per Solo's design, no automatic action
5. **Lead extraction** -- Parses `.squad/team.md` Members table via regex to find Lead for `squad:{lead}` label
6. **Integration point** -- Step 3.5 in main loop, after Invoke-Scheduler, before issue scan

**Key Patterns:**
- GitHub Contents API requires SHA for PUT updates (fetch first, then update)
- PowerShell pipe (`$body | gh api --input -`) instead of bash heredoc (`<<<`) for stdin
- Dedup ceremony issues by checking for existing `[CEREMONY]` or `[ROADMAP]` titles before creating
- Hub exception hardcoded: FirstFrameStudios is infrastructure, not a project

**File Modified:** `tools/ralph-watch.ps1`

**Status:** PR #193 opened

### 2026-07-25: ralph-watch v4 Rewrite -- Tamir-style Simplification

**Task:** Rewrite ralph-watch.ps1 from 1397 lines to ~726 lines following Tamir Dresher's approach.

**What Changed:**
1. **Architecture shift** -- Multi-repo via prompt scope, not script iteration. Single static prompt tells Ralph to scan all 4 FFS repos. Squad agent handles parallelism internally.
2. **Dropped** -- Night/day mode (Get-OperatingMode, Get-ModeConfig), issue pre-fetching (Get-ScheduledIssues, Get-SessionAssignments), activity monitors, PR dedup tracking, remote URL validation, repo branch validation, Build-SessionPrompt, Invoke-CopilotSession, multi-repo foreach loop.
3. **Kept as-is** -- Invoke-GitPull, Invoke-Scheduler, Invoke-UpstreamSync, Check-ProjectLifecycle, Test-HasSquadRoster, Get-RepoName. These are well-tested and work.
4. **Kept and simplified** -- Write-RalphLog (removed mode/sessions fields), Update-Heartbeat (uses IntervalMinutes instead of ModeConfig), Write-FailureAlert, Get-SessionMetrics, circuit breaker, lock file, .ralph-stop.
5. **Params simplified** -- 4 params (IntervalMinutes, SessionTimeout, DryRun, MaxRounds) instead of 9 (Mode, NightSessions, DaySessions, NightInterval, DayInterval, MaxIssuesPerSession, DryRun, MaxRounds, Repos).

**Key Patterns:**
- Static prompt with multi-repo scope replaces per-repo session scheduling
- Session timeout via Start-Job + Wait-Job is our safety net (Tamir doesn't have this)
- Downstream repo discovery via filesystem (Join-Path parentDir repoName) instead of param array
- Python writer script needed for generating clean PowerShell without backtick-escaping issues in here-strings

**File Modified:** `tools/ralph-watch.ps1` (1397 -> 726 lines, 48% reduction)
