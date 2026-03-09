## Hitstun state. Fighter is stunned after taking an unblocked hit.
## Cannot act until hitstun frames expire. Knockback decelerates over time.
## Exit paths: Idle (hitstun expired), KO (HP ≤ 0).
## Safety net: 60-frame max (1 second) prevents infinite stun.
class_name HitState
extends FighterState

const DEFAULT_HITSTUN: int = 12
const MAX_HITSTUN: int = 60
## Horizontal knockback deceleration (px/sec per frame).
## Tuned so lights stop in ~5f and heavies slide ~12f for visual impact.
const KNOCKBACK_DECEL: float = 18.0

var _hitstun_remaining: int = 0


func enter(args: Dictionary) -> void:
	super.enter(args)
	_hitstun_remaining = mini(args.get("hitstun_frames", DEFAULT_HITSTUN), MAX_HITSTUN)


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Decelerate horizontal knockback
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, KNOCKBACK_DECEL)

	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		# Kill vertical velocity on landing, prevent bouncing
		if fighter.velocity.y > 0.0:
			fighter.velocity.y = 0

	fighter.move_and_slide()

	_hitstun_remaining -= 1

	if _hitstun_remaining <= 0:
		state_machine.transition_to("idle", {})
		return

	# Safety timeout
	if frames_in_state > MAX_HITSTUN:
		state_machine.transition_to("idle", {})
		return
