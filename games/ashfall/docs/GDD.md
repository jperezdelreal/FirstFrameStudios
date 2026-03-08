# Ashfall — Game Design Document

**Version:** 1.0  
**Author:** Yoda (Game Designer / Vision Keeper)  
**Engine:** Godot 4  
**Genre:** 1v1 Fighting Game  
**Platform:** PC (Keyboard + Gamepad)  
**Status:** Pre-Production  

---

## Table of Contents

1. [Vision & Pillars](#1-vision--pillars)
2. [Core Mechanics](#2-core-mechanics)
3. [Character Design](#3-character-design)
4. [Stage Design](#4-stage-design)
5. [Game Flow](#5-game-flow)
6. [Controls](#6-controls)
7. [AI Opponent](#7-ai-opponent)
8. [Art Direction](#8-art-direction)
9. [Audio Direction](#9-audio-direction)
10. [Scope Boundary](#10-scope-boundary)

---

## 1. Vision & Pillars

### The Pitch

**Ashfall is a 1v1 fighting game where every hit fuels the fire.** Combat generates Ember — a visible, shared resource that builds on screen as the fight intensifies. Aggression is rewarded: land hits, build Ember, unlock devastating Ignition moves. But Ember is volatile. Your opponent can steal it, redirect it, or let you burn yourself out. The result is fights that escalate from cautious footsies into volcanic eruptions of power — and every round tells a story.

### The Hook: The Ember System

What Street Fighter did with meter and Tekken did with rage, Ashfall does with **Ember** — a resource that *both players can see and fight over*. Ember isn't hidden in a UI bar. It manifests visually: the stage darkens, particle embers float upward, characters glow hotter. The fight itself becomes the meter.

This solves the biggest problem in fighting games for new players: **"I don't understand what's happening."** In Ashfall, you can *see* the momentum shift. When the screen is on fire, someone is about to do something devastating. Even spectators who've never played a fighter understand: *things are about to explode*.

### The Four Pillars

**Pillar 1: Every Hit Feeds the Fire**  
Combat generates Ember. Landed attacks, blocked specials, and aggressive play all build Ember for both players (attacker builds faster). This creates positive feedback: action rewards action. Turtling starves the fire. The game mechanically pushes toward exciting exchanges.

**Pillar 2: Readable Combat**  
Every attack has clear anticipation frames. Poses read as silhouettes. Hit reactions are dramatic — you know who's winning at a glance. This is a fighting game you can *watch* and understand without frame data spreadsheets. Spectator clarity is a design constraint, not a nice-to-have.

**Pillar 3: Commitment and Consequence**  
Heavy attacks have real recovery. Whiffed specials are punishable. Ignition moves are powerful but cost your entire Ember stock — use them wrong and you've reset your momentum to zero. Every decision has weight. No option-select safety nets that erase player choices.

**Pillar 4: The 10-Second Identity Test**  
Each character must feel fundamentally different within 10 seconds of play. Not just different moves — different *rhythms*. Kael's pacing is deliberate and controlled. Rhena's is explosive and relentless. A player should know which character they're fighting in the first exchange, blindfolded.

### Design Principles (Binding)

1. **Player Hands First** — If a mechanic is technically correct but feels bad to input, fix the feel, not the player. Input latency budget: ≤ 100ms total from press to screen response.
2. **Frame Data Is Law** — Every move has documented startup, active, and recovery frames. No exceptions. If it doesn't have frame data, it doesn't ship.
3. **Asymmetric Balance** — Characters are not balanced by making them similar. They're balanced by making their *strategies* equally viable. Kael can zone; Rhena can rush. Neither strategy is strictly dominant.
4. **Teach Through Play** — No text tutorials. The player learns by doing. Arcade mode escalates opponent difficulty to naturally teach mechanics.

---

## 2. Core Mechanics

### 2.1 Health System

- **Health per round:** 1000 HP
- **Display:** Horizontal health bar, top of screen, drains left-to-right (P1) and right-to-left (P2)
- **Damage display:** Recent damage shown as a lighter "ghost" section that fades over 1 second (shows how much that combo did)
- **Chip damage:** Blocked special moves deal 25% of their normal damage. Normal moves deal 0 chip. This rewards using meter for offense.
- **No health regeneration.** What you lose, you lose.

### 2.2 Round System

- **Best of 3 rounds** (first to 2 round wins)
- **Round timer:** 60 seconds per round
- **Time-out:** Player with more HP remaining wins the round. If HP is equal, the round is a draw (both lose a round — forces aggression)
- **Round transition:** 2-second pause → "Round X" announcement → 1-second countdown → "FIGHT"
- **Match point:** When either player is one round from victory, the announcer calls "FINAL ROUND" and stage Ember effects intensify

### 2.3 The Ember System (Core Resource)

Ember is Ashfall's signature mechanic. It replaces traditional "super meter" with a system that is visual, shared, and fight-defining.

**Ember Generation:**

| Action | Ember Gained (Attacker) | Ember Gained (Defender) |
|--------|------------------------|------------------------|
| Light attack lands | +5 | +2 |
| Medium attack lands | +8 | +3 |
| Heavy attack lands | +12 | +5 |
| Special move lands | +15 | +6 |
| Attack blocked | +3 | +4 |
| Whiffed attack (miss) | +0 | +0 |
| Throw lands | +10 | +4 |
| Taking damage | — | +1 per 50 HP lost |

- **Maximum Ember:** 100 per player (tracked individually)
- **Ember decay:** If no combat action occurs for 3 seconds, both players' Ember decays at 5/second. Keeps pressure on.
- **Visual escalation:** At 0 Ember, the stage is normal. At 50+ (either player), embers begin floating upward. At 75+, the stage lighting shifts warm. At 100, the character glows with visible heat distortion.

**Ember Spending:**

| Action | Ember Cost | Effect |
|--------|-----------|--------|
| EX Special | 25 | Enhanced version of a special move (more damage, better properties) |
| Ember Cancel | 25 | Cancel recovery frames of a normal into a special (combo extension) |
| Ignition Move | 50 | Character-specific cinematic super move |
| Burnout Reversal | 50 | Defensive burst — pushes opponent away on block or during pressure. Costs 50 to prevent spam. |

**Design Intent:** Ember rewards engagement. Aggressive play builds it faster, but the defender always gains *some* Ember — preventing total shutouts. The decay mechanic means you can't just bank it and turtle. Use it or lose it.

### 2.4 Movement

**Ground Movement:**
- **Walk forward:** Standard speed. Advancing walk.
- **Walk backward:** 85% of forward walk speed. Slight speed penalty for retreating.
- **Crouch:** Hold Down. Reduces hurtbox height by ~40%. Enables crouching attacks and low blocks.
- **Dash forward:** Double-tap Forward (or dedicated dash button). Quick burst of forward movement. 16 frames total, invulnerable frames 3-5 (3 frames of i-frames at dash start).
- **Backdash:** Double-tap Back. Evasive movement. 20 frames total, invulnerable frames 1-8 (longer i-frames but slower overall — defensive tool).

**Jumping:**
- **Neutral jump:** Straight up. 36 frames airtime. Used for avoiding lows and neutral spacing.
- **Forward jump:** Diagonal arc forward. 40 frames airtime. Approach tool.
- **Backward jump:** Diagonal arc backward. 40 frames airtime. Escape tool.
- **No double jump.** No air dash. Grounded, footsies-focused game. Jumps are commitments.

**Movement Constants (tunable):**

| Parameter | Value | Notes |
|-----------|-------|-------|
| Walk speed (forward) | 200 px/sec | ~3 seconds to cross stage |
| Walk speed (backward) | 170 px/sec | Retreat penalty |
| Dash distance | 120 px | Roughly 1/5 of stage |
| Dash duration | 16 frames | 267ms |
| Backdash distance | 100 px | Shorter than forward dash |
| Jump height | 150 px | Modest — this isn't an air game |
| Jump forward distance | 180 px | Covers good ground |
| Gravity | 900 px/sec² | Snappy arc, not floaty |

### 2.5 Attack System

**Normal Attacks — 6-Button Layout:**

| Button | Standing | Crouching | Jumping |
|--------|----------|-----------|---------|
| Light Punch (LP) | Quick jab, 4f startup | Low poke, 5f startup | Air jab, 4f startup |
| Medium Punch (MP) | Straight punch, 7f startup | Body blow, 8f startup | Angled punch, 7f startup |
| Heavy Punch (HP) | Overhand smash, 12f startup | Uppercut, 14f startup | Diving fist, 10f startup |
| Light Kick (LK) | Shin kick, 5f startup | Low kick, 4f startup | Knee, 5f startup |
| Medium Kick (MK) | Side kick, 8f startup | Sweep (knockdown), 9f startup | Angled kick, 8f startup |
| Heavy Kick (HK) | Roundhouse, 14f startup | Slide (knockdown), 12f startup | Drop kick, 12f startup |

**Attack Properties:**

| Property | Light | Medium | Heavy |
|----------|-------|--------|-------|
| Startup | 4-5f | 7-9f | 12-14f |
| Active | 2-3f | 3-4f | 4-6f |
| Recovery | 6-8f | 10-14f | 16-22f |
| Damage | 30-40 | 60-80 | 100-130 |
| Hitstun | 12f | 16f | 22f |
| Blockstun | 8f | 12f | 16f |
| On-hit advantage | +4f | +3f | +2f |
| On-block advantage | -2f | -4f | -8f |

**Key Frame Data Rules:**
- **Recovery ≥ Startup** — attacks are commitments, not free pokes
- **Hitstun > Startup (of lighter move)** — ensures combo links work: landing a medium gives enough hitstun to link into a light
- **Negative on block (heavies)** — blocked heavy attacks are punishable. Risk/reward.
- **Positive on hit** — landing attacks gives frame advantage for continued pressure

### 2.6 Blocking

- **Standing block:** Hold Back. Blocks mid and high attacks. Loses to lows.
- **Crouching block:** Hold Down-Back. Blocks low and mid attacks. Loses to overheads (jumping attacks, command overheads).
- **No dedicated block button.** Hold-back blocking is the standard. This is a design choice: blocking requires awareness of spacing (you must hold *away* from opponent), not just pressing a button.
- **Block pushback:** Blocked attacks push the defender backward slightly (4-12 px depending on attack strength). Prevents infinite pressure at point-blank.
- **Guard break:** Does not exist in MVP. No guard meter. Blocking is reliable but costs positioning (pushback) and initiative (you're not attacking).

### 2.7 Throws

- **Input:** LP + LK simultaneously (close range)
- **Range:** Must be within 40px of opponent (roughly touching)
- **Startup:** 5 frames. Active: 2 frames. Cannot be blocked.
- **Throw tech (escape):** Input LP + LK within 7 frames of being thrown. Both players reset to neutral. Prevents throw from being a guaranteed punish.
- **Throw damage:** 120 base damage. Does not scale (throws are never part of combos).
- **Purpose:** Throws beat blocking. Blocking beats attacks. Attacks beat throw attempts. This is the core RPS (rock-paper-scissors) triangle of fighting games.

### 2.8 Combo System

**Target Combos (Chains):**
- Light → Medium → Heavy is a universal 3-hit chain. Input timing window: 12 frames between each button.
- Each character has 2-3 unique target combos beyond the universal chain.

**Links:**
- After a normal attack hits, if the remaining hitstun exceeds the startup of the next normal, a *link* is possible.
- Example: Standing MP (16f hitstun) → Standing LP (4f startup) = 12-frame link window.
- Links require more precise timing than chains. They are the skill ceiling.

**Cancels:**
- Certain normal attacks can be *canceled* into special moves during their active or early recovery frames.
- Cancel window: frames 1-6 of recovery (varies by move).
- Ember Cancel (25 Ember): Cancel recovery into ANY special move. Extends combos beyond normal limits.

**Combo Scaling (Damage Proration):**

| Hit # in Combo | Damage Multiplier |
|----------------|-------------------|
| 1 | 100% |
| 2 | 100% |
| 3 | 80% |
| 4 | 70% |
| 5 | 60% |
| 6 | 50% |
| 7+ | 40% (floor) |

**Why:** Prevents touch-of-death combos. Long combos are flashy but don't delete health bars. Keeps rounds competitive. Max practical combo damage target: ~350 (35% HP) without Ember, ~450 (45% HP) with full Ember spend.

**Juggle System:**
- Launcher moves (character-specific) send the opponent airborne.
- Airborne opponents can be hit with a limited juggle (max 3 juggle hits before forced knockdown).
- Juggle hits use the same proration table.

### 2.9 Knockdown & Wake-Up

- **Hard knockdown:** Caused by sweeps, throws, and certain specials. Opponent is grounded for 24 frames before auto-rising.
- **Soft knockdown:** Caused by juggle enders. Opponent recovers 8 frames faster (16-frame down time).
- **Quick rise:** Input any button during knockdown to rise 8 frames early. Adds a decision layer (quick rise to avoid setplay, or stay down to reset spacing).
- **Wake-up options:** On wake-up, the player can block, attack, throw, backdash, or use a reversal special. No guaranteed setups that are inescapable.

### 2.10 Special Move Inputs

**Notation (NumPad Convention):**
```
7 8 9      ↖ ↑ ↗
4 5 6  =   ← N →   (assumes facing right)
1 2 3      ↙ ↓ ↘
```

**Motion Types Used in Ashfall:**

| Motion | Notation | Common Name | Example |
|--------|----------|-------------|---------|
| Quarter-circle forward | 236 + Button | Fireball motion | ↓ ↘ → + Punch |
| Quarter-circle back | 214 + Button | Reverse fireball | ↓ ↙ ← + Punch |
| Dragon punch | 623 + Button | Shoryuken motion | → ↓ ↘ + Punch |
| Half-circle forward | 41236 + Button | Half-circle | ← ↙ ↓ ↘ → + Punch |
| Half-circle back | 63214 + Button | Reverse half-circle | → ↘ ↓ ↙ ← + Punch |
| Double quarter-circle | 236236 + Button | Super motion | ↓ ↘ → ↓ ↘ → + Punch |

**Input Leniency:**
- **Input buffer window:** 8 frames (133ms). Inputs pressed within 8 frames of being valid are consumed.
- **Motion leniency:** Diagonal inputs count for both cardinal directions. 2369 is accepted as 236. Shortcut: 26 is accepted as 236 (diagonal skip).
- **Negative edge:** NOT used. Button press only, not release. Keeps inputs clean for newcomers.
- **Priority system:** If multiple specials share a motion prefix, the more complex motion takes priority (623 beats 236 if both are valid with the same button).

---

## 3. Character Design

### Design Philosophy

Two characters. Two completely different answers to the same game. Both have access to the universal mechanics (throws, dashes, Ember system), but their normals, specials, and optimal strategies diverge sharply.

**The Archetype Pairing:** Balanced All-Rounder vs. Explosive Rushdown. This is the classic pairing because it naturally teaches fighting game fundamentals — spacing and patience (Kael) versus pressure and reads (Rhena). A new player can pick either and have a viable, complete toolkit.

---

### 3.1 KAEL — The Cinder Monk

**Archetype:** Balanced / Shoto  
**Personality:** Disciplined, stoic, controlled. Kael is a martial artist who treats combat as meditation. He doesn't waste movement. Every strike is placed, not thrown. His fire burns steady — not explosive, but unrelenting.  
**Visual Identity:** Lean, athletic build. Wrapped forearms. Simple gi-style attire with ember-colored accents. Hair tied back. Calm expression even mid-combat. Silhouette reads as "focused fighter."  
**Rhythm:** Methodical. Kael's gameplan is spacing — keeping the opponent at mid-range where his pokes and projectile control space. He wins by out-thinking, not out-rushing.

**Stats:**
- Walk speed: 200 px/sec (average)
- Dash distance: 120 px (average)
- Health: 1000 (standard)
- Damage output: Average per-hit, above average in optimized combos

**Normal Highlights:**
- Standing MP (Straight Ember Palm): Excellent mid-range poke. 7f startup, great horizontal reach. His bread-and-butter spacing tool.
- Crouching MK (Low Sweep): 9f startup knockdown. Key combo ender and round-closer.
- Standing HK (Spinning Back Kick): 14f startup but huge range. Whiff punish tool at max spacing.

**Special Moves:**

| Move | Input | Properties |
|------|-------|------------|
| **Ember Shot** | 236 + P | Projectile. LP = slow speed, HP = fast speed. 18f startup, 6f recovery. Controls horizontal space. EX (25 Ember): fires 2 hits, more hitstun. |
| **Rising Cinder** | 623 + P | Anti-air uppercut. 5f startup (invincible frames 1-5). Launches on hit. LP = short height/less damage, HP = full arc/more damage. EX: fully invincible through active frames. Kael's reversal. |
| **Cinder Step** | 214 + K | Forward-advancing kick. LK = short distance/safe on block, HK = long distance/unsafe on block (-6). Gap closer. EX: passes through opponent (side switch). |
| **Flame Sweep** | 214 + P | Low-hitting palm strike along the ground. MP = mid distance, HP = far distance. Hits low (must be crouch-blocked). EX: causes hard knockdown. |

**Ignition Move — Inferno Pillar** (50 Ember):
- Input: 236236 + HP
- Startup: 8f (invincible frames 1-5)
- Kael drives his palm into the ground. A pillar of fire erupts vertically in front of him. Hits grounded and airborne opponents.
- Damage: 280 (before proration)
- Can be comboed into from close MP or cancelled normals.
- Visual: Camera zooms slightly, screen darkens, pillar effect with intense particle shower.

**Kael's Gameplan:**  
Control space with Ember Shot. Anti-air jumps with Rising Cinder. Use Cinder Step to close distance when the opponent respects the projectile. Punish whiffs with Standing HK or Crouching MK. Build Ember through consistent, controlled pressure. Spend Ember on EX Rising Cinder (safe reversal) or Inferno Pillar for big combo damage.

---

### 3.2 RHENA — The Wildfire

**Archetype:** Rushdown / Pressure  
**Personality:** Explosive, confident, relentless. Rhena fights like a wildfire — chaotic, overwhelming, and impossible to contain once she gets going. She talks during fights (short barks, taunts). Where Kael is discipline, Rhena is instinct.  
**Visual Identity:** Muscular, compact build. Wild short hair. Street-fighting attire — wraps, torn sleeves, combat boots. Visible burn scars on arms (worn as pride, not shame). Silhouette reads as "ready to explode."  
**Rhythm:** Explosive. Rhena wants to be in your face. Her moves have less range but more advantage on hit. She wins by getting in and not letting you breathe.

**Stats:**
- Walk speed: 220 px/sec (fast — 10% faster than Kael)
- Dash distance: 140 px (long — she closes ground fast)
- Health: 950 (slightly less — trades survivability for aggression tools)
- Damage output: High per-hit, highest damage off successful reads

**Normal Highlights:**
- Standing LP (Quick Cross): 4f startup. Her fastest button. Starts pressure strings.
- Standing MK (Snap Kick): 8f startup with excellent advantage on hit (+5). Her best frame trap starter.
- Crouching HP (Rising Elbow): 12f startup anti-air. Less range than Kael's DP but doesn't require a motion input — it's a normal.

**Special Moves:**

| Move | Input | Properties |
|------|-------|------------|
| **Blaze Rush** | 236 + K | Charging shoulder tackle. LK = short/safe, HK = long/hits twice/unsafe (-4). Closes distance fast. EX (25 Ember): armor on frames 3-8 (absorbs one hit without interrupting). Her approach tool. |
| **Flashpoint** | 623 + P | Rising knee into aerial hammer. Anti-air but also works as combo ender. LP = quick/less damage, HP = slow startup but devastating damage. EX: wall bounces on hit (enables follow-up juggle). |
| **Ignition Grip** | 63214 + P | Command throw. 8f startup, cannot be blocked. Grabs, lifts, slams. 160 damage. Cannot be teched like normal throws. Slower startup is the tradeoff. EX: extra damage (200) and switches sides. |
| **Afterburn** | 214 + K | Evasive backflip into diving kick. LK = short arc/fast, HK = long arc/can cross-up. Dodge + attack in one motion. EX: invincible during flip (frames 1-12). |

**Ignition Move — Firestorm** (50 Ember):
- Input: 236236 + HK
- Startup: 6f (invincible frames 1-3)
- Rhena charges forward with a 5-hit rush of punches and kicks, ending with a massive grab-slam.
- Damage: 300 (before proration)
- Range: Must be close (within 80px). Whiffs at range and is extremely punishable.
- Can be comboed into from close MK or Ember-cancelled normals.
- Visual: Screen streaks with motion blur, each hit produces a burst of ember particles, slam creates a ground-crack effect.

**Rhena's Gameplan:**  
Get in. Blaze Rush closes distance. Afterburn evades projectiles. Once in range, pressure with LP/MK frame traps. Mix up between normal throw (fast, techable), Ignition Grip (slow, untechable), and continued pressure. Force the opponent to guess. Build Ember fast through constant contact. Spend Ember on EX Blaze Rush (armored approach) or Firestorm for burst damage off a confirm.

---

### 3.3 Matchup Dynamic

**Kael vs Rhena** is the fundamental fighting game question: *can the zoner keep them out, or can the rushdown get in?*

- At full screen: Kael controls with Ember Shot. Rhena must dashblock, jump, or use Afterburn to approach.
- At mid range: Kael's pokes dominate. Rhena needs a read to dash or Blaze Rush through.
- At close range: Rhena's pressure is suffocating. Kael needs Rising Cinder (risky — huge punish if baited) or backdash to reset.

Neither player has a dominant position at all ranges. The fight is about *who dictates the range*. This is what makes the matchup replayable.

---

## 4. Stage Design

### 4.1 The Forge — Ashfall's First Stage

**Theme:** An ancient volcanic forge, open to the sky. Cracked obsidian floor. Cooling lava channels visible at the edges. A massive dormant anvil in the deep background. The sky is perpetually dusk — amber light filtering through volcanic haze.

**Visual Mood:** Warm, intense, primal. The palette is volcanic: black stone, orange lava glow, deep amber sky, cool blue-grey smoke. The stage communicates the game's identity — fire, intensity, consequence.

**Dimensions:**

| Parameter | Value | Notes |
|-----------|-------|-------|
| Stage width | 640 px (playable area) | ~3.2 seconds to walk across at Kael's speed |
| Stage height | 360 px (visible) | 16:9 aspect ratio base |
| Left boundary | Hard wall (invisible) | Characters cannot walk off-screen |
| Right boundary | Hard wall (invisible) | Same |
| Floor Y position | 280 px from top | Ground plane for all characters |
| Render resolution | 640×360 base, scaled up | Pixel-art friendly resolution |

**Camera Behavior:**
- Camera tracks the **midpoint** between the two fighters horizontally.
- Camera zoom adjusts based on fighter distance:
  - Close (< 200px apart): Slight zoom in (1.1x). Intensifies close combat.
  - Mid (200-400px): Default zoom (1.0x).
  - Far (400-600px): Slight zoom out (0.9x). Ensures both fighters are always visible.
- Camera never scrolls — the stage is a single screen. Fighters are bound within it.
- Camera vertical position is fixed. No vertical tracking (grounded game, jumps don't go high enough to warrant it).

**Background Layers (Parallax):**

| Layer | Content | Scroll Rate | Notes |
|-------|---------|-------------|-------|
| 0 (farthest) | Amber sky + volcanic haze | 0.0x (static) | Sets mood |
| 1 | Distant volcano silhouette | 0.05x | Subtle parallax depth |
| 2 | Forge structure + anvil | 0.15x | Main landmark |
| 3 | Lava channels + ground detail | 0.3x | Mid-depth detail |
| 4 (closest) | Floor + fight surface | 1.0x | Gameplay plane |

**Ember Integration:**
- At low Ember (0-30): Stage is calm. Lava channels glow dimly.
- At mid Ember (30-70): Lava channels brighten. Ambient particles (embers, ash) drift upward.
- At high Ember (70-100): Lava pulses. Ember particles intensify. Background forge glows. The stage *reacts to the fight*.

---

## 5. Game Flow

### 5.1 State Machine

```
BOOT → TITLE SCREEN → MAIN MENU → CHARACTER SELECT → STAGE (auto: The Forge)
  → PRE-ROUND → ROUND (active gameplay) → ROUND END
  → [repeat rounds until match decided]
  → MATCH END → VICTORY SCREEN → REMATCH / MAIN MENU
```

### 5.2 Screen-by-Screen

**Title Screen:**
- "ASHFALL" logo with ember particle effect.
- "Press any button to start."
- No options here — straight to main menu.

**Main Menu:**
- **Arcade** — Fight AI opponents (Kael or Rhena, escalating difficulty).
- **Versus** — Local 2-player.
- **Training** — Free practice with input display and frame data overlay.
- **Options** — Controls, audio, display settings.
- Clean, minimal. No sub-menus deeper than 1 level.

**Character Select:**
- Side-by-side character portraits. P1 selects left, P2 selects right.
- In Arcade/Training mode, P2 side shows AI.
- Selection confirms with a fire burst effect.
- If same character selected by both players: P2 gets an alternate color palette.
- Max time: 30 seconds. If no selection, defaults to Kael.

**Pre-Round:**
- Characters walk to starting positions from off-screen.
- "ROUND 1" / "ROUND 2" / "FINAL ROUND" announcement.
- 1-second beat. "FIGHT!" — gameplay begins.

**Round (Active Gameplay):**
- 60-second timer counting down.
- HUD visible: health bars (top), round markers (dots below health), Ember gauges (below health bars), timer (top center).
- Gameplay runs at **fixed 60 FPS timestep** with delta accumulator.

**Round End:**
- Triggered by: HP reaches 0 OR timer runs out.
- Winner performs a brief victory pose (1.5 seconds).
- Loser plays defeat animation.
- Round marker fills in for the winner.
- 2-second pause → next round starts.

**Match End:**
- After 2 round wins, the winner performs their **match victory animation** (3 seconds, unique per character).
- "K.O." or "TIME" displayed prominently.
- Screen transitions to victory screen.

**Victory Screen:**
- Winner displayed with character art and name.
- Stats shown: rounds won, total damage dealt, longest combo, Ember spent.
- Options: **Rematch** (same characters, reset) or **Main Menu**.
- In Arcade mode: "CONTINUE?" with countdown, then next opponent.

### 5.3 Timing Summary

| Transition | Duration |
|------------|----------|
| Character select → Pre-round | 1.5 seconds |
| Pre-round → FIGHT | 3 seconds total |
| Round end → Next round start | 4 seconds |
| Match end → Victory screen | 3 seconds |
| Victory screen → Rematch | Instant on selection |
| Victory screen → Menu | 1.5 second fade |

---

## 6. Controls

### 6.1 Gamepad Layout (Primary — Recommended)

```
                    [LB]  [RB]
                    [LT]  [RT]

   [D-Pad]                        [Y] HP    [X] MP
     ↑                            [B] HK    [A] LP
   ← ↓ →         [Back] [Start]  
                                  [LK] [MK] — mapped to triggers

   [Left Stick] — movement (same as D-pad)
```

**Mapping:**

| Button | Action |
|--------|--------|
| D-Pad / Left Stick | Movement (8-way) |
| A (Xbox) / Cross (PS) | Light Punch (LP) |
| X (Xbox) / Square (PS) | Medium Punch (MP) |
| Y (Xbox) / Triangle (PS) | Heavy Punch (HP) |
| B (Xbox) / Circle (PS) | Light Kick (LK) |
| LB / L1 | Medium Kick (MK) |
| RB / R1 | Heavy Kick (HK) |
| LT / L2 | Throw (LP + LK macro) |
| RT / R2 | Dash (forward dash macro) |
| Start | Pause |

**Why 6-button:** Fighting games need distinct buttons for distinct attack weights. 4-button systems (Tekken, Smash) assign limbs; 6-button systems (SF, Guilty Gear) assign weight × limb. Ashfall uses 6-button because it gives the clearest mechanical vocabulary: each button = one move in any stance.

**Macro Buttons:** LT and RT are macros (LP+LK for throw, forward-forward for dash). They don't add moves — they make existing moves accessible. Macros are optional; the manual inputs always work.

### 6.2 Keyboard Layout (Secondary)

```
Movement:                  Attacks:
  W (up/jump)              U = LP    I = MP    O = HP
  A (left)  D (right)      J = LK    K = MK    L = HK
  S (down/crouch)
                           Space = Throw (LP+LK macro)
                           Shift = Dash macro
                           Esc = Pause
```

**Why this layout:** Left hand on WASD for movement, right hand on UIO/JKL for attacks. Mirrors the gamepad concept: directional input on one hand, action buttons on the other. Hands are far enough apart to avoid accidental inputs.

### 6.3 Control Requirements for Implementation

- **Remappable:** All controls must be remappable from the Options menu. Store config in `user://controls.cfg`.
- **Input method auto-detection:** If a gamepad is connected, show gamepad prompts. If keyboard input is detected, switch prompts. Seamless.
- **Simultaneous input:** Both P1 and P2 can use keyboard OR gamepads. Support mixed input (P1 keyboard, P2 gamepad).
- **Deadzone:** Analog stick deadzone = 0.25 (configurable). D-pad preferred for precision.
- **SOCD (Simultaneous Opposing Cardinal Directions):** If Left+Right pressed simultaneously, resolve to Neutral. If Up+Down pressed simultaneously, resolve to Up (jump priority). This prevents illegal input exploits.

---

## 7. AI Opponent

### 7.1 Design Philosophy

The AI exists to make single-player fun — not to simulate a human. It should feel like a sparring partner that adapts to your skill level, not a cheating robot that reads your inputs.

### 7.2 MVP AI Behavior

**Difficulty: Normal (only difficulty for MVP)**

The AI operates on a simple decision tree with weighted random selection, evaluated every 30 frames (0.5 seconds):

**At far range (> 300px):**
- Walk forward: 50%
- Dash forward: 20%
- Use projectile (Kael only): 30%

**At mid range (150-300px):**
- Walk forward: 20%
- Attack (random normal): 30%
- Block: 25%
- Use special move: 15%
- Backdash: 10%

**At close range (< 150px):**
- Attack (light/medium): 40%
- Throw: 15%
- Block: 25%
- Backdash: 10%
- Use special move: 10%

**Defensive Reactions:**
- Block incoming attack: 60% chance to block correctly (stand/crouch)
- Tech throws: 40% chance
- Anti-air jumps: 30% chance to use appropriate anti-air

**Combo Behavior:**
- Can execute the universal LP → MP → HP target combo
- Does not perform links or cancels (those are human skill ceiling)
- Will use EX specials when at 50+ Ember
- Will use Ignition Move when at 100 Ember and opponent below 30% HP

### 7.3 AI Rules (Binding)

1. **No input reading.** The AI never reads the player's inputs before they produce visible on-screen results. It reacts to positions, states, and animations — same data a human has.
2. **Reaction delay:** AI decisions have a 6-12 frame delay before executing (simulates human reaction time). This makes it beatable on reaction.
3. **No perfect play.** AI intentionally drops combos, mis-times blocks, and occasionally whiffs moves. Perfection is boring — personality is interesting.
4. **Difficulty scaling (DEFERRED):** Easy/Hard/Very Hard are deferred. MVP ships with Normal only. Future difficulty adjusts: reaction delay, block rate, combo complexity, Ember usage efficiency.

---

## 8. Art Direction

### 8.1 Visual Style: 2D Pixel Art (High-Resolution)

**Style Reference:** HD pixel art at the resolution tier of games like *Guilty Gear XX* or *The Last Blade 2* — detailed sprite work with strong silhouettes and expressive animation. Not retro 8-bit; not HD illustration. The sweet spot: **detailed enough to read emotion, stylized enough to animate cleanly.**

**Resolution Target:**
- Characters: 128×128 px sprite canvas (scaled to ~200px on screen)
- Stage: 640×360 base resolution, scaled up to display resolution
- UI: Vector or high-res pixel art (scalable)

**Color Palette:**
- **Stage palette:** Volcanic warm (obsidian black, lava orange, amber, deep red, cool grey smoke)
- **Kael palette:** Cool discipline (grey-white gi, blue-ember accents, tan skin tones)
- **Rhena palette:** Hot intensity (dark red/black attire, orange-ember accents, warm skin tones)
- **UI palette:** Clean contrast (dark backgrounds, bright orange/white text, ember particle accents)
- **Hit effects:** Bright orange-white flash on contact. High saturation. Must pop against any background.

### 8.2 Animation Requirements

**Per Character — Required Animation States:**

| State | Frames (target) | Loop? | Priority |
|-------|-----------------|-------|----------|
| Idle | 6-8 | Yes | P0 |
| Walk Forward | 8 | Yes | P0 |
| Walk Backward | 8 | Yes | P0 |
| Crouch (transition) | 3 | No | P0 |
| Crouch (idle) | 4 | Yes | P0 |
| Jump (up arc) | 4 | No | P0 |
| Jump (peak) | 2 | No | P0 |
| Jump (fall) | 4 | No | P0 |
| Dash Forward | 4 | No | P0 |
| Backdash | 4 | No | P0 |
| Standing LP | 3 | No | P0 |
| Standing MP | 5 | No | P0 |
| Standing HP | 7 | No | P0 |
| Standing LK | 3 | No | P0 |
| Standing MK | 5 | No | P0 |
| Standing HK | 7 | No | P0 |
| Crouching LP | 3 | No | P0 |
| Crouching MP | 5 | No | P0 |
| Crouching HP | 6 | No | P0 |
| Crouching LK | 3 | No | P0 |
| Crouching MK | 5 | No | P0 |
| Crouching HK | 6 | No | P0 |
| Jump LP | 3 | No | P1 |
| Jump MP | 4 | No | P1 |
| Jump HP | 5 | No | P1 |
| Jump LK | 3 | No | P1 |
| Jump MK | 4 | No | P1 |
| Jump HK | 5 | No | P1 |
| Standing block | 2 | No | P0 |
| Crouching block | 2 | No | P0 |
| Hit (light) | 3 | No | P0 |
| Hit (heavy) | 5 | No | P0 |
| Hit (crouching) | 3 | No | P0 |
| Hit (air) | 4 | No | P0 |
| Knockdown (fall) | 6 | No | P0 |
| Knockdown (ground) | 4 | No | P0 |
| Wake-up | 4 | No | P0 |
| Throw (execute) | 8 | No | P0 |
| Thrown (victim) | 8 | No | P0 |
| Win pose | 12 | No | P1 |
| Lose pose | 8 | No | P1 |
| Special 1 | 8-12 | No | P0 |
| Special 2 | 8-12 | No | P0 |
| Special 3 | 8-12 | No | P0 |
| Special 4 | 6-10 | No | P0 |
| Ignition Move | 16-24 | No | P1 |

**Total per character: ~45 animation states, ~230 frames.**

**Animation Rules:**
1. **Anticipation is mandatory.** Every attack has visible wind-up frames. No attack goes from idle to active in 0 frames.
2. **Silhouette test.** Every pose must be identifiable as a solid black silhouette. If two poses look similar in silhouette, redesign one.
3. **Exaggeration over realism.** Punches extend further than anatomically possible. Kicks arc wider. Hit reactions are dramatic. This is a video game, not a simulation.
4. **Consistent weight.** Kael's animations are controlled and precise (small wind-ups, clean lines). Rhena's are explosive and messy (big wind-ups, wide swings, momentum overshoot).

### 8.3 VFX Requirements

| Effect | When | Visual | Priority |
|--------|------|--------|----------|
| Hit spark | Attack connects | Bright orange-white burst, 4-6 frames | P0 |
| Block spark | Attack blocked | Blue-white spark, smaller than hit, 3 frames | P0 |
| Ember particles | Ember gauge building | Small orange dots floating upward | P0 |
| Dash trail | During dashes | Motion blur / afterimage, 3-4 frames | P1 |
| Ignition flash | Ignition move activation | Full-screen white flash (2 frames) + zoom | P1 |
| KO effect | Final hit of match | Slow-motion (0.3x for 30 frames) + heavy screen shake | P1 |
| Projectile (Kael) | Ember Shot active | Fireball sprite, 4-frame animation loop | P0 |

---

## 9. Audio Direction

### 9.1 Music

**Vibe:** Intense, percussion-driven, cinematic. Think taiko drums meets industrial metal — primal and modern simultaneously. The music should make you want to *fight*, not just listen.

**Structure:**
- **Character Select:** Melodic, anticipatory. Building energy. Medium tempo (110 BPM).
- **The Forge stage theme:** Starts restrained (sparse percussion, low drone). As Ember builds during the round, layers add: heavier drums, distorted guitar or synth stabs, rising strings. Music reacts to fight intensity. If both players are passive, the music stays sparse. If the fight is aggressive, it swells.
- **Victory theme:** Short (8 seconds). Triumphant, punctuated. Unique per character.
- **Menu theme:** Ambient, warm. Ember crackle + soft melodic line. Not distracting.

**Implementation Note:** Dynamic music is a P2 feature. For MVP, the stage theme is a single looping track at full intensity. The dynamic layer system is designed now so the music can be authored with layers from the start, even if the dynamic triggering comes later.

### 9.2 Sound Effects

**Hit Sounds (P0 — Highest Audio Priority):**

| Sound | Trigger | Character |
|-------|---------|-----------|
| Light hit | LP/LK connects | Sharp snap. Short decay. |
| Medium hit | MP/MK connects | Meatier thud. Medium decay. |
| Heavy hit | HP/HK connects | Deep impact boom. Long decay. Screen shake accompanies. |
| Block sound | Attack blocked | Dull thud + metallic ring. Must sound *different* from hits. |
| Whiff sound | Attack misses | Subtle whoosh. Air cutting. |
| Throw sound | Throw connects | Grab (cloth), impact (slam), grunt. 3-part sound. |
| Special hit | Special move connects | Character-specific. Layered: impact + fire SFX (hiss/whoosh). |
| Ignition hit | Ignition move connects | Cinematic. Multi-layered. Heavy reverb. Screen-filling. |

**Rules:**
- **Variation is mandatory.** Every hit sound has 3 variants minimum. Random selection with pitch jitter (±5%). Prevents audio fatigue.
- **Hit sounds fire on the FIRST active frame that connects**, not on animation frame. Audio must sync to the game state, not the sprite.
- **Layering:** Heavy hits = base impact + fire accent + bass rumble. Light hits = single sharp transient. More layers = more weight.

**Voice (P1):**
- Each character has ~10 voice barks: attack grunts (3 variants), hit reactions (3 variants), KO cry (1), Ignition move callout (1), round win line (2).
- Rhena is louder and more vocal. Kael is sparse — heavy exhales, minimal vocalization.

### 9.3 Announcer

- "ROUND 1" / "ROUND 2" / "FINAL ROUND"
- "FIGHT!"
- "K.O."
- "TIME"
- "[Character name] WINS"
- Tone: Authoritative, energetic, not over-the-top. Think: a veteran referee, not a hype man.
- **Priority:** P1. Can use placeholder text-to-speech for MVP.

---

## 10. Scope Boundary

### IN for MVP (Ship This)

| Feature | Priority | Notes |
|---------|----------|-------|
| 2 playable characters (Kael, Rhena) | P0 | Complete movesets, all normals + 4 specials + Ignition each |
| 1 stage (The Forge) | P0 | Full art, parallax, Ember-reactive lighting |
| Local Versus mode (2P) | P0 | Same-screen, keyboard + gamepad |
| Arcade mode (vs AI) | P0 | 3 fights (easy→normal→hard AI — or single Normal for true MVP) |
| Training mode | P0 | Input display, free practice, dummy options (stand/crouch/jump) |
| Full combat system | P0 | All mechanics from Section 2 |
| Ember system | P0 | Core resource with visual feedback |
| Health/round/timer | P0 | Standard fighting game HUD |
| Game flow (menu→select→fight→result) | P0 | All screens from Section 5 |
| Gamepad + keyboard support | P0 | Remappable |
| Hit VFX + SFX | P0 | At minimum: hit sparks, block sparks, 3-variant hit sounds |
| AI opponent (Normal difficulty) | P0 | Per Section 7 |

### DEFERRED (Not in MVP)

| Feature | When | Notes |
|---------|------|-------|
| Online multiplayer (rollback netcode) | Post-MVP Phase 1 | Requires GGPO/rollback architecture. Plan for it but don't build it yet. |
| Additional characters (3-8) | Post-MVP Phase 2 | Each new character = ~4 weeks of design + art + implementation |
| Additional stages (3-5) | Post-MVP Phase 2 | Visual variety, but 1 stage is enough for core gameplay validation |
| Story/Arcade mode (narrative) | Post-MVP Phase 3 | Character intros, rival battles, endings. Requires narrative writing. |
| Ranked mode | Post-MVP (requires online) | ELO/matchmaking system |
| Replay system | Post-MVP Phase 1 | Input recording + playback. Valuable for community but not MVP. |
| Spectator mode | Post-MVP (requires online) | |
| Dynamic music system | Post-MVP Phase 1 | Layer system triggered by Ember levels |
| Difficulty levels (Easy/Hard/Very Hard) | Post-MVP Phase 1 | Tune AI parameters per Section 7 |
| Tutorial mode | Post-MVP Phase 1 | Interactive combo trials, mechanic explanations |
| Color editor / alt costumes | Post-MVP Phase 2 | Palette swaps first, then unique costumes |
| Cross-platform | Future | Depends on Godot export targets |

### Scope Principles

1. **Ship the punching first.** The game is playable when two characters can fight on one stage with satisfying combat feel. Everything else is iteration on that foundation.
2. **No feature without a core loop connection.** If a feature doesn't serve the round-to-round fighting experience, it's deferred.
3. **Plan for online from day 1.** Use deterministic simulation (fixed timestep, input-based state advancement) so rollback netcode is *possible* later. Don't build it now, but don't make it impossible.
4. **Art before variety.** One stage with beautiful Ember integration > three stages with flat lighting. Two characters with full movesets > four characters with half-baked kits.

---

## Appendix A: Reference Games

| Game | What We Take | What We Leave |
|------|-------------|---------------|
| Street Fighter V/6 | 6-button layout, frame data discipline, V-Trigger as inspiration for Ember | V-System complexity, character-specific V-triggers |
| Tekken 7/8 | Rage system (comeback resource), visual intensity at match point | 4-button limb system, 3D movement |
| Guilty Gear Strive | Tension meter (offensive resource), wall break spectacle | Roman Cancel complexity, air dash system |
| Under Night In-Birth | GRD/Vorpal (visible momentum resource) | Information density overload for new players |
| Fantasy Strike | Accessibility focus, readable animations | Simplified inputs (we keep motions but add leniency) |

---

## Appendix B: Technical Constraints (For Implementers)

- **Engine:** Godot 4.x
- **Render:** 2D sprites (Sprite2D + AnimationPlayer)
- **Physics:** Custom fighting game physics (no Godot physics engine — fighting games need deterministic, frame-exact collision)
- **Timestep:** Fixed 60 FPS with delta accumulator. `_physics_process(delta)` at 60 Hz.
- **Input:** Godot's InputMap + custom input buffer (8-frame ring buffer, per Section 2.10)
- **State machines:** Enum-based state machines per character (not AnimationTree — need frame-exact control)
- **Hitbox/Hurtbox:** Area2D nodes with collision shapes, toggled per animation frame
- **Audio:** AudioStreamPlayer pool (8 concurrent) with pitch jitter for hit SFX variation
- **Scene structure:** Main scene → GameManager (autoload) → FightScene → [P1, P2, Stage, HUD, InputManager]
- **Determinism:** All gameplay logic must be deterministic given the same inputs. No `randf()` in gameplay code — use seeded RNG. This enables future replay system and rollback netcode.

---

*"The fire doesn't ask permission. It just burns."*  
*— Ashfall design motto*
