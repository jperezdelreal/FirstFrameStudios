# Boba — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Visual approach:** All art is procedural Canvas 2D drawing — no external images
- **Current state:** Characters are basic geometric shapes (programmer art). Visual quality scored 30% in gap analysis. Animation is ad-hoc sine-wave arm bobbing. No particle system exists.
- **Key gap:** User explicitly requested "visually modern" and "clean, modern 2D look." This is the biggest quality gap.

## Learnings

### Wave 1 — EX-B1, EX-B2, P1-2 (2026-06-03)

**Delivered:**
- `.squad/analysis/art-direction.md` — Full visual style guide: primary/secondary palettes, outline approach (2px #222222, round caps), flat shading with one highlight layer, character proportions (Homer chunky, enemies lean), comic-book effect style.
- `src/systems/vfx.js` — Complete VFX system module:
  - `VFX.drawShadow()` (static) — oval ground shadow that scales/fades with jump height. Ready for player.js and enemy.js to adopt when those owners migrate.
  - `VFX.createHitEffect(x, y, intensity)` — starburst at impact point. Three intensities: light (20px, punch), medium (30px, kick), heavy (40px, combo finisher). 6 radiating rays, white center flash, scale-up + alpha-fade over 100ms.
  - `VFX.createKOEffect(x, y)` — larger starburst (50px) with 5 orbiting four-point star particles. 250ms lifetime.
  - `vfx` singleton with `addEffect()`, `update(dt)`, `render(ctx)`.
  - Integration instructions in file header comment for Chewie (gameplay.js owner).

**Key decisions:**
- Used `#222222` instead of pure black for outlines — softer, more cartoon-like.
- Pre-computed random ray angles at creation time so effects don't jitter across frames.
- Effect progress uses ease-out fade (`1 - t²`) for natural-feeling disappearance.
- Made `drawShadow` static so it can be called without a VFX instance — useful for entity render methods.
- Used `ctx.save()`/`ctx.restore()` in drawShadow to avoid leaking globalAlpha or fillStyle.
- Added minimum shadow scale (0.3) so shadow never fully disappears during high jumps.

**Blocked on (waiting for other agents):**
- Integration into gameplay.js update/render loop (Chewie's domain)
- Migration of player.js/enemy.js inline shadows to VFX.drawShadow() (Lando/Tarkin's domain)
- Combat hit callbacks to trigger createHitEffect/createKOEffect (Chewie + combat.js owner)
