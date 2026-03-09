extends Node2D
# Test suite for AudioManager — validates audio bus setup and playback API
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing AudioManager...")
print("=" * 60)

test_playback_methods_exist()
test_volume_control_roundtrip()
test_sfx_volume_set_and_get()

_print_results()


# --- Test Functions ---

func test_playback_methods_exist() -> void:
var required_methods: Array[String] = [
"play_light_hit", "play_heavy_hit", "play_block", "play_whiff",
"start_music", "stop_music",
]
var missing: Array[String] = []
for method_name in required_methods:
if not AudioManager.has_method(method_name):
missing.append(method_name)

if missing.is_empty():
_pass("all %d playback methods exist" % required_methods.size())
else:
_fail("missing methods: %s" % str(missing))


func test_volume_control_roundtrip() -> void:
var original: float = AudioManager.get_music_volume()

AudioManager.set_music_volume(-15.0)
var after_set: float = AudioManager.get_music_volume()

AudioManager.set_music_volume(original)

var diff: float = absf(after_set - (-15.0))
if diff < 0.5:
_pass("set_music_volume(-15) -> get_music_volume() = %.1f dB" % after_set)
else:
_fail("volume roundtrip failed: set -15 dB, got %.1f dB" % after_set)


func test_sfx_volume_set_and_get() -> void:
var original: float = AudioManager.get_sfx_volume()

AudioManager.set_sfx_volume(-5.0)
var after_set: float = AudioManager.get_sfx_volume()

AudioManager.set_sfx_volume(original)

var diff: float = absf(after_set - (-5.0))
if diff < 0.5:
_pass("set_sfx_volume(-5) -> get_sfx_volume() = %.1f dB" % after_set)
else:
_fail("SFX volume roundtrip failed: set -5 dB, got %.1f dB" % after_set)


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
print("✅ AudioManager: ALL %d tests passed!" % total)
else:
print("❌ AudioManager: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)