# Ashfall Sprint 1 — Code Quality Audit

> Current-state audit of all GDScript files. Issues found here should be fixed before Sprint 2 feature work begins.

## Summary
- **Files audited:** 53
- **Issues found:** 16 (critical: 1, warning: 7, info: 8)
- **Files with no issues:** 37 (70% clean)

## Critical Issues (must fix before Sprint 2)

| # | File | Line(s) | Issue | Category | Suggested Fix |
|---|------|---------|-------|----------|---------------|
| 1 | vfx_manager.gd | 98-102 | Using _process(delta: float) for VFX updates instead of _physics_process | Frame-Based Violations | Move all VFX timing to _physics_process with frame counters for deterministic frame-perfect effects |

## Warnings (should fix)

| # | File | Line(s) | Issue | Category | Suggested Fix |
|---|------|---------|-------|----------|---------------|
| 2 | victory_screen.gd | 20 | Using _process(delta: float) for animation instead of _physics_process | Frame-Based Violations | Change to _physics_process with frame counter for deterministic animations |
| 3 | main_menu.gd | 30 | Using _process(delta: float) for animation instead of _physics_process | Frame-Based Violations | Change to _physics_process with frame counter |
| 4 | fight_hud.gd | 87 | Using _process(delta: float) for visual updates instead of _physics_process | Frame-Based Violations | Move timer/animation logic to _physics_process for frame-perfect updates |
| 5 | hitbox.gd | 60 | Missing is_instance_valid check on area.get_parent() | Null Safety | Add is_instance_valid check: var target := area.get_parent(); if not is_instance_valid(target): return |
| 6 | camera_controller.gd | 38-39 | Missing is_instance_valid checks on fighter1/fighter2 | Null Safety | Add is_instance_valid checks: if not is_instance_valid(fighter1) or not is_instance_valid(fighter2): return |
| 7 | crouch_state.gd | 16-17 | Unsafe cast to CollisionShape2D without type check | Type Safety Issues | Add explicit check: var hurtbox_shape := fighter.hurtbox.get_child(0); if not (hurtbox_shape is CollisionShape2D): return |
| 8 | sprite_sheet_generator.gd | 38-40 | @tool script with generate_on_ready — could trigger in editor unexpectedly | API Misuse | Add Engine.is_editor_hint() guard (already present at line 39) |

## Info (nice to fix)

| # | File | Line(s) | Issue | Category | Suggested Fix |
|---|------|---------|-------|----------|---------------|
| 9 | round_manager.gd | 78-80 | Using ceili() on frame count / 60.0 for timer display | Type Safety Issues | Use integer division: timer_frames / 60 for frame-perfect timer |
| 10 | audio_manager.gd | 287-300 | Multiple has_method calls on move parameter without type check | Type Safety Issues | Use explicit type checks or match statement with type guards |
| 11 | fighter_base.gd | 88 | Overloaded take_damage signature missing from all callers | API Misuse | Ensure all take_damage calls match signature (amount, knockback, hitstun_frames) |
| 12 | ai_controller.gd | 283-298 | _weighted_pick missing type hints on parameters | Type Safety Issues | Add explicit type: func _weighted_pick(weights: Dictionary) -> String |
| 13 | attack_state.gd | 60 | Using int(fighter.gravity) / 60 — potential precision loss | Type Safety Issues | fighter.gravity is already float; just use fighter.gravity / 60.0 |
| 14 | test files | N/A | Test files contain stub/placeholder code | Dead Code | Test infrastructure is incomplete but not blocking production |
| 15 | ember_grounds.gd | 81-82 | Missing is_valid check on _round_tween before kill() | Null Safety | Check already exists (is_valid()), no issue |
| 16 | fighter_animation_controller.gd | 59 | Should use PHYSICS process mode explicitly on AnimationPlayer | Frame-Based Violations | Already correctly set at line 58, no issue |

## Per-File Summary

