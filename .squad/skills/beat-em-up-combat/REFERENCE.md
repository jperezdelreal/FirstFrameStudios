# SKILL: Beat 'Em Up Combat Design

Combat design patterns for side-scrolling beat 'em ups. Covers attack lifecycles, frame data conventions, combo systems, enemy archetypes, boss design, and game feel.

---
name: "beat-em-up-combat"
description: "Combat design patterns for beat 'em up games — frame data, combos, enemy design, boss phases, game feel"
domain: "game-design"
confidence: "low"
source: "earned — extracted from firstPunch combat implementation across 4 agents (Lando, Tarkin, Yoda, Ackbar)"
---

## When to Use This Skill
- Designing or implementing combat for a side-scrolling beat 'em up
- Tuning attack timing, hitboxes, or damage values
- Creating new enemy types or boss encounters
- Debugging "combat feels wrong" or "too easy/hard" reports
- Reviewing combat code for timing/state correctness

## When NOT to Use This Skill
- Turn-based combat (different design vocabulary entirely)
- Platformer combat without combos (simpler model)
- Competitive fighting games (much deeper frame data requirements)

---

## Core Patterns

### 1. The Attack Lifecycle: Startup → Active → Recovery

Every attack has exactly three phases. Skipping any one produces bad game feel.

```
STARTUP (anticipation)    ACTIVE (hitbox live)    RECOVERY (vulnerability)
┌─────────────────┐      ┌──────────────┐        ┌─────────────────┐
│ Wind-up frames  │ ──►  │ Damage frames│  ──►   │ Cool-down frames│
│ NO hitbox       │      │ Hitbox ON    │        │ NO hitbox       │
│ Can be canceled │      │ Hit detected │        │ Punishable      │
│ Visual telegraph│      │ VFX/SFX fire │        │ Cannot cancel   │
└─────────────────┘      └──────────────┘        └─────────────────┘
```

**Anti-pattern (firstPunch lesson):** Zero startup frames on all attacks made combat feel weightless. Even 2-3 frames of anticipation (arm pull-back) adds impact.

**Frame data reference targets (60fps):**

| Attack Type | Startup | Active | Recovery | Total | DPS Target |
|-------------|---------|--------|----------|-------|------------|
| Light jab   | 2-3f    | 3-4f   | 4-6f     | 10-12f | 30-40 |
| Heavy punch | 4-6f    | 4-5f   | 8-12f    | 18-22f | 35-45 |
| Kick        | 3-5f    | 4-6f   | 6-8f     | 14-18f | 25-35 |
| Jump attack | 4-6f    | 5-8f   | 6-10f    | 16-22f | 40-50 |
| Special     | 6-10f   | 6-10f  | 10-15f   | 24-30f | 50-60 |
| Grab/throw  | 5-8f    | 2-3f   | 8-12f    | 16-22f | N/A |

**Rule:** Recovery ≥ Startup. Players must commit to attacks. If recovery < startup, attacks are free and spammable.

### 2. Hitbox/Hurtbox System

```javascript
// Hitbox: deals damage. Hurtbox: receives damage.
// They are SEPARATE rectangles, not the same as the entity bounding box.

const attackHitbox = {
    x: entity.x + (entity.facing === 1 ? 30 : -80),  // offset from entity
    y: entity.y - 20,
    width: 50,
    height: 40
};

// Critical: hitbox is only active during ACTIVE frames
if (attackPhase === 'active') {
    checkCollisions(attackHitbox, targetHurtboxes);
}
```

**Key rules:**
- Hitbox activates ONLY during the active phase — never during startup or recovery
- Use a `hitList` Set per attack to prevent multi-hitting the same target
- Clear `hitList` when the attack ends, not when it starts (prevents edge-case double-hits)
- Hitbox should extend slightly beyond the visual to feel generous (players expect leniency)

**Anti-pattern (firstPunch lesson):** Hit detection ran only on the first frame of attack. Must check every frame during the active window.

### 3. Combo System Patterns

