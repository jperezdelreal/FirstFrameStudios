# Rendering Technology Research — firstPunch

**Author:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Status:** Complete  
**Context:** User feedback that current Canvas 2D graphics look "cutre" (cheap/tacky). Character/car scale wrong, signs look low-res, overall quality far from AAA browser game standard.

---

## Current Architecture Analysis

### What We Have Now
- **Canvas:** Fixed 1280×720, no devicePixelRatio handling
- **Rendering:** 100% procedural Canvas 2D — zero bitmap assets
- **Per-frame cost:** ~150-250 canvas API calls (fillRect, arc, beginPath, fillText, etc.)
- **Entity rendering:** ~60-100 canvas calls per character (head, body, limbs, face expressions, shadow)
- **Background:** 3-layer parallax (far/mid/foreground) with procedural buildings, signs, text
- **VFX:** Particle system + effect layer (hit flashes, damage numbers, motion trails, screen flash)
- **Text:** 8-16px sans-serif for signs, 14-28px for HUD — no font loading, no anti-aliasing control
- **No HiDPI:** Canvas renders at CSS pixels, not device pixels. On a 2× Retina display, every pixel is 4× blurry.

### Root Causes of "Cutre" Look
1. **No devicePixelRatio scaling** — Text, lines, and shapes render blurry on modern displays. This is the #1 fixable issue.
2. **Tiny procedural text** — 8-16px sans-serif for building signs looks pixelated even at 1×
3. **No sprite caching** — Characters redrawn from scratch every frame (~100 API calls per entity × 20 entities = 2000 calls/frame)
4. **No post-processing** — No glow, blur, bloom, or color grading. Raw shapes look flat.
5. **Fixed 1280×720** — No resolution-independent design; doesn't scale to 1920×1080 or 4K

---

## Option 1: Stay on Canvas 2D + Optimize

### What Canvas 2D CAN Achieve
Canvas 2D is more capable than most developers realize:
- **Gradients & patterns:** Linear/radial gradients, pattern fills for textures
- **Compositing:** `globalCompositeOperation` enables additive blending, screen, multiply, etc.
- **Shadows:** `shadowBlur`, `shadowColor` for glow effects (expensive but usable sparingly)
- **Image smoothing:** `imageSmoothingEnabled`, `imageSmoothingQuality` for anti-aliasing control
- **Paths & curves:** Bezier curves, quadratic curves for smooth character outlines
- **Filters:** `ctx.filter = 'blur(4px)'` — CSS-style filters on canvas (modern browsers)
- **OffscreenCanvas:** Pre-render complex entities to offscreen canvases, blit as images

### HiDPI Fix (Applicable to ALL Options)
```javascript
const dpr = window.devicePixelRatio || 1;
const rect = canvas.getBoundingClientRect();
canvas.width = rect.width * dpr;
canvas.height = rect.height * dpr;
ctx.scale(dpr, dpr);
canvas.style.width = `${rect.width}px`;
canvas.style.height = `${rect.height}px`;
```
**Impact:** Immediately fixes blurry text/lines. Single biggest visual quality improvement possible. Works on Canvas 2D with zero migration.

### Sprite Caching Strategy
```javascript
// Pre-render character to offscreen canvas ONCE per state change
const spriteCache = new Map();
function getCachedSprite(entity, state, frame) {
    const key = `${entity.type}_${state}_${frame}_${entity.facing}`;
    if (!spriteCache.has(key)) {
        const offscreen = document.createElement('canvas');
        offscreen.width = entity.width * dpr;
        offscreen.height = entity.height * dpr;
        const octx = offscreen.getContext('2d');
        octx.scale(dpr, dpr);
        entity.drawProcedural(octx); // draw once
        spriteCache.set(key, offscreen);
    }
    return spriteCache.get(key);
}
// Then in render loop: ctx.drawImage(cached, x, y, w, h);
```
**Impact:** Reduces per-entity cost from ~100 API calls to 1 `drawImage` call. For 20 entities, that's 2000 → 20 calls. Massive performance improvement.

