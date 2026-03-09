## Crouching state. Fighter ducks, reducing hurtbox height.
## Blocks low attacks automatically when holding back.
## Exit paths: Idle (down released), Attack (crouch attacks), Block, Hit.
class_name CrouchState
extends FighterState

var _original_hurtbox_scale: Vector2 = Vector2.ONE


func enter(args: Dictionary) -> void:
	super.enter(args)
	if not fighter:
		return
	fighter.velocity.x = 0
	# Shrink hurtbox to simulate ducking
	var node: Node = fighter.hurtbox.get_child(0)
	if not (node is CollisionShape2D):
		return
	var hurtbox_shape: CollisionShape2D = node as CollisionShape2D
	if hurtbox_shape:
		_original_hurtbox_scale = hurtbox_shape.scale
		hurtbox_shape.scale.y = fighter.crouch_hurtbox_scale
		hurtbox_shape.position.y += 10.0


func exit() -> void:
	super.exit()
	if not fighter:
		return
	# Restore hurtbox
	var node: Node = fighter.hurtbox.get_child(0)
	if not (node is CollisionShape2D):
		return
	var hurtbox_shape: CollisionShape2D = node as CollisionShape2D
	if hurtbox_shape:
		hurtbox_shape.scale = _original_hurtbox_scale
		hurtbox_shape.position.y -= 10.0


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	fighter.velocity.x = 0

	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0

	fighter.move_and_slide()

	# --- Transitions ---

	if not fighter.is_input_pressed("down"):
		state_machine.transition_to("idle", {})
		return

	if _any_attack_pressed():
		state_machine.transition_to("attack", {"crouching": true})
		return
	
	if fighter.is_holding_back() and fighter.is_input_pressed("block"):
		state_machine.transition_to("block", {"crouching": true})
		return


func _any_attack_pressed() -> bool:
	return (fighter.is_input_just_pressed("light_punch")
		or fighter.is_input_just_pressed("heavy_punch")
		or fighter.is_input_just_pressed("light_kick")
		or fighter.is_input_just_pressed("heavy_kick"))
