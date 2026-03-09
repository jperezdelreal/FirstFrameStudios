# Procedural Sprite System for Ashfall Characters

**Author:** Nien (Character Artist)  
**Date:** 2026-03-09  
**Status:** Proposed  
**Scope:** Ashfall character art pipeline

## Decision

Character placeholders use Godot's `_draw()` API via a `CharacterSprite` base class (Node2D) instead of pre-rendered PNG sprite sheets. Each character has its own sprite script (kael_sprite.gd, rhena_sprite.gd) that overrides pose methods.

## Key Points

1. **Procedural-first pipeline:** Characters are drawn at runtime using Godot draw primitives. A `SpriteSheetGenerator` @tool script can bake these into PNGs for AnimationPlayer when needed.
2. **Palette system:** P1/P2 variants are `Array[Dictionary]` of named colors. `palette_index` export swaps palettes without code changes. Extensible to additional costumes.
3. **State bridge pattern:** `SpriteStateBridge` polls `StateMachine.current_state.name` each physics frame to sync poses. No modifications to gameplay scripts required — respects ownership boundaries.
4. **Character-specific scenes:** `kael.tscn` and `rhena.tscn` extend fighter_base.tscn structure, adding procedural sprite + bridge as new nodes. `fight_scene.tscn` updated to instance these instead of generic fighter_base.
5. **Silhouette differentiation:** Kael = ponytail + lean upright stance + controlled extensions. Rhena = wild spiky hair + wide low stance + overshooting messy swings. Distinct at any scale.

## Impact

- **Boba (Art Director):** Review silhouettes and palettes for style guide compliance
- **Chewie/Lando (Engine/Gameplay):** fight_scene.tscn now instances kael.tscn/rhena.tscn instead of fighter_base.tscn. Sprite2D node preserved for future texture loading.
- **Solo (Architect):** New `scripts/fighters/sprites/` module. SpriteStateBridge adds polling load (one string comparison per fighter per frame — negligible).
- **Future characters:** Extend `CharacterSprite`, override 8 pose methods, add to palettes array. ~400-500 LOC per character.

## Why

Procedural art eliminates the external tool dependency for placeholder iteration. The team can tweak proportions, palettes, and poses directly in GDScript without a pixel art editor. The bake-to-PNG path preserves compatibility with AnimationPlayer for production art later.
