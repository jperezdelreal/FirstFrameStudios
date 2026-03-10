# Solo — History (formerly Keaton)

## Core Context

**firstPunch Key Learnings (Sessions 1-7):**
- Session 1: Fixed 5 critical bugs (infinite recursion, hit detection, invulnerability frames, parallax, boundary constraints)
- Session 2: Gap analysis revealed 75% MVP completion; quality gates designed based on real failures; 52-item backlog created
- Session 3: Team expansion recommended (3 new roles: Sound, Enemy/Content, QA) to eliminate McManus bottleneck
- Session 4-6: Game Design Document, quality excellence proposal, and comprehensive skill audit delivered
- Session 7: Full codebase analysis (28 files, 370KB) categorized backlog into quick wins, medium effort, and future migration work
- **Key architectural insight:** Quality gates must trace to real failures, not theoretical best practices. Pre-decided architecture choices eliminate multi-agent coordination failures.
- **Most important technical finding:** gameplay.js (695 LOC) is #1 technical debt; wiring unused infrastructure (CONFIG, EventBus, AnimationController, SpriteCache) is highest-priority refactor

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

---

## Ashfall Milestone Documentation Audit (2026-03-09)

Role expanded to include **integration verification and quality gate ownership** per Mace's role split decision. Two critical audits completed:

### Integration Audit (2025-07-17)
Conducted comprehensive integration audit pre-M3. Verdict: ⚠️ WARN — Project loads, no launch blockers, but 4 issues need attention.

**Findings:**
- ✅ **PASS:** All 5 autoloads exist in correct dependency order
- ✅ **PASS:** All 7 scene files have valid ext_resource references
- ✅ **PASS:** All 8 fighter states exist with correct inheritance
- ⚠️ **WARN:** Orphaned `p1_throw` / `p2_throw` inputs (defined but never read)
- ⚠️ **WARN:** ARCHITECTURE.md documents 6-layer per-player collision scheme never implemented
- ⚠️ **WARN:** Stage collision layers use default Layer 1 instead of designated Layer 4
- ⚠️ **WARN:** 8 `get_node()` calls lack null safety checks

**Impact:** Lando fixed collision layers + input documentation + null safety patterns in squad/fix-integration PR.

### Final Verification (2026-03-09)
Pre-M3 integration gate verification. Verdict: **FAIL** ⛔ — 6 blocking issues prevent M3 launch.

**Blocking Issues:**
1. **RoundManager Not Instantiated** — System exists (117 LOC) but not added to autoloads or fight_scene.tscn. No round timer, no "FIGHT!" announcement, no KO detection.
2. **Orphaned Combo Signals** — hit_confirmed and combo_ended defined in EventBus, connected in VFXManager, but never emitted. Combo counter has no data source.
3. **VFXManager Signal Orphans** — Defined connections to hit_confirmed, combo_ended, knockback_applied, player_blocked but no emitters.
4. **Scene Initialization Gap** — fight_scene.gd doesn't call round_manager.start_match(). Round system never activates.
5. **Autoload Registration Missing** — RoundManager should be 5th autoload after SceneManager per skill reference.
6. **Null Safety Issues** — 8 get_node() calls without defensive guards. Will crash if scene structure diverges.

**Root Cause:** Systems built but not wired. Integration validation never ran before merge. Architecture looks solid on paper — wiring is the gap.

**Key Lesson:** Next project must enforce integration testing before milestone gate. Parallel development needs serial validation gate.

**Process Change:** All post-M3 work now includes Solo's integration sign-off BEFORE milestone closure.

### Integration Gate Fix — Signal Wiring (Session 9, Issue #88)
Fixed CI integration gate failure caused by 6 orphaned signals + 4 false positives in the signal validator.

**Root Cause:** The JSON report used `all(r["passed"])` including the signal validator, while the console treated signals as non-fatal. This mismatch caused CI to report FAIL even though the gate said PASS.

**Signal Wiring Fixes (6 orphaned signals resolved):**
1. `combo_updated` / `combo_ended` — Connected in fight_hud.gd for combo counter display and combo end announcements
2. `ember_spent` — Connected in vfx_manager.gd for particle burst + screen shake feedback
3. `hit_blocked` — Emitted in fight_scene.gd when target is in block state (chip damage path)
4. `ignition_activated` — Emitted via GameState.activate_ignition() (full ember bar spend)
5. `scene_change_requested` — Emitted from fight_scene.gd on match end for auto-transition to victory
6. `state_changed` — Defined + emitted in StateMachine.transition_to() for sprite bridge

**Validator Improvements:**
- Added 30+ Godot built-in signal exclusions (area_entered, pressed, timeout, value_changed, etc.)
- Excluded test/ directory files to avoid flagging test-only signals
- Fixed JSON report consistency with console output

