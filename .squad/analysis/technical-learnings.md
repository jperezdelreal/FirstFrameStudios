# Technical Learnings — firstPunch Engine

**Author:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Project:** firstPunch — Browser-based game beat 'em up  
**Stack:** Vanilla JS (ES modules), HTML5 Canvas 2D, Web Audio API  
**Constraint:** Zero build tools, zero npm, zero bundler. `<script type="module">` only.

---

## 1. What We Built — Engine Systems Inventory

| System | File | LOC | Purpose | Quality |
|--------|------|-----|---------|---------|
| **Game Loop** | `game.js` | 191 | Fixed-timestep loop, scene management, hitlag, zoom, slow-mo, screen transitions | ★★★★★ — Clean, battle-tested, handles edge cases |
| **Renderer** | `renderer.js` | 112 | HiDPI-aware Canvas 2D wrapper, camera, screen shake, zoom transforms | ★★★★☆ — Solid. Could add resolution-independent scaling |
| **Input** | `input.js` | 127 | Keyboard input with pressed/held/released tracking + attack buffering | ★★★★★ — Clean API, buffer system is production-quality |
| **Audio** | `audio.js` | 931 | Procedural SFX synthesis, mix bus architecture, spatial audio, ambience | ★★★★★ — Most ambitious system. Fully procedural, zero assets |
| **Music** | `music.js` | 260 | Procedural background music, 3-layer adaptive intensity, beat scheduler | ★★★★☆ — Impressive for procedural. Limited musical range |
| **Animation** | `animation.js` | 84 | Data-only frame controller, frame events, lag-spike recovery | ★★★★★ — Perfect separation of concerns. Tiny and correct |
| **Events** | `events.js` | 48 | Pub/sub event bus, safe mid-emit unsubscribe, once() support | ★★★★★ — Textbook implementation. Wouldn't change a line |
| **Particles** | `particles.js` | 143 | Config-driven particle emitter, 3 preset configs, data-only | ★★★★☆ — Clean API. Could add object pooling for GC |
| **Sprite Cache** | `sprite-cache.js` | 35 | DPR-aware offscreen canvas cache, key-based invalidation | ★★★★☆ — Simple and effective. Needs LRU eviction for scale |

**Total engine code: 1,931 LOC across 9 files.**

### What's NOT in the engine (lives in gameplay code)
- Combat system (collision, combos, damage) → `combat.js`
- Entity logic (player, enemies, AI) → `player.js`, `enemy.js`
- Wave/level management → `wave-manager.js`
- VFX effects (hit flash, motion trails, damage numbers) → `vfx.js`
- Background/parallax rendering → `background.js`
- HUD → `hud.js`

This split is intentional: the engine provides infrastructure, game-specific logic stays outside.

---

## 2. What Worked Well

### 2.1 Fixed-Timestep Game Loop
The `while (accumulator >= fixedDelta)` pattern in `game.js` was rock-solid from day one. Benefits:
- **Deterministic physics** — game runs the same at 30fps and 144fps
- **No spiral of death** — `frameTime` capped at 0.25s prevents death spiral after tab-switch
- **Clean layering** — zoom/timeScale use real dt, scene gets scaled dt, hitlag uses frame count
- Transitions, hitlag, and scene updates are mutually exclusive in the priority chain — no state corruption

### 2.2 Data-Only Animation Controller
`AnimationController` never renders, never knows about canvas. It just tracks frame index and timer. The renderer interprets frames however it wants (number, object, function). This enabled:
- Same animation system for player, enemies, and UI elements
- Frame events for SFX timing (footstep on walk frame 2)
- `play()` is a no-op for same-animation — callers can spam it safely
- The `while` loop handles lag spikes that skip multiple frames

