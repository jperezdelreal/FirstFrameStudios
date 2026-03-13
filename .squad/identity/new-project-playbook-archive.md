# new-project-playbook.md — Full Archive

> Archived version. Compressed operational copy at `new-project-playbook.md`.

---

# New Project Playbook — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Active — The definitive guide for Day 1 of any new project.  
**Applies to:** Every future project, regardless of genre, tech stack, IP, or platform.

---

## Why This Exists

firstPunch taught us that starting a project right determines everything that follows. We went from zero to a playable build in 30 minutes — and then spent months untangling decisions we made in those first 30 minutes (god-scene in gameplay.js, 214 LOC of unwired infrastructure, state machines with missing exit paths, timer conflation bugs). 

This playbook ensures that every new project starts with the clarity firstPunch earned through pain. It is genre-agnostic, tech-agnostic, and IP-agnostic. The ~70% of what makes First Frame Studios effective — principles, processes, team coordination, design methodology, quality standards — transfers to any project. Only ~30% is tech-specific and needs adaptation.

**Use this document as a sequential checklist.** Complete each phase before advancing to the next. Skip nothing.

---

## 1. Pre-Production Phase (Before Writing Code)

Pre-production is where we earn the right to write code. Every hour invested here saves a week during production. firstPunch proved this: our 9-reference-game study produced a GDD that prevented dozens of design dead ends. The hours we *didn't* spend on pre-production (tech evaluation, architecture planning) cost us months of rework.

---

### 1.1 Genre Research Protocol

**Goal:** Understand the genre's solved problems before solving them again. (Principle #2: Research Before Reinvention.)

**Step-by-step:**

1. **Identify 7-12 landmark titles in the genre.** Not "games we like" — the games that *defined* the genre or *redefined* it. Include:
   - 2-3 foundational titles (the ones that established the rules)
   - 3-4 modern refinements (the ones that improved on the formula)
   - 2-3 indie standouts (the ones that did something unexpected within constraints)
   - 1-2 failures (the ones that prove what NOT to do — just as important)

   *firstPunch example: We studied 9 beat 'em ups spanning Streets of Rage 2 (1992) to Shredder's Revenge (2022) — 30 years of genre evolution. This wasn't optional research. It was the foundation of every design decision.*

2. **Play each reference game for at least 30 minutes with analytical intent.** Not for fun — for study. Take notes on:
   - Core loop: What do the first 60 seconds teach the player?
   - Game feel: Input latency, feedback on actions, weight of movement
   - Unique mechanics: What does THIS game do that others don't?
   - What frustrated you? Where did the design fail?
   - How does the game handle difficulty, pacing, tutorialization?

