# Decision: Sprite Test Viewer Updated for Cel-Shade Sprites

**Author:** Wedge (UI Dev)
**Date:** 2025-01-XX
**File:** `games/ashfall/scripts/test/sprite_poc_test.gd`

## What changed

Updated the test viewer to load cel-shade rendered sprites from the new directory structure (`res://assets/sprites/kael/` and `res://assets/sprites/rhena/`) instead of the outdated `res://assets/poc/v2/` path.

## Key decisions

1. **Auto-detect frame count** — Instead of hardcoding frame counts per animation, the viewer now loads frames sequentially (0000, 0001, ...) until a file is missing. This means new renders with different frame counts just work without code changes.

2. **Frame rate: 12fps loops, 15fps attacks** — Idle/walk use 12fps for a smooth but readable loop. Punch/kick use 15fps for snappier attack feel. These are standard fighting game rates.

3. **Replaced "lp" animation with punch/kick** — Old viewer had 3 anims (idle, walk, lp). New viewer has 4 (idle, walk, punch, kick) mapped to keys 1-4. K/R keys are now character-only (no longer doubled on 4/5).

4. **Background path changed to v1** — The `embergrounds_bg.png` only exists in `assets/poc/v1/`, not v2. Pointed the viewer there. This is still a placeholder BG — will need a proper stage asset eventually.

5. **Contact sheets ignored** — Each animation dir contains a `_sheet.png` contact sheet. The auto-detect loop naturally skips these since they don't match the `_NNNN.png` naming pattern.
