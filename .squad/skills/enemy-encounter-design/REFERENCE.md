# SKILL: Enemy & Encounter Design (Universal)

Enemy and encounter design patterns for action games across all genres. Covers enemy archetypes, behavioral frameworks, encounter composition, difficulty scaling, boss design philosophy, and AI patterns.

---

name: "enemy-encounter-design"
description: "Universal enemy & encounter design for action games — archetypes, AI patterns, wave composition, difficulty scaling, boss design"
domain: "game-design"
confidence: "medium"
source: "earned — extracted from firstPunch enemy implementation (beat 'em up context), generalized to be genre-agnostic with genre-specific guidance"

---

## When to Use This Skill

- Designing enemy types or behaviors for an action game
- Planning encounter waves, boss fights, or difficulty progression
- Tuning enemy stats (HP, speed, damage) or AI behavior
- Reviewing enemy code for pattern coherence and fairness
- Creating enemy variety without duplicating effort ("palette swap" anti-pattern)
- Debugging "encounter is unfair" or "encounters feel boring" feedback

## When NOT to Use This Skill

- Puzzle games or narrative adventures (enemies are environmental hazards, not gameplay verbs)
- Turn-based RPGs (different decision-making framework entirely)
- Purely stealth games (cover, detection, and evasion take priority over direct combat)

---

## Core Philosophy: Enemies as Gameplay Verbs

Every enemy type is a **teaching tool** and a **strategic choice** for the player.

### The Core Principles

**1. Enemies Teach Mechanics**
Each new enemy type should force the player to use a skill they just learned. Wave composition is a tutorial.
- Wave 1: Slow bruisers teach patience and positioning
- Wave 2: Fast enemies teach timing and prediction
- Wave 3: Both types together, requiring switching between strategies

**2. "Enemies Are Gameplay Verbs"**
If an attack button is a verb ("punch"), then each enemy type should be a different verb that the player must respond to:
- Fodder = spam attacks, test basic strings
- Bruiser = circle behind, exploit recovery windows
- Agile = predict and counter, not chase
- Ranged = close distance, manage threat
- Support = eliminate first, change win condition

This creates a "rock-paper-scissors" system where variety rewards tactical thinking instead of rote execution.

**3. Visual Design Communicates Behavior**
Before any tutorial or first encounter, the player should **intuit** the enemy's role from appearance:
- Large = slow + high HP + high damage (bruiser)
- Small = fast + low HP + low damage (fodder)
- Glowing/ranged weapon = ranged threat
- Shield/armor = requires specific strategy
- Unusual silhouette = special mechanic (charger, support, etc.)

Colors and proportions should **never lie**. If an enemy looks slow but moves fast, players feel cheated.

**4. Escalation, Not Saturation**
Encounter complexity should grow predictably:
```
Wave 1:  Type A solo              (learn type A)
Wave 2:  Type B solo              (learn type B)
Wave 3:  A + B mixed              (combine strategies)
Wave 4:  Type C solo              (learn type C)
Wave 5:  A + B + C + new pattern  (synthesis + escalation)
```

Never introduce 3 new enemy types simultaneously. New types should arrive 1-2 per wave with ample solo encounters before mixing.

---

## Enemy Archetypes (Universal)

These archetypes are genre-agnostic templates. Every enemy fits into one or more of these categories.

### 1. **Fodder** — The "Mook" Enemy

**Purpose:** Make the player feel powerful. Weak individually, threatening in groups.

**Stats:**
- HP: 20-40 (dead in 3-5 hits)
- Speed: Moderate (100-120 units/sec)
- Damage: Low (3-5 dmg per hit)
- Attack frequency: Moderate (every 1.0-1.5s)

**Behavior:** Approach, attack once/twice, repeat. No advanced tactics. No retreat.

**Design examples by genre:**
- **Beat 'em up:** Basic goon, green shirt variant, mook with pipe
- **Platformer:** Walking enemy, patrol + fall logic
- **Shooter:** Basic grunt, low armor, walks toward player in formation
- **RPG:** Low-level slime, goblin, basic skeleton
- **Stealth:** Unalert guard, standard patrol route

**Player response:** Spam attacks, crowd control abilities, group knockback. Makes the player feel like a hero.

**Teaching role:** Teaches attack timing and basic movement in safe environment.

---

### 2. **Bruiser** — The "Tank" Enemy

**Purpose:** Punish impatience. Reward positioning and pattern recognition.

**Stats:**
- HP: 80-120 (dead in 8-12 hits, tanky but not unkillable)
- Speed: Slow (50-80 units/sec)
- Damage: High (10-15 dmg per hit)
- Attack frequency: Slow (every 1.5-2.5s with long windup)

**Behavior:** Approach steadily, wind up before attacking, commit to attack, slow recovery. No chase. No tactical retreat.

**Mechanics:**
- Long startup frames (0.6-1.0s wind-up) = visible telegraph
- Long recovery window = punishable (3-5 frames of vulnerability)
- High poise/armor = takes 2-3 hits to interrupt

**Design examples by genre:**
- **Beat 'em up:** Armored enemy, heavy variant with super armor
- **Platformer:** Large slow-moving obstacle, pushes player back on collision
- **Shooter:** Heavy armor, slow movement, high damage shotgun
- **RPG:** Tank enemy, high DEF, low AGI, slow but high STR
- **Stealth:** Armored guard, harder to eliminate silently

**Player response:** 
1. Avoid the attack (dodge, jump, move back)
2. Wait for recovery
3. Circle behind and attack from the back (beats blocking)
4. Use a crowd-control ability to stun the windup

**Teaching role:** Teaches the value of positioning. Introduces "you can't face-tank damage — you must position."

---

### 3. **Agile** — The "Evasive" Enemy

**Purpose:** Punish slow reactions. Reward prediction and timing.

**Stats:**
- HP: 30-50 (low but dangerous)
- Speed: Fast (160-200 units/sec)
- Damage: Medium (6-8 dmg per hit)
- Attack frequency: Fast (every 0.5-0.8s, short combos)

**Behavior:** Dash in, attack 1-2 times, retreat to safety (150-200px distance), re-engage after 1-2s. Circles around the player unpredictably.

**Mechanics:**
- Short attack windows = harder to interrupt
- High movement speed = hard to chase
- Retreat behavior = creates "attack windows" that close quickly
- No super armor = dies fast but escapes faster

