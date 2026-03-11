# Decision: Flora Core Engine Architecture

**Date:** 2025-07-16  
**Author:** Chewie (Engine Developer)  
**Issue:** #3 — Core Game Loop and Scene Manager Integration  
**Status:** ✅ Implemented (PR #13)  
**Repo:** jperezdelreal/flora

## Context

Flora needed foundational engine infrastructure before any gameplay could be built. The scaffold provided stubs for SceneManager and EventBus but no game loop, input handling, or asset loading.

## Decisions

### 1. Fixed-Timestep Game Loop (Accumulator Pattern)
- GameLoop wraps PixiJS Ticker but steps in fixed 1/60s increments via time accumulator
- Max 4 fixed steps per frame prevents spiral of death on lag spikes
- Provides `frameCount` for deterministic logic and `alpha` for render interpolation
- **Rationale:** Deterministic state updates enable future save/replay/netcode. Variable-delta game logic causes desync bugs.

### 2. SceneContext Injection (No Global Singletons)
- Scenes receive `SceneContext = { app, sceneManager, input, assets }` in `init()` and `update()`
- No global `window.game` or singleton pattern
- **Rationale:** Explicit dependencies are testable, refactorable, and don't create hidden coupling.

### 3. Input Edge Detection Per Fixed Step
- `InputManager.endFrame()` clears pressed/released sets after each fixed-step update
- Raw key state persists across frames; edges are consumed once
- **Rationale:** Variable frame rates can cause missed inputs if edges are cleared per render frame instead of per logic step.

### 4. Scene Transitions via Graphics Overlay
- Fade-to-black using a Graphics rectangle with animated alpha (ease-in-out)
- No render-to-texture or extra framebuffers
- **Rationale:** Simple, GPU-efficient, works on all PixiJS backends (WebGL, WebGPU, Canvas).

## Alternatives Rejected
1. **Raw Ticker.deltaTime for game logic** — Non-deterministic, causes physics/timing bugs
2. **Global singleton for input/assets** — Hidden dependencies, harder to test
3. **CSS transitions for scene fades** — Breaks when canvas is fullscreen, not composable with game rendering
