# SKILL: Web Game Engine (Canvas 2D + Web Audio)

Build a browser-based 2D game engine from scratch using HTML5 Canvas and Web Audio API. Zero dependencies, zero build tools, ES modules only.

---

## When to Use This Skill
- Building a 2D browser game without a framework
- Targeting `<script type="module">` with no bundler
- Need procedural audio (no audio file assets)
- Game requires custom mechanics that fight framework abstractions (hitlag, attack buffering, adaptive music)
- Team wants full control over every system

## When NOT to Use This Skill
- You have sprite sheet assets → use Phaser or PixiJS
- You need GPU shader effects (bloom, distortion) → use PixiJS
- You need physics beyond AABB → use a framework with physics
- Team is >5 people → standardized framework APIs reduce coordination cost

---

## Core Architecture

### File Structure
```
src/
  engine/           # Infrastructure — zero game imports
    game.js         # Fixed-timestep loop, scene management, transitions
    renderer.js     # HiDPI Canvas 2D wrapper, camera, shake, zoom
    input.js        # Keyboard tracking (pressed/held/released) + input buffering
    audio.js        # Procedural SFX synthesis, mix bus, spatial audio
    music.js        # Adaptive procedural music, beat scheduler
    animation.js    # Data-only frame controller, frame events
    events.js       # Pub/sub event bus
    particles.js    # Config-driven particle emitter
    sprite-cache.js # DPR-aware offscreen canvas cache
  game/             # Game-specific — imports from engine/
    scenes/         # Wiring files (thin — connect systems, minimal logic)
    entities/       # Player, enemies, AI
    systems/        # Combat, waves, VFX
    rendering/      # Background, HUD
    data/           # Level configs, entity types (pure data)
```

**Rule:** `engine/` never imports from `game/`. The engine provides hooks, the game implements them.

---

## System-by-System Guide

### 1. Game Loop (game.js)
Fixed-timestep accumulator pattern. Non-negotiable — use this from frame 1.

```javascript
export class Game {
    constructor(canvas) {
        this.fixedDelta = 1 / 60;
        this.accumulator = 0;
        this.lastTime = 0;
    }
    
    loop = () => {
        const now = performance.now();
        let frameTime = (now - this.lastTime) / 1000;
        this.lastTime = now;
        if (frameTime > 0.25) frameTime = 0.25; // prevent death spiral
        
        this.accumulator += frameTime;
        while (this.accumulator >= this.fixedDelta) {
            this.currentScene?.update(this.fixedDelta);
            this.accumulator -= this.fixedDelta;
        }
        this.currentScene?.render();
        requestAnimationFrame(this.loop);
    };
}
```

**Key decisions:**
- Cap `frameTime` at 0.25s to prevent spiral of death after tab switch
- Scene gets `fixedDelta` (constant), never raw `frameTime` (variable)
- Render outside the fixed-step loop — runs once per frame at display refresh rate
- Use arrow function for `loop` to preserve `this` binding

**Advanced features to add incrementally:**
- Hitlag: frame counter checked before scene update, decrements per tick
- Slow-mo: `timeScale` multiplier on `fixedDelta` before passing to scene
- Screen zoom: lerp `zoomLevel` back to 1.0 using real dt (unaffected by slow-mo)
- Scene transitions: two-phase state machine (fade-out → switch → fade-in)

### 2. Renderer (renderer.js)
HiDPI-aware Canvas 2D wrapper. Set up DPR scaling FIRST, before drawing anything.

```javascript
export class Renderer {
    constructor(canvas) {
        this.ctx = canvas.getContext('2d');
        const dpr = window.devicePixelRatio || 1;
        this.dpr = dpr;
        this.width = 1280;   // logical — all game code uses this
        this.height = 720;
        canvas.width = this.width * dpr;
        canvas.height = this.height * dpr;
        canvas.style.width = this.width + 'px';
        canvas.style.height = this.height + 'px';
        this.ctx.scale(dpr, dpr);
        
        // For code that only has ctx reference
        canvas.logicalWidth = this.width;
        canvas.logicalHeight = this.height;
    }
}
```

**Critical:** After DPR scaling, `canvas.width` ≠ logical width. Any code using `ctx.canvas.width` for positioning will break. Use `canvas.logicalWidth || canvas.width` everywhere.

**Camera:** `save()` applies translate + shake + zoom, `restore()` reverts. All world-space rendering happens between save/restore. HUD renders after restore (screen-space).

### 3. Input (input.js)
Track three states per key: held (current frame), pressed (this frame only), released (this frame only).

```javascript
export class Input {
    constructor() {
        this.keys = {};           // currently held
        this.keysPressed = {};    // just pressed this frame
        this.keysReleased = {};   // just released this frame
        window.addEventListener('keydown', e => {
            if (!this.keys[e.code]) this.keysPressed[e.code] = true;
            this.keys[e.code] = true;
        });
        window.addEventListener('keyup', e => {
            this.keys[e.code] = false;
            this.keysReleased[e.code] = true;
        });
    }
    clearFrameState() { this.keysPressed = {}; this.keysReleased = {}; }
}
```

**Input buffering** for fighting games: capture attack inputs in keydown handler, store with 0.15s expiry timer. `consumeBuffer()` returns and clears the buffered action. Clear buffer on hit state entry to prevent stale inputs.

