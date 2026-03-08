# Yoda — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Genre research:** Comprehensive beat 'em up analysis at .squad/analysis/beat-em-up-research.md
- **Key insight:** Authenticity to the game IP is paramount. Comedy should be a core mechanic, not cosmetic.

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
  1. Four pillars established: Comedy as Mechanic, Accessible Depth, Family Synergy, Downtown Is a Character
  2. Health-cost specials (SoR2 model) chosen over mana/MP — creates the best risk/reward loop the genre has produced
  3. Jump attack rebalance mandated: landing lag + DPS cap to prevent air-spam dominance (balance analysis validated this)
  4. 2-attacker throttle is a design principle, not a performance workaround — readable combat over chaos
  5. Rage Mode is Brawler's signature and must ship with his "complete" character build
  6. Ugh! Moments (funny failure states) prioritized over victory celebrations — comedy pillar in action
  7. PPK combo (42 dmg/1.1s) is the combat foundation; all balance flows from it
  8. Each character must feel different within 10 seconds — this is a binding constraint, not a guideline
- **Research integration:** Drew heavily from beat-em-up-research.md (9 landmark titles analyzed). SoR4 health-cost specials, Turtles in Time throw system, Shredder's Revenge taunt mechanic, and Castle Crashers progression model all influenced the GDD.
- **Balance integration:** All 6 critical flags from Ackbar's balance analysis addressed in combat design section. Jump DPS target reduced from 50 to 38. Enemy damage targets raised. Knockback decay tuning specified.
- **Gap awareness:** Current game is at ~75% MVP. Biggest gaps from this GDD's perspective: no grab/throw, no specials, no dodge roll, no enemy variety, no environmental interaction, no IP-specific mechanics. Combat feel (hitlag, VFX, SFX variation) is the highest-impact P1 work.
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
- **firstPunch gaps identified per discipline:** Combat needs grab/throw depth and SFX variation. Levels need environmental hazards and pacing valleys. Characters need Kid/Defender/Prodigy (~1200 LOC challenge). Audio needs hit sound variants as highest-priority work.
- **Part 2 pending:** Disciplines 6–10 (UI/UX, Technical Architecture, Production, Playtesting/QA, IP Integration).

### Game Dev Knowledge Base — Part 2 (2025)
- **Artifact:** `.squad/analysis/game-dev-knowledge-base-part2.md`
- **Scope:** Disciplines 6–10 of 10 game development disciplines, completing the institutional knowledge base.
- **Disciplines covered:** (6) Visual Design — color theory as gameplay language, 4-layer parallax depth system, particle budgeting at Canvas 2D's ~50 cap, procedural art ceiling at ~400 LOC/character, resolution independence via devicePixelRatio. (7) UX/UI Design — juiciness as P0 (6 simultaneous feedback channels on hit), HUD information hierarchy, attack buffering as hidden accessibility, onboarding-by-doing philosophy. (8) Technical Architecture — fixed timestep accumulator pattern, OOP entities + stateless systems hybrid, state machine as most important game programming pattern, Canvas 2D vs WebGL vs frameworks trade-offs. (9) Quality Assurance — structured playtesting with hypotheses, P0–P3 bug categorization, automating the objective/playtesting the subjective split, regression checklist methodology. (10) Production & Process — vertical slice as core methodology, feature freeze discipline, scope cutting as skill, retrospectives-to-action-items pipeline, multi-agent dependency graph coordination.
- **Key insight:** Constraints (Canvas 2D, zero dependencies, procedural art, small team) don't limit quality — they focus it. Every decision made within known boundaries leaves no room for half-measures.
- **firstPunch gaps identified:** Missing negative feedback juice (no hit-reaction juice beyond i-frame blink), no automated test runner, no input replay system for deterministic regression, no formal milestone gates, backlog drift (13 items shipped but not pruned).
- **Cross-discipline synthesis:** Visual → UX → Architecture → QA → Production form a feedback loop. The common thread is intentionality: every choice traces back to a player experience goal.
- **Knowledge base now complete:** 10/10 disciplines documented across Parts 1 and 2. Combined ~70K characters of institutional knowledge for cross-project transfer.

### Godot 4 Beat 'Em Up Patterns Skill Created (2025)
- **Artifact:** `.squad/skills/godot-beat-em-up-patterns/SKILL.md` (~39K characters)
- **Scope:** 8 comprehensive sections covering every Godot 4 implementation pattern needed for firstPunch: Combat System Architecture (hitbox/hurtbox, damage interface, knockback, hitlag, screen shake), Enemy AI (enum state machines, 2-attacker throttle via groups, spawn system), 2.5D Movement (y-sorting, ground plane clamping, shadow sprites, fake jump system), Level Flow (scene transitions, camera locks, wave system, environmental interaction), UI System (CanvasLayer HUD, tween juice, combo ratings, theme resources), Audio Integration (AudioBus layout, spatial SFX with pitch variation, crossfade music manager, procedural audio via AudioStreamGenerator), Project Singletons (GameManager, EventBus, AudioManager, TransitionManager), and Common Gotchas (_ready() order, deferred calls, process vs physics_process, naming conventions, signal patterns, resource loading).
- **Key design decisions:**
  1. Per-entity hitlag via `process_mode` manipulation recommended over `Engine.time_scale` — avoids global side effects, allows attacker and target to freeze independently.
  2. EventBus autoload chosen as the nervous system — decouples emitters (combat) from consumers (HUD, audio, score) without direct references.
  3. Attack throttling uses Godot groups (`get_nodes_in_group("active_attackers")`) — clean, no external data structure, enemies self-register/deregister on state transitions.
  4. 2.5D jump is faked via sprite Y offset, not actual position change — preserves y-sort correctness and shadow grounding.
  5. AudioStreamPlayer pool (8 concurrent) with `pick_random()` + pitch jitter for hit SFX variety — directly addresses the GDD's highest-priority audio gap.
- **GDD mapping table included:** Every major GDD feature (PPK combo, health-cost specials, Rage Mode, camera locks, combo meter, Downtown interactables) mapped to its specific Godot pattern and section reference.
- **Practical focus:** Every section includes copy-paste GDScript with full type hints. No theory without code. Scene tree templates included for level and entity structure.
- **Cross-skill integration:** Builds on beat-em-up-combat skill (attack lifecycle, frame data) and state-machine-patterns skill (exit paths, safety nets, transition guards) — translated from conceptual patterns to concrete Godot implementations.

