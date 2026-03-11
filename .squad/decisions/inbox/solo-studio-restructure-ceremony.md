# 🏗️ CEREMONY: Studio Restructure Review

**Ceremony Type:** Major — Studio-Wide Restructuring  
**Facilitator:** Solo (Lead / Chief Architect)  
**Requested by:** Joaquín  
**Date:** 2026-07-24  
**Status:** AWAITING FOUNDER APPROVAL

---

## Context

Today the studio completed a massive architectural pivot:
- **Monorepo → Multi-repo hub** (Option C Hybrid implemented)
- **FFS became Studio Hub** — no game code
- **ComeRosquillas** → own repo (jperezdelreal/ComeRosquillas, 8 open issues)
- **Flora** → own repo (jperezdelreal/flora, 0 open issues)
- **ffs-squad-monitor** → tool repo (jperezdelreal/ffs-squad-monitor, 5 open issues)
- **ralph-watch.ps1** upgraded to v2 (401 lines, multi-repo, failure alerts)
- **GitHub Pages** site deployed with Astro
- **8 game issues** migrated FFS → ComeRosquillas
- **4 infra issues** remain in FFS hub

This ceremony audits everything that needs to change now that we're a multi-repo studio, not a monorepo with game code.

---

## 1. TEAM DISTRIBUTION AUDIT

### Current State

18 entities on the roster (team.md):
- **15 named agents:** Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien, Jango, Mace, Scribe
- **2 system roles:** Ralph (Work Monitor), @copilot (Coding Agent)
- **All 15 listed as 🟢 Active** — no hibernated agents

### Problems

1. **5 agents were created for Ashfall/Godot art pipeline** and have no meaningful work in the current web stack:
   - **Boba (Art Director)** — built for Blender/FLUX sprite pipeline. ComeRosquillas uses emoji sprites. Flora uses PixiJS built-in.
   - **Leia (Environment Artist)** — built for Godot environment scenes. Web games use CSS/Canvas/tilemap backgrounds.
   - **Bossk (VFX Artist)** — built for Godot particle systems. Web VFX = Canvas/CSS animations.
   - **Nien (Character Artist)** — built for FLUX character generation and Godot procedural sprites. No FLUX pipeline exists for current projects.
   - **Greedo (Sound Designer)** — *exception:* charter is already generalized. ComeRosquillas has procedural audio. KEEP active.

2. **team.md still says "Active Games: FLORA (planned — repo pending)"** — stale. ComeRosquillas is the active game. Flora repo exists.

3. **@copilot capability profile still lists "GDScript / Godot work 🟡"** — no Godot work exists anymore.

4. **now.md says "ComeRosquillas: games/comerosquillas/"** — stale path, it's now in its own repo.

### Actions

| Action | Agent | Priority |
|--------|-------|----------|
| **HIBERNATE** Boba, Leia, Bossk, Nien — move to "Hibernated" section in team.md | Solo | P0 |
| **KEEP ACTIVE** (11): Solo, Chewie, Lando, Wedge, Greedo, Tarkin, Ackbar, Yoda, Jango, Mace, Scribe + Ralph + @copilot | — | — |
| Update team.md "Active Games" to list ComeRosquillas + Flora + Squad Monitor | Solo | P0 |
| Update @copilot capability profile: remove GDScript, add HTML/JS/Canvas, TypeScript/Vite/PixiJS | Solo | P1 |
| Update now.md: remove `games/comerosquillas/` path, link to external repos correctly | Solo | P0 |
| **NO NEW ROLES NEEDED** — web stack is simpler, current 11 agents cover all domains | — | — |

### Proposed Lean Roster (11 active + 4 hibernated)

