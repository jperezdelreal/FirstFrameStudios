## Base class for procedural character sprites. Handles palette system,
## pose state, and common drawing helpers. Character-specific scripts
## (kael_sprite.gd, rhena_sprite.gd) extend this to draw each pose.
##
## When pre-rendered PNG sprites exist for a character, this class
## automatically switches from procedural _draw() rendering to
## AnimatedSprite2D playback. Falls back to procedural if no PNGs found.
class_name CharacterSprite
extends Node2D

## Which color palette to use (0 = P1 default, 1 = P2 alternate)
@export var palette_index: int = 0

## Current animation pose — set by state machine or AnimationPlayer
@export var pose: String = "idle":
	set(value):
		if pose != value:
			pose = value
			if _use_png_sprites:
				_update_sprite_animation()
			else:
				queue_redraw()

## Mirrors the sprite horizontally when true (facing left).
## Uses AnimatedSprite2D.flip_h for PNG sprites, parent scale.x for procedural.
## PNG sprites from Blender face LEFT by default, so flip is inverted for them.
var flip_h: bool = false:
	set(value):
		if flip_h != value:
			flip_h = value
			if _use_png_sprites and _animated_sprite:
				_animated_sprite.flip_h = not flip_h
			else:
				scale.x = -1.0 if flip_h else 1.0

## Character palettes — override in subclass
## Each palette is a Dictionary with keys: skin, hair, outfit_primary,
## outfit_secondary, accent, eye, outline, wrap, scar, boots
var palettes: Array[Dictionary] = []

## Convenience accessor for the active palette
var pal: Dictionary:
	get:
		if palettes.is_empty():
			return {}
		return palettes[clampi(palette_index, 0, palettes.size() - 1)]

# ===================================================================
# PNG Sprite System — pre-rendered Mixamo sprites via AnimatedSprite2D
# ===================================================================

## True when pre-rendered PNG sprites are loaded and active
var _use_png_sprites: bool = false

## AnimatedSprite2D child created at runtime for PNG sprite playback
var _animated_sprite: AnimatedSprite2D = null

## Base path for sprite assets
const _SPRITE_BASE_PATH := "res://assets/sprites/"

## Scale factor for 512px sprites — sized for fighting-game proportions.
## 0.55 × 512 ≈ 282px rendered height — ~26% of 1080p viewport height.
## Comparable to Street Fighter / Guilty Gear character proportions.
const _PNG_SPRITE_SCALE := 0.55

## Texture-pixel offset to anchor sprite at bottom-center (feet at origin).
## 512 / 2 = 256 — shifts the sprite up so the node position = feet.
const _PNG_SPRITE_OFFSET := Vector2(0, -256)

## Maps pose strings → sprite animation names.
## Every pose the state machine can set MUST be listed here to prevent
## fallthrough to procedural _draw(). Missing entries fall back to "idle".
const _POSE_TO_ANIM := {
	# Stance / movement
	"idle": "idle",
	"walk": "walk",
	"walk_2": "walk",
	"crouch": "idle",
	"dash": "walk",
	"backdash": "walk",
	# Standing punches
	"attack_lp": "punch",
	"attack_mp": "punch",
	"attack_hp": "punch",
	# Standing kicks
	"attack_lk": "kick",
	"attack_mk": "kick",
	"attack_hk": "kick",
	# Crouching punches
	"crouch_lp": "punch",
	"crouch_mp": "punch",
	"crouch_hp": "punch",
	# Crouching kicks
	"crouch_lk": "kick",
	"crouch_mk": "kick",
	"crouch_hk": "kick",
	# Air punches
	"jump_lp": "punch",
	"jump_mp": "punch",
	"jump_hp": "punch",
	# Air kicks
	"jump_lk": "kick",
	"jump_mk": "kick",
	"jump_hk": "kick",
	# Jump (no attack)
	"jump_up": "idle",
	"jump_peak": "idle",
	"jump_fall": "idle",
	# Block
	"block_standing": "idle",
	"block_crouching": "idle",
	# Hit reactions
	"hit": "idle",
	"hit_heavy": "idle",
	"hit_crouching": "idle",
	"hit_air": "idle",
	# Knockdown
	"ko": "idle",
	"knockdown_fall": "idle",
	# Throw
	"throw_startup": "punch",
	"throw_execute": "punch",
	"throw_whiff": "idle",
	"throw_victim": "idle",
	# Recovery
	"wakeup": "idle",
	# Specials / super
	"special_1": "punch",
	"special_2": "punch",
	"special_3": "kick",
	"special_4": "kick",
	"ignition": "kick",
	# Win / Lose
	"win": "idle",
	"lose": "idle",
}

