# Chewie — History (formerly Fenster)

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
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

### AAA Systems Integration (Destructibles, Hazards, Audio, VFX)
- **Destructibles (AAA-L1):** Imported `Destructible` + `LEVEL_1` from data/levels.js. Created instances in `onEnter()` from `LEVEL_1.destructibles`. Updated each frame via `forEach(d => d.update(dt))`. Attack collision uses `Combat.checkCollision` against `d.getHurtbox()`, with damage matching the player's current attack type from the same table combat.js uses. Drops apply instantly: health +10 (capped at maxHealth), score +100. Rendered before entities for proper depth layering. Player `attackHitList` reused to prevent double-hits per swing.
- **Hazards (AAA-L3):** Created from `LEVEL_1.hazards` in `onEnter()`. Updated each frame. Damage zones checked for player AND all living enemies every frame. Used `entity.takeDamage()` method (not direct property assignment) to properly handle invuln, dodge frames, flash, and lives system. Rendered before entities like destructibles.
- **Voice barks (AAA-A3):** `playGrunt()` called at 30% chance when player takes enemy damage (inside existing health-delta check). `playCheer()` called when combo count crosses 5+ threshold (tracked via `comboCountBefore` snapshot). Both wrapped in try/catch for audio context safety.
- **Enemy telegraphs (AAA-V3):** Tracks `prevState` per enemy before update/AI tick. Detects transitions INTO windup states (`windup`, `charge_windup`, `slam_windup`). Calls `VFX.createTelegraph()` at enemy center-X/top-Y. Guarded with `typeof` check.
- **Environmental ambience (AAA-A2):** `audio.startAmbience(1)` called at end of `onEnter()` after music init. `audio.stopAmbience()` called in `onExit()` before music stop. Both wrapped in try/catch. Skipped on options-resume path.
- **Boss intro (AAA-V4):** `VFX.createBossIntro()` called when wave spawning produces a boss variant enemy. Uses 'BRUISER' name and 'Heh!' title. Guarded with `typeof` check.
- **Screen flash (AAA-V5):** `VFX.createScreenFlash()` triggered when any combat hit has `intensity === 'heavy'`. White flash, 0.15s duration. Guarded with `typeof` check.
- **Combo-scaled hits (AAA-A4):** Updated all `audio.playHit()` calls in `combat.js`'s `handlePlayerAttack` to pass `player.comboCount`. Enemy-on-player hits in `handleEnemyAttacks` left at default (0) since combo scaling is for player attacks only. `playHit(comboCount)` method already existed in audio.js with the proper escalation logic.

### Critical Bug Fixes — Player Freeze + Enemy Passivity
- **Player freeze after hit (Bug 1):** The `else` branch in `player.update()` (hitstunTime > 0) correctly sets `state = 'hit'`. But when hitstunTime expires and the `if (hitstunTime <= 0)` branch runs, no handler matched state `'hit'` — all the `if/else if` chains only handle `dodging`, `dodge_recovery`, `throwing`, `grabbing`, `back_attack`, `idle`, `walk`, `jump`. The player was permanently stuck in `'hit'` state, unable to move or attack. Fix: added `if (this.state === 'hit') this.state = 'idle';` at the top of the hitstunTime <= 0 block.
- **Enemy passivity (Bug 2):** Default enemies (`_behaveDefault`) had a gap between the `_farAway(distance)` threshold (150px) and `attackRange` (80px for normal, 90px for tough). Enemies approached until within 150px, then fell through to the `_circlePlayer` fallback, which maintains a 125px target distance — outside the 80px attack range. Enemies orbited forever at 125px without ever reaching attack range. Fix: replaced the `_farAway` check + circling fallback with unconditional `_approachPlayer`, matching the approach-always pattern already used by `_behaveFast` and `_behaveHeavy`. Enemies now close the gap and enter attack range.
- **Lesson:** Always verify that EVERY state in a state machine has a valid exit transition. The 'hit' state had no recovery path because it was set in the `else` branch but consumed in the `if` branch where no handler recognized it. Also: behavior tree distance thresholds must be coherent with entity config values (attackRange vs approach/circle distances).

