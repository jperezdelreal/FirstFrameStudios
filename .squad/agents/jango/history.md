# Jango — History

## Core Context

**Jango's Core Role:** Tool Engineer + PR Reviewer. Tooling autonomy (no bandwidth limits), multi-repo CI/CD infrastructure, automation for operational efficiency. GitHub Actions specialist.

**Key Technical Learnings:**
- ralph-watch.ps1 is production-ready with single-instance guards, heartbeat, log rotation. Needs operational activation, not construction.
- Scheduler infrastructure works: dedup per-minute prevents duplicate issues. Task definitions must be web-game-relevant (not Godot).
- Tools requiring manual startup need dead-simple quickstart docs — one command, no setup. Pipeline-first means launchable.
- CI/CD pattern: validate-before-deploy, separate CI from deploy workflows, minimize build time for rapid iteration.
- Multi-repo ralph-watch defaults to all 4 FFS repos; session-scoped prompts (1 repo/session) focus copilot better than mega-prompts.

**Studio Infrastructure Owned:**
- **ralph-watch.ps1 v3** — Multi-repo scheduler with night/day mode (2 parallel sessions night, 1 session day), priority filtering, governance filter (T0/T1 approved), metrics parsing, failure alerts, activity monitor
- **GitHub Actions workflows** — 20+ workflows (triage, heartbeat, daily-digest, drift-detection, label-enforce, label-sync, CI, docs, preview, release, webhook notifications)
- **Scheduler tasks** — 4 enabled for ComeRosquillas (daily browser playtest, browser-compat-check, performance profiling, weekly backlog grooming)
- **Metrics collection** — daily metrics script for all repos (issues opened/closed, PRs merged, contributors, Ralph metrics)
- **Discord webhook notifications** — rate-limited, ASCII-safe, color-coded (red/green/blue/gray), for CI failures, PR merges, priority issues, Ralph heartbeats
- **Upstream sync** — G11 guardrail, syncs skills/quality-gates/governance/decisions from hub to downstream repos after git pull

**Important File Paths:**
- `tools/ralph-watch.ps1` — Main scheduler script (454 lines, multi-repo, night/day mode)
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

## 2026-03-12: Prepare-Mode for Blocked Issues in ralph-watch.ps1

**Task:** Implement "prepare but don't merge" mode per governance.md Dependencies section.

**What Changed:**
1. **blocked-by detection** — Scans labels for `blocked-by:*` pattern, sets `IsBlocked` flag on issue objects
2. **P3 blocked skip** — Skip entirely (not worth preparing), logged with `[dep]` marker
3. **Sort order** — Blocked issues sort after non-blocked (work non-blocked first)
4. **[PREPARE-ONLY] marker** — Issue lines tagged for blocked issues in both sync and parallel sessions
5. **Prompt instructions** — New `PREPARE MODE (blocked issues)` section instructing Ralph to only write tests, scaffold, open Draft PRs [WIP], never merge/close blocked issues

**Key Pattern:** Defense in depth — enforce at scheduler level (skip/filter) AND prompt level (instructions). Even if prompt ignored, governance rules still enforced.

**File Modified:** tools/ralph-watch.ps1

**Status:** ✅ COMPLETE

---

## 2026-03-12: G10 + G11 Guardrails in ralph-watch.ps1

**What:**
- **G10 Roster Check** — Ralph skips repos without `.squad/team.md` containing `## Members` section before fetching issues
- **G11 Upstream Sync** — Hub content syncs to downstream repos after every git pull (skills/, quality-gates.md, governance.md, decisions.md, squad.agent.md)

