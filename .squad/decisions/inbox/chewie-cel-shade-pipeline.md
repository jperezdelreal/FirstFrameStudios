# Cel-Shade Pipeline Standardization

**Author:** Chewie (Engine Developer)
**Date:** 2025-07-22
**Status:** Proposed
**Scope:** Ashfall sprite rendering pipeline

## Decision

Standardized the cel-shade sprite pipeline with production-quality parameters:

1. **2-step shadow bands as default** — Hard shadow/lit split at 0.45 (Guilty Gear Xrd style). 3-step available via `--steps 3` but 2-step is the fighting game standard.
2. **Outline thickness 0.01** — Visible at 512px. Previous 0.002 was invisible. Range 0.008-0.012 appropriate for Mixamo mannequin.
3. **Fresnel rim light always on** — Edge glow with per-character color. Disable with `--no-rim-light`.
4. **Dramatic single-key lighting** — Key=5.0, Fill=0.6, Ambient=0.3. High contrast drives the cel-shade look.
5. **Single source of truth** — `cel_shade_material.py` is the only shader module. `blender_sprite_render.py` imports it via `--preset` flag.
6. **EEVEE engine name** — Blender 5.0 uses `BLENDER_EEVEE` (not `BLENDER_EEVEE_NEXT`).

## Impact on Team

- Artists reviewing sprites: Files in `assets/sprites/{character}/{animation}/`
- Anyone rendering: Use `--preset kael` or `--preset rhena` — no manual color setup
- New characters: Add preset to `cel_shade_material.py` PRESETS dict
- Pipeline docs in `tools/BLENDER-SPRITE-PIPELINE.md` remain valid

## Why

Founder wants Street Fighter / Guilty Gear Xrd style. The 2-step shadow + rim light + thick outline combination achieves that dramatic hand-drawn look from free Mixamo mannequins.
