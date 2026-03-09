## Autoload VFX manager. Spawns character-specific hit sparks, block sparks,
## screen shake, hitstun flash, damage number popups, KO freeze-frame/slow-motion,
## KO screen flash, and ember particle trails.
## Connects exclusively to EventBus signals — zero direct coupling.
## Character palettes: Kael (blue-ember, controlled) vs Rhena (red-orange, explosive).
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

# ── KO freeze-frame state ──────────────────────────────
var _ko_freeze_frames: int = 0
const KO_FREEZE_FRAMES: int = 6  # ~100ms at 60fps

# ── Character VFX palettes ─────────────────────────────
# Kael (Cinder Monk): cool discipline — blue-ember accents, controlled precise bursts
# Rhena (Wildfire): hot intensity — orange-ember, red/explosive wild scattered
const CHARACTER_PALETTES := {
	"Kael": {
		"spark_start": Color(0.5, 0.8, 1.0, 1.0),
		"spark_end": Color(1.0, 0.6, 0.2, 0.0),
		"spark_base": Color(0.4, 0.7, 1.0, 1.0),
		"spread": 40.0,
		"vel_min": 80.0,
		"vel_max": 180.0,
		"gravity": Vector3(0, -60, 0),
		"particle_bonus": 0,
		"damping_min": 20.0,
		"damping_max": 40.0,
		"scale_min": 1.5,
		"scale_max": 2.5,
		"ko_start": Color(0.5, 0.8, 1.0, 1.0),
		"ko_end": Color(1.0, 0.6, 0.2, 0.0),
		"flash_color": Color(3.0, 4.0, 5.0, 1.0),
		"dmg_color": Color(0.4, 0.85, 1.0, 1.0),
	},
	"Rhena": {
		"spark_start": Color(1.0, 1.0, 0.9, 1.0),
		"spark_end": Color(1.0, 0.05, 0.0, 0.0),
		"spark_base": Color(1.0, 0.4, 0.1, 1.0),
		"spread": 90.0,
		"vel_min": 160.0,
		"vel_max": 350.0,
		"gravity": Vector3(0, 300, 0),
		"particle_bonus": 4,
		"damping_min": 15.0,
		"damping_max": 35.0,
		"scale_min": 1.0,
		"scale_max": 4.0,
		"ko_start": Color(1.0, 0.3, 0.0, 1.0),
		"ko_end": Color(0.8, 0.0, 0.0, 0.0),
		"flash_color": Color(5.0, 2.0, 1.0, 1.0),
		"dmg_color": Color(1.0, 0.3, 0.1, 1.0),
	},
}
const DEFAULT_PALETTE := {
	"spark_start": Color(1.0, 1.0, 1.0, 1.0),
	"spark_end": Color(1.0, 0.6, 0.1, 0.0),
	"spark_base": Color(1.0, 0.9, 0.7, 1.0),
	"spread": 60.0,
	"vel_min": 120.0,
	"vel_max": 250.0,
	"gravity": Vector3(0, 300, 0),
	"particle_bonus": 0,
	"damping_min": 40.0,
	"damping_max": 80.0,
	"scale_min": 1.5,
	"scale_max": 3.0,
	"ko_start": Color(1.0, 1.0, 0.8, 1.0),
	"ko_end": Color(1.0, 0.3, 0.0, 0.0),
	"flash_color": Color(5.0, 5.0, 5.0, 1.0),
	"dmg_color": Color(1.0, 0.9, 0.7, 1.0),
}


func _ready() -> void:
	assert(EventBus != null, "VFXManager requires EventBus to load first")
	assert(GameState != null, "VFXManager requires GameState to load first")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_wire_signals()


func _process(delta: float) -> void:
	_tick_freeze()
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
	var char_name := _get_character_name(attacker)

	_spawn_hit_sparks(hit_pos, hit_type, char_name)
	_apply_screen_shake(hit_type, move)
	_apply_flash(target, char_name)
	_spawn_damage_number(hit_pos, move, char_name)


func _on_hit_confirmed(attacker: Variant, target: Variant, _move: Variant, _combo_count: int) -> void:
	if target and is_instance_valid(target):
		_apply_flash(target, _get_character_name(attacker))


# ── Hit blocked: blue/white sparks + light shake ────────

func _on_hit_blocked(attacker: Variant, target: Variant, move: Variant) -> void:
	if not target or not is_instance_valid(target):
		return
	var hit_pos := _get_hit_position(attacker, target)
	_spawn_block_sparks(hit_pos)
	_apply_screen_shake("light", move)


