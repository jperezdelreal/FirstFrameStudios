# firstPunch — AAA-Level Gap Analysis & Prioritized Backlog

**Author:** Solo (Lead)  
**Date:** 2026-06-04  
**Context:** 12-person team (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien). Goal: "elevar este juego a categoría AAA y ganar un premio."  
**Source material:** beat-em-up-research.md, bug-and-visual-audit.md, visual-modernization-plan.md, backlog-expansion.md, all src/ code files.

---

## 1. Current State vs AAA Standard

Rating scale: 1 (broken) → 5 (functional prototype) → 7 (solid indie) → 10 (award-winning browser beat 'em up).

| Area | Score | Assessment |
|------|-------|------------|
| **Combat Feel** | 5/10 | Hitlag + screen shake + knockback exist (great foundation). Missing: grab/throw system, dodge roll, juggle physics, attack buffering, directional specials. Combo system is basic (counter + timer). No risk/reward loops (health-cost specials, taunt meter). Beat 'em up research says grab/throw is in ALL 9 reference games — we have zero. |
| **Enemy Variety** | 4/10 | 4 variants (normal, fast, heavy, boss) with behavior tree AI. Good AI architecture. Missing: ranged, shield, aerial, grappler, summoner types. Research says 6-9 enemy types minimum. Boss has 3 phases (good) but only 1 boss total. No mini-bosses. Enemy intro sequences absent. |
| **Visual Quality** | 5.5/10 | Procedural Canvas art with consistent outlines. Boba's VFX system adds hit effects, KO text, damage numbers, motion trails, spawn effects. Missing: walk cycle animations, squash/stretch, facial expressions, unique enemy silhouettes, attack anticipation frames. Backgrounds have parallax but lack Downtown landmark density. |
| **Audio Quality** | 6/10 | Layered hit sounds (bass+mid+sparkle), mix bus architecture, pitch variation, priority system, spatial panning, procedural music with 3 intensity layers. Missing: vocal barks (Ugh!, Radical!), environmental ambience, dynamic crowd reactions, retro-themed SFX library. Bugs: some audio hooks not connected (wave fanfares, landing, vocals partially wired). |
| **Level Design** | 3/10 | Single level with 4 waves. Wave data is hardcoded arrays. No environmental interaction (destructibles, throwable objects, hazards). No set pieces. No level intro/outro cinematics beyond a basic timer. Research says beat 'em ups need 6-8 encounters per level with walk → encounter → walk pacing. We have 4 flat waves. |
| **UI/UX** | 6/10 | Health bar, score, combo counter, boss health bar, lives icons, enemy health bars all present and polished. Title screen is atmospheric. Missing: options menu, pause menu buttons, wave progress indicator, special cooldown display, score breakdown on game over, scene transitions, character select screen. |
| **Replayability** | 2/10 | localStorage high score only. No character select (Brawler only). No difficulty settings. No per-level rankings. No unlockables. No challenges. Research says progression systems "dramatically extend engagement." We have near-zero replay incentive. |
| **Technical Polish** | 6/10 | Fixed timestep, modular ES6 architecture, camera system, wave manager, config.js. Debug overlay exists. Missing: event bus integration (exists but unused), animation controller (exists but unused), particle system partially integrated. Some dead code. Performance untested under heavy load. No accessibility features. |

**Overall AAA Readiness: 4.7/10**

### Critical Gaps Summary (ordered by impact on "award-worthy")

1. **Grab/throw system** — Present in ALL 9 reference games. Most fundamental missing mechanic.
2. **Dodge roll with i-frames** — Expected in every modern beat 'em up (SoR4, Shredder's Revenge).
3. **Multiple playable characters** — Character differentiation is "non-negotiable" per research.
4. **Level content depth** — 1 level, 4 waves. Award-winning games have 6-8 levels.
5. **Environmental interaction** — Destructibles, throwables, hazards. Downtown is "RICH with interactive potential."
6. **Animation quality** — Scored 4/10 in audit. No anticipation, follow-through, or squash/stretch.
7. **Replayability systems** — Character select, scoring ranks, challenges, unlockables.

---

## 2. New AAA-Tier Backlog Items

Items NOT in the existing 85-item backlog. Organized by domain.

