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

### Animation System (P1-8)
- `AnimationController` is data-only — tracks frame index and timer, returns frame data, never renders. Frames can be any type (number, object, function) — the renderer decides how to interpret them.
- `play()` is a no-op if the same animation is already playing and not finished. This lets callers spam `play('idle')` every frame without resetting the animation.
- `onFrameEvent(callback)` fires `callback(animName, frameIndex)` on every frame change — useful for SFX timing (e.g. footstep on frame 2 of walk).
- Frame timer uses a `while` loop to handle cases where `dt` spans multiple frames (e.g. after a lag spike). Non-looping animations clamp to last frame and set `finished = true`.

### Event System (P1-15)
- `EventBus.emit()` iterates over a shallow copy of the listener array so handlers can safely call `off()` mid-emit without corrupting the iteration.
- `once()` wraps the callback in a self-removing wrapper. The wrapper is what gets registered, so `off()` with the original callback won't match — this is intentional (once-listeners are fire-and-forget).
- Documented seven standard game events in header comments. These are conventions, not enforced — any string works as an event name.

### Screen Transitions (P1-19)
- Transition is a two-phase state machine: `fade-out` (alpha 0→1) then `fade-in` (alpha 1→0), each taking `transitionDuration` (0.3s). Scene switch happens at the midpoint when screen is fully black.
- First `switchScene()` call (no current scene) skips the transition — direct switch for initial load. Subsequent calls require fade. `switchScene()` is a no-op while already transitioning to prevent double-switch bugs.
- Transition check runs in the fixed-timestep loop *before* hitlag/scene update, so game logic is fully paused during fades. The overlay renders *after* the scene render to draw on top of everything.
- Game constructor now grabs `canvas.getContext('2d')` as `this.ctx` for the transition overlay. This is a minor addition — scenes already get their own ctx references.

### Particle System + Damage Numbers (P2-6)
- `ParticleSystem` is data-driven: `emit(x, y, config)` spawns N particles using a config object with `count`, `speed`, `spread`, `lifetime`, `size`, `color` (array for random pick), `gravity`, `fadeOut`, `shrink`. No rendering opinions — just rectangles. Callers can extend later.
- Particle angles scatter around -π/2 (upward) ± spread/2. Speed and lifetime get ±30% randomization to avoid uniform blobs.
- Three pre-built configs exported as constants: `DUST_CLOUD` (landing dust, 0.3s, upward float), `HIT_SPARKS` (narrow 45° cone, 0.2s, fast), `DEATH_DEBRIS` (360° spread, gravity-affected, 0.5s).
- Wiring damage numbers required extending `Combat.handlePlayerAttack` hit objects to include `damage` — minimal one-field addition. Gameplay.js calls `VFX.createDamageNumber()` in the same loop as hit effects, using `player.comboCount > 2` for the combo flag.
- `VFX.createKOText` doesn't exist in Boba's vfx.js — the conditional in the task spec meant skip it. KO *effects* were already wired from the P2 integration pass.

### Music Crash Fix + System Wiring (C4, H1, Particles)
- **Music null safety (C4):** Wrapped `new Music()` in try/catch and guarded with `this.audio.context && this.audio.musicBus` checks before construction. All `music.setIntensity/start/stop` calls null-checked. `onExit` stop also wrapped in try/catch — if the AudioContext is already closed, we just swallow the error.
- **Particle system wiring:** Imported `ParticleSystem` + 3 preset configs. Created instance in constructor (not onEnter — same lifecycle as VFX). `update(dt)` runs in both `update()` and `updateDuringHitlag()` so particles animate through freeze frames. `render(ctx)` placed right after `vfx.render()` in world-space. Emitters: `DUST_CLOUD` at player feet on landing, `HIT_SPARKS` at combat hit position, `DEATH_DEBRIS` at enemy center on KO despawn.
- **Wave fanfares (H1):** `playWaveStart()` fires when `waveManager.check()` returns new enemies (camera locks). `playWaveClear()` fires when camera unlocks (all enemies defeated). `playLevelComplete()` fires once when `levelComplete` flag first goes true.
- **Landing sound:** Reused existing `prevJumpHeight` tracking — when it transitions from >0 to 0, call `audio.playLanding()` alongside the dust cloud emit. Single detection point, no duplicate triggers.
