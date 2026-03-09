## Fight HUD — polished health bars with ghost damage, round indicators,
## timer with urgency, combo counter, enhanced announcer with FINAL ROUND,
## and Ember meter with EX/Ignition threshold markers.
## Wired to EventBus signals for fully decoupled updates.
extends CanvasLayer

# ── Constants ────────────────────────────────────────────
const GHOST_DELAY_FRAMES: int = 30       # 0.5s at 60 FPS
const GHOST_SPEED: float = 400.0
const HP_LERP: float = 10.0
const EMBER_LERP: float = 8.0
const ROUNDS_TO_WIN: int = 2

const ANNOUNCE_DURATION_FRAMES: int = 90  # 1.5s total
const ANNOUNCE_SCALE_IN_FRAMES: int = 9   # 0.15s punch-in
const ANNOUNCE_FADE_OUT_FRAMES: int = 18  # 0.3s fade

const COMBO_FADE_FRAMES: int = 60         # 1s fade after combo ends
const COMBO_MIN_DISPLAY: int = 2          # min hits before showing counter

const TIMER_WARN_SECONDS: int = 10

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
const CLR_COMBO := Color(1.0, 0.95, 0.4)
const CLR_COMBO_DMG := Color(1.0, 0.7, 0.3, 0.85)
const CLR_FINAL := Color(1.0, 0.3, 0.15)
const CLR_FIGHT := Color(1.0, 0.95, 0.4)
const CLR_THRESH := Color(1.0, 1.0, 1.0, 0.4)

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
@onready var p1_combo_hits: Label = %P1ComboHits
@onready var p1_combo_dmg: Label = %P1ComboDmg
@onready var p2_combo_hits: Label = %P2ComboHits
@onready var p2_combo_dmg: Label = %P2ComboDmg
@onready var final_round_label: Label = %FinalRoundLabel

# ── Health state ─────────────────────────────────────────
var p1_hp: float = 1000.0
var p1_max_hp: float = 1000.0
var p1_display_hp: float = 1000.0
var p1_ghost_hp: float = 1000.0
var p1_ghost_delay: int = 0

var p2_hp: float = 1000.0
var p2_max_hp: float = 1000.0
var p2_display_hp: float = 1000.0
var p2_ghost_hp: float = 1000.0
var p2_ghost_delay: int = 0

# ── Ember state ──────────────────────────────────────────
var p1_ember: float = 0.0
var p1_ember_display: float = 0.0
var p2_ember: float = 0.0
var p2_ember_display: float = 0.0

# ── Round state ──────────────────────────────────────────
var current_round: int = 1
var p1_rounds_won: int = 0
var p2_rounds_won: int = 0

# ── Combo state ──────────────────────────────────────────
var _combo_active: bool = false
var _combo_player_id: int = 0
var _combo_count: int = 0
var _combo_damage: int = 0
var _combo_fade_frames: int = 0
var _last_hit_damage: int = 0

# ── Announcement state ──────────────────────────────────
var _announce_elapsed: int = 0
var _announcing: bool = false

# ── Timer urgency ────────────────────────────────────────
var _timer_is_warn: bool = false
var _timer_warn_frame: int = 0


func _ready() -> void:
	_wire_signals()
	_rebuild_dots()
	_hide_announcer()
	_hide_combo()
	final_round_label.visible = false
	call_deferred("_setup_ember_thresholds")


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
	EventBus.round_draw.connect(_on_round_draw)


func _physics_process(delta: float) -> void:
	_tick_health(delta)
	_tick_ember(delta)
	_tick_announcer()
	_tick_combo()
	_tick_timer_warn()


# ── Health bars ──────────────────────────────────────────

func _tick_health(delta: float) -> void:
	# P1 — smooth drain + ghost trail
	p1_display_hp = lerpf(p1_display_hp, p1_hp, HP_LERP * delta)
	p1_bar.value = (p1_display_hp / maxf(p1_max_hp, 1.0)) * 100.0
	_color_hp(p1_bar, p1_display_hp / maxf(p1_max_hp, 1.0))

	if p1_ghost_delay > 0:
		p1_ghost_delay -= 1
	else:
		p1_ghost_hp = move_toward(p1_ghost_hp, p1_display_hp, GHOST_SPEED * delta)
	p1_ghost.value = (p1_ghost_hp / maxf(p1_max_hp, 1.0)) * 100.0

	# P2 — mirror
	p2_display_hp = lerpf(p2_display_hp, p2_hp, HP_LERP * delta)
	p2_bar.value = (p2_display_hp / maxf(p2_max_hp, 1.0)) * 100.0
	_color_hp(p2_bar, p2_display_hp / maxf(p2_max_hp, 1.0))

	if p2_ghost_delay > 0:
		p2_ghost_delay -= 1
	else:
		p2_ghost_hp = move_toward(p2_ghost_hp, p2_display_hp, GHOST_SPEED * delta)
	p2_ghost.value = (p2_ghost_hp / maxf(p2_max_hp, 1.0)) * 100.0