### Rendering Technology Research (Rendering-R1)
- **Root cause of "cutre" look:** No `devicePixelRatio` handling. Canvas renders at CSS pixels (1280×720) regardless of display density. On a 2× Retina display, every shape/text is 4× blurry. This is the single biggest visual quality issue and is fixable in <2 hours with zero risk.
- **Sprite caching is transformative:** Current architecture redraws ~100 canvas API calls per entity per frame. Pre-rendering to offscreen canvases and using `drawImage()` reduces this to 1 call per entity — a 10× performance improvement that also enables richer procedural art since the drawing cost is amortized across frames.
- **PixiJS v8 works without a build step** via UMD CDN (`<script src="cdn/pixi.js">`). ESM imports from CDN have friction (import maps needed for sub-dependencies). UMD global approach is clean and reliable.
- **Phaser is wrong for our situation.** We already have working custom systems (combat, waves, input, audio, animation, events, hitlag, screen transitions). Phaser would replace tested code at 2× the migration cost for features we don't need (tilemaps, built-in physics). It's a framework for starting from scratch, not for upgrading an existing engine.
- **Hybrid approach (Canvas 2D drawing → PixiJS rendering) is the optimal upgrade path** if GPU effects are needed. Keep all procedural drawing code (entity art), convert offscreen canvases to PixiJS textures for GPU compositing/filters. Preserves our art pipeline while adding GPU acceleration.
- **Two-phase strategy minimizes risk:** Phase 1 (HiDPI + sprite caching + resolution scaling) is zero-dependency and gives 80% of the visual quality improvement. Phase 2 (PixiJS hybrid) is only needed if GPU effects (bloom, glow, blur) are required after Phase 1.

### HiDPI Rendering + Sprite Cache (Phase 1 Implementation)
- **DPR scaling in Renderer constructor:** `canvas.width = 1280 * dpr`, `canvas.height = 720 * dpr`, then `ctx.scale(dpr, dpr)`. All existing game code continues using 1280×720 logical coordinates — zero changes needed in player/enemy/background/HUD rendering. The `this.width`/`this.height` properties remain 1280/720.
- **Logical dimension propagation:** Set `canvas.logicalWidth` and `canvas.logicalHeight` as custom properties on the canvas element. Code that only has a `ctx` reference (VFX effects, debug overlay) reads `ctx.canvas.logicalWidth || ctx.canvas.width` to get logical dimensions. The fallback to `canvas.width` keeps backward compatibility if `logicalWidth` isn't set.
- **Downstream fixes required:** Five places used `ctx.canvas.width/height` for screen-space positioning: game.js transition overlay, VFX boss intro, VFX screen flash fillRect, VFX speed lines, and debug overlay metrics panel. All switched to logical dimensions. The zoom center in `save()` also switched from `this.canvas.width/2` to `this.width/2`.
- **CSS `image-rendering: pixelated` was already fixed** to `auto` by a prior change — no action needed. With DPR scaling + bilinear interpolation, procedural canvas art renders at native display resolution.

### Input Handling Skill Creation (P1 — Universal Skill) (2026-03-07)
- **Context:** Ackbar's skills audit identified `input-handling` as a critical missing universal skill. Input patterns are scattered across `web-game-engine` and `godot-4-manual`, but no unified skill exists. Every game (Canvas, Godot, Unity, any engine/genre) needs solid input architecture.
- **Scope:** Created `.squad/skills/input-handling/SKILL.md` — engine-agnostic, genre-agnostic reference for building responsive input systems.
- **Content structure:** 
  1. **Principle:** "Input Is the Player's Voice" — latency budget ≤100ms, why responsiveness matters (fighting games, platformers, action)
  2. **Input Buffering:** Ring buffer pattern, 6-10 frame windows, when to clear, buffering limitations
  3. **Coyote Time / Grace Periods:** Why 200ms human reaction matters, implementation pattern, tuning table (jump: 100-150ms, defend: 50-100ms, grab: 30-50ms, action: 100-200ms)
  4. **Input Mapping Architecture:** Abstracting actions from keys (`'attack'` not `'KeyJ'`), action types (press/hold/release/double-tap/charge), InputMapper for remapping, standard action set
  5. **Directional Input:** Last-pressed-wins pattern for opposing directions (left+right = right if right pressed last), 4-way vs 8-way implementation
  6. **Input Priority & Conflict Resolution:** Priority queue for simultaneous actions, InputConsumer pattern for "eating" inputs, movement as non-exclusive
  7. **Platform-Specific Patterns:** Keyboard (key repeat filtering, focus loss, modifier keys), Gamepad (dead zones 0.15-0.25, button mapping, vibration), Touch (virtual buttons, gesture recognition, screen-relative positioning)
  8. **Debug & Testing:** Input visualization overlay (backtick toggle showing held/pressed/buffered), input recording/playback for test sequences, latency measurement (target <100ms total)
  9. **Implementation Examples:** firstPunch patterns for keyboard + gamepad input manager, buffering ring, conflict resolution in gameplay loop, touchscreen fallback architecture
  10. **Anti-Patterns:** Polling instead of event-driven, no buffering (missed inputs), hardcoded key codes, assuming 60fps for timing, no dead zones, ignoring focus loss, no accessibility options
  11. **Genre Applications:** Action games (tight buffering, short grace periods), fighting games (frame-perfect input, 10-frame windows), platformers (jump coyote, dash buffer), RPGs (menu navigation, dialogue interaction), puzzle games (minimal latency requirement but gesture support needed)
