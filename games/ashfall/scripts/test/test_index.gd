extends Control
# Auto-generated test index - links to all test scenes

var test_scenes = []

func _ready() -> void:
	scan_test_scenes()
	create_buttons()

func scan_test_scenes() -> void:
	var test_dir = "res://scenes/test/"
	var dir = DirAccess.open(test_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn") and file_name.begins_with("test_") and file_name != "test_index.tscn":
				test_scenes.append(test_dir + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	test_scenes.sort()
	print("Found ", test_scenes.size(), " test scenes")

func create_buttons() -> void:
	var vbox = $VBoxContainer
	
	for scene_path in test_scenes:
		var button = Button.new()
		var scene_name = scene_path.get_file().get_basename()
		button.text = scene_name.replace("test_", "").replace("_", " ").capitalize()
		button.pressed.connect(_on_test_button_pressed.bind(scene_path))
		vbox.add_child(button)
	
	if test_scenes.is_empty():
		var label = Label.new()
		label.text = "No test scenes found!"
		vbox.add_child(label)

func _on_test_button_pressed(scene_path: String) -> void:
	print("Loading test scene: ", scene_path)
	get_tree().change_scene_to_file(scene_path)
