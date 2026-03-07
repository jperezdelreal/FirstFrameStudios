# Team Decisions

## Decision: Game Vision & Design Document

**Author:** Yoda (Game Designer)  
**Date:** 2025  
**Type:** Design Authority  
**Status:** Proposed  
**Artifact:** `.squad/analysis/game-design-document.md`

---

### Summary

Created the comprehensive Game Design Document (GDD) for SimpsonsKong — the team's north star for all design and implementation decisions.

### Key Decisions

#### Vision
SimpsonsKong is a browser-based Simpsons beat 'em up where comedy IS the combat. Players should laugh, feel powerful, and immediately want to try the next character. Instant-play browser design means zero friction, 5-7 minute levels, and session-friendly pacing.

#### Four Design Pillars
1. **Comedy as a Core Mechanic** — Humor is in the gameplay systems (taunts, D'oh! moments, Simpsons-rated combo meter), not just cosmetic.
2. **Accessible Depth** — Button-mashers have fun; combo masters have a different kind of fun. Streets of Rage 4 principle.
3. **Family Synergy** — Co-op mechanics reward playing as the Simpson family together (team attacks, proximity buffs, family super).
4. **Springfield Is a Character** — Environments are interactive playgrounds with landmark gags, destructibles, and hazards.

#### Core Combat
- **PPK combo** as the bread-and-butter (42 damage/1.1s)
- **Health-cost specials** with recovery-by-attacking (SoR2/SoR4 model)
- **Grab/throw system** (Turtles in Time influence)
- **Dodge roll with i-frames** (modern standard)
- **Super meter** filled by damage and taunts
- **Jump attacks rebalanced** with landing lag to prevent air-spam dominance (balance analysis finding)

#### Characters (4 planned, Homer first)
- Homer: Power/All-Rounder, Donut Rage Mode, Belly Bounce
- Bart: Speed, Skateboard Dash, Slingshot ranged, Bartman super
- Marge: Range, Purse Swing, Hair Whip, Maternal Instinct passive
- Lisa: Technical/CC, Saxophone Blast, Intellect Advantage dodge, Activist Rally super

#### Simpsons-Specific Mechanics
- **Donut Rage Mode** (eat 3 donuts → Homer power-up, creates heal vs. rage dilemma)
- **D'oh! Moments** (funny failure states at every level)
- **Couch Gag loading screens** (randomized, collectible transitions)
- **Springfield landmarks** as interactive combat elements
- **Simpsons food** as themed health pickups (Pink Donut, Krusty Burger, Flaming Moe)
- **Combat barks** (character quotes on gameplay events)

#### Balance Integration
Incorporated all 6 critical and 3 medium balance flags from Ackbar's analysis:
- Jump attack DPS capped at 38 (down from 50) via landing lag
- Enemy damage targets raised (8 base, up from 5)
- 2-attacker throttle as design principle, not performance compromise
- Knockback tuning to preserve PPK combo viability

#### Platform Constraints
Documented Canvas 2D limitations and "Future: Native/Engine Migration" items (shaders, skeletal animation, online multiplayer, advanced physics).

### Impact
Every team member now has a single reference for "what are we building and why." Design authority calls prevent scope creep and ensure coherence.

---

## Decision: Art Department Restructuring & Team Expansion

**Author:** Solo (Lead)  
**Date:** 2026-06-04  
**Status:** Proposal Evaluation  
**Requested by:** joperezd

---

### Executive Summary

**Verdict: APPROVE with modifications.** Boba is carrying 17 backlog items spanning 4 distinct disciplines (character art, environment art, VFX, and art direction). In real game dev, these are separate careers. The restructuring is justified. The Game Designer role fills a genuine gap that becomes more critical as the team scales. However, recommend phasing the rollout and adjusting one role boundary.

### 1. Does This Make Sense? Workload Justification

#### Current Boba Workload (17 items across 4 domains)

**Character Art (5 items):** P2-4 Homer redesign, P1-9 Homer walk cycle (art side), P1-10 Homer attack animations (art side), P1-11 Enemy death animation, EX-B7 Consistent entity rendering style.

**Environment Art (3 items):** P2-5 Background overhaul, EX-B6 Foreground parallax layer, EX-B8 Environmental background animations.

**VFX (5 items):** P1-2 Hit impact VFX, EX-B3 Enemy attack telegraph VFX, EX-B4 Attack motion trails, EX-B5 Enemy spawn-in effects, P2-9 KO text effects.

**Art Direction (2 items):** EX-B1 Art direction & color palette, EX-B2 Character ground shadows.

**Plus shared items:** P2-10 Animated title screen (with Wedge), P2-13 Score pop-ups.

#### Analysis

The visual modernization plan alone is **62KB** — a massive document covering Homer's stubble rendering, enemy proportions, background parallax layers, particle effects, and more. This is not a part-time gig. Each of the 4 proposed sub-roles maps cleanly to a real workload cluster:

| Proposed Role | Items Owned | Unique Skills Required |
|---------------|-------------|----------------------|
| Art Director | 2 + review all | Style coherence, palette design, proportional systems |
| Environment/Asset Artist | 3+ | Parallax math, tile/prop design, atmospheric effects |
| VFX Artist | 5+ | Particle systems, timing curves, screen effects |
| Character/Enemy Artist | 5+ | Anatomy/proportions, pose design, animation readability |

**Verdict: Yes, 4 art roles are justified.** Each has 3-5 items minimum on the current backlog, and the backlog will grow as the game develops (more enemies = more character art, more levels = more environments, more attacks = more VFX). The visual modernization plan alone has enough work to keep all 4 busy through P2.

**One concern:** At P3+ or between projects, the Environment Artist and VFX Artist may have lighter loads. This is acceptable — they can assist each other (VFX Artist helps with animated background elements, Environment Artist helps with environmental VFX like steam/fire). The Art Director can route overflow work.

### 2. Boba's Transition

#### Why Promotion Makes Sense

Boba is the strongest candidate for Art Director because:

1. **Created the art direction guide** (`.squad/analysis/art-direction.md`) — already established the color palette, outline approach, shading model, character proportions, and effects style. This IS art direction work.
2. **Wrote the visual modernization plan** (62KB) — demonstrated ability to analyze current state, define target state, and plan implementation across every visual system. This is exactly what an Art Director does.
3. **Understands the technical medium** — Canvas 2D API procedural drawing is the constraint. Boba knows what's possible and what's expensive. New artists will need this guidance.

#### Recommended Transition Process

1. **Boba retains the art direction documents** as canonical references. New artists read these first.
2. **Boba does NOT hand off in-progress work mid-stream.** Any items Boba has started should be completed by Boba. New artists pick up unstarted items.
3. **Art Director role includes code review authority** on all visual PRs. No visual code merges without Boba's review (or explicit delegation).
4. **First task for new artists:** Each new artist implements one small item under Boba's direct review to calibrate style alignment. Don't let them run free on day one.
5. **Boba's charter update:** Change from "VFX/Art Specialist" to "Art Director." Responsibilities shift from production to direction + review + style enforcement + selective production on high-complexity items (e.g., Homer's final design is too important to delegate to a new hire).

