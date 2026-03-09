## Fight HUD — health bars, round timer, round counter, ember meters, announcements.
## Wired to EventBus signals for fully decoupled updates.
extends CanvasLayer

# ── Health state ─────────────────────────────────────────
var p1_hp: float = 1000.0
var p1_max_hp: float = 1000.0
var p1_display_hp: float = 1000.0
var p1_ghost_hp: float = 1000.0
var p1_ghost_delay: float = 0.0

var p2_hp: float = 1000.0
var p2_max_hp: float = 1000.0
var p2_display_hp: float = 1000.0
var p2_ghost_hp: float = 1000.0
var p2_ghost_delay: float = 0.0

# ── Ember state ──────────────────────────────────────────
var p1_ember: float = 0.0
var p1_ember_display: float = 0.0
var p2_ember: float = 0.0
var p2_ember_display: float = 0.0

# ── Round state ──────────────────────────────────────────
var current_round: int = 1
var p1_rounds_won: int = 0
var p2_rounds_won: int = 0

# ── Announcement state ──────────────────────────────────
var announce_timer: float = 0.0

# ── Tuning ───────────────────────────────────────────────
const GHOST_DELAY: float = 0.5
const GHOST_SPEED: float = 400.0
const HP_LERP: float = 10.0
const EMBER_LERP: float = 8.0
const ANNOUNCE_DURATION: float = 1.5
const ANNOUNCE_SCALE_IN: float = 0.15
const ANNOUNCE_FADE_OUT: float = 0.3
const ROUNDS_TO_WIN: int = 2

# ── Colour palette ───────────────────────────────────────
const CLR_HP_HIGH := Color(0.298, 0.686, 0.314)
const CLR_HP_MID := Color(0.976, 0.847, 0.208)
const CLR_HP_LOW := Color(0.937, 0.325, 0.314)
const CLR_EMBER := Color(1.0, 0.596, 0.0)
const CLR_EMBER_HOT := Color(1.0, 0.82, 0.28)
const CLR_P1 := Color(0.31, 0.765, 0.969)
const CLR_P2 := Color(0.937, 0.325, 0.314)
const CLR_TIMER := Color(1.0, 0.96, 0.76)
const CLR_TIMER_WARN := Color(1.0, 0.2, 0.2)
const CLR_DOT_OFF := Color(0.35, 0.35, 0.42)

# ── Node references (unique names from scene) ───────────
@onready var p1_bar: ProgressBar = %P1HealthBar
@onready var p1_ghost: ProgressBar = %P1GhostBar
@onready var p2_bar: ProgressBar = %P2HealthBar
@onready var p2_ghost: ProgressBar = %P2GhostBar
@onready var p1_ember_bar: ProgressBar = %P1EmberBar
@onready var p2_ember_bar: ProgressBar = %P2EmberBar
@onready var timer_label: Label = %TimerLabel
@onready var round_dots: HBoxContainer = %RoundDots
@onready var announcer: Label = %AnnouncerLabel


func _ready() -> void:
	_wire_signals()
	_rebuild_dots()
	announcer.text = ""
	announcer.modulate.a = 0.0


func _wire_signals() -> void:
	EventBus.fighter_damaged.connect(_on_fighter_damaged)
	EventBus.fighter_ko.connect(_on_fighter_ko)
	EventBus.round_started.connect(_on_round_started)
	EventBus.round_ended.connect(_on_round_ended)
	EventBus.match_ended.connect(_on_match_ended)
	EventBus.timer_updated.connect(_on_timer_updated)
	EventBus.announce.connect(_on_announce)
	EventBus.ember_changed.connect(_on_ember_changed)
	EventBus.combo_updated.connect(_on_combo_updated)
	EventBus.combo_ended.connect(_on_combo_ended)


func _process(delta: float) -> void:
	_tick_health(delta)
	_tick_ember(delta)
	_tick_announcer(delta)


# ── Health bars ──────────────────────────────────────────

