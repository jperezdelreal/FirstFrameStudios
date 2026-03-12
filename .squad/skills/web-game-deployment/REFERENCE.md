---
name: "web-game-deployment"
description: "Patterns for deploying web games — GitHub Pages, Vite build optimization, mobile viewport/touch, and PWA basics for offline play"
domain: "deployment"
confidence: "low"
source: "manual — first capture of web game deployment patterns for browser-based games"
---

## Context

Use this skill when shipping a web game to players. Covers the full path from `npm run build` to a playable URL — static hosting on GitHub Pages, build optimization for fast load times, mobile-friendly viewport setup, and PWA configuration for offline play.

This applies to any web game built with Vite (or similar bundlers). The patterns work for both raw Canvas 2D games and PixiJS/Phaser projects.

## Patterns

### 1. GitHub Pages Deployment (Static, from dist/)

#### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
    push:
        branches: [main]
    workflow_dispatch:

permissions:
    contents: read
    pages: write
    id-token: write

concurrency:
    group: pages
    cancel-in-progress: true

jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4
            - uses: actions/setup-node@v4
              with:
                  node-version: 20
                  cache: npm
            - run: npm ci
            - run: npm run build
            - uses: actions/upload-pages-artifact@v3
              with:
                  path: dist

    deploy:
        needs: build
        runs-on: ubuntu-latest
        environment:
            name: github-pages
            url: ${{ steps.deployment.outputs.page_url }}
        steps:
            - id: deployment
              uses: actions/deploy-pages@v4
```

#### Vite Base Path

```typescript
// vite.config.ts
export default defineConfig({
    base: './', // relative paths — works on any subdirectory
});
```

**Critical:** Default `base: '/'` breaks on GitHub Pages when the repo isn't at the root domain. Use `'./'` for portable builds.

#### Repository Settings

1. Settings → Pages → Source: **GitHub Actions**
2. No need to configure a branch — the workflow handles artifact upload
3. Custom domain: add a `CNAME` file to `public/` so Vite copies it to `dist/`

### 2. Vite Build Optimization

#### Tree-Shaking

Vite (via Rollup) tree-shakes unused exports automatically. To benefit:

```typescript
// ✅ Named exports — tree-shakeable
export function lerp(a: number, b: number, t: number): number { ... }
export function clamp(value: number, min: number, max: number): number { ... }

// ❌ Default export of object — NOT tree-shakeable
export default { lerp, clamp };
```

**Rules:**
- Use named exports for utility functions
- Avoid `import * as Utils` — import only what you use
- PixiJS v8 is tree-shakeable — import `{ Sprite, Container }` not the entire package

#### Asset Hashing

Vite adds content hashes to filenames automatically (`hero-3a4b5c.png`). This enables aggressive caching:

```typescript
// vite.config.ts
export default defineConfig({
    build: {
        rollupOptions: {
            output: {
                // Organize hashed output
                assetFileNames: 'assets/[name]-[hash][extname]',
                chunkFileNames: 'js/[name]-[hash].js',
                entryFileNames: 'js/[name]-[hash].js',
            },
        },
    },
});
```

**Rules:**
- Never reference built filenames directly — they change on every build
- `index.html` is NOT hashed (entry point must be stable)
- Set long cache headers on everything except `index.html`

#### Chunk Splitting

```typescript
// vite.config.ts
export default defineConfig({
    build: {
        rollupOptions: {
            output: {
                manualChunks: {
                    pixi: ['pixi.js'],       // ~400KB — cache separately
                    audio: ['tone', 'howler'], // audio libs if used
                },
            },
        },
    },
});
```

Separate large dependencies into their own chunks so game code updates don't invalidate the framework cache.

#### Compression

```typescript
// vite.config.ts
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
    plugins: [
        viteCompression({ algorithm: 'gzip' }),  // .gz files
        viteCompression({ algorithm: 'brotliCompress', ext: '.br' }), // .br files
    ],
});
```

GitHub Pages serves gzip automatically. For custom hosting, pre-compress with Brotli for ~15–20% smaller bundles.

#### Build Size Budget

| Asset Type | Budget | Notes |
|-----------|--------|-------|
| Total JS (gzipped) | < 500KB | PixiJS alone is ~150KB gzipped |
| Total images | < 5MB | Use spritesheets, not individual PNGs |
| Audio | < 10MB | Use OGG/MP3, not WAV |
| Initial load (all) | < 15MB | Players abandon after 10s on mobile |

### 3. Mobile Viewport and Touch

#### Viewport Meta Tag

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0,
    maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
```

