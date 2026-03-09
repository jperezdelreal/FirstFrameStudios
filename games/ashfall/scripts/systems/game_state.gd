## Autoload singleton holding global game state.
## Readable by any system; mutations go through methods
## so listeners can react via EventBus.
extends Node

enum GamePhase { TITLE, CHARACTER_SELECT, FIGHTING, ROUND_END, MATCH_END, TRAINING }

var current_phase: GamePhase = GamePhase.TITLE
var current_round: int = 1
var scores: Array[int] = [0, 0]
var ember: Array[int] = [0, 0]

const MAX_EMBER: int = 100
const ROUNDS_TO_WIN: int = 2

func reset_match() -> void:
	current_round = 1
	scores = [0, 0]
	ember = [0, 0]
	current_phase = GamePhase.FIGHTING

func advance_round(winner_index: int) -> void:
	scores[winner_index] += 1
	current_round += 1
	ember = [0, 0]

func add_ember(player_id: int, amount: int) -> void:
	var idx := player_id - 1
	ember[idx] = mini(ember[idx] + amount, MAX_EMBER)
	EventBus.ember_changed.emit(player_id, ember[idx])

func spend_ember(player_id: int, cost: int, action: String) -> bool:
	var idx := player_id - 1
	if ember[idx] < cost:
		return false
	ember[idx] -= cost
	EventBus.ember_spent.emit(player_id, cost, action)
	EventBus.ember_changed.emit(player_id, ember[idx])
	return true

func get_ember(player_id: int) -> int:
	return ember[player_id - 1]


func activate_ignition(player_id: int) -> bool:
	if not spend_ember(player_id, MAX_EMBER, "ignition"):
		return false
	EventBus.ignition_activated.emit(player_id)
	return true

func is_match_over() -> bool:
	return scores[0] >= ROUNDS_TO_WIN or scores[1] >= ROUNDS_TO_WIN

func get_match_winner_index() -> int:
	if scores[0] >= ROUNDS_TO_WIN:
		return 0
	if scores[1] >= ROUNDS_TO_WIN:
		return 1
	return -1
