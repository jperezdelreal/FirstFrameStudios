# SKILL: Godot 4 Manual — Part 2 (Sections 7–12)

Continuation of the Godot 4 reference for porting firstPunch from Canvas 2D / Web Audio to Godot 4. Covers input, audio, tilemaps, project organization, key patterns, and a complete JS → Godot migration table.

---
name: "godot-4-manual-part2"
description: "Godot 4 deep-dive: input, audio, tilemaps, project org, patterns, and JS migration mapping"
domain: "game-engine"
confidence: "medium"
source: "authored — Chewie (Engine Dev), synthesized from Godot 4.x docs + firstPunch codebase analysis"
---

## When to Use This Skill
- Implementing input, audio, tilemaps, or project structure in the Godot port
- Migrating any firstPunch JS module to its Godot equivalent
- Applying beat-em-up patterns (state machines, pooling, screen shake) in GDScript
- Setting up export presets or folder conventions for the Godot project

## When NOT to Use This Skill
- Godot 3.x projects (API differs significantly)
- 3D projects (different node types, spatial audio setup)
- Non-porting tasks where no JS → Godot mapping is needed

---

## 7. Input System

### 7.1 InputMap

Godot's **InputMap** decouples physical keys from game actions. Define actions in **Project → Project Settings → Input Map** or via code. Each action can bind keyboard, mouse, and gamepad inputs simultaneously.

```gdscript
# Add actions at runtime (normally done in Project Settings)
func _ready():
    InputMap.add_action("attack")
    var key_event = InputEventKey.new()
    key_event.keycode = KEY_Z
    InputMap.action_add_event("attack", key_event)
```

### 7.2 Polling: is_action_pressed vs is_action_just_pressed

- `Input.is_action_pressed("move_right")` — returns `true` every frame the key is held. Use for continuous movement.
- `Input.is_action_just_pressed("attack")` — returns `true` only on the frame the key goes down. Use for discrete actions (punch, jump, menu confirm).
- `Input.is_action_just_released("grab")` — fires once on key-up. Useful for charge-release mechanics.

Always poll input in `_process()` or `_unhandled_input()`, never in `_physics_process()` unless you need frame-perfect physics alignment.

```gdscript
func _process(_delta):
    var dir = Vector2.ZERO
    dir.x = Input.get_axis("move_left", "move_right")
    dir.y = Input.get_axis("move_up", "move_down")
    velocity = dir * SPEED

    if Input.is_action_just_pressed("attack"):
        _start_attack()
```

### 7.3 Gamepad Support

Godot auto-detects gamepads. Bind stick axes and buttons alongside keyboard keys on the same action name — no extra code needed. Use `Input.get_connected_joypads()` to enumerate controllers for local co-op.

```gdscript
# In Project Settings, bind "move_right" to both:
#   KEY_D  +  Joypad Axis 0 (positive)
# Then this single line handles both:
var h = Input.get_axis("move_left", "move_right")
```

### 7.4 Input Buffering

firstPunch's JS `input.js` buffers attack presses for combo chains. Replicate with a timer:

```gdscript
var _attack_buffer_time := 0.0
const BUFFER_WINDOW := 0.15  # seconds

func _process(delta):
    if Input.is_action_just_pressed("attack"):
        _attack_buffer_time = BUFFER_WINDOW
    _attack_buffer_time = max(_attack_buffer_time - delta, 0.0)

func consume_attack_buffer() -> bool:
    if _attack_buffer_time > 0.0:
        _attack_buffer_time = 0.0
        return true
    return false
```

Call `consume_attack_buffer()` when the current attack animation ends to chain the next hit.

---

## 8. Audio in Godot

### 8.1 AudioStreamPlayer Nodes

Godot provides three player nodes:

| Node | Use Case |
|------|----------|
| `AudioStreamPlayer` | Non-positional (music, UI SFX) |
| `AudioStreamPlayer2D` | Positional in 2D (enemy grunts, impacts) |
| `AudioStreamPlayer3D` | Positional in 3D (not used in 2D games) |

Load `.ogg` (recommended) or `.wav` files as `AudioStream` resources. Call `play()` to start.

