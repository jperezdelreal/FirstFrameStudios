extends Node2D
# Test suite for InputBuffer — validates input queuing, SOCD, and motion detection
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing InputBuffer...")
print("=" * 60)

test_buffer_configuration()
test_inject_and_check_button()
test_inject_direction_facing()
test_consume_prevents_double_read()

_print_results()


# --- Test Functions ---

func test_buffer_configuration() -> void:
if InputBuffer.buffer_size < 1:
_fail("buffer_size should be >= 1, got %d" % InputBuffer.buffer_size)
return
if InputBuffer.input_leniency < 1:
_fail("input_leniency should be >= 1, got %d" % InputBuffer.input_leniency)
return
if InputBuffer.simultaneous_window < 1:
_fail("simultaneous_window should be >= 1, got %d" % InputBuffer.simultaneous_window)
return
if InputBuffer.input_leniency > InputBuffer.buffer_size:
_fail("input_leniency (%d) should not exceed buffer_size (%d)" % [
InputBuffer.input_leniency, InputBuffer.buffer_size
])
return

_pass("buffer config valid (size=%d, leniency=%d, sim_window=%d)" % [
InputBuffer.buffer_size, InputBuffer.input_leniency, InputBuffer.simultaneous_window
])


func test_inject_and_check_button() -> void:
InputBuffer.player_id = 1
InputBuffer.facing_right = true
InputBuffer.update()

InputBuffer.inject_button("lp")
InputBuffer.update()

var detected: bool = InputBuffer.check_button("lp")
if not detected:
_fail("inject_button('lp') not detected by check_button")
return

_pass("inject_button + check_button detects injected input")


func test_inject_direction_facing() -> void:
InputBuffer.player_id = 1
InputBuffer.facing_right = true
InputBuffer.update()

InputBuffer.inject_direction("right")
InputBuffer.update()

var holding_fwd: bool = InputBuffer.is_holding_forward()
if not holding_fwd:
_fail("inject_direction('right') while facing_right should be forward")
return

_pass("inject_direction respects facing for forward detection")


func test_consume_prevents_double_read() -> void:
InputBuffer.player_id = 1
InputBuffer.facing_right = true
InputBuffer.update()

InputBuffer.inject_button("hp")
InputBuffer.update()

var first: bool = InputBuffer.check_button("hp")
InputBuffer.consume_button("hp")
var second: bool = InputBuffer.check_button("hp")

if not first:
_fail("hp should be detected before consume")
return
if second:
_fail("hp should NOT be detected after consume_button")
return

_pass("consume_button prevents double execution")


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
print("✅ InputBuffer: ALL %d tests passed!" % total)
else:
print("❌ InputBuffer: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)