### 2.1 Combat AAA (Lando + Yoda)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-C1 | Grab/throw system | Lando | XL | P1-8 (animation controller) | Proximity grab input when near enemy. Grab state: pummel (mash attack for damage) or throw (directional input + attack). Thrown enemies damage other enemies on collision. Foundation for the genre's most satisfying micro-interaction. Every reference game has this. |
| AAA-C2 | Dodge roll with i-frames | Lando | L | None | Dedicated dodge input (double-tap direction or dedicated key). 0.3s animation with 0.15s i-frames in the middle. Recovery frames prevent spam. Brawler's dodge: stumbling belly roll. Each future character gets unique dodge animation. |
| AAA-C3 | Juggle physics system | Lando | L | P1-8 | Launched enemies become physics objects. Hit airborne enemies to keep them up. Wall/floor bounce states. Simplified to 2-3 bounce states (not full simulation) for Canvas performance. Skill expression layer for advanced players. |
| AAA-C4 | Style/combo scoring meter | Yoda + Wedge | M | None | Visible meter that fills with variety: different attacks, no repeats, grabs, throws, juggles, air combos. Resets on damage. retro-themed ratings: "Boring" → "Meh" → "Radical!" → "Excellent!" → "Best. Combo. Ever." Drives replayability and score chasing. |
| AAA-C5 | Taunt mechanic | Lando + Yoda | M | None | Dedicated taunt button. Builds super meter faster but leaves player vulnerable for ~1s. Brawler: eats invisible donut. Animation must be cancellable on hit. Risk/reward that "game characters are MADE for." |
| AAA-C6 | Super move meter + activation | Lando + Bossk | L | AAA-C5 | Meter fills from combat, taunts, and combo performance. When full, special input triggers character-specific super: Brawler = Rage Mode (temporary berserk, belly attacks, invincibility). Cinematic camera zoom on activation. |
| AAA-C7 | Dash attack | Lando | M | AAA-C2 | Double-tap forward + attack for closing-distance offensive move. Brawler: running belly charge. Covers 150px gap quickly. Found in SoR2, SoR4, Scott Pilgrim. |
| AAA-C8 | Back attack | Lando | S | None | Attack input while enemies behind = backward elbow/kick. Prevents "surrounded and helpless" situations. Found in SoR2, SoR4, Final Fight. |
| AAA-C9 | Attack buffering system | Chewie | M | None | Queue next attack input during current attack's active frames. If player presses punch during kick recovery, punch executes immediately after kick ends. Makes combos feel responsive and intentional. Modern beat 'em up standard. |
| AAA-C10 | Directional combo finishers | Lando + Yoda | M | P1-5 (combo system) | Different combo enders based on final directional input. Forward+attack = launch (juggle starter). Down+attack = ground slam. Neutral = knockdown sweep. Adds depth without extra buttons. |

### 2.2 Character Roster (Nien + Lando + Yoda)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-CH1 | Character select screen | Wedge + Nien | L | At least 2 characters | Arcade-style character select with animated preview of each character, stat comparison (speed/power/range triangle), unique idle animation. game couch in the middle — selected character sits on it. |
| AAA-CH2 | the Kid playable | Nien (art) + Lando (gameplay) | XL | AAA-C2, P1-8 | Fast/technical archetype. Skateboard dash, slingshot ranged, alter-ego super. Unique combo strings. "signature" taunt. Different hitboxes, speed values, attack animations. Full character with unique feel within 10 seconds of play. |
| AAA-CH3 | the Defender playable | Nien (art) + Lando (gameplay) | XL | AAA-C2, P1-8 | Range/support archetype. Purse weapon (extended range), hair whip spin attack, Tot Assist super. Maternal Instinct shield near allies. Unique combo strings and animations. |
| AAA-CH4 | the Prodigy playable | Nien (art) + Lando (gameplay) | XL | AAA-C2, P1-8 | Technical/crowd-control archetype. Saxophone blast (cone AoE), jump rope whip (mid-range), extra dodge i-frames. Activist Rally super (stun all enemies). Smart, defensive playstyle. |
| AAA-CH5 | Character unlock system | Yoda + Chewie | M | AAA-CH1, at least 1 extra character | Start with Brawler. Unlock Kid after clearing Level 1. Unlock Defender after clearing Level 2. Unlock Prodigy after clearing Level 3. localStorage persistence. Creates "one more run" motivation. |

### 2.3 Level Design & Content (Tarkin + Leia + Yoda)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-L1 | Destructible objects system | Tarkin + Leia | L | EX-T4 (data format) | Crates, barrels, newspaper stands, parking meters, phone booths. Each has HP, break animation, drop table (health, weapon, score). Interactable with attacks. Downtown-themed: smash a neighbor's mailbox, kick Donut Shop sign. |
| AAA-L2 | Throwable props | Tarkin + Lando | M | AAA-C1 (grab system), AAA-L1 | Pick up environmental objects (trash cans, fire hydrants, enemy weapons). Throw directionally. Damages enemies on contact. Integrates with grab input when near prop instead of enemy. |
| AAA-L3 | Environmental hazards | Tarkin + Leia | M | AAA-L1 | Toxic barrels (damage zones), manhole steam (knockback), falling signs. Affect enemies AND player. Throwing enemy into hazard = bonus damage + score. Downtown-authentic. |
| AAA-L4 | Level 2: City School | Tarkin + Leia | XL | EX-T4, AAA-L1 | New level with unique background (school hallways, gym, playground), new encounter pacing, new building types. Mini-boss: Bruiser variant. Final boss: Ringleader. 6-8 encounters with walk-fight-walk pacing. |
| AAA-L5 | Level 3: Factory | Tarkin + Leia | XL | AAA-L4 | Industrial setting with conveyor belts (moving platform mechanic), toxic zones, cooling tower finale. Boss: the Mayor in mech suit. Environmental storytelling through background details. |
| AAA-L6 | Couch gag level intros | Yoda + Bossk | M | Per level | Each level starts with a unique "couch gag" intro: brief animated scene before gameplay starts (2-3 seconds). Level 1: Brawler crashes through door. Level 2: Family runs from bees. game tradition meets beat 'em up convention. |
| AAA-L7 | Set piece encounters | Tarkin + Yoda | L | AAA-L4 | Mid-level unique moments that break the formula: sky rail fight (scrolling platform), school bus chase, factory meltdown countdown. One per level. Prevents monotony. |
| AAA-L8 | Level select / world map | Wedge + Leia | M | AAA-L4 | Downtown world map showing available levels, completion stars, best ranks. Unlock linearly. Shows Downtown from above. Players choose which level to replay. |

