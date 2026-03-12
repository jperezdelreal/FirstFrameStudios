# SKILL: Universal Game Design Fundamentals

The science and art of creating systems that players *want* to engage with. This skill applies to any genre, any platform, any IP — because the human mind works the same way regardless of whether you're designing a match-3 puzzle, a 3D action game, or a turn-based RPG. Game design is applied psychology plus interaction design plus systematic iteration.

---

name: "game-design-fundamentals"
description: "Core game design frameworks, player psychology, difficulty design, pacing, rewards, communication, and validation — genre-agnostic"
domain: "game-design"
confidence: "low"
source: "research across reference games (Celeste, Hades, Hollow Knight, Portal, Tetris, Dark Souls, BotW) + core studio principles (Player Hands First, Measure the Fun, Research Before Reinvention)"

---

## When to Use This Skill

- **At the start of any new project:** Use this as a mental checklist before writing a design doc
- **When designing a core mechanic:** Use MDA framework to ensure mechanics → dynamics → aesthetics flows
- **When tuning difficulty:** Use difficulty curve patterns and challenge design lens
- **When a feature feels "off" but you can't articulate why:** Cross-reference against player psychology and feedback loop patterns
- **When reviewing another designer's work:** Use this as a design critique framework
- **When building progression systems:** Use player psychology sections (mastery curves, intrinsic vs extrinsic motivation, loss aversion)
- **When a genre is new to the studio:** Use genre-specific lenses to analyze reference games
- **Before shipping:** Use anti-patterns checklist to identify design debt before players experience it

## When NOT to Use This Skill

- **Level design specifics** — Use genre-specific level design skills (platformer level grammar, dungeon topology, etc.)
- **Technical implementation** — Use engine-specific or code architecture skills
- **Narrative structure** — Use story/writing skills (out of scope for game design fundamentals)
- **Visual/audio style** — Use 2D art, 3D art, procedural audio skills
- **UI/UX specifics** — Use ui-ux-patterns skill (this covers game design psychology for mechanics, not menus)

---

## 1. Core Design Frameworks

These are the thinking tools that organize chaos into coherent systems.

### 1.1 MDA Framework: Mechanics → Dynamics → Aesthetics

**The Model:** Every game design flows in one direction:

```
MECHANICS (what you build)
    ↓
DYNAMICS (what emerges in play)
    ↓
AESTHETICS (what the player *feels*)
```

**Mechanics** are the rules and systems. In chess: move rules, capture rules, board constraints. In Mario: jump mechanics, gravity, collision rules.

**Dynamics** are the behaviors that emerge from mechanics in player hands. Chess mechanics generate dynamics like "tempo exchange," "pin tactics," "weak squares." Mario mechanics generate dynamics like "precise platforming," "risk/reward jumps," "rhythm of approach and leap."

**Aesthetics** are the emotional/psychological responses. Chess produces: tension, competition, mastery. Mario produces: joy, flow, achievement.

**Critical Rule:** You cannot design aesthetics directly. You design mechanics, playtesting reveals dynamics, and dynamics create aesthetics. If you say "I want the player to feel scared" and design a big monster, you haven't designed fear — you've made a guess. Play it. If the monster is slow and predictable, the dynamics don't generate fear aesthetics. Adjust mechanics, retest.

**Example (Celeste):**
- **Mechanic:** Dash cooldown resets on ground contact
- **Dynamic:** Players discover they can dash-jump-dash in sequence, creating upward chains
- **Aesthetic:** "I am masterful, I am flying, I am in control" (agency + competence)

**Example (Dark Souls):**
- **Mechanic:** Stamina cost for every action (attack, dodge, block), stamina refill is slow
- **Dynamic:** Every action is a commitment with real consequence; healing costs time; running away burns stamina
- **Aesthetic:** "This is deadly serious, I must plan, every choice matters" (tension + consequence)

**How to Use:** Before implementing a feature, write:
1. What mechanics am I building?
2. What dynamics do I expect to emerge?
3. What aesthetics do I want the player to experience?
4. Then playtests: Do the dynamics actually emerge? Do those dynamics produce those aesthetics?
If not, you're tuning the wrong thing.

---

### 1.2 The Core Loop Concept

The core loop is the **smallest repeating unit of gameplay** — what the player does every 30 seconds, 5 minutes, and 30 minutes.

**The 30-second loop** (micro-loop):
- Press button → thing happens → feedback → ready for next button press
- Example (Mario): Run → jump → land → run again
- Example (Tetris): Piece falls → rotate → place → next piece spawns
- Example (Combat): Attack → recover → move → attack again
- This loop is your **core interaction**. If it doesn't feel good, nothing else matters.

**The 5-minute loop** (activity loop):
- A complete "encounter" or "challenge" from start to resolution
- Example (Mario): Clear one level
- Example (Tetris): Survive one wave of increasing speed
- Example (Combat): Fight one enemy or small group
- This loop gives the 30-second loop context and stakes.

**The 30-minute loop** (session loop):
- A complete "play session" — the reason the player opened the game today
- Example (Mario): Complete 3–5 levels with increasing challenge
- Example (Tetris): Play until death, high score achieved or not
- Example (Combat): Wave of enemies, intermission, next wave, boss encounter
- This loop determines pacing, learning curve, and when the player naturally stops.

**How to Use:**
1. **Identify your core loop at each scale.** If you can't describe the 30-second loop in one sentence, your core mechanic isn't clear.
2. **Prototype the 30-second loop first.** Get it feeling right before adding layers.
3. **Make sure each loop layer respects the previous layer.** A 30-minute loop that overloads the 30-second loop (forcing constant attention changes) will exhaust players.
4. **Pacing problem diagnosis:** If players say "this is exhausting" → your 30-minute loop might be too intense. If they say "this is boring" → your 5-minute loop might be too repetitive.

---

### 1.3 Feedback Loops: Positive, Negative, Rubber Band

Every system in a game creates feedback loops. Understanding which type you're creating is essential.

**Positive Feedback Loop (Snowball):**
- Success produces more success. Getting ahead makes you MORE ahead.
- **Example:** In an RTS, more resources → stronger army → win more fights → capture more resource nodes → exponentially stronger army
- **Use when:** You want momentum to feel powerful, or you want player skill to compound ("if you're good, you get MORE good")
- **Risk:** Runaway winner. First death can be fatal; comeback feels impossible.
- **Mitigation:** Pair with negative feedback elsewhere, or use it intentionally for difficulty scaling (expert mode snowballs faster)

**Negative Feedback Loop (Rubber Band / Equilibrium):**
- Success reduces your future success. You're pulled back toward balance.
- **Example:** Mario Kart: losing players get better items (blue shells, speed boosts), winning players get bananas and coins. The leader is targeted, the trailing players get help.
- **Use when:** You want competitive fairness, or you want to reward skilled players *tactically* without letting them run away with the game
- **Risk:** Can feel manipulative ("the game cheated me"). Player agency feels reduced.
- **Mitigation:** Make the rubber band effects transparent, or frame them as thematic (harder difficulty tier unlocks for better players)

