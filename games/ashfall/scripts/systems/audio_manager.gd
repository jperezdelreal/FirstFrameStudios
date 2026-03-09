## Autoload singleton managing all fight audio for Ashfall.
## Generates procedural sounds at startup, routes through dedicated mix buses,
## and reacts to EventBus signals for fully decoupled audio playback.
##
## Mix hierarchy (loudest → quietest):
##   Announcer (+3 dB) > SFX (0 dB) > Music (-10 dB)
##
## Sound pool: 8 concurrent SFX players (per GDD Appendix B)
## with ±5% pitch jitter on every hit to prevent repetition fatigue.
extends Node

# --- Constants ---
const SAMPLE_RATE: int = 44100
const SFX_POOL_SIZE: int = 8
const PITCH_JITTER: float = 0.05

# --- Audio bus indices (assigned at runtime) ---
var _sfx_bus_idx: int = -1
var _music_bus_idx: int = -1
var _announcer_bus_idx: int = -1

# --- Sound libraries ---
var _light_hit_sounds: Array[AudioStreamWAV] = []
var _heavy_hit_sounds: Array[AudioStreamWAV] = []
var _block_sound: AudioStreamWAV
var _whiff_sound: AudioStreamWAV
var _timer_tick_sound: AudioStreamWAV
var _ignition_sound: AudioStreamWAV
var _announcer_sounds: Dictionary = {}
var _bg_music_stream: AudioStreamWAV

# --- Player nodes ---
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0
var _music_player: AudioStreamPlayer
var _announcer_player: AudioStreamPlayer
var _tick_player: AudioStreamPlayer

# --- State ---
var _timer_ticking: bool = false


func _ready() -> void:
	_setup_buses()
	_generate_all_sounds()
	_create_players()
	_connect_signals()


# =========================================================================
# BUS SETUP — SFX, Music, Announcer routed to Master
# =========================================================================

func _setup_buses() -> void:
	AudioServer.add_bus()
	_sfx_bus_idx = AudioServer.bus_count - 1
	AudioServer.set_bus_name(_sfx_bus_idx, "SFX")
	AudioServer.set_bus_volume_db(_sfx_bus_idx, 0.0)
	AudioServer.set_bus_send(_sfx_bus_idx, "Master")

	AudioServer.add_bus()
	_music_bus_idx = AudioServer.bus_count - 1
	AudioServer.set_bus_name(_music_bus_idx, "Music")
	AudioServer.set_bus_volume_db(_music_bus_idx, -10.0)
	AudioServer.set_bus_send(_music_bus_idx, "Master")

	AudioServer.add_bus()
	_announcer_bus_idx = AudioServer.bus_count - 1
	AudioServer.set_bus_name(_announcer_bus_idx, "Announcer")
	AudioServer.set_bus_volume_db(_announcer_bus_idx, 3.0)
	AudioServer.set_bus_send(_announcer_bus_idx, "Master")


# =========================================================================
# PLAYER CREATION
# =========================================================================

func _create_players() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_sfx_pool.append(player)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	add_child(_music_player)

	_announcer_player = AudioStreamPlayer.new()
	_announcer_player.bus = &"Announcer"
	add_child(_announcer_player)

	_tick_player = AudioStreamPlayer.new()
	_tick_player.bus = &"SFX"
	add_child(_tick_player)


# =========================================================================
# SIGNAL WIRING — connect to EventBus for decoupled audio
# =========================================================================

func _connect_signals() -> void:
	EventBus.hit_landed.connect(_on_hit_landed)
	EventBus.hit_blocked.connect(_on_hit_blocked)
	EventBus.fighter_ko.connect(_on_fighter_ko)
	EventBus.round_started.connect(_on_round_started)
	EventBus.round_ended.connect(_on_round_ended)
	EventBus.match_ended.connect(_on_match_ended)
	EventBus.timer_updated.connect(_on_timer_updated)
	EventBus.announce.connect(_on_announce)
	EventBus.ignition_activated.connect(_on_ignition)


# =========================================================================
# EVENT HANDLERS
# =========================================================================

