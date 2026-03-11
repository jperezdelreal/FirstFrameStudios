# SKILL: Godot 4 Design Patterns for Beat 'Em Ups

Practical, copy-paste-ready Godot 4 patterns for building a 2.5D beat 'em up. Every pattern here maps directly to firstPunch's GDD — hitbox/hurtbox combat, 2-attacker throttle, health-cost specials, comedy-driven feedback, and Downtown-as-a-character level flow. Built from the squad's existing skills (beat-em-up-combat, state-machine-patterns) translated into GDScript.

---
name: "godot-beat-em-up-patterns"
description: "Godot 4 implementation patterns for 2.5D beat 'em ups — combat, AI, movement, levels, UI, audio, singletons"
domain: "game-engine"
confidence: "low"
source: "authored — Yoda (Game Designer), synthesized from GDD v1.0 + beat-em-up-combat skill + state-machine-patterns skill"
---

## When to Use This Skill
- Implementing any firstPunch system in Godot 4
- Porting existing Canvas 2D logic to Godot's node system
- Setting up project structure, autoloads, and scene hierarchy
- Debugging combat feel, enemy behavior, or level flow in Godot
- Any Godot 4 beat 'em up project

## When NOT to Use This Skill
- 3D beat 'em ups (different node types, physics, camera)
- Non-combat Godot projects (puzzle, narrative, sim)
- Godot 3.x projects (syntax differences in GDScript, node renames)

---

## 1. Combat System Architecture in Godot

### 1.1 Hitbox/Hurtbox Pattern Using Area2D

The foundational combat pattern. Every damageable entity has a **Hurtbox** (where it can be hit). Every attack spawns or enables a **Hitbox** (where it deals damage). They are separate Area2D children on the same entity.

**Scene tree for a fighter:**
```
CharacterBody2D (Player or Enemy)
├── Sprite2D
├── AnimationPlayer
├── CollisionShape2D          # Physics body for movement
├── Hurtbox (Area2D)          # WHERE I CAN BE HIT
│   └── CollisionShape2D      # Covers the sprite bounds
├── Hitbox (Area2D)           # WHERE I DEAL DAMAGE
│   └── CollisionShape2D      # Covers the attack range
└── StateMachine
```

**Collision layer setup (Project → Project Settings → Layer Names → 2D Physics):**

| Layer | Name         | Purpose                        |
|-------|--------------|--------------------------------|
| 1     | Environment  | Walls, floors, obstacles       |
| 2     | Player Body  | Player's physics collider      |
| 3     | Enemy Body   | Enemy physics colliders        |
| 4     | Player Hitbox| Player attack areas            |
| 5     | Enemy Hitbox | Enemy attack areas             |
| 6     | Player Hurtbox| Player's vulnerable area      |
| 7     | Enemy Hurtbox| Enemy vulnerable areas         |
| 8     | Pickups      | Weapons, health, items         |

