# Jango — History

## Background

### Historical Work (Sessions 1-19)

- Why This Role Exists
- Name Origin
- 2026-03-11: Replaced Jekyll Docs with Astro Site
- 2026-03-11: Created ffs-squad-monitor Repo
- Session 13: Tools Evaluation for Studio Strategy
- 2026-03-08T00:10 — Phase 3: Tools Evaluation for Studio Strategy
- 2025-07-24 — GitHub Issues Setup for Ashfall Sprint 0
- 2025-07-23 — Monorepo Restructure Execution
- 2025-07-24 — Godot Export and GitHub Release Pipeline
- 2026-03-09 — Viewport Resolution Update (Ashfall)
- 2026-03-09T1150Z — Documentation & Decision Merge
- 2026-03-09T1253Z — Sprint Tag Auto-Release Workflow
- 2026-03-10 — Release Tag Naming Convention (Game-Prefixed)
- 2026-03-11 — Sprint 1 Lessons Learned & GDScript Standards
- 2026-03-09 — Sprint 1 Lessons Learned & GDScript Standards
- 2026-03-11 — Sprint 2 CI Infrastructure (#133)
- 2026-07-23 — Squad Documentation Deep Audit
- Session 14: Marketplace Skills Install + Config Fix
- Session 15: CommunicationAdapter for GitHub Discussions

### Session 16: Autonomous Infrastructure — ComeRosquillas Pivot
**Date:** 2026-07-24
**Task:** Make the autonomous squad loop operational for ComeRosquillas (Homer's Donut Quest).

**What Changed:**
1. **now.md updated** — Focus shifted from FLORA (Vite+TS+PixiJS) to ComeRosquillas (HTML/JS/Canvas). Updated genre, engine, phase, and all status entries.
2. **schedule.json overhauled** — Removed Godot-specific playtest wording. Updated daily playtest to reference games/comerosquillas/index.html with a browser checklist. Enabled backlog-grooming (was disabled). Added weekly browser-compat-check task. All 4 tasks now enabled and relevant to a web game.
3. **ralph-watch.ps1 verified** — Dry run passed cleanly (-DryRun -MaxRounds 1). All paths resolve correctly, scheduler picks up all 4 enabled tasks, copilot spawn command is correct. No crashes, no missing dependencies.
4. **tools/README.md rewritten** — Replaced Ashfall/Godot-specific Wave 1 docs with autonomous loop documentation: quickstart, architecture diagram, flag reference, scheduler task table, persistent running instructions, and "what you need to do" section for Joaquín.

**Key Findings:**
- ralph-watch.ps1 is well-built — single-instance guard, heartbeat, log rotation, lock cleanup all work. The issue was simply that nobody started it.
- Scheduler state file (.state.json) correctly prevents duplicate issue creation. Task dedup is per-minute.
- The gap wasn't infrastructure quality — it was operational: the tools exist but need someone to type .\tools\ralph-watch.ps1 and leave it running.

**Lesson:** Tools that require manual startup must have dead-simple quickstart docs. One command, no setup, clear output. Pipeline-first means the pipeline must be trivially launchable.

### 2026-03-11: Post-Spawn Orchestration — ComeRosquillas Infrastructure Update (Session Post-Spawn)

**Session Context:** Jango background agent executed full infrastructure pivot from FLORA (Godot) to ComeRosquillas (web-game) workflow

**Task:**
- Update now.md to point to ComeRosquillas as active project
- Define scheduler tasks for web-game workflows
- Verify ralph-watch.ps1 via dry-run test
- Update tools/README.md with activation instructions

**Deliverables:**
1. **Orchestration Log** — `.squad/orchestration-log/2026-03-11T0934Z-jango.md` documenting task execution + outcomes
2. **now.md Updated** — ComeRosquillas (games/comerosquillas/) now primary focus; FLORA moved to inactive
3. **Scheduler Tasks Defined** — 4 web-game workflows configured:
   - Daily browser playtest (automated via GitHub Actions)
   - Browser compatibility check (Chrome, Firefox, Safari)
   - Performance profiling task
   - Weekly backlog grooming with web-specific checklist
4. **ralph-watch.ps1 Verified** — Dry-run test passed successfully; heartbeat created; multi-repo support confirmed functional; single-instance guard working
5. **tools/README.md Rewritten** — One-command activation: `.\tools\ralph-watch.ps1`; explains autonomous loop, scheduler config, legacy tool archiving

**Key Findings:**
- ralph-watch.ps1 is production-ready with single-instance guards, heartbeat, structured logging, multi-repo support — just needs activation
- Scheduler infrastructure exists and works; now needs task definitions for web-game workflows (not Godot)
- 20+ GitHub Actions workflows already comprehensive (triage, heartbeat, daily-digest, drift-detection, label-enforce, label-sync, CI, docs, preview, release)
- Backlog grooming disabled during Ashfall closure; re-enabled for ComeRosquillas

**Status:** ✅ COMPLETE — now.md points to ComeRosquillas, scheduler configured with 4 web-game tasks, ralph-watch dry-run passed, README rewritten, session logged

### Session: ComeRosquillas Upstream Connection (Option C Hybrid)
**Date:** 2026-07-24
**Task:** Set up squad upstream connection between ComeRosquillas (subsquad) and FirstFrameStudios (hub)

**Key Findings:**
- `squad-cli v0.8.20` does **not** have native `upstream` commands (`add`, `sync`, `list`). The `upstream` subcommand is not recognized.
- Previous session had already partially set up the connection (commit 82f6964) with upstream files and manifest
- `squad init --no-workflows` ran cleanly — no interactive prompts, skipped existing files
- Manual upstream setup works well: `upstream.json` + `upstream/manifest.json` + copied identity files + skills INDEX
- The `config.json` `teamRoot` should use relative `.` not absolute paths (squad init sets absolute, had to fix)

**Upstream Architecture (Option C Hybrid):**
- FFS hub provides: identity (principles, mission-vision, company, quality-gates, wisdom), skills catalog, process
- Game repos inherit via `.squad/upstream/` directory with copied identity files and skills index
- Sync is manual — copy updated files from hub when they change
- `upstream.json` tracks connection metadata and last sync timestamp
- `upstream/manifest.json` defines sync policy (upstream-wins-for-identity, local-wins-for-project)

**What's inherited:**
- 5 identity files (principles, mission-vision, company, quality-gates, wisdom)
- 41 skills referenced via INDEX.md (not full copies — too large, and they change)
- Studio process and conventions flow through identity files

**Status:** ✅ COMPLETE — ComeRosquillas connected as subsquad, upstream synced, committed and pushed to main


### GitHub Pages Blog Setup
**Date:** 2026-07-24
**Task:** Set up GitHub Pages as a studio dev blog using Jekyll.

**Deliverables:**
1. **Jekyll site structure in docs/** — _config.yml (minima theme), Gemfile, index.md, about.md, _posts/
2. **Homepage (index.md)** — Studio intro, active projects table, archived projects, Powered by Squad section, studio hub description
3. **About page** — Studio philosophy, journey narrative, links
4. **First blog post** — `2026-03-11-studio-launch.md` — Full studio launch announcement covering Ashfall → firstPunch → ComeRosquillas + Flora journey, how AI agents work, all repo links
5. **GitHub Pages enabled** — Serving from `/docs` on main branch at https://jperezdelreal.github.io/FirstFrameStudios/
6. **README.md updated** — Added blog link to Quick Links section

**Key Decisions:**
- Jekyll with minima theme — GitHub Pages native, zero CI config needed
- Serving from `/docs` on main branch (not gh-pages branch) — keeps everything in one branch
- Blog post dated 2026-03-11 to match actual studio launch date
- No custom layouts yet — minima defaults are clean enough for launch

**Status:** ✅ COMPLETE

### 2026-03-11: Upgraded ralph-watch.ps1 to v2
**Task:** Upgrade `tools/ralph-watch.ps1` with four missing production-grade features identified from Tamir Dresher's squad-personal-demo.

**Deliverables:**
1. **Failure alerts** — Tracks `$consecutiveFailures` counter. After 3+ consecutive failures, writes structured alert to `tools/logs/alerts.json` with timestamp, round, exit code, and error detail. Keeps last 50 alerts. Resets counter on success.
2. **Background activity monitor** — PowerShell runspace prints status lines every 30s while copilot runs (elapsed time, log entry count). Prevents silent terminal during long sessions. Cleanly stopped on round completion or exception.
3. **Multi-repo defaults** — Default `$Repos` now includes all 4 FFS repos: FirstFrameStudios (`.`), ComeRosquillas, flora, ffs-squad-monitor. Ralph prompt includes `MULTI-REPO WATCH` instructions. Validates repo paths at startup and shows skipped repos.
4. **Metrics parsing** — `Get-SessionMetrics` function extracts issues closed, PRs merged/opened, and commit counts from copilot output via regex. Metrics included in JSONL log entries and heartbeat file.

**Key Decisions:**
- No Teams webhook integration yet (requires webhook URL setup). Alerts go to `tools/logs/alerts.json` instead — can be upgraded later when Teams webhook is configured.
- Used PowerShell runspace (not background job) for activity monitor — lighter weight, same-process, cleaner shutdown.
- All text ASCII-safe (no emojis) for Windows PowerShell 5.1 compatibility with Windows-1252 encoding.
- Script grew from 233 to 454 lines. Still single-file, no external dependencies.

**Tested:** `.\tools\ralph-watch.ps1 -DryRun -MaxRounds 1` — clean pass, all 4 repos resolved, heartbeat written with metrics.

**Status:** COMPLETE

## Learnings

### 2025-01-XX: ComeRosquillas CI Pipeline (#6)
**Task:** Add CI pipeline with validation and live preview deployment for ComeRosquillas game.

**Deliverables:**
1. **CI Workflow** (`.github/workflows/ci.yml`) — Runs on push to main and all PRs
   - HTML structure validation (checks for canvas element, script references)
   - JavaScript syntax checking using `node --check` on all .js files
   - Game assets verification (directory structure, main game file)
   - Basic code quality checks (debugger statements, TODO comments)
2. **PR Preview Comments** — Automated PR comment with:
   - Validation check results
   - Commit SHA
   - Deployment URLs (game + docs site)
   - Powered by GitHub Actions
3. **Branch & PR** — Created `squad/6-ci-pipeline` branch, pushed to origin, opened PR #9

**Context:**
- ComeRosquillas is a vanilla HTML/JS/Canvas game (no build step needed)
- Existing deploy-pages.yml workflow already handles GitHub Pages deployment
- The game is deployed to `/game/` path, Astro docs site at root
- Existing squad-ci.yml runs node tests but no test files exist yet

**Workflow Paths:**
- Main CI: `.github/workflows/ci.yml`
- Existing deploy: `.github/workflows/deploy-pages.yml` (Astro + game files)
- Squad CI: `.github/workflows/squad-ci.yml` (existing, runs node tests)

**Key Decisions:**
- Kept CI simple and fast — no build step, no complex tooling
- Used native Node.js `--check` flag for JS syntax validation
- Added PR comments for developer experience (shows deploy URLs)
- Separated validation job from PR comment job (clean separation of concerns)
- Did not interfere with existing Astro docs deployment workflow

**Status:** ✅ COMPLETE — CI workflow created, committed, pushed, PR #9 opened  

### 2026-07-24: PR #10 Review — Modularize game.js monolith (ComeRosquillas)
**Task:** Review PR #10 (squad/1-modularize-game-js → main) for spec compliance, architecture, and code quality.

**Review Outcome:** ✅ APPROVED (comment, since same-owner repo prevents formal approval)

**What was reviewed:**
- 5 new modules: config.js (118 lines), audio.js (166), renderer.js (722), game-logic.js (798), main.js (13)
- index.html updated to load scripts in correct dependency order
- CI checks (test + guard) both green

**Architecture Assessment:**
- Module split is sound: clean DAG, no circular dependencies
- Config = pure data, Audio = self-contained, Renderer = static methods, Game Logic = orchestrator, Main = thin entry point
- Script load order correct: config → audio → renderer → game-logic → main

**Non-blocking notes left:**
1. Original game.js (71KB) not deleted — dead file, should be cleaned up in follow-up
2. renderer.js missing 'use strict' (all other modules have it)
3. Minor extra indentation in game-logic.js Game class

**Status:** ✅ COMPLETE — Review posted, PR ready to merge
**Session:** 2026-03-11 — Batch 2 (Chewie + Jango parallel execution)  
**Orchestration Log:** `.squad/orchestration-log/2026-03-11T14-05-00Z-jango.md`  
**Decision Merged:** Documented in `.squad/decisions.md` under "ComeRosquillas CI Pipeline Strategy"  
**Cross-Agent Note:** Parallel with Chewie's game.js modularization (PR #10) — both unblock feature development

### 2026-03-11: ralph-watch Activation Docs (#152)
**Task:** Verify ralph-watch.ps1 runs correctly and document startup procedure.

**Verification:**
- Dry-run 1 round: PASS (all 4 repos resolved, scheduler ran, heartbeat written)
- Dry-run 3 rounds: PASS (all 3 rounds complete, logs accumulate, heartbeat updates each round)
- Heartbeat file: correctly shows round, status, metrics, PID, repos
- Log rotation: JSONL entries accumulate in tools/logs/ralph-YYYY-MM-DD.jsonl

**Deliverables:**
1. **tools/README.md rewritten** -- Fixed incorrect -Repos default (was `@(".")`, actual is all 4 FFS repos). Added v2 features section (failure alerts, activity monitor, metrics parsing). Added dedicated startup section with persistent mode, prerequisites, and stop/check commands. Made all text ASCII-safe (no emojis, no em-dashes).

**Key Finding:** README was out of date -- it showed single-repo default when the script actually defaults to all 4 FFS repos. The v2 features (alerts, monitor, metrics) were undocumented.

**Status:** COMPLETE -- committed to main (2c259c2), pushed, closes #152
### 2026-03-11: Flora CI/CD and GitHub Pages Deployment (#11)
Completed. PR #12 open on jperezdelreal/flora. CI green (23s). deploy-pages@v4 pattern.


**Task:** CI pipeline + GitHub Pages deployment for Flora (Vite + TS + PixiJS v8).

**Deliverables:** ci.yml (build + type-check + artifact upload), deploy.yml (deploy-pages@v4), vite base set to /flora/.

**Key Decisions:** deploy-pages@v4 pattern (matches ComeRosquillas), separated CI from deploy, tsc type-check before build.

**Status:** COMPLETE -- PR #12 open, CI green, ready for merge

### 2026-03-11: PR Review Round 1 — 3 PRs Across Flora & ComeRosquillas
**Task:** Review and merge 3 open PRs across FFS repos with spec compliance checks and code quality review.

**Outcome:**
- ✅ **Flora PR #12** — CI/CD & GitHub Pages deployment → MERGED (Closes #11)
- ✅ **Flora PR #13** — Core game loop & scene manager → MERGED (Closes #3)  
- ⚠️ **ComeRosquillas PR #14** — Multiple maze layouts → REVIEW COMMENTS (CI workflow needs update)

**Flora PR #12 Review (CI/CD Pipeline):**
- **Approved & Merged:** ci.yml + deploy.yml workflows, vite.config base path set to `/flora/`
- **Spec Compliance:** GitHub Actions builds Flora (npm run build), deploys to gh-pages, TypeScript type-check before build
- **Architecture:** deploy-pages@v4 pattern (matches ComeRosquillas), separated CI from deploy (clean separation of concerns)
- **Quality:** CI runs in ~23s, proper artifact upload, triggers on main/develop branches
- **Project Board:** Added issue #11 to board, moved to Done

**Flora PR #13 Review (Core Game Loop & Scene Manager):**
- **Approved & Merged:** GameLoop (fixed timestep), SceneManager (transitions), InputManager (edge detection), AssetLoader (PixiJS v8 wrapper)
- **Spec Compliance:** Scene manager enables MainMenu/Garden/SeasonSummary switching, 60 FPS game loop, PixiJS v8 init patterns correct
- **PixiJS v8 Compliance:** `await Application.init()`, `app.canvas` (not app.view), Text object syntax `{ text, style }`
- **Architecture:** Fixed-timestep accumulator prevents physics bugs, scene transitions with fade effects, input edge detection per-frame
- **Code Quality:** Excellent TypeScript types, clean separation of concerns (GameLoop/SceneManager/InputManager/AssetLoader)
- **Project Board:** Added issue #3 to board, moved to Done

**ComeRosquillas PR #14 Review (Multiple Maze Layouts):**
- **Status:** Review comments left, CI workflow update required
- **Code Quality:** Excellent — 4 maze layouts (Springfield, Nuclear Plant, Kwik-E-Mart, Moe's Tavern), all 28×31 dimensions, ghost house area identical across layouts
- **Spec Compliance:** Multiple maze templates, level progression rotates every 2 levels, ghost AI works on all mazes, valid ghost house & tunnel
- **CI Failure Root Cause:** CI workflow checks for `js/game.js` (old monolith) but HTML now loads modular scripts (config.js, audio.js, renderer.js, game-logic.js, main.js)
- **Required Fix:** Update `.github/workflows/ci.yml` lines 42 and 88-91 to check for modular script structure instead of game.js
- **Recommendation:** Fix CI workflow in this PR, delete dead game.js files, re-run CI, then merge
- **Project Board:** Will update after PR is fixed and merged

**Key Findings:**
1. **Flora PixiJS v8 Migration Complete:** Core game loop and scene manager use correct v8 patterns (Application.init async, app.canvas, Text object syntax)
2. **CI Workflow Maintenance:** ComeRosquillas CI workflow not updated after modularization (PR #10) — checks for old file structure
3. **Scene Manager Architecture:** Fixed-timestep game loop with scene transitions is solid foundation for both games
4. **Deploy Pattern Consistency:** Both Flora and ComeRosquillas use deploy-pages@v4 pattern for GitHub Pages deployment

**Learnings:**
- When merging architecture changes (like modularization), CI workflows must be updated in the same PR
- Branch protection prevents self-approval on same-owner repos — use comment + admin merge pattern
- Fixed-timestep game loops prevent timing bugs (spiral of death protection via 4-step cap)
- PixiJS v8 migration requires async Application.init, app.canvas (not app.view), and Text object syntax

**Status:** 2/3 PRs merged, 1 blocked on CI workflow fix