## FPS and loop config per sprite animation
const _SPRITE_ANIM_CONFIGS := {
	"idle":  { "fps": 12.0, "loop": true },
	"walk":  { "fps": 12.0, "loop": true },
	"punch": { "fps": 15.0, "loop": false },
	"kick":  { "fps": 15.0, "loop": false },
}

## All valid pose names — covers every fighter state.
## Subclasses override the _draw_*() methods for character-specific art.
## Poses without a dedicated drawing fall back to the closest match.
const POSES := [
	# Stance
	"idle", "walk", "walk_2", "crouch",
	# Air
	"jump_up", "jump_peak", "jump_fall",
	# Movement
	"dash", "backdash",
	# Standing attacks (punches + kicks)
	"attack_lp", "attack_mp", "attack_hp",
	"attack_lk", "attack_mk", "attack_hk",
	# Crouching attacks
	"crouch_lp", "crouch_mp", "crouch_hp",
	"crouch_lk", "crouch_mk", "crouch_hk",
	# Jump attacks
	"jump_lp", "jump_mp", "jump_hp",
	"jump_lk", "jump_mk", "jump_hk",
	# Block
	"block_standing", "block_crouching",
	# Hit reactions
	"hit", "hit_heavy", "hit_crouching", "hit_air",
	# Knockdown
	"ko", "knockdown_fall",
	# Throw
	"throw_startup", "throw_execute", "throw_whiff", "throw_victim",
	# Recovery
	"wakeup",
	# Specials + super
	"special_1", "special_2", "special_3", "special_4",
	"ignition",
	# Win/Lose
	"win", "lose",
]


func _ready() -> void:
	_init_palettes()
	_try_load_png_sprites()
	if not _use_png_sprites:
		queue_redraw()


## Override in subclass to define P1/P2 palettes
func _init_palettes() -> void:
	pass


## Override in subclass to return the character identifier used for
## sprite asset paths (e.g. "kael", "rhena"). Return "" to skip PNG loading.
func _get_character_id() -> String:
	return ""


# ===================================================================
# PNG Sprite Loading
# ===================================================================

## Attempts to load pre-rendered PNG sprites for this character.
## If successful, creates an AnimatedSprite2D child and sets _use_png_sprites.
func _try_load_png_sprites() -> void:
	var char_id := _get_character_id()
	if char_id.is_empty():
		return

	# Probe for at least one idle frame
	var probe_path := "%s%s/idle/%s_idle_0000.png" % [_SPRITE_BASE_PATH, char_id, char_id]
	if not ResourceLoader.exists(probe_path):
		print("[CharacterSprite] No PNG sprites for '%s' — using procedural rendering" % char_id)
		return

	var frames := _build_sprite_frames(char_id)
	if frames.get_animation_names().is_empty():
		return

	_animated_sprite = AnimatedSprite2D.new()
	_animated_sprite.sprite_frames = frames
	_animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_animated_sprite.offset = _PNG_SPRITE_OFFSET
	_animated_sprite.scale = Vector2(_PNG_SPRITE_SCALE, _PNG_SPRITE_SCALE)
	add_child(_animated_sprite)

	_use_png_sprites = true
	# Switch mirroring from parent scale.x to child flip_h
	scale.x = 1.0
	_animated_sprite.flip_h = flip_h
	_update_sprite_animation()
	print("[CharacterSprite] PNG sprites loaded for '%s'" % char_id)


