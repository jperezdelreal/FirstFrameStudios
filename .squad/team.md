# Squad Team

> First Frame Studios — AI Game Development Studio

## Coordinator

| Name | Role | Notes |
|------|------|-------|
| Squad | Coordinator | Routes work, enforces handoffs and reviewer gates. |

## Members

| Name | Role | Charter | Status |
|------|------|---------|--------|
| Solo | Lead / Chief Architect | `.squad/agents/solo/charter.md` | 🏗️ Active |
| Jango | Tool Engineer | `.squad/agents/jango/charter.md` | ⚙️ Active |
| Mace | Producer | `.squad/agents/mace/charter.md` | 📊 Active |
| Scribe | Session Logger | `.squad/agents/scribe/charter.md` | 📋 Active |
| Ralph | Work Monitor | — | 🔄 Monitor |
| @copilot | Coding Agent | `copilot-instructions.md` | 🤖 Active |

<!-- copilot-auto-assign: false -->

## Hibernated

Agents with no active work in the current web-game stack. Wake when their domain is needed again.

| Name | Role | Charter | Status | Wake Condition |
|------|------|---------|--------|----------------|
| Chewie | Engine Dev | `.squad/agents/_alumni/chewie/charter.md` | ❄️ Hibernated | Engine work needed (game loop, physics, renderer) |
| Lando | Gameplay Dev | `.squad/agents/_alumni/lando/charter.md` | ❄️ Hibernated | Combat/mechanics design needed |
| Wedge | UI Dev | `.squad/agents/_alumni/wedge/charter.md` | ❄️ Hibernated | UI/layout work needed beyond CSS |
| Greedo | Sound Designer | `.squad/agents/_alumni/greedo/charter.md` | ❄️ Hibernated | Audio design needed beyond Web Audio API |
| Tarkin | Enemy/Content Dev | `.squad/agents/_alumni/tarkin/charter.md` | ❄️ Hibernated | Enemy AI / content pipeline needed |
| Yoda | Game Designer / Vision Keeper | `.squad/agents/_alumni/yoda/charter.md` | ❄️ Hibernated | Strategic game design decisions needed |
| Boba | Art Director | `.squad/agents/_alumni/boba/charter.md` | ❄️ Hibernated | Art pipeline needed (FLUX, Blender, dedicated art direction) |
| Leia | Environment Artist | `.squad/agents/_alumni/leia/charter.md` | ❄️ Hibernated | Dedicated environment art needed beyond CSS/Canvas |
| Bossk | VFX Artist | `.squad/agents/_alumni/bossk/charter.md` | ❄️ Hibernated | Dedicated VFX pipeline needed beyond Canvas/CSS animations |
| Nien | Character Artist | `.squad/agents/_alumni/nien/charter.md` | ❄️ Hibernated | Character art pipeline needed (FLUX, sprite generation) |
| Ackbar | QA/Playtester | `.squad/agents/_alumni/ackbar/charter.md` | ❄️ Hibernated | Dedicated QA/playtesting needed beyond Lead smoke tests |

### @copilot Capability Profile

| Capability | Fit | Notes |
|------------|-----|-------|
| Single-file bug fixes | 🟢 | Good at isolated fixes with clear reproduction |
| Multi-file refactors | 🟡 | Works but needs well-scoped issues |
| New feature implementation | 🟡 | Best with detailed specs in issue body |
| HTML/JS/Canvas web games | 🟢 | Strong fit — well-defined DOM/Canvas patterns |
| TypeScript/Vite/PixiJS | 🟡 | Works well with clear specs and type definitions |
| Architecture decisions | 🔴 | Route to Solo (Lead) instead |
| Test writing | 🟢 | Good at writing tests from specs |

## Project Context

- **Project:** First Frame Studios (Studio Hub)
- **User:** Joaquin Perez del Real
- **Created:** 2026-03-06
- **Description:** AI-powered game development studio. Parent squad managing studio-wide knowledge, skills, and team coordination. Game-specific work happens in subsquad repos.
- **Universe:** Star Wars

## Active Projects

| Project | Repo | Stack | Status |
|---------|------|-------|--------|
| ComeRosquillas (Homer's Donut Quest) | [jperezdelreal/ComeRosquillas](https://github.com/jperezdelreal/ComeRosquillas) | HTML/JS/Canvas | 🟢 Active — 8 open issues |
| Flora (Cozy Gardening Roguelite) | [jperezdelreal/flora](https://github.com/jperezdelreal/flora) | TypeScript/Vite/PixiJS | 🟡 Planned — repo created |
| FFS Squad Monitor | [jperezdelreal/ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor) | Vite/JS | ⚠️ Scaffold — 5 open issues |

### Archived Projects

- **Ashfall** — Godot 4 fighting game, 2 sprints shipped, shelved (genre too complex for AI-only tuning)
- **firstPunch** — Canvas 2D beat 'em up, completed prototype

## Issue Source

- **Repository:** jperezdelreal/FirstFrameStudios
- **Connected:** 2026-03-08
- **Scope:** Studio-level issues (cross-game coordination, tooling, team management)
