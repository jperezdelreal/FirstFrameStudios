# Team Decisions

## Gap Analysis — Key Findings & Recommendations

**From:** Keaton (Lead)  
**Date:** 2026-06-03  
**Type:** Analysis Summary for Team  

---

### Key Findings

1. **Overall MVP completion: ~75%.** The game is playable with solid core mechanics, but two critical gaps remain.

2. **P0 miss: High score persistence** — localStorage saving was an explicit requirement that was never implemented. This is trivial (< 30 min) and should be done immediately.

3. **Biggest quality gap: Visual quality at 30%.** The user repeatedly asked for "visually modern" and "clean, modern 2D look." Current characters are basic geometric shapes — recognizable as a game, but not as a modern one. This requires an animation system (P1-8) before meaningful visual improvement is possible.

4. **Combat feel at 50%.** The mechanics *work* but lack *juice*. The #1 missing element is **hitlag** (2-3 frame freeze on impact) — a small change with massive feel improvement. After that: impact VFX, sound variation, and combo chains.

5. **Architecture is sound but needs targeted refactoring.** The gameplay scene is a "god object" handling waves, camera, background, and game state. This must be decomposed before adding levels, enemy variety, or pickups.

6. **Gameplay Dev is the bottleneck.** ~60% of the backlog routes to this role. Consider adding a VFX/Art specialist to handle visual improvements independently.

### Recommended Immediate Actions

| Priority | Action | Owner | Effort |
|----------|--------|-------|--------|
| 🔴 Now | Implement localStorage high score | UI Dev | S |
| 🔴 Now | Add kick animation + kick/jump SFX | Gameplay Dev + Engine Dev | S |
| 🟡 Next | Add hitlag on attack connect | Engine Dev | S |
| 🟡 Next | Add enemy attack throttling (max 2 attackers) | Gameplay Dev | S |
| 🟡 Next | Build animation system core | Engine Dev | L |
| 🔵 After | Combo system + jump attacks | Gameplay Dev | M |
| 🔵 After | Gameplay scene refactor | Lead | M |

### Team Recommendation

Current team (Lead, Engine Dev, Gameplay Dev, UI Dev) is sufficient for P0 and P1. For P2 (visual overhaul, enemy variety, boss), strongly recommend adding a **VFX/Art specialist** who can work on Canvas-drawn art and particle effects without blocking the engineers.

### Decision Required

Should we prioritize **combat feel** (hitlag, combos, enemy AI) or **visual quality** (animation system, character redesign) first? Both need the animation system, so P1-8 is the critical path regardless. My recommendation: **combat feel first** — a fun-feeling game with simple art beats a pretty game that feels mushy.

---

*Full analysis: `.squad/analysis/gap-analysis.md`*

---

## Backlog Expansion for 8-Person Team

**Author:** Solo (Lead)  
**Date:** 2026-06-03  
**Status:** Proposed

### Summary

Expanded the 52-item backlog to 85 items (+33 new) after analyzing what domain specialists (Boba, Greedo, Tarkin, Ackbar) would identify that the original 4-engineer team missed. Also re-assigned 28 existing items to correct specialist owners.

### Key Outcomes

1. **Lando's bottleneck eliminated:** Dropped from 26 items (50% of backlog) to 10 items focused on player mechanics. This was the #1 structural problem.

2. **Chewie freed from audio:** 7 audio items moved to Greedo. Chewie now focuses purely on engine systems (game loop, renderer, animation controller, particles, events).

3. **33 new items added — zero busywork.** Every item addresses a real gap:
   - Boba: 8 items — art foundations before art production (palette, shadows, telegraphs, style guide)
   - Greedo: 8 items — audio infrastructure before sound content (mix bus, layering, priority, spatial)
   - Tarkin: 9 items — content systems before content authoring (behavior trees, data format, pacing, wave rules)
   - Ackbar: 8 items — dev tools before testing (hitbox debug, frame data, overlay, regression checklist)

4. **One new P0 discovered:** Audio context initialization (EX-G1) — Web Audio silently fails without user gesture. Potential showstopper engineers missed.

5. **Specialist pattern: infrastructure first.** All four specialists prioritized systems/tools over content. This is the right call — build the pipeline, then fill it.

### Impact

Backlog growth from 52→85 does NOT mean longer timeline. The 8-person team parallelizes across 4 independent workstreams. More items + more people = same or shorter delivery with higher quality.

### Full Details

See `.squad/analysis/backlog-expansion.md` for complete item list, re-assignment tables, and load analysis.
