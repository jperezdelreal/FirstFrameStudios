# codebase-analysis-and-learnings.md — Full Archive

> Archived version. Compressed operational copy at `codebase-analysis-and-learnings.md`.

---

# firstPunch — Full Codebase Analysis & Learnings

**Author:** Solo (Lead)  
**Date:** 2026-06-05  
**Scope:** Every source file in `src/` (28 files, 370KB), cross-referenced against 101-item AAA backlog.

---

## 1. Codebase Architecture Summary

### File Map (28 files)

| Directory | Files | LOC (approx) | Responsibility |
|-----------|-------|---------------|----------------|
| `src/engine/` | 9 files | ~1500 | Game loop, renderer, input, audio, events, animation, particles, music, sprite-cache |
| `src/entities/` | 4 files | ~1800 | Player (1080), Enemy (750), Destructible (325), Hazard (300) |
| `src/systems/` | 6 files | ~1700 | AI (350), Combat (250), VFX (1200+), Background (600+), Camera (35), WaveManager (47) |
| `src/scenes/` | 3 files | ~1000 | Gameplay (695), Title (340), Options (285) |
| `src/ui/` | 2 files | ~600 | HUD (530+), Highscore (27) |
| `src/data/` | 1 file | ~160 | Level definitions + enemy type configs |
| `src/debug/` | 1 file | ~150 | Debug overlay (hitbox visualization, FPS) |
| `src/` | 2 files | ~90 | main.js (36), config.js (45) |

### Architecture Patterns

**What works well:**
- **ES6 module imports** — Clean dependency graph, no circular imports detected
- **Scene pattern** — `Game.switchScene()` with `onEnter/onExit` lifecycle is simple and effective
- **Fixed timestep** — `Game.loop()` with accumulator prevents physics drift
- **Entity-based design** — Player/Enemy are self-contained with `update(dt)` + `render(ctx)`
- **Static utility classes** — `Combat` and `AI` as static method collections (no instance state needed)
- **Camera extraction** — Clean Camera class with lock/unlock for wave encounters
- **WaveManager extraction** — Wave spawning decoupled from gameplay.js
- **VFX integration pattern** — Static factory methods (`VFX.createHitEffect()`) + instance effects list
- **Mix bus audio** — Master → SFX/Music/UI/Ambience routing is professional-grade
- **Level data separation** — `src/data/levels.js` with typed ENEMY_TYPES + LEVEL_1 structure
- **HiDPI rendering** — Renderer scales by `devicePixelRatio` from the start

**What causes problems:**
- **gameplay.js is still a god scene** (695 LOC) — orchestrates ALL systems directly with no event bus
- **No event bus wiring** — `events.js` exists (49 LOC, complete EventBus) but is imported by ZERO files
- **No animation controller wiring** — `animation.js` exists (85 LOC, complete AnimationController) but is imported by ZERO files
- **Config not wired** — `config.js` defines CONFIG but no files import it (migration guide in comments only)
- **Entity rendering is inline** — Player render is ~400 LOC of Canvas procedural drawing inside player.js
- **Duplicate data** — WAVE_DATA hardcoded in gameplay.js AND `LEVEL_1.waves` in levels.js (two sources of truth)
- **Tight coupling** — gameplay.js directly calls `this.audio.playPunch()`, `this.vfx.addEffect()`, `this.particles.emit()` — ~40 direct system calls
- **No sprite caching used** — `sprite-cache.js` exists (35 LOC, complete SpriteCache) but no entity uses it

---

## 2. Bucket Classification

### Bucket 1: "Quick Wins" — Implementable NOW (< 1 hour each)

These are surgical edits to existing files, no structural changes needed.

