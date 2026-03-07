# Visual Quality Audit V2 — "Why Does It Look Cutre?"

**Author:** Boba (Art Director)  
**Date:** 2026-06-03  
**Verdict:** The game looks cheap for ONE dominant reason and several compounding ones.

---

## Executive Summary

The #1 reason the game looks "cutre" is **the canvas does not account for `window.devicePixelRatio`**. On any modern display (Retina MacBook = 2x, most Windows laptops = 1.25–1.5x, phones = 2–3x), the game renders at HALF or less resolution and gets upscaled by the browser, making everything blurry, blocky, and low-resolution. Combined with `image-rendering: pixelated` in CSS (which prevents smoothing), this produces the worst possible visual quality. Fixing DPR alone would make the game look 3–4× sharper instantly.

Beyond DPR, there are scale/proportion issues, unreadable text, and some art consistency gaps that compound the "cheap" feeling.

---

## Issue #1: HiDPI / Retina Canvas Resolution (CRITICAL — Severity 10/10)

### What's Wrong

The canvas is hardcoded to `1280x720` in `index.html` line 10:
```html
<canvas id="gameCanvas" width="1280" height="720"></canvas>
```

`src/engine/renderer.js` lines 3–6 simply read this:
```js
this.canvas = canvas;
this.ctx = canvas.getContext('2d');
this.width = canvas.width;   // 1280
this.height = canvas.height; // 720
```

**`window.devicePixelRatio` is referenced ZERO times in the entire codebase.** (grep confirms no matches.)

On a 2× Retina display, the canvas element is CSS-sized to fill the viewport (e.g., 2560×1440 CSS pixels) but the backing buffer is only 1280×720 physical pixels. The browser upscales 1280→2560, making every line, text glyph, and shape blurry.

### How Bad It Looks: 10/10

This is THE primary cause of the "low-res" complaint. Every single visual element — characters, buildings, text, effects — renders at half resolution on Retina/HiDPI. On a 15" MacBook Pro (2×), this turns sharp 2px outlines into fuzzy 1px blobs and makes 11px text into 5.5px mush.

### The Fix

In `renderer.js` constructor or in `main.js` at canvas init:
```js
const dpr = window.devicePixelRatio || 1;
canvas.width = 1280 * dpr;
canvas.height = 720 * dpr;
canvas.style.width = '1280px';
canvas.style.height = '720px';
ctx.scale(dpr, dpr);
// Keep this.width/this.height as 1280/720 (logical size)
```

Remove from `styles.css`:
```css
image-rendering: crisp-edges;
image-rendering: pixelated;
```
These force nearest-neighbor scaling which makes smooth Canvas 2D art look deliberately blocky. They're appropriate for pixel art games, NOT for procedural vector-style Canvas drawing.

### Fixable on Canvas 2D? YES — trivial fix, massive impact.

---

## Issue #2: CSS Canvas Scaling Forces Pixelated Upscale (Severity 8/10)

### What's Wrong

`styles.css` lines 24–25:
```css
image-rendering: crisp-edges;
image-rendering: pixelated;
```

These CSS properties tell the browser to use nearest-neighbor interpolation when upscaling the canvas. For a procedurally-drawn game with smooth curves, gradients, and text — this is the opposite of what you want. It makes:
- Diagonal lines look like staircases
- Text glyphs look chunky and aliased
- Curves on characters (belly, head) look blocky
- Gradients on health bars look banded

### How Bad It Looks: 8/10

Combined with Issue #1, this is devastating. Even without DPR fix, removing pixelated rendering would let the browser's bilinear filter smooth the upscale somewhat.

### The Fix

Remove both `image-rendering` lines. If a CRT/retro aesthetic is desired later, it should be done as a post-process shader, not via CSS.

### Fixable on Canvas 2D? YES — CSS-only change.

---

## Issue #3: Text at Unreadable Font Sizes (Severity 7/10)

### What's Wrong

