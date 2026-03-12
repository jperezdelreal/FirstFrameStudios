---
name: "canvas-2d-optimization"
description: "Performance and quality patterns for Canvas 2D — HiDPI, sprite caching, text rendering, migration criteria"
domain: "rendering"
confidence: "low"
source: "earned — extracted from firstPunch HiDPI retrofit"
has_reference: true
---

## Context
Performance and visual quality patterns for HTML5 Canvas 2D games. HiDPI handling is day-1 requirement, not optimization. On Retina displays, missing DPR fix = half-resolution upscaled = blurry everything.

## Core Patterns

- **HiDPI setup (THE #1 lesson):** `canvas.width = logical * dpr; canvas.style.width = logical + 'px'; ctx.scale(dpr, dpr)`. Store logicalWidth/Height for game code
- **Remove `image-rendering: pixelated`** — Destructive for procedural art. Only correct for actual pixel art at integer scale
- **Sprite caching with offscreen canvas** — Cache procedural draws (100 API calls → 1 `drawImage`). Key: `entityType_state_facing_frame`
- **Pixel-perfect text** — `Math.round()` text positions. Below 10px = invisible. Set `textBaseline = 'middle'`
- **Performance budgets:** <8ms frame time, <500 Canvas calls/frame, <50 entities uncached, <200 particles

## Key Examples

**Sprite cache:**
```javascript
function getCachedSprite(entity, state, frame) {
    const key = `___`;
    if (!cache.has(key)) {
        const offscreen = document.createElement('canvas');
        offscreen.width = entity.width * dpr;
        offscreen.height = entity.height * dpr;
        const octx = offscreen.getContext('2d');
        octx.scale(dpr, dpr);
        entity.drawProcedural(octx);
        cache.set(key, offscreen);
    }
    return cache.get(key);
}
```

**When to migrate to PixiJS:** >100 entities consistently, frame time >12ms after caching, need GPU shaders. Hybrid approach: procedural → offscreen Canvas → PixiJS texture.

## Anti-Patterns

- **No DPR handling** — #1 visual quality killer. Everything blurry on Retina
- **`image-rendering: pixelated` on procedural** — Destroys smooth curves
- **Using `ctx.canvas.width` after DPR** — Returns physical pixels (doubled)
- **Sub-pixel text coords** — Causes blur. Always `Math.round()`
- **Redrawing procedural every frame** — 100 calls × 20 entities = 2000. Cache
