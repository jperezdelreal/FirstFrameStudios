## Cracked obsidian floor with animated lava seeping through fissures.
## Positioned at the ground surface; draws obsidian texture, depth-shaded
## gradient, branching cracks, lava channels at edges, pools, and rock debris.
## Round-reactive: base/crack/highlight colors shift from cool dormant to
## volcanic eruption via set_visual_data() called by ember_grounds.gd.
extends Node2D

var _intensity := 0.0
var _lava_color := Color(0.8, 0.25, 0.0, 0.5)
var _base_color := Color(0.045, 0.038, 0.032)
var _crack_color := Color(0.8, 0.25, 0.0)
var _highlight_color := Color(0.08, 0.065, 0.055, 0.5)
var _frame: int = 0
var _cracks: Array = []
var _pools: Array = []
var _patches: Array = []
var _rocks: Array = []
var _edge_channels: Array = []


func _ready() -> void:
	_build_cracks()
	_build_pools()
	_build_patches()
	_build_rocks()
	_build_edge_channels()


func _build_cracks() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(22):
		var pts: Array = []
		var x := rng.randf_range(30.0, 1250.0)
		var y := rng.randf_range(8.0, 148.0)
		pts.append(Vector2(x, y))
		var seg_count: int = rng.randi_range(3, 7)
		for _j in range(seg_count):
			x = clampf(x + rng.randf_range(-42.0, 42.0), -10.0, 1290.0)
			y = clampf(y + rng.randf_range(-14.0, 22.0), 4.0, 156.0)
			pts.append(Vector2(x, y))
		var branches: Array = []
		if rng.randf() > 0.5 and pts.size() >= 3:
			var branch_idx: int = rng.randi_range(1, pts.size() - 2)
			var bp: Vector2 = pts[branch_idx]
			var branch_pts: Array = [bp]
			for _k in range(rng.randi_range(2, 4)):
				bp = Vector2(
					clampf(bp.x + rng.randf_range(-28.0, 28.0), -10.0, 1290.0),
					clampf(bp.y + rng.randf_range(-10.0, 16.0), 4.0, 156.0)
				)
				branch_pts.append(bp)
			branches.append(branch_pts)
		_cracks.append({
			"pts": pts,
			"branches": branches,
			"w": rng.randf_range(1.2, 3.2),
			"phase": rng.randf_range(0.0, TAU),
			"speed": rng.randf_range(1.0, 2.0),
		})


func _build_pools() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in range(7):
		_pools.append({
			"pos": Vector2(rng.randf_range(90.0, 1190.0), rng.randf_range(20.0, 135.0)),
			"rx": rng.randf_range(6.0, 16.0),
			"ry": rng.randf_range(4.0, 10.0),
			"phase": rng.randf_range(0.0, TAU),
		})


func _build_patches() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in range(32):
		_patches.append({
			"rect": Rect2(
				rng.randf_range(0, 1240), rng.randf_range(0, 145),
				rng.randf_range(18, 85), rng.randf_range(8, 40)
			),
			"shade_offset": rng.randf_range(-0.015, 0.018),
			"warm": rng.randf_range(0.0, 1.0),
		})


func _build_rocks() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 113
	for i in range(16):
		var cx := rng.randf_range(40.0, 1240.0)
		var cy := rng.randf_range(12.0, 146.0)
		var sz := rng.randf_range(3.0, 8.0)
		var vert_count: int = rng.randi_range(4, 7)
		var poly: Array = []
		for v in range(vert_count):
			var angle: float = TAU * float(v) / float(vert_count) + rng.randf_range(-0.3, 0.3)
			var r: float = sz * rng.randf_range(0.55, 1.0)
			poly.append(Vector2(cx + cos(angle) * r, cy + sin(angle) * r * 0.6))
		_rocks.append({
			"poly": poly,
			"shade": rng.randf_range(-0.012, 0.015),
		})


func _build_edge_channels() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 202
	for side in [0, 1]:
		var base_x: float = 8.0 if side == 0 else 1238.0
		var channel_w := rng.randf_range(30.0, 44.0)
		var segments: Array = []
		for s in range(8):
			var y_start: float = float(s) * 20.0
			segments.append({
				"y_start": y_start,
				"y_end": y_start + 20.0,
				"x_off": rng.randf_range(-5.0, 5.0),
				"w_var": rng.randf_range(-4.0, 4.0),
				"phase": rng.randf_range(0.0, TAU),
			})
		_edge_channels.append({
			"base_x": base_x,
			"width": channel_w,
			"side": side,
			"segments": segments,
		})


## Primary visual data from main controller (round-reactive colors).
func set_visual_data(ember_t: float, lava_col: Color, base_col: Color,
		crack_col: Color, highlight_col: Color) -> void:
	_intensity = ember_t
	_lava_color = lava_col
	_base_color = base_col
	_crack_color = crack_col
	_highlight_color = highlight_col


## Backward-compatible setter.
func set_intensity(ember_t: float, lava_col: Color) -> void:
	_intensity = ember_t
	_lava_color = lava_col


func _physics_process(_delta: float) -> void:
	_frame += 1
	queue_redraw()


