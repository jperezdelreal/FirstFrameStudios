# SKILL: Canvas 2D Optimization

Performance and visual quality patterns for HTML5 Canvas 2D games. Covers HiDPI rendering, sprite caching, text quality, and migration criteria.

---
name: "canvas-2d-optimization"
description: "Performance and quality patterns for Canvas 2D — HiDPI, sprite caching, text rendering, migration criteria"
domain: "rendering"
confidence: "low"
source: "earned — extracted from firstPunch HiDPI retrofit, visual quality audits, and rendering research"
---

## When to Use This Skill
- Building or maintaining a Canvas 2D game
- Diagnosing blurry rendering on Retina/HiDPI displays
- Optimizing render performance (too many draw calls, frame drops)
- Evaluating whether to stay on Canvas 2D or migrate to PixiJS
- Fixing text readability or visual quality issues

## When NOT to Use This Skill
- Already using PixiJS/Phaser (these handle DPR and batching internally)
- WebGL-first project (different optimization model)
- Non-game Canvas use (data visualization has different patterns)

---

## Core Patterns

### 1. HiDPI / devicePixelRatio Setup (THE #1 Lesson)

**This is a day-1 requirement, not an optimization.** On Retina displays, a canvas without DPR handling renders at half resolution and gets upscaled by the browser, making everything blurry. This single fix resolves ~60% of the "cheap look."

```javascript
const dpr = window.devicePixelRatio || 1;
canvas.width = 1280 * dpr;           // physical pixel buffer
canvas.height = 720 * dpr;
canvas.style.width = '1280px';       // CSS locks visual size
canvas.style.height = '720px';
ctx.scale(dpr, dpr);                 // all drawing uses logical coords

// Store logical dimensions for game code to reference
canvas.logicalWidth = 1280;
canvas.logicalHeight = 720;
```

**After applying DPR fix, audit all code for hardcoded dimensions:**
```javascript
// ❌ WRONG — uses physical pixels (doubled on Retina)
const centerX = ctx.canvas.width / 2;

// ✅ CORRECT — uses logical pixels (stable across DPR)
const centerX = ctx.canvas.logicalWidth / 2;
// Or: ctx.canvas.width / dpr / 2;
```

**Hidden bugs post-DPR fix:** Any file using `ctx.canvas.width` or `ctx.canvas.height` directly will break. In firstPunch, 5 files had this bug (game.js, vfx.js ×3, debug overlay). Add `logicalWidth`/`logicalHeight` properties and search-replace.

### 2. Remove `image-rendering: pixelated`

```css
/* ❌ DESTRUCTIVE for procedural/vector art */
canvas {
    image-rendering: crisp-edges;
    image-rendering: pixelated;
}

/* ✅ CORRECT — let browser use bilinear filtering (default) */
canvas {
    /* No image-rendering property at all */
}
```

**Why it's wrong:** `pixelated` forces nearest-neighbor upscaling. For pixel art sprites, this is correct. For procedural Canvas 2D drawing (arcs, beziers, gradients, text), it makes everything blocky — diagonal lines staircase, curves lose smoothness, gradients band.

**When pixelated IS correct:** Only when rendering actual pixel art at integer scale factors. If you're drawing shapes with Canvas API calls, never use it.

### 3. Sprite Caching with Offscreen Canvases

Procedural drawing is expensive per-call (~100 Canvas API calls per entity). Cache the result to an offscreen canvas and blit with a single `drawImage()`.

```javascript
const spriteCache = new Map();

function getCachedSprite(entity, state, frame) {
    const key = `${entity.type}_${state}_${frame}_${entity.facing}`;
    
    if (!spriteCache.has(key)) {
        const dpr = window.devicePixelRatio || 1;
        const offscreen = document.createElement('canvas');
        offscreen.width = entity.width * dpr;
        offscreen.height = entity.height * dpr;
        const octx = offscreen.getContext('2d');
        octx.scale(dpr, dpr);
        entity.drawProcedural(octx);  // full procedural draw (once)
        spriteCache.set(key, offscreen);
    }
    return spriteCache.get(key);
}

// In render loop — one call instead of 100:
const sprite = getCachedSprite(entity, entity.state, entity.frame);
ctx.drawImage(sprite, entity.x, entity.y, entity.width, entity.height);
```

**Performance impact:**

| Metric | Before Cache | After Cache | Improvement |
|--------|-------------|-------------|-------------|
| Canvas API calls/frame (20 entities) | ~2,500 | ~200 | 12.5× |
| Per-entity draw calls | ~100 | 1 | 100× |
| Frame render time | ~12ms | ~2ms | 6× |
| Max entities at 60fps | ~30 | ~100+ | 3× |

**Cache key pattern:** `${entityType}_${state}_${facing}_${frame}` captures all visual variations. State changes auto-invalidate (new key = cache miss = redraw).

**When NOT to cache:**
- Scrolling backgrounds (key changes every frame, defeats caching)
- Individual particles (too cheap, change every frame)
- Entities with continuous variation (smooth rotation, color lerps)

**Memory budget:** ~8MB for 50 cached sprites at 2× DPR. Add LRU eviction if cache grows beyond 100 entries.

