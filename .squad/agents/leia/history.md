# Leia — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current state:** Springfield background with Power Plant, Kwik-E-Mart, Moe's, parallax layers, foreground elements.

## Learnings

- Building pattern array in background.js tiles across the world; adding new types requires: array entry, switch case, draw method — all three.
- Far layer uses `cameraX * 0.8` offset with `PLANT_SPACING` to tile; new far-layer elements (billboards, signs) should anchor relative to plant positions to avoid overlap.
- `seededRandom(x * factor + offset)` keeps frame-stable randomness for per-building variation (graffiti, window lighting, car colors).
- Easter eggs work best as conditional draws inside existing building methods or as spaced elements in `_ground()` — keeps them discoverable but not cluttering.
- Cloud variety comes from separate draw methods per type (puffy/wisp/small) with different alpha and drift speeds for parallax depth.
- Mountains use very slow parallax (0.1×) + seeded peaks for consistent silhouette — must draw before power plant so they layer behind.
- `ctx.ellipse()` works well for puddles and wisp clouds; `ctx.arc()` for wheels/donuts/fish eyes.
