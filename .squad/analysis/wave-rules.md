# Wave Composition Design Rules

> Canonical rules for authoring enemy waves in `src/data/levels.js`.  
> Author: Tarkin (Enemy/Content Dev)  
> Date: 2025-06-04  
> See also: `encounter-pacing.md` for Level 1 pacing curve.

---

## 1. Solo Introduction Rule

**Never introduce a new enemy type alongside other types.**

When a type appears for the first time in the game, the player must fight it alone (or with only that same type) so they can learn its tells, timing, and threat level without distraction.

- ✅ Wave of 2 tough enemies (first tough appearance)
- ❌ Wave of 3 normals + 1 tough (tough mixed in before player has seen it solo)

**Exception for Level 1:** The tough variant in Wave 3 is acceptable because (a) it shares the same moveset as normal and differs only in stats, and (b) the red color makes it visually distinct. Truly new *behaviors* (ranged, charging, shielded) must always get a solo intro wave.

---

## 2. Mix Melee Types for Variety

Once a type has been introduced, mix it with other known types to create varied encounters. Homogeneous waves (all-normal, all-tough) feel flat after the intro phase.

Guidelines:
- After both normal and tough are introduced, waves should contain a mix.
- Vary the ratio to control difficulty: more toughs = harder.
- Place faster enemies in back ranks and slower ones up front to create natural pacing as they approach the player at different speeds.

---

## 3. On-Screen Enemy Cap

**Maximum 6 enemies alive on screen at any time.**

The attack throttle (max 2 simultaneous attackers) keeps combat readable, but more than 6 bodies creates visual clutter and makes the circling behavior look chaotic rather than menacing.

Enforcement:
- Per-wave spawn counts must not exceed 6.
- If a level needs more than 6 enemies in a sequence, split into sub-waves with a brief gap (see Rule 5).
- WaveManager should track alive-enemy count and delay spawns if the cap would be exceeded.

---

## 4. Minimum Spawn Gap

**At least 2 seconds between wave activations.**

Back-to-back spawns deny the player any sense of progress and can cause enemies to stack on top of each other visually.

Implementation:
- `triggerX` values should be spaced so that at normal walk speed (~200 px/s), the player needs ≥2 seconds of walking to reach the next trigger.
- Minimum `triggerX` gap: **400 px** (200 px/s × 2 s).
- WaveManager may also enforce a cooldown timer as a safety net.

---

## 5. Breather Walk Between Waves

**The player must have a clear, enemy-free path forward between waves.**

After a wave is cleared, the camera unlock + forward walk serves as a tension release. This rhythm (fight → breathe → fight) is critical to beat 'em up feel.

Guidelines:
- Breather duration: **2–3 seconds** of free movement (400–600 px of walking space).
- No enemies should be visible during the breather — spawn positions for the next wave should be off-screen right.
- Optional: place pickups (health, score items) in the breather zone as a reward for clearing the wave.
- The final wave in a level should have a longer breather (3–5 seconds) before the victory screen.

---

## 6. Spawn Positioning

Enemies should spawn at world positions that create gameplay interest:

| Pattern | Description | When to use |
|---|---|---|
| **Front spread** | All enemies ahead of player, spread on Y axis | Intro waves, low pressure |
| **Flanking** | Some enemies behind trigger point | After player learns to turn; creates urgency |
| **Pincer** | Enemies on both sides of player | High-difficulty waves, forces quick decisions |
| **Staggered depth** | Enemies at varying X distances | Creates natural approach timing variety |

Rules:
- Y positions should stay within the walkable area (400–600 game units).
- Spread enemies at least 50 px apart on both axes to prevent visual stacking at spawn.
- Place at least one enemy close to trigger so combat starts immediately; place others further back for staggered arrival.

---

## 7. Difficulty Scaling Across Levels

For future levels beyond Level 1:

| Parameter | Level 1 | Level 2 | Level 3+ |
|---|---|---|---|
| Max enemies per wave | 5 | 6 | 6 |
| New type intro | Tough (Wave 3) | TBD | TBD |
| Flanking frequency | 1 wave | Most waves | All waves |
| Breather length | 3 sec | 2 sec | 2 sec |
| Pickup frequency | Generous | Moderate | Sparse |

---

## Quick Checklist for Wave Authors

Before committing a new wave definition in `src/data/levels.js`:

- [ ] New enemy type gets a solo intro wave first?
- [ ] Wave enemy count ≤ 6?
- [ ] triggerX gap from previous wave ≥ 400 px?
- [ ] Breather space between waves (400–600 px)?
- [ ] Y positions within 400–600 range?
- [ ] Enemies spread ≥ 50 px apart?
- [ ] Mix of known types after intros?
- [ ] At least one enemy near trigger for immediate engagement?
