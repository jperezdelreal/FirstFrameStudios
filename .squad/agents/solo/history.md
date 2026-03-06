# Solo — History (formerly Keaton)

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

### Bug Fixes (Session 1)
Fixed 5 critical bugs that were making the game unplayable:

1. **Infinite recursion in input.js**: Two methods named `isDown()` caused stack overflow. Renamed the directional helper from `isDown()` to `isMovingDown()` to resolve the conflict. Updated the single caller in player.js.

2. **Combat hit detection only ran one frame**: Attack hitboxes are active for multiple frames, but collision detection only ran on the first frame. Moved `Combat.handlePlayerAttack()` outside the `if (attackResult)` block and added `attackHitList` Set to Player to track which enemies have been hit per attack. This prevents multi-hitting the same enemy but allows reliable hit detection throughout the attack animation.

3. **No invulnerability frames**: Player took damage every frame during enemy attacks (~360 damage at 60fps from one attack). Added `invulnTime` property with 500ms i-frames after taking damage. Also added visual blink effect during invulnerability.

4. **Parallax scrolling backwards**: Buildings moved faster than foreground instead of slower. Changed from `bx = i * 400 - buildingOffset` to `bx = i * 400 + camX * 0.7` so buildings scroll at 0.3x camera speed after transform.

5. **Player could walk off left edge**: Added boundary check to constrain player.x to `cameraX + 10` minimum.

All fixes were surgical edits to preserve existing code structure.

### Gap Analysis (Session 2)
Performed comprehensive gap analysis of MVP vs original requirements. Key findings:

1. **Overall completion ~75%.** Core mechanics, rendering, controls, and HUD all meet requirements. Two critical gaps: localStorage high score (0% — missed entirely) and visual quality (30% — far from "modern").

2. **Combat feel scored 5/10.** Mechanics work but lack juice. Biggest missing element is hitlag (freeze frames on impact). No combo system, no jump attacks, no impact VFX, no sound variation.

3. **Architecture is solid but gameplay.js is a god scene** (260 LOC handling waves, camera, background, game state). Must decompose before adding features.

4. **Animation system is the critical path dependency.** Both visual quality improvements and combat feel polish require a proper frame-based animation controller. Currently animation is just sine-wave arm bobbing.

5. **Gameplay Dev role is the bottleneck** — ~60% of backlog items route there. Recommend adding VFX/Art specialist.

6. **Produced 52-item prioritized backlog** across P0 (5 items), P1 (20 items), P2 (17 items), P3 (14 items). Recommended execution in 6 phases.

7. **Key architectural recommendation:** Combat feel first, visuals second. A fun game with simple art beats a pretty game with mushy controls.

### Team Expansion Recommendation (Session 3)
Analyzed the 52-item backlog for load distribution and proposed expanding the squad from 4 devs to 8 specialists for cross-game capability. Key findings:

1. **McManus (Gameplay Dev) carries 50% of the backlog** (26 of 52 items). Even with VFX/Art absorbing ~8 items, McManus still owns 18 — the critical bottleneck on every project.

2. **Recommended 3 new roles** beyond the confirmed VFX/Art Specialist:
   - **Sound Designer ("Kobayashi")** — Owns 7 audio items (2× P0), frees Fenster for core engine work. Web Audio API procedural synthesis compounds massively across games. Highest parallelism.
   - **Enemy/Content Dev ("Redfoot")** — Owns 14 items (enemy types, AI, bosses, pickups, levels). Splits gameplay work into "player verbs" (McManus) vs "game nouns" (Redfoot). Natural parallel workflow.
   - **QA/Playtester ("Verbal")** — No owned items but validates every item. Engineers can't objectively assess their own game feel. Builds calibrated instincts for combat timing, balance, and difficulty that compound across projects.

3. **Rejected 5 roles:** Dedicated Animator (overlaps VFX), DevOps (no build step), Narrative Writer (minimal story in beat 'em ups), Network Engineer (only 2 stretch items), PM (Keaton covers this), Second UI Dev (Hockney's load is manageable).

4. **Key insight:** The expanded team creates 3 independent parallel columns — Engine/Gameplay/Content, Presentation/Audio, and Quality — that can all work simultaneously without blocking each other. Every role has consistent work across game projects.

5. **Onboarding sequence:** VFX/Art first (already confirmed), Sound Designer second (owns P0 items), Content Dev third (needed by P2 phase), QA fourth (valuable once combat mechanics exist to test).

### Backlog Expansion Analysis (Session 4)
Analyzed whether the backlog grows with 4 new specialists (Boba, Greedo, Tarkin, Ackbar). Key findings:

1. **Backlog grew 52 → 85 items (+63%).** Added 33 genuinely useful items, zero busywork. Growth concentrated in P1 (+14) and P2 (+14) — foundational systems and polish, not stretch goals.

2. **Re-assigned 28 existing items** to correct specialist owners. Biggest impact: Lando dropped from 26 items (50%, critical bottleneck) to 10 items focused purely on player mechanics. Chewie freed from 7 audio items.

3. **All specialists prioritized infrastructure over content.** Boba wants art direction before drawing. Greedo wants mix buses before composing. Tarkin wants data formats before level design. Ackbar wants debug tools before playtesting. Pattern: experienced specialists build pipelines first, then fill them.

4. **Discovered one new P0:** Audio context initialization (Web Audio requires user gesture). Potential showstopper that engineers overlooked. Sound Designer caught it immediately.

5. **Key insight: more items ≠ more time.** The expanded team parallelizes across 4 independent workstreams (Engine+Gameplay, VFX+Art, Audio, Content+QA). 85 items across 8 people is lighter per-person than 52 items across 4 people with a 50% bottleneck on one role.

6. **Documents produced:** `.squad/analysis/backlog-expansion.md` (full item list, re-assignments, load analysis), `.squad/decisions/inbox/solo-backlog-expansion.md` (decision summary).