**How to Combine Them:**
- **Local snowball, global equilibrium:** In Mario Kart, during a single race your lead creates a snowball (first place gets first to the finish) BUT across the tournament, losing races pull you back toward average standing. Both loops coexist.
- **Skill ceiling through positive feedback:** In fighting games, each successful hit is a positive feedback (damage → knockdown → combo opportunity). Skilled players snowball within a single match. But **between** matches, the ranking system (negative feedback) keeps you playing opponents at your skill level.

**Design Rule:** Every design question about "balance" usually has a hidden question: "Which feedback loops serve my design goals?" Answer that, and balance becomes clear.

---

### 1.4 Risk/Reward Design: Making Choices Meaningful

A choice is only meaningful if both paths have different values and different costs.

**Structure of a Risk/Reward Decision:**

```
Safe Path:        Guaranteed outcome, low/medium reward
  Example:        Block (guaranteed defense, no damage output)
  
Risky Path:       High potential reward, potential cost
  Example:        Attack (deal damage, but vulnerable to counterattack)
  
Consequence:      Both choices must feel valid in some context
  Example:        Block when outnumbered; attack when you have time
```

**The Anti-Pattern:** If one path dominates (e.g., attacking is always better than blocking), the choice disappears. Players aren't making decisions — they're following the optimal path.

**How Risk/Reward Shapes Gameplay:**

- **In combat:** Attack costs stamina but deals damage. Dodge costs stamina but avoids damage. Both are costs; both are valid. Context determines the right choice.
- **In platformers:** The safe path hugs the wall (slow, safe). The risky path cuts across spikes (fast, dangerous). Skilled players cut across; learners hug walls. Both are valid.
- **In puzzles:** The obvious solution works but takes 10 steps. The clever solution takes 3 steps but requires seeing a non-obvious connection. Reward cleverness; don't punish the obvious path.
- **In RPGs:** Spend resources now (healing items, buffs) for safety, or save for a critical moment and risk losing? Both valid.

**Design Process:**
1. Identify the core decision the player makes every minute.
2. Make sure both choices (safe/risky, fast/safe, etc.) have real value.
3. Use difficulty tuning to change the ratio, not to eliminate one choice.
4. Playtest: Do players feel they're making *meaningful* choices, or following a script?

---

## 2. Player Psychology: Why Players Care

Game design is applied psychology. These are the invisible forces that keep players engaged.

### 2.1 Flow State: The Balance Between Challenge and Skill (Csikszentmihalyi)

**The Model:**
```
         Challenge
              ↑
              │      FLOW
              │    (Challenge = Skill)
              │   ╱─────────────────╲
              │  ╱  Too hard: PANIC   ╲
              │ ╱                      ╲
              │                   Too easy: BOREDOM
              └──────────────────────────→ Player Skill
```

**Flow state** is when challenge matches skill exactly. Not too hard (which produces anxiety and quits), not too easy (which produces boredom and quitting).

**Critical insight:** Flow is a *moving target*. As the player improves (skill increases), the game must introduce new challenges to maintain flow. This is why progression matters.

**How to design for flow:**
1. **Baseline difficulty:** Make the first 10% of your game feel slightly easy. Let players build confidence and learn the core loop without panic.
2. **Graduated challenge:** Every 5–10 minutes of play, introduce a small new mechanic or increase difficulty slightly.
3. **Skill gates:** Some content is locked until the player has demonstrated the prerequisite skill (beat the tutorial level before the hard level). This prevents flow-breaking "wall" difficulty spikes.
4. **Optional challenge:** Offer easier and harder paths. The normal path maintains flow for average players. Hard mode for skill seekers; easy mode for learning.

**Testing:** Playtesting question: "At what point did you feel challenged but not overwhelmed?" Compare across players. If some felt bored and others felt panicked at the same level, your difficulty tuning is uneven.

---

### 2.2 Intrinsic vs Extrinsic Motivation: Why Players *Want* to Play

**Extrinsic motivation:** You play because you *get something* (points, rewards, achievements).
- Fast-acting but shallow. Player stops when rewards stop.
- Examples: Loot in RPGs, currency in mobile games, achievements in competitive games
- Risk: If you balance rewards poorly, players feel "grindy" (forced to repeat for reward)

**Intrinsic motivation:** You play because the *act itself* is satisfying.
- Slow-acting but deep. Players keep playing because they love the interaction.
- Examples: The feel of a jump in a platformer, the satisfaction of solving a puzzle, the thrill of a risky move working perfectly
- Risk: If intrinsic systems are weak, extrinsic rewards feel hollow

**The Mix:**
- **Early game (first hour):** Extrinsic rewards carry the game while intrinsic systems teach themselves. New players don't yet understand why the jump feels good; the reward for landing it helps.
- **Mid-game (hours 2–10):** Intrinsic systems mature. Extrinsic rewards shift from "why am I playing" to "cool milestone unlocked."
- **Late game (hours 10+):** Intrinsic systems are the anchor. Extrinsic rewards are cosmetic or provide new challenges (not the reason to play).

**Design rule:** If your game relies 100% on extrinsic rewards, it's a chore. If it relies 100% on intrinsic systems with no feedback, it feels empty. The mix depends on your genre and target audience.

**How to diagnose problems:**
- Players complain "grinding is boring" → extrinsic reward loops are too repetitive or sparse
- Players complain "this mechanic feels pointless" → intrinsic feedback is missing (see game-feel-juice skill)
- Players quit after unlocking reward → reward was extrinsic alone; intrinsic system wasn't engaging

---

### 2.3 Loss Aversion: Why Losing Feels 2x Worse Than Winning Feels Good

**The Fact:** Humans experience loss roughly twice as intensely as equivalent gains (Kahneman & Tversky).

- Gaining 100 points: "Nice!"
- Losing 100 points: "ARGH!" (stronger emotion)

**This matters in games because:**
- Death that costs progress is emotionally loaded. The player doesn't think "I lost 5 minutes of progress"; they think "I FAILED."
- Permadeath is not balanced by "if you win, great reward." The loss is heavier.
- Resource loss (spending mana, ammo, health potions) feels worse than equivalent gain.

**How to design with loss aversion:**
1. **Make loss meaningful but fair.** If the player's loss is their fault (they played badly), loss aversion makes them want to retry (good). If loss feels arbitrary (unfair enemy, bad RNG), loss aversion makes them quit (bad).
2. **Avoid permanent loss in early game.** Permanent death (classic roguelike) is fine *if* meta-progression exists (unlocks, permanent upgrades). Otherwise, new players feel betrayed.
3. **Use loss aversion as pacing.** "You're about to lose all your ammo if you waste it" creates tension. Loss aversion makes players think twice.
4. **Mitigate with checkpoints/saves.** Permadeath between checkpoints (40 minutes) is brutal. Permadeath within a checkpoint (5 minutes) is fair. Permadeath with auto-saves (no way to fail accidentally) is forgiving.

**Anti-pattern:** "We made permadeath hardcore mode." If you didn't test whether new players find hardcore fun or just frustrating, you've created loss-aversion tilt (where the game feels unfair because the player blames external factors).

---

### 2.4 Mastery Curves: Making Players Feel They're Getting Better

**The Reality:** Players don't *need* to get better to enjoy a game. But they *want* to feel they're getting better.