Multiple text draws use font sizes that are unreadable at 1280×720, and completely invisible on HiDPI:

| Location | File | Font Size | Text | Readability |
|---|---|---|---|---|
| Jebediah plaque | `background.js:888` | **5px** | "JEBEDIAH" | Invisible |
| I&S poster | `background.js:620` | **5px** | "I&S" | Invisible |
| El Barto graffiti | `background.js:493,635` | **8-9px** | "EL BARTO" | Barely visible |
| Springfield sign | `background.js:305` | **9px** | "WELCOME TO" | Barely readable |
| Burns billboard | `background.js:269` | **11px** | "VOTE BURNS" | Borderline |
| Burns quote | `background.js:284` | **8px italic** | "Excellent..." | Unreadable |
| Style meter label | `hud.js:164` | **9px** | "STYLE" | Tiny |
| Style info | `hud.js:222` | **8px** | "Best. Combo. Ever." | Illegible |
| Style multiplier | `hud.js:232` | **10px** | "x5" | Small |
| Wave label | `hud.js:296` | **8px** | "WAVE" | Barely visible |

### How Bad It Looks: 7/10

Signs that should be charming Easter eggs are literally unreadable smudges. HUD labels that should communicate game state are too small to scan at a glance. On HiDPI without the DPR fix, these become sub-pixel noise.

### The Fix

- **Minimum font size: 12px** for any text the player should read
- **Background signs**: Increase to 14–16px for primary text, 12px for secondary
- **Easter eggs (I&S, Jebediah, El Barto)**: Increase to 10–12px minimum, or replace with visual symbols that read at small sizes
- **HUD labels**: Increase "STYLE", "WAVE" to 11–12px minimum
- Set `ctx.textBaseline = 'middle'` consistently (some draws omit it)

### Fixable on Canvas 2D? YES — font size changes only.

---

## Issue #4: Scale/Proportion Mismatch Between Layers (Severity 6/10)

### What's Wrong

Characters, buildings, and landmarks exist at contradictory scales:

**Player (foreground, 1× parallax):**
- Homer: 64×80px — walks on ground plane Y=400–600

**Mid-layer buildings (0.5× parallax — should read as "further away"):**
- Kwik-E-Mart: 210×140px
- Moe's: 170×125px
- Houses: 115–130px wide, 95–110px tall
- Elementary: 250×155px

**Far-layer landmarks (0.2× parallax — should read as "very far"):**
- Power Plant cooling tower: 130px wide, 180px tall
- Billboard: 110×55px
- Springfield sign: 130×35px

**The problem:** Buildings at 0.5× parallax scroll slower (suggesting distance) but their drawn size is only 1.5–3× larger than Homer. If Homer is supposed to be ~6 feet tall, a Kwik-E-Mart (a single-story convenience store) at 140px should be roughly 2× Homer's height (160px). That's close. But the Power Plant cooling towers at 180px (0.2× parallax, suggesting great distance) should be MUCH larger — cooling towers are 100+ feet tall. They look like garden sheds.

**Ground plane compression:**
- Walkable area: Y=400 to Y=600 (200px total depth)
- Homer height: 80px (40% of walkable depth)
- This makes Homer look enormous relative to the "street" he walks on

### How Bad It Looks: 6/10

It doesn't look overtly wrong at first glance because parallax sells some depth. But on closer inspection, the Power Plant looks like a toy, buildings feel like dollhouses, and Homer dominates the street in an uncanny way.

### The Fix

- **Far-layer landmarks**: Scale up 1.5–2×. Power Plant towers should be 250–300px tall, billboards 150×70px.
- **Consider increasing HORIZON** from 400 to 350 to give more vertical room for buildings to breathe and more ground plane for characters.
- **Ground plane**: Consider expanding walkable depth range from 200px to 250px (Y=380–630) to reduce the "Homer fills the street" effect.
- **Foreground hydrants** (background.js foreground layer): Currently drawn at similar size to background ones — should be 1.5× larger to sell depth.

