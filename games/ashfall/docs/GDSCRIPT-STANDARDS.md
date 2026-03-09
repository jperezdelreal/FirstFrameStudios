# GDScript Coding Standards — Ashfall (Godot 4.6)

> Rules derived from Sprint 1 bugs. Every rule has a "Why" that links to the bug it prevents.

**Target:** Godot 4.6.x (config_version=5)  
**Maintained by:** Jango (Tool Engineer)  
**Last Updated:** 2026-03-11  
**Status:** **MANDATORY** for Sprint 2+

---

## How to Use This Document

1. **Read before writing Sprint 2 code** — 10 minutes now saves 3 hours of debugging later
2. **Reference during code review** — Jango will flag violations in PR comments
3. **Update when new patterns emerge** — Add lessons from future sprints
4. **Link bugs to rules** — Every rule cites the Sprint 1 commit/issue that motivated it

**Symbol Legend:**
- ✅ **CORRECT** — Follow this pattern
- ❌ **WRONG** — Avoid this pattern (will cause bugs)
- ⚠️ **CAUTION** — Works but risky; use with care

---

## Critical Rules (Violation = Bug)

### Rule 1: Never Use `:=` for Dictionary/Array/abs() Values

**Why:** Godot 4.6 type inference fails silently. `:=` from `dict["key"]`, `array[0]`, or `abs(x)` produces `Variant` instead of the expected type. Causes runtime errors in exports, null references, and function signature mismatches.

**Sprint 1 bugs:** Commits `6076e0c`, `e76e2c6`, `f54779d`, `c6fdc1c`, `21df376` (10 emergency fixes in v0.2.0)

#### Dictionary Access

```gdscript
# ❌ WRONG — var fc is Variant, not Color
var palette := {"flash_color": Color.RED}
var fc := palette["flash_color"]

# ✅ CORRECT — explicit type annotation
var palette := {"flash_color": Color.RED}
var fc: Color = palette["flash_color"]
```

**Affected files in Sprint 1:** `vfx_manager.gd`, `character_select.gd`

#### Array Access

```gdscript
# ❌ WRONG — var player is Variant, not AudioStreamPlayer
var player := _sfx_pool[_sfx_pool_index]

# ✅ CORRECT — explicit type annotation
var player: AudioStreamPlayer = _sfx_pool[_sfx_pool_index]
```

**Affected files in Sprint 1:** `audio_manager.gd`, `round_manager.gd`

#### Math Operations

```gdscript
# ❌ WRONG — var grab_offset is Variant (40.0 * Variant = Variant)
var grab_offset := 40.0 * fighter.facing_direction

# ✅ CORRECT — explicit float type
var grab_offset: float = 40.0 * fighter.facing_direction
```

**Affected files in Sprint 1:** `throw_state.gd` (2 instances)

#### Function Returns Without Explicit Type

```gdscript
# ❌ WRONG — to_int() returns Variant if not declared
var round_num := parts[1].to_int()

# ✅ CORRECT — explicit type
var round_num: int = parts[1].to_int()
```

**Affected files in Sprint 1:** `audio_manager.gd`, `round_manager.gd`

---

### Rule 2: Use Type-Specific Math Functions (absf/absi, not abs)

**Why:** `abs()` returns `Variant` for legacy compatibility. Godot 4.6 has type-specific versions that return concrete types.

**Sprint 1 bugs:** Commit `c6fdc1c` (throw_state.gd float inference failure)

```gdscript
# ❌ WRONG — abs() returns Variant
var dist := abs(fighter.global_position.x - opp.global_position.x)

# ✅ CORRECT — absf() returns float
var dist: float = absf(fighter.global_position.x - opp.global_position.x)
```