func _on_hit_landed(_attacker: Variant, _target: Variant, move: Variant) -> void:
	var is_heavy := _is_heavy_move(move)
	if is_heavy:
		play_heavy_hit()
	else:
		play_light_hit()


func _on_hit_blocked(_attacker: Variant, _target: Variant, _move: Variant) -> void:
	play_block()


func _on_fighter_ko(_fighter: Variant) -> void:
	# Dramatic body-impact SFX (announcer K.O. tone comes from announce signal)
	play_heavy_hit()


func _on_round_started(_round_number: int) -> void:
	_timer_ticking = false
	start_music()


func _on_round_ended(_winner: Variant, _round_number: int) -> void:
	_timer_ticking = false
	stop_music()


func _on_match_ended(_winner: Variant, _scores: Array) -> void:
	_timer_ticking = false
	stop_music()


func _on_timer_updated(seconds_remaining: int) -> void:
	if seconds_remaining <= 10 and seconds_remaining > 0:
		_timer_ticking = true
		_play_timer_tick()
	else:
		_timer_ticking = false


func _on_announce(text: String) -> void:
	var clean := text.to_upper().strip_edges()
	if clean.begins_with("ROUND"):
		var parts := clean.split(" ")
		if parts.size() >= 2:
			var round_num := parts[1].to_int()
			var key := "round_%d" % clampi(round_num, 1, 3)
			_play_announcer(key)
	elif clean.begins_with("FIGHT"):
		_play_announcer("fight")
	elif "K.O" in clean or clean == "KO":
		_play_announcer("ko")
	elif clean.begins_with("PERFECT"):
		_play_announcer("perfect")
	elif clean.begins_with("TIME"):
		_play_announcer("time")
	elif clean.begins_with("FINAL"):
		_play_announcer("round_3")


func _on_ignition(_player_id: int) -> void:
	_play_sfx(_ignition_sound)


# =========================================================================
# PUBLIC PLAYBACK API
# =========================================================================

func play_light_hit() -> void:
	if _light_hit_sounds.is_empty():
		return
	_play_sfx(_light_hit_sounds[randi() % _light_hit_sounds.size()])


func play_heavy_hit() -> void:
	if _heavy_hit_sounds.is_empty():
		return
	_play_sfx(_heavy_hit_sounds[randi() % _heavy_hit_sounds.size()])


func play_block() -> void:
	_play_sfx(_block_sound)


func play_whiff() -> void:
	_play_sfx(_whiff_sound)


func start_music() -> void:
	if _music_player.playing:
		return
	_music_player.stream = _bg_music_stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


# =========================================================================
# VOLUME CONTROL
# =========================================================================

func set_sfx_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(_sfx_bus_idx, db)

func set_music_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(_music_bus_idx, db)

func set_announcer_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(_announcer_bus_idx, db)

func set_master_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(0, db)

func get_sfx_volume() -> float:
	return AudioServer.get_bus_volume_db(_sfx_bus_idx)

func get_music_volume() -> float:
	return AudioServer.get_bus_volume_db(_music_bus_idx)

func get_announcer_volume() -> float:
	return AudioServer.get_bus_volume_db(_announcer_bus_idx)


# =========================================================================
# INTERNAL PLAYBACK HELPERS
# =========================================================================

