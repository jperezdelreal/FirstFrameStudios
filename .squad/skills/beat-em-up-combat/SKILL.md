---
name: "beat-em-up-combat"
description: "Combat design patterns for beat 'em up games — frame data, combos, enemy design, boss phases, game feel"
domain: "game-design"
confidence: "low"
source: "earned — extracted from firstPunch combat implementation"
has_reference: true
---

## Context
Combat design patterns for side-scrolling beat 'em ups. Covers attack lifecycles, frame data, combos, enemy archetypes, and game feel learned from firstPunch across 4 agents.

## Core Patterns

- **Attack lifecycle: Startup → Active → Recovery** — Every attack needs all three phases. Startup = anticipation, Active = hitbox live, Recovery = vulnerability
- **Frame data targets (60fps):** Light jab 10-12f total, Heavy punch 18-22f, Kick 14-18f. Recovery ≥ Startup (non-negotiable commitment)
- **Hitbox/Hurtbox separation** — Hitbox active ONLY during active frames. Use `hitList` Set to prevent multi-hitting same target
- **Gatling combo system** — Chain attacks during cancel window (late active + early recovery). Increment combo on HIT, not input
- **Enemy AI throttling** — Max 2 simultaneous attackers. Remaining enemies orbit/taunt. Prevents unfair dogpiles
- **Distance threshold coherence** — `attackRange < circleDistance < approachThreshold`. Draw number line, verify no dead zones

## Key Examples

**Game feel on hit (apply ALL):**
```javascript
onHit(attacker, target, damage) {
    game.setHitlag(damage >= 20 ? 6 : 3);  // freeze frames
    target.knockback(attacker.facing * 10);
    renderer.shake(3, 4);
    vfx.spawnImpactSpark(target.x, target.y);
    audio.playLayeredHit(damage);
    if (target.hp <= 0) game.setSlowMo(0.3, 10);
}
```

**Enemy archetypes:**
- **Grunt** — Low HP, medium speed, walk → swing. Mash attack
- **Dasher** — Low HP, fast, charges from offscreen. Time dodge
- **Tank** — High HP, slow, heavy windup. Circle behind
- **Ranged** — Low HP, projectiles. Close distance, priority target

## Anti-Patterns

- **Zero startup frames** — Attacks feel weightless. Always add 2+ frames
- **Hitbox active during recovery** — Mashable, no commitment
- **Timer conflation** — One timer for duration AND cooldown. Separate concerns
- **No attack throttling** — Unfair dogpiles. Cap at 2-3 simultaneous
- **Distance dead zones** — Overlap thresholds correctly