### Performance Ceiling
| Scenario | Canvas 2D (no cache) | Canvas 2D (cached) |
|----------|---------------------|---------------------|
| 20 entities + BG + VFX | ~2500 calls, ~12ms/frame | ~200 calls, ~2ms/frame |
| 50 entities + effects | ~6000 calls, frame drops | ~500 calls, solid 60fps |
| Post-processing (blur/glow) | ctx.filter is slow | Usable sparingly |
| Particle count limit | ~200 before drops | ~500+ with cached sprites |

### Visual Quality Ceiling
- **With HiDPI + caching + gradients + better procedural art:** Can reach "polished indie" quality (think Castle Crashers, Newgrounds flash-era upgraded)
- **Cannot achieve:** Real-time blur/glow on many elements, shader-based distortion, GPU-accelerated particle effects, blend modes at scale
- **Realistic ceiling:** 7/10 visual quality — good for stylized art, limited for AAA effects

### Pros
- ✅ Zero migration cost — all improvements are additive
- ✅ No dependencies — no CDN load, no version conflicts
- ✅ Instant page load — no library download
- ✅ Full control — we own every pixel
- ✅ HiDPI fix is trivial
- ✅ Sprite caching gives 10× performance gain

### Cons
- ❌ No GPU acceleration — all rendering is CPU-bound
- ❌ No real shaders — can't do bloom, distortion, chromatic aberration
- ❌ No sprite batching — each drawImage is a separate GPU upload
- ❌ Post-processing is expensive (ctx.filter triggers software rendering)
- ❌ Canvas 2D text rendering quality is platform-dependent
- ❌ Harder to achieve "wow factor" visual effects

### Migration Cost: **0 hours** (improvements are additive)

---

## Option 2: PixiJS (WebGL Renderer)

### What Is PixiJS?
PixiJS is a 2D WebGL rendering engine (with Canvas 2D fallback). Current version: **v8.16.0**. It provides GPU-accelerated sprite rendering, shader support, filter effects, and particle systems.

### What It Gives Us Over Canvas 2D
- **GPU-accelerated rendering:** All sprites rendered via WebGL — 10-100× faster than Canvas 2D for sprite-heavy scenes
- **Sprite batching:** Multiple sprites using the same texture are drawn in a single GPU draw call
- **Built-in filters:** Blur, glow, color matrix, displacement, distortion — all GPU-accelerated
- **Blend modes:** Additive, screen, multiply — proper compositing at zero cost
- **Particle containers:** Optimized for thousands of particles at 60fps
- **Texture management:** Atlas support, resolution scaling, mipmap generation
- **Render textures:** Render to texture for post-processing, off-screen composition

### Procedural Drawing Compatibility
PixiJS has a `Graphics` class that provides a Canvas-like API for procedural drawing:
```javascript
const graphics = new PIXI.Graphics();
graphics.circle(0, 0, 50).fill(0xFFD700);
graphics.rect(-20, -30, 40, 60).fill(0x0000FF);
```
**However:** Graphics objects are re-tesselated every frame if modified. For best performance, draw procedurally to an offscreen Canvas, then use that as a PixiJS texture. This is the hybrid approach (Option 5).

### No-Build-Step Constraint
PixiJS v8 provides ESM builds via CDN:
```html
<script type="module">
import * as PIXI from 'https://cdn.jsdelivr.net/npm/pixi.js@8.16.0/dist/pixi.mjs';
</script>
```
**⚠️ Caveat:** PixiJS v8 has many sub-dependencies (earcut, eventemitter3, etc.). The CDN ESM bundle may have import map issues without a bundler. The UMD build (`pixi.js`) works reliably:
```html
<script src="https://cdn.jsdelivr.net/npm/pixi.js@8.16.0/dist/pixi.js"></script>
<script type="module">
const { Application, Sprite, Graphics } = globalThis.PIXI;
</script>
```
**Verdict:** Works without a build step, but ESM imports from CDN may require an import map. UMD global works cleanly. **This is a minor friction point, not a blocker.**

