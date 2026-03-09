## Attack state. Runs through startup → active → recovery frame windows.
## Hitbox activation/deactivation is driven by AnimationPlayer tracks when
## a FighterAnimationController is present; falls back to manual frame
## counters otherwise. Exit paths: Idle (recovery done), Hit (interrupted).
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

## The MoveData driving this attack — set from transition args.
var _current_move: MoveData = null
## True when AnimationPlayer is handling hitbox timing for this attack.
var _anim_drives_hitbox: bool = false


func enter(args: Dictionary) -> void:
	super.enter(args)
	_is_crouching = args.get("crouching", false)
	_current_move = args.get("move", null) as MoveData
	_startup = args.get("startup_frames", default_startup)
	_active = args.get("active_frames", default_active)
	_recovery = args.get("recovery_frames", default_recovery)
	_total_frames = _startup + _active + _recovery
	_hitbox_spawned = false

	# Check if AnimationPlayer is driving hitbox timing
	_anim_drives_hitbox = false
	if fighter:
		# Halt horizontal movement during attack
		fighter.velocity.x = 0
		var anim_ctrl := fighter.get_node_or_null("FighterAnimationController")
		if anim_ctrl and _current_move:
			anim_ctrl.play_attack_animation(_current_move)
			_anim_drives_hitbox = true


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

	# Frame phase logic — skip manual hitbox control when AnimationPlayer drives it
	if not _anim_drives_hitbox:
		if frames_in_state <= _startup:
			pass
		elif frames_in_state <= _startup + _active:
			if not _hitbox_spawned:
				_activate_hitboxes()
				_hitbox_spawned = true
		elif frames_in_state <= _total_frames:
			if _hitbox_spawned:
				_deactivate_hitboxes()
				_hitbox_spawned = false

	if frames_in_state > _total_frames:
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
			# Wire current move's frame data into the hitbox for accurate hit_data
			if _current_move and child is Hitbox:
				child.damage = _current_move.damage
				child.knockback_force = _current_move.knockback
				child.hitstun_duration = _current_move.hitstun_frames
				child.blockstun_duration = _current_move.blockstun_frames


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


## Returns the MoveData driving this attack, or null.
func get_current_move() -> MoveData:
	return _current_move


## Returns the move name string for sprite pose lookup.
func get_current_move_name() -> String:
	if _current_move:
		return _current_move.move_name
	return ""
