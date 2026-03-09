extends Node2D
## Sprite PoC Test Viewer
## Displays Kael's PoC sprites as animations over the Embergrounds background.
## Keys: 1=Idle  2=Walk  3=LP  F=Flip  ESC=Quit
## Author: Chewie (Engine Developer)

const SPRITE_PATH := "res://assets/poc/"

const ANIM_CONFIG := {
	"idle": { "prefix": "kael_idle_", "count": 8, "fps": 8.0, "loop": true },
	"walk": { "prefix": "kael_walk_", "count": 8, "fps": 10.0, "loop": true },
	"lp":   { "prefix": "kael_lp_",   "count": 12, "fps": 60.0, "loop": false },
}

# 512px sprites scaled for visibility. Collision box is 30x60 (1:2 ratio).
# At 0.4 scale the sprite renders ~205px tall — reasonable for a 1080p fighting game.
const SPRITE_SCALE := 0.4

var sprite: AnimatedSprite2D
var hud_label: Label
var current_anim: String = "idle"


func _ready() -> void:
	_setup_background()
	_setup_sprite()
	_setup_hud()
	sprite.play("idle")
	print("🎮 Sprite PoC Viewer loaded — 1/2/3 to switch anims, F to flip, ESC to quit")


func _setup_background() -> void:
	var bg_tex := load(SPRITE_PATH + "embergrounds_bg.png") as Texture2D
	if not bg_tex:
		push_warning("Background texture not found")
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
	# Position at screen center, slightly above bottom
	sprite.position = Vector2(960, 800)
	sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	sprite.animation_finished.connect(_on_animation_finished)
	add_child(sprite)


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for anim_name in ANIM_CONFIG:
		var cfg: Dictionary = ANIM_CONFIG[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, cfg.fps)
		frames.set_animation_loop(anim_name, cfg.loop)

		for i in range(1, cfg.count + 1):
			var path: String = SPRITE_PATH + cfg.prefix + "%02d.png" % i
			var tex := load(path) as Texture2D
			if tex:
				frames.add_frame(anim_name, tex)
			else:
				push_warning("Missing sprite: " + path)

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
	hud_label.text = "Animation: %s  |  [1] Idle  [2] Walk  [3] LP  [F] Flip  [ESC] Quit" % current_anim.to_upper()


func _play_animation(anim_name: String) -> void:
	current_anim = anim_name
	sprite.play(anim_name)
	_update_hud()


func _on_animation_finished() -> void:
	# Non-looping anims (LP) return to idle when done
	if not ANIM_CONFIG[current_anim].loop:
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
			_play_animation("lp")
		KEY_F:
			sprite.scale.x *= -1
		KEY_ESCAPE:
			get_tree().quit()