### Performance
| Scenario | PixiJS Performance |
|----------|-------------------|
| 20 sprites | Trivial, <1ms |
| 100 sprites | Easy, ~2ms |
| 1000 sprites | Comfortable at 60fps |
| 10,000 sprites | ~30fps (ParticleContainer: 60fps) |
| Filters (blur on 5 elements) | <1ms GPU |
| Full-screen post-process | ~2-3ms GPU |

### Bundle Size
- **Full bundle (UMD, minified):** ~500KB (~150KB gzipped)
- **ESM tree-shaken:** ~200-300KB depending on features used
- **Impact:** Adds ~150KB to initial page load (gzipped). Acceptable for a game.

### Migration Cost
Our codebase changes needed:
1. **Renderer class:** Replace Canvas 2D context calls with PixiJS Container/Sprite system (~4-8 hours)
2. **Entity rendering:** Convert procedural drawing to PixiJS Graphics or pre-rendered textures (~8-12 hours)
3. **Background system:** Convert parallax layers to PixiJS TilingSprite or Container (~4-6 hours)
4. **VFX system:** Replace canvas-based effects with PixiJS filters + particles (~4-6 hours)
5. **HUD:** Convert to PixiJS Text objects (~2-4 hours)
6. **Game loop integration:** PixiJS has its own ticker; need to reconcile with our fixed-timestep loop (~2-4 hours)

**Total: ~24-40 hours (3-5 days)**

### Pros
- ✅ GPU-accelerated — massive performance headroom
- ✅ Built-in filters (blur, glow, displacement) — instant AAA effects
- ✅ Sprite batching — efficient rendering at scale
- ✅ Well-maintained — active development, large community
- ✅ HiDPI handled automatically
- ✅ Particle system built-in

### Cons
- ❌ ~500KB bundle size
- ❌ ESM CDN usage has friction (import maps needed for v8)
- ❌ 24-40 hour migration cost
- ❌ Learning curve for PixiJS scene graph (Containers, DisplayObjects)
- ❌ Our custom game loop must reconcile with PixiJS ticker
- ❌ Procedural drawing → Graphics objects is a different API than Canvas 2D

---

## Option 3: Phaser (Game Framework)

### What Phaser Adds Beyond PixiJS
Phaser 3 (v3.90.0) is a complete game framework that includes:
- **Rendering:** WebGL + Canvas 2D (its own renderer, not PixiJS since Phaser 3)
- **Physics:** Arcade Physics (AABB), Matter.js (full rigid body), Impact
- **Scene management:** Built-in scene state machine with preload/create/update lifecycle
- **Input:** Keyboard, mouse, touch, gamepad — all handled
- **Audio:** Web Audio API integration with spatial audio
- **Tweens:** Full tweening engine with easing functions
- **Cameras:** Built-in camera system with zoom, shake, fade, follow
- **Tilemaps:** Tiled map editor support
- **Animation:** Sprite animation manager

### Would It REPLACE Our Custom Engine?
**Yes — almost entirely.** Phaser provides:
- Scene management → replaces our `Game.switchScene()` + transition system
- Input handling → replaces our `Input` class
- Camera → replaces our `Renderer.save/restore` + camera + shake + zoom
- Physics → could replace our `Combat.checkCollision` rectangle checks
- Audio → replaces our `Audio` + `Music` classes
- Tweens → replaces manual lerp code in HUD, VFX
- Animation → replaces our `AnimationController`

**What we'd keep:** Game design logic (enemy AI, wave system, combo system, combat rules).

### Migration Cost
This is essentially a **full engine rewrite**:
1. Port all scenes to Phaser Scene lifecycle (~8-12 hours)
2. Port entities to Phaser GameObjects (~12-16 hours)
3. Port rendering to Phaser's drawing API (~8-12 hours)
4. Port input to Phaser input manager (~2-4 hours)
5. Port audio to Phaser audio (~4-6 hours)
6. Port VFX/particles to Phaser particles (~4-6 hours)
7. Port camera/UI to Phaser camera + UI (~4-6 hours)
8. Debug and fix integration issues (~8-12 hours)