```gdscript
@onready var sfx_hit = $HitSound  # AudioStreamPlayer node

func on_hit():
    sfx_hit.pitch_scale = randf_range(0.9, 1.1)  # slight variation
    sfx_hit.play()
```

### 8.2 Audio Bus Layout

Edit buses in the **Audio** tab at the bottom of the editor. firstPunch's JS `audio.js` has four buses — replicate the same layout:

| Bus | Purpose | Godot Setup |
|-----|---------|-------------|
| Master | Final output | Auto-created |
| Music | Background tracks | Route music players here |
| SFX | Hit sounds, impacts | Route combat AudioStreamPlayers here |
| UI | Menu clicks, confirms | Route UI sounds here |

Set a player's bus in code or inspector:

```gdscript
$HitSound.bus = "SFX"
$MenuClick.bus = "UI"
```

Adjust bus volume globally:

```gdscript
AudioServer.set_bus_volume_db(
    AudioServer.get_bus_index("SFX"), linear_to_db(0.8)
)
```

### 8.3 Spatial Audio (2D)

`AudioStreamPlayer2D` attenuates based on distance from the active `Listener2D` (or the camera if no listener is set). Configure `max_distance` and `attenuation` in the inspector. Great for positional hit sounds and environmental audio.

### 8.4 Procedural Audio with AudioStreamGenerator

firstPunch's `music.js` generates oscillator-based music. In Godot, use `AudioStreamGenerator`:

```gdscript
var playback: AudioStreamGeneratorPlayback
func _ready():
    var gen = AudioStreamGenerator.new()
    gen.mix_rate = 44100.0
    $Player.stream = gen
    $Player.play()
    playback = $Player.get_stream_playback()

func _process(_delta):
    while playback.get_frames_available() > 0:
        var sample = sin(phase * TAU) * 0.3
        playback.push_frame(Vector2(sample, sample))
        phase += frequency / 44100.0
```

This is low-level. For most cases, prefer pre-rendered audio assets and layer them with multiple `AudioStreamPlayer` nodes at different volumes for intensity-based music (crossfade between calm and intense tracks).

---

## 9. Tilemaps & Level Design

### 9.1 TileMap Node

`TileMap` is Godot 4's primary node for grid-based level geometry. Assign a `TileSet` resource containing your tile atlas (spritesheet), then paint levels directly in the editor.

Key properties:
- **Tile Size** — matches your art grid (e.g., 16×16, 32×32).
- **Layers** — a single TileMap can have multiple layers (ground, walls, decoration) with independent z-index and physics.
- **Physics Layers** — assign collision shapes per-tile in the TileSet to auto-generate walkable/blocked areas.

```gdscript
# Place/remove tiles via code
var tilemap: TileMap = $TileMap
tilemap.set_cell(0, Vector2i(5, 3), 0, Vector2i(2, 0))  # layer, coords, source_id, atlas_coords
tilemap.erase_cell(0, Vector2i(5, 3))
```

### 9.2 TileSet Configuration

Create a `TileSet` resource, add a texture atlas, then define:
- **Terrain sets** — auto-tiling with terrain bits (Godot auto-picks correct corners/edges).
- **Physics layers** — collision polygons per tile for walls and floors.
- **Custom data layers** — attach metadata (e.g., `is_hazard`, `damage_amount`) to tiles, readable at runtime.

```gdscript
# Read custom data from a tile
var data = tilemap.get_cell_tile_data(0, Vector2i(5, 3))
if data and data.get_custom_data("is_hazard"):
    player.take_damage(data.get_custom_data("damage_amount"))
```

### 9.3 Parallax Layers

firstPunch's `background.js` renders a 3-layer parallax Downtown skyline. In Godot, use `ParallaxBackground` + `ParallaxLayer` nodes:

```gdscript
# Scene tree:
# ParallaxBackground
#   ParallaxLayer (far)    → motion_scale = Vector2(0.2, 0.0)
#   ParallaxLayer (mid)    → motion_scale = Vector2(0.5, 0.0)
#   ParallaxLayer (near)   → motion_scale = Vector2(0.8, 0.0)
```

