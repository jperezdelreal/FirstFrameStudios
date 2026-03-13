# Monorepo Structure Validation — First Frame Studios

> Compressed from 48KB. Full: monorepo-structure-archive.md

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-22  
---

## Executive Summary
The proposed monorepo structure is **fundamentally sound** but **incomplete**. It correctly places game projects under `games/`, shared assets under `shared/`, and squad infrastructure under `.squad/`. However, it is missing critical repository infrastructure that any professional GitHub-hosted monorepo needs before Day 1.
**Key findings:**
---

## 1. Validated & Complete Monorepo Structure
```
FirstFrameStudios/                          # Repository root
---

## 2. Directory Purpose & Guidance
### Root Level
| Directory | Purpose | Key Files | Notes |
| `.copilot/` | Copilot CLI configuration | Auto-generated | Managed by @copilot CLI; no manual edits needed. |
| `.github/` | GitHub infrastructure | workflows/, templates | Branch protection, issue templates, CI/CD, PR template. |
| `.squad/` | Studio team & knowledge | agents/, skills/, identity/, decisions.md | The institutional brain. Every decision, every skill, every agent history. **DO NOT** put game-specific code here. |
| `shared/` | Cross-game reusable assets & code | godot/, canvas-2d/, assets/, docs/, configs/ | Shared plugins, utilities, assets, style guides. Each game **symlinks** or **references** what it needs. |
| `games/` | Game project folders | game-kong/, ashfall/, [future games]/ | Each game is self-contained with its own README, .gitignore, architecture. |
| `docs/` | Repository-level documentation | GETTING_STARTED.md, ARCHITECTURE.md, CONTRIBUTING.md | How to navigate this monorepo. How to set up dev environment. How to build and ship. |
# In games/game-kong/.gitignore

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Then in setup script:

> Compressed from 48KB. Full: monorepo-structure-archive.md

# .github/workflows/ci-game-build.yml

> Compressed from 48KB. Full: monorepo-structure-archive.md

---

## 3. Git Infrastructure (.gitignore, .gitattributes, .editorconfig)
### `.gitignore` (Comprehensive)
The monorepo needs a root `.gitignore` that covers:
# Root .gitignore

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Godot

> Compressed from 48KB. Full: monorepo-structure-archive.md

# JavaScript / npm

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Development

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Except: let each game define its own ignores

> Compressed from 48KB. Full: monorepo-structure-archive.md

### `.gitattributes` (Binary Handling)
# Squad append-only merge strategy (existing, keep it)

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Binary assets — Git LFS (if stored in repo)

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Text files

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Documentation

> Compressed from 48KB. Full: monorepo-structure-archive.md

### `.editorconfig` (Code Style)
# All files

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Markdown

> Compressed from 48KB. Full: monorepo-structure-archive.md

# JavaScript

> Compressed from 48KB. Full: monorepo-structure-archive.md

# GDScript (Godot)

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Python

> Compressed from 48KB. Full: monorepo-structure-archive.md

# YAML/JSON

> Compressed from 48KB. Full: monorepo-structure-archive.md

---

## 4. GitHub Infrastructure (.github/)
### CI/CD Workflows
#### `ci-game-build.yml` — Per-Game Build Pipeline
### Issue Templates
---
---

## Game
- [ ] firstPunch
- [ ] Ashfall

## Describe the bug
[...]

## Steps to reproduce
1. Start the game
2. Do X

## Expected behavior
[...]

## Screenshots/Video
[...]
```
### Pull Request Template

## Type of Change
- [ ] Bug fix
- [ ] New feature

## Related Issues
Closes #XXX

## Description
[...]

## Testing
How was this tested?

## Checklist
- [ ] I've tested locally
- [ ] I've updated relevant documentation
---

## 5. Root-Level Configuration Files
### `README.md` (Repository Manifest)
The entry point. Should answer:
# First Frame Studios — Game Development Monorepo

> Compressed from 48KB. Full: monorepo-structure-archive.md


## Quick Start
### Run firstPunch (locally)
```bash
# Open http://localhost:8000

> Compressed from 48KB. Full: monorepo-structure-archive.md

### Open Ashfall in Godot

## Important Links
- **New here?** Read [GETTING_STARTED.md](docs/GETTING_STARTED.md)
- **Contributing?** Read [CONTRIBUTING.md](CONTRIBUTING.md)

## For Developers
- Development setup: [docs/DEVELOPMENT_SETUP.md](docs/DEVELOPMENT_SETUP.md)
- Building games: [docs/BUILDING.md](docs/BUILDING.md)
### `CONTRIBUTING.md` (Contribution Guidelines)
# Contributing to First Frame Studios

> Compressed from 48KB. Full: monorepo-structure-archive.md


## Code of Conduct
We are a studio committed to excellence, iteration, and learning from failure.

## Before You Start
1. Read [.squad/identity/principles.md](.squad/identity/principles.md) — our 12 leadership principles
2. Read [.squad/identity/quality-gates.md](.squad/identity/quality-gates.md) — definition of done

## Workflow
1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make commits with meaningful messages: `git commit -m "Clear description"`

## Commit Message Format
```
[GAME] Concise description

