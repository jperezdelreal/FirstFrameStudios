# Studio Growth Framework

> **Author:** Yoda (Game Designer)
> **Date:** 2025
> **Status:** Active — This document explains how First Frame Studios evolves without breaking.

---

## Introduction: The Antifragility Question

As First Frame Studios grows — from one shipped game to many, from one genre to many, from a 12-person squad to potentially a studio that spans continents — a fundamental risk emerges: **At what point does growth become restructuring? At what point do we hit a bottleneck that demands we rebuild our foundations?**

The answer is: Never, if we're intentional.

This document codifies the meta-model of the studio — the architecture that *absorbs* growth instead of breaking under it. It explains the permanent 70% of what makes us effective, the adaptive 30%, how skills compound across projects, how teams elastically scale, and what could derail us if we're not careful.

This is not a process document. This is not a project plan. This is a *constitution* — the shape that First Frame Studios holds even as projects, teams, and genres change.

---

## 1. The 70/30 Rule: Permanent and Adaptive

### The Permanent 70%

These foundations don't change per genre, per platform, or per project. They are the studio's skeleton. They are independent of technology, IP, dimension, or scope.

#### 1.1 Leadership Principles (principles.md)

Our 12 principles are not constraints on a specific game. They are decision-making algorithms that work in *any* context:

- **Player Hands First** — applies to a browser beat 'em up, a VR puzzle game, or a text adventure
- **Research Before Reinvention** — applies whether researching beat 'em ups, platformers, or roguelikes
- **Ship the Playable** — works the same whether the target platform is Canvas 2D, Godot 4, or Unreal 5
- **Domain Owners, Not Silos** — governs team structure whether the team is 12 people or 120
- **Bugs Are a Broken Promise** — universal severity framework regardless of platform or genre
- **Every Project Teaches the Next** — the compounding mechanism that makes each new project faster than the last

When a new specialist joins the studio, they read these principles before touching code. When a new genre project kicks off, these principles solve the first design conflict. When teams scale, these principles don't change — they just govern more people.

#### 1.2 Quality Gates and Definition of Done (quality-gates.md)

What separates a shipped game from a beta is not the technology. It's:

- **Playable:** A new player can pick it up and understand the core loop within 2 minutes
- **Responsive:** Input latency is below the 100ms human perception threshold
- **Stable:** No game-breaking bugs; no softlocks, crashes, or player freezes
- **Intentional:** Every tuned parameter has a target range and a reason
- **Polished:** Game feel is implemented: feedback loops, audio variation, visual feedback on consequence
- **Tested:** Structured playtesting with measurable hypotheses, not just vibes

These gates are expressed as *outcomes*, not as tool-specific checks. "Input latency below 100ms" works whether we measure it with profilers, framerunning, or playtest data. "No game-breaking bugs" works whether we test with manual QA or automated regression suites.

#### 1.3 Team Coordination Methodology

The squad system is permanent:

- **Domain ownership:** Each specialist owns one domain completely. No one carries two. No domain floats.
- **Cross-domain collaboration:** Every domain owner attends other domains' reviews and feedback cycles.
- **Drop-box pattern:** Producers and QA are the integration points. Creative vision flows down. Playable builds flow up.
- **Asynchronous by default:** Documents (GDDs, skills, decisions, post-mortems) are the primary communication medium. Synchronous meetings are rare and structured.
- **Ceremony rhythm:** Weekly standups (15 min), bi-weekly retrospectives (1h), monthly strategy reviews (1h), quarterly planning (2h). Nothing changes per project.

This structure works whether we have one 12-person squad or three parallel squads. The charter of each role (Lead, Gameplay Dev, Sound, QA) doesn't change. What they read and build *in that role* changes per project.

#### 1.4 Design Methodology

The process is permanent:

1. **Research Sprint** — Study 5–10 reference games in the genre. Document patterns, innovations, and failures.
2. **GDD** — Write the game design document informed by research, not guesswork.
3. **Backlog generation** — Break the GDD into buildable work items. Assign complexity, risk, and dependencies.
4. **Vertical slice** — Build the smallest version that proves the core loop works. Target: playable in 30 days.
5. **Iterative build** — Ship playable builds every 2 weeks. Let playtesting drive the backlog.
6. **Retrospective & skills capture** — Document what worked, what failed, what we'd do differently. Capture patterns as permanent skills.

This process works for a beat 'em up, a platformer, or a 3D action game. The research targets change. The GDD section headings adapt. The backlog items scale. The core rhythm stays constant.

#### 1.5 Company Identity & Values

Our core DNA — encoded in mission-vision.md and company.md — is permanent:

- **The first frame is a promise** — universal, applies to any game
- **Constraints forge better games** — universal, applies to any tech stack and any limitation
- **Research is the shortcut** — universal, applies to any genre
- **Ship the playable then listen** — universal, applies to any platform
- **Every lesson compounds** — the meta-principle that governs institutional memory

These are not Simpsons-specific. They are not Canvas-2D-specific. They are studio truths.

---

### The Adaptive 30%

These change per project. They are the specializations that sit *on top* of the permanent 70%. We expect them to be different for every game and every genre we make.

#### 2.1 Engine-Specific Skills

**What's permanent:** The concept of an "Engine Skill" (a documented pattern of implementation in a specific engine).

**What's adaptive:** Which engine we're using and what patterns matter for that engine.

- SimpsonsKong used Canvas 2D. Skill: `godot-beat-em-up-patterns/SKILL.md` is our engine-specific knowledge for *the next* Canvas project (or conversion).
- Next project might use Godot 4. Skill: `godot-4-manual/SKILL.md` captures Godot-specific patterns.
- Future projects might use Unity, Unreal, or a custom engine. Each gets its own engine skill.

These skills are *not* the studio's identity. They are tools the studio wields. When we change tools, we don't change who we are — we change what we're using.

#### 2.2 Genre-Specific Skills

**What's permanent:** The concept of a "Genre Vertical" (a permanent body of research, patterns, and skills specific to a genre).

**What's adaptive:** Which genres we're pursuing and what patterns dominate in each.

- **Beat 'Em Up Vertical (current):** skills for combat design, enemy AI, 2.5D movement, pacing, character expression, audio feedback.
- **Platformer Vertical (future):** skills for movement physics, level design, precision tuning, momentum, coyote time.
- **Fighting Game Vertical (future):** skills for frame-perfect input, netcode, character balance, hitbox design, competitive metagame.

