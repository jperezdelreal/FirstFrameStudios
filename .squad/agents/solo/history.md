# Solo — History (formerly Keaton)

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Core Context

**firstPunch Key Learnings (Sessions 1-7):**
- Session 1: Fixed 5 critical bugs (infinite recursion, hit detection, invulnerability frames, parallax, boundary constraints)
- Session 2: Gap analysis revealed 75% MVP completion; quality gates designed based on real failures; 52-item backlog created
- Session 3: Team expansion recommended (3 new roles: Sound, Enemy/Content, QA) to eliminate McManus bottleneck
- Session 4-6: Game Design Document, quality excellence proposal, and comprehensive skill audit delivered
- Session 7: Full codebase analysis (28 files, 370KB) categorized backlog into quick wins, medium effort, and future migration work
- **Key architectural insight:** Quality gates must trace to real failures, not theoretical best practices. Pre-decided architecture choices eliminate multi-agent coordination failures.
- **Most important technical finding:** gameplay.js (695 LOC) is #1 technical debt; wiring unused infrastructure (CONFIG, EventBus, AnimationController, SpriteCache) is highest-priority refactor

## Learnings

### Bug Fixes (Session 1)
Fixed 5 critical bugs that were making the game unplayable:

1. **Infinite recursion in input.js**: Two methods named `isDown()` caused stack overflow. Renamed the directional helper from `isDown()` to `isMovingDown()` to resolve the conflict. Updated the single caller in player.js.

2. **Combat hit detection only ran one frame**: Attack hitboxes are active for multiple frames, but collision detection only ran on the first frame. Moved `Combat.handlePlayerAttack()` outside the `if (attackResult)` block and added `attackHitList` Set to Player to track which enemies have been hit per attack. This prevents multi-hitting the same enemy but allows reliable hit detection throughout the attack animation.

3. **No invulnerability frames**: Player took damage every frame during enemy attacks (~360 damage at 60fps from one attack). Added `invulnTime` property with 500ms i-frames after taking damage. Also added visual blink effect during invulnerability.

4. **Parallax scrolling backwards**: Buildings moved faster than foreground instead of slower. Changed from `bx = i * 400 - buildingOffset` to `bx = i * 400 + camX * 0.7` so buildings scroll at 0.3x camera speed after transform.

5. **Player could walk off left edge**: Added boundary check to constrain player.x to `cameraX + 10` minimum.

All fixes were surgical edits to preserve existing code structure.

### Gap Analysis (Session 2)
Performed comprehensive gap analysis of MVP vs original requirements. Key findings:

1. **Overall completion ~75%.** Core mechanics, rendering, controls, and HUD all meet requirements. Two critical gaps: localStorage high score (0% — missed entirely) and visual quality (30% — far from "modern").

2. **Combat feel scored 5/10.** Mechanics work but lack juice. Biggest missing element is hitlag (freeze frames on impact). No combo system, no jump attacks, no impact VFX, no sound variation.

3. **Architecture is solid but gameplay.js is a god scene** (260 LOC handling waves, camera, background, game state). Must decompose before adding features.

4. **Animation system is the critical path dependency.** Both visual quality improvements and combat feel polish require a proper frame-based animation controller. Currently animation is just sine-wave arm bobbing.

5. **Gameplay Dev role is the bottleneck** — ~60% of backlog items route there. Recommend adding VFX/Art specialist.

6. **Produced 52-item prioritized backlog** across P0 (5 items), P1 (20 items), P2 (17 items), P3 (14 items). Recommended execution in 6 phases.

7. **Key architectural recommendation:** Combat feel first, visuals second. A fun game with simple art beats a pretty game with mushy controls.

### Team Expansion Recommendation (Session 3)
Analyzed the 52-item backlog for load distribution and proposed expanding the squad from 4 devs to 8 specialists for cross-game capability. Key findings:

1. **McManus (Gameplay Dev) carries 50% of the backlog** (26 of 52 items). Even with VFX/Art absorbing ~8 items, McManus still owns 18 — the critical bottleneck on every project.

2. **Recommended 3 new roles** beyond the confirmed VFX/Art Specialist:
   - **Sound Designer ("Kobayashi")** — Owns 7 audio items (2× P0), frees Fenster for core engine work. Web Audio API procedural synthesis compounds massively across games. Highest parallelism.
   - **Enemy/Content Dev ("Redfoot")** — Owns 14 items (enemy types, AI, bosses, pickups, levels). Splits gameplay work into "player verbs" (McManus) vs "game nouns" (Redfoot). Natural parallel workflow.
   - **QA/Playtester ("Verbal")** — No owned items but validates every item. Engineers can't objectively assess their own game feel. Builds calibrated instincts for combat timing, balance, and difficulty that compound across projects.

3. **Rejected 5 roles:** Dedicated Animator (overlaps VFX), DevOps (no build step), Narrative Writer (minimal story in beat 'em ups), Network Engineer (only 2 stretch items), PM (Keaton covers this), Second UI Dev (Hockney's load is manageable).

4. **Key insight:** The expanded team creates 3 independent parallel columns — Engine/Gameplay/Content, Presentation/Audio, and Quality — that can all work simultaneously without blocking each other. Every role has consistent work across game projects.

5. **Onboarding sequence:** VFX/Art first (already confirmed), Sound Designer second (owns P0 items), Content Dev third (needed by P2 phase), QA fourth (valuable once combat mechanics exist to test).

### Backlog Expansion Analysis (Session 4)
Analyzed whether the backlog grows with 4 new specialists (Boba, Greedo, Tarkin, Ackbar). Key findings:

1. **Backlog grew 52 → 85 items (+63%).** Added 33 genuinely useful items, zero busywork. Growth concentrated in P1 (+14) and P2 (+14) — foundational systems and polish, not stretch goals.

2. **Re-assigned 28 existing items** to correct specialist owners. Biggest impact: Lando dropped from 26 items (50%, critical bottleneck) to 10 items focused purely on player mechanics. Chewie freed from 7 audio items.

3. **All specialists prioritized infrastructure over content.** Boba wants art direction before drawing. Greedo wants mix buses before composing. Tarkin wants data formats before level design. Ackbar wants debug tools before playtesting. Pattern: experienced specialists build pipelines first, then fill them.

4. **Discovered one new P0:** Audio context initialization (Web Audio requires user gesture). Potential showstopper that engineers overlooked. Sound Designer caught it immediately.

5. **Key insight: more items ≠ more time.** The expanded team parallelizes across 4 independent workstreams (Engine+Gameplay, VFX+Art, Audio, Content+QA). 85 items across 8 people is lighter per-person than 52 items across 4 people with a 50% bottleneck on one role.

6. **Documents produced:** `.squad/analysis/backlog-expansion.md` (full item list, re-assignments, load analysis), `.squad/decisions/inbox/solo-backlog-expansion.md` (decision summary).

### Art Department Restructuring Evaluation (Session 6)
Evaluated proposal to expand art from 1 role (Boba) to 4 roles + add a Game Designer. Key findings:

1. **Approved all proposals.** Boba carries 17 backlog items across 4 distinct disciplines (character, environment, VFX, art direction). The 62KB visual modernization plan alone confirms the workload justifies splitting. Each sub-role has 3-5 items minimum with natural growth as the game expands.