**Total: ~50-74 hours (7-10 days)**

### No-Build-Step Constraint
Phaser provides a UMD build via CDN:
```html
<script src="https://cdn.jsdelivr.net/npm/phaser@3.90.0/dist/phaser.js"></script>
```
Also provides ESM: `dist/phaser.esm.js`. **Works without a build step.**

### Is It Overkill?
**Partially.** We already have a working engine with custom systems (combat, wave management, animation, input, audio, events). Phaser would replace systems we've already built and tested. The main value-add is:
- Better rendering (WebGL)
- Built-in particle effects
- Camera effects (fade, flash, shake built-in)
- Tween engine

But we'd lose the tight integration we've built between our systems. Our combo system, hitlag, attack buffering, and wave management would all need to be rewired to Phaser events.

### Bundle Size
- **Full UMD build:** ~1.2MB minified (~350KB gzipped)
- **Significantly heavier than PixiJS**

### Pros
- ✅ Complete framework — everything built-in
- ✅ Excellent documentation and examples
- ✅ Large community, actively maintained
- ✅ Built-in physics could simplify collision code
- ✅ Camera effects (shake, zoom, fade) are trivial
- ✅ Works via CDN

### Cons
- ❌ **Massive migration cost** (50-74 hours)
- ❌ **Replaces working systems** — we'd throw away tested code
- ❌ **1.2MB bundle** — heavy for a browser game
- ❌ **Opinionated** — must conform to Phaser's scene/object lifecycle
- ❌ **Overkill** — we don't need tilemaps, built-in physics, or Phaser's input system
- ❌ **Learning curve** — entire team must learn Phaser API

---

## Option 4: Three.js / WebGL Direct

### Assessment
- **Overkill for 2D.** Three.js is a 3D rendering engine. Using it for 2D requires:
  - Orthographic camera setup
  - Plane geometries for sprites
  - Custom shader materials for 2D effects
  - Fighting against 3D assumptions throughout the API
- **2.5D effects** (parallax depth, perspective distortion) are possible but achievable more easily with PixiJS displacement filters
- **Custom shaders** are powerful but require GLSL knowledge
- **Bundle size:** ~600KB minified
- **Migration cost:** Full rewrite (~80+ hours)

### When It Makes Sense
- True 3D or 2.5D perspective (not our case)
- Custom shader-heavy rendering (film grain, ray marching, etc.)
- When you need WebGPU support path

### Verdict: **Not recommended for firstPunch.** The 2D-in-3D overhead isn't justified when PixiJS provides all the 2D GPU features we need.

---

## Option 5: Hybrid — Canvas 2D Drawing + PixiJS Rendering

### Concept
Keep procedural Canvas 2D drawing for character art, but use PixiJS as the rendering compositor:
1. Draw each character state to an offscreen Canvas (procedural art, full control)
2. Convert offscreen Canvas to PixiJS Texture
3. PixiJS handles: compositing, blending, filters (blur, glow), particles, batching
4. Background layers as PixiJS TilingSprite or Container
5. HUD as PixiJS Text/Container on top layer

### Implementation
```javascript
// Draw character procedurally
const offscreen = document.createElement('canvas');
offscreen.width = 128; offscreen.height = 128;
const octx = offscreen.getContext('2d');
drawPlayer(octx, state, frame); // existing procedural code

// Convert to PixiJS texture
const texture = PIXI.Texture.from(offscreen);
const sprite = new PIXI.Sprite(texture);
sprite.position.set(entity.x, entity.y);

// Apply GPU effects
sprite.filters = [new PIXI.BlurFilter(2)]; // glow on hit
```

### Pros
- ✅ **Preserves ALL procedural drawing code** — minimal entity code changes
- ✅ **GPU compositing** — PixiJS handles the expensive part (blending, filters, particles)
- ✅ **Best of both worlds** — procedural art flexibility + GPU performance
- ✅ **Incremental migration** — can convert one system at a time
- ✅ **GPU filters for AAA effects** — blur, glow, displacement, color matrix
- ✅ HiDPI handled by PixiJS automatically

