# firstPunch — Comprehensive Gap Analysis & Prioritized Backlog

**Author:** Keaton (Lead / Architect)  
**Date:** 2026-06-03  
**Scope:** Full gap analysis between current MVP and original requirements  

---

## 1. Current State Assessment

### Overview

firstPunch is a functional, playable browser-based beat 'em up built in ~30 minutes with pure JavaScript, HTML5 Canvas, and Web Audio API. The game has a working game loop, one playable character (Brawler), one enemy type (with a "tough" variant), three enemy waves, and basic combat mechanics.

### File Inventory & Quality

| File | LOC | Purpose | Quality |
|------|-----|---------|---------|
| `index.html` | 13 | Entry point, canvas element | ✅ Clean |
| `styles.css` | 26 | Letterbox layout, 16:9 aspect | ✅ Clean |
| `src/main.js` | 24 | Bootstrap, scene registration | ✅ Clean |
| `src/engine/game.js` | 65 | Game loop, fixed timestep, scene management | ✅ Solid |
| `src/engine/renderer.js` | 89 | Canvas wrapper, camera, screen shake | ✅ Good |
| `src/engine/input.js` | 69 | Keyboard state management | ✅ Good (post-bugfix) |
| `src/engine/audio.js` | 50 | Web Audio API SFX | ⚠️ Minimal — only 3 sounds |
| `src/entities/player.js` | 256 | Brawler: movement, attack, render | ⚠️ Mixed — logic+render coupled |
| `src/entities/enemy.js` | 167 | Generic enemy with variant | ⚠️ Mixed — single type |
| `src/systems/combat.js` | 75 | Collision detection, damage handling | ✅ Good |
| `src/systems/ai.js` | 61 | Enemy AI state machine | ⚠️ Basic — single behavior |
| `src/scenes/title.js` | 71 | Title screen | ⚠️ Bare minimum |
| `src/scenes/gameplay.js` | 260 | Level logic, waves, camera, background | ⚠️ God scene — too many responsibilities |
| `src/ui/hud.js` | 48 | Health bar + score | ✅ Clean |

**Total:** ~1,274 lines across 14 files.

### What Works Well
- Fixed timestep game loop with spiral-of-death protection
- Scene management (title ↔ gameplay)
- Keyboard input with frame-accurate pressed/released tracking
- AABB collision detection with separate hitbox/hurtbox
- Camera following + camera locks for wave encounters
- Y-sorting for 2.5D depth illusion
- Invulnerability frames (500ms) with visual blink
- Screen shake on hit
- Knockback physics with friction decay
- Enemy AI: approach, circle, retreat, attack behaviors
- HUD with health bar and score

---

## 2. Gap Analysis by Requirement Area

### 2.1 Rendering (HTML5 Canvas at 60 FPS)

| Requirement | Status | Gap |
|-------------|--------|-----|
| HTML5 Canvas | ✅ Done | — |
| 60 FPS fixed timestep | ✅ Done | Well-implemented with accumulator pattern |
| Fixed 16:9 playfield (1280×720) | ✅ Done | Canvas is 1280×720 |
| Responsive scale-to-fit | ✅ Done | CSS `aspect-ratio: 16/9` + max-width/height |
| Letterboxing | ✅ Done | Black body background with centered canvas |

**Completion: 100%** — Rendering infrastructure fully meets requirements.

### 2.2 Architecture

| Requirement | Status | Gap |
|-------------|--------|-----|
| `/src/engine` (game loop, timing, renderer) | ✅ Done | `game.js`, `renderer.js`, `input.js`, `audio.js` |
| `/src/scenes` (title, gameplay) | ✅ Done | `title.js`, `gameplay.js` |
| `/src/entities` (player, enemy) | ✅ Done | `player.js`, `enemy.js` |
| `/src/systems` (combat, collision, AI, input) | ⚠️ Partial | Has `combat.js` and `ai.js` — but collision is inside combat, and input is in engine |
| `/assets` (placeholders) | ❌ Missing | No `/assets` directory at all; all graphics are procedural Canvas draws |

**Completion: 85%** — Good structure but some system/module separation could be cleaner.

**Gaps:**
- No dedicated collision system (lives inside `Combat`)
- Input system lives in `/engine` (acceptable but inconsistent with requirement)
- No `/assets` directory — not critical since everything is procedural, but the spec expected it
- `gameplay.js` is a "god scene" handling background rendering, wave spawning, camera logic, and level design — should be decomposed

