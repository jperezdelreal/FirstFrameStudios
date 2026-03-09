## Floating ember particles rising from the volcanic floor.
## Emission rate controlled by round progression and Ember gauge.
extends Node2D

var _emission_rate := 0.15
var _time := 0.0
var _particles: Array = []
var _rng := RandomNumberGenerator.new()

const MAX_PARTICLES := 60


func _ready() -> void:
	z_index = 5
	_rng.seed = 123


func set_emission_rate(rate: float) -> void:
	_emission_rate = rate


func _process(delta: float) -> void:
	_time += delta
	_spawn(delta)
	var alive: Array = []
	for p in _particles:
		p["age"] += delta
		if p["age"] < p["life"]:
			alive.append(p)
	_particles = alive
	queue_redraw()


func _spawn(delta: float) -> void:
	var count := int(_emission_rate * 25.0 * delta + _rng.randf())
	for i in range(mini(count, 3)):
		if _particles.size() >= MAX_PARTICLES:
			return
		_particles.append({
			"x": _rng.randf_range(40.0, 1240.0),
			"y": 560.0 + _rng.randf_range(-5.0, 5.0),
			"vx": _rng.randf_range(-12.0, 12.0),
			"vy": _rng.randf_range(-45.0, -90.0),
			"sz": _rng.randf_range(1.5, 3.5),
			"age": 0.0,
			"life": _rng.randf_range(2.5, 5.0),
			"phase": _rng.randf_range(0.0, TAU),
			"hue": _rng.randf_range(0.0, 1.0),
		})


func _draw() -> void:
	for p in _particles:
		var t: float = p["age"] / p["life"]
		var fade := (1.0 - t) * (1.0 - t)
		var x: float = p["x"] + p["vx"] * p["age"] + sin(p["age"] * 2.5 + p["phase"]) * 6.0
		var y: float = p["y"] + p["vy"] * p["age"]
		var sz: float = p["sz"] * (1.0 - t * 0.4)

		# Color: bright orange-yellow core fading to dim red.
		var r := lerpf(1.0, 0.8, p["hue"])
		var g := lerpf(0.65, 0.25, t) * lerpf(0.85, 1.0, p["hue"])
		var b := lerpf(0.1, 0.0, t)

		draw_circle(Vector2(x, y), sz * 2.5, Color(r, g * 0.4, 0.0, fade * 0.12))
		draw_circle(Vector2(x, y), sz, Color(r, g, b, fade * 0.85))
