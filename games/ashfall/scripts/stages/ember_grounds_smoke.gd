## Drifting smoke plumes from the volcanic background.
## Density scales with round progression for atmosphere buildup.
extends Node2D

var _density := 0.3
var _time := 0.0
var _wisps: Array = []


func _ready() -> void:
	_build_wisps()


func _build_wisps() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	for i in range(24):
		_wisps.append({
			"base_x": rng.randf_range(200.0, 1100.0),
			"base_y": rng.randf_range(60.0, 350.0),
			"size": rng.randf_range(40.0, 120.0),
			"drift": rng.randf_range(3.0, 12.0),
			"alpha": rng.randf_range(0.02, 0.06),
			"phase": rng.randf_range(0.0, TAU),
			"wobble": rng.randf_range(5.0, 20.0),
		})


func set_density(d: float) -> void:
	_density = d


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for w in _wisps:
		var alpha: float = w["alpha"] * _density
		if alpha < 0.003:
			continue
		var x: float = w["base_x"] + sin(_time * 0.3 + w["phase"]) * w["wobble"]
		x += _time * w["drift"]
		x = fmod(x + 200.0, 1680.0) - 200.0
		var y: float = w["base_y"] - sin(_time * 0.2 + w["phase"]) * 10.0
		var sz: float = w["size"] + sin(_time * 0.4 + w["phase"]) * 8.0

		# Layered circles for soft smoke look.
		draw_circle(Vector2(x, y), sz * 1.3, Color(0.18, 0.16, 0.15, alpha * 0.4))
		draw_circle(Vector2(x, y), sz, Color(0.14, 0.12, 0.11, alpha * 0.7))
		draw_circle(
			Vector2(x + sz * 0.25, y - sz * 0.15),
			sz * 0.65,
			Color(0.10, 0.09, 0.08, alpha * 0.5)
		)