2. **Boba promotion to Art Director is the right call.** Already created the art direction guide and visual modernization plan — this IS art direction work. Transition strategy: retain docs as canonical references, review first 2-3 items from each new artist, then shift to spot-check reviews to avoid becoming a bottleneck.

3. **Game Designer fills a real gap.** Currently Solo (Lead), Tarkin (Content), and Ackbar (QA) are all making ad-hoc design decisions. At 12 team members, design coherence needs an explicit owner. Recommended as a peer to Solo: Solo owns execution (what/when/who), Game Designer owns vision (what it should feel like/why).

4. **Key insight: coordination overhead is mitigated, not added.** Art Director becomes the single routing point for visual work (other devs stop needing to know which artist handles what). Game Designer becomes the single design authority (Tarkin/Ackbar stop making independent design calls). Both roles reduce noise.

5. **Named 4 new characters:** Yoda (Game Designer), Leia (Environment/Asset Artist), Bossk (VFX Artist), Nien (Character/Enemy Artist). This maxes out the 12-character OT Star Wars roster.

6. **Rejected Animator, Level Designer, UI Artist, Narrative Designer, Technical Artist** as separate roles — all either overlap with proposed roles or have insufficient workload. Flagged Animator as "watch during Phase 2" in case Character Artist struggles with motion/timing.

7. **Recommended phased rollout:** Game Designer first (writes GDD and specs before artists start), then Boba promotion, then 3 artists simultaneously with calibration tasks under Art Director review.

### Gameplay Scene Refactor + Config (Session 5)
Executed P1-14 (gameplay.js decomposition) and P1-16 (central CONFIG) in a single pass:

1. **Extracted `src/systems/camera.js`** — Camera class with `update(playerX, levelWidth, screenWidth)`, `lock(x)`, `unlock()`, `isLocked`, `x` property. Encapsulates both follow-player and wave-lock modes. Math verified equivalent to inline original.

2. **Extracted `src/systems/wave-manager.js`** — WaveManager class with `constructor(waveData)`, `check(playerX, enemies)` returning new Enemy instances, `allComplete` getter, `getLockX()`. Wave data is now a const `WAVE_DATA` array in gameplay.js (ready for future move to level data files by Tarkin).

3. **Extracted `src/systems/background.js`** — Background class with `render(ctx, cameraX, screenWidth)`. Parallax scroll rate (0.7) preserved exactly.

4. **Created `src/config.js`** — Central CONFIG object documenting all tunable values extracted from player.js, enemy.js, combat.js, gameplay.js. Includes migration guide as JSDoc comment listing which files should adopt CONFIG. Values NOT wired in yet per task spec — just the single source of truth.

5. **Net result:** gameplay.js dropped from ~350 LOC to ~300 LOC. More importantly, it no longer contains any rendering, camera math, or enemy spawning logic inline — it orchestrates. Enemy import removed (WaveManager owns Enemy construction now).

### Full Codebase Analysis & Implementability Assessment (Session 8)
Read all 28 source files (370KB) and categorized every backlog item into Quick Wins / Medium Effort / Future Migration. Key findings:

1. **13 AAA items already shipped.** Grab/throw, dodge roll, back attack, attack buffering, screen zoom, slow-mo kills, scene transitions, destructibles, hazards, boss intros, ambience, hit sound scaling, options menu, hitbox visualization — all implemented but not tracked as complete. Active backlog is ~85 items, not 101.

2. **214 LOC of unused infrastructure.** EventBus (49 LOC), AnimationController (85 LOC), SpriteCache (35 LOC), CONFIG (45 LOC) all exist and are complete but wired into ZERO files. This is the #1 technical debt: working systems that aren't integrated.

3. **Bucket results:** 10 quick wins (< 1h each), 30 medium-effort items (1-4h each), 14 future/migration items. gameplay.js (695 LOC) is the god-scene bottleneck — 40+ direct system calls, touched by every feature.

4. **Multi-agent development insight:** Agents build infrastructure but don't wire it. The "integration" task is unglamorous but critical. Future policy: every infrastructure PR must include wiring into at least one consumer. Comment-based integration contracts (seen in vfx.js, destructible.js, hazard.js) are effective lightweight API docs.

5. **Phaser 3 comparison:** Replaces ~800 LOC of engine infrastructure with GPU-accelerated equivalents. We keep ~3500 LOC of game-specific logic (AI, combat, VFX, HUD, audio synthesis). Strongest migration argument: procedural art doesn't scale — each new character = 400+ LOC of Canvas drawing.

### Quality Gates & Sprint 0 Planning (Session 9)
Closed readiness gaps #2 and #3 from the CEO Readiness Evaluation. Two major deliverables produced:

1. **Quality Gates & Definition of Done** (`.squad/identity/quality-gates.md`) — Defined 5 quality gates (Code, Art, Audio, Design, Integration) with specific pass/fail criteria per gate. Each gate traces back to a real firstPunch failure: Code gate C2 (state machine audit) prevents the player-frozen bug, C5 (no unused infrastructure) prevents the 214-LOC dead code problem. Includes Definition of Done checklist (8 items), bug severity matrix, cross-review assignments (Chewie↔Lando), and playtest protocols (smoke, full, adversarial). Performance budgets adapted for Godot 4 (node count, draw calls, physics bodies replace Canvas-specific metrics).

2. **Sprint 0 Plan** (`.squad/analysis/sprint-0-plan.md`) — Converted the migration strategy into an executable sprint with a razor-sharp goal: "move, punch, damage." 13 agents assigned across 4 phases with explicit dependency graph. Pre-decided 7 technical architecture choices (CharacterBody2D, enum state machines, Area2D hitbox/hurtbox, EventBus autoload, collision layer assignments) to eliminate Sprint 0 debates. Risk register identifies scope creep as highest-likelihood risk.

