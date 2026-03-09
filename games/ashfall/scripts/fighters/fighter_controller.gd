## Reads from InputBuffer each physics frame and translates attack input
## into state machine transitions with MoveData. States handle their own
## movement transitions — the controller only handles attacks.
##
## Priority system (critical for feel):
##   1. Throw (LP+LK simultaneous)
##   2. Special moves (complex motions — DP > HCF/HCB > QCF/QCB)
##   3. Heavy normals (commitment = reward)
##   4. Light normals (speed = safety)
##
## Runs BEFORE the StateMachine in the scene tree so it can consume
## buttons before states see them (prevents double transitions).
class_name FighterController
extends Node

var fighter: Fighter
var input_buffer: InputBuffer
var moveset: FighterMoveset

# Motion priority: most complex first. DP must beat QCF overlap.
const MOTION_PRIORITY: Array = ["double_qcf", "hcf", "hcb", "dp", "qcf", "qcb"]
# Button priority within normals: heavies before lights
const BUTTON_PRIORITY: Array = ["hk", "hp", "lk", "lp"]

func _physics_process(_delta: float) -> void:
	if not fighter or not input_buffer or not moveset:
		return

	var current_state: String = _get_current_state()

	# Don't process input during uninterruptible states
	if current_state in ["hit", "ko", "launch", "block", "attack", "throw"]:
		return

	# Only ground attacks for M1 (no air specials)
	if not fighter.is_grounded:
		return

	# Priority: throw > specials > normals
	if _try_throw():
		return
	if _try_special_moves():
		return
	if _try_normal_attacks():
		return

## Attempt a throw (LP+LK simultaneous press).
func _try_throw() -> bool:
	if input_buffer.check_simultaneous(["lp", "lk"]):
		input_buffer.consume_button("lp")
		input_buffer.consume_button("lk")
		fighter.state_machine.transition_to("throw", {})
		return true
	return false

## Check for special move inputs. Most complex motions checked first.
func _try_special_moves() -> bool:
	for motion in MOTION_PRIORITY:
		if input_buffer.check_motion(motion):
			for button in BUTTON_PRIORITY:
				if input_buffer.check_button(button):
					var move := moveset.get_special(motion, button)
					if move:
						_execute_attack(move)
						input_buffer.consume_button(button)
						input_buffer.consume_motion()
						return true
	return false

## Check for normal attack inputs. Heavies checked before lights.
func _try_normal_attacks() -> bool:
	var is_crouching: bool = input_buffer.is_holding_down()
	for button in BUTTON_PRIORITY:
		if input_buffer.check_button(button):
			var move := moveset.get_normal(button, is_crouching)
			if move:
				_execute_attack(move)
				input_buffer.consume_button(button)
				return true
	return false

## Transition to attack state with move data for proper frame timing.
func _execute_attack(move: MoveData) -> void:
	fighter.state_machine.transition_to("attack", {
		"move": move,
		"startup_frames": move.startup_frames,
		"active_frames": move.active_frames,
		"recovery_frames": move.recovery_frames,
		"crouching": move.requires_crouch,
	})

func _get_current_state() -> String:
	if fighter.state_machine.current_state:
		return fighter.state_machine.current_state.name.to_lower()
	return ""
