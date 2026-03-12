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

### Skill Template Update — SKILL.md + REFERENCE.md Split
**By:** Jango | **Date:** 2026-01-30 | **Status:** Implemented
Two-file structure for skills: SKILL.md (max 5KB) with frontmatter, core patterns, and key examples; REFERENCE.md (on-demand) with deep dive, full examples, and implementation guides.

---

## Active Process Decisions

### Priority & Dependency System (P0-P3)
**By:** Solo | **Date:** 2026-03-12 | **Status:** Active (T1, Founder-reviewed)
Priority (P0-P3) determines execution order; Tiers (T0-T3) determine approval authority. Independent axes.
- P0=Blocker, P1=Sprint-critical, P2=Normal (default), P3=Nice-to-have
- Dependencies tracked via `blocked-by:*` labels + issue body `## Dependencies` section
- Blocked work: prepare (tests, scaffold, draft PR) but don't merge until blocker resolved
- Emergency follow-up auto-labeled P1; Lead can bump to P0
- Ralph auto-unblocks after 24h when blocker closes; Lead can re-block
- G13: Advisory inflation warning at >20% P0/P1
- Full design: `.squad/decisions-archive.md`

### PR Convention
All PRs must include `Closes #N` in body. Branch naming: `squad/{issue-number}-{slug}`.

### Integration Pass Required
After parallel agent work, Solo verifies systems connect before next wave. Hard gate.

### Backlog Automation
Scan code for TODOs, auto-create issues. Lead adjusts workload independently.

### Solo/Jango Role Split
**Date:** 2026-03-09 | Solo = architecture deep work. Jango = tooling + PR reviews + CI. Mace = ops, sprint planning, blocker tracking.

---

### GitHub Actions Cron Reduction
**By:** Jango (Tool Engineer) | **Date:** 2025-07-16 | **Status:** Implemented
Reduced scheduled workflow frequency to lower monthly GitHub Actions run volume from ~4,320 to ~900.
- `squad-heartbeat.yml`: `*/15 * * * *` → `0 * * * *` (720 runs/month)
- `squad-notify-ralph-heartbeat.yml`: `*/30 * * * *` → `0 */4 * * *` (180 runs/month)
- Event triggers unchanged; only scheduled polling reduced

### Ralph-Watch Guardrails (G10 + G11)
**By:** Jango (Tool Engineer) | **Date:** 2026-03-12 | **Status:** Implemented
Two safeguards in ralph-watch.ps1 to prevent wasted cycles and ensure downstream repo currency.
- **G10 — Roster Check:** Ralph skips repos without `.squad/team.md` containing `## Members` section
- **G11 — Upstream Sync:** After git pull, hub syncs `.squad/skills/`, quality-gates.md, governance.md, decisions.md to downstream repos with `.squad/` directory; auto-commits as "chore: upstream sync from hub"
- Both features support DryRun mode; ASCII-safe logging for Windows PowerShell 5.1

### Guardrails G1-G14 Implementation
**By:** Solo (Lead / Chief Architect) | **Date:** 2026-07-25 | **Status:** Implemented
Distributed guardrails across governance files per their operational domain:
- **Scribe charter:** G1 (decisions.md max 5KB auto-archive), G2 (SKILL.md max 5KB overflow), G3 (log cleanup >30 days)
- **Governance.md:** G5 (hub roster infra-only), G7 (now.md single source), G8 (squad.agent.md hash consistency), G9 (cron ≥1h), G12 (identity docs no rejected options)
- **Ceremonies.md:** G4 (quality-gates review at kickoff), G6 (cleanup at closeout), G14 (squad.config.ts project name)
- Changes <50 lines total; no content removed, only surgical additions

### Priority & Dependency System (P0-P3)
**By:** Solo (Lead / Chief Architect) | **Date:** 2026-07-26 | **Status:** Implemented (T1 Authority)
Implemented priority and dependency tracking system per T1 governance. Independent from approval tiers.
- **Levels:** P0=Blocker, P1=Sprint-critical, P2=Normal (default), P3=Nice-to-have
- **Dependencies:** `blocked-by:*` labels + issue body `## Dependencies` section
- **Blocked work rule:** Prepare (tests, scaffold, draft PR) but don't merge until blocker resolves
- **Emergency follow-up:** Auto-labeled P1; Lead can bump to P0
- **Ralph auto-unblock:** 24h after blocker closes; Lead can re-block
- **G13 advisory:** No CI enforcement on priority inflation; Lead judgment prevails
- **No preemption:** P0 work finishes current task first, doesn't interrupt

---

*Last cleaned: 2026-03-12. Previous content archived to `decisions-archive.md`.*
