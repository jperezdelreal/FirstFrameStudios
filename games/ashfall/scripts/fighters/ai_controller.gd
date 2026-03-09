## AI opponent controller for single-player fighting.
## Drives a fighter through synthetic input injection into its InputBuffer —
## same code path as a human player, no special-case fighter logic.
## Reads opponent position and state (visual info only, never raw inputs).
class_name AIController
extends Node

enum AIState { IDLE, APPROACH, ATTACK, BLOCK, RETREAT }

# --- Configuration (exported for tuning) ---

## The fighter this AI controls. Set via inspector or fight_scene.gd.
@export var fighter: CharacterBody2D
## Frames before the AI acts on observed opponent changes (simulates reaction time).
@export var reaction_delay_min: int = 8
@export var reaction_delay_max: int = 14
## Base frames between decisions. Variance applied each cycle.
@export var decision_interval: int = 24
## 0.0 = passive, 1.0 = relentless. Weights attack vs defensive choices.
@export var aggression: float = 0.6
## Probability of blocking when the opponent is attacking.
@export var block_chance: float = 0.5
## Probability of teching an incoming throw.
@export var throw_tech_chance: float = 0.4
## Probability of using anti-air when opponent jumps.
@export var anti_air_chance: float = 0.3

# --- Distance thresholds (pixels) ---
const CLOSE_RANGE: float = 120.0
const MID_RANGE: float = 300.0

# --- Internal state ---
var ai_state: AIState = AIState.IDLE
var decision_timer: int = 0
var action_frames: int = 0
var opponent: CharacterBody2D = null
var _reaction_queue: Array[Dictionary] = []

# Combo execution state
var _combo_queue: Array[String] = []
var _combo_timer: int = 0

# Attack weights — higher = more likely. Tunable per-character.
var attack_weights: Dictionary = {
	"lp": 35,
	"lk": 25,
	"hp": 20,
	"hk": 20,
}

# States where the AI should not inject new inputs
const PROTECTED_STATES: Array[String] = [
	"attackstate", "hitstate", "kostate", "launchstate",
	"blockstate", "crouchblockstate", "introstate",
]

# ------------------------------------------------------------------
# Lifecycle
# ------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	if not _has_valid_refs():
		return

	if _in_protected_state():
		# Reset decision flow so we re-evaluate cleanly after recovery.
		decision_timer = 0
		action_frames = 0
		_combo_queue.clear()
		return

	# 1. Process queued reactions (delayed response to opponent actions).
	_tick_reactions()

	# 2. Execute queued combo inputs.
	if _tick_combo():
		return

	# 3. If we're mid-action, keep executing the current state.
	if action_frames > 0:
		action_frames -= 1
		_execute_state()
		return

	# 4. Decision cooldown.
	decision_timer -= 1
	if decision_timer > 0:
		_execute_state()
		return

	# 5. Fresh decision.
	_evaluate()
	decision_timer = decision_interval + _randi_range(-4, 4)

# ------------------------------------------------------------------
# Decision-making (runs every decision_interval frames)
# ------------------------------------------------------------------

func _evaluate() -> void:
	var dist := _distance_to_opponent()
	var opp_state := _opponent_state_name()

	# --- Reactive layer (checked first, overrides distance logic) ---
	if opp_state == "attackstate" or opp_state == "airattackstate":
		if _roll(block_chance):
			_queue_reaction(AIState.BLOCK, 12)
			return

	if opp_state == "jumpstate":
		if _roll(anti_air_chance):
			_queue_reaction(AIState.ATTACK, 6)
			return

	# --- Distance-based proactive decisions ---
	if dist > MID_RANGE:
		# Far: close the gap.
		_set_state(AIState.APPROACH, _randi_range(20, 40))
	elif dist > CLOSE_RANGE:
		# Mid range: mix of approach, attack, block, retreat.
		var roll := randf()
		if roll < 0.25 * aggression:
			_set_state(AIState.APPROACH, _randi_range(10, 20))
		elif roll < 0.25 * aggression + 0.35:
			_set_state(AIState.ATTACK, 1)
		elif roll < 0.25 * aggression + 0.35 + 0.20:
			_set_state(AIState.BLOCK, _randi_range(10, 24))
		elif roll < 0.25 * aggression + 0.35 + 0.20 + 0.10:
			_set_state(AIState.RETREAT, _randi_range(10, 20))
		else:
			_set_state(AIState.IDLE, _randi_range(6, 12))
	else:
		# Close range: attack, throw, block, or retreat.
		var roll := randf()
		if roll < 0.40 * aggression:
			_set_state(AIState.ATTACK, 1)
		elif roll < 0.40 * aggression + 0.15:
			_attempt_throw()
			_set_state(AIState.IDLE, 12)
		elif roll < 0.40 * aggression + 0.15 + 0.25:
			_set_state(AIState.BLOCK, _randi_range(10, 20))
		elif roll < 0.40 * aggression + 0.15 + 0.25 + 0.12:
			_set_state(AIState.RETREAT, _randi_range(14, 28))
		else:
			_set_state(AIState.IDLE, _randi_range(6, 12))

