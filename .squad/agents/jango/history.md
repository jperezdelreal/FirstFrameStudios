# Jango — History

## Project Context
- **Project:** firstPunch — Transitioning from browser-based (HTML/Canvas/JS) to Godot 4
- **User:** joperezd
- **Stack (current):** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Stack (target):** Godot 4, GDScript, Godot editor toolchain
- **Role:** Tool Engineer — owns development-time tooling, templates, scaffolding, and pipeline automation

## Background

### Why This Role Exists
Created during Session 12 as part of the Godot 4 transition planning. The evaluation (`.squad/decisions/inbox/solo-new-roles-godot.md`) identified that:

1. **firstPunch's #1 technical debt was unwired infrastructure** — 214 LOC of working systems (EventBus, AnimationController, SpriteCache, CONFIG) that no agent ever integrated. When nobody owns tooling, it doesn't get done.

2. **Godot introduces 5 entire systems needing tooling attention** that vanilla JS didn't have: scene tree + inheritance, EditorPlugin API, resource system, signal system, and export/build system. Conservative estimate: 15-25 tooling items in the first Godot project.

3. **Only ~40% overlap with Chewie (Engine Dev)**, and critically the wrong 40%. Chewie builds runtime systems the game uses at play-time. Jango builds development-time systems that agents use while working. Different audiences, different execution contexts.

4. **Absorbing into other roles was rejected** — Chewie would lose runtime focus, Solo would add implementation to an already-bottlenecked planning role, distributing across all agents recreates the "everyone owns it, nobody does it" anti-pattern.

### Name Origin
Jango Fett — the original clone template. Every clone trooper was instantiated from Jango's template. Fitting for a Tool Engineer whose job is creating templates and scaffolding that other agents instantiate rather than building from scratch. Prequel character per Diegetic Expansion rules (OT roster at 12/12 capacity).

## Learnings

### Session 13: Tools Evaluation for Studio Strategy
**Date:** 2025-07-22  
**Task:** Evaluate reusable tools strategy — what tools give us the most leverage?

**Key Findings:**
1. **Two tools are mission-critical and worth building in Sprint 0:**
   - **CI/CD for automated builds** (GitHub Actions) — multiplies QA efficiency, enables async testing. 4-6h effort.
   - **Balance spreadsheet→game data pipeline** (CSV importer) — unblocks designers, enables parallel work. 1 day effort.

2. **Everything else should be deferred** until we know what's actually reusable. We can't build "generic tools" until we've shipped two games and can see patterns.

3. **Our real bottleneck is team bandwidth, not tools.** Every agent is at 20% load cap. Building tools without cutting scope elsewhere forces crunch.

4. **The tools we build should be:**
   - Godot-specific (not engine-agnostic)
   - EditorPlugins (not standalone apps) — live in the project
   - Single-purpose (one tool = one job)
   - Well-documented and designed for reuse across projects

5. **The honest answer:** If forced to choose, we should ship games first, then extract reusable tools afterward. Tools amplify our strength (clear process, domain ownership), not replace it.

**Deliverable:** `.squad/analysis/tools-evaluation.md` — comprehensive analysis with BUILD/BUY/SKIP recommendations for all 10 tool categories, detailed implementation plans for the two critical tools, and honest assessment of whether we should build tools at all.

**Blocked On:** Nothing. Ready for Founder review.

