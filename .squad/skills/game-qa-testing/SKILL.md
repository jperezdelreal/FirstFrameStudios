# SKILL: Game QA & Testing

Quality assurance patterns specific to games — execution tracing, state machine audits, and structured playtesting.

---
name: "game-qa-testing"
description: "QA patterns for games — execution tracing, state machine audits, playtest protocols, bug severity, regression testing"
domain: "testing"
confidence: "low"
has_reference: true
source: "earned — extracted from firstPunch QA process (Ackbar's self-assessment, missed bugs, quality excellence proposal)"
---

## Context

Reading code is not testing. You must trace execution paths frame-by-frame and verify that every state machine actually exits. This skill covers game-specific QA: state machine audits, frame-level tracing, adversarial playtesting, bug severity triage, and regression checklists. Use for any game QA task; not for unit testing pure functions or non-game UI testing.

## Core Patterns

### Trace Execution, Don't Just Read Code
For every state machine, trace at least one complete path from entry to exit. If you can't reach exit in <60 frames, the state has a bug. Reading `if (state === 'hit')` looks correct; tracing frame-by-frame reveals the exit condition is never reached.

### State Machine Audit
For every entity, build a table: State | Entry Condition | Per-Frame Behavior | Exit Path(s) | Timeout. Look for: empty exit paths (dead-end state), missing timeouts, timers that don't decrement, and two systems independently setting state.

### Testing Layers (all required)
1. **Code trace** — frame-by-frame mental sim (catches dead-end states)
2. **Smoke test** — launch and play 30 seconds (catches crashes)
3. **Feature test** — test specific new feature
4. **Regression test** — run 10-item checklist after ANY combat change
5. **Adversarial test** — spam inputs, edge cases, simultaneous events
6. **Full playtest** — play full level naturally for balance/pacing/feel

### Bug Severity & Triage
- 🔴 **CRITICAL** — game unplayable, player stuck → never ship
- 🟠 **HIGH** — core mechanic broken → fix before ship
- 🟡 **MEDIUM** — partial feature, workaround exists → ship with notes
- 🟢 **LOW** — polish issue → log for future, don't block ship

### Absence-of-Code Detection
The hardest bugs are missing code. Compare design doc state transitions against actual code — every row should map to a line of code. Missing mappings are potential CRITICAL bugs.

## Key Examples

**Frame-by-frame trace catching a bug:**
```
Frame 0: Player 'idle', HP=100
Frame 1: Enemy attacks → takeDamage(10) → state='hit', hitstunTime=0.3
Frame 2: update(0.016) → hitstunTime=0.284... state still 'hit'
...
Frame 19: hitstunTime ≈ 0 → WHERE IS THE TRANSITION? → 🐛 BUG: no 'hit' → 'idle' code
```

**10-item regression checklist (run after any combat change):**
```
□ 1. Light attack combo completes    □ 6. Combo counter increments/resets
□ 2. Jump attack → idle on landing   □ 7. Can't attack during hitstun
□ 3. Player damage → recovers        □ 8. Score increments on kill
□ 4. I-frames active after damage    □ 9. Wave progresses after clear
□ 5. Enemy approaches and attacks    □ 10. No crash in 30-second session
```

## Anti-Patterns

1. **Reading ≠ Testing** — read for understanding, trace for verification
2. **File coverage ≠ path coverage** — "I read every file" doesn't mean "I found every bug"
3. **Happy path only** — test edge cases: attack during hitstun, die while grabbing, boundary jumps
4. **Subjective-only QA** — "feels good" is not QA; measure DPS, frame data, state durations
5. **False positive reporting** — reproduce bugs before reporting; verify they're real
6. **No regression after changes** — combat is coupled; run the checklist after every change
7. **Overconfidence** — max 8/10 confidence without full state audit + adversarial playtest + level playthrough
