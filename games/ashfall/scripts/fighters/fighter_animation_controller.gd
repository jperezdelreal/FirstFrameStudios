## Bridges the state machine to AnimationPlayer for frame-perfect
## sprite pose transitions and hitbox activation/deactivation.
## Builds animations programmatically from MoveData so frame data
## (startup/active/recovery) drives visuals deterministically at 60 FPS.
class_name FighterAnimationController
extends Node

## Cached node references — resolved in _ready().
var fighter: Fighter
var anim_player: AnimationPlayer
var character_sprite: CharacterSprite
var anim_library: AnimationLibrary

## Relative node paths from the fighter root (set dynamically).
var _sprite_path: String = ""
var _hitbox_shape_path: String = "Hitboxes/Hitbox/CollisionShape"
var _hitbox_area_path: String = "Hitboxes/Hitbox"

## Walk cycle timing (frames per step at 60 FPS).
const WALK_STEP_FRAMES: int = 5
const FRAME_DURATION: float = 1.0 / 60.0

## Track last played animation to avoid redundant play() calls.
var _current_anim: String = ""


func _ready() -> void:
	# Walk up to find the Fighter owner
	var node := get_parent()
	while node:
		if node is Fighter:
			fighter = node
			break
		node = node.get_parent()

	if not fighter:
		push_warning("FighterAnimationController: No Fighter ancestor found")
		return

	# Find the CharacterSprite child
	for child in fighter.get_children():
		if child is CharacterSprite:
			character_sprite = child
			_sprite_path = str(fighter.get_path_to(child))
			break

	if not character_sprite:
		push_warning("FighterAnimationController: No CharacterSprite found")
		return

	# Get or validate AnimationPlayer
	anim_player = fighter.get_node_or_null("AnimationPlayer")
	if not anim_player:
		push_warning("FighterAnimationController: No AnimationPlayer node found")
		return

	# Deterministic: process in physics step, not render frame
	anim_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS

	# Create animation library and populate all animations
	anim_library = AnimationLibrary.new()
	_build_all_animations()
	anim_player.add_animation_library("", anim_library)

	# Connect to state machine for automatic animation switching
	if fighter.state_machine:
		fighter.state_machine.state_changed.connect(_on_state_changed)

	# Start with idle
	play_animation("idle")


## Play a named animation. No-op if already playing the same one.
func play_animation(anim_name: String) -> void:
	if not anim_player:
		return
	if _current_anim == anim_name:
		return
	if anim_player.has_animation(anim_name):
		_current_anim = anim_name
		anim_player.play(anim_name)
	else:
		push_warning("FighterAnimationController: Animation '%s' not found" % anim_name)


## Build an attack animation from MoveData frame data.
## Returns the animation name so the caller can play it.
func play_attack_animation(move: MoveData) -> String:
	if not move or not anim_player:
		return ""
	var anim_name := _attack_anim_name(move)
	# Build on first use (lazy creation for dynamically loaded moves)
	if not anim_player.has_animation(anim_name):
		_build_attack_animation(move)
	play_animation(anim_name)
	return anim_name


## Stop current animation and reset to idle pose.
func stop_and_reset() -> void:
	if anim_player and anim_player.is_playing():
		anim_player.stop()
	_current_anim = ""
	if character_sprite:
		character_sprite.pose = "idle"


# =========================================================================
#  Signal handler
# =========================================================================

func _on_state_changed(state_name: String) -> void:
	var lower := state_name.to_lower()
	match lower:
		"idle":
			play_animation("idle")
		"walk":
			play_animation("walk")
		"crouch":
			play_animation("crouch")
		"jump":
			play_animation("jump")
		"block":
			_play_block_animation()
		"hit":
			play_animation("hit")
		"ko":
			play_animation("ko")
		"throw":
			play_animation("throw")
		"attack":
			_play_attack_from_state()
		_:
			play_animation("idle")


# =========================================================================
#  Animation builders
# =========================================================================

