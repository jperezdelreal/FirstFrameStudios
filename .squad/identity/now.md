---
updated_at: 2026-03-11T08:00:00.000Z
focus_area: FLORA — Sprint 0 Ready
team_size: 11 active + 3 hibernated + Scribe + Ralph
current_phase: Infrastructure complete. FLORA repo live. Ready for Sprint 0.
genre: Cozy gardening roguelite
engine: Vite + TypeScript + PixiJS v8
scope: Studio hub complete; FLORA repo created with squad infrastructure
---

# Now

## Current Focus
FLORA infrastructure complete. All systems go for Sprint 0.

## Status
- Studio Hub Restructure: ✅ COMPLETE — team.md, routing.md, README, labels, workflows, ralph-watch, scheduler
- FLORA Repo: ✅ LIVE — https://github.com/jperezdelreal/flora — Vite+TS+PixiJS scaffolded, .squad/ initialized, 11 agents chartered
- Ashfall: ✅ ARCHIVED — 2 sprints shipped, games/ gitignored, issues closed, releases deleted
- firstPunch: ✅ ARCHIVED — Canvas 2D prototype

## Key Decisions
- **Hybrid Architecture (Option C) approved** — FirstFrameStudios = studio hub (parent squad), game repos = subsquads inheriting via `squad upstream`
- **FLORA selected as next game** — Cozy/nature genre, Vite + TypeScript + PixiJS stack
- **11 agents active for FLORA**, 3 hibernated (Leia, Bossk, Nien) — hibernation happens when FLORA repo is created
- **Blog patterns adopted** — TLDR convention, issue templates, heartbeat cron, archive/notify workflows

## Next Actions
1. Create FLORA repo (`jperezdelreal/flora`)
2. Scaffold Vite + TypeScript + PixiJS project
3. Run `squad init` + `squad upstream add FirstFrameStudios`
4. Set up CI/CD, issue templates, project board
5. Begin FLORA Sprint 0

## Ashfall History

### Sprint 0 — Foundation Shipped (2026-03-09)

**The Result:** Ashfall 1v1 fighting game prototype is **playable, shipped, and playtested PASS**. Full game loop works (menu → select → fight → victory). 2 characters with distinct play styles (Kael shoto, Rhena rushdown). Deterministic 60 FPS physics. All P0/P1 blockers fixed in Sprint 0 PRs.

**The Metrics:**
- 5 PRs merged to main (Solo, Nien, Lando, Chewie, Wedge)
- 5 major bugs fixed (empty hitbox geometry, take_damage signature, timer draw loop, HUD score sync, integration signals)
- M0-M4 gates: ✅ ✅ ✅ ✅ ✅ (all passed)
- Ackbar playtest verdict: PASS WITH NOTES
- Time: 1 week (2026-03-02 to 2026-03-09)

### Sprint 1 — Art Phase Shipped (2026-03-20)

**The Result:** Ashfall now plays with **final character art, stage backgrounds, and character-specific VFX**. Full visual identity established. All 45 animation states per character rendered and integrated. Stage shows 3-round visual progression (dormant → warming → eruption). Ackbar playtest verdict: **PASS**.

**The Metrics:**
- 3 PRs merged to main (Nien, Leia, Bossk)
- 0 integration conflicts; 0 sprite loading failures; 0 animation crashes
- M0-M4 gates: ✅ ✅ ✅ ✅ ✅ (all passed)
- Ackbar playtest verdict: PASS
- Time: 10 days (2026-03-10 to 2026-03-20)

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

**Updated by Solo (Chief Architect) on 2026-03-11 after studio restructuring (E1+E8).**

Studio hub established. Next: create FLORA repo and scaffold the project.
