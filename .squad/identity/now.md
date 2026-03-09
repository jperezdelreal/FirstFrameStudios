---
updated_at: 2026-03-20T18:00:00.000Z
focus_area: Ashfall — 1v1 Fighting Game in Godot 4
team_size: 15 specialists + Scribe + Ralph
current_phase: Sprint 1 Complete — Sprint 2 Planning Next
genre: Fighting (1v1, Tekken/Street Fighter style)
engine: Godot 4
scope: 1 stage, 2 characters (MVP)
---

# Now

## Current Focus
Ashfall — Sprint 2 (UI/Polish Phase) Planning; Character select upgrade, HUD polish, P2 animation states, post-playtest follow-ups

## Status
- Sprint 0 (Foundation): ✅ SHIPPED — All 5 PRs merged; M0-M4 gates passed; playable 1v1 prototype (tag: sprint-0-shipped)
- Sprint 1 (Art Phase): ✅ SHIPPED — All 3 PRs merged (#103, #104, #105); Character sprites, stage art, VFX complete; playable with final art (tag: sprint-1-shipped)
- Sprint 2 (UI/Polish Phase): 🔜 NEXT — Character select visual upgrade, HUD alignment, P2 animation polish, post-playtest follow-ups

## Sprint 0 Complete — Foundation Shipped (2026-03-09)

**The Result:** Ashfall 1v1 fighting game prototype is **playable, shipped, and playtested PASS**. Full game loop works (menu → select → fight → victory). 2 characters with distinct play styles (Kael shoto, Rhena rushdown). Deterministic 60 FPS physics. All P0/P1 blockers fixed in Sprint 0 PRs.

**The Metrics:**
- 5 PRs merged to main (Solo, Nien, Lando, Chewie, Wedge)
- 5 major bugs fixed (empty hitbox geometry, take_damage signature, timer draw loop, HUD score sync, integration signals)
- M0-M4 gates: ✅ ✅ ✅ ✅ ✅ (all passed)
- Ackbar playtest verdict: PASS WITH NOTES
- Time: 1 week (2026-03-02 to 2026-03-09)

**What's Shipped:**
- Complete round management (best of 3, 99s timer, KO detection, double KO handling)
- Input buffer (141 LOC, 8-frame window, SOCD resolution, motion detection)
- AI opponent with decision tree
- Procedural 8-voice SFX pool (no external audio dependencies)
- Screen shake + VFX on hit/block/KO
- HUD (health, timer, ember meter, round count, combo counter)
- Git tag: `sprint-0-shipped`

## Sprint 1 Complete — Art Phase Shipped (2026-03-20)

**The Result:** Ashfall now plays with **final character art, stage backgrounds, and character-specific VFX**. Full visual identity established. All 45 animation states per character rendered and integrated. Stage shows 3-round visual progression (dormant → warming → eruption). Ackbar playtest verdict: **PASS**.

**The Metrics:**
- 3 PRs merged to main (Nien, Leia, Bossk)
- 0 integration conflicts; 0 sprite loading failures; 0 animation crashes
- M0-M4 gates: ✅ ✅ ✅ ✅ ✅ (all passed)
- Ackbar playtest verdict: PASS
- Time: 10 days (2026-03-10 to 2026-03-20)

**What's Shipped:**
- Kael & Rhena final sprites (all ~45 P0+P1 animation states each)
- EmberGrounds stage with 3-round visual progression
- Character-specific VFX (Kael embers, Rhena bursts)
- AnimationPlayer fully wired; sprite loading pipeline complete
- Art Direction document locked (silhouettes, palettes, animation timing, naming convention)
- 60 FPS maintained across all visual effects
- Git tag: `sprint-1-shipped`

**Key Process Wins:**
- Parallel execution model validated (0 conflicts, 4 PRs merged same day)
- Scope de-scope criteria worked (P2 animation states deferred per plan; no last-minute panic)
- Art direction lock prevented rework (Boba M0 completed Days 1–2; all downstream shipped first-pass)
- Definition of Success framework proved effective (all criteria measurable and verified at sprint end)

**Next Sprint (Sprint 2 — UI/Polish Phase):** P2 animation states (throw mechanics, win/lose poses), character select visual upgrade, HUD alignment, post-playtest polish.

**What's Shipped:**
- Complete round management (best of 3, 99s timer, KO detection, double KO handling)
- Input buffer (141 LOC, 8-frame window, SOCD resolution, motion detection)
- AI opponent with decision tree
- Procedural 8-voice SFX pool (no external audio dependencies)
- Screen shake + VFX on hit/block/KO
- HUD (health, timer, ember meter, round count, combo counter)
- Git tag: `sprint-0-shipped`

**Next Sprint (Sprint 1 — Art Phase):** Final character art, stage art, animation polish. Scope TBD pending founder input.

## Active Directives
- **Joaquín never reviews code** — Jango handles all PR reviews (founder focus on vision, not implementation)
- **Wiki updates automatic** — Mace updates GitHub Wiki within 24h of milestone completion
- **Dev Diary automatic** — Mace posts discussion update within 24h of milestone completion
- **Post-milestone ceremony:** Merge PRs → Verify `Closes #N` → Wiki update → Dev Diary → Retrospective → Clean branches → Update now.md → File next milestone issues

## Key Agreements
- All agents branch from LATEST main (not old commits or non-main branches)
- File ownership is enforced — no two agents edit the same file in parallel
- project.godot gatekeeper: Jango (designate ONE agent per wave to modify it)
- PR template required: `Closes #N` MUST be in body, not title
- Integration pass before marking milestone complete (3–5 min per build, saves hours later)

---

**Updated by Solo (Chief Architect) on 2026-03-08 after M1+M2 completion.**

We've built a solid foundation. Next: fix integration gaps, then ship character art in M3.