**Every attribute matters:**
- `maximum-scale=1.0, user-scalable=no` — prevents pinch-to-zoom breaking game input
- `viewport-fit=cover` — fills the screen on notched devices (iPhone)

#### Fullscreen Canvas CSS

```css
* { margin: 0; padding: 0; box-sizing: border-box; }

html, body {
    width: 100%;
    height: 100%;
    overflow: hidden;        /* no scrollbars */
    touch-action: none;      /* disable browser gestures */
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    user-select: none;
}

canvas {
    display: block;
    width: 100vw;
    height: 100vh;
    /* OR maintain aspect ratio: */
    /* max-width: 100vw; max-height: 100vh; margin: auto; */
    object-fit: contain;
}
```

**`touch-action: none`** on the body is critical — without it, the browser intercepts swipes for navigation.

#### Responsive Canvas Resize

```typescript
function resizeCanvas(app: Application, logicalW: number, logicalH: number): void {
    const windowW = window.innerWidth;
    const windowH = window.innerHeight;
    const scale = Math.min(windowW / logicalW, windowH / logicalH);

    const scaledW = Math.floor(logicalW * scale);
    const scaledH = Math.floor(logicalH * scale);

    app.canvas.style.width = `${scaledW}px`;
    app.canvas.style.height = `${scaledH}px`;
    app.canvas.style.marginLeft = `${(windowW - scaledW) / 2}px`;
    app.canvas.style.marginTop = `${(windowH - scaledH) / 2}px`;
}

window.addEventListener('resize', () => resizeCanvas(app, 1280, 720));
window.addEventListener('orientationchange', () => {
    setTimeout(() => resizeCanvas(app, 1280, 720), 100); // delay for iOS
});
```

#### Touch Input Considerations

```typescript
// Prevent default on game canvas to avoid scroll/zoom
canvas.addEventListener('touchstart', handler, { passive: false });
canvas.addEventListener('touchmove', handler, { passive: false });

function handler(e: TouchEvent): void {
    e.preventDefault();
    // Convert to logical coordinates
    const rect = canvas.getBoundingClientRect();
    for (const touch of Array.from(e.changedTouches)) {
        const x = (touch.clientX - rect.left) * (logicalWidth / rect.width);
        const y = (touch.clientY - rect.top) * (logicalHeight / rect.height);
        // handle touch at (x, y)
    }
}
```

**Rules:**
- Always convert touch coordinates from screen space to game logical space
- Use `{ passive: false }` + `preventDefault()` to stop browser from intercepting touches
- Support multi-touch — iterate `changedTouches`, not just `touches[0]`
- Add on-screen virtual controls (D-pad, buttons) for mobile — keyboard doesn't exist

### 4. PWA Basics

#### Web App Manifest

```json
// public/manifest.json
{
    "name": "My Game",
    "short_name": "MyGame",
    "description": "A browser-based 2D game",
    "start_url": "./index.html",
    "display": "fullscreen",
    "orientation": "landscape",
    "background_color": "#0a0a1a",
    "theme_color": "#0a0a1a",
    "icons": [
        { "src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
        { "src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
    ]
}
```

Link it in `index.html`:
```html
<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#0a0a1a">
<meta name="apple-mobile-web-app-capable" content="yes">
```

**`display: "fullscreen"`** hides the browser chrome — the game fills the entire screen. Use `"standalone"` if you want the status bar visible.

