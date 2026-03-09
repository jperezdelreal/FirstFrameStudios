## Tracks per-fighter combo state. Increments on hit_landed, resets when
## the opponent recovers (idle/block) or a timeout expires. Emits
## combo_updated / hit_confirmed / combo_ended through EventBus.
## Frame-based timers only — deterministic at 60 FPS.
extends Node

const COMBO_TIMEOUT: int = 60  # frames without a hit before combo drops

# Per-fighter combo data keyed by fighter node instance id
var _combos: Dictionary = {}


## Combo entry for a single attacker
class ComboData:
	var count: int = 0
	var total_damage: int = 0
	var frames_since_hit: int = 0
	var active: bool = false
	var target: Node = null


# ── Public API ──────────────────────────────────────────

func register_fighter(fighter: Node) -> void:
	var id := fighter.get_instance_id()
	if not _combos.has(id):
		_combos[id] = ComboData.new()


func reset_all() -> void:
	for id in _combos:
		var data: ComboData = _combos[id]
		if data.active:
			_end_combo(_find_fighter(id), data)


# ── Lifecycle ───────────────────────────────────────────

func _ready() -> void:
	EventBus.hit_landed.connect(_on_hit_landed)
	EventBus.hit_blocked.connect(_on_hit_blocked)
	EventBus.round_started.connect(_on_round_started)


func _physics_process(_delta: float) -> void:
	for id in _combos:
		var data: ComboData = _combos[id]
		if not data.active:
			continue

		data.frames_since_hit += 1

		# Timeout — opponent recovered or hit never came
		if data.frames_since_hit > COMBO_TIMEOUT:
			_end_combo(_find_fighter(id), data)
			continue

		# Opponent returned to neutral (idle, walk, crouch, jump)
		if data.target and is_instance_valid(data.target):
			var state_name := _get_state_name(data.target)
			if state_name in ["idle", "walk", "crouch", "jump"]:
				_end_combo(_find_fighter(id), data)
				continue


# ── Signal handlers ─────────────────────────────────────

func _on_hit_landed(attacker: Variant, target: Variant, move: Variant) -> void:
	if not attacker or not is_instance_valid(attacker):
		return
	register_fighter(attacker)

	var id := attacker.get_instance_id()
	var data: ComboData = _combos[id]
	var damage: int = move.get("damage", 10) if move is Dictionary else 10

	data.count += 1
	data.total_damage += damage
	data.frames_since_hit = 0
	data.active = true
	data.target = target

	EventBus.combo_updated.emit(attacker, data.count)
	EventBus.hit_confirmed.emit(attacker, target, move, data.count)


func _on_hit_blocked(attacker: Variant, _target: Variant, _move: Variant) -> void:
	if not attacker or not is_instance_valid(attacker):
		return
	var id := attacker.get_instance_id()
	if not _combos.has(id):
		return
	var data: ComboData = _combos[id]
	if data.active:
		_end_combo(attacker, data)


func _on_round_started(_round_number: int) -> void:
	reset_all()


# ── Internals ───────────────────────────────────────────

func _end_combo(fighter: Variant, data: ComboData) -> void:
	if data.count > 1:
		EventBus.combo_ended.emit(fighter, data.count, data.total_damage)
	data.count = 0
	data.total_damage = 0
	data.frames_since_hit = 0
	data.active = false
	data.target = null
	EventBus.combo_updated.emit(fighter, 0)


func _get_state_name(fighter: Node) -> String:
	if fighter.has_node("StateMachine"):
		var sm := fighter.get_node("StateMachine")
		if sm and "current_state" in sm and sm.current_state:
			return sm.current_state.name.to_lower()
	return ""


func _find_fighter(instance_id: int) -> Variant:
	## Resolve a fighter node from its instance id (safe even if freed).
	var obj := instance_from_id(instance_id)
	if obj and is_instance_valid(obj):
		return obj
	return null
