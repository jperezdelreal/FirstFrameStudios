extends Control
# Tool 9: VFX/Audio Test Bench (#40)
# Interactive test environment for VFX and audio effects
# Author: Jango (Lead, Tool Engineer)

# VFX test parameters
var vfx_intensity: float = 1.0
var vfx_duration: float = 0.3

# Audio test parameters
var audio_pitch: float = 1.0
var audio_volume: float = 0.0  # dB

# VFX list
var vfx_effects = [
	{"name": "Hit Spark (Light)", "method": "play_hit_spark", "args": []},
	{"name": "Hit Spark (Heavy)", "method": "play_hit_spark_heavy", "args": []},
	{"name": "Block Spark", "method": "play_block_spark", "args": []},
	{"name": "Screen Shake (Light)", "method": "screen_shake", "args": [0.2, 5.0]},
	{"name": "Screen Shake (Heavy)", "method": "screen_shake", "args": [0.5, 15.0]},
	{"name": "KO Slowmo", "method": "ko_slowmo", "args": []},
	{"name": "Hit Flash", "method": "hit_flash", "args": []},
	{"name": "Dust Impact", "method": "dust_impact", "args": []},
]

# Audio effects (14 procedural sounds from GDD)
var audio_effects = [
	"hit_light",
	"hit_medium",
	"hit_heavy",
	"block",
	"whiff",
	"jump",
	"land",
	"dash",
	"special",
	"super",
	"ko",
	"round_start",
	"round_end",
	"menu_select",
]

func _ready() -> void:
	build_interface()
	print("🎨 VFX/Audio Test Bench loaded!")
	print("Test your effects here - no more 'I never saw my work' 😎")

func build_interface() -> void:
	# Main container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	margin.add_child(main_vbox)
	
	# Title
	var title = Label.new()
	title.text = "🎨 VFX / AUDIO TEST BENCH"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "The 'I never saw my work' fix for Bossk and Greedo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(subtitle)
	
	main_vbox.add_child(HSeparator.new())
	
	# Horizontal split: VFX left, Audio right
	var hsplit = HBoxContainer.new()
	hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(hsplit)
	
	# VFX Section
	var vfx_section = create_vfx_section()
	hsplit.add_child(vfx_section)
	
	hsplit.add_child(VSeparator.new())
	
	# Audio Section
	var audio_section = create_audio_section()
	hsplit.add_child(audio_section)

func create_vfx_section() -> VBoxContainer:
	var section = VBoxContainer.new()
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var header = Label.new()
	header.text = "⚡ VFX EFFECTS"
	header.add_theme_font_size_override("font_size", 24)
	section.add_child(header)
	
	# Parameter controls
	var params_group = VBoxContainer.new()
	section.add_child(params_group)
	
	# Intensity slider
	var intensity_label = Label.new()
	intensity_label.text = "Intensity: 1.0"
	params_group.add_child(intensity_label)
	
	var intensity_slider = HSlider.new()
	intensity_slider.min_value = 0.1
	intensity_slider.max_value = 2.0
	intensity_slider.value = 1.0
	intensity_slider.step = 0.1
	intensity_slider.value_changed.connect(func(val):
		vfx_intensity = val
		intensity_label.text = "Intensity: %.1f" % val
	)
	params_group.add_child(intensity_slider)
	
	# Duration slider
	var duration_label = Label.new()
	duration_label.text = "Duration: 0.3s"
	params_group.add_child(duration_label)
	
	var duration_slider = HSlider.new()
	duration_slider.min_value = 0.1
	duration_slider.max_value = 2.0
	duration_slider.value = 0.3
	duration_slider.step = 0.1
	duration_slider.value_changed.connect(func(val):
		vfx_duration = val
		duration_label.text = "Duration: %.1fs" % val
	)
	params_group.add_child(duration_slider)
	
	section.add_child(HSeparator.new())
	
	# VFX buttons
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_child(scroll)
	
	var vfx_grid = VBoxContainer.new()
	scroll.add_child(vfx_grid)
	
	for effect in vfx_effects:
		var btn = Button.new()
		btn.text = effect.name
		btn.pressed.connect(_on_vfx_button_pressed.bind(effect))
		vfx_grid.add_child(btn)
	
	return section

