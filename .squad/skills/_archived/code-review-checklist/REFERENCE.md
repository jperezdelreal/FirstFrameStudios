# Code Review Checklist for GDScript Game Systems

## Metadata
- **Confidence:** medium
- **Domain:** Code Review, GDScript, Game Architecture
- **Last validated:** 2026-03-08
- **Source:** Jango code review (Ashfall Pre-M3) — 24 issues across 31 files

## Pattern

Game systems built for multi-agent development need systematic review to catch integration blockers, null safety violations, and state machine initialization issues early. This checklist identifies patterns that consistently appear in code reviews and prevent runtime crashes.

## Review Checklist

### 1. Null Safety on Node References

**Pattern:** Code accesses node references (via `get_node()`, `get_parent()`, or autoloaded singletons) without null checks.

**Validation:** Check every assignment to a typed variable that expects a Node reference.

```gdscript
# ❌ UNSAFE
func _update_facing() -> void:
    if global_position.x < opponent.global_position.x:  # crashes if opponent null
        flip_h = false

# ✅ SAFE
func _update_facing() -> void:
    if not opponent or not is_instance_valid(opponent):
        return
    if global_position.x < opponent.global_position.x:
        flip_h = false
```

**Checklist items:**
- [ ] All `opponent` or `owner` references are checked before use
- [ ] `@onready` variables are verified to exist before use in `_physics_process` or `_process`
- [ ] Autoloaded singletons that might fail to initialize are checked (e.g., `if RoundManager:`)
- [ ] `get_node()` results are checked for null before calling methods
- [ ] `get_parent()` results are validated as the expected type

### 2. State Machine Initialization Guarantee

**Pattern:** State machines may never initialize, causing fighters to freeze on spawn. Two ways this fails:
- `initial_state` is not set in the scene editor
- `_ready()` doesn't force a transition to a valid starting state

**Validation:**
```gdscript
# ❌ FRAGILE — relies on initial_state being set in scene
func _ready():
    # ... wire states ...
    if not state_machine.current_state:
        state_machine.transition_to("idle", {})
    # If initial_state is set to something other than idle, this doesn't fix it

# ✅ SAFE — always ensure idle start
func _ready():
    # ... wire states ...
    # Always transition to idle, regardless of initial_state setting
    state_machine.transition_to("idle", {})
```

**Checklist items:**
- [ ] State machine `_ready()` always calls `transition_to()` with a valid starting state
- [ ] Starting state (e.g., "idle") is hardcoded or verified to exist in the states dictionary
- [ ] No branch through `_ready()` leaves `current_state` as null
- [ ] Race conditions prevented: state wiring happens before state initialization (use `call_deferred` if needed)

### 3. Exported Variables Have Defaults

**Pattern:** Configuration values hardcoded as `const` should be `@export` for designer tuning, but must have sensible defaults in the inspector.

**Validation:**
```gdscript
# ❌ HARDCODED — can't be tuned per-character
const BUFFER_SIZE = 30
const INPUT_LENIENCY = 8

# ✅ EXPORTED — can be tuned in editor with defaults
@export var buffer_size: int = 30
@export var input_leniency: int = 8
```

**Checklist items:**
- [ ] Magic numbers (frame counts, timers, distances) are extracted to `@export` variables
- [ ] Buffer windows and timing values are exportable, not hardcoded as consts
- [ ] Spawn positions, character-specific values, and balancing numbers are exported
- [ ] Default values are sensible (not 0, not 999999)

### 4. Signal Connections Verified (Not Just Definitions)

**Pattern:** Signals can be defined in a singleton but never actually connected or emitted, becoming dead code.

**Validation:**
```gdscript
# ❌ SIGNAL DEFINED BUT NEVER USED
signal fighter_knocked_out(fighter: Fighter)  # defined in EventBus

# Code never connects:
# EventBus.fighter_knocked_out.connect(...)

# Code never emits:
# EventBus.emit_signal("fighter_knocked_out", fighter)

# ✅ SIGNAL COMPLETE
signal fighter_knocked_out(fighter: Fighter)  # defined in EventBus

# In fighter_base.gd:
func enter_ko_state():
    EventBus.emit_signal("fighter_knocked_out", self)  # emitted

# In round_manager.gd:
func _ready():
    EventBus.fighter_knocked_out.connect(_on_fighter_ko)  # connected

func _on_fighter_ko(fighter: Fighter):
    state = ROUND_STATES.KO  # consumed and does meaningful work
```

**Checklist items:**
- [ ] Every signal defined in EventBus is checked: `grep -r "emit_signal" src/` for emissions
- [ ] For each signal emission, verify at least one `.connect()` exists in another system
- [ ] Callback does meaningful work (not just `push_print` for debugging)
- [ ] Emitting system runs before consuming system (dependency order in autoloads)
- [ ] No signals in EventBus with zero emissions (dead code)

