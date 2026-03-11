# Godot 4 Manual — Part 1 (Sections 1–6)

> Reference for firstPunch — a beat 'em up built with Godot 4 and GDScript.

---

## Section 1: Philosophy — "Everything is a Node"

Godot's core idea: **everything in your game is a Node**, and nodes compose into **Scenes** via a **Scene Tree**.

### The Scene Tree

The Scene Tree is a single rooted tree that holds every active node. The engine traverses it each frame to call lifecycle methods (`_process`, `_physics_process`), propagate input, and render. Nodes higher in the tree process first; children inherit their parent's transform.

### Node Types

Every node has a specific purpose. Key base types:

| Node | Purpose |
|------|---------|
| `Node2D` | Base for all 2D objects (position, rotation, scale) |
| `CharacterBody2D` | Kinematic body with `move_and_slide()` |
| `Area2D` | Overlap detection (hitboxes, triggers) |
| `Sprite2D` | Draws a texture |
| `AnimationPlayer` | Keyframe animation of any property |
| `Control` | Base for all UI elements |
| `Camera2D` | Viewport camera |

### Scene Instancing

A **Scene** is a saved branch of nodes (`.tscn` file). Scenes are reusable templates. You build a `Player.tscn` once, then **instance** it into `Main.tscn`. At runtime, instancing creates an independent copy:

```gdscript
var enemy_scene = preload("res://scenes/enemy.tscn")

func spawn_enemy(pos: Vector2) -> void:
    var enemy = enemy_scene.instantiate()
    enemy.position = pos
    add_child(enemy)
```

### Composition Over Inheritance

Godot favors **composition**: attach child nodes to add behavior. Need a hitbox? Add an `Area2D` child. Need health? Attach a script. Need animation? Add an `AnimationPlayer`. This keeps scenes modular and reusable—critical for a beat 'em up where players, enemies, and items share mechanics like health bars and knockback but differ in behavior.

**Rule of thumb:** If two scenes share behavior, extract that behavior into a child scene and instance it into both, rather than building an inheritance chain.

---

## Section 2: GDScript Basics

GDScript is Godot's built-in language — Python-like syntax, tightly integrated with the engine.

### Syntax Fundamentals

Indentation-based blocks. Variables use `var`, constants use `const`. Functions use `func`. No semicolons.

```gdscript
extends CharacterBody2D

const SPEED: float = 200.0

var health: int = 100
var is_attacking: bool = false

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
```

### Type Hints

Optional but strongly recommended. They enable editor autocompletion and catch bugs at parse time:

```gdscript
var direction: Vector2 = Vector2.ZERO
var enemies: Array[Node2D] = []
func get_damage() -> int:
    return 10
```

### @export and @onready

`@export` exposes a variable to the Inspector so designers can tweak values without touching code. `@onready` defers initialization until the node enters the tree:

```gdscript
@export var move_speed: float = 150.0
@export var max_health: int = 100
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
```

### Lifecycle Methods

| Method | When It Runs |
|--------|-------------|
| `_ready()` | Once, when node and children enter tree |
| `_process(delta)` | Every visual frame (~60/s) |
| `_physics_process(delta)` | Every physics tick (default 60/s, fixed) |
| `_input(event)` | On every input event |
| `_unhandled_input(event)` | Input not consumed by UI |

Use `_physics_process` for movement and collision; `_process` for visuals and UI updates.

### Key Differences from JavaScript

| GDScript | JavaScript |
|----------|-----------|
| `var` / `const` | `let` / `const` |
| Indentation scoping | Brace scoping |
| `func` | `function` / `=>` |
| `null` | `null` / `undefined` |
| `print()` | `console.log()` |
| `$NodeName` (shorthand for `get_node`) | `document.querySelector()` |
| Signals (observer) | `addEventListener` |
| No `this` keyword | `this` context |

---

## Section 3: Signals

Signals are Godot's implementation of the **Observer pattern** — a node emits a signal, and any connected node reacts without tight coupling.

### Built-in Signals

Most nodes ship with signals. Examples:

- `Area2D.body_entered(body)` — a physics body overlaps
- `Timer.timeout()` — timer expires
- `Button.pressed()` — UI button clicked
- `AnimationPlayer.animation_finished(anim_name)` — animation ends

### Custom Signals

Declare with `signal` at the top of your script:

```gdscript
signal health_changed(new_health: int)
signal died

func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        died.emit()
```

### Connecting Signals via Code

Use `.connect()` to wire signals at runtime. This is essential when instancing scenes dynamically (e.g., spawning enemies):

```gdscript
func _ready() -> void:
    var hurtbox: Area2D = $HurtboxArea
    hurtbox.area_entered.connect(_on_hurtbox_hit)

func _on_hurtbox_hit(area: Area2D) -> void:
    if area.is_in_group("enemy_hitbox"):
        take_damage(area.get_parent().attack_power)
```

You can also connect in the editor's Node tab — but code connections are preferred for dynamically spawned nodes.

### When to Use Signals vs Direct Calls

| Use Signals When… | Use Direct Calls When… |
|--------------------|------------------------|
| The emitter shouldn't know about the receiver | Parent calls a method on a known child |
| Multiple listeners need to react | Only one receiver, tightly coupled |
| Decoupling scenes (player doesn't import enemy) | Performance-critical per-frame logic |
| Broadcasting events (died, scored, combo_hit) | Simple parent → child communication |

**Beat 'em up example:** The player emits `died`, and the `GameManager`, `HUD`, and `CameraShake` nodes all listen — none of them are coupled to each other.

---

## Section 4: Scene Architecture for Beat 'Em Up

### Main Scene Tree Structure

```
Main (Node2D)
├── World (Node2D)
│   ├── Background (ParallaxBackground)
│   │   └── ParallaxLayer
│   │       └── Sprite2D
│   ├── YSortGroup (Node2D) [y_sort_enabled]
│   │   ├── Player (CharacterBody2D)  ← instanced
│   │   ├── Enemy1 (CharacterBody2D)  ← instanced
│   │   └── Enemy2 (CharacterBody2D)  ← instanced
│   └── Spawners (Node2D)
│       ├── EnemySpawner1 (Marker2D)
│       └── EnemySpawner2 (Marker2D)
├── HUD (CanvasLayer)
│   ├── HealthBar (TextureProgressBar)
│   └── ScoreLabel (Label)
├── Camera2D
└── GameManager (Node)
```

### Player Scene Internals (`Player.tscn`)

```
Player (CharacterBody2D)
├── Sprite2D (or AnimatedSprite2D)
├── CollisionShape2D          ← body collision
├── HitboxArea (Area2D)       ← deals damage
│   └── CollisionShape2D
├── HurtboxArea (Area2D)      ← receives damage
│   └── CollisionShape2D
├── AnimationPlayer
└── AttackTimer (Timer)
```

The `HitboxArea` is only enabled during attack frames. The `HurtboxArea` is always active and listens for enemy hitboxes via `area_entered`.

### Enemy Instancing

Enemies are preloaded scenes spawned at runtime from `Marker2D` positions:

```gdscript
# game_manager.gd
@export var enemy_scene: PackedScene
@onready var y_sort: Node2D = %YSortGroup

func spawn_wave(positions: Array[Vector2]) -> void:
    for pos in positions:
        var enemy = enemy_scene.instantiate()
        enemy.position = pos
        enemy.died.connect(_on_enemy_died)
        y_sort.add_child(enemy)
```

The `YSortGroup` node sorts children by Y position so characters closer to the bottom render in front — essential for beat 'em up depth.

---

## Section 5: Physics & Collision

### Body Types

| Type | Use Case | Movement |
|------|----------|----------|
| `CharacterBody2D` | Player, enemies — controlled movement | `move_and_slide()` |
| `RigidBody2D` | Physics-driven objects (barrels, debris) | Forces & impulses |
| `Area2D` | Hitboxes, hurtboxes, triggers, pickups | No physics movement |

For a beat 'em up, players and enemies are `CharacterBody2D`. Thrown objects may be `RigidBody2D`. All combat detection uses `Area2D`.

### Collision Layers & Masks

Layers define what a body **is**. Masks define what it **scans for**.

| Layer | Name | Used By |
|-------|------|---------|
| 1 | World | Walls, ground boundaries |
| 2 | Player Body | Player's `CharacterBody2D` |
| 3 | Enemy Body | Enemy's `CharacterBody2D` |
| 4 | Player Hitbox | Player attack `Area2D` |
| 5 | Enemy Hitbox | Enemy attack `Area2D` |
| 6 | Player Hurtbox | Player damage receiver |
| 7 | Enemy Hurtbox | Enemy damage receiver |

Player hitbox (layer 4) masks layer 7 (enemy hurtbox). Enemy hitbox (layer 5) masks layer 6 (player hurtbox). This way, attacks only detect valid targets.

### move_and_slide()

The primary movement method for `CharacterBody2D`. Set `velocity`, then call it:

```gdscript
# player.gd
func _physics_process(delta: float) -> void:
    var input := Vector2(
        Input.get_axis("move_left", "move_right"),
        Input.get_axis("move_up", "move_down")
    )
    velocity = input.normalized() * move_speed
    move_and_slide()
```

### Hitbox/Hurtbox Pattern with Area2D

```gdscript
# In player.gd — enable hitbox only during attack
func attack() -> void:
    $HitboxArea/CollisionShape2D.disabled = false
    $AnimationPlayer.play("punch")
    await $AnimationPlayer.animation_finished
    $HitboxArea/CollisionShape2D.disabled = true

# In enemy.gd — detect incoming damage
func _ready() -> void:
    $HurtboxArea.area_entered.connect(_on_hurt)

func _on_hurt(hitbox: Area2D) -> void:
    var damage: int = hitbox.get_parent().attack_power
    take_damage(damage)
```

---

## Section 6: Animation System

### AnimationPlayer

The most powerful animation node. It keyframes **any property** on any node — position, modulate (color), `CollisionShape2D.disabled`, custom script variables. One `AnimationPlayer` can drive sprite frames, hitbox timing, and sound effects in a single timeline.

```gdscript
@onready var anim: AnimationPlayer = $AnimationPlayer

func play_animation(name: String) -> void:
    if anim.current_animation != name:
        anim.play(name)
```

### AnimatedSprite2D

Simpler alternative for frame-based animation. Define animations in a `SpriteFrames` resource with named sequences (idle, walk, punch). Good for quick prototyping:

```gdscript
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
    if velocity.length() > 0:
        sprite.play("walk")
    else:
        sprite.play("idle")
    if velocity.x != 0:
        sprite.flip_h = velocity.x < 0
```

### AnimationTree

For complex state-based animation blending. Uses a **state machine** to transition between animations with conditions. Ideal when a character has many states (idle, walk, attack, hurt, die) and transitions need rules:

```
AnimationTree
├── StateMachine
│   ├── Idle → Walk (velocity > 0)
│   ├── Walk → Idle (velocity == 0)
│   ├── Any → Attack (attack_trigger)
│   ├── Any → Hurt (hurt_trigger)
│   └── Hurt → Idle (auto)
```

Control it from code by setting parameters:

```gdscript
@onready var anim_tree: AnimationTree = $AnimationTree

func _physics_process(delta: float) -> void:
    anim_tree.set("parameters/conditions/is_moving", velocity.length() > 0)
    anim_tree.set("parameters/conditions/is_idle", velocity.length() == 0)
```

### Animation Events (Method Tracks)

`AnimationPlayer` supports **Call Method** tracks — fire a function at a specific keyframe. Use this to enable/disable hitboxes at exact attack frames:

- Frame 3 of "punch": call `enable_hitbox()`
- Frame 6 of "punch": call `disable_hitbox()`

This keeps combat timing synchronized with visuals without manual timers.

### Sprite Sheets

Load a sprite sheet into `Sprite2D`, set `hframes` and `vframes` to define the grid, then animate the `frame` property with `AnimationPlayer`. For `AnimatedSprite2D`, import frames into a `SpriteFrames` resource directly. Godot's import system can auto-slice grid-based sheets.

---

*Part 2 continues with Input Handling, State Machines, UI, Audio, and Resource Management.*
