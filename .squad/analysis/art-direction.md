# SimpsonsKong — Art Direction & Visual Style Guide

**Author:** Boba (VFX/Art Specialist)  
**Date:** 2026-06-03  
**Status:** Active

---

## Primary Color Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Simpsons Yellow | 🟡 | `#FED90F` | Homer's skin, title text, UI highlights |
| Springfield Sky Blue | 🔵 | `#87CEEB` | Sky background, health bar backing |
| Grass Green | 🟢 | `#7CFC00` | Ground plane, stage floors |
| Outline Black | ⚫ | `#222222` | 2px character outlines (not pure black — too harsh) |
| White | ⚪ | `#FFFFFF` | Eyes, highlights, flash effects |

## Secondary Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Homer Blue (pants) | 🔵 | `#4169E1` | Homer's clothing |
| Homer White (shirt) | ⚪ | `#F5F5F5` | Homer's shirt — slightly off-white |
| Enemy Red | 🔴 | `#E74C3C` | Enemy health bars, damage indicators |
| UI Gold | 🟡 | `#F1C40F` | Score text, combo counter |
| UI Dark | ⬛ | `#2C3E50` | UI panel backgrounds |
| Hit Flash White | ⚪ | `#FFFFEE` | Impact starburst center |
| Hit Flash Yellow | 🟡 | `#FFD700` | Impact starburst rays |
| KO Stars Yellow | 🟡 | `#FFEC8B` | KO star particles |
| Danger Red | 🔴 | `#FF4444` | Low health warning, critical hits |

## Outline Approach

- **2px dark outlines** (`#222222`) on all character shapes for readability against any background
- Outlines drawn *under* fill (stroke before fill, or separate outline pass)
- Line cap: `round` — gives a softer, more cartoon-like feel
- Line join: `round` — avoids harsh corners on limbs

## Shading Model

- **Flat colors only** — no Canvas gradients (keeps rendering fast and clean)
- **One highlight layer** per major body part: a lighter shade at ~20% opacity overlaid on the upper portion
- Example: Homer's belly gets a `rgba(255, 255, 255, 0.15)` highlight arc on the upper-left quadrant
- Shadow side implied by the ground shadow (VFX system), not by shading on the character itself

## Character Proportions

### Homer (Player)
- **Chunky/round** silhouette — big belly is the defining shape
- Head-to-body ratio: ~1:2.5 (big head, Simpsons style)
- Short legs, wide stance for stability
- Arms slightly short — reach comes from attack hitbox extension
- Belly protrudes forward — key readability shape even at small sizes

### Enemies (Generic Thugs)
- **Taller and leaner** than Homer — contrast makes Homer feel heavier/stronger
- Narrower shoulders, longer legs
- Slightly hunched posture (menacing)
- Color-coded by type (palette swap approach for variety without new art)

## Effects Style

- **Comic-book inspired** — bold, readable at speed
- **Starburst shapes** for hit impacts: 4-6 radiating lines from center point
- **Speed lines** behind moving characters during dashes/knockback
- **Bold, saturated colors** — no pastels in effects (they need to pop)
- **Short lifetimes** — effects last 80-120ms max, fast in/fast out
- **Scale-up then fade** animation curve — effects grow to full size in ~2 frames, then alpha-fade over remaining frames

## Canvas Rendering Notes

- All art is procedural Canvas 2D — no external images
- Use `ctx.save()` / `ctx.restore()` around all entity rendering
- Shadow ellipses at character feet for 2.5D depth (see `VFX.drawShadow()`)
- Screen shake via camera offset, not entity position changes
- Z-ordering by Y position (entities lower on screen render on top)
