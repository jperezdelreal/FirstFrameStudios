---
name: "2d-game-art"
description: "Reusable skill for 2D game art direction, procedural Canvas rendering, and visual polish in browser-based games"
domain: "visual-art"
confidence: "high"
source: "project-experience"
origin: "firstPunch (2026)"
---

## Context

This skill covers art direction for 2D browser games using HTML5 Canvas. It was developed through building firstPunch — a beat 'em up with 100% procedural art (no external images). The patterns apply to any Canvas 2D game and partially to sprite-based games.

## Patterns

### 1. Display Pipeline First, Art Second

**The most important rule.** Before drawing anything, set up correct Canvas scaling:

```javascript
function setupCanvas(canvas) {
    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    const ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
    return ctx;
}
```

Never use `image-rendering: pixelated` for procedural art. It destroys anti-aliased curves and gradients. Only use it for actual pixel art with integer scaling.

Handle `window.resize` to recalculate canvas dimensions and re-apply DPR scaling.

### 2. Style Guide as Source of Truth

Create an `art-direction.md` before any render code. Lock these values:

| Decision | Example | Why It Matters |
|----------|---------|---------------|
| Outline color | `#222222` (not pure black) | Softer, more cartoon-like; pure black is too harsh |
| Outline width | `2px` with `round` cap/join | Consistent thickness, no sharp corners |
| Shading model | Flat + one highlight layer (20% white) | Fast to render, easy to maintain consistency |
| Palette | 10-15 locked hex codes | Prevents color drift across multiple artists/agents |
| Proportion reference | All entities at correct relative scale | Prevents the "giant character next to tiny building" problem |

Every visual contributor must reference this document. Changes to it require explicit approval.

### 3. Procedural Canvas Art Patterns

#### Organic Shapes via Bezier Curves
```javascript
// Belly bulge (better than overlapping ellipses — single clean outline)
ctx.beginPath();
ctx.moveTo(left, top);
ctx.quadraticCurveTo(left - bulge, midY, left, bottom);
ctx.lineTo(right, bottom);
ctx.quadraticCurveTo(right + bulge, midY, right, top);
ctx.closePath();
ctx.fill();
ctx.stroke(); // single clean outline around entire shape
```

#### Separate Path Per Shape for Clean Outlines
```javascript
// WRONG: Two eyes in one path — outline connects them
ctx.beginPath();
ctx.arc(leftEyeX, eyeY, r, 0, TAU);
ctx.arc(rightEyeX, eyeY, r, 0, TAU);
ctx.fill();
ctx.stroke(); // ← draws line BETWEEN eyes

// RIGHT: Separate beginPath per eye
ctx.beginPath();
ctx.arc(leftEyeX, eyeY, r, 0, TAU);
ctx.fill();
ctx.stroke();
ctx.beginPath();
ctx.arc(rightEyeX, eyeY, r, 0, TAU);
ctx.fill();
ctx.stroke();
```

#### State-Preserving Rendering
```javascript
// ALWAYS save/restore around entity rendering
ctx.save();
ctx.translate(entity.x, entity.y);
if (entity.facing === -1) ctx.scale(-1, 1); // flip horizontally
// ... draw entity ...
ctx.restore(); // prevents leaking transforms, alpha, styles
```

#### Seeded Random for Stable Procedural Detail
```javascript
// Frame-stable random (same input = same output, no flicker)
function seededRandom(seed) {
    return (Math.sin(seed * 127.1 + 311.7) * 43758.5453) % 1;
}
// Use for: lit windows, crack positions, grass blade angles
```

### 4. Color Theory for Games

**The 60-30-10 Rule:**
- 60% dominant (background, large surfaces) — low saturation
- 30% secondary (characters, props) — medium saturation  
- 10% accent (UI, effects, key objects) — high saturation

**Saturation Depth Rule:**
- Foreground: 100% saturation
- Mid-ground: 60-70% saturation
- Far background: 30-40% saturation

**Readability hierarchy:** Brightest/highest-contrast elements read first. Player character must always be the highest-contrast element on screen.

### 5. Animation Essentials (The Big 4)

| Principle | Game Application | Implementation |
|-----------|-----------------|----------------|
| **Squash & Stretch** | Landing compression, jump elongation | `ctx.scale(1/factor, factor)` with timer |
| **Anticipation** | Attack wind-up, jump crouch | State machine: `windup → active → recovery` |
| **Follow-through** | Arm overshoot, hair lag, belly bounce | Damped spring: `vel += (target - current) * stiff - vel * damp` |
| **Timing** | Fast attacks (4 frames), heavy attacks (10 frames) | Frame counters with easing curves |

### 6. VFX as Shared Module

Create a central VFX system that all entities use:

```javascript
// Pattern: static factory methods + instance management
class VFX {
    static drawShadow(ctx, x, y, width, jumpHeight) { /* ... */ }
    static createHitEffect(vfxInstance, x, y, intensity) { /* ... */ }
    static createDamageNumber(vfxInstance, x, y, value, isCombo) { /* ... */ }
    
    addEffect(effect) { this.effects.push(effect); }
    update(dt) { /* age and remove expired effects */ }
    render(ctx) { /* draw all active effects */ }
}
```