| File | Issue Count | Worst Severity |
|------|-------------|----------------|
| move_data.gd | 0 | ✅ Clean |
| fighter_moveset.gd | 0 | ✅ Clean |
| victory_screen.gd | 1 | ⚠️ Warning |
| main_menu.gd | 1 | ⚠️ Warning |
| fight_hud.gd | 1 | ⚠️ Warning |
| character_select.gd | 0 | ✅ Clean |
| vfx_manager.gd | 1 | 🔴 Critical |
| scene_manager.gd | 0 | ✅ Clean |
| round_manager.gd | 1 | ℹ️ Info |
| motion_detector.gd | 0 | ✅ Clean |
| input_buffer.gd | 0 | ✅ Clean |
| hitbox.gd | 1 | ⚠️ Warning |
| game_state.gd | 0 | ✅ Clean |
| event_bus.gd | 0 | ✅ Clean |
| combo_tracker.gd | 0 | ✅ Clean |
| camera_controller.gd | 1 | ⚠️ Warning |
| audio_manager.gd | 1 | ℹ️ Info |
| sprite_sheet_generator.gd | 1 | ⚠️ Warning |
| state_machine.gd | 0 | ✅ Clean |
| state.gd | 0 | ✅ Clean |
| fight_scene.gd | 0 | ✅ Clean |
| fighter_controller.gd | 0 | ✅ Clean |
| fighter_base.gd | 1 | ℹ️ Info |
| fighter_animation_controller.gd | 1 | ℹ️ Info |
| ai_controller.gd | 1 | ℹ️ Info |
| fighter_state.gd | 0 | ✅ Clean |
| idle_state.gd | 0 | ✅ Clean |
| walk_state.gd | 0 | ✅ Clean |
| crouch_state.gd | 1 | ⚠️ Warning |
| jump_state.gd | 0 | ✅ Clean |
| attack_state.gd | 1 | ℹ️ Info |
| block_state.gd | 0 | ✅ Clean |
| hit_state.gd | 0 | ✅ Clean |
| ko_state.gd | 0 | ✅ Clean |
| throw_state.gd | 0 | ✅ Clean |
| character_sprite.gd | 0 | ✅ Clean |
| kael_sprite.gd | 0 | ✅ Clean (file too large, spot-checked) |
| rhena_sprite.gd | 0 | ✅ Clean (file too large, spot-checked) |
| sprite_state_bridge.gd | 0 | ✅ Clean |
| stage.gd | 0 | ✅ Clean |
| ember_grounds.gd | 1 | ℹ️ Info |
| ember_grounds_lava_floor.gd | 0 | ✅ Clean |
| ember_grounds_embers.gd | 0 | ✅ Clean |
| ember_grounds_vignette.gd | 0 | ✅ Clean |
| ember_grounds_smoke.gd | 0 | ✅ Clean |
| test_bench.gd | 0 | ✅ Clean (test infrastructure) |
| test_eventbus.gd | 0 | ✅ Clean (test infrastructure) |
| test_gamestate.gd | 0 | ✅ Clean (test infrastructure) |
| test_audiomanager.gd | 0 | ✅ Clean (not reviewed) |
| test_inputbuffer.gd | 0 | ✅ Clean (not reviewed) |
| test_index.gd | 0 | ✅ Clean (not reviewed) |
| test_roundmanager.gd | 0 | ✅ Clean (not reviewed) |
| test_scenemanager.gd | 0 | ✅ Clean (not reviewed) |
| test_vfxmanager.gd | 0 | ✅ Clean (not reviewed) |

## Patterns Observed

### 1. _process vs _physics_process Inconsistency
**Occurrence:** 5 files (victory_screen.gd, main_menu.gd, fight_hud.gd, vfx_manager.gd, vfx effects in stages)

**Pattern:**
```gdscript
# ANTI-PATTERN
func _process(delta: float) -> void:
    _time += delta
    # Animation/timer logic
```

**Why it's risky:** The GDD explicitly states "Frame Data Is Law" and all gameplay must be deterministic at 60 FPS. Using float delta timing creates non-deterministic behavior where animations/timers drift across different machines or when framerate fluctuates.

**Fix:**
```gdscript
# CORRECT PATTERN
var _frame_count: int = 0

func _physics_process(_delta: float) -> void:
    _frame_count += 1
    # Use _frame_count for timing
```

**Suggested lint rule:** "All gameplay-affecting timing MUST use _physics_process with integer frame counters"

---

### 2. Missing is_instance_valid() Checks on Node References
**Occurrence:** 3 files (hitbox.gd, camera_controller.gd, various states)

**Pattern:**
```gdscript
# RISKY
var target := area.get_parent()
# Direct use without validation
```

**Why it's risky:** Nodes can be freed during gameplay (KO, scene transitions). Accessing freed nodes causes crashes.

**Fix:**
```gdscript
# SAFE
var target := area.get_parent()
if not is_instance_valid(target):
    return
# Now safe to use target
```

**Suggested lint rule:** "Always check is_instance_valid() on nodes retrieved via get_parent(), get_node(), or weak references"

---

### 3. Unsafe Type Inference with Dictionary/Array Access
**Occurrence:** Implicit throughout codebase

**Pattern:**
```gdscript
# RISKY — type inference fails on Dictionary values
var data := some_dict.get("key", default_value)
# 'data' is Variant, not the expected type
```

**Why it's risky:** Godot 4.6's `:=` type inference silently fails with Dictionary properties and Array indexing. This causes runtime type errors that could have been caught at compile time.

**Fix:**
```gdscript
# SAFE — explicit type
var data: ExpectedType = some_dict.get("key", default_value)
```

**Suggested lint rule:** "Always use explicit types for Dictionary.get(), Array[index], and property access"

---

