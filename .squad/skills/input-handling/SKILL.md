# SKILL: Input Handling

Input is the player's direct voice to the game. It is the moment of connection. Input latency budget, buffering strategies, platform-specific handling, and accessibility through remapping transform input from a technical detail into a core pillar of game feel.

---

name: "input-handling"
description: "Universal input system design — buffering, latency budgets, action mapping, multiplatform support, accessibility, and testing patterns"
domain: "engine-architecture"
confidence: "medium"
source: "validated in firstPunch (Canvas keyboard + Web Audio), patterns are universal across all engines and genres"

---

## When to Use This Skill

- Building a new game and need input architecture from day 1
- Transitioning from one engine to another (Canvas → Godot, etc.)
- Game feels unresponsive or "eats inputs" — need buffering strategy
- Supporting multiple input methods (keyboard, gamepad, touch)
- Implementing accessibility features like control remapping
- Platformers, beat 'em ups, action games, any genre where input feels matters
- Mobile/web game that needs touch or gamepad support

## When NOT to Use This Skill

- Simple UI with pointer/click only (use native web input)
- Game with no time-sensitive input (turn-based strategy)
- 3D games with built-in input systems (Unity, Unreal — still read Principle #2 though)

---

## Principle: "Input Is the Player's Voice"

**Responsiveness is non-negotiable.** The player presses a button. The game should *feel* instant, even when complex systems lurk beneath. Input latency is the first metric players feel — before frame rate, before graphics, before narrative.

### Latency Budget: Total ≤ 100ms

- Input captured: ~0-1ms (OS polling)
- Game loop delay: ~8ms (waiting for next frame at 60 FPS)
- Update → Physics → Render: ~8-16ms (one frame)
- Rendering delay: 0-33ms (monitor refresh interval)
- Display lag: variable (monitor + GPU pipeline)

**Frame of delay = 16.7ms at 60 FPS.** Most players notice delays ≥ 50ms. Input systems must consume < 8ms (ideally < 1ms) to leave room for everything else.

### Why Latency Matters

- **Fighting games:** 1-frame difference changes combos. SoR4 targets <100ms total. SFVI: 4-frame input window minimum.
- **Platformers:** Jump responsiveness is make-or-break. Celeste allows jump input 6 frames after leaving ground (coyote time).
- **Action games:** Every attack, dodge, or interact must feel instant or the game feels broken.

---

## Input Buffering: Storing Inputs the Player Actually Pressed

### What Is Input Buffering?

Players press inputs faster than state machines can consume them. Without buffering, these inputs vanish and the player feels the game "ate" their input. Input buffering stores recent inputs in a ring buffer, allowing state transitions to consume them.

### Ring Buffer Pattern

```javascript
export class InputBuffer {
    constructor(bufferSize = 10) {
        this.buffer = Array(bufferSize).fill(null);
        this.head = 0;
        this.size = bufferSize;
        this.inputExpiry = 0.15; // 150ms = 9 frames at 60 FPS
    }

    push(action, timestamp) {
        this.buffer[this.head] = { action, timestamp };
        this.head = (this.head + 1) % this.size;
    }

    consume(action, currentTime) {
        // Find the most recent matching action within expiry window
        for (let i = 0; i < this.size; i++) {
            const entry = this.buffer[i];
            if (entry && entry.action === action) {
                const age = currentTime - entry.timestamp;
                if (age < this.inputExpiry) {
                    this.buffer[i] = null;
                    return true;
                }
            }
        }
        return false;
    }

    clear() {
        this.buffer.fill(null);
    }
}
```

### Buffer Window: 6-10 Frames (100-167ms)

- **6 frames (100ms):** Tight. Good for precise action games (fighting games, rhythm).
- **10 frames (167ms):** Generous. Good for platformers where buffering prevents feel of "eaten input."
- **Test empirically:** Let players feel both. They'll tell you which is more satisfying.

### When to Clear the Buffer

Buffers can hide stale inputs. Clear strategically:
- When state transitions to a new action type (e.g., from attack to hit) — don't let old attack presses stack
- When state enters recovery or invulnerability — don't let buffered attacks execute during untargetable frames
- On major state changes (idle → attack is safe; but attack → hit should clear attack buffer)

```javascript
// In state machine update:
if (this.state === 'idle' && this.inputBuffer.consume('attack')) {
    this.state = 'attack';
    this.inputBuffer.clear();  // Clear on state entry to prevent stacking
}
```

### Buffering Limitations

Buffering is not magic. It stores inputs *that happened*, not inputs the player *intended*. Use buffering for:
- ✅ Quick inputs during animations
- ✅ Combo sequences (press, press, press → execute)
- ❌ NOT as an apology for bad game feel
- ❌ NOT as a substitute for animation responsiveness

If buffering is your only input tool, the game still feels sluggish.

---

## Coyote Time / Grace Periods: Generous Windows for Human Reaction

### What Is Coyote Time?

Coyote time is a grace period where a player can perform an action *slightly after* the valid window closes. Named after Road Runner cartoons where characters run off cliffs and only fall once they look down.

### Real-World Examples

**Platformers:**
- Jump allowed 4-6 frames (67-100ms) after leaving a ledge
- Players at 200ms reaction time don't realize they "shouldn't" have been able to jump
- Result: game feels forgiving, not cheap

**Fighters:**
- Block allowed 2-3 frames after hit connects (let opponent block on reaction)
- Anti-air shoryuken allowed during jump startup (not just on-ground)
- Result: defense feels responsive, offense isn't oppressive

**Action Games:**
- Dodge allowed 3-4 frames after damage taken (reaction window)
- Grab allowed 2-3 frames before animation completes (visual lead-ahead)

### Why It Matters

**Human reaction time ≈ 200ms.** A player *sees* a hazard and reacts, but by the time their finger hits the button (16 frames later at 60 FPS), the valid window has already closed. Coyote time is *generous design*, not a bug.

### Implementation Pattern

```javascript
export class CoyoteWindow {
    constructor(duration = 0.1) {
        this.duration = duration;
        this.timeSinceClosed = Infinity;
    }

    open() {
        this.timeSinceClosed = 0;
    }

    tick(dt) {
        if (this.timeSinceClosed !== Infinity) {
            this.timeSinceClosed += dt;
        }
    }

    close() {
        if (this.timeSinceClosed === 0) {
            // Was actively open this frame, now closing
            // timeSinceClosed will start counting at next tick
        }
    }

    isValid() {
        return this.timeSinceClosed < this.duration;
    }

    reset() {
        this.timeSinceClosed = Infinity;
    }
}
```

### Tuning Coyote Time

| Context | Window (ms) | Window (frames @ 60fps) | Feel |
|---------|-----------|------------------------|------|
| Jump after leaving ground | 100-150 | 6-9 | Forgiving, skill-based |
| Defend after hit | 50-100 | 3-6 | Tactical |
| Grab startup | 30-50 | 2-3 | Quick window, high risk |
| Action recovery | 100-200 | 6-12 | Generous, easy to chain |

**Start generous (120ms). Let playtesting make it tighter if needed.** Players rarely complain that coyote windows are too wide — they complain when they're invisible.

---

## Input Mapping Architecture: Abstract Actions from Physical Keys

### Why Abstract Actions Matter

```javascript
// ❌ DON'T DO THIS (hard-coded keys)
if (input.isHeld('KeyJ')) {  // J key = attack
    this.attack();
}

// ✅ DO THIS (abstract action)
if (input.isHeld('attack')) {
    this.attack();
}
```

Benefits:
1. **Remappable:** Player rebinds attack from J to Z → one config change
2. **Portable:** Switch from keyboard to gamepad. Action name stays the same
3. **Testable:** Test code says `input.simulate('attack')` without knowing which key triggers it
4. **Accessible:** Player with limited hand mobility rebinds to more reachable keys

### Action Type System

Not all inputs are created equal. Define action *types*:

```javascript
export const ACTION_TYPES = {
    PRESS: 'press',           // Discrete — one frame
    HOLD: 'hold',             // Continuous — multiple frames
    RELEASE: 'release',       // Trigger on key-up
    DOUBLE_TAP: 'double-tap', // Two presses within window
    CHARGE: 'charge',         // Hold > duration threshold
};

export class InputAction {
    constructor(name, type, defaultKeys) {
        this.name = name;      // e.g., 'attack'
        this.type = type;      // PRESS, HOLD, etc.
        this.keys = defaultKeys; // ['KeyJ', 'GamepadButton0']
        this.pressed = false;
        this.held = false;
        this.released = false;
    }
}
```

### Input Mapper

```javascript
export class InputMapper {
    constructor(actions = []) {
        this.actions = new Map();
        this.keyMap = new Map();  // Key → action(s)
        this.gamepadDeadZones = new Map();

        actions.forEach(action => this.registerAction(action));
    }

    registerAction(action) {
        this.actions.set(action.name, action);
        action.keys.forEach(key => {
            if (!this.keyMap.has(key)) this.keyMap.set(key, []);
            this.keyMap.get(key).push(action.name);
        });
    }

    remapAction(actionName, newKeys) {
        const action = this.actions.get(actionName);
        if (!action) return;

        // Remove old mappings
        action.keys.forEach(key => {
            const actions = this.keyMap.get(key);
            this.keyMap.set(key, actions.filter(a => a !== actionName));
        });

        // Add new mappings
        action.keys = newKeys;
        newKeys.forEach(key => {
            if (!this.keyMap.has(key)) this.keyMap.set(key, []);
            this.keyMap.get(key).push(actionName);
        });
    }

    // Store/restore from JSON for player preferences
    export() {
        return Array.from(this.actions.values()).map(a => ({
            name: a.name,
            keys: a.keys,
        }));
    }

    import(config) {
        config.forEach(({ name, keys }) => {
            this.remapAction(name, keys);
        });
    }
}
```

### Standard Action Set

Every game has core actions. Define them:

```javascript
export const STANDARD_ACTIONS = [
    new InputAction('up', ACTION_TYPES.HOLD, ['ArrowUp', 'GamepadDPadUp']),
    new InputAction('down', ACTION_TYPES.HOLD, ['ArrowDown', 'GamepadDPadDown']),
    new InputAction('left', ACTION_TYPES.HOLD, ['ArrowLeft', 'GamepadDPadLeft']),
    new InputAction('right', ACTION_TYPES.HOLD, ['ArrowRight', 'GamepadDPadRight']),
    
    new InputAction('attack', ACTION_TYPES.PRESS, ['KeyJ', 'GamepadButton0']),
    new InputAction('jump', ACTION_TYPES.PRESS, ['Space', 'GamepadButton2']),
    new InputAction('grab', ACTION_TYPES.PRESS, ['KeyK', 'GamepadButton1']),
    new InputAction('special', ACTION_TYPES.PRESS, ['KeyL', 'GamepadRB']),
    
    new InputAction('pause', ACTION_TYPES.PRESS, ['Escape', 'GamepadStart']),
    new InputAction('menu-select', ACTION_TYPES.PRESS, ['Enter', 'GamepadButton0']),
    new InputAction('menu-back', ACTION_TYPES.PRESS, ['Escape', 'GamepadButton1']),
];
```

---

## Directional Input: 4-Way vs 8-Way, Last-Pressed Wins

### The Problem: Simultaneous Opposite Directions

Player presses Left then Right quickly. The inputs arrive in the same frame:
```
Frame 1: keys = { left: true, right: true }
```

What's the intent? The player meant "switch to right." The solution: **last-pressed wins**.

### Last-Pressed Pattern

```javascript
export class DirectionalInput {
    constructor() {
        this.x = 0;    // -1, 0, or 1
        this.y = 0;    // -1, 0, or 1
        
        // Timestamp of most recent change
        this.xLastPressed = { left: 0, right: 0 };
        this.yLastPressed = { up: 0, down: 0 };
        this.time = 0;
    }

    update(input) {
        this.time++;
        
        // X axis
        if (input.isHeld('left')) this.xLastPressed.left = this.time;
        if (input.isHeld('right')) this.xLastPressed.right = this.time;
        
        if (this.xLastPressed.left > this.xLastPressed.right) {
            this.x = -1;
        } else if (this.xLastPressed.right > this.xLastPressed.left) {
            this.x = 1;
        } else {
            this.x = 0;
        }

        // Y axis (same logic)
        if (input.isHeld('up')) this.yLastPressed.up = this.time;
        if (input.isHeld('down')) this.yLastPressed.down = this.time;
        
        if (this.yLastPressed.up > this.yLastPressed.down) {
            this.y = -1;
        } else if (this.yLastPressed.down > this.yLastPressed.up) {
            this.y = 1;
        } else {
            this.y = 0;
        }
    }

    get direction() {
        return { x: this.x, y: this.y };
    }
}
```

### 4-Way vs 8-Way

- **4-Way:** Only cardinal directions (N, S, E, W). Simplest, common in grid-based or strict directional games.
- **8-Way:** Includes diagonals (NE, NW, SE, SW). Rich expressivity for analog input or fighting game commands.

**Implementation:**
```javascript
const direction = directionalInput.direction;

if (direction.x !== 0 && direction.y !== 0) {
    // Both pressed — this is a diagonal (8-way)
    // In 4-way mode, pick the most recently pressed axis
    const xRecentness = Math.max(input.xLastPressed.left, input.xLastPressed.right);
    const yRecentness = Math.max(input.yLastPressed.up, input.yLastPressed.down);
    
    if (xRecentness > yRecentness) {
        direction.y = 0;  // Ignore Y, keep X
    } else {
        direction.x = 0;  // Ignore X, keep Y
    }
}
```

---

## Input Priority & Conflict Resolution

### The Problem: Simultaneous Actions

Player presses attack + jump in the same frame. What happens?

```
Frame 1: actions = ['attack', 'jump']
```

You need a *priority queue*.

### Priority System

```javascript
export class InputPriority {
    constructor() {
        this.priorities = new Map([
            ['attack', 1],
            ['jump', 2],
            ['grab', 1],
            ['dodge', 3],
            ['movement', 10],  // Lowest number = highest priority
            ['pause', 0],       // Highest priority (always interrupts)
        ]);
    }

    sort(actions) {
        return actions.sort((a, b) => {
            const pA = this.priorities.get(a) ?? 999;
            const pB = this.priorities.get(b) ?? 999;
            return pA - pB;
        });
    }
}
```

### Input Consumption ("Eating" Inputs)

When one system handles an input, other systems shouldn't see it:

```javascript
export class InputConsumer {
    constructor() {
        this.consumed = new Set();
    }

    consume(action) {
        this.consumed.add(action);
    }

    isConsumed(action) {
        return this.consumed.has(action);
    }

    clear() {
        this.consumed.clear();
    }
}
```

**Usage in scene update:**
```javascript
const priority = new InputPriority();
const actions = input.getActivePressActions();
const sorted = priority.sort(actions);

const consumer = new InputConsumer();

// Menu system (highest priority)
if (scene.menuOpen) {
    for (const action of sorted) {
        if (consumer.isConsumed(action)) continue;
        if (scene.menu.handleAction(action)) {
            consumer.consume(action);
            break; // Menu handled it
        }
    }
    return; // Don't process gameplay
}

// Gameplay systems
for (const action of sorted) {
    if (consumer.isConsumed(action)) continue;
    
    if (action === 'attack' && player.canAttack()) {
        player.attack();
        consumer.consume(action);
    } else if (action === 'jump' && player.canJump()) {
        player.jump();
        consumer.consume(action);
    }
}
```

### Movement Always Processes

Movement is special — it's usually non-exclusive. Even if attack consumed input, movement still runs:

```javascript
// Gameplay update (after attack/jump/grab handling)
const dir = directionalInput.direction;
if (dir.x !== 0 || dir.y !== 0) {
    player.move(dir.x, dir.y);  // Always runs if input active
}
```

---

## Platform-Specific Patterns

### Keyboard (Desktop)

**Challenges:**
- Key repeat (OS repeats key-down events every ~500ms)
- Modifier keys (Shift, Ctrl, Alt affect behavior)
- Focus loss (user switches tabs, keys get stuck)

**Solutions:**

```javascript
export class KeyboardInput {
    constructor() {
        this.keys = {};
        this.keysPressed = {};
        this.keysReleased = {};
        this.skipRepeat = new Set();  // Keys to ignore repeat

        window.addEventListener('keydown', e => {
            // Ignore repeat events
            if (e.repeat) return;
            
            // Capture on first press
            if (!this.keys[e.code]) {
                this.keysPressed[e.code] = true;
            }
            this.keys[e.code] = true;
        });

        window.addEventListener('keyup', e => {
            this.keys[e.code] = false;
            this.keysReleased[e.code] = true;
        });

        // Handle tab switches — clear all keys on blur
        window.addEventListener('blur', () => {
            this.keys = {};
            this.keysPressed = {};
            this.keysReleased = {};
        });

        // Modifier keys — can be used for secondary actions
        this.shiftHeld = false;
        window.addEventListener('keydown', e => {
            if (e.shiftKey) this.shiftHeld = true;
        });
        window.addEventListener('keyup', e => {
            if (!e.shiftKey) this.shiftHeld = false;
        });
    }

    clearFrameState() {
        this.keysPressed = {};
        this.keysReleased = {};
    }
}
```

**Standards:**
- Arrow keys or WASD for movement
- Space for jump/action
- Escape for pause/menu
- Numbers (1-4) for quick select

### Gamepad (Gamepad API)

**Challenges:**
- Analog sticks need dead zones (prevent drift)
- Pressure sensitivity (varies by gamepad)
- Vibration API support (not all browsers)
- Multiple gamepads

**Solutions:**

```javascript
export class GamepadInput {
    constructor() {
        this.deadZone = 0.2;      // 20% — typical for modern controllers
        this.triggerThreshold = 0.5;
        this.gamepads = [];
    }

    update() {
        const gps = navigator.getGamepads();
        
        for (let i = 0; i < gps.length; i++) {
            const gp = gps[i];
            if (!gp) continue;

            // Analog stick (axis 0 = left-right, axis 1 = up-down)
            const lx = this.applyDeadZone(gp.axes[0]);
            const ly = this.applyDeadZone(gp.axes[1]);

            // Buttons (standard mapping)
            const a = gp.buttons[0].pressed;      // A / Cross
            const b = gp.buttons[1].pressed;      // B / Circle
            const x = gp.buttons[2].pressed;      // X / Square
            const y = gp.buttons[3].pressed;      // Y / Triangle
            const lb = gp.buttons[4].pressed;     // LB / L1
            const rb = gp.buttons[5].pressed;     // RB / R1
            const lt = gp.buttons[6].value > this.triggerThreshold;
            const rt = gp.buttons[7].value > this.triggerThreshold;
            const back = gp.buttons[8].pressed;   // Back / Select
            const start = gp.buttons[9].pressed;  // Start

            // D-pad (separate from analog)
            const dpadUp = gp.buttons[12].pressed;
            const dpadDown = gp.buttons[13].pressed;
            const dpadLeft = gp.buttons[14].pressed;
            const dpadRight = gp.buttons[15].pressed;

            this.gamepads[i] = {
                analogStick: { x: lx, y: ly },
                buttons: { a, b, x, y, lb, rb, lt, rt, back, start },
                dpad: { up: dpadUp, down: dpadDown, left: dpadLeft, right: dpadRight },
                connected: true,
            };
        }
    }

    applyDeadZone(value) {
        if (Math.abs(value) < this.deadZone) return 0;
        return value;
    }

    // Vibration (haptic feedback)
    vibrate(gamepadIndex, duration, intensity = 1) {
        const gp = navigator.getGamepads()[gamepadIndex];
        if (gp?.hapticActuators?.[0]) {
            gp.hapticActuators[0].pulse(intensity, duration * 1000);
        }
    }
}
```

**Standards:**
- Left analog stick: movement (or right stick in some games)
- D-Pad: menu navigation or movement (alternative)
- A / Cross: confirm / jump / attack (primary action)
- B / Circle: cancel / grab
- X / Square: secondary action
- Y / Triangle: tertiary action
- LB / L1, RB / R1: abilities or shoulder actions
- Start: pause
- Back / Select: menu

### Touch (Mobile)

**Challenges:**
- No physical buttons — need virtual buttons
- Gesture recognition (swipe, hold, tap, multi-tap)
- Visual feedback (show touch active)
- Variable screen sizes

**Solutions:**

```javascript
export class TouchInput {
    constructor(canvas) {
        this.canvas = canvas;
        this.touches = new Map();  // Touch ID → touch data
        this.buttons = new Map();  // Virtual buttons
        this.gestureBuffer = [];

        canvas.addEventListener('touchstart', e => this.onTouchStart(e));
        canvas.addEventListener('touchmove', e => this.onTouchMove(e));
        canvas.addEventListener('touchend', e => this.onTouchEnd(e));

        // Define virtual button layout
        this.defineButtons();
    }

    defineButtons() {
        const w = this.canvas.logicalWidth;
        const h = this.canvas.logicalHeight;
        const buttonSize = 60;
        const margin = 10;

        // Left side: D-pad for movement
        this.buttons.set('up', {
            x: margin + buttonSize,
            y: margin,
            size: buttonSize,
            action: 'up',
        });
        this.buttons.set('down', {
            x: margin + buttonSize,
            y: margin + buttonSize * 2,
            size: buttonSize,
            action: 'down',
        });
        this.buttons.set('left', {
            x: margin,
            y: margin + buttonSize,
            size: buttonSize,
            action: 'left',
        });
        this.buttons.set('right', {
            x: margin + buttonSize * 2,
            y: margin + buttonSize,
            size: buttonSize,
            action: 'right',
        });

        // Right side: Action buttons
        this.buttons.set('attack', {
            x: w - margin - buttonSize,
            y: h - margin - buttonSize * 2,
            size: buttonSize,
            action: 'attack',
        });
        this.buttons.set('jump', {
            x: w - margin - buttonSize * 2.5,
            y: h - margin - buttonSize,
            size: buttonSize,
            action: 'jump',
        });
    }

    onTouchStart(e) {
        for (const touch of e.changedTouches) {
            const pos = this.getTouchPosition(touch);
            const button = this.getButtonAtPosition(pos);

            this.touches.set(touch.identifier, {
                startX: pos.x,
                startY: pos.y,
                currentX: pos.x,
                currentY: pos.y,
                button,
                startTime: Date.now(),
            });
        }
    }

    onTouchMove(e) {
        for (const touch of e.changedTouches) {
            const pos = this.getTouchPosition(touch);
            const touchData = this.touches.get(touch.identifier);
            if (touchData) {
                touchData.currentX = pos.x;
                touchData.currentY = pos.y;
            }
        }
    }

    onTouchEnd(e) {
        for (const touch of e.changedTouches) {
            const touchData = this.touches.get(touch.identifier);
            if (touchData) {
                const duration = Date.now() - touchData.startTime;
                const distance = Math.hypot(
                    touchData.currentX - touchData.startX,
                    touchData.currentY - touchData.startY
                );

                // Classify gesture
                if (distance < 10 && duration < 200) {
                    // Tap
                    this.gestureBuffer.push({
                        type: 'tap',
                        button: touchData.button,
                    });
                } else if (distance > 50) {
                    // Swipe
                    const angle = Math.atan2(
                        touchData.currentY - touchData.startY,
                        touchData.currentX - touchData.startX
                    );
                    this.gestureBuffer.push({
                        type: 'swipe',
                        angle,
                        distance,
                    });
                }
            }

            this.touches.delete(touch.identifier);
        }
    }

    getTouchPosition(touch) {
        const rect = this.canvas.getBoundingClientRect();
        const dpr = window.devicePixelRatio || 1;
        return {
            x: (touch.clientX - rect.left) / (rect.width / this.canvas.logicalWidth),
            y: (touch.clientY - rect.top) / (rect.height / this.canvas.logicalHeight),
        };
    }

    getButtonAtPosition(pos) {
        for (const [name, button] of this.buttons) {
            const dx = pos.x - button.x;
            const dy = pos.y - button.y;
            if (
                Math.abs(dx) < button.size / 2 &&
                Math.abs(dy) < button.size / 2
            ) {
                return name;
            }
        }
        return null;
    }

    // Render virtual buttons
    render(ctx) {
        ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
        ctx.lineWidth = 2;

        for (const [name, button] of this.buttons) {
            const active = this.touches.values().some(t => t.button === name);
            ctx.fillStyle = active ? 'rgba(255, 200, 0, 0.5)' : 'rgba(255, 255, 255, 0.2)';

            ctx.beginPath();
            ctx.rect(
                button.x - button.size / 2,
                button.y - button.size / 2,
                button.size,
                button.size
            );
            ctx.fill();
            ctx.stroke();

            // Label
            ctx.fillStyle = active ? '#fff' : 'rgba(255, 255, 255, 0.6)';
            ctx.font = '12px monospace';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(name, button.x, button.y);
        }
    }
}
```

### Cross-Platform Unified API

Ideally, expose a single input interface that abstracts all three:

```javascript
export class UnifiedInput {
    constructor(canvas) {
        this.keyboard = new KeyboardInput();
        this.gamepad = new GamepadInput();
        this.touch = new TouchInput(canvas);
        this.mapper = new InputMapper(STANDARD_ACTIONS);
    }

    update() {
        this.gamepad.update();
        this.keyboard.clearFrameState();
    }

    isHeld(actionName) {
        const action = this.mapper.actions.get(actionName);
        if (!action) return false;

        // Check all input methods
        return action.keys.some(key => {
            // Keyboard
            if (key.startsWith('Key') || key.startsWith('Arrow')) {
                return this.keyboard.keys[key];
            }
            // Gamepad button
            if (key.startsWith('Gamepad')) {
                const [, buttonName] = key.split(':');
                return this.getGamepadButtonState(buttonName);
            }
            return false;
        });
    }

    getGamepadButtonState(buttonName) {
        // Map button names to gamepad state
        // (implementation omitted for brevity)
        return false;
    }
}
```

---

## Debug & Testing

### Input Visualization Overlay

Help you see what's happening:

```javascript
export class InputDebugOverlay {
    constructor(input, canvas) {
        this.input = input;
        this.canvas = canvas;
        this.visible = false;

        window.addEventListener('keydown', e => {
            if (e.code === 'Backquote') this.visible = !this.visible; // Backtick toggle
        });
    }

    render(ctx) {
        if (!this.visible) return;

        ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
        ctx.fillRect(0, 0, 400, 300);

        ctx.fillStyle = '#0f0';
        ctx.font = '12px monospace';
        let y = 20;

        // Show held keys
        ctx.fillText('HELD KEYS:', 10, y);
        y += 15;
        Object.entries(this.input.keys)
            .filter(([, held]) => held)
            .forEach(([code]) => {
                ctx.fillText(`  ${code}`, 20, y);
                y += 15;
            });

        // Show pressed this frame
        ctx.fillText('PRESSED:', 10, y);
        y += 15;
        Object.keys(this.input.keysPressed).forEach(code => {
            ctx.fillText(`  ${code}`, 20, y);
            y += 15;
        });

        // Show buffered inputs (if using InputBuffer)
        if (this.input.buffer) {
            ctx.fillText('BUFFERED:', 10, y);
            y += 15;
            this.input.buffer.buffer.forEach((entry, i) => {
                if (entry) {
                    ctx.fillText(`  [${i}] ${entry.action}`, 20, y);
                    y += 15;
                }
            });
        }
    }
}
```

### Input Recording & Playback

Capture and replay input sequences:

```javascript
export class InputRecorder {
    constructor() {
        this.recording = null;
        this.recordings = new Map();
        this.playback = null;
    }

    startRecording(name) {
        this.recording = {
            name,
            frames: [],
            startTime: performance.now(),
        };
    }

    recordFrame(actions) {
        if (!this.recording) return;
        this.recording.frames.push([...actions]);
    }

    stopRecording() {
        if (this.recording) {
            this.recordings.set(this.recording.name, this.recording);
            this.recording = null;
        }
    }

    playback(name) {
        const recording = this.recordings.get(name);
        if (recording) {
            this.playback = {
                recording,
                frameIndex: 0,
            };
        }
    }

    getPlaybackActions() {
        if (!this.playback) return [];
        const actions = this.playback.recording.frames[this.playback.frameIndex] || [];
        this.playback.frameIndex++;
        if (this.playback.frameIndex >= this.playback.recording.frames.length) {
            this.playback = null;
        }
        return actions;
    }

    exportRecording(name) {
        const rec = this.recordings.get(name);
        return JSON.stringify(rec);
    }

    importRecording(name, json) {
        this.recordings.set(name, JSON.parse(json));
    }
}
```

**Usage in testing:**
```javascript
const recorder = new InputRecorder();

// During manual testing
recorder.startRecording('combo-sequence');
// ... play through the combo ...
recorder.stopRecording();

// Later, run the replay test
recorder.playback('combo-sequence');
for (let frame = 0; frame < 120; frame++) {
    const actions = recorder.getPlaybackActions();
    // ... run game update with replayed actions ...
}
```

### Latency Measurement

Measure the actual delay from input to screen:

```javascript
export class LatencyMeter {
    constructor() {
        this.inputTimes = new Map();
        this.measuredLatencies = [];

        window.addEventListener('keydown', e => {
            this.inputTimes.set(e.code, performance.now());
        });
    }

    measureScreenResponse(inputCode, callback) {
        const inputTime = this.inputTimes.get(inputCode);
        if (!inputTime) return;

        // On next frame, measure when visual change was rendered
        requestAnimationFrame(() => {
            const screenTime = performance.now();
            const latency = screenTime - inputTime;
            this.measuredLatencies.push(latency);

            if (callback) callback(latency);
        });
    }

    getStats() {
        if (this.measuredLatencies.length === 0) return null;
        const sorted = [...this.measuredLatencies].sort((a, b) => a - b);
        return {
            min: sorted[0],
            max: sorted[sorted.length - 1],
            avg: sorted.reduce((a, b) => a + b) / sorted.length,
            p95: sorted[Math.floor(sorted.length * 0.95)],
            p99: sorted[Math.floor(sorted.length * 0.99)],
        };
    }

    reset() {
        this.measuredLatencies = [];
    }
}
```

---

## Anti-Patterns

### 1. "Raw Polling Only" — No Buffering

**The Problem:**
```javascript
update(dt) {
    if (input.isHeld('attack')) {
        this.attack();  // Executes every frame, not once
    }
}
```

This runs attack every frame if the key is held. Players need to tap the key precisely to execute once. Feels terrible.

**The Fix:** Use input buffering + state transitions.

```javascript
update(dt) {
    if (this.state === 'idle' && input.buffer.consume('attack')) {
        this.state = 'attack';
    }
}
```

### 2. "Fixed Key Mapping" — No Remapping

**The Problem:**
```javascript
if (input.isHeld('KeyJ')) {
    player.attack();
}
```

Player can't rebind to their preferred keys. Accessibility failure.

**The Fix:** Use InputMapper with configurable key bindings.

### 3. "Input in Render Loop"

**The Problem:**
```javascript
function render() {
    // ... render code ...
    if (input.isHeld('attack')) {  // ❌ Wrong place!
        player.attack();
    }
}
```

Input handling depends on when render runs, not on fixed timestep. Frame-dependent behavior.

**The Fix:** Process input in `update()`, not `render()`.

```javascript
function gameLoop() {
    accumulator += frameTime;
    while (accumulator >= fixedDelta) {
        input.clearFrameState();
        scene.update(fixedDelta);  // Input processing here
        accumulator -= fixedDelta;
    }
    scene.render();
}
```

### 4. "Eating Inputs Silently"

**The Problem:**
```javascript
if (menuOpen && input.isPressed('attack')) {
    menu.select();
}
// Game never sees 'attack' input
```

Player presses attack, menu closes, game doesn't attack. Feels like the input vanished.

**The Fix:** Use InputConsumer pattern. When menu handles input, it removes the action from input so gameplay doesn't see it. But gameplay should always know what happened.

### 5. "No Coyote Time" — Tight, Unforgiving Windows

**The Problem:**
```javascript
if (player.isAirborne && input.isPressed('jump')) {
    player.jump();  // Only works while airborne, never after
}
```

Player leaves the ground and 50ms later presses jump. Too late. Game feels punishing.

**The Fix:** Add grace periods. Let players jump for 6 frames after leaving ground.

---

## firstPunch Learnings

### What We Built

**Input System (Canvas + Web Audio):**
- Keyboard handler with keydown/keyup tracking (pressed/held/released state)
- Input buffering for attack sequences (6-frame buffer, 150ms expiry)
- Buffer clear on state transitions (prevent stale attacks executing during hit/recovery)
- Direction tracking with last-pressed-wins for left/right conflicts

**Integration:**
- Input captured in the game loop before scene update
- Fixed-timestep processing (no frame-dependent input)
- Buffered inputs consumed by state machines on transition
- Movement processed every frame (non-exclusive)

### What Worked

1. **Separating input capture from input consumption** — Keyboard events capture immediately (responsive), but gameplay processes buffered actions on state transitions (clean, predictable).
2. **Ring buffer for attack inputs** — Simple, bounded memory, expired old presses automatically.
3. **Last-pressed-wins for direction** — Left + Right = Right if right pressed last. Intuitive, no ambiguity.
4. **Clear buffer on state entry** — Prevents attack presses from stacking during transitions.

### What We'd Improve for Godot

1. **Gamepad/Touch support** — firstPunch only supports keyboard. Next project should abstract from day 1.
2. **InputMapper for remapping** — Hard-coded key names. Player preferences matter.
3. **Input visualization overlay** — Would have caught the recursion bug faster (isDown confusion).
4. **Latency measurement** — No way to verify responsiveness empirically. Add frame-accurate measurement.
5. **Generalized action types** — Only press/hold. Combat needs charge windows, double-taps, gesture recognition.
6. **Touch buttons** — Mobile support requires visual button layout and gesture recognition.

### The Recursion Bug We Fixed

**Original code had a naming conflict:**
```javascript
isDown(code) {
    return this.keys[code];
}

isMovingDown() {  // Meant to check down arrow direction
    return this.isDown('ArrowDown');  // ✅ Fixed
    // Original: return this.keys.ArrowDown; (before isDown existed)
}
```

Early version had `isDown()` calling itself:
```javascript
isDown(direction) {
    if (direction === 'down') return this.isDown('down');  // ❌ INFINITE RECURSION
}
```

**Lesson:** Input handling is common enough that naming collisions are easy. Use clear, specific names. `isKeyHeld()` is clearer than `isDown()`.

---

## Checklist for Your Game

Use this when building input for any game:

- [ ] **Capture phase:** Key events handled in keydown/keyup or polling, update every frame
- [ ] **Buffering:** Recent inputs stored, expired after N frames or time window
- [ ] **Processing:** Buffered inputs consumed in update(), not render()
- [ ] **Abstraction:** Actions are named ("attack"), not keys ("KeyJ")
- [ ] **Remapping:** Player can rebind actions to different keys
- [ ] **Priorities:** Simultaneous actions handled with priority queue
- [ ] **Consumption:** One system handles input, others don't see it (menu vs gameplay)
- [ ] **Movement:** Processed every frame, not buffered
- [ ] **Direction:** Last-pressed-wins for conflicts
- [ ] **Directional windows:** Coyote time / grace periods for human reaction
- [ ] **Multiplatform:** Keyboard, gamepad, and/or touch all work
- [ ] **Testing:** Input visualization overlay for debugging
- [ ] **Recording:** Playback sequences for testing (optional but valuable)
- [ ] **Latency:** Measured and < 100ms total (optional but important)
- [ ] **Accessibility:** Remapping works, keys are rebindable

---

## References & Further Reading

**Landmark Games:**
- **Super Smash Bros. Melee** — Frame-data precision, buffering for combos (wavedashing)
- **Celeste** — Coyote time, generous input windows, responsive platforming
- **Street Fighter VI** — Input buffering, action priority, visual feedback
- **The Legend of Zelda: Breath of the Wild** — Responsive directional input, seamless button mapping

**Articles:**
- "Input Lag" — Road Rash Revenge (developer commentary on latency)
- "Responsive Controls" — Extra Credits (accessible overview)
- GDC talk on fighting game input by Keitsui (Frame data, buffering, priority)

**Standards:**
- W3C Gamepad API — Specification for gamepad support
- MDN Web Audio API — Spec for sound feedback timing
- HTML5 Canvas — Spec for millisecond-accurate rendering timing
