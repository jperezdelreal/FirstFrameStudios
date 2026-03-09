# Skill: GDScript Godot 4.6 Patterns

## Confidence: high
## Domain: GDScript, Godot 4.6, type safety, fighting game architecture

## Summary

Sprint 1 of Ashfall (Godot 4.6 fighting game) revealed systematic bugs in type inference, input handling, and frame data management. This skill captures the patterns that work reliably in Godot 4.6 and the anti-patterns that cause silent failures in exports.

**Key Insight:** Godot 4.6 is NOT Python. Type inference with `:=` fails on Dictionary/Array access and `abs()` calls, producing `Variant` instead of concrete types. This works in editor but breaks in Windows exports.

## Patterns

### Pattern 1: Explicit Type Annotations for Dictionary/Array Access

**Problem:** `:=` from `dict["key"]` or `array[idx]` infers `Variant`, not the expected type.

**Solution:** Always use explicit type annotations.

```gdscript
# ❌ ANTI-PATTERN — infers Variant
var fc := palette["flash_color"]      # Variant, not Color
var player := _sfx_pool[idx]           # Variant, not AudioStreamPlayer
var round_num := parts[1].to_int()     # Variant, not int

# ✅ CORRECT PATTERN — explicit types
var fc: Color = palette["flash_color"]
var player: AudioStreamPlayer = _sfx_pool[idx]
var round_num: int = parts[1].to_int()
```

**Why it matters:** Runtime errors in exports, null reference crashes, function signature mismatches.

---

### Pattern 2: Type-Specific Math Functions

**Problem:** `abs()`, `min()`, `max()`, `clamp()` return `Variant` for legacy compatibility.

**Solution:** Use type-specific versions: `absf()`, `absi()`, `minf()`, `mini()`, etc.

```gdscript
# ❌ ANTI-PATTERN
var dist := abs(a - b)

# ✅ CORRECT PATTERN
var dist: float = absf(a - b)
```

---

### Pattern 3: Native Button Nodes for Menu Input

**Problem:** Custom `_input()` with `InputEventKey` matching works in editor but breaks in Windows exports.

**Solution:** Use native `Button` nodes with `grab_focus()` and signal connections.

```gdscript
# ✅ CORRECT PATTERN
@onready var button := $SelectButton

func _ready() -> void:
    button.pressed.connect(_on_select)
    button.grab_focus()
```

---

### Pattern 4: Never Override Engine ui_* Actions

**Problem:** Custom `ui_accept`, `ui_cancel` in `project.godot` replaces Godot defaults. Works in editor, breaks in exports.

**Solution:** Use engine defaults for UI, add game-specific actions separately.

---

### Pattern 5: Frame-Based Timing (Fighting Games)

**Problem:** Float timers introduce non-determinism.

**Solution:** Integer frame counters at 60 FPS fixed tick.

```gdscript
# ✅ CORRECT PATTERN
var frames_in_state: int = 0

func _physics_process(_delta: float) -> void:
    frames_in_state += 1
    if frames_in_state >= 30:  # 30 frames = 0.5s at 60 FPS
        _transition()
```

## References

- [Ashfall Sprint 1 Lessons Learned](../../games/ashfall/docs/SPRINT-1-LESSONS-LEARNED.md)
- [Ashfall GDScript Standards](../../games/ashfall/docs/GDSCRIPT-STANDARDS.md)

**Owner:** Jango (Tool Engineer)  
**Last Updated:** 2026-03-11
