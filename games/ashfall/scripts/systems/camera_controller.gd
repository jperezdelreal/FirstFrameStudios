## Camera controller for the fight scene. Follows both fighters with smooth
## interpolation, zooms based on distance, and clamps to stage boundaries.
class_name CameraController
extends Camera2D

## References to both fighters — set by FightScene on _ready().
var fighter1: Node2D
var fighter2: Node2D

## Stage boundary X coordinates (inner edges of walls).
@export var stage_left: float = -300.0
@export var stage_right: float = 940.0

## Fixed vertical center for the camera.
@export var camera_y: float = 180.0

## Zoom limits: higher value = tighter (closer), lower = wider.
@export var zoom_min: Vector2 = Vector2(0.75, 0.75)  # widest — fighters far apart
@export var zoom_max: Vector2 = Vector2(1.3, 1.3)    # tightest — fighters close

## Distance thresholds that map to zoom range.
@export var distance_close: float = 150.0
@export var distance_far: float = 700.0

## Lerp weight per physics frame — lower = smoother.
@export var position_smoothing: float = 0.08
@export var zoom_smoothing: float = 0.06

## Viewport size for boundary clamping.
var _viewport_size: Vector2


func _ready() -> void:
	_viewport_size = get_viewport_rect().size


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(fighter1) or not is_instance_valid(fighter2):
		return

	var target_pos := _calculate_target_position()
	var target_zoom := _calculate_target_zoom()

	# Clamp position so the camera never shows past stage edges.
	target_pos.x = _clamp_to_stage(target_pos.x, target_zoom.x)

	# Smooth interpolation.
	global_position = global_position.lerp(target_pos, position_smoothing)
	zoom = zoom.lerp(target_zoom, zoom_smoothing)


func _calculate_target_position() -> Vector2:
	var midpoint_x := (fighter1.global_position.x + fighter2.global_position.x) / 2.0
	return Vector2(midpoint_x, camera_y)


func _calculate_target_zoom() -> Vector2:
	var distance := absf(fighter1.global_position.x - fighter2.global_position.x)
	# Normalize distance into 0..1 range between close and far thresholds.
	var t := clampf(
		(distance - distance_close) / (distance_far - distance_close), 0.0, 1.0
	)
	# t=0 (close) → zoom_max (tight), t=1 (far) → zoom_min (wide).
	return zoom_max.lerp(zoom_min, t)


func _clamp_to_stage(x: float, zoom_level: float) -> float:
	var half_visible_width := _viewport_size.x / (2.0 * zoom_level)
	var min_x := stage_left + half_visible_width
	var max_x := stage_right - half_visible_width
	if min_x > max_x:
		# Stage narrower than visible area — just center it.
		return (stage_left + stage_right) / 2.0
	return clampf(x, min_x, max_x)