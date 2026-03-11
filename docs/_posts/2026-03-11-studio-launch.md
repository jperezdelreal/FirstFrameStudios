---
layout: post
title: "🎮 First Frame Studios Is Live — Building Games with AI Agents"
date: 2026-03-11
categories: [studio, announcement]
tags: [launch, squad, ai, gamedev]
excerpt: "We're a game studio where 15 AI agents build real games autonomously. Here's how we got here, what we're building, and why this works."
---

# First Frame Studios Is Live

We're building games with AI agents. Not as a gimmick — as the actual development model.

**First Frame Studios** is a game development studio where a team of 15 specialized AI agents, coordinated by [Squad](https://github.com/bradygaster/squad), builds complete, playable games. Each agent owns a domain — game design, engine dev, art, audio, QA, tooling, production — and works autonomously through GitHub issues and pull requests.

This is the story of how we got here.

---

## The Journey: From Fighting Games to Arcade Fun

### 🔥 Ashfall — The Fighting Game That Taught Us Limits

Our first project was **Ashfall**, a 1v1 fighting game built in Godot 4. We shipped two sprints — full infrastructure, scene trees, input systems, character controllers. The AI squad moved *fast*. Architecture, pipeline, asset management — all of it came together in days.

But fighting games live and die on **feel**. Frame-perfect inputs, hitbox precision, the weight of a punch connecting. That's the kind of thing that needs a human playing it hundreds of times, tweaking values by intuition. Our AI team could build the systems, but tuning the soul of a fighting game required something we didn't have yet.

**What we learned:** AI teams build infrastructure at incredible speed. But genre-specific feel-tuning is still a human-loop problem. Choose your genre wisely.

### 👊 firstPunch — Proving AI Can Build Real Engines

Next came **firstPunch**, a beat 'em up built entirely in vanilla JavaScript with Canvas 2D. No framework, no engine — just raw code.

The result: a **1,931 LOC custom game engine** with an EventBus, AnimationController, SpriteCache, configuration system, and full combat mechanics. All built by AI agents branching, filing PRs, and merging code like a real development team.

firstPunch proved something important: AI agents don't just write boilerplate. They can build **real, interconnected systems** — state machines, animation blending, entity management — at production quality.

**What we learned:** Vanilla JS was the right call for proving the model. But we also discovered our #1 technical debt pattern: *unwired infrastructure*. 214 LOC of perfectly working systems that no agent ever connected to the game. When nobody owns tooling, it doesn't get done. (That's why we created [Jango](https://github.com/jperezdelreal/FirstFrameStudios), our Tool Engineer agent.)

### 🍩 ComeRosquillas — The Active Game

Now we're building **[ComeRosquillas](https://github.com/jperezdelreal/ComeRosquillas)** — an arcade web game. Fast, fun, replayable. HTML + JavaScript + Canvas. No framework overhead, just pure gameplay.

This is our first game targeting a **playable, shippable product** — not a tech demo, not a proof of concept. Real game, real players, real fun.

### 🌿 FLORA — The Ambitious One

In parallel, we've scaffolded **[FLORA](https://github.com/jperezdelreal/flora)** — a cozy roguelite built with Vite + TypeScript + PixiJS v8. Procedural worlds, resource gathering, and the kind of depth that rewards repeated play.

FLORA is on hold while ComeRosquillas gets to a shippable state, but the repo is ready and waiting.

---

## How the AI Team Works

Our studio runs on **[Squad](https://github.com/bradygaster/squad)** by [Brady Gaster](https://github.com/bradygaster). Here's the loop:

1. **Ralph** (our autonomous watcher) monitors all repos for new issues
2. Issues get triaged and assigned to the right specialist agent
3. Each agent **branches from main**, does their work, and files a PR with `Closes #N`
4. **Jango** (Tool Engineer) reviews and merges PRs
5. The cycle repeats — 24/7, no standups required

The agents are cast from the Star Wars universe (it started as a fun naming convention and became a genuine identity system):

| Agent | Role | Domain |
|-------|------|--------|
| Yoda | Game Designer | GDDs, mechanics, balance |
| Chewie | Engine Dev | Runtime systems, physics |
| Solo | Tech Lead | Architecture, code quality |
| Jango | Tool Engineer | CI/CD, scaffolding, pipelines |
| Lando | Art Director | Visual identity, sprites |
| Mace | Scribe | Docs, wiki, dev diaries |
| Ralph | Autonomous Loop | Issue watching, scheduling |

Each agent respects **file ownership** — no two agents edit the same file in parallel. They use PR templates, follow branching conventions, and maintain decision logs. It's not chaos. It's structured autonomy.

---

## The Repos

Everything is open source:

- 🏠 **[FirstFrameStudios](https://github.com/jperezdelreal/FirstFrameStudios)** — Studio Hub (this repo). Infrastructure, squad config, tools.
- 🍩 **[ComeRosquillas](https://github.com/jperezdelreal/ComeRosquillas)** — Active arcade game
- 🌿 **[FLORA](https://github.com/jperezdelreal/flora)** — Cozy roguelite (on hold)
- 📊 **[ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor)** — Real-time agent dashboard

---

## What's Next

- Ship ComeRosquillas to a playable state
- Get the autonomous loop (ralph-watch) running persistently
- Build out the Squad Monitor dashboard with real data
- Start this dev blog as a living record of the journey

We're not pretending AI replaces human creativity. We're proving it **amplifies** it. One human founder + 15 specialized agents = a studio that ships.

Follow along. The code is all public. The decisions are all logged. The games are all playable.

Let's build something worth playing. 🎮

---

*First Frame Studios is built by [Joaquín Pérez del Real](https://github.com/jperezdelreal). Inspired by [Organized by AI](https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai) by Tamir Dresher.*
