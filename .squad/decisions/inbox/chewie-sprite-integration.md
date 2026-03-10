# PNG Sprite Integration into CharacterSprite

**Author:** Chewie (Engine Developer)  
**Date:** 2026-07-24  
**Status:** Implemented  
**Scope:** Ashfall fighter rendering pipeline

## Decision

Modified `CharacterSprite` base class to auto-detect and render pre-rendered PNG sprites instead of procedural `_draw()` geometry. The system probes `res://assets/sprites/{character_id}/` at startup and creates an `AnimatedSprite2D` child if sprites are found.

## Key Design Choices

1. **Detection via virtual method** — `_get_character_id()` returns the character folder name. Base returns `""` (no sprites). Subclasses override with `"kael"` / `"rhena"`. Cleaner than class name parsing.

2. **Pose setter branches** — When `pose` changes, the setter calls `_update_sprite_animation()` (PNG mode) or `queue_redraw()` (procedural mode). No new signals, no polling.

3. **Graceful fallback** — If sprites aren't found, procedural rendering continues unchanged. Both Kael and Rhena can run with or without PNGs.

4. **Zero changes to downstream systems** — `SpriteStateBridge`, `FighterAnimationController`, fighter `.tscn` files, hitboxes, and HUD are all untouched. The integration is entirely inside `CharacterSprite`.

5. **Scale constant** — `_PNG_SPRITE_SCALE = 0.15` (512px → ~77px). Tunable constant, not buried in logic.

## Impact on Team

- **Boba:** New sprite animations (block, hit, jump, etc.) just need to follow the naming convention `{char}_{anim}_{NNNN}.png` in the correct folder. Add the animation name to `_SPRITE_ANIM_CONFIGS` and pose mappings to `_POSE_TO_ANIM`.
- **Wedge:** No gameplay changes. State machine and hitbox systems unaffected.
- **Joaquín:** Run the game normally — if PNGs exist, they render automatically.

## Files Changed

- `games/ashfall/scripts/fighters/sprites/character_sprite.gd` — PNG sprite system added
- `games/ashfall/scripts/fighters/sprites/kael_sprite.gd` — `_get_character_id()` override
- `games/ashfall/scripts/fighters/sprites/rhena_sprite.gd` — `_get_character_id()` override
