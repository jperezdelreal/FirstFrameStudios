# Nien — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current characters:** Homer with bezier curves, M-hair, stubble, overbite. 4 enemy variants (normal/fast/heavy/tough) + Nelson boss. All Canvas 2D procedural art.

## Learnings
- Added Homer walk-cycle leg framing, expression-based face drawing, and enemy death spin/launch fades with X eyes.
- Upgraded Homer's fists from plain circles to Simpsons-style 4-finger fists with palm, knuckle row, and thumb using ellipses.
- Added shoe soles (darker brown line at bottom) to both player and all enemy variants for grounding detail.
- Added belt with silver buckle at Homer's shirt-pants transition for visual separation.
- Redesigned Homer's ears from simple arcs to defined C-shaped ellipses with inner ear detail strokes.
- Enemy visual identity pass: normal gets purple baseball cap with brim, tough gets goatee, fast gets sneaker lace dots, heavy/boss get thick visible neck, boss gets open vest with lapels and white undershirt V-neck.
- All new shapes use smooth arcs, ellipses, and quadraticCurveTo for anti-aliased rendering. Existing round lineJoin/lineCap settings preserved.
