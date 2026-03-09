## @tool script — Run in the Godot editor to bake procedural character
## sprites into PNG sprite sheets for AnimationPlayer import.
##
## Usage:
##   1. Attach this script to a Node2D in any scene
##   2. Set the character_type and palette_index in the inspector
##   3. Click "Generate" in the toolbar (or call generate_sheets() from code)
##   4. PNGs are saved to res://assets/sprites/fighters/{character}/
@tool
class_name SpriteSheetGenerator
extends Node2D

@export_enum("kael", "rhena") var character_type: String = "kael"
@export var palette_index: int = 0
@export var sprite_size: int = 128
@export var generate_on_ready: bool = false

## All poses to bake
const POSE_LIST := [
	"idle", "walk", "walk_2",
	"attack_lp", "attack_mp", "attack_hp",
	"hit", "ko"
]

## Pose-to-filename mapping (per asset naming convention)
const POSE_FILENAMES := {
	"idle": "idle",
	"walk": "walk",
	"walk_2": "walk",        # second walk frame goes in same sheet
	"attack_lp": "punch_lp",
	"attack_mp": "punch_mp",
	"attack_hp": "punch_hp",
	"hit": "hit",
	"ko": "ko",
}


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	if generate_on_ready:
		generate_sheets()


## Generate all pose PNGs for the configured character and palette
func generate_sheets() -> void:
	if not Engine.is_editor_hint():
		push_warning("SpriteSheetGenerator: Refusing to run outside the editor.")
		return

	var sprite_node: CharacterSprite = _create_sprite_instance()
	if not sprite_node:
		push_error("SpriteSheetGenerator: Could not create sprite for '%s'" % character_type)
		return

	add_child(sprite_node)
	sprite_node.palette_index = palette_index

	var variant_suffix := "_p1" if palette_index == 0 else "_p2"
	var output_dir := "res://assets/sprites/fighters/%s" % character_type

	# Ensure directory exists
	if not DirAccess.dir_exists_absolute(output_dir):
		DirAccess.make_dir_recursive_absolute(output_dir)

	for pose_name in POSE_LIST:
		sprite_node.pose = pose_name
		sprite_node.queue_redraw()

		# Wait one frame for the draw to complete
		await get_tree().process_frame

		# Render to viewport texture
		var img := _render_sprite_to_image(sprite_node)
		if img:
			var filename := "%s_%s%s.png" % [character_type, POSE_FILENAMES[pose_name], variant_suffix]
			var path := "%s/%s" % [output_dir, filename]
			var err := img.save_png(path)
			if err == OK:
				print("  ✓ Saved: %s" % path)
			else:
				push_error("  ✗ Failed to save: %s (error %d)" % [path, err])

	sprite_node.queue_free()
	print("SpriteSheetGenerator: Done generating %s %s sheets." % [character_type, "P1" if palette_index == 0 else "P2"])


## Render a CharacterSprite pose into an Image by capturing a SubViewport
func _render_sprite_to_image(sprite_node: CharacterSprite) -> Image:
	var vp := SubViewport.new()
	vp.size = Vector2i(sprite_size, sprite_size)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE

	# Move sprite into viewport, centred
	var container := Node2D.new()
	container.position = Vector2(sprite_size * 0.5, sprite_size * 0.85)
	vp.add_child(container)

	# Clone the sprite drawing into the viewport
	var clone: CharacterSprite = _create_sprite_instance()
	clone.palette_index = sprite_node.palette_index
	clone.pose = sprite_node.pose
	container.add_child(clone)

	add_child(vp)
	await get_tree().process_frame
	await get_tree().process_frame

	var img := vp.get_texture().get_image()
	vp.queue_free()
	return img


func _create_sprite_instance() -> CharacterSprite:
	match character_type:
		"kael":
			return KaelSprite.new()
		"rhena":
			return RhenaSprite.new()
		_:
			return null
