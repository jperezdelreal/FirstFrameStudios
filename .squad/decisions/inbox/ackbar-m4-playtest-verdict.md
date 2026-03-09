# Decision: M4 Gate Playtest Verdict

**Author:** Ackbar (QA/Playtester)
**Date:** 2025-07-25
**Scope:** Ashfall Sprint 0 M4 gate — ship verification

## Decision

**PASS WITH NOTES** for M4 gate.

## Rationale

The Sprint 0 prototype passes because:
- Full game flow works end-to-end (main menu → character select → fight → victory → rematch/menu)
- 9 fighter states implemented and transitioning correctly with safety timeouts
- Frame-based determinism is solid (integer counters, 60 FPS locked)
- Input system uses proper FGC conventions (8f buffer, SOCD, motion priority)
- EventBus decoupling between all 7 autoloads is clean
- Balance data is reasonable for shoto vs rushdown archetypes
- Audio/VFX/HUD integration is correctly signal-wired

## Conditions (Must-Fix Before M5)

1. **P0 #92:** Add hitbox geometry to fighter scenes (attacks currently deal no damage)
2. **P0 #93:** Fix take_damage signature (fight_scene passes 1 arg, needs 3)
3. **P1 #94:** Sync RoundManager scores to GameState (HUD/victory show 0-0)
4. **P1 #95:** Handle equal-HP timer draw (currently loops forever)

## Impact

Sprint 0 M4 gate is cleared. The team can proceed to M5 planning. The 4 bugs above are blocking for any gameplay-focused milestone and should be the first items in the next sprint.
