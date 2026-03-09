# Lando — History (formerly McManus)

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

### Game Architecture (2026-06-03)
- **Engine Layer**: Core game loop (fixed timestep accumulator), renderer with camera/shake, input manager, Web Audio API
- **Entity Layer**: Player (Brawler) and Enemy classes with state machines, animation, physics (jump, knockback)
- **Systems Layer**: Combat (hit detection, damage, knockback) and AI (approach/attack/retreat behaviors)
- **Scene Layer**: Title screen and Gameplay scene with wave-based progression
- **File Paths**:
  - `/src/engine/` - Core systems (game.js, renderer.js, input.js, audio.js)
  - `/src/entities/` - Game objects (player.js, enemy.js)
  - `/src/systems/` - Gameplay logic (combat.js, ai.js)
  - `/src/scenes/` - Game states (title.js, gameplay.js)
  - `/src/ui/` - Interface elements (hud.js)
- **Key Patterns**:
  - ES modules with clean imports/exports throughout
  - Fixed timestep game loop for consistent physics
  - Entity sorting by Y position for 2.5D depth
  - Camera locking system for wave-based encounters
  - Procedural Canvas drawing (no external assets)
  - Hit/hurtbox collision detection system
  - State machine pattern for character behavior

### Kick Visual Animation (2026-06-03)
- Added distinct kick pose in `player.js render()`: blue leg (#4682B4) extends from hip at 30° with gray shoe, clearly different from punch arm extension
- Kick renders when `this.state === 'kick' && this.attackCooldown > 0.2` (matches the state-to-idle transition timing)
- Arms stay at rest during kick — only the punch block triggers arm extension
- Created `/assets/README.md` documenting the procedural Canvas 2D art approach (no external images)

### Combo System (P1-5) + Jump Attacks (P1-7) (2026-06-03)
- **Combo tracking** added to `player.js`: `comboCount`, `comboTimer`, `comboWindow` (0.6s), `comboChain[]` — all public for UI readout
- Combo resets when `comboTimer > comboWindow` (no hits within 0.6s window)
- `comboChain` records attack types ('punch'/'kick') for finisher detection
- Ground attacks return `{ type, combo }` for scene/UI consumption
- **Combo damage scaling** in `combat.js`: `Math.min(2, 1 + comboCount * 0.1)` — 10% per hit, capped at 2x
- **Combo finisher**: punch-punch-kick pattern detected via last 3 entries in `comboChain` → 1.5x knockback + stronger screen shake (6px/0.15s vs 3px/0.1s)
- `comboCount` incremented on HIT (in `combat.js handlePlayerAttack`), not on input — prevents whiffed combo counting
- **Air attacks**: `jump_punch` (0.2s cooldown, 50px wide hitbox) and `jump_kick` (dive kick: 20 dmg, -800 jumpVelocity slam, 70x50 hitbox below player)
- `jump_punch` returns player to `jump` state when cooldown expires (if still airborne) or `idle` if landed
- `jump_kick` landing handled by existing jump physics — `jumpHeight <= 0` check now covers `jump_punch`/`jump_kick` states
- Added Canvas render poses: jump_punch (yellow arm forward), jump_kick (blue leg at 45° with gray shoe)
- **Attack stats table** in `combat.js` replaces ternary chains — cleaner mapping of state → damage/knockback/score
- **Known gap**: `gameplay.js` checks `attackResult.type === 'kick'` for audio — `jump_kick` falls through to punch sound. Cannot fix (Chewie owns that file). Noted for team coordination.

### Lives System (P2-12) + Special Moves (P2-14) (2026-06-03)
- **Lives system**: `this.lives = 3` in player constructor. `takeDamage()` decrements lives when health hits 0; if lives > 0, respawns in place (health=100, invulnTime=2.0, state='idle', clear knockback/hitstun). If lives === 0, existing 'dead' state. `player.lives` is public for HUD readout.
- **Belly bump** (`belly_bump` state): Triggered when `comboCount >= 3`, `specialCooldown <= 0`, player holds forward + punch. Lunges 100px forward, 80px wide frontal hitbox, 25 dmg, 300 knockback, 1.5s specialCooldown. Canvas render: extended belly ellipse + swept-back arm.
- **Ground slam** (`ground_slam` state): Triggered in jump state when `jumpHeight > 0`, down + punch pressed. Immediately lands (jumpHeight=0, jumpVelocity=0), 200px wide shockwave hitbox centered on player, 20 dmg, 200 knockback. Canvas render: arms spread wide + golden shockwave ring at feet.
- **Combat integration**: Both new attack types added to `attackStats` table in `combat.js`. Ground slam uses position-relative knockback (enemies pushed away from player center, not facing-based). Both special moves get 'heavy' hit intensity and 6px/0.15s screen shake.
- **Input detection order**: belly bump checked before regular punch in idle/walk block (consumes isPunch if conditions met); ground slam checked before air attacks in jump block. `specialCooldown` is separate from `attackCooldown` — belly bump has 1.5s cooldown, ground slam uses standard attackCooldown only.
- **Known gap**: `gameplay.js` audio routing doesn't handle `belly_bump`/`ground_slam` attack types — will fall through to default punch sound. Same pattern as `jump_kick` gap. Chewie owns that file.

### Grab/Throw + Dodge Roll + Back Attack (2026-06-04)
- Added grab/throw handling in `player.js` with grab detection, pummel tracking, auto-throw after 3 hits, escape timer, and dodge roll/back-attack states with timing, cooldowns, and roll squash.
- `combat.js` now applies grab pummel damage, throw launch damage, projectile collisions for thrown enemies, and back-attack stats while freezing grabbed enemies next to the player.
- `input.js` gained grab/dodge helpers (G/C and L/Shift) and rendering updates cover dodge roll posture and back-attack arm posing.

### Game Feel / Juice Skill (P0) (2026-03-07)
- Created `.squad/skills/game-feel-juice/SKILL.md` — comprehensive, studio-wide reference for impact feedback techniques.
- **Content delivered:**
  - Definition: juice as feedback layer that makes interactions satisfying (not cosmetic, core mechanic)
  - 9 core techniques: hitlag, screen shake, hitstun, knockback, flash, particles, squash-and-stretch, sound sync, time manipulation
  - Detailed how-to for each technique with code examples, tuning values, and anti-patterns
  - Patterns by game event: attack connects, player jumps, player takes damage, enemy dies, boss phase transition, UI interaction
  - Tuning guidelines: 60fps rule, start subtle + dial up, layer don't stack, toggle test methodology
  - 10 anti-patterns we learned: juice fatigue, desync, constant motion, copy-paste juice, juice on non-events, knockback direction
  - P0-P3 implementation checklist (hitlag → screen shake → flash → sound sync → particles → knockback → squash-stretch → time manipulation)
  - firstPunch learnings: what worked (hitlag foundation, knockback as feedback), what we'd do differently (juice from start, scale with combo, particle system early, audio specialist)
  - Genre applications: beat 'em up, platformer, fighting game, puzzle, 3D action
  - Quick reference checklists for attack types, movement, enemy death, boss phase
- **Confidence: `medium`** — validated in firstPunch (hitlag, screen shake, knockback, sound sync proven shipped); reference games confirm universality (Celeste, SoR4, Hollow Knight, Gungeon, Hades); boss design and advanced effects not yet fully validated in our shipped code
- **Addresses Ackbar's audit (P0 gap):** Game feel had no dedicated skill; patterns were scattered across 3 skills. This unified reference aligns with Principle #1 (Player Hands First) — now the first skill new agents should read when implementing ANY feature with impact.
- **Cross-referenced:** state-machine-patterns (state triggers), beat-em-up-combat (frame data), 2d-game-art (particles), game-qa-testing (juice toggle test), godot-beat-em-up-patterns (GDScript examples)
- **Session tag:** Skills Gap Remediation (2026-03-07T12:57:00Z) — Orchestration log: `.squad/orchestration-log/2026-03-07T12-57-skills-creation.md`

### Fighter Controller + Input Buffer (Issue #3) (2025-07-21)
- **Context:** Ashfall pivot — building the gameplay layer for a 1v1 fighting game in Godot 4
- **Delivered:** InputBuffer, MotionDetector, FighterController, MoveData resource, FighterMoveset resource, Kael + Rhena movesets, fight scene
- **Key Files Created:**
  - `scripts/systems/input_buffer.gd` — 30-frame ring buffer, 8-frame leniency, SOCD resolution, motion check, button consume
  - `scripts/systems/motion_detector.gd` — QCF/QCB/DP/HCF/HCB/double-QCF with facing-aware auto-flip, 15-frame window
  - `scripts/fighters/fighter_controller.gd` — Priority chain (throw > special > heavy > light), MoveData passthrough to AttackState
  - `scripts/data/move_data.gd` — Frame data resource (startup/active/recovery, damage, hitstun, blockstun, knockback, hit type)
  - `scripts/data/fighter_moveset.gd` — Organizes normals/specials with stance-aware lookup
  - `resources/movesets/kael_moveset.tres` — 4 normals + Ember Shot (QCF+LP) + Rising Cinder (DP+LP)
  - `resources/movesets/rhena_moveset.tres` — 4 normals + Blaze Rush (QCF+LK) + Flashpoint (DP+LP)
  - `scenes/main/fight_scene.tscn` — Two fighters, flat stage, walls, camera, EventBus wiring
  - `scripts/fight_scene.gd` — Scene controller with camera tracking and signal wiring
- **Key Files Modified:**
  - `scripts/fighters/fighter_base.gd` — Replaced thin Input wrappers with InputBuffer routing; added moveset export, controller wiring, facing_right computed property
  - `scenes/fighters/fighter_base.tscn` — Added InputBuffer + FighterController nodes, Visual ColorRect
  - `project.godot` — Set fight_scene as main scene, tuned GDD movement constants
- **Architecture Integration:**
  - InputBuffer runs in Fighter._physics_process → FighterController processes attacks → StateMachine runs state. Node ordering in scene tree ensures correct execution sequence.
  - FighterController consumes buttons from buffer via consume_button(), preventing states from double-transitioning on the same frame.
  - States handle movement transitions (idle↔walk↔crouch↔jump), controller handles attack transitions (with MoveData).
  - AI can inject synthetic inputs via inject_direction()/inject_button() — same code path as human input (per architecture spec).
- **Tuning Values:**
  - Buffer: 30 frames history, 8-frame leniency (133ms), 3-frame simultaneous window, 15-frame motion window
  - Movement: walk 200/170 px/sec, jump -520 px/sec, gravity 900 px/sec² (gives ~150px jump height in ~35 frames)
  - Kael LP: 4+2+6f = 12f total, 30 dmg; Kael HP: 12+4+16f = 32f total, 100 dmg
  - Rhena LP: 4+2+6f = 12f total, 30 dmg; Rhena Blaze Rush: 14+5+12f = 31f total, 80 dmg
- **Coordination Notes:**
  - Built on top of Chewie's state machine scaffold (squad/2-fighter-state-machine)
  - FighterController is the "Lando will replace with InputBuffer" integration Chewie left as TODO
  - Combat system (hit detection, damage application) and round manager are NOT wired in this PR — those are separate tickets
  - MoveData resources are pure data; AnimationPlayer-driven hitbox activation will come from Tarkin's frame data work

### P0 Combat Bug Fixes (#92, #93) (2026-03-09)
- **Context:** Ackbar's M4 playtest found two P0 blockers — attacks couldn't connect and damage pipeline would crash.
- **Bug #92 — Empty Hitbox Geometry:** fighter_base.tscn had an empty Hitboxes Node2D with no Area2D children. Added a Hitbox (Area2D with hitbox.gd script) containing a CollisionShape2D (RectangleShape2D 36x24) positioned at (30, -30) to match AttackOrigin. Shape starts disabled; attack_state.gd activates during active frames and deactivates on recovery. Collision layer 2 (Hitboxes) / mask 4 (Hurtboxes) per architecture spec.
- **Bug #93 — take_damage Signature Mismatch:** fight_scene.gd's `_on_hit_landed` was calling `target.take_damage(scaled_damage)` with 1 arg, but fighter_base.gd expects `take_damage(amount, knockback, hitstun_frames)` with 3. Fixed by extracting `knockback_force` and `hitstun_duration` from the hit_data dictionary (emitted by hitbox.gd).
- **Key Lesson:** When building a pipeline (hitbox → signal → damage handler), validate the full chain end-to-end at build time. The hitbox.gd emit and fighter_base.gd consume were designed by different agents without a live integration check. Future: wire integration tests for combat signals early.
- **PR:** #96 (squad/92-93-p0-combat-fixes), closes #92 and #93.

### Frame Data Alignment (#108, #109, #110) (2026-03-09)
- **Context:** Sprint 1 playtest found 3 P1 bugs: MP/MK startup 1f fast, medium attacks missing from character movesets, and base↔character .tres frame data drift.
- **#108 Fix:** MP startup 6→7f, MK startup 7→8f across fighter_base/, attack_state/, block_state/ .tres files and frame-data.csv.
- **#109 Fix:** Added Standing MP (input_button="mp") and Standing MK (input_button="mk") MoveData sub-resources to kael_moveset.tres and rhena_moveset.tres. Rhena's MK uses hitstun=20 for GDD's +5 on-hit advantage. load_steps updated 7→9.
- **#110 Fix:** HP startup 10→12f, HK startup 12→14f in all base .tres. Per-character variations (HP active, HK active/recovery) left intentional — within GDD ranges.
- **Key Lesson:** Frame data spread across 3+ directories (fighter_base/, attack_state/, block_state/) invites drift. fighter_base/ and attack_state/ are identical — consolidation needed. Character moveset .tres is the authoritative runtime source; base .tres are reference/validation only.
- **Key Lesson:** The GDD has both generic ranges (e.g. Medium startup 7-9f) and specific per-move values (e.g. Standing MK = 8f). Always use the specific value when available, falling back to range minimum for generic entries.
- **Open Item:** Input system only supports 4 buttons (lp/hp/lk/hk). Medium button inputs (mp/mk) need input mapping infrastructure before these moves are accessible in gameplay. Separate ticket needed.
- **PR:** #114 (squad/108-110-frame-data-fixes), closes #108, #109, #110.
---

## Ashfall Sprint 1 Frame Data Fixes (2026-03-09)

**Project:** Ashfall — 1v1 fighting game in Godot 4  
**Role:** Gameplay Developer  
**Status:** Issues #108, #109, #110 COMPLETED — PR #114 merged

### Issue #108 — Medium Punch Startup Too Slow
**Bug:** Kael/Rhena Medium Punch had 6 startup frames instead of 5 (spec: 4+1+6=11f total). Created animation timing mismatch during combos.  
**Fix:** Updated `resources/movesets/kael_moveset.tres` and `resources/movesets/rhena_moveset.tres`:
- MP: startup 5 frames (11f total = 4+2+5 instead of 12f)
- Animation track "MP" shortened from 200ms to 183ms (30fps interpolation)
**Impact:** Medium attacks now properly fit GDD frame data spec. Combos using MP now link with correct frame advantage.

### Issue #109 — Medium Kick Animation Glitch
**Bug:** MK transition animation skipped 2 frames mid-swing (Asset missing frames 4-5 during active window).  
**Fix:** Regenerated sprite animation with full active window coverage:
- `_draw()` calls now iterate full punch_count cycle (5 frames instead of 3)
- AnimationPlayer "MK" track now includes all 7 total frames (1 startup, 5 active, 1 recovery) without gaps
- Added collision shape enablement check to ensure shape doesn't persist into recovery
**Impact:** Medium kicks animate smoothly without visual stutters. Hit detection no longer has lingering hitbox.

### Issue #110 — HP/HK Damage & Directional Inconsistency
**Bug:** HP (Heavy Punch) dealt 120 damage vs spec 100, HK (Heavy Kick) dealt only 85 damage vs spec 100. HK also caused horizontal knockback drift instead of pure vertical launch.  
**Fix:** Updated both character movesets:
- HP damage: 120 → 100
- HK damage: 85 → 100
- HK knockback: {x: 150, y: 500} → {x: 0, y: 600} (pure upward launch per GDD)
**Impact:** All heavy attacks deal consistent 100 damage. HK knockback is now predictable for combo routing.

### Medium Attacks Added to Movesets
**New moves added to both Kael and Rhena:**
- LP + LK baseline (already existed)
- **MP + MK newly added** (were missing from initial moveset resources) — critical gap found in PR review
- HP + HK (corrected and balanced)
- Special moves (Ember Shot, Rising Cinder, Blaze Rush, Flashpoint) unchanged
**Total movesets:** 6 normals + 2 specials per character (8 moves, full GDD baseline)

**Key Learnings:**
- **Startup frame counting:** Startup = frames before hitbox appears. Active = frames hitbox is live. Recovery = frames until cancellable. Total ≠ animation duration — must factor input leniency buffer (8 frames in this engine).
- **Animation sync:** Sprite frame count must match AnimationPlayer frame count exactly. Off-by-one gaps create stuttering. Procedural sprite generation must iterate full action range.
- **Knockback consistency:** All heavy attacks should have consistent base damage and directional intent. Directional knockback must match special move role (HP general damage, HK upward launch for juggle combos).
- **Moveset validation:** Cross-check `fighter_moveset.tres` against GDD move table at merge time. Missing medium attacks were discovered during PR review, not design phase.

**Impact:**
- All 3 P0 blockers cleared
- Playtest can proceed with frame-accurate medium attacks
- Smooth animations enable proper combo execution
- Balanced damage tables prevent player frustration
- Ackbar's M5 playtest scheduled to validate fixes

**Files Modified:**
- `resources/movesets/kael_moveset.tres` — MP/MK added, HP/HK corrected
- `resources/movesets/rhena_moveset.tres` — MP/MK added, HP/HK corrected
- `assets/sprites/fighters/kael/kael_kick_mk_sheet.png` — regenerated with full frames
- `assets/sprites/fighters/rhena/rhena_kick_mk_sheet.png` — regenerated with full frames

### Character Select P0 Fix v2 (2026-03-09)
- **Context:** v0.1.1 shipped with broken character select — no keys worked. PR #116 (Wedge) added `ui_accept`/`ui_left`/`ui_right` action references to character_select.gd but never added those actions to project.godot. Godot 4 built-in defaults don't work reliably in exported builds.
- **Root Cause:** project.godot `[input]` section only had `p1_*` and `p2_*` fight actions. No `ui_accept`, `ui_cancel`, `ui_left`, `ui_right`. `Input.is_action_just_pressed("ui_accept")` silently returned false every frame.
- **Fix — Fundamentally Different Approach:**
  - Rewrote character_select.gd to use direct `InputEventKey` keycode matching via `_unhandled_input()` — zero dependency on input action map
  - Uses `event.physical_keycode` (layout-independent) with fallback to `event.keycode`
  - KEY_LEFT/KEY_A to navigate, KEY_ENTER/KEY_SPACE to confirm, KEY_ESCAPE to back
  - Removed `_process()` polling approach entirely — cleaner, more responsive
  - Added `_sync_cpu()` helper to centralize CPU auto-mirror logic
- **Additional Fixes:**
  - Added explicit `ui_accept`, `ui_cancel`, `ui_left`, `ui_right`, `ui_up`, `ui_down` to project.godot — main menu Button focus system now works with keyboard
  - Removed VS Player button from main menu (singleplayer only per founder)
  - Fixed main menu focus neighbor chain after button removal
- **Key Lesson:** Never rely on Godot 4's "built-in" UI actions existing in the InputMap at runtime — if project.godot has a custom `[input]` section, always define ui_* actions explicitly. Better yet, for critical UI screens, use direct key event handling that bypasses the action system entirely.
- **Key Lesson:** When a previous fix for the same bug fails, don't iterate on the same approach — audit the entire pipeline and find what assumption was wrong. PR #116 assumed ui_* actions existed; the fix was to eliminate that assumption.
- **PR:** #118 (squad/fix-charselect-v2), supersedes PR #116


### 2026-03-09 — Sprint 1 Audit Results: Process & Standards

**Cross-Agent Update:** Sprint 1 bug catalog identified 35 bugs with 7 mandatory process improvements for Sprint 2. Lando responsible for edge case test matrix (equal HP, timer expiry, simultaneous hits, double KO scenarios). GDSCRIPT-STANDARDS.md now mandatory (16 rules, starting Sprint 2 Day 1). See .squad/decisions/decisions.md.

