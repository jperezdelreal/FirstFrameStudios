# Decision: Green Chroma Key for All FLUX Character Generation

**Author:** Nien (Character Artist)  
**Date:** 2026-03-12  
**Status:** PROPOSED

## Decision

All FLUX-generated character sprites should use solid bright green (#00FF00) chroma key backgrounds instead of relying on rembg post-processing for background removal.

## Context

The founder (Joaquín) noticed artifacts from rembg's AI-based background removal on previous PoC sprites. Testing with explicit green chroma key prompts on FLUX 2 Pro produced 6/6 images with perfectly clean green backgrounds (100% corner pixel verification).

## Implications

- **Prompt change:** Every character generation prompt must start with "isolated character, full body, solid bright green (#00FF00) chroma key background, no border, no frame, no text"
- **Pipeline change:** Replace rembg step with simple green color-key removal (faster, deterministic, no artifacts)
- **Affects:** Nien (character art), Boba (art direction), anyone running FLUX generation scripts
- **Does NOT affect:** Stage backgrounds, VFX, UI elements (those don't need transparency)

## Hero Design Proposals

Generated 3 design proposals each for Kael and Rhena at 1024×1024:
- `games/ashfall/assets/poc/designs/kael_design_{a,b,c}.png`
- `games/ashfall/assets/poc/designs/rhena_design_{a,b,c}.png`
- Contact sheets: `designs_kael.png`, `designs_rhena.png`

**Awaiting founder approval** before generating animation frames.
