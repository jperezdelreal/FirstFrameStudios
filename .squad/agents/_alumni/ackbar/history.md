# Ackbar — History

## Core Context (Summarized)

**Role:** Game QA specialist for Ashfall. Only team member testing the experience critically; engineers test their own code.

**Key Contributions:**
1. **Frame Data Analysis** — Built debug overlay, performed DPS balance analysis, created comprehensive playtest protocol
2. **Sprint 1 Code Quality Audit (2026-03-09)** — Reviewed all 53 GDScript files; 37 clean (70%), 16 issues found (1 critical)
   - Critical: vfx_manager.gd uses _process instead of _physics_process (violates "Frame Data Is Law")
   - Pattern: 5 files use float delta timing instead of deterministic frame counters; 3 files missing is_instance_valid() checks
3. **Visual Quality Playtest (2026-03-22)** — Sprint 1 art APPROVED: silhouette test PASS, VFX PASS, stage visuals PASS, AnimationPlayer PASS
   - Found: MP/MK startup 1f faster than spec; medium attacks missing from movesets; frame data drift
   - Key insight: Pipeline architecturally sound; gaps are numerical, not structural

**Technical Standards (Ashfall):**
- Fixed 60fps deterministic; inputs drive state (enables rollback netcode)
- _physics_process() only; integer frame counters > float timers
- Node-based state machine per fighter; AnimationPlayer drives timing; MoveData resources; 6 collision layers

**Archived Skills:** VFX integration, hitlag system, event system, animation design, screen transitions, particles, music wiring
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