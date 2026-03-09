# Ashfall Pre-M3 Code Review

**Reviewer:** Jango (Lead, Ashfall Project)  
**Requested by:** Joaquín  
**Date:** 2026-03-08  
**Scope:** Full review of games/ashfall/scripts/ (31 GDScript files)

---

## Executive Summary

**VERDICT: 🔴 NOT READY FOR M3**

The codebase demonstrates strong architectural design and follows GDScript best practices, but **5 critical blockers** prevent the game from running. The core issue is that **RoundManager is never instantiated**, meaning no round lifecycle, no timer, no win conditions. Additionally, several integration gaps and missing null checks will cause crashes.

### Issue Counts by Severity

| Severity | Count | Status |
|----------|-------|--------|
| 🔴 **Blocker** | **5** | Must fix before M3 |
| 🟡 **Should Fix** | **11** | Quality issues, fix soon |
| 🟢 **Nice to Have** | **8** | Polish, can wait |
| **TOTAL** | **24** | |

---

## 🔴 BLOCKERS (Must Fix Before M3)

### 1. RoundManager Not Instantiated in FightScene

**File:** `games/ashfall/scripts/fight_scene.gd`  
**Lines:** N/A (missing code)

**Issue:**  
ARCHITECTURE.md specifies RoundManager as a child of FightScene, but `fight_scene.gd` never instantiates it. The round state machine will never run.

**Impact:**
- No round transitions (INTRO → READY → FIGHT → KO)
- Timer never counts down
- No announcements ("ROUND 1", "FIGHT!", "K.O.")
- Match never ends

**Fix:**
```gdscript
# fight_scene.gd
@onready var round_manager: RoundManager = $RoundManager

func _ready():
    # ... existing code ...
    round_manager.start_match(fighter1, fighter2)
```

Add RoundManager node to `fight_scene.tscn`.

---

### 2. Fighter Damage/KO Signals Not Wired to RoundManager

**File:** `games/ashfall/scripts/fight_scene.gd`  
**Lines:** 20-23

**Issue:**  
`fighter_base.gd` emits `knocked_out` signal, and `fight_scene.gd` forwards it to EventBus, but **RoundManager never receives it**. Round transitions won't trigger.

**Current Code:**
```gdscript
func _ready():
    fighter1.knocked_out.connect(_on_fighter_ko)  # ← forwards to EventBus only
    fighter2.knocked_out.connect(_on_fighter_ko)
```

**Impact:**
- KO state never transitions to ROUND_RESET or MATCH_END
- Scores never update
- Rounds never advance

**Fix:**
```gdscript
func _ready():
    # Connect to both RoundManager (for round logic) and EventBus (for audio/VFX)
    round_manager.start_match(fighter1, fighter2)  # ← this wires KO signals internally
```

`RoundManager.start_match()` already handles this (lines 44-47 of `round_manager.gd`).

---

### 3. Missing Null Check on Opponent Before _update_facing

**File:** `games/ashfall/scripts/fighters/fighter_base.gd`  
**Lines:** 69-82

**Issue:**  
`_update_facing()` accesses `opponent.global_position` without verifying `opponent` exists.

**Current Code:**
```gdscript
func _update_facing() -> void:
    if not opponent or not state_machine.current_state:  # ← checks opponent
        return
    var state_name := state_machine.current_state.name.to_lower()
    if state_name in ["attack", "hit", "ko"]:
        return
    if global_position.x < opponent.global_position.x:  # ← crashes if opponent null
```

**Impact:**
- Crashes on scene load if opponent reference not set
- Happens if fighters spawn in wrong order

**Fix:**
```gdscript
func _update_facing() -> void:
    if not opponent or not is_instance_valid(opponent) or not state_machine.current_state:
        return
    # ... rest of method ...
```

Add `is_instance_valid()` check.

---

### 4. State Machine May Not Initialize if initial_state Not Set

**File:** `games/ashfall/scripts/fighters/fighter_base.gd`  
**Lines:** 54-57

**Issue:**  
Fallback to idle only happens if `current_state` is null, but if `state_machine.initial_state` is not set in the scene, the state machine never starts.

