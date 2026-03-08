## Airborne state. Applies jump impulse on enter, gravity each tick.
## Transitions back to idle on landing. Air control is intentionally
## limited — commitment to jump is a core fighting game principle.
## Exit paths: Idle (landed), Hit (air reset).
class_name JumpState
extends FighterState

## Horizontal air drift speed (fraction of walk speed for limited control)
const AIR_CONTROL_FACTOR: float = 0.5

var _jump_direction: float = 0.0


func enter(args: Dictionary) -> void:
	super.enter(args)
	if not fighter:
		return

	# Capture horizontal intent at moment of jump
	if fighter.is_input_pressed("right"):
		_jump_direction = 1.0
	elif fighter.is_input_pressed("left"):
		_jump_direction = -1.0
	else:
		_jump_direction = 0.0

	fighter.velocity.y = -fighter.jump_force
	fighter.velocity.x = _jump_direction * fighter.walk_speed * AIR_CONTROL_FACTOR


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Gravity
	fighter.velocity.y += fighter.gravity / 60.0

	# Minimal air control
	if fighter.is_input_pressed("right"):
		fighter.velocity.x = fighter.walk_speed * AIR_CONTROL_FACTOR
	elif fighter.is_input_pressed("left"):
		fighter.velocity.x = -fighter.walk_speed * AIR_CONTROL_FACTOR
	else:
		fighter.velocity.x = _jump_direction * fighter.walk_speed * AIR_CONTROL_FACTOR

	fighter.move_and_slide()

	# Landing detection
	if fighter.is_on_floor() and frames_in_state > 2:
		state_machine.transition_to("idle", {})
		return

	# Safety net: if airborne longer than 3 seconds, force landing
	if frames_in_state > 180:
		state_machine.transition_to("idle", {})
		return
