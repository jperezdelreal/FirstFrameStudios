extends Node2D
# Test suite for GameState — validates state transitions, ember system, match logic
# Author: Ackbar (QA/Playtester)

var _tests_passed: int = 0
var _tests_failed: int = 0

func _ready() -> void:
print("=" * 60)
print("Testing GameState...")
print("=" * 60)

test_reset_match()
test_advance_round_increments_score()
test_ember_add_and_clamp()
test_ember_spend_success_and_fail()
test_ignition_requires_full_ember()
test_match_over_detection()
test_match_winner_index()

_print_results()


# --- Test Functions ---

func test_reset_match() -> void:
GameState.reset_match()

if GameState.current_round != 1:
_fail("reset_match: current_round should be 1, got %d" % GameState.current_round)
return
if GameState.scores[0] != 0 or GameState.scores[1] != 0:
_fail("reset_match: scores should be [0,0], got %s" % str(GameState.scores))
return
if GameState.ember[0] != 0 or GameState.ember[1] != 0:
_fail("reset_match: ember should be [0,0], got %s" % str(GameState.ember))
return
_pass("reset_match resets round, scores, and ember")


func test_advance_round_increments_score() -> void:
GameState.reset_match()
GameState.advance_round(0)

if GameState.scores[0] != 1:
_fail("advance_round: P1 score should be 1, got %d" % GameState.scores[0])
return
if GameState.scores[1] != 0:
_fail("advance_round: P2 score should still be 0, got %d" % GameState.scores[1])
return
if GameState.current_round != 2:
_fail("advance_round: round should be 2, got %d" % GameState.current_round)
return
_pass("advance_round increments winner score and round number")


func test_ember_add_and_clamp() -> void:
GameState.reset_match()
GameState.add_ember(1, 60)

var ember_val: int = GameState.get_ember(1)
if ember_val != 60:
_fail("add_ember: P1 ember should be 60, got %d" % ember_val)
return

GameState.add_ember(1, 80)
ember_val = GameState.get_ember(1)
if ember_val != GameState.MAX_EMBER:
_fail("add_ember: P1 ember should clamp to %d, got %d" % [GameState.MAX_EMBER, ember_val])
return
_pass("add_ember accumulates and clamps at MAX_EMBER (%d)" % GameState.MAX_EMBER)


func test_ember_spend_success_and_fail() -> void:
GameState.reset_match()
GameState.add_ember(1, 50)

var spent: bool = GameState.spend_ember(1, 30, "special")
if not spent:
_fail("spend_ember: should succeed with 50 ember and 30 cost")
return

var remaining: int = GameState.get_ember(1)
if remaining != 20:
_fail("spend_ember: remaining should be 20, got %d" % remaining)
return

var overspend: bool = GameState.spend_ember(1, 50, "super")
if overspend:
_fail("spend_ember: should fail when cost exceeds available ember")
return

_pass("spend_ember succeeds/fails correctly and deducts")


func test_ignition_requires_full_ember() -> void:
GameState.reset_match()
GameState.add_ember(1, 50)

var activated: bool = GameState.activate_ignition(1)
if activated:
_fail("activate_ignition: should fail with only 50 ember")
return

GameState.add_ember(1, 50)
activated = GameState.activate_ignition(1)
if not activated:
_fail("activate_ignition: should succeed at MAX_EMBER")
return

var after: int = GameState.get_ember(1)
if after != 0:
_fail("activate_ignition: ember should be 0 after ignition, got %d" % after)
return

_pass("activate_ignition requires MAX_EMBER and drains to 0")


func test_match_over_detection() -> void:
GameState.reset_match()

if GameState.is_match_over():
_fail("is_match_over: should be false at start")
return

GameState.advance_round(0)
GameState.advance_round(0)

if not GameState.is_match_over():
_fail("is_match_over: should be true after P1 wins %d rounds" % GameState.ROUNDS_TO_WIN)
return

_pass("is_match_over detects when a player reaches ROUNDS_TO_WIN")


func test_match_winner_index() -> void:
GameState.reset_match()

var winner: int = GameState.get_match_winner_index()
if winner != -1:
_fail("get_match_winner_index: should be -1 before match over, got %d" % winner)
return

GameState.advance_round(1)
GameState.advance_round(1)

winner = GameState.get_match_winner_index()
if winner != 1:
_fail("get_match_winner_index: should be 1 after P2 wins, got %d" % winner)
return

_pass("get_match_winner_index returns correct winner or -1")


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
print("✅ GameState: ALL %d tests passed!" % total)
else:
print("❌ GameState: %d/%d tests passed (%d failed)" % [_tests_passed, total, _tests_failed])
print("=" * 60)