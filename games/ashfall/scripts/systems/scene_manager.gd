## Autoload scene manager — handles scene flow and fade transitions.
## Flow: Main Menu → Character Select → Fight → Victory → (Rematch / Menu)
extends CanvasLayer

# Fade overlay drawn on top of everything
var _fade_rect: ColorRect
var _tween: Tween

const FADE_DURATION: float = 0.4

# Match context carried across scene changes
var game_mode: String = "vs_cpu"  # "vs_cpu" or "vs_player"
var p1_character: String = "Kael"
var p2_character: String = "Rhena"
var match_stats: Dictionary = {}

# Scene paths
const SCENE_MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const SCENE_CHARACTER_SELECT := "res://scenes/ui/character_select.tscn"
const SCENE_FIGHT := "res://scenes/main/fight_scene.tscn"
const SCENE_VICTORY := "res://scenes/ui/victory_screen.tscn"


func _ready() -> void:
	layer = 100
	_create_fade_overlay()
	EventBus.scene_change_requested.connect(_on_scene_change_requested)


func _create_fade_overlay() -> void:
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.modulate.a = 0.0
	add_child(_fade_rect)


func goto_scene(path: String) -> void:
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_fade_rect, "modulate:a", 1.0, FADE_DURATION)
	_tween.tween_callback(_swap_scene.bind(path))
	_tween.tween_property(_fade_rect, "modulate:a", 0.0, FADE_DURATION)
	_tween.tween_callback(func(): _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE)


func _swap_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)


func goto_main_menu() -> void:
	GameState.current_phase = GameState.GamePhase.TITLE
	goto_scene(SCENE_MAIN_MENU)


func goto_character_select(mode: String) -> void:
	game_mode = mode
	GameState.current_phase = GameState.GamePhase.CHARACTER_SELECT
	goto_scene(SCENE_CHARACTER_SELECT)


func goto_fight() -> void:
	GameState.reset_match()
	goto_scene(SCENE_FIGHT)


func goto_victory(winner_name: String, stats: Dictionary) -> void:
	match_stats = stats
	match_stats["winner"] = winner_name
	GameState.current_phase = GameState.GamePhase.MATCH_END
	goto_scene(SCENE_VICTORY)


func rematch() -> void:
	goto_fight()


func _on_scene_change_requested(scene_path: String) -> void:
	goto_scene(scene_path)
