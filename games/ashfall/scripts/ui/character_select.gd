## Character select — button-based UI (same pattern as main_menu.gd).
## Uses Godot Button nodes with focus navigation so keyboard input works
## natively in both editor and exported builds.
extends Control

const CHARACTERS := [
	{"name": "Kael", "archetype": "Balanced", "color": Color(0.31, 0.765, 0.969)},
	{"name": "Rhena", "archetype": "Rushdown", "color": Color(0.937, 0.325, 0.314)},
]

var p1_index: int = -1
var _transitioning: bool = false

@onready var kael_btn: Button = %KaelButton
@onready var rhena_btn: Button = %RhenaButton
@onready var fight_btn: Button = %FightButton
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
	fight_btn.visible = false
	_wire_buttons()
	_update_display()
	var mode_text := "VS CPU" if SceneManager.game_mode == "vs_cpu" else "VS PLAYER"
	mode_label.text = mode_text
	kael_btn.grab_focus()


func _wire_buttons() -> void:
	kael_btn.pressed.connect(_on_character_selected.bind(0))
	rhena_btn.pressed.connect(_on_character_selected.bind(1))
	fight_btn.pressed.connect(_on_fight)
	# Focus neighbours for keyboard nav
	kael_btn.focus_neighbor_bottom = kael_btn.get_path_to(rhena_btn)
	rhena_btn.focus_neighbor_top = rhena_btn.get_path_to(kael_btn)
	rhena_btn.focus_neighbor_bottom = rhena_btn.get_path_to(fight_btn)
	fight_btn.focus_neighbor_top = fight_btn.get_path_to(rhena_btn)


func _on_character_selected(index: int) -> void:
	if _transitioning:
		return
	p1_index = index
	_sync_cpu()
	_update_display()
	_on_fight()


func _on_fight() -> void:
	if _transitioning or p1_index < 0:
		return
	_transitioning = true
	var p2_index := 1 if p1_index == 0 else 0
	SceneManager.p1_character = CHARACTERS[p1_index].name
	SceneManager.p2_character = CHARACTERS[p2_index].name
	get_tree().create_timer(0.5).timeout.connect(SceneManager.goto_fight)


func _sync_cpu() -> void:
	if SceneManager.game_mode != "vs_cpu":
		return


func _update_display() -> void:
	var p2_index := (1 - p1_index) if p1_index >= 0 else 1

	if p1_index >= 0:
		var p1: Dictionary = CHARACTERS[p1_index]
		p1_name_label.text = p1.name
		p1_archetype_label.text = p1.archetype
		p1_status_label.text = "READY!"
	else:
		p1_name_label.text = "?"
		p1_archetype_label.text = "Choose your fighter"
		p1_status_label.text = "Pick a character above"

	var p2: Dictionary = CHARACTERS[p2_index]
	p2_portrait.color = p2.color
	p2_name_label.text = p2.name
	p2_archetype_label.text = p2.archetype
	p2_status_label.text = "CPU" if SceneManager.game_mode == "vs_cpu" else (
		"READY!" if p1_index >= 0 else "Waiting..."
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _transitioning:
			return
		if p1_index >= 0:
			p1_index = -1
			fight_btn.visible = false
			_update_display()
			kael_btn.grab_focus()
		else:
			SceneManager.goto_main_menu()
		get_viewport().set_input_as_handled()