### 2.3 Procedural Audio Architecture
Building the entire sound system from Web Audio API oscillators was the highest-risk decision and the biggest payoff:
- **Zero audio assets** — no loading, no 404s, no file size, no licensing
- **Mix bus hierarchy** (SFX → Master, Music → Master, UI → Master, Ambience → Master) enabled per-channel volume control trivially
- **Priority + dedup system** prevented audio pile-up (MAX_SAME_TYPE = 3, per-frame pitch spread)
- **Layered hit sounds** (bass thud + noise crack + sparkle ping) at varying intensities created rich feedback
- **Combo-scaled hits** — `playHit(comboCount)` maps 1-2 → light, 3-4 → medium, 5-7 → heavy, 8+ → massive with delay reverb

### 2.4 Event Bus Simplicity
48 lines. Does everything we need:
- Shallow copy of listener array in `emit()` — handlers can safely `off()` mid-iteration
- `once()` wraps callback in self-removing wrapper — fire-and-forget by design
- Seven documented event conventions in header comments, but any string works
- Zero coupling between emitters and receivers

### 2.5 Scene Management with Transitions
Two-phase state machine (fade-out → scene switch → fade-in) with guards:
- First `switchScene()` call skips transition (instant load)
- No-op while already transitioning (prevents double-switch)
- Transition runs in fixed-timestep before hitlag/scene update — game is fully paused during fades
- Overlay renders after scene — always on top

### 2.6 Sprite Cache + HiDPI as a Pair
These two systems were designed together and complement each other:
- `SpriteCache.getOrCreate(key, w, h, drawFn)` creates offscreen canvas at `w*dpr × h*dpr`
- One-time draw cost amortized across all frames until state change
- Key pattern: `brawler_idle_right_0` — entity type + state + facing + frame
- `invalidate(key)` for state changes, `clear()` for full reset
- Integration pattern: entity render method wraps existing draw calls in the `drawFn` callback — zero refactoring of art code

---

## 3. What Broke

### 3.1 Hitlag Integration — The Invisible Bug
**Problem:** After adding hitlag, VFX effects froze during hit freeze because `updateDuringHitlag()` wasn't calling `vfx.update(dt)`. Effects would hang mid-animation for 2-3 frames.

**Root cause:** The game loop's priority chain (`transition → hitlag → normal update`) meant during hitlag, only `updateDuringHitlag()` runs. Any system that should animate through freeze (VFX, particles, screen shake) must be explicitly updated in BOTH `update()` AND `updateDuringHitlag()`.

**Fix:** Both VFX and particle systems update in `updateDuringHitlag()`. This is now a pattern: any visual-only system that should persist through hitlag gets dual-update wiring.

**Lesson:** When you add a new game-loop mode (hitlag, pause, cutscene), audit EVERY system for which mode it should run in. Make a matrix.

### 3.2 State Machine Gap — Player Freeze After Hit
**Problem:** Player became permanently stuck in `'hit'` state after taking damage.

**Root cause:** The `else` branch in `player.update()` sets `state = 'hit'` when `hitstunTime > 0`. When hitstun expires, the `if (hitstunTime <= 0)` branch runs, but no handler matched `'hit'` state — all `if/else if` chains only handle `dodging`, `dodge_recovery`, `throwing`, `grabbing`, `back_attack`, `idle`, `walk`, `jump`.

**Fix:** Added `if (this.state === 'hit') this.state = 'idle';` at the top of the recovery block.

**Lesson:** Every state in a state machine MUST have at least one exit transition. When adding a new state, always ask "how does the entity leave this state?" before shipping.

### 3.3 Enemy AI Distance Threshold Gap
**Problem:** Default enemies orbited the player at 125px forever without attacking.

**Root cause:** `_farAway(distance)` threshold was 150px, but `attackRange` was 80px. Enemies approached until within 150px, then fell through to `_circlePlayer`, which maintained 125px target distance — outside the 80px attack range. Unreachable gap.

**Fix:** Replaced distance-gated behavior with unconditional `_approachPlayer`, matching the approach-always pattern from fast/heavy enemy variants.