### Cons
- ❌ Canvas-to-texture conversion has a cost (~0.5ms per texture update)
- ❌ Need to manage texture lifecycle (create/update/destroy)
- ❌ Still requires PixiJS bundle (~500KB)
- ❌ Two rendering paradigms in one codebase (complexity)

### Migration Cost
1. Add PixiJS to project (CDN) (~1 hour)
2. Create PixiJS Application as render target (~2 hours)
3. Wrap entity rendering: draw to offscreen canvas → PixiJS sprite (~8-12 hours)
4. Convert background to PixiJS layers (~4-6 hours)
5. Port VFX to PixiJS filters + particles (~4-6 hours)
6. Port HUD to PixiJS Text (~2-4 hours)
7. Reconcile game loop (~2-4 hours)

**Total: ~23-35 hours (3-5 days)** — Similar to full PixiJS, but more of the entity code survives intact.

---

## Comparative Evaluation Matrix

| Criterion | Canvas 2D + Optimize | PixiJS | Phaser | Three.js | Hybrid (Canvas+PixiJS) |
|-----------|---------------------|--------|--------|----------|----------------------|
| **Visual Quality Ceiling** | 7/10 (polished indie) | 9/10 (AAA browser) | 9/10 (AAA browser) | 10/10 (overkill) | 9/10 (AAA browser) |
| **Migration Cost** | 0h (additive) | 24-40h (3-5 days) | 50-74h (7-10 days) | 80+h (rewrite) | 23-35h (3-5 days) |
| **No-Build-Step** | ✅ Native | ⚠️ UMD works, ESM needs importmap | ✅ UMD works | ⚠️ ESM needs importmap | ⚠️ UMD works |
| **Performance (60fps)** | Good (with caching) | Excellent | Excellent | Excellent | Excellent |
| **Learning Curve** | None | Medium (scene graph) | High (full framework) | High (3D concepts) | Medium (scene graph) |
| **Bundle Size** | 0KB | ~500KB (~150KB gz) | ~1.2MB (~350KB gz) | ~600KB (~180KB gz) | ~500KB (~150KB gz) |
| **HiDPI Fix** | Manual (trivial) | Automatic | Automatic | Automatic | Automatic |
| **Shader Effects** | ❌ | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Sprite Batching** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Risk** | Low | Medium | High | Very High | Medium |

---

## Immediate Fixes (Any Option)

These improvements should be applied **regardless of rendering technology choice**:

### 1. HiDPI/Retina Canvas Fix (1-2 hours)
```javascript
// In renderer.js constructor:
const dpr = window.devicePixelRatio || 1;
this.dpr = dpr;
canvas.style.width = canvas.width + 'px';
canvas.style.height = canvas.height + 'px';
canvas.width *= dpr;
canvas.height *= dpr;
this.ctx.scale(dpr, dpr);
// Internal coordinates remain 1280×720, rendering is crisp
```
**This alone fixes the "low-res signs" complaint.**

### 2. Pre-rendered Sprite Caching (4-6 hours)
Draw each character state/frame to an offscreen canvas once, then `drawImage()` each frame.
- Reduces per-entity render cost from ~100 → 1 canvas call
- Enables higher-detail procedural art (cost is amortized)
- Natural path toward PixiJS migration (cached canvas → texture)

### 3. Resolution-Independent Design (2-3 hours)
```javascript
// Design at 1920×1080 internal, scale to any screen
const DESIGN_WIDTH = 1920;
const DESIGN_HEIGHT = 1080;
const scale = Math.min(window.innerWidth / DESIGN_WIDTH, window.innerHeight / DESIGN_HEIGHT);
canvas.style.width = (DESIGN_WIDTH * scale) + 'px';
canvas.style.height = (DESIGN_HEIGHT * scale) + 'px';
canvas.width = DESIGN_WIDTH * dpr;
canvas.height = DESIGN_HEIGHT * dpr;
```