### 2.4 Visual AAA (Boba + Leia + Bossk + Nien)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-V1 | Screen zoom on power hits | Bossk + Chewie | M | None | Camera zooms to 1.15× for 0.2s on heavy attacks (belly bump, ground slam, combo finishers). Combined with existing hitlag creates cinematic impact. Canvas scale transform around hit point. |
| AAA-V2 | Slow-motion final kill | Chewie + Bossk | M | None | Last enemy in wave: game runs at 0.3× speed for 0.5s during killing blow. Camera zoom, extra particles, dramatic audio pitch-shift. Classic arcade dramatics. |
| AAA-V3 | Cinematic boss intros | Bossk + Nien | L | At least 1 boss | Camera pans to boss spawn, name card overlay ("BRUISER — Heh!"), unique entrance animation, brief dialogue. 3-4 seconds. Sets stakes, builds anticipation. Standard in every reference game. |
| AAA-V4 | Character idle animations | Nien | M | P1-8 | Brawler: occasional belly scratch, yawn, look at watch. Kid: skateboard trick, crack knuckles. Each character 3-4 unique idle variants on timer. Personality expressed through stillness. |
| AAA-V5 | Environmental storytelling | Leia + Boba | M | Background system | Background details that tell Downtown stories: Mayor's billboard, cartoon-within-a-cartoon poster, graffiti ("graffiti tag"), Founder Downtown statue. Not interactive — pure visual worldbuilding. |
| AAA-V6 | Scene transitions | Bossk + Wedge | M | None | Fade/wipe/slide transitions between title → gameplay, gameplay → game over, level → level. Currently instant-cut. 0.5s transition prevents jarring switches. |
| AAA-V7 | Weather/atmosphere system | Leia + Bossk | L | Background system | Per-level atmosphere: Level 1 = sunny day, Level 2 = overcast, Level 3 = night with industrial glow. Rain particles, fog overlay, time-of-day sky gradients. |
| AAA-V8 | Death animations | Nien + Bossk | M | P1-8 | Enemies: spin and fall, ragdoll bounce, dramatic fly-off-screen. Player: collapse animation, "Game Over" pose. Currently enemies just fade out (alpha). |

### 2.5 Audio AAA (Greedo)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-A1 | Character voice barks | Greedo | L | None | Procedural voice synthesis for key moments: Brawler "Ugh!" on hit (descending tone + vowel filter), "Woohoo!" on combo, "Mmm..." on health pickup. Kid "Radical!" on big hit. Even simple synthesized vocals add massive personality. 3-4 barks per character. |
| AAA-A2 | Environmental ambience | Greedo | M | None | Background audio layer per level: Downtown birds + distant traffic (Level 1), school bell + kids (Level 2), industrial hum + alarms (Level 3). Low-pass filtered, panned wide. Creates sense of place. Plays under music layer. |
| AAA-A3 | Dynamic crowd reactions | Greedo | M | AAA-C4 (style meter) | Crowd cheering audio responds to combo performance: scattered claps at 3-hit, cheering at 5-hit, roaring at 8+. "Boo" on player death. Downtown citizens watching the fight. Builds the "audience" feeling of arcade games. |
| AAA-A4 | Hit sound scaling by combo | Greedo | S | P1-5 | Hit sound intensity increases with combo count: hit #1 is light, hit #5 has full layered crack, hit #8+ adds reverb tail. Audio escalation mirrors visual combo escalation. |
| AAA-A5 | Boss music themes | Greedo | L | AAA-V3, Music system | Unique procedural music pattern per boss fight. Tempo increase on phase transitions. Victory fanfare on boss defeat. Music is "50% of game feel" per research. Boss music must feel DIFFERENT from regular combat. |
| AAA-A6 | retro-themed pickup sounds | Greedo | S | P2-8 | Distinct sounds for Downtown food pickups: donut (satisfying crunch + "Mmm"), Buzz Cola (fizz + gulp), Burger Joint (sizzle). Each pickup sounds appetizing. Reinforces IP authenticity. |

### 2.6 UI/UX AAA (Wedge + Yoda)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-U1 | Options/settings menu | Wedge | M | None | Accessible from title + pause. Volume sliders (Master, SFX, Music), difficulty select (Chill Mode / Normal / Nightmare Mode), control display, credits. Rounded panels matching existing HUD style. |
| AAA-U2 | Pause menu redesign | Wedge | M | None | Replace text-only pause with proper menu: Resume, Restart Level, Options, Quit to Title. Keyboard navigation with visual highlight. Semi-transparent backdrop blur effect. |
| AAA-U3 | Score breakdown screen | Wedge + Yoda | M | None | After level complete: animated tally of Enemies Defeated, Highest Combo, Time Bonus, Damage Taken penalty, Total Score. Letter grade (S/A/B/C/D). Drives score-chasing. |
| AAA-U4 | Wave/progress indicator | Wedge | S | None | Small "Wave 2/4" or progress dots at top-center of HUD. Players need to know how much level remains. Fills as waves are cleared. |
| AAA-U5 | Special move cooldown display | Wedge | S | AAA-C6 | Meter/icon near health bar showing super meter fill level. Glows when full. Pulses to draw attention. Clear affordance for "press X to activate." |
| AAA-U6 | Loading/couch gag screens | Wedge + Bossk | M | AAA-L6 | Between-level screens showing game couch gag art while assets "load" (or just as transition entertainment). Different gag each time. Low-effort, high-charm. |