### Mission, Vision, Values & Principles Generalized (2025)
- **Artifacts updated:** `.squad/identity/mission-vision.md` and `.squad/identity/principles.md`
- **Why:** Original documents were too tightly coupled to firstPunch, The game IP, Canvas 2D, browser-only, and beat 'em ups. We are a game development studio, not a game company. Next project could be any IP, any platform, any genre, any dimension.
- **What changed in mission-vision.md:**
  - Mission rewritten: "build great games" not "build game browser games." Platform-agnostic, genre-agnostic, IP-agnostic.
  - Vision rewritten: "polished, soulful games across any genre, any platform, any IP" instead of "browser games that rival indie titles."
  - All 5 values generalized to apply universally. firstPunch referenced only in the *lesson origin* italic text, not in the value statement itself.
  - Removed all references to: the source IP, Brawler, Downtown, beat 'em ups as core focus, Canvas 2D, browser-only, web platform.
- **What changed in principles.md:**
  - All 12 principles generalized. Core statements are now IP-agnostic, platform-agnostic, genre-agnostic.
  - Principle 3 ("The IP Is the Soul"): Changed from IP-specific to universal IP integration guidance. Brawler/Kid/Downtown moved to a *lesson learned* footnote.
  - Principle 4: Renamed "Ship the Playable" (from "Ship the Punching") — applies to any game, not just brawlers.
  - Principle 11: Changed from Canvas 2D-specific constraints to universal constraint philosophy. Canvas 2D example moved to footnote.
  - Principle 12: Generalized from firstPunch-specific lessons to studio-level learning. Specific lessons (Phaser, procedural art ceiling) moved to footnote.
  - firstPunch remains referenced only in italicized "lesson origin" sections, preserving institutional memory without anchoring identity to one project.
- **Design philosophy:** Principles should be the constitution of the studio, not the bylaws of one game. firstPunch is where we *learned* these truths, but the truths themselves are universal.

