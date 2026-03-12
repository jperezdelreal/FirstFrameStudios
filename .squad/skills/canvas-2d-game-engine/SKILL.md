---
name: "canvas-2d-game-engine"
description: "Patterns for building HTML5 Canvas 2D games from scratch — fixed timestep loop, rendering, input, collision, state machines, and audio"
domain: "game-engine"
confidence: "low"
source: "manual — first capture of Canvas 2D game engine patterns for web-native development"
has_reference: true
---

## Context

Build 2D browser games directly on the HTML5 Canvas API (`CanvasRenderingContext2D`) without frameworks. Covers platformers, top-down RPGs, beat-em-ups, and puzzle games using ES modules and modern browsers. Does NOT apply to PixiJS, Phaser, or other framework-wrapped engines — see `vite-typescript-pixijs` for those.

## Core Patterns

### Game Loop — Fixed Timestep (60fps)

Accumulator pattern decouples physics from display refresh. Physics always steps at `FIXED_DT = 1/60` regardless of monitor Hz. Cap `frameTime` at 0.25s to prevent spiral of death after background tabs.

```javascript
const FIXED_DT = 1 / 60;
let accumulator = 0, lastTime = 0;

function loop(timestamp) {
    let frameTime = Math.min((timestamp - lastTime) / 1000, 0.25);
    lastTime = timestamp;
    accumulator += frameTime;
    while (accumulator >= FIXED_DT) { update(FIXED_DT); accumulator -= FIXED_DT; }
    render();
    requestAnimationFrame(loop);
}
requestAnimationFrame((ts) => { lastTime = ts; requestAnimationFrame(loop); });
```

### Rendering — HiDPI + Sprites

Always set up DPR scaling first. After scaling, `canvas.width` returns physical pixels — store and use logical dimensions for all game math. Set `ctx.imageSmoothingEnabled = false` for pixel art (re-set after every resize).

```javascript
function setupCanvas(canvas, w, h) {
    const dpr = window.devicePixelRatio || 1;
    canvas.width = w * dpr; canvas.height = h * dpr;
    canvas.style.width = w + 'px'; canvas.style.height = h + 'px';
    const ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
    ctx.imageSmoothingEnabled = false;
    return ctx;
}
```

Only render tiles visible in the camera viewport. Use offscreen canvas caching for procedural graphics.

### Input — Keyboard, Touch, Gamepad

Track three states per key: **held**, **pressed** (this frame), **released** (this frame). Call `endFrame()` at END of game loop to clear per-frame flags.

- **Touch**: convert to logical coordinates, use `{ passive: false }` + `preventDefault()` to suppress scroll/zoom
- **Gamepad**: poll every frame (no events), apply deadzone (0.15) to avoid stick drift

### Collision Detection

- **AABB**: `a.x < b.x+b.w && a.x+a.w > b.x && a.y < b.y+b.h && a.y+a.h > b.y`
- **Circle**: compare squared distances — never `Math.sqrt()` in hot loops
- **>50 entities**: use spatial grid partitioning to reduce O(n²) checks

### State Machine

States implement `enter()`, `exit()`, `update(dt)`, `render(ctx)`. Transitions always go through `switchState()` — never assign `currentState` directly. `exit()` must clean up everything `enter()` set up.

### Audio

Defer `AudioContext` creation until first user gesture. Build gain bus hierarchy: master → sfx/music → individual sounds. Use `exponentialRampToValueAtTime(0.001, ...)` (never ramp to 0). Cap concurrent sounds per type (3–4 max).

## Key Examples

### Minimal Game Skeleton

```javascript
import { Input } from './input.js';
const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');
const input = new Input();
const FIXED_DT = 1 / 60;
let accumulator = 0, lastTime = 0;

function loop(timestamp) {
    let frameTime = Math.min((timestamp - lastTime) / 1000, 0.25);
    lastTime = timestamp;
    accumulator += frameTime;
    while (accumulator >= FIXED_DT) { update(FIXED_DT); accumulator -= FIXED_DT; }
    render();
    input.endFrame();
    requestAnimationFrame(loop);
}
function update(dt) { /* game logic */ }
function render() { ctx.clearRect(0, 0, canvas.width, canvas.height); /* draw */ }
requestAnimationFrame((ts) => { lastTime = ts; requestAnimationFrame(loop); });
```

## Anti-Patterns

1. **Variable timestep** — passing raw `frameTime` to physics breaks on different Hz monitors
2. **AudioContext at page load** — browsers block it; create on first user gesture
3. **Forgetting DPR scaling** — blurry on Retina; always set up before drawing
4. **Using `canvas.width` for game math after DPR** — returns physical pixels, not logical
5. **`Math.sqrt()` in collision loops** — compare squared distances instead
6. **No frame cap** — background tabs produce hundreds of physics steps; cap at 0.25s
7. **Direct state assignment** — bypasses `exit()` cleanup; use `switchState()`
8. **Forgetting `endFrame()`** — `wasPressed()` stays true forever
9. **Touch without `preventDefault()`** — page scrolls/zooms during gameplay