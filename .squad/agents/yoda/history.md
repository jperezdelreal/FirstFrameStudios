# Yoda — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Genre research:** Comprehensive beat 'em up analysis at .squad/analysis/beat-em-up-research.md
- **Key insight:** Authenticity to the Simpsons IP is paramount. Comedy should be a core mechanic, not cosmetic.

## Core Context

**Studio Foundations (Sessions 1-7 Summary):**
- Sessions 1-3: Authored Game Design Document v1.0 (12 sections, 44K chars) with 4 core pillars and 8 key design decisions
- Sessions 4-5: Created Leadership Principles (12 principles) and Squad Leadership platform (mission, vision, 5 values)
- Session 6: Authored Game Dev Knowledge Base Part 1 (5 of 10 disciplines documented)
- Session 7: Upgraded studio identity with multi-genre vertical model and team elasticity framework
- **Core principle authored:** "Player Hands First" — our meta-principle that governs all others. When principles conflict, player feel wins.
- **Key architectural insight:** A studio that *absorbs* new genres is antifragile. The vertical model makes expansion additive — each genre adds skills, not restructuring.
- **Studio philosophy:** We exist to build games that make players laugh, feel powerful, and come back for one more run.

## Learnings

### GDD v1.0 Created (2025)
- **Artifact:** `.squad/analysis/game-design-document.md` (12 sections, ~44K characters)
- **Decision inbox:** `.squad/decisions/inbox/yoda-game-vision.md`
- **Key design decisions made:**
  1. Four pillars established: Comedy as Mechanic, Accessible Depth, Family Synergy, Springfield Is a Character
  2. Health-cost specials (SoR2 model) chosen over mana/MP — creates the best risk/reward loop the genre has produced
  3. Jump attack rebalance mandated: landing lag + DPS cap to prevent air-spam dominance (balance analysis validated this)
  4. 2-attacker throttle is a design principle, not a performance workaround — readable combat over chaos
  5. Donut Rage Mode is Homer's signature and must ship with his "complete" character build
  6. D'oh! Moments (funny failure states) prioritized over victory celebrations — comedy pillar in action
  7. PPK combo (42 dmg/1.1s) is the combat foundation; all balance flows from it
  8. Each character must feel different within 10 seconds — this is a binding constraint, not a guideline
- **Research integration:** Drew heavily from beat-em-up-research.md (9 landmark titles analyzed). SoR4 health-cost specials, Turtles in Time throw system, Shredder's Revenge taunt mechanic, and Castle Crashers progression model all influenced the GDD.
- **Balance integration:** All 6 critical flags from Ackbar's balance analysis addressed in combat design section. Jump DPS target reduced from 50 to 38. Enemy damage targets raised. Knockback decay tuning specified.
- **Gap awareness:** Current game is at ~75% MVP. Biggest gaps from this GDD's perspective: no grab/throw, no specials, no dodge roll, no enemy variety, no environmental interaction, no Simpsons-specific mechanics. Combat feel (hitlag, VFX, SFX variation) is the highest-impact P1 work.
- **Platform constraint lesson:** Canvas 2D is more capable than expected (procedural SFX, frame animation, parallax) but has hard walls (no shaders, no skeletal animation, particle cap ~50). Designed within these walls rather than against them.