**Type-Specific Math Functions:**
| Generic (Variant) | Float-Specific | Int-Specific | Return Type |
|-------------------|----------------|--------------|-------------|
| `abs(x)` | `absf(x)` | `absi(x)` | float / int |
| `min(a, b)` | `minf(a, b)` | `mini(a, b)` | float / int |
| `max(a, b)` | `maxf(a, b)` | `maxi(a, b)` | float / int |
| `clamp(x, a, b)` | `clampf(x, a, b)` | `clampi(x, a, b)` | float / int |

**Rule:** Always use the typed version (`*f` or `*i`) unless you explicitly need Variant polymorphism.

---

### Rule 3: Explicit Return Types on All Functions

**Why:** Function return type inference is unreliable in Godot 4.6. Omitting `-> Type` makes the return value `Variant`, breaking type safety downstream.

**Sprint 1 bugs:** Multiple functions returned Variant unintentionally, caught during v0.2.0 proactive fixes

```gdscript
# ❌ WRONG — return type is Variant
func get_distance(a, b):
    return abs(a - b)

# ✅ CORRECT — explicit return type
func get_distance(a: float, b: float) -> float:
    return absf(a - b)
```

**Exception:** `_init()`, `_ready()`, `_process()` — Godot virtual functions don't need `-> void` (but it's fine to add).

---

### Rule 4: Never Override Engine Built-In Input Actions

**Why:** Overriding `ui_accept`, `ui_cancel`, `ui_left`, `ui_right`, `ui_up`, `ui_down` in `project.godot` replaces Godot's hardcoded defaults. Custom overrides with `physical_keycode:0`/`keycode:0` work in editor but break in Windows exports.

**Sprint 1 bugs:** Commit `c72cd81` — character select keyboard broken in exports after custom `ui_*` actions added

```ini
# ❌ WRONG — overrides break exports
[input]
ui_accept={
"events": [Object(InputEventKey, "physical_keycode":0, "keycode":16777221)]
}

# ✅ CORRECT — use engine defaults, add game-specific actions
[input]
p1_punch={...}
p1_kick={...}
# Leave ui_* actions untouched
```

**Engine Built-Ins (Do NOT Override):**
- `ui_accept` — Enter, Space, Joypad A
- `ui_cancel` — Escape, Joypad B
- `ui_left` / `ui_right` / `ui_up` / `ui_down` — Arrow keys, D-pad
- `ui_page_up` / `ui_page_down` — Page Up/Down
- `ui_home` / `ui_end` — Home/End

**If you need custom menu navigation:** Use `Button` nodes with `grab_focus()` and `focus_neighbor_*` properties (see Rule 5).

---

### Rule 5: Use Button Nodes for Menus, Not Custom _input()

**Why:** Custom `_input()` with `InputEventKey` bypasses Godot's focus system. Works with keyboard in editor but fails in exports, doesn't support controllers, and breaks accessibility.

**Sprint 1 bugs:** 6 PRs over 10 days to fix character select input (commits `c476a0b`, `7e3f67e`, `c552290`, `7a5f3d4`, `c72cd81`, `2655e2b`)

```gdscript
# ❌ WRONG — custom keycode handling
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ENTER:
            _on_select()

# ✅ CORRECT — native Button with signals
@onready var button := $SelectButton

func _ready() -> void:
    button.pressed.connect(_on_select)
    button.grab_focus()  # Handles keyboard + controller + accessibility
```

**Menu Input Pattern (Follow main_menu.gd):**

```gdscript
# 1. Define Button nodes in scene
@onready var start_button := $Panel/VBox/StartButton
@onready var options_button := $Panel/VBox/OptionsButton
@onready var quit_button := $Panel/VBox/QuitButton

func _ready() -> void:
    # 2. Connect signals
    start_button.pressed.connect(_on_start)
    options_button.pressed.connect(_on_options)
    quit_button.pressed.connect(_on_quit)
    
    # 3. Set focus neighbors for arrow key navigation
    start_button.focus_neighbor_bottom = options_button.get_path()
    options_button.focus_neighbor_top = start_button.get_path()
    options_button.focus_neighbor_bottom = quit_button.get_path()
    quit_button.focus_neighbor_top = options_button.get_path()
    
    # 4. Grab focus on first button
    start_button.grab_focus()

# 5. Handle Escape in _unhandled_input (after focus system)
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        _on_back()
        get_viewport().set_input_as_handled()
```

