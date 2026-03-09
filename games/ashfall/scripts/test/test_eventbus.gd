extends Node2D
# Test suite for EventBus — validates signal connectivity and emission
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing EventBus...")
print("=" * 60)

test_signal_exists()
test_signal_emission_round_started()
test_signal_emission_fighter_damaged()
test_signal_emission_ember_changed()
test_multiple_listeners()

_print_results()


# --- Test Functions ---

func test_signal_exists() -> void:
var required_signals: Array[String] = [
"hit_landed", "hit_blocked", "hit_confirmed",
"combo_updated", "combo_ended",
"fighter_damaged", "fighter_ko",
"round_started", "round_ended", "round_draw",
"match_ended", "match_draw",
"timer_updated", "announce",
"ember_changed", "ember_spent", "ignition_activated",
"game_paused", "game_resumed", "scene_change_requested",
]
for sig_name in required_signals:
if EventBus.has_signal(sig_name):
_pass("signal_exists: " + sig_name)
else:
_fail("signal_exists: " + sig_name + " — MISSING from EventBus")


func test_signal_emission_round_started() -> void:
var received_round: Array[int] = []
var callback: Callable = func(round_number: int) -> void:
received_round.append(round_number)

EventBus.round_started.connect(callback)
EventBus.round_started.emit(3)
EventBus.round_started.disconnect(callback)

if received_round.size() == 1 and received_round[0] == 3:
_pass("round_started emits correct round number")
else:
_fail("round_started emission — expected [3], got " + str(received_round))


func test_signal_emission_fighter_damaged() -> void:
var received_data: Array = []
var callback: Callable = func(fighter: Variant, amount: int, remaining_hp: int) -> void:
received_data.append({"amount": amount, "remaining_hp": remaining_hp})

EventBus.fighter_damaged.connect(callback)
EventBus.fighter_damaged.emit(null, 25, 75)
EventBus.fighter_damaged.disconnect(callback)

if received_data.size() == 1:
var entry: Dictionary = received_data[0]
var amount: int = entry["amount"]
var hp: int = entry["remaining_hp"]
if amount == 25 and hp == 75:
_pass("fighter_damaged emits correct amount and remaining_hp")
else:
_fail("fighter_damaged data mismatch — got amount=%d hp=%d" % [amount, hp])
else:
_fail("fighter_damaged not received (got %d callbacks)" % received_data.size())


func test_signal_emission_ember_changed() -> void:
var received: Array = []
var callback: Callable = func(player_id: int, new_value: int) -> void:
received.append({"player_id": player_id, "new_value": new_value})

EventBus.ember_changed.connect(callback)
EventBus.ember_changed.emit(1, 50)
EventBus.ember_changed.disconnect(callback)

if received.size() == 1:
var entry: Dictionary = received[0]
var pid: int = entry["player_id"]
var val: int = entry["new_value"]
if pid == 1 and val == 50:
_pass("ember_changed emits correct player_id and value")
else:
_fail("ember_changed data mismatch — got pid=%d val=%d" % [pid, val])
else:
_fail("ember_changed not received")


func test_multiple_listeners() -> void:
var counter_a: Array[int] = [0]
var counter_b: Array[int] = [0]
var cb_a: Callable = func(_rn: int) -> void:
counter_a[0] += 1
var cb_b: Callable = func(_rn: int) -> void:
counter_b[0] += 1

EventBus.round_started.connect(cb_a)
EventBus.round_started.connect(cb_b)
EventBus.round_started.emit(1)
EventBus.round_started.disconnect(cb_a)
EventBus.round_started.disconnect(cb_b)

if counter_a[0] == 1 and counter_b[0] == 1:
_pass("multiple listeners both receive round_started")
else:
_fail("multiple listeners — a=%d b=%d (expected 1,1)" % [counter_a[0], counter_b[0]])


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
print("✅ EventBus: ALL %d tests passed!" % total)
else:
print("❌ EventBus: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)