**Current Code:**
```gdscript
func _ready():
    # ... wire states ...
    if not state_machine.current_state:
        state_machine.transition_to("idle", {})  # ← only runs if current_state null
```

**Impact:**
- Fighters freeze on spawn
- No input processing
- No movement or attacks

**Fix:**
```gdscript
func _ready():
    # ... wire states ...
    # Force idle if not already in a state
    if not state_machine.current_state:
        state_machine.transition_to("idle", {})
    elif state_machine.current_state.name.to_lower() != "idle":
        # Ensure we start in idle, not whatever initial_state was set to
        state_machine.transition_to("idle", {})
```

Or simplify:
```gdscript
    # Always start in idle
    state_machine.transition_to("idle", {})
```

---

### 5. Autoload Order Violation: SceneManager Loads Before RoundManager Exists

**File:** `games/ashfall/project.godot`  
**Lines:** [autoload] section

**Issue:**  
Per `.squad/skills/godot-project-integration/SKILL.md`, systems that depend on EventBus must load in dependency order. RoundManager is **not an autoload**, but it should be, and it must load after GameState.

**Current Autoload Order:**
```ini
EventBus="*res://scripts/systems/event_bus.gd"       # 1st
GameState="*res://scripts/systems/game_state.gd"     # 2nd
VFXManager="*res://scripts/systems/vfx_manager.gd"   # 3rd
AudioManager="*res://scripts/systems/audio_manager.gd" # 4th
SceneManager="*res://scripts/systems/scene_manager.gd" # 5th
# RoundManager NOT HERE ← problem
```

**Impact:**
- RoundManager is instantiated per-scene, meaning round state doesn't persist across scene reloads
- No global access to round state
- SceneManager can't query round state for victory screen transitions

**Fix:**
Add RoundManager as autoload after GameState:
```ini
[autoload]
EventBus="*res://scripts/systems/event_bus.gd"
GameState="*res://scripts/systems/game_state.gd"
RoundManager="*res://scripts/systems/round_manager.gd"  # ← ADD THIS
VFXManager="*res://scripts/systems/vfx_manager.gd"
AudioManager="*res://scripts/systems/audio_manager.gd"
SceneManager="*res://scripts/systems/scene_manager.gd"
```

Then change `fight_scene.gd` to:
```gdscript
func _ready():
    RoundManager.start_match(fighter1, fighter2)  # ← use autoload singleton
```

---

## 🟡 SHOULD FIX (Quality Issues, Fix Soon)

### 6. Hitbox owner_fighter Auto-Detect Can Fail Silently

**File:** `games/ashfall/scripts/systems/hitbox.gd`  
**Lines:** 33-39

**Issue:**  
Walks up tree to find `CharacterBody2D` parent, but if not found, `owner_fighter` stays `null`. Later, `_get_directional_knockback()` checks `owner_fighter`, but hit detection does not.

**Fix:**
```gdscript
func _ready():
    # ... existing code ...
    if not owner_fighter:
        push_warning("Hitbox '%s' could not find owner fighter in parent tree" % name)
```

---

### 7. _activate_hitboxes Iterates All Children Every Frame

**File:** `games/ashfall/scripts/fighters/states/attack_state.gd`  
**Lines:** 81-87, 90-101

**Issue:**  
Loops through `fighter.hitboxes.get_children()` on every activate/deactivate call. For a 60-frame attack with 3 hitboxes, that's 360 child lookups.

**Fix:**  
Cache hitbox references in `enter()`:
```gdscript
var _cached_hitboxes: Array[Hitbox] = []

func enter(args: Dictionary):
    super.enter(args)
    # Cache hitbox nodes once
    _cached_hitboxes.clear()
    for child in fighter.hitboxes.get_children():
        if child is Hitbox:
            _cached_hitboxes.append(child)

func _activate_hitboxes():
    for hitbox in _cached_hitboxes:
        hitbox.activate()
```

---

### 8. Buffer Windows Hardcoded Instead of Exported

**File:** `games/ashfall/scripts/systems/input_buffer.gd`  
**Lines:** 11-13

**Issue:**  
`BUFFER_SIZE`, `INPUT_LENIENCY`, `SIMULTANEOUS_WINDOW` are `const` but should be `@export` for per-character tuning.