**Why This Works:**
- Godot handles Enter, Space, arrows, Escape, and controller automatically
- Focus system provides visual feedback (outline/highlight)
- Works in editor and exports identically
- Supports keyboard, mouse, controller, and accessibility tools

---

### Rule 6: Prefix Custom Draw Methods with Underscore

**Why:** `Node2D` has built-in `draw_*` methods. Custom methods with the same name shadow them, causing method signature mismatches in exports.

**Sprint 1 bugs:** Commit `21df376` — `draw_ellipse()` shadowed `Node2D.draw_ellipse()`, broke exports with 94 call site failures

```gdscript
# ❌ WRONG — shadows Node2D.draw_ellipse()
func draw_ellipse(center: Vector2, rx: float, ry: float) -> void:
    # Custom implementation
    pass

# ✅ CORRECT — clearly custom, no shadowing
func _draw_ellipse_outlined(center: Vector2, rx: float, ry: float) -> void:
    # Custom implementation
    pass
```

**Node2D Built-In Draw Methods (Do NOT Shadow):**
- `draw_line()`, `draw_rect()`, `draw_circle()`, `draw_arc()`, `draw_polygon()`
- `draw_polyline()`, `draw_string()`, `draw_char()`, `draw_mesh()`, `draw_texture()`
- `draw_ellipse()` ← **Caught in Sprint 1**

**Rule:** Always prefix custom draw helpers with `_` to avoid conflicts.

---

### Rule 7: Frame-Based Timing Only (No Float Timers in Gameplay)

**Why:** Fighting game architecture requires deterministic integer frame counters at 60 FPS. Float timers introduce non-determinism that breaks replay, rollback netcode, and combo consistency.

**Sprint 1 bugs:** Issue #65 — `attack_state.gd` line 48 used `fighter.gravity / 60.0` (float division)

```gdscript
# ❌ WRONG — float timer
var time_in_state: float = 0.0

func _physics_process(delta: float) -> void:
    time_in_state += delta
    if time_in_state >= 0.5:  # Non-deterministic
        _transition()

# ✅ CORRECT — frame counter
var frames_in_state: int = 0

func _physics_process(_delta: float) -> void:
    frames_in_state += 1
    if frames_in_state >= 30:  # 30 frames = 0.5s at 60 FPS
        _transition()
```

**Physics Process Pattern:**

```gdscript
func _physics_process(_delta: float) -> void:
    # Ignore delta in gameplay code (always 1/60)
    frames_in_state += 1
    
    # Integer division for frame-based math
    if not fighter.is_on_floor():
        fighter.velocity.y += int(fighter.gravity) / 60  # Not / 60.0
    
    # Frame-based phase transitions (startup/active/recovery)
    if frames_in_state == move_data.startup:
        _activate_hitbox()
    elif frames_in_state == move_data.startup + move_data.active:
        _deactivate_hitbox()
```

**Delta Usage Rule:**
- ✅ **Use delta:** Visual interpolation (`position.x = lerp(a, b, delta * speed)`)
- ✅ **Use delta:** Camera smoothing, particle lifetime, tween timing
- ❌ **Don't use delta:** Gameplay timers, hitbox activation, hitstun duration, combo windows

---

## Important Rules (Violation = Risk)

### Rule 8: Autoload Order Matters — Add Runtime Assertions

**Why:** `VFXManager`, `AudioManager`, `SceneManager`, and `RoundManager` all depend on `EventBus` and `GameState`. If autoload order changes in `project.godot`, systems silently break with null reference errors.