func _play_sfx(stream: AudioStreamWAV, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	var player := _get_next_sfx_player()
	player.stream = stream
	player.pitch_scale = pitch_scale * randf_range(1.0 - PITCH_JITTER, 1.0 + PITCH_JITTER)
	player.play()


func _play_announcer(key: String) -> void:
	if not _announcer_sounds.has(key):
		return
	_announcer_player.stream = _announcer_sounds[key]
	_announcer_player.pitch_scale = 1.0
	_announcer_player.play()


func _play_timer_tick() -> void:
	_tick_player.stream = _timer_tick_sound
	_tick_player.pitch_scale = 1.0
	_tick_player.play()


func _get_next_sfx_player() -> AudioStreamPlayer:
	var start := _sfx_pool_index
	for i in SFX_POOL_SIZE:
		var idx := (start + i) % SFX_POOL_SIZE
		if not _sfx_pool[idx].playing:
			_sfx_pool_index = (idx + 1) % SFX_POOL_SIZE
			return _sfx_pool[idx]
	# All busy — steal oldest slot
	var player := _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % SFX_POOL_SIZE
	return player


func _is_heavy_move(move: Variant) -> bool:
	if move == null:
		return false
	if move is Resource:
		var dmg = move.get("damage") if move.has_method("get") else 0
		if dmg is int or dmg is float:
			return dmg > 80
		var move_name = move.get("name") if move.has_method("get") else ""
		if move_name is String:
			return "heavy" in move_name.to_lower() or "hp" in move_name.to_lower() or "hk" in move_name.to_lower()
	if move is Dictionary:
		var dmg = move.get("damage", 0)
		if dmg > 80:
			return true
		var move_name: String = move.get("name", "")
		return "heavy" in move_name.to_lower() or "hp" in move_name.to_lower() or "hk" in move_name.to_lower()
	return false


# =========================================================================
# PROCEDURAL SOUND GENERATION
# =========================================================================

func _generate_all_sounds() -> void:
	_generate_light_hits()
	_generate_heavy_hits()
	_block_sound = _generate_block()
	_whiff_sound = _generate_whiff()
	_timer_tick_sound = _generate_tick()
	_ignition_sound = _generate_ignition()
	_generate_announcer_sounds()
	_bg_music_stream = _generate_background_music()


# --- Light hits: sharp snap, short decay (3 variants per GDD) ---

func _generate_light_hits() -> void:
	_light_hit_sounds.append(_gen_layered_hit(200.0, 0.06, 0.7, 18.0))
	_light_hit_sounds.append(_gen_layered_hit(230.0, 0.055, 0.65, 22.0))
	_light_hit_sounds.append(_gen_layered_hit(175.0, 0.065, 0.75, 15.0))


# --- Heavy hits: deep impact boom, longer tail (3 variants per GDD) ---

func _generate_heavy_hits() -> void:
	_heavy_hit_sounds.append(_gen_heavy_hit(100.0, 40.0, 0.18, 0.85))
	_heavy_hit_sounds.append(_gen_heavy_hit(85.0, 30.0, 0.22, 0.9))
	_heavy_hit_sounds.append(_gen_heavy_hit(120.0, 50.0, 0.16, 0.8))


func _gen_layered_hit(base_freq: float, duration: float, volume: float,
		noise_decay: float) -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	var phase := 0.0

	for i in num_samples:
		var t := float(i) / num_samples
		# 5% attack, exponential decay
		var env: float
		if t < 0.05:
			env = t / 0.05
		else:
			env = exp(-8.0 * (t - 0.05))

		# Layer 1 — sine thud (base impact)
		phase += TAU * base_freq / SAMPLE_RATE
		var sine_val := sin(phase) * 0.6

		# Layer 2 — noise transient (snap texture, decays fast)
		var noise_val := (randf() * 2.0 - 1.0) * exp(-noise_decay * t) * 0.4

		var sample_f := (sine_val + noise_val) * env * volume
		_write_sample(data, i, sample_f)

	return _make_stream(data)


func _gen_heavy_hit(freq_start: float, freq_end: float, duration: float,
		volume: float) -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	var phase := 0.0
	var sub_phase := 0.0

	for i in num_samples:
		var t := float(i) / num_samples
		# Fast attack, slow decay
		var env: float
		if t < 0.02:
			env = t / 0.02
		else:
			env = exp(-4.0 * (t - 0.02))

		var freq := lerpf(freq_start, freq_end, t)
		phase += TAU * freq / SAMPLE_RATE
		var body := sin(phase) * 0.5

		# Sub-bass rumble
		sub_phase += TAU * (freq * 0.5) / SAMPLE_RATE
		var sub := sin(sub_phase) * 0.3

		# Noise impact
		var noise := (randf() * 2.0 - 1.0) * exp(-12.0 * t) * 0.3

		# High crack transient
		var crack := sin(phase * 8.0) * exp(-30.0 * t) * 0.15

		var sample_f := (body + sub + noise + crack) * env * volume
		_write_sample(data, i, sample_f)

	return _make_stream(data)


# --- Block: metallic ring + dull thud (must sound different from hits) ---

func _generate_block() -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * 0.12)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	var ring_phase1 := 0.0
	var ring_phase2 := 0.0

	for i in num_samples:
		var t := float(i) / num_samples
		var env := exp(-6.0 * t)

		# Metallic ring (two harmonically-unrelated frequencies = inharmonic = metallic)
		ring_phase1 += TAU * 800.0 / SAMPLE_RATE
		ring_phase2 += TAU * 2200.0 / SAMPLE_RATE
		var ring := sin(ring_phase1) * 0.4 + sin(ring_phase2) * 0.25

		# Dull thud underneath
		var thud := sin(TAU * 150.0 * float(i) / SAMPLE_RATE) * exp(-15.0 * t) * 0.3

		var sample_f := (ring + thud) * env * 0.7
		_write_sample(data, i, sample_f)

	return _make_stream(data)


