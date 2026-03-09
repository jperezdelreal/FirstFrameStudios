## Autoload VFX manager. Spawns hit sparks, block sparks, screen shake,
## hitstun flash, KO slow-motion, and ember particle trails.
## Connects exclusively to EventBus signals — zero direct coupling.
extends Node

# ── Screen shake state ──────────────────────────────────
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_elapsed: float = 0.0
var _camera: Camera2D

# ── KO slow-motion state ───────────────────────────────
var _ko_slowmo_timer: float = 0.0
const KO_SLOWMO_SCALE: float = 0.3
const KO_SLOWMO_DURATION: float = 0.5

# ── Hitstun flash tracking ─────────────────────────────
var _flash_targets: Array[Dictionary] = []
const FLASH_FRAMES: int = 2

# ── Ember trail tracking ───────────────────────────────
var _ember_emitters: Dictionary = {}  # player_id -> GPUParticles2D


func _ready() -> void:
	assert(EventBus != null, "VFXManager requires EventBus to load first")
	assert(GameState != null, "VFXManager requires GameState to load first")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_wire_signals()


func _process(delta: float) -> void:
	_tick_shake(delta)
	_tick_slowmo(delta)
	_tick_flash()


# ── Signal wiring ───────────────────────────────────────

func _wire_signals() -> void:
	EventBus.hit_landed.connect(_on_hit_landed)
	EventBus.hit_blocked.connect(_on_hit_blocked)
	EventBus.hit_confirmed.connect(_on_hit_confirmed)
	EventBus.fighter_ko.connect(_on_fighter_ko)
	EventBus.ember_changed.connect(_on_ember_changed)
	EventBus.ember_spent.connect(_on_ember_spent)
	EventBus.round_started.connect(_on_round_started)


# ── Hit landed: sparks + shake + flash ──────────────────

func _on_hit_landed(attacker: Variant, target: Variant, move: Variant) -> void:
	if not target or not is_instance_valid(target):
		return
	var hit_pos := _get_hit_position(attacker, target)
	var hit_type := _get_hit_type(move)

	_spawn_hit_sparks(hit_pos, hit_type)
	_apply_screen_shake(hit_type)
	_apply_flash(target)


func _on_hit_confirmed(_attacker: Variant, target: Variant, _move: Variant, _combo_count: int) -> void:
	# Confirmed hits already handled via hit_landed; combo flash reinforcement
	if target and is_instance_valid(target):
		_apply_flash(target)


# ── Hit blocked: blue/white sparks + light shake ────────

func _on_hit_blocked(attacker: Variant, target: Variant, move: Variant) -> void:
	if not target or not is_instance_valid(target):
		return
	var hit_pos := _get_hit_position(attacker, target)
	_spawn_block_sparks(hit_pos)
	_apply_screen_shake("light")


# ── KO: slow-motion + big burst ────────────────────────

func _on_fighter_ko(fighter: Variant) -> void:
	if not fighter or not is_instance_valid(fighter):
		return
	_start_ko_slowmo()
	var pos: Vector2
	if fighter is Node2D:
		pos = fighter.global_position
	else:
		pos = Vector2.ZERO
	_spawn_ko_burst(pos)
	_apply_screen_shake("special")


# ── Ember changed: update ember trail particles ─────────

func _on_ember_changed(player_id: int, new_value: int) -> void:
	_update_ember_trail(player_id, new_value)


# ── Ember spent: burst flash feedback ───────────────────

func _on_ember_spent(player_id: int, _amount: int, _action: String) -> void:
	var fighter := _find_fighter(player_id)
	if fighter and fighter is Node2D:
		_spawn_hit_sparks(fighter.global_position + Vector2(0, -30), "special")
		_apply_screen_shake("light")


# ── Round started: reset VFX state ──────────────────────

func _on_round_started(_round_number: int) -> void:
	_shake_intensity = 0.0
	_shake_duration = 0.0
	_shake_elapsed = 0.0
	_ko_slowmo_timer = 0.0
	Engine.time_scale = 1.0
	_flash_targets.clear()
	# Clean up lingering ember emitters
	for pid in _ember_emitters:
		var emitter = _ember_emitters[pid]
		if is_instance_valid(emitter):
			emitter.emitting = false