**Sprint 1 bugs:** Issue #66, PR #82 — Integration gate caught autoload order violations after merge

```gdscript
# ✅ CORRECT — assert dependencies in _ready()
extends Node

func _ready() -> void:
    assert(EventBus != null, "VFXManager requires EventBus to load first")
    assert(GameState != null, "VFXManager requires GameState to load first")
    _wire_signals()
```

**Current Autoload Order (LOCKED):**

```ini
[autoload]
EventBus="*res://scripts/systems/event_bus.gd"        # 1st — no dependencies
GameState="*res://scripts/systems/game_state.gd"      # 2nd — no dependencies
AudioManager="*res://scripts/systems/audio_manager.gd" # 3rd — uses EventBus
VFXManager="*res://scripts/systems/vfx_manager.gd"     # 4th — uses EventBus + GameState
SceneManager="*res://scripts/systems/scene_manager.gd" # 5th — uses EventBus + GameState
```

**Rule:** Always add `assert()` checks in `_ready()` for any autoload that references another autoload.

---

### Rule 9: Signal Naming Convention — past_tense for Events

**Why:** Signals represent events that **already happened**. Past tense makes the timeline clear: `hit_landed` = hit has landed, listener reacts.

**EventBus Signal Naming:**

```gdscript
# ✅ CORRECT — past tense
signal hit_landed(attacker, target, move)
signal round_started(round_number)
signal fighter_ko(fighter, round_number)
signal combo_ended(fighter, total_hits, total_damage)

# ❌ WRONG — present/future tense (ambiguous)
signal hit_lands(attacker, target, move)
signal round_start(round_number)
signal fighter_dies(fighter)
signal end_combo(fighter, hits, damage)
```

**Exception:** Request signals (imperative) use present tense:
```gdscript
signal scene_change_requested(scene_path)  # Requesting future action
```

**Rule:** Events = past tense, Requests = present tense

---

### Rule 10: Always emit Signals, Even If No Listeners Yet

**Why:** Integration gate validates signal wiring. A signal that's defined but never emitted will fail validation, blocking merge. Emit signals where the event happens, even if no system listens yet.

**Sprint 1 bugs:** PR #88 — 6 signals defined but never emitted (hit_blocked, ember_spent, ignition_activated, combo_updated, combo_ended, state_changed)

```gdscript
# ❌ WRONG — signal defined but never emitted
signal combo_updated(fighter, hit_count)

func _on_hit_landed(...):
    # Combo logic here but no emit
    pass

# ✅ CORRECT — emit where event occurs
signal combo_updated(fighter, hit_count)

func _on_hit_landed(attacker, target, move):
    _combo_count += 1
    EventBus.combo_updated.emit(attacker, _combo_count)  # Always emit
```

**Pattern:** Define signal → Emit in event source → Connect in consumers. If you can't emit immediately, add a TODO comment:

```gdscript
signal training_mode_started()
# TODO: Emit when training mode implemented (Sprint 2 #xyz)
```

---

### Rule 11: Collision Layers — Use Named Constants, Not Magic Numbers

**Why:** `collision_layer = 8` is meaningless. `collision_layer = STAGE_LAYER` is self-documenting. Layer numbers are hard to remember and error-prone.

**Sprint 1 bugs:** PR #32 — Floor/walls used wrong collision layers (fighter layers instead of stage layer)

```gdscript
# ❌ WRONG — magic number
fighter.collision_mask = 9  # What is 9?

# ✅ CORRECT — named constant
const FIGHTERS_LAYER := 1   # 2^0
const HITBOXES_LAYER := 2   # 2^1
const HURTBOXES_LAYER := 4  # 2^2
const STAGE_LAYER := 8      # 2^3

fighter.collision_mask = FIGHTERS_LAYER | STAGE_LAYER  # Self-documenting
```

**Ashfall Layer Assignments (LOCKED):**