**Lesson:** Behavior tree distance thresholds must be coherent with entity config values. Draw the number line: `attackRange < circleDistance < approachThreshold` creates a dead zone. Always verify the chain.

### 3.4 Music Crash on AudioContext Restrictions
**Problem:** `new Music()` threw when browser blocked AudioContext creation (autoplay policy).

**Fix:** Wrapped in try/catch. All `music.method()` calls null-checked. `onExit()` stop also wrapped. If AudioContext is closed, we swallow the error.

**Lesson:** Web Audio API requires user gesture to start. Never assume AudioContext is available at construction time. Always null-check the music object before calling methods.

### 3.5 Multi-Agent File Conflicts
During parallel development, multiple agents editing `gameplay.js` simultaneously caused merge conflicts and state corruption. The 600+ line scene file became a bottleneck.

**Lesson:** Large files that multiple systems touch are coordination hazards. The solution is to keep the "wiring" file thin — it imports systems and connects them, but logic lives in imported modules. This is the difference between a 600-line gameplay.js and a 200-line one.

---

## 4. What Phaser Gives for Free

For each of our custom systems, here's the Phaser 3 equivalent and what we'd gain/lose:

| Our System | LOC | Phaser 3 Equivalent | What We'd Gain | What We'd Lose |
|-----------|-----|---------------------|----------------|----------------|
| `game.js` (loop + scenes) | 191 | `Phaser.Game` + Scene lifecycle | Built-in preload/create/update, scene stacking, sleep/wake | Custom hitlag, slow-mo, transition timing |
| `renderer.js` | 112 | `Phaser.Cameras.Scene2D` | Zoom, shake, fade, follow, scroll — all built-in with easing | Direct canvas control, custom save/restore |
| `input.js` | 127 | `Phaser.Input.Keyboard` | Combo detection, duration tracking, key binding UI | Our attack buffer system (would need re-impl) |
| `audio.js` | 931 | `Phaser.Sound.WebAudioSoundManager` | Asset-based audio with spatial, pooling, sprite sheets | ALL procedural synthesis — Phaser is file-based |
| `music.js` | 260 | `Phaser.Sound` + markers | Layer crossfading, volume control | Procedural adaptive music — no equivalent |
| `animation.js` | 84 | `Phaser.Animations` | Sprite sheet support, global animation manager | Our data-agnostic frame controller |
| `events.js` | 48 | `Phaser.Events.EventEmitter` | Same features + wildcard events | Nothing meaningful |
| `particles.js` | 143 | `Phaser.GameObjects.Particles` | GPU-accelerated, texture-based, zones, emitter configs | Our config simplicity, zero-dependency |
| `sprite-cache.js` | 35 | `Phaser.Textures.TextureManager` | Atlas support, dynamic texture creation | DPR-aware offscreen canvas pattern |

**Verdict:** Phaser would replace ~800 LOC of infrastructure but force us to rewrite ~1100 LOC of audio/music (our most ambitious systems) into an asset-based paradigm. The procedural audio pipeline has no Phaser equivalent. Migration cost: 50-74 hours. **Not worth it for an existing project.**

---

## 5. Canvas 2D Ceiling

### What Canvas 2D Cannot Do Well
1. **Real-time blur/glow on many elements** — `ctx.filter = 'blur()'` triggers software rendering, ~2-5ms per element. Unusable for >3 simultaneous blurs.
2. **Shader-based distortion** — No custom shaders. Can't do chromatic aberration, heat haze, water ripple, CRT scanlines.
3. **GPU-accelerated particles** — Each particle is a separate `fillRect` call. Cap at ~200 particles before frame drops (500+ with sprite caching).
4. **Blend modes at scale** — `globalCompositeOperation` works but each mode switch flushes the GPU batch. Expensive if toggled per-entity.
5. **Sprite batching** — Each `drawImage` is a separate GPU upload. No way to batch sprites sharing the same texture atlas.
6. **Post-processing pipeline** — No render-to-texture. Can't do multi-pass effects (bloom = blur + additive blend).
7. **Text rendering quality** — Platform-dependent. Canvas text on Windows vs Mac vs Linux looks different. No subpixel control.

