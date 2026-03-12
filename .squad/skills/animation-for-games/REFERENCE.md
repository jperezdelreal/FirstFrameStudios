---
name: "animation-for-games"
description: "Universal animation principles, state machines, timing, and implementation patterns for all game genres and platforms"
domain: "animation-systems"
confidence: "low"
source: "extracted from firstPunch experience + cross-game research (Street Fighter, Celeste, Hollow Knight, Beat Saber)"
origin: "First Frame Studios (2026)"
---

# SKILL: Animation for Games — Universal Motion Systems

Animation is the second language of game design. It tells the player what is happening, what is *about to* happen, and when they can act. A game can have perfect mechanics under the hood, but if animation timing is wrong, the player will feel the game is broken — even though the code is correct.

This skill covers the universal principles that apply to **any animation system**, **any genre**, **any engine**: from sprite sheets to skeletal rigs, from retro pixel art to modern 3D, from platformers to RPGs to fighters.

---

## When to Use This Skill

- Implementing a character animation system (state machine, frame sequences, transitions)
- Tuning animation timing to match game mechanics (attack startup, recovery, walk responsiveness)
- Debugging "animation feels floaty" or "the game feels unresponsive" (almost always an animation timing problem)
- Choosing between sprite sheets vs skeletal animation for a new project
- Designing animation pipelines for a multi-character game
- Creating knockback/hit reaction/death animations that feel impactful
- Setting up procedural animation systems (walking, bobbing, squash/stretch)

## When NOT to Use This Skill

- Audio design and sound effects — see procedural-audio skills
- Particle effects and visual effects — see `game-feel-juice` (for game feel application)
- UI animation and transitions — see `ui-ux-patterns` (when available)
- Character concept art and 2D art direction — see `2d-game-art`
- This skill is about MOTION SYSTEMS, not art creation. It assumes drawings/models already exist.

---

## 1. The 12 Principles of Animation Applied to Games

The Disney 12 principles define how good animation works. Games use the same principles, but with different priorities:

### 1.1 Squash & Stretch

**The Principle:** Deformation exaggerates impact and creates weight perception.

**Game Application:**
- Jump landing: compress the character 5-15% vertically on frame of impact
- Jump takeoff: stretch 5-10% vertically in the frames before leaving ground
- Getting hit: squash inward (10-20%) for a single frame, then bounce back
- Heavy object impact: squash on ground contact, stretch slightly on rebound

**Why It Matters for Games:**
The player's brain reads squash/stretch as "weight has landed" or "force was applied." Without it, even a heavy character looks floaty. This single effect makes combat feel 50% more weighty.

**Implementation:**
```javascript
// On jump landing, apply squash for 2-3 frames
if (isLanding) {
    const squashFactor = 1 - (0.15 * landingAge / 3); // 15% compression over 3 frames
    entity.scaleY = squashFactor;
    entity.scaleX = 1 + (0.15 * landingAge / 3) * 0.5; // slight width expansion
    landingAge++;
}
```

**Tuning Ranges:**
- Subtle (walk, small jumps): 5-8% deformation
- Normal (combat, platforming): 8-15% deformation  
- Exaggerated (heavy impacts, boss attacks): 15-25% deformation

### 1.2 Anticipation

**The Principle:** Movement before movement — the wind-up before the action.

**Game Application:**
- Attacking: crouch/wind-up frames BEFORE the hit frames
- Jumping: subtle squat before takeoff (1-3 frames)
- Charging abilities: visual buildup (glow, particle growth)
- Death: stagger back briefly before falling

**Why It Matters for Games:**
Anticipation is the ONLY way the player knows what's coming. In a 1v1 fight, if an opponent's attack has no wind-up, the player has zero opportunity to react. Frame-perfect fighting games use 5-20 frame startup times specifically to make attacks readable.

**Implementation:**
```javascript
// Attack state machine
const attackStates = {
    idle: { duration: 999 },
    anticipation: { duration: 6, nextState: 'active' },  // wind-up
    active: { duration: 8, nextState: 'recovery' },      // hit frames
    recovery: { duration: 10, nextState: 'idle' }        // recovery
};
```

**The Anticipation Priority Matrix:**
| Attack Weight | Startup Frames | Recovery Frames | Total Duration |
|---------------|---|---|---|
| Quick poke | 4-6 | 6-8 | 10-14 |
| Normal attack | 8-12 | 12-16 | 20-28 |
| Heavy attack | 16-24 | 16-24 | 32-48 |
| Ultra/Boss | 30-60 | 20-40 | 50-100 |

### 1.3 Staging

**The Principle:** The pose must read instantly, at any size, even as a silhouette.

**Game Application:**
- Character pose must be unambiguous (attack vs idle vs hit)
- Limb angles should exaggerate, not minimize
- Attack direction must be obvious from pose alone
- Enemy state (aggressive, defending, dying) must read in shadow

**Why It Matters for Games:**
In fast-paced games, the player has 100-300ms to read the opponent's state. A ambiguous pose means delayed reaction = player gets hit unfairly.

**Implementation:**
The silhouette test: play your animation in fullscreen. Squint. Can you still tell what the character is doing? If not, the pose doesn't have enough clear geometry.

**Examples:**
- GOOD: Punch pose = arm extended far from body, shoulder rotated back, weight shifted
- BAD: Punch pose = arm slightly extended, weight centered, could be idle

### 1.4 Follow-Through

**The Principle:** Parts of the body continue moving after the main action stops.

**Game Application:**
- Weapon trails and overshoot after attack finish
- Hair/cloth lag and swing after direction change
- Belly bounce on landing or quick direction change
- Arm overshoot at end of throwing motion
- Tail swing when character stops running

**Why It Matters for Games:**
Follow-through prevents animation from feeling robotic. It also gives visual feedback on impact (the weapon keeps moving = force was applied). Without it, everything feels stiff.

**Implementation (Damped Spring):**
```javascript
// Follower position lags behind target with damping
function updateFollowThrough(follower, target, stiffness, damping) {
    const diff = target - follower;
    follower.velocity += diff * stiffness - follower.velocity * damping;
    follower.position += follower.velocity * dt;
}
```

**Application Examples:**
- Weapon trails: stiffness=0.15, damping=0.9, oscillates 2-3 times
- Hair: stiffness=0.1, damping=0.85, gentle swinging
- Belly: stiffness=0.08, damping=0.8, bulges on impact then settles

### 1.5 Timing (Frame Counts)

**The Principle:** Timing = weight, speed, and impact force.

