## AI opponent controller for single-player fighting.
## Drives a fighter through synthetic input injection into its InputBuffer —
## same code path as a human player, no special-case fighter logic.
## Reads opponent position and state (visual info only, never raw inputs).
##
## Sprint 2 Phase 4: Aggressive AI with 3 difficulty presets (Easy/Normal/Hard),
## spacing intelligence at 4 range bands, combo follow-ups, special-move usage,
## and anti-pattern safeguards that prevent passive play.
class_name AIController
extends Node

enum AIState { IDLE, APPROACH, DASH_IN, ATTACK, BLOCK, RETREAT }
enum Difficulty { EASY, NORMAL, HARD }

# ------------------------------------------------------------------
# Configuration (exported for tuning)
# ------------------------------------------------------------------

## The fighter this AI controls. Set via inspector or fight_scene.gd.
@export var fighter: CharacterBody2D
## Difficulty preset — auto-configures all tuning knobs on _ready().
@export var difficulty: Difficulty = Difficulty.NORMAL

@export_group("Tuning Knobs")
## How fast AI reacts to opponent changes (fewer frames = harder).
@export var reaction_time_frames: int = 12
## 0.0 = passive, 1.0 = relentless. Weights offensive vs defensive choices.
@export var aggression_factor: float = 0.6
## Chance of following up a hit with a combo string (0.0–1.0).
@export var combo_execution_rate: float = 0.3
## How often AI uses special moves when attacking (0.0–1.0).
@export var special_move_usage: float = 0.15
## Probability of blocking incoming attacks (0.0–1.0).
@export var block_chance: float = 0.5
## Probability of teching an incoming throw.
@export var throw_tech_chance: float = 0.4
## Probability of using anti-air when opponent jumps.
@export var anti_air_chance: float = 0.3

# ------------------------------------------------------------------
# Distance thresholds (pixels)
# ------------------------------------------------------------------

const CLOSE_RANGE: float = 120.0
const MID_RANGE: float = 250.0
const FAR_RANGE: float = 400.0

# ------------------------------------------------------------------
# Anti-pattern caps (frames)
# ------------------------------------------------------------------

## AI forced to act after idling this long.
const MAX_IDLE_FRAMES: int = 18
## AI stops blocking and retaliates after this long.
const MAX_BLOCK_FRAMES: int = 30
## AI reverses retreat and approaches after this long.
const MAX_RETREAT_FRAMES: int = 24
## Rolling window of recent attacks for repetition detection.
const MOVE_HISTORY_SIZE: int = 6
## Same move chosen this many times in history → force variety.
const REPEAT_THRESHOLD: int = 3

# ------------------------------------------------------------------
# Decision cadence
# ------------------------------------------------------------------

const BASE_DECISION_INTERVAL: int = 24
## Frames between combo hits (must fit within chain window).
const COMBO_LINK_FRAMES: int = 10
## Cooldown frames between dash-in attempts.
const DASH_COOLDOWN_FRAMES: int = 30

# ------------------------------------------------------------------
# Internal state
# ------------------------------------------------------------------

var ai_state: AIState = AIState.IDLE
var decision_timer: int = 0
var action_frames: int = 0
var opponent: CharacterBody2D = null
var _reaction_queue: Array[Dictionary] = []

# Combo execution state
var _combo_queue: Array[String] = []
var _combo_timer: int = 0

# Anti-pattern tracking
var _idle_frames: int = 0
var _block_frames: int = 0
var _retreat_frames: int = 0
var _move_history: Array[String] = []

# Dash cooldown
var _dash_cooldown: int = 0

# Attack weights — higher = more likely. Tunable per-character.
var attack_weights: Dictionary = {
	"lp": 35,
	"lk": 25,
	"hp": 20,
	"hk": 20,
}

# States where the AI should not inject new inputs.
# Must match the scene-tree node names lowered (e.g. "Attack" → "attack").
const PROTECTED_STATES: Array[String] = [
	"attack", "hit", "ko", "block", "throw",
]

