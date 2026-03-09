## Connects the procedural CharacterSprite to the fighter's state machine,
## updating the sprite pose whenever the fighter changes state.
## Attach as a child of the CharacterSprite node.
class_name SpriteStateBridge
extends Node

## The fighter this sprite belongs to
var fighter: Fighter
## Resolved at runtime from parent
var character_sprite: CharacterSprite


func _ready() -> void:
	# Parent should be the CharacterSprite node
	if get_parent() is CharacterSprite:
		character_sprite = get_parent() as CharacterSprite

	# Walk up the tree to find our fighter (CharacterBody2D ancestor)
	var node := get_parent()
	while node:
		if node is Fighter:
			fighter = node
			break
		node = node.get_parent()

	if not fighter:
		push_warning("SpriteStateBridge: No Fighter ancestor found")
		return

	if not character_sprite:
		push_warning("SpriteStateBridge: Parent is not a CharacterSprite")
		return

	# Sync facing on startup
	character_sprite.flip_h = fighter.facing_direction < 0


func _physics_process(_delta: float) -> void:
	if not fighter or not character_sprite:
		return
	character_sprite.flip_h = fighter.facing_direction < 0
	_sync_pose_from_state()


func _sync_pose_from_state() -> void:
	if not fighter.state_machine.current_state:
		return
	var state_name := fighter.state_machine.current_state.name.to_lower()
	var new_pose := _state_to_pose(state_name)
	if character_sprite.pose != new_pose:
		character_sprite.pose = new_pose


## Map fighter state names to sprite pose names
func _state_to_pose(state_name: String) -> String:
	match state_name:
		"idle":   return "idle"
		"walk":   return "walk"
		"crouch": return "crouch"
		"jump":   return _get_jump_pose()
		"attack": return _get_attack_pose()
		"block":  return _get_block_pose()
		"hit":    return "hit"
		"ko":     return "ko"
		"throw":  return "throw_execute"
		"launch": return "jump_up"
		"wakeup": return "wakeup"
		_:        return "idle"


func _get_jump_pose() -> String:
	if not fighter:
		return "jump_peak"
	var vel_y := fighter.velocity.y
	if vel_y < -20.0:
		return "jump_up"
	elif vel_y > 20.0:
		return "jump_fall"
	else:
		return "jump_peak"


func _get_block_pose() -> String:
	if not fighter:
		return "block_standing"
	if fighter.is_on_floor() and _is_crouching():
		return "block_crouching"
	return "block_standing"


func _is_crouching() -> bool:
	if fighter.state_machine.current_state and fighter.state_machine.current_state.has_method("is_crouching"):
		return fighter.state_machine.current_state.is_crouching()
	return false


func _get_attack_pose() -> String:
	var attack_state = fighter.state_machine.current_state
	if not attack_state or not attack_state.has_method("get_current_move_name"):
		return "attack_mp"
	var move_name: String = attack_state.get_current_move_name()

	# Special / super moves
	if "ignition" in move_name or "super" in move_name:
		return "ignition"
	if "special_4" in move_name:
		return "special_4"
	if "special_3" in move_name:
		return "special_3"
	if "special_2" in move_name:
		return "special_2"
	if "special_1" in move_name or "special" in move_name:
		return "special_1"

	# Determine context: airborne vs crouching vs standing
	var is_air := not fighter.is_on_floor()
	var is_crouch := _is_crouching()

	# Determine strength + type from move name
	if "hk" in move_name or "heavy_kick" in move_name:
		if is_air: return "jump_hk"
		if is_crouch: return "crouch_hk"
		return "attack_hk"
	elif "mk" in move_name or "medium_kick" in move_name:
		if is_air: return "jump_mk"
		if is_crouch: return "crouch_mk"
		return "attack_mk"
	elif "lk" in move_name or "light_kick" in move_name or "kick" in move_name:
		if is_air: return "jump_lk"
		if is_crouch: return "crouch_lk"
		return "attack_lk"
	elif "hp" in move_name or "heavy" in move_name:
		if is_air: return "jump_hp"
		if is_crouch: return "crouch_hp"
		return "attack_hp"
	elif "mp" in move_name or "medium" in move_name:
		if is_air: return "jump_mp"
		if is_crouch: return "crouch_mp"
		return "attack_mp"
	elif "lp" in move_name or "light" in move_name:
		if is_air: return "jump_lp"
		if is_crouch: return "crouch_lp"
		return "attack_lp"
	return "attack_mp"