- **Confidence: `medium`** — Validated in firstPunch (keyboard, gamepad, buffering, conflict resolution all tested and working). Patterns are universal across engines; ready for cross-project use.
- **Cross-refs:** game-feel-juice (input feedback), ui-ux-patterns (menu navigation), state-machine-patterns (input consumption in state machines)
- **Session tag:** Skills Gap Remediation (2026-03-07T12:57:00Z) — P1 gap from Ackbar audit. Orchestration log: `.squad/orchestration-log/2026-03-07T12-57-skills-creation.md`
  9. **Anti-Patterns:** Raw polling only (no buffering = player frustration), fixed key mapping (no accessibility), input in render loop (frame-dependent), eating inputs silently, tight/unforgiving windows
  10. **firstPunch Learnings:** What we built (keyboard buffering, last-pressed-wins direction), what worked (separating capture from consumption, ring buffer simplicity, buffer clear on state entry), what we'd improve for Godot (gamepad/touch support, InputMapper, visualization overlay, latency measurement, action types beyond press/hold)
  11. **Checklist:** 14 items covering capture, buffering, processing, abstraction, remapping, priorities, consumption, movement, direction, grace periods, multiplatform, testing, recording, latency, accessibility
- **Confidence level:** `medium` — Validated in firstPunch (Canvas keyboard + Web Audio), patterns are universal across all engines and genres. Not marked `high` because gamepad/touch support is theoretical (Canvas only used keyboard), but the architectural patterns are battle-tested and portable.
- **Format:** Followed existing SKILL.md format (name/description/domain/confidence/source header, When to Use/When NOT sections, core patterns with code examples, real-world examples, checklists, references). Used firstPunch-specific learning sections tied to actual bugs we fixed (recursion in isDown, buffering preventing stale inputs, last-pressed-wins resolving left+right conflicts).

## Ashfall — Fighter Engine Infrastructure

