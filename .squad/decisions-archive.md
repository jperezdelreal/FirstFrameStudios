# Decisions Archive

> Archived decisions from Ashfall, firstPunch, and other completed/shelved projects.
> Preserved for institutional knowledge. See decisions.md for active studio decisions.

---

### Chewie — Fighter Engine Infrastructure Decisions (2025-07-22)
**Author:** Chewie (Engine Developer)  
**Status:** Proposed  
**Scope:** Ashfall — fighter state machine, hitbox/hurtbox, round manager

Technical architecture decisions for Ashfall combat engine:

1. **Simplified Collision Layers (4 instead of 6)** — Using scaffold's existing 4 layers (Fighters, Hitboxes, Hurtboxes, Stage) for local play. Will expand to 6-layer per-player scheme when needed for 2v2 or complex self-hit prevention.
2. **Node Names Without "State" Suffix** — States named "Idle", "Walk", "Attack" (not "IdleState"). Makes transition calls clean: `transition_to("idle")`.
3. **Frame-Phase Attack State (Temporary)** — AttackState uses frame counters for hitbox timing. Will switch to AnimationPlayer-driven activation when Tarkin creates MoveData resources.
4. **Dual Signal Emission in RoundManager** — Both local signals (for FightScene wiring) AND EventBus global signals (for UI/VFX/audio decoupling). Slight redundancy for significant decoupling benefit.
5. **Input Wrappers (Not InputBuffer Yet)** — Placeholder thin wrappers over Input singleton, keyed by player_id. Lando will replace with full InputBuffer system per ARCHITECTURE.md.

**Impact:** Lando extends these with motion detection. Tarkin creates MoveData resources. Wedge wires signal connections. Solo reviews collision expansion path.

---

### Lando — Fighter Controller + Input Buffer Architecture (2025-07-21)
**Author:** Lando (Gameplay Developer)  
**Status:** Implemented  
**Scope:** Ashfall — input system and fighter gameplay layer

Core input system decisions:

1. **InputBuffer Routes ALL Input** — All fighter input flows through InputBuffer ring buffer (8-frame / 133ms leniency). Enables buffered inputs, motion detection, consume mechanics, AI injection, deterministic replay.
2. **Controller Handles Attacks, States Handle Movement** — FighterController owns attack priority (throw > specials > normals). States handle movement transitions (idle ↔ walk ↔ crouch ↔ jump). Separation prevents rewriting state logic.
3. **Motion Priority: Complex Beats Simple** — DP (→↓↘) beats QCF (↓↘→). Priority order: double_qcf > hcf/hcb > dp > qcf/qcb. Matches SF6/Guilty Gear standard.
4. **MoveData as Pure Resource** — Moves are `.tres` resource files. Designers tune frame data in Inspector without touching GDScript. Each character's moveset is exportable.
5. **8-Frame Input Leniency** — Sweet spot: generous enough for casual players, tight enough for precision-play pros. Tunable via `InputBuffer.INPUT_LENIENCY`.
6. **SOCD Resolution** — Left+Right = Neutral, Up+Down = Up (jump priority). FGC standard.

**Why:** "Player Hands First" — InputBuffer is the invisible engineering separating responsive from broken feeling.

---

### Lando — Integration Fixes (2025-07-17)
**Author:** Lando  
**Status:** PR Created  
**Scope:** Input & collision domain integration

Fixed integration issues:
1. **Removed Orphaned Throw Inputs** — p1_throw / p2_throw defined in project.godot but never read. Throws use LP+LK simultaneous press (fighter_controller.gd).
2. **Updated Collision Layer Documentation** — ARCHITECTURE.md documented 6-layer scheme never implemented. Updated to reflect actual 4-layer shared scheme in code.
3. **Fixed Stage Collision Layers** — Stage StaticBody2D now on Layer 4 (Stage), fighters detect Layer 4. Was working by accident with default Layer 1.
4. **Input Buffer Configuration Exported** — Converted BUFFER_SIZE, INPUT_LENIENCY, SIMULTANEOUS_WINDOW to @export for runtime Godot Inspector tuning.

**Impact:** Collision detection now explicit. Input buffer easily tunable for playtesting.

---

## Ashfall Art Sprint Directives (2026-03-09)

### Jango — GitHub Issues Infrastructure for Ashfall Sprint 0 (2025-07-24)
**Author:** Jango (Tool Engineer)  
**Status:** Implemented  
**Scope:** Ashfall project tracking — affects all agents

GitHub Issues setup as PM backbone for Sprint 0 in jperezdelreal/FirstFrameStudios:

1. **Milestone:** "Ashfall Sprint 0" groups all sprint work
2. **24 Labels:** Structured filtering system:
   - `game:ashfall` — per-game filter (monorepo support)
   - `priority:p0/p1/p2` — critical path tiers
   - `type:feature/infrastructure/art/audio/design/qa` — work categories
   - `squad:{agent}` — 14-agent ownership (one per agent)
3. **13 Issues (#1–#13):** Critical path tasks from SPRINT-0.md with full descriptions

**Why:** Every agent filters by their squad label. Milestone view shows sprint progress. Acceptance criteria self-validate completion. `game:ashfall` label future-proofs for multi-game monorepo.

---

### Solo — Integration Audit (2025-07-17)
**Agent:** Solo (Architect)  
**Status:** Completed  
**Verdict:** ⚠️ WARN — Project loads, no launch blockers, but issues need attention

**Autoload Check:** ✅ PASS — All 5 autoloads exist in dependency order (EventBus → GameState → VFXManager → AudioManager → SceneManager). Note: RoundManager exists but not registered as autoload.

**Scene References:** ✅ PASS — All 7 .tscn files have valid ext_resource references. Both .tres resource files valid.

**State Machine:** ✅ PASS — All 8 fighter states exist (Idle, Walk, Crouch, Jump, Attack, Block, Hit, KO). Base class inheritance correct.

**Input Map vs Controller:** ⚠️ WARN — Orphaned `p1_throw` / `p2_throw` in project.godot but never read (throws use LP+LK). Low impact, spec divergence.

**Collision Layers:** ⚠️ WARN — ARCHITECTURE.md documents 6-layer per-player scheme never implemented. Actual code uses 4-layer shared scheme. Alignment needed.

**Null Safety:** ⚠️ WARN — 8 `get_node()` calls without null checks. Should add defensive guards before M3.

**GDD Compliance:** ✅ SPOT CHECK PASS — Ember System, 6-button layout, deterministic simulation verified in code.

---

### Mace — Wiki Updates After Milestone Completion (2025-01-20)
**Author:** Mace (Producer)  
**Decision:** GitHub Wiki must be updated within 1 business day after each milestone completion

**Update Scope:**
1. **Home.md** — Milestone summary, completion status, merged PRs by category, infrastructure changes
2. **Ashfall-Sprint-0.md** — New milestone section, issue numbers, PR list, M3/M4 status
3. **Ashfall-Architecture.md** — New systems introduced, API docs, autoload details, scene links
4. **Ashfall-GDD.md** — Implementation notes, mechanics moved to "complete"
5. **Team.md** — Team size changes, review process updates

**Process:**
1. Assign one agent (Mace or Scribe) to wiki update task
2. Clone wiki repo to temp location
3. Update all pages in single commit
4. Push with: `docs: Update wiki for [Milestone Name] completion`
5. Verify wiki renders on GitHub

**Success Criteria:**
- ✅ All 5 pages updated
- ✅ Links correct, cross-references work
- ✅ Commit includes Co-authored-by trailer
- ✅ Push succeeds, wiki reflects changes within 5 minutes

**Owner:** Mace

---

### 2025-07-24: Godot Build Pipeline Architecture — Jango (Tool Engineer)

**Status:** Implemented (PR #111)

**Decision:** Automated builds and releases for Ashfall.

**Key Decisions:**

1. **Export Presets Versioned** — Needed for CI/CD (no credentials, only relative paths)
2. **Manual Godot Installation** — wget for Godot 4.6 (explicit version control)
3. **Tag-Triggered Releases** — Push v* tag → automatic build and GitHub Release
4. **Windows Desktop Only** — Initially. Can add Linux/Mac/Web later.
5. **Cross-Compilation on Ubuntu** — Linux runner exports Windows .exe

**Architecture:**
```
Tag push (v0.1.0) → GitHub Actions → Install Godot + templates 
  → Export to .exe → Zip → Create GitHub Release
```

**Deliverables:**
- `games/ashfall/export_presets.cfg` — Windows preset
- `.github/workflows/godot-release.yml` — Build workflow
- Root `.gitignore` updated

**Impact:**
- Developers: Create releases by pushing tag
- Players: Download and play without Godot
- QA: Test via manual workflow dispatch
- Future: Pipeline reusable for other projects

**Testing:** Merge PR #111 → test manual dispatch → create v0.0.1-test tag → validate

---

---

### Cel-Shade Parameters for Fighting Game Sprite Quality (Boba)
**Author:** Boba (Art Director)  
**Date:** 2026-06-12  
**Status:** RECOMMENDED FOR IMPLEMENTATION  
**Audience:** Chewie (Engine Dev), Joaquin (Founder)

We will upgrade the Ashfall Blender sprite rendering pipeline to **Guilty Gear Xrd-inspired cel-shade parameters**, targeting fighting game visual quality (readable at 512×512, bold outlines, dramatic lighting, hand-painted color treatment).

**Current Problem:** Outline thickness (0.002) is invisible at 512×512 PNG export; reads as muddy. 3-step shading too soft for fighting game punch; needs hard-edged shadow/lit split.

**Guilty Gear Xrd Reference:** Arc System Works achieved iconic anime-style 3D NOT through photorealism, but through:
1. **Bold outlines** — visually dominant, define form
2. **Hard shadow edges** — 2-step banded shading, not gradual
3. **Dramatic directional lighting** — artist-chosen, non-physical
4. **Color restraint** — characters stay in hue family (no radical hue shifts)

**Specific Parameters:**
- **Outline Thickness:** 0.008 (4× thicker, ~2–3 pixels at 512×512)
- **Kael Outline:** (0.35, 0.15, 0.05) — burnt sienna, warm
- **Rhena Outline:** (0.08, 0.12, 0.20) — dark navy, cool
- **Shading:** 2-step (shadow + lit with hard edge at 0.5 diffuse threshold)
- **Lighting:** Key SUN 3.0 (50°, 10°, 30°) + Fill SUN 1.5 (60°, -20°, -30°) + Ambient (0.15, 0.15, 0.18) strength 0.5
- **Export:** PNG RGBA 8-bit, BLENDER_EEVEE renderer

**Impact:**
- Visual: Immediate character recognizability at all scales; arcade-game polish
- Technical: Minor code changes, no render time increase
- Schedule: 3–5 hours total (Chewie implementation + testing)

**Acceptance Criteria:**
1. Code updated: Thickness flag exposed in CLI, outline colors per character in PRESETS
2. Test renders: Kael idle, Rhena idle at 512×512 exported as PNG
3. Visual validation: In Godot viewport at game scale (screen-side-by-side with old renders)
4. Approval: Boba visual review; if quality acceptable, lock parameters for production sprite batch
5. Documentation: Spec updated with any parameter tweaks after testing

**Reference:** `games/ashfall/docs/CEL-SHADE-ART-SPEC.md` (comprehensive, implementation-ready)

---

### Cel-Shade Pipeline Standardization (Chewie)
**Author:** Chewie (Engine Developer)  
**Date:** 2026-07-22  
**Status:** Proposed  
**Scope:** Ashfall sprite rendering pipeline

Standardized the cel-shade sprite pipeline with production-quality parameters:

1. **2-step shadow bands as default** — Hard shadow/lit split at 0.45 (Guilty Gear Xrd style). 3-step available via `--steps 3` but 2-step is the fighting game standard.
2. **Outline thickness 0.01** — Visible at 512px. Previous 0.002 was invisible. Range 0.008-0.012 appropriate for Mixamo mannequin.
3. **Fresnel rim light always on** — Edge glow with per-character color. Disable with `--no-rim-light`.
4. **Dramatic single-key lighting** — Key=5.0, Fill=0.6, Ambient=0.3. High contrast drives the cel-shade look.
5. **Single source of truth** — `cel_shade_material.py` is the only shader module. `blender_sprite_render.py` imports it via `--preset` flag.
6. **EEVEE engine name** — Blender 5.0 uses `BLENDER_EEVEE` (not `BLENDER_EEVEE_NEXT`).

**Impact on Team:**
- Artists reviewing sprites: Files in `assets/sprites/{character}/{animation}/`
- Anyone rendering: Use `--preset kael` or `--preset rhena` — no manual color setup
- New characters: Add preset to `cel_shade_material.py` PRESETS dict
- Pipeline docs in `tools/BLENDER-SPRITE-PIPELINE.md` remain valid

**Why:** Founder wants Street Fighter / Guilty Gear Xrd style. The 2-step shadow + rim light + thick outline combination achieves that dramatic hand-drawn look from free Mixamo mannequins.

**Status:** Ready for production. 380 frames rendered (Kael 190 + Rhena 190) with contact sheets.

---

### Ashfall GDD v1.0 — Creative Foundation (Yoda)
**Author:** Yoda (Game Designer / Vision Keeper)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Ashfall project — all agents building on this game

Game Design Document for Ashfall (`games/ashfall/docs/GDD.md`), a 1v1 fighting game built in Godot 4. The GDD covers vision/pillars, core mechanics, 2 characters, 1 stage, game flow, controls, AI, art direction, audio direction, and scope boundary.

**Key Creative Decisions:**
1. **The Ember System** — Ashfall's signature mechanic. A visible, shared resource that replaces traditional hidden super meter. Both players can see and fight over it.
2. **6-Button Layout** — LP/MP/HP/LK/MK/HK with macro buttons for throw and dash. Street Fighter lineage, not Tekken.
3. **Kael & Rhena** — Balanced shoto vs rushdown. Classic archetype pairing that naturally teaches fighting game fundamentals.
4. **Deterministic Simulation from Day 1** — Fixed 60fps, seeded RNG, input-based state. Enables future rollback netcode without rewrite.
5. **Combo Proration** — Damage scales down per hit in combo (100% → 40% floor). Max combo damage ~35-45% HP.
6. **Scope Boundary** — MVP = 2 characters, 1 stage, local vs, arcade, training. Everything else deferred.

**Impact on Team:** Scene structure and deterministic game loop defined. Frame data and combat system spec ready. AI behavior tree and difficulty parameters defined. All teams have clear design direction.

**Why:** Design translation of founder directive ("1v1 fighting game, 1 stage + 2 characters"). Scope boundary prevents team from building features outside core loop.

---

### Ashfall Fighting Game Architecture (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-08-03  
**Status:** Proposed

Technical architecture defined in `games/ashfall/docs/ARCHITECTURE.md`. Key decisions:

1. **Frame-based timing** — Integer frame counters, not float timers. All gameplay in `_physics_process()` at 60 FPS fixed tick.
2. **Node-based state machine** — Each fighter state is separate Node with independent script.
3. **AnimationPlayer as frame data** — Hitbox activation driven by AnimationPlayer tracks (startup/active/recovery frames).
4. **MoveData as Resource** — Moves are `.tres` resource files with frame data, damage, hitstun, knockback. Pure data, no logic.
5. **AI uses input buffer** — AI injects synthetic inputs; same code path as human fighters.
6. **Six collision layers** — P1/P2 hitboxes, hurtboxes, pushboxes on separate layers. No self-hits.
7. **Six parallel work lanes** — File ownership ensures simultaneous work without conflicts.

**Impact:** All agents must read `games/ashfall/docs/ARCHITECTURE.md` before writing Ashfall code. Clear module boundaries enable 6 parallel work streams.

**Why:** Deterministic fighting games require frame-perfect timing. Module separation enables parallel development without cross-dependencies.

---

### Ashfall Sprint 0 Scope & Milestone Decisions (Mace)
**Author:** Mace (Producer)  
**Date:** 2026-[Sprint Start Date]  
**Status:** Active — Governing Sprint 0 execution

Complete Sprint 0 plan in `games/ashfall/docs/SPRINT-0.md` covering scope lock, deliverables, phased expansion, studio methodology, technology selection, feature triage, release gates, and knowledge capture.

**Scope Decisions:**
1. **MVP Scope (LOCKED):** 1 stage + 2 characters + basic AI + round system + game flow
2. **Sprint 0 Focus:** Architecture + playable prototype only; no content art, sound, menus
3. **Phased Content Expansion:** 5 phases (Foundation → Balance → Art → UI/Stage → Audio)
4. **Studio Methodology:** 20% load cap + Scrumban (3-task WIP limit) for 14-agent parallelism
5. **Technology Lock:** Godot 4 + GDScript (no re-evaluation this project)
6. **Feature Triage:** Four-Test Framework (core loop, player impact, cost-to-joy, coherence)
7. **Release Gates:** Definition of Done requires acceptance criteria, review, integration, docs, git, playtesting
8. **Knowledge Capture:** Sprint 0 outputs become reusable patterns for future FFS projects

**Governance:** joperezd (final approval), Mace (enforcement), Yoda (design), Solo (architecture), all agents (load discipline).

**Why:** Locked scope + parallel methodology prevents bottlenecks. 14-agent team can work truly parallel with clear role boundaries. Phased approach enables incremental delivery and playtesting feedback.

---

### Sprint 0 Milestone Status Update (Mace)
**Author:** Mace (Producer)  
**Date:** 2026-03-09  
**Status:** Active

M0-M3 gates have been passed and verified. M4 (stable build, balance tuning, ship) is now the active milestone gate.

**Milestone Status:**
- M0 ✅ GDD + Architecture approved (closed issues #1-#4 in Sprint 0)
- M1 ✅ Project buildable (scaffold + core systems implemented)
- M2 ✅ Movement + attacks working (fighter controller, hitbox system, AI opponent functional)
- M3 ✅ HUD integrated, game flow playable 1v1 (main menu, character select, fight scene, HUD, round manager, victory screen — all implemented and wired)
- M4 🔲 Stable build, balance tuning, ship Sprint 0 — **ACTIVE GATE**

**Current Blockers:**
- P0 Blocker: Issue #88 (Integration Gate failure — signal wiring in core systems)

**In Progress:**
- Issue #9 (character sprite placeholders — assigned to Nien, Phase 2 content prep, NOT M4 blocker)
- Ackbar playtesting and balance tuning (M4 ship gate activity)

**Scope Clarification:**
- Issues #50-#58 (Phase 2-5 content: VFX palettes, audio, cinematics, training mode) are NOT Sprint 0 blockers
- M4 gate focuses solely on: Integration stability, combat feel, deterministic 1v1 game flow
- Phase 2 content waits for M4 completion

---

### 2026-03-09T220139Z: Game Resolution is 1080p
**By:** joperezd (via Copilot)  
**What:** Game resolution is 1920×1080 (1080p), NOT 720p. This affects sprite dimension scaling: at 1080p, characters render larger, so 512×512 may need validation for proportions.  
**Why:** User correction — critical data for sprite sizing and oversampling calculation.

---

### 2026-03-09T215832Z: FLUX for Stage Backgrounds
**By:** joperezd (via Copilot)  
**What:** FLUX models are used for generating stage art (backgrounds, parallax layers, round progression visuals), not just character sprites. Stages are simpler: no frame-to-frame consistency required, only style coherence. ~10-15 images per stage vs ~1,000 for characters.  
**Why:** User insight — expands art sprint scope to cover full visual system, not isolated character assets.

---

### 2026-03-09T220815Z: FLUX for HUD Art + Inspiration References
**By:** joperezd (via Copilot)  
**What:** HUD elements are also FLUX-generated: life bar frames, character portraits, ember meter decorations, UI backgrounds. Text and dynamic data render in-engine. Founder added inspiration screenshots in `docs/screenshots/Inspiration` (Tekken, Street Fighter, etc.) for style reference in prompts.  
**Why:** User input — extends FLUX scope to complete visual ecosystem and provides real industry references for consistent AI generation.

---

### Sprite Brief v3 — Three-Model FLUX Pipeline Validated
**Author:** Boba (Art Director)  
**Date:** 2026-03-11  
**Status:** Final  
**Scope:** Ashfall art asset production — all FLUX-based generation

Complete specification for multi-model AI sprite production in `games/ashfall/docs/SPRITE-ART-BRIEF.md` v3. Three FLUX models validated end-to-end on Azure AI Foundry with confirmed authentication, rate limits, and capabilities.

**Key Decisions Locked:**

1. **Three-Model Pipeline:**
   - **FLUX 2 Pro** (4 req/min, 4.0 MP) → Hero frames only (1024×1024 identity reference per character)
   - **FLUX 1 Kontext Pro** (30 req/min, 1.0 MP) → Production sprites (512×512 with character consistency via reference images)
   - **FLUX 1.1 Pro** (30 req/min, 1.6 MP) → Non-character assets (backgrounds, VFX, projectiles, HUD, UI)

2. **512×512 Resolution Confirmed for 1080p:**
   - Game renders at 1920×1080
   - Sprites at 512×512 = 3.3× oversampling at typical viewport distance
   - Risk: LOW — proportions safe, no aliasing risk

3. **Character Consistency Upgrade:**
   - v2 used prompt anchoring only (weakest technique)
   - v3 uses Kontext Pro's `input_image` parameter for visual reference propagation (proven technique)
   - Risk assessment: proportions drift downgraded from High to Medium; costume detail loss from Medium to Low

4. **Hero Frame Gate (Single QC Point):**
   - No pose production begins without Boba approval of character hero frame
   - Hero frames generated at 1024×1024, downscaled to 512×512 for reference input
   - This is the pipeline's only quality control checkpoint

5. **Production Estimates:**
   - ~1,020 total frames (51 poses × 2 characters × ~10 avg frames/pose)
   - Raw generation: ~34 minutes at Kontext Pro's 30 req/min
   - With QA cycles: ~2 hours total
   - Tier: Modern Indie Fighter (510 frames/character equivalent)

6. **Infrastructure:**
   - All models on same Azure AI Foundry resource
   - Auth: Entra ID Bearer token (API key auth disabled by org policy)
   - Token refresh: ~1 hour expiry, auto-refresh for batch sessions

7. **Asset Scope (Full Visual System):**
   - Character sprites: ~1,020 frames (Kontext Pro, consistency critical)
   - Stage backgrounds: ~10-15 per stage (FLUX 1.1 Pro, style coherence only)
   - HUD elements: ~30-50 UI assets (FLUX 1.1 Pro with inspiration references)
   - Title screen: 1-2 cinematic frames (FLUX 2 Pro for quality)

**Impact on Team:**
- **All agents:** SPRITE-ART-BRIEF.md v3 is master reference for sprite generation. No further revisions needed for P0/P1.
- **Mace (Producer):** Production timeline confirmed realistic — 2 hours for full sprite set generation.
- **Chewie/Bossk (Gameplay/VFX):** File naming convention and Godot import settings locked. Can begin integration in parallel.
- **Coordinator:** Infrastructure validation complete. All three models tested end-to-end.

**Why:**
v1 and v2 were written against assumptions about FLUX capabilities. v3 is written against validated infrastructure — three models tested end-to-end with confirmed endpoints, rate limits, and capabilities. The three-model pipeline leverages each model's strengths rather than forcing one model to do everything.

**This document is the single source of truth for all art asset generation for the remainder of the Ashfall sprint.**

---

## Sprint 0 Closure Decisions (2026-03-09)

### M4 Gate Playtest Verdict (Ackbar)
**Author:** Ackbar (QA/Playtester)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall Sprint 0 M4 gate — ship verification

**Decision:** **PASS WITH NOTES** for M4 gate.

**Rationale:**
The Sprint 0 prototype passes because:
- Full game flow works end-to-end (main menu → character select → fight → victory → rematch/menu)
- 9 fighter states implemented and transitioning correctly with safety timeouts
- Frame-based determinism is solid (integer counters, 60 FPS locked)
- Input system uses proper FGC conventions (8f buffer, SOCD, motion priority)
- EventBus decoupling between all 7 autoloads is clean
- Balance data is reasonable for shoto vs rushdown archetypes
- Audio/VFX/HUD integration is correctly signal-wired

**Conditions (Must-Fix Before M5):**
1. **P0 #92:** Add hitbox geometry to fighter scenes (attacks currently deal no damage)
2. **P0 #93:** Fix take_damage signature (fight_scene passes 1 arg, needs 3)
3. **P1 #94:** Sync RoundManager scores to GameState (HUD/victory show 0-0)
4. **P1 #95:** Handle equal-HP timer draw (currently loops forever)

**Impact:** Sprint 0 M4 gate is cleared. The team can proceed to M5 planning. The 4 bugs above are blocking for any gameplay-focused milestone and should be the first items in the next sprint.

---

### P0 Combat Pipeline Integration Fix (Lando)
**Author:** Lando (Gameplay Developer)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall combat system — affects all agents touching hit/damage pipeline

**Decision:** The combat damage pipeline (hitbox → EventBus.hit_landed → fight_scene → take_damage) was broken at two independent points: missing collision geometry and mismatched function signatures. Both bugs existed since the initial implementation because hitbox.gd, fight_scene.gd, and fighter_base.gd were authored by different agents without a live integration test.

**Key Fixes:**
1. **Hitbox geometry** must be defined in the scene file, not left empty. CollisionShape2D with RectangleShape2D (36x24) added under Hitboxes/Hitbox.
2. **take_damage signature** aligned: fight_scene.gd now passes all 3 args (damage, knockback_force, hitstun_frames) from the hit_data dictionary.

**Team Impact:**
- **All agents:** When building cross-module pipelines (emitter → signal → consumer), the full chain must be tested end-to-end before the PR merges. Signal signatures and scene node hierarchies are the most common mismatch points.
- **Tarkin:** When wiring AnimationPlayer-driven hitbox activation, the Hitbox node + CollisionShape2D now exist in fighter_base.tscn. Per-move hitbox sizing can override the default 36x24 shape via MoveData or AnimationPlayer tracks.
- **Ackbar:** The hit_data dictionary keys used are `knockback_force` and `hitstun_duration` (matching hitbox.gd's emit). Any future additions to hit_data should be documented.

**Why:** Two P0 bugs blocking Sprint 0 ship. Both were integration seams — individually correct modules that failed when connected. This is our most common bug pattern in multi-agent development.

---

### Equal-HP Draw State Handling (Chewie)
**Author:** Chewie (Engine/Systems)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall RoundManager — draw state logic and signals

**Decision:** When both fighters reach 0 HP simultaneously, round_manager must declare round_draw (not loop forever). Dual new signals (round_draw, match_draw) clarify game rule implementation.

**Key Changes:**
1. **Draw State Logic:** RoundManager.check_round_end() now checks if both fighters' HP ≤ 0, emits `round_draw` signal instead of entering KO state.
2. **Signal Architecture:** New `round_draw` signal for per-round draws; new `match_draw` signal for full match draws (future tournament logic).
3. **GDD Alignment:** Per GDD: "Equal HP = mutual KO = draw round" — now correctly implemented.

**Team Impact:**
- Rules encoded as signals improve code clarity (testable, debuggable)
- New team members can read signals as game rule documentation
- Draw states properly handled for 1v1, tournament, and network play future

**Why:** Game rules must be explicit in code. The GDD said "equal HP = draw," but the round_manager logic only knew about KO.

---

### HUD Score Sync Architecture (Wedge)
**Author:** Wedge (UI/Frontend)
**Date:** 2026-03-09
**Status:** Accepted
**Scope:** Ashfall UI — score tracking and GameState integration

**Decision:** GameState is the single source of truth for all score state. RoundManager syncs scores to GameState after each round, and FightHUD reads from GameState every frame.

**Key Architecture:**
1. **Score Sync:** After `round_end`, RoundManager calls `GameState.set_scores(scores)`.
2. **GameState Enhancement:** New `set_scores()` and `get_scores()` methods ensure persistence and read access.
3. **FightHUD Integration:** HUD reads from `GameState.scores` (not local copies), preventing drift.

**Team Impact:**
- Autoload state is the source of truth (prevents local state drift)
- HUD is data-driven (easier to test, debug, extend)
- Foundation for multiplayer sync (GameState → network replication path)

**Why:** Local state (RoundManager.scores) can drift from global state (GameState.scores). Always push updates to single source of truth.

---

### Procedural Sprite System for Ashfall Characters (Nien)
**Author:** Nien (Character Artist)
**Date:** 2026-03-09
**Status:** Proposed
**Scope:** Ashfall character art pipeline

**Decision:** Character placeholders use Godot's `_draw()` API via a `CharacterSprite` base class (Node2D) instead of pre-rendered PNG sprite sheets. Each character has its own sprite script (kael_sprite.gd, rhena_sprite.gd) that overrides pose methods.

**Key Points:**
1. **Procedural-first pipeline:** Characters are drawn at runtime using Godot draw primitives. A `SpriteSheetGenerator` @tool script can bake these into PNGs for AnimationPlayer when needed.
2. **Palette system:** P1/P2 variants are `Array[Dictionary]` of named colors. `palette_index` export swaps palettes without code changes. Extensible to additional costumes.
3. **State bridge pattern:** `SpriteStateBridge` polls `StateMachine.current_state.name` each physics frame to sync poses. No modifications to gameplay scripts required — respects ownership boundaries.
4. **Character-specific scenes:** `kael.tscn` and `rhena.tscn` extend fighter_base.tscn structure, adding procedural sprite + bridge as new nodes. `fight_scene.tscn` updated to instance these instead of generic fighter_base.
5. **Silhouette differentiation:** Kael = ponytail + lean upright stance + controlled extensions. Rhena = wild spiky hair + wide low stance + overshooting messy swings. Distinct at any scale.

**Impact:**
- **Boba (Art Director):** Review silhouettes and palettes for style guide compliance
- **Chewie/Lando (Engine/Gameplay):** fight_scene.tscn now instances kael.tscn/rhena.tscn instead of fighter_base.tscn. Sprite2D node preserved for future texture loading.
- **Solo (Architect):** New `scripts/fighters/sprites/` module. SpriteStateBridge adds polling load (one string comparison per fighter per frame — negligible).
- **Future characters:** Extend `CharacterSprite`, override 8 pose methods, add to palettes array. ~400-500 LOC per character.

**Why:** Procedural art eliminates the external tool dependency for placeholder iteration. The team can tweak proportions, palettes, and poses directly in GDScript without a pixel art editor. The bake-to-PNG path preserves compatibility with AnimationPlayer for production art later.

---

### Jango — M1+M2 Retrospective Action Items (2026-03-08)
**Author:** Jango (Lead)  
**Status:** Proposed  
**Scope:** Ashfall — Pre-M3 mandatory fixes

Top 3 action items from post-M2 review:

1. 🔴 **Cherry-pick AI Controller to Main (P0)** — ai_controller.gd (298 LOC) merged to wrong branch. Game has no single-player. Cherry-pick from remotes/origin/squad/7-ai-opponent or recreate PR from main-based branch.
2. 🔴 **Full Integration Pass in Godot (P0)** — All systems built in parallel, no end-to-end validation. Open project, walk Main Menu → Character Select → Fight → KO → Victory → Rematch. File bugs.
3. 🟡 **Add Medium Buttons to Input Map (P1)** — GDD specifies 6-button layout (LP/MP/HP/LK/MK/HK) but project.godot only maps 4 per player. No medium punch/kick. Add p1_medium_punch/kick and movesets.

**Process Change:** No M3 feature work begins until items 1 and 2 complete.

---

### Asset Naming Convention (2026-03-09)
**Author:** Joaquín (User)  
**Status:** Active  
**Scope:** Ashfall sprite asset naming

All game assets follow: `{character}_{action}_{variant}.png` in `assets/sprites/{character}/`

- **Characters:** lowercase, no spaces (kael, rhena)
- **Actions:** lowercase, match state names (idle, walk, jump, punch, kick, throw, hit, ko, block)
- **Variants:** attack strength suffix (lp, mp, hp, lk, mk, hk) — omit for non-attacks
- **Spritesheets:** `{character}_{action}_sheet.png`
- **Stages:** `assets/stages/{stage_name}/{element}.png`

**Why:** M3 will have Nien creating sprites while Chewie/Lando reference them in code. Shared naming prevents integration friction.

---

### Solo — Final Verification (2026-03-09)
**Agent:** Solo (Architect and Integration Gatekeeper)  
**Date:** 2026-03-09  
**Commit:** 05eafc6 (main, post-PR #28 + #32 merge)  
**Verdict:** **FAIL** ⛔ — 6 blocking issues prevent M3 launch

**Blocking Issues:**
1. **RoundManager Not Instantiated** — System exists (117 LOC) but never added to autoloads or fight_scene.tscn. No round timer, no "FIGHT!" announcement, no KO detection.
2. **Orphaned Combo Signals** — hit_confirmed and combo_ended defined in EventBus, connected in VFXManager, but never emitted anywhere. Combo counter has no data source.
3. **VFXManager Signal Orphans** — Defined connections to hit_confirmed / combo_ended / knockback_applied / player_blocked but systems don't emit them.
4. **Scene Initialization Order** — fight_scene.gd doesn't call round_manager.start_match(). Round system never activates.
5. **Autoload Registration Missing** — RoundManager should be registered as autoload (5th after SceneManager) per SKILL reference pattern.
6. **Null Safety Issues** — 8 get_node() calls lack null checks. Will crash if scene structure diverges.

**Root Cause:** Systems built but not wired together. Integration validation never ran before merge.

**Why This Matters:** Architecture looks solid on paper. Wiring is the gap. Next project: integration testing before milestone gate.

---

### Art Direction Lock — Sprint 1 M0 (Boba)

**Author:** Boba (Art Director)  
**Date:** 2026-03-09  
**Status:** Active  
**Scope:** Ashfall — all visual output

## Decision

Art direction for Ashfall is formally locked in `games/ashfall/docs/ART-DIRECTION.md` (PR #113, Issue #102).

## Key Visual Rules (Team-Binding)

1. **Silhouette First** — Characters must be identifiable by outline alone at 64×64px. Binary pass/fail.
2. **Accent color = identity** — Kael is blue (`#4073D9`), Rhena is orange (`#F28C1A`). This applies to VFX, damage numbers, ember aura, and any future UI elements.
3. **No pure black/white** — Darkest allowed: `#0D0D1A`. Brightest allowed: `#E0DBD1`. Keeps everything in the warm volcanic world.
4. **P1 palettes are canon.** P2 exists only for mirror matches.
5. **Procedural art only** — All character rendering is `_draw()` code. No external PNG sprites for fighters.
6. **Stage escalation is mandatory** — EmberGrounds must visually transform across rounds (Dormant → Warming → Eruption).
7. **VFX is character-tinted** — Hit sparks, KO bursts, damage numbers, and flash colors must use the attacker's character palette.
8. **Animation timing must match frame-data.csv** — No visual-only timing. If LP is 4+2+6 frames, the sprite must complete in exactly 12 frames at 60fps.

## Impact

- Nien, Leia, Bossk, Chewie all reference this document for their Sprint 1 deliverables
- Mace enforces naming convention and palette compliance at PR review
- No visual changes without Art Director sign-off after this lock

## Why

Art direction lock prevents rework. Sprint 1 has 4 parallel workstreams (sprites, stage, VFX, animation). If visual direction shifts mid-sprint, all 4 streams must restart. Locking early is the single highest-leverage production decision for art phase.

---

### Decision: Frame Data Authority and Base .tres Consolidation (Lando)

**Author:** Lando (Gameplay Developer)  
**Date:** 2026-03-09  
**Context:** Issues #108, #109, #110 — Sprint 1 playtest frame data bugs

## Decision

**Character moveset .tres files are the authoritative runtime source for frame data.** Base .tres files (fighter_base/, attack_state/) are reference/validation data only.

## Rationale

- fighter_base/ and attack_state/ contain identical data — redundancy invites drift
- Character movesets already contain character-specific tuning (e.g., Rhena HP active=5f vs Kael HP active=4f)
- FighterMoveset.get_normal() is the runtime lookup path — base .tres are never loaded at runtime

## Recommendation

1. Consolidate fighter_base/ and attack_state/ into a single directory (or remove one)
2. Add a validation script that checks character moveset values against GDD ranges
3. Consider auto-generating base .tres from frame-data.csv to prevent manual drift

## Impact

- Affects: Chewie (state machine references), Tarkin (animation frame data), Yoda (GDD updates)
- No runtime behavior change — this is a data organization decision

---

### Solo — Signal Wiring Validator Standards (2026-03-09)
**Author:** Solo (Lead / Chief Architect)  
**Status:** Implemented (PR #89)  
**Scope:** Ashfall project — all agents writing GDScript

**Decisions:**

1. **Godot built-in signals are excluded** from signal wiring validator. Signals like `area_entered`, `pressed`, `timeout`, `value_changed` emitted by engine should never be flagged as orphaned.

2. **Test files are excluded** from signal analysis. Test scripts use engine signals on programmatic UI and emit legacy test-only signals not part of game signal graph.

3. **Every EventBus signal must have both emitter and consumer.** Defining a signal on EventBus is not enough — must be `.emit()`ed somewhere and `.connect()`ed somewhere, or validator fails CI.

4. **integration-gate.py JSON report treats signal warnings as non-fatal,** matching console behavior. Prevents CI/console status divergence.

**Impact:**
- All agents must wire both sides of any new EventBus signal before merging
- Jango should update signal-related templates to include wiring reminders
- Future signals added to EventBus without emitters/consumers caught in CI

**Why:** Validator caught real wiring gaps (6 orphaned signals) mixed with false positives (4 Godot built-ins). Separation ensures CI catches real issues without noise.

---

### Sprint Structure & Terminology (2026-03-09) — Mace (Producer)

**Status:** APPROVED & DOCUMENTED

**Problem:** Terminology confusion between Milestone Gates (M0-M4) and Sprints. Causes ambiguous planning.

**Solution:** 
- **Milestone Gates** = checkpoints within a sprint
- **Sprints** = major work phases (Art Phase, UI Phase, Audio Phase)

**Key Decisions:**
1. Each sprint has M0-M4 milestone gates
2. M4 = ship criteria
3. Scope lock at sprint start

**Ashfall Sprint Structure:**
- Sprint 0: Foundation (shipped)
- Sprint 1: Art Phase (in progress)
- Sprint 2: UI/UX
- Sprint 3: Audio + VFX
- Sprint 4+: Polish & Expansion

---

### Sprint 1 (Art Phase) Kickoff Decision (2026-03-10) — Mace (Producer)

**Status:** ✅ APPROVED

**Decision: Sprint 1 Scope is LOCKED**

**What's IN Scope:**
1. Character Sprites (Nien) — Kael & Rhena, ~45 states each
2. Stage Background (Leia) — EmberGrounds 3-round progression
3. Art Direction (Boba) — Silhouettes, palettes, animation timing
4. Character VFX (Bossk) — Kael embers, Rhena bursts
5. AnimationPlayer Integration (Chewie) — Sprite loading, animation wiring
6. Visual Playtest (Ackbar) — PASS verdict required

**What's OUT of Scope:**
- Audio → Sprint 3
- UI/UX polish → Sprint 2
- Training mode, additional characters → Phase 5+

**Milestone Gates:**
- M0: Art Direction locked
- M1: Sprites drafted
- M2: VFX + AnimationPlayer wired
- M3: Visual integration complete
- M4: Ackbar visual playtest PASS (required to ship)

**Load Analysis:** 140h planned, 96h available. Over by 44h; mitigated via P2 de-scope if bottleneck hits.

---

### Sprint 1 Closure Decision (2026-03-20) — Mace (Producer)

**Status:** COMPLETE — Sprint 1 (Art Phase) Officially Shipped

**Sprint Duration:** 2026-03-10 to 2026-03-20 (10 days)

**PRs Merged (2026-03-20):**
1. PR #103 — Leia: EmberGrounds stage
2. PR #104 — Nien: Fighter animation states (P0+P1)
3. PR #105 — Bossk: Character-specific VFX

**All Milestone Gates Verified:**
- ✅ M0: Art Direction locked
- ✅ M1: Character sprites delivered
- ✅ M2: VFX + AnimationPlayer wired
- ✅ M3: Visual integration complete
- ✅ M4: Ackbar visual playtest PASS

**Quality Gates Passed:**
- ✅ Silhouette test: Kael vs Rhena visually distinct
- ✅ Ackbar playtest: PASS
- ✅ Animation smoothness: Frame-perfect transitions
- ✅ VFX differentiation: Particles identify character
- ✅ P0 bugs: 0 critical issues

**Key Decisions:**
1. P2 De-scope (throw/win/lose deferred to Sprint 2)
2. Parallel execution validated (4 PRs, 0 conflicts)
3. Art direction lock prevented rework
4. Playtesting as gating criterion

**Critical Follow-ups for Sprint 2:**
1. P2 animation states
2. Ackbar playtest notes triage
3. Character select visual upgrade

---

### Ackbar Sprint 1 Visual Playtest Verdict (2026-03-20) — Ackbar (QA Lead)

**Status:** ✅ PASS WITH NOTES

**Verdict:** Sprint 1 art deliverables meet quality bar. All animation states implemented per character with distinct art. VFX wired. Stage escalation functional. AnimationPlayer integrated. Characters visually distinct.

**Three P1 Issues Require Follow-up:**

1. **P1-001:** MP/MK startup frames 1f faster than GDD spec. Must align before combo tuning.

2. **P1-002:** Medium attacks missing from character moveset .tres. Only 6 moves per character.

3. **P1-003:** Frame data drift between base .tres and character .tres (HP: 10f vs 12f).

**Impact:**
- Yoda: Review GDD frame data vs implementation
- Solo/Chewie: Resolve .tres source authority
- Mace: Track P1 issues as Sprint 2 blockers

**Rationale:** PASS WITH NOTES acceptable per SPRINT-1-SUCCESS.md. All follow-ups documented.

---

### 2026-03-09T1247Z: User Directive — Viewport Resolution

**By:** joperezd (via Copilot)  
**Status:** IMPLEMENTED

**What:** Viewport should be 1920x1080 (1080p), not 720p.

**Why:** 1280x720 is too low for 2026 standards. 1080p provides better visual clarity for fighting game.

**Implementation:** `games/ashfall/project.godot` [display] section updated:
- `viewport_width`: 1280 → 1920
- `viewport_height`: 720 → 1080

**Status:** Complete.

---

### 2026-03-09T1253Z: User Directive — Auto-Release at Sprint End

**By:** joperezd (via Copilot)  
**Status:** PENDING IMPLEMENTATION

**What:** Releases should happen automatically at sprint end. When a sprint is shipped (tagged `sprint-N-shipped`), a versioned release (v0.N.0 or similar) should be created automatically with the built .exe.

**Why:** Zero-friction release flow tied to sprint cadence. Founder wants automatic versioning tied to sprint milestones.

**Implementation Approach:** 
- GitHub Actions workflow triggers on `sprint-N-shipped` tag push
- Automatically creates v0.N.0 release
- Builds .exe and attaches to release
- Integrates with existing godot-release.yml

**Status:** Captured for team memory. Requires workflow expansion after Sprint 1.

---

### 2026-03-09T1257Z: User Directive — Release Naming Convention

**By:** joperezd (via Copilot)

**What:** All releases (tags and downloadable GitHub Releases) must always reference the game name and version. 

**Format:**
- Tag: {game}-v{version} (e.g., shfall-v0.1.0)
- Release Title: {Game} v{version} (e.g., Ashfall v0.1.0)
- Zip: {Game}-v{version}-{platform}.zip (e.g., Ashfall-v0.1.0-windows.zip)

**Why:** User request — captured for team memory. The repo (FirstFrameStudios) may host multiple games, so releases must be unambiguous about which game they belong to.

**Governance:** Enforce in GitHub Actions workflows and release notes templates.

---

### 2026-03-09T1150Z: Build Pipeline — Automated Godot Releases (Jango)

**Status:** IMPLEMENTED — PR #111

**What:** Complete build pipeline architecture for Ashfall:

**Workflow:**
1. Developer pushes version tag (e.g., shfall-v0.1.0) to GitHub
2. GitHub Actions workflow triggers: .github/workflows/godot-release.yml
3. CI installs Godot 4.6 + export templates
4. Exports Windows .exe from games/ashfall/ directory
5. Creates GitHub Release with downloadable zip package

**Key Decisions:**
1. **Export Presets Versioned** — games/ashfall/export_presets.cfg committed to git (non-standard, but necessary for CI/CD reproducibility)
2. **Manual Godot Installation** — wget for explicit Godot 4.6 version control
3. **Tag-Triggered Releases** — Tag format {game}-v{version} per release naming directive
4. **Windows Desktop Only** — Initially. Linux/Mac/Web can be added later.
5. **Cross-Compilation on Ubuntu** — Linux runner exports Windows .exe for broad platform compatibility

**Architecture:**
`
Tag push (ashfall-v0.1.0) 
  → GitHub Actions detected
  → Download Godot 4.6 + templates
  → Export to .exe 
  → Package as zip 
  → Create GitHub Release with download
`

**Deliverables:**
- games/ashfall/export_presets.cfg — Windows Desktop export preset (Godot 4.6)
- .github/workflows/godot-release.yml — Automated build + release workflow
- Root .gitignore updated to allow export_presets.cfg, ignore builds/

**Impact:**
- Developers: Create releases by pushing tag (zero friction)
- Players: Download and play without Godot installed
- QA: Manual workflow dispatch for testing
- Future: Pipeline reusable template for additional projects

**Next Steps:**
- Test manual workflow dispatch
- Create v0.0.1-test tag to validate build output
- Document release process for team

# Decision: Sprite Art Brief Revised with Web Research

**Author:** Boba (Art Director)  
**Date:** 2026-03-10  
**Status:** Proposed  
**Scope:** Ashfall sprite production pipeline

## What Changed

Revised `games/ashfall/docs/SPRITE-ART-BRIEF.md` based on web research per founder directive ("que se informen bien de lo que implica este cambio").

### Key Revisions

1. **Canvas: 256×256 → 512×512.** Web research confirms 512 is the industry sweet spot for AI sprite generation. 256 is only for NES/SNES-era retro art. Joaquín's original instinct was correct.

2. **New Section 0 (Research & Best Practices).** Covers resolution standards, character consistency techniques, industry sprite count benchmarks, and the proven ControlNet + LoRA + img2img workflow.

3. **New Section 5 (FLUX on Azure: Capabilities & Limitations).** Honest assessment: our Azure deployment supports text-to-image ONLY. No ControlNet, no img2img, no LoRA, no seed control. All proven consistency techniques are unavailable.

4. **New Section 6 (Tool Evaluation).** Head-to-head comparison of FLUX on Azure vs Local SD + ComfyUI. Local SD is objectively superior for character consistency. FLUX advantage is zero setup + newer model.

5. **Infrastructure Decision Gate.** Added after P0 in production pipeline: if >30% of frames need regeneration due to consistency drift, we should evaluate pivoting to local SD + ComfyUI.

6. **Frame Count Analysis.** Our ~600 frames/character is in the Guilty Gear range. Ambitious but achievable — if we have the right tools.

## Decisions Requiring Founder Input

1. **Confirm 512×512** — Now aligned with research. No objection expected.
2. **After P0:** Evaluate consistency results and decide whether to continue with FLUX on Azure or invest in local SD + ComfyUI setup.
3. **Hybrid approach option:** Use FLUX for reference frames → train LoRA locally → use ComfyUI for production. Best of both worlds but requires GPU hardware.

## Impact on Team

- All agents referencing sprite dimensions must use 512×512
- Production timeline unchanged for P0 (same 48 frames, same generation process)
- Potential infrastructure pivot after P0 if consistency is unacceptable

## Why This Matters

The founder asked us to research before building. He was right. Without this research, we would have attempted 1,200 frames of prompt-only generation with no proven path to character consistency — and discovered the problem after weeks of wasted effort. Now we know the risks upfront and have a decision gate to course-correct early.

---

### 2026-03-09T210032Z: FLUX deployment status
**By:** joperezd (via Copilot)
**What:** Solo FLUX 1.1 Pro está desplegado actualmente. Los otros 3 modelos (Kontext Pro, FLUX 2 Pro, FLUX 2 Flex) pueden desplegarse en Azure AI Foundry y crear variables de entorno de sistema para cada uno. Despliegue pendiente antes de empezar producción de sprites.
**Why:** User input — estado real de infraestructura. No asumir que los modelos están disponibles hasta que Joaquín los despliegue.

---

### 2026-03-09T205438Z: Full FLUX model arsenal available
**By:** joperezd (via Copilot)
**What:** Four FLUX models available on Azure AI Foundry:
1. FLUX 1.1 Pro — text-to-image, 30 tokens/min
2. FLUX 1 Kontext Pro — text+image editing with CHARACTER CONSISTENCY, rate limit TBD
3. FLUX 2 Pro — text-to-image + img2img, 4/min
4. FLUX 2 Flex — text-to-image + img2img + NATIVE ControlNet + inpainting, rate limit TBD
**Why:** User input — complete model inventory for art sprint tool evaluation.

---

### 2026-03-09T205742Z: Complete FLUX rate limits confirmed
**By:** joperezd (via Copilot)
**What:** Rate limits confirmados para todos los modelos FLUX en Azure AI Foundry:
- FLUX 1.1 Pro (text-to-image): 30/min
- FLUX 1 Kontext Pro (text+image ref, character consistency): 30/min
- FLUX 2 Pro (text-to-image + img2img): 4/min
- FLUX 2 Flex (text + img2img + ControlNet nativo + inpainting): 4/min
**Why:** User input — rate limits finales para planificación de producción.

---

### 2026-03-09T212435Z: FLUX API validated — Entra ID auth works
**By:** joperezd + Squad (via Copilot)
**What:** FLUX 1.1 Pro API call validated successfully. Auth: Entra ID Bearer token (az account get-access-token --resource https://cognitiveservices.azure.com). API key auth disabled by org Azure Policy. BFL native path: providers/blackforestlabs/v1/flux-pro-1.1?api-version=preview. Response: 121KB PNG in b64_json. Sprint de arte desbloqueado para FLUX 1.1 Pro.
**Why:** Validation confirmed — pipeline is functional. Next: deploy Kontext Pro, FLUX 2 Pro, FLUX 2 Flex.

---

### 2026-03-09T205112Z: FLUX 2 Pro disponible con img2img
**By:** joperezd (via Copilot)
**What:** Además de FLUX 1.1 Pro (text-to-image, 30 tokens/min), hay disponible FLUX 2 Pro que soporta text-to-image E image-to-image. Rate limit: 4 calls por minuto.
**Why:** User input — cambia fundamentalmente la evaluación de herramientas. img2img permite propagación de consistencia entre frames sin necesitar ControlNet/LoRA.

---

### Sprite PoC Test Viewer (Chewie)
**Author:** Chewie (Engine Developer)  
**Date:** 2026-03-09  
**Status:** Implemented  
**Scope:** Test tooling — games/ashfall/scenes/test/ and games/ashfall/scripts/test/

Created a standalone test scene (sprite_poc_test.tscn + sprite_poc_test.gd) that loads and displays the PoC sprites generated for Kael. Plays idle (8fps), walk (10fps), and LP (60fps) animations over the Embergrounds background with keyboard controls.

**Files Created:**
- games/ashfall/scenes/test/sprite_poc_test.tscn — Minimal Node2D scene
- games/ashfall/scripts/test/sprite_poc_test.gd — All logic, data-driven animation config

**Design Choices:**
1. **Fully programmatic scene** — Script creates all nodes in _ready(). The .tscn is just a root Node2D with the script attached. Zero manual editor work needed; easy to diff and review.
2. **Data-driven ANIM_CONFIG** — Adding new animations (walk_back, MP, HP, etc.) requires only a new dictionary entry and the PNG files. No code changes.
3. **Runtime texture filter** — Set TEXTURE_FILTER_NEAREST on the AnimatedSprite2D node instead of modifying .import files. Keeps the viewer self-contained without affecting other scenes that might use these assets.
4. **Center-bottom origin** — offset = Vector2(0, -256) so the node position represents feet. Matches fighting game convention where character position = ground contact point.
5. **LP auto-return** — Non-looping animations return to idle via nimation_finished signal, driven by the loop flag in config.
6. **Scale 0.4** — Renders the 512×512 sprite at ~205px on a 1080p screen. Reasonable fighting game character size. The 30×60 collision box proportions (1:2 ratio) will be handled by the collision system, not the visual scale.

**How to Run:**
Set sprite_poc_test.tscn as the main scene in Godot editor (Project → Project Settings → Run → Main Scene), or run it directly via Scene → Run Current Scene (F6) with the scene open.

**Impact:**
Test-only. No production code affected. No autoloads required (the viewer is self-contained). Other agents can use this pattern for future sprite/animation test viewers.

**Why:** Validates FLUX sprite generation pipeline. Establishes data-driven animation pattern for Ashfall test suite. Enables visual iteration without manual sprite sheet assembly.

---

## Nien (Character Artist) — v2 Frame Generation
# PoC v2 Animation Frames — Complete

**Author:** Nien (Character Artist)  
**Date:** 2026-07-08  
**Status:** Complete  
**Scope:** Ashfall PoC v2 animation frames

## Summary

Generated 56 animation frames (28 per character) for Kael and Rhena using Kontext Pro with approved hero designs as input_image references. All frames saved to `games/ashfall/assets/poc/v2/` with RGBA transparency.

## Frames Generated

| Character | Action | Frames | Status |
|-----------|--------|--------|--------|
| Kael      | Idle   | 8      | ✅ All clean |
| Kael      | Walk   | 8      | ✅ All clean |
| Kael      | LP     | 12     | ✅ All clean |
| Rhena     | Idle   | 8      | ✅ All clean |
| Rhena     | Walk   | 8      | ✅ 3 required retry (content filter) |
| Rhena     | LP     | 12     | ✅ All clean |

## v1 Fixes Applied

1. **Walk leg alternation:** Each walk frame prompt explicitly specifies which leg is forward/back (e.g., "RIGHT foot forward, LEFT foot behind"). This addresses the v1 sliding/moonwalk issue.
2. **LP kata vocabulary:** All attack prompts use martial arts kata language instead of combat words. Zero content filter rejections across 24 LP frames.
3. **Approved hero references:** Used `kael_design_b.png` and `rhena_design_c.png` as Kontext Pro input_image, improving character consistency over v1.

## Post-Processing

- Green chroma key backgrounds removed with widened tolerance (handles dark/olive greens)
- Corner-based fallback detection for non-standard background colors
- All 56 frames verified RGBA with >5% transparent pixels
- Contact sheets: `contact_v2_kael.png`, `contact_v2_rhena.png`

## API Details

- **Deployment:** `flux.1-kontext-pro` (lowercase with dots)
- **Auth:** Bearer token via `az account get-access-token`
- **Rate:** 2.5s delay between calls, ~56 calls completed in ~4 minutes
- **Size:** 1024×1024 per frame

## Impact

- PoC v2 frames ready for founder review
- Walk cycle fix addresses primary v1 feedback
- Pipeline proven for future character animation generation

---

## 2026-03-10T08:55Z: User Directive — Audio Model Deployed
### 2026-03-10T08:55Z: User directive — Audio model deployed
**By:** Joaquín (via Copilot)
**What:** GPT-Audio-1.5 deployed on Azure AI Foundry for audio generation. Rate limit: 90,000 requests/min (extremely generous). Available for Sprint 3 (Audio) when ready.
**Why:** Founder deployed a new model for future audio sprint. Captured for team memory so Greedo (Sound Designer) knows what's available.

---

## Pipeline & Art Direction Decisions

### V2 Animation Consistency Audit (Boba)
**Author:** Boba (Art Director)  
**Date:** 2025-01-27  
**Status:** 🔴 CRITICAL FAILURE

**Executive Summary**

Joaquín's assessment is 100% correct. V2 frames are unusable for animation. Each frame looks like a different character — fundamentally incompatible with frame-by-frame animation which requires consistency between frames.

**V1 Analysis: KAEL IDLE (8 frames)**

| Metric | Score | Notes |
|--------|-------|-------|
| **Character Identity** | 10/10 | Same face, same proportions, same person across all 8 frames |
| **Outfit Consistency** | 10/10 | Identical grey-white gi, dark belt, brown boots, arm wraps |
| **Color Palette** | 10/10 | Exact same hex values frame-to-frame |
| **Pose Readability** | 9/10 | Clear breathing cycle, smooth transitions implied |

**V1 TOTAL: 39/40 — Production-ready**

**V2 Analysis: KAEL (28 frames, 3 rows)**

| Metric | Score | Notes |
|--------|-------|-------|
| **Character Identity** | 2/10 | Different faces, different body types. Frame 1 and Frame 5 are NOT the same person. |
| **Outfit Consistency** | 1/10 | Red gi → green gi → brown gi → purple gi → grey gi. Belt: yellow → orange → purple → red → blue. No two frames match. |
| **Color Palette** | 1/10 | Complete chaos. 7+ different outfit colors in Row 1 alone. |
| **Pose Readability** | 3/10 | Poses exist but you'd never notice them over the color/identity changes |

**V2 KAEL TOTAL: 7/40 — Unusable**

**V2 RHENA TOTAL: 7/40 — Unusable**

**Root Cause Analysis**

The v2 process appears to have:

1. **No reference anchoring** — Each frame generated independently without enforcing the previous frame's appearance
2. **High variation sampling** — The AI model was likely allowed too much creative freedom per-frame
3. **No color palette lock** — Hair, outfit, belt colors re-rolled each generation
4. **No identity preservation** — Face and body treated as "character" concept rather than "this specific character"

**V1 succeeded because:** Likely used stronger reference conditioning or multiple passes with same seed/parameters.

**Impact Assessment**

Can V2 be animated? **NO.** Playing these frames sequentially would create a flickering nightmare.

Can V2 be salvaged? **Maybe partial.** If we cherry-pick only frames that match (maybe 3-4 per character). But honestly? **Start over with v1's methodology.**

**Recommendations**

1. **Immediate:** Abandon v2 approach. Do not invest more time in this direction.
2. **V3 Direction:** Return to v1's methodology. Whatever constraint/conditioning made v1 consistent, restore it.
3. **Process Change:** Before generating 28 frames, generate 3 and verify consistency. Fail fast.
4. **Scope Reduction:** Maybe we don't need 28 frames per animation. V1's 8 frames looked great. Quality > quantity.

---

### Sprite Animation Consistency — Research & Recommendation (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-10  
**Status:** Proposed  
**Triggered by:** Founder (Joaquín) reports v2 animation frames worse than v1. ChatGPT research independently suggests skeleton-based pose conditioning.

**Root Cause Analysis: Why V2 Failed**

Boba's audit confirmed it: V2 scored 7/40 vs V1's 39/40. The character looks different in every frame. This is an **architectural failure** in how we generate frames.

**The fundamental error:** We used Kontext Pro to generate each frame independently from a text prompt. Kontext Pro is an image-editing model — it excels when you give it a source image and say "change this specific thing." We used it like a text-to-image model, asking it to generate "frame 2: anticipation pose" from scratch each time. Without structural conditioning (pose skeleton) or appearance anchoring (reference image fed per-frame), the model re-rolls identity on every generation.

**Why V1 worked:** V1 likely used tighter reference conditioning — same seed, same parameters, minimal pose variation (breathing cycle = subtle). The moment we asked for diverse poses (punches, kicks, jumps across 28 frames), the model had nothing to anchor identity to.

**Core insight:** Text prompts alone cannot enforce visual consistency across frames. You need **structural control** (what pose to take) AND **appearance control** (what the character looks like) as explicit inputs to every frame generation.

**Research Findings: All Viable Approaches**

I conducted 9 independent web searches across FLUX models, ControlNet, academic papers, indie game pipelines, and specialized tools.

**Approach A: ComfyUI + FLUX + ControlNet Pose + IP-Adapter**

How it works: Generate master sprite → create pose skeletons → feed both into ComfyUI with ControlNet (pose mode) and IP-Adapter (appearance locking) → generate each frame conditioned on both pose AND appearance.

**Consistency level:** High (8/10). Remaining 20% variation is in fine details requiring manual QA.

**Complexity:** HIGH. Requires local ComfyUI setup, model downloads (~20GB), workflow configuration, GPU with 12-24GB VRAM.

**Verdict:** This is what the ChatGPT research was pointing at. It's the right direction, but requires FLUX.2 Dev (open weights + ControlNet), NOT our current FLUX 1.1 Pro or Kontext Pro API.

**Approach B: PixelLab (Purpose-Built Tool)**

How it works: PixelLab is an AI tool built specifically for pixel art game assets. Has built-in **skeleton-based animation system** — you define joint positions, it generates consistent frames.

**Consistency level:** High (8/10) for pixel art style. Purpose-built for this exact problem.

**Complexity:** LOW. Web-based tool, no local setup.

**Verdict:** Best option IF our art direction is pixel art. Fast to test, low risk. Worth a spike.

**Approach C: 3D-to-2D Pipeline (Mixamo + Blender → Sprite Render)**

How it works: Get 3D humanoid model (Mixamo free library) → apply fighting animations from Mixamo's mocap library → In Blender: orthographic camera, side view, render each frame as PNG → Use SpriteStar or Spritesheet Renderer addon to batch-export sprite sheets → Post-process in Aseprite/Photoshop for style.

**Consistency level:** PERFECT (10/10). It's the same 3D model in every frame. Consistency is guaranteed by definition.

**Complexity:** MEDIUM. Blender setup is one-time. Mixamo animations are free and immediate.

**Verdict:** Most reliable approach for consistency. Zero AI randomness. Classic technique used by professional studios (Donkey Kong Country, Killer Instinct, many modern indie fighters).

**Approach D & E: Sprite Sheet Diffusion & SaaS Tools**

Sprite Sheet Diffusion (Academic research) and SaaS tools (Spritesheets.AI, AutoSprite, Scenario) are additional options but lower priority.

**Top 3 Alternatives — Ranked by Feasibility**

**🥇 Rank 1: 3D-to-2D Pipeline (Mixamo + Blender)**
- **Why first:** Guaranteed consistency. Zero randomness. Proven in professional fighting games.
- **Time to first result:** 2-4 hours
- **Ongoing cost:** Free (Blender + Mixamo are free)
- **Risk:** Art style gap needs post-processing. But a consistent ugly sprite is infinitely more useful than a beautiful inconsistent one.

**🥈 Rank 2: ComfyUI + FLUX.2 Dev + ControlNet + IP-Adapter**
- **Why second:** Best AI approach. Combines pose control with appearance locking.
- **Time to first result:** 1-2 days
- **Ongoing cost:** GPU time (local) or cloud GPU rental
- **Risk:** Complex pipeline. Requires 12-24GB VRAM. Still has ~20% variation requiring QA.

**🥉 Rank 3: PixelLab (if pixel art style)**
- **Why third:** Purpose-built for exactly this problem, but style-locked to pixel art.
- **Time to first result:** 30 minutes
- **Ongoing cost:** SaaS subscription
- **Risk:** Vendor lock-in, pixel art only

**Honest Assessment: Is AI Frame-by-Frame Animation Production-Ready?**

**Short answer: Not yet for fighting games, with our current approach.**

AI-generated sprites are production-ready for: concept art, simple animations with proper pipeline, prototyping, pixel art with dedicated tools.

AI-generated sprites are NOT yet reliable for: complex fighting game animations without structural conditioning, frame-data-precise combat sprites, prompt-only generation.

**My recommendation:** Use AI for concept art and style exploration. Use 3D-to-2D (Mixamo + Blender) for production animation frames. This is what professional indie studios actually do.

**Proposed Next Steps**

1. **Immediate:** Stop generating frames with current approach. It won't improve.
2. **This week:** Boba runs a spike — download Mixamo fighter model, apply punch animation, render 5 frames in Blender, evaluate quality.
3. **This week:** Boba tests PixelLab with Kael's master sprite — 30 min evaluation.
4. **If 3D-to-2D works:** Adopt as primary pipeline.
5. **If we still want AI:** Set up ComfyUI + FLUX.2 Dev + ControlNet locally.
6. **Art direction decision:** Yoda + Boba align on pixel art (PixelLab-friendly) vs cel-shaded (needs 3D-to-2D or ControlNet pipeline).

---

### Decision: 3D-to-2D Sprite Pipeline via Mixamo + Blender (Chewie)
**Author:** Chewie (Engine Dev)  
**Date:** 2026-07-22  
**Status:** Proposed (Spike complete, awaiting founder validation)  
**Scope:** Ashfall art pipeline — sprite generation for all characters

**Context**

AI sprite generation (Kontext Pro / FLUX) failed for animation frames. Individual frames looked great but had zero frame-to-frame consistency. Unusable as actual game animation.

The team researched alternatives. Top recommendation: **3D-to-2D pipeline using Mixamo (free 3D models + animations) + Blender (automated rendering).**

**Decision**

Adopt a 3D-to-2D sprite rendering pipeline:

1. **Source:** Free Mixamo models + animations (FBX format, manual download — no API)
2. **Render:** Blender 4.x Python script, CLI-driven, orthographic camera, transparent PNG output
3. **Style:** Cel-shade toon shader (Shader-to-RGB + ColorRamp) for 2D fighting game look
4. **Output:** Individual frames as {character}_{animation}_{NNNN}.png at 512×512

**What Was Built (Spike)**

| File | Purpose |
|---|---|
| games/ashfall/tools/blender_sprite_render.py | Main render script — FBX import, camera, lighting, frame rendering, contact sheet |
| games/ashfall/tools/cel_shade_material.py | Toon material toolkit with character presets (kael, rhena) and outline support |
| games/ashfall/tools/BLENDER-SPRITE-PIPELINE.md | Full documentation — prerequisites, step-by-step guide, customization, troubleshooting |

**Why**

| Criterion | AI Generation | 3D-to-2D Pipeline |
|---|---|---|
| Frame consistency | ❌ Zero | ✅ Perfect (same mesh) |
| Animation flow | ❌ Frames don't connect | ✅ Mocap-driven, smooth |
| Style control | ⚠️ Prompt-dependent | ✅ Material/shader control |
| Cost | ✅ Pay per generation | ✅ Free (Mixamo + Blender) |
| Speed per character | ✅ Fast | ⚠️ Setup time, then fast batch |

**Next Steps**

1. **Founder validates spike** — Download one Mixamo model, run the script, check output quality
2. **If validated:** Render full Kael animation set (idle, walk, all attacks, hit, KO)
3. **If validated:** Render Rhena with different preset colors
4. **Long-term:** Consider custom 3D models (replace Mixamo with bespoke characters)

**Risks**

- Mixamo models are generic — may need custom modeling later for unique character identity
- Blender must be installed on dev machines (it is — founder confirmed)
- FBX import quality varies — some Mixamo rigs need manual cleanup

---

### V2 Frames REJECTED — Pipeline Pivot Directive (2026-03-10T09:27Z)
**By:** Joaquín (via Copilot)

v2 animation frames are WORSE than v1. Zero consistency between frames — each frame looks like a different character. Kontext Pro cannot maintain character identity across different poses via text prompts alone. Founder says "no veo que estemos avanzando".

**New approach needed:** pose conditioning with skeleton images (per ChatGPT research). Stop generating frames until pipeline is redesigned with pose conditioning.

**Why:** Critical quality failure. Current approach of text-only pose descriptions to Kontext Pro is fundamentally flawed for animation frames. Need skeleton/ControlNet conditioning via FLUX 2 Flex or equivalent.

---

### Art Style Direction — Pixel Art Target (2026-03-10T10:15Z)
**By:** Joaquín (via Copilot)

**What:** Visual target is Street Fighter pixel art style (Ryu). Classic 2D fighting game sprites with hand-drawn pixel art look. Not generic 3D, not cel-shade — pixel art like SF2/SF3.

**Why:** Founder defined the visual target for production sprites. This constrains art pipeline choices: either pixel-art post-processing on 3D renders, PixelLab SaaS, or stylized 3D models rendered to look like pixel art.

**Impact:** Clarifies Rank 3 (PixelLab) becomes viable alternative. 3D-to-2D with pixel-art post-processing is primary path. Confirms this is NOT high-res cel-shade.

# Decision: Free 3D Model Selection for Ashfall Character Pipeline

**Date:** 2026-01-09  
**Decision Maker:** Boba (Art Director)  
**Category:** Asset sourcing  
**Priority:** High (blocks character sprite production)

---

## Context

The Mixamo Y-Bot default mannequin lacks personality. Founder directive: "yo no quiero unos maniquies feos, quiero que sean personajes" (I don't want ugly mannequins, I want characters).

**Constraint:** Zero budget — must use free models.  
**Target Characters:** Kael (fire monk, orange palette) + Rhena (ice warrior, blue palette)  
**Pipeline:** Existing Mixamo FBX → Blender cel-shade render → 512×512 PNG

---

## Decision

### Primary Recommendation
**Use Quaternius (Kael) + RenderHub Liv (Rhena) as base models.**

**Rationale:**
1. **Quaternius (Kael)**
   - CC0 license (zero IP complications)
   - Rigged for animation, FBX export ready
   - Stylized aesthetic aligns with cel-shade look
   - Game-tested across 500+ indie titles
   - Customization path clear: recolor orange, add cloth wraps
   - Estimated effort: 8-12 hours Blender work

2. **RenderHub Liv (Rhena)**
   - Designed specifically for fighting games
   - Female-form character (matches Rhena brief)
   - Pre-rigged, Mixamo-compatible
   - Silhouette already combat-ready
   - Customization path clear: recolor blue, enhance armor
   - Estimated effort: 8-10 hours Blender work

3. **Both Models**
   - FBX format (native to our pipeline)
   - Mixamo skeleton compatibility (upload for animation library)
   - No format conversion needed
   - Risk level: Low (quality pre-validated)

### Fallback (If Phase 1 evaluation fails)
1. **Ready Player Me** (professional pipeline, higher customization depth)
2. **Kenney Mini Characters** (quality consistency, simpler aesthetic)
3. **OpenGameArt martial arts models** (if Sketchfab/community options emerge)

---

## Alternatives Considered

| Option | Pros | Cons | Rank |
|---|---|---|---|
| **Quaternius + RenderHub** | CC0, game-tested, FBX-ready, low risk | Requires 16-22hr Blender work | ⭐⭐⭐ |
| **Ready Player Me** | Professional, highly customizable, standard rig | GLB→FBX conversion, higher complexity | ⭐⭐ |
| **Kenney** | Extremely consistent, CC0, well-documented | Less personality, higher customization needed | ⭐⭐ |
| **Sketchfab browsing** | Massive variety, unique models | Quality inconsistent, licensing risk, rigging variable | ⭐ |
| **Commission new models** | Perfect fit, original IP | $1000-5000+ cost, violates zero-budget constraint | ✗ |
| **Stay with Y-Bot** | No development time, pipeline proven | Founder rejected; lacks personality | ✗ |

**Conclusion:** Quaternius + RenderHub balance quality, effort, cost, and timeline constraints best.

---

## Implementation Plan

### Phase 1: Evaluation (2 hours)
**Objective:** Validate Blender pipeline and Mixamo compatibility.

1. Download Quaternius fighter + RenderHub Liv (FBX)
2. Import both to Blender (test scene)
3. Run through cel-shade material application
4. Render test PNG at 512×512
5. Upload to Mixamo, validate auto-rig + animation retargeting
6. **Decision Point:** Proceed to Phase 2 or adjust model selection

**Owner:** Boba (Art Director)  
**Timeline:** 2 hours  
**Success Criteria:**
- FBX imports cleanly
- Cel-shade material renders without topology issues
- Mixamo auto-rig succeeds (skeleton recognized)
- Test animation applies correctly

### Phase 2: Customization (16-22 hours)
**Objective:** Customize models to Kael/Rhena specifications.

#### Kael (Quaternius Base) — 8-12 hours
1. Material customization: orange palette (#FF8C00, #FFA500, #FFB347)
2. Model customization:
   - Add cloth wraps (geometry modeling)
   - Remove shoes → barefoot variant
   - Optional: enhance face/features for personality
3. Rig verification: Ensure Mixamo skeleton intact
4. FBX export with armature
5. Upload to Mixamo, tag for "meditation", "punch", "kick" animations
6. Contact sheet generation (4 key poses)

#### Rhena (RenderHub Liv Base) — 8-10 hours
1. Material customization: steel blue palette (#2E5C8A, #4A90E2, #1C3A5F)
2. Model customization:
   - Armor silhouette enhancement (if needed)
   - Adjust color contrast (armor vs. body)
   - Optional: weapon refinement
3. Rig verification: Ensure Mixamo skeleton intact
4. FBX export with armature
5. Upload to Mixamo, tag for "warrior stance", "punch", "kick" animations
6. Contact sheet generation (4 key poses)

**Owner:** Boba (Art Director)  
**Timeline:** 2-3 days elapsed (assuming 4-6 hours/day Blender work)  
**Success Criteria:**
- Contact sheets approved by Founder
- Models match character brief (personality, colors, silhouette)
- Mixamo animations apply cleanly

### Phase 3: Production Rendering (4-6 hours)
**Objective:** Generate full sprite library for Godot.

1. Mixamo animation download (100+ free martial arts animations)
2. Batch render sprites (512×512, RGBA)
3. Sprite sheet generation + naming convention alignment
4. Godot asset import
5. In-game testing + visual QA

**Owner:** Chewie (Engine) + Boba (Art Direction)  
**Timeline:** 1 day  
**Success Criteria:**
- All animations render without artifacts
- Sprite sheets match cel-shade spec (0.008 outline, 2-step shadow)
- In-game appearance matches contact sheets

---

## Resource Requirements

### Software
- **Blender 4.x** (existing; cel-shade material already configured)
- **Mixamo account** (free Adobe tier sufficient)
- **Python script** (existing render pipeline)

### Time Commitment
- **Art Director:** 18-24 hours (Phase 1 evaluation + Phase 2 customization + approval gates)
- **Engine (Chewie):** 2 hours (Phase 3 rendering + Godot import validation)
- **Total:** 20-26 hours

### Cost
- **Models:** $0 (CC0 + free)
- **Software:** $0 (existing licenses)
- **Timeline:** 5-7 days calendar time (assuming 4-6 hr/day work availability)

---

## Approval Gate

**Before Phase 2 begins:** Founder must approve model styles + color palettes from Phase 1 test renders.

**Decision Required:**
1. Quaternius stylized aesthetic acceptable? (vs. more realistic alternatives)
2. RenderHub Liv proportions match Rhena vision?
3. Timeline realistic for project schedule?

---

## Success Metrics

✅ **Phase 1 Complete:**
- Blender pipeline validated for both models
- Mixamo upload/animation retargeting verified
- Test PNG render quality acceptable

✅ **Phase 2 Complete:**
- Contact sheets approved by Founder
- Kael matches orange/cloth aesthetic
- Rhena matches blue/warrior aesthetic
- FBX exports clean (no topology/rig warnings)

✅ **Phase 3 Complete:**
- 100+ martial arts animation sprites rendered
- Godot asset integration successful
- In-game character appearance matches specs

---

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| Quaternius model doesn't customize well to orange | High | Low | Phase 1 testing; fallback to Kenney |
| RenderHub Liv rig incompatible with Mixamo | High | Low | Manual rig adjustment; fallback to CGTrader |
| Blender topology issues during rendering | Medium | Medium | Retopo or model swap; 2-4 hour delay |
| Founder rejects style after Phase 1 | High | Medium | Early approval gate; discuss alternatives now |
| Timeline overruns (Blender work slower than estimated) | Medium | Medium | Pare customization scope; focus on color only |

---

## Decision Record

**Approved By:** Boba (Art Director)  
**Reviewed By:** [Pending Founder feedback]  
**Date Decided:** 2026-01-09  
**Status:** Ready for Phase 1 execution

**Next Action:** Schedule Phase 1 evaluation; present test renders to Founder for style approval before proceeding to Phase 2.

---

## References

- **Research:** `games/ashfall/docs/FREE-3D-MODEL-RESEARCH.md`
- **Quaternius:** https://quaternius.com/characters.html
- **RenderHub Liv:** https://www.renderhub.com/hisqiefurqoni/stylized-female-fighting-character-liv
- **Mixamo:** https://mixamo.com
- **Blender Cel-Shade Pipeline:** `tools/scripts/cel_shade_material.py` (existing)

# Decision: Auto-Screenshot Mode for Sprite Viewer

**Author:** Chewie (Engine Developer)  
**Date:** 2026-10-03  
**Status:** IMPLEMENTED  
**Scope:** Ashfall sprite viewer test tooling

## Context
Joaquín was frustrated by the manual loop: agents tweak sprite viewer code → Joaquín opens Godot → runs scene → reports result. No agent could verify visual output independently.

## Decision
Added a `--screenshot` CLI mode to `sprite_poc_test.gd` that:
1. Parses `OS.get_cmdline_user_args()` for `--screenshot`, `--char=`, `--anim=`
2. Waits 5 render frames, captures viewport to PNG
3. Saves to both `user://screenshot.png` and project root `screenshot.png`
4. Prints paths to stdout and quits

Created `games/ashfall/tools/screenshot.bat` to wrap the Godot CLI call.

## Rationale
- **Zero impact on interactive mode** — `_process()` early-returns when not in screenshot mode
- **Dual save paths** — `user://` is always writable; project root is easy for agents/humans to find
- **Extensible** — same pattern works for any scene; just change `--scene` in the CLI call
- **Agent-friendly** — batch file can be invoked from any automation; stdout confirms paths

## Key Paths
- Script: `games/ashfall/scripts/test/sprite_poc_test.gd`
- Batch: `games/ashfall/tools/screenshot.bat`
- Output: `games/ashfall/screenshot.png`

# Decision: Mixamo Character Sprite Rendering

**Author:** Chewie (Engine Developer)
**Date:** 2025-07-08
**Status:** COMPLETED

## Context

The founder selected two custom Mixamo characters (Kael and Rhena) with real clothing, proportions, and personality — replacing the generic Y-Bot placeholder. These models come with their own materials/textures from Mixamo's character system.

## Decision

**Render with original Mixamo materials (no cel-shade override).**

The pipeline previously used `--cel-shade --preset kael/rhena` to apply monochrome toon shading. For these production characters, we tested rendering WITHOUT cel-shade first — letting the model's own skin, clothing, and hair textures come through EEVEE's standard renderer.

**Result: Original materials render cleanly.** The characters look like themselves, with distinct clothing, skin tones, and hair. No need for the cel-shade fallback.

## Render Summary

| Character | Animation   | Source FBX     | Frames | Step | Output Directory                    |
|-----------|-------------|----------------|--------|------|-------------------------------------|
| Kael      | Idle        | Idle.fbx       | 30     | 2    | sprites/kael/idle/                  |
| Kael      | Walk        | Walking.fbx    | 16     | 2    | sprites/kael/walk/                  |
| Kael      | Punch       | Punching.fbx   | 13     | 5    | sprites/kael/punch/                 |
| Kael      | Kick        | Side Kick.fbx  | 13     | 5    | sprites/kael/kick/                  |
| Rhena     | Idle        | Idle.fbx       | 106    | 2    | sprites/rhena/idle/                 |
| Rhena     | Walk        | Walking.fbx    | 16     | 2    | sprites/rhena/walk/                 |
| Rhena     | Punch       | Hook Punch.fbx | 14     | 5    | sprites/rhena/punch/                |
| Rhena     | Kick        | Mma Kick.fbx   | 13     | 5    | sprites/rhena/kick/                 |

**Totals:** 221 frames rendered, 8 contact sheets generated.

## Notes

- Rhena's idle animation is 106 frames (212 source frames at step=2) — unusually long. May want to trim for in-game use.
- Root motion pinning (mixamorig:Hips X/Y zeroed) worked on all animations — no character drift.
- Renderer: BLENDER_EEVEE (not EEVEE_NEXT), standard 2-light rig (key 3.0 + fill 1.5).
- Contact sheets generated for visual review in each output directory.
- If the art direction later calls for unified cel-shade style, the `--cel-shade --preset` flags remain available.

# Decision: 3D Character Models Downloaded & Tested

**Date:** 2025-07-08  
**Author:** Chewie (Engine)  
**Status:** Results ready for founder review

---

## What Happened

Downloaded free CC0 3D character models and ran them through our Blender cel-shade pipeline.

### Successfully Downloaded (automated)
| Pack | Source | Characters | Format | Size |
|------|--------|-----------|--------|------|
| **Quaternius RPG Pack** | Google Drive | Monk, Warrior, Rogue, Ranger, Cleric, Wizard + weapons | FBX/Blend/glTF | ~15 MB |
| **Kenney Animated Characters 1-3** | kenney.nl | 3× characterMedium + animations | FBX | ~2 MB |
| **Kenney Mini Characters** | kenney.nl | 12 characters (6M/6F) | FBX/GLB | ~2.3 MB |

All saved to: `games/ashfall/assets/3d/characters/`

### Pipeline Test Results

**Quaternius Monk** → **WINNER for Kael base.** Fighting stance with fists raised, chibi proportions, cel-shade looks great. Already animated with combat idle.

**Quaternius Warrior** → Sword character with ponytail and armor. Great silhouette and personality. Animation includes attack sequence.

**Kenney models** → Too generic. Same mannequin problem as Y-Bot. Not recommended.

### Test renders at:
- `games/ashfall/assets/sprites/test_quaternius_monk/` (11 frames + contact sheet)
- `games/ashfall/assets/sprites/test_quaternius_warrior/` (15 frames + contact sheet)
- `games/ashfall/assets/sprites/test_kenney_kael_side/` (Kenney with Kael colors)

---

## Known Limitations

1. **Monochrome rendering** — Our cel-shade pipeline paints everything one color (Kael orange). Clothes, skin, hair all same tone. Needs per-material color work for production.
2. **Animation framing** — Characters with big motion (jumps, swings) can exit the camera frame. Pipeline auto-fit uses frame-1 bounds only.
3. **Mixamo retargeting needed** — Quaternius models have their own animations (idle/attack), but we need Mixamo martial arts library (punch, kick, walk, etc.) for the full moveset.

---

## 30-Second Download Guide (for Joaquin)

### Priority 1: More Quaternius Packs (browser)
These have the best fighting-game characters. Open in browser → click "Download" → save ZIP:

1. **Knight Pack** (animated knight with swords/helmets):
   `https://drive.google.com/drive/folders/1QVyfCJkq70mAwMIh1cGq1xfHp2LN5GmK`

2. **Animated Women** (4 female characters with animations):
   `https://drive.google.com/drive/folders/1c13R--fMqdR6r2MRlcKKsbPky0__T-yJ`

3. **Universal Base Characters** (6 models, 3 body types, 20 hairstyles):
   Visit `https://quaternius.itch.io/universal-base-characters` → click "Download" (free)

Save FBX files to: `games/ashfall/assets/3d/characters/`

### Priority 2: KayKit Adventurers (browser)
5 rigged/animated dungeon characters with 25+ weapons. CC0 license.
1. Visit `https://kaylousberg.itch.io/kaykit-adventurers`
2. Click "Download" → "No thanks, just take me to the downloads"
3. Download the free ZIP
4. Extract FBX files to `games/ashfall/assets/3d/characters/kaykit-adventurers/`

### Priority 3: Mixamo Characters (browser)
Your existing Mixamo account has built-in characters beyond Y-Bot:
1. Go to `https://mixamo.com` → log in
2. Click "Characters" tab (top-left)
3. Try: **Mery** (female), **Big Vegas** (stocky male), **Mutant** (creature)
4. Select any animation → Download as FBX
5. These come pre-rigged — drop directly into pipeline

### Test any FBX in pipeline:
```
"C:\Program Files\Blender Foundation\Blender 5.0\blender.exe" --background --python games/ashfall/tools/blender_sprite_render.py -- --input YOUR_MODEL.fbx --output games/ashfall/assets/sprites/test_output/ --character test --animation idle --size 512 --step 2 --cel-shade --preset kael --outline --contact-sheet
```

---

## Recommendation

**Use Quaternius Monk as Kael's base mesh.** It's already in the repo, already renders through our pipeline, has a fighting stance, and the chibi proportions give it character. Upload to Mixamo for the full martial arts animation set, then customize colors in Blender.

For Rhena, download the Quaternius Animated Women pack or KayKit Adventurers — both have female warrior characters that could work as a base.

# Sprite Pipeline V2 — Root Motion Pinning & Animation-Aware Stepping

**Author:** Chewie (Engine Developer)  
**Date:** 2025-07-23  
**Status:** Implemented  
**Scope:** Ashfall sprite rendering pipeline (`blender_sprite_render.py`)

## Changes Made

### 1. Tighter Camera Framing
- Ortho scale padding: **1.1× → 1.03×** of model bounds
- Character now fills ~97% of the 512×512 frame vs ~90% before
- Still auto-fits; `--ortho-scale` CLI override still available

### 2. Root Motion Pinning (NEW)
- Mixamo animations bake root motion into `mixamorig:Hips` bone
- New `pin_root_motion()` zeros X/Y translation each frame, keeps Z + rotations
- Runs after `frame_set()`, before `render()` — character stays centered
- Auto-detects root bone with fallback chain: mixamorig:Hips → Hips → Root → first parentless bone

### 3. Animation-Aware Frame Stepping (NEW)
- `ANIM_STEP_HINTS` dict maps animation keywords to optimal steps
- Attacks (punch/kick/heavy/special): **step=5** → ~13 frames (was 31 with step=2)
- Loops (idle/walk/run): **step=2** → 16-17 frames (unchanged)
- Auto-applied via `get_smart_step()`; user `--step` still works as override
- Key metric met: **no attack exceeds 15 frames**

## Frame Count Summary
| Animation | Old Frames | New Frames | At 15fps |
|-----------|-----------|------------|----------|
| idle      | 17        | 17         | 1.13s    |
| walk      | 16        | 16         | 1.07s    |
| punch     | 31        | 13         | 0.87s    |
| kick      | 31        | 13         | 0.87s    |

## Impact on Team
- **Art (Boba):** Sprites are larger in frame, centered, and attack timing is game-appropriate. Review contact sheets.
- **Design (Yoda):** Frame data for moves can now reference 13-frame attacks for punch/kick — much snappier feel.
- **Godot integration:** Same output paths, same naming convention. Just re-import the updated PNGs.
- **Future characters:** Pipeline auto-handles any Mixamo FBX — root motion pinning and smart stepping are automatic.

# PNG Sprite Integration into CharacterSprite

**Author:** Chewie (Engine Developer)  
**Date:** 2026-07-24  
**Status:** Implemented  
**Scope:** Ashfall fighter rendering pipeline

## Decision

Modified `CharacterSprite` base class to auto-detect and render pre-rendered PNG sprites instead of procedural `_draw()` geometry. The system probes `res://assets/sprites/{character_id}/` at startup and creates an `AnimatedSprite2D` child if sprites are found.

## Key Design Choices

1. **Detection via virtual method** — `_get_character_id()` returns the character folder name. Base returns `""` (no sprites). Subclasses override with `"kael"` / `"rhena"`. Cleaner than class name parsing.

2. **Pose setter branches** — When `pose` changes, the setter calls `_update_sprite_animation()` (PNG mode) or `queue_redraw()` (procedural mode). No new signals, no polling.

3. **Graceful fallback** — If sprites aren't found, procedural rendering continues unchanged. Both Kael and Rhena can run with or without PNGs.

4. **Zero changes to downstream systems** — `SpriteStateBridge`, `FighterAnimationController`, fighter `.tscn` files, hitboxes, and HUD are all untouched. The integration is entirely inside `CharacterSprite`.

5. **Scale constant** — `_PNG_SPRITE_SCALE = 0.15` (512px → ~77px). Tunable constant, not buried in logic.

## Impact on Team

- **Boba:** New sprite animations (block, hit, jump, etc.) just need to follow the naming convention `{char}_{anim}_{NNNN}.png` in the correct folder. Add the animation name to `_SPRITE_ANIM_CONFIGS` and pose mappings to `_POSE_TO_ANIM`.
- **Wedge:** No gameplay changes. State machine and hitbox systems unaffected.
- **Joaquín:** Run the game normally — if PNGs exist, they render automatically.

## Files Changed

- `games/ashfall/scripts/fighters/sprites/character_sprite.gd` — PNG sprite system added
- `games/ashfall/scripts/fighters/sprites/kael_sprite.gd` — `_get_character_id()` override
- `games/ashfall/scripts/fighters/sprites/rhena_sprite.gd` — `_get_character_id()` override

# Squad Documentation Deep Audit — Complete Feature Inventory

**Author:** Jango (Tool Engineer)
**Date:** 2026-07-23
**Status:** Proposed
**Audience:** Joaquín (Founder), all agents

---

## Summary

Deep-crawled 25+ pages of the Squad docs site (bradygaster.github.io/squad). Read every Get Started, Concepts, Features, Guide, Reference, Scenarios, Cookbook, and What's New page. Cross-referenced against our `.squad/` directory, `squad.config.ts`, GitHub workflows, and identity files. This report covers **every documented feature** with our adoption status, value assessment, and specific next steps.

---

## Feature Inventory

### 1. CLI Installation & Distribution

**What it does:** Squad installs via `npm i -g @bradygaster/squad-cli`. Supports global install, npx one-off, and SDK library import.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — we have `squad.config.ts` and full `.squad/` directory |
| Value | 🤷 Low — already done |
| Effort | N/A |

---

### 2. Team Formation (Init Mode)

**What it does:** `squad init` scans your repo, proposes a 3-7 member team based on detected stack, lets you customize, then writes `.squad/` directory with charters, routing, and casting.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — 15 agents + Scribe + Ralph + @copilot on the roster |
| Value | 🤷 Low — already mature |
| Effort | N/A |

---

### 3. Parallel Fan-Out Execution

**What it does:** Saying "Team, ..." triggers parallel agent spawning. Multiple agents work simultaneously in separate context windows. Coordinator collects and synthesizes results.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — we use "Team, ..." pattern regularly |
| Value | 🔥 High — multiplies throughput on multi-domain tasks |
| Effort | N/A |

---

### 4. Response Modes (Direct / Lightweight / Standard / Full)

**What it does:** Squad auto-selects effort level. Direct (~2-3s) for status checks, Lightweight (~8-12s) for quick fixes, Standard (~25-35s) for normal work, Full (~40-60s) for multi-agent tasks.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — automatic, no config needed |
| Value | 💡 Medium — saves tokens on simple queries |
| Effort | N/A |

---

### 5. Work Routing (Named / Domain / Skill-Aware)

**What it does:** Three routing strategies: Named ("Chewie, fix X"), Domain (pattern matching in `routing.md`), and Skill-aware (agent with relevant skill preferred). First match wins.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — comprehensive `routing.md` with 13 work types |
| Value | 🔥 High — critical for correct agent assignment |
| Effort | N/A |

---

### 6. Reviewer Protocol & Lockout

**What it does:** When a reviewer (Lead, Tester) rejects work, the original agent gets locked out — no self-revision allowed. Prevents endless fix-retry loops. Deadlock handling escalates to user.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — Solo (Lead) and Ackbar (QA) have review authority |
| Value | 🔥 High — prevents infinite feedback loops |
| Effort | N/A |

---

### 7. Ceremonies (Design Review + Retrospective)

**What it does:** Structured meetings auto-triggered at key moments. Design Review before multi-agent tasks with shared systems. Retrospective after failures. Custom ceremonies supported.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — both Design Review and Retrospective configured in `ceremonies.md` |
| Value | 🔥 High — design reviews prevent conflicting implementations |
| Effort | N/A |

**Gap noted:** We have only the two default ceremonies. Docs mention you can add custom ceremonies (e.g., "security review", "sprint planning"). We could add:
- **Sprint Planning ceremony** — Mace facilitates, auto-triggers at sprint boundaries
- **Art Review ceremony** — Boba facilitates before sprite/animation integration

---

### 8. Decisions System (decisions.md + inbox)

**What it does:** Append-only shared memory all agents read before working. Decisions captured from agent work (inbox files), user directives, and Scribe merges.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — large `decisions.md` (85KB!), active inbox with 7 pending items |
| Value | 🔥 High — team alignment backbone |
| Effort | N/A |

**⚠️ Critical gap: Decision Archiving.** Docs say when `decisions.md` gets large, old decisions should archive to `decisions-archive.md` — "preserved for reference but no longer loaded into agent context." Our file is **85KB** — that's eating enormous context budget. We do NOT have a `decisions-archive.md`.

**Recommendation:** 🔥 HIGH PRIORITY — Archive stale sprint artifacts and one-time planning fragments. This could cut agent context usage dramatically.

---

### 9. Directives (Signal Word Detection)

**What it does:** Say "always", "never", "from now on", "remember to", "don't", "make sure to" and Squad captures it as a permanent team rule. Persists across all sessions.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Configured but underused — directives exist in `decisions.md` but we don't have a separate `directives.md` |
| Value | 🔥 High — fastest way to shape team behavior |
| Effort | Trivial (minutes) |

**Docs note:** The CLI reference mentions a separate `directives.md` file for permanent rules. We embed them in `decisions.md`. Either approach works, but a dedicated file prevents dilution.

---

### 10. Skills System (Starter + Earned, Confidence Lifecycle)

**What it does:** Reusable knowledge files at `.squad/skills/{name}/SKILL.md`. Team-wide (not per-agent). Earned skills have confidence lifecycle: Low → Medium → High. Skills are portable across projects via export/import.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — **31 skills** in `.squad/skills/`, covering game design, combat, audio, tools, workflow, etc. |
| Value | 🔥 High — massive knowledge base already |
| Effort | N/A |

**Gap noted:** We likely haven't assigned confidence levels to our earned skills. Docs say earned skills should have `**Confidence:** low|medium|high` in them. Worth auditing.

---

### 11. Personal History (history.md per agent)

**What it does:** Each agent has `.squad/agents/{name}/history.md`. After every session, agents append learnings. Only that agent reads its own history. Progressive summarization when >12KB.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — all agents have history files, some quite large |
| Value | 🔥 High — specialized per-agent memory |
| Effort | N/A |

**Gap noted:** Progressive summarization. Docs say when history exceeds ~12KB, older entries should be archived into a summary section. Some of our agent histories (like Jango's at 25KB) may be oversized.

---

### 12. Human Team Members

**What it does:** Add real people to the roster with 👤 Human badge. No charter, no history, never spawned as sub-agent. When work routes to them, Squad pauses and tells you someone needs to act. Stale reminders keep things moving.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no human members on roster |
| Value | 💡 Medium — useful for Joaquín as formal approval gate |
| Effort | Trivial (minutes) |

**Recommendation:** Consider adding Joaquín as a human member for approval gates on architecture decisions, sprint scope, and art direction sign-off. The docs' litmus test: "If you want agents to stop and wait for someone's input before proceeding, add them."

---

### 13. @copilot Coding Agent Integration

**What it does:** GitHub Copilot coding agent as autonomous squad member. Picks up issues, creates branches, opens PRs. Three-tier capability profile (🟢🟡🔴). Auto-assign via `COPILOT_ASSIGN_TOKEN` PAT.

| Aspect | Assessment |
|--------|------------|
| Our status | ⚠️ Partially set up — @copilot on roster, capability profile defined, `squad-issue-assign.yml` exists, BUT auto-assign is `false` and likely no `COPILOT_ASSIGN_TOKEN` secret |
| Value | 🔥 High — autonomous async work on well-defined tasks |
| Effort | Small (< 1 hour) |

**To fully enable:**
1. Set `copilot-auto-assign: true` in `team.md`
2. Create classic PAT with `repo` scope at github.com/settings/tokens/new
3. `gh secret set COPILOT_ASSIGN_TOKEN` on the repo
4. Ensure `copilot-setup-steps.yml` exists in `.github/`
5. Test by labeling an issue `squad:copilot`

---

### 14. Ralph — Work Monitor

**What it does:** Built-in agent that tracks the work queue, monitors CI status, auto-triages issues. Three layers: in-session ("Ralph, go"), local watchdog (`squad watch`), cloud heartbeat (GitHub Actions cron). Never stops while work remains.

| Aspect | Assessment |
|--------|------------|
| Our status | ⚠️ Partially set up — Ralph on roster, `squad-heartbeat.yml` exists, but likely not actively used for continuous monitoring |
| Value | 🔥 High — autonomous backlog processing |
| Effort | Small (< 1 hour) to fully activate |

**Untapped patterns:**
- "Ralph, go" — activates in-session work loop
- `squad watch --interval 5` — persistent local polling
- Heartbeat cron for fully unattended triage

---

### 15. GitHub Issues Integration

**What it does:** Connect to repo, view backlog, work on issues, agents create branches/PRs, handle review feedback, merge. Full issue-driven development workflow.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — issue source connected to `jperezdelreal/FirstFrameStudios`, routing labels configured |
| Value | 🔥 High — core workflow |
| Effort | N/A |

---

### 16. Plugin Marketplace

**What it does:** Community-curated bundles of agent templates, skills, and best practices. Available marketplaces include awesome-copilot, anthropic-skills, azure-cloud-dev, security-hardening. Install with `/plugin install`.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no plugins directory, no marketplace configured |
| Value | 💡 Medium — could bring pre-built patterns for game dev |
| Effort | Small (< 1 hour) |

**Recommendation:** Check if any marketplaces have game-dev-related plugins. We have `plugin-marketplace.md` in `.squad/` (docs template) but no actual marketplace configured. Try: `"Browse awesome-copilot marketplace"` in a session.

---

### 17. Export & Import

**What it does:** Export trained team to portable JSON. Import into any repo. Skills, casting state, agent histories included. Project-specific details stripped on import.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available but unused — `squad export` is a CLI command we haven't used |
| Value | 💡 Medium — useful when we start our second game project |
| Effort | Trivial (minutes) |

**When to use:** Before major refactors (backup), when starting the next game project (bring trained team), sharing with collaborators.

---

### 18. Personal Squad (Cross-Project)

**What it does:** `squad init --global` creates `~/.squad/` — a personal team root. All projects point to it. Agents remember conventions across all repos. Skills learned in one project carry to all others.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — `config.json` shows `teamRoot: "."` (local mode) |
| Value | 💡 Medium — becomes high when we have multiple game projects |
| Effort | Small (< 1 hour) |

**When to adopt:** When we start the second game project. For now, single-project local mode is correct.

---

### 19. Consult Mode

**What it does:** Bring your personal squad to projects you don't own (OSS, client work) without leaving traces. Team consults invisibly, then extracts generic learnings back to personal squad.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up (requires Personal Squad first) |
| Value | 🤷 Low for us — we're not contributing to other repos with Squad |
| Effort | N/A |

---

### 20. Upstream Inheritance

**What it does:** Declare external Squad sources (other repos, local dirs, exports) and inherit their context (skills, decisions, routing) at session start. Enables knowledge sharing across teams/orgs.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no `upstream.json` |
| Value | 💡 Medium — useful for multi-project studios (share game-dev skills across projects) |
| Effort | Small (< 1 hour) |

**When to adopt:** When we have 2+ game projects and want to share studio-level conventions without duplicating. Our `identity/` directory already captures studio-level wisdom — upstream inheritance would formalize sharing it.

---

### 21. SDK-First Mode (squad.config.ts)

**What it does:** Define your team in TypeScript using builder functions (`defineTeam`, `defineAgent`, `defineRouting`, `defineCeremony`, `defineHooks`, `defineCasting`, `defineTelemetry`). Typed, testable, version-controlled. Run `squad build` to generate `.squad/` files.

| Aspect | Assessment |
|--------|------------|
| Our status | ⚠️ Partially set up — we have `squad.config.ts` but it uses basic config format, not full builder functions |
| Value | 💡 Medium — typed config is nice but our markdown-based setup works |
| Effort | Medium (session) to fully migrate |

**Gap noted:** Our `squad.config.ts` routes everything to `@scribe` — this looks like a placeholder/template that was never customized. The routing rules in `routing.md` are the ones actually used. The config should either be fixed or removed to avoid confusion.

---

### 22. Governance Hooks (defineHooks)

**What it does:** File-write guards (allowedWritePaths), blocked commands, PII scrubbing, reviewer lockout enforcement, maxAskUser limit. Enforced in code, not just suggestions.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no hooks defined in `squad.config.ts` |
| Value | 🔥 High — prevents agents from writing outside their domain, scrubs PII |
| Effort | Small (< 1 hour) |

**Recommendation:** Add `defineHooks` to our config:
```ts
hooks: {
  allowedWritePaths: ['games/**', '.squad/**', 'tools/**', 'docs/**'],
  blockedCommands: ['rm -rf', 'DROP TABLE'],
  scrubPii: true,
  reviewerLockout: true,
  maxAskUser: 3,
}
```

---

### 23. Model Selection & Fallback Chains

**What it does:** Per-agent model selection based on task type. 16+ models across Premium/Standard/Fast tiers. Task-aware defaults (code → Sonnet, docs → Haiku, visual → Opus). Fallback chains for unavailability.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — `squad.config.ts` has full fallback chain config, default model `claude-sonnet-4.5` |
| Value | 🔥 High — cost optimization without quality loss |
| Effort | N/A |

---

### 24. Casting System (Universe Themes)

**What it does:** Agents named from fictional universes. Allowlist universes, overflow strategy, capacity limits. 33+ universes available.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — Star Wars universe, casting history/policy/registry files present |
| Value | 💡 Medium — team cohesion and personality |
| Effort | N/A |

**Note:** `squad.config.ts` lists different allowlist universes (Usual Suspects, Breaking Bad, The Wire, Firefly) than what we actually use (Star Wars). Config is mismatched — our actual casting uses Star Wars per `team.md`.

---

### 25. Identity Layer (wisdom.md, now.md)

**What it does:** `wisdom.md` stores reusable heuristics learned through work. `now.md` provides temporal awareness (current sprint, priorities).

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — `.squad/identity/` has wisdom.md, now.md, company.md, mission-vision.md, principles.md, quality-gates.md, growth-framework.md, new-project-playbook.md |
| Value | 🔥 High — deep studio identity beyond just project context |
| Effort | N/A |

---

### 26. Interactive Shell (squad command)

**What it does:** Persistent interactive session with `/status`, `/history`, `/agents`, `/sessions`, `/resume` commands. Session management with resume capability.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available — we primarily use `copilot --agent squad` instead |
| Value | 💡 Medium — `/sessions` and `/resume` could help with session continuity |
| Effort | Trivial (minutes) |

---

### 27. squad doctor (Setup Validation)

**What it does:** 9-check setup validation with clear pass/fail output. Validates `.squad/` structure, config files, agent definitions, file permissions, integrations.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available but likely not routinely run |
| Value | 💡 Medium — useful diagnostic after upgrades or problems |
| Effort | Trivial (minutes) — just run `squad doctor` |

---

### 28. squad upgrade

**What it does:** Upgrades Squad-owned files (templates, workflows) to latest version without touching team state (charters, decisions, history).

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available — unknown when last run |
| Value | 💡 Medium — keeps templates current |
| Effort | Trivial (minutes) |

---

### 29. squad nap (Context Hygiene)

**What it does:** Compress, prune, archive `.squad/` state. `--deep` for thorough cleanup, `--dry-run` to preview. Keeps context budget lean.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not used — never run |
| Value | 🔥 High — our 85KB decisions.md and 25KB+ history files scream for this |
| Effort | Trivial (minutes) |

**Recommendation:** Run `squad nap --dry-run` to preview, then `squad nap --deep` to clean up. This directly addresses our context bloat problem.

---

### 30. squad scrub-emails

**What it does:** Remove email addresses from Squad state files. PII protection.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Available but unknown if needed |
| Value | 🤷 Low — small team, unlikely PII in state files |
| Effort | Trivial (minutes) |

---

### 31. Remote Control (squad start --tunnel)

**What it does:** Control Copilot CLI from phone via secure WebSocket tunnel. PTY + devtunnel + phone browser. 7-layer security model. Perfect for demos.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up |
| Value | 🤷 Low for us — no mobile workflow needed |
| Effort | Small (< 1 hour) |

---

### 32. OpenTelemetry / Aspire Dashboard

**What it does:** Observability for Squad operations. Traces, metrics, spans. Aspire dashboard for visualization.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up |
| Value | 🤷 Low — overkill for our team size |
| Effort | Medium (session) |

---

### 33. Git Worktrees Support

**What it does:** Two strategies — worktree-local (independent `.squad/` per worktree) or main-checkout (shared via symlink). `merge=union` for append-only files.

| Aspect | Assessment |
|--------|------------|
| Our status | 🟡 Merge rules likely configured via `.gitattributes` |
| Value | 🤷 Low — we don't use worktrees currently |
| Effort | N/A |

---

### 34. GitHub Workflows Suite

**What it does:** Squad installs/upgrades 11+ GitHub Actions workflows: heartbeat, triage, issue-assign, label-enforce, CI, docs, main-guard, preview, promote, release, insider-release.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — 11 squad-* workflows + sync-squad-labels.yml |
| Value | 🔥 High — automation backbone |
| Effort | N/A |

---

### 35. Decision Archiving

**What it does:** When `decisions.md` grows large, archive old decisions to `decisions-archive.md`. Active decisions stay lean; agents read less context.

| Aspect | Assessment |
|--------|------------|
| Our status | ❌ Not set up — no `decisions-archive.md` exists, main file is 85KB |
| Value | 🔥 High — directly reduces context waste |
| Effort | Small (< 1 hour) |

---

### 36. Scribe Agent

**What it does:** Silent decision logger. Periodically consolidates inbox files into canonical `decisions.md`, deduplicating overlapping entries. Always on roster.

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — Scribe on roster with charter |
| Value | 🔥 High — maintains shared memory |
| Effort | N/A |

---

### 37. Concurrency Limits

**What it does:** Default 5 agents in parallel. Adjustable via prompt ("Run at most 2 agents at once to save costs").

| Aspect | Assessment |
|--------|------------|
| Our status | ✅ Active — default behavior |
| Value | 💡 Medium — cost control lever |
| Effort | N/A |

---

## Sample Prompts from the Docs We Should Try

### High-Value for Game Studio Context

```
Team, build the [feature] — include gameplay code, art integration, and tests.
```
Multi-agent fan-out tuned for our domain.

```
Ralph, go — start monitoring and process the backlog until it's clear.
```
Activate autonomous work processing.

```
Run a design review before we start the [feature] rebuild.
```
Formal ceremony before multi-agent architecture work.

```
Run a retro on why those tests failed.
```
Automated root-cause analysis.

```
Always use [convention]. From now on, [rule].
```
Directive capture for persistent team rules.

```
Yoda, do a 20-minute spike on [design question]. Write a decision.
```
Architectural spike pattern.

```
Show me what skills this team has learned.
```
Audit accumulated knowledge.

```
What did the team accomplish last session? Any blockers?
```
Quick status without spawning agents.

```
Team, design the [system]. Don't code yet. Write decisions to decisions.md.
```
Decision-first development pattern.

```
Export the current team.
```
Backup before major changes.

---

## Best Practices We're Not Following

### 1. Decision Archiving (CRITICAL)
Our `decisions.md` is **85KB**. The docs explicitly say to archive stale entries to `decisions-archive.md` so agents read a lean, current shared brain. This is likely our #1 context budget waste.

### 2. Progressive History Summarization
Agent history files should be summarized when >12KB. Some of ours are 25KB+. The docs say older entries should condense into a summary section.

### 3. Context Hygiene (`squad nap`)
Never used. Docs recommend periodic cleanup to compress, prune, and archive `.squad/` state.

### 4. Skill Confidence Levels
Our 31 skills likely don't have confidence metadata (Low/Medium/High). The docs say earned skills should track how battle-tested they are.

### 5. Directives in Dedicated File
The CLI reference shows a `directives.md` file for permanent rules separate from `decisions.md`. We mix everything together.

---

## Tips and Tricks We Haven't Adopted

1. **"Team" keyword for fan-out** — We may not consistently use this trigger word.
2. **"Keep working" / "Work until done"** — Activates Ralph's continuous loop.
3. **Stack decisions in your prompt** — Front-load conventions in the first prompt to reduce agent questions.
4. **Decision-first development** — "Don't code yet. Write decisions." before implementation.
5. **Spike → Decision → Build** — For hard problems, spike first, then decide, then build.
6. **Check `/status` before big asks** — Prevent overloading already-working agents.
7. **Reference decisions, not details** — "See the auth decision in decisions.md" instead of re-explaining.

---

## Common Mistakes from Docs We Might Be Making

| Mistake | Fix | Our Risk Level |
|---------|-----|----------------|
| Vague prompts → agents ask questions | Be specific about scope upfront | 💡 Medium |
| Interrupting parallel work | Let it finish, then review | 💡 Medium |
| Not using Ralph on full backlog | `Ralph, go` — let the bot grind | 🔥 High |
| Too many agents | Start with 4-5, add specialists later | 💡 Medium (we have 15) |
| Lost team knowledge | Commit `.squad/` to git | ✅ We do this |
| Contradicting old decisions | Ask Scribe to remind you of rules | 💡 Medium |
| 85KB decisions.md | Archive old decisions | 🔥 Critical |

---

## Personal Squad Patterns

The docs describe a "Personal Squad" concept (`squad init --global` → `~/.squad/`) that creates a cross-project team identity. **Not relevant for us yet** — we operate in a single repo. This becomes valuable when:

- We start the second game project (export skills → import to new repo)
- Joaquín wants consistent agent behavior across repos
- We want studio-level conventions separate from game-specific decisions

Our `identity/` directory already captures studio-level wisdom — it's a natural precursor to a personal squad setup.

---

## What We're Missing

### 🔴 Critical Gaps (Fix This Session)

1. **Decision Archiving** — 85KB `decisions.md` is burning context budget on every agent spawn. Run `squad nap --deep` or manually create `decisions-archive.md` and move old entries. This is the single highest-ROI fix available.

2. **History Summarization** — Agent histories over 12KB need progressive summarization. Multiple agents are over this threshold.

### 🟡 High-Value Gaps (Fix This Sprint)

3. **@copilot Auto-Assign** — It's on the roster but disabled. Create PAT, set secret, enable auto-assign. Unlocks autonomous issue processing for well-defined tasks.

4. **Governance Hooks** — No file-write guards, no PII scrubbing. Adding `defineHooks` to `squad.config.ts` prevents agents from writing outside their domain.

5. **squad.config.ts Cleanup** — Routing rules all point to `@scribe` (placeholder). Casting allowlist doesn't match actual universe (Star Wars). Fix or remove to avoid confusion.

6. **Custom Ceremonies** — Only have Design Review and Retrospective. Consider adding Sprint Planning (Mace facilitates) and Art Review (Boba facilitates).

### 🟢 Nice-to-Have Gaps (Future Sprints)

7. **Plugin Marketplace** — Browse for game-dev relevant plugins. May not exist yet, but worth checking.

8. **Personal Squad** — For when we start the next game project. Export current team, init global, connect both projects.

9. **Upstream Inheritance** — Share studio conventions across game projects. Natural extension of our identity layer.

10. **Skill Confidence Levels** — Audit all 31 skills and add confidence metadata.

11. **Dedicated directives.md** — Separate permanent rules from the decision log.

12. **Human Team Member** — Add Joaquín as formal approval gate for architecture/scope decisions.

### ⬜ Not Needed

- Remote Control (squad start --tunnel) — No mobile workflow
- OpenTelemetry/Aspire — Overkill for our scale
- Consult Mode — We don't contribute to external projects with Squad
- Git Worktrees — Not our workflow

---

## Priority Action Items

| # | Action | Owner | Effort | Impact |
|---|--------|-------|--------|--------|
| 1 | Run `squad nap --deep` (or manually archive decisions) | Jango | Small | 🔥 Critical — context budget |
| 2 | Enable @copilot auto-assign (PAT + secret) | Jango | Small | 🔥 High — autonomous work |
| 3 | Fix `squad.config.ts` (routing, casting mismatch) | Jango | Small | 💡 Medium — config hygiene |
| 4 | Add governance hooks to config | Jango | Small | 🔥 High — safety guardrails |
| 5 | Run `squad doctor` to validate setup | Jango | Trivial | 💡 Medium — diagnostic baseline |
| 6 | Summarize oversized agent histories | Scribe | Small | 💡 Medium — context budget |
| 7 | Add custom ceremonies (Sprint Planning, Art Review) | Jango | Small | 💡 Medium — process quality |
| 8 | Add Joaquín as human team member | Jango | Trivial | 💡 Medium — approval gates |

---

*This audit covers every documented feature as of 2026-07-23 across 25+ docs pages. Squad is alpha software — features may change. Re-audit recommended after major Squad version updates.*

# Squad Ecosystem Audit — Comprehensive Feature Investigation

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-23  
**Status:** PROPOSED  
**Scope:** Squad CLI v0.8.25, all features vs. current adoption

---

## Executive Summary

We're running Squad v0.8.25 with a mature 16-member team (14 AI agents + Ralph + @copilot), 31 skills, 5 ceremonies, and 17 GitHub Actions workflows. After a thorough investigation of the CLI, docs site, and upstream Squad repo, I found **6 high-value features we should adopt now**, **4 worth adopting later**, and **3 to skip**. Our biggest gaps are: no `squad nap` hygiene (our history files are 69KB+), no SubSquads for parallel workstreams, and unused plugin marketplace.

---

## TOP 5 RECOMMENDATIONS — ADOPT NOW

| # | Feature | Why | Effort |
|---|---------|-----|--------|
| 1 | **`squad nap --deep`** | Our `.squad/` state is bloated (Solo history alone is 69KB). Context hygiene prevents agent confusion and token waste. | Trivial — one command |
| 2 | **SubSquads (Workstreams)** | Split Art Sprint vs. Gameplay vs. Audio into isolated Codespace lanes. Prevents merge conflicts and rate-limit bottleneck. | Small — create `streams.json` |
| 3 | **Add Joaquín as Human Team Member** | Formal approval gates for architecture decisions and ship/no-ship calls. Agents stop-and-wait instead of guessing. | Trivial — one prompt |
| 4 | **Enable `squad-heartbeat.yml` cron** | Ralph runs every 30 min unattended. Untriaged issues get auto-processed even when we're AFK. | Trivial — uncomment cron line |
| 5 | **`squad build --check` in CI** | Catch config drift between `squad.config.ts` and `.squad/` markdown. Prevents silent divergence. | Small — add workflow step |

---

## Full Feature Audit

### 1. Squad CLI Commands

| Command | What It Does | Status | Value | Effort | Recommendation |
|---------|-------------|--------|-------|--------|----------------|
| `squad init` | Initialize Squad | ✅ Active (done long ago) | — | — | Already done |
| `squad upgrade` | Update Squad-owned files | ✅ Active | High | Trivial | Keep running on new releases |
| `squad status` | Show active squad info | ✅ Active | Low | Trivial | Already available |
| `squad triage` | Scan and categorize issues | 🟡 Configured (via workflow) | High | Trivial | Use `squad triage --interval 10` for local persistent triage |
| `squad loop` | Ralph continuous work loop | 🟡 Configured (in-session only) | High | Small | Enable for sprint execution sessions |
| `squad hire` | Team creation wizard | ✅ Active | Medium | Trivial | Already used for team building |
| `squad copilot` | Add/remove @copilot agent | ✅ Active | Medium | Trivial | Already configured |
| `squad plugin` | Manage plugin marketplaces | ❌ Not set up | Medium | Small | Adopt later — see Plugin section |
| `squad export` | Export squad to JSON snapshot | ❌ Not used | Medium | Trivial | Use before major migrations |
| `squad import` | Import from export file | ❌ Not used | Medium | Trivial | Paired with export |
| `squad start` | Copilot with remote access | ❌ Not set up | Low | Medium | Adopt later — see RC section |
| `squad nap` | Context hygiene/compression | ❌ Not used | **High** | Trivial | **ADOPT NOW** |
| `squad doctor` | Health checks | ✅ Active (8/8 passing) | Medium | Trivial | Run periodically |
| `squad consult` | Personal squad on foreign repos | ❌ N/A for us | Low | — | Skip — we own our repos |
| `squad extract` | Extract learnings from consult | ❌ N/A | Low | — | Skip — paired with consult |
| `squad subsquads` | Multi-Codespace scaling | ❌ Not set up | **High** | Small | **ADOPT NOW** |
| `squad link` | Link to remote team root | ❌ Not set up | Medium | Small | Adopt later — useful for multi-repo |
| `squad build` | Compile squad.config.ts | 🟡 Have config, never built | **High** | Small | **ADOPT NOW** |
| `squad aspire` | .NET Aspire dashboard | ❌ Not set up | Low | Medium | Skip — not .NET project |
| `squad rc` | Remote Control bridge | ❌ Not set up | Low | Medium | Adopt later — nice for demos |
| `squad upstream` | Manage upstream Squad sources | ❌ Not set up | Medium | Small | Adopt later — multi-repo synergy |
| `squad migrate` | Convert between formats | ❌ Not needed | Low | — | Skip — already on SDK mode |
| `squad scrub-emails` | Remove PII | ✅ Available | Low | Trivial | Run if needed |

---

### 2. Plugin Marketplace

**Status:** ❌ Not set up  
**Value:** Medium  
**Effort:** Small

**What it is:** Community-curated bundles of agent templates, skills, and conventions from GitHub repos. Four marketplaces exist:

| Marketplace | URL | Relevance to Us |
|-------------|-----|-----------------|
| awesome-copilot | `github/awesome-copilot` | 🟡 Low — frontend/backend web focus, not game dev |
| anthropic-skills | `anthropics/skills` | 🟢 Medium — Claude optimization patterns could help |
| azure-cloud-dev | `github/azure-cloud-development` | 🔴 None — we don't use Azure |
| security-hardening | `github/security-hardening` | 🟡 Low — game doesn't handle sensitive data |

**Game dev gap:** No game development marketplace exists yet. None of the existing marketplaces have Godot, GDScript, game design, or fighting game plugins.

**Recommendation:** Adopt later. Consider **creating our own marketplace** repo (`FirstFrameStudios/squad-gamedev-plugins`) packaging our 31 skills as reusable plugins. This would be the first game-dev Squad marketplace.

**How to adopt:**
1. `squad plugin marketplace add anthropics/skills` — get Claude optimization patterns
2. Long-term: Package our skills into a public marketplace for the Squad community

---

### 3. SubSquads (Workstreams)

**Status:** ❌ Not set up  
**Value:** **HIGH**  
**Effort:** Small

**What it is:** Partitions work into labeled SubSquads so multiple Codespaces can work in parallel on different parts of the project. Each SubSquad targets a GitHub label and optionally restricts to certain directories.

**Why we need it:** Our 14-agent team has natural workstream boundaries:
- **Art Sprint** (`team:art`) — Boba, Leia, Bossk, Nien → `games/ashfall/assets/`, `tools/blender/`
- **Gameplay** (`team:gameplay`) — Lando, Tarkin, Chewie → `games/ashfall/scripts/`, `games/ashfall/scenes/`
- **Audio** (`team:audio`) — Greedo → `games/ashfall/audio/`
- **QA** (`team:qa`) — Ackbar, Jango → `games/ashfall/test/`

**Recommendation:** **ADOPT NOW**

**How to adopt:**
1. Create `.squad/streams.json`:
```json
{
  "streams": [
    {
      "name": "art-sprint",
      "labelFilter": "team:art",
      "folderScope": ["games/ashfall/assets/", "tools/"],
      "workflow": "branch-per-issue"
    },
    {
      "name": "gameplay",
      "labelFilter": "team:gameplay",
      "folderScope": ["games/ashfall/scripts/", "games/ashfall/scenes/"],
      "workflow": "branch-per-issue"
    },
    {
      "name": "audio",
      "labelFilter": "team:audio",
      "folderScope": ["games/ashfall/audio/"],
      "workflow": "branch-per-issue"
    }
  ]
}
```
2. Create GitHub labels: `team:art`, `team:gameplay`, `team:audio`
3. In each Codespace, activate: `squad subsquads activate art-sprint`

---

### 4. Human Team Members

**Status:** ❌ Not set up  
**Value:** **HIGH**  
**Effort:** Trivial

**What it is:** Adds real people to the Squad roster with 👤 Human badge. When work routes to a human, Squad pauses and waits for their input. Humans can't be spawned as sub-agents but can serve as reviewers and approval gates.

**Why we need it:** Joaquín is the founder but has no formal roster entry. Adding him creates explicit approval gates for:
- Architecture decisions (currently ad-hoc)
- Ship/no-ship calls at milestones
- Art direction sign-off
- Design review participation in ceremonies

**Recommendation:** **ADOPT NOW**

**How to adopt:**
1. In a Squad session: `"Add Joaquín (joperezd) as Founder and Creative Director"`
2. He appears on roster with 👤 badge
3. Update ceremonies to add Joaquín as participant in Design Review and Integration Gate
4. Routing: architecture decisions and milestone sign-offs route to Joaquín

---

### 5. SDK-First Mode & `squad build`

**Status:** 🟡 Have `squad.config.ts`, never run `squad build`  
**Value:** **HIGH**  
**Effort:** Small

**What it is:** `squad.config.ts` is the single source of truth. `squad build` compiles it into `.squad/` markdown. `squad build --check` validates sync in CI.

**Current gap:** We have a `squad.config.ts` that defines models, routing, and casting — but our `.squad/` markdown files were created independently. The config and the markdown may have **silently diverged**. Our config is also incomplete — it doesn't define agents, ceremonies, hooks, or skills.

**Recommendation:** **ADOPT NOW** (partial — build validation, not full migration)

**How to adopt:**
1. Run `squad build --dry-run` to see what would be generated vs. what exists
2. Expand `squad.config.ts` to include all agents, ceremonies, hooks
3. Add `squad build --check` to CI workflow (add step to `squad-ci.yml`)
4. Optionally: `squad build --watch` for live rebuilds during development
5. Add `defineHooks()` for governance: allowed write paths, blocked commands, PII scrubbing

---

### 6. `squad watch` / Ralph Persistent Polling

**Status:** 🟡 Ralph exists on roster, no persistent polling  
**Value:** High  
**Effort:** Trivial

**What it is:** `squad watch --interval 10` runs Ralph as a local watchdog, checking GitHub every N minutes for untriaged issues, stale PRs, CI failures. Three layers: in-session (`Ralph, go`), local watchdog (`squad watch`), cloud heartbeat (GitHub Actions cron).

**Current gap:** We use Ralph in-session only. The heartbeat workflow exists but cron is commented out. No local watchdog.

**Recommendation:** Adopt now — enable heartbeat cron, use `squad watch` during sprint sessions.

**How to adopt:**
1. Edit `.github/workflows/squad-heartbeat.yml` — uncomment the cron schedule (e.g., `'*/30 * * * *'`)
2. During sprints, run `squad watch --interval 10` in a background terminal
3. Ensure `gh` CLI is authenticated with Classic PAT (scopes: `repo`, `project`)

---

### 7. `squad doctor` Deep Checks

**Status:** ✅ Active (8/8 passing)  
**Value:** Medium  
**Effort:** Trivial

**What it is:** Validates squad setup — checks files, config, health. Already passing all 8 checks.

**Recommendation:** Keep running periodically, especially after `squad upgrade`.

---

### 8. Ceremonies

**Status:** ✅ 5 configured (Design Review, Retrospective, Integration Gate, Spec Validation, Godot Smoke Test)  
**Value:** Medium  
**Effort:** Small

**What the docs offer:** The docs show ceremonies are flexible — any trigger, any schedule, custom agendas. Built-in types are Design Review and Retrospective, but you can create any custom ceremony.

**Ceremonies we could add:**

| Ceremony | Trigger | Value |
|----------|---------|-------|
| **Sprint Planning** | Manual, start of sprint | High — Mace + Yoda + Solo plan the sprint |
| **Daily Standup** | Schedule (cron `0 9 * * 1-5`) | Medium — agents report blockers |
| **Art Review** | After art PRs merged | Medium — Boba reviews visual consistency |
| **Security Review** | Before release builds | Low — less critical for single-player game |

**Recommendation:** Add Sprint Planning ceremony now; Daily Standup adopt later (requires `squad loop` active).

**How to adopt:** Add to `.squad/ceremonies.md`:
```markdown
## Sprint Planning

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | before |
| **Condition** | start of new sprint |
| **Facilitator** | Mace (Producer) |
| **Participants** | Mace + Yoda + Solo + Joaquín |
| **Time budget** | focused |
| **Enabled** | ✅ yes |
```

---

### 9. GitHub Actions Workflows

**Status:** 17 workflows installed — 12 active, 5 template stubs  
**Value:** High  
**Effort:** Varies

| Workflow | Status | Action Needed |
|----------|--------|---------------|
| **squad-heartbeat.yml** | 🟡 Active but cron disabled | **Uncomment cron** — enables unattended triage |
| **squad-triage.yml** | ✅ Active | Working — routes `squad`-labeled issues |
| **squad-issue-assign.yml** | ✅ Active | Working — acknowledges `squad:*` labels |
| **sync-squad-labels.yml** | ✅ Active | Working — syncs labels from roster |
| **squad-label-enforce.yml** | ✅ Active | Working — enforces mutual exclusivity |
| **pr-body-check.yml** | ✅ Active | Working — warns if no `Closes #N` |
| **branch-validation.yml** | ✅ Active | Working — PRs must target main |
| **squad-main-guard.yml** | ✅ Active | Working — blocks `.squad/` on protected branches |
| **squad-promote.yml** | ✅ Active | Working — dev→preview→main promotion |
| **integration-gate.yml** | ✅ Active | Working — GDScript linting on PRs to main |
| **godot-project-guard.yml** | ✅ Active | Working — warns on project.godot changes |
| **godot-release.yml** | ✅ Active | Working — exports Godot builds on tags |
| **squad-ci.yml** | ⚠️ Template stub | Needs build/test commands configured |
| **squad-docs.yml** | ⚠️ Template stub | Needs docs build configured |
| **squad-release.yml** | ⚠️ Template stub | Needs release process configured |
| **squad-insider-release.yml** | ⚠️ Template stub | Needs insider build configured |
| **squad-preview.yml** | ⚠️ Template stub | Needs preview validation configured |

**Recommendation:** Enable heartbeat cron now. The 5 template stubs need Godot-specific build commands — configure `squad-ci.yml` to run GDScript linting and Godot export checks on PRs.

---

### 10. Remote Squad Mode (`squad link`)

**Status:** ❌ Not set up  
**Value:** Medium (for future multi-repo)  
**Effort:** Small

**What it is:** Links project to a remote team root — shared team identity (casting, charters, decisions) across multiple repos while keeping project-specific state local.

**Relevance:** Useful when we have multiple game repos sharing the same studio team. Currently single-repo.

**Recommendation:** Adopt later — when we start a second game project, `squad link` lets the new repo inherit our team without duplicating configuration.

---

### 11. Skills System

**Status:** ✅ 31 skills active  
**Value:** High (already delivering value)  
**Effort:** N/A

**Current skills (31):** 2d-game-art, animation-for-games, beat-em-up-combat, canvas-2d-optimization, code-review-checklist, enemy-encounter-design, feature-triage, fighting-game-design, game-audio-design, game-design-fundamentals, game-feel-juice, game-qa-testing, gdscript-godot46, github-pr-workflow, godot-4-manual, godot-beat-em-up-patterns, godot-project-integration, godot-tooling, input-handling, integration-discipline, level-design-fundamentals, milestone-completion-checklist, multi-agent-coordination, parallel-agent-workflow, procedural-audio, project-conventions, squad-conventions, state-machine-patterns, studio-craft, ui-ux-patterns, web-game-engine

**Best practices from docs:**
- **Confidence lifecycle:** Low → Medium → High. Confidence only goes up.
- **Earned vs. Starter:** Starter skills (`squad-*`) get overwritten on upgrade. Earned skills are protected.
- **Team-wide:** All agents read all skills. Not per-agent.
- **Portable:** Skills survive export/import.

**Recommendation:** Audit confidence levels — ensure battle-tested skills are at High. Consider consolidating overlapping skills (e.g., `beat-em-up-combat` + `fighting-game-design`).

---

### 12. Adding Joaquín as Human Member

See **Item 4** above — full details in the Human Team Members section.

---

### 13. `squad rc` (Remote Control)

**Status:** ❌ Not set up  
**Value:** Low (for now)  
**Effort:** Medium

**What it is:** Spawns Copilot CLI in a PTY, mirrors terminal via WebSocket + devtunnel. Phone scans QR code → full terminal on mobile. 7-layer security (devtunnel auth, session tokens, ticket-based WS auth, rate limiting, secret redaction, connection limits, audit logging).

**Cool factor:** High. **Practical value for us:** Low. We work from desktop. Could be useful for demos or monitoring long runs from phone.

**Recommendation:** Skip for now. Adopt when doing live demos or conference talks.

**Prerequisites if adopted:** `winget install Microsoft.devtunnel` → `devtunnel user login` → `squad start --tunnel`

---

### 14. Upstream Inheritance (`squad upstream`)

**Status:** ❌ Not set up  
**Value:** Medium (future)  
**Effort:** Small

**What it is:** Declares external Squad sources to inherit skills, decisions, casting policy, and routing. Supports local paths, git repos, and export snapshots. "Closest-wins" — later entries override.

**Relevance:** If we publish our game-dev skills as a marketplace/upstream repo, other game studios could inherit our expertise. We could also inherit from a community game-dev Squad if one emerges.

**Recommendation:** Adopt later — after creating our marketplace repo.

---

### 15. Context Hygiene (`squad nap`)

**Status:** ❌ Never run  
**Value:** **HIGH**  
**Effort:** Trivial

**What it is:** Compresses, prunes, and archives `.squad/` state. `--deep` does thorough cleanup. `--dry-run` previews.

**Why critical:** Solo's history.md alone is 69KB. decisions.md is 85KB. These bloated files consume agent context tokens and slow down every session. `squad nap --deep` will compress old sessions, prune archived decisions, and keep only active state.

**Recommendation:** **ADOPT NOW — run immediately.**

**How to adopt:**
1. `squad nap --dry-run` — preview what gets cleaned
2. `squad nap --deep` — full cleanup
3. Commit the cleaned state
4. Run monthly or after major milestones

---

### 16. Export/Import

**Status:** ❌ Not used  
**Value:** Medium  
**Effort:** Trivial

**What it is:** `squad export` creates a portable JSON snapshot of the entire team. `squad import` restores it.

**Recommendation:** Run `squad export` before any major upgrade or restructuring. Keep as backup/portability insurance.

---

### 17. Consult Mode

**Status:** ❌ N/A  
**Value:** Low for us  
**Effort:** N/A

**What it is:** Brings personal squad to repos you don't own (OSS, client work) without leaving traces.

**Recommendation:** Skip — we own our repos. Possibly useful if Joaquín contributes to OSS Godot projects.

---

### 18. .NET Aspire Dashboard

**Status:** ❌ Not set up  
**Value:** Low  
**Effort:** Medium

**What it is:** OpenTelemetry observability dashboard. Designed for .NET projects.

**Recommendation:** Skip — we're a Godot/GDScript project, not .NET.

---

## Summary Matrix

| Feature | Status | Value | Effort | Action |
|---------|--------|-------|--------|--------|
| `squad nap --deep` | ❌ | HIGH | Trivial | **ADOPT NOW** |
| SubSquads | ❌ | HIGH | Small | **ADOPT NOW** |
| Human Members (Joaquín) | ❌ | HIGH | Trivial | **ADOPT NOW** |
| Heartbeat cron | 🟡 | HIGH | Trivial | **ADOPT NOW** |
| `squad build --check` CI | 🟡 | HIGH | Small | **ADOPT NOW** |
| Sprint Planning ceremony | ❌ | HIGH | Small | **ADOPT NOW** |
| Ralph `squad watch` | 🟡 | High | Trivial | Adopt soon |
| Plugin marketplace | ❌ | Medium | Small | Adopt later |
| `squad link` | ❌ | Medium | Small | Adopt later (multi-repo) |
| `squad upstream` | ❌ | Medium | Small | Adopt later |
| Export/import | ❌ | Medium | Trivial | Adopt later |
| Skill confidence audit | ✅ | Medium | Small | Adopt later |
| `squad rc` | ❌ | Low | Medium | Skip |
| Aspire dashboard | ❌ | Low | Medium | Skip |
| Consult mode | ❌ | Low | — | Skip |

---

## Implementation Order

**Phase 1 — This sprint (immediate):**
1. Run `squad nap --deep` to clean bloated state
2. Add Joaquín as human team member
3. Uncomment heartbeat cron in `squad-heartbeat.yml`
4. Add Sprint Planning ceremony to `ceremonies.md`
5. Run `squad build --dry-run` to assess config drift

**Phase 2 — Next sprint:**
6. Create `.squad/streams.json` for SubSquads
7. Set up `squad build --check` in CI
8. Run `squad export` as backup
9. Configure `squad-ci.yml` with GDScript lint commands

**Phase 3 — Future:**
10. Create `FirstFrameStudios/squad-gamedev-plugins` marketplace
11. Set up `squad link` when second game starts
12. Explore `squad upstream` for cross-studio knowledge sharing

---

*Solo — Lead / Chief Architect, First Frame Studios*

# Decision: Sprite Test Viewer Updated for Cel-Shade Sprites

**Author:** Wedge (UI Dev)
**Date:** 2025-01-XX
**File:** `games/ashfall/scripts/test/sprite_poc_test.gd`

## What changed

Updated the test viewer to load cel-shade rendered sprites from the new directory structure (`res://assets/sprites/kael/` and `res://assets/sprites/rhena/`) instead of the outdated `res://assets/poc/v2/` path.

## Key decisions

1. **Auto-detect frame count** — Instead of hardcoding frame counts per animation, the viewer now loads frames sequentially (0000, 0001, ...) until a file is missing. This means new renders with different frame counts just work without code changes.

2. **Frame rate: 12fps loops, 15fps attacks** — Idle/walk use 12fps for a smooth but readable loop. Punch/kick use 15fps for snappier attack feel. These are standard fighting game rates.

3. **Replaced "lp" animation with punch/kick** — Old viewer had 3 anims (idle, walk, lp). New viewer has 4 (idle, walk, punch, kick) mapped to keys 1-4. K/R keys are now character-only (no longer doubled on 4/5).

4. **Background path changed to v1** — The `embergrounds_bg.png` only exists in `assets/poc/v1/`, not v2. Pointed the viewer there. This is still a placeholder BG — will need a proper stage asset eventually.

5. **Contact sheets ignored** — Each animation dir contains a `_sheet.png` contact sheet. The auto-detect loop naturally skips these since they don't match the `_NNNN.png` naming pattern.


---

# === ARCHIVED FROM decisions.md (2026-03-12) ===

# Squad Decisions

## Active Decisions

### 2026-03-11: ComeRosquillas Modularization Architecture (Chewie)
**Date:** 2026-03-11  
**Author:** Chewie (Engine Developer)  
**Issue:** #1 — Modularize game.js monolith  
**Status:** ✅ Implemented (PR #10)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas shipped with a 1789-line game.js monolith containing all code: constants, audio, rendering, game logic, and initialization. This blocked parallel development and made code navigation difficult.

**Decision:**
Split game.js into 5 focused modules organized by responsibility with clean dependency flow.

**Module Structure:**
- **config.js** (114 lines): Constants, maze data (31×28), ghost configs, Simpsons colors, game states, direction vectors
- **engine/audio.js** (166 lines): SoundManager class — Simpsons theme, D'oh sound, Duff jingle, background music
- **engine/renderer.js** (720 lines): Sprites static class — Homer rendering, 4 ghost characters (Burns, Bob, Nelson, Snake), donut/Duff, maze
- **game-logic.js** (791 lines): Game class — game loop, state machine (7 states), player movement, ghost AI (scatter/chase/frightened), scoring, level progression
- **main.js** (13 lines): Entry point — thin instantiation of Game

**Load Order (Dependency DAG):**
```
config.js (no deps)
  ↓
audio.js (uses config)
  ↓
renderer.js (uses config)
  ↓
game-logic.js (uses all)
  ↓
main.js (instantiates Game)
```

**Rationale:**
1. **Config as Foundation** — Pure data, zero dependencies enables safe parallel work on rendering and game logic
2. **Engine Separation** — Audio and renderer are orthogonal concerns, separate files enable parallel development
3. **Static Renderer** — Sprites class uses static methods (no instance state), simplifies testing, eliminates object allocation
4. **No Bundler** — Vanilla JS project with simple DAG, `<script>` tags provide explicit load order, low development friction

**Alternatives Rejected:**
1. **ES Modules** — Would require export/import syntax changes. Global namespace approach simpler for vanilla JS.
2. **Split Renderer by Entity** (player.js, ghosts.js, maze.js) — Drawing code tightly coupled to config constants. 720-line cohesion preferable to fragmentation.
3. **Webpack/Vite Bundle** — Adds build step complexity. Browser handles 5 files efficiently.

**Consequences:**
- ✅ Clear module responsibilities, parallel development enabled, static methods easily testable
- ✅ Maintainability improved: code navigation easier, onboarding clearer
- ❌ Global namespace risk if naming conflicts arise (mitigated by discipline)
- ❌ Load order dependency — index.html must maintain correct script order (easy to break)

**Testing:**
- ✅ Game loads and plays after modularization
- ✅ All sounds, rendering, gameplay, scoring, level progression work identically
- ✅ Zero breaking changes

**Future Work:**
- Consider ES modules when browser support matures
- Extract maze data to JSON if editing becomes frequent
- Add JSDoc for IDE autocomplete
- Split game-logic.js if it grows beyond 1000 lines

---

### 2026-03-11: ComeRosquillas CI Pipeline Strategy (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Issue:** #6 — Add CI pipeline with validation and deploy checks  
**Status:** ✅ Implemented (PR #9)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas is a vanilla HTML/JS/Canvas game (no build step). Need lightweight CI that validates code quality and enables live PR preview without adding bundler complexity.

**Decision:**
Implemented GitHub Actions workflow (`ci.yml`) with JavaScript syntax validation, HTML structure checks, and automated PR preview comments.

**Workflow Details:**
- **Triggers:** All PRs and main pushes
- **Execution Time:** ~30 seconds
- **Validations:**
  - HTML structure (canvas element, script references)
  - JavaScript syntax (`node --check` on all .js files)
  - Game assets structure
  - Code quality (no debugger statements, TODO awareness)
- **Output:** Automated PR comment with validation results and deployment URLs

**Rationale:**
1. **Keep It Simple** — No build step for vanilla game. Bundlers (webpack, parcel) would slow development.
2. **Fast Feedback** — 30-second runs provide immediate validation on every commit.
3. **PR Experience** — Comments with validation + deploy links in one place improve developer workflow.
4. **Separation of Concerns** — CI validation (this) ≠ Deployment (existing deploy-pages.yml) ≠ Squad framework (squad-ci.yml)
5. **Node.js Native** — `node --check` for JS validation. Can extend with ESLint/Prettier later if needed.

**Alternatives Rejected:**
1. **Add ESLint/Prettier** — Too much config overhead for v1.0. Can add later if style becomes an issue.
2. **HTML Validator Service** — External dependency + network calls. Simple grep sufficient for now.
3. **Playwright/Puppeteer E2E Tests** — No test files exist yet. CI focuses on syntax first. E2E can be added in future sprints.
4. **Combine with squad-ci.yml** — Squad-ci.yml is squad-framework specific. Kept separate for clarity.

**Consequences:**
- ✅ Fast CI runs, zero dependencies beyond Node.js, clear validation messages, improves developer experience
- ✅ Does not interfere with existing Astro docs deployment
- ❌ No code style enforcement yet (no linter), no E2E tests, manual grep checks
- ✓ Can extend with ESLint, Prettier, Playwright later without major rearchitecture

**Follow-up:**
- Add ESLint + Prettier if code style issues arise
- Add Playwright E2E tests when game stabilizes
- Add Lighthouse CI for performance checks
- Monitor CI run times — optimize if they exceed 2 minutes

---

### 2026-03-11: ComeRosquillas Issue Triage & Squad Routing (Solo)
**Date:** 2026-03-11  
**Author:** Solo (Lead/Architect)  
**Scope:** Assign squad routing labels to all 8 open issues  
**Status:** ✅ Complete  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas shipped with 8 open GitHub issues. None had squad routing labels, blocking Ralph's auto-assignment workflow.

**Decision:**
Triaged all 8 issues with squad routing + priority labels, creating 14 labels in repo and applying them to each issue with rationale comments.

**Triage Results:**

| Issue | Title | Assigned To | Priority | Rationale |
|---|---|---|---|---|
| #1 | Modularize game.js | solo + chewie | P0 | Blocks everything downstream (cascades to #3, #4, #5, #7, #8) |
| #2 | Mobile/touch controls | wedge | P2 | Platform expansion, non-blocking for v1.0, post-launch polish |
| #3 | High score persistence | wedge + lando | P2 | Engagement feature, not critical for core loop, post-launch |
| #4 | Multiple maze layouts | tarkin + lando | P1 | Critical for replayability, v1.0 essential, start after #1 |
| #5 | Simpsons intermission cutscenes | wedge | P3 | Pure charm/narrative, deferred until core stable |
| #6 | CI pipeline | jango | P1 | Unblocks velocity, tooling investment, parallel stream |
| #7 | Ghost AI improvement | tarkin | P1 | Gameplay core (difficulty + personality), v1.0 essential |
| #8 | Sound effects variety | greedo | P1 | Sound IS gameplay feel, v1.0 essential |

**Routing Philosophy:**
- **P0 (Critical):** Unblocks everything downstream (only #1)
- **P1 (Ship-Blocking):** Must complete before v1.0 release (#4, #6, #7, #8). Can run in parallel.
- **P2 (Medium):** Valuable engagement features, ship after v1.0 stable (#2, #3)
- **P3 (Polish):** Pure charm/narrative, deferred (#5)

**Key Insight — Monolithic Anti-Pattern Repeats:**
- firstPunch: gameplay.js = 695 LOC → architecture refactor was P0
- ComeRosquillas: game.js = 1636 LOC → architecture refactor is P0

**Implication:** Studio should establish **architectural debt prevention pattern**:
- Max 300-400 LOC per module before auto-triggering refactor review
- Modular architecture designed upfront, not retrofitted
- Code organization as critical as feature completion

---

### 2026-03-11: Create ffs-squad-monitor Repository (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Requested by:** Joaquín  
**Status:** ✅ Implemented

**Context:**
Joaquín wants a real-time monitoring dashboard for the FFS squad, inspired by [Tamir Dresher's squad-monitor](https://github.com/tamirdresher/squad-monitor). We already have `ralph-watch.ps1` writing heartbeat data and structured logs — we need a visual frontend.

**Decision:**
Created a new public repo `jperezdelreal/ffs-squad-monitor` with:
- Vite + vanilla JS stack (lightweight, learning-friendly)
- Sprint 0 scaffolding: dashboard HTML, heartbeat polling script, mock data
- 5 roadmap issues covering heartbeat reader, log viewer, timeline, UI, and Actions integration
- Squad initialized with upstream link to FirstFrameStudios

**Rationale:**
- **Separate repo** keeps monitoring concerns out of the main FFS codebase
- **Vite + vanilla JS** is minimal, fast to iterate, and good for learning
- **Read-only observer pattern** — monitor reads heartbeat/logs but never writes to FFS
- **Sprint 0 = scaffolding only** — real implementation tracked via GitHub Issues

**Links:**
- Repo: https://github.com/jperezdelreal/ffs-squad-monitor
- Issues: https://github.com/jperezdelreal/ffs-squad-monitor/issues
- Inspiration: https://github.com/tamirdresher/squad-monitor

---

### 2026-03-11: Squad Upstream Setup — ComeRosquillas → FirstFrameStudios (Jango)
**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Status:** IMPLEMENTED  
**Scope:** Infrastructure / Squad Architecture

**Context:**
ComeRosquillas (Homer's Donut Quest) was absorbed into First Frame Studios at `games/comerosquillas/`. The standalone ComeRosquillas repo (jperezdelreal/ComeRosquillas) needs to inherit studio identity, skills, and process from the FFS hub.

The approved architecture is **Option C Hybrid**:
- **FirstFrameStudios** = Studio hub (parent squad with identity, skills, principles)
- **Game repos** = Subsquads inheriting via upstream connection

**Decision:**
Set up a manual upstream connection since `squad-cli v0.8.20` does not yet have native `upstream` commands.

**What Was Done:**
1. **Squad initialized** in ComeRosquillas via `squad-cli init --no-workflows`
2. **Upstream directory created** at `.squad/upstream/` with:
   - `manifest.json` — connection metadata, sync policy, inherited content list
   - `identity/` — copied identity files from FFS (principles, mission-vision, company, quality-gates, wisdom)
   - `skills/INDEX.md` — reference index of 41 FFS skills (categorized by applicability)
3. **Config updated** — `.squad/config.json` includes upstream hub reference
4. **upstream.json enriched** — added repo, relationship, last_synced, synced_content fields
5. **Committed and pushed** to `main`

**Sync Policy:**

| Content Type | Strategy | Notes |
|---|---|---|
| Identity files | Copy from hub | Upstream wins — these are studio-level |
| Skills | Reference index only | Full content stays in hub repo |
| Decisions | Reference only | Game-specific decisions stay local |
| Project config | Local only | Game-specific settings |

**How to Re-sync:**
When FFS identity or skills change, manually copy updated files:
```powershell
cd "C:\Users\joperezd\GitHub Repos\ComeRosquillas"
Copy-Item "C:\Users\joperezd\GitHub Repos\FirstFrameStudios\.squad\identity\{file}" ".squad\upstream\identity\{file}"
# Update last_synced in .squad/upstream.json
```

**Alternatives Considered:**
1. **Native `squad upstream` commands** — Not available in v0.8.20. When squad-cli adds this feature, migrate to native commands.
2. **Git submodules** — Too heavy for configuration inheritance. Submodules are for code, not squad metadata.
3. **Symlinks** — Don't work across repos on GitHub. Only viable for local development.

**Migration Path:**
When `squad-cli` ships `upstream add/sync/list`:
1. Run `squad upstream add` pointing to FFS
2. Run `squad upstream sync` to replace manual copies
3. Remove manual `.squad/upstream/` directory if native upstream uses a different structure
4. Update this decision document

**Risks:**
- **Manual sync drift** — If FFS identity changes and nobody syncs downstream, ComeRosquillas will have stale studio guidance. Mitigated by: checking sync date during ceremonies.
- **squad-cli breaking changes** — If a future version introduces native upstream with a different structure, migration will be needed.

---

### User Directives (2026-03-08)

#### 2026-03-08T115537Z: Ashfall Game Type Pivot
**By:** joperezd (via Copilot)  

Ashfall pivots from action roguelike to 1v1 fighting game (Tekken/Street Fighter style) in Godot 4. Scope limited to 1 stage + 2 characters initially. Content expansion deferred.

#### 2026-03-08T10:37: Repository Structure
**By:** joperezd (via Copilot)  

First Frame Studios uses a single GitHub repository (monorepo). The .squad/ folder lives at root (studio-level). Each game is a subfolder containing its Godot project. Team has access to GitHub Actions, PRs, Dashboards, and all GitHub features.

**Why:** Centralizes studio knowledge, skills, and team state. Each game is a folder, not separate repo.

#### 2026-03-08T10:25: Tool & Skill Development Autonomy
**By:** joperezd (via Copilot)  

Agents should NOT be limited to existing tools and skills. When performing a task, if an agent detects a gap or needs a specific tool to do better work, they should have the ability to request it and have it developed on the spot.

---

### Game Architecture (McManus)
**Date:** 2026-06-03  
**Status:** Implemented

Complete beat 'em up game with modular ES6 architecture and no external dependencies. Fixed timestep (60 FPS), Canvas 2D renderer with camera system, keyboard state management, Web Audio API sound effects. Entity-component pattern for Player and AI enemies with state machines. Combat uses rectangle collision detection, knockback physics, hitstun. Wave-based progression with camera locks. All graphics procedurally drawn via Canvas API. File structure: index.html + styles.css for entry, src/engine/entities/systems/scenes/ui/ for modules.

**Why:** Simplicity (no frameworks), modularity (clean separation), performance (fixed timestep), and satisfying combat feedback (screen shake, knockback, hitstun).

### Core Gameplay Bug Fixes (Keaton)
**Date:** 2024  
**Status:** Implemented

Five critical bugs fixed:
1. **Input infinite recursion** — Renamed duplicate `isDown()` to `isMovingDown()` to prevent stack overflow
2. **Hit detection unreliability** — Moved `Combat.handlePlayerAttack()` to run every frame with `attackHitList` Set to prevent multi-hits
3. **Damage loop** — Added 500ms invulnerability frames (`invulnTime`) with blink effect for visual feedback
4. **Parallax direction** — Changed background scroll from 1.3x to 0.3x for proper depth perception
5. **Left boundary** — Added player boundary check `Math.max(player.x, cameraX + 10)` to keep player visible

**Why:** Surgical fixes to make game playable. Each addressed a specific bug without rewriting systems. Hit tracking and i-frames follow standard beat 'em up patterns.

### Team Expansion (Solo/Keaton, Lead)
**Date:** 2026-06-03  
**Status:** Implemented

Complete squad expansion from 4 core roles (Solo, Chewie, Lando, Wedge) to 9-member cross-game development team. VFX/Art Specialist (Boba) confirmed. Three new roles added:
- **Greedo (Sound Designer):** Owns Web Audio API expertise, procedural SFX library, music generation system. 7 backlog items (2×P0, 2×P1, 1×P2, 2×P3). Frees Chewie from audio work. Cross-game value: ★★★★★ (sound toolkit compounds across all projects).
- **Tarkin (Enemy/Content Dev):** Owns enemy AI, boss design, wave composition, pickups, difficulty scaling. 14 backlog items (1×P1, 6×P2, 7×P3). Reduces Lando from 26→12 items. Works in parallel on content while Lando builds player systems.
- **Ackbar (QA/Playtester):** Owns testing, balance tuning, feel verification across all items. Develops calibrated instincts for hitbox fairness, combo timing, input responsiveness. Cross-game value: ★★★★☆ (feel tuning expertise compounds).

Revised load distribution eliminates McManus bottleneck, enables parallel workstreams (Engine/Gameplay/Content/Presentation).

**Why:** Gap analysis on 52-item backlog revealed structural overload: Lando carrying 50%, Chewie juggling audio + engine. Three new roles distribute work, enable parallelism, and build compounding cross-game expertise.

### Phaser 3 & Future Tech (2026-03-06T20:05)
**By:** joperezd (via Copilot)  
**Status:** Pending — Future Project Planning

Phaser 3 and other "too late to implement" improvements should be captured as learnings for future projects, not implemented in firstPunch. The squad should conduct deep research across all game development disciplines, document everything, analyze the current game for what's easily implementable vs needs major refactoring, and work autonomously for 4 hours with excellence as the standard.

**Why:** Strategic learning capture for the game dev squad's growth across projects. Protects firstPunch from scope creep while building institutional knowledge for next project.

### Full Codebase Analysis & Learnings (Solo)
**Date:** 2026-03-06  
**Status:** Completed

Read all 28 source files (370KB) and categorized every remaining backlog item into 3 buckets:

**Key Findings:**
1. **13 AAA backlog items already shipped** (grab/throw, dodge roll, back attack, attack buffering, screen zoom, slow-mo kills, scene transitions, destructibles, hazards, boss intros, ambience, hit sound scaling, options menu, hitbox visualization). Active backlog should be ~85 items, not 101.

2. **3 complete infrastructure systems exist but unused**: EventBus (49 LOC), AnimationController (85 LOC), SpriteCache (35 LOC). Also CONFIG (45 LOC). Total: 214 LOC of working code gathering dust. Wiring these is highest-priority action.

3. **Bucket classification:**
   - **Quick Wins (< 1h):** 10 remaining actionable items
   - **Medium Effort (1-4h):** 30 actionable items
   - **Future/Migration:** 14 items requiring Phaser 3 or WebGL

4. **gameplay.js (695 LOC) = #1 technical debt** — touches every system, 40+ direct calls. EventBus wiring is the single most impactful refactor.

5. **Procedural art ceiling reached** — each character needs ~400 LOC Canvas code. Adding Kid/Defender/Prodigy = 1200+ LOC. Strongest argument for Phaser 3 + sprite sheets.

6. **Phaser 3 migration impact:** Replaces ~800 LOC infrastructure (game loop, renderer, input, camera, particles, animation) with GPU-accelerated equivalents. Keeps ~3500 LOC game-specific logic.

**Recommended Priority:** Wire unused infrastructure (CONFIG, EventBus, AnimationController, SpriteCache) → Quick Wins → Combat polish → Content/Visual quality → System polish → Phaser 3 migration.

### New Project Playbook Created (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Studio-wide — affects how every future project starts

Created `.squad/identity/new-project-playbook.md` — the definitive, repeatable process for starting any new project at First Frame Studios, regardless of genre, tech stack, IP, or platform.

**What It Contains:**
1. **Pre-Production Phase** — Genre research protocol (7-12 reference games, analytical play, skill extraction), IP assessment (original vs licensed), 9-dimension tech selection framework, team skill transfer audit, competitive analysis
2. **Sprint 0 Foundation** — Engine-agnostic repo checklist, squad adaptation guide, genre skill creation, architecture proposal requirements, minimum playable formula per genre, quality gates adaptation
3. **Production Phases** — P0-P3 priority system, parallel lane planning, skill capture rhythm, cross-project knowledge transfer
4. **Technology Transition Checklist** — What transfers/rewrites/needs evaluation, migration mapping (Canvas→Godot as template), repeatable training protocol
5. **Language/Stack Flexibility Matrix** — 12 tech stacks compared, T-shirt migration sizing, the 70/30 rule (70% of our effectiveness is tech-agnostic)
6. **Anti-Bottleneck Patterns** — 7 firstPunch bottlenecks with preventions, 6 common studio patterns, serialize/parallelize guide, add-role vs add-skill decision matrix

**Key Decisions Within:**
- **8-point migration threshold:** Require 8+ point lead in 9-dimension matrix to justify engine migration
- **20% load cap:** No agent carries more than 20% of any phase's items
- **Module boundaries in Sprint 0:** Architecture proposal required before Phase 2 code begins
- **Wiring requirement:** Every infrastructure PR must include connection to at least one consumer

**Why:** The founder wants solid foundations so starting any new project is clear, repeatable, and bottleneck-free. firstPunch taught us everything in this playbook through real bugs, real bottlenecks, and real breakthroughs. Documenting it ensures we never repeat the investigation.

**Impact:**
- Every future project follows this playbook from Day 1
- Pre-production becomes a structured process, not ad-hoc discovery
- Technology transitions follow a proven 4-phase pattern
- Bottleneck patterns are identified and mitigated proactively
- New team members can read this document and understand how we start projects

### Skills System Needs Structural Investment Before Next Project (Ackbar)
**Author:** Ackbar (QA Lead)  
**Date:** 2025-07-21  
**Status:** Proposed

Conducted comprehensive audit of all 12 skills in `.squad/skills/`. Quality of individual skills is strong (7/12 rated ⭐⭐⭐⭐+), but coverage (5/10) and growth-readiness (4/10) are the weaknesses.

**Decision:**
Three actions should be taken before the next project kicks off:

1. **Create `game-feel-juice` skill (P0)** — Our #1 principle ("Player Hands First") has no dedicated skill. Game feel patterns are scattered across 3 skills. A unified, engine-agnostic game feel reference should be the first skill any new agent reads. Assign to Yoda + Lando.

2. **Create `ui-ux-patterns` skill (P1)** — Wedge is a domain owner with zero skills. Every game needs UI. This is the largest single-agent gap on the team. Assign to Wedge.

3. **Structural cleanup (P1)** — Split `godot-beat-em-up-patterns` (39KB, too large). Resolve overlaps: merge `canvas-2d-optimization` into `web-game-engine`, deduplicate `godot-tooling` vs `project-conventions`. Assign to Solo + Chewie.

**Impact:**
- **Yoda, Lando:** Create `game-feel-juice` skill
- **Wedge:** Create `ui-ux-patterns` skill  
- **Solo, Chewie:** Structural cleanup of overlapping skills
- **All agents:** 6 skills should have confidence bumped from `low` to `medium`
- **Full audit:** `.squad/analysis/skills-audit.md` contains per-skill ratings, gap analysis, and improvement recommendations

### 2026-03-10: New Project Proposals Ceremony
**By:** Full Team (6 agents — Yoda, Chewie, Lando, Boba, Solo, Tarkin)  
**What:** 18 game proposals generated with internet research for post-Ashfall direction. Top 5 ranked by AI-friendliness, scope, and viral potential:
1. **LAST SIGNAL** (micro-horror radio routing, 2 wk MVP) — Yoda's pick
2. **FLORA** (cozy gardening roguelite with L-systems, 3 wk MVP) — Boba's pick
3. **RICOCHET RAMPAGE** (physics destruction arcade, 3 wk MVP) — Lando's pick
4. **FACTORY FLUX** (automation puzzle roguelite, 4 wk MVP) — Solo's pick
5. **SHADOW THIEF** (stealth platformer as shadow, 4 wk MVP) — Boba's runner-up

**Why:** Ashfall closure ceremony concluded the studio needs simpler, web-first games that leverage rapid prototyping strengths. All 18 proposals designed to avoid Ashfall's failure modes (subjective feel tuning, complex art pipelines, genre complexity).

**Status:** AWAITING FOUNDER DECISION — Joaquín to review and select direction.

---

### 2026-03-11: Upstream + SubSquad + Blog Patterns Architecture Proposal
**By:** Solo (Lead Architect) + Jango (Tool Engineer)  
**Status:** AWAITING FOUNDER APPROVAL  
**What:** Complete implementation plan for incorporating Tamir Dresher blog patterns + upstream + subsquad into FFS workflow.

**Architecture Decision: Option C — Hybrid (RECOMMENDED)**
- `FirstFrameStudios/` = Studio hub (parent squad with identity, skills, principles)
- `jperezdelreal/flora` = Game repo (subsquad, inherits via `squad upstream`)
- Scales to future games: new repo + `squad upstream add FirstFrameStudios`
- 11 FLORA agents active, 3 hibernated (Leia, Bossk, Nien)

**Implementation Phases:**
- Phase 0: Restructure studio hub, TLDR convention (Day 1)
- Phase 1: Create FLORA repo, squad init, squad upstream (Day 1-2)
- Phase 2: CI/CD, workflows, issue templates, project board (Day 2-3)
- Phase 3: ralph-watch + scheduler (Day 3-4)
- Phase 4: FLORA Sprint 0 — build the game! (Day 4+)
- Phase 5: Podcaster + Squad Monitor (Week 2+)

**Tooling Priority:**
- DO FIRST: Issue template, heartbeat cron, TLDR convention, archive/notify workflows (~5h)
- DO NEXT: ralph-watch.ps1, scheduler, daily-digest, drift-detection (~24h)
- DO LATER: Squad Monitor, Podcaster (~5h)

**Full plans available in session context. Awaiting Joaquín's go/no-go.**

---

### 2026-03-11: Autonomy Gap Audit — Planned vs Implemented
**By:** Solo (Lead Architect)  
**Requested by:** Joaquín  
**Status:** INFORMATIONAL — input to prioritization

**Context:**
Joaquín flagged frustration: the squad planned an autonomous execution model (from Tamir Dresher blog patterns, Option C hybrid architecture in `solo-upstream-subsquad-proposal.md`) but much of it remains unimplemented. This audit compares what was **planned** in the inbox decisions vs what **actually exists** in the repo.

**Source Documents Analyzed:**
1. `copilot-tamir-blog-learnings.md` — 16 operational patterns from Tamir's blog
2. `solo-upstream-subsquad-proposal.md` — Option C hybrid implementation plan (5 phases)
3. `copilot-directive-2026-03-11T0745-repo-autonomy.md` — Founder directive: agents can create repos autonomously

**Gap Matrix:**

| # | Pattern / Plan Item | Status | Evidence |
|---|---------------------|--------|----------|
| 1 | **GitHub Issues = Central Brain** | ✅ IMPLEMENTED | Issue templates exist (`.github/ISSUE_TEMPLATE/squad-task.yml`), triage workflow exists, labels created |
| 2 | **Ralph Outer Loop (`ralph-watch.ps1`)** | ⚠️ BUILT, NOT ACTIVATED | Script exists at `tools/ralph-watch.ps1` (fully implemented, single-instance guard, heartbeat, structured logging). **Never run persistently.** Heartbeat file exists but is likely stale. |
| 3 | **Maximize Parallelism in Ralph** | ❌ NOT TESTED | Ralph prompt exists but parallel agent spawning not validated in production runs |
| 4 | **Two-Way Communication via Webhooks** | ❌ NOT IMPLEMENTED | No webhook integration, no Teams/Slack adapter, no notification channel configured |
| 5 | **Auto-Scan External Inputs** | ❌ NOT IMPLEMENTED | No email/Teams/HackerNews scanning. No `teams-bridge` label usage. |
| 6 | **Podcaster for Long Content** | ❌ NOT IMPLEMENTED | No Edge TTS integration. Phase 5 item — correctly deferred. |
| 7 | **Self-Built Scheduler** | ⚠️ BUILT, NOT ACTIVATED | `tools/scheduler/Invoke-SquadScheduler.ps1` exists with cron evaluator. Needs `schedule.json` tasks defined and actual activation via ralph-watch. |
| 8 | **Squad Monitor Dashboard** | ❌ NOT IMPLEMENTED | Not installed (`dotnet tool install -g squad-monitor` never run). Phase 5 item. |
| 9 | **Side Project Repos** | ⚠️ AUTHORIZED, NOT USED | Founder directive grants autonomy for repo creation. No side repos created yet. |
| 10 | **GitHub Actions Ecosystem** | ✅ MOSTLY IMPLEMENTED | 20+ workflows exist: triage, heartbeat, daily-digest, drift-detection, archive-done, label-enforce, label-sync, CI, docs, preview, release. **Comprehensive.** |
| 11 | **Self-Approve PRs** | ❌ NOT CONFIGURED | No auto-merge setup. PRs require human review. |
| 12 | **Cross-Repo Contributions** | ❌ NOT STARTED | No upstream PRs to Squad repo or other tools |
| 13 | **`squad upstream` for inherited context** | ❌ NOT IMPLEMENTED | Option C planned studio-hub + game-repo inheritance. No `squad upstream` configured. ComeRosquillas lives inside FFS repo, not as a subsquad. |
| 14 | **Multi-repo management** | ❌ NOT IMPLEMENTED | ralph-watch supports `$Repos` param but only single repo in use |
| 15 | **TLDR Convention** | ⚠️ DOCUMENTED, NOT ENFORCED | Team knows the pattern. No automated enforcement. No CI check for TLDR in issue comments. |
| 16 | **Issue Template** | ✅ IMPLEMENTED | `.github/ISSUE_TEMPLATE/squad-task.yml` exists |

**Phase Tracking (from `solo-upstream-subsquad-proposal.md`):**

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 0** | Restructure studio hub, TLDR convention | ⚠️ PARTIAL — hub exists, TLDR not enforced |
| **Phase 1** | Create game repo, squad init, squad upstream | ❌ NOT STARTED — ComeRosquillas absorbed into FFS, no subsquad |
| **Phase 2** | CI/CD, workflows, issue templates, project board | ✅ MOSTLY DONE — workflows are comprehensive |
| **Phase 3** | ralph-watch + scheduler | ⚠️ BUILT, NOT ACTIVATED |
| **Phase 4** | Game Sprint 0 — build the game | ⚠️ IN PROGRESS — ComeRosquillas exists (1636 LOC, playable) but no sprint structure |
| **Phase 5** | Podcaster + Squad Monitor | ❌ NOT STARTED (correctly — Phase 5) |

**Summary: What's Actually Blocking Autonomy:**

The infrastructure is **more built than it appears**. The real gap is **activation, not construction**:

1. **ralph-watch.ps1 needs to be started and left running.** The script is production-ready with single-instance guards, heartbeat, logging, and multi-repo support. It just hasn't been turned on.

2. **Scheduler needs tasks defined.** `Invoke-SquadScheduler.ps1` works but `schedule.json` needs actual recurring tasks (daily playtest, weekly retro, drift detection triggers).

3. **TLDR enforcement is cultural, not technical.** Agents write TLDRs when reminded. Need a lightweight CI check or prompt-level convention reinforcement.

4. **The subsquad/upstream model was abandoned** in favor of absorbing ComeRosquillas directly into FFS. This is fine for a single game but won't scale. Decision needed: is this the permanent model or a temporary expedient?

5. **Webhooks/notifications are the biggest true gap.** No way for the squad to proactively signal Joaquín when something important happens. This is the highest-leverage unbuilt feature.

**Recommended Priority Order:**
1. **P0:** Activate ralph-watch persistently (DevBox or local machine)
2. **P0:** Define schedule.json with 3-5 recurring tasks
3. **P1:** Install Squad Monitor (`dotnet tool install -g squad-monitor`)
4. **P1:** Add webhook notification for critical events (CI failure, PR merged)
5. **P2:** Evaluate subsquad model for ComeRosquillas vs monorepo approach
6. **P2:** Podcaster integration for long reports

---

### 2026-03-11: Autonomous Infrastructure Pivot to ComeRosquillas
**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Status:** Implemented

**Context:**
The autonomous loop infrastructure (ralph-watch, scheduler, heartbeat) was built during the FLORA planning phase but never became operational. The studio focus has shifted to ComeRosquillas (Homer's Donut Quest), a web game at `games/comerosquillas/` using HTML/JS/Canvas.

**Decision:**
1. **now.md** points to ComeRosquillas as the active project (not FLORA)
2. **Scheduler tasks** reference web-game workflows (browser playtest, browser compat) instead of Godot builds
3. **Backlog grooming** is enabled (was disabled)
4. **tools/README.md** documents how to start the autonomous loop with one command
5. **Legacy Godot tools** remain in `tools/` for reference but are documented as archived

**Consequences:**
- Any agent reading `now.md` will know the active game is ComeRosquillas
- The scheduler will create web-game-appropriate issues when ralph-watch runs
- Joaquín can start the full loop with `.\tools\ralph-watch.ps1`

**Team Impact:**
- **All agents:** now.md context is current — no confusion about FLORA vs ComeRosquillas
- **Ackbar:** Playtest issues now include browser checklist instead of Godot build instructions
- **Mace:** Backlog grooming is back on the schedule (Wednesdays)
- **Ralph:** Loop is verified operational — just needs to be started

---

### 2026-03-11: Learnings from Tamir Dresher's "Organized by AI" blog
**By:** Joaquín (via Copilot) — team reading assignment  
**Source:** https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai  
**What:** Key patterns from a power-user who runs Squad as his daily productivity system.

**Operational Patterns We Should Adopt:**

1. **GitHub Issues = Central Brain.** All Squad discussion happens IN issue comments. Agents always write TLDR at top of every comment. The founder reviews TLDRs, writes instructions in comments, sets status back to "Todo." Everything is documented, searchable, nothing lost.

2. **Ralph Outer Loop (`ralph-watch.ps1`).** Wraps Ralph in a persistent PowerShell loop that: (a) pulls latest code before each round, (b) spawns fresh Copilot sessions each time, (c) has heartbeat files, structured logging, failure alerts. Runs on machine or DevBox unattended.

3. **Maximize Parallelism in Ralph.** Prompt explicitly says: "If there are 5 actionable issues, spawn 5 agents in one turn." Don't work issues one at a time.

4. **Two-Way Communication via Webhooks.** Squad sends Teams/Slack messages for critical events (CI failures, PR merges, blocking issues). Uses Adaptive Cards with styled formatting. Rule: only send when genuinely newsworthy, never spam.

5. **Auto-Scan External Inputs.** Squad reads emails (Outlook COM), Teams messages, and tech news (HackerNews, Reddit). Creates GitHub issues automatically for actionable items. Labels like `teams-bridge` distinguish auto-created from manual.

6. **Podcaster for Long Content.** Converts markdown reports to audio via Edge TTS. Listen to 3000-word reports while walking. Auto-triggered after significant deliverables (>500 words).

7. **Self-Built Scheduler.** `Invoke-SquadScheduler.ps1` — cron-based triggers for recurring tasks (daily scans, weekly reports). Maintains state file. Runs before each Ralph round.

8. **Squad Monitor Dashboard.** Real-time .NET tool showing agent activity, token usage, costs. Open-sourced at github.com/tamirdresher/squad-monitor. `dotnet tool install -g squad-monitor`.

9. **Side Project Repos.** Squad creates their own repos for tools/utilities that shouldn't clutter the main repo. Links back to main project.

10. **GitHub Actions Ecosystem.** Workflows for: triage, heartbeat (5 min), daily digest, docs auto-gen, drift detection (weekly), archive done issues (7 days), notifications, label enforcement, label sync from team.md.

11. **Self-Approve PRs (Personal Repos).** For personal repos, Squad creates, reviews, and merges their own PRs. Human only jumps in for areas they care about or flagged reviews.

12. **Cross-Repo Contributions.** Squad naturally contributes back upstream to tools they use (PRs to Squad repo itself).

**Philosophy Shifts:**

- **"I don't manage tasks anymore. I manage decisions."** — The human focuses on decisions, Squad does everything else.
- **"AI is the first approach that meets me where I am."** — AI adapts to human chaos, not the other way around.
- **"The boundary between using a tool and building a tool dissolved."** — Squad evolved its own tools (monitor, scheduler, tunnel) as needs arose.
- **Squad as brain extension, not replacement.** — User still makes all important decisions. AI remembers, does tedious work, keeps systems running.

**Multi-Repo & Upstream Patterns (Joaquín highlighted these):**

13. **`squad upstream` for inherited context.** Tamir used the `upstream` command to inherit decisions, skills, and team context from parent squads. His personal Squad connects to work repos so agents can scan and learn from them without copy-pasting context. This enables hierarchical squad organization — one parent Squad with shared knowledge, child Squads per project.

14. **Multi-repo management.** Squad agents create and manage their OWN repos when they need standalone tools (squad-monitor, cli-tunnel, squad-personal-demo). Ralph's prompt includes `MULTI-REPO WATCH` to scan multiple repos for actionable issues in a single round. Example: `"In addition to tamresearch1, also scan tamirdresher/squad-monitor for actionable issues."`

15. **Cross-repo contributions upstream.** Agents contributed PRs back to the Squad repo itself: ADO Platform Adapter (PR #191), CommunicationAdapter (PR #263), SubSquads (PR #272), Upstream & Watch commands (PR #280), test resilience (PR #283). The boundary between "using a tool" and "building a tool" dissolved completely.

16. **Side project repos as first-class workflow.** When agents need a standalone tool, they create a repo, build it there, and link back to the main project. Just like a real engineer saying "I'll build this separately so it doesn't clutter the main project." Examples: squad-monitor (real-time dashboard, open-sourced), cli-tunnel (remote terminal access).

**Applicable to First Frame Studios:**

- We should adopt the **GitHub Issues as backbone** pattern — all agent work documented in issue comments with TLDRs
- We should explore **ralph-watch.ps1** for unattended operation during long builds/sprints
- **Squad Monitor** could give Joaquín visibility into what agents are doing during long parallel spawns
- The **Podcaster** pattern could help Joaquín consume long analysis docs (we generate a LOT of analysis)
- **GitHub Actions workflows** (triage, heartbeat, daily digest) would automate our current manual processes
- The **self-built scheduler** pattern would enable recurring tasks (daily playtest, weekly retro)
- **`squad upstream`** could let FFS have a master Squad with studio-wide knowledge (principles, conventions, skills) inherited by each game project's Squad — shared wisdom without duplication
- **Multi-repo watch** in Ralph would let us monitor both the main FFS repo AND any game-specific repos (e.g., a separate `games/flora` repo) from a single Ralph loop
- **Cross-repo contributions** — our agents could contribute improvements back to Squad itself when they hit limitations, just like Tamir's team did

---

### 2026-03-11T07:45: User directive — Side Project Repo Autonomy
**By:** Joaquín (via Copilot)  
**What:** Los agentes pueden crear repos públicos bajo demanda sin aprobación previa. Ellos deciden el nombre, qué agentes asignar, y todo lo que haga falta para el side project. Autonomía total en gestión de repos.

**Why:** User request — captured for team memory. Enables Tamir-style "side project repos as first-class workflow" pattern.

---

### 2026-03-10T22:06: User directive — Visual Quality Standard
**By:** Joaquín (via Copilot)  
**What:** Los juegos propuestos deben ser VISTOSOS — nada de cutreces baratas. Visualmente impresionantes pero rápidos de hacer. El objetivo es aprender cosas nuevas (frameworks como Vite, etc.) y hacer show off. Explorar lo que hay en la web: gente usando Squad/AI para completar juegos tipo Pokémon, nuevos frameworks, ideas novedosas sin sobrecomplicaciones.

**Why:** User request — captured for team memory. Establishes visual quality as non-negotiable criteria for next project selection.

---

### 2026-03-10: Ashfall Project Closure
**By:** Full Team (closure ceremony)  
**What:** Ashfall (1v1 fighting game, Godot 4) officially shelved after 2 complete sprints. Key lessons: fighting games too complex for AI-only tuning, art pipeline needs validation before production, integration gates must be automated from Day 1, Lead Architect role must split at 10+ agents.

**Why:** Team consensus — the genre requires subjective feel-tuning that AI agents cannot deliver. Studio pivoting to simpler, faster-to-ship game genres.

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

---

### Documentation & Terminology Clarity (2026-03-09T10:11Z)
**By:** joperezd (via Copilot)
**Date:** 2026-03-09
**Status:** Directive

**What:** All public-facing documentation (wiki, devblog, README) must clearly distinguish between Milestone Gates (M0-M4 within a sprint) and Sprints (Sprint 0 = Foundation, Sprint 1 = Art, etc.). No ambiguity — readers should understand at a glance where the project stands without confusing "M3" with "Sprint 3". Use consistent terminology everywhere.

**Why:** User experienced confusion from docs mixing milestone gate numbers with sprint/phase numbers. This caused incorrect assumptions about project status. Accuracy and clarity in documentation is a top priority.

---

### Sprint Definition of Success (2026-03-09T10:14Z)
**By:** joperezd (via Copilot)
**Date:** 2026-03-09
**Status:** Directive

**What:** Every sprint must have a clear "Definition of Success" — specific, measurable criteria that determine whether the sprint can be closed satisfactorily. This applies retroactively to Sprint 0 and must be defined upfront for all future sprints (Sprint 1+). The criteria should answer: "What must be true for us to close this sprint satisfied?" Not just "tasks done" but quality gates, feel checks, and ship readiness.

**Why:** Without explicit success criteria, sprints drift — you can't tell if you're done or just out of time. The founder wants clarity on what "done" means for each sprint so the team knows the goal and can celebrate when they hit it.

---

### Jango — Solo Role Split (2026-03-09)
**Author:** Joaquín (User)  
**Status:** Active  
**Scope:** Team role clarification — Solo & Mace

**Change:** Solo's role narrowed to pure architecture review. Operational tasks (blocker tracking, branch rebasing, stale issue management) moved to Mace.

**Why:** "Architecture review is deep work" — can't do it well while context-switching to ops. Solo does uninterrupted architecture design. Mace handles transactional ops (check, flag, resolve).

**Authority:**
- **Solo:** Pure architecture review, system design, integration patterns, code structure
- **Mace:** Ops backbone — blocker unblocking, branch validation, issue cleanup, rebase coordination

**Artifacts:** Solo's charter updated, Mace's charter updated, routing.md updated.

---

### Mace — GitHub Operations Setup (2026-03-08)
**Author:** Mace (Producer)  
**Status:** Implemented  
**Scope:** GitHub-centric project operations for FirstFrameStudios

What Was Done:

1. **README.md Development Section** — Links to Issues, Project, Wiki, workflow diagram, CONTRIBUTING.md
2. **CONTRIBUTING.md Created** — Complete workflow:
   - Branch naming: `squad/{issue-number}-{slug}`
   - Commit format with examples
   - Label system explanation (game, squad, type, priority, status)
   - How Squad agents pick up work (via labels)
   - PR process, code review standards, 20% load cap
3. **team.md Updated** — Issue Source section (jperezdelreal/FirstFrameStudios, game:ashfall filter for current sprint)
4. **GitHub Wiki Status** ⏳ — Wiki cannot be enabled via API. Manual action required: joperezd must enable in repo settings

**Why:** Centralized visibility, clear workflow, scalability, governance, discoverability.

**Decisions Made:**
- Label-driven work allocation (Squad agents query GitHub Issues by label, not manual assignment)
- Branch naming ties to issues (squad/{issue-number} enables auto-linking)
- Wiki optional, not critical (processes in CONTRIBUTING.md; Wiki hosts GDDs/ARCHs separately)
- Load cap governance in CONTRIBUTING.md (team understands 20% rule)
- Game-tagged filtering (game:ashfall current sprint, future games follow same model)

**Risk Mitigation:**
- Wiki not enabled immediately? No impact; critical docs in repo.
- Squad agents don't find issues? Daily standup in #ashfall clarifies ownership.
- Load cap enforcement? Mace monitors daily, blocks merges if agent exceeds 20%.

**Follow-Up Actions:**
- [ ] joperezd: Enable Wiki in repo settings
- [ ] joperezd: Create Wiki home page
- [ ] Solo: Train agents on branch naming + commit format
- [ ] Jango: (Optional) GitHub Actions validator for branch names
- [ ] Mace: Begin daily #ashfall standup

---

### Mace — Dev Diary Post Process (Post-Milestone)
**Author:** Mace (Producer)  
**Decision:** Create Dev Diary discussion post after each milestone

**Process:**
1. **Timing:** Post within 24 hours of milestone completion
2. **Category:** "General" discussion category
3. **Title Format:** `🔥 Dev Diary #X: [Milestone Title]` (e.g., "#2: Character Sprites & Polish")
4. **Content:** Pitch, What We Shipped, By The Numbers, What's Next, The Meta, CTA
5. **Tone:** Passionate, transparent, indie dev blog + behind-the-scenes documentary. NOT corporate.
6. **Visibility:** Public-facing marketing for First Frame Studios. Every post reminds readers this is AI-powered dev.

**Integration with Wiki:**
- Update `.squad/wiki/milestones.md` after each milestone
- Link Dev Diary discussion from milestone entry
- Track discussion URL for metrics

---

### Mace — Issue Creation Discipline (2026-03-09)
**Author:** Joaquín (User)  
**Decision:** All agents must create GitHub issues immediately when they find bugs, blockers, or unresolved questions

**Why:** Post-mortems revealed known problems never tracked. Tarkin's AI controller sat on dead branch with no issue. Solo's overload surfaced only in ceremony. Issues at discovery time, not retroactively.

---

### User Directives — March 8-9, 2026

#### 2026-03-08T12:42:49Z: GitHub-First Development
**By:** Joaquín (User)  
**What:** Use GitHub's full potential — Issues for task tracking, Projects for boards, PRs for code review. No empty repo; everything active and visible.

#### 2026-03-08T18:01:00Z: Joaquín Never Reviews Code
**By:** Joaquín (User)  
**What:** Joaquín is NOT a code reviewer. Jango (Lead) handles all PR reviews. Founder focuses on vision, not implementation.

#### 2026-03-08T18:05:00Z: Wiki Auto-Update Post-Milestone
**By:** Joaquín (User)  
**What:** Wiki updates automatically after each milestone as part of dev cycle. Mace responsibility. Integrate in post-milestone flow.

#### 2026-03-08T18:10:00Z: Dev Diary Auto-Post
**By:** Joaquín (User)  
**What:** El devlog (GitHub Discussions) se publica automáticamente tras cada milestone, igual que la wiki. Responsabilidad de Mace. No se pide manualmente.

#### 2026-03-08T21:22:00Z: Jango Unlimited on Tooling
**By:** Joaquín (User)  
**What:** Jango (Lead) has NO 20% bandwidth limit. Full freedom to propose and create tools, scripts, automations. Not just reviewer — tool engineer with carte blanche.

#### 2026-03-09T09:15:31Z: Backlog Automation, Team Autonomy, Role Overload
**By:** Joaquín (User)  
**What:** 
1. Backlog sync must be automated (CI/CD) — scan code for TODOs, docs for undocumented items, auto-create issues
2. Lead autonomy on bandwidth — Jango adjusts workload distribution independently, no CEO approval needed
3. Auto-wiki/devblog updates — Implement Jango's proposed automation
4. Solo overloaded — needs role split (architecture review ≠ ops tasks)
5. ADRs and integration testing — Evaluate and implement Solo's proposals


---

### 2026-03-11T11:20: User directive
**By:** Joaquín (via Copilot)
**What:** No Podcaster. No queremos integración de text-to-speech ni conversión de reports a audio.
**Why:** User decision — out of scope for FFS.

---

### 2026-03-11T12:16Z: User directive — GitHub Pages architecture and purpose
**By:** Joaquin (via Copilot)
**What:** Each repo has its own GitHub Pages site with distinct purpose:
- **FFS Hub Page** → Brand, identity, studio presentation. "AI Gaming Studio Hub". NOT game content.
- **Game Pages** (ComeRosquillas, Flora, etc.) → Game showcase: screenshots, changelog, playable demo (Play button).
- All Pages share a consistent Astro template/theme from FFS but with per-game branding/colors.
- Updates are automated: push to main → Actions rebuild → Pages deploys.
**Why:** User request — defines the purpose and content structure of each GitHub Pages site across the multi-repo architecture.

---

### 2026-03-11T12:19Z: User directive — FFS homepage and blog strategy
**By:** Joaquin (via Copilot)
**What:** 
1. FFS homepage is practically perfect as-is — do NOT redesign it.
2. FFS blog should auto-publish summarized progress updates from game repos (advances, milestones, releases).
3. Push-to-main workflow is correct for both hub and game repos.
**Why:** User request — preserves current hub design and establishes blog as the living chronicle of studio activity.

---

# Multi-Repo Studio Governance — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-24  
**Requested by:** Joaquín (Founder)  
**Status:** ⏳ AWAITING FOUNDER APPROVAL  
**Scope:** Studio-wide — defines how FFS operates as a multi-repo studio hub

---

## Preamble

Joaquín asked the fundamental governance question: **how does everything flow in a multi-game studio?** This document answers that question across 9 domains. Once approved, it becomes the operating manual for First Frame Studios.

**Studio Topology:**
```
FirstFrameStudios (Hub)
├── jperezdelreal/ComeRosquillas  (Game repo — HTML/JS/Canvas)
├── jperezdelreal/flora            (Game repo — Vite/TS/PixiJS, on hold)
├── jperezdelreal/ffs-squad-monitor (Tool repo — Vite/JS)
└── [future repos]                 (Created on demand per Repo Autonomy directive)
```

**Key Actors:**
- **Joaquín** — Founder. Vision, direction, go/no-go decisions. Never reviews code.
- **Solo** — Hub Lead / Chief Architect. Architecture, integration, governance.
- **Jango** — Tool Engineer / PR Reviewer. All code reviews, CI/CD, tooling.
- **Mace** — Producer. Sprint planning, ops, blocker tracking.
- **Yoda** — Game Designer / Vision Keeper. Creative coherence per project.
- **@copilot** — Coding agent. Executes well-defined tasks autonomously.
- **Ralph** — Work Monitor. Heartbeat, scheduling, multi-repo watch.

---

## 1. APPROVAL FLOW

### 1.1 Tiered Approval Model

| Tier | What | Approver | Turnaround | Examples |
|------|------|----------|------------|----------|
| **T0 — Auto-Approved** | Routine work matching existing patterns | No human approval needed | Immediate | Bug fixes, test additions, dependency updates, docs updates, @copilot issue work |
| **T1 — Agent-Reviewed** | Implementation PRs, feature work | Jango (PR Reviewer) | Same session | New features, refactors, gameplay changes, UI work, audio additions |
| **T2 — Lead-Reviewed** | Architecture changes, cross-system work | Solo (Lead) + Jango | Same day | New systems, module restructuring, API changes, integration PRs |
| **T3 — Founder-Decided** | Direction, vision, go/no-go | Joaquín | Async (via issue comment) | New game selection, project closure, team changes, budget decisions, this document |

### 1.2 Per-Repo Approval Rules

**Hub (FirstFrameStudios):**
- Identity/principles/wisdom changes → T3 (Founder)
- Team/routing/ceremonies changes → T2 (Solo)
- Skills creation/updates → T1 (Jango reviews, domain expert authors)
- Tool scripts (ralph-watch, scheduler) → T1 (Jango)
- Decision documents → T2 (Solo proposes, Founder approves if T3)

**Game Repos (ComeRosquillas, Flora, future games):**
- Gameplay code PRs → T1 (Jango reviews)
- Architecture decisions → T2 (Solo reviews)
- Game-specific .squad/ config → T0 (auto-approved, game squad manages)
- New game milestones/sprints → T2 (Mace + Solo + Yoda plan)
- Ship/no-ship decision → T3 (Founder)

**Tool Repos (ffs-squad-monitor, future tools):**
- Implementation PRs → T1 (Jango reviews)
- Creation of new tool repo → T0 (per Repo Autonomy directive, 2026-03-11)
- Tool repo architecture → T1 (Jango, since tool repos are Jango's domain)

### 1.3 Does Every PR Need Approval?

**Yes, but the level varies:**
- **T0 PRs** (bug fixes, docs, tests): Jango can fast-track approve or @copilot can self-merge if `copilot-auto-assign: true` is set and CI passes.
- **T1 PRs** (features): Jango reviews. One approval required. No Joaquín involvement.
- **T2 PRs** (architecture): Solo + Jango both review. Two approvals required.
- **T3 PRs** (governance): Joaquín approves via issue comment. Squad implements.

### 1.4 Can Game Repos Self-Approve?

**Yes, within bounds.** Game squads operate autonomously for T0 and T1 work:
- Game-internal features, bugs, and content → self-approved by game squad's reviewer (Jango)
- Cross-repo changes (upstream sync, shared tool integration) → Hub review (Solo)
- Game closure/archival → Founder decision (T3)

**Rule:** If the change stays inside the game repo and doesn't affect studio identity, skills, or team structure, the game squad approves it. If it flows upstream, Hub reviews.

---

## 2. AUTONOMY LEVELS

### 2.1 Autonomy Matrix by Repo Type

| Autonomy Level | Hub | Game Repo | Tool Repo |
|----------------|-----|-----------|-----------|
| **Full Autonomy** (no ask needed) | Tool scripts, orchestration logs, session logs | Gameplay code, game-specific bugs, local .squad/ config, issue creation, sprint execution | All implementation, architecture, issues, releases |
| **Notify Hub** (do it, then tell) | Skill updates, ceremony changes | New milestone start, dependency on hub skill, architecture deviations | Integration points with other repos |
| **Ask Hub** (propose, wait for approval) | Identity/principle changes, team roster changes | Cross-repo PRs, requests for new hub skills, requests for team changes | N/A — tool repos are fully autonomous |
| **Ask Founder** (escalate to Joaquín) | New game selection, project closures, budget | Ship decisions, IP/brand decisions | N/A |

### 2.2 What Can a Game Squad Do WITHOUT Asking the Hub?

1. ✅ Create issues, plan sprints, assign work within the game repo
2. ✅ Implement features, fix bugs, write tests, ship builds
3. ✅ Create game-specific .squad/ config, skills, and decisions
4. ✅ Merge PRs after Jango review (T1)
5. ✅ Create side-tool repos if needed (per Repo Autonomy directive)
6. ✅ Run ceremonies (retrospectives, design reviews, playtests)
7. ✅ Update game-specific documentation and README
8. ✅ Deploy to GitHub Pages or other hosting

### 2.3 What MUST Escalate to the Hub?

1. 🔺 Changes to studio identity (principles, mission, company identity)
2. 🔺 Requests for new studio-wide skills or skill modifications
3. 🔺 Team roster changes (wake hibernated agents, create new agents)
4. 🔺 Cross-repo dependencies (game A needs something from game B)
5. 🔺 Architecture patterns that should become studio standards
6. 🔺 Project closure, archival, or significant scope changes
7. 🔺 Any change to upstream-inherited content

### 2.4 @copilot Auto-Assign

**Current state:** `copilot-auto-assign: false` in team.md.

**Recommended policy:**
- **Hub repo:** Keep `false`. Hub work is governance/architecture — not @copilot's strength (🔴 per capability profile).
- **Game repos:** Set to `true` for issues labeled `squad:copilot`. Well-defined game tasks (HTML/JS/Canvas, TypeScript/Vite, PixiJS) are @copilot's sweet spot (🟢).
- **Tool repos:** Set to `true`. Tool implementation is straightforward and well-scoped.

**Guard rail:** @copilot PRs still require Jango review before merge. Auto-assign means auto-pickup, not auto-merge. The Lead triages which issues get `squad:copilot` per the routing table in routing.md.

---

## 3. SKILL FLOW BETWEEN REPOS

### 3.1 How Skills Move Between Games

```
Game A discovers pattern → Game A writes draft skill → Hub reviews → Hub curates → All games inherit
```

**Step-by-step:**
1. **Discovery:** During game development, an agent identifies a reusable pattern (e.g., "procedural maze generation for arcade games").
2. **Draft:** The agent writes a draft skill in the game repo at `.squad/skills/{skill-name}/SKILL.md` (per Self-Improvement charter section).
3. **Proposal:** Agent creates an issue in the Hub repo: `[Skill Proposal] {skill-name}` with link to draft.
4. **Review:** Solo reviews for studio-wide applicability. Yoda validates game design relevance. Jango checks technical quality.
5. **Promotion:** If approved, the skill is moved to the Hub's `.squad/skills/` directory and added to the skills index.
6. **Inheritance:** All game repos receive the skill on next `squad upstream sync`.

### 3.2 Studio Skills (Hub-Curated)

The Hub maintains **studio skills** — patterns proven across 2+ projects or deemed universally applicable. These live in `.squad/skills/` and are indexed.

**Current studio skills:** 41 skills across game design, audio, animation, level design, enemy design, studio craft, engine patterns, and more.

**Categorization for inheritance:**

| Category | Inherited By | Examples |
|----------|-------------|---------|
| **Universal** (all games) | All game repos | game-feel-juice, studio-craft, ui-ux-patterns, procedural-audio |
| **Genre-Specific** (opt-in) | Games in that genre | beat-em-up-combat, arcade-game-patterns |
| **Tech-Specific** (opt-in) | Games using that stack | canvas-2d-optimization, vite-typescript-patterns |
| **Archived** | None (reference only) | godot-beat-em-up-patterns, godot-tooling |

### 3.3 When a Game Discovers a Pattern

**Threshold for promotion:** A pattern becomes a studio skill when:
1. It solved a real problem in a shipped game (not theoretical)
2. It's documented with examples (not just a vague principle)
3. It applies to at least one other game genre/stack (or is demonstrably universal)
4. An agent explicitly proposes it (patterns don't promote themselves)

**Anti-pattern:** "This pattern works in ComeRosquillas so let's make it a studio skill." → Does it apply to Flora? To a future 3D game? If it's Pac-Man-specific, it stays in ComeRosquillas.

### 3.4 `squad upstream sync` — When and How

**When to sync:**
- After Hub identity changes (principles, wisdom, quality-gates)
- After new studio skills are approved
- At project kickoff (fresh sync before Sprint 0)
- Monthly maintenance sync (drift prevention)

**How to sync (until squad-cli ships native upstream):**
```powershell
# From game repo root
cd "C:\Users\joperezd\GitHub Repos\ComeRosquillas"

# Sync identity (upstream wins)
Copy-Item "..\FirstFrameStudios\.squad\identity\principles.md" ".squad\upstream\identity\"
Copy-Item "..\FirstFrameStudios\.squad\identity\wisdom.md" ".squad\upstream\identity\"
Copy-Item "..\FirstFrameStudios\.squad\identity\quality-gates.md" ".squad\upstream\identity\"

# Update skills index
Copy-Item "..\FirstFrameStudios\.squad\skills\INDEX.md" ".squad\upstream\skills\"

# Update timestamp
# Edit .squad/upstream/manifest.json → last_synced: (current ISO 8601)
```

**Who syncs:** Jango (Tool Engineer) owns the sync process. Mace tracks sync dates in ceremony checklists.

---

## 4. HUB'S ROLE IN GAME DEVELOPMENT

### 4.1 What Does the Hub Squad DO During Active Game Dev?

The Hub is **not idle** during game development. It operates as the **studio brain**:

| Hub Activity | Owner | Cadence |
|-------------|-------|---------|
| Skill curation and growth | Solo + domain experts | Ongoing — as proposals arrive |
| Cross-project pattern recognition | Solo | Per milestone review |
| Team health monitoring | Mace | Weekly |
| Tool development and maintenance | Jango | As needed |
| Ralph multi-repo watch | Ralph | Continuous (when activated) |
| Studio ceremonies (kickoff, ship, postmortem) | Solo + Yoda + Mace | Per lifecycle event |
| Upstream sync to game repos | Jango | Monthly + on-change |
| Quality gate evolution | Solo + Ackbar | Post-milestone |
| Dashboard/monitor maintenance | Jango | As needed |

### 4.2 Does Solo Review Game PRs?

**Only T2 PRs** (architecture changes). Solo does NOT review routine game PRs:
- **Jango** reviews all T0 and T1 PRs (bug fixes, features, content)
- **Solo** reviews T2 PRs (new systems, module restructuring, cross-system integration)
- **Solo** performs integration gate verification after parallel agent waves

**Rationale:** Per the Jango-Solo role split decision (2026-03-09), Solo does deep architecture work. Routine PR review is Jango's domain. Context-switching between architecture and line-by-line review degrades both.

### 4.3 How Does Hub Identity/Wisdom Flow Downstream?

Three mechanisms:

1. **Upstream sync** — Identity files (principles, wisdom, quality-gates) copied to game repos. Upstream wins on conflicts.
2. **Agent charters** — All agents carry studio-scoped charters that reference hub principles. Charters travel with the agent regardless of which repo they work in.
3. **Ceremony outputs** — Kickoff ceremony includes "read the principles" step. Retrospective outputs flow back to hub as lessons. Skills flow through promotion pipeline.

### 4.4 Does the Hub Create Issues for Games?

**Both models coexist:**

| Issue Source | Where Filed | Examples |
|-------------|------------|---------|
| Game squad self-manages | Game repo | Bugs, features, sprint work, playtesting |
| Hub identifies cross-project issue | Hub repo (tagged `game:{name}`) | Upstream sync needed, skill gap identified, pattern to promote |
| Founder requests | Game repo (if game-specific) or Hub (if studio-wide) | "Add mobile controls", "Ship by Friday" |
| Ralph/Scheduler creates | Game repo | Recurring tasks (weekly playtest, backlog grooming) |

**Rule:** Games are self-managing by default. The Hub intervenes when it spots cross-project patterns, upstream drift, or quality gate failures that the game squad missed.

---

## 5. SIDE PROJECT LIFECYCLE

### 5.1 When a Game Needs a New Tool

**Per the Repo Autonomy directive (2026-03-11):** Any agent can create a public repo for a side project without prior approval. They decide the name, agent assignments, and everything needed.

**Process:**
1. Agent identifies need (e.g., "we need a sprite consistency checker")
2. Agent creates repo under `jperezdelreal/` (or proposes under `FirstFrameStudios/` org if created)
3. Agent runs `squad init` in the new repo
4. Agent sets up `squad upstream add FirstFrameStudios` for inherited context
5. Agent creates initial issues and starts building
6. Agent notifies Hub (issue in FFS: `[New Tool] {tool-name} created`)

### 5.2 Where Is Tool Development Tracked?

**In the tool repo itself.** The tool is a first-class project with its own issues, PRs, and milestones.

**Hub tracking:** The Hub maintains a reference in `team.md` (Active Projects table) and `routing.md` (Multi-Repo Issue Routing). Hub does NOT duplicate the tool's issue board.

**Cross-reference:**
- Tool repo README links back to FFS as parent studio
- FFS team.md lists the tool repo with status
- Ralph's multi-repo watch includes tool repos

### 5.3 How Tools Get Shared Across Games

1. **NPM/package:** If the tool is a library, publish to npm or use git submodule
2. **Script copy:** If the tool is a script (like integration-gate.py), copy to game repos that need it
3. **Studio skill:** If the tool embodies a pattern, promote the pattern to a hub skill
4. **Direct dependency:** If the tool is a standalone app (like squad-monitor), games don't depend on it — it reads from them

**Rule:** Tools should be **read-only observers** of game repos where possible (like squad-monitor reads heartbeat data but never writes to game repos). This prevents coupling.

---

## 6. CEREMONY SCHEDULE

### 6.1 Studio Ceremony Calendar

| Ceremony | When | Facilitator | Participants | Output |
|----------|------|-------------|-------------|--------|
| **Project Kickoff** | When Founder greenlights a new game | Solo (Lead) | Solo + Yoda + Mace + Jango + Joaquín | Repo created, squad initialized, Sprint 0 plan, architecture proposal, GDD skeleton |
| **Sprint Planning** | Start of each sprint (biweekly) | Mace (Producer) | Mace + Yoda + Solo | Sprint scope, assignments, milestone, success criteria |
| **Mid-Sprint Review** | Midpoint of sprint | Mace (Producer) | Mace + active agents | Progress check, blocker identification, scope adjustment |
| **Sprint Retrospective** | End of each sprint | Solo (Lead) | All involved agents | 5 went-right / 5 went-wrong, action items, lessons for hub |
| **Integration Gate** | After parallel agent waves | Solo (Architect) | Solo + Ackbar | Systems verified connected, blockers documented |
| **Ship Ceremony** | When a game is "done" | Yoda (Vision Keeper) | Full team + Joaquín | Ship decision, release checklist, launch announcement |
| **Post-Mortem** | After project closure | Solo (Lead) | Full team | Lessons document, skill proposals, process improvements |
| **Next Project Selection** | After post-mortem + cooldown | Yoda (Game Designer) | Full team proposals, Joaquín decides | Game proposals ranked, Founder selects, kickoff scheduled |
| **Monthly Upstream Sync** | First Monday of month | Jango (Tool Engineer) | Jango | All game repos synced with latest hub identity/skills |
| **Quarterly Studio Review** | Every 3 months | Mace (Producer) | Solo + Mace + Joaquín | Studio health metrics, team assessment, strategic direction |

### 6.2 Ceremony Details

#### Project Kickoff (Solo facilitates)

**Trigger:** Joaquín greenlights a new game from the proposals list.

**Agenda (Day 1-2):**
1. Create game repo under `jperezdelreal/`
2. Run `squad init --no-workflows` (or full init when CLI supports it)
3. Set up `squad upstream` connection to FFS hub
4. Yoda drafts Game Design Document skeleton
5. Solo delivers Architecture v1.0 (per New Project Playbook)
6. Mace creates Sprint 0 plan with milestones and success criteria
7. Jango sets up CI/CD, issue templates, labels, workflows
8. Team reads principles.md (required — Principle #12)
9. Hub issue: `[Kickoff Complete] {game-name}` with all links

**Output:** Playable repo with architecture locked, GDD skeleton, Sprint 0 plan, CI green, upstream connected.

#### Ship Ceremony (Yoda facilitates)

**Trigger:** Game meets ship criteria (defined in Sprint N's Definition of Success).

**Agenda:**
1. Yoda performs final Vision Keeper review: "Does this feel like THIS game?"
2. Ackbar runs full smoke test on target platform(s)
3. Solo verifies integration gate passes
4. Mace confirms all milestone issues closed
5. Joaquín gives ship/no-ship decision (T3)
6. If ship: Jango triggers release workflow, Mace posts Dev Diary, Mace updates Wiki
7. Celebration. The team earned it.

**Output:** Released game, Dev Diary post, Wiki milestone entry, release tag.

#### Post-Mortem (Solo facilitates)

**Trigger:** After Ship Ceremony or after project closure/archival.

**Agenda (per Principle #15):**
1. Each agent contributes "5 went right / 5 went wrong" (async, before ceremony)
2. Solo synthesizes into patterns
3. Identify skills to promote to hub
4. Identify process improvements for next project
5. Write lessons to `.squad/analysis/{game}-postmortem.md`
6. Create action items as Hub issues

**Output:** Postmortem document, skill proposals, process improvement issues, updated hub wisdom.

#### Next Project Selection (Yoda facilitates)

**Trigger:** After post-mortem cooldown (minimum 1 day, recommended 1 week).

**Agenda:**
1. Yoda calls for proposals: each agent may submit 1-3 game concepts
2. Proposals scored on: AI-friendliness, scope (MVP ≤ 4 weeks), visual impact, learning opportunity, viral potential
3. Top 5 presented to Joaquín with ranked recommendations
4. Joaquín selects (T3 decision)
5. Project Kickoff ceremony scheduled

**Output:** Ranked proposals document, Founder selection, kickoff date.

---

## 7. PROJECT LIFECYCLE

### 7.1 When a Game Is DONE

**"Done" means one of two states:**

#### State A: SHIPPED ✅
The game is released, playable, and the team is satisfied.

**Post-ship checklist:**
1. ✅ Release tag created (`v1.0.0`)
2. ✅ GitHub Pages deployment live (or other hosting)
3. ✅ All milestone issues closed with `Closes #N`
4. ✅ Post-Mortem ceremony completed
5. ✅ Lessons promoted to hub skills (where applicable)
6. ✅ Dev Diary final post published
7. ✅ Wiki updated with final status
8. ✅ Repo stays **ACTIVE** for patches and maintenance
9. ✅ README updated with "Released" badge and play link

**The repo does NOT get archived.** Shipped games may receive patches, community fixes, and minor updates. The repo goes into **maintenance mode** — new features are unlikely, but bugs get fixed.

#### State B: SHELVED 📦
The game is abandoned before shipping (like Ashfall).

**Post-shelve checklist:**
1. ✅ Post-Mortem ceremony completed (this is MORE important for shelved games)
2. ✅ Lessons promoted to hub skills aggressively (this is the game's legacy)
3. ✅ All useful patterns extracted before archival
4. ✅ Repo marked as archived on GitHub (Settings → Archive)
5. ✅ Hub team.md updated: project status → ✅ ARCHIVED
6. ✅ Final decision document explaining WHY it was shelved
7. ✅ Game-specific agents hibernated (if they have no cross-game role)

### 7.2 How Is the NEXT Game Selected?

**Who proposes:** Any agent on the team. Agents are encouraged to research trends, analyze what's working in the indie space, and propose games that match FFS strengths.

**Who decides:** Joaquín (Founder). Always. T3 decision. The team recommends, the Founder chooses.

**Game Jam option:** Yoda can propose a "48-hour game jam" ceremony where 3-4 agents each prototype a different game concept. The prototypes are played, and the best one becomes the next project. This is optional — Joaquín can also just pick from written proposals.

**Timeline from idea to repo:**

| Step | Time | Who |
|------|------|-----|
| Proposal written | 1-2 hours | Any agent |
| Team review & ranking | 1 session | Yoda facilitates, all agents vote |
| Founder selects | Async | Joaquín |
| Repo created + squad init | 30 minutes | Jango |
| Upstream connected | 15 minutes | Jango |
| Architecture v1.0 | 2-4 hours | Solo |
| GDD skeleton | 2-4 hours | Yoda |
| Sprint 0 plan | 1-2 hours | Mace |
| **Total: Idea → Building** | **~1-2 days** | — |

---

## 8. LOGGING AND OBSERVABILITY

### 8.1 Where Each Layer Logs

| Layer | Log Location | Format | Owner |
|-------|-------------|--------|-------|
| **Hub orchestration** | `.squad/orchestration-log/` | Markdown per session (`{date}-{agent}.md`) | Solo |
| **Hub tools** | `tools/logs/` | Structured JSON (ralph heartbeat, scheduler state) | Ralph / Jango |
| **Hub sessions** | `.squad/sessions/` | Session artifacts | Scribe |
| **Hub decisions** | `.squad/decisions/` + `.squad/decisions/inbox/` | Markdown decision docs | All agents |
| **Game repo squad** | Game's `.squad/log/` | Game-specific session logs | Game squad |
| **Game repo CI** | GitHub Actions logs | Standard CI output | Jango / GitHub |
| **Ralph heartbeat** | `tools/logs/heartbeat.json` | `{timestamp, repos_checked, issues_found, status}` | Ralph |
| **Ralph structured logs** | `tools/logs/ralph-{date}.jsonl` | One JSON object per line, per action | Ralph |

### 8.2 Cross-Repo Visibility

| Reader | Can Read | Cannot Read |
|--------|----------|-------------|
| **Hub agents** | All Hub logs, game repo public logs (via git clone/API) | Game repo local-only files |
| **Game agents** | Own repo logs, Hub upstream identity/skills (via sync) | Other game repo logs, Hub orchestration logs |
| **Ralph** | All repos (multi-repo watch), all heartbeat files | N/A — Ralph reads everything |
| **Joaquín** | Everything (founder access to all repos) | N/A |
| **Squad Monitor** | Hub + game heartbeat.json, ralph logs | Agent session content (too verbose) |

### 8.3 Monitor Dashboard Aggregation

**ffs-squad-monitor** aggregates by reading:
1. `heartbeat.json` from each repo (polling or webhook)
2. GitHub API for issue counts, PR status, CI status per repo
3. Ralph's structured logs for activity timeline

**Dashboard views (planned):**
- **Studio Overview:** All repos, their status, last activity
- **Agent Activity:** Who did what, when (from orchestration logs)
- **Issue Burndown:** Open/closed per repo over time
- **CI Health:** Green/red status per repo
- **Heartbeat Timeline:** When Ralph last checked each repo

---

## 9. BRAND AND QUALITY GUIDELINES

### 9.1 Studio-Level Rules (ALL Games Must Follow)

#### Code Standards
| Rule | Enforcement | Details |
|------|-------------|---------|
| **Branch naming** | CI check (label-enforce workflow) | `squad/{issue-number}-{slug}` |
| **Commit format** | Convention (CONTRIBUTING.md) | `type(scope): description` — types: feat, fix, chore, docs, style, refactor, test |
| **PR template** | Required | `Closes #N` MUST be in body. Agent name in description. |
| **PR review required** | Branch protection | Minimum 1 approval (Jango for T1, Solo+Jango for T2) |
| **CI must pass** | Branch protection | No merge with red CI |
| **No unused infrastructure** | PR review gate (Quality Gate C5) | Every system created must be wired to at least one consumer |

#### Issue Conventions
| Rule | Details |
|------|---------|
| **Labels** | `type:bug`, `type:feature`, `type:chore`, `priority:P0-P3`, `squad:{agent}`, `game:{name}` |
| **TLDR convention** | Every issue comment by an agent starts with a `**TLDR:**` line. Joaquín reads TLDRs only. |
| **Issue template** | Use `.github/ISSUE_TEMPLATE/squad-task.yml` for squad work |
| **Stale issue cleanup** | Issues untouched for 14 days get `status:stale` label (via workflow) |

#### README Structure (All Repos)
Every FFS repo README must include:
1. **Game/tool name + one-line description**
2. **Play/demo link** (GitHub Pages or equivalent)
3. **Screenshot or GIF** (visual-first — Principle #4: Ship the Playable)
4. **Tech stack badge(s)**
5. **"Part of First Frame Studios"** with link to hub repo
6. **Development section** (how to run locally, how to contribute)
7. **Squad section** (team members, how issues work)

#### Visual Identity
| Element | Standard |
|---------|----------|
| **Studio name** | "First Frame Studios" (always full name in READMEs and about pages) |
| **Tagline** | "Forged in Play" (optional, for marketing materials) |
| **Repo descriptions** | Include "First Frame Studios" or "FFS" for discoverability |
| **Dev Diary branding** | `🔥 Dev Diary #X:` format (Mace's established convention) |

### 9.2 How Are These Enforced?

| Mechanism | What It Enforces | Where |
|-----------|-----------------|-------|
| **Upstream sync** | Identity, principles, quality gates | All game repos (via .squad/upstream/) |
| **GitHub Actions workflows** | Branch naming, label enforcement, stale issues, CI, heartbeat | Per repo (copied from hub templates) |
| **PR review** | Code quality, commit format, PR template, TLDR | Jango reviews all PRs |
| **Ceremonies** | Process adherence, retrospective lessons | Solo/Mace facilitate |
| **Agent charters** | Domain expertise, skill references, self-improvement protocol | .squad/agents/{name}/charter.md |
| **CONTRIBUTING.md** | Workflow documentation, branch naming, commit format, label system | Per repo (synced from hub template) |

### 9.3 What's NOT Standardized (Game Autonomy)

Games have full freedom over:
- Art style and visual direction (per-game identity)
- Tech stack choice (HTML/Canvas, Vite/TS/PixiJS, future engines)
- Game-specific mechanics and design decisions
- Internal file structure and module organization
- Game-specific CI/CD beyond the baseline
- Marketing and community engagement approach

---

## Summary: The Three Laws of FFS Governance

1. **Games are autonomous, Hub is authoritative.** Games run their own sprints, merge their own PRs, and manage their own issues. The Hub owns identity, skills, quality standards, and team composition.

2. **Everything escalates by tier, nothing escalates by default.** T0 auto-approves. T1 goes to Jango. T2 goes to Solo. T3 goes to Joaquín. When in doubt, check the tier table.

3. **Knowledge flows up and down.** Patterns discovered in games flow UP to hub skills. Identity and standards flow DOWN via upstream sync. Ralph watches everything. The monitor shows everything. Nothing is siloed.

---

## Approval

This document requires Founder approval (T3) to become active.

**To approve:** Comment on the Hub issue with "APPROVED" or "APPROVED WITH CHANGES: {details}".

**Once approved:**
- This document moves from `.squad/decisions/inbox/` to `.squad/decisions/`
- All game repos receive a sync with the new governance rules
- routing.md and team.md are updated to reference this document
- Mace adds ceremony schedule to project board

---

*Written by Solo (Lead / Chief Architect) — First Frame Studios*  
*"The studio grows when the rules are clear enough to follow and flexible enough to not need exceptions."*

---

## 2026-03-11T14:28: User Directive — Auto-Delete Branches + Code Review Rulesets

**By:** Joaquín (via Copilot)  
**What:** When creating repos, always enable "Automatically delete head branches" and set up rulesets for code review.  
**Why:** User request — captured for team memory. Ensures clean branch hygiene and enforced PR reviews across all FFS repos.

---

## 2026-03-11: ComeRosquillas Ghost AI Architecture Decision

**Date:** 2026-03-11  
**Author:** Tarkin (Enemy/Content Designer)  
**Issue:** #7 — Improve ghost AI with difficulty curve and personality  
**Status:** ✅ Implemented (PR #11)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
Ghost AI in ComeRosquillas was functional but all four villains behaved nearly identically (classic Pac-Man Blinky/Pinky/Inky/Clyde targeting with no personality feel). No difficulty scaling beyond minimal speed increase.

**Decision:**
Implement personality-based targeting through the existing `getChaseTarget()` method + random direction overrides in `moveGhost()`, plus a 0..1 difficulty ramp that scales 6 parameters across 9 levels.

**Ghost Personality Mapping:**
- Burns → Ambush (targets ahead of Homer)
- Bob Patiño → Aggressive (direct chase, speed bonus)
- Nelson → Patrol/Guard (zone defense with proximity trigger)
- Snake → Erratic (random directions + random targets)

**Difficulty Scaling Parameters:**
Ghost speed, fright duration, scatter/chase time ratios, ghost house exit delays, frightened ghost speed, personality aggression values — all driven by single `getDifficultyRamp()` function.

**Rationale:**
1. Personality through target selection keeps one unified `moveGhost()` — no per-ghost state machines needed for a Pac-Man clone
2. Difficulty ramp as 0..1 float makes all scaling parameters easy to tune from one place
3. All changes confined to `js/game-logic.js` per the modularization architecture (Chewie's decision)

**Impact on other agents:**
- Lando: Scoring/progression unaffected — ghost point values unchanged
- Chewie: Engine untouched — no renderer or audio changes
- Wedge: UI/HUD untouched

---

## 2026-03-11: ComeRosquillas Audio Architecture (Greedo)

**Date:** 2026-03-11  
**Author:** Greedo (Sound Designer)  
**Issue:** #8 — Sound effects variety and improved music  
**PR:** #12  
**Repo:** jperezdelreal/ComeRosquillas

**Decision:**

Implemented mix bus architecture (sfxBus + musicBus → compressor → destination) and expanded procedural audio to 8 SFX types with variation systems. All sounds procedural via Web Audio API — no external audio files.

**Key Choices:**

1. **Mix bus with compressor:** DynamicsCompressor on master prevents clipping when SFX and music overlap. This is zero-cost and should be standard on all projects.
2. **Variation via cycling + pitch spread:** Chomp cycles through 4 patterns with ±8% random pitch. Death randomly picks from 3 variants. Ghost-eat pitch escalates with combo. These techniques prevent repetition fatigue without adding complexity.
3. **Backward-compatible API:** `play(type, data)` accepts optional second parameter. Existing `play('chomp')` calls work unchanged. Only 2 lines changed in game-logic.js.
4. **Smooth mute transitions:** `linearRampToValueAtTime` instead of hard gain cuts. Prevents audio pops.

**Impact on Other Agents:**

- **Lando/Tarkin:** If adding new game events (bonus collect, combo chain), call `this.sound.play('newType')` and add a case in audio.js. The API pattern is established.
- **Chewie:** Bus architecture is initialized in SoundManager constructor. No engine changes needed.
- **Wedge:** If adding audio settings UI, use `toggleMute()` for music and the bus gain values for volume sliders.

---

## 2026-03-11: ralph-watch README ASCII-safe and v2-accurate

**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Issue:** #152

**Context:**
tools/README.md was out of date -- it documented ralph-watch v1 defaults (single repo) and omitted v2 features (failure alerts, activity monitor, metrics parsing, multi-repo).

**Decision:**
Rewrote README to accurately reflect ralph-watch v2:
- Default `-Repos` is all 4 FFS repos, not just `.`
- Documented failure alerts (alerts.json after 3+ consecutive failures)
- Documented activity monitor (background runspace)
- Documented metrics parsing (issues closed, PRs merged/opened)
- Added prerequisites section (gh CLI, copilot extension)
- All text ASCII-safe (no emojis, no Unicode dashes) for PS 5.1 compatibility

**Impact:**
- Any agent or human reading tools/README.md now gets accurate activation instructions
- Startup is one command: `.\tools\ralph-watch.ps1`

---

## 2026-03-11: Flora Architecture — Module Structure & Patterns

**Author:** Solo (Lead Architect)  
**Date:** 2026-03-11  
**Repo:** jperezdelreal/flora  
**PR:** #2  
**Status:** PROPOSED (awaiting merge)

**Context:**

Flora is FFS's second game — a cozy gardening roguelite built on Vite + TypeScript + PixiJS v8. Needed a clean architecture from day one to avoid the monolithic anti-pattern that plagued ComeRosquillas (1636 LOC game.js) and firstPunch (695 LOC gameplay.js).

**Decision:**

### Module Structure (7 modules)

| Module | Responsibility | Rules |
|--------|---------------|-------|
| `core/` | SceneManager, EventBus, (future: input, asset loader) | Owns the game loop |
| `scenes/` | Individual game screens (boot, menu, garden, etc.) | One active at a time |
| `entities/` | Game objects (plants, player, tools) | Scene-agnostic |
| `systems/` | ECS-lite update loops (growth, weather, inventory) | Communicate via EventBus |
| `ui/` | HUD, menus, dialogs | Subscribe to events, never mutate state |
| `utils/` | Math, RNG, helpers | Pure functions, no imports from other src/ modules |
| `config/` | Constants, balance values, tuning | Pure data, no side effects |

### Key Patterns

1. **Scene-Based Architecture** — All game states are Scenes managed by SceneManager. One active at a time. Clean init/update/destroy lifecycle.

2. **ECS-Lite** — Not a full Entity-Component-System framework. Lightweight systems that iterate typed entity collections. Keeps complexity proportional to game scope.

3. **Typed Event Bus** — Pub-sub with EventMap type for compile-time safety. Prevents circular dependencies between systems, UI, and scenes.

4. **PixiJS v8 Patterns** — Async `Application.init()`, `app.canvas` (not `app.view`), `Text({text, style})` object syntax, `Assets.load()` API.

### Dependency Direction

```
main.ts → core → scenes → entities/systems/ui
config ← imported by anything
utils ← imported by anything
EventBus ← imported by scenes, systems, ui
```

**Rationale:**

- Modular from day one prevents the monolith anti-pattern (lesson from ComeRosquillas and firstPunch)
- Scene-based is simpler than FSM for a small-medium game
- ECS-lite avoids framework overhead while keeping separation of concerns
- Event bus is the standard decoupling pattern for game modules

**Implications:**

- All new features go in the appropriate module (no cross-cutting monoliths)
- New scenes implement the Scene interface
- New systems implement the System interface
- Inter-module communication goes through EventBus, not direct imports

---

## 2026-03-11: Flora Game Design Document (GDD v1.0)

**Date:** 2026-03-11  
**Decided By:** Yoda (Game Designer)  
**Status:** READY FOR ARCHITECTURE REVIEW  
**Artifact:** `jperezdelreal/flora/docs/GDD.md` (PR #1)

### Decision Summary

**What:** Approved Flora GDD v1.0 as the design foundation for Sprint 0 development.

**Why:** 
1. Aligns with "cozy first, challenge second" directive from Joaquín
2. MVP scope is realistic for AI-developed game (12 plants, one-season loop, basic hazards)
3. Roguelite elements are light (discovery-driven, not punishment-driven)
4. Design decisions support tech stack (Vite + TypeScript + PixiJS v8)
5. Clear progression loop ensures engagement without grinding

**Scope:** 
- Sprint 0 MVP: 8×8 garden, 12 plants, 20–40 min per run, 3–5 runs per session
- Post-MVP deferred: garden expansion, complex synergies, cosmetics, seasonal variety, save/load

### Key Design Pillars

1. **Cozy but Intentional** — Relaxing tone, meaningful choices, no punishment
2. **Every Run is Different** — Randomized seeds, unique scenarios each time
3. **Grow & Discover** — Incremental unlocks, botanical encyclopedia grows with playtime
4. **The Garden Reflects You** — Aesthetic choices are expressive; memories persist

### Core Loop

**One Run = 20–40 minutes**

1. **Seeding (3–5 min):** Choose from 4–6 random plants; arrange on 8×8 plot
2. **Tending (12–25 min):** Water, harvest, manage pests, adapt to weather (12 in-game days)
3. **Harvest & Reflection (2–5 min):** Collect new seeds, update encyclopedia, unlock rewards

**Each Season Resets:** Garden, weather, available seeds, plant states  
**Each Season Persists:** Encyclopedia, tools, garden upgrades, achievements

### Meta-Progression (Session Level)

Unlocks per run:
- **Runs 1–2:** Common seeds (8–10), basic tools
- **Runs 3–5:** Rare seeds, soil upgrades, compost system
- **Runs 6–10:** Heirloom seeds, garden structures, advanced tools

After 5–10 runs, player feels measurably more powerful and has discovered 15–20 unique plants.

### Garden Mechanics

#### Plant System
- **Growth Time:** 3–8 in-game days (varies per plant)
- **Water Need:** 1–5 waterings per cycle
- **Health:** 0–100% (affected by water, pests, weather)
- **Yield:** 1–3 seeds per harvest + bonus fruit (aesthetic)

#### Hazards (All Solvable, No Combat)
- **Pests:** Appear on day 6–8; player removes manually or uses tools
- **Drought:** Increases watering frequency (Summer hazard)
- **Frost:** Sensitive plants wilt if not harvested in time (Winter hazard)
- **Weeds:** Occupy space or slow growth; removable or compostable

### Art & Audio Direction

**Art:**
- Tilebase pixel art (16×16 grid, 32×32 plants/player)
- Warm earthy palette (soil browns, greens, sky blues, accent flower colors)
- Seasonal shifts (spring pastels → summer gold → fall rust → winter cool)
- Smooth growth animations; satisfying harvest pop

**Audio:**
- Ambient loops (60–90 BPM, cozy lo-fi style)
- Soft SFX (water pour, soil tap, harvest chime, pest rustle)
- No stressful cues; total mix encourages relaxation

### MVP Scope (Hard Boundary for Sprint 0)

#### IN MVP
- One-season loop (12 in-game days)
- 12 plant types (4 common, 4 uncommon, 2 rare, 2 heirloom)
- 8×8 garden plot
- Hazards: pests, drought
- Tools: basic watering can, hand, pest remover
- Encyclopedia (discover/unlock mechanic)
- Soil quality (basic feedback)
- One tool unlock per first harvest
- One plant unlock per season completion

#### OUT of MVP (Deferred)
- Garden expansion
- Complex synergies (polyculture bonus, shade mechanic)
- Advanced tools (soil tester, compost bin, trellis)
- Seasonal variety (MVP = same season all runs)
- Cosmetics / achievements
- Save/load (single session only)
- Mobile optimization

### Success Criteria

Players will:
1. ✓ Complete 3–5 runs in one session
2. ✓ Discover at least 1 new plant per run
3. ✓ Feel harvesting is rewarding (audio + visual works)
4. ✓ Play for 30–40 minutes without rushing
5. ✓ See encyclopedia growth; feel progression
6. ✓ No frustration; hazards solvable by restart

### Next Steps

1. **Architecture Review (Solo):** Validate tech stack feasibility; suggest data structures
2. **Sprint 0 Planning (Jango, Squad):** Timeline, asset needs, task breakdown
3. **Art Spike:** Plant sprite concepts (16×16, growth frames)
4. **Audio Spike:** Ambient track (90 sec loop) + 5 SFX

### Design Philosophy Reinforced

> *"Cozy First, Challenge Second."*

Every design decision prioritizes:
1. **Player agency** — Hazards are puzzles, not punishments
2. **Discovery** — Unlocking feels like loot drops in traditional roguelikes
3. **Accessibility** — Failed run = "next season, I'll try different" not "I lost progress"
4. **Visible progress** — Encyclopedia fills; tools appear; garden expands

**Approved by:** Yoda, Game Designer  
**For:** First Frame Studios Squad  
**Date:** 2026-03-11

**Related Decisions:**
- **Studio Philosophy:** "Player Hands First" (session 7)
- **Genre Pillars:** "Game Feel is Differentiator" (2026-03-08)
- **Tech Stack:** Vite + TypeScript + PixiJS v8 (from now.md)
- **Scope Governance:** MVP-lock principle (from Mace's Sprint 0 plan, Ashfall)

---

### 2026-03-11T14:28: User directive
**By:** Joaquín (via Copilot)
**What:** When creating repos, always enable "Automatically delete head branches" and set up rulesets for code review.
**Why:** User request — captured for team memory. Ensures clean branch hygiene and enforced PR reviews across all FFS repos.

---

# Decision: ComeRosquillas Audio Architecture (Greedo)

**Date:** 2026-03-11  
**Author:** Greedo (Sound Designer)  
**Issue:** #8 — Sound effects variety and improved music  
**PR:** #12  
**Repo:** jperezdelreal/ComeRosquillas

## Decision

Implemented mix bus architecture (sfxBus + musicBus → compressor → destination) and expanded procedural audio to 8 SFX types with variation systems. All sounds procedural via Web Audio API — no external audio files.

## Key Choices

1. **Mix bus with compressor:** DynamicsCompressor on master prevents clipping when SFX and music overlap. This is zero-cost and should be standard on all projects.
2. **Variation via cycling + pitch spread:** Chomp cycles through 4 patterns with ±8% random pitch. Death randomly picks from 3 variants. Ghost-eat pitch escalates with combo. These techniques prevent repetition fatigue without adding complexity.
3. **Backward-compatible API:** `play(type, data)` accepts optional second parameter. Existing `play('chomp')` calls work unchanged. Only 2 lines changed in game-logic.js.
4. **Smooth mute transitions:** `linearRampToValueAtTime` instead of hard gain cuts. Prevents audio pops.

## Impact on Other Agents

- **Lando/Tarkin:** If adding new game events (bonus collect, combo chain), call `this.sound.play('newType')` and add a case in audio.js. The API pattern is established.
- **Chewie:** Bus architecture is initialized in SoundManager constructor. No engine changes needed.
- **Wedge:** If adding audio settings UI, use `toggleMute()` for music and the bus gain values for volume sliders.

---

# Decision: ralph-watch README ASCII-safe and v2-accurate

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #152

## Context
tools/README.md was out of date -- it documented ralph-watch v1 defaults (single repo) and omitted v2 features (failure alerts, activity monitor, metrics parsing, multi-repo).

## Decision
Rewrote README to accurately reflect ralph-watch v2:
- Default `-Repos` is all 4 FFS repos, not just `.`
- Documented failure alerts (alerts.json after 3+ consecutive failures)
- Documented activity monitor (background runspace)
- Documented metrics parsing (issues closed, PRs merged/opened)
- Added prerequisites section (gh CLI, copilot extension)
- All text ASCII-safe (no emojis, no Unicode dashes) for PS 5.1 compatibility

## Impact
- Any agent or human reading tools/README.md now gets accurate activation instructions
- Startup is one command: `.\tools\ralph-watch.ps1`

---

# Decision: Flora Architecture — Module Structure & Patterns

**Author:** Solo (Lead Architect)  
**Date:** 2026-03-11  
**Repo:** jperezdelreal/flora  
**PR:** #2  
**Status:** PROPOSED (awaiting merge)

## Context

Flora is FFS's second game — a cozy gardening roguelite built on Vite + TypeScript + PixiJS v8. Needed a clean architecture from day one to avoid the monolithic anti-pattern that plagued ComeRosquillas (1636 LOC game.js) and firstPunch (695 LOC gameplay.js).

## Decision

### Module Structure (7 modules)

| Module | Responsibility | Rules |
|--------|---------------|-------|
| `core/` | SceneManager, EventBus, (future: input, asset loader) | Owns the game loop |
| `scenes/` | Individual game screens (boot, menu, garden, etc.) | One active at a time |
| `entities/` | Game objects (plants, player, tools) | Scene-agnostic |
| `systems/` | ECS-lite update loops (growth, weather, inventory) | Communicate via EventBus |
| `ui/` | HUD, menus, dialogs | Subscribe to events, never mutate state |
| `utils/` | Math, RNG, helpers | Pure functions, no imports from other src/ modules |
| `config/` | Constants, balance values, tuning | Pure data, no side effects |

### Key Patterns

1. **Scene-Based Architecture** — All game states are Scenes managed by SceneManager. One active at a time. Clean init/update/destroy lifecycle.

2. **ECS-Lite** — Not a full Entity-Component-System framework. Lightweight systems that iterate typed entity collections. Keeps complexity proportional to game scope.

3. **Typed Event Bus** — Pub-sub with EventMap type for compile-time safety. Prevents circular dependencies between systems, UI, and scenes.

4. **PixiJS v8 Patterns** — Async `Application.init()`, `app.canvas` (not `app.view`), `Text({text, style})` object syntax, `Assets.load()` API.

### Dependency Direction

main.ts → core → scenes → entities/systems/ui
config ← imported by anything
utils ← imported by anything
EventBus ← imported by scenes, systems, ui

## Rationale

- Modular from day one prevents the monolith anti-pattern (lesson from ComeRosquillas and firstPunch)
- Scene-based is simpler than FSM for a small-medium game
- ECS-lite avoids framework overhead while keeping separation of concerns
- Event bus is the standard decoupling pattern for game modules

## Implications

- All new features go in the appropriate module (no cross-cutting monoliths)
- New scenes implement the Scene interface
- New systems implement the System interface
- Inter-module communication goes through EventBus, not direct imports

---

### ComeRosquillas Ghost AI Architecture Decision
**Date:** 2026-03-11  
**Author:** Tarkin (Enemy/Content Designer)  
**Issue:** #7 — Improve ghost AI with difficulty curve and personality  
**Status:** ✅ Implemented (PR #11)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
Ghost AI in ComeRosquillas was functional but all four villains behaved nearly identically (classic Pac-Man Blinky/Pinky/Inky/Clyde targeting with no personality feel). No difficulty scaling beyond minimal speed increase.

**Decision:**
Implement personality-based targeting through the existing `getChaseTarget()` method + random direction overrides in `moveGhost()`, plus a 0..1 difficulty ramp that scales 6 parameters across 9 levels.

**Ghost Personality Mapping:**
- Burns → Ambush (targets ahead of Homer)
- Bob Patiño → Aggressive (direct chase, speed bonus)
- Nelson → Patrol/Guard (zone defense with proximity trigger)
- Snake → Erratic (random directions + random targets)

**Difficulty Scaling Parameters:**
Ghost speed, fright duration, scatter/chase time ratios, ghost house exit delays, frightened ghost speed, personality aggression values — all driven by single `getDifficultyRamp()` function.

**Rationale:**
1. Personality through target selection keeps one unified `moveGhost()` — no per-ghost state machines needed for a Pac-Man clone
2. Difficulty ramp as 0..1 float makes all scaling parameters easy to tune from one place
3. All changes confined to `js/game-logic.js` per the modularization architecture (Chewie's decision)

**Impact on other agents:**
- Lando: Scoring/progression unaffected — ghost point values unchanged
- Chewie: Engine untouched — no renderer or audio changes
- Wedge: UI/HUD untouched

---

# Decision: Flora CI/CD Pipeline Architecture

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Scope:** Flora repo (jperezdelreal/flora)
**Issue:** #11

## Decision

Flora uses a two-workflow CI/CD architecture:

1. **ci.yml** -- Runs on all pushes and PRs to main/develop. Type-checks (tsc --noEmit), builds (vite build), uploads dist/ artifact.
2. **deploy.yml** -- Runs only on push to main. Builds and deploys to GitHub Pages via actions/deploy-pages@v4.

Vite base set to '/flora/' (with trailing slash) for GitHub Pages path resolution.

## Rationale

- **deploy-pages@v4** over gh-pages branch push: Cleaner permissions model, matches ComeRosquillas pattern, no need for deploy keys or PATs.
- **Separated CI from deploy**: PRs get fast validation without triggering deploys. Deploy only fires on main merge.
- **Type-check step**: Catches TypeScript errors before build, fails fast.
- **Artifact upload in CI**: Allows downloading and inspecting build output from any PR.

## Impact

- All FFS web games now use the same deploy-pages pattern
- Merge PR #12 and enable GitHub Pages (Source: GitHub Actions) in repo settings

---

# Decision: Flora Core Engine Architecture

**Date:** 2025-07-16  
**Author:** Chewie (Engine Developer)  
**Issue:** #3 — Core Game Loop and Scene Manager Integration  
**Status:** ✅ Implemented (PR #13)  
**Repo:** jperezdelreal/flora

## Context

Flora needed foundational engine infrastructure before any gameplay could be built. The scaffold provided stubs for SceneManager and EventBus but no game loop, input handling, or asset loading.

## Decisions

### 1. Fixed-Timestep Game Loop (Accumulator Pattern)
- GameLoop wraps PixiJS Ticker but steps in fixed 1/60s increments via time accumulator
- Max 4 fixed steps per frame prevents spiral of death on lag spikes
- Provides `frameCount` for deterministic logic and `alpha` for render interpolation
- **Rationale:** Deterministic state updates enable future save/replay/netcode. Variable-delta game logic causes desync bugs.

### 2. SceneContext Injection (No Global Singletons)
- Scenes receive `SceneContext = { app, sceneManager, input, assets }` in `init()` and `update()`
- No global `window.game` or singleton pattern
- **Rationale:** Explicit dependencies are testable, refactorable, and don't create hidden coupling.

### 3. Input Edge Detection Per Fixed Step
- `InputManager.endFrame()` clears pressed/released sets after each fixed-step update
- Raw key state persists across frames; edges are consumed once
- **Rationale:** Variable frame rates can cause missed inputs if edges are cleared per render frame instead of per logic step.

### 4. Scene Transitions via Graphics Overlay
- Fade-to-black using a Graphics rectangle with animated alpha (ease-in-out)
- No render-to-texture or extra framebuffers
- **Rationale:** Simple, GPU-efficient, works on all PixiJS backends (WebGL, WebGPU, Canvas).

## Alternatives Rejected
1. **Raw Ticker.deltaTime for game logic** — Non-deterministic, causes physics/timing bugs
2. **Global singleton for input/assets** — Hidden dependencies, harder to test
3. **CSS transitions for scene fades** — Breaks when canvas is fullscreen, not composable with game rendering


---

# PR Review Round 1 — CI Workflow Maintenance Decision

**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Context:** Reviewed 3 PRs across Flora and ComeRosquillas repos  
**Decision Status:** Team-wide policy

## Problem

ComeRosquillas PR #14 (multiple maze layouts) has CI failures despite correct implementation. Root cause: CI workflow (`.github/workflows/ci.yml`) checks for old monolithic structure (`js/game.js`) but the codebase was modularized in PR #10 (5 modules: config.js, audio.js, renderer.js, game-logic.js, main.js). The CI workflow was never updated to match the new structure.

## Decision

**CI workflows must be updated in the same PR that introduces structural changes.**

When a PR modifies project structure (file moves, modularization, build system changes), the author must:
1. Update CI workflow checks to match the new structure
2. Update any path references in workflows (artifact paths, script checks, HTML validation)
3. Verify CI passes before marking the PR ready for review

## Rationale

1. **Prevents Silent Breakage** — If modularization PR merges without CI updates, subsequent PRs fail with confusing errors unrelated to their changes
2. **Atomic Changes** — Structure + CI updates belong together logically (same architectural change)
3. **Review Clarity** — Reviewers can see the full impact of structural changes (code + tooling) in one PR
4. **Rollback Safety** — If a structural change needs to be reverted, the CI workflows revert with it

## Example: ComeRosquillas Modularization

**PR #10 (Modularization):**
- Split `js/game.js` (1789 lines) → 5 modules (config.js, audio.js, renderer.js, game-logic.js, main.js)
- Updated `index.html` to load modular scripts
- ❌ **Did NOT update** `.github/workflows/ci.yml` (still checked for `js/game.js`)

**PR #14 (Maze Layouts):**
- Added 4 maze templates to `config.js`
- Updated `game-logic.js` to rotate mazes
- ✅ Code quality excellent, spec compliance perfect
- ❌ CI fails: workflow checks for `js/game.js` reference in HTML (no longer exists)

**Impact:**
- PR #14 blocked on CI fix unrelated to maze implementation
- Reviewer (Jango) had to diagnose CI workflow mismatch
- Developer must add CI fix to maze PR or create separate PR

## Required CI Update for ComeRosquillas

Update `.github/workflows/ci.yml`:

```yaml
# Line 36-44: HTML structure check
- name: Check HTML structure
  run: |
    # Check for required HTML elements
    if ! grep -q '<canvas id="gameCanvas">' index.html; then
      echo "❌ Missing gameCanvas element!"
      exit 1
    fi
    
    # Check for modular script structure (not monolithic game.js)
    if ! grep -q 'src="js/config.js"' index.html; then
      echo "❌ Missing config.js script reference!"
      exit 1
    fi
    
    if ! grep -q 'src="js/main.js"' index.html; then
      echo "❌ Missing main.js script reference!"
      exit 1
    fi

# Lines 77-93: Verify game assets
- name: Verify game assets
  run: |
    # Check for required directories
    if [ ! -d "js" ]; then
      echo "❌ js/ directory not found!"
      exit 1
    fi
    
    # Check for core modular files
    if [ ! -f "js/config.js" ]; then
      echo "❌ js/config.js not found!"
      exit 1
    fi
    
    if [ ! -f "js/game-logic.js" ]; then
      echo "❌ js/game-logic.js not found!"
      exit 1
    fi
    
    if [ ! -f "js/main.js" ]; then
      echo "❌ js/main.js not found!"
      exit 1
    fi
```

## Alternatives Considered

1. **Separate CI Update PR** — Creates extra PR overhead, doesn't prevent breakage
2. **Manual CI Bypass** — Unsafe, breaks automation trust
3. **Post-Merge CI Fix** — Main branch broken between merge and fix

## Consequences

✅ **Benefits:**
- CI always matches codebase structure
- Structural PRs are fully self-contained
- Reviewers see complete architectural impact
- Subsequent PRs don't inherit structural CI failures

⚠️ **Tradeoffs:**
- Structural PRs have higher complexity (code + tooling changes)
- Requires PR authors to understand CI workflows
- May need CI workflow documentation for developers

## Action Items

1. **ComeRosquillas PR #14:** Developer adds CI workflow fix to the PR, re-runs CI, then merge
2. **Squad Documentation:** Add "CI Workflow Maintenance" section to contribution guidelines
3. **PR Template:** Add checklist item: "If this PR changes project structure, update CI workflows"
4. **Ralph Watch:** Add CI workflow check to PR review automation (detect structure changes, flag missing CI updates)

## Related Decisions

- **2026-03-11: ComeRosquillas CI Pipeline Strategy** — Lightweight CI for vanilla JS games (no bundler)
- **2026-03-11: ComeRosquillas Modularization Architecture** — 5-module split with clean DAG

## Status

**ACTIVE** — Policy applies to all future PRs across all FFS repos (FirstFrameStudios, ComeRosquillas, Flora, ffs-squad-monitor)




---

## Archived: decisions/decisions.md (pre-2026-03-11 First Punch/Ashfall era)


# Team Decisions

## Decision: Game Vision & Design Document

**Author:** Yoda (Game Designer)  
**Date:** 2025  
**Type:** Design Authority  
**Status:** Proposed  
**Artifact:** `.squad/analysis/game-design-document.md`

---

### Summary

Created the comprehensive Game Design Document (GDD) for firstPunch — the team's north star for all design and implementation decisions.

### Key Decisions

#### Vision
firstPunch is a browser-based game beat 'em up where comedy IS the combat. Players should laugh, feel powerful, and immediately want to try the next character. Instant-play browser design means zero friction, 5-7 minute levels, and session-friendly pacing.

#### Four Design Pillars
1. **Comedy as a Core Mechanic** — Humor is in the gameplay systems (taunts, Ugh! moments, game-rated combo meter), not just cosmetic.
2. **Accessible Depth** — Button-mashers have fun; combo masters have a different kind of fun. Streets of Rage 4 principle.
3. **Team Synergy** — Co-op mechanics reward playing as the team together (team attacks, proximity buffs, team super).
4. **Downtown Is a Character** — Environments are interactive playgrounds with landmark gags, destructibles, and hazards.

#### Core Combat
- **PPK combo** as the bread-and-butter (42 damage/1.1s)
- **Health-cost specials** with recovery-by-attacking (SoR2/SoR4 model)
- **Grab/throw system** (Turtles in Time influence)
- **Dodge roll with i-frames** (modern standard)
- **Super meter** filled by damage and taunts
- **Jump attacks rebalanced** with landing lag to prevent air-spam dominance (balance analysis finding)

#### Characters (4 planned, Brawler first)
- Brawler: Power/All-Rounder, Rage Mode, Belly Bounce
- Kid: Speed, Skateboard Dash, Slingshot ranged, alter-ego super
- Defender: Range, Purse Swing, Hair Whip, Maternal Instinct passive
- Prodigy: Technical/CC, Saxophone Blast, Intellect Advantage dodge, Activist Rally super

#### game-Specific Mechanics
- **Rage Mode** (eat 3 donuts → Brawler power-up, creates heal vs. rage dilemma)
- **Ugh! Moments** (funny failure states at every level)
- **Couch Gag loading screens** (randomized, collectible transitions)
- **Downtown landmarks** as interactive combat elements
- **game food** as themed health pickups (Pink Donut, Burger Joint, Fire Cocktail)
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

**Character Art (5 items):** P2-4 Brawler redesign, P1-9 Brawler walk cycle (art side), P1-10 Brawler attack animations (art side), P1-11 Enemy death animation, EX-B7 Consistent entity rendering style.

**Environment Art (3 items):** P2-5 Background overhaul, EX-B6 Foreground parallax layer, EX-B8 Environmental background animations.

**VFX (5 items):** P1-2 Hit impact VFX, EX-B3 Enemy attack telegraph VFX, EX-B4 Attack motion trails, EX-B5 Enemy spawn-in effects, P2-9 KO text effects.

**Art Direction (2 items):** EX-B1 Art direction & color palette, EX-B2 Character ground shadows.

**Plus shared items:** P2-10 Animated title screen (with Wedge), P2-13 Score pop-ups.

#### Analysis

The visual modernization plan alone is **62KB** — a massive document covering Brawler's stubble rendering, enemy proportions, background parallax layers, particle effects, and more. This is not a part-time gig. Each of the 4 proposed sub-roles maps cleanly to a real workload cluster:

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
5. **Boba's charter update:** Change from "VFX/Art Specialist" to "Art Director." Responsibilities shift from production to direction + review + style enforcement + selective production on high-complexity items (e.g., Brawler's final design is too important to delegate to a new hire).

#### Risk: Boba Becomes a Bottleneck

If every visual change needs Art Director review, Boba becomes a chokepoint. Mitigation: Boba reviews the first 2-3 items from each new artist, then shifts to spot-check reviews. Trust builds. The art direction document serves as the "always-available reviewer" — if the work follows the guide, it's probably fine.

### 3. Game Designer Role

#### Is It Genuinely Needed?

**Yes, and the need is already visible.** Here's what's currently happening without a Game Designer:

- **Solo (Lead) is implicitly doing game design.** The gap analysis, the 52-item backlog, the phased execution plan, the priority rankings — these are all game design decisions made by a project lead. This works at small scale but doesn't scale.
- **Tarkin (Enemy/Content Dev) is doing content design.** Wave composition rules (EX-T2), encounter pacing curves (EX-T3), boss phase frameworks (EX-T5) — these are game design decisions embedded in a content dev role.
- **Ackbar (QA) is doing balance design.** DPS analysis (EX-A5), frame data documentation (EX-A2) — balance tuning IS game design.
- **Nobody owns the coherent vision.** Is firstPunch a casual brawler or a technical fighter? How hard should it be? What's the target session length? What emotions should each wave evoke? These questions have no designated owner.

#### What a Game Designer Does Day-to-Day

| Activity | Frequency | Example |
|----------|-----------|---------|
| Maintain GDD | Ongoing | "Brawler's punch should feel heavy — 4 frame startup, 8 active, 12 recovery. Compare to enemy punch: 6/6/8." |
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
Boba: [art direction] → [Brawler redesign] → [backgrounds] → [VFX] → [enemies]
                       (all sequential — one person)
```

**After (3 parallel art pipelines + oversight):**
```
Boba (Art Dir):   [style guide] → [review] → [review] → [review] → ...
Env Artist:       [backgrounds] → [parallax] → [props] → [level 2 bg] → ...
VFX Artist:       [hit VFX] → [telegraphs] → [trails] → [spawn FX] → ...
Char Artist:      [Brawler redesign] → [walk cycle] → [enemy art] → [boss] → ...
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

1. **Phase A — Game Designer (Yoda):** Onboard first. Before adding 3 artists, we need the GDD and design specs they'll work from. Yoda writes the GDD, defines Brawler's target feel, specifies enemy personality profiles, and sets the difficulty curve. ~1 session to establish.

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

## Decision: FLUX API Sprite Generation PoC — APPROVED

**Author:** Nien (Character Artist)  
**Date:** 2026-03-09  
**Status:** COMPLETED — Ready for Production Pipeline  
**Artifact:** `games/ashfall/assets/poc/` (32 images)

---

### Summary

FLUX API sprite generation pipeline validated end-to-end. All 32 PoC images (4 hero frames/scenes + 28 Kael sprite frames) generated successfully and saved to production asset directory. Pipeline architecture approved for full-scale production implementation.

### Key Findings

#### FLUX 2 Pro (Hero Frames & Environmental Assets)
- **Output Quality:** High-fidelity at 1024×1024 (characters) and 1920×1080 (scenes)
- **Rate Limit:** 15s between requests (manageable, ~240 requests/hour)
- **Use Case:** Recommended for hero frames, title screens, background assets
- **4/4 Assets Generated:**
  - `kael_hero.png` — Character reference frame (658 KB)
  - `rhena_hero.png` — Alternative character frame (814 KB)
  - `embergrounds_bg.png` — Volcanic stage background (2,951 KB)
  - `title_screen.png` — Game title screen (2,609 KB)

#### FLUX 1 Kontext Pro (Sprite Frame Generation)
- **Output Quality:** Good frame consistency when using hero frame as input_image reference
- **Rate Limit:** 3s between requests (30/min capacity, ~1,800 requests/hour)
- **Production Feasibility:** 1,020-frame full generation possible in ~40 min API time
- **Character Consistency:** Input reference image successfully maintains costume, hair, build, and style across frames
- **Seed Locking:** Per-sequence seed fixing improves frame-to-frame coherence (tested on idle, walk, attack cycles)

#### Sprite Generation Tested (28 frames)
- **Idle Cycle:** 8 frames (seed=1001) — smooth breathing/standing animation
- **Walk Cycle:** 8 frames (seed=2001) — natural locomotion
- **Light Punch Attack:** 12 frames (seed=3001) — startup → active → recovery phases
  - **Content Filter Issues:** 3 retries needed on combat prompts
  - **Resolution:** Rewrite using martial arts terminology ("extending," "kata," "controlled motion") instead of combat language ("punch," "strike," "impact")
  - **Success Rate:** 100% after prompt adjustment

### Production Architecture

**Recommended Pipeline:**

```
1. Hero Frame Generation (FLUX 2 Pro)
   ↓
2. Sprite Frame Batch Generation (FLUX 1 Kontext Pro)
   ↓
3. Post-Processing:
   a) Background Removal (alpha transparency)
   b) Palette Enforcement (color standardization)
   c) PNG Compression (reduction from 680 KB → ~50-100 KB target)
   ↓
4. Sprite Sheet Assembly
   ↓
5. Game Integration & Testing
```

### Technical Constraints & Workarounds

| Constraint | Impact | Workaround |
|-----------|--------|-----------|
| Content filter on combat language | 3 retries for attack frames | Pre-approved prompt vocabulary (martial arts focus) |
| Large file sizes (680 KB avg) | Storage & bandwidth costs | Post-processing compression pipeline required |
| No alpha transparency | Sprites not game-ready | Background removal post-processing step |
| FLUX 2 Pro rate limit (15s) | ~240 images/hour | Acceptable for hero frame generation |
| FLUX 1 Kontext Pro rate limit (3s) | ~1,200 images/hour | Full 1,020-frame run feasible in ~40 min |

### Approved Decisions

1. ✅ **Use FLUX 2 Pro for hero frames** — Quality and consistency justified
2. ✅ **Use FLUX 1 Kontext Pro for sprite batches** — Rate limit and character consistency suitable for production
3. ✅ **Input reference image requirement** — Hero frame as input_image mandatory for character coherence
4. ✅ **Prompt vocabulary control** — Maintain pre-approved word list avoiding content filter triggers
5. ✅ **Post-processing pipeline mandatory** — Background removal, compression, sprite sheet assembly
6. ✅ **Production scaling approved** — Full 1,020-frame generation (~40 min API time) feasible

### Implementation Roadmap

**Phase 1 (Immediate):** Post-processing pipeline specification
- Finalize compression targets (target: 50-100 KB per frame)
- Define sprite sheet layout and assembly automation
- Test on existing 32 PoC images

**Phase 2 (Week 1):** Full character generation
- Generate 1,020 Kael sprite frames (hero frame locked)
- Test animation timing in game engine
- Validate post-processing pipeline

**Phase 3 (Week 2+):** Iterate for additional characters
- Generate hero frames for secondary characters (Rhena, others)
- Sprite frame generation per character (locked hero reference per character)
- Content library expansion

### Outcome

✅ PoC COMPLETE — 32/32 images successfully generated  
✅ Pipeline architecture validated  
✅ Production constraints documented  
✅ Rate limits & API behavior understood  
✅ Content filter workarounds established  
✅ Post-processing requirements specified  
✅ **Ready to move to full production implementation**

---

## Decision: AAA-Level Gap Analysis & Expanded Backlog

**Author:** Solo (Lead)  
**Date:** 2026-06-04  
**Status:** Proposed

---

### What

Comprehensive AAA gap analysis comparing firstPunch's current state against "award-winning browser beat 'em up" standard. Produced a 101-item prioritized backlog (56 new + 45 carried from existing 85) organized into 5 execution phases, plus 8 future/migration items.

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
- **Character Roster (5):** Character select, Kid/Defender/Prodigy playable, unlock system
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
2. **4 playable characters.** Brawler + Kid + Defender + Prodigy. Each follows the speed/power/range archetype triangle from research.
3. **3 levels minimum.** Downtown Streets → City School → Factory. Each with unique boss and environment.
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

- localStorage key is `firstPunch_highScore` — namespaced to avoid collisions if other games share the domain.
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
- firstPunch engine code (1,931 LOC) doesn't transfer — but all architectural knowledge does

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

**The lesson from firstPunch proves this:** The #1 technical debt finding (Session 8) was "214 LOC of unused infrastructure — working systems that aren't wired into anything." The multi-agent-coordination skill (Session 10) identified the core pattern: "agents build infrastructure but don't wire it." A Tool Engineer's explicit job would be closing this gap — building the scaffolding, templates, and automation that ensure new code arrives pre-wired.

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

**Conservative estimate:** 15-25 tooling items in the first Godot project, ongoing maintenance as game scope grows. That's a full role's worth of work, comparable to Tarkin's content workload (18 items in firstPunch).

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

**Distribute across all agents?** No. This is exactly the pattern that produced 214 LOC of unused infrastructure in firstPunch. When everyone is responsible for tooling, nobody is responsible for tooling. The multi-agent-coordination skill explicitly warns against this.

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

---

## Decision: User Directive — Sprite Sheets vs. Procedural Rendering

**Date:** 2026-03-09T18:23Z  
**Author:** joperezd (via Copilot)  
**Type:** Project Direction  
**Status:** ACTIVE

### Summary

AI-assisted pixel art sprite sheets is the preferred approach for character visuals (not bake of `_draw()` output). The founder identified a planning gap: the team should have evaluated `_draw()` visual ceiling in Sprint 0 and planned sprite sheets from the start. This is a research and planning failure that must be prevented in future sprints.

### Key Insight

The `_draw()` procedural approach has a visual quality ceiling that was never assessed. Sprite sheet pixel art should have been the target from day 1. Going forward, evaluate technical ceilings of visual approaches **BEFORE** committing to them.

### Lesson for Future Sprints

- Before committing to a rendering technique, have Boba (Art Director) and Solo (Architect) jointly evaluate the quality ceiling
- **Can this technique reach our visual target?** must be answered in Sprint 0, not discovered in Sprint 2
- AI-generated pixel art with cleanup is the chosen path for character sprites

---

## Decision: Infrastructure Constraint — FLUX Rate Limit

**Date:** 2026-03-09T204055Z  
**Author:** joperezd (via Copilot)  
**Type:** Infrastructure  
**Status:** ACTIVE

### Summary

FLUX 1.1 Pro on Azure AI Foundry has a rate limit of **30 tokens per minute**. All sprite generation planning must account for this hard constraint — batch sizes, timing, and pipeline pacing.

### Impact

This is a hard infrastructure constraint that affects:
- Batch size optimization (10-frame cycles fit within 30 tokens/min)
- Total generation timeline (905 estimated FLUX calls = ~30 hours at rate limit)
- Cost and budget planning (token consumption determines Azure invoice)
- Pipeline architecture (sequential generation required, parallelization not possible)

---

## Decision: Sprite Art Brief for AI-Generated Pixel Art

**Date:** 2026-03-09  
**Decider:** Boba (Art Director)  
**Status:** Proposed (Awaiting Joaquín approval)  
**Scope:** Ashfall sprite generation pipeline

### Context

Ashfall is transitioning from procedural `_draw()` art to pixel art sprites generated by FLUX 1.1 Pro (Azure AI Foundry). This decision establishes the technical and creative parameters for the entire art sprint (~1000 sprite frames).

### Key Decisions

#### 1. Canvas Dimensions: 256×256 px (not 512×512)

**Rationale:**
- FLUX generates cleaner pixel art at 256×256 (less interpolation artifacts)
- In-game render size is ~30×60px → 256×256 provides 4.3× safety margin (sufficient for quality)
- 2× faster iteration cycles (30 sec/frame vs. 60 sec/frame at 512×512)
- Power-of-2 texture size (optimal GPU memory alignment)
- Azure rate limit is 30 tokens/min → smaller canvas = more iterations within budget

**Alternative considered:** 512×512 (Joaquín's suggestion) — viable for special cases (win poses, promotional renders) but overkill for gameplay sprites.

**Recommendation:** Start with 256×256 for all gameplay sprites. Reserve 512×512 for character select portraits and marketing materials only.

#### 2. Frame Generation Strategy: Frame-by-Frame (not Sprite Sheets)

**Rationale:**
- FLUX struggles with multi-frame sprite sheet layouts (misaligned frames, inconsistent spacing)
- Fighting games require precise frame data — active frames, recovery frames must match exact frame counts
- Frame-level control enables surgical iteration (regenerate frame 5 only, not entire 12-frame sequence)
- Character consistency is solvable via strong prompt anchoring (include full character reference in every frame prompt)
- P0 scope is only ~48 frames → 24 minutes generation time at 30 sec/frame (acceptable)

**Workflow:**
1. Generate frame 1 (establishes character visual baseline)
2. Review immediately (validate silhouette, colors, proportions)
3. If frame 1 passes, generate frames 2-N using frame 1 as reference anchor
4. Review sequence in Godot AnimationPlayer
5. Regenerate any frames with consistency breaks

#### 3. Palette Enforcement: Hex-Guided Prompts + Optional Post-Recolor

**Rationale:**
- FLUX does not guarantee exact hex colors (interprets color descriptions, drifts ±10-15%)
- Including hex values in prompts (e.g., "grey-white gi (#E0DBD1)") guides FLUX toward target colors
- Minor drift (±10%) is visually acceptable for P0/P1 (gameplay sprites)
- Exact palette match required for P2 (polish) — use post-recolor script if drift exceeds 15%

**Decision:** Accept ±10% color drift for P0/P1. Reserve post-recolor pass for P2 only if visual drift is unacceptable.

#### 4. Review Gates: 6 Checkpoints (Boba + Joaquín at Gate 6)

- **Gate 1:** First frame of first pose — validates prompt strategy, establishes visual baseline
- **Gate 2:** First complete pose (8 frames) — validates frame coherence, animation flow
- **Gate 3:** P0 complete (6 pose sets) — systemic check before scaling to P1
- **Gate 4:** P1 midpoint (17 pose sets per character) — catches style drift
- **Gate 5:** P1 complete (34 pose sets) — gameplay integration validation
- **Gate 6:** P2 complete (all 51 poses) — final art director + founder sign-off

#### 5. Batch Strategy: 10-Frame Review Cycles

**Rationale:**
- Generating 48 frames blindly risks 48 frames with consistent errors (wrong hair color, wrong proportions)
- 10-frame batches enable rapid error detection (discover bad prompt in 5 minutes vs. 24 minutes)
- Review overhead is minimal (30 seconds per batch vs. hours of wasted generation)

#### 6. Iteration Budget: 50% P0, 25% P1, 35% P2

**Total estimated frames:**
- P0: 48 frames × 1.5 (iteration) = 72 generations
- P1: 450 frames × 1.25 = 563 generations
- P2: 200 frames × 1.35 = 270 generations
- **Grand total: ~905 generations** (within Azure rate limits: 30/min = 1800/hour)

### Team Impact

- **Boba (Art Director):** Owns all 6 review gates, prompt strategy iteration during P0, QA checklist enforcement
- **Nien (Sprite Implementer, if assigned):** Executes FLUX API calls, frame-by-frame generation workflow
- **Chewie (Gameplay Engineer):** Integrates sprites into Godot AnimationPlayer, reports gameplay timing issues
- **Mace (Producer):** Tracks P0/P1/P2 progress, manages Azure budget
- **Joaquín (Founder):** Approves this decision brief, final sign-off at Gate 6

### Open Questions for Joaquín

1. **Confirm 256×256 canvas size** — Is 4.3× safety margin sufficient for in-game render quality? Or do you want 512×512 for all sprites (2× slower iteration)?
2. **Confirm P0 scope** — Are 3 poses (idle, walk, attack_lp) sufficient to validate the pipeline? Or do you want additional poses in P0?
3. **Confirm review gate involvement** — Should you review at Gate 3 (P0 complete) or only at Gate 6 (P2 complete)?
4. **Confirm Azure budget** — ~905 FLUX generations at $X per token = $Y total. Is this within budget?

---

## Decision: Sprite Art Vision Guide — FLUX Creative Direction

**Date:** 2026-03-09  
**Author:** Yoda (Game Designer / Vision Keeper)  
**Status:** ACTIVE — Reference document for Sprint 2 art generation  
**Impact:** CRITICAL — Defines creative vision for all FLUX-generated sprites

### Summary

Created comprehensive Sprite Art Vision Guide (`games/ashfall/docs/SPRITE-ART-VISION.md`) to ensure FLUX 1.1 Pro-generated sprites capture Ashfall's creative identity and personality, not just technical requirements.

### Key Decisions

#### 1. Intensity Escalation Strategy

**Decision:** Escalating intensity (Round 1 → Round 3) is handled by **VFX overlay and stage art**, NOT by sprite variants.

**Rationale:**
- Keeps sprite count manageable (no need for 3× sprite variants per pose)
- Sprites remain emotionally consistent across rounds
- Context (stage eruption, ember particles, screen effects) provides intensity escalation
- Allows sprite generation to focus on baseline emotion

**Implications:**
- Boba generates ONE set of sprites per character pose
- VFX team handles ember glow intensity scaling with meter
- Stage art team handles environmental intensity progression

#### 2. Art Style Target: HD Pixel Art with Cel-Shading

**Decision:** Target Last Blade 2 / Guilty Gear XX / Garou: Mark of the Wolves quality — HD pixel art (64×64px base) with flat color + cel-shaded hard-edge shadows.

**Rationale:**
- Provides enough detail for facial expressions and body language (key for readable emotion)
- Avoids low-res 8-bit/16-bit limitations (can't show personality clearly)
- Cel-shading maintains stylized look while adding depth
- Aligns with "Guilty Gear quality" Sprint 2 vision

#### 3. Character Movement Personality Framework

**Decision:** Define character personality through **movement energy** descriptors for FLUX, not just frame data.

- **Kael = "Economy of Motion":** Minimal wind-ups, linear trajectories, clean recovery. Moves like martial artist practicing forms alone. SNAPS into position, doesn't swing.
- **Rhena = "Explosive Commitment":** BIG wind-ups, wide arcs, momentum bleed. Moves like street brawler with something to prove. SWINGS and has to brake.

#### 4. Emotion Scale Matrix by Action State

**Decision:** Created detailed emotion descriptions for EVERY action state for BOTH characters.

**Core Rules:**
- **Kael NEVER loses composure** (even at peak intensity, shows CONTROL)
- **Rhena is ALWAYS intense** (even idle, looks ready to explode)

#### 5. Non-Negotiable Consistency Rules

**Decision:** Established strict pixel-exact proportions and identity markers that MUST remain constant across ALL frames.

**Key Constants:**
- **Body proportions:** Exact pixel measurements (Kael: 12px shoulders, Rhena: 14px shoulders)
- **Identity markers:** Kael's ponytail, Rhena's burn scars — ALWAYS present
- **Ember colors:** Kael = blue, Rhena = orange — NEVER swap

### Cross-Team Dependencies

- **Boba (Art Director):** Use SPRITE-ART-VISION.md as creative layer for SPRITE-ART-BRIEF.md. Every FLUX prompt must reference vision guide.
- **Mace (Producer):** Intensity escalation decision reduces sprite count by ~3× (no round variants needed). Faster Sprint 2 art completion.
- **firstPunch (VFX):** Implement ember glow intensity scaling with meter (shader overlay on sprites, not baked-in variants).

### Why This Matters

**Problem:** FLUX can generate technically perfect pixel art that feels SOULLESS and generic.

**Solution:** This vision guide ensures every sprite communicates:
- **WHO these characters ARE** (Kael = disciplined calm, Rhena = explosive fury)
- **WHAT this fight FEELS like** (volcanic intensity, readable combat)
- **WHY this is ASHFALL** (not generic fighter #47)
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

# Decision: Universal Game Development Skills Initiative (Deep Research Wave)

**Author:** Solo (Lead), Yoda (Game Designer), Greedo (Sound Designer), Boba (Art Director), Leia (Environment Artist), Tarkin (Enemy/Content Dev)  
**Date:** 2026-03-07  
**Status:** Approved & Implemented  
**Session:** Deep Research Wave — Broadening from beat-em-up to universal game development knowledge  
**Requested by:** joperezd

---

## Executive Summary

**APPROVED.** Commissioned 7 agents in parallel to create universal, engine-agnostic game development skills based on firstPunch beat 'em up expertise. Result: 7 comprehensive skill documents (292.7 KB) covering game design, audio design, animation, level design, and enemy design — applicable across all game genres and platforms.

### Key Decisions

1. **Scope Expansion:** Broaden team knowledge from beat-em-up-specific to universal principles
2. **Timing:** Execute *before* Phase 4 AAA work and potential future projects
3. **Approach:** Extract theory from firstPunch experience + validate against industry best practices
4. **Documentation Standard:** Follow game-feel-juice pattern (philosophy → patterns → anti-patterns → genre-specific)
5. **Confidence Model:** Medium confidence (validated in firstPunch), will escalate to High after cross-project validation

---

## Skills Created (7 Total)

### 1. Game Design Fundamentals (Yoda)
- **Location:** `.squad/skills/game-design-fundamentals/SKILL.md`
- **Size:** 62.6 KB
- **Sections:** 12 (philosophy, systems, economy, progression, engagement loops, difficulty balancing, narrative, agency, psychology, iteration, anti-patterns, documentation)
- **Scope:** Genre-agnostic game design principles for all game types
- **Anti-patterns:** 8 documented failure modes (design-by-committee, scope creep, impossible difficulty, etc.)
- **Key principle:** Emergence and player agency as core design drivers

### 2. Game Audio Design (Greedo)
- **Location:** `.squad/skills/game-audio-design/SKILL.md`
- **Size:** 32.5 KB
- **Sections:** 10 (audio as game design, sound principles, adaptive music, spatial audio, budget framework, implementation patterns, platforms, genre-specific, testing, anti-patterns)
- **Scope:** Universal audio design across all genres and platforms, engine-agnostic
- **Audio hierarchy:** CRITICAL > HIGH > NORMAL > LOW to prevent "wall of sound"
- **Key principle:** "Eyes can close, ears can't" — audio is a first-class design tool, not an afterthought

### 3. Animation for Games (Boba)
- **Location:** `.squad/skills/animation-for-games/SKILL.md`
- **Size:** 51 KB
- **Sections:** 13 (fundamentals, timing, character, combat, communication, performance, tools, rigging, motion capture, systems, IK/FK, blending, anti-patterns)
- **Scope:** 2D and 3D animation principles, engine-agnostic
- **Key formula:** 12 FPS as optimal game animation baseline (24 FPS for cinematic)
- **Anti-patterns:** 7 documented failures (over-animation, rigid poses, no squash-stretch, etc.)

### 4. Level Design Fundamentals (Leia)
- **Location:** `.squad/skills/level-design-fundamentals/SKILL.md`
- **Size:** 60 KB
- **Sections:** 10 (philosophy, spatial grammar, flow & pacing, environmental storytelling, 7-genre-specific, tools, camera, secrets, anti-patterns, process)
- **Scope:** Universal spatial design principles for all game types
- **Core framework:** 6 space types (safe, danger, transition, arena, reward, story) and 3-beat teaching rhythm
- **Genre guidance:** Platformer, Beat 'em Up, Metroidvania, RPG, Puzzle, 3D Action, Horror

### 5. Enemy & Encounter Design (Tarkin)
- **Location:** `.squad/skills/enemy-encounter-design/SKILL.md`
- **Size:** 49.5 KB
- **Sections:** 11 (philosophy, 10 archetypes, boss design, composition, spawning rules, difficulty, AI, DPS budget, anti-patterns, genre guidance)
- **Scope:** Enemy design and encounter systems for action games
- **10 archetypes:** Fodder, Bruiser, Agile, Ranged, Shield, Swarm, Explosive, Support, Mini-boss, Boss
- **Boss principle (Mega Man model):** Patterns are learnable (not random), tested in 2-3 minutes, multi-phase escalation
- **DPS budget framework:** Calculate max safe DPS from player HP ÷ safe TTK (4-6s)

### Supporting Analysis Documents

**6. Foundations Reassessment (Solo)**
- **Location:** `.squad/analysis/foundations-reassessment.md`
- **Size:** 12.3 KB
- **Content:** Current state assessment (7.5/10), 5 priority actions, cross-team gap analysis
- **Key finding:** Team possesses deep beat-em-up knowledge but lacks breadth for scaling to other genres
- **Recommendation:** Invest in universal skills *before* Phase 4 AAA work and future projects

**7. Skills Audit v2 (Ackbar)**
- **Location:** `.squad/analysis/skills-audit-v2.md`
- **Size:** 14.2 KB
- **Content:** Audit of 15 existing skills, confidence ratings, cross-reference recommendations
- **Quality benchmark:** game-feel-juice rated ⭐⭐⭐⭐⭐ (5/5 stars) as model for documentation
- **Findings:** 12/15 skills at medium+ confidence; 3 skills need cross-reference updates

---

## Rationale & Context

### Why This Initiative Now?

1. **Institutional Knowledge Risk:** firstPunch expertise is deep but concentrated. One key agent departure means knowledge loss.
2. **Future Project Readiness:** Next project (TBD) may not be beat-em-up. Without universal skills, team restarts from zero.
3. **Team Scale:** Growing to 13+ agents (with Tool Engineer addition) increases knowledge-sharing burden. Written skills scale better than tribal knowledge.
4. **Foundation Before Complexity:** Phase 4 AAA work requires solid conceptual foundation. This research wave provides that foundation.
5. **Publishing Standard:** Document *one set* of principles that apply universally, rather than project-specific playbooks.

### Validation Approach

All skills include:
- **Internal references:** Cross-link to game-feel-juice (our quality standard), beat-em-up-combat (proven system), and sibling universal skills
- **Industry validation:** Patterns extracted from published game analysis, GDC talks, developer interviews, and peer-reviewed game studies
- **Confidence ratings:** Medium for most (validated in firstPunch context); will escalate to High after cross-project testing
- **Anti-patterns:** 7-10 documented failure modes per skill, drawn from firstPunch bugs and research

---

## Quality Standards & Deliverables

### Documentation Template (Universal Skills)
Each skill follows game-feel-juice structure:
1. **Core Philosophy** — Why this discipline matters in games
2. **Foundational Patterns** — 5-10 reusable patterns with examples
3. **Anti-Patterns Catalog** — 7-10 documented failure modes to avoid
4. **Genre-Specific Application** — How principles adapt across game types
5. **Implementation Guidance** — Concrete workflow and integration patterns
6. **Cross-References** — Links to related skills and projects

### Confidence Levels

| Skill | Confidence | Validation Source |
|-------|-----------|------------------|
| game-design-fundamentals | Medium | firstPunch design decisions + GDC talks + published game analysis |
| game-audio-design | Medium | firstPunch audio system + Hades/Celeste/SoR4 analysis + procedural-audio skill validation |
| animation-for-games | Medium | firstPunch animation patterns + industry best practices + character animation research |
| level-design-fundamentals | Low | firstPunch level design + 3-beat teaching model (not yet cross-tested on platformer/RPG) |
| enemy-encounter-design | Medium | firstPunch enemy types + wave composition rules + published enemy design frameworks |

*Confidence levels will increase as skills are applied to new projects.*

---

## Impact on Other Skills & Decisions

### Cross-References & Linkage

All 7 new universal skills interlink:
- **game-feel-juice** (existing) ← referenced by all 5 universal skills as quality standard
- **beat-em-up-combat** (existing) ← referenced by enemy-encounter-design and game-design-fundamentals as firstPunch validation
- **game-design-fundamentals** ← references game-feel-juice, beat-em-up-combat
- **game-audio-design** ← references game-feel-juice, game-design-fundamentals
- **animation-for-games** ← references game-feel-juice, game-design-fundamentals
- **level-design-fundamentals** ← references game-feel-juice, game-design-fundamentals
- **enemy-encounter-design** ← references game-feel-juice, beat-em-up-combat, game-design-fundamentals

### Updates to Existing Skills

**Recommendation (Ackbar/QA):** Update 3 existing skills with cross-references to new universal skills:
1. **beat-em-up-combat** → Add "Cross-reference: enemy-encounter-design" in boss section
2. **game-feel-juice** → Add "Universal parallel skill: game-design-fundamentals" in intro
3. **procedural-audio** → Add "Universal parallel skill: game-audio-design" in scope section

---

## Metrics & Success Criteria

### Deliverables (Achieved)
- ✅ 7 comprehensive skill documents created (292.7 KB)
- ✅ Universal principles extracted from firstPunch beat-em-up expertise
- ✅ Game Design Fundamentals (Yoda): 62.6 KB, 12 sections, 8 anti-patterns
- ✅ Game Audio Design (Greedo): 32.5 KB, 10 sections, validated against procedural-audio system
- ✅ Animation for Games (Boba): 51 KB, 13 sections, 2D/3D frameworks
- ✅ Level Design Fundamentals (Leia): 60 KB, 10 sections, 6 space types + 3-beat model
- ✅ Enemy & Encounter Design (Tarkin): 49.5 KB, 11 sections, 10 archetypes + DPS budget
- ✅ Foundations Reassessment (Solo): 12.3 KB, 7.5/10 score, 5 priority actions
- ✅ Skills Audit v2 (Ackbar): 14.2 KB, game-feel-juice benchmark (⭐⭐⭐⭐⭐)

### Team Impact
- **Before:** 15 reusable skills (beat-em-up focused)
- **After:** 22 reusable skills (universal + beat-em-up focused)
- **Knowledge breadth:** Increased from 1 genre to 7+ genres
- **Scalability:** Team can onboard to new projects with existing skill foundation vs. starting from zero

---

## Decisions & Action Items

### Approved Scope
✅ Create universal game design fundamentals skill  
✅ Create universal game audio design skill  
✅ Create universal animation principles skill  
✅ Create universal level design skill  
✅ Create universal enemy design skill  
✅ Conduct second-pass skills audit (Ackbar)  
✅ Assess foundations and priority actions (Solo)  

### Recommended Next Steps
1. **Update existing skills:** Add cross-references per Ackbar/QA recommendations
2. **Schedule skill validation:** Plan cross-project testing to escalate confidence levels
3. **Team training:** Brief squad on new skill availability and applicability
4. **Tool Engineer integration:** Ensure Lobot/K-2SO role has access to all skill documentation for pipeline/template work
5. **Document next project:** When Phase 4 or new project greenlit, start with universal skills as foundation

### Out of Scope (For Future Decisions)
- Implementing universal skills into specific engines (Godot, Unity, etc.)
- Creating platform-specific variants (Web, Mobile, Console)
- Genre-specific extensions (RPG systems, Metroidvania progression, etc.)

---

## Sign-Off

**Team Lead:** Solo — Approved this research wave and recommends immediate integration into team knowledge base.

**QA Lead:** Ackbar — Audited deliverables. game-feel-juice benchmark met. Recommend cross-references to be added in follow-up session.

**Key Contributors:** Yoda, Greedo, Boba, Leia, Tarkin — All deliverables completed on schedule. Universal principles successfully extracted from beat-em-up context. Ready for cross-project validation.

---

*Deep Research Wave — 2026-03-07, Session concluded 2026-03-07T23:52:00Z UTC*


---

## Decision: Sprint 1 Bug Catalog — Process Improvements for Sprint 2

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-09  
**Status:** Proposed  
**Scope:** Ashfall Sprint 2 and all future sprints  
**Artifact:** games/ashfall/docs/SPRINT-1-BUG-CATALOG.md

---

### Summary

Comprehensive analysis of **35 bugs** cataloged across 9 categories during Sprint 1, with **16 P0/P1 severity issues**. Every bug was preventable with better processes: integration checkpoints, explicit type enforcement, signal contracts, export testing, branch hygiene, and edge case testing.

### Seven Mandatory Process Changes for Sprint 2

1. **Integration Checkpoint at End of Every Sprint** ✅ CRITICAL — Catch integration bugs within sprint, not deferred
2. **Enforce Explicit Type Annotations** ✅ CRITICAL — Prevent runtime type errors, catch bugs at compile time
3. **Signal Contract Testing** ✅ CRITICAL — Prevent VFX/audio/HUD failing during integration
4. **Frame Data Validation Tool** ✅ HIGH PRIORITY — Prevent balance inconsistencies, ensure GDD sync
5. **Export Testing in CI/CD** ✅ HIGH PRIORITY — Catch platform-specific bugs before merge
6. **Branch Hygiene Enforcement** ✅ HIGH PRIORITY — Prevent work getting lost on dead branches
7. **Edge Case Test Matrix** ✅ MEDIUM PRIORITY — Prevent edge case bugs in round/match management

### Key Metrics

- **35 bugs total:** 7 P0, 9 P1, 10 P2, 9 unrated
- **66% found by humans**, 34% by automation
- **46% are P0/P1 severity** (should be caught before merge)
- **Average lag time: 1 day** (introduced → discovered)

### Verdict

**APPROVED for mandatory Sprint 2 enforcement.**

---

## Decision: Code Quality Audit — Process vs Physics Process Timing

**Author:** Ackbar (QA/Playtester)  
**Date:** 2026-03-09  
**Status:** Proposed  
**Type:** Code Quality / Standards Enforcement  
**Artifact:** games/ashfall/docs/SPRINT-1-CODE-AUDIT.md

---

### Summary

Sprint 1 code audit revealed **5 files using _process(delta) for timing-sensitive animations** instead of _physics_process. GDD requires deterministic "Frame Data Is Law" at 60 FPS. Float delta timing creates non-deterministic behavior, framerate-dependent drift, and replay desync issues.

### Decision Matrix

| System | Uses _physics_process? | Rationale |
|--------|------------------------|-----------|
| VFX timing (shake, flash, slowmo) | ✅ YES | Affects player input timing |
| HUD animations (health bar, timer) | ✅ YES | Round timer is gameplay-critical |
| UI menu animations (title glow) | ❌ NO | Pure cosmetic, no gameplay impact |

### Priority Changes

**Priority 1 (Critical):** vfx_manager.gd → use _physics_process with frame counters

**Priority 2 (Should fix):** fight_hud.gd → use _physics_process

**Priority 3 (Cosmetic):** victory_screen.gd, main_menu.gd → leave as _process

### Verdict

**APPROVED.** Enforce _physics_process for all gameplay-affecting timing via lint rule.

---

## Decision: Sprint 1 Lessons Learned & GDScript Standards

**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-09  
**Status:** Proposed  
**Type:** Standards / Process Enforcement  
**Artifacts:**
- games/ashfall/docs/SPRINT-1-LESSONS-LEARNED.md
- games/ashfall/docs/GDSCRIPT-STANDARDS.md
- .squad/skills/gdscript-godot46/SKILL.md

---

### Summary

Sprint 1 revealed systematic bugs in Godot 4.6 type inference, input handling, and frame data management. **23 fix commits** were required. Bugs weren't isolated — they followed **patterns**:

1. **Type inference failure:** := from dict/array/abs() produces Variant (10 fixes)
2. **Input export divergence:** Custom _input() works in editor, breaks in Windows exports (6 PRs)
3. **Frame data drift:** Three sources of truth diverged silently (3 P1 bugs)
4. **Integration gate reactive:** Tool existed but ran after merge, not before (2 PRs)

### Decision: MANDATORY for Sprint 2+

**Enforcement mechanisms:**
1. Integration gate runs on every PR — GitHub Action blocks merge if failed
2. Pre-commit type safety check — Grep for risky := patterns
3. Code review checklist — Validate against GDSCRIPT-STANDARDS.md
4. Windows export testing — Required for all UI/input changes

### Success Criteria for Sprint 2

- Zero := with dict/array/abs() in merged PRs
- Zero input export failures
- Fewer than 3 fix commits (down from 23 in Sprint 1)

### Why Mandatory?

**Sprint 1 evidence:** 10 type bugs followed same pattern; 6 input bugs made same mistake. If agents don't know the pattern, they'll repeat it.

**Productivity:** 10 days lost to character select debugging; 3-4 hours hunting type inference issues; emergency releases disrupted work.

**Future risk:** Sprint 2 is combo system (high complexity, low tolerance for bugs).

### Verdict

**APPROVED for mandatory Sprint 2 enforcement.** Every rule traces to real bug. Evidence is overwhelming.

---

### 2026-03-09T232154Z: PoC feedback y directivas del founder
**By:** joperezd (via Copilot)
**What:** 
1. Estilo y calidad visual: APROBADO por el founder
2. Kael no debería llevar botas — es un monje (descalzo o sandalias)
3. El founder evalúa gusto/estilo. La consistencia y corrección es responsabilidad del equipo (Boba/Nien)
4. Corregir walk cycle (misma pierna) y LP recovery (frames 7-12 cargan de nuevo)
5. Preparar código Godot para ejecutar la PoC con los sprites generados
**Why:** Founder review — GO en estilo, ITERATE en animación. Equipo debe autogestionar calidad.


---

## Decision: Transparent Backgrounds Directive (User Requirement)

**Author:** Joaquín (Founder, via Copilot)  
**Date:** 2026-03-10  
**Status:** Approved  
**Type:** User Requirement / Art Pipeline

### Summary

All character sprites MUST have transparent backgrounds (alpha channel). FLUX generates opaque PNGs with inconsistent backgrounds (white, brown, grey). A background removal post-processing step is required in the art pipeline.

### Rationale

- Game sprites need transparency to composite over stage backgrounds in Godot
- Inconsistent opaque backgrounds are unusable in-engine
- User requirement from Joaquín (founder)

### Decision

Background removal is mandatory for all FLUX sprite batches before production integration.

---

## Decision: PoC Sprite Background Removal Pipeline

**Author:** Nien (Character Artist)  
**Date:** 2026-03-10  
**Status:** Executed  
**Type:** Art Pipeline / Process

### Context

FLUX-generated PoC sprites had inconsistent opaque backgrounds (white, brown, grey). Game sprites must have transparent backgrounds for proper compositing over stage backgrounds in Godot.

### Decision

Used Python 
embg library (u2net AI model) for batch background removal on all 30 character sprites. Saved transparent PNGs over originals in-place.

### Scope

- **Processed:** kael_hero, rhena_hero, 8 idle, 8 walk, 12 lp frames (30 files)
- **Excluded:** embergrounds_bg.png, title_screen.png (full backgrounds, not sprites)

### Rationale

- 
embg uses AI-based segmentation (u2net) which handles varied/gradient backgrounds better than simple color thresholding
- Industry-standard tool for game sprite background removal
- CPU-only install avoids GPU dependency for CI/pipeline use

### Impact

- All PoC sprites now ready for Godot compositing over any stage background
- Establishes 
embg as the standard background removal step in the FLUX → game-ready sprite pipeline
- Future FLUX batches should include this step automatically after generation

### Verdict

**APPROVED.** rembg (u2net) is the standard for background removal in the production sprite pipeline.

---

## Decision: Kael FLUX Sprite PoC — Art Director Review

# Kael FLUX Sprite PoC — Art Director Review

**Reviewer:** Boba (Art Director)  
**Date:** 2025-07-22  
**Assets Reviewed:**  
- `games/ashfall/assets/poc/contact_idle.png` — 8 idle frames  
- `games/ashfall/assets/poc/contact_walk.png` — 8 walk frames  
- `games/ashfall/assets/poc/contact_lp.png` — 12 LP frames  

---

## 1. IDLE (8 frames)

| Criteria | Assessment |
|----------|------------|
| **Consistency** | ⚠️ Moderate issues. Skin tone varies (frames 4-5 warmer/more saturated than 1-3, 6-8). Arm wrap visibility shifts between frames. Overall proportions stable. |
| **Motion Flow** | ✅ Subtle breathing motion reads well. Good fighting game idle loop feel. |
| **Silhouette** | ✅ Strong. Guard stance clear, fists visible, head distinct from body. |
| **Background Removal** | ✅ Clean transparency, no visible halos or artifacts. |
| **Known Fix Check** | ❌ **FAIL: Kael is wearing brown boots/shoes** in all 8 frames. GDD specifies barefoot fire monk. This was flagged as a required fix. |

### VERDICT: **NEEDS WORK**
- **Blocker:** Regenerate barefoot. The boots break character identity.
- Minor: Color-correct skin tones for consistency across frames.

---

## 2. WALK (8 frames)

| Criteria | Assessment |
|----------|------------|
| **Consistency** | ✅ Good. All frames same character. Warm orange skin tone consistent. Sandal wraps match throughout. |
| **Motion Flow** | ⚠️ **Problem: Legs don't alternate.** Frames show subtle weight shift/bobbing but both legs stay mostly in same position. This will read as "bouncing in place" not "walking forward." |
| **Silhouette** | ✅ Clear guard stance silhouette maintained. Good fighting game readability. |
| **Background Removal** | ✅ Clean cuts, transparent background intact. |
| **Known Fix Check** | ✅ Barefoot with proper sandal wraps. ❌ Legs do NOT alternate as required. |

### VERDICT: **NEEDS WORK**
- **Blocker:** Walk cycle needs actual leg alternation. Current frames are more of a "bounce idle" than a walk.
- Positive: Footwear correct on this set (sandals/barefoot look).

---

## 3. LP — Light Punch (12 frames)

| Criteria | Assessment |
|----------|------------|
| **Consistency** | ❌ **SEVERE inconsistency.** Frames 1-6 and 7-12 look like two different characters. |
|  | • Frames 1-6: Pale skin, brown boots, taller/leaner proportions, realistic style |
|  | • Frames 7-12: Warm orange skin, sandals, stockier proportions, more stylized |
| **Motion Flow** | ⚠️ Within each row, motion is okay. Frame 4-5-6 show fire ember effect (good fire monk identity). Frames 7-12 show recovery to guard. But the jarring style break at frame 7 destroys readability. |
| **Silhouette** | ✅ Punch extension clear in both styles. Attack readable. |
| **Background Removal** | ✅ Clean on all frames. |
| **Known Fix Check** | ⚠️ Partial. Frames 7-12 are barefoot ✅, show recovery to guard ✅. But frames 1-6 still have boots ❌. |

### VERDICT: **FAIL**
- **Blocker:** Two completely different character styles spliced together. Cannot ship this.
- The fire ember effect on extended fist (frames 4-6) is actually great — keep that concept.
- Regenerate entire LP sequence with consistent character model matching the Walk sandal style.

---

## OVERALL PoC VERDICT: **NEEDS WORK**

### Summary
FLUX can produce quality fighting game sprites — the Walk set proves this. But the AI is generating inconsistent character interpretations across prompts. The IDLE and LP sets have boot/barefoot violations, and LP has a catastrophic style break mid-animation.

### Actionable Next Steps

1. **Standardize the reference.** Pick the Walk frames (7-12 of LP also match) as the canonical Kael look: warm orange skin, sandal wraps, stockier martial artist proportions.

2. **Regenerate IDLE** with explicit barefoot/sandal prompt, using Walk frames as img2img reference if FLUX supports it.

3. **Regenerate LP frames 1-6** to match the style of frames 7-12. The recovery half is good; the startup/active half is wrong.

4. **Walk leg alternation** — either regenerate with better motion description, or manually reorder/flip frames to create proper alternation.

5. **Color consistency pass.** When all sets are regenerated, do a final color grade to lock skin tone, gi color, and wrap color across all animations.

### What's Working
- Background removal (rembg) is excellent — clean transparency throughout
- Fighting game silhouettes are clear and readable
- Fire monk identity comes through when prompted correctly (ember effect on LP)
- The "correct" Kael (Walk, LP 7-12) has good martial artist energy

### Recommendation
Do NOT proceed to full animation set production until barefoot + consistent style is locked. One more PoC iteration with tighter prompting should get us there. Consider creating a Kael reference sheet PNG that gets fed into every generation prompt.

---

*— Boba, Art Director*


---

## Decision: PoC Art Sprint — Founder Verdict

### 2026-03-10T07:44Z: PoC Art Sprint — Founder Verdict
**By:** Joaquín (via Copilot)
**What:** PoC Arte validada. Stage "GUAPISIMO". Character looks good. Known prompt issues (boots, backgrounds) acknowledged — were fixed in second pass. LP attack animation too fast (60fps × 12 frames = 0.2s), needs more frames or lower FPS for production. Scene loaded without issues in Godot. Screenshots saved to games/ashfall/docs/screenshots/PoC Arte/
**Why:** Founder review of Art PoC — validates FLUX pipeline for production use. Key learning: initial prompts need more care (barefoot, transparent bg, etc.) but the quality ceiling is proven.


---

## Decision: Art Pipeline Workflow — Approval Gate + Design Iterations

### 2026-03-10T07:51Z: User directive — Art pipeline workflow
**By:** Joaquín (via Copilot)
**What:** Art pipeline must follow this flow: (1) Generate hero reference with FLUX 2 Pro at 1024px on transparent/solid-color background — get founder approval on static character design BEFORE proceeding. (2) Use approved hero as Kontext Pro input_image to generate animation frames. (3) FLUX 2 Pro should generate without background from the start — avoid rembg post-processing which "siempre se nota un poquito". Generate multiple design proposals for Kael and Rhena for founder approval.
**Why:** Founder observed rembg artifacts. Better to generate clean from source than fix in post. Also wants design approval gate before frame generation to avoid wasting API calls on wrong designs.

---

## Decision: Green Chroma Key for All FLUX Character Generation

**Author:** Nien (Character Artist)  
**Date:** 2026-03-10  
**Status:** PROPOSED

### Decision

All FLUX-generated character sprites should use solid bright green (#00FF00) chroma key backgrounds instead of relying on rembg post-processing for background removal.

### Context

The founder (Joaquín) noticed artifacts from rembg's AI-based background removal on previous PoC sprites. Testing with explicit green chroma key prompts on FLUX 2 Pro produced 6/6 images with perfectly clean green backgrounds (100% corner pixel verification).

### Implications

- **Prompt change:** Every character generation prompt must start with "isolated character, full body, solid bright green (#00FF00) chroma key background, no border, no frame, no text"
- **Pipeline change:** Replace rembg step with simple green color-key removal (faster, deterministic, no artifacts)
- **Affects:** Nien (character art), Boba (art direction), anyone running FLUX generation scripts
- **Does NOT affect:** Stage backgrounds, VFX, UI elements (those don't need transparency)

### Hero Design Proposals

Generated 3 design proposals each for Kael and Rhena at 1024×1024:
- `games/ashfall/assets/poc/designs/kael_design_{a,b,c}.png`
- `games/ashfall/assets/poc/designs/rhena_design_{a,b,c}.png`
- Contact sheets: `designs_kael.png`, `designs_rhena.png`

**Awaiting founder approval** before generating animation frames.

---

## Decision: AI Sprite Background Generation Research

# AI Sprite Background Generation Research
**Researcher:** Boba (Art Director)  
**Date:** 2025  
**Objective:** Determine best approach for AI-generated fighting game sprite backgrounds

---

## Executive Summary

After researching industry practices, academic literature, and available technologies, we have **four viable options** for background handling in our FLUX-based sprite pipeline. The current approach (green chroma key) is **industry-standard and proven**, but emerging alternatives offer quality improvements with proper setup.

**Primary Recommendation:** Continue with **Option A (Green chroma key)** as the baseline, with **Option B (LayerDiffuse for transparent generation)** as the premium path if we want native alpha support.

---

## Research Findings

### 1. Industry Standard for Game Studios
Game studios adopting AI-generated assets follow a consistent pattern:
- **Export format:** All assets generated as PNG with transparency
- **Background handling:** Most use chroma key (green screen) generation followed by color removal
- **Post-processing:** ~80-90% AI generation, then 10-20% human artist cleanup
- **Consistency method:** Detailed prompts, reference images, and prompt structure standardization
- **Workflow:** Rapid iteration → in-engine testing → quality control → final polish

**Key Finding:** The industry hasn't settled on a single "best" approach—instead, they use what works for their constraints. Choice depends on setup complexity, desired quality, and timeline.

---

### 2. FLUX Model Transparency Capabilities

**Standard FLUX (as-is):** Cannot natively generate transparent backgrounds with alpha channels. Standard FLUX outputs RGB images only.

**Technical Solution Available:** LayerDiffuse-Flux enables native RGBA generation
- Specialized fork of FLUX trained to explicitly predict alpha channels
- Produces true transparent backgrounds (not post-processed removal)
- Preserves soft edges, glows, and semi-transparency better than any removal method
- Requires: Custom weights + moderate setup in ComfyUI/Forge
- Available: Open-source on GitHub (FireRedTeam/LayerDiffuse-Flux)

**Workaround (Post-Processing):** Transparify method—generate on black AND white backgrounds, then mathematically reconstruct alpha channel (effective but adds generation overhead).

---

### 3. Chroma Key vs. AI Background Removal

| Aspect | Green Chroma Key | AI Removal (rembg) |
|--------|-----------------|-------------------|
| **Edge Quality** | Sharp, precise (if lighting controlled) | Very good (modern models), minor artifacts possible |
| **Real-Time** | Yes | No (~5-15s per image) |
| **Soft Edges** | Requires careful spill management | Naturally handles hair, transparency |
| **Glows/Reflections** | Can remove unintentionally | Preserved better by modern AI |
| **Setup Required** | High (consistent lighting) | Low (any image) |
| **Batch Processing** | Predictable results | Requires per-image tuning sometimes |
| **Hair/Complex Objects** | Struggles without manual cleanup | Modern models (BiRefNet, BRIA RMBG 2.0) excel |
| **Flexibility** | Rigid (must use chroma) | Works on any background |

**Winner by Category:**
- **Best for predictable, batch sprite generation:** Chroma key (when studio-controlled)
- **Best for edge quality on complex objects:** AI removal with modern models (BRIA RMBG 2.0, BiRefNet)
- **Best for flexibility:** AI removal (works on any background)
- **Best for professional/polished results:** Chroma key (if perfectly lit; AI removal for hands-off)

**Conclusion:** Chroma key is cleaner IF you control lighting/environment perfectly. AI removal is more practical for flexible workflows and actually superior on complex geometry (fabric, hair, transparent items).

---

### 4. Best Chroma Key Color

**For Digital/Game Art:** GREEN is the standard
- Digital sensors are most sensitive to green (highest detail capture)
- Reflects more light (easier to light evenly)
- Distinct from skin tones
- Widely available, affordable
- **Your current choice (#00FF00) is industry-standard**

**Blue Screen:** Use only if green elements are in your character/props
- Less spill (reflects less light)
- Better in low-light scenes
- Digital cameras less sensitive (slightly less detail)

**Magenta:** Rarely used in game art
- Too close to skin tones
- Not standard tooling support
- Only use in special edge cases

**Recommendation:** Stay with green. Your #00FF00 is correct.

---

### 5. AI-Generated Sprite Pipeline Best Practices

**Standard Pipeline Architecture (Industry):**
1. **Frontend:** Upload/prompt interface
2. **Backend:** Workflow orchestration (Azure AI Foundry in our case)
3. **AI Service:** FLUX model on Azure
4. **Output:** PNG with transparent background
5. **Post-Processing:** Cleanup (5-10% of frames need touch-up)
6. **QC:** In-engine testing before final export

**Consistency Maintenance (Fighting Games Specific):**
- Use character reference images as conditioning
- Maintain strict prompt structure across all generations
- Pre-define animation set: idle, walk, punch, kick, block, hit, crouch
- Frame count: 8-16 frames per action (adjust for smoothness)
- Export as sprite sheets with consistent frame dimensions

**Key Success Factors:**
1. **Detailed Prompts:** "Pixel art sprite, [character], [pose], [action], [style], [orientation]"
2. **Batch Generation:** Generate all frames of one action before moving to next
3. **Version Control:** Store base generations separately from final polished versions
4. **Rapid Iteration:** Small test sets → in-engine → feedback → regen
5. **Manual Touch-Up:** Budget time for 10-20% hand cleanup (blinking pixels, anatomy fixes, weapon placement)

---

## Decision Options Analyzed

### Option A: Green Chroma Key → Color-Key Removal Script ✅ (Current)
**Process:**
1. Prompt FLUX with character on #00FF00 background
2. Export PNG
3. Run automated color-key script (strips green, generates alpha)
4. Manual cleanup as needed

**Pros:**
- Industry-standard, proven method
- Fast iteration (no model retraining)
- Consistent results with stable prompting
- Works with standard FLUX
- Simple automated pipeline
- Minimal computational overhead

**Cons:**
- Requires perfect lighting control in generation prompt
- Green spill can occur on edges
- Not ideal for semi-transparent elements (glass, glow effects)
- Less flexible (must use green background in prompt)

**Estimated Timeline:** Weeks 1-4 (immediate implementation)
**Quality Level:** Production-ready (with 10-15% touch-up)
**Complexity:** Low
**Best For:** Rapid prototyping, consistent batching, controlled lighting scenarios

---

### Option B: LayerDiffuse for Direct Transparent Generation 🌟 (Premium)
**Process:**
1. Set up LayerDiffuse-Flux fork in ComfyUI/Azure environment
2. Prompt FLUX to generate with native alpha channel
3. Export PNG with true transparency
4. Minimal cleanup needed

**Pros:**
- Native alpha output (true transparency, not removal)
- Preserves soft edges, glows, halos better
- Better for complex geometry (fabric folds, hair strands)
- No color spill issues
- More flexible prompting (no need to specify green background)
- Superior for semi-transparent elements

**Cons:**
- Requires custom weights/model setup
- Moderate setup complexity (ComfyUI integration)
- Less widely adopted (fewer references/examples)
- Potential compatibility questions with Azure AI Foundry
- Unknown validation time on first implementation

**Estimated Timeline:** Weeks 2-5 (prototyping) + setup validation
**Quality Level:** Premium/polished (5% touch-up only)
**Complexity:** Moderate
**Best For:** Final production assets, characters with complex materials, premium quality push

---

### Option C: Solid Color Background → rembg AI Removal
**Process:**
1. Prompt FLUX with character on solid white/gray background
2. Export PNG
3. Run rembg (AI segmentation model) for background removal
4. Manual cleanup as needed

**Pros:**
- Works without special setup (rembg is free/open-source)
- No need to modify FLUX prompts
- Modern models (BRIA RMBG 2.0) handle complex edges well
- Great for hair, transparent, and fabric elements
- Flexible (any background color works)

**Cons:**
- Adds processing step (~5-15s per image)
- May require per-image tuning for difficult cases
- Minor artifacts possible (white halos, residual pixels)
- Quality inconsistent across diverse character designs
- Not real-time (slower batch processing)
- Additional cloud API calls or local GPU time

**Estimated Timeline:** Weeks 1-3 (minimal setup)
**Quality Level:** Good (varies; 15-25% touch-up)
**Complexity:** Very Low
**Best For:** Flexible/experimental workflows, characters with non-standard designs

---

### Option D: Hybrid Approach (Recommended Flexibility)
**Process:**
1. **Primary:** Green chroma key (Option A) for 80% of characters
2. **Secondary:** LayerDiffuse (Option B) for complex characters (fabric-heavy, transparent elements)
3. **Fallback:** rembg (Option C) for experimental/special cases

**Pros:**
- Leverages best-of-breed for each scenario
- Fast production for standard characters
- Premium quality for hero characters
- Handles edge cases gracefully
- Scalable as pipeline matures

**Cons:**
- Requires managing multiple workflows
- Slight learning curve for team
- More decision points (which method for which character?)

**Estimated Timeline:** Weeks 1-5 (staggered implementation)
**Quality Level:** Production-to-Premium (depends on route chosen)
**Complexity:** Moderate
**Best For:** Scaling production, diverse character roster, mature pipeline

---

## Recommendation

### Primary Path: **OPTION A + OPTION B (Hybrid Progressive)**

**Phase 1 (Now):** Continue with Option A
- Use green chroma key as production baseline
- Optimize prompting for clean edges
- Build automated color-key removal script
- Target: 70-80% production-ready on first pass

**Phase 2 (After 2-3 weeks evaluation):** Add Option B
- Set up LayerDiffuse-Flux in parallel Azure instance
- Test on 5-10 complex characters (fabric, glowing effects)
- Validate output quality vs. Option A
- Document workflow for team

**Phase 3 (Optional):** Keep Option C as fallback
- Use rembg only for edge cases or experimental characters
- Don't overcomplicate pipeline with it as primary path

---

## Action Items for Joaquín

1. **Validate Azure Compatibility:** Confirm LayerDiffuse-Flux can integrate with your Azure AI Foundry setup (may need custom container/weights)
2. **Chroma Key Script:** Build/adapt color-key removal (simple Python: detect green pixels, set alpha=0, export PNG)
3. **Prompt Template:** Standardize your FLUX prompts for fighting game sprites (I can provide template)
4. **Batch Test:** Generate 10-15 characters with Option A, measure edge quality and touch-up time
5. **Reference Asset:** Create a "Character Visual Bible" (style guide + color palette) for consistency

---

## Summary Table: Quick Reference

| Option | Timeline | Complexity | Quality | Best For | Current Viability |
|--------|----------|-----------|---------|----------|------------------|
| A: Chroma Key | Weeks 1-4 | Low | Good (85%) | Batch production | ✅ **Start Now** |
| B: LayerDiffuse | Weeks 2-5 | Moderate | Premium (95%) | Complex characters | 🔄 Prototype Phase 2 |
| C: rembg | Weeks 1-3 | Very Low | Fair-Good (75%) | Edge cases | ⚠️ Fallback Only |
| D: Hybrid | Weeks 1-5 | Moderate | Excellent | Production at scale | 🌟 **Final Goal** |

---

## Closing Notes

Your current approach (green chroma key) is **not only standard—it's the right starting point**. The industry converges on this for good reason: speed, predictability, and control. The only reason to shift is if you hit quality ceilings on complex characters.

LayerDiffuse represents the **next evolution** in transparent asset generation, and since it's emerging now, early adoption could give you a competitive advantage in asset quality. However, it's not a "must-have"—it's a quality multiplier.

**Proceed with confidence on Option A. Plan for Option B as a Phase 2 enhancement.**


---

## Decision: Art Pipeline Workflow — Approval Gate + Design Iterations

### 2026-03-10T07:51Z: User directive — Art pipeline workflow
**By:** Joaquín (via Copilot)
**What:** Art pipeline must follow this flow: (1) Generate hero reference with FLUX 2 Pro at 1024px on transparent/solid-color background — get founder approval on static character design BEFORE proceeding. (2) Use approved hero as Kontext Pro input_image to generate animation frames. (3) FLUX 2 Pro should generate without background from the start — avoid rembg post-processing which "siempre se nota un poquito". Generate multiple design proposals for Kael and Rhena for founder approval.
**Why:** Founder observed rembg artifacts. Better to generate clean from source than fix in post. Also wants design approval gate before frame generation to avoid wasting API calls on wrong designs.


---

## Decision: Green Chroma Key for All FLUX Character Generation

# Decision: Green Chroma Key for All FLUX Character Generation

**Author:** Nien (Character Artist)  
**Date:** 2026-03-12  
**Status:** PROPOSED

## Decision

All FLUX-generated character sprites should use solid bright green (#00FF00) chroma key backgrounds instead of relying on rembg post-processing for background removal.

## Context

The founder (Joaquín) noticed artifacts from rembg's AI-based background removal on previous PoC sprites. Testing with explicit green chroma key prompts on FLUX 2 Pro produced 6/6 images with perfectly clean green backgrounds (100% corner pixel verification).

## Implications

- **Prompt change:** Every character generation prompt must start with "isolated character, full body, solid bright green (#00FF00) chroma key background, no border, no frame, no text"
- **Pipeline change:** Replace rembg step with simple green color-key removal (faster, deterministic, no artifacts)
- **Affects:** Nien (character art), Boba (art direction), anyone running FLUX generation scripts
- **Does NOT affect:** Stage backgrounds, VFX, UI elements (those don't need transparency)

## Hero Design Proposals

Generated 3 design proposals each for Kael and Rhena at 1024×1024:
- `games/ashfall/assets/poc/designs/kael_design_{a,b,c}.png`
- `games/ashfall/assets/poc/designs/rhena_design_{a,b,c}.png`
- Contact sheets: `designs_kael.png`, `designs_rhena.png`

**Awaiting founder approval** before generating animation frames.


---

## Decision: Hero Design Selections Approved

### 2026-03-10T08:45Z: Hero design selections approved
**By:** Joaquín (via Copilot)
**What:** Kael = Design B, Rhena = Design C. These are the locked hero references for all animation frame generation via Kontext Pro. Files: kael_design_b.png and rhena_design_c.png in games/ashfall/assets/poc/designs/
**Why:** Founder selected preferred character designs from 3 proposals each. These become the canonical input_image references for the production art pipeline.



---

# Decision: Automated Visual Test Pipeline for Fight Scene

**Author:** Ackbar (QA/Playtester)  
**Date:** 2025-07-23  
**Status:** Implemented  
**Scope:** Ashfall fight scene QA automation

## Context

The team cannot visually verify the fight scene without manually launching Godot and playing. This blocks AI-based visual analysis and makes regression testing slow and inconsistent.

## Decision

Built a 3-file automated visual test pipeline that captures 7 screenshots of simulated gameplay:

1. **`scripts/test/fight_visual_test.gd`** — Coroutine-based test controller that:
   - Instances the fight scene, waits for FIGHT state via `RoundManager.announce`
   - Simulates 7 gameplay steps using `Input.action_press/release`
   - Captures screenshots with the proven `RenderingServer.frame_post_draw` pattern
   - Saves to both `res://` (project) and `user://` (absolute) paths
   
2. **`scenes/test/fight_visual_test.tscn`** — Minimal scene wrapper
3. **`tools/visual_test.bat`** — One-click launcher

## Key Design Choices

- **Coroutine sequencing over state machine** — `await _wait_frames()` is more readable than tracking step/frame counters in `_process`. Each test step reads as plain English.
- **Signal-based fight detection** — Connects to `RoundManager.announce("FIGHT!")` instead of hardcoding a frame delay. Survives intro timing changes.
- **Tap inputs for attacks, hold for movement** — Attacks press for 1 frame then release (matches real player behavior). Movement holds for the full step duration.
- **Dual output paths** — `res://` for in-project agent access, `user://` for external tool access (CI, Python scripts, etc.)

## Impact

- Any team member or CI system can run `visual_test.bat` to get 7 annotated screenshots
- AI agents can analyze screenshots for visual regressions without manual playtesting
- Pattern is extensible — add new steps to the `_run_test_sequence()` coroutine


---

# Decision: PNG Sprite Integration Standards

**Author:** Chewie (Engine Developer)
**Date:** 2025-07-17
**Scope:** Ashfall sprite system (character_sprite.gd, fighter_base.gd)

## Decisions Made

### 1. PNG Sprite Scale = 0.20
`_PNG_SPRITE_SCALE` set to 0.20 (512px → 102px rendered height, ~1.7x collision box). This provides proper visual presence with the fight scene's dynamic Camera2D zoom (0.75–1.3 range over a 1920×1080 viewport).

### 2. AnimatedSprite2D.flip_h for PNG sprite mirroring
When PNG sprites are active, CharacterSprite.flip_h uses the child AnimatedSprite2D's native `flip_h` property instead of parent `scale.x`. This avoids transform accumulation issues between parent scale and child offset. Procedural _draw() still uses parent `scale.x`.

### 3. All 45+ poses mapped in _POSE_TO_ANIM
Every pose the state machine can emit has an entry in `_POSE_TO_ANIM`. Non-attack poses (hit, block, jump, ko, etc.) map to "idle". Throws/specials map to "punch" or "kick". This guarantees no fallthrough to procedural _draw() when PNG sprites are loaded.

### 4. fighter_base owns CharacterSprite reference
`fighter_base.gd` now finds and stores a `character_sprite: CharacterSprite` reference (by type, not by name). This enables direct facing control from `_update_facing()` alongside the SpriteStateBridge, and ensures correct facing from the first frame via explicit `_update_facing()` call in `fight_scene._ready()`.

## Impact
- Any future CharacterSprite poses added to the state machine MUST also be added to `_POSE_TO_ANIM`.
- New characters extending CharacterSprite automatically inherit these fixes.
- The fight_scene.gd now documents all P1/P2 controls in a header comment block.


---

# Decision: CommunicationAdapter for GitHub Discussions

**Author:** Jango  
**Date:** 2025-07-23  
**Status:** Implemented (partial — category creation requires manual step)

## Context

Joaquín wants an automated devblog where Scribe and Ralph post session summaries to GitHub Discussions after each session. This provides public visibility into what the Squad is working on without manual effort.

## Decision

1. **Channel:** GitHub Discussions (native to the repo, no external services needed)
2. **Config:** Added `communication` block to `.squad/config.json` with:
   - `channel: "github-discussions"`
   - `postAfterSession: true` — Scribe posts after every session
   - `postDecisions: true` — Decision merges get posted
   - `postEscalations: true` — Blockers get visibility
   - `repository: "jperezdelreal/FirstFrameStudios"`
   - `category: "Squad DevLog"` — dedicated category for automated posts
3. **Scribe charter updated** with Communication section defining format, content, and emoji convention
4. **Test post created** at https://github.com/jperezdelreal/FirstFrameStudios/discussions/151

## Manual Action Required

⚠️ **Joaquín must create the "Squad DevLog" discussion category manually:**
1. Go to https://github.com/jperezdelreal/FirstFrameStudios/settings → Discussions
2. Click "New category"
3. Name: `Squad DevLog`
4. Description: `Automated session logs from the Squad AI team`
5. Format: `Announcement` (only maintainers/bots can post, others can comment)
6. Emoji: 🤖

The GitHub API does not support creating discussion categories programmatically. Until this category is created, posts should use "Announcements" as a fallback.

## Alternatives Considered

- **GitHub Issues:** Too noisy, mixes with real bugs/tasks
- **Wiki:** Good for reference docs, bad for chronological updates
- **External blog:** Unnecessary dependency, discussions are built-in

## Impact

- Scribe: New responsibility — post to Discussions after session logging
- Ralph: Can use same channel for heartbeat/status updates
- All agents: Session work becomes publicly visible


---

# Decision: Marketplace Skill Adoption

**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-23  
**Status:** Implemented

## Context

Our `.squad/skills/` directory contained 31 custom skills built in-house for our game dev workflow. The `github/awesome-copilot` and `anthropics/skills` repos offer community-maintained skills covering general development workflows (PRDs, refactoring, context mapping, commit conventions, issue management, etc.) that complement our domain-specific skills.

## Decision

Installed 9 marketplace skills into `.squad/skills/`:

| Skill | Source | Purpose |
|-------|--------|---------|
| `game-engine-web` | github/awesome-copilot | Web game engine patterns (HTML5/Canvas/WebGL) |
| `context-map` | github/awesome-copilot | Map relevant files before making changes |
| `create-technical-spike` | github/awesome-copilot | Time-boxed spike documents for research |
| `refactor-plan` | github/awesome-copilot | Sequenced multi-file refactor planning |
| `prd` | github/awesome-copilot | Product Requirements Documents |
| `conventional-commit` | github/awesome-copilot | Structured commit message generation |
| `github-issues` | github/awesome-copilot | GitHub issue management via MCP |
| `what-context-needed` | github/awesome-copilot | Ask what files are needed before answering |
| `skill-creator` | anthropics/skills | Create and iterate on new skills |

## Naming Convention

When a marketplace skill name collides with an existing local skill, the marketplace version gets a suffix (e.g., `game-engine` → `game-engine-web` because we already had `web-game-engine`).

## Also Fixed

- **squad.config.ts routing**: Was all `@scribe` placeholder. Now routes to correct agents per work type.
- **squad.config.ts casting**: Was wrong universe list. Now `['Star Wars']`.
- **squad.config.ts governance**: Enabled `scribeAutoRuns: true`, added `hooks` with write guards, blocked commands, and PII scrubbing.

## Risks

- Marketplace skills may diverge from upstream — no auto-update mechanism yet. Manual re-fetch needed.
- `skill-creator` from anthropics is large (33KB) — may need trimming if it causes context bloat.

## Follow-up

- Monitor which marketplace skills agents actually invoke — prune unused ones after 2 sprints.
- Consider building a `skill-sync` tool if we adopt more marketplace skills.


---

### Walk/Kick Animation + Hit Reach Fix (Lando)
**Author:** Lando (Gameplay Developer)  
**Date:** 2025-07-23  
**Status:** IMPLEMENTED & VERIFIED  
**Scope:** Animation system, combat reach, hitbox cleanup

#### Problem
Founder tested manually and reported three critical issues:
1. Walk animation not playing — character moves but sprite stays in idle pose
2. Kick animation not playing — pressing kick keys shows punch pose instead
3. Hits don't connect visually — punches don't reach the opponent despite hitbox detection working

#### Root Causes Found

**Walk animation (Issue #1):**
`FighterAnimationController._ready()` accessed `fighter.state_machine` which is an `@onready` variable — null during sibling `_ready()` due to Godot's init ordering (children before parent). The `state_changed` signal was never connected, so the AnimationPlayer stayed on "idle" forever, overwriting all pose changes.

**Kick animation (Issue #2):** Three compounding bugs:
- `_move_to_pose()` mapped kick buttons (lk/mk/hk) to punch poses (attack_lp/mp/hp)
- `_get_attack_pose()` used case-sensitive matching (`"lk" in "Standing LK"` → false)
- Both movesets had no standing LK (only Crouching LK with `requires_crouch=true`)

**Hit reach (Issue #3):**
Fighters at x=200 and x=440 (240px gap). Hitbox extends 176px from origin, hurtbox starts 48px from target. Maximum reachable gap is 224px — the 240px gap exceeded it by 16px.

#### Changes Made
| File | Change |
|------|--------|
| `fighter_animation_controller.gd` | Access StateMachine node directly; fix `_move_to_pose()` kick mapping; stop AnimationPlayer on fallback instead of playing "hit" |
| `sprite_state_bridge.gd` | Add `.to_lower()` to move name in `_get_attack_pose()` |
| `character_sprite.gd` | Fix `flip_h` setter to use `AnimatedSprite2D.flip_h` for PNG sprites |
| `fight_scene.tscn` | Move Fighter2 from x=440 to x=400 |
| `kael_moveset.tres` | Add Standing LK (5f/3f/8f, 35 dmg) |
| `rhena_moveset.tres` | Add Standing LK (4f/3f/8f, 35 dmg) |
| `attack_state.gd` | Use `set_deferred` for hitbox deactivation during physics callbacks |
| `hitbox.gd` | Use `set_deferred` in `deactivate()` |

#### Verification
- `visual_test.bat`: 7/7 screenshots captured, walk shows `pose=walk → anim=walk`, kick shows `pose=attack_lk → anim=kick`, punch connects (`[Hitbox] HIT!`), no physics errors, no animation flickering
- `play.bat --quit-after 8`: Clean run, PNG sprites load for both characters

#### Known Remaining Issues
- AnimationMixer warning about string blending for "Ember Shot" (harmless, Godot internal)
- Throw animation has similar AnimationPlayer vs SpriteStateBridge pose conflict (not reported, lower priority)


---

# Decision: Combat Hitbox Scaling for PNG Sprites

**Author:** Lando (Gameplay Developer)
**Date:** 2026-07-22
**Status:** Implemented & Verified

## Context

The sprite pipeline recently upgraded from ~60px procedural canvas drawings to ~282px pre-rendered PNG sprites (512px at 0.55 scale). The collision system (hitboxes, hurtboxes, body collision) was never updated to match, breaking all combat — attacks animated but dealt no damage.

## Decision

Scale all fighter collision shapes by 3.67× (282px / ~77px procedural) and fix hitbox directional flipping.

### Specific Values

| Shape | Old Size | New Size | Old Position | New Position |
|-------|----------|----------|--------------|--------------|
| Body collision | 30×60 | 110×220 | (0, -30) | (0, -110) |
| Hurtbox | 26×56 | 96×206 | (0, -28) | (0, -103) |
| Hitbox | 36×24 | 132×88 | (30, -30) | (110, -110) |
| AttackOrigin | — | — | (30, -30) | (110, -110) |
| Sprite (legacy) | — | — | (0, -30) | (0, -141) |

### Hitbox Flipping

Added `shape.position.x = absf(shape.position.x) * fighter.facing_direction` in `attack_state._activate_hitboxes()` so hitboxes extend toward the opponent regardless of which side the attacker faces.

## Files Changed

- `games/ashfall/scenes/fighters/kael.tscn` — collision shape sizes + positions
- `games/ashfall/scenes/fighters/rhena.tscn` — collision shape sizes + positions
- `games/ashfall/scenes/fighters/fighter_base.tscn` — template consistency
- `games/ashfall/scripts/fighters/states/attack_state.gd` — hitbox direction flip
- `games/ashfall/scripts/systems/hitbox.gd` — debug print on hit

## Verification

- `visual_test.bat`: All 7 screenshots pass. Console confirms `[Hitbox] HIT! Fighter1 → Fighter2 | dmg=50`.
- `play.bat --quit-after 5`: Clean exit, no errors.
- Walk animation confirmed rendering with PNG sprites.

## Future Consideration

Any time sprite scale changes, collision shapes must be re-calibrated. Consider extracting collision dimensions into a shared constant or resource so they track sprite scale automatically.


---

# Lando — Gameplay Bug Fixes

**Author:** Lando (Gameplay Developer)
**Date:** 2026-07-22
**Status:** IMPLEMENTED
**Scope:** Fighter facing, AI controller, walk animation

## Changes Made

### 1. Facing Direction Fix (character_sprite.gd, fighter_base.gd)
Removed the `if flip_h != value` guard from the `flip_h` setter in `character_sprite.gd`. The guard prevented initial facing propagation when the desired value (false for P1) matched the default. Also hide the legacy `$Sprite` (Sprite2D) node when PNG sprites are active.

**Impact on Team:**
- Chewie: No action needed. The setter now always propagates — slightly more calls but zero-cost (one bool assignment per frame).
- Boba: No visual change — sprites were already correct once the game ran for one frame. This fixes the first-frame glitch.

### 2. AI Controller Wiring (fight_scene.gd, ai_controller.gd)
Wired the existing `AIController` to Fighter2 (Rhena) in `fight_scene.gd`. Fixed `PROTECTED_STATES` array to match actual state node names (`attack` not `attackstate`, etc.).

**Impact on Team:**
- Yoda: The AI uses Normal difficulty by default. Difficulty can be tuned via the `AIController.Difficulty` enum.
- Ackbar: CPU opponent is now active — visual tests and QA runs will show P2 fighting back.

### 3. Walk Animation Timing Fix (fighter_animation_controller.gd)
Added `_set_initial_pose()` that immediately sets the CharacterSprite pose on state change, closing the one-frame gap before AnimationPlayer evaluates its property tracks. Applied to idle, walk, crouch, and jump transitions.

**Impact on Team:**
- All agents: Animation transitions now feel one frame tighter. No action needed.


---

# Decision: Instance FightHUD in fight_scene.tscn (not runtime)

**Date:** 2025-07-22
**Author:** Wedge (UI/UX Developer)
**Status:** Implemented

## Context

The FightHUD (`scenes/ui/fight_hud.tscn`) was fully implemented but never added to the fight scene tree. The fight scene had Stage, Fighters, and Camera2D — no HUD.

## Decision

Instance `fight_hud.tscn` directly in `fight_scene.tscn` rather than loading at runtime in GDScript.

**Reasons:**
1. The HUD is fully self-contained — it connects all 11 EventBus signals in its own `_ready()` via `_wire_signals()`. No external setup needed.
2. Scene-tree instancing is visible in the Godot editor, making the scene hierarchy inspectable.
3. The CanvasLayer (layer=10) ensures it renders above everything regardless of camera — no z-index coordination required.
4. `@onready` references resolve before `_ready()` runs, so fight_scene.gd can set name labels immediately.

## What Changed

- `fight_scene.tscn`: Added ext_resource for `fight_hud.tscn`, instanced as `FightHUD` child node
- `fight_scene.gd`: Added `@onready var hud` reference, set P1/P2 name labels from `SceneManager.p1_character`/`p2_character`

## Signal Verification

All 11 EventBus signals the HUD connects to are defined and emitted by existing systems (fight_scene.gd, RoundManager, ComboTracker). No missing signals.



---

### 2026-03-11T09:53: User directive
**By:** Joaquín (via Copilot)
**What:** FFS is the Studio Hub only. No game code in FFS — active games live in their own repos (ComeRosquillas, Flora). Games should be documented as Active Projects with links, not stored in /games. The /games folder is only for archived/local games (Ashfall, firstPunch).
**Why:** User correction — establishes clean hub architecture. Issues belong in game repos, not the hub.


---

### 2026-03-11: Replace Jekyll Docs with Astro Site (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Requested by:** Joaquín  
**Status:** ✅ Implemented

**Context:**
Joaquín wanted a site inspired by Brady Gaster's Squad docs (https://bradygaster.github.io/squad/) — modern, dark, polished. The existing Jekyll setup in docs/ was a bare minima theme with limited appeal for a game studio.

**Decision:**
Replaced Jekyll with Astro 6 + Tailwind CSS v4. Created a full studio site with:
- Landing page: hero, feature cards, project cards, "how it works" steps, archived games
- Blog section with Astro content collections (glob loader)
- BaseLayout with glassmorphism header, mobile nav, dark theme
- GitHub Actions workflow for automated deployment to GitHub Pages

**Rationale:**
- **Astro** — static site generator with near-zero JS shipped, great for content sites
- **Tailwind CSS v4** — utility-first CSS, rapid iteration without separate CSS files
- **Dark theme** — game studios look better dark; matches the industry aesthetic
- **Content collections** — type-safe blog posts, easy to add more posts over time
- **GitHub Actions** — automated deploy on push to main (only when docs/ changes)

**Technical Notes:**
- `@astrojs/tailwind` integration does NOT support Astro 6 (peer dep: astro ≤5). Use `@tailwindcss/vite` plugin directly in `astro.config.mjs`
- Content collections in Astro 5+/6 require `glob` loader from `astro/loaders`, not `type: 'content'`
- Site config: `site: 'https://jperezdelreal.github.io'`, `base: '/FirstFrameStudios'`

**Links:**
- Site: https://jperezdelreal.github.io/FirstFrameStudios/
- Workflow: `.github/workflows/deploy-pages.yml`
- Inspiration: https://bradygaster.github.io/squad/


---

# Decision: GitHub Pages Blog Setup

**Author:** Jango (Tool Engineer)
**Date:** 2026-07-24
**Status:** Implemented

## Decision

Set up GitHub Pages for FirstFrameStudios as a Jekyll-powered studio dev blog, served from `/docs` on main branch.

## Rationale

- **Jekyll** chosen because GitHub Pages has native support — zero CI workflow needed, no build step to maintain
- **minima theme** — clean, readable, blog-focused. Can upgrade to `just-the-docs` later if we need more structure
- **`/docs` on main branch** — simpler than a `gh-pages` branch. All content lives alongside the codebase
- **Blog format** — dev diary posts in `_posts/` with frontmatter, auto-indexed on homepage

## What Was Created

- `docs/_config.yml` — Jekyll config with minima theme
- `docs/index.md` — Homepage with studio info, project links, team description
- `docs/about.md` — About page with philosophy and journey
- `docs/_posts/2026-03-11-studio-launch.md` — Launch announcement blog post
- `docs/Gemfile` — GitHub Pages gem dependencies

## URL

https://jperezdelreal.github.io/FirstFrameStudios/

## Impact

- All agents can now add blog posts by creating files in `docs/_posts/YYYY-MM-DD-title.md`
- Mace (Scribe) should own blog content going forward — dev diaries, milestone posts
- README.md updated with blog link in Quick Links


---

# Decision: ralph-watch.ps1 v2 Upgrade

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Status:** IMPLEMENTED
**Requested by:** Joaquin

## Context

Joaquin reviewed Tamir Dresher's squad-personal-demo repo and found our `ralph-watch.ps1` was missing four production-grade features that Tamir's implementation had. Our script was 233 lines with the basics (mutex, heartbeat, git pull, scheduler, log rotation, dry run, multi-repo param). It needed failure alerting, background monitoring, smarter defaults, and metrics extraction.

## Decision

Upgrade `tools/ralph-watch.ps1` to v2 with all four missing features, keeping the script ASCII-safe for Windows PowerShell 5.1 compatibility.

## Changes Made

### 1. Failure Alerts
- Added `$consecutiveFailures` counter and `$alertThreshold = 3`
- `Write-FailureAlert` function writes structured JSON alerts to `tools/logs/alerts.json`
- Each alert includes timestamp, level, round, failure count, exit code, error detail
- Keeps last 50 alerts (rolling window)
- Counter resets to 0 on successful round
- Future upgrade path: swap file writes for Teams webhook calls when webhook URL is configured

### 2. Background Activity Monitor
- `Start-ActivityMonitor` creates a PowerShell runspace that prints status every 30 seconds
- Shows elapsed time and today's log entry count -- prevents silent terminal during long sessions
- `Stop-ActivityMonitor` cleanly disposes runspace on round completion or exception
- Used runspace (not background job) for lower overhead and same-process lifecycle

### 3. Multi-Repo Defaults
- Default `$Repos` now includes all 4 FFS repos: `.`, `../ComeRosquillas`, `../flora`, `../ffs-squad-monitor`
- Ralph prompt now includes `MULTI-REPO WATCH` section listing all repos
- Startup validates repo paths and shows which repos were skipped (not found)
- Falls back to current directory if no repos resolve

### 4. Metrics Parsing
- `Get-SessionMetrics` parses copilot output with regex for: issues closed, PRs merged, PRs opened, commits
- Handles multiple phrasings (e.g., "closed 3 issues", "3 issues closed", "issues closed: 3")
- Metrics included in JSONL log entries and heartbeat file
- Shown in round completion line: `[issues=N prs_merged=N prs_opened=N]`

## Trade-offs

| Choice | Alternative | Why |
|--------|------------|-----|
| File-based alerts (alerts.json) | Teams webhook directly | We don't have webhook URL configured yet; file alerts work offline and can be read by ffs-squad-monitor |
| PowerShell runspace | Background job | Runspace is lighter weight, same process, cleaner shutdown semantics |
| Regex metrics parsing | Structured copilot output | Copilot CLI doesn't emit structured data; regex is best-effort but captures common patterns |
| ASCII-only text | Unicode/emoji markers | Windows PowerShell 5.1 reads .ps1 files as Windows-1252 without UTF-8 BOM, breaking emoji bytes |

## Verification

```powershell
.\tools\ralph-watch.ps1 -DryRun -MaxRounds 1
```

Clean pass: all 4 repos resolved, scheduler ran, heartbeat written with metrics and repo list.

## Impact

- Script: 233 -> 454 lines
- No new dependencies
- Backward compatible (all new params have defaults)
- Heartbeat file format extended (new fields: repos, consecutiveFailures, metrics)


---

# 🏗️ CEREMONY: Studio Restructure Review

**Ceremony Type:** Major — Studio-Wide Restructuring  
**Facilitator:** Solo (Lead / Chief Architect)  
**Requested by:** Joaquín  
**Date:** 2026-07-24  
**Status:** ✅ APPROVED by Joaquin (2026-03-11)

---

## Context

Today the studio completed a massive architectural pivot:
- **Monorepo → Multi-repo hub** (Option C Hybrid implemented)
- **FFS became Studio Hub** — no game code
- **ComeRosquillas** → own repo (jperezdelreal/ComeRosquillas, 8 open issues)
- **Flora** → own repo (jperezdelreal/flora, 0 open issues)
- **ffs-squad-monitor** → tool repo (jperezdelreal/ffs-squad-monitor, 5 open issues)
- **ralph-watch.ps1** upgraded to v2 (401 lines, multi-repo, failure alerts)
- **GitHub Pages** site deployed with Astro
- **8 game issues** migrated FFS → ComeRosquillas
- **4 infra issues** remain in FFS hub

This ceremony audits everything that needs to change now that we're a multi-repo studio, not a monorepo with game code.

---

## 1. TEAM DISTRIBUTION AUDIT

### Current State

18 entities on the roster (team.md):
- **15 named agents:** Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien, Jango, Mace, Scribe
- **2 system roles:** Ralph (Work Monitor), @copilot (Coding Agent)
- **All 15 listed as 🟢 Active** — no hibernated agents

### Problems

1. **5 agents were created for Ashfall/Godot art pipeline** and have no meaningful work in the current web stack:
   - **Boba (Art Director)** — built for Blender/FLUX sprite pipeline. ComeRosquillas uses emoji sprites. Flora uses PixiJS built-in.
   - **Leia (Environment Artist)** — built for Godot environment scenes. Web games use CSS/Canvas/tilemap backgrounds.
   - **Bossk (VFX Artist)** — built for Godot particle systems. Web VFX = Canvas/CSS animations.
   - **Nien (Character Artist)** — built for FLUX character generation and Godot procedural sprites. No FLUX pipeline exists for current projects.
   - **Greedo (Sound Designer)** — *exception:* charter is already generalized. ComeRosquillas has procedural audio. KEEP active.

2. **team.md still says "Active Games: FLORA (planned — repo pending)"** — stale. ComeRosquillas is the active game. Flora repo exists.

3. **@copilot capability profile still lists "GDScript / Godot work 🟡"** — no Godot work exists anymore.

4. **now.md says "ComeRosquillas: games/comerosquillas/"** — stale path, it's now in its own repo.

### Actions

| Action | Agent | Priority |
|--------|-------|----------|
| **HIBERNATE** Boba, Leia, Bossk, Nien — move to "Hibernated" section in team.md | Solo | P0 |
| **KEEP ACTIVE** (11): Solo, Chewie, Lando, Wedge, Greedo, Tarkin, Ackbar, Yoda, Jango, Mace, Scribe + Ralph + @copilot | — | — |
| Update team.md "Active Games" to list ComeRosquillas + Flora + Squad Monitor | Solo | P0 |
| Update @copilot capability profile: remove GDScript, add HTML/JS/Canvas, TypeScript/Vite/PixiJS | Solo | P1 |
| Update now.md: remove `games/comerosquillas/` path, link to external repos correctly | Solo | P0 |
| **NO NEW ROLES NEEDED** — web stack is simpler, current 11 agents cover all domains | — | — |

### Proposed Lean Roster (11 active + 4 hibernated)

| Name | Role | Status | Why |
|------|------|--------|-----|
| Solo | Lead / Chief Architect | 🏗️ Active | Always needed |
| Chewie | Engine Dev | 🔧 Active | Game loop, renderer, engine systems (any stack) |
| Lando | Gameplay Dev | ⚔️ Active | Player mechanics, combat, game logic |
| Wedge | UI Dev | ⚛️ Active | HUD, menus, screens, web UI |
| Greedo | Sound Designer | 🔊 Active | Web Audio API, procedural sound |
| Tarkin | Enemy/Content Dev | 👾 Active | Enemy AI, content, level design |
| Ackbar | QA/Playtester | 🧪 Active | Browser testing, game feel |
| Yoda | Game Designer | 🎯 Active | Vision keeper, GDD, feature triage |
| Jango | Tool Engineer | ⚙️ Active | ralph-watch, scheduler, CI/CD, build tooling |
| Mace | Producer | 📊 Active | Sprint planning, ops, blocker management |
| Scribe | Session Logger | 📋 Active | Automatic documentation |
| Ralph | Work Monitor | 🔄 Monitor | Autonomous loop |
| @copilot | Coding Agent | 🤖 Active | Issue execution |
| Boba | Art Director | ❄️ Hibernated | Wake when art pipeline needed |
| Leia | Environment Artist | ❄️ Hibernated | Wake when environment art needed |
| Bossk | VFX Artist | ❄️ Hibernated | Wake when dedicated VFX needed |
| Nien | Character Artist | ❄️ Hibernated | Wake when character art pipeline needed |

---

## 2. FFS HUB CLEANUP AUDIT

### Current State

The hub repo still contains massive monorepo leftovers:

| Item | Size | Files | Status |
|------|------|-------|--------|
| `games/ashfall/` | **1,625 MB** | **6,071** | ❌ Godot project + .godot cache. MUST DELETE. |
| `games/first-punch/` | 394 KB | 33 | ❌ Archived Canvas game. SHOULD DELETE. |
| `tools/*.py` (12 scripts) | ~50 KB | 12 | ❌ All Godot-specific validators/generators |
| `tools/create_tool_issues.ps1` | ~5 KB | 1 | ❌ One-time script, already executed |
| `tools/pr-body.txt` | ~1 KB | 1 | ❌ One-time PR body text |
| `tools/create-pr.md` | ~2 KB | 1 | ❌ One-time PR template |
| `tools/TODO-create-issues.md` | ~2 KB | 1 | ❌ One-time task list |

**Godot-specific GitHub workflows (3):**
- `.github/workflows/godot-project-guard.yml` — watches `games/ashfall/project.godot`
- `.github/workflows/godot-release.yml` — builds Godot exports with ashfall tags
- `.github/workflows/integration-gate.yml` — GDScript linting and type checking

**Godot-specific skills (8):**
- `gdscript-godot46` — GDScript 4.6 patterns
- `godot-4-manual` — Godot 4 manual reference
- `godot-beat-em-up-patterns` — Godot fighting game patterns
- `godot-project-integration` — Godot multi-agent integration
- `godot-tooling` — Godot EditorPlugins, autoloads
- `godot-visual-testing` — Godot viewport testing
- `code-review-checklist` — GDScript-focused review
- `project-conventions` — Godot file/scene conventions

**Stale agent charters (2 heavily Godot-locked):**
- Jango's charter references `project.godot`, autoloads, GDScript conventions, EditorPlugin, `.tres`
- Solo's charter examples reference Godot scene trees, nodes, signals (patterns are generic but examples are Godot)

**Context bloat:**
- `decisions.md` = **2,341 lines, 164 KB, 161 entries** — ~70% Ashfall-specific
- `solo/history.md` = **356 lines, 38 KB** — ~60% Ashfall/firstPunch specific

### Problems

1. **games/ashfall/ is 1.6 GB** — this is the single biggest cleanup item. The .godot cache alone is massive.
2. **12 Python tools are all Godot-specific** — check-autoloads, check-signals, check-scenes, validate-project, etc. None work for web games.
3. **3 GitHub workflows will never trigger** since Godot paths and tags don't exist in the hub.
4. **8 skills are Godot-specific** but contain valuable patterns if we ever return to Godot. Should be archived, not deleted.
5. **decisions.md is dangerously bloated** at 164 KB. This wastes context tokens every session.

### Actions

| Action | Priority |
|--------|----------|
| **DELETE `games/ashfall/`** — 1.6 GB of Godot files. No game code in hub. | P0 |
| **DELETE `games/first-punch/`** — archived Canvas prototype. Already in git history. | P0 |
| **DELETE 12 Godot Python tools** from `tools/` (keep ralph-watch.ps1, scheduler/, README.md, logs/, .ralph-heartbeat.json) | P0 |
| **DELETE one-time scripts** (create_tool_issues.ps1, pr-body.txt, create-pr.md, TODO-create-issues.md) | P0 |
| **DELETE 3 Godot workflows** (godot-project-guard.yml, godot-release.yml, integration-gate.yml) | P0 |
| **ARCHIVE 8 Godot skills** → move to `.squad/skills/_archived/` (preserve knowledge) | P1 |
| **ARCHIVE Ashfall decisions** from decisions.md → decisions-archive.md (keep ~15 active decisions) | P1 |
| **RUN `squad nap --deep`** on Solo and decisions to compress context | P1 |
| Update Jango's charter for web tooling stack | P1 |
| Update Solo's charter examples for web architecture | P1 |

---

## 3. HUB PURPOSE DEFINITION

### Mission Statement

> **FirstFrameStudios is the Studio Hub** — the central nervous system for all FFS projects. It holds studio identity, shared skills, team infrastructure, and cross-project tools. No game code lives here; games inherit studio DNA via `squad upstream` and live in their own repositories.

### What SHOULD Live in the Hub

| Category | Contents |
|----------|----------|
| **Studio Identity** | `.squad/identity/` (principles, mission-vision, company, quality-gates, wisdom) |
| **Team Definition** | `.squad/team.md`, `.squad/routing.md`, `.squad/agents/` |
| **Cross-Project Skills** | `.squad/skills/` (only universal/web skills — 32 after archiving 8 Godot) |
| **Shared Tools** | `tools/ralph-watch.ps1`, `tools/scheduler/`, `tools/README.md` |
| **Docs Site** | `docs/` (Astro site deployed to GitHub Pages) |
| **Studio Decisions** | `.squad/decisions.md` (studio-level only) |
| **Hub Workflows** | `.github/workflows/` (label-sync, heartbeat, triage, deploy-pages, etc.) |
| **Repo Config** | `README.md`, `CONTRIBUTING.md`, `CODEOWNERS`, `squad.config.ts`, `.editorconfig` |

### What Should NOT Be in the Hub

| Category | Where It Belongs |
|----------|-----------------|
| Game source code | Game repos (ComeRosquillas, Flora) |
| Game-specific issues | Game repos |
| Game-specific workflows | Game repos |
| Game-specific tools | Game repos or tool repos |
| Godot projects/files | Nowhere (archived project) |
| Game-specific decisions | Game repo `.squad/decisions.md` |

### Ideal Folder Structure (Post-Cleanup)

```
FirstFrameStudios/
├── .copilot/
│   └── mcp-config.json          # MCP server configuration
├── .github/
│   ├── agents/squad.agent.md    # Copilot agent definition
│   ├── ISSUE_TEMPLATE/          # Hub issue templates
│   ├── workflows/               # Hub-level workflows only (no Godot)
│   └── pull_request_template.md
├── .squad/
│   ├── agents/                  # All 15 agent charters
│   ├── decisions/               # Inbox + archive
│   ├── identity/                # Studio identity documents
│   ├── skills/                  # Cross-project + web skills only
│   │   └── _archived/           # Godot skills preserved
│   ├── config.json
│   ├── decisions.md             # Active decisions (slim — <50 entries)
│   ├── routing.md
│   └── team.md
├── docs/                        # Astro site (GitHub Pages)
├── tools/
│   ├── ralph-watch.ps1          # v2 autonomous loop
│   ├── scheduler/               # Cron-based task scheduler
│   ├── logs/                    # Ralph structured logs
│   ├── .ralph-heartbeat.json
│   └── README.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── README.md
└── squad.config.ts
```

---

## 4. TOOLS / PLUGINS / MCP AUDIT

### Current State

| Tool | Location | Status | Notes |
|------|----------|--------|-------|
| ralph-watch.ps1 v2 | `tools/ralph-watch.ps1` | ✅ Production-ready | 401 lines, multi-repo, failure alerts, activity monitor |
| Scheduler | `tools/scheduler/` | ✅ Operational | 4 recurring tasks defined (playtest, retro, grooming, browser compat) |
| Squad Monitor | jperezdelreal/ffs-squad-monitor | ⚠️ Repo exists, scaffold only | 5 open issues, Vite+JS stack |
| 12 Python scripts | `tools/*.py` | ❌ All Godot-specific | Should be deleted |
| Astro docs site | `docs/` | ✅ Deployed | GitHub Pages active |

**MCP Configuration (`.copilot/mcp-config.json`):**
```json
{
  "mcpServers": {
    "EXAMPLE-trello": { ... }  // ← Not configured, just an example
  }
}
```
**Problem:** MCP is not actually configured. Just a Trello example placeholder.

### What Tamir Has That We Don't

| Pattern | Tamir | FFS | Gap |
|---------|-------|-----|-----|
| ralph-watch outer loop | ✅ | ✅ | Parity |
| Self-built scheduler | ✅ | ✅ | Parity |
| Squad Monitor dashboard | ✅ (dotnet tool) | ⚠️ (Vite scaffold) | Implementation gap |
| Teams/Discord webhooks | ✅ (Adaptive Cards) | ❌ | Missing entirely |
| Podcaster (Edge TTS) | ✅ | ❌ | Nice to have |
| Email/Teams scanning | ✅ (Outlook COM) | ❌ | Overkill for us |
| CLI Tunnel | ✅ | ❌ | Not needed |
| GitHub Actions ecosystem | ✅ (12+ workflows) | ✅ (22 workflows) | We have MORE |
| Cross-repo contributions | ✅ | ❌ | Future opportunity |

### Actions

| Action | Priority |
|--------|----------|
| **DELETE 12 Godot Python scripts** from tools/ | P0 |
| **Configure MCP properly** — remove Trello example, add useful servers (GitHub, or leave empty) | P1 |
| **Add Discord webhook** for critical notifications (CI failures, PR merges, P0 issues) | P1 |
| **Build out ffs-squad-monitor** — the scaffold exists, 5 issues are filed | P2 |
| **Evaluate Podcaster** — useful for Joaquín consuming long reports | P2 |
| **Skip:** Email scanning (we don't use email), CLI Tunnel (not needed) | — |

---

## 5. ROUTING TABLE UPDATE

### Current State

routing.md has these stale references:
- **Jango row:** "EditorPlugins, scene templates, GDScript style guide, build/export automation, project.godot config, linting, asset pipelines"
- **Solo row:** "scene tree conventions"
- **Integration gates:** "After every parallel agent wave — verify systems connect, signals wired, project loads"
- **Post-merge smoke test:** "open Godot, run full game flow, verify end-to-end"
- **No multi-repo routing** — doesn't say which issues go where
- **No web tech routing** — no mention of HTML, Canvas, PixiJS, Vite, TypeScript

### Problems

1. Routing still assumes a single Godot project
2. No guidance for multi-repo issue triage
3. Web technology work types not represented
4. @copilot capability profile references Godot

### Actions

| Action | Priority |
|--------|----------|
| **Rewrite routing table** for web game stack | P0 |
| **Add multi-repo routing section** (which issues go where) | P0 |
| **Update integration gates** for browser-based testing | P1 |
| **Update @copilot capability profile** | P1 |

### Proposed Routing Table

```markdown
## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Game engine, loop, timing, systems | Chewie | Game loop, renderer, input, animation system, physics, collision |
| Player mechanics, combat, abilities | Lando | Player entity, combat system, special moves, player state machine |
| Enemy AI, content, levels, pickups | Tarkin | Enemy types, boss patterns, wave/level design, pickups, difficulty |
| UI, HUD, menus, screens, web layout | Wedge | HUD, title screen, game over, pause, score displays, CSS/HTML |
| Audio, SFX, music, sound design | Greedo | Sound effects, procedural music, Web Audio API, audio events |
| QA, playtesting, balance, browser testing | Ackbar | Playtesting, combat feel, cross-browser, regression, edge cases |
| Tooling, CI/CD, workflows, build pipelines | Jango | GitHub workflows, ralph-watch, scheduler, build automation |
| Architecture, integration review | Solo | Project structure, integration verification, decisions, architecture |
| Ops, blockers, branch management | Mace | Blocker tracking, branch rebasing, stale issue cleanup |
| Sprint planning, timelines, workload | Mace | Sprint planning, milestone tracking, scope management |
| Feature triage, scope decisions | Yoda + Mace | Vision Keeper evaluates features against four-test framework |
| Async issue work (bugs, tests, features) | @copilot 🤖 | Well-defined tasks: HTML/JS/Canvas, TypeScript, Vite, PixiJS |

## Multi-Repo Issue Routing

| Issue About | Goes To | Examples |
|-------------|---------|----------|
| ComeRosquillas gameplay/bugs | jperezdelreal/ComeRosquillas | Ghost AI, scoring, maze layout, mobile controls |
| Flora gameplay/bugs | jperezdelreal/flora | PixiJS systems, gardening mechanics, roguelite features |
| Squad Monitor features | jperezdelreal/ffs-squad-monitor | Dashboard UI, heartbeat reader, log viewer |
| Studio infra / tooling | jperezdelreal/FirstFrameStudios | ralph-watch, scheduler, team changes, docs site |
| Cross-project process | jperezdelreal/FirstFrameStudios | Ceremonies, skills, team decisions, routing |
```

---

## 6. SKILLS AUDIT

### Current State

41 skills in `.squad/skills/`. Classified:

| Classification | Count | Skills |
|----------------|-------|--------|
| **GODOT-SPECIFIC** | 8 | gdscript-godot46, godot-4-manual, godot-beat-em-up-patterns, godot-project-integration, godot-tooling, godot-visual-testing, code-review-checklist, project-conventions |
| **WEB-GAME** | 5 | 2d-game-art, canvas-2d-optimization, game-engine-web, procedural-audio, web-game-engine |
| **CROSS-PROJECT** | 28 | animation-for-games, beat-em-up-combat, context-map, conventional-commit, create-technical-spike, enemy-encounter-design, feature-triage, fighting-game-design, game-audio-design, game-design-fundamentals, game-feel-juice, game-qa-testing, github-issues, github-pr-workflow, input-handling, integration-discipline, level-design-fundamentals, milestone-completion-checklist, multi-agent-coordination, parallel-agent-workflow, prd, refactor-plan, skill-creator, squad-conventions, state-machine-patterns, studio-craft, ui-ux-patterns, what-context-needed |

### Problems

1. **8 Godot skills waste context** when loaded by agents working on web games
2. **No PixiJS skill** exists for Flora (Vite + TypeScript + PixiJS)
3. **No web deployment skill** (GitHub Pages, itch.io, Netlify)
4. **canvas-2d-optimization and web-game-engine overlap** — previous audit recommended merging
5. **code-review-checklist is Godot-locked** — should have a web version

### Actions

| Action | Priority |
|--------|----------|
| **ARCHIVE 8 Godot skills** → `.squad/skills/_archived/` | P1 |
| **CREATE `web-code-review`** — HTML/JS/TS review checklist replacing Godot-focused one | P1 |
| **CREATE `pixijs-patterns`** — PixiJS game patterns for Flora (when Flora activates) | P2 |
| **CREATE `web-game-deployment`** — GitHub Pages, itch.io, Netlify deployment patterns | P2 |
| **MERGE** canvas-2d-optimization into web-game-engine (redundant overlap) | P2 |
| **KEEP ALL 28 cross-project skills** — these are the studio's institutional knowledge | — |
| **KEEP ALL 5 web-game skills** — directly relevant to current projects | — |

---

## 7. DECISIONS CLEANUP

### Current State

`decisions.md`: **2,341 lines, 164 KB, ~161 decision entries**

This is dangerously bloated. Context tokens are wasted loading Ashfall-specific decisions that will never be referenced again.

### Classification

**ARCHIVE (Ashfall/firstPunch-specific, ~30+ entries):**
- Cel-Shade Parameters (Boba)
- Cel-Shade Pipeline Standardization (Chewie)
- Ashfall GDD v1.0 (Yoda)
- Ashfall Architecture (Solo)
- Sprint 0 Scope & Milestones (Mace)
- All Sprint 0 Closure Decisions (M4 gate, Combat fix, Draw state, HUD sync)
- Procedural Sprite System (Nien)
- Sprite Brief v3 (Boba)
- Asset Naming Convention (Ashfall-specific)
- FLUX decisions (3 entries)
- Sprint 1 Bug Catalog
- Jango M1+M2 Retrospective
- Sprint Definition of Success (Ashfall context)
- Game Architecture — McManus/firstPunch
- Core Gameplay Bug Fixes — firstPunch
- Full Codebase Analysis — firstPunch
- All Ashfall user directives (game type pivot, 1080p, FLUX for stages/HUD)
- P0 Combat Pipeline Integration Fix (Lando)
- Equal-HP Draw State (Chewie)
- HUD Score Sync Architecture (Wedge)
- Sprint 0 Milestone Status (Mace)
- Game Resolution 1080p directive
- Sprite Animation Consistency Research (Solo)

**KEEP (studio-level, multi-project, ~15 entries):**
- ffs-squad-monitor creation ✅
- Squad Upstream Setup — ComeRosquillas ✅
- Tamir Blog Learnings (16 operational patterns) ✅
- Side Project Repo Autonomy directive ✅
- Visual Quality Standard directive ✅
- Ashfall Closure (historical reference) ✅
- Solo Role Split (process improvement) ✅
- Autonomy Gap Audit ✅
- ComeRosquillas Infrastructure Pivot ✅
- New Project Proposals Ceremony ✅
- Documentation & Terminology Clarity ✅
- Option C Hybrid Architecture ✅
- Tool & Skill Development Autonomy ✅
- Team Expansion (historical) ✅
- New Project Playbook (studio-level) ✅

### Problems

1. **164 KB is ~5x the recommended size** for a decisions file
2. Most entries are Ashfall-specific and will never be referenced
3. Context tokens wasted loading this in every session
4. New agents get confused by Godot-specific decisions when working on web games

### Actions

| Action | Priority |
|--------|----------|
| **MASS ARCHIVE** Ashfall/firstPunch decisions → `decisions-archive.md` | P0 |
| **KEEP ~15 active decisions** in decisions.md (studio-level only) | P0 |
| **Target: decisions.md under 30 KB** after cleanup | P0 |
| **Run `squad nap --deep`** on history files | P1 |

---

## SUMMARY: TOP 10 ACTIONS BY PRIORITY

| # | Action | Priority | Impact | Owner |
|---|--------|----------|--------|-------|
| 1 | **DELETE `games/ashfall/`** (1.6 GB, 6071 files) | P0 | Removes 99% of repo bloat. Hub should have zero game code. | Jango |
| 2 | **DELETE `games/first-punch/`** (33 files) | P0 | Complete the hub cleanup. Git history preserves everything. | Jango |
| 3 | **ARCHIVE Ashfall decisions** from decisions.md → decisions-archive.md. Target <30 KB active. | P0 | Stops wasting context tokens. Every session loads this file. | Solo |
| 4 | **DELETE 12 Godot Python tools + 3 Godot workflows** from hub | P0 | Removes confusing dead code. Only ralph-watch/scheduler should remain. | Jango |
| 5 | **UPDATE team.md** — hibernate Boba/Leia/Bossk/Nien, update project context | P0 | Prevents agents from routing work to hibernated roles. | Solo |
| 6 | **UPDATE now.md** — fix stale ComeRosquillas path, update status accurately | P0 | Every session reads this first. Must be correct. | Solo |
| 7 | **REWRITE routing.md** for web game stack + multi-repo routing | P0 | Agents need to know where to send work across 4 repos. | Solo |
| 8 | **ARCHIVE 8 Godot skills** → `.squad/skills/_archived/` | P1 | Preserves knowledge while keeping active skills relevant. | Jango |
| 9 | **UPDATE Jango + Solo charters** — remove Godot references | P1 | Charters guide agent behavior. Must match current stack. | Solo |
| 10 | **Configure Discord webhook** for critical notifications | P1 | Highest-leverage unbuilt feature. Joaquín needs proactive alerts. | Jango |

### Quick Wins (bonus — can be done alongside the top 10):
- Delete one-time scripts from tools/ (pr-body.txt, create-pr.md, etc.)
- Fix MCP config (remove Trello example or add real servers)
- Update @copilot capability profile in team.md
- Merge canvas-2d-optimization into web-game-engine skill

---

## Estimated Effort

| Priority | Items | Effort |
|----------|-------|--------|
| P0 (do now) | 7 items | ~2-3 hours (mostly deletions and rewrites) |
| P1 (this week) | 3 items | ~3-4 hours (archives, charter updates, webhook) |
| P2 (nice to have) | 5 items | ~8 hours (new skills, monitor build-out, podcaster eval) |

---

## Approval

Joaquín — please review and approve/modify. Upon approval, Solo will orchestrate execution:
1. Jango handles deletions (games/, tools/, workflows/)
2. Solo handles rewrites (team.md, routing.md, now.md, decisions archival)
3. Both run in parallel for maximum speed

**This ceremony output lives at:** `.squad/decisions/inbox/solo-studio-restructure-ceremony.md`

---

*Prepared by Solo (Lead / Chief Architect) — 2026-07-24*


---

## Decision: Game Pages Template and Blog Automation Skills

**Author:** Chewie  
**Date:** 2026-03-11T12:21Z  
**Status:** Approved  

### Summary

Two new skills created to standardize and automate web presence across game repositories:

1. **game-pages-template** — Reusable Astro Pages template for consistent showcase sites across all game repos
2. **blog-automation** — Auto-generated blog posts from ceremonies, milestones, and releases

### Rationale

Enables any new game repository to quickly set up branded Pages with proper styling and structure. Ensures the hub blog stays current with game progress through automated feed generation.

### Impact

- Standardized web presence across FFS Studio projects
- Reduced setup time for new games
- Hub blog automatically reflects game milestones and releases

---

## Decision: User Directive — Scroll Animations Standard

**Author:** Joaquín (via Copilot)  
**Date:** 2026-03-11T13:30Z  
**Status:** Active Directive  
**Type:** UX/Design Authority

### Directive

The fade-in scroll animations and hover glow effects from the Status page v2 must be applied to **ALL Pages** sites:
- FFS Hub
- ComeRosquillas
- Flora
- Future games

### Rationale

These animations are:
- **Aesthetic**: Visually polished and modern
- **Non-intrusive**: Don't distract from content
- **User-requested**: Joaquín directive

Establishes a consistent visual animation standard across the studio's entire web presence.

### Scope

Apply to all Astro-based Pages repositories. Consider this a platform standard, not project-specific.

### Implementation

Add scroll animations and hover effects to all .astro components across ComeRosquillas, Flora, and future Pages sites.

---

## Decision: ASCII-Safe schedule.json for PowerShell 5.1

**Date:** 2026-03-11  
**Owner:** Jango (Tool Engineer)  
**Issue:** #153  
**Status:** Implemented

### Problem

Windows PowerShell 5.1 reads .ps1 files using Windows-1252 encoding (no UTF-8 BOM). When ralph-watch.ps1 parses schedule.json, emoji UTF-8 bytes and em-dashes become garbled smart quotes, breaking JSON parsing.

### Solution

Replaced all non-ASCII characters in 	ools/scheduler/schedule.json:

| Character | Replacement | Occurrences |
|-----------|------------|-------------|
| 🎮 | [GAME] | Daily Playtest title |
| 📋 | [LOG] | Weekly Retro title |
| 🧹 | [MAINT] | Backlog Grooming title |
| 🌐 | [TEST] | Browser Compat Check title |
| — (em-dash U+2014) | -- (double hyphen) | All 4 titles |

### Outcome

✅ All emoji replaced with descriptive ASCII tags (brackets preserve readability)  
✅ All em-dashes converted to double hyphens  
✅ JSON validated with ConvertFrom-Json (PowerShell 5.1 compatible)  
✅ Scheduled tasks remain semantically correct for issue creation  

### Future Implications

- schedule.json is now 100% ASCII-safe for Windows PowerShell 5.1
- ralph-watch.ps1 can safely parse and execute scheduled tasks without encoding errors
- Any future JSON config files in tools/ should follow this ASCII-first convention per history.md guidelines


# Flora PR #20 Review — Build Failure + Integration Gaps

**Date:** 2026-03-11  
**Reviewer:** Ackbar (QA/Playtester)  
**PR:** jperezdelreal/flora#20 — "feat: hazard system with pests and weather events"  
**Issue:** #7 (Priority P0)  
**Review Link:** https://github.com/jperezdelreal/flora/pull/20#issuecomment-4041007260

---

## Summary

The hazard system **core logic is architecturally sound and well-balanced**, but the PR is **not shippable** due to:
1. TypeScript compilation errors (blocker)
2. Missing UI/input integration (can't be playtested)
3. Incomplete acceptance criteria from issue #7

**Verdict:** ⛔ **Changes Requested**

---

## Critical Issues

### 1. TypeScript Build Failure (BLOCKER)

**Severity:** 🛑 Critical  
**Impact:** PR cannot be merged — CI build fails

**Error:**
```
src/main.ts(22,42): error TS2345: Argument of type 'GardenScene' is not assignable to parameter of type 'Scene'.
  Types of property 'init' are incompatible.
    Type '(app: Application<Renderer>) => Promise<void>' is not assignable to type '(ctx: SceneContext) => Promise<void>'.
```

**Root cause:** Scene interface expects `SceneContext` parameter, but GardenScene provides `Application<Renderer>`. This is **NOT** in the hazard system code — appears to be a bad merge or pre-existing issue on the branch.

**Required fix:** Resolve Scene/GardenScene type mismatch before re-review.

---

### 2. Missing Acceptance Criteria

From issue #7, these are **not implemented**:

#### ❌ Pest UI marker on affected plant tile
- **Expected:** Visual indicator (sprite, icon, debug circle) appears on infested plant
- **Actual:** No rendering code in PR
- **Impact:** Can't playtest pest spawning or removal

#### ❌ Player click-to-remove pest action
- **Expected:** InputManager integration to detect click on pest tile → call `HazardSystem.removePest(pestId)`
- **Actual:** No input wiring in PR
- **Impact:** Core interaction mechanic is unimplemented

#### ❌ Drought visual warning (sky color shift, UI alert)
- **Expected:** Visual feedback when drought is active (sky tint, weather icon, notification)
- **Actual:** No rendering code in PR
- **Impact:** Player can't see drought state during gameplay

**Note:** The **system logic exists** (drought multiplier, day tracking, state management), but without UI/input, this is backend-only code.

---

### 3. Pest Spawning Flow Unclear

**Code:**
```typescript
private spawnPests(): void {
  // No implementation needed here - spawning happens externally
  // This is a hook for future plant-targeting logic
}
```

**Issues:**
- `spawnPests()` is called during day advancement but does nothing
- `trySpawnPestOnPlant(plant)` exists but has no external caller
- What happens if there are 0 plants in the garden on day 6-8?

**Required fix:** Either:
1. Implement `spawnPests()` to iterate over plants and call `trySpawnPestOnPlant()`
2. Document the expected external integration point (e.g., "PlantSystem must call `trySpawnPestOnPlant` for each eligible plant")

---

## What Works Well

### ✅ Type Safety
- Strong TypeScript types throughout (`PestConfig`, `DroughtConfig`, `HazardData`)
- Proper type guards: `isPest()`, `isDrought()`, `getPestData()`, `getDroughtData()`
- No `any` casts found

### ✅ Architecture
- Clean System/Entity pattern following existing conventions
- Proper state management with `PestState` enum
- Config-driven design with tunable parameters
- Hazards stored in Map (efficient lookup by ID)

### ✅ Game Balance
All numbers feel fair for an MVP:
- **Pest damage:** 12/day (tunable via config)
- **Resistance:** 30% chance at >70% health (prevents determinism, feels fair)
- **Drought multiplier:** 1.5× water needs (punishing but not brutal)
- **Drought duration:** 2-3 days (short enough to recover)
- **Spawn window:** Day 6-8 (gives player time to learn systems)

### ✅ Difficulty Scaling
Elegant 0→1 ramp across seasons:
- Pest spawn chance: 0.5× → 1.2× (easy to hard)
- Drought intensity: 1.0× → 1.3× (water needs)
- Max hazards: 1 → 3 (early to late game)

### ✅ "Never Instant-Fail" Design
- Pests deal damage over time (not instant death)
- Drought increases needs (not instant withering)
- Resistance mechanic gives healthy plants a chance
- Players always have counterplay options

---

## Required Fixes (Before Approval)

1. **Fix TypeScript Scene/GardenScene errors** (blocker)
2. **Add pest visual indicators** (sprites, markers, or debug circles)
3. **Wire InputManager for click-to-remove pests** (interaction mechanic)
4. **Add drought visual warning** (sky tint, weather icon, UI notification)
5. **Clarify/implement pest spawning flow** (link to PlantSystem or document external hook)

---

## Decision Points for Team

### Should hazard rendering live in HazardSystem or a separate Renderer?

**Current state:** HazardSystem has no rendering logic  
**Options:**
1. Add `render(app)` method to HazardSystem (like PlantSystem pattern)
2. Create separate HazardRenderer component
3. Let GardenScene handle hazard rendering directly

**Recommendation:** Follow existing PlantSystem pattern — add rendering to HazardSystem for consistency.

---

### Should pest spawning be automatic or manual?

**Current state:** `spawnPests()` is empty, `trySpawnPestOnPlant()` requires external caller  
**Options:**
1. **Automatic:** HazardSystem fetches plants from PlantSystem and spawns pests autonomously
2. **Manual:** Caller (GardenScene or PlantSystem) must invoke `trySpawnPestOnPlant()` for each plant

**Recommendation:** Automatic spawning keeps HazardSystem self-contained. Pass PlantSystem reference during init or `onDayAdvance()`.

---

## QA Learnings

### Key Pattern Identified
**"Architecturally sound ≠ shippable"**

A system can have:
- ✅ Clean architecture
- ✅ Strong types
- ✅ Good balance
- ✅ Solid logic

...but still be **un-shippable** if it can't be playtested. "Does it compile?" and "Can I interact with it in-game?" are equally critical gates.

### Acceptance Criteria Completeness
Issue #7 explicitly listed:
- Pest UI marker ❌
- Click-to-remove action ❌
- Drought visual warning ❌

These should've been implemented alongside the system logic, not deferred. A hazard system without visuals is like a car engine without a dashboard — technically functional but practically unusable.

---

## Re-Review Criteria

I'll approve once:
1. ✅ Build passes (TypeScript errors resolved)
2. ✅ Pests have visual indicators in-game
3. ✅ Player can click to remove pests
4. ✅ Drought shows visual warning
5. ✅ Pest spawning flow is clear/implemented

The **core hazard logic is excellent** — it just needs to be wired into the game. Once integrated, I expect this to be a strong foundation for future hazard types (heat waves, frost, locusts, etc.).

---

**Next Steps:**
- Assignee (Tarkin?) should address the 5 required fixes
- Re-request review from Ackbar when ready
- Consider splitting into two PRs if rendering/input work is substantial (backend logic + frontend integration)


### 2026-03-11T20:13Z: User directive — Repo creation tiers
**By:** Joaquin (Founder, via Copilot)
**What:** New repo creation is NOT always T0. Tiers depend on repo type:
- New GAME repo → T0 (founder only — changes studio direction)
- New TOOL/UTILITY repo (like squad-monitor) → T1 (Lead proposes, FFS Hub approves via PR)
- Fork or clone of existing tool → T2 (agent can do if issue justifies)
**Why:** Founder wants freedom for tool creation without bottlenecking on T0 approval. Tools are infrastructure, not strategic direction changes.


### 2026-03-11T20:30Z: Founder governance vision (comprehensive)
**By:** Joaquin (Founder, via Copilot)

**T0 (Founder only) -- MINIMAL, only paradigm-shifting decisions:**
- Deciding what NEW GAMES to build (Project = Game). This is the founder's only "capricho"
- Everything else should be automatic. T0 must NOT slow down the studio

**Moving FROM T0 to T1:**
- Adding/removing team members (agents) from roster -> T1 (not T0)

**Moving FROM T1 to T0:**
- Modifying studio principles (principles.md) -> T0 (these are foundational)

**T1 (FFS Hub = the Bible):**
- FFS Hub IS the brand, strategy, vision, everything
- Hub contains all that's needed for game repos to make good decisions autonomously
- Projects (games) are BORN from FFS but have their own "soul" -- artistic freedom within FFS values
- Tool repos that serve multiple repos should live at hub level or as separate repos (like squad-monitor)

**Ceremonies (MANDATORY):**
- At project START, MIDPOINT, and END
- Must include skills assessment and team member evaluation
- These inform decisions about team needs

**Project Autonomy:**
- Each project has TOTAL freedom to create its own tools, plugins, MCP connections
- If a tool has cross-repo application, escalate to FFS level:
  - Either inherit from hub
  - Or create a new tool repo (T1, not T0)

**Philosophy:**
- FFS must be 99% autonomous
- The founder decides WHAT games to make, not HOW
- The hub is the Bible -- everything downstream inherits and respects it
- Each game breathes FFS values but has creative freedom


### 2026-03-11T20:35: User directive
**By:** Joaquin (via Copilot)
**What:** Major refactors to `.squad/` directory structure remain at T0 (founder approval required). Rationale: foundational infrastructure, too risky for autonomous changes. Can be revisited if it causes bottlenecks.
**Why:** User request — captured for team memory

### 2026-03-11T20:35: User directive (governance tier refinements)
**By:** Joaquin (via Copilot)
**What:** Agent roster changes tiered by scope:
- Adding/removing agents in FFS Hub roster = T0 (founder approval)
- Adding/removing agents in game repo roster = T2 (project autonomy)
**Why:** User request — hub agents influence studio-wide decisions, game agents are project-scoped


### 2026-03-12T07-02-25Z: Founder directive — Governance tier restructuring
**By:** Joaquin (Founder, via Copilot)
**What:** 
1. T0 must be ULTRA minimal — ONLY: creating new game repos (founder's capricho) and modifying principles.md. Nothing else. T0 = only decisions that ABSOLUTELY change the paradigm of FFS.
2. T1: Founder does NOT want to approve anything at T1. T1 becomes Lead-authority (Solo decides alone). Hub roster changes, .squad/ refactors, and everything currently marked "Lead+Founder" becomes Lead-only.
3. Hub is the Bible — brand, strategy, vision, everything. Projects inherit but have artistic freedom.
4. Ceremonies mandatory at project start, midpoint, and end. Skills assessment and team evaluation at each.
5. Total project autonomy for tools, plugins, MCP connections. If cross-repo applicable, escalate to FFS level or create new repo.
6. FFS must be 99% autonomous. Founder decides WHAT games, not HOW.
**Why:** Founder vision — current governance has too many founder touchpoints, slowing studio autonomy. T0 was bloated with items that should be T1, and T1 required founder approval unnecessarily.


### 2026-03-12T07-16-15Z: Founder directive — .squad/ refactor tier split
**By:** Joaquin (Founder, via Copilot)
**What:** .squad/ refactors are NOT uniformly one tier. Split into:
- T1 (Lead authority): Content/organizational refactors — reorganizing analysis/, archiving logs, restructuring skills/ folders, consolidating duplicate casting files. These are housekeeping and Solo can handle them.
- T0 (Founder review): Structural/workflow refactors that could break the squad system — modifying routing.md tier definitions, refactoring config.json schema, changing the decisions inbox pipeline, renaming agents/ folder structure. These are "fox guarding the henhouse" scenarios.
**Why:** Founder agreed with Solo's risk analysis showing 3 of 8 example refactors are genuinely dangerous (routing, config, decisions pipeline). The rest are safe for Lead authority.


### 2026-03-12T07-27-32Z: Founder directive -- No agent-to-founder escalation at T1
**By:** Joaquin (Founder, via Copilot)
**What:** Remove the "any agent may appeal a T1 decision to the Founder" escalation path from governance. This undermines the Lead's authority at T1. The chain is: agents escalate to Solo (Lead), Solo is the ceiling for T1 decisions. Only Solo escalates to Founder, and only for T0 matters. No agent should be able to bypass the Lead.
**Why:** The whole point of T1 being Lead-only is that the Founder doesn't want to be involved. An appeal path to the Founder defeats that purpose and creates a shortcut around the Lead's authority.


# Decision: Daily Metrics Collector Script

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #164
**PR:** #168

## Decision

Created `tools/collect-daily-metrics.ps1` to collect daily studio productivity metrics across all 4 FFS repos. The script uses `gh` CLI exclusively for GitHub API calls and outputs structured JSON to `tools/metrics/YYYY-MM-DD.json`.

## Key Design Choices

1. **gh CLI over raw API** -- consistent with ralph-watch patterns, simpler auth
2. **Date search filters** -- uses `--search "created:DATE..DATE"` syntax for reliable date scoping
3. **JSONL log parsing** -- reads ralph-watch logs to extract round/duration/metrics data
4. **Parameterized** -- supports `-Date`, `-DryRun`, `-RepoNames`, `-Owner` for flexibility
5. **Day number from epoch** -- auto-calculates from 2026-03-11T16:31:48Z (same epoch as issue spec)
6. **ASCII-safe** -- no emojis or unicode, compatible with Windows PowerShell 5.1

## Open Questions

- Should this be integrated into ralph-watch as a post-round task, or run separately via scheduler?
- Should we add a rolling averages file (`tools/metrics/averages.json`) as mentioned in the issue?
- Should metrics JSON files be committed to the repo or gitignored?


# Decision: ralph-watch v3 Night/Day Mode Scheduling

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #167
**PR:** #169
**Status:** Pending Review

## Context

ralph-watch.ps1 ran a single copilot session per round at a fixed 15-minute interval regardless of time of day. Nights and weekends were wasted capacity; daytime sessions competed with the user's VS Code.

## Decision

Implement automatic night/day mode scheduling:

- **Night mode** (weeknights 21:00-07:00, weekends 24h): 2 parallel Start-Job copilot sessions, 5 issues/session, 2-minute intervals. Each session scoped to exactly 1 repo.
- **Day mode** (weekdays 07:00-21:00): 1 session, 3 issues/round, 10-minute intervals.
- **Auto-detect** via system clock (Get-Date). Manual override via -Mode param.

### Governance Filter
- T0: skip (founder approval required)
- T1: skip unless labeled "approved"
- T2/T3: auto-assign

### Scheduling Algorithm
1. Sort by priority label (P0 > P1 > P2 > P3)
2. Then by repo open issue count (busiest repo first)
3. Then game repos over hub (more user-facing work)

## Rationale

- Nights/weekends have no user competition -- maximize throughput
- 1 session per repo prevents cross-repo prompt confusion
- Governance filter prevents autonomous agents from touching high-stakes work
- Priority scheduling ensures critical issues get worked first

## Alternatives Considered

1. **Fixed schedule table** -- Rejected; clock-based auto-detection is simpler and self-maintaining
2. **Single session with larger issue count at night** -- Rejected; parallel sessions reduce round time by ~50%
3. **No governance filter** -- Rejected; T0/T1 issues need human judgment

## Consequences

- Night throughput roughly doubles (2 sessions vs 1)
- Day mode is gentler on system resources and git contention
- Mode transitions are logged, making it auditable
- Start-Job introduces PowerShell job cleanup complexity (mitigated with Wait/Remove patterns)


# Decision: Discord Webhook Notifications Architecture

**Date:** 2026-03-12  
**Author:** Jango (Tool Engineer)  
**Status:** Implemented  
**Related:** Issue #163, PR #171

## Context

The squad needed proactive notifications for critical events (CI failures, PR merges, priority issues, Ralph rounds) to keep Joaquin informed without requiring constant manual checking of GitHub.

## Decision

Implement Discord webhook notifications via GitHub Actions workflows with strict rate limiting and simple, spam-free design.

## Architecture

### Reusable Workflow Pattern
- **squad-notify-discord.yml** is the core reusable workflow
- All event-specific workflows call this with inputs (event_type, summary, link, color)
- Centralizes notification logic, rate limiting, and Discord API interaction

### Rate Limiting
- **Max 10 notifications per hour** (hard limit)
- Enforced at both workflow level and PowerShell script level
- Rate limit file tracks timestamps of last 20 notifications
- Silently skips notifications when limit exceeded (logs warning)

### Event Coverage
| Event | Trigger | Workflow |
|-------|---------|----------|
| CI Failure on main | workflow_run (completed + failure) | squad-notify-ci-failure.yml |
| PR Merged | pull_request (closed + merged) | squad-notify-pr-merged.yml |
| Priority Issue | issues (labeled + p0/critical) | squad-notify-priority-issue.yml |
| Ralph Round | schedule (*/30) + heartbeat check | squad-notify-ralph-heartbeat.yml |

### ASCII-Safe Design
- **No emojis** in PowerShell scripts (Windows compatibility)
- Text prefixes instead: `[FAIL]`, `[MERGE]`, `[ALERT]`, `[RALPH]`, `[INFO]`
- Discord embeds support emojis natively (if webhook sender adds them manually)

### Security
- Webhook URL stored in GitHub secret `DISCORD_WEBHOOK_URL`
- Never hardcoded or committed to repo
- PowerShell script reads from environment variable `$env:DISCORD_WEBHOOK_URL`

## Alternatives Considered

**1. Slack webhook** -- More complex setup, requires workspace admin approval  
**2. Email notifications** -- No immediate visibility, requires SMTP config  
**3. GitHub Discussions posts** -- Too noisy, not real-time  
**4. Teams webhook** -- Organizational restrictions, harder to test  

**Why Discord:** Free, simple webhook URL, no auth complexity, instant delivery, Joaquin already uses it.

## Implementation Details

### Heartbeat Round Detection
Ralph heartbeat workflow runs every 30 minutes but only notifies when round number increases:
- Reads `tools/.ralph-heartbeat.json` for current round
- Compares to `.github/.ralph-last-notified-round` (last notified round)
- Only sends notification if current > last
- Updates last notified round on successful send

### Color Codes (Decimal)
- Red (failures/alerts): `15158332`
- Green (success): `5763719`
- Blue (info): `3066993`
- Gray (neutral): `5814783`

### Rate Limit Cleanup
- Keeps last 20 timestamps in rate limit file
- Auto-cleans on every send (tail -n 20 pattern)
- Prevents file growth over time

## Trade-offs

**Pros:**
- Simple setup (one webhook URL, one secret)
- Instant notifications (Discord delivers in <1 second)
- Rate limiting prevents spam
- Reusable workflow reduces duplication
- PowerShell script allows ralph-watch integration

**Cons:**
- Requires Discord webhook URL (manual setup step)
- Rate limit may skip notifications during bursts (acceptable — prevents spam)
- Heartbeat checks every 30 min (not instant, but acceptable for background updates)

## Success Criteria

✅ Webhook endpoint configured (Discord webhook via secret)  
✅ Notification on: CI failure on main branch  
✅ Notification on: PR merged to main  
✅ Notification on: Issue labeled priority:p0 or priority:critical  
✅ Notification on: Ralph round completed (via heartbeat check)  
✅ Notifications include: event type, link, 1-line summary  
✅ Rate limiting: max 10 notifications per hour  
✅ GitHub Actions workflow integration  

## Lessons Learned

1. **Reusable workflows** simplify event-triggered notification patterns
2. **Rate limiting at the source** (before API call) is more reliable than relying on external limits
3. **ASCII-safe constraint** matters for PowerShell — emojis break on some Windows systems
4. **Heartbeat round tracking** prevents duplicate notifications on scheduled checks
5. **workflow_run event** is the cleanest way to catch all CI failures (wildcards work: workflows: ["*"])

## Related Decisions

- Ralph Watch v2 (#167) -- provides heartbeat file for round completion detection
- Daily Metrics Collector (#164) -- could extend to send daily summary notifications

## Tags

`infrastructure`, `notifications`, `discord`, `github-actions`, `webhooks`, `rate-limiting`


# Decision: autonomy-model.md Created as Reference Document

**Author:** Solo (Lead / Chief Architect)
**Date:** 2025-07-25
**Tier:** T1 (`.squad/` content refactor — Lead authority)
**Status:** Executed

## Decision

Created `.squad/identity/autonomy-model.md` to rescue operational content from governance v1 (Domains 2, 6, 7) that was intentionally cut from governance-v2.md for brevity.

## Rationale

Governance v2 reduced v1 from 1051 → 237 lines. The zone summary tables survived, but detailed rationale, configuration inheritance mechanics, hub/downstream responsibilities, and per-repo autonomy profiles were cut. These are needed by agents for day-to-day decisions about what they can and can't do locally.

## Scope

- **Reference doc only** — governance.md remains the authority on tiers and zones.
- **147 lines, tables over prose** — no philosophy paragraphs.
- **No duplication** — doesn't repeat what v2 already says well; adds the WHY and HOW.

## Content

Zone A/B/C rationale tables, Zone B extension example, Configuration Inheritance (cascades + local), Inheritance Conflict Resolution (4 rules), Hub Responsibilities (5), Downstream Responsibilities (6), Conflict Resolution (4 rules), Autonomy by Repository (4 repos).


# Decision: SceneContext Pattern Enforcement in Flora

**Date:** 2025-01-XX  
**Author:** Solo (Lead Architect)  
**Context:** flora repository (jperezdelreal/flora) Issue #23  
**Status:** Implemented  

## Decision

Enforced the SceneContext architectural pattern across all Scene implementations in the Flora project. All Scene.init() and Scene.update() methods must accept SceneContext instead of direct Application references.

## Rationale

**Problem:**  
GardenScene was implementing Scene interface incorrectly by accepting `Application` directly in init() instead of the SceneContext wrapper. This caused TypeScript build failures and deploy workflow blockage.

**Solution:**  
Updated GardenScene to conform to the SceneContext pattern:
- `init(app: Application)` → `init(ctx: SceneContext)`
- `update(delta: number)` → `update(delta: number, ctx: SceneContext)`
- All Application references changed to `ctx.app`
- Scene stage access changed to `ctx.sceneManager.stage`

## Benefits

1. **Consistent Architecture:** All scenes access shared resources through SceneContext
2. **Better Testability:** SceneContext can be mocked more easily than Application
3. **Dependency Injection:** Scenes receive input, assets, and sceneManager without tight coupling
4. **Type Safety:** TypeScript enforces the pattern at compile time

## Implementation Details

**Files Modified:**
- `src/scenes/GardenScene.ts`

**Changes:**
- Import SceneContext type
- Updated init() signature to accept SceneContext
- Updated update() signature to accept SceneContext
- Changed all `app.*` references to `ctx.app.*`
- Changed scene stage access to use `ctx.sceneManager.stage`

## Verification

- ✅ TypeScript compilation passes (`npx tsc --noEmit`)
- ✅ Production build succeeds (`npm run build`)
- ✅ Deploy workflow unblocked

## Future Considerations

When implementing new Scenes in Flora:
1. Always implement Scene interface with correct signatures
2. Use SceneContext for all shared resource access
3. Run TypeScript type check early in development to catch signature mismatches
4. Reference BootScene.ts or GardenScene.ts as pattern examples

## Related

- Issue: jperezdelreal/flora#23
- PR: jperezdelreal/flora#24
- Pattern defined in: src/core/SceneManager.ts


# Decision: Governance T0/T1 Restructure — Founder Directives Applied

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-25  
**Status:** Implemented  
**Tier:** T0 (modifies T0 scope)  
**Scope:** Studio-wide — affects all repos, all agents, all approval flows

## What Was Decided

Per explicit Founder directives from Joaquín:

### 1. T0 Ultra-Minimized
T0 now contains **only two items**:
- Creating a new game repository (the founder's "capricho")
- Modifying studio principles (`principles.md`)

**Removed from T0:**
- Hub roster changes → moved to T1
- `.squad/` directory refactors → moved to T1
- Technology pivots → moved to T1
- Governance changes (unless modifying T0 scope) → moved to T1

### 2. T1 = Lead Authority Only
T1 no longer requires Founder approval. Solo (Lead) has full, permanent authority over all T1 decisions. The Founder does not participate in routine T1 approvals.

**What this means:**
- Solo can create tool repos, change quality gates, add/remove hub agents, refactor `.squad/`, update ceremonies, modify governance, and make all cross-repo architectural decisions without waiting for Founder sign-off.
- Agents may appeal T1 decisions to the Founder, but this is an exception path, not the default.

### 3. Delegation Rules Updated
New permanent rule: "T1 is fully delegated to Lead — no founder approval required for any T1 decision."

### 4. Governance Self-Governance Updated
- Changes to governance that don't modify T0 scope: T1 (Lead authority)
- Changes to governance that modify T0 scope: T0 (Founder only)

## Why

Joaquín's directive: **"FFS must be 99% autonomous. The founder decides WHAT games to make, not HOW."**

The previous governance had the Founder as a bottleneck on every T1 decision — tool repos, quality gates, skills, ceremonies, sprint scope, roster changes. This created an approval funnel through a single human for decisions that are reversible and within the Lead's domain expertise.

The hub is the Bible. Solo is its steward. The Founder's role is strategic direction (new games, principles), not operational governance.

## Impact

| Who | What Changes |
|-----|-------------|
| **Solo (Lead)** | Full T1 authority — no more "propose and wait for Founder" |
| **All agents** | T1 proposals go to Solo only. Faster turnaround on cross-repo decisions |
| **Joaquín (Founder)** | Only involved in T0 (new games, principles, archival, T0 scope changes) |
| **Mace (Producer)** | Sprint scope changes need Solo alignment, not Solo + Joaquín |
| **Jango (Tool Engineer)** | Tool repo creation approved by Solo only |

## Files Modified

- `.squad/identity/governance.md` — 20+ edits across all 9 domains + appendices
- `.squad/agents/solo/history.md` — learning entry added


# Decision: Governance v2.0 Draft — Full Rewrite for Founder Review

**Author:** Solo (Lead / Chief Architect)
**Date:** 2026-07-25
**Status:** Proposed — awaiting Founder comparison with v1
**Tier:** T0 (structural changes to governance tiers and T0 scope definition)
**Scope:** Studio-wide governance

## What Is Being Proposed

A complete rewrite of `.squad/identity/governance.md` (1051 lines, 9 domains, ~55KB) into `.squad/identity/governance-v2.md` (237 lines, 6 sections, ~14KB).

Written as a **separate file** so the Founder can compare both versions side-by-side before deciding.

## What Changed

### Structural
- **9 domains → 6 focused sections** plus Quick Reference and Appendix
- **1051 → 237 lines** (77% reduction)
- Quick Reference tables placed FIRST for immediate agent use
- Tables over prose throughout — killed philosophy paragraphs

### Redundancy Eliminated
- Domains 2 (Autonomy), 6 (Hub-Downstream), 7 (Config Inheritance) explained the same hub-vs-downstream model three times → consolidated into one **Autonomy Zones** section
- Domains 3 (Skills), 4 (Ceremonies), 5 (Lifecycle), 8 (Routing) duplicated content from `ceremonies.md`, `routing.md`, `new-project-playbook.md` → replaced with **cross-references**

### Contradictions Resolved
- Old Domain 1 (Tiers) and Domain 9 (Decision Authority) had conflicting T0 scope → **Decision Authority Matrix now matches Tier definitions exactly**

### T0 Refined Per Latest Founder Directives
T0 is exhaustively defined as:
1. New game repos
2. `principles.md` changes
3. `routing.md` tier definitions changes
4. `config.json` schema changes
5. Decisions pipeline structure changes
6. Agent folder naming convention changes
7. T0 scope changes

### T1 Confirmed Lead-Only
Every T1 entry says "Solo (Lead)" — never "Lead + Founder." Hub roster changes, content-level `.squad/` refactors, tool repos, governance changes (not T0 scope) — all Lead authority.

## Why

The Founder couldn't finish reading v1 (55KB). The audit found only ~150 lines of actionable content buried in philosophy paragraphs. A constitution should be readable in 5 minutes and unambiguous. v2 achieves this.

## Action Required

**Founder:** Compare `governance.md` (v1) with `governance-v2.md` (v2). If approved, v2 replaces v1. If changes needed, provide feedback for revision.

## Files

- **Created:** `.squad/identity/governance-v2.md` (237 lines)
- **NOT modified:** `.squad/identity/governance.md` (v1 untouched)


# Cutscene System Architecture for ComeRosquillas

**Date:** 2025-01-XX  
**Agent:** Wedge (UI/UX Developer)  
**Project:** ComeRosquillas  
**Issue:** #5 - Simpsons-themed intermission cutscenes

## Decision

Implemented a timeline-based cutscene system using a dedicated game state (ST_CUTSCENE) with declarative actor spawning and simple action processing.

## Context

ComeRosquillas needed Pac-Man-style intermission cutscenes between levels to add personality and humor. The game already had a state machine and rich sprite rendering methods for characters.

## Design Choices

### Timeline-Based Architecture
- Cutscenes defined as `{duration, timeline: [{frame, action, params}]}` objects
- Events trigger at specific frames (e.g., frame 0, 30, 60)
- Actors stored in array with position, velocity, and type
- Update loop advances frame counter and spawns/updates actors

**Why:** Declarative timelines are easier to author and modify than imperative animation code. Non-programmers can add cutscenes by editing data.

### Reuse Existing Sprite Methods
- Called Sprites.drawHomer(), _drawBurns(), _drawNelson(), drawDonut(), drawDuff()
- No new rendering code needed
- Actors positioned in screen space, not grid space

**Why:** DRY principle — sprites already looked good, no need to redraw. Maintains visual consistency with gameplay.

### Skip on Any Key
- Any keypress during ST_CUTSCENE calls skipCutscene()
- Immediately transitions to next level via endCutscene()

**Why:** Player agency — some players want to skip, others want to watch. Match arcade conventions.

### Black Background
- Full black canvas instead of game maze
- Focuses attention on animated sprites

**Why:** Simplicity and performance. No need to render maze during cutscenes. Classic arcade aesthetic.

## Trade-offs

- **Pro:** Easy to add new cutscenes without touching logic code
- **Pro:** Minimal performance impact (just sprite drawing)
- **Pro:** Consistent with existing codebase patterns (state machine)
- **Con:** Timeline format is rigid — complex branching/looping would require new actions
- **Con:** No audio/dialogue system yet (could extend action types)

## Alternatives Considered

1. **Sprite sheets + frame-by-frame animation** — Too heavyweight for a Pac-Man clone
2. **Video files** — Would break "no external assets" constraint
3. **CSS animations** — Mixing canvas and DOM would complicate rendering

## Future Extensions

- Add 'sound' action type to trigger SFX at specific frames
- Add 'camera' action for pan/zoom effects
- Support looping cutscenes (e.g., attract mode)
- Add cutscene editor UI (stretch goal)

## Files Modified

- `js/config.js` — Added ST_CUTSCENE, CUTSCENE_LEVELS, CUTSCENES data
- `js/game-logic.js` — Added cutscene methods, state handling, skip logic



---

## Archived: decisions/archive/2026-03-07 snapshot


# Team Decisions

## Decision: Game Vision & Design Document

**Author:** Yoda (Game Designer)  
**Date:** 2025  
**Type:** Design Authority  
**Status:** Proposed  
**Artifact:** `.squad/analysis/game-design-document.md`

---

### Summary

Created the comprehensive Game Design Document (GDD) for firstPunch — the team's north star for all design and implementation decisions.

### Key Decisions

#### Vision
firstPunch is a browser-based game beat 'em up where comedy IS the combat. Players should laugh, feel powerful, and immediately want to try the next character. Instant-play browser design means zero friction, 5-7 minute levels, and session-friendly pacing.

#### Four Design Pillars
1. **Comedy as a Core Mechanic** — Humor is in the gameplay systems (taunts, Ugh! moments, game-rated combo meter), not just cosmetic.
2. **Accessible Depth** — Button-mashers have fun; combo masters have a different kind of fun. Streets of Rage 4 principle.
3. **Team Synergy** — Co-op mechanics reward playing as the team together (team attacks, proximity buffs, team super).
4. **Downtown Is a Character** — Environments are interactive playgrounds with landmark gags, destructibles, and hazards.

#### Core Combat
- **PPK combo** as the bread-and-butter (42 damage/1.1s)
- **Health-cost specials** with recovery-by-attacking (SoR2/SoR4 model)
- **Grab/throw system** (Turtles in Time influence)
- **Dodge roll with i-frames** (modern standard)
- **Super meter** filled by damage and taunts
- **Jump attacks rebalanced** with landing lag to prevent air-spam dominance (balance analysis finding)

#### Characters (4 planned, Brawler first)
- Brawler: Power/All-Rounder, Rage Mode, Belly Bounce
- Kid: Speed, Skateboard Dash, Slingshot ranged, alter-ego super
- Defender: Range, Purse Swing, Hair Whip, Maternal Instinct passive
- Prodigy: Technical/CC, Saxophone Blast, Intellect Advantage dodge, Activist Rally super

#### game-Specific Mechanics
- **Rage Mode** (eat 3 donuts → Brawler power-up, creates heal vs. rage dilemma)
- **Ugh! Moments** (funny failure states at every level)
- **Couch Gag loading screens** (randomized, collectible transitions)
- **Downtown landmarks** as interactive combat elements
- **game food** as themed health pickups (Pink Donut, Burger Joint, Fire Cocktail)
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

**Character Art (5 items):** P2-4 Brawler redesign, P1-9 Brawler walk cycle (art side), P1-10 Brawler attack animations (art side), P1-11 Enemy death animation, EX-B7 Consistent entity rendering style.

**Environment Art (3 items):** P2-5 Background overhaul, EX-B6 Foreground parallax layer, EX-B8 Environmental background animations.

**VFX (5 items):** P1-2 Hit impact VFX, EX-B3 Enemy attack telegraph VFX, EX-B4 Attack motion trails, EX-B5 Enemy spawn-in effects, P2-9 KO text effects.

**Art Direction (2 items):** EX-B1 Art direction & color palette, EX-B2 Character ground shadows.

**Plus shared items:** P2-10 Animated title screen (with Wedge), P2-13 Score pop-ups.

#### Analysis

The visual modernization plan alone is **62KB** — a massive document covering Brawler's stubble rendering, enemy proportions, background parallax layers, particle effects, and more. This is not a part-time gig. Each of the 4 proposed sub-roles maps cleanly to a real workload cluster:

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
5. **Boba's charter update:** Change from "VFX/Art Specialist" to "Art Director." Responsibilities shift from production to direction + review + style enforcement + selective production on high-complexity items (e.g., Brawler's final design is too important to delegate to a new hire).

#### Risk: Boba Becomes a Bottleneck

If every visual change needs Art Director review, Boba becomes a chokepoint. Mitigation: Boba reviews the first 2-3 items from each new artist, then shifts to spot-check reviews. Trust builds. The art direction document serves as the "always-available reviewer" — if the work follows the guide, it's probably fine.

### 3. Game Designer Role

#### Is It Genuinely Needed?

**Yes, and the need is already visible.** Here's what's currently happening without a Game Designer:

- **Solo (Lead) is implicitly doing game design.** The gap analysis, the 52-item backlog, the phased execution plan, the priority rankings — these are all game design decisions made by a project lead. This works at small scale but doesn't scale.
- **Tarkin (Enemy/Content Dev) is doing content design.** Wave composition rules (EX-T2), encounter pacing curves (EX-T3), boss phase frameworks (EX-T5) — these are game design decisions embedded in a content dev role.
- **Ackbar (QA) is doing balance design.** DPS analysis (EX-A5), frame data documentation (EX-A2) — balance tuning IS game design.
- **Nobody owns the coherent vision.** Is firstPunch a casual brawler or a technical fighter? How hard should it be? What's the target session length? What emotions should each wave evoke? These questions have no designated owner.

#### What a Game Designer Does Day-to-Day

| Activity | Frequency | Example |
|----------|-----------|---------|
| Maintain GDD | Ongoing | "Brawler's punch should feel heavy — 4 frame startup, 8 active, 12 recovery. Compare to enemy punch: 6/6/8." |
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
Boba: [art direction] → [Brawler redesign] → [backgrounds] → [VFX] → [enemies]
                       (all sequential — one person)
```

**After (3 parallel art pipelines + oversight):**
```
Boba (Art Dir):   [style guide] → [review] → [review] → [review] → ...
Env Artist:       [backgrounds] → [parallax] → [props] → [level 2 bg] → ...
VFX Artist:       [hit VFX] → [telegraphs] → [trails] → [spawn FX] → ...
Char Artist:      [Brawler redesign] → [walk cycle] → [enemy art] → [boss] → ...
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

1. **Phase A — Game Designer (Yoda):** Onboard first. Before adding 3 artists, we need the GDD and design specs they'll work from. Yoda writes the GDD, defines Brawler's target feel, specifies enemy personality profiles, and sets the difficulty curve. ~1 session to establish.

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

Comprehensive AAA gap analysis comparing firstPunch's current state against "award-winning browser beat 'em up" standard. Produced a 101-item prioritized backlog (56 new + 45 carried from existing 85) organized into 5 execution phases, plus 8 future/migration items.

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
- **Character Roster (5):** Character select, Kid/Defender/Prodigy playable, unlock system
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
2. **4 playable characters.** Brawler + Kid + Defender + Prodigy. Each follows the speed/power/range archetype triangle from research.
3. **3 levels minimum.** Downtown Streets → City School → Factory. Each with unique boss and environment.
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

- localStorage key is `firstPunch_highScore` — namespaced to avoid collisions if other games share the domain.
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
- firstPunch engine code (1,931 LOC) doesn't transfer — but all architectural knowledge does

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

**The lesson from firstPunch proves this:** The #1 technical debt finding (Session 8) was "214 LOC of unused infrastructure — working systems that aren't wired into anything." The multi-agent-coordination skill (Session 10) identified the core pattern: "agents build infrastructure but don't wire it." A Tool Engineer's explicit job would be closing this gap — building the scaffolding, templates, and automation that ensure new code arrives pre-wired.

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

**Conservative estimate:** 15-25 tooling items in the first Godot project, ongoing maintenance as game scope grows. That's a full role's worth of work, comparable to Tarkin's content workload (18 items in firstPunch).

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

**Distribute across all agents?** No. This is exactly the pattern that produced 214 LOC of unused infrastructure in firstPunch. When everyone is responsible for tooling, nobody is responsible for tooling. The multi-agent-coordination skill explicitly warns against this.

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



---

## Archived: yoda-growth-framework decision


# Decision: Studio Growth Framework Created

**Date:** 2025  
**Author:** Yoda (Game Designer)  
**Status:** Complete  
**Scope:** Studio meta-architecture and scaling strategy  

---

## The Decision

First Frame Studios has created a comprehensive **Growth Framework** (`.squad/identity/growth-framework.md`) that documents how the studio will evolve from a single-game team to a multi-game, multi-genre studio without breaking under its own weight.

---

## Why Now?

The founder's directive: **"amplitud de miras"** (breadth of vision). firstPunch proved we can ship one game. But the studio must be built to absorb new genres, new platforms, new team members, and new challenges without fundamental restructuring.

At growth inflection points, studios either:
1. **Scale vertically** — Add more layers of management, more process overhead, more bureaucracy. This works at massive scale but kills small teams.
2. **Scale horizontally** — Add more teams, same structure, shared knowledge base. This requires documenting everything so knowledge compounds.

First Frame Studios chooses **horizontal scaling** with a documented foundation.

---

## Core Insight: The 70/30 Rule

**70% of what makes First Frame Studios effective is PERMANENT and tech/genre agnostic:**
- Leadership principles (decision-making algorithms)
- Quality gates and definition of done (outcome-based standards)
- Team structure and domain ownership model
- Design methodology (research → GDD → backlog → build → retrospective → skills)
- Company identity and values

**30% is ADAPTIVE and changes per project:**
- Engine-specific skills (Canvas 2D vs. Godot 4 vs. Unreal)
- Genre-specific skills (beat 'em up combat vs. platformer physics vs. fighting game netcode)
- Code patterns and architecture (specific to tech stack)
- Art pipelines (sprites vs. models vs. vector)

This ratio means: **New genres, new platforms, and new teams don't break us. They're absorbed by the permanent 70%.**

---

## What the Framework Delivers

1. **Skill Architecture** — How knowledge compounds across projects: universal skills (state machines, game feel), genre verticals (beat 'em up, future platformer/fighting), tech stack skills, and maturity levels.

2. **Team Elasticity** — Core roles (Game Designer, Lead, Engine, Gameplay, QA) are permanent. New roles emerge per project scope. New genres may require new specialist roles (e.g., Level Designer for platformer, Netcode Engineer for fighting game).

3. **Genre Onboarding Protocol** — Two playbooks:
   - **First genre:** 8 weeks (research → GDD template → minimum playable → skill creation → team assessment → architecture spike)
   - **Returning to genre:** 4 weeks (read existing skills, check for updates, start with institutional advantage)

4. **Technology Independence** — GDD, principles, quality gates, and team charters are engine-agnostic. Only engine-specific skills, build pipelines, and architecture docs are locked to a platform. If Canvas 2D becomes obsolete, we port to Godot 4. The 70% carries forward unchanged.

5. **Risk Mitigation** — Six risks that force restructuring if ignored (knowledge-in-head, engine lock-in, single-genre limit, process scalability, key person dependency, platform obsolescence). For each, the documented prevention.

6. **Growth Milestones** — Five stages: Single Genre → Second Genre → Multi-Genre → Multi-Platform → Studio Scale. The framework explains what each stage proves and what risks it mitigates.

---

## Trade-Offs and Alternatives

### Alternative 1: "Don't document. Trust people and relationships."
- **Pro:** Faster in the short term. Less "bureaucracy."
- **Con:** Catastrophic when people leave. Knowledge dies. Studio must rehire and retrain. At Stage 2 or 3, this breaks the studio.
- **Why we didn't choose this:** firstPunch already taught us that institutional memory (decisions.md, skills, history.md) is what compounds. We can't rely on people staying; we have to rely on documented patterns.

### Alternative 2: "Create new structure for each new genre."
- **Pro:** Each genre gets optimized structure.
- **Con:** Restructuring overhead kills momentum. Team churn. Principles become inconsistent. By Stage 3 (multi-genre), the studio becomes a chaos of different cultures.
- **Why we didn't choose this:** The framework proves that one squad structure can absorb any genre. Efficiency comes from consistent structure, not specialized structure.

### Alternative 3: "Write the framework after the second game ships."
- **Pro:** We'll have more data.
- **Con:** The second game will be chaotic and slow because the team won't have a shared mental model of how to scale. Decision-making will be ad-hoc. We'll make preventable mistakes.
- **Why we didn't choose this:** Writing the framework *now*, from firstPunch's lessons, gives us a hypothesis to test with the second game. If the hypothesis holds, the second game will be faster. If it breaks, we'll learn why and update the framework.

---

## Implementation

The Growth Framework is **not** a change to current operations. It is a **description of how we already work** (from firstPunch) plus a **set of protocols for what comes next**.

**Immediate actions:**
1. ✅ Growth Framework created and archived at `.squad/identity/growth-framework.md`
2. ✅ Learnings appended to `.squad/agents/yoda/history.md`
3. 🔲 Distributed to team and discussed in next studio meeting
4. 🔲 Used as the foundation for the next project's onboarding

**When the second project starts:**
1. Team reads the relevant sections (Sections 2–4: Skill Architecture, Team Elasticity, Genre Onboarding Protocol)
2. Follow the Genre Onboarding Protocol (8 weeks of research/planning before Sprint 0)
3. Document findings in the retrospective and update the framework with what we learned

---

## Reversibility

**This is highly reversible.** The Growth Framework is a description of intent, not a constraint. If the team discovers that the framework is wrong, we update it. If the 70/30 ratio doesn't hold, we change the ratio. If the genre onboarding protocol doesn't work, we redesign it.

The only part that's non-reversible is: **Committing to documentation as the source of truth.** Once we've organized institutional knowledge around written skills and decision logs, we can't go back to "knowledge in people's heads" without losing everything. But that's the direction we've already chosen (with firstPunch's GDD, skills, and decisions.md), so this isn't a new commitment.

---

## Success Criteria

The Growth Framework succeeds if:

1. **Second game launches faster than first** — Research, planning, and architecture spikes take 4 weeks instead of 8 (because we have existing knowledge).
2. **No reshuffling of team structure** — We don't need to reorganize roles or create new departments to ship the second game.
3. **Skills compound** — We can point to at least two transferable patterns from beat 'em up that accelerated the second game's development.
4. **New genres don't break quality** — The second game ships at the same quality bar as firstPunch without working weekends or hiring crisis staff.
5. **Framework survives contact with reality** — We update the framework based on what we learned. Some claims will be wrong; that's OK.

---

## Related Decisions

- [Yoda — Game Vision](../yoda-game-vision.md) — The GDD and design principles that shape all games
- [Solo — Team Expansion](../solo-team-expansion.md) — The squad structure that this framework describes
- [Company Identity](../identity/company.md) — Section 7 (Genre Strategy — Vertical Growth) is the narrative version of this framework

---

## Notes for Future Readers

If you're reading this in Year 2 or beyond:

1. **Check if the 70/30 rule held.** Did 70% of the studio's effectiveness remain constant across genres? Or did the split change? Document your findings.
2. **Check if the genre onboarding protocol worked.** Did the second genre take 8 weeks (first time) or 4 weeks (returning)? What was faster? What was slower?
3. **Check if team elasticity proved correct.** Did new roles emerge as predicted? Did the core structure absorb them, or did the team need to restructure?
4. **Update the framework with what you learned.** Stamp the date and note what changed.

This framework is a hypothesis. Your job is to test it, refine it, and make it true.

---

**Co-authored-by:** Copilot <223556219+Copilot@users.noreply.github.com>


---

## Archived: Root decisions.md pre-v2 cleanup (2026-03-12)


# Squad Decisions

## Active Decisions

### 2026-03-11: ComeRosquillas Modularization Architecture (Chewie)
**Date:** 2026-03-11  
**Author:** Chewie (Engine Developer)  
**Issue:** #1 — Modularize game.js monolith  
**Status:** ✅ Implemented (PR #10)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas shipped with a 1789-line game.js monolith containing all code: constants, audio, rendering, game logic, and initialization. This blocked parallel development and made code navigation difficult.

**Decision:**
Split game.js into 5 focused modules organized by responsibility with clean dependency flow.

**Module Structure:**
- **config.js** (114 lines): Constants, maze data (31×28), ghost configs, Simpsons colors, game states, direction vectors
- **engine/audio.js** (166 lines): SoundManager class — Simpsons theme, D'oh sound, Duff jingle, background music
- **engine/renderer.js** (720 lines): Sprites static class — Homer rendering, 4 ghost characters (Burns, Bob, Nelson, Snake), donut/Duff, maze
- **game-logic.js** (791 lines): Game class — game loop, state machine (7 states), player movement, ghost AI (scatter/chase/frightened), scoring, level progression
- **main.js** (13 lines): Entry point — thin instantiation of Game

**Load Order (Dependency DAG):**
```
config.js (no deps)
  ↓
audio.js (uses config)
  ↓
renderer.js (uses config)
  ↓
game-logic.js (uses all)
  ↓
main.js (instantiates Game)
```

**Rationale:**
1. **Config as Foundation** — Pure data, zero dependencies enables safe parallel work on rendering and game logic
2. **Engine Separation** — Audio and renderer are orthogonal concerns, separate files enable parallel development
3. **Static Renderer** — Sprites class uses static methods (no instance state), simplifies testing, eliminates object allocation
4. **No Bundler** — Vanilla JS project with simple DAG, `<script>` tags provide explicit load order, low development friction

**Alternatives Rejected:**
1. **ES Modules** — Would require export/import syntax changes. Global namespace approach simpler for vanilla JS.
2. **Split Renderer by Entity** (player.js, ghosts.js, maze.js) — Drawing code tightly coupled to config constants. 720-line cohesion preferable to fragmentation.
3. **Webpack/Vite Bundle** — Adds build step complexity. Browser handles 5 files efficiently.

**Consequences:**
- ✅ Clear module responsibilities, parallel development enabled, static methods easily testable
- ✅ Maintainability improved: code navigation easier, onboarding clearer
- ❌ Global namespace risk if naming conflicts arise (mitigated by discipline)
- ❌ Load order dependency — index.html must maintain correct script order (easy to break)

**Testing:**
- ✅ Game loads and plays after modularization
- ✅ All sounds, rendering, gameplay, scoring, level progression work identically
- ✅ Zero breaking changes

**Future Work:**
- Consider ES modules when browser support matures
- Extract maze data to JSON if editing becomes frequent
- Add JSDoc for IDE autocomplete
- Split game-logic.js if it grows beyond 1000 lines

---

### 2026-03-11: ComeRosquillas CI Pipeline Strategy (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Issue:** #6 — Add CI pipeline with validation and deploy checks  
**Status:** ✅ Implemented (PR #9)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas is a vanilla HTML/JS/Canvas game (no build step). Need lightweight CI that validates code quality and enables live PR preview without adding bundler complexity.

**Decision:**
Implemented GitHub Actions workflow (`ci.yml`) with JavaScript syntax validation, HTML structure checks, and automated PR preview comments.

**Workflow Details:**
- **Triggers:** All PRs and main pushes
- **Execution Time:** ~30 seconds
- **Validations:**
  - HTML structure (canvas element, script references)
  - JavaScript syntax (`node --check` on all .js files)
  - Game assets structure
  - Code quality (no debugger statements, TODO awareness)
- **Output:** Automated PR comment with validation results and deployment URLs

**Rationale:**
1. **Keep It Simple** — No build step for vanilla game. Bundlers (webpack, parcel) would slow development.
2. **Fast Feedback** — 30-second runs provide immediate validation on every commit.
3. **PR Experience** — Comments with validation + deploy links in one place improve developer workflow.
4. **Separation of Concerns** — CI validation (this) ≠ Deployment (existing deploy-pages.yml) ≠ Squad framework (squad-ci.yml)
5. **Node.js Native** — `node --check` for JS validation. Can extend with ESLint/Prettier later if needed.

**Alternatives Rejected:**
1. **Add ESLint/Prettier** — Too much config overhead for v1.0. Can add later if style becomes an issue.
2. **HTML Validator Service** — External dependency + network calls. Simple grep sufficient for now.
3. **Playwright/Puppeteer E2E Tests** — No test files exist yet. CI focuses on syntax first. E2E can be added in future sprints.
4. **Combine with squad-ci.yml** — Squad-ci.yml is squad-framework specific. Kept separate for clarity.

**Consequences:**
- ✅ Fast CI runs, zero dependencies beyond Node.js, clear validation messages, improves developer experience
- ✅ Does not interfere with existing Astro docs deployment
- ❌ No code style enforcement yet (no linter), no E2E tests, manual grep checks
- ✓ Can extend with ESLint, Prettier, Playwright later without major rearchitecture

**Follow-up:**
- Add ESLint + Prettier if code style issues arise
- Add Playwright E2E tests when game stabilizes
- Add Lighthouse CI for performance checks
- Monitor CI run times — optimize if they exceed 2 minutes

---

### 2026-03-11: ComeRosquillas Issue Triage & Squad Routing (Solo)
**Date:** 2026-03-11  
**Author:** Solo (Lead/Architect)  
**Scope:** Assign squad routing labels to all 8 open issues  
**Status:** ✅ Complete  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
ComeRosquillas shipped with 8 open GitHub issues. None had squad routing labels, blocking Ralph's auto-assignment workflow.

**Decision:**
Triaged all 8 issues with squad routing + priority labels, creating 14 labels in repo and applying them to each issue with rationale comments.

**Triage Results:**

| Issue | Title | Assigned To | Priority | Rationale |
|---|---|---|---|---|
| #1 | Modularize game.js | solo + chewie | P0 | Blocks everything downstream (cascades to #3, #4, #5, #7, #8) |
| #2 | Mobile/touch controls | wedge | P2 | Platform expansion, non-blocking for v1.0, post-launch polish |
| #3 | High score persistence | wedge + lando | P2 | Engagement feature, not critical for core loop, post-launch |
| #4 | Multiple maze layouts | tarkin + lando | P1 | Critical for replayability, v1.0 essential, start after #1 |
| #5 | Simpsons intermission cutscenes | wedge | P3 | Pure charm/narrative, deferred until core stable |
| #6 | CI pipeline | jango | P1 | Unblocks velocity, tooling investment, parallel stream |
| #7 | Ghost AI improvement | tarkin | P1 | Gameplay core (difficulty + personality), v1.0 essential |
| #8 | Sound effects variety | greedo | P1 | Sound IS gameplay feel, v1.0 essential |

**Routing Philosophy:**
- **P0 (Critical):** Unblocks everything downstream (only #1)
- **P1 (Ship-Blocking):** Must complete before v1.0 release (#4, #6, #7, #8). Can run in parallel.
- **P2 (Medium):** Valuable engagement features, ship after v1.0 stable (#2, #3)
- **P3 (Polish):** Pure charm/narrative, deferred (#5)

**Key Insight — Monolithic Anti-Pattern Repeats:**
- firstPunch: gameplay.js = 695 LOC → architecture refactor was P0
- ComeRosquillas: game.js = 1636 LOC → architecture refactor is P0

**Implication:** Studio should establish **architectural debt prevention pattern**:
- Max 300-400 LOC per module before auto-triggering refactor review
- Modular architecture designed upfront, not retrofitted
- Code organization as critical as feature completion

---

### 2026-03-11: Create ffs-squad-monitor Repository (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Requested by:** Joaquín  
**Status:** ✅ Implemented

**Context:**
Joaquín wants a real-time monitoring dashboard for the FFS squad, inspired by [Tamir Dresher's squad-monitor](https://github.com/tamirdresher/squad-monitor). We already have `ralph-watch.ps1` writing heartbeat data and structured logs — we need a visual frontend.

**Decision:**
Created a new public repo `jperezdelreal/ffs-squad-monitor` with:
- Vite + vanilla JS stack (lightweight, learning-friendly)
- Sprint 0 scaffolding: dashboard HTML, heartbeat polling script, mock data
- 5 roadmap issues covering heartbeat reader, log viewer, timeline, UI, and Actions integration
- Squad initialized with upstream link to FirstFrameStudios

**Rationale:**
- **Separate repo** keeps monitoring concerns out of the main FFS codebase
- **Vite + vanilla JS** is minimal, fast to iterate, and good for learning
- **Read-only observer pattern** — monitor reads heartbeat/logs but never writes to FFS
- **Sprint 0 = scaffolding only** — real implementation tracked via GitHub Issues

**Links:**
- Repo: https://github.com/jperezdelreal/ffs-squad-monitor
- Issues: https://github.com/jperezdelreal/ffs-squad-monitor/issues
- Inspiration: https://github.com/tamirdresher/squad-monitor

---

### 2026-03-11: Squad Upstream Setup — ComeRosquillas → FirstFrameStudios (Jango)
**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Status:** IMPLEMENTED  
**Scope:** Infrastructure / Squad Architecture

**Context:**
ComeRosquillas (Homer's Donut Quest) was absorbed into First Frame Studios at `games/comerosquillas/`. The standalone ComeRosquillas repo (jperezdelreal/ComeRosquillas) needs to inherit studio identity, skills, and process from the FFS hub.

The approved architecture is **Option C Hybrid**:
- **FirstFrameStudios** = Studio hub (parent squad with identity, skills, principles)
- **Game repos** = Subsquads inheriting via upstream connection

**Decision:**
Set up a manual upstream connection since `squad-cli v0.8.20` does not yet have native `upstream` commands.

**What Was Done:**
1. **Squad initialized** in ComeRosquillas via `squad-cli init --no-workflows`
2. **Upstream directory created** at `.squad/upstream/` with:
   - `manifest.json` — connection metadata, sync policy, inherited content list
   - `identity/` — copied identity files from FFS (principles, mission-vision, company, quality-gates, wisdom)
   - `skills/INDEX.md` — reference index of 41 FFS skills (categorized by applicability)
3. **Config updated** — `.squad/config.json` includes upstream hub reference
4. **upstream.json enriched** — added repo, relationship, last_synced, synced_content fields
5. **Committed and pushed** to `main`

**Sync Policy:**

| Content Type | Strategy | Notes |
|---|---|---|
| Identity files | Copy from hub | Upstream wins — these are studio-level |
| Skills | Reference index only | Full content stays in hub repo |
| Decisions | Reference only | Game-specific decisions stay local |
| Project config | Local only | Game-specific settings |

**How to Re-sync:**
When FFS identity or skills change, manually copy updated files:
```powershell
cd "C:\Users\joperezd\GitHub Repos\ComeRosquillas"
Copy-Item "C:\Users\joperezd\GitHub Repos\FirstFrameStudios\.squad\identity\{file}" ".squad\upstream\identity\{file}"
# Update last_synced in .squad/upstream.json
```

**Alternatives Considered:**
1. **Native `squad upstream` commands** — Not available in v0.8.20. When squad-cli adds this feature, migrate to native commands.
2. **Git submodules** — Too heavy for configuration inheritance. Submodules are for code, not squad metadata.
3. **Symlinks** — Don't work across repos on GitHub. Only viable for local development.

**Migration Path:**
When `squad-cli` ships `upstream add/sync/list`:
1. Run `squad upstream add` pointing to FFS
2. Run `squad upstream sync` to replace manual copies
3. Remove manual `.squad/upstream/` directory if native upstream uses a different structure
4. Update this decision document

**Risks:**
- **Manual sync drift** — If FFS identity changes and nobody syncs downstream, ComeRosquillas will have stale studio guidance. Mitigated by: checking sync date during ceremonies.
- **squad-cli breaking changes** — If a future version introduces native upstream with a different structure, migration will be needed.

---

### User Directives (2026-03-08)

#### 2026-03-08T115537Z: Ashfall Game Type Pivot
**By:** joperezd (via Copilot)  

Ashfall pivots from action roguelike to 1v1 fighting game (Tekken/Street Fighter style) in Godot 4. Scope limited to 1 stage + 2 characters initially. Content expansion deferred.

#### 2026-03-08T10:37: Repository Structure
**By:** joperezd (via Copilot)  

First Frame Studios uses a single GitHub repository (monorepo). The .squad/ folder lives at root (studio-level). Each game is a subfolder containing its Godot project. Team has access to GitHub Actions, PRs, Dashboards, and all GitHub features.

**Why:** Centralizes studio knowledge, skills, and team state. Each game is a folder, not separate repo.

#### 2026-03-08T10:25: Tool & Skill Development Autonomy
**By:** joperezd (via Copilot)  

Agents should NOT be limited to existing tools and skills. When performing a task, if an agent detects a gap or needs a specific tool to do better work, they should have the ability to request it and have it developed on the spot.

---

### Game Architecture (McManus)
**Date:** 2026-06-03  
**Status:** Implemented

Complete beat 'em up game with modular ES6 architecture and no external dependencies. Fixed timestep (60 FPS), Canvas 2D renderer with camera system, keyboard state management, Web Audio API sound effects. Entity-component pattern for Player and AI enemies with state machines. Combat uses rectangle collision detection, knockback physics, hitstun. Wave-based progression with camera locks. All graphics procedurally drawn via Canvas API. File structure: index.html + styles.css for entry, src/engine/entities/systems/scenes/ui/ for modules.

**Why:** Simplicity (no frameworks), modularity (clean separation), performance (fixed timestep), and satisfying combat feedback (screen shake, knockback, hitstun).

### Core Gameplay Bug Fixes (Keaton)
**Date:** 2024  
**Status:** Implemented

Five critical bugs fixed:
1. **Input infinite recursion** — Renamed duplicate `isDown()` to `isMovingDown()` to prevent stack overflow
2. **Hit detection unreliability** — Moved `Combat.handlePlayerAttack()` to run every frame with `attackHitList` Set to prevent multi-hits
3. **Damage loop** — Added 500ms invulnerability frames (`invulnTime`) with blink effect for visual feedback
4. **Parallax direction** — Changed background scroll from 1.3x to 0.3x for proper depth perception
5. **Left boundary** — Added player boundary check `Math.max(player.x, cameraX + 10)` to keep player visible

**Why:** Surgical fixes to make game playable. Each addressed a specific bug without rewriting systems. Hit tracking and i-frames follow standard beat 'em up patterns.

### Team Expansion (Solo/Keaton, Lead)
**Date:** 2026-06-03  
**Status:** Implemented

Complete squad expansion from 4 core roles (Solo, Chewie, Lando, Wedge) to 9-member cross-game development team. VFX/Art Specialist (Boba) confirmed. Three new roles added:
- **Greedo (Sound Designer):** Owns Web Audio API expertise, procedural SFX library, music generation system. 7 backlog items (2×P0, 2×P1, 1×P2, 2×P3). Frees Chewie from audio work. Cross-game value: ★★★★★ (sound toolkit compounds across all projects).
- **Tarkin (Enemy/Content Dev):** Owns enemy AI, boss design, wave composition, pickups, difficulty scaling. 14 backlog items (1×P1, 6×P2, 7×P3). Reduces Lando from 26→12 items. Works in parallel on content while Lando builds player systems.
- **Ackbar (QA/Playtester):** Owns testing, balance tuning, feel verification across all items. Develops calibrated instincts for hitbox fairness, combo timing, input responsiveness. Cross-game value: ★★★★☆ (feel tuning expertise compounds).

Revised load distribution eliminates McManus bottleneck, enables parallel workstreams (Engine/Gameplay/Content/Presentation).

**Why:** Gap analysis on 52-item backlog revealed structural overload: Lando carrying 50%, Chewie juggling audio + engine. Three new roles distribute work, enable parallelism, and build compounding cross-game expertise.

### Phaser 3 & Future Tech (2026-03-06T20:05)
**By:** joperezd (via Copilot)  
**Status:** Pending — Future Project Planning

Phaser 3 and other "too late to implement" improvements should be captured as learnings for future projects, not implemented in firstPunch. The squad should conduct deep research across all game development disciplines, document everything, analyze the current game for what's easily implementable vs needs major refactoring, and work autonomously for 4 hours with excellence as the standard.

**Why:** Strategic learning capture for the game dev squad's growth across projects. Protects firstPunch from scope creep while building institutional knowledge for next project.

### Full Codebase Analysis & Learnings (Solo)
**Date:** 2026-03-06  
**Status:** Completed

Read all 28 source files (370KB) and categorized every remaining backlog item into 3 buckets:

**Key Findings:**
1. **13 AAA backlog items already shipped** (grab/throw, dodge roll, back attack, attack buffering, screen zoom, slow-mo kills, scene transitions, destructibles, hazards, boss intros, ambience, hit sound scaling, options menu, hitbox visualization). Active backlog should be ~85 items, not 101.

2. **3 complete infrastructure systems exist but unused**: EventBus (49 LOC), AnimationController (85 LOC), SpriteCache (35 LOC). Also CONFIG (45 LOC). Total: 214 LOC of working code gathering dust. Wiring these is highest-priority action.

3. **Bucket classification:**
   - **Quick Wins (< 1h):** 10 remaining actionable items
   - **Medium Effort (1-4h):** 30 actionable items
   - **Future/Migration:** 14 items requiring Phaser 3 or WebGL

4. **gameplay.js (695 LOC) = #1 technical debt** — touches every system, 40+ direct calls. EventBus wiring is the single most impactful refactor.

5. **Procedural art ceiling reached** — each character needs ~400 LOC Canvas code. Adding Kid/Defender/Prodigy = 1200+ LOC. Strongest argument for Phaser 3 + sprite sheets.

6. **Phaser 3 migration impact:** Replaces ~800 LOC infrastructure (game loop, renderer, input, camera, particles, animation) with GPU-accelerated equivalents. Keeps ~3500 LOC game-specific logic.

**Recommended Priority:** Wire unused infrastructure (CONFIG, EventBus, AnimationController, SpriteCache) → Quick Wins → Combat polish → Content/Visual quality → System polish → Phaser 3 migration.

### New Project Playbook Created (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Studio-wide — affects how every future project starts

Created `.squad/identity/new-project-playbook.md` — the definitive, repeatable process for starting any new project at First Frame Studios, regardless of genre, tech stack, IP, or platform.

**What It Contains:**
1. **Pre-Production Phase** — Genre research protocol (7-12 reference games, analytical play, skill extraction), IP assessment (original vs licensed), 9-dimension tech selection framework, team skill transfer audit, competitive analysis
2. **Sprint 0 Foundation** — Engine-agnostic repo checklist, squad adaptation guide, genre skill creation, architecture proposal requirements, minimum playable formula per genre, quality gates adaptation
3. **Production Phases** — P0-P3 priority system, parallel lane planning, skill capture rhythm, cross-project knowledge transfer
4. **Technology Transition Checklist** — What transfers/rewrites/needs evaluation, migration mapping (Canvas→Godot as template), repeatable training protocol
5. **Language/Stack Flexibility Matrix** — 12 tech stacks compared, T-shirt migration sizing, the 70/30 rule (70% of our effectiveness is tech-agnostic)
6. **Anti-Bottleneck Patterns** — 7 firstPunch bottlenecks with preventions, 6 common studio patterns, serialize/parallelize guide, add-role vs add-skill decision matrix

**Key Decisions Within:**
- **8-point migration threshold:** Require 8+ point lead in 9-dimension matrix to justify engine migration
- **20% load cap:** No agent carries more than 20% of any phase's items
- **Module boundaries in Sprint 0:** Architecture proposal required before Phase 2 code begins
- **Wiring requirement:** Every infrastructure PR must include connection to at least one consumer

**Why:** The founder wants solid foundations so starting any new project is clear, repeatable, and bottleneck-free. firstPunch taught us everything in this playbook through real bugs, real bottlenecks, and real breakthroughs. Documenting it ensures we never repeat the investigation.

**Impact:**
- Every future project follows this playbook from Day 1
- Pre-production becomes a structured process, not ad-hoc discovery
- Technology transitions follow a proven 4-phase pattern
- Bottleneck patterns are identified and mitigated proactively
- New team members can read this document and understand how we start projects

### Skills System Needs Structural Investment Before Next Project (Ackbar)
**Author:** Ackbar (QA Lead)  
**Date:** 2025-07-21  
**Status:** Proposed

Conducted comprehensive audit of all 12 skills in `.squad/skills/`. Quality of individual skills is strong (7/12 rated ⭐⭐⭐⭐+), but coverage (5/10) and growth-readiness (4/10) are the weaknesses.

**Decision:**
Three actions should be taken before the next project kicks off:

1. **Create `game-feel-juice` skill (P0)** — Our #1 principle ("Player Hands First") has no dedicated skill. Game feel patterns are scattered across 3 skills. A unified, engine-agnostic game feel reference should be the first skill any new agent reads. Assign to Yoda + Lando.

2. **Create `ui-ux-patterns` skill (P1)** — Wedge is a domain owner with zero skills. Every game needs UI. This is the largest single-agent gap on the team. Assign to Wedge.

3. **Structural cleanup (P1)** — Split `godot-beat-em-up-patterns` (39KB, too large). Resolve overlaps: merge `canvas-2d-optimization` into `web-game-engine`, deduplicate `godot-tooling` vs `project-conventions`. Assign to Solo + Chewie.

**Impact:**
- **Yoda, Lando:** Create `game-feel-juice` skill
- **Wedge:** Create `ui-ux-patterns` skill  
- **Solo, Chewie:** Structural cleanup of overlapping skills
- **All agents:** 6 skills should have confidence bumped from `low` to `medium`
- **Full audit:** `.squad/analysis/skills-audit.md` contains per-skill ratings, gap analysis, and improvement recommendations

### 2026-03-10: New Project Proposals Ceremony
**By:** Full Team (6 agents — Yoda, Chewie, Lando, Boba, Solo, Tarkin)  
**What:** 18 game proposals generated with internet research for post-Ashfall direction. Top 5 ranked by AI-friendliness, scope, and viral potential:
1. **LAST SIGNAL** (micro-horror radio routing, 2 wk MVP) — Yoda's pick
2. **FLORA** (cozy gardening roguelite with L-systems, 3 wk MVP) — Boba's pick
3. **RICOCHET RAMPAGE** (physics destruction arcade, 3 wk MVP) — Lando's pick
4. **FACTORY FLUX** (automation puzzle roguelite, 4 wk MVP) — Solo's pick
5. **SHADOW THIEF** (stealth platformer as shadow, 4 wk MVP) — Boba's runner-up

**Why:** Ashfall closure ceremony concluded the studio needs simpler, web-first games that leverage rapid prototyping strengths. All 18 proposals designed to avoid Ashfall's failure modes (subjective feel tuning, complex art pipelines, genre complexity).

**Status:** AWAITING FOUNDER DECISION — Joaquín to review and select direction.

---

### 2026-03-11: Upstream + SubSquad + Blog Patterns Architecture Proposal
**By:** Solo (Lead Architect) + Jango (Tool Engineer)  
**Status:** AWAITING FOUNDER APPROVAL  
**What:** Complete implementation plan for incorporating Tamir Dresher blog patterns + upstream + subsquad into FFS workflow.

**Architecture Decision: Option C — Hybrid (RECOMMENDED)**
- `FirstFrameStudios/` = Studio hub (parent squad with identity, skills, principles)
- `jperezdelreal/flora` = Game repo (subsquad, inherits via `squad upstream`)
- Scales to future games: new repo + `squad upstream add FirstFrameStudios`
- 11 FLORA agents active, 3 hibernated (Leia, Bossk, Nien)

**Implementation Phases:**
- Phase 0: Restructure studio hub, TLDR convention (Day 1)
- Phase 1: Create FLORA repo, squad init, squad upstream (Day 1-2)
- Phase 2: CI/CD, workflows, issue templates, project board (Day 2-3)
- Phase 3: ralph-watch + scheduler (Day 3-4)
- Phase 4: FLORA Sprint 0 — build the game! (Day 4+)
- Phase 5: Podcaster + Squad Monitor (Week 2+)

**Tooling Priority:**
- DO FIRST: Issue template, heartbeat cron, TLDR convention, archive/notify workflows (~5h)
- DO NEXT: ralph-watch.ps1, scheduler, daily-digest, drift-detection (~24h)
- DO LATER: Squad Monitor, Podcaster (~5h)

**Full plans available in session context. Awaiting Joaquín's go/no-go.**

---

### 2026-03-11: Autonomy Gap Audit — Planned vs Implemented
**By:** Solo (Lead Architect)  
**Requested by:** Joaquín  
**Status:** INFORMATIONAL — input to prioritization

**Context:**
Joaquín flagged frustration: the squad planned an autonomous execution model (from Tamir Dresher blog patterns, Option C hybrid architecture in `solo-upstream-subsquad-proposal.md`) but much of it remains unimplemented. This audit compares what was **planned** in the inbox decisions vs what **actually exists** in the repo.

**Source Documents Analyzed:**
1. `copilot-tamir-blog-learnings.md` — 16 operational patterns from Tamir's blog
2. `solo-upstream-subsquad-proposal.md` — Option C hybrid implementation plan (5 phases)
3. `copilot-directive-2026-03-11T0745-repo-autonomy.md` — Founder directive: agents can create repos autonomously

**Gap Matrix:**

| # | Pattern / Plan Item | Status | Evidence |
|---|---------------------|--------|----------|
| 1 | **GitHub Issues = Central Brain** | ✅ IMPLEMENTED | Issue templates exist (`.github/ISSUE_TEMPLATE/squad-task.yml`), triage workflow exists, labels created |
| 2 | **Ralph Outer Loop (`ralph-watch.ps1`)** | ⚠️ BUILT, NOT ACTIVATED | Script exists at `tools/ralph-watch.ps1` (fully implemented, single-instance guard, heartbeat, structured logging). **Never run persistently.** Heartbeat file exists but is likely stale. |
| 3 | **Maximize Parallelism in Ralph** | ❌ NOT TESTED | Ralph prompt exists but parallel agent spawning not validated in production runs |
| 4 | **Two-Way Communication via Webhooks** | ❌ NOT IMPLEMENTED | No webhook integration, no Teams/Slack adapter, no notification channel configured |
| 5 | **Auto-Scan External Inputs** | ❌ NOT IMPLEMENTED | No email/Teams/HackerNews scanning. No `teams-bridge` label usage. |
| 6 | **Podcaster for Long Content** | ❌ NOT IMPLEMENTED | No Edge TTS integration. Phase 5 item — correctly deferred. |
| 7 | **Self-Built Scheduler** | ⚠️ BUILT, NOT ACTIVATED | `tools/scheduler/Invoke-SquadScheduler.ps1` exists with cron evaluator. Needs `schedule.json` tasks defined and actual activation via ralph-watch. |
| 8 | **Squad Monitor Dashboard** | ❌ NOT IMPLEMENTED | Not installed (`dotnet tool install -g squad-monitor` never run). Phase 5 item. |
| 9 | **Side Project Repos** | ⚠️ AUTHORIZED, NOT USED | Founder directive grants autonomy for repo creation. No side repos created yet. |
| 10 | **GitHub Actions Ecosystem** | ✅ MOSTLY IMPLEMENTED | 20+ workflows exist: triage, heartbeat, daily-digest, drift-detection, archive-done, label-enforce, label-sync, CI, docs, preview, release. **Comprehensive.** |
| 11 | **Self-Approve PRs** | ❌ NOT CONFIGURED | No auto-merge setup. PRs require human review. |
| 12 | **Cross-Repo Contributions** | ❌ NOT STARTED | No upstream PRs to Squad repo or other tools |
| 13 | **`squad upstream` for inherited context** | ❌ NOT IMPLEMENTED | Option C planned studio-hub + game-repo inheritance. No `squad upstream` configured. ComeRosquillas lives inside FFS repo, not as a subsquad. |
| 14 | **Multi-repo management** | ❌ NOT IMPLEMENTED | ralph-watch supports `$Repos` param but only single repo in use |
| 15 | **TLDR Convention** | ⚠️ DOCUMENTED, NOT ENFORCED | Team knows the pattern. No automated enforcement. No CI check for TLDR in issue comments. |
| 16 | **Issue Template** | ✅ IMPLEMENTED | `.github/ISSUE_TEMPLATE/squad-task.yml` exists |

**Phase Tracking (from `solo-upstream-subsquad-proposal.md`):**

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 0** | Restructure studio hub, TLDR convention | ⚠️ PARTIAL — hub exists, TLDR not enforced |
| **Phase 1** | Create game repo, squad init, squad upstream | ❌ NOT STARTED — ComeRosquillas absorbed into FFS, no subsquad |
| **Phase 2** | CI/CD, workflows, issue templates, project board | ✅ MOSTLY DONE — workflows are comprehensive |
| **Phase 3** | ralph-watch + scheduler | ⚠️ BUILT, NOT ACTIVATED |
| **Phase 4** | Game Sprint 0 — build the game | ⚠️ IN PROGRESS — ComeRosquillas exists (1636 LOC, playable) but no sprint structure |
| **Phase 5** | Podcaster + Squad Monitor | ❌ NOT STARTED (correctly — Phase 5) |

**Summary: What's Actually Blocking Autonomy:**

The infrastructure is **more built than it appears**. The real gap is **activation, not construction**:

1. **ralph-watch.ps1 needs to be started and left running.** The script is production-ready with single-instance guards, heartbeat, logging, and multi-repo support. It just hasn't been turned on.

2. **Scheduler needs tasks defined.** `Invoke-SquadScheduler.ps1` works but `schedule.json` needs actual recurring tasks (daily playtest, weekly retro, drift detection triggers).

3. **TLDR enforcement is cultural, not technical.** Agents write TLDRs when reminded. Need a lightweight CI check or prompt-level convention reinforcement.

4. **The subsquad/upstream model was abandoned** in favor of absorbing ComeRosquillas directly into FFS. This is fine for a single game but won't scale. Decision needed: is this the permanent model or a temporary expedient?

5. **Webhooks/notifications are the biggest true gap.** No way for the squad to proactively signal Joaquín when something important happens. This is the highest-leverage unbuilt feature.

**Recommended Priority Order:**
1. **P0:** Activate ralph-watch persistently (DevBox or local machine)
2. **P0:** Define schedule.json with 3-5 recurring tasks
3. **P1:** Install Squad Monitor (`dotnet tool install -g squad-monitor`)
4. **P1:** Add webhook notification for critical events (CI failure, PR merged)
5. **P2:** Evaluate subsquad model for ComeRosquillas vs monorepo approach
6. **P2:** Podcaster integration for long reports

---

### 2026-03-11: Autonomous Infrastructure Pivot to ComeRosquillas
**Author:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Status:** Implemented

**Context:**
The autonomous loop infrastructure (ralph-watch, scheduler, heartbeat) was built during the FLORA planning phase but never became operational. The studio focus has shifted to ComeRosquillas (Homer's Donut Quest), a web game at `games/comerosquillas/` using HTML/JS/Canvas.

**Decision:**
1. **now.md** points to ComeRosquillas as the active project (not FLORA)
2. **Scheduler tasks** reference web-game workflows (browser playtest, browser compat) instead of Godot builds
3. **Backlog grooming** is enabled (was disabled)
4. **tools/README.md** documents how to start the autonomous loop with one command
5. **Legacy Godot tools** remain in `tools/` for reference but are documented as archived

**Consequences:**
- Any agent reading `now.md` will know the active game is ComeRosquillas
- The scheduler will create web-game-appropriate issues when ralph-watch runs
- Joaquín can start the full loop with `.\tools\ralph-watch.ps1`

**Team Impact:**
- **All agents:** now.md context is current — no confusion about FLORA vs ComeRosquillas
- **Ackbar:** Playtest issues now include browser checklist instead of Godot build instructions
- **Mace:** Backlog grooming is back on the schedule (Wednesdays)
- **Ralph:** Loop is verified operational — just needs to be started

---

### 2026-03-11: Learnings from Tamir Dresher's "Organized by AI" blog
**By:** Joaquín (via Copilot) — team reading assignment  
**Source:** https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai  
**What:** Key patterns from a power-user who runs Squad as his daily productivity system.

**Operational Patterns We Should Adopt:**

1. **GitHub Issues = Central Brain.** All Squad discussion happens IN issue comments. Agents always write TLDR at top of every comment. The founder reviews TLDRs, writes instructions in comments, sets status back to "Todo." Everything is documented, searchable, nothing lost.

2. **Ralph Outer Loop (`ralph-watch.ps1`).** Wraps Ralph in a persistent PowerShell loop that: (a) pulls latest code before each round, (b) spawns fresh Copilot sessions each time, (c) has heartbeat files, structured logging, failure alerts. Runs on machine or DevBox unattended.

3. **Maximize Parallelism in Ralph.** Prompt explicitly says: "If there are 5 actionable issues, spawn 5 agents in one turn." Don't work issues one at a time.

4. **Two-Way Communication via Webhooks.** Squad sends Teams/Slack messages for critical events (CI failures, PR merges, blocking issues). Uses Adaptive Cards with styled formatting. Rule: only send when genuinely newsworthy, never spam.

5. **Auto-Scan External Inputs.** Squad reads emails (Outlook COM), Teams messages, and tech news (HackerNews, Reddit). Creates GitHub issues automatically for actionable items. Labels like `teams-bridge` distinguish auto-created from manual.

6. **Podcaster for Long Content.** Converts markdown reports to audio via Edge TTS. Listen to 3000-word reports while walking. Auto-triggered after significant deliverables (>500 words).

7. **Self-Built Scheduler.** `Invoke-SquadScheduler.ps1` — cron-based triggers for recurring tasks (daily scans, weekly reports). Maintains state file. Runs before each Ralph round.

8. **Squad Monitor Dashboard.** Real-time .NET tool showing agent activity, token usage, costs. Open-sourced at github.com/tamirdresher/squad-monitor. `dotnet tool install -g squad-monitor`.

9. **Side Project Repos.** Squad creates their own repos for tools/utilities that shouldn't clutter the main repo. Links back to main project.

10. **GitHub Actions Ecosystem.** Workflows for: triage, heartbeat (5 min), daily digest, docs auto-gen, drift detection (weekly), archive done issues (7 days), notifications, label enforcement, label sync from team.md.

11. **Self-Approve PRs (Personal Repos).** For personal repos, Squad creates, reviews, and merges their own PRs. Human only jumps in for areas they care about or flagged reviews.

12. **Cross-Repo Contributions.** Squad naturally contributes back upstream to tools they use (PRs to Squad repo itself).

**Philosophy Shifts:**

- **"I don't manage tasks anymore. I manage decisions."** — The human focuses on decisions, Squad does everything else.
- **"AI is the first approach that meets me where I am."** — AI adapts to human chaos, not the other way around.
- **"The boundary between using a tool and building a tool dissolved."** — Squad evolved its own tools (monitor, scheduler, tunnel) as needs arose.
- **Squad as brain extension, not replacement.** — User still makes all important decisions. AI remembers, does tedious work, keeps systems running.

**Multi-Repo & Upstream Patterns (Joaquín highlighted these):**

13. **`squad upstream` for inherited context.** Tamir used the `upstream` command to inherit decisions, skills, and team context from parent squads. His personal Squad connects to work repos so agents can scan and learn from them without copy-pasting context. This enables hierarchical squad organization — one parent Squad with shared knowledge, child Squads per project.

14. **Multi-repo management.** Squad agents create and manage their OWN repos when they need standalone tools (squad-monitor, cli-tunnel, squad-personal-demo). Ralph's prompt includes `MULTI-REPO WATCH` to scan multiple repos for actionable issues in a single round. Example: `"In addition to tamresearch1, also scan tamirdresher/squad-monitor for actionable issues."`

15. **Cross-repo contributions upstream.** Agents contributed PRs back to the Squad repo itself: ADO Platform Adapter (PR #191), CommunicationAdapter (PR #263), SubSquads (PR #272), Upstream & Watch commands (PR #280), test resilience (PR #283). The boundary between "using a tool" and "building a tool" dissolved completely.

16. **Side project repos as first-class workflow.** When agents need a standalone tool, they create a repo, build it there, and link back to the main project. Just like a real engineer saying "I'll build this separately so it doesn't clutter the main project." Examples: squad-monitor (real-time dashboard, open-sourced), cli-tunnel (remote terminal access).

**Applicable to First Frame Studios:**

- We should adopt the **GitHub Issues as backbone** pattern — all agent work documented in issue comments with TLDRs
- We should explore **ralph-watch.ps1** for unattended operation during long builds/sprints
- **Squad Monitor** could give Joaquín visibility into what agents are doing during long parallel spawns
- The **Podcaster** pattern could help Joaquín consume long analysis docs (we generate a LOT of analysis)
- **GitHub Actions workflows** (triage, heartbeat, daily digest) would automate our current manual processes
- The **self-built scheduler** pattern would enable recurring tasks (daily playtest, weekly retro)
- **`squad upstream`** could let FFS have a master Squad with studio-wide knowledge (principles, conventions, skills) inherited by each game project's Squad — shared wisdom without duplication
- **Multi-repo watch** in Ralph would let us monitor both the main FFS repo AND any game-specific repos (e.g., a separate `games/flora` repo) from a single Ralph loop
- **Cross-repo contributions** — our agents could contribute improvements back to Squad itself when they hit limitations, just like Tamir's team did

---

### 2026-03-11T07:45: User directive — Side Project Repo Autonomy
**By:** Joaquín (via Copilot)  
**What:** Los agentes pueden crear repos públicos bajo demanda sin aprobación previa. Ellos deciden el nombre, qué agentes asignar, y todo lo que haga falta para el side project. Autonomía total en gestión de repos.

**Why:** User request — captured for team memory. Enables Tamir-style "side project repos as first-class workflow" pattern.

---

### 2026-03-10T22:06: User directive — Visual Quality Standard
**By:** Joaquín (via Copilot)  
**What:** Los juegos propuestos deben ser VISTOSOS — nada de cutreces baratas. Visualmente impresionantes pero rápidos de hacer. El objetivo es aprender cosas nuevas (frameworks como Vite, etc.) y hacer show off. Explorar lo que hay en la web: gente usando Squad/AI para completar juegos tipo Pokémon, nuevos frameworks, ideas novedosas sin sobrecomplicaciones.

**Why:** User request — captured for team memory. Establishes visual quality as non-negotiable criteria for next project selection.

---

### 2026-03-10: Ashfall Project Closure
**By:** Full Team (closure ceremony)  
**What:** Ashfall (1v1 fighting game, Godot 4) officially shelved after 2 complete sprints. Key lessons: fighting games too complex for AI-only tuning, art pipeline needs validation before production, integration gates must be automated from Day 1, Lead Architect role must split at 10+ agents.

**Why:** Team consensus — the genre requires subjective feel-tuning that AI agents cannot deliver. Studio pivoting to simpler, faster-to-ship game genres.

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

---

### Documentation & Terminology Clarity (2026-03-09T10:11Z)
**By:** joperezd (via Copilot)
**Date:** 2026-03-09
**Status:** Directive

**What:** All public-facing documentation (wiki, devblog, README) must clearly distinguish between Milestone Gates (M0-M4 within a sprint) and Sprints (Sprint 0 = Foundation, Sprint 1 = Art, etc.). No ambiguity — readers should understand at a glance where the project stands without confusing "M3" with "Sprint 3". Use consistent terminology everywhere.

**Why:** User experienced confusion from docs mixing milestone gate numbers with sprint/phase numbers. This caused incorrect assumptions about project status. Accuracy and clarity in documentation is a top priority.

---

### Sprint Definition of Success (2026-03-09T10:14Z)
**By:** joperezd (via Copilot)
**Date:** 2026-03-09
**Status:** Directive

**What:** Every sprint must have a clear "Definition of Success" — specific, measurable criteria that determine whether the sprint can be closed satisfactorily. This applies retroactively to Sprint 0 and must be defined upfront for all future sprints (Sprint 1+). The criteria should answer: "What must be true for us to close this sprint satisfied?" Not just "tasks done" but quality gates, feel checks, and ship readiness.

**Why:** Without explicit success criteria, sprints drift — you can't tell if you're done or just out of time. The founder wants clarity on what "done" means for each sprint so the team knows the goal and can celebrate when they hit it.

---

### Jango — Solo Role Split (2026-03-09)
**Author:** Joaquín (User)  
**Status:** Active  
**Scope:** Team role clarification — Solo & Mace

**Change:** Solo's role narrowed to pure architecture review. Operational tasks (blocker tracking, branch rebasing, stale issue management) moved to Mace.

**Why:** "Architecture review is deep work" — can't do it well while context-switching to ops. Solo does uninterrupted architecture design. Mace handles transactional ops (check, flag, resolve).

**Authority:**
- **Solo:** Pure architecture review, system design, integration patterns, code structure
- **Mace:** Ops backbone — blocker unblocking, branch validation, issue cleanup, rebase coordination

**Artifacts:** Solo's charter updated, Mace's charter updated, routing.md updated.

---

### Mace — GitHub Operations Setup (2026-03-08)
**Author:** Mace (Producer)  
**Status:** Implemented  
**Scope:** GitHub-centric project operations for FirstFrameStudios

What Was Done:

1. **README.md Development Section** — Links to Issues, Project, Wiki, workflow diagram, CONTRIBUTING.md
2. **CONTRIBUTING.md Created** — Complete workflow:
   - Branch naming: `squad/{issue-number}-{slug}`
   - Commit format with examples
   - Label system explanation (game, squad, type, priority, status)
   - How Squad agents pick up work (via labels)
   - PR process, code review standards, 20% load cap
3. **team.md Updated** — Issue Source section (jperezdelreal/FirstFrameStudios, game:ashfall filter for current sprint)
4. **GitHub Wiki Status** ⏳ — Wiki cannot be enabled via API. Manual action required: joperezd must enable in repo settings

**Why:** Centralized visibility, clear workflow, scalability, governance, discoverability.

**Decisions Made:**
- Label-driven work allocation (Squad agents query GitHub Issues by label, not manual assignment)
- Branch naming ties to issues (squad/{issue-number} enables auto-linking)
- Wiki optional, not critical (processes in CONTRIBUTING.md; Wiki hosts GDDs/ARCHs separately)
- Load cap governance in CONTRIBUTING.md (team understands 20% rule)
- Game-tagged filtering (game:ashfall current sprint, future games follow same model)

**Risk Mitigation:**
- Wiki not enabled immediately? No impact; critical docs in repo.
- Squad agents don't find issues? Daily standup in #ashfall clarifies ownership.
- Load cap enforcement? Mace monitors daily, blocks merges if agent exceeds 20%.

**Follow-Up Actions:**
- [ ] joperezd: Enable Wiki in repo settings
- [ ] joperezd: Create Wiki home page
- [ ] Solo: Train agents on branch naming + commit format
- [ ] Jango: (Optional) GitHub Actions validator for branch names
- [ ] Mace: Begin daily #ashfall standup

---

### Mace — Dev Diary Post Process (Post-Milestone)
**Author:** Mace (Producer)  
**Decision:** Create Dev Diary discussion post after each milestone

**Process:**
1. **Timing:** Post within 24 hours of milestone completion
2. **Category:** "General" discussion category
3. **Title Format:** `🔥 Dev Diary #X: [Milestone Title]` (e.g., "#2: Character Sprites & Polish")
4. **Content:** Pitch, What We Shipped, By The Numbers, What's Next, The Meta, CTA
5. **Tone:** Passionate, transparent, indie dev blog + behind-the-scenes documentary. NOT corporate.
6. **Visibility:** Public-facing marketing for First Frame Studios. Every post reminds readers this is AI-powered dev.

**Integration with Wiki:**
- Update `.squad/wiki/milestones.md` after each milestone
- Link Dev Diary discussion from milestone entry
- Track discussion URL for metrics

---

### Mace — Issue Creation Discipline (2026-03-09)
**Author:** Joaquín (User)  
**Decision:** All agents must create GitHub issues immediately when they find bugs, blockers, or unresolved questions

**Why:** Post-mortems revealed known problems never tracked. Tarkin's AI controller sat on dead branch with no issue. Solo's overload surfaced only in ceremony. Issues at discovery time, not retroactively.

---

### User Directives — March 8-9, 2026

#### 2026-03-08T12:42:49Z: GitHub-First Development
**By:** Joaquín (User)  
**What:** Use GitHub's full potential — Issues for task tracking, Projects for boards, PRs for code review. No empty repo; everything active and visible.

#### 2026-03-08T18:01:00Z: Joaquín Never Reviews Code
**By:** Joaquín (User)  
**What:** Joaquín is NOT a code reviewer. Jango (Lead) handles all PR reviews. Founder focuses on vision, not implementation.

#### 2026-03-08T18:05:00Z: Wiki Auto-Update Post-Milestone
**By:** Joaquín (User)  
**What:** Wiki updates automatically after each milestone as part of dev cycle. Mace responsibility. Integrate in post-milestone flow.

#### 2026-03-08T18:10:00Z: Dev Diary Auto-Post
**By:** Joaquín (User)  
**What:** El devlog (GitHub Discussions) se publica automáticamente tras cada milestone, igual que la wiki. Responsabilidad de Mace. No se pide manualmente.

#### 2026-03-08T21:22:00Z: Jango Unlimited on Tooling
**By:** Joaquín (User)  
**What:** Jango (Lead) has NO 20% bandwidth limit. Full freedom to propose and create tools, scripts, automations. Not just reviewer — tool engineer with carte blanche.

#### 2026-03-09T09:15:31Z: Backlog Automation, Team Autonomy, Role Overload
**By:** Joaquín (User)  
**What:** 
1. Backlog sync must be automated (CI/CD) — scan code for TODOs, docs for undocumented items, auto-create issues
2. Lead autonomy on bandwidth — Jango adjusts workload distribution independently, no CEO approval needed
3. Auto-wiki/devblog updates — Implement Jango's proposed automation
4. Solo overloaded — needs role split (architecture review ≠ ops tasks)
5. ADRs and integration testing — Evaluate and implement Solo's proposals


---

### 2026-03-11T11:20: User directive
**By:** Joaquín (via Copilot)
**What:** No Podcaster. No queremos integración de text-to-speech ni conversión de reports a audio.
**Why:** User decision — out of scope for FFS.

---

### 2026-03-11T12:16Z: User directive — GitHub Pages architecture and purpose
**By:** Joaquin (via Copilot)
**What:** Each repo has its own GitHub Pages site with distinct purpose:
- **FFS Hub Page** → Brand, identity, studio presentation. "AI Gaming Studio Hub". NOT game content.
- **Game Pages** (ComeRosquillas, Flora, etc.) → Game showcase: screenshots, changelog, playable demo (Play button).
- All Pages share a consistent Astro template/theme from FFS but with per-game branding/colors.
- Updates are automated: push to main → Actions rebuild → Pages deploys.
**Why:** User request — defines the purpose and content structure of each GitHub Pages site across the multi-repo architecture.

---

### 2026-03-11T12:19Z: User directive — FFS homepage and blog strategy
**By:** Joaquin (via Copilot)
**What:** 
1. FFS homepage is practically perfect as-is — do NOT redesign it.
2. FFS blog should auto-publish summarized progress updates from game repos (advances, milestones, releases).
3. Push-to-main workflow is correct for both hub and game repos.
**Why:** User request — preserves current hub design and establishes blog as the living chronicle of studio activity.

---

# Multi-Repo Studio Governance — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-24  
**Requested by:** Joaquín (Founder)  
**Status:** ⏳ AWAITING FOUNDER APPROVAL  
**Scope:** Studio-wide — defines how FFS operates as a multi-repo studio hub

---

## Preamble

Joaquín asked the fundamental governance question: **how does everything flow in a multi-game studio?** This document answers that question across 9 domains. Once approved, it becomes the operating manual for First Frame Studios.

**Studio Topology:**
```
FirstFrameStudios (Hub)
├── jperezdelreal/ComeRosquillas  (Game repo — HTML/JS/Canvas)
├── jperezdelreal/flora            (Game repo — Vite/TS/PixiJS, on hold)
├── jperezdelreal/ffs-squad-monitor (Tool repo — Vite/JS)
└── [future repos]                 (Created on demand per Repo Autonomy directive)
```

**Key Actors:**
- **Joaquín** — Founder. Vision, direction, go/no-go decisions. Never reviews code.
- **Solo** — Hub Lead / Chief Architect. Architecture, integration, governance.
- **Jango** — Tool Engineer / PR Reviewer. All code reviews, CI/CD, tooling.
- **Mace** — Producer. Sprint planning, ops, blocker tracking.
- **Yoda** — Game Designer / Vision Keeper. Creative coherence per project.
- **@copilot** — Coding agent. Executes well-defined tasks autonomously.
- **Ralph** — Work Monitor. Heartbeat, scheduling, multi-repo watch.

---

## 1. APPROVAL FLOW

### 1.1 Tiered Approval Model

| Tier | What | Approver | Turnaround | Examples |
|------|------|----------|------------|----------|
| **T0 — Auto-Approved** | Routine work matching existing patterns | No human approval needed | Immediate | Bug fixes, test additions, dependency updates, docs updates, @copilot issue work |
| **T1 — Agent-Reviewed** | Implementation PRs, feature work | Jango (PR Reviewer) | Same session | New features, refactors, gameplay changes, UI work, audio additions |
| **T2 — Lead-Reviewed** | Architecture changes, cross-system work | Solo (Lead) + Jango | Same day | New systems, module restructuring, API changes, integration PRs |
| **T3 — Founder-Decided** | Direction, vision, go/no-go | Joaquín | Async (via issue comment) | New game selection, project closure, team changes, budget decisions, this document |

### 1.2 Per-Repo Approval Rules

**Hub (FirstFrameStudios):**
- Identity/principles/wisdom changes → T3 (Founder)
- Team/routing/ceremonies changes → T2 (Solo)
- Skills creation/updates → T1 (Jango reviews, domain expert authors)
- Tool scripts (ralph-watch, scheduler) → T1 (Jango)
- Decision documents → T2 (Solo proposes, Founder approves if T3)

**Game Repos (ComeRosquillas, Flora, future games):**
- Gameplay code PRs → T1 (Jango reviews)
- Architecture decisions → T2 (Solo reviews)
- Game-specific .squad/ config → T0 (auto-approved, game squad manages)
- New game milestones/sprints → T2 (Mace + Solo + Yoda plan)
- Ship/no-ship decision → T3 (Founder)

**Tool Repos (ffs-squad-monitor, future tools):**
- Implementation PRs → T1 (Jango reviews)
- Creation of new tool repo → T0 (per Repo Autonomy directive, 2026-03-11)
- Tool repo architecture → T1 (Jango, since tool repos are Jango's domain)

### 1.3 Does Every PR Need Approval?

**Yes, but the level varies:**
- **T0 PRs** (bug fixes, docs, tests): Jango can fast-track approve or @copilot can self-merge if `copilot-auto-assign: true` is set and CI passes.
- **T1 PRs** (features): Jango reviews. One approval required. No Joaquín involvement.
- **T2 PRs** (architecture): Solo + Jango both review. Two approvals required.
- **T3 PRs** (governance): Joaquín approves via issue comment. Squad implements.

### 1.4 Can Game Repos Self-Approve?

**Yes, within bounds.** Game squads operate autonomously for T0 and T1 work:
- Game-internal features, bugs, and content → self-approved by game squad's reviewer (Jango)
- Cross-repo changes (upstream sync, shared tool integration) → Hub review (Solo)
- Game closure/archival → Founder decision (T3)

**Rule:** If the change stays inside the game repo and doesn't affect studio identity, skills, or team structure, the game squad approves it. If it flows upstream, Hub reviews.

---

## 2. AUTONOMY LEVELS

### 2.1 Autonomy Matrix by Repo Type

| Autonomy Level | Hub | Game Repo | Tool Repo |
|----------------|-----|-----------|-----------|
| **Full Autonomy** (no ask needed) | Tool scripts, orchestration logs, session logs | Gameplay code, game-specific bugs, local .squad/ config, issue creation, sprint execution | All implementation, architecture, issues, releases |
| **Notify Hub** (do it, then tell) | Skill updates, ceremony changes | New milestone start, dependency on hub skill, architecture deviations | Integration points with other repos |
| **Ask Hub** (propose, wait for approval) | Identity/principle changes, team roster changes | Cross-repo PRs, requests for new hub skills, requests for team changes | N/A — tool repos are fully autonomous |
| **Ask Founder** (escalate to Joaquín) | New game selection, project closures, budget | Ship decisions, IP/brand decisions | N/A |

### 2.2 What Can a Game Squad Do WITHOUT Asking the Hub?

1. ✅ Create issues, plan sprints, assign work within the game repo
2. ✅ Implement features, fix bugs, write tests, ship builds
3. ✅ Create game-specific .squad/ config, skills, and decisions
4. ✅ Merge PRs after Jango review (T1)
5. ✅ Create side-tool repos if needed (per Repo Autonomy directive)
6. ✅ Run ceremonies (retrospectives, design reviews, playtests)
7. ✅ Update game-specific documentation and README
8. ✅ Deploy to GitHub Pages or other hosting

### 2.3 What MUST Escalate to the Hub?

1. 🔺 Changes to studio identity (principles, mission, company identity)
2. 🔺 Requests for new studio-wide skills or skill modifications
3. 🔺 Team roster changes (wake hibernated agents, create new agents)
4. 🔺 Cross-repo dependencies (game A needs something from game B)
5. 🔺 Architecture patterns that should become studio standards
6. 🔺 Project closure, archival, or significant scope changes
7. 🔺 Any change to upstream-inherited content

### 2.4 @copilot Auto-Assign

**Current state:** `copilot-auto-assign: false` in team.md.

**Recommended policy:**
- **Hub repo:** Keep `false`. Hub work is governance/architecture — not @copilot's strength (🔴 per capability profile).
- **Game repos:** Set to `true` for issues labeled `squad:copilot`. Well-defined game tasks (HTML/JS/Canvas, TypeScript/Vite, PixiJS) are @copilot's sweet spot (🟢).
- **Tool repos:** Set to `true`. Tool implementation is straightforward and well-scoped.

**Guard rail:** @copilot PRs still require Jango review before merge. Auto-assign means auto-pickup, not auto-merge. The Lead triages which issues get `squad:copilot` per the routing table in routing.md.

---

## 3. SKILL FLOW BETWEEN REPOS

### 3.1 How Skills Move Between Games

```
Game A discovers pattern → Game A writes draft skill → Hub reviews → Hub curates → All games inherit
```

**Step-by-step:**
1. **Discovery:** During game development, an agent identifies a reusable pattern (e.g., "procedural maze generation for arcade games").
2. **Draft:** The agent writes a draft skill in the game repo at `.squad/skills/{skill-name}/SKILL.md` (per Self-Improvement charter section).
3. **Proposal:** Agent creates an issue in the Hub repo: `[Skill Proposal] {skill-name}` with link to draft.
4. **Review:** Solo reviews for studio-wide applicability. Yoda validates game design relevance. Jango checks technical quality.
5. **Promotion:** If approved, the skill is moved to the Hub's `.squad/skills/` directory and added to the skills index.
6. **Inheritance:** All game repos receive the skill on next `squad upstream sync`.

### 3.2 Studio Skills (Hub-Curated)

The Hub maintains **studio skills** — patterns proven across 2+ projects or deemed universally applicable. These live in `.squad/skills/` and are indexed.

**Current studio skills:** 41 skills across game design, audio, animation, level design, enemy design, studio craft, engine patterns, and more.

**Categorization for inheritance:**

| Category | Inherited By | Examples |
|----------|-------------|---------|
| **Universal** (all games) | All game repos | game-feel-juice, studio-craft, ui-ux-patterns, procedural-audio |
| **Genre-Specific** (opt-in) | Games in that genre | beat-em-up-combat, arcade-game-patterns |
| **Tech-Specific** (opt-in) | Games using that stack | canvas-2d-optimization, vite-typescript-patterns |
| **Archived** | None (reference only) | godot-beat-em-up-patterns, godot-tooling |

### 3.3 When a Game Discovers a Pattern

**Threshold for promotion:** A pattern becomes a studio skill when:
1. It solved a real problem in a shipped game (not theoretical)
2. It's documented with examples (not just a vague principle)
3. It applies to at least one other game genre/stack (or is demonstrably universal)
4. An agent explicitly proposes it (patterns don't promote themselves)

**Anti-pattern:** "This pattern works in ComeRosquillas so let's make it a studio skill." → Does it apply to Flora? To a future 3D game? If it's Pac-Man-specific, it stays in ComeRosquillas.

### 3.4 `squad upstream sync` — When and How

**When to sync:**
- After Hub identity changes (principles, wisdom, quality-gates)
- After new studio skills are approved
- At project kickoff (fresh sync before Sprint 0)
- Monthly maintenance sync (drift prevention)

**How to sync (until squad-cli ships native upstream):**
```powershell
# From game repo root
cd "C:\Users\joperezd\GitHub Repos\ComeRosquillas"

# Sync identity (upstream wins)
Copy-Item "..\FirstFrameStudios\.squad\identity\principles.md" ".squad\upstream\identity\"
Copy-Item "..\FirstFrameStudios\.squad\identity\wisdom.md" ".squad\upstream\identity\"
Copy-Item "..\FirstFrameStudios\.squad\identity\quality-gates.md" ".squad\upstream\identity\"

# Update skills index
Copy-Item "..\FirstFrameStudios\.squad\skills\INDEX.md" ".squad\upstream\skills\"

# Update timestamp
# Edit .squad/upstream/manifest.json → last_synced: (current ISO 8601)
```

**Who syncs:** Jango (Tool Engineer) owns the sync process. Mace tracks sync dates in ceremony checklists.

---

## 4. HUB'S ROLE IN GAME DEVELOPMENT

### 4.1 What Does the Hub Squad DO During Active Game Dev?

The Hub is **not idle** during game development. It operates as the **studio brain**:

| Hub Activity | Owner | Cadence |
|-------------|-------|---------|
| Skill curation and growth | Solo + domain experts | Ongoing — as proposals arrive |
| Cross-project pattern recognition | Solo | Per milestone review |
| Team health monitoring | Mace | Weekly |
| Tool development and maintenance | Jango | As needed |
| Ralph multi-repo watch | Ralph | Continuous (when activated) |
| Studio ceremonies (kickoff, ship, postmortem) | Solo + Yoda + Mace | Per lifecycle event |
| Upstream sync to game repos | Jango | Monthly + on-change |
| Quality gate evolution | Solo + Ackbar | Post-milestone |
| Dashboard/monitor maintenance | Jango | As needed |

### 4.2 Does Solo Review Game PRs?

**Only T2 PRs** (architecture changes). Solo does NOT review routine game PRs:
- **Jango** reviews all T0 and T1 PRs (bug fixes, features, content)
- **Solo** reviews T2 PRs (new systems, module restructuring, cross-system integration)
- **Solo** performs integration gate verification after parallel agent waves

**Rationale:** Per the Jango-Solo role split decision (2026-03-09), Solo does deep architecture work. Routine PR review is Jango's domain. Context-switching between architecture and line-by-line review degrades both.

### 4.3 How Does Hub Identity/Wisdom Flow Downstream?

Three mechanisms:

1. **Upstream sync** — Identity files (principles, wisdom, quality-gates) copied to game repos. Upstream wins on conflicts.
2. **Agent charters** — All agents carry studio-scoped charters that reference hub principles. Charters travel with the agent regardless of which repo they work in.
3. **Ceremony outputs** — Kickoff ceremony includes "read the principles" step. Retrospective outputs flow back to hub as lessons. Skills flow through promotion pipeline.

### 4.4 Does the Hub Create Issues for Games?

**Both models coexist:**

| Issue Source | Where Filed | Examples |
|-------------|------------|---------|
| Game squad self-manages | Game repo | Bugs, features, sprint work, playtesting |
| Hub identifies cross-project issue | Hub repo (tagged `game:{name}`) | Upstream sync needed, skill gap identified, pattern to promote |
| Founder requests | Game repo (if game-specific) or Hub (if studio-wide) | "Add mobile controls", "Ship by Friday" |
| Ralph/Scheduler creates | Game repo | Recurring tasks (weekly playtest, backlog grooming) |

**Rule:** Games are self-managing by default. The Hub intervenes when it spots cross-project patterns, upstream drift, or quality gate failures that the game squad missed.

---

## 5. SIDE PROJECT LIFECYCLE

### 5.1 When a Game Needs a New Tool

**Per the Repo Autonomy directive (2026-03-11):** Any agent can create a public repo for a side project without prior approval. They decide the name, agent assignments, and everything needed.

**Process:**
1. Agent identifies need (e.g., "we need a sprite consistency checker")
2. Agent creates repo under `jperezdelreal/` (or proposes under `FirstFrameStudios/` org if created)
3. Agent runs `squad init` in the new repo
4. Agent sets up `squad upstream add FirstFrameStudios` for inherited context
5. Agent creates initial issues and starts building
6. Agent notifies Hub (issue in FFS: `[New Tool] {tool-name} created`)

### 5.2 Where Is Tool Development Tracked?

**In the tool repo itself.** The tool is a first-class project with its own issues, PRs, and milestones.

**Hub tracking:** The Hub maintains a reference in `team.md` (Active Projects table) and `routing.md` (Multi-Repo Issue Routing). Hub does NOT duplicate the tool's issue board.

**Cross-reference:**
- Tool repo README links back to FFS as parent studio
- FFS team.md lists the tool repo with status
- Ralph's multi-repo watch includes tool repos

### 5.3 How Tools Get Shared Across Games

1. **NPM/package:** If the tool is a library, publish to npm or use git submodule
2. **Script copy:** If the tool is a script (like integration-gate.py), copy to game repos that need it
3. **Studio skill:** If the tool embodies a pattern, promote the pattern to a hub skill
4. **Direct dependency:** If the tool is a standalone app (like squad-monitor), games don't depend on it — it reads from them

**Rule:** Tools should be **read-only observers** of game repos where possible (like squad-monitor reads heartbeat data but never writes to game repos). This prevents coupling.

---

## 6. CEREMONY SCHEDULE

### 6.1 Studio Ceremony Calendar

| Ceremony | When | Facilitator | Participants | Output |
|----------|------|-------------|-------------|--------|
| **Project Kickoff** | When Founder greenlights a new game | Solo (Lead) | Solo + Yoda + Mace + Jango + Joaquín | Repo created, squad initialized, Sprint 0 plan, architecture proposal, GDD skeleton |
| **Sprint Planning** | Start of each sprint (biweekly) | Mace (Producer) | Mace + Yoda + Solo | Sprint scope, assignments, milestone, success criteria |
| **Mid-Sprint Review** | Midpoint of sprint | Mace (Producer) | Mace + active agents | Progress check, blocker identification, scope adjustment |
| **Sprint Retrospective** | End of each sprint | Solo (Lead) | All involved agents | 5 went-right / 5 went-wrong, action items, lessons for hub |
| **Integration Gate** | After parallel agent waves | Solo (Architect) | Solo + Ackbar | Systems verified connected, blockers documented |
| **Ship Ceremony** | When a game is "done" | Yoda (Vision Keeper) | Full team + Joaquín | Ship decision, release checklist, launch announcement |
| **Post-Mortem** | After project closure | Solo (Lead) | Full team | Lessons document, skill proposals, process improvements |
| **Next Project Selection** | After post-mortem + cooldown | Yoda (Game Designer) | Full team proposals, Joaquín decides | Game proposals ranked, Founder selects, kickoff scheduled |
| **Monthly Upstream Sync** | First Monday of month | Jango (Tool Engineer) | Jango | All game repos synced with latest hub identity/skills |
| **Quarterly Studio Review** | Every 3 months | Mace (Producer) | Solo + Mace + Joaquín | Studio health metrics, team assessment, strategic direction |

### 6.2 Ceremony Details

#### Project Kickoff (Solo facilitates)

**Trigger:** Joaquín greenlights a new game from the proposals list.

**Agenda (Day 1-2):**
1. Create game repo under `jperezdelreal/`
2. Run `squad init --no-workflows` (or full init when CLI supports it)
3. Set up `squad upstream` connection to FFS hub
4. Yoda drafts Game Design Document skeleton
5. Solo delivers Architecture v1.0 (per New Project Playbook)
6. Mace creates Sprint 0 plan with milestones and success criteria
7. Jango sets up CI/CD, issue templates, labels, workflows
8. Team reads principles.md (required — Principle #12)
9. Hub issue: `[Kickoff Complete] {game-name}` with all links

**Output:** Playable repo with architecture locked, GDD skeleton, Sprint 0 plan, CI green, upstream connected.

#### Ship Ceremony (Yoda facilitates)

**Trigger:** Game meets ship criteria (defined in Sprint N's Definition of Success).

**Agenda:**
1. Yoda performs final Vision Keeper review: "Does this feel like THIS game?"
2. Ackbar runs full smoke test on target platform(s)
3. Solo verifies integration gate passes
4. Mace confirms all milestone issues closed
5. Joaquín gives ship/no-ship decision (T3)
6. If ship: Jango triggers release workflow, Mace posts Dev Diary, Mace updates Wiki
7. Celebration. The team earned it.

**Output:** Released game, Dev Diary post, Wiki milestone entry, release tag.

#### Post-Mortem (Solo facilitates)

**Trigger:** After Ship Ceremony or after project closure/archival.

**Agenda (per Principle #15):**
1. Each agent contributes "5 went right / 5 went wrong" (async, before ceremony)
2. Solo synthesizes into patterns
3. Identify skills to promote to hub
4. Identify process improvements for next project
5. Write lessons to `.squad/analysis/{game}-postmortem.md`
6. Create action items as Hub issues

**Output:** Postmortem document, skill proposals, process improvement issues, updated hub wisdom.

#### Next Project Selection (Yoda facilitates)

**Trigger:** After post-mortem cooldown (minimum 1 day, recommended 1 week).

**Agenda:**
1. Yoda calls for proposals: each agent may submit 1-3 game concepts
2. Proposals scored on: AI-friendliness, scope (MVP ≤ 4 weeks), visual impact, learning opportunity, viral potential
3. Top 5 presented to Joaquín with ranked recommendations
4. Joaquín selects (T3 decision)
5. Project Kickoff ceremony scheduled

**Output:** Ranked proposals document, Founder selection, kickoff date.

---

## 7. PROJECT LIFECYCLE

### 7.1 When a Game Is DONE

**"Done" means one of two states:**

#### State A: SHIPPED ✅
The game is released, playable, and the team is satisfied.

**Post-ship checklist:**
1. ✅ Release tag created (`v1.0.0`)
2. ✅ GitHub Pages deployment live (or other hosting)
3. ✅ All milestone issues closed with `Closes #N`
4. ✅ Post-Mortem ceremony completed
5. ✅ Lessons promoted to hub skills (where applicable)
6. ✅ Dev Diary final post published
7. ✅ Wiki updated with final status
8. ✅ Repo stays **ACTIVE** for patches and maintenance
9. ✅ README updated with "Released" badge and play link

**The repo does NOT get archived.** Shipped games may receive patches, community fixes, and minor updates. The repo goes into **maintenance mode** — new features are unlikely, but bugs get fixed.

#### State B: SHELVED 📦
The game is abandoned before shipping (like Ashfall).

**Post-shelve checklist:**
1. ✅ Post-Mortem ceremony completed (this is MORE important for shelved games)
2. ✅ Lessons promoted to hub skills aggressively (this is the game's legacy)
3. ✅ All useful patterns extracted before archival
4. ✅ Repo marked as archived on GitHub (Settings → Archive)
5. ✅ Hub team.md updated: project status → ✅ ARCHIVED
6. ✅ Final decision document explaining WHY it was shelved
7. ✅ Game-specific agents hibernated (if they have no cross-game role)

### 7.2 How Is the NEXT Game Selected?

**Who proposes:** Any agent on the team. Agents are encouraged to research trends, analyze what's working in the indie space, and propose games that match FFS strengths.

**Who decides:** Joaquín (Founder). Always. T3 decision. The team recommends, the Founder chooses.

**Game Jam option:** Yoda can propose a "48-hour game jam" ceremony where 3-4 agents each prototype a different game concept. The prototypes are played, and the best one becomes the next project. This is optional — Joaquín can also just pick from written proposals.

**Timeline from idea to repo:**

| Step | Time | Who |
|------|------|-----|
| Proposal written | 1-2 hours | Any agent |
| Team review & ranking | 1 session | Yoda facilitates, all agents vote |
| Founder selects | Async | Joaquín |
| Repo created + squad init | 30 minutes | Jango |
| Upstream connected | 15 minutes | Jango |
| Architecture v1.0 | 2-4 hours | Solo |
| GDD skeleton | 2-4 hours | Yoda |
| Sprint 0 plan | 1-2 hours | Mace |
| **Total: Idea → Building** | **~1-2 days** | — |

---

## 8. LOGGING AND OBSERVABILITY

### 8.1 Where Each Layer Logs

| Layer | Log Location | Format | Owner |
|-------|-------------|--------|-------|
| **Hub orchestration** | `.squad/orchestration-log/` | Markdown per session (`{date}-{agent}.md`) | Solo |
| **Hub tools** | `tools/logs/` | Structured JSON (ralph heartbeat, scheduler state) | Ralph / Jango |
| **Hub sessions** | `.squad/sessions/` | Session artifacts | Scribe |
| **Hub decisions** | `.squad/decisions/` + `.squad/decisions/inbox/` | Markdown decision docs | All agents |
| **Game repo squad** | Game's `.squad/log/` | Game-specific session logs | Game squad |
| **Game repo CI** | GitHub Actions logs | Standard CI output | Jango / GitHub |
| **Ralph heartbeat** | `tools/logs/heartbeat.json` | `{timestamp, repos_checked, issues_found, status}` | Ralph |
| **Ralph structured logs** | `tools/logs/ralph-{date}.jsonl` | One JSON object per line, per action | Ralph |

### 8.2 Cross-Repo Visibility

| Reader | Can Read | Cannot Read |
|--------|----------|-------------|
| **Hub agents** | All Hub logs, game repo public logs (via git clone/API) | Game repo local-only files |
| **Game agents** | Own repo logs, Hub upstream identity/skills (via sync) | Other game repo logs, Hub orchestration logs |
| **Ralph** | All repos (multi-repo watch), all heartbeat files | N/A — Ralph reads everything |
| **Joaquín** | Everything (founder access to all repos) | N/A |
| **Squad Monitor** | Hub + game heartbeat.json, ralph logs | Agent session content (too verbose) |

### 8.3 Monitor Dashboard Aggregation

**ffs-squad-monitor** aggregates by reading:
1. `heartbeat.json` from each repo (polling or webhook)
2. GitHub API for issue counts, PR status, CI status per repo
3. Ralph's structured logs for activity timeline

**Dashboard views (planned):**
- **Studio Overview:** All repos, their status, last activity
- **Agent Activity:** Who did what, when (from orchestration logs)
- **Issue Burndown:** Open/closed per repo over time
- **CI Health:** Green/red status per repo
- **Heartbeat Timeline:** When Ralph last checked each repo

---

## 9. BRAND AND QUALITY GUIDELINES

### 9.1 Studio-Level Rules (ALL Games Must Follow)

#### Code Standards
| Rule | Enforcement | Details |
|------|-------------|---------|
| **Branch naming** | CI check (label-enforce workflow) | `squad/{issue-number}-{slug}` |
| **Commit format** | Convention (CONTRIBUTING.md) | `type(scope): description` — types: feat, fix, chore, docs, style, refactor, test |
| **PR template** | Required | `Closes #N` MUST be in body. Agent name in description. |
| **PR review required** | Branch protection | Minimum 1 approval (Jango for T1, Solo+Jango for T2) |
| **CI must pass** | Branch protection | No merge with red CI |
| **No unused infrastructure** | PR review gate (Quality Gate C5) | Every system created must be wired to at least one consumer |

#### Issue Conventions
| Rule | Details |
|------|---------|
| **Labels** | `type:bug`, `type:feature`, `type:chore`, `priority:P0-P3`, `squad:{agent}`, `game:{name}` |
| **TLDR convention** | Every issue comment by an agent starts with a `**TLDR:**` line. Joaquín reads TLDRs only. |
| **Issue template** | Use `.github/ISSUE_TEMPLATE/squad-task.yml` for squad work |
| **Stale issue cleanup** | Issues untouched for 14 days get `status:stale` label (via workflow) |

#### README Structure (All Repos)
Every FFS repo README must include:
1. **Game/tool name + one-line description**
2. **Play/demo link** (GitHub Pages or equivalent)
3. **Screenshot or GIF** (visual-first — Principle #4: Ship the Playable)
4. **Tech stack badge(s)**
5. **"Part of First Frame Studios"** with link to hub repo
6. **Development section** (how to run locally, how to contribute)
7. **Squad section** (team members, how issues work)

#### Visual Identity
| Element | Standard |
|---------|----------|
| **Studio name** | "First Frame Studios" (always full name in READMEs and about pages) |
| **Tagline** | "Forged in Play" (optional, for marketing materials) |
| **Repo descriptions** | Include "First Frame Studios" or "FFS" for discoverability |
| **Dev Diary branding** | `🔥 Dev Diary #X:` format (Mace's established convention) |

### 9.2 How Are These Enforced?

| Mechanism | What It Enforces | Where |
|-----------|-----------------|-------|
| **Upstream sync** | Identity, principles, quality gates | All game repos (via .squad/upstream/) |
| **GitHub Actions workflows** | Branch naming, label enforcement, stale issues, CI, heartbeat | Per repo (copied from hub templates) |
| **PR review** | Code quality, commit format, PR template, TLDR | Jango reviews all PRs |
| **Ceremonies** | Process adherence, retrospective lessons | Solo/Mace facilitate |
| **Agent charters** | Domain expertise, skill references, self-improvement protocol | .squad/agents/{name}/charter.md |
| **CONTRIBUTING.md** | Workflow documentation, branch naming, commit format, label system | Per repo (synced from hub template) |

### 9.3 What's NOT Standardized (Game Autonomy)

Games have full freedom over:
- Art style and visual direction (per-game identity)
- Tech stack choice (HTML/Canvas, Vite/TS/PixiJS, future engines)
- Game-specific mechanics and design decisions
- Internal file structure and module organization
- Game-specific CI/CD beyond the baseline
- Marketing and community engagement approach

---

## Summary: The Three Laws of FFS Governance

1. **Games are autonomous, Hub is authoritative.** Games run their own sprints, merge their own PRs, and manage their own issues. The Hub owns identity, skills, quality standards, and team composition.

2. **Everything escalates by tier, nothing escalates by default.** T0 auto-approves. T1 goes to Jango. T2 goes to Solo. T3 goes to Joaquín. When in doubt, check the tier table.

3. **Knowledge flows up and down.** Patterns discovered in games flow UP to hub skills. Identity and standards flow DOWN via upstream sync. Ralph watches everything. The monitor shows everything. Nothing is siloed.

---

## Approval

This document requires Founder approval (T3) to become active.

**To approve:** Comment on the Hub issue with "APPROVED" or "APPROVED WITH CHANGES: {details}".

**Once approved:**
- This document moves from `.squad/decisions/inbox/` to `.squad/decisions/`
- All game repos receive a sync with the new governance rules
- routing.md and team.md are updated to reference this document
- Mace adds ceremony schedule to project board

---

*Written by Solo (Lead / Chief Architect) — First Frame Studios*  
*"The studio grows when the rules are clear enough to follow and flexible enough to not need exceptions."*

---

## 2026-03-11T14:28: User Directive — Auto-Delete Branches + Code Review Rulesets

**By:** Joaquín (via Copilot)  
**What:** When creating repos, always enable "Automatically delete head branches" and set up rulesets for code review.  
**Why:** User request — captured for team memory. Ensures clean branch hygiene and enforced PR reviews across all FFS repos.

---

## 2026-03-11: ComeRosquillas Ghost AI Architecture Decision

**Date:** 2026-03-11  
**Author:** Tarkin (Enemy/Content Designer)  
**Issue:** #7 — Improve ghost AI with difficulty curve and personality  
**Status:** ✅ Implemented (PR #11)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
Ghost AI in ComeRosquillas was functional but all four villains behaved nearly identically (classic Pac-Man Blinky/Pinky/Inky/Clyde targeting with no personality feel). No difficulty scaling beyond minimal speed increase.

**Decision:**
Implement personality-based targeting through the existing `getChaseTarget()` method + random direction overrides in `moveGhost()`, plus a 0..1 difficulty ramp that scales 6 parameters across 9 levels.

**Ghost Personality Mapping:**
- Burns → Ambush (targets ahead of Homer)
- Bob Patiño → Aggressive (direct chase, speed bonus)
- Nelson → Patrol/Guard (zone defense with proximity trigger)
- Snake → Erratic (random directions + random targets)

**Difficulty Scaling Parameters:**
Ghost speed, fright duration, scatter/chase time ratios, ghost house exit delays, frightened ghost speed, personality aggression values — all driven by single `getDifficultyRamp()` function.

**Rationale:**
1. Personality through target selection keeps one unified `moveGhost()` — no per-ghost state machines needed for a Pac-Man clone
2. Difficulty ramp as 0..1 float makes all scaling parameters easy to tune from one place
3. All changes confined to `js/game-logic.js` per the modularization architecture (Chewie's decision)

**Impact on other agents:**
- Lando: Scoring/progression unaffected — ghost point values unchanged
- Chewie: Engine untouched — no renderer or audio changes
- Wedge: UI/HUD untouched

---

## 2026-03-11: ComeRosquillas Audio Architecture (Greedo)

**Date:** 2026-03-11  
**Author:** Greedo (Sound Designer)  
**Issue:** #8 — Sound effects variety and improved music  
**PR:** #12  
**Repo:** jperezdelreal/ComeRosquillas

**Decision:**

Implemented mix bus architecture (sfxBus + musicBus → compressor → destination) and expanded procedural audio to 8 SFX types with variation systems. All sounds procedural via Web Audio API — no external audio files.

**Key Choices:**

1. **Mix bus with compressor:** DynamicsCompressor on master prevents clipping when SFX and music overlap. This is zero-cost and should be standard on all projects.
2. **Variation via cycling + pitch spread:** Chomp cycles through 4 patterns with ±8% random pitch. Death randomly picks from 3 variants. Ghost-eat pitch escalates with combo. These techniques prevent repetition fatigue without adding complexity.
3. **Backward-compatible API:** `play(type, data)` accepts optional second parameter. Existing `play('chomp')` calls work unchanged. Only 2 lines changed in game-logic.js.
4. **Smooth mute transitions:** `linearRampToValueAtTime` instead of hard gain cuts. Prevents audio pops.

**Impact on Other Agents:**

- **Lando/Tarkin:** If adding new game events (bonus collect, combo chain), call `this.sound.play('newType')` and add a case in audio.js. The API pattern is established.
- **Chewie:** Bus architecture is initialized in SoundManager constructor. No engine changes needed.
- **Wedge:** If adding audio settings UI, use `toggleMute()` for music and the bus gain values for volume sliders.

---

## 2026-03-11: ralph-watch README ASCII-safe and v2-accurate

**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Issue:** #152

**Context:**
tools/README.md was out of date -- it documented ralph-watch v1 defaults (single repo) and omitted v2 features (failure alerts, activity monitor, metrics parsing, multi-repo).

**Decision:**
Rewrote README to accurately reflect ralph-watch v2:
- Default `-Repos` is all 4 FFS repos, not just `.`
- Documented failure alerts (alerts.json after 3+ consecutive failures)
- Documented activity monitor (background runspace)
- Documented metrics parsing (issues closed, PRs merged/opened)
- Added prerequisites section (gh CLI, copilot extension)
- All text ASCII-safe (no emojis, no Unicode dashes) for PS 5.1 compatibility

**Impact:**
- Any agent or human reading tools/README.md now gets accurate activation instructions
- Startup is one command: `.\tools\ralph-watch.ps1`

---

## 2026-03-11: Flora Architecture — Module Structure & Patterns

**Author:** Solo (Lead Architect)  
**Date:** 2026-03-11  
**Repo:** jperezdelreal/flora  
**PR:** #2  
**Status:** PROPOSED (awaiting merge)

**Context:**

Flora is FFS's second game — a cozy gardening roguelite built on Vite + TypeScript + PixiJS v8. Needed a clean architecture from day one to avoid the monolithic anti-pattern that plagued ComeRosquillas (1636 LOC game.js) and firstPunch (695 LOC gameplay.js).

**Decision:**

### Module Structure (7 modules)

| Module | Responsibility | Rules |
|--------|---------------|-------|
| `core/` | SceneManager, EventBus, (future: input, asset loader) | Owns the game loop |
| `scenes/` | Individual game screens (boot, menu, garden, etc.) | One active at a time |
| `entities/` | Game objects (plants, player, tools) | Scene-agnostic |
| `systems/` | ECS-lite update loops (growth, weather, inventory) | Communicate via EventBus |
| `ui/` | HUD, menus, dialogs | Subscribe to events, never mutate state |
| `utils/` | Math, RNG, helpers | Pure functions, no imports from other src/ modules |
| `config/` | Constants, balance values, tuning | Pure data, no side effects |

### Key Patterns

1. **Scene-Based Architecture** — All game states are Scenes managed by SceneManager. One active at a time. Clean init/update/destroy lifecycle.

2. **ECS-Lite** — Not a full Entity-Component-System framework. Lightweight systems that iterate typed entity collections. Keeps complexity proportional to game scope.

3. **Typed Event Bus** — Pub-sub with EventMap type for compile-time safety. Prevents circular dependencies between systems, UI, and scenes.

4. **PixiJS v8 Patterns** — Async `Application.init()`, `app.canvas` (not `app.view`), `Text({text, style})` object syntax, `Assets.load()` API.

### Dependency Direction

```
main.ts → core → scenes → entities/systems/ui
config ← imported by anything
utils ← imported by anything
EventBus ← imported by scenes, systems, ui
```

**Rationale:**

- Modular from day one prevents the monolith anti-pattern (lesson from ComeRosquillas and firstPunch)
- Scene-based is simpler than FSM for a small-medium game
- ECS-lite avoids framework overhead while keeping separation of concerns
- Event bus is the standard decoupling pattern for game modules

**Implications:**

- All new features go in the appropriate module (no cross-cutting monoliths)
- New scenes implement the Scene interface
- New systems implement the System interface
- Inter-module communication goes through EventBus, not direct imports

---

## 2026-03-11: Flora Game Design Document (GDD v1.0)

**Date:** 2026-03-11  
**Decided By:** Yoda (Game Designer)  
**Status:** READY FOR ARCHITECTURE REVIEW  
**Artifact:** `jperezdelreal/flora/docs/GDD.md` (PR #1)

### Decision Summary

**What:** Approved Flora GDD v1.0 as the design foundation for Sprint 0 development.

**Why:** 
1. Aligns with "cozy first, challenge second" directive from Joaquín
2. MVP scope is realistic for AI-developed game (12 plants, one-season loop, basic hazards)
3. Roguelite elements are light (discovery-driven, not punishment-driven)
4. Design decisions support tech stack (Vite + TypeScript + PixiJS v8)
5. Clear progression loop ensures engagement without grinding

**Scope:** 
- Sprint 0 MVP: 8×8 garden, 12 plants, 20–40 min per run, 3–5 runs per session
- Post-MVP deferred: garden expansion, complex synergies, cosmetics, seasonal variety, save/load

### Key Design Pillars

1. **Cozy but Intentional** — Relaxing tone, meaningful choices, no punishment
2. **Every Run is Different** — Randomized seeds, unique scenarios each time
3. **Grow & Discover** — Incremental unlocks, botanical encyclopedia grows with playtime
4. **The Garden Reflects You** — Aesthetic choices are expressive; memories persist

### Core Loop

**One Run = 20–40 minutes**

1. **Seeding (3–5 min):** Choose from 4–6 random plants; arrange on 8×8 plot
2. **Tending (12–25 min):** Water, harvest, manage pests, adapt to weather (12 in-game days)
3. **Harvest & Reflection (2–5 min):** Collect new seeds, update encyclopedia, unlock rewards

**Each Season Resets:** Garden, weather, available seeds, plant states  
**Each Season Persists:** Encyclopedia, tools, garden upgrades, achievements

### Meta-Progression (Session Level)

Unlocks per run:
- **Runs 1–2:** Common seeds (8–10), basic tools
- **Runs 3–5:** Rare seeds, soil upgrades, compost system
- **Runs 6–10:** Heirloom seeds, garden structures, advanced tools

After 5–10 runs, player feels measurably more powerful and has discovered 15–20 unique plants.

### Garden Mechanics

#### Plant System
- **Growth Time:** 3–8 in-game days (varies per plant)
- **Water Need:** 1–5 waterings per cycle
- **Health:** 0–100% (affected by water, pests, weather)
- **Yield:** 1–3 seeds per harvest + bonus fruit (aesthetic)

#### Hazards (All Solvable, No Combat)
- **Pests:** Appear on day 6–8; player removes manually or uses tools
- **Drought:** Increases watering frequency (Summer hazard)
- **Frost:** Sensitive plants wilt if not harvested in time (Winter hazard)
- **Weeds:** Occupy space or slow growth; removable or compostable

### Art & Audio Direction

**Art:**
- Tilebase pixel art (16×16 grid, 32×32 plants/player)
- Warm earthy palette (soil browns, greens, sky blues, accent flower colors)
- Seasonal shifts (spring pastels → summer gold → fall rust → winter cool)
- Smooth growth animations; satisfying harvest pop

**Audio:**
- Ambient loops (60–90 BPM, cozy lo-fi style)
- Soft SFX (water pour, soil tap, harvest chime, pest rustle)
- No stressful cues; total mix encourages relaxation

### MVP Scope (Hard Boundary for Sprint 0)

#### IN MVP
- One-season loop (12 in-game days)
- 12 plant types (4 common, 4 uncommon, 2 rare, 2 heirloom)
- 8×8 garden plot
- Hazards: pests, drought
- Tools: basic watering can, hand, pest remover
- Encyclopedia (discover/unlock mechanic)
- Soil quality (basic feedback)
- One tool unlock per first harvest
- One plant unlock per season completion

#### OUT of MVP (Deferred)
- Garden expansion
- Complex synergies (polyculture bonus, shade mechanic)
- Advanced tools (soil tester, compost bin, trellis)
- Seasonal variety (MVP = same season all runs)
- Cosmetics / achievements
- Save/load (single session only)
- Mobile optimization

### Success Criteria

Players will:
1. ✓ Complete 3–5 runs in one session
2. ✓ Discover at least 1 new plant per run
3. ✓ Feel harvesting is rewarding (audio + visual works)
4. ✓ Play for 30–40 minutes without rushing
5. ✓ See encyclopedia growth; feel progression
6. ✓ No frustration; hazards solvable by restart

### Next Steps

1. **Architecture Review (Solo):** Validate tech stack feasibility; suggest data structures
2. **Sprint 0 Planning (Jango, Squad):** Timeline, asset needs, task breakdown
3. **Art Spike:** Plant sprite concepts (16×16, growth frames)
4. **Audio Spike:** Ambient track (90 sec loop) + 5 SFX

### Design Philosophy Reinforced

> *"Cozy First, Challenge Second."*

Every design decision prioritizes:
1. **Player agency** — Hazards are puzzles, not punishments
2. **Discovery** — Unlocking feels like loot drops in traditional roguelikes
3. **Accessibility** — Failed run = "next season, I'll try different" not "I lost progress"
4. **Visible progress** — Encyclopedia fills; tools appear; garden expands

**Approved by:** Yoda, Game Designer  
**For:** First Frame Studios Squad  
**Date:** 2026-03-11

**Related Decisions:**
- **Studio Philosophy:** "Player Hands First" (session 7)
- **Genre Pillars:** "Game Feel is Differentiator" (2026-03-08)
- **Tech Stack:** Vite + TypeScript + PixiJS v8 (from now.md)
- **Scope Governance:** MVP-lock principle (from Mace's Sprint 0 plan, Ashfall)

---

### 2026-03-11T14:28: User directive
**By:** Joaquín (via Copilot)
**What:** When creating repos, always enable "Automatically delete head branches" and set up rulesets for code review.
**Why:** User request — captured for team memory. Ensures clean branch hygiene and enforced PR reviews across all FFS repos.

---

# Decision: ComeRosquillas Audio Architecture (Greedo)

**Date:** 2026-03-11  
**Author:** Greedo (Sound Designer)  
**Issue:** #8 — Sound effects variety and improved music  
**PR:** #12  
**Repo:** jperezdelreal/ComeRosquillas

## Decision

Implemented mix bus architecture (sfxBus + musicBus → compressor → destination) and expanded procedural audio to 8 SFX types with variation systems. All sounds procedural via Web Audio API — no external audio files.

## Key Choices

1. **Mix bus with compressor:** DynamicsCompressor on master prevents clipping when SFX and music overlap. This is zero-cost and should be standard on all projects.
2. **Variation via cycling + pitch spread:** Chomp cycles through 4 patterns with ±8% random pitch. Death randomly picks from 3 variants. Ghost-eat pitch escalates with combo. These techniques prevent repetition fatigue without adding complexity.
3. **Backward-compatible API:** `play(type, data)` accepts optional second parameter. Existing `play('chomp')` calls work unchanged. Only 2 lines changed in game-logic.js.
4. **Smooth mute transitions:** `linearRampToValueAtTime` instead of hard gain cuts. Prevents audio pops.

## Impact on Other Agents

- **Lando/Tarkin:** If adding new game events (bonus collect, combo chain), call `this.sound.play('newType')` and add a case in audio.js. The API pattern is established.
- **Chewie:** Bus architecture is initialized in SoundManager constructor. No engine changes needed.
- **Wedge:** If adding audio settings UI, use `toggleMute()` for music and the bus gain values for volume sliders.

---

# Decision: ralph-watch README ASCII-safe and v2-accurate

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Issue:** #152

## Context
tools/README.md was out of date -- it documented ralph-watch v1 defaults (single repo) and omitted v2 features (failure alerts, activity monitor, metrics parsing, multi-repo).

## Decision
Rewrote README to accurately reflect ralph-watch v2:
- Default `-Repos` is all 4 FFS repos, not just `.`
- Documented failure alerts (alerts.json after 3+ consecutive failures)
- Documented activity monitor (background runspace)
- Documented metrics parsing (issues closed, PRs merged/opened)
- Added prerequisites section (gh CLI, copilot extension)
- All text ASCII-safe (no emojis, no Unicode dashes) for PS 5.1 compatibility

## Impact
- Any agent or human reading tools/README.md now gets accurate activation instructions
- Startup is one command: `.\tools\ralph-watch.ps1`

---

# Decision: Flora Architecture — Module Structure & Patterns

**Author:** Solo (Lead Architect)  
**Date:** 2026-03-11  
**Repo:** jperezdelreal/flora  
**PR:** #2  
**Status:** PROPOSED (awaiting merge)

## Context

Flora is FFS's second game — a cozy gardening roguelite built on Vite + TypeScript + PixiJS v8. Needed a clean architecture from day one to avoid the monolithic anti-pattern that plagued ComeRosquillas (1636 LOC game.js) and firstPunch (695 LOC gameplay.js).

## Decision

### Module Structure (7 modules)

| Module | Responsibility | Rules |
|--------|---------------|-------|
| `core/` | SceneManager, EventBus, (future: input, asset loader) | Owns the game loop |
| `scenes/` | Individual game screens (boot, menu, garden, etc.) | One active at a time |
| `entities/` | Game objects (plants, player, tools) | Scene-agnostic |
| `systems/` | ECS-lite update loops (growth, weather, inventory) | Communicate via EventBus |
| `ui/` | HUD, menus, dialogs | Subscribe to events, never mutate state |
| `utils/` | Math, RNG, helpers | Pure functions, no imports from other src/ modules |
| `config/` | Constants, balance values, tuning | Pure data, no side effects |

### Key Patterns

1. **Scene-Based Architecture** — All game states are Scenes managed by SceneManager. One active at a time. Clean init/update/destroy lifecycle.

2. **ECS-Lite** — Not a full Entity-Component-System framework. Lightweight systems that iterate typed entity collections. Keeps complexity proportional to game scope.

3. **Typed Event Bus** — Pub-sub with EventMap type for compile-time safety. Prevents circular dependencies between systems, UI, and scenes.

4. **PixiJS v8 Patterns** — Async `Application.init()`, `app.canvas` (not `app.view`), `Text({text, style})` object syntax, `Assets.load()` API.

### Dependency Direction

main.ts → core → scenes → entities/systems/ui
config ← imported by anything
utils ← imported by anything
EventBus ← imported by scenes, systems, ui

## Rationale

- Modular from day one prevents the monolith anti-pattern (lesson from ComeRosquillas and firstPunch)
- Scene-based is simpler than FSM for a small-medium game
- ECS-lite avoids framework overhead while keeping separation of concerns
- Event bus is the standard decoupling pattern for game modules

## Implications

- All new features go in the appropriate module (no cross-cutting monoliths)
- New scenes implement the Scene interface
- New systems implement the System interface
- Inter-module communication goes through EventBus, not direct imports

---

### ComeRosquillas Ghost AI Architecture Decision
**Date:** 2026-03-11  
**Author:** Tarkin (Enemy/Content Designer)  
**Issue:** #7 — Improve ghost AI with difficulty curve and personality  
**Status:** ✅ Implemented (PR #11)  
**Repo:** jperezdelreal/ComeRosquillas

**Context:**
Ghost AI in ComeRosquillas was functional but all four villains behaved nearly identically (classic Pac-Man Blinky/Pinky/Inky/Clyde targeting with no personality feel). No difficulty scaling beyond minimal speed increase.

**Decision:**
Implement personality-based targeting through the existing `getChaseTarget()` method + random direction overrides in `moveGhost()`, plus a 0..1 difficulty ramp that scales 6 parameters across 9 levels.

**Ghost Personality Mapping:**
- Burns → Ambush (targets ahead of Homer)
- Bob Patiño → Aggressive (direct chase, speed bonus)
- Nelson → Patrol/Guard (zone defense with proximity trigger)
- Snake → Erratic (random directions + random targets)

**Difficulty Scaling Parameters:**
Ghost speed, fright duration, scatter/chase time ratios, ghost house exit delays, frightened ghost speed, personality aggression values — all driven by single `getDifficultyRamp()` function.

**Rationale:**
1. Personality through target selection keeps one unified `moveGhost()` — no per-ghost state machines needed for a Pac-Man clone
2. Difficulty ramp as 0..1 float makes all scaling parameters easy to tune from one place
3. All changes confined to `js/game-logic.js` per the modularization architecture (Chewie's decision)

**Impact on other agents:**
- Lando: Scoring/progression unaffected — ghost point values unchanged
- Chewie: Engine untouched — no renderer or audio changes
- Wedge: UI/HUD untouched

---

# Decision: Flora CI/CD Pipeline Architecture

**Date:** 2026-03-11
**Author:** Jango (Tool Engineer)
**Scope:** Flora repo (jperezdelreal/flora)
**Issue:** #11

## Decision

Flora uses a two-workflow CI/CD architecture:

1. **ci.yml** -- Runs on all pushes and PRs to main/develop. Type-checks (tsc --noEmit), builds (vite build), uploads dist/ artifact.
2. **deploy.yml** -- Runs only on push to main. Builds and deploys to GitHub Pages via actions/deploy-pages@v4.

Vite base set to '/flora/' (with trailing slash) for GitHub Pages path resolution.

## Rationale

- **deploy-pages@v4** over gh-pages branch push: Cleaner permissions model, matches ComeRosquillas pattern, no need for deploy keys or PATs.
- **Separated CI from deploy**: PRs get fast validation without triggering deploys. Deploy only fires on main merge.
- **Type-check step**: Catches TypeScript errors before build, fails fast.
- **Artifact upload in CI**: Allows downloading and inspecting build output from any PR.

## Impact

- All FFS web games now use the same deploy-pages pattern
- Merge PR #12 and enable GitHub Pages (Source: GitHub Actions) in repo settings

---

# Decision: Flora Core Engine Architecture

**Date:** 2025-07-16  
**Author:** Chewie (Engine Developer)  
**Issue:** #3 — Core Game Loop and Scene Manager Integration  
**Status:** ✅ Implemented (PR #13)  
**Repo:** jperezdelreal/flora

## Context

Flora needed foundational engine infrastructure before any gameplay could be built. The scaffold provided stubs for SceneManager and EventBus but no game loop, input handling, or asset loading.

## Decisions

### 1. Fixed-Timestep Game Loop (Accumulator Pattern)
- GameLoop wraps PixiJS Ticker but steps in fixed 1/60s increments via time accumulator
- Max 4 fixed steps per frame prevents spiral of death on lag spikes
- Provides `frameCount` for deterministic logic and `alpha` for render interpolation
- **Rationale:** Deterministic state updates enable future save/replay/netcode. Variable-delta game logic causes desync bugs.

### 2. SceneContext Injection (No Global Singletons)
- Scenes receive `SceneContext = { app, sceneManager, input, assets }` in `init()` and `update()`
- No global `window.game` or singleton pattern
- **Rationale:** Explicit dependencies are testable, refactorable, and don't create hidden coupling.

### 3. Input Edge Detection Per Fixed Step
- `InputManager.endFrame()` clears pressed/released sets after each fixed-step update
- Raw key state persists across frames; edges are consumed once
- **Rationale:** Variable frame rates can cause missed inputs if edges are cleared per render frame instead of per logic step.

### 4. Scene Transitions via Graphics Overlay
- Fade-to-black using a Graphics rectangle with animated alpha (ease-in-out)
- No render-to-texture or extra framebuffers
- **Rationale:** Simple, GPU-efficient, works on all PixiJS backends (WebGL, WebGPU, Canvas).

## Alternatives Rejected
1. **Raw Ticker.deltaTime for game logic** — Non-deterministic, causes physics/timing bugs
2. **Global singleton for input/assets** — Hidden dependencies, harder to test
3. **CSS transitions for scene fades** — Breaks when canvas is fullscreen, not composable with game rendering


---

# PR Review Round 1 — CI Workflow Maintenance Decision

**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Context:** Reviewed 3 PRs across Flora and ComeRosquillas repos  
**Decision Status:** Team-wide policy

## Problem

ComeRosquillas PR #14 (multiple maze layouts) has CI failures despite correct implementation. Root cause: CI workflow (`.github/workflows/ci.yml`) checks for old monolithic structure (`js/game.js`) but the codebase was modularized in PR #10 (5 modules: config.js, audio.js, renderer.js, game-logic.js, main.js). The CI workflow was never updated to match the new structure.

## Decision

**CI workflows must be updated in the same PR that introduces structural changes.**

When a PR modifies project structure (file moves, modularization, build system changes), the author must:
1. Update CI workflow checks to match the new structure
2. Update any path references in workflows (artifact paths, script checks, HTML validation)
3. Verify CI passes before marking the PR ready for review

## Rationale

1. **Prevents Silent Breakage** — If modularization PR merges without CI updates, subsequent PRs fail with confusing errors unrelated to their changes
2. **Atomic Changes** — Structure + CI updates belong together logically (same architectural change)
3. **Review Clarity** — Reviewers can see the full impact of structural changes (code + tooling) in one PR
4. **Rollback Safety** — If a structural change needs to be reverted, the CI workflows revert with it

## Example: ComeRosquillas Modularization

**PR #10 (Modularization):**
- Split `js/game.js` (1789 lines) → 5 modules (config.js, audio.js, renderer.js, game-logic.js, main.js)
- Updated `index.html` to load modular scripts
- ❌ **Did NOT update** `.github/workflows/ci.yml` (still checked for `js/game.js`)

**PR #14 (Maze Layouts):**
- Added 4 maze templates to `config.js`
- Updated `game-logic.js` to rotate mazes
- ✅ Code quality excellent, spec compliance perfect
- ❌ CI fails: workflow checks for `js/game.js` reference in HTML (no longer exists)

**Impact:**
- PR #14 blocked on CI fix unrelated to maze implementation
- Reviewer (Jango) had to diagnose CI workflow mismatch
- Developer must add CI fix to maze PR or create separate PR

## Required CI Update for ComeRosquillas

Update `.github/workflows/ci.yml`:

```yaml
# Line 36-44: HTML structure check
- name: Check HTML structure
  run: |
    # Check for required HTML elements
    if ! grep -q '<canvas id="gameCanvas">' index.html; then
      echo "❌ Missing gameCanvas element!"
      exit 1
    fi
    
    # Check for modular script structure (not monolithic game.js)
    if ! grep -q 'src="js/config.js"' index.html; then
      echo "❌ Missing config.js script reference!"
      exit 1
    fi
    
    if ! grep -q 'src="js/main.js"' index.html; then
      echo "❌ Missing main.js script reference!"
      exit 1
    fi

# Lines 77-93: Verify game assets
- name: Verify game assets
  run: |
    # Check for required directories
    if [ ! -d "js" ]; then
      echo "❌ js/ directory not found!"
      exit 1
    fi
    
    # Check for core modular files
    if [ ! -f "js/config.js" ]; then
      echo "❌ js/config.js not found!"
      exit 1
    fi
    
    if [ ! -f "js/game-logic.js" ]; then
      echo "❌ js/game-logic.js not found!"
      exit 1
    fi
    
    if [ ! -f "js/main.js" ]; then
      echo "❌ js/main.js not found!"
      exit 1
    fi
```

## Alternatives Considered

1. **Separate CI Update PR** — Creates extra PR overhead, doesn't prevent breakage
2. **Manual CI Bypass** — Unsafe, breaks automation trust
3. **Post-Merge CI Fix** — Main branch broken between merge and fix

## Consequences

✅ **Benefits:**
- CI always matches codebase structure
- Structural PRs are fully self-contained
- Reviewers see complete architectural impact
- Subsequent PRs don't inherit structural CI failures

⚠️ **Tradeoffs:**
- Structural PRs have higher complexity (code + tooling changes)
- Requires PR authors to understand CI workflows
- May need CI workflow documentation for developers

## Action Items

1. **ComeRosquillas PR #14:** Developer adds CI workflow fix to the PR, re-runs CI, then merge
2. **Squad Documentation:** Add "CI Workflow Maintenance" section to contribution guidelines
3. **PR Template:** Add checklist item: "If this PR changes project structure, update CI workflows"
4. **Ralph Watch:** Add CI workflow check to PR review automation (detect structure changes, flag missing CI updates)

## Related Decisions

- **2026-03-11: ComeRosquillas CI Pipeline Strategy** — Lightweight CI for vanilla JS games (no bundler)
- **2026-03-11: ComeRosquillas Modularization Architecture** — 5-module split with clean DAG

## Status

**ACTIVE** — Policy applies to all future PRs across all FFS repos (FirstFrameStudios, ComeRosquillas, Flora, ffs-squad-monitor)


---

## Priority & Dependency System Design (2026-03-12)

**Archived from:** .squad/decisions/inbox/solo-priority-dependency-design.md  
**Status:** Approved T1 Decision — Moved to active decisions.md  
**Author:** Solo (Lead / Chief Architect)
# Priority & Dependency System Design

**Type:** T1 Decision (Lead authority)  
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-12  
**Status:** Final — Founder decisions incorporated, ready for T1 approval  
**Supersedes:** copilot-directive-2026-03-12T1128-priority-dependency-system.md  
**Related:** governance.md §2, routing.md, .github/agents/squad.agent.md (Ralph reference)

---

## Executive Summary

This design adds **Priority (P0-P3)** and **Dependency tracking** to FFS governance. These are orthogonal to Tiers (who approves): Priority determines execution order, Tiers determine approval authority. The system prevents wasted work when T2 tasks run ahead of unresolved T1 decisions by introducing a "prepare but don't merge" state for blocked work.

**Key principle:** Tier ≠ Priority. A T0 decision to launch a new game may be P2 (normal backlog). A T2 bug fix may be P0 (production outage).

---

## 1. Priority Definitions (P0-P3)

### Formal Definitions

| Priority | Name | Definition | Execution Rule |
|----------|------|------------|----------------|
| **P0** | Blocker | Nothing else advances until this is resolved. System-wide halt. | Process FIRST. Ralph holds all other assignments until P0 is resolved or transitioned. |
| **P1** | Sprint-Critical | Must complete in current sprint. Directly blocks sprint goals. | Parallel execution allowed. No merge until P0 items resolved. |
| **P2** | Normal Backlog | Standard work queue. Important but not time-sensitive. | Standard FIFO queue processing. Default priority if none assigned. |
| **P3** | Nice-to-Have | Low-impact improvements. Process when capacity available. | Last in queue. May be deferred indefinitely. |

### Priority Application Examples (FFS Context)

| Example | Priority | Rationale |
|---------|----------|-----------|
| Production outage in ComeRosquillas (game won't load) | P0 | Blocks all players. Everything stops until fixed. |
| Governance v2.0 design (Solo T1 decision) blocking 3 Sprint 1 features | P0 | 3 agents can't merge work. Architecture bottleneck. |
| CI pipeline broken — all PRs blocked | P0 | No code can merge. Team paralyzed. |
| Sprint 1 feature defined in GDD (M1 milestone) | P1 | Sprint commitment. Not a blocker but must complete this sprint. |
| Security vulnerability in auth flow (no active exploit) | P1 | Urgent but not production-halting. Must fix before next release. |
| Refactor game.js monolith (ComeRosquillas #154) | P2 | Important for maintainability but no immediate impact. |
| Add intermission cutscenes (ComeRosquillas #158) | P2 | Nice feature, no urgency. |
| Add dark mode to Squad Monitor dashboard | P3 | Polish. Not blocking anything. |
| Typo in README | P3 | Cosmetic. Fix when convenient. |

### Relationship Between Tier and Priority

**Core Principle:** Tier and Priority are **independent axes**.

| Axis | Question | Controls |
|------|----------|----------|
| **Tier** | Who must approve this? | Authority delegation, approval gates |
| **Priority** | When should this run? | Execution order, Ralph's work queue |

**Independence examples:**

- **T0 + P2:** Founder decides to create a new game repo (T0), but it's scheduled for Q2 (P2). High authority, low urgency.
- **T2 + P0:** Production bug in ComeRosquillas ghost AI (T2). Chewie has authority, but it's a blocker (P0).
- **T1 + P0:** Solo designs governance v2 (T1). No Founder approval needed, but 3 agents are blocked waiting for the design (P0).

**Interaction Rules:**

1. **Authority first, execution second.** Tier determines who can approve. Priority determines when to process.
2. **Emergency Authority overrides Priority.** Per governance.md §4, emergency fixes bypass normal approval tiers AND priority queue. They execute immediately.
3. **T0 decisions don't auto-escalate to P0.** Founder approval doesn't mean urgent execution. Solo triages and assigns priority.
4. **P0 doesn't grant T0 authority.** A P0 bug fix still requires appropriate tier approval. Urgency doesn't bypass governance.

### Priority and Emergency Authority Interaction

**Governance §4 already defines Emergency Authority:** Any agent may make emergency fixes (production outage, critical bug, security vulnerability) without normal approval. Constraints: minimum viable change, retroactive review within 24 hours, logged in retrospective.

**How P0 and Emergency Authority interact:**

| Situation | Use Emergency Authority | Use P0 Priority |
|-----------|-------------------------|-----------------|
| Production is down RIGHT NOW, game unplayable | ✅ Emergency fix immediately, retroactive review | Assign P0 after emergency fix merged (for related follow-up work) |
| Critical bug discovered in sprint, not yet in production | ❌ Not an emergency (no active outage) | ✅ P0 — block all other work, fix before next deploy |
| Governance design blocking 3 agents | ❌ Not an emergency (no production impact) | ✅ P0 — resolve design bottleneck ASAP |
| Security vulnerability, no active exploit | ❌ Not an emergency (no immediate harm) | ✅ P1 — urgent but not a full stop |

**Rule:** Emergency Authority is for active production crises requiring immediate action. P0 is for blocking work that prevents the team from making progress. They overlap rarely (a P0 production outage would trigger Emergency Authority, then post-fix work becomes P0).

### Emergency Follow-Up Priority Rule

After an emergency fix (governance §4), all follow-up work (tests, refactoring, postmortem) is automatically labeled **P1** (sprint-critical). The Lead may escalate to P0 if truly blocking, or downgrade to P2 if minor. This ensures emergency follow-up is treated with urgency but does not halt all other work by default.

---

## 2. Dependency Model

### Dependency Expression

Dependencies are expressed via **GitHub labels** plus structured **issue body section**.

**Labels** (generic — specifics go in the issue body):

| Label | Meaning |
|-------|---------|
| `blocked-by:issue` | Blocked by another issue (see body for details) |
| `blocked-by:pr` | Blocked by a PR merge (see body for details) |
| `blocked-by:decision` | Blocked by a pending decision (see body for tier) |
| `blocked-by:upstream` | Blocked by hub/parent repo work (see body for link) |
| `blocked-by:external` | Blocked by third-party (see body for details) |

**Issue body section** (added by Lead during triage):

```markdown
## Dependencies

**Blocked by:**
- #189 (Priority system design — T1 decision by Solo)
- Decision: governance.md §2 update must be approved before implementation

**Blocks:**
- #190 (Ralph implementation)
- #191 (Label automation)

**Prepare mode allowed:** Yes — agent may scaffold tests, update docs, write spike code in draft PR. NO MERGE until #189 approved.
```

**Why both labels and body text?**
- **Labels:** Machine-readable. Ralph scans for `blocked-by:*` labels.
- **Body section:** Human-readable context. Explains WHY the dependency exists and WHAT the agent can do while blocked.

### Types of Dependencies

| Type | Example | Label | Notes |
|------|---------|-------|-------|
| **Issue → Issue** | #190 depends on #189 | `blocked-by:issue` | Most common. Standard work dependency. |
| **Issue → PR** | #192 depends on PR #145 merging | `blocked-by:pr` | Rare. Usually just wait for the PR to merge. |
| **Issue → Decision** | #190 depends on Solo deciding governance v2 design | `blocked-by:decision` | Common for architecture/design work. |
| **Issue → Upstream** | ComeRosquillas #25 depends on FFS hub #189 | `blocked-by:upstream` | Cross-repo. Downstream project waits for hub decision. |
| **Issue → External** | #200 depends on Squad CLI v0.9 release | `blocked-by:external` | Third-party dependency. Rare. Track in comments. |

Generic labels avoid GitHub's 100-label limit. Specifics (which issue, which PR) go in the `## Dependencies` section of the issue body.

### The "Prepare But Don't Merge" Rule

**Exact semantics:**

When an issue is labeled with `blocked-by:*`, the assigned agent may:

**✅ ALLOWED ("Prepare"):**
- Create a branch (`squad/{issue-number}-{slug}`)
- Write tests (TDD approach — write failing tests for blocked feature)
- Scaffold code structure (empty functions, interfaces, type definitions)
- Write spike code to explore the problem space
- Update documentation (README, CHANGELOG, ADRs)
- Open a **Draft PR** with `[WIP]` prefix in title
- Commit and push to branch (work is saved, not lost)

**❌ FORBIDDEN (until blocker resolved):**
- Mark PR as "Ready for review"
- Merge to main (even if CI passes and reviews approve)
- Deploy to production
- Close the issue
- Remove `blocked-by:*` label without confirming blocker is resolved

**What "prepare" means in practice:**

The goal is to do useful work that won't be wasted if the blocker decision changes direction. Tests are safest (they document expected behavior). Scaffolding is next safest (structure can be refactored). Full implementation is risky (may need to be rewritten).

**Example: Issue #190 (Ralph implementation) blocked by #189 (priority system design)**

While blocked, the agent may:
1. Write test cases: "Ralph should process P0 issues first", "Ralph should skip blocked issues"
2. Scaffold `ralph-priority-queue.ts` with function stubs
3. Update `.github/agents/squad.agent.md` with placeholder sections
4. Open Draft PR titled "[WIP] feat: priority-aware Ralph (blocked by #189)"

The agent may NOT:
1. Implement the full priority queue logic (design may change)
2. Merge the PR (even if Solo reviews and approves it)
3. Close #190 (work is not complete until blocker resolved)

**How blocked state is tracked:**

| State | Label | PR State | Actions |
|-------|-------|----------|---------|
| **Blocked** | `blocked-by:*` present | Draft PR or no PR | Agent prepares, does NOT merge |
| **Unblocked** | `blocked-by:*` removed | Draft → Ready | Agent completes work, opens for review, merges after approval |
| **Stale block** | `blocked-by:*` present, blocker closed >24 hours ago | Draft PR | Ralph detects and flags (see §7 Edge Cases) |

**How to unblock:**

1. **Manual:** Lead or assigned agent checks blocker status, confirms resolved, removes `blocked-by:*` label
2. **Automated (future enhancement):** GitHub Action monitors `blocked-by:issue-N` labels, auto-removes when issue N closes
3. **Ralph check:** Ralph's scan cycle (Step 2) checks `blocked-by:*` labels, reports stale blocks

---

## 3. Ralph Changes

Ralph's current behavior (from squad.agent.md §Ralph — Work Monitor):

**Current Step 1 (Scan for work):**
- Untriaged issues (`squad` label, no `squad:{member}`)
- Member-assigned issues (`squad:{member}`, still open)
- Open PRs, Draft PRs
- Review feedback, CI failures, Approved PRs

**Current Step 2 (Categorize):**
- Untriaged → Lead triages
- Assigned → Spawn agent
- Draft PRs → Check progress
- Review feedback → Route to author
- CI failures → Notify agent
- Approved PRs → Merge

**Current Step 3 (Act):**
- Process one category at a time: Untriaged > Assigned > CI failures > Review feedback > Approved PRs
- NO priority awareness
- NO dependency checking

### New Scan Logic (Priority-Aware)

**Updated Step 1 (Scan for work):** Add priority and dependency filters to GitHub API calls.

```bash
# Untriaged issues (labeled squad but no squad:{member} sub-label)
gh issue list --label "squad" --state open --json number,title,labels,assignees --limit 50

# Member-assigned issues (labeled squad:{member}, still open)
gh issue list --state open --json number,title,labels,assignees --limit 50 | # filter for squad:* labels

# Blocked issues (has blocked-by:* label)
gh issue list --state open --json number,title,labels --limit 50 | # filter for blocked-by:* labels

# Open PRs from squad members
gh pr list --state open --json number,title,author,labels,isDraft,reviewDecision --limit 50

# Draft PRs (agent work in progress)
gh pr list --state open --draft --json number,title,author,labels,checks --limit 50
```

**Key addition:** Ralph now fetches up to 50 items (was 20) to ensure P0 items aren't missed due to pagination.

### New Step 2 (Categorize with Priority)

Ralph categorizes work into **priority buckets** before processing:

| Bucket | Filter | Processing Rule |
|--------|--------|-----------------|
| **P0 Active** | `priority:P0` + NOT `blocked-by:*` | Process FIRST. Hold all other work. |
| **P0 Blocked** | `priority:P0` + `blocked-by:*` | Flag as critical blocker. Report to Lead immediately. |
| **P1 Active** | `priority:P1` + NOT `blocked-by:*` | Process after P0, before P2. Parallel execution allowed. |
| **P1 Blocked** | `priority:P1` + `blocked-by:*` | Prepare mode. Spawn agent with BLOCKED flag in prompt. |
| **P2 Active** | `priority:P2` or NO priority label + NOT `blocked-by:*` | Standard queue. Process after P1. |
| **P2 Blocked** | `priority:P2` + `blocked-by:*` | Prepare mode. Low priority for spawning. |
| **P3 Active** | `priority:P3` + NOT `blocked-by:*` | Last in queue. Process only if no P0/P1/P2 work. |
| **P3 Blocked** | `priority:P3` + `blocked-by:*` | Skip. Don't spawn until unblocked. |

**New categories (added to existing):**

| Category | Signal | Action | Priority |
|----------|--------|--------|----------|
| **P0 Blocker** | `priority:P0`, NOT blocked | 🚨 Process IMMEDIATELY. Hold all other assignments. Report to Lead. | Highest |
| **P0 Blocked** | `priority:P0` + `blocked-by:*` | 🚨 CRITICAL: P0 is blocked. Report to Lead immediately. Investigate blocker. | Highest (alert only) |
| **P1 Sprint Work** | `priority:P1`, NOT blocked | ⚡ Process after P0. Parallel spawns allowed. | High |
| **Untriaged issues** | `squad` label, no `squad:{member}` label | Lead triages: reads issue, assigns `squad:{member}` label + priority | Medium |
| **Assigned but unstarted** | `squad:{member}` label, no assignee or no PR, NOT blocked | Spawn the assigned agent to pick it up | Medium (sorted by priority) |
| **Blocked work** | `blocked-by:*` label | Check blocker status. If resolved, remove label. If not, prepare mode (see §3.3). | Low (prepare only) |
| **Draft PRs** | PR in draft from squad member | Check if agent needs to continue; if stalled, nudge | Low |
| **Review feedback** | PR has `CHANGES_REQUESTED` review | Route feedback to PR author agent to address | Medium |
| **CI failures** | PR checks failing | Notify assigned agent to fix, or create a fix issue | High (blocks merge) |
| **Approved PRs** | PR approved, CI green, ready to merge | Merge and close related issue | Medium |
| **No work found** | All clear | Report: "📋 Board is clear. Ralph is idling." Suggest `npx @bradygaster/squad-cli watch` for persistent polling. | N/A |

**Processing order:** P0 Active > P0 Blocked (alert) > P1 Active > Untriaged > Assigned (by priority) > CI failures > Review feedback > Approved PRs > Blocked work (prepare) > Draft PRs > P3 Active

### Dependency Checking Before Spawning

**New Step 2.5 (Dependency Check):** Before spawning an agent for "Assigned but unstarted" work, Ralph checks for `blocked-by:*` labels.

```javascript
// Pseudocode for Ralph's dependency check
function canSpawnAgent(issue) {
  const blockedLabels = issue.labels.filter(l => l.startsWith('blocked-by:'));
  
  if (blockedLabels.length === 0) {
    return { canSpawn: true, mode: 'normal' };
  }
  
  // Issue is blocked — check if blocker is resolved
  for (const label of blockedLabels) {
    const blockerStatus = checkBlockerStatus(label, issue.body);
    if (blockerStatus.isBlocking) {
      return { 
        canSpawn: true, 
        mode: 'prepare', 
        blocker: blockerStatus.blocker,
        reason: blockerStatus.reason 
      };
    }
  }
  
  // All blockers resolved — remove labels and spawn normally
  removeBlockedByLabels(issue.number);
  return { canSpawn: true, mode: 'normal' };
}
```

**Blocker status check logic:**

| Blocked By | Check | Resolved If |
|------------|-------|-------------|
| `blocked-by:issue` | Read issue body, extract issue number, fetch issue status | Linked issue is closed |
| `blocked-by:pr` | Read issue body, extract PR number, fetch PR status | Linked PR is merged |
| `blocked-by:decision` | Read issue body, check for decision file in `.squad/decisions/` | Decision file moved from `inbox/` to `decisions.md` (approved) |
| `blocked-by:upstream` | Read issue body, extract upstream issue link, fetch status | Upstream issue is closed OR upstream PR is merged |
| `blocked-by:external` | Read issue body, manual check only | Lead manually removes label when condition met |

### What Ralph Does With Blocked Items

| Priority | Blocked Status | Ralph Action |
|----------|----------------|--------------|
| **P0** | Blocked | 🚨 ALERT: Report to Lead immediately. "P0 item #N is blocked by {blocker}. This is a critical bottleneck." Do NOT spawn agent. |
| **P1** | Blocked | Spawn agent in **prepare mode**. Add BLOCKED flag to spawn prompt (see §3.5). |
| **P2** | Blocked | Spawn agent in **prepare mode** only if no active P0/P1 work. Otherwise skip. |
| **P3** | Blocked | Skip. Do NOT spawn. Wait for blocker to resolve. |

**Rationale:**
- **P0 blocked** is a red flag — the highest priority item can't make progress. Lead must intervene.
- **P1 blocked** should still prepare (tests, scaffolding) to stay ready for sprint completion.
- **P2 blocked** can prepare if capacity allows, but it's not urgent.
- **P3 blocked** is low priority — no point preparing until unblocked.

### How Ralph Handles P0 Interrupts

**Scenario:** Ralph is processing P2 work (3 agents spawned). A new P0 issue is created or an existing issue is re-labeled to P0.

**Current behavior:** Ralph doesn't scan GitHub during a work-check cycle. It only scans at the start of each cycle (Step 1).

**New behavior (P0 interrupt handling):**

1. **Ralph checks GitHub at start of each cycle** (no change).
2. **If P0 work is found:**
   - **Complete in-flight work first** (don't kill running agents mid-task).
   - **After in-flight work completes,** report: "🚨 P0 detected: {issue title}. Pausing all other work."
   - **Process P0 work exclusively** until resolved.
   - **Resume normal queue** after P0 is closed or transitioned to P1/P2.

3. **If P0 blocked is found:**
   - **Alert immediately** (don't wait for cycle to complete): "🚨 CRITICAL: P0 item #N is blocked by {blocker}. Lead intervention required."
   - **Continue normal work** (no point stopping everything if the blocker can't be resolved immediately).
   - **Lead must triage:** Either resolve the blocker (spawn agent to fix blocker), downgrade P0 to P1 (if not truly a blocker), or escalate to Founder (if T0 blocker).

**No preemption:** Ralph does NOT kill running agents when P0 appears. Agents complete their current task, then Ralph switches to P0. This avoids wasted work and half-finished PRs.

**Exception:** If user explicitly says "stop everything, P0 only", Ralph may mark in-flight work as Draft PRs and switch immediately.

### Changes to Ralph's Board Format

**Current board format (from squad.agent.md):**

```
🔄 Ralph — Work Monitor
━━━━━━━━━━━━━━━━━━━━━━
📊 Board Status:
  🔴 Untriaged:    2 issues need triage
  🟡 In Progress:  3 issues assigned, 1 draft PR
  🟢 Ready:        1 PR approved, awaiting merge
  ✅ Done:         5 issues closed this session

Next action: Triaging #42 — "Fix auth endpoint timeout"
```

**New board format (priority-aware):**

```
🔄 Ralph — Work Monitor
━━━━━━━━━━━━━━━━━━━━━━
📊 Board Status (Priority Breakdown):

  🚨 P0 BLOCKERS:     1 active, 0 blocked
     #189 — Priority system design (T1, Solo) — IN PROGRESS

  ⚡ P1 SPRINT:       3 active, 1 blocked
     #190 — Ralph implementation (blocked by #189) — PREPARING
     #191 — Label automation — READY TO START
     #192 — Governance update — READY TO START

  📋 P2 BACKLOG:      5 active, 2 blocked
     #154 — Modularize game.js — IN PROGRESS
     #155 — Mobile controls — ASSIGNED
     #156 — High score leaderboard — BLOCKED by #189

  💡 P3 NICE-TO-HAVE: 2 active, 1 blocked

  🔴 Untriaged:      2 issues need triage
  🟢 Ready to Merge: 1 PR approved (CI green)
  ✅ Done:           5 issues closed this session

Next action: Processing P0 #189 — Solo spawned
```

**Key additions:**
1. **Priority breakdown section** (P0 > P1 > P2 > P3)
2. **Blocked count per priority** (quick visibility into bottlenecks)
3. **Status indicators** (IN PROGRESS, PREPARING, READY TO START, BLOCKED by #N)
4. **Next action clarifies priority** ("Processing P0..." vs "Triaging...")

**Condensed format (when board is large):**

```
🔄 Ralph — Work Monitor
━━━━━━━━━━━━━━━━━━━━━━
📊 Board: 1 P0 | 4 P1 (1 blocked) | 7 P2 (2 blocked) | 3 P3 | 2 untriaged | 1 ready to merge

Next: 🚨 P0 #189 — Priority system design (Solo)
```

---

## 4. Lead Triage Changes

Lead triage currently evaluates (from routing.md):

1. Is this well-defined?
2. Does it follow existing patterns?
3. Does it need design judgment?
4. Is it security-sensitive?
5. Is it medium complexity with specs?

Then assigns `squad:{member}` label and posts triage notes.

### New Triage Checklist (7 Points)

**Extended checklist:**

1. **Is this well-defined?** (no change)
2. **Does it follow existing patterns?** (no change)
3. **Does it need design judgment?** (no change)
4. **Is it security-sensitive?** (no change)
5. **Is it medium complexity with specs?** (no change)
6. **🆕 What is the priority?** (P0/P1/P2/P3) — When must this complete? What does it block?
7. **🆕 What are the dependencies?** (blocked-by) — What must finish before this can merge?

### When and How to Assign Priority Labels

**Decision tree for priority assignment:**

| Question | If Yes → | If No → |
|----------|----------|---------|
| Does this block production or prevent all progress? | P0 | Continue |
| Is this a sprint commitment or critical for current milestone? | P1 | Continue |
| Is this low-impact polish or future work? | P3 | P2 (default) |

**Examples:**

| Issue | Priority | Reasoning |
|-------|----------|-----------|
| "Game crashes on level 3" | P0 if in production, P1 if in dev | Production = blocker. Dev = sprint-critical. |
| "Implement ghost AI (GDD M1 feature)" | P1 | Sprint commitment in GDD. |
| "Refactor game.js monolith" | P2 | Important but not urgent. |
| "Add dark mode" | P3 | Nice-to-have polish. |
| "Typo in README" | P3 | Cosmetic. |

**Guideline:** When in doubt, default to P2. Over-prioritizing (everything is P0) defeats the purpose. Under-prioritizing (everything is P3) creates false urgency. P2 is the working default.

### When and How to Identify Dependencies

**Decision tree for dependency identification:**

| Question | If Yes → | Action |
|----------|----------|--------|
| Does this require a design decision (T0 or T1)? | Yes | Add `blocked-by:decision-{tier}` label. Document which decision in body. |
| Does this build on another open issue? | Yes | Add `blocked-by:issue` label. Link to prerequisite issue in body. |
| Does this require a PR to merge first? | Yes | Add `blocked-by:pr` label. Link to PR in body. |
| Does this depend on hub/upstream work? | Yes | Add `blocked-by:upstream` label. Link to hub issue in body. |
| Does this depend on third-party (Squad CLI, external library)? | Yes | Add `blocked-by:external` label. Describe in body. |

**How to document dependencies in issue body:**

During triage, the Lead adds a `## Dependencies` section to the issue body:

```markdown
## Dependencies

**Blocked by:**
- #189 (Priority system design — T1 decision by Solo)
- Decision: governance.md §2 update must be approved before Ralph implementation

**Blocks:**
- #190 (Ralph implementation)
- #191 (Label automation)

**Prepare mode allowed:** Yes
  ✅ Write tests for priority queue behavior
  ✅ Scaffold ralph-priority-queue.ts with function stubs
  ✅ Update squad.agent.md with placeholder sections
  ❌ Do NOT implement full priority logic (design may change)
  ❌ Do NOT merge PR until #189 approved
```

**Triage template (updated):**

```markdown
## Triage Notes

**Squad member:** {member}
**Complexity:** {low/medium/high}
**Priority:** P{0-3} — {reasoning}
**Dependencies:** {none | blocked-by:* labels}
**@copilot suitability:** 🟢 good fit / 🟡 needs review / 🔴 not suitable
**Estimated effort:** {small/medium/large}

{additional context}
```

### Default Priority If None Assigned

**Rule:** If an issue has no `priority:*` label after triage, Ralph treats it as **P2 (Normal Backlog)**.

**Rationale:** P2 is the working default. Most issues are normal backlog work. P0/P1 are exceptions that must be explicitly flagged. P3 is explicitly deprioritized.

**Exception:** Untriaged issues (no `squad:{member}` label yet) have no priority until the Lead triages them. They appear in Ralph's "Untriaged" category, which is processed after P0/P1 but before P2.

---

## 5. Label System

### Exact Label Names and Colors

**Priority labels:**

| Label | Color | Description |
|-------|-------|-------------|
| `priority:P0` | `#d73a4a` (red) | Blocker — nothing advances without this |
| `priority:P1` | `#ff9800` (orange) | Sprint-critical — affects current sprint |
| `priority:P2` | `#0366d6` (blue) | Normal backlog |
| `priority:P3` | `#6c757d` (gray) | Nice-to-have |

**Dependency labels:**

| Label | Color | Description |
|-------|-------|-------------|
| `blocked-by:issue` | `#b60205` (dark red) | Blocked by another issue (see body) |
| `blocked-by:pr` | `#b60205` (dark red) | Blocked by a PR merge (see body) |
| `blocked-by:decision` | `#b60205` (dark red) | Blocked by a pending decision (see body) |
| `blocked-by:upstream` | `#b60205` (dark red) | Blocked by hub/parent repo work (see body) |
| `blocked-by:external` | `#b60205` (dark red) | Blocked by third-party (see body) |

**Rationale for dark red:** `blocked-by:*` labels are alarm signals. They indicate stalled work. Dark red makes them visually distinct from `priority:P0` (bright red = urgent, dark red = blocked).

### Hub-Level vs Project-Level Labels (Zone B Consideration)

**Zone B rule (from governance.md §3):** Hub sets defaults, projects may extend but not weaken.

| Label Type | Hub-Level (Zone A) | Project-Level (Zone B) |
|------------|---------------------|------------------------|
| **Priority (P0-P3)** | Required. All repos inherit. | Strict P0-P3 only. No extensions, no suffixes. Projects inherit hub priority labels exactly as defined. |
| **Dependency (blocked-by:*)** | Required. All repos inherit. | May add project-specific blockers (blocked-by:design-doc, blocked-by:asset) if needed. |
| **Squad (squad, squad:{member})** | Required. All repos inherit. | May add project-specific squad labels (squad:artist, squad:sound-designer) for local agents. |

**Enforcement:**
1. **Hub labels are authoritative.** If a project removes or renames `priority:P0`, sync must fail (CI check).
2. **Project labels are extensions.** Projects may add `priority:P1-hotfix` (maps to P1) or `blocked-by:asset` (project-specific blocker).
3. **Sync workflow validates.** `.github/workflows/sync-squad-labels.yml` checks that all hub labels exist in project repos. Does NOT remove project-specific labels.

**RESOLVED (Founder decision):** Strict P0-P3 only. No extensions allowed. No `priority:P1-content` or similar suffixes. Zone B projects inherit hub priority labels exactly. This prevents priority inflation and ensures consistent semantics across all repos.

### Label Automation Changes (sync-squad-labels.yml)

**Current workflow:** `.github/workflows/sync-squad-labels.yml` reads `squad.labels.json` (if it exists) and syncs labels to the repo.

**Changes needed:**

1. **Add priority and dependency labels to `squad.labels.json`** in FFS hub repo.

```json
{
  "labels": [
    {
      "name": "priority:P0",
      "color": "d73a4a",
      "description": "Blocker — nothing advances without this"
    },
    {
      "name": "priority:P1",
      "color": "ff9800",
      "description": "Sprint-critical — affects current sprint"
    },
    {
      "name": "priority:P2",
      "color": "0366d6",
      "description": "Normal backlog"
    },
    {
      "name": "priority:P3",
      "color": "6c757d",
      "description": "Nice-to-have"
    },
    {
      "name": "blocked-by:issue",
      "color": "b60205",
      "description": "Blocked by another issue (see body)"
    },
    {
      "name": "blocked-by:pr",
      "color": "b60205",
      "description": "Blocked by a PR merge (see body)"
    },
    {
      "name": "blocked-by:decision",
      "color": "b60205",
      "description": "Blocked by a pending decision (see body)"
    },
    {
      "name": "blocked-by:upstream",
      "color": "b60205",
      "description": "Blocked by hub/parent repo work (see body)"
    },
    {
      "name": "blocked-by:external",
      "color": "b60205",
      "description": "Blocked by third-party (see body)"
    }
  ]
}
```

2. **Update `sync-squad-labels.yml` to validate priority/dependency labels** in project repos.

Add a validation step:

```yaml
- name: Validate Priority and Dependency Labels
  run: |
    # Check that all hub-required labels exist in project repo
    for label in "priority:P0" "priority:P1" "priority:P2" "priority:P3" \
                 "blocked-by:issue" "blocked-by:pr" "blocked-by:decision" \
                 "blocked-by:upstream" "blocked-by:external"; do
      if ! gh label list --json name --jq '.[] | .name' | grep -q "^$label$"; then
        echo "ERROR: Required label '$label' missing from project repo"
        exit 1
      fi
    done
```

3. **Sync workflow runs on schedule** (existing behavior: daily cron or on `squad.labels.json` changes).

**No changes to manual labeling:** Developers and agents can still manually add/remove labels via GitHub UI or `gh` CLI. The sync workflow only enforces that hub-required labels exist.

---

## 6. Governance Updates

### Exact Text Changes Needed

**Location:** governance.md §2 (Approval Tiers)

**Addition:** New subsection after §2 "Approval Tiers", before §3 "Autonomy Zones".

---

**PROPOSED TEXT FOR GOVERNANCE.MD:**

---

## 2.5. Execution Priority

Approval Tiers (§2) determine **who decides**. Execution Priority determines **when work runs**. These are independent axes.

### Priority Levels

| Priority | Name | Definition | Execution Rule |
|----------|------|------------|----------------|
| **P0** | Blocker | Nothing else advances until this is resolved. System-wide halt. | Ralph processes FIRST. Holds all other assignments until P0 is resolved or transitioned. |
| **P1** | Sprint-Critical | Must complete in current sprint. Directly blocks sprint goals. | Ralph processes after P0, before P2. Parallel execution allowed. |
| **P2** | Normal Backlog | Standard work queue. Important but not time-sensitive. | Ralph processes in FIFO order. **Default priority if none assigned.** |
| **P3** | Nice-to-Have | Low-impact improvements. Process when capacity available. | Ralph processes last. May be deferred indefinitely. |

### Tier ≠ Priority

| Example | Tier | Priority | Explanation |
|---------|------|----------|-------------|
| Create new game repo | T0 | P2 | Founder approval required (T0), but scheduled for Q2 (P2). High authority, low urgency. |
| Production bug in game | T2 | P0 | Agent has authority (T2), but it's a blocker (P0). Low authority, high urgency. |
| Governance v2 design | T1 | P0 | Solo decides (T1), but 3 agents are blocked waiting (P0). Medium authority, high urgency. |

### Priority Assignment

The **Lead** (Solo) assigns priority during triage. Default: P2 if none assigned.

**Decision tree:**

1. Does this block production or prevent all progress? → **P0**
2. Is this a sprint commitment or critical for current milestone? → **P1**
3. Is this low-impact polish or future work? → **P3**
4. Otherwise → **P2** (default)

### Dependencies and Blocked Work

Issues may be blocked by decisions, other issues, PRs, or upstream work. Blocked issues are labeled with `blocked-by:*` (see routing.md for dependency model).

**Prepare-but-don't-merge rule:** When an issue is blocked, the assigned agent may:

✅ **Allowed (Prepare):**
- Write tests (TDD approach)
- Scaffold code structure (empty functions, interfaces)
- Write spike code to explore problem space
- Open Draft PR with `[WIP]` prefix

❌ **Forbidden (until blocker resolved):**
- Mark PR as Ready for review
- Merge to main
- Close the issue

**Rationale:** Agents can make progress on blocked work (tests, scaffolding) without wasting effort if the blocker decision changes direction.

### Priority and Emergency Authority

Emergency Authority (§4) overrides Priority. A production outage triggers Emergency Authority (immediate fix, retroactive review), not P0 (which would wait for next Ralph cycle). After emergency fix merges, follow-up work is automatically labeled P1 (sprint-critical). Lead may escalate to P0 if truly blocking.

**Rule:** Emergency Authority is for active production crises requiring immediate action. P0 is for blocking work that prevents the team from making progress. They rarely overlap.

---

**END OF PROPOSED TEXT**

---

### Where Priority Fits in the Tier Decision Matrix

**No changes to Tier Decision Matrix (governance.md §2).** Tiers remain unchanged. Priority is orthogonal.

**New section in routing.md:** Lead triage checklist extended to include priority and dependency evaluation (see §4 above).

### Any New Guardrails Needed

**Proposed new guardrails:**

| Guardrail | Rule |
|-----------|------|
| **G13** | Priority inflation guardrail (advisory). Ralph warns when >20% of open issues are labeled P0 or P1. Lead decides whether to re-triage. No CI enforcement. |
| **G14** | Blocked issues must have a `## Dependencies` section in the issue body documenting the blocker and what "prepare mode" work is allowed. |
| **G15** | P0 items blocked for >3 days trigger escalation. Lead must intervene: resolve blocker, downgrade priority, or escalate to Founder. |

**Rationale:**

- **G13:** Prevents "everything is urgent" syndrome. If 20%+ of the backlog is P0/P1, priorities have lost meaning. Lead must re-calibrate.
- **G14:** Ensures blocked work is actionable. Agents need to know what they can do while blocked.
- **G15:** P0 should resolve quickly (by definition, it's blocking everything). If a P0 is blocked for 3+ days, something is wrong (bad priority assignment, unresolved blocker, or legitimate escalation).

---

## 7. Edge Cases & Risks

### Circular Dependencies

**Problem:** Issue #A depends on #B, #B depends on #C, #C depends on #A. Nobody can start.

**Detection:**
1. **Manual:** Lead notices during triage ("This issue is blocked by #B, but #B is blocked by this issue").
2. **Automated (future):** GitHub Action or Ralph enhancement that builds a dependency graph and detects cycles.

**Resolution:**
1. **Break the cycle:** One issue is designated as the "entry point" — remove its `blocked-by:*` label and start there.
2. **Escalate to Lead:** If cycle is legitimate (architectural deadlock), Solo must redesign the work breakdown.
3. **Immediate action:** If P0 is involved in a cycle, this is a CRITICAL failure. Lead must resolve within 24 hours or escalate to Founder.

**Example:**
- #189 (priority system design) depends on #190 (Ralph implementation) for testing
- #190 depends on #189 for design spec
- **Resolution:** Remove #190's dependency on #189. Ralph implementation can scaffold tests without full design. Design adjusts based on implementation feedback.

### Cross-Repo Dependencies (ComeRosquillas Blocked by FFS Decision)

**Problem:** Game repo (ComeRosquillas) has an issue blocked by a hub decision (FFS #189). How is this tracked?

**Current model:** `blocked-by:upstream` label + comment linking to hub issue.

**Process:**

1. **Game repo issue #25:** "Implement priority-aware work queue in ComeRosquillas"
   - Label: `blocked-by:upstream`
   - Body: "Blocked by FFS hub #189 (priority system design). Cannot implement until hub governance defines priority semantics."

2. **Hub issue #189:** "Design priority system"
   - Body: "Blocks downstream: ComeRosquillas #25"

3. **Ralph in ComeRosquillas:** Sees `blocked-by:upstream`, checks comment, realizes blocker is in FFS hub. Reports: "Blocked by upstream hub #189."

4. **Ralph in FFS hub:** Processes #189 (P0). When closed, no automatic unlabeling of downstream ComeRosquillas #25.

5. **Manual unblock:** Lead (or ComeRosquillas agent) removes `blocked-by:upstream` label from ComeRosquillas #25 after confirming FFS #189 is resolved.

**Risk:** Stale `blocked-by:upstream` labels (FFS #189 closes, but ComeRosquillas #25 still says blocked).

**Mitigation:**
1. **Ralph checks blocker status:** When Ralph scans ComeRosquillas and finds `blocked-by:upstream`, it parses the comment, extracts the hub issue link, and checks if it's closed. If closed >24 hours ago, Ralph flags: "⚠️ Stale blocker: Upstream FFS #189 closed >24 hours ago, but #25 still blocked."
2. **Weekly grooming:** Lead reviews all `blocked-by:*` labels weekly (manual ceremony). Remove stale labels.
3. **GitHub Action (future):** Automated cron job that checks `blocked-by:issue` and `blocked-by:upstream` labels, flags stale blocks as comments on the issue.

### P0 Declared by Wrong Agent (Who Can Set P0?)

**Problem:** An agent labels their own issue as P0 to get it prioritized. Priority inflation.

**Governance rule:**

| Role | Can Assign P0? | Can Assign P1? | Can Assign P2/P3? |
|------|----------------|----------------|-------------------|
| **Lead (Solo)** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Producer (Mace)** | ⚠️ With Lead approval | ✅ Yes (sprint scope) | ✅ Yes |
| **Assigned agent** | ❌ No — escalate to Lead | ❌ No — escalate to Lead | ✅ Yes (self-prioritize within backlog) |
| **Founder (Joaquín)** | ✅ Yes (emergency override) | ✅ Yes | ✅ Yes |

**Rationale:**
- **P0 is system-wide.** Only Lead (Solo) or Founder can declare a blocker that halts all other work.
- **P1 is sprint-scoped.** Producer (Mace) owns sprint scope, so can assign P1 (with Lead alignment on cross-project impact).
- **P2/P3 are self-service.** Agents can prioritize their own backlog items as P2 (normal) or P3 (low).

**Enforcement:**
1. **GitHub Action (future):** CI check that fails PRs adding `priority:P0` label without Lead approval.
2. **Ralph validation:** When Ralph scans and finds P0, it checks who labeled it (GitHub API audit log). If not Lead/Founder, Ralph flags: "⚠️ Unauthorized P0: #N labeled by {agent}, not Lead. Awaiting triage."
3. **Retroactive correction:** Lead reviews P0 labels weekly. Demote false P0s to P1/P2.

**Exception:** Emergency Authority (governance §4) allows any agent to fix production outages immediately. After the fix, follow-up work is automatically labeled P1 (sprint-critical). Lead may escalate to P0 if truly blocking, or downgrade to P2 if minor.

### Priority Inflation ("Everything is P0")

**Problem:** Over time, more and more issues get labeled P0 or P1, defeating the purpose of prioritization.

**Guardrail G13:** If >20% of open issues are labeled P0 or P1, the Lead must re-triage and demote non-critical items.

**Monitoring:**
1. **Ralph weekly report:** "📊 Priority distribution: 12 P0 (15%), 30 P1 (38%), 40 P2 (50%), 5 P3 (6%). ⚠️ P1 exceeds threshold — re-triage recommended."
2. **Lead reviews:** Solo scans P0/P1 labels weekly during grooming. Demote items that aren't truly blocking/sprint-critical.
3. **GitHub Action (future):** Weekly cron job that calculates priority distribution, opens issue if thresholds exceeded.

**Threshold tuning:** 20% is a starting point. Adjust based on team size and sprint length. Small teams may tolerate 30% P0/P1 (short sprints, high urgency). Large teams should aim for <10% P0/P1 (long sprints, more parallelism).

### Stale Blocked-By Labels (Dependency Resolved But Label Not Removed)

**Problem:** Issue #190 is blocked by #189. #189 closes. Nobody removes `blocked-by:issue` label from #190. Ralph keeps treating it as blocked.

**Detection:**

1. **Ralph scans blocked issues:** For each `blocked-by:*` label, Ralph checks if the blocker is resolved (see §3.3 Dependency Check).
2. **Stale block threshold:** If blocker closed >24 hours ago and label still exists, Ralph flags: "⚠️ Stale blocker: #190 blocked by #189, but #189 closed >24 hours ago. Recommend unblocking."
3. **Weekly grooming:** Lead reviews all `blocked-by:*` labels. Remove stale labels manually.

**Auto-removal (active — Founder approved):**

GitHub Action that runs daily:

```yaml
name: Clean Stale Blockers

on:
  schedule:
    - cron: "0 12 * * *"  # Daily at noon UTC

jobs:
  clean-stale-blockers:
    runs-on: ubuntu-latest
    steps:
      - name: Find stale blocked-by labels
        run: |
          # For each issue with blocked-by:issue label
          # Parse issue body, extract blocker issue number
          # Check if blocker is closed
          # If closed >24 hours ago, remove label and comment:
          # "🤖 Auto-unblocked: Blocker #N closed 24+ hours ago."
```

**Manual override:** If Lead intentionally keeps `blocked-by:*` label after blocker closes (e.g., waiting for deployment, not just merge), add comment: "HOLD: Do not auto-remove. Waiting for production deployment of #N."

---

## Summary of Changes Required

### Documentation Updates (T1 decisions by Solo)

| File | Change | Tier |
|------|--------|------|
| `governance.md` | Add §2.5 "Execution Priority" (full text in §6 above) | T1 |
| `governance.md` | Add guardrails G13, G14, G15 | T1 |
| `routing.md` | Update Lead triage checklist (add priority + dependency steps) | T1 |
| `.github/agents/squad.agent.md` | Update Ralph reference (priority-aware scan logic, dependency checking, board format) | T1 |
| `.squad/templates/ralph-reference.md` | Full rewrite to reflect priority system (if this file exists) | T1 |
| `.squad/templates/triage-template.md` | Add priority and dependency fields | T1 |

### Label System (T1 decisions by Solo)

| Action | Details | Tier |
|--------|---------|------|
| Create `squad.labels.json` | Add 9 labels (4 priority + 5 blocked-by) with colors and descriptions | T1 |
| Update `sync-squad-labels.yml` | Add validation step for required labels | T1 |
| Run label sync | Apply labels to FFS hub and all downstream repos | T1 |

### Ralph Implementation (T2 work, blocked by this design)

| Issue | Work | Tier | Blocked By |
|-------|------|------|------------|
| #190 | Implement priority-aware scan logic in Ralph | T2 | This design (#189) |
| #190 | Implement dependency checking before spawning | T2 | This design (#189) |
| #190 | Update Ralph board format | T2 | This design (#189) |
| #191 | Create `squad.labels.json` and sync labels | T2 | This design (#189) |

**All T2 work may PREPARE (tests, scaffolding) but NOT MERGE until this design is approved (T1 decision).**

---

## Resolved Questions (Founder Decisions)

All design questions have been resolved by Founder review:

1. **Priority label extensions** — **RESOLVED: Strict P0-P3 only.** No extensions allowed. Zone B projects inherit hub priority labels exactly as defined.

2. **Emergency follow-up priority** — **RESOLVED: Follow-up inherits P1 automatically.** Lead may escalate to P0 if truly blocking, or downgrade to P2 if minor.

3. **G13 priority inflation guardrail** — **RESOLVED: Advisory only.** Ralph warns when >20% P0/P1. Lead decides whether to re-triage. No CI enforcement.

4. **Stale blocked-by label removal** — **RESOLVED: Ralph auto-unblocks after 24h.** When a blocker closes, Ralph auto-removes `blocked-by:*` label after 24 hours and comments "🤖 Auto-unblocked: #{blocker} closed". Lead can re-block if needed.

5. **P0 interrupt behavior** — **RESOLVED: Complete current cycle, then P0 exclusive.** Running agents finish their current task. No preemption, no agent killing mid-task.

---

## Approval and Next Steps

**This is a T1 design decision.** Solo (Lead) has full authority to approve and implement. Founder has resolved all open questions.

**Next steps:**

1. **Solo approves** (T1 authority) and moves this document from `inbox/` to active `decisions.md`.
2. **Ralph + Label implementation spawned** (#190, #191) as T2 work.

**Success criteria:**
- Ralph processes P0 items first (verified via board status reports)
- Blocked issues don't spawn agents prematurely (verified via Ralph logs)
- Priority distribution stays healthy (<20% P0/P1) after 2 sprints
- Zero stale blockers after 1 month (24h auto-unblock effective)

---

**Document Status:** Final — Founder decisions incorporated, ready for T1 approval  
**Next Action:** Solo approves (T1) and moves to active decisions  
**Approval Authority:** T1 (Solo decides — Founder input received and incorporated)

