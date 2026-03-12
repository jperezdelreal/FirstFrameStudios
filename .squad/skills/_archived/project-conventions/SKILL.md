---
name: "project-conventions"
description: "GDScript style, file naming, scene conventions, folder structure, Git workflow, documentation, and review standards for First Frame Studios Godot 4 projects"
domain: "project-conventions"
confidence: "high"
has_reference: true
source: "synthesized — from Godot 4 documentation, GDScript style guide, godot-tooling skill, and firstPunch lessons"
---

## Context

Defines all code style, naming, file structure, scene, Git, and documentation conventions for First Frame Studios Godot 4 projects. Every agent must follow these standards when writing GDScript, creating scenes, committing code, or submitting work for review. Full details, examples, and the review checklist are in REFERENCE.md.

## Core Patterns

### Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Variables / Functions | `snake_case` | `var move_speed`, `func take_damage()` |
| Classes / Nodes | `PascalCase` | `class_name EnemyGrunt`, `AnimationPlayer` |
| Constants | `SCREAMING_SNAKE_CASE` | `const MAX_ENEMIES: int = 10` |
| Signals | `snake_case`, past tense | `signal health_changed` |
| Private members | `_` prefix | `var _internal_timer: float` |

### File Naming
- Scripts: `snake_case.gd` — Scenes: `PascalCase.tscn` — Resources: `snake_case.tres`
- Assets (images/audio/fonts): `lowercase_snake_case` with appropriate extension
- Script files match their `class_name`: `class_name EnemyGrunt` → `enemy_grunt.gd`

### Script Structure (top → bottom)
`@tool` → `class_name` → `extends` → `## doc-comment` → signals → enums → constants → `@export` vars → public vars → private vars (`_`, `@onready`) → virtual methods → public methods → private methods

### Type Hints — Required
- All function parameters and return types must be typed
- All `@export` variables must be typed and have `##` doc-comments
- Local variables: type when not obvious from literal

### Scene Rules
- One root node per `.tscn`, primary script on root only
- Inherit from `templates/` base scenes — never build from scratch if a template exists
- Use `%UniqueNode` or `@export var` references — never hard-coded deep paths
- Document all custom signals with `##` comments

### Folder Structure (key directories)
- `autoloads/` — singleton scripts (thin, single-purpose)
- `scenes/` — `.tscn` files organized by domain (characters, levels, ui, effects)
- `scripts/` — standalone reusable `.gd` (components, data resources)
- `resources/` — `.tres` instances (stats, attack data, themes)
- `templates/` — base scenes for inheritance (owned by Jango)
- `assets/` — sprites, audio, fonts (mirrors domain structure)

### Git Conventions
- Branch: `feature/{agent}-{description}`, `fix/…`, `tooling/…`, `refactor/…`
- Commit: `<type>(<scope>): <summary>` + `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`
- Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `tooling`
- Track `export_presets.cfg`, `*.import`, `.gdlintrc` — never track `.godot/`

### Formatting
Tabs, 120-char max line, double quotes, trailing commas in multi-line collections, two blank lines before functions, no semicolons.

## Key Examples

```gdscript
## Manages enemy grunt: patrol, chase, melee attack.
class_name EnemyGrunt
extends EnemyBase

## Emitted when this grunt detects the player.
signal alerted(target: Node2D)

enum State { PATROL, CHASE, ATTACK, HURT, DEAD }
const ATTACK_RANGE: float = 45.0

## Max detection distance in pixels.
@export var detection_range: float = 300.0

var current_state: State = State.PATROL
@onready var _anim: AnimationPlayer = %AnimationPlayer


func _physics_process(delta: float) -> void:
    match current_state:
        State.PATROL:
            _do_patrol(delta)
        State.CHASE:
            _do_chase(delta)
    move_and_slide()


func _do_patrol(delta: float) -> void:
    pass
```

## Anti-Patterns

- **Build It, Don't Wire It** — Every new system must connect to ≥1 consumer in the same PR. No orphaned infrastructure.
- **Everyone Edits project.godot** — Only Jango owns `project.godot` and `templates/`. Others request changes via decision inbox.
- **Magic Node Paths** — Never use `$"../../deep/path"`. Use `%UniqueNode`, `@onready var := %Name`, or `@export var`.
- **Flat Scene Tree** — Group nodes hierarchically under named parents per base templates.
- **Stringly Typed Signals** — Use `signal.connect(callable)`, not string-based `connect()`.
- **God Autoload** — Keep autoloads single-purpose: EventBus, GameState, SceneManager each separate.
- **Untyped Exports** — Always type exports with `##` doc-comments: `@export var speed: float = 100.0`.
- **_process for Everything** — Physics/movement in `_physics_process`; visuals/UI in `_process`; events via signals/timers.