**Fix:**
```gdscript
@export var buffer_size: int = 30
@export var input_leniency: int = 8
@export var simultaneous_window: int = 3
```

---

### 9. _find_fighter Assumes Scene Structure

**File:** `games/ashfall/scripts/systems/vfx_manager.gd`  
**Lines:** 466-483

**Issue:**  
Searches `get_tree().get_nodes_in_group("fighters")` but never validates result is a valid `Node2D`. If scene structure differs, returns `null` and causes ember trail crash.

**Fix:**
```gdscript
func _find_fighter(player_id: int) -> Node:
    var fighters := get_tree().get_nodes_in_group("fighters")
    for f in fighters:
        if f is Node2D and "player_id" in f and f.player_id == player_id:
            return f
    return null
```

---

### 10. _is_heavy_move Uses Weak Type Checking

**File:** `games/ashfall/scripts/systems/audio_manager.gd`  
**Lines:** 283-299

**Issue:**  
Uses `move.has_method("get")` instead of proper type validation. Breaks if `move` is a custom class.

**Fix:**
```gdscript
func _is_heavy_move(move: Variant) -> bool:
    if move is MoveData:
        return move.damage > 80 or "heavy" in move.move_name.to_lower()
    elif move is Dictionary:
        # ... existing dict logic ...
    return false
```

---

### 11. p1_spawn and p2_spawn Hardcoded

**File:** `games/ashfall/scripts/systems/round_manager.gd`  
**Lines:** 34-35

**Issue:**  
Hardcoded `Vector2(-200, 0)` and `Vector2(200, 0)` but never used. `fighter_base.reset_for_round()` takes `spawn_position` param but RoundManager doesn't pass stage-specific spawns.

**Fix:**  
Extract to stage resource:
```gdscript
# stage.gd
@export var p1_spawn: Marker2D
@export var p2_spawn: Marker2D

# round_manager.gd
func _start_round():
    var stage = get_tree().current_scene.get_node("Stage")
    fighters[0].reset_for_round(stage.p1_spawn.global_position)
    fighters[1].reset_for_round(stage.p2_spawn.global_position)
```

---

### 12. Throw Transitions to Non-Existent State

**File:** `games/ashfall/scripts/fighters/fighter_controller.gd`  
**Lines:** 48-54

**Issue:**  
`_try_throw()` returns `true` but never transitions to throw state. Comment says "TODO" but this means throw input is consumed and nothing happens.

**Fix:**  
Either implement throw state or remove detection:
```gdscript
func _try_throw() -> bool:
    if input_buffer.check_simultaneous(["lp", "lk"]):
        input_buffer.consume_button("lp")
        input_buffer.consume_button("lk")
        fighter.state_machine.transition_to("throw", {})  # ← ADD THIS
        return true
    return false
```

Or comment out the entire method until throw state exists.

---

### 13. transition_to Only Warns on Invalid State

**File:** `games/ashfall/scripts/states/state_machine.gd`  
**Lines:** 25-28

**Issue:**  
Uses `push_warning` but continues execution. Fighter stays in current state with consumed input, which is confusing to debug.

**Fix:**
```gdscript
func transition_to(target_state_name: String, args: Dictionary = {}) -> void:
    var target = states.get(target_state_name.to_lower())
    if target == null:
        push_error("State '%s' not found in state machine" % target_state_name)
        return
```

---

### 14. Collision Layers Don't Match ARCHITECTURE.md

**File:** `games/ashfall/scripts/systems/hitbox.gd`  
**Lines:** 26-27

**Issue:**  
Code sets `layer=2 mask=4` but ARCHITECTURE.md says "Layer 3=Hitboxes, Layer 4=Hurtboxes". However, `project.godot` says "Layer 2=Hitboxes, Layer 3=Hurtboxes". **Documentation vs implementation mismatch.**

**Current project.godot:**
```ini
2d_physics/layer_1="Fighters"
2d_physics/layer_2="Hitboxes"    # ← code uses this
2d_physics/layer_3="Hurtboxes"   # ← code uses mask=4 (bit 2, layer 3)
2d_physics/layer_4="Stage"
```

