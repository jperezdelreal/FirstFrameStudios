# SKILL: Input Handling

Input is the player's direct voice to the game. Input latency budget, buffering strategies, platform-specific handling, and accessibility through remapping transform input from technical detail into a core pillar of game feel.

---

name: "input-handling"
description: "Universal input system design — buffering, latency budgets, action mapping, multiplatform support, accessibility, testing patterns"
domain: "engine-architecture"
confidence: "medium"
source: "firstPunch (Canvas keyboard), patterns universal across all engines/genres"
has_reference: true

---

## Context

Use when building new game input architecture, transitioning engines, game feels unresponsive/"eats inputs", supporting multiple input methods (keyboard/gamepad/touch), implementing accessibility (remapping), or for any genre where input feel matters. Not for simple UI pointer/click, turn-based strategy, or 3D games with built-in input systems (though read Principle #2).

## Core Patterns

### Latency Budget: Total ≤ 100ms
Input → Game Loop → Update → Render → Display = ~8-50ms total. Input systems must consume < 8ms (ideally < 1ms). Players notice delays ≥ 50ms. Every 16.7ms = 1 frame at 60 FPS.

### Input Buffering: Ring Buffer Pattern
Store recent inputs (6-10 frames, 100-167ms window). Players press faster than state machines consume. Without buffering, inputs vanish ("eaten input" feel).

```javascript
buffer.push(action, timestamp);
buffer.consume(action, currentTime); // Returns true if found within expiry window
buffer.clear(); // On major state transitions
```

**Clear strategically:** Clear on state entry (attack → recovery) to prevent stacking. Don't clear on safe transitions (idle → attack).

### Coyote Time / Grace Periods
Allow action *slightly after* valid window closes. Jump allowed 4-6 frames (67-100ms) after leaving ground. Human reaction time ≈ 200ms, so by time finger hits button, window has closed. Coyote time is generous design, not a bug.

**Tuning:** Jump after ground: 100-150ms. Defend after hit: 50-100ms. Grab startup: 30-50ms. Start generous (120ms), tighten if playtesting requires.

### Action Mapping: Abstract from Physical Keys
```javascript
// WRONG: Hard-coded keys
if (input.isHeld('KeyJ')) attack();

// RIGHT: Abstract action
if (input.isHeld('attack')) attack();
```

**Benefits:** Remappable, portable (keyboard → gamepad), testable, accessible.

**Action Types:** PRESS (discrete, 1 frame), HOLD (continuous), RELEASE (trigger on key-up), DOUBLE_TAP (2 presses in window), CHARGE (hold > duration).

## Key Examples

### Directional Input: Last-Pressed Wins
Player presses Left then Right quickly. Both arrive same frame. Intent: "switch to right." Solution: timestamp each press, last-pressed wins.

```javascript
if (leftTime > rightTime) x = -1;
else if (rightTime > leftTime) x = 1;
else x = 0;
```

### Input Priority & Consumption
Simultaneous actions need priority queue. Pause (priority 0, highest) > hit (90) > attack (80) > dodge (75) > jump (70) > movement (50) > idle (0). When one system handles input, others don't see it ("consumption").

### Platform-Specific
**Keyboard:** Key repeat (ignore `e.repeat`), focus loss (clear on blur), modifier keys (Shift/Ctrl/Alt).

**Gamepad:** Dead zones (20% typical), pressure sensitivity, vibration API, multiple gamepads. Analog stick: `applyDeadZone(value) { if (abs(value) < 0.2) return 0; }`.

**Touch:** Virtual buttons, gesture recognition (tap, swipe, hold), visual feedback, variable screen sizes. Render buttons, detect touch in button bounds.

## Anti-Patterns

- **Raw Polling Only:** No buffering. `if (input.isHeld('attack')) attack();` executes every frame. Fix: Use buffer + state transitions.
- **Fixed Key Mapping:** No remapping. Accessibility failure. Fix: InputMapper with configurable bindings.
- **Input in Render Loop:** Frame-dependent behavior. Fix: Process input in `update()`, not `render()`.
- **Eating Inputs Silently:** Menu closes, game doesn't see input. Fix: InputConsumer pattern.
- **No Coyote Time:** Tight windows, unforgiving. Fix: Add 6f grace after leaving ground.

**Full details:** See REFERENCE.md for complete ring buffer implementation, coyote window patterns, input mapper architecture, directional input, priority/conflict resolution, platform-specific handlers (keyboard/gamepad/touch), cross-platform unified API, debug overlays, input recording/playback, latency measurement, firstPunch learnings (recursion bug fix), and checklist for any game.