---
name: "fighting-game-design"
description: "1v1 fighting game design — frame data, combo theory, RPS triangle, meter systems"
domain: "game-design"
confidence: "medium"
source: "Ashfall GDD (Yoda, 2025) + cross-genre research"
has_reference: true
---

## Context
Design patterns specific to 1v1 fighters. Frame data as law, RPS triangle, input motions, combo theory, and meta-game of reads. Separates fighters from other action genres.

## Core Patterns

- **Core loop:** Neutral (footsies) → Pressure (advantage) → Combo/Punish → Reset → Neutral
- **RPS triangle:** Attack beats Throw, Throw beats Block, Block beats Attack. Every option must lose to something
- **Frame data relationships:** On-hit advantage = Hitstun - Recovery. On-block advantage = Blockstun - Recovery. Recovery ≥ Startup (non-negotiable)
- **Meter design spectrum:** Traditional (land/take hits → EX/super), Rage (take damage → comeback), Tension (aggression → Roman Cancel)
- **Proration curve:** Hits 1-2 = 100%, Hit 3 = 80%, Hit 4 = 70%, Hit 5 = 60%, Hit 6+ = 50-40% floor. Max combo = 30-45% HP
- **Deterministic simulation:** Fixed 60fps timestep, no `randf()`, no floats in gameplay, state serializable for rollback netcode

## Key Examples

**Frame data targets (60fps):**
- Light: 3-5f startup, safe on block (-1 to -3), 30-40 dmg
- Heavy: 12-16f startup, unsafe (-6 to -10), 100-130 dmg
- Special: variable risk/reward per move

**Character archetypes:**
- **Shoto** — Good at everything, no critical gaps
- **Rushdown** — Close pressure, fast, weak range
- **Zoner** — Long-range control, weak up close
- **Grappler** — High damage throws, slow approach

**Input motion complexity = move power:** QCF (236) basic, DP (623) anti-air, Double QCF (236236) super, 360 grappler exclusive

## Anti-Patterns

- **Touch-of-death combos** — One opening = death. Cap at 45% max
- **Unpunishable moves** — Every powerful move needs weakness
- **Input reading AI** — React to visual info only, not button presses
- **No reversal option** — Players need defensive escape from pressure