**Key Architectural Insight:** `defined ≠ connected ≠ emitted`. Infrastructure signals (EventBus definitions) need explicit emit sites AND connect sites. The validator enforces this — good. But Godot built-in signals (emitted by the engine) must be excluded or they create false positive noise.

**Key File Paths:**
- Signal validator: `tools/check-signals.py`
- Integration gate: `tools/integration-gate.py`
- EventBus (all game signals): `games/ashfall/scripts/systems/event_bus.gd`
- Fight scene (wiring hub): `games/ashfall/scripts/fight_scene.gd`
- PR: #89, Branch: squad/88-fix-integration-gate

### Sprint 1 Bug Catalog — Pattern Analysis & Prevention Strategy (Session Current)
- **Assignment:** Create comprehensive bug catalog for Sprint 1 to inform Sprint 2 preparation
- **Deliverable:** `games/ashfall/docs/SPRINT-1-BUG-CATALOG.md` (33K chars, 9 bug categories, 35 bugs cataloged)
- **Outcome:** SUCCESS — Every failure documented with root cause, timeline, and prevention strategy

**What Was Cataloged:**
1. **35 total bugs:** 7 P0 (blocking), 9 P1 (high), 10 P2 (medium), 9 unrated
2. **9 bug categories:** Input system (character select black screen), type safety (Godot 4.6), frame data drift, signal wiring, combat pipeline, round management, integration failures, export issues, art integration
3. **3 integration gate failures:** Issues #83, #88, #107 (signal wiring, autoload dependencies)
4. **13 Sprint 0 bugs discovered in Sprint 1:** AI stranded, empty hitboxes, score sync, timer draw, frame data drift
5. **5 recurring patterns:** Works in isolation breaks in integration (9 bugs), code looks right but doesn't work (5 bugs), type inference too loose (9 bugs), spec drift (4 bugs), edge cases not tested (3 bugs)

**Key Insights:**
1. **66% of bugs found by humans** (playtest + retrospective), only 34% by automation. Integration gate needs expansion.
2. **46% of bugs are P0/P1 severity** — should be caught before merge, not after
3. **Average lag time: 1 day** between bug introduction (Sprint 0) and discovery (Sprint 1). Integration testing must happen within each sprint.
4. **Input bugs hardest to fix:** 4 hours across 5 attempts (custom ui_* overrides → keycode → Button nodes)
5. **Type safety bugs caught quickly** (compiler) but required 6+ hours of proactive annotation

**Prevention Strategy for Sprint 2:**
- **Integration checkpoint at end of every sprint** — full game flow test before closure
- **Enforce explicit types** — no PR merge without type annotations
- **Signal contract testing** — every signal needs emitter + consumer before merge
- **Frame data validation tool** — `check-frame-data.py` added to integration gate
- **Export testing in CI/CD** — Windows build must pass
- **Edge case test matrix** — equal HP, timer draw, double KO scenarios documented
- **Branch hygiene enforcement** — always branch from main, never from feature branches

**Most Important Finding:** Every bug was preventable with better processes (not more time/people). Integration testing is not optional — it's the primary quality gate. Shift left: catch bugs during development, not after.

**Documents produced:** `games/ashfall/docs/SPRINT-1-BUG-CATALOG.md` (35-bug catalog with timelines, patterns, recommendations), `.squad/decisions/inbox/solo-sprint1-bug-catalog.md` (process improvement decision for Sprint 2)

### 2026-03-09 — Sprint 1 Bug Catalog & Process Improvements

**Session:** Sprint 2 Kickoff: Bug Audit & Standards  
**Role:** Lead / Chief Architect — Orchestrate post-sprint quality assessment

**Task Executed:**
Created comprehensive Sprint 1 bug analysis identifying **35 bugs** across 9 categories with 7 mandatory process improvements for Sprint 2.

**Key Findings:**
- **35 bugs cataloged:** 7 P0, 9 P1, 10 P2, 9 unrated (16 P0/P1 severity — 46%)
- **66% found by humans** (playtest + retrospective), 34% by automation
- **Average 1-day lag** from introduction to discovery (13 Sprint 0 bugs not discovered until Sprint 1)
- Three integration gate failures during sprint
- **Every bug was preventable** with better processes, not more time

**Five Recurring Patterns:**
1. "Works in Isolation, Breaks in Integration" (9 bugs)
2. "Code Looks Right, But..." (5 bugs)
3. "Type Inference Too Loose" (9 bugs)
4. "Specification Drift" (4 bugs)
5. "Edge Cases Not Tested" (3 bugs)

