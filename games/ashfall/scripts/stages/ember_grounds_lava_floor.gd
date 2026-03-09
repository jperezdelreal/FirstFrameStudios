## Cracked obsidian floor with animated lava seeping through fissures.
## Positioned at the ground surface; draws cracks, glow, and lava pools.
extends Node2D

var _intensity := 0.0
var _lava_color := Color(0.8, 0.25, 0.0, 0.5)
var _time := 0.0
var _cracks: Array = []
var _pools: Array = []
var _patches: Array = []


func _ready() -> void:
	_build_cracks()
	_build_pools()
	_build_patches()


func _build_cracks() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(16):
		var pts: Array = []
		var x := rng.randf_range(0.0, 1280.0)
		var y := rng.randf_range(5.0, 150.0)
		pts.append(Vector2(x, y))
		for _j in range(rng.randi_range(3, 6)):
			x = clampf(x + rng.randf_range(-35.0, 35.0), -10.0, 1290.0)
			y = clampf(y + rng.randf_range(-12.0, 20.0), 2.0, 158.0)
			pts.append(Vector2(x, y))
		_cracks.append({
			"pts": pts,
			"w": rng.randf_range(1.5, 3.0),
			"phase": rng.randf_range(0.0, TAU),
		})


func _build_pools() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in range(5):
		_pools.append({
			"pos": Vector2(rng.randf_range(60.0, 1220.0), rng.randf_range(15.0, 140.0)),
			"r": rng.randf_range(5.0, 14.0),
			"phase": rng.randf_range(0.0, TAU),
		})


func _build_patches() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in range(20):
		_patches.append({
			"rect": Rect2(
				rng.randf_range(0, 1240), rng.randf_range(0, 140),
				rng.randf_range(25, 70), rng.randf_range(12, 35)
			),
			"shade": rng.randf_range(0.03, 0.055),
		})


func set_intensity(ember_t: float, lava_col: Color) -> void:
	_intensity = ember_t
	_lava_color = lava_col


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	# Base obsidian surface.
	draw_rect(Rect2(0, 0, 1280, 160), Color(0.05, 0.04, 0.035))

	# Subtle texture variation — darker patches for visual depth.
	for p in _patches:
		var s: float = p["shade"]
		draw_rect(p["rect"], Color(s, s * 0.85, s * 0.7, 0.35))

	var glow := 0.25 + _intensity * 0.75

	# Lava cracks — wide glow underneath, thin bright line on top.
	for c in _cracks:
		var pts: Array = c["pts"]
		var w: float = c["w"]
		var pulse := (sin(_time * 1.4 + c["phase"]) * 0.5 + 0.5) * glow
		var gc := Color(_lava_color.r, _lava_color.g, _lava_color.b, pulse * 0.35)
		var cc := Color(
			_lava_color.r * 0.95, _lava_color.g * 0.7,
			_lava_color.b * 0.4, pulse * 0.75
		)
		for k in range(pts.size() - 1):
			draw_line(pts[k], pts[k + 1], gc, w * 3.5, true)
		for k in range(pts.size() - 1):
			draw_line(pts[k], pts[k + 1], cc, w, true)

	# Lava pools — soft halo + bright core.
	for p in _pools:
		var pulse := (sin(_time * 1.1 + p["phase"]) * 0.5 + 0.5) * glow
		var pos: Vector2 = p["pos"]
		var r: float = p["r"]
		draw_circle(
			pos, r * 2.2,
			Color(_lava_color.r, _lava_color.g * 0.5, 0.0, pulse * 0.12)
		)
		draw_circle(
			pos, r,
			Color(_lava_color.r, _lava_color.g * 0.8, _lava_color.b * 0.3, pulse * 0.55)
		)