# ═════════════════════════════════════════════════════════
# HIT SPARKS — white/orange burst (8-12 particles, 0.3s)
# ═════════════════════════════════════════════════════════

func _spawn_hit_sparks(pos: Vector2, hit_type: String) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.z_index = 100

	match hit_type:
		"light":
			particles.amount = 8
		"heavy":
			particles.amount = 10
		"special":
			particles.amount = 12
		_:
			particles.amount = 8

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 120.0
	mat.initial_velocity_max = 250.0
	mat.gravity = Vector3(0, 300, 0)
	mat.scale_min = 1.5
	mat.scale_max = 3.0
	mat.damping_min = 40.0
	mat.damping_max = 80.0

	# White-orange gradient for hit sparks
	var gradient := GradientTexture1D.new()
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, Color(1.0, 1.0, 1.0, 1.0))   # white
	g.set_color(1, Color(1.0, 0.6, 0.1, 0.0))     # orange → transparent
	gradient.gradient = g
	mat.color_ramp = gradient

	# Bright start color
	mat.color = Color(1.0, 0.9, 0.7, 1.0)

	particles.process_material = mat
	particles.lifetime = 0.3

	_add_to_scene(particles, pos)
	particles.emitting = true
	_auto_free(particles, 0.5)


# ═════════════════════════════════════════════════════════
# BLOCK SPARKS — blue/white burst (6-8 particles, 0.25s)
# ═════════════════════════════════════════════════════════

func _spawn_block_sparks(pos: Vector2) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 6
	particles.z_index = 100

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 80.0
	mat.initial_velocity_max = 180.0
	mat.gravity = Vector3(0, 200, 0)
	mat.scale_min = 1.0
	mat.scale_max = 2.5
	mat.damping_min = 60.0
	mat.damping_max = 100.0

	# Blue/white gradient for block sparks
	var gradient := GradientTexture1D.new()
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, Color(0.8, 0.9, 1.0, 1.0))     # white-blue
	g.set_color(1, Color(0.3, 0.5, 1.0, 0.0))       # deep blue → transparent
	gradient.gradient = g
	mat.color_ramp = gradient

	mat.color = Color(0.7, 0.85, 1.0, 1.0)

	particles.process_material = mat
	particles.lifetime = 0.25

	_add_to_scene(particles, pos)
	particles.emitting = true
	_auto_free(particles, 0.45)


# ═════════════════════════════════════════════════════════
# KO BURST — big dramatic particle explosion
# ═════════════════════════════════════════════════════════

func _spawn_ko_burst(pos: Vector2) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 24
	particles.z_index = 100

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 200.0
	mat.initial_velocity_max = 450.0
	mat.gravity = Vector3(0, 400, 0)
	mat.scale_min = 2.0
	mat.scale_max = 5.0
	mat.damping_min = 30.0
	mat.damping_max = 60.0

	var gradient := GradientTexture1D.new()
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, Color(1.0, 1.0, 0.8, 1.0))     # bright yellow-white
	g.set_color(1, Color(1.0, 0.3, 0.0, 0.0))       # red-orange → transparent
	gradient.gradient = g
	mat.color_ramp = gradient

	mat.color = Color(1.0, 0.95, 0.8, 1.0)

	particles.process_material = mat
	particles.lifetime = 0.6

	_add_to_scene(particles, pos)
	particles.emitting = true
	_auto_free(particles, 1.0)


# ═════════════════════════════════════════════════════════
# SCREEN SHAKE — camera offset with exponential decay
# ═════════════════════════════════════════════════════════

func _apply_screen_shake(hit_type: String) -> void:
	var intensity: float
	match hit_type:
		"light":
			intensity = 2.0
		"heavy":
			intensity = 5.0
		"special":
			intensity = 8.0
		_:
			intensity = 2.0

	# Only override if new shake is stronger
	if intensity > _shake_intensity:
		_shake_intensity = intensity
		_shake_duration = 0.15
		_shake_elapsed = 0.0