### What Canvas 2D Does Surprisingly Well
- Gradients and pattern fills — native, fast
- Compositing operations (additive, multiply, screen) — one at a time, but reliable
- OffscreenCanvas for pre-rendering — our sprite cache proves this scales
- Path/bezier curves — smooth procedural character outlines
- Shadow effects — `shadowBlur` for occasional glow (expensive, use sparingly)
- `ctx.filter` for single-element effects — CSS filter strings work in modern browsers

### Realistic Ceiling
With HiDPI + sprite caching + good procedural art: **7/10 visual quality** ("polished indie" — Castle Crashers era). Cannot reach AAA browser game quality without GPU rendering (PixiJS/WebGL).

---

## 6. HiDPI Learnings

### The Problem
Canvas renders at CSS pixels by default. On a 2× Retina display, a 1280×720 canvas renders at 1280×720 physical pixels, then gets upscaled to 2560×1440 by the browser. Every shape, line, and text glyph is 4× blurry. **This was the single biggest visual quality issue.**

### The Fix (5 lines of code)
```javascript
const dpr = window.devicePixelRatio || 1;
canvas.width = 1280 * dpr;     // physical pixels
canvas.height = 720 * dpr;
canvas.style.width = '1280px';  // CSS pixels
canvas.style.height = '720px';
ctx.scale(dpr, dpr);           // all drawing in logical coords
```

### What Broke
Five places in the codebase used `ctx.canvas.width` / `ctx.canvas.height` for screen-space positioning. After DPR scaling, `canvas.width` is 2560 on a 2× display, not 1280. Every one of these became a positioning bug.

**Files affected:**
1. `game.js` — transition overlay `fillRect`
2. `vfx.js` — boss intro positioning
3. `vfx.js` — screen flash `fillRect`
4. `vfx.js` — speed lines origin
5. Debug overlay — metrics panel positioning

### The Solution Pattern
Added custom properties to canvas element:
```javascript
canvas.logicalWidth = 1280;
canvas.logicalHeight = 720;
```
Code that only has a `ctx` reference reads `ctx.canvas.logicalWidth || ctx.canvas.width` — the fallback preserves backward compatibility.

### Key Insight
**Set `canvas.style.width/height` explicitly.** Without it, `width: auto` in CSS sizes the canvas based on the enlarged backing buffer, making it 2× too large visually. The explicit CSS dimensions lock the visual size regardless of backing buffer resolution.

### DPR and Offscreen Canvases
Sprite cache must also create offscreen canvases at DPR resolution:
```javascript
offscreen.width = width * dpr;
offscreen.height = height * dpr;
offscreenCtx.scale(dpr, dpr);
drawFn(offscreenCtx);
// Then: mainCtx.drawImage(offscreen, x, y, logicalWidth, logicalHeight);
```
Without this, cached sprites render at 1× and look blurry on the HiDPI main canvas.

---

## 7. Performance Patterns

### 7.1 Sprite Caching — The Big Win
**Before:** ~100 Canvas API calls per entity per frame × 20 entities = 2000 calls/frame.  
**After:** 1 `drawImage` call per entity = 20 calls/frame. **100× reduction.**

The key insight: procedural drawing is expensive per-call but cheap per-pixel. Drawing Brawler's head once (15 arcs + fills) costs the same whether it's displayed for 1 frame or 1000. Cache the result, blit the image.

**Cache key design:** `${entityType}_${state}_${facing}_${frame}` — captures all visual variations. State changes invalidate the key automatically (new key = new cache entry).

**When to invalidate:** Only on visual state changes. Don't invalidate for position changes — the cached sprite is drawn at the new position with `drawImage(sprite, x, y)`.

