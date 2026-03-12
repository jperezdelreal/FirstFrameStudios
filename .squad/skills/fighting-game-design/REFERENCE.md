# SKILL: Fighting Game Design

Design patterns, mechanics, and balance frameworks specific to 1v1 fighting games. Covers the unique challenges that separate fighters from other action genres: frame data as law, the RPS triangle, input motions, combo theory, and the meta-game of reads.

---

name: "fighting-game-design"
description: "1v1 fighting game design — frame data, combo theory, RPS triangle, meter systems, input motions, matchup balance, and player archetypes"
domain: "game-design"
confidence: "medium"
source: "extracted from Ashfall GDD creation (Yoda, 2025) + cross-genre research (SF6, Tekken 8, Guilty Gear Strive, Under Night, Fantasy Strike)"

---

## When to Use This Skill

- Designing combat mechanics for a 1v1 fighting game
- Creating character movesets, frame data, and balance targets
- Designing meter/resource systems that reward specific playstyles
- Tuning combo systems (proration, juggle limits, link windows)
- Reviewing fighting game code for timing, collision, or feel issues
- Planning netcode architecture (deterministic requirements)

## When NOT to Use This Skill

- Beat 'em up combat (1vMany, different design vocabulary) — see `beat-em-up-combat`
- Platform fighters (Smash-like, different physics model)
- Turn-based combat systems
- General game feel/juice patterns — see `game-feel-juice`

---

## 1. The Fighting Game Core Loop

The 30-second loop of every fighting game:

```
NEUTRAL (footsies) → PRESSURE (advantage) → COMBO/PUNISH → RESET → NEUTRAL
```

- **Neutral:** Both players at mid-range, looking for an opening. This is where spacing, pokes, and projectiles matter.
- **Pressure:** One player has advantage (landed a hit, opponent is blocking). Mixups happen here.
- **Combo/Punish:** Confirmed hit into damage. Execution phase.
- **Reset:** After knockdown or combo end, both players return to a decision point.

Every mechanic must serve one of these phases. If a feature doesn't affect neutral, pressure, combo, or reset, it doesn't belong in the combat system.

---

## 2. The RPS Triangle (Rock-Paper-Scissors)

The foundation of fighting game interaction:

```
ATTACK  →  beats  →  THROW ATTEMPT (opponent is pressing buttons, not blocking)
THROW   →  beats  →  BLOCKING (grab beats guard)
BLOCK   →  beats  →  ATTACK (defense absorbs offense)
```

**Critical:** Every option must lose to something. If blocking beats both attacks AND throws, there's no reason not to block. If attacks beat both blocking AND throws, there's no mixup — just mash.

**Layered RPS:**
- **High/Low:** Standing attacks vs crouching attacks. Standing block loses to lows. Crouching block loses to overheads.
- **Left/Right:** Cross-ups and side switches. Must block in the correct direction.
- **Strike/Throw:** The core triangle. Fast but blockable vs slow but unblockable.
- **Safe/Unsafe:** Safe moves have low reward. Unsafe moves have high reward but are punishable.

---

## 3. Frame Data as Design Language

Every move has three phases (see `animation-for-games` for the animation side):

```
STARTUP → ACTIVE → RECOVERY
```

**Key relationships:**

| Concept | Formula | Why It Matters |
|---------|---------|----------------|
| On-hit advantage | Hitstun - Recovery | Positive = you can act first after hitting |
| On-block advantage | Blockstun - Recovery | Negative = you're at risk after being blocked |
| Combo link window | Hitstun - Next move's startup | Must be > 0 for a link to work |
| Punish window | Attacker's recovery - Defender's fastest move startup | Must be > 0 for a punish |

**Design Rules:**
1. **Light attacks:** Fast startup (3-5f), small reward (30-40 dmg), safe on block (-1 to -3)
2. **Heavy attacks:** Slow startup (12-16f), big reward (100-130 dmg), unsafe on block (-6 to -10)
3. **Special moves:** Variable. Define risk/reward per move. Anti-air DP should be high risk (very unsafe) + high reward (invincible, launcher).
4. **Recovery ≥ Startup** — Non-negotiable. If recovery is shorter than startup, the move is free (no commitment).

---

## 4. Meter/Resource Design

**Design Spectrum:**

| System | Build Method | Spend Options | Design Goal |
|--------|-------------|---------------|-------------|
| Traditional meter (SF) | Land/take hits | EX moves, supers | Reward consistent play |
| Rage/Desperation (Tekken) | Take damage | Rage art (comeback) | Rubber-band / tension |
| Tension (Guilty Gear) | Move forward, attack | Roman Cancel, supers | Reward aggression |
| Ember (Ashfall) | Land hits (attacker > defender), decays without action | EX, cancel, ignition, reversal | Reward engagement, punish passivity |

