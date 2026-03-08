## Main menu — title screen with ember glow, mode selection, and options.
extends Control

@onready var title_label: Label = %TitleLabel
@onready var vs_cpu_btn: Button = %VsCpuButton
@onready var vs_player_btn: Button = %VsPlayerButton
@onready var options_btn: Button = %OptionsButton
@onready var quit_btn: Button = %QuitButton
@onready var options_panel: PanelContainer = %OptionsPanel
@onready var master_slider: HSlider = %MasterSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var options_back_btn: Button = %OptionsBackButton

var _ember_time: float = 0.0
var _options_open: bool = false

const CLR_EMBER := Color(1.0, 0.45, 0.08)
const CLR_EMBER_GLOW := Color(1.0, 0.7, 0.2)
const CLR_TITLE := Color(1.0, 0.92, 0.7)


func _ready() -> void:
	options_panel.visible = false
	_wire_buttons()
	_apply_title_glow()
	# Focus first button
	vs_cpu_btn.grab_focus()


func _process(delta: float) -> void:
	_ember_time += delta
	_apply_title_glow()


func _apply_title_glow() -> void:
	var pulse := (sin(_ember_time * 3.0) + 1.0) * 0.5
	var glow_color := CLR_TITLE.lerp(CLR_EMBER_GLOW, pulse * 0.4)
	title_label.add_theme_color_override("font_color", glow_color)
	title_label.add_theme_color_override("font_outline_color",
		CLR_EMBER.lerp(CLR_EMBER_GLOW, pulse))


func _wire_buttons() -> void:
	vs_cpu_btn.pressed.connect(_on_vs_cpu)
	vs_player_btn.pressed.connect(_on_vs_player)
	options_btn.pressed.connect(_on_options)
	quit_btn.pressed.connect(_on_quit)
	options_back_btn.pressed.connect(_on_options_back)
	# Focus neighbours for keyboard nav
	vs_cpu_btn.focus_neighbor_bottom = vs_cpu_btn.get_path_to(vs_player_btn)
	vs_player_btn.focus_neighbor_top = vs_player_btn.get_path_to(vs_cpu_btn)
	vs_player_btn.focus_neighbor_bottom = vs_player_btn.get_path_to(options_btn)
	options_btn.focus_neighbor_top = options_btn.get_path_to(vs_player_btn)
	options_btn.focus_neighbor_bottom = options_btn.get_path_to(quit_btn)
	quit_btn.focus_neighbor_top = quit_btn.get_path_to(options_btn)


func _on_vs_cpu() -> void:
	SceneManager.goto_character_select("vs_cpu")


func _on_vs_player() -> void:
	SceneManager.goto_character_select("vs_player")


func _on_options() -> void:
	_options_open = true
	options_panel.visible = true
	options_back_btn.grab_focus()


func _on_options_back() -> void:
	_options_open = false
	options_panel.visible = false
	vs_cpu_btn.grab_focus()


func _on_quit() -> void:
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _options_open:
			_on_options_back()
			get_viewport().set_input_as_handled()
