# Ashfall Sprint 2 — Success Report

> Sprint 2: Visual Quality & Code Hardening
> "Guilty Gear quality, not 1982" → "At least Sega Mega Drive quality"

## Sprint Goal
Transform Ashfall from a functional prototype into a visually compelling fighting game.

## Verdict: ✅ PASS WITH NOTES
Per Ackbar's integration test (PLAYTEST-REPORT-SPRINT2.md).

## What Shipped

### Phase 0: Code Hardening (14 issues fixed)
- 8 PRs merged: VFX determinism (#124 P0), null safety (#125, #127), type annotations (#128, #129), unsafe casts (#132), precision fixes (#130, #134, #135), UI timing (#122, #123, #126), test infrastructure (#131), CI gate (#133)
- Integration gate GitHub Action now runs on every PR
- PR template with pre-merge checklist
- GDScript Standards document (GDSCRIPT-STANDARDS.md)

### Phase 1: Camera & Sprites
- Dynamic camera zoom — distance-based, Guilty Gear-style framing (PR #144)
- Sprite detail upgrade — 11 new palette colors, detailed anatomy, clothing, ember VFX per character (PR #147)

### Phase 2: Stage & VFX
- Ember Grounds art upgrade — cracked obsidian floor, lava channels, 3-round color progression, parallax depth (PR #145)
- Hit feedback VFX — light/medium/heavy hit sparks, screen shake, KO slow-mo, Ember stage integration (PR #146)

### Phase 3: HUD & UI
- Health bars with gradient (green→yellow→red) and ghost damage
- Round indicators with FINAL ROUND detection
- Timer with urgency pulse at <10s
- Combo counter with per-player display
- Ember meter with threshold markers (25 EX, 50 Ignition)
- Enhanced announcer text with color-coding (PR #149)

### Phase 4: AI & Combat Feel
- AI aggressiveness — 3 difficulty levels (Easy/Normal/Hard), 4-band spacing intelligence, anti-stall safeguards (PR #148)
- Combat feel — fixed block system, MoveData→Hitbox wiring, 6-button input, GDD frame data alignment (PR #150)

## Stats
- **PRs merged:** 15
- **Issues closed:** 14 (code quality) + Sprint 2 feature work
- **Files changed:** ~50+
- **Lines changed:** ~3,000+ insertions
- **Agents involved:** Bossk, Wedge, Chewie, Lando, Jango, Tarkin, Greedo, Ackbar, Nien, Leia, Mace, Yoda, Solo

## Sprint 1 Lessons Applied
- ✅ Zero `:=` with dict/array in Sprint 2 code
- ✅ Integration gate runs before merge
- ✅ All new code uses `_physics_process` for gameplay
- ✅ Explicit types everywhere
- ✅ `absf()`/`absi()` instead of `abs()`

## Notes for Sprint 3
From Ackbar's playtest report (non-blocking):
- Walk state missing medium attack transitions
- Hardcoded hitbox paths in some files
- Untyped dict access in stage rendering
- Some unused signals to clean up

## What's Next
Sprint 3: Audio Phase — SFX, procedural music, announcer voice

---

*Mace (Producer) — Sprint 2 Success Report, 2026-03-27*
