---
name: game-engine
description: 'Expert skill for building web games using HTML5, Canvas, WebGL, JavaScript'
domain: "game-development"
confidence: "high"
has_reference: true
---

## Context
Build web-based games and engines using HTML5 Canvas, WebGL, JavaScript. Includes starter templates, reference docs, workflows for 2D/3D with Phaser, Three.js, Babylon.js, A-Frame.

## Core Patterns

- **Game loop:** Process Input → Update State → Render (use `requestAnimationFrame`)
- **Rendering:** Canvas 2D (sprites, tilemaps), WebGL (3D, advanced 2D), SVG (vector UI), CSS (DOM elements)
- **Physics:** 2D (AABB, circle, SAT collision), 3D (bounding box/sphere, raycasting), velocity/acceleration, gravity
- **Controls:** Keyboard (arrow/WASD), Mouse (click, pointer lock), Touch (virtual joysticks), Gamepad API
- **Audio:** Web Audio API (programmatic, spatial), HTML5 Audio (simple playback)

## Key Examples

**Basic 2D workflow:**
1. HTML with `<canvas>`
2. Get 2D context
3. Game loop with `requestAnimationFrame`
4. Game objects (position, velocity, size)
5. Input handling
6. Collision detection
7. Scoring/win conditions
8. Audio

**Templates available:** paddle-game, 2d-maze, 2d-platform, gameBase-template-repo, simple-2d-engine

**References:** basics.md, web-apis.md, techniques.md, 3d-web-games.md, control-mechanisms.md, publishing.md, algorithms.md

## Anti-Patterns

- **Canvas blank** — Check context and drawing inside game loop
- **Variable speed** — Use delta time, not fixed values
- **Inconsistent collision** — Continuous detection for fast objects
- **Audio won't play** — Requires user interaction first
- **Poor performance** — Profile, reduce draw calls, object pooling