**Key Design Questions:**
1. Does the meter reward the winning or losing player? (Comeback vs snowball)
2. Can both players see the meter? (Information symmetry)
3. Does meter decay? (Use-it-or-lose-it pressure)
4. How many spend options? (Fewer = clearer decisions)

**Ashfall's Ember answers:** Rewards the attacker more but gives the defender something (prevents shutout). Both players can see it AND feel it (stage reacts). Decays after 3 seconds of no action (forces engagement). Four spend options (EX, cancel, ignition, reversal) — each serves a distinct purpose.

---

## 5. Combo System Design

**Three combo types, from easy to hard:**

1. **Chains/Target Combos:** Press buttons in sequence during cancel windows. Easy execution. Design-time combos (you define which buttons chain).
2. **Links:** Land a move, wait for hitstun to create advantage, input next move during the advantage window. Harder execution. Emergent combos (frame data creates them).
3. **Cancels:** Interrupt recovery of a normal into a special move. Medium execution. Bridges normals into specials.

**Proration (Damage Scaling):**

Without proration, optimal play is a single long combo that kills in one touch. With proration, long combos deal diminishing damage, keeping rounds competitive.

**Recommended proration curve:**
- Hits 1-2: 100% damage
- Hit 3: 80%
- Hit 4: 70%
- Hit 5: 60%
- Hit 6+: 50% → 40% floor

**Juggle limit:** Cap airborne hits (3-4 max) to prevent infinite juggles. Force a knockdown after the limit.

**Max combo damage target:** 30-45% of max HP. This means every round has 2-3 "real" interactions minimum. One-touch-kills are anti-fun for both players.

---

## 6. Deterministic Simulation (Technical Design Requirement)

Fighting games MUST be deterministic: given the same inputs on the same frame, the game state must be identical. This is non-negotiable for:
- Replay systems (record inputs, replay produces identical match)
- Rollback netcode (rewind to known state, replay with corrected inputs)
- Training mode frame stepping

**Requirements:**
- Fixed timestep (60 FPS, no variable delta in gameplay code)
- No `randf()` — use seeded RNG for any randomness
- No floating-point in gameplay logic (use integers or fixed-point)
- State must be serializable (for rollback snapshots)
- Input buffer is part of game state

---

## 7. Character Archetype Vocabulary

| Archetype | Strengths | Weaknesses | Examples |
|-----------|-----------|------------|----------|
| **Shoto/All-Rounder** | Good at everything, no critical gaps | No dominant strength | Ryu, Sol, Jin |
| **Rushdown** | Close-range pressure, fast moves, mixups | Low range, committal approach | Cammy, Millia, Hwoarang |
| **Zoner** | Long-range control, projectiles, space denial | Weak up close, slow moves | Dhalsim, Axl, Samus |
| **Grappler** | High damage, command throws, armor | Slow, poor approach, read-dependent | Zangief, Potemkin, King |
| **Setplay** | Oki pressure, traps, planned sequences | Requires knockdown to start, volatile | Menat, Zato, Ibuki |
| **Balanced** | Above-average in 2-3 areas, viable at all ranges | Master of none | Kael (Ashfall), Ky, Kazuya |

**Design Rule:** Each character's archetype should be obvious within 10 seconds of play. If a character's identity requires reading a guide, the design failed.

---

## 8. Input Motion Design

**Motion complexity communicates move power:**

| Motion | Complexity | Typical Use |
|--------|-----------|-------------|
| 236 (QCF) | Low | Projectiles, basic specials |
| 214 (QCB) | Low | Retreating specials, defensive tools |
| 623 (DP) | Medium | Anti-air, reversals (high reward justifies harder input) |
| 41236 (HCF) | Medium-High | Command throws, powerful specials |
| 236236 (Double QCF) | High | Super/Ignition moves (power justifies complexity) |
| 360 (SPD) | Very High | Grappler command throws (reserved for specialists) |

**Leniency rules (for accessibility):**
- Accept diagonal shortcuts (26 counts as 236)
- Input buffer: 6-10 frames (100-167ms)
- Priority: more complex motion wins when inputs overlap
- No negative edge (button press only, not release)

---

## Anti-Patterns

1. **Touch-of-death combos** — One opening = death. Players feel cheated. Cap combo damage at 45% max.
2. **Unpunishable moves** — If a move is safe on block, safe on whiff, and deals good damage, it dominates. Every powerful move needs a weakness.
3. **Input reading AI** — AI that reacts to button presses before animation appears is cheating. React to visual information only.
4. **Identical characters** — Two characters with the same normals and slightly different specials aren't "balanced," they're boring.
5. **No reversal option** — If a player has no defensive escape from pressure (no DP, no burst, no pushback), the game feels oppressive.
6. **Floaty jumps** — Long airtime removes the commitment from jumping. Jumps should be fast arcs with clear landing vulnerability.
