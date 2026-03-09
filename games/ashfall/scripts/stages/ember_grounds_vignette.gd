## Screen-edge heat glow overlay with cinematic corner darkening.
## Intensifies in later rounds to sell volcanic eruption. Glow color
## shifts from cool amber (dormant) to fiery orange-red (eruption)
## via set_visual_data() called by ember_grounds.gd.
## Uses frame-based animation in _physics_process per GDSCRIPT-STANDARDS Rule 7.
extends Node2D

var _strength := 0.0
var _ember_t := 0.0
var _glow_color := Color(0.95, 0.35, 0.05)
var _frame: int = 0

const STEPS := 10


func _ready() -> void:
	z_index = 10


## Primary visual data from main controller (round-reactive glow color).
func set_visual_data(s: float, ember_t: float, glow_col: Color) -> void:
	_strength = s
	_ember_t = ember_t
	_glow_color = glow_col


## Backward-compatible setter.
func set_strength(s: float, ember_t: float) -> void:
	_strength = s
	_ember_t = ember_t


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _strength > 0.005 or _ember_t > 0.3:
		queue_redraw()


func _draw() -> void:
	var t: float = float(_frame) / 60.0

	# ── Cinematic corner darkening (always on, subtle) ──
	var corner_a := 0.06 + _strength * 0.08
	var corner_sz := 180.0 + _strength * 60.0
	# Top-left.
	for i in range(6):
		var ct: float = float(i) / 6.0
		var ca := corner_a * (1.0 - ct) * 0.5
		var cs := corner_sz * (1.0 - ct * 0.7)
		draw_rect(Rect2(0, 0, cs, cs * 0.6), Color(0.0, 0.0, 0.0, ca))
	# Top-right.
	for i in range(6):
		var ct: float = float(i) / 6.0
		var ca := corner_a * (1.0 - ct) * 0.5
		var cs := corner_sz * (1.0 - ct * 0.7)
		draw_rect(Rect2(1280.0 - cs, 0, cs, cs * 0.6), Color(0.0, 0.0, 0.0, ca))

	if _strength < 0.005:
		return

	var pulse := sin(t * 0.9) * 0.12 + 0.88
	var base_a := _strength * pulse * (0.5 + _ember_t * 0.5)
	var edge := 65.0 + _strength * 90.0
	var step := edge / STEPS

	# ── Bottom glow — strongest, heat rises from below ──
	for i in range(STEPS):
		var gt: float = float(i) / float(STEPS)
		var a := base_a * 0.42 * (1.0 - gt)
		draw_rect(
			Rect2(0, 720.0 - edge + step * gt, 1280, step),
			Color(_glow_color.r, _glow_color.g, _glow_color.b, a)
		)

	# ── Left glow ──
	for i in range(STEPS):
		var gt: float = float(i) / float(STEPS)
		var a := base_a * 0.22 * (1.0 - gt)
		draw_rect(
			Rect2(step * gt, 0, step, 720),
			Color(_glow_color.r, _glow_color.g, _glow_color.b, a)
		)

	# ── Right glow ──
	for i in range(STEPS):
		var gt: float = float(i) / float(STEPS)
		var a := base_a * 0.22 * (1.0 - gt)
		draw_rect(
			Rect2(1280.0 - step * (gt + 1.0), 0, step, 720),
			Color(_glow_color.r, _glow_color.g, _glow_color.b, a)
		)

	# ── Top glow — subtle ──
	for i in range(STEPS):
		var gt: float = float(i) / float(STEPS)
		var a := base_a * 0.10 * (1.0 - gt)
		draw_rect(
			Rect2(0, step * gt, 1280, step),
			Color(_glow_color.r, _glow_color.g, _glow_color.b, a)
		)

	# ── Extra heat shimmer band at bottom during high intensity ──
	if _strength > 0.25:
		var shimmer := sin(t * 2.2) * 0.08 + 0.08
		var shimmer_a := (_strength - 0.25) * shimmer * 2.0
		draw_rect(
			Rect2(0, 680, 1280, 40),
			Color(_glow_color.r * 1.1, _glow_color.g * 0.6, 0.0, shimmer_a * 0.18)
		)
