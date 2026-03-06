# Chewie — History (formerly Fenster)

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

### Hitlag System (P1-1)
- Added `hitlagFrames` counter and `addHitlag(frames)` method to `Game` class. Uses `Math.max` to prevent stacking from multi-hits.
- Game loop checks hitlag before scene update: if active, decrements counter and calls `scene.updateDuringHitlag(dt)` instead of `scene.update(dt)`. Rendering always runs.
- `updateDuringHitlag(dt)` hook lets scenes decide what visual effects continue during freeze (e.g. screen shake). Clean separation — engine provides the hook, scene implements it.
- Player attack hitlag: 3 frames. Enemy attack hitlag: 2 frames. Triggered in `gameplay.js` by checking `scoreGained > 0` (player) and health delta (enemy).
- Enemy hit detection uses health-before/after comparison since `Combat.handleEnemyAttacks` doesn't return hit count and i-frames may absorb damage silently.

### Integration Pass — Phase 2 Systems (P2)
- **VFX wiring:** Imported `VFX` class (not singleton — per-scene instance avoids stale effects across transitions). `vfx.update(dt)` runs both in `update()` and `updateDuringHitlag()` so effects animate smoothly through freeze frames. `vfx.render(ctx)` placed after entity rendering but before `renderer.restore()` so effects are in world-space under the camera transform, then HUD draws on top.
- **Hit effect positioning:** Modified `Combat.handlePlayerAttack` to return `{ score, hits: [{x, y, intensity}] }` instead of a plain number. Hit position is the midpoint between player and enemy centers. Intensity maps: combo finisher → 'heavy', kick/jump_kick → 'medium', punch/jump_punch → 'light'. Minimal change to combat.js — just added hit tracking array and restructured the return.
- **KO effects:** Created at cleanup time (when `enemy.deathTime > 0.5`) at the enemy's center position, right before `cleanupDeadEnemies` removes them. This gives a visual "poof" on despawn rather than at the kill moment (which already has a hit flash).
- **Debug overlay:** Imported Ackbar's `DebugOverlay`, created in constructor, `destroy()` called in `onExit()` to clean up the keydown listener. Renders absolutely last (after HUD, game over/level complete text). Toggled with backtick key.
- **Jump kick audio:** Extended the attack result type check from `'kick'` to `'kick' || 'jump_kick'` so Lando's aerial attacks play the correct sound. All other types (punch, jump_punch) fall through to `playPunch()`.
- **API adaptation:** Boba's VFX static factories return effect objects (not void) — you call `vfx.addEffect(VFX.createHitEffect(...))`. The task description had a slightly different API signature; always read the actual file header.
