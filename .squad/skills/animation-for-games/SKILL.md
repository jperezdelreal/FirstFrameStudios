# SKILL: Animation for Games

Universal motion systems for any game. Animation tells the player what is happening, what is about to happen, and when they can act. Covers state machines, timing, sprite vs skeletal, and genre applications.

---

name: "animation-for-games"
description: "Universal animation principles, state machines, timing, and implementation patterns for all game genres and platforms"
domain: "animation-systems"
confidence: "low"
source: "firstPunch experience + cross-game research (Street Fighter, Celeste, Hollow Knight, Beat Saber)"
has_reference: true

---

## Context

Use when implementing character animation systems, tuning timing to match mechanics, debugging "animation feels floaty" or "game feels unresponsive," choosing sprite vs skeletal, or designing animation pipelines. Not for audio design, particle effects, UI animation, or character concept art.

## Core Patterns

### The 12 Principles (Game Priority)
**Tier 1 (Do not skip):**
1. **Timing:** Frame counts define weight/speed/impact. Wrong timing breaks everything.
2. **Anticipation:** Wind-up before action. Makes attacks readable and fair.
3. **Squash & Stretch:** Deformation conveys weight and impact.

**Tier 2 (High value):**
4. **Follow-Through:** Parts continue moving after main action stops.
5. **Staging:** Pose must read instantly, even as silhouette.
6. **Exaggeration:** Games can push further than reality. 120% is better than 100%.

### Animation State Machine (Universal)
```
IDLE → MOVEMENT (walk/run/dash/jump) → COMBAT (attack/hit/block/dodge) → DEATH
```

**Transition Matrix:** Define which states can go where. Use priority rules (death > hit > attack > movement > idle). Clear cancel windows (recovery last 30% is cancellable).

### Frame Data Concept (Combat)
```
Attack = Startup + Active + Recovery
Jab: 4f startup, 3f active, 6f recovery = 13f total (0.216s at 60fps)
Heavy: 16f startup, 8f active, 16f recovery = 40f total (0.666s)
```

**Rules:** Heavy = slow, light = fast. Recovery scales with power. Startup is readability.

## Key Examples

### Sprite vs Skeletal
**Sprite (frame-by-frame):** Artist control, predictable memory, best for pixel art. Cons: time-intensive, no procedural variation.

**Skeletal (bones):** Compact, blendable, scalable, procedural-friendly. Cons: steeper learning curve, less per-frame control.

**When:** Pixel art → sprite. Multiple characters/animations → skeletal. Smooth blending needed → skeletal.

### Attack Animation Anatomy
```
Wind-up (6f) → Active (8f) → Recovery (12f) = 26f total
```
**Vulnerability window:** After attack finishes, 1.0s window (obvious visually - stagger, weapon lowers, retreat).

### Walk Cycles
- **Snappy (8-12f):** Arcade fighters, platformers. Responsive, energetic.
- **Realistic (16-24f):** RPGs, action-adventure. Weighty, grounded.
- **Extra smooth (32+f):** High-fidelity games, cinematics.

## Anti-Patterns

- **Floaty Movement:** Animation disconnects from physics. Fix: Add squash on landing, frame-perfect arc timing.
- **Animation Lock:** Stuck in long animations, can't cancel. Fix: Cancel windows (last 30% of recovery).
- **Template Syndrome:** Every character animates identically. Fix: Light character (6f startup), heavy (20f startup).
- **Frame Data Ignorance:** Beautiful but feels bad. Fix: Document frame data, playtest timing.
- **No Transition Planning:** Hard cuts between animations. Fix: Blend time (0.05-0.15s cross-fade).

**Full details:** See REFERENCE.md for complete 12 principles, state machine patterns, timing tables, sprite sheet workflows, skeletal rig structures, procedural animation, genre-specific timing (fighter, platformer, RPG, puzzle, horror), and implementation checklist.