func _build_all_animations() -> void:
	_build_idle_animation()
	_build_walk_animation()
	_build_crouch_animation()
	_build_jump_animation()
	_build_hit_animation()
	_build_ko_animation()
	_build_block_animations()
	_build_throw_animation()
	_build_moveset_animations()


func _build_idle_animation() -> void:
	var anim := Animation.new()
	anim.length = FRAME_DURATION
	anim.loop_mode = Animation.LOOP_LINEAR

	_add_pose_track(anim, "idle", 0.0)
	anim_library.add_animation("idle", anim)


func _build_walk_animation() -> void:
	var total_frames := WALK_STEP_FRAMES * 2
	var anim := Animation.new()
	anim.length = total_frames * FRAME_DURATION
	anim.loop_mode = Animation.LOOP_LINEAR

	var track_idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, _sprite_path + ":pose")
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_NEAREST)
	# Step 1: walk pose
	anim.track_insert_key(track_idx, 0.0, "walk")
	# Step 2: walk_2 pose
	anim.track_insert_key(track_idx, WALK_STEP_FRAMES * FRAME_DURATION, "walk_2")

	anim_library.add_animation("walk", anim)


func _build_crouch_animation() -> void:
	var anim := Animation.new()
	anim.length = FRAME_DURATION
	anim.loop_mode = Animation.LOOP_LINEAR

	_add_pose_track(anim, "crouch", 0.0)
	anim_library.add_animation("crouch", anim)


func _build_jump_animation() -> void:
	# Jump uses 3 phases based on velocity. We create a base animation
	# that starts with jump_up; the bridge overrides pose dynamically
	# for peak/fall phases based on fighter velocity each frame.
	var anim := Animation.new()
	anim.length = 3.0  # Long enough for any jump (safety: 180 frames = 3s)
	anim.loop_mode = Animation.LOOP_NONE

	_add_pose_track(anim, "jump_up", 0.0)
	anim_library.add_animation("jump", anim)


func _build_hit_animation() -> void:
	# Duration is dynamic (hitstun frames vary per move).
	# Default to max hitstun length; state will transition before it ends.
	var anim := Animation.new()
	anim.length = 60.0 * FRAME_DURATION  # MAX_HITSTUN = 60 frames
	anim.loop_mode = Animation.LOOP_NONE

	_add_pose_track(anim, "hit", 0.0)
	anim_library.add_animation("hit", anim)


func _build_ko_animation() -> void:
	var anim := Animation.new()
	anim.length = 180.0 * FRAME_DURATION  # SAFETY_TIMEOUT = 180 frames
	anim.loop_mode = Animation.LOOP_NONE

	_add_pose_track(anim, "ko", 0.0)
	anim_library.add_animation("ko", anim)


func _build_block_animations() -> void:
	# Standing block
	var standing := Animation.new()
	standing.length = FRAME_DURATION
	standing.loop_mode = Animation.LOOP_LINEAR
	_add_pose_track(standing, "block_standing", 0.0)
	anim_library.add_animation("block_standing", standing)

	# Crouching block
	var crouching := Animation.new()
	crouching.length = FRAME_DURATION
	crouching.loop_mode = Animation.LOOP_LINEAR
	_add_pose_track(crouching, "block_crouching", 0.0)
	anim_library.add_animation("block_crouching", crouching)


func _build_throw_animation() -> void:
	# Throw has multiple phases handled by ThrowState.
	# This animation sets the pose; phase transitions are state-driven.
	var anim := Animation.new()
	anim.length = 120.0 * FRAME_DURATION  # Safety timeout
	anim.loop_mode = Animation.LOOP_NONE

	_add_pose_track(anim, "attack_hp", 0.0)
	anim_library.add_animation("throw", anim)


func _build_moveset_animations() -> void:
	if not fighter.moveset:
		return
	for move in fighter.moveset.normals:
		_build_attack_animation(move)
	for move in fighter.moveset.specials:
		_build_attack_animation(move)


