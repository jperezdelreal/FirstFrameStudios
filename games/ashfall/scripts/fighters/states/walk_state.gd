## Walking state. Moves fighter left/right at walk_speed.
## Uses walk_back_speed when retreating for asymmetric movement feel.
## Exit paths: Idle (no input), Jump, Attack, Block, Hit.
class_name WalkState
extends FighterState


func enter(args: Dictionary) -> void:
	super.enter(args)


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Determine direction and speed
	var move_dir: float = 0.0
	if fighter.is_input_pressed("right"):
		move_dir = 1.0
	elif fighter.is_input_pressed("left"):
		move_dir = -1.0

	# Use slower speed when walking backward
	var is_backing: bool = (move_dir != 0.0 and int(move_dir) != fighter.facing_direction)
	var speed: float = fighter.walk_back_speed if is_backing else fighter.walk_speed
	fighter.velocity.x = move_dir * speed

	# Gravity
	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0

	fighter.move_and_slide()

	# --- Transitions ---

	if fighter.is_input_just_pressed("up"):
		state_machine.transition_to("jump", {})
		return

	if _any_attack_pressed():
		state_machine.transition_to("attack", {})
		return

	if fighter.is_input_pressed("down"):
		state_machine.transition_to("crouch", {})
		return

	if move_dir == 0.0:
		state_machine.transition_to("idle", {})
		return


func _any_attack_pressed() -> bool:
	return (fighter.is_input_just_pressed("light_punch")
		or fighter.is_input_just_pressed("heavy_punch")
		or fighter.is_input_just_pressed("light_kick")
		or fighter.is_input_just_pressed("heavy_kick"))
