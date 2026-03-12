# SKILL: State Machine Patterns for Game Entities

Robust state machine design for game entities. Every lesson here was learned the hard way — the player freeze bug, enemy passivity bug, and 3 timer conflation bugs in firstPunch all trace to violations of these patterns.

---
name: "state-machine-patterns"
description: "Robust state machine design — exit paths, transition guards, timeout safety nets, and common anti-patterns"
domain: "game-architecture"
confidence: "low"
source: "earned — extracted from firstPunch critical bugs (player freeze, enemy passivity, timer conflation)"
---

## When to Use This Skill
- Implementing entity state machines (player, enemies, bosses, NPCs)
- Debugging "entity stuck in state" or "entity does nothing" bugs
- Reviewing combat, AI, or animation state code
- Adding new states to existing entities
- Any system where an object transitions between discrete behavioral modes

## When NOT to Use This Skill
- Pure data transformations (no behavioral states)
- UI state managed by a framework (React/Vue state is a different paradigm)
- Simple on/off toggles (no transitions to manage)

---

## Core Patterns

### 1. Every State MUST Have an Exit Path

**THE lesson of the project.** The player freeze bug happened because `takeDamage()` set `state = 'hit'` but NO code ever transitioned back to `'idle'` when hitstun expired.

```javascript
// ❌ BROKEN — 'hit' state has no exit
takeDamage(amount) {
    this.state = 'hit';
    this.hitstunTime = 0.3;
}

update(dt) {
    this.hitstunTime -= dt;
    // ... but if state === 'hit' and hitstunTime <= 0, what happens?
    // NOTHING. Player is frozen forever.
}

// ✅ FIXED — explicit exit path for every state
update(dt) {
    this.hitstunTime -= dt;
    
    if (this.state === 'hit' && this.hitstunTime <= 0) {
        this.state = 'idle';  // THE MISSING LINE
    }
}
```

**Rule:** Before adding ANY new state, answer: **"How does the entity leave this state?"** If you can't answer in one sentence, the state is broken.

### 2. State Transition Table Documentation

Document every state as a table. If a cell is empty, that's a potential dead-end.

```
┌──────────────┬─────────────────────┬─────────────────────┬──────────────┐
│ State        │ Entry Condition     │ Per-Frame Behavior  │ Exit Path(s) │
├──────────────┼─────────────────────┼─────────────────────┼──────────────┤
│ idle         │ Default / recovery  │ Accept input        │ → walk, attack, jump, hit, grab │
│ walk         │ Movement input      │ Move + animate      │ → idle (no input), attack, jump, hit │
│ attack       │ Attack input        │ Run attack phases   │ → idle (recovery done), hit │
│ hit          │ takeDamage()        │ Decrement hitstun   │ → idle (hitstun ≤ 0), dead (hp ≤ 0) │
│ jump         │ Jump input          │ Apply gravity       │ → idle (landed), hit │
│ grab         │ Grab input + range  │ Hold timer          │ → idle (timeout 1.5s), throw, pummel │
│ dead         │ HP ≤ 0             │ Play death anim     │ → (removed from game) │
│ dodge        │ Dodge input         │ Move invulnerable   │ → dodge_recovery (timer 0.4s) │
│ dodge_recover│ Dodge ends          │ Brief vulnerability │ → idle (timer expires) │
└──────────────┴─────────────────────┴─────────────────────┴──────────────┘
```

### 3. Guard Conditions on Transitions

Not every transition should be allowed from every state. Guard conditions prevent invalid state changes.

```javascript
// ❌ BROKEN — attack overrides hit state (player attacks while stunned)
handleInput() {
    if (input.wasPressed('attack')) {
        this.state = 'attack';  // No guard — works even during hitstun!
    }
}

// ✅ FIXED — guard prevents attacking during non-actionable states
handleInput() {
    const actionableStates = ['idle', 'walk'];
    if (input.wasPressed('attack') && actionableStates.includes(this.state)) {
        this.state = 'attack';
    }
}
```

**Enemy AI guard (firstPunch lesson):** The enemy passivity bug happened because AI logic set `state = 'idle'` every frame during cooldown, overriding the `'attack'` state that was just set. Fix: protect animation-critical states from AI override.

```javascript
// ❌ BROKEN — AI override kills attack state
updateAI(dt) {
    if (this.aiCooldown > 0) {
        this.state = 'idle';       // Overrides 'attack' set 1 frame ago!
        return;
    }
}

// ✅ FIXED — protected states are immune to AI override
updateAI(dt) {
    const protectedStates = ['attack', 'windup', 'hit'];
    if (protectedStates.includes(this.state)) {
        return;  // Let the state run its course
    }

    if (this.aiCooldown > 0) {
        this.state = 'idle';
        return;
    }
}
```

### 4. Timeout Safety Nets

No timed state should last forever without explicit intent. Every state with a timer needs a maximum duration fallback.

```javascript
// Pattern: state with timeout safety net
update(dt) {
    if (this.state === 'grab') {
        this.grabTimer -= dt;

        // Normal exit: player throws or pummels
        if (input.wasPressed('attack')) { this.throw(); return; }

        // Safety net: auto-release after 1.5 seconds
        if (this.grabTimer <= 0) {
            this.state = 'idle';
            this.releaseGrabbedEnemy();
        }
    }
}
```