### 2.3 Core Beat 'Em Up Mechanics

| Requirement | Status | Gap |
|-------------|--------|-----|
| Side-scrolling | ✅ Done | Camera follows player horizontally |
| Limited vertical movement (2.5D) | ✅ Done | Y constrained to 400–600 range |
| Player move (4-direction) | ✅ Done | WASD + Arrow keys, separate horizontal/depth speed |
| Player punch | ✅ Done | J/Z — 10 damage, 0.3s cooldown, 40px hitbox |
| Player kick | ✅ Done | K/X — 15 damage, 0.5s cooldown, 60px hitbox |
| Player jump | ✅ Done | Space — parabolic arc with gravity |
| Enemies approach | ✅ Done | AI approaches when distance > 100 |
| Enemies attack | ✅ Done | AI attacks when within 80px, 1.5s cooldown |
| Enemies take damage | ✅ Done | Hitbox/hurtbox collision, damage numbers |
| Enemies die | ✅ Done | Death state with fade-out and cleanup |
| Hit-stun | ✅ Done | 200ms hitstun for both player and enemies |
| Knockback | ✅ Done | Directional knockback with friction decay |

**Completion: 95%** — Core mechanics are solid. Minor gaps:
- **Jump attacks** not implemented — jumping doesn't affect combat at all
- **No combo system** — attacks are standalone, no chains
- **Kick has no distinct animation** — the render method only shows a punch extension, no kick visual

### 2.4 Characters

| Requirement | Status | Gap |
|-------------|--------|-----|
| One playable character (Brawler) | ✅ Done | Brawler with yellow head, white shirt, blue pants |
| One basic enemy type | ✅ Done | Purple variant (30 HP) |
| Enemy variant | ✅ Done | "Tough" variant (dark red, 50 HP) — same behavior |
| Optional boss | ❌ Not done | No boss entity exists |

**Completion: 75%** — Core character requirement met. Boss is explicitly "optional."

### 2.5 Level Design

| Requirement | Status | Gap |
|-------------|--------|-----|
| One short horizontal level | ✅ Done | 4000px wide |
| Enemy waves via camera locks | ✅ Done | 3 waves with invisible triggers |
| Background parallax | ✅ Done | Buildings at 0.3x scroll speed |

**Completion: 95%** — Level design meets MVP requirements. Background is functional but visually plain.

### 2.6 Controls

| Requirement | Status | Gap |
|-------------|--------|-----|
| WASD / Arrow keys movement | ✅ Done | Both mappings work |
| J/K (or Z/X) attacks | ✅ Done | J/Z = punch, K/X = kick |
| Space jump | ✅ Done | — |

**Completion: 100%**

### 2.7 UI / HUD

| Requirement | Status | Gap |
|-------------|--------|-----|
| Health bar | ✅ Done | Top-left, numeric + bar, color changes at low health |
| Score display | ✅ Done | Top-right, score from hits and kills |

**Completion: 100%** — HUD meets spec. Could be much more polished.

### 2.8 Audio

| Requirement | Status | Gap |
|-------------|--------|-----|
| Punch SFX | ✅ Done | Square wave, 150Hz, 0.05s |
| Hit SFX | ✅ Done | Sawtooth wave, 100Hz, 0.08s |
| KO SFX | ✅ Done | Sine sweep 300→50Hz |
| Web Audio API | ✅ Done | Synthesized procedural sounds |

**Completion: 80%** — Functional but extremely minimal. Only 3 sound effects total. No kick sound, no jump sound, no background music placeholder.

### 2.9 Persistence

| Requirement | Status | Gap |
|-------------|--------|-----|
| High score in localStorage | ❌ Not done | No localStorage usage anywhere |

**Completion: 0%** — This is an explicit P0 requirement that was not implemented.

### 2.10 Documentation

| Requirement | Status | Gap |
|-------------|--------|-----|
| README with how to run | ✅ Done | Quick Start section |
| README with controls | ✅ Done | Controls table |
| Note on what was scoped out | ✅ Done | "What Was Scoped Out" section |

**Completion: 100%**

### 2.11 Visual Style

