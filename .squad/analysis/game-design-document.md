# firstPunch — Game Design Document

> Compressed from 44KB. Full: game-design-document-archive.md

> **Author:** Yoda (Game Designer)  
> **Date:** 2025  
---

## 1. Game Vision Statement
firstPunch is a browser-based beat 'em up that captures the chaotic joy of being *inside* a game episode — fists first. Players should feel the slapstick weight of Brawler's belly bounce, laugh when Kid taunts a room full of goons, and grin when a perfectly timed combo earns them a "Best. Combo. Ever." rating. This isn't a game that happens to have game characters; it's a game where the comedy IS the combat, where Downtown's landmarks are weapons and arenas, and where every punch lands with the exaggerated, cartoon-physics satisfaction that only the source IP universe can deliver. Built for the browser, it's instant joy — no downloads, no installs, just click and punch. The goal: make players laugh, feel powerful, and immediately want to try the next character.
---

## 2. Design Pillars
Every design decision must pass through these four pillars. If a feature doesn't serve at least one pillar, it doesn't belong.
### Pillar 1: Comedy as a Core Mechanic
### Pillar 2: Accessible Depth
### Pillar 3: Family Synergy
### Pillar 4: Downtown Is a Character
---

## 3. Player Experience Goals
These define the emotional arc of the game — what the player should FEEL at each milestone.
### First 10 Seconds
### First 30 Seconds
### First Minute
### First Level Complete
---

## 4. Core Combat Design
The combat system is the heart of firstPunch. It draws from the genre's best: Streets of Rage 4's depth, Turtles in Time's spectacle, Shredder's Revenge's modern feel, and the original classic arcade beat 'em ups's authenticity.
### 4.1 Inputs & Controls
| Input | Action | Notes |
| Direction (WASD / Arrows) | Move (4-direction, 2.5D) | Horizontal movement faster than vertical (depth) |
| Attack (J / Z) | Light attack (punch) | Foundation of all combos |
| Heavy (K / X) | Heavy attack (kick) | Slower, stronger, combo finisher |
| Jump (Space) | Jump | Parabolic arc, enables aerial combat |
| Special (L / C) | Special move | Costs health (SoR2 model), powerful crowd clear |
---

## 5. Character Design Philosophy
Each playable character must feel **completely different within 10 seconds of play** — not just a stat swap, but a fundamentally different combat experience.
### 5.1 The Character Triangle
### 5.2 the Brawler — The All-Rounder
| Stat | Value | Notes |
| Speed | ★★★☆☆ | Medium — Brawler isn't fast, but he's not slow |
| Power | ★★★★☆ | Strong — his hits are meaty, satisfying |
| Range | ★★☆☆☆ | Short — he's a brawler, in your face |
| Defense | ★★★★☆ | Tanky — Brawler takes punishment like a champ |
---

## 6. Enemy Design Philosophy
Enemies are the game's vocabulary. Each type teaches the player a new word; encounters combine words into sentences; levels compose sentences into stories.
### 6.1 The Enemy Vocabulary
| Type | Name (game) | HP | Speed | Behavior | Counter Strategy | Teaches Player... |
| **Grunt** | Mayor's Goon | 30 | Medium | Walk toward player, basic punch | Any attack | Basic combat flow |
| **Tough** | Plant Security | 70 | Slow | Same as grunt, more HP, hits harder (10 dmg) | Sustained combos, patience | Commitment and combo chains |
| **Dasher** | Bruiser's Bully | 25 | Fast | Sprint at player, tackle, retreat | Dodge/jump, punish recovery | Timing and dodge usage |
| **Ranged** | Knife Thrower (street thug) | 20 | Medium | Throws projectiles from distance, retreats on approach | Close distance quickly, prioritize | Target prioritization |
| **Shield** | Riot Cop | 40 | Slow | Blocks frontal attacks, advances slowly | Grab, jump attack, flank | Positional thinking |
---

