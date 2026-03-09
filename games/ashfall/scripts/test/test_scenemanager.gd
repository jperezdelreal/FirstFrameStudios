extends Node2D
# Test suite for SceneManager — validates scene flow state and transition API
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing SceneManager...")
print("=" * 60)

test_scene_constants_defined()
test_default_properties()
test_navigation_methods_exist()

_print_results()


# --- Test Functions ---

func test_scene_constants_defined() -> void:
var paths: Array[String] = [
SceneManager.SCENE_MAIN_MENU,
SceneManager.SCENE_CHARACTER_SELECT,
SceneManager.SCENE_FIGHT,
SceneManager.SCENE_VICTORY,
]
for path in paths:
if path.is_empty() or not path.begins_with("res://"):
_fail("scene constant has invalid path: '%s'" % path)
return

_pass("all 4 scene constants are valid res:// paths")


func test_default_properties() -> void:
var valid_modes: Array[String] = ["vs_cpu", "vs_player"]
if SceneManager.game_mode not in valid_modes:
_fail("game_mode '%s' not in %s" % [SceneManager.game_mode, str(valid_modes)])
return

if SceneManager.p1_character.is_empty():
_fail("p1_character should not be empty")
return
if SceneManager.p2_character.is_empty():
_fail("p2_character should not be empty")
return

_pass("default properties valid (mode=%s, p1=%s, p2=%s)" % [
SceneManager.game_mode, SceneManager.p1_character, SceneManager.p2_character
])


func test_navigation_methods_exist() -> void:
var required: Array[String] = [
"goto_scene", "goto_main_menu", "goto_character_select",
"goto_fight", "goto_victory", "rematch",
]
var missing: Array[String] = []
for method_name in required:
if not SceneManager.has_method(method_name):
missing.append(method_name)

if missing.is_empty():
_pass("all %d navigation methods exist" % required.size())
else:
_fail("missing methods: %s" % str(missing))


# --- Helpers ---

func _pass(name: String) -> void:
_tests_passed += 1
print("  ✅ PASS: ", name)

func _fail(name: String) -> void:
_tests_failed += 1
print("  ❌ FAIL: ", name)

func _print_results() -> void:
print("")
var total: int = _tests_passed + _tests_failed
if _tests_failed == 0:
print("✅ SceneManager: ALL %d tests passed!" % total)
else:
print("❌ SceneManager: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)