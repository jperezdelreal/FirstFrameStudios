# SKILL: Level Design Fundamentals — Universal Architecture for Every Genre

Levels are the sentences of game design. Mechanics are words; levels are how you speak to the player. A level teaches, tests, or rewards. It paces emotional intensity, guides exploration, and transforms mechanics into meaningful experiences. This skill transcends beat 'em ups, platformers, RPGs, puzzles, and 3D action — the principles are universal. The application is genre-specific.

---

name: "level-design-fundamentals"
description: "Universal level design principles covering spatial grammar, pacing, flow, environmental storytelling, genre-specific patterns, and playtesting methodology"
domain: "game-design"
confidence: "low"
source: "extracted from firstPunch beat 'em up level patterns (horizontal scroll, camera locks, wave arenas) + genre research (Super Metroid, Dark Souls, Portal, Celeste, Hollow Knight, Undertale, Doom, BotW)"

---

## When to Use This Skill

- Designing levels or level sections for any genre (platformer, action, RPG, puzzle, horror, etc.)
- Planning level progression, pacing, and difficulty curves
- Playtesting and identifying why a level feels slow, frustrating, or boring
- Architecting environmental storytelling or narrative progression
- Creating level design documents or blockout plans
- Reviewing level layouts for flow, clarity, and player agency
- Debugging "player got lost," "level felt repetitive," or "difficulty spike came out of nowhere"
- Onboarding new level designers for a project

## When NOT to Use This Skill

