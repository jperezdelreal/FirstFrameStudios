extends Node2D
# Test suite for RoundManager — validates round lifecycle and state machine
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing RoundManager...")
print("=" * 60)

test_initial_state()
test_configurable_exports()
test_round_signal_emission()
test_scores_array_initialized()

_print_results()


# --- Test Functions ---

func test_initial_state() -> void:
if RoundManager.current_round < 1:
_fail("initial_state: current_round should be >= 1, got %d" % RoundManager.current_round)
return

var valid_states: Array[String] = [
"INACTIVE", "INTRO", "READY", "FIGHT", "KO", "ROUND_RESET", "MATCH_END"
]
if RoundManager.round_state not in valid_states:
_fail("initial_state: round_state '%s' not in valid states" % RoundManager.round_state)
return

_pass("initial_state: current_round=%d, round_state='%s'" % [RoundManager.current_round, RoundManager.round_state])


func test_configurable_exports() -> void:
if RoundManager.rounds_to_win < 1 or RoundManager.rounds_to_win > 5:
_fail("rounds_to_win out of sane range: %d" % RoundManager.rounds_to_win)
return
if RoundManager.round_time_seconds < 1 or RoundManager.round_time_seconds > 300:
_fail("round_time_seconds out of sane range: %d" % RoundManager.round_time_seconds)
return
if RoundManager.intro_frames < 1:
_fail("intro_frames should be >= 1, got %d" % RoundManager.intro_frames)
return
if RoundManager.ko_frames < 1:
_fail("ko_frames should be >= 1, got %d" % RoundManager.ko_frames)
return

_pass("configurable exports within sane ranges (rounds_to_win=%d, time=%ds)" % [
RoundManager.rounds_to_win, RoundManager.round_time_seconds
])


func test_round_signal_emission() -> void:
var received: Array[int] = []
var callback: Callable = func(round_number: int) -> void:
received.append(round_number)

RoundManager.round_started.connect(callback)
RoundManager.round_started.emit(1)
RoundManager.round_started.disconnect(callback)

if received.size() == 1 and received[0] == 1:
_pass("round_started signal emits and delivers round number")
else:
_fail("round_started signal — expected [1], got %s" % str(received))


func test_scores_array_initialized() -> void:
if RoundManager.scores.size() != 2:
_fail("scores array should have 2 elements, got %d" % RoundManager.scores.size())
return
if typeof(RoundManager.scores[0]) != TYPE_INT or typeof(RoundManager.scores[1]) != TYPE_INT:
_fail("scores elements should be int, got types %d, %d" % [
typeof(RoundManager.scores[0]), typeof(RoundManager.scores[1])
])
return

_pass("scores array initialized with 2 int elements: %s" % str(RoundManager.scores))


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
print("✅ RoundManager: ALL %d tests passed!" % total)
else:
print("❌ RoundManager: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)