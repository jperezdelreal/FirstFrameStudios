# SimpsonsKong — Game Design Document

> **Author:** Yoda (Game Designer)  
> **Date:** 2025  
> **Version:** 1.0  
> **Status:** Active — This is the team's north star.

---

## 1. Game Vision Statement

SimpsonsKong is a browser-based beat 'em up that captures the chaotic joy of being *inside* a Simpsons episode — fists first. Players should feel the slapstick weight of Homer's belly bounce, laugh when Bart taunts a room full of goons, and grin when a perfectly timed combo earns them a "Best. Combo. Ever." rating. This isn't a game that happens to have Simpsons characters; it's a game where the comedy IS the combat, where Springfield's landmarks are weapons and arenas, and where every punch lands with the exaggerated, cartoon-physics satisfaction that only the Simpsons universe can deliver. Built for the browser, it's instant joy — no downloads, no installs, just click and punch. The goal: make players laugh, feel powerful, and immediately want to try the next character.

---

## 2. Design Pillars

Every design decision must pass through these four pillars. If a feature doesn't serve at least one pillar, it doesn't belong.

### Pillar 1: Comedy as a Core Mechanic
Humor isn't cosmetic — it's woven into every system. Taunts are mechanically meaningful *and* hilarious. Failure states are funny ("D'oh!" moments), not frustrating. The combo meter speaks in Simpsons quotes. Enemy defeat animations reference show gags. Environmental interactions are comedic set pieces. A player who never reads a single line of dialogue should still laugh from gameplay alone.

**Design test:** "If we stripped the Simpsons skin off this mechanic, would it still be funny?" If no, the comedy is cosmetic. Push deeper.

### Pillar 2: Accessible Depth
Easy to play, deep to master — the Streets of Rage 4 principle. A first-time player mashing buttons should have fun and clear content. A veteran chaining dodge-cancel into juggle-combo into wall-bounce should feel like a combat artist. The skill ceiling is high but the skill floor is on the ground.

**Design test:** "Can a button-masher have fun? Can a combo master have a *different* kind of fun?" Both must be yes.

### Pillar 3: Family Synergy
The Simpsons are a family. The game mechanically rewards playing together. Co-op isn't just "two players on screen" — it's team attacks, proximity buffs, and a family super that only fires when everyone coordinates. Solo play is great; family play is transcendent.

**Design test:** "Does this feature feel better with two players than one?" If it feels exactly the same, add a co-op dimension.

### Pillar 4: Springfield Is a Character
Environments aren't backdrops — they're interactive, story-rich, and full of surprises. Every Springfield location should feel like visiting a place you know from the show. Destructible props, environmental hazards, landmark-specific gags, and interactive set pieces turn levels from corridors into playgrounds.

**Design test:** "Would a Simpsons fan recognize this location? Would they be delighted by what they can interact with?"

---

## 3. Player Experience Goals

These define the emotional arc of the game — what the player should FEEL at each milestone.

### First 10 Seconds
> "I'm Homer Simpson punching bad guys!"

The player sees Homer — immediately recognizable, chunky, yellow. They press attack and Homer throws a big, satisfying punch. An enemy staggers backward. Screen shakes. A crunchy impact sound plays. The player grins. **They are Homer.**

*Design implication:* Homer's idle and first punch must be iconic. No tutorial needed — the first attack must land, feel weighty, and be unmistakably Homer.

### First 30 Seconds
> "This combat feels GREAT — that combo was satisfying!"

The player has discovered punch-punch-kick. The combo counter appeared. The last enemy flew across the screen with a 375-knockback finisher. The combo meter flashed "Ay Caramba!" The player is now *seeking* combos, not just mashing.

*Design implication:* The PPK combo must be discoverable through natural play (most players will try punch-punch-kick organically). The feedback must be dramatically different from single hits — bigger screen shake, louder sound, longer knockback, combo text.

### First Minute
> "These enemies actually make me think!"

The player encounters a charger that punishes standing still, then a shielded enemy that can't be hit from the front. They learn to dodge-roll, then to grab-and-throw. Each new enemy type teaches a new skill. The player's "vocabulary" is growing.

*Design implication:* The golden rule — one new enemy type per encounter. Never overwhelm the player's learning capacity. Each enemy must have a clear visual tell and a clear counter-strategy.

### First Level Complete
> "Springfield feels alive, enemies are varied, the boss was EPIC."

The player has fought through Springfield Downtown, passing the Kwik-E-Mart and Moe's Tavern. They threw an enemy into Lard Lad's giant donut. The boss had three phases and required everything they'd learned. The victory screen showed their score, their best combo, and their rank. They feel accomplished.

*Design implication:* Levels must have visual variety, environmental interaction, and a climactic boss fight. The end-of-level screen must celebrate the player's performance.

### First Game Over
> "I want to try again — and maybe try Bart next time."

The game over screen shows their score, teases what they could improve ("Your best combo was 12 — can you hit 20?"), and shows the character select screen. The player notices Bart's speed stats and thinks "I wonder how he plays..."

*Design implication:* Game over must not feel punishing. Tease improvement and alternatives. Character select should be visible and tempting.

### First Full Completion
> "I need to play again with a different character — and beat my high score."

The player beat all levels with Homer. They unlocked a new difficulty. They see their time and score on the leaderboard. They know Marge has completely different combos. The Treehouse of Horror bonus level is locked behind a challenge they haven't completed. There are reasons to return.

*Design implication:* Replayability comes from character variety, score chasing, difficulty modes, and unlockable content. The game must feel different with each character, not just a stat swap.

---

## 4. Core Combat Design