#### Risk: Boba Becomes a Bottleneck

If every visual change needs Art Director review, Boba becomes a chokepoint. Mitigation: Boba reviews the first 2-3 items from each new artist, then shifts to spot-check reviews. Trust builds. The art direction document serves as the "always-available reviewer" — if the work follows the guide, it's probably fine.

### 3. Game Designer Role

#### Is It Genuinely Needed?

**Yes, and the need is already visible.** Here's what's currently happening without a Game Designer:

- **Solo (Lead) is implicitly doing game design.** The gap analysis, the 52-item backlog, the phased execution plan, the priority rankings — these are all game design decisions made by a project lead. This works at small scale but doesn't scale.
- **Tarkin (Enemy/Content Dev) is doing content design.** Wave composition rules (EX-T2), encounter pacing curves (EX-T3), boss phase frameworks (EX-T5) — these are game design decisions embedded in a content dev role.
- **Ackbar (QA) is doing balance design.** DPS analysis (EX-A5), frame data documentation (EX-A2) — balance tuning IS game design.
- **Nobody owns the coherent vision.** Is SimpsonsKong a casual brawler or a technical fighter? How hard should it be? What's the target session length? What emotions should each wave evoke? These questions have no designated owner.

#### What a Game Designer Does Day-to-Day

| Activity | Frequency | Example |
|----------|-----------|---------|
| Maintain GDD | Ongoing | "Homer's punch should feel heavy — 4 frame startup, 8 active, 12 recovery. Compare to enemy punch: 6/6/8." |
| Review combat feel | Every combat change | "Hitlag is 4 frames but knockback distance is too short — enemies don't sell the hit. Increase from 60px to 90px." |
| Define enemy personalities | Per enemy type | "Fast enemy: harasses from flanks, never attacks head-on, retreats after 1 hit. Player should feel annoyed, not threatened." |
| Set difficulty curve | Per level | "Wave 3 is the first real challenge — 2 basic + 1 fast. Player should lose 20-30% health here on first attempt." |
| Resolve design conflicts | As needed | "Tarkin wants 8 enemies on screen for spectacle. Ackbar says it's unreadable. Design call: cap at 5, but make each feel more dangerous." |
| Write acceptance criteria | Per feature | "Jump attack: must hit enemies in a 60px radius on landing. Screen shake on landing. Dust particles. 1.5x damage of normal punch." |

#### Risk of NOT Having One

Without a Game Designer, design decisions get made by whoever happens to be working on that system. Lando decides punch frame data. Tarkin decides wave composition. Ackbar identifies balance problems but has no authority to define the target. The result is a game that works mechanically but lacks a coherent feel — each system is locally optimized but not globally harmonized.

**The risk scales with team size.** At 4 devs, implicit design worked. At 8, cracks showed (Tarkin and Ackbar both doing design-adjacent work). At 12, without a designer, you'll get 12 people pulling the game in 12 directions.

#### Recommendation

**Approve the Game Designer role.** Position it as a peer to Solo (Lead), not a report. Solo owns project execution (what to build, when, who). Game Designer owns game vision (what it should feel like, why, how it all fits together). They collaborate on priorities — the Game Designer says "we need hitlag before adding new enemies" and Solo says "agreed, slotting it into Phase 2."

### 4. Impact on Workflow

#### Routing Changes

Current routing sends ALL visual work to Boba. New routing:

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Art direction, style review, visual coherence | Boba (Art Director) | Style guide updates, cross-artist reviews, palette decisions |
| Backgrounds, props, tiles, parallax, landmarks | New: Environment Artist | P2-5, EX-B6, EX-B8, level-specific backgrounds |
| Particles, explosions, impacts, screen effects | New: VFX Artist | P1-2, EX-B3, EX-B4, EX-B5, P2-9 |
| Characters, enemies, animation poses, silhouettes | New: Character Artist | P2-4, P1-9 (art), P1-10 (art), P1-11, EX-B7 |
| Game vision, balance targets, design specs | New: Game Designer | GDD, difficulty curves, feature acceptance criteria |

#### Parallelism Gains

**Before (1 art pipeline):**
```
Boba: [art direction] → [Homer redesign] → [backgrounds] → [VFX] → [enemies]
                       (all sequential — one person)
```

**After (3 parallel art pipelines + oversight):**
```
Boba (Art Dir):   [style guide] → [review] → [review] → [review] → ...
Env Artist:       [backgrounds] → [parallax] → [props] → [level 2 bg] → ...
VFX Artist:       [hit VFX] → [telegraphs] → [trails] → [spawn FX] → ...
Char Artist:      [Homer redesign] → [walk cycle] → [enemy art] → [boss] → ...
Game Designer:    [GDD] → [frame data specs] → [difficulty curve] → [review] → ...
```