Each vertical is permanent once created. Adding a new vertical doesn't invalidate the old one — it compounds. A platformer vertical learns from beat 'em up patterns and adds new dimensions.

#### 2.3 Code Patterns & Architecture

**What's permanent:** The principle of intentional, documented architecture decisions.

**What's adaptive:** Which architecture patterns are best for a given engine/platform/scope.

- SimpsonsKong used a modular ES6 architecture with Canvas 2D rendering, a fixed timestep game loop, and Canvas-based procedural art. Those patterns are documented in `godot-beat-em-up-patterns/SKILL.md`.
- If the next game uses Godot 4, the architecture might use a node tree with scenes, autoloads for managers, and @export variables for balancing.
- If a future game is multiplayer, the architecture might add netcode (rollback, client-side prediction) and state synchronization.

The lesson isn't "use this specific architecture." It's "document your architecture decisions, explain why you made them, capture the trade-offs, and make the decision reversible."

#### 2.4 Art Pipeline

**What's permanent:** The principle that art pipelines are intentional, documented, and efficient.

**What's adaptive:** Whether that pipeline uses 2D sprites, 3D models, vector art, procedural generation, or pixel art.

- SimpsonsKong used procedural Canvas 2D art. Trade-off: fast iteration, low file size, high code cost (~400 LOC per character).
- Next project might use pre-drawn sprites with animation frames. Trade-off: slower visual iteration, larger file size, low code cost, higher visual fidelity.
- Future project might use 3D models. Trade-off: new skillset, different asset pipeline, different rendering performance profile.

When the art pipeline changes, the specialist who owns it (currently Nien and Leia, with Boba directing) learns the new pipeline. The rest of the studio trusts them to deliver within the quality gates. The domain ownership structure doesn't change — the implementation does.

---

## 2. Skill Architecture: How Knowledge Grows

Skills are how the studio compounds. They are the opposite of institutional knowledge that lives in a person's head. They are written, versioned, searchable, and transferable.

### 2.1 Universal Skills

These apply to *every* game, every genre, every platform. Once learned, they are permanent studio assets.

**Examples:**
- `state-machine-patterns/SKILL.md` — How to design and code state machines that don't deadlock, are testable, and are easy to reason about. Applies to entity AI, UI flow, game state, anything with discrete states.
- `game-feel-juice/SKILL.md` — The systems that produce the sensation of impact: screen shake, hitlag, knockback, audio feedback, visual effects timing.
- `multi-agent-coordination/SKILL.md` — How to coordinate between independent systems without direct references (EventBus, signals, message systems).
- `game-qa-testing/SKILL.md` — Hypothesis-driven testing methodology, regression checklists, balance analysis frameworks.
- `project-conventions/SKILL.md` — Naming patterns, file organization, comment standards, asset naming — the consistent grammar that makes codebases readable even after six months away.

These skills are learned once and referenced forever. When a new specialist joins, they read the relevant universal skills. When a new project starts, old projects' skills are available as templates.

### 2.2 Genre Verticals

Each genre becomes a vertical — a collection of interconnected skills specific to that genre.

#### Beat 'Em Up Vertical (Current)

**Permanent skills in this vertical:**
- `beat-em-up-combat/SKILL.md` — Frame data, hitstun, combos, knockback, health-cost specials, crowd control. The core loop of the genre.
- `beat-em-up-enemy-ai/SKILL.md` — Enemy state machines, attack patterns, wave composition, spawn systems, difficulty scaling.
- `beat-em-up-pacing/SKILL.md` — How to structure a level: peaks and valleys, enemy variety, environmental hazards, camera locks. The rhythm that keeps players engaged.
- `beat-em-up-character-design/SKILL.md` — Silhouette theory, archetype differentiation, how to make a character feel unique within 10 seconds.
- `beat-em-up-research/SKILL.md` — The genre analysis: Streets of Rage, TMNT: Shredder's Revenge, Castle Crashers, Scott Pilgrim, Final Fight, River City Girls, Dragon's Crown — what each game did well, what it missed, how the genre evolved.

**Cross-pollination with future verticals:**
- A platformer's movement physics will learn from beat 'em up's frame data discipline (buffering windows, ground checks, state transitions).
- A fighting game's balance framework will learn from beat 'em up's health-cost special design (risk/reward loops).
- An action RPG's enemy composition system will learn from beat 'em up's wave design (pacing, difficulty curves, variety spacing).

#### Platformer Vertical (Future)

When we build our first platformer, these skills will be created:
- `platformer-movement-physics/SKILL.md` — Velocity curves, coyote time, jump buffering, momentum preservation, wall sliding, dashes.
- `platformer-level-design/SKILL.md` — Level grammar, teach-by-doing tutorials, camera locks, spike placement, difficulty ramps.
- `platformer-precision-tuning/SKILL.md` — Hitbox fairness, collision detection edge cases, animation-to-hitbox synchronization.
- `platformer-progression/SKILL.md` — Vertical progression (abilities that open new areas), skill progression (better jumping), collectible systems.
- `platformer-research/SKILL.md` — Celeste, Hollow Knight, Ori, Mega Man, Super Meat Boy — reference analysis specific to movement-focused games.

#### Fighting Game Vertical (Future)

When we build our first fighting game:
- `fighting-game-netcode/SKILL.md` — Rollback netcode architecture, client-side prediction, deterministic simulation, input buffering for online play.
- `fighting-game-balance/SKILL.md` — Frame data, wake-up pressure, throw escapes, meter systems, character archetype balance.
- `fighting-game-ui/SKILL.md` — Training mode design, frame display, hitbox visualization, combo trials, replay system.
- `fighting-game-research/SKILL.md` — Street Fighter 6, Tekken 8, Guilty Gear Strive, Under Night In-Birth — how modern fighting games teach, balance, and compete.

### 2.3 Tech Stack Skills

For each platform/engine the studio uses, skills are created.

**Examples:**
- `canvas-2d-patterns/SKILL.md` — Procedural art, animation frame timing, Canvas limitations and workarounds, web audio integration.
- `godot-4-manual/SKILL.md` (in progress) — GDScript, scene trees, node hierarchy, autoloads, signals, custom nodes, performance profiling in Godot.
- `web-game-engine/SKILL.md` (future) — When considering a web framework (Phaser 3, Excalibur, Babylon.js).
- `unity-patterns/SKILL.md` (future) — When moving to Unity for a 3D project.
- `unreal-blueprints/SKILL.md` (future) — When moving to Unreal for AAA-scale projects.