## 7. Level Design Philosophy
Levels follow the proven beat 'em up structure but infuse it with Downtown's identity.
### 7.1 Pacing Template
### 7.2 Downtown Levels
| Level | Location | Visual Theme | Unique Hazard | Interactive Elements | Boss |
| 1 | Downtown Downtown | Daytime streets, shops, Donut Shop statue | Traffic (cars cross occasionally) | Throw enemies into Donut Shop's donut; smash a neighbor's mailbox; break Quick Stop window | Ringleader |
| 2 | Factory | Industrial, green glow, cooling towers | Toxic barrels (damage zones) | Push enemies into acid pools; use pipes as weapons; ride conveyor belts | the Mayor in mech suit |
| 3 | Joe's Bar → Squidport | Night scene, neon signs, waterfront | Wet floor (slip physics near dock) | Throw enemies into jukebox; use bar stools as weapons; knock enemies off the pier | Fat Tony |
| 4 | City School → Treehouse | Schoolyard, playground, treehouse | Playground equipment (swings hit passersby) | Use dodgeballs as projectiles; slide down banister; launch enemies off seesaw | Bruiser + Jimbo + Dolph (trio boss) |
---

## 8. Progression & Replayability
### 8.1 Progression Model
firstPunch uses the **Neo-Retro** model (SoR4 / Shredder's Revenge): per-run scoring with unlockable content and difficulty modes. Light RPG elements are layered in without overwhelming browser-game scope.
### 8.2 Score System with Style Bonuses
| Action | Points | Multiplier |
| Punch hit | 10 | — |
| Kick hit | 15 | — |
| Combo finisher (3+ chain) | 25 | ×combo_count |
| Grab throw | 30 | — |
---

## 9. Web Platform Constraints & Future Migration
firstPunch is built for the browser (HTML5 Canvas 2D, Web Audio API, vanilla JS). This is a strength — instant play, zero friction — but it imposes constraints. This section documents what we CAN do, what we CANNOT do, and what belongs in a "Future: Native/Engine Migration" roadmap.
### 9.1 What We Can Do Well on Canvas 2D
| Capability | Approach | Quality Ceiling |
| Character rendering | Procedural Canvas draw + sprite sheets (when ready) | Good — distinct, readable characters |
| Frame-based animation | Canvas drawImage with sprite atlas | Good — smooth 60 FPS |
| 2.5D depth sorting | Y-sort entity array each frame | Good — standard technique |
| Particle effects (light) | Object pooling, 30-50 particles max | Adequate — dust, sparks, simple bursts |
| Screen shake / flash | Camera offset + overlay rect | Good — standard game feel |
---

## 10. game-Specific Mechanics
These are the features that make firstPunch *uniquely game* — mechanics no other beat 'em up can replicate because they're born from the IP.
### 10.1 Brawler's Rage Mode
### 10.2 Ugh! Moments (Funny Failure States)
### 10.3 Couch Gag Loading Screens
### 10.4 Downtown Landmarks as Interactive Elements
| Landmark | Level | Interaction |
| Donut Shop Donut | Downtown | Throw enemy into statue → giant donut falls, damages area |
| Quick Stop | Downtown | Break window → shopkeeper yells "Come again!" + drops health item |
---

## 11. Current State vs. Vision (Gap Summary)
Based on the gap analysis and balance analysis, here is where we are relative to this GDD's vision:
| GDD Section | Current State | Gap | Priority |
| Basic combo (PPK) | ✅ Damage scaling works | Need combo counter UI, hit feedback | P1 |
| Grab/throw | ❌ Not implemented | Full system needed | P2 |
| Special moves | ❌ Not implemented | Health-cost specials, 3 per character | P2 |
| Dodge roll | ❌ Not implemented | Core defensive mechanic | P1 |
| Jump attacks | ⚠️ Implemented but OP | Needs landing lag, DPS rebalance | P1 |
| Weapon pickups | ❌ Not implemented | Weapon entities + durability | P2 |
---

## 12. Design Authority Notes
These are binding design decisions that the team should not override without consulting the Game Designer:
1. **Comedy is non-negotiable.** If a mechanic isn't fun or funny, redesign it. Never ship something that feels generic.
---