### 2.7 Replayability & Progression (Yoda + Chewie)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-R1 | Difficulty modes | Yoda + Tarkin | M | None | 3 modes: "Chill Mode" (1.5× player HP, 0.7× enemy damage, generous i-frames), "Normal", "Nightmare Mode" (0.7× player HP, 1.3× enemy damage, tighter windows). Affects scoring multiplier. Very game naming. |
| AAA-R2 | Per-level rankings | Yoda + Chewie | M | AAA-U3 | S/A/B/C/D rank per level stored in localStorage. Based on score, time, and max combo. Shown on level select. Drives "get S rank on every level" goal. |
| AAA-R3 | Per-level challenges | Yoda + Ackbar | M | AAA-L4 | 3 optional challenges per level: "No damage taken," "Reach 10-hit combo," "Complete under 3 minutes." Shown in level select. Unlock cosmetic rewards. Low-cost, high-replay-value per research. |
| AAA-R4 | Unlockable extras | Yoda | S | AAA-CH5, AAA-R3 | Gallery of character concept art, enemy profiles, sound test. Unlocked by completing challenges or reaching milestones. Reward layer for completionists. |
| AAA-R5 | Leaderboard (localStorage) | Chewie + Wedge | M | AAA-U3 | Per-level top-10 local leaderboard. Shows rank, score, character, date. "Can you beat your own score?" Self-competition in absence of online features. |

### 2.8 Technical & Accessibility (Chewie + Ackbar)

| # | Item | Owner | Complexity | Dependencies | Description |
|---|------|-------|-----------|--------------|-------------|
| AAA-T1 | 60fps performance budget | Chewie + Ackbar | L | None | Profile and optimize: batch Canvas draw calls, minimize allocations per frame, object pooling for particles/VFX/enemies. Target: maintain 60fps with 10+ enemies + full VFX on mid-range hardware. |
| AAA-T2 | Event bus integration | Chewie | L | M3 (events.js exists) | Wire the existing event bus into gameplay: enemy.hit, wave.start, wave.clear, player.damage, combo.milestone, boss.phase events. Decouples systems — VFX subscribes to events instead of gameplay.js calling VFX directly. Reduces god-scene coupling. |
| AAA-T3 | Colorblind mode | Wedge + Ackbar | S | None | Options toggle: replaces color-dependent information (health bar, enemy types) with pattern/shape differentiation. Enemy type icons above heads. Not just color swap — ensure all game-critical info has non-color cues. |
| AAA-T4 | Input remapping | Chewie + Wedge | M | None | Settings screen to rebind keys. Store in localStorage. Default controls stay. Essential accessibility feature. Gamepad support as stretch. |
| AAA-T5 | Gamepad support | Chewie | M | AAA-T4 | Gamepad API integration. Map d-pad/sticks to movement, face buttons to punch/kick/jump/special. Auto-detect on connect. Beat 'em ups feel best on controllers. |
| AAA-T6 | Automated smoke tests | Ackbar + Chewie | M | AAA-T2 (event bus) | Headless test: init → spawn → move → attack → enemy damage → enemy die → score → wave clear → level complete. Run via event bus assertions. Catches regressions on every change. |

---

## 3. "Future: Engine Migration" Items

Things that CANNOT be done well on Canvas 2D + vanilla JS. These are explicitly OUT OF SCOPE for the current tech stack but documented for a potential future migration.

| # | Item | Why Canvas 2D Can't | Target Tech | Impact |
|---|------|---------------------|-------------|--------|
| FUT-1 | Shader-based effects (glow, bloom, blur) | Canvas 2D has no programmable shaders. `filter` CSS property is slow and limited. Real-time bloom/blur requires fragment shaders. | WebGL / PixiJS / Phaser | Would enable hit glow halos, boss aura effects, screen-wide bloom on super moves, motion blur on dashes. |
| FUT-2 | Skeletal animation (Spine-like) | Canvas 2D procedural drawing means redrawing every frame from code. Skeletal animation requires bone hierarchies with interpolation, which is impractical without a runtime. | Spine / DragonBones + WebGL | Would enable fluid character animation, blend trees, IK for grab poses, cloth physics on Defender's dress. |
| FUT-3 | WebGL rendering pipeline | Canvas 2D is CPU-rendered and single-threaded. At 20+ entities with VFX, particle systems, and parallax layers, CPU becomes the bottleneck. | WebGL / PixiJS | Would enable GPU-accelerated rendering, sprite batching, 100+ particles without frame drops, post-processing pipeline. |
| FUT-4 | Online multiplayer | Requires WebSocket/WebRTC infrastructure, server-authoritative game state, input prediction, rollback netcode. Far beyond vanilla JS scope. | Node.js server + WebSocket | Would enable 2-4 player online co-op — the genre's killer feature. |
| FUT-5 | Sprite sheet asset pipeline | Current approach: procedural Canvas drawing. Real sprite sheets need: asset loading, atlas packing, frame extraction, async load management. | PixiJS / custom loader | Would enable imported pixel art, artist-drawn sprites, animation editors like Aseprite integration. |
| FUT-6 | Advanced particle system | Canvas 2D particles are CPU-limited. GPU particle systems can handle 1000+ particles with physics at zero CPU cost. | WebGL compute / PixiJS particles | Would enable weather effects (rain, snow), massive explosion debris, environmental particle fog. |
| FUT-7 | Local multiplayer (same keyboard) | Technically possible but input conflicts with 2+ players on one keyboard make it impractical. Gamepad helps but browser Gamepad API is inconsistent. | Gamepad API + careful key mapping | Would enable couch co-op — research says co-op is the genre's killer feature. Feasible but risky on current stack. |
| FUT-8 | Mobile touch controls | Touch input for a 6-button beat 'em up requires virtual joystick + action buttons. Canvas 2D touch events work but UI overlay adds complexity. | Touch API + virtual pad | Would expand audience to mobile. Technically possible but UX is challenging for a genre that demands precise input. |

