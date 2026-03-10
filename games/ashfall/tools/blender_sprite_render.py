"""
Blender 5.x Sprite Rendering Pipeline — Ashfall Fighting Game
==============================================================
Imports a Mixamo FBX, sets up orthographic camera + flat lighting,
renders each animation frame as a transparent PNG, and generates
a contact sheet.

Uses cel_shade_material.py for toon shading (same directory).

Usage (from command line):
    blender --background --python blender_sprite_render.py -- \
        --input model.fbx \
        --output sprites/punch/ \
        --character kael \
        --animation punch_lp \
        --size 512 \
        --step 2 \
        --camera-angle side \
        --cel-shade \
        --preset kael \
        --outline

Requires: Blender 5.0+ with bpy, Pillow (optional, for contact sheet).
"""

import bpy
import os
import sys
import math
import argparse
from pathlib import Path
from mathutils import Vector, Euler

# Ensure the tools directory is on sys.path so cel_shade_material can be imported
_TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
if _TOOLS_DIR not in sys.path:
    sys.path.insert(0, _TOOLS_DIR)

import cel_shade_material


# ---------------------------------------------------------------------------
# CLI argument parsing (everything after "--")
# ---------------------------------------------------------------------------

def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1:]
    else:
        argv = []

    parser = argparse.ArgumentParser(
        description="Render 2D sprite frames from a 3D Mixamo FBX."
    )
    parser.add_argument("--input", required=True, help="Path to .fbx file")
    parser.add_argument("--output", required=True, help="Output directory for PNGs")
    parser.add_argument("--character", default="fighter", help="Character name prefix (e.g. kael)")
    parser.add_argument("--animation", default="idle", help="Animation name for filenames (e.g. punch_lp)")
    parser.add_argument("--size", type=int, default=512, help="Render resolution (square)")
    parser.add_argument("--step", type=int, default=2, help="Render every Nth frame (1 = every frame)")
    parser.add_argument("--ortho-scale", type=float, default=0.0,
                        help="Orthographic scale (0 = auto-fit model)")
    parser.add_argument("--camera-angle", choices=["side", "front", "3/4"],
                        default="side", help="Camera perspective")
    parser.add_argument("--cel-shade", action="store_true",
                        help="Apply cel-shade toon material to all meshes")
    parser.add_argument("--preset", default="neutral",
                        choices=list(cel_shade_material.PRESETS.keys()),
                        help="Character color preset (kael/rhena/neutral)")
    parser.add_argument("--outline", action="store_true",
                        help="Add inverted-hull outline to meshes")
    parser.add_argument("--outline-thickness", type=float,
                        default=cel_shade_material.DEFAULT_OUTLINE_THICKNESS,
                        help="Outline thickness for solidify modifier")
    parser.add_argument("--steps", type=int, default=2,
                        help="Shadow band count (2=anime, 3=classic)")
    parser.add_argument("--contact-sheet", action="store_true",
                        help="Generate a contact sheet from rendered frames")
    parser.add_argument("--padding", type=int, default=4,
                        help="Padding between contact sheet cells (px)")
    return parser.parse_args(argv)


# ---------------------------------------------------------------------------
# Scene cleanup
# ---------------------------------------------------------------------------

def clear_scene():
    """Remove all objects, meshes, materials, and actions."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block_type in [bpy.data.meshes, bpy.data.materials,
                       bpy.data.cameras, bpy.data.lights,
                       bpy.data.armatures, bpy.data.actions]:
        for block in block_type:
            block_type.remove(block)


# ---------------------------------------------------------------------------
# FBX import
# ---------------------------------------------------------------------------

def import_fbx(filepath):
    """Import FBX and return all imported objects."""
    abs_path = os.path.abspath(filepath)
    if not os.path.isfile(abs_path):
        raise FileNotFoundError(f"FBX not found: {abs_path}")

    before = set(bpy.data.objects.keys())
    bpy.ops.import_scene.fbx(
        filepath=abs_path,
        use_anim=True,
        automatic_bone_orientation=True,
        ignore_leaf_bones=True
    )
    after = set(bpy.data.objects.keys())
    new_names = after - before
    return [bpy.data.objects[n] for n in new_names]


# ---------------------------------------------------------------------------
# Model utilities
# ---------------------------------------------------------------------------

def get_model_bounds(objects):
    """Calculate combined AABB of all mesh objects in world space."""
    min_co = Vector((float('inf'),) * 3)
    max_co = Vector((float('-inf'),) * 3)
    for obj in objects:
        if obj.type == 'MESH':
            bbox = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
            for co in bbox:
                min_co.x = min(min_co.x, co.x)
                min_co.y = min(min_co.y, co.y)
                min_co.z = min(min_co.z, co.z)
                max_co.x = max(max_co.x, co.x)
                max_co.y = max(max_co.y, co.y)
                max_co.z = max(max_co.z, co.z)

    if min_co.x == float('inf'):
        # Fallback for armature-only imports
        for obj in objects:
            if obj.type == 'ARMATURE':
                loc = obj.location
                min_co = loc - Vector((1, 1, 1))
                max_co = loc + Vector((1, 1, 1))
                break
        else:
            min_co = Vector((-1, -1, 0))
            max_co = Vector((1, 1, 2))

    return min_co, max_co


def get_model_center_and_height(objects):
    """Return center point and total height of the model."""
    mn, mx = get_model_bounds(objects)
    center = (mn + mx) / 2
    height = mx.z - mn.z
    width = max(mx.x - mn.x, mx.y - mn.y)
    return center, height, width


# ---------------------------------------------------------------------------
# Camera setup
# ---------------------------------------------------------------------------

CAMERA_PRESETS = {
    "side": {
        "rotation": Euler((math.radians(90), 0, math.radians(90)), 'XYZ'),
        "axis": "X",  # Camera looks along +X
    },
    "front": {
        "rotation": Euler((math.radians(90), 0, 0), 'XYZ'),
        "axis": "Y",
    },
    "3/4": {
        "rotation": Euler((math.radians(80), 0, math.radians(45)), 'XYZ'),
        "axis": "XY",
    },
}


def setup_camera(objects, angle="side", ortho_scale=0.0, render_size=512):
    """Create an orthographic camera framing the model."""
    cam_data = bpy.data.cameras.new("SpriteCam")
    cam_data.type = 'ORTHO'
    cam_obj = bpy.data.objects.new("SpriteCam", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj

    preset = CAMERA_PRESETS[angle]
    cam_obj.rotation_euler = preset["rotation"]

    center, height, width = get_model_center_and_height(objects)
    distance = max(height, width) * 3

    # Position camera along the viewing axis
    if angle == "side":
        cam_obj.location = (center.x + distance, center.y, center.z)
    elif angle == "front":
        cam_obj.location = (center.x, center.y - distance, center.z)
    else:  # 3/4
        offset = distance / math.sqrt(2)
        cam_obj.location = (center.x + offset, center.y - offset, center.z + height * 0.2)

    # Auto-fit ortho scale to model bounds with 10% padding
    if ortho_scale <= 0:
        ortho_scale = max(height, width) * 1.1
    cam_data.ortho_scale = ortho_scale

    # Render settings
    scene = bpy.context.scene
    scene.render.resolution_x = render_size
    scene.render.resolution_y = render_size
    scene.render.resolution_percentage = 100

    return cam_obj


# ---------------------------------------------------------------------------
# Lighting (flat/cel-shade friendly)
# ---------------------------------------------------------------------------

def setup_lighting(objects, use_cel_shade=False):
    """Create lighting rig appropriate for the rendering mode.

    When cel-shade is enabled, delegates to cel_shade_material's dramatic
    fighting-game lighting. Otherwise uses a standard 2-light sprite rig.
    """
    if use_cel_shade:
        cel_shade_material.setup_fighting_game_lighting(objects)
        return

    center, height, _ = get_model_center_and_height(objects)
    offset = height * 2

    key_data = bpy.data.lights.new("KeyLight", 'SUN')
    key_data.energy = 3.0
    key_obj = bpy.data.objects.new("KeyLight", key_data)
    bpy.context.collection.objects.link(key_obj)
    key_obj.location = (offset, -offset, offset * 1.5)
    key_obj.rotation_euler = Euler((math.radians(50), math.radians(10), math.radians(30)), 'XYZ')

    fill_data = bpy.data.lights.new("FillLight", 'SUN')
    fill_data.energy = 1.5
    fill_obj = bpy.data.objects.new("FillLight", fill_data)
    bpy.context.collection.objects.link(fill_obj)
    fill_obj.location = (-offset, offset, offset)
    fill_obj.rotation_euler = Euler((math.radians(60), math.radians(-20), math.radians(-30)), 'XYZ')

    world = bpy.data.worlds.get("World")
    if world is None:
        world = bpy.data.worlds.new("World")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg_node = world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs["Color"].default_value = (0.15, 0.15, 0.18, 1.0)
        bg_node.inputs["Strength"].default_value = 0.5


# ---------------------------------------------------------------------------
# Transparent background
# ---------------------------------------------------------------------------

def setup_transparency():
    """Configure render for transparent RGBA output."""
    scene = bpy.context.scene
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    scene.render.image_settings.color_depth = '8'

    # Use EEVEE for speed (Blender 5.0 uses BLENDER_EEVEE, not BLENDER_EEVEE_NEXT)
    scene.render.engine = 'BLENDER_EEVEE'

    # Disable unnecessary post-processing
    scene.view_settings.view_transform = 'Standard'
    scene.render.use_motion_blur = False


# ---------------------------------------------------------------------------
# Animation detection
# ---------------------------------------------------------------------------

def get_animation_range():
    """Detect the frame range of the imported animation."""
    scene = bpy.context.scene
    # Try to get from actions first
    for action in bpy.data.actions:
        start = int(action.frame_range[0])
        end = int(action.frame_range[1])
        if end > start:
            scene.frame_start = start
            scene.frame_end = end
            return start, end

    # Fallback to scene range
    return scene.frame_start, scene.frame_end


# ---------------------------------------------------------------------------
# Frame rendering
# ---------------------------------------------------------------------------

def render_frames(output_dir, character, animation, step=2, size=512):
    """Render every Nth frame of the animation as individual PNGs.

    Naming convention: {character}_{animation}_{frame:04d}.png
    """
    os.makedirs(output_dir, exist_ok=True)
    scene = bpy.context.scene
    start, end = get_animation_range()

    rendered = []
    frame_index = 0

    print(f"\n=== Rendering {character}_{animation} ===")
    print(f"    Frame range: {start}-{end}, step: {step}")
    print(f"    Output: {output_dir}\n")

    for frame in range(start, end + 1, step):
        scene.frame_set(frame)
        filename = f"{character}_{animation}_{frame_index:04d}.png"
        filepath = os.path.join(output_dir, filename)
        scene.render.filepath = filepath
        bpy.ops.render.render(write_still=True)
        rendered.append(filepath)
        frame_index += 1
        print(f"    [{frame_index}] Frame {frame} → {filename}")

    print(f"\n=== Done: {len(rendered)} frames rendered ===\n")
    return rendered


# ---------------------------------------------------------------------------
# Contact sheet generation
# ---------------------------------------------------------------------------

def generate_contact_sheet(rendered_files, output_dir, character, animation,
                            cell_size=512, padding=4):
    """Combine rendered frames into a single contact sheet PNG.

    Tries Pillow first; falls back to Blender compositor if Pillow is missing.
    """
    if not rendered_files:
        print("No frames to assemble into contact sheet.")
        return None

    sheet_path = os.path.join(output_dir, f"{character}_{animation}_sheet.png")

    try:
        from PIL import Image
        return _contact_sheet_pillow(rendered_files, sheet_path, cell_size, padding)
    except ImportError:
        print("Pillow not available — generating contact sheet with Blender compositing.")
        return _contact_sheet_blender(rendered_files, sheet_path, cell_size, padding)


def _contact_sheet_pillow(files, sheet_path, cell_size, padding):
    """Build contact sheet using Pillow."""
    from PIL import Image
    import math as m

    count = len(files)
    cols = int(m.ceil(m.sqrt(count)))
    rows = int(m.ceil(count / cols))

    sheet_w = cols * (cell_size + padding) + padding
    sheet_h = rows * (cell_size + padding) + padding
    sheet = Image.new('RGBA', (sheet_w, sheet_h), (0, 0, 0, 0))

    for i, fpath in enumerate(files):
        img = Image.open(fpath).convert('RGBA')
        img = img.resize((cell_size, cell_size), Image.LANCZOS)
        col = i % cols
        row = i // cols
        x = padding + col * (cell_size + padding)
        y = padding + row * (cell_size + padding)
        sheet.paste(img, (x, y))

    sheet.save(sheet_path)
    print(f"Contact sheet saved: {sheet_path} ({cols}x{rows} grid)")
    return sheet_path


def _contact_sheet_blender(files, sheet_path, cell_size, padding):
    """Fallback contact sheet using Blender's image API (no Pillow)."""
    import math as m

    count = len(files)
    cols = int(m.ceil(m.sqrt(count)))
    rows = int(m.ceil(count / cols))

    sheet_w = cols * (cell_size + padding) + padding
    sheet_h = rows * (cell_size + padding) + padding

    sheet_img = bpy.data.images.new("ContactSheet", sheet_w, sheet_h, alpha=True)
    # Initialize all pixels to transparent
    pixels = [0.0] * (sheet_w * sheet_h * 4)

    for i, fpath in enumerate(files):
        frame_img = bpy.data.images.load(fpath)
        fw, fh = frame_img.size
        frame_pixels = list(frame_img.pixels)

        col = i % cols
        row = i // cols
        # Blender images are bottom-up, so invert row
        base_x = padding + col * (cell_size + padding)
        base_y = sheet_h - padding - (row + 1) * (cell_size + padding) + padding

        # Simple nearest-neighbor copy (no resize — assumes frames match cell_size)
        for py in range(min(fh, cell_size)):
            for px in range(min(fw, cell_size)):
                src_idx = (py * fw + px) * 4
                dst_x = base_x + px
                dst_y = base_y + py
                if 0 <= dst_x < sheet_w and 0 <= dst_y < sheet_h:
                    dst_idx = (dst_y * sheet_w + dst_x) * 4
                    pixels[dst_idx:dst_idx + 4] = frame_pixels[src_idx:src_idx + 4]

        bpy.data.images.remove(frame_img)

    sheet_img.pixels = pixels
    sheet_img.filepath_raw = sheet_path
    sheet_img.file_format = 'PNG'
    sheet_img.save()
    bpy.data.images.remove(sheet_img)

    print(f"Contact sheet saved (Blender fallback): {sheet_path} ({cols}x{rows} grid)")
    return sheet_path


# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------

def main():
    args = parse_args()

    print("\n" + "=" * 60)
    print("  Ashfall Sprite Renderer — 3D-to-2D Pipeline")
    print("=" * 60)
    print(f"  Input:      {args.input}")
    print(f"  Output:     {args.output}")
    print(f"  Character:  {args.character}")
    print(f"  Animation:  {args.animation}")
    print(f"  Size:       {args.size}x{args.size}")
    print(f"  Step:       every {args.step} frame(s)")
    print(f"  Camera:     {args.camera_angle}")
    print(f"  Cel-shade:  {args.cel_shade}")
    if args.cel_shade:
        print(f"  Preset:     {args.preset}")
        print(f"  Outline:    {args.outline} (thickness: {args.outline_thickness})")
        print(f"  Steps:      {args.steps}")
    print("=" * 60 + "\n")

    # 1. Clean slate
    clear_scene()

    # 2. Import model + animation
    imported = import_fbx(args.input)
    print(f"Imported {len(imported)} objects from FBX.")

    # 3. Apply cel-shade material via cel_shade_material module
    if args.cel_shade:
        cel_shade_material.apply_preset(
            args.preset,
            outline=args.outline,
            outline_thickness=args.outline_thickness,
            steps=args.steps,
            rim_light=True,
            setup_lights=False,
            objects=imported,
        )
        print(f"Applied cel-shade preset '{args.preset}' to all meshes.")

    # 4. Camera
    setup_camera(imported, angle=args.camera_angle,
                 ortho_scale=args.ortho_scale, render_size=args.size)

    # 5. Lighting (fighting-game style when cel-shaded)
    setup_lighting(imported, use_cel_shade=args.cel_shade)

    # 6. Transparency
    setup_transparency()

    # 7. Render frames
    frames = render_frames(
        output_dir=args.output,
        character=args.character,
        animation=args.animation,
        step=args.step,
        size=args.size,
    )

    # 8. Contact sheet (optional)
    if args.contact_sheet:
        generate_contact_sheet(
            frames, args.output, args.character, args.animation,
            cell_size=args.size, padding=args.padding,
        )

    print("\n✅ Pipeline complete!")
    print(f"   {len(frames)} frames → {args.output}")
    print(f"   Naming: {args.character}_{args.animation}_NNNN.png\n")


if __name__ == "__main__":
    main()
