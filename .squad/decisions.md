# Squad Decisions

> Active decisions the team must respect. Historical decisions in `decisions-archive.md`.
> Format: see `templates/decision-record.md`.

---

## Studio Directives

### Joaquin never reviews code
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Jango handles all PR reviews. Founder focuses on vision, not implementation.

### GitHub-First Development
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Use GitHub's full potential — Issues, Projects, PRs, Actions. Everything active and visible.

### Repo Autonomy
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
Agents can create public repos on demand without prior approval. Full autonomy in repo management.

### Visual Quality Standard
**By:** Joaquin | **Date:** 2026-03-10 | **Status:** Active
Games must be visually impressive. No cheap-looking prototypes. Learn new frameworks, show off.

### No Podcaster / Text-to-Speech
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
No TTS integration. Out of scope for FFS.

### Tool Engineer Autonomy
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Jango has NO bandwidth limit. Full freedom to propose and create tools, scripts, automations.

### Wiki & Dev Diary Auto-Publish
**By:** Joaquin | **Date:** 2026-03-08 | **Status:** Active
Wiki and devlog updates are automatic after each milestone. Mace's responsibility. Never manual.

### GitHub Pages Architecture
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
- FFS Hub Page: brand, identity, studio presentation (NOT game content)
- Game Pages: showcase, screenshots, changelog, playable demo
- Consistent Astro template, per-game branding. Push-to-main deploys.

### FFS Homepage Locked
**By:** Joaquin | **Date:** 2026-03-11 | **Status:** Active
FFS homepage is practically perfect. Do NOT redesign. Blog auto-publishes progress from game repos.

### Governance v2 — Tier Restructure
**By:** Joaquin | **Date:** 2026-03-12 | **Status:** Active
- T0 ultra-minimal: only new games + principles.md + critical .squad/ structural changes
- T1 Lead-only: no founder approval. Solo decides.
- No agent-to-founder escalation at T1. Chain: agents -> Solo -> Founder (T0 only).
- .squad/ refactors split: content refactors = T1, structural/workflow = T0

---

## Active Architecture Decisions

### ComeRosquillas: Modular Architecture
**By:** Chewie | **Date:** 2026-03-11 | **Status:** Implemented
Split game.js monolith into 5 modules: config.js, audio.js, renderer.js, game-logic.js, main.js. Vanilla JS, no bundler, script tag load order.

### ComeRosquillas: CI Pipeline
**By:** Jango | **Date:** 2026-03-11 | **Status:** Implemented
GitHub Actions CI for linting, build verification, and Pages deployment on push to main.

### Multi-Repo Hub Architecture
**By:** Solo | **Date:** 2026-03-11 | **Status:** Active
FFS is hub-and-spoke. Hub = no game code, only infrastructure. Each game/tool has its own repo with `squad upstream` to hub. Skills, quality gates, and governance cascade down.

### Ashfall: Shelved
**By:** Team | **Date:** 2026-03-10 | **Status:** Closed
Fighting game too complex for AI-only tuning. Studio pivoting to simpler genres.

---

## Active Process Decisions

### PR Convention
All PRs must include `Closes #N` in body. Branch naming: `squad/{issue-number}-{slug}`.

### Integration Pass Required
After parallel agent work, Solo verifies systems connect before next wave. Hard gate.

### Backlog Automation
Scan code for TODOs, auto-create issues. Lead adjusts workload independently.

### Solo/Jango Role Split
**Date:** 2026-03-09 | Solo = architecture deep work. Jango = tooling + PR reviews + CI. Mace = ops, sprint planning, blocker tracking.

---

*Last cleaned: 2026-03-12. Previous content archived to `decisions-archive.md`.*