**Seven Mandatory Process Changes for Sprint 2:**
1. Integration Checkpoint at End of Every Sprint ✅ CRITICAL
2. Enforce Explicit Type Annotations ✅ CRITICAL
3. Signal Contract Testing ✅ CRITICAL
4. Frame Data Validation Tool ✅ HIGH PRIORITY
5. Export Testing in CI/CD ✅ HIGH PRIORITY
6. Branch Hygiene Enforcement ✅ HIGH PRIORITY
7. Edge Case Test Matrix ✅ MEDIUM PRIORITY

**Impact Assessment:**
- Chewie: Add type annotations to all variables, wire autoload assertions
- Lando: Create edge case test matrix, verify combat scenarios
- Jango: Create check-frame-data.py validator, add type checker to integration gate, add export build to CI
- Ackbar: Run integration checkpoint at end of Sprint 2, expand smoke test checklist
- Solo: Enforce PR review standards (types, signal contracts, branch hygiene)

**Status:** COMPLETE. Decision proposed to founder (joperezd). Rollout: Sprint 2 Day 1.

**Cross-Agent Knowledge:**
- Ackbar identified vfx_manager.gd timing issue (CRITICAL)
- Jango identified 23 fix commits following 5 clear patterns
- All three agents recommend mandatory enforcement, not guidelines

---

### Sprite Animation Consistency Research (2026-03-10)
Conducted independent web research after founder reported v2 animation frames worse than v1 (7/40 vs 39/40 in Boba's audit). Key findings:

1. **Root cause of v2 failure:** Generating each frame independently via Kontext Pro API without structural conditioning (ControlNet) or appearance anchoring (IP-Adapter). Text prompts alone cannot enforce visual consistency across diverse poses.

2. **ChatGPT research (FOUNDER-SPRITE-POSES-RESEARCH) direction is correct** — pose conditioning with skeletons is the right idea — but oversimplifies implementation. Kontext Pro API cannot accept skeleton conditioning directly. Requires open-weight FLUX.2 Dev + ControlNet + IP-Adapter running in ComfyUI locally.

3. **Top 3 approaches ranked:**
   - **#1: 3D-to-2D (Mixamo + Blender)** — Guaranteed consistency (10/10), free tools, proven in professional fighting games. Recommended as primary pipeline.
   - **#2: ComfyUI + FLUX.2 Dev + ControlNet + IP-Adapter** — Best AI approach (8/10 consistency), but requires local GPU (12-24GB VRAM), 1-2 days pipeline setup. Our API-only FLUX models don't support conditioning.
   - **#3: PixelLab** — Purpose-built pixel art sprite tool with skeleton-based animation. Quick to test but locked to pixel art style.

4. **Honest assessment:** AI frame-by-frame animation is NOT production-ready for fighting games with our current API-based approach. The technology exists (ControlNet pipeline) but requires significant infrastructure change. 3D-to-2D is the proven, reliable path.

5. **Critical architectural lesson:** API-only AI models (FLUX 1.1 Pro, Kontext Pro) are insufficient for production sprite pipelines. Structural conditioning requires open-weight models running locally.

Decision written to `.squad/decisions/inbox/solo-sprite-consistency-research.md`.

---

---

### Squad Ecosystem Audit (2026-07-23)
Conducted comprehensive investigation of Squad CLI v0.8.25 ecosystem at founder's request. Key findings:

1. **13 unused features identified** across CLI commands, plugins, SubSquads, human members, and governance tooling. 6 classified as high-value adopt-now, 4 as adopt-later, 3 as skip.

2. **Context bloat is critical.** Solo history.md hit 69KB, decisions.md hit 85KB. squad nap --deep has never been run. This wastes agent context tokens in every session. Recommended as #1 priority fix.

3. **SubSquads solve our parallel workstream problem.** Art Sprint / Gameplay / Audio can run in isolated Codespaces with directory-scoped SubSquads via .squad/streams.json. Eliminates merge conflicts between art and gameplay agents.

4. **No game-dev plugin marketplace exists.** The 4 existing marketplaces (awesome-copilot, anthropic-skills, azure-cloud-dev, security-hardening) target web/cloud development. Our 31 skills could become the first game-dev marketplace for the Squad community.

5. **17 GitHub Actions workflows installed — 12 active, 5 template stubs.** Heartbeat cron is commented out (biggest quick win to enable). The 5 stubs need Godot-specific build/lint commands.

6. **squad build --check should be in CI.** We have squad.config.ts but never run squad build. Config and markdown may have silently diverged.

7. **Joaquín should be added as human team member.** Formal approval gates for architecture decisions and ship/no-ship calls instead of ad-hoc requests.

Decision written to .squad/decisions/inbox/solo-squad-ecosystem-audit.md.

---