**`orientation: "landscape"`** locks orientation on mobile. Use `"any"` for games that work in both orientations.

#### Service Worker for Offline Play

```javascript
// public/sw.js
const CACHE_NAME = 'game-v1';
const ASSETS_TO_CACHE = [
    './',
    './index.html',
    // JS and CSS files are hashed — cache them on first load
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS_TO_CACHE))
    );
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) =>
            Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
        )
    );
    self.clients.claim();
});

self.addEventListener('fetch', (event) => {
    event.respondWith(
        caches.match(event.request).then((cached) => {
            // Cache-first strategy — perfect for games where assets don't change
            return cached || fetch(event.request).then((response) => {
                const clone = response.clone();
                caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
                return response;
            });
        })
    );
});
```

Register in `main.ts`:
```typescript
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('./sw.js').catch(console.error);
}
```

**Cache-first strategy** is ideal for games — assets are static and versioned by hash. The service worker serves from cache instantly, only fetching on cache miss.

**Updating the game:** Change `CACHE_NAME` to `'game-v2'`. The `activate` event deletes old caches. Players get the new version on their next visit.

## Examples

### Minimal index.html for a Web Game

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0,
        maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="theme-color" content="#0a0a1a">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <link rel="manifest" href="manifest.json">
    <title>My Game</title>
    <style>
        * { margin: 0; padding: 0; }
        html, body { width: 100%; height: 100%; overflow: hidden;
            background: #0a0a1a; touch-action: none; user-select: none; }
        canvas { display: block; }
    </style>
</head>
<body>
    <div id="game"></div>
    <script type="module" src="/src/main.ts"></script>
</body>
</html>
```

### Deploy Checklist

```
Pre-deploy:
  □ npm run build succeeds with no errors
  □ npm run preview — test the built version locally
  □ Test on mobile device or Chrome DevTools mobile emulation
  □ Check total bundle size (< 500KB JS gzipped, < 15MB total)

GitHub Pages:
  □ vite.config.ts has base: './'
  □ Deploy workflow committed to .github/workflows/
  □ Repository Settings → Pages → Source: GitHub Actions
  □ CNAME in public/ if using custom domain

Mobile:
  □ Viewport meta tag includes user-scalable=no
  □ touch-action: none on body
  □ Canvas resizes on orientationchange
  □ Touch coordinates converted to logical space
  □ Virtual controls visible on touch devices

PWA:
  □ manifest.json in public/ with icons
  □ Service worker registered
  □ Game loads offline after first visit
  □ Cache version bumped on each release
```

## Anti-Patterns

1. **`base: '/'` for GitHub Pages** — assets load from the domain root, not the repo subdirectory. The game shows a blank screen. Use `base: './'`.

2. **No viewport meta tag** — mobile browsers zoom and scroll on touch input. The game becomes unplayable on phones. Add it to `index.html` on day 1.

3. **Forgetting `touch-action: none`** — swipe gestures trigger browser back/forward navigation instead of game input. Set on the body or canvas element.

4. **Skipping `npm run preview`** — the dev server and production build behave differently (asset paths, env variables, module resolution). Always test the built version before deploying.

5. **Caching `index.html`** — the entry point must always be fresh so browsers discover new hashed assets. Set `Cache-Control: no-cache` for `index.html` only; everything else gets long-lived caches.

6. **No loading screen** — players see a black screen for 3–10 seconds while assets download. Show a progress bar during `Assets.loadBundle()`.

7. **WAV audio files** — a single WAV can be 50MB. Use OGG (preferred, smaller) with MP3 fallback. Keep total audio under 10MB.

8. **No `orientationchange` handler** — rotating a phone leaves the canvas at the wrong size. Listen for both `resize` and `orientationchange` (with a small delay for iOS).

9. **Hardcoding asset paths in service worker** — Vite hashes filenames on every build. Use a cache-first strategy that caches on first fetch instead of pre-caching specific filenames.