**Game Application:**
- Fast attack (light sword): 4-frame startup + 6-frame active = quick and snappy
- Heavy attack (two-handed sword): 16-frame startup + 12-frame active = slower, more weight
- Walk: 8-12 frames per cycle = snappy, arcade feel; 16-24 frames = realistic, grounded
- Idle: 2-4 second loops = subtle breathing/swaying
- Run: 6-10 frames per cycle = fast, energetic

**Why It Matters for Games:**
Frame count is the ONLY objective measure of game feel. The player's hands respond to timing precisely. A 2-frame input buffer change is immediately felt. This is why fighting games obsess over frame data.

**The Frame Data Concept (For Combat):**
```
Startup Frames = Frames from move input to first active frame
Active Frames = Frames where the hitbox can connect
Recovery Frames = Frames where the attacker is vulnerable after attack
Total = Startup + Active + Recovery

Example: Jab
Startup: 4f  (wind-up)
Active: 3f   (hit can connect on any of these 3 frames)
Recovery: 6f (vulnerable, can be interrupted)
Total: 13f (at 60fps = 0.216 seconds)
```

**Critical Timing Rules:**
1. **Heavy = Slow, Light = Fast** — If your heavy sword has the same startup as your jab, it's broken
2. **Recovery scales with power** — A heavy attack should have heavy recovery
3. **Startup is readability** — No startup = unreadable, unfair to opponent
4. **Active frames define combo potential** — More active frames = easier to combo

### 1.6 Exaggeration

**The Principle:** Games can push further than reality. 120% is better than 100%.

**Game Application:**
- Emotions: characters react BIG to damage (heavy flinch, dramatic knockback)
- Movement: characters move with more flourish than realistic (larger arm swing, higher jump arc)
- Impacts: objects deform more on collision than physics would suggest
- Colors: reaction effects use high saturation, exaggerated glow

**Why It Matters for Games:**
Reality is boring in games. The player expects exaggeration. A subtle hit reaction feels like nothing happened. A dramatic one feels impactful.

**Examples:**
- GROUNDED (but boring): Character falls naturally, realistic recovery time
- EXAGGERATED (better): Character gets knocked back 2-3x as far, stumbles backward, slower recovery
- RESULT: Exaggerated version feels like the attack had impact, even though damage is identical

### 1.7 Which Principles Matter MOST for Games

**Tier 1 (Do not skip):**
1. **Timing** — Wrong frame counts break everything
2. **Anticipation** — Wind-ups make actions readable and fair
3. **Squash & Stretch** — Makes weight/impact perceptible

**Tier 2 (High value, enables combat feel):**
4. **Follow-Through** — Prevents stiffness, adds polish
5. **Staging** — Ensures clarity across all zoom levels
6. **Exaggeration** — Transforms mechanical correctness into emotional impact

**Tier 3 (Nice to have, genre-dependent):**
7. **Secondary Action** — Idle blinks, breathing (less important in fast games)
8. **Overlapping Action** — Layers of movement (useful in slow games)

---

## 2. Animation State Machines

The backbone of all game animation. A state machine defines which animations can play, when they transition, and what takes priority.

### 2.1 Core States (Universal)

These states apply to **every** game character, any genre:

```
IDLE
├─ standing idle (subtle swaying/breathing)
├─ crouching idle (ready stance)
└─ air idle (falling)

MOVEMENT
├─ walk (forward, backward, lateral)
├─ run (fast forward)
├─ dash (quick directional movement)
├─ slide (momentum-based movement with stopping)
└─ jump
    ├─ jump startup (crouch wind-up)
    ├─ ascend (rising)
    ├─ apex (peak, brief hang)
    ├─ descend (falling)
    └─ land (impact + recovery)

COMBAT
├─ attack
│   ├─ light attack (jab)
│   ├─ heavy attack (power hit)
│   ├─ special attack (ability, ultimate)
│   └─ charged attack (wind-up + release)
├─ hit (taking damage)
│   ├─ light hit (flinch)
│   ├─ heavy hit (knockback + fall)
│   └─ critical hit (stun, special reaction)
├─ block (defense stance)
└─ dodge (quick evasion)

DEATH
└─ death (final animation, ~12-24 frames, can be exaggerated)
```

### 2.2 Transition Matrix (Which States Can Go Where)

```
From IDLE:
  → WALK (directional input)
  → JUMP (jump input)
  → ATTACK (attack input)
  → HIT (take damage)
  → DEATH (HP = 0)

From WALK:
  → IDLE (no input)
  → RUN (hold input)
  → JUMP (jump while moving)
  → ATTACK (attack while walking)
  → HIT (take damage while moving)

From ATTACK:
  → ATTACK (chain next attack, if allowed)
  → RECOVERY (automatically after active frames)
  → IDLE (after recovery, if no input)
  → HIT (can be interrupted by heavy damage)
  → DODGE (if "attack cancel into dodge" is allowed)

From HIT (Hitstun):
  → IDLE (hitstun expires, standing hit)
  → FALL (hitstun expires, heavy knockback hit)
  → DEATH (overkill hit)
```

### 2.3 Priority Rules (Combat > Movement > Idle)

When multiple inputs occur simultaneously, use priority:

```javascript
const statePriority = {
    death: 100,
    hit: 90,           // Getting hit always interrupts
    attack: 80,        // Attacking interrupts movement
    dodge: 75,         // Dodge interrupts attack (if allowed)
    jump: 70,          // Jump interrupts walk/run
    movement: 50,      // Walk/run is low priority
    idle: 0             // Idle is default
};
```

**Rule:** When transitioning to a higher-priority state, interrupt the current state immediately (with proper animation cleanup).

### 2.4 Animation Cancels (Interrupt Windows)

Not all animations can be interrupted. Frame-perfect games use strict cancel windows:

```javascript
// Example: Attack animation can be cancelled into Dodge during recovery
const attackStates = {
    startup: {
        frames: 6,
        cancelable: false          // Can't dodge during wind-up
    },
    active: {
        frames: 8,
        cancelable: false          // Can't dodge during active hits
    },
    recovery: {
        frames: 12,
        cancelable: true           // CAN dodge after frame 14 (14/12 = last 2 frames)
    }
};

// In game loop:
if (isDodgeInput && currentFrame >= activationFrame + cancelFrame) {
    transitionState(entity, 'dodge');  // Only succeeds if in cancel window
}
```

