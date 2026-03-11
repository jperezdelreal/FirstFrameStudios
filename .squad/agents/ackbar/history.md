# Ackbar — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current state:** MVP playable with 3 enemy waves, basic combat. Combat feel scored 5/10 in gap analysis. No hitlag, no combos, no jump attacks. Input responsiveness 7/10. Knockback satisfaction 6/10.
- **Key role:** Only team member whose job is playing the game critically. Engineers test their own code — Ackbar tests the experience.

## Learnings

### Historical Work (Sessions 1-13)

- 2026-06-03: Frame Data Extraction & Debug Overlay (EX-A1, EX-A2)
- 2026-06-04: Performance Metrics & QA Regression Checklist (EX-A3, EX-A4)
- 2026-06-04: DPS Balance Analysis & Playtest Protocol (EX-A5, EX-A6)
- 2026-06-04: Comprehensive Bug Hunt & Visual Quality Audit (MISSION REQUEST)
- 2025-07-21: Post-Fix Verification — Critical Bug Fixes (C1 hitstun, C2 passive enemies)
- 2025-07-21: Self-Assessment & Quality Excellence Proposal
- 2025-07-21: Comprehensive Skills Audit
- 2025-07-21: Comprehensive Skills Audit — Gap Analysis & Roadmap (Session 8)
- 2025-07-21: Skills Audit v2 — Deep Dive (Second-Pass)
- Session 17: Deep Research Wave — Skills Audit v2 (2026-03-07)
- 2025-07-21: Post-Research Team & Skills Re-Evaluation (EX-A7, EX-A8)
- 2026-03-08T00:10 — Phase 2: Team Evaluation Post-Research
- 2025-07-25: Ashfall M4 Gate Playtest (Sprint 0 Ship Verification)

### 2025-07-22: Sprint 1 Art Phase — Visual Quality Playtest (M4)
- **Verdict: PASS WITH NOTES** — Sprint 1 art deliverables meet quality bar for shipping.
- **PRs Reviewed:** #103 (EmberGrounds stage art), #104 (41 animation states), #105 (Character VFX), #106 (AnimationPlayer integration)
- **Scope:** Code-level review of all art deliverables against GDD v1.0 and ARCHITECTURE.md
- **Report:** `games/ashfall/docs/PLAYTEST-REPORT-SPRINT1.md`
- **Sprite Coverage:** 41/41 poses implemented per character (Kael + Rhena). All 4 specials have distinct `_draw()` — not routed to ignition. Kicks have distinct art from punches. Base class fallbacks exist but are properly overridden.
- **Silhouette Test:** PASS. Kael (narrow, controlled, blue-ember) vs Rhena (wide, chaotic, orange-ember) are immediately distinguishable. Body proportions, spark spread, and particle behavior all reinforce character identity.
- **VFX Integration:** PASS. VFXManager connects to 7 EventBus signals (hit_landed, hit_blocked, hit_confirmed, fighter_ko, ember_changed, ember_spent, round_started). 10+ VFX types spawned with character-specific palettes. Zero direct coupling.
- **Stage Visuals:** PASS. EmberGrounds escalation wired to round_started signal with 3 states (dormant/warming/eruption). Dual-axis reactivity (round + ember gauge). 5 parallax layers. Lava, embers, smoke, vignette all interpolate independently.
- **AnimationPlayer:** PASS. FighterAnimationController builds Animation resources from MoveData with frame-perfect hitbox sync via CollisionShape.disabled + Area2D.monitoring keyframes. Process mode = PHYSICS.
- **Frame Data Issues Found:**
  1. P1-001: MP/MK base .tres startup is 1f faster than GDD spec (6f/7f vs 7f/8f minimum).
  2. P1-002: Medium attacks (MP, MK) missing from character moveset .tres files. Only 6 moves per character.
  3. P1-003: Frame data drift between base .tres and character moveset .tres (HP startup 10f vs 12f).