---

## 4. Prioritized Execution Plan

### Phase A: Combat Excellence — "Make it feel award-worthy"
**Goal:** Every punch, kick, grab, and dodge feels incredible. This is the foundation everything else is built on.  
**Duration estimate:** Weeks 1-3  
**Principle:** "A fun game with simple art beats a pretty game with mushy controls."

| # | Item | Owner | Size | Deps | Priority |
|---|------|-------|------|------|----------|
| A-1 | Fix C1-C3 critical bugs (enemy attacks) | Lando + Tarkin | S | None | ★★★ Blocker |
| A-2 | Grab/throw system (AAA-C1) | Lando | XL | A-1 | ★★★ Core |
| A-3 | Dodge roll with i-frames (AAA-C2) | Lando | L | None | ★★★ Core |
| A-4 | Attack buffering (AAA-C9) | Chewie | M | None | ★★★ Core |
| A-5 | Back attack (AAA-C8) | Lando | S | None | ★★☆ High |
| A-6 | Dash attack (AAA-C7) | Lando | M | A-3 | ★★☆ High |
| A-7 | Directional combo finishers (AAA-C10) | Lando + Yoda | M | P1-5 | ★★☆ High |
| A-8 | Juggle physics (AAA-C3) | Lando | L | A-2 | ★★☆ High |
| A-9 | Style/combo scoring meter (AAA-C4) | Yoda + Wedge | M | None | ★★☆ High |
| A-10 | Taunt mechanic (AAA-C5) | Lando + Yoda | M | None | ★☆☆ Med |
| A-11 | Super move meter (AAA-C6) | Lando + Bossk | L | A-10, A-9 | ★☆☆ Med |
| A-12 | Enemy behavior tree upgrade (EX-T1) | Tarkin | M | None | ★★★ Core |
| A-13 | Enemy attack throttling refinement (P1-4) | Tarkin | S | A-12 | ★★☆ High |
| A-14 | Encounter pacing curve (EX-T3) | Tarkin + Yoda | S | A-12 | ★★☆ High |
| A-15 | Wave composition rules (EX-T2) | Tarkin + Yoda | S | None | ★★☆ High |
| A-16 | Hitbox visualization (EX-A1) | Ackbar | S | None | ★★★ Core |
| A-17 | Frame data documentation (EX-A2) | Ackbar | S | A-1 | ★★☆ High |
| A-18 | Input responsiveness audit (EX-A8) | Ackbar | S | A-4 | ★☆☆ Med |
| A-19 | Difficulty modes (AAA-R1) | Yoda + Tarkin | M | None | ★☆☆ Med |

**Parallel lanes:**
- **Lane 1 (Lando):** A-1 → A-2 → A-3 → A-5 → A-6 → A-7 → A-8 → A-10 → A-11
- **Lane 2 (Tarkin):** A-1 → A-12 → A-13 → A-14 → A-15
- **Lane 3 (Chewie):** A-4, then support A-11
- **Lane 4 (Yoda):** A-9 → A-14 → A-15 → A-19
- **Lane 5 (Ackbar):** A-16 → A-17 → A-18 (continuous playtesting)
- **Lane 6 (Wedge):** A-9 (UI for style meter)

### Phase B: Visual Excellence — "Make it look stunning"
**Goal:** Every frame should be screenshot-worthy. Downtown comes alive.  
**Duration estimate:** Weeks 2-5 (overlaps with Phase A)  
**Principle:** Art specialists work in parallel with combat team.