### Fighter State Machine, Hitbox/Hurtbox, Round Manager (Issues #2, #4)
- **Branch:** `squad/2-fighter-state-machine` (from `squad/1-godot-scaffold`)
- **FighterState base class** (`scripts/fighters/fighter_state.gd`): Extends the generic `State` class with a typed `fighter: CharacterBody2D` reference. All concrete states extend this. Reference is wired by `fighter_base.gd._ready()` before the first physics tick.
- **8 fighter states** in `scripts/fighters/states/`: idle, walk, crouch, jump, attack, block, hit (hitstun), ko (knockdown). Each uses integer frame counters, not float timers. Every state has at least one exit path and a safety timeout (attack: 120f, block: 120f, hitstun: 60f max, KO: 180f). States read input via thin `Fighter.is_input_pressed()` wrappers keyed by `player_id` — Lando will replace these with `InputBuffer` later.
- **Fighter base** (`scripts/fighters/fighter_base.gd`): `Fighter` class extending `CharacterBody2D`. Properties: health, max_health, ember_meter, facing_direction (±1), is_grounded. Methods: `take_damage(amount, knockback, hitstun_frames)` transitions to hit/ko state and emits signals, `reset_for_round()` resets HP/position/state. Auto-faces opponent (guarded during attack/hit/ko). Input helpers abstracted by player_id prefix.
- **Fighter base scene** (`scenes/fighters/fighter_base.tscn`): CharacterBody2D root → CollisionShape2D (RectangleShape2D 30×60), Sprite2D placeholder, Hurtbox (Area2D Layer 3 / Mask Layer 2) with HurtboxShape, AttackOrigin (Marker2D at x=30), Hitboxes (Node2D container), StateMachine with all 8 state children.
- **Hitbox system** (`scripts/systems/hitbox.gd`): `Hitbox` class extending `Area2D`. Properties: damage, knockback_force, hitstun_duration, hit_type (LIGHT/MEDIUM/HEAVY). On Layer 2, masks Layer 3. `activate()`/`deactivate()` control monitoring and enable/disable child CollisionShape2Ds. One-hit-per-attack: `_hit_targets` array prevents same target being struck twice per activation window. On overlap → emits `EventBus.hit_landed(owner_fighter, target, hit_data)`. Auto-discovers owner fighter by walking up the scene tree.
- **Round manager** (`scripts/systems/round_manager.gd`): `RoundManager` class. State flow: INACTIVE → INTRO (60f) → READY (90f) → FIGHT → KO (120f) → ROUND_RESET (90f) → back to INTRO, or MATCH_END. Best of 3 rounds, 99-second timer (frame-counted). Wires to fighter `knocked_out` signals via `start_match()`. Dual signal emission: local signals for direct wiring + EventBus for decoupled listeners. Timer display updates only when the displayed second changes (avoids 60 signal emissions per second).
- **Collision layer scheme:** Layer 1 = Fighters (physics bodies), Layer 2 = Hitboxes, Layer 3 = Hurtboxes, Layer 4 = Stage. Matches project.godot layer names set by Jango's scaffold. The architecture doc specifies a 6-layer per-player scheme but the simplified 4-layer setup works for the current scope.
- **Initialization ordering:** StateMachine._ready() runs before Fighter._ready() (Godot bottom-up). Fighter sets state references in its own _ready(), with a fallback `transition_to("idle")` if initial_state wasn't resolved from the scene file. IdleState.enter() guards fighter access with `if fighter:` for the first (reference-less) call.
- **Key design choice:** Attack state uses frame-phase logic (startup → active → recovery) internally as placeholder. When Tarkin delivers MoveData resources and AnimationPlayer frame-data tracks, the hitbox activation will shift to animation-driven. The current frame counters are the scaffolding; the architecture is the destination.
- **Cross-references:** Skill references Ackbar's QA testing patterns, Yoda's Player Hands First principle, and the team's latency discipline from the 100ms budget in web game engine skill. Complements existing skills without duplicating: `web-game-engine` covers the game loop and Canvas renderer, this skill is focused purely on input abstraction and multiplatform support.
- **SpriteCache class:** DPR-aware offscreen canvas factory. `getOrCreate(key, width, height, drawFn)` creates an offscreen canvas at `width*dpr × height*dpr`, scales its context by DPR, runs `drawFn(ctx)` once, and caches the result. Subsequent calls return the cached canvas for `drawImage()` blitting — 1 call instead of 100+. `invalidate(key)` for state changes (animation frame), `clear()` for full reset. Exported as a singleton `spriteCache`.
- **Integration pattern for entity rendering:** `const key = \`brawler_${state}_${facing}_${frame}\`; const sprite = spriteCache.getOrCreate(key, w, h, ctx => { ...all draw calls... }); mainCtx.drawImage(sprite, x, y, w, h);` — entity render methods can adopt this incrementally without changing draw call internals.
- **canvas.style.width/height set explicitly** to `1280px`/`720px` to prevent CSS `width: auto` from sizing the canvas based on the enlarged backing buffer. The `max-width: 100vw; max-height: 100vh` CSS constraints still apply for viewport fitting.

### Technical Learnings Document (Retrospective)
- Wrote comprehensive technical learnings to `.squad/analysis/technical-learnings.md` — inventoried all 9 engine systems (1,931 total LOC), documented what worked (fixed timestep, data-only animation, procedural audio, event bus), what broke (hitlag dual-update, state machine exit gaps, AI distance thresholds, AudioContext autoplay), Phaser comparison, Canvas 2D ceiling, HiDPI journey, performance patterns, audio synthesis techniques, and architecture evolution from monolith to modular.
- Created reusable skill `.squad/skills/web-game-engine/SKILL.md` — codified the engine architecture, system-by-system implementation guide, critical patterns (state machine exits, dual-update matrix, DPR propagation, AudioContext lifecycle), performance budgets, and common mistakes. Designed as a day-1 reference for starting a new Canvas 2D + Web Audio game engine.
- **Key retrospective insight:** The three decisions that saved the most time were (1) fixed-timestep loop from the start, (2) mix bus hierarchy before any sound, (3) engine/game directory split. The three that cost the most time were (1) monolith gameplay.js before extraction, (2) missing state machine exit transitions, (3) HiDPI retrofitting instead of day-1 setup.