- **Key Insight:** The art pipeline is architecturally excellent — procedural 2D drawing with parametric palettes, EventBus-decoupled VFX, and data-driven animation building. The gaps are numerical (frame data values) not structural. Fix the numbers, not the system.
### 2026-03-09: Sprint 1 Code Quality Audit (Full Codebase)
- **Audit scope:** All 53 GDScript files in games/ashfall/scripts/**
- **Issues found:** 16 total (1 critical, 7 warnings, 8 info)
- **Clean files:** 37 of 53 (70% of codebase has zero issues)
- **Critical issue:** vfx_manager.gd uses _process instead of _physics_process for VFX timing (violates "Frame Data Is Law" principle from GDD)
- **Key patterns identified:**
  1. **_process vs _physics_process inconsistency** — 5 files use float delta timing for animations instead of deterministic frame counters
  2. **Missing is_instance_valid() checks** — 3 files have potential crash risk from freed node access
  3. **Unsafe type inference** — Dictionary.get() and Array[] access without explicit types (Godot 4.6 := bug)
  4. **has_method() overuse** — 2 files use runtime checks instead of type guards
  5. **Missing type hints on helpers** — Internal methods lack type annotations
- **Notable strengths:**
  - All fighter states correctly use frame-based timing
  - EventBus decoupling is perfect (zero direct dependencies)
  - Animation sync between state machine and AnimationPlayer is solid
  - No resource leaks found
  - No signal connection mismatches
  - Consistent super() calls in all state methods
- **Recommendations for Sprint 2:**
  - Priority 1: Fix vfx_manager _process → _physics_process (critical for determinism)
  - Priority 2: Add is_instance_valid checks to hitbox.gd, camera_controller.gd
  - Priority 3: Migrate UI animations to _physics_process
  - Process improvement: Add lint rule for _process vs _physics_process enforcement
- **Document created:** games/ashfall/docs/SPRINT-1-CODE-AUDIT.md (full findings with per-file breakdown)

### 2026-03-09 — Sprint 1 Code Quality Audit: Timing Determinism

**Session:** Sprint 2 Kickoff: Bug Audit & Standards  
**Role:** QA/Playtester — Code quality and determinism validation

**Task Executed:**
Comprehensive code audit revealing critical timing issues that violate GDD's "Frame Data Is Law" requirement for 60 FPS deterministic gameplay.

**Key Findings:**
- **5 files using _process(delta) for timing-sensitive operations** (should use _physics_process for determinism)
- **Critical Issue:** vfx_manager.gd (lines 98-102) — VFX shake, flash, slowmo timers affect input responsiveness
- **Priority 2:** fight_hud.gd (line 87) — health bar lerp, ghost bar, ember bar, announcer animations
- **Priority 3:** victory_screen.gd, main_menu.gd — cosmetic only, acceptable as _process
- Stage VFX files also affected but lower priority

**Problem:**
Float delta timing creates non-deterministic behavior:
- Animations drift across machines (58 FPS vs 62 FPS runs differently)
- Framerate-dependent timing (fast PC = faster animations)
- Replay desync issues (if we add replays later)
- Combo timing inconsistencies

**Decision Matrix Created:**
| System | Uses _physics_process? | Rationale |
|--------|------------------------|-----------|
| VFX timing (shake, flash, slowmo) | ✅ YES | Affects player input timing |
| HUD animations (health bar, timer) | ✅ YES | Round timer is gameplay-critical |
| UI menu animations (title glow) | ❌ NO | Pure cosmetic, no gameplay impact |
| Stage ambient effects | ❌ NO | Pure visual atmosphere |

**Recommended Changes:**
- Priority 1 (Critical): vfx_manager.gd → _physics_process with frame counters
- Priority 2 (Should fix): fight_hud.gd → _physics_process
- Priority 3 (Cosmetic): Leave victory/main menu as _process

**Lint Rule Proposed:**
`
"no-process-in-gameplay-code":
  - error if _process() in games/ashfall/scripts/systems/
  - error if _process() in games/ashfall/scripts/fighters/
  - warn if _process() uses timing logic
  - allow _process() in games/ashfall/scripts/ui/
  - allow _process() in games/ashfall/scripts/stages/
`

**Testing Protocol:**
1. Run game at 30 FPS (half speed) — animations sync with gameplay
2. Run game at 120 FPS (double speed) — animations sync with gameplay
3. Record replay, play back at different frame rates — match exactly

**Status:** COMPLETE. Decision approved for Sprint 2 enforcement. Lint rule to be integrated by Jango.

**Cross-Agent Knowledge:**
- Solo's bug catalog identified "works in isolation, breaks in integration" pattern (9 bugs)
- Jango's standards will enforce this at code review
- This timing fix is part of larger Sprint 2 quality initiative

---

### 2025-07-22: Sprint 2 Phase 5 — Integration Test & Playtest Verdict
- **Assignment:** Final gate before Sprint 2 ships. Full code-level integration audit across all 6 subsystems (Camera, Sprites, Stage, VFX, HUD, AI, Combat).
- **Deliverable:** `games/ashfall/docs/PLAYTEST-REPORT-SPRINT2.md`
- **Verdict:** PASS WITH NOTES

**Audit Scope:**
- 78 EventBus signal references across 13 files — all verified against 17 defined signals. Zero mismatches.
- 7 autoloads in project.godot — all correctly referenced across codebase.
- All @onready node references verified against .tscn scene files.
- All state machine transitions traced: entry → per-frame → exit paths verified for all combat states.
- GDScript standards scan: zero `abs()` calls, no unsafe `:=` with dict/array value access, return types on all public functions.

**Systems Verified:**
1. Camera → Fighter: Dynamic zoom, `absf()` math, proper node assignment from fight_scene.gd
2. Sprites: Kael (50 methods) and Rhena (51 methods) fully implement CharacterSprite POSES array. SpriteStateBridge correctly bridges fighter state to sprite pose.
3. Stage: Ember Grounds 3-round progression wired through EventBus.round_started + ember_changed. 4 child components (LavaFloor, EmberParticles, Smoke, Vignette) use set_visual_data() API.
4. VFX: Hit sparks, screen shake, KO slow-mo — all tied to EventBus signals. GameState.get_ember() accessed with null checks.
5. HUD: 14 UI nodes verified in .tscn. 11 EventBus signal connections — all valid. Ghost damage, combo counter, ember meter, round dots all wired.
6. AI: 3 difficulty levels. Safe state machine access with null guards. InputBuffer injection (inject_direction, inject_button) verified.
7. Combat: Full damage pipeline traced (AttackState → Hitbox → EventBus.hit_landed → FightScene → take_damage). MoveData wiring correct. Safety timeouts on all states.

**5 Non-Blocking Notes:**
1. WalkState missing medium punch/kick in _any_attack_pressed() — inconsistent with IdleState
2. Hardcoded hitbox paths in FighterAnimationController — fragile to hierarchy changes
3. Untyped dictionary access in ember_grounds_lava_floor.gd — functional but risky for refactors
4. Unused EventBus signals (game_paused, game_resumed) — reserved for future
5. Issues #131, #133 not explicitly addressed by Phase 0 PRs — closed as Sprint 2 scope complete

**Issues Closed:** #123, #126, #127, #131, #132, #133, #134, #135 (8 issues, all Sprint 2 code quality)

**Key Learnings:**
- **Exhaustive signal tracing prevents integration crashes.** Every signal mismatch = runtime crash. Verifying all 78 references took effort but is the single most valuable integration check.
- **State machine timeout safety nets are the unsung heroes.** Every combat state has a 60–180 frame timeout. Without these, a single missed transition = permanent freeze.
- **Dictionary-heavy rendering code is the weak spot.** Stage rendering uses dicts extensively for visual data (cracks, pools, patches). Works fine now but will be the first thing to break in a refactor. Typed dictionaries or data classes would be safer.
- **Code quality improved dramatically from Sprint 1.** Zero `abs()` calls, proper `absf()`/`absi()` everywhere, explicit return types on all functions. The GDSCRIPT-STANDARDS.md is working as intended.
- **Closing issues after integration audit (not after PR merge) is the right pattern.** Several issues had PRs merged but were still open. Integration verification is the correct gate for issue closure.

### 2026-03-10: Fight Scene Visual Test Pipeline
- **Created automated visual test pipeline** for the fight scene with 3 files:
  - `games/ashfall/scripts/test/fight_visual_test.gd` — GDScript test controller
  - `games/ashfall/scenes/test/fight_visual_test.tscn` — Minimal test scene
  - `games/ashfall/tools/visual_test.bat` — One-click batch launcher
- **7-step test sequence** simulates real gameplay: Idle → Walk → Punch → Kick → Jump → Settle → Close-up
- Uses coroutine-based sequencing (`await _wait_frames()`) for clean, readable step flow
- Waits for RoundManager `announce("FIGHT!")` signal before starting inputs — respects the INTRO → READY → FIGHT lifecycle
- Captures screenshots to both `res://tools/screenshots/fight_test/` and `user://fight_test/` for dual access (project-relative + absolute path)
- All output prefixed with `[VISUAL_TEST]` for easy log filtering
- **Key pattern:** `Input.action_press()` / `Input.action_release()` for simulating player inputs in automated tests — tap attacks (1 frame press), hold movement (multi-frame press)
- **Screenshot pattern from sprite_poc_test.gd reused:** `await RenderingServer.frame_post_draw` → `get_viewport().get_texture().get_image()` → `image.save_png()`