**Design examples by genre:**
- **Beat 'em up:** Fast enemy variant, hit-and-run tactics, strafe attacks
- **Platformer:** Jumping enemy, bounces around arena, unpredictable paths
- **Shooter:** Drone, fast-moving low-HP target, erratic movement
- **RPG:** Quick enemy, high AGI, low DEF, hit-and-run combos
- **Stealth:** Patrol guard with good hearing, reacts quickly to noise

**Player response:**
1. Predict the retreat path (don't chase, cut them off)
2. Use homing attacks or ranged abilities to punish retreats
3. Pin them in a corner (limit retreat space)
4. Wait for a predictable pattern in their movement

**Teaching role:** Teaches prediction over reaction. Introduces "you can't hit what you can't catch — anticipate."

---

### 4. **Ranged** — The "Zoner" Enemy

**Purpose:** Create distance management gameplay. Force the player to approach or find cover.

**Stats:**
- HP: 40-60 (dies quickly at close range)
- Speed: Moderate-to-fast (100-140 units/sec)
- Damage: Medium (6-10 dmg per projectile, can chain hits at distance)
- Attack frequency: Medium (every 1.0-1.5s)
- Range: 200-400px (attack/retreat boundary)

**Behavior:** Stay at distance, attack from range, retreat if player approaches within attack range. Strafe to maintain distance. Rare: use cover or high ground.

**Mechanics:**
- Projectile delay (150-300ms from launch to impact) = telegraphed
- Safe distance = 150-200px, retreat trigger at 100px
- No melee attack or weak melee (3-5 dmg)
- Vulnerable during attack windup (0.3-0.5s exposed time)

**Design examples by genre:**
- **Beat 'em up:** Enemy with gun/crossbow, keeps distance, panic fires
- **Platformer:** Cannon placement, turret, projectile launcher
- **Shooter:** Ranged combatant, sniper, grenadier, artillery support
- **RPG:** Mage enemy, casting animations, elemental projectiles
- **Stealth:** Guard with gun, cover user, alarm trigger

**Player response:**
1. Close distance before they establish range
2. Use cover (environment objects) or shields
3. Dodge projectiles (timing + positioning)
4. Eliminate them first (priority target in mixed waves)

**Teaching role:** Teaches space management and priority targeting. Introduces "some threats are at range — manage approach."

---

### 5. **Shield/Defender** — The "Puzzle" Enemy

**Purpose:** Introduce mechanical counter-play beyond "hit until dead."

**Stats:**
- HP: 60-100 (block reduces damage dealt)
- Speed: Slow (60-90 units/sec)
- Damage: Medium-high (8-12 dmg when attacking)
- Attack frequency: Every 2.0-3.0s (slow, with big windup)

**Behavior:** Maintain distance, hold shield up (blocks ~80% damage from front), attack occasionally with big windup. Rotate to face player. Panic-retreat if flanked.

**Mechanics:**
- Shield blocks frontal damage (from 0-120° cone ahead of them)
- Shield breaks after 30-50 blocked hits or 1-2 big attacks
- Once broken: 2-3s vulnerable window before shield regenerates
- Back attacks bypass shield entirely (2x damage multiplier)
- Shield has visual indicator (cracks, glow fades as health drops)

**Design examples by genre:**
- **Beat 'em up:** Shielded enemy, sword + shield, rank-and-file knight
- **Platformer:** Shielded obstacle, must hit from the side
- **Shooter:** Riot shield unit, mobile cover that dies to sustained fire
- **RPG:** Tank with barrier spell, requires breaker spell or back attack
- **Stealth:** Heavy guard with armor plating, requires explosives or headshot

**Player response:**
1. Attack the shield (destabilize them for the break window)
2. Circle around the back (back attack = bypass shield)
3. Use grab/throw attacks (grabs ignore shields)
4. Use a "breaker" ability (armor-piercing move)
5. Coordinate with allies for flanking (beat 'em up multi-player context)

**Teaching role:** Teaches "not all threats are solved by hitting harder — mechanics matter." Introduces positioning as a core skill.

---

### 6. **Swarm** — The "Crowd" Enemy

**Purpose:** Individual weakness creates safety; groups create danger. Teaches crowd control.

**Stats per individual:**
- HP: 15-25 (die very fast)
- Speed: Fast-to-moderate (120-150 units/sec)
- Damage: Very low (2-3 dmg each)
- Attack frequency: Very fast (every 0.4-0.6s)

**Spawn behavior:**
- Spawn in groups of 4-8
- Spawn in staggered waves (not all at once)
- Each individual has simple AI (approach, attack)
- No retreat or tactical spacing

**Mechanics:**
- Individual hits do negligible damage
- Cumulative damage from the group is dangerous (4 enemies × 3 dmg = 12 dmg/sec)
- Weak to area-of-effect abilities or crowd control (stun, knockback, screen-clear)
- No complex behavior (easy to code many instances)

**Design examples by genre:**
- **Beat 'em up:** Swarms of rats, bugs, tiny ninjas, clones
- **Platformer:** Enemy group that spawns infinitely until objective is cleared
- **Shooter:** Drone swarms, zombie hordes, waves of weak enemies
- **RPG:** Swarm of bats, spiders, locusts, army of golems
- **Stealth:** Guards in formation, must thin the group before engaging

**Player response:**
1. Crowd control ability (AoE, stun, knockback all at once)
2. Separate and destroy piecemeal (kite and focus fire)
3. Find bottleneck geography (funnel them into tight space)
4. Use screen-clearing "desperation" move
5. Run past them (they're weak enough to ignore if needed)

**Teaching role:** Teaches crowd management and the power of AoE abilities. Introduces "sometimes you need a different tool."

---

### 7. **Explosive/Suicide** — The "Risk" Enemy

**Purpose:** Create tension through threat, not through high damage. Force repositioning.

**Stats:**
- HP: 40-60 (fragile)
- Speed: Slow or moderate (70-120 units/sec)
- Damage: Very high + AOE (20-30 dmg in 150px radius on death)
- Threat range: 200-300px detonation radius

**Behavior:** Approach steadily, try to get close (target is within explosion radius). On death or trigger (low HP, get cornered), explode. Tries to avoid being hit but doesn't flee.

**Mechanics:**
- Visual telegraph: glowing, pulsing, sparking as they approach
- Audio cue: beeping, warning sound that accelerates as they get closer
- Explosion deals high damage + knockback in radius
- Deals damage to other enemies too (can chain explosions)
- Can be triggered early (hit until they explode, or wait)

**Design examples by genre:**
- **Beat 'em up:** Exploding barrel enemy, suicide bomber, dynamite-carrying enemy
- **Platformer:** Self-destruct obstacle, exploding platform
- **Shooter:** Suicide bomber, explosive barrel placement, mine trap
- **RPG:** Possessed bomb, elemental explosive construct
- **Stealth:** Explosive trap, tripwire, alarm bell (metaphorical "explosion")

**Player response:**
1. Kill them at range before they approach
2. Knock them away from the player (use knockback)
3. Corral them toward enemy groups (chain explosions as strategy)
4. Use terrain (pillar, obstacle) as shield
5. Time the explosion for when you're safely positioned
6. Defeat them last (if possible) to avoid damage spike

**Teaching role:** Teaches resource management (health, positioning) under pressure. Introduces "some threats require early elimination."

---

### 8. **Support/Buffer** — The "Enabler" Enemy

**Purpose:** Create priority targeting and change the win condition.

**Stats:**
- HP: 50-80 (moderate, killable but tanky)
- Speed: Moderate (100-130 units/sec)
- Damage: None or very low (buffs allies instead of attacking)
- Attack frequency: N/A (uses abilities instead)

**Abilities:**
- Heal nearby allies (20-30 HP, 3-5s cooldown)
- Buff allies (damage+, speed+, armor+)
- Cleanse status effects from allies
- Revive fallen allies (rare, powerful)

**Behavior:**
- Avoid the player (retreats at 150px)
- Stay near allies (150px proximity)
- Use buff/heal ability when allies take damage
- No direct combat capability (dies fast to focused fire)

**Design examples by genre:**
- **Beat 'em up:** Healer character, summoner ally
- **Platformer:** N/A (not common in platformers)
- **Shooter:** Medic, ammo supplier, buffing officer
- **RPG:** Cleric, bard, support mage, healer construct
- **Stealth:** Command officer that alerts guards (elimination prevents alarm spreading)

**Player response:**
1. Eliminate support first (prevents healing, removes buff source)
2. Focus fire on support to deny healing to other enemies
3. Use burst damage to kill support before it heals
4. Coordinate ally focus fire (in multiplayer)
5. Use crowd control to prevent support from reaching allies

**Teaching role:** Teaches priority targeting and threat assessment. Introduces "some kills are more valuable than others."

---

### 9. **Mini-Boss** — The "Elevated" Archetype

**Purpose:** Test the player on a single enemy before introducing multi-phase bosses.

**Stats:** Any archetype elevated by 1.5-2.0x:
- HP: 150-250 (significantly tankier than normal variants)
- Speed: Slightly increased or equal
- Damage: +5-10 dmg bonus
- Special: Unique move, charge attack, or multi-phase behavior

**Behavior:** Same as the archetype it's based on, but **with one additional move:**
- Bruiser mini-boss: adds a spin-to-clear or slam attack
- Agile mini-boss: adds a charge-up teleport or dive attack
- Ranged mini-boss: adds a multi-projectile barrage or homing shot

**Mechanics:**
- 2-phase structure (100-50% HP uses basic moves, 50-0% uses new move frequently)
- Longer startup frames (telegraphed heavily)
- Bigger hitboxes (easier to hit back)
- Music change or visual distinction (darker colors, larger size, special effects)

**Design examples by genre:**
- **Beat 'em up:** Tougher enemy variant (Heavy/Fast at 2x stats), named enemy, crew leader
- **Platformer:** Boss platformer enemy (multiple hit points, escalating behavior)
- **Shooter:** Elite/veteran enemy, stronger variant with armor
- **RPG:** Mini-boss encounter, named enemy with unique moveset
- **Stealth:** Tough guard with special equipment, squad leader

**Player response:**
1. Learn the new move's telegraph during phase 1
2. Exploit the move's recovery window in phase 2
3. Focus on surviving phase 2 (usually highest damage output)
4. Use knowledge from that enemy archetype's encounters (bruiser tips apply)

**Teaching role:** Bridge between trash encounters and boss fights. Tests mastery of a single archetype before multi-phase fights.

---

### 10. **Boss** — The "Exam" Enemy

See dedicated **Boss Design** section below. Bosses are comprehensive tests of all mechanics learned.

---

## Archetype Combinations & Emergent Difficulty

Combine archetypes to create new challenge profiles:

| Combination | Result | Example |
|-------------|--------|---------|
| Ranged + Agile | **Sniper** | Fast, hard to catch, stays at distance, deadly accurate |
| Bruiser + Shield | **Fortress** | Mobile wall, unstoppable advance, back attacks required |
| Bruiser + Support | **Paladin** | Tank that heals allies, eliminate first or engage from behind |
| Agile + Explosive | **Hit-and-Run Bomb** | Fast approach, detonates on retreat (timing-intensive) |
| Swarm + Buffing Lead | **Tier System** | Leader buffs weaker swarms, kill leader first to break cohesion |
| Ranged + Shield | **Archer Fortress** | Blocks projectiles from front, projectiles from back ignore shield |

---

## Boss Design Philosophy

Bosses are not "harder versions of normal enemies." Bosses are **exams** that test everything the player learned in that section.

### Core Boss Principles

**1. Bosses Have Clear Patterns (The Mega Man Principle)**

```
Boss pattern should be learnable within 2-3 minutes of observation.

NOT: Random attack order, unpredictable behavior, luck-based
YES: "Punch 3 times → charge attack → slam → repeat"
     Predictable, but executing a response is hard (timing, positioning, etc.)
```

Every boss should have a **documented pattern** (for your design notes):
```
Pattern A: Punch combo (0.5s + 0.5s + 0.7s) + 1.0s recovery
Pattern B: Charge across arena (0.8s wind-up, 1.2s charge, knockback on hit)
Pattern C: AOE slam (0.6s wind-up, 2.0s recovery)

Cycle: A → B → A → C → repeat
Tells: Punches have slight red glow, charge has gold aura, slam rumbles the arena
Vulnerability windows: 
  - After punch combo: 1.0s window
  - After charge: 1.5s window
  - After slam: 2.0s window
```

**2. Multi-Phase Design: Escalation Over Saturation**

```
Phase 1 (100-66% HP):  Teach the boss's basic move set
Phase 2 (66-33% HP):   Add 1 new attack + increase speed 1.2x
Phase 3 (33-0% HP):    Add 1 more attack + reduce recovery windows + desperation mode
```

**Each phase is a discrete difficulty spike** — not a gradual difficulty increase, but 1-2 discrete new challenges:

```javascript
// Phase transition design
if (boss.hp <= boss.maxHp * 0.66 && boss.phase === 1) {
    boss.phase = 2;
    boss.enterInvulnerable(1.5);           // Brief window where boss can't be damaged (transition moment)
    playPhaseTransitionVFX();              // Screen shake, camera focus, music change
    playPhaseTransitionSFX();              // Boss roar, environmental reaction
    
    // The new mechanic is taught during the invulnerability window
    boss.unlockAttack('groundSlam');       // New attack available
    boss.speedMultiplier = 1.2;            // 20% faster
    boss.recoveryMultiplier = 0.8;         // 20% shorter recovery (more aggressive)
}
```

**3. Vulnerability Windows: "Attack Now" Moments Are Clear**

```
"I'm a 12-year-old. I've never seen this boss before. When should I attack?"

YES: After the boss finishes its attack animation, it stands still for 1.0s (obvious)
NO:  "Try to hit during the recovery frame 18-23 of a 30-frame animation" (requires frame data)
```

Vulnerability windows should be **obvious visually**:
- Boss staggers or stumbles
- Boss's weapon drops or lowers
- Boss retreats to distance
- Boss is knocked back
- Camera focus on player (cinematically "this is your turn")

**Bad design:** Boss recovers instantly. No window. Only safe space is unpredictable.

**Good design:** Boss finishes attack, has 1.5s window. Window is telegraphed by animation, not by reading code.

**4. Spectacle Budget: Bosses Are Events**

A boss fight should **feel different** from a normal encounter:
- **Music**: Unique track, building intensity in phase 2-3
- **Camera**: Lock to arena, zoom in/out on attacks, focus shifts to vulnerability windows
- **Environment**: Arena changes per phase (debris, hazards appear), destructible elements react to boss attacks
- **Visual effects**: Bigger attacks (larger hitboxes, more VFX), glowing tell-signs, screen shake on big hits
- **Audio design**: Boss has unique attack sounds, voice lines, roar on phase transitions
- **Pacing**: Boss fight has dramatic beats (slow intro, building intensity, final desperation mode)

**Example:** Dark Souls phase transition — boss roars, screen shakes, music shifts, player can breathe before the next phase begins. That 2-second moment **feels earned**.

**Example:** Cuphead — boss is literally on screen taking up 40% of the viewport, with exaggerated animations telegraphing every move.

---

## Boss Design Patterns by Type

### The Rushdown Boss
**Pattern:** Aggressive combo fighter that applies pressure.
- Phase 1: Single 3-hit combo + dash
- Phase 2: Double 3-hit combo, interleaved dashes
- Phase 3: Triple combos, no breathing room

**Vulnerability:** Brief window after each combo ends.

**Challenge:** Punishing sustained pressure. Player must learn to block/dodge through the pattern, then punish the end.

**Example:** Hollow Knight — rapid melee combinations with obvious end-lag.

---

### The Telegraphed Artillery Boss
**Pattern:** Big, slow, heavily telegraphed attacks.
- Phase 1: Overhead smash (0.8s wind-up, visible red circle)
- Phase 2: Add spinning slash (0.6s wind-up)
- Phase 3: Rapid alternation, reduced wind-up time

**Vulnerability:** Long recovery after each attack (1.5s+).

**Challenge:** Patience and observation. Learn the tells, avoid the attack, punish during recovery.

**Example:** God of War — heavy, one-handed slow swings with obvious recovery.

---

### The Elemental/Summoning Boss
**Pattern:** Attacks are interspersed with summon phases.
- Phase 1: Spawns 2 minions, attacks 2-3 times, minions die
- Phase 2: Spawns 3 minions + attacks while minions are active
- Phase 3: Rapid minion respawns, fewer attack windows

**Vulnerability:** Only after minions are cleared (or minion-focused phase ends).

**Challenge:** Resource management and crowd control. Must decide: kill minions first or focus boss?

**Example:** Dark Souls — Ornstein & Smough (duo boss).

---

### The Pattern Boss
**Pattern:** Scripted, learnable, requires execution.
- Phase 1: Attack A → Attack B → Attack A → repeat
- Phase 2: Attack A → B → C → A → repeat
- Phase 3: Rapid A, B, C sequence with no pattern repetition

**Vulnerability:** Varies by attack phase; requires learning the cycle.

**Challenge:** Observation and memory. Pattern is learnable, but execution under pressure is hard.

**Example:** Cuphead — bosses have strict, learnable patterns; the challenge is not in unpredictability but in precise execution.

---

## Encounter Design: Wave Composition

Encounters should introduce enemy types systematically, then combine them for escalation.

### The Introduction Wave
**First encounter with a new enemy type should be:**
- Isolated (just 1 of the new type)
- Safe space (no other enemies, arena is open)
- Obvious visual design (telegraphed, clear mechanics)
- Non-punishing (losing doesn't feel unfair)

```javascript
// Wave 2 intro: Fast enemy
const wave2 = {
    triggerX: 1500,
    enemies: [
        { type: 'fast', x: 2000, y: 300 }  // 1 fast enemy, solo, player has space to learn
    ]
};

// Wave 3: Fast enemy mixed with known types
const wave3 = {
    triggerX: 3000,
    enemies: [
        { type: 'normal', x: 3200, y: 300 },
        { type: 'fast', x: 3400, y: 300 },
        { type: 'normal', x: 3600, y: 300 }
    ]
};
```

### The Escalation Pattern

```
Wave 1:  Type A (1-2)           ← Learn type A
Wave 2:  Type A (2-3)           ← Repeat to solidify
Wave 3:  Type B (1)             ← Introduce type B solo
Wave 4:  Type A + Type B (2+1)  ← Combine them (A is known, B is new, easy mix)
Wave 5:  Type C (1)             ← Introduce type C solo
Wave 6:  A + B + C (mixed)      ← Full synthesis
```

**Rules:**
1. New enemy types are introduced in isolation (1 enemy, no other threats)
2. New types are always mixed with at least 1 known type (provides familiarity)
3. Waves are never more than 6-8 enemies simultaneously (overwhelm = frustration)
4. Type variety increases by 1 new type every 2-3 waves (sustained learning curve)

### Arena Design Affects Difficulty

Same encounter is harder or easier based on arena layout:

| Arena | Difficulty | Example |
|-------|-----------|---------|
| **Open, flat** | Easy | Simple 2D platformer level, wide horizontal space |
| **Cluttered** | Medium | Destructible objects, platforms, pillars create obstacles |
| **Tight corridors** | Hard | Enemies can't spread out, crowd control easier/harder |
| **Multi-level** | Hard | Enemies above/below, ranged advantage, positional complexity |
| **Hazardous** | Hard + Tactical | Steam vents, spikes, lava; can throw enemies into hazards |
| **Circle arena** | Medium | Symmetric, limited escape routes, fair for all enemy types |

---

## Spawning Fairness

**Unfair spawns cause rage quits.**

### The Fairness Rules

**Rule 1: Players always see spawns coming**
```javascript
// GOOD: Enemy spawns at screen edge, walks on
const spawnX = camera.x + 320;  // Right edge of screen
enemy.x = spawnX;
enemy.state = 'approach';  // Walk on, player sees them

// BAD: Enemy spawns behind the player with no warning
const spawnX = player.x - 150;  // Behind player's vision
enemy.x = spawnX;
enemy.state = 'attack';  // Immediately attacks (feels cheap)
```

**Rule 2: Spawns are trigger-based, not random**
```javascript
// GOOD: Spawns at predetermined X position (wave marker)
if (player.x > wave.triggerX) {
    spawnWaveEnemies(wave);
}

// BAD: Random spawn (unpredictable) or time-based (ignores player progress)
if (Math.random() < 0.05) {
    spawnRandomEnemy();  // Can spawn behind player
}
```

**Rule 3: Stagger spawn arrival**
```javascript
// GOOD: Enemies spawn 0.5s apart (visual clarity)
setTimeout(() => spawnEnemy1(), 0);
setTimeout(() => spawnEnemy2(), 500);
setTimeout(() => spawnEnemy3(), 1000);

// BAD: All at once (sudden overwhelming pressure)
[enemy1, enemy2, enemy3].forEach(spawnEnemy);
```

**Rule 4: Initial spawn position is safe**
```javascript
// GOOD: Enemy spawns at edge, has to move to threaten
const spawnX = camera.x + 320;   // Off-screen right
const spawnY = groundLevel;      // Safe ground

// BAD: Enemy spawns in melee range
const spawnX = player.x + 50;    // Instant threat
const spawnY = player.y;         // Right next to player
```

---

## Difficulty Scaling: Knobs You Can Adjust

### Stat Scaling (Least Interesting)

Increase raw numbers:
- HP: +20 per difficulty tier
- Damage: +2 per difficulty tier
- Speed: +1.1x multiplier per tier

**Problem:** Doesn't change how the enemy plays, just takes longer to kill. Eventually becomes a "bullet sponge."

**Use for:** Quick tuning, late-game encounters, stat-based RPGs.

### Behavioral Scaling (Most Interesting)

Enemies get new moves and better AI:
- Fast enemy: adds a teleport dash (phase 2)
- Bruiser: adds a spin attack (phase 2)
- Ranged: adds homing projectiles (phase 2)
- Swarm: leader unit buffs the group (+20% speed/damage)

**Problem:** Requires more design and implementation work.

**Use for:** Boss fights, mini-boss encounters, late-game content.

### Composition Scaling

Harder encounters use smarter enemy combinations:

```
Difficulty 1:  Type A solo
Difficulty 2:  Type A + Type B (A is bruiser, B is easy swarm)
Difficulty 3:  Type A + Type B + Type C (mixed with ranged)
Difficulty 4:  Type A (mini-boss variant) + Type C + Type D support
```

**Problem:** Requires authoring more wave data.

**Use for:** Wave-based games, structured encounters.

### Environmental Scaling

The arena changes:

```
Difficulty 1:  Open arena, no hazards, lots of safe space
Difficulty 2:  Some destructible objects, limited safe zones
Difficulty 3:  Active hazards (steam vents, spikes), tight quarters
Difficulty 4:  Hazards + destructibles + moving platforms
```

**Problem:** Level design time, testing burden.

**Use for:** Platformers, arena-based games.

### Adaptive Scaling (Director AI)

A meta-AI watches player performance and adjusts encounter intensity in real-time:

```javascript
// Left 4 Dead director system
const difficulty = calculateCurrentDifficulty();  // Player health, ammo, progress

if (difficulty < 0.3) {
    // Player is winning easily
    director.spawnHarderEnemies();
    director.reduceSafeWaitTime();
} else if (difficulty > 0.7) {
    // Player is struggling
    director.reduceEnemySpawns();
    director.addHealthPickups();
}
```

**Problem:** Complex to tune, can feel unfair if poorly calibrated.

**Use for:** Games where difficulty curve matters most (horror, roguelikes, survival).

---

## AI Behavior Patterns

### State Machine AI (Simple, Common)

```
Idle
  ↓ (detect player)
Pursue
  ↓ (in range)
Attack
  ↓ (cooldown expires)
Idle

Each state has clear entry/exit conditions.
```

**Pros:** Simple to understand and debug, predictable behavior.

**Cons:** Hard to add nuance (requires more states), tedious to extend with new behaviors.

**Beat 'em up example:**
```javascript
// firstPunch approach — behavior tree style (simple state dispatch)
function updateEnemy(enemy, player, dt) {
    // Common checks
    if (enemy.state === 'dead') return;
    if (enemy.state === 'hitstun') { enemy.hitstunTime -= dt; return; }
    
    // State machine dispatch
    switch(enemy.variant) {
        case 'normal': _behaveNormal(enemy, player, dt); break;
        case 'fast': _behaveFast(enemy, player, dt); break;
        case 'heavy': _behaveHeavy(enemy, player, dt); break;
    }
}

function _behaveNormal(enemy, player, dt) {
    const distance = Math.hypot(player.x - enemy.x, player.y - enemy.y);
    
    if (distance < 80) {  // Attack range
        if (hasAttackSlot() && enemy.attackCooldown <= 0) {
            enemy.state = 'attack';
            enemy.attackCooldown = 1.5;
        } else {
            enemy.state = 'circle';
            circleAround(enemy, player);
        }
    } else if (distance < 150) {  // Approach range
        enemy.state = 'approach';
        moveToward(enemy, player);
    } else {
        enemy.state = 'idle';
    }
}
```

### Behavior Trees (Flexible, More Complex)

```javascript
// Selector: try each condition in order, execute first that returns true
selector([
    sequence([isDead(), do_nothing]),           // If dead, stop
    sequence([isHitstun(), do_hitstun_decay]),  // If stunned, play stun
    sequence([canAttack(), do_attack]),         // If can attack, attack
    sequence([inRange(), do_circle]),           // If close but can't attack, circle
    sequence([farAway(), do_approach]),         // If far, approach
    sequence([true(), do_idle])                 // Default: idle
])
```

**Pros:** Flexible composition, easy to add conditions, scales to complex AI.

**Cons:** Overkill for simple enemies, harder to debug (tree traversal).

### Attack Throttling (Prevent Unfair Dogpiles)

```javascript
// Global attack throttling
const MAX_SIMULTANEOUS_ATTACKERS = 2;

function updateEnemyAI(enemy, player, dt) {
    const attackingEnemies = enemies.filter(e => e.state === 'attack' || e.state === 'windup');
    
    if (attackingEnemies.length >= MAX_SIMULTANEOUS_ATTACKERS) {
        // Can't attack, circle instead
        enemy.state = 'circle';
    } else if (canAttack()) {
        enemy.state = 'attack';
        registerAsAttacker(enemy);  // Notify system
    }
}
```

**Why:** 2-4 enemies attacking simultaneously feels fair. 6+ enemies at once feels like a cheap dogpile.

### Group Coordination

**Flanking:** Enemies try to approach from different angles.
```javascript
const angleToPlayer = Math.atan2(player.y - enemy.y, player.x - enemy.x);
const desiredFlankAngle = angleToPlayer + (enemy.id % 2 === 0 ? 0.8 : -0.8);  // ±45 degrees
moveToward(enemy, player.x + Math.cos(desiredFlankAngle) * 100, player.y + ...);
```

**Surrounding:** Enemies position around the player to reduce escape space.
```javascript
// Distance to stand at: 150px (circle radius)
// Angle: distributed around 360° based on how many allies are nearby
const allyCount = countEnemiesNearPlayer();
const angleOffset = (enemy.id / allyCount) * Math.PI * 2;  // Distribute around circle
moveToward(enemy, player.x + Math.cos(angleOffset) * 150, player.y + Math.sin(angleOffset) * 150);
```

**Retreating when allies die:** Morale system.
```javascript
const allyDeathCount = trackDeadAllies();
if (allyDeathCount > maxMoraleHits) {
    enemy.state = 'retreat';  // Run away
    moveAway(enemy, player);
}
```

### Telegraphing: The Most Important Pattern

**A telegraph is a **visual or audio cue** that warns the player before an attack happens.**

```javascript
// Attack wind-up with visual telegraph
enemy.state = 'windup';
enemy.windupTime = 0.6;  // 600ms of warning

function renderEnemy(enemy, ctx) {
    if (enemy.state === 'windup') {
        // Visual tell: glow, pulsing ring, color change, etc.
        ctx.fillStyle = 'rgba(255, 0, 0, 0.3)';
        ctx.beginPath();
        ctx.arc(enemy.x, enemy.y, 100, 0, Math.PI * 2);  // Warning circle
        ctx.fill();
        
        ctx.font = '20px Arial';
        ctx.fillText('!', enemy.x - 10, enemy.y - 150);  // Exclamation mark
    }
}

// Audio telegraph: warning sound or alarm
function playTelegraph(enemy) {
    if (enemy.attackType === 'heavy') {
        audio.play('boss_charge_loop', 0.6);  // Loop while winding up
    }
}
```

**Telegraphs should be:**
- **Visual:** Red glow, charging effect, weapon raising, color change
- **Audio:** Warning beep, charge sound, voice line ("HERE I COME!"), crescendo music
- **Spatial:** Enemy positioning changes (steps back, lowers body), particle effects build
- **Clear:** Obvious enough that a first-time player notices it

**Anti-pattern:** No telegraph. Attack happens instantly. Player feels cheated.

---

## Difficulty & Tuning: The DPS Budget

### The DPS Budget Framework

**How much damage should enemies deal per second?**

```
Player HP:        200 hp
Safe HP:          50 hp  (don't want player 1-shot)
Vulnerable HP:    200 hp (how much damage per second is "dangerous")

Safe TTK (Time to Kill):  4-6 seconds (time player has to kill an encounter before dying)

Max DPS budget:   200 hp / 4 sec = 50 dps
```

**For a single normal enemy:**
```
Enemy damage:     5 dps
Safe margin:      2-3 other normal enemies before it's dangerous (5 dps × 3 = 15 dps)
```

**For a bruiser:**
```
Bruiser damage:   12 dps
Safe margin:      1-2 bruisers (12-24 dps = high threat)
Attack throttling: Only 1 bruiser should attack at a time
```

**For a ranged enemy:**
```
Ranged projectile: 8 dps
Safe margin:      3-4 projectile sources (dodgeable, predictable)
```

### Time-to-Kill Targets (60 FPS, damage per hit)

| Enemy Type | Time-to-Kill | Hits Needed (assuming 10 dps) |
|------------|-------------|-----|
| Fodder | 2-3s | 3-4 hits |
| Normal | 3-5s | 5-7 hits |
| Bruiser | 8-10s | 10-15 hits |
| Mini-boss | 20-30s | 30-45 hits |
| Boss | 60-90s | 90-135 hits |

**Rule:** Fodder should die quickly (feel powerful), bosses should take a while (feel epic).

### Threat Radius

**At what distance should an enemy become active?**

```javascript
const THREAT_RADIUS = 500;  // 500px away

if (distanceToPlayer < THREAT_RADIUS) {
    enemy.state = 'alert';  // Start pursuing
} else {
    enemy.state = 'idle';   // Wait
}
```

**Tuning:**
- Too small (100px): Enemies catch player off-guard
- Too large (800px): Encounters feel slow, lots of walking before combat
- Sweet spot: 300-400px for beat 'em ups (half a screen away)

### Spawn Rates & Simultaneous Enemies

```javascript
const MAX_SIMULTANEOUS_ENEMIES = 8;        // Total on-screen
const MAX_SIMULTANEOUS_ATTACKERS = 2;      // Attacking at once

if (aliveEnemies.length >= MAX_SIMULTANEOUS_ENEMIES) {
    // Stop spawning until enemy dies
    deferSpawn();
}
```

**Tuning:**
- Too few (2-3): Encounters feel easy, underwhelming
- Too many (10+): Encounters feel chaotic, unfair
- Sweet spot: 6-8 enemies max (manageable, challenging)

### The "One Death = Lesson" Rule

**If a player dies, they should know what to do differently next time.**

```
✗ Bad death:  Player doesn't know what killed them or why
✓ Good death: "Oh, I didn't see that ranged enemy. Next time I'll close distance faster."

✗ Bad death:  Attack spawned behind them with no warning
✓ Good death: "I got surrounded by 8 enemies. I should kite back next time."

✗ Bad death:  Random instant-death with no telegraph
✓ Good death: "That boss roared and did a big attack. I need to back up before the attack lands."
```

**Design rule:** Every enemy attack should have a:
1. **Telegraph** (visual/audio warning)
2. **Learnable timing** (not random)
3. **Clear counter** ("what does the player do to survive?")

---

## Anti-Patterns: What NOT to Do

### 1. "Bullet Sponge" Enemies

**Anti-pattern:** Enemies with huge HP pools that don't have interesting behavior.

```javascript
// BAD: 500 HP, only punches, takes 2 minutes to kill
{
    hp: 500,
    behavior: 'approach and attack'  // Same as 50 HP enemy, just slower
}

// GOOD: 500 HP, BUT has windups, phases, coordinated allies
{
    hp: 500,
    phases: [
        { pattern: 'punch combo', newMoveAt: 50% },
        { pattern: 'adds spawn', newMoveAt: 25% }
    ]
}
```

**Fix:** Add **interesting mechanics** at higher HP. Every 50 HP threshold should introduce a new challenge, not just extend the grind.

### 2. "Unfair Ambush" Spawns

**Anti-pattern:** Enemies spawn behind the player or without visual warning.

```javascript
// BAD: Spawns directly behind player
const spawnX = player.x - 100;  // Behind
enemy.x = spawnX;
enemy.state = 'attack';  // Immediately attacks

// GOOD: Spawns at edge of screen, walks on
const spawnX = camera.x + 320;  // Right edge
enemy.x = spawnX;
enemy.state = 'approach';  // Walk on camera first
```

**Fix:** Always spawn enemies where the player can see them coming. Use camera-relative spawn positions.

### 3. "Palette Swap Army" Variety

**Anti-pattern:** Every enemy is identical behavior, just different colors.

```javascript
// BAD: Red = same behavior, blue = same behavior, yellow = same behavior
const enemies = [
    { color: 'red', behavior: 'approach and attack' },
    { color: 'blue', behavior: 'approach and attack' },
    { color: 'yellow', behavior: 'approach and attack' }
];

// GOOD: Each color has distinct behavior
const enemies = [
    { color: 'red', behavior: 'bruiser (slow, tanky)' },
    { color: 'blue', behavior: 'agile (fast, evasive)' },
    { color: 'yellow', behavior: 'ranged (keeps distance)' }
];
```

**Fix:** Use archetype variety from earlier sections. Each enemy type should force a different player response.

### 4. "Passive Crowd" (firstPunch Lesson)

**Anti-pattern:** Enemies stand around waiting for their "turn" to attack instead of acting autonomously.

```javascript
// BAD: Enemy just stands still until it's "its turn"
if (isMyTurn()) {
    attack();
} else {
    doNothing();  // Just stands there passively
}

// GOOD: Enemy circles, repositions, or applies pressure while waiting
if (canAttack()) {
    attack();
} else {
    circle(player);  // Stay active, threaten space
}
```

**Fix:** Implement **attack throttling** with **secondary behavior** (circling, repositioning, posturing). Enemies should always be doing something.

### 5. "Instant Death" Without Telegraph

**Anti-pattern:** Attacks that one-hit kill without warning.

```javascript
// BAD: Boss slams, instant 200 damage (kills player if at 200 HP)
boss.attack();
player.takeDamage(200);  // No warning, instant death

// GOOD: Boss has 0.8s wind-up, then slam deals 100 damage (not instant kill)
boss.state = 'windup';  // 0.8s visual warning
boss.windupTime = 0.8;
// Then:
playWindupAnimation();  // Visual telegraph
playWindupSound();      // Audio telegraph
// Then:
player.takeDamage(100);  // High damage but not instant
```

**Fix:** Add **telegraph** (wind-up, audio cue, visual effect). No attack should instant-kill without warning. If one-hit kills are desired (Dark Souls style), they must be **telegraphed extremely clearly**.

### 6. Distance Threshold Dead Zones

**Anti-pattern:** Attack range and approach distance don't overlap, creating zones where the enemy does nothing.

```
// BAD: Dead zone between approach and attack
Approach range: < 200px
Attack range:   < 100px
Dead zone:      100-200px (enemy stands still, confused)

// GOOD: Ranges overlap
Approach range: < 150px
Attack range:   < 80px
Overlap:        80-150px (circle behavior bridges the gap)
```

**Fix:** Draw the number line. Verify `attackRange < circleDistance < approachThreshold`. Add circling behavior to fill gaps.

### 7. "Passive Arrow Spam" (Ranged Overload)

**Anti-pattern:** Too many ranged enemies at once, or ranged enemies that never run out of ammo and blast forever.

```javascript
// BAD: 4 ranged enemies, each firing projectiles every 0.5s indefinitely
const rangedEnemies = [
    { type: 'archer', fireRate: 0.5 },
    { type: 'archer', fireRate: 0.5 },
    { type: 'archer', fireRate: 0.5 },
    { type: 'archer', fireRate: 0.5 }
];
// Player is hit by 8 projectiles per second (unavoidable)

// GOOD: 1-2 ranged enemies with sparser fire
const rangedEnemies = [
    { type: 'archer', fireRate: 1.5 },  // Every 1.5s
    { type: 'archer', fireRate: 1.5 }
];
// Player is hit by 1-2 projectiles per second (dodgeable)
```

**Fix:** Cap concurrent ranged threats. Use attack throttling for ranged enemies too.

### 8. No Recovery Window for Bosses

**Anti-pattern:** Boss attacks endlessly with no gap for the player to attack.

```javascript
// BAD: Boss attacks every 1.0s with 0.4s attack time, 0.1s recovery
Boss attack #1: 0.0-0.4s (attack) + 0.1s recovery = 0.5s total
Boss attack #2: 0.5-0.9s (attack) + 0.1s recovery = 1.0s total
// No window for player to attack (0.1s gaps are too short)

// GOOD: Boss attacks with clear recovery
Boss attack #1: 0.0-0.6s (attack) + 1.0s recovery = 1.6s total
// Player has 1.0s window to attack (plenty of time)
```

**Fix:** Recovery must be **longer than startup**. `recovery >= startup + (active - 1)`. Always leave a breathing room for the player.

---

## Balancing & Tuning Checklist

Before shipping any enemy:

- [ ] Enemy has a clear archetype (fodder, bruiser, agile, ranged, etc.)
- [ ] Enemy's visual design communicates its archetype (big=slow, small=fast, etc.)
- [ ] Enemy has 1-2 primary attacks, not 6 (clarity beats variety)
- [ ] Attack has startup frames (telegraphed, not instant)
- [ ] Attack has recovery window (punishable, not safe)
- [ ] Enemy doesn't attack while other enemies are attacking (max 2 simultaneous)
- [ ] Attack throttling prevents unfair dogpiles
- [ ] Distance thresholds are drawn out and verified (no dead zones)
- [ ] Behavior changes based on situation (approach, attack, circle, retreat)
- [ ] New enemy type gets solo introduction wave before mixing
- [ ] Wave composition escalates (type A → B → A+B → C → A+B+C)
- [ ] DPS is within budget (see DPS Budget section)
- [ ] Time-to-kill matches enemy type target (3-5s for normal, 8-10s for bruiser)
- [ ] Spawn positions are fair (visible before attack, not behind player)
- [ ] Boss fights have clear patterns (Mega Man principle)
- [ ] Boss transitions between phases visibly (invulnerability + VFX)
- [ ] Boss has recovery windows after each attack
- [ ] All attacks are telegraphed (visual or audio)

---

## Cross-Genre Design Patterns

### Beat 'Em Up Specific

- **Grab/throw interactions:** Enemies should be grabbable; throws should deal bonus damage
- **Back attacks:** Always deal extra damage (incentivizes positioning)
- **Crowd control:** Knockback resets enemy positions, creating breathing room
- **Approach-based:** Enemies must close distance before attacking (melee-focused)
- **Hitstun:** Hitting enemies interrupts their current action (high skill expression)

### Platformer Specific

- **Patrol routes:** Enemies follow paths, predictable; adds environmental puzzle element
- **Jump threats:** Enemy patterns incorporate vertical movement (jumping, hovering)
- **Platform obstacles:** Enemies that ARE platforms (jump on them, careful of hitboxes)
- **Avoidance focus:** Surviving without hitting enemies is valid (escape, not fight)

### Shooter Specific

- **Cover usage:** Enemies use environmental cover, forces positioning
- **Suppression:** Enemies pin player down with fire, allies flank
- **Hitscan vs projectiles:** Different threat profiles, different counter-play
- **Ammo/resource consideration:** Some enemies carry supplies or upgrades
- **Formations:** Squad tactics (triangle formation, staggered approach)

### RPG Specific

- **Stat-based challenge:** Enemy level, stats, equipment matter more than behavior
- **Elemental weaknesses:** Enemy types are defined by resistances (fire/ice/water)
- **Status effects:** Enemies inflict poison/curse/slow; counter-play via buffs
- **Loot tables:** Enemy type determines drop tables (elemental slimes drop crystal shards)
- **Turn-based behaviors:** Enemies have discrete "turn," pattern recognizable over turns

### Stealth Specific

- **Patrol routes:** Predictable, observable paths; player plans around them
- **Detection cones:** Visual range indicator (when does guard notice you?)
- **Alert states:** Unaware → suspicious → alert → calling backup
- **Guard elimination priority:** Remove guards in order to minimize alerts
- **Noise mechanics:** Loud actions trigger guards, stealth is prioritized

---

## Documentation: Skill References

- **game-feel-juice** — How to make hits feel impactful (hitlag, screen shake, knockback)
- **beat-em-up-combat** — Beat 'em up frame data and combo systems (foundational)
- **state-machine-patterns** — Implementing flexible AI behavior structures
- **game-design-fundamentals** — Difficulty curves and progression
- **camera-systems** — Camera focus on boss fights, cinematic moments

---

## Summary: The Enemy Design Checklist

**Your enemy is good if:**
1. ✅ It has a clear archetype that forces a specific player response
2. ✅ Its visual design communicates its role (no surprises)
3. ✅ Its attacks are telegraphed and recoverable
4. ✅ It doesn't unfairly attack 2+ times simultaneously (throttled)
5. ✅ Its first encounter is safe (solo, isolated, obvious)
6. ✅ New enemy types arrive 1-2 per wave (gradual introduction)
7. ✅ It fits within the DPS budget (fair TTK relative to other threats)
8. ✅ It teaches a mechanic (directly or indirectly)

**Your boss is good if:**
1. ✅ It has a learnable pattern (Mega Man principle, not random)
2. ✅ It has clear vulnerability windows (attack-now moments)
3. ✅ It has 2-3 phases with discrete new challenges
4. ✅ Each phase feels visually/aurally distinct (spectacle)
5. ✅ Transitions are celebrated (invulnerability + camera + sound)
6. ✅ Recovery windows are long enough for player to counter-attack

**Your encounter is good if:**
1. ✅ New enemy types are introduced solo before mixing
2. ✅ Wave composition escalates type by type
3. ✅ Spawns are fair (visible, not ambush)
4. ✅ Arena layout affects difficulty appropriately
5. ✅ Difficulty curve matches progression (harder late, easier early)
6. ✅ One death = player knows what to do differently next time
