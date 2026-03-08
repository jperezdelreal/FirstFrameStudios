## Character select — two-panel selection with WASD (P1) and Arrows (P2).
## Confirm with attack, back with block. Transitions to fight when both confirm.
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
	_update_display()
	var mode_text := "VS CPU" if SceneManager.game_mode == "vs_cpu" else "VS PLAYER"
	mode_label.text = mode_text


func _process(_delta: float) -> void:
	if _transitioning:
		return
	_handle_p1_input()
	_handle_p2_input()
	_check_ready()


func _handle_p1_input() -> void:
	if p1_confirmed:
		if Input.is_action_just_pressed("p1_block"):
			p1_confirmed = false
			_update_display()
		return
	if Input.is_action_just_pressed("p1_left"):
		p1_index = wrapi(p1_index - 1, 0, CHARACTERS.size())
		_update_display()
	elif Input.is_action_just_pressed("p1_right"):
		p1_index = wrapi(p1_index + 1, 0, CHARACTERS.size())
		_update_display()
	if Input.is_action_just_pressed("p1_light_punch"):
		p1_confirmed = true
		_update_display()


func _handle_p2_input() -> void:
	if SceneManager.game_mode == "vs_cpu":
		# CPU auto-picks opponent character
		p2_index = 1 if p1_index == 0 else 0
		p2_confirmed = p1_confirmed
		_update_display()
		return
	if p2_confirmed:
		if Input.is_action_just_pressed("p2_block"):
			p2_confirmed = false
			_update_display()
		return
	if Input.is_action_just_pressed("p2_left"):
		p2_index = wrapi(p2_index - 1, 0, CHARACTERS.size())
		_update_display()
	elif Input.is_action_just_pressed("p2_right"):
		p2_index = wrapi(p2_index + 1, 0, CHARACTERS.size())
		_update_display()
	if Input.is_action_just_pressed("p2_light_punch"):
		p2_confirmed = true
		_update_display()


func _check_ready() -> void:
	if p1_confirmed and p2_confirmed and not _transitioning:
		_transitioning = true
		SceneManager.p1_character = CHARACTERS[p1_index].name
		SceneManager.p2_character = CHARACTERS[p2_index].name
		# Brief delay before transition
		get_tree().create_timer(0.5).timeout.connect(SceneManager.goto_fight)


func _update_display() -> void:
	var p1 := CHARACTERS[p1_index]
	var p2 := CHARACTERS[p2_index]
	p1_portrait.color = p1.color
	p1_name_label.text = p1.name
	p1_archetype_label.text = p1.archetype
	p1_status_label.text = "READY!" if p1_confirmed else "← A/D →  [U] Confirm"

	p2_portrait.color = p2.color
	p2_name_label.text = p2.name
	p2_archetype_label.text = p2.archetype
	if SceneManager.game_mode == "vs_cpu":
		p2_status_label.text = "CPU" if p2_confirmed else "CPU"
	else:
		p2_status_label.text = "READY!" if p2_confirmed else "← ←/→ →  [Num4] Confirm"


func _unhandled_input(event: InputEvent) -> void:
	# Global back — go to main menu
	if event.is_action_pressed("ui_cancel") and not _transitioning:
		if p1_confirmed:
			p1_confirmed = false
			_update_display()
		else:
			SceneManager.goto_main_menu()
		get_viewport().set_input_as_handled()
