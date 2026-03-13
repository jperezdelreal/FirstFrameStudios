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

## Core Context (Sessions Summarized)

**Major Initiatives (2026-03-11 to 2026-03-12):**

1. **ralph-watch v3 + Governance Integration**
   - Prepare-mode for blocked issues (blocked-by detection, [PREPARE-ONLY] markers, defense-in-depth at scheduler + prompt)
   - G10 Roster Check: Skip repos without team.md ## Members
   - G11 Upstream Sync: Auto-sync skills/governance/decisions from Hub to downstream repos after git pull
   - Check-ProjectLifecycle function for autonomous ceremony triggering (Sprint Planning issues auto-created, project-state.json updates)
   - PR review dedup (hashtable + prompt-level instructions), needs-research handling (no hard skip, [NEEDS-RESEARCH] marker if squad:{member} labeled)
   - squad-triage.yml body-quality heuristic (acceptance criteria, checklists, ≥100 char body)

2. **PR Review Cycles**
   - Round 2 (2026-03-11): 5/5 PRs merged (Flora #15-17, ComeRosq #15-16). Learned: merge conflicts resolved by combining exports, --admin flag for same-owner repos.
   - Updated tools/README.md docs (was outdated, missing v2 features)

3. **Tooling & Metrics**
   - collect-daily-metrics.ps1: per-repo issue/PR/contributor stats + Ralph metrics → tools/metrics/YYYY-MM-DD.json
   - ComeRosquillas CI (ci.yml): HTML validation, JS syntax, assets check (no build step)
   - GitHub Pages Blog: Jekyll + minima, docs/ on main
   - Priority Labels (P0-P3 + blocked-by:*): Key lesson — workflows must consume config files

4. **Studio Infrastructure Cleanup (R3)**
   - Deleted merged branch (Monitor: squad/13-real-data)
   - squad.labels.json: 7 categories, member-specific auto-generated
   - Cleaned 8 obsolete Star Wars labels from Flora & ComeRosquillas; updated to local team
   - squad.config.ts: Removed games/**, updated routing to @solo/@jango/@mace, removed retired agents

5. **Architecture Learnings**
   - Branch defaults require API call before deletion
   - Label cleanup benefits from listing first
   - Defense-in-depth patterns (scheduler + prompt) more reliable than single-layer enforcement
   - Windows PowerShell 5.1: ASCII-safe only (no unicode/emojis, use -- not em-dash)
   - GitHub API: Contents API requires SHA for PUT updates, use PowerShell pipes for stdin

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
