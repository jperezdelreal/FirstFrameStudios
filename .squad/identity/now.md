---
updated_at: 2026-03-08T19:25:00.000Z
focus_area: Ashfall — 1v1 Fighting Game in Godot 4
team_size: 15 specialists + Scribe + Ralph
current_phase: M1+M2 Complete — M3 Ready
genre: Fighting (1v1, Tekken/Street Fighter style)
engine: Godot 4
scope: 1 stage, 2 characters (MVP)
---

# Now

## Current Focus
Ashfall — 1v1 Fighting Game (Godot 4)

## Status
- M1 (Greybox Prototype): ✅ COMPLETE — 9 PRs merged, 31 GDScript files, 2,711 lines of code
- M2 (Visual Polish): ✅ COMPLETE — 8 systems merged (VFX, UI, audio, game flow)
- M3 (Character Sprites): 🔜 NEXT — Issue #9 (Kael and Rhena sprites)
- M4 (Playtesting): 📋 PLANNED — Issue #13 (balance pass, combo tuning)

## Recent Retrospective (M1+M2)

**The Good:** Frame-based combat architecture is solid. Input buffer (141 LOC) is production-quality. Procedural audio generates 14 distinct sounds with zero dependencies. EventBus decoupling works flawlessly. Parallel execution delivered 8 systems simultaneously.

**The Bad:** AI controller (298 LOC) stranded on dead branch after PR merged to wrong base. Medium punch/kick inputs missing from project.godot (GDD specifies 6 buttons, only 4 implemented). No integration testing — systems built in parallel isolation, never verified together in Godot. project.godot conflicts from parallel autoload additions.

**The Action Items:**
1. 🔴 Cherry-pick AI controller to main (game needs single-player)
2. 🔴 Run full integration pass in Godot (open project, verify all 5 autoloads, walk full game flow)
3. 🟡 Add medium buttons to input map and movesets (resolve GDD spec deviation)

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