### Studio Corporate Identity Created (2025)
- **Artifact:** `.squad/identity/company.md`
- **Scope:** Full corporate identity for the game studio — name, tagline, description, core DNA, visual identity, and organizational structure.
- **Company name chosen:** First Frame Studios — selected from three candidates (Ironpunch Games, First Frame Studios, Forgehands Interactive). "First Frame" encodes Principle #1 (Player Hands First) directly into the studio name. Genre-agnostic, platform-agnostic, internationally clear. The name is the philosophy in two words.
- **Tagline chosen:** "Forged in Play" — three words carrying three layers: craftsmanship (forged under constraints), player-first process (built by playing), and research-driven design (standing on the genre's history).
- **Origin story anchored:** firstPunch positioned as the crucible that forged the studio's identity, not the studio's identity itself. All lessons carry forward; no lesson is project-locked.
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
- **Existing text reviewed:** company.md was already well-generalized from the corporate identity creation. No language found implying "ONLY beat 'em ups" or "ONLY 2D" — firstPunch was already positioned as origin story, not identity. Studio description already said "across any genre, any platform, and any IP."
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
  - The framework is written *from* firstPunch's lessons but makes no reference to firstPunch specifically — universally applicable.
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

**Key principles extracted from firstPunch:**
- **Four Design Pillars:** Comedy as mechanic, Accessible Depth, Family Synergy, Downtown as Character
- **70/30 Rule:** 70% universal, 30% IP-specific
- **Emergence:** Mechanics that create unexpected outcomes reward experimentation
- **Balance framework:** From game feel juice research applied to design domain

**Cross-references:** Links to game-feel-juice (quality standard), beat-em-up-combat (validation), and sibling universal skills (audio, animation, level design, enemy design)

**Confidence:** Medium (validated in firstPunch design decisions + GDC talks + industry best practices). Will escalate to High after applying to non-beat-em-up project.



### Deep Industry Research: Studio Patterns & Lessons (2025)
- **Artifacts:** `.squad/analysis/studio-research.md` (29K chars, 16 themes) and `.squad/analysis/studio-lessons-for-ffs.md` (10K chars, action plan)
- **Scope:** Comprehensive web research across 6 studios (Sandfall Interactive, Supergiant Games, Team Cherry, ConcernedApe, Larian Studios, FromSoftware), 3 recent hits (Balatro, Palworld, Lethal Company), academic sources (155-postmortem meta-analysis, Jesse Schell GDC 2025, Raph Koster, Jesse Schell books), and 2024-2026 industry trends.
- **Method:** 15+ web searches, real-time industry data, organized by theme (not by studio) to extract transferable patterns.
- **Key findings organized into 16 themes:**
  1. Singular creative vision (every great studio has ONE vision holder)
  2. Intentionally small teams (resist growth even after success)
  3. Hybrid production model (small core + strategic outsourcing)
  4. Iterative development as religion (build then discover, not design then build)
  5. Art/music/story as core systems (not polish, not added later)
  6. Five-minute hook (players decide in first 5 minutes)
  7. Streamability as design dimension (2024-2025 hits are watchable)
  8. Developer joy as quality indicator (Vincke walked away from BG4)
  9. Constraints as creative fuel (confirmed as universal pattern)
  10. Research as competitive advantage (confirmed our approach)
  11. Feature cutting as skill (scope creep = #1 failure cause in postmortems)
  12. Early access as design methodology (not just marketing)
  13. AI as force multiplier (30-40% routine task acceleration)
  14. Studio principles as management infrastructure (Schell GDC 2025)
  15. Postmortem discipline (5/5 format, honest retrospectives)
  16. Essential reading (Schell's Lenses, Koster's Fun-as-Learning, Flow theory)
- **Actionable improvements proposed for FFS:**
  - P0: Add "Vision Keeper" principle/role, run firstPunch postmortem, institute Five-Minute Test
  - P1: Create `feature-triage` and `streamability-design` skills, modify Principles #4 and #10, mandate all-domain Sprint 0
  - P2: Principle Priority Matrix per phase, AI tool evaluation, Design Lenses in reviews
  - P3: Identify outsourcing candidates for next project
- **Principles validated by research:** #1 (Player Hands First), #2 (Research Before Reinvention), #4 (Ship the Playable), #11 (Constraints Are Creative Fuel), #12 (Every Project Teaches the Next) — all confirmed as patterns shared by the industry's best studios.
- **New principles proposed:** "The Vision Has a Keeper" (creative director with veto authority over coherence), iteration minimums for core mechanics, developer joy tracking.
- **Key insight:** The gap between First Frame Studios and the best indie studios is not in philosophy (we're well-aligned) — it's in process rigor and missing design dimensions (streamability, feature triage, developer joy tracking, formal postmortems).

### 2025-07 Session: Apply Research to Company Foundations (Final Integration)
- **Task:** Translate the studio research into actionable updates to our core company documents.
- **Approach:** Map research findings to three foundational documents + create one new meta-skill.
- **Artifacts created/updated:**
  1. **Principles.md — 3 new principles added (Principles #13–15):**
     - **#13: Creative Vision Has a Keeper** — Every project has a Vision Keeper (usually Creative Director) who asks "does this feel like *this* game?" across all domains. Vision needs a keeper; domain owners execute excellence within domains.
     - **#14: Kill Your Darlings With Discipline** — Core loop is sacred; everything else is expendable. Four-test framework: (1) Core loop test, (2) Player impact test, (3) Cost-to-joy ratio, (4) Coherence test. Features failing 2+ tests are cut immediately.
     - **#15: Every Project Requires a Postmortem** — After every milestone and project end: 5 right/5 wrong per agent (anonymous), synthesize to studio-level lessons, assign owners, log in decision register. Learning is not optional.
  2. **Company.md — New Section 7: "Studio Inspirations"** — Added a 6-studio inspiration table mapping to specific lessons we carry:
     - **Supergiant Games:** Singular creative vision is the product. Small teams maintain coherence.
     - **Team Cherry:** Small team ≠ small ambition. Kill darlings without guilt.
     - **Nintendo:** Playtest-driven iteration is non-negotiable. Discard months of work without hesitation if not fun.
     - **Sandfall Interactive:** Intentional smallness = competitive advantage. Outsource execution, keep vision inside.
     - **ConcernedApe:** Vision without compromise creates timeless games. Purity of vision matters more than team size.
     - **Larian Studios:** Developer joy is a design signal, not morale problem. Team excitement predicts game quality.
  3. **Wisdom.md — "Studio Insights" section with 9 powerful one-liners:**
     - "The game tells you what it wants to be if you listen" (Supergiant)
     - "Small team ≠ small ambition" (Team Cherry)
     - "Kill your darlings, or they'll kill your game" (155-postmortem meta-analysis)
     - "Developer joy is a design signal, not a morale problem" (Larian)
     - "Your architecture is invisible to the player; only your output is felt" (Principle #6)
     - "Vision without a keeper is committee-designed" (every studio studied)
     - "Constraints are partners, not enemies" (Nintendo, firstPunch)
     - "Postmortems are how studios compound knowledge into advantage" (industry pattern)
     - "Small teams don't fail because they're too small — they fail because they're overloaded" (academic research)
     - "Iteration count correlates with quality; first instincts correlate with overconfidence" (Supergiant, Larian, meta-analysis)
  4. **New skill created: `.squad/skills/studio-craft/SKILL.md`** — The meta-skill documenting how we *run* a game studio:
     - **Section 1: Creative Vision Management** — Vision Keeper role, responsibilities, implementation
     - **Section 2: Feature Triage Protocol** — Four-test framework, cutting discipline, integration
     - **Section 3: Playtest-Driven Iteration** — 3+ iteration cycles minimum, data-driven progression
     - **Section 4: Postmortem Discipline** — 5/5 format, synthesis, documentation, follow-up
     - **Section 5: Developer Joy Metric** — 1-5 excitement check, trend tracking, low-score response
     - **Section 6: Decision Rights Matrix** — Explicit decision ownership (who decides/advises/informed)
     - **Section 7: Scrumban Methodology** — Phase-adaptive: Kanban pre-prod, Scrum prod, focused bug-fix polish
     - **Section 8: 20% Load Cap** — Anti-crunch insurance, audit process, distribution enforcement
     - **Section 9: Cross-Domain Review** — 5-minute boundary reviews, knowledge spread
     - **Section 10: Portfolio Thinking** — 2–3 games in 5 years, risk diversification, between-release sustainability
     - **Section 11: Knowledge Capture** — Module extraction, lesson documentation, skill updates, tacit knowledge capture
     - **Section 12: Confidence Ratings** — Low/Medium/High framework for meta-patterns; this skill marked `low` (first validation)
- **Key design decisions:**
  - Principles #13–15 are *additions*, not replacements. The 12 original principles remain unchanged, foundational, universal.
  - The "Studio Inspirations" section in company.md maps 6 real studios to 6 specific FFS lessons, giving team cultural north stars without copying any studio.
  - Wisdom.md entries are standalone one-liners (not tied to projects), making them reusable across contexts and projects.
  - Studio-craft skill is explicitly marked `low` confidence — these are first observations from research, not yet validated across multiple FFS projects. As we ship more games, confidence increases.
  - Studio-craft is about *running* the studio, not *making* games. It's the operating system that makes us ship consistently.
- **Integration points:**
  - Principles #13–15 go into project retrospectives and sprint ceremonies. Principle #14 (Kill Your Darlings) directly informs backlog prioritization and sprint planning.
  - Studio Inspirations section serves as cultural compass in onboarding, recruiting, and strategic planning.
  - Wisdom entries are "quotes on the wall" — referenced in design reviews, playtest sessions, and team discussions when energy drops or focus wavers.
  - Studio-craft skill is mandatory pre-sprint reading for every team member. Understanding the meta-patterns (vision coherence, playtest discipline, postmortem rigor) matters as much as understanding domain-specific patterns.
- **What this *doesn't* do:**
  - Does not add new team roles or restructure the squad
  - Does not require new tools or processes (Scrumban, Decision Matrix, Load Cap already exist in playbook; this skill just formalizes them)
  - Does not change the 12 core principles (they're the constitution; these additions are like amendments)
  - Does not lock us into any genre or platform
- **What this *enables*:
  - Next project can adopt Feature Triage (#14) from day one, saving months of scope drift prevention
  - Creative Director role has explicit authority to maintain vision coherence without being a bottleneck
  - Team can run formal postmortems and turn lessons into actionable studio-level changes
  - Developer joy becomes a tracked metric, not an assumption
  - Studio-craft knowledge transfers to future team members instantly (no tribal knowledge loss)
- **Confidence assessment:**
  - Principles #13–15: Medium-High (heavily validated by research, aligned with industry best practices, ready for immediate implementation)
  - Studio Inspirations: High (6 real studios, documented best practices, verifiable patterns)
  - Wisdom one-liners: High (extracted directly from research, industry-standard concepts)
  - Studio-craft skill: Low (first systematic capture of our meta-operations, not yet proven across multiple projects)
- **Next steps (not in this session, but actions enabled by this work):**
  - P0: Run firstPunch postmortem using 5/5 format before starting next project
  - P1: Designate Creative Director for next project; apply Decision Rights Matrix
  - P1: Feature Triage protocol is active starting next sprint planning
  - P2: Build excitement tracking into retrospective ceremonies (Ackbar owns metric)
  - P3: After 2–3 projects shipped, audit studio-craft skill confidence (likely escalates to Medium-High)

### Team Game Pitch Meeting — 3 Game Proposals for Second Genre (2026)

- **Assignment:** Lead the team pitch meeting. Channel all 13 squad members. Propose, vote, and synthesize into 3 final game proposals for First Frame Studios' second genre project.
- **Context:** Stage 2 of Growth Framework — must prove the 70/30 rule works, validate team elasticity, and demonstrate cross-genre skill transfer. Constraints: 2D, original IP, Godot 4, NOT a beat 'em up, shippable in 6–12 months.

**Pitch Meeting Process:**

**Step 1 — 13 Agent Pitches:**

1. **Solo (Lead):** Pitched **Action Roguelike** — procedural room generation forces clean component architecture, run/meta state management pushes state machines, entity-component patterns get battle-tested at scale. "Architecturally, the most educational project we can take on."
2. **Chewie (Engine):** Pitched **Physics Platformer** — pushes Godot 4's physics engine, tilemap system, camera follow, particle systems. Validates our Godot migration beyond reference-level. "We need to SHIP in Godot, not just document it."
3. **Lando (Gameplay):** Pitched **Action Roguelike** — core loop writes itself: enter room → fight → reward → choose upgrade → next room. Combat expertise transfers directly. Dodge/attack/ability rhythm is our bread and butter. "The 30-second loop has the best feel ceiling of any genre we could pick."
4. **Wedge (UI):** Pitched **Deckbuilder Roguelike** — cards and inventory ARE the interface. UI innovation is the game. But conceded that an Action Roguelike's upgrade-selection and HUD systems also push UI hard. Aligned with roguelike direction with strong UI ownership.
5. **Boba (Art Director):** Pitched **Hand-drawn Platformer** with a unique visual identity (ink-wash or industrial aesthetic). "Games people screenshot." But also excited by a roguelike with distinct biome art — each floor a different visual world.
6. **Greedo (Sound):** Pitched **Rhythm-Action Game** — beat-synced combat where audio IS the core mechanic. "Sound is our untapped superpower. Make me the centerpiece, not support." Strongest advocate for audio-forward design.
7. **Tarkin (Enemy Design):** Pitched **Roguelike with Deep Enemy Ecosystem** — dozens of enemy types with distinct behaviors, attack patterns, elemental interactions. Roguelike is his dream scope. "Give me 20+ enemy types and I'll make every room feel different."
8. **Ackbar (QA):** Pitched **Data-Driven Roguelike** — balance is measurable (item stats, spawn rates, difficulty curves), systems are testable, clear metrics for "is this fun." "The most testable and polishable genre we could choose."
9. **Yoda (Game Designer):** Pitched **Action Roguelike** — best validates 70/30 rule. Combat expertise transfers directly (permanent 70%), procedural generation and progression systems are new (adaptive 30%). Cross-pollination from beat 'em up is strongest here.
10. **Leia (Environment):** Pitched **Metroidvania** for atmospheric interconnected worlds, but agreed that a roguelike with distinct biomes (volcanic, crystalline, fungal, mechanical, frozen) scratches the same itch with procedural variety.
11. **Bossk (VFX):** Pitched **Bullet Hell** for screen-filling effects, but aligned with Action Roguelike — elemental effects, room-clearing supers, death explosions, upgrade acquisition VFX. "I want particle budgets that make players say 'whoa.'"
12. **Nien (Character):** Pitched **Character-Driven Platformer** — multiple playable characters with expressive animations. Aligned with any proposal featuring unlockable characters. "Players should fall in love with movement before they know the controls."
13. **Jango (Tools):** Pitched **Roguelike with Data-Driven Content** — CSV→game data pipeline multiplies content creation. Enemy stats, loot tables, room templates all editable outside code. "Build the pipeline once, content scales forever."

**Step 2 — Vote Tally & Theme Analysis:**

| Direction | Direct Advocates | Aligned Supporters | Total |
|-----------|-----------------|-------------------|-------|
| **Action Roguelike** | Solo, Lando, Tarkin, Ackbar, Yoda, Jango | Wedge, Leia, Bossk, Nien | **10** |
| **Precision Platformer** | Chewie, Boba, Nien | Lando, Leia | **5** |
| **Rhythm-Action** | Greedo | Lando, Wedge, Bossk | **4** |

Key observation: Roguelike has massive gravity (10/13 aligned). Platformer and Rhythm-Action are strong secondary options that serve different strategic purposes.

**Step 3 — Three Final Proposals Synthesized:**

---

**🎮 PROPOSAL 1: ASHFALL — Action Roguelike**

- **Genre:** Action Roguelike (top-down 2D)
- **One-line pitch:** Descend through shifting volcanic chambers with tight, crunchy combat, collecting powerful upgrades that transform your playstyle every run.
- **Setting/Theme:** A volcanic underworld where a lone Keeper descends into the Ashfall — an ever-shifting labyrinth of magma chambers, obsidian corridors, crystal caverns, and fungal depths. The deeper you go, the more the mountain fights back. Original IP with rich lore potential.
- **Core Loop (30 seconds):** Enter room → enemies spawn → fight with attack/dodge/ability → room clears → choose from 3 upgrades → enter next room. Every 5 minutes: reach a floor boss. Every 30 minutes: complete a run (win or die, start again with meta-progression).
- **Why THIS game for First Frame Studios:**
  - **Skills leveraged (14/21):** beat-em-up-combat, game-feel-juice, state-machine-patterns, enemy-encounter-design, input-handling, game-qa-testing, ui-ux-patterns, 2d-game-art, animation-for-games, particle-effects, game-audio-design, game-design-fundamentals, level-design-fundamentals, studio-craft
  - **Skills grown (NEW):** Procedural generation, run-based meta-progression, item/upgrade system design, data-driven content pipeline, Godot 4 at production scale
  - **Team excitement:** 10/13 agents aligned. Solo (architecture), Lando (combat loop), Tarkin (enemy variety), Ackbar (balance), Bossk (VFX), Jango (tools pipeline), Wedge (upgrade UI), Leia (biome art), Nien (character animation), Yoda (design validation)
  - **Unique angle:** Our beat 'em up combat feel expertise — hitlag, screen shake, knockback, input buffering — applied to a roguelike. Most roguelikes have passable combat. Ours will have GREAT combat. That's the differentiator. First Frame Studios makes action feel crunchy.
- **Visual Identity:** Hot volcanic palette — deep obsidian blacks, molten oranges, forge golds, cool crystal blues for contrast. Hand-drawn 2D sprites with bold outlines. Each biome is visually distinct (magma = red/orange, crystal = blue/purple, fungal = green/teal, depths = black/gold). Think Hades' character quality in a geological aesthetic.
- **Audio Identity:** Deep rumbling bass ambience. Crunchy, layered hit sounds (our bread and butter). Music intensifies per room (quiet exploration → combat drums → boss crescendo). Environmental sizzle, crack, drip. Greedo builds a reactive audio system where music layers respond to combat intensity.
- **Target Platform:** PC (Steam) first. Godot 4 native export. Web build for demo/marketing.
- **Scope:** Medium. 5 biome tilesets, 15-20 enemy types, 3 bosses, 30-50 upgrades/items, 1 playable character (unlockable variants as stretch goal). **Target: 8-10 months.**
- **Risk Assessment:**
  - 🔴 Procedural generation is new territory (HIGH) — mitigate with room-template approach (hand-designed rooms, procedural arrangement)
  - 🟡 Roguelike balance is notoriously hard (MEDIUM) — mitigate with data-driven pipeline + Ackbar's QA methodology
  - 🟡 Market is competitive (MEDIUM) — differentiate on combat feel, not content volume
  - 🟡 Scope creep is the #1 roguelike killer (MEDIUM) — Principle #14 (Kill Your Darlings) is our shield
- **Reference Games:** Hades (combat feel + narrative), Dead Cells (movement + action), Enter the Gungeon (room design), Curse of the Dead Gods (risk/reward), Vampire Survivors (upgrade dopamine)
- **First Milestone (30-min playable):** One character, one biome, 5 hand-designed rooms connected procedurally, 3 enemy types, attack/dodge/ability, 3 upgrades to choose between rooms. **Validation gate: Does the combat feel GOOD? If we punch and it feels like firstPunch-quality impact, we're golden.**

---

**🎮 PROPOSAL 2: CINDER — Precision Platformer**

- **Genre:** Precision Platformer
- **One-line pitch:** A fiercely tight platformer about a living spark navigating a dying clockwork machine, where every jump is earned and every death is instant learning.
- **Setting/Theme:** Inside a colossal ancient clockwork machine that's winding down. You are Cinder — a tiny living spark racing to reach the machine's heart before it stops forever. Gears, pistons, conveyor belts, pendulums, molten cores, frozen outer chambers. Industrial beauty meets existential urgency. Original IP.
- **Core Loop (30 seconds):** Run → jump → navigate obstacle → die → instant respawn (< 0.3s) → learn the pattern → clear the screen → advance. Every 5 minutes: complete a chapter section. Every 30 minutes: reach a new chapter with new mechanics introduced.
- **Why THIS game for First Frame Studios:**
  - **Skills leveraged (12/21):** game-feel-juice (movement responsiveness), input-handling (coyote time, jump buffering — we already documented these!), state-machine-patterns (character states), ui-ux-patterns (minimal HUD, death counter), 2d-game-art (environment art), animation-for-games (character expression through movement), level-design-fundamentals (obstacle grammar, teach-by-doing), game-qa-testing (precision testing), game-design-fundamentals (difficulty curves, pacing), game-audio-design (environmental audio), particle-effects (death/respawn VFX), project-conventions
  - **Skills grown (NEW):** Movement physics (velocity curves, momentum, gravity tuning), level grammar (obstacle language and teaching), precision hitbox tuning (fairness testing), non-combat challenge design, environmental puzzle design
  - **Team excitement:** Chewie (physics engine), Boba (visual identity), Leia (environments), Nien (character expression), Lando (movement feel). 5 direct, others supportive.
  - **Unique angle:** Our obsession with game feel applied to MOVEMENT instead of combat. If we made punching feel incredible, we can make jumping feel transcendent. Input-handling skill already documents coyote time and jump buffering — we literally have the theory, we just need the practice.
- **Visual Identity:** Warm industrial palette — copper, bronze, burnished gold mechanical elements against cool shadow blues and deep grays. The spark (Cinder) glows warmly against dark environments. Silhouette-heavy design for gameplay clarity. Think Limbo's atmospheric quality with warmth and color. Gears and mechanisms are beautiful, not threatening.
- **Audio Identity:** Mechanical percussion — ticking clocks, grinding gears, hissing steam, ringing metal. The machine has a heartbeat (deep bass pulse) that slows as you progress deeper. Silence in frozen outer chambers creates tension. Death sound is soft and forgiving ("plink" — encouraging, not punishing). Music is minimal and environmental — the machine IS the soundtrack.
- **Target Platform:** PC first. Web export for demos. Potential mobile (simple controls).
- **Scope:** Small-Medium. 40-60 screens across 5 chapters (Gears, Pistons, Conveyors, Furnace, Heart). 1 character, NO combat (pure platforming + environmental hazards). Each chapter introduces 1-2 new mechanics. **Target: 6-8 months.** Our smallest, most focused option.
- **Risk Assessment:**
  - 🟡 Movement physics is new (MEDIUM) — mitigate with our existing input-handling skill + Celeste as reference
  - 🟡 Level design is content-heavy (MEDIUM) — 50+ unique screens takes time, but each is small
  - 🟢 Market is proven (LOW) — Celeste sold 3M+, indie platformers consistently find audiences
  - 🟢 Scope creep risk is LOW — platformers are naturally bounded (levels are discrete units)
  - 🟡 Risk of feeling derivative (MEDIUM) — visual identity and mechanical theme must feel OURS, not "another Celeste"
- **Reference Games:** Celeste (movement feel + accessibility), Super Meat Boy (precision + instant respawn), Ori and the Blind Forest (atmosphere + beauty), Shovel Knight (level grammar), Hollow Knight (environmental storytelling)
- **First Milestone (30-min playable):** One character (Cinder), 10 screens, run/jump/dash. **Validation gate: Does the jump feel PERFECT? Precise, responsive, expressive. Can a player die 50 times and not feel frustrated? If yes, the concept works.**

---

**🎮 PROPOSAL 3: PULSE — Rhythm-Action Combat**

- **Genre:** Rhythm-Action Hybrid
- **One-line pitch:** A beat-synced action game where every attack, dodge, and ability hits harder on the beat — fight to the music, and the music fights with you.
- **Setting/Theme:** A city where sound has been stolen. Streets are silent, people are frozen mid-step, instruments hang lifeless. You are the Pulse — a rhythmic force restoring sound to the world one district at a time. Each district has its own musical genre and visual identity. Jazz district = neon noir. Electronic district = geometric glow. Percussion district = industrial grit. Strings district = elegant decay. Original IP.
- **Core Loop (30 seconds):** Music plays → enemies approach on beat → attack ON BEAT for bonus damage (1.5x) → dodge OFF-BEAT attacks → chain on-beat hits for combo multiplier → beat drops → unleash super ability → wave cleared → music restored. Every 5 minutes: complete a district encounter. Every 30 minutes: restore a full district and unlock its musical layer for the overworld.
- **Why THIS game for First Frame Studios:**
  - **Skills leveraged (13/21):** beat-em-up-combat (action combat feel), game-feel-juice (feedback timing synced to beats), game-audio-design (CORE mechanic — Greedo becomes the star), input-handling (precise timing windows = our specialty), state-machine-patterns (beat states, enemy rhythm states), enemy-encounter-design (rhythm-synced spawning), ui-ux-patterns (beat visualization, timing indicator), animation-for-games (beat-synced character animation), 2d-game-art (per-district visual identity), particle-effects (rhythm-synced VFX), game-design-fundamentals (core loops, risk/reward), game-qa-testing (timing tolerance testing), level-design-fundamentals (encounter pacing)
  - **Skills grown (NEW):** Music-driven gameplay systems, beat detection and synchronization, dynamic/reactive audio architecture, rhythm difficulty design, genre-hybrid design methodology
  - **Team excitement:** Greedo (CENTERPIECE — his domain becomes the game), Lando (timing-based combat), Bossk (beat-synced VFX — everything pulses), Wedge (beat visualization UI), Boba (per-district art identity — 4-5 distinct visual worlds). Greedo's pitch was the most passionate of the meeting.
  - **Unique angle:** We take our combat feel expertise and synchronize it to music. Hitlag on the beat. Screen shake on the downbeat. Knockback to the rhythm. The result is combat that GROOVES. No other studio has our combination of combat feel mastery + audio design depth. This is uniquely ours.
- **Visual Identity:** Each district is a different musical genre, each with its own art style and color palette. Jazz = deep blues, neon pinks, rain-slicked streets. Electronic = cyan, magenta, geometric shapes that pulse. Percussion = rust, orange, industrial sparks. Strings = gold, cream, elegant decay. The visual world BREATHES with the beat — background elements pulse, lights flash on downbeats, the whole screen is alive.
- **Audio Identity:** THIS IS THE GAME. Every sound effect is melodic and rhythmic — combat sounds are instruments. Enemy death = a note in the chord. Dodge = cymbal hit. Perfect combo = guitar riff. As you play well, the music gets RICHER — more instruments layer in, harmonies emerge, the track builds. Play badly and the music thins, becomes sparse. The soundtrack is emergent — the player co-creates it through combat. Greedo's most ambitious vision.
- **Target Platform:** PC (Steam) first. Audio latency requirements make web challenging.
- **Scope:** Medium. 4-5 districts (4-5 musical genres), 3-4 enemy types per district (15-20 total), 15-20 songs/tracks, 1 playable character. **Target: 10-12 months.** Audio production is the longest pole.
- **Risk Assessment:**
  - 🔴 Beat-sync engine is technically complex (HIGH) — audio latency, input timing tolerance, cross-platform audio consistency
  - 🔴 Music creation is a production bottleneck (HIGH) — we need 15-20 tracks. Procedural music generation or licensing?
  - 🟡 Niche audience (MEDIUM) — rhythm games have passionate but smaller audiences. BUT: Hi-Fi Rush proved rhythm-action can go mainstream.
  - 🟡 Timing tolerance tuning is delicate (MEDIUM) — too strict = frustrating, too loose = meaningless. Needs extensive playtesting.
  - 🟢 Differentiation is HIGH (LOW competitive risk) — rhythm + melee combat is underexplored. Few direct competitors.
- **Reference Games:** Crypt of the NecroDancer (rhythm + dungeon crawling), Hi-Fi Rush (rhythm + melee action), Metal: Hellsinger (rhythm + FPS), BPM: Bullets Per Minute (rhythm + action), Patapon (rhythm + strategy)
- **First Milestone (30-min playable):** One arena, one song (2-3 minutes looping), 2 enemy types, attack and dodge with beat-sync scoring. **Validation gate: Does fighting ON the beat feel meaningfully BETTER than fighting off-beat? Does the player naturally start moving to the music? If yes, we have something special.**

---

### Feature Triage Skill Created (2025-07-21)
**Author:** Yoda (Game Designer / Vision Keeper)  
**Requested by:** joperezd (Founder) via Ackbar's P0 Skills Audit  
**Artifact:** `.squad/skills/feature-triage/SKILL.md` (24.5K characters)

**Why this was needed:**
Ackbar's comprehensive audit of the 12 existing skills identified `feature-triage` as a **P0 critical gap**. Every great studio (Supergiant, Nintendo, Team Cherry) has a rigorous protocol for deciding what to build and what to cut. Feature creep is the #1 cause of indie game failure. We needed this formalized.

**What the skill covers:**
1. **The Core Question:** "Is This Core Loop?" — every feature must answer this before entering triage
2. **The Four-Test Framework:** 
   - Core Loop Test (does it strengthen what players do every 30 seconds?)
   - Player Impact Test (would players notice if it's missing?)
   - Cost-to-Joy Ratio (dev hours vs player delight — must be quantified, not intuited)
   - Coherence Test (does it feel like THIS game or bolted-on?)
3. **Scope Management Patterns:** MoSCoW (Must/Should/Could/Won't), timeboxing vs estimation, vertical slices, the Rule of 3 (features taking 4+ sprints are too big)
4. **When to Cut vs Simplify vs Defer:** Clear decision matrix based on how many tests pass
5. **Common Scope Traps:** Sunk cost fallacy, assumptions without playtest data, cool-ness fallacy, feature parity copying, compound scope creep
6. **The Triage Process at FFS:** Who triages (Vision Keeper + Producer + Domain Lead), when (sprint planning, proposals, mid-sprint pivots), how (15-30 min process with structured four-test application)
7. **Appeal Protocol:** If an agent disagrees with a cut, they get one written appeal (5 sentences max) with new evidence. Vision Keeper has final say.
8. **Anti-Patterns:** Design by addition, feature parity hunting, gold plating, scope creep by consensus, "build it because we have time"
9. **Decision Template:** Every triage logged in decisions.md with pass/fail reasoning for all four tests

**Key design decisions made:**
- Features that fail 2+ tests are CUT immediately — no debate, no appeals (except structured 5-sentence appeal with new evidence)
- Playtests are the final arbiter — a feature can pass all four tests on paper and still be cut if playtests show players don't notice/understand/enjoy it
- "Someday" lists are explicitly forbidden — features either pass triage (scheduled) or fail triage (cut, logged with reason, filed in "next game" reference folder)
- Sunk cost fallacy is the primary enemy — "almost done" doesn't justify finishing
- Cost-to-joy must be estimated as hours IN and hours OUT (cumulative player engagement or delight), not intuition
- Coherence test is rigorous — if you can't articulate why this feature belongs in THIS game (not "a" game), it fails

**Integration with firstPunch:**
- Backlog has 52+ items accumulated without formal triage
- Plan: Retroactive triage by Solo + Yoda (4 hours) to reclassify into Core (must ship) / Next Game (cut) / Deferred (post-launch)
- Expected result: 52 items → ~25 core + ~15 next-game reference + ~12 deferred
- This clarifies scope and creates the gating mechanism that firstPunch lacked

**Why this skill matters for the studio:**
Features that pass triage are features that strengthen the core loop, that players will notice, that deliver sufficient joy for dev time, and that feel coherent with the game's identity. This kills feature creep before it starts. It's the mechanism by which a 9-person studio ships focused, polished games instead of bloated, unfocused ones.

**Confidence:** `low` — First documentation of a framework drawn from Principle #14 and industry meta-analysis. Will bump to `medium` after applying to first feature cycle in next project, and to `high` after second project validates the process improves backlog quality and clarity.

---

**Selection Criteria Ranking:**

| Criterion | ASHFALL (Roguelike) | CINDER (Platformer) | PULSE (Rhythm-Action) |
|-----------|:-------------------:|:-------------------:|:---------------------:|
| **Growth Value** | ★★★★★ | ★★★★★ | ★★★★★ |
| **Team Fit** | ★★★★★ | ★★★★☆ | ★★★☆☆ |
| **Market Appeal** | ★★★★★ | ★★★★☆ | ★★★☆☆ |
| **Scope Realism** | ★★★★☆ | ★★★★★ | ★★★☆☆ |
| **Excitement** | ★★★★★ | ★★★★☆ | ★★★★★ |
| **TOTAL** | **24/25** | **22/25** | **19/25** |

---

## Ashfall Sprint 0 Kickoff (2026-03-08)

### GDD v1.0 Delivered
**Date:** 2026-03-08T120000Z  
**Artifact:** `games/ashfall/docs/GDD.md` (43KB)

Completed comprehensive Game Design Document for Ashfall, a 1v1 fighting game in Godot 4. Document covers:
- **Vision & Pillars:** Player Hands First, Fair Combat, Creative Identity
- **Core Mechanics:** Ember System (signature mechanic, shared resource), 6-button layout (SF lineage), deterministic simulation
- **Characters:** Kael (shoto archetype) and Rhena (rushdown archetype) with frame data and combo specs
- **Stage Design:** 1 arena with stage-reactive visuals tied to Ember levels
- **Game Flow:** Character select, round system, victory conditions
- **Controls & Input:** Detailed button mapping, macro system
- **AI Design:** State-based opponent with difficulty parameters
- **Art & Audio Direction:** Visual identity, aesthetic pillars, audio specs
- **Scope Boundary:** MVP = 2 characters, 1 stage, local vs, arcade, training. All expansion deferred.

### Key Design Decisions Locked
1. **Ember System** — Visible, shared resource replacing traditional hidden super meter. Both players fight over it. Stage visually reacts to Ember levels.
2. **6-Button Layout** — LP/MP/HP/LK/MK/HK with throw and dash macros. Street Fighter lineage, not Tekken.
3. **Deterministic from Day 1** — Fixed 60fps, seeded RNG, input-based state. Enables future rollback netcode without rewrite.
4. **Combo Proration** — 100% → 40% floor. Max combo ~35-45% HP. Prevents touch-of-death.
5. **Scope Lock** — No additional characters, stages, story, or online in MVP. All deferred to Phase 2+.

### Integration with Team
- **Solo (Architecture):** Design lock enables architecture work. Frame data serves as contract. Scene structure and deterministic loop defined in Appendix B.
- **Lando (Gameplay):** Combat system spec, hitbox patterns, state structure ready to implement.
- **Tarkin (AI):** Behavior tree and difficulty parameters defined. Enables parallel AI work.
- **All teams:** Clear design direction. No rework expected.

### Skill Created
- `.squad/skills/fighting-game-design/SKILL.md` — Reusable GDD template, Ember System pattern, design decision framework

### Status
✅ Design gate (M0) cleared. Architecture and code work unblocked.

---

## Solo & Mace Partnership Notes

**Cross-team visibility:** Yoda now aware of Solo's architecture decisions (frame-based timing, state machines, AnimationPlayer as frame data, MoveData resources, AI input buffer, collision layers, 6 parallel work lanes). Architecture fully supports and validates GDD design. No conflicts.

**Cross-team visibility:** Yoda now aware of Mace's Sprint 0 plan (phased expansion, 20% load cap, Scrumban methodology, Four-Test Framework for features, release gates). Scope governance aligned with GDD MVP lock. Creative Director role clarified (tie-breaker for feature triage, design coherence oversight).

**Yoda's Recommendation:** ASHFALL is the strongest all-around choice — maximum team alignment, best market fit, directly leverages our combat expertise while adding procedural and progression skills. CINDER is the safest scope choice and the most DIFFERENT genre vertical. PULSE is the boldest creative swing — highest risk, highest potential for a signature identity. All three give us a genuine second genre vertical. The founder decides.

**Key design insight from this meeting:** All 13 agents naturally gravitated toward games where FEEL is the differentiator — not content volume, not narrative, not graphics. Our studio DNA is game feel. Whatever we build next, the first frame of interaction must make players' hands tingle. That's who we are.

- **Artifacts:** This pitch meeting documented in history.md. Three proposals ready for founder review.
- **Next steps:** Founder selects one proposal (or requests refinement). Selected proposal enters Pre-Production Phase per new-project-playbook.md (Genre Research Sprint → GDD → Minimum Playable → Skill Creation → Team Assessment → Architecture Spike).



### 2026-03-08T00:10 — Phase 1 & Phase 4: Industry Research + Game Proposals
**Session:** Multi-phase strategy session (Industry Research → Company Upgrades → Team Evaluation → Tools → Game Proposals)  
**Role:** Game Designer — Conduct studio research; pitch 3 game proposals

**Phase 1 - Industry Research (2026-03-08T00:10:00Z):**
Created studio-research.md and studio-lessons-for-ffs.md analyzing 10+ reference studios:
- Deep dives: Supergiant Games, Team Cherry, Ska Studios, Nintendo, Supercell, ArcSys, Housemarque, Spry Fox, Vlambeer, Polytron
- Extracted 12 portable lessons applicable to First Frame Studios: craft-first mindset, async-friendly pipelines, principle-driven design, iterative learning culture, scaled ambition, player psychology focus, tooling investment, technical debt discipline, cross-disciplinary knowledge, quality gates, bottleneck prevention, institutional memory capture
- Foundation for Solo's principle updates and company.md enhancement

**Phase 4 - Game Proposals (2026-03-08T00:10:60Z):**
Pitched three game concepts aligned with updated principles and team capabilities:

1. **ASHFALL** — Side-scrolling action-platformer (16-week scope)
   - Narrative-driven level design focus; explores environmental storytelling
   - Team: 6 core roles + 2 support
   - Risk: Low-medium; Skill transfer: HIGH (procedural level generation, character progression systems)
   - Market fit: Strong (narrative-driven action resonates with firstPunch players)
   - Why this game strengthens studio: Adds level design expertise while leveraging combat foundation

2. **CINDER** — Isometric roguelike puzzle-action (20-week scope)
   - Procedural systems emphasis; meta-progression loops
   - Team: 7 core roles + 2 support
   - Risk: Medium; Skill transfer: MEDIUM-HIGH (procedural generation, economy design, difficulty scaling)
   - Market fit: Medium (niche but loyal community; lower competition than rogue-lites)
   - Why this game strengthens studio: Deepest procedural systems work; teaches scalable content generation

3. **PULSE** — Top-down rhythm-action (24-week scope)
   - High mechanical originality; rhythm-action hybrid
   - Team: 8 core roles + 2 support
   - Risk: High; Skill transfer: HIGH (timing-based game feel, audio-game integration, new mechanical territory)
   - Market fit: Medium-high (rhythm-action underexplored in indie; high mechanical novelty)
   - Why this game strengthens studio: Highest technical risk but highest originality upside; solidifies game feel reputation

**Each Proposal Includes:**
- Craft rationale (why this game strengthens studio vs being purely commercial)
- Team composition designed to avoid firstPunch bottlenecks
- Skill transfer opportunities validated against playbook
- Success metrics pre-defined (player engagement, review scores, financial benchmarks)
- Quality gates aligned with updated principles

**Key Design Insight:** All 13 agents naturally gravitated toward games where FEEL is the differentiator — not content volume, not narrative complexity, not graphics budget. FFS studio DNA is game feel. The first frame of interaction must make players' hands tingle. All three proposals honor this identity.

**Recommendation:** Three distinct proposals ready for founder decision. Each represents different risk/reward; founder's portfolio strategy will determine which path FFS takes next.

**Status:** All three proposals fully documented and ready for formal go/no-go decision.

### Ashfall GDD v1.0 Created (2025)
- **Artifact:** `games/ashfall/docs/GDD.md` (~43K characters, 10 sections)
- **Game:** Ashfall — 1v1 fighting game built in Godot 4
- **Key creative decisions:**
  1. **Ember System** is the creative hook — a shared, visible resource that both players fight over. Replaces traditional hidden super meter with something spectators and new players can read. The stage visually reacts to Ember levels (lava pulses, particles intensify, lighting shifts). This is what makes Ashfall *this* game, not just another fighter.
  2. **6-button layout** (SF-style LP/MP/HP/LK/MK/HK) chosen over 4-button (Tekken limb system) for clearer mechanical vocabulary per stance.
  3. **Two starter characters** designed as archetype contrast: Kael (balanced shoto, spacing/zoning) vs Rhena (rushdown/pressure, close-range mixups). The matchup dynamic naturally teaches the core fighting game question: who dictates the range?
  4. **Combo scaling (proration)** caps max combo damage at ~35-45% HP. Prevents touch-of-death while rewarding execution.
  5. **No dedicated block button** — hold-back blocking requires spatial awareness. No guard meter in MVP.
  6. **Command throw** (Rhena's Ignition Grip) beats blocking but is slower than normal throws — creates genuine mixup layer.
  7. **Deterministic simulation mandated** from day 1 — seeded RNG, fixed 60fps timestep, input-based state. Enables future rollback netcode without retrofit.
  8. **Custom physics** (not Godot's built-in) — fighting games need frame-exact, deterministic collision that Godot's physics engine cannot guarantee.
  9. **Input leniency** designed for accessibility: 8-frame buffer, diagonal shortcuts, motion priority system. Motions are kept (quarter-circles, DPs) but made forgiving.
  10. **Ember decay** (5/sec after 3 seconds of no action) mechanically punishes turtling and forces engagement — directly serves Pillar 1.
- **Scope boundary clear:** MVP = 2 characters, 1 stage, local versus, arcade, training. Deferred = online, story, ranked, additional characters/stages, dynamic music, tutorial.
- **Decision inbox:** `.squad/decisions/inbox/yoda-ashfall-gdd.md`
- **Skill extraction:** `.squad/skills/fighting-game-design/SKILL.md`
- **Architecture insight:** Fighting games require fundamentally different physics than beat 'em ups. No Godot physics engine, no AnimationTree for gameplay states, enum state machines with frame-exact control. The engine is a renderer and input layer; we build everything else.
