## Screen-edge heat glow overlay.
## Intensifies in later rounds to sell volcanic eruption.
extends Node2D

var _strength := 0.0
var _ember_t := 0.0
var _time := 0.0

const GLOW_COLOR := Color(0.95, 0.35, 0.05)
const STEPS := 8


func _ready() -> void:
	z_index = 10


func set_strength(s: float, ember_t: float) -> void:
	_strength = s
	_ember_t = ember_t


func _process(delta: float) -> void:
	_time += delta
	if _strength > 0.01:
		queue_redraw()


func _draw() -> void:
	if _strength < 0.01:
		return

	var pulse := sin(_time) * 0.1 + 0.9
	var base_a := _strength * pulse * (0.5 + _ember_t * 0.5)
	var edge := 60.0 + _strength * 80.0
	var step := edge / STEPS

	# Bottom glow — strongest, heat rises from below.
	for i in range(STEPS):
		var t := float(i) / STEPS
		var a := base_a * 0.4 * (1.0 - t)
		draw_rect(
			Rect2(0, 720.0 - edge + step * i, 1280, step),
			Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, a)
		)

	# Left glow.
	for i in range(STEPS):
		var t := float(i) / STEPS
		var a := base_a * 0.2 * (1.0 - t)
		draw_rect(
			Rect2(step * i, 0, step, 720),
			Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, a)
		)

	# Right glow.
	for i in range(STEPS):
		var t := float(i) / STEPS
		var a := base_a * 0.2 * (1.0 - t)
		draw_rect(
			Rect2(1280.0 - step * (i + 1), 0, step, 720),
			Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, a)
		)

	# Top glow — subtle.
	for i in range(STEPS):
		var t := float(i) / STEPS
		var a := base_a * 0.12 * (1.0 - t)
		draw_rect(
			Rect2(0, step * i, 1280, step),
			Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, a)
		)
