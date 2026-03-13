# Rendering Technology Research — firstPunch

> Compressed from 22KB. Full: rendering-tech-research-archive.md

**Author:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
---

## Current Architecture Analysis
### What We Have Now
- **Canvas:** Fixed 1280×720, no devicePixelRatio handling
### Root Causes of "Cutre" Look
---

## Option 1: Stay on Canvas 2D + Optimize
### What Canvas 2D CAN Achieve
Canvas 2D is more capable than most developers realize:
### HiDPI Fix (Applicable to ALL Options)
### Sprite Caching Strategy
### Performance Ceiling
| Scenario | Canvas 2D (no cache) | Canvas 2D (cached) |
| 20 entities + BG + VFX | ~2500 calls, ~12ms/frame | ~200 calls, ~2ms/frame |
| 50 entities + effects | ~6000 calls, frame drops | ~500 calls, solid 60fps |
---

## Option 2: PixiJS (WebGL Renderer)
### What Is PixiJS?
PixiJS is a 2D WebGL rendering engine (with Canvas 2D fallback). Current version: **v8.16.0**. It provides GPU-accelerated sprite rendering, shader support, filter effects, and particle systems.
### What It Gives Us Over Canvas 2D
### Procedural Drawing Compatibility
### No-Build-Step Constraint
| Scenario | PixiJS Performance |
| 20 sprites | Trivial, <1ms |
| 100 sprites | Easy, ~2ms |
---

## Option 3: Phaser (Game Framework)
### What Phaser Adds Beyond PixiJS
Phaser 3 (v3.90.0) is a complete game framework that includes:
### Would It REPLACE Our Custom Engine?
### Migration Cost
### No-Build-Step Constraint
---

## Option 4: Three.js / WebGL Direct
### Assessment
- **Overkill for 2D.** Three.js is a 3D rendering engine. Using it for 2D requires:
### When It Makes Sense
### Verdict: **Not recommended for firstPunch.** The 2D-in-3D overhead isn't justified when PixiJS provides all the 2D GPU features we need.
---

## Option 5: Hybrid — Canvas 2D Drawing + PixiJS Rendering
### Concept
Keep procedural Canvas 2D drawing for character art, but use PixiJS as the rendering compositor:
### Implementation
### Pros
### Cons
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
---

## Immediate Fixes (Any Option)
These improvements should be applied **regardless of rendering technology choice**:
### 1. HiDPI/Retina Canvas Fix (1-2 hours)
### 2. Pre-rendered Sprite Caching (4-6 hours)
### 3. Resolution-Independent Design (2-3 hours)
### 4. Better Procedural Art Techniques (ongoing)
---

## 🏆 RECOMMENDATION
### Phase 1 (Now): Canvas 2D Optimization — **Do This Immediately**
**Time: 8-12 hours**
### Phase 2 (When Needed): Hybrid Canvas + PixiJS Migration
### Migration Plan (Phase 2)
---

## Appendix: Key Technical References
### Canvas 2D Optimization (MDN)
- Pre-render to offscreen canvas to avoid redundant draw calls
### PixiJS v8 Key Features
### devicePixelRatio Handling