| Name | Role | Status | Why |
|------|------|--------|-----|
| Solo | Lead / Chief Architect | 🏗️ Active | Always needed |
| Chewie | Engine Dev | 🔧 Active | Game loop, renderer, engine systems (any stack) |
| Lando | Gameplay Dev | ⚔️ Active | Player mechanics, combat, game logic |
| Wedge | UI Dev | ⚛️ Active | HUD, menus, screens, web UI |
| Greedo | Sound Designer | 🔊 Active | Web Audio API, procedural sound |
| Tarkin | Enemy/Content Dev | 👾 Active | Enemy AI, content, level design |
| Ackbar | QA/Playtester | 🧪 Active | Browser testing, game feel |
| Yoda | Game Designer | 🎯 Active | Vision keeper, GDD, feature triage |
| Jango | Tool Engineer | ⚙️ Active | ralph-watch, scheduler, CI/CD, build tooling |
| Mace | Producer | 📊 Active | Sprint planning, ops, blocker management |
| Scribe | Session Logger | 📋 Active | Automatic documentation |
| Ralph | Work Monitor | 🔄 Monitor | Autonomous loop |
| @copilot | Coding Agent | 🤖 Active | Issue execution |
| Boba | Art Director | ❄️ Hibernated | Wake when art pipeline needed |
| Leia | Environment Artist | ❄️ Hibernated | Wake when environment art needed |
| Bossk | VFX Artist | ❄️ Hibernated | Wake when dedicated VFX needed |
| Nien | Character Artist | ❄️ Hibernated | Wake when character art pipeline needed |

---

## 2. FFS HUB CLEANUP AUDIT

### Current State

The hub repo still contains massive monorepo leftovers:

| Item | Size | Files | Status |
|------|------|-------|--------|
| `games/ashfall/` | **1,625 MB** | **6,071** | ❌ Godot project + .godot cache. MUST DELETE. |
| `games/first-punch/` | 394 KB | 33 | ❌ Archived Canvas game. SHOULD DELETE. |
| `tools/*.py` (12 scripts) | ~50 KB | 12 | ❌ All Godot-specific validators/generators |
| `tools/create_tool_issues.ps1` | ~5 KB | 1 | ❌ One-time script, already executed |
| `tools/pr-body.txt` | ~1 KB | 1 | ❌ One-time PR body text |
| `tools/create-pr.md` | ~2 KB | 1 | ❌ One-time PR template |
| `tools/TODO-create-issues.md` | ~2 KB | 1 | ❌ One-time task list |

**Godot-specific GitHub workflows (3):**
- `.github/workflows/godot-project-guard.yml` — watches `games/ashfall/project.godot`
- `.github/workflows/godot-release.yml` — builds Godot exports with ashfall tags
- `.github/workflows/integration-gate.yml` — GDScript linting and type checking

**Godot-specific skills (8):**
- `gdscript-godot46` — GDScript 4.6 patterns
- `godot-4-manual` — Godot 4 manual reference
- `godot-beat-em-up-patterns` — Godot fighting game patterns
- `godot-project-integration` — Godot multi-agent integration
- `godot-tooling` — Godot EditorPlugins, autoloads
- `godot-visual-testing` — Godot viewport testing
- `code-review-checklist` — GDScript-focused review
- `project-conventions` — Godot file/scene conventions

**Stale agent charters (2 heavily Godot-locked):**
- Jango's charter references `project.godot`, autoloads, GDScript conventions, EditorPlugin, `.tres`
- Solo's charter examples reference Godot scene trees, nodes, signals (patterns are generic but examples are Godot)

**Context bloat:**
- `decisions.md` = **2,341 lines, 164 KB, 161 entries** — ~70% Ashfall-specific
- `solo/history.md` = **356 lines, 38 KB** — ~60% Ashfall/firstPunch specific

### Problems

1. **games/ashfall/ is 1.6 GB** — this is the single biggest cleanup item. The .godot cache alone is massive.
2. **12 Python tools are all Godot-specific** — check-autoloads, check-signals, check-scenes, validate-project, etc. None work for web games.
3. **3 GitHub workflows will never trigger** since Godot paths and tags don't exist in the hub.
4. **8 skills are Godot-specific** but contain valuable patterns if we ever return to Godot. Should be archived, not deleted.
5. **decisions.md is dangerously bloated** at 164 KB. This wastes context tokens every session.

### Actions

| Action | Priority |
|--------|----------|
| **DELETE `games/ashfall/`** — 1.6 GB of Godot files. No game code in hub. | P0 |
| **DELETE `games/first-punch/`** — archived Canvas prototype. Already in git history. | P0 |
| **DELETE 12 Godot Python tools** from `tools/` (keep ralph-watch.ps1, scheduler/, README.md, logs/, .ralph-heartbeat.json) | P0 |
| **DELETE one-time scripts** (create_tool_issues.ps1, pr-body.txt, create-pr.md, TODO-create-issues.md) | P0 |
| **DELETE 3 Godot workflows** (godot-project-guard.yml, godot-release.yml, integration-gate.yml) | P0 |
| **ARCHIVE 8 Godot skills** → move to `.squad/skills/_archived/` (preserve knowledge) | P1 |
| **ARCHIVE Ashfall decisions** from decisions.md → decisions-archive.md (keep ~15 active decisions) | P1 |
| **RUN `squad nap --deep`** on Solo and decisions to compress context | P1 |
| Update Jango's charter for web tooling stack | P1 |
| Update Solo's charter examples for web architecture | P1 |