| Requirement | Status | Gap |
|-------------|--------|-----|
| Clean, modern 2D look | ❌ Subpar | Characters are simple geometric shapes |
| HD sprites or vector-style | ❌ Subpar | Basic rectangles and circles |
| Strong hit effects (flash) | ⚠️ Partial | White overlay flash exists, but weak |
| Camera shake | ✅ Done | 3px intensity, 100ms duration |
| Modern visuals preferred | ❌ Subpar | Current look is programmer-art prototype |

**Completion: 30%** — This is the biggest gap. The user explicitly wanted "visually modern" and the current state is functional placeholder art.

---

## 3. Visual Quality Audit

### Current State
Characters are drawn with basic Canvas primitives:
- **Brawler:** Yellow circle head, white rectangle body, blue rectangle pants, small rectangle arms with sine-wave bob. Punch animation extends one arm rectangle.
- **Enemies:** Pink circle head, purple/red rectangle body, black rectangle legs. Nearly identical animation to player.
- **Background:** Flat color fills — sky blue, green grass, gray road with yellow dashes. Brown rectangles for buildings with blue rectangle windows.

### Assessment

The visual quality is at **early prototype** level. While functional, it looks nothing like a "modern 2D game." The characters lack:

1. **Distinct silhouettes** — Brawler and enemies are very similar stick-figure proportions
2. **Proper body proportions** — Brawler should be round/stocky, enemies should have varied builds
3. **Animation states** — Walk cycle is just arm bobbing, no leg movement. No distinct punch vs kick pose. No jump animation. No hurt pose.
4. **Visual identity** — Brawler is barely recognizable as Brawler. No distinctive features (mouth, M-shaped hair, beer gut)
5. **Background detail** — No Downtown landmarks, no depth layers beyond single parallax
6. **Effects/juice** — Minimal impact effects. No dust clouds, no sparks, no impact flashes beyond a white overlay
7. **Color palette** — Uses web-standard named colors rather than a cohesive art direction

### Work Required to Reach "Modern" Standard (Canvas API Only)

| Area | Effort | Description |
|------|--------|-------------|
| Brawler redesign | L | Proper round body, M-shaped hair detail, distinct face, multiple pose states (idle, walk, punch, kick, jump, hurt, dead) |
| Enemy redesign | M per type | Distinct body shapes, color schemes, visual identity for each variant |
| Walk animation system | M | Frame-based leg/arm movement cycling, smooth transitions |
| Attack animations | M | Distinct punch vs kick poses, wind-up and follow-through frames |
| Background overhaul | L | Multi-layer parallax, Downtown buildings (Quick Stop, Factory silhouettes), clouds, street details |
| Impact effects | M | Starburst/flash on hit, motion lines, impact sparks |
| Particle system | M | Dust on landing, debris on death, sparkle effects |
| UI polish | S | Styled health bar with icons, arcade-style score counter, combo display |

**Estimated total: 3–5 focused development sessions** to reach a "looks good" standard with Canvas-only rendering.

---

## 4. Combat Feel Audit

### Input Responsiveness
**Rating: 7/10** — Input is processed every fixed timestep (60 FPS). Attacks register on the same frame as key press. No input buffering means fast tapping can miss inputs if they land between frames, but this is acceptable for the genre.

### Hit Feedback
**Rating: 5/10** — Multiple systems combine:
- ✅ Screen shake (3px, 100ms) — present but subtle
- ✅ White flash overlay on hit entity — present but weak (could be more dramatic)
- ✅ Knockback physics — good directional knockback with friction
- ❌ No hitlag/freeze frames — the genre standard "pause on impact" is absent
- ❌ No visual hit effect (starburst, impact sprite) at point of contact
- ❌ Hit sound is generic — no variation, no pitch randomization

### Knockback Satisfaction
**Rating: 6/10** — Knockback direction and magnitude are correct. Friction decay (0.85 for enemies, 0.9 for player) feels natural. However:
- Knockback doesn't distinguish punch vs kick visually enough (just distance)
- No "launch" on final hit (enemy should fly farther on kill hit)
- No ground-bounce or ragdoll on KO

### Combo Potential
**Rating: 2/10** — Nearly non-existent:
- Punch has 0.3s cooldown, kick has 0.5s cooldown — both standalone
- No combo chain detection (punch-punch-kick, etc.)
- No combo counter display
- No damage scaling for combos
- No special moves or finishers
- Jump attacks don't exist — jumping is purely evasive

