---
name: "vite-typescript-pixijs"
description: "Patterns for building games with Vite + TypeScript strict mode + PixiJS v8 — project setup, asset loading, scene management, and type-safe game architecture"
domain: "game-engine"
confidence: "low"
has_reference: true
source: "manual — first capture of Vite + TS + PixiJS v8 patterns for web game development"
---

## Context

Use this skill when building a 2D web game with PixiJS v8, TypeScript strict mode, and Vite. This stack provides WebGL/WebGPU rendering, sprite sheets, and a mature asset pipeline. Does NOT apply to raw Canvas 2D games (see `canvas-2d-game-engine`) or 3D games (Three.js/Babylon.js).

## Core Patterns

### Vite Setup

- `base: './'` for relative paths (GitHub Pages); `assetsInlineLimit: 0` so PixiJS loader handles assets; split PixiJS into its own chunk via `manualChunks`.
- Build script must run `tsc --noEmit && vite build` — Vite strips types without checking them.

### TypeScript Config

- `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true` — non-negotiable for game code.
- `moduleResolution: "bundler"`, `types: ["vite/client"]`.
- Use discriminated unions for entity state, `as const satisfies` for readonly config objects, explicit null guards everywhere.

### PixiJS v8 Integration

- **Bootstrap:** `const app = new Application(); await app.init({...});` — constructor takes no options in v8.
- **Canvas:** `app.canvas` (not `app.view`). Ticker delta is in frames — divide by 60 for seconds.
- **Assets:** Define a manifest with bundles; load via `Assets.init({ manifest })` then `Assets.loadBundle('name')`. No scattered `Assets.load()` calls.
- **Scenes:** Each scene owns a `Container` added/removed from `app.stage`. `exit()` must clean up everything `enter()` created.

## Key Examples

### Full Bootstrap

```typescript
import { Application, Assets } from 'pixi.js';

async function main(): Promise<void> {
    const app = new Application();
    await app.init({
        width: 1280, height: 720,
        backgroundColor: 0x0a0a1a,
        resolution: window.devicePixelRatio || 1,
        autoDensity: true,
    });
    document.getElementById('game')!.appendChild(app.canvas);

    await Assets.init({ manifest: (await import('./assets/manifest')).default });
    await Assets.loadBundle('core');

    const scenes = new SceneManager(app);
    scenes.register('menu', new MenuScene(scenes));
    scenes.register('play', new PlayScene(scenes));
    scenes.switchTo('menu');

    app.ticker.add((ticker) => scenes.update(ticker.deltaTime / 60));
}
main().catch(console.error);
```

### Project Structure

```
src/
    main.ts                # Bootstrap
    assets/manifest.ts     # Asset manifest (bundles + aliases)
    scenes/                # SceneManager, MenuScene, PlayScene, GameOverScene
    entities/              # Player, Enemy, types.ts (interfaces + state unions)
    systems/               # CollisionSystem, InputSystem
    config/                # Readonly config data (enemies, levels)
    utils/                 # math (Vector2, clamp, lerp), pool (object pooling)
```

## Anti-Patterns

1. **Skipping `tsc --noEmit`** — type errors silently pass through Vite; game crashes at runtime.
2. **`new Application({ ... })` in v8** — constructor no longer takes options; must use `await app.init({...})`.
3. **Scattered `Assets.load()` calls** — unpredictable load timing causes missing texture errors. Use manifest bundles.
4. **Using `any` for entities** — use discriminated unions and `unknown` + type guards instead.
5. **Forgetting scene cleanup** — `exit()` must remove children, listeners, and audio to prevent leaks.
6. **`app.view` in v8** — renamed to `app.canvas`; v7 tutorial code silently fails.
7. **Mutating config objects** — use `readonly` interfaces and instance copies to avoid shared-state corruption.
8. **Ignoring `noUncheckedIndexedAccess`** — array access returns `T | undefined`, preventing ghost entity bugs.