**Cancel Window Rules:**
- **Attack startup:** NOT cancellable (committed wind-up)
- **Attack active:** NOT cancellable (hit frames)
- **Attack recovery:** Cancellable in last 30-50% (committed, but not fully)
- **Jump:** Cancellable during ascent (move direction change)
- **Run:** Always cancellable (tight, responsive movement)

### 2.5 Blending Between States (Smooth Transitions)

Hard cuts between animations look jarring. Blending smooths transitions:

```javascript
// Cross-fade blend: lerp between two poses
function blendPoses(poseA, poseB, blendAlpha) {
    return {
        x: lerp(poseA.x, poseB.x, blendAlpha),
        y: lerp(poseA.y, poseB.y, blendAlpha),
        rotation: lerpAngle(poseA.rotation, poseB.rotation, blendAlpha),
        // ... all properties
    };
}

// In state machine:
const blendTime = 0.1; // 6 frames at 60fps
let blendAlpha = 0;

function transitionState(newState) {
    previousState = currentState;
    currentState = newState;
    blendAlpha = 0;
}

function updateAnimation(dt) {
    if (blendAlpha < 1) {
        blendAlpha += dt / blendTime;
        const pose = blendPoses(
            previousState.pose(),
            currentState.pose(),
            Math.min(blendAlpha, 1)
        );
        drawEntity(pose);
    } else {
        drawEntity(currentState.pose());
    }
}
```

**Blend Timing Rules:**
- **Quick transitions** (walk → run): 0.05-0.1s blend
- **Combat transitions** (idle → attack): 0.0s blend (snap to attack pose, critical timing)
- **Movement transitions** (run → idle): 0.1-0.2s blend (feels snappy)
- **Hit reactions** (idle → hit): 0.0s blend (immediate impact)

---

## 3. Sprite Animation vs Skeletal Animation

Two fundamentally different approaches, each with tradeoffs:

### 3.1 Sprite Animation (Frame-by-Frame)

**What:** Pre-drawn frames, arranged in sequence. Each frame is a complete image (PNG, PNG in sprite sheet, etc).

**Characteristics:**
- Each frame is individually drawn
- Stored as sprite sheet or separate PNGs
- Played by stepping through frame indices
- Memory: predictable, fixed per animation
- Quality: limited by number of frames (smooth = lots of frames = memory cost)
- Interpolation: limited to discrete frames

**Best For:**
- Pixel art games (Shovel Knight, Celeste, Enter the Gungeon)
- Stylized 2D (Scott Pilgrim vs The World game, Persona 4, Hades)
- Retro-inspired games
- Games where animation realism is NOT the priority
- Projects with 2D artists who prefer drawing

**Pros:**
- Artist has complete control over every pixel
- Predictable memory usage (frames = memory)
- No runtime computation, just image playback
- Easy to add detail (custom shading per frame)
- Familiar toolchain (Aseprite, Piskel, traditional frame-by-frame animation)

**Cons:**
- Time-intensive to create (8-12 frames per animation = hours of drawing)
- Scaling breaks unless power-of-2 sprite sheet sizing
- No procedural variation (each frame is static)
- Hard to create smooth transitions between animations
- Large sprite sheets can cause memory/load issues

**Example Frame Sheet:**
```
[Idle Frame 0] [Idle Frame 1] [Idle Frame 2] [Idle Frame 3]
[Walk Frame 0] [Walk Frame 1] [Walk Frame 2] [Walk Frame 3]
[Run Frame 0] [Run Frame 1]
[Attack Frame 0] [Attack Frame 1] [Attack Frame 2] ...
```

### 3.2 Skeletal/Bone Animation

**What:** A rig of bones/joints + vertex deformation. Bones animate (rotate/translate), and the mesh deforms to follow.

**Characteristics:**
- Single base mesh + bone hierarchy
- Bones are animated (rotations, translations)
- Mesh vertex weights determine bone influence
- Memory: compact (bones + base mesh only)
- Quality: smooth, scalable, blendable
- Interpolation: automatic between poses (bone rotations → mesh deformation)

**Best For:**
- 3D games (any 3D game uses skeletal animation)
- Modern 2D games wanting smooth animation (Hollow Knight, Celeste technically uses sprites but modern 2D indies use Spine/DragonBones)
- Character-heavy games needing lots of animation variation
- Games requiring blend trees (attack → movement blending, procedural animation)
- Projects scaling to multiple characters

**Pros:**
- Creation time scales well (rig once, animate many moves)
- Bone rotations are blendable (can smoothly transition between attacks)
- Memory efficient (single mesh + bones, reused across all animations)
- Easy to procedurally modify (add squash/stretch, IK, procedural movement)
- Scaling is seamless
- Industry standard (exported to most engines)

**Cons:**
- Steeper learning curve (bone rigging, weight painting)
- Requires skeletal animation tool (Spine, DragonBones, Blender)
- Less artistic control per frame (bound by rig constraints)
- Runtime deformation cost (mesh updated every frame)
- Overkill for simple pixel art

**Example Rig Structure:**
```
Root (center of mass)
├─ Spine (torso)
│  ├─ Head
│  │  └─ Eyes (rotates to look at target)
│  └─ Arms (L/R)
│     └─ Hands (L/R)
├─ Hips
│  └─ Legs (L/R)
│     └─ Feet (L/R)
└─ Tail (optional, follows root rotation)
```

### 3.3 When to Use Which

| Factor | Sprite | Skeletal |
|--------|--------|----------|
| Art style: Pixel art | ✓ | ✗ |
| Art style: Stylized 2D | ✓ | ✓ |
| Number of characters | 1-3 | 4+ |
| Animation count | <10 | 10+ |
| Memory budget: Tight | ✗ | ✓ |
| Smooth blending needed | ✗ | ✓ |
| Procedural animation | ✗ | ✓ |
| Artist availability | Drawing-focused | Rigging-focused |
| Engine support | Universal | Some engines weak |

### 3.4 Hybrid Approaches

**Sprite + Procedural Effects:**
Use sprite sheets for character body, procedural for:
- Squash/stretch (scale deformation)
- Weapon trails (procedural lines)
- Screen shake (camera offset)
- Particle effects (procedural generation)

Benefits: Artist-controlled character, plus juice through code.

**Example:**
```javascript
// Draw sprite at base position
ctx.drawImage(spriteSheet, frameX, frameY, width, height, x, y, width, height);

// Apply procedural squash/stretch on top
ctx.save();
ctx.translate(x + width/2, y + height/2);
ctx.scale(1 + squashStretchX, 1 + squashStretchY);  // Procedural deformation
ctx.drawImage(...);  // Redraw with deformation
ctx.restore();

// Draw weapon trail (procedural line)
drawWeaponTrail(ctx, startPos, endPos);
```

