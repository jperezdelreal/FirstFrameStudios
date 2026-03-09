# Ashfall Integration Audit

**Agent:** Solo (Architect)
**Date:** 2025-07-17
**Verdict:** ⚠️ WARN — Project loads, no blockers, but issues need attention

---

## 1. Autoload Order Check — ✅ PASS

All 5 autoloads exist and are in correct dependency order:

| Order | Name | Path | File Exists | Dependencies |
|-------|------|------|-------------|--------------|
| 1 | EventBus | `scripts/systems/event_bus.gd` | ✅ | None |
| 2 | GameState | `scripts/systems/game_state.gd` | ✅ | EventBus |
| 3 | VFXManager | `scripts/systems/vfx_manager.gd` | ✅ | EventBus, GameState |
| 4 | AudioManager | `scripts/systems/audio_manager.gd` | ✅ | EventBus |
| 5 | SceneManager | `scripts/systems/scene_manager.gd` | ✅ | EventBus, GameState |

**Note:** `round_manager.gd` exists in `scripts/systems/` but is NOT registered as an autoload.
This is valid if RoundManager is instantiated as a scene node rather than a singleton, but differs
from the SKILL.md reference pattern which lists it as the 5th autoload.

> `project.godot:19-25`

---

## 2. Scene Reference Check — ✅ PASS

Every `ext_resource` script and resource reference in all 7 `.tscn` files resolves to an existing file.

| Scene | References | All Exist |
|-------|-----------|-----------|
| `scenes/fighters/fighter_base.tscn` | 12 ext_resources (scripts) | ✅ |
| `scenes/main/fight_scene.tscn` | 2 scripts + 1 PackedScene + 2 .tres | ✅ |
| `scenes/stages/ember_grounds.tscn` | 1 script | ✅ |
| `scenes/ui/fight_hud.tscn` | 1 script | ✅ |
| `scenes/ui/main_menu.tscn` | 1 script | ✅ |
| `scenes/ui/character_select.tscn` | 1 script | ✅ |
| `scenes/ui/victory_screen.tscn` | 1 script | ✅ |

Both `.tres` resource files also have valid script references:
- `resources/movesets/kael_moveset.tres` → `scripts/data/fighter_moveset.gd`, `scripts/data/move_data.gd` ✅
- `resources/movesets/rhena_moveset.tres` → `scripts/data/fighter_moveset.gd`, `scripts/data/move_data.gd` ✅

---

## 3. State Machine Completeness — ✅ PASS

All 8 fighter states referenced in `fighter_base.tscn` have corresponding `.gd` files:

| State Node | Script Path | File Exists |
|------------|------------|-------------|
| Idle | `scripts/fighters/states/idle_state.gd` | ✅ |
| Walk | `scripts/fighters/states/walk_state.gd` | ✅ |
| Crouch | `scripts/fighters/states/crouch_state.gd` | ✅ |
| Jump | `scripts/fighters/states/jump_state.gd` | ✅ |
| Attack | `scripts/fighters/states/attack_state.gd` | ✅ |
| Block | `scripts/fighters/states/block_state.gd` | ✅ |
| Hit | `scripts/fighters/states/hit_state.gd` | ✅ |
| KO | `scripts/fighters/states/ko_state.gd` | ✅ |

Inheritance chain verified: each state extends `FighterState` → `State` → `Node`.
Both base classes (`scripts/fighters/fighter_state.gd`, `scripts/states/state.gd`) exist.

> `fighter_base.tscn:3-12`

---

## 4. Input Map vs Controller Check — ⚠️ WARN

### Input actions defined in `project.godot` [input] section (per player):
`up`, `down`, `left`, `right`, `light_punch`, `heavy_punch`, `light_kick`, `heavy_kick`, `block`, `throw`

### Input actions read by `input_buffer.gd` `_read_raw_input()` (line 109-129):
`up`, `down`, `left`, `right`, `light_punch`, `heavy_punch`, `light_kick`, `heavy_kick`, `block`

### Mismatch:

| Issue | Details |
|-------|---------|
| **Orphaned input: `p1_throw` / `p2_throw`** | Defined in `project.godot:81-85,131-133` but never read by any script. Throws are implemented via LP+LK simultaneous press in `fighter_controller.gd:48-53`. The dedicated throw button is dead code in the input map. |

**Impact:** Low. No script references a non-existent input action (which would cause a runtime error). The orphaned `throw` actions just waste input map space. However, this is a spec divergence — if the GDD intends a dedicated throw button, the implementation doesn't match.

> `input_buffer.gd:109-129` — throw not read
> `fighter_controller.gd:48-53` — throw via LP+LK
> `project.godot:81-85` — p1_throw defined

---

## 5. Collision Layer Consistency — ⚠️ WARN

### `project.godot` layer names (`project.godot:137-143`):

| Layer | Bit Value | Name |
|-------|-----------|------|
| 1 | 1 | Fighters |
| 2 | 2 | Hitboxes |
| 3 | 4 | Hurtboxes |
| 4 | 8 | Stage |

