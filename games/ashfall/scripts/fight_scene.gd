## Fight scene controller. Sets up fighters, wires signals through
## EventBus, and manages the fight lifecycle.
extends Node2D

@onready var fighter1: Fighter = $Fighters/Fighter1
@onready var fighter2: Fighter = $Fighters/Fighter2
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	# Cross-reference opponents
	fighter1.opponent = fighter2
	fighter2.opponent = fighter1

	# Visual differentiation — Kael is warm (orange), Rhena is cool (blue)
	var visual2 := fighter2.get_node_or_null("Visual") as ColorRect
	if visual2:
		visual2.color = Color(0.2, 0.4, 0.8, 1)

	# Wire fighter signals to EventBus
	fighter1.took_damage.connect(_on_fighter_damaged)
	fighter2.took_damage.connect(_on_fighter_damaged)
	fighter1.knocked_out.connect(_on_fighter_ko)
	fighter2.knocked_out.connect(_on_fighter_ko)

	GameState.reset_match()

	# Wire hit_landed signal for damage application
	EventBus.hit_landed.connect(_on_hit_landed)

	# Start the round system
	RoundManager.start_match(fighter1, fighter2)

func _physics_process(_delta: float) -> void:
	_update_camera()

func _update_camera() -> void:
	if not camera or not fighter1 or not fighter2:
		return
	# Track midpoint between fighters
	var midpoint := (fighter1.global_position + fighter2.global_position) / 2.0
	camera.global_position.x = midpoint.x
	# Zoom based on distance
	var distance := abs(fighter1.global_position.x - fighter2.global_position.x)
	if distance < 200:
		camera.zoom = Vector2(1.1, 1.1)
	elif distance > 400:
		camera.zoom = Vector2(0.9, 0.9)
	else:
		camera.zoom = Vector2(1.0, 1.0)

func _on_fighter_damaged(fighter_node, amount: int, remaining_hp: int) -> void:
	EventBus.fighter_damaged.emit(fighter_node, amount, remaining_hp)

func _on_fighter_ko(fighter_node) -> void:
	EventBus.fighter_ko.emit(fighter_node)

func _on_hit_landed(attacker, target, move: Dictionary) -> void:
	if not target or not is_instance_valid(target):
		return
	var damage: int = move.get("damage", 10)
	if target.has_method("take_damage"):
		target.take_damage(damage)
