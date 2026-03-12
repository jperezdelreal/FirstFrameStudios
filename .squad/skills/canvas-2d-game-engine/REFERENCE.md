---
name: "canvas-2d-game-engine"
description: "Patterns for building HTML5 Canvas 2D games from scratch — fixed timestep loop, rendering, input, collision, state machines, and audio"
domain: "game-engine"
confidence: "low"
source: "manual — first capture of Canvas 2D game engine patterns for web-native development"
---

## Context

Use this skill when building a 2D browser game directly on the HTML5 Canvas API without a framework. These patterns apply to any game that renders with `CanvasRenderingContext2D` — platformers, top-down RPGs, beat-em-ups, puzzle games. The skill assumes ES modules and modern browsers (no IE11).

This does NOT apply when using PixiJS, Phaser, or other frameworks that wrap Canvas/WebGL — those have their own idioms. See `vite-typescript-pixijs` for PixiJS patterns.

## Patterns

### 1. Fixed Timestep Game Loop (60fps)

The accumulator pattern decouples physics from display refresh rate. Physics always steps at 1/60s regardless of monitor Hz.

```javascript
const FIXED_DT = 1 / 60;
const MAX_FRAME_TIME = 0.25; // prevent spiral of death after tab switch

let accumulator = 0;
let lastTime = 0;

function loop(timestamp) {
    let frameTime = (timestamp - lastTime) / 1000;
    lastTime = timestamp;
    if (frameTime > MAX_FRAME_TIME) frameTime = MAX_FRAME_TIME;

    accumulator += frameTime;
    while (accumulator >= FIXED_DT) {
        update(FIXED_DT); // physics, AI, input — always same dt
        accumulator -= FIXED_DT;
    }

    render(); // runs once per display frame, outside the fixed loop
    requestAnimationFrame(loop);
}

requestAnimationFrame((ts) => { lastTime = ts; requestAnimationFrame(loop); });
```

**Key rules:**
- Cap `frameTime` at 0.25s — returning from a background tab can produce multi-second deltas
- `update()` always receives the constant `FIXED_DT`, never raw frame time
- `render()` runs once per display frame, outside the accumulator loop
- Use arrow function or `.bind()` to preserve `this` when wrapping in a class

### 2. Canvas Rendering Patterns

#### HiDPI Setup (do this FIRST)

```javascript
function setupCanvas(canvas, logicalWidth, logicalHeight) {
    const dpr = window.devicePixelRatio || 1;
    canvas.width = logicalWidth * dpr;
    canvas.height = logicalHeight * dpr;
    canvas.style.width = logicalWidth + 'px';
    canvas.style.height = logicalHeight + 'px';
    const ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
    ctx.imageSmoothingEnabled = false; // pixel art
    return ctx;
}
```

After DPR scaling, `canvas.width` returns physical pixels. Store logical dimensions separately and use those for all game math.

#### Sprites

```javascript
// Draw a sprite from a spritesheet
ctx.drawImage(
    spritesheet,
    frameX * frameW, frameY * frameH, frameW, frameH, // source rect
    entity.x, entity.y, frameW, frameH                 // dest rect
);
```

For pixel art, set `ctx.imageSmoothingEnabled = false` after every canvas resize.

#### Tilemaps

```javascript
function renderTilemap(ctx, map, tileset, tileSize) {
    // Only draw tiles visible in the camera viewport
    const startCol = Math.floor(camera.x / tileSize);
    const endCol = Math.ceil((camera.x + viewportW) / tileSize);
    const startRow = Math.floor(camera.y / tileSize);
    const endRow = Math.ceil((camera.y + viewportH) / tileSize);

    for (let row = startRow; row < endRow; row++) {
        for (let col = startCol; col < endCol; col++) {
            const tileId = map[row]?.[col];
            if (tileId == null) continue;
            const sx = (tileId % tilesPerRow) * tileSize;
            const sy = Math.floor(tileId / tilesPerRow) * tileSize;
            ctx.drawImage(tileset, sx, sy, tileSize, tileSize,
                col * tileSize - camera.x, row * tileSize - camera.y,
                tileSize, tileSize);
        }
    }
}
```

#### Particles

Config-driven emitter. Spawn particles with randomized properties from a config object.