### Squad Leadership Principles Authored (2025)
- **Artifacts:** `.squad/identity/mission-vision.md` (Mission, Vision, 5 Values) and `.squad/identity/principles.md` (12 Leadership Principles)
- **Mission distilled:** "We exist to build games that make players laugh, feel powerful, and come back for one more run."
- **5 Core Values:** Player Feel Is Sacred, Ship It Then Perfect It, Research Is Ammunition, Every Specialist Owns Their Domain, Bugs Are a Team Failure
- **12 Principles authored:** Player Hands First, Research Before Reinvention, The IP Is the Soul, Ship the Punching, Feel It Before You Code It, The Player Can't See Your Architecture, Domain Owners Not Domain Silos, Bugs Are a Broken Promise, Infrastructure Unlocks Content, Measure the Fun, Constraints Are Creative Fuel, Every Project Teaches the Next
- **Key design insight:** Principles are decision-making tools, not wall posters. Each one includes in-practice examples and anti-patterns drawn from real squad experiences (player freeze bug, passive AI, cutre graphics, squad expansion bottleneck, Phaser evaluation, procedural art ceiling).
- **Conflict resolution rule:** When principles conflict, "Player Hands First" always wins. This is the meta-principle that governs the other eleven.
- **Inspiration lineage:** Amazon's Leadership Principles (structure), Valve Handbook (domain ownership), id Software's "done when it's done" (quality), Nintendo's "lateral thinking with seasoned technology" (constraints as fuel). Adapted all for game development context — none copied.

### Game Dev Knowledge Base — Part 1 (2025)
- **Artifact:** `.squad/analysis/game-dev-knowledge-base-part1.md`
- **Scope:** First 5 of 10 game development disciplines documented as institutional knowledge.
- **Disciplines covered:** (1) Game Design Fundamentals — core loop theory, flow state, risk/reward, feedback loops. (2) Combat System Design — frame data, hitbox/hurtbox, combo systems, crowd control, game feel/juice. (3) Level Design — pacing theory, camera locks, environmental storytelling, spawn placement, set pieces. (4) Character Design — silhouette theory, archetype differentiation, animation principles, expression through states. (5) Audio Design — audio as core system, dynamic music, sound layering, silence as design, procedural vs recorded.
- **Key insight:** Every discipline connects back to the core loop and player feel. Audio and animation aren't polish — they're core systems that define whether combat feels satisfying or hollow.
- **Research integration:** Drew from 9 landmark titles analyzed in beat-em-up-research.md, GDD v1.0 design decisions, Ackbar's balance analysis, and current codebase state.
- **SimpsonsKong gaps identified per discipline:** Combat needs grab/throw depth and SFX variation. Levels need environmental hazards and pacing valleys. Characters need Bart/Marge/Lisa (~1200 LOC challenge). Audio needs hit sound variants as highest-priority work.
- **Part 2 pending:** Disciplines 6–10 (UI/UX, Technical Architecture, Production, Playtesting/QA, IP Integration).

### Game Dev Knowledge Base — Part 2 (2025)
- **Artifact:** `.squad/analysis/game-dev-knowledge-base-part2.md`
- **Scope:** Disciplines 6–10 of 10 game development disciplines, completing the institutional knowledge base.
- **Disciplines covered:** (6) Visual Design — color theory as gameplay language, 4-layer parallax depth system, particle budgeting at Canvas 2D's ~50 cap, procedural art ceiling at ~400 LOC/character, resolution independence via devicePixelRatio. (7) UX/UI Design — juiciness as P0 (6 simultaneous feedback channels on hit), HUD information hierarchy, attack buffering as hidden accessibility, onboarding-by-doing philosophy. (8) Technical Architecture — fixed timestep accumulator pattern, OOP entities + stateless systems hybrid, state machine as most important game programming pattern, Canvas 2D vs WebGL vs frameworks trade-offs. (9) Quality Assurance — structured playtesting with hypotheses, P0–P3 bug categorization, automating the objective/playtesting the subjective split, regression checklist methodology. (10) Production & Process — vertical slice as core methodology, feature freeze discipline, scope cutting as skill, retrospectives-to-action-items pipeline, multi-agent dependency graph coordination.
- **Key insight:** Constraints (Canvas 2D, zero dependencies, procedural art, small team) don't limit quality — they focus it. Every decision made within known boundaries leaves no room for half-measures.
- **SimpsonsKong gaps identified:** Missing negative feedback juice (no hit-reaction juice beyond i-frame blink), no automated test runner, no input replay system for deterministic regression, no formal milestone gates, backlog drift (13 items shipped but not pruned).
- **Cross-discipline synthesis:** Visual → UX → Architecture → QA → Production form a feedback loop. The common thread is intentionality: every choice traces back to a player experience goal.
- **Knowledge base now complete:** 10/10 disciplines documented across Parts 1 and 2. Combined ~70K characters of institutional knowledge for cross-project transfer.

