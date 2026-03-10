## Camera controller for the fight scene. Dynamically frames 2-fighter combat
## like a fighting game (Guilty Gear style). Tight zoom when close, wide when
## far, smooth tracking at the midpoint, vertical compensation for jumps,
## and edge clamping to stage boundaries.
class_name CameraController
extends Camera2D

## References to both fighters — set by FightScene on _ready().
var fighter1: Node2D
var fighter2: Node2D

# -- Stage boundaries --

## Stage boundary X coordinates (inner edges of walls).
@export var stage_left: float = -300.0
@export var stage_right: float = 940.0

## Stage floor Y and ceiling Y for vertical clamping.
## Set below the physics floor (y=300) so the camera can show ground area
## and center fighters properly on the 1920×1080 viewport.
@export var stage_floor_y: float = 500.0
@export var stage_ceiling_y: float = -100.0

# -- Zoom tuning --

## Zoom limits: higher value = tighter (closer), lower = wider.
@export var zoom_min: Vector2 = Vector2(0.75, 0.75)
@export var zoom_max: Vector2 = Vector2(1.3, 1.3)

## Distance thresholds that map to zoom range.
@export var distance_close: float = 150.0
@export var distance_far: float = 700.0

# -- Tracking tuning --

## Lerp weight per physics frame — lower = smoother.
@export var follow_speed: float = 0.08
@export var zoom_speed: float = 0.06

## Resting vertical center when both fighters are grounded.
@export var camera_y: float = 180.0

## How aggressively the camera follows vertical movement (0 = ignore, 1 = instant).
@export var vertical_follow_weight: float = 0.35

# -- Fighting game framing --

## Fraction of screen width reserved for fighter framing (0.6 = fighters in
## middle 60%). The remaining space becomes margin on each side.
@export var framing_ratio: float = 0.65

## Extra horizontal padding (pixels) added to each side beyond framing_ratio.
@export var margin_horizontal: float = 40.0

# -- Internal state --

var _viewport_size: Vector2


func _ready() -> void:
	_viewport_size = get_viewport_rect().size


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(fighter1) or not is_instance_valid(fighter2):
		return

	var target_pos: Vector2 = _calculate_target_position()
	var target_zoom: Vector2 = _calculate_target_zoom()

	# Ensure framing margins — zoom out further if fighters would fall outside
	# the desired screen region at the current zoom level.
	target_zoom = _enforce_framing_margins(target_zoom)

	# Clamp position so the camera never shows past stage edges.
	target_pos.x = _clamp_to_stage_x(target_pos.x, target_zoom.x)
	target_pos.y = _clamp_to_stage_y(target_pos.y, target_zoom.y)

	# Smooth interpolation (frame-rate-independent via fixed physics tick).
	global_position = global_position.lerp(target_pos, follow_speed)
	zoom = zoom.lerp(target_zoom, zoom_speed)


## Returns the ideal camera center: horizontal midpoint between fighters,
## vertical offset blended toward the highest fighter when airborne.
func _calculate_target_position() -> Vector2:
	var midpoint_x: float = (fighter1.global_position.x + fighter2.global_position.x) / 2.0

	# Vertical compensation: blend toward the fighter that is highest (lowest Y).
	var highest_y: float = minf(fighter1.global_position.y, fighter2.global_position.y)
	var vertical_offset: float = minf(highest_y - camera_y, 0.0)
	var target_y: float = camera_y + vertical_offset * vertical_follow_weight

	return Vector2(midpoint_x, target_y)


## Maps fighter distance to a zoom level. Close = tight (zoom_max),
## far = wide (zoom_min).
func _calculate_target_zoom() -> Vector2:
	var distance: float = absf(fighter1.global_position.x - fighter2.global_position.x)
	var t: float = clampf(
		(distance - distance_close) / (distance_far - distance_close), 0.0, 1.0
	)
	return zoom_max.lerp(zoom_min, t)


## If both fighters wouldn't fit inside the desired framing region at the
## current zoom, widen the zoom until they do.
func _enforce_framing_margins(base_zoom: Vector2) -> Vector2:
	var distance: float = absf(fighter1.global_position.x - fighter2.global_position.x)
	var required_width: float = distance + margin_horizontal * 2.0
	# Fighters should occupy at most `framing_ratio` of the visible width.
	var visible_width_needed: float = required_width / framing_ratio
	var zoom_for_framing: float = _viewport_size.x / visible_width_needed
	# Never zoom tighter than what framing allows, but respect zoom_min floor.
	var final_zoom: float = clampf(
		minf(base_zoom.x, zoom_for_framing), zoom_min.x, zoom_max.x
	)
	return Vector2(final_zoom, final_zoom)


## Clamps camera X so the visible area stays within stage boundaries.
func _clamp_to_stage_x(x: float, zoom_level: float) -> float:
	var half_visible_width: float = _viewport_size.x / (2.0 * zoom_level)
	var min_x: float = stage_left + half_visible_width
	var max_x: float = stage_right - half_visible_width
	if min_x > max_x:
		return (stage_left + stage_right) / 2.0
	return clampf(x, min_x, max_x)


## Clamps camera Y so the visible area stays within stage vertical boundaries.
func _clamp_to_stage_y(y: float, zoom_level: float) -> float:
	var half_visible_height: float = _viewport_size.y / (2.0 * zoom_level)
	var min_y: float = stage_ceiling_y + half_visible_height
	var max_y: float = stage_floor_y - half_visible_height
	if min_y > max_y:
		return (stage_ceiling_y + stage_floor_y) / 2.0
	return clampf(y, min_y, max_y)