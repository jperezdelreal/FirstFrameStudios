# 2026-03-10T07:44Z: Boba Art Director Sprite Review

**Actor:** Boba (Art Director)  
**Subject:** Nien Contact Sheet Review (FLUX PoC)  
**Status:** COMPLETE

---

## Review Summary

Boba completed visual assessment of 3 Nien contact sheets (idle, walk, LP). Full review document in `.squad/decisions/inbox/boba-sprite-review.md`.

---

## Verdict: NEEDS WORK

**IDLE:** Boots visible (GDD violation — character requires barefoot). Skin tone inconsistency (frames 4-5 warmer than 1-3, 6-8). Motion reads well.

**WALK:** Barefoot/sandals correct. Leg alternation broken — both legs stay mostly in same position (reads as "bounce idle" not "walk"). Silhouette strong.

**LP:** **FAIL** — catastrophic style break. Frames 1-6 have pale skin + brown boots (wrong character). Frames 7-12 have warm orange skin + sandals (correct). Fire ember effect on frames 4-6 is excellent concept but frames need regeneration.

---

## Actionable Next Steps

1. Standardize reference to Walk frames (frames 7-12 of LP also match): warm orange skin, sandal wraps, stockier proportions
2. Regenerate IDLE with explicit barefoot/sandal prompt, using Walk frames as reference
3. Regenerate LP frames 1-6 to match frames 7-12 style (keep fire ember effect concept)
4. Fix Walk leg alternation (either regenerate with better motion description or manually reorder frames)
5. Color consistency pass across all animations once regenerated

---

## What's Working

- Background removal (rembg) is excellent
- Fighting game silhouettes are clear and readable
- Fire monk identity comes through when prompted correctly
- The "correct" Kael (Walk, LP 7-12) has good martial artist energy

---

## Recommendation

**Do NOT proceed to full animation set production** until barefoot + consistent style is locked. One more PoC iteration with tighter prompting should get us there. Consider creating a Kael reference sheet PNG for every generation prompt.

---

*— Scribe*
