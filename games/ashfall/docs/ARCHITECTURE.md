# Ashfall — Technical Architecture

**Genre:** 1v1 Fighting Game (Tekken / Street Fighter style)  
**Engine:** Godot 4.6 — GDScript  
**Scope:** 1 stage, 2 playable characters, local multiplayer + AI opponent  
**Author:** Solo (Lead / Chief Architect)  
**Status:** Blueprint — Pre-Implementation

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Frame Timing & Physics](#2-frame-timing--physics)
3. [Scene Tree Structure](#3-scene-tree-structure)
4. [Fighter Architecture](#4-fighter-architecture)
5. [Combat System](#5-combat-system)
6. [Input System](#6-input-system)
7. [Round System](#7-round-system)
8. [AI Architecture](#8-ai-architecture)
9. [Signal Architecture](#9-signal-architecture)
10. [Directory Structure](#10-directory-structure)
11. [File Ownership](#11-file-ownership)
12. [Conventions & Anti-Patterns](#12-conventions--anti-patterns)

---

## 1. Design Principles

1. **Frame-perfect combat.** Every game system runs on a fixed 60 FPS tick. No delta-time approximations for gameplay logic.
2. **Player hands first.** Input responsiveness and hit feedback take priority over visual fidelity. A snappy 2-frame jab matters more than a polished idle animation.
3. **One agent, one file.** Module boundaries are drawn so 5+ agents can build in parallel without touching the same file.
4. **Godot-native patterns.** Use AnimationPlayer for frame data, Area2D for hitboxes, signals for decoupled communication. Don't fight the engine.
5. **Every state has an exit path.** No dead-end states. Every timed state has a timeout safety net. (Learned from firstPunch player-freeze bug.)
6. **Wire on build.** Every new system must connect to at least one consumer before the PR merges. No unwired infrastructure.

---

## 2. Frame Timing & Physics

Fighting games require deterministic, frame-perfect logic. Godot's `_physics_process` runs at a fixed tick rate — we set it to 60 FPS.

### project.godot Configuration

```ini
[physics]
common/physics_ticks_per_second=60
common/max_physics_steps_per_frame=1

[application]
run/max_fps=60
```

### Timing Rules

| Concept | Implementation |
|---------|---------------|
| **Game tick** | 1 frame = 1/60th second ≈ 16.67ms |
| **Gameplay logic** | ALL combat, input, state machines run in `_physics_process()` |
| **Visual interpolation** | Cosmetic-only updates (particles, camera smoothing) may use `_process()` |
| **Frame counting** | Integer frame counters, not float timers. `frames_in_state += 1`, not `time_in_state += delta` |
| **Hitstun** | Measured in frames (e.g., 12 frames of hitstun), not seconds |
| **Input buffer** | Measured in frames (e.g., 6-frame input window) |

### Why Frames, Not Seconds

```gdscript
# ❌ WRONG — float drift, non-deterministic
var hitstun_time: float = 0.2  # 12 frames... sometimes 11, sometimes 13

# ✅ CORRECT — deterministic, frame-perfect
var hitstun_frames: int = 12   # Always exactly 12 ticks
```

Frame-based timing guarantees that a 3-frame startup jab is always 3 frames. Float timers accumulate rounding errors and produce inconsistent behavior across hardware.

---

## 3. Scene Tree Structure

```
FightScene (Node2D)                          ← Root scene, owns round logic
├── Stage (Node2D)                           ← Background, floor, stage boundaries
│   ├── Background (Sprite2D/ParallaxBackground)
│   ├── Floor (StaticBody2D + CollisionShape2D)
│   └── StageBounds (Node2D)
│       ├── LeftWall (StaticBody2D + CollisionShape2D)
│       └── RightWall (StaticBody2D + CollisionShape2D)
│
├── Fighters (Node2D)                        ← Container for both fighters
│   ├── Fighter1 (CharacterBody2D)           ← Player 1 (or AI)
│   │   ├── Sprite (AnimatedSprite2D)
│   │   ├── CollisionShape (CollisionShape2D) ← Physics body
│   │   ├── Hurtbox (Area2D)                 ← Where this fighter CAN be hit
│   │   │   └── HurtboxShape (CollisionShape2D)
│   │   ├── Hitboxes (Node2D)               ← Container for attack hitboxes
│   │   │   ├── HitboxPunch (Area2D)         ← Enabled per-attack via AnimationPlayer
│   │   │   │   └── PunchShape (CollisionShape2D)
│   │   │   ├── HitboxKick (Area2D)
│   │   │   │   └── KickShape (CollisionShape2D)
│   │   │   └── HitboxSpecial (Area2D)
│   │   │       └── SpecialShape (CollisionShape2D)
│   │   ├── Pushbox (Area2D)                 ← Prevents fighters overlapping
│   │   │   └── PushboxShape (CollisionShape2D)
│   │   ├── AnimationPlayer                  ← Frame data: enables/disables hitboxes per frame
│   │   └── StateMachine (Node)              ← State machine controller
│   │       ├── IdleState (Node)
│   │       ├── WalkState (Node)
│   │       ├── CrouchState (Node)
│   │       ├── JumpState (Node)
│   │       ├── AttackState (Node)
│   │       ├── BlockState (Node)
│   │       ├── HitState (Node)
│   │       └── KOState (Node)
│   │
│   └── Fighter2 (CharacterBody2D)           ← Player 2 (or AI) — same structure
│
├── CombatSystem (Node)                      ← Hit detection, damage, combos
├── RoundManager (Node)                      ← Round logic, win conditions, resets
│
├── Camera2D                                 ← Follows midpoint between fighters
│
└── UI (CanvasLayer)                         ← All HUD elements
    ├── HealthBarP1 (Control)
    ├── HealthBarP2 (Control)
    ├── RoundTimer (Control)
    ├── RoundIndicator (Control)             ← Round dots / icons
    ├── ComboCounter (Control)
    ├── RoundAnnouncer (Control)             ← "ROUND 1", "FIGHT!", "K.O."
    └── PauseMenu (Control)
```

### Node Responsibilities

| Node | Responsibility | Script |
|------|---------------|--------|
| `FightScene` | Scene lifecycle, connects systems, owns physics tick orchestration | `fight_scene.gd` |
| `Stage` | Visual background, floor collision, stage boundaries (wall push) | `stage.gd` |
| `Fighter1/2` | Character physics, movement, state machine, owns hitbox/hurtbox hierarchy | `fighter.gd` (shared base) |
| `CombatSystem` | Listens for hitbox/hurtbox overlaps, calculates damage, applies hitstun | `combat_system.gd` |
| `RoundManager` | Round state (intro → fight → ko → reset), timer, win tracking | `round_manager.gd` |
| `Camera2D` | Tracks midpoint between fighters, zoom based on distance | `fight_camera.gd` |
| `UI` | Health bars, timer display, round indicators, announcements | Multiple UI scripts |

---

## 4. Fighter Architecture

Each fighter is a `CharacterBody2D` scene with a modular state machine, hitbox/hurtbox system, and data-driven move list.

### 4.1 State Machine

The state machine uses a **node-based pattern**: each state is a child `Node` under a `StateMachine` controller. This avoids the god-file anti-pattern — each state is its own script.

```
StateMachine (Node)         ← state_machine.gd
├── IdleState (Node)        ← idle_state.gd
├── WalkState (Node)        ← walk_state.gd
├── WalkBackState (Node)    ← walk_back_state.gd
├── CrouchState (Node)      ← crouch_state.gd
├── JumpState (Node)        ← jump_state.gd
├── AttackState (Node)      ← attack_state.gd
├── AirAttackState (Node)   ← air_attack_state.gd
├── BlockState (Node)       ← block_state.gd
├── CrouchBlockState (Node) ← crouch_block_state.gd
├── HitState (Node)         ← hit_state.gd
├── LaunchState (Node)      ← launch_state.gd
├── KOState (Node)          ← ko_state.gd
└── IntroState (Node)       ← intro_state.gd
```

#### State Machine Controller (`state_machine.gd`)

```gdscript
class_name StateMachine
extends Node

@export var initial_state: Node

var current_state: Node
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is Node:
            states[child.name.to_lower()] = child
            child.state_machine = self
    current_state = initial_state
    current_state.enter({})

func _physics_process(_delta: float) -> void:
    current_state.physics_update()

func transition_to(target_state_name: String, args: Dictionary = {}) -> void:
    var target = states.get(target_state_name.to_lower())
    if target == null:
        push_warning("State '%s' not found" % target_state_name)
        return
    current_state.exit()
    current_state = target
    current_state.enter(args)
```

#### Base State (`fighter_state.gd`)

```gdscript
class_name FighterState
extends Node

var fighter: CharacterBody2D  # Set by fighter.gd on ready
var state_machine: StateMachine
var frames_in_state: int = 0

func enter(_args: Dictionary) -> void:
    frames_in_state = 0

func exit() -> void:
    pass

func physics_update() -> void:
    frames_in_state += 1

func handle_input(_input_buffer: InputBuffer) -> void:
    pass
```

#### State Transition Table

Every state must have documented exit paths. No dead-end states.

```
┌─────────────────┬──────────────────────────┬────────────────────────────────────┐
│ State           │ Entry Condition          │ Exit Path(s)                       │
├─────────────────┼──────────────────────────┼────────────────────────────────────┤
│ Intro           │ Round start              │ → Idle (intro anim complete)       │
│ Idle            │ Default / recovery       │ → Walk, Crouch, Jump, Attack,      │
│                 │                          │   Block, Hit, KO                   │
│ Walk            │ Forward input held       │ → Idle (no input), Attack, Jump,   │
│                 │                          │   Block, Hit                       │
│ WalkBack        │ Back input held          │ → Idle (no input), Block, Hit      │
│ Crouch          │ Down input held          │ → Idle (down released), Attack     │
│                 │                          │   (crouch attacks), CrouchBlock,   │
│                 │                          │   Hit                              │
│ Jump            │ Up input                 │ → Idle (landed), AirAttack, Hit    │
│                 │                          │   (air reset)                      │
│ Attack          │ Attack input (grounded)  │ → Idle (recovery frames done),     │
│                 │                          │   Attack (cancel into next hit on  │
│                 │                          │   contact), Hit                    │
│ AirAttack       │ Attack input (airborne)  │ → Jump (attack done, still in     │
│                 │                          │   air), Idle (landed)              │
│ Block           │ Back + incoming attack   │ → Idle (blockstun done, or input   │
│                 │                          │   released + no attack incoming)   │
│ CrouchBlock     │ Down-back + incoming low │ → Crouch (blockstun done)          │
│ Hit             │ Received unblocked hit   │ → Idle (hitstun expired), KO       │
│                 │                          │   (HP ≤ 0), Launch (launcher hit)  │
│ Launch          │ Launcher hit received    │ → Hit (landed from air), KO        │
│ KO              │ HP ≤ 0 during Hit/Launch │ → (Terminal — round ends)          │
│                 │                          │   Safety: 180-frame timeout → emit │
│                 │                          │   round_over if stuck              │
└─────────────────┴──────────────────────────┴────────────────────────────────────┘
```

### 4.2 Hitbox / Hurtbox System

Uses Godot's `Area2D` with collision layers for clean separation.

#### Collision Layer Assignment

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | `physics` | CharacterBody2D physics (floor, walls) |
| 2 | `p1_hurtbox` | Player 1's hurtbox — where P1 can be hit |
| 3 | `p2_hurtbox` | Player 2's hurtbox — where P2 can be hit |
| 4 | `p1_hitbox` | Player 1's attack hitboxes — what P1 attacks with |
| 5 | `p2_hitbox` | Player 2's attack hitboxes — what P2 attacks with |
| 6 | `pushbox` | Fighter body pushboxes (prevent overlap) |

**Collision matrix:**
- P1 hitboxes (layer 4) → detect P2 hurtboxes (mask 3)
- P2 hitboxes (layer 5) → detect P1 hurtboxes (mask 2)
- Pushboxes (layer 6) → detect other pushboxes (mask 6)
- Hitboxes never collide with own hurtboxes

#### Hitbox Activation via AnimationPlayer

AnimationPlayer drives hitbox enable/disable per frame. This is the **frame data system** — it defines startup, active, and recovery frames visually in the animation timeline.

```
AnimationPlayer Track: "Hitboxes/HitboxPunch/PunchShape:disabled"
Frame 0-2:  disabled = true    ← Startup (3 frames)
Frame 3-5:  disabled = false   ← Active (3 frames — hitbox is live)
Frame 6-11: disabled = true    ← Recovery (6 frames)
```

Each attack animation controls:
- `CollisionShape2D.disabled` — hitbox on/off per frame
- `CollisionShape2D.position` — hitbox position per frame (for moving attacks)
- `CollisionShape2D.shape.size` — hitbox size per frame (optional)
- `AnimatedSprite2D.frame` — visual frame sync

### 4.3 Animation System

Use `AnimatedSprite2D` for character visuals, driven by the state machine. `AnimationPlayer` handles frame data (hitbox timing, hurtbox adjustments, movement pulses).

```gdscript
# In attack_state.gd
func enter(args: Dictionary) -> void:
    super.enter(args)
    var move: MoveData = args.get("move")
    fighter.animated_sprite.play(move.animation_name)
    fighter.animation_player.play(move.hitbox_animation)
```

**Two animation nodes, two jobs:**
- `AnimatedSprite2D` → Visual sprite frames (what the player sees)
- `AnimationPlayer` → Frame data: hitbox timing, hurtbox shifts, movement impulses (what the game logic uses)

### 4.4 Move Data Structure

Moves are defined as `Resource` files — pure data, no logic. This lets designers tune frame data without touching code.

```gdscript
# move_data.gd
class_name MoveData
extends Resource

@export var move_name: String = ""
@export var input_command: String = ""  # e.g., "5LP", "236HP", "623LP"

# Frame data
@export var startup_frames: int = 3
@export var active_frames: int = 3
@export var recovery_frames: int = 6

# Damage & properties
@export var damage: int = 50
@export var chip_damage: int = 5             # Damage on block
@export var hitstun_frames: int = 12
@export var blockstun_frames: int = 8
@export var knockback_force: Vector2 = Vector2(200, 0)
@export var launch_force: Vector2 = Vector2.ZERO  # Non-zero = launcher

# Hit properties
@export var hit_type: HitType = HitType.MID  # HIGH, MID, LOW
@export var can_cancel_into: Array[String] = []  # Move names this cancels into

# Animation references
@export var animation_name: String = ""       # AnimatedSprite2D animation
@export var hitbox_animation: String = ""     # AnimationPlayer hitbox track

enum HitType { HIGH, MID, LOW }
```

**Total frames for a move** = `startup_frames + active_frames + recovery_frames`. A 3+3+6 jab = 12 total frames = 0.2 seconds at 60 FPS.

#### Move List (per character, as Resource)

```gdscript
# fighter_moveset.gd
class_name FighterMoveset
extends Resource

@export var character_name: String = ""
@export var normals: Array[MoveData] = []     # LP, MP, HP, LK, MK, HK
@export var specials: Array[MoveData] = []    # Quarter-circle moves, DPs, etc.
@export var throws: Array[MoveData] = []
@export var supers: Array[MoveData] = []      # Future: meter-dependent

func get_move_by_command(command: String) -> MoveData:
    for move in normals + specials + throws + supers:
        if move.input_command == command:
            return move
    return null
```

Movesets are saved as `.tres` files in `resources/movesets/`. Each character has one moveset resource.

### 4.5 Fighter Base Script

```gdscript
# fighter.gd
class_name Fighter
extends CharacterBody2D

signal hit_landed(attacker: Fighter, target: Fighter, move: MoveData)
signal took_damage(fighter: Fighter, amount: int, remaining_hp: int)
signal knocked_out(fighter: Fighter)

@export var player_id: int = 1  # 1 or 2
@export var moveset: FighterMoveset
@export var max_hp: int = 1000

var hp: int = 1000
var facing_right: bool = true
var is_grounded: bool = true
var opponent: Fighter  # Set by FightScene on ready
var input_buffer: InputBuffer

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox
@onready var pushbox: Area2D = $Pushbox

func _ready() -> void:
    input_buffer = InputBuffer.new()
    add_child(input_buffer)
    _setup_collision_layers()

func _physics_process(_delta: float) -> void:
    _update_facing()
    input_buffer.update()

func _update_facing() -> void:
    if opponent and state_machine.current_state.name != "AttackState":
        facing_right = global_position.x < opponent.global_position.x
        animated_sprite.flip_h = not facing_right

func apply_damage(amount: int, move: MoveData) -> void:
    hp = max(0, hp - amount)
    took_damage.emit(self, amount, hp)
    if hp <= 0:
        knocked_out.emit(self)

func reset_for_round(spawn_position: Vector2) -> void:
    hp = max_hp
    global_position = spawn_position
    velocity = Vector2.ZERO
    state_machine.transition_to("idle")

func _setup_collision_layers() -> void:
    if player_id == 1:
        hurtbox.collision_layer = 2   # p1_hurtbox
        _set_hitbox_masks(3)          # detect p2_hurtbox
    else:
        hurtbox.collision_layer = 3   # p2_hurtbox
        _set_hitbox_masks(2)          # detect p1_hurtbox

func _set_hitbox_masks(target_hurtbox_layer: int) -> void:
    for hitbox in $Hitboxes.get_children():
        if hitbox is Area2D:
            hitbox.collision_layer = 4 if player_id == 1 else 5
            hitbox.collision_mask = target_hurtbox_layer
```

---

## 5. Combat System

The `CombatSystem` node handles hit detection, damage calculation, hitstun application, and combo tracking. It lives as a sibling to fighters, not inside them — keeping combat logic centralized and testable.

### 5.1 Hit Detection Flow

```
1. AnimationPlayer enables HitboxPunch on frame 3 of jab animation
2. Godot physics detects overlap: P1's HitboxPunch ↔ P2's Hurtbox
3. HitboxPunch emits area_entered(P2_Hurtbox)
4. CombatSystem receives signal → looks up active MoveData
5. CombatSystem checks: Is target blocking? Correct block height?
6. CombatSystem applies: damage, hitstun, knockback, combo counter
7. CombatSystem emits: hit_landed or hit_blocked signal
8. Target fighter transitions to Hit or Block state with frame count from MoveData
```

### 5.2 Combat System Script (Outline)

```gdscript
# combat_system.gd
class_name CombatSystem
extends Node

signal hit_confirmed(attacker: Fighter, target: Fighter, move: MoveData, combo_count: int)
signal hit_blocked(attacker: Fighter, target: Fighter, move: MoveData)
signal combo_ended(fighter: Fighter, total_hits: int, total_damage: int)

var combo_counters: Dictionary = {}   # fighter -> {hits: int, damage: int, scaling: float}
var hit_this_attack: Dictionary = {}  # hitbox -> Array[Fighter] (prevent multi-hit per active window)

func _ready() -> void:
    _connect_hitboxes()

func register_hit(attacker: Fighter, target: Fighter, move: MoveData, hitbox: Area2D) -> void:
    # Prevent same hitbox hitting same target twice in one active window
    if hit_this_attack.get(hitbox, []).has(target):
        return
    hit_this_attack[hitbox] = hit_this_attack.get(hitbox, []) + [target]

    if _is_blocking(target, move):
        _apply_block(attacker, target, move)
        hit_blocked.emit(attacker, target, move)
    else:
        _apply_hit(attacker, target, move)

func _apply_hit(attacker: Fighter, target: Fighter, move: MoveData) -> void:
    var combo = combo_counters.get(target, {"hits": 0, "damage": 0, "scaling": 1.0})
    combo.hits += 1

    # Damage scaling: each hit in a combo does less (minimum 20%)
    var scaled_damage = int(move.damage * combo.scaling)
    combo.damage += scaled_damage
    combo.scaling = max(0.2, combo.scaling - 0.1)
    combo_counters[target] = combo

    target.apply_damage(scaled_damage, move)
    target.state_machine.transition_to("hit", {
        "hitstun_frames": move.hitstun_frames,
        "knockback": _get_knockback(attacker, target, move)
    })

    hit_confirmed.emit(attacker, target, move, combo.hits)

func _apply_block(attacker: Fighter, target: Fighter, move: MoveData) -> void:
    target.apply_damage(move.chip_damage, move)
    target.state_machine.transition_to("block", {
        "blockstun_frames": move.blockstun_frames,
        "knockback": _get_knockback(attacker, target, move) * 0.3
    })

func _is_blocking(target: Fighter, move: MoveData) -> bool:
    var in_block_state = target.state_machine.current_state.name in ["BlockState", "CrouchBlockState"]
    if not in_block_state:
        # Auto-block: holding back counts as blocking if in idle/walk_back
        var holding_back = target.input_buffer.is_holding_back(target.facing_right)
        if not holding_back:
            return false
    # Check block height: must crouch-block lows, must stand-block highs
    match move.hit_type:
        MoveData.HitType.LOW:
            return target.state_machine.current_state.name == "CrouchBlockState"
        MoveData.HitType.HIGH:
            return target.state_machine.current_state.name == "BlockState"
        MoveData.HitType.MID:
            return true  # Any block works for mids
    return false

func _get_knockback(attacker: Fighter, target: Fighter, move: MoveData) -> Vector2:
    var direction = 1.0 if attacker.global_position.x < target.global_position.x else -1.0
    return Vector2(move.knockback_force.x * direction, move.knockback_force.y)

func reset_combo(fighter: Fighter) -> void:
    if combo_counters.has(fighter) and combo_counters[fighter].hits > 0:
        combo_ended.emit(fighter, combo_counters[fighter].hits, combo_counters[fighter].damage)
    combo_counters[fighter] = {"hits": 0, "damage": 0, "scaling": 1.0}

func clear_hit_tracking(hitbox: Area2D) -> void:
    hit_this_attack.erase(hitbox)
```

### 5.3 Combo System

Combos are **implicit** — they happen when the defender is hit again before hitstun expires. No explicit combo tree needed.

```
Hit 1: Jab → 50 damage × 1.0 scaling = 50 damage, 12 hitstun frames
Hit 2: Jab → 50 damage × 0.9 scaling = 45 damage, 12 hitstun frames
Hit 3: Heavy Punch → 100 damage × 0.8 scaling = 80 damage, 18 hitstun frames
  (Total: 175 damage, 3-hit combo)

If attacker doesn't land another hit before hitstun expires → combo drops, counter resets.
```

**Cancel windows:** Certain moves can cancel into other moves on hit. The `can_cancel_into` array in `MoveData` defines valid cancel routes. AttackState checks this on `hit_confirmed`.

---

## 6. Input System

Fighting game input is the most latency-sensitive system. We buffer inputs, detect motions, and resolve simultaneously-pressed buttons.

### 6.1 Input Buffer

The buffer stores the last N frames of input. This lets the system detect motion commands (↓↘→+P = fireball) and allows lenient timing (pressing attack 3 frames before landing still triggers the grounded attack).

```gdscript
# input_buffer.gd
class_name InputBuffer
extends Node

const BUFFER_SIZE: int = 30        # 30 frames = 0.5 seconds of history
const INPUT_LENIENCY: int = 6      # 6 frames = 0.1 seconds to queue a move

var buffer: Array[Dictionary] = []  # Ring buffer of input snapshots
var player_id: int = 1

# Current-frame input state
var current_input: Dictionary = {}

func _ready() -> void:
    for i in BUFFER_SIZE:
        buffer.append({})

func update() -> void:
    current_input = _read_raw_input()
    buffer.append(current_input)
    if buffer.size() > BUFFER_SIZE:
        buffer.pop_front()

func _read_raw_input() -> Dictionary:
    var prefix = "p%d_" % player_id
    return {
        "up": Input.is_action_pressed(prefix + "up"),
        "down": Input.is_action_pressed(prefix + "down"),
        "left": Input.is_action_pressed(prefix + "left"),
        "right": Input.is_action_pressed(prefix + "right"),
        "lp": Input.is_action_just_pressed(prefix + "light_punch"),
        "hp": Input.is_action_just_pressed(prefix + "heavy_punch"),
        "lk": Input.is_action_just_pressed(prefix + "light_kick"),
        "hk": Input.is_action_just_pressed(prefix + "heavy_kick"),
    }

# Check if a button was pressed within the leniency window
func was_pressed(button: String, window: int = INPUT_LENIENCY) -> bool:
    var start = max(0, buffer.size() - window)
    for i in range(start, buffer.size()):
        if buffer[i].get(button, false):
            return true
    return false

# Check if a direction is currently held
func is_held(direction: String) -> bool:
    return current_input.get(direction, false)

func is_holding_back(facing_right: bool) -> bool:
    return is_held("left") if facing_right else is_held("right")

func is_holding_forward(facing_right: bool) -> bool:
    return is_held("right") if facing_right else is_held("left")
```

### 6.2 Motion Detection

Motion inputs (quarter-circle forward, dragon punch, etc.) are detected by scanning the buffer for directional sequences.

```gdscript
# motion_detector.gd
class_name MotionDetector
extends RefCounted

# Numpad notation:
#   7 8 9      ↖ ↑ ↗
#   4 5 6  =   ← ● →
#   1 2 3      ↙ ↓ ↘

const MOTION_WINDOW: int = 15  # frames to complete a motion input

static func detect_motion(buffer: Array[Dictionary], facing_right: bool) -> String:
    if _check_motion(buffer, _get_qcf(facing_right)):
        return "qcf"  # Quarter-circle forward (↓↘→) — fireballs
    if _check_motion(buffer, _get_qcb(facing_right)):
        return "qcb"  # Quarter-circle back (↓↙←)
    if _check_motion(buffer, _get_dp(facing_right)):
        return "dp"   # Dragon punch (→↓↘) — shoryuken
    if _check_motion(buffer, _get_hcf(facing_right)):
        return "hcf"  # Half-circle forward (←↙↓↘→)
    if _check_motion(buffer, _get_hcb(facing_right)):
        return "hcb"  # Half-circle back (→↘↓↙←)
    return ""

static func _check_motion(buffer: Array[Dictionary], sequence: Array[Dictionary]) -> bool:
    var seq_index = 0
    var start = max(0, buffer.size() - MOTION_WINDOW)
    for i in range(start, buffer.size()):
        if _matches_direction(buffer[i], sequence[seq_index]):
            seq_index += 1
            if seq_index >= sequence.size():
                return true
    return false

static func _matches_direction(input: Dictionary, required: Dictionary) -> bool:
    for key in required:
        if not input.get(key, false):
            return false
    return true

# Motion sequences (facing right — mirror for facing left)
static func _get_qcf(facing_right: bool) -> Array[Dictionary]:
    var fwd = "right" if facing_right else "left"
    return [{"down": true}, {"down": true, fwd: true}, {fwd: true}]

static func _get_qcb(facing_right: bool) -> Array[Dictionary]:
    var back = "left" if facing_right else "right"
    return [{"down": true}, {"down": true, back: true}, {back: true}]

static func _get_dp(facing_right: bool) -> Array[Dictionary]:
    var fwd = "right" if facing_right else "left"
    return [{fwd: true}, {"down": true}, {"down": true, fwd: true}]

static func _get_hcf(facing_right: bool) -> Array[Dictionary]:
    var back = "left" if facing_right else "right"
    var fwd = "right" if facing_right else "left"
    return [{back: true}, {"down": true, back: true}, {"down": true}, {"down": true, fwd: true}, {fwd: true}]

static func _get_hcb(facing_right: bool) -> Array[Dictionary]:
    var fwd = "right" if facing_right else "left"
    var back = "left" if facing_right else "right"
    return [{fwd: true}, {"down": true, fwd: true}, {"down": true}, {"down": true, back: true}, {back: true}]
```

### 6.3 Input Mapping

```ini
# project.godot input map (configured via Project Settings → Input Map)

# Player 1 (Keyboard - left side)
p1_up       = W
p1_down     = S
p1_left     = A
p1_right    = D
p1_light_punch  = U
p1_heavy_punch  = I
p1_light_kick   = J
p1_heavy_kick   = K

# Player 2 (Keyboard - right side / numpad)
p2_up       = Up Arrow
p2_down     = Down Arrow
p2_left     = Left Arrow
p2_right    = Right Arrow
p2_light_punch  = Numpad 4
p2_heavy_punch  = Numpad 5
p2_light_kick   = Numpad 1
p2_heavy_kick   = Numpad 2

# Gamepad (both players — mapped by device index)
p{n}_up     = DPad Up / Left Stick Up
p{n}_down   = DPad Down / Left Stick Down
p{n}_left   = DPad Left / Left Stick Left
p{n}_right  = DPad Right / Left Stick Right
p{n}_light_punch  = X (Square)
p{n}_heavy_punch  = Y (Triangle)
p{n}_light_kick   = A (Cross)
p{n}_heavy_kick   = B (Circle)
```

### 6.4 Throw Detection

Throws require simultaneous button press (LP+LK within 2 frames).

```gdscript
# In input_buffer.gd
func is_throw_input(window: int = 2) -> bool:
    return was_pressed("lp", window) and was_pressed("lk", window)
```

---

## 7. Round System

Best of 3 rounds. Standard fighting game flow.

### 7.1 Round State Machine

```
┌──────────┐    timer    ┌──────────┐   press    ┌──────────┐
│  INTRO   │───expires──→│  READY   │──start────→│  FIGHT   │
│ (60f)    │             │ (90f)    │            │          │
└──────────┘             └──────────┘            └────┬─────┘
                                                      │
                                           HP ≤ 0 or Timer = 0
                                                      │
                                                 ┌────▼─────┐
                                                 │   KO     │
                                                 │ (120f)   │
                                                 └────┬─────┘
                                                      │
                                          ┌───────────┼───────────┐
                                          │                       │
                                    Match not over           Match over
                                          │                       │
                                   ┌──────▼──────┐        ┌──────▼──────┐
                                   │ ROUND_RESET  │        │  MATCH_END  │
                                   │ (90f)        │        │             │
                                   └──────┬──────┘        └─────────────┘
                                          │
                                          └──→ INTRO (next round)
```

### 7.2 Round Manager Script (Outline)

```gdscript
# round_manager.gd
class_name RoundManager
extends Node

signal round_started(round_number: int)
signal round_ended(winner: Fighter, round_number: int)
signal match_ended(winner: Fighter, score: Array[int])
signal timer_updated(seconds_remaining: int)
signal announce(text: String)  # "ROUND 1", "FIGHT!", "K.O."

@export var rounds_to_win: int = 2
@export var round_time_seconds: int = 99
@export var intro_frames: int = 60
@export var ready_frames: int = 90
@export var ko_frames: int = 120
@export var reset_frames: int = 90

var current_round: int = 1
var scores: Array[int] = [0, 0]  # P1 wins, P2 wins
var timer_frames: int = 0
var round_state: String = "INTRO"
var state_frames: int = 0
var fighters: Array[Fighter] = []

var p1_spawn: Vector2 = Vector2(-200, 0)
var p2_spawn: Vector2 = Vector2(200, 0)

func start_match(fighter1: Fighter, fighter2: Fighter) -> void:
    fighters = [fighter1, fighter2]
    scores = [0, 0]
    current_round = 1
    _start_round()

func _physics_process(_delta: float) -> void:
    state_frames += 1
    match round_state:
        "INTRO":
            if state_frames >= intro_frames:
                _transition_to("READY")
                announce.emit("ROUND %d" % current_round)
        "READY":
            if state_frames >= ready_frames:
                _transition_to("FIGHT")
                announce.emit("FIGHT!")
        "FIGHT":
            timer_frames -= 1
            timer_updated.emit(ceili(timer_frames / 60.0))
            if timer_frames <= 0:
                _time_over()
        "KO":
            if state_frames >= ko_frames:
                _check_match_over()
        "ROUND_RESET":
            if state_frames >= reset_frames:
                current_round += 1
                _start_round()
        "MATCH_END":
            pass  # Wait for UI / scene transition

func on_fighter_ko(fighter: Fighter) -> void:
    if round_state != "FIGHT":
        return
    var winner_index = 1 if fighter == fighters[0] else 0
    scores[winner_index] += 1
    _transition_to("KO")
    announce.emit("K.O.!")
    round_ended.emit(fighters[winner_index], current_round)

func _time_over() -> void:
    # Higher HP wins; if tied, current round is a draw (no score change)
    var winner_index = 0 if fighters[0].hp > fighters[1].hp else 1
    if fighters[0].hp != fighters[1].hp:
        scores[winner_index] += 1
    _transition_to("KO")
    announce.emit("TIME!")
    round_ended.emit(fighters[winner_index], current_round)

func _check_match_over() -> void:
    for i in 2:
        if scores[i] >= rounds_to_win:
            _transition_to("MATCH_END")
            match_ended.emit(fighters[i], scores)
            return
    _transition_to("ROUND_RESET")

func _start_round() -> void:
    timer_frames = round_time_seconds * 60
    fighters[0].reset_for_round(p1_spawn)
    fighters[1].reset_for_round(p2_spawn)
    _transition_to("INTRO")
    round_started.emit(current_round)

func _transition_to(new_state: String) -> void:
    round_state = new_state
    state_frames = 0
```

---

## 8. AI Architecture

Basic state machine AI for single-player opponent. Designed for Phase 1 — functional, not competitive.

### 8.1 AI State Machine

```
┌───────────┐          in range          ┌───────────┐
│  APPROACH │────────────────────────────→│  ATTACK   │
│           │←───────────────────────────│           │
└─────┬─────┘         out of range       └─────┬─────┘
      │                                         │
      │ opponent attacks                        │ got hit
      │                                         │
      ▼                                         ▼
┌───────────┐                            ┌───────────┐
│  BLOCK    │                            │  RECOVER  │
│           │────timer expires──────────→│           │──→ APPROACH
└───────────┘                            └───────────┘
```

### 8.2 AI Controller Script (Outline)

```gdscript
# ai_controller.gd
class_name AIController
extends Node

@export var fighter: Fighter
@export var reaction_frames: int = 12     # How fast AI reacts (lower = harder)
@export var aggression: float = 0.7       # 0.0 = passive, 1.0 = relentless
@export var block_chance: float = 0.5     # Probability of blocking on reaction

var ai_state: String = "APPROACH"
var decision_cooldown: int = 0
var opponent: Fighter

enum Difficulty { EASY, MEDIUM, HARD }

func configure_difficulty(level: Difficulty) -> void:
    match level:
        Difficulty.EASY:
            reaction_frames = 20
            aggression = 0.3
            block_chance = 0.2
        Difficulty.MEDIUM:
            reaction_frames = 12
            aggression = 0.5
            block_chance = 0.5
        Difficulty.HARD:
            reaction_frames = 6
            aggression = 0.8
            block_chance = 0.8

func _physics_process(_delta: float) -> void:
    if not opponent or not fighter:
        return
    if decision_cooldown > 0:
        decision_cooldown -= 1
        return

    # Protected states — don't override active attack/hitstun
    var protected_states = ["AttackState", "HitState", "KOState", "LaunchState", "BlockState"]
    if fighter.state_machine.current_state.name in protected_states:
        return

    var distance = abs(fighter.global_position.x - opponent.global_position.x)
    var attack_range = 120.0
    var approach_range = 300.0

    match ai_state:
        "APPROACH":
            if distance <= attack_range:
                ai_state = "ATTACK"
            elif distance <= approach_range:
                _move_toward_opponent()
            else:
                _move_toward_opponent()

            # React to opponent attacking
            if opponent.state_machine.current_state.name == "AttackState":
                if randf() < block_chance:
                    ai_state = "BLOCK"
                    decision_cooldown = reaction_frames

        "ATTACK":
            if distance > attack_range * 1.5:
                ai_state = "APPROACH"
                return
            if randf() < aggression:
                _execute_attack()
                decision_cooldown = 30  # Cooldown after attacking

        "BLOCK":
            _hold_back()
            decision_cooldown = 20
            ai_state = "RECOVER"

        "RECOVER":
            decision_cooldown = 15
            ai_state = "APPROACH"

func _move_toward_opponent() -> void:
    var direction = sign(opponent.global_position.x - fighter.global_position.x)
    # Inject synthetic input into the fighter's input buffer
    fighter.input_buffer.inject_direction("right" if direction > 0 else "left")

func _execute_attack() -> void:
    var attacks = ["lp", "hp", "lk", "hk"]
    var chosen = attacks[randi() % attacks.size()]
    fighter.input_buffer.inject_button(chosen)

func _hold_back() -> void:
    fighter.input_buffer.inject_direction("left" if fighter.facing_right else "right")
```

**AI communicates through the input buffer**, not by directly setting fighter state. This means the fighter's state machine and combat system treat AI input identically to human input — no special code paths.

---

## 9. Signal Architecture

All inter-system communication flows through signals. No system directly calls methods on another system (except parent→child within a scene).

### 9.1 Signal Flow Diagram

```
Fighter                          CombatSystem                    RoundManager
───────                          ────────────                    ────────────
hit_landed ─────────────────────→ register_hit()
                                  │
                                  ├─→ hit_confirmed ─────────────→ (combo UI)
                                  ├─→ hit_blocked ───────────────→ (block VFX)
                                  └─→ combo_ended ───────────────→ (combo UI)
                                  
took_damage ────────────────────────────────────────────────────→ (health bar UI)
knocked_out ────────────────────────────────────────────────────→ on_fighter_ko()
                                                                  │
                                                                  ├─→ round_ended
                                                                  ├─→ match_ended
                                                                  ├─→ round_started
                                                                  ├─→ timer_updated ──→ (timer UI)
                                                                  └─→ announce ────────→ (announcer UI)
```

### 9.2 Signal Registry

| Signal | Emitter | Listener(s) | Payload |
|--------|---------|-------------|---------|
| `hit_landed` | Fighter (via hitbox area_entered) | CombatSystem | attacker, target, move |
| `took_damage` | Fighter | UI (HealthBar) | fighter, amount, remaining_hp |
| `knocked_out` | Fighter | RoundManager | fighter |
| `hit_confirmed` | CombatSystem | UI (ComboCounter), VFX, SFX | attacker, target, move, combo_count |
| `hit_blocked` | CombatSystem | VFX, SFX | attacker, target, move |
| `combo_ended` | CombatSystem | UI (ComboCounter) | fighter, total_hits, total_damage |
| `round_started` | RoundManager | Fighters (reset), UI, Camera | round_number |
| `round_ended` | RoundManager | UI, Camera | winner, round_number |
| `match_ended` | RoundManager | Scene transition | winner, scores |
| `timer_updated` | RoundManager | UI (RoundTimer) | seconds_remaining |
| `announce` | RoundManager | UI (RoundAnnouncer) | text |

### 9.3 Signal Wiring (in `fight_scene.gd`)

```gdscript
func _ready() -> void:
    # Fighter → CombatSystem
    $Fighters/Fighter1.hit_landed.connect($CombatSystem.register_hit)
    $Fighters/Fighter2.hit_landed.connect($CombatSystem.register_hit)

    # Fighter → RoundManager
    $Fighters/Fighter1.knocked_out.connect($RoundManager.on_fighter_ko)
    $Fighters/Fighter2.knocked_out.connect($RoundManager.on_fighter_ko)

    # Fighter → UI
    $Fighters/Fighter1.took_damage.connect($UI/HealthBarP1.on_damage)
    $Fighters/Fighter2.took_damage.connect($UI/HealthBarP2.on_damage)

    # CombatSystem → UI
    $CombatSystem.hit_confirmed.connect($UI/ComboCounter.on_hit)
    $CombatSystem.combo_ended.connect($UI/ComboCounter.on_combo_end)

    # RoundManager → UI
    $RoundManager.timer_updated.connect($UI/RoundTimer.on_timer_update)
    $RoundManager.announce.connect($UI/RoundAnnouncer.on_announce)
    $RoundManager.round_started.connect(_on_round_started)
    $RoundManager.match_ended.connect(_on_match_ended)

    # Cross-references
    $Fighters/Fighter1.opponent = $Fighters/Fighter2
    $Fighters/Fighter2.opponent = $Fighters/Fighter1
```

---

## 10. Directory Structure

```
games/ashfall/
├── project.godot                        ← Godot project config
├── icon.svg
│
├── scenes/                              ← All .tscn scene files
│   ├── main/
│   │   ├── fight_scene.tscn            ← Root fight scene
│   │   ├── main_menu.tscn             ← Title screen
│   │   └── character_select.tscn      ← Character selection
│   ├── fighters/
│   │   ├── fighter_base.tscn          ← Base fighter (inherited by all characters)
│   │   ├── ryu_analog.tscn           ← Character 1 (inherits fighter_base)
│   │   └── ken_analog.tscn           ← Character 2 (inherits fighter_base)
│   ├── stages/
│   │   └── dojo_stage.tscn           ← First stage
│   └── ui/
│       ├── fight_hud.tscn            ← In-fight HUD (health, timer, combos)
│       ├── health_bar.tscn           ← Reusable health bar component
│       ├── combo_counter.tscn        ← Combo hit display
│       ├── round_announcer.tscn      ← "ROUND 1" / "FIGHT!" / "K.O."
│       └── pause_menu.tscn           ← Pause overlay
│
├── scripts/                            ← All .gd script files
│   ├── fighters/
│   │   ├── fighter.gd                 ← Base fighter class (CharacterBody2D)
│   │   ├── fighter_state.gd           ← Base state class
│   │   ├── state_machine.gd           ← State machine controller
│   │   ├── states/                    ← Individual state scripts
│   │   │   ├── idle_state.gd
│   │   │   ├── walk_state.gd
│   │   │   ├── walk_back_state.gd
│   │   │   ├── crouch_state.gd
│   │   │   ├── jump_state.gd
│   │   │   ├── attack_state.gd
│   │   │   ├── air_attack_state.gd
│   │   │   ├── block_state.gd
│   │   │   ├── crouch_block_state.gd
│   │   │   ├── hit_state.gd
│   │   │   ├── launch_state.gd
│   │   │   ├── ko_state.gd
│   │   │   └── intro_state.gd
│   │   └── character_scripts/         ← Per-character overrides (if needed)
│   │       ├── ryu_analog.gd
│   │       └── ken_analog.gd
│   ├── systems/
│   │   ├── combat_system.gd           ← Hit detection, damage, combos
│   │   ├── round_manager.gd           ← Round flow, timer, win conditions
│   │   ├── input_buffer.gd            ← Input buffering and history
│   │   ├── motion_detector.gd         ← Motion input recognition (QCF, DP, etc.)
│   │   └── ai_controller.gd           ← AI opponent logic
│   ├── data/
│   │   ├── move_data.gd               ← MoveData resource class
│   │   └── fighter_moveset.gd         ← FighterMoveset resource class
│   ├── ui/
│   │   ├── health_bar.gd
│   │   ├── combo_counter.gd
│   │   ├── round_timer.gd
│   │   ├── round_announcer.gd
│   │   └── pause_menu.gd
│   ├── camera/
│   │   └── fight_camera.gd            ← Camera tracking and zoom
│   └── stages/
│       └── stage.gd                   ← Stage base script (boundaries, floor)
│
├── resources/                          ← .tres resource files (pure data)
│   ├── movesets/
│   │   ├── ryu_analog_moveset.tres    ← Character 1 move list
│   │   └── ken_analog_moveset.tres    ← Character 2 move list
│   └── fighter_data/
│       ├── ryu_analog_data.tres       ← HP, walk speed, jump height, etc.
│       └── ken_analog_data.tres
│
├── assets/                             ← Art, audio, fonts (non-code)
│   ├── sprites/
│   │   ├── fighters/
│   │   │   ├── ryu_analog/            ← Sprite sheets per character
│   │   │   └── ken_analog/
│   │   ├── stages/
│   │   │   └── dojo/
│   │   ├── ui/
│   │   └── effects/                   ← Hit sparks, block flashes
│   ├── audio/
│   │   ├── sfx/                       ← Hit sounds, whooshes, announcer
│   │   └── music/                     ← Stage BGM
│   └── fonts/
│
├── docs/
│   └── ARCHITECTURE.md                ← This document
│
└── tests/                              ← GDScript unit tests (future)
    └── test_combat_system.gd
```

---

## 11. File Ownership

Each file has **one owner** — the agent who creates and maintains it. Other agents may read any file but must not edit files they don't own without coordination.

### Ownership Map

| Agent | Owned Files | Domain |
|-------|-------------|--------|
| **Solo** (Lead) | `docs/ARCHITECTURE.md`, signal wiring in `fight_scene.gd` | Architecture, integration |
| **Chewie** (Engine) | `state_machine.gd`, `fighter_state.gd`, `fighter.gd`, `fight_scene.gd` (scene setup), `fight_camera.gd`, `stage.gd` | Core engine, scene tree, physics |
| **Lando** (Gameplay) | `states/*.gd` (all state scripts), `combat_system.gd`, `input_buffer.gd`, `motion_detector.gd` | Fighter mechanics, combat, input |
| **Tarkin** (Content) | `resources/movesets/*.tres`, `resources/fighter_data/*.tres`, `move_data.gd`, `fighter_moveset.gd`, `ai_controller.gd` | Move data, AI, character tuning |
| **Wedge** (UI) | `scripts/ui/*.gd`, `scenes/ui/*.tscn`, `scenes/main/main_menu.tscn`, `scenes/main/character_select.tscn` | All UI scenes and scripts |
| **Boba** (VFX/Art) | `assets/sprites/**`, `assets/effects/**` | All visual assets, sprite sheets |
| **Greedo** (Sound) | `assets/audio/**` | All audio assets |
| **Jango** (Tools) | `project.godot`, `.editorconfig`, linter configs, `addons/` | Project config, tooling |
| **Ackbar** (QA) | `tests/**` | Test scripts, balance verification |

### Shared File Rules

- `fight_scene.gd` — Chewie owns scene setup; Solo owns signal wiring section (clearly marked with `# === SIGNAL WIRING ===` comments)
- `project.godot` — Jango owns; other agents request changes via decisions inbox
- `fighter.gd` — Chewie owns the base class; Lando may add signals with coordination
- **Conflict resolution:** If two agents need the same file, Solo arbitrates. Default: serialize (one agent per wave).

### Parallel Work Lanes

These lanes can execute simultaneously with zero file conflicts:

```
Lane 1 (Chewie):  fighter.gd, state_machine.gd, fight_scene.gd, stage.gd
Lane 2 (Lando):   states/*.gd, combat_system.gd, input_buffer.gd
Lane 3 (Tarkin):  movesets/*.tres, ai_controller.gd, move_data.gd
Lane 4 (Wedge):   ui/*.gd, ui/*.tscn, menus
Lane 5 (Boba):    sprites/**, effects/**
Lane 6 (Greedo):  audio/**
```

Six agents building in parallel, zero file overlap.

---

## 12. Conventions & Anti-Patterns

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Script files | `snake_case.gd` | `combat_system.gd` |
| Scene files | `snake_case.tscn` | `fight_scene.tscn` |
| Resource files | `snake_case.tres` | `ryu_analog_moveset.tres` |
| Classes | `PascalCase` | `CombatSystem`, `FighterState` |
| Signals | `snake_case`, past tense for events | `hit_landed`, `round_ended` |
| Constants | `UPPER_SNAKE_CASE` | `BUFFER_SIZE`, `MAX_HP` |
| Node names in tree | `PascalCase` | `Fighter1`, `CombatSystem`, `HealthBarP1` |

### Anti-Patterns to Avoid

1. **Dead-end states** — Every state must have an exit path. Every timed state must have a timeout safety net. (See state machine skill.)

2. **Float timers for gameplay** — Use integer frame counters. `hitstun_frames -= 1`, not `hitstun_time -= delta`.

3. **Direct cross-system calls** — Systems communicate through signals, not direct method calls. `CombatSystem` does not call `fighter.state_machine.transition_to()` directly; it emits a signal that the fighter listens to. Exception: parent→child within the same scene branch.

4. **Logic in `_process()`** — All gameplay logic runs in `_physics_process()` for deterministic frame timing. `_process()` is only for cosmetic interpolation.

5. **God scripts** — No script over 300 LOC. If a script is getting large, decompose it. The state-per-node pattern prevents fighter god scripts.

6. **Unwired infrastructure** — Every new system must connect to at least one consumer in the same PR. No orphaned code.

7. **AI bypassing input** — AI must inject inputs into the buffer, not directly set fighter state. This keeps one code path for human and AI fighters.

8. **Timer conflation** — Separate timers for separate concerns. Attack duration, hitbox active window, and AI cooldown are three different integers, not one shared variable.

### Architecture Review Gates

- **First PR from each agent:** Full architecture review by Solo before merge
- **State machine changes:** Must include updated transition table
- **New signals:** Must be added to the Signal Registry (Section 9.2)
- **New files:** Must be added to File Ownership table (Section 11)

---

## Appendix: Quick Reference

### Adding a New Move

1. Create a `MoveData` resource in `resources/movesets/`
2. Set frame data: startup, active, recovery
3. Set damage, hitstun, blockstun, knockback
4. Create hitbox animation track in `AnimationPlayer`
5. Create sprite animation in `AnimatedSprite2D`
6. Add to character's `FighterMoveset` resource
7. If it's a special move, add motion command to `MotionDetector`

### Adding a New Fighter State

1. Create `new_state.gd` extending `FighterState`
2. Implement `enter()`, `exit()`, `physics_update()`, `handle_input()`
3. Add state node to `StateMachine` in fighter scene
4. Update transition table in this document
5. Add timeout safety net if state is timed
6. Verify: trace entry → exit in ≤60 frames

### Adding a New Character

1. Create inherited scene from `fighter_base.tscn`
2. Add sprite sheets to `assets/sprites/fighters/{name}/`
3. Create `AnimatedSprite2D` animations for all states
4. Create `AnimationPlayer` tracks for hitbox frame data
5. Create `FighterMoveset` resource with all moves
6. Create `fighter_data` resource with stats (HP, speed, etc.)
7. Optional: character-specific script extending `Fighter` for unique mechanics
