# Visual Quality Audit V2 — "Why Does It Look Cutre?"

> Compressed from 16KB. Full: visual-quality-audit-v2-archive.md

**Author:** Boba (Art Director)  
**Date:** 2026-06-03  
---

## Executive Summary
The #1 reason the game looks "cutre" is **the canvas does not account for `window.devicePixelRatio`**. On any modern display (Retina MacBook = 2x, most Windows laptops = 1.25–1.5x, phones = 2–3x), the game renders at HALF or less resolution and gets upscaled by the browser, making everything blurry, blocky, and low-resolution. Combined with `image-rendering: pixelated` in CSS (which prevents smoothing), this produces the worst possible visual quality. Fixing DPR alone would make the game look 3–4× sharper instantly.
Beyond DPR, there are scale/proportion issues, unreadable text, and some art consistency gaps that compound the "cheap" feeling.
---

## Issue #1: HiDPI / Retina Canvas Resolution (CRITICAL — Severity 10/10)
### What's Wrong
The canvas is hardcoded to `1280x720` in `index.html` line 10:
### How Bad It Looks: 10/10
### The Fix
### Fixable on Canvas 2D? YES — trivial fix, massive impact.
---

## Issue #2: CSS Canvas Scaling Forces Pixelated Upscale (Severity 8/10)
### What's Wrong
`styles.css` lines 24–25:
### How Bad It Looks: 8/10
### The Fix
### Fixable on Canvas 2D? YES — CSS-only change.
---

## Issue #3: Text at Unreadable Font Sizes (Severity 7/10)
### What's Wrong
Multiple text draws use font sizes that are unreadable at 1280×720, and completely invisible on HiDPI:
| Location | File | Font Size | Text | Readability |
| Founder plaque | `background.js:888` | **5px** | "FOUNDER" | Invisible |
| I&S poster | `background.js:620` | **5px** | "I&S" | Invisible |
| graffiti tag graffiti | `background.js:493,635` | **8-9px** | "GRAFFITI" | Barely visible |
| Downtown sign | `background.js:305` | **9px** | "WELCOME TO" | Barely readable |
| Mayor billboard | `background.js:269` | **11px** | "VOTE MAYOR" | Borderline |
---

## Issue #4: Scale/Proportion Mismatch Between Layers (Severity 6/10)
### What's Wrong
Characters, buildings, and landmarks exist at contradictory scales:
### How Bad It Looks: 6/10
### The Fix
### Fixable on Canvas 2D? YES — constant tweaks, no rendering changes.
---

## Issue #5: Outline/Stroke Inconsistency Across Layers (Severity 4/10)
### What's Wrong
The art direction specifies `2px #222222` outlines with round caps for all elements. This is correctly applied to:
### How Bad It Looks: 4/10
### The Fix
### Fixable on Canvas 2D? YES — color constant changes.
---

## Issue #6: Missing Saturation Depth Hierarchy (Severity 5/10)
### What's Wrong
The visual modernization plan (Wave 5) identified this: foreground, mid-ground, and background all have similar color saturation. This flattens depth perception.
### How Bad It Looks: 5/10
### The Fix
### Fixable on Canvas 2D? YES — color value changes only.
---

## Issue #7: Title Screen Text Uses System Fonts (Severity 3/10)
### What's Wrong
All text throughout the game uses `"Arial Black", Arial, sans-serif` — a system font stack. While this is readable and available everywhere, it contributes to a "default/generic" look. Professional games use custom display fonts for titles and UI.
### How Bad It Looks: 3/10
### The Fix
### Fixable on Canvas 2D? YES — @font-face + CSS, then reference in Canvas font strings.
---

## Issue #8: Foreground Layer Too Transparent (Severity 3/10)
### What's Wrong
`background.js` foreground layer renders at `0.3 alpha` (per history.md Wave 7). Lampposts, fence, and hydrants are so transparent they're barely visible. Foreground elements should be partially opaque — enough to sell depth, not so faded they look like ghosts.
### How Bad It Looks: 3/10
### The Fix
### Fixable on Canvas 2D? YES — alpha constant change.
---

## Issue #9: Health/Status Text Too Small for Gameplay Scanning (Severity 4/10)
### What's Wrong
In `hud.js`, critical gameplay information is rendered at small sizes:
### How Bad It Looks: 4/10
### The Fix
### Fixable on Canvas 2D? YES — font size constants.
---

## Issue #10: Enemy Variant Visual Distinction at Game Speed (Severity 4/10)
### What's Wrong
Enemy variants differ by color and minor accessories:
### How Bad It Looks: 4/10
### The Fix
### Fixable on Canvas 2D? YES — dimension/proportion changes in enemy render.
---

## Priority Matrix
| Priority | Issue | Severity | Effort | Impact |
|---|---|---|---|---|
| **P0** | #1 HiDPI/DPR | 10/10 | 30min | Fixes 60% of "cutre" |
| **P0** | #2 CSS pixelated | 8/10 | 5min | Removes forced blockiness |
| **P1** | #3 Text sizes | 7/10 | 1hr | Makes signs/HUD readable |
| **P1** | #4 Scale proportions | 6/10 | 1hr | Fixes "toy world" feeling |
| **P1** | #6 Saturation hierarchy | 5/10 | 30min | Improves depth perception |
| **P2** | #5 Outline consistency | 4/10 | 30min | Polish consistency |
---

## The Honest Bottom Line
The game has **good procedural art** — Brawler is recognizable, buildings are charming, effects are polished. The art team's work is solid. The problem is **the rendering pipeline throws it all away** by displaying everything at half resolution with nearest-neighbor upscaling. It's like printing a high-quality poster on a fax machine.
Fix DPR + remove pixelated CSS = the game immediately looks 3–4× better. Everything else is polish on top.