The combat system is the heart of SimpsonsKong. It draws from the genre's best: Streets of Rage 4's depth, Turtles in Time's spectacle, Shredder's Revenge's modern feel, and the original Simpsons Arcade's authenticity.

### 4.1 Inputs & Controls

| Input | Action | Notes |
|-------|--------|-------|
| Direction (WASD / Arrows) | Move (4-direction, 2.5D) | Horizontal movement faster than vertical (depth) |
| Attack (J / Z) | Light attack (punch) | Foundation of all combos |
| Heavy (K / X) | Heavy attack (kick) | Slower, stronger, combo finisher |
| Jump (Space) | Jump | Parabolic arc, enables aerial combat |
| Special (L / C) | Special move | Costs health (SoR2 model), powerful crowd clear |
| Dodge (Shift / V) | Dodge roll | I-frames during roll, directional |
| Grab (Attack near stunned enemy) | Grab/throw | Context-sensitive, proximity-based |
| Taunt (T) | Character-specific taunt | Builds super meter, leaves vulnerable |

### 4.2 Basic Combo Structure

The combo system layers depth without gating access:

**Ground Combo Chain:**
```
Punch → Punch → Punch → Auto-finisher (knockback)
  └→ Kick (at any point) → Heavy finisher (big knockback + extra damage)
  └→ Forward + Attack → Dash attack (gap closer, combo starter)
  └→ Back + Attack → Back attack (hits behind, anti-surround)
```

**The PPK (Punch-Punch-Kick) is the bread and butter:**
- Punch 1: 10 damage (base, 1.0× multiplier)
- Punch 2: 12 damage (combo tier 1, 1.1× multiplier) — rewards commitment
- Kick finisher: 20 damage (combo tier 2, 1.2× multiplier) + 1.5× knockback
- **Total: 42 damage in 1.1 seconds** — the optimal ground DPS when spacing cooperates

**Combo Window:** 0.4 seconds between inputs to maintain the chain. Dropping the window resets the combo. This window is generous enough for casual play but tight enough to require attention.

**Combo Scaling:** Each successive hit in a combo increases the damage multiplier by 10%, capping at +50% (6-hit chain). This rewards sustained aggression without making infinite combos broken.

### 4.3 Grab & Throw System (Turtles in Time Influence)

Grabs are the genre's most satisfying micro-interaction:

- **Initiation:** Walk into a hitstunned enemy and press Attack
- **Grab state:** Player holds enemy, can:
  - **Pummel (Attack):** 3 quick hits at 8 damage each
  - **Forward Throw (Direction + Attack):** Hurl enemy forward — enemy becomes a projectile, damages anything it hits
  - **Slam (Down + Attack):** Slam enemy into ground — AOE damage at impact point
  - **Screen Throw (Up + Attack):** Toss enemy toward the camera (Turtles in Time homage) — most damage, most dramatic, longest recovery
- **Grab duration:** 2 seconds max, then enemy breaks free
- **Counter-grab risk:** Other enemies can hit you during a grab — grabs are powerful but risky when surrounded

### 4.4 Special Moves (Streets of Rage 2 Health-Cost Model)

Specials cost HP to use but recovering that HP by landing normal attacks creates the genre's best risk/reward loop:

- **Cost:** Each special costs 8% of max HP (8 HP)
- **Recovery window:** The spent HP becomes "grey health" — landing 3 normal attacks within 4 seconds recovers it fully
- **Failure penalty:** If you don't recover in time, the grey health is lost permanently
- **Design intent:** This creates a constant micro-decision — "Do I spend health to clear this crowd and then recover it aggressively, or play it safe?" Aggressive play is rewarded. Passive play is safe but slow.

**Homer's Specials:**
- **Belly Bounce (Neutral Special):** Homer lunges forward, belly-first. Hits all enemies in a wide frontal arc. Sends them flying. The signature move.
- **Power Slide (Down + Special):** Homer slides along the ground. Low profile, hits grounded enemies, good for gap closing.
- **Rising Uppercut (Up + Special):** Homer launches upward with a fist. Anti-air, combo launcher, sends enemies skyward for juggle follow-ups.

### 4.5 Jump & Aerial Combat

Aerial combat adds a vertical dimension but must not trivialize ground play (per balance analysis: jump attacks currently OP at 50 DPS vs. 39 DPS ground):

- **Jump Punch:** Quick, weak (8 damage), fast cooldown (0.25s) — air-to-air, gap closer
- **Jump Kick:** Slow, strong (18 damage), dive angle — air-to-ground, committal
- **Ground Pound (Down + Attack while airborne):** Homer slams down — AOE on landing, high damage (22), long recovery (0.3s landing lag). The "hype" option.
- **Landing Recovery:** All jump attacks incur 0.1s landing lag to prevent air-spam dominance. Jump attacks are burst tools, not the primary damage loop.

**Target Balance (post-tuning):**
| Attack Style | DPS | Risk | Use Case |
|-------------|-----|------|----------|
| Punch spam | 33 | Low | Safe, steady |
| PPK combo | 39 | Medium | Optimal ground damage |
| Jump attacks | 38 | Medium-High | Burst, positioning (with landing lag) |
| Special moves | 45 (burst) | High (HP cost) | Crowd clear, combo extend |

### 4.6 Dodge Roll (Modern Standard)

No modern beat 'em up ships without a dodge. It's the defensive complement to aggressive combat:

- **Activation:** Shift/V + direction
- **I-frames:** 0.2 seconds of invincibility during roll animation
- **Recovery:** 0.15 seconds of vulnerability after roll ends
- **Cooldown:** 0.5 seconds between dodges (prevents dodge spam)
- **Character flavor:** Homer dives (clumsy, wide), Bart cartwheels (flashy), Lisa ducks (precise), Marge sidesteps (dignified)

