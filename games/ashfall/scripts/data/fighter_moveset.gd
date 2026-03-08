## Resource containing a character's full move list.
## Organizes moves into normals and specials for priority lookup.
class_name FighterMoveset
extends Resource

@export var character_name: String = ""
@export var normals: Array[MoveData] = []
@export var specials: Array[MoveData] = []

## Find a normal move by button and stance.
func get_normal(button: String, crouching: bool) -> MoveData:
	for move in normals:
		if move.input_button == button and move.requires_crouch == crouching:
			return move
	# Fallback: if no crouching version exists, use standing
	if crouching:
		for move in normals:
			if move.input_button == button and not move.requires_crouch:
				return move
	return null

## Find a special move by motion and button.
func get_special(motion: String, button: String) -> MoveData:
	for move in specials:
		if move.input_motion == motion and move.input_button == button:
			return move
	# Check for "any punch" or "any kick" wildcards
	for move in specials:
		if move.input_motion == motion:
			if move.input_button == "p" and button in ["lp", "hp"]:
				return move
			if move.input_button == "k" and button in ["lk", "hk"]:
				return move
	return null

## Get all specials that use a given motion (for priority checking).
func get_specials_for_motion(motion: String) -> Array[MoveData]:
	var result: Array[MoveData] = []
	for move in specials:
		if move.input_motion == motion:
			result.append(move)
	return result