### Fixable on Canvas 2D? YES — constant tweaks, no rendering changes.

---

## Issue #5: Outline/Stroke Inconsistency Across Layers (Severity 4/10)

### What's Wrong

The art direction specifies `2px #222222` outlines with round caps for all elements. This is correctly applied to:
- ✅ Player body parts (`player.js:644–648`)
- ✅ Enemy body parts (`enemy.js:374–378`)
- ✅ Building exteriors (OUTLINE constant in `background.js:34`)

But broken in:
- ❌ Power Plant uses `#6A6A6A` and `#555555` strokes (`background.js:320–352`) — grey instead of dark
- ❌ Jebediah statue uses `#4A6A4A` strokes (`background.js:901,910`) — green-tinted
- ❌ Smokestack uses `#555555` stroke (`background.js:352`) — lighter than standard
- ❌ Some window strokes drop to `lineWidth: 1` or `0.5` — inconsistent with 2px standard
- ❌ Brick lines in Elementary are `0.5px` (`background.js:654`) — nearly invisible

### How Bad It Looks: 4/10

Not immediately jarring but contributes to a "some things look polished, some don't" inconsistency that reads as unfinished.

### The Fix

- Replace all structural outlines with `OUTLINE` constant (`#222222`)
- Keep decorative strokes (brick lines, window cross-bars) at 1px but use `#444444` instead of near-invisible 0.5px
- Far-layer elements can use slightly lighter outlines (`#555555`) to suggest atmospheric perspective — but be intentional about it, not accidental

### Fixable on Canvas 2D? YES — color constant changes.

---

## Issue #6: Missing Saturation Depth Hierarchy (Severity 5/10)

### What's Wrong

The visual modernization plan (Wave 5) identified this: foreground, mid-ground, and background all have similar color saturation. This flattens depth perception.

