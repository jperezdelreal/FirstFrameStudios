# Bossk — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current VFX:** Hit starbursts, KO effects, damage numbers, motion trails, spawn effects in src/systems/vfx.js. Particle system with dust/sparks/debris in src/engine/particles.js.

## Learnings

- All VFX methods follow a consistent pattern: static factory creates an effect object with `type`, `lifetime`, `maxLifetime`, and `render(ctx, progress)`, then calls `vfxInstance.addEffect()`. New effects must match this contract.
- The `createMotionTrail` signature is backward-compatible — the new `attackType` param is optional and trailing. Existing callers without it still work with default color.
- Boss intro (`type: 'boss_intro'`) needs gameplay.js to check `vfx.effects.some(e => e.type === 'boss_intro')` and pause updates — this is documented in header integration instructions #11 but NOT implemented in gameplay.js (by design: we don't own that file).
- Screen-sized effects (flash, speed lines, boss intro) use `ctx.canvas.width/height` for dimensions — no hardcoded canvas size.
- Telegraph ring expanding outward uses the same progress-based alpha pattern as spawn effects. Keeping visual language consistent across warning indicators.
- Sparkle particles on motion trails use cubic bezier interpolation (`mt³·P0 + 3·mt²·t·P1 + ...`) to position along the outer arc edge — avoids needing a second render pass.
- **Ashfall VFXManager** (`games/ashfall/scripts/systems/vfx_manager.gd`) is a Godot 4 autoload that connects exclusively to EventBus signals. All VFX is decoupled — no direct fighter references.
- Character identification for VFX uses `fighter.player_id` → `SceneManager.p1_character` / `SceneManager.p2_character`. VFXManager loads before SceneManager in autoload order, but character lookup only happens in signal callbacks (after all autoloads ready), so it's safe.
- Character VFX palettes use a `CHARACTER_PALETTES` dictionary keyed by character name (e.g. "Kael", "Rhena") with a `DEFAULT_PALETTE` fallback. Adding a new character's VFX = adding one dictionary entry. All palette-consuming methods accept `char_name: String = ""` for backward compatibility.
- Kael's palette uses negative gravity (`Vector3(0, -60, 0)`) so embers float upward — key to his fire/meditation identity. Rhena's uses high velocity (160-350) and wide spread (90°) for explosive shards.
- KO effects chain: freeze-frame (6 frames at `time_scale=0`) → slow-motion (`time_scale=0.3` for 0.5s) → restore. `_tick_freeze()` runs per-frame in `_process()` since `process_mode = PROCESS_MODE_ALWAYS` still fires during `time_scale=0` (delta is 0 but frame counter decrements).
- Damage number popups use a `Node2D` marker with a `Label` child, tweened upward with fade-out. Font size scales with damage (20/24/28). `_auto_free` handles cleanup after 1s.
- Screen shake now scales by damage: `intensity *= clampf(dmg / 80.0, 0.6, 2.0)`. Duration also scales: `0.15 + clampf(intensity / 50.0, 0, 0.1)`. This makes LP jabs feel crisp and HP/specials feel heavy.
- **Issue #124 fix:** Converted `vfx_manager.gd` from `_process(delta)` to `_physics_process(_delta)` with integer frame counters for deterministic VFX timing. Float-based `_shake_duration`/`_shake_elapsed`/`_ko_slowmo_timer` replaced with `_shake_duration_frames`/`_shake_frames_elapsed`/`_ko_slowmo_frames` (int). KO slow-mo duration changed from `0.5s` float to `30` frames constant. All timing now deterministic at 60fps per "Frame Data Is Law" principle. (PR #139)
- **Sprint 2 Phase 2/4 — Hit Feedback VFX + Ember Stage Integration (PR #146):**
  - Hit sparks now vary by hit strength via `HIT_SPARK_CONFIG` constant: light (white, 6p, 0.2s), medium (orange, 10p, 0.3s), heavy (red/orange, 16p, 0.4s). Character palette still influences gravity, damping, and color blend (30% accent lerp).
  - `_get_hit_type` now returns "light"/"medium"/"heavy" instead of "light"/"heavy"/"special" — aligns with HitType enum (0/1/2). "special" reserved for KO/ember bursts only.
  - Screen shake px ranges now explicit: light=1.5px, medium=3.5px, heavy=6.5px, special=10px. Duration is frame-based: `9 + clampi(int(intensity / 2.0), 0, 6)` frames.
  - Ember stage integration uses 3 tiers: 50+ ember → floating stage particles (6-30, box emission across viewport), 75+ → warm orange overlay (3-12% alpha on CanvasLayer 90), 100 → heat distortion via sine-wave camera wobble (1.5px amplitude, ~4Hz). Distortion defers to active screen shake.
  - `_update_ember_stage()` queries `GameState.get_ember()` for both players and uses max — stage is a shared visualization of the highest ember level.
  - Stage effects fully cleaned up on `round_started` via `_cleanup_stage_effects()`. Overlay uses `queue_free()`, particles toggled off then freed.
