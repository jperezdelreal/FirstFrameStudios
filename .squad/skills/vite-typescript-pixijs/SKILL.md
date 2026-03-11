---
name: "vite-typescript-pixijs"
description: "Patterns for building games with Vite + TypeScript strict mode + PixiJS v8 — project setup, asset loading, scene management, and type-safe game architecture"
domain: "game-engine"
confidence: "low"
source: "manual — first capture of Vite + TS + PixiJS v8 patterns for web game development"
---

## Context

Use this skill when building a 2D web game with PixiJS v8 as the rendering engine, TypeScript for type safety, and Vite as the build tool. This stack is the right choice when you need WebGL/WebGPU rendering performance, sprite sheet support, and a mature asset pipeline — things that raw Canvas 2D doesn't provide out of the box.

This does NOT apply to raw Canvas 2D games (see `canvas-2d-game-engine`) or 3D games (use Three.js or Babylon.js instead).

## Patterns

### 1. Project Setup

#### vite.config.ts

```typescript
import { defineConfig } from 'vite';

export default defineConfig({
    base: './', // relative paths for GitHub Pages deployment
    build: {
        target: 'esnext',
        assetsInlineLimit: 0, // never inline assets — let PixiJS loader handle them
        rollupOptions: {
            output: {
                manualChunks: {
                    pixi: ['pixi.js'], // separate chunk for PixiJS (~400KB)
                },
            },
        },
    },
    server: {
        port: 3000,
        open: true,
    },
});
```

#### tsconfig.json

```json
{
    "compilerOptions": {
        "target": "ESNext",
        "module": "ESNext",
        "moduleResolution": "bundler",
        "strict": true,
        "noUncheckedIndexedAccess": true,
        "exactOptionalPropertyTypes": true,
        "useDefineForClassFields": true,
        "skipLibCheck": true,
        "outDir": "dist",
        "sourceMap": true,
        "types": ["vite/client"]
    },
    "include": ["src"]
}
```

**Key flags:**
- `strict: true` — non-negotiable for game code; catches null entity bugs at compile time
- `noUncheckedIndexedAccess` — array/map access returns `T | undefined`, forcing null checks on tile lookups, entity arrays, etc.
- `exactOptionalPropertyTypes` — prevents `undefined` from sneaking into optional config fields

#### package.json scripts

```json
{
    "scripts": {
        "dev": "vite",
        "build": "tsc --noEmit && vite build",
        "preview": "vite preview",
        "typecheck": "tsc --noEmit --watch"
    }
}
```

Always run `tsc --noEmit` before `vite build`. Vite strips types without checking them — TypeScript errors silently pass through.

### 2. PixiJS v8 Application Bootstrap

```typescript
import { Application, Assets } from 'pixi.js';

const LOGICAL_WIDTH = 1280;
const LOGICAL_HEIGHT = 720;

async function main(): Promise<void> {
    const app = new Application();

    await app.init({
        width: LOGICAL_WIDTH,
        height: LOGICAL_HEIGHT,
        backgroundColor: 0x1a1a2e,
        resolution: window.devicePixelRatio || 1,
        autoDensity: true,
        antialias: false, // pixel art — disable antialiasing
    });

    document.getElementById('game')!.appendChild(app.canvas);

    // Load assets before starting game
    await loadAssets();

    // Start game loop
    const game = new GameManager(app);
    app.ticker.add((ticker) => {
        game.update(ticker.deltaTime / 60); // convert to seconds
    });
}

main().catch(console.error);
```

**PixiJS v8 changes from v7:**
- `new Application()` no longer takes options — call `await app.init({...})` separately
- `app.view` is now `app.canvas`
- `app.screen` gives logical dimensions (use for positioning)
- Ticker delta is in frames (1.0 = one frame at 60fps) — divide by 60 for seconds

### 3. Asset Loading and Management

```typescript
import { Assets, Spritesheet, Texture } from 'pixi.js';

// Define asset manifest — single source of truth
const manifest = {
    bundles: [
        {
            name: 'game',
            assets: [
                { alias: 'hero', src: './assets/hero.png' },
                { alias: 'heroSheet', src: './assets/hero.json' },
                { alias: 'tiles', src: './assets/tileset.png' },
                { alias: 'bgMusic', src: './assets/music.mp3' },
            ],
        },
        {
            name: 'ui',
            assets: [
                { alias: 'font', src: './assets/ui-font.fnt' },
                { alias: 'buttons', src: './assets/buttons.json' },
            ],
        },
    ],
};

async function loadAssets(): Promise<void> {
    await Assets.init({ manifest });

    // Load bundles on demand — don't load everything upfront
    await Assets.loadBundle('game');
}

// Type-safe asset access
function getTexture(alias: string): Texture {
    const texture = Assets.get<Texture>(alias);
    if (!texture) throw new Error(`Texture not found: ${alias}`);
    return texture;
}
```