| # | Item | Files Touched | What To Do | Risk |
|---|------|--------------|------------|------|
| QW-1 | **Wave progress indicator** (AAA-U4) | `hud.js` | Add 4 dots/text at top-center of HUD. `waveInfo` already passed to `hud.render()` in gameplay.js line 532. Just draw it. | ★☆☆ Zero |
| QW-2 | **Wire CONFIG into entities** (P1-16 completion) | `player.js`, `enemy.js`, `combat.js`, `gameplay.js` | Replace hardcoded `200`, `120`, `400`, `100` etc with `CONFIG.player.speed`, etc. Import + find-replace. | ★☆☆ Low — values are identical |
| QW-3 | **Difficulty modes** (AAA-R1) | `gameplay.js`, `config.js` | `game.difficulty` already exists (set in options.js). Multiply CONFIG values by difficulty scalars in `onEnter()`. 3 lines of math. | ★☆☆ Low |
| QW-4 | **Back attack** (AAA-C8) | Already done | `back_attack` state fully implemented in player.js (lines 260-344), combat.js has stats. Hitbox exists. **Already shipped.** | ★☆☆ N/A |
| QW-5 | **Colorblind mode** (AAA-T3) | `hud.js`, `enemy.js` | Add enemy type icons (letter/shape) above health bars. Toggle in options. HUD already draws enemy bars. | ★☆☆ Low |
| QW-6 | **Hit sound combo scaling** (AAA-A4) | Already done | `audio.playHit(comboCount)` already implemented with 4 tiers (lines 159-183). **Already shipped.** | ★☆☆ N/A |
| QW-7 | **game pickup sounds** (AAA-A6) | `audio.js` | Add `playPickupDonut()`, `playPickupCola()` methods (3 oscillators each). Wire in gameplay.js destructible drop handler. | ★☆☆ Low |
| QW-8 | **Fix duplicate wave data** | `gameplay.js` | Delete WAVE_DATA const (lines 18-40), import from `LEVEL_1.waves` in levels.js. Adapt field names (`triggerX→x`, `type→variant`). | ★★☆ Medium — test wave triggers |
| QW-9 | **Screen flash on player damage** | `gameplay.js` | Add `VFX.createScreenFlash(this.vfx, '#FF0000', 0.2)` after player takes damage (line 348). One line. | ★☆☆ Zero |
| QW-10 | **Enemy spawn effect scale-up** | `enemy.js` | Add `spawnTimer/spawnScale` properties per VFX integration comments. 10 lines in constructor + update + render. | ★☆☆ Low |
| QW-11 | **Scene transitions** (AAA-V6) | Already done | `game.js` has full fade-in/fade-out transition system (lines 24-130). `switchScene()` triggers it. **Already shipped.** | ★☆☆ N/A |
| QW-12 | **Screen zoom on power hits** (AAA-V1) | Already done | `game.triggerZoom()` implemented (game.js lines 36-40), called in gameplay.js for belly_bump, ground_slam, and heavy hits. **Already shipped.** | ★☆☆ N/A |
| QW-13 | **Slow-motion final kill** (AAA-V2) | Already done | `game.triggerSlowMo()` implemented (game.js lines 42-45), triggered on last wave enemy kill (gameplay.js line 391) and level complete. **Already shipped.** | ★☆☆ N/A |
| QW-14 | **Attack buffering** (AAA-C9) | Already done | Input buffer system in `input.js` (lines 7-68), consumed in player.js (line 318). **Already shipped.** | ★☆☆ N/A |
| QW-15 | **Dodge roll with i-frames** (AAA-C2) | Already done | Full dodge state machine in player.js (lines 59-65, 151-162, 199-214), double-tap and dedicated key in input.js. i-frames check in `takeDamage()` line 487. **Already shipped.** | ★☆☆ N/A |
| QW-16 | **Grab/throw system** (AAA-C1) | Already done | Full grab/pummel/throw in player.js (lines 49-56, 221-258), combat.js handles thrown enemy collision (lines 16-104). **Already shipped.** | ★☆☆ N/A |
| QW-17 | **Destructible objects** (AAA-L1) | Already done | `destructible.js` (325 LOC), integrated in gameplay.js with hit detection and drops. **Already shipped.** | ★☆☆ N/A |
| QW-18 | **Environmental hazards** (AAA-L3) | Already done | `hazard.js` (300 LOC), integrated in gameplay.js with damage to player AND enemies. **Already shipped.** | ★☆☆ N/A |
| QW-19 | **Boss intro VFX** (AAA-V3) | Already done | `VFX.createBossIntro()` exists and is called in gameplay.js line 414 when boss spawns. **Already shipped.** | ★☆☆ N/A |
| QW-20 | **Environmental ambience** (AAA-A2) | Already done | `audio.startAmbience()` called in gameplay.js line 104, ambienceBus wired in audio.js. **Already shipped.** | ★☆☆ N/A |
| QW-21 | **Dynamic crowd reactions on combo** (AAA-A3 partial) | Partially done | Woohoo on 5+ combo exists (gameplay.js line 297). Ugh on damage (line 349). Missing: crowd cheering audio layer. | ★☆☆ Low |
| QW-22 | **Edge case regression checklist** (EX-A4) | Documentation only | Write a checklist doc from known bugs in history.md. No code changes. | ★☆☆ Zero |
| QW-23 | **Frame data documentation** (EX-A2) | Documentation only | Document all attack frame data from player.js/enemy.js hitbox timing. No code changes. | ★☆☆ Zero |

**Summary: 23 items. 13 already shipped. 10 actionable quick wins remaining.**

### Bucket 2: "Medium Effort" — Implementable with targeted refactoring (1-4 hours each)

