---
updated_at: 2026-07-24T00:00:00.000Z
focus_area: ComeRosquillas — Homer's Donut Quest
team_size: 11 active + 3 hibernated + Scribe + Ralph
current_phase: Active development. Autonomous loop being brought online.
genre: Arcade / collectathon web game
engine: HTML + JavaScript + Canvas 2D (no framework)
scope: Web game at games/comerosquillas/. Studio autonomous infrastructure operational.
---

# Now

## Current Focus
ComeRosquillas (Homer's Donut Quest) — a browser-based arcade game built with vanilla HTML/JS/Canvas. Located at `games/comerosquillas/`.

## Status
- ComeRosquillas: 🟢 ACTIVE — `games/comerosquillas/`, HTML/JS/Canvas, playable prototype
- Autonomous Loop: 🟡 BRINGING ONLINE — ralph-watch, scheduler, heartbeat wired up
- Ashfall: ✅ ARCHIVED — 2 sprints shipped
- firstPunch: ✅ ARCHIVED — Canvas 2D prototype
- FLORA: ❄️ ON HOLD — repo created but focus shifted to ComeRosquillas

## Key Decisions
- **ComeRosquillas is the active game** — arcade web game, no framework, pure HTML/JS/Canvas
- **Autonomous squad loop is priority** — ralph-watch runs continuously, scheduler creates issues, agents work them
- **Joaquín never reviews code** — Jango handles all PR reviews
- **Blog patterns adopted** — TLDR convention, issue templates, heartbeat cron, archive/notify workflows

## Next Actions
1. Get ralph-watch running persistently (autonomous loop)
2. Ship ComeRosquillas gameplay features via squad issues
3. Set up dev server for local testing
4. Iterate on game mechanics through playtest → issue → fix cycle

## Project History (Summary)
- **Ashfall:** 2 sprints shipped (Sprint 0 foundation + Sprint 1 art). Archived.
- **firstPunch:** Canvas 2D prototype. Archived.
- **FLORA:** Repo created, scaffolded. On hold — focus shifted to ComeRosquillas.

## Active Directives
- **Repo autonomy** — Agents can create public repos on demand without prior approval. They decide name, agent assignments, and everything needed for side projects. Full autonomy in repo management. (Directive 2026-03-11, Joaquín)
- **Joaquín never reviews code** — Jango handles all PR reviews (founder focus on vision, not implementation)
- **Wiki updates automatic** — Mace updates GitHub Wiki within 24h of milestone completion
- **Dev Diary automatic** — Mace posts discussion update within 24h of milestone completion
- **Post-milestone ceremony:** Merge PRs → Verify `Closes #N` → Wiki update → Dev Diary → Retrospective → Clean branches → Update now.md → File next milestone issues

## Key Agreements
- All agents branch from LATEST main (not old commits or non-main branches)
- File ownership is enforced — no two agents edit the same file in parallel
- PR template required: `Closes #N` MUST be in body, not title
- Integration pass before marking milestone complete (3–5 min per build, saves hours later)

---

**Updated by Jango (Tool Engineer) on 2026-07-24 — shifted focus to ComeRosquillas, autonomous loop online.**
