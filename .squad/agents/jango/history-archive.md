## Project Context
- **Project:** firstPunch — Transitioning from browser-based (HTML/Canvas/JS) to Godot 4
- **User:** joperezd
- **Stack (current):** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Stack (target):** Godot 4, GDScript, Godot editor toolchain
- **Role:** Tool Engineer — owns development-time tooling, templates, scaffolding, and pipeline automation




## Archived Session Details (moved by P1-04)



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