Requires modifying specific areas but doesn't break the overall architecture.

| # | Item | Files Touched | Effort | What To Do | Risk | Dependencies |
|---|------|--------------|--------|------------|------|--------------|
| ME-1 | **Wire EventBus into gameplay** (AAA-T2) | `gameplay.js`, `main.js`, all systems | 3-4h | Create EventBus instance in main.js, pass to scenes. Replace 40+ direct system calls in gameplay.js with `bus.emit('enemy.hit', ...)`. Systems subscribe to events. Biggest single refactor for reducing coupling. | ★★★ High — touches everything | None |
| ME-2 | **Wire AnimationController** (P1-8) | `player.js`, `enemy.js`, `animation.js` | 3-4h | AnimationController exists but unused. Define animation maps per entity state, call `anim.play(state)` + `anim.update(dt)`, use `anim.getCurrentFrame()` to drive render. Prerequisite for proper walk cycles. | ★★☆ Medium | None |
| ME-3 | **Wire SpriteCache into entity rendering** | `player.js`, `enemy.js`, `sprite-cache.js` | 2-3h | SpriteCache exists but unused. Pre-render entity states to offscreen canvases, blit with drawImage. Reduces ~2000 canvas calls/frame to ~20. Biggest performance win. | ★★☆ Medium | None |
| ME-4 | **Style/combo scoring meter** (AAA-C4) | `hud.js`, `player.js` | 1-2h | Style meter already implemented in hud.js (`_renderStyleMeter()`, `_getStyleInfo()`, levels from "Meh" to "Best. Combo. Ever."). `styleTypes` tracked on player. Partially done — verify full integration and polish display. | ★☆☆ Low | None |
| ME-5 | **Pause menu redesign** (AAA-U2) | `gameplay.js` | 2h | Replace text-only pause (gameplay.js lines 660-689) with proper menu items (Resume/Restart/Options/Quit). Add keyboard nav with highlight. backdrop blur via ctx.filter. | ★★☆ Medium | None |
| ME-6 | **Options/settings menu** (AAA-U1) | Already done | N/A | `options.js` (285 LOC) with volume sliders, difficulty select, control display. Accessible from title + pause. **Already shipped.** | ★☆☆ N/A | None |
| ME-7 | **Score breakdown screen** (AAA-U3) | `gameplay.js` or new scene | 2-3h | New screen after level complete: tally enemies, combos, time bonus, letter grade. Requires new scene or extended level-complete overlay. | ★★☆ Medium | None |
| ME-8 | **Juggle physics system** (AAA-C3) | `player.js`, `enemy.js`, `combat.js` | 3-4h | Add `airborne` state to enemies. Launch on certain hits. Allow hitting airborne enemies. Wall/floor bounce (2-3 states). Modify combat.js knockback to set enemy airborne. | ★★★ High — combat feel | Grab system (done) |
| ME-9 | **Dash attack** (AAA-C7) | `player.js`, `combat.js` | 2h | New state 'dash_attack' — double-tap forward + attack. Brawler runs forward 150px with belly hitbox. Similar to belly_bump but from neutral (no combo req). | ★★☆ Medium | Dodge (done) |
| ME-10 | **Taunt mechanic** (AAA-C5) | `player.js`, `input.js`, `audio.js` | 2h | New state 'taunt' with dedicated key. 1s vulnerability. Builds style meter. Brawler eats invisible donut. Cancellable on hit. | ★★☆ Medium | Style meter (ME-4) |
| ME-11 | **Super move meter + activation** (AAA-C6) | `player.js`, `hud.js`, `combat.js`, `vfx.js` | 3-4h | New meter filled by combat+taunts. When full, special input triggers Rage Mode (temporary berserk). Camera zoom on activation. New HUD element. | ★★★ High | Taunt (ME-10), Style (ME-4) |
| ME-12 | **Directional combo finishers** (AAA-C10) | `player.js`, `combat.js` | 2h | Detect directional input on combo chain ender. Forward=launch, Down=ground slam, Neutral=sweep. Modify attackResult return to include direction. | ★★☆ Medium | Combo system (done) |
| ME-13 | **Content data format** (EX-T4) | `data/levels.js` | 1-2h | Already partially done — LEVEL_1 has waves, destructibles, hazards. Formalize JSON-like schema with wave triggers, entity spawns, background type. levels.js is the right home. | ★☆☆ Low | None |
| ME-14 | **Character voice barks** (AAA-A1) | `audio.js` | 2-3h | Procedural voice synthesis: Ugh (descending tone + vowel filter), Woohoo, Mmm (food pickup). Audio.js already has `playGrunt()`, `playCheer()` stubs. Enhance with formant filters. | ★★☆ Medium | None |
| ME-15 | **Boss music themes** (AAA-A5) | `music.js` | 2-3h | Add boss music pattern (faster tempo, different note sequence). Music.setIntensity(3) for boss. Tempo increase on phase transitions. Victory fanfare. Music system already has 3 intensity levels. | ★★☆ Medium | Music system (done) |
| ME-16 | **Weapon pickups** (P2-7) | `gameplay.js`, `data/levels.js`, new entity | 3h | New Pickup entity (weapon type, duration). Drop from destructibles. Player holds weapon state that modifies attack hitboxes/damage. Render weapon in player hand. | ★★★ High — combat interaction | Destructibles (done) |
| ME-17 | **Food/health pickups** (P2-8) | `gameplay.js`, `data/levels.js` | 1-2h | Already partially done — destructible drops heal player (gameplay.js line 289). Needs: visual pickup entity on ground, pickup animation, sound. | ★☆☆ Low | Destructibles (done) |
| ME-18 | **Per-level rankings** (AAA-R2) | `highscore.js`, new scene | 2h | Extend localStorage to store per-level S/A/B/C/D rank. Grade based on score+time+combo. Display on level select (if exists) or title. | ★☆☆ Low | Score breakdown (ME-7) |
| ME-19 | **Input remapping** (AAA-T4) | `input.js`, `options.js` | 3h | Store key bindings in localStorage. options.js already has control display. Add rebind mode. Modify all isX() methods to use configurable mapping. | ★★★ High — touches all input | None |
| ME-20 | **Gamepad support** (AAA-T5) | `input.js` | 3h | Gamepad API polling in Input class. Map d-pad/sticks to movement, buttons to attack/jump/dodge. Auto-detect on connect. | ★★☆ Medium | Input remapping (ME-19) |
| ME-21 | **Enemy behavior tree upgrade** (EX-T1) | `ai.js` | 2-3h | ai.js already uses behavior tree pattern with conditions + actions. Upgrade: add flanking behavior, coordinated group attacks, formation holding. | ★★☆ Medium | None |
| ME-22 | **Fast/Heavy enemy enhancements** (P2-2/P2-3) | `enemy.js`, `ai.js`, `data/levels.js` | 2h | Fast: afterimage trail, sliding attack. Heavy: ground slam shockwave, armor flash VFX. Data in levels.js, behavior in ai.js, rendering in enemy.js. | ★★☆ Medium | None |
| ME-23 | **Ranged enemy type** (P3-5) | `enemy.js`, `ai.js`, `data/levels.js` | 3h | New variant in ENEMY_TYPES. AI: maintain distance, fire projectile. New Projectile entity or inline in enemy.js. Render: unique silhouette. | ★★★ High — new entity type | Content data format (ME-13) |
| ME-24 | **Shield enemy type** (P3-6) | `enemy.js`, `ai.js`, `combat.js` | 3h | New variant with frontal shield. Block attacks from facing direction. Must grab or attack from behind. Modify combat.js hit detection. | ★★★ High | Grab (done), Content format (ME-13) |
| ME-25 | **Mini-boss encounters** (EX-T8) | `data/levels.js`, `ai.js` | 2h | Create mini-boss variants (e.g., tough_bruiser) with unique AI patterns. Data-driven from levels.js. | ★★☆ Medium | Behavior upgrade (ME-21) |
| ME-26 | **60fps performance budget** (AAA-T1) | All render files | 3-4h | Profile with devtools. Priority: wire SpriteCache (ME-3), batch canvas calls, object pool particles. Target: 60fps with 10+ enemies + VFX. | ★★☆ Medium | Sprite cache (ME-3) |
| ME-27 | **Automated smoke tests** (AAA-T6) | New test file | 3h | Headless test: init game → spawn player → simulate input → verify combat → verify score → verify wave → verify complete. Requires EventBus for assertions. | ★★★ High | EventBus (ME-1) |
| ME-28 | **Brawler walk cycle animation** (P1-9) | `player.js` | 3h | Replace `walkBob` sine wave (line 603) with proper multi-frame walk: legs alternate, arms swing, body sway. All in player.js render method. 400 LOC of Canvas drawing to modify. | ★★★ High — visual quality | AnimationController (ME-2) |
| ME-29 | **Brawler attack animations** (P1-10) | `player.js` | 3h | Replace static arm positions with multi-frame anticipation → active → recovery. Wind-up frames, follow-through. Currently just arm angle changes. | ★★★ High — combat feel | AnimationController (ME-2) |
| ME-30 | **Enemy unique silhouettes** (vis-mod §2.1-2.4) | `enemy.js` | 3-4h | Currently all enemies share same body shape (just recolored). Give each variant unique proportions, accessories, poses. Heavy: wider, armored. Fast: lean, hooded. Boss: distinctive. | ★★☆ Medium | None |
| ME-31 | **Death animations** (AAA-V8) | `enemy.js` | 2h | Currently: spin + fade (lines 323-333). Upgrade: variant-specific deaths. Normal: ragdoll bounce. Heavy: dramatic fall. Fast: fly off screen. Boss: multi-stage collapse. | ★★☆ Medium | None |
| ME-32 | **Background landmark expansion** (vis-mod §3.2) | `background.js` | 2-3h | background.js already has Quick Stop, Joe's Bar, Comic Shop, Elementary, Donut Shop, Bargain Outlet, Founder statue. Add: Burger Joint, neighbor house, player house, town hall. | ★☆☆ Low | None |
| ME-33 | **Hitbox visualization** (EX-A1) | Already done | N/A | `debug-overlay.js` (150 LOC) draws hurtboxes (green) and attack hitboxes (red) with labels. Toggle with backtick key. **Already shipped.** | ★☆☆ N/A | None |

