---
name: "2d-game-art"
description: "Reusable skill for 2D game art direction, procedural Canvas rendering, and visual polish in browser-based games"
domain: "visual-art"
confidence: "high"
source: "project-experience"
origin: "firstPunch (2026)"
has_reference: true
---

## Context
Art direction for 2D browser games using HTML5 Canvas. Developed through firstPunch, a beat 'em up with 100% procedural art. Patterns apply to any Canvas 2D game and partially to sprite-based games.

## Core Patterns

- **Display pipeline first** — Set up DPR scaling before art: `canvas.width = rect.width * dpr; ctx.scale(dpr, dpr)`. Never use `image-rendering: pixelated` for procedural art
- **Style guide as source of truth** — Lock: outline color (#222222), width (2px round), shading model (flat + highlight), palette (10-15 hex), proportions
- **Organic shapes via Bezier** — Single clean outline using `quadraticCurveTo` for curves
- **Separate path per shape** — One `beginPath()` per visual element prevents connecting outlines
- **State-preserving rendering** — Always `ctx.save()`/`restore()` around entities
- **Seeded random for stability** — Frame-stable procedural detail. No `Math.random()` in render
- **60-30-10 color rule** — 60% background (low sat), 30% characters (medium), 10% accents (high)
- **Parallax layers** — Sky static, far 0.2x, mid 0.5x, ground 1.0x camera scroll

## Key Examples

**VFX module:**
```javascript
class VFX {
    static drawShadow(ctx, x, y, width, jumpHeight) { /* ... */ }
    static createHitEffect(vfxInstance, x, y, intensity) { /* ... */ }
    update(dt) { /* age and remove */ }
    render(ctx) { /* draw all active */ }
}
```

**Damage number with outline:**
```javascript
ctx.strokeStyle = '#222222'; ctx.lineWidth = 3;
ctx.strokeText(text, x, y);
ctx.fillStyle = color; ctx.fillText(text, x, y);
```

## Anti-Patterns

- **Skipping DPR scaling** — #1 quality killer. Everything blurry on HiDPI
- **`image-rendering: pixelated` on procedural art** — Destroys curves
- **Pure black outlines (#000000)** — Too harsh, use #222222
- **Shared path for shapes** — Outlines connect incorrectly
- **`Math.random()` in render** — Flickers every frame
- **No proportion reference** — Scale inconsistency
