---
updated_at: 2026-03-11T09:53:00.000Z
focus_area: Studio Hub — orchestrating active game repos
team_size: 11 active + 3 hibernated + Scribe + Ralph
current_phase: Hub operational. Two active game repos, monitor repo, autonomous loop ready.
genre: N/A (studio hub)
engine: N/A (studio hub)
scope: Studio hub managing active projects via upstream. No game code lives here.
---

# Now

## Next Session Plan (Session 3)

**Start with:** "Continuemos"

### Step 1: Ralph ON (5 min)
- Fix schedule.json emojis (ASCII-safe)
- Start ralph-watch.ps1 in persistent mode (-MaxRounds 0)
- Close issue #152

### Step 2: Game Development — ALL repos in parallel
Ralph scans all repos and picks up open issues. The squad works on:

**ComeRosquillas** (8 open issues → ship to v1.0):
- Existing issues #1-#8 cover gameplay polish, UI, audio, mobile
- Goal: first shipped game from the studio
- Pages already live at jperezdelreal.github.io/ComeRosquillas/

**Flora** (Kickoff → Sprint 0):
- T3 already approved (Joaquin selected Flora)
- Solo runs Kickoff ceremony (T2, no founder needed)
- Yoda drafts GDD, Solo does architecture, Jango sets up CI/Pages
- Stack: Vite + TypeScript + PixiJS v8

**Squad Monitor** (5 open issues):
- Vite dashboard for agent activity
- Jango owns, low priority vs games

### Step 3: Founder role
- Joaquin does NOT need to approve anything until ship/no-ship
- All work is T0-T2 (auto-approved or agent-reviewed)
- Check Status page and Board when curious
- Say "Ralph, status" anytime for a snapshot

### Key URLs
- Hub: https://jperezdelreal.github.io/FirstFrameStudios/
- Status: https://jperezdelreal.github.io/FirstFrameStudios/status/
- ComeRosquillas: https://jperezdelreal.github.io/ComeRosquillas/play/
- Board: https://github.com/users/jperezdelreal/projects/5

## Current Focus
FFS is the **Studio Hub** — no game code, only studio infrastructure. Games live in their own repos and inherit via `squad upstream`.

## Active Projects
- **ComeRosquillas** — https://github.com/jperezdelreal/ComeRosquillas (HTML/JS/Canvas arcade)
- **FLORA** — https://github.com/jperezdelreal/flora (Vite + TypeScript + PixiJS cozy roguelite)
- **Squad Monitor** — https://github.com/jperezdelreal/ffs-squad-monitor (dashboard)

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