# ------------------------------------------------------------------
# Lifecycle
# ------------------------------------------------------------------

func _ready() -> void:
	_apply_difficulty_preset()


func _apply_difficulty_preset() -> void:
	match difficulty:
		Difficulty.EASY:
			reaction_time_frames = 20
			aggression_factor = 0.3
			combo_execution_rate = 0.1
			special_move_usage = 0.05
			block_chance = 0.35
			throw_tech_chance = 0.2
			anti_air_chance = 0.15
		Difficulty.NORMAL:
			reaction_time_frames = 12
			aggression_factor = 0.6
			combo_execution_rate = 0.3
			special_move_usage = 0.15
			block_chance = 0.5
			throw_tech_chance = 0.4
			anti_air_chance = 0.3
		Difficulty.HARD:
			reaction_time_frames = 6
			aggression_factor = 0.85
			combo_execution_rate = 0.6
			special_move_usage = 0.3
			block_chance = 0.7
			throw_tech_chance = 0.6
			anti_air_chance = 0.5


## Resets all internal state for a new round or match.
func reset() -> void:
	ai_state = AIState.IDLE
	decision_timer = 0
	action_frames = 0
	_reaction_queue.clear()
	_combo_queue.clear()
	_combo_timer = 0
	_idle_frames = 0
	_block_frames = 0
	_retreat_frames = 0
	_move_history.clear()
	_dash_cooldown = 0


func _physics_process(_delta: float) -> void:
	if not _has_valid_refs():
		return

	if _in_protected_state():
		# Reset decision flow so we re-evaluate cleanly after recovery.
		decision_timer = 0
		action_frames = 0
		_combo_queue.clear()
		return

	if _dash_cooldown > 0:
		_dash_cooldown -= 1

	# 0. Track anti-pattern counters every frame.
	_tick_anti_pattern_counters()

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
	# Higher aggression = shorter decision cycles (faster re-evaluation).
	var interval: int = maxi(6, BASE_DECISION_INTERVAL - roundi(aggression_factor * 14.0))
	decision_timer = interval + _randi_range(-3, 3)

# ------------------------------------------------------------------
# Anti-pattern tracking
# ------------------------------------------------------------------

func _tick_anti_pattern_counters() -> void:
	match ai_state:
		AIState.IDLE:
			_idle_frames += 1
			_block_frames = 0
			_retreat_frames = 0
		AIState.BLOCK:
			_block_frames += 1
			_idle_frames = 0
			_retreat_frames = 0
		AIState.RETREAT:
			_retreat_frames += 1
			_idle_frames = 0
			_block_frames = 0
		_:
			_idle_frames = 0
			_block_frames = 0
			_retreat_frames = 0


func _record_attack(attack_name: String) -> void:
	_move_history.append(attack_name)
	if _move_history.size() > MOVE_HISTORY_SIZE:
		_move_history.pop_front()


func _is_repeating(attack_name: String) -> bool:
	if _move_history.size() < REPEAT_THRESHOLD:
		return false
	var count: int = 0
	for move: String in _move_history:
		if move == attack_name:
			count += 1
	return count >= REPEAT_THRESHOLD

# ------------------------------------------------------------------
# Decision-making
# ------------------------------------------------------------------

