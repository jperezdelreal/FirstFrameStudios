---
has_reference: true
---

# SKILL: Web Game Engine (Canvas 2D + Web Audio)

Build a browser-based 2D game engine from scratch using HTML5 Canvas and Web Audio API. Zero dependencies, zero build tools, ES modules only.

## Context

This skill guides building a zero-dependency 2D browser game engine using HTML5 Canvas and Web Audio API with ES modules only. Use when you need full control over custom mechanics (hitlag, attack buffering, adaptive music) without framework abstractions. Not suitable when you need GPU shaders, complex physics, or have sprite sheet assets — use Phaser/PixiJS instead.

## Core Patterns

### Architecture: engine/ vs game/

```
src/
  engine/           # Infrastructure — zero game imports
    game.js         # Fixed-timestep loop, scene management
    renderer.js     # HiDPI Canvas 2D wrapper, camera, shake
    input.js        # Keyboard tracking + input buffering
    audio.js        # Procedural SFX synthesis, mix bus
    music.js        # Adaptive procedural music
    animation.js    # Data-only frame controller
    events.js       # Pub/sub event bus
    particles.js    # Config-driven emitter
    sprite-cache.js # DPR-aware canvas cache
  game/             # Game-specific — imports from engine/
    scenes/         # Thin wiring files
    entities/       # Player, enemies, AI
    systems/        # Combat, waves, VFX
    rendering/      # Background, HUD
    data/           # Level configs (pure data)
```

**Rule:** `engine/` never imports from `game/`.

### Game Loop — Fixed Timestep (Non-Negotiable)

- Cap `frameTime` at 0.25s to prevent spiral of death after tab switch
- Scene gets `fixedDelta` (constant), never raw `frameTime`
- Render outside fixed-step loop — once per frame at display refresh rate
- Arrow function for `loop` preserves `this` binding
- Hitlag: frame counter checked before scene update, decrements per tick
- Slow-mo: `timeScale` multiplier on `fixedDelta`

### Renderer — HiDPI-Aware

- Set DPR scaling FIRST: `canvas.width = logicalWidth * dpr`, then `ctx.scale(dpr, dpr)`
- After scaling, `canvas.width` != logical width — store `canvas.logicalWidth` and use everywhere
- Camera: `save()` applies translate + shake + zoom, `restore()` reverts. World-space between save/restore, HUD after restore

### Input — Three-State Tracking

Track held, pressed (this frame), released (this frame) per key. Call `clearFrameState()` each frame. For fighting games: buffer inputs with 0.15s expiry, `consumeBuffer()` returns and clears.

### Audio — Mix Bus Architecture

Route all sounds: sfxBus/musicBus/uiBus -> masterBus -> destination. Always `exponentialRampToValueAtTime(0.001)`, never 0. Pre-create reusable noise buffers. Cap same-type sounds at 3 with +0.05 pitch spread.

### Animation — Data-Only Controller

Never renders — returns current frame data. Frames can be any type (number, object, function); renderer decides interpretation. Use `while` loop in update to handle lag spikes spanning multiple frames.

### State Machine Exits

Every state MUST define exit transitions. Missing exits cause permanent entity freeze. Document entry/exit conditions before implementing.

### Dual-Update Matrix

Visual systems (VFX, particles, shake, audio) must update during hitlag. Game logic does not. Create explicit matrix per game mode.

### Sprite Cache

DPR-aware offscreen canvas: `getOrCreate(key, w, h, drawFn)`. Key: `${type}_${state}_${facing}_${frame}`. Reduces per-entity render from ~100 calls to 1 `drawImage`.

## Key Examples

### Fixed-Timestep Loop

```javascript
loop = () => {
    const now = performance.now();
    let frameTime = (now - this.lastTime) / 1000;
    this.lastTime = now;
    if (frameTime > 0.25) frameTime = 0.25;
    this.accumulator += frameTime;
    while (this.accumulator >= this.fixedDelta) {
        this.currentScene?.update(this.fixedDelta);
        this.accumulator -= this.fixedDelta;
    }
    this.currentScene?.render();
    requestAnimationFrame(this.loop);
};
```

### AudioContext Lifecycle

```javascript
// Construction: wrap in try/catch
try { this.music = new Music(audio.context, audio.musicBus); } catch(e) { this.music = null; }
// Usage: always null-check
this.music?.setIntensity(2);
// Cleanup: context may already be closed
try { this.music?.stop(); } catch(e) {}
```

## Anti-Patterns

1. **No DPR handling** — blurry on Retina. Fix on day 1.
2. **Variable timestep** — different speeds on different hardware. Use fixed timestep.
3. **AudioContext at construction** — browser blocks it. Resume after user gesture.
4. **`exponentialRampToValueAtTime(0)`** — throws. Use 0.001.
5. **State with no exit** — entity freezes permanently.
6. **Monolith scene file** — merge conflict magnet. Keep wiring files thin.
7. **`canvas.width` after DPR** — returns physical pixels. Use `canvas.logicalWidth`.
8. **Optimizing before profiling** — measure first.

## Performance Budgets

| Metric | Budget |
|--------|--------|
| Frame time | < 16ms (60fps) |
| Canvas calls/frame | < 300 |
| Active audio nodes | < 30 |
| Particles | < 500 |
