# Art Direction Lock — Sprint 1 M0

**Author:** Boba (Art Director)
**Date:** 2026-03-09
**Status:** Active
**Scope:** Ashfall — all visual output

## Decision

Art direction for Ashfall is formally locked in `games/ashfall/docs/ART-DIRECTION.md` (PR #113, Issue #102).

## Key Visual Rules (Team-Binding)

1. **Silhouette First** — Characters must be identifiable by outline alone at 64×64px. Binary pass/fail.
2. **Accent color = identity** — Kael is blue (`#4073D9`), Rhena is orange (`#F28C1A`). This applies to VFX, damage numbers, ember aura, and any future UI elements.
3. **No pure black/white** — Darkest allowed: `#0D0D1A`. Brightest allowed: `#E0DBD1`. Keeps everything in the warm volcanic world.
4. **P1 palettes are canon.** P2 exists only for mirror matches.
5. **Procedural art only** — All character rendering is `_draw()` code. No external PNG sprites for fighters.
6. **Stage escalation is mandatory** — EmberGrounds must visually transform across rounds (Dormant → Warming → Eruption).
7. **VFX is character-tinted** — Hit sparks, KO bursts, damage numbers, and flash colors must use the attacker's character palette.
8. **Animation timing must match frame-data.csv** — No visual-only timing. If LP is 4+2+6 frames, the sprite must complete in exactly 12 frames at 60fps.

## Impact

- Nien, Leia, Bossk, Chewie all reference this document for their Sprint 1 deliverables
- Mace enforces naming convention and palette compliance at PR review
- No visual changes without Art Director sign-off after this lock

## Why

Art direction lock prevents rework. Sprint 1 has 4 parallel workstreams (sprites, stage, VFX, animation). If visual direction shifts mid-sprint, all 4 streams must restart. Locking early is the single highest-leverage production decision for art phase.