# --- Whiff: breathy air-cutting whoosh ---

func _generate_whiff() -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * 0.08)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in num_samples:
		var t := float(i) / num_samples
		var env := sin(PI * t) * 0.3
		var noise := (randf() * 2.0 - 1.0) * env
		_write_sample(data, i, noise)

	return _make_stream(data)


# --- Timer tick: sharp 1kHz click ---

func _generate_tick() -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * 0.03)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in num_samples:
		var t := float(i) / num_samples
		var env := 1.0 - t
		var val := sin(TAU * 1000.0 * float(i) / SAMPLE_RATE) * env * 0.5
		_write_sample(data, i, val)

	return _make_stream(data)


# --- Ignition: rising flame whoosh + power burst ---

func _generate_ignition() -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * 0.35)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	var phase := 0.0

	for i in num_samples:
		var t := float(i) / num_samples
		# Rising frequency sweep (fire whoosh)
		var freq := lerpf(120.0, 900.0, t * t)
		phase += TAU * freq / SAMPLE_RATE

		# Envelope: slow build → peak at 70% → fast decay
		var env: float
		if t < 0.7:
			env = t / 0.7
		else:
			env = (1.0 - t) / 0.3

		var body := sin(phase) * 0.4
		var noise := (randf() * 2.0 - 1.0) * env * 0.35
		var harmonic := sin(phase * 3.0) * 0.15 * env

		var sample_f := (body + noise + harmonic) * env * 0.8
		_write_sample(data, i, sample_f)

	return _make_stream(data)


# --- Announcer: distinct tonal patterns per callout ---

func _generate_announcer_sounds() -> void:
	# Ascending patterns increase in register per round to build tension
	_announcer_sounds["round_1"] = _gen_announcer_notes([
		{freq = 440.0, dur = 0.12},
		{freq = 523.0, dur = 0.12},
		{freq = 659.0, dur = 0.25},
	])
	_announcer_sounds["round_2"] = _gen_announcer_notes([
		{freq = 523.0, dur = 0.12},
		{freq = 659.0, dur = 0.12},
		{freq = 784.0, dur = 0.25},
	])
	_announcer_sounds["round_3"] = _gen_announcer_notes([
		{freq = 659.0, dur = 0.12},
		{freq = 784.0, dur = 0.12},
		{freq = 1047.0, dur = 0.3},
	])
	_announcer_sounds["fight"] = _gen_announcer_notes([
		{freq = 880.0, dur = 0.08},
		{freq = 1047.0, dur = 0.08},
		{freq = 1319.0, dur = 0.15},
	], 0.9)
	_announcer_sounds["ko"] = _gen_announcer_notes([
		{freq = 784.0, dur = 0.15},
		{freq = 392.0, dur = 0.35},
	], 0.85)
	_announcer_sounds["perfect"] = _gen_announcer_notes([
		{freq = 523.0, dur = 0.1},
		{freq = 659.0, dur = 0.1},
		{freq = 784.0, dur = 0.1},
		{freq = 1047.0, dur = 0.35},
	], 0.8)
	_announcer_sounds["time"] = _gen_announcer_notes([
		{freq = 660.0, dur = 0.15},
		{freq = 440.0, dur = 0.3},
	], 0.75)