func _evaluate() -> void:
	# --- Anti-pattern overrides: force action if AI is stalling ---
	if _idle_frames >= MAX_IDLE_FRAMES:
		_set_state(AIState.APPROACH, _randi_range(10, 20))
		_idle_frames = 0
		return
	if _block_frames >= MAX_BLOCK_FRAMES:
		_set_state(AIState.ATTACK, 1)
		_block_frames = 0
		return
	if _retreat_frames >= MAX_RETREAT_FRAMES:
		_set_state(AIState.APPROACH, _randi_range(12, 24))
		_retreat_frames = 0
		return

	var dist: float = _distance_to_opponent()
	var opp_state: String = _opponent_state_name()

	# --- Reactive layer (opponent doing something threatening) ---
	if opp_state == "attackstate" or opp_state == "airattackstate":
		if _roll(block_chance):
			_queue_reaction(AIState.BLOCK, _randi_range(6, 14))
			return

	if opp_state == "jumpstate":
		if _roll(anti_air_chance):
			_queue_reaction(AIState.ATTACK, 1)
			return

	# --- Spacing intelligence: 4 range bands ---
	if dist > FAR_RANGE:
		_evaluate_far_range()
	elif dist > MID_RANGE:
		_evaluate_mid_range()
	elif dist > CLOSE_RANGE:
		_evaluate_poke_range()
	else:
		_evaluate_close_range()


func _evaluate_far_range() -> void:
	# Far range: aggressively close distance. Mostly approach, occasional dash.
	var roll: float = randf()
	var dash_w: float = 0.3 * aggression_factor
	if roll < dash_w and _dash_cooldown <= 0:
		_set_state(AIState.DASH_IN, _randi_range(8, 14))
		_dash_cooldown = DASH_COOLDOWN_FRAMES
	else:
		_set_state(AIState.APPROACH, _randi_range(20, 40))


func _evaluate_mid_range() -> void:
	# Mid range: mix approach with poke attacks. Weighted by aggression.
	var roll: float = randf()
	var approach_w: float = 0.35 * aggression_factor
	var attack_w: float = 0.30 * aggression_factor
	var dash_w: float = 0.15 * aggression_factor
	if roll < approach_w:
		_set_state(AIState.APPROACH, _randi_range(10, 24))
	elif roll < approach_w + attack_w:
		_set_state(AIState.ATTACK, 1)
	elif roll < approach_w + attack_w + dash_w and _dash_cooldown <= 0:
		_set_state(AIState.DASH_IN, _randi_range(6, 12))
		_dash_cooldown = DASH_COOLDOWN_FRAMES
	elif roll < approach_w + attack_w + dash_w + 0.10:
		_set_state(AIState.BLOCK, _randi_range(6, 14))
	else:
		_set_state(AIState.IDLE, _randi_range(4, 8))


func _evaluate_poke_range() -> void:
	# Poke range (between close and mid): optimal attack distance. Heavily offensive.
	var roll: float = randf()
	var attack_w: float = 0.50 * aggression_factor
	var approach_w: float = 0.20
	if roll < attack_w:
		_set_state(AIState.ATTACK, 1)
	elif roll < attack_w + approach_w:
		_set_state(AIState.APPROACH, _randi_range(6, 12))
	elif roll < attack_w + approach_w + 0.12:
		_set_state(AIState.BLOCK, _randi_range(6, 12))
	else:
		_set_state(AIState.IDLE, _randi_range(3, 6))


func _evaluate_close_range() -> void:
	# In the opponent's face: attack, combo, throw. Minimal defense.
	var roll: float = randf()
	var attack_w: float = 0.55 * aggression_factor
	var throw_w: float = 0.15 * aggression_factor
	if roll < attack_w:
		_set_state(AIState.ATTACK, 1)
	elif roll < attack_w + throw_w:
		_attempt_throw()
		_set_state(AIState.IDLE, 8)
	elif roll < attack_w + throw_w + 0.10:
		_set_state(AIState.BLOCK, _randi_range(4, 10))
	elif roll < attack_w + throw_w + 0.10 + 0.06:
		_set_state(AIState.RETREAT, _randi_range(8, 16))
	else:
		_set_state(AIState.IDLE, _randi_range(3, 6))

# ------------------------------------------------------------------
# State execution (runs every physics frame while action_frames > 0)
# ------------------------------------------------------------------

