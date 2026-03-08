extends Node2D
# Auto-generated test scene for AudioManager
# Tests audio playback

func _ready() -> void:
	print("="*60)
	print("Testing AudioManager...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	AudioManager.play_sfx("hit_light")
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_sfx("hit_heavy")
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_sfx("block")
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_sfx("ko")
	
	print("")
	print("✅ AudioManager tests completed!")
	print("="*60)