| # | Item | Owner | Size | Deps | Priority |
|---|------|-------|------|------|----------|
| B-1 | Art direction enforcement (EX-B1) | Boba | S | None | ★★★ Blocker |
| B-2 | Consistent entity rendering style (EX-B7) | Boba + Nien | M | B-1 | ★★★ Core |
| B-3 | Character ground shadows (EX-B2) | Bossk | S | None | ★★★ Core |
| B-4 | Brawler walk cycle (P1-9 / vis-mod §1.5) | Nien | M | P1-8 | ★★★ Core |
| B-5 | Brawler attack animations (P1-10 / vis-mod §1.4+) | Nien | M | P1-8 | ★★★ Core |
| B-6 | Facial expressions (vis-mod §1.4) | Nien | S | None | ★★☆ High |
| B-7 | Brawler detail polish (stubble, ears, hands, shirt) | Nien | M | B-1 | ★★☆ High |
| B-8 | Enemy unique silhouettes (vis-mod §2.1-2.4) | Nien | L | B-1 | ★★☆ High |
| B-9 | Enemy walk cycles (vis-mod §2.5) | Nien | M | B-4 | ★★☆ High |
| B-10 | Enemy attack telegraph VFX (EX-B3) | Bossk | S | P1-8 | ★★★ Core |
| B-11 | Attack motion trails polish (EX-B4) | Bossk | M | P1-8 | ★★☆ High |
| B-12 | Enemy spawn effects (EX-B5) | Bossk | S | None | ★☆☆ Med |
| B-13 | Death animations (AAA-V8) | Nien + Bossk | M | P1-8 | ★★☆ High |
| B-14 | Background landmark expansion (vis-mod §3.2) | Leia | L | None | ★★☆ High |
| B-15 | Background foreground parallax layer | Leia | M | B-14 | ★☆☆ Med |
| B-16 | Environmental storytelling details (AAA-V5) | Leia + Boba | M | B-14 | ★☆☆ Med |
| B-17 | Atmospheric perspective (vis-mod §3.3) | Leia | S | None | ★☆☆ Med |
| B-18 | Screen zoom on power hits (AAA-V1) | Bossk + Chewie | M | None | ★★☆ High |
| B-19 | Slow-motion final kill (AAA-V2) | Chewie + Bossk | M | None | ★★☆ High |
| B-20 | Scene transitions (AAA-V6) | Bossk + Wedge | M | None | ★☆☆ Med |
| B-21 | Character idle animations (AAA-V4) | Nien | M | P1-8 | ★☆☆ Med |
| B-22 | Background animations (EX-B8) | Leia | M | B-14 | ★☆☆ Med |

**Parallel lanes:**
- **Lane 1 (Boba — Art Director):** B-1 → B-2 → review all artist output. Spot-check, not bottleneck.
- **Lane 2 (Nien — Characters):** B-4 → B-5 → B-6 → B-7 → B-8 → B-9 → B-13 → B-21
- **Lane 3 (Bossk — VFX):** B-3 → B-10 → B-11 → B-12 → B-18 → B-19 → B-20
- **Lane 4 (Leia — Environments):** B-14 → B-15 → B-16 → B-17 → B-22

### Phase C: Content Depth — "Multiple characters, levels, bosses"
**Goal:** Transform from a demo into a full game. 3+ levels, 4 playable characters, diverse enemies.  
**Duration estimate:** Weeks 4-8 (overlaps with Phase B tail)

| # | Item | Owner | Size | Deps | Priority |
|---|------|-------|------|------|----------|
| C-1 | Content data format (EX-T4) | Tarkin | M | P1-14 | ★★★ Blocker |
| C-2 | Fast enemy type enhancements (P2-2) | Tarkin | S | A-12 | ★★☆ High |
| C-3 | Heavy enemy type enhancements (P2-3) | Tarkin | S | A-12 | ★★☆ High |
| C-4 | Ranged enemy type (P3-5) | Tarkin + Nien | M | C-1 | ★★☆ High |
| C-5 | Shield enemy type (P3-6) | Tarkin + Nien | M | C-1, AAA-C1 | ★★☆ High |
| C-6 | Mini-boss encounters (EX-T8) | Tarkin | M | A-12 | ★★☆ High |
| C-7 | Boss phase framework (EX-T5) | Tarkin | M | None | ★★☆ High |
| C-8 | Weapon pickups (P2-7) | Tarkin + Leia | M | AAA-L1 | ★★☆ High |
| C-9 | Food/health pickups (P2-8) | Tarkin + Leia | M | AAA-L1 | ★★☆ High |
| C-10 | Destructible objects (AAA-L1) | Tarkin + Leia | L | C-1 | ★★★ Core |
| C-11 | Throwable props (AAA-L2) | Tarkin + Lando | M | C-10, AAA-C1 | ★★☆ High |
| C-12 | Environmental hazards (AAA-L3) | Tarkin + Leia | M | C-10 | ★☆☆ Med |
| C-13 | the Kid (AAA-CH2) | Nien + Lando | XL | Phase A complete | ★★★ Core |
| C-14 | the Defender (AAA-CH3) | Nien + Lando | XL | C-13 | ★★☆ High |
| C-15 | the Prodigy (AAA-CH4) | Nien + Lando | XL | C-14 | ★☆☆ Med |
| C-16 | Character select screen (AAA-CH1) | Wedge + Nien | L | C-13 | ★★★ Core |
| C-17 | Level 2: City School (AAA-L4) | Tarkin + Leia | XL | C-1, C-10 | ★★★ Core |
| C-18 | Level 3: Factory (AAA-L5) | Tarkin + Leia | XL | C-17 | ★★☆ High |
| C-19 | Cinematic boss intros (AAA-V3) | Bossk + Nien | L | C-7 | ★★☆ High |
| C-20 | Couch gag level intros (AAA-L6) | Yoda + Bossk | M | Per level | ★☆☆ Med |
| C-21 | Set piece encounters (AAA-L7) | Tarkin + Yoda | L | C-17 | ★☆☆ Med |
| C-22 | Character unlock system (AAA-CH5) | Yoda + Chewie | M | C-13 | ★☆☆ Med |
| C-23 | Pickup drop table system (EX-T6) | Tarkin | S | C-8, C-9 | ★☆☆ Med |
| C-24 | Enemy group coordination (EX-T7) | Tarkin | M | A-12 | ★★☆ High |
| C-25 | Enemy intro sequences (EX-T9) | Tarkin + Yoda | S | C-4 or C-5 | ★☆☆ Med |