These skills are *descriptive*, not prescriptive. They document "here's how we've successfully used this engine" — not "you must always use this approach." They become reference material for specialists new to the engine.

### 2.4 Naming Convention

Skills are named to communicate their scope:

- **Universal:** `{topic}/SKILL.md` — `state-machine-patterns/SKILL.md`, `game-feel-juice/SKILL.md`
- **Genre-specific:** `{genre}-{topic}/SKILL.md` — `beat-em-up-combat/SKILL.md`, `platformer-level-design/SKILL.md`
- **Engine-specific:** `{engine}-{topic}/SKILL.md` — `godot-4-manual/SKILL.md`, `canvas-2d-patterns/SKILL.md`

This naming makes browsing intuitive: `ls skills/` shows universal skills at the top, then genre verticals, then engine patterns.

### 2.5 Skill Maturity Levels

Skills have a maturity model:

- **Level 1: Documented** — "Here's how we did this once. It worked. Here are patterns and code examples."
- **Level 2: Validated** — "We've done this twice in different projects. The pattern holds."
- **Level 3: Mature** — "We've done this 3+ times. It's the studio standard. New projects reference this."
- **Level 4: Evolved** — "A specialist has innovated on the base pattern. This is our evolved best practice."

Skills start at Level 1 after a project ships. They level up as we validate them across projects. When a skill reaches Level 4, it's owned by a domain specialist who maintains it as the studio standard.

---

## 3. Team Elasticity: Roles That Scale

The squad structure is permanent. The workload per specialist changes. The specialized roles emerge as needed.

### 3.1 Core Roles (Every Project)

These roles exist for *every* game:

| Role | Responsibility | Domain Constant |
|------|---------------|----|
| **Game Designer (Yoda)** | GDD authorship, vision, mechanics, balance philosophy | Vision & intent, not implementation |
| **Lead (Solo)** | Architecture, team coordination, tech strategy, final calls | Decides on technical approach |
| **Engine Dev (Chewie)** | Core engine systems, rendering, physics, performance | Platform abstraction, performance |
| **Gameplay Dev (Lando)** | Combat/mechanics, player feel, input handling | Game feel implementation |
| **Art (Boba, Nien, Leia, Bossk)** | Visual identity, characters, environments, effects | Aesthetic vision & execution |
| **Sound (Greedo)** | Audio feedback, music, sound design systems | Audio as core system |
| **QA (Ackbar)** | Testing, balance analysis, playtest methodology | Player experience quality gate |

### 3.2 Roles That Scale with Project Scope

Some roles emerge when the scope demands them:

| Scope Signal | Role | Responsibility |
|------|------|-----------------|
| **Multiple characters (5+)** | Dedicated Character Animator | Owns animation rigging, frame timing, character expression |
| **Large level count (10+)** | Level Designer | Owns level layout, pacing, environmental storytelling |
| **Dialogue/narrative content** | Narrative Designer | Owns story beats, character voice, dialogue trees |
| **Procedural content** | Content Generator Dev | Owns procedural systems (loot tables, level gen, enemy variation) |
| **User-facing tools** | Tool Engineer | Owns editor plugins, asset pipelines, visualization tools |

When the scope no longer demands a role, that role consolidates back to an existing domain owner. A solo studio project might have 12 people. A massive AAA project might have 12 people *per department*.

### 3.3 Roles That Emerge with New Genres

Some roles become necessary when entering a new genre:

| Genre Requirement | Role | When Added |
|------|------|------------|
| **Platformer:** Precision-critical movement | Movement Specialist | When starting first platformer (validates coyote time, buffering windows, etc.) |
| **Fighting Game:** Online competition | Netcode Engineer | When starting first fighting game (designs rollback, handles determinism) |
| **Action RPG:** Progression systems | Systems Designer | When starting first RPG (balances economy, skill trees, loot) |
| **3D Action:** Camera & spatial control | 3D Specialist | When starting first 3D game (camera orbiting, depth perception, lock-on) |
| **Multiplayer:** Real-time coordination | Network Engineer | When adding multiplayer (server architecture, player sync, anti-cheat) |

### 3.4 Decision Framework: Role or Skill?

When a new capability is needed, ask:

1. **Is this capability genre-agnostic?** (e.g., "better procedural audio generation")
   - **→ Add a skill.** Update the `audio-design/SKILL.md` with the new technique. Greedo learns and applies it.

2. **Is this capability genre-specific and deep enough for a dedicated owner?**
   - Example: "Fighting game netcode is complex and touches 20% of the codebase."
   - **→ Add a role.** A Network Engineer joins for the fighting game project. They own netcode end-to-end.

3. **Is the skill gap in an existing domain owner >2 levels AND the workload justifies it?**
   - Example: "Lando is carrying 50 items. A new Gameplay Dev would own character abilities while Lando owns core loop mechanics."
   - **→ Add a role.** Split the domain, not the person. When the workload shrinks, roles consolidate.

The principle: **Roles scale up and down based on scope. Domains stay constant. Knowledge is always documented.**

---

## 4. Genre Onboarding Protocol

This is the playbook for entering a new genre without losing momentum.

### 4.1 First Time: New Genre (Complete Protocol)

#### Phase 1: Research Sprint (2 weeks)

**Goal:** Understand the genre's design space, proven patterns, and frontiers.