### Next Project Tech Evaluation — "Nos Jugamos Todo" (2025-07-15)
- Evaluated 5 engines (Phaser 3, Godot 4, Unity, Defold, UE5) across 9 dimensions for the next project where "nos jugamos todo."
- **Recommendation: Godot 4** over Phaser 3. Phaser scores 66/90, Godot scores 74/90. The 8-point gap comes from platform reach (web-only vs everywhere), visual ceiling (8.5 vs 9.5/10), performance ceiling (browser-limited vs native), and audio (file-based vs AudioStreamGenerator supporting procedural synthesis).
- Every award-winning beat 'em up (Shredder's Revenge, Castle Crashers, Streets of Rage 4, River City Girls) ships native. Zero browser-only games in the competitive set. Staying web-only is conformist for a project with award ambitions.
- Godot's `AudioStreamGenerator` preserves our procedural audio investment — raw PCM buffer that Greedo can fill with oscillator synthesis. Phaser would force abandoning 931 LOC of our most innovative system.
- GDScript learning curve estimated at 2-3 weeks for JS devs (Python-like syntax). C# available as fallback. All architectural knowledge transfers: fixed timestep → `_physics_process`, event bus → signals, audio bus → AudioBus, hitlag → `Engine.time_scale`.
- Unity rejected for squad fit: C# learning curve (2-3 months), heavy editor, pricing uncertainty, scene merge conflicts with 12 agents. Defold rejected: small community, visual ceiling 8/10, Lua paradigm shift.
- Full analysis written to `.squad/analysis/next-project-tech-evaluation.md`. Decision summary submitted to `.squad/decisions/inbox/chewie-tech-ambition.md`.

### Timer Draw Fix — Bug #95
- **Bug:** `_time_over()` defaulted `winner_index = 0` when HP was equal, emitted `round_ended` with a fake winner, and never incremented scores. Match looped forever since nobody could reach `rounds_to_win`.
- **Root cause:** Missing draw branch. The `>=` in `f0_hp >= f1_hp` silently picked P1 as winner on ties, but the score guard `if f0_hp != f1_hp` prevented any score change.
- **Fix:** Per GDD ("both lose a round — forces aggression"), equal HP now increments both scores. New `round_draw` and `match_draw` signals added to RoundManager and EventBus so UI/audio can react to draws distinctly from wins.
- **Edge case:** If both players hit `rounds_to_win` simultaneously (e.g., two consecutive draws in best-of-3), `_check_match_over()` now detects the double-win condition and emits `match_draw` + "DRAW GAME!" announcement, ending the match cleanly.
- **Pattern:** Always handle the equal case explicitly in comparison logic. `>=` silently swallowing ties is a common fighting game bug.
### AnimationPlayer Integration (Sprint 1 — Issue #101)
- **FighterAnimationController** creates animations programmatically at runtime from MoveData resources. Uses AnimationLibrary API. Each moveset's normals+specials get their own animation with property tracks for sprite pose, hitbox CollisionShape.disabled, and Area2D.monitoring.
- **AnimationPlayer.playback_process_mode = PHYSICS** is critical for deterministic 60fps fighting game timing. Standard process mode would cause frame-inconsistent behavior.
- **Dual hitbox control pattern:** AnimationPlayer property tracks drive hitbox timing when FighterAnimationController is present; AttackState's manual frame counters remain as fallback. The `_anim_drives_hitbox` flag prevents double-activation. This means the system works correctly even without AnimationPlayer (backward compatible).
- **SpriteStateBridge dual-mode:** When AnimationPlayer controller exists, the bridge only overrides poses for states with per-frame dynamic conditions (jump velocity → pose, block stance detection, throw phase). For static states (idle, walk, hit, ko), AnimationPlayer drives poses via state_changed signal. This prevents the bridge from fighting the AnimationPlayer.
- **CharacterSprite pose fallback chains:** Added 13 new poses to the base class with virtual method fallbacks (e.g., `_draw_attack_lk()` → `_draw_attack_lp()`, `_draw_crouch()` → `_draw_idle()`). Subclasses override only when Nien provides dedicated art. No runtime errors for unimplemented poses.
- **Character scenes (kael.tscn, rhena.tscn) were missing Hitbox nodes** — only fighter_base.tscn had them. Added Hitbox (Area2D + CollisionShape2D) to both. Without this, attack_state.gd's hitbox activation was iterating over empty children.
- **Walk cycle:** 5 frames per step (WALK_STEP_FRAMES), 10-frame loop alternating between "walk" and "walk_2" poses via AnimationPlayer value track with INTERPOLATION_NEAREST.
- **Attack animation naming:** `attack_` + move_name (from MoveData.move_name). Lazy-created on first use for dynamically loaded moves.
- **AttackState.get_current_move() and get_current_move_name():** Added these accessors so SpriteStateBridge and FighterAnimationController can query the active MoveData. The bridge's `has_method("get_current_move_name")` check was already in place but the method didn't exist — now it does.
- **PR #106 created, closes #101.**
### 2026-03-09 — Sprint 1 Audit Results: Type Safety & Standards