## Build a single attack animation with frame-accurate hitbox tracks.
func _build_attack_animation(move: MoveData) -> void:
	var anim_name := _attack_anim_name(move)
	if anim_library.has_animation(anim_name):
		return

	var total := move.total_frames()
	var anim := Animation.new()
	anim.length = total * FRAME_DURATION
	anim.loop_mode = Animation.LOOP_NONE

	# --- Pose track ---
	var pose_name := _move_to_pose(move)
	var pose_track := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(pose_track, _sprite_path + ":pose")
	anim.track_set_interpolation_type(pose_track, Animation.INTERPOLATION_NEAREST)
	anim.track_insert_key(pose_track, 0.0, pose_name)

	# --- Hitbox CollisionShape disabled track ---
	var shape_track := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(shape_track, _hitbox_shape_path + ":disabled")
	anim.track_set_interpolation_type(shape_track, Animation.INTERPOLATION_NEAREST)
	# Startup: disabled
	anim.track_insert_key(shape_track, 0.0, true)
	# Active: enabled
	var active_start := move.startup_frames * FRAME_DURATION
	anim.track_insert_key(shape_track, active_start, false)
	# Recovery: disabled again
	var recovery_start := (move.startup_frames + move.active_frames) * FRAME_DURATION
	anim.track_insert_key(shape_track, recovery_start, true)

	# --- Hitbox Area2D monitoring track ---
	var monitor_track := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(monitor_track, _hitbox_area_path + ":monitoring")
	anim.track_set_interpolation_type(monitor_track, Animation.INTERPOLATION_NEAREST)
	anim.track_insert_key(monitor_track, 0.0, false)
	anim.track_insert_key(monitor_track, active_start, true)
	anim.track_insert_key(monitor_track, recovery_start, false)

	anim_library.add_animation(anim_name, anim)


# =========================================================================
#  Helpers
# =========================================================================

## Add a simple single-key pose track to an animation.
func _add_pose_track(anim: Animation, pose_value: String, time: float) -> void:
	var track_idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, _sprite_path + ":pose")
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_NEAREST)
	anim.track_insert_key(track_idx, time, pose_value)


## Derive animation name from a MoveData resource.
func _attack_anim_name(move: MoveData) -> String:
	if move.move_name != "":
		return "attack_" + move.move_name
	# Fallback: build from button + stance
	var prefix := "crouch_" if move.requires_crouch else "attack_"
	return prefix + move.input_button


## Map a MoveData to its sprite pose name.
func _move_to_pose(move: MoveData) -> String:
	var button := move.input_button
	if move.requires_crouch:
		match button:
			"lp": return "attack_lp"
			"hp": return "attack_hp"
			"lk": return "attack_lp"
			"hk": return "attack_hp"
			_:    return "attack_mp"
	match button:
		"lp": return "attack_lp"
		"mp": return "attack_mp"
		"hp": return "attack_hp"
		"lk": return "attack_lp"
		"mk": return "attack_mp"
		"hk": return "attack_hp"
		_:    return "attack_mp"


## Play the block animation matching the current stance.
func _play_block_animation() -> void:
	if not fighter or not fighter.state_machine or not fighter.state_machine.current_state:
		play_animation("block_standing")
		return
	var block_state := fighter.state_machine.current_state
	var is_crouching: bool = false
	if block_state.has_method("is_crouching"):
		is_crouching = block_state.is_crouching()
	elif "is_crouching" in block_state or "_is_crouching" in block_state:
		is_crouching = block_state.get("_is_crouching") if "_is_crouching" in block_state else false
	play_animation("block_crouching" if is_crouching else "block_standing")


## Play the attack animation matching the current AttackState's move.
func _play_attack_from_state() -> void:
	if not fighter or not fighter.state_machine:
		return
	var attack_state := fighter.state_machine.current_state
	if attack_state and attack_state.has_method("get_current_move"):
		var move: MoveData = attack_state.get_current_move()
		if move:
			play_attack_animation(move)
			return
	# Fallback: generic attack pose
	play_animation("hit")  # Will be overridden by bridge