Each `ParallaxLayer` contains a `Sprite2D` or `TextureRect`. Set `motion_mirroring` to the texture width for seamless looping. The camera automatically drives the scroll — no code needed.

### 9.4 Visual Level Editing

For a beat-em-up like firstPunch, combine TileMap painting with placed scene instances:
1. Paint ground/walls with TileMap.
2. Place spawn markers as `Marker2D` nodes at positions where enemies/items appear.
3. Use `Area2D` trigger zones for wave boundaries and camera locks.
4. Group all level content under a single scene (e.g., `level_downtown.tscn`).

This replaces the data-driven `levels.js` approach with a visual, WYSIWYG workflow.

---

## 10. Project Organization

### 10.1 Recommended Folder Structure

```
res://
├── addons/              # Third-party plugins
├── assets/
│   ├── sprites/         # .png spritesheets, atlases
│   ├── audio/
│   │   ├── sfx/         # .ogg/.wav sound effects
│   │   └── music/       # .ogg background tracks
│   └── fonts/           # .ttf/.otf
├── scenes/
│   ├── characters/      # player.tscn, enemy_*.tscn
│   ├── levels/          # level_downtown.tscn
│   ├── ui/              # hud.tscn, title_screen.tscn
│   └── effects/         # hit_effect.tscn, particles
├── scripts/
│   ├── autoload/        # global singletons
│   ├── components/      # reusable scripts (health, hitbox)
│   └── resources/       # custom Resource classes
├── resources/           # .tres files (tilesets, themes)
└── project.godot
```

### 10.2 Autoload Singletons

Register in **Project → Project Settings → Autoload**. These are always-available global nodes — equivalent to firstPunch's imported module instances.

Common autoloads for a beat-em-up:

| Autoload | Purpose | Replaces JS Module |
|----------|---------|-------------------|
| `GameManager` | Score, lives, difficulty, scene transitions | `game.js` globals |
| `AudioManager` | Play SFX/music, manage buses | `audio.js` + `music.js` |
| `EventBus` | Global signal hub | `events.js` |
| `Config` | Tuning constants | `config.js` |

```gdscript
# scripts/autoload/event_bus.gd
extends Node
signal enemy_hit(enemy, damage)
signal wave_cleared(wave_index)
signal player_died
```

Access from anywhere: `EventBus.enemy_hit.emit(self, 25)`

### 10.3 Resource Files (.tres)

Custom `Resource` classes store data that was previously in JS objects/JSON. They're serializable, inspector-editable, and memory-efficient (shared by reference).

```gdscript
# scripts/resources/enemy_data.gd
class_name EnemyData
extends Resource
@export var display_name: String
@export var max_hp: int = 50
@export var speed: float = 80.0
@export var attack_damage: int = 10
```

Create `.tres` files in the editor for each enemy variant (normal, tough, fast, heavy, boss) — replaces the template objects in `levels.js`.

### 10.4 Export Presets

Configure in **Project → Export**. Add presets for each target:
- **Web (HTML5)** — closest to current firstPunch deployment. Outputs `.html` + `.wasm` + `.pck`.
- **Windows/macOS/Linux** — desktop builds.
- **Android/iOS** — mobile (requires SDK setup).

Set export filters to include/exclude files, configure icons, and set feature tags. Run headless exports via CLI: `godot --headless --export-release "Web" build/index.html`.

---

## 11. Key Patterns

### 11.1 State Machine with Enum + Match

The core pattern for player/enemy behavior. Replaces firstPunch's string-based state checks in `player.js` and `enemy.js`.

```gdscript
enum State { IDLE, RUN, ATTACK, HURT, DEAD }
var state: State = State.IDLE

func _process(delta):
    match state:
        State.IDLE:
            _idle(delta)
        State.RUN:
            _run(delta)
        State.ATTACK:
            _attack(delta)
        State.HURT:
            _hurt(delta)
        State.DEAD:
            _dead(delta)

func change_state(new_state: State):
    state = new_state
```

For complex AI (enemy behavior trees in `ai.js`), consider the `StateChart` addon or a dedicated state-node approach where each state is a child `Node` with `enter()` / `exit()` / `update()` methods.