**Summary: 33 items. 3 already shipped. 30 actionable medium-effort items remaining.**

### Bucket 3: "Future Project Learnings" — Would require major refactor or migration

Things that are too late to do well on Canvas 2D / current architecture. Captured as LEARNINGS for next project.

| # | Item | Why It's Future | Canvas 2D Ceiling | Phaser 3 / Next-Gen Solution |
|---|------|----------------|-------------------|------------------------------|
| FUT-1 | **Shader-based effects** (glow, bloom, blur) | Canvas 2D has no programmable shaders. `ctx.filter` is software-rendered and slow. | Can fake with shadowBlur sparingly | Phaser 3 has built-in WebGL pipeline with shader support, bloom/glow filters at zero CPU cost |
| FUT-2 | **Skeletal animation** (Spine-like) | Our procedural drawing means redrawing every frame from code (~400 LOC per entity). Bone hierarchies with interpolation need a runtime. | Can approximate with frame-based animation controller (ME-2) but no blending/IK | Phaser 3 + Spine plugin gives bone animation, blend trees, IK, cloth physics out of the box |
| FUT-3 | **WebGL rendering pipeline** | All rendering is CPU-bound single-threaded. At 20+ entities with full VFX, we hit the ceiling. Sprite caching helps but doesn't solve. | Realistic ceiling: ~50 entities + moderate VFX at 60fps with sprite caching | Phaser 3 WebGL renderer: GPU sprite batching, 1000+ sprites at 60fps, render textures |
| FUT-4 | **Online multiplayer** | Requires WebSocket/WebRTC, server-authoritative state, rollback netcode. Far beyond scope. | Not attempted | Colyseus or Socket.io server + Phaser 3 client. Still complex but framework handles rendering. |
| FUT-5 | **Sprite sheet asset pipeline** | We're 100% procedural drawing — no bitmap assets. Importing sprites needs: asset loading, atlas packing, frame extraction, async load. | Could load individual images but no batching/atlas support | Phaser 3 has built-in texture atlas, sprite sheet animation, asset loader with progress |
| FUT-6 | **Advanced particle system** (GPU) | Our ParticleSystem is CPU-bound (array splice, per-particle math). Good for ~200 particles. | CPU ceiling at ~500 particles | Phaser 3 particle emitter: GPU-accelerated, 10,000+ particles, physics, emission shapes |
| FUT-7 | **Local multiplayer** | Technically possible (Gamepad API) but input conflicts with 2 players on keyboard. No entity system for multiple players. | Feasible but awkward — player.js assumes single instance | Phaser 3 input plugin handles multiple gamepads natively. Entity system supports n players. |
| FUT-8 | **Mobile touch controls** | Touch for 6-button beat 'em up needs virtual joystick + buttons. UX challenge. | Possible but painful — no touch framework | Phaser 3 virtual joystick plugin, touch input zones, mobile-responsive scaling |
| FUT-9 | **Kid/Defender/Prodigy playable characters** (AAA-CH2-CH4) | Each requires ~800 LOC of procedural Canvas drawing (new body, animations, unique hitboxes). 3 chars = 2400 LOC of rendering code. | Doable but incredibly labor-intensive — each character is a full rewrite of player.js render | Phaser 3 + sprite sheets: artist draws in Aseprite, export animation frames, load & play. Art pipeline replaces code. |
| FUT-10 | **Level 2 + Level 3** (AAA-L4/L5) | Each level needs ~600 LOC of new background procedural drawing (unique buildings, landmarks, palette). background.js is already 600+ LOC for one level. | Technically possible but diminishing returns on procedural art | Phaser 3 tilemap editor (Tiled) → export JSON → load in Phaser. Artists build levels visually. |
| FUT-11 | **Character select screen** (AAA-CH1) | Needs animated character previews, stat comparison, smooth transitions. Heavy Canvas 2D rendering for a UI screen. | Doable but requires custom animation rendering per character | Phaser 3 scene manager + tween system + sprite animations make this trivial |
| FUT-12 | **Weather/atmosphere system** (AAA-V7) | Rain particles, fog overlay, sky gradients need many transparent layers = performance hit on Canvas 2D. | Can fake with overlay rectangles at 50% alpha, ~100 rain particles max | Phaser 3 particle weather, WebGL blend modes, post-processing pipeline |
| FUT-13 | **Set piece encounters** (AAA-L7) | Scrolling platform fights, chase sequences need camera system overhaul and entity physics changes. | Camera class is simple follow/lock only — no cinematic camera modes | Phaser 3 camera: follow, scroll, lerp, shake, flash, zoom, viewport, all built-in |
| FUT-14 | **Automated visual regression testing** | No test framework at all — vanilla JS with no build step. | Would need to add a test runner (unlikely in zero-dependency project) | Standard testing frameworks (Vitest, Playwright) with Phaser's headless mode |