Benefits: consistent style, no duplication, easy to adjust all effects globally.

### 7. Visual Hierarchy Enforcement

```
Priority 1: PLAYER → highest contrast, most saturated, always visible
Priority 2: THREATS → slightly lower contrast than player, distinct silhouettes
Priority 3: UI/FEEDBACK → screen-space elements, damage numbers (world-space but short-lived)
Priority 4: INTERACTABLES → lower saturation than characters, clear shape language
Priority 5: BACKGROUND → lowest saturation, slowest animation, never competes
```

**The squint test:** Blur your eyes. If you can still identify player, enemies, and health bar, hierarchy works.

### 8. Parallax Background Layers

```javascript
// Three-layer system with depth-appropriate detail
function renderBackground(ctx, cameraX, screenWidth) {
    renderSky(ctx);                                    // static (no parallax)
    renderFarLayer(ctx, cameraX * 0.2, screenWidth);   // distant landmarks, desaturated
    renderMidLayer(ctx, cameraX * 0.5, screenWidth);   // buildings, medium detail
    renderGround(ctx, cameraX * 1.0, screenWidth);     // road/sidewalk, full detail
    // After entities: renderForeground(ctx, cameraX * 1.3, screenWidth);
}
```

Far layer should have reduced `globalAlpha` (0.65) and lower saturation for atmospheric perspective.

### 9. Resolution-Independent UI

```javascript
// Position UI relative to viewport, not world coordinates
const margin = 20; // logical pixels
const healthBarX = margin;
const healthBarY = margin;
const scoreX = screenWidth - margin;

// Scale text based on viewport
const fontSize = Math.max(16, screenHeight * 0.03);
ctx.font = `bold ${fontSize}px sans-serif`;
```

### 10. When to Switch from Procedural to Sprites

| Signal | Threshold |
|--------|-----------|
| Entity render code length | >200 lines per entity |
| Animation states needed | >4 distinct poses |
| Art requires textures | Wood grain, fabric, stone |
| Second artist joins | Sprites are parallelizable, render code is not |
| Character redesign time | >2 hours per character |

The hybrid approach works well: sprites for characters, procedural for VFX/UI/backgrounds.

## Examples

### Good: Consistent Outline System
```javascript
// Set once, use everywhere
const OUTLINE = '#222222';
const OUTLINE_WIDTH = 2;

function setupOutline(ctx) {
    ctx.strokeStyle = OUTLINE;
    ctx.lineWidth = OUTLINE_WIDTH;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
}
```

### Good: Effect with Ease-Out Fade
```javascript
function createHitEffect(x, y) {
    return {
        x, y,
        lifetime: 0.1,
        age: 0,
        render(ctx) {
            const t = this.age / this.lifetime;
            const alpha = 1 - t * t; // ease-out: fast start, slow end
            const scale = 1 + t * 0.5; // grow slightly
            ctx.globalAlpha = alpha;
            ctx.save();
            ctx.translate(this.x, this.y);
            ctx.scale(scale, scale);
            // ... draw starburst ...
            ctx.restore();
            ctx.globalAlpha = 1;
        }
    };
}
```

### Good: Damage Number with Text Outline
```javascript
ctx.font = `bold ${fontSize}px sans-serif`;
ctx.textAlign = 'center';
// Dark outline for readability against any background
ctx.strokeStyle = '#222222';
ctx.lineWidth = 3;
ctx.lineJoin = 'round';
ctx.strokeText(text, x, y);
// Bright fill on top
ctx.fillStyle = color;
ctx.fillText(text, x, y);
```

## Anti-Patterns

- **Skipping DPR scaling** — Makes ALL art look blurry/cheap on HiDPI displays. This is the #1 "cutre" cause. Always implement before any art work.
- **`image-rendering: pixelated` on procedural art** — Destroys anti-aliased curves. Only for actual pixel art with integer scaling.
- **Pure black outlines (`#000000`)** — Too harsh for cartoon styles. Use `#222222` or `#1A1A1A` for softer look.
- **Sharing a single path for multiple shapes** — Outline connects shapes. Use separate `beginPath()` per visual element.
- **Hardcoded pixel dimensions** — Prevents scaling. Use proportion constants relative to a reference unit.
- **Math.random() for visual detail** — Flickers every frame. Use seeded random for stable procedural detail.
- **Gradient shading in a flat-shaded game** — Style breaks destroy quality perception. Pick ONE shading model and enforce it everywhere.
- **Entity-specific VFX code** — Leads to inconsistent effects. Centralize all VFX in a shared module.
- **Text below 10px logical** — Illegible on standard displays, invisible on HiDPI. Minimum 10px for UI, 12px for world text.
- **Same saturation across all depth layers** — Flattens the scene. Use saturation depth rule (100% / 70% / 40%).
- **Reviewing art changes as code diffs** — A correct-looking bezier change can be visually wrong. Always review with screenshots.
- **No proportion reference sheet** — Each entity drawn in isolation leads to scale inconsistency. Create a reference with all entities at correct relative size on Day 1.