### 4. Better Procedural Art Techniques (ongoing)
- Use gradients instead of flat fills for depth
- Add subtle shadows under characters
- Use bezier curves instead of rectangles for body parts
- Increase sign font sizes and use custom web fonts
- Add outline strokes for character definition

---

## 🏆 RECOMMENDATION

### Phase 1 (Now): Canvas 2D Optimization — **Do This Immediately**
**Time: 8-12 hours**

Apply the three immediate fixes:
1. **HiDPI rendering** — fixes blurry text/signs (1-2h)
2. **Sprite caching** — 10× render performance gain (4-6h)
3. **Resolution-independent design** — scales to any screen (2-3h)

These are zero-risk, zero-dependency improvements that dramatically improve visual quality and performance. They also prepare the codebase for a future PixiJS migration by establishing the offscreen-canvas-to-sprite pattern.

### Phase 2 (When Needed): Hybrid Canvas + PixiJS Migration
**Time: 23-35 hours | Trigger: When we need GPU effects (bloom, glow, blur, particle storms)**

If after Phase 1 the visual quality still isn't "AAA enough," migrate to the hybrid approach:
1. Add PixiJS via CDN UMD script tag
2. Create PixiJS Application as the main render target
3. Convert cached offscreen canvases → PixiJS textures (minimal code change)
4. Add GPU filters for hit effects, screen transitions, particle effects
5. Keep all procedural drawing code — just render the output through PixiJS

**Why Hybrid over full PixiJS:** Preserves our procedural drawing investment. We don't have sprite sheets and aren't getting them. The hybrid approach gives us GPU acceleration where it matters (compositing, effects) while keeping our art pipeline intact.

**Why NOT Phaser:** We already have a working engine with custom systems. Phaser would replace code we've built and tested, at 2× the migration cost, for features we don't need (tilemaps, built-in physics, input system). It's the wrong tool for our situation.

**Why NOT Three.js:** Overkill. PixiJS gives us everything we need for 2D GPU rendering.

### Migration Plan (Phase 2)

```
Week 1 (Day 1-2): Setup
  - Add PixiJS UMD to index.html
  - Create PixiJSRenderer wrapper class
  - Reconcile game loop with PixiJS ticker
  - Verify basic rendering works

Week 1 (Day 3-5): Entity Migration
  - Convert entity offscreen canvases → PixiJS textures
  - Set up depth-sorted Container for game world
  - Verify all entity states render correctly

Week 2 (Day 1-2): Background + VFX
  - Convert parallax layers to PixiJS Containers
  - Port VFX effects to PixiJS filters
  - Port particle system to PixiJS ParticleContainer

Week 2 (Day 3-4): Polish
  - HUD → PixiJS Text objects
  - Screen transitions → PixiJS container alpha
  - Add new GPU effects (bloom on hits, screen distortion)
  - Performance testing and optimization

Week 2 (Day 5): Integration Testing
  - Full playthrough testing
  - Edge case verification
  - Performance profiling
```

---

## Appendix: Key Technical References

### Canvas 2D Optimization (MDN)
- Pre-render to offscreen canvas to avoid redundant draw calls
- Avoid floating-point coordinates (use Math.floor/Math.round)
- Use `{ alpha: false }` context option if no transparency needed
- `ctx.filter` supports CSS filter strings (blur, brightness, contrast)
- Multiple layered canvases for static vs dynamic content

### PixiJS v8 Key Features
- WebGPU support (future-proof)
- Improved asset loading and texture management
- Better tree-shaking for smaller bundles
- New Graphics API (more Canvas-like)
- Filter system with custom shaders
- ParticleContainer for 10K+ particles

### devicePixelRatio Handling
- `window.devicePixelRatio` returns the display's pixel density (1.0 for standard, 2.0 for Retina, up to 3.0+ for mobile)
- Canvas must be sized at `width * dpr × height * dpr` physical pixels
- Context must be scaled by `dpr` so drawing coordinates remain in CSS pixels
- CSS width/height must be set explicitly to prevent the browser from stretching