**Gatling combo (recommended for beat 'em ups):**
```
Light → Light → Light → Heavy (ender)
  Each hit chains into the next if input arrives during a cancel window.
  The cancel window overlaps with late active + early recovery frames.
```

```javascript
// Cancel window: allow chaining during last 3 active frames + first 4 recovery frames
const canCancel = (attackPhase === 'active' && activeTimer <= 3) ||
                  (attackPhase === 'recovery' && recoveryTimer >= recoveryDuration - 4);

if (canCancel && input.wasPressed('attack')) {
    startNextComboHit();
}
```

**Combo counter rules:**
- Increment combo count on HIT confirmation, not on input press
- Reset combo after 1-2 seconds of no hits (combo timeout)
- Scale combo feedback: hits 1-3 normal, 4-6 stylish, 7+ screen effects
- DPS should increase slightly per combo hit (reward commitment)

**Anti-pattern:** Incrementing combo on button press — produces inflated counts when whiffing.

### 4. Enemy Design Vocabulary

| Archetype | Role | HP | Speed | Attack Pattern | Player Response |
|-----------|------|-----|-------|----------------|-----------------|
| **Grunt** | Fodder | Low | Medium | Walk up → single swing | Mash attack, crowd control |
| **Dasher** | Disruptor | Low | Fast | Charge from offscreen | Time dodge, counter-attack |
| **Tank** | Pressure | High | Slow | Slow windup → heavy hit | Circle behind, punish recovery |
| **Ranged** | Zoner | Low | Medium | Stay back → projectile | Close distance, priority target |
| **Shield** | Puzzle | Medium | Slow | Blocks frontal attacks | Grab, back attack, or jump attack |

**Enemy AI throttling (critical for feel):**
```javascript
// Max 2 enemies attacking simultaneously — prevents unfair dogpiles
const MAX_SIMULTANEOUS_ATTACKERS = 2;
const currentAttackers = enemies.filter(e => e.state === 'attack' || e.state === 'windup');

if (currentAttackers.length >= MAX_SIMULTANEOUS_ATTACKERS) {
    // Remaining enemies orbit and taunt instead of attacking
    this.behaviorState = 'circle';
}
```

**Distance threshold coherence (firstPunch lesson):**
```
attackRange < circleDistance < approachThreshold
    80px    <    125px      <     150px

If circleDistance > attackRange, enemies orbit forever without attacking.
Draw the number line. Verify no dead zones.
```

### 5. Boss Phase Design

```
Phase 1 (100-66% HP): Basic pattern — teach the boss's moves
Phase 2 (66-33% HP):  Add new attack + increase speed — escalate pressure
Phase 3 (33-0% HP):   Desperation mode — remove recovery windows, add minions
```

**Phase transition pattern:**
```javascript
if (boss.hp <= boss.maxHp * 0.66 && boss.phase === 1) {
    boss.phase = 2;
    boss.enterInvulnerable(2.0);  // Brief invuln during transition
    playBossPhaseTransition();     // VFX + camera + sound
    boss.unlockAttack('groundSlam');
}
```

**Rules:**
- Each phase should be learnable independently (~30 seconds of pattern recognition)
- Transition = brief invulnerability + camera focus + sound cue (reward the player)
- Add minion spawns sparingly — overwhelm = frustration, not challenge
- Final phase should feel urgent: faster attacks, wider hitboxes, environmental changes

---

## Game Feel Checklist

Apply ALL of these on every hit. Missing any one makes combat feel "off":

| Effect | Duration | Purpose |
|--------|----------|---------|
| **Hitlag** (freeze frames) | 3-6 frames (50-100ms) | Weight and impact |
| **Knockback** | 5-15px push | Spatial feedback |
| **Screen shake** | 2-4 frames, 2-4px | Camera impact |
| **Hit VFX** (impact spark) | 4-8 frames | Visual confirmation |
| **Hit SFX** (layered) | Instant | Audio feedback |
| **Enemy flash** (white) | 1-2 frames | Damage confirmation |
| **Slow-mo** (kills only) | 6-10 frames at 0.3x | Reward for kills |

```javascript
// Hitlag: freeze both attacker and target
onHit(attacker, target, damage) {
    const hitlagFrames = damage >= 20 ? 6 : 3;
    game.setHitlag(hitlagFrames);
    
    target.knockback(attacker.facing * 10);
    renderer.shake(3, 4);  // intensity, duration in frames
    vfx.spawnImpactSpark(target.x, target.y);
    audio.playLayeredHit(damage);  // bass + mid + high layers scale with damage
    
    if (target.hp <= 0) {
        game.setSlowMo(0.3, 10);  // 30% speed for 10 frames
    }
}
```

---

## Anti-Patterns

1. **Zero startup frames** — Attacks feel like button presses, not physical actions. Always add 2+ frames of anticipation.
2. **Hitbox active during recovery** — Player can "mash through" encounters. Hitbox must deactivate before recovery begins.
3. **Timer conflation** — Using one timer for both attack duration AND cooldown. These are separate concerns: animation duration vs AI decision delay. (Caused 3 critical bugs in firstPunch.)
4. **Symmetrical frame data** — If every attack has identical timing, combat becomes monotonous. Vary the risk/reward profile.
5. **No attack throttling** — All enemies attacking at once is unfair. Use a `MAX_SIMULTANEOUS_ATTACKERS` cap with orbiting behavior for excess enemies.
6. **Distance threshold dead zones** — Attack range and approach distance must overlap. Draw the number line and verify.
7. **Combo count on input** — Inflates numbers. Count on confirmed hit only.
8. **Missing hit list per attack** — Without tracking which targets were already hit, multi-frame hitboxes deal damage every frame.

---

## Checklist

Before shipping any combat change, verify:

- [ ] Every attack has startup > 0 frames (anticipation)
- [ ] Recovery ≥ startup (commitment cost)
- [ ] Hitbox only active during active phase
- [ ] Hit list prevents multi-hit per attack
- [ ] Combo increments on HIT, not INPUT
- [ ] Enemy distance thresholds have no dead zones (draw the number line)
- [ ] Max simultaneous attackers is capped (2-3)
- [ ] Hitlag fires on every hit (3-6 frames)
- [ ] Screen shake fires on every hit
- [ ] Hit SFX has variation (pitch randomization ±5%)
- [ ] DPS is within target range for the attack type
- [ ] Boss phase transitions include invulnerability + VFX
- [ ] New enemy types fit an archetype with a clear player response