**3x art throughput** with quality oversight. This is the whole point.

#### Coordination Overhead

Adding 4 roles increases coordination cost. Mitigations:

1. **Art Director is the single routing point** for all visual questions. Other team members don't need to know which artist handles what — they go to Boba, who routes internally.
2. **Game Designer is the single design authority.** Tarkin, Ackbar, and Lando stop making ad-hoc design decisions — they consult the GDD or ask the designer.
3. **No new meetings needed.** Art Director reviews async (PR reviews). Game Designer writes specs in `.squad/analysis/` docs that others consume.

#### File Ownership Updates

| File | Current Owner | New Owner |
|------|--------------|-----------|
| `src/systems/background.js` | Boba | Environment Artist |
| `src/systems/vfx.js` | Boba | VFX Artist |
| `src/engine/particles.js` | Boba | VFX Artist |
| `src/entities/player.js` (render methods) | Boba/Lando | Character Artist (render) + Lando (gameplay) |
| `src/entities/enemy.js` (render methods) | Boba/Tarkin | Character Artist (render) + Tarkin (AI/gameplay) |
| Art direction docs | Boba | Boba (Art Director) |
| GDD (new) | N/A | Game Designer |

### 5. Naming — Remaining Star Wars OT Characters

#### Current Roster (8 named)

Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar.

#### 4 New Names Needed

Remaining iconic OT characters (unused): Luke, Leia, Vader, Yoda, Obi-Wan, R2, 3PO, Jabba, Palpatine, Biggs, Bossk, Nien Nunb, Piett, Mon Mothma, Dengar, IG-88, Lobot.

| Role | Proposed Name | Rationale |
|------|--------------|-----------|
| **Game Designer** | **Yoda** | The wisest character in Star Wars. Sees the big picture. Teaches others. A Game Designer defines the vision and guides the team — pure Yoda energy. |
| **Environment/Asset Artist** | **Leia** | Organized, detail-oriented, builds the world around the heroes. Leia constructs alliances and bases; this artist constructs the stages and settings. |
| **VFX Artist** | **Bossk** | A Trandoshan bounty hunter — fierce, explosive, intense. VFX work is about dramatic impacts, explosions, and visual ferocity. Bossk fits the energy. |
| **Character/Enemy Artist** | **Nien** | Nien Nunb — distinctive face, memorable design, personality in every detail. A Character Artist obsesses over exactly these qualities: silhouette, expression, personality. |

#### Updated Roster (12/12)

| # | Name | Role |
|---|------|------|
| 1 | Solo | Lead |
| 2 | Chewie | Engine Dev |
| 3 | Lando | Gameplay Dev |
| 4 | Wedge | UI Dev |
| 5 | Boba | Art Director *(promoted from VFX/Art Specialist)* |
| 6 | Greedo | Sound Designer |
| 7 | Tarkin | Enemy/Content Dev |
| 8 | Ackbar | QA/Playtester |
| 9 | Yoda | Game Designer *(new)* |
| 10 | Leia | Environment/Asset Artist *(new)* |
| 11 | Bossk | VFX Artist *(new)* |
| 12 | Nien | Character/Enemy Artist *(new)* |

**Note:** This maxes out the 12-character Star Wars roster. Future expansion would require either expanding the universe (Prequel/Sequel trilogy, Mandalorian, etc.) or increasing the cap.

### 6. Roles the User Didn't Mention

#### Considered and Rejected

| Role | Verdict | Reasoning |
|------|---------|-----------|
| **Animator** | ❌ Reject | The user's proposal implicitly distributes animation: Character Artist handles pose/frame design, VFX Artist handles effect animations, Engine Dev (Chewie) maintains the animation system (`src/engine/animation.js`). A dedicated Animator would overlap with all three. In a Canvas 2D procedural game, "animation" IS the art — there are no separate sprite sheets to animate. |
| **Level Designer** | ❌ Reject (covered) | Tarkin (Enemy/Content Dev) already owns level/wave design (EX-T2, EX-T3, EX-T4, P3-7). Adding the Game Designer (Yoda) further covers design-level thinking. A dedicated Level Designer would fight Tarkin for the same work. In a beat 'em up with linear levels, level design is a subset of content design, not a full role. |
| **Technical Artist** | 🟡 Monitor | In larger studios, a Tech Artist bridges art and engineering — building tools, optimizing render pipelines, creating shader utilities. Right now, Chewie (Engine Dev) handles the rendering pipeline and Boba understands Canvas 2D constraints. If the team hits friction where artists need tools that engineers don't prioritize, revisit this role. Not needed yet. |
| **UI Artist** | ❌ Reject | Wedge (UI Dev) handles HUD, menus, and screen layouts. The Character Artist (Nien) can provide art assets for UI elements (character portraits, icons) when needed. UI art volume is too low for a dedicated role in a beat 'em up. |
| **Narrative Designer** | ❌ Reject | Beat 'em ups have minimal narrative. Intro cutscene text, boss taunts, and game over screens don't justify a role. The Game Designer (Yoda) can write the thin narrative layer as part of the GDD. |

#### One Role Worth Watching: Dedicated Animator

I rejected this above, but I want to flag it explicitly. The visual modernization plan describes complex animation needs: walk cycles, attack anticipation frames, squash/stretch, secondary motion, idle breathing. Currently this work falls to the Character Artist, but animation is a distinct skill from static character design. If the Character Artist (Nien) struggles with timing and motion — the "acting" of animation — while excelling at proportions and design, we may need to split again. **Watch for this signal during Phase 2 (P1 Feel).** For now, keeping animation as a Character Artist responsibility is correct.

### 7. Implementation Sequence

If approved, recommended rollout order:

