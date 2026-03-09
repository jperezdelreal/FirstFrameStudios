extends Node2D
# Test suite for VFXManager — validates VFX API, constants, and palette data
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing VFXManager...")
print("=" * 60)

test_constants_sane()
test_eventbus_signal_wiring()
test_character_palettes_present()

_print_results()


# --- Test Functions ---

func test_constants_sane() -> void:
if VFXManager.KO_SLOWMO_SCALE <= 0.0 or VFXManager.KO_SLOWMO_SCALE >= 1.0:
_fail("KO_SLOWMO_SCALE should be in (0,1), got %.2f" % VFXManager.KO_SLOWMO_SCALE)
return
if VFXManager.KO_SLOWMO_DURATION <= 0.0:
_fail("KO_SLOWMO_DURATION should be > 0, got %.2f" % VFXManager.KO_SLOWMO_DURATION)
return
if VFXManager.FLASH_FRAMES < 1:
_fail("FLASH_FRAMES should be >= 1, got %d" % VFXManager.FLASH_FRAMES)
return
if VFXManager.KO_FREEZE_FRAMES < 1:
_fail("KO_FREEZE_FRAMES should be >= 1, got %d" % VFXManager.KO_FREEZE_FRAMES)
return

_pass("VFX constants valid (slowmo=%.1f, freeze=%d frames)" % [
VFXManager.KO_SLOWMO_SCALE, VFXManager.KO_FREEZE_FRAMES
])


func test_eventbus_signal_wiring() -> void:
var wired_signals: Array[String] = [
"hit_landed", "hit_blocked", "hit_confirmed",
"fighter_ko", "ember_changed", "ember_spent", "round_started",
]
var unwired: Array[String] = []
for sig_name in wired_signals:
if not EventBus.has_signal(sig_name):
unwired.append(sig_name)

if unwired.is_empty():
_pass("all %d EventBus signals exist for VFX wiring" % wired_signals.size())
else:
_fail("EventBus missing signals for VFX: %s" % str(unwired))


func test_character_palettes_present() -> void:
var palettes: Dictionary = VFXManager.CHARACTER_PALETTES
var required_chars: Array[String] = ["Kael", "Rhena"]
var required_keys: Array[String] = [
"spark_start", "spark_end", "flash_color", "dmg_color",
]

for char_name in required_chars:
if not palettes.has(char_name):
_fail("CHARACTER_PALETTES missing '%s'" % char_name)
return
var pal: Dictionary = palettes[char_name]
for key in required_keys:
if not pal.has(key):
_fail("palette '%s' missing key '%s'" % [char_name, key])
return

_pass("CHARACTER_PALETTES has Kael & Rhena with required color keys")


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
print("✅ VFXManager: ALL %d tests passed!" % total)
else:
print("❌ VFXManager: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)