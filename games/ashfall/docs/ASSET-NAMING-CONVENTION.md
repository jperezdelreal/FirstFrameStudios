# Asset Naming Convention

All game assets follow a standardized naming pattern to ensure consistency across sprite creation and code integration.

## Format

```
games/ashfall/assets/sprites/{character}/{character}_{action}_{variant}.png
```

## Rules

- **Character name**: lowercase, no spaces (e.g., `kael`, `rhena`)
- **Action**: lowercase, matches state name (e.g., `idle`, `walk`, `jump`, `punch`, `kick`, `throw`, `hit`, `ko`, `block`)
- **Variant**: attack strength suffix (`lp`, `mp`, `hp`, `lk`, `mk`, `hk`) — omit for non-attack states
- **Spritesheets**: `{character}_{action}_sheet.png` (if using sheets instead of individual frames)
- **Stage assets**: `assets/stages/{stage_name}/{element}.png`

## Examples

**Character Sprites:**
```
assets/sprites/kael/kael_idle.png
assets/sprites/kael/kael_punch_lp.png
assets/sprites/kael/kael_punch_mp.png
assets/sprites/kael/kael_punch_hp.png
assets/sprites/kael/kael_kick_lk.png
assets/sprites/kael/kael_kick_mk.png
assets/sprites/kael/kael_kick_hk.png
assets/sprites/kael/kael_walk.png
assets/sprites/kael/kael_jump.png
assets/sprites/kael/kael_hit.png
assets/sprites/kael/kael_ko.png
assets/sprites/kael/kael_block.png

assets/sprites/rhena/rhena_idle.png
assets/sprites/rhena/rhena_punch_lp.png
...
```

**Spritesheets:**
```
assets/sprites/kael/kael_punch_sheet.png
assets/sprites/rhena/rhena_kick_sheet.png
```

## Why This Matters

This convention prevents naming mismatches between sprite creators and code consumers. Without shared naming standards, assets become difficult to locate and reference in code.
