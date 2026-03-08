extends Node2D
# Auto-generated test scene for VFXManager
# Tests VFX effects

func _ready() -> void:
	print("="*60)
	print("Testing VFXManager...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	VFXManager.play_hit_spark(Vector2(640, 360))
	await get_tree().create_timer(0.5).timeout
	VFXManager.play_block_spark(Vector2(640, 400))
	await get_tree().create_timer(0.5).timeout
	VFXManager.screen_shake(0.3, 10.0)
	
	print("")
	print("✅ VFXManager tests completed!")
	print("="*60)
