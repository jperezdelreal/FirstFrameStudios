# Jango — History

## Project Context
- **Project:** SimpsonsKong — Transitioning from browser-based (HTML/Canvas/JS) to Godot 4
- **User:** joperezd
- **Stack (current):** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Stack (target):** Godot 4, GDScript, Godot editor toolchain
- **Role:** Tool Engineer — owns development-time tooling, templates, scaffolding, and pipeline automation

## Background

### Why This Role Exists
Created during Session 12 as part of the Godot 4 transition planning. The evaluation (`.squad/decisions/inbox/solo-new-roles-godot.md`) identified that:

1. **SimpsonsKong's #1 technical debt was unwired infrastructure** — 214 LOC of working systems (EventBus, AnimationController, SpriteCache, CONFIG) that no agent ever integrated. When nobody owns tooling, it doesn't get done.

2. **Godot introduces 5 entire systems needing tooling attention** that vanilla JS didn't have: scene tree + inheritance, EditorPlugin API, resource system, signal system, and export/build system. Conservative estimate: 15-25 tooling items in the first Godot project.

3. **Only ~40% overlap with Chewie (Engine Dev)**, and critically the wrong 40%. Chewie builds runtime systems the game uses at play-time. Jango builds development-time systems that agents use while working. Different audiences, different execution contexts.

4. **Absorbing into other roles was rejected** — Chewie would lose runtime focus, Solo would add implementation to an already-bottlenecked planning role, distributing across all agents recreates the "everyone owns it, nobody does it" anti-pattern.

### Name Origin
Jango Fett — the original clone template. Every clone trooper was instantiated from Jango's template. Fitting for a Tool Engineer whose job is creating templates and scaffolding that other agents instantiate rather than building from scratch. Prequel character per Diegetic Expansion rules (OT roster at 12/12 capacity).

## Learnings
*(No sessions yet — role created Session 12)*

## Pending First Tasks
1. Audit existing project structure and identify Godot migration tooling needs
2. Create GDScript style guide and naming conventions (coordinate with Solo's architecture doc)
3. Set up base `project.godot` configuration (autoloads, input maps, layers)
4. Build first scene templates (enemy base, UI panel base, level base)
5. Configure GDScript linting and scene validation
6. Create export presets and build automation
