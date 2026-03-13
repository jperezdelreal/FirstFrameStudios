# Boba — History

## Core Context (Summarized)

**Role:** Sprite & animation artist for Ashfall game.

**Key Contributions:**
1. **Art Direction & Cel-Shade Pipeline** — Designed cel-shade production workflow using Blender (cel_shade_material.py shader module + blender_sprite_render.py render driver)
   - 2-step shadow ramp (0.45 threshold), 0.01 outline thickness, Fresnel rim light, 5.0/0.6 key-fill ratio
   - Rendered 380 frames × 2 characters in RGBA 512×512; contact sheets for visual review
   - Preset system (--preset kael/rhena) for character setup; EEVEE validated
2. **Sprite Integration & Animation States** — 41/41 character poses per fighter (Kael + Rhena); all 4 specials have distinct art; kicks distinct from punches
3. **Contact Sheet Production** — Batch visual review caught zero errors (vs AI consistency issues)

**Technical Standards:**
- Deterministic 60fps game loops with fixed timestep
- AnimationController synchronizes animation timeline to frame counter
- MoveData resources drive animation frames; no generic _process(), only _physics_process()
- Procedural 2D drawing with parametric palettes enables efficient variation

**Archived Skills:** Sprite design, animation pipeline, Blender rendering, cel-shade materials, production workflows

---

*Archived history; sessions details from various dates summarized above.*