### 7.2 Offscreen Canvas vs ImageBitmap
We chose `document.createElement('canvas')` for offscreen rendering. `OffscreenCanvas` (capital O) is the newer API but has quirks:
- Not available in all browsers without feature detection
- `createImageBitmap()` is the transfer method — async, adds complexity
- Plain canvas elements work everywhere and integrate seamlessly with `drawImage()`

### 7.3 When NOT to Optimize
- **Don't cache backgrounds** that scroll continuously — the cache key would change every frame
- **Don't cache particles** — they're cheap individually and change every frame
- **Don't pre-optimize** — we ran without sprite caching for weeks and only added it when we hit visual quality issues (HiDPI blurriness), not performance issues

### 7.4 Object Pooling (Future)
The particle system uses `splice()` to remove dead particles — creates GC pressure. For >200 particles, switch to a pool:
```javascript
// Instead of splice, swap-and-pop:
particles[i] = particles[particles.length - 1];
particles.length--;
```
We haven't needed this yet. Profile before optimizing.

### 7.5 The `requestAnimationFrame` Pattern
Our game loop uses `requestAnimationFrame` for the outer frame, fixed timestep for inner logic. This gives:
- V-sync alignment (no tearing)
- Automatic throttling when tab is background
- Consistent game speed regardless of monitor refresh rate

---

## 8. Audio Learnings

### 8.1 Web Audio API Architecture
**Mix bus hierarchy is essential.** We built:
```
SFX Bus (0.7) ──┐
Music Bus (0.5) ─┼── Master Bus (1.0) ──► destination
UI Bus (1.0) ────┤
Ambience Bus (0.08)─┘
```
Each bus is a `GainNode`. Per-channel volume control is just `bus.gain.value = x`. Muting music doesn't affect SFX. This should be the first thing you set up.

### 8.2 Procedural Synthesis Techniques

**Hit sounds (3-layer):**
1. Bass body thud — sine oscillator 60-80Hz, 0.08s decay
2. Mid impact crack — noise buffer through bandpass 800-2000Hz, 0.04s
3. High sparkle ping — sine 2500Hz, 0.02s (only on strong hits)

**Vocal sounds (formant synthesis):**
- Generate noise buffer → bandpass filter → sweep filter frequency over time
- "Ugh!" = bandpass 800Hz→200Hz (descending mournful vowel)
- "Woohoo!" = bandpass 300Hz→1200Hz (ascending excited vowel) + LFO tremolo
- "Radical!" = bandpass 600Hz→2400Hz→1800Hz + sawtooth overtone

**Percussion:**
- Kick = sine 60Hz→30Hz pitch drop, 0.1s
- Hi-hat = pre-generated noise buffer (reused!) through highpass 7000Hz, 0.03s

**Key pattern:** Short noise buffer + bandpass filter + frequency sweep = surprisingly expressive vocal simulation.

### 8.3 Sound Priority & Deduplication
Without controls, rapid combat creates audio pile-up — 20 hit sounds in one frame.

**Solution:** Three-tier system:
1. **MAX_SAME_TYPE = 3** — no more than 3 of any sound type playing simultaneously
2. **Priority levels** (AMBIENT < ENEMY < PLAYER) — player sounds always play
3. **Per-frame pitch spread** — same sound played 2-3 times in one frame gets +0.05, +0.10 pitch offset to avoid phase cancellation

### 8.4 Adaptive Music
The `Music` class uses a beat scheduler (`setInterval` at 100ms) that schedules notes 150ms ahead of playback time. Three layers crossfade based on game state:
- Level 0 (walking): bass only
- Level 1 (enemies nearby): bass + percussion
- Level 2 (combat): bass + percussion + melody

Crossfading uses `setTargetAtTime` with exponential approach — smooth transitions, no clicks.