func _color_hp(bar: ProgressBar, ratio: float) -> void:
	var style := _ensure_own_fill(bar)
	if not style:
		return
	# Smooth continuous gradient: green (1.0) → yellow (0.5) → red (0.0)
	if ratio > 0.5:
		style.bg_color = CLR_HP_MID.lerp(CLR_HP_HIGH, (ratio - 0.5) / 0.5)
	else:
		style.bg_color = CLR_HP_LOW.lerp(CLR_HP_MID, ratio / 0.5)


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

func _tick_announcer() -> void:
	if not _announcing:
		announcer.modulate.a = 0.0
		return

	_announce_elapsed += 1
	var hold_end: int = ANNOUNCE_DURATION_FRAMES - ANNOUNCE_FADE_OUT_FRAMES

	if _announce_elapsed < ANNOUNCE_SCALE_IN_FRAMES:
		# Phase 1: punch-in scale (2.5x → 1x with ease curve)
		var t: float = float(_announce_elapsed) / float(ANNOUNCE_SCALE_IN_FRAMES)
		var s: float = lerpf(2.5, 1.0, ease(t, -2.0))
		announcer.pivot_offset = announcer.size * 0.5
		announcer.scale = Vector2(s, s)
		announcer.modulate.a = t
	elif _announce_elapsed < hold_end:
		# Phase 2: hold at full opacity
		announcer.scale = Vector2.ONE
		announcer.modulate.a = 1.0
	elif _announce_elapsed < ANNOUNCE_DURATION_FRAMES:
		# Phase 3: fade out
		var remaining: int = ANNOUNCE_DURATION_FRAMES - _announce_elapsed
		announcer.scale = Vector2.ONE
		announcer.modulate.a = float(remaining) / float(ANNOUNCE_FADE_OUT_FRAMES)
	else:
		_announcing = false
		announcer.modulate.a = 0.0


# ── Combo counter ───────────────────────────────────────

func _tick_combo() -> void:
	if _combo_active and _combo_count >= COMBO_MIN_DISPLAY:
		_show_combo(_combo_player_id, _combo_count, _combo_damage, 1.0)
	elif _combo_fade_frames > 0:
		_combo_fade_frames -= 1
		var alpha: float = float(_combo_fade_frames) / float(COMBO_FADE_FRAMES)
		_show_combo(_combo_player_id, _combo_count, _combo_damage, alpha)
	else:
		_hide_combo()


func _show_combo(pid: int, hit_count: int, damage: int, alpha: float) -> void:
	var hits_label: Label = p1_combo_hits if pid == 1 else p2_combo_hits
	var dmg_label: Label = p1_combo_dmg if pid == 1 else p2_combo_dmg
	var other_hits: Label = p2_combo_hits if pid == 1 else p1_combo_hits
	var other_dmg: Label = p2_combo_dmg if pid == 1 else p1_combo_dmg

	other_hits.modulate.a = 0.0
	other_dmg.modulate.a = 0.0

	hits_label.text = "%d HITS" % hit_count
	hits_label.modulate.a = alpha

	dmg_label.text = "%d DMG" % damage
	dmg_label.modulate.a = alpha * 0.85

	# Scale punch grows with combo length during active combos
	if _combo_active:
		var s: float = minf(1.0 + float(hit_count) * 0.04, 1.4)
		hits_label.pivot_offset = hits_label.size * 0.5
		hits_label.scale = Vector2(s, s)
	else:
		hits_label.scale = Vector2.ONE


func _hide_combo() -> void:
	p1_combo_hits.modulate.a = 0.0
	p1_combo_dmg.modulate.a = 0.0
	p2_combo_hits.modulate.a = 0.0
	p2_combo_dmg.modulate.a = 0.0


# ── Timer urgency ────────────────────────────────────────

func _tick_timer_warn() -> void:
	if not _timer_is_warn:
		return
	_timer_warn_frame += 1
	# ~4 Hz sine pulse using frame counter for deterministic visuals
	var pulse: float = (sin(float(_timer_warn_frame) * 0.42) + 1.0) * 0.5
	timer_label.add_theme_color_override("font_color",
		CLR_TIMER.lerp(CLR_TIMER_WARN, pulse))


# ── Signal handlers ──────────────────────────────────────

func _on_fighter_damaged(fighter: Variant, amount: int, remaining_hp: int) -> void:
	var pid: int = 1
	if fighter and "player_id" in fighter:
		pid = fighter.player_id

	_last_hit_damage = amount

	if pid == 1:
		p1_hp = float(remaining_hp)
		p1_ghost_delay = GHOST_DELAY_FRAMES
	else:
		p2_hp = float(remaining_hp)
		p2_ghost_delay = GHOST_DELAY_FRAMES

	# Accumulate damage during active combo (this fighter is the defender)
	if _combo_active and _combo_player_id != pid:
		_combo_damage += amount