**Deliverables:**
- Play 5–10 landmark titles in the genre. Track playtime per title (~5 hours each).
- Document for each title: core loop, character archetypes, difficulty curves, progression systems, what the game did *well* and what it missed.
- Create a comparison matrix: Which games did X system best? Where is there innovation vs. copy?
- Identify 3–5 "solved problems" the genre has already answered (e.g., beat 'em up solved health-cost specials, combo breadcrumb trails).
- Identify 2–3 "unsolved problems" or gaps (e.g., beat 'em up has never perfectly balanced 2-player vs. 4-player cooperative difficulty).
- Write a genre research document at `.squad/analysis/{genre}-research.md`.

**Owner:** Game Designer (Yoda), with input from any specialist who's played a reference game.

**Why this timing:** 2 weeks is enough to build intuition without going deep. A month would be over-researching. 10 days would miss nuance.

#### Phase 2: Genre GDD Template (1 week)

**Goal:** Adapt the GDD framework to the genre's specific concerns.

**Deliverables:**
- Take the GDD template from `.squad/templates/GDD-base.md` (will be created if missing).
- Add genre-specific sections. Examples:
  - Beat 'Em Up GDD includes: "Combat System Design," "Enemy Wave Composition," "2.5D Movement Tuning"
  - Platformer GDD includes: "Movement Physics Specification," "Level Design Grammar," "Precision Tuning Targets"
  - Fighting Game GDD includes: "Character Frame Data," "Netcode Architecture," "Competitive Balance Framework"
- Define which metrics matter for this genre (e.g., beat 'em up measures PPK DPS; platformer measures coyote window in frames; fighting game measures rollback latency in frames).
- Draft the GDD with placeholder content to show structure.

**Owner:** Game Designer (Yoda) + Lead (Solo) for technical sections.

#### Phase 3: Minimum Playable Definition (1 week)

**Goal:** Define the smallest thing that proves the genre works in our hands.

**Deliverables:**
- Specify what "playable" means for this genre. Examples:
  - **Beat 'Em Up:** One character can punch one enemy, the enemy reacts, the character can take damage and recover.
  - **Platformer:** A character can move left/right, jump, land on platforms, fall if they miss, respawn without crashing.
  - **Fighting Game:** Two characters can perform basic attacks, blocking is possible, one character can reduce the other's health to zero.
- Identify the critical path: What's the one feature that, if it doesn't feel *right*, invalidates the entire game?
- Set a timeline: "Playable version ships in 30 days with only the minimum features."
- Identify technical risks: What unknown unknown could derail the 30-day timeline? Test that first.

**Owner:** Lead (Solo) + Game Designer (Yoda).

#### Phase 4: Skill Creation from Research (2 weeks, parallel with Phase 3)

**Goal:** Capture the genre's solved problems as skills the team can reference.

**Deliverables:**
- For each "solved problem" identified in research, create a skill at `.squad/skills/{genre}-{topic}/SKILL.md`.
- Include: What's the problem? How have 3–5 reference games solved it? What are the trade-offs? What's our philosophy for this problem? Code examples (if applicable).
- Examples:
  - `beat-em-up-combat/SKILL.md` — Specifies health-cost specials, PPK foundation, damage balancing.
  - `platformer-movement-physics/SKILL.md` — Specifies coyote windows, jump buffering, momentum curves.
  - `fighting-game-balance/SKILL.md` — Specifies frame advantage, wake-up pressure, character archetypes.

**Owner:** Game Designer (Yoda) + relevant specialists (e.g., Lando for gameplay skills, Greedo for audio skills).

#### Phase 5: Team Assessment (1 week)

**Goal:** Map current team skills to genre needs, identify gaps.

**Deliverables:**
- Create a table:
  | Skill | Needed? | Owned by | Confidence | Risk |
  |-------|---------|----------|------------|------|
  | `platformer-movement-physics` | Yes | Lando | Level 1 (new) | HIGH — no platformer experience |
  | `procedural-art` | Yes | Nien | Level 3 (beat 'em up transfer) | LOW — we did this in Canvas |
  | `netcode` | No (single-player) | N/A | N/A | N/A |
- Identify Level 1 gaps (skills we're learning for the first time).
- Decide: Do we hire someone with that skill, or does an existing specialist learn it?
- For each Level 1 skill, assign a "Skill Mentor" from a reference studio or external expert (if hiring isn't possible).

**Owner:** Lead (Solo) + Game Designer (Yoda).

#### Phase 6: Architecture Spike (3 weeks)

**Goal:** Build a throwaway prototype to validate tech choices before committing architecture.

**Deliverables:**
- Spike code (will be deleted) that explores the genre's technical challenges.
- Examples:
  - **Platformer spike:** Test coyote window behavior, collision detection edge cases, animation-to-hitbox sync at different frame rates.
  - **Fighting Game spike:** Implement rollback netcode with 2–3 characters, test determinism, measure latency.
  - **3D Action spike:** Implement camera orbiting, lock-on system, depth-based rendering.
- Document the spike findings: What worked? What needs a different approach? Is the planned tech stack viable?
- **Critical decision:** Does the spike tell us to commit to the current tech stack, or switch? This is the last point where switching is cheap.

**Owner:** Lead (Solo) + Engine Dev (Chewie).

**Timeline:** These six phases take ~8 weeks total before production builds start. This is the "slow planning fast execution" approach: spend time up front understanding the genre, then execute with confidence.

### 4.2 Return to Genre: Known Genre (Accelerated Protocol)

When starting a *second* project in a genre we've already done:

1. **Read existing genre skills** (~2 hours)
   - Open `.squad/skills/{genre}-*/SKILL.md`
   - Check: Did the patterns from the first project hold? Are there new techniques we've learned?

2. **Genre research update** (~1 week)
   - New games have launched since the first project. Check if reference games have evolved.
   - Example: If we did a beat 'em up in 2025 and now it's 2027, check if a new Streets of Rage or River City Girls shipped and what it does differently.

3. **Skill confidence bump** (~1 week)
   - For skills we validated in the first project, bump them from Level 1 → Level 2 or Level 2 → Level 3.
   - Example: `beat-em-up-combat` goes from "Documented (Level 1)" to "Validated (Level 2)" after a second shipped game.

4. **GDD template refinement** (~3 days)
   - Take the GDD template from the first project.
   - Update it with lessons learned (e.g., "Section 4 was underspecified; expand it for the next game").

5. **Start Sprint 0 with institutional advantage**
   - The team now *knows* this genre.
   - Minimum playable definition is faster (we know what "playable" means).
   - Technical risks are known (we hit them last time).
   - Spike phase is 1 week instead of 3 (we're validating novelty, not proving genre viability).

**Timeline:** Returning to a known genre compresses the research/planning phase from 8 weeks to **4 weeks**. Same quality. Double speed. That's the compound effect of documentation.

---

## 5. Technology Independence Guarantee

First Frame Studios is *not* locked into any technology. This is intentional. Here's how we maintain that freedom.

### 5.1 What Must Be Engine-Agnostic

These artifacts are sacred — they never mention specific engines, languages, or tools.

| Artifact | Why Agnostic | How We Enforce It |
|----------|-------------|-------------------|
| **GDD (game-design-document.md)** | It describes WHAT players experience, not HOW engineers build it | Always written in Markdown. Never references engine features. Never says "use Godot's RigidBody2D." Always says "the character has knockback that decays over 0.5 seconds." |
| **Quality Gates (quality-gates.md)** | They describe outcomes, not tool-specific checks | Gates are player-centric: "input latency < 100ms", "no game-breaking bugs," "combos are readable." Not "use this profiler" or "run this test suite." |
| **Team Charters** | Roles are defined by WHAT they do, not HOW (tools they use) | Lando is "Gameplay Engineer" not "Godot Gameplay Programmer." The charter says "translates design intent into code the player's hands feel" — works in any language. |
| **Leadership Principles (principles.md)** | They describe player experience philosophy, not implementation | "Player Hands First" is about *feel*, not about specific frame rates or technologies. It applies to Canvas 2D, Godot, Unreal, or a Game Boy. |
| **Skill descriptions (in SKILL.md files)** | The *principle* of a skill is universal; only the implementation is engine-specific | `game-feel-juice/SKILL.md` describes the *concept* of feedback loops (screen shake, hitlag, knockback, audio variation). The *implementation* of screen shake changes per engine. |

### 5.2 What CAN Be Engine-Specific (and That's OK)

These are lower-down in the abstraction stack. It's fine if they're locked to a specific engine — they're labeled clearly.

| Artifact | Why Specific | Example |
|----------|------------|---------|
| **Engine Skills** | An engine skill documents HOW to do something in a specific engine. That's literally its purpose. | `godot-4-manual/SKILL.md` is 100% Godot 4. That's correct. If we switch to Unity, we write `unity-patterns/SKILL.md`. |
| **Architecture Docs** | Specific to the tech stack, but written to make patterns portable | "Our game uses an EventBus architecture to decouple systems." Works in any engine. The implementation changes (Godot signals vs. custom event system vs. C# events), but the *pattern* transfers. |
| **Build Pipelines** | Necessarily engine/platform specific | Canvas 2D build pipeline (webpack bundle → single HTML file) vs. Godot 4 build pipeline (export.tres → platform-specific binary). Different tools, same intent: "ship a playable build to the target platform." |
| **Refactoring docs** | Can reference current tooling | "We refactored `gameplay.js` (695 LOC) into modules" is fine to document. It's historically accurate. |

### 5.3 How We Prevent Lock-In

The principle: **If we ever want to change platforms, nothing dies except the engine-specific code.**

To verify this, ask: "What would we need to rewrite if we switched to [new engine]?"

**Example: Switching from Canvas 2D to Godot 4**

- **Would rewrite:** `godot-beat-em-up-patterns/SKILL.md` becomes `canvas-2d-patterns/SKILL.md` in history, and we write new `godot-4-beat-em-up-patterns/SKILL.md`. OK — that's expected.
- **Would NOT rewrite:** The GDD. The combat design document says "characters do 25 DPS with a 10-frame hitstun window" — this is true regardless of engine.
- **Would NOT rewrite:** Quality gates. "Input latency < 100ms" applies in Canvas 2D, Godot 4, or Unreal 5.
- **Would NOT rewrite:** Team structure. Lando is still the Gameplay Engineer. Their charter doesn't change — their tools do.
- **Would NOT rewrite:** Skill descriptions of universal patterns. `state-machine-patterns/SKILL.md` is about *concepts*, not specific code syntax.

This is the "reverse platform migration test" — if something would die in a platform migration, it's probably engine-specific and fine. If something *shouldn't* die in a platform migration, it must be documented as platform-agnostic.

---

## 6. Growth Milestones: When Is the Studio "Mature"?

Maturity is defined by stage, not by size or revenue. At each stage, the studio has proven it can do something new without breaking.

### Stage 1: Single Genre (Current)

**What the studio has proven:**
- ✅ Can design and ship a complete game in one genre (beat 'em up)
- ✅ Has created research documents, a GDD, and institutional knowledge
- ✅ Has written 10 game development disciplines as shared knowledge
- ✅ Has authored leadership principles that work under pressure
- ✅ Has established domain ownership and eliminated information silos
- ✅ Has built a repeatable process (research → GDD → backlog → build → retrospective → skills)

**Maturity criteria:**
- One shipped game with measurable player engagement
- 5+ core team members with documented charters
- All major decisions logged in decisions.md
- All architectural decisions documented with rationale
- Skills from the shipped game captured in `.squad/skills/`

**Risk mitigated:** "All our knowledge is in one person's head" → Addressed by skills system and decision logging.

### Stage 2: Second Genre (Next Milestone)

**What the studio will prove:**
- ✅ Can onboard a new genre without restructuring
- ✅ Can validate that the 70/30 rule actually works (70% of our effectiveness is genre-agnostic)
- ✅ Can test team elasticity (new roles emerge and are successfully integrated)
- ✅ Can demonstrate skill transfer (beats from one genre inform another)

**Maturity criteria:**
- Second shipped game in a different genre (e.g., platformer)
- New genre skills created and at Level 2 (Validated)
- At least one new role added and integrated successfully (e.g., Level Designer)
- Post-mortem comparing the two genres' approaches
- Documented cross-pollination insights (what beat 'em up taught the platformer project)

**Risk mitigated:** "We can only make one genre" → Addressed by proven genre onboarding protocol and cross-genre pattern transfer.

**Key moment:** When the second game ships, the studio can credibly say: "Our process works across genres. The structure we've built will scale."

### Stage 3: Multi-Genre (3+ Shipped Games)

**What the studio will prove:**
- ✅ Multiple genre verticals are active and compound
- ✅ Cross-pollination creates genuine innovation (a technique from genre A improves genre B's execution)
- ✅ Team is no longer optimized for one game; it's optimized for *any* game in *any* genre
- ✅ Onboarding a new genre now takes 4 weeks (accelerated protocol) instead of 8

**Maturity criteria:**
- 3+ shipped games across 3+ genres
- 3+ mature genre verticals (Level 2+)
- Evidence of cross-genre innovation in design docs
- New specialists have joined and been integrated into existing domains
- At least one specialist has led a project in two different genres (proves portability of leadership)

**Risk mitigated:** "Our processes only work at small scale" → Addressed by parallel project execution (the studio can now handle 2+ games in parallel without chaos).

### Stage 4: Platform Expansion (Multi-Platform)

**What the studio will prove:**
- ✅ A single game ships on multiple platforms (e.g., browser, desktop, mobile)
- ✅ Platform-specific skills are created without losing platform independence
- ✅ Distribution and localization pipelines exist and work

**Maturity criteria:**
- One complete game shipped on 3+ platforms (e.g., web, Windows, Mac, iOS)
- Platform-specific build pipelines documented
- Localization strategy exists (if applicable)
- Performance targets are met on each platform
- Cross-platform input handling is invisible to players

**Risk mitigated:** "Switching platforms requires a rewrite" → Addressed by keeping GDD and core mechanics platform-agnostic, with platform-specific skills as tools.

### Stage 5: Studio Scale (Multiple Concurrent Projects)

**What the studio will prove:**
- ✅ 2–3 games in development simultaneously, in different genres
- ✅ Teams don't block each other
- ✅ Shared infrastructure (audio tools, art pipelines, QA processes) accelerate all projects
- ✅ A second Game Designer or Lead can run a project independently

**Maturity criteria:**
- 2+ games actively in development with separate teams
- Shared systems (audio library, character animation templates, QA frameworks) benefit multiple projects
- Domain owners have documented their expertise such that a second specialist can step in
- Studio has hired and onboarded a second domain owner (e.g., a second Lead or second Sound Designer)
- Projects don't share team members except at the top (Solo remains the bottleneck if all decisions flow through him — but that risk is known)

**Risk mitigated:** "A key team member leaving derails us" → Addressed by institutional memory (all decisions and expertise in files), domain documentation, and onboarding processes.

---

## 7. Risk Registry: What Could Force Restructuring?

These are the risks that, if ignored, *will* force the studio to stop, rebuild, and restructure. For each risk, we have a mitigation.

### Risk 1: "All Our Knowledge Is in One Person's Head"

**Trigger:** A specialist leaves or is absent, and the team realizes "nobody else can do what they do."

**Mitigation:**
- Every domain owner documents their expertise in `.squad/skills/{domain}/*.md`
- Every decision that affected that domain is logged in `.squad/decisions/`
- Every specialist has a clear charter that others can study
- When a specialist is absent, the team can reference their documented work

**Verification:**
- Can a new person pick up a domain owner's work by reading the documentation? Yes? Good.
- Can the team point to a living document that explains "this is how we do audio design"? Yes? Good.
- If a person quit today, is their expertise captured? If no, that's a priority.

### Risk 2: "We Can Only Make Games in One Engine"

**Trigger:** The studio evaluates a new engine (e.g., switching from Canvas 2D to Godot 4) and realizes core technology decisions are locked into the old engine.

**Mitigation:**
- The 70/30 rule: 70% of what we do is engine-agnostic (GDD, principles, processes, universal skills).
- Only 30% is engine-specific (engine skills, architecture, build pipelines).
- Engine skills are clearly labeled as such and don't bleed into universal knowledge.
- Leadership has explicitly decided: "If we need to switch engines, we're prepared."

**Verification:**
- Would we need to rewrite the GDD to switch engines? If yes, that's a problem.
- Would we need to rewrite quality gates to switch engines? If yes, that's a problem.
- Would we need to change team structure to switch engines? If yes, that's probably fine (new specialists, but same roles).

### Risk 3: "We Can Only Make One Genre"

**Trigger:** The studio starts a second genre project and discovers the team, process, or structure doesn't scale across genres.

**Mitigation:**
- Genre onboarding protocol (Phase 1–6) is proven *before* starting a second genre.
- Genre verticals are created and documented as permanent knowledge.
- The squad structure is genre-agnostic: Yoda is the Game Designer for any genre, Lando is Gameplay Eng for any genre.
- Cross-pollination is intentional: Research for genre 2 explicitly compares to genre 1.

**Verification:**
- When the second game ships, ask: "Did we restructure the team to make this?" If yes, investigate why (it might be necessary, but it should be intentional, not accidental).
- When the second game ships, ask: "Did we apply lessons from game 1?" If no, that's a red flag.

### Risk 4: "Our Processes Don't Scale Beyond 12 People"

**Trigger:** The squad grows to 15+ people and the rituals (standups, retrospectives, decision-making) break down.

**Mitigation:**
- The squad system is designed to work at small scale (12 specialists) and to scale horizontally (multiple squads) rather than vertically (bloating one squad).
- When the team exceeds capacity, add a *new squad*, not more people to the existing one.
- Each squad has its own Lead, its own ceremonies, its own projects — but all share the same principles, skills, and decision framework.
- The founder (or CTO) is the integration point between squads, not a bottleneck.

**Verification:**
- Are standups still 15 minutes with <15 people? Good.
- Are retrospectives still producing action items? Good.
- Do decision-makers have clear charters? Good.
- Is there a bottleneck where one person must approve every decision? That's OK for now, but document it as a risk for when the studio scales.

### Risk 5: "A Key Team Member Leaves and We Lose Direction"

**Trigger:** The Game Designer, the Lead, or another core specialist leaves, and the studio discovers no one else understands the vision or can make architectural decisions.

**Mitigation:**
- The GDD is the north star. If Yoda leaves, the GDD remains.
- Architectural decisions are documented in `.squad/decisions/`. If Solo leaves, future leads can see *why* decisions were made.
- Leadership principles are shared. Any lead should be able to make decisions that fit the principles.
- Onboarding documentation for each role is detailed enough that a replacement can step in within a month.
- The founder has read all decisions and can step in as interim lead if needed.

**Verification:**
- If the Game Designer leaves today, is the vision clear enough that the team can execute on existing backlog? Yes? Good.
- If the Lead leaves, can the team continue shipping builds? Yes? Good.
- Is there a successor identified and trained for critical roles? For Stage 1, probably not. By Stage 3, there should be.

### Risk 6: "Engine or Platform Obsolescence"

**Trigger:** A new engine becomes dominant (e.g., WebGPU replaces Canvas 2D as the way to do browser games), and our expertise in the old engine becomes worthless.

**Mitigation:**
- We've separated engine-specific skills from universal skills. If Canvas 2D becomes obsolete, the engine skill dies, but game design, principles, and universal skills remain.
- We've proven the studio can migrate engines (implicitly through the 70/30 rule). When the time comes, we migrate.
- We *don't* switch engines preemptively. We only switch when: (a) the new engine is clearly superior for our goals, (b) the migration cost is lower than staying on the old engine, (c) the team is aligned.

**Verification:**
- If Canvas 2D became obsolete tomorrow, could we ship on Godot 4? Yes? Good.
- Do we have a technical trail of "why we chose Canvas 2D" in decisions.md? Good — when we reconsider, we know what changed.

---

## 8. Decision Gates and Authority

To prevent restructuring, authority must be clear. This is how we make decisions about growth.

### Who Decides What?

| Decision Type | Authority | Process |
|---------------|-----------|---------|
| **New Genre** | Founder + Creative Director (Yoda) | Research + Feasibility study + Team consensus |
| **New Technology** | Lead (Solo) + Founder | Spike + Comparison doc + Decision log |
| **New Team Member** | Lead (Solo) + relevant domain owner | Skills assessment + Culture fit |
| **New Role** | Lead (Solo) + Founder | Gap analysis + Workload justification + Timeline to ROI |
| **Principle Violation** | Team consensus or Founder | Documented in decisions.md with reasoning |
| **Process Change** | Affected domain owners + Founder | Tested in one sprint before studio-wide adoption |

The principle: **Domain owners make decisions within their domain. Conflicts between domains go to the Lead. Conflicts involving studio direction go to the Founder.**

### Permanent Decision Log

Every major decision is logged in `.squad/decisions/` with:
- **What:** The decision made
- **Why:** The reasoning, options considered, and trade-offs
- **When:** The date and sprint context
- **Who:** The decision maker and stakeholders
- **Impact:** What changes as a result
- **Reversibility:** Can this decision be reversed? At what cost?

When the studio grows and questions resurface ("Should we switch engines?", "Should we hire a second Lead?"), the team reads the decision log and knows:
1. Have we made this decision before?
2. What changed that we should reconsider?
3. What did we learn last time?

This prevents re-litigating old decisions and accelerates new ones.

---

## 9. Putting It Together: An Example Growth Path

Let's walk through what the studio looks like in 5 years if it follows this framework.

### Year 1 (Current)
- **Games shipped:** 1 (SimpsonsKong)
- **Genres mastered:** 1 (Beat 'Em Up)
- **Team size:** 12 specialists
- **Engine:** Canvas 2D
- **Platforms:** Web (browser)
- **Skills:** `beat-em-up-*` (4 skills), universal skills (8 skills), `canvas-2d-patterns` (1 skill)

### Year 2
- **Games shipped:** 2 (SimpsonsKong + a Platformer)
- **Genres mastered:** 2 (Beat 'Em Up, Platformer)
- **Team size:** 15 (original 12 + one new Level Designer + two junior artists)
- **Engine:** Canvas 2D (platformer) or Godot 4 (team's choice)
- **Platforms:** Web + Desktop (Platformer on Godot 4)
- **Skills:** `beat-em-up-*` (4), `platformer-*` (4), universal (8), `canvas-2d-*` (1), maybe `godot-4-*` (1)

**Key milestone:** The team proves it can onboard a new genre without restructuring. Principles, processes, and team charters remain the same. Only skills and tech stack change.

### Year 3
- **Games shipped:** 3 (SimpsonsKong + Platformer + Fighting Game)
- **Genres mastered:** 3 (Beat 'Em Up, Platformer, Fighting Game)
- **Team size:** 20 (two squads: 12 core + 8 specialists split between projects)
- **Engine:** Godot 4 becomes studio standard; Canvas 2D is "legacy"
- **Platforms:** Web, Desktop, Mobile
- **Skills:** 4 per genre (12 total) + 10 universal + 2 engine-specific (Godot 4 + legacy Canvas)

**Key milestone:** The studio now has multiple concurrent projects. A second Game Designer or Lead can run a project. Shared infrastructure (audio tools, character templates) benefits all projects.

### Year 4
- **Games shipped:** 4 (portfolio includes beat 'em up, platformer, fighting game, action RPG)
- **Genres mastered:** 4
- **Team size:** 28 (three small squads, each ~9 people)
- **Engine:** Godot 4 for 2D; exploring 3D (Unity or Unreal for a new game)
- **Platforms:** Web, Desktop (Windows/Mac), Mobile, Console (if applicable)
- **Skills:** 4 per genre (16 total) + 12 universal + 3 engine-specific

**Key milestone:** The studio is no longer "one project" — it's a *studio* that ships multiple games. Each game succeeds or fails on its own merit. Failures don't sink the studio. Successes compound.

### Year 5
- **Games shipped:** 5–6 (four-to-five concurring in different stages)
- **Genres mastered:** 4–5
- **Team size:** 40–50 (5+ squads, specialized by genre or project)
- **Engine:** Polyglot — Godot 4 for indie 2D, Unity or Unreal for 3D
- **Platforms:** Everywhere the game demands it
- **Skills:** Comprehensive library across all genres, engines, and disciplines

**Key milestone:** First Frame Studios is no longer "a team that made SimpsonsKong." It's "a studio that ships great games." The knowledge from game 1 compounds into games 2, 3, 4, and beyond. Specialists can switch projects and be productive in a week because the principles, processes, and skills are documented.

---

## 10. Maintenance: Keeping the Framework Alive

A framework is only useful if it's maintained. Here's how the studio ensures the Growth Framework doesn't become an artifact on a shelf.

### 10.1 Quarterly Review

Every quarter, Yoda (Game Designer) + Solo (Lead) review:
- Is the framework still accurate? What changed in how we actually work?
- Are the 70/30 principle holdings up? (Has 30% crept to 40%?)
- Do we have gaps in documentation? Blind spots?
- Have new patterns emerged that should be captured?

This review takes 2 hours and produces a patch to this document.

### 10.2 Retrospectives as Data

Every project retrospective feeds the framework:
- Did the genre onboarding protocol work? What was faster, what was slower?
- Did the skills system work? Are specialists actually reading documented skills?
- Did the team structure scale? What new roles emerged?
- What did we learn that should be permanent knowledge?

Insights feed back into: principles.md (if a principle was violated), quality-gates.md (if we discovered a new quality criterion), or skills/ (if a new pattern emerged).

### 10.3 Decision Log Review

Once a year, the team reviews `.squad/decisions/`:
- Which decisions are still relevant?
- Which decisions have been superseded?
- Which decisions explain our current state to newcomers?

Old decisions are archived. Current decisions are refreshed. New decision documents link to this framework as context.

### 10.4 Onboarding Validation

Every new specialist reads:
1. Mission & Vision (mission-vision.md)
2. Leadership Principles (principles.md)
3. Company Identity (company.md)
4. **This Growth Framework** (growth-framework.md)
5. Relevant skills for their domain

This takes 2 days of reading. The onboarding manager asks: "Is this still accurate? Is anything confusing?" Feedback feeds into framework updates.

---

## 11. Anti-Patterns: What Breaks the Framework

To close the loop, here are the mistakes that would undo everything:

### Anti-Pattern 1: "All decisions are documented, but no one reads them."

**Why it breaks:** Documentation without adoption is theater. The file exists, but it's not a living system.

**Prevention:**
- Decisions are linked from the backlog. When a feature is built, the decision that shaped it is referenced.
- New specialists read decisions as part of onboarding.
- Decision log is reviewed once a year to flag outdated or ignored decisions.

### Anti-Pattern 2: "Principles are posted on the wall, but decisions violate them."

**Why it breaks:** Principles become aspirational instead of operational. When a deadline looms, "we'll violate the principle just this once" — and then it's always once.

**Prevention:**
- Principles are checked explicitly in design reviews. "Does this decision fit Principle #1? If not, what's the justification?"
- Violations are logged in decisions.md with full context. They're acknowledged, not hidden.
- When principles are violated, a retrospective asks: "Was the violation necessary? Can we change the principle or the process?"

### Anti-Pattern 3: "Skills exist, but they're at Level 1 forever."

**Why it breaks:** A skill at Level 1 (Documented once) is basically a memo, not institutional knowledge. It decays over time as the team forgets the context.

**Prevention:**
- Skills are explicitly leveled: Level 1 (Documented), Level 2 (Validated across 2+ projects), Level 3 (Mature studio standard), Level 4 (Evolved best practice).
- A skill stays at Level 1 only for 1–2 projects. By the second project using a skill, it should level up to Level 2.
- Domain owners review their skills quarterly and bump levels or deprecate them.

### Anti-Pattern 4: "The framework says we can do X, but we've never tried."

**Why it breaks:** Overconfidence. The framework is a theory until tested.

**Prevention:**
- The framework is written *from* experience (SimpsonsKong taught us these lessons), but it's also a *hypothesis*.
- Every major framework claim is tested before the framework is updated. "We claim we can onboard a new genre in 8 weeks" — that's tested with the second genre project.
- Framework revisions are dated. Future readers can see when a claim was made and when it was validated.

### Anti-Pattern 5: "Specialist leaves, knowledge walks out the door."

**Why it breaks:** Documentation is great, but some knowledge lives in muscle memory, relationships, and context that's hard to write down.

**Prevention:**
- When a specialist is hired, assume they'll eventually leave (role change, life happens, better opportunity elsewhere).
- In their final month, conduct a "knowledge transfer" session: record video walkthroughs of key systems, update decision logs with context, create a "handoff doc" for the successor.
- The predecessor is available for 2 weeks during the transition.
- Critical roles (Lead, Game Designer, domain owners) should have a clear succession plan by Stage 3 (multi-genre). Not all specialists need successors at Stage 1.

---

## Conclusion: The Framework Is the Studio

First Frame Studios doesn't exist to make one game. It exists to build a *capability* — the ability to make great games in any genre, any platform, any IP, at any scale.

This Growth Framework is how we protect that capability. The 70/30 rule ensures that when we change platforms or genres, 70% of our strength carries forward. The skill architecture ensures that expertise compounds instead of being lost. Team elasticity ensures that we scale without breaking our structure. The genre onboarding protocol ensures that we can enter new creative spaces with confidence. Technology independence ensures that we're never locked into a specific engine or platform.

Most importantly, **the framework is a living system**. It's not a theory written once and shelved. It's reviewed quarterly, updated annually, and tested with every new project. The framework survives because the team maintains it. The team maintains it because they see it working — each new project proves that the previous project's lessons accelerated the current one.

At its heart, the Growth Framework says this:

> We are building a studio that learns. Each project teaches the next. Each genre deepens our expertise. Each specialist documents their knowledge so that when they move to a new project (or leave the studio), their work remains. Our principles don't change. Our quality gates don't change. Our commitment to the player doesn't change. What changes is the game, the genre, the platform — and each change is an opportunity to prove that First Frame Studios is built to last.

---

## Appendix A: Framework Checklist for New Projects

When starting any new project, check these boxes:

- [ ] **Research sprint completed** — 5–10 reference games studied, research.md written
- [ ] **Genre GDD template created** — Sections specific to this genre, not generic
- [ ] **Minimum playable defined** — Specific definition of "30-day playable" for this genre
- [ ] **Team assessment done** — Skills gap analysis, confidence levels, mentorship assigned
- [ ] **Architecture spike completed** — Tech stack validated on throwaway code
- [ ] **Relevant skills read** — Team members have read skills that apply to this project
- [ ] **Decision framework clear** — Everyone understands who decides what
- [ ] **Quality gates reviewed** — Updated for this genre (metrics may differ)
- [ ] **Retrospective plan created** — How will we capture learnings at the end?

If these eight boxes are checked before Sprint 0, the project is set up to succeed *and* to teach the studio something.

---

## Appendix B: Glossary

- **70/30 Rule:** 70% of studio effectiveness is permanent (principles, processes, team structure). 30% is adaptive (genre, engine, platform).
- **Vertical:** A permanent body of genre-specific knowledge and skills (e.g., Beat 'Em Up Vertical).
- **Skill:** A documented pattern or system specific to a domain, genre, or engine (e.g., `beat-em-up-combat/SKILL.md`).
- **Maturity Level:** How validated a skill is (Level 1: Documented, Level 2: Validated, Level 3: Mature, Level 4: Evolved).
- **Domain Owner:** A specialist who has final authority in their area (e.g., Sound Designer owns audio).
- **Domain Silo:** What we *avoid* — when one person hides knowledge and blocks others from learning.
- **Genre Onboarding Protocol:** The 6-phase process for entering a new genre (Research → GDD → Minimum Playable → Skills → Team Assessment → Architecture Spike).
- **Architecture Spike:** Throwaway code written to validate tech choices before committing to architecture.
- **Quality Gate:** An outcome-based criterion that a game must meet before shipping (e.g., input latency < 100ms).
- **Playable Build:** A game that demonstrates the core loop, can be played on the target platform, and teaches something about the design.
- **Retrospective:** A team meeting to capture what was learned, what worked, and what to do differently next time.
- **Decision Log:** Permanent record of major decisions, reasoning, trade-offs, and context.
- **Cross-Pollination:** When a technique from one genre improves execution in another (e.g., beat 'em up's state machines → fighting game's netcode).
- **Elastic Scaling:** When team structure adapts to project scope without breaking (new roles emerge, old roles consolidate).
- **Technology Independence:** The property of being able to change engines/platforms without rewriting core game design or processes.

---

*This document is the constitution of First Frame Studios' growth. It was written to ensure that as the studio scales, it doesn't break. Print it. Read it. Maintain it. Let it teach the next generation of specialists what it means to build a studio that lasts.*
