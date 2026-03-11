# Session Log: Hero Design Proposals (Kael & Rhena)
**Date:** 2026-03-10T07:51Z  
**Agent:** Nien (Character Artist)

## New Pipeline Approach

**The Shift:** Green chroma key generation + approval gate + Kontext frames

### Phase 1: Design Generation (COMPLETE ✅)
- **Problem:** Previous rembg post-processing created visible artifacts
- **Solution:** FLUX 2 Pro generates directly onto solid bright green (#00FF00) backgrounds
- **Result:** 6/6 images with perfectly clean, deterministic green backgrounds (100% corner pixel verification)
- **Artifacts Generated:**
  - 3 Kael design proposals (kael_design_a.png, b.png, c.png)
  - 3 Rhena design proposals (rhena_design_a.png, b.png, c.png)
  - Comparative contact sheets (designs_kael.png, designs_rhena.png)
  - All stored: `games/ashfall/assets/poc/designs/`

### Phase 2: Approval Gate (PENDING ⏳)
- Founder reviews design proposals
- Selects preferred Kael and Rhena designs
- Decision output feeds directly to next phase (no rework waste)

### Phase 3: Animation Frame Generation (QUEUED)
- Approved hero designs sent to Kontext Pro as `input_image`
- Generates animation frames for idle, attack, and hurt states
- Output integrated into ashfall prototype

## Implications
- **Prompt Template:** All future character generation must start with chroma key prefix
- **Pipeline:** Replace rembg step entirely with simple green color-key removal (faster, deterministic)
- **Scope:** Applies to character sprites; does NOT affect backgrounds, VFX, or UI elements
- **API Efficiency:** Approval gate prevents wasted API calls on unapproved designs

---
*Logged by: Scribe*