### Enemy AI Engagement Quality
**Rating: 5/10** — Functional but predictable:
- Enemies approach directly with some circling behavior
- 1.5s attack cooldown + 0.5s AI pause after attack feels deliberate
- Multiple enemies can attack simultaneously (no "one-at-a-time" rule)
- No stagger — when grouped, they feel like a blob
- No AI variety — all enemies behave identically regardless of variant
- "Tough" variant is only different in HP (50 vs 30), same speed/damage/behavior

### What Makes Beat 'Em Ups FEEL Good (and What's Missing)

| Feel Element | Present? | Notes |
|--------------|----------|-------|
| Hitlag (frame freeze on impact) | ❌ | #1 missing feel element — crucial for weight |
| Hit spark / impact VFX | ❌ | No visual at point of contact |
| Sound variation | ❌ | Same sound every hit — quickly boring |
| Combo chains | ❌ | No linked attacks |
| Jump attacks | ❌ | Jumping is evasive only |
| Enemy stagger/stumble | ⚠️ | Hitstun exists but no visual stagger animation |
| Crowd control (enemy attack throttling) | ❌ | All enemies attack freely |
| Death animation / ragdoll | ❌ | Enemies just fade out |
| Damage numbers | ❌ | No floating damage indicators |
| KO text pop-up | ❌ | No "KO!" "POW!" text effects |

**Overall Combat Feel Score: 5/10** — Functional but lacking the "juice" that makes beat 'em ups addictive.

---

## 5. Architecture Audit

### Strengths
1. **Clean ES module system** — Every file is a self-contained ES module with clear imports/exports
2. **Scene management** — `Game` class handles scene lifecycle with `onEnter`/`onExit` hooks
3. **Fixed timestep** — Proper accumulator pattern prevents physics inconsistencies
4. **Separation of concerns** — Engine, entities, systems, scenes, UI are in separate directories
5. **No external dependencies** — Zero npm packages, runs from a single HTML file

### Issues

#### 5.1 God Scene Problem
`gameplay.js` (260 LOC) handles too many concerns:
- Level data (wave definitions)
- Wave spawning logic
- Camera management
- Background rendering
- Game state (over/complete)
- Entity lifecycle

**Recommendation:** Extract `Level`, `WaveManager`, `Camera`, and `Background` into separate modules.

#### 5.2 Entity Render Coupling
Both `player.js` and `enemy.js` contain their own `render()` methods with hardcoded Canvas draw calls. This makes it impossible to:
- Swap visual styles without rewriting entities
- Add animation frames without touching game logic
- Share rendering patterns between entity types

**Recommendation:** Extract rendering into a sprite/animation system that entities reference.

#### 5.3 No Animation System
Animation is ad-hoc — `animTime` increments but is only used for arm-bobbing sine waves. There's no concept of:
- Named animation states (idle, walk, punch, kick, jump, hurt)
- Frame sequences within animations
- Transition rules between animations
- Animation events (trigger sound on frame X)

**Recommendation:** Create an `AnimationController` that maps states to frame sequences.

#### 5.4 Missing Collision System
Collision detection lives statically inside `Combat.checkCollision()`. There's no general-purpose collision system for:
- Environmental collision (walls, boundaries)
- Pickup collision
- Trigger zone detection

**Recommendation:** Extract into `/src/systems/collision.js`.

#### 5.5 No Event System
Systems communicate through direct method calls and return values. There's no event bus for:
- "Enemy died" → update score, play KO sound, spawn pickup
- "Player hit" → screen shake, flash, slow-mo
- "Wave cleared" → unlock camera, play fanfare

**Recommendation:** Add a lightweight pub/sub event system for decoupling.

#### 5.6 Hardcoded Values
Many values are hardcoded in-place:
- Player speed (200), depth speed (120), jump power (400)
- Attack damage (10/15), cooldowns (0.3/0.5)
- Enemy HP (30/50), AI ranges (80/100)
- Y-axis bounds (400–600)
- Level width (4000)

**Recommendation:** Move to a configuration object or data files for easy tuning.

### Architecture Score: 7/10
Good foundation for a 30-minute sprint. Needs targeted refactors before adding features, especially the god scene decomposition and animation system.

---

## 6. Polish Backlog (Everything Beyond MVP)

### 6.1 Missing P0 Requirements
| Item | Description |
|------|-------------|
| High score persistence | Save/load high score from localStorage |

