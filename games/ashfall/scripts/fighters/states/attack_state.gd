## Attack state. Runs through startup → active → recovery frame windows.
## Hitbox activation/deactivation is driven by frame counters here as
## placeholder; AnimationPlayer tracks will replace this when frame data
## resources (MoveData) are wired by Tarkin.
## Exit paths: Idle (recovery done), Hit (interrupted by damage).
class_name AttackState
extends FighterState

## Default frame windows — overridden by MoveData when available
@export var default_startup: int = 3
@export var default_active: int = 3
@export var default_recovery: int = 8

var _startup: int = 3
var _active: int = 3
var _recovery: int = 8
var _total_frames: int = 14
var _is_crouching: bool = false
var _hitbox_spawned: bool = false


func enter(args: Dictionary) -> void:
	super.enter(args)
	_is_crouching = args.get("crouching", false)
	_startup = args.get("startup_frames", default_startup)
	_active = args.get("active_frames", default_active)
	_recovery = args.get("recovery_frames", default_recovery)
	_total_frames = _startup + _active + _recovery
	_hitbox_spawned = false

	if fighter:
		# Halt horizontal movement during attack
		fighter.velocity.x = 0


func exit() -> void:
	super.exit()
	_deactivate_hitboxes()


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Gravity still applies (especially for air attacks)
	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0

	fighter.move_and_slide()

	# Frame phase logic
	if frames_in_state <= _startup:
		# Startup — no hitbox yet
		pass
	elif frames_in_state <= _startup + _active:
		# Active — hitbox is live
		if not _hitbox_spawned:
			_activate_hitboxes()
			_hitbox_spawned = true
	elif frames_in_state <= _total_frames:
		# Recovery — hitbox off, fighter is vulnerable
		if _hitbox_spawned:
			_deactivate_hitboxes()
			_hitbox_spawned = false
	else:
		# Attack complete
		var return_state := "crouch" if _is_crouching else "idle"
		state_machine.transition_to(return_state, {})
		return

	# Safety timeout: 2 seconds max
	if frames_in_state > 120:
		_deactivate_hitboxes()
		state_machine.transition_to("idle", {})
		return


func _activate_hitboxes() -> void:
	for child in fighter.hitboxes.get_children():
		if child is Area2D:
			child.monitoring = true
			var shape := child.get_child(0) as CollisionShape2D
			if shape:
				shape.disabled = false


func _deactivate_hitboxes() -> void:
	if not fighter:
		return
	for child in fighter.hitboxes.get_children():
		if child is Area2D:
			child.monitoring = false
			var shape := child.get_child(0) as CollisionShape2D
			if shape:
				shape.disabled = true
			# Reset one-hit tracking if using Hitbox class
			if child.has_method("deactivate"):
				child.deactivate()
