# SKILL: Enemy & Encounter Design

Universal enemy and encounter design patterns for action games. Covers enemy archetypes, behavioral frameworks, encounter composition, difficulty scaling, boss design, and AI patterns.

---

name: "enemy-encounter-design"
description: "Universal enemy & encounter design for action games — archetypes, AI patterns, wave composition, difficulty scaling, boss design"
domain: "game-design"
confidence: "medium"
source: "firstPunch enemy implementation (beat 'em up) + genre research"
has_reference: true

---

## Context

Use when designing enemy types/behaviors, planning encounters/waves/bosses, tuning stats (HP/speed/damage) or AI, creating enemy variety, or debugging "encounter is unfair/boring." Not for puzzle games, narrative adventures, turn-based RPGs, or purely stealth games.

## Core Patterns

### Enemies as Gameplay Verbs
Every enemy type teaches a skill:
- **Fodder** = spam attacks (make player feel powerful)
- **Bruiser** = position behind, exploit recovery (teach patience)
- **Agile** = predict and counter (teach timing)
- **Ranged** = close distance, manage threat (teach space)
- **Shield** = back attack or breaker ability (teach mechanics matter)

**Visual Design Communicates Behavior:** Large = slow + tanky. Small = fast + weak. Glowing/weapon = ranged. Shield/armor = special strategy.

### The 9 Core Archetypes
1. **Fodder:** 20-40 HP, moderate speed, low damage. Dead in 3-5 hits.
2. **Bruiser:** 80-120 HP, slow, high damage. Long windup (0.6-1.0s telegraph), punishable recovery.
3. **Agile:** 30-50 HP, fast (160-200 units/s), hit-and-run. Dash in → attack → retreat.
4. **Ranged:** 40-60 HP, moderate speed, projectile (200-400px range). Retreat when approached.
5. **Shield/Defender:** 60-100 HP, blocks frontal damage (~80%). Back attacks bypass.
6. **Swarm:** 15-25 HP each, fast, spawn 4-8. Weak to AoE/crowd control.
7. **Explosive/Suicide:** 40-60 HP, approaches to detonate (20-30 damage, 150px radius). Visual/audio telegraph.
8. **Support/Buffer:** 50-80 HP, heals/buffs allies. No direct damage. Eliminate first.
9. **Mini-Boss:** Any archetype × 1.5-2.0 stats + one unique move.

### Encounter Escalation Pattern
```
Wave 1: Type A solo (learn A)
Wave 2: Type A (2-3) (repeat A)
Wave 3: Type B solo (learn B)
Wave 4: A + B mixed (combine)
Wave 5: Type C solo (learn C)
Wave 6: A + B + C (synthesis)
```

**Rules:** New types in isolation. Mix with known types. Never >6-8 enemies simultaneously. New types 1-2 per wave.

## Key Examples

### Boss Design Philosophy
**Bosses are exams** testing everything learned. Not "harder versions of normal enemies."

**Core Principles:**
1. **Clear patterns (Mega Man):** Learnable within 2-3 minutes. "Punch 3× → charge → slam → repeat."
2. **Multi-phase:** Phase 1 (100-66% HP) = basic moveset. Phase 2 (66-33%) = add 1 attack + 1.2× speed. Phase 3 (33-0%) = add 1 more + desperation.
3. **Vulnerability windows obvious:** After attack, 1.0-2.0s window (stagger, weapon lowers, retreat visible).
4. **Spectacle budget:** Unique music, camera lock/zoom, environment changes, larger VFX, dramatic beats.

### DPS Budget Framework
```
Player HP: 200
Safe TTK: 4-6s (time to kill encounter before dying)
Max DPS budget: 200 / 4 = 50 dps

Normal enemy: 5 dps (safe margin: 2-3 enemies = 15 dps)
Bruiser: 12 dps (1-2 bruisers = 24 dps, high threat)
```

### Attack Throttling (Prevent Dogpiles)
```
MAX_SIMULTANEOUS_ATTACKERS = 2

If attackingEnemies.length >= 2:
    enemy.state = 'circle' (stay active but don't attack)
```

## Anti-Patterns

- **Bullet Sponge:** Huge HP, no interesting behavior. Fix: Add phases, new moves every 50 HP.
- **Unfair Ambush:** Spawn behind player with no warning. Fix: Always spawn at screen edge, walk on.
- **Palette Swap Army:** Identical behavior, different colors. Fix: Each color = distinct archetype.
- **Passive Crowd:** Enemies wait turn instead of acting. Fix: Attack throttling + circle/reposition behavior.
- **Instant Death Without Telegraph:** One-hit kill, no warning. Fix: 0.8s windup, visual/audio cue.

**Full details:** See REFERENCE.md for complete archetype stats, behavior patterns, wave composition rules, boss design patterns (rushdown, artillery, summoner, pattern boss), spawning fairness rules, difficulty scaling knobs, AI patterns (state machine, behavior trees, group coordination), and balancing checklist.