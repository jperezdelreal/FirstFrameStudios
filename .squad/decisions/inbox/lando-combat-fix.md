# Decision: Combat Hitbox Scaling for PNG Sprites

**Author:** Lando (Gameplay Developer)
**Date:** 2026-07-22
**Status:** Implemented & Verified

## Context

The sprite pipeline recently upgraded from ~60px procedural canvas drawings to ~282px pre-rendered PNG sprites (512px at 0.55 scale). The collision system (hitboxes, hurtboxes, body collision) was never updated to match, breaking all combat — attacks animated but dealt no damage.

## Decision

Scale all fighter collision shapes by 3.67× (282px / ~77px procedural) and fix hitbox directional flipping.

### Specific Values

| Shape | Old Size | New Size | Old Position | New Position |
|-------|----------|----------|--------------|--------------|
| Body collision | 30×60 | 110×220 | (0, -30) | (0, -110) |
| Hurtbox | 26×56 | 96×206 | (0, -28) | (0, -103) |
| Hitbox | 36×24 | 132×88 | (30, -30) | (110, -110) |
| AttackOrigin | — | — | (30, -30) | (110, -110) |
| Sprite (legacy) | — | — | (0, -30) | (0, -141) |

### Hitbox Flipping

Added `shape.position.x = absf(shape.position.x) * fighter.facing_direction` in `attack_state._activate_hitboxes()` so hitboxes extend toward the opponent regardless of which side the attacker faces.

## Files Changed

- `games/ashfall/scenes/fighters/kael.tscn` — collision shape sizes + positions
- `games/ashfall/scenes/fighters/rhena.tscn` — collision shape sizes + positions
- `games/ashfall/scenes/fighters/fighter_base.tscn` — template consistency
- `games/ashfall/scripts/fighters/states/attack_state.gd` — hitbox direction flip
- `games/ashfall/scripts/systems/hitbox.gd` — debug print on hit

## Verification

- `visual_test.bat`: All 7 screenshots pass. Console confirms `[Hitbox] HIT! Fighter1 → Fighter2 | dmg=50`.
- `play.bat --quit-after 5`: Clean exit, no errors.
- Walk animation confirmed rendering with PNG sprites.

## Future Consideration

Any time sprite scale changes, collision shapes must be re-calibrated. Consider extracting collision dimensions into a shared constant or resource so they track sprite scale automatically.