func create_audio_section() -> VBoxContainer:
	var section = VBoxContainer.new()
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var header = Label.new()
	header.text = "🔊 AUDIO EFFECTS"
	header.add_theme_font_size_override("font_size", 24)
	section.add_child(header)
	
	# Parameter controls
	var params_group = VBoxContainer.new()
	section.add_child(params_group)
	
	# Pitch slider
	var pitch_label = Label.new()
	pitch_label.text = "Pitch: 1.0"
	params_group.add_child(pitch_label)
	
	var pitch_slider = HSlider.new()
	pitch_slider.min_value = 0.5
	pitch_slider.max_value = 2.0
	pitch_slider.value = 1.0
	pitch_slider.step = 0.1
	pitch_slider.value_changed.connect(func(val):
		audio_pitch = val
		pitch_label.text = "Pitch: %.1f" % val
	)
	params_group.add_child(pitch_slider)
	
	# Volume slider
	var volume_label = Label.new()
	volume_label.text = "Volume: 0dB"
	params_group.add_child(volume_label)
	
	var volume_slider = HSlider.new()
	volume_slider.min_value = -20.0
	volume_slider.max_value = 10.0
	volume_slider.value = 0.0
	volume_slider.step = 1.0
	volume_slider.value_changed.connect(func(val):
		audio_volume = val
		volume_label.text = "Volume: %ddB" % int(val)
	)
	params_group.add_child(volume_slider)
	
	section.add_child(HSeparator.new())
	
	# Audio buttons
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_child(scroll)
	
	var audio_grid = VBoxContainer.new()
	scroll.add_child(audio_grid)
	
	for effect in audio_effects:
		var btn = Button.new()
		btn.text = effect.replace("_", " ").capitalize()
		btn.pressed.connect(_on_audio_button_pressed.bind(effect))
		audio_grid.add_child(btn)
	
	return section

func _on_vfx_button_pressed(effect: Dictionary) -> void:
	print("▶️ Playing VFX: ", effect.name)
	
	if not VFXManager:
		print("❌ VFXManager not found!")
		return
	
	# Get mouse position for effect spawn
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Call VFX method with parameters
	var method = effect.method
	if VFXManager.has_method(method):
		if effect.args.is_empty():
			# Methods that need position
			if method in ["play_hit_spark", "play_hit_spark_heavy", "play_block_spark", "dust_impact"]:
				VFXManager.call(method, mouse_pos)
			else:
				VFXManager.call(method)
		else:
			# Methods with custom args (like screen_shake)
			var args = effect.args.duplicate()
			if method == "screen_shake":
				args[0] = args[0] * vfx_intensity
				args[1] = args[1] * vfx_intensity
			VFXManager.callv(method, args)
	else:
		print("⚠️ VFXManager doesn't have method: ", method)
		print("   (This is OK - method may not be implemented yet)")

func _on_audio_button_pressed(effect_name: String) -> void:
	print("▶️ Playing Audio: ", effect_name)
	
	if not AudioManager:
		print("❌ AudioManager not found!")
		return
	
	# Call audio method (assuming play_sfx API)
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx(effect_name, audio_volume, audio_pitch)
	elif AudioManager.has_method("play_sound"):
		AudioManager.play_sound(effect_name, audio_volume, audio_pitch)
	else:
		print("⚠️ AudioManager doesn't have play_sfx() or play_sound() method")
		print("   (This is OK - method may not be implemented yet)")

func _input(event: InputEvent) -> void:
	# Quick exit with ESC
	if event.is_action_pressed("ui_cancel"):
		print("Exiting test bench...")
		get_tree().quit()