**ARCHITECTURE.md says:**
```
Layer 1: Player 1 (fighters)
Layer 2: Player 2 (fighters)
Layer 3: Hitboxes           # ← docs say this
Layer 4: Hurtboxes          # ← docs say this
Layer 5: Pushboxes
Layer 6: Environment
```

**Fix:**  
Update ARCHITECTURE.md to match implementation:
```markdown
Layer 1: Fighters (both P1 and P2)
Layer 2: Hitboxes
Layer 3: Hurtboxes
Layer 4: Stage
```

---

### 15. Hurtbox Position Adjustment Not Verified in Scene

**File:** `games/ashfall/scripts/fighters/states/crouch_state.gd`  
**Lines:** 19-20

**Issue:**  
`hurtbox_shape.position.y += 10.0` assumes hurtbox pivot is at feet. If pivot is centered, this moves hurtbox down instead of shrinking up.

**Fix:**  
Use `scale.y` only, or verify pivot in scene and document assumption:
```gdscript
func enter(args: Dictionary):
    super.enter(args)
    # Shrink hurtbox vertically (assumes pivot at bottom)
    var hurtbox_shape := fighter.hurtbox.get_child(0) as CollisionShape2D
    if hurtbox_shape:
        _original_hurtbox_scale = hurtbox_shape.scale
        hurtbox_shape.scale.y = fighter.crouch_hurtbox_scale
        # Only adjust position if pivot is at center (verify in scene)
        # hurtbox_shape.position.y += 10.0
```

---

### 16. State Machine States Get Fighter Reference in _ready

**File:** `games/ashfall/scripts/fighters/fighter_base.gd`  
**Lines:** 45-48

**Issue:**  
Wires `fighter` into states during `_ready()`, but `state_machine._ready()` might not have initialized `states` dict yet, leading to race condition.

**Fix:**  
Use `call_deferred` or check states dict is populated:
```gdscript
func _ready():
    health = max_health
    input_buffer.player_id = player_id
    input_buffer.facing_right = facing_right
    
    # Defer state wiring until state_machine is ready
    call_deferred("_wire_fighter_to_states")

func _wire_fighter_to_states():
    for state_node in state_machine.get_children():
        if state_node is FighterState:
            state_node.fighter = self
    # Ensure idle start
    if not state_machine.current_state:
        state_machine.transition_to("idle", {})
```

---

## 🟢 NICE TO HAVE (Polish, Can Wait)

### 17. Code Duplication: _any_attack_pressed Duplicated Across States

**Files:**  
- `games/ashfall/scripts/fighters/states/idle_state.gd:54-59`
- `games/ashfall/scripts/fighters/states/walk_state.gd:56-61`
- `games/ashfall/scripts/fighters/states/crouch_state.gd:63-68`

**Fix:**  
Extract to `FighterState` base class:
```gdscript
# fighter_state.gd
func _any_attack_pressed() -> bool:
    return (fighter.is_input_just_pressed("light_punch")
        or fighter.is_input_just_pressed("heavy_punch")
        or fighter.is_input_just_pressed("light_kick")
        or fighter.is_input_just_pressed("heavy_kick"))
```

---

### 18. Magic Numbers: Deceleration Value Hardcoded in HitState

**File:** `games/ashfall/scripts/fighters/states/hit_state.gd:25`

**Fix:**
```gdscript
@export var knockback_friction: float = 15.0

func physics_update():
    fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, knockback_friction)
```

---

### 19. Magic Numbers: Air Control Factor Hardcoded in JumpState

**File:** `games/ashfall/scripts/fighters/states/jump_state.gd:9`

**Fix:**  
Move to `fighter_base.gd`:
```gdscript
@export var air_control_factor: float = 0.5
```

---

### 20. Code Smell: _ensure_own_fill Creates Duplicates Every Call

**File:** `games/ashfall/scripts/ui/fight_hud.gd:287-297`

**Issue:**  
Checks `has_meta` but duplicates `StyleBox` on first call. If bar properties change later, this orphans resources.

**Fix:**  
Call once in `_ready()`:
```gdscript
func _ready():
    _wire_signals()
    _rebuild_dots()
    # Duplicate StyleBoxes once
    _ensure_own_fill(p1_bar)
    _ensure_own_fill(p1_ghost)
    _ensure_own_fill(p2_bar)
    _ensure_own_fill(p2_ghost)
    _ensure_own_fill(p1_ember_bar)
    _ensure_own_fill(p2_ember_bar)
```