**Parallel lanes:**
- **Lane 1 (Tarkin):** C-1 → C-2 → C-3 → C-4 → C-5 → C-6 → C-7 → C-10 → C-12 → C-17 → C-18
- **Lane 2 (Nien + Lando):** C-13 → C-14 → C-15 (characters need Phase A combat systems)
- **Lane 3 (Leia):** C-8 → C-9 → C-10 (art) → C-11 → C-17 (art) → C-18 (art)
- **Lane 4 (Yoda):** C-20 → C-21 → C-22 → C-25 (design specs for all content)
- **Lane 5 (Wedge):** C-16 (character select)
- **Lane 6 (Bossk):** C-19 → C-20

### Phase D: Polish & Juice — "The 10% that makes it feel 100% complete"
**Goal:** Every interaction has feedback, every screen has polish, every sound is satisfying.  
**Duration estimate:** Weeks 7-10

| # | Item | Owner | Size | Deps | Priority |
|---|------|-------|------|------|----------|
| D-1 | Character voice barks (AAA-A1) | Greedo | L | None | ★★★ Core |
| D-2 | Environmental ambience (AAA-A2) | Greedo | M | None | ★★☆ High |
| D-3 | Dynamic crowd reactions (AAA-A3) | Greedo | M | AAA-C4 | ★★☆ High |
| D-4 | Hit sound combo scaling (AAA-A4) | Greedo | S | P1-5 | ★★☆ High |
| D-5 | Boss music themes (AAA-A5) | Greedo | L | C-7 | ★★☆ High |
| D-6 | game pickup sounds (AAA-A6) | Greedo | S | C-8, C-9 | ★☆☆ Med |
| D-7 | Options/settings menu (AAA-U1) | Wedge | M | None | ★★★ Core |
| D-8 | Pause menu redesign (AAA-U2) | Wedge | M | None | ★★☆ High |
| D-9 | Score breakdown screen (AAA-U3) | Wedge + Yoda | M | None | ★★★ Core |
| D-10 | Wave progress indicator (AAA-U4) | Wedge | S | None | ★★☆ High |
| D-11 | Special cooldown display (AAA-U5) | Wedge | S | AAA-C6 | ★☆☆ Med |
| D-12 | Level select / world map (AAA-L8) | Wedge + Leia | M | C-17 | ★★☆ High |
| D-13 | Per-level rankings (AAA-R2) | Yoda + Chewie | M | D-9 | ★★☆ High |
| D-14 | Per-level challenges (AAA-R3) | Yoda + Ackbar | M | C-17 | ★★☆ High |
| D-15 | Unlockable extras (AAA-R4) | Yoda | S | D-14 | ★☆☆ Med |
| D-16 | Local leaderboard (AAA-R5) | Chewie + Wedge | M | D-9 | ★☆☆ Med |
| D-17 | Weather/atmosphere system (AAA-V7) | Leia + Bossk | L | C-17 | ★☆☆ Med |
| D-18 | Loading/couch gag screens (AAA-U6) | Wedge + Bossk | M | C-20 | ★☆☆ Med |
| D-19 | 60fps performance budget (AAA-T1) | Chewie + Ackbar | L | Phase C | ★★★ Core |
| D-20 | Event bus integration (AAA-T2) | Chewie | L | None | ★★☆ High |
| D-21 | Colorblind mode (AAA-T3) | Wedge + Ackbar | S | None | ★☆☆ Med |
| D-22 | Input remapping (AAA-T4) | Chewie + Wedge | M | None | ★★☆ High |
| D-23 | Gamepad support (AAA-T5) | Chewie | M | D-22 | ★☆☆ Med |
| D-24 | Automated smoke tests (AAA-T6) | Ackbar + Chewie | M | D-20 | ★★☆ High |
| D-25 | Playtest protocol & metrics (EX-A6) | Ackbar | M | None | ★★★ Core |
| D-26 | DPS balance analysis (EX-A5) | Ackbar | S | Phase A | ★★☆ High |
| D-27 | Edge case regression checklist (EX-A4) | Ackbar | S | Phase A | ★★★ Core |

**Parallel lanes:**
- **Lane 1 (Greedo):** D-1 → D-2 → D-3 → D-4 → D-5 → D-6
- **Lane 2 (Wedge):** D-7 → D-8 → D-9 → D-10 → D-11 → D-12
- **Lane 3 (Yoda):** D-13 → D-14 → D-15 (design + balance specs)
- **Lane 4 (Chewie):** D-19 → D-20 → D-22 → D-23 → D-24
- **Lane 5 (Ackbar):** D-25 → D-26 → D-27 (continuous throughout)
- **Lane 6 (Leia + Bossk):** D-17 → D-18

### Phase E: Future / Engine Migration
**Goal:** Items that push beyond Canvas 2D + vanilla JS. Only pursue after Phases A-D ship.  
**Status:** Documented, not scheduled.

