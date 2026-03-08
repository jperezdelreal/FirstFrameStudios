extends Node2D
# Auto-generated test scene for RoundManager
# Tests RoundManager flow

func _ready() -> void:
	print("="*60)
	print("Testing RoundManager...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	RoundManager.start_round()
	await get_tree().create_timer(1.0).timeout
	RoundManager.end_round(1)
	print("Round: ", RoundManager.current_round)
	
	print("")
	print("✅ RoundManager tests completed!")
	print("="*60)
