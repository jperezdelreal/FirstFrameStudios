---
name: "web-game-deployment"
description: "Patterns for deploying web games — GitHub Pages, Vite build optimization, mobile viewport/touch, and PWA basics for offline play"
domain: "deployment"
confidence: "low"
source: "manual — first capture of web game deployment patterns for browser-based games"
has_reference: true
---

## Context

Use this skill when shipping a web game to players. Covers the full path from `npm run build` to a playable URL — static hosting on GitHub Pages, Vite build optimization, mobile viewport/touch setup, and PWA configuration for offline play. Applies to any Vite-bundled web game (Canvas 2D, PixiJS, Phaser).

## Core Patterns

### GitHub Pages Deployment

Deploy from `dist/` via GitHub Actions using `actions/upload-pages-artifact@v3` and `actions/deploy-pages@v4`. Set repository Pages source to **GitHub Actions** (not branch). Always set `base: './'` in `vite.config.ts` — default `base: '/'` breaks on repo subdirectories. Place a `CNAME` file in `public/` for custom domains.

### Vite Build Optimization

- **Tree-shaking:** Use named exports, not default-export objects. Import selectively (`{ Sprite, Container }` not `* as PIXI`).
- **Chunk splitting:** Isolate large deps (`pixi.js`, audio libs) via `manualChunks` so game code updates don't bust framework cache.
- **Asset hashing:** Vite auto-hashes filenames. Never reference built filenames directly. Set long cache on everything except `index.html`.
- **Size budgets:** JS < 500KB gzipped, images < 5MB (use spritesheets), audio < 10MB (OGG/MP3, not WAV), total initial load < 15MB.

### Mobile Viewport & Touch

Set viewport meta: `width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover`. Apply `touch-action: none` on body/canvas. Use `{ passive: false }` + `preventDefault()` on touch events. Convert touch coordinates from screen space to logical game space. Listen for both `resize` and `orientationchange` (delay for iOS).

### PWA for Offline Play

Add `manifest.json` with `display: "fullscreen"` and `orientation: "landscape"`. Register a service worker with **cache-first** strategy — ideal for static game assets. Bump `CACHE_NAME` version on each release to invalidate old caches.

## Key Examples

### Minimal Deploy Workflow

```yaml
# .github/workflows/deploy.yml
on: { push: { branches: [main] }, workflow_dispatch: }
permissions: { contents: read, pages: write, id-token: write }
concurrency: { group: pages, cancel-in-progress: true }
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci && npm run build
      - uses: actions/upload-pages-artifact@v3
        with: { path: dist }
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: { name: github-pages, url: "${{ steps.deployment.outputs.page_url }}" }
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

### Fullscreen Game HTML

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0,
    maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <meta name="theme-color" content="#0a0a1a">
  <link rel="manifest" href="manifest.json">
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

## Anti-Patterns

1. **`base: '/'` on GitHub Pages** — blank screen; assets resolve to domain root instead of repo subdirectory. Use `'./'`.
2. **Missing viewport meta / `touch-action: none`** — mobile browsers zoom and intercept swipes, making the game unplayable.
3. **Skipping `npm run preview`** — dev server and production build differ (paths, env, modules). Always test built output.
4. **Caching `index.html`** — entry point must stay fresh so browsers discover new hashed assets. Cache everything else aggressively.
5. **WAV audio files** — a single WAV can be 50MB. Use OGG with MP3 fallback; keep total audio under 10MB.
6. **No loading screen** — players see black for 3–10s during asset download. Show a progress bar.
7. **Hardcoded paths in service worker** — Vite hashes change every build. Use cache-on-first-fetch, not pre-cached filenames.
8. **No `orientationchange` handler** — phone rotation leaves canvas at wrong size.
