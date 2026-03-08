#!/usr/bin/env python3
"""
Tool 8: Test Scene Generator (#38)
Scans autoload systems and generates minimal test scenes for each.
Author: Jango (Lead, Tool Engineer)
"""

import os
import sys
from pathlib import Path

ASHFALL_ROOT = Path(__file__).parent.parent / "games" / "ashfall"
SYSTEMS_DIR = ASHFALL_ROOT / "scripts" / "systems"
TEST_SCENES_DIR = ASHFALL_ROOT / "scenes" / "test"
TEST_SCRIPTS_DIR = ASHFALL_ROOT / "scripts" / "test"

# System-specific test configurations
SYSTEM_TEST_CONFIG = {
    "event_bus.gd": {
        "name": "EventBus",
        "test_methods": [
            'EventBus.emit_signal("round_started", 1)',
            'EventBus.emit_signal("player_hit", 1, 50)',
            'EventBus.emit_signal("round_ended", 1)'
        ],
        "description": "Tests EventBus signal emission"
    },
    "game_state.gd": {
        "name": "GameState",
        "test_methods": [
            'GameState.start_match("Kael", "Rhena")',
            'GameState.set_round_winner(1)',
            'print("Match state: ", GameState.get_match_state())'
        ],
        "description": "Tests GameState tracking"
    },
    "round_manager.gd": {
        "name": "RoundManager",
        "test_methods": [
            'RoundManager.start_round()',
            'await get_tree().create_timer(1.0).timeout',
            'RoundManager.end_round(1)',
            'print("Round: ", RoundManager.current_round)'
        ],
        "description": "Tests RoundManager flow"
    },
    "vfx_manager.gd": {
        "name": "VFXManager",
        "test_methods": [
            'VFXManager.play_hit_spark(Vector2(640, 360))',
            'await get_tree().create_timer(0.5).timeout',
            'VFXManager.play_block_spark(Vector2(640, 400))',
            'await get_tree().create_timer(0.5).timeout',
            'VFXManager.screen_shake(0.3, 10.0)'
        ],
        "description": "Tests VFX effects"
    },
    "audio_manager.gd": {
        "name": "AudioManager",
        "test_methods": [
            'AudioManager.play_sfx("hit_light")',
            'await get_tree().create_timer(0.5).timeout',
            'AudioManager.play_sfx("hit_heavy")',
            'await get_tree().create_timer(0.5).timeout',
            'AudioManager.play_sfx("block")',
            'await get_tree().create_timer(0.5).timeout',
            'AudioManager.play_sfx("ko")'
        ],
        "description": "Tests audio playback"
    },
    "scene_manager.gd": {
        "name": "SceneManager",
        "test_methods": [
            'print("Current scene: ", SceneManager.current_scene)',
            'print("Can transition: ", SceneManager.can_transition)'
        ],
        "description": "Tests SceneManager state"
    },
    "input_buffer.gd": {
        "name": "InputBuffer",
        "test_methods": [
            'InputBuffer.buffer_input("p1_light_punch", 1)',
            'await get_tree().create_timer(0.1).timeout',
            'var inputs = InputBuffer.get_buffered_inputs(1, 0.3)',
            'print("Buffered inputs: ", inputs.size())'
        ],
        "description": "Tests input buffering"
    }
}

def generate_test_scene_tscn(system_name: str, test_script_path: str) -> str:
    """Generate .tscn file content for a test scene"""
    return f"""[gd_scene load_steps=2 format=3 uid="uid://test_{system_name.lower()}"]

[ext_resource type="Script" path="{test_script_path}" id="1"]

[node name="Test{system_name}" type="Node2D"]
script = ExtResource("1")

[node name="Label" type="Label" parent="."]
offset_left = 50.0
offset_top = 50.0
offset_right = 600.0
offset_bottom = 150.0
theme_override_font_sizes/font_size = 24
text = "Test: {system_name}
Running automated tests...
Check console for output."
"""

def generate_test_script(system_name: str, config: dict) -> str:
    """Generate GDScript test file content"""
    test_calls = "\n\t".join(config["test_methods"])
    
    return f'''extends Node2D
# Auto-generated test scene for {system_name}
# {config["description"]}

func _ready() -> void:
\tprint("="*60)
\tprint("Testing {system_name}...")
\tprint("="*60)
\t
\trun_tests()

func run_tests() -> void:
\t{test_calls}
\t
\tprint("")
\tprint("✅ {system_name} tests completed!")
\tprint("="*60)
'''