| # | Item | Tech Required | Impact | Notes |
|---|------|--------------|--------|-------|
| E-1 | WebGL migration (FUT-3) | PixiJS / Phaser | Unlocks GPU rendering, all shader effects | Biggest single migration. Everything else follows. |
| E-2 | Shader effects (FUT-1) | WebGL | Bloom, glow, blur, chromatic aberration | Depends on E-1 |
| E-3 | Skeletal animation (FUT-2) | Spine/DragonBones | Fluid animation, blend trees, IK | Depends on E-1 |
| E-4 | Online multiplayer (FUT-4) | WebSocket + server | The genre's killer feature | Massive scope. Could use a relay service. |
| E-5 | Sprite sheet pipeline (FUT-5) | PixiJS loader | Enable artist-drawn sprites, Aseprite export | Depends on E-1 |
| E-6 | GPU particle system (FUT-6) | WebGL compute | 1000+ particles, weather, explosions | Depends on E-1 |
| E-7 | Local multiplayer (FUT-7) | Gamepad API | Couch co-op on one device | Feasible now but risky |
| E-8 | Mobile touch controls (FUT-8) | Touch API | Mobile audience expansion | UX challenge for beat 'em up inputs |

---

## 5. Complete Backlog Summary

### Item Count by Phase

| Phase | New Items (this doc) | Carried from existing 85 | Total |
|-------|---------------------|-------------------------|-------|
| A (Combat) | 11 new AAA-C items | 8 existing (EX-T1-T3, EX-A1-A2, EX-A8, P1-4, P1-5) | 19 |
| B (Visual) | 8 new AAA-V items | 14 existing (EX-B1-B8, P1-8-P1-10, P2-4-P2-5) | 22 |
| C (Content) | 14 new AAA items | 11 existing (EX-T4-T9, P2-1-P2-3, P3-5-P3-7) | 25 |
| D (Polish) | 15 new AAA items | 12 existing (EX-G1-G8, EX-A4-A7, P1-12) | 27 |
| E (Future) | 8 items | 0 | 8 |
| **Total** | **56 new** | **45 carried** | **101 active + 8 future** |

### Owner Load Distribution (Active Items Only)

| Owner | Phase A | Phase B | Phase C | Phase D | Total |
|-------|---------|---------|---------|---------|-------|
| **Lando** (Gameplay) | 9 | 0 | 3 | 0 | 12 |
| **Tarkin** (Content) | 5 | 0 | 13 | 0 | 18 |
| **Nien** (Characters) | 0 | 9 | 3 | 0 | 12 |
| **Leia** (Environments) | 0 | 5 | 4 | 2 | 11 |
| **Bossk** (VFX) | 0 | 7 | 2 | 2 | 11 |
| **Boba** (Art Director) | 0 | 2 | 0 | 0 | 2 (+ reviews) |
| **Greedo** (Sound) | 0 | 0 | 0 | 6 | 6 |
| **Wedge** (UI) | 1 | 1 | 1 | 8 | 11 |
| **Chewie** (Engine) | 1 | 1 | 1 | 6 | 9 |
| **Yoda** (Game Design) | 3 | 0 | 4 | 4 | 11 |
| **Ackbar** (QA) | 3 | 0 | 0 | 4 | 7 |
| **Solo** (Lead) | 0 | 0 | 0 | 0 | 0 (orchestration) |

**Key insight:** No single person exceeds 18 items, and Tarkin's high count is distributed across Phases A and C (never overloaded in a single phase). Lando's critical path (Phase A combat) is 9 items, all sequential — this is the project's heartbeat and cannot be parallelized further. Everything else flows around it.

### Critical Path

```
Phase A: Lando's combat chain is the critical path
  A-1 (bug fixes) → A-2 (grab) → A-3 (dodge) → A-6 (dash) → A-8 (juggle)
  
Phase C: Characters depend on Phase A combat
  Phase A complete → C-13 (Kid) → C-14 (Defender) → C-15 (Prodigy)
  
Phase C: Levels depend on content data format
  C-1 (data format) → C-10 (destructibles) → C-17 (Level 2) → C-18 (Level 3)
```

All other work (visual, audio, UI, QA) runs in parallel and does NOT block the critical path.

---

## 6. What "Award-Winning" Looks Like

Based on the genre research, an award-winning browser beat 'em up needs:

1. **Combat that feels incredible** — Every hit has weight (hitlag + shake + particles + sound). Grab/throw for crowd control. Dodge for defense. Combos for expression. ✅ Achievable in Phase A.

2. **Character personality** — 4 distinct playable game, each feeling unique within 10 seconds. Taunts, voice barks, idle animations. ✅ Achievable in Phases B+C.

3. **Downtown as a character** — Backgrounds that make fans say "I recognize that!" Destructible objects, environmental gags, authentic locations. ✅ Achievable in Phases B+C.

4. **Replayability hooks** — Score rankings, challenges, character unlocks, difficulty modes. "One more run" motivation. ✅ Achievable in Phase D.

5. **Polish that surprises** — Screen zoom on kills, slow-mo on final enemy, crowd cheering, boss intros. The details that make players share screenshots. ✅ Achievable in Phases B+D.

6. **Technical respect** — 60fps, no bugs, accessible controls, colorblind mode. Respect the player. ✅ Achievable in Phase D.

**The game is 101 items away from award-worthy. With 12 specialists working 4 parallel lanes, this is a realistic — not aspirational — plan.**

---

*This document supersedes gap-analysis.md and backlog-expansion.md as the authoritative backlog. All previous items are either carried forward with updated priorities or explicitly superseded by AAA-tier replacements.*
