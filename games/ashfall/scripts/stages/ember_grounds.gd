## Ember Grounds — volcanic fighting arena for Ashfall.
## Reacts to Ember gauge (EventBus.ember_changed) and escalates
## across rounds (EventBus.round_started) from dormant to eruption.
## Round 1: Dormant (cool obsidian, dim lava, blue-gray sky).
## Round 2: Warming (amber glow, brightening lava, haze thickens).
## Round 3: Eruption (intense reds/oranges, active lava, full atmosphere).
extends Node2D

const STAGE_WIDTH := 1280
const STAGE_HEIGHT := 720
const FLOOR_Y := 560.0

# ── Round palette arrays: index 0 = dormant, 1 = warming, 2 = eruption ──

# Sky gradient — deep blue-black to volcanic amber.
const R_SKY_CALM = [
	Color(0.04, 0.025, 0.025),
	Color(0.12, 0.05, 0.018),
	Color(0.22, 0.07, 0.015),
]
const R_SKY_HOT = [
	Color(0.10, 0.04, 0.025),
	Color(0.26, 0.09, 0.025),
	Color(0.42, 0.13, 0.035),
]

# Lava glow (near-layer background strip).
const R_LAVA_CALM = [
	Color(0.30, 0.08, 0.0, 0.08),
	Color(0.65, 0.18, 0.0, 0.28),
	Color(0.90, 0.32, 0.04, 0.50),
]
const R_LAVA_HOT = [
	Color(0.65, 0.24, 0.03, 0.45),
	Color(0.95, 0.42, 0.05, 0.72),
	Color(1.0, 0.55, 0.10, 0.92),
]

# Volcano silhouettes — near-black to warm-tinted dark.
const R_SIL_CALM = [
	Color(0.035, 0.02, 0.018),
	Color(0.06, 0.03, 0.015),
	Color(0.09, 0.04, 0.018),
]
const R_SIL_HOT = [
	Color(0.07, 0.032, 0.02),
	Color(0.12, 0.055, 0.025),
	Color(0.18, 0.075, 0.032),
]

# Floor obsidian base color.
const R_FLOOR_BASE_CALM = [
	Color(0.042, 0.036, 0.032),
	Color(0.052, 0.040, 0.030),
	Color(0.062, 0.044, 0.028),
]
const R_FLOOR_BASE_HOT = [
	Color(0.055, 0.040, 0.034),
	Color(0.068, 0.048, 0.033),
	Color(0.085, 0.054, 0.030),
]

# Floor crack lava glow color.
const R_CRACK_GLOW_CALM = [
	Color(0.45, 0.10, 0.0),
	Color(0.72, 0.22, 0.02),
	Color(1.0, 0.38, 0.05),
]
const R_CRACK_GLOW_HOT = [
	Color(0.75, 0.28, 0.04),
	Color(1.0, 0.45, 0.06),
	Color(1.0, 0.60, 0.12),
]

# Floor top-surface highlight for visual grounding.
const R_FLOOR_HIGHLIGHT = [
	Color(0.07, 0.06, 0.05, 0.45),
	Color(0.11, 0.075, 0.05, 0.55),
	Color(0.16, 0.09, 0.045, 0.65),
]

# Ember particle core color.
const R_EMBER_CORE = [
	Color(0.85, 0.45, 0.08),
	Color(1.0, 0.55, 0.12),
	Color(1.0, 0.38, 0.06),
]

# Smoke tint color.
const R_SMOKE_TINT_CALM = [
	Color(0.11, 0.10, 0.10),
	Color(0.15, 0.12, 0.09),
	Color(0.22, 0.14, 0.08),
]
const R_SMOKE_TINT_HOT = [
	Color(0.14, 0.12, 0.11),
	Color(0.20, 0.15, 0.10),
	Color(0.28, 0.17, 0.09),
]

# Vignette glow color.
const R_VIGNETTE_COLOR = [
	Color(0.25, 0.12, 0.08),
	Color(0.65, 0.28, 0.06),
	Color(0.95, 0.35, 0.05),
]

const R_EMBER_RATE = [0.15, 0.5, 1.0]
const R_SMOKE_DENSITY = [0.3, 0.6, 1.0]
const R_VIGNETTE = [0.0, 0.15, 0.4]
const R_LAVA_FLOW_ALPHA = [0.06, 0.25, 0.55]

var _current_round := 0
var _target_round := 0
var _round_lerp := 0.0
var _round_tween: Tween
var _ember_values: Array[int] = [0, 0]
var _ember_intensity := 0.0

