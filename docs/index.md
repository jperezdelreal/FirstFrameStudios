---
layout: home
title: Home
---

# 🎮 First Frame Studios

> AI-powered game development studio — shipping games with a 15-agent Squad team.

We build games. Not tech demos, not prototypes — **complete, playable games** that players want to come back to. Our secret weapon: a team of specialized AI agents coordinated by [Squad](https://github.com/bradygaster/squad), each owning a domain — engine, gameplay, art, audio, QA, production.

---

## 🕹️ Active Projects

| Game | Description | Stack | Status |
|------|-------------|-------|--------|
| 🍩 [**ComeRosquillas**](https://github.com/jperezdelreal/ComeRosquillas) | Arcade web game — fast, fun, replayable | HTML + JS + Canvas | 🎮 Playable |
| 🌿 [**FLORA**](https://github.com/jperezdelreal/flora) | Cozy roguelite with procedural worlds | Vite + TypeScript + PixiJS v8 | 🌱 Starting |

## 🛠️ Studio Tools

| Tool | Description | Link |
|------|-------------|------|
| 📊 **Squad Monitor** | Real-time dashboard for agent activity across all repos | [ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor) |

## 📦 Archived Projects

| Game | Genre | What We Learned |
|------|-------|-----------------|
| 🔥 **Ashfall** | 1v1 Fighting (Godot 4) | AI teams can build infrastructure fast, but fighting games need human feel-tuning. 2 sprints shipped before archiving. |
| 👊 **firstPunch** | Beat 'em Up (Canvas 2D) | Built a 1,931 LOC custom engine from scratch in vanilla JS. Proved AI agents can build real game systems. |

---

## 🤖 Powered by Squad

First Frame Studios runs on [Squad](https://github.com/bradygaster/squad) — an AI agent orchestration framework. Our team of **15 specialized agents** works autonomously across game repos:

- **Yoda** — Game Designer. Owns GDDs, mechanics, balance.
- **Chewie** — Engine Developer. Runtime systems, physics, rendering.
- **Jango** — Tool Engineer. Scaffolding, CI/CD, pipelines.
- **Lando** — Art Director. Visual identity, sprites, UI.
- **Solo** — Tech Lead. Architecture decisions, code quality.
- **Mace** — Scribe. Documentation, wiki, dev diaries.
- **Ralph** — The autonomous loop. Watches for issues, assigns work, keeps the studio running 24/7.

Each agent branches from main, files PRs with `Closes #N`, and never steps on another agent's files. The result: parallel development at machine speed with human-level specialization.

**Inspired by:** [Organized by AI — Tamir Dresher](https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai)

---

## 🏗️ Studio Hub

This repository ([FirstFrameStudios](https://github.com/jperezdelreal/FirstFrameStudios)) is the **Studio Hub** — no game code lives here. It manages:

- **`.squad/`** — Team roster, decisions, skills, casting, ceremonies
- **`tools/`** — ralph-watch (autonomous loop), scheduler, shared tooling
- **`.github/workflows/`** — Triage, heartbeat, daily digest, drift detection

Game repos inherit studio knowledge via `squad upstream`.

---

## 📬 Latest Posts