**How mastery curves work:**
1. **Early game:** Learning. Frequent "aha moments" (new mechanic unlocked, new move discovered, suddenly a strategy clicks).
2. **Mid-game:** Refinement. Fewer new discoveries; more practice with known systems. Difficulty increases require timing/precision, not new knowledge.
3. **Late game:** Mastery. Player has learned everything. Difficulty now comes from tight execution, resource optimization, or facing new enemy patterns that require adapting old knowledge in new ways.

**Design pattern (Celeste model):**
- **Levels 1–3:** Introduce mechanics one at a time. Each level teaches something new, then lets the player practice it.
- **Levels 4–6:** Combine mechanics. Now the player must apply what they learned in new contexts (this is where "aha" moments spike).
- **Levels 7–9:** Master the combination. Same tools, harder precision required.

**Teaching the progression:**
- **Visible skill gates:** "You can now dash-jump." Make this explicit. Players feel achievement.
- **Stat transparency:** Show attack damage, cooldown reductions, DPS scaling. Players see how they're improving numerically.
- **Difficulty adaptation:** If a player does *too well* (boss beaten with 95% HP), offer harder difficulty. Make progression feel natural, not hard-capped.

**Anti-pattern:** "The game gets harder but the player doesn't learn any new moves." This feels like the game is cheating, not like the player is failing.

---

### 2.5 The "One More Try" Feeling: What Creates Compulsive Replay

This is the feeling that makes a player say "just one more round" at 2 AM.

**What generates it:**
1. **Short loop with quick feedback:** Tetris, Match-3, roguelike runs. Each loop is 5–10 minutes; death is quick; retry is instant. Fast iteration creates compulsion.
2. **Meaningful failure:** The death taught something. "Oh, I should have gone left instead of right." This frames death as learning, not punishment.
3. **Progression that compounds:** Each run gets slightly stronger (unlocks, meta-progression, or cumulative skill). Session 2 is better than session 1.
4. **Luck variance in the loop:** Even perfect play sometimes fails because of RNG. This means even a skilled player can fail, which means retry feels necessary.
5. **Visible goal just out of reach:** Beat my high score by 500 points. Get to floor 5 instead of floor 4. "Just one more try" is rational.