## Branch Naming
- `feature/description` — New feature
- `fix/description` — Bug fix

## Code Review Checklist
Before submitting:
- [ ] Code follows `.editorconfig` style
### `LICENSE` (MIT Recommended)
### `SECURITY.md` (Security Policy)
# Security Policy

> Compressed from 48KB. Full: monorepo-structure-archive.md


## Reporting Vulnerabilities
**Do not file public issues for security vulnerabilities.**
Instead, email security@firstframestudios.com with:
### `CHANGELOG.md` (Version History)
# Changelog

> Compressed from 48KB. Full: monorepo-structure-archive.md


## [Unreleased]
### Added
- Ashfall: New enemy archetype (Shade)
### Fixed

## [1.0.0] - firstPunch Released
### Added
- firstPunch v1.0: Playable beat 'em up with 5 waves
### `copilot-instructions.md` (Agent Instructions)
# Instructions for @copilot

> Compressed from 48KB. Full: monorepo-structure-archive.md


## Key Context
- **What you're building:** Multi-game studio with shared infrastructure
- **Where to find documentation:** `.squad/identity/` has company principles, playbook, growth framework

## When Working on a Game
1. Read the game's `ARCHITECTURE.md` to understand tech choices
2. Read relevant shared skills before writing code

## When Working on Studio Infrastructure
1. Changes to `.squad/` must include rationale
2. Update relevant agent history (`.squad/agents/{agent-name}/history.md`)

## When Adding Files
- Game code → `games/{game-name}/`
- Shared utilities → `shared/`

## Never
- Commit secrets or credentials
- Add large binary files without Git LFS
---

## 6. `shared/` Directory Architecture
### Godot Path Strategy
For Godot games to access shared code and addons:
# After cloning, run setup

> Compressed from 48KB. Full: monorepo-structure-archive.md

# Or in addons folder:

> Compressed from 48KB. Full: monorepo-structure-archive.md

### Canvas 2D Path Strategy
### Asset Organization
---

## 7. Migration Plan: Current → New Structure
### Phase 1: Preparation (No Code Changes)
**Objective:** Prepare the new structure before moving files.
### Phase 2: Move firstPunch (Main Game)
### Phase 3: Set Up CI/CD
### Phase 4: Create Root README & Final Polish
---

## 8. Complete File Checklist
### Create (New Files)
**Root level:**
### Move (Existing Files from Root)
### Update (Existing Files)
---

## 9. Trade-Offs & Architectural Decisions
### Decision 1: Monorepo vs Multi-Repo
**Chosen:** Monorepo (single GitHub repository)
### Decision 2: Symlinks vs Git Submodules vs Copy
### Decision 3: Shared Asset Scope
### Decision 4: Documentation Strategy
---

## 10. Concerns & Risk Mitigation
### Concern 1: Shared Asset Dependencies
**Risk:** If a shared asset changes, does it break existing games?
### Concern 2: Godot Path Resolution
### Concern 3: CI/CD Scalability
### Concern 4: Asset Size & Git Performance
---

## 11. Validation Checklist
Before pushing to GitHub, verify:
### Repository Structure
### Configuration
### Documentation
### CI/CD
---

## Appendix A: Example `.github/workflows/ci-game-build.yml`
```yaml
name: Build Games
---

## Appendix B: Example `docs/GETTING_STARTED.md`
```markdown
# Getting Started with First Frame Studios

> Compressed from 48KB. Full: monorepo-structure-archive.md

Welcome! This guide helps you set up your development environment and understand our studio.

## 1. Read These First
1. **Our Philosophy** → `.squad/identity/company.md` (5 min read)
2. **Leadership Principles** → `.squad/identity/principles.md` (10 min read)

## 2. Set Up Your Development Environment
Follow [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for:
- Installing Node.js

## 3. Understand the Structure
- **Your game lives in:** `games/{game-name}/`
- **Shared code/assets live in:** `shared/`

## 4. Choose Your Path
### "I'm working on firstPunch"
1. Read `games/game-kong/README.md` — Game overview
### "I'm working on Ashfall (Godot)"
### "I'm contributing to shared infrastructure"

## 5. Daily Workflow
### Before you start
```bash
### Create a feature branch
# or: fix/description, docs/description, infra/description

> Compressed from 48KB. Full: monorepo-structure-archive.md

### Make commits
### Push and PR
# Open PR on GitHub, assign reviewers

> Compressed from 48KB. Full: monorepo-structure-archive.md


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

## 8. Next Steps
1. ✅ Read the onboarding docs
2. ✅ Set up your dev environment
---

## Summary
This validated structure is:
- ✅ **Complete:** Includes all files a professional GitHub repo needs