### 11.2 Object Pooling

Spawning/freeing nodes every frame is expensive. Pool reusable objects like particles, projectiles, and hit effects.

```gdscript
# scripts/autoload/pool.gd
extends Node
var _pools: Dictionary = {}

func get_node(scene: PackedScene, count: int = 10) -> Node:
    var key = scene.resource_path
    if key not in _pools:
        _pools[key] = []
        for i in count:
            var inst = scene.instantiate()
            inst.set_process(false)
            _pools[key].append(inst)
    if _pools[key].size() > 0:
        var n = _pools[key].pop_back()
        n.set_process(true)
        return n
    return scene.instantiate()  # fallback: create new

func release(node: Node, scene: PackedScene):
    node.set_process(false)
    node.get_parent().remove_child(node)
    _pools[scene.resource_path].append(node)
```

### 11.3 Scene Transitions

Replace `game.js` scene switching with a smooth fade transition autoload:

```gdscript
# scripts/autoload/scene_manager.gd
extends CanvasLayer
@onready var fade: ColorRect = $FadeRect

func change_scene(path: String, duration := 0.3):
    var tween = create_tween()
    tween.tween_property(fade, "color:a", 1.0, duration)
    await tween.finished
    get_tree().change_scene_to_file(path)
    tween = create_tween()
    tween.tween_property(fade, "color:a", 0.0, duration)
```

Call from anywhere: `SceneManager.change_scene("res://scenes/levels/level_1.tscn")`

### 11.4 Screen Shake & Hit Lag

firstPunch's `renderer.js` applies screen shake on hits; `combat.js` uses hit-stop frames. In Godot:

```gdscript
# Attach to Camera2D
func shake(intensity: float = 5.0, duration: float = 0.2):
    var tween = create_tween()
    for i in int(duration / 0.02):
        tween.tween_property(self, "offset",
            Vector2(randf_range(-1,1), randf_range(-1,1)) * intensity, 0.02)
    tween.tween_property(self, "offset", Vector2.ZERO, 0.02)

# Hit lag — freeze the tree briefly
func hit_lag(duration: float = 0.05):
    get_tree().paused = true
    await get_tree().create_timer(duration, true, false, true).timeout
    get_tree().paused = false
```

Set player/enemy `process_mode` to `PROCESS_MODE_ALWAYS` for nodes that should ignore the pause (e.g., the camera, UI).

---

## 12. Migration Mapping Table

Complete mapping of firstPunch's JS modules to their Godot 4 equivalents.

### 12.1 Engine Modules

| JS Module | Purpose | Godot Equivalent | Notes |
|-----------|---------|-------------------|-------|
| `engine/game.js` | Game loop, scene management | `SceneTree` + autoload `GameManager` | Godot runs the loop; autoload holds global state |
| `engine/renderer.js` | Canvas 2D drawing, camera, shake | `CanvasItem._draw()` + `Camera2D` | Use sprites/nodes instead of manual draw calls |
| `engine/animation.js` | Frame-based sprite animation | `AnimatedSprite2D` / `AnimationPlayer` | `AnimationPlayer` for complex multi-track timelines |
| `engine/input.js` | Keyboard + buffering | `InputMap` + `Input` singleton | See Section 7 for buffer pattern |
| `engine/audio.js` | Web Audio bus management | `AudioServer` + `AudioStreamPlayer` | See Section 8 |
| `engine/music.js` | Procedural oscillator music | `AudioStreamGenerator` or layered tracks | Oscillator approach possible but asset layers preferred |
| `engine/particles.js` | Particle emitter system | `GPUParticles2D` / `CPUParticles2D` | Built-in node with visual editor |
| `engine/sprite-cache.js` | Offscreen canvas caching | Not needed | Godot's renderer handles batching/caching internally |
| `engine/events.js` | Pub/sub event bus | Autoload with `signal` declarations | See `EventBus` in Section 10.2 |

### 12.2 Entity Modules

