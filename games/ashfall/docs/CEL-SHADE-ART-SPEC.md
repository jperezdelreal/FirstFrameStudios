# Cel-Shade Art Direction Specification — Ashfall Blender Pipeline

**Status:** ACTIVE  
**Author:** Boba (Art Director)  
**Created:** 2026-06-12  
**For:** Chewie (Engine Dev) — Shader Implementation  
**References:** Guilty Gear Xrd cel-shade breakdown, established Ashfall color palettes  

---

## Executive Summary

This specification defines exact parameters for transforming Mixamo FBX renders into hand-drawn fighting game quality sprites via Blender cel-shade shaders and compositing. The target look is **Guilty Gear Xrd-inspired**: bold outlines, hard-edged shadow bands, dramatic directional lighting, and hand-painted color treatment—without investing in high-fidelity 3D models.

**Key Philosophy:** Guilty Gear Xrd achieves its iconic anime look not through photorealism, but through **aggressive artistic choices** in shading, lighting, and outline treatment. We adopt this philosophy: prioritize visual punch and character readability over 3D correctness.

---

## 1. Outline System

### 1.1 — Outline Thickness

**Current State:** 0.002 (Blender Solidify modifier scale) — too thin, reads as muddy at 512×512.  
**Target:** 0.008 (4x thicker)

**Rationale:**
- At 512×512, a 0.002 outline is ~1 pixel or less—vanishes in PNG compression and screen scaling.
- Guilty Gear uses visually prominent outlines; outlines define character form as much as fill color does.
- 0.008 gives ~2–3 pixel outlines at 512×512, readable and dramatic.
- **Test on-screen in Godot after render to validate visual weight.**

**Implementation:**
- Update `cel_shade_material.py` default: `--outline-thickness 0.008`
- Update `blender_sprite_render.py` to accept outline thickness flag (propagate to cel_shade_material calls)

### 1.2 — Outline Color per Character

Outlines should **reinforce character identity**, not default to black.

| Character | Outline Color | RGB (0–1) | Rationale |
|-----------|---------------|-----------|-----------|
| **Kael** | Deep burnt sienna | (0.35, 0.15, 0.05) | Darker version of warm ember palette; feels "hot" |
| **Rhena** | Dark navy | (0.08, 0.12, 0.20) | Darker blue; complements steel-blue body |
| **Generic** | Near-black | (0.08, 0.08, 0.08) | Fallback; slightly warm-neutral |