```javascript
function emitParticles(particles, x, y, config) {
    for (let i = 0; i < config.count; i++) {
        const angle = config.angle + (Math.random() - 0.5) * config.spread;
        const speed = config.speed * (0.5 + Math.random() * 0.5);
        particles.push({
            x, y,
            vx: Math.cos(angle) * speed,
            vy: Math.sin(angle) * speed,
            life: config.lifetime,
            maxLife: config.lifetime,
            size: config.size,
            color: config.colors[Math.floor(Math.random() * config.colors.length)],
            gravity: config.gravity || 0,
        });
    }
}

function updateParticles(particles, dt) {
    for (let i = particles.length - 1; i >= 0; i--) {
        const p = particles[i];
        p.vy += p.gravity * dt;
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.life -= dt;
        if (p.life <= 0) particles.splice(i, 1);
    }
}
```

### 3. Input Handling

Track three states per key: **held** (down right now), **pressed** (just went down this frame), **released** (just went up this frame).

```javascript
class Input {
    constructor() {
        this.keys = {};
        this.justPressed = {};
        this.justReleased = {};

        window.addEventListener('keydown', (e) => {
            if (!this.keys[e.code]) this.justPressed[e.code] = true;
            this.keys[e.code] = true;
        });
        window.addEventListener('keyup', (e) => {
            this.keys[e.code] = false;
            this.justReleased[e.code] = true;
        });
    }

    isHeld(code) { return !!this.keys[code]; }
    wasPressed(code) { return !!this.justPressed[code]; }
    wasReleased(code) { return !!this.justReleased[code]; }
    endFrame() { this.justPressed = {}; this.justReleased = {}; }
}
```

Call `endFrame()` at the END of the game loop, after update and render.

#### Touch Input

```javascript
canvas.addEventListener('touchstart', (e) => {
    e.preventDefault();
    for (const touch of e.changedTouches) {
        const rect = canvas.getBoundingClientRect();
        const x = (touch.clientX - rect.left) * (logicalWidth / rect.width);
        const y = (touch.clientY - rect.top) * (logicalHeight / rect.height);
        handleTouchStart(touch.identifier, x, y);
    }
}, { passive: false });
```

Always convert touch coordinates to logical canvas coordinates. Use `passive: false` and `preventDefault()` to suppress scroll/zoom.

#### Gamepad

```javascript
function pollGamepad() {
    const gp = navigator.getGamepads()[0];
    if (!gp) return null;
    return {
        leftStickX: applyDeadzone(gp.axes[0], 0.15),
        leftStickY: applyDeadzone(gp.axes[1], 0.15),
        a: gp.buttons[0].pressed,
        b: gp.buttons[1].pressed,
    };
}
function applyDeadzone(value, threshold) {
    return Math.abs(value) < threshold ? 0 : value;
}
```

Poll gamepad every frame — there are no gamepad events. Apply a deadzone (0.15) to avoid stick drift.

### 4. Collision Detection

#### AABB (Axis-Aligned Bounding Box)

```javascript
function aabbOverlap(a, b) {
    return a.x < b.x + b.w &&
           a.x + a.w > b.x &&
           a.y < b.y + b.h &&
           a.y + a.h > b.y;
}
```

#### Circle Collision

```javascript
function circleOverlap(a, b) {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    const distSq = dx * dx + dy * dy;
    const radiusSum = a.radius + b.radius;
    return distSq < radiusSum * radiusSum;
}
```

Compare squared distances — avoid `Math.sqrt()` in hot loops.

#### Spatial Partitioning

For >50 collidable entities, use a grid to reduce O(n²) checks:

```javascript
function buildGrid(entities, cellSize) {
    const grid = {};
    for (const e of entities) {
        const key = `${Math.floor(e.x / cellSize)},${Math.floor(e.y / cellSize)}`;
        (grid[key] ??= []).push(e);
    }
    return grid;
}
```

### 5. Game State Machine

```javascript
class Game {
    constructor() {
        this.states = { menu: new MenuState(), play: new PlayState(),
                        pause: new PauseState(), gameover: new GameOverState() };
        this.currentState = null;
    }

    switchState(name, params) {
        this.currentState?.exit();
        this.currentState = this.states[name];
        this.currentState.enter(params);
    }

    update(dt) { this.currentState?.update(dt); }
    render(ctx) { this.currentState?.render(ctx); }
}

// Each state implements: enter(), exit(), update(dt), render(ctx)
class PlayState {
    enter() { /* init level, reset entities */ }
    exit() { /* cleanup listeners */ }
    update(dt) { /* game logic */ }
    render(ctx) { /* draw world */ }
}
```

