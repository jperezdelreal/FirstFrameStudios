---
name: "state-machine-patterns"
description: "Robust state machine design — exit paths, transition guards, timeout safety nets, and common anti-patterns"
domain: "game-architecture"
confidence: "low"
source: "earned — extracted from firstPunch critical bugs (player freeze, enemy passivity, timer conflation)"
has_reference: true
---

## Context

Robust state machine design for game entities, distilled from critical bugs in firstPunch (player freeze, enemy passivity, timer conflation). Apply when implementing, debugging, or reviewing entity state machines for players, enemies, bosses, or NPCs. Not applicable to UI framework state or simple on/off toggles.

## Core Patterns

### Every State Must Have an Exit Path
Before adding any state, answer: **"How does the entity leave this state?"** If you can't answer in one sentence, the state is broken. Document states using a transition table with Entry Condition, Per-Frame Behavior, and Exit Path(s) — empty exit cells indicate dead-ends.

### Guard Conditions on Transitions
Not every transition is valid from every state. Maintain an `actionableStates` list for input-driven transitions and a `protectedStates` list (e.g., `'attack'`, `'windup'`, `'hit'`) that are immune to AI/external override.

### Timeout Safety Nets
Every timed state needs a maximum duration fallback. Recommended maximums: attack 2.0s, hitstun 1.0s, grab 1.5s, dodge 0.5s, invulnerable 3.0s, boss_transition 5.0s. Only `idle`, `walk`, `dead` are intentionally unbounded.

### Separate Timers for Separate Concerns
Never use one timer for multiple purposes (attack duration AND cooldown AND AI delay). Each concern gets its own timer variable to prevent state corruption.

### Single Point of State Change
Route all state changes through a single `setState()` method with guards. Multiple systems (input, AI, animation) writing `this.state` directly causes same-frame conflicts.

## Key Examples

**Dead-end state (player freeze bug):**
```javascript
// ❌ 'hit' state with no exit — player frozen forever
takeDamage(amount) { this.state = 'hit'; this.hitstunTime = 0.3; }
update(dt) { this.hitstunTime -= dt; /* no transition back! */ }

// ✅ Explicit exit path
update(dt) {
    this.hitstunTime -= dt;
    if (this.state === 'hit' && this.hitstunTime <= 0) {
        this.state = 'idle';
    }
}
```

**Unguarded AI override (enemy passivity bug):**
```javascript
// ❌ AI resets state every frame, killing active attacks
updateAI(dt) {
    if (this.aiCooldown > 0) { this.state = 'idle'; return; }
}

// ✅ Protected states immune to override
updateAI(dt) {
    const protectedStates = ['attack', 'windup', 'hit'];
    if (protectedStates.includes(this.state)) return;
    if (this.aiCooldown > 0) { this.state = 'idle'; return; }
}
```

## Anti-Patterns

1. **Dead-end states** — No exit path; entity enters and never leaves. Highest-severity bug class.
2. **Timer conflation** — One timer for multiple concerns causes state corruption (1-frame attacks, hitbox inversion).
3. **Unguarded state override** — AI/input sets state without checking protected states.
4. **Missing negative code** — Bug is in code that doesn't exist (missing exit transition). Only found by tracing execution, not reading.
5. **Distance threshold dead zones** — Non-overlapping approach/attack ranges create indecision zones.
6. **Testing by reading, not tracing** — Always simulate 3-5 consecutive frames mentally; reading `if` conditions looks correct but hides timing bugs.

## Checklist

- [ ] New state has documented exit path reachable within 60 frames
- [ ] Timeout safety net exists for all timed states (max 5s)
- [ ] Protected states list updated for animation-critical states
- [ ] No timer serves double duty
- [ ] Transition table updated; no empty exit cells
- [ ] No code path sets state without guards