**Why not pure black?**
- Pure black (#000) can feel harsh and flattened on warm-toned characters.
- Tinting outline slightly toward the character's primary hue creates visual harmony.
- Guilty Gear's character outlines often reflect the character's theme color.

**Implementation:**
- Extend `cel_shade_material.py` PRESETS to include `outline_color` field.
- Update `apply_preset()` to pass outline color to `add_outline_modifier()`.

### 1.3 — Outline Uniformity

**Decision:** Outlines are **uniform thickness across all body parts.**

**Rationale:**
- Mixamo models don't have per-body-part material slots (no easy mesh separation without manual rigging).
- Uniform outlines simplify the pipeline and avoid discontinuities where body parts meet.
- Guilty Gear uses uniform outlines on most characters; variable lineweight is a *future* refinement if we get higher-fidelity models.

**Future Enhancement (Not In This Spec):**
- If we migrate to custom 3D models with separate materials (torso, arms, legs, head), we can expose outline thickness per material.
- For now: one outline pass per character.

---

## 2. Shadow Bands (Cel-Shade Steps)

### 2.1 — Number of Steps

**Target:** 2 steps (hard shadow/lit split) for **maximum dramatic impact**.

**Why 2 steps?**
- Guilty Gear Xrd uses primarily 2-step shading (shadow + lit area with hard edge).
- 3-step (shadow + midtone + highlight) adds softness; fighting games need punch.
- 2-step creates the clearest silhouettes and strongest visual readability.
- Simple, fast to render, zero compromise on legibility.

**Current Situation:** Tools default to 3 steps (0.35 and 0.7 ramp positions).  
**Change:** Update default to `--steps 2`

### 2.2 — Shadow Band Ramp Positions

**Ramp Configuration (2-step, CONSTANT interpolation):**

| Position | Value | Color | Purpose |
|----------|-------|-------|---------|
| **0.0** | Shadow band | Shadow color (per character) | All faces getting less than ~0.5 diffuse brightness |
| **0.5** | Lit band | Base color | All faces getting > 0.5 diffuse brightness |

**Technical Details:**
- Blender's `ShaderNodeValToRGB` with `CONSTANT` interpolation creates hard edges.
- Input is the diffuse brightness (0.0 = shadowed, 1.0 = fully lit).
- Threshold at 0.5 is aggressive but clean; mimics hand-drawn "50/50" shading.

**Color Values per Character:**

**Kael (Cinder Monk):**
- Base: (0.85, 0.35, 0.15) — warm ember orange
- Shadow: (0.35, 0.12, 0.05) — deep burnt sienna
- Highlight (if using 3-step): (1.0, 0.65, 0.30) — hot flame
- Ratio: Shadow ≈ 40% intensity of base, Highlight ≈ 120% of base

**Rhena (Wildfire):**
- Base: (0.25, 0.45, 0.75) — steel blue
- Shadow: (0.10, 0.18, 0.35) — deep indigo
- Highlight (if using 3-step): (0.55, 0.70, 0.90) — ice blue
- Ratio: Shadow ≈ 40% of base, Highlight ≈ 120% of base

**Reference: Guilty Gear's color approach**
- Characters have a pronounced shadow that desaturates slightly and darkens.
- Highlights are brighter but still in the same hue family (no pure white).
- The contrast between shadow and lit creates "cartooniness."

### 2.3 — Hard Edge Control

**Implementation:**
- `ShaderNodeValToRGB` with `CONSTANT` interpolation = hard edges. ✓
- No smoothstep or softening in the color ramp.
- Edge sharpness is a feature, not a bug.

**If Harshness Is Excessive:**
- Slightly increase the threshold (move to 0.55 instead of 0.5).
- This allows a sliver of midtone between shadow/lit, but maintains contrast.
- **Test after render; document if changed.**

---

## 3. Lighting Setup

### 3.1 — Light Direction & Count

**Configuration:**
- **Primary Light:** 1 strong directional (SUN) light
- **Fill Light:** 1 softer directional (SUN) light to prevent total darkness in shadow areas
- **Ambient:** Subtle world ambient to prevent pure black areas

**Why this approach?**
- Guilty Gear uses strong key lighting for dramatic shadows.
- A single light alone creates murky shadowed areas; fill prevents this.
- Fighting game sprites need both contrast *and* readability in shadow regions.

### 3.2 — Key Light Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Type** | SUN (directional) | Mimics sun; casts parallel rays |
| **Energy** | 3.0 | Strong primary; creates clear lit/shadow split |
| **Position** | Upper-left-front | Typical "animation" lighting angle |
| **Rotation (current)** | (50°, 10°, 30°) in XYZ Euler | Establishes left-to-right shadow edge |

**Directional Specifics:**
- **Upper-left** = traditional illustration lighting (mimics overhead sun + viewer's left).
- **Slightly forward (negative Z in front view)** = models face toward camera, shadows fall back and down.
- This creates dynamic facial shadows and body shaping without looking flat.

**Guilty Gear Reference:**
- Their lighting creates strong shadows on one side of faces (e.g., Rembrandt triangle on cheeks).
- Our Mixamo models won't match that exactly, but directional lighting from upper-left is standard.

### 3.3 — Fill Light Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Type** | SUN (directional) | Directional consistency |
| **Energy** | 1.5 | Softer than key; just enough to define shadow shapes |
| **Position** | Opposite side of key (upper-right-back) | Fills shadow areas without washing out |
| **Rotation (current)** | (60°, -20°, -30°) in XYZ Euler | Opposite direction; rear-positioned |

**Purpose:**
- Prevents "silhouette" look where shadows are pure black.
- Allows body contours to be visible even in shadow areas.
- Should not overpower key light (1.5 vs 3.0 energy).

### 3.4 — Ambient Lighting

| Parameter | Value | Notes |
|-----------|-------|-------|
| **World Background Color** | (0.15, 0.15, 0.18) | Very dark; warm-neutral |
| **Strength** | 0.5 | Subtle; mostly for bounce |

**Rationale:**
- Pure black ambient (0.0 strength) can cause unexpected dark spots.
- Slight color + low strength gives soft bounce without washing out shading.
- This color is slightly cool to balance the warm character palette.

### 3.5 — Shadow Quality

**Blender EEVEE Settings (for speed; Cycles is overkill for sprite rendering):**
- **Engine:** BLENDER_EEVEE_NEXT (or BLENDER_EEVEE if on older Blender)
- **Soft Shadows:** Disabled (sharp shadows for fighting game clarity)
- **Ambient Occlusion:** Disabled (would muddy the cel-shade bands)
- **Bloom:** Disabled at render; may be added in post-processing

---

## 4. Color Palette Refinement

### 4.1 — Existing Palettes (Validated)

The Kael and Rhena color sets in `cel_shade_material.py` are locked:

**Kael — Cinder Monk:**
```
base:      (0.85, 0.35, 0.15, 1.0)  ← Primary skin/fabric tone
shadow:    (0.35, 0.12, 0.05, 1.0)  ← Shadow darkening
highlight: (1.0,  0.65, 0.30, 1.0)  ← Bright glow (future: 3-step mode)
outline:   (0.35, 0.15, 0.05, 1.0)  ← Outline tint
```

**Rhena — Wildfire:**
```
base:      (0.25, 0.45, 0.75, 1.0)  ← Primary skin/fabric tone
shadow:    (0.10, 0.18, 0.35, 1.0)  ← Shadow darkening
highlight: (0.55, 0.70, 0.90, 1.0)  ← Bright glow (future: 3-step mode)
outline:   (0.08, 0.12, 0.20, 1.0)  ← Outline tint
```

### 4.2 — Per-Body-Part Material Separation (Future)

**Current Limitation:** Mixamo FBX imports as a single mesh with one material. We cannot currently assign different colors to skin vs. clothing vs. hair without:
1. Rigging the model manually in Blender (time-prohibitive).
2. Using a higher-fidelity paid model with per-part materials.

**Decision:** Accept single-color rendering for now. Personality comes from **outlines, shading, and pose**—not multi-colored materials.

**Why This Is OK:**
- Guilty Gear's *early* cell-shading (before Strive) also used relatively unified color treatment on simpler models.
- Bold outlines and dramatic shading create character distinction more than material variety.
- Once we have custom models or better FBX prep, re-visit per-part coloring.

### 4.3 — Saturation & Vibrance

**Blender Render Settings:**
- **Color Management:** Linear color space (native Blender default).
- **Gamma:** 2.2 (standard sRGB out for PNG).
- **Exposure:** 0.0 (neutral; don't boost or dim globally).

**Post-Processing (See Section 5):**
- Slight color grading to warm/cool emphasize character mood.

---

## 5. Post-Processing & Compositing Effects

### 5.1 — In-Blender Compositing

**Pipeline:**
1. Render cel-shade beauty pass (current setup).
2. Route through compositor for optional enhancements (do not bake into beauty pass).
3. Export final PNG.

### 5.2 — Recommended Compositing Nodes

**Effect 1: Subtle Bloom on Highlights**

| Node | Setting | Purpose |
|------|---------|---------|
| **Glare** | Type: Bloom; Threshold: 0.8; Intensity: 0.3 | Softly glows bright areas (outlines, highlight bands) |

**When to use:**
- If outlines feel too harsh, a slight bloom softens them without losing definition.
- Current test: Try WITHOUT bloom first. Add only if needed after visual review.

**Effect 2: Color Grading (Filmic Look)**

| Node | Setting | Purpose |
|------|---------|---------|
| **Color Curve** | Slight S-curve (shadows darker, highlights brighter) | Increases contrast; mimics hand-drawn punch |

**Settings:**
- Shadows: Pull down to ~0.15 brightness.
- Midtones: Neutral (no change).
- Highlights: Lift slightly to ~0.95 brightness.
- Result: Snappier image, more "comic book" feel.

**Decision:** Optional. Test after sprite validation; may not be necessary if cel-shade alone achieves desired look.

### 5.3 — Compositing NOT to Use

- **Ambient Occlusion Node:** Darkens recesses; conflicts with cel-shade bands.
- **Defocus/Depth of Field:** Fighting game sprites must be sharp.
- **Motion Blur:** Not applicable to static pose renders.

### 5.4 — Export Settings

| Setting | Value | Rationale |
|---------|-------|-----------|
| **Format** | PNG | Lossless; preserves transparency for Godot |
| **Color Mode** | RGBA | Transparent background for sprite layering |
| **Bit Depth** | 8-bit | Standard; 16-bit overkill for sprites |
| **Compression** | Default (9) | Compress fully; file size matters for asset streaming |

---

## 6. The Hand-Drawn Illusion: Guilty Gear Xrd Key Techniques

This section explains *why* we're making these choices, rooted in Guilty Gear's proven methods.

### 6.1 — Sharp Shadows & Hard Edges (Our Implementation)

**What Guilty Gear Does:**
- Uses 2-step or 3-step shading with **hard, banded transitions** instead of smooth gradients.
- Shadows are painted shapes, not natural gradients—mimics hand-drawn inking.

**Our Implementation:**
- `ShaderNodeValToRGB` with `CONSTANT` interpolation = hard edge at 0.5 diffuse threshold.
- No smoothstep; no gradual falloff.

**Result:** Anime-like shading where shadow and light regions are clearly separated, readable at small sizes.

### 6.2 — Inverted-Hull Outlines (Our Implementation)

**What Guilty Gear Does:**
- Renders the character mesh twice: once normally, once slightly enlarged with inverted normals in black/dark.
- Creates crisp outlines that scale with the model.

**Our Implementation:**
- Blender `Solidify` modifier with `thickness=0.008`, `offset=1.0`, `use_flip_normals=True`.
- Outline material is pure emission (no shading), solid color.

**Result:** Clean, readable silhouettes that don't break during animation.

### 6.3 — Directional Lighting for Drama

**What Guilty Gear Does:**
- Lights characters from upper-left (traditional illustration angle).
- Strong key light creates dramatic shadows; fill light prevents silhouette effect.
- Lighting is *artist-chosen*, not physically accurate.

**Our Implementation:**
- Key light (SUN, 3.0 energy) at (50°, 10°, 30°) = upper-left-front.
- Fill light (SUN, 1.5 energy) opposite = prevents pure black shadows.
- Result: Animated, expressive lighting that guides viewer's eye.

### 6.4 — Color Restraint & Harmony

**What Guilty Gear Does:**
- Characters have ONE dominant hue family (e.g., Ky = blue, Sol = orange-red).
- Shadow desaturates but stays in hue family; highlights brighten but don't shift.
- Outline tints reflect character theme (not pure black).

**Our Implementation:**
- Kael: warm orange (base) → burnt sienna (shadow) with orange outline.
- Rhena: steel blue (base) → indigo (shadow) with navy outline.
- No radical hue shifts; harmony across shadow/lit/outline.

**Result:** Cohesive character identity; recognizable at any brightness level.

### 6.5 — Normal Editing (Future Enhancement)

**What Guilty Gear Does:**
- Artists *edit vertex normals directly* to sculpt where shadows fall.
- Allows stylized facial shading (e.g., Rembrandt triangle) without complex geometry.

**Our Limitation:**
- Mixamo models are rigged but not hand-tuned for artistry.
- Manual normal editing would require in-Blender sculpting for each character.

**Decision:** Defer to post-character-art phases. For now, rely on lighting angle + cel-shade bands to create readable shapes.

**Future:** If we commission custom character models, require normal maps pre-edited for our lighting.

---

## 7. Implementation Checklist for Chewie (Engine Dev)

### 7.1 — Code Updates Needed

**In `cel_shade_material.py`:**
- [ ] Change default `--outline-thickness` from 0.002 to 0.008
- [ ] Add `outline_color` field to PRESETS dictionary
- [ ] Update `apply_preset()` to pass outline color to `add_outline_modifier()`
- [ ] Update docstring with exact parameters per section 1–2 of this spec

**In `blender_sprite_render.py`:**
- [ ] Add `--outline-thickness` CLI flag (optional, default 0.008)
- [ ] Add `--shadow-steps` CLI flag (optional, default 2)
- [ ] Pass these flags to `cel_shade_material.apply_preset()`
- [ ] Document in file header (lines 1–20)

**In lighting setup (`setup_lighting()` function):**
- [ ] Validate key light energy (3.0), position, and rotation match section 3.2
- [ ] Validate fill light energy (1.5), position, and rotation match section 3.3
- [ ] Validate world ambient color (0.15, 0.15, 0.18) and strength (0.5)
- [ ] Add comments explaining each parameter per this spec

### 7.2 — Testing Protocol

After code changes, before committing:

1. **Test Render:**
   - Render Kael idle animation with new parameters.
   - Render Rhena idle animation.
   
2. **Visual Validation:**
   - Outlines read as clear black/dark boundaries at 512×512.
   - Shadow/lit split is obvious (hard edge, no muddy midtone).
   - Colors match the palette (Kael orange, Rhena blue).
   - Character is recognizable at 128×128 (in-game scale).
   
3. **Comparison:**
   - Screenshot with old settings (0.002 thickness, 3 steps).
   - Screenshot with new settings.
   - Side-by-side in Godot viewport.
   
4. **Document Result:**
   - If visual quality improves: commit with message "Update cel-shade parameters to GGXrd-inspired 2-step with 0.008 outlines."
   - If visual quality degrades: investigate (lighting angle? outline tint color? Steps too aggressive?).
   - Iterate with Boba (Art Director) for feedback.

---

## 8. Exact Parameters Reference Card

**For quick lookup during implementation:**

### Outline
```
Thickness: 0.008
Kael outline color:   RGB (0.35, 0.15, 0.05)
Rhena outline color:  RGB (0.08, 0.12, 0.20)
Generic fallback:     RGB (0.08, 0.08, 0.08)
```

### Shading
```
Steps: 2
Ramp position 0.0: Shadow color (per character)
Ramp position 0.5: Base color (per character)
Interpolation: CONSTANT (hard edge)
```

### Colors
```
Kael:
  Base:      (0.85, 0.35, 0.15)
  Shadow:    (0.35, 0.12, 0.05)
  Highlight: (1.0,  0.65, 0.30)  [for 3-step future]

Rhena:
  Base:      (0.25, 0.45, 0.75)
  Shadow:    (0.10, 0.18, 0.35)
  Highlight: (0.55, 0.70, 0.90)  [for 3-step future]
```

### Lights
```
Key Light:
  Type: SUN
  Energy: 3.0
  Rotation: (50°, 10°, 30°) XYZ Euler

Fill Light:
  Type: SUN
  Energy: 1.5
  Rotation: (60°, -20°, -30°) XYZ Euler

World Ambient:
  Color: (0.15, 0.15, 0.18)
  Strength: 0.5
```

### Export
```
Format: PNG
Color Mode: RGBA
Bit Depth: 8-bit
Film Transparent: True
Engine: BLENDER_EEVEE or BLENDER_EEVEE_NEXT
```

---

## 9. Open Questions & Future Refinements

### 9.1 — Outline Thickness Feedback

After first renders, we may find:
- 0.008 is **too thick** → feels cartoonish (revert to 0.005)
- 0.008 is **too thin** → still muddy (increase to 0.012)

**Decision:** Chewie renders and shares with Boba. Boba provides visual feedback. Iterate.

### 9.2 — 3-Step Shading Revisit

Once 2-step is locked, we can experiment with 3-step (shadow + midtone + highlight) for:
- Softer, more subtle lighting
- Added depth without looking flat

**When:** After Kael and Rhena 2-step sprites are validated and in-game.

### 9.3 — Character-Specific Lighting Angles

If we build more characters (boss, alternate skin), consider:
- Lighting angle tweaks per character thematic (e.g., darker character = stronger key light for readability).
- This would be per-animation-batch parameters, not global.

### 9.4 — Normal Map Authoring

If we upgrade to custom 3D characters, plan:
- Manual normal editing in Blender for stylized facial shadows.
- Rim lighting setup (shader node additions).
- Per-body-part material separation for multi-color rendering.

---

## 10. Appendix — Visual Reference Links

- **Guilty Gear Xrd GDC Talk:** Junya Motomura's 2015 GDC presentation (recommended viewing)
- **GitHub Reference:** [galloscript/GGXrdShading](https://github.com/galloscript/GGXrdShading) — open-source Blender cel-shade implementation
- **Ashfall ART-DIRECTION.md:** Sibling document; defines character silhouettes, poses, and animation timing
- **Current Pipeline:** `games/ashfall/tools/cel_shade_material.py`, `games/ashfall/tools/blender_sprite_render.py`

---

## Sign-Off

- **Spec Author:** Boba (Art Director)
- **Target Implementer:** Chewie (Engine Dev)
- **Status:** Ready for implementation
- **Last Review:** 2026-06-12

---

**Next Steps:**
1. Chewie implements changes to cel_shade_material.py and blender_sprite_render.py
2. Render test sprites (Kael idle, Rhena idle)
3. Boba reviews on-screen in Godot; provides feedback
4. Iterate parameters as needed
5. Lock parameters and move to production sprite renders