3. **Document findings in `analysis/{genre}-research.md`.** Structure:
   - Per-game analysis (200-300 words each)
   - Cross-game patterns (what did ALL successful games share?)
   - Genre-specific mechanics inventory (e.g., for beat 'em ups: grab/throw, dodge, combo systems, specials, co-op)
   - Design principles that emerged from the research
   - Anti-patterns observed in weaker titles

4. **Extract reusable patterns into initial skill outlines.** These don't need to be complete — they're hypotheses that production will validate. Create:
   - `skills/{genre}-mechanics/SKILL.md` — Core mechanics patterns (e.g., combo systems, movement physics, progression)
   - `skills/{genre}-patterns/SKILL.md` — Higher-level design patterns (e.g., difficulty curves, tutorialization, encounter design)

5. **Hold a Genre Knowledge Session.** Yoda presents research findings to the full squad. Every agent asks: "What does this mean for MY domain?" The Sound Designer asks about audio patterns. The Art Director asks about visual identity trends. The QA Lead asks about common player frustrations.

**Output:** `analysis/{genre}-research.md`, initial skill outlines, shared team understanding of the genre's design space.

**Time budget:** 2-4 sessions. Do not rush this. The genre research for firstPunch's beat 'em ups produced findings that informed 101 backlog items.

---

### 1.2 IP Assessment

**Goal:** Determine whether this is original IP or licensed, and how that changes every downstream decision.

**Decision matrix:**

| Factor | Original IP | Licensed IP |
|--------|------------|-------------|
| **Design freedom** | Total — we define the world | Constrained — the source material dictates |
| **Character mechanics** | Archetypes from genre conventions | Derived from character personality (Principle #3: IP Is the Soul) |
| **Visual identity** | Art Director defines from scratch | Art Director interprets existing aesthetic |
| **Audio identity** | Sound Designer creates original soundscape | Must reference or complement source material |
| **Marketing** | We build the brand | Built-in audience, but higher expectations |
| **Legal** | None | License terms constrain scope, timeline, revenue |

**For licensed IP, additional steps:**

1. **Source material immersion.** The entire team consumes the source material — not just the lead. Everyone. Tarkin needs to understand villain archetypes. Greedo needs to hear the audio landscape. Nien needs to see how characters move.

2. **IP authenticity checklist.** For every mechanic: "Does this feel authentic to the source material?" If it could be any IP, redesign it. *firstPunch example: Brawler's belly bounce instead of a generic dash. The verb came from the character, not from a genre template.*

3. **IP constraint mapping.** What can we NOT do? Which characters, locations, and storylines are off-limits? What are the licensee's approval gates? Document these constraints early — they're creative fuel (Principle #11), not obstacles.

**Output:** IP assessment document with design approach, constraint map, and authenticity checklist criteria.

---

### 1.3 Technology Selection

**Goal:** Choose the right engine/language/platform for THIS project. Not the one we used last time. Not the trendy one. The *right* one.

**Framework: 9-Dimension Scoring Matrix**

We developed this during the source IPKong → Godot evaluation. It works for any tech comparison. Score each candidate 1-10 on:

| # | Dimension | What It Measures |
|---|-----------|-----------------|
| 1 | **Visual ceiling** | Maximum achievable visual quality on this tech |
| 2 | **Performance ceiling** | Maximum entity count, FPS stability, memory efficiency |
| 3 | **Development speed** | Time from "I want this feature" to "it's playable" |
| 4 | **Learning curve** | Ramp-up time for our specific squad's current skills |
| 5 | **Export targets** | Which platforms can we ship to? |
| 6 | **Community & longevity** | Will this tech exist and be supported in 3-5 years? |
| 7 | **Art pipeline** | Quality of tools for creating, importing, and iterating on art |
| 8 | **Audio** | Quality of audio systems, support for our approach (procedural or file-based) |
| 9 | **Squad fit** | How well does this tech match our existing skills and workflow? |

**Process:**

1. **List 3-5 viable candidates.** Include the obvious choices AND one "stretch" option that pushes us. Our firstPunch eval compared Phaser 3, Godot 4, Unity, Defold, and Unreal (the stretch).

2. **Score each candidate.** Chewie leads the technical evaluation. Yoda evaluates design workflow. Boba evaluates art pipeline. Greedo evaluates audio capabilities. Solo synthesizes.

3. **Weight dimensions by project needs.** A mobile puzzle game weights "performance ceiling" differently than a PC action game. A jam prototype weights "development speed" above all. Document why you weighted the way you did.

4. **Require 8+ point lead for migration.** If our current tech scores within 8 points of a new tech, the migration cost probably isn't worth it. Godot beat Phaser by 8 points (74 vs 66) — that justified the switch. If it had been 70 vs 66, we'd have stayed.

5. **Document the evaluation in `analysis/tech-evaluation-{project}.md`.** Include the full matrix, the rationale, the rejected alternatives, and what would change the answer. Future Solo should be able to read this in 2 years and understand exactly why we chose what we chose (Principle #12: Every Project Teaches the Next).

**Red flags that override scoring:**
- The tech has no community momentum → reject regardless of features
- The tech had a pricing/trust controversy in the last 2 years → apply a 2-point penalty to "longevity"
- The tech is overkill for the project scope → prefer the simpler option (Principle #11: Constraints Are Creative Fuel)
- The tech would force us to abandon a proven innovative system → heavy penalty (we almost lost procedural audio in the Phaser path)

**Output:** Tech evaluation document with scored matrix, decision, and rationale.

---

### 1.4 Team Assessment

**Goal:** Understand which skills transfer, which gaps exist, and whether we need new roles or new skills for existing roles.

**Step-by-step:**

1. **Skill transfer audit.** For each agent, assess against the chosen tech:
   - ✅ **Transfers directly:** Design patterns, architecture thinking, domain expertise, process knowledge
   - 🔄 **Transfers with adaptation:** Language syntax, API equivalents, tool workflow
   - ❌ **Needs new learning:** Engine-specific features, new paradigms, new toolchains

2. **Gap analysis.** Does this genre/project require skills nobody on the squad has?
   - *Example: If entering 3D, nobody owns camera management, spatial combat, or depth perception feedback. That's a gap.*
   - *Example: If entering multiplayer, nobody owns netcode, matchmaking, or server architecture. That's a bigger gap.*

3. **Decision: New roles vs. new skills.**
   - **New skill for existing role:** When the gap is a natural extension of someone's domain (e.g., Chewie learning a new rendering API — still engine work)
   - **New role:** When the gap is a new domain that would overload an existing owner or requires fundamentally different expertise (e.g., we added Jango for tooling because nobody owned development-time systems)

4. **Training plan.** For each identified gap:
   - What's the learning resource? (Official docs, tutorials, our own skill documents)
   - Who's the learning buddy? (Pair agents for ramp-up)
   - What's the validation milestone? (Build a small thing that proves competence)
   - What's the estimated ramp-up time?

   *firstPunch example: For Godot transition, we estimated 2-3 weeks GDScript ramp, created a 12-section manual (`godot-4-manual` skill), and assigned domain-specific Godot exploration tasks to each agent.*

**Output:** Skill transfer matrix, gap analysis, training plan with timelines.

---

### 1.5 Competitive Analysis

**Goal:** Know what similar games exist and define our differentiation.

**Step-by-step:**

1. **Market scan.** Find 5-10 games that occupy the space we're entering. Include:
   - Direct competitors (same genre, same platform, similar scope)
   - Aspirational targets (games we want to be compared to)
   - Adjacent games (different genre, similar audience)

2. **For each competitor, document:**
   - What they did well (be honest — respect good work)
   - What they did poorly (opportunities for us)
   - Their audience reception (Steam reviews, Metacritic, community sentiment)
   - Their pricing/distribution model

3. **Define our differentiation.** Answer: "Why would a player choose our game over [competitor]?" If the answer is "they wouldn't" or "ours is the same but with different art," rethink the project. Differentiation must be gameplay-level, not cosmetic.

4. **Define our "one thing."** Every successful indie game does ONE thing better than anyone else. Find ours and protect it from scope creep. Everything else is negotiable. This is not.

**Output:** Competitive analysis section in GDD or standalone `analysis/competitive-{project}.md`.

---

## 2. Sprint 0 — Foundation (First Week)

Sprint 0 is about proving the engine and the team, not shipping the game. The goal is razor-sharp: **"Does the core action feel right?"** Everything else is Sprint 1+.

---

### 2.1 Repository Setup (Engine-Agnostic Checklist)

Regardless of engine, every project starts with these:

**Source control:**
- [ ] Repository created with appropriate `.gitignore` for the chosen engine
- [ ] Branch strategy defined (main = stable, dev = integration, feature branches for work)
- [ ] README with project name, engine version, setup instructions
- [ ] All squad members can clone, build, and run

**Project structure:**
- [ ] Engine project file created and configured (e.g., `project.godot`, `package.json`, `.csproj`)
- [ ] Folder structure defined and documented:
  - Scenes/levels directory
  - Scripts/code directory
  - Assets directory (art, audio, data)
  - Resources/configs directory
  - Tests directory (if applicable)
- [ ] Entry point defined (main scene, index.html, etc.)
- [ ] Export/build targets configured for at least ONE platform

**Infrastructure stubs:**
- [ ] Event/signal system stubbed (autoload, event bus, or engine-native signals)
- [ ] Game state singleton stubbed (current scene, score, player data)
- [ ] Input mapping defined (named actions, not hardcoded keys)
- [ ] Collision layers/masks assigned and documented (if applicable)
- [ ] Audio bus layout defined (Master → SFX, Music, Ambient at minimum)

**Quality infrastructure:**
- [ ] Style guide/conventions document exists (or `project-conventions` skill filled)
- [ ] Linter/formatter configured (if the language supports it)
- [ ] CI/CD pipeline stubbed (even if it just validates "project opens without errors")

**Owner:** Jango (Tool Engineer) scaffolds. Solo (Lead) reviews and approves before anyone builds on it.

*firstPunch lesson: We didn't define collision layers upfront. Phase 3 integration revealed incompatible assumptions between Chewie and Lando. Pre-deciding these in Sprint 0 eliminated our most common multi-agent coordination failure.*

---

### 2.2 Squad Adaptation

The squad's roles are genre-agnostic (Principle: Team Adaptability from company.md). What changes per project is the SKILLS they read, not their charters. Here's how to adapt:

**Stays as-is (every project):**
- `team.md` — Roster and role definitions (roles are stable)
- `routing.md` — Domain routing rules (same routing, different content)
- `principles.md` — Leadership principles (universal)
- `quality-gates.md` — Gate structure (adapt thresholds, not gates)
- `company.md` — Studio identity (project-independent)
- Agent charters — Role boundaries (stable across projects)

**Needs adaptation (per project):**
- `skills/` — New genre-specific skills, tech-specific skills
- `analysis/` — Fresh research, GDD, backlog, tech evaluation
- `quality-gates.md` thresholds — Performance budgets change per platform/engine
- Sprint plans — New dependency graphs, new phase structures
- Agent skill requirements — Which skills each agent should read before starting

**Adaptation checklist:**
- [ ] Review each agent charter: Does this role have work in this project? If not, mark as "on standby"
- [ ] Identify charter updates needed (new engine means Chewie's charter references new systems)
- [ ] Create project-specific skill reading lists per agent
- [ ] Update quality gate performance budgets for the target platform
- [ ] Define cross-review assignments for the new project structure

*firstPunch example: When evaluating art department expansion, we checked which agents had insufficient work before adding roles. Leia and Bossk went on standby during Sprint 0 because there was nothing for them until gameplay existed. Don't activate agents with no work.*

---

### 2.3 Genre Skill Creation

The first research output becomes the team's genre playbook. Two skills, created during or immediately after pre-production:

**`skills/{genre}-mechanics/SKILL.md`:**
- Core mechanics of the genre (what the player DOES)
- Frame data targets and timing windows (if applicable)
- Input patterns and responsiveness standards
- Movement physics conventions
- Reference implementations from landmark titles

**`skills/{genre}-patterns/SKILL.md`:**
- Higher-level design patterns (how levels/encounters/progression WORKS)
- Difficulty curve conventions
- Pacing patterns
- Tutorialization approaches
- Common anti-patterns and why they fail

**Format:** Follow the existing skill template with frontmatter, When to Use/Not Use, Core Patterns with code examples, Anti-Patterns, and Checklists.

*firstPunch example: We created `beat-em-up-combat/SKILL.md` (attack lifecycle, frame data, hitbox rules, combo systems, enemy archetypes, game feel checklist) and `beat-em-up-patterns` for higher-level design. These weren't theoretical — they were synthesized from 9 reference games and validated against our own shipped code.*

---

### 2.4 Architecture Proposal

**Owner:** Solo (Lead / Chief Architect). This is my job. Nobody else defines architecture.

**Before anyone writes game code, I deliver:**

1. **Module boundaries.** What are the major systems? Where do they start and stop? What does each system own and NOT own? Every module has one owner — no shared ownership, no ambiguity.

2. **Scene/node/component structure.** How entities are composed. What the hierarchy looks like. Where shared logic lives vs. instance-specific logic. Document the scene tree (or equivalent) as a diagram.

3. **Integration patterns.** How do modules talk to each other? Signals/events? Direct references? Dependency injection? Define ONE pattern and enforce it. Mixed patterns create bugs.
   - *firstPunch used both EventBus signals AND direct function calls. This created 40+ direct calls in gameplay.js. Pick ONE. We chose EventBus + typed signals for Godot.*

4. **State machine standards.** Every entity with states gets:
   - A transition table (which states can transition to which)
   - Exit conditions for EVERY state (the #1 lesson from firstPunch — missing exits caused critical bugs)
   - A timeout safety net for any state that could potentially get stuck

5. **Naming conventions.** Files, classes, signals, variables, folders — all named consistently. Document in `project-conventions` skill.

6. **Technical decisions pre-table.** Decisions that WILL be debated if not pre-decided. Physics approach, input handling pattern, camera setup, data format for configurations. Write them down with rationale. Sprint 0 is not the time for architecture debates — it's the time for architecture clarity.

   *firstPunch Sprint 0 pre-decided 7 architecture choices (CharacterBody2D, enum state machines, Area2D hitbox/hurtbox, EventBus autoload, Camera2D, Input map actions, flat scene tree). Zero Sprint 0 debates on architecture.*

**Output:** Architecture proposal document reviewed by Chewie and Lando before Phase 2 begins.

---

### 2.5 Minimum Playable Definition

**Goal:** Define "what's the first playable for THIS genre?" — the smallest build that lets us feel the core action.

**Formula:** The minimum playable is the core verb + one target + one feedback.

| Genre | Core Verb | Target | Feedback | Minimum Playable |
|-------|-----------|--------|----------|-------------------|
| Beat 'em up | Punch | Enemy | Takes damage, reacts | Move + punch + enemy reacts to hit |
| Platformer | Jump | Platform | Land on it | Move + jump + land on platform |
| Fighting game | Attack | Opponent | Block/hit reaction | Two characters + basic attacks + blocking |
| Puzzle | Place/match | Grid/board | Clear/score | One puzzle mechanic + win condition |
| Shooter | Shoot | Enemy | Dies/reacts | Move + shoot + enemy dies |
| RPG | Attack/interact | NPC/enemy | Dialogue/damage | Move + one combat encounter OR one NPC interaction |
| Racing | Drive | Track | Finish line | Accelerate + steer + one complete track loop |

**Success criteria for ANY minimum playable:**

1. The game opens without errors
2. The player character responds to input within 1 frame
3. The core action produces visible, audible feedback
4. At least one "target" exists and reacts to the core action
5. A HUD shows at least one piece of state (health, score, time)
6. No crashes, freezes, or dead-end states
7. Ackbar has playtested and confirmed all criteria met

**The "First Frame" test:** Does it feel like a game in the first second of interaction? If the character responds to input and the core action connects with satisfying feedback, Sprint 0 succeeds. *firstPunch Sprint 0 goal: "Move, punch, damage." Nothing else. That constraint kept us focused.*

**Time budget:** 3-4 sessions maximum. If it takes longer, the scope is too big.

---

### 2.6 Quality Gates Adaptation

Our quality gates (Code, Art, Audio, Design, Integration) are universal in structure but need per-project adaptation:

**Always applies (every project):**
- C1: Compiles and runs without errors
- C2: State machine audit (every state has entry, behavior, exit)
- C3: All imports/dependencies valid
- C5: No unused infrastructure (build-don't-wire anti-pattern prevention)
- C6: Cross-reviewed by a second engineer
- D1: Aligns with GDD
- D2: Serves player experience (Player Hands First)
- D5: Player feedback clear
- I1: No regressions
- I2: All systems wired
- All Definition of Done items

**Needs adaptation per project:**
- Performance budgets (I3): FPS targets, entity limits, memory — all change by platform and engine
- Art resolution standards (A2): Pixel density, format, import settings — all engine-specific
- Audio routing (AU4): Bus structure, format support — all engine-specific
- Export target verification (I5): Which platforms? Web? Desktop? Mobile?
- Genre-specific design gates: Fighting games need frame data verification. Puzzle games need difficulty curve testing. Platformers need jump arc validation.

**Process:**
1. Copy `quality-gates.md` as the starting template
2. Update performance budget table for target engine/platform
3. Add 2-5 genre-specific criteria under Design Quality Gate
4. Remove criteria that don't apply (e.g., spatial audio panning for a text adventure)
5. Solo reviews and approves the adapted gates before Sprint 1

---

## 3. Production Phases

Production is where the game gets built. The playbook here is about *rhythm* — how to organize work, capture knowledge, and maintain quality across sprints.

---

### 3.1 Phase Planning Methodology

**Priority system (P0-P3):**

| Priority | Definition | Rule |
|----------|-----------|------|
| **P0** | Game-breaking — can't play without it | Fix before anything else. Drop current work. |
| **P1** | Core experience — the game isn't the game without this | Complete before moving to P2. These define the minimum shippable product. |
| **P2** | Polish & depth — elevates good to great | Work on after P1 is stable. These are the "wow" moments. |
| **P3** | Nice-to-have — would love it but can cut it | Only if time allows. First to cut under deadline pressure. |

**Phase structure (adapt per project):**

- **Phase A: Core Mechanics** (P0 + critical P1) — Get the core loop feeling right. This is the critical path. Every other phase depends on the core action feeling good.
- **Phase B: Content & Depth** (remaining P1) — Enemies, levels, progression, variety. The core loop now has THINGS to loop through.
- **Phase C: Polish & Juice** (P2) — VFX, audio polish, screen feel, tutorialization. The game goes from "works" to "feels great."
- **Phase D: Ship Prep** (remaining P2 + infrastructure) — Bug fixes, performance optimization, build pipeline, QA passes. The game goes from "feels great" to "ships clean."

**Parallel lanes:** Each phase has independent workstreams that can run simultaneously:
- Engine/Gameplay lane (Chewie, Lando)
- Art/Audio lane (Boba, Nien, Leia, Bossk, Greedo)
- Content/QA lane (Tarkin, Ackbar, Yoda)
- Tooling lane (Jango)

*firstPunch lesson: Lando carrying 50% of the backlog created a critical bottleneck. Phase planning must ensure no agent carries more than 20% of any phase's items. If someone exceeds 20%, split their work or add a parallel contributor.*

---

### 3.2 Skill Capture Rhythm

**After each phase (not just at the end of the project):**

1. **Phase retrospective.** 30-minute session:
   - What worked? (Capture as a pattern in `wisdom.md`)
   - What didn't? (Capture as an anti-pattern)
   - What surprised us? (Capture as a learning in agent history)
   - What would we do differently next time? (Capture in this playbook)

2. **Skill extraction.** If a phase taught us something reusable:
   - New pattern → Add to existing skill or create new skill
   - New anti-pattern → Add to relevant skill's anti-pattern section
   - New process → Update playbook or ceremonies
   - New tool/technique → Document in relevant skill

3. **Agent history update.** Each agent updates their `history.md` with:
   - What they built
   - What they learned
   - What they'd do differently
   - Key decisions they made and why

**Cadence:** Skills are living documents. Don't wait for "perfection" — write what you know NOW, refine as you learn more. A skill with 5 patterns is better than no skill while you wait to document 20.

*firstPunch example: After our codebase analysis session, we extracted 5 new skills (state-machine-patterns, multi-agent-coordination, beat-em-up-combat, canvas-2d-optimization, game-qa-testing). Each one traced directly to real bugs and real wins. Skills born from experience, not theory.*

---

### 3.3 Cross-Project Knowledge Transfer

**What transfers between projects (compound returns):**
- Leadership principles (universal)
- Quality gates structure (universal, thresholds adapt)
- Team structure and routing (universal)
- Process knowledge: how to run sprints, how to triage bugs, how to playtest
- Genre skills (reusable whenever we return to that genre)
- Tech-agnostic skills: state-machine-patterns, multi-agent-coordination, game-qa-testing
- Design methodology: research protocol, GDD structure, backlog format
- Agent histories and institutional memory

**What stays project-specific (does not transfer):**
- Game-specific code
- Project-specific GDD content
- Asset files (art, audio, levels)
- Engine-specific configuration

**Transfer mechanism:**
- Skills directory carries forward (copy relevant skills to new project repo)
- Agent histories carry forward (agents remember what they learned)
- This playbook carries forward (it IS the transfer mechanism)
- Decisions log carries forward as reference (don't re-debate settled questions)

**Rule:** Before opening any design or tech question on a new project, check if a past project already answered it. Read the decision log. Read agent histories. Read relevant skills. Learning means not repeating the investigation. (Principle #12: Every Project Teaches the Next.)

---

## 4. Technology Transition Checklist

When changing engines, languages, or fundamental tech stack. We did this once (Canvas 2D → Godot 4) and documented the pattern. Here it is, generalized.

---

### 4.1 What Transfers (Keep These)

| Category | Examples | Effort to Transfer |
|----------|---------|-------------------|
| **Architecture patterns** | State machines, event-driven communication, entity composition, module boundaries | Zero — these are concepts, not code |
| **Design documents** | GDD, competitive analysis, genre research, balance targets | Zero — copy directly |
| **Skills methodology** | Skill template, skill capture rhythm, reading lists | Zero — methodology is tech-agnostic |
| **Leadership principles** | All 12 principles | Zero — these are human truths |
| **Team structure** | Roles, routing, charters, cross-review assignments | Zero — roles are genre/tech-agnostic |
| **Quality process** | Gate structure, Definition of Done, bug severity matrix, playtest protocols | Minimal — update thresholds, keep structure |
| **Institutional memory** | Agent histories, decision logs, retrospective learnings | Zero — memory travels with the team |

### 4.2 What Needs Rewrite

| Category | Examples | Effort |
|----------|---------|--------|
| **Engine-specific skills** | `canvas-2d-optimization` → `{new-engine}-optimization` | Medium — concepts transfer, API details change |
| **All game code** | Player, enemies, combat, UI, VFX, audio | High — but architecture patterns guide the rewrite |
| **Build pipeline** | Export targets, CI/CD, deployment scripts | Medium — engine-specific tooling |
| **Project conventions** | Naming, file structure, style guide | Medium — language and engine dictate conventions |
| **Tool infrastructure** | Templates, scaffolding, editor plugins | High — entirely engine-specific |

### 4.3 What Needs Evaluation

**Run the 9-Dimension Scoring Matrix (Section 1.3) before every migration.** No exceptions. Even if the answer seems obvious.

Questions to answer:
- Does the new tech raise our ceiling enough to justify the migration cost?
- Does the new tech lower our floor in any dimension? (We nearly lost procedural audio in the Phaser path)
- Is the squad's current skill set closer to the new tech or the old tech?
- What's the estimated ramp-up time?
- Can we prototype in the new tech before committing?

**Migration threshold:** Require an 8+ point lead in the 9-dimension matrix to justify migration. Below that, the productivity cost of switching likely exceeds the capability gain.

### 4.4 Migration Mapping (Our Proven Pattern)

Based on our Canvas 2D → Godot 4 migration:

**Phase 1: Knowledge Mapping (1 session)**
Document what we built, what transfers as concepts, and what needs rewriting. Create a two-column table: firstPunch System → New Engine Equivalent.

*Our example:*
| Our System | Engine Equivalent |
|-----------|------------------|
| Fixed-timestep game loop | `_physics_process(delta)` — built in |
| State machines (enum + match) | Same pattern, GDScript enum + match |
| EventBus (pub/sub) | Signals — Godot's native equivalent, stronger typed |
| Audio bus hierarchy | AudioBus system — built in, visual editor |
| Sprite caching | Texture management — built in |
| Hitlag / time scale | `Engine.time_scale` — built in |
| Screen shake / zoom | Camera2D properties — built in |

**Phase 2: Training Sprint (1-3 weeks depending on tech distance)**
Each agent explores their domain in the new tech:
- Engine Dev: Game loop, scene management, rendering pipeline
- Gameplay Dev: Character controller, input, state machines
- Art team: Animation tools, sprite import, visual effects
- Audio: Audio system, bus routing, procedural capability (if applicable)
- UI Dev: UI framework, theming, layout system
- QA: Debugging tools, profiler, remote inspector
- Lead: Project structure, autoloads/singletons, signal architecture
- Tool Engineer: Scaffolding, templates, conventions

**Phase 3: Prototype (1-2 weeks)**
Build the minimum playable (Section 2.5) in the new tech. Compare feel with the old build. The new version must match or exceed the old version's feel before committing to full production.

**Phase 4: Full Production**
Apply everything from this playbook — Sprint 0, architecture proposal, quality gates, the whole process — as if starting fresh, but with all institutional knowledge intact.

### 4.5 Training Protocol (Repeatable Process)

When we moved to Godot, we created a 12-section manual (`godot-4-manual` skill). Here's the generalized process:

1. **Identify the learning scope.** What does each agent need to know? Not everything — just their domain's equivalent in the new tech.

2. **Create a structured learning resource.** Either:
   - A skill document covering the engine fundamentals (our approach — `godot-4-manual`)
   - A curated reading list of official docs + tutorials per domain
   - A series of small exercises per agent ("build X in the new engine")

3. **Pair learning.** Agents with adjacent domains learn together:
   - Chewie + Lando (engine + gameplay — they share systems)
   - Boba + Nien (art direction + character art — they share visual pipeline)
   - Greedo + Chewie (audio + engine — audio system is engine-dependent)

4. **Validation milestones.** Each agent demonstrates competence:
   - Engine Dev: Game loop running, scene transitions working
   - Gameplay Dev: Character moving, input responsive
   - Art team: Sprites imported, one animation playing
   - Audio: Sound playing through correct bus
   - Each builds a SMALL thing and shows it to the team

5. **Document the training.** What we learned, what was harder than expected, what clicked immediately. This feeds the next migration's training plan.

---

## 5. Language/Stack Flexibility Matrix

**The key insight: ~70% of what makes First Frame Studios effective is tech-agnostic. Only ~30% is tech-specific.**

The 70% that travels everywhere:
- Leadership principles (how we make decisions)
- Team structure (who does what)
- Quality process (how we define "done")
- Design methodology (how we research, design, and iterate)
- Skill capture rhythm (how we learn)
- Project management (priority system, phase planning, backlog format)
- IP approach (how we handle character design, authenticity, world-building)

The 30% that changes:
- Language syntax and idioms
- Engine APIs and workflows
- Build tools and deployment
- Engine-specific design patterns
- Platform-specific optimizations

---

### Compatibility Matrix

| Tech Stack | Language Shift | Engine Shift | Paradigm Shift | Migration Effort | Notes |
|-----------|---------------|-------------|---------------|-----------------|-------|
| **Godot / GDScript** | Python-like → ours | Godot editor, scene/node | Signal-based, scene tree | — (current target) | Our next project's stack |
| **Godot / C#** | GDScript → C# | Same engine | Same + stronger typing | **S** | Same engine, different language. Viable for performance-critical paths. |
| **Unity / C#** | GDScript → C# | Full engine change | Component/prefab, inspector-heavy | **L** | Bigger paradigm shift. Scene merge conflicts with 13 agents. Asset store dependency risk. |
| **Unreal / C++** | GDScript → C++ | Full engine change | Blueprint + C++, massive editor | **XL** | Only justified for 3D or AAA scope. Overkill for 2D. |
| **Unreal / Blueprint** | Visual scripting | Full engine change | Node-based logic | **XL** | Interesting for prototyping. Not for production with 13 agents. |
| **Web / JS + Canvas** | Back to JS | Back to browser | Module-based, manual engine | **M** | We already did this. Know the ceiling. Good for jams, prototypes. |
| **Web / PixiJS** | JS | WebGL wrapper | Similar to Phaser, less framework | **M** | More control than Phaser, less framework support. |
| **Web / Phaser 3** | JS | Full 2D framework | Scene lifecycle, physics built-in | **S** | Strong for web-only games. Loses procedural audio, platform reach. |
| **Rust / Bevy** | GDScript → Rust | ECS engine | Entity-Component-System, data-oriented | **XL** | Steep learning curve. Rust ownership model is a paradigm shift. Incredible performance if mastered. |
| **C++ / SDL2** | GDScript → C++ | Low-level | Manual everything | **XL** | Maximum control, maximum effort. Only for extreme performance needs. |
| **Lua / LÖVE** | GDScript → Lua | Lightweight 2D | Callback-based | **M** | Great for jams and small projects. Limited tooling for larger teams. |
| **Lua / Defold** | GDScript → Lua | Message-passing engine | Unique paradigm | **L** | Excellent mobile performance. Niche community. |

**T-shirt sizing guide:**
- **S** = 1-2 weeks ramp, same paradigm, language is adjacent
- **M** = 2-4 weeks ramp, familiar paradigm, different language
- **L** = 1-2 months ramp, new paradigm, significant relearning
- **XL** = 2-3+ months ramp, fundamentally different approach, steep learning curve

---

### What Changes vs. What Stays (Per Switch)

**If changing LANGUAGE only (same engine):**
- Changes: Syntax, idioms, type system, standard library
- Stays: Engine workflow, scene structure, editor tools, asset pipeline, ALL design/process

**If changing ENGINE (new rendering, new editor):**
- Changes: Project structure, build pipeline, editor workflow, engine APIs, asset import
- Stays: Architecture patterns, state machine design, design documents, team structure, quality process, ALL principles

**If changing PARADIGM (e.g., OOP → ECS, imperative → visual scripting):**
- Changes: How you think about code organization, entity composition, data flow
- Stays: Game design knowledge, genre expertise, team coordination, quality standards, IP approach

**The compounding insight:** Every project we complete adds to the 70% that transfers. Genre research compounds. Design methodology compounds. Quality process compounds. The more projects we ship, the smaller the "new" portion of each subsequent project becomes.

---

## 6. Anti-Bottleneck Patterns

Bottlenecks are the #1 velocity killer. Every project has them. The goal isn't to eliminate bottlenecks (impossible) — it's to detect them early and resolve them fast.

---

### 6.1 Bottlenecks We Hit in firstPunch (And How to Prevent Them)

| Bottleneck | What Happened | Root Cause | Prevention |
|-----------|--------------|-----------|-----------|
| **Single-agent overload** | Lando carried 50% of backlog (26/52 items) | No content developer. Gameplay + content on one person. | **Load cap: No agent >20% of any phase.** If exceeded, split the domain or add a parallel contributor. |
| **God-scene accumulation** | `gameplay.js` grew to 695 LOC touching every system | No module boundaries defined upfront. Easy to add "just one more function" to the central file. | **Module boundaries in Sprint 0.** Architecture proposal defines what each file owns BEFORE code is written. |
| **Build-don't-wire** | 214 LOC of working infrastructure (EventBus, AnimationController, SpriteCache, CONFIG) never connected to consumers | Agents build systems in isolation. Integration is unglamorous. Nobody owns it. | **Every infrastructure PR must include wiring to at least one consumer.** No orphan systems. Quality gate C5 enforces this. |
| **Missing state exits** | Player frozen in `hit` state — no exit path defined. 3 timer conflation bugs. | State machines built incrementally without auditing the full transition table. | **Transition table required before implementation.** Quality gate C2 requires documented entry/behavior/exit for every state. |
| **Undiscovered shipped bugs** | Two game-breaking bugs (player freeze, passive enemies) shipped because no agent caught them | Self-review only. No dedicated QA. No regression checklist. | **Cross-review assignments + Ackbar's regression checklist.** No code merges without a second pair of eyes. |
| **Art direction drift** | 17 backlog items across 4 art disciplines, no central authority | Art was one person doing 4 jobs. No art direction document. | **Art Director role with art direction document.** Created before production starts. All art reviewed against it. |
| **Tech ceiling discovery (late)** | Discovered procedural art ceiling (~400 LOC/character) after building 1 character, not before | No tech evaluation before starting. Jumped straight to building. | **Pre-production tech evaluation (Section 1.3).** Know your ceiling BEFORE you start building against it. |

---

### 6.2 Common Game Studio Bottleneck Patterns

| Pattern | Description | Detection Signal | Mitigation |
|---------|------------|-----------------|-----------|
| **Pipeline bottleneck** | One person/system that every other task depends on | Multiple agents waiting on the same deliverable | Parallelize the bottleneck's work or break the dependency. If art blocks gameplay, use placeholder art. |
| **Integration cliff** | Individual systems work in isolation, then fail catastrophically when connected | "Everything works in my branch" followed by integration failures | Integration passes after each parallel work phase. EventBus/signal contracts agreed upfront. |
| **Scope snowball** | "Just one more feature" accumulates until the project is overwhelmed | Backlog growing faster than items are completed | P0/P1/P2/P3 discipline. Solo makes scope cuts. P3 items are cut first, always. |
| **Perfectionism paralysis** | Polishing a system to perfection while the rest of the game doesn't exist | One system at 95% quality while three systems are at 0% | Ship the playable (Principle #4). 80% quality across all systems beats 100% quality in one system with nothing else. |
| **Knowledge silos** | Only one person understands a system, and they're unavailable | "Ask [agent] — they're the only one who knows how that works" | Cross-review assignments, documented architecture, skill documents. Every critical system understood by at least 2 agents. |
| **Decision debt** | Unresolved questions accumulate and block downstream work | Agents making incompatible assumptions because nobody decided | Pre-decide architecture in Sprint 0 (Section 2.4). Decision log in `decisions.md`. Solo decides when consensus stalls. |

---

### 6.3 When to Parallelize vs. Serialize

**Parallelize when:**
- Tasks are in independent domains (art, audio, gameplay, UI)
- Module boundaries are defined and integration contracts exist
- Placeholder assets can stand in for dependencies (use colored rectangles, sine-wave sounds)
- Each agent can test their work in isolation

**Serialize when:**
- A system's output is another system's input (don't build UI for a health bar before health exists)
- Architecture decisions affect multiple agents (decide first, then build in parallel)
- Integration is failing — stop adding new features and fix what's broken
- The core loop isn't fun yet — don't build content for a broken core

**Our dependency rule:** If your task has a dependency, identify it on Day 1. If the dependency is 2+ days away, find something you CAN do in parallel. Never sit idle waiting for a dependency when there's backlog work available.

---

### 6.4 When to Add Team Members vs. Add Skills

| Situation | Add a Skill | Add a Role |
|-----------|------------|-----------|
| Existing agent's domain naturally includes the gap | ✅ | ❌ |
| Gap requires fundamentally different expertise | ❌ | ✅ |
| Workload on existing agent is already >20% of phase | ❌ | ✅ (domain split) |
| Gap is temporary (one project, one phase) | ✅ | ❌ |
| Gap is permanent (every project will need this) | ❌ | ✅ |
| Adding a role would create coordination overhead > productivity gain | ✅ (absorb it) | ❌ |

**firstPunch examples:**
- **Added skill, not role:** Canvas 2D optimization — Chewie's domain, natural extension, documented as a skill.
- **Added role, not skill:** Tool Engineer (Jango) — nobody owned development-time tooling, and distributing it across agents recreated the "everyone owns it, nobody does it" anti-pattern.
- **Split domain:** Art department (1 → 4 roles) — Boba carrying 17 items across 4 disciplines was unsustainable. Domain was too broad for one owner (Principle #7: split when overloaded).

---

## Appendix A: Day 1 Quickstart

For the impatient — here's the absolute minimum to start a new project. After this, follow the full playbook.

**Hour 1: Decide**
- [ ] What genre? (If new, start Section 1.1 research)
- [ ] What IP? (Original or licensed — Section 1.2)
- [ ] What tech? (If uncertain, run Section 1.3 evaluation. If continuing current tech, skip.)

**Hour 2-4: Research**
- [ ] Identify 7-12 reference games
- [ ] Play 2-3 of them analytically (30 min each)
- [ ] Document first impressions and core patterns

**Day 2-3: Foundation**
- [ ] Jango scaffolds repository (Section 2.1)
- [ ] Solo writes architecture proposal (Section 2.4)
- [ ] Yoda drafts GDD v0.1 (500 words max — core loop + 30-second gameplay description)
- [ ] Boba creates art direction document
- [ ] Define minimum playable (Section 2.5)

**Day 4-7: Build**
- [ ] Phase 2 of Sprint 0 — core gameplay
- [ ] Phase 3 — integration and QA
- [ ] Ackbar playtests. Done when the First Frame test passes.

**End of Week 1:** We have a playable prototype with the core action feeling right, a full architecture, a GDD outline, and quality gates defined. Everything else is iteration.

---

## Appendix B: Template — Pre-Production Checklist

Copy this checklist into a new project's `analysis/` directory and check items as completed.

```markdown
# Pre-Production Checklist — [Project Name]

## Genre Research
- [ ] 7-12 reference games identified
- [ ] Each played for 30+ minutes with analytical notes
- [ ] `analysis/{genre}-research.md` written
- [ ] Genre knowledge session held with full squad
- [ ] Initial genre skills outlined

## IP Assessment
- [ ] Original vs. licensed determined
- [ ] IP authenticity checklist defined (if licensed)
- [ ] Constraint map documented (if licensed)
- [ ] Source material consumed by full team (if licensed)

## Technology Selection
- [ ] 3-5 candidates identified
- [ ] 9-dimension scoring matrix completed
- [ ] Decision documented with rationale
- [ ] `analysis/tech-evaluation-{project}.md` written

## Team Assessment
- [ ] Skill transfer audit complete
- [ ] Gaps identified
- [ ] New roles vs. new skills decision made
- [ ] Training plan with timelines

## Competitive Analysis
- [ ] 5-10 competitors identified
- [ ] Differentiation defined
- [ ] "One thing" identified and protected

## Sprint 0 Ready
- [ ] Repository setup checklist complete
- [ ] Architecture proposal written and reviewed
- [ ] Minimum playable defined
- [ ] Quality gates adapted for this project
- [ ] Genre skills created
- [ ] Agent assignments for Sprint 0 defined
```

---

*This playbook is the product of everything firstPunch taught us — every bug, every bottleneck, every breakthrough. It's not theory. It's the pattern we wish we'd had on Day 1 of our first project. Now we do. Use it.*

*— Solo, Lead / Chief Architect, First Frame Studios*