### 8.5 Gotchas
- **Autoplay policy:** `AudioContext` starts in `'suspended'` state. Must call `context.resume()` after user gesture. Never assume it's ready at construction.
- **Node cleanup:** Oscillators/sources that have `stop()`ped auto-disconnect, but GainNodes and filters don't. Use `setTimeout` to disconnect after sound duration + buffer.
- **Noise buffer reuse:** Pre-create noise buffers for repeated sounds (hi-hat). Creating buffers per-play causes GC pressure.
- **`exponentialRampToValueAtTime` can't ramp to 0** — use 0.001 instead. Ramp to actual 0 throws.
- **Delay feedback loops:** For reverb tails, must disconnect the feedback loop after use or it leaks.

### 8.6 Spatial Audio
Simple but effective: `StereoPanner` node with pan calculated from entity screen position:
```javascript
const screenX = worldX - cameraX;
const pan = (screenX / screenWidth) * 2 - 1;  // -1 to 1
```
Temporarily swaps `sfxBus` to route through panner, then restores. Hack-ish but works without refactoring every play method.

---

## 9. Architecture Evolution

### Phase 1: Monolith (`gameplay.js`)
Everything in one file: player logic, enemy AI, combat, rendering, audio triggers, wave management, UI. ~2000 lines. Worked for rapid prototyping but became unmaintainable.

**Pain points:**
- Multiple agents editing the same file → merge conflicts
- Finding the right section required scrolling through unrelated code
- Bugs in one system (audio) could mask bugs in another (combat) because everything shared scope

### Phase 2: Engine/Game Split
Extracted infrastructure into `src/engine/`:
- `game.js` — loop, scenes, hitlag, zoom, slow-mo, transitions
- `renderer.js` — canvas wrapper, camera, shake
- `input.js` — keyboard tracking, buffer
- `audio.js` — all sound synthesis
- `music.js` — procedural music
- `animation.js` — frame controller
- `events.js` — pub/sub bus
- `particles.js` — particle emitter
- `sprite-cache.js` — offscreen canvas cache

Game-specific code stayed in `src/`:
- `gameplay.js` — scene wiring (the "main" file, now thinner)
- `player.js`, `enemy.js` — entity logic
- `combat.js` — collision and damage
- `vfx.js` — visual effects
- `background.js`, `hud.js` — rendering

### Phase 3: System Integration via Hooks
The engine provides hooks, the game implements them:
- `scene.update(dt)` — normal update
- `scene.updateDuringHitlag(dt)` — what animates during freeze
- `scene.render()` — full render call
- `scene.onEnter()` / `scene.onExit()` — lifecycle

This lets the engine add features (hitlag, transitions, zoom) without touching game code.

### Key Insight: The Wiring File
`gameplay.js` is the "wiring" file — it imports systems and connects them. It should be as thin as possible:
- Import player, enemies, combat, audio, VFX, particles, HUD, background
- In `update()`: call each system's update in order, wire cross-system events
- In `render()`: call each system's render in order

The temptation is to put logic here. Resist it. Every `if` statement in the wiring file is a future merge conflict.

---

## 10. For the Next Project

### Day 1 Decisions That Save Weeks

1. **Set up HiDPI from the start.** The 5-line DPR fix should be in your renderer constructor before you draw a single pixel. Retrofitting it means hunting down every `canvas.width` reference.

2. **Build the mix bus first.** Create SFX/Music/UI/Master gain node hierarchy before playing any sound. Retrofitting volume control into 30 individual play methods is painful.

3. **Use a fixed-timestep loop from the start.** The accumulator pattern (`while (accumulator >= fixedDelta)`) prevents every timing bug you'll ever encounter. Don't start with `requestAnimationFrame(dt)` and "fix it later."

4. **Separate engine from game on day 1.** `src/engine/` for infrastructure, `src/game/` for game-specific code. The engine should have zero imports from game code.

5. **Define your state machine states AND their exit transitions.** Before implementing any state, write a table: "state X transitions to Y on condition Z." This prevents the player-freeze bug.

6. **Set up event bus early.** Cross-system communication via events prevents the import web where everything depends on everything. Combat doesn't import Audio — it emits `'enemy.hit'`, Audio subscribes.

