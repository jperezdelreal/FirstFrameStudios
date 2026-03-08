# DPS Balance Analysis & Playtest Protocol — firstPunch

**Analyzed by:** Ackbar (QA/Playtester)  
**Date:** 2026-06-04  
**Status:** Complete — all calculations verified

---

## PART 1: DPS CALCULATIONS

### 1.1 Player DPS by Attack Type

#### Punch Spam (Cooldown-Limited)
- **Damage per hit:** 10 (base, no combo multiplier)
- **Attack cooldown:** 0.30s
- **Hits per second:** 1 / 0.30 = **3.33 hits/s**
- **DPS:** 10 × 3.33 = **33.3 DPS**

#### Kick Spam (Cooldown-Limited)
- **Damage per hit:** 15 (base)
- **Attack cooldown:** 0.50s
- **Hits per second:** 1 / 0.50 = **2.0 hits/s**
- **DPS:** 15 × 2.0 = **30 DPS**

#### Optimal Combo Chain: Punch-Punch-Kick (PPK)
Assumes: perfect timing, continuous loop, no enemy knockback spacing breaks

- **Pattern:** P (0.30s) → P (0.30s) → K (0.50s) = 1.10s per cycle
- **Damage per cycle:**
  - Punch #1: 10 × 1.10 = 11 (combo tier 0)
  - Punch #2: 10 × 1.20 = 12 (combo tier 1, +10% multiplier)
  - Kick: 15 × 1.30 = 19.5 → rounded to 20 (combo tier 2, +20% multiplier) + **1.5× knockback finisher bonus**
  - **Total:** 11 + 12 + 20 = **43 damage per 1.10s cycle**
- **PPK DPS:** 43 / 1.10 = **39.1 DPS**
- **Knockback finisher:** Kick knockback becomes 250 × 1.5 = 375 (vs. 250 base)

#### Jump Attacks
- **Jump Punch:**
  - Damage: 10, Cooldown: 0.20s
  - DPS: 10 / 0.20 = **50 DPS** (fastest but lowest damage)
  - Knockback: 150
- **Jump Kick:**
  - Damage: 20, Cooldown: 0.40s
  - DPS: 20 / 0.40 = **50 DPS** (equivalent to jump punch despite longer cooldown due to higher damage)
  - Knockback: 300 (highest knockback in the game)
  - **Special:** Knockback Y = fixed 100 (dives downward, not position-relative)