1. **Phase A — Game Designer (Yoda):** Onboard first. Before adding 3 artists, we need the GDD and design specs they'll work from. Yoda writes the GDD, defines Homer's target feel, specifies enemy personality profiles, and sets the difficulty curve. ~1 session to establish.

2. **Phase B — Promote Boba to Art Director:** Update charter, update routing table. Boba reviews the existing art direction guide and visual modernization plan, then produces a brief "artist onboarding brief" — the subset of the 62KB plan that new artists need on day one.

3. **Phase C — Onboard 3 Artists (Leia, Bossk, Nien):** All three start simultaneously. Each gets one small calibration task reviewed by Boba. After passing review, they pick up backlog items in their domain.

**Total new charters to write:** 4 (Yoda, Leia, Bossk, Nien)  
**Charters to update:** 1 (Boba)  
**Routing table updates:** 1 (routing.md)  
**Team table updates:** 1 (team.md)  
**Registry updates:** 1 (casting/registry.json)

### 8. Final Recommendation

| Decision | Verdict |
|----------|---------|
| Split art from 1→4 roles | ✅ **Approve** — workload and skill differentiation justify it |
| Promote Boba to Art Director | ✅ **Approve** — already doing the work, owns the knowledge |
| Add Game Designer | ✅ **Approve** — fills a real gap that scales with team size |
| Proposed ownership boundaries | ✅ **Approve** — clean splits along file/system lines |
| 4 new Star Wars names | ✅ **Approve** — Yoda, Leia, Bossk, Nien |
| Phase the rollout (Designer → Art Dir → Artists) | ✅ **Recommend** — design specs before production |

**Net result:** Team grows from 8 → 12 specialists. Art throughput triples. Design coherence gets an explicit owner. The risk is coordination overhead, mitigated by the Art Director as visual routing point and Game Designer as design authority. Both roles reduce noise for everyone else, not add it.

---

## Decision: AAA-Level Gap Analysis & Expanded Backlog

**Author:** Solo (Lead)  
**Date:** 2026-06-04  
**Status:** Proposed

---

### What

Comprehensive AAA gap analysis comparing SimpsonsKong's current state against "award-winning browser beat 'em up" standard. Produced a 101-item prioritized backlog (56 new + 45 carried from existing 85) organized into 5 execution phases, plus 8 future/migration items.

### Current State Assessment

| Area | Score (out of 10) |
|------|-------------------|
| Combat Feel | 5 |
| Enemy Variety | 4 |
| Visual Quality | 5.5 |
| Audio Quality | 6 |
| Level Design | 3 |
| UI/UX | 6 |
| Replayability | 2 |
| Technical Polish | 6 |
| **Overall** | **4.7** |

**Biggest gaps:** Grab/throw (in ALL 9 reference games, we have zero), dodge roll, multiple playable characters, level content depth (1 level vs. 6-8 needed), replayability systems.

### New Items Added (56 total)

- **Combat AAA (10):** Grab/throw, dodge roll, juggle physics, style meter, taunt, super meter, dash attack, back attack, attack buffering, directional finishers
- **Character Roster (5):** Character select, Bart/Marge/Lisa playable, unlock system
- **Level Design (8):** Destructibles, throwable props, hazards, 2 new levels, couch gags, set pieces, world map
- **Visual AAA (8):** Screen zoom, slow-mo kills, boss intros, idle animations, storytelling, transitions, weather, death animations
- **Audio AAA (6):** Voice barks, ambience, crowd reactions, combo scaling, boss music, pickup sounds
- **UI/UX AAA (6):** Options menu, pause redesign, score breakdown, wave indicator, cooldown display, loading screens
- **Replayability (5):** Difficulty modes, per-level rankings, challenges, unlockables, leaderboard
- **Technical (6):** 60fps budget, event bus, colorblind mode, input remap, gamepad, smoke tests

### Execution Phases

| Phase | Focus | Items | Duration |
|-------|-------|-------|----------|
| **A: Combat Excellence** | Make combat feel award-worthy | 19 | Weeks 1-3 |
| **B: Visual Excellence** | Make it look stunning | 22 | Weeks 2-5 |
| **C: Content Depth** | Characters, levels, bosses | 25 | Weeks 4-8 |
| **D: Polish & Juice** | The 10% that makes it feel 100% | 27 | Weeks 7-10 |
| **E: Future/Migration** | Beyond Canvas 2D | 8 | Post-ship |

### Key Decisions Made

1. **Combat first, always.** Lando's combat chain (grab → dodge → dash → juggle) is the critical path. Everything else runs in parallel.
2. **4 playable characters.** Homer + Bart + Marge + Lisa. Each follows the speed/power/range archetype triangle from research.
3. **3 levels minimum.** Springfield Streets → Springfield Elementary → Nuclear Power Plant. Each with unique boss and environment.
4. **Engine migration is Phase E.** Canvas 2D can deliver an award-winning game. WebGL migration is valuable but NOT required for the prize.
5. **No single owner exceeds 18 items.** Tarkin has the highest count (18) but distributed across two phases. Lando's critical path is 9 items.

### Full Document

See `.squad/analysis/aaa-gap-analysis.md` for complete analysis with per-item owners, complexities, dependencies, and lane assignments.

### Why

The user wants to "elevar este juego a categoría AAA y ganar un premio." The existing 85-item backlog was engineer-focused and missed fundamental genre requirements (grab/throw, multiple characters, level variety). This analysis bridges the gap between "working prototype" and "award-worthy game" using the 12-person team's full specialist capacity.

---

## Gap Analysis — Key Findings & Recommendations

**From:** Keaton (Lead)  
**Date:** 2026-06-03  
**Type:** Analysis Summary for Team  

---

### Key Findings

1. **Overall MVP completion: ~75%.** The game is playable with solid core mechanics, but two critical gaps remain.