---

## 4. Animation Timing for Game Feel

How frame counts create specific game feel goals:

### 4.1 Attack Animation Anatomy

Every attack breaks into three phases:

```
Wind-up         Active         Recovery
(Anticipation)  (Hit Frames)   (Vulnerable)
───────────     ─────────      ──────────
    6f              8f             12f        = 26 frames total

Player can't act  | Hitbox active  | Player taking
during wind-up    | on these frames | damage risk
```

**Frame Data Example — Three Attack Weights:**

```
JABS (Quick, weak, multi-hit potential):
  Startup:  4f  (quick execution, visually reads fast)
  Active:   3f  (short window, makes it safe from far away)
  Recovery: 6f  (fast recovery, chains into next move)
  Total:    13f (0.216s at 60fps)
  Combo?    Yes (quick recovery allows chains)

HEAVY ATTACKS (Power, slow, knockback):
  Startup:  16f (wind-up is obvious, player has time to react)
  Active:   8f  (longer active window, more forgiving to execute)
  Recovery: 16f (slow recovery, big commitment)
  Total:    40f (0.666s at 60fps)
  Combo?    No (too slow, can't chain)

GRABS (Ultra-high commitment, unblockable):
  Startup:  20f (very telegraphed)
  Active:   10f (forgiving grab window)
  Recovery: 20f (grabbed opponent thrown, attacker recovers)
  Total:    50f (0.833s at 60fps)
  Combo?    No (throws have their own flow)
```

### 4.2 Walk Cycles

Balance between snappy arcade feel and realistic locomotion:

```
SNAPPY (8-12 frames total):
  Used in: Arcade fighters, platformers, quick games
  Feel: Responsive, energetic, arcadey
  Example: 8f walk = character feels quick and nimble
  
REALISTIC (16-24 frames):
  Used in: RPGs, action-adventure, grounded games
  Feel: Weighty, realistic, grounded
  Example: 20f walk = smooth natural motion

EXTRA SMOOTH (32+ frames):
  Used in: High-fidelity games, cinematics
  Feel: Realistic, cinematic
  Example: 48f walk = fluid, detailed leg mechanics
```

**Walk Cycle Structure:**
```
Frame 0-3:   Left foot forward, right foot back
Frame 4-7:   Legs passing, weight shift
Frame 8-11:  Right foot forward, left foot back
Frame 12-15: Legs passing, weight shift
Frame 16-19: Return to start (cycle repeats)
```

### 4.3 Idle Animations

The "resting" state, but not static:

```
BRIEF IDLE (2-3 second loop):
  1-2 frames: Return to neutral pose
  Rest of loop: Subtle breathing (vertical bob, 2-4 pixels)
  Use in: Arcade games, fast-paced action

ELABORATE IDLE (4-8 second loop):
  Stages: Standing → weight shift → arm adjustment → breathing return
  Variation: Multiple idle animations, randomly select
  Use in: RPGs, character-driven games
```

**Good Idle Examples:**
- Subtle vertical bob (breathing): ±2px, slow sine wave
- Weight shift: ±5 degrees hip rotation, 1 second cycle
- Arm sway: ±10 degrees shoulder rotation, asymmetric (not mechanical)
- Eye blink: Random blinks every 3-8 seconds, 2-3 frame blink

### 4.4 Hit Reactions

Feedback when taking damage:

```
LIGHT HIT (flinch):
  Startup:  0f (instant)
  Anim:     4-6f (quick recoil)
  Recovery: 0f (can act immediately)
  Knockback: Minimal (1-3 pixels)
  
HEAVY HIT (knockback + fall):
  Startup:  0f (instant)
  Anim:     8-12f (stagger backward)
  Recovery: 0-4f (can act after recovery)
  Knockback: Moderate (10-30 pixels)
  
CRITICAL HIT (stun + huge knockback):
  Startup:  2f (brief pause)
  Anim:     12-20f (dramatic stagger/spin)
  Recovery: 4-8f (delayed recovery)
  Knockback: Heavy (50+ pixels, can push into wall)
```

### 4.5 Death Animations

The final statement. Make it count:

```
QUICK DEATH (Arcade feel):
  Duration: 8-12 frames
  Style: Sudden collapse or flip
  Loop: One-shot, screen shakes, music stops
  
DRAMATIC DEATH (Cinematic feel):
  Duration: 20-30 frames
  Style: Extended knockback animation + fall + settle
  Loop: One-shot, screen darkens, respawn prompt
  
EXAGGERATED DEATH (Stylized feel):
  Duration: 30-60 frames
  Style: Spin, stretch, overshoot, elaborate finish
  Loop: One-shot, particles, screen effect, celebration
```

---

## 5. Animation in Different Engines

Tooling varies by engine, but concepts are identical.

### 5.1 Godot (AnimationPlayer + AnimationTree)

**AnimationPlayer:** Timeline editor, keyframe-based animation.

```gdscript
# In scene tree: AnimationPlayer node
$AnimationPlayer.play("idle")
$AnimationPlayer.play("attack", -1, 2.0)  # play "attack", no speed override

# Transitions (blending)
$AnimationPlayer.queue("walk")  # plays next after current

# Call scripts at specific frames
$AnimationPlayer.queue_animation_method(7)  # call method at frame 7
```

**AnimationTree:** Hierarchical state machine + blending.

```gdscript
# StateMachine pattern in AnimationTree
[Idle] ──(input)──> [Walk] ──(speed>1)──> [Run]
  ↓                    ↑                      ↓
[Attack] ──────────────────────────────── [Jump]

# Blend spaces: smooth transitions by parameter
# Example: Walk → Run blends by "speed" parameter
$AnimationTree.set("parameters/BlendSpace/blend_position", speed)
```

**Pros:** Visual editor, frame-accurate, built-in state machines  
**Cons:** Steep learning curve, can be slow to iterate

### 5.2 Unity (Animator + Animation Controller)

**Animator:** State machine-based, blend trees, parameters drive transitions.

```csharp
// Set state machine parameter (string, int, bool, float)
animator.SetFloat("speed", moveInput.magnitude);
animator.SetBool("isJumping", true);
animator.SetTrigger("attack");  // trigger-type parameters (one-frame events)

// Get current state info
AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
if (stateInfo.IsName("Attack") && stateInfo.normalizedTime > 0.6f) {
    // Can cancel after 60% of animation
}
```

**Blend Trees:** Hierarchical parameter-driven blending.

