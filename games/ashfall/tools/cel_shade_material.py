"""
Cel-Shade Material Toolkit — Ashfall Fighting Game
===================================================
Standalone companion script that applies toon/cel-shade shaders
to models in Blender. Can be run independently or imported by
blender_sprite_render.py.

Usage (standalone):
    blender --background --python cel_shade_material.py -- \
        --input model.fbx \
        --preset kael \
        --outline

Usage (from Blender Python console):
    import cel_shade_material
    cel_shade_material.apply_preset("kael")

Presets map to Ashfall character color palettes.
"""

import bpy
import sys
import os
import math
import argparse
from mathutils import Vector


# ---------------------------------------------------------------------------
# Character color presets (Ashfall palette)
# ---------------------------------------------------------------------------

PRESETS = {
    "kael": {
        "name": "Kael — Cinder Monk",
        "base":    (0.85, 0.35, 0.15, 1.0),   # Warm ember orange
        "shadow":  (0.35, 0.12, 0.05, 1.0),   # Deep burnt sienna
        "highlight": (1.0, 0.65, 0.30, 1.0),  # Hot flame
        "outline": (0.12, 0.05, 0.02, 1.0),   # Near-black brown
        "rim":     (1.0, 0.50, 0.20, 1.0),    # Warm rim glow
    },
    "rhena": {
        "name": "Rhena",
        "base":    (0.25, 0.45, 0.75, 1.0),   # Steel blue
        "shadow":  (0.10, 0.18, 0.35, 1.0),   # Deep indigo
        "highlight": (0.55, 0.70, 0.90, 1.0), # Ice blue
        "outline": (0.05, 0.08, 0.15, 1.0),   # Dark navy
        "rim":     (0.45, 0.65, 1.0, 1.0),    # Cool rim glow
    },
    "neutral": {
        "name": "Neutral (preview)",
        "base":    (0.7, 0.7, 0.7, 1.0),
        "shadow":  (0.3, 0.3, 0.3, 1.0),
        "highlight": (0.95, 0.95, 0.95, 1.0),
        "outline": (0.1, 0.1, 0.1, 1.0),
        "rim":     (0.9, 0.9, 0.95, 1.0),
    },
}

# Default outline thickness tuned for 512px fighting game sprites
DEFAULT_OUTLINE_THICKNESS = 0.01


# ---------------------------------------------------------------------------
# CLI parsing
# ---------------------------------------------------------------------------

def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1:]
    else:
        argv = []

    parser = argparse.ArgumentParser(description="Apply cel-shade materials.")
    parser.add_argument("--input", help="Path to .fbx file (optional if scene already loaded)")
    parser.add_argument("--preset", default="neutral",
                        choices=list(PRESETS.keys()),
                        help="Character color preset")
    parser.add_argument("--outline", action="store_true",
                        help="Add inverted-hull outline pass")
    parser.add_argument("--outline-thickness", type=float, default=DEFAULT_OUTLINE_THICKNESS,
                        help="Outline thickness (solidify modifier)")
    parser.add_argument("--steps", type=int, default=2,
                        help="Number of cel-shade bands (2=anime, 3=classic)")
    parser.add_argument("--rim-light", action="store_true", default=True,
                        help="Add fresnel rim light for silhouette pop (default: on)")
    parser.add_argument("--no-rim-light", action="store_true",
                        help="Disable rim light")
    return parser.parse_args(argv)


# ---------------------------------------------------------------------------
# Core cel-shade material builder
# ---------------------------------------------------------------------------

