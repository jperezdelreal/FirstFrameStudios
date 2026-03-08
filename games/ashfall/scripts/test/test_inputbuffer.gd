extends Node2D
# Auto-generated test scene for InputBuffer
# Tests input buffering

func _ready() -> void:
	print("="*60)
	print("Testing InputBuffer...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	InputBuffer.buffer_input("p1_light_punch", 1)
	await get_tree().create_timer(0.1).timeout
	var inputs = InputBuffer.get_buffered_inputs(1, 0.3)
	print("Buffered inputs: ", inputs.size())
	
	print("")
	print("✅ InputBuffer tests completed!")
	print("="*60)
