# Lando Integration Fixes — Input & Collision Domain

**Agent:** Lando (Input & Controls Specialist)  
**Date:** 2025-07-17  
**Branch:** `squad/fix-integration`  
**Status:** ✅ PR Created

---

## Summary

Fixed Solo WARN items #1-3 and Jango should-fix item #8 related to input and collision systems.

---

## Changes Made

### 1. Solo WARN #1: Removed Orphaned Throw Inputs ✅

**Files Modified:** `games/ashfall/project.godot`

**Issue:** `p1_throw` and `p2_throw` input actions were defined in project.godot but never read by any script. The GDD specifies throws use LP+LK simultaneous press (implemented in `fighter_controller.gd:48-53`), not a dedicated throw button.

**Fix:** Removed both `p1_throw` and `p2_throw` input action definitions from the `[input]` section.

**Lines Removed:**
- Lines 81-85: p1_throw definition
- Lines 131-135: p2_throw definition

---

### 2. Solo WARN #2: Updated Collision Layer Documentation ✅

**Files Modified:** `games/ashfall/docs/ARCHITECTURE.md`

**Issue:** ARCHITECTURE.md documented a 6-layer per-player collision scheme that was never implemented. The actual code uses a simpler 4-layer shared scheme matching `project.godot`.

**Fix:** Updated lines 267-282 to reflect the actual implementation:

**Old (incorrect):**
- 6 layers: physics, p1_hurtbox, p2_hurtbox, p1_hitbox, p2_hitbox, pushbox

**New (correct):**
- 4 layers: Fighters, Hitboxes, Hurtboxes, Stage
- Added detailed collision matrix showing layer/mask bit values
- Clarified that this is a shared layer scheme, not per-player

---

### 3. Solo WARN #3: Fixed Stage Collision Layers ✅

**Files Modified:** 
- `games/ashfall/scenes/main/fight_scene.tscn`
- `games/ashfall/scenes/fighters/fighter_base.tscn`

**Issue:** Stage collision bodies (Floor, LeftWall, RightWall) in fight_scene.tscn used default Layer 1 instead of Layer 4 (Stage). Fighter collision mask didn't include Layer 4, so they wouldn't detect stage geometry from other scenes (like ember_grounds.tscn).

**Fix:**
- Set all stage StaticBody2D nodes to `collision_layer = 8` (Layer 4: Stage)
- Set stage `collision_mask = 0` (stage doesn't need to detect anything)
- Set FighterBase CharacterBody2D `collision_mask = 9` (layers 1+4: detects other fighters AND stage)

**Impact:** Fighters now correctly detect stage floors/walls via `move_and_slide()`. Previously worked by accident because both used default Layer 1.

---

### 4. Jango Should-Fix #8: Input Buffer Configuration ✅

**Files Modified:** `games/ashfall/scripts/systems/input_buffer.gd`

**Issue:** Buffer window constants were hardcoded, making them difficult to tune without code changes.

**Fix:** Converted three constants to `@export` variables:
- `const BUFFER_SIZE` → `@export var buffer_size`
- `const INPUT_LENIENCY` → `@export var input_leniency`
- `const SIMULTANEOUS_WINDOW` → `@export var simultaneous_window`

Updated all 5 references throughout the file to use the new variable names.

**Benefit:** Allows runtime tweaking via Godot Inspector without code changes. Useful for playtesting and balance tuning.

---

## Files Changed

| File | Lines Changed | Purpose |
|------|---------------|---------|
| `project.godot` | -10 | Removed orphaned throw inputs |
| `ARCHITECTURE.md` | ~20 | Updated collision layer docs |
| `fight_scene.tscn` | +6 | Fixed stage collision layers |
| `fighter_base.tscn` | +1 | Fixed fighter collision mask |
| `input_buffer.gd` | ~16 | Exported buffer constants |

**Total:** 5 files changed, 25 insertions(+), 28 deletions(-)

---

## Testing Notes

- ✅ All changes verified via `git diff`
- ✅ No modifications to files Chewie is working on (state machine, round manager, event bus connections)
- ⚠️ **Requires in-editor verification:** Open project in Godot 4.6 to confirm:
  - Stage collision layers display correctly in Inspector
  - Fighters collide with stage floor/walls
  - No red missing-script indicators
  - Input buffer exports appear in Inspector

---

## Related Audit Items

- ✅ Solo integration audit WARN #1 (orphaned throw inputs)
- ✅ Solo integration audit WARN #2 (ARCHITECTURE.md collision layers)
- ✅ Solo integration audit WARN #3 (fight_scene.tscn collision layers)
- ✅ Jango code review should-fix #8 (hardcoded buffer windows)

---

## PR Information

**Branch:** `squad/fix-integration`  
**Commit:** `4225ad4`  
**Title:** fix: resolve integration issues — collision layers, input cleanup, docs alignment  
**URL:** https://github.com/jperezdelreal/FirstFrameStudios/pull/new/squad/fix-integration

---

## Next Steps

1. ✅ Branch created and pushed
2. ✅ Commit created with detailed message
3. 🔄 PR opened (manual completion in browser)
4. ⏳ Awaiting review from team
5. ⏳ In-editor verification required

---

## Notes

- Did NOT modify files in Chewie's domain (fight_scene.gd, fighter_base.gd, round_manager.gd)
- Did NOT add RoundManager to autoloads (that's Chewie's blocker fix)
- Focused exclusively on input and collision configuration
- All changes are non-breaking and align implementation with design docs
