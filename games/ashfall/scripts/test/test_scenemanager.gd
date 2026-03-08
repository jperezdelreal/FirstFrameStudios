extends Node2D
# Auto-generated test scene for SceneManager
# Tests SceneManager state

func _ready() -> void:
	print("="*60)
	print("Testing SceneManager...")
	print("="*60)
	
	run_tests()

func run_tests() -> void:
	print("Current scene: ", SceneManager.current_scene)
	print("Can transition: ", SceneManager.can_transition)
	
	print("")
	print("✅ SceneManager tests completed!")
	print("="*60)