### 6.2 Combat & Gameplay Polish
| Item | Description |
|------|-------------|
| Combo system | Punch-punch-kick chains, timing windows, damage scaling |
| Jump attacks | Air punch, air kick, ground slam (jump + down + attack) |
| Hitlag/freeze frames | 2-3 frame pause on impact for weight |
| Enemy attack throttling | Only 1-2 enemies attack at once, others circle |
| Weapon pickups | Pipe, bat, beer bottle — timed powerups on the ground |
| Food/health pickups | Donut, Buzz Cola — restore HP |
| Special moves | Brawler belly bump, power slide |
| Grab/throw | Grab stunned enemies, throw into others |

### 6.3 Enemy Variety
| Item | Description |
|------|-------------|
| Fast enemy type | Low HP, high speed, hit-and-run behavior |
| Heavy enemy type | High HP, slow, uninterruptible super armor |
| Ranged enemy type | Throws objects from distance, retreats when approached |
| Shield enemy type | Blocks from front, must be attacked from behind or jumped over |
| Boss enemy | Large sprite, multi-phase fight, unique attack patterns, health bar |

### 6.4 Visual Improvements
| Item | Description |
|------|-------------|
| Brawler redesign | Proper proportions, recognizable features, multiple animation frames per state |
| Enemy redesign | Distinct look per type, varied body shapes and colors |
| Animation system | Frame-based animation controller, smooth state transitions |
| Background overhaul | Downtown landmarks, multi-layer parallax, environmental detail |
| Impact VFX | Starburst, motion lines, sparks at hit point |
| Particle system | Dust clouds, debris, sparkles, smoke |
| Damage numbers | Floating numbers on hit with scaling and fade |
| KO text effects | "POW!" "WHAM!" comic-style pop-ups |
| Combo counter | On-screen combo display with multiplier |
| Screen flash | White flash overlay on big hits |
| Death animations | Enemies fly back, bounce, fade with stars |
| Brawler idle animation | Breathing, belly jiggle, beer scratch |

### 6.5 Audio Improvements
| Item | Description |
|------|-------------|
| Kick SFX | Distinct from punch — lower, thudier |
| Jump SFX | Whoosh sound on jump |
| Land SFX | Thud on landing |
| Enemy hurt SFX variations | 3-4 randomized hit sounds for variety |
| Background music | Simple looping chiptune or synth track (procedural) |
| Wave start fanfare | Audio cue when camera locks |
| Wave clear fanfare | Audio cue when wave defeated |
| Level complete jingle | Victory music |
| Game over sting | Dramatic failure sound |
| UI sounds | Menu select, menu confirm |
| Environmental ambience | Birds, traffic, Downtown hum |

### 6.6 UI/UX Polish
| Item | Description |
|------|-------------|
| Animated title screen | Character preview, animated logo, particle background |
| Game over screen | Continue countdown, high score display |
| Pause menu | ESC to pause, resume/quit options |
| Enemy health bars | Small health bar above each enemy |
| High score display | Show on title screen and game over screen |
| Score pop-ups | Floating score values when enemies are hit/killed |
| Lives system | 3 lives with continue |
| Player death animation | Dramatic fall, fade, respawn with i-frames |
| Level intro | "Downtown Downtown" text card before gameplay |
| Screen transitions | Fade in/out between scenes |

