---
name: "project-conventions"
description: "GDScript style, file naming, scene conventions, folder structure, Git workflow, documentation, and review standards for First Frame Studios Godot 4 projects"
domain: "project-conventions"
confidence: "high"
source: "synthesized — from Godot 4 documentation, GDScript style guide, godot-tooling skill, and firstPunch lessons"
---

## When to Use This Skill
- Writing or reviewing any GDScript, scene, or resource file
- Creating new files, folders, or scenes in the project
- Making Git commits or branches
- Preparing work for review or merge
- Onboarding to a First Frame Studios Godot 4 project

## When NOT to Use This Skill
- Deciding game design or mechanics (that's Yoda/Solo territory)
- Building runtime engine systems (that's Chewie territory)
- Creating art or audio assets (that's Boba/Greedo territory)

---

## 1. GDScript Style Guide

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Variables | `snake_case` | `var move_speed` |
| Functions | `snake_case` | `func take_damage()` |
| Classes / class_name | `PascalCase` | `class_name EnemyGrunt` |
| Nodes (scene tree) | `PascalCase` | `HurtboxArea`, `AnimationPlayer` |
| Constants | `SCREAMING_SNAKE_CASE` | `const MAX_ENEMIES: int = 10` |
| Signals | `snake_case`, past tense | `signal health_changed` |
| Enums | `PascalCase` name, `SCREAMING_SNAKE` values | `enum State { IDLE, WALKING, ATTACKING }` |
| Groups | `snake_case` | `"enemies"`, `"destructibles"` |
| Private members | `_` prefix | `var _internal_timer: float` |

### Type Hints

Type hints are **required** on all function signatures and exported variables. They enable editor autocompletion and catch bugs at parse time.

```gdscript
# REQUIRED — always type function parameters and return values
func take_damage(amount: int, source: Node2D) -> void:
    pass

func get_health() -> int:
    return _current_health

# REQUIRED — always type exported variables
@export var move_speed: float = 150.0
@export var max_health: int = 100

# RECOMMENDED — type local variables when the type isn't obvious
var direction: Vector2 = Vector2.ZERO
var enemies: Array[Node2D] = []

# ACCEPTABLE — omit type when obvious from the literal
var is_dead = false
var count = 0
```

### Script Internal Ordering

Every GDScript file must follow this ordering:

```
1.  @tool (if applicable)
2.  class_name declaration
3.  extends statement
4.  ## Class doc-comment
5.  Signals
6.  Enums
7.  Constants
8.  @export variables
9.  Public variables
10. Private variables (_prefixed, @onready)
11. Built-in virtual methods (_ready, _process, _physics_process, _input)
12. Public methods
13. Private methods (_prefixed)
```

### Formatting Rules

- **Indentation:** Tabs (Godot default), not spaces.
- **Max line length:** 120 characters.
- **Blank lines:** Two blank lines before each function definition. One blank line between logical blocks inside a function.
- **Trailing commas:** Use trailing commas in multi-line arrays and dictionaries.
- **String quotes:** Use double quotes `"` for strings.
- **No semicolons.**

---

## 2. File Naming

| File Type | Convention | Example |
|-----------|-----------|---------|
| GDScript files | `snake_case.gd` | `enemy_grunt.gd`, `game_manager.gd` |
| Scene files | `PascalCase.tscn` | `EnemyGrunt.tscn`, `MainMenu.tscn` |
| Resource files | `snake_case.tres` | `grunt_stats.tres`, `main_theme.tres` |
| Shader files | `snake_case.gdshader` | `outline_effect.gdshader` |
| Image assets | `lowercase_snake_case.png` | `player_idle_spritesheet.png` |
| Audio assets | `lowercase_snake_case.wav/.ogg` | `punch_hit.wav`, `bg_level_01.ogg` |
| Font assets | `lowercase_snake_case.ttf/.otf` | `press_start_2p.ttf` |

**Rules:**
- Never use spaces or special characters in file names.
- Scene files match their root node's `class_name` when one is declared.
- Script files match the class they define: `class_name EnemyGrunt` → `enemy_grunt.gd`.

---

## 3. Scene Conventions

### One Root Node Per Scene
Every `.tscn` has exactly one root node. The root determines the scene's type and purpose.

### Script Attached to Root
The primary script is always attached to the root node. Child nodes should not have scripts unless they are self-contained reusable components (e.g., a `Healthbar.tscn` instanced as a child).

### Signal Documentation
All custom signals must be documented with `##` comments directly above the declaration:

```gdscript
## Emitted when this entity takes damage. [param amount] is the raw damage before mitigation.
signal damaged(amount: int, source: Node2D)

## Emitted when health reaches zero. Connected by GameManager for score tracking.
signal died
```

### Inherited Scenes
- Inherit from base templates in `templates/` — never build a scene from scratch if a template exists.
- Never delete nodes inherited from a base scene — only add or modify.
- Override points in base scenes are marked with `## OVERRIDE:` comments.

### Unique Names
- Mark key child nodes as "Access as Unique Name" in the editor so scripts reference them with `%NodeName` instead of fragile paths.
- Prefer `%UniqueNode` or `@export var` references over hard-coded `$"../../deep/path"` paths.

---

## 4. Folder Structure

The canonical `res://` layout for a First Frame Studios Godot 4 project:

```
res://
├── addons/                      # EditorPlugins and third-party addons
│   └── squad_tools/             # First Frame Studios editor tooling
│       ├── plugin.cfg
│       ├── squad_tools.gd
│       ├── inspectors/
│       ├── validators/
│       └── dock_panels/
├── autoloads/                   # Autoload singleton scripts (registered in project.godot)
│   ├── event_bus.gd
│   ├── game_state.gd
│   ├── scene_manager.gd
│   ├── audio_manager.gd
│   └── config.gd
├── scenes/                      # All .tscn scene files, organized by domain
│   ├── characters/
│   │   ├── player/
│   │   │   └── Player.tscn
│   │   └── enemies/
│   │       ├── EnemyGrunt.tscn
│   │       └── EnemyBoss.tscn
│   ├── levels/
│   │   ├── Level01.tscn
│   │   └── Level02.tscn
│   ├── ui/
│   │   ├── HUD.tscn
│   │   ├── MainMenu.tscn
│   │   └── PauseMenu.tscn
│   └── effects/
│       └── HitSpark.tscn
├── scripts/                     # Standalone .gd scripts not tied to a specific scene
│   ├── components/              # Reusable behavior scripts (state machines, AI)
│   │   ├── state_machine.gd
│   │   └── health_component.gd
│   └── data/                    # Custom Resource class definitions
│       ├── enemy_stats.gd
│       └── attack_data.gd
├── resources/                   # .tres resource instances (data, themes, materials)
│   ├── enemies/
│   │   ├── grunt_stats.tres
│   │   └── boss_stats.tres
│   ├── weapons/
│   │   ├── punch_data.tres
│   │   └── kick_data.tres
│   └── ui/
│       └── main_theme.tres
├── templates/                   # Base scenes for inheritance (owned by Jango)
│   ├── entities/
│   │   ├── entity_base.tscn
│   │   ├── enemy_base.tscn
│   │   └── player_base.tscn
│   ├── ui/
│   │   ├── panel_base.tscn
│   │   └── hud_element_base.tscn
│   ├── levels/
│   │   └── level_base.tscn
│   └── effects/
│       └── vfx_base.tscn
├── assets/                      # Raw art, audio, and font assets
│   ├── sprites/
│   │   ├── characters/
│   │   └── environment/
│   ├── audio/
│   │   ├── sfx/
│   │   └── music/
│   └── fonts/
├── shaders/                     # .gdshader files
├── export_presets.cfg           # Export presets (checked into version control)
├── project.godot                # Project configuration (owned by Jango)
└── .gdlintrc                    # GDScript lint configuration
```

**Rules:**
- `project.godot` is owned by Jango. Other agents request changes via decision inbox.
- `templates/` is owned by Jango. Agents inherit from templates, they don't modify them.
- Scenes and their scripts live together when the script is scene-specific. Standalone reusable scripts go in `scripts/`.
- Asset sub-folders mirror the domain structure (characters, environment, ui).
- Never put files in `res://` root except `project.godot`, `export_presets.cfg`, and config files.

---

## 5. Git Conventions

### .gitignore for Godot

```gitignore
# Godot 4 generated files
.godot/

# OS junk
.DS_Store
Thumbs.db

# Build output
build/
export/

# IDE / Editor
*.swp
*.swo
*~
.vscode/
.idea/

# Mono (if using C#)
.mono/
data_*/
```

**Tracked files that might seem generated:**
- `export_presets.cfg` — **DO track.** Export configuration must be shared.
- `*.import` — **DO track.** Godot's import metadata must be shared so assets reimport consistently.
- `.gdlintrc` — **DO track.** Linting config is shared.
- `.godot/` — **DO NOT track.** This is the local editor cache, unique per machine.

### Branch Naming

```
feature/{agent}-{short-description}     # New feature work
fix/{agent}-{short-description}          # Bug fixes
tooling/{agent}-{short-description}      # Tooling / infrastructure
refactor/{agent}-{short-description}     # Refactoring without behavior change

Examples:
  feature/chewie-player-movement
  fix/lando-hud-score-overflow
  tooling/jango-scene-validator
  refactor/solo-event-bus-cleanup
```

- Branch from `main` unless directed otherwise.
- Keep branches short-lived — merge or rebase within the session.
- Delete branches after merge.

### Commit Message Format

```
<type>(<scope>): <short summary>

<optional body — what and why, not how>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `tooling`

**Scope:** The affected area — `player`, `enemy`, `hud`, `event-bus`, `project-config`, `templates`, etc.

**Examples:**
```
feat(player): add punch combo with 3-hit chain

Implement PunchCombo state in state machine. Hitbox timing
synced to AnimationPlayer method tracks on frames 3, 8, 14.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

```
tooling(templates): create enemy_base.tscn with hurtbox wiring

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## 6. Code Documentation

### Class Documentation
Every script must begin with a `##` doc-comment block above the `class_name` or `extends` statement describing the class purpose:

```gdscript
## Controls enemy grunt behavior: patrol, chase, and melee attack.
##
## Inherits from EnemyBase. Override _on_entity_ready() to configure
## grunt-specific sprite and animation. Connects to EventBus for
## wave management signals.
class_name EnemyGrunt
extends EnemyBase
```

### Signal Documentation
Every custom signal must have a `##` comment explaining when it fires and what its parameters mean:

```gdscript
## Emitted when the grunt first spots the player. [param target] is the detected Player node.
signal alerted(target: Node2D)

## Emitted when the grunt's patrol route is completed. No parameters.
signal patrol_complete
```

### Exported Variable Documentation
Every `@export` variable must have a `##` comment explaining what it controls:

```gdscript
## Maximum distance (in pixels) at which the grunt detects the player.
@export var detection_range: float = 300.0

## Seconds between melee attacks. Lower = more aggressive.
@export_range(0.5, 3.0) var attack_cooldown: float = 1.5
```

### class_name Declarations
- Every script that will be referenced by type in other scripts **must** declare `class_name`.
- Every custom Resource script **must** declare `class_name` for inspector type safety.
- Utility scripts that are only `extends Node` and attached to a single scene may omit `class_name` if they are never referenced by type elsewhere.

### Inline Comments
- Use `#` for brief inline explanations of non-obvious logic.
- Do not comment obvious code (`health -= amount  # subtract amount from health`).
- Use `## OVERRIDE:` in base classes/templates to mark extension points.
- Use `# TODO:` for known incomplete work (include the agent name: `# TODO(chewie): add knockback direction`).

---

## 7. Review Checklist

Before submitting any work, verify every item:

### Code Quality
- [ ] GDScript lint passes with zero errors (warnings reviewed and justified)
- [ ] All function signatures have type hints (parameters and return type)
- [ ] All `@export` variables have `##` documentation comments
- [ ] Script follows the internal ordering convention (signals → enums → constants → exports → …)
- [ ] No unused variables, imports, or signals

### Scene Quality
- [ ] Scene has one root node with the primary script attached
- [ ] Scene inherits from the appropriate base template (if one exists)
- [ ] Node tree is organized hierarchically, not flat
- [ ] Key nodes marked as unique name where referenced from script
- [ ] No hard-coded deep node paths (`$"../../Player"`)
- [ ] Signals are connected via code (for dynamic nodes) or editor (for static nodes)

### Naming & Structure
- [ ] File names follow conventions (snake_case.gd, PascalCase.tscn, lowercase assets)
- [ ] Files are in the correct directory per folder structure
- [ ] Class names, variable names, and constants follow naming conventions
- [ ] New signals use past tense naming (`health_changed`, not `change_health`)

### Integration
- [ ] New systems are wired to at least one consumer (no orphaned infrastructure)
- [ ] Autoload changes are requested via decision inbox (not self-committed)
- [ ] `project.godot` changes reviewed and applied by Jango only
- [ ] New scenes tested — instantiate in editor and verify no errors in Output panel

### Git
- [ ] Commit message follows `<type>(<scope>): <summary>` format
- [ ] Branch named per convention (`feature/{agent}-{description}`)
- [ ] No `.godot/` directory or build artifacts in the commit
- [ ] `Co-authored-by` trailer included in commit message

---

## 8. Anti-Patterns

### ❌ The "Build It, Don't Wire It" Anti-Pattern
**What it looks like:** An agent creates a system (EventBus, SpriteCache, state machine) but never connects it to any consumer. The system exists but nothing uses it.
**Why it's bad:** firstPunch shipped with 214 LOC of working infrastructure that no agent integrated. Unwired code is dead code that creates false confidence.
**Do this instead:** Every new system must be connected to at least one consumer in the same PR. Include integration contracts as comments showing where and how to connect.

### ❌ The "Everyone Edits project.godot" Anti-Pattern
**What it looks like:** Multiple agents modify `project.godot` — autoload ordering conflicts, input map collisions, physics layer name overwrites.
**Why it's bad:** One wrong autoload edit breaks every agent. Merge conflicts in `project.godot` are silent and destructive.
**Do this instead:** Jango is the single owner of `project.godot`. Other agents request changes via the decision inbox.

### ❌ The "Magic Node Path" Anti-Pattern
**What it looks like:** Hard-coded deep paths like `$"../../World/Player/Sprite2D"` that break when any ancestor node is renamed or moved.
**Why it's bad:** Godot fails silently on invalid paths — returns `null`, causes cascade crashes later with no clear origin.
**Do this instead:** Use `%UniqueNode` names, `@onready var node := %NodeName`, or `@export var node: Node2D` for cross-scene references. Keep node references shallow.

### ❌ The "Flat Scene Tree" Anti-Pattern
**What it looks like:** All nodes dumped at the root level of a scene with no logical grouping.
**Why it's bad:** Makes the scene unreadable, node paths fragile, and refactoring impossible.
**Do this instead:** Group related nodes under named parents. Follow the hierarchy defined in base scene templates.

### ❌ The "Stringly Typed Signal" Anti-Pattern
**What it looks like:** Connecting signals via string names: `connect("my_signal", Callable(self, "_on_signal"))`.
**Why it's bad:** Typos in signal names fail silently at runtime. No autocompletion, no static analysis.
**Do this instead:** Use typed signal syntax: `my_signal.connect(_on_signal)`. Define signals with typed parameters.

### ❌ The "God Autoload" Anti-Pattern
**What it looks like:** A single autoload that handles game state, scene transitions, audio, scoring, input, and UI — hundreds of lines doing everything.
**Why it's bad:** Impossible to test, impossible to reason about, merge conflicts on every commit.
**Do this instead:** Keep autoloads thin and single-purpose. `EventBus` only declares signals. `GameState` only holds state. `SceneManager` only transitions scenes.

### ❌ The "Untyped Export" Anti-Pattern
**What it looks like:** `@export var speed = 100` with no type hint or documentation.
**Why it's bad:** The inspector shows the wrong widget (int vs float ambiguity), other agents don't know what the variable controls, and bugs hide.
**Do this instead:** `@export var speed: float = 100.0` with a `##` comment above it: `## Base movement speed in pixels per second.`

### ❌ The "_process for Everything" Anti-Pattern
**What it looks like:** All logic crammed into `_process(delta)` — movement, collision checks, UI updates, AI decisions.
**Why it's bad:** Movement and physics must run in `_physics_process` for deterministic behavior. Mixing them causes jitter, missed collisions, and frame-rate-dependent bugs.
**Do this instead:** Use `_physics_process` for movement, collision, and physics. Use `_process` for visuals and UI. Use signals and timers for event-driven logic.

---

## Examples

### Well-Structured GDScript File

```gdscript
## Manages a basic enemy grunt that patrols and attacks the player on sight.
##
## Inherits EnemyBase for health and damage systems. Uses a simple
## state machine for patrol/chase/attack behavior.
class_name EnemyGrunt
extends EnemyBase

## Emitted when this grunt first detects the player.
signal alerted(target: Node2D)

## Emitted when this grunt completes its patrol route.
signal patrol_complete

enum State { PATROL, CHASE, ATTACK, HURT, DEAD }

const ATTACK_RANGE: float = 45.0

## Maximum distance (in pixels) at which the grunt detects the player.
@export var detection_range: float = 300.0

## Seconds between melee swings.
@export_range(0.5, 3.0) var attack_cooldown: float = 1.5

var current_state: State = State.PATROL

@onready var _nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var _anim: AnimationPlayer = %AnimationPlayer
@onready var _attack_timer: Timer = %AttackTimer


func _ready() -> void:
    super()
    _attack_timer.wait_time = attack_cooldown
    _attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(delta: float) -> void:
    match current_state:
        State.PATROL:
            _do_patrol(delta)
        State.CHASE:
            _do_chase(delta)
        State.ATTACK:
            pass
    move_and_slide()


func alert(target: Node2D) -> void:
    current_state = State.CHASE
    alerted.emit(target)


func _do_patrol(delta: float) -> void:
    # Move along patrol waypoints
    pass


func _do_chase(delta: float) -> void:
    # Navigate toward player
    pass


func _on_attack_timer_timeout() -> void:
    current_state = State.ATTACK
    _anim.play("attack")
```
