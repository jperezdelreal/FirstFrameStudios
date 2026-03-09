# Orchestration: Boba — Art Direction Document

**Date:** 2026-03-09T1200Z  
**Agent:** Boba (Art Director)  
**Mode:** Background  
**Project:** Ashfall (Godot 4)  
**Issue:** #102  

## Task Executed

**Task:** Create comprehensive art direction document for Ashfall 1v1 fighting game  
**Status:** SUCCESS — PR #113 merged, issue #102 closed

## Deliverables

**Document:** `games/ashfall/docs/ART-DIRECTION.md` (634 lines)

**Sections:**
1. **Visual Identity** — Ashfall aesthetic: hand-drawn, expressive, high-contrast fighting game art. Influences: Street Fighter hand-draw style, Persona UI clarity, Wildermyth hand-painted look.
2. **Color Palette** — Primary (skin, cloth base), Secondary (accents, UI), Highlight/Shadow system, character differentiation through color.
3. **Character Design** — Kael (composed, controlled, tied ponytail silhouette), Rhena (wild, explosive, spiky tufts silhouette). Proportions (heads 1/6 body height), facial expression as primary readability marker.
4. **Animation Philosophy** — Procedural sprites (no pre-drawn frames), state-driven poses, exaggeration for impact, personality in attack timing.
5. **VFX & Juicing** — Hit effects (flash + particles), special move VFX language (Ember Shot vs Blaze Rush visually distinct), status effects (hitstun, blocking, knockdown).
6. **UI/HUD** — Health bar design, combo counter style, round/match UI, menus, fonts, layout grid.
7. **Implementation Roadmap** — Phase 1 (fighters + 1 stage), Phase 2 (additional stages + effects), Phase 3+ (menu polish, cinematics).

**Key Decisions:**
- Procedural Canvas 2D approach ports from firstPunch → Godot `_draw()` API
- Character silhouette differentiation via hair shape as primary readability strategy
- Palette system enables P1/P2 color variants without duplicating character code
- VFX "signature language" — each special move has distinct visual effect pattern for instant recognition
- 128×128 character sprite bounding box standardized for stage layout planning

**Cross-referenced:** Nien's character sprite documentation, motion capture readability standards, fighting game UI conventions (SFV, Guilty Gear)

## Impact

**Team:** Establishes visual standards for all future Ashfall art assets (stages, effects, UI, menus). Nien's character animation work builds directly on these specs.  
**Confidence:** High — validated against GDD pillars and industry standards.  
**Blocked on:** None — standalone deliverable.

## Notes

- All color hex values cross-checked with firstPunch established palette for consistency
- Implementation examples provided for Godot GDScript `_draw()` equivalents
- Ready for stage artist onboarding in Phase 2
