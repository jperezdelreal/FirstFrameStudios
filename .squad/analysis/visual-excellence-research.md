# Visual Excellence Research — 2D Game Art & firstPunch Learnings

> Compressed from 25KB. Full: visual-excellence-research-archive.md

**Author:** Boba (Art Director)  
**Date:** 2026-06-03  
---

## Part 1 — Industry Research
### 1. What Award-Winning 2D Game Art Looks Like
The best 2D games share five traits regardless of art style:
| Game | Style | Why It Works |
| **Cuphead** | 1930s rubber-hose animation | Hand-drawn frames at 24fps, watercolor backgrounds, every frame is a painting. Total commitment to one aesthetic — no style breaks. |
| **Hollow Knight** | Hand-drawn vector | Limited palette per biome (3–5 core colors), incredible silhouette clarity, environmental storytelling through art alone. Players recognize every area by color. |
| **Celeste** | Pixel art + particle effects | Tiny sprites with massive personality via animation. Dust clouds, hair movement, and trail effects convey weight and speed. Minimal pixels, maximum expressiveness. |
| **Dead Cells** | 3D-rendered-to-2D sprites | Fluid 60fps animation with anticipation/follow-through on every action. Procedural levels but hand-crafted animation quality. |
| **Streets of Rage 4** | Hand-painted digital | Bold outlines, flat shading with one highlight layer, limited palette per character. Readability at combat speed — every attack reads instantly. |
---
---
---
---
---
---
---
---

## Part 2 — firstPunch Learnings
### The devicePixelRatio Disaster
**What happened:** The canvas was set to 1280×720 physical pixels but displayed in a CSS container that could be 2560×1440 on Retina screens. Zero `devicePixelRatio` references existed in the entire codebase. Additionally, `image-rendering: pixelated` was applied via CSS, forcing nearest-neighbor upscaling.
---
### Procedural Art Limitations — What Took Hours vs. Minutes
---
### Multi-Artist Coordination — How 4 Art Roles Worked
---
### Scale/Proportion Consistency — The Car/Building/Character Problem
---
---

## Part 3 — Future Project Guidelines
### Day 1 Art Decisions Checklist
Before writing a single line of render code:
### Sprite Sheet Pipeline — When to Switch
### Art Review Process