### 4. Pixel-Perfect Text Rendering

```javascript
// ❌ BLURRY — sub-pixel positioning
ctx.fillText('SCORE: 1000', 10.7, 24.3);

// ✅ CRISP — integer coordinates
ctx.fillText('SCORE: 1000', Math.round(10.7), Math.round(24.3));
```

**Helper pattern from firstPunch:**
```javascript
function drawCrispText(ctx, text, x, y, font, color) {
    ctx.font = font;
    ctx.fillStyle = color;
    ctx.textBaseline = 'middle';  // consistent vertical alignment
    ctx.fillText(text, Math.round(x), Math.round(y));
}
```

**Minimum font sizes:**
| Context | Minimum | Recommended |
|---------|---------|-------------|
| HUD labels | 11px | 12-14px |
| Background signs (primary) | 14px | 14-16px |
| Background signs (secondary) | 12px | 12-14px |
| Easter egg text | 10px | 10-12px |
| Score/timer | 14px | 16-20px |

**Below 10px:** Text becomes sub-pixel noise on standard displays. On non-DPR-fixed canvases, effective size is halved (5px rendered = invisible). Replace tiny text with visual symbols.

### 5. Performance Budgets

| Budget | Target | Warning | Critical |
|--------|--------|---------|----------|
| Frame time | <8ms | 8-12ms | >16ms (dropped frames) |
| Canvas API calls/frame | <500 | 500-1000 | >2000 |
| Active entities | <50 | 50-80 | >100 without caching |
| Active particles | <200 | 200-400 | >500 |
| Offscreen canvases | <100 | 100-200 | >200 (memory) |
| `drawImage()` calls/frame | <100 | 100-200 | >300 |

**Profiling method:** Chrome DevTools → Performance tab → record a boss fight (worst case). Check:
1. Frame time distribution (should be <8ms P95)
2. Long tasks (any single operation >5ms)
3. GC pauses (create objects outside render loop)

---

## When to Consider PixiJS Migration

| Stay on Canvas 2D | Migrate to PixiJS |
|-------------------|-------------------|
| Procedural art only, no sprites | Need GPU shader effects (bloom, blur, glow) |
| <50 entities on screen | >100 entities consistently |
| No real-time color filters | Need per-entity tint/filters |
| Frame time under 8ms | Frame time >12ms after caching |
| 7/10 visual quality is acceptable | Targeting 9/10 AAA browser quality |
| Zero dependencies requirement | OK with ~150KB gzipped dependency |

**Hybrid approach (recommended migration path):**
Draw procedurally to offscreen Canvas → upload as PixiJS texture → GPU compositing and filters. Preserves all existing procedural art code.

**Migration cost estimates:**
- Canvas 2D + optimize: 0h (additive improvements)
- Hybrid Canvas 2D + PixiJS: 23-35h
- Full PixiJS rewrite: 24-40h
- Full Phaser rewrite: 50-74h (NOT recommended — replaces working systems)

---

## Anti-Patterns

1. **No DPR handling** — The #1 visual quality killer. Everything looks blurry on Retina. This is not optional.
2. **`image-rendering: pixelated` on procedural art** — Forces nearest-neighbor on smooth vector drawing. Only correct for actual pixel art sprites.
3. **Using `ctx.canvas.width` after DPR fix** — Returns physical pixels (doubled). Use logical width/height instead.
4. **Sub-pixel text coordinates** — Causes blurry text. Always `Math.round()` text positions.
5. **Redrawing procedural entities every frame** — 100 API calls per entity × 20 entities = 2000 calls. Cache to offscreen canvas.
6. **Font sizes below 10px** — Illegible on standard displays, invisible on non-DPR canvases. Use visual symbols instead.
7. **Pre-optimizing before profiling** — Don't add sprite caching until you've measured a real bottleneck. DPR fix always comes first.
8. **Caching particles or backgrounds** — Cache keys change every frame, defeating the purpose. Only cache stable visuals (entity poses).
9. **Assuming Canvas 2D needs replacing** — Canvas 2D at 7/10 quality ceiling is sufficient for polished indie games. Migration is justified only when you need GPU effects or >100 entities.

---

## Checklist

Before shipping any rendering change, verify:

- [ ] `devicePixelRatio` is handled (canvas.width = logical × dpr)
- [ ] `canvas.style.width/height` set to logical dimensions (CSS lock)
- [ ] `ctx.scale(dpr, dpr)` called once after context creation
- [ ] No `image-rendering: pixelated` on procedural art canvases
- [ ] All `ctx.canvas.width` usages replaced with `logicalWidth` or `width / dpr`
- [ ] Text positions use `Math.round()` for integer coordinates
- [ ] `ctx.textBaseline = 'middle'` set for consistent vertical alignment
- [ ] No font sizes below 10px (replace with symbols if needed)
- [ ] Procedural entity draws cached to offscreen canvas (if >20 entities)
- [ ] Sprite cache keys include entity type, state, facing, and frame
- [ ] Offscreen canvases created at DPR-scaled dimensions
- [ ] Frame time profiled under worst-case scenario (boss fight)
- [ ] Canvas API calls/frame measured and within budget (<500)
