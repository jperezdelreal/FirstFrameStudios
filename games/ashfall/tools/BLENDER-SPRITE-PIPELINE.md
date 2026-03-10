# 3D-to-2D Sprite Rendering Pipeline

> **Status:** Spike / Proof-of-concept  
> **Owner:** Chewie (Engine Dev)  
> **Purpose:** Generate consistent, frame-perfect sprite sheets from 3D models  
> **Why:** AI sprite generation (Kontext Pro) failed — zero consistency between animation frames. 3D models guarantee the same character in every frame.

---

## Prerequisites

| Requirement | Version | Notes |
|---|---|---|
| **Blender** | 4.0+ | Must be callable from command line (`blender` in PATH) |
| **Mixamo account** | Free tier works | [mixamo.com](https://www.mixamo.com) — Adobe ID required |
| **Python** (optional) | 3.10+ | Only needed for contact sheet if Pillow is preferred over Blender fallback |

### Verify Blender CLI

```powershell
# Windows — find Blender path
& "C:\Program Files\Blender Foundation\Blender 4.x\blender.exe" --version

# Add to PATH or create alias
$env:BLENDER = "C:\Program Files\Blender Foundation\Blender 4.x\blender.exe"
```

---

## Step-by-Step Pipeline

### 1. Download from Mixamo (Manual — ~5 minutes)

Mixamo has no public API. Download manually:

1. Go to [mixamo.com](https://www.mixamo.com) and sign in
2. **Pick a character:**
   - Click "Characters" tab
   - Search for a martial arts / fighter body type (e.g., "Y Bot", "X Bot", or any humanoid)
   - Click "Use This Character"
3. **Download the T-pose model:**
   - With the character selected and NO animation, click **Download**
   - Format: **FBX Binary (.fbx)**
   - Pose: **T-pose**
   - Save as: `kael_tpose.fbx`
4. **Download animations:**
   - Click "Animations" tab
   - Search and download each:

   | Animation | Mixamo Search Term | Download Settings |
   |---|---|---|
   | Idle | "idle", "breathing idle", "fighting idle" | FBX, Without Skin, 30fps |
   | Walk | "walk", "walking" | FBX, Without Skin, 30fps |
   | Punch | "punch", "cross punch", "jab" | FBX, Without Skin, 30fps |
   | Kick | "kick", "roundhouse" | FBX, Without Skin, 30fps |
   | Hit reaction | "hit reaction", "take damage" | FBX, Without Skin, 30fps |

   - **Important:** For animations, select "Without Skin" to get just the skeleton animation. Or select "With Skin" if you want the model baked in.
   - Save as: `kael_idle.fbx`, `kael_walk.fbx`, `kael_punch_lp.fbx`, etc.

5. **Organize files:**
   ```
   games/ashfall/assets/3d-source/
   ├── kael_tpose.fbx        # Base model (T-pose)
   ├── kael_idle.fbx          # Idle animation
   ├── kael_walk.fbx          # Walk cycle
   ├── kael_punch_lp.fbx      # Light punch
   ├── kael_punch_mp.fbx      # Medium punch
   ├── kael_punch_hp.fbx      # Heavy punch
   ├── kael_hit.fbx           # Hit reaction
   └── kael_ko.fbx            # Knockout
   ```

> **Tip:** If you downloaded animations "With Skin", each FBX is self-contained and can be rendered directly. If "Without Skin", you'll need to retarget the animation onto the T-pose model in Blender (more advanced).

### 2. Run the Blender Render Script

**Basic usage (one animation):**

```powershell
& $env:BLENDER --background --python games/ashfall/tools/blender_sprite_render.py -- `
    --input "games/ashfall/assets/3d-source/kael_idle.fbx" `
    --output "games/ashfall/assets/sprites/fighters/kael/idle/" `
    --character kael `
    --animation idle `
    --size 512 `
    --step 2 `
    --camera-angle side `
    --contact-sheet
```

**With cel-shade style:**

```powershell
& $env:BLENDER --background --python games/ashfall/tools/blender_sprite_render.py -- `
    --input "games/ashfall/assets/3d-source/kael_punch_lp.fbx" `
    --output "games/ashfall/assets/sprites/fighters/kael/punch_lp/" `
    --character kael `
    --animation punch_lp `
    --size 512 `
    --step 2 `
    --cel-shade `
    --contact-sheet
```

**Batch render all animations (PowerShell):**

```powershell
$BLENDER = "C:\Program Files\Blender Foundation\Blender 4.x\blender.exe"
$SOURCE = "games/ashfall/assets/3d-source"
$OUTPUT = "games/ashfall/assets/sprites/fighters/kael"

$animations = @("idle", "walk", "punch_lp", "punch_mp", "punch_hp", "hit", "ko")

foreach ($anim in $animations) {
    & $BLENDER --background --python games/ashfall/tools/blender_sprite_render.py -- `
        --input "$SOURCE/kael_$anim.fbx" `
        --output "$OUTPUT/$anim/" `
        --character kael `
        --animation $anim `
        --size 512 `
        --step 2 `
        --cel-shade `
        --contact-sheet
    Write-Host "✅ Rendered: $anim"
}
```

### 3. Output Structure

After running, you'll have:

```
games/ashfall/assets/sprites/fighters/kael/
├── idle/
│   ├── kael_idle_0000.png
│   ├── kael_idle_0001.png
│   ├── ...
│   └── kael_idle_sheet.png    # Contact sheet
├── walk/
│   ├── kael_walk_0000.png
│   └── ...
├── punch_lp/
│   ├── kael_punch_lp_0000.png
│   └── ...
└── ...
```

Each frame is a 512×512 transparent PNG — ready for Godot import.

---

## Customization

### Camera Angle

| Flag | View | Best For |
|---|---|---|
| `--camera-angle side` | Pure side view (90°) | 2D fighters (Street Fighter) |
| `--camera-angle front` | Front-facing | Character select, portraits |
| `--camera-angle 3/4` | Isometric-ish (45°) | Beat 'em ups, RPGs |

### Orthographic Scale

The camera auto-fits to the model bounds. Override with:

```
--ortho-scale 2.5
```

Larger value = more zoom out. Useful for keeping consistent framing across different animations (a kick might extend further than an idle pose).

### Frame Step

| `--step` | Result |
|---|---|
| 1 | Every frame (smoothest, most files) |
| 2 | Every other frame (good default) |
| 3 | Every 3rd frame (snappier, fewer files) |
| 4+ | Very choppy, stylized look |

For a 30fps Mixamo animation with `--step 2`, you get ~15 sprite frames per second — standard for 2D fighting games.

### Render Size

| `--size` | Use Case |
|---|---|
| 256 | Retro / pixel-art downscale source |
| 512 | Standard (our default) |
| 1024 | High-res, if your game needs it |

---

## Post-Processing for Art Styles

### Cel-Shade / Toon Look

Built into the pipeline:

```
--cel-shade
```

This applies a Shader-to-RGB + ColorRamp material with hard-edged lighting bands. For character-specific colors, use the companion script:

```powershell
& $env:BLENDER --background --python games/ashfall/tools/cel_shade_material.py -- `
    --input model.fbx `
    --preset kael `
    --outline `
    --outline-thickness 0.003 `
    --steps 3
```

Available presets: `kael` (ember orange), `rhena` (steel blue), `neutral` (grey).

### Pixel Art Downscale

Render at 512×512, then downscale with nearest-neighbor in your image tool:

```powershell
# Using ImageMagick (if installed)
magick convert kael_idle_0000.png -resize 64x64 -filter point kael_idle_0000_pixel.png
```

Or in Python:
```python
from PIL import Image
img = Image.open("kael_idle_0000.png")
small = img.resize((64, 64), Image.NEAREST)
small.save("kael_idle_0000_pixel.png")
```

### Outline-Only (Ink Style)

Use the cel-shade material with `--outline` and set base/shadow colors to white:
1. Edit `cel_shade_material.py` PRESETS to add a white base + white shadow preset
2. The outline modifier will be the only visible detail — gives a manga/ink look

### Silhouette

Render with a solid black emission material — useful for readability testing.

---

## Troubleshooting

| Problem | Solution |
|---|---|
| "FBX not found" | Use absolute path or verify relative path from where you run the command |
| Model is tiny/huge | Adjust `--ortho-scale` manually, or check FBX export scale in Mixamo |
| No animation plays | Ensure FBX was exported "With Skin" from Mixamo, or that animation data exists in the file |
| Frames are blank | Check camera angle — model may face wrong direction. Try `--camera-angle front` |
| Blender not found | Set full path: `& "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe"` |
| EEVEE errors | Script uses `BLENDER_EEVEE_NEXT` (Blender 4.x). For 3.x, change to `BLENDER_EEVEE` in the script |
| Contact sheet missing | Add `--contact-sheet` flag. Pillow optional (Blender fallback available) |

---

## Why This Pipeline?

| Approach | Consistency | Speed | Quality |
|---|---|---|---|
| ❌ AI generation (Kontext Pro) | Zero — every frame is different | Fast | High per-frame, unusable as animation |
| ❌ Hand-drawn sprites | Perfect | Very slow | Depends on artist |
| ✅ **3D-to-2D pipeline** | **Perfect** — same mesh every frame | Medium (one-time setup) | High + customizable |

The 3D model is the single source of truth. Every frame comes from the same geometry, same rig, same material. Consistency is guaranteed by construction.

---

## Future Enhancements

- [ ] Animation retargeting (apply Mixamo anims to custom models)
- [ ] Multi-angle rendering (8-direction sprites for beat 'em up)
- [ ] Godot SpriteFrames auto-import script
- [ ] Palette swap via material presets (P1/P2 colors)
- [ ] Automated batch pipeline (watch folder → render → output)