func _gen_announcer_notes(notes: Array, volume: float = 0.7) -> AudioStreamWAV:
	var gap := 0.03
	var total_dur := 0.0
	for note in notes:
		total_dur += note.dur + gap
	total_dur -= gap

	var num_samples := int(SAMPLE_RATE * total_dur)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	var sample_offset := 0
	for note_idx in notes.size():
		var note: Dictionary = notes[note_idx]
		var note_samples := int(SAMPLE_RATE * note.dur)
		var gap_samples := int(SAMPLE_RATE * gap) if note_idx < notes.size() - 1 else 0
		var phase := 0.0

		for i in note_samples:
			var t := float(i) / note_samples
			var env := 1.0
			if t < 0.08:
				env = t / 0.08
			elif t > 0.85:
				env = (1.0 - t) / 0.15

			# Square wave + sine fundamental for arcade-referee tone
			phase += TAU * note.freq / SAMPLE_RATE
			var val := (1.0 if sin(phase) > 0 else -1.0) * env * volume * 0.4
			val += sin(phase) * env * volume * 0.3

			var idx := (sample_offset + i) * 2
			if idx + 1 < data.size():
				_write_sample_at(data, idx, val)

		sample_offset += note_samples + gap_samples

	return _make_stream(data)


# --- Background music: ember drone — looping ambient for Ember Grounds ---

func _generate_background_music() -> AudioStreamWAV:
	var bpm := 112.0
	var beat_dur := 60.0 / bpm
	var total_beats := 16  # 4 bars × 4 beats
	var total_dur := total_beats * beat_dur
	var num_samples := int(SAMPLE_RATE * total_dur)

	var data := PackedByteArray()
	data.resize(num_samples * 2)

	var bass_notes := [130.81, 164.81, 196.0, 261.63, 196.0, 164.81, 130.81, 164.81]
	var bass_phase := 0.0
	var drone_phase := 0.0

	for i in num_samples:
		var t_abs := float(i) / SAMPLE_RATE
		var beat_f := t_abs / beat_dur
		var beat_idx := int(beat_f) % total_beats
		var beat_pos := fmod(beat_f, 1.0)

		# Bass — sine notes through C-E-G progression
		var note_idx := beat_idx % bass_notes.size()
		var bass_freq: float = bass_notes[note_idx]
		var note_env := 1.0 if beat_pos < 0.85 else (1.0 - (beat_pos - 0.85) / 0.15)
		note_env *= 0.12
		bass_phase += TAU * bass_freq / SAMPLE_RATE
		var bass := sin(bass_phase) * note_env

		# Low drone — A1 with slow LFO modulation
		drone_phase += TAU * 55.0 / SAMPLE_RATE
		var drone := sin(drone_phase) * 0.06
		drone *= 0.7 + 0.3 * sin(TAU * 0.25 * t_abs)

		# Kick on even beats
		var kick := 0.0
		if beat_idx % 2 == 0 and beat_pos < 0.06:
			var kick_t := beat_pos / 0.06
			var kick_freq := lerpf(80.0, 30.0, kick_t)
			kick = sin(TAU * kick_freq * beat_pos) * (1.0 - kick_t) * 0.08

		# Hi-hat noise on every beat
		var hat := 0.0
		if beat_pos < 0.02:
			hat = (randf() * 2.0 - 1.0) * (1.0 - beat_pos / 0.02) * 0.04

		_write_sample(data, i, bass + drone + kick + hat)

	var stream := _make_stream(data)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = num_samples
	return stream


# =========================================================================
# PCM UTILITIES
# =========================================================================

func _make_stream(pcm_data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = pcm_data
	return stream


func _write_sample(data: PackedByteArray, sample_index: int, value: float) -> void:
	var clamped := clampf(value, -1.0, 1.0)
	var sample_int := int(clamped * 32767.0)
	var byte_idx := sample_index * 2
	data[byte_idx] = sample_int & 0xFF
	data[byte_idx + 1] = (sample_int >> 8) & 0xFF


func _write_sample_at(data: PackedByteArray, byte_index: int, value: float) -> void:
	var clamped := clampf(value, -1.0, 1.0)
	var sample_int := int(clamped * 32767.0)
	data[byte_index] = sample_int & 0xFF
	data[byte_index + 1] = (sample_int >> 8) & 0xFF