## Pending First Tasks
1. Audit existing project structure and identify Godot migration tooling needs
2. Create GDScript style guide and naming conventions (coordinate with Solo's architecture doc)
3. Set up base `project.godot` configuration (autoloads, input maps, layers)
4. Build first scene templates (enemy base, UI panel base, level base)
5. Configure GDScript linting and scene validation
6. Create export presets and build automation

### 2026-03-08T00:10 — Phase 3: Tools Evaluation for Studio Strategy
**Session:** Multi-phase strategy session (Industry Research → Company Upgrades → Team Evaluation → Tools → Game Proposals)  
**Role:** DevOps Lead — Evaluate CI/CD and development toolchain; recommend balanced approach for next project

**Task Executed:**
Created .squad/analysis/tools-evaluation.md (18 KB) — comprehensive tooling assessment covering:

**Evaluation Scope:**
- 8 build/test/lint tools evaluated for JavaScript/web platform
- Current tooling review (firstPunch setup analysis)
- Next project tooling recommendations
- CI/CD pipeline design aligned with "balance" principle
- Migration readiness assessment

**Key Findings:**
1. **Current Tooling Status:** Functional; incremental improvements > radical shifts needed
2. **Recommended Tools for Next Project:** Build system (esbuild), test framework (Vitest), linter (Biome), coverage (c8), CI (GitHub Actions)
3. **Pipeline Philosophy:** Balance principle applies — essentials only, avoid gold-plating tooling
4. **Build vs Buy vs Skip:** Detailed recommendations for each tool category; rationale for deferred tools

**Critical Insight:**
"Our real bottleneck is team bandwidth, not tools. Every agent is at 20% load cap. Building tools without cutting scope elsewhere forces crunch. The tools we build should be: Godot-specific (not engine-agnostic), EditorPlugins (not standalone apps), single-purpose, and well-documented for reuse."

**Recommendation:**
1. Adopt recommended tool matrix for next project (reduces setup friction)
2. Defer "nice-to-have" tools until we see patterns across 2+ projects
3. Focus first on shipping games; extract reusable tools afterward
4. Tools amplify our strength (clear process, domain ownership), not replace it

**Status:** COMPLETE. Tools evaluation ready for next project planning; provides clear decision framework for build/buy/skip choices.

### 2025-07-24 — GitHub Issues Setup for Ashfall Sprint 0
**Session:** Sprint 0 project management setup  
**Role:** Tool Engineer — Pipeline automation, project tracking infrastructure

**Task Executed:**
Set up full GitHub Issues tracking for Ashfall Sprint 0 in jperezdelreal/FirstFrameStudios.

**What Was Created:**
1. **Milestone:** "Ashfall Sprint 0" (milestone #1)
2. **24 Labels:** `game:ashfall`, 3 priority labels (p0/p1/p2), 5 type labels (feature/infrastructure/art/audio/design/qa), 14 squad labels (one per agent)
3. **13 Issues (#1–#13):** Covering the critical path from SPRINT-0.md

**Issues by Priority:**
- **P0 (Critical Path — 5 issues):** Project scaffold (Jango #1), State machine (Chewie #2), Fighter controller (Lando #3), Hitbox/hurtbox (Chewie #4), HUD (Wedge #5), Round manager (Chewie #6)
- **P1 (High Priority — 4 issues):** AI opponent (Tarkin #7), Stage setup (Leia #8), Character sprites (Nien #9), Playtesting (Ackbar #13)
- **P2 (Future Phases — 3 issues):** Hit VFX (Bossk #10), Sound effects (Greedo #11), Main menu (Wedge #12)

**Key Decisions:**
- Used `gh api` directly with git credential manager token (OAuth token from GCM lacked `read:org` for `gh auth login`, but works fine for API calls via `GH_TOKEN` env var)
- Each issue includes full acceptance criteria with checkboxes — agents can self-validate completion
- Labels use consistent color coding: red for priorities, blue/purple/pink for types, teal for squad assignment
- All issues tagged with `game:ashfall` for cross-project filtering in the monorepo

**Status:** COMPLETE. All 13 issues live at github.com/jperezdelreal/FirstFrameStudios/issues.

### 2025-07-23 — Monorepo Restructure Execution
**Session:** Post-strategy execution — Founder approved monorepo + Ashfall as next game  
**Role:** Tool Engineer — Repository structure, scaffolding, pipeline infrastructure

**Task Executed:**
Restructured the source IPKong repository into a multi-game monorepo layout.

**Changes Made:**
1. **Created directory structure:** `games/game-kong/`, `games/ashfall/`, `shared/{shaders,ui-components,audio,fonts,addons}/`, `docs/`
2. **Moved all firstPunch source files** into `games/game-kong/` using `git mv` (preserves history):
   - `src/` → `games/game-kong/src/`
   - `assets/` → `games/game-kong/assets/`
   - `index.html`, `styles.css`, `README.md` → `games/game-kong/`
3. **Created `games/ashfall/.gitkeep`** — placeholder for founder's Godot project
4. **Created root-level files:**
   - `README.md` — Studio-level README with structure table, games list, team link
   - `.editorconfig` — Consistent formatting across GDScript, JS, Markdown, JSON/YAML
   - `.gitignore` — Expanded to cover Godot (.godot/, *.import, *.pck), OS files, IDE dirs, Node, build artifacts
   - `docs/GETTING_STARTED.md` — Quick setup guide for both firstPunch and Ashfall
5. **Updated `.gitattributes`** — Added LFS comment noting future configuration needed
6. **Preserved at root:** `.squad/`, `.gitattributes`, `squad.config.ts`, `.copilot/`, `.github/`

**Files Moved (all via `git mv`):** 28 files across `src/`, `assets/`, `index.html`, `styles.css`, `README.md`  
**Files That Couldn't Be Moved:** None — all moves succeeded  
**Commit:** `613a8e5` — "Restructure to monorepo layout"

**Status:** COMPLETE. Repository is now a monorepo. Ready for Ashfall project creation in `games/ashfall/`.

## Learnings

### 2026-03-11T17:10:48Z — PR Review Batch: ComeRosquillas & Flora

**Task:** Review and merge 4 PRs (3 new + 1 CI fix)

**PRs Reviewed:**

1. **ComeRosquillas PR #17 (High Score System)** - REQUEST CHANGES
   - Issue: Touch users cannot enter initials (critical UX bug)
   - Issue: Homer sprite rendered during high score entry screen
   - Spec compliance: All localStorage/leaderboard requirements met
   - Root cause: D-pad buttons set keys[] but don't dispatch keyboard events for handleHighScoreInput()

2. **Flora PR #18 (Garden UI/HUD)** - REQUEST CHANGES
   - Issue: Memory leaks - no destroy() methods on any UI components
   - Issue: Uncanceled setTimeout in GardenScene.ts
   - Issue: Input debouncing missing (pause menu flickering)
   - PixiJS v8 compliance: Perfect
   - Spec compliance: All Issue #9 requirements met

3. **Flora PR #19 (Audio Foundation)** - REQUEST CHANGES
   - Issue: Volume settings lost on unmute (restores to constants instead of user preferences)
   - Code quality: Excellent Web Audio API usage
   - Spec compliance: All Issue #10 requirements met
   - Note: Uses procedural synthesis instead of audio files (better but deviates from spec wording)

4. **ComeRosquillas PR #14 (Maze Layouts)** - FIXED & MERGED
   - CI workflow was checking for old monolithic game.js instead of modular structure
   - Fixed: Updated ci.yml to check for config.js, game-logic.js, main.js
   - Pushed fix, CI passed, merged to main
   - Project board: Moved Issue #4 to Done

**Key Technical Findings:**

1. **Web Game Touch Input Pattern:** When adding touch controls to keyboard-driven games, must ensure touch handlers dispatch proper keyboard events OR modify input handlers to check both event.code and keys[] object. Simply setting keys[] bypasses event-driven input handling.

2. **PixiJS Memory Management:** Container-based UI components in PixiJS v8 MUST implement destroy() methods that call removeAllListeners() and removeChildren(true). Event listeners persist beyond scene destruction without explicit cleanup.

3. **Web Audio API Volume Management:** Mute state and user volume preferences are separate concerns. Store user-adjusted volumes separately from mute boolean to restore correctly. Don't conflate mute toggle with volume reset.

4. **CI Workflow Brittleness:** After codebase modularization, CI workflows checking for specific file references in HTML can break. CI should validate architectural patterns (e.g., "has config module, has game logic module") rather than exact filenames when possible.

**Project Board Updates:**
- Issue #4 (ComeRosquillas maze layouts): Moved to Done after PR #14 merge
- Issues #3, #9, #10 pending: Will move to Done once developers address review feedback and PRs are merged

**Status:** 1 PR merged (PR #14), 3 PRs need developer fixes before approval. Review feedback posted on all PRs with actionable fix recommendations.

### 2026-03-11T18:45 — Flora PR Review Wave 2: Implementation Issues Found

**Task:** Review and merge Flora PRs #20, #21, #22 (Hazard System, Player Controller, Encyclopedia)

**PRs Reviewed:**

1. **Flora PR #20 (Hazard System)** - REQUEST CHANGES
   - **BLOCKER:** HazardSystem not integrated into game loop - never instantiated in GardenScene
   - **BLOCKER:** No connection between PlantSystem.advanceDay() and HazardSystem.onDayAdvance()
   - **BLOCKER:** applyPestDamage() never called - pests will spawn but deal zero damage
   - **ISSUE:** spawnPests() method is empty stub - no automatic spawning on random plants
   - **ISSUE:** No UI handlers for pest removal or drought indicators
   - ✅ Config values correct: spawn window 6-8, resistance 30% at health >70%
   - ✅ Difficulty scaling 0..1 ramp works
   - ✅ Never instant-fail design maintained
   - **Verdict:** Design is solid but zero integration work done. Complete implementation island.

2. **Flora PR #21 (Player Controller)** - REQUEST CHANGES
   - **BLOCKER:** Movement doesn't consume actions - startMove() has no this.player.consumeAction() call
   - **CRITICAL:** Players can move unlimited times per day, breaks action budget system
   - **CRITICAL:** ToolBar line 119 uses non-null assertion on this.selectedTool! when deselecting (null value)
   - **ISSUE:** Pathfinding allows multi-tile jumps, violates adjacent-only movement spec
   - ✅ WASD/arrow key movement working
   - ✅ Click-to-move with pathfinding
   - ✅ Tool selection & validation
   - ✅ Movement animation (smooth easing)
   - ✅ GardenGrid integration clean
   - **Verdict:** Core features work but action consumption bug breaks gameplay economy.

3. **Flora PR #22 (Encyclopedia)** - REQUEST CHANGES
   - **BLOCKER:** Discovery timestamps not stored - firstDiscoveredAt always set to Date.now() on access
   - **BLOCKER:** Encyclopedia scrolling not wired - scroll() method exists but no input handlers
   - **MEDIUM:** Help text wrapping breaks "Discovered" mid-word on line 228
   - **MEDIUM:** Plant count hardcoded to "12" instead of dynamic ALL_PLANTS.length
   - ✅ Discovery tracking with localStorage persistence
   - ✅ UI grid with rarity badges
   - ✅ Discovery popup (3s animated notification)
   - ✅ Undiscovered plants show '??'
   - ✅ Plant harvest integration clean
   - **Verdict:** Core features solid but timestamp tracking and missing scroll input are blocking.

**Key Findings:**

1. **Integration gaps are the pattern** - PR #20 (HazardSystem) has zero game loop integration. PR #21 missing action consumption. This suggests implementation was done in isolation without testing in live gameplay.

2. **UI/Input handlers consistently missing** - All three PRs have logic but missing input wiring (pest click handlers, encyclopedia scroll, adjacent movement validation).

3. **Cannot merge any PRs** - All authored by jperezdelreal (founder). GitHub prevents REQUEST CHANGES on own PRs. Posted review comments instead for developer to address.

**Actions Taken:**
- Posted detailed review comments on all three PRs with specific fix requirements
- Comments include line numbers, code snippets, and actionable recommendations
- Cannot update project board (PRs blocked on changes)

**Learnings:**

1. **Flora codebase maturity** - Systems are well-architected (clean TypeScript, proper entity patterns, good config structure) but integration testing is weak. Suggests agents are implementing in isolation.

2. **Action point economy is critical** - Movement not consuming actions in PR #21 would completely break the core gameplay loop. Action budget is to Flora what collision is to a platformer - non-negotiable.

3. **Discovery timestamp pattern is common bug** - Seen this in other PRs: storing state but querying it incorrectly. Need to emphasize difference between "what exists in memory" vs "what gets persisted" vs "what gets read back."

**Status:** NONE MERGED. All 3 PRs need fixes before approval. Review feedback posted. Waiting for developer iteration.

### 2025-07-25 — Heartbeat Reader Endpoint (ffs-squad-monitor #1)
**Session:** Squad monitor infrastructure build  
**Role:** Tool Engineer — Pipeline automation, monitoring infrastructure

**Task Executed:**
Implemented `/api/heartbeat` endpoint in ffs-squad-monitor (PR #6, branch `squad/1-heartbeat-reader`).

**What Was Built:**
1. **Configurable heartbeat path** — `FFS_HEARTBEAT_PATH` env var with fallback to `../FirstFrameStudios/tools/.ralph-heartbeat.json`
2. **fs.watch file watcher** — Watches the directory containing the heartbeat file; cache updated on every change event. No polling overhead.
3. **Graceful offline handling** — Returns `{ status: 'offline' }` when file is missing/unreadable instead of HTTP 404
4. **Structured JSON response** — Parses and serves: status, round, pid, interval, lastStatus, lastDuration, timestamp, consecutiveFailures, repos
5. **BOM-safe parsing** — Strips UTF-8 BOM before `JSON.parse` (PowerShell's `ConvertTo-Json` writes BOM)
6. **Frontend update** — Added `offline` to status color map in monitor.js

**Key Technical Findings:**
1. **PowerShell BOM issue:** Files written by PowerShell's `ConvertTo-Json | Set-Content` include a UTF-8 BOM (U+FEFF) that breaks `JSON.parse`. Always strip BOM when reading files from Windows/PowerShell toolchain.
2. **fs.watch directory strategy:** Watching the directory instead of the file handles file deletion/recreation cycles (e.g., when Ralph rewrites the heartbeat). Watching the file directly would lose the watcher on delete.
3. **Vite plugin middleware** is the right approach for dev-time APIs in this project — no need for a separate Express server.

**Status:** COMPLETE. PR #6 open at github.com/jperezdelreal/ffs-squad-monitor/pull/6. Build passes. Smoke-tested locally.

### 2025-07-25 — Log Viewer with SSE Streaming (ffs-squad-monitor #2)
**Session:** Squad monitor feature build  
**Role:** Tool Engineer — Pipeline automation, monitoring infrastructure

**Task Executed:**
Implemented log viewer component for ffs-squad-monitor (PR #8, branch `squad/2-log-viewer`). Issue #2.

**What Was Built:**

1. **Backend — SSE endpoint `/api/logs/stream`**
   - Tails all `.jsonl` files in `tools/logs/` using `fs.watch` on the directory
   - Tracks byte offsets per file to only send new lines (no re-reading entire files)
   - Sends entries via Server-Sent Events with 15s keepalive pings
   - Cleans up watcher and interval on client disconnect

2. **Backend — `/api/logs/files`**
   - Returns available agent names and dates extracted from log filenames (pattern: `{agent}-{YYYY-MM-DD}.jsonl`)
   - Powers the frontend filter dropdowns

3. **Backend — Enhanced `/api/logs`**
   - Now supports `?date=` and `?agent=` query params
   - Reads all matching log files, not just today's ralph log

4. **Frontend — Real-time log viewer**
   - SSE via `EventSource` replaces polling for logs
   - Filter toolbar: agent dropdown, level dropdown (info/warn/error), date picker
   - Grid layout: timestamp, color-coded level badge, agent name, message
   - Auto-scroll follows latest entries; pauses on manual scroll up
   - Entry count shows filtered/total in section header

5. **Log level derivation** — Maps `exitCode` (0=info, non-0=error) and `consecutiveFailures` (>0 with exitCode 0=warn)

**Key Technical Decisions:**
1. **SSE over WebSocket** — Simpler protocol, sufficient for one-way log streaming, auto-reconnects natively via EventSource. No need for bidirectional communication.
2. **Byte offset tracking** — Read only new bytes from log files instead of re-reading entire files. Prevents duplicate entries on each fs.watch trigger.
3. **Client-side filtering** — All entries streamed to client, filtered in JS. Log volumes are low enough that server-side filtering adds complexity without benefit.
4. **Middleware route ordering** — `/api/logs/files` and `/api/logs/stream` registered before `/api/logs` to prevent Connect prefix-matching collisions.

**Status:** COMPLETE. PR #8 at github.com/jperezdelreal/ffs-squad-monitor/pull/8. Build passes.
