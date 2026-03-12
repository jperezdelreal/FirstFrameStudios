---
updated_at: 2026-03-12
focus_area: Studio Hub — orchestrating active game repos
team_size: 11 active + 4 hibernated + Scribe + Ralph
current_phase: Hub operational. Multi-repo architecture live, three projects in flight.
genre: N/A (studio hub)
engine: N/A (studio hub)
scope: Studio hub managing active projects via upstream. No game code lives here.
---

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

## Project Lifecycle

FFS uses a **standard lifecycle** across all project repos (not the hub):
- **Sprint Planning** → **Sprinting** → **Sprint Planning** (loop) → **Closeout** (when mature)
- Sprints end when issues close, not on a calendar. Every ceremony produces GitHub issues.
- State tracked in `.squad/project-state.json` per repo (`phase`, `sprint`, `design_doc`)
- Hub is excluded — infrastructure stays in permanent maintenance mode.
- See `.squad/ceremonies.md` § "Project Lifecycle Ceremonies" for full spec.

## Infrastructure

- **ralph-watch.ps1 v2:** Multi-repo autonomous loop (401 lines, failure alerts, activity monitor)
- **Scheduler:** 4 recurring tasks (playtest, retro, grooming, browser compat)
- **GitHub Actions:** 22 workflows (triage, heartbeat, daily-digest, deploy-pages, etc.)
- **Upstream:** ComeRosquillas + Flora inherit studio identity via `.squad/upstream/`

## Archived Projects

- **Ashfall** — Godot 4 fighting game, 2 sprints shipped, shelved (genre too complex for AI-only tuning)
- **firstPunch** — Canvas 2D beat 'em up, completed prototype