| Layer # | Name | Bit Value | Used By |
|---------|------|-----------|---------|
| 1 | Fighters | 1 (2^0) | `CharacterBody2D` pushboxes |
| 2 | Hitboxes | 2 (2^1) | `Area2D` attack zones |
| 3 | Hurtboxes | 4 (2^2) | `Area2D` damage zones |
| 4 | Stage | 8 (2^3) | `StaticBody2D` floor/walls |

**Rule:** Define layer constants in a `CollisionLayers` autoload or in `res://scripts/constants.gd`. Never hardcode layer numbers.

---

### Rule 12: Exported Variables Must Have Types

**Why:** Godot Inspector needs explicit types to show the correct editor widget. `@export var x` without a type shows a generic Variant field.

```gdscript
# ❌ WRONG — no type, shows Variant field in Inspector
@export var max_speed = 300

# ✅ CORRECT — explicit type, shows numeric spinbox
@export var max_speed: float = 300.0
```

**Type-Specific Inspector Widgets:**
- `int` → Spinbox with integer steps
- `float` → Spinbox with decimal steps
- `String` → Single-line text input
- `Color` → Color picker
- `NodePath` → Node path selector
- `Resource` → Resource dropdown

**Export Hints:**

```gdscript
@export_range(0, 100, 1) var health: int = 100        # Slider 0-100
@export_enum("Kael", "Rhena") var character: String   # Dropdown
@export_file("*.json") var config_path: String        # File picker
@export_multiline var description: String             # Multi-line text
```

---

## Style Rules (Consistency)

### Rule 13: Indentation — Tabs, Not Spaces

**Why:** GDScript official style guide uses tabs. Godot editor default is tabs. Mixing tabs/spaces causes invisible formatting bugs.

**Sprint 1 bugs:** Commit `be6422b` — "restore tab indentation in camera_controller.gd" (someone used spaces)

```gdscript
# ✅ CORRECT — tabs for indentation
func _ready() -> void:
→   if condition:
→   →   do_something()

# ❌ WRONG — spaces for indentation
func _ready() -> void:
    if condition:
        do_something()
```

**EditorConfig (.editorconfig at repo root):**

```ini
[*.gd]
indent_style = tab
indent_size = 4
```

**Rule:** Configure your editor to use tabs for `.gd` files. Never mix tabs and spaces.

---

### Rule 14: Naming Conventions

**Sprint 1 pattern:** Inconsistent naming made code review harder. Standardize now.

#### Variables

```gdscript
# ✅ CORRECT — snake_case
var player_health: int = 100
var is_blocking: bool = false
var max_combo_hits: int = 10

# ❌ WRONG — camelCase or PascalCase
var playerHealth: int = 100
var IsBlocking: bool = false
```

#### Constants

```gdscript
# ✅ CORRECT — SCREAMING_SNAKE_CASE
const MAX_HEALTH: int = 1000
const GRAVITY: float = 980.0
const HITSTUN_MULTIPLIER: float = 1.5

# ❌ WRONG — lowercase or camelCase
const max_health: int = 1000
const maxHealth: int = 1000
```

#### Functions

```gdscript
# ✅ CORRECT — snake_case, verb prefix
func calculate_damage() -> int:
func is_in_hitstun() -> bool:
func get_current_state() -> String:

# ❌ WRONG — camelCase or noun-only
func calculateDamage() -> int:
func hitstun() -> bool:
func state() -> String:
```

#### Classes (class_name)

```gdscript
# ✅ CORRECT — PascalCase
class_name FighterController
class_name MoveData
class_name HitboxArea

# ❌ WRONG — snake_case or lowercase
class_name fighter_controller
class_name movedata
```

#### Signals

```gdscript
# ✅ CORRECT — past_tense_snake_case
signal hit_landed
signal round_started
signal fighter_ko

# ❌ WRONG — present tense or camelCase
signal hitLands
signal roundStart
signal fighterDie
```