---

### 21. Naming Clarity: MotionDetector Could Be Singleton Autoload

**File:** `games/ashfall/scripts/systems/motion_detector.gd`

**Issue:**  
All methods are static. Consider making it an autoload singleton for consistency with other systems (EventBus, GameState).

---

### 22. Missing Feature: No Validation That Moveset Is Complete

**File:** `games/ashfall/scripts/data/fighter_moveset.gd`

**Issue:**  
`get_normal()` returns `null` if no move found, but no validation at load time.

**Fix:**  
Add validation method:
```gdscript
func validate() -> bool:
    var required_buttons := ["lp", "hp", "lk", "hk"]
    for btn in required_buttons:
        if not get_normal(btn, false):
            push_error("Moveset '%s' missing standing normal: %s" % [character_name, btn])
            return false
    return true
```

---

### 23. Polish: KO Announces Twice

**Files:**  
- `games/ashfall/scripts/fighters/states/ko_state.gd:38`
- `games/ashfall/scripts/systems/round_manager.gd:102`

**Issue:**  
`KOState` emits "K.O.!" and `RoundManager._on_fighter_ko()` also emits "K.O.!". Double announcement.

**Fix:**  
Remove announcement from `ko_state.gd` (keep in RoundManager only).

---

### 24. Architecture: Scene Paths as Constants in SceneManager

**File:** `games/ashfall/scripts/systems/scene_manager.gd:18-21`

**Issue:**  
Scene paths are constants but could move to `ProjectSettings` for easier editing by non-programmers.

**Fix:**
```gdscript
const SCENE_MAIN_MENU := ProjectSettings.get_setting("ashfall/scenes/main_menu")
const SCENE_CHARACTER_SELECT := ProjectSettings.get_setting("ashfall/scenes/character_select")
# etc.
```

---

## Overall Code Quality Assessment

### ✅ What's Working Well

1. **Excellent Architecture Compliance**  
   - Node-per-state pattern followed consistently
   - EventBus decoupling is clean (no direct cross-system references)
   - Frame-based timing used everywhere (deterministic)

2. **Strong GDScript Practices**  
   - Typed variables used throughout (`var health: int`, `var fighter: Fighter`)
   - `class_name` declarations on all custom classes
   - `@onready` for node references
   - Proper `_ready()` vs `_physics_process()` separation

3. **Good Error Prevention**  
   - Safety timeouts in all timed states (HitState, KOState, AttackState)
   - Input consumption to prevent double-execution
   - SOCD resolution in InputBuffer

4. **Clean Separation of Concerns**  
   - Data (MoveData, FighterMoveset) separate from logic
   - States own their transitions (no god-file state machine)
   - Systems communicate via signals, not direct calls

5. **Performance Awareness**  
   - SFX pool pattern in AudioManager (8 concurrent players)
   - Procedural audio generation at startup, not runtime
   - Frame counting instead of float timers

### ❌ Critical Gaps

1. **No Integration Testing**  
   - RoundManager never instantiated → round system untested
   - Signals wired to EventBus but not to consumers
   - Hitbox/Hurtbox collision untested (layer mismatch in docs)

2. **Missing Null Safety**  
   - `opponent` reference accessed without validation
   - Hitbox owner auto-detect fails silently
   - State machine initialization not guaranteed

3. **Documentation Drift**  
   - ARCHITECTURE.md collision layers don't match implementation
   - GDD specifies 6-button layout (LP, MP, HP, LK, MK, HK) but code only has 4 (LP, HP, LK, HK)

4. **Hardcoded Configuration**  
   - Spawn positions hardcoded in RoundManager
   - Input buffer windows are constants
   - Air control, friction, knockback values scattered across states

---

## Recommended Action Plan

