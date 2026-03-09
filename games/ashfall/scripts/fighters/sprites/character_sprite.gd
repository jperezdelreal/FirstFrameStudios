## Base class for procedural character sprites. Handles palette system,
## pose state, and common drawing helpers. Character-specific scripts
## (kael_sprite.gd, rhena_sprite.gd) extend this to draw each pose.
class_name CharacterSprite
extends Node2D

## Which color palette to use (0 = P1 default, 1 = P2 alternate)
@export var palette_index: int = 0

## Current animation pose — set by state machine or AnimationPlayer
@export var pose: String = "idle":
	set(value):
		if pose != value:
			pose = value
			queue_redraw()

## Mirrors the sprite horizontally when true (facing left)
var flip_h: bool = false:
	set(value):
		if flip_h != value:
			flip_h = value
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

## All valid pose names
const POSES := [
	"idle", "walk", "walk_2",
	"crouch",
	"jump_up", "jump_peak", "jump_fall",
	"dash", "backdash",
	"attack_lp", "attack_mp", "attack_hp",
	"attack_lk", "attack_mk", "attack_hk",
	"crouch_lp", "crouch_mp", "crouch_hp",
	"crouch_lk", "crouch_mk", "crouch_hk",
	"jump_lp", "jump_mp", "jump_hp",
	"jump_lk", "jump_mk", "jump_hk",
	"block_standing", "block_crouching",
	"hit", "ko",
	"throw_execute", "throw_victim",
	"wakeup",
	"special_1", "special_2", "special_3", "special_4",
	"ignition",
	"win", "lose",
]


func _ready() -> void:
	_init_palettes()
	queue_redraw()


## Override in subclass to define P1/P2 palettes
func _init_palettes() -> void:
	pass


func _draw() -> void:
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
		"ko":               _draw_ko()
		"throw_execute":    _draw_throw_execute()
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
func _draw_idle() -> void: pass
func _draw_walk() -> void: pass
func _draw_walk_2() -> void: pass
func _draw_crouch() -> void: pass
func _draw_jump_up() -> void: pass
func _draw_jump_peak() -> void: pass
func _draw_jump_fall() -> void: pass
func _draw_dash() -> void: pass
func _draw_backdash() -> void: pass
func _draw_attack_lp() -> void: pass
func _draw_attack_mp() -> void: pass
func _draw_attack_hp() -> void: pass
func _draw_attack_lk() -> void: pass
func _draw_attack_mk() -> void: pass
func _draw_attack_hk() -> void: pass
func _draw_crouch_lp() -> void: pass
func _draw_crouch_mp() -> void: pass
func _draw_crouch_hp() -> void: pass
func _draw_crouch_lk() -> void: pass
func _draw_crouch_mk() -> void: pass
func _draw_crouch_hk() -> void: pass
func _draw_jump_lp() -> void: pass
func _draw_jump_mp() -> void: pass
func _draw_jump_hp() -> void: pass
func _draw_jump_lk() -> void: pass
func _draw_jump_mk() -> void: pass
func _draw_jump_hk() -> void: pass
func _draw_block_standing() -> void: pass
func _draw_block_crouching() -> void: pass
func _draw_hit() -> void: pass
func _draw_ko() -> void: pass
func _draw_throw_execute() -> void: pass
func _draw_throw_victim() -> void: pass
func _draw_wakeup() -> void: pass
func _draw_special_1() -> void: pass
func _draw_special_2() -> void: pass
func _draw_special_3() -> void: pass
func _draw_special_4() -> void: pass
func _draw_ignition() -> void: pass
func _draw_win() -> void: pass
func _draw_lose() -> void: pass


# =========================================================================
#  Common drawing helpers — coordinates relative to node origin (0,0).
#  Character fits in roughly 30×60 px to match the collision box.
# =========================================================================

## Outlined ellipse via polygon approximation
func draw_ellipse(center: Vector2, radius: Vector2, color: Color,
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