```
├─ Idle/Run [based on "speed" parameter]
│  ├─ Idle (speed < 0.1)
│  └─ Run (speed >= 0.1)
├─ Jump [based on "isJumping" bool]
└─ Attack [based on "attackType" int]
   ├─ Light (0)
   ├─ Heavy (1)
   └─ Special (2)
```

**Pros:** Industry standard, powerful blend trees, visual editor  
**Cons:** Can be slow with many parameters, blend tree complexity

### 5.3 General Engine Patterns

Regardless of engine:

```javascript
// State machine core (pseudo-code)
class AnimationController {
    constructor(entity) {
        this.entity = entity;
        this.currentState = "idle";
        this.frameCount = 0;
        this.frameInState = 0;
    }
    
    update(dt) {
        this.frameInState++;
        this.frameCount++;
        
        // State machine transition logic
        switch(this.currentState) {
            case "idle":
                if (inputMovement.length > 0) this.transitionTo("walk");
                if (inputAttack) this.transitionTo("attack");
                break;
            case "walk":
                if (inputMovement.length === 0) this.transitionTo("idle");
                if (inputAttack) this.transitionTo("attack");
                break;
            case "attack":
                const stateDef = this.getStateDefinition("attack");
                if (this.frameInState >= stateDef.duration) {
                    this.transitionTo("idle");
                }
                break;
        }
    }
    
    transitionTo(newState) {
        this.currentState = newState;
        this.frameInState = 0;
    }
}
```

### 5.4 Canvas 2D (Manual Frame Stepping)

For browser games using raw Canvas:

```javascript
// Manual frame stepping
const animations = {
    walk: { frames: 8, frameDuration: 2 }, // 8 frames, 2 frames each
    attack: { frames: 12, frameDuration: 1 }
};

let currentAnimation = "walk";
let animationFrame = 0;
let frameAge = 0;

function updateAnimation(dt) {
    frameAge += dt * 60; // Convert to frame count
    
    const animDef = animations[currentAnimation];
    if (frameAge >= animDef.frameDuration) {
        animationFrame = (animationFrame + 1) % animDef.frames;
        frameAge = 0;
    }
    
    renderFrame(spriteSheet, animationFrame);
}
```

---

## 6. Procedural Animation

Generated at runtime, not pre-authored. Enables variation and polish.

### 6.1 Procedural Walk

Generate walking motion via math instead of keyframes:

```javascript
function getWalkPose(cycle) {
    // cycle: 0-1 representing one complete walk
    // Bob (vertical)
    const bob = Math.sin(cycle * TAU) * 3;
    
    // Leg swing
    const leftLeg = Math.sin(cycle * TAU) * 30;
    const rightLeg = Math.sin((cycle + 0.5) * TAU) * 30;
    
    // Arm swing (opposite legs)
    const leftArm = Math.sin((cycle + 0.5) * TAU) * 25;
    const rightArm = Math.sin(cycle * TAU) * 25;
    
    // Head tilt
    const headTilt = Math.sin(cycle * TAU * 2) * 5;  // Higher frequency
    
    return {
        bodyY: bob,
        leftLegRotation: leftLeg,
        rightLegRotation: rightLeg,
        leftArmRotation: leftArm,
        rightArmRotation: rightArm,
        headRotation: headTilt
    };
}
```

**Advantages:**
- Seamless speed variation (change cycle rate, animation plays at any speed)
- Smooth transitions (blend between poses)
- Memory efficient

**Disadvantages:**
- Less artistic control
- Can feel mechanical if tuning is off

### 6.2 Screen Shake

Procedural camera jitter:

```javascript
function updateScreenShake(dt) {
    if (shakeTimeRemaining > 0) {
        // Sine wave oscillation for smooth jitter
        const phase = (Date.now() * shakeFrequency * 0.001);
        const shakeX = Math.sin(phase) * shakeAmount;
        const shakeY = Math.cos(phase * 0.7) * shakeAmount * 0.6;  // Asymmetric
        
        camera.x += shakeX;
        camera.y += shakeY;
        
        // Exponential decay
        shakeAmount *= Math.exp(-5 * dt);
        shakeTimeRemaining -= dt;
    }
}
```

### 6.3 Squash & Stretch

Dynamic deformation on velocity changes:

```javascript
function updateSquashStretch(entity, dt) {
    const velocityMagnitude = Math.hypot(entity.velX, entity.velY);
    const targetSquash = 1 - (velocityMagnitude / maxVelocity) * 0.15;
    
    entity.scaleY += (targetSquash - entity.scaleY) * 0.2;  // Smooth toward target
}
```

### 6.4 Trail Effects

Particle trails following movement:

```javascript
function updateTrail(entity, dt) {
    // Every frame, record position
    entity.trail.push({
        x: entity.x,
        y: entity.y,
        age: 0,
        maxAge: 0.3  // Trail fades over 0.3 seconds
    });
    
    // Age and remove expired trail points
    entity.trail = entity.trail.filter(point => {
        point.age += dt;
        return point.age < point.maxAge;
    });
}

function renderTrail(ctx, entity) {
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    for (let i = 0; i < entity.trail.length - 1; i++) {
        const p1 = entity.trail[i];
        const p2 = entity.trail[i + 1];
        const alpha = 1 - (p1.age / p1.maxAge);
        ctx.globalAlpha = alpha;
        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y);
        ctx.lineTo(p2.x, p2.y);
        ctx.stroke();
    }
    ctx.globalAlpha = 1;
}
```

### 6.5 Particle-Driven Animation

Use particles to create dynamic effects:

```javascript
// Footstep dust on landing
function onLanding(entity) {
    for (let i = 0; i < 8; i++) {
        const angle = (i / 8) * TAU;
        particles.push({
            x: entity.x,
            y: entity.y + entity.height,
            velX: Math.cos(angle) * 100,
            velY: Math.sin(angle) * 80 - 50,
            age: 0,
            maxAge: 0.5,
            size: 4
        });
    }
}
```

### 6.6 Inverse Kinematics (IK)

Procedurally position joints to meet targets (e.g., feet on ground, look-at targets):

```javascript
// Simplified IK: feet placement on terrain
function updateIK(skeleton) {
    // Get target position (e.g., ground at left foot)
    const leftFootTarget = getGroundHeight(skeleton.leftFootX);
    const rightFootTarget = getGroundHeight(skeleton.rightFootX);
    
    // Adjust leg lengths to reach targets
    skeleton.leftLegLength = distance(skeleton.hip, leftFootTarget);
    skeleton.rightLegLength = distance(skeleton.hip, rightFootTarget);
    
    // Solve joint rotations to maintain leg length
    solveIKChain(skeleton.hips, skeleton.leftKnee, skeleton.leftFoot, leftFootTarget);
    solveIKChain(skeleton.hips, skeleton.rightKnee, skeleton.rightFoot, rightFootTarget);
}
```