### 4.7 Weapon Pickups (Final Fight Influence)

Weapons change combat feel temporarily:

| Weapon | Source | Damage Modifier | Range Modifier | Durability | Notes |
|--------|--------|----------------|---------------|------------|-------|
| Metal Pipe | Crates, barrels | 1.5× | 1.3× | 8 hits | Classic beat 'em up weapon |
| Baseball Bat | Barrels | 1.8× | 1.5× | 5 hits | Huge knockback, slow swing |
| Beer Bottle (Duff) | Moe's level | 1.3× | 1.0× | 3 hits, then shatters | Fast, throwable after last hit |
| Skateboard (Bart only) | Crates | 1.4× | 2.0× | 6 hits | Ride for dash attack, swing for melee |
| Saxophone (Lisa only) | Special drop | 1.2× | 2.5× | 10 hits | Sonic wave, crowd control |

Weapons drop on the ground when the player is hit. Enemies can walk over dropped weapons, removing them. This creates urgency: use it or lose it.

### 4.8 Crowd Control Mechanics

When 6+ enemies surround the player, panic sets in. Good crowd control design prevents this from being frustrating:

- **Attack throttling:** Maximum 2 enemies attack simultaneously. Others circle at mid-range, feinting and repositioning. This creates readable combat.
- **AOE specials:** Belly Bounce hits in a wide arc — the crowd-clear panic button (at HP cost).
- **Thrown enemies as projectiles:** Grabbing one enemy and throwing them into a group scatters the crowd.
- **Knockdown duration:** Knocked-down enemies stay down for 1.5 seconds — reducing active threats.
- **Vertical positioning:** Players who use the 2.5D depth axis to "split" groups into manageable clusters are rewarded.
- **Combo meter incentive:** Hitting 4+ enemies in one combo awards a "Crowd Control!" bonus multiplier.

### 4.9 Super Move System

Filled by dealing damage and taunting. The ultimate expression of each character:

- **Meter:** Fills from 0–100%. Dealing damage fills ~1% per hit. Taunting fills 5% per taunt (but leaves you vulnerable for 1.5 seconds).
- **Activation:** Full meter + Special button
- **Homer's Super — "Donut Apocalypse":** Homer inhales a massive donut, turns red, and belly-bounces across the entire screen. Everything hit takes massive damage and flies into the walls. Comedy and power fantasy in one move.
- **Meter carries between encounters** within a level but resets between levels.

---

## 5. Character Design Philosophy

Each playable character must feel **completely different within 10 seconds of play** — not just a stat swap, but a fundamentally different combat experience.

### 5.1 The Character Triangle

Characters follow the classic beat 'em up archetype triangle (Final Fight codified, every game since honors it):

```
         HOMER (Power/All-Rounder)
            ↗               ↖
    MARGE (Range)        BART (Speed)
            ↖               ↗
         LISA (Technical/Crowd Control)
```

### 5.2 Homer Simpson — The All-Rounder

> *"The everyman. If Homer can do it, anyone can."*

| Stat | Value | Notes |
|------|-------|-------|
| Speed | ★★★☆☆ | Medium — Homer isn't fast, but he's not slow |
| Power | ★★★★☆ | Strong — his hits are meaty, satisfying |
| Range | ★★☆☆☆ | Short — he's a brawler, in your face |
| Defense | ★★★★☆ | Tanky — Homer takes punishment like a champ |
| Technical | ★★☆☆☆ | Simple — fewest inputs to master |

**Signature Mechanics:**
- **Belly physics:** Homer's belly is a hitbox. Belly Bounce is his defining move.
- **Donut Rage Mode:** Eating 3 donuts in a level fills a secondary rage meter. When activated: +30% damage, +20% speed, belly attacks have AOE splash, lasts 10 seconds. Visual: Homer turns red, steam from ears.
- **Duff Power-Up:** Duff beer pickup gives 5-second speed boost with very slightly wobbly controls (risk/reward flavor).

**Why Homer is the starter character:** He's the most forgiving. His high defense and simple combos let new players learn the systems without dying. His power fantasy is direct: "I am a big guy and I hit things hard."

### 5.3 Bart Simpson — The Speedster

> *"Hit and run. Never stand still. Be annoying."*

| Stat | Value | Notes |
|------|-------|-------|
| Speed | ★★★★★ | Fastest character, darting, evasive |
| Power | ★★☆☆☆ | Weak individual hits, relies on combo volume |
| Range | ★★★☆☆ | Medium — slingshot gives ranged option |
| Defense | ★★☆☆☆ | Fragile — must dodge, not tank |
| Technical | ★★★★☆ | Combo-heavy, rewards mastery |

**Signature Mechanics:**
- **Skateboard Dash:** Replaces dodge roll. Bart hops on his skateboard — faster, hits enemies during dash, can chain into attacks. Higher skill ceiling than a dodge.
- **Slingshot:** Dedicated ranged attack (down + attack at range). Low damage but interrupts enemy attacks and builds combo meter from safety.
- **"Eat My Shorts" Taunt:** Bart's taunt fills meter 8% (vs. standard 5%) but has a longer animation — more reward, more risk.
- **Bartman Super:** Bart transforms into Bartman — gains flight for 5 seconds, rains down aerial attacks, cape has a wide hitbox.

### 5.4 Marge Simpson — The Range Fighter

> *"Keep them at arm's length. Protect the family."*