### 5. GDD Spec vs Implementation Completeness

**Pattern:** Game Design Document specifies features that the code doesn't fully implement (e.g., 6-button input but only 4 implemented).

**Validation:**
- [ ] Read the GDD section on the feature (e.g., player inputs, movesets, collision)
- [ ] Count required distinct items (e.g., 6 buttons: LP, MP, HP, LK, MK, HK)
- [ ] Search code for implementation: `grep -r "light_punch\|medium_punch" src/`
- [ ] Compare counts: if GDD says 6 but code has 4, that's a blocker
- [ ] For input map: verify `project.godot` [input_map] includes all GDD-specified inputs
- [ ] For movesets: verify `FighterMoveset` class has methods for all GDD move types

**Example from Ashfall:**
- GDD specifies: 6-button layout (LP, MP, HP, LK, MK, HK)
- `project.godot` [input_map] defines: only 4 buttons per player (LP, HP, LK, HK)
- Medium punch and medium kick are missing → movesets incomplete

### 6. Collision Layers Match Documentation

**Pattern:** Collision layer scheme documented in ARCHITECTURE.md doesn't match actual `project.godot` or scene files.

**Validation:**
```
Steps:
1. Open project.godot, read [2d_physics] layer names
2. Open ARCHITECTURE.md, read collision layer documentation
3. Do they describe the same scheme?
   - Same number of layers?
   - Same layer names/purposes?
   - Same layer assignments?
4. Spot-check scene files (.tscn):
   - Open any CharacterBody2D or Area2D node
   - Check collision_layer and collision_mask values
   - Do they match the documented scheme?
```

**Checklist items:**
- [ ] ARCHITECTURE.md collision documentation matches `project.godot` [2d_physics] section
- [ ] All physics nodes (CharacterBody2D, Area2D, StaticBody2D) in `.tscn` files have EXPLICIT collision_layer and collision_mask (not relying on defaults)
- [ ] Layer assignments in scene files match the documented scheme
- [ ] No scene file uses Layer 1 (default) when it should use a different layer

### 7. Hardcoded Values That Should Be Exported or Configurable

**Pattern:** Values that vary per-character, per-scene, or per-balance-pass are hardcoded into scripts instead of being tunable.

**Validation:**
```gdscript
# ❌ HARDCODED — can't tune for testing
spawn_position = Vector2(-200, 0)  # hardcoded in RoundManager

crouch_hurtbox_position_y = 10.0  # assume hurtbox pivot is at feet
deceleration = 15.0  # knockback friction, should vary per-character
air_control_factor = 0.5  # jump air drift, should vary per-character

# ✅ EXTRACTED — tunable per-character or per-stage
@export var p1_spawn: Marker2D  # reference to stage's spawn marker
@export var crouch_hurtbox_scale: float = 0.8  # or use scale.y
@export var knockback_friction: float = 15.0
@export var air_control_factor: float = 0.5
```

**Checklist items:**
- [ ] Physics values (friction, acceleration, air control) are exported
- [ ] Timing values (frame counts, animation timers) are exported
- [ ] Spawn positions reference stage markers or are stage-specific resources
- [ ] Damage values and move properties come from MoveData resources, not hardcoded
- [ ] UI position/scale values are not hardcoded into scene structure

## When to Apply

- Code review of any new system or state class
- Before merging a PR that adds gameplay features
- Before marking a feature complete or milestone ready
- When integrating work from multiple agents
- As part of the post-wave integration gate (see `.squad/skills/parallel-agent-workflow/SKILL.md`)

## Review Workflow

1. **Read the PR description:** Understand what was intended
2. **Search for known anti-patterns** using grep:
   ```powershell
   # Null dereference risks
   grep -r "opponent\." src/fighters/
   grep -r "get_node(" src/
   
   # Hardcoded values
   grep -r "const [A-Z_]* = [0-9]" src/
   grep -r "Vector2(.*[0-9]+.*[0-9]+.*)" src/
   ```
3. **Run the checklist** above on each new file
4. **Spot-check integration points:**
   - If adding a signal, verify it's emitted and connected
   - If modifying project.godot, verify autoload order
   - If touching collisions, verify layers match docs
5. **Request changes** for any checklist failures
6. **Approve only after** all items pass

## Key Takeaway

**Code review catches integration gaps early.** Systems can look correct in isolation but fail when integrated because signals aren't wired, state machines don't initialize, or null references crash on runtime. Use this checklist to shift integration testing left, catching issues in PR review instead of post-merge debugging.