**Summary: 14 items documented as future/migration targets.**

---

## 3. Already-Shipped Items (Discovery)

During this analysis, I found **13 AAA backlog items that are already implemented** but may not be tracked as complete:

| Item | Evidence |
|------|----------|
| AAA-C1 Grab/throw system | player.js lines 49-56, 221-258; combat.js lines 16-104 |
| AAA-C2 Dodge roll with i-frames | player.js lines 59-65, 151-162, 199-214, 487 |
| AAA-C8 Back attack | player.js lines 260-344, 529-536 |
| AAA-C9 Attack buffering | input.js lines 7-68; player.js line 318 |
| AAA-V1 Screen zoom on power hits | game.js lines 36-40; gameplay.js line 219 |
| AAA-V2 Slow-motion final kill | game.js lines 42-45; gameplay.js line 391 |
| AAA-V6 Scene transitions | game.js lines 24-130 (fade-in/fade-out) |
| AAA-L1 Destructible objects | destructible.js (325 LOC); gameplay.js lines 84, 244, 280-294 |
| AAA-L3 Environmental hazards | hazard.js (300 LOC); gameplay.js lines 87, 246, 354-370 |
| AAA-V3 Boss intro VFX | VFX.createBossIntro(); gameplay.js line 414 |
| AAA-A2 Environmental ambience | audio.js ambienceBus; gameplay.js line 104 |
| AAA-A4 Hit sound combo scaling | audio.js lines 159-183, 4 tiers |
| AAA-U1 Options/settings menu | options.js (285 LOC), volume sliders + difficulty |
| EX-A1 Hitbox visualization | debug-overlay.js (150 LOC), toggle with backtick |

