## Character select — direct key-event driven (no dependency on input action map).
## Uses InputEventKey keycodes so Enter/Space/Arrows/Escape always work regardless
## of whether ui_* actions exist in project.godot.
extends Control

const CHARACTERS := [
	{"name": "Kael", "archetype": "Balanced", "color": Color(0.31, 0.765, 0.969)},
	{"name": "Rhena", "archetype": "Rushdown", "color": Color(0.937, 0.325, 0.314)},
]

# Selection state
var p1_index: int = 0
var p2_index: int = 1
var p1_confirmed: bool = false
var p2_confirmed: bool = false
var _transitioning: bool = false

# Node refs
@onready var p1_portrait: ColorRect = %P1Portrait
@onready var p1_name_label: Label = %P1NameLabel
@onready var p1_archetype_label: Label = %P1ArchetypeLabel
@onready var p1_status_label: Label = %P1StatusLabel
@onready var p2_portrait: ColorRect = %P2Portrait
@onready var p2_name_label: Label = %P2NameLabel
@onready var p2_archetype_label: Label = %P2ArchetypeLabel
@onready var p2_status_label: Label = %P2StatusLabel
@onready var vs_label: Label = %VsLabel
@onready var mode_label: Label = %ModeLabel


func _ready() -> void:
	set_process_input(true)
	_update_display()
	var mode_text := "VS CPU" if SceneManager.game_mode == "vs_cpu" else "VS PLAYER"
	mode_label.text = mode_text


func _input(event: InputEvent) -> void:
	if _transitioning:
		return
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	# Resolve key — prefer physical_keycode (layout-independent), fall back to keycode
	var key: int = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	if key == KEY_NONE:
		return

	# --- ESCAPE: back / un-confirm ---
	if key == KEY_ESCAPE:
		if p1_confirmed:
			p1_confirmed = false
			_sync_cpu()
			_update_display()
		else:
			SceneManager.goto_main_menu()
		get_viewport().set_input_as_handled()
		return

	# --- NAVIGATION: Left / Right (arrows or A / D) ---
	if key in [KEY_LEFT, KEY_A] and not p1_confirmed:
		p1_index = wrapi(p1_index - 1, 0, CHARACTERS.size())
		_sync_cpu()
		_update_display()
		get_viewport().set_input_as_handled()
		return

	if key in [KEY_RIGHT, KEY_D] and not p1_confirmed:
		p1_index = wrapi(p1_index + 1, 0, CHARACTERS.size())
		_sync_cpu()
		_update_display()
		get_viewport().set_input_as_handled()
		return

	# --- CONFIRM: Enter / Space / KP Enter / U (p1_light_punch legacy) ---
	if key in [KEY_ENTER, KEY_SPACE, KEY_KP_ENTER, KEY_U] and not p1_confirmed:
		p1_confirmed = true
		_sync_cpu()
		_update_display()
		_check_ready()
		get_viewport().set_input_as_handled()
		return


func _sync_cpu() -> void:
	if SceneManager.game_mode != "vs_cpu":
		return
	p2_index = 1 if p1_index == 0 else 0
	p2_confirmed = p1_confirmed


func _check_ready() -> void:
	if p1_confirmed and p2_confirmed and not _transitioning:
		_transitioning = true
		SceneManager.p1_character = CHARACTERS[p1_index].name
		SceneManager.p2_character = CHARACTERS[p2_index].name
		get_tree().create_timer(0.5).timeout.connect(SceneManager.goto_fight)


func _update_display() -> void:
	var p1 := CHARACTERS[p1_index]
	var p2 := CHARACTERS[p2_index]
	p1_portrait.color = p1.color
	p1_name_label.text = p1.name
	p1_archetype_label.text = p1.archetype
	p1_status_label.text = "READY!" if p1_confirmed else "← →  Enter to Confirm"

	p2_portrait.color = p2.color
	p2_name_label.text = p2.name
	p2_archetype_label.text = p2.archetype
	p2_status_label.text = "CPU" if SceneManager.game_mode == "vs_cpu" else (
		"READY!" if p2_confirmed else "← →  Enter to Confirm"
	)