**How to implement:**
- **Keep core loop tight:** If one run takes 40 minutes, "one more try" means 80 minutes (players won't say this).
- **Make death fast:** Don't make the player watch a 20-second death animation. Fail → try again in 2 seconds.
- **Show why they failed:** Display enemy health, remaining waves, or "you died 3 times on this room" so retry feels directed.
- **Variable rewards:** Sometimes the random spawn gives you the perfect tool to beat a challenge. This positive variance in luck creates "wow, I almost had it!" moments.

**Anti-pattern:** "I added prestige mechanics to make players keep playing." Prestige (reset progress to earn a permanent bonus) creates *obligations*, not compulsion. Players feel trapped, not motivated. Compulsion must feel intrinsic.

---

## 3. Difficulty & Challenge Design

Difficulty is not a slider. It is a design tool that communicates your game's genre identity and teaches systems.

### 3.1 Difficulty Curves

**Linear Curve:**
```
Challenge
   ↑
   │        ╱─────────
   │      ╱
   │    ╱
   └───────────────→ Time
```
Difficulty increases steadily. Safe, predictable, good for tutorials and gradual learning.
**Use for:** Casual games, story-heavy games where steady challenge supports narrative pacing, puzzle games.

**Exponential Curve:**
```
Challenge
   ↑
   │           ╱────
   │         ╱╱
   │       ╱
   └───────────────→ Time
```
Difficulty increases slowly at first, then rapidly. Good for games where you want a "wall" — a moment where new mechanics finally click and suddenly you're flying.
**Use for:** Roguelikes (early runs are forgiving, skilled players face brutal late game), skill-based games (learn mechanics early, execution matters late).

**Sawtooth Curve:**
```
Challenge
   ↑
   │  ╱╲  ╱╲  ╱╲  ╱╲
   │ ╱  ╲╱  ╲╱  ╱
   └───────────────→ Time
```
Repeated cycles of ease and challenge. You learn a new mechanic (easier), then face a challenge with it (harder), then reset. Excellent for tutorial and early game.
**Use for:** Story campaigns with multiple acts, level-based games (beat easy level, then hard level, then rest), structured progression.

**Custom Curve (Game-Specific):**
Some games have difficulty shaped by their content. A boss-rush game spikes at every boss, then eases. A roguelike spikes on certain enemies or builds. Design the curve to match the *content*, not just the clock.

**How to implement:**
- **Know your curve.** Before shipping, chart it. "Is difficulty linear, exponential, sawtooth, or custom?" If you don't know, the player probably feels confused.
- **Pacing problem diagnosis:** If players quit at the 30-minute mark, check your difficulty curve. Exponential curves spike too hard around that mark.
- **Tuning patience:** Give players 20–30 minutes before a real difficulty spike. Confidence needs time to build.

---

### 3.2 Dynamic Difficulty Adjustment (DDA)

**What:** The game automatically adjusts challenge based on player performance.

**When to use:**
- **Single-player casual games** where player skill varies wildly and you want everyone to finish
- **Story-focused games** where challenge must not interrupt narrative pacing
- **Skill-agnostic games** (e.g., mobile games with mixed skill bases)

**When NOT to use:**
- **Skill-based communities** (roguelikes, fighting games, speedrunning games). Players want fixed difficulty because skill means something.
- **Competitive games.** Rubber-banding feels like the game is cheating.
- **Games where learning IS the content** (Dark Souls, Celeste). Challenge must be consistent so the player learns the optimal path.

**Examples:**
- **Good DDA:** In a story platformer, if the player dies 5 times on a level, reduce obstacle density without telling them. They don't notice; they just "figure it out."
- **Bad DDA:** In a roguelike, if the player is doing too well, spawn harder enemies. The community will hate you for "balancing" them out of their run.

**Implementation:**
```
Measure: Win rate, death rate, time-to-complete on recent attempts
Adjust: If win rate > 70%, increase challenge
        If win rate < 30%, decrease challenge
        Target: 40-50% win rate = player operating at skill edge
```

**Rule:** DDA must be invisible or thematic. "You're doing well, so enemies get harder" is transparent and can feel manipulative. "You unlocked the harder biome" feels like progression.

---

### 3.3 "Difficulty is a Design Tool, Not a Slider"

This is the core principle of difficulty design.

**Anti-pattern:** "Let's add an Easy/Normal/Hard slider that just multiplies enemy health and damage."

Result: All three difficulties feel the same (just spongy enemies), and Hardcore players feel cheated because "skilled play" only saves time, not challenge. Easy players feel bad because they still die to the same patterns.

**Better pattern:** Difficulty changes *design*, not just numbers.

**Example (Combat):**
- **Easy:** Fewer enemies, simpler attack patterns, wider windows to dodge
- **Normal:** Baseline enemies, mixed patterns, standard windows
- **Hard:** More enemies, faster attacks, narrower windows, new attack types, enemies coordinate

Now each difficulty is a *different game*. Easy teaches the core pattern. Normal is the intended experience. Hard is a remix that requires mastery.

**Example (Platformer):**
- **Easy:** More checkpoints, wider platforms, friendly obstacles (e.g., moving platforms that help)
- **Normal:** Standard checkpoint frequency, standard platform width, neutral obstacles
- **Hard:** Fewer checkpoints, narrower platforms, hostile obstacles (moving platforms that hurt, spikes), new obstacle types

**Design rule:** If your difficulty modes don't change *what the player does*, they're just padding. Rewrite the level design, the enemy behaviors, the obstacle placement. Make each difficulty a unique design.

---

### 3.4 Teaching Through Gameplay: The Nintendo School

The best game design never tells the player "press jump to jump." The level design itself teaches.

**Principle:** Every obstacle teaches a lesson before it kills you.

**Example (Super Mario Bros. NES):**
- The Goomba is the *first* enemy. It walks left, and immediately kills the player.
- The player learns: "Enemies hurt. Jump over them."
- Every Goomba encounter after that reinforces the same lesson in slightly different contexts (on platforms, near gaps, etc.).

**Example (Portal):**
- The first test chamber has no threats. The player learns how portal placement works.
- Second chamber adds pressure plates (slight time pressure). The player learns: "Portal placement can solve timed problems."
- Third chamber removes the ability to see one portal. The player learns: "I can solve problems by placing portals I can't see."
- By the tenth chamber, the player is layering three concepts together — but each was taught alone first.

**How to implement:**
1. **Introduce one mechanic per level or section.** Don't combine new mechanics; teach them separately.
2. **Force the player to use it correctly.** The obstacle is designed so that the only solution is the new mechanic.
3. **Vary the context.** Once learned, show the same mechanic in different situations (different terrain, different pressure, etc.).
4. **Only combine mechanics once each is learned.** Combination levels come after both individual levels.

**Anti-pattern:** Tutorial that *tells* the player "here's how to dash" vs level that *forces* the player to discover "I can dash to cross this gap." Teaching is visceral and remembered. Telling is forgotten.

---

### 3.5 The "Hard But Fair" Principle

**Principle:** Every death must feel like the player's fault, not the game's fault.

**What makes a death feel unfair:**
- Enemy attack with no telegraph (you couldn't see it coming)
- Invisible hitbox (you thought you were safe)
- RNG failure outside player control (random spike damage, random enemy spawn)
- Timing-required precision with latency/input lag (player presses button, 100ms later something happens)
- Punishment before teaching (the first encounter kills you instantly with no warning)

**What makes a death feel fair:**
- Enemy attack with clear telegraph (arm raise, sound cue, visual cue)
- Visible hitbox (player sees the danger zone)
- Player had agency (they could have dodged, they chose not to)
- Consequence is proportional (one mistake = one death, not instant game over)
- Teaching before punishment (the first encounter shows the pattern; the second encounter punishes failure)

**How to implement:**
1. **Telegraph every threat.** If an attack is coming, the player should know 0.5–1 second before it lands.
2. **Test controls responsiveness.** Input latency > 100ms makes death feel unfair (the player pressed dodge; the game didn't listen fast enough).
3. **Provide recovery windows.** After most attacks that hit, the player should have a moment to dodge the follow-up. No instant-death combos without warning.
4. **Communicate hitboxes.** Make danger zones visually obvious (red glow, sparks, shadow, etc.).
5. **Let players learn without punishment.** The first encounter with a new attack should not kill instantly. Show the pattern, then raise stakes.

**Testing:** Playtesting question: "On a death, did you feel it was your mistake, or the game's?" If >30% of deaths feel unfair, your telegraphing or hitboxes are unclear.

---

## 4. Pacing & Rhythm: The Heartbeat of a Game

Pacing determines whether a game feels relentless or drags.

### 4.1 Tension/Release Cycles

Games breathe. Action → rest → action → bigger action → bigger rest.

**Micro-cycle (1–2 minutes):**
```
Attack phase (intense): Player faces enemies, high challenge
     ↓
Rest phase (ease): Clear the room, enemy approaches slowly, or safe zone
     ↓
Attack phase (higher intensity): More enemies, harder pattern
```

**Why this matters:** Constant action fatigues. Constant rest bores. The cycle between them is what creates engagement.

**Example (Beat 'Em Up):**
- Wave 1: 3 weak enemies (action)
- Brief pause (rest)
- Wave 2: 5 medium enemies (action, harder)
- Brief pause (rest)
- Wave 3: 2 strong enemies + minions (action, hardest)
- Victory screen (rest, celebration)

**Example (Platformer):**
- Spike gauntlet (tension): Navigate hazards
- Safe platform (release): Catch breath, see next challenge
- Bigger spike gauntlet (tension, escalated)
- Boss platform (release, safety before boss)

**How to tune:** Playtesting: Does the game ever feel "always on"? (tension too long) Or "nothing matters"? (rest too long) The ratio should feel like breathing, not drowning.

---

### 4.2 Pacing Diagrams

Map emotional intensity across your game.

**Template:**
```
Intensity
   ↑
10 │                                ╱─────╲  (Final Boss/Climax)
9  │                              ╱       ╲
8  │                    ╱───────╲╱         ╲
7  │        ╱─╲        ╱                    ╲
6  │      ╱   ╲──────╱                      ╱
5  │  ╱─╲╱                                 ╱
4  │╱                                   ╱
3  │───────────────────────────────────
   │
   └─────────────────────────────────────→ Time
     Intro    Act 1    Act 2    Act 3  Outro
```

**What this shows:**
- Intro: Low intensity (introduction, learning)
- Act 1: Gradual escalation
- Act 2: Peak intensity with a breather
- Act 3: Final escalation toward climax
- Outro: Deescalation (win lap, victory screen)

**How to use this:**
1. **Sketch your pacing diagram *before* designing levels.** This forces you to think about the overall arc.
2. **Identify peaks and valleys.** Where should the player feel safest? Where should they feel most threatened?
3. **Tune the ratio.** If the diagram is too spiky, the game feels chaotic. If it's too flat, the game is boring.
4. **Map to your game structure.** Levels, waves, chapters, story beats — align intensity with structure.

**Anti-pattern:** Linear difficulty curve is not the same as good pacing. Linear means "gradually harder," but it doesn't account for player fatigue or dramatic structure.

---

### 4.3 The "Power Fantasy Arc": Start Weak, Grow Strong, Face Overwhelming Odds, Triumph

This is a universal narrative structure that also applies to game design mechanics.

**The Arc:**
1. **Act 1 (Weak):** Player is underpowered. Teach core mechanics. One enemy is a challenge.
2. **Act 2 (Growing):** Player gains tools, skills, unlocks. Scaling begins. Three enemies are manageable.
3. **Act 3 (Overwhelmed):** New enemy types or boss that is genuinely threatening despite player power-up. "I was strong, but this is stronger."
4. **Act 4 (Triumph):** Player discovers a new technique or tool, or masters existing systems at peak level. Suddenly the overwhelming enemy is beatable.

**Why this works:** It mirrors the hero's journey. It gives progression stakes (something to lose). It prevents power scaling from creating "one-shot everything" boredom.

**Example (Hollow Knight):**
- Early game: You have 5 health, one attack, no special moves. Husks take 5 hits.
- Mid-game: You have 10 health, upgraded attack (2 hits), special moves. Tougher enemies take 8–10 hits but are manageable.
- Late-game: Bosses have 100+ health pools, multi-phase patterns, and new attack types you've never seen.
- End-game: With all upgrades and mastery, you can do it. The boss is still formidable, but you're strong enough.

**Example (Dark Souls):**
- Start: 10 stamina, 400 health, basic sword. Enemies can 2-shot you.
- Mid: 40 stamina, 1000 health, powerful weapons. You can 3-shot most enemies.
- Late: Endgame bosses have 5000 health pools and intricate attack patterns.
- Mastery: You've learned the patterns so well that even with their health pools, you know when to dodge, when to attack. The challenge shifts from "they kill me" to "execution matters."

**How to design:**
1. **Track player power growth numerically.** Damage scaling, health increases, tool unlock schedule.
2. **Track enemy power growth.** Boss health, attack damage, pattern complexity.
3. **Make sure they don't sync perfectly.** There should be moments where the enemy is ahead (creating tension) and moments where the player is ahead (creating power fantasy).
4. **Climax should feel *earned*.** If the final boss dies too easily, the power fantasy falls apart. If it feels impossible, the player gave up before triumph.

---

### 4.4 Session Design: Respecting the Player's Time

**Principle:** The player opened your game for X minutes. Respect that time window.

**Session windows:**
- **Mobile/Casual:** 5–15 minutes. The player is on a break.
- **Console/PC Afternoon:** 30–90 minutes. The player cleared their schedule.
- **PC Evening:** 90–180 minutes. Deep engagement session.

**Design accordingly:**
- **5–15 min game:** One self-contained loop should complete. No 2-hour story arcs. Checkpoints are pointless (save on exit).
- **30–90 min game:** One act or chapter should complete. Save points at logical breaks (after boss, at level start). Player should feel closure on one session.
- **90+ min game:** Multiple options. Long play session available; also, quit-safe design so a break at any point feels acceptable.

**Quit-safe design:**
- Auto-save frequently (every 5 minutes of progress minimum)
- Allow quit at any time without punishment (no "save or lose progress")
- Provide narrative/mechanical closure at natural points (after boss, end of level, story beat)
- If you're asking for 2 hours, make sure the player *wanted* to play 2 hours, not trapped by sunk time

**Anti-pattern:** "You can only save at these 3 specific points, and they're 1 hour apart." This punishes the player for having a life. Result: frustration and quitting.

---

## 5. Reward Systems (Genre-Agnostic)

Rewards are not just numbers. They communicate value, competence, and progress.

### 5.1 Types of Rewards

**Progression Unlocks:**
- New abilities, tools, moves, areas
- **Why it works:** Unlocks change what the player *can do*, expanding possibility space
- **Example:** Ability to double-jump unlocks platforms previously unreachable

**Cosmetics:**
- Skins, colors, visual effects, emotes
- **Why it works:** Allows self-expression without breaking game balance
- **Example:** Character costume, weapon appearance, custom idle animation

**Power Growth:**
- Increased damage, health, speed, cooldown reduction
- **Why it works:** Makes the player feel stronger; previous challenges become easier
- **Example:** Leveling up, equipment upgrades, skill point allocation

**Narrative Reveals:**
- Story progression, character development, world building
- **Why it works:** Humans are story engines; revelation drives engagement
- **Example:** Beating a boss unlocks dialogue, a letter, or context for the next area

**Skill Mastery:**
- The satisfaction of *doing* something difficult well
- **Why it works:** Intrinsic reward from competence
- **Example:** Landing a 10-hit combo, solving a puzzle in one elegant move, speedrunning a previously hard level

**Scores/Metrics:**
- Numbers that track performance (high score, fastest time, accuracy %)
- **Why it works:** Gives concrete feedback on improvement
- **Example:** Your combo counter, kill count, survival time

**How to design:** Mix reward types per session. Early game leans on progression unlocks (teaching). Mid-game leans on power growth and narrative. Late game leans on cosmetics and skill mastery (intrinsic systems mature).

---

### 5.2 Variable Ratio Reinforcement (The Slot Machine Principle)

This is the psychology of why slot machines are addictive, and why it matters for game design.

**Fixed Ratio:** "Every 10 actions produces a reward." Predictable, boring.

**Variable Ratio:** "On average, every 10 actions produces a reward, but sometimes it's 3 actions, sometimes 15." Unpredictable, engaging.

**Why variable ratio is more engaging:**
- **Anticipation:** You never know when the next reward is coming. This keeps you attentive.
- **Surprise:** When the reward comes early, it feels like a lucky streak.
- **Resilience:** When reward is delayed, you're more patient because "the next one might be soon."

**How to use in game design:**
- **Loot games:** Don't make every 10th enemy drop a guaranteed reward. Make it probabilistic. 10% chance per enemy creates variable ratio.
- **Combo systems:** "Every 10 hits is a combo bonus" is boring. "Combos reset randomly" makes the player stay engaged.
- **Progression:** "The next 3 levels all have mid-boss bosses" is predictable. Mix it: some levels, no boss; some levels, surprise boss.

**Danger:** Variable ratio is *addictive*, which is powerful and dangerous. Mobile games abuse this (cosmetic loot boxes with variable rewards = slot machine design). Use it intentionally, not manipulatively. If you're using variable ratio to keep players playing against their will, that's predatory, not engaging.

---

### 5.3 Currency Design: Single vs Multiple Currencies

**Single Currency** (e.g., "Gold"):
- Simpler economy
- All progression unified
- Risk: Everything has a price, which can feel mercenary
- **Use for:** Games where economy is NOT the focus (beat 'em ups, platformers)

**Multiple Currencies** (e.g., "Gold" for weapons, "Gems" for cosmetics, "XP" for leveling):
- Complex economy allows different progression paths
- Cosmetics feel separate from power (player isn't forced to choose between looking good and being strong)
- Risk: Confusing for new players; tempts predatory monetization (cosmetics cost real money)
- **Use for:** Games where player agency through economy matters (RPGs, strategy games, looter games)

**Design rule:** If you're making multiple currencies, make the relationship clear.
- **Earned currencies** (gold from fighting enemies) for power progression
- **Cosmetic currencies** (gems from side quests or cosmetic-only activities) for appearance
- **Battle Pass currency** (separate currency unlocked by gameplay, converted to cosmetics)

This prevents the feeling of "I have to grind forever for cosmetics" while keeping cosmetics optional.

---

### 5.4 "Earned vs Given": Why Rewards Must Feel Earned

**Earned reward:** "I beat the boss and earned this weapon."
- Feels valuable
- Creates satisfaction
- Player attributes the weapon's power to their skill

**Given reward:** "I reached level 5 and automatically got this weapon."
- Feels like a participation trophy
- No satisfaction
- Player attributes the weapon to progression tick, not skill

**Design rule:** If you're giving a reward, make the player *earn* it through at least one of these:
1. **Defeat:** Beat an enemy or obstacle
2. **Challenge:** Complete a difficult section
3. **Exploration:** Find hidden area
4. **Secret:** Discover non-obvious solution
5. **Grind:** Repetition (weakest, but acceptable if meaningful)

**Anti-pattern:** "Every 15 minutes of playtime, you get a free cosmetic." This trains players that time = reward, not accomplishment = reward. Results: players optimize for *playing time*, not *playing well*.

Better: "Every 15 minutes of playtime, unlock a cosmetic *option*. Complete challenges to *earn* specific cosmetics."

---

## 6. Player Communication (Without Words)

The best game design communicates entirely through the game world. The player doesn't read instructions; they *see* what's possible.

### 6.1 Affordances: How Players Know What They Can Interact With

**Affordance:** A visual or contextual cue that signals "you can interact with this."

**Examples:**
- A button that *looks* pressable (beveled, highlighted) vs one that looks flat and un-pressable
- A ledge that *looks* climbable (is it at reachable height? Is there a handhold?) vs one that's too high
- An enemy that *looks* vulnerable (flashing, staggered animation) vs one that's locked down

**How to implement:**
1. **Visual contrast:** Interactive objects should look different from scenery.
2. **Consistency:** If one door is interactive and looks X way, all interactive doors should look similar.
3. **Signposting in context:** A ledge the player can climb should be near another ledge they just climbed.
4. **Animation cues:** If the player *can't* interact with something, animate it in a "locked" state (gray, dim, or shaking "no").

**Anti-pattern:** "The secret is in this corner, but I gave no visual indication." The player won't find it, and they'll feel the game cheated them. *Show* hidden things subtly (slight glow, different texture, etc.).

---

### 6.2 Signposting: Guiding Without Explicit Instructions

**Signposting** is the art of guiding the player to the right action without breaking immersion.

**Techniques:**
1. **Level design:** Make the path you want obvious. If the exit is up, make "up" look passable and "left" look blocked with scenery.
2. **Lighting:** Brighter areas feel like "go here"; dark areas feel like "don't go there" (unless the game is about dark, then inverse).
3. **NPC placement:** An NPC standing in front of a door signals "go here."
4. **Sound:** Ambient noise ahead of you (music, distant voices) signals "something is there."
5. **Particle effects:** A glow, smoke, or sparkle signals "something to interact with."
6. **Color:** A red enemy versus a blue environment creates visual separation (enemy stands out).

**Example (Portal):**
- The exit portal is placed in the center of the chamber, well-lit, and all paths lead toward it. The player never feels lost; they naturally move toward the goal.

**Example (Dark Souls):**
- The next bonfire (safe area) is usually visible from a distance (glow on a building, visible in the distance). The player has no objective marker, but sees the glow and goes there.

**Anti-pattern:** Quest marker or explicit instruction. It works (player always goes the right way), but it breaks the immersion of exploration and discovery.

---

### 6.3 Visual Hierarchy in Gameplay: What Draws the Eye First

In any frame, the player's eye needs to know where to look.

**Principles:**
1. **Size:** Bigger objects grab attention first.
2. **Color:** Contrasting colors pop (red object on blue background).
3. **Movement:** Animated objects draw the eye faster than static ones.
4. **Depth:** Objects in foreground seem closer/more important.
5. **Lighting:** Bright objects attract before dark ones.

**Example (HUD design):**
- Your health bar is large, red, and in the corner (size + color + position = you always know your health)
- Enemy health is smaller, visible above the enemy (size + position = you see it but it's not primary focus)
- Your ability cooldowns are smallest and peripheral (you check them when needed, not constantly)

**Example (Combat design):**
- Your character: bright, centered, in focus
- Enemies: bright, animated, easy to track
- Projectiles: very bright, colorful (yellow/red), stand out immediately
- Terrain: muted, background focus
- Result: Player knows what to avoid and what to attack instantly

**How to implement:**
1. **Identify the priority.** What does the player need to pay attention to in this moment?
2. **Make the priority visually dominant.** Size, color, and animation.
3. **Reduce noise.** Everything else should be visually quieter.

---

### 6.4 Sound as Information: Audio Cues That Communicate Game State

Sound is as important as visuals for communication. Modern games use sound to convey:
- **Status:** Enemy at full health vs low health (sound pitch changes)
- **Feedback:** Attack hit vs attack missed (different sounds)
- **Location:** Enemy off-screen (sound direction tells you where)
- **Consequence:** Action was successful vs failed (success = chime; failure = buzzer)

**Examples:**
- **Boss music changes as boss health decreases:** Full health = ominous. Half health = frantic. Low health = desperate.
- **Footsteps get louder when enemy approaches:** Audio creates tension without seeing the enemy.
- **Different hit sound for critical vs normal hit:** Audio-only feedback that your attack was special.

**How to implement:**
1. **Map states to sounds.** Every game state should have a sonic signature.
2. **Use pitch for progression.** Higher pitch = good/alert. Lower pitch = bad/danger. Middle = neutral.
3. **Layering for intensity.** Add more instruments/channels as intensity increases (rest = solo instrument; action = full orchestra).

See procedural-audio skill for implementation details.

---

### 6.5 Color Language: The Vocabulary of Color in Games

Players learn color meaning from culture and from other games. Use that vocabulary.

**Universal meanings:**
- **Red:** Danger, enemy, attack
- **Green:** Safe, heal, progress, go
- **Yellow/Gold:** Important, interactive, key
- **Blue:** Ally, water, calm, cold
- **Purple:** Magic, mysterious, special
- **Gray:** Neutral, boring, inactive
- **White:** Light, pure, safe

**How to use:**
1. **Be consistent within your game.** If red is danger, make all dangers red (enemy glow, attack telegraph, damage effect).
2. **Respect player expectations.** If players expect green = safe, don't make green mean "poison gas." Break expectations with intention, not accident.
3. **Contrast for clarity.** Enemy on red background is hard to see. Enemy on blue background pops. Choose backgrounds that make important elements visible.

**Example (Zelda: Breath of the Wild):**
- Red = fire damage, fire enemies, fire hazards
- Blue = water, ice, cold biomes
- Gold = treasure, interactive objects, NPCs
- Green = healing, safe zones, vegetation
- Purple = magic, special mechanics, corruption

Player never has to read a tutorial about color. They *see* red and know "this is dangerous."

---

## 7. Prototyping & Validation: Finding the Fun

The only way to know if something is fun is to build it and play it.

### 7.1 "Find the Fun" Methodology

**Process:**
1. **Build the minimum** — What is the smallest version of this mechanic that can be tested?
2. **Play it** — Don't read the code. Play it with fresh eyes.
3. **Ask: Is it fun?** — Don't ask "is it correct?" or "is it balanced?" Just: does it feel good?
4. **Iterate fast** — Change one variable, retest. Change a different variable, retest.
5. **Stop optimizing the non-fun parts** — If the core feels fun, stop tuning edge cases. Move on.

**Example (Combat mechanics):**
- Minimum prototype: Player can attack. Enemy takes damage. Enemy dies. That's it.
- Play it. Does it feel good to attack?
- If yes: Add feedback (screen shake, hit sound). Re-test. Better?
- If no: What's wrong? Is it too slow? Not impactful enough? Change the timing or feedback, re-test.
- Once attacking feels fun, *then* add combos, *then* add enemy patterns, *then* add difficulty.

**Key insight:** You will throw away 70% of your prototyped ideas. That's correct. The goal is to *find* the 30% that's actually fun, not to polish everything equally.

---

### 7.2 Paper Prototyping for Game Design

**What:** Test game mechanics with physical materials (cards, tokens, dice, paper) before writing code.

**Why:**
- **Fast iteration:** Change a rule in 30 seconds. Re-test in 5 minutes.
- **No technical barrier:** You don't need to code. Anyone can prototype.
- **Focus on systems:** You're testing mechanics, not aesthetics. Noise is removed.

**Example (RPG combat system):**
1. Write attack values on cards (Player: 10 damage, Enemy: 8 damage)
2. Play out one fight manually (take turns attacking, subtract health)
3. Ask: Does it feel good? Is it too fast? Too slow? Does the player feel powerful?
4. Change values (Player: 15 damage, Enemy: 6 damage) and re-test
5. Once it feels right in paper form, code it

**Example (Puzzle game):**
1. Draw the puzzle on paper
2. Play it manually (move pieces by hand)
3. Iterate on the solution difficulty
4. Once the paper version is fun, code the digital version

**How to implement:**
1. Identify the core system (combat, progression, resource management, puzzle mechanic)
2. Represent it with physical materials
3. Play 3–5 iterations manually
4. Once you know it's fun, prototype in code

**Anti-pattern:** Spend 2 weeks coding a system, discover it's not fun, rewrite it. Paper prototype for 2 days instead; discover it's not fun immediately; iterate until it is.

---

### 7.3 Vertical Slice vs Horizontal Slice: When to Use Each

**Vertical Slice:** One complete feature, all the way from beginning to end.
- Example: One level of a platformer, fully polished (graphics, sound, feedback, difficulty, progression)
- **Use for:** Proving a core loop works end-to-end. Good for pitches and early validation.
- **Risk:** Takes longer to build (includes polish, art, audio). Gives detailed feedback on one path only.

**Horizontal Slice:** All features at once, but at lower polish.
- Example: All 5 main mechanics in rough form, no art pass, placeholder sounds
- **Use for:** Testing how mechanics interact. Good for finding system-level problems.
- **Risk:** No single feature feels "finished." Can be demoralizing. Hard to show to outsiders.

**When to use which:**
- **Early prototype:** Horizontal slice. You're testing if the mix of mechanics works together.
- **Mid-project:** Vertical slice. You're proving one complete experience works polished.
- **Pre-ship:** Mix. Multiple vertical slices of different features (all at shipping quality), plus horizontal slices of content (all features present, some unpolished).

---

### 7.4 Playtest-Driven Iteration: The Build → Test → Learn Cycle

**Process:**
1. **Build:** Ship a playable version (even if rough)
2. **Test:** Playtesters play it; you watch and take notes
3. **Learn:** What surprised you? What felt good? What felt wrong?
4. **Iterate:** Change the thing that surprised you. Rebuild.
5. **Repeat:** Another playtest with fresh testers

**How to structure a playtest:**
- **Objective:** "I want to know if the difficulty curve feels right" (specific question, not general vibes)
- **Observation:** Don't tell the player what to do. Watch them figure it out. Do they figure it out naturally, or struggle?
- **Metric:** "Did 80% of players beat level 3 on first try?" (measurable, not vague)
- **Duration:** 10–15 minutes of gameplay per tester. Longer playtests yield diminishing returns.

**What to measure:**
- **Time to understand the mechanic:** How many minutes before the player "gets it"?
- **Success rate:** What percentage of players beat a challenge?
- **Engagement:** Do players say "that was fun" or "I was bored"?
- **Feedback:** What did players struggle with? What surprised them?

**Anti-pattern:** "I'll ship the game and playtest in beta." By then, it's too late to change core systems. Playtest during development, starting with the core loop.

---

## 8. Genre-Specific Design Lenses: How Genres Shape Design

These are brief overviews. For detailed genre knowledge, refer to genre-specific skills.

### 8.1 Action/Combat: Frame Data, Hit Feedback, Combo Depth

**What defines the genre:**
- **Frame data:** Attack startup/active/recovery timing is the core language
- **Hit feedback:** Hitlag, knockback, and hitstun make hits *feel* impactful
- **Combo system:** Chaining attacks creates depth and skill expression

**Key design questions:**
- Can the player string attacks together, or is each attack isolated?
- Do combos have a risk (must commit to the string) or a reward (damage multiplier)?
- Is there a defensive option (block, dodge, parry) that counters combos, or are combos unpunishable?

**Reference games:** Streets of Rage 4, Marvel vs Capcom, Hades, Devil May Cry

See beat-em-up-combat skill for detailed frame data patterns.

---

### 8.2 Platformer: Jump Arc, Coyote Time, Level Grammar

**What defines the genre:**
- **Jump feel:** The arc of the jump is the core interaction. Too floaty = feels bad. Too heavy = feels unresponsive.
- **Coyote time:** The player can jump for a short time after leaving a platform (~4 frames). This forgives edge-case misses and feels generous.
- **Level grammar:** Repeating platform patterns teach the player the rules (single jump: 3-tile gap, double jump: 6-tile gap, etc.)

**Key design questions:**
- What's the intended jump arc? How high and how far?
- When should new movement mechanics be introduced?
- Are platforms grid-aligned (snappy, predictable) or organic (floaty, expressive)?

**Reference games:** Celeste, Super Mario Bros, Hollow Knight, Meat Boy

---

### 8.3 Puzzle: Mechanic Introduction, "Aha Moment" Pacing

**What defines the genre:**
- **Mechanic introduction:** One new puzzle rule per 2–3 levels
- **Aha moment:** The point where the player understands the mechanic's potential (usually level 2 after introduction)
- **Escalation:** Combine mechanics in unpredictable ways

**Key design questions:**
- When does the player *first understand* a mechanic vs when do they *master* it?
- Are puzzles logic-based (one optimal solution) or creative (many valid solutions)?
- Does the game teach the solution or the tool? (Portal: teaches tools; The Witness: teaches observation)

**Reference games:** Portal, The Witness, Tetris, Sokoban

---

### 8.4 RPG: Progression Curves, Choice Consequence, Build Diversity

**What defines the genre:**
- **Progression curves:** XP, leveling, stat growth. How fast does the player feel stronger?
- **Choice consequence:** Player decisions create mechanical or narrative outcomes
- **Build diversity:** Multiple valid ways to build a character (different stats, abilities, equipment)

**Key design questions:**
- Does the player feel stronger after each level (power fantasy) or does enemy scaling negate it (flat difficulty)?
- Do player choices feel meaningful, or are all builds equivalently viable (reduces decision weight)?
- Is progression linear or is there choice in *which* abilities to unlock?

**Reference games:** Dark Souls, Baldur's Gate 3, Persona 5, Diablo

---

### 8.5 Strategy: Information Management, Decision Trees, Asymmetry

**What defines the genre:**
- **Information management:** What the player can see determines their decisions (fog of war, hidden enemy units)
- **Decision trees:** Each decision branches into many possible follow-ups
- **Asymmetry:** Different factions/units/rules create distinct playstyles

**Key design questions:**
- Is this simultaneous (all players act at once) or turn-based (one player acts, then next)?
- How much information is hidden? If everything is hidden, players feel helpless. If everything is visible, there's no discovery.
- Are there dominant strategies or is the meta-game diverse?

**Reference games:** Chess, Starcraft, Civilization, Fire Emblem

---

## 9. Anti-Patterns: What Kills Games

These are design failures you want to avoid.

### 9.1 "Design by Committee": Too Many Opinions, No Vision Owner

**What happens:** The game tries to please everyone. The designer asks "what do you think?" and gets 5 different answers from 5 team members.

**Result:** The game feels unfocused. Mechanics contradict each other. Features are added and removed. No coherent identity.

**How to prevent:**
- One person owns the game's vision (the designer). Other team members provide feedback, but the designer makes the final call.
- Regular design reviews where the designer presents direction, team provides feedback, designer incorporates what serves the vision.
- Document decisions in the GDD so "why did we make this choice?" has an answer, not "Sarah liked it."

**Related principle:** Principle #7 (Domain Owners, Not Silos). The designer owns the game design domain.

---

### 9.2 "Feature Creep": Adding Mechanics That Don't Serve the Core Loop

**What happens:** "We could add a fishing mechanic." "We could add base building." "We could add a tower defense mode." Each is separate. None serves the core loop. The game tries to do everything and does nothing well.

**Result:** Development time balloons. Each mechanic is half-finished. The game feels scattered.

**How to prevent:**
1. **Define the core loop first.** What is the ONE thing the player does every minute?
2. **Every feature must serve the core loop or its scaffolding.** Fishing is cool, but if it doesn't teach combat, doesn't require combat, and doesn't reward combat, it's feature creep.
3. **Say no 10 times for every yes.** Iteration means cutting, not adding.

**Related principle:** Principle #4 (Ship the Playable). Ship the core experience first. Expand only after the core is strong.

---

### 9.3 "The 80% Trap": Spending 80% of Dev Time on 20% of the Experience

**What happens:** A team spends 40 hours building a perfect boss fight animation, when the core combat system is missing. Or spends 2 weeks polishing the main menu when the game isn't fun yet.

**Result:** Polish on non-critical systems. Core experience suffers.

**How to prevent:**
1. **Identify the critical path.** What must ship for the game to be playable?
2. **The critical path gets 80% of time.** Core loop, core content, core feedback.
3. **Everything else gets 20% of time.** Boss animations, UI polish, nice-to-haves.
4. **Ruthlessly prioritize.** If a feature isn't on the critical path, it's bonus, not required.

**Related principle:** Principle #1 (Player Hands First). Polish the first 10 seconds, not the credits screen.

---

### 9.4 "Balance First, Fun Later": Wrong Order; Find the Fun, Then Balance It

**What happens:** The designer creates 20 attack types with carefully calculated damage values, then tests the game and discovers 18 of them feel bad.

**Result:** Wasted effort. Time spent balancing un-fun mechanics. Demoralization.

**How to prevent:**
1. **Prototype rough.** Build the mechanic with placeholder values.
2. **Playtest rough.** Is it fun in rough form? If no, delete it or redesign it.
3. **Polish fun mechanics.** Once a mechanic is fun, then tune numbers and balance it.

**Corollary:** "Don't balance broken mechanics." If an attack feels bad, don't adjust its DPS. Redesign the attack animation, timing, or feedback. Fix the feel, then balance.

**Related principle:** Principle #1 (Player Hands First). The feel is the feature. Balance is tuning.

---

## 10. Reference Games by Design Excellence

Play these games. Study them. Extract patterns.

### Celeste (2018)
**Why:** Perfect difficulty tuning, accessibility options, flawless jump feel, narrative integration through mechanics
- Study: How does coyote time make a difficult game feel fair?
- Study: How does a helper mode teach without feeling condescending?
- Study: How does the story reinforce the mechanical challenge (climbing a mountain = struggle = overcoming self-doubt)?

### Hades (2020)
**Why:** Core loop design, narrative integration, reward systems, replayability through variety
- Study: Why does a roguelike feel story-rich, not grindy?
- Study: How do cosmetic rewards and power rewards coexist?
- Study: How does variety in weapon/build options prevent the loop from feeling repetitive?

### Hollow Knight (2017)
**Why:** World design, difficulty signposting, exploration, progression pacing
- Study: How does the map communicate dangers (boss door looks scary; safe zone looks peaceful)?
- Study: How do movement upgrades unlock new areas without feeling like arbitrary gates?
- Study: How does the "hard but fair" principle play out in boss design?

### Portal (2007)
**Why:** Teaching through design, escalation, challenge design without combat
- Study: How does each test chamber introduce one concept, then combine previous concepts?
- Study: How does the environment itself teach (the path to the exit is usually the only path)?
- Study: How does difficulty escalate without enemy scaling?

### Tetris (1989)
**Why:** Simple core loop, infinite depth, perfect pacing
- Study: Why does one mechanic (falling blocks, rotation, line clear) create emergent depth?
- Study: How does increasing speed create escalation without changing rules?
- Study: Why does a game from 1989 still have a competitive community?

### Dark Souls (2011)
**Why:** Risk/reward design, world design, difficulty as communication, fairness in challenge
- Study: How does stamina management create meaningful resource decisions?
- Study: How does telegraphing make a hard game feel fair?
- Study: How does multiplayer integrate into a single-player game without breaking pacing?

### Breath of the Wild (2017)
**Why:** Player agency, emergent gameplay, open-world design without restriction
- Study: How do systems interact to create unscripted player moments?
- Study: How does the game avoid quest markers and still guide the player?
- Study: How does dynamic difficulty (scale up/down based on tools) handle open-world player agency?

---

## How to Use This Skill

1. **Before starting any project:** Read sections 1 (Core Frameworks), 2 (Player Psychology), and 3 (Difficulty). Use them to shape your GDD.
2. **When designing a new mechanic:** Use MDA framework. Define mechanics → expected dynamics → desired aesthetics. Prototype the mechanic. Playtest. Do dynamics match expectations?
3. **When a system feels "off":** Cross-reference against the anti-patterns. Is it feature creep? Is balance prioritized over fun? Is there player psychology you're missing?
4. **For genre questions:** Read the genre-specific lens (Section 8). For detailed patterns, refer to genre-specific skills.
5. **When stuck:** Playtest. Watch players engage with your game. They will tell you what's wrong faster than any theory.

---

## Related Skills

- `game-feel-juice`: Feedback implementation for any game
- `beat-em-up-combat`: Combat design specifics for side-scrolling beat 'em ups
- `ui-ux-patterns`: UI/menu design patterns
- `state-machine-patterns`: Implementing game state architecture
- Genre-specific skills (when available): Platformer grammar, puzzle design, RPG progression, strategy meta-game

---

## Change Log

**2026-08-03 (Initial creation by Yoda)**
- Created as foundational universal skill for all First Frame Studios projects
- Covers 10 core design frameworks from industry research and studio experience
- Emphasis on Player Hands First principle and playtest-driven iteration
- Genre-agnostic approach suitable for any game, any platform, any IP
- Confidence: Low (first observation, not yet validated in shipped projects beyond beat 'em ups)

---

