# Bossk — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current VFX:** Hit starbursts, KO effects, damage numbers, motion trails, spawn effects in src/systems/vfx.js. Particle system with dust/sparks/debris in src/engine/particles.js.

## Learnings

- All VFX methods follow a consistent pattern: static factory creates an effect object with `type`, `lifetime`, `maxLifetime`, and `render(ctx, progress)`, then calls `vfxInstance.addEffect()`. New effects must match this contract.
- The `createMotionTrail` signature is backward-compatible — the new `attackType` param is optional and trailing. Existing callers without it still work with default color.
- Boss intro (`type: 'boss_intro'`) needs gameplay.js to check `vfx.effects.some(e => e.type === 'boss_intro')` and pause updates — this is documented in header integration instructions #11 but NOT implemented in gameplay.js (by design: we don't own that file).
- Screen-sized effects (flash, speed lines, boss intro) use `ctx.canvas.width/height` for dimensions — no hardcoded canvas size.
- Telegraph ring expanding outward uses the same progress-based alpha pattern as spawn effects. Keeping visual language consistent across warning indicators.
- Sparkle particles on motion trails use cubic bezier interpolation (`mt³·P0 + 3·mt²·t·P1 + ...`) to position along the outer arc edge — avoids needing a second render pass.