func _on_fighter_ko(_fighter: Variant) -> void:
	_on_announce("K.O.!")


func _on_round_started(round_number: int) -> void:
	current_round = round_number

	# Reset all HP and display values
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

	# Reset combo state
	_combo_active = false
	_combo_fade_frames = 0
	_hide_combo()

	# Reset timer urgency
	_timer_is_warn = false
	_timer_warn_frame = 0
	timer_label.add_theme_color_override("font_color", CLR_TIMER)

	_rebuild_dots()

	# Show FINAL ROUND indicator when either player is one win from victory
	var is_final: bool = (
		p1_rounds_won >= ROUNDS_TO_WIN - 1 or p2_rounds_won >= ROUNDS_TO_WIN - 1
	)
	final_round_label.visible = is_final


func _on_round_ended(_winner: Variant, _round_number: int) -> void:
	p1_rounds_won = GameState.scores[0]
	p2_rounds_won = GameState.scores[1]
	_rebuild_dots()


func _on_round_draw(_round_number: int) -> void:
	p1_rounds_won = GameState.scores[0]
	p2_rounds_won = GameState.scores[1]
	_rebuild_dots()


func _on_match_ended(_winner: Variant, _scores: Array) -> void:
	pass


func _on_timer_updated(seconds_remaining: int) -> void:
	timer_label.text = str(seconds_remaining)
	_timer_is_warn = seconds_remaining <= TIMER_WARN_SECONDS
	if not _timer_is_warn:
		_timer_warn_frame = 0
		timer_label.add_theme_color_override("font_color", CLR_TIMER)


func _on_announce(text: String) -> void:
	var display_text: String = text

	# Replace round announcement with FINAL ROUND when at match point
	if text.begins_with("ROUND") or text.begins_with("Round"):
		var is_final: bool = (
			p1_rounds_won >= ROUNDS_TO_WIN - 1 or p2_rounds_won >= ROUNDS_TO_WIN - 1
		)
		if is_final:
			display_text = "FINAL ROUND"
			announcer.add_theme_color_override("font_color", CLR_FINAL)
		else:
			announcer.add_theme_color_override("font_color", Color.WHITE)
	elif text == "K.O.!" or text == "K.O.":
		announcer.add_theme_color_override("font_color", CLR_HP_LOW)
	elif text == "FIGHT!":
		announcer.add_theme_color_override("font_color", CLR_FIGHT)
	else:
		announcer.add_theme_color_override("font_color", Color.WHITE)

	announcer.text = display_text
	_announce_elapsed = 0
	_announcing = true
	announcer.scale = Vector2(2.5, 2.5)
	announcer.modulate.a = 0.0


func _on_ember_changed(player_id: int, new_value: int) -> void:
	if player_id == 1:
		p1_ember = float(new_value)
	else:
		p2_ember = float(new_value)


func _on_combo_updated(fighter: Variant, combo_count: int) -> void:
	var pid: int = 1
	if fighter and "player_id" in fighter:
		pid = fighter.player_id

	if combo_count >= 1:
		if not _combo_active:
			# New combo — include the first hit's damage
			_combo_damage = _last_hit_damage
			_combo_active = true
			_combo_player_id = pid
		_combo_count = combo_count
		_combo_fade_frames = 0


func _on_combo_ended(fighter: Variant, total_hits: int, total_damage: int) -> void:
	var pid: int = 1
	if fighter and "player_id" in fighter:
		pid = fighter.player_id

	if total_hits >= COMBO_MIN_DISPLAY:
		_combo_player_id = pid
		_combo_count = total_hits
		_combo_damage = total_damage
		_combo_fade_frames = COMBO_FADE_FRAMES
	_combo_active = false


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


# ── Ember threshold markers ─────────────────────────────

func _setup_ember_thresholds() -> void:
	# EX at 25 Ember, Ignition at 50 Ember (max 100)
	_add_threshold_marker(p1_ember_bar, 0.25, false)
	_add_threshold_marker(p1_ember_bar, 0.50, false)
	_add_threshold_marker(p2_ember_bar, 0.25, true)
	_add_threshold_marker(p2_ember_bar, 0.50, true)


func _add_threshold_marker(bar: ProgressBar, fraction: float, reversed: bool) -> void:
	var marker := ColorRect.new()
	marker.color = CLR_THRESH
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bar_size: Vector2 = bar.size
	var x_pos: float
	if reversed:
		x_pos = bar_size.x * (1.0 - fraction)
	else:
		x_pos = bar_size.x * fraction

	marker.position = Vector2(x_pos - 1.0, 0.0)
	marker.size = Vector2(2.0, bar_size.y)
	bar.add_child(marker)


# ── Helpers ──────────────────────────────────────────────

func _hide_announcer() -> void:
	announcer.text = ""
	announcer.modulate.a = 0.0
	_announcing = false


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