**Architecture:**
- G10: `Test-HasSquadRoster` helper, called before each repo's issue fetch
- G11: `Invoke-UpstreamSync` helper as Step 2.5 in main loop (between git pull and scheduler)
- G11 only syncs if downstream has `.squad/` directory (won't create it)
- G11 commits only if git detects differences, message: "chore: upstream sync from hub"
- DryRun support for both guardrails

**ASCII-safe markers:** Used `[roster]` and `[sync]` text instead of emojis for Windows PowerShell 5.1

**File Modified:** tools/ralph-watch.ps1

**Status:** ✅ COMPLETE

---

## Earlier Sessions (Compressed)

**2026-03-11: PR Review Round 2** — 5/5 PRs merged (Flora #15-17, ComeRosq #15-16). Key: merge conflicts resolved by combining exports, --admin flag needed for same-owner repos.

**2026-03-11: ralph-watch Docs (#152)** — Verified dry-run 1+3 rounds PASS. Rewrote tools/README.md (was out of date — showed single-repo default, missing v2 features).

**2026-03-11: Daily Metrics (#164)** — Created tools/collect-daily-metrics.ps1 with per-repo issue/PR/contributor stats + Ralph round metrics. Output: tools/metrics/YYYY-MM-DD.json. PR #168.

**2026-03-11: ComeRosquillas CI (#6)** — ci.yml with HTML validation, JS syntax check, assets verification. No build step, simple.

**2026-07-24: ComeRosq Pivot** — Switched now.md + schedule.json from Godot to web. Gap was operational, not construction.

**2026-07-24: Upstream Connection** — Manual upstream setup (squad-cli lacks native upstream cmds). Hub provides identity + skills catalog via .squad/upstream/. config.json teamRoot uses relative `.`.

**2026-07-24: GitHub Pages Blog** — Jekyll + minima in docs/, GitHub Pages from /docs on main. Studio blog with launch post.

**2026-03-11: ralph-watch v2** — Added failure alerts (tools/logs/alerts.json), activity monitor (PowerShell runspace), multi-repo defaults, metrics parsing. 233→454 lines.

**2026-07-25: Priority Labels** — Created P0-P3 + blocked-by:* labels. Key lesson: sync-squad-labels.yml has hardcoded labels that override — config files only work if workflows consume them.

---

## 2026-03-12: R3 Cleanup — Multi-Repo Optimization

**Tasks Completed (All 5):**

1. **R3.1: Delete merged branch (Monitor)** — Removed `squad/13-real-data` locally and remotely after PR #16 merge.

2. **R3.5: Regenerate squad.labels.json (Hub)** — Created `.squad/squad.labels.json` documenting all standard labels from sync-squad-labels.yml workflow. Includes 7 categories: squad, priority, blocked_by, go, release, type, signal. Also notes that member-specific labels are auto-generated.

3. **R3.6: Clean obsolete labels (Flora + ComeRosquillas)** — Deleted 8 Star Wars agent labels (solo, chewie, lando, wedge, greedo, tarkin, jango, yoda/ackbar) from each repo. Flora now has only local squad members: oak, brock, erika, misty, sabrina + copilot base label. ComeRosquillas now has: moe, barney, lenny, nelson + ralph + copilot base label.

4. **R3.8: Update squad.config.ts (Hub)** — Removed `games/**` from `allowedWritePaths` (games code moved to separate repos). Updated routing rules to current active agents: feature-dev→@solo/@jango/@mace, bug-fix→@jango/@mace, testing→@mace (removed retired agents @chewie, @lando, @ackbar).

5. **R3.10: Rename master → main (Monitor)** — Completed branch migration: local rename, push new main, set GitHub default, delete remote master, fix local/remote HEAD tracking. Monitor is now fully on main.

**Key Learnings:**
- Branch default changes require API call before deletion (can't delete current default)
- Label cleanup across repos benefited from listing first to avoid errors on missing labels
- Config files (squad.config.ts) require careful agent roster maintenance — used current team (Solo, Jango, Mace)

**Commits:**
- Hub: `86db7b5` — squad.labels.json + squad.config.ts updates
- Monitor: No additional commits (already on main, branch deletions complete)
- Flora: No commits (label deletions only)
- ComeRosquillas: No commits (label deletions only)

---

## 2026-07-25: Fix 5 Bugs in ralph-watch and squad-triage (PR #191)

**Task:** Fix 5 discovered bugs across ralph-watch.ps1 and squad-triage.yml.

**What Changed:**
1. **squad-triage.yml** -- Replaced blind `go:needs-research` default with body quality heuristic (checks for acceptance criteria, checklists, structured sections, body length >= 100 chars)
2. **ralph-watch needs-research handling** -- No longer hard-skips `go:needs-research` issues. If the issue has a `squad:{member}` label, includes it with `[NEEDS-RESEARCH]` marker for agent investigation
3. **PR review prompt rules** -- Added explicit PR REVIEW RULES section: `--request-changes` for rejections, `--approve` for approvals, `--comment` only for non-blocking suggestions
4. **Re-review detection** -- Added RE-REVIEW DETECTION prompt section: detects COMMENTED reviews with rejection verdicts and new commits, asks reviewer to re-review properly
5. **PR dedup tracking** -- Added `$script:processedPRs` hashtable + `Update-ProcessedPRs` / `Test-PRAlreadyProcessed` helpers + prompt-side PR DEDUP instructions to prevent re-commenting loops
6. **ASCII fix** -- Replaced pre-existing em-dash (U+2014) with `--` to maintain Windows PowerShell 5.1 compatibility

**Key Patterns:**
- Defense in depth: dedup enforced at BOTH scheduler level (PowerShell hashtable) AND prompt level (instructions)
- Issue object extended with `NeedsResearch` property for downstream markers
- Triage heuristic is intentionally simple (regex-based, no NLP) for reliability in GitHub Actions

**Files Modified:** `.github/workflows/squad-triage.yml`, `tools/ralph-watch.ps1`

**Status:** PR #191 opened