2. **P0 miss: High score persistence** — localStorage saving was an explicit requirement that was never implemented. This is trivial (< 30 min) and should be done immediately.

3. **Biggest quality gap: Visual quality at 30%.** The user repeatedly asked for "visually modern" and "clean, modern 2D look." Current characters are basic geometric shapes — recognizable as a game, but not as a modern one. This requires an animation system (P1-8) before meaningful visual improvement is possible.

4. **Combat feel at 50%.** The mechanics *work* but lack *juice*. The #1 missing element is **hitlag** (2-3 frame freeze on impact) — a small change with massive feel improvement. After that: impact VFX, sound variation, and combo chains.

5. **Architecture is sound but needs targeted refactoring.** The gameplay scene is a "god object" handling waves, camera, background, and game state. This must be decomposed before adding levels, enemy variety, or pickups.

6. **Gameplay Dev is the bottleneck.** ~60% of the backlog routes to this role. Consider adding a VFX/Art specialist to handle visual improvements independently.

### Recommended Immediate Actions

| Priority | Action | Owner | Effort |
|----------|--------|-------|--------|
| 🔴 Now | Implement localStorage high score | UI Dev | S |
| 🔴 Now | Add kick animation + kick/jump SFX | Gameplay Dev + Engine Dev | S |
| 🟡 Next | Add hitlag on attack connect | Engine Dev | S |
| 🟡 Next | Add enemy attack throttling (max 2 attackers) | Gameplay Dev | S |
| 🟡 Next | Build animation system core | Engine Dev | L |
| 🔵 After | Combo system + jump attacks | Gameplay Dev | M |
| 🔵 After | Gameplay scene refactor | Lead | M |

### Team Recommendation

Current team (Lead, Engine Dev, Gameplay Dev, UI Dev) is sufficient for P0 and P1. For P2 (visual overhaul, enemy variety, boss), strongly recommend adding a **VFX/Art specialist** who can work on Canvas-drawn art and particle effects without blocking the engineers.

### Decision Required

Should we prioritize **combat feel** (hitlag, combos, enemy AI) or **visual quality** (animation system, character redesign) first? Both need the animation system, so P1-8 is the critical path regardless. My recommendation: **combat feel first** — a fun-feeling game with simple art beats a pretty game that feels mushy.

---

*Full analysis: `.squad/analysis/gap-analysis.md`*

---

## High Score localStorage Key & Save Strategy

**Author:** Wedge  
**Date:** 2025-01-01  
**Status:** Implemented  
**Scope:** P0-1 — High Score Persistence

### Decision

- localStorage key is `simpsonsKong_highScore` — namespaced to avoid collisions if other games share the domain.
- High score is saved at the moment `gameOver` or `levelComplete` is triggered, not continuously during gameplay. A `highScoreSaved` flag prevents duplicate writes.
- `saveHighScore()` returns a boolean so the renderer can show "NEW HIGH SCORE!" vs the existing value — no extra localStorage read needed in the render loop for that decision.
- All localStorage access is wrapped in try/catch to gracefully handle private browsing or disabled storage (falls back to 0).
- Title screen only shows the high score label when value > 0, keeping a clean first-play experience.

### Why

- Single save point is simpler and avoids unnecessary writes during gameplay.
- Boolean return from save avoids coupling render logic to storage checks.
- Graceful fallback means the game never crashes due to storage restrictions.

---

## AudioContext Resume Pattern

**Author:** Greedo  
**Date:** 2025-06-04  
**Status:** Implemented

### Context
Web Audio API requires a user gesture before AudioContext can produce sound. The previous code created the context eagerly in the constructor, meaning audio could silently fail on first load in Chrome, Safari, and Firefox.

### Decision
- AudioContext is still created in the constructor (so `currentTime` etc. are available immediately)
- A `resume()` method checks `context.state === 'suspended'` and calls `context.resume()`
- `main.js` registers a one-time `keydown`/`click` listener that calls `audio.resume()` and removes itself
- All existing `playX()` methods continue to work without changes — they just produce no sound until the context is resumed

### Why
- Transparent fix: zero changes to any caller code
- One-time listener self-removes to avoid unnecessary event handling
- Works across all modern browsers (Chrome, Firefox, Safari, Edge)
- The title screen requires ENTER to start, so audio is always resumed before gameplay begins

### Trade-offs
- If a caller tries to play sound before any user interaction, it silently does nothing (acceptable — matches browser behavior)
- Could alternatively lazy-create the context on first `resume()`, but that would delay `currentTime` baseline — not worth the complexity

---

## Backlog Expansion for 8-Person Team

**Author:** Solo (Lead)  
**Date:** 2026-06-03  
**Status:** Proposed

### Summary

Expanded the 52-item backlog to 85 items (+33 new) after analyzing what domain specialists (Boba, Greedo, Tarkin, Ackbar) would identify that the original 4-engineer team missed. Also re-assigned 28 existing items to correct specialist owners.

### Key Outcomes

1. **Lando's bottleneck eliminated:** Dropped from 26 items (50% of backlog) to 10 items focused on player mechanics. This was the #1 structural problem.

2. **Chewie freed from audio:** 7 audio items moved to Greedo. Chewie now focuses purely on engine systems (game loop, renderer, animation controller, particles, events).

3. **33 new items added — zero busywork.** Every item addresses a real gap:
   - Boba: 8 items — art foundations before art production (palette, shadows, telegraphs, style guide)
   - Greedo: 8 items — audio infrastructure before sound content (mix bus, layering, priority, spatial)
   - Tarkin: 9 items — content systems before content authoring (behavior trees, data format, pacing, wave rules)
   - Ackbar: 8 items — dev tools before testing (hitbox debug, frame data, overlay, regression checklist)

4. **One new P0 discovered:** Audio context initialization (EX-G1) — Web Audio silently fails without user gesture. Potential showstopper engineers missed.

