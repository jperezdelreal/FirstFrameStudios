## Ember Grounds — volcanic fighting arena for Ashfall.
## Background intensity shifts as Ember builds (EventBus.ember_changed).
extends Node2D

## Stage dimensions in viewport coordinates (GDD §4.1, 2× base 640×360).
const STAGE_WIDTH := 1280
const STAGE_HEIGHT := 720
const FLOOR_Y := 560.0

## Ember-reactive color palette.
const SKY_CALM := Color(0.12, 0.05, 0.02)
const SKY_INTENSE := Color(0.30, 0.08, 0.02)
const LAVA_CALM := Color(0.7, 0.2, 0.0, 0.25)
const LAVA_INTENSE := Color(1.0, 0.45, 0.05, 0.85)
const SILHOUETTE_CALM := Color(0.07, 0.035, 0.015)
const SILHOUETTE_INTENSE := Color(0.12, 0.05, 0.025)

var _ember_values: Array[int] = [0, 0]
var _ember_intensity: float = 0.0

@onready var _sky: ColorRect = $ParallaxBackground/SkyLayer/Sky
@onready var _lava_glow: ColorRect = $ParallaxBackground/NearLayer/LavaGlow
@onready var _volcano_left: Polygon2D = $ParallaxBackground/MidLayer/VolcanoLeft
@onready var _volcano_center: Polygon2D = $ParallaxBackground/MidLayer/VolcanoCenter
@onready var _volcano_right: Polygon2D = $ParallaxBackground/MidLayer/VolcanoRight


func _ready() -> void:
	EventBus.ember_changed.connect(_on_ember_changed)
	_apply_ember_visuals(0.0)


func _on_ember_changed(player_id: int, new_value: int) -> void:
	var idx := clampi(player_id - 1, 0, 1)
	_ember_values[idx] = new_value
	_ember_intensity = clampf(
		float(maxi(_ember_values[0], _ember_values[1])) / 100.0, 0.0, 1.0
	)
	_apply_ember_visuals(_ember_intensity)


func _apply_ember_visuals(t: float) -> void:
	if _sky:
		_sky.color = SKY_CALM.lerp(SKY_INTENSE, t)
	if _lava_glow:
		_lava_glow.color = LAVA_CALM.lerp(LAVA_INTENSE, t)
	var sil := SILHOUETTE_CALM.lerp(SILHOUETTE_INTENSE, t)
	if _volcano_left:
		_volcano_left.color = sil
	if _volcano_center:
		_volcano_center.color = sil
	if _volcano_right:
		_volcano_right.color = sil


## Returns the spawn position for a given player (1 or 2).
func get_spawn_position(player_id: int) -> Vector2:
	match player_id:
		1: return $SpawnPositions/P1Spawn.position
		_: return $SpawnPositions/P2Spawn.position