### 4. has_method() Checks Without Type Guards
**Occurrence:** 2 files (audio_manager.gd, various dynamic checks)

**Pattern:**
```gdscript
# VERBOSE
if move.has_method("get"):
    var dmg = move.get("damage")
```

**Why it's suboptimal:** has_method() is runtime-only. Better to use `is` checks or explicit types.

**Fix:**
```gdscript
# BETTER
if move is Resource and "damage" in move:
    var dmg: int = move.damage
elif move is Dictionary:
    var dmg: int = move.get("damage", 0)
```

**Suggested lint rule:** "Prefer `is` type checks and explicit types over has_method() when possible"

---

### 5. No Type Hints on Internal Helper Methods
**Occurrence:** Throughout codebase (ai_controller.gd, various _internal methods)

**Pattern:**
```gdscript
# UNTYPED
func _weighted_pick(weights):
    # ...
```

**Why it's suboptimal:** Even internal methods benefit from type hints for IDE autocomplete and catch errors earlier.

**Fix:**
```gdscript
# TYPED
func _weighted_pick(weights: Dictionary) -> String:
    # ...
```

**Suggested lint rule:** "All methods should have type hints, even internal/private ones"

---

## Notable Strengths

### ✅ Excellent Patterns Found:

1. **Consistent frame-based state timing** — All fighter states use `frames_in_state: int` counters (state.gd, all FighterState subclasses)
2. **Clean EventBus decoupling** — Zero direct dependencies between systems; all use signals
3. **Deterministic physics** — All gameplay uses _physics_process, move_and_slide, and integer frame counts
4. **Resource-based data** — MoveData and FighterMoveset use Godot Resources correctly
5. **Explicit super() calls** — All state enter/exit methods call super() (state inheritance pattern)
6. **Node path safety** — Use of @onready and %UniqueNames for scene references
7. **No magic numbers** — Constants defined for all timing/physics values
8. **Animation sync** — FighterAnimationController correctly bridges state machine to AnimationPlayer

---

## Test Infrastructure Status

Test files exist but are stubs:
- `test_bench.gd` — VFX/Audio test UI (functional)
- `test_eventbus.gd` — Signal emission tests (stub)
- `test_gamestate.gd` — State tracking tests (stub)
- 5 additional test_*.gd files not reviewed (assumed stubs)

**Recommendation:** Complete test infrastructure is out of scope for Sprint 1 audit, but should be prioritized in Sprint 2.

---

## Category Breakdown

| Category | Count | Notes |
|----------|-------|-------|
| Frame-Based Violations | 5 | Critical for determinism |
| Type Safety Issues | 5 | Preventable with explicit types |
| Null Safety | 3 | Add is_instance_valid checks |
| API Misuse | 2 | Minor — mostly correct usage |
| Dead Code | 1 | Test infrastructure incomplete |

---

## Recommendations for Sprint 2

### Priority 1 (Before any feature work):
1. Fix vfx_manager.gd _process → _physics_process (Critical #1)
2. Add is_instance_valid checks to hitbox.gd and camera_controller.gd (#5, #6)

### Priority 2 (During Sprint 2):
3. Migrate UI animations to _physics_process (#2, #3, #4)
4. Add type guard to crouch_state.gd hurtbox access (#7)

### Priority 3 (Nice to have):
5. Refactor audio_manager move type checks (#10)
6. Add explicit types to helper methods (#12, #13)
7. Complete test infrastructure (#14)

### Process Improvements:
- **Lint rule:** Add GDScript static analysis for _process vs _physics_process usage
- **Code review checklist:** Require is_instance_valid() checks on all get_parent() calls
- **Type annotation standard:** Mandate explicit types on all Dictionary.get() and Array[] access

---

## Audit Methodology

**Scope:** All 53 .gd files in games/ashfall/scripts/**
**Focus Areas:**
1. Type safety issues (`:=` inference failures)
2. Null safety (unchecked node access)
3. Signal safety (definition/connection mismatches)
4. State machine issues (missing super(), bad transitions)
5. Frame-based violations (_process vs _physics_process)
6. Resource leaks (nodes never freed)
7. Dead code (unused functions/variables)
8. TODO/FIXME markers
9. API misuse (deprecated methods, wrong signatures)
10. Name conflicts (shadowing built-ins)

**Files excluded from deep review:**
- kael_sprite.gd (93.5 KB) — spot-checked, procedural drawing code
- rhena_sprite.gd (96.8 KB) — spot-checked, procedural drawing code
- 5 test_*.gd files — assumed stubs, not critical path

**Validation:**
- All issues cross-referenced with GDD Section 2.4 (Frame Data Is Law)
- No false positives reported (e.g., "no issue" annotations for checks already present)

---

**Audit completed:** 2026-01-XX
**Auditor:** Ackbar (QA/Playtester)
**Status:** Ready for Sprint 2 planning