**Rules:**
- `exit()` must clean up everything `enter()` set up (listeners, timers, audio)
- State transitions go through `switchState()` — never set `currentState` directly
- Pause state can store a reference to PlayState to render it as a background

### 6. Audio via Web Audio API

```javascript
class AudioManager {
    constructor() {
        this.ctx = null; // defer creation until user gesture
    }

    init() {
        if (this.ctx) return;
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        this.masterGain = this.ctx.createGain();
        this.sfxGain = this.ctx.createGain();
        this.musicGain = this.ctx.createGain();
        this.sfxGain.connect(this.masterGain);
        this.musicGain.connect(this.masterGain);
        this.masterGain.connect(this.ctx.destination);
    }

    resume() {
        if (this.ctx?.state === 'suspended') this.ctx.resume();
    }

    playSfx(buffer, volume = 1, pitch = 1) {
        if (!this.ctx) return;
        const source = this.ctx.createBufferSource();
        source.buffer = buffer;
        source.playbackRate.value = pitch;
        const gain = this.ctx.createGain();
        gain.gain.value = volume;
        source.connect(gain).connect(this.sfxGain);
        source.start();
    }
}
```

**Critical rules:**
- Defer `AudioContext` creation until the first user gesture (click/keydown) — browsers block autoplay
- Always use `exponentialRampToValueAtTime(0.001, ...)` — ramping to 0 throws an error
- Build a gain bus hierarchy: master → sfx/music/ui → individual sounds
- Cap concurrent sounds per type (max 3–4) to prevent audio blowout

## Examples

### Minimal Game Skeleton

```javascript
// main.js
import { Input } from './input.js';

const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');
const input = new Input();

const FIXED_DT = 1 / 60;
let accumulator = 0;
let lastTime = 0;

function loop(timestamp) {
    let frameTime = (timestamp - lastTime) / 1000;
    lastTime = timestamp;
    if (frameTime > 0.25) frameTime = 0.25;

    accumulator += frameTime;
    while (accumulator >= FIXED_DT) {
        update(FIXED_DT);
        accumulator -= FIXED_DT;
    }
    render();
    input.endFrame();
    requestAnimationFrame(loop);
}

function update(dt) {
    // game logic here
}

function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    // draw here
}

requestAnimationFrame((ts) => { lastTime = ts; requestAnimationFrame(loop); });
```

### Sprite Cache for Procedural Graphics

```javascript
const cache = new Map();

function getCachedSprite(key, w, h, drawFn) {
    if (cache.has(key)) return cache.get(key);
    const dpr = window.devicePixelRatio || 1;
    const offscreen = document.createElement('canvas');
    offscreen.width = w * dpr;
    offscreen.height = h * dpr;
    const octx = offscreen.getContext('2d');
    octx.scale(dpr, dpr);
    drawFn(octx, w, h);
    cache.set(key, offscreen);
    return offscreen;
}
```

## Anti-Patterns

1. **Variable timestep** — passing raw `frameTime` to physics. Game runs at different speeds on 60Hz vs 144Hz monitors. Always use fixed timestep.

2. **AudioContext at page load** — browsers block it. Create on first user interaction and call `resume()` after gestures.

3. **Forgetting DPR scaling** — everything looks blurry on Retina displays. Set up DPR scaling before drawing anything.

4. **`canvas.width` for game math after DPR** — returns physical pixels, not logical. Store and use logical dimensions.

5. **`Math.sqrt()` in collision loops** — compare squared distances instead. Saves significant CPU in tight loops.

6. **No frame cap on accumulator** — a 10-second background tab produces hundreds of physics steps. Cap `frameTime` at 0.25s.

7. **Direct state assignment** — setting `game.currentState = new PlayState()` bypasses `exit()` cleanup. Always go through `switchState()`.

8. **Forgetting `endFrame()`** — `wasPressed()` returns true forever. Clear per-frame input state at the end of each loop iteration.

9. **Touch without `preventDefault()`** — the page scrolls and zooms while the player tries to play. Use `{ passive: false }` on touch listeners.
