# SKILL: Godot Visual Testing

## What This Skill Covers
Automated screenshot-based visual testing for Godot 4.x games. Simulates player inputs, captures viewport screenshots at key moments, and saves them for human or AI analysis.

## Core Pattern

### Screenshot Capture
```gdscript
await RenderingServer.frame_post_draw
var image: Image = get_viewport().get_texture().get_image()
image.save_png(path)  # Accepts res://, user://, or absolute filesystem paths
```

### Input Simulation
```gdscript
# Tap input (attacks) — press 1 frame, release
Input.action_press("p1_light_punch")
await get_tree().process_frame
Input.action_release("p1_light_punch")

# Hold input (movement) — press, wait N frames, release
Input.action_press("p1_right")
await _wait_frames(60)
Input.action_release("p1_right")
```

### Frame-Based Waiting
```gdscript
func _wait_frames(count: int) -> void:
    for i in range(count):
        await get_tree().process_frame
```

### Waiting for Game State
```gdscript
# Connect to a signal and await it before starting tests
RoundManager.announce.connect(_on_announce)

func _on_announce(text: String) -> void:
    if text == "FIGHT!":
        RoundManager.announce.disconnect(_on_announce)
        _run_test_sequence()
```

### Output Directory Setup
```gdscript
# Create dirs before saving (Godot won't auto-create)
DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/screenshots/"))
DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir() + "/test_output")
```

### Dual-Path Save (Project + User)
```gdscript
# res:// path — globalize for save_png, stays in project tree
var abs_res := ProjectSettings.globalize_path("res://tools/screenshots/test.png")
image.save_png(abs_res)

# user:// path — always writable, use directly
image.save_png("user://test_output/test.png")
var abs_user := ProjectSettings.globalize_path("user://test_output/test.png")
print("Saved to: %s" % abs_user)
```

## File Structure
```
scripts/test/fight_visual_test.gd    # Test controller script
scenes/test/fight_visual_test.tscn   # Minimal scene (root Node2D + script)
tools/visual_test.bat                # CLI launcher
tools/screenshots/fight_test/        # Output directory (in .gitignore)
```

## Scene File Template (.tscn)
```
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://scripts/test/fight_visual_test.gd" id="1"]
[node name="FightVisualTest" type="Node2D"]
script = ExtResource("1")
```

## Batch Launcher Template
```batch
@echo off
set GODOT="path/to/godot_console.exe"
set PROJECT="path/to/project"
%GODOT% --path %PROJECT% --scene res://scenes/test/fight_visual_test.tscn -- --visual-test
```

## Key Principles
1. **Always await `RenderingServer.frame_post_draw`** before capturing — ensures the frame is fully rendered
2. **Use `OS.get_cmdline_user_args()`** to parse args after `--` separator
3. **Coroutine sequencing** (`await _wait_frames()`) is cleaner than frame-counter state machines for linear test sequences
4. **Prefix all output** with a tag like `[VISUAL_TEST]` for log filtering
5. **Call `get_tree().quit()`** at the end to exit cleanly in headless/CI environments
6. **Wait for game state** (e.g., round manager FIGHT state) before simulating inputs — don't assume fixed intro timing
7. **Release all inputs** in a cleanup step before quitting to avoid sticky input bugs

## When to Use
- Regression testing after art, animation, or camera changes
- Verifying fight scene renders correctly after code changes
- Generating screenshots for AI-based visual analysis
- CI/CD pipelines that need visual validation
