## Area2D-based hitbox that activates during attacks.
## Detects hurtbox overlaps and emits EventBus.hit_landed once per target
## per activation window (one-hit-per-attack rule).
##
## Collision setup: Layer 2 (Hitboxes), monitors Layer 3 (Hurtboxes).
## The owning AttackState or AnimationPlayer calls activate()/deactivate().
class_name Hitbox
extends Area2D

enum HitType { LIGHT, MEDIUM, HEAVY }

@export var damage: int = 50
@export var knockback_force: Vector2 = Vector2(300, -50)
@export var hitstun_duration: int = 12
@export var blockstun_duration: int = 8
@export var hit_type: HitType = HitType.LIGHT

## Fighter that owns this hitbox — set by fighter_base.gd or scene wiring.
var owner_fighter: CharacterBody2D

## Targets already struck during this activation window.
var _hit_targets: Array = []


func _ready() -> void:
	# Layer 2 = Hitboxes, Mask = Layer 3 = Hurtboxes (bit 2 = value 4)
	collision_layer = 2
	collision_mask = 4
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)

	# Auto-detect owner fighter by walking up the tree
	if not owner_fighter:
		var parent := get_parent()
		while parent:
			if parent is CharacterBody2D:
				owner_fighter = parent
				break
			parent = parent.get_parent()


func activate() -> void:
	_hit_targets.clear()
	monitoring = true
	# Enable all child collision shapes
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false


func deactivate() -> void:
	set_deferred("monitoring", false)
	_hit_targets.clear()
	# Disable all child collision shapes
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)


func _on_area_entered(area: Area2D) -> void:
	var target: Node = area.get_parent()
	if not is_instance_valid(target):
		return
	if target == owner_fighter:
		return
	if target in _hit_targets:
		return
	_hit_targets.append(target)

	print("[Hitbox] HIT! %s → %s | dmg=%d" % [
		owner_fighter.name if owner_fighter else "???",
		target.name if target else "???",
		damage])

	var hit_data := {
		"damage": damage,
		"knockback_force": _get_directional_knockback(target),
		"hitstun_duration": hitstun_duration,
		"blockstun_duration": blockstun_duration,
		"hit_type": hit_type,
	}
	EventBus.hit_landed.emit(owner_fighter, target, hit_data)


func _get_directional_knockback(target: Node2D) -> Vector2:
	var direction: float = 1.0
	if owner_fighter and target:
		direction = sign(target.global_position.x - owner_fighter.global_position.x)
		if direction == 0.0:
			direction = 1.0
	return Vector2(knockback_force.x * direction, knockback_force.y)
