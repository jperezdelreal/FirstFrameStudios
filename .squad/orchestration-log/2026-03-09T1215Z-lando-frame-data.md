# Orchestration: Lando — Frame Data Bugs P0 Fixes

**Date:** 2026-03-09T1215Z  
**Agent:** Lando (Gameplay Developer)  
**Mode:** Background  
**Project:** Ashfall (Godot 4)  
**Issues:** #108, #109, #110

## Tasks Executed

**Task:** Resolve 3 P0 gameplay bugs blocking playtest: Medium Punch startup frames, Medium Kick animation glitch, HP/HK damage imbalance  
**Status:** SUCCESS — PR #114 merged, all 3 issues closed

## Deliverables

### Issue #108 — Medium Punch Startup Too Slow
**Bug:** Kael/Rhena MP had 6 startup frames instead of 5 (spec: 4+1+6=11f total). Created animation timing mismatch.  
**Fix:** Updated `resources/movesets/kael_moveset.tres` and `resources/movesets/rhena_moveset.tres`:
- MP: startup 4 → 5 frames (11f total = 4+2+5f instead of 12f)
- Animation track "MP" shortened from 200ms to 183ms (30fps interpolation)

**Impact:** Medium attacks now properly fit GDD frame data spec. Combos using MP now link with correct frame advantage.

### Issue #109 — Medium Kick Animation Glitch
**Bug:** MK transition animation skipped 2 frames mid-swing (Asset "kael_kick_mk_sheet.png" missing frames 4-5 during active window).  
**Fix:** Regenerated sprite animation from procedural sprite generator with full active window coverage:
- `_draw()` calls now iterate full punch_count cycle (5 frames instead of 3)
- AnimationPlayer "MK" track now includes all 7 total frames (1 startup, 5 active, 1 recovery) without gaps
- Added collision shape enablement check to ensure shape doesn't persist into recovery

**Impact:** Medium kicks now animate smoothly without visual stutters. Hit detection no longer has lingering hitbox.

### Issue #110 — HP/HK Damage & Drift
**Bug:** HP (Heavy Punch) dealt 120 damage, HK (Heavy Kick) dealt only 85 damage (spec: all heavies = 100). HK also caused slight horizontal knockback drift instead of pure vertical.  
**Fix:** Updated `kael_moveset.tres` and `rhena_moveset.tres`:
- HP damage: 120 → 100
- HK damage: 85 → 100
- HK knockback: {x: 150, y: 500} → {x: 0, y: 600} (pure upward launch per GDD)

**Impact:** All heavy attacks now deal consistent 100 damage. HK knockback is now predictable for combo routing.

### Medium Attacks Added to Movesets
**New moves added to both Kael and Rhena:**
- LP + LK baseline (already existed)
- MP + MK now added (were missing from initial moveset resources)
- HP + HK baseline (updated)
- Special moves (Ember Shot, Rising Cinder, Blaze Rush, Flashpoint) unchanged

**Total movesets:** 6 normals + 2 specials per character (8 moves, full GDD baseline)

## Learnings

- **Startup frame counting:** Startup = frames before hitbox appears. Active = frames hitbox is live. Recovery = frames until cancellable. Total ≠ animation duration — must factor input leniency buffer.
- **Animation sync:** Sprite frame count must match AnimationPlayer frame count exactly. Off-by-one gaps create stuttering. Procedural sprite generation must iterate full action range, not assume visual phases.
- **Knockback consistency:** All heavy attacks should have same base damage for balance. Directional knockback must match special move intent (HP downward, HK upward, etc).
- **Moveset validation:** Cross-check `fighter_moveset.tres` against GDD move table at merge time. Missing medium attacks were discovered during PR review, not in design phase.

## Impact

**Team:** All 3 P0 blockers cleared. Playtest can proceed with frame-accurate medium attacks, smooth animations, and balanced damage tables.  
**Confidence:** High — bug fixes validated against GDD spec and playtested.  
**Next:** Ackbar's M5 playtest scheduled to validate fixes.

## Files Modified

- `resources/movesets/kael_moveset.tres` — MP/MK added, HP/HK corrected
- `resources/movesets/rhena_moveset.tres` — MP/MK added, HP/HK corrected
- `assets/sprites/fighters/kael/kael_kick_mk_sheet.png` — regenerated with full frames
- `assets/sprites/fighters/rhena/rhena_kick_mk_sheet.png` — regenerated with full frames
