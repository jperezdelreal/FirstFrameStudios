## Blocking state. Fighter absorbs attacks with reduced/chip damage.
## Blockstun is measured in frames (deterministic). Pushback applies
## a decaying horizontal force away from the attacker.
## Block pushback: 4-12 px per GDD §2.6, proportional to attack strength.
## Exit paths: Idle (blockstun expired + not holding block), Crouch, Hit.
class_name BlockState
extends FighterState

## Minimum blockstun if no value provided
const DEFAULT_BLOCKSTUN: int = 8
## Pushback scale: knockback * scale = initial push velocity.
## Tuned so light (kb=80) → ~5px and heavy (kb=200) → ~12px per GDD §2.6.
const BLOCK_PUSHBACK_SCALE: float = 0.06
## Deceleration for block pushback (px/sec per frame)
const BLOCK_PUSHBACK_DECEL: float = 10.0

var _blockstun_remaining: int = 0
var _is_crouching: bool = false
var _pushback: Vector2 = Vector2.ZERO


func enter(args: Dictionary) -> void:
	super.enter(args)
	_blockstun_remaining = args.get("blockstun_frames", DEFAULT_BLOCKSTUN)
	_is_crouching = args.get("crouching", false)
	_pushback = args.get("knockback", Vector2.ZERO) * BLOCK_PUSHBACK_SCALE
	if fighter:
		fighter.velocity = _pushback
		# Push attacker back too — both fighters separate on block (GDD §2.6)
		if fighter.opponent and is_instance_valid(fighter.opponent):
			var push_dir: float = sign(
				fighter.opponent.global_position.x - fighter.global_position.x
			)
			if push_dir == 0.0:
				push_dir = 1.0
			var attacker_push: float = absf(_pushback.x) * 0.5
			fighter.opponent.velocity.x += attacker_push * push_dir


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Decelerate pushback
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, BLOCK_PUSHBACK_DECEL)

	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0

	fighter.move_and_slide()

	_blockstun_remaining -= 1

	if _blockstun_remaining <= 0:
		# Blockstun over — return to stance or stay blocking if held
		if fighter.is_holding_back() and fighter.is_input_pressed("block"):
			# Still holding block — stay until released
			pass
		elif fighter.is_input_pressed("down"):
			state_machine.transition_to("crouch", {})
			return
		else:
			state_machine.transition_to("idle", {})
			return

	# Safety timeout: 2 seconds max blockstun
	if frames_in_state > 120:
		state_machine.transition_to("idle", {})
		return