func _tick_health(delta: float) -> void:
	# P1 — smooth drain + ghost trail
	p1_display_hp = lerpf(p1_display_hp, p1_hp, HP_LERP * delta)
	p1_bar.value = (p1_display_hp / maxf(p1_max_hp, 1.0)) * 100.0
	_color_hp(p1_bar, p1_display_hp / maxf(p1_max_hp, 1.0))

	if p1_ghost_delay > 0.0:
		p1_ghost_delay -= delta
	else:
		p1_ghost_hp = move_toward(p1_ghost_hp, p1_display_hp, GHOST_SPEED * delta)
	p1_ghost.value = (p1_ghost_hp / maxf(p1_max_hp, 1.0)) * 100.0

	# P2 — mirror
	p2_display_hp = lerpf(p2_display_hp, p2_hp, HP_LERP * delta)
	p2_bar.value = (p2_display_hp / maxf(p2_max_hp, 1.0)) * 100.0
	_color_hp(p2_bar, p2_display_hp / maxf(p2_max_hp, 1.0))

	if p2_ghost_delay > 0.0:
		p2_ghost_delay -= delta
	else:
		p2_ghost_hp = move_toward(p2_ghost_hp, p2_display_hp, GHOST_SPEED * delta)
	p2_ghost.value = (p2_ghost_hp / maxf(p2_max_hp, 1.0)) * 100.0


func _color_hp(bar: ProgressBar, ratio: float) -> void:
	var style := _ensure_own_fill(bar)
	if not style:
		return
	if ratio > 0.5:
		style.bg_color = CLR_HP_HIGH
	elif ratio > 0.25:
		style.bg_color = CLR_HP_MID.lerp(CLR_HP_HIGH, (ratio - 0.25) / 0.25)
	else:
		style.bg_color = CLR_HP_LOW.lerp(CLR_HP_MID, ratio / 0.25)


# ── Ember bars ───────────────────────────────────────────

func _tick_ember(delta: float) -> void:
	p1_ember_display = lerpf(p1_ember_display, p1_ember, EMBER_LERP * delta)
	p1_ember_bar.value = p1_ember_display
	_color_ember(p1_ember_bar, p1_ember_display)

	p2_ember_display = lerpf(p2_ember_display, p2_ember, EMBER_LERP * delta)
	p2_ember_bar.value = p2_ember_display
	_color_ember(p2_ember_bar, p2_ember_display)