**This means the active backlog should be ~85 items, not 101.**

---

## 4. Architecture Learnings

### What Patterns Worked Well

1. **Scene lifecycle pattern** — `onEnter/onExit` with `switchScene()` is clean, simple, and handles all transitions. Game.js owns the loop, scenes own behavior. This pattern should be reused in Phaser 3.

2. **Static utility classes** — `Combat.handlePlayerAttack()` and `AI.updateEnemy()` as static methods avoid unnecessary instantiation. Data flows through parameters, not instance state. Clean functional style.

3. **Attack throttling via slots** — `AI.activeAttackers` with per-frame reset prevents gangpile attacks. Simple, effective, and creates readable fight choreography.

4. **Mix bus audio architecture** — Master → SFX/Music/UI/Ambience routing with independent gain nodes is professional-grade. Enables per-channel volume, muting, and spatial effects without changing sound callsites.

5. **Layered hit sound engine** — Bass thud + mid crack + high sparkle with intensity parameter creates rich hit sounds from pure synthesis. No assets needed. This entire Audio system transfers to any project.

6. **Data-driven level definitions** — `src/data/levels.js` with typed enemy configs + wave triggers + destructible placements + hazard placements is the right pattern. Separates content from code.

7. **VFX factory pattern** — `VFX.createHitEffect()`, `VFX.createKOText()`, `VFX.createSpawnEffect()` as static factories that return effect objects added to an instance list. Clean separation of creation from management.

### What Caused Problems

1. **God scene anti-pattern** — gameplay.js (695 LOC) directly orchestrates player, enemies, combat, AI, VFX, particles, audio, camera, waves, destructibles, hazards, and HUD. Every new feature adds more lines here. Event bus exists but isn't wired.