@onready var _sky: ColorRect = $ParallaxBackground/SkyLayer/Sky
@onready var _lava_glow: ColorRect = $ParallaxBackground/NearLayer/LavaGlow
@onready var _volcano_left: Polygon2D = $ParallaxBackground/MidLayer/VolcanoLeft
@onready var _volcano_center: Polygon2D = $ParallaxBackground/MidLayer/VolcanoCenter
@onready var _volcano_right: Polygon2D = $ParallaxBackground/MidLayer/VolcanoRight
@onready var _lava_flow_left: Polygon2D = $ParallaxBackground/MidLayer/LavaFlowLeft
@onready var _lava_flow_right: Polygon2D = $ParallaxBackground/MidLayer/LavaFlowRight


func _ready() -> void:
	EventBus.ember_changed.connect(_on_ember_changed)
	EventBus.round_started.connect(_on_round_started)
	_apply_visuals()


func _on_ember_changed(player_id: int, new_value: int) -> void:
	var idx := clampi(player_id - 1, 0, 1)
	_ember_values[idx] = new_value
	_ember_intensity = clampf(
		float(maxi(_ember_values[0], _ember_values[1])) / 100.0, 0.0, 1.0
	)
	_apply_visuals()


func _on_round_started(round_number: int) -> void:
	var new_target := clampi(round_number - 1, 0, 2)
	if new_target == _current_round and new_target == _target_round:
		return
	if _round_tween and _round_tween.is_valid():
		_round_tween.kill()
		_current_round = _target_round
		_round_lerp = 0.0
	_target_round = new_target
	if _target_round != _current_round:
		_round_tween = create_tween()
		_round_tween.tween_method(
			_set_round_lerp, 0.0, 1.0, 1.5
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		_round_tween.tween_callback(_finish_round_transition)
	_apply_visuals()


func _set_round_lerp(t: float) -> void:
	_round_lerp = t
	_apply_visuals()


func _finish_round_transition() -> void:
	_current_round = _target_round
	_round_lerp = 0.0
	_apply_visuals()


## Interpolate a color across round palettes.
func _rc(arr: Array) -> Color:
	return (arr[_current_round] as Color).lerp(arr[_target_round] as Color, _round_lerp)


## Interpolate a float across round values.
func _rf(arr: Array) -> float:
	return lerpf(float(arr[_current_round]), float(arr[_target_round]), _round_lerp)


func _apply_visuals() -> void:
	var sky_color := _rc(R_SKY_CALM).lerp(_rc(R_SKY_HOT), _ember_intensity)
	var lava_color := _rc(R_LAVA_CALM).lerp(_rc(R_LAVA_HOT), _ember_intensity)
	var sil_color := _rc(R_SIL_CALM).lerp(_rc(R_SIL_HOT), _ember_intensity)

	if _sky:
		_sky.color = sky_color
	if _lava_glow:
		_lava_glow.color = lava_color
	for v in [_volcano_left, _volcano_center, _volcano_right]:
		if v:
			v.color = sil_color

	# Lava flows on volcano slopes.
	var flow_alpha := _rf(R_LAVA_FLOW_ALPHA) + _ember_intensity * 0.2
	var flow_color := Color(
		lava_color.r, lava_color.g * 0.8, lava_color.b * 0.5, flow_alpha
	)
	for f in [_lava_flow_left, _lava_flow_right]:
		if f:
			f.color = flow_color

	# Compute round-reactive data for sub-effects.
	var ember_rate := _rf(R_EMBER_RATE)
	var smoke_density := _rf(R_SMOKE_DENSITY)
	var vignette_str := _rf(R_VIGNETTE)

	var floor_base := _rc(R_FLOOR_BASE_CALM).lerp(_rc(R_FLOOR_BASE_HOT), _ember_intensity)
	var crack_glow := _rc(R_CRACK_GLOW_CALM).lerp(_rc(R_CRACK_GLOW_HOT), _ember_intensity)
	var floor_highlight := _rc(R_FLOOR_HIGHLIGHT)
	var ember_core := _rc(R_EMBER_CORE)
	var smoke_tint := _rc(R_SMOKE_TINT_CALM).lerp(_rc(R_SMOKE_TINT_HOT), _ember_intensity)
	var vignette_glow := _rc(R_VIGNETTE_COLOR)

	if has_node("LavaFloor"):
		$LavaFloor.set_visual_data(
			_ember_intensity, lava_color, floor_base, crack_glow, floor_highlight
		)
	if has_node("EmberParticles"):
		$EmberParticles.set_visual_data(ember_rate, ember_core)
	if has_node("ParallaxBackground/SmokeLayer/Smoke"):
		$ParallaxBackground/SmokeLayer/Smoke.set_visual_data(smoke_density, smoke_tint)
	if has_node("Vignette"):
		$Vignette.set_visual_data(vignette_str, _ember_intensity, vignette_glow)


## Returns the spawn position for a given player (1 or 2).
func get_spawn_position(player_id: int) -> Vector2:
	match player_id:
		1: return $SpawnPositions/P1Spawn.position
		_: return $SpawnPositions/P2Spawn.position
