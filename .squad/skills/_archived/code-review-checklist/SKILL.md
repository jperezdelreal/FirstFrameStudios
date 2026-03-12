---
name: "code-review-checklist"
description: "Code review checklist for GDScript game systems in multi-agent development"
domain: "code-review"
confidence: "medium"
source: "Jango code review (Ashfall Pre-M3) — 24 issues across 31 files"
has_reference: true
---

## Context
Multi-agent game development needs systematic review to catch integration blockers, null safety violations, and state machine issues early. Patterns from Ashfall M1+M2 review where 5 blockers prevented the game from running.

## Core Patterns

- **Null safety on node references** — Check `opponent`, `owner`, autoloads before use. Always: `if not opponent or not is_instance_valid(opponent): return`
- **State machine init guarantee** — `_ready()` must call `transition_to("idle", {})` regardless of `initial_state` setting
- **Exported variables have defaults** — Magic numbers (frames, timers, distances) → `@export` with sensible defaults
- **Signals verified connected** — Grep for `.connect()` calls. Every signal needs ≥1 emitter AND ≥1 consumer doing meaningful work
- **GDD spec vs implementation** — Count required items in GDD, search code. If GDD says 6 buttons but code has 4 = blocker
- **Collision layers match docs** — project.godot [2d_physics] must match ARCHITECTURE.md. All physics nodes need EXPLICIT layer/mask

## Key Examples

**Safe node access:**
```gdscript
func _update_facing() -> void:
    if not opponent or not is_instance_valid(opponent):
        return
    if global_position.x < opponent.global_position.x:
        flip_h = false
```

**Review workflow:**
1. Read PR description
2. Grep for anti-patterns: `grep -r "opponent\." src/`, `grep -r "const [A-Z_]* = [0-9]" src/`
3. Run checklist on each new file
4. Verify integration points (signals, autoload order, collision layers)

## Anti-Patterns

- **Null dereference without checks** — `opponent.global_position` crashes if null
- **State machine without forced init** — Relying on scene `initial_state` setting
- **Hardcoded magic numbers** — Should be `@export` for tuning
- **Signals defined but never connected/emitted** — Dead code
- **Spec drift unvalidated** — Code doesn't match GDD