5. **Specialist pattern: infrastructure first.** All four specialists prioritized systems/tools over content. This is the right call — build the pipeline, then fill it.

### Impact

Backlog growth from 52→85 does NOT mean longer timeline. The 8-person team parallelizes across 4 independent workstreams. More items + more people = same or shorter delivery with higher quality.

### Full Details

See `.squad/analysis/backlog-expansion.md` for complete item list, re-assignment tables, and load analysis.

# Decision Proposal: Rendering Technology

**From:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Priority:** High  
**Status:** Proposed

## Summary

Researched 5 rendering technology options to address the "cutre" (cheap-looking) graphics feedback. Full analysis in `.squad/analysis/rendering-tech-research.md`.

## Current Problem

- No HiDPI/Retina support → blurry text and shapes on modern displays
- ~100 canvas API calls per entity per frame → no headroom for richer art
- No GPU effects → flat, unpolished look (no glow, blur, bloom)
- Fixed 1280×720 → doesn't scale to larger screens

## Recommendation: Two-Phase Approach

### Phase 1 — Canvas 2D Optimization (NOW, 8-12 hours, zero risk)
1. **HiDPI fix** — scale canvas by `devicePixelRatio`. Fixes blurry signs immediately.
2. **Sprite caching** — pre-render entities to offscreen canvases, `drawImage()` each frame. 10× perf gain.
3. **Resolution-independent design** — internal 1920×1080, scale to any screen.

### Phase 2 — Hybrid Canvas + PixiJS (LATER, 23-35 hours, if Phase 1 isn't enough)
- Add PixiJS via CDN UMD (no build step needed)
- Keep procedural Canvas drawing → convert to PixiJS textures
- GPU filters for bloom, glow, distortion effects
- PixiJS ParticleContainer for particle storms

### Rejected Options
- **Full PixiJS rewrite** — similar cost to hybrid but loses procedural drawing flexibility
- **Phaser** — 50-74h rewrite, replaces working systems we've built, 1.2MB bundle
- **Three.js** — overkill for 2D, 80+h rewrite

## Impact
Phase 1 alone should transform the visual quality from "cutre" to "polished indie." Phase 2 adds AAA-level GPU effects if needed.

## Decision Needed
Approve Phase 1 implementation (HiDPI + sprite caching + resolution scaling). Phase 2 deferred until we evaluate Phase 1 results.



---

# Decision Inbox: Tech Ambition Evaluation

**From:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Priority:** P0 — Strategic Direction  
**Status:** Proposal — Awaiting Team Discussion

---

## Summary

Evaluated 5 engine options across 9 dimensions for the next project ("nos jugamos todo"). Full analysis in `.squad/analysis/next-project-tech-evaluation.md`.

## Recommendation: Godot 4

**Phaser 3 is a good engine. Godot 4 is the right weapon for the fight we're picking.**

### Why Not Phaser
- Web-only limits us to itch.io — no Steam, no mobile, no console
- Every award-winning beat 'em up ships native. Zero browser-only games in the competitive set.
- We'd lose our procedural audio system (931 LOC) — Phaser is file-based only
- Visual ceiling: 8.5/10 vs Godot's 9.5/10
- Performance ceiling: browser JS GC vs native binary

### Why Godot
- **Multi-platform:** Web + Desktop + Mobile + Console (via W4) from one codebase
- **2D is first-class:** Not a 3D engine with 2D bolted on (unlike Unity)
- **Free forever:** MIT license, no pricing surprises, no runtime fees
- **Our knowledge transfers:** Fixed timestep → `_physics_process`, event bus → signals, audio bus → AudioBus system, hitlag → `Engine.time_scale`. Concepts transfer, only syntax changes.
- **Procedural audio survives:** `AudioStreamGenerator` provides raw PCM buffer for Greedo's synthesis work
- **Built-in tools accelerate squad:** Animation editor, particle designer, shader editor, tilemap editor, debugger, profiler — every specialist gets real tools
- **Community exploding:** 100K+ GitHub stars, fastest-growing engine, backed by W4 Games

### Why Not Unity
- C# learning curve (2-3 months vs GDScript's 2-3 weeks)
- Heavy editor, slow iteration
- Pricing trust eroded
- Scene merge conflicts with 12-person squad

### The Score
| Engine | Total (9 dimensions) |
|--------|---------------------|
| **Godot 4** | **74/90** |
| Phaser 3 | 66/90 |
| Unity | 66/90 |
| Defold | 57/90 |

### Cost
- 2-3 week learning sprint before production velocity matches current level
- GDScript ramp-up (Python-like, approachable for JS devs)
- SimpsonsKong engine code (1,931 LOC) doesn't transfer — but all architectural knowledge does

### Action Needed
- Squad discussion on engine choice
- If approved: 2-week learning sprint → 2-week prototype → production

—Chewie


---

# Decision: Evaluate 2 Proposed New Roles for Godot Transition

**Author:** Solo (Lead)
**Date:** 2025-07-22
**Status:** Recommendation
**Requested by:** joperezd

---

## Context

The team is transitioning from a vanilla HTML/Canvas/JS stack to Godot 4 for future projects. Two new roles are proposed: **Chief Architect** and **Tool Engineer**. The current squad is at 12/12 OT Star Wars character capacity (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien) plus Scribe and Ralph as support. This evaluation assesses whether these roles are genuinely new or absorbable into existing charters.

---

## 1. Does Solo Already Cover Chief Architect?

### Current Solo Charter
Solo's charter explicitly states:
- "Project architecture and structure decisions"
- "Code review and integration oversight"
- "Ensuring modules work together correctly"
- "Makes final call on architectural trade-offs"

### What Chief Architect Would Own
- Repo structure, game architecture, conventions
- Scene tree design, node hierarchy standards
- Code style guide, naming conventions
- Integration patterns (how modules connect)
- Reviews architecture decisions