#### Private Variables/Functions

```gdscript
# ✅ CORRECT — prefix with underscore
var _combo_count: int = 0
func _update_animation() -> void:

# Public API
var health: int = 100
func take_damage(amount: int) -> void:
```

---

### Rule 15: File Organization

**Standard .gd file structure:**

```gdscript
# 1. Class declaration
class_name FighterController
extends Node

# 2. Signals
signal state_changed(new_state)

# 3. Enums
enum State { IDLE, WALK, JUMP, ATTACK }

# 4. Constants
const MAX_SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

# 5. Exported variables
@export var fighter_name: String = "Kael"
@export var max_health: int = 1000

# 6. Public variables
var health: int = 1000
var current_state: State = State.IDLE

# 7. Private variables
var _velocity: Vector2 = Vector2.ZERO
var _animation_player: AnimationPlayer

# 8. Onready variables
@onready var sprite := $Sprite2D
@onready var hitbox := $Hitbox

# 9. Lifecycle methods (_init, _ready, _process, _physics_process, _input)
func _ready() -> void:
    pass

func _physics_process(_delta: float) -> void:
    pass

# 10. Public methods
func take_damage(amount: int) -> void:
    pass

# 11. Private methods
func _update_animation() -> void:
    pass

# 12. Signal callbacks
func _on_hitbox_area_entered(area: Area2D) -> void:
    pass
```

**Rule:** Follow this order. Keep related code together.

---

### Rule 16: Comments — Why, Not What

**Why:** Code shows *what* it does. Comments should explain *why* (rationale, edge cases, design decisions).

```gdscript
# ❌ WRONG — comment repeats code
# Set velocity to zero
fighter.velocity = Vector2.ZERO

# ✅ CORRECT — explains why
# Ground friction stops all horizontal movement on landing
fighter.velocity = Vector2.ZERO

# ❌ WRONG — obvious statement
# Loop through all enemies
for enemy in enemies:
    enemy.take_damage(10)

# ✅ CORRECT — explains rationale
# Apply chip damage to blocking enemies (GDD §3.2.1)
for enemy in blocking_enemies:
    enemy.take_damage(10)
```

**When to Comment:**
- ✅ Workarounds for Godot bugs
- ✅ Magic numbers with context (frame counts, damage scaling)
- ✅ Non-obvious algorithms (motion detection, proration)
- ✅ Design decisions (why X instead of Y)
- ❌ Obvious variable assignments
- ❌ Self-explanatory function calls

---

## Godot 4.6 Gotchas

Quick-reference list of Godot 4.6 specific pitfalls the team has encountered.

### 1. Type Inference Fails on Dictionary/Array Access
`:=` from `dict["key"]` or `array[0]` produces `Variant`. Always use explicit types.

### 2. abs() Returns Variant
Use `absf()` for floats, `absi()` for ints.

### 3. Custom ui_* Actions Break Exports
Never override `ui_accept`, `ui_cancel`, `ui_left/right/up/down` in `project.godot`.

### 4. _input() Bypasses Focus System
Use `Button` nodes with `grab_focus()` for menus, not custom `_input()`.

### 5. Method Name Shadowing Silent in Editor
Custom `draw_ellipse()` shadows `Node2D.draw_ellipse()`. Prefix custom methods with `_`.

### 6. AnimationPlayer Process Mode
Set to `PHYSICS` for deterministic frame-based gameplay. Default is `IDLE` (render frames).

### 7. Collision Layer Bit Shifting
`collision_mask = 9` means layers 1 + 8 (bits 0 and 3). Use named constants, not magic numbers.

### 8. Autoload Load Order Not Enforced
If `VFXManager` loads before `EventBus`, null reference crash. Add `assert()` checks in `_ready()`.

### 9. Scene References Are Paths, Not GUIDs
Renaming/moving a script breaks `.tscn` references silently. Integration gate tool #4 catches this.

