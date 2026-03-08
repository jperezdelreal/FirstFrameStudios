## Base class for all playable fighters. Owns health, facing, movement
## constants, and the state-machine ↔ hitbox/hurtbox wiring.
## Character-specific scripts extend this to override constants or add moves.
class_name Fighter
extends CharacterBody2D

signal took_damage(fighter: Fighter, amount: int, remaining_hp: int)
signal knocked_out(fighter: Fighter)

# --- Exported tunables ---
@export var player_id: int = 1
@export var max_health: int = 1000
@export var walk_speed: float = 200.0
@export var walk_back_speed: float = 150.0
@export var jump_force: float = 500.0
@export var gravity: float = 1200.0
@export var crouch_hurtbox_scale: float = 0.6

# --- Runtime state ---
var health: int = 1000
var ember_meter: int = 0
var facing_direction: int = 1  # 1 = right, -1 = left
var is_grounded: bool = true
var opponent: Fighter

# --- Node references ---
@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitboxes: Node2D = $Hitboxes
@onready var attack_origin: Marker2D = $AttackOrigin

# --- Input helper ---
var _input_prefix: String = "p1_"


func _ready() -> void:
	health = max_health
	_input_prefix = "p%d_" % player_id
	# Wire fighter reference into every state before the first physics tick
	for state_node in state_machine.get_children():
		if state_node is FighterState:
			state_node.fighter = self
	# Ensure state machine starts in idle (safety fallback if
	# initial_state export wasn't resolved from the scene file)
	if not state_machine.current_state:
		state_machine.transition_to("idle", {})


func _physics_process(_delta: float) -> void:
	_update_facing()
	is_grounded = is_on_floor()


# --- Facing ---

func _update_facing() -> void:
	if not opponent or not state_machine.current_state:
		return
	var state_name := state_machine.current_state.name.to_lower()
	# Don't flip mid-attack, mid-hitstun, or when KO'd
	if state_name in ["attack", "hit", "ko"]:
		return
	if global_position.x < opponent.global_position.x:
		facing_direction = 1
	else:
		facing_direction = -1
	sprite.flip_h = facing_direction < 0
	attack_origin.position.x = abs(attack_origin.position.x) * facing_direction


# --- Damage interface ---

func take_damage(amount: int, knockback: Vector2, hitstun_frames: int) -> void:
	health = maxi(0, health - amount)
	took_damage.emit(self, amount, health)
	velocity += knockback
	if health <= 0:
		knocked_out.emit(self)
		state_machine.transition_to("ko", {})
	else:
		state_machine.transition_to("hit", {"hitstun_frames": hitstun_frames})


# --- Round lifecycle ---

func reset_for_round(spawn_position: Vector2) -> void:
	health = max_health
	ember_meter = 0
	global_position = spawn_position
	velocity = Vector2.ZERO
	state_machine.transition_to("idle", {})


# --- Input helpers (thin wrappers — Lando will replace with InputBuffer) ---

func is_input_pressed(action: String) -> bool:
	return Input.is_action_pressed(_input_prefix + action)


func is_input_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(_input_prefix + action)


func is_holding_back() -> bool:
	if facing_direction > 0:
		return is_input_pressed("left")
	return is_input_pressed("right")


func is_holding_forward() -> bool:
	if facing_direction > 0:
		return is_input_pressed("right")
	return is_input_pressed("left")
