extends Node2D
## Sprite Test Viewer — Cel-Shade Rendered Sprites
## Displays Kael or Rhena cel-shaded sprites as animations over the Embergrounds background.
## Keys: 1=Idle  2=Walk  3=Punch  4=Kick  K=Kael  R=Rhena  F=Flip  ESC=Quit
## Author: Chewie (Engine Developer)

const SPRITE_BASE := "res://assets/sprites/"
const BG_PATH := "res://assets/poc/v1/embergrounds_bg.png"

# Animation configs: fps tuned for fighting game feel (12fps loops, 15fps attacks)
const ANIM_CONFIGS := {
	"idle":  { "fps": 12.0, "loop": true },
	"walk":  { "fps": 12.0, "loop": true },
	"punch": { "fps": 15.0, "loop": false },
	"kick":  { "fps": 15.0, "loop": false },
}

const CHARACTERS := ["kael", "rhena"]

const CENTER_X := 960
const RHENA_OFFSET_X := 200

# 512px sprites scaled for visibility. Collision box is 30x60 (1:2 ratio).
# At 0.4 scale the sprite renders ~205px tall — reasonable for a 1080p fighting game.
const SPRITE_SCALE := 0.4

var sprite: AnimatedSprite2D
var hud_label: Label
var current_anim: String = "idle"
var current_character: String = "kael"


func _ready() -> void:
	_setup_background()
	_setup_sprite()
	_setup_hud()
	sprite.play("idle")
	print("🎮 Sprite Viewer loaded — 1/2/3/4 anims, K/R chars, F flip, ESC quit")


func _setup_background() -> void:
	var bg_tex := load(BG_PATH) as Texture2D
	if not bg_tex:
		push_warning("Background texture not found at: " + BG_PATH)
		return
	var bg := Sprite2D.new()
	bg.texture = bg_tex
	bg.centered = false
	add_child(bg)


func _setup_sprite() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = _build_sprite_frames()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Center-bottom origin: offset sprite up so node position = feet
	sprite.offset = Vector2(0, -256)
	sprite.position = Vector2(_get_character_x(), 800)
	sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	sprite.animation_finished.connect(_on_animation_finished)
	add_child(sprite)


func _get_character_x() -> float:
	if current_character == "rhena":
		return CENTER_X + RHENA_OFFSET_X
	return CENTER_X


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for anim_name in ANIM_CONFIGS:
		var cfg: Dictionary = ANIM_CONFIGS[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, cfg.fps)
		frames.set_animation_loop(anim_name, cfg.loop)

		# Auto-detect frames: load sequentially until a frame is missing
		var i := 0
		while true:
			var path: String = "%s%s/%s/%s_%s_%04d.png" % [
				SPRITE_BASE, current_character, anim_name,
				current_character, anim_name, i
			]
			var tex := load(path) as Texture2D
			if not tex:
				break
			frames.add_frame(anim_name, tex)
			i += 1

		if i == 0:
			push_warning("No frames found for %s/%s" % [current_character, anim_name])
		else:
			print("  Loaded %s/%s: %d frames @ %sfps" % [current_character, anim_name, i, cfg.fps])

	return frames


func _setup_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	hud_label = Label.new()
	hud_label.position = Vector2(20, 20)
	hud_label.add_theme_font_size_override("font_size", 22)
	hud_label.add_theme_color_override("font_color", Color.WHITE)
	hud_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	hud_label.add_theme_constant_override("shadow_offset_x", 2)
	hud_label.add_theme_constant_override("shadow_offset_y", 2)
	canvas.add_child(hud_label)
	_update_hud()


func _update_hud() -> void:
	hud_label.text = "%s — %s  |  [1] Idle  [2] Walk  [3] Punch  [4] Kick  [K] Kael  [R] Rhena  [F] Flip  [ESC] Quit" % [current_character.to_upper(), current_anim.to_upper()]


func _play_animation(anim_name: String) -> void:
	current_anim = anim_name
	sprite.play(anim_name)
	_update_hud()


func _on_animation_finished() -> void:
	# Non-looping attack anims return to idle when done
	if not ANIM_CONFIGS[current_anim].loop:
		_play_animation("idle")


func _switch_character(character_name: String) -> void:
	if current_character == character_name:
		return
	current_character = character_name
	sprite.sprite_frames = _build_sprite_frames()
	sprite.position.x = _get_character_x()
	_play_animation("idle")


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_1:
			_play_animation("idle")
		KEY_2:
			_play_animation("walk")
		KEY_3:
			_play_animation("punch")
		KEY_4:
			_play_animation("kick")
		KEY_K:
			_switch_character("kael")
		KEY_R:
			_switch_character("rhena")
		KEY_F:
			sprite.scale.x *= -1
		KEY_ESCAPE:
			get_tree().quit()
