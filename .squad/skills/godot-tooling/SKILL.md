# SKILL: Godot Tooling & Development Infrastructure

Patterns for building development-time tooling in Godot 4 — EditorPlugins, scene templates, autoload singletons, GDScript conventions, resource organization, and build/export automation.

---
name: "godot-tooling"
description: "Godot 4 development tooling — EditorPlugins, scene templates, autoloads, GDScript style guide, build automation"
domain: "game-engine-tooling"
confidence: "low"
source: "synthesized — from Godot 4 documentation, firstPunch lessons (unwired infrastructure pattern), and team coordination analysis"
---

## When to Use This Skill
- Setting up a new Godot 4 project for multi-agent development
- Creating scene templates or base classes that other agents will inherit
- Building EditorPlugins for validation, custom inspectors, or workflow tools
- Establishing or enforcing GDScript style and naming conventions
- Configuring asset import pipelines, export presets, or CI/CD
- Debugging "silent failure" issues (null node paths, unconnected signals)

## When NOT to Use This Skill
- Implementing game logic or mechanics (that's Chewie/Lando territory)
- Creating art assets or audio (that's Boba/Greedo territory)
- Making game design decisions (that's Yoda/Solo territory)
- Runtime performance optimization (that's Chewie territory)

---

## Core Patterns

### 1. EditorPlugin Architecture

EditorPlugins live in `addons/{plugin_name}/` and extend the Godot editor with custom functionality.

**Directory structure:**
```
addons/
  squad_tools/
    plugin.cfg          # Plugin metadata (required)
    squad_tools.gd      # Main plugin script (extends EditorPlugin)
    inspectors/         # Custom inspector plugins
    validators/         # Scene/script validation tools
    dock_panels/        # Custom dock UI panels
    gizmos/             # Custom spatial gizmos
```

**Plugin lifecycle:**
```gdscript
@tool
extends EditorPlugin

func _enter_tree() -> void:
    # Register inspectors, dock panels, autoloads
    add_custom_type("EnemyBase", "CharacterBody2D", preload("res://templates/enemy_base.gd"), preload("res://icon.svg"))
    add_control_to_dock(DOCK_SLOT_RIGHT_UL, _create_validation_panel())

func _exit_tree() -> void:
    # Clean up everything registered in _enter_tree
    remove_custom_type("EnemyBase")
    remove_control_from_docks(_validation_panel)
```

**Key rules:**
- Always use `@tool` annotation — EditorPlugins run in the editor, not the game
- Always clean up in `_exit_tree()` — every `add_*` must have a matching `remove_*`
- Use `EditorInterface` to access editor state (edited scene, selected nodes, file system)
- Use `EditorUndoRedoManager` for any modifications to support undo/redo

### 2. Scene Template Conventions

Scene templates are base scenes that agents inherit rather than building from scratch. This prevents architectural drift and ensures consistency.

**Template hierarchy:**
```
templates/
  entities/
    entity_base.tscn        # Root: CharacterBody2D + CollisionShape2D + AnimatedSprite2D
    enemy_base.tscn          # Inherits entity_base, adds AI + health + hurt_box
    player_base.tscn         # Inherits entity_base, adds input + state_machine
  ui/
    panel_base.tscn          # Root: PanelContainer + MarginContainer + VBoxContainer
    hud_element_base.tscn    # Root: Control with anchors preset
  levels/
    level_base.tscn          # Root: Node2D + TileMapLayer + Camera2D + UI layer
  effects/
    vfx_base.tscn            # Root: Node2D + GPUParticles2D + Timer (auto-free)
```

**Inherited scene rules:**
- Base scenes define the **required node structure** — child scenes add specifics
- Mark override points with comments: `## OVERRIDE: Add enemy-specific sprites here`
- Never delete nodes from a base scene in an inherited scene — only add or modify
- Base scene scripts should use virtual methods (prefix with `_`) that children override:

```gdscript
# entity_base.gd
class_name EntityBase
extends CharacterBody2D

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health
    _on_entity_ready()  # Virtual — children override this

func take_damage(amount: int, source: Node2D) -> void:
    current_health -= amount
    _on_damage_taken(amount, source)  # Virtual
    if current_health <= 0:
        _on_death()  # Virtual

func _on_entity_ready() -> void:
    pass  # Override in children

func _on_damage_taken(_amount: int, _source: Node2D) -> void:
    pass  # Override in children

func _on_death() -> void:
    queue_free()  # Default behavior, override for custom death
```

### 3. Autoload Singleton Patterns

Autoloads are globally accessible singletons registered in `project.godot`. They persist across scene changes.

**Standard autoloads:**
```
# project.godot [autoload] section
EventBus = "*res://autoloads/event_bus.gd"
GameState = "*res://autoloads/game_state.gd"
SceneManager = "*res://autoloads/scene_manager.gd"
AudioManager = "*res://autoloads/audio_manager.gd"
Config = "*res://autoloads/config.gd"
```

**EventBus pattern (typed signals):**
```gdscript
# autoloads/event_bus.gd
extends Node

# Combat events
signal enemy_damaged(enemy: Node2D, amount: int, source: Node2D)
signal enemy_killed(enemy: Node2D, killer: Node2D)
signal player_damaged(amount: int, source: Node2D)

# Game flow events
signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal level_completed()

# UI events
signal score_changed(new_score: int)
signal health_changed(current: int, maximum: int)
```

**Key rules:**
- Autoloads are the ONLY global state — no other globals allowed
- Use typed signals with descriptive parameter names
- Autoload scripts should be pure logic — no `@onready` node references (they have no scene tree parent)
- Keep autoloads thin — they coordinate, they don't implement game logic
- Prefix autoload access with the registered name: `EventBus.enemy_damaged.emit(self, 10, attacker)`

### 4. Resource File Organization

Godot resources (`.tres`, `.res`) are data files that can be shared across scenes.

**Directory structure:**
```
resources/
  enemies/
    grunt_stats.tres         # Custom Resource: EnemyStats
    boss_stats.tres
  weapons/
    punch_data.tres          # Custom Resource: AttackData
    kick_data.tres
  ui/
    main_theme.tres          # Theme resource
    hud_theme.tres
  audio/
    sfx_bus_layout.tres      # AudioBusLayout
```

**Custom Resource pattern:**
```gdscript
# resources/scripts/enemy_stats.gd
class_name EnemyStats
extends Resource

@export var display_name: String = ""
@export var max_health: int = 100
@export var move_speed: float = 100.0
@export var attack_damage: int = 10
@export var attack_range: float = 50.0
@export_range(0.1, 3.0) var attack_cooldown: float = 1.0
@export var drop_table: Array[PackedScene] = []
```

**Key rules:**
- Use custom Resources for data that designers/content devs need to tweak (enemy stats, weapon data, wave definitions)
- Resources are cheaper than scenes — use them for pure data, scenes for anything with nodes
- Always define `class_name` on custom resources for type safety in the inspector
- Use `@export_range`, `@export_enum`, `@export_file` for inspector UX

### 5. GDScript Style Guide

**Naming conventions:**
```
Files:         snake_case.gd, snake_case.tscn
Classes:       PascalCase (class_name PlayerController)
Functions:     snake_case (func take_damage())
Variables:     snake_case (var max_health)
Constants:     SCREAMING_SNAKE (const MAX_ENEMIES)
Signals:       snake_case, past tense (signal health_changed)
Enums:         PascalCase name, SCREAMING_SNAKE values
Nodes:         PascalCase in scene tree (AnimatedSprite2D, HurtBox)
Groups:        snake_case ("enemies", "destructibles")
```

**Typing rules:**
```gdscript
# ALWAYS type function signatures
func take_damage(amount: int, source: Node2D) -> void:

# ALWAYS type exported variables
@export var speed: float = 200.0

# Type local variables when the type isn't obvious
var direction: Vector2 = Vector2.ZERO
var enemies: Array[Enemy] = []

# Okay to omit type when obvious from assignment
var is_dead = false  # clearly bool
var count = 0        # clearly int
```

**Documentation standards:**
```gdscript
## A brief description of the class.
##
## A longer description if needed, explaining the purpose
## and how this class fits into the game architecture.
class_name EnemyGrunt
extends EnemyBase

## Emitted when the grunt enters alert state.
signal alerted(target: Node2D)

## Maximum distance at which the grunt can detect the player.
@export var detection_range: float = 300.0
```

**Organization within a file:**
```
1. @tool (if applicable)
2. class_name
3. extends
4. ## Class documentation
5. Signals
6. Enums
7. Constants
8. @export variables
9. Public variables
10. Private variables (@onready, internal state)
11. Built-in virtual methods (_ready, _process, _physics_process)
12. Public methods
13. Private methods (prefixed with _)
```

### 6. Build/Export Automation

**Export presets structure:**
```
# export_presets.cfg — checked into version control
[preset.0]
name = "Web"
platform = "Web"
custom_features = ""
export_filter = "all_resources"

[preset.1]
name = "Windows Desktop"
platform = "Windows Desktop"
```

**CI/CD pipeline (GitHub Actions):**
```yaml
# .github/workflows/godot-build.yml
name: Godot Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.3
    steps:
      - uses: actions/checkout@v4
      - name: Import assets
        run: godot --headless --import
      - name: Run GDScript lint
        run: gdlint .
      - name: Export Web build
        run: godot --headless --export-release "Web" build/web/index.html
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: web-build
          path: build/web/
```

**GDScript linting (`.gdlintrc`):**
```ini
[general]
max-line-length = 120
tab-size = 4

[naming]
class-name-regex = "([A-Z][a-z]+)+"
function-name-regex = "[a-z][a-z0-9_]*"
variable-name-regex = "[a-z][a-z0-9_]*"
constant-name-regex = "[A-Z][A-Z0-9_]*"
signal-name-regex = "[a-z][a-z0-9_]*"
```

---

## Anti-Patterns

### 1. The "Build It, Don't Wire It" Anti-Pattern
**Problem:** Agent creates a system (EventBus, SpriteCache) but doesn't connect it to any consumer. Infrastructure exists but is unused.
**Fix:** Every template/tool PR must include wiring into at least one consumer. Template scripts include integration contracts as comments showing where and how to connect.

### 2. The "Everyone Owns project.godot" Anti-Pattern
**Problem:** Multiple agents edit `project.godot` — autoload order conflicts, input map collisions, layer name overwrites.
**Fix:** Single owner (Jango). Other agents request changes via decision inbox. Jango validates and applies.

### 3. The "Flat Scene Tree" Anti-Pattern
**Problem:** All nodes dumped at the root of a scene with no grouping. Makes refactoring impossible and node paths fragile.
**Fix:** Scene templates enforce node hierarchy. Base scenes define the required structure. EditorPlugin validates scene tree depth and grouping.

### 4. The "Stringly Typed Signal" Anti-Pattern
**Problem:** Signals connected via string names in code (`connect("my_signal", callable)`) — typos fail silently.
**Fix:** Use typed signal syntax: `my_signal.connect(_on_signal)`. Define signals with typed parameters. EditorPlugin validates signal connections at save time.

### 5. The "Magic Node Path" Anti-Pattern
**Problem:** Hard-coded node paths (`$"../../Player/Sprite2D"`) that break when scene structure changes.
**Fix:** Use `@onready` with `%UniqueNode` syntax. Mark important nodes as "unique name" in the editor. Or pass node references via `@export var` for cross-scene references.

---

## Checklists

### New Project Setup Checklist
- [ ] `project.godot` configured (window size, stretch mode, physics layers, input map)
- [ ] Autoload singletons created and registered (EventBus, GameState, SceneManager)
- [ ] Directory structure created (`scenes/`, `scripts/`, `resources/`, `addons/`, `autoloads/`, `templates/`, `assets/`)
- [ ] Base scene templates created (entity, enemy, player, UI panel, level, VFX)
- [ ] GDScript style guide documented and `.gdlintrc` configured
- [ ] Export presets configured (at minimum: Web)
- [ ] `.gitignore` configured for Godot (`.godot/`, `*.import` in assets)
- [ ] CI/CD pipeline configured (lint + export)
- [ ] EditorPlugin skeleton created in `addons/squad_tools/`

### Scene Template Review Checklist
- [ ] Base scene has clear node hierarchy (not flat)
- [ ] Override points documented with `## OVERRIDE:` comments
- [ ] Script uses virtual methods for extension points
- [ ] Required signals defined with typed parameters
- [ ] `@export` variables have sensible defaults
- [ ] Inherited scenes tested — instantiate and verify no errors

### EditorPlugin Review Checklist
- [ ] Uses `@tool` annotation
- [ ] `_exit_tree()` cleans up everything registered in `_enter_tree()`
- [ ] Uses `EditorUndoRedoManager` for modifications
- [ ] Doesn't crash on edge cases (empty scene, no selection)
- [ ] Has a way to disable/enable without uninstalling
- [ ] Tested with both new and existing project scenes

### Pre-Commit Quality Gate Checklist
- [ ] GDScript lint passes (no errors, warnings reviewed)
- [ ] Scene validation passes (required nodes present, naming correct)
- [ ] No orphaned signals (connected signals have valid targets)
- [ ] No magic node paths (all paths use `%UniqueNode` or `@export`)
- [ ] `project.godot` changes reviewed by Jango (if any)
- [ ] New scenes inherit from appropriate base template