func _draw() -> void:
	var t: float = float(_frame) / 60.0
	var glow := 0.25 + _intensity * 0.75

	# ── Base obsidian surface with vertical depth gradient ──
	var base_dark := Color(
		_base_color.r * 0.75, _base_color.g * 0.75, _base_color.b * 0.75
	)
	for row in range(8):
		var row_t: float = float(row) / 8.0
		var row_color := _base_color.lerp(base_dark, row_t)
		draw_rect(Rect2(0, row * 20, 1280, 20), row_color)

	# ── Texture variation patches ──
	for p in _patches:
		var s: float = p["shade_offset"]
		var w: float = p["warm"]
		draw_rect(p["rect"] as Rect2, Color(
			_base_color.r + s + w * 0.006,
			_base_color.g + s * 0.85,
			_base_color.b + s * 0.65 - w * 0.004,
			0.38
		))

	# ── Rock debris fragments ──
	for r in _rocks:
		var poly: Array = r["poly"]
		var s: float = r["shade"]
		if poly.size() >= 3:
			var pv := PackedVector2Array(poly)
			var colors := PackedColorArray()
			for _i in range(poly.size()):
				colors.append(Color(
					_base_color.r + s + 0.018,
					_base_color.g + s + 0.013,
					_base_color.b + s + 0.008,
					0.50
				))
			draw_polygon(pv, colors)

	# ── Lava channels at left/right edges ──
	for ch in _edge_channels:
		var bx: float = ch["base_x"]
		var cw: float = ch["width"]
		var segs: Array = ch["segments"]
		for seg in segs:
			var pulse := (sin(t * 1.2 + (seg["phase"] as float)) * 0.5 + 0.5) * glow
			var sx: float = bx + (seg["x_off"] as float)
			var sw: float = cw + (seg["w_var"] as float)
			var sy: float = seg["y_start"]
			var sh: float = (seg["y_end"] as float) - sy
			# Wide outer halo.
			draw_rect(
				Rect2(sx - sw * 0.3, sy, sw * 1.6, sh),
				Color(_lava_color.r, _lava_color.g * 0.35, 0.0, pulse * 0.07)
			)
			# Main lava channel.
			draw_rect(
				Rect2(sx, sy, sw, sh),
				Color(_lava_color.r, _lava_color.g * 0.65, _lava_color.b * 0.25, pulse * 0.42)
			)
			# Bright core strip.
			draw_rect(
				Rect2(sx + sw * 0.25, sy + 2, sw * 0.5, maxf(sh - 4, 1.0)),
				Color(
					minf(_crack_color.r * 1.15, 1.0),
					_crack_color.g * 0.85,
					_crack_color.b * 0.45,
					pulse * 0.6
				)
			)

	# ── Lava cracks: glow layer, main line, hot core ──
	for c in _cracks:
		var pts: Array = c["pts"]
		var w: float = c["w"]
		var spd: float = c["speed"]
		var pulse := (sin(t * spd + (c["phase"] as float)) * 0.5 + 0.5) * glow
		var gc := Color(_crack_color.r, _crack_color.g * 0.45, 0.0, pulse * 0.22)
		var cc := Color(
			_crack_color.r * 0.92, _crack_color.g * 0.68,
			_crack_color.b * 0.35, pulse * 0.68
		)
		var hc := Color(
			minf(_crack_color.r * 1.1, 1.0),
			minf(_crack_color.g * 1.15, 1.0),
			_crack_color.b * 0.7,
			pulse * 0.88
		)
		for k in range(pts.size() - 1):
			draw_line(pts[k], pts[k + 1], gc, w * 4.0, true)
		for k in range(pts.size() - 1):
			draw_line(pts[k], pts[k + 1], cc, w * 1.5, true)
		for k in range(pts.size() - 1):
			draw_line(pts[k], pts[k + 1], hc, maxf(w * 0.4, 0.8), true)
		# Branches.
		var branches: Array = c["branches"]
		for branch in branches:
			var bpts: Array = branch
			for k in range(bpts.size() - 1):
				draw_line(bpts[k], bpts[k + 1], gc, w * 2.5, true)
			for k in range(bpts.size() - 1):
				draw_line(bpts[k], bpts[k + 1], cc, w * 0.8, true)

	# ── Lava pools: distant halo → outer glow → core → hot center ──
	for p in _pools:
		var pulse := (sin(t * 1.1 + (p["phase"] as float)) * 0.5 + 0.5) * glow
		var pos: Vector2 = p["pos"]
		var rx: float = p["rx"]
		var ry: float = p["ry"]
		var avg_r := (rx + ry) * 0.5
		draw_circle(pos, avg_r * 2.8, Color(
			_lava_color.r, _lava_color.g * 0.25, 0.0, pulse * 0.04
		))
		draw_circle(pos, avg_r * 1.6, Color(
			_lava_color.r, _lava_color.g * 0.45, 0.0, pulse * 0.12
		))
		draw_circle(pos, avg_r, Color(
			_lava_color.r, _lava_color.g * 0.72, _lava_color.b * 0.28, pulse * 0.52
		))
		draw_circle(pos, avg_r * 0.35, Color(
			minf(_crack_color.r * 1.12, 1.0),
			minf(_crack_color.g * 1.08, 1.0),
			_crack_color.b * 0.55,
			pulse * 0.72
		))

	# ── Top surface highlight — grounds the fighters ──
	draw_rect(Rect2(0, 0, 1280, 3), Color(0.0, 0.0, 0.0, 0.32))
	draw_line(
		Vector2(0, 1), Vector2(1280, 1),
		_highlight_color, 2.0
	)
	draw_line(
		Vector2(0, 3.5), Vector2(1280, 3.5),
		Color(
			_highlight_color.r, _highlight_color.g,
			_highlight_color.b, _highlight_color.a * 0.28
		),
		1.0
	)

	# ── Bottom edge fade to darkness ──
	for i in range(4):
		var fade_t: float = float(i) / 4.0
		draw_rect(
			Rect2(0, 148 + i * 3, 1280, 3),
			Color(0.0, 0.0, 0.0, 0.12 * (1.0 - fade_t))
		)
