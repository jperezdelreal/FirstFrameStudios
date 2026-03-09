## Floating ember particles rising from the volcanic floor.
## Emission rate and core color controlled by round progression and Ember gauge.
## Uses frame-based animation in _physics_process per GDSCRIPT-STANDARDS Rule 7.
extends Node2D

var _emission_rate := 0.15
var _core_color := Color(0.9, 0.5, 0.1)
var _frame: int = 0
var _particles: Array = []
var _rng := RandomNumberGenerator.new()

const MAX_PARTICLES := 60
const SPAWN_INTERVAL := 2


## Primary visual data from main controller (round-reactive).
func set_visual_data(rate: float, core_col: Color) -> void:
	_emission_rate = rate
	_core_color = core_col


## Backward-compatible setter.
func set_emission_rate(rate: float) -> void:
	_emission_rate = rate


func _ready() -> void:
	z_index = 5
	_rng.seed = 123


func _physics_process(_delta: float) -> void:
	_frame += 1
	# Spawn new particles on interval frames.
	if _frame % SPAWN_INTERVAL == 0:
		_spawn()
	# Age and cull dead particles.
	var alive: Array = []
	for p in _particles:
		p["age_f"] = (p["age_f"] as int) + 1
		if (p["age_f"] as int) < (p["life_f"] as int):
			alive.append(p)
	_particles = alive
	queue_redraw()


func _spawn() -> void:
	var count: int = int(_emission_rate * 2.5 + _rng.randf())
	for i in range(mini(count, 3)):
		if _particles.size() >= MAX_PARTICLES:
			return
		var base_y := 560.0 + _rng.randf_range(-6.0, 6.0)
		var life_frames: int = _rng.randi_range(150, 300)
		_particles.append({
			"x": _rng.randf_range(30.0, 1250.0),
			"y": base_y,
			"vx": _rng.randf_range(-14.0, 14.0),
			"vy": _rng.randf_range(-50.0, -95.0),
			"sz": _rng.randf_range(1.4, 3.8),
			"age_f": 0,
			"life_f": life_frames,
			"phase": _rng.randf_range(0.0, TAU),
			"hue": _rng.randf_range(0.0, 1.0),
			"trail": _rng.randf() > 0.6,
		})


func _draw() -> void:
	for p in _particles:
		var age_f: int = p["age_f"]
		var life_f: int = p["life_f"]
		var norm_t: float = float(age_f) / float(life_f)
		var age_sec: float = float(age_f) / 60.0
		var fade := (1.0 - norm_t) * (1.0 - norm_t)

		var px: float = (p["x"] as float) + (p["vx"] as float) * age_sec
		px += sin(age_sec * 2.5 + (p["phase"] as float)) * 7.0
		var py: float = (p["y"] as float) + (p["vy"] as float) * age_sec
		var sz: float = (p["sz"] as float) * (1.0 - norm_t * 0.35)
		var hue: float = p["hue"]

		# Color: blend from round-reactive core toward dim red as particle ages.
		var r := lerpf(_core_color.r, 0.75, norm_t) * lerpf(1.0, 0.85, hue)
		var g := lerpf(_core_color.g, 0.15, norm_t) * lerpf(0.9, 1.0, hue)
		var b := lerpf(_core_color.b, 0.0, norm_t)
		var pos := Vector2(px, py)

		# Glow halo.
		draw_circle(pos, sz * 3.0, Color(r, g * 0.35, 0.0, fade * 0.08))
		# Outer bloom.
		draw_circle(pos, sz * 1.8, Color(r, g * 0.5, b * 0.2, fade * 0.18))
		# Core particle.
		draw_circle(pos, sz, Color(r, g, b, fade * 0.82))

		# Trail afterglow for some particles.
		if p["trail"] as bool and age_f > 6:
			var trail_age: float = float(age_f - 6) / 60.0
			var tx: float = (p["x"] as float) + (p["vx"] as float) * trail_age
			tx += sin(trail_age * 2.5 + (p["phase"] as float)) * 7.0
			var ty: float = (p["y"] as float) + (p["vy"] as float) * trail_age
			draw_circle(
				Vector2(tx, ty), sz * 0.6,
				Color(r * 0.7, g * 0.3, 0.0, fade * 0.2)
			)
