# 🎮 First Frame Studios

> AI-powered game development studio — shipping games with a 15-agent Squad team.

## What We Do

We build games. Not tech demos, not prototypes — **complete, playable games** that players want to come back to. Our secret weapon: a team of specialized AI agents coordinated by [Squad](https://github.com/bradygaster/squad), each owning a domain (engine, gameplay, art, audio, QA, production).

## Active Projects

| Game | Repo | Status | Stack |
|------|------|--------|-------|
| 🌿 **FLORA** | [flora](https://github.com/jperezdelreal/flora) | 🌱 Starting | Vite + TypeScript + PixiJS v8 |
| 🍩 **ComeRosquillas** | [ComeRosquillas](https://github.com/jperezdelreal/ComeRosquillas) | 🎮 Playable | HTML + JS + Canvas |

## Studio Tools

| Tool | Repo | Purpose |
|------|------|---------|
| 📊 **Squad Monitor** | [ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor) | Real-time dashboard for agent activity |

## Archived Projects

| Game | Genre | What We Learned |
|------|-------|----------------|
| 🔥 Ashfall | 1v1 Fighting (Godot 4) | AI teams can build infrastructure fast but fighting games need human feel-tuning |
| 👊 firstPunch | Beat 'em Up (Canvas 2D) | Vanilla JS game engine from scratch — 1,931 LOC custom engine |

## Studio Infrastructure

This repo is the **Studio Hub** — the parent Squad that manages studio-wide knowledge:

- **`.squad/`** — Team roster, decisions, skills, casting, ceremonies
- **`tools/`** — ralph-watch (autonomous loop), scheduler, shared tooling
- **`.github/workflows/`** — Triage, heartbeat, daily digest, drift detection

Game-specific repos inherit studio knowledge via `squad upstream`.

## The Team

Built with [Squad v0.8.25](https://github.com/bradygaster/squad) — Star Wars universe casting 🌌

## Quick Links

- 🌐 [**Studio Blog**](https://jperezdelreal.github.io/FirstFrameStudios/) — Dev blog with project updates and studio learnings
- [New Project Proposals](/.squad/analysis/new-project-proposals-2026-03-10.md)
- [Studio Principles](/.squad/identity/mission-vision.md)
- [Team Wisdom](/.squad/identity/wisdom.md)
- [Blog: Organized by AI](https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai) (inspiration)