**Current:**
- Player: Bright yellow (#FED90F), blue pants (#4169E1) — full saturation ✅
- Mid buildings: Bright teal (#2E8B8B), dark brown (#5C3A21), full green (#4A7A4A) — full saturation ❌
- Far landmarks: Grey (#8A8A8A) — correctly desaturated ✅ but too uniform
- Sky: Good gradient ✅

**Mid-layer buildings are too saturated** for their depth. They compete with player for visual attention.

### How Bad It Looks: 5/10

The eye doesn't know where to focus. Homer should pop against a slightly muted background. Instead, the Kwik-E-Mart's teal is almost as visually loud as Homer's yellow.

### The Fix

- **Mid-layer**: Reduce saturation by 30%. Kwik-E-Mart teal → desaturated teal (#5A9A9A). Moe's brown → muted (#6A4A31).
- **Far-layer**: Keep current greys, add subtle blue atmospheric tint
- **Foreground elements**: At 0.3 alpha already (good), no change needed

### Fixable on Canvas 2D? YES — color value changes only.

---

## Issue #7: Title Screen Text Uses System Fonts (Severity 3/10)

### What's Wrong

All text throughout the game uses `"Arial Black", Arial, sans-serif` — a system font stack. While this is readable and available everywhere, it contributes to a "default/generic" look. Professional games use custom display fonts for titles and UI.

The title "SIMPSONS KONG" at 72px in Arial Black (`title.js:196`) is functional but generic. The same font is reused for HUD labels, combo counter, menu items, and building signs.

### How Bad It Looks: 3/10

Not terrible — Arial Black is a decent bold display font. But it screams "web app" rather than "game." A single custom font for titles + one for body would elevate the feel significantly.

### The Fix

- Load one custom web font via @font-face for titles/headers (something with personality — hand-drawn, comic book, or Simpsons-inspired)
- Keep Arial/sans-serif for small labels and body text
- Alternative: If no custom font, use Canvas text path rendering with manual outlines/shadows to make the system font feel more designed

### Fixable on Canvas 2D? YES — @font-face + CSS, then reference in Canvas font strings.

---

## Issue #8: Foreground Layer Too Transparent (Severity 3/10)

### What's Wrong

`background.js` foreground layer renders at `0.3 alpha` (per history.md Wave 7). Lampposts, fence, and hydrants are so transparent they're barely visible. Foreground elements should be partially opaque — enough to sell depth, not so faded they look like ghosts.

### How Bad It Looks: 3/10

Subtle issue, but it means the depth layering (far → mid → near → foreground) that was carefully designed doesn't actually read. The foreground layer is nearly invisible.

### The Fix

- Increase foreground alpha to `0.5–0.6`
- Consider using silhouette (dark) foreground elements rather than transparent full-color ones
- Alternatively, darken foreground elements instead of making them transparent — dark lampposts at 0.8 alpha reads better than full-color at 0.3

### Fixable on Canvas 2D? YES — alpha constant change.

---

## Issue #9: Health/Status Text Too Small for Gameplay Scanning (Severity 4/10)

### What's Wrong

In `hud.js`, critical gameplay information is rendered at small sizes:
- Health text "100 / 100": `11px` (`hud.js:399`)
- "HOMER" label: `13px` (`hud.js:334`)
- Score label "SCORE": `11px` (`hud.js:437`)
- "LIVES" label: `11px` (`hud.js:416`)
- Wave dots: `5px radius` (`hud.js:244`)

At 1280×720 these are small. On HiDPI without DPR fix, they're micro-text.

### How Bad It Looks: 4/10

The HUD has good design (rounded panels, gradients, glow effects) but the information density is hurt by small text. Players need to squint to read their health value.

### The Fix

- Health text: 13–14px
- Labels: 14–15px
- Score value is good at 28px ✅
- Wave dots: 6–7px radius
- All HUD text benefits from DPR fix (Issue #1) more than individual size bumps

### Fixable on Canvas 2D? YES — font size constants.

---

## Issue #10: Enemy Variant Visual Distinction at Game Speed (Severity 4/10)

### What's Wrong

Enemy variants differ by color and minor accessories:
- Normal: purple suit (#663399)
- Tough: dark red (#8B0000) + scar
- Fast: blue (#2196F3) + hoodie
- Heavy: green (#2E7D32) + bandana + wider body

At 48×76 pixels on a scrolling screen in combat, distinguishing "purple guy" from "red guy" requires conscious attention. The silhouettes are too similar — all are humanoid figures with the same proportions except heavy (slightly wider).

### How Bad It Looks: 4/10

Functionally adequate — you CAN tell them apart if you look. But in a beat 'em up, enemy type recognition should be instant (< 100ms). SoR4 and TMNT achieve this with wildly different silhouettes, not just color swaps.

### The Fix

- **Heavy**: Make significantly wider (1.5× current) and shorter — "tank" reads at a glance
- **Fast**: Add motion lines or lean the sprite more aggressively, make thinner
- **Tough**: Add a hat or different head shape, not just a subtle scar
- **Boss**: Already distinct with devil-horn hair — good ✅

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
| **P2** | #9 HUD text size | 4/10 | 30min | Readability at speed |
| **P2** | #10 Enemy distinction | 4/10 | 2hr | Gameplay readability |
| **P3** | #8 Foreground alpha | 3/10 | 10min | Depth layer visibility |
| **P3** | #7 Custom font | 3/10 | 1hr | Professional feel |

**Total estimated effort:** ~7.5 hours  
**P0 alone (DPR + CSS):** ~35 minutes for 60%+ visual improvement

---

## The Honest Bottom Line

The game has **good procedural art** — Homer is recognizable, buildings are charming, effects are polished. The art team's work is solid. The problem is **the rendering pipeline throws it all away** by displaying everything at half resolution with nearest-neighbor upscaling. It's like printing a high-quality poster on a fax machine.

Fix DPR + remove pixelated CSS = the game immediately looks 3–4× better. Everything else is polish on top.