**Cross-Agent Update:** Sprint 1 analysis identified systematic type inference bugs. All Ashfall developers now required to follow GDSCRIPT-STANDARDS.md (16 rules) starting Sprint 2 Day 1. See decision in .squad/decisions/decisions.md. Key impact for Chewie: add explicit type annotations to all variables.


### Dynamic Camera Zoom System (Sprint 2 Phase 1)
- Enhanced `camera_controller.gd` with Guilty Gear-style dynamic framing for 2-fighter combat.
- **Dynamic zoom:** Maps horizontal fighter distance to zoom level via `clampf` + `lerp`. Close = tight (zoom_max 1.3), far = wide (zoom_min 0.75). Distance thresholds tunable via `@export`.
- **Vertical compensation:** Camera blends toward highest fighter (lowest Y) using `vertical_follow_weight` (0.35). Only activates when a fighter is above `camera_y` baseline — grounded fights stay stable.
- **Fighting game framing:** `_enforce_framing_margins()` calculates required visible width from fighter distance + `margin_horizontal` padding, divided by `framing_ratio` (0.65). If distance-based zoom would place fighters outside the middle 65% of screen, zoom widens automatically.
- **Vertical edge clamping:** Added `_clamp_to_stage_y()` with `stage_ceiling_y` / `stage_floor_y` boundaries, mirroring the existing X-axis clamp logic.
- **GDSCRIPT-STANDARDS compliance:** Replaced all `:=` with explicit type annotations (`var x: float =`). Used `absf()`, `clampf()`, `minf()` instead of generic `abs/clamp/min`. All functions have explicit `-> Type` return annotations. Zero Variant inference.
- Renamed `position_smoothing` → `follow_speed`, `zoom_smoothing` → `zoom_speed` for clarity. No external callers found.
- **PR #144 created.**

### Sprite PoC Test Viewer
- Created `scenes/test/sprite_poc_test.tscn` + `scripts/test/sprite_poc_test.gd` — minimal viewer for PoC sprite animations.
- Data-driven animation config: `ANIM_CONFIG` dictionary maps animation names to prefix/count/fps/loop. Adding new animations = one dict entry + files. No code changes.
- `AnimatedSprite2D` with programmatic `SpriteFrames`: loads numbered PNGs at runtime via `load()`. Avoids manual SpriteFrames resource creation in editor.
- Center-bottom origin via `offset = Vector2(0, -256)` on a 512×512 sprite with `centered = true`. Node position represents feet.
- Flip via `scale.x *= -1` preserves offset math and animation state. No need for `flip_h` which doesn't work with offset-based origins.
- LP animation (non-looping) auto-returns to idle via `animation_finished` signal. Config-driven — any animation with `loop: false` gets the same behavior.
- HUD on `CanvasLayer` so it's unaffected by camera/zoom in future. Shadow text for readability over any background.
- Texture filter set to `TEXTURE_FILTER_NEAREST` on the AnimatedSprite2D node (runtime override, no .import file changes needed).
