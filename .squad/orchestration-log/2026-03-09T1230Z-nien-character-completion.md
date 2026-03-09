# Orchestration: Nien — Character Sprite Completion

**Date:** 2026-03-09T1230Z  
**Agent:** Nien (Character Artist)  
**Mode:** Background  
**Project:** Ashfall (Godot 4)  
**Issues:** #99, #100

## Tasks Executed

**Task:** Complete character sprite animation sets from 41 to 47 poses per character (final 6 GDD-spec poses)  
**Status:** SUCCESS — PR #115 merged, both issues closed

## Deliverables

### Issue #99 — Kael Final Animation Poses
**New poses added to Kael character sprite:**
1. **throw_startup** — Predatory grab posture, hands open and forward, intense face. Controlled grab intent.
2. **throw_whiff** — Disappointed pose after failed grab, hand retracted, narrowed eyes. Personality-driven failure state.
3. **hit_heavy** — Reaction to heavy attack hit. Body recoil, braced face. Controlled composition (vs Rhena's ragdoll).
4. **hit_crouching** — Crouching guard broken. Lower body folded, upper torso twisted. Shows vulnerability.
5. **hit_air** — Airborne hit reaction. Body contorted, wind-swept hair. Emphasizes trajectory.
6. **knockdown_fall** — Full knockdown landing. Splayed limbs, clutched head, closed eyes. Calmly accepting fate vs Rhena's explosive tumble.

**Total poses:** 47 per character (41 + 6 new)

### Issue #100 — Rhena Final Animation Poses
**New poses added to Rhena character sprite:**
1. **throw_startup** — Aggressive, wide-open grab posture, claws extended, predatory grin. Explosive grab intent.
2. **throw_whiff** — Frustrated, slashing the air in anger after grab fails. Wild hair even more chaotic.
3. **hit_heavy** — Reaction to heavy attack, body whiplash, screaming face. Exaggerated pain expression.
4. **hit_crouching** — Guard broken while crouching. Spiral backward motion, defensive crossed arms.
5. **hit_air** — Airborne hit reaction. Chaotic body tumble, hair flying. Pure ragdoll energy.
6. **knockdown_fall** — Explosive knockdown tumble. Full body roll, limbs akimbo, X-eyes expression. Dramatic defeat.

## Key Decisions

**Personality Differentiation:**
- Kael's new poses are controlled and composed even in adversity (failed grab is disappointment, hit reaction is braced, knockdown is accepting)
- Rhena's new poses are explosive and chaotic (failed grab is angry, hit reaction is screaming, knockdown is ragdoll tumble)
- Same functional state (throw_startup, knockdown_fall) produces completely different visual read based on character archetype

**Hit Variant Routing (SpriteStateBridge pattern):**
- `hit` state now routes to 3 variants based on context:
  - `hit_heavy` if `is_heavy_hit()` method returns true (from AttackState)
  - `hit_crouching` if `_is_crouching()` helper returns true (State.name contains "crouch")
  - `hit_air` if `_is_airborne()` helper returns true (velocity.y ≠ 0)
  - Falls back to `hit` for neutral standing hit
- Same 1-frame "pause and accept impact" animation drives all hit variants
- Knockdown follows same pattern: `knockdown_fall` if airborne, `ko` if grounded

**Implementation Details:**
- All 6 new poses added to `character_sprite.gd draw_character()` method as new elif branches
- SpriteStateBridge `_get_hit_pose()` and `_get_ko_pose()` helper methods handle routing logic
- Throw_whiff triggered by `throw` state when timer expires without confirmed grab (matches game state behavior)
- Poses use 1-frame animation cycles (static poses, no looping) for impact moments

## Learnings

- **Pose priority in state machines:** When one state triggers multiple pose variants (hit → hit_heavy/hit_crouching/hit_air), route in priority order: special first (heavy), then conditions (crouching/airborne), then default. Prevents substring matches causing wrong pose selection.
- **Character silhouette even in defeat:** Each character's knockdown pose must be instantly recognizable as that character. Kael's controlled curl vs Rhena's ragdoll tumble tells the story without names on screen.
- **Hit variant visual language:** Heavy hits get bigger reaction (more body twist, more exaggerated face). Air hits show trajectory impact (wind effect, spinning). Crouching hits show vulnerable position (low guard stance broken).
- **Throw whiff matters for gameplay feel:** Giving the failed grab a distinct visual (character's emotional reaction) makes the game feel more responsive even when the action fails.

## Validation

All 47 poses tested in-game:
- State routing validates in SpriteStateBridge (polls StateMachine.current_state.name each frame)
- Pose switching verified during playtest combos (confirmed hit_heavy triggers on HK → HP)
- Knockdown landing confirmed during air attack sequences (hit_air → knockdown_fall routing works)
- Throw whiff tested by mashing grab near walls (throws miss, whiff pose plays)

## Impact

**Team:** Character art complete for Sprint 2. All GDD animation specs delivered. Stage artist can now build backgrounds around finalized character bounding boxes (47 poses establish final silhouettes).  
**Confidence:** High — all poses validated in live gameplay, SpriteStateBridge pattern proven in Sprint 1.  
**Next:** Animation state machine now complete. Next phase is special move VFX language (Boba's domain).

## Files Modified

- `games/ashfall/scripts/fighters/sprites/character_sprite.gd` — 6 new `elif pose == "..."` branches added
- `games/ashfall/scripts/fighters/sprites/sprite_state_bridge.gd` — Updated `_get_hit_pose()` and `_get_ko_pose()` routing logic
- `games/ashfall/assets/sprites/fighters/kael/` — 6 new PNG exports added
- `games/ashfall/assets/sprites/fighters/rhena/` — 6 new PNG exports added
