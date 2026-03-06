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

### Final Integration Pass (FIP)
- **Motion trails:** Wired `VFX.createMotionTrail` on `attackResult` (the frame the player enters attack state). Trail position derived from `player.getAttackHitbox()` center — the hitbox is valid immediately since cooldown was just set. Dimensions follow Boba's integration spec: 40×20 for punch variants, 55×25 for kicks, larger for specials. Angle flipped by `player.facing` so trails arc in the correct direction. Guarded with `typeof VFX.createMotionTrail === 'function'` for safety.
- **Spawn effects:** `VFX.createSpawnEffect` called at both wave-spawn and boss-add-spawn sites, positioned at enemy center-X / feet-Y per Boba's spec. Also guarded with typeof check.
- **Foreground parallax:** `background.renderForeground()` placed inside save/restore (camera transform active) after entity rendering but before VFX. The foreground does its own 1.3× parallax math using `cameraX * (FRONT_PARALLAX - 1.0)` as extra offset — this is designed to work with the canvas translate from `renderer.save()`. VFX draws on top of foreground scenery so hit effects aren't obscured by lampposts.
- **Boss health bar:** HUD already self-contained — `render()` receives `enemies` array, finds boss via `enemies.find(e => e.variant === 'boss' && e.state !== 'dead')`, and renders bar at screen bottom. No gameplay.js changes needed.
- **Vocal sounds:** `playExertion()` on belly_bump/ground_slam, `playGrunt()` at 30% chance on other attacks, `playOof()` when player health decreases from enemy attacks. Audio methods confirmed present in audio.js.
- **Render order sanity:** Final order is clear → save → background → entities(y-sorted) → foreground → VFX → particles → restore → HUD → intro → game_over → level_complete → pause → debug. VFX/particles update at top of `update()` (before early-returns) so effects animate during intro/pause/gameOver states — this is intentional.

### Attack Buffering + Screen Zoom + Slow-Mo (AAA-C9, AAA-V1, AAA-V2)
- **Attack Buffering (C9):** Buffer state (`bufferedAction`, `bufferTimer`) lives in `Input` class — auto-captured in the `keydown` handler for attack keys (J/Z → punch, K/X → kick). 0.15s expiry window handled by `updateBuffer(dt)`. `consumeBuffer()` returns and clears the buffered action. Player's attack block merges buffer with live input via `wantsPunch = isPunch() || buffered === 'punch'`. Buffer cleared on hit state entry (`input.clearBuffer()`) so stale inputs don't fire after hitstun. Timer updated each frame in gameplay.js alongside other per-frame systems.
- **Screen Zoom (V1):** Zoom state on `Game` class (`zoomLevel`, `zoomTarget`, `zoomSpeed=10`, `zoomTimer`). `triggerZoom(level, duration)` snaps `zoomLevel` to target then lerps back to 1.0 via `_updateZoom(dt)` — uses real dt (not scaled) so zoom animates smoothly during slow-mo. Game pushes `zoomLevel` to `renderer.zoomLevel` each frame before render. Renderer applies zoom in `save()` centered on canvas midpoint: translate-to-center → scale → translate-back → camera. Triggered on: belly_bump, ground_slam, heavy-intensity combo hits, wave clear kills, and boss kill.
- **Slow-Mo (V2):** Time scale on `Game` class (`timeScale`, `timeScaleTimer`). `triggerSlowMo(scale, duration)` sets scale, `_updateTimeScale(dt)` counts down with real dt and restores to 1.0. Game loop computes `scaledDt = fixedDelta * timeScale` and passes it to `scene.update()`. Hitlag, transitions, zoom, and time-scale updates all use real dt. Triggered on: last enemy killed in active wave (camera locked + enemies → 0) and level complete. Audio pitch-shifts via `Music.setTimeScale(scale)` which stores `_pitchScale` multiplier applied to bass and melody oscillator frequencies — restored to 1.0 on camera unlock.
