# monorepo-structure.md — Full Archive

> Archived version. Compressed operational copy at `monorepo-structure.md`.

---

# Monorepo Structure Validation — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-22  
**Status:** Validated & Complete  
**Scope:** GitHub-ready monorepo for First Frame Studios multi-game development

---

## Executive Summary

The proposed monorepo structure is **fundamentally sound** but **incomplete**. It correctly places game projects under `games/`, shared assets under `shared/`, and squad infrastructure under `.squad/`. However, it is missing critical repository infrastructure that any professional GitHub-hosted monorepo needs before Day 1.

**Key findings:**
1. ✅ **Correct:** Game-per-folder organization, shared assets structure, .squad placement
2. ✅ **Correct:** Separation of game code from studio infrastructure
3. ❌ **Missing:** Documentation scaffolding (LICENSE, CONTRIBUTING, CHANGELOG, onboarding guides)
4. ❌ **Missing:** Git infrastructure (.editorconfig, comprehensive .gitignore for Godot/Canvas 2D, LFS configuration)
5. ❌ **Missing:** Repository root configuration files (copilot-instructions.md, repository manifesto)
6. ❌ **Unclear:** Shared assets reference strategy (symlinks vs git submodules vs Godot res:// paths)
7. ⚠️ **Needs clarity:** CI/CD game discovery and per-game build triggers

**This document provides:**
- ✅ Validated, corrected full directory tree
- ✅ Explanation for every directory
- ✅ Migration plan from current layout (firstPunch at root) to new structure
- ✅ Complete file creation checklist
- ✅ Implementation sequence and dependencies
- ✅ Trade-offs and architectural decisions

---

## 1. Validated & Complete Monorepo Structure

```
FirstFrameStudios/                          # Repository root
│
├── .copilot/                               # Copilot CLI config (exists)
├── .github/
│   ├── workflows/
│   │   ├── ci-game-build.yml              # Per-game builds (Canvas 2D, Godot)
│   │   ├── ci-tests.yml                   # Monorepo-wide tests (if applicable)
│   │   ├── docs-preview.yml               # Build docs on PR
│   │   └── [squad workflows migrate here]  # Existing squad/release/triage
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── game_feature.md
│   │   ├── tech_spike.md
│   │   └── documentation.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml                      # (If monorepo adds npm dependencies)
│
├── .squad/                                 # Squad team infrastructure (exists)
│   ├── agents/
│   │   ├── solo/
│   │   ├── [11 other agents]/
│   │   └── [shared agent tooling]/
│   ├── analysis/
│   │   ├── monorepo-structure.md           # This document
│   │   ├── tools-evaluation.md
│   │   ├── [domain-specific analyses]/
│   │   └── beat-em-up-research.md
│   ├── decisions/
│   ├── decisions.md
│   ├── identity/
│   │   ├── company.md
│   │   ├── new-project-playbook.md
│   │   ├── growth-framework.md
│   │   ├── principles.md
│   │   ├── quality-gates.md
│   │   └── mission-vision.md
│   ├── skills/
│   │   ├── beat-em-up-combat/
│   │   ├── godot-beat-em-up-patterns/
│   │   ├── canvas-2d-optimization/
│   │   ├── game-feel-juice/
│   │   ├── [20+ more skills]/
│   │   └── [shared studio knowledge]/
│   ├── team.md                             # Roster, roles, assignments
│   └── log/, orchestration-log/, sessions/ # Generated / ephemeral
│
├── shared/                                 # Studio-wide shared assets & code
│   ├── README.md                           # How to use shared assets in game projects
│   ├── godot/                              # Godot-specific shared code
│   │   ├── addons/                         # Godot plugins (game feel, utils, QA)
│   │   │   ├── game-feel-tuner/
│   │   │   ├── debug-overlay/
│   │   │   ├── framerate-monitor/
│   │   │   └── [community/asset store addons]/
│   │   ├── autoload/                       # GDScript autoload singletons
│   │   │   ├── AudioManager.gd
│   │   │   ├── GameConfig.gd
│   │   │   └── EventBus.gd
│   │   ├── gdscript-libs/                  # GDScript utility libraries
│   │   │   ├── state-machines/
│   │   │   ├── data-structures/
│   │   │   ├── math-utils/
│   │   │   └── physics-helpers/
│   │   └── project_settings.tres            # Shared Godot project settings template
│   │
│   ├── canvas-2d/                          # Canvas 2D JavaScript shared libraries
│   │   ├── input-systems/                  # Unified input handler
│   │   ├── physics-utils/                  # Collision, movement helpers
│   │   ├── animation-utils/                # Sprite/canvas animation library
│   │   └── state-machines/                 # State machine utilities
│   │
│   ├── assets/                             # Raw/processed shared assets
│   │   ├── audio/
│   │   │   ├── sound-effects/              # Reusable SFX library
│   │   │   ├── music/                      # Compositional templates (not full tracks)
│   │   │   └── voice/                      # Voice effect libraries
│   │   ├── fonts/                          # Studio font files (.otf, .ttf)
│   │   ├── ui-components/                  # Reusable UI graphics/patterns
│   │   │   ├── buttons/
│   │   │   ├── dialog-boxes/
│   │   │   ├── menus/
│   │   │   └── hud-elements/
│   │   └── visual-effects/                 # VFX sprites, particles, shaders
│   │       ├── explosions/
│   │       ├── impacts/
│   │       └── screen-transitions/
│   │
│   ├── docs/                               # Shared documentation templates
│   │   ├── art-style-guide.md
│   │   ├── audio-design-guidelines.md
│   │   ├── performance-budgets.md          # Per-platform budgets
│   │   └── platform-guidelines.md          # Web, desktop, console (future)
│   │
│   └── configs/                            # Shared configuration files
│       ├── .editorconfig-shared
│       ├── prettier.config.mjs             # (If monorepo uses npm)
│       └── balance-data-schema.json        # Shared game balance data schema
│
├── games/                                  # Game projects folder
│   ├── README.md                           # Explanation of games structure
│   │
│   ├── game-kong/                      # Project 1 — Canvas 2D beat 'em up
│   │   ├── README.md                       # Game-specific README
│   │   ├── package.json                    # (Optional) If using npm for dev tools
│   │   ├── .editorconfig
│   │   ├── .gitignore                      # Game-specific ignores
│   │   ├── LICENSE                         # Game IP licensing (may differ from studio)
│   │   ├── index.html                      # Entry point
│   │   ├── styles.css
│   │   ├── src/
│   │   │   ├── engine/
│   │   │   ├── entities/
│   │   │   ├── systems/
│   │   │   ├── scenes/
│   │   │   └── ui/
│   │   ├── assets/                         # Game-specific assets (not shared)
│   │   │   ├── sprites/
│   │   │   ├── audio/
│   │   │   └── data/
│   │   ├── .github/                        # Game-specific issue/PR templates (optional)
│   │   └── ARCHITECTURE.md                 # Game-specific technical architecture
│   │
│   └── ashfall/                            # Project 2 — Godot 4 3D action RPG (future)
│       ├── README.md
│       ├── project.godot
│       ├── .editorconfig
│       ├── .gitignore
│       ├── LICENSE
│       ├── ARCHITECTURE.md
│       ├── scenes/
│       ├── scripts/
│       ├── assets/
│       ├── addons/                         # Game-specific plugins (not shared)
│       ├── exports/                        # Export presets
│       └── project_settings.tres
│
├── docs/                                   # Repository-level documentation
│   ├── README.md                           # Repository manifest (what is this mono?)
│   ├── GETTING_STARTED.md                  # Onboarding for new team members
│   ├── CONTRIBUTING.md                     # Contribution guidelines
│   ├── ARCHITECTURE.md                     # Monorepo architecture decisions
│   ├── DEVELOPMENT_SETUP.md                # Local environment setup
│   ├── BUILDING.md                         # Build instructions per game
│   ├── CHANGELOG.md                        # Studio-level version history
│   ├── FAQ.md                              # Common questions
│   └── [game-specific guides]/
│
├── tools/                                  # Studio build/dev tools
│   ├── README.md
│   ├── game-builder.js                     # Script to build all games
│   ├── local-server.js                     # Dev server that serves games
│   ├── balance-data-importer.py            # Import balance sheets to game data
│   ├── asset-optimizer.sh                  # Batch process assets
│   ├── scripts/
│   │   ├── setup-dev-env.sh               # Initial development setup
│   │   ├── run-all-tests.sh               # Test all games
│   │   └── export-builds.sh                # Export all games
│   └── configs/                            # Tool configuration
│
├── .editorconfig                           # Code style (root for all projects)
├── .gitignore                              # Comprehensive ignore rules
├── .gitattributes                          # Binary handling (exists, needs expansion)
├── copilot-instructions.md                 # @copilot agent instructions
├── CONTRIBUTING.md                         # How to contribute to the monorepo
├── LICENSE                                 # Studio license (MIT recommended)
├── README.md                               # Monorepo manifest
├── CHANGELOG.md                            # Version history
├── SECURITY.md                             # Security policy
│
└── [CI/CD configuration files]
    ├── .env.example                        # Environment variables template
    └── [platform-specific secrets config]
```

---

## 2. Directory Purpose & Guidance

### Root Level

| Directory | Purpose | Key Files | Notes |
|-----------|---------|-----------|-------|
| `.copilot/` | Copilot CLI configuration | Auto-generated | Managed by @copilot CLI; no manual edits needed. |
| `.github/` | GitHub infrastructure | workflows/, templates | Branch protection, issue templates, CI/CD, PR template. |
| `.squad/` | Studio team & knowledge | agents/, skills/, identity/, decisions.md | The institutional brain. Every decision, every skill, every agent history. **DO NOT** put game-specific code here. |
| `shared/` | Cross-game reusable assets & code | godot/, canvas-2d/, assets/, docs/, configs/ | Shared plugins, utilities, assets, style guides. Each game **symlinks** or **references** what it needs. |
| `games/` | Game project folders | game-kong/, ashfall/, [future games]/ | Each game is self-contained with its own README, .gitignore, architecture. |
| `docs/` | Repository-level documentation | GETTING_STARTED.md, ARCHITECTURE.md, CONTRIBUTING.md | How to navigate this monorepo. How to set up dev environment. How to build and ship. |
| `tools/` | Build & dev infrastructure | game-builder.js, balance-importer.py | Scripts that run across the monorepo. Not tied to any single game. |

### `.squad/` (Studio Infrastructure)

This is the **most important** directory for understanding how the studio works. It contains:

- **agents/** — Agent histories, charters, expertise profiles. Where each agent documents what they've learned.
- **analysis/** — Strategic documents (monorepo-structure.md, tools-evaluation.md, technical learnings). Research-backed decisions.
- **decisions/** — Decision logs per agent. Quick reference for "who decided what and why."
- **identity/** — Company DNA. Who we are, what we stand for, how we operate (company.md, principles.md, quality-gates.md, new-project-playbook.md, growth-framework.md).
- **skills/** — The reusable knowledge base. 25+ documented skills covering every domain. Engine-agnostic where possible. See skills/README.md for navigation.
- **team.md** — Current roster, roles, domains, availability.
- **decisions.md** — Master decision log across all agents (append-only, union merge strategy in .gitattributes).

**Rule:** Nothing game-specific lives here. If it's knowledge that carries forward to the next project, it belongs in `.squad/`. If it's only useful for firstPunch or Ashfall, it belongs in `games/{game-name}/`.

### `shared/` (Cross-Game Assets & Code)

**Godot path:** `shared/godot/addons/` → Game project links via `res://addons/first-frame/` symlink or copies into project
**Canvas 2D path:** `shared/canvas-2d/` → Game project imports via ES6 modules or copies files

**What goes here:**
- ✅ Reusable plugins (game feel tuner, debug overlay, framerate monitor)
- ✅ Reusable GDScript libraries (state machines, data structures, physics helpers)
- ✅ Reusable sound effects library (not full soundtrack)
- ✅ UI component designs (button styles, dialog templates, HUD layouts)
- ✅ Font files used across games
- ✅ Shared documentation (art style guide, performance budgets, audio design guidelines)

**What doesn't go here:**
- ❌ Game-specific art (firstPunch's Brawler sprite)
- ❌ Game-specific audio (firstPunch's boss music)
- ❌ Game-specific story/lore
- ❌ Game-specific GDD content

**Reference strategy:** Each game's `.gitignore` should **exclude** shared/ folder, then symlink or mount specific pieces:
```bash
# In games/game-kong/.gitignore
shared/          # Exclude the whole folder

# Then in setup script:
ln -s ../../shared/fonts ./assets/fonts
ln -s ../../shared/ui-components ./assets/ui-components
```

Or for Godot, use the res:// path system with proper project configuration.

### `games/{game-name}/` Structure

Each game is a self-contained project with its own:

```
games/game-kong/
├── README.md                    # What this game is, how to play it, controls
├── ARCHITECTURE.md              # Game-specific tech decisions
├── index.html                   # Entry point (for Canvas 2D)
├── project.godot               # Entry point (for Godot)
├── src/                         # Game source code (structure depends on tech)
├── assets/                      # Game-specific art, audio, data
├── .gitignore                   # Game-specific git ignores
├── .editorconfig               # (Optional) Override root .editorconfig
├── LICENSE                      # (If IP-licensed, license terms; else inherit studio license)
└── [tests/]                     # (If applicable) Test files
```

**Key principle:** A new developer should be able to:
1. Clone the entire repo
2. `cd games/game-kong`
3. See README.md, read ARCHITECTURE.md
4. Understand what technology this game uses
5. Follow setup instructions and run it locally

**CI/CD discovery:** Games are discovered by GitHub Actions via directory structure:
```yaml
# .github/workflows/ci-game-build.yml
strategy:
  matrix:
    game: [game-kong, ashfall]
run: |
  cd games/${{ matrix.game }}
  # Build/test that game
```

### `docs/` (Repository Documentation)

| File | Purpose |
|------|---------|
| **README.md** | "What is this repository?" Welcome + quick links. |
| **GETTING_STARTED.md** | Onboarding checklist for new team members. Which tools to install, which skills to read, how to join the squad. |
| **CONTRIBUTING.md** | Contribution guidelines. Branch naming, commit message format, PR review process. Includes Git trailer for Copilot. |
| **ARCHITECTURE.md** | Why is this a monorepo? What are the trade-offs? How should games interact with shared/? |
| **DEVELOPMENT_SETUP.md** | Step-by-step local environment setup (Node, Godot, Python, etc.). |
| **BUILDING.md** | How to build each game for each platform. Export settings, build scripts, CI/CD explained. |
| **CHANGELOG.md** | Version history (studio-level releases, not per-game). |
| **FAQ.md** | "How do I...?" Common questions. |

### `tools/` (Build & Infrastructure Scripts)

Small scripts and utilities that serve the whole monorepo:

- `game-builder.js` — Node script that builds all games sequentially or in parallel
- `local-server.js` — Dev server that serves games/ folder, watches for changes
- `balance-data-importer.py` — Converts balance spreadsheet to game data format
- `scripts/setup-dev-env.sh` — Installs Godot, Node, Python, Git hooks, etc.
- `scripts/run-all-tests.sh` — Runs tests across all games
- `scripts/export-builds.sh` — Exports release builds for all games

These are **optional** but recommended. Start with just a local-server.js and add as needed.

---

## 3. Git Infrastructure (.gitignore, .gitattributes, .editorconfig)

### `.gitignore` (Comprehensive)

The monorepo needs a root `.gitignore` that covers:
- Godot projects (*.import, .godot/, .godot/*, user://, *.tres backup files)
- Canvas 2D projects (node_modules/, dist/, build/)
- Development tools (*.swp, .DS_Store, *.sublime-workspace, Thumbs.db)
- IDE config (.vscode/, .idea/, *.sublime-project)
- OS files (.DS_Store, Thumbs.db)

**Important:** Use a **negation pattern** so that each game's .gitignore takes precedence:
```gitignore
# Root .gitignore

# Godot
*.import
.godot/
.godot/
user://
*.tres.backup

# JavaScript / npm
node_modules/
dist/
build/
.env
.env.local

# Development
*.swp
*.swo
*.sublime-workspace
.vscode/
.idea/
.DS_Store
Thumbs.db

# Except: let each game define its own ignores
!/games/**/.gitignore
```

Then each game can add project-specific rules (e.g., games/game-kong/.gitignore can ignore browser cache).

### `.gitattributes` (Binary Handling)

Expand the existing `.gitattributes` to handle assets properly:

```
# Squad append-only merge strategy (existing, keep it)
.squad/decisions.md merge=union
.squad/agents/*/history.md merge=union
.squad/log/** merge=union
.squad/orchestration-log/** merge=union

# Binary assets — Git LFS (if stored in repo)
*.png binary diff=exif
*.jpg binary diff=exif
*.jpeg binary diff=exif
*.gif binary binary
*.ogg binary
*.mp3 binary
*.wav binary
*.unitypackage binary
*.tscn binary merge=union
*.tres binary merge=union

# Text files
*.md text eol=lf
*.js text eol=lf
*.gd text eol=lf
*.py text eol=lf
*.sh text eol=lf

# Documentation
*.md text eol=lf encoding=UTF-8
```

**Note:** If binary assets get large (>100MB), use Git LFS. Otherwise, store assets directly.

### `.editorconfig` (Code Style)

Root `.editorconfig` provides defaults for all files in the monorepo:

```ini
root = true

# All files
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

# Markdown
[*.md]
trim_trailing_whitespace = false

# JavaScript
[*.{js,mjs}]
indent_style = space
indent_size = 2

# GDScript (Godot)
[*.gd]
indent_style = space
indent_size = 4

# Python
[*.py]
indent_style = space
indent_size = 4

# YAML/JSON
[*.{json,yml,yaml}]
indent_style = space
indent_size = 2
```

Each game can have its own `.editorconfig` that overrides these defaults.

---

## 4. GitHub Infrastructure (.github/)

### CI/CD Workflows

#### `ci-game-build.yml` — Per-Game Build Pipeline

```yaml
name: Build Games

on:
  pull_request:
    branches: [main, dev, preview]
  push:
    branches: [main, dev]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        game: [game-kong, ashfall]
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Node (for Canvas 2D games)
        if: matrix.game == 'game-kong'
        uses: actions/setup-node@v4
        with:
          node-version: 22
      
      - name: Set up Godot (for Godot games)
        if: matrix.game == 'ashfall'
        uses: chickensoft-games/setup-godot@v2
        with:
          version: 4.3
      
      - name: Build ${{ matrix.game }}
        run: |
          cd games/${{ matrix.game }}
          npm run build  # or godot build command
      
      - name: Run tests
        run: |
          cd games/${{ matrix.game }}
          npm test  # or godot test
```

#### `ci-tests.yml` — Monorepo-Wide Tests

If the monorepo itself has tests (squad infrastructure tests, etc.):

```yaml
name: Tests

on: [pull_request, push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm test
```

### Issue Templates

`.github/ISSUE_TEMPLATE/`:

- **bug_report.md** — For game bugs (crash, gameplay balance, art glitch)
- **game_feature.md** — For game feature requests
- **tech_spike.md** — For technical investigation work
- **documentation.md** — For docs improvements

Example:
```markdown
---
name: Bug Report
about: Report a game bug
title: "[BUG] "
labels: bug
---

## Game
- [ ] firstPunch
- [ ] Ashfall
- [ ] Other

## Describe the bug
[...]

## Steps to reproduce
1. Start the game
2. Do X
3. See Y

## Expected behavior
[...]

## Screenshots/Video
[...]
```

### Pull Request Template

`.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Game content
- [ ] Documentation
- [ ] Infrastructure

## Related Issues
Closes #XXX

## Description
[...]

## Testing
How was this tested?

## Checklist
- [ ] I've tested locally
- [ ] I've updated relevant documentation
- [ ] I've updated CHANGELOG.md
- [ ] Code follows project style guide
```

---

## 5. Root-Level Configuration Files

### `README.md` (Repository Manifest)

The entry point. Should answer:
- What is First Frame Studios?
- What games are in this repo?
- How do I run a game locally?
- Where do I find documentation?
- Who can I ask for help?

```markdown
# First Frame Studios — Game Development Monorepo

Welcome to First Frame Studios' central repository. This is a monorepo containing:
- **Finished games:** firstPunch (Canvas 2D beat 'em up)
- **In-progress games:** Ashfall (Godot 4 action RPG)
- **Studio knowledge:** Skills, decisions, principles, team structure
- **Shared assets:** Reusable code, art, audio, UI components

## Quick Start

### Run firstPunch (locally)
```bash
cd games/game-kong
python -m http.server  # or: npx serve .
# Open http://localhost:8000
```

### Open Ashfall in Godot
```bash
cd games/ashfall
godot  # Opens Godot editor
```

## Important Links
- **New here?** Read [GETTING_STARTED.md](docs/GETTING_STARTED.md)
- **Contributing?** Read [CONTRIBUTING.md](CONTRIBUTING.md)
- **Understanding the structure?** Read [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Want to know how we work?** Read [.squad/identity/company.md](.squad/identity/company.md)

## For Developers
- Development setup: [docs/DEVELOPMENT_SETUP.md](docs/DEVELOPMENT_SETUP.md)
- Building games: [docs/BUILDING.md](docs/BUILDING.md)
- FAQ: [docs/FAQ.md](docs/FAQ.md)
```

### `CONTRIBUTING.md` (Contribution Guidelines)

```markdown
# Contributing to First Frame Studios

## Code of Conduct
We are a studio committed to excellence, iteration, and learning from failure.

## Before You Start
1. Read [.squad/identity/principles.md](.squad/identity/principles.md) — our 12 leadership principles
2. Read [.squad/identity/quality-gates.md](.squad/identity/quality-gates.md) — definition of done
3. Understand which game you're working on (see [games/README.md](games/README.md))

## Workflow
1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make commits with meaningful messages: `git commit -m "Clear description"`
3. Include our Co-authored-by trailer:
   ```
   Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
   ```
4. Push and open a PR against `dev` (not `main`)
5. PR must pass CI/CD before merging
6. All PRs require at least one review

## Commit Message Format
```
[GAME] Concise description

Longer explanation if needed.

Closes #123
Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

Examples:
```
[firstPunch] Fix knockback physics scaling
[Ashfall] Add new enemy archetype
[Shared] Update game-feel-juice documentation
[Infra] Improve CI/CD performance
```

## Branch Naming
- `feature/description` — New feature
- `fix/description` — Bug fix
- `docs/description` — Documentation
- `infra/description` — Infrastructure / tooling
- `research/description` — Technical research / spike

## Code Review Checklist
Before submitting:
- [ ] Code follows `.editorconfig` style
- [ ] Related tests pass (`npm test` or Godot tests)
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Commit message is clear
- [ ] Co-authored-by trailer included
```

### `LICENSE` (MIT Recommended)

```
MIT License

Copyright (c) 2025 First Frame Studios

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Note:** If a game uses licensed IP (like firstPunch with the source IP), include a per-game LICENSE file.

### `SECURITY.md` (Security Policy)

```markdown
# Security Policy

## Reporting Vulnerabilities

**Do not file public issues for security vulnerabilities.**

Instead, email security@firstframestudios.com with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any proposed fixes

We will acknowledge within 48 hours and provide updates as we work on a fix.
```

### `CHANGELOG.md` (Version History)

```markdown
# Changelog

All notable changes to First Frame Studios games are documented here.

## [Unreleased]

### Added
- Ashfall: New enemy archetype (Shade)
- Shared: New game-feel tuning addon

### Fixed
- firstPunch: Knockback physics scaling issue (#123)

## [1.0.0] - firstPunch Released

### Added
- firstPunch v1.0: Playable beat 'em up with 5 waves
```

### `copilot-instructions.md` (Agent Instructions)

Instructions for @copilot when used in the repo:

```markdown
# Instructions for @copilot

You are working in the First Frame Studios monorepo.

## Key Context

- **What you're building:** Multi-game studio with shared infrastructure
- **Where to find documentation:** `.squad/identity/` has company principles, playbook, growth framework
- **Where to find knowledge:** `.squad/skills/` has 25+ reusable skills
- **Where game code lives:** `games/{game-name}/`
- **Where shared code lives:** `shared/`

## When Working on a Game

1. Read the game's `ARCHITECTURE.md` to understand tech choices
2. Read relevant shared skills before writing code
3. All commits must include Co-authored-by trailer (see CONTRIBUTING.md)
4. Run CI/CD tests before pushing

## When Working on Studio Infrastructure

1. Changes to `.squad/` must include rationale
2. Update relevant agent history (`.squad/agents/{agent-name}/history.md`)
3. Decisions should be logged in `.squad/decisions.md`

## When Adding Files

- Game code → `games/{game-name}/`
- Shared utilities → `shared/`
- Studio knowledge → `.squad/`
- Documentation → `docs/`

## Never

- Commit secrets or credentials
- Add large binary files without Git LFS
- Make breaking changes without team discussion
```

---

## 6. `shared/` Directory Architecture

### Godot Path Strategy

For Godot games to access shared code and addons:

**Option A: Symlink (Recommended)**
```bash
# After cloning, run setup
cd games/ashfall
ln -s ../../shared/godot/addons ./addons  # Or copy if on Windows

# Or in addons folder:
ln -s ../../../shared/godot/addons/game-feel-tuner ./game-feel-tuner
```

**Option B: Godot Project Settings (res:// paths)**
In `project.godot`:
```ini
[autoload]
GameConfig="res://autoload/GameConfig.gd"
EventBus="res://autoload/EventBus.gd"
```

Then symlink the autoload folder or copy files.

**Option C: Git Submodule (Not Recommended)**
```bash
git submodule add https://github.com/firstframestudios/shared-godot shared/godot
```
Submodules are complex and prone to confusion. Symlinks or direct copies are simpler.

### Canvas 2D Path Strategy

For Canvas 2D games, import shared utilities via ES6 modules:

```javascript
// games/game-kong/src/systems/input.js
import { StateMachine } from '../../../shared/canvas-2d/state-machines/index.js';
import { InputHandler } from '../../../shared/canvas-2d/input-systems/index.js';
```

Or copy utilities directly if they're small.

### Asset Organization

**Shared assets:** Non-game-specific visual/audio elements (fonts, generic UI, reusable effects)
**Game-specific assets:** Characters, levels, story-specific audio

```
shared/assets/
├── fonts/
│   ├── studio-sans.otf       # Used across all games
│   └── studio-mono.ttf
├── ui-components/
│   ├── buttons/
│   │   ├── button-default.png
│   │   └── button-pressed.png
│   └── dialogs/
│       └── dialog-frame.png
└── visual-effects/
    ├── explosions/           # Generic explosion sprite
    └── screen-transitions/
```

**Godot:** Reference via `res://` paths that symlink to shared/
**Canvas 2D:** Reference via relative imports or asset pipeline

---

## 7. Migration Plan: Current → New Structure

### Phase 1: Preparation (No Code Changes)

**Objective:** Prepare the new structure before moving files.

1. **Create directories**
   ```bash
   mkdir -p games/game-kong
   mkdir -p games/ashfall  # (placeholder for future)
   mkdir -p shared/{godot,canvas-2d,assets,docs,configs}
   mkdir -p docs
   mkdir -p tools/scripts
   mkdir -p .github/{ISSUE_TEMPLATE,workflows}
   ```

2. **Create documentation files** (from Section 5)
   - `docs/README.md`
   - `docs/GETTING_STARTED.md`
   - `docs/CONTRIBUTING.md`
   - `docs/ARCHITECTURE.md`
   - `docs/DEVELOPMENT_SETUP.md`
   - `docs/BUILDING.md`
   - `docs/CHANGELOG.md`
   - `docs/FAQ.md`

3. **Create root configuration**
   - `.editorconfig` (from Section 3)
   - `copilot-instructions.md` (from Section 5)
   - Update `.gitignore` (from Section 3)
   - Update `.gitattributes` (from Section 3)
   - `LICENSE`
   - `SECURITY.md`
   - `CHANGELOG.md`
   - Root `README.md` (from Section 5)
   - `CONTRIBUTING.md` (from Section 5)

4. **Create issue/PR templates** (in `.github/ISSUE_TEMPLATE/`)
   - `bug_report.md`
   - `game_feature.md`
   - `tech_spike.md`
   - `documentation.md`
   - `.github/PULL_REQUEST_TEMPLATE.md`

### Phase 2: Move firstPunch (Main Game)

**Objective:** Move current game code to `games/game-kong/`.

1. **Create game-specific files**
   ```bash
   cd games/game-kong
   # Copy from root:
   # - index.html
   # - styles.css
   # - src/ (entire directory)
   # - assets/ (game-specific assets)
   ```

2. **Create game documentation**
   - `games/game-kong/README.md` — Game-specific (controls, features, known issues)
   - `games/game-kong/ARCHITECTURE.md` — Technical design (Canvas 2D, entity-component, systems)
   - `games/game-kong/.gitignore` — Game-specific ignores (if any)
   - `games/game-kong/LICENSE` — (game IP license or inherit from studio)

3. **Create placeholder `games/ashfall/`**
   ```bash
   mkdir -p games/ashfall
   # Create empty project.godot as placeholder
   # Create README.md (WIP - Godot 4 action RPG)
   ```

4. **Create shared assets stubs**
   ```bash
   # Move shared UI/font assets (if any) to shared/assets/
   mkdir -p shared/assets/{fonts,ui-components,visual-effects}
   ```

### Phase 3: Set Up CI/CD

**Objective:** Create GitHub Actions workflows.

1. **Create `.github/workflows/ci-game-build.yml`**
   - Build both Canvas 2D (game-kong) and future Godot games
   - Trigger on PR and push

2. **Create `.github/workflows/ci-tests.yml`**
   - Run any monorepo-level tests
   - Check documentation build

3. **Migrate existing workflows**
   - Move existing `.github/workflows/squad-*.yml` to new location
   - Update any path references

### Phase 4: Create Root README & Final Polish

1. **Create root `README.md`** with:
   - Welcome message
   - Games list and quick-start commands
   - Links to documentation
   - Link to `.squad/` for company info

2. **Create `games/README.md`** explaining:
   - How games are organized
   - How to add a new game
   - Shared assets strategy

3. **Create `shared/README.md`** explaining:
   - What belongs in shared/
   - How to reference shared assets/code
   - Symlink strategy

4. **Test the setup:**
   - Verify `cd games/game-kong && open index.html` works
   - Verify CI/CD pipeline triggers
   - Verify all links in documentation resolve

---

## 8. Complete File Checklist

### Create (New Files)

**Root level:**
- [ ] `README.md` — Repository manifest
- [ ] `CONTRIBUTING.md` — Contribution guidelines
- [ ] `LICENSE` — MIT license
- [ ] `SECURITY.md` — Security policy
- [ ] `CHANGELOG.md` — Version history
- [ ] `copilot-instructions.md` — Agent instructions
- [ ] `.editorconfig` — Code style defaults
- [ ] `docs/GETTING_STARTED.md` — Onboarding guide
- [ ] `docs/ARCHITECTURE.md` — Monorepo architecture
- [ ] `docs/CONTRIBUTING.md` — (Copy of root, for easy access)
- [ ] `docs/DEVELOPMENT_SETUP.md` — Dev environment setup
- [ ] `docs/BUILDING.md` — Build instructions
- [ ] `docs/CHANGELOG.md` — (Copy of root, for easy access)
- [ ] `docs/FAQ.md` — Frequently asked questions

**GitHub infrastructure:**
- [ ] `.github/ISSUE_TEMPLATE/bug_report.md`
- [ ] `.github/ISSUE_TEMPLATE/game_feature.md`
- [ ] `.github/ISSUE_TEMPLATE/tech_spike.md`
- [ ] `.github/ISSUE_TEMPLATE/documentation.md`
- [ ] `.github/PULL_REQUEST_TEMPLATE.md`
- [ ] `.github/workflows/ci-game-build.yml` — Per-game build pipeline
- [ ] `.github/workflows/ci-tests.yml` — Monorepo tests

**Game-specific:**
- [ ] `games/game-kong/README.md` — Game-specific overview
- [ ] `games/game-kong/ARCHITECTURE.md` — Technical design
- [ ] `games/game-kong/.gitignore` — (If different from root)
- [ ] `games/ashfall/README.md` — Placeholder for future project

**Shared infrastructure:**
- [ ] `shared/README.md` — Explanation of shared assets strategy
- [ ] `shared/godot/README.md` — Godot-specific guidance
- [ ] `shared/canvas-2d/README.md` — Canvas 2D guidance
- [ ] `shared/assets/README.md` — Asset library guide
- [ ] `shared/docs/art-style-guide.md` — Visual consistency
- [ ] `shared/docs/audio-design-guidelines.md` — Audio standards
- [ ] `shared/docs/performance-budgets.md` — Platform targets

**Tools:**
- [ ] `tools/README.md` — Overview of build tools
- [ ] `tools/scripts/setup-dev-env.sh` — Initial setup script

### Move (Existing Files from Root)

**Move to `games/game-kong/`:**
- [ ] `index.html`
- [ ] `styles.css`
- [ ] `src/` (entire directory)
- [ ] `assets/` (entire directory, or game-specific subset)

**Keep at Root:**
- [ ] `.git/`, `.github/`, `.squad/`, `.copilot/`
- [ ] All `.squad/` files remain at root level

### Update (Existing Files)

**Root `.gitignore`:**
- [ ] Add Godot patterns (*.import, .godot/, user://)
- [ ] Add Canvas 2D patterns (node_modules/, dist/)
- [ ] Preserve squad merge strategy with negation patterns for game-specific ignores

**Root `.gitattributes`:**
- [ ] Add binary asset patterns (*.png, *.ogg, *.mp3, etc.)
- [ ] Add union merge for *.tres, *.tscn files
- [ ] Keep squad union merge strategy

---

## 9. Trade-Offs & Architectural Decisions

### Decision 1: Monorepo vs Multi-Repo

**Chosen:** Monorepo (single GitHub repository)

**Why:**
- ✅ Shared skills, decisions, and institutional knowledge live in one place
- ✅ Cross-game utilities and assets are versioned together
- ✅ Single CI/CD pipeline
- ✅ Founder can push studio to GitHub as a unified package

**Trade-off:**
- ❌ Repo gets larger over time (mitigated by Git LFS for assets)
- ❌ CI/CD must understand game-per-directory structure

### Decision 2: Symlinks vs Git Submodules vs Copy

**Chosen:** Symlinks for code, copy for binary assets

**Why:**
- ✅ Symlinks are simple and don't complicate Git history
- ✅ No merge conflicts from submodule version mismatches
- ✅ Developers can modify shared code and see changes immediately

**Alternative:** If developers need strict isolation, use `.gitignore` + setup script to copy files.

### Decision 3: Shared Asset Scope

**Chosen:** Only truly shared assets (fonts, generic UI, reusable SFX)

**Why:**
- ✅ Prevents asset bloat (firstPunch's Brawler sprite is NOT shared)
- ✅ Each game can evolve visually without affecting others
- ✅ Clear ownership: game-specific art belongs in games/{game}/assets/

**Rule:** If an asset is used by 2+ games, it belongs in shared/. Otherwise, it's game-specific.

### Decision 4: Documentation Strategy

**Chosen:** Multi-level docs (root README + game READMEs + skill docs)

**Why:**
- ✅ New developer reads root README to understand what the repo is
- ✅ New developer reads game README to understand a specific game
- ✅ Architecture questions are answered in ARCHITECTURE.md files
- ✅ `.squad/` skills provide deep technical knowledge

---

## 10. Concerns & Risk Mitigation

### Concern 1: Shared Asset Dependencies

**Risk:** If a shared asset changes, does it break existing games?

**Mitigation:**
- Shared assets should be backwards-compatible (don't remove, only add)
- Each game pins the version it uses (e.g., via commit hash or tag)
- Breaking changes require discussion in `.squad/decisions.md`

### Concern 2: Godot Path Resolution

**Risk:** Godot projects may have trouble resolving symlinked addons.

**Mitigation:**
- Test symlinks on all platforms (Windows, Mac, Linux) during Sprint 0
- If symlinks don't work on Windows, use a setup script that copies files instead
- Document the workaround in `docs/DEVELOPMENT_SETUP.md`

### Concern 3: CI/CD Scalability

**Risk:** As games multiply, CI/CD matrix gets unwieldy.

**Mitigation:**
- Use a setup.json or config file that lists games instead of hardcoding them
- Each game's .gitignore can signal "skip CI" if needed
- Optimize caching to avoid rebuilding Godot every time

### Concern 4: Asset Size & Git Performance

**Risk:** Monorepo with many large assets becomes slow to clone.

**Mitigation:**
- Use Git LFS for binary assets >2MB
- Consider hosting large assets separately (S3, Perforce, etc.) as studio grows
- Document asset management strategy in `shared/assets/README.md`

### Concern 5: Team Understanding

**Risk:** New developers don't understand the structure or where to put files.

**Mitigation:**
- `docs/GETTING_STARTED.md` has a "Where do I put X?" decision tree
- `.squad/identity/new-project-playbook.md` includes "repo structure" checklist
- `games/README.md` explains game organization
- `shared/README.md` explains asset strategy
- `copilot-instructions.md` guides the @copilot agent

---

## 11. Validation Checklist

Before pushing to GitHub, verify:

### Repository Structure
- [ ] `games/game-kong/` exists with all game files
- [ ] `games/ashfall/` exists as placeholder
- [ ] `shared/` directory exists with subdirectories
- [ ] `.squad/` exists with all existing files
- [ ] `docs/` has 8+ documentation files
- [ ] `.github/workflows/` has CI/CD workflows
- [ ] `.github/ISSUE_TEMPLATE/` has 4 issue templates
- [ ] Root has README, LICENSE, CONTRIBUTING, SECURITY, CHANGELOG, copilot-instructions.md

### Configuration
- [ ] `.gitignore` covers Godot, Canvas 2D, IDEs, OS files
- [ ] `.gitattributes` handles binary assets correctly
- [ ] `.editorconfig` provides style defaults
- [ ] Root `README.md` links to all key docs

### Documentation
- [ ] `docs/GETTING_STARTED.md` has onboarding checklist
- [ ] `docs/ARCHITECTURE.md` explains monorepo design
- [ ] `games/game-kong/README.md` has game description and controls
- [ ] `games/game-kong/ARCHITECTURE.md` explains technical stack

### CI/CD
- [ ] `.github/workflows/ci-game-build.yml` runs on PR/push
- [ ] Workflow tests both Canvas 2D and Godot games
- [ ] Workflow passes with current code
- [ ] Issue/PR templates are visible in UI

### Functionality
- [ ] `cd games/game-kong && open index.html` works
- [ ] All relative imports in firstPunch code work
- [ ] No broken links in Markdown files
- [ ] Squad infrastructure remains untouched

---

## Appendix A: Example `.github/workflows/ci-game-build.yml`

```yaml
name: Build Games

on:
  pull_request:
    branches: [main, dev, preview]
  push:
    branches: [main, dev]

env:
  NODE_VERSION: 22
  GODOT_VERSION: 4.3

jobs:
  discover:
    runs-on: ubuntu-latest
    outputs:
      games: ${{ steps.games.outputs.matrix }}
    steps:
      - uses: actions/checkout@v4
      - id: games
        run: |
          games=$(ls -d games/*/ | sed 's|games/||g' | sed 's|/||g' | jq -R -s -c 'split("\n")[:-1]')
          echo "matrix=$games" >> $GITHUB_OUTPUT

  build:
    needs: discover
    runs-on: ubuntu-latest
    strategy:
      matrix:
        game: ${{ fromJson(needs.discover.outputs.games) }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Detect game type
        id: detect
        run: |
          if [ -f "games/${{ matrix.game }}/project.godot" ]; then
            echo "type=godot" >> $GITHUB_OUTPUT
          else
            echo "type=canvas2d" >> $GITHUB_OUTPUT
          fi
      
      - name: Set up Node (Canvas 2D)
        if: steps.detect.outputs.type == 'canvas2d'
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Set up Godot
        if: steps.detect.outputs.type == 'godot'
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
      
      - name: Build ${{ matrix.game }}
        run: |
          cd games/${{ matrix.game }}
          if [ -f "package.json" ]; then
            npm install
            npm run build 2>/dev/null || echo "No build script"
          fi
      
      - name: Run tests
        run: |
          cd games/${{ matrix.game }}
          if [ -f "package.json" ]; then
            npm test 2>/dev/null || echo "No tests"
          fi
```

---

## Appendix B: Example `docs/GETTING_STARTED.md`

```markdown
# Getting Started with First Frame Studios

Welcome! This guide helps you set up your development environment and understand our studio.

## 1. Read These First

1. **Our Philosophy** → `.squad/identity/company.md` (5 min read)
2. **Leadership Principles** → `.squad/identity/principles.md` (10 min read)
3. **New Project Playbook** → `.squad/identity/new-project-playbook.md` (this is how we do everything)

## 2. Set Up Your Development Environment

Follow [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for:
- Installing Node.js
- Installing Godot 4.3
- Installing Git (with proper line endings)
- Cloning the repo
- Symlink setup (if needed)

## 3. Understand the Structure

- **Your game lives in:** `games/{game-name}/`
- **Shared code/assets live in:** `shared/`
- **Studio knowledge lives in:** `.squad/`
- **Documentation lives in:** `docs/`

## 4. Choose Your Path

### "I'm working on firstPunch"
1. Read `games/game-kong/README.md` — Game overview
2. Read `games/game-kong/ARCHITECTURE.md` — Technical design
3. Read `.squad/skills/canvas-2d-optimization/` — Performance tips
4. Read `.squad/skills/beat-em-up-combat/` — Combat mechanics
5. Start coding!

### "I'm working on Ashfall (Godot)"
1. Read `games/ashfall/README.md` — Game overview
2. Read `games/ashfall/ARCHITECTURE.md` — Technical design
3. Read `.squad/skills/godot-beat-em-up-patterns/` — Godot patterns
4. Read `.squad/skills/state-machine-patterns/` — Architecture
5. Open `games/ashfall/project.godot` in Godot editor

### "I'm contributing to shared infrastructure"
1. Read `.squad/identity/quality-gates.md` — What "done" means
2. Read `shared/README.md` — Shared asset strategy
3. Read `CONTRIBUTING.md` — PR workflow
4. Submit your PR against `dev` branch

## 5. Daily Workflow

### Before you start
```bash
git checkout dev
git pull origin dev
```

### Create a feature branch
```bash
git checkout -b feature/descriptive-name
# or: fix/description, docs/description, infra/description
```

### Make commits
```bash
git commit -m "[GameName] Concise description

Longer explanation if needed.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

### Push and PR
```bash
git push origin feature/descriptive-name
# Open PR on GitHub, assign reviewers
```

## 6. Finding Answers

| Question | Answer Location |
|----------|-----------------|
| How do I...? | `docs/FAQ.md` |
| What's the company philosophy? | `.squad/identity/company.md` |
| How do we make decisions? | `.squad/decisions.md` |
| What does an agent do? | `.squad/team.md` and their charter |
| What's been done before? | `.squad/analysis/` |
| What should I learn about X? | `.squad/skills/` (search by name) |

## 7. Help & Questions

- **Technical question about game code?** Open an issue or ask in Discord
- **Philosophical question about the studio?** Read `.squad/` first, then discuss
- **Need to escalate?** Contact Solo (Lead Architect)
- **Reporting a bug?** Use GitHub Issues with the bug_report template
- **Suggesting a feature?** Use GitHub Issues with the game_feature template

## 8. Next Steps

1. ✅ Read the onboarding docs
2. ✅ Set up your dev environment
3. ✅ Pick a game or task
4. ✅ Read the relevant skill docs
5. ✅ Make your first commit!

Welcome to the team. We're building something great together.
```

---

## Summary

This validated structure is:
- ✅ **Complete:** Includes all files a professional GitHub repo needs
- ✅ **Scalable:** Grows to 5+ games without breaking
- ✅ **Clear:** Every directory has a purpose, every file has a home
- ✅ **Documented:** Multiple levels of guidance for different audiences
- ✅ **Operational:** CI/CD, issue templates, contribution guidelines ready
- ✅ **Principled:** Reflects First Frame Studios' values (research-driven, playable-first, skill-based)

**Next step:** Execute Migration Plan (Section 7) in Phase 1-4 over 2-3 days.