---

## 7. Animation Pipeline

The production workflow from concept to shipped game:

### 7.1 Concept → Key Poses → In-Betweens → Cleanup → Export → Integration → Tuning

```
1. CONCEPT
   └─ Reference videos, concept sketches, gameplay requirements
   
2. KEY POSES (Blocking)
   └─ Draw extreme poses only: start, middle, end of action
   └─ Quick rough sketches to establish motion
   
3. IN-BETWEENS (Spline)
   └─ Fill frames between key poses
   └─ Use ease curves (not linear interpolation)
   └─ Add overlapping action, secondary motion
   
4. CLEANUP (Polish)
   └─ Fix line weight, smooth curves, check silhouettes
   └─ Adjust timing based on playtest feedback
   └─ Add detail (shading, texture, effects)
   
5. EXPORT
   └─ Sprite sheets (PNG + metadata), or
   └─ Skeletal rig (JSON, FBX, GLTF)
   
6. INTEGRATION
   └─ Import into engine
   └─ Connect to state machine
   └─ Test blending, transitions, frame alignment
   
7. TUNING (Playtesting)
   └─ Adjust timings for game feel
   └─ Add juice (squash/stretch, trails, effects)
   └─ Balance responsiveness vs weight
```

### 7.2 Naming Conventions

Consistent naming prevents confusion across team:

```
Sprite Sheets (frame-by-frame):
  {character}_{action}_{variant}.png
  
  Example:
    brawler_idle_default.png
    brawler_walk_fast.png
    brawler_punch_heavy.png
    brawler_punch_light.png
    brawler_jump_startup.png
    brawler_jump_ascend.png
    brawler_jump_descend.png
    brawler_jump_land.png
    
Skeletal Animations (bones):
  {character}_{action}_{variant}.json (or .spine, .dragobones, etc)
  
  Example:
    brawler_idle_default.json
    brawler_walk_normal.json
    brawler_run_fast.json
    brawler_punch_light_01.json
    brawler_punch_light_02.json  (two-hit combo)
    brawler_punch_heavy.json
    brawler_grab_throw.json
    brawler_hit_light.json
    brawler_hit_heavy.json
    brawler_death_default.json

Convention Key:
  {character}: Entity name (brawler, defender, bruiser, etc)
  {action}: Animation type (idle, walk, run, punch, kick, grab, jump, hit, death)
  {variant}: Modifier if multiple versions of same action
    - Direction: forward, backward
    - Weight: light, normal, heavy
    - Emotion: happy, angry, hurt
    - Number: 01, 02 for multi-hit sequences
```

### 7.3 Asset Organization

**By Character (Recommended for small teams):**
```
animations/
├─ brawler/
│  ├─ idle.png
│  ├─ walk.png
│  ├─ attack.png
│  └─ ...
├─ defender/
├─ bruiser/
└─ ...
```

**By Action (Recommended for large teams, parallel work):**
```
animations/
├─ idle/
│  ├─ brawler.png
│  ├─ defender.png
│  └─ ...
├─ walk/
├─ attack/
└─ ...
```

**By Size (For responsive design):**
```
animations/
├─ 1x/ (mobile, small screens)
├─ 2x/ (desktop)
├─ 4x/ (high-res)
└─ ...
```

### 7.4 Frame Rate Selection

Different feel from different framerates:

```
12 FPS:
  Use: Flash-style animation, stylized games
  Feel: Choppy but charming (12 frames per second)
  Example: Paperfold, Bitsy
  
24 FPS:
  Use: Smooth cartoon animation, standard animation
  Feel: Fluid and natural, not too expensive
  Example: Disney animations, modern pixel art games
  
30 FPS:
  Use: Console games, some 3D games
  Feel: Smooth, standard for some engines
  Example: Some older console games
  
60 FPS:
  Use: Fast-action games, competitive games
  Feel: Hyper-responsive, smooth on 60Hz+ displays
  Example: Fighters, shooters, action games
```

### 7.5 Export Formats

**Sprite Sheets:**
- PNG (most common)
- JSON metadata (frame offsets, collision boxes, animation sequences)
- Tools: Aseprite, Texturepackr, free-tex-packer

**Skeletal Animation:**
- Spine JSON (.json + .atlas)
- DragonBones JSON (.json)
- FBX (3D, but used for 2D rigged animation in some engines)
- GLTF/GLB (standard 3D format, supports skeletal animation)

---

## 8. Animation for Different Genres

Genres have different animation priorities:

### 8.1 Action/Fighter

**Priority:** Frame-perfect timing, clear hitbox visualizations, impactful recovery

```
Attack Startup:   8-20f (telegraphed, fair)
Attack Active:    6-10f (reasonable window, skill reward)
Attack Recovery:  8-20f (commitment, can't mash)

Must-Have Animations:
  ✓ Light attack (jab): 4f startup, 3f active, 6f recovery
  ✓ Heavy attack (power): 16f startup, 8f active, 16f recovery
  ✓ Special move (super): 20f startup, 12f active, 20f recovery
  ✓ Hit reaction (flinch): 4f immediate reaction
  ✓ Knockback + fall: ragdoll or in-place stagger
  ✓ Block animation: defensive stance
  ✓ Grab: 20f startup, 10f throw recovery
```

**Example Frame Data (Street Fighter DNA):**
```
Ryu Hadoken:
  Startup: 15f (obvious wind-up)
  Active: 25f (projectile life, can block/dodge)
  Recovery: 22f (can chain into walk/dash)
  
Makes the move readable (15f = 250ms for opponent reaction) and balanced.
```

### 8.2 Platformer

**Priority:** Responsive jump arc, snappy direction changes, expressive idle

```
Jump Arc:        12-20f (feel the weight and control)
Land Recovery:   4-8f (quick, snappy feeling)
Direction Change: 0f (instant, hyper-responsive)
Walk:            8-12f (snappy, arcade-like)

Must-Have Animations:
  ✓ Jump startup (crouch): 2-3f (short wind-up)
  ✓ Jump ascent: 6-12f (rising arc)
  ✓ Jump apex: 1-3f (brief hang)
  ✓ Jump descent: 4-8f (falling)
  ✓ Land: 4-8f (impact + squash)
  ✓ Wall slide (if applicable): smooth, no impact
  ✓ Dash/double jump (if applicable): explosive startup
```