# ── KO: slow-motion + big burst ────────────────────────

func _on_fighter_ko(fighter: Variant) -> void:
	if not fighter or not is_instance_valid(fighter):
		return
	var pos: Vector2
	if fighter is Node2D:
		pos = fighter.global_position
	else:
		pos = Vector2.ZERO
	var ko_char := _get_ko_attacker_name(fighter)
	_start_ko_freeze_frame()
	_spawn_ko_burst(pos, ko_char)
	_spawn_ko_flash(ko_char)
	_apply_screen_shake("special")


# ── Ember changed: update ember trail particles ─────────

func _on_ember_changed(player_id: int, new_value: int) -> void:
	_update_ember_trail(player_id, new_value)


# ── Ember spent: burst flash feedback ───────────────────

func _on_ember_spent(player_id: int, _amount: int, _action: String) -> void:
	var fighter := _find_fighter(player_id)
	if fighter and fighter is Node2D:
		var char_name := _get_character_name(fighter)
		_spawn_hit_sparks(fighter.global_position + Vector2(0, -30), "special", char_name)
		_apply_screen_shake("light")


# ── Round started: reset VFX state ──────────────────────

func _on_round_started(_round_number: int) -> void:
	_shake_intensity = 0.0
	_shake_duration = 0.0
	_shake_elapsed = 0.0
	_ko_slowmo_timer = 0.0
	_ko_freeze_frames = 0
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

func _spawn_hit_sparks(pos: Vector2, hit_type: String, char_name: String = "") -> void:
	var palette := _get_palette(char_name)
	var particles := GPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.z_index = 100

	var base_count: int
	match hit_type:
		"light":
			base_count = 8
		"heavy":
			base_count = 10
		"special":
			base_count = 12
		_:
			base_count = 8
	particles.amount = base_count + palette.particle_bonus

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = palette.spread
	mat.initial_velocity_min = palette.vel_min
	mat.initial_velocity_max = palette.vel_max
	mat.gravity = palette.gravity
	mat.scale_min = palette.scale_min
	mat.scale_max = palette.scale_max
	mat.damping_min = palette.damping_min
	mat.damping_max = palette.damping_max

	var gradient := GradientTexture1D.new()
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, palette.spark_start)
	g.set_color(1, palette.spark_end)
	gradient.gradient = g
	mat.color_ramp = gradient

	mat.color = palette.spark_base

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

func _spawn_ko_burst(pos: Vector2, char_name: String = "") -> void:
	var palette := _get_palette(char_name)
	var particles := GPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 24 + palette.particle_bonus * 2
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
	g.set_color(0, palette.ko_start)
	g.set_color(1, palette.ko_end)
	gradient.gradient = g
	mat.color_ramp = gradient

	mat.color = palette.spark_base

	particles.process_material = mat
	particles.lifetime = 0.6

	_add_to_scene(particles, pos)
	particles.emitting = true
	_auto_free(particles, 1.0)


# ═════════════════════════════════════════════════════════
# SCREEN SHAKE — camera offset with exponential decay
# ═════════════════════════════════════════════════════════

func _apply_screen_shake(hit_type: String, move: Variant = null) -> void:
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

	# Scale intensity by actual move damage when available
	if move is Dictionary:
		var dmg: int = move.get("damage", 50)
		intensity *= clampf(float(dmg) / 80.0, 0.6, 2.0)

	# Only override if new shake is stronger
	if intensity > _shake_intensity:
		_shake_intensity = intensity
		_shake_duration = 0.15 + clampf(intensity / 50.0, 0.0, 0.1)
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

func _apply_flash(target: Variant, char_name: String = "") -> void:
	if not target or not is_instance_valid(target):
		return

	var palette := _get_palette(char_name)
	var flash_col: Color = palette.flash_color

	# Avoid duplicate flash entries for same target
	for entry in _flash_targets:
		if entry.target == target:
			entry.frames_remaining = FLASH_FRAMES
			entry.flash_color = flash_col
			_set_flash(target, flash_col)
			return

	_flash_targets.append({
		"target": target,
		"frames_remaining": FLASH_FRAMES,
		"original_modulate": _get_modulate(target),
		"flash_color": flash_col,
	})
	_set_flash(target, flash_col)