| JS Module | Purpose | Godot Equivalent | Notes |
|-----------|---------|-------------------|-------|
| `entities/player.js` | Player character | `CharacterBody2D` scene + GDScript | Scene with Sprite, AnimationPlayer, CollisionShape, Hitbox/Hurtbox Area2Ds |
| `entities/enemy.js` | Enemy variants + AI | `CharacterBody2D` scene + `EnemyData` Resource | One scene per variant or one scene driven by `.tres` data |
| `entities/destructible.js` | Breakable objects | `StaticBody2D` or `RigidBody2D` scene | HP component script, emits items on break |
| `entities/hazard.js` | Environmental hazards | `Area2D` with damage script | `body_entered` signal triggers damage |

### 12.3 System Modules

| JS Module | Purpose | Godot Equivalent | Notes |
|-----------|---------|-------------------|-------|
| `systems/ai.js` | Enemy behavior tree | State machine (enum+match) or `StateChart` addon | See Section 11.1 |
| `systems/combat.js` | Hit detection, damage | `Area2D` signals + combat autoload | Hitbox/hurtbox areas emit signals on overlap |
| `systems/camera.js` | Camera follow + lock | `Camera2D` with script | `position_smoothing`, `limit_*` properties built-in |
| `systems/background.js` | 3-layer parallax | `ParallaxBackground` + `ParallaxLayer` | See Section 9.3 |
| `systems/vfx.js` | Hit effects, trails | `GPUParticles2D` + `AnimationPlayer` | Tween-based screen effects |
| `systems/wave-manager.js` | Wave spawning + triggers | Autoload or level-local script + `Area2D` triggers | `Area2D` zones trigger spawns on player entry |

### 12.4 Scene / UI / Data Modules

| JS Module | Purpose | Godot Equivalent | Notes |
|-----------|---------|-------------------|-------|
| `scenes/gameplay.js` | Main gameplay scene | `gameplay.tscn` (root scene) | Scene tree replaces manual orchestration |
| `scenes/title.js` | Title screen | `title_screen.tscn` | `Control` nodes for menus |
| `scenes/options.js` | Options menu | `options.tscn` | `HSlider` for volume, `OptionButton` for difficulty |
| `ui/hud.js` | HUD rendering | `hud.tscn` (`CanvasLayer` + `Control`) | `Label`, `TextureProgressBar`, `Tween` for animations |
| `ui/highscore.js` | Persistent high scores | `ConfigFile` or `FileAccess` | `ConfigFile` saves to `user://` — survives exports |
| `data/levels.js` | Level/wave/enemy data | `.tres` Resource files + TileMap scenes | Visual editing replaces data arrays |
| `debug/debug-overlay.js` | FPS/debug info | Built-in **Debug → Monitors** or custom `CanvasLayer` | `Engine.get_frames_per_second()` for custom overlay |
| `config.js` | Tuning constants | Autoload `Config` or exported `Resource` | `@export` vars are inspector-editable |
| `main.js` | Bootstrap | `project.godot` + autoloads | Godot handles initialization automatically |

### 12.5 Quick-Reference Cheat Sheet

| JS Concept | Godot Equivalent |
|------------|-----------------|
| `requestAnimationFrame` | `_process(delta)` |
| `setInterval` / `setTimeout` | `Timer` node or `get_tree().create_timer()` |
| `canvas.getContext("2d")` | `CanvasItem._draw()` or Sprite nodes |
| `addEventListener("keydown")` | `_unhandled_input(event)` |
| `localStorage` | `ConfigFile` / `FileAccess` at `user://` |
| `new Audio()` | `AudioStreamPlayer` node |
| `OscillatorNode` | `AudioStreamGenerator` |
| `module.exports` / `import` | `class_name` + `preload()` / `load()` |
| `JSON.parse()` | `JSON.parse_string()` |
| `Math.random()` | `randf()` / `randi()` / `randf_range()` |
| `class` / `extends` | `class_name X extends Node` |
| `this` | `self` |
| `null` | `null` (same, but also check `is_instance_valid()`) |
| `console.log()` | `print()` / `push_warning()` / `push_error()` |
| `Promise` / `async-await` | `await signal` / `await coroutine()` |