### 10. Export Builds Are Stricter Than Editor
Type mismatches, null refs, and method shadowing tolerated in editor often crash in exports. Test exports early.

---

## Checklist for PR Review

Use this checklist when reviewing `.gd` code:

### Type Safety
- [ ] No `:=` with dictionary access (`dict["key"]`)
- [ ] No `:=` with array access (`array[0]`)
- [ ] No `:=` with `abs()` (use `absf()`/`absi()` instead)
- [ ] All functions have explicit return types (`-> Type`)
- [ ] All `@export` variables have explicit types

### Input Handling
- [ ] No custom `ui_*` action overrides in `project.godot`
- [ ] Menus use `Button` nodes, not custom `_input()`
- [ ] If `_input()` used, verify not for menu navigation

### Naming & Style
- [ ] Variables: `snake_case`
- [ ] Constants: `SCREAMING_SNAKE_CASE`
- [ ] Functions: `snake_case` with verb prefix
- [ ] Classes: `PascalCase`
- [ ] Signals: `past_tense_snake_case`
- [ ] Tabs for indentation (not spaces)

### Architecture
- [ ] Frame-based timing (int counters, not float timers)
- [ ] Autoload dependencies have `assert()` checks
- [ ] Collision layers use named constants
- [ ] Custom draw methods prefixed with `_`
- [ ] Signals emitted where events occur

### Documentation
- [ ] Comments explain "why", not "what"
- [ ] Magic numbers have context comments
- [ ] Workarounds documented

### Testing
- [ ] Integration gate passes (run `python tools/integration-gate.py`)
- [ ] Windows export tested if input/UI changes
- [ ] No Godot editor warnings/errors

---

## Quick Reference — Do's and Don'ts

| ✅ DO | ❌ DON'T |
|-------|----------|
| `var x: float = dict["key"]` | `var x := dict["key"]` |
| `var dist: float = absf(a - b)` | `var dist := abs(a - b)` |
| `func get_health() -> int:` | `func get_health():` |
| `Button` nodes with `grab_focus()` | Custom `_input()` for menus |
| `collision_mask = FIGHTERS \| STAGE` | `collision_mask = 9` |
| `frames_in_state: int = 0` | `time_in_state: float = 0.0` |
| `func _draw_custom_rect():` | `func draw_rect():` (shadows built-in) |
| `assert(EventBus != null)` | Assume autoload order is safe |
| Use `absf()`, `minf()`, `maxf()` | Use `abs()`, `min()`, `max()` |
| Emit all defined signals | Define signals never emitted |

---

## When to Break These Rules

**Never break Critical Rules (1-7).** They prevent bugs.

**Important Rules (8-12)** can be bent with justification:
- Document the exception in a comment
- Link to issue/discussion with rationale
- Get Jango approval in PR review

**Style Rules (13-16)** are guidelines:
- Consistency matters more than specific choices
- If existing file uses spaces, match it (then refactor later)
- If GDD uses different naming, document the translation

---

## Updating This Document

When a new bug pattern emerges:

1. **Identify the pattern** — What went wrong?
2. **Find the root cause** — Why did it happen?
3. **Add a rule** — How do we prevent it?
4. **Link to the bug** — Commit hash or issue number
5. **Provide examples** — ✅ CORRECT vs ❌ WRONG
6. **Update the checklist** — Add validation step

**Owner:** Jango maintains this doc. Anyone can propose additions via PR.

---

## References

- [GDScript Style Guide (Official)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot 4.6 Type System Documentation](https://docs.godotengine.org/en/4.6/tutorials/scripting/gdscript/static_typing.html)
- [Ashfall Architecture Doc](./ARCHITECTURE.md)
- [Sprint 1 Lessons Learned](./SPRINT-1-LESSONS-LEARNED.md)

---

*"Good code works. Great code explains why it works and prevents you from breaking it."*

— Jango, Tool Engineer