| Stat | Value | Notes |
|------|-------|-------|
| Speed | ★★★☆☆ | Medium — measured, deliberate |
| Power | ★★★☆☆ | Medium — consistent, not explosive |
| Range | ★★★★★ | Longest reach — purse and hair whip |
| Defense | ★★★☆☆ | Average — benefits from keeping distance |
| Technical | ★★★☆☆ | Moderate — spacing is her skill expression |

**Signature Mechanics:**
- **Purse Swing:** Marge's basic combo has 1.5× the range of Homer's. Her combo finisher sends enemies flying farther. She controls space.
- **Hair Whip:** Marge's back attack uses her towering blue hair — 360° spin with massive range. The premier anti-surround tool.
- **Maternal Instinct:** Passive — when near an ally below 30% HP, Marge takes 25% reduced damage and deals 15% more. She's the protector.
- **Maggie Assist Super:** Maggie crawls out and bonks the nearest enemy with her mallet, stunning everything in a radius. A love letter to the show's intro.

### 5.5 Lisa Simpson — The Technical / Crowd Controller

> *"Smart play. Control the battlefield. Make enemies look foolish."*

| Stat | Value | Notes |
|------|-------|-------|
| Speed | ★★★★☆ | Quick — smaller frame, nimble |
| Power | ★★☆☆☆ | Low per-hit — compensated by AOE and combos |
| Range | ★★★★☆ | Long — saxophone projectile, jump rope whip |
| Defense | ★★☆☆☆ | Low — must rely on positioning and crowd control |
| Technical | ★★★★★ | Most complex, highest skill ceiling |

**Signature Mechanics:**
- **Saxophone Blast:** Chargeable sonic wave — tap for quick short-range pulse, hold for wide-cone crowd control. Lisa's defining tool.
- **Intellect Advantage:** Lisa's dodge roll has 50% more i-frames (0.3s vs. 0.2s). She "reads" enemy attacks better. Rewards defensive mastery.
- **Jump Rope Whip:** Lisa's basic attack uses her jump rope as a whip — longer range than Homer, faster than Marge, but less damage.
- **Activist Rally Super:** Lisa gives a passionate speech. All enemies on screen are stunned for 3 seconds as they stop to listen. Comedy gold AND strategic (set up combos for allies).

### 5.6 The 10-Second Differentiation Rule

Within 10 seconds of selecting a character, the player must feel the difference:

| Character | 10-Second Moment |
|-----------|-----------------|
| Homer | Throw a big punch. Enemy flies across the screen. "I'm STRONG." |
| Bart | Skateboard-dash through three enemies. "I'm FAST." |
| Marge | Purse-whip hits an enemy two body-lengths away. "I have RANGE." |
| Lisa | Saxophone blast hits four enemies at once. "I control the CROWD." |

---

## 6. Enemy Design Philosophy

Enemies are the game's vocabulary. Each type teaches the player a new word; encounters combine words into sentences; levels compose sentences into stories.

### 6.1 The Enemy Vocabulary

| Type | Name (Simpsons) | HP | Speed | Behavior | Counter Strategy | Teaches Player... |
|------|-----------------|-----|-------|----------|-----------------|------------------|
| **Grunt** | Burns' Goon | 30 | Medium | Walk toward player, basic punch | Any attack | Basic combat flow |
| **Tough** | Plant Security | 70 | Slow | Same as grunt, more HP, hits harder (10 dmg) | Sustained combos, patience | Commitment and combo chains |
| **Dasher** | Nelson's Bully | 25 | Fast | Sprint at player, tackle, retreat | Dodge/jump, punish recovery | Timing and dodge usage |
| **Ranged** | Knife Thrower (Snake Jailbird) | 20 | Medium | Throws projectiles from distance, retreats on approach | Close distance quickly, prioritize | Target prioritization |
| **Shield** | Riot Cop | 40 | Slow | Blocks frontal attacks, advances slowly | Grab, jump attack, flank | Positional thinking |
| **Grappler** | Wrestler (Bonesaw) | 50 | Medium | Grabs player on contact, throws them | Keep distance, hit-and-run | Spacing discipline |
| **Aerial** | Radioactive Man Fan (flies in costume) | 20 | Fast | Swoops from above, dive attacks | Anti-air, timed jumps | Vertical awareness |
| **Summoner** | Sideshow Bob | 35 | Slow | Summons grunt waves, stays back | Rush down immediately | Priority targeting |

### 6.2 Enemy Introduction Pacing

```
Level 1: Springfield Downtown
  Wave 1: Grunts only (learn to fight)
  Wave 2: Grunts + 1 Tough (learn commitment)
  Wave 3: Grunts + Dasher (learn to dodge)
  Wave 4: Mix of learned types (combine skills)
  BOSS: Sideshow Bob (combines summoning + pattern recognition)

Level 2: Springfield Nuclear Power Plant
  Wave 1: Grunts + Ranged (learn prioritization)
  Wave 2: Tough + Shield (learn flanking)
  ...and so on, each level adding 1-2 new enemy types
```

**The Golden Rule:** Never introduce more than one new enemy type per encounter. Let the player learn the "word" before building "sentences."

### 6.3 Enemy AI Throttling

To prevent unfair pile-ons:
- **Max simultaneous attackers:** 2 (on Normal difficulty), 3 (on Hard)
- **Circle behavior:** Non-attacking enemies orbit at mid-range, feinting and repositioning. This looks like tactical behavior, not waiting in line.
- **Attack cooldown stagger:** When two enemies attack near-simultaneously, stagger by 0.3s minimum to give the player readable dodge windows.
- **Retreat on ally hit:** When an enemy near another enemy sees their ally get hit, they briefly retreat 0.5s before re-engaging. This creates natural breathing room.

