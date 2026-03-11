---
title: "Studio Restructure: From Monorepo to Multi-Repo Hub"
date: 2026-03-11
excerpt: "We broke the monorepo apart, trimmed the squad from 15 to 11, and shipped new tooling. Here's what changed and why."
tags: [restructure, architecture, squad, tooling]
---

# Studio Restructure: From Monorepo to Multi-Repo Hub

Today we ran our first real ceremony — a structured retro + restructure session — and the studio came out leaner on the other side.

Here's what happened.

---

## The Problem: Monorepo Growing Pains

When we launched First Frame Studios, everything lived in one repo: squad config, CI workflows, game code, docs, tools. It worked fine when Ashfall was the only project. But once we added ComeRosquillas, FLORA, and the squad monitor, the monorepo started fighting us.

PRs touched files across unrelated domains. Godot workflows ran on docs changes. Game-specific CI gates blocked hub-level PRs. The boundaries were wrong.

## What Changed: Hub + Upstream Architecture

We restructured into a hub-and-spoke model:

```
┌─────────────────────────┐
│   FirstFrameStudios     │  ← Hub: squad config, docs, tools, CI
│   (this repo)           │
└──────────┬──────────────┘
           │ upstream
     ┌─────┴──────┐
     ▼            ▼
┌─────────┐  ┌─────────┐
│ ComeRos │  │  FLORA   │   ← Game repos: self-contained, own CI
│ quillas │  │          │
└─────────┘  └─────────┘
```

Each game repo is now fully self-contained with its own workflows, tests, and release pipeline. The hub holds what's shared: squad configuration, the Astro docs site, studio-wide tooling, and orchestration workflows.

Godot-specific CI — the project.godot guard, GDScript linting, the export pipeline — all moved out. Those workflows belong in game repos that actually use Godot, not in the hub.

## Squad Changes: 15 → 11 Active

We trimmed the squad. Not because agents failed — because scope changed.

Four agents are now **hibernated** (config preserved, not active):
- Agents tied to Ashfall's Godot pipeline
- Specialists whose domains moved to game-specific repos

Eleven agents remain active, focused on the hub and cross-repo orchestration. The hibernated agents can be reactivated when their domains are needed again. No config was lost.

## New Tooling

Three tools shipped as part of the restructure:

- **ralph-watch v2** — The autonomous issue watcher got a rewrite. Faster polling, better dedup, multi-repo support across the hub and all game repos.
- **Squad Monitor** — Real-time dashboard showing agent status, active issues, and PR throughput across all repos. Lives at [ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor).
- **GitHub Pages** — The docs site (the one you're reading) is now deployed via GitHub Pages with an Astro build pipeline. No more manual deploys.

## What's Next

The restructure clears the path for focused work:
- ComeRosquillas sprints without hub noise
- FLORA can spin up independently when ready
- Hub improvements (docs, tooling, squad config) ship without game-repo side effects

The ceremony format worked. We'll keep running them — structured checkpoints beat ad-hoc chaos every time.

---

*Ceremony run by [Joaquín Pérez del Real](https://github.com/jperezdelreal). Changes tracked in issues and committed to main.*