func _tick_shake(delta: float) -> void:
	if _shake_duration <= 0.0:
		return

	_shake_elapsed += delta
	if _shake_elapsed >= _shake_duration:
		_shake_duration = 0.0
		_shake_intensity = 0.0
		_reset_camera_offset()
		return

	# Find the active Camera2D
	if not _camera or not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_2d()
	if not _camera:
		return

	# Exponential decay
	var progress := _shake_elapsed / _shake_duration
	var amplitude := _shake_intensity * exp(-3.0 * progress)
	var offset_x := randf_range(-amplitude, amplitude)
	var offset_y := randf_range(-amplitude, amplitude)
	_camera.offset = Vector2(offset_x, offset_y)


func _reset_camera_offset() -> void:
	if _camera and is_instance_valid(_camera):
		_camera.offset = Vector2.ZERO


# ═════════════════════════════════════════════════════════
# HITSTUN FLASH — sprite turns white for 2 frames
# ═════════════════════════════════════════════════════════

func _apply_flash(target: Variant) -> void:
	if not target or not is_instance_valid(target):
		return

	# Avoid duplicate flash entries for same target
	for entry in _flash_targets:
		if entry.target == target:
			entry.frames_remaining = FLASH_FRAMES
			_set_white(target, true)
			return

	_flash_targets.append({
		"target": target,
		"frames_remaining": FLASH_FRAMES,
		"original_modulate": _get_modulate(target),
	})
	_set_white(target, true)


func _tick_flash() -> void:
	var i := _flash_targets.size() - 1
	while i >= 0:
		var entry: Dictionary = _flash_targets[i]
		entry.frames_remaining -= 1
		if entry.frames_remaining <= 0:
			_set_white(entry.target, false)
			_flash_targets.remove_at(i)
		i -= 1


func _set_white(target: Variant, white: bool) -> void:
	if not is_instance_valid(target):
		return

	# Look for the sprite node on the fighter
	var sprite: Node = null
	if target.has_node("Sprite"):
		sprite = target.get_node("Sprite")
	elif target.has_node("Visual"):
		sprite = target.get_node("Visual")

	if sprite and sprite is CanvasItem:
		if white:
			sprite.modulate = Color(5.0, 5.0, 5.0, 1.0)  # HDR white flash
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _get_modulate(target: Variant) -> Color:
	if not is_instance_valid(target):
		return Color.WHITE
	var sprite: Node = null
	if target.has_node("Sprite"):
		sprite = target.get_node("Sprite")
	elif target.has_node("Visual"):
		sprite = target.get_node("Visual")
	if sprite and sprite is CanvasItem:
		return sprite.modulate
	return Color.WHITE


# ═════════════════════════════════════════════════════════
# KO SLOW-MOTION — Engine.time_scale = 0.3 for 0.5s
# ═════════════════════════════════════════════════════════

func _start_ko_slowmo() -> void:
	Engine.time_scale = KO_SLOWMO_SCALE
	_ko_slowmo_timer = KO_SLOWMO_DURATION


func _tick_slowmo(delta: float) -> void:
	if _ko_slowmo_timer <= 0.0:
		return
	# Use unscaled delta since Engine.time_scale affects delta
	var real_delta := delta / maxf(Engine.time_scale, 0.01)
	_ko_slowmo_timer -= real_delta
	if _ko_slowmo_timer <= 0.0:
		_ko_slowmo_timer = 0.0
		Engine.time_scale = 1.0


# ═════════════════════════════════════════════════════════
# EMBER TRAILS — particle glow that intensifies with meter
# ═════════════════════════════════════════════════════════