def generate_test_index_scene() -> tuple[str, str]:
    """Generate test_index.tscn and script that links to all test scenes"""
    tscn = """[gd_scene load_steps=2 format=3 uid="uid://test_index"]

[ext_resource type="Script" path="res://scripts/test/test_index.gd" id="1"]

[node name="TestIndex" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="VBoxContainer" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -200.0
offset_top = -250.0
offset_right = 200.0
offset_bottom = 250.0
grow_horizontal = 2
grow_vertical = 2

[node name="Title" type="Label" parent="VBoxContainer"]
layout_mode = 2
theme_override_font_sizes/font_size = 32
text = "Ashfall Test Suite"
horizontal_alignment = 1

[node name="Subtitle" type="Label" parent="VBoxContainer"]
layout_mode = 2
text = "Select a test scene to run:"
horizontal_alignment = 1

[node name="HSeparator" type="HSeparator" parent="VBoxContainer"]
layout_mode = 2
"""
    
    script = '''extends Control
# Auto-generated test index - links to all test scenes

var test_scenes = []

func _ready() -> void:
\tscan_test_scenes()
\tcreate_buttons()

func scan_test_scenes() -> void:
\tvar test_dir = "res://scenes/test/"
\tvar dir = DirAccess.open(test_dir)
\tif dir:
\t\tdir.list_dir_begin()
\t\tvar file_name = dir.get_next()
\t\twhile file_name != "":
\t\t\tif file_name.ends_with(".tscn") and file_name.begins_with("test_") and file_name != "test_index.tscn":
\t\t\t\ttest_scenes.append(test_dir + file_name)
\t\t\tfile_name = dir.get_next()
\t\tdir.list_dir_end()
\t
\ttest_scenes.sort()
\tprint("Found ", test_scenes.size(), " test scenes")

func create_buttons() -> void:
\tvar vbox = $VBoxContainer
\t
\tfor scene_path in test_scenes:
\t\tvar button = Button.new()
\t\tvar scene_name = scene_path.get_file().get_basename()
\t\tbutton.text = scene_name.replace("test_", "").replace("_", " ").capitalize()
\t\tbutton.pressed.connect(_on_test_button_pressed.bind(scene_path))
\t\tvbox.add_child(button)
\t
\tif test_scenes.is_empty():
\t\tvar label = Label.new()
\t\tlabel.text = "No test scenes found!"
\t\tvbox.add_child(label)

func _on_test_button_pressed(scene_path: String) -> void:
\tprint("Loading test scene: ", scene_path)
\tget_tree().change_scene_to_file(scene_path)
'''
    
    return tscn, script

def main():
    print("🔧 Tool 8: Test Scene Generator")
    print("=" * 60)
    
    # Ensure output directories exist
    TEST_SCENES_DIR.mkdir(parents=True, exist_ok=True)
    TEST_SCRIPTS_DIR.mkdir(parents=True, exist_ok=True)
    
    generated_count = 0
    
    # Generate test scene for each configured system
    for system_file, config in SYSTEM_TEST_CONFIG.items():
        system_path = SYSTEMS_DIR / system_file
        
        if not system_path.exists():
            print(f"⚠️  System not found: {system_file} (skipping)")
            continue
        
        system_name = config["name"]
        test_scene_name = f"test_{system_name.lower()}"
        
        # Generate script
        test_script_path = TEST_SCRIPTS_DIR / f"{test_scene_name}.gd"
        test_script_content = generate_test_script(system_name, config)
        test_script_path.write_text(test_script_content, encoding="utf-8")
        
        # Generate scene
        test_scene_path = TEST_SCENES_DIR / f"{test_scene_name}.tscn"
        rel_script_path = f"res://scripts/test/{test_scene_name}.gd"
        test_scene_content = generate_test_scene_tscn(system_name, rel_script_path)
        test_scene_path.write_text(test_scene_content, encoding="utf-8")
        
        print(f"✅ Generated test for {system_name}")
        generated_count += 1
    
    # Generate test index
    index_tscn, index_script = generate_test_index_scene()
    (TEST_SCENES_DIR / "test_index.tscn").write_text(index_tscn, encoding="utf-8")
    (TEST_SCRIPTS_DIR / "test_index.gd").write_text(index_script, encoding="utf-8")
    print(f"✅ Generated test index scene")
    
    print("=" * 60)
    print(f"✨ Generated {generated_count} test scenes + index")
    print(f"📂 Scenes: {TEST_SCENES_DIR}")
    print(f"📂 Scripts: {TEST_SCRIPTS_DIR}")
    print(f"🚀 Run: Open test_index.tscn in Godot and select a test")
    return 0

if __name__ == "__main__":
    sys.exit(main())