### `ARCHITECTURE.md` (line 270-281) documents a DIFFERENT 6-layer scheme:

| Layer | Name |
|-------|------|
| 1 | physics (CharacterBody2D) |
| 2 | p1_hurtbox |
| 3 | p2_hurtbox |
| 4 | p1_hitbox |
| 5 | p2_hitbox |
| 6 | pushbox |

**The actual implementation matches `project.godot` (4 shared layers), NOT `ARCHITECTURE.md` (6 per-player layers).**

### Actual collision values in scene/script files:

| Node | File | collision_layer | collision_mask | Matches project.godot? |
|------|------|-----------------|----------------|----------------------|
| FighterBase (CharacterBody2D) | `fighter_base.tscn:22` | 1 (default) | 1 (default) | ✅ Layer 1 = Fighters |
| Hurtbox (Area2D) | `fighter_base.tscn:39-40` | 4 | 2 | ✅ Layer 3 = Hurtboxes, detects Layer 2 = Hitboxes |
| Hitbox (Area2D) | `hitbox.gd:25-26` | 2 | 4 | ✅ Layer 2 = Hitboxes, detects Layer 3 = Hurtboxes |
| Floor/Walls (ember_grounds) | `ember_grounds.tscn:74,84,92` | 8 | 0 | ✅ Layer 4 = Stage |
| Floor/Walls (fight_scene) | `fight_scene.tscn:29,34,40` | 1 (default) | 1 (default) | ❌ Should be Layer 4 = Stage (value 8) |

### Issues:

1. **`ARCHITECTURE.md` collision layer documentation is stale/wrong.** It describes a 6-layer per-player scheme (lines 270-281) that was never implemented. The actual code uses a simpler 4-layer shared scheme matching `project.godot`. This will mislead future agents.

2. **`fight_scene.tscn` stage bodies use default collision layers.** The Floor, LeftWall, and RightWall `StaticBody2D` nodes in `fight_scene.tscn` have no explicit `collision_layer` — they default to Layer 1 (Fighters) instead of Layer 4 (Stage, value 8). This works by accident because `CharacterBody2D.move_and_slide()` checks against Layer 1 which both fighter and stage share, but it violates the documented layer scheme and could cause unintended fighter-to-stage-body interactions.

3. **Fighter mask doesn't include Stage layer.** `FighterBase` `CharacterBody2D` has default `collision_mask=1`. If `ember_grounds.tscn` is used as the stage (where floor has `collision_layer=8`), fighters' `move_and_slide()` won't detect the floor because mask 1 doesn't include layer 4 (value 8). Currently not triggered because `fight_scene.tscn` embeds its own stage on Layer 1.

> `ember_grounds.tscn:74` — `collision_layer = 8`
> `fighter_base.tscn:22` — no mask for layer 4
> `fight_scene.tscn:29-43` — no explicit collision_layer on stage bodies

---

## 6. Missing File Detection — ✅ PASS

### All referenced scripts exist:
Every `ext_resource` path in all `.tscn` and `.tres` files resolves to an existing `.gd` file. Zero broken references.

### All referenced resources exist:
- `resources/movesets/kael_moveset.tres` ✅
- `resources/movesets/rhena_moveset.tres` ✅

### Empty directories (not blocking):
- `resources/fighter_data/` — contains only `.gitkeep` (no `.tres` files yet)
- `scripts/camera/` — contains only `.gitkeep` (camera logic is in `fight_scene.gd` instead of a dedicated `fight_camera.gd`)

### ARCHITECTURE.md references scripts that don't exist yet (non-blocking):
- `combat_system.gd` — referenced in architecture docs but not yet implemented
- `fight_camera.gd` — referenced in directory structure docs; camera tracking is embedded in `fight_scene.gd:30-43`

These are aspirational/planned references in documentation, not actual scene dependencies. They don't prevent project loading.

---

## Summary

| Check | Result | Blocking? |
|-------|--------|-----------|
| Autoload order | ✅ PASS | — |
| Scene references | ✅ PASS | — |
| State machine completeness | ✅ PASS | — |
| Input map vs controller | ⚠️ WARN | No — orphaned `throw` inputs, no missing ones |
| Collision layer consistency | ⚠️ WARN | No — works with current fight_scene.tscn stage; ember_grounds stage would break |
| Missing file detection | ✅ PASS | — |

### Recommended Actions (priority order):

1. **Fix collision layers in `fight_scene.tscn`** — Add `collision_layer = 8` and `collision_mask = 0` to Floor, LeftWall, RightWall. Add `collision_mask = 9` (layers 1+4) to FighterBase so fighters detect both other fighters and stage geometry.

2. **Update ARCHITECTURE.md collision documentation** — Replace the 6-layer scheme (lines 270-281) with the actual 4-layer scheme from `project.godot`.

3. **Decide on throw input** — Either remove `p1_throw`/`p2_throw` from `project.godot` (if LP+LK is the design intent), or wire the dedicated throw button into `input_buffer.gd` (if a one-button throw is desired).
