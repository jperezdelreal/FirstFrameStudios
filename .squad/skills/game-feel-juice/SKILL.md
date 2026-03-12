# SKILL: Game Feel & "Juice"

The difference between "press button, thing happens" and "press button, FEEL the impact." Juice is the collection of feedback effects that make interactions satisfying. Applies to every genre.

---

name: "game-feel-juice"
description: "Juice patterns and feedback techniques — screen shake, hitlag, flash, particles, knockback, squash-and-stretch, sound sync, time manipulation"
domain: "game-design"
confidence: "medium"
source: "firstPunch combat implementation + genre research (Celeste, SoR4, Hollow Knight, Gungeon, Hades)"
has_reference: true

---

## Context

Use when implementing feedback effects for player actions (attack, jump, dash, collect, UI), tuning mechanics that work but feel lifeless, debugging "combat feels weightless" or "interaction feels flat," or creating a game feel checklist before shipping a feature. Not for pure UI feedback, animation systems, or audio pipelines (juice is part of these, not a replacement).

## Core Patterns

### The 10 Core Juice Techniques
1. **Screen Shake:** Camera jiggles on impact. 2-5px amplitude, 0.1-0.2s duration. Small hit: 2px, heavy: 5-8px.
2. **Hitlag (Freeze Frames):** Game pauses 2-6 frames on hit. Light: 2-3f, heavy: 4-6f. THE most important effect.
3. **Hitstun:** Target stunned 0.3-0.8s after hit. Light: 0.2s, medium: 0.4s, heavy: 0.6-0.8s.
4. **Knockback:** Push target away. Light: 100 force/20-30px. Heavy: 250 force/50-80px. Include upward bounce.
5. **Flash (Color):** Target turns white/color briefly. Normal: white 0.067s, damage taken: red 0.15s.
6. **Particle Bursts:** 3-5 sparks/dust radiate outward. Lifetime 0.2-0.5s with gravity.
7. **Squash & Stretch:** Scale 5-15% on impact/jump/landing. Jump takeoff: squash down. Airborne: stretch up. Landing: squash.
8. **Sound Sync:** Audio + visual SAME FRAME. Even 2f desync feels wrong. Vary pitch/volume by damage.
9. **Time Manipulation:** Slow-mo on critical moments. Kill: 0.15-0.2 time scale for 0.3-0.5s. Use sparingly.
10. **Combined Layering:** Stack 3-4 subtle effects. Each alone is subtle. Together, punchy.

### Attack Connects Pattern (Layered)
```
Same frame:
1. Hitlag (freeze attacker + target, 4f)
2. Screen shake (3px, 0.1s)
3. Hit flash (target white, 0.067s)
4. Knockback velocity applied (300 px/s)
5. Sound (impact SFX, volume scaled to damage)
6. Particles (4 sparks radiating)
7. Hitstun state (0.4s)
8. Score/combo counter increment
```

### Player Jump Pattern (3 Phases)
**Takeoff:** Squash down (0.95x, 1.05y), sound, dust particles (2).
**Airborne:** Stretch up (1.0x, 1.1y), sustained.
**Landing:** Squash (1.05x, 0.85y), sound, shake (2px), dust (4 particles).

## Key Examples

### Tuning Guidelines (60fps Rule)
At 60fps, 1 frame = 16.67ms. Most juice effects 2-8 frames (33-133ms):
- 2f (33ms) = almost instantaneous (flash)
- 4f (67ms) = perceptible, quick (hitlag)
- 6f (100ms) = noticeable, snappy (shake)
- 8f (133ms) = feels slow if longer

**Start subtle, dial up:** Implement at 50% → test → increase 20-30% → repeat. Never exceed 150% of baseline.

### Layer, Don't Stack
**Wrong:** One big effect (10px shake).
**Right:** 3-4 subtle effects (3px shake + flash + particles + sound). Combination > sum of parts.

### Toggle Test (Gold Standard)
Create debug toggle that disables ALL juice. Play with ON and OFF. If difference < 30%, implementation weak. If > 50%, over-juicing. Target: 40-50% improvement from juice alone.

## Anti-Patterns

- **Juice Fatigue:** Everything shakes/flashes. Fix: Reserve dramatic juice for critical moments. Scale by significance.
- **Desync (Audio-Visual):** Sound 3f after visual. Fix: Sound and visual triggered same frame. Never `setTimeout()` for audio.
- **Constant Motion:** Shake never stops. Fix: Shake has clear start/end (< 0.3s). Between moments, game is STILL.
- **Copy-Paste Juice:** Every hit identical. Fix: Vary by attack type (punch: white flash/sparks, kick: yellow/dust, special: multi-color/burst).
- **Juice on Non-Events:** Trivial actions get full juice. Fix: Critical (full juice), major (70%), minor (30%), ambient (0%).

**Full details:** See REFERENCE.md for complete technique breakdowns, implementation patterns by game event (hit, jump, damage, death, boss transition, UI interaction), tuning ranges, firstPunch learnings, genre applications (beat 'em up, platformer, fighter, puzzle, 3D action), and shipping checklist.