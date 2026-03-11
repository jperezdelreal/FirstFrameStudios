# Now

> What's happening at First Frame Studios right now.

## Current Phase

**Studio Hub Operational** — Multi-repo architecture live. 11 active agents + 4 hibernated. Three projects in flight.

## Active Projects

| Project | Repo | Stack | Status | Issues |
|---------|------|-------|--------|--------|
| **ComeRosquillas** (Homer's Donut Quest) | [jperezdelreal/ComeRosquillas](https://github.com/jperezdelreal/ComeRosquillas) | HTML/JS/Canvas | 🟢 Active | 8 open |
| **Flora** (Cozy Gardening Roguelite) | [jperezdelreal/flora](https://github.com/jperezdelreal/flora) | TypeScript/Vite/PixiJS | 🟡 Planned | 0 open |
| **FFS Squad Monitor** | [jperezdelreal/ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor) | Vite/JS | ⚠️ Scaffold | 5 open |

## Studio Hub

- **Repo:** [jperezdelreal/FirstFrameStudios](https://github.com/jperezdelreal/FirstFrameStudios)
- **Purpose:** Studio identity, shared skills, team infrastructure, cross-project tools
- **No game code lives here** — games inherit studio DNA via `squad upstream` and live in their own repos
- **Docs site:** GitHub Pages (Astro)

## Team

- **11 active agents:** Solo, Chewie, Lando, Wedge, Greedo, Tarkin, Ackbar, Yoda, Jango, Mace, Scribe
- **2 system roles:** Ralph (Work Monitor), @copilot (Coding Agent)
- **4 hibernated:** Boba, Leia, Bossk, Nien (art pipeline roles — wake when needed)

## Infrastructure

- **ralph-watch.ps1 v2:** Multi-repo autonomous loop (401 lines, failure alerts, activity monitor)
- **Scheduler:** 4 recurring tasks (playtest, retro, grooming, browser compat)
- **GitHub Actions:** 22 workflows (triage, heartbeat, daily-digest, deploy-pages, etc.)
- **Upstream:** ComeRosquillas + Flora inherit studio identity via `.squad/upstream/`

## Archived Projects

- **Ashfall** — Godot 4 fighting game, 2 sprints shipped, shelved (genre too complex for AI-only tuning)
- **firstPunch** — Canvas 2D beat 'em up, completed prototype