func _color_ember(bar: ProgressBar, value: float) -> void:
	var style := _ensure_own_fill(bar)
	if not style:
		return
	if value >= 75.0:
		var pulse := (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.5
		style.bg_color = CLR_EMBER.lerp(CLR_EMBER_HOT, pulse)
	elif value >= 50.0:
		style.bg_color = CLR_EMBER
	else:
		style.bg_color = CLR_EMBER.darkened(0.15)


# ── Announcer ────────────────────────────────────────────

func _tick_announcer(delta: float) -> void:
	if announce_timer <= 0.0:
		announcer.modulate.a = 0.0
		return

	announce_timer -= delta
	var elapsed := ANNOUNCE_DURATION - announce_timer

	if elapsed < ANNOUNCE_SCALE_IN:
		# Phase 1: punch-in scale
		var t := elapsed / ANNOUNCE_SCALE_IN
		var s := lerpf(2.5, 1.0, ease(t, -2.0))
		announcer.pivot_offset = announcer.size * 0.5
		announcer.scale = Vector2(s, s)
		announcer.modulate.a = t
	elif announce_timer > ANNOUNCE_FADE_OUT:
		# Phase 2: hold
		announcer.scale = Vector2.ONE
		announcer.modulate.a = 1.0
	else:
		# Phase 3: fade out
		announcer.scale = Vector2.ONE
		announcer.modulate.a = announce_timer / ANNOUNCE_FADE_OUT


# ── Signal handlers ──────────────────────────────────────

func _on_fighter_damaged(fighter: Variant, _amount: int, remaining_hp: int) -> void:
	var pid := 1
	if fighter and "player_id" in fighter:
		pid = fighter.player_id
	if pid == 1:
		p1_hp = float(remaining_hp)
		p1_ghost_delay = GHOST_DELAY
	else:
		p2_hp = float(remaining_hp)
		p2_ghost_delay = GHOST_DELAY


func _on_fighter_ko(_fighter: Variant) -> void:
	_on_announce("K.O.!")


func _on_round_started(round_number: int) -> void:
	current_round = round_number
	p1_hp = p1_max_hp
	p2_hp = p2_max_hp
	p1_display_hp = p1_max_hp
	p2_display_hp = p2_max_hp
	p1_ghost_hp = p1_max_hp
	p2_ghost_hp = p2_max_hp
	p1_ember = 0.0
	p2_ember = 0.0
	p1_ember_display = 0.0
	p2_ember_display = 0.0
	p1_bar.value = 100.0
	p2_bar.value = 100.0
	p1_ghost.value = 100.0
	p2_ghost.value = 100.0
	p1_ember_bar.value = 0.0
	p2_ember_bar.value = 0.0
	_rebuild_dots()


func _on_round_ended(_winner: Variant, _round_number: int) -> void:
	p1_rounds_won = GameState.scores[0]
	p2_rounds_won = GameState.scores[1]
	_rebuild_dots()


func _on_match_ended(_winner: Variant, _scores: Array) -> void:
	pass


func _on_timer_updated(seconds_remaining: int) -> void:
	timer_label.text = str(seconds_remaining)
	if seconds_remaining <= 10:
		var pulse := (sin(Time.get_ticks_msec() * 0.01) + 1.0) * 0.5
		timer_label.add_theme_color_override("font_color",
			CLR_TIMER.lerp(CLR_TIMER_WARN, pulse))
	else:
		timer_label.add_theme_color_override("font_color", CLR_TIMER)


func _on_announce(text: String) -> void:
	announcer.text = text
	announce_timer = ANNOUNCE_DURATION
	announcer.scale = Vector2(2.5, 2.5)
	announcer.modulate.a = 0.0


func _on_ember_changed(player_id: int, new_value: int) -> void:
	if player_id == 1:
		p1_ember = float(new_value)
	else:
		p2_ember = float(new_value)


func _on_combo_updated(_fighter: Variant, combo_count: int) -> void:
	if combo_count >= 2:
		_on_announce("%d HIT" % combo_count)


func _on_combo_ended(_fighter: Variant, total_hits: int, _total_damage: int) -> void:
	if total_hits >= 3:
		_on_announce("%d HIT COMBO!" % total_hits)


# ── Round dots ───────────────────────────────────────────

func _rebuild_dots() -> void:
	for child in round_dots.get_children():
		child.queue_free()

	# P1 dots
	for i in ROUNDS_TO_WIN:
		var dot := _make_dot(i < p1_rounds_won, CLR_P1)
		round_dots.add_child(dot)

	# Spacer
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(24, 0)
	round_dots.add_child(sep)

	# P2 dots
	for i in ROUNDS_TO_WIN:
		var dot := _make_dot(i < p2_rounds_won, CLR_P2)
		round_dots.add_child(dot)


func _make_dot(filled: bool, color: Color) -> Label:
	var dot := Label.new()
	dot.text = "●" if filled else "○"
	dot.add_theme_color_override("font_color", color if filled else CLR_DOT_OFF)
	dot.add_theme_font_size_override("font_size", 20)
	dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dot.custom_minimum_size = Vector2(22, 0)
	return dot


# ── Helpers ──────────────────────────────────────────────

func _ensure_own_fill(bar: ProgressBar) -> StyleBoxFlat:
	## Duplicate the shared sub-resource so per-bar colour mutation is safe.
	if bar.has_meta("_own_fill"):
		return bar.get_theme_stylebox("fill") as StyleBoxFlat
	var src := bar.get_theme_stylebox("fill")
	if not src:
		return null
	var dup := src.duplicate()
	bar.add_theme_stylebox_override("fill", dup)
	bar.set_meta("_own_fill", true)
	return dup as StyleBoxFlat
