# Sprint 2 Playtest Report

## Verdict: PASS WITH NOTES

## What Was Tested
- Code integration review of all Sprint 2 PRs merged across 5 phases (PRs #136–#150)
- Signal wiring verification (78 EventBus references across 13 files)
- GDScript Standards compliance (all .gd files scanned)
- Cross-system compatibility (autoloads, scene tree, state machine)
- Camera, Sprites, Stage, VFX, HUD, AI, Combat subsystem integration

## Findings

### ✅ Working
- **Signal integrity:** All 78 EventBus signal references across 13 files map to the 17 signals defined in event_bus.gd. Zero mismatches.
- **Autoload wiring:** All 7 autoloads (EventBus, GameState, RoundManager, VFXManager, AudioManager, SceneManager, ComboTracker) defined in project.godot and correctly referenced.
- **Camera → Fighter:** camera_controller.gd correctly receives fighter1/fighter2 from fight_scene.gd. Uses `absf()` for float math (lines 98, 108). All node paths valid.
- **HUD → EventBus:** fight_hud.gd connects to all 11 required signals. All 14 @onready node references verified against fight_hud.tscn. Every function has explicit return type.
- **AI → Fighter:** ai_controller.gd safely accesses state_machine, input_buffer, and opponent with null guards. All 35 functions have return types. Uses `inject_direction()` and `inject_button()` which exist in InputBuffer.
- **Combat pipeline:** attack_state.gd → hitbox.gd → EventBus.hit_landed → fight_scene.gd → target.take_damage() — full chain verified. MoveData wiring correct. One-hit-per-activation rule enforced.
- **State machine safety:** All combat states (Attack, Hit, Block, Throw, Jump, KO) have timeout safety nets (60–180 frames) preventing infinite loops.
- **Stage round progression:** ember_grounds.gd connects to EventBus.round_started and ember_changed. 3-round visual escalation implemented with proper tween management.
- **VFX → GameState:** vfx_manager.gd correctly calls GameState.get_ember(pid) with null check. 3-tier visual system (50+, 75+, 100 ember) cascades properly.
- **Sprite system:** kael_sprite.gd (1699 lines, 50 functions) and rhena_sprite.gd (1764 lines, 51 functions) both extend CharacterSprite correctly. All pose methods match POSES array.
- **GDScript compliance:** Zero `abs()` calls found (all use `absf()`/`absi()`). No unsafe `:=` with dict/array value access. Return types on all public functions.

### ⚠️ Notes
1. **WalkState missing medium attacks (LOW):** `walk_state.gd` `_any_attack_pressed()` checks light_punch, heavy_punch, light_kick, heavy_kick but not medium_punch or medium_kick. Player must stop walking to use medium attacks. Not a crash, but inconsistent with idle_state which checks all 6.
2. **Hardcoded hitbox paths (MEDIUM):** `fighter_animation_controller.gd` lines 16–17 hardcode `"Hitboxes/Hitbox/CollisionShape"` and `"Hitboxes/Hitbox"`. Works with current scene structure but will break silently if hierarchy changes.
3. **Untyped dict access in stage rendering (LOW):** `ember_grounds_lava_floor.gd` lines 168–203 use dictionary access for visual data (`p["shade_offset"]`, `r["poly"]`, etc.) with explicit type annotations on the receiving variable but no typed dictionary declarations. Functional but could mask type errors in future refactors.
4. **Unused signals (INFO):** `game_paused` and `game_resumed` signals defined in EventBus but have no listeners. Reserved for future use — no crash risk.
5. **Open code quality issues (#131, #133):** Test stub code (#131) and sprite_sheet_generator @tool risk (#133) were not explicitly addressed by Phase 0 PRs. Non-blocking but should be tracked for Sprint 3.

### 🔴 Blockers
- None. No crash-path issues found. All signal chains, node references, and autoload dependencies are valid.

## Sprint 2 Visual Quality Assessment

Does the code represent a meaningful visual upgrade?

- **Camera:** ✅ Dynamic zoom based on fighter distance with proper framing margins. Uses `absf()` correctly. Smooth interpolation via lerp. Meets "Guilty Gear framing" goal.
- **Sprites:** ✅ Major upgrade. 11-color palettes per character, detailed anatomy (face features, muscle contour, clothing). Kael (50 draw methods, warm palette) and Rhena (51 draw methods, cool palette) have distinct visual identities. SpriteStateBridge correctly reads fighter state for pose selection.
- **Stage:** ✅ Ember Grounds implements 3-round visual progression (dormant → warming → eruption). Parallax layers, lava channels, ember particles, smoke, and vignette all wired through set_visual_data() API. Cracked obsidian floor with animated lava glow.
- **HUD:** ✅ Modern fighting game HUD: gradient health bars with ghost damage, ember meter, round indicators, combo counter (hits + damage), announcer text, timer with urgency coloring. All 14 UI nodes verified in .tscn.
- **AI:** ✅ 3 difficulty levels (Easy/Normal/Hard) with tunable parameters. Approaches player, uses combos, respects spacing. Protected state filtering prevents input injection during uninterruptible frames. Weighted attack selection with anti-spam tracking.
- **VFX:** ✅ Hit sparks (light/medium/heavy), screen shake with frame-based decay, KO slow-motion, block sparks, ember trail particles. 3-tier ember stage effects. All VFX tied to EventBus signals for proper decoupling.

## Recommendation

**Ship.** Sprint 2 delivers a meaningful visual and systems upgrade across all 6 domains. The codebase is well-structured with proper signal decoupling, null safety, and GDScript standards compliance. The 5 notes above are non-blocking quality improvements for Sprint 3.

Tag as `ashfall-v0.3.0` after Windows export verification.