### Godot 4 Beat 'Em Up Patterns Skill Created (2025)
- **Artifact:** `.squad/skills/godot-beat-em-up-patterns/SKILL.md` (~39K characters)
- **Scope:** 8 comprehensive sections covering every Godot 4 implementation pattern needed for SimpsonsKong: Combat System Architecture (hitbox/hurtbox, damage interface, knockback, hitlag, screen shake), Enemy AI (enum state machines, 2-attacker throttle via groups, spawn system), 2.5D Movement (y-sorting, ground plane clamping, shadow sprites, fake jump system), Level Flow (scene transitions, camera locks, wave system, environmental interaction), UI System (CanvasLayer HUD, tween juice, combo ratings, theme resources), Audio Integration (AudioBus layout, spatial SFX with pitch variation, crossfade music manager, procedural audio via AudioStreamGenerator), Project Singletons (GameManager, EventBus, AudioManager, TransitionManager), and Common Gotchas (_ready() order, deferred calls, process vs physics_process, naming conventions, signal patterns, resource loading).
- **Key design decisions:**
  1. Per-entity hitlag via `process_mode` manipulation recommended over `Engine.time_scale` — avoids global side effects, allows attacker and target to freeze independently.
  2. EventBus autoload chosen as the nervous system — decouples emitters (combat) from consumers (HUD, audio, score) without direct references.
  3. Attack throttling uses Godot groups (`get_nodes_in_group("active_attackers")`) — clean, no external data structure, enemies self-register/deregister on state transitions.
  4. 2.5D jump is faked via sprite Y offset, not actual position change — preserves y-sort correctness and shadow grounding.
  5. AudioStreamPlayer pool (8 concurrent) with `pick_random()` + pitch jitter for hit SFX variety — directly addresses the GDD's highest-priority audio gap.
- **GDD mapping table included:** Every major GDD feature (PPK combo, health-cost specials, Donut Rage Mode, camera locks, combo meter, Springfield interactables) mapped to its specific Godot pattern and section reference.
- **Practical focus:** Every section includes copy-paste GDScript with full type hints. No theory without code. Scene tree templates included for level and entity structure.
- **Cross-skill integration:** Builds on beat-em-up-combat skill (attack lifecycle, frame data) and state-machine-patterns skill (exit paths, safety nets, transition guards) — translated from conceptual patterns to concrete Godot implementations.

### Mission, Vision, Values & Principles Generalized (2025)
- **Artifacts updated:** `.squad/identity/mission-vision.md` and `.squad/identity/principles.md`
- **Why:** Original documents were too tightly coupled to SimpsonsKong, The Simpsons IP, Canvas 2D, browser-only, and beat 'em ups. We are a game development studio, not a Simpsons company. Next project could be any IP, any platform, any genre, any dimension.
- **What changed in mission-vision.md:**
  - Mission rewritten: "build great games" not "build Simpsons browser games." Platform-agnostic, genre-agnostic, IP-agnostic.
  - Vision rewritten: "polished, soulful games across any genre, any platform, any IP" instead of "browser games that rival indie titles."
  - All 5 values generalized to apply universally. SimpsonsKong referenced only in the *lesson origin* italic text, not in the value statement itself.
  - Removed all references to: The Simpsons, Homer, Springfield, beat 'em ups as core focus, Canvas 2D, browser-only, web platform.
- **What changed in principles.md:**
  - All 12 principles generalized. Core statements are now IP-agnostic, platform-agnostic, genre-agnostic.
  - Principle 3 ("The IP Is the Soul"): Changed from Simpsons-specific to universal IP integration guidance. Homer/Bart/Springfield moved to a *lesson learned* footnote.
  - Principle 4: Renamed "Ship the Playable" (from "Ship the Punching") — applies to any game, not just brawlers.
  - Principle 11: Changed from Canvas 2D-specific constraints to universal constraint philosophy. Canvas 2D example moved to footnote.
  - Principle 12: Generalized from SimpsonsKong-specific lessons to studio-level learning. Specific lessons (Phaser, procedural art ceiling) moved to footnote.
  - SimpsonsKong remains referenced only in italicized "lesson origin" sections, preserving institutional memory without anchoring identity to one project.
