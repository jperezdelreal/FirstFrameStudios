## Throw state. Grab → execute or whiff. Opponent can tech during startup.
##
## Phase flow:
##   STARTUP (5f) → ACTIVE grab check (2f) → EXECUTE throw (20f) → Idle
##                                         → WHIFF recovery (15f) → Idle
##
## Tech/break: If opponent inputs LP+LK during STARTUP or first ACTIVE
## frame, the throw is broken and both fighters return to idle.
##
## Exit paths: Idle (whiff recovery, execute done, tech'd), Hit (interrupted).
class_name ThrowState
extends FighterState

enum Phase { STARTUP, ACTIVE, EXECUTE, WHIFF, TECH }

const THROW_RANGE: float = 70.0       # px — must be close to grab
const STARTUP_FRAMES: int = 5
const ACTIVE_FRAMES: int = 2
const EXECUTE_FRAMES: int = 20        # throw animation length
const WHIFF_RECOVERY: int = 15        # punishable on whiff
const TECH_RECOVERY: int = 12         # both fighters recover after tech

const THROW_DAMAGE: int = 120
const THROW_KNOCKBACK: Vector2 = Vector2(280, -120)
const THROW_HITSTUN: int = 20

var _phase: int = Phase.STARTUP
var _phase_frames: int = 0
var _grabbed_opponent: CharacterBody2D = null


func enter(args: Dictionary) -> void:
	super.enter(args)
	_phase = Phase.STARTUP
	_phase_frames = 0
	_grabbed_opponent = null
	if fighter:
		fighter.velocity.x = 0


func exit() -> void:
	super.exit()
	_grabbed_opponent = null


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Gravity still applies
	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0
	fighter.move_and_slide()

	_phase_frames += 1

	match _phase:
		Phase.STARTUP:
			_process_startup()
		Phase.ACTIVE:
			_process_active()
		Phase.EXECUTE:
			_process_execute()
		Phase.WHIFF:
			_process_whiff()
		Phase.TECH:
			_process_tech()

	# Safety timeout: 2 seconds max
	if frames_in_state > 120:
		state_machine.transition_to("idle", {})


func _process_startup() -> void:
	# Opponent can tech during startup
	if _opponent_is_teching():
		_begin_tech()
		return
	if _phase_frames >= STARTUP_FRAMES:
		_phase = Phase.ACTIVE
		_phase_frames = 0


func _process_active() -> void:
	# First active frame still allows tech
	if _phase_frames <= 1 and _opponent_is_teching():
		_begin_tech()
		return

	if not _grabbed_opponent:
		var opp := _get_opponent()
		if opp and _in_throw_range(opp) and _opponent_throwable(opp):
			_grabbed_opponent = opp
			_phase = Phase.EXECUTE
			_phase_frames = 0
			# Freeze opponent in place during throw
			_grabbed_opponent.velocity = Vector2.ZERO
			return

	if _phase_frames >= ACTIVE_FRAMES:
		# Whiffed — no opponent in range
		_phase = Phase.WHIFF
		_phase_frames = 0


func _process_execute() -> void:
	# Hold opponent next to thrower during animation
	if _grabbed_opponent:
		var grab_offset: float = 40.0 * fighter.facing_direction
		_grabbed_opponent.global_position.x = fighter.global_position.x + grab_offset
		_grabbed_opponent.velocity = Vector2.ZERO

	if _phase_frames >= EXECUTE_FRAMES:
		_apply_throw_damage()
		state_machine.transition_to("idle", {})


func _process_whiff() -> void:
	if _phase_frames >= WHIFF_RECOVERY:
		state_machine.transition_to("idle", {})


func _process_tech() -> void:
	if _phase_frames >= TECH_RECOVERY:
		state_machine.transition_to("idle", {})


## Apply throw damage and knockback to the grabbed opponent.
func _apply_throw_damage() -> void:
	if not _grabbed_opponent or not _grabbed_opponent.has_method("take_damage"):
		return
	var kb := THROW_KNOCKBACK
	kb.x *= fighter.facing_direction
	_grabbed_opponent.take_damage(THROW_DAMAGE, kb, THROW_HITSTUN)
	_grabbed_opponent = null


## Check if the opponent is inputting throw (LP+LK) to tech.
func _opponent_is_teching() -> bool:
	var opp := _get_opponent()
	if not opp or not _in_throw_range(opp):
		return false
	if opp.has_node("InputBuffer"):
		var opp_buffer: InputBuffer = opp.get_node("InputBuffer")
		return opp_buffer.check_simultaneous(["lp", "lk"])
	return false


## Begin tech sequence — both fighters push apart and recover.
func _begin_tech() -> void:
	_phase = Phase.TECH
	_phase_frames = 0
	_grabbed_opponent = null
	# Push thrower backward
	fighter.velocity.x = -100.0 * fighter.facing_direction
	# Push opponent backward
	var opp := _get_opponent()
	if opp:
		opp.velocity.x = 100.0 * fighter.facing_direction
		if opp.has_node("StateMachine"):
			opp.state_machine.transition_to("idle", {})


func _get_opponent() -> CharacterBody2D:
	if fighter and fighter.opponent:
		return fighter.opponent
	return null


func _in_throw_range(opp: CharacterBody2D) -> bool:
	var dist: float = absf(fighter.global_position.x - opp.global_position.x)
	return dist <= THROW_RANGE


## Opponent can be thrown if they're in a vulnerable ground state.
func _opponent_throwable(opp: CharacterBody2D) -> bool:
	if not opp.has_node("StateMachine"):
		return true
	var opp_state: String = opp.state_machine.current_state.name.to_lower()
	# Can't throw someone who is already thrown, in hitstun, KO'd, or airborne
	if opp_state in ["throw", "hit", "ko", "jump", "launch"]:
		return false
	if not opp.is_grounded:
		return false
	return true