**Layer/Mask rules:**
- Player Hitbox → scans layer 7 (Enemy Hurtbox)
- Enemy Hitbox → scans layer 6 (Player Hurtbox)
- Player Hurtbox → sits on layer 6, mask empty (passive — it gets detected, doesn't detect)
- Enemy Hurtbox → sits on layer 7, mask empty (passive)

```gdscript
# hurtbox.gd — Attach to every Hurtbox Area2D
class_name Hurtbox
extends Area2D

# Visual debug: flash red when hit (editor only)
func _ready() -> void:
	collision_layer = 0   # Set via inspector per entity type (layer 6 or 7)
	collision_mask = 0    # Hurtboxes are passive — they get detected, not detect
```

```gdscript
# hitbox.gd — Attach to every Hitbox Area2D
class_name Hitbox
extends Area2D

@export var damage: int = 10
@export var knockback_force: float = 300.0
@export var knockback_direction: Vector2 = Vector2.RIGHT
@export var hitstun_duration: float = 0.3
@export var hitlag_frames: int = 4

# Track what we've already hit this attack to prevent multi-hit
var _hit_targets: Array[Node] = []

func _ready() -> void:
	# Disabled by default — enabled only during active attack frames
	monitoring = false
	area_entered.connect(_on_area_entered)

func activate() -> void:
	_hit_targets.clear()
	monitoring = true

func deactivate() -> void:
	monitoring = false
	_hit_targets.clear()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and area.get_parent() not in _hit_targets:
		var target = area.get_parent()
		_hit_targets.append(target)

		# Build hit data and send it to the target
		var hit_data := {
			"damage": damage,
			"knockback": knockback_direction.normalized() * knockback_force,
			"hitstun": hitstun_duration,
			"hitlag_frames": hitlag_frames,
			"attacker": get_parent(),  # who hit me
		}

		if target.has_method("take_damage"):
			target.take_damage(hit_data)
```

### 1.2 Damage Interface Pattern

Every damageable node implements `take_damage()`. No inheritance required — duck typing via `has_method()`.

```gdscript
# player.gd (excerpt)
func take_damage(hit_data: Dictionary) -> void:
	if _state == State.DODGING:
		return  # I-frames during dodge roll

	if _invincible:
		return  # Post-hit invincibility

	var actual_damage: int = hit_data["damage"]
	health -= actual_damage

	# Knockback via velocity
	velocity = hit_data["knockback"]

	# Enter hitstun state
	_hitstun_remaining = hit_data["hitstun"]
	_change_state(State.HIT)

	# Trigger hitlag
	_apply_hitlag(hit_data["hitlag_frames"])

	# Screen shake
	_camera_shake(actual_damage)

	# I-frames after hit
	_start_invincibility(0.5)

	if health <= 0:
		_change_state(State.DEAD)
```

```gdscript
# destructible_prop.gd — Even props implement take_damage()
extends StaticBody2D

@export var max_health: int = 30
var health: int

func _ready() -> void:
	health = max_health

func take_damage(hit_data: Dictionary) -> void:
	health -= hit_data["damage"]
	# Spawn hit particles
	_spawn_debris()
	if health <= 0:
		_break_apart()

func _break_apart() -> void:
	# Spawn pickup items from broken prop
	var pickup_scene = preload("res://scenes/pickups/health_pickup.tscn")
	var pickup = pickup_scene.instantiate()
	pickup.global_position = global_position
	get_parent().add_child(pickup)
	queue_free()
```

### 1.3 Knockback via CharacterBody2D.velocity

Godot's `CharacterBody2D.move_and_slide()` handles knockback naturally. Set `velocity`, let the physics do the rest.

```gdscript
# Inside player.gd or enemy.gd _physics_process
func _physics_process(delta: float) -> void:
	match _state:
		State.HIT:
			# Knockback decays via friction
			velocity = velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
			_hitstun_remaining -= delta
			if _hitstun_remaining <= 0:
				_change_state(State.IDLE)
		State.IDLE, State.WALK:
			# Normal movement
			velocity = _input_direction * MOVE_SPEED
		# ... other states

	move_and_slide()
```

**Knockback direction flipping (face the attacker):**
```gdscript
func take_damage(hit_data: Dictionary) -> void:
	var attacker: Node2D = hit_data["attacker"]
	var direction_from_attacker = (global_position - attacker.global_position).normalized()
	velocity = direction_from_attacker * hit_data["knockback"].length()
```

### 1.4 Hitlag: The Secret Sauce of Game Feel

Hitlag is the 3-6 frame freeze on impact that makes hits feel weighty. Two approaches:

**Approach A: Process mode manipulation (RECOMMENDED — per-entity, no global side effects)**
```gdscript
# hitlag_component.gd — Attach as child node to any entity
class_name HitlagComponent
extends Node

var _hitlag_timer: float = 0.0
var _parent: Node

func _ready() -> void:
	_parent = get_parent()

func apply(duration_frames: int) -> void:
	# Convert frames to seconds (assuming 60fps target)
	_hitlag_timer = duration_frames / 60.0
	# Pause the parent's processing
	_parent.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if _hitlag_timer > 0:
		_hitlag_timer -= delta
		if _hitlag_timer <= 0:
			_parent.process_mode = Node.PROCESS_MODE_INHERIT
```

**Approach B: Engine.time_scale (global, cinematic moments only)**
```gdscript
# Use ONLY for super moves, boss kills, final hits — affects EVERYTHING
func apply_global_hitlag(duration: float = 0.08) -> void:
	Engine.time_scale = 0.05
	# Use a SceneTreeTimer so it respects time_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
```

### 1.5 Screen Shake via Camera2D

```gdscript
# camera_shake.gd — Attach to Camera2D
class_name CameraShake
extends Camera2D

var _shake_intensity: float = 0.0
var _shake_decay: float = 5.0

func shake(intensity: float, decay: float = 5.0) -> void:
	_shake_intensity = intensity
	_shake_decay = decay

func _process(delta: float) -> void:
	if _shake_intensity > 0.1:
		offset = Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		_shake_intensity = lerpf(_shake_intensity, 0.0, _shake_decay * delta)
	else:
		_shake_intensity = 0.0
		offset = Vector2.ZERO

# Usage from anywhere:
# Get the camera and shake it
# var camera = get_viewport().get_camera_2d() as CameraShake
# camera.shake(8.0)  # Light hit
# camera.shake(16.0) # Heavy hit
# camera.shake(32.0) # Super move / boss death
```

**Tween-based alternative (one-shot, precise control):**
```gdscript
func shake_tween(camera: Camera2D, intensity: float, duration: float = 0.2) -> void:
	var tween = create_tween()
	var shake_count := 4
	var step_duration := duration / shake_count
	for i in shake_count:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", offset, step_duration)
		intensity *= 0.7  # Decay each shake
	tween.tween_property(camera, "offset", Vector2.ZERO, step_duration)
```

---

## 2. Enemy AI in Godot

### 2.1 State Machine Using Enums + Match

This is Godot's bread-and-butter AI pattern. Matches our state-machine-patterns skill directly.

```gdscript
# enemy.gd
extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	CIRCLE,      # Orbiting player, waiting for attack slot
	ATTACK_WINDUP,
	ATTACKING,
	HIT,
	DEAD,
}

var _state: State = State.IDLE
var _state_timer: float = 0.0
var _target: CharacterBody2D = null

const CHASE_SPEED := 120.0
const ATTACK_RANGE := 60.0
const CIRCLE_RANGE := 100.0
const ATTACK_WINDUP_TIME := 0.4
const MAX_STATE_DURATION := 5.0  # Safety net — no state lasts forever

func _physics_process(delta: float) -> void:
	_state_timer += delta

	# SAFETY NET: Force exit if stuck in any state too long
	if _state_timer > MAX_STATE_DURATION and _state != State.DEAD:
		_change_state(State.IDLE)

	match _state:
		State.IDLE:
			_do_idle(delta)
		State.CHASE:
			_do_chase(delta)
		State.CIRCLE:
			_do_circle(delta)
		State.ATTACK_WINDUP:
			_do_attack_windup(delta)
		State.ATTACKING:
			_do_attacking(delta)
		State.HIT:
			_do_hit(delta)
		State.DEAD:
			pass  # Death animation playing, then queue_free()

	move_and_slide()

func _change_state(new_state: State) -> void:
	# EXIT logic for old state
	match _state:
		State.ATTACKING:
			_release_attack_slot()
			$Hitbox.deactivate()
		State.CIRCLE:
			pass

	_state = new_state
	_state_timer = 0.0

	# ENTER logic for new state
	match new_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.ATTACK_WINDUP:
			velocity = Vector2.ZERO
			$AnimationPlayer.play("attack_windup")
		State.ATTACKING:
			$Hitbox.activate()
			$AnimationPlayer.play("attack")
		State.HIT:
			$AnimationPlayer.play("hit")
		State.DEAD:
			$AnimationPlayer.play("death")
			$CollisionShape2D.set_deferred("disabled", true)

func _do_idle(delta: float) -> void:
	_target = _find_nearest_player()
	if _target:
		_change_state(State.CHASE)

func _do_chase(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_change_state(State.IDLE)
		return

	var dist = global_position.distance_to(_target.global_position)

	if dist < ATTACK_RANGE and _can_claim_attack_slot():
		_change_state(State.ATTACK_WINDUP)
	elif dist < CIRCLE_RANGE:
		_change_state(State.CIRCLE)
	else:
		var dir = (_target.global_position - global_position).normalized()
		velocity = dir * CHASE_SPEED

func _do_hit(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	if _state_timer > 0.3:  # Hitstun duration
		_change_state(State.IDLE)
```

### 2.2 Attack Throttling — The 2-Attacker Rule

From the GDD: "Maximum 2 enemies attack simultaneously." This is a **design principle**, not a performance hack. Use groups.

```gdscript
# Put this in a shared place — e.g., an EnemyManager autoload

const MAX_SIMULTANEOUS_ATTACKERS := 2

func _can_claim_attack_slot() -> bool:
	var current_attackers = get_tree().get_nodes_in_group("active_attackers")
	return current_attackers.size() < MAX_SIMULTANEOUS_ATTACKERS

func _claim_attack_slot() -> void:
	add_to_group("active_attackers")

func _release_attack_slot() -> void:
	if is_in_group("active_attackers"):
		remove_from_group("active_attackers")
```

**In the enemy script, integrate slots with state transitions:**
```gdscript
func _do_chase(delta: float) -> void:
	var dist = global_position.distance_to(_target.global_position)
	if dist < ATTACK_RANGE:
		if _can_claim_attack_slot():
			_claim_attack_slot()
			_change_state(State.ATTACK_WINDUP)
		else:
			# Can't attack yet — circle and wait
			_change_state(State.CIRCLE)
	else:
		velocity = (_target.global_position - global_position).normalized() * CHASE_SPEED

func _do_circle(delta: float) -> void:
	# Orbit the player at mid-range, periodically re-check attack slot
	var angle = _state_timer * 1.5  # Orbit speed
	var offset = Vector2(cos(angle), sin(angle) * 0.5) * CIRCLE_RANGE
	var target_pos = _target.global_position + offset
	velocity = (target_pos - global_position).normalized() * CHASE_SPEED * 0.6

	# Re-check for attack slot every ~1 second
	if fmod(_state_timer, 1.0) < delta and _can_claim_attack_slot():
		_claim_attack_slot()
		_change_state(State.ATTACK_WINDUP)
```

### 2.3 Spawn System Using PackedScene

```gdscript
# wave_spawner.gd — Attach to a Node2D at each spawn point
class_name WaveSpawner
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 3
@export var spawn_delay: float = 0.5

signal wave_cleared

var _alive_enemies: Array[Node] = []

func spawn_wave() -> void:
	for i in spawn_count:
		await get_tree().create_timer(spawn_delay).timeout
		var enemy = enemy_scene.instantiate()
		enemy.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-15, 15))
		enemy.tree_exited.connect(_on_enemy_died.bind(enemy))
		get_parent().add_child(enemy)
		_alive_enemies.append(enemy)

func _on_enemy_died(enemy: Node) -> void:
	_alive_enemies.erase(enemy)
	if _alive_enemies.is_empty():
		wave_cleared.emit()
```

### 2.4 Finding the Nearest Player

```gdscript
func _find_nearest_player() -> CharacterBody2D:
	var players = get_tree().get_nodes_in_group("players")
	var nearest: CharacterBody2D = null
	var nearest_dist := INF
	for player in players:
		var dist = global_position.distance_to(player.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = player
	return nearest
```

---

## 3. 2.5D Movement System

### 3.1 Y-Sorting for Depth

Entities that are lower on screen (higher Y) render in front. Godot handles this natively.

**Option A: CanvasItem y_sort_enabled (RECOMMENDED)**
```
Node2D (y_sort_enabled = true)  ← The game world root
├── Player                       ← Auto-sorted by Y position
├── Enemy1
├── Enemy2
├── Prop (barrel)
└── Prop (lamppost)
```

```gdscript
# In the level root node
func _ready() -> void:
	y_sort_enabled = true  # All children auto-sort by Y
```

**Key nuance:** Set the entity's origin (position) at their FEET, not their center. This ensures a tall character standing above a short one renders behind correctly.

```gdscript
# If your sprite origin is center, offset visually:
# In the entity scene, move Sprite2D.offset.y upward by half the sprite height
# so that the CharacterBody2D.position represents the foot position.
```

**Option B: Manual z_index (for exceptions — UI elements in world space, flying enemies)**
```gdscript
# Flying enemies render above everything
func _process(delta: float) -> void:
	z_index = 100  # Always on top
```

### 3.2 Ground Plane Constraints

In 2.5D beat 'em ups, characters walk on a "ground plane" — they can move left/right freely but vertical movement (depth) is clamped.

```gdscript
# player.gd — movement with ground plane constraints
const MOVE_SPEED := 200.0
const VERTICAL_SPEED_RATIO := 0.6  # Depth movement is slower than horizontal
const GROUND_Y_MIN := 160.0        # Top of walkable area
const GROUND_Y_MAX := 280.0        # Bottom of walkable area

func _physics_process(delta: float) -> void:
	if _state in [State.IDLE, State.WALK]:
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# Vertical movement is slower to sell the depth illusion
		input_dir.y *= VERTICAL_SPEED_RATIO
		velocity = input_dir * MOVE_SPEED

	move_and_slide()

	# Clamp to ground plane AFTER move_and_slide
	position.y = clampf(position.y, GROUND_Y_MIN, GROUND_Y_MAX)
```

### 3.3 Shadow Sprites

Shadows ground characters visually, especially during jumps.

```gdscript
# shadow.gd — Attach to a Sprite2D child of each entity
extends Sprite2D

var _ground_y: float  # The Y position of the entity's feet when grounded

func _ready() -> void:
	# Shadow texture: a small dark ellipse, semi-transparent
	modulate = Color(0, 0, 0, 0.3)
	z_index = -1  # Always render below the character
	_ground_y = get_parent().position.y

func _process(_delta: float) -> void:
	# Shadow stays at foot level (ground_y), doesn't follow jumps
	global_position.x = get_parent().global_position.x
	global_position.y = _ground_y

	# Scale shadow based on jump height — higher = smaller shadow
	var height_above_ground = _ground_y - get_parent().global_position.y
	var scale_factor = clampf(1.0 - (height_above_ground / 200.0), 0.3, 1.0)
	scale = Vector2(scale_factor, scale_factor)
```

### 3.4 Jump System for 2.5D

Jumping in 2.5D is faked — the character moves UP on screen (negative Y offset) while their "ground position" stays the same for sorting.

```gdscript
# player.gd — jump system
var _jump_height: float = 0.0  # Visual offset, not actual position
var _jump_velocity: float = 0.0
const JUMP_FORCE := 350.0
const GRAVITY := 900.0
var _is_airborne := false

func _start_jump() -> void:
	_jump_velocity = -JUMP_FORCE
	_is_airborne = true
	_change_state(State.JUMPING)

func _physics_process(delta: float) -> void:
	if _is_airborne:
		_jump_velocity += GRAVITY * delta
		_jump_height += _jump_velocity * delta

		if _jump_height >= 0.0:
			_jump_height = 0.0
			_is_airborne = false
			_on_land()

		# Apply visual offset — sprite goes up, shadow stays
		$Sprite2D.position.y = _jump_height
	# ... rest of movement
```

---

## 4. Level Flow

### 4.1 Scene Transitions

```gdscript
# transition_manager.gd — Autoload singleton
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect  # Full-screen black overlay
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func change_scene(scene_path: String) -> void:
	anim_player.play("fade_out")
	await anim_player.animation_finished
	get_tree().change_scene_to_file(scene_path)
	anim_player.play("fade_in")
	await anim_player.animation_finished

func change_scene_packed(scene: PackedScene) -> void:
	anim_player.play("fade_out")
	await anim_player.animation_finished
	get_tree().change_scene_to_packed(scene)
	anim_player.play("fade_in")
	await anim_player.animation_finished
```

**AnimationPlayer setup:**
- `fade_out`: Tween `ColorRect.modulate.a` from 0 → 1 over 0.3s
- `fade_in`: Tween `ColorRect.modulate.a` from 1 → 0 over 0.3s

### 4.2 Camera Locks and Limits

Camera locks prevent the player from scrolling past a fight zone until all enemies are cleared. Classic beat 'em up pattern.

```gdscript
# camera_lock_zone.gd — Area2D trigger in the level
class_name CameraLockZone
extends Area2D

@export var left_limit: float = 0.0
@export var right_limit: float = 640.0
@export var top_limit: float = 0.0
@export var bottom_limit: float = 360.0
@export var enemy_waves: Array[PackedScene] = []

var _locked := false
var _camera: Camera2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and not _locked:
		_locked = true
		_camera = get_viewport().get_camera_2d()

		# Lock camera to this zone
		_camera.limit_left = int(left_limit)
		_camera.limit_right = int(right_limit)
		_camera.limit_top = int(top_limit)
		_camera.limit_bottom = int(bottom_limit)

		# Spawn enemies
		_start_waves()

func _start_waves() -> void:
	for wave_scene in enemy_waves:
		var spawner = wave_scene.instantiate()
		add_child(spawner)
		spawner.spawn_wave()
		await spawner.wave_cleared

	# All waves cleared — unlock camera
	_unlock_camera()

func _unlock_camera() -> void:
	_camera.limit_left = -10000000
	_camera.limit_right = 10000000
	_camera.limit_top = -10000000
	_camera.limit_bottom = 10000000
	_locked = false
```

### 4.3 Wave System

```gdscript
# level.gd — Level root script
extends Node2D

@export var waves: Array[WaveData] = []  # Custom resource

var _current_wave: int = 0

func _ready() -> void:
	_start_next_wave()

func _start_next_wave() -> void:
	if _current_wave >= waves.size():
		_level_complete()
		return

	var wave = waves[_current_wave]
	var enemies_alive := 0

	for spawn_info in wave.spawns:
		var enemy = spawn_info.scene.instantiate()
		enemy.global_position = spawn_info.position
		enemy.tree_exited.connect(func():
			enemies_alive -= 1
			if enemies_alive <= 0:
				_current_wave += 1
				# Brief pause between waves
				await get_tree().create_timer(1.5).timeout
				_start_next_wave()
		)
		add_child(enemy)
		enemies_alive += 1

func _level_complete() -> void:
	EventBus.level_completed.emit(_current_wave)
	TransitionManager.change_scene("res://scenes/levels/results_screen.tscn")
```

### 4.4 Environmental Interactions

```gdscript
# interactive_prop.gd — Donut Shop's donut, fire hydrant, etc.
extends StaticBody2D

@export var interaction_type: StringName = &"throw"
@export var damage_on_break: int = 25
@export var break_radius: float = 80.0
@export var debris_scene: PackedScene

func take_damage(hit_data: Dictionary) -> void:
	# Props can be destroyed by attacks
	_explode()

func _explode() -> void:
	# Damage all enemies in radius
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < break_radius:
			enemy.take_damage({
				"damage": damage_on_break,
				"knockback": (enemy.global_position - global_position).normalized() * 400.0,
				"hitstun": 0.5,
				"hitlag_frames": 6,
				"attacker": self,
			})

	# Spawn debris particles
	if debris_scene:
		var debris = debris_scene.instantiate()
		debris.global_position = global_position
		get_parent().add_child(debris)

	queue_free()
```

---

## 5. UI System

### 5.1 HUD with CanvasLayer

```
CanvasLayer (layer = 10)   ← Always above game world
├── HBoxContainer          ← Health bars for all players
│   ├── PlayerHealthBar
│   │   ├── TextureRect (portrait)
│   │   ├── ProgressBar (health)
│   │   └── Label (name)
│   └── PlayerHealthBar2   ← For co-op
├── Label (score)
├── Label (combo_counter)
└── Control (boss_health)  ← Hidden until boss fight
```

```gdscript
# hud.gd
extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var score_label: Label = %ScoreLabel
@onready var combo_label: Label = %ComboLabel

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.combo_changed.connect(_on_combo_changed)

func _on_health_changed(current: int, max_hp: int) -> void:
	# Smooth drain animation
	var tween = create_tween()
	tween.tween_property(health_bar, "value", float(current) / max_hp * 100.0, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)
	# Score pop animation
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_ease(Tween.EASE_OUT)

func _on_combo_changed(count: int, rating: String) -> void:
	if count < 2:
		combo_label.visible = false
		return

	combo_label.visible = true
	combo_label.text = "%d HIT! %s" % [count, rating]

	# Combo text punch-in effect
	combo_label.scale = Vector2(2.0, 2.0)
	var tween = create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
```

### 5.2 Combo Rating from GDD

```gdscript
# Returns game-flavored combo text
func _get_combo_rating(count: int) -> String:
	if count >= 20:
		return '"Best. Combo. Ever."'
	elif count >= 15:
		return '"Radical!"'
	elif count >= 10:
		return '"Excellent!"'  # Mayor voice
	elif count >= 5:
		return '"Woohoo!"'
	elif count >= 3:
		return '"Not bad!"'
	return ""
```

### 5.3 Theme Resources for Consistent Styling

```gdscript
# Create a Theme resource: res://themes/game_theme.tres
# In Project Settings → GUI → Theme → Custom, assign it globally.

# Or apply per-Control:
func _ready() -> void:
	var theme = preload("res://themes/game_theme.tres")
	# All child Controls inherit this theme
	set_theme(theme)
```

**Theme structure tips:**
- `ProgressBar` → custom StyleBoxFlat for health (yellow fill, blue border — game palette)
- `Label` → custom font (bold, outlined for readability against gameplay)
- Set `Label.label_settings` for per-label font size/color overrides

---

## 6. Audio Integration

### 6.1 AudioBus Layout

Set up in **Project → Audio Bus Layout** (`res://default_bus_layout.tres`):

```
Master
├── SFX        (combat hits, footsteps, props breaking)
├── Music      (level BGM, boss themes)
├── UI         (menu clicks, score pops, combo callouts)
└── Ambience   (Downtown background — traffic, birds, chatter)
```

### 6.2 Spatial SFX with AudioStreamPlayer2D

```gdscript
# hit_sfx.gd — Attach to entities
extends Node

# Preload hit sound variants for variety (CRITICAL for game feel)
var hit_sounds: Array[AudioStream] = [
	preload("res://audio/sfx/hit_01.wav"),
	preload("res://audio/sfx/hit_02.wav"),
	preload("res://audio/sfx/hit_03.wav"),
]

@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func play_hit() -> void:
	player.stream = hit_sounds.pick_random()
	player.pitch_scale = randf_range(0.9, 1.1)  # Slight pitch variation
	player.play()
```

**Attach `AudioStreamPlayer2D` to entities:**
- Set `Bus` property to "SFX"
- Set `Max Distance` for spatial falloff (useful in co-op with split areas)

### 6.3 Dynamic Music — Crossfade Between Streams

```gdscript
# music_manager.gd — Autoload singleton
extends Node

var _current_player: AudioStreamPlayer
var _next_player: AudioStreamPlayer
var _crossfade_duration := 1.5

@onready var player_a: AudioStreamPlayer = $PlayerA
@onready var player_b: AudioStreamPlayer = $PlayerB

func _ready() -> void:
	player_a.bus = &"Music"
	player_b.bus = &"Music"
	_current_player = player_a
	_next_player = player_b

func play_track(track: AudioStream, crossfade: bool = true) -> void:
	_next_player.stream = track
	_next_player.volume_db = -80.0
	_next_player.play()

	if crossfade and _current_player.playing:
		var tween = create_tween().set_parallel()
		tween.tween_property(_current_player, "volume_db", -80.0, _crossfade_duration)
		tween.tween_property(_next_player, "volume_db", 0.0, _crossfade_duration)
		await tween.finished
		_current_player.stop()
	else:
		_next_player.volume_db = 0.0

	# Swap references
	var temp = _current_player
	_current_player = _next_player
	_next_player = temp

# Usage:
# MusicManager.play_track(preload("res://audio/music/boss_theme.ogg"))
```

### 6.4 Procedural Audio Hints

Greedo's procedural audio techniques from the web audio implementation transfer to Godot via `AudioStreamGenerator`:

```gdscript
# procedural_hit.gd — Generate impact sounds procedurally
extends AudioStreamPlayer

var _playback: AudioStreamGeneratorPlayback
var _sample_rate: float
var _phase: float = 0.0

func _ready() -> void:
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.1
	stream = generator
	bus = &"SFX"

func play_impact(frequency: float = 150.0, duration: float = 0.05) -> void:
	play()
	_playback = get_stream_playback()
	_sample_rate = (stream as AudioStreamGenerator).mix_rate
	_phase = 0.0

	var samples := int(_sample_rate * duration)
	for i in samples:
		var t := float(i) / samples
		var envelope := 1.0 - t  # Linear decay
		var sample := sin(_phase * TAU) * envelope * 0.5
		# Add noise for crunch
		sample += randf_range(-0.1, 0.1) * envelope
		_playback.push_frame(Vector2(sample, sample))
		_phase += frequency / _sample_rate
		frequency *= 0.995  # Pitch drops on impact — sells weight
```

---

## 7. Project Singletons (Autoload)

Register in **Project → Project Settings → Autoload**:

| Script Path | Node Name | Purpose |
|-------------|-----------|---------|
| `res://autoloads/game_manager.gd` | GameManager | Game state, score, lives |
| `res://autoloads/event_bus.gd` | EventBus | Global signal hub |
| `res://autoloads/audio_manager.gd` | AudioManager | Centralized SFX |
| `res://autoloads/transition_manager.tscn` | TransitionManager | Scene transitions with effects |

### 7.1 GameManager

```gdscript
# game_manager.gd
extends Node

var score: int = 0
var lives: int = 3
var current_level: int = 0
var difficulty: float = 1.0
var is_paused: bool = false

func add_score(amount: int) -> void:
	score += amount
	EventBus.score_changed.emit(score)

func lose_life() -> void:
	lives -= 1
	if lives <= 0:
		EventBus.game_over.emit()
	else:
		EventBus.player_respawn.emit()

func reset() -> void:
	score = 0
	lives = 3
	current_level = 0
	difficulty = 1.0
```

### 7.2 EventBus — Global Signal Hub

```gdscript
# event_bus.gd — The nervous system of the game
extends Node

# Combat
signal player_health_changed(current: int, max_hp: int)
signal enemy_defeated(enemy_type: StringName, position: Vector2)
signal combo_changed(count: int, rating: String)
signal hit_landed(attacker: Node, target: Node, damage: int)

# Game flow
signal score_changed(new_score: int)
signal level_completed(level_index: int)
signal game_over
signal player_respawn
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

# UI
signal show_dialogue(speaker: String, text: String)
signal boss_intro(boss_name: String)
```

**Why EventBus instead of direct references?**
- Enemies don't need a reference to the HUD to update the combo counter
- The level doesn't need to know about the score label
- New systems can listen to existing signals without modifying emitters
- Perfectly matches our GDD's multi-system feedback loops (hit → score → combo → UI → audio)

### 7.3 AudioManager

```gdscript
# audio_manager.gd
extends Node

const MAX_CONCURRENT_SFX := 8

var _sfx_pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in MAX_CONCURRENT_SFX:
		var player = AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_sfx_pool.append(player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch
			player.play()
			return
	# All players busy — skip this sound (graceful degradation)
```

---

## 8. Common Godot Gotchas for Our Squad

### 8.1 _ready() Order: Children First

Children's `_ready()` fires **before** their parent's `_ready()`. This means you can safely reference child nodes in `_ready()`, but you **cannot** reference siblings or parents reliably.

```gdscript
# ✅ SAFE — children are ready when parent's _ready() fires
func _ready() -> void:
	$Sprite2D.modulate = Color.YELLOW  # Child exists
	$Hitbox.deactivate()               # Child exists

# ❌ UNSAFE — sibling or parent may not be ready
func _ready() -> void:
	get_parent().some_method()  # Parent might not be ready yet!
	# Use call_deferred or await get_tree().process_frame
```

### 8.2 Deferred Calls for Scene Tree Modification

Never add/remove nodes during physics callbacks or signal handlers that fire during the physics step. Use `call_deferred()`.

```gdscript
# ❌ CRASHES or undefined behavior
func _on_enemy_died() -> void:
	remove_child(enemy)   # Modifying tree during iteration!
	enemy.queue_free()

# ✅ SAFE — deferred to after current frame
func _on_enemy_died() -> void:
	enemy.queue_free()  # queue_free() is already deferred internally

# For adding nodes:
func _spawn_effect() -> void:
	var effect = effect_scene.instantiate()
	get_parent().call_deferred("add_child", effect)  # Safe
	# OR: get_parent().add_child.call_deferred(effect)
```

### 8.3 _process vs _physics_process

| Callback | When it runs | Use for |
|----------|-------------|---------|
| `_process(delta)` | Every render frame (variable rate) | Visuals, UI, animations, camera |
| `_physics_process(delta)` | Fixed timestep (default 60/s) | Movement, combat logic, AI, collisions |

```gdscript
# ✅ Movement in physics, visuals in process
func _physics_process(delta: float) -> void:
	velocity = _input_dir * SPEED
	move_and_slide()

func _process(delta: float) -> void:
	$Sprite2D.flip_h = velocity.x < 0  # Visual only
	_update_animation()                  # Visual only
```

**Our rule:** If it affects gameplay (position, damage, state), it goes in `_physics_process`. If it's purely visual (sprites, particles, UI tweens), it goes in `_process`.

### 8.4 Node Naming & GDScript Conventions

```gdscript
# Nodes in the scene tree: PascalCase
# Player, EnemyGrunt, HealthBar, HitboxComponent

# Variables and functions: snake_case
var move_speed: float = 200.0
func _change_state(new_state: State) -> void:

# Constants: SCREAMING_SNAKE_CASE
const MAX_HEALTH := 100
const KNOCKBACK_FRICTION := 800.0

# Signals: snake_case, past tense for events
signal health_changed(current: int, max_hp: int)
signal enemy_defeated(enemy: Node)

# Enums: PascalCase name, UPPER_CASE values
enum State { IDLE, WALK, ATTACK, HIT, DEAD }

# Private convention: prefix with underscore
var _state: State = State.IDLE
func _do_idle(delta: float) -> void:

# Type hints: ALWAYS use them
func take_damage(hit_data: Dictionary) -> void:
var enemies: Array[Node] = []
```

### 8.5 GDScript Indentation

GDScript uses **tabs** by default (Godot editor enforces this). Spaces will cause errors. Unlike Python, mixing tabs/spaces is a hard error, not a warning.

```gdscript
# ✅ Tabs (Godot default)
func _ready() -> void:
	var x = 10     # One tab
	if x > 5:
		print(x)   # Two tabs

# ❌ WILL NOT PARSE — spaces where tabs expected
func _ready() -> void:
    var x = 10     # Spaces! Error in Godot.
```

### 8.6 Signal Connection Patterns

```gdscript
# Method 1: In code (RECOMMENDED for dynamic connections)
func _ready() -> void:
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)

# Method 2: In editor (green icons in inspector)
# Fine for static connections, but harder to track in code review

# Method 3: Callable with bind (pass extra data)
enemy.tree_exited.connect(_on_enemy_died.bind(enemy))

# Disconnecting (prevent memory leaks on scene changes):
func _exit_tree() -> void:
	EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
```

### 8.7 Resource Preloading vs Loading

```gdscript
# preload() — compile-time, blocks until loaded. Use for always-needed assets.
const ENEMY_SCENE = preload("res://scenes/enemies/grunt.tscn")
const HIT_SOUND = preload("res://audio/sfx/hit_01.wav")

# load() — runtime, blocks current frame. Use for conditional assets.
var boss_scene = load("res://scenes/enemies/boss_%s.tscn" % boss_name)

# ResourceLoader (async) — background loading. Use for level transitions.
func _load_next_level(path: String) -> void:
	ResourceLoader.load_threaded_request(path)
	# Check in _process:
	# var status = ResourceLoader.load_threaded_get_status(path)
	# if status == ResourceLoader.THREAD_LOAD_LOADED:
	#     var scene = ResourceLoader.load_threaded_get(path)
```

---

## Quick Reference: Scene Tree Template

A complete beat 'em up level scene tree:

```
Level (Node2D, y_sort_enabled=true)
├── ParallaxBackground
│   ├── ParallaxLayer (sky, scroll 0.2)
│   ├── ParallaxLayer (buildings, scroll 0.5)
│   └── ParallaxLayer (ground, scroll 1.0)
├── TileMapLayer (walkable ground)
├── Entities (Node2D, y_sort_enabled=true)
│   ├── Player (CharacterBody2D)
│   │   ├── Sprite2D
│   │   ├── Shadow (Sprite2D)
│   │   ├── AnimationPlayer
│   │   ├── CollisionShape2D
│   │   ├── Hurtbox (Area2D)
│   │   ├── Hitbox (Area2D)
│   │   └── HitlagComponent
│   ├── Enemy instances (spawned at runtime)
│   └── Props (destructible)
├── CameraLockZones (Node2D)
│   ├── CameraLockZone1 (Area2D)
│   └── CameraLockZone2 (Area2D)
├── Pickups (Node2D)
├── Camera2D (CameraShake script)
├── CanvasLayer (HUD)
│   ├── HealthBar
│   ├── ScoreLabel
│   └── ComboLabel
└── AudioStreamPlayer (level BGM, bus=Music)
```

---

## Mapping to firstPunch GDD

| GDD Feature | Godot Pattern | Section |
|-------------|---------------|---------|
| PPK combo (42 dmg/1.1s) | Hitbox activate/deactivate per combo step | §1 |
| Health-cost specials (SoR2) | GameManager tracks grey health + Timer for recovery | §7.1 |
| 2-attacker throttle | Group queries: `get_nodes_in_group("active_attackers")` | §2.2 |
| Belly Bounce (Brawler special) | Wide hitbox + high knockback_force + screen shake | §1.1, §1.5 |
| Rage Mode | GameManager secondary meter + modulate tint | §7.1 |
| Ugh! Moments | AnimationPlayer death variants + EventBus signals | §7.2 |
| Dodge roll i-frames | State.DODGING check in take_damage() | §1.2 |
| Grab/throw system | State.GRABBING + thrown enemy as projectile (Area2D) | §2.1 |
| Camera locks per wave | CameraLockZone + Camera2D.limit | §4.2 |
| Combo meter ("Radical!") | EventBus.combo_changed → HUD tween animation | §5.1 |
| Downtown environments | interactive_prop.gd + take_damage() on props | §4.4 |
| SFX variation (3+ per hit) | Array[AudioStream].pick_random() + pitch jitter | §6.2 |
| Dynamic boss music | MusicManager crossfade on EventBus.boss_intro | §6.3 |