**Example (Celeste DNA):**
```
Jump:
  Startup: 0f (instant on input)
  Ascent: 14f (full jump arc)
  Descent: 8f (falling)
  Land: 6f (impact + recovery)
  
Air control: Can change direction at any time during ascent.
```

### 8.3 RPG

**Priority:** Elaborate ability animations, status effect visuals, party formation

```
Abilities:       20-60f (cinematic, impact-focused)
Status Effects:  Visual markers (poison glow, freeze particle)
Party Formation: Group positioning, formation changes

Must-Have Animations:
  ✓ Ability casting: 15f startup (build magic), 20-40f effect, 10f recovery
  ✓ Ability hit: 10f impact animation
  ✓ Status affliction: Sprite tint or particle aura
  ✓ Level up: Celebration animation (30f)
  ✓ Item use: Quick animation (5-10f)
```

### 8.4 Puzzle

**Priority:** Satisfying piece placement, cascade effects, celebration animations

```
Piece Move:      4f (quick, responsive)
Piece Lock:      8f (settling into place)
Cascade:         12f per level (satisfying tumble)
Match Clear:     20f (celebration animation)
Victory:         40-60f (big finish)

Must-Have Animations:
  ✓ Piece selection: subtle glow or bounce
  ✓ Piece placement: snap into grid + slight overshoot
  ✓ Cascade: gravity + rotation as pieces fall
  ✓ Match clear: explosion, particles, score pop
  ✓ Game over: slow settle or dramatic finish
```

### 8.5 Horror

**Priority:** Slow deliberate movement, environmental animation for tension

```
Walk:            20-30f (heavy, dread-filled)
Look Around:     15-20f (slow head turns, unease)
Breath:          Long idle cycles (5-10 seconds)
Startle:         2f reaction burst, then slow recovery

Must-Have Animations:
  ✓ Breathe (idle): Slow vertical bob, audible inhale/exhale
  ✓ Walk: Heavy footsteps, careful placement
  ✓ Run (fear): Desperate, uncontrolled acceleration
  ✓ Lean/Peek: Careful, deliberate head rotation
  ✓ Flinch: Violent startle, then slow recovery
  ✓ Fall: Gravity + controlled landing (gravity wins, impact is heavy)
```

---

## 9. Anti-Patterns

What NOT to do:

### 9.1 Floaty Movement

**Problem:** Animation disconnects from gameplay physics. The character drifts rather than grounding.

**Symptoms:**
- Jump doesn't *feel* like jumping (arc is smooth but weightless)
- Walk doesn't match ground contact (feet slide)
- Landing doesn't feel like impact (no squash, no recovery frame)

**Fix:**
- Land: add 10-20% squash, hitstun brief recovery
- Jump: frame-perfect arc timing to match physics
- Walk: keyframe footsteps to match ground contact, short stance phase

### 9.2 Animation Lock

**Problem:** Player stuck in long animations, can't cancel, feels unresponsive.

**Symptoms:**
- Attack finishes but player still frozen
- Can't dodge or jump while attacking
- Button mashing doesn't work

**Fix:**
- Cancel windows: last 30% of recovery is cancellable
- Jump buffering: input jump up to 4 frames before landing
- Attack input buffering: next attack in queue while current finishes

### 9.3 Template Syndrome

**Problem:** Every character animates the same way. No personality.

**Symptoms:**
- Light character has same attack timing as heavy character
- All walk cycles are identical
- No variation by character weight/personality

**Fix:**
- Light character: 6f startup, 12f recovery (fast, snappy)
- Heavy character: 20f startup, 20f recovery (slow, deliberate)
- Vary walk cycle speed and bob amount

### 9.4 Frame Data Ignorance

**Problem:** Beautiful animations that feel terrible to play because timing is wrong.

**Symptoms:**
- Attack hits but feels delayed
- Jump feels floaty
- Block feels unresponsive

**Fix:**
- Document frame data for every animation
- Playtesting: measure startup/recovery times
- Compare to reference games (Street Fighter, Celeste, etc)

### 9.5 No Transition Planning

**Problem:** Hard cuts between animations feel jarring.

**Symptoms:**
- Walk → Run snaps awkwardly
- Attack → Idle stutters
- Damage reaction interrupts movement badly

**Fix:**
- Blend time: 0.05-0.15s cross-fade
- Shared poses: attack recovery flows into idle pose
- Animation trees: blend spaces for smooth parameter transitions

### 9.6 Ignoring Hit Reactions

**Problem:** Attacks deal damage but character shows no reaction.

**Symptoms:**
- Hit enemy, nothing happens (looks weightless)
- Block feels powerless
- Combo doesn't feel satisfying

**Fix:**
- Light hit: 4f flinch, 1-3px knockback
- Heavy hit: 8-12f stagger, 20px+ knockback
- Hit flash: 1-2f color tint (white, red, or enemy color)

### 9.7 Procedural Overcomplexity

**Problem:** Procedural animation so complex it breaks visually or causes bugs.

**Symptoms:**
- Procedural IK causes jittery limbs
- Procedural walk glitches on slopes
- Blend between procedural and key-framed feels uncanny

**Fix:**
- Keep procedural simple (walk bob, screen shake, trails)
- Use keyframes for complex motions (attacks, special moves)
- Test procedural systems extensively (edge cases, extreme parameters)

---

## 10. Animation Checklist Before Shipping

Use this to validate animation quality before release:

### Technical
- [ ] All animations are registered in state machine
- [ ] Transitions are smooth (no snaps, consistent blend times)
- [ ] Cancel windows are tested and feel responsive
- [ ] Frame data is documented for all combat animations
- [ ] Memory usage is within budget (sprite sheets sized efficiently)
- [ ] Performance is stable (no frame drops during animation-heavy scenes)

### Game Feel
- [ ] Landing has squash/stretch and recovery frame
- [ ] Attacks have visible anticipation (startup frames are clear)
- [ ] Hit reactions are impactful (flash, knockback, hitstun)
- [ ] Idle is subtle but alive (breathing, swaying, blinks)
- [ ] Death animation is satisfying (exaggerated, long enough to read)

### Design
- [ ] Character personality matches animation style (fast characters feel fast)
- [ ] Silhouettes read at all zoom levels (squint test passes)
- [ ] Attack timing matches balance goals (heavy = slow, light = fast)
- [ ] Walk/run feel grounded and weighty (not floaty)
- [ ] Direction changes are responsive (instant, not sluggish)