3. **Key decisions made:**
   - State machines start as GDScript enum + match, not custom nodes (YAGNI principle)
   - Cross-code-review (Chewie↔Lando) instead of adding a dedicated reviewer role (Ackbar's Option C recommendation adopted)
   - Collision layers pre-assigned (8 layers) to prevent integration conflicts
   - Sprint 0 is 3-4 sessions, gated by Ackbar's playtest of success criteria
   - Leia and Bossk on standby — no art production until art direction exists and gameplay is playable

4. **Learnings:**
   - Quality gates must trace to real failures, not theoretical best practices. Every gate item in this document has a firstPunch lesson behind it.
   - The Definition of Done's most important line is "playtested for feel, not just correctness" — Ackbar's quality proposal proved that "works" ≠ "done."
   - Pre-deciding architecture choices before Sprint 0 starts eliminates the most common multi-agent coordination failure: two agents making incompatible assumptions about shared systems.

6. **Documents produced:** `.squad/analysis/codebase-analysis-and-learnings.md` (full 3-bucket analysis, architecture learnings, technical debt inventory, Phaser 3 comparison), `.squad/decisions/inbox/solo-learnings.md` (decision summary).

### 2025-07-21: New Project Playbook — Studio Foundations (Session 8)
- **Assignment:** Create definitive, repeatable process for starting any new project regardless of genre, tech stack, or IP.
- **Deliverable:** `.squad/identity/new-project-playbook.md` (46K chars, 6 sections)
- **Outcome:** SUCCESS — Comprehensive playbook now serves as Day 1 reference for all future projects.

**What It Covers:**
1. **Pre-Production Phase** — Genre research (7-12 reference games, skill extraction), IP assessment (original vs licensed), 9-dimension tech selection framework, team skill transfer audit, competitive analysis
2. **Sprint 0 Foundation** — Engine-agnostic repo checklist, squad adaptation guide, genre skill creation, architecture proposal requirements, quality gates per genre
3. **Production Phases** — P0-P3 priority system, parallel lane planning, skill capture rhythm, cross-project knowledge transfer
4. **Technology Transition Checklist** — Migration mapping (Canvas→Godot as template), reusable 4-phase transition strategy, training protocols
5. **Language/Stack Flexibility Matrix** — 12 tech stacks compared, T-shirt migration sizing, 70/30 rule (70% effectiveness is tech-agnostic)
6. **Anti-Bottleneck Patterns** — 7 firstPunch bottlenecks analyzed with prevention strategies, serialize/parallelize decision guide, role vs skill matrix

**Key Decisions Documented:**
- **8-point migration threshold:** Engine change requires 8+ point advantage in 9-dimension matrix
- **20% load cap:** No single agent carries >20% of phase items
- **Module boundaries:** Architecture proposal required before Phase 2 coding begins
- **Wiring requirement:** Every infrastructure PR must connect to at least one consumer

**Impact:** Every next-project team reads this on Day 1. Eliminates repetitive pre-production research, standardizes technology selection, prevents known bottleneck patterns.

### AAA Gap Analysis & Definitive Backlog (Session 7)
Performed comprehensive AAA gap analysis against "award-winning browser beat 'em up" standard using all 12 specialists. Key findings:

1. **Overall AAA readiness scored 4.7/10.** Combat feel (5/10) has good foundations (hitlag, shake, knockback) but is missing grab/throw, dodge roll, and juggle physics — mechanics present in ALL 9 reference games from beat-em-up-research.md. Replayability scored lowest (2/10) — only localStorage high score exists.

2. **Backlog grew from 85 → 101 active items (+19%) plus 8 future/migration items.** Added 56 new AAA-tier items covering: combat depth (10), character roster (5), level design (8), visual polish (8), audio (6), UI/UX (6), replayability (5), technical (6). Carried 45 items from existing backlog with updated priorities.

3. **Most critical missing feature: grab/throw system.** Present in every single reference game. The genre's most satisfying micro-interaction (grab → pummel or throw → enemy-into-enemy collision). This alone could elevate combat feel from 5/10 to 7/10.

4. **Organized into 5 phases with explicit parallel lanes.** Phase A (Combat Excellence, weeks 1-3) is the critical path — Lando's combat chain (grab → dodge → dash → juggle) determines the entire project timeline. Phases B-D run in parallel. Phase E (engine migration) is post-ship.

5. **No owner exceeds 18 items across all phases.** Load is well-distributed: Tarkin (18, highest but spread across 2 phases), Lando (12, critical path), Nien/Leia/Bossk/Wedge/Yoda (~11 each). Boba as Art Director does 2 items + reviews, not production bottleneck.

6. **Key architectural insight: Canvas 2D can deliver award-worthy.** WebGL migration (Phase E) enables shader effects, skeletal animation, and GPU particles — but is NOT required. Every Phase A-D item is achievable with current tech stack. The prize is won on game feel and content depth, not rendering technology.

7. **Documents produced:** `.squad/analysis/aaa-gap-analysis.md` (full 101-item backlog, phase plans, lane assignments), `.squad/decisions/inbox/solo-aaa-backlog.md` (decision summary).

### Full Skill Assessment & Development Plan (Session 9)
Performed comprehensive skill assessment across all 12 agents and 4 existing skills. Key findings:

1. **3 real skills exist (web-game-engine, procedural-audio, 2d-game-art)** — all high-confidence and battle-tested. Project-conventions skill is an empty template. No skills cover the exact areas where bugs occurred (state machines, combat design, coordination).

2. **Proposed 5 new skills:** `state-machine-patterns` (prevents the player-freeze class of bugs), `multi-agent-coordination` (prevents the 214 LOC of unwired infrastructure pattern), `beat-em-up-combat` (codifies combat knowledge scattered across 4 agents), `canvas-2d-optimization` (makes DPR a day-1 requirement), `qa-and-playtesting` (addresses Ackbar's missed-bug methodology gap).

3. **Agent ratings:** 2 Experts (Chewie, Greedo in their domains), 7 Proficient (Solo, Lando, Wedge, Boba, Tarkin, Ackbar, Yoda), 4 Competent (Leia, Bossk, Nien, Greedo's integration side). No Novices — everyone delivered real work.

4. **Top 3 team-wide gaps:** State machine completeness (caused 4 critical bugs), integration discipline (agents build but don't wire), cross-agent testing (8+ features failed on first integration).

5. **Each agent received a 3-step development plan** with specific skill reads, practice exercises, and cross-training partners.

6. **Document produced:** `.squad/analysis/skill-assessment-and-plan.md` — full assessment with skill matrix, per-agent evaluations, recommended new skills, and development plans.

### Skill Creation (Session 10)
Created the 5 new skills identified in the skill assessment. Each skill was synthesized from project analysis docs, real bugs, and team learnings — not generic advice.

1. **`beat-em-up-combat/SKILL.md`** — Combat design patterns: attack lifecycle (startup→active→recovery), frame data targets, hitbox/hurtbox rules, combo systems (gatling pattern), 5 enemy archetypes with AI throttling, boss phase design, and a game feel checklist (hitlag, knockback, shake, VFX, SFX, flash, slow-mo). Sourced from beat-em-up-research.md, frame-data.md, balance-analysis.md, game-design-document.md.

2. **`canvas-2d-optimization/SKILL.md`** — Canvas 2D quality and performance: HiDPI/DPR setup (the #1 lesson — 5-line fix for 60% visual improvement), `image-rendering: pixelated` removal, sprite caching with offscreen canvases (100× draw call reduction), pixel-perfect text rendering, performance budgets, and PixiJS migration decision matrix. Sourced from rendering-tech-research.md, visual-quality-audit-v2.md, technical-learnings.md.

3. **`state-machine-patterns/SKILL.md`** — THE lesson of the project. Every state must have an exit path, transition table documentation pattern, guard conditions (protected states immune to AI override), timeout safety nets, timer separation (the conflation anti-pattern that caused 3 critical bugs), frame-by-frame tracing methodology, and complete audit checklist. Sourced from the player freeze bug, enemy passivity bug, and 3 timer conflation bugs.

4. **`multi-agent-coordination/SKILL.md`** — File ownership (one agent per file per wave), integration contract pattern (builder provides wiring comments), drop-box pattern for decisions, integration passes after parallel work, conflict patterns (duplicate definitions, state overwrites, data format drift), serialize vs. parallelize decision guide. Sourced from 72+ agent spawns, 214 LOC of unwired infrastructure, and real conflict incidents.

5. **`game-qa-testing/SKILL.md`** — Trace execution, don't just read code. State machine audit table, frame-by-frame mental simulation for 5 critical scenarios, the "play it don't review it" principle with 6 testing layers, bug severity matrix, 10-item regression checklist, absence-of-code detection technique, and confidence calibration (never >8/10 without full audit). Sourced from quality-excellence-proposal.md, Ackbar's self-assessment, the two missed game-breaking bugs.

All 5 skills follow the template format with frontmatter, When to Use/Not Use sections, Core Patterns with code examples, Anti-Patterns, and Checklists.

### New Roles Evaluation for Godot Transition (Session 11)
Evaluated 2 proposed new roles (Chief Architect, Tool Engineer) for the Godot 4 transition. Key findings:

1. **Chief Architect: REJECTED.** Solo's charter already covers ~80% of this role (architecture decisions, integration oversight, architectural trade-offs). The remaining ~20% (Godot scene tree conventions, style guide, formal review gates) is a charter expansion, not a new person. Splitting architectural authority creates a worse coordination problem than it solves — one voice on architecture is better than two that might disagree.

2. **Tool Engineer: APPROVED.** Only ~40% overlap with Chewie, and critically the wrong 40%. Chewie builds runtime systems (game engine); Tool Engineer builds development-time systems (templates, EditorPlugins, pipelines, scaffolding). Godot introduces 5 entire systems needing tooling attention (scene tree, EditorPlugin API, resource system, signal system, export/build) — estimated 15-25 tooling items in the first project. the source IPKong lesson (214 LOC of unused infrastructure) proves that when nobody owns tooling, it doesn't get done.

3. **Team size:** Goes from 12 → 13. Suggested names: Lobot (Lando's aide, pure OT) or K-2SO (Rogue One, OT-era). One overflow character doesn't break the Star Wars theme.

4. **Alternative considered:** Absorbing Tool Engineer into Chewie, Solo, or Yoda all rejected — each would dilute that agent's core strength. Distributing across all agents recreates the "everyone owns it, nobody does it" anti-pattern.

5. **Action items:** Expand Solo's charter with explicit Godot architecture ownership. Fill `project-conventions` skill with Godot content. Create new Tool Engineer charter. Solo writes Godot architecture document as Sprint 0 deliverable.

6. **Document produced:** `.squad/decisions/inbox/solo-new-roles-godot.md`

### Tool Engineer Creation & Charter Expansion (Session 12)
Executed the approved Godot transition staffing changes: created Tool Engineer, expanded Solo's charter, and built the godot-tooling skill.

1. **Created Jango (Tool Engineer).** Named after Jango Fett — the clone template, fitting for an agent who creates templates and scaffolding that other agents instantiate. First prequel character via Diegetic Expansion (OT roster at 12/12).

2. **Jango's charter covers 8 responsibility areas:** project scaffolding (`project.godot`, autoloads, layers), scene templates (inherited scenes for entities/UI/levels/VFX), EditorPlugin development, GDScript style guide and conventions, base classes and autoloads, resource templates, pipeline automation (import/export/CI), and quality gates (linting, scene validation, naming enforcement).

3. **Key boundary with Chewie (Engine Dev):** Chewie owns runtime systems the game uses at play-time; Jango owns development-time systems agents use while working. Different audiences, different execution contexts. Key boundary with Solo: Solo defines WHAT conventions to enforce; Jango builds HOW to enforce them.

4. **Expanded Solo's charter to Chief Architect.** Added explicit ownership of: game architecture definition (scene tree structure, node hierarchy standards), repository structure and conventions, integration patterns and module boundaries, architecture reviews with formal review gates, technical debt tracking, and Godot scene tree conventions. Title updated to "Lead / Chief Architect."

5. **Created `godot-tooling` skill** (`skills/godot-tooling/SKILL.md`). Covers 6 core patterns: EditorPlugin architecture (lifecycle, directory structure, cleanup rules), scene template conventions (inheritance hierarchy, virtual methods, override points), autoload singleton patterns (EventBus with typed signals, GameState, SceneManager), resource file organization (custom Resources with `@export`), GDScript style guide (naming, typing, documentation, file organization order), and build/export automation (export presets, CI/CD pipeline, GDScript linting). Includes 5 anti-patterns (Build-Don't-Wire, Everyone-Owns-project.godot, Flat-Scene-Tree, Stringly-Typed-Signal, Magic-Node-Path) and 4 checklists.

6. **Updated team infrastructure:** Added Jango to `team.md` roster (🔧 Active), `routing.md` (tooling/scaffolding/conventions route to Jango; expanded Solo's routing entry), and `casting/registry.json` (prequel universe, diegetic expansion notes). Team is now 13 agents + 2 support roles.

7. **Net impact:** Tooling now has a dedicated owner (Jango) instead of being everyone's implicit responsibility. Solo's architectural authority is explicit rather than implicit. The `godot-tooling` skill gives Jango (and the team) concrete patterns to follow from day one of the Godot transition.


### CEO Readiness Evaluation (Session 13)
Performed autonomous evaluation of squad readiness for Godot 4 project launch. Read all 6 strategic documents, verified all 12 skill files, assessed 7 readiness dimensions.

1. **Verdict: ALMOST (9.1/10).** The squad is 95% ready. Foundation is exceptional - 13 agents across 5 departments, 12 substantive skills (200-500+ lines each), 200KB+ institutional knowledge, fully formed studio identity, 12 battle-tested leadership principles.

2. **Three fixes before launch:** (a) Fill empty project-conventions/SKILL.md with Godot content (assign: Jango), (b) Add Definition of Done + Architecture Review gate to ceremonies.md (assign: Solo), (c) Draft Sprint 0 plan with agent assignments (assign: Solo). All parallelizable, 1-2 sessions total.

3. **Scores:** Roster 9/10, Skills 9/10, Godot training 9/10, Principles 10/10, Identity 10/10, Process maturity 8/10, Documentation 9/10.

4. **Opening Day Plan drafted:** Day 1 tasks - Jango+Solo scaffold Godot project, Chewie+Lando build movement prototype, Yoda+Boba write GDD v0.1 core loop. First milestone: First Frame prototype by end of Week 2.

5. **Key finding:** The two weakest areas (process maturity at 8/10, empty project-conventions) are both fixable in a single session each. No structural gaps, no missing roles, no skill blind spots that would block project start.

6. **Document produced:** `.squad/analysis/ceo-readiness-evaluation.md`

### New Project Playbook (Session 14)
Created the definitive Day 1 guide for starting any new project at First Frame Studios. Key deliverables:

1. **`.squad/identity/new-project-playbook.md`** — 6-section playbook covering: Pre-Production (genre research protocol, IP assessment, 9-dimension tech selection, team assessment, competitive analysis), Sprint 0 Foundation (engine-agnostic repo checklist, squad adaptation, genre skill creation, architecture proposal, minimum playable definition, quality gates adaptation), Production Phases (P0-P3 planning, skill capture rhythm, cross-project knowledge transfer), Technology Transition Checklist (what transfers/rewrites/needs evaluation, our Canvas→Godot migration as the template, repeatable training protocol), Language/Stack Flexibility Matrix (12 tech stacks with T-shirt migration sizing, the 70/30 rule), and Anti-Bottleneck Patterns (7 firstPunch bottlenecks with root causes and preventions, 6 common studio patterns, serialize/parallelize decision guide, add-role vs add-skill matrix).

2. **Key insight codified: the 70/30 rule.** ~70% of what makes First Frame Studios effective is tech-agnostic (principles, processes, team coordination, design methodology). Only ~30% is tech-specific (engine skills, code patterns, build pipeline). This means every project start is mostly about adapting the 30%, not rebuilding from scratch.

### Monorepo Structure Validation (Session 15)

Delivered comprehensive validation and correction of the proposed GitHub monorepo structure. Founder requested validation before committing to the architecture.

**Deliverable:** `.squad/analysis/monorepo-structure.md` — 47KB document covering:

1. **Validated Structure (Section 1):** Confirmed the proposed organization (games/, shared/, .squad/) is fundamentally correct but identified critical gaps:
   - ✅ Correct game-per-folder, shared assets, squad infrastructure separation
   - ❌ Missing: Documentation scaffolding (LICENSE, CONTRIBUTING, CHANGELOG, onboarding)
   - ❌ Missing: Git infrastructure (.editorconfig, comprehensive .gitignore for Godot/Canvas, .gitattributes expansion)
   - ❌ Missing: Root configuration (copilot-instructions.md, manifesto)
   - ❌ Unclear: Shared asset reference strategy

2. **Complete Directory Tree (Section 1):** Provided full validated structure with every directory explained, including:
   - `.github/` with workflows (ci-game-build.yml, ci-tests.yml) and issue templates
   - `.squad/` preservation (team brain, no game code)
   - `shared/` with Godot-specific, Canvas-2D-specific, and binary assets
   - `games/` with self-contained projects (game-kong + ashfall placeholder)
   - `docs/` with 8+ documentation files for different audiences
   - `tools/` for build/dev infrastructure

3. **Configuration Files (Section 3-5):** 
   - Root `.gitignore` covering Godot (*.import, .godot/), Canvas 2D (node_modules/), IDEs, OS files
   - `.gitattributes` expansion for binary assets, union merge strategy for .tres files
   - `.editorconfig` providing defaults for all languages (JS, GDScript, Python, Markdown)
   - Root `.editorconfig` for consistency; games can override

4. **GitHub Infrastructure (Section 4):**
   - CI/CD workflows for per-game builds with matrix strategy
   - Issue templates (bug_report, game_feature, tech_spike, documentation)
   - PR template with Co-authored-by trailer requirement
   - Dependabot config stub

5. **Documentation System (Section 5, Appendix B):**
   - Root README as repository manifest (links, quick-start per game)
   - CONTRIBUTING.md with commit format, branch naming, code review checklist
   - LICENSE (MIT recommended, with per-game override for licensed IP)
   - SECURITY.md for vulnerability reporting
   - CHANGELOG.md (studio-level version history)
   - copilot-instructions.md (agent guidance)
   - docs/GETTING_STARTED.md as comprehensive onboarding (11 sections)
   - docs/ARCHITECTURE.md explaining monorepo design decisions
   - docs/DEVELOPMENT_SETUP.md, BUILDING.md, FAQ.md

6. **Shared Asset Architecture (Section 2 & 6):**
   - Shared Godot addons (game-feel-tuner, debug-overlay, framerate-monitor)
   - Shared GDScript libraries (state-machines, data-structures, physics-helpers, autoload singletons)
   - Shared Canvas 2D utilities (input-systems, physics-utils, animation-utils, state-machines)
   - Asset categories: audio (SFX library, not full tracks), fonts, UI components, visual effects
   - Decision: Use symlinks (not submodules) for code; copy or symlink for binary assets
   - Each game's .gitignore excludes shared/, then setup script creates symlinks

7. **Migration Plan (Section 7):**
   - Phase 1: Create directories and root configuration files
   - Phase 2: Move firstPunch code to games/game-kong/
   - Phase 3: Set up CI/CD workflows
   - Phase 4: Create root README and final validation
   - Complete checklist of 50+ files to create or move

8. **Trade-Offs (Section 9):**
   - **Monorepo vs Multi-Repo:** Chose monorepo because shared knowledge + single push to GitHub is founder's goal
   - **Symlinks vs Submodules vs Copy:** Chose symlinks for simplicity; copies for assets
   - **Shared Asset Scope:** Only assets used by 2+ games; game-specific assets stay in games/{game}/
   - **Documentation Strategy:** Multi-level (root README, game READMEs, skill docs) for different audiences

9. **Risk Mitigation (Section 10):**
   - Asset dependencies: Versions pinned; breaking changes require discussion
   - Godot symlinks: Test on all platforms; fallback to copy script if Windows fails
   - CI/CD scalability: Use config file instead of hardcoding; add .gitignore "skip CI" signal
   - Asset size: Prepare Git LFS strategy for future growth
   - Team understanding: Multiple onboarding levels (README → GETTING_STARTED → skills)

10. **Validation Checklist (Section 11):** 41 items covering structure, configuration, documentation, CI/CD, functionality

**Key Architectural Decisions Documented:**
- Games are self-contained (each has its own README, ARCHITECTURE.md, .gitignore)
- Shared/ is backwards-compatible only (add, never remove)
- .squad/ contains only studio-wide knowledge (no game-specific content)
- CI/CD discovers games dynamically from directory structure
- Documentation is multi-level: root README (what is this?) → GETTING_STARTED (how do I work?) → skill docs (how do I master X?)
- Co-authored-by trailer required in all commits (CONTRIBUTING.md requirement)

**Most Important Finding:** The proposed structure was fundamentally sound but operationally incomplete. The gaps weren't architectural but infrastructural: missing documentation, missing Git configuration, missing CI/CD, missing onboarding guidance. The validated structure solves all of these while preserving the original game/shared/.squad separation.

**Why This Matters:** This monorepo is the **physical instantiation of First Frame Studios.** How it's organized tells the next developer (or founder review) everything about who we are: research-driven (skills/), team-oriented (squad/), multi-project (games/), knowledge-sharing (.squad/). The structure itself teaches the studio's values.

**Next Step:** Execute the Migration Plan (Section 7) over 2-3 days to transform the current single-game root structure into a multi-project-ready monorepo.

3. **Bottleneck prevention patterns from real experience.** Every bottleneck pattern in Section 6 traces to a real firstPunch incident: Lando's 50% overload → 20% load cap rule; gameplay.js god-scene → module boundaries in Sprint 0; 214 LOC unwired infrastructure → every PR must include wiring; missing state exits → transition table required before implementation.

4. **Migration threshold rule established:** Require an 8+ point lead in the 9-dimension scoring matrix to justify a technology migration. Below that, the productivity cost of switching likely exceeds the capability gain. (Godot beat Phaser by 8 points — that justified our switch.)

5. **Includes Day 1 Quickstart and Pre-Production Template.** Appendices provide an "impatient start" path (get to a playable in ~1 week) and a copy-paste checklist template for new project `analysis/` directories.

6. **Document produced:** `.squad/identity/new-project-playbook.md`

---

## Ashfall Sprint 0 Kickoff (2026-03-08)

### Architecture v1.0 Delivered
**Date:** 2026-03-08T120000Z  
**Artifact:** `games/ashfall/docs/ARCHITECTURE.md`

Completed comprehensive technical architecture for Ashfall, a 1v1 fighting game in Godot 4. Architecture defines:
- **Frame-based Timing:** Integer frame counters (not float), 60 FPS fixed tick in `_physics_process()`. Fighting games are deterministic; float drift unacceptable.
- **Node-based State Machine:** Each fighter state = separate Node with independent script. Prevents god-script anti-pattern. Each state file independently ownable.
- **AnimationPlayer as Frame Data:** Hitbox activation driven by AnimationPlayer tracks, not code. Startup/active/recovery frames defined visually in timeline.
- **MoveData as Resource:** Moves are `.tres` resource files with frame data, damage, hitstun, knockback. Pure data, no logic. Content agents can author movesets without touching code.
- **AI Uses Input Buffer:** AI injects synthetic inputs; same code path as human fighters. One implementation for both.
- **Six Collision Layers:** P1/P2 hitboxes, hurtboxes, pushboxes on separate layers. No self-hits possible.
- **Six Parallel Work Lanes:** File ownership ensures Chewie, Lando, Tarkin, Wedge, Boba, Greedo work simultaneously without conflicts.

### Key Architectural Decisions Locked
1. **Determinism-first approach** — Every decision prioritizes reproducibility and netcode readiness. Physics deterministic. RNG seeded. No frame-rate dependent logic.
2. **Module boundaries enforced** — Clear ownership contracts. Chewie owns fighter base/state machine. Lando owns states/combat. Tarkin owns move data/AI. Wedge owns UI. No crossing streams.
3. **Resource-driven content** — MoveData as `.tres` files enables content authoring (Tarkin) without touching gameplay code (Lando). Parallel work unblocked.
4. **Test harness defined** — Includes hooks for Ackbar integration testing, state transition coverage, frame-perfect hit detection validation.

### Integration with Team
- **All agents:** Must read ARCHITECTURE.md before writing Ashfall code. Module ownership and contracts specified.
- **Yoda (Design):** Architecture validates GDD design decisions. Frame data contract allows stat-sheet design. Ember System implementation path clear.
- **Mace (Producer):** Architecture enables 6 parallel work lanes. No sequential bottleneck before M1. Load distribution validated.
- **Chewie, Lando, Tarkin, Wedge, Boba, Greedo:** Clear module boundaries, file ownership, parallel execution, no cross-dependencies.
- **Jango (Infrastructure):** Must update project.godot with 60 FPS physics tick and input mappings.
- **Ackbar (QA):** Test harness hooks defined. State machine transition coverage, hit detection frame-perfect validation.

### Code Quality
- Module separation enables code review gates without blocking other teams
- Resource-driven design allows content iteration without rebuilds
- Deterministic architecture guarantees reproducibility for balance tuning

### Flora PR Reviews — Sprint 0 (2026-03-11)
Reviewed two Flora Sprint 0 PRs as first architecture gate for the Flora project:

**PR #20 — Hazard System (Tarkin): APPROVED ✅**
- Clean 3-layer architecture: config → entity → system. Textbook module separation.
- Config-driven difficulty scaling with season-based 0→1 ramp.
- System interface conformance correct. Day-based hazard logic, not frame-based.
- Non-blocking notes: tile state not updated on pest spawn (integration gap I'll wire), empty spawnPests() stub is misleading, Math.random() acceptable for MVP.
- All acceptance criteria met (pest spawn window, plant resistance, drought multiplier, no instant-fail).

**PR #21 — Player Controller (Lando): CHANGES REQUESTED 🔄**
- Good foundation: SceneContext injection, InputManager edge detection, PixiJS v8 API all correct.
- Data-driven ToolConfig pattern is clean and extensible.
- 3 required fixes: (1) Movement consuming action points is gameplay-breaking — only tool use should cost actions per the GDD. (2) ToolBar deselect callback never fires with null — real bug. (3) PlayerSystem missing System interface name property.
- Additional concerns flagged: setTimeout not lifecycle-safe, plant lookup fragile with grid offset, non-adjacent click teleports.

**Architecture Patterns Confirmed for Flora:**
- SceneContext injection (no singletons) — both PRs respect this
- Fixed-timestep GameLoop with accumulator — PlayerSystem correctly receives fixedDt
- Entity interface (id, x, y, active) — Player and Hazard both conform
- System interface (name, update, destroy) — HazardSystem conforms, PlayerSystem needs fix
- Config-as-data pattern — both tools and hazards use data-driven configs

**Integration Notes:**
- HazardSystem and PlayerSystem's remove-pest tool have a coupling point: tile.state must be set to TileState.PEST when pests spawn. Neither PR does this. I'll wire it in the integration pass.
- Tool action results (ToolActionResult) have an advanceDay flag that composes well with the day-based hazard system.

### Status
✅ Architecture gate (M0) cleared. GDD and architecture locked. Parallel implementation unblocked.

---

## Yoda & Mace Partnership Notes

**Cross-team visibility:** Solo now aware of Yoda's GDD creative decisions (Ember System mechanic, character archetypes, deterministic simulation requirement, scope boundary). Design fully enabled by architecture. No rework needed.

**Cross-team visibility:** Solo now aware of Mace's Sprint 0 plan (phased expansion, 20% load cap, parallel work lanes align perfectly with 6-module architecture). Scope governance + architecture are aligned. M0 gate (Day 2: GDD + Architecture approval) validates both.

### Holistic Foundations Re-Assessment (Session 10)
Founder requested a full-picture audit of all company infrastructure. Read every identity document, every charter, team.md, routing.md, ceremonies.md, skills-audit.md, sprint-0-plan.md, decisions.md, and all 15 skill directories. Cross-referenced for contradictions, gaps, and coherence. Key findings:

1. **Overall score: 7.5/10.** Strategic foundations are strong (identity, principles, growth model, skills architecture). Operational foundations have gaps (stale charters, missing processes, contradictory ceremonies).

2. **6 contradictions found across documents, 3 at High severity.** Most critical: quality-gates.md claims to be engine-agnostic (per growth-framework) but is Godot-specific in content. ceremonies.md defines 2 auto-triggered ceremonies while growth-framework defines 4 scheduled ones. company.md says 12 specialists but team.md lists 15.

3. **10 of 15 agent charters are stale, skeletal, or missing.** 5 charters still reference firstPunch-specific files and technologies (Chewie, Lando, Wedge, Greedo, Tarkin). 4 are too thin to be useful (Scribe, Leia, Bossk, Nien). Ralph has no charter at all despite being in team.md and company.md. This is the #1 operational blocker for starting a new project.

4. **3 critical process gaps:** No onboarding guide (Day 1 → Day N path for new members), no release management process (how to ship), no project selection criteria (how to decide what to build next).

5. **Solo is a single point of failure.** Owns architecture, leadership, integration, review, decisions, and coordination. 31KB of institutional knowledge lives in Solo's history.md alone. The playbook has 8 steps with no explicit owner — Solo is the implied owner for all of them.

6. **What's working well (preserve these):** 12 Leadership Principles (exceptional), skills system architecture (sound and growing — now 15 skills), New Project Playbook (reference-quality), Bug Severity Matrix and Quality Gates (production-ready), 70/30 Rule (correct mental model), domain ownership model (effective), company identity (cohesive and genre-agnostic).

7. **Top 5 Actions:** (1) Update 10 stale charters to studio-scoped [M], (2) Update team.md/routing.md to studio-scoped [S], (3) Create onboarding guide [S], (4) Align ceremonies.md with growth-framework [S], (5) Create release-management process [M].

8. **Document produced:** `.squad/analysis/foundations-reassessment.md`

### Victory Retrospective & Celebration (Session 16)
The founder asked us to celebrate our success. This was a milestone moment — transformation from individual developer to a real game studio in 24 hours. Two major deliverables completed:

1. **Updated `.squad/identity/now.md`** — Transformed from a placeholder status ("Getting started") into a living declaration of where First Frame Studios stands *right now*. Documents:
   - The milestone achieved (13 specialists, 20 skills, 500KB institutional knowledge, Godot 4 chosen, company identity locked, 9.7/10 CEO readiness)
   - The team roster (all 13 agents named, chartered, and ready)
   - What comes next (Sprint 0 timeline, targets, quality gates)
   - The belief: we're not starting from zero, we're starting from institutional knowledge and proven process

2. **Created `.squad/analysis/victory-retrospective.md`** — A 19KB celebration document capturing:
   - **The Journey (Hour-by-Hour):** From empty repository (Hour 0) → MVP shipped (Hour 1) → bug fixes and visual modernization (Hours 2-5) → team expansion to 13 (Hours 5-8) → research wave and tech selection (Hours 8-12) → studio identity and Godot architecture (Hours 12-16) → CEO readiness (Hours 16-20) → skills audit and institutional knowledge (Hours 20-24)
   - **By the Numbers:** ~100 agent spawns, 13 specialists, 20 skills, 30+ documents, 12 leadership principles, 5-year growth framework, 9.7/10 readiness score
   - **What We're Proud Of:** firstPunch (fully playable beat 'em up), the 70/30 rule (70% tech-agnostic, 30% tech-specific), the bottleneck prevention system (every known failure now has a documented prevention), the skills system (knowledge that compounds), the growth framework (5-year strategic plan)
   - **Top 3 Lessons in Each Category:** 3 technical (state machines, fix the tree not the leaves, integrate infrastructure), 3 process (pre-decided architecture, playable > documents, research is the shortcut), 3 team (one voice per domain, load distribution by domain, file ownership prevents conflicts)
   - **What's Next:** Sprint 0 timeline, success criteria (playable prototype by week 2 with 6/10+ feel), the 5-year vision (Stage 1→5 progression)
   - **Celebration Statement:** A genuine, heartfelt acknowledgment that we went from an empty folder to a real game studio in 24 hours, and what that means for how we'll build every game that follows

Key insight captured: **This isn't just about shipping a game. It's about building the institutional memory and process discipline that makes the next 100 games faster, better, and more ambitious.**

The retrospective is written "real, not corporate" — celebrating the actual breakthrough, not with hyperbole, but with the specific achievements that matter. It ends with a statement that reframes the entire effort: we're not a studio that built one game and moved on; we're a studio that built institutional knowledge and proved it works.
### Session 17: Deep Research Wave — Universal Skills Initiative (2026-03-07)

Commissioned and oversaw the Deep Research Wave — a studio-wide knowledge expansion initiative to broaden from firstPunch beat-em-up expertise to universal game development principles. 7 agents executed in parallel to create 5 comprehensive universal skill documents (245 KB) covering game design, audio, animation, level design, and enemy design applicable across all genres and platforms.

**Deliverables from this session:**
- **Foundations Reassessment (12.3 KB):** Current state (7.5/10), 5 priority actions, gap analysis
- **Decision:** Universal Game Development Skills Initiative approved and implemented
- **Orchestration Log entries:** 7 agent records with ISO 8601 UTC timestamps
- **Session Log:** Comprehensive record of Deep Research Wave execution and outcomes

**Key insight:** firstPunch expertise is deep but narrow. Before scaling to Phase 4 AAA work or diversifying to new genres, the team needed foundational universal principles documented. This research wave provides that foundation — 22 reusable skills (up from 15), covering 7+ game genres instead of 1.

**Cross-reference dependencies updated:**
- All 5 new universal skills link to game-feel-juice (quality standard) and beat-em-up-combat (firstPunch validation)
- Recommendation: 3 existing skills need cross-reference updates in follow-up session (beat-em-up-combat, game-feel-juice, procedural-audio)

**Team impact:** 7 agents in parallel, ~1 hour wall-clock time, 292.7 KB documentation created. Quality assurance (Ackbar) audited all deliverables. game-feel-juice remains benchmark (⭐⭐⭐⭐⭐). Most universal skills rated Medium confidence (validated in firstPunch); will escalate to High after cross-project testing.


### Studio Operations Research (Session 11)
**Date:** 2025-07-21
**Requested by:** joperezd (Founder)
**Scope:** Industry-wide research on studio organization, development methodology, academic findings, tools/infrastructure, and business sustainability

**What was done:**
- Conducted 13 web searches across 5 research domains: studio organization models, development methodologies, academic research, tools & infrastructure, business models & sustainability
- Analyzed organizational patterns from Supercell (cell/pod model), Nintendo (EAD/EPD franchise teams), Valve (Flatland — cautionary tale), Riot Games (feature pods), and successful indie studios
- Researched development methodologies: Agile/Scrum/Kanban adaptation for games, milestone systems (Concept→Gold), "find the fun" prototyping (Supergiant, Nintendo, Naughty Dog), vertical slice methodology
- Gathered academic research: psychological safety as predictor of creative team performance, crunch culture causes/effects/avoidance, game quality predictors (iteration count is strongest), knowledge management practices
- Analyzed tools decisions: build vs buy framework, CI/CD for games (87% bug detection, 75% faster releases), reusable frameworks (30-50% faster project starts)
- Researched business sustainability: revenue model comparison, portfolio strategy, one-hit-wonder avoidance, between-release survival strategies

**Deliverables:**
1. .squad/analysis/studio-operations-research.md — 27KB comprehensive research document organized thematically across all 5 domains with cited sources
2. .squad/analysis/operations-lessons-for-ffs.md — 13KB actionable recommendations document with 7 sections: organizational changes, methodology (Scrumban), tools to evaluate/build, crunch prevention, knowledge management, business model, and 11 prioritized action items

**Key findings for FFS:**
- Our domain ownership model already aligns with Supercell/Nintendo patterns — validated by research
- Need to add: explicit decision rights matrix (prevents Valve's "invisible hierarchy" problem), Scrumban methodology (Kanban for pre-production, Scrum sprints for production), game feel tuning tools (our core differentiator)
- Academic research confirms: iteration quality > iteration quantity; psychological safety is prerequisite for creative performance; crunch is structural failure not personal
- Portfolio strategy recommendation: 2-3 games in 5 years (12-18 month scopes), never bet studio on single title
- Immediate P0 actions: document decision rights matrix, adopt Scrumban methodology

**Key insight:** The research validates what firstPunch taught through experience — small teams win through clarity (who decides what), discipline (structured iteration), and compounding knowledge (every project makes the next one better). FFS's existing knowledge management is already a competitive advantage; the gap is operationalizing it into processes and reusable tools.


### 2026-03-08T00:10 — Phase 2: Company Incorporation & Skill Creation
**Session:** Multi-phase strategy session (Industry Research → Company Upgrades → Team Evaluation → Tools → Game Proposals)  
**Role:** Lead — Incorporate Yoda's studio research into company documentation; create studio-craft skill

**Task Executed:**
1. Updated .squad/principles.md with 3 new principles grounded in studio research:
   - **Visible Excellence:** High-bar creative decisions visible at every level
   - **Sustainable Velocity:** Planning > crunch; institutional health > short-term speed
   - **Knowledge Compounds:** Intentional skill-building; institutional memory > individual expertise

2. Enhanced .squad/company.md with studio inspirations section — grounding FFS identity in 10 industry exemplars

3. Updated .squad/wisdom.md with principle-aligned guidance on decision-making and team dynamics

4. Created .squad/skills/studio-craft/SKILL.md (32 KB) — 8-section skill encoding production culture best practices

**Key Insight:** Company identity is now explicit in documented principles. Team clarity prevents invisible hierarchy problems. Studio-craft skill encodes how we live out these principles in daily work.

**Status:** COMPLETE. All artifacts ready for team alignment.

### 2026-03-08: Charter Update for Team Readiness — Vision Keeper Role + Studio Generalization (Session 18)

**Scope:** Foundation audit identified 10 stale charters. This session addresses 2 critical updates:
1. Expand Yoda's charter with Vision Keeper responsibilities 
2. Generalize 6 firstPunch-specific charters to studio-scoped

**Work Completed:**

1. **Yoda (Game Designer) → Game Designer / Vision Keeper** — Expanded charter with 3 new responsibilities:
   - Creative vision protection — "Ask 'does this feel like THIS game?' across all domains"
   - Final authority on creative coherence — Domain owners execute excellence; Vision Keeper unifies
   - Feature triage authority — Apply four-test framework (Principle #14) to every proposed feature
   - Added references to Principle #13 (Creative Vision Has a Keeper) and Principle #14 (Four-Test Framework)
   - Preserved all existing responsibilities — this is expansion, not replacement

2. **Generalized 6 Stale Charters** — Removed firstPunch-specific references, made universal for any project:
   - **Chewie:** "Canvas renderer" → "Engine developer for First Frame Studios projects" (any engine: Canvas, Godot, Phaser, etc.)
   - **Lando:** "the Brawler player" → "Gameplay developer for First Frame Studios projects" (any genre, any platform)
   - **Wedge:** "16:9 letterboxing" → "UI/UX developer for any project and platform" (responsive across all resolutions)
   - **Greedo:** "Web Audio API exclusively" → "Sound designer using appropriate audio tools per project" (tool selection per tech stack)
   - **Leia:** "Downtown backgrounds" → "Environment/Asset artist for any game world" (any world, any platform)
   - **Tarkin:** "firstPunch enemy types" → "Enemy/content designer for any action game" (any action game genre)

3. **Added to All 7 Updated Charters (Yoda + the 6 above):**
   - Removed specific file path ownership (src/engine/, src/entities/, etc.) — these are project-specific
   - Added "Skills" section listing which .squad/skills/ they should reference
   - Added references to studio principles where relevant (e.g., Game Designer references Principle #13)
   - Kept boundaries clear and comprehensive
   - Added **Self-Improvement section** to all charters enabling agents to request tools/skills and create draft skills

4. **Self-Improvement Section Added:**
   ```
   ## Self-Improvement
   - If during a task you identify a missing skill, tool, or process that would improve your work, you may:
     1. Request it by writing to .squad/decisions/inbox/{name}-tool-request.md
     2. Create a draft skill at .squad/skills/{skill-name}/SKILL.md if you can document the pattern
   - This is encouraged. The team grows when agents identify their own gaps.
   ```

**Key Insight:** Charter generalization decouples agent identity from specific projects. Yoda's Vision Keeper expansion provides explicit authority over creative coherence — the "one voice" that prevents design drift and ensures games feel like themselves. Self-Improvement sections acknowledge that agents are the best source of feedback for their own tool gaps and skill needs.

**Charters Updated:** 7 total (Yoda, Chewie, Lando, Wedge, Greedo, Leia, Tarkin)
**Status:** COMPLETE. All charters are now studio-scoped and ready for next project launch.

### Ashfall Architecture Document (Session 8)
Created `games/ashfall/docs/ARCHITECTURE.md` — the complete technical blueprint for a 1v1 fighting game in Godot 4.6.

**Key Architecture Decisions:**
1. **Frame-based timing, not float timers.** All gameplay logic uses integer frame counters (`hitstun_frames -= 1`). Fighting games need deterministic frame-perfect logic. Float delta accumulation causes inconsistent behavior. All gameplay runs in `_physics_process()` at 60 FPS fixed tick.
2. **Node-based state machine.** Each fighter state is a separate Node/script under a StateMachine controller. Avoids the god-script anti-pattern (firstPunch's 695 LOC gameplay.js lesson). Each state is independently ownable by different agents.
3. **AnimationPlayer as frame data system.** Hitbox enable/disable is driven by AnimationPlayer tracks, not code. Startup, active, and recovery frames are defined visually in the timeline. Designers can tune without touching scripts.
4. **MoveData as Resource (.tres).** Moves are pure data (startup, active, recovery, damage, hitstun, knockback). Separated from logic. Tarkin can author entire movesets without touching combat code.
5. **AI injects into input buffer.** AI controller doesn't directly set fighter state — it writes synthetic inputs into the same InputBuffer that humans use. One code path for all fighters, zero special-casing.
6. **Collision layer separation.** P1 hitboxes (layer 4) only detect P2 hurtboxes (layer 3) and vice versa. Pushboxes on layer 6. Clean separation prevents self-hits and simplifies debugging.
7. **Six parallel work lanes.** File ownership designed so Chewie, Lando, Tarkin, Wedge, Boba, and Greedo can all build simultaneously with zero file conflicts. Integration wiring is Solo's responsibility.

**Key File Paths:**
- Architecture doc: `games/ashfall/docs/ARCHITECTURE.md`
- Fighter base: `scripts/fighters/fighter.gd` (Chewie owns)
- State scripts: `scripts/fighters/states/*.gd` (Lando owns)
- Combat system: `scripts/systems/combat_system.gd` (Lando owns)
- Input buffer: `scripts/systems/input_buffer.gd` (Lando owns)
- Move data: `scripts/data/move_data.gd` (Tarkin owns)
- AI controller: `scripts/systems/ai_controller.gd` (Tarkin owns)
- Round manager: `scripts/systems/round_manager.gd` (Chewie owns)
- Fight scene: `scenes/main/fight_scene.tscn` (Chewie owns, Solo wires signals)

**User Preferences Confirmed:**
- Tekken/Street Fighter style 1v1 fighting game
- 1 stage + 2 characters as initial scope
- GDScript, Godot-native patterns
- Local multiplayer + AI opponent