### Phase 1: Fix Blockers (2-3 hours)
1. Add RoundManager as autoload (issues #1, #2, #5)
2. Add null checks for opponent and state_machine (issues #3, #4)
3. Test that a full match runs: INTRO → FIGHT → KO → ROUND 2 → MATCH END

### Phase 2: Fix Should-Fix Items (4-5 hours)
4. Add error logging for silent failures (issues #6, #9, #13)
5. Optimize hitbox activation (issue #7)
6. Fix throw input (issue #12) or remove detection
7. Update ARCHITECTURE.md collision layers (issue #14)
8. Extract hardcoded values to exports (issues #8, #11)

### Phase 3: Integration Testing (2 hours)
9. Open project in Godot 4.6
10. Verify all autoloads initialize without errors
11. Play 3 full matches and verify:
    - Round transitions work
    - Timer counts down
    - Announcements appear
    - Health bars update
    - Hits register and deal damage
    - KO triggers round end
    - Match ends after 2 round wins

### Phase 4: Polish (Nice to Have)
12. Refactor duplicated code (issue #17)
13. Extract magic numbers (issues #18, #19)
14. Add moveset validation (issue #22)

---

## GitHub Issues Created

**Note:** GitHub CLI (`gh`) is not installed on this system. The following issues should be created manually at:  
`https://github.com/jperezdelreal/FirstFrameStudios/issues/new`

### Blocker Issues to Create:

1. **[Ashfall] 🔴 BLOCKER: RoundManager not instantiated in FightScene**  
   Labels: `type:bug`, `game:ashfall`, `priority:critical`

2. **[Ashfall] 🔴 BLOCKER: Fighter damage/KO signals not wired to RoundManager**  
   Labels: `type:bug`, `game:ashfall`, `priority:critical`

3. **[Ashfall] 🔴 BLOCKER: Missing null check on opponent before _update_facing**  
   Labels: `type:bug`, `game:ashfall`, `priority:critical`

4. **[Ashfall] 🔴 BLOCKER: State machine may not initialize if initial_state not set**  
   Labels: `type:bug`, `game:ashfall`, `priority:critical`

5. **[Ashfall] 🔴 BLOCKER: SceneManager loads before RoundManager exists (autoload order)**  
   Labels: `type:bug`, `game:ashfall`, `priority:critical`

### Should-Fix Issues to Create:

6. **[Ashfall] 🟡 Hitbox owner_fighter auto-detect can fail silently**  
   Labels: `type:bug`, `game:ashfall`, `priority:high`

7. **[Ashfall] 🟡 Performance: _activate_hitboxes iterates all children every frame**  
   Labels: `type:performance`, `game:ashfall`, `priority:medium`

8. **[Ashfall] 🟡 Buffer windows hardcoded instead of exported**  
   Labels: `type:enhancement`, `game:ashfall`, `priority:medium`

9. **[Ashfall] 🟡 VFXManager._find_fighter assumes scene structure**  
   Labels: `type:bug`, `game:ashfall`, `priority:high`

10. **[Ashfall] 🟡 AudioManager._is_heavy_move uses weak type checking**  
    Labels: `type:bug`, `game:ashfall`, `priority:medium`

11. **[Ashfall] 🟡 Spawn positions hardcoded in RoundManager**  
    Labels: `type:enhancement`, `game:ashfall`, `priority:medium`

12. **[Ashfall] 🟡 Throw input consumed but state not implemented**  
    Labels: `type:bug`, `game:ashfall`, `priority:high`

13. **[Ashfall] 🟡 State machine transition_to only warns on invalid state**  
    Labels: `type:bug`, `game:ashfall`, `priority:medium`

14. **[Ashfall] 🟡 Collision layers don't match ARCHITECTURE.md**  
    Labels: `type:documentation`, `game:ashfall`, `priority:medium`

15. **[Ashfall] 🟡 CrouchState hurtbox position adjustment not verified**  
    Labels: `type:bug`, `game:ashfall`, `priority:medium`

16. **[Ashfall] 🟡 Race condition: State machine states get fighter reference in _ready**  
    Labels: `type:bug`, `game:ashfall`, `priority:high`

---

## Sign-Off

**Jango, Lead — Ashfall Project**

The codebase demonstrates strong fundamentals and clean architecture, but **critical integration work remains**. Once the 5 blockers are fixed and round lifecycle is verified in-engine, the game should be playable. The should-fix items are important for stability and debuggability but not immediate showstoppers.

**Recommendation: Fix blockers 1-5, then test in Godot before proceeding to M3 content work.**
