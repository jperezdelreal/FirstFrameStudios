# New Project Playbook — First Frame Studios

> Compressed from 45KB. Full version: new-project-playbook-archive.md

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
---

## Why This Exists
firstPunch taught us that starting a project right determines everything that follows. We went from zero to a playable build in 30 minutes — and then spent months untangling decisions we made in those first 30 minutes (god-scene in gameplay.js, 214 LOC of unwired infrastructure, state machines with missing exit paths, timer conflation bugs). 
This playbook ensures that every new project starts with the clarity firstPunch earned through pain. It is genre-agnostic, tech-agnostic, and IP-agnostic. The ~70% of what makes First Frame Studios effective — principles, processes, team coordination, design methodology, quality standards — transfers to any project. Only ~30% is tech-specific and needs adaptation.
---

## 1. Pre-Production Phase (Before Writing Code)
Pre-production is where we earn the right to write code. Every hour invested here saves a week during production. firstPunch proved this: our 9-reference-game study produced a GDD that prevented dozens of design dead ends. The hours we *didn't* spend on pre-production (tech evaluation, architecture planning) cost us months of rework.
---
### 1.1 Genre Research Protocol
---
### 1.2 IP Assessment
| Factor | Original IP | Licensed IP |
| **Design freedom** | Total — we define the world | Constrained — the source material dictates |
| **Character mechanics** | Archetypes from genre conventions | Derived from character personality (Principle #3: IP Is the Soul) |
---
---
---
---

## 2. Sprint 0 — Foundation (First Week)
Sprint 0 is about proving the engine and the team, not shipping the game. The goal is razor-sharp: **"Does the core action feel right?"** Everything else is Sprint 1+.
---
### 2.1 Repository Setup (Engine-Agnostic Checklist)
---
### 2.2 Squad Adaptation
---
### 2.3 Genre Skill Creation
---
### 2.4 Architecture Proposal
---
| Genre | Core Verb | Target | Feedback | Minimum Playable |
---
---

## 3. Production Phases
Production is where the game gets built. The playbook here is about *rhythm* — how to organize work, capture knowledge, and maintain quality across sprints.
---
### 3.1 Phase Planning Methodology
| Priority | Definition | Rule |
| **P0** | Game-breaking — can't play without it | Fix before anything else. Drop current work. |
| **P1** | Core experience — the game isn't the game without this | Complete before moving to P2. These define the minimum shippable product. |
| **P2** | Polish & depth — elevates good to great | Work on after P1 is stable. These are the "wow" moments. |
---
---
---

## 4. Technology Transition Checklist
When changing engines, languages, or fundamental tech stack. We did this once (Canvas 2D → Godot 4) and documented the pattern. Here it is, generalized.
---
### 4.1 What Transfers (Keep These)
| Category | Examples | Effort to Transfer |
| **Architecture patterns** | State machines, event-driven communication, entity composition, module boundaries | Zero — these are concepts, not code |
| **Design documents** | GDD, competitive analysis, genre research, balance targets | Zero — copy directly |
| **Skills methodology** | Skill template, skill capture rhythm, reading lists | Zero — methodology is tech-agnostic |
---

## 5. Language/Stack Flexibility Matrix
**The key insight: ~70% of what makes First Frame Studios effective is tech-agnostic. Only ~30% is tech-specific.**
The 70% that travels everywhere:
---
### Compatibility Matrix
| Tech Stack | Language Shift | Engine Shift | Paradigm Shift | Migration Effort | Notes |
| **Godot / GDScript** | Python-like → ours | Godot editor, scene/node | Signal-based, scene tree | — (current target) | Our next project's stack |
| **Godot / C#** | GDScript → C# | Same engine | Same + stronger typing | **S** | Same engine, different language. Viable for performance-critical paths. |
---
---

## 6. Anti-Bottleneck Patterns
Bottlenecks are the #1 velocity killer. Every project has them. The goal isn't to eliminate bottlenecks (impossible) — it's to detect them early and resolve them fast.
---
### 6.1 Bottlenecks We Hit in firstPunch (And How to Prevent Them)
| Bottleneck | What Happened | Root Cause | Prevention |
| **Single-agent overload** | Lando carried 50% of backlog (26/52 items) | No content developer. Gameplay + content on one person. | **Load cap: No agent >20% of any phase.** If exceeded, split the domain or add a parallel contributor. |
| **God-scene accumulation** | `gameplay.js` grew to 695 LOC touching every system | No module boundaries defined upfront. Easy to add "just one more function" to the central file. | **Module boundaries in Sprint 0.** Architecture proposal defines what each file owns BEFORE code is written. |
| **Build-don't-wire** | 214 LOC of working infrastructure (EventBus, AnimationController, SpriteCache, CONFIG) never connected to consumers | Agents build systems in isolation. Integration is unglamorous. Nobody owns it. | **Every infrastructure PR must include wiring to at least one consumer.** No orphan systems. Quality gate C5 enforces this. |
---
---
---
---

## Appendix A: Day 1 Quickstart
For the impatient — here's the absolute minimum to start a new project. After this, follow the full playbook.
**Hour 1: Decide**
---

## Appendix B: Template — Pre-Production Checklist
Copy this checklist into a new project's `analysis/` directory and check items as completed.
```markdown
# Pre-Production Checklist — [Project Name]

> Compressed from 45KB. Full version: new-project-playbook-archive.md


## Genre Research
- [ ] 7-12 reference games identified
- [ ] Each played for 30+ minutes with analytical notes

## IP Assessment
- [ ] Original vs. licensed determined
- [ ] IP authenticity checklist defined (if licensed)

## Technology Selection
- [ ] 3-5 candidates identified
- [ ] 9-dimension scoring matrix completed

## Team Assessment
- [ ] Skill transfer audit complete
- [ ] Gaps identified

## Competitive Analysis
- [ ] 5-10 competitors identified
- [ ] Differentiation defined

## Sprint 0 Ready
- [ ] Repository setup checklist complete
- [ ] Architecture proposal written and reviewed
---