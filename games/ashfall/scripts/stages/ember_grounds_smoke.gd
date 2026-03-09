## Drifting smoke plumes and volcanic haze from the background.
## Density and tint scale with round progression for atmosphere buildup.
## Uses frame-based animation in _physics_process per GDSCRIPT-STANDARDS Rule 7.
## Includes horizontal haze bands at the horizon for depth layering.
extends Node2D

var _density := 0.3
var _tint := Color(0.12, 0.11, 0.10)
var _frame: int = 0
var _wisps: Array = []
var _haze_bands: Array = []


func _ready() -> void:
	_build_wisps()
	_build_haze_bands()


func _build_wisps() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	for i in range(28):
		_wisps.append({
			"base_x": rng.randf_range(150.0, 1130.0),
			"base_y": rng.randf_range(50.0, 360.0),
			"size": rng.randf_range(35.0, 130.0),
			"drift": rng.randf_range(2.5, 14.0),
			"alpha": rng.randf_range(0.018, 0.06),
			"phase": rng.randf_range(0.0, TAU),
			"wobble": rng.randf_range(5.0, 22.0),
			"layer": rng.randi_range(0, 2),
		})


func _build_haze_bands() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 88
	for i in range(5):
		_haze_bands.append({
			"y": rng.randf_range(280.0, 420.0),
			"height": rng.randf_range(20.0, 55.0),
			"alpha": rng.randf_range(0.012, 0.035),
			"drift": rng.randf_range(1.0, 4.0),
			"phase": rng.randf_range(0.0, TAU),
		})


## Primary visual data from main controller (round-reactive).
func set_visual_data(d: float, tint_col: Color) -> void:
	_density = d
	_tint = tint_col


## Backward-compatible setter.
func set_density(d: float) -> void:
	_density = d


func _physics_process(_delta: float) -> void:
	_frame += 1
	queue_redraw()


func _draw() -> void:
	var t: float = float(_frame) / 60.0

	# ── Horizontal haze bands at horizon for depth ──
	for band in _haze_bands:
		var band_alpha: float = (band["alpha"] as float) * _density
		if band_alpha < 0.002:
			continue
		var bx := sin(t * 0.15 + (band["phase"] as float)) * 20.0
		var by: float = band["y"]
		var bh: float = band["height"]
		draw_rect(
			Rect2(bx - 40.0, by, 1360.0, bh),
			Color(_tint.r * 0.9, _tint.g * 0.85, _tint.b * 0.8, band_alpha * 0.7)
		)
		# Softer inner band.
		draw_rect(
			Rect2(bx - 20.0, by + bh * 0.2, 1320.0, bh * 0.6),
			Color(_tint.r, _tint.g * 0.9, _tint.b * 0.85, band_alpha * 0.45)
		)

	# ── Drifting smoke wisps ──
	for w in _wisps:
		var layer: int = w["layer"]
		var layer_alpha_mult: float = 0.5 + float(layer) * 0.25
		var alpha: float = (w["alpha"] as float) * _density * layer_alpha_mult
		if alpha < 0.002:
			continue

		var x: float = (w["base_x"] as float) + sin(t * 0.3 + (w["phase"] as float)) * (w["wobble"] as float)
		x += t * (w["drift"] as float)
		x = fmod(x + 250.0, 1780.0) - 250.0
		var y: float = (w["base_y"] as float) - sin(t * 0.2 + (w["phase"] as float)) * 12.0
		var sz: float = (w["size"] as float) + sin(t * 0.4 + (w["phase"] as float)) * 10.0

		# Layered circles with round-reactive tint for soft volumetric look.
		draw_circle(
			Vector2(x, y), sz * 1.35,
			Color(_tint.r * 1.1, _tint.g, _tint.b * 0.95, alpha * 0.35)
		)
		draw_circle(
			Vector2(x, y), sz,
			Color(_tint.r, _tint.g * 0.92, _tint.b * 0.88, alpha * 0.65)
		)
		draw_circle(
			Vector2(x + sz * 0.22, y - sz * 0.12),
			sz * 0.6,
			Color(_tint.r * 0.85, _tint.g * 0.8, _tint.b * 0.75, alpha * 0.45)
		)
		# Warm inner highlight for later rounds.
		if _density > 0.45:
			draw_circle(
				Vector2(x - sz * 0.1, y + sz * 0.08),
				sz * 0.35,
				Color(
					_tint.r * 1.3, _tint.g * 0.7, _tint.b * 0.4,
					alpha * 0.2 * (_density - 0.45) * 1.8
				)
			)