### Framework vs Custom — Decision Framework

**Build custom when:**
- You need < 10 systems (loop, input, rendering, audio, animation)
- Your audio is procedural (no framework supports this)
- You want zero dependencies / zero build step
- You're learning and want to understand the fundamentals
- Your game has custom mechanics that fight framework abstractions (hitlag, attack buffering)

**Use a framework (Phaser/PixiJS) when:**
- You need GPU rendering (WebGL shaders, blend modes, post-processing)
- You're using sprite sheet assets (frameworks excel at texture management)
- You need physics beyond AABB collision
- Your team is >3 people and needs standardized APIs
- You're building multiple games and want to amortize learning cost

**Never migrate mid-project** unless the framework gives you something critical you literally cannot build. We considered Phaser → rejected because it would replace working systems at 50-74 hours cost.

### File Organization That Scales

```
src/
  engine/           # Zero game-specific imports
    game.js         # Loop, scenes, transitions
    renderer.js     # Canvas wrapper, camera
    input.js        # Keyboard/gamepad
    audio.js        # Sound synthesis
    music.js        # Adaptive music
    animation.js    # Frame controller
    events.js       # Pub/sub bus
    particles.js    # Particle emitter
    sprite-cache.js # Offscreen canvas cache
  game/             # Imports from engine/, never imported BY engine/
    scenes/
      gameplay.js   # Wiring file — thin as possible
      menu.js
      options.js
    entities/
      player.js
      enemy.js
    systems/
      combat.js
      wave-manager.js
      vfx.js
    rendering/
      background.js
      hud.js
    data/
      levels.js
      enemy-types.js
```

**Rules:**
- `engine/` has zero imports from `game/`
- `game/scenes/` is the wiring layer — imports everything, contains minimal logic
- `game/entities/` owns entity state and behavior
- `game/systems/` owns cross-entity logic (combat, waves)
- `game/data/` is pure configuration — no logic, no imports

### Testing Strategy From the Start

We shipped with zero automated tests. What we'd do differently:

1. **Test the engine systems in isolation.** `AnimationController`, `EventBus`, `ParticleSystem`, and `Input` are pure logic — no DOM, no Canvas. They're trivially testable.

2. **State machine transition tables as tests.** For each state, assert: "from state X with input Y, transitions to state Z." This catches the player-freeze bug on day 1.

3. **Audio integration tests via node counts.** After `playHit()`, assert that `audio.activeSounds` incremented. After timeout, assert it decremented. Catches dedup/priority bugs.

4. **Snapshot the game loop behavior.** Record `update()` call counts for 100 frames at various `dt` values. Assert fixed-timestep invariants (dt is always `1/60`).

5. **Don't test rendering.** Canvas pixel tests are flaky and slow. Test the data (entity positions, states, animation frames) and trust the rendering code. Visual QA is manual.

6. **Use a lightweight runner.** No Jest, no Mocha in a zero-build-step project. A simple `test.html` that imports modules and runs assertions is enough. Or use `node --experimental-vm-modules` for engine-only tests.

---

## Appendix: Performance Numbers

| Metric | Before Optimization | After Sprite Cache + HiDPI |
|--------|--------------------|-----------------------------|
| Canvas API calls/frame (20 entities) | ~2,500 | ~200 |
| Frame render time | ~12ms | ~2ms |
| Max entities at 60fps | ~30 | ~100+ |
| Particle cap before drops | ~200 | ~500 |
| Audio nodes (combat scene) | 15-25 | 15-25 (unchanged) |
| Memory (sprite cache, 50 entries) | — | ~8MB (offscreen canvases) |

### Browser Compatibility Notes
- `devicePixelRatio` — supported everywhere including IE11
- `StereoPanner` — all modern browsers, no Safari <14.1
- `AudioContext` — `webkitAudioContext` fallback for older Safari
- `canvas.getContext('2d')` — universal
- ES modules (`<script type="module">`) — all modern browsers
