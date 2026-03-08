## Victory screen — displays winner, match stats, and rematch/menu options.
extends Control

@onready var winner_label: Label = %WinnerLabel
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var rematch_btn: Button = %RematchButton
@onready var menu_btn: Button = %MenuButton

const CLR_GOLD := Color(1.0, 0.85, 0.3)
const CLR_STAT := Color(0.85, 0.82, 0.75)
var _glow_time: float = 0.0


func _ready() -> void:
	_populate()
	_wire_buttons()
	rematch_btn.grab_focus()


func _process(delta: float) -> void:
	_glow_time += delta
	var pulse := (sin(_glow_time * 2.5) + 1.0) * 0.5
	winner_label.add_theme_color_override("font_color",
		CLR_GOLD.lerp(Color.WHITE, pulse * 0.3))


func _populate() -> void:
	var stats := SceneManager.match_stats
	var winner_name: String = stats.get("winner", "???")
	winner_label.text = winner_name.to_upper() + " WINS!"

	# Clear existing stat labels
	for child in stats_container.get_children():
		child.queue_free()

	# Build stat lines
	var p1_score: int = GameState.scores[0]
	var p2_score: int = GameState.scores[1]
	_add_stat("Rounds", "%s %d - %d %s" % [
		SceneManager.p1_character, p1_score, p2_score, SceneManager.p2_character])

	var total_damage: int = stats.get("total_damage", 0)
	if total_damage > 0:
		_add_stat("Total Damage", str(total_damage))

	var longest_combo: int = stats.get("longest_combo", 0)
	if longest_combo > 0:
		_add_stat("Longest Combo", "%d hits" % longest_combo)

	var ember_spent: int = stats.get("ember_spent", 0)
	if ember_spent > 0:
		_add_stat("Ember Spent", str(ember_spent))


func _add_stat(stat_name: String, value: String) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	var name_lbl := Label.new()
	name_lbl.text = stat_name + ":"
	name_lbl.add_theme_color_override("font_color", CLR_STAT.darkened(0.2))
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.custom_minimum_size = Vector2(220, 0)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(16, 0)

	var val_lbl := Label.new()
	val_lbl.text = value
	val_lbl.add_theme_color_override("font_color", CLR_STAT)
	val_lbl.add_theme_font_size_override("font_size", 20)
	val_lbl.custom_minimum_size = Vector2(220, 0)

	row.add_child(name_lbl)
	row.add_child(spacer)
	row.add_child(val_lbl)
	stats_container.add_child(row)


func _wire_buttons() -> void:
	rematch_btn.pressed.connect(_on_rematch)
	menu_btn.pressed.connect(_on_menu)
	rematch_btn.focus_neighbor_bottom = rematch_btn.get_path_to(menu_btn)
	menu_btn.focus_neighbor_top = menu_btn.get_path_to(rematch_btn)


func _on_rematch() -> void:
	SceneManager.rematch()


func _on_menu() -> void:
	SceneManager.goto_main_menu()