2. **Rendering coupled to entities** — Player render is ~400 LOC inside player.js. Enemy render is ~400 LOC inside enemy.js. Any visual change requires editing gameplay logic files. Should be separate Renderer components.

3. **Unused infrastructure** — EventBus (49 LOC), AnimationController (85 LOC), SpriteCache (35 LOC), CONFIG (45 LOC) all exist and are complete, but NONE are wired into the game. 214 LOC of working infrastructure gathering dust.

4. **Duplicate data sources** — Wave data exists in both `WAVE_DATA` (gameplay.js) and `LEVEL_1.waves` (levels.js). Hazards/destructibles correctly use levels.js but waves don't. Creates maintenance confusion.

5. **No test infrastructure** — Zero tests. Zero assertions. Changes are validated only by manual play. Every feature addition is a regression risk.

6. **Procedural art scaling problem** — Each entity needs ~400 LOC of Canvas draw calls for rendering. Adding a new character means writing 400+ new lines of art code. This doesn't scale past 2-3 characters.

---

## 5. Multi-Agent Development Learnings

### What Happens When 8+ Agents Edit the Same Codebase

1. **Integration instructions are critical** — VFX.js, destructible.js, and hazard.js all include detailed integration comments (20-30 lines each) explaining exactly how gameplay.js should wire them. This prevented merge conflicts because the integrator (gameplay.js owner) knew exactly what to do.

2. **God scene is the bottleneck** — gameplay.js is touched by every feature. Audio needs hooks there. VFX needs hooks there. Combat needs hooks there. Hazards need hooks there. The scene decomposition (Session 5) helped but didn't solve it. EventBus wiring (ME-1) is the real solution.

3. **Data-driven design enables parallel work** — levels.js can be edited by a content designer without touching gameplay code. enemy types, wave compositions, destructible placements, and hazard placements are all data. This is the model for all content.

4. **Feature flags prevent half-done features** — Using `if (typeof VFX.createMotionTrail === 'function')` guards (gameplay.js line 190) allows VFX features to be added/removed independently. Defensive programming for multi-agent development.

5. **Naming conventions matter more with many agents** — Consistent `camelCase` for methods, `UPPER_CASE` for constants, `kebab-case` for files. When 8 agents follow the same convention, code reads as one voice.

6. **Infrastructure gets built but not wired** — Three agents independently built useful systems (EventBus, AnimationController, SpriteCache) but no one wired them in. The "wiring" task is unglamorous but critical. Solo should own explicit "wire X into Y" tasks.

7. **Comment-based integration contracts work** — The pattern of "here's how to integrate this" comments at the top of files (destructible.js, hazard.js, vfx.js, debug-overlay.js) is a lightweight API contract. Better than nothing, worse than TypeScript interfaces.

---

## 6. Technical Debt Inventory

| Debt Item | Location | Impact | Fix Effort |
|-----------|----------|--------|------------|
| **Unused EventBus** | `events.js` | Systems tightly coupled to gameplay.js. Adding features = more god-scene LOC. | 3-4h (ME-1) |
| **Unused AnimationController** | `animation.js` | Entities use hardcoded sine-wave bobbing. No real animation system despite one existing. | 3-4h (ME-2) |
| **Unused SpriteCache** | `sprite-cache.js` | ~2000 canvas API calls/frame for entity rendering. Performance ceiling hit at 10+ entities. | 2-3h (ME-3) |
| **Unused CONFIG** | `config.js` | Hardcoded values scattered across player.js, enemy.js, combat.js. Balance tuning requires editing 4+ files. | 1h (QW-2) |
| **Duplicate wave data** | `gameplay.js` + `levels.js` | Two sources of truth for wave definitions. Editing one doesn't update the other. | 30min (QW-8) |
| **Player render in player.js** | `player.js` (400+ LOC) | Gameplay logic mixed with rendering. Can't change art without risking gameplay bugs. | 4h+ to extract |
| **Enemy render in enemy.js** | `enemy.js` (400+ LOC) | Same as above. Each new enemy variant adds 100+ LOC of render code to enemy.js. | 4h+ to extract |
| **No tests** | Entire codebase | Zero automated tests. Manual testing only. Every change is a regression gamble. | 3h for smoke tests (ME-27) |
| **40+ direct system calls in gameplay.js** | `gameplay.js` | audio.playX(), vfx.addEffect(), particles.emit(), renderer.screenShake() called directly. Hard to add new effects or change behavior without editing god scene. | Fixed by EventBus (ME-1) |
| **game._resumeScene, game._suspendScene** | `game.js`, `gameplay.js`, `options.js` | Private-convention underscored properties used as cross-scene state flags. Fragile. Should be a proper state machine. | 1h to clean up |

