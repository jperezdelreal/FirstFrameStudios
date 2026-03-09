## Default resting state. Fighter stands still and accepts all input.
## Exit paths: Walk, Crouch, Jump, Attack, Block, Hit, KO.
class_name IdleState
extends FighterState


func enter(args: Dictionary) -> void:
	super.enter(args)
	if fighter:
		fighter.velocity.x = 0


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Apply gravity when airborne (e.g. landing frames)
	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0

	fighter.move_and_slide()

	# --- Transition checks (priority order) ---

	# Jump
	if fighter.is_input_just_pressed("up"):
		state_machine.transition_to("jump", {})
		return

	# Attack
	if _any_attack_pressed():
		state_machine.transition_to("attack", {})
		return

	# Block (holding back)
	if fighter.is_holding_back() and fighter.is_input_pressed("block"):
		state_machine.transition_to("block", {})
		return

	# Crouch
	if fighter.is_input_pressed("down"):
		state_machine.transition_to("crouch", {})
		return

	# Walk
	if fighter.is_input_pressed("left") or fighter.is_input_pressed("right"):
		state_machine.transition_to("walk", {})
		return


func _any_attack_pressed() -> bool:
	return (fighter.is_input_just_pressed("light_punch")
		or fighter.is_input_just_pressed("medium_punch")
		or fighter.is_input_just_pressed("heavy_punch")
		or fighter.is_input_just_pressed("light_kick")
		or fighter.is_input_just_pressed("medium_kick")
		or fighter.is_input_just_pressed("heavy_kick"))