# ------------------------------------------------------------------
# State execution (runs every physics frame while action_frames > 0)
# ------------------------------------------------------------------

func _execute_state() -> void:
	match ai_state:
		AIState.IDLE:
			pass  # No inputs — let the fighter idle naturally.
		AIState.APPROACH:
			_inject_toward_opponent()
		AIState.ATTACK:
			_pick_and_inject_attack()
			ai_state = AIState.IDLE
		AIState.BLOCK:
			_inject_hold_back()
		AIState.RETREAT:
			_inject_hold_back()

# ------------------------------------------------------------------
# Input injection helpers
# ------------------------------------------------------------------

func _inject_toward_opponent() -> void:
	if not fighter or not opponent:
		return
	var dir := sign(opponent.global_position.x - fighter.global_position.x)
	var direction: String = "right" if dir > 0 else "left"
	fighter.input_buffer.inject_direction(direction)

func _inject_hold_back() -> void:
	if not fighter:
		return
	var back_dir: String = "left" if fighter.facing_right else "right"
	fighter.input_buffer.inject_direction(back_dir)

func _pick_and_inject_attack() -> void:
	var dist := _distance_to_opponent()

	# At close range, occasionally do LP → MP → HP target combo.
	if dist < CLOSE_RANGE and _roll(0.25 * aggression):
		_start_combo(["lp", "hp", "lk"])
		return

	# Weighted random single attack.
	var chosen := _weighted_pick(attack_weights)
	_inject_button(chosen)

func _attempt_throw() -> void:
	# Throw = LP + LK simultaneously.
	_inject_button("lp")
	_inject_button("lk")

func _inject_button(button: String) -> void:
	if fighter and fighter.input_buffer:
		fighter.input_buffer.inject_button(button)

# ------------------------------------------------------------------
# Combo queue
# ------------------------------------------------------------------

func _start_combo(buttons: Array[String]) -> void:
	_combo_queue = buttons.duplicate()
	_combo_timer = 0

func _tick_combo() -> bool:
	if _combo_queue.is_empty():
		return false
	_combo_timer -= 1
	if _combo_timer <= 0:
		var btn: String = _combo_queue.pop_front()
		_inject_button(btn)
		_combo_timer = 10  # ~10 frames between combo hits (within 12-frame chain window)
	return true

# ------------------------------------------------------------------
# Reaction queue (simulates human reaction delay)
# ------------------------------------------------------------------

func _queue_reaction(target_state: AIState, hold_frames: int) -> void:
	var delay := _randi_range(reaction_delay_min, reaction_delay_max)
	_reaction_queue.append({
		"frames_left": delay,
		"state": target_state,
		"hold": hold_frames,
	})

func _tick_reactions() -> void:
	var i := 0
	while i < _reaction_queue.size():
		_reaction_queue[i]["frames_left"] -= 1
		if _reaction_queue[i]["frames_left"] <= 0:
			var r: Dictionary = _reaction_queue[i]
			_set_state(r["state"] as AIState, r["hold"] as int)
			_reaction_queue.remove_at(i)
			return  # Process one reaction per frame at most.
		i += 1

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------

func _set_state(new_state: AIState, hold: int) -> void:
	ai_state = new_state
	action_frames = hold

func _has_valid_refs() -> bool:
	if not fighter:
		return false
	if not opponent:
		# Try to find opponent from fighter reference.
		if fighter.has_method("get") and fighter.get("opponent"):
			opponent = fighter.get("opponent")
		return opponent != null
	return true

func _in_protected_state() -> bool:
	if not fighter or not fighter.get("state_machine"):
		return false
	var sm: StateMachine = fighter.get("state_machine") as StateMachine
	if not sm or not sm.current_state:
		return false
	return sm.current_state.name.to_lower() in PROTECTED_STATES

func _distance_to_opponent() -> float:
	if not fighter or not opponent:
		return 9999.0
	return absf(fighter.global_position.x - opponent.global_position.x)

func _opponent_state_name() -> String:
	if not opponent or not opponent.get("state_machine"):
		return ""
	var sm: StateMachine = opponent.get("state_machine") as StateMachine
	if not sm or not sm.current_state:
		return ""
	return sm.current_state.name.to_lower()

func _roll(chance: float) -> bool:
	return randf() < chance

func _randi_range(low: int, high: int) -> int:
	return randi() % (high - low + 1) + low

func _weighted_pick(weights: Dictionary) -> String:
	var total: int = 0
	for w: int in weights.values():
		total += w
	var roll: int = randi() % total
	var cumulative: int = 0
	for key: String in weights:
		cumulative += weights[key]
		if roll < cumulative:
			return key
	return weights.keys()[0]
