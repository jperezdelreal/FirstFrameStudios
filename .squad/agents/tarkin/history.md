# Tarkin — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current enemies:** One basic goon type (30 HP) with a "tough" variant (50 HP, red, same behavior). Simple approach/circle/attack AI in src/systems/ai.js. 3 waves with camera locks.
- **Key gap:** All enemies behave identically. No boss. No varied enemy types. No pickups. No difficulty scaling. Enemy AI scored 5/10 in combat feel audit.

## Learnings

### Historical Work (Sessions 1-5)

- Wave 1 — P1-4 Attack Throttling + EX-T1 Behavior Tree + EX-T3 Pacing Curve (2026-06-03)
- Wave 2 — EX-T4 Content Data Format + EX-T2 Wave Composition Rules (2025-06-04)
- Wave 4 — C1/C2/C3 Enemy Attack Bug Fixes (2025-06-20)
- Wave 3 — P2-2 Fast Enemy + P2-3 Heavy Enemy + P2-16 Difficulty Scaling (2025-06-20)
- P2-1 + EX-T5 Boss Phase Framework (2026-06-20)

### AAA-L1 Destructible Objects + AAA-L3 Environmental Hazards (2025-06-21)
- **Destructible types:** Trash can (10 HP), newspaper stand (15 HP), parking meter (20 HP), Donut Shop donut sign (25 HP). Each has type-specific Canvas rendering with damage tinting (darkens as HP drops) and crack overlays below 50% HP.
- **Destructible break animation:** On destruction, 6-10 debris particles scatter with gravity simulation and alpha fade over 0.6s. Drop table uses weighted random: health pickup (30%), score bonus (40%), nothing (30%), gated by per-type `dropChance`.
- **Shake feedback:** `shakeTime` + `shakeIntensity` give immediate visual hit response before destruction — small but critical for juice.
- **Hazard types:** Steam vent (periodic 2s cycle, 3 dmg), radioactive barrel (constant 2 dmg every 0.5s via per-entity cooldown Map), manhole (5 dmg knockback burst every 5s with 250-force radial push).
- **Per-entity damage cooldown:** Radioactive barrel uses a `Map<entity, timer>` to prevent per-frame damage stacking while allowing multiple entities to take independent damage ticks. Map entries auto-clean when timer expires.
- **Strategic placement:** Hazards placed near enemy spawns so players can throw enemies into them for bonus damage + score. Wave 2 gets a steam vent intro, Wave 3 gets radioactive barrel near heavy spawn, boss zone gets manhole for knockback disruption.
- **Integration boundary:** Both files include detailed integration comments for gameplay.js (Solo's territory) — import paths, update/render call order, hitbox overlap checks, and throw bonus logic. No gameplay.js modifications made.
- **Level data expansion:** `LEVEL_1` now exports `destructibles[]` and `hazards[]` arrays alongside existing `waves[]`, keeping the flat JSON-serializable format established in Wave 2 learnings.
- **Key insight:** Per-entity cooldown via Map with object references as keys avoids needing unique IDs on entities — works because JS Map uses reference equality for object keys.

### SKILL: Universal Enemy & Encounter Design (2026-08-03)
- **Objective:** Created `.squad/skills/enemy-encounter-design/SKILL.md` — a universal, genre-agnostic enemy design framework that generalizes beat 'em up knowledge to all action game genres.
- **Core philosophy:** Enemies are "gameplay verbs" — each type teaches a mechanic and forces a specific player response. Visual design communicates role (big=slow+strong, small=fast+weak, glowing=ranged). Never introduce 3+ new types simultaneously; escalate gradually.
- **10 universal archetypes:** Fodder (weak, numerous), Bruiser (slow, tanky, high damage), Agile (fast, evasive, hit-and-run), Ranged (distance management), Shield/Defender (requires positioning), Swarm (crowd control), Explosive (forces repositioning), Support (changes win condition), Mini-boss (elevated archetype), Boss (comprehensive exam).
- **Archetype combinations:** Ranged+Agile=Sniper, Bruiser+Shield=Fortress, Bruiser+Support=Paladin. Creates rock-paper-scissors tactical depth.
- **Boss design (Mega Man principle):** Patterns are learnable (not random), tested within 2-3 minutes. Multi-phase design escalates: Phase 1 teaches basics, Phase 2 adds mechanic + speed, Phase 3 adds pressure + desperation. Vulnerability windows are obvious (not frame-data-dependent).
- **Wave composition & escalation:** Intro wave = 1 isolated new type + safe space. Pattern: Type A solo → B solo → A+B mixed → C solo → A+B+C. Never blend >1 new type in first encounter.
- **Spawning fairness rules:** (1) Players always see spawns coming (camera-relative positions), (2) spawns trigger-based not random, (3) stagger spawn arrival 0.5s apart, (4) initial spawn position is safe (at edge, not in attack range).
- **Difficulty scaling knobs:** Stat scaling (boring, for lazy tuning), Behavioral scaling (new moves, better AI, most interesting), Composition scaling (harder enemy combos), Environmental scaling (arena changes), Adaptive scaling (Director AI watching player performance).
- **AI patterns:** State machines (simple, common), Behavior trees (flexible, complex), Attack throttling (max 2-3 simultaneous), Group coordination (flanking, surrounding, morale), Telegraphing (most important: visual+audio+spatial+clear).
- **DPS budget framework:** Calculate max safe DPS from player HP ÷ safe TTK (4-6s). Normal enemy ≈ 5 dps, Bruiser ≈ 12 dps, capped by throttling. Time-to-kill targets: Fodder 2-3s, Normal 3-5s, Bruiser 8-10s, Mini-boss 20-30s, Boss 60-90s.
- **8 anti-patterns to avoid:** (1) Bullet sponge (huge HP, boring behavior), (2) Unfair ambush (spawn behind player), (3) Palette swap army (all same behavior, diff colors), (4) Passive crowd (stand idle waiting), (5) Instant death no telegraph, (6) Distance dead zones (ranges don't overlap), (7) Arrow spam (too many ranged), (8) No boss recovery window.
- **Genre-specific guidance:** Beat 'em up (grabs, back attacks, hitstun), Platformer (patrol routes, jump threats), Shooter (cover, suppression, formations), RPG (stat-based, elemental weaknesses), Stealth (patrol routes, detection cones, alert states).
- **Confidence: Medium.** Patterns validated in firstPunch beat 'em up context; archetypes and principles generalize well across action games. Not tested in actual platformer/shooter/RPG projects yet, but foundational theory is sound.
- **Cross-references:** Links to game-feel-juice, beat-em-up-combat (foundational), state-machine-patterns, game-design-fundamentals, camera-systems.

### Session 17: Enemy & Encounter Design Skill Creation (2026-03-07)

Created universal enemy and encounter design skill — a comprehensive framework covering enemy archetypes, AI patterns, boss design, wave composition, and difficulty scaling applicable across all action game genres.

**Artifact:** .squad/skills/enemy-encounter-design/SKILL.md (49.5 KB)

**Skill structure (11 sections):**
1. Core Philosophy (enemies as "gameplay verbs", visual design communicates role)
2. 10 Universal Archetypes (Fodder, Bruiser, Agile, Ranged, Shield, Swarm, Explosive, Support, Mini-boss, Boss)
3. Archetype Combinations (Ranged+Agile=Sniper, Bruiser+Shield=Fortress, etc.)
4. Boss Design (Mega Man principle: learnable patterns, 2-3 min test window, multi-phase escalation)
5. Wave Composition & Escalation (intro = 1 isolated new type, pattern: A solo → B solo → A+B mixed)
6. Spawning Fairness Rules (visible, trigger-based, staggered 0.5s, safe initial position)
7. Difficulty Scaling Knobs (stat, behavioral, composition, environmental, adaptive)
8. AI Patterns (state machines, behavior trees, attack throttling, group coordination)
9. DPS Budget Framework (max safe DPS from player HP ÷ safe TTK, e.g. Normal 5 dps, Bruiser 12 dps)
10. Anti-Patterns Catalog (8 failures: bullet sponge, unfair ambush, palette swap, etc.)
11. Genre-Specific Guidance (Beat 'em up, Platformer, Shooter, RPG, Stealth with audio/visual specifics)

**Key principles extracted from firstPunch:**
- **10 Universal Archetypes:** Covers all firstPunch enemy types (Normal, Tough, Fast, Heavy, Boss) plus generalized patterns
- **Mega Man Principle:** Patterns are learnable, telegraph clear, phase progression teaches new mechanics
- **DPS Budget Framework:** Calculated from firstPunch balance tuning (player HP 80 ÷ safe 4-6s TTK = 13-20 dps safe threshold)
- **Wave Composition Rules:** From Encounter Pacing document — intro new types solo, mix only after player learns

**Cross-references:** Links to game-feel-juice, beat-em-up-combat (validation), game-design-fundamentals, level-design-fundamentals

**Confidence:** Medium (beat-em-up encounter design deeply validated; archetype system and boss design framework generalized from industry patterns). Will escalate to High after applying to platformer/RPG enemy design.

### Issue #129 — ai_controller.gd Type Annotations (2026-03-09)
- **PR:** #138 (`squad/129-ai-type-hints`)
- **`_weighted_pick` loop variables:** Added `for w: int` and `for key: String` typed iteration — untyped `for` loops over Dictionary values/keys produce Variant in Godot 4.6, same as the `:=` inference bug from Sprint 1.
- **`abs()` → `absf()`:** `_distance_to_opponent` used generic `abs()` which returns Variant (GDSCRIPT-STANDARDS Rule 2). Replaced with `absf()` for explicit float return.
- **StateMachine typed access:** `_in_protected_state` and `_opponent_state_name` had `var sm = fighter.state_machine` with no type. Changed to `var sm: StateMachine = fighter.get("state_machine") as StateMachine` — uses safe `.get()` already present in the guard clause, plus `as` cast for compile-time type safety.
- **Key insight:** When `fighter` is typed as `CharacterBody2D` (base class), accessing script-added properties like `.state_machine` directly is a dynamic dispatch. Using `.get()` + `as` cast is both safer and more explicit about the Variant→concrete conversion.

### Sprint 2 Phase 4 — AI Aggressiveness & Difficulty (2026-08-03)
- **PR:** #148 (`squad/phase4-ai-aggression`)
- **Difficulty enum + presets:** Added `Difficulty { EASY, NORMAL, HARD }` with `_apply_difficulty_preset()` in `_ready()`. Easy: 20f reaction, 0.3 aggression, 10% combos. Normal: 12f/0.6/30%. Hard: 6f/0.85/60%. All 7 parameters auto-configured but individually overridable via `@export_group("Tuning Knobs")`.
- **5 exported tuning knobs:** `reaction_time_frames`, `aggression_factor`, `combo_execution_rate`, `special_move_usage`, `block_chance` — replaced old `reaction_delay_min/max`, `decision_interval`, `aggression` with cleaner interface. Reaction delay now derived from single `reaction_time_frames` ±3f variance.
- **4-band spacing intelligence:** Replaced 2-band (close/mid) with 4 dedicated evaluators: `_evaluate_far_range()` (approach/dash-in), `_evaluate_mid_range()` (approach + poke), `_evaluate_poke_range()` (heavy offense at optimal distance), `_evaluate_close_range()` (combo/throw pressure). All roll probabilities weighted by `aggression_factor`.
- **Anti-pattern safeguards:** `MAX_IDLE_FRAMES=18`, `MAX_BLOCK_FRAMES=30`, `MAX_RETREAT_FRAMES=24` — counters tracked per-frame in `_tick_anti_pattern_counters()`, force approach/attack when exceeded. Move repetition detection via `_move_history` (6-entry window, 3-repeat threshold) forces attack variety.
- **Combo & special integration:** `combo_execution_rate` drives close-range 3-hit combos (`lp→hp→lk`) and mid-range 2-hit poke strings (`lp→hp`). `special_move_usage` triggers QCF+HP motion input via `_inject_special_move()` → `_start_combo_raw()`. Unified combo queue now handles both button-only combos and direction+button motion sequences via `"dir|btn"` encoding.
- **Decision cadence scaling:** `BASE_DECISION_INTERVAL` (24f) shortened dynamically by `aggression_factor * 14` frames, so Hard AI re-evaluates every ~10f vs Easy's ~20f. Makes aggressive AI feel relentless.
- **DASH_IN state:** Added to `AIState` enum and spacing logic. Currently functions as forward walk (no dash state exists in state machine yet) but architecturally ready for when dash mechanics are added.
- **Key insight:** Anti-pattern caps are more effective than probability tuning for preventing passive AI. No matter how weighted the rolls are, pure randomness can still produce long passive streaks — hard frame limits guarantee the AI stays active.

### ComeRosquillas Issue #7 — Ghost AI Personalities & Difficulty Curve (2026-03-11)
- **PR:** #11 (`squad/7-ghost-ai`) — repo: jperezdelreal/ComeRosquillas
- **Ghost personality system:** 4 distinct villain AIs in `getChaseTarget()`:
  - Burns (idx 0): Ambush — targets 4–8 tiles ahead of Homer's direction, look-ahead distance scales with level
  - Bob Patiño (idx 1): Aggressive — always targets Homer's exact tile, slightly faster speed (+5% at max ramp)
  - Nelson (idx 2): Patrol/Guard — cycles between 4 waypoints near power pellets, switches to direct chase within 8–14 tile radius (scales with level)
  - Snake (idx 3): Erratic — 30% chance to ignore target and pick random direction, chase target itself is random 40-75% of the time (inverts with level)
- **Difficulty curve (0..1 ramp over 9 levels):**
  - Ghost base speed: 0.9x → scales +0.06x per level (was +0.05x)
  - Fright time: 360 → 120 frames (67% reduction at max ramp)
  - Scatter durations: shrink 50%, chase durations: grow 30%
  - Ghost exit delays: shrink 60% (ghosts leave house faster)
  - Frightened ghost speed: 0.5x → 0.65x (harder to catch at high levels)
- **Key insight for arcade games:** Personality differentiation in Pac-Man clones is best done through target selection (getChaseTarget) + random overrides in direction picking (moveGhost), not through separate state machines per ghost. Keeps the code simple and the architecture flat — one moveGhost function handles all ghosts, personality only diverges at decision points.
- **Modular codebase note:** ComeRosquillas uses global namespace (no ES modules), `<script>` tag loading order. All ghost AI stays in `js/game-logic.js` per the modularization decision (Chewie's PR #10).