### 4. Audio (audio.js)
Build the mix bus FIRST. All sounds route through bus hierarchy.

```javascript
export class Audio {
    constructor() {
        this.context = new (window.AudioContext || window.webkitAudioContext)();
        this.masterBus = this.context.createGain();
        this.sfxBus = this.context.createGain();
        this.musicBus = this.context.createGain();
        this.uiBus = this.context.createGain();
        
        this.sfxBus.connect(this.masterBus);
        this.musicBus.connect(this.masterBus);
        this.uiBus.connect(this.masterBus);
        this.masterBus.connect(this.context.destination);
    }
    resume() {
        if (this.context.state === 'suspended') this.context.resume();
    }
}
```

**Procedural SFX patterns:**
- Hit sounds: sine oscillator (bass body) + noise buffer through bandpass (crack) + high sine (sparkle)
- Vocal sounds: noise buffer → bandpass filter → sweep filter frequency (formant synthesis)
- Percussion: sine pitch drop (kick), noise through highpass (hi-hat)
- Always ramp to 0.001, never 0 (exponentialRamp throws on 0)
- Pre-create reusable noise buffers for repeated sounds

**Sound priority:** Track active sounds per type, cap at MAX_SAME_TYPE (3). Per-frame pitch spread (+0.05 per duplicate) prevents phase cancellation.

### 5. Animation (animation.js)
Data-only controller. Never renders. Returns current frame data.

```javascript
export class AnimationController {
    constructor(animations) { /* { idle: { frames, frameDuration, loop } } */ }
    play(name) { /* no-op if same animation already playing */ }
    update(dt) { /* while loop handles lag spikes spanning multiple frames */ }
    getCurrentFrame() { return this.currentAnim.frames[this.frameIndex]; }
    onFrameEvent(callback) { /* fires on every frame change */ }
}
```

Frames can be any type (number, object, function) — the renderer decides interpretation. This decoupling is the system's greatest strength.

### 6. Events (events.js)
Minimal pub/sub. ~50 lines. Iterate over a shallow copy in `emit()` so handlers can safely unsubscribe mid-iteration.

### 7. Particles (particles.js)
Config-driven emitter. `emit(x, y, config)` where config has `count`, `speed`, `spread`, `lifetime`, `size`, `color[]`, `gravity`, `fadeOut`, `shrink`. Export preset configs as constants.

### 8. Sprite Cache (sprite-cache.js)
DPR-aware offscreen canvas factory. `getOrCreate(key, w, h, drawFn)` creates at `w*dpr × h*dpr`, scales context, runs drawFn once, caches. Reduces per-entity render cost from ~100 calls to 1 `drawImage`.

**Key pattern:** `const key = \`${type}_${state}_${facing}_${frame}\``

---

## Critical Patterns

### State Machine Exit Transitions
Every state MUST have at least one exit transition. Before implementing a state, write:
```
State: 'hit'
  Entry: when entity takes damage
  Exit: when hitstunTime <= 0 → 'idle'
```
Missing exit transitions cause permanent entity freeze.

### Dual-Update for Visual Systems
When the game loop has multiple modes (normal, hitlag, pause), visual-only systems (VFX, particles, screen shake) must update in ALL modes where they should animate. Create a matrix:

| System | Normal | Hitlag | Pause | Transition |
|--------|--------|--------|-------|------------|
| Game logic | ✅ | ❌ | ❌ | ❌ |
| VFX | ✅ | ✅ | ❌ | ❌ |
| Particles | ✅ | ✅ | ❌ | ❌ |
| Screen shake | ✅ | ✅ | ❌ | ❌ |
| Audio | ✅ | ✅ | ❌ | ❌ |

### HiDPI Propagation
After DPR scaling, audit every use of `canvas.width`/`canvas.height`. Replace with `canvas.logicalWidth`/`canvas.logicalHeight`. Test on a 2× display (or Chrome DevTools device emulation).

### AudioContext Lifecycle
```javascript
// Construction: wrap in try/catch
try { this.music = new Music(audio.context, audio.musicBus); } catch(e) { this.music = null; }
// Usage: always null-check
this.music?.setIntensity(2);
// Cleanup: wrap in try/catch (context may already be closed)
try { this.music?.stop(); } catch(e) {}
```

---

## Performance Targets

| Metric | Budget |
|--------|--------|
| Frame time | < 16ms (60fps) |
| Canvas API calls/frame | < 300 (with sprite cache) |
| Active audio nodes | < 30 |
| Particles | < 500 |
| Sprite cache entries | < 100 (watch memory) |

---

## Common Mistakes

1. **No DPR handling** — everything looks blurry on Retina. Fix on day 1.
2. **Variable timestep** — game runs at different speeds on different hardware. Use fixed timestep.
3. **AudioContext at construction** — browser blocks it. Resume after user gesture.
4. **Ramp to 0** — `exponentialRampToValueAtTime(0)` throws. Use 0.001.
5. **State with no exit** — entity freezes permanently. Always define exit conditions.
6. **Monolith scene file** — becomes merge conflict magnet. Keep wiring files thin.
7. **Optimizing before profiling** — sprite caching added value, particle pooling didn't (yet). Measure first.
8. **`canvas.width` after DPR** — returns physical pixels, not logical. Use custom properties.