- **Narrative/dialogue design** — see game-design-fundamentals for story beats
- **Enemy/NPC AI** — see agent-specific skill (e.g., "enemy-ai-patterns" for beat 'em ups)
- **Puzzle design** — covered here lightly, but deep puzzle design is its own discipline
- **Engine/platform constraints** — understand your engine's limits first (see engine skills)
- **Art asset creation** — level design is about *structure*, not visual execution (see 2d-game-art for backgrounds)

---

## 1. Level Design Philosophy

### What Is a Level?

**A level is a structured problem-space where the player applies learned mechanics to overcome designed challenges and discover rewards.**

It is not:
- A rectangular space filled with enemies
- A container for your art
- A tutorial disguised as gameplay
- An excuse to show off technical features

It is:
- The primary teacher of your game's complexity
- The pacing device that controls emotional intensity
- The structure that grants agency while guiding direction
- The story told through environment, not cutscenes

### The Level is the Teacher (Nintendo's Core Insight)

In the best-designed games, the level itself teaches. Not text, not cutscenes, not dialogue — the *structure* of the level communicates the rule.

**Example: Super Mario Bros. (1985)**
- Level 1-1 teaches jumping by presenting a small gap. Gap is wide enough that running jump is required.
- Next section: wider gap, forcing timing mastery.
- Then: gap with enemy, forcing timing + threat assessment.
- Each section adds complexity incrementally. Zero dialogue. Zero pause menu tutorials. The level *is* the tutorial.

**Example: Dark Souls (2011)**
- Early area (Undead Asylum) has one NPC who teaches backstab mechanic.
- But the *level itself* teaches through repetition: multiple backstabbable humanoid enemies positioned to reward stealth approach.
- Player learns "backstab = safe damage" through the level's structure, not from dialogue.

**In your levels:** Introduce a mechanic, repeat it with variations, combine it with previous mechanics. That's the 3-beat rule (covered in Flow & Pacing below).

### The Three Level Purposes: Teach, Test, Reward

Every level (and every section within a level) falls into one of three categories:

**1. Teach — Introduce or practice a single concept**
- Player learns one new thing per teaching level
- Threat is low; failure is part of learning
- Success = player understands the mechanic
- Example: First platformer level where you learn jump timing. Enemies are slow or absent.

**2. Test — Combine known concepts under pressure**
- Mechanics are old; the *combination* is new
- Threat is high; failure has consequences
- Success = player demonstrates mastery
- Example: Boss that uses three attacks you've faced separately; you must respond to combinations.

**3. Reward — Celebrate mastery with spectacle or narrative**
- Challenge is low or optional; focus is on discovery or story payoff
- Reward takes form of: treasure, vista, story beat, new ability, or safe exploration
- Success = player feels acknowledged
- Example: Secret area with rare collectible, or cutscene revealing plot twist after defeating final boss.

**Rhythm:** Teach → Test → Reward → (repeat with higher stakes). Never teach and test in the same section. Never test without prior teaching. Never make rewards feel dangerous.

### Player Agency vs. Directed Narrative

The best levels create the *illusion of choice* within a *structured narrative*.

**Player Agency:** The player believes they are making meaningful decisions.
- "Should I take the risky shortcut or the safe long route?"
- "Do I explore this side area or press forward?"
- "How do I approach this encounter — sneaky or direct?"

**Directed Narrative:** The level guides the player toward the intended experience.
- Both routes lead to the same encounter (the shortcut is faster but riskier).
- The side area is optional but contains story/world lore (not mandatory progression).
- The encounter is designed for both approaches to succeed.

**How to blend them:**
- Create **primary paths** (intended progression) and **optional paths** (shortcuts, secrets).
- Gate paths with difficulty/skill checks, not with invisible walls.
- Reward exploration without punishing linear play.
- Communicate choice through visual hierarchy and environmental design, not through menus.

**Example (BotW): Shrine of Resurrection to First Tower**
- Intended path: linear climb with tutorial enemies, opens into world
- Player agency: climb can be skipped if you move laterally and glide to tower
- Both approaches teach the same mechanics (movement, sight lines)
- Player believes they outsmarted the design; design intended exactly this

---

## 2. Spatial Grammar — The Building Blocks of Level Structure

Every level is composed of distinct space types. Each type has a purpose. Together, they form a "grammar" — a language of spatial design.

### The Six Core Space Types

#### 2.1 Safe Spaces

**Purpose:** Player can pause, plan, heal, or breathe.

**Characteristics:**
- No active threats (no enemies spawning, no environmental hazards)
- Clear sightlines to exits
- Room to maneuver without pressure
- Visual clarity (no visual clutter)

**Examples:**
- Hub area in an RPG (town, tavern, base camp)
- Safe room in Metroidvania (empty chamber before next challenge)
- Rest point in Dark Souls (bonfire)
- Checkpoint room before boss in platformer

**When to use:** After every major test section. Not optional. Players need to breathe, and they need to *know* they're safe.

**Anti-pattern:** Safe space that looks dangerous (dark colors, ominous music). Player won't relax. Pacing breaks.

#### 2.2 Danger Zones

**Purpose:** Threats exist; player must act or react.

**Characteristics:**
- Active enemies, hazards, or time pressure
- Limited escape routes
- Visual hierarchy focuses on threats
- Feedback on danger (red tint, warning sounds, visual emphasis on hazards)

**Examples:**
- Combat arena in beat 'em up
- Spike pit section in platformer
- Ambush corridor in action game
- Mini-boss chamber

**When to use:** After player has tools/knowledge to handle the threat. Danger zones are tests, not surprises.

**Anti-pattern:** Danger zone with no warning (instant death trap). Frustration, not challenge. Teach first.

#### 2.3 Transition Spaces

**Purpose:** Move player between safe and danger zones; control pacing and narrative flow.

**Characteristics:**
- Lower threat than danger zones
- Visual or narrative context-setting
- Can be slower-paced (hallway, corridor, elevator, bridge)
- Breathing room but not complete safety

**Examples:**
- Corridor between rooms
- Elevator ride (downtime for music shift, visual story beat)
- Gate/bridge crossing (moment to observe what's ahead)
- Shop entrance in RPG (shopping as a pacing break)
- Hallway where camera pans to show upcoming threat

**When to use:** Between every major section. Don't skip transition spaces; they control *when* the player encounters the next challenge.

**Timing:** 10-20 seconds of movement is typical. Long transitions (30+ seconds) work if something meaningful happens (music change, visual reveal, story dialogue).

**Anti-pattern:** Transition space filled with minor enemies. It stops being a pacing control and becomes "more threat." Keep transitions clear or make them intentionally scenic.

#### 2.4 Arena/Encounter Spaces

**Purpose:** Structured combat or challenge with clear boundaries and designed flow.

**Characteristics:**
- Clear boundaries (walls, arena shape)
- Enemy positions designed to teach a pattern
- Environmental features (cover, hazards, heights)
- Escape routes or progression triggers are clear

**Examples:**
- Beat 'em up wave arena (horizontal scroll with camera lock)
- Boss chamber
- Puzzle room (spatial puzzle as encounter)
- Minefield area with path forward

**When to use:** Every meaningful challenge should have a designed arena, not a random open space.

**Design checklist:**
- [ ] Player has room to maneuver (minimum 1.5× player character width)
- [ ] Threats are positioned to teach a pattern (not random placement)
- [ ] Escape routes or victory conditions are clear
- [ ] Environmental hazards reinforce (not contradict) the challenge

**Anti-pattern:** Arena where optimal strategy is to stay in one corner (spamming attack). If the arena allows a dominant strategy, expand it or add threats that punish camping.

#### 2.5 Reward Spaces

**Purpose:** Celebrate completion, provide progression, or tell story through environment.

**Characteristics:**
- Challenge is low or optional
- Focus is on discovery or narrative payoff
- Visual beauty or story significance
- Player feels acknowledged

**Examples:**
- Treasure room (rare collectible, currency)
- Vista or viewpoint (sweeping environmental narrative)
- Character appearance or boss defeat cutscene
- Secret area with lore details
- Skill tree unlock or ability upgrade
- Safe room with story NPC dialogue

**When to use:** At the end of every major test section. Reward doesn't have to be mechanical; story beats and environmental moments count.

**Timing:** Reward spaces should feel unhurried. Let the player soak in the moment.

**Anti-pattern:** Reward space that's hard to reach and then punishes failure (falling spikes around the treasure). Rewards should feel *safe* to experience.

### 2.6 Sequencing the Spaces: The Safe-Transition-Danger-Reward Cycle

The fundamental rhythm of level design:

```
SAFE → TRANSITION → DANGER → REWARD → (SAFE for next cycle, or TRANSITION to next cycle)
```

**Example breakdown (platformer level):**
1. **SAFE:** Checkpoint room. Player collects last health, readies.
2. **TRANSITION:** Corridor with slight incline. Camera pans to show the vista ahead (spike pit).
3. **DANGER:** Spike pit with moving platforms. Challenge requires precise jumps.
4. **REWARD:** Safe platform on far side + vista of next area + 50 coins pickup.
5. *Loop repeats:* Safe checkpoint → transition to next challenge.

**Example breakdown (beat 'em up wave):**
1. **SAFE:** Previous wave ended. Player is at full health or near-full. Clear arena.
2. **TRANSITION:** Enemy appears at edge of screen. Dramatic entrance SFX. Music shifts.
3. **DANGER:** Combat arena. Waves of enemies test combo chains.
4. **REWARD:** Boss defeated, camera zoom, slow-mo finish, screen shake celebration. Health restored.

**Why this rhythm matters:**
- Tension naturally builds (safe → danger) and releases (danger → reward)
- Player knows where they are in the progression cycle (pacing predictability)
- Safe spaces prevent frustration accumulation
- Rewards reinforce that challenges were worth overcoming

**Tuning the cycle:** A game with 5-minute cycles feels breezy. A game with 15-minute cycles between safe spaces feels punishing. Know your genre's pacing expectation.

---

## 3. Flow & Pacing — Controlling Emotional Intensity

Pacing is the heartbeat of level design. Get it right, and the player never feels slow or bored. Get it wrong, and good mechanics feel tedious.

### The Roller Coaster Model

**Concept:** Emotional intensity in a level follows a curve, not a plateau. Build tension → release → build higher → bigger release.

```
Intensity
^
|     /\           /\
|    /  \         /  \
|   /    \       /    \
|  /      \     /      \
| /        \   /        \
|/          \_/          \___
└──────────────────────────────→ Time
```

**Building tension (intensity rises):**
- Introduce a threat or challenge
- Remove escape routes
- Increase danger: faster enemies, more enemies, environmental hazards stack
- Tighten time windows

**Releasing tension (intensity drops):**
- Threat is eliminated or escaped
- Safe space is reached
- Music shifts to calmer tone
- Reward is presented (coin, story beat, vista)

**Why it works:** The human nervous system craves cycles of tension and release. Without release, tension becomes frustration. Without tension, release has no meaning.

### Intensity Mapping (Graphing Your Level's Emotional Curve)

Before building, sketch your level's intensity on a timeline:

```
10 |                         *
9  |                     *       *
8  |             *   *               *
7  |         *       *           *   *
6  |     *       *           *         *
5  |             *           *
4  | *   *       *
3  |
2  |
1  |
0  +─────────────────────────────────→ Time (seconds)
```

**Rules for a healthy intensity curve:**
- Never stay at max intensity (10) for > 1 minute. Player exhaustion = frustration.
- Never plateau at medium intensity (5) for > 2 minutes. Player boredom = disengagement.
- Every local peak should be slightly higher than the last (escalation).
- Every valley should still be above baseline (no complete relaxation until safe space).
- Final peak should be the highest (climax).

**Example: 5-minute beat 'em up wave progression**
- Min 0-30s: Intensity 2-4. Single weak enemy. Player learns response pattern.
- Min 1-2: Intensity 5-7. Multiple weak enemies. Combos are tested.
- Min 2-3: Intensity 6-8. One strong enemy with new attack pattern.
- Min 3-4: Intensity 7-9. Multiple strong enemies + environmental hazards.
- Min 4-5: Intensity 8-10. Boss or champion enemy. All mechanics tested in combination.
- Min 5: Intensity 0. Reward space. Victory moment.

**Tuning:** If playtesting reveals "mid-level felt draggy," your intensity curve probably had a 2-minute plateau at level 5.

### Rest Points Are Not Optional

A "rest point" is any moment where the player is not under pressure: safe space, save station, menu, cutscene, slower transition.

**Why rest points matter:**
- They prevent frustration accumulation (player tolerance for difficulty resets after rest)
- They give hands a break (literally: avoid RSI by building in pause moments)
- They let story or environment breathe
- They create pacing rhythm that feels natural, not exhausting

**Minimum rest points (by game length):**
- **30-minute game:** Rest point every 3-5 minutes (6-10 rest points total)
- **1-hour game:** Rest point every 5-7 minutes (8-12 rest points total)
- **2+ hour game:** Rest point every 5-10 minutes; natural gameplay pacing often provides these

**What counts as a rest point?**
- Safe room or checkpoint
- Save station or menu access
- NPC dialogue or cutscene (music softer, threat gone)
- Slower-paced exploration section
- Collectible-gathering zone (low threat)
- Shop or upgrade interface

**What does NOT count as a rest point?**
- A platformer section with spikes (threat = pressure)
- A "corridor" filled with weak enemies
- A cinematic moment where you have no control

**Anti-pattern:** Designing a 10-minute boss gauntlet with no rest points in between. Player fatigue becomes a second enemy. Break it into 2-minute sections with safe checkpoints.

### The 3-Beat Rule — Teaching Through Repetition

**Concept:** Master teaching follows a pattern: Introduce → Repeat with variation → Combine with previous concepts.

**Example: Teaching dash attack in a beat 'em up**

**Beat 1 — Introduce:**
- Single weak enemy, open arena
- Enemy is stationary or very slow
- Force player to try dash attack to progress (it's the only viable option)
- Player learns: "Dash attack = close distance quickly"

**Beat 2 — Repeat with variation:**
- Multiple weak enemies in a line
- Player must dash-attack between them to maintain momentum
- Variation: enemies have slight knockback, forcing spacing management
- Player learns: "Dash attack + spacing = effective offense"

**Beat 3 — Combine:**
- Enemy with defensive move (block, dodge) + other strong enemies nearby
- Player must dash-attack past the defensive enemy, then standard attacks on others
- Or: dash-attack into boss that has patterned counterattack
- Player learns: "Dash attack is strong, but has a vulnerability window"

**Why it works:** The mechanic is not introduced, tested, then forgotten. It's woven into progression. By the time the player encounters a complex challenge using dash-attack, they've internalized it through repetition at increasing complexity.

**Applying the 3-beat rule:**
- Identify every core mechanic (jump, attack, special move, environmental interaction)
- Design three sections where it appears: simple, varied, combined
- Space them out (not back-to-back; player needs rest between)
- Never assume players mastered it after one appearance

**Anti-pattern:** Introducing a mechanic once, then never using it again. Player assumes it's situational (not core) and forgets it exists.

### Speed Management — Obstacles and Boosts

Pacing is also controlled by movement speed: slower sections build intensity, faster sections release it.

**Slowdown tools (build tension):**
- Narrow corridors (restrict movement)
- Water/mud sections (reduced speed)
- Stairs (slower ascent)
- Puzzle sections (force player to think, not run)
- Environmental obstacles (force navigation)

**Speedup tools (release tension or extend reward):**
- Open areas (free movement)
- Downhill sections (natural acceleration)
- Speed-boost items (temporary velocity increase)
- Escape sequences (run away from threat)
- Fast travel (teleport to safe zone)

**Pacing rhythm example (3-minute platformer level):**
- 0-30s: Open area, free movement. Intensity 2. (release)
- 30-45s: Narrow spike corridor. Intensity 7. (tension)
- 45-60s: Speed-boost pickup + open area. Intensity 3. (release)
- 60-90s: Multiple obstacles, puzzle solution required. Intensity 6. (tension)
- 90-120s: Boss arena. Intensity 9. (peak tension)
- 120-180s: Victory moment + safe room. Intensity 0. (full release)

---

## 4. Environmental Storytelling — Tell Story Through Space

The best levels tell a story without cutscenes, dialogue, or text. The environment speaks.

### Visual Narrative: Show, Don't Tell

**Concept:** A destroyed room tells more than a cutscene. An abandoned path tells more than exposition. A misplaced object tells more than narration.

**Example: Dark Souls**
- No quest log. No mission markers.
- Instead: a skeleton with a sword at the bottom of a cliff (story: someone fell here)
- Nearby, a note corpse holding a key (story: they were trying to reach something locked)
- A faded bloodstain on the ground (story: other players died here too; maybe don't go this way)
- The *environment* teaches caution and curiosity without words

**Example: Hollow Knight**
- No exposition: "This kingdom fell to disease"
- Instead: dead bugs everywhere, black ichor pooling, husks of enemies, decaying architecture
- Player reconstructs the narrative through environmental observation

**Visual narrative techniques:**
- **Contrast:** A pristine, clean room next to a ruined room (story of decline)
- **Density:** Crowded area (activity, commerce, life) vs. sparse area (abandonment, danger)
- **Materials:** Stone and steel (structure, authority) vs. wood and cloth (decay, poverty)
- **Light:** Bright areas (safety, hope) vs. dark areas (danger, mystery)
- **Scale:** Giant architecture (something powerful lived here) vs. small spaces (limited civilization)

### Breadcrumbing: Guiding Without Markers

**Concept:** Leave subtle clues that guide the player without quest markers or dialogue.

**Breadcrumbing techniques:**
1. **Visual direction:** Player's eye naturally follows a path (bright object ahead, contrasting color, leading lines)
2. **Enemy placement:** Enemies guard the intended path (where danger is, progression is)
3. **Architectural flow:** The level naturally channels movement (narrow passages lead forward)
4. **Environmental hints:** A visible goal (treasure room door, boss silhouette) draws the player
5. **Light changes:** Brighter areas ahead suggest progression; darkness suggests retreat

**Example (Portal):**
- No compass, no UI guidance
- Instead: test chambers are designed so the only "forward" path is obvious (walls, platforms, light sources)
- Player never feels lost because the level *is* the guide

**Example (Metroidvania - Super Metroid):**
- No quest log for "go to Norfair"
- Instead: visual blocking (lava river you can't cross) naturally guides exploration
- Red rooms = hot areas (story: get heat-resistant suit before entering)
- Locked blue doors = progression gates (hunt for blue keycard)
- Environment teaches through visual language

**Anti-pattern:** Breadcrumbs that contradict each other (multiple "obvious" paths) or require backtracking repeatedly (player gets lost, frustrated).

### World Consistency — Every Element Belongs

**Concept:** Every visual, every architectural choice, every detail should feel like it belongs in this world, not a generic game level.

**Consistency questions:**
- **Climate:** Does the architecture match the climate? (Desert temples are different from snow caves.)
- **Culture:** Does the design reflect a society or civilization? (Are there signs of who lived here?)
- **Age:** Is the environment young (fresh construction) or old (weathered, overgrown)?
- **Function:** Do spaces look designed for their purpose? (A bar has seating, a forge has heat-related architecture.)
- **Damage pattern:** If something is broken, is the breakage consistent with what broke it? (Explosion damage vs. rust vs. decay look different.)

**Example: firstPunch (beat 'em up)**
- Every location is recognizable from the show: Factory, Quick Stop, Joe's Bar, City School
- Architecture matches the show's design (squat suburban structures, industrial plant)
- Details (billboard signs, parked cars, vendor stands) are consistent with the Downtown we know
- Player recognizes the world; it feels authentic, not generic

**Building consistency:**
- Create a "visual identity" doc: color palette, material language, architectural vocabulary
- Reference real-world equivalents (ancient temples, modern offices, medieval castles) for structural design
- Limit variety in early levels; expand it gradually as the world expands
- Every new element should answer: "Where did this come from? Who made it? Why is it here?"

**Anti-pattern:** Random mixture of themes (medieval castle connected to sci-fi lab, no explanation). Breaks immersion.

### Reference Games and Environmental Storytelling

Study these masters:

| Game | Technique | Why It Works |
|------|-----------|-------------|
| **Dark Souls** | Interconnected world; every location tells backstory through placement and detail | Exploration is investigation; curiosity is rewarded |
| **Hollow Knight** | Environmental decay + enemy ecology tells history | Player pieces together fallen kingdom narrative |
| **Portal** | Test chambers design the narrative: increasing complexity = escalating stakes | Design *is* the story |
| **Metroid** | Color-coded environments gate progression; biomes feel earned, not arbitrary | Visual clarity + world consistency |
| **BotW** | Ruins and environmental hazards tell story of ancient civilization + current state | Exploration reveals narrative without cutscenes |
| **Hyper Light Drifter** | Minimal dialogue; visual storytelling through environment, enemy design, and artifacts | Atmosphere and beauty carry meaning |

---

## 5. Level Design by Genre — Genre-Specific Patterns

### 5.1 Platformer

**Core challenge:** Navigate obstacles through precise movement.

**Spatial grammar:**
- **Obstacle progression:** Platform → Gap → Moving platform → Gap + moving platform → Hazard + platform
- **Verticality:** Multi-screen height sections (climbing towers, descending pits)
- **Rhythm-based:** Platforms that appear/disappear on timing (synchronize your jump with their cycle)

**Pacing structure:**
- Introduce one obstacle per section
- Repeat with variation
- Combine obstacles in final challenge
- Rest point (safe platform or checkpoint)

**Speed management:**
- Slowdown: narrow corridors, crowded platforms, spike sections
- Speedup: boost pads, conveyor belts, downhill sections, open areas

**Secrets & exploration:**
- Hidden platforms (slightly off-screen or hard to see)
- Secret areas above/below main path
- Rewards for risky routes (platform over spikes vs. safe route)

**Common mistakes:**
- "Difficulty wall" — sudden spike with no preparation (no teaching beats before the wall)
- Invisible platforms (frustration without a reason)
- Slippery physics without clear visual feedback
- Respawning at start of level instead of last checkpoint

**References:** Celeste (tight controls + fair difficulty), Super Metroid (exploration + verticality), Kirby's Epic Yarn (forgiving difficulty with mastery paths)

---

### 5.2 Beat 'em Up (Horizontal Scroll)

**Core challenge:** Survive waves of enemies in a horizontal scroll arena.

**Spatial grammar:**
- **Wave arena:** Horizontal space with camera lock; player moves left-right within bounds
- **Hazards:** Environmental obstacles (spikes, pits, electrified floors) positioned between enemy spawn zones
- **Vertical sections:** Occasional stairs, multi-level arenas for verticality
- **Escape routes:** Clear paths to retreat, not dead ends

**Pacing structure:**
- **Wave 1:** Single enemy, open arena, simple pattern (teach)
- **Wave 2:** Multiple weak enemies or one enemy with variation (repeat)
- **Wave 3+:** Combination of enemy types + hazards + special moves (combine)
- **Boss wave:** Champion enemy with all mechanics tested (climax)
- **Victory:** Full health restoration, slow-mo finish, celebrate

**Camera management:**
- Lock camera to arena for arena waves
- Slight pan to show incoming threats
- Quick zoom-out if arena is expansive

**Enemy positioning:**
- Spawn edges of screen (telegraphed arrival)
- Stagger spawns (don't spawn all at once)
- Position near hazards (hazard acts as gating tool, not spawn point)

**Hazard placement:**
- Hazards are *challenges*, not *punishment* (player should be able to dodge them)
- Position hazards in ways that force interesting player decisions (retreat to edge vs. fight in middle)

**Common mistakes:**
- Overlapping hit detection (attacks hitting through walls)
- No gap between waves (players need breath)
- Hazards that feel unfair or unavoidable
- Knockback that sends player into another hazard (double-punishment)

**References:** Streets of Rage 4 (juice + wave design), Shredder's Revenge (camera lock + vertical variety), Turtles in Time (throw spectacle + hazard integration)

---

### 5.3 Metroidvania

**Core challenge:** Explore an interconnected world, unlock new areas through ability gates, find shortcuts.

**Spatial grammar:**
- **Interconnected map:** Every room connects to 2-4 adjacent rooms; backtracking reveals new paths
- **Ability gates:** Colored doors (blue door = blue key item; spike-jumping = air-dash ability)
- **Shortcuts:** One-way paths that connect distant sections (elevator, bridge)
- **Hubs:** Central safe areas that connect to multiple biomes
- **Dead ends:** Optional paths that contain treasures or lore, but don't block progression

**Level structure:**
- **Biome:** A thematic region (underground caverns, volcanic chambers, ice caves)
- **Biome unlock:** Typically requires an ability found in a previous biome
- **Revisit:** Once you gain an ability, previous biomes have new accessible areas

**Exploration rewards:**
- Ability upgrades (health max, movement speed, special attack)
- Skill items (double-jump, wall-jump, grapple)
- Lore items (log entries, audio logs, environmental clues)
- Cosmetics (skins, customization)

**Map design principles:**
- **Visibility:** Player should be able to see where they're going (visual sightline to next area)
- **Clarity:** Gate types are visually distinct (spikes ≠ locked door ≠ lava)
- **Shortcut strategy:** Shortcuts should save travel time but not break progression order

**Pacing:**
- Early biome: 1-2 new abilities, 3-5 enemy types, 1-2 minibosses
- Mid biome: 2-3 new abilities, 5-8 enemy types, 2-3 minibosses
- Late biome: 1-2 new abilities + combination of all previous abilities, 8+ enemy types, 1-2 minibosses + final boss

**Common mistakes:**
- "Backtrack hell" — forcing players to traverse long distances without new content
- Gating progression behind required-to-find items without hints
- Making shortcuts obvious early (removes exploration motivation)
- Forgetting to adjust enemy difficulty when abilities scale player power

**References:** Super Metroid (dense map, clear gating), Hollow Knight (ability-based progression + interconnected world), Castlevania: SotN (biome variety + exploration rewards)

---

### 5.4 RPG (Dungeons & Overworld)

**Core challenge:** Navigate exploration spaces, engage in turn-based or real-time combat, discover story.

**Spatial grammar:**
- **Town/hub:** Safe area for shopping, dialogue, resting, party management
- **Overworld:** Large traversal space connecting towns and dungeons
- **Dungeon:** Combat-focused area with puzzle chambers, traps, and boss
- **Story location:** Unique areas with narrative significance (temple, castle, ancient ruin)

**Progression logic:**
- Early game: nearby dungeons, weak enemies (tutorial)
- Mid game: dangerous overworld, mid-tier dungeons, ability-gated areas
- Late game: far dungeons, strong enemies, final dungeon with climactic boss

**Environmental puzzle types:**
- **Spatial:** Navigate through obstacle course (spikes, gaps, moving platforms)
- **Combat:** Defeat enemies to progress (sealed doors)
- **Interaction:** Solve by activating objects in order (pressure plates, levers)
- **Exploration:** Find hidden key/switch (encourages thorough search)

**Pacing in dungeons:**
- **Entry chamber:** Establishes theme and first challenge type
- **Mid dungeon:** Complexity increases; treasure/healing items mid-way
- **Boss chamber:** Peak difficulty; safe room before boss for final prep

**Reward structure:**
- **Small treasures:** Gold, items, gear (every room or two)
- **Major loot:** Equipment upgrade, powerful consumable (major chamber)
- **Story beat:** NPC encounter, plot revelation (thematic placement)

**Common mistakes:**
- "Empty space" — large overworld with nothing to find
- Dungeons that feel copy-pasted (same enemy, same layout repeated)
- Difficulty balance that doesn't account for player progression
- Story moments in combat-heavy dungeons (hard to focus on narrative during threat)

**References:** Final Fantasy VII (dungeon variety + story integration), Zelda: Ocarina of Time (spatial puzzles + ability gates), Chrono Trigger (minimap clarity + shortcut design)

---

### 5.5 Puzzle (Spatial & Logic)

**Core challenge:** Understand a mechanic rule, apply it creatively to overcome obstacles.

**Spatial grammar:**
- **Concept chamber:** Introduce one rule in isolation (player learns, no pressure)
- **Practice chamber:** Repeat the rule with variation
- **Integration chamber:** Combine with previously-learned rules
- **Showcase chamber:** All rules combined in beautiful, satisfying solution

**Difficulty scaling:**
- **Mechanic introduction:** 1 rule, 1 solution
- **Repeat with variation:** 1 rule, 3-4 solutions (player finds one)
- **Combination:** 2 rules, multiple solutions (problem-solving becomes complex)
- **Showcase:** 3+ rules, elegant solution requires lateral thinking

**"Aha" moment design:**
- Setup the problem clearly (visual clarity of what's blocking progress)
- Provide all necessary tools (don't require knowledge outside the game)
- Reward insight (when player figures it out, it *feels* clever)
- Celebrate the solution (slow-mo, visual feedback, progression gate opens)

**Pacing in puzzle games:**
- Cognitive load ramps linearly (not exponentially)
- Rest points = story beats or simpler rooms
- "Aha" moments should be spaced (don't cluster hard puzzles back-to-back)

**Common mistakes:**
- Unclear problem statement (player doesn't know what they're trying to solve)
- Hidden solutions (requiring trial-and-error instead of logic)
- Misleading mechanics (rule works differently than established)
- Solution that's too obscure (clever for the designer, not the player)

**References:** Portal (clear rule → escalating complexity → elegant finale), Tetris Effect (simple rule, infinite solutions), Outer Wilds (exploration + puzzle + revelation)

---

### 5.6 3D Action (Arena-Based)

**Core challenge:** Navigate 3D space, manage camera, engage in real-time combat with positioning.

**Spatial grammar:**
- **Sightline design:** Player can see ahead and behind; no blindspots that spawn enemies
- **Cover placement:** Destructible or temporary cover for tactical positioning
- **Verticality:** Multiple levels (ground, elevated platforms, rooftops)
- **Arena boundaries:** Clear limits (walls, pits, environmental hazards)

**Camera management:**
- Over-the-shoulder typical (fixed offset from player)
- Arena-wide camera pullback for large encounters
- Adjust distance based on threat (closer = tension, farther = context)

**Combat positioning:**
- **Threat zones:** Areas where enemy fire is concentrated
- **Escape routes:** Clear paths to reposition
- **Grenade spawns:** Explosives positioned to reward smart use, not as hazards
- **Elevation:** Height advantage = tactical edge (see-line benefit)

**Pacing:** Single combat encounter can be 2-5 minutes. Multiple encounters break with safe room between.

**Common mistakes:**
- **Sightline issues:** Spawning enemies behind cameras (cheap damage)
- **Cover that's too strong:** Player hides, then game is boring
- **Invisible walls:** World looks open, but movement is blocked
- **Camera clipping:** Camera goes through walls, disorienting player

**References:** Doom 2016 (arena design + vertical space), Batman Arkham City (counter mechanics + arena choreography), Nier: Automata (multiple camera angles + combat variety)

---

### 5.7 Horror (Survival)

**Core challenge:** Navigate threat space while managing limited resources and psychological pressure.

**Spatial grammar:**
- **Safe zones:** Campfire, base camp, locked room (refuge that feels earned)
- **Claustrophobic spaces:** Narrow corridors, underground passages (pressure)
- **Wide-open spaces:** Visual threat (nowhere to hide, exposed)
- **Disorienting spaces:** Maze-like, multiple similar corridors (psychological pressure)
- **Threat spaces:** Where enemies hunt; visibility and escape routes are limited

**Pacing in horror:**
- Long calm sections (player relaxes, defenses drop)
- Brief intense moments (threat attack, narrow escape)
- Rhythm: calm → threat → calm (higher) → worse threat
- Build toward climax without total release (relief comes at end of game)

**Audio/visual design:**
- **Audio cues:** Distant threat (buildup), nearby threat (immediate danger), absence of sound (eerie)
- **Lighting:** Shadows and highlights suggest threat; sudden darkness = vulnerability
- **Music:** Minimal in safe zones, intense during threat, silence is terrifying

**Resource management:**
- Limited ammo, health items, or light sources
- Decision points: "Do I risk going forward or retreat?" (mechanical tension)
- Scarcity makes every resource feel meaningful

**Common mistakes:**
- Overusing jump-scares (player becomes desensitized)
- Threat that's unkillable (player feels powerless, not scared)
- Excessive visibility issues (frustration instead of fear)
- Pacing so intense that player never feels fear (fear requires calm/contrast)

**References:** Resident Evil 4 (controlled threat + resource scarcity), Alien: Isolation (stalking threat + limited hiding), SCP Foundation games (disorienting spaces + invisible threat)

---

## 6. Level Design Tools & Process

### 6.1 Blockout/Greybox — Test Gameplay Before Art

**What:** Build a level with basic shapes (rectangles, cylinders) and placeholder colors before creating final art.

**Why:**
- Test gameplay feels at scale (is the jump distance correct? Can the player navigate this space?)
- Identify pacing issues (is this section boring? Does difficulty spike make sense?)
- Adjust enemy placement and count before art is final
- Fail fast (discover problems before 40 hours of art work)

**Blockout checklist:**
- [ ] Player can move through entire level without clipping
- [ ] Camera behaves correctly (not stuck, can see ahead)
- [ ] Enemies spawn in intended locations
- [ ] Hazards are positioned correctly
- [ ] Safe zones are clearly distinct from danger zones
- [ ] Pacing "feels" right (playtest walk-through without pressure)
- [ ] Difficulty curve is sensible (no sudden difficulty spikes)

**Typical blockout tools:**
- **2D:** Engine's built-in shapes (Godot: Rect2D, rectangles), placeholder tileset
- **3D:** White cubes, simple primitives, flat colors
- **Paper:** Sketch on graph paper, hand-drawn level layout

**Time allocation:** Blockout is typically 10-20% of total level design time. Fast blockout = fast iteration.

**Anti-pattern:** Skipping blockout because you want to "just build the art." Discover problems after art is done = rework art = wasted time.

---

### 6.2 Heatmaps — Where Do Players Die? Where Do They Spend Time?

**What:** Visual overlay showing where player deaths occur, where players spend the most time, where players look.

**Heat map types:**

**Death map:**
- Red zones = high death rate (difficulty spike or confusing mechanic?)
- Blue zones = no deaths (too easy or players avoid?)
- Reveals if difficulty is distributed fairly or spiky

**Dwell time map:**
- Bright areas = players spend long time here (exploration, confusion, or deliberate slowness?)
- Dark areas = players rush through (boring or navigating predictably?)
- Identifies pacing problems

**Gaze map (in first-person/action games):**
- Where does the player's eye focus?
- Reveals if important elements are visible or missed
- Guides UI and visual hierarchy placement

**How to gather data:**
- Playtesting: observe 5+ players, mark where they die and where they linger
- Analytics (for published games): track player positions, deaths, time spent in zones
- Simple logging: record player position every 0.5 seconds, overlay on level map

**Interpreting heatmaps:**
- High death zone + no intended difficulty spike = bad enemy placement, unfair hazard, or mechanic not taught
- High dwell time in empty space = player confusion (lost or uncertain where to go)
- Low dwell time in reward space = reward isn't visible or player didn't notice it

**Action items:**
- Reposition enemies/hazards in high-death zones
- Add visual guidance in high-dwell zones
- Highlight or relocate reward items
- Adjust difficulty curve if spikes are inappropriate

---

### 6.3 Playtesting Cycles

**Cycle structure:**

```
Blockout → Playtest → Analyze → Iterate → Art Pass → Playtest → Polish Pass → Final
```

**Blockout phase:** 1-2 days
- Build white-box level
- Position enemies, hazards, rewards
- Test basic flow (can player move through? Does camera work?)

**First playtest:** 3-5 fresh players
- Minimal guidance ("here's the goal, go")
- Observe: Where do they die? Where do they get lost? What feels slow?
- Record: deaths, dwell times, confusion moments

**Iterate:** 1-2 days
- Move enemies based on death clusters
- Add visual guidance where players got lost
- Adjust enemy difficulty if spikes are too steep
- Re-block architecture if pacing is bad

**Art pass:** 2-5 days
- Add final art assets
- Lighting, particle effects, background
- Music and SFX
- Visual polish

**Second playtest:** 3-5 fresh players (different from first group)
- Test again with final art and audio
- Does art add clarity or confusion?
- Does music enhance or distract from pacing?

**Polish pass:** 1-3 days
- Visual tweaks (color balance, text clarity)
- Camera shake tuning for screen shake feedback
- SFX timing adjustments
- Rare edge cases (what if player sequences challenges in unexpected order?)

**Final pass:** 1 day
- One full playthrough with fresh eyes
- Check for softlocks, clipping, unintended skips
- Verify all victory conditions work

**Total timeline:** 1-2 weeks for a single level, depending on scope.

---

### 6.4 Paper Planning — Sketch Before You Build

**Method:** Sketch level layout on graph paper before opening the engine.

**Sketch checklist:**
- [ ] Player start position
- [ ] End goal or boss location
- [ ] Safe zones (mark with S)
- [ ] Danger zones (mark with D)
- [ ] Transitions between zones (mark with T)
- [ ] Enemy positions and types
- [ ] Hazard locations
- [ ] Treasure/reward locations
- [ ] Camera lock zones (for beat 'em ups)
- [ ] Escape routes (is there a retreat path?)

**Benefits:**
- Fast iteration (erase and redraw takes seconds)
- Communication (share sketch with team, everyone sees the design)
- Constraint (forces simplicity; complex paper sketch = over-scoped level)

**Example sketch (beat 'em up wave):**
```
CAMERA LOCK BOUNDARY
┌─────────────────────────────────────────┐
│                                         │
│  [SPAWN] ← E1   E2      E3 (elite) →   │
│              ▁▁▁▁▁▁▁▁▁▁ (hazard)      │
│         ^                             │
│         │ (reward coin)                │
│         S (safe zone at start)        │
│                                         │
└─────────────────────────────────────────┘
```

**Time:** 10-15 minutes per level sketch. Fast enough to sketch 5 level variations and compare.

---

### 6.5 Modular Design — Reusable Pieces

**Concept:** Build level sections that combine into varied environments without duplicating artwork.

**Modular principles:**
- **Tile size:** Standard unit (e.g., 32px × 32px tiles) that combines into larger structures
- **Semantic variation:** One tile type with multiple visual appearances (grass tile in 4 rotations, 3 states of decay)
- **Piece composability:** An "arena" is built from 4 standard tiles arranged differently each time
- **Content variation:** Enemies/hazards placed in modular tile arrangements without duplicating tiles

**Benefits:**
- Artist creates 20 tile variations; designer combines them into 100 unique-feeling levels
- Asset reuse reduces file size and memory footprint
- Changes to a tile update everywhere automatically
- Faster iteration (move tiles around, don't redraw)

**Example (beat 'em up backgrounds):**
- **Base module:** 2-building cluster (factory + shop, school + house, etc.)
- **Far layer:** Distant building silhouettes (repeated every 2-3 clusters)
- **Mid layer:** Poles, signs, vehicles (placed between buildings)
- **Foreground:** Trees, barriers, foreground elements (layered at 50% alpha)
- **Hazard module:** Spikes, lava, electric tiles (reused across waves)

**Modular vs. bespoke:** Use modular for fast iteration in early development; shift toward bespoke art as you near completion (final levels should feel unique, not cookie-cutter).

**Anti-pattern:** Using the exact same tile arrangement in multiple levels (feels repetitive). Modular design should create *variety* through composition, not *sameness* through copy-paste.

---

## 7. Camera & View Design

### 7.1 Side-Scroll (2D Platformer & Beat 'em Up)

**Standard setup:**
- Fixed horizontal view
- Player is 1/3 from left side of screen (not centered)
- Vertical view extends 1.5× player jump height above and below player

**Pan ahead:** When player moves forward, camera pans slightly ahead (telegraphs upcoming threat).

**Lock zones:** In beat 'em ups, camera locks to arena boundaries (waves don't scroll).

**Parallax:** Background layers move at fractional speed (0.3× to 0.8× main camera speed) to suggest depth.

**Vertical adjustment:** If hazard is above or below player, camera adjusts to keep it visible (don't lock hazards off-screen).

### 7.2 Top-Down (Dungeon, Overworld)

**Standard setup:**
- Full 360° movement visibility
- Player centered or slightly offset (avoid screen edge disorientation)
- Rotation: does the camera rotate with player? (common in twin-stick shooters, rare in grid-based RPGs)

**UI overlay:** Top-down often shows map, health, inventory; ensure overlay doesn't block level visibility.

**Sightline:** Player can see 1.5-2× their melee range ahead (balance discovery vs. planning).

### 7.3 Third-Person (3D Action)

**Over-the-shoulder:** Offset camera 1-2m behind and 1m right of player.

**Distance:** Adjusts based on threat (closer for intense combat, farther for exploration).

**Collision:** Camera pushes away from walls (reveal space instead of zooming in).

**Cinematic moments:** Disable player control, let camera perform a pan or zoom (story beat).

### 7.4 First-Person (FPS, Immersive Sim)

**Field of view:** 90° is standard (balance peripheral vision vs. immersion).

**Motion:** Smooth, no sudden rotations (prevents motion sickness).

**Bobbing:** Slight vertical camera sway when walking (feels natural; 0.5-1° oscillation is typical).

**Lean:** Ability to peek around corners without exposing full body.

### 7.5 Dynamic Camera

**Zoom:** Camera zooms in/out based on situation (threat = zoom in for intensity; safe = zoom out for context).

**Shake:** Brief oscillation on impact (covered in game-feel-juice skill).

**Pan:** Smooth camera movement to emphasize a story moment or threat.

**Lock-on:** Camera follows enemy for multi-opponent combat (used in action RPGs like DMC or Souls games).

---

## 8. Secrets & Exploration Rewards

### 8.1 Hidden Path Design: Visible-If-You-Look-Carefully

**Principle:** A secret is not a secret if it's invisible. A secret is something the attentive player notices.

**Visibility spectrum:**
- **Obvious:** Visual highlight, clear path, no searching (not a secret)
- **Noticeable:** Attentive player spots it (slight color contrast, off-beat detail)
- **Hidden:** Requires effort to find (behind object, above sightline, requires jumping to area)
- **Obscure:** Extremely well hidden (speedrunner-level search)

**Good secret design:** Tier 2-3. Obvious enough that observant players find them; hidden enough that casual players miss them.

**Visual tricks:**
- Slightly brighter/darker alcove (draws eye)
- Unusual detail that doesn't match surroundings (stands out)
- Dead-end path that looks deliberate (hidden reward worth the detour)
- Partially visible object (hint of what's there)

**Positional hiding:**
- Above sightline (requires jumping or climbing)
- Behind transparent foreground (obscured but visible)
- Off the main path (requires backtracking)
- In a thematically appropriate location (fits the world)

### 8.2 Risk/Reward Placement

**Concept:** Harder paths yield better rewards; easy paths yield standard rewards.

**Examples:**
- **Safe route:** Follow the main path, defeat enemies, collect coins
- **Risky route:** Bypass enemies, jump over spike pit, reach hidden treasure room with 3× coins

**Player agency:** "I can take the safe path (guaranteed success) or the risky path (higher reward, but requires skill)."

**Tuning:** Safe path should always be viable (no "you must take risky path to progress"). Risky path should be noticeably better (2-3× rewards minimum).

### 8.3 Collectibles: Purpose Determines Design

**Type 1: Currency**
- Purpose: Unlock upgrades, buy items
- Placement: Scattered across normal path, concentrated in risky paths
- Density: Enough to feel meaningful progression, not so many that they clutter the screen

**Type 2: Lore/Story**
- Purpose: World-building, character development, hidden narrative
- Placement: Require active exploration (off main path)
- Density: Sparse (if you find all of them, you've really *explored*)

**Type 3: Completion**
- Purpose: 100% completion achievement
- Placement: Mix of easy (to feel progress) and hard (final challenge)
- Density: Usually 50-100 per world (game feel depends on your game)

**Type 4: Power**
- Purpose: Permanent stat increase (health, strength, skill upgrade)
- Placement: Reward for overcoming challenges or hidden in secret areas
- Density: Limited (too many breaks progression balance)

### 8.4 Easter Eggs: Fan Service Without Breaking Pacing

**Principle:** Easter eggs are rewards for *knowledge*, not for *searching randomly*.

**Good Easter egg design:**
- Requires specific action or knowledge to trigger
- Doesn't interrupt gameplay (appears as visual detail, not a cutscene)
- Fan service that delights without confusing new players
- Multiple layers (casual players see one joke, hardcore fans see deeper references)

**Example:** firstPunch — a Treehouse of Horror reference in one specific level that only activates if you interact with a specific object. Players who know the show smile; players who don't see it and aren't confused.

**Bad Easter egg design:**
- Requires hours of grinding to find
- Interrupts pacing with a mandatory cutscene
- Requires knowledge outside the game to understand
- References are mean-spirited or obscure

### 8.5 Completionist Design: 100% Should Feel Satisfying

**Principle:** Players who want to find everything should feel rewarded for the effort, not punished.

**Completionist checklist:**
- [ ] Collectibles are findable (not RNG, not procedural generation of locations)
- [ ] Finding everything yields something meaningful (power boost, new ability, lore unlock)
- [ ] The process isn't tedious (if collecting 100 items, each one is interesting, not a copy-paste task)
- [ ] 100% completion is achievable without perfect play (allows mistakes/skill variance)
- [ ] Completionists are celebrated (unlock bonus mode, special achievement, or story acknowledgment)

**Anti-pattern:** 100% completion requiring:
- Perfect blind speedrun (unfair)
- Grinding same activity 1000 times (tedious)
- Content that contradicts world lore (confusing)
- Rewards so powerful they break balance (frustrating for non-completionists)

---

## 9. Anti-Patterns: What NOT To Do

### 9.1 "The Corridor"

**What:** A long, linear path with no choices, no exploration, no surprises. Player follows a tunnel to the next arena.

**Why it's bad:**
- Feels like a tutorial zone (on-rails, no agency)
- Wastes time between real challenges
- Player attention drops (nothing interesting to look at)
- Pacing dies (no tension, no release, just travel)

**How to fix it:**
- Add environmental variety (curve the path, change lighting, introduce thematic details)
- Add mini-challenges (one weak enemy, a jump puzzle, a narrowing path)
- Add exploration hooks (optional side paths, collectibles, visual storytelling)
- Keep it short (< 30 seconds of movement)

**Good corridor:** Dark Souls elevator (thematic, player can observe ahead, reveals story through environment).
**Bad corridor:** Long hallway between combat arenas with no detail.

### 9.2 "Empty Space"

**What:** Large areas with nothing to do, no enemies, no hazards, no reason to be there.

**Why it's bad:**
- Player gets bored waiting for something to happen
- Pacing dies (no tension buildup)
- World feels dead or unfinished
- Player assumes they're lost

**How to fix it:**
- Add environmental details (lore, visual storytelling)
- Add exploration rewards (collectibles, secret areas)
- Add enemies/hazards (something to do)
- Reduce the space (if there's nothing there, don't make it big)
- Change the pacing (slower-paced exploration with meaningful discovery)

**Good empty space:** BotW shrine of resurrection (minimalist, intentional, player builds their first build, progression is clear)
**Bad empty space:** Hallway with no details, no enemy spawns, just travel

### 9.3 "Difficulty Wall"

**What:** Sudden spike in difficulty with no preparation. Safe section → instant lethal challenge.

**Why it's bad:**
- Teaches nothing (no gradual introduction)
- Feels unfair (player wasn't warned)
- Breaks pacing (no build-up)
- Frustrates (player dies without understanding why)

**How to fix it:**
- Introduce new threat type in low-stress version first
- Gradually increase intensity (1 enemy → 2 → 3 with hazard)
- Space out difficulty increases (one per level section)
- Provide safe checkpoint before major difficulty spike

**Good difficulty ramp:** Celeste (each screen introduces one challenge, difficulty builds screen-by-screen)
**Bad difficulty ramp:** Jump from tutorial level (1 enemy) to mid-boss (3 enemies + 5 hazards)

### 9.4 "Backtrack Hell"

**What:** Forcing players to traverse long distances repeatedly without new content.

**Why it's bad:**
- Wastes player time
- Breaks pacing (no meaningful progression)
- Frustrates (feels like punishment)
- World feels small if players keep seeing the same paths

**How to fix it:**
- Add shortcuts (one-way paths that reduce travel time)
- Add new content on revisit (enemies repositioned, new hazards, story beats)
- Fast travel between visited areas
- Minimize required backtracking (design so players move forward when possible)

**Good backtracking:** Metroidvania where gaining an ability reveals new paths in old areas (revisit feels rewarding)
**Bad backtracking:** Dungeon where you must traverse 5 rooms to get back to the start after each boss attempt

### 9.5 "Copy-Paste Rooms"

**What:** Identical layouts repeated throughout the level (same enemy arrangement, same architecture, minor color swaps).

**Why it's bad:**
- Feels generated or lazy (immersion breaks)
- Predictable (no surprises)
- Boring (same challenge repeated, not learned from)
- Suggests the game ran out of ideas

**How to fix it:**
- Add variation (enemy count changes, positions shift, hazards differ)
- Use modular design intentionally (same tiles, different arrangement each time)
- Add contextual details (progression feels different in different areas)
- Reference the world (why does this room look like the last? Maybe it's meant to?)

**Good repetition:** Grid-based dungeons where room *structure* is consistent but *content* varies (players learn the space's logic, then content surprises them)
**Bad repetition:** Three identical arena rooms in a row with different enemy colors

---

## 10. The Level Design Process at a Glance

```
1. CONCEIVE
   ├─ Define genre and core mechanic
   ├─ Sketch on paper (10 min)
   └─ Identify level purpose (teach/test/reward)

2. BLOCKOUT
   ├─ Build white-box in engine (1-2 days)
   ├─ Rapid iteration on layout
   └─ Test with one team member

3. FIRST PLAYTEST
   ├─ 3-5 external players (fresh eyes)
   ├─ Gather data: deaths, dwell time, confusion
   └─ Identify problem zones

4. ITERATE
   ├─ Reposition enemies/hazards (1-2 days)
   ├─ Adjust difficulty/pacing
   └─ Playtest one more round with blockout

5. ART PASS
   ├─ Final visuals, lighting, effects (2-5 days)
   ├─ Audio: music, SFX
   └─ Visual polish

6. SECOND PLAYTEST
   ├─ 3-5 new players with final art
   ├─ Verify clarity (does art help or confuse?)
   └─ Gather feedback on feel/pacing

7. POLISH
   ├─ Camera tuning, visual tweaks (1-3 days)
   ├─ Edge case testing
   └─ One final full playthrough

8. SHIP
   └─ Level is done
```

---

## 11. References & Further Reading

### Landmark Games by Genre

| Genre | Reference | Why Study It |
|-------|-----------|-------------|
| **Platformer** | Celeste | Escalating difficulty, fairness, level communication |
| **Beat 'em Up** | Streets of Rage 4 | Wave progression, camera locks, juice + challenge |
| **Metroidvania** | Super Metroid | Interconnected design, ability gates, shortcuts |
| **Puzzle** | Portal | Mechanic introduction, escalation, beautiful solutions |
| **RPG** | Final Fantasy VII | Dungeon variety, pacing, story integration |
| **3D Action** | Doom 2016 | Arena design, verticality, threat management |
| **Horror** | Alien: Isolation | Pacing, tension, resource scarcity |
| **Open World** | The Legend of Zelda: Breath of the Wild | Player agency, exploration rewards, non-linear progression |

### Key Design Documents to Study

- **Level Design Documentation Template:** Papers with sketches, intensity maps, blockout images
- **Dark Souls Design:** Interconnected world map documentation, ability-gating systems
- **Celeste Development:** Climate and difficulty scaling analysis
- **Portal Design:** Escalation structures and "aha moment" pedagogy

### Tools to Learn

- **Paper & pencil:** Fastest iteration
- **Your engine's level editor:** Learn it deeply
- **Heatmap tools:** Custom logging or engine-provided analytics
- **Playtesting frameworks:** Structured observation protocols

---

## 12. Summary: The Universal Principles

1. **Levels teach through design.** The level IS the tutorial. Introduce, repeat, combine.

2. **Spatial grammar creates meaning.** Safe → Transition → Danger → Reward is the fundamental rhythm.

3. **Pacing is emotional architecture.** Build tension, release, build higher. Never stay at max intensity forever.

4. **The level tells story.** Visual details, enemy placement, and environment speak louder than dialogue.

5. **Genre shapes application, not principle.** Platformers, beat 'em ups, Metroidvanias—same core grammar, different expression.

6. **Blockout before art.** Test gameplay fast; fail early; iterate cheaply.

7. **Playtest with fresh eyes.** Your instincts are biased; five external players are truth.

8. **Secrets are for careful observers.** Hidden doesn't mean invisible; it means "visible if you look."

9. **Difficulty scales intentionally.** Spikes should feel earned, not arbitrary.

10. **The player's experience is the metric.** Measure success by heatmaps and playtesting feedback, not by your design document.

---

**Confidence Level: `low`** — This is the first formal documentation of universal level design fundamentals beyond beat 'em up specifics. Genre-specific sections will need playtesting and iteration. Recommend expanding with live case studies from your next project.

**Cross-Reference:** Links to game-design-fundamentals (pacing, difficulty, player agency), game-feel-juice (camera shake, feedback), and genre-specific skills (procedural-audio, animation patterns).

**Next Iteration:** After working through 2-3 complete level designs across different genres, elevate confidence to `medium` and add case studies from those projects.
