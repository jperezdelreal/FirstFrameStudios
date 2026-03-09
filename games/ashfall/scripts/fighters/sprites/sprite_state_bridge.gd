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
		"crouch": return "idle"
		"jump":   return "idle"
		"attack": return _get_attack_pose()
		"block":  return "idle"
		"hit":    return "hit"
		"ko":     return "ko"
		"throw":  return "attack_hp"
		_:        return "idle"


func _get_attack_pose() -> String:
	# Try to determine which attack from the state's context
	var attack_state = fighter.state_machine.current_state
	if attack_state.has_method("get_current_move_name"):
		var move_name: String = attack_state.get_current_move_name()
		if "lp" in move_name or "light" in move_name:
			return "attack_lp"
		elif "hp" in move_name or "heavy" in move_name:
			return "attack_hp"
		else:
			return "attack_mp"
	return "attack_mp"
