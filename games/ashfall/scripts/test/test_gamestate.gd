extends Node2D
# Auto-generated test scene for GameState
# Tests GameState tracking

func _ready() -> void:
	print("="*60)
	print("Testing GameState...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	GameState.start_match("Kael", "Rhena")
	GameState.set_round_winner(1)
	print("Match state: ", GameState.get_match_state())
	
	print("")
	print("✅ GameState tests completed!")
	print("="*60)