**Recommended timeouts:**

| State | Normal Exit | Safety Net Timeout |
|-------|-----------|-------------------|
| attack | Recovery timer expires | 2.0s max |
| hit/hitstun | Hitstun timer expires | 1.0s max |
| grab | Player input (throw/pummel) | 1.5s |
| dodge | Dodge distance reached | 0.5s |
| windup | Windup timer expires | 1.5s |
| invulnerable | Invuln timer expires | 3.0s |
| boss_transition | Animation completes | 5.0s |

**The "infinite" states:** `idle`, `walk`, `dead` are intentionally unbounded. Every OTHER state needs a timeout.

### 5. Timer Separation (The Conflation Anti-Pattern)

**firstPunch's worst recurring bug.** Using one timer for multiple purposes (attack duration AND cooldown AND AI decision delay) causes state corruption.

```javascript
// ❌ BROKEN — one timer, three jobs
update(dt) {
    this.aiCooldown -= dt;

    if (this.aiCooldown <= 0.3) {
        this.hitboxActive = true;     // "Active" phase
    }
    if (this.aiCooldown <= 0) {
        this.state = 'idle';          // "Recovery" done
        this.aiCooldown = 1.5;        // Reset for next decision
    }
}

// ✅ FIXED — separate timers for separate concerns
update(dt) {
    this.attackDuration -= dt;    // How long the attack animation lasts
    this.hitboxTimer -= dt;       // How long the hitbox is active
    this.aiCooldown -= dt;        // How long until next AI decision

    // Hitbox active only during its window
    this.hitboxActive = this.hitboxTimer > 0 && this.hitboxTimer < this.hitboxDuration;

    // Attack animation ends independently of AI
    if (this.attackDuration <= 0) {
        this.state = 'idle';
    }

    // AI decision happens independently of attack animation
    // (guarded by state check — won't override active attack)
}
```

---

## Testing State Machines

### Trace Every Path

For every state in the entity, simulate the path through frames:

```
Frame 0: Entity in 'idle'
Frame 1: takeDamage() called → state = 'hit', hitstunTime = 0.3
Frame 2: update(0.016) → hitstunTime = 0.284, still 'hit' ✓
...
Frame 19: update(0.016) → hitstunTime ≈ 0.0, transition to 'idle' ✓
Frame 20: Entity in 'idle' ✓ — EXIT PATH CONFIRMED
```

**If you can't trace from entry to exit in <60 frames, the state probably has a bug.**

### State Machine Audit Checklist

For every entity state machine, verify:

```
For EACH state:
  □ Entry condition documented
  □ Per-frame behavior documented
  □ At least 1 exit path exists
  □ Exit condition is reachable (timer decrements, input checked, etc.)
  □ Timeout safety net exists (for timed states)
  □ Protected from external override (for animation-critical states)
  □ Timer(s) are dedicated (not shared with other concerns)

For the machine as a whole:
  □ Transition table is complete (no empty exit cells)
  □ All distance thresholds are coherent (draw the number line)
  □ No two systems independently set the same state variable
  □ Default/fallback state is reachable from all states
```

---

## Anti-Patterns

1. **Dead-end states** — A state with no exit path. The entity enters and never leaves. Always the highest-severity bug class. (Player freeze: `'hit'` with no transition back to `'idle'`.)

2. **Timer conflation** — One timer controlling attack duration, cooldown, and AI delay. Separate timers for separate concerns. (Caused 3 critical enemy bugs: 1-frame attacks, windup override, hitbox inversion.)

3. **Unguarded state override** — AI or input logic forcefully sets `state = 'idle'` without checking if the entity is in a protected state. (Enemy passivity: AI set `'idle'` during `'attack'`.)

4. **Missing negative code** — The bug is not in code that exists, but in code that DOESN'T exist. A missing `if (state === 'hit' && timer <= 0) state = 'idle'` is invisible when reading code — you must trace execution paths to catch it.

5. **Distance threshold dead zones** — Attack range and approach distance don't overlap, creating zones where the entity can't decide what to do. (Enemy orbited forever: approach threshold 150px but attack range only 80px, with circle distance at 125px.)

6. **State set in multiple places** — Two different systems (input handler + AI + animation callback) all set `this.state`, potentially fighting each other on the same frame. State changes should route through a single `setState()` method with guards.

7. **Testing by reading, not tracing** — Reading `if (state === 'hit')` looks correct. Tracing frame-by-frame reveals the timer never reaches the threshold. Always simulate 3-5 consecutive frames mentally.

---

## Checklist

Before shipping any state machine change:

- [ ] New state has at least one documented exit path
- [ ] Exit condition is reachable (timer actually decrements, or input is actually checked)
- [ ] Timeout safety net exists for timed states (max 5s for any state)
- [ ] Protected states list updated if new animation-critical state added
- [ ] No timer serves double duty (separate timers for separate concerns)
- [ ] Distance thresholds drawn on number line (no dead zones)
- [ ] Frame-by-frame trace from entry to exit completed (≤60 frames)
- [ ] No code path sets state without checking guards
- [ ] Transition table updated with new state
- [ ] Tested: entity enters new state and returns to idle within expected time
