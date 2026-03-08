## Stores the last N frames of player input for motion detection and
## input leniency. This is the core of fighting game feel — the buffer
## window, motion tolerance, and consume logic determine whether the
## game feels responsive or eats inputs.
##
## Buffer window: 8 frames (133ms) — generous for casuals, tight for pros.
## Motion window: 15 frames — enough to complete a QCF without rushing.
class_name InputBuffer
extends Node

@export var buffer_size: int = 30          # frames of history (0.5s at 60fps)
@export var input_leniency: int = 8        # frames to queue a button press
@export var simultaneous_window: int = 3   # frames for simultaneous press detection

var buffer: Array = []               # ring buffer of input snapshots
var player_id: int = 1
var facing_right: bool = true

func _ready() -> void:
	for i in buffer_size:
		buffer.append(_empty_frame())

## Called each physics frame by the fighter to capture input.
func update() -> void:
	var raw := _read_raw_input()
	var resolved := _resolve_socd(raw)
	resolved["direction"] = _compute_direction(resolved)
	buffer.append(resolved)
	if buffer.size() > buffer_size:
		buffer.pop_front()

## Check if a button was pressed within the leniency window.
func check_button(button: String) -> bool:
	var start := maxi(0, buffer.size() - input_leniency)
	for i in range(start, buffer.size()):
		if buffer[i].get(button, false):
			return true
	return false

## Check for a specific motion input in the buffer.
## Respects facing direction automatically.
func check_motion(motion_name: String) -> bool:
	return MotionDetector.detect_specific(buffer, motion_name, facing_right)

## Check if multiple buttons were pressed within a small window (throws: LP+LK).
func check_simultaneous(buttons: Array) -> bool:
	var start := maxi(0, buffer.size() - simultaneous_window)
	var found: Dictionary = {}
	for i in range(start, buffer.size()):
		for btn in buttons:
			if buffer[i].get(btn, false):
				found[btn] = true
	return found.size() == buttons.size()

## Consume a button press from the buffer to prevent double execution.
func consume_button(button: String) -> void:
	for i in range(buffer.size() - 1, maxi(0, buffer.size() - input_leniency) - 1, -1):
		if buffer[i].get(button, false):
			buffer[i][button] = false
			return

## Clear motion history to prevent double consumption of directional input.
func consume_motion() -> void:
	var start := maxi(0, buffer.size() - MotionDetector.MOTION_WINDOW)
	for i in range(start, buffer.size()):
		buffer[i]["up"] = false
		buffer[i]["down"] = false
		buffer[i]["left"] = false
		buffer[i]["right"] = false
		buffer[i]["direction"] = 5

## Check if a direction is currently held this frame.
func is_held(direction: String) -> bool:
	if buffer.is_empty():
		return false
	return buffer.back().get(direction, false)

func is_holding_back() -> bool:
	return is_held("left") if facing_right else is_held("right")

func is_holding_forward() -> bool:
	return is_held("right") if facing_right else is_held("left")

func is_holding_down() -> bool:
	return is_held("down")

func is_holding_up() -> bool:
	return is_held("up")

## Detect the best motion currently in the buffer (highest priority).
func detect_best_motion() -> String:
	return MotionDetector.detect_motion(buffer, facing_right)

# --- AI support: inject synthetic inputs ---

func inject_direction(dir: String) -> void:
	if buffer.is_empty():
		return
	buffer.back()[dir] = true
	buffer.back()["direction"] = _compute_direction(buffer.back())

func inject_button(button: String) -> void:
	if buffer.is_empty():
		return
	buffer.back()[button] = true

# --- Internal ---

func _read_raw_input() -> Dictionary:
	var prefix := "p%d_" % player_id
	return {
		# Direction held states (for motion detection and movement)
		"up": Input.is_action_pressed(prefix + "up"),
		"down": Input.is_action_pressed(prefix + "down"),
		"left": Input.is_action_pressed(prefix + "left"),
		"right": Input.is_action_pressed(prefix + "right"),
		# Direction just-pressed (one-frame triggers for jump, etc.)
		"just_up": Input.is_action_just_pressed(prefix + "up"),
		"just_down": Input.is_action_just_pressed(prefix + "down"),
		"just_left": Input.is_action_just_pressed(prefix + "left"),
		"just_right": Input.is_action_just_pressed(prefix + "right"),
		# Attack buttons (one-frame press)
		"lp": Input.is_action_just_pressed(prefix + "light_punch"),
		"hp": Input.is_action_just_pressed(prefix + "heavy_punch"),
		"lk": Input.is_action_just_pressed(prefix + "light_kick"),
		"hk": Input.is_action_just_pressed(prefix + "heavy_kick"),
		# Block held state
		"block": Input.is_action_pressed(prefix + "block"),
	}

## SOCD resolution per GDD: Left+Right=Neutral, Up+Down=Up (jump priority).
func _resolve_socd(input: Dictionary) -> Dictionary:
	var resolved := input.duplicate()
	if resolved.get("left", false) and resolved.get("right", false):
		resolved["left"] = false
		resolved["right"] = false
	if resolved.get("up", false) and resolved.get("down", false):
		resolved["down"] = false
	return resolved

## Compute numpad direction from held cardinals.
func _compute_direction(input: Dictionary) -> int:
	var up: bool = input.get("up", false)
	var down: bool = input.get("down", false)
	var left: bool = input.get("left", false)
	var right: bool = input.get("right", false)
	if up and left: return 7
	if up and right: return 9
	if up: return 8
	if down and left: return 1
	if down and right: return 3
	if down: return 2
	if left: return 4
	if right: return 6
	return 5  # neutral

func _empty_frame() -> Dictionary:
	return {
		"up": false, "down": false, "left": false, "right": false,
		"just_up": false, "just_down": false, "just_left": false, "just_right": false,
		"lp": false, "hp": false, "lk": false, "hk": false,
		"block": false,
		"direction": 5,
	}