---

## 3. HUB PURPOSE DEFINITION

### Mission Statement

> **FirstFrameStudios is the Studio Hub** — the central nervous system for all FFS projects. It holds studio identity, shared skills, team infrastructure, and cross-project tools. No game code lives here; games inherit studio DNA via `squad upstream` and live in their own repositories.

### What SHOULD Live in the Hub

| Category | Contents |
|----------|----------|
| **Studio Identity** | `.squad/identity/` (principles, mission-vision, company, quality-gates, wisdom) |
| **Team Definition** | `.squad/team.md`, `.squad/routing.md`, `.squad/agents/` |
| **Cross-Project Skills** | `.squad/skills/` (only universal/web skills — 32 after archiving 8 Godot) |
| **Shared Tools** | `tools/ralph-watch.ps1`, `tools/scheduler/`, `tools/README.md` |
| **Docs Site** | `docs/` (Astro site deployed to GitHub Pages) |
| **Studio Decisions** | `.squad/decisions.md` (studio-level only) |
| **Hub Workflows** | `.github/workflows/` (label-sync, heartbeat, triage, deploy-pages, etc.) |
| **Repo Config** | `README.md`, `CONTRIBUTING.md`, `CODEOWNERS`, `squad.config.ts`, `.editorconfig` |

### What Should NOT Be in the Hub

| Category | Where It Belongs |
|----------|-----------------|
| Game source code | Game repos (ComeRosquillas, Flora) |
| Game-specific issues | Game repos |
| Game-specific workflows | Game repos |
| Game-specific tools | Game repos or tool repos |
| Godot projects/files | Nowhere (archived project) |
| Game-specific decisions | Game repo `.squad/decisions.md` |

### Ideal Folder Structure (Post-Cleanup)

```
FirstFrameStudios/
├── .copilot/
│   └── mcp-config.json          # MCP server configuration
├── .github/
│   ├── agents/squad.agent.md    # Copilot agent definition
│   ├── ISSUE_TEMPLATE/          # Hub issue templates
│   ├── workflows/               # Hub-level workflows only (no Godot)
│   └── pull_request_template.md
├── .squad/
│   ├── agents/                  # All 15 agent charters
│   ├── decisions/               # Inbox + archive
│   ├── identity/                # Studio identity documents
│   ├── skills/                  # Cross-project + web skills only
│   │   └── _archived/           # Godot skills preserved
│   ├── config.json
│   ├── decisions.md             # Active decisions (slim — <50 entries)
│   ├── routing.md
│   └── team.md
├── docs/                        # Astro site (GitHub Pages)
├── tools/
│   ├── ralph-watch.ps1          # v2 autonomous loop
│   ├── scheduler/               # Cron-based task scheduler
│   ├── logs/                    # Ralph structured logs
│   ├── .ralph-heartbeat.json
│   └── README.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── README.md
└── squad.config.ts
```

---

## 4. TOOLS / PLUGINS / MCP AUDIT

### Current State

| Tool | Location | Status | Notes |
|------|----------|--------|-------|
| ralph-watch.ps1 v2 | `tools/ralph-watch.ps1` | ✅ Production-ready | 401 lines, multi-repo, failure alerts, activity monitor |
| Scheduler | `tools/scheduler/` | ✅ Operational | 4 recurring tasks defined (playtest, retro, grooming, browser compat) |
| Squad Monitor | jperezdelreal/ffs-squad-monitor | ⚠️ Repo exists, scaffold only | 5 open issues, Vite+JS stack |
| 12 Python scripts | `tools/*.py` | ❌ All Godot-specific | Should be deleted |
| Astro docs site | `docs/` | ✅ Deployed | GitHub Pages active |

**MCP Configuration (`.copilot/mcp-config.json`):**
```json
{
  "mcpServers": {
    "EXAMPLE-trello": { ... }  // ← Not configured, just an example
  }
}
```
**Problem:** MCP is not actually configured. Just a Trello example placeholder.

