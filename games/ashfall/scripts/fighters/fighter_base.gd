## Base class for all playable fighters. Owns health, facing, movement
## constants, input buffer, fighter controller, animation controller,
## and state-machine wiring.
## Character-specific scripts extend this to override constants or add moves.
class_name Fighter
extends CharacterBody2D

signal took_damage(fighter: Fighter, amount: int, remaining_hp: int)
signal knocked_out(fighter: Fighter)

# --- Exported tunables (GDD 2.4) ---
@export var player_id: int = 1
@export var max_health: int = 1000
@export var walk_speed: float = 200.0       # px/sec forward
@export var walk_back_speed: float = 170.0  # px/sec backward (retreat penalty)
@export var jump_force: float = 520.0       # initial upward velocity
@export var gravity: float = 900.0          # px/sec²
@export var crouch_hurtbox_scale: float = 0.6
@export var moveset: FighterMoveset

# --- Runtime state ---
var health: int = 1000
var ember_meter: int = 0
var facing_direction: int = 1  # 1 = right, -1 = left
var is_grounded: bool = true
var opponent: Fighter

var facing_right: bool:
	get: return facing_direction > 0

# --- Node references ---
@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitboxes: Node2D = $Hitboxes
@onready var attack_origin: Marker2D = $AttackOrigin
@onready var input_buffer: InputBuffer = $InputBuffer
@onready var controller: FighterController = $FighterController
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	health = max_health
	# Wire input buffer
	input_buffer.player_id = player_id
	input_buffer.facing_right = facing_right
	# Wire fighter reference into every state before the first physics tick
	for state_node in state_machine.get_children():
		if state_node is FighterState:
			state_node.fighter = self
	# Wire controller
	if controller:
		controller.fighter = self
		controller.input_buffer = input_buffer
		controller.moveset = moveset
	# Ensure state machine starts in idle (safety fallback if
	# initial_state export wasn't resolved from the scene file)
	if not state_machine.current_state:
		state_machine.transition_to("idle", {})


func _physics_process(_delta: float) -> void:
	_update_facing()
	input_buffer.update()
	input_buffer.facing_right = facing_right
	is_grounded = is_on_floor()


# --- Facing ---

func _update_facing() -> void:
	if not opponent or not state_machine.current_state:
		return
	var state_name := state_machine.current_state.name.to_lower()
	# Don't flip mid-attack, mid-hitstun, mid-throw, or when KO'd
	if state_name in ["attack", "hit", "ko", "throw"]:
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


# --- Input helpers (routed through InputBuffer for buffering + consume) ---

func is_input_pressed(action: String) -> bool:
	match action:
		"up": return input_buffer.is_held("up")
		"down": return input_buffer.is_held("down")
		"left": return input_buffer.is_held("left")
		"right": return input_buffer.is_held("right")
		"block": return input_buffer.is_held("block")
	return false


func is_input_just_pressed(action: String) -> bool:
	match action:
		"up": return input_buffer.check_button("just_up")
		"down": return input_buffer.check_button("just_down")
		"left": return input_buffer.check_button("just_left")
		"right": return input_buffer.check_button("just_right")
		"light_punch": return input_buffer.check_button("lp")
		"heavy_punch": return input_buffer.check_button("hp")
		"light_kick": return input_buffer.check_button("lk")
		"heavy_kick": return input_buffer.check_button("hk")
	return false


func is_holding_back() -> bool:
	return input_buffer.is_holding_back()


func is_holding_forward() -> bool:
	return input_buffer.is_holding_forward()
