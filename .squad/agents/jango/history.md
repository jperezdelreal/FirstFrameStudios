# Jango — History

## Project Context
- **Project:** SimpsonsKong — Transitioning from browser-based (HTML/Canvas/JS) to Godot 4
- **User:** joperezd
- **Stack (current):** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Stack (target):** Godot 4, GDScript, Godot editor toolchain
- **Role:** Tool Engineer — owns development-time tooling, templates, scaffolding, and pipeline automation

## Background

### Why This Role Exists
Created during Session 12 as part of the Godot 4 transition planning. The evaluation (`.squad/decisions/inbox/solo-new-roles-godot.md`) identified that:

1. **SimpsonsKong's #1 technical debt was unwired infrastructure** — 214 LOC of working systems (EventBus, AnimationController, SpriteCache, CONFIG) that no agent ever integrated. When nobody owns tooling, it doesn't get done.

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
- Current tooling review (SimpsonsKong setup analysis)
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

### 2025-07-23 — Monorepo Restructure Execution
**Session:** Post-strategy execution — Founder approved monorepo + Ashfall as next game  
**Role:** Tool Engineer — Repository structure, scaffolding, pipeline infrastructure

**Task Executed:**
Restructured the SimpsonsKong repository into a multi-game monorepo layout.

**Changes Made:**
1. **Created directory structure:** `games/simpsons-kong/`, `games/ashfall/`, `shared/{shaders,ui-components,audio,fonts,addons}/`, `docs/`
2. **Moved all SimpsonsKong source files** into `games/simpsons-kong/` using `git mv` (preserves history):
   - `src/` → `games/simpsons-kong/src/`
   - `assets/` → `games/simpsons-kong/assets/`
   - `index.html`, `styles.css`, `README.md` → `games/simpsons-kong/`
3. **Created `games/ashfall/.gitkeep`** — placeholder for founder's Godot project
4. **Created root-level files:**
   - `README.md` — Studio-level README with structure table, games list, team link
   - `.editorconfig` — Consistent formatting across GDScript, JS, Markdown, JSON/YAML
   - `.gitignore` — Expanded to cover Godot (.godot/, *.import, *.pck), OS files, IDE dirs, Node, build artifacts
   - `docs/GETTING_STARTED.md` — Quick setup guide for both SimpsonsKong and Ashfall
5. **Updated `.gitattributes`** — Added LFS comment noting future configuration needed
6. **Preserved at root:** `.squad/`, `.gitattributes`, `squad.config.ts`, `.copilot/`, `.github/`

**Files Moved (all via `git mv`):** 28 files across `src/`, `assets/`, `index.html`, `styles.css`, `README.md`  
**Files That Couldn't Be Moved:** None — all moves succeeded  
**Commit:** `613a8e5` — "Restructure to monorepo layout"

**Status:** COMPLETE. Repository is now a monorepo. Ready for Ashfall project creation in `games/ashfall/`.