---

## 7. Phaser 3 Comparison — What We Built vs What's Free

| Our Custom System | LOC | What Phaser 3 Gives Free | Verdict |
|-------------------|-----|--------------------------|---------|
| **Game loop** (game.js) | 190 | `Phaser.Game` with config, fixed timestep, scene manager, camera, physics — all built-in | Replace entirely |
| **Renderer** (renderer.js) | 112 | WebGL renderer with automatic batching, HiDPI, camera transforms, zoom, shake — zero code | Replace entirely |
| **Input** (input.js) | 128 | Keyboard, mouse, gamepad, touch — all with key combos, duration, just-pressed/released | Replace entirely |
| **Scene manager** (game.js) | ~40 | Scene lifecycle with `create/update/render`, transition effects, parallel scenes, data passing | Replace entirely |
| **Camera** (camera.js) | 35 | Camera system with follow, dead zone, lerp, bounds, zoom, shake, flash, fade, scroll factor | Replace entirely |
| **Sprite cache** (sprite-cache.js) | 35 | Texture manager with atlas, sprite sheets, dynamic textures, render textures | Replace entirely |
| **Particle system** (particles.js) | 143 | GPU particle emitter with zones, emitter configs, blend modes, 10,000+ particles | Replace entirely |
| **Animation controller** (animation.js) | 85 | Animation manager with frame-based and time-based, blend, chain, events, sprite sheet integration | Replace entirely |
| **Audio** (audio.js) | 900+ | Web Audio plugin with spatial audio, markers, looping, fading, decoding — but NOT procedural synthesis | Keep procedural synthesis approach, use Phaser for playback management |
| **Music** (music.js) | 260 | Background music with looping, crossfade, volume — but NOT procedural generation | Keep procedural approach — this is unique to our project |
| **VFX** (vfx.js) | 1200+ | Particle emitters cover 50%. Shaders/filters cover 30%. Custom effects still needed for KO text, boss intros, etc. | Partial replacement — keep custom effect types |
| **Background** (background.js) | 600+ | Tilemap layers with parallax scroll factors built-in. But procedural drawing is our choice. | Keep procedural approach OR migrate to tilemap |
| **AI** (ai.js) | 346 | No built-in AI. Phaser doesn't provide game-specific AI. | Keep entirely — this is game-specific logic |
| **Combat** (combat.js) | 250 | Arcade physics has overlap/collide. But combat logic (hitboxes, damage, combos) is game-specific. | Keep entirely — game-specific |
| **HUD** (hud.js) | 530+ | No built-in HUD. DOM overlay or Canvas drawing is still manual. | Keep — game-specific UI |

**Bottom line:** Phaser 3 replaces ~800 LOC of infrastructure (game loop, renderer, input, camera, particles, animation, sprite cache) with battle-tested, GPU-accelerated equivalents. We keep ~3500 LOC of game-specific logic (AI, combat, VFX, HUD, audio synthesis, background art, entities). Migration cost: 2-3 weeks for an experienced developer.

---

## 8. Prioritized Action Plan

### Phase 0: Foundation Wiring (Do First — Unblocks Everything)
1. **QW-2**: Wire CONFIG into all entities (1h)
2. **QW-8**: Fix duplicate wave data (30min)
3. **ME-1**: Wire EventBus into gameplay (3-4h)
4. **ME-2**: Wire AnimationController (3-4h)
5. **ME-3**: Wire SpriteCache (2-3h)

**Why:** These 5 items address the top technical debts and unblock 80% of the remaining backlog. Every visual, audio, and gameplay improvement becomes easier once these are done.

### Phase 1: Quick Wins Sprint
Items QW-1 through QW-23 (remaining 10 actionable). Ship them all in a single session. Each is < 1 hour and improves the game with zero risk.

### Phase 2: Combat Polish
Items ME-8 through ME-12 (juggle, dash, taunt, super, combo finishers). These build on the already-shipped grab/dodge/back-attack foundation.

### Phase 3: Content + Visual Quality
Items ME-28 through ME-32 (walk cycles, attack animations, enemy silhouettes, death animations, landmarks). The visual quality gap.

### Phase 4: System Polish
Items ME-5 through ME-7 (pause menu, score breakdown), ME-14-15 (voice barks, boss music), ME-18 (rankings).

### Beyond: Phaser 3 Migration
All FUT items. Start fresh with the architectural learnings from this project. Keep the game logic, replace the engine.

---

*This document is the authoritative source for what's implementable, what's shipped, and what's deferred. Cross-reference with aaa-gap-analysis.md for full item descriptions.*