### What Tamir Has That We Don't

| Pattern | Tamir | FFS | Gap |
|---------|-------|-----|-----|
| ralph-watch outer loop | ✅ | ✅ | Parity |
| Self-built scheduler | ✅ | ✅ | Parity |
| Squad Monitor dashboard | ✅ (dotnet tool) | ⚠️ (Vite scaffold) | Implementation gap |
| Teams/Discord webhooks | ✅ (Adaptive Cards) | ❌ | Missing entirely |
| Podcaster (Edge TTS) | ✅ | ❌ | Nice to have |
| Email/Teams scanning | ✅ (Outlook COM) | ❌ | Overkill for us |
| CLI Tunnel | ✅ | ❌ | Not needed |
| GitHub Actions ecosystem | ✅ (12+ workflows) | ✅ (22 workflows) | We have MORE |
| Cross-repo contributions | ✅ | ❌ | Future opportunity |

### Actions

| Action | Priority |
|--------|----------|
| **DELETE 12 Godot Python scripts** from tools/ | P0 |
| **Configure MCP properly** — remove Trello example, add useful servers (GitHub, or leave empty) | P1 |
| **Add Discord webhook** for critical notifications (CI failures, PR merges, P0 issues) | P1 |
| **Build out ffs-squad-monitor** — the scaffold exists, 5 issues are filed | P2 |
| **Evaluate Podcaster** — useful for Joaquín consuming long reports | P2 |
| **Skip:** Email scanning (we don't use email), CLI Tunnel (not needed) | — |

---

## 5. ROUTING TABLE UPDATE

### Current State

routing.md has these stale references:
- **Jango row:** "EditorPlugins, scene templates, GDScript style guide, build/export automation, project.godot config, linting, asset pipelines"
- **Solo row:** "scene tree conventions"
- **Integration gates:** "After every parallel agent wave — verify systems connect, signals wired, project loads"
- **Post-merge smoke test:** "open Godot, run full game flow, verify end-to-end"
- **No multi-repo routing** — doesn't say which issues go where
- **No web tech routing** — no mention of HTML, Canvas, PixiJS, Vite, TypeScript

### Problems

1. Routing still assumes a single Godot project
2. No guidance for multi-repo issue triage
3. Web technology work types not represented
4. @copilot capability profile references Godot

### Actions

| Action | Priority |
|--------|----------|
| **Rewrite routing table** for web game stack | P0 |
| **Add multi-repo routing section** (which issues go where) | P0 |
| **Update integration gates** for browser-based testing | P1 |
| **Update @copilot capability profile** | P1 |

### Proposed Routing Table

```markdown
## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Game engine, loop, timing, systems | Chewie | Game loop, renderer, input, animation system, physics, collision |
| Player mechanics, combat, abilities | Lando | Player entity, combat system, special moves, player state machine |
| Enemy AI, content, levels, pickups | Tarkin | Enemy types, boss patterns, wave/level design, pickups, difficulty |
| UI, HUD, menus, screens, web layout | Wedge | HUD, title screen, game over, pause, score displays, CSS/HTML |
| Audio, SFX, music, sound design | Greedo | Sound effects, procedural music, Web Audio API, audio events |
| QA, playtesting, balance, browser testing | Ackbar | Playtesting, combat feel, cross-browser, regression, edge cases |
| Tooling, CI/CD, workflows, build pipelines | Jango | GitHub workflows, ralph-watch, scheduler, build automation |
| Architecture, integration review | Solo | Project structure, integration verification, decisions, architecture |
| Ops, blockers, branch management | Mace | Blocker tracking, branch rebasing, stale issue cleanup |
| Sprint planning, timelines, workload | Mace | Sprint planning, milestone tracking, scope management |
| Feature triage, scope decisions | Yoda + Mace | Vision Keeper evaluates features against four-test framework |
| Async issue work (bugs, tests, features) | @copilot 🤖 | Well-defined tasks: HTML/JS/Canvas, TypeScript, Vite, PixiJS |

## Multi-Repo Issue Routing

| Issue About | Goes To | Examples |
|-------------|---------|----------|
| ComeRosquillas gameplay/bugs | jperezdelreal/ComeRosquillas | Ghost AI, scoring, maze layout, mobile controls |
| Flora gameplay/bugs | jperezdelreal/flora | PixiJS systems, gardening mechanics, roguelite features |
| Squad Monitor features | jperezdelreal/ffs-squad-monitor | Dashboard UI, heartbeat reader, log viewer |
| Studio infra / tooling | jperezdelreal/FirstFrameStudios | ralph-watch, scheduler, team changes, docs site |
| Cross-project process | jperezdelreal/FirstFrameStudios | Ceremonies, skills, team decisions, routing |
```

---

## 6. SKILLS AUDIT

### Current State

41 skills in `.squad/skills/`. Classified:

| Classification | Count | Skills |
|----------------|-------|--------|
| **GODOT-SPECIFIC** | 8 | gdscript-godot46, godot-4-manual, godot-beat-em-up-patterns, godot-project-integration, godot-tooling, godot-visual-testing, code-review-checklist, project-conventions |
| **WEB-GAME** | 5 | 2d-game-art, canvas-2d-optimization, game-engine-web, procedural-audio, web-game-engine |
| **CROSS-PROJECT** | 28 | animation-for-games, beat-em-up-combat, context-map, conventional-commit, create-technical-spike, enemy-encounter-design, feature-triage, fighting-game-design, game-audio-design, game-design-fundamentals, game-feel-juice, game-qa-testing, github-issues, github-pr-workflow, input-handling, integration-discipline, level-design-fundamentals, milestone-completion-checklist, multi-agent-coordination, parallel-agent-workflow, prd, refactor-plan, skill-creator, squad-conventions, state-machine-patterns, studio-craft, ui-ux-patterns, what-context-needed |

### Problems

1. **8 Godot skills waste context** when loaded by agents working on web games
2. **No PixiJS skill** exists for Flora (Vite + TypeScript + PixiJS)
3. **No web deployment skill** (GitHub Pages, itch.io, Netlify)
4. **canvas-2d-optimization and web-game-engine overlap** — previous audit recommended merging
5. **code-review-checklist is Godot-locked** — should have a web version

### Actions

| Action | Priority |
|--------|----------|
| **ARCHIVE 8 Godot skills** → `.squad/skills/_archived/` | P1 |
| **CREATE `web-code-review`** — HTML/JS/TS review checklist replacing Godot-focused one | P1 |
| **CREATE `pixijs-patterns`** — PixiJS game patterns for Flora (when Flora activates) | P2 |
| **CREATE `web-game-deployment`** — GitHub Pages, itch.io, Netlify deployment patterns | P2 |
| **MERGE** canvas-2d-optimization into web-game-engine (redundant overlap) | P2 |
| **KEEP ALL 28 cross-project skills** — these are the studio's institutional knowledge | — |
| **KEEP ALL 5 web-game skills** — directly relevant to current projects | — |

---

## 7. DECISIONS CLEANUP

### Current State

`decisions.md`: **2,341 lines, 164 KB, ~161 decision entries**

This is dangerously bloated. Context tokens are wasted loading Ashfall-specific decisions that will never be referenced again.

### Classification

**ARCHIVE (Ashfall/firstPunch-specific, ~30+ entries):**
- Cel-Shade Parameters (Boba)
- Cel-Shade Pipeline Standardization (Chewie)
- Ashfall GDD v1.0 (Yoda)
- Ashfall Architecture (Solo)
- Sprint 0 Scope & Milestones (Mace)
- All Sprint 0 Closure Decisions (M4 gate, Combat fix, Draw state, HUD sync)
- Procedural Sprite System (Nien)
- Sprite Brief v3 (Boba)
- Asset Naming Convention (Ashfall-specific)
- FLUX decisions (3 entries)
- Sprint 1 Bug Catalog
- Jango M1+M2 Retrospective
- Sprint Definition of Success (Ashfall context)
- Game Architecture — McManus/firstPunch
- Core Gameplay Bug Fixes — firstPunch
- Full Codebase Analysis — firstPunch
- All Ashfall user directives (game type pivot, 1080p, FLUX for stages/HUD)
- P0 Combat Pipeline Integration Fix (Lando)
- Equal-HP Draw State (Chewie)
- HUD Score Sync Architecture (Wedge)
- Sprint 0 Milestone Status (Mace)
- Game Resolution 1080p directive
- Sprite Animation Consistency Research (Solo)

**KEEP (studio-level, multi-project, ~15 entries):**
- ffs-squad-monitor creation ✅
- Squad Upstream Setup — ComeRosquillas ✅
- Tamir Blog Learnings (16 operational patterns) ✅
- Side Project Repo Autonomy directive ✅
- Visual Quality Standard directive ✅
- Ashfall Closure (historical reference) ✅
- Solo Role Split (process improvement) ✅
- Autonomy Gap Audit ✅
- ComeRosquillas Infrastructure Pivot ✅
- New Project Proposals Ceremony ✅
- Documentation & Terminology Clarity ✅
- Option C Hybrid Architecture ✅
- Tool & Skill Development Autonomy ✅
- Team Expansion (historical) ✅
- New Project Playbook (studio-level) ✅

### Problems

1. **164 KB is ~5x the recommended size** for a decisions file
2. Most entries are Ashfall-specific and will never be referenced
3. Context tokens wasted loading this in every session
4. New agents get confused by Godot-specific decisions when working on web games

### Actions

| Action | Priority |
|--------|----------|
| **MASS ARCHIVE** Ashfall/firstPunch decisions → `decisions-archive.md` | P0 |
| **KEEP ~15 active decisions** in decisions.md (studio-level only) | P0 |
| **Target: decisions.md under 30 KB** after cleanup | P0 |
| **Run `squad nap --deep`** on history files | P1 |

---

## SUMMARY: TOP 10 ACTIONS BY PRIORITY

| # | Action | Priority | Impact | Owner |
|---|--------|----------|--------|-------|
| 1 | **DELETE `games/ashfall/`** (1.6 GB, 6071 files) | P0 | Removes 99% of repo bloat. Hub should have zero game code. | Jango |
| 2 | **DELETE `games/first-punch/`** (33 files) | P0 | Complete the hub cleanup. Git history preserves everything. | Jango |
| 3 | **ARCHIVE Ashfall decisions** from decisions.md → decisions-archive.md. Target <30 KB active. | P0 | Stops wasting context tokens. Every session loads this file. | Solo |
| 4 | **DELETE 12 Godot Python tools + 3 Godot workflows** from hub | P0 | Removes confusing dead code. Only ralph-watch/scheduler should remain. | Jango |
| 5 | **UPDATE team.md** — hibernate Boba/Leia/Bossk/Nien, update project context | P0 | Prevents agents from routing work to hibernated roles. | Solo |
| 6 | **UPDATE now.md** — fix stale ComeRosquillas path, update status accurately | P0 | Every session reads this first. Must be correct. | Solo |
| 7 | **REWRITE routing.md** for web game stack + multi-repo routing | P0 | Agents need to know where to send work across 4 repos. | Solo |
| 8 | **ARCHIVE 8 Godot skills** → `.squad/skills/_archived/` | P1 | Preserves knowledge while keeping active skills relevant. | Jango |
| 9 | **UPDATE Jango + Solo charters** — remove Godot references | P1 | Charters guide agent behavior. Must match current stack. | Solo |
| 10 | **Configure Discord webhook** for critical notifications | P1 | Highest-leverage unbuilt feature. Joaquín needs proactive alerts. | Jango |

### Quick Wins (bonus — can be done alongside the top 10):
- Delete one-time scripts from tools/ (pr-body.txt, create-pr.md, etc.)
- Fix MCP config (remove Trello example or add real servers)
- Update @copilot capability profile in team.md
- Merge canvas-2d-optimization into web-game-engine skill

---

## Estimated Effort

| Priority | Items | Effort |
|----------|-------|--------|
| P0 (do now) | 7 items | ~2-3 hours (mostly deletions and rewrites) |
| P1 (this week) | 3 items | ~3-4 hours (archives, charter updates, webhook) |
| P2 (nice to have) | 5 items | ~8 hours (new skills, monitor build-out, podcaster eval) |

---

## Approval

Joaquín — please review and approve/modify. Upon approval, Solo will orchestrate execution:
1. Jango handles deletions (games/, tools/, workflows/)
2. Solo handles rewrites (team.md, routing.md, now.md, decisions archival)
3. Both run in parallel for maximum speed

**This ceremony output lives at:** `.squad/decisions/inbox/solo-studio-restructure-ceremony.md`

---

*Prepared by Solo (Lead / Chief Architect) — 2026-07-24*