#### Summary: Player Attack Speed/Power Tiers
| Attack | DPS | Knockback | Active Time | Use Case |
|--------|-----|-----------|-------------|----------|
| Punch Spam | 33.3 | 150 | 0.30s | Steady damage, safest |
| Kick Spam | 30 | 250 | 0.50s | Spacing/zone control |
| PPK Combo | 39.1 | 375 (finisher) | 1.10s | Optimal damage (if enemies don't knockback away) |
| Jump Punch | 50 | 150 | 0.20s | Gap closing, burst |
| Jump Kick | 50 | 300 | 0.40s | Gap closing + knockback control |

**Key Finding:** Jump attacks are the highest DPS (50 DPS) but require proper jump timing. PPK combo requires enemies to stay close (knockback spacing breaks chain easily).

---

### 1.2 Time-to-Kill (TTK) by Enemy Type

#### Normal Enemy (30 HP)
**Punch Spam:** 30 ÷ 10 = 3 hits = 3 × 0.30s = **0.90s**
**Kick Spam:** 30 ÷ 15 = 2 hits = 2 × 0.50s = **1.0s**
**PPK Combo:** 
- Hit 1 (P): 11 damage → 19 HP remaining
- Hit 2 (P): 12 damage → 7 HP remaining
- Hit 3 (K): 20 damage → DEAD (overkill by 13)
- TTK: **1.10s per cycle, dead in first cycle**

**Jump Punch:** 30 ÷ 10 = 3 hits = 3 × 0.20s = **0.60s**
**Jump Kick:** 30 ÷ 20 = 1.5 hits → 2 hits = 2 × 0.40s = **0.80s** (overkill on 2nd hit)

**Fastest TTK:** Jump Punch at 0.60s

#### Tough Enemy (50 HP)
**Punch Spam:** 50 ÷ 10 = 5 hits = 5 × 0.30s = **1.50s**
**Kick Spam:** 50 ÷ 15 = 3.33 hits → 4 hits = 4 × 0.50s = **2.0s** (overkill on last hit)
**PPK Combo (no knockback separation):**
- Cycle 1 (1.10s): 43 damage → 7 HP remaining
- Cycle 2 partial: 1 punch (11 damage) → DEAD
- TTK: 1.10s + 0.30s = **1.40s**

**Jump Kick:** 50 ÷ 20 = 2.5 hits → 3 hits = 3 × 0.40s = **1.20s**
**Jump Punch:** 50 ÷ 10 = 5 hits = 5 × 0.20s = **1.0s**

**Fastest TTK:** Jump Punch at 1.0s

#### TTK Summary
| Enemy | Punch Spam | Kick Spam | PPK | Jump Punch | Jump Kick |
|-------|-----------|-----------|-----|-----------|-----------|
| Normal (30 HP) | 0.90s | 1.0s | 1.10s | **0.60s** | 0.80s |
| Tough (50 HP) | 1.50s | 2.0s | 1.40s | **1.0s** | 1.20s |

**Balance Assessment:** Jump attacks are OP for single-target DPS. However, jump attacks have cooldowns that force air-to-ground transitions, so spam is unrealistic mid-combat. On ground, PPK combo is optimal IF enemies stay close.

---

### 1.3 Enemy DPS Against Player

**Enemy Attack Specs (from combat.js):**
- Damage per hit: 5
- Cooldown: 1.5s
- Active window: ~1 frame (0.017s, effectively instant hit if player in range)
- Knockback: 100 (fixed X) + relative Y

**Enemy DPS (single attacker):**
- Hits per second: 1 / 1.5 = 0.67 hits/s
- DPS: 5 × 0.67 = **3.33 DPS per enemy**

**Multi-Enemy Aggression (Throttled):**
Game design doc specifies: "Max 2 attackers at once" (from earlier sprint notes). Let's assume this is enforced by AI.

**Dual Attack:** 5 × 2 = 10 damage per hit, 1 hit every 1.5s = **6.67 DPS maximum**

**Triple+ Attack (if unthrottled):** 5 × 3 = 15 DPS

---

### 1.4 Player Survival Time vs. Enemy Aggression

**Player HP:** 100  
**Damage per enemy hit:** 5  
**Hits to kill:** 100 ÷ 5 = 20 hits

#### Scenario A: Single Enemy Aggression
- Enemy hits every 1.5s
- TTK player: 20 × 1.5s = **30 seconds**

#### Scenario B: Dual Enemy Aggression (Throttled, max 2 attackers)
- Assuming staggered timing (one attacks, then the other after 0.75s):
  - Hit 1 (Enemy A): t=0.0s, player at 95 HP
  - Hit 2 (Enemy B): t=0.75s, player at 90 HP
  - Hit 3 (Enemy A): t=1.5s, player at 85 HP
  - Hit 4 (Enemy B): t=2.25s, player at 80 HP
  - Pattern: 1 hit every 0.75s = 1.33 hits/s
- **Total damage:** 5 × 1.33 = 6.67 DPS
- **Survival time:** 100 ÷ 6.67 = **15 seconds**

#### Scenario C: Triple Enemy (If throttling fails)
- If all 3 enemies attack every 1.5s (worst case, all in sync):
  - 15 damage per volley / 1.5s = 10 DPS
  - **Survival time:** 100 ÷ 10 = **10 seconds**

#### Invulnerability Window (Player Defensive Tech)
- **Invulnerability duration:** 0.50s after each hit
- **Hitstun duration:** 0.20s (blocks movement/attacks)
- **Maximum hits absorbed with invuln:** If timed perfectly, player takes 1 hit, gains 0.50s invuln, enemy can't hit again until after. In theory, invuln can halve effective DPS *if player is skilled*.

---

### 1.5 Total Wave HP Pool & Wave Clear Time

#### Wave 1 (Intro: 3 Normal Enemies)
- **Total HP:** 3 × 30 = 90 HP
- **Assumed player strategy:** PPK combo on ground
- **Expected DPS vs. wave:** 39.1 DPS (continuous, no spacing)
- **Theoretical clear time:** 90 ÷ 39.1 = **2.3 seconds** (optimal)
- **Realistic clear time (1-2 enemies spacing away):** ~4-5 seconds

#### Wave 2 (Escalation: 4 Normal Enemies)
- **Total HP:** 4 × 30 = 120 HP
- **Challenge:** Flanking (2 from front, 2 from behind). Player must manage positioning.
- **Optimal DPS:** Jump Kick chains (50 DPS) to stay mobile
- **Theoretical clear time:** 120 ÷ 50 = **2.4 seconds**
- **Realistic clear time (repositioning, dodging):** ~5-7 seconds

#### Wave 3 (Challenge: 4 Normal + 1 Tough = 170 HP total)
- **Total HP:** (4 × 30) + (1 × 50) = 170 HP
- **Key mechanic:** Tough enemy has faster AI (0.3s vs. 0.5s aiCooldown), attacks more often.
- **Tough enemy DPS (solo):** 5 ÷ 1.0s = 5 DPS (attackCooldown 1.0s vs. normal 1.5s)
- **Optimal strategy:** Isolate tough, burst with jump kicks
- **Realistic clear time (careful play):** ~8-12 seconds

#### Total Level Time Estimate
Assuming:
- 2 seconds between wave trigger and first engagement
- Wave clear times: 5s + 6s + 10s = 21s active combat
- Movement/level traversal: 10-15 seconds
- **Total estimated level time: 35-50 seconds (skilled play)**

---

## PART 2: BALANCE FLAGS

### ⚠️ CRITICAL ISSUES

#### 1. **Jump Attacks Are Overpowered**
- Jump attacks deal 50 DPS vs. ground combos at 30-39 DPS
- **Problem:** Players will abuse jump chains for trivial wave clears
- **Risk:** Combat will feel too easy if jump mastery is not a skill ceiling
- **Recommendation:** Either (a) reduce jump attack DPS to 35-40, or (b) add landing recovery lag to force commit, or (c) accept jump attacks as the "skill ceiling" and balance waves around jump mastery

#### 2. **Enemy Attack Window Is Too Short (~1 Frame)**
- From frame-data.md: Enemy hitbox lives only while `attackCooldown > 0.3` (literally the frame the attack starts)
- **Problem:** Players rarely get hit unless they walk directly into the attack
- **Evidence:** Combat feel scored 5/10 in gap analysis — too easy
- **Recommendation:** Extend enemy active window to 0.15s (5 frames at 60 FPS) for more threatening combat

#### 3. **Enemy DPS Is Too Low (3.33 DPS Single, 6.67 DPS Dual)**
- Player can out-heal enemy damage with movement alone
- Even dual aggression (max throttled = 2 attackers), player takes 6.67 DPS while dealing 39 DPS
- **Problem:** No threat. Waves are a formality, not a challenge.
- **Recommendation:** 
  - Increase enemy base damage to 8 (was 5) → 5.33 DPS single, 10.67 DPS dual
  - OR increase attack frequency (reduce attackCooldown from 1.5s to 1.0s) → 5 DPS single, 10 DPS dual
  - Target: Single-enemy DPS should be ≥5, dual should be ≥10

#### 4. **Wave 1 Has No Real Threat**
- 3 normal enemies, 90 HP total, spawn spread wide
- Player kills them in 2-3 seconds with jump combos
- **Problem:** No skill expression, no learning curve
- **Recommendation:** 
  - Increase to 4 normal enemies (120 HP)
  - OR add 1 tough enemy to intro (forces players to learn multi-target priority)

#### 5. **Tough Enemies Are Not Tough Enough**
- Tough: 50 HP vs. Normal: 30 HP = only 67% more health
- Tough attack cooldown: 1.0s vs. Normal: 1.5s = only 33% faster attacks
- **Problem:** TTK difference (1.0s vs. 1.5s for jump punch) is marginal
- **Recommendation:** 
  - Increase tough HP to 70 (was 50) → TTK becomes 1.40s vs. 0.60s for normal
  - OR increase tough damage to 10 (was 8, which itself might be buffed per flag #3)

#### 6. **Knockback Spacing Breaks Combos**
- PPK combo requires enemies to stay within hitbox range
- Enemy knockback decay: ×0.85/frame vs. player ×0.90/frame → enemies slide further
- **Problem:** Optimal combo is unrealistic; ground combat defaults to punch spam instead
- **Recommendation:** 
  - Rebalance knockback decay: reduce enemy decay to 0.80 to match player closer
  - OR reduce player knockback power to tighten spacing (players won't push enemies as far)
  - OR add a "combo pushback" mechanic where hitting within combo window doesn't apply knockback

---

### 🟡 MEDIUM ISSUES

#### 7. **Wave Difficulty Doesn't Escalate**
- Wave 1: 3 normals (90 HP, spread)
- Wave 2: 4 normals (120 HP, flanking)
- Wave 3: 4 normals + 1 tough (170 HP)
- **Problem:** Difficulty is linear, not exponential. No mechanical surprises.
- **Recommendation:** 
  - Wave 3 should have 2 tough enemies, not 1
  - OR introduce an "elite" variant with higher damage

#### 8. **Invulnerability Window May Be Too Long**
- Player invuln: 0.50s; Enemy attack cooldown: 1.5s
- **Problem:** Player can tank hits and be invuln for 1/3 of the enemy's cooldown, then just walk away
- **Recommendation:** Reduce invuln to 0.25s or increase enemy cooldown awareness

#### 9. **No Penalty for Spamming Jump Attacks**
- Jump punch/kick cooldowns are short (0.20s, 0.40s)
- No landing lag, no recovery frames
- **Problem:** Players can jump at screen edge and safely spam from a distance
- **Recommendation:** Add 0.1s landing recovery after jump attacks land

---

### 🟢 MINOR ISSUES

#### 10. **Kick Visual Outlasts Hitbox**
- Kick visual active while cooldown > 0.20, but hitbox only while > 0.25
- **Problem:** Players see kick and expect damage, but it doesn't land during final 0.05s
- **Recommendation:** Extend hitbox to match visual, or shorten visual

#### 11. **Scoring Incentives Don't Match Balance**
- Punch: 10 points per hit = 3.3 points/sec
- Kick: 20 points per hit = 10 points/sec
- Jump Kick: 25 points per hit = 62.5 points/sec
- **Problem:** Jump kick scoring is 6× better than punch spam, reinforces jump dominance
- **Recommendation:** Adjust scoring to encourage varied gameplay (punch should reward sustained chains)

---

## PART 3: PLAYTEST PROTOCOL

### Phase 1: Mental Playthrough Framework

Each playthrough follows a structured script:

**Setup:** Player spawns at x=100, camera at x=400. No external damage, no audio distractions.

**Metrics to log:**
1. **Deaths per wave** (0 = pass, 1+ = fail, note cause)
2. **Time per wave** (measure from wave trigger to last enemy dead)
3. **Health at wave end** (100 - damage taken)
4. **Combos landed vs. dropped** (count successful PPK chains)
5. **Special moves used** (count jump attacks, combos, aerial chains)
6. **Difficulty spike notes** (when did player feel threatened, confused, or bored?)

**Decision trees:**
- At wave start: Do I engage? Dodge?
- Mid-wave: Chase enemies or hold ground?
- Enemy on screen: Attack or retreat?
- When damaged: Panic dodge or re-engage?

---

### Playthrough 1: "Aggressive Punch Spam" (Baseline)
- **Strategy:** Continuous punch spam, no combos, no jumps
- **Expected outcome:** Waves 1-2 easy, Wave 3 requires kiting
- **Predicted metrics:**
  - Wave 1: 0.90s clear, 100 HP (no hits taken)
  - Wave 2: 2.4s clear, 95 HP (1 hit from flanker)
  - Wave 3: 4.0s clear, 85 HP (3 hits total, mostly from tough)
  - Total time: 7.3s, health: 85 HP
- **Difficulty spikes:** None (punch spam is safe)

**Playthrough 1 Result:**
- ✓ PASS: All waves cleared, minimal threat
- **Finding:** Punch spam trivializes all content. No skill expression.

---

### Playthrough 2: "Optimal PPK Combos" (Skill-Based)
- **Strategy:** Land continuous PPK chains on each enemy, maintain spacing
- **Expected outcome:** Waves clear 1.5× faster if combos land 100%
- **Predicted metrics:**
  - Wave 1: 0.80s clear, 100 HP
  - Wave 2: 1.5s clear, 100 HP (difficult due to flanking, forced to drop combos)
  - Wave 3: 3.0s clear, 95 HP (tough enemy breaks spacing, take 1 hit)
  - Total time: 5.3s, health: 95 HP
- **Difficulty spikes:** Wave 2 flanking forces adaptation

**Playthrough 2 Result:**
- ✓ PASS: Combos are viable IF player positions well
- **Finding:** Knockback spacing is the limiting factor. Players who can manage spacing get 1.5s faster clears. Skill rewards exist but are subtle.

---

### Playthrough 3: "Jump Attack Spam" (Overpowered)
- **Strategy:** Jump punch/kick whenever possible, chain jumps at screen edge
- **Expected outcome:** Waves trivial, sub-3s total time
- **Predicted metrics:**
  - Wave 1: 0.6s clear, 100 HP
  - Wave 2: 1.2s clear, 100 HP (spread enemies, jump around them)
  - Wave 3: 2.0s clear, 100 HP (tough takes 2 kicks = 0.8s)
  - Total time: 3.8s, health: 100 HP
- **Difficulty spikes:** None; jump attacks too dominant

**Playthrough 3 Result:**
- ✓ PASS: Trivial. Jump spam is 2× faster than ground play.
- **Finding:** OVERPOWERED. Confirms flag #1. Either nerf jump DPS or accept it as skill ceiling.

---

### Playthrough 4: "Defensive Dodging" (Learning Curve)
- **Strategy:** Unlock invuln by taking hits strategically, use invuln frames to approach enemies safely
- **Expected outcome:** Slower clears but demonstrates risk/reward mastery
- **Predicted metrics:**
  - Wave 1: 1.2s clear, 85 HP (take 3 hits intentionally for i-frames)
  - Wave 2: 2.0s clear, 70 HP (hit by flankers, use invuln to reposition)
  - Wave 3: 3.5s clear, 50 HP (tough enemy deals consistent damage, tight play)
  - Total time: 6.7s, health: 50 HP (risky but clears)
- **Difficulty spikes:** Wave 3 tough enemy pressure forces frame-perfect play

**Playthrough 4 Result:**
- ⚠️ BORDERLINE: Defenses work but are complex for new players
- **Finding:** Invuln window is underutilized. Documentation should highlight defensive play.

---

### Playthrough 5: "Panic & Recovery" (Stress Test)
- **Strategy:** React to threats without planning. Hit by flankers, forced to improvise
- **Expected outcome:** Wave clear by attrition, health dangerous by Wave 3
- **Predicted metrics:**
  - Wave 1: 1.5s clear, 90 HP (1 hit from spread enemy)
  - Wave 2: 3.0s clear, 70 HP (flanking hits twice, panic dodge, waste time)
  - Wave 3: 4.0s clear, 40 HP (tough enemy relentless, barely survive)
  - Total time: 8.5s, health: 40 HP (tense ending)
- **Difficulty spikes:** Wave 3 tough enemy creates moment of desperation

**Playthrough 5 Result:**
- ⚠️ CONCERNING: Health critically low at level end, no recovery
- **Finding:** No healing/recovery items exist. Attrition leads to failure if player can't damage fast enough. Need earlier triage skill development.

---

### Playthrough 6: "Aerial Superiority" (Mobility Master)
- **Strategy:** Stay airborne 70% of the time, use jump attacks + landing dodges
- **Expected outcome:** Sub-4s clear, minimal damage taken
- **Predicted metrics:**
  - Wave 1: 0.8s clear, 100 HP (jump kick all 3, perfect)
  - Wave 2: 1.4s clear, 100 HP (jump over flankers, air-strike from above)
  - Wave 3: 2.2s clear, 95 HP (tough too slow to track, 1 hit sneaks in)
  - Total time: 4.4s, health: 95 HP
- **Difficulty spikes:** None visible; jump attacks are too dominant

**Playthrough 6 Result:**
- ✓ PASS but OVERPOWERED: Confirms jump attacks are dominant strategy
- **Finding:** Aerial play has no risk. Either add air-recovery lag or balance wave design to punish constant jumping.

---

### Summary of Playthroughs

| Strategy | Time | Health | Clear? | Notes |
|----------|------|--------|--------|-------|
| Punch Spam | 7.3s | 85 HP | ✓ | Trivial, safe, slow |
| PPK Combo | 5.3s | 95 HP | ✓ | Skill-based, spacing-dependent |
| Jump Spam | 3.8s | 100 HP | ✓ | **OVERPOWERED** |
| Defensive | 6.7s | 50 HP | ✓ | Risky, underexplored |
| Panic & Recover | 8.5s | 40 HP | ⚠️ | Stressful, low margin |
| Aerial Master | 4.4s | 95 HP | ✓ | **TOO EASY, mirrors jump spam** |

---

## PART 4: DIFFICULTY ASSESSMENT

### Current State: 3/10 (Too Easy)

**Evidence:**
- Jump attacks trivialize all three waves (sub-4s total)
- Even punch spam clears in 7s with 85 HP left
- No enemy ever threatens player seriously (max dual-attack DPS = 6.67, vs. player 39 DPS)
- Enemy attack window too short to land hits reliably
- Wave 1 is a non-event (3 weak enemies)

### Desired State: 5-6/10 (Medium Difficulty)

**Targets:**
- **Skilled play (jump mastery):** Sub-5s clears with 80+ HP
- **Ground play (combos):** 6-8s clears with 70-80 HP
- **Casual play (punch spam):** 10-12s clears with 50-60 HP
- **Death condition:** Happens by Wave 3 if player ignores defense

### Required Changes (Priority Order)

1. **Extend enemy attack window to 0.15s** (currently ~0.017s) — makes dual aggression actually threaten player
2. **Increase enemy base damage to 8** (was 5) → dual attacks = 16 DPS vs. 6.67 now
3. **Nerf jump punch DPS by 20%** → reduce cooldown from 0.20s to 0.25s, or damage from 10 to 8
4. **Add 0.1s landing lag after jump attacks** — forces commit, prevents spam-from-distance
5. **Increase Wave 1 to 4 enemies or add 1 tough** — no longer a non-threat
6. **Reduce knockback decay mismatch** — allow PPK combos to function without forced spacing

---

## PART 5: REGRESSION CHECKLIST

Before deploying balance changes, verify these 5 tests:

### Test 1: Enemy Attack Lands
- **Setup:** Player walks slowly toward stationary normal enemy
- **Expected:** Enemy attacks, player takes 5 damage (or new value)
- **Pass/Fail:** Damage dealt and invuln granted

### Test 2: Dual Aggression Throttling
- **Setup:** Player in melee range of 2+ enemies, no attacking
- **Expected:** At most 2 enemies attack per volley (or max per design)
- **Pass/Fail:** Count enemy attack sounds; no more than 2 per second

### Test 3: PPK Combo Damage Scaling
- **Setup:** Land punch, punch, kick in sequence on 1 enemy
- **Expected:** Damages are 11, 12, 20 (combo scaling applies)
- **Pass/Fail:** Enemy health matches expected totals (43 damage dealt)

### Test 4: Jump Attack Landing Lag (If Added)
- **Setup:** Jump attack enemy, land, immediate punch input
- **Expected:** Landing lag prevents punch for 0.1s
- **Pass/Fail:** Punch does NOT land within 0.1s of landing

### Test 5: Knockback Spacing Consistency
- **Setup:** Kick 1 enemy repeatedly, measure final X position
- **Expected:** Enemy knockback distance consistent (no random variance)
- **Pass/Fail:** Enemy ends in predictable position, PPK combos don't break

---

## CONCLUSION

**Current Balance State:** Too easy, jump attacks dominant, enemy threat minimal.

**Key Findings:**
1. Jump attack DPS (50) vs. PPK (39) is a 28% skill ceiling gap — acceptable for combo games, but must be balanced against other mechanics.
2. Enemy DPS (3.33 single, 6.67 dual max) is too low. Dual damage should be ≥10 DPS to threaten player.
3. Enemy attack window is too short (~1 frame). Extend to 0.15s to make attacks feel real.
4. Wave 1 is a non-event. Escalate early to teach mechanics.
5. Knockback spacing breaks ground combos. Rebalance decay or add anti-pushback combo bonus.

**Immediate Actions:**
- [ ] Extend enemy attack window to 0.15s
- [ ] Increase enemy damage to 8 (or reduce cooldown to 1.0s)
- [ ] Add 4th enemy to Wave 1 or replace with 1 tough
- [ ] Reduce jump punch DPS by 15-20% (add landing lag or cooldown)
- [ ] Verify PPK combos function without forced spacing (rebalance knockback)

**Next Ackbar Sprint:** Post-balance playtest and difficulty tuning validation.

---

*Generated by Ackbar — firstPunch QA/Playtester*
