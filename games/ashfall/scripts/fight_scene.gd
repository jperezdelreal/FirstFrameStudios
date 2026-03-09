## Fight scene controller. Sets up fighters, wires signals through
## EventBus, and manages the fight lifecycle.
extends Node2D

# Combo damage proration: multiplier per hit number (index 0 = hit 1).
# Hit 5+ uses the last value (40% floor).
const COMBO_PRORATION: Array[float] = [1.0, 0.8, 0.65, 0.5, 0.4]

@onready var fighter1: Fighter = $Fighters/Fighter1
@onready var fighter2: Fighter = $Fighters/Fighter2
@onready var camera: CameraController = $Camera2D

var combo_tracker: Node

func _ready() -> void:
	# Cross-reference opponents
	fighter1.opponent = fighter2
	fighter2.opponent = fighter1

	# Visual differentiation — Kael is warm (orange), Rhena is cool (blue)
	var visual2 := fighter2.get_node_or_null("Visual") as ColorRect
	if visual2:
		visual2.color = Color(0.2, 0.4, 0.8, 1)

	# Wire fighter signals to EventBus
	fighter1.took_damage.connect(_on_fighter_damaged)
	fighter2.took_damage.connect(_on_fighter_damaged)
	fighter1.knocked_out.connect(_on_fighter_ko)
	fighter2.knocked_out.connect(_on_fighter_ko)

	# Wire camera controller to fighters
	if camera:
		camera.fighter1 = fighter1
		camera.fighter2 = fighter2

	GameState.reset_match()

	# Wire hit_landed signal for damage application
	EventBus.hit_landed.connect(_on_hit_landed)

	# Wire match_ended for scene transition to victory screen
	EventBus.match_ended.connect(_on_match_ended)

	# Combo tracker — counts consecutive hits per fighter
	_setup_combo_tracker()

	# Start the round system
	RoundManager.start_match(fighter1, fighter2)

func _on_fighter_damaged(fighter_node, amount: int, remaining_hp: int) -> void:
	EventBus.fighter_damaged.emit(fighter_node, amount, remaining_hp)

func _on_fighter_ko(fighter_node) -> void:
	EventBus.fighter_ko.emit(fighter_node)

func _get_proration(combo_hit: int) -> float:
	var idx: int = clampi(combo_hit - 1, 0, COMBO_PRORATION.size() - 1)
	return COMBO_PRORATION[idx]

func _on_hit_landed(attacker, target, move: Dictionary) -> void:
	if not target or not is_instance_valid(target):
		return

	# Blocked hits emit hit_blocked, apply chip damage + blockstun
	if _is_blocking(target):
		EventBus.hit_blocked.emit(attacker, target, move)
		var base_damage: int = move.get("damage", 10)
		var chip: int = maxi(1, base_damage / 10)
		var blockstun: int = move.get("blockstun_duration", 8)
		var knockback: Vector2 = move.get("knockback_force", Vector2.ZERO)
		if target.has_method("take_block_damage"):
			target.take_block_damage(chip, knockback, blockstun)
		return

	var base_damage: int = move.get("damage", 10)
	var combo_hit: int = ComboTracker.get_combo_count(attacker)
	var scaled_damage: int = maxi(1, int(base_damage * _get_proration(combo_hit)))
	var knockback_force: Vector2 = move.get("knockback_force", Vector2(100, 0))
	var hitstun: int = move.get("hitstun_duration", 12)
	if target.has_method("take_damage"):
		target.take_damage(scaled_damage, knockback_force, hitstun)

func _setup_combo_tracker() -> void:
	var script := load("res://scripts/systems/combo_tracker.gd")
	combo_tracker = Node.new()
	combo_tracker.set_script(script)
	combo_tracker.name = "ComboTracker"
	add_child(combo_tracker)
	combo_tracker.register_fighter(fighter1)
	combo_tracker.register_fighter(fighter2)


func _is_blocking(target: Node) -> bool:
	if not target.has_node("StateMachine"):
		return false
	var sm := target.get_node("StateMachine")
	if sm and "current_state" in sm and sm.current_state:
		return sm.current_state.name.to_lower() == "block"
	return false


func _on_match_ended(winner: Variant, _scores: Variant) -> void:
	var winner_name := ""
	if winner and "player_id" in winner:
		winner_name = SceneManager.p1_character if winner.player_id == 1 else SceneManager.p2_character
	SceneManager.match_stats = {"winner": winner_name}
	GameState.current_phase = GameState.GamePhase.MATCH_END
	# Delay before transitioning to the victory screen
	get_tree().create_timer(2.0).timeout.connect(func():
		EventBus.scene_change_requested.emit(SceneManager.SCENE_VICTORY)
	)