func _update_ember_trail(player_id: int, ember_value: int) -> void:
	# Find the fighter node for this player in the scene
	var fighter := _find_fighter(player_id)
	if not fighter:
		return

	if ember_value < 25:
		# Below threshold — no trail particles
		if _ember_emitters.has(player_id):
			var emitter = _ember_emitters[player_id]
			if is_instance_valid(emitter):
				emitter.emitting = false
		return

	# Create or update emitter
	var emitter: GPUParticles2D
	if _ember_emitters.has(player_id) and is_instance_valid(_ember_emitters[player_id]):
		emitter = _ember_emitters[player_id]
	else:
		emitter = _create_ember_emitter()
		fighter.add_child(emitter)
		_ember_emitters[player_id] = emitter

	# Scale intensity with ember value (25-100 → 0.0-1.0)
	var intensity := clampf((ember_value - 25.0) / 75.0, 0.0, 1.0)
	emitter.amount = int(lerpf(3.0, 12.0, intensity))
	emitter.emitting = true

	# Color shift: low ember = dim orange, high = bright white-hot
	var mat := emitter.process_material as ParticleProcessMaterial
	if mat:
		var base_color := Color(1.0, 0.5, 0.1).lerp(Color(1.0, 0.9, 0.6), intensity)
		mat.color = base_color
		mat.scale_min = lerpf(1.0, 2.0, intensity)
		mat.scale_max = lerpf(1.5, 3.5, intensity)


func _create_ember_emitter() -> GPUParticles2D:
	var particles := GPUParticles2D.new()
	particles.one_shot = false
	particles.explosiveness = 0.0
	particles.amount = 4
	particles.z_index = 50
	particles.position = Vector2(0, -20)

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 60.0
	mat.gravity = Vector3(0, -40, 0)  # float upward
	mat.scale_min = 1.0
	mat.scale_max = 1.5
	mat.damping_min = 10.0
	mat.damping_max = 20.0

	var gradient := GradientTexture1D.new()
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, Color(1.0, 0.6, 0.1, 0.8))
	g.set_color(1, Color(1.0, 0.3, 0.0, 0.0))
	gradient.gradient = g
	mat.color_ramp = gradient

	mat.color = Color(1.0, 0.5, 0.1, 1.0)

	particles.process_material = mat
	particles.lifetime = 0.6

	return particles


func _find_fighter(player_id: int) -> Node:
	# Search for fighters in the scene tree
	var fighters := get_tree().get_nodes_in_group("fighters")
	for f in fighters:
		if "player_id" in f and f.player_id == player_id:
			return f

	# Fallback: search FightScene structure
	var fight_scene := get_tree().current_scene
	if not fight_scene:
		return null
	var fighters_node := fight_scene.get_node_or_null("Fighters")
	if not fighters_node:
		return null
	for child in fighters_node.get_children():
		if "player_id" in child and child.player_id == player_id:
			return child
	return null


# ═════════════════════════════════════════════════════════
# HELPERS
# ═════════════════════════════════════════════════════════

func _get_hit_position(attacker: Variant, target: Variant) -> Vector2:
	if attacker is Node2D and target is Node2D:
		return (attacker.global_position + target.global_position) / 2.0
	if target is Node2D:
		return target.global_position
	return Vector2.ZERO


func _get_hit_type(move: Variant) -> String:
	if move is Dictionary:
		var ht = move.get("hit_type", 0)
		match ht:
			0:  # Hitbox.HitType.LIGHT
				return "light"
			1:  # Hitbox.HitType.MEDIUM
				return "heavy"
			2:  # Hitbox.HitType.HEAVY
				return "special"
		# Fallback: check damage for intensity mapping
		var dmg: int = move.get("damage", 50)
		if dmg >= 100:
			return "special"
		elif dmg >= 70:
			return "heavy"
		return "light"
	return "light"


func _add_to_scene(node: Node2D, pos: Vector2) -> void:
	var scene_root := get_tree().current_scene
	if scene_root:
		scene_root.add_child(node)
		node.global_position = pos
	else:
		add_child(node)
		node.position = pos


func _auto_free(node: Node, delay: float) -> void:
	get_tree().create_timer(delay).timeout.connect(func():
		if is_instance_valid(node):
			node.queue_free()
	)
