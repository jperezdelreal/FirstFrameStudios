# Game Development Knowledge Base — Part 1

> **Purpose:** Institutional knowledge across 10 game dev disciplines, built from SimpsonsKong experience and industry research.
> **Scope:** Part 1 covers disciplines 1–5. Part 2 covers disciplines 6–10.
> **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up (HTML5 Canvas, ES modules, Web Audio API)

---

## Discipline 1: Game Design Fundamentals

### Core Principles

- **Core loop is king.** Every game reduces to a loop the player repeats hundreds of times. If Approach → Attack → Combo Ender doesn't feel good on repetition 500, nothing else matters. Design the loop first, build everything else around it.
- **Flow state requires calibrated difficulty.** Csikszentmihalyi's flow channel applies directly: too easy breeds boredom, too hard breeds frustration. The sweet spot is when the player is *barely* succeeding. Difficulty curves should ramp in steps with recovery valleys, never linearly.
- **Feedback loops amplify or dampen behavior.** Positive feedback (combo counters, score multipliers) encourages aggression. Negative feedback (health loss, enemy scaling) punishes recklessness. The best games layer both — SoR4's health-cost specials with recovery-on-hit is a textbook dual feedback loop.
- **Risk/reward is the engine of engagement.** Every meaningful player decision should trade safety for reward. Taunting for meter (Shredder's Revenge), spending health on specials (SoR2/4), and staying in combat range for combo extensions all embody this.
- **Player motivation is intrinsic AND extrinsic.** The *feel* of punching (intrinsic) hooks players in the first session. Unlockable characters, leaderboards, and progression (extrinsic) bring them back for session ten.

### Best Practices from Reference Games

SoR4's 12 difficulty levels let every player find their flow channel. Castle Crashers layered stat allocation onto a simple core loop, adding depth without complexity. Shredder's Revenge's per-level challenges created micro-goals within macro-progression.

### Common Mistakes

- Designing systems before the core loop is fun. Architecture doesn't matter if the punching feels limp.
- Flat difficulty — no valleys after peaks. Players need breathing room.
- Confusing difficulty with unfairness. Cheap hits and unclear tells aren't "hard," they're broken.
- Over-relying on extrinsic motivation. If the core loop isn't satisfying, no amount of unlockables will save it.

### Application to SimpsonsKong

Our PPK combo (42 dmg/1.1s) is the core loop foundation. All balance flows from it. The Donut Rage Mode and health-cost specials create the risk/reward layer. Comedy as a mechanic (D'oh! Moments, funny failure states) provides intrinsic motivation unique to our IP. Our difficulty curve must account for browser-game session lengths (5–15 minutes).

### Learnings for Future Projects

Define and playtest the core loop before building any surrounding systems. Validate flow state with real players early — designer intuition is necessary but insufficient. Budget for at least 3 difficulty tuning passes.

---

## Discipline 2: Combat System Design (Beat 'Em Up)

### Core Principles

- **Frame data is the skeleton of combat feel.** Startup frames create anticipation, active frames define the hit window, recovery frames create vulnerability. A jab with 3f startup / 4f active / 6f recovery *feels* fast. A heavy with 8f / 6f / 12f *feels* committed. These numbers are the difference between responsive and sluggish.
- **Hitbox/hurtbox separation is non-negotiable.** The attack's damaging area (hitbox) must be separate from the character's vulnerable area (hurtbox). Overlapping them creates trades on every attack, which feels unfair. Hitboxes should extend slightly beyond the visual to be generous to the player.
- **Combo systems must reward skill without punishing mastery's absence.** Mashing attack should produce a satisfying string. Deliberate timing should extend combos. The gap between floor and ceiling is the game's depth.
- **Crowd control defines the skill ceiling.** Positioning on the 2.5D plane, knockdown management, juggle decisions — these are what separate a button-masher from an expert. The 2-attacker throttle keeps combat readable while the player manages the wider crowd.
- **Game feel ("juice") is 50% of combat quality.** Hitlag (2–4 frames), screen shake, hit flash, impact particles, knockback animation, and SFX variation transform identical mechanics from lifeless to visceral.

### Best Practices from Reference Games

SoR4's variable hitstop (light = 2f, heavy = 4f+) communicates weight through time. Final Fight's grab → piledriver loop remains the genre's most satisfying micro-interaction 35 years later. Turtles in Time proved that spectacle moves (screen-throw) can be both stylish AND strategic. Shredder's Revenge's dodge roll with i-frames is now expected in modern entries.

### Common Mistakes

- Jump attacks that dominate all other options (air-spam). We addressed this: landing lag + DPS cap (target 38, down from 50).
- Hitboxes that match visuals exactly — feels unfair. Be generous to the player, strict on enemies.
- No invulnerability frames after taking damage, creating inescapable damage loops.
- Identical hit reactions regardless of attack strength. A jab and a heavy should produce visibly different reactions.

### Application to SimpsonsKong

Rectangle collision detection works for our scope. Our combat uses knockback physics, hitstun, and screen shake already. Biggest gaps: grab/throw depth, special move variety, and hit SFX variation. The 2-attacker throttle is a design principle we've committed to. Each character must feel different within 10 seconds — this is a binding constraint validated by Final Fight's archetype trinity.

### Learnings for Future Projects

Build a frame data spreadsheet before coding combat. Implement hitlag from day one — retrofitting it is painful. Budget separate tuning time for single-enemy feel vs. crowd feel; they require different balancing.

---

## Discipline 3: Level Design

### Core Principles

- **Pacing is rhythm, not monotony.** Levels follow an intensity wave: walk-in (mood) → easy encounter → scroll → new element → spike → mix → boss. Every peak needs a valley. SoR4's elevator level is a masterclass in escalating tension precisely because it alternates pressure with brief respites.
- **Camera locks create arenas.** The screen stops scrolling, enemies spawn, and the player must clear them to progress. Frequency matters — too many feels like a gauntlet, too few makes traversal boring. 3–5 locks per level is the genre standard.
- **Environmental storytelling replaces cutscenes.** In beat 'em ups, narrative lives in the environment: destructible objects tell you "a fight happened here," hazards tell you "this place is dangerous," and set pieces tell you "something extraordinary is happening." Springfield locations (Moe's Tavern, the power plant, Krustyland) should feel like the show.
- **Spawn placement is invisible difficulty tuning.** Where enemies appear, from which direction, and in what combinations is the primary difficulty lever. Flanking spawns are harder than frontal. Mixed types (grunt + ranged + shield) are harder than homogeneous groups. Never introduce more than one new enemy type per encounter.
- **Set pieces break monotony.** Unique moments — riding a vehicle, a chase sequence, a scrolling hazard — prevent formula fatigue. Turtles in Time's surfboard level and SoR2's pirate ship work because they're rare and memorable.

### Best Practices from Reference Games

The original Simpsons Arcade turned Springfield locations into combat arenas, making fans feel *inside* the show. Scott Pilgrim's world map gave players agency over level order. Shredder's Revenge layered per-level challenges (no-hit, find collectibles) onto standard progression for replay incentive.

### Common Mistakes

- Constant high intensity with no valleys. Players need micro-rest moments to appreciate the peaks.
- Spawning enemies from off-screen behind the player without audio/visual warning. Feels cheap.
- Levels that are visually distinct but mechanically identical. Theme changes must bring new encounter designs.
- Forgetting that camera boundaries *are* level design. A badly placed camera lock can make an easy fight frustrating.

### Application to SimpsonsKong

Wave-based progression with camera locks is already implemented. Our biggest level design opportunities: environmental hazards that affect enemies too (throwing goons into Springfield landmarks), destructible objects for health/weapons, and pacing variation between encounters. Springfield's iconic locations are our strongest asset — each should feel like an episode set.

### Learnings for Future Projects

Paper-map levels before building them. Mark intensity on a 1–10 scale per encounter and plot the wave. Playtest pacing before polishing art — a well-paced ugly level is more fun than a beautiful monotonous one.

---

## Discipline 4: Character Design

### Core Principles

- **Silhouette theory: identify at a glance.** Every character must be recognizable from silhouette alone. Homer (round, large), Bart (spiky head, small), Marge (tall hair tower), Lisa (star-shaped hair) — the Simpsons IP gives us this for free. In gameplay, silhouette communicates character class: wide = power, narrow = speed.
- **Archetype differentiation is felt, not explained.** Final Fight established the trinity: slow/powerful (Haggar/Homer), balanced (Cody), fast/technical (Guy/Bart). The difference must be apparent within 10 seconds of play — not through stats screens, but through animation speed, attack range, and screen impact. This is a binding constraint.
- **Animation principles sell character.** Squash-and-stretch on attacks, anticipation frames before heavy moves, follow-through after swings. These 12 Disney principles apply directly to game animation. Even with procedural Canvas art (~400 LOC per character), these principles differentiate "moves" from "animations."
- **Expression through states defines personality.** Idle animations, hit reactions, victory poses, and especially *failure states* reveal character. Homer's D'oh! on taking damage, Bart's "Eat my shorts" taunt, Lisa's exasperated sigh — the Simpsons' comedic personality lives in their reactions, not their attacks.

### Best Practices from Reference Games

Castle Crashers gave each of 30+ characters a unique elemental identity through magic color alone. Dragon's Crown made classes feel fundamentally different — Sorceress played nothing like Fighter. Shredder's Revenge differentiated 7 turtles + allies through reach, speed, and super move spectacle. Scott Pilgrim used pixel art expressiveness to give characters personality despite limited frames.

### Common Mistakes

- Palette-swap characters that play identically. Different colors aren't different characters.
- Balancing by making all characters converge toward the same DPS. Diversity of feel matters more than numerical balance.
- Neglecting hit reactions and failure states. Players see these more than victory poses — they *are* the character's personality during gameplay.
- Over-animating idle and under-animating combat. Combat frames are where players spend 90% of their attention.

### Application to SimpsonsKong

Procedural Canvas art is our current approach (~400 LOC per character). The Simpsons IP provides perfect silhouette differentiation. Our biggest character design challenge: adding Bart/Marge/Lisa means ~1200 LOC of Canvas drawing code — this is the strongest argument for eventual Phaser 3 + sprite sheet migration. D'oh! Moments (funny failure states) are prioritized over victory celebrations, which is the comedy pillar in action. Donut Rage Mode is Homer's signature mechanic and must ship with his "complete" build.

### Learnings for Future Projects

Design characters from silhouette outward, not detail inward. Prototype the feel (speed, range, weight) before the visuals. Failure states and hit reactions deserve as much design attention as attacks — players see them constantly.

---

## Discipline 5: Audio Design

### Core Principles

- **Audio is 50% of game feel.** Remove the sound from any beat 'em up and combat feels hollow. The crunch of a landed punch, the whoosh of a whiff, the crack of a bat — these aren't decoration, they're feedback. Muting SoR4 reduces its feel quality by half. Audio is not a polish pass; it's a core system.
- **Dynamic music responds to gameplay state.** Intensity-matched audio keeps players emotionally synchronized with the action. Exploration gets ambient layers; combat adds percussion and intensity; boss fights bring the full arrangement. Transitions should be musical (on beat/bar boundaries), not abrupt.
- **Sound layering creates richness without cacophony.** A single punch hit uses 3–5 layered sounds: impact thud, flesh hit, reaction grunt, environmental reverb, optional crunch/crackle. Each layer can be independently varied for freshness. SFX variation (3–5 variants per action) prevents audio fatigue — hearing the same punch sound 500 times becomes subliminal torture.
- **Silence is a design tool.** A brief moment of quiet before a boss entrance, the audio dropping out before a climactic hit, ambient sound after clearing an encounter — silence creates contrast that makes the loud moments louder. Games that fill every millisecond with sound lose their dynamic range.
- **Procedural vs. recorded audio is a spectrum, not a binary.** Web Audio API enables procedural SFX (synthesized hits, dynamic pitch variation, generated ambience) that are lightweight and infinitely variable. Recorded audio has higher fidelity but is static and file-heavy. Browser games benefit from a hybrid: procedural for frequent sounds (punches, footsteps), recorded for signature moments (character voice lines, boss themes).

### Best Practices from Reference Games

SoR2's Yuzo Koshiro soundtrack set the bar for genre audio — electronic music that matched the urban aesthetic and varied by stage mood. SoR4 uses variable hit sounds that scale with combo count, making long combos sound increasingly impactful. Shredder's Revenge's audio punctuates super moves with brief silence before the hit, maximizing impact through contrast. The original Simpsons Arcade used voice samples sparingly but memorably — Homer's "D'oh!" became iconic through restraint.

### Common Mistakes

- Treating audio as a polish-phase task. By that point, the game's feel is established without it and audio feels "added on" rather than integrated.
- Single-variant SFX for frequent actions. One punch sound repeated 500 times per session is actively harmful.
- Music that doesn't respond to gameplay state. Static loops disconnect the player from the action's emotional arc.
- Audio mix that drowns out feedback sounds with music. Player-action SFX must always cut through the mix.

### Application to SimpsonsKong

Web Audio API is our audio foundation, enabling procedural SFX generation — lightweight and infinitely variable. Greedo (Sound Designer) owns this domain with 7 backlog items including procedural SFX library and music generation. Our procedural approach is ideal for hit sound variation (pitch shift, layering). Simpsons voice lines ("D'oh!", "Eat my shorts!") should be rare and impactful — restraint makes them memorable. Current gap: hit SFX variation is the highest-impact audio work remaining.

### Learnings for Future Projects

Integrate audio from the first playable build, not the last polish pass. Budget for 3–5 variants of every frequent sound. Procedural audio (Web Audio API, synthesized SFX) is underexplored in indie/browser games and provides infinite variation at zero file cost. Define an audio mix hierarchy early: player SFX > enemy SFX > ambient > music.

---

> **Next:** Part 2 covers Discipline 6 (UI/UX Design), Discipline 7 (Technical Architecture), Discipline 8 (Production & Project Management), Discipline 9 (Playtesting & QA), and Discipline 10 (IP Integration & Tone).
