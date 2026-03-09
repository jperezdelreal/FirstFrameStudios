## Round manager — drives the match lifecycle: intros, countdowns,
## fight phase, KO detection, round resets, and match-over.
## Best of 3 rounds, 99-second timer per round.
##
## State flow: INTRO → READY → FIGHT → KO → ROUND_RESET → INTRO (or MATCH_END)
## All timing is frame-based (deterministic at 60 FPS).
extends Node


func _ready() -> void:
	assert(EventBus != null, "RoundManager requires EventBus to load first")
	assert(GameState != null, "RoundManager requires GameState to load first")


# --- Signals (wired to UI and other systems via fight_scene.gd) ---
signal round_started(round_number: int)
signal round_ended(winner: CharacterBody2D, round_number: int)
signal round_draw(round_number: int)
signal match_ended(winner: CharacterBody2D, scores: Array[int])
signal match_draw(scores: Array[int])
signal timer_updated(seconds_remaining: int)
signal announce(text: String)

# --- Configuration ---
@export var rounds_to_win: int = 2
@export var round_time_seconds: int = 99
@export var intro_frames: int = 60
@export var ready_frames: int = 90
@export var ko_frames: int = 120
@export var reset_frames: int = 90

# --- Runtime state ---
var current_round: int = 1
var scores: Array[int] = [0, 0]
var timer_frames: int = 0
var round_state: String = "INACTIVE"
var state_frames: int = 0
var fighters: Array = []
var _last_displayed_seconds: int = -1

var p1_spawn: Vector2 = Vector2(-200, 0)
var p2_spawn: Vector2 = Vector2(200, 0)


func start_match(fighter1: CharacterBody2D, fighter2: CharacterBody2D) -> void:
	fighters = [fighter1, fighter2]
	scores = [0, 0]
	current_round = 1

	# Wire KO signals
	if not fighter1.knocked_out.is_connected(_on_fighter_ko):
		fighter1.knocked_out.connect(_on_fighter_ko)
	if not fighter2.knocked_out.is_connected(_on_fighter_ko):
		fighter2.knocked_out.connect(_on_fighter_ko)

	_start_round()


func _physics_process(_delta: float) -> void:
	if round_state == "INACTIVE":
		return

	state_frames += 1

	match round_state:
		"INTRO":
			if state_frames >= intro_frames:
				_transition_to("READY")
				announce.emit("ROUND %d" % current_round)
				EventBus.announce.emit("ROUND %d" % current_round)

		"READY":
			if state_frames >= ready_frames:
				_transition_to("FIGHT")
				announce.emit("FIGHT!")
				EventBus.announce.emit("FIGHT!")

		"FIGHT":
			timer_frames -= 1
			var seconds := ceili(timer_frames / 60.0)
			if seconds != _last_displayed_seconds:
				_last_displayed_seconds = seconds
				timer_updated.emit(seconds)
				EventBus.timer_updated.emit(seconds)
			if timer_frames <= 0:
				_time_over()

		"KO":
			if state_frames >= ko_frames:
				_check_match_over()

		"ROUND_RESET":
			if state_frames >= reset_frames:
				current_round += 1
				_start_round()

		"MATCH_END":
			pass


# --- External events ---

func _on_fighter_ko(fighter: CharacterBody2D) -> void:
	if round_state != "FIGHT":
		return
	var winner_index: int = 1 if fighter == fighters[0] else 0
	scores[winner_index] += 1
	GameState.scores[winner_index] = scores[winner_index]
	_transition_to("KO")
	announce.emit("K.O.!")
	EventBus.announce.emit("K.O.!")
	round_ended.emit(fighters[winner_index], current_round)
	EventBus.round_ended.emit(fighters[winner_index], current_round)


# --- Internal helpers ---

func _time_over() -> void:
	var f0_hp: int = fighters[0].health if fighters[0] else 0
	var f1_hp: int = fighters[1].health if fighters[1] else 0
	_transition_to("KO")
	announce.emit("TIME!")
	EventBus.announce.emit("TIME!")

	if f0_hp == f1_hp:
		# GDD: equal HP = draw, both lose the round (forces aggression)
		scores[0] += 1
		scores[1] += 1
		GameState.scores = scores.duplicate()
		round_draw.emit(current_round)
		EventBus.round_draw.emit(current_round)
	else:
		var winner_index: int = 0 if f0_hp > f1_hp else 1
		scores[winner_index] += 1
		GameState.scores[winner_index] = scores[winner_index]
		round_ended.emit(fighters[winner_index], current_round)
		EventBus.round_ended.emit(fighters[winner_index], current_round)


func _check_match_over() -> void:
	var p1_won := scores[0] >= rounds_to_win
	var p2_won := scores[1] >= rounds_to_win
	if p1_won and p2_won:
		# Double draw-out: both reached rounds_to_win simultaneously
		_transition_to("MATCH_END")
		announce.emit("DRAW GAME!")
		EventBus.announce.emit("DRAW GAME!")
		match_draw.emit(scores)
		EventBus.match_draw.emit(scores)
		return
	for i in 2:
		if scores[i] >= rounds_to_win:
			_transition_to("MATCH_END")
			match_ended.emit(fighters[i], scores)
			EventBus.match_ended.emit(fighters[i], scores)
			return
	_transition_to("ROUND_RESET")


func _start_round() -> void:
	timer_frames = round_time_seconds * 60
	_last_displayed_seconds = round_time_seconds
	if fighters.size() >= 2:
		fighters[0].reset_for_round(p1_spawn)
		fighters[1].reset_for_round(p2_spawn)
	_transition_to("INTRO")
	round_started.emit(current_round)
	EventBus.round_started.emit(current_round)


func _transition_to(new_state: String) -> void:
	round_state = new_state
	state_frames = 0