**Rules:**
- Use a manifest — no scattered `Assets.load()` calls throughout the codebase
- Bundle assets by scene/level — load only what's needed
- Always provide a loading screen during `loadBundle()` — asset loading is async and can take seconds
- Alias names are the contract between loading and usage — keep them stable

### 4. Scene Management

```typescript
import { Container, Application } from 'pixi.js';

interface Scene {
    readonly container: Container;
    enter(params?: Record<string, unknown>): void;
    exit(): void;
    update(dt: number): void;
}

class SceneManager {
    private currentScene: Scene | null = null;
    private scenes = new Map<string, Scene>();

    constructor(private app: Application) {}

    register(name: string, scene: Scene): void {
        this.scenes.set(name, scene);
    }

    switchTo(name: string, params?: Record<string, unknown>): void {
        if (this.currentScene) {
            this.currentScene.exit();
            this.app.stage.removeChild(this.currentScene.container);
        }

        const next = this.scenes.get(name);
        if (!next) throw new Error(`Scene not found: ${name}`);

        this.currentScene = next;
        this.app.stage.addChild(next.container);
        next.enter(params);
    }

    update(dt: number): void {
        this.currentScene?.update(dt);
    }
}
```

**Scene implementation:**

```typescript
class PlayScene implements Scene {
    readonly container = new Container();
    private entities: Entity[] = [];

    enter(params?: Record<string, unknown>): void {
        const level = (params?.['level'] as number) ?? 1;
        this.buildLevel(level);
    }

    exit(): void {
        this.container.removeChildren();
        this.entities = [];
    }

    update(dt: number): void {
        for (const entity of this.entities) {
            entity.update(dt);
        }
    }

    private buildLevel(level: number): void {
        // Create sprites, add to container, populate entities array
    }
}
```

**Rules:**
- Each scene owns a `Container` — added/removed from `app.stage` on enter/exit
- `exit()` must destroy everything `enter()` created (children, event listeners, audio)
- Scenes are reusable — `enter()` re-initializes, not the constructor

### 5. TypeScript Strict Mode Patterns for Games

#### Entity Types with Discriminated Unions

```typescript
type EntityState =
    | { kind: 'idle' }
    | { kind: 'walk'; direction: Vector2 }
    | { kind: 'attack'; frame: number; duration: number }
    | { kind: 'hit'; stunTime: number }
    | { kind: 'dead' };

interface Entity {
    x: number;
    y: number;
    state: EntityState;
    update(dt: number): void;
}

function handleState(entity: Entity, dt: number): void {
    switch (entity.state.kind) {
        case 'idle':
            // TypeScript knows no extra fields here
            break;
        case 'attack':
            // TypeScript knows .frame and .duration exist
            entity.state.frame += dt;
            if (entity.state.frame >= entity.state.duration) {
                entity.state = { kind: 'idle' };
            }
            break;
        case 'hit':
            entity.state.stunTime -= dt;
            if (entity.state.stunTime <= 0) {
                entity.state = { kind: 'idle' };
            }
            break;
        // exhaustive — compiler errors if you miss a case
    }
}
```

#### Readonly Config Objects

```typescript
interface EnemyConfig {
    readonly name: string;
    readonly hp: number;
    readonly speed: number;
    readonly attackRange: number;
    readonly cooldown: number;
}

const ENEMY_TYPES = {
    grunt: { name: 'Grunt', hp: 30, speed: 100, attackRange: 50, cooldown: 1.5 },
    brute: { name: 'Brute', hp: 80, speed: 60, attackRange: 70, cooldown: 2.5 },
} as const satisfies Record<string, EnemyConfig>;

type EnemyType = keyof typeof ENEMY_TYPES;
```

`as const satisfies` gives you both literal types AND compile-time validation against the interface.

#### Nullable Patterns

```typescript
// ❌ BAD — nullable field with no guard
class Player {
    target: Enemy | null = null;

    attack(): void {
        this.target.takeDamage(10); // 💥 runtime error if null
    }
}

// ✅ GOOD — explicit null check
class Player {
    target: Enemy | null = null;

    attack(): void {
        if (!this.target) return;
        this.target.takeDamage(10); // TypeScript narrows to Enemy
    }
}
```

#### Type-Safe Event Emitter

```typescript
type GameEvents = {
    'enemy-killed': { enemy: Enemy; score: number };
    'level-complete': { level: number; time: number };
    'player-hit': { damage: number; source: Entity };
};

class TypedEmitter<T extends Record<string, unknown>> {
    private listeners = new Map<keyof T, Set<(data: never) => void>>();

    on<K extends keyof T>(event: K, fn: (data: T[K]) => void): void {
        if (!this.listeners.has(event)) this.listeners.set(event, new Set());
        this.listeners.get(event)!.add(fn as (data: never) => void);
    }

    emit<K extends keyof T>(event: K, data: T[K]): void {
        for (const fn of this.listeners.get(event) ?? []) {
            (fn as (data: T[K]) => void)(data);
        }
    }

    off<K extends keyof T>(event: K, fn: (data: T[K]) => void): void {
        this.listeners.get(event)?.delete(fn as (data: never) => void);
    }
}
```

## Examples

### Full Bootstrap (main.ts)

```typescript
import { Application, Assets } from 'pixi.js';
import { SceneManager } from './scenes/SceneManager';
import { MenuScene } from './scenes/MenuScene';
import { PlayScene } from './scenes/PlayScene';

async function main(): Promise<void> {
    const app = new Application();
    await app.init({
        width: 1280,
        height: 720,
        backgroundColor: 0x0a0a1a,
        resolution: window.devicePixelRatio || 1,
        autoDensity: true,
    });

    document.getElementById('game')!.appendChild(app.canvas);

    // Load core assets
    await Assets.init({ manifest: (await import('./assets/manifest')).default });
    await Assets.loadBundle('core');

    // Setup scenes
    const scenes = new SceneManager(app);
    scenes.register('menu', new MenuScene(scenes));
    scenes.register('play', new PlayScene(scenes));
    scenes.switchTo('menu');

    // Game loop
    app.ticker.add((ticker) => {
        scenes.update(ticker.deltaTime / 60);
    });
}

main().catch(console.error);
```

### Project Structure

```
src/
    main.ts               # Bootstrap — init PixiJS, load assets, start
    assets/
        manifest.ts       # Asset manifest (bundles + aliases)
    scenes/
        SceneManager.ts   # Scene switching, lifecycle
        MenuScene.ts
        PlayScene.ts
        GameOverScene.ts
    entities/
        Player.ts
        Enemy.ts
        types.ts          # Shared entity interfaces and state types
    systems/
        CollisionSystem.ts
        InputSystem.ts
    config/
        enemies.ts        # Readonly config data
        levels.ts
    utils/
        math.ts           # Vector2, clamp, lerp
        pool.ts           # Object pool for particles/projectiles
```

## Anti-Patterns

1. **Skipping `tsc --noEmit`** — Vite strips types without checking them. Your game compiles with type errors and crashes at runtime. Always typecheck before building.

2. **Using `any` for game entities** — defeats the purpose of TypeScript. Use discriminated unions for state, interfaces for contracts, and `unknown` + type guards when deserializing.

3. **`new Application({ ... })` in PixiJS v8** — constructor no longer takes options. Use `await app.init({...})`. Failing to await means rendering before the GPU context is ready.

4. **Scattered `Assets.load()` calls** — assets load at unpredictable times, causing missing texture errors. Use a manifest and load bundles explicitly during scene transitions with a loading indicator.

5. **Ignoring `noUncheckedIndexedAccess`** — array access like `entities[i]` silently returns `undefined` when out of bounds. This flag forces you to handle it, preventing ghost entity bugs.

6. **Mutating config objects** — an enemy that modifies its `config.hp` corrupts the config for all enemies of that type. Use `readonly` on config interfaces and create instance copies.

7. **Forgetting to remove children on scene exit** — PixiJS containers retain references. Leaked sprites accumulate, slow rendering, and cause state bugs on re-entry.

8. **`app.view` in PixiJS v8** — renamed to `app.canvas`. Code copied from v7 tutorials silently fails.