### 6.7 Level & Progression
| Item | Description |
|------|-------------|
| Level variety | Different backgrounds (Downtown, Factory, Joe's Bar) |
| Environmental hazards | Toxic barrels, falling objects |
| Destructible objects | Trash cans, barrels that drop items |
| More enemy waves | Increase enemy count and variety through level |
| Difficulty scaling | Enemies get more aggressive in later waves |
| Multiple levels | 3-4 levels with different themes |
| Level select screen | After completing level 1 |

### 6.8 Extra Characters
| Item | Description |
|------|-------------|
| Kid (playable) | Skateboard attack, slingshot ranged, fast/weak |
| Defender (playable) | Purse swing, longer reach, balanced stats |
| Prodigy (playable) | Saxophone projectile, crowd control focus |
| Character select screen | Choose character before gameplay |

---

## 7. Prioritized Backlog

### P0 — Must Have (Original Requirements Not Yet Implemented)

| # | Item | Complexity | Owner | Dependencies | Description |
|---|------|-----------|-------|--------------|-------------|
| P0-1 | High score persistence | S | UI Dev | None | Save high score to localStorage on game over / level complete. Load and display on title screen. |
| P0-2 | `/assets` directory | S | Any | None | Create placeholder `/assets` directory with a README explaining procedural art approach |
| P0-3 | Kick visual animation | S | Gameplay Dev | None | Add distinct kick pose in player.js render method (leg extension vs arm extension) |
| P0-4 | Kick sound effect | S | Engine Dev | None | Add `playKick()` to audio.js with distinct sound. Wire into gameplay.js attack handling. |
| P0-5 | Jump sound effect | S | Engine Dev | None | Add `playJump()` to audio.js. Trigger on jump initiation. |

### P1 — Should Have (Significantly Improves Quality)

| # | Item | Complexity | Owner | Dependencies | Description |
|---|------|-----------|-------|--------------|-------------|
| P1-1 | Hitlag (freeze frames) | S | Engine Dev | None | Add 2-3 frame pause when attacks connect. Apply to both attacker and defender. Single biggest combat feel improvement. |
| P1-2 | Hit impact VFX | M | Gameplay Dev | None | Draw starburst/flash sprite at point of collision. Animate over 4-6 frames. |
| P1-3 | Sound variation | S | Engine Dev | None | Randomize pitch ±20% on hit/punch sounds. Add 2-3 sound variants for hits. |
| P1-4 | Enemy attack throttling | S | Gameplay Dev | None | AI coordinator: max 2 enemies attack simultaneously, others wait and circle. Huge gameplay improvement. |
| P1-5 | Combo system (basic) | M | Gameplay Dev | None | Detect punch-punch-kick chain within timing window. Track combo count. Apply damage multiplier. |
| P1-6 | Combo counter display | S | UI Dev | P1-5 | Show combo count on screen with scaling text. Fade after combo drops. |
| P1-7 | Jump attacks | M | Gameplay Dev | None | Enable attacks while airborne. Air punch (quick, weak), air kick (dive kick). |
| P1-8 | Animation system core | L | Engine Dev | None | Create `AnimationController` class: named states → frame arrays, transitions, events. Decouple render from logic. |
| P1-9 | Brawler walk cycle | M | Gameplay Dev | P1-8 | Multi-frame walk animation using animation system. Leg movement, arm swing. |
| P1-10 | Brawler attack animations | M | Gameplay Dev | P1-8 | Distinct multi-frame punch and kick animations with wind-up and follow-through. |
| P1-11 | Enemy death animation | M | Gameplay Dev | P1-8 | Enemy flies backward on kill hit, bounces once, fades with stars/birds circling. |
| P1-12 | Background music (procedural) | M | Engine Dev | None | Simple looping bass/melody using Web Audio API oscillators. Mute/unmute toggle. |
| P1-13 | Game over screen | M | UI Dev | P0-1 | Continue option (with lives or timer), high score display, restart option. |
| P1-14 | Gameplay scene refactor | M | Lead | None | Extract `WaveManager`, `Camera`, `Background`, `LevelData` from gameplay.js. Required before adding level variety. |
| P1-15 | Event system | M | Engine Dev | None | Lightweight pub/sub bus for decoupled communication between systems. |
| P1-16 | Configuration data | S | Lead | None | Extract all hardcoded gameplay values into a config module for easy balancing. |
| P1-17 | Damage numbers | S | UI Dev | None | Floating damage text at hit point. Scale up, drift upward, fade out. |
| P1-18 | Enemy health bars | S | UI Dev | None | Small health bar above each enemy, only visible when damaged. |
| P1-19 | Screen transitions | S | Engine Dev | None | Fade-to-black between title and gameplay scenes. |
| P1-20 | Pause menu | M | UI Dev | None | ESC to pause. Show "PAUSED" overlay with Resume/Quit options. |

### P2 — Nice to Have (Polish & Extras)

| # | Item | Complexity | Owner | Dependencies | Description |
|---|------|-----------|-------|--------------|-------------|
| P2-1 | Boss enemy | L | Gameplay Dev | P1-8 | Large character, unique attack patterns (charge, ground pound, throw), multi-phase with visual tells. End of level 1. |
| P2-2 | Fast enemy type | M | Gameplay Dev | P1-8 | Low HP, high speed, dash attack, hit-and-run AI behavior. |
| P2-3 | Heavy enemy type | M | Gameplay Dev | P1-8 | High HP, slow, super armor (doesn't flinch on first hit), powerful attacks. |
| P2-4 | Brawler redesign (modern Canvas art) | L | Gameplay Dev | P1-8 | Recognizable Brawler: round belly, M-hair, overbite, proper proportions. 8+ animation frames. |
| P2-5 | Background overhaul | L | Gameplay Dev | P1-14 | Downtown landmarks: Quick Stop, cooling towers, Joe's Bar. Multi-layer parallax (3+ layers). Clouds, street details. |
| P2-6 | Particle system | M | Engine Dev | None | Generic particle emitter. Dust on landing, sparks on hit, debris on death. |
| P2-7 | Weapon pickups | M | Gameplay Dev | P1-14, P1-15 | Pipe, bat on ground. Timed powerup, increased damage/range. Drop on hit. |
| P2-8 | Food/health pickups | S | Gameplay Dev | P1-14, P1-15 | Donut, Buzz Cola spawn from defeated enemies or barrels. Restore 20-30 HP. |
| P2-9 | KO text effects | S | UI Dev | None | "POW!" "WHAM!" comic-style text pop at hit location. Random selection, scale+fade animation. |
| P2-10 | Animated title screen | M | UI Dev | P1-8 | Brawler idle animation, animated logo, particle effects, scrolling background. |
| P2-11 | Wave fanfares | S | Engine Dev | None | Audio cue for camera lock (danger) and wave clear (victory). |
| P2-12 | Lives system | S | Gameplay Dev | P1-13 | 3 lives. Respawn with brief invulnerability. Display lives on HUD. |
| P2-13 | Score pop-ups | S | UI Dev | None | "+10" "+50" floating text when scoring points. |
| P2-14 | Special moves | M | Gameplay Dev | P1-5 | Brawler belly bump (forward+attack during combo), power slide (down+jump). |
| P2-15 | Grab/throw | L | Gameplay Dev | P1-8 | Grab stunned enemy, throw directionally. Thrown enemy damages others. |
| P2-16 | Difficulty scaling | S | Gameplay Dev | None | Later waves: faster AI cooldowns, more aggressive approach, enemies have more HP. |
| P2-17 | Level intro text | S | UI Dev | None | "STAGE 1: DOWNTOWN" text card with fade before gameplay. |

### P3 — Stretch (Beyond Original Scope)

| # | Item | Complexity | Owner | Dependencies | Description |
|---|------|-----------|-------|--------------|-------------|
| P3-1 | Kid (playable character) | XL | Gameplay Dev | P1-8, P2-4 | Full character: skateboard dash, slingshot attack, unique animations. |
| P3-2 | Defender (playable character) | XL | Gameplay Dev | P1-8, P2-4 | Full character: purse swing (long range), vacuum cleaner special. |
| P3-3 | Prodigy (playable character) | XL | Gameplay Dev | P1-8, P2-4 | Full character: saxophone wave projectile, crowd control focus. |
| P3-4 | Character select screen | M | UI Dev | P3-1 or P3-2 or P3-3 | Character preview with stats, select with input, transitions to gameplay. |
| P3-5 | Ranged enemy type | M | Gameplay Dev | P1-8 | Throws objects from distance, retreats when player closes in. Projectile entity. |
| P3-6 | Shield enemy type | M | Gameplay Dev | P1-8 | Blocks frontal attacks, must be flanked or jump-attacked. Block animation. |
| P3-7 | Multiple levels | XL | Gameplay Dev | P1-14, P2-5 | 3-4 levels: Downtown, Factory, Joe's Bar, Burger Joint. Each with unique waves and background. |
| P3-8 | Level select screen | M | UI Dev | P3-7 | Post-level-1 selection screen. |
| P3-9 | Environmental hazards | M | Gameplay Dev | P1-14 | Toxic barrels (damage zone), falling donuts, conveyor belts. |
| P3-10 | Destructible objects | M | Gameplay Dev | P1-14, P1-15, P2-6 | Trash cans, barrels, boxes that break when hit and drop items. |
| P3-11 | Full SFX library | L | Engine Dev | None | 15+ distinct sound effects: footsteps, environmental, voice grunts. |
| P3-12 | Procedural music system | L | Engine Dev | P1-12 | Dynamic music that intensifies during combat, calms between waves. |
| P3-13 | Leaderboard (online) | XL | Engine Dev | P0-1 | Simple backend for global high scores. Way beyond scope. |
| P3-14 | 2-player co-op (local) | XL | Engine Dev | None | Second player with WASD while P1 uses arrows. Shared screen. Major refactor. |

---

## 8. Team Assessment

### Current Team

| Role | Member | Strengths | Bottleneck Risk |
|------|--------|-----------|-----------------|
| Lead / Architect | Keaton | Architecture, integration, code review | Becomes bottleneck if doing implementation |
| Engine Dev | McManus | Game loop, renderer, audio, systems | Audio + animation system + particle system is a lot |
| Gameplay Dev | (TBD/assumed) | Entities, AI, combat, level design | Most backlog items land here — overloaded |
| UI Dev | (TBD/assumed) | HUD, menus, screen effects | Moderate load, but grows with polish phase |

### Assessment

The current 4-person team **can deliver P0 and P1** but will be strained on P2. Key concerns:

1. **Gameplay Dev is overloaded** — Combat improvements, enemy variety, animation frames, character art, level design, and pickups all route to one person. This is the critical path.

2. **No dedicated artist/VFX role** — The user's explicit emphasis on "visually modern" means significant art work. Current team members are engineers doing art, which will be slow and likely lower quality.

3. **Audio is underserved** — Engine Dev handles audio alongside engine work. Background music and SFX variety need dedicated attention.

### Recommended Additional Roles

| Role | Priority | Justification |
|------|----------|---------------|
| **VFX / Art Specialist** | High | Dedicated to Canvas-drawn character art, backgrounds, particle effects, animations. Unblocks the visual quality gap (biggest shortcoming). |
| **Sound Designer** | Medium | Dedicated to Web Audio API sound design: procedural music, SFX library, audio feel. Small but high-impact. |
| **QA / Playtester** | Medium | Manual testing, feel feedback, balance tuning. Engineers are bad at testing their own combat feel. |
| **Second Gameplay Dev** | Low (P2+) | Split the gameplay workload: one handles combat/enemy systems, other handles level design/pickups. |

### Recommended Execution Order

**Phase 1 (P0 — 1 session):** High score persistence, missing SFX, kick animation. Ship these fast.

**Phase 2 (P1 Core Feel — 2-3 sessions):** Hitlag, impact VFX, sound variation, combo system, enemy throttling, jump attacks. This is the "make it FEEL good" phase.

**Phase 3 (P1 Infrastructure — 2-3 sessions):** Animation system, scene refactor, event system, config extraction. This enables everything in P2.

**Phase 4 (P1 Polish — 2 sessions):** Background music, game over screen, damage numbers, enemy health bars, pause menu, screen transitions.

**Phase 5 (P2 Content — 3-5 sessions):** Boss, enemy variety, Brawler redesign, background overhaul, particles, pickups, special moves.

**Phase 6 (P3 Expansion — ongoing):** Additional characters, levels, advanced features.

---

## Summary

### Completion vs Requirements

| Area | Completion | Verdict |
|------|-----------|---------|
| Rendering infrastructure | 100% | ✅ Fully meets requirements |
| Architecture | 85% | ⚠️ Good but needs refactoring for growth |
| Core mechanics | 95% | ✅ Solid — minor gaps (jump attacks, combos) |
| Characters | 75% | ⚠️ One character done, no boss |
| Level design | 95% | ✅ Functional level with wave system |
| Controls | 100% | ✅ All controls working |
| UI/HUD | 100% | ✅ Basic HUD complete |
| Audio | 80% | ⚠️ Functional but too minimal |
| Persistence | 0% | ❌ Not implemented (explicit requirement) |
| Documentation | 100% | ✅ Complete |
| Visual quality | 30% | ❌ Biggest gap — far from "modern" |
| Combat feel | 50% | ⚠️ Functional but lacks juice |

### Overall MVP Completion: ~75%

The game is playable and demonstrates all core beat 'em up patterns. The two critical gaps are:
1. **localStorage high score** — a P0 requirement that was missed entirely
2. **Visual quality** — the user explicitly and repeatedly requested "modern visuals" and the current state is prototype-level programmer art

### Top 5 Highest-Impact Items
1. **P0-1: High score persistence** — Missing requirement, trivial to implement
2. **P1-1: Hitlag** — Single biggest combat feel improvement, small effort
3. **P1-4: Enemy attack throttling** — Makes combat tactical instead of chaotic
4. **P1-5: Combo system** — Transforms button-mashing into skilled play
5. **P1-8: Animation system** — Unlocks all visual improvements downstream