def create_cel_shade_material(name, base_color, shadow_color,
                               highlight_color=None, steps=2,
                               rim_light=True, rim_color=None):
    """Build a Shader-to-RGB toon material with configurable bands.

    The technique:
    1. Diffuse BSDF captures lighting direction
    2. Shader to RGB converts shading to a greyscale value
    3. ColorRamp with CONSTANT interpolation creates hard-edged bands
    4. Emission shader outputs flat color (no specular reflections)
    5. Optional fresnel rim light adds silhouette pop (Guilty Gear style)

    This gives the classic 2D fighting game hand-drawn look.
    """
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    # --- Node creation ---
    output = nodes.new('ShaderNodeOutputMaterial')
    output.location = (1000, 0)

    diffuse = nodes.new('ShaderNodeBsdfDiffuse')
    diffuse.inputs['Color'].default_value = base_color
    diffuse.location = (-200, 0)

    shader_to_rgb = nodes.new('ShaderNodeShaderToRGB')
    shader_to_rgb.location = (0, 0)

    color_ramp = nodes.new('ShaderNodeValToRGB')
    color_ramp.location = (200, 0)

    # --- Configure color ramp bands ---
    cr = color_ramp.color_ramp
    cr.interpolation = 'CONSTANT'

    # Remove extra default elements
    while len(cr.elements) > 1:
        cr.elements.remove(cr.elements[-1])

    if steps == 2:
        # Hard 2-step (Guilty Gear style): shadow / lit at ~0.45
        cr.elements[0].position = 0.0
        cr.elements[0].color = shadow_color
        e1 = cr.elements.new(0.45)
        e1.color = base_color
    elif steps == 3:
        # Three-tone: shadow + midtone + highlight
        cr.elements[0].position = 0.0
        cr.elements[0].color = shadow_color
        e1 = cr.elements.new(0.35)
        e1.color = base_color
        if highlight_color:
            e2 = cr.elements.new(0.7)
            e2.color = highlight_color
        else:
            e2 = cr.elements.new(0.7)
            e2.color = (
                min(base_color[0] * 1.3, 1.0),
                min(base_color[1] * 1.3, 1.0),
                min(base_color[2] * 1.3, 1.0),
                1.0,
            )
    elif steps >= 4:
        # Multi-band: gradient from shadow → base → highlight
        cr.elements[0].position = 0.0
        cr.elements[0].color = shadow_color
        for i in range(1, steps):
            t = i / (steps - 1)
            pos = t * 0.85 + 0.1
            hl = highlight_color or (1.0, 1.0, 1.0, 1.0)
            color = (
                shadow_color[0] + (hl[0] - shadow_color[0]) * t,
                shadow_color[1] + (hl[1] - shadow_color[1]) * t,
                shadow_color[2] + (hl[2] - shadow_color[2]) * t,
                1.0,
            )
            cr.elements.new(pos).color = color

    # --- Rim light (fresnel edge glow for silhouette pop) ---
    if rim_light:
        rim_c = rim_color or highlight_color or (1.0, 1.0, 1.0, 1.0)

        fresnel = nodes.new('ShaderNodeFresnel')
        fresnel.inputs['IOR'].default_value = 1.45
        fresnel.location = (200, -250)

        rim_ramp = nodes.new('ShaderNodeValToRGB')
        rim_ramp.location = (400, -250)
        rim_cr = rim_ramp.color_ramp
        rim_cr.interpolation = 'CONSTANT'
        while len(rim_cr.elements) > 1:
            rim_cr.elements.remove(rim_cr.elements[-1])
        rim_cr.elements[0].position = 0.0
        rim_cr.elements[0].color = (0.0, 0.0, 0.0, 1.0)
        rim_edge = rim_cr.elements.new(0.65)
        rim_edge.color = rim_c

        rim_mix = nodes.new('ShaderNodeMixRGB')
        rim_mix.blend_type = 'ADD'
        rim_mix.inputs['Fac'].default_value = 0.7
        rim_mix.location = (600, 0)

        emission = nodes.new('ShaderNodeEmission')
        emission.location = (800, 0)
        emission.inputs['Strength'].default_value = 1.0

        links.new(diffuse.outputs['BSDF'], shader_to_rgb.inputs['Shader'])
        links.new(shader_to_rgb.outputs['Color'], color_ramp.inputs['Fac'])
        links.new(color_ramp.outputs['Color'], rim_mix.inputs['Color1'])
        links.new(fresnel.outputs['Fac'], rim_ramp.inputs['Fac'])
        links.new(rim_ramp.outputs['Color'], rim_mix.inputs['Color2'])
        links.new(rim_mix.outputs['Color'], emission.inputs['Color'])
        links.new(emission.outputs['Emission'], output.inputs['Surface'])
    else:
        emission = nodes.new('ShaderNodeEmission')
        emission.location = (500, 0)
        emission.inputs['Strength'].default_value = 1.0

        links.new(diffuse.outputs['BSDF'], shader_to_rgb.inputs['Shader'])
        links.new(shader_to_rgb.outputs['Color'], color_ramp.inputs['Fac'])
        links.new(color_ramp.outputs['Color'], emission.inputs['Color'])
        links.new(emission.outputs['Emission'], output.inputs['Surface'])

    return mat


# ---------------------------------------------------------------------------
# Outline via inverted-hull method
# ---------------------------------------------------------------------------

def create_outline_material(color=(0.1, 0.1, 0.1, 1.0)):
    """Solid black emission material for the outline shell."""
    mat = bpy.data.materials.new(name="Outline")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    output = nodes.new('ShaderNodeOutputMaterial')
    output.location = (200, 0)

    emission = nodes.new('ShaderNodeEmission')
    emission.inputs['Color'].default_value = color
    emission.inputs['Strength'].default_value = 1.0
    emission.location = (0, 0)

    links.new(emission.outputs['Emission'], output.inputs['Surface'])

    # Backface culling flipped — only renders the inside of the inflated mesh
    mat.use_backface_culling = True

    return mat


def add_outline_modifier(obj, thickness=None, outline_color=(0.1, 0.1, 0.1, 1.0)):
    """Add a Solidify modifier with flipped normals for outline effect.

    The inverted-hull technique:
    1. Duplicate the mesh shell outward (Solidify)
    2. Flip normals so only the backface (outer edge) is visible
    3. Apply a flat black material to the shell
    This creates clean outlines that scale with the model.
    """
    if thickness is None:
        thickness = DEFAULT_OUTLINE_THICKNESS
    if obj.type != 'MESH':
        return

    outline_mat = create_outline_material(outline_color)

    # Add outline material slot
    obj.data.materials.append(outline_mat)
    outline_idx = len(obj.data.materials) - 1

    mod = obj.modifiers.new(name="Outline", type='SOLIDIFY')
    mod.thickness = thickness
    mod.offset = 1.0  # Expand outward only
    mod.use_flip_normals = True
    mod.material_offset = outline_idx
    mod.use_rim = False


# ---------------------------------------------------------------------------
# Fighting-game lighting setup
# ---------------------------------------------------------------------------

def setup_fighting_game_lighting(objects):
    """Strong directional key light from upper-left, minimal fill.

    Mimics the dramatic single-source lighting of character select screens
    in Street Fighter / Guilty Gear Xrd. The hard directional light works
    with the 2-step shadow ramp to create bold shadow shapes.
    """
    from mathutils import Euler

    # Find model for positioning
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
        min_co = Vector((-1, -1, 0))
        max_co = Vector((1, 1, 2))

    height = max_co.z - min_co.z
    offset = height * 2

    # Key light — strong, upper-left, dramatic angle
    key_data = bpy.data.lights.new("KeyLight", 'SUN')
    key_data.energy = 5.0
    key_obj = bpy.data.objects.new("KeyLight", key_data)
    bpy.context.collection.objects.link(key_obj)
    key_obj.location = (-offset, -offset * 0.5, offset * 2)
    key_obj.rotation_euler = Euler((math.radians(55), math.radians(-15), math.radians(-35)), 'XYZ')

    # Fill light — very subtle, just to prevent pure-black areas
    fill_data = bpy.data.lights.new("FillLight", 'SUN')
    fill_data.energy = 0.6
    fill_obj = bpy.data.objects.new("FillLight", fill_data)
    bpy.context.collection.objects.link(fill_obj)
    fill_obj.location = (offset, offset, offset * 0.5)
    fill_obj.rotation_euler = Euler((math.radians(70), math.radians(20), math.radians(30)), 'XYZ')

    # World ambient — near-zero to preserve shadow contrast
    world = bpy.data.worlds.get("World")
    if world is None:
        world = bpy.data.worlds.new("World")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg_node = world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs["Color"].default_value = (0.08, 0.08, 0.10, 1.0)
        bg_node.inputs["Strength"].default_value = 0.3

    print("  Lighting: fighting-game dramatic (key=5.0, fill=0.6, ambient=0.3)")


# ---------------------------------------------------------------------------
# High-level API
# ---------------------------------------------------------------------------

def apply_preset(preset_name, outline=False, outline_thickness=None,
                 steps=2, rim_light=True, setup_lights=False, objects=None):
    """Apply a character cel-shade preset to all mesh objects in the scene.

    Args:
        preset_name: Key into PRESETS dict
        outline: Enable inverted-hull outlines
        outline_thickness: Override default thickness (0.01)
        steps: Shadow band count (2=anime hard, 3=classic)
        rim_light: Enable fresnel rim highlight
        setup_lights: Also configure fighting-game lighting rig
        objects: Specific objects to apply to (None = all scene meshes)
    """
    if outline_thickness is None:
        outline_thickness = DEFAULT_OUTLINE_THICKNESS

    if preset_name not in PRESETS:
        print(f"Unknown preset '{preset_name}'. Available: {list(PRESETS.keys())}")
        return

    p = PRESETS[preset_name]
    print(f"\nApplying cel-shade preset: {p['name']}")
    print(f"  Steps: {steps}, Rim light: {rim_light}, Outline: {outline}")

    mat = create_cel_shade_material(
        name=f"CelShade_{preset_name}",
        base_color=p["base"],
        shadow_color=p["shadow"],
        highlight_color=p["highlight"],
        steps=steps,
        rim_light=rim_light,
        rim_color=p.get("rim"),
    )

    if objects is None:
        meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
    else:
        meshes = [obj for obj in objects if obj.type == 'MESH']

    for obj in meshes:
        obj.data.materials.clear()
        obj.data.materials.append(mat)
        if outline:
            add_outline_modifier(obj, outline_thickness, p["outline"])

    if setup_lights and meshes:
        all_objs = objects if objects else list(bpy.context.scene.objects)
        setup_fighting_game_lighting(all_objs)

    print(f"  Applied to {len(meshes)} mesh(es).")
    if outline:
        print(f"  Outline enabled (thickness: {outline_thickness})")

    return mat


# ---------------------------------------------------------------------------
# Main entry point (standalone)
# ---------------------------------------------------------------------------

def main():
    args = parse_args()

    # Import FBX if provided
    if args.input:
        abs_path = os.path.abspath(args.input)
        if os.path.isfile(abs_path):
            bpy.ops.object.select_all(action='SELECT')
            bpy.ops.object.delete(use_global=False)
            bpy.ops.import_scene.fbx(filepath=abs_path, use_anim=True,
                                      automatic_bone_orientation=True)
            print(f"Imported: {abs_path}")
        else:
            print(f"FBX not found: {abs_path}")
            return

    use_rim = not args.no_rim_light

    apply_preset(args.preset, outline=args.outline,
                 outline_thickness=args.outline_thickness,
                 steps=args.steps, rim_light=use_rim,
                 setup_lights=True)

    print("\n✅ Cel-shade material applied!")


if __name__ == "__main__":
    main()