### Audio Sync
- [ ] Sound effects trigger at correct frames (punch sound on active frame)
- [ ] Music stings sync with attack impacts
- [ ] Footstep sounds align with walk cycle ground contact

### Polish
- [ ] All animations have consistent outline/shading style (see `2d-game-art`)
- [ ] Juice effects are applied (see `game-feel-juice`)
- [ ] Color palette matches art direction (no color inconsistencies)
- [ ] VFX (particles, trails, flashes) enhance without overwhelming

---

## Cross-References

**Related Skills:**
- [`2d-game-art`](../2d-game-art/SKILL.md) — Visual style, color theory, procedural rendering (companion skill for sprite/character creation)
- [`game-feel-juice`](../game-feel-juice/SKILL.md) — Screen shake, hitlag, particles, feedback effects (animation creates the canvas, juice fills it)
- [`state-machine-patterns`](../state-machine-patterns/SKILL.md) — Transition logic, priority systems (animation state machine is an application of state machine patterns)
- [`beat-em-up-combat`](../beat-em-up-combat/SKILL.md) — Combat frame data, hitbox design (uses animation timing as foundation)
- [`godot-beat-em-up-patterns`](../godot-beat-em-up-patterns/SKILL.md) — Godot-specific animation implementation (AnimationPlayer, AnimationTree)

**Engine Documentation:**
- Godot: [AnimationPlayer Docs](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html)
- Unity: [Animator Docs](https://docs.unity3d.com/Manual/Animator.html)
- Spine: [Spine Runtime Documentation](http://en.esotericsoftware.com/spine-runtimes)

---

## Examples

### Example 1: Frame-Perfect Jab (Fighting Game)

```javascript
const jabAnimation = {
    startup: {
        frames: 4,
        pose: "windup",        // Crouch stance, arm pulled back
        cancelable: false
    },
    active: {
        frames: 3,
        pose: "extended",      // Arm fully extended
        hitboxActive: true,    // Hit detection runs on these frames
        cancelable: false
    },
    recovery: {
        frames: 6,
        pose: "recovery",      // Arm retracting, weight settling
        cancelable: true       // Last 2-3 frames (cancel window)
    }
};

// Total: 13 frames = 0.216 seconds at 60fps
// Allows: combo into next attack after frame 4 (startup + last of active)
```

### Example 2: Satisfying Jump (Platformer)

```javascript
const jumpAnimation = {
    startup: {
        frames: 2,
        pose: "crouch",        // Squash downward
        sfx: "jump_wind",      // Sound effect for wind-up
        squash: 0.85
    },
    ascent: {
        frames: 12,
        pose: "jumping",       // Extended, rising
        arcCurve: "easeOut",   // Gravity falloff
        airControl: true       // Can move left/right, change direction
    },
    apex: {
        frames: 2,
        pose: "apex",          // Brief hang at top
        airControl: true
    },
    descent: {
        frames: 8,
        pose: "falling",       // Body contracts slightly
        airControl: true,
        arcCurve: "easeIn"     // Faster fall
    },
    landing: {
        frames: 4,
        pose: "land",          // Crouch on impact
        squash: 0.8,           // 20% squash
        sfx: "land_impact",
        particles: "dust"
    }
};

// Total: 28 frames = 0.466 seconds
// Arc curve ensures realistic gravity
// Air control gives player agency
// Land squash + SFX makes impact feel real
```

### Example 3: Heavy Attack (Beat 'em Up)

```javascript
const heavyPunchAnimation = {
    startup: {
        frames: 16,
        pose: "powerUp",       // Arm pulled back, body twisted
        sfx: "wind_up",        // Audible charging
        particles: "charge",   // Visual buildup (glow)
        cancelable: false
    },
    active: {
        frames: 8,
        pose: "impact",        // Full extension, weight forward
        hitboxActive: true,    // Large hitbox active
        hitstun: 0.4,          // Opponent gets 24 frames stun
        knockback: 30,         // Strong push
        screenshake: 5,        // Impact effect
        sfx: "punch_heavy",
        cancelable: false
    },
    recovery: {
        frames: 16,
        pose: "recovery",      // Recovery from overextension
        vulnerable: true,      // Can be interrupted
        cancelable: true       // Last 5 frames (31% of recovery)
    }
};

// Total: 40 frames = 0.666 seconds (slow, weighty)
// Startup telegraphs the attack (fair to opponent)
// Heavy hitstun and knockback make hit feel impactful
// Long recovery = big commitment, balances power
```

### Example 4: Procedural Walk (Any Character)

```javascript
function generateWalkCycle(speed, characterSize) {
    const cycleFrames = 12 - (speed * 4); // Faster = shorter cycle
    const positions = [];
    
    for (let frame = 0; frame < cycleFrames; frame++) {
        const progress = frame / cycleFrames;  // 0-1
        
        // Vertical bob (simple sine)
        const bob = Math.sin(progress * TAU) * characterSize * 0.05;
        
        // Horizontal sway (weight shift)
        const sway = Math.sin(progress * TAU * 2) * 2;  // ±2 pixels
        
        // Leg angles (opposite swing)
        const legAngle = Math.sin(progress * TAU) * 25;  // ±25 degrees
        
        // Arm swing (opposite legs)
        const armAngle = -legAngle * 0.8;  // Dampened
        
        positions.push({
            bodyY: bob,
            bodyX: sway,
            leftLegRotation: legAngle,
            rightLegRotation: -legAngle,
            leftArmRotation: armAngle,
            rightArmRotation: -armAngle,
            head: Math.sin(progress * TAU * 2) * 3  // Subtle head bob
        });
    }
    
    return positions;
}

// Usage:
const walk = generateWalkCycle(0.5, 32);  // Speed 0.5, 32px tall character
playAnimation(walk, frameRate);
```

---

## Summary

Animation is the difference between a mechanic and an experience. Master these skills:

1. **The 12 Principles** — Why animation works psychologically
2. **State Machines** — How to organize animation transitions
3. **Frame Data** — The objective measure of game feel
4. **Timing** — The most powerful tool you have
5. **Iteration** — Animation is tuned, not set-and-forget

Every game, every genre, every platform uses these concepts. Learn them once, apply them everywhere.

---

**Confidence:** `low` — This skill captures universal patterns from firstPunch and cross-game research, but needs validation across different genres, engines, and production scales before bumping to `medium` or `high`.

**Created:** 2026-08-03  
**By:** Boba (Art Director, First Frame Studios)