## Builds a SpriteFrames resource by scanning the asset directory.
func _build_sprite_frames(char_id: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for anim_name: String in _SPRITE_ANIM_CONFIGS:
		var cfg: Dictionary = _SPRITE_ANIM_CONFIGS[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, cfg.fps)
		frames.set_animation_loop(anim_name, cfg.loop)

		var i := 0
		while true:
			var path := "%s%s/%s/%s_%s_%04d.png" % [
				_SPRITE_BASE_PATH, char_id, anim_name,
				char_id, anim_name, i
			]
			if not ResourceLoader.exists(path):
				break
			var tex := load(path) as Texture2D
			frames.add_frame(anim_name, tex)
			i += 1

		if i == 0:
			push_warning("[CharacterSprite] No frames for %s/%s" % [char_id, anim_name])

	return frames


## Plays the sprite animation that corresponds to the current pose.
func _update_sprite_animation() -> void:
	if not _animated_sprite:
		return
	var anim_name: String = _POSE_TO_ANIM.get(pose, "idle")
	if not _animated_sprite.sprite_frames.has_animation(anim_name):
		anim_name = "idle"
	# Only restart when the animation actually changes
	if _animated_sprite.animation != anim_name:
		_animated_sprite.play(anim_name)


## Returns true when using pre-rendered PNG sprites instead of procedural.
func is_using_png_sprites() -> bool:
	return _use_png_sprites


func _draw() -> void:
	if _use_png_sprites:
		return
	match pose:
		"idle":             _draw_idle()
		"walk":             _draw_walk()
		"walk_2":           _draw_walk_2()
		"crouch":           _draw_crouch()
		"jump_up":          _draw_jump_up()
		"jump_peak":        _draw_jump_peak()
		"jump_fall":        _draw_jump_fall()
		"dash":             _draw_dash()
		"backdash":         _draw_backdash()
		"attack_lp":        _draw_attack_lp()
		"attack_mp":        _draw_attack_mp()
		"attack_hp":        _draw_attack_hp()
		"attack_lk":        _draw_attack_lk()
		"attack_mk":        _draw_attack_mk()
		"attack_hk":        _draw_attack_hk()
		"crouch_lp":        _draw_crouch_lp()
		"crouch_mp":        _draw_crouch_mp()
		"crouch_hp":        _draw_crouch_hp()
		"crouch_lk":        _draw_crouch_lk()
		"crouch_mk":        _draw_crouch_mk()
		"crouch_hk":        _draw_crouch_hk()
		"jump_lp":          _draw_jump_lp()
		"jump_mp":          _draw_jump_mp()
		"jump_hp":          _draw_jump_hp()
		"jump_lk":          _draw_jump_lk()
		"jump_mk":          _draw_jump_mk()
		"jump_hk":          _draw_jump_hk()
		"block_standing":   _draw_block_standing()
		"block_crouching":  _draw_block_crouching()
		"hit":              _draw_hit()
		"hit_heavy":        _draw_hit_heavy()
		"hit_crouching":    _draw_hit_crouching()
		"hit_air":          _draw_hit_air()
		"ko":               _draw_ko()
		"knockdown_fall":   _draw_knockdown_fall()
		"throw_startup":    _draw_throw_startup()
		"throw_execute":    _draw_throw_execute()
		"throw_whiff":      _draw_throw_whiff()
		"throw_victim":     _draw_throw_victim()
		"wakeup":           _draw_wakeup()
		"special_1":        _draw_special_1()
		"special_2":        _draw_special_2()
		"special_3":        _draw_special_3()
		"special_4":        _draw_special_4()
		"ignition":         _draw_ignition()
		"win":              _draw_win()
		"lose":             _draw_lose()
		_:                  _draw_idle()


# --- Virtual pose methods (override in subclass) ---
# Core stance
func _draw_idle() -> void: pass
func _draw_walk() -> void: pass
func _draw_walk_2() -> void: pass
func _draw_crouch() -> void: _draw_idle()
func _draw_dash() -> void: pass
func _draw_backdash() -> void: pass

# Jump -- default to idle
func _draw_jump_up() -> void: _draw_idle()
func _draw_jump_peak() -> void: _draw_idle()
func _draw_jump_fall() -> void: _draw_idle()

# Standing attacks -- kicks default to punch equivalents
func _draw_attack_lp() -> void: pass
func _draw_attack_mp() -> void: pass
func _draw_attack_hp() -> void: pass
func _draw_attack_lk() -> void: _draw_attack_lp()
func _draw_attack_mk() -> void: _draw_attack_mp()
func _draw_attack_hk() -> void: _draw_attack_hp()

# Crouching attacks
func _draw_crouch_lp() -> void: pass
func _draw_crouch_mp() -> void: pass
func _draw_crouch_hp() -> void: pass
func _draw_crouch_lk() -> void: pass
func _draw_crouch_mk() -> void: pass
func _draw_crouch_hk() -> void: pass

# Jump attacks
func _draw_jump_lp() -> void: pass
func _draw_jump_mp() -> void: pass
func _draw_jump_hp() -> void: pass
func _draw_jump_lk() -> void: pass
func _draw_jump_mk() -> void: pass
func _draw_jump_hk() -> void: pass

# Block -- default to idle/crouch
func _draw_block_standing() -> void: _draw_idle()
func _draw_block_crouching() -> void: _draw_crouch()

# Hit reactions -- variants default to base hit
func _draw_hit() -> void: pass
func _draw_hit_heavy() -> void: _draw_hit()
func _draw_hit_crouching() -> void: _draw_hit()
func _draw_hit_air() -> void: _draw_hit()

# Knockdown -- fall defaults to KO ground pose
func _draw_ko() -> void: pass
func _draw_knockdown_fall() -> void: _draw_ko()

# Throw -- defaults until character-specific art
func _draw_throw_startup() -> void: _draw_attack_hp()
func _draw_throw_execute() -> void: _draw_attack_hp()
func _draw_throw_whiff() -> void: _draw_idle()
func _draw_throw_victim() -> void: pass

# Recovery
func _draw_wakeup() -> void: pass

# Specials + super
func _draw_special_1() -> void: pass
func _draw_special_2() -> void: pass
func _draw_special_3() -> void: pass
func _draw_special_4() -> void: pass
func _draw_ignition() -> void: pass

# Win/Lose -- default to idle/ko
func _draw_win() -> void: _draw_idle()
func _draw_lose() -> void: _draw_ko()


# ==================================================================#  Common drawing helpers — coordinates relative to node origin (0,0).
#  Character fits in roughly 30×60 px to match the collision box.
# ==================================================================
## Outlined ellipse via polygon approximation
func draw_ellipse_outlined(center: Vector2, radius: Vector2, color: Color,
		outline_color: Color = Color.TRANSPARENT, outline_width: float = 1.0,
		segments: int = 16) -> void:
	var points := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / segments
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
	if outline_color.a > 0.0:
		var outline_pts := points.duplicate()
		outline_pts.append(points[0])
		draw_polyline(outline_pts, outline_color, outline_width, true)


## Draw a limb segment (thick line with round caps + optional outline)
func draw_limb(from: Vector2, to: Vector2, thickness: float, color: Color,
		outline_color: Color = Color.TRANSPARENT) -> void:
	if outline_color.a > 0.0:
		draw_line(from, to, outline_color, thickness + 2.0, true)
	draw_line(from, to, color, thickness, true)


## Circle with optional outline ring
func draw_circle_outlined(center: Vector2, radius: float, color: Color,
		outline_color: Color = Color.TRANSPARENT, outline_width: float = 1.0) -> void:
	draw_circle(center, radius, color)
	if outline_color.a > 0.0:
		draw_arc(center, radius, 0, TAU, 32, outline_color, outline_width, true)


## Forearm wrap detail (horizontal lines across a limb area)
func draw_forearm_wraps(center: Vector2, length: float, width: float,
		wrap_color: Color, wrap_count: int = 3) -> void:
	var step := length / (wrap_count + 1)
	for i in range(1, wrap_count + 1):
		var y := center.y - length * 0.5 + step * i
		draw_line(
			Vector2(center.x - width * 0.5, y),
			Vector2(center.x + width * 0.5, y),
			wrap_color, 1.0, true
		)


## Draw a simple fist (circle + knuckle bumps)
func draw_fist(center: Vector2, radius: float, color: Color,
		outline: Color = Color.TRANSPARENT) -> void:
	draw_circle_outlined(center, radius, color, outline)
	# knuckle bumps
	for i in 3:
		var bx := center.x - radius * 0.5 + radius * 0.5 * i
		draw_circle(Vector2(bx, center.y - radius * 0.6), radius * 0.25, outline if outline.a > 0 else color.darkened(0.2))


## Draw a boot shape (rectangle + sole)
func draw_boot(pos: Vector2, w: float, h: float, boot_color: Color,
		sole_color: Color, outline: Color = Color.TRANSPARENT) -> void:
	var rect := Rect2(pos.x - w * 0.5, pos.y - h, w, h)
	draw_rect(rect, boot_color)
	# Sole
	draw_rect(Rect2(pos.x - w * 0.55, pos.y - 2, w * 1.1, 3), sole_color)
	if outline.a > 0.0:
		draw_rect(rect, outline, false, 1.0)
