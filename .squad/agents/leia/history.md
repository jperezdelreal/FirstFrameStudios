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
- Scale reference: characters ~64-80px = 6 feet. Single-story shops ~160-180px, 2-story houses ~150px walls + 45px roof, school ~220px + tower. Cars ~100×35, hydrants ~18×30, lampposts ~120px, foreground lampposts ~150px.
- All canvas text coordinates must use `Math.round()` to avoid sub-pixel blurriness. Minimum readable font size is 10px; sign text should be 12-16px for readability at game speed.
- Sign text always needs a contrasting background rectangle behind it — otherwise text on textured surfaces is unreadable.
- Building material differentiation: horizontal siding lines (0.6-0.7px, subtle alpha) for wood/vinyl, brick lines (1px with vertical offsets) for masonry, flat paint for stucco.
- Door proportions: character-height doors (~80px tall) look correct; the old 40-55px doors made buildings look like dollhouses.
- Window frames (2px colored stroke around the glass fill) plus cross bars make windows read as windows rather than colored rectangles.
- Power plant cooling towers need to be ~270px tall to read as industrial scale at the far parallax layer; 180px made them look like garden sheds.
- Foreground alpha of 0.5 balances depth layering visibility vs gameplay clarity (0.3 was invisible, 0.7 would obscure action).
- Road detail: white edge lines + yellow center dashes + raised curb with shadow sells "real road"; just center dashes looked like a generic grey strip.
- Mid-layer building colors should be slightly desaturated vs player palette to prevent visual competition (e.g. Kwik-E-Mart #5A9A9A not #2E8B8B).
