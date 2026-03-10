extends Node2D
## Automated Fight Scene Visual Test
## Loads the fight scene, waits for FIGHT state, simulates player inputs,
## and captures screenshots at each step for AI-based visual analysis.
##
## Usage: Pass `-- --visual-test` on the Godot command line.
## Output: Screenshots saved to res://tools/screenshots/fight_test/ and user://fight_test/
## Author: Ackbar (QA/Playtester)

const FIGHT_SCENE_PATH := "res://scenes/main/fight_scene.tscn"
const SCREENSHOT_RES_DIR := "res://tools/screenshots/fight_test/"
const SCREENSHOT_USER_DIR := "user://fight_test/"
const TOTAL_STEPS := 7

var _visual_test_mode := false
var _screenshots_captured := 0


func _ready() -> void:
	_parse_args()
	if not _visual_test_mode:
		print("[VISUAL_TEST] Not in visual-test mode. Pass -- --visual-test to activate.")
		get_tree().quit()
		return

	_ensure_output_dirs()
	_print_header()

	# Instance the fight scene as a child
	var fight_scene := preload(FIGHT_SCENE_PATH).instantiate()
	add_child(fight_scene)

	# Wait for the FIGHT state via RoundManager announce signal
	RoundManager.announce.connect(_on_announce)
	print("[VISUAL_TEST] Fight scene loaded. Waiting for round intro to finish...")


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--visual-test":
			_visual_test_mode = true


func _on_announce(text: String) -> void:
	if text == "FIGHT!":
		RoundManager.announce.disconnect(_on_announce)
		print("[VISUAL_TEST] FIGHT! Round is active — beginning test sequence.")
		_run_test_sequence()


# ── Test Sequence ─────────────────────────────────────────────────

func _run_test_sequence() -> void:
	# Step 1: IDLE — both fighters standing, no input
	_log_step(1, "Idle — both fighters standing")
	await _wait_frames(60)
	await _capture("01_idle")

	# Step 2: P1 WALK FORWARD — hold right for 60 frames
	_log_step(2, "P1 Walk Forward")
	Input.action_press("p1_right")
	await _wait_frames(60)
	await _capture("02_p1_walk")
	Input.action_release("p1_right")

	# Step 3: P1 LIGHT PUNCH — tap punch, wait for animation
	_log_step(3, "P1 Light Punch")
	Input.action_press("p1_light_punch")
	await get_tree().process_frame
	Input.action_release("p1_light_punch")
	await _wait_frames(15)
	await _capture("03_p1_punch")
	await _wait_frames(15)

	# Step 4: P1 LIGHT KICK — tap kick, wait for animation
	_log_step(4, "P1 Light Kick")
	Input.action_press("p1_light_kick")
	await get_tree().process_frame
	Input.action_release("p1_light_kick")
	await _wait_frames(15)
	await _capture("04_p1_kick")
	await _wait_frames(15)

	# Step 5: P1 JUMP — tap up, capture mid-air
	_log_step(5, "P1 Jump (mid-air capture)")
	Input.action_press("p1_up")
	await get_tree().process_frame
	Input.action_release("p1_up")
	await _wait_frames(12)
	await _capture("05_p1_jump")
	await _wait_frames(20)

	# Step 6: WAIT — let fighters settle back to idle
	_log_step(6, "Wait — letting fighters settle")
	await _wait_frames(60)
	await _capture("06_settled")

	# Step 7: CLOSE-UP — walk P1 close to P2, test camera zoom
	_log_step(7, "Close-up — P1 walks to P2")
	Input.action_press("p1_right")
	await _wait_frames(40)
	Input.action_release("p1_right")
	await _wait_frames(10)
	await _capture("07_close")

	_finish()


# ── Utilities ─────────────────────────────────────────────────────

func _wait_frames(count: int) -> void:
	for i in range(count):
		await get_tree().process_frame


func _capture(screenshot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()

	# Save to res://tools/screenshots/fight_test/ (project-relative, easy for agents)
	var res_path := SCREENSHOT_RES_DIR + screenshot_name + ".png"
	var abs_res := ProjectSettings.globalize_path(res_path)
	var err_res := image.save_png(abs_res)
	if err_res == OK:
		print("[VISUAL_TEST] Saved: %s" % abs_res)
	else:
		push_error("[VISUAL_TEST] FAIL saving %s (error %d)" % [abs_res, err_res])

	# Save to user://fight_test/ (guaranteed writable, absolute path for external tools)
	var user_path := SCREENSHOT_USER_DIR + screenshot_name + ".png"
	var err_user := image.save_png(user_path)
	if err_user == OK:
		var abs_user := ProjectSettings.globalize_path(user_path)
		print("[VISUAL_TEST] Saved: %s" % abs_user)
	else:
		push_error("[VISUAL_TEST] FAIL saving %s (error %d)" % [user_path, err_user])

	_screenshots_captured += 1
	print("[VISUAL_TEST] [%d/%d] %s — %dx%d" % [
		_screenshots_captured, TOTAL_STEPS, screenshot_name,
		image.get_width(), image.get_height()
	])


func _log_step(step: int, description: String) -> void:
	print("[VISUAL_TEST] Step %d/%d: %s" % [step, TOTAL_STEPS, description])


func _ensure_output_dirs() -> void:
	var res_abs := ProjectSettings.globalize_path(SCREENSHOT_RES_DIR)
	DirAccess.make_dir_recursive_absolute(res_abs)
	var user_abs := OS.get_user_data_dir() + "/fight_test"
	DirAccess.make_dir_recursive_absolute(user_abs)


func _print_header() -> void:
	var res_abs := ProjectSettings.globalize_path(SCREENSHOT_RES_DIR)
	var user_abs := OS.get_user_data_dir() + "/fight_test"
	print("[VISUAL_TEST] ==========================================")
	print("[VISUAL_TEST]  Ashfall — Fight Scene Visual Test")
	print("[VISUAL_TEST]  Steps: %d" % TOTAL_STEPS)
	print("[VISUAL_TEST]  Output (res://):  %s" % res_abs)
	print("[VISUAL_TEST]  Output (user://): %s" % user_abs)
	print("[VISUAL_TEST] ==========================================")


func _finish() -> void:
	# Release any lingering inputs as safety measure
	for action in ["p1_right", "p1_left", "p1_up", "p1_down",
			"p1_light_punch", "p1_light_kick"]:
		Input.action_release(action)

	var res_abs := ProjectSettings.globalize_path(SCREENSHOT_RES_DIR)
	var user_abs := OS.get_user_data_dir() + "/fight_test"
	print("[VISUAL_TEST] ==========================================")
	print("[VISUAL_TEST]  DONE — %d/%d screenshots captured" % [_screenshots_captured, TOTAL_STEPS])
	print("[VISUAL_TEST]  res:// dir:  %s" % res_abs)
	print("[VISUAL_TEST]  user:// dir: %s" % user_abs)
	print("[VISUAL_TEST] ==========================================")

	# Brief delay for clean exit
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