func _execute_state() -> void:
	match ai_state:
		AIState.IDLE:
			pass  # No inputs — let the fighter idle naturally.
		AIState.APPROACH:
			_inject_toward_opponent()
		AIState.DASH_IN:
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
	var dir: float = sign(opponent.global_position.x - fighter.global_position.x)
	var direction: String = "right" if dir > 0.0 else "left"
	fighter.input_buffer.inject_direction(direction)


func _inject_hold_back() -> void:
	if not fighter:
		return
	var back_dir: String = "left" if fighter.facing_right else "right"
	fighter.input_buffer.inject_direction(back_dir)


func _pick_and_inject_attack() -> void:
	var dist: float = _distance_to_opponent()

	# Special move check (QCF + HP)
	if _roll(special_move_usage):
		_inject_special_move()
		_record_attack("special_qcf")
		return

	# Close range: try combo based on combo_execution_rate
	if dist < CLOSE_RANGE and _roll(combo_execution_rate):
		_start_combo(["lp", "hp", "lk"])
		_record_attack("combo_lp_hp_lk")
		return

	# Poke range: try a 2-hit string at reduced rate
	if dist < MID_RANGE and _roll(combo_execution_rate * 0.5):
		_start_combo(["lp", "hp"])
		_record_attack("combo_lp_hp")
		return

	# Weighted random single attack with anti-repeat
	var chosen: String = _pick_non_repeating_attack()
	_inject_button(chosen)
	_record_attack(chosen)


func _pick_non_repeating_attack() -> String:
	var chosen: String = _weighted_pick(attack_weights)
	if _is_repeating(chosen):
		var alternatives: Array[String] = []
		for key: String in attack_weights:
			if key != chosen:
				alternatives.append(key)
		if not alternatives.is_empty():
			chosen = alternatives[randi() % alternatives.size()]
	return chosen


func _inject_special_move() -> void:
	# QCF + HP motion: ↓ → ↘ → → + HP (injected across combo queue frames)
	if not fighter or not fighter.input_buffer:
		return
	var fwd: String = "right" if fighter.facing_right else "left"
	fighter.input_buffer.inject_direction("down")
	_start_combo_raw([
		{"dir": "down", "btn": ""},
		{"dir": fwd, "btn": ""},
		{"dir": fwd, "btn": "hp"},
	])


func _start_combo_raw(steps: Array[Dictionary]) -> void:
	# Queues raw direction+button pairs for multi-frame input sequences.
	_combo_queue.clear()
	_combo_timer = 0
	for step: Dictionary in steps:
		var dir_str: String = step.get("dir", "") as String
		var btn_str: String = step.get("btn", "") as String
		# Encode as "dir|btn" for _tick_combo_raw to parse.
		_combo_queue.append(dir_str + "|" + btn_str)


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
	_combo_queue.clear()
	for btn: String in buttons:
		# Encode button-only entries as "|btn" (no direction component).
		_combo_queue.append("|" + btn)
	_combo_timer = 0


func _tick_combo() -> bool:
	if _combo_queue.is_empty():
		return false
	_combo_timer -= 1
	if _combo_timer <= 0:
		var entry: String = _combo_queue.pop_front()
		var parts: PackedStringArray = entry.split("|")
		var dir_part: String = parts[0] if parts.size() > 0 else ""
		var btn_part: String = parts[1] if parts.size() > 1 else ""
		if dir_part != "":
			fighter.input_buffer.inject_direction(dir_part)
		if btn_part != "":
			_inject_button(btn_part)
		_combo_timer = COMBO_LINK_FRAMES
	return true

# ------------------------------------------------------------------
# Reaction queue (simulates human reaction delay)
# ------------------------------------------------------------------

func _queue_reaction(target_state: AIState, hold_frames: int) -> void:
	var delay: int = _reaction_delay()
	_reaction_queue.append({
		"frames_left": delay,
		"state": target_state,
		"hold": hold_frames,
	})


func _reaction_delay() -> int:
	return maxi(1, reaction_time_frames + _randi_range(-3, 3))


func _tick_reactions() -> void:
	var i: int = 0
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