func _tick_flash() -> void:
	var i := _flash_targets.size() - 1
	while i >= 0:
		var entry: Dictionary = _flash_targets[i]
		entry.frames_remaining -= 1
		if entry.frames_remaining <= 0:
			_restore_modulate(entry.target)
			_flash_targets.remove_at(i)
		i -= 1


func _set_flash(target: Variant, flash_color: Color) -> void:
	if not is_instance_valid(target):
		return

	var sprite: Node = null
	if target.has_node("Sprite"):
		sprite = target.get_node("Sprite")
	elif target.has_node("Visual"):
		sprite = target.get_node("Visual")

	if sprite and sprite is CanvasItem:
		sprite.modulate = flash_color


func _restore_modulate(target: Variant) -> void:
	if not is_instance_valid(target):
		return

	var sprite: Node = null
	if target.has_node("Sprite"):
		sprite = target.get_node("Sprite")
	elif target.has_node("Visual"):
		sprite = target.get_node("Visual")

	if sprite and sprite is CanvasItem:
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


# ═════════════════════════════════════════════════════════
# KO FREEZE-FRAME — brief Engine.time_scale=0 pause
# ═════════════════════════════════════════════════════════

func _start_ko_freeze_frame() -> void:
	Engine.time_scale = 0.0
	_ko_freeze_frames = KO_FREEZE_FRAMES


func _tick_freeze() -> void:
	if _ko_freeze_frames <= 0:
		return
	_ko_freeze_frames -= 1
	if _ko_freeze_frames <= 0:
		_start_ko_slowmo()


# ═════════════════════════════════════════════════════════
# KO FLASH — full-screen color flash tinted by attacker
# ═════════════════════════════════════════════════════════

func _spawn_ko_flash(char_name: String) -> void:
	var palette := _get_palette(char_name)
	var layer := CanvasLayer.new()
	layer.layer = 100

	var rect := ColorRect.new()
	var fc := palette.flash_color
	rect.color = Color(minf(fc.r / 5.0, 1.0), minf(fc.g / 5.0, 1.0), minf(fc.b / 5.0, 1.0), 0.8)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	add_child(layer)

	var tween := create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(layer.queue_free)


# ═════════════════════════════════════════════════════════
# DAMAGE NUMBERS — floating popups that fade up and out
# ═════════════════════════════════════════════════════════

func _spawn_damage_number(pos: Vector2, move: Variant, char_name: String) -> void:
	var damage := 0
	if move is Dictionary:
		damage = move.get("damage", 0)
	if damage <= 0:
		return

	var palette := _get_palette(char_name)
	var marker := Node2D.new()
	marker.z_index = 200

	var label := Label.new()
	label.text = str(damage)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", _get_damage_font_size(damage))
	label.add_theme_color_override("font_color", palette.dmg_color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 3)
	label.position = Vector2(-20, -10)
	marker.add_child(label)

	_add_to_scene(marker, pos + Vector2(randf_range(-15.0, 15.0), -30.0))

	var start_y := marker.global_position.y
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(marker, "global_position:y", start_y - 60.0, 0.8) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(marker, "modulate:a", 0.0, 0.6) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.2)
	_auto_free(marker, 1.0)


func _get_damage_font_size(damage: int) -> int:
	if damage >= 100:
		return 28
	elif damage >= 70:
		return 24
	return 20


# ═════════════════════════════════════════════════════════
# CHARACTER IDENTIFICATION
# ═════════════════════════════════════════════════════════

func _get_character_name(fighter: Variant) -> String:
	if not fighter or not is_instance_valid(fighter) or not "player_id" in fighter:
		return ""
	if fighter.player_id == 1:
		return SceneManager.p1_character if SceneManager else ""
	elif fighter.player_id == 2:
		return SceneManager.p2_character if SceneManager else ""
	return ""


func _get_ko_attacker_name(ko_victim: Variant) -> String:
	if not ko_victim or not is_instance_valid(ko_victim) or not "player_id" in ko_victim:
		return ""
	# The attacker is the OTHER player
	if ko_victim.player_id == 1:
		return SceneManager.p2_character if SceneManager else ""
	elif ko_victim.player_id == 2:
		return SceneManager.p1_character if SceneManager else ""
	return ""


func _get_palette(char_name: String) -> Dictionary:
	if CHARACTER_PALETTES.has(char_name):
		return CHARACTER_PALETTES[char_name]
	return DEFAULT_PALETTE