### 6.4 Boss Design Philosophy

Bosses are the final exam for each level. They must be multi-phase, memorable, and mechanically unique.

**Boss Design Template:**
- **Phase 1 (100%–60% HP):** Boss uses 2 attacks with clear tells. Player learns the patterns. Difficulty: moderate.
- **Phase 2 (60%–30% HP):** Boss adds 1-2 new attacks, moves faster, may summon adds. Difficulty: high.
- **Phase 3 (30%–0% HP):** Boss enters "rage" state — faster, stronger, but more predictable (their "tell" becomes more obvious, rewarding pattern mastery). Difficulty: intense but fair.

**Every boss must have:**
1. A unique mechanic not seen in regular enemies
2. A visual tell before every attack (wind-up animation, flash, sound cue)
3. A punish window after every attack (the player's reward for learning)
4. A comedy moment (a gag mid-fight that's funny even when you're losing)

**Level 1 Boss: Sideshow Bob**
- Phase 1: Bob throws rakes at the player (dodge them). Steps on rakes himself periodically (stun window — comedy reference).
- Phase 2: Bob summons waves of grunts. Player must fight through adds to reach Bob. Bob throws larger rakes in patterns.
- Phase 3: Bob enters "Fury" state — rapid rake throws, charges at player. But he trips on rakes more often (longer punish windows). The comedy escalates with the difficulty.

---

## 7. Level Design Philosophy

Levels follow the proven beat 'em up structure but infuse it with Springfield's identity.

### 7.1 Pacing Template

Every level follows this rhythm:

```
Walk-in (mood setting, 10s)
  → Encounter 1: Easy warm-up (Grunts only)
    → Scroll (breathe, environment gags, breakable props)
      → Encounter 2: Introduce new element (1 new enemy type)
        → Scroll (brief, pick-up health/weapons)
          → Encounter 3: Difficulty spike / mini-boss (combination of learned types)
            → Scroll (set piece moment — riding monorail, dodging nuclear waste)
              → Encounter 4: Full tactical (all learned types combined)
                → Camera Lock → BOSS FIGHT
                  → Victory Screen (score, rank, stats)
```

**The 70/20/10 Rule (Power Fantasy):**
- 70% of encounters: Player is dominant, mowing through enemies, feeling powerful
- 20% of encounters: Player is challenged, needs to use their full toolkit
- 10% of encounters: Player is overwhelmed, creating dramatic tension (boss phase 3, ambush waves)

### 7.2 Springfield Levels

Each level is a recognizable Springfield location with unique visual identity, environmental hazards, and interactive elements.

| Level | Location | Visual Theme | Unique Hazard | Interactive Elements | Boss |
|-------|----------|-------------|---------------|---------------------|------|
| 1 | Springfield Downtown | Daytime streets, shops, Lard Lad statue | Traffic (cars cross occasionally) | Throw enemies into Lard Lad's donut; smash Flanders' mailbox; break Kwik-E-Mart window | Sideshow Bob |
| 2 | Nuclear Power Plant | Industrial, green glow, cooling towers | Radioactive barrels (damage zones) | Push enemies into reactor pools; use control rods as weapons; ride conveyor belts | Mr. Burns in mech suit |
| 3 | Moe's Tavern → Squidport | Night scene, neon signs, waterfront | Wet floor (slip physics near dock) | Throw enemies into jukebox; use bar stools as weapons; knock enemies off the pier | Fat Tony |
| 4 | Springfield Elementary → Treehouse | Schoolyard, playground, treehouse | Playground equipment (swings hit passersby) | Use dodgeballs as projectiles; slide down banister; launch enemies off seesaw | Nelson + Jimbo + Dolph (trio boss) |
| Bonus | Treehouse of Horror | Horror-themed Springfield, dark, spooky | Zombie hands from ground (grab/slow) | Everything is different — zombie enemies, alien projectiles, haunted props | Kang & Kodos |

### 7.3 Environmental Interaction

Springfield is RICH with interactive potential. Every level should have:

- **Destructible props (minimum 5 per level):** Trash cans, newspaper stands, mailboxes, benches, parking meters. Breaking them drops health, score items, or weapons.
- **Throwable objects (minimum 2 per level):** Barrels, crates, Buzz Cola machines. Pick up and throw for massive damage + comedic ragdoll.
- **Environmental hazards (1 per level):** Traffic, radioactive waste, wet floors. Affect enemies AND players. Clever players bait enemies into hazards.
- **Landmark gags (1 per level):** Throwing an enemy into Lard Lad makes the donut fall. Hitting the Springfield Tire Fire makes it belch smoke. Breaking the "Welcome to Springfield" sign reveals the town motto changes each playthrough (Simpsons reference).

### 7.4 Level Duration

Browser-native means respecting players' time:
- **Target level length:** 4–6 minutes per level (skilled play), 7–10 minutes (casual play)
- **Encounter count:** 4 combat encounters + 1 boss per level
- **Scroll sections:** 15–20 seconds each, enough for breathing and environmental discovery
- **Total game length (first run):** 25–40 minutes across 4 levels + bonus

---

## 8. Progression & Replayability

### 8.1 Progression Model

SimpsonsKong uses the **Neo-Retro** model (SoR4 / Shredder's Revenge): per-run scoring with unlockable content and difficulty modes. Light RPG elements are layered in without overwhelming browser-game scope.

### 8.2 Score System with Style Bonuses

Score isn't just "hit enemy, get points." It's a performance rating that rewards *how* you play:

| Action | Points | Multiplier |
|--------|--------|-----------|
| Punch hit | 10 | — |
| Kick hit | 15 | — |
| Combo finisher (3+ chain) | 25 | ×combo_count |
| Grab throw | 30 | — |
| Thrown enemy hits another | 50 | — |
| Environmental kill | 75 | — |
| Dodge into counter-attack | 40 | — |
| Taunt near enemies (risk bonus) | 20 | — |
| No-damage encounter clear | +50% encounter total | — |
| Full-level no-continue | +100% level total | — |

**Style Rating (Simpsons-Themed):**

| Rating | Score Threshold | Visual |
|--------|----------------|--------|
| "Boring" | 0–999 | Gray text, sad Homer |
| "Meh" | 1,000–2,999 | White text, shrug emoji |
| "Not Bad" | 3,000–5,999 | Yellow text, thumbs up |
| "Ay Caramba!" | 6,000–9,999 | Orange text, Bart's catchphrase |
| "Excellent!" | 10,000–14,999 | Green text, Mr. Burns fingers |
| "Best. Level. Ever." | 15,000+ | Gold text, Comic Book Guy's voice |

### 8.3 Combo Meter

A visible on-screen combo counter that increases with consecutive hits:

- **Timer:** 2.5 seconds between hits before combo drops
- **Display:** "COMBO ×12" with escalating text size and color
- **Milestones:** At 5×, 10×, 20×, and 50× hits, a themed sound bite plays:
  - 5×: Homer "Woohoo!"
  - 10×: Bart "Ay Caramba!"
  - 20×: Mr. Burns "Excellent!"
  - 50×: Comic Book Guy "Best. Combo. Ever."
- **Combo break:** Taking damage resets the combo and plays Homer's "D'oh!"

### 8.4 Character Unlocks

Characters unlock through natural play, not grinding:

| Character | Unlock Condition | Rationale |
|-----------|-----------------|-----------|
| Homer | Available from start | The entry point, the mascot |
| Bart | Complete Level 1 | Early reward, encourages continued play |
| Marge | Complete Level 2 | Mid-game unlock, new playstyle to explore |
| Lisa | Complete Level 3 | Late-game unlock, highest skill ceiling character as reward for progression |

### 8.5 Difficulty Modes

Named with Simpsons flavor:

| Mode | Name | Enemy HP | Enemy Damage | Max Attackers | Unlocked |
|------|------|----------|-------------|---------------|----------|
| Easy | "Couch Mode" | 0.7× | 0.5× | 1 | Default |
| Normal | "Springfield" | 1.0× | 1.0× | 2 | Default |
| Hard | "Sideshow Bob" | 1.3× | 1.5× | 3 | Beat game on Normal |
| Nightmare | "Treehouse of Horror" | 1.5× | 2.0× | 4 | Beat game on Hard |

### 8.6 Per-Level Challenges (Shredder's Revenge Influence)

Each level has 3 optional challenges that reward stars. Stars unlock the bonus Treehouse of Horror level.

| Challenge Type | Example | Stars |
|---------------|---------|-------|
| Score threshold | "Score 10,000+ on Downtown" | ★ |
| No-damage | "Clear Power Plant without taking damage" | ★ |
| Time trial | "Beat Moe's Tavern in under 4 minutes" | ★ |
| Style | "Land a 30-hit combo on Elementary" | ★ |

**Bonus level unlock:** 8 out of 12 total stars required.

### 8.7 High Score Persistence

- **localStorage** saves: high scores per level per character, unlocked characters, unlocked difficulties, challenge stars
- **Display:** Title screen shows personal bests. Game over screen compares current run to personal best.
- **Future:** Online leaderboards (see Section 9)

---

## 9. Web Platform Constraints & Future Migration

SimpsonsKong is built for the browser (HTML5 Canvas 2D, Web Audio API, vanilla JS). This is a strength — instant play, zero friction — but it imposes constraints. This section documents what we CAN do, what we CANNOT do, and what belongs in a "Future: Native/Engine Migration" roadmap.

### 9.1 What We Can Do Well on Canvas 2D

| Capability | Approach | Quality Ceiling |
|-----------|----------|----------------|
| Character rendering | Procedural Canvas draw + sprite sheets (when ready) | Good — distinct, readable characters |
| Frame-based animation | Canvas drawImage with sprite atlas | Good — smooth 60 FPS |
| 2.5D depth sorting | Y-sort entity array each frame | Good — standard technique |
| Particle effects (light) | Object pooling, 30-50 particles max | Adequate — dust, sparks, simple bursts |
| Screen shake / flash | Camera offset + overlay rect | Good — standard game feel |
| Parallax backgrounds | Multi-layer scroll with different speeds | Good — adds depth cheaply |
| HUD / UI | Canvas text + rect overlays | Adequate — functional, styleable |
| Sound effects | Web Audio API oscillators + noise | Good — procedural SFX is surprisingly capable |
| Music | Web Audio API sequencer / oscillator patterns | Adequate — chiptune/synth style |
| Input | KeyboardEvent + Gamepad API | Good — responsive, multi-input support |
| Save/Load | localStorage | Good — simple and reliable |

### 9.2 What We CANNOT Do (or Cannot Do Well)

These are documented as **"Future: Native/Engine Migration"** items — features that would require moving beyond Canvas 2D.

| Limitation | Impact | Migration Target |
|-----------|--------|-----------------|
| **Shader effects** (glow, blur, distortion, CRT filter) | No post-processing. Hit effects limited to overlays. | WebGL / Engine (Phaser, PixiJS) |
| **Skeletal animation** (Spine, DragonBones) | All animation is frame-based. No procedural bone movement, ragdoll, or IK. | Spine runtime + WebGL renderer |
| **Full sprite sheet pipeline** | Currently all procedural draw. Importing artist-made sprites requires a sprite atlas loader. | Asset pipeline + spritesheet tool (TexturePacker) |
| **Online multiplayer** | WebSocket real-time sync is possible but complex. Latency makes action games hard over network. | Dedicated server + WebSocket / WebRTC |
| **Audio beyond Web Audio API** | No streaming music, no compressed audio decode on all browsers, no spatial audio. | Howler.js or native audio engine |
| **100+ particles / complex VFX** | Canvas 2D performance degrades past ~50-80 active draw objects with alpha. | WebGL particle system (GPU-accelerated) |
| **Advanced physics** | No Box2D-style physics. Ragdoll, cloth, fluid impossible. | Physics engine (Matter.js or Box2D.js) |
| **Complex UI** | Canvas-drawn UI is laborious. No layout engine, no text reflow. | HTML/CSS overlay UI + Canvas game |
| **Mobile touch controls** | Possible but requires custom virtual joystick implementation. | Touch input layer + virtual gamepad |

### 9.3 Pragmatic Constraints (Design Must Respect)

These constraints shape specific design decisions:

1. **Max on-screen entities:** Target 12-15 (player + 8 enemies + 4 pickups/projectiles). Beyond this, frame drops likely.
2. **Max simultaneous particles:** 40-50 at peak (impact burst). Pool and recycle aggressively.
3. **Animation frames per character:** 8-12 unique frames is practical (idle ×2, walk ×4, punch ×2, kick ×2, hurt ×1, KO ×1). More requires sprite sheets.
4. **Background layers:** 3 max (far sky, mid buildings, near street). More causes overdraw.
5. **Sound channels:** Web Audio API handles ~16 simultaneous sounds comfortably. Budget: 4 for combat SFX, 2 for UI, 2 for voice, 8 for music.
6. **Save data size:** localStorage is limited (~5 MB). Save only scores, unlocks, and settings — no replay data.
7. **Level size:** 4000-6000px horizontal scroll per level. Wider causes camera/memory issues.

---

## 10. Simpsons-Specific Mechanics

These are the features that make SimpsonsKong *uniquely Simpsons* — mechanics no other beat 'em up can replicate because they're born from the IP.

### 10.1 Homer's Donut Rage Mode

**Concept:** Donuts aren't just health pickups — they fuel Homer's signature power-up.

- **Mechanic:** Each donut picked up fills the Donut Rage Meter by 33% (3 donuts = full meter)
- **Activation:** When meter is full, player can activate Rage Mode (dedicated button or auto-activates)
- **Effects (10-second duration):**
  - Homer turns red, steam shoots from his ears (show reference)
  - +30% damage on all attacks
  - +20% movement speed
  - Belly attacks gain AOE splash (hits in a radius)
  - All attacks cause extra screen shake
  - Homer yells "WHY YOU LITTLE—!" on activation
- **Design intent:** Creates a "hoarding vs. healing" dilemma. Do you eat the donut now for 25 HP, or save it toward Rage Mode? Three donuts saved means three times you didn't heal. Pure Simpsons risk/reward.

### 10.2 D'oh! Moments (Funny Failure States)

**Concept:** Failure should be funny, not frustrating. Homer's "D'oh!" is one of TV's most iconic sounds — make it part of the game.

- **Combo drop:** Homer says "D'oh!" when hit mid-combo. The combo counter text shatters.
- **Missed grab:** Homer stumbles forward when a grab whiffs (reaching for thin air).
- **Fall into hazard:** Homer flails with cartoon legs for 0.5s before taking damage. Wile E. Coyote energy.
- **Game over:** Homer slumps on the couch (show reference). "Mmm... game over."
- **Boss kill you:** Boss does a victory taunt specific to their character. Sideshow Bob laughs maniacally.
- **Zero-damage level clear:** Screen text: "Wow, Homer actually did something right!" — Marge voice line.

### 10.3 Couch Gag Loading Screens

**Concept:** The show's iconic couch gag becomes the level transition.

- **Between levels:** A brief animated couch gag plays (the family runs to the couch in a unique way each time — just like the show).
- **Variations:** 5-10 couch gag animations that randomize. Each is 3-5 seconds.
- **Loading function:** These mask any asset loading / state transition between levels.
- **Collector incentive:** "You've seen 4/10 couch gags!" — encourages replays to see them all.

### 10.4 Springfield Landmarks as Interactive Elements

Every level should have at least one major Springfield landmark that players can interact with:

| Landmark | Level | Interaction |
|----------|-------|-------------|
| Lard Lad Donut | Downtown | Throw enemy into statue → giant donut falls, damages area |
| Kwik-E-Mart | Downtown | Break window → Apu yells "Thank you, come again!" + drops health item |
| Nuclear Cooling Tower | Power Plant | Hit control panel → steam burst damages nearby enemies |
| Moe's Jukebox | Moe's Tavern | Hit jukebox → music changes, brief enemy confusion (stun) |
| Springfield Gorge | Bonus/Transition | Throw enemy into gorge → they fall like Homer in the show (long scream, distant thud) |
| Springfield Tire Fire | Any level with it visible | Attack it → belches smoke cloud, obscures enemy vision (they wander randomly for 3s) |

### 10.5 Simpsons Quotes as Combat Barks

**Concept:** Characters quip during combat, making fights feel like scenes from the show.

**Trigger system:** Barks play on specific gameplay events with cooldowns (minimum 8 seconds between barks) to prevent annoyance.

| Trigger | Homer | Bart |
|---------|-------|------|
| Kill enemy | "Why you little—!" | "Eat my shorts!" |
| Take damage | "D'oh!" | "Ay caramba!" |
| Grab enemy | "Come here, you!" | "Don't have a cow, man!" |
| Use special | "Woohoo!" | "I'm Bartman!" |
| Low health | "Mmm... hospital food..." | "I didn't do it!" |
| Taunt | *belches* | *moons enemies* |
| Boss encounter | "Ah, nuts." | "Cool, a boss!" |

| Trigger | Marge | Lisa |
|---------|-------|------|
| Kill enemy | "Hmm!" (disapproving) | "The data supports this approach!" |
| Take damage | "Oh, Homie!" | "This is not a scholarly pursuit!" |
| Grab enemy | "You need a time-out!" | "According to my research—" |
| Use special | *frustrated growl* | *saxophone riff* |
| Low health | "I'll just have a little worry..." | "Statistically, I should've avoided that." |
| Taunt | *tuts disapprovingly* | *plays saxophone* |
| Boss encounter | "Oh, my." | "Fascinating specimen." |

### 10.6 Springfield Food as Health Pickups

No generic "turkey leg in a trash can" — every health pickup is a Simpsons food item:

| Pickup | HP Restored | Source | Simpsons Reference |
|--------|------------|--------|-------------------|
| Pink Donut | 25 HP (or Rage Meter +33%) | Crates, defeated enemies | Homer's iconic food |
| Krusty Burger | 40 HP | Barrels | The fast food staple |
| Buzz Cola | 15 HP + 3s speed boost | Vending machines | Springfield's soda brand |
| Flaming Moe | 50 HP | Moe's level only | The legendary drink |
| Duff Beer | 20 HP + slight wobble | Various | Homer's beer of choice |
| Squishee | 30 HP | Kwik-E-Mart level | Brain-freeze brief stun if at full HP (comedy) |

---

## 11. Current State vs. Vision (Gap Summary)

Based on the gap analysis and balance analysis, here is where we are relative to this GDD's vision:

| GDD Section | Current State | Gap | Priority |
|-------------|--------------|-----|----------|
| Basic combo (PPK) | ✅ Damage scaling works | Need combo counter UI, hit feedback | P1 |
| Grab/throw | ❌ Not implemented | Full system needed | P2 |
| Special moves | ❌ Not implemented | Health-cost specials, 3 per character | P2 |
| Dodge roll | ❌ Not implemented | Core defensive mechanic | P1 |
| Jump attacks | ⚠️ Implemented but OP | Needs landing lag, DPS rebalance | P1 |
| Weapon pickups | ❌ Not implemented | Weapon entities + durability | P2 |
| Super meter | ❌ Not implemented | Meter system + character supers | P2 |
| Taunt mechanic | ❌ Not implemented | Animation + meter fill + vulnerability | P2 |
| Enemy vocabulary | ⚠️ 2 types (grunt, tough) | Need 6+ types | P2-P3 |
| Boss fights | ❌ Not implemented | Multi-phase boss system | P2 |
| Level variety | ⚠️ 1 level (Downtown) | Need 4 levels + bonus | P3 |
| Environmental interaction | ❌ Not implemented | Destructibles, hazards, landmarks | P2-P3 |
| Characters (Homer) | ✅ Playable | Needs art overhaul, specials, rage mode | P2 |
| Characters (Bart, Marge, Lisa) | ❌ Not implemented | Full character builds | P3 |
| Score system | ⚠️ Basic scoring exists | Style ratings, combo bonuses needed | P1-P2 |
| Difficulty modes | ❌ Not implemented | 4 named difficulties | P2 |
| Combat feel (hitlag, VFX, SFX) | ⚠️ Minimal | Hitlag, particles, sound variation | P1 (highest impact) |
| Donut Rage Mode | ❌ Not implemented | Homer's signature mechanic | P2 |
| D'oh! Moments | ❌ Not implemented | Failure humor system | P2 |
| High score persistence | ❌ Not implemented | localStorage save/load | P0 |

---

## 12. Design Authority Notes

These are binding design decisions that the team should not override without consulting the Game Designer:

1. **Comedy is non-negotiable.** If a mechanic isn't fun or funny, redesign it. Never ship something that feels generic.
2. **The PPK combo is the foundation.** All combat balance flows from the punch-punch-kick chain. Don't change its timing without full rebalance.
3. **Health-cost specials, not mana/MP.** The SoR2/SoR4 model (spend HP, recover by attacking) is the core risk/reward loop. Do not replace with a separate resource bar.
4. **Two attackers max on Normal.** Enemy throttling is a design choice, not a performance compromise. Readable combat over chaotic pile-ons.
5. **Each character must feel different in 10 seconds.** If a character feels like "Homer but faster," the design has failed. Rebuild.
6. **Levels are 5-7 minutes, not 15.** This is a browser game. Respect session length. Pack density into short experiences.
7. **Jump attacks must not be dominant.** Balance analysis shows 50 DPS aerial vs. 39 DPS ground is unhealthy. Landing lag and DPS tuning are required.
8. **Environmental interaction is mandatory per level.** Every level must have destructibles and at least one landmark gag. Springfield is a playground, not a corridor.
9. **Donut Rage Mode ships with Homer.** It's his signature. Do not defer it past the character being "complete."
10. **D'oh! moments ship before victory celebrations.** Funny failure is more important than flashy success. The player should laugh when they mess up.

---

*This Game Design Document is a living document. It will be updated as the team builds, playtests, and iterates. All mechanic decisions should be validated against these design pillars and principles.*

*Created by Yoda — SimpsonsKong Game Designer*