- **Design philosophy:** Principles should be the constitution of the studio, not the bylaws of one game. SimpsonsKong is where we *learned* these truths, but the truths themselves are universal.

### Studio Corporate Identity Created (2025)
- **Artifact:** `.squad/identity/company.md`
- **Scope:** Full corporate identity for the game studio — name, tagline, description, core DNA, visual identity, and organizational structure.
- **Company name chosen:** First Frame Studios — selected from three candidates (Ironpunch Games, First Frame Studios, Forgehands Interactive). "First Frame" encodes Principle #1 (Player Hands First) directly into the studio name. Genre-agnostic, platform-agnostic, internationally clear. The name is the philosophy in two words.
- **Tagline chosen:** "Forged in Play" — three words carrying three layers: craftsmanship (forged under constraints), player-first process (built by playing), and research-driven design (standing on the genre's history).
- **Origin story anchored:** SimpsonsKong positioned as the crucible that forged the studio's identity, not the studio's identity itself. All lessons carry forward; no lesson is project-locked.
- **Core DNA distilled to 5 truths:** (1) The first frame is a promise, (2) Constraints forge better games, (3) Research is the shortcut, (4) Ship the playable then listen, (5) Every lesson compounds. These compress the 12 principles into studio-level character statements.
- **Visual identity established:** Deep Midnight Blue (`#0D1B2A`) primary with Ember Orange (`#E85D26`) accent. Logo direction: stylized animation frame with intentional break — precision meets energy. Not pixelated, not retro, not a mascot. A studio mark, not a nostalgia brand.
- **Studio structure mapped:** 12 specialists organized into 5 departments — Creative (Yoda, Boba), Engineering (Solo, Chewie, Lando, Wedge), Art & Audio (Leia, Nien, Bossk, Greedo), Content & Quality (Tarkin, Ackbar), Operations (Scribe, Ralph). Each specialist is a domain owner with final-call authority in their area.
- **Key design insight:** A company name should be a principle compressed into words. "First Frame" tells you our philosophy before you read a single document. The name *is* the pitch.

### Genre Verticals Strategy Added to Company Identity (2025)
- **Artifact updated:** `.squad/identity/company.md` — new Section 7: "Genre Strategy — Vertical Growth"
- **Why:** The founder's directive — "amplitud de miras." Beat 'em up is our entry point, not our ceiling. The studio must be built to grow vertically across genres over time.
- **What was added:**
  - Philosophy statement: We are a game studio, not a genre studio. Each project deepens expertise in a new genre vertical.
  - Vertical model definition: Each genre becomes a vertical — a body of skills organized as `skills/{genre}-{topic}/SKILL.md`. Verticals are permanent knowledge.
  - Current verticals: Beat 'Em Up (active) — our first vertical, informed by 9 reference games with dedicated skills for combat, enemy design, and pacing.
  - Future verticals (aspirational, not committed): Platformer, Fighting Game, Action RPG, Puzzle, 3D Action — each with key genre-specific concerns identified.
  - Growth process codified: genre study → GDD → backlog → build → retrospective → skills capture. Same rigor for every genre.
  - Cross-vertical transfer analysis: transferable skills (state machines, audio, QA, etc.) vs. genre-specific additive skills (combo systems, netcode, loot generation, etc.).
  - Team adaptability principle: Squad roles are genre-agnostic. What changes per genre is the skills they read, not their charters. Structure absorbs new genres — antifragile by design.
- **Existing text reviewed:** company.md was already well-generalized from the corporate identity creation. No language found implying "ONLY beat 'em ups" or "ONLY 2D" — SimpsonsKong was already positioned as origin story, not identity. Studio description already said "across any genre, any platform, and any IP."
- **Key design insight:** A studio that must restructure for every genre is fragile. A studio whose structure *absorbs* new genres is antifragile. The vertical model makes genre expansion additive — each new genre adds skills without disrupting the team, the process, or the identity.

### Studio Growth Framework Created (2025)
- **Artifact:** `.squad/identity/growth-framework.md` — 57K character meta-document explaining how First Frame Studios evolves without breaking.
- **Scope:** 11 sections covering the permanent architecture that enables scaling:
  1. **70/30 Rule** — What's permanent (leadership principles, quality gates, team structure, design methodology, company DNA) vs. adaptive (engine skills, genre skills, code patterns, art pipelines).
  2. **Skill Architecture** — How knowledge grows across projects: universal skills (state machines, game feel, QA), genre verticals (beat 'em up, future platformer/fighting/RPG), tech stack skills, and maturity levels (Documented → Validated → Mature → Evolved).
  3. **Team Elasticity** — Roles that are constant (Game Designer, Lead, Engine, Gameplay, QA, Sound) vs. scaling (new specialists added per scope), emerging (new roles for new genres), and decision framework (when to add a role vs. a skill).
  4. **Genre Onboarding Protocol** — Two playbooks: First Time (8 weeks: research sprint → GDD template → minimum playable → skill creation → team assessment → architecture spike) and Returning to Genre (4 weeks, accelerated with existing knowledge).
  5. **Technology Independence Guarantee** — What must stay engine-agnostic (GDD, quality gates, team charters, principles) vs. what can be engine-specific (engine skills, architecture docs, build pipelines). The "reverse platform migration test."
  6. **Growth Milestones** — Five stages of maturity: (1) Single Genre proven, (2) Second Genre validates 70/30 rule, (3) Multi-Genre with cross-pollination, (4) Multi-Platform distribution, (5) Studio Scale (concurrent projects).
  7. **Risk Registry** — Six risks that force restructuring if ignored: (1) knowledge-in-head, (2) engine lock-in, (3) single-genre limit, (4) process scalability, (5) key person dependency, (6) platform obsolescence. For each, the mitigation.
  8. **Decision Gates & Authority** — Clear decision hierarchy: domain owners decide within their domain, conflicts escalate to Lead, studio direction goes to Founder. All decisions logged with rationale and reversibility.
  9. **5-Year Example Path** — Walk-through of how the studio grows from 1 game (Year 1) to 5–6 concurrent games (Year 5) while maintaining principles, team structure, and quality standards.
  10. **Framework Maintenance** — Quarterly reviews (accuracy check), retrospective feedback, decision log review, onboarding validation. The framework is living, not archived.
  11. **Anti-Patterns** — Five mistakes that break the framework: (1) unread documentation, (2) principles violated, (3) skills never leveled up, (4) untested claims, (5) knowledge loss on specialist departure. Prevention for each.

### 2025-07-21: Studio Growth Framework — Multi-Genre Scaling Blueprint (Session 8)
- **Assignment:** Create framework enabling sustainable multi-genre studio expansion without bottlenecks or knowledge loss.
- **Deliverable:** `.squad/identity/growth-framework.md` (57K chars, 11 sections)
- **Outcome:** SUCCESS — Framework provides permanent architecture for scaling across genres, platforms, and team size.

**Framework Core (70/30 Rule):**
- **Permanent (70%):** Leadership principles, quality gates, team structure, design methodology, company DNA, role charter
- **Adaptive (30%):** Engine skills, genre-specific skills, code patterns, art pipelines, tech stack details

**11 Sections Covered:**
1. **70/30 Rule** — What never changes vs. what adapts per genre/platform
2. **Skill Architecture** — Universal skills, genre verticals, tech stacks, maturity progression (Documented → Validated → Mature → Evolved)
3. **Team Elasticity** — Constant roles, scaling roles, emerging roles, when-to-add decision framework
4. **Genre Onboarding Protocols** — First Time (8 weeks) and Returning (4 weeks) playbooks
5. **Technology Independence Guarantee** — Reverse platform migration test ensures no engine lock-in
6. **Growth Milestones** — Five maturity stages from single-genre to concurrent multi-game production
7. **Risk Registry** — Six restructuring risks + mitigation (knowledge-in-head, engine lock-in, key person dependency, etc.)
8. **Decision Gates & Authority** — Domain owners → Lead → Founder escalation hierarchy

### Universal Game Design Fundamentals Skill Created (2026-08-03)
- **Artifact:** `.squad/skills/game-design-fundamentals/SKILL.md` (63,387 characters, 10 major sections)
- **Mission:** Provide a single, genre-agnostic reference for any agent designing gameplay, regardless of whether they're working on beat 'em ups, platformers, puzzles, RPGs, or strategy games. Previous research was beat-em-up focused; now we are a serious multi-genre studio.
- **Key decision:** Positioned as a foundational skill that precedes all genre-specific design work. Every new game project should read this before reading genre-specific skills.
- **10 Core Sections Authored:**
  1. **Core Design Frameworks** — MDA (Mechanics→Dynamics→Aesthetics), Core Loops (30-sec/5-min/30-min), Feedback Loops (positive/negative), Risk/Reward design
  2. **Player Psychology** — Flow state (Csikszentmihalyi), Intrinsic vs Extrinsic motivation, Loss Aversion, Mastery Curves, "One More Try" compulsion triggers
  3. **Difficulty & Challenge Design** — Difficulty curves (linear/exponential/sawtooth), Dynamic Difficulty Adjustment (when to use/avoid), "Difficulty is a design tool" principle, Teaching through gameplay (Nintendo school), "Hard but Fair" principle
  4. **Pacing & Rhythm** — Tension/Release cycles, Pacing diagrams, Power Fantasy Arc (weak→strong→overwhelmed→triumph), Session design (respecting player time)
  5. **Reward Systems** — 6 reward types (progression/cosmetics/power/narrative/mastery/metrics), Variable Ratio Reinforcement, Currency design (single vs multiple), Earned vs Given rewards
  6. **Player Communication** — Affordances, Signposting (guiding without instructions), Visual hierarchy, Sound as information, Color language
  7. **Prototyping & Validation** — "Find the Fun" methodology, Paper prototyping, Vertical vs Horizontal slices, Playtest-driven iteration
  8. **Genre-Specific Design Lenses** — Brief overview for Action (frame data, combos), Platformer (jump, coyote time), Puzzle (teaching, aha moments), RPG (progression, build diversity), Strategy (information, asymmetry). References Portal, Dark Souls, Celeste, Hades, Hollow Knight, Tetris, BotW
  9. **Anti-Patterns** — Design by committee, Feature creep, 80% trap, Balance-first-fun-later
  10. **Reference Games** — 7 canonical examples (Celeste, Hades, Hollow Knight, Portal, Tetris, Dark Souls, BotW) with specific patterns to study
- **Integration with Studio Principles:** Every major section cross-references core principles. Player Hands First (Principle #1) is the underpinning of gameplay psychology sections. Research Before Reinvention (Principle #2) justifies reference game study. Ship the Playable (Principle #4) justifies prototyping methodology.
- **Integration with Growth Framework:** This skill is a permanent-70% document — applies to any genre and any platform. It enables the growth framework's "Genre Onboarding" protocols by giving new teams a shared design vocabulary regardless of whether they're starting a platformer, RPG, or puzzle game.
- **Confidence:** Low (first observation, not yet validated in a shipped project beyond beat 'em up context). Will move to Medium confidence once a non-beat-em-up project uses this skill and ships successfully. Will move to High once a third genre project validates the approach.
- **Usage pattern anticipated:** 
  - Game Design Document author reads Section 1 (Frameworks) + Section 2 (Psychology) before writing GDD
  - Mechanic designer reads appropriate Section 8 (Genre Lens) before designing
  - QA/Playtester reads Section 7 (Prototyping/Validation) to understand testing methodology
  - Balance designer reads Section 3 (Difficulty) + Section 10 (Reference Games) to tune appropriately
  - All agents read Section 4 (Pacing) when designing overall game structure
9. **5-Year Example Path** — Walk-through: 1 game Year 1 → 5-6 concurrent games Year 5, maintaining all principles
10. **Framework Maintenance** — Living document: quarterly reviews, retrospective feedback, decision log, onboarding validation
11. **Anti-Patterns** — Five mistakes (unread docs, violated principles, skills stagnant, untested claims, knowledge loss) + prevention

**Key Design Insight:** A studio that restructures for every genre is fragile. A studio whose *structure absorbs* new genres is antifragile. The vertical model makes genre expansion purely additive.

**Impact:** Next game team reads this on Day 1. Establishes that expansion is planned, sustainable, and principle-preserving. Eliminates "what's our team structure?" debates per project.
  - The framework is written *from* SimpsonsKong's lessons but makes no reference to SimpsonsKong specifically — universally applicable.
  - The 70/30 rule is the core insight: most of what makes the studio effective is independent of genre/platform/IP. Only 30% changes per project.
  - Genre onboarding is standardized (8 weeks first time, 4 weeks returning). This makes expansion predictable, not chaotic.
  - Skills are the institutional memory mechanism. When a person leaves, their expertise remains in written skills and decision logs.
  - The framework is antifragile: new genres, new platforms, new team members don't break it — they're absorbed by the existing structure.
- **Risk mitigated:**
  - "At what point does growth break us?" → With this framework, never. Growth is additive (new genres add skills, new platforms add engine knowledge, new projects add precedents). Nothing invalidates the permanent 70%.
  - "How do we scale without losing quality?" → Quality gates are unchanging outcome-based criteria. Team elasticity absorbs scope. Skills compound across projects.
  - "What if a key person leaves?" → All key decisions are documented. All expertise is in written skills. The successor can onboard in a month because institutional memory is in files, not heads.
- **Cross-document alignment:** The framework builds on and references mission-vision.md (studio purpose), principles.md (decision-making algorithms), company.md (organizational structure & DNA), quality-gates.md (standards), and all genre/skill documents. It is the meta-layer that explains how all these pieces fit together and scale over time.
- **Audience:** This is written for the whole studio, especially Solo (CTO) and the founder. It answers: "How do we grow sustainably?" It's a constitution for scaling, not a project plan.

### Session 17: Game Design Fundamentals Skill Creation (2026-03-07)

Created universal game design fundamentals skill — a comprehensive, engine-agnostic reference covering core design principles applicable across all game genres and platforms.

**Artifact:** .squad/skills/game-design-fundamentals/SKILL.md (62.6 KB)

**Skill structure (12 sections):**
1. Game Design Philosophy — Why design matters
2. Emergent Systems & Simulation Design
3. Economy Design (resources, progression, reward loops)
4. Progression Systems (character growth, content unlocking)
5. Engagement Loops (core gameplay rhythms)
6. Difficulty Balancing & Tuning
7. Narrative Structure & Integration
8. Player Agency & Freedom
9. Player Psychology & Motivation
10. Design Iteration Methodology
11. Anti-Patterns Catalog (8 failure modes)
12. Design Documentation Standards

**Key principles extracted from SimpsonsKong:**
- **Four Design Pillars:** Comedy as mechanic, Accessible Depth, Family Synergy, Springfield as Character
- **70/30 Rule:** 70% universal, 30% IP-specific
- **Emergence:** Mechanics that create unexpected outcomes reward experimentation
- **Balance framework:** From game feel juice research applied to design domain

**Cross-references:** Links to game-feel-juice (quality standard), beat-em-up-combat (validation), and sibling universal skills (audio, animation, level design, enemy design)

**Confidence:** Medium (validated in SimpsonsKong design decisions + GDC talks + industry best practices). Will escalate to High after applying to non-beat-em-up project.