### Overlap Analysis: **~80% overlap.**

Solo already owns architecture decisions, integration patterns, and code review. The skill assessment (Session 9) rates Solo as "Proficient" with strongest skill being "Strategic analysis and workload distribution." The architectural work Solo did — gameplay.js decomposition, CONFIG extraction, camera/wave-manager/background extraction — is exactly what a Chief Architect would do.

### What's Genuinely New
The ~20% that doesn't cleanly fit Solo today:
1. **Godot-specific scene tree design** — This is domain knowledge Solo doesn't have yet. But it's a *learning gap*, not a *role gap*. Solo will learn Godot's scene/node model the same way Solo learned Canvas 2D architecture.
2. **Code style guide / naming conventions** — This was identified as a gap: the `project-conventions` skill is an empty template (Low confidence, zero content). But writing a style guide is a one-time task, not a full-time role.
3. **Formal architecture reviews** — Solo does this informally. A Godot project with 12 agents would benefit from explicit review gates. But this is a *process improvement* for Solo's charter, not a new person.

### Verdict: **Do NOT create Chief Architect. Expand Solo's charter.**

**Rationale:** Splitting architectural authority creates a coordination problem worse than any it solves. Who has final say — Solo or Chief Architect? If Chief Architect overrides Solo on architecture, Solo becomes a project manager without teeth. If Solo overrides Chief Architect, the role is advisory and agents will learn to route around it. One voice on architecture is better than two voices that might disagree.

**What to do instead:**
- Add to Solo's charter: "Owns Godot scene tree conventions, node hierarchy standards, and code style guide"
- Solo's first Godot task: produce the architecture document (repo structure, scene tree patterns, naming conventions, signal conventions) *before* any agent writes code
- Fill the `project-conventions` skill with Godot-specific content (currently an empty template — this is the right vehicle)
- Add explicit architecture review gates to the squad workflow (Solo reviews scene tree structure on first PR from each agent)

---

## 2. Does Chewie Already Cover Tool Engineer?

### Current Chewie Charter
Chewie's charter states:
- "Game loop with fixed timestep at 60 FPS"
- "Canvas renderer with camera support"
- "Keyboard input handling system"
- "Web Audio API for sound effects"
- "Core engine architecture"
- "Owns: src/engine/ directory"

### What Tool Engineer Would Own
- Project structure in Godot (scene templates, base classes)
- Editor tools/plugins for the team
- Pipeline automation (asset import, build scripts)
- Scaffolding that prevents architectural mistakes
- Facilitating other agents' work

### Overlap Analysis: **~40% overlap.**

Chewie is an **engine developer** — builds runtime systems that the game uses at play-time. Tool Engineer builds **development-time** systems that *agents* use while working. These are fundamentally different audiences and different execution contexts.

| Dimension | Chewie (Engine Dev) | Tool Engineer |
|-----------|-------------------|---------------|
| **Audience** | The game (runtime) | The developers (dev-time) |
| **Output** | Game systems (physics, rendering, audio) | Templates, plugins, scripts, pipelines |
| **When it runs** | During gameplay | During development |
| **Godot equivalent** | Writing custom nodes, shaders, game systems | Writing EditorPlugins, export presets, GDScript templates |
| **Success metric** | Game runs well | Agents are productive and consistent |

### What Chewie Already Does That's Tool-Adjacent
- Chewie did create reusable infrastructure: SpriteCache, AnimationController, EventBus (though none were wired — Session 8 finding)
- Chewie's integration passes (FIP, AAA) were essentially tooling work — connecting systems together
- Chewie wrote the `web-game-engine` skill document — documentation that helps other agents

### What's Genuinely New in Godot
Godot creates significantly more tooling surface area than vanilla JS:
1. **EditorPlugin API** — Godot has a full plugin system for extending the editor. Custom inspectors, dock panels, import plugins, gizmos. This is a distinct skillset from game engine coding.
2. **Scene templates / inherited scenes** — Godot's scene inheritance model means base scenes need careful design. A bad base scene propagates mistakes to every child. This is architectural scaffolding work.
3. **Asset import pipelines** — Godot's import system (reimport settings, resource presets, `.import` files) needs configuration. Sprite atlases, audio bus presets, input map exports.
4. **GDScript code generation** — Template scripts for common patterns (state machines, enemy base class, UI panel base) that agents instantiate rather than write from scratch.
5. **Build/export automation** — Export presets, CI/CD for Godot builds, platform-specific settings.
6. **Project.godot management** — Autoload singletons, input map, layer names, physics settings. One wrong edit breaks everyone.

### Verdict: **YES, create Tool Engineer. This is a distinct role.**

**Rationale:** The overlap with Chewie is only ~40%, and critically, it's the wrong 40%. Chewie's strength is runtime systems — the skill assessment rates Chewie as "Expert" in "System integration and engine architecture." Tool Engineer is about *development-time* productivity. Asking Chewie to also write EditorPlugins, manage import pipelines, and create scaffolding templates would split Chewie's focus between two fundamentally different jobs: making the game work vs. making the team work.

**The lesson from SimpsonsKong proves this:** The #1 technical debt finding (Session 8) was "214 LOC of unused infrastructure — working systems that aren't wired into anything." The multi-agent-coordination skill (Session 10) identified the core pattern: "agents build infrastructure but don't wire it." A Tool Engineer's explicit job would be closing this gap — building the scaffolding, templates, and automation that ensure new code arrives pre-wired.

---

## 3. Godot-Specific Needs Assessment

### Does Godot's Architecture Justify a Dedicated Tooling Role?

**Yes, and here's why it's MORE needed than in vanilla JS:**

In our Canvas/JS project, there was no editor, no import system, no scene tree, no project file, no plugin API. The "tooling" was just file organization and conventions. Godot introduces 5 entire systems that need tooling attention:

| Godot System | Tooling Work Required | Comparable JS Work |
|-------------|----------------------|-------------------|
| Scene tree + inheritance | Base scene design, node hierarchy templates, inherited scene conventions | None (we had flat file imports) |
| EditorPlugin API | Custom inspector panels, validation tools, asset preview widgets | None (no editor) |
| Resource system | .tres/.res management, resource presets, custom resource types | None (all inline) |
| Signal system | Signal naming conventions, connection patterns, signal bus architecture | We built EventBus (49 LOC) but never used it |
| Export/build system | Export presets, CI/CD, platform configs, feature flags | None (no build step) |

**Conservative estimate:** 15-25 tooling items in the first Godot project, ongoing maintenance as game scope grows. That's a full role's worth of work, comparable to Tarkin's content workload (18 items in SimpsonsKong).

### Godot's Scene-Signal Architecture Creates Unique Coordination Challenges

In vanilla JS, a bad import path fails loudly at runtime. In Godot, a bad signal connection or incorrect node path fails *silently* — the signal just doesn't fire, the node reference returns null. Tool Engineer can build editor validation plugins that catch these at edit-time, before agents commit broken connections.

---

## 4. Team Size: 12/12 → 13 (Overflow Handling)

### Current Roster (12 OT Characters)
Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien

### Adding 1 New Role → 13 Characters
Since we're only recommending Tool Engineer (not Chief Architect), we need 1 new character, not 2.

### Options for the 13th Character

**Option A: Prequel character**
Use a prequel-era character: Qui-Gon, Mace, Padmé, Jango, Maul, Dooku, Grievous, Rex, Ahsoka, etc.

**Option B: Extended OT universe**
Characters from OT-adjacent media: Thrawn, Mara Jade, Kyle Katarn, Dash Rendar, etc.

**Option C: Rogue One / Solo film characters**
K-2SO, Chirrut, Jyn, Cassian, Qi'ra, Beckett, L3-37, etc.

### Recommendation: **Prequel is fine. Go with it.**

The Star Wars naming convention is a fun team identity feature, not a hard constraint. One prequel character doesn't break the theme. The convention already bent with Scribe and Ralph (non-Star Wars support roles).

**Suggested name: K-2SO** — the reprogrammed droid from Rogue One. Fitting for a Tool Engineer: originally built for one purpose, reprogrammed to serve the team. Technically OT-era (Rogue One is set immediately before A New Hope). Alternatively, **Lobot** — Lando's cyborg aide from Cloud City, literally an augmented assistant, pure OT.

---

## 5. Alternative: Absorb Into Existing Roles?

### Chief Architect → Absorbed into Solo ✅

This is straightforward. Solo's charter already covers 80% of this. The remaining 20% (Godot conventions, style guide, formal review gates) is a charter expansion, not a new person. Solo should:
1. Write the Godot architecture document as Sprint 0 deliverable
2. Fill the `project-conventions` skill with Godot-specific content
3. Add architecture review gates to the workflow

### Tool Engineer → NOT absorbable ❌

We evaluated 3 absorption candidates:

**Chewie?** No. Chewie is a runtime systems expert. EditorPlugins, import pipelines, and scaffolding templates are development-time concerns. Splitting Chewie's focus would degrade both game engine quality AND tooling quality. The skill assessment rates Chewie as the team's only Expert-level engineer — don't dilute that.

**Solo?** No. Solo is already the planning/coordination bottleneck. Adding hands-on tooling work would mean either slower planning cycles or rushed tools. Solo's weakness is already "follow-through on integration" (CONFIG.js never wired in). Adding more implementation to Solo's plate makes this worse.

**Yoda (Game Designer)?** No. Yoda defines *what* the game should be, not *how* the development environment works. Completely different domain.

**Distribute across all agents?** No. This is exactly the pattern that produced 214 LOC of unused infrastructure in SimpsonsKong. When everyone is responsible for tooling, nobody is responsible for tooling. The multi-agent-coordination skill explicitly warns against this.

---

## Summary of Recommendations

| Proposed Role | Verdict | Action |
|--------------|---------|--------|
| **Chief Architect** | ❌ **Do NOT create** | Expand Solo's charter with Godot architecture responsibilities. Fill `project-conventions` skill. Add review gates. |
| **Tool Engineer** | ✅ **CREATE** | New role with distinct charter. Owns EditorPlugins, scene templates, import pipelines, scaffolding, build automation. Suggested name: Lobot or K-2SO. |

### Charter Draft for Tool Engineer

```
## Role
Tool Engineer for [Godot Project].

## Responsibilities
- Godot project structure setup and maintenance (project.godot, autoloads, layers)
- Scene templates and inherited scenes for common patterns
- Base class scripts (state machine, enemy base, UI panel base)
- EditorPlugin development (custom inspectors, validation tools, asset previews)
- Asset import pipeline configuration (sprite atlases, audio presets, resource types)
- Build/export automation and CI/CD pipeline
- Scaffolding tools that enforce architectural conventions
- Integration validation — ensuring agent work connects correctly

## Boundaries
- Owns: addons/ directory, project.godot configuration, export presets
- Creates templates that other agents instantiate
- Does NOT implement game logic, art, or audio — builds tools for those who do
- Coordinates with Solo on architectural standards (Solo defines WHAT, Tool Engineer builds HOW to enforce it)

## Model
Preferred: auto
```

### Net Team Impact

| Metric | Before | After |
|--------|--------|-------|
| Team size | 12 + 2 support | 13 + 2 support |
| Architectural authority | Solo (implicit) | Solo (explicit, expanded charter) |
| Tooling ownership | Nobody (distributed, often dropped) | Tool Engineer (dedicated) |
| Star Wars theme integrity | Pure OT | OT + 1 Rogue One/OT-adjacent character |
| Risk of unwired infrastructure | High (proven pattern) | Low (Tool Engineer's explicit job) |

---

*Solo — Lead*

