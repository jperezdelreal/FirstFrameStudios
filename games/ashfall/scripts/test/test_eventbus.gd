extends Node2D
# Auto-generated test scene for EventBus
# Tests EventBus signal emission

func _ready() -> void:
	print("="*60)
	print("Testing EventBus...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	EventBus.emit_signal("round_started", 1)
	EventBus.emit_signal("player_hit", 1, 50)
	EventBus.emit_signal("round_ended", 1)
	
	print("")
	print("✅ EventBus tests completed!")
	print("="*60)
