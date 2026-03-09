# Playtest Report — Sprint 1 (Art Phase)

**Tester:** Ackbar (QA Lead / Playtester)  
**Date:** 2025-07-22  
**Sprint:** Sprint 1 — Art Phase  
**PRs Reviewed:** #103 (EmberGrounds), #104 (41 animation states), #105 (Character VFX), #106 (AnimationPlayer integration)  
**Method:** Code-level review of all art deliverables against GDD v1.0 and ARCHITECTURE.md specs

---

## Verdict: ✅ PASS WITH NOTES

Sprint 1 art deliverables are **production-ready** for gameplay integration. All core visual systems are implemented, characters are distinct, VFX are wired, and the stage escalates correctly. Three P1 items require follow-up before Sprint 2 gameplay tuning begins.

---

## Test Results Summary

| Test Area | Result | Details |
|-----------|--------|---------|
| **1. Sprite Coverage** | ✅ PASS | 41/41 poses implemented per character |
| **2. Silhouette Test** | ✅ PASS | Kael and Rhena visually distinct across all poses |
| **3. VFX Integration** | ✅ PASS | VFXManager wired to 7 EventBus signals, 10+ VFX types |
| **4. Stage Visuals** | ✅ PASS | EmberGrounds escalation wired to round_started |
| **5. AnimationPlayer** | ✅ PASS | FighterAnimationController builds from MoveData correctly |
| **6. Frame Data** | ⚠️ PASS WITH NOTES | Discrepancies in base .tres vs GDD spec |

---

## 1. Sprite Coverage — ✅ PASS (41/41)

**Files reviewed:**
- `scripts/fighters/sprites/character_sprite.gd` (base class, 41 POSES)
- `scripts/fighters/sprites/kael_sprite.gd` (80.9 KB, 41 `_draw_*()` methods)
- `scripts/fighters/sprites/rhena_sprite.gd` (84.3 KB, 41 `_draw_*()` methods)

**POSES array (character_sprite.gd) — 41 entries:**

| # | Pose | Kael | Rhena |
|---|------|------|-------|
| 1 | idle | ✅ | ✅ |
| 2 | walk | ✅ | ✅ |
| 3 | walk_2 | ✅ | ✅ |
| 4 | crouch | ✅ | ✅ |
| 5 | jump_up | ✅ | ✅ |
| 6 | jump_peak | ✅ | ✅ |
| 7 | jump_fall | ✅ | ✅ |
| 8 | dash | ✅ | ✅ |
| 9 | backdash | ✅ | ✅ |
| 10–15 | attack_lp/mp/hp/lk/mk/hk | ✅ | ✅ |
| 16–21 | crouch_lp/mp/hp/lk/mk/hk | ✅ | ✅ |
| 22–27 | jump_lp/mp/hp/lk/mk/hk | ✅ | ✅ |
| 28 | block_standing | ✅ | ✅ |
| 29 | block_crouching | ✅ | ✅ |
| 30 | hit | ✅ | ✅ |
| 31 | ko | ✅ | ✅ |
| 32 | throw_execute | ✅ | ✅ |
| 33 | throw_victim | ✅ | ✅ |
| 34 | wakeup | ✅ | ✅ |
| 35–38 | special_1/2/3/4 | ✅ | ✅ |
| 39 | ignition | ✅ | ✅ |
| 40 | win | ✅ | ✅ |
| 41 | lose | ✅ | ✅ |

**Key observation:** All 4 special move poses have fully distinct `_draw()` implementations in both characters (not routed to ignition as initially suspected). Kicks have distinct art separate from punch equivalents.

**GDD mapping note:** GDD lists ~45 states because it counts hit variants (light/heavy/crouch/air) and knockdown variants (fall/ground) separately. These map to single `hit` and `ko` poses in code. Acceptable — visual differentiation of hit reactions is a polish item, not a blocker.

---

## 2. Silhouette Test — ✅ PASS

**Kael (The Cinder Monk):**
- Narrow shoulders (SHOULDER_W: 12.0), thin limbs (ARM_THICK: 3.5, LEG_THICK: 4.0)
- Upright, centered stance — reads as disciplined/controlled
- P1: cool blue-ember palette, P2: warm red-ember
- Narrow spark spread (40°), controlled particle velocity

**Rhena (The Wildfire):**
- Wide shoulders (SHOULDER_W: 14.0), thick limbs (ARM_THICK: 4.5, LEG_THICK: 5.0)
- Stockier build, lower head position — reads as aggressive/powerful
- Burn scars rendered as overlay details, torn sleeve edges
- P1: hot orange-ember palette, P2: cool cyan-frost
- Wide spark spread (90°), fast chaotic particles (+4 bonus)

**Verdict:** Characters are immediately distinguishable by silhouette alone. Body proportions, stance posture, and VFX spread create clear visual identity. Kael = precision, Rhena = chaos.

---

## 3. VFX Integration — ✅ PASS

**File reviewed:** `scripts/systems/vfx_manager.gd`

**EventBus signal connections (7 total):**

| Signal | VFX Response | Character-Specific? |
|--------|-------------|---------------------|
| `hit_landed` | Hit sparks (8-12 particles), screen shake, damage numbers | ✅ Kael blue / Rhena orange |
| `hit_blocked` | Block sparks (6 particles, blue-white) | Shared |
| `hit_confirmed` | 2-frame hitstun flash overlay | Shared |
| `fighter_ko` | KO burst (20+ particles), 6-frame freeze, 0.3x slow-mo, screen flash | ✅ Character palette |
| `ember_changed` | Ember trail particles from fighter position | Shared |
| `ember_spent` | Burst flash + light screen shake | Shared |
| `round_started` | Reset VFX state, clear timers | N/A |

**Screen shake intensity tiers:** Light (2.0/0.1s), Medium (4.0/0.15s), Heavy (6.0/0.2s), Special (8.0/0.25s)

**Architecture:** Zero direct coupling — VFXManager listens only to EventBus signals. Can add/remove VFX without touching fighter or stage code. Clean.

---

## 4. Stage Visuals (EmberGrounds) — ✅ PASS

**Files reviewed:**
- `scripts/stages/ember_grounds.gd` (main stage controller)
- `scripts/stages/ember_grounds_lava_floor.gd` (animated obsidian + lava fissures)
- `scripts/stages/ember_grounds_embers.gd` (floating particles, max 60)
- `scripts/stages/ember_grounds_smoke.gd` (24 procedural wisps, parallax 0.15x)
- `scripts/stages/ember_grounds_vignette.gd` (heat glow overlay, 8-step gradient)

**Round escalation wiring:**
- Listens to `EventBus.round_started(round_number)`
- 3 states: Dormant (R1) → Warming (R2) → Eruption (R3)
- 1.5s cubic ease-in-out transition between states
- All sub-effects (lava, embers, smoke, vignette) interpolate independently

**Ember gauge reactivity:**
- Listens to `EventBus.ember_changed(player_id, new_value)`
- Lerps between CALM and HOT palettes based on max ember gauge (0–100%)
- Lava glow, sky color, and particle rate scale dynamically

**Parallax layers:** Sky (0.0x) → Silhouettes (0.05x) → Forge (0.15x) → Lava Channels (0.3x) → Floor (1.0x)

**Verdict:** Complete implementation with proper scene hierarchy, smooth transitions, and dual-axis reactivity (round state + ember gauge). Volcanic atmosphere escalates naturally.

---

## 5. AnimationPlayer Integration — ✅ PASS

**File reviewed:** `scripts/fighters/fighter_animation_controller.gd`

**MoveData → Animation pipeline:**

```
MoveData.tres → _build_attack_animation() → Animation resource → AnimationPlayer library
```

**Hitbox sync mechanism:**
1. **Startup frames:** `CollisionShape.disabled = true`, `Area2D.monitoring = false`
2. **Active frames:** `CollisionShape.disabled = false`, `Area2D.monitoring = true`
3. **Recovery frames:** `CollisionShape.disabled = true`, `Area2D.monitoring = false`

Both properties are keyframed at exact frame boundaries using `FRAME_DURATION = 1.0/60.0`. This ensures frame-perfect hitbox activation in `_physics_process()`.

**State machine integration:** `_on_state_changed()` routes state names to animation names. Covers idle, walk, crouch, jump, block (standing/crouching), hit, ko, throw, and attack (dynamically from AttackState's MoveData).

**AnimationPlayer process mode:** Set to `PHYSICS` — animations tick in sync with game logic, not render frames. Correct for deterministic fighting game.

---

## 6. Frame Data Consistency — ⚠️ PASS WITH NOTES

### Frame data exists in 3 locations. Discrepancies found.

**Source 1: GDD.md (design intent)**

| Strength | Startup | Active | Recovery |
|----------|---------|--------|----------|
| Light | 4–5f | 2–3f | 6–8f |
| Medium | 7–9f | 3–4f | 10–14f |
| Heavy | 12–14f | 4–6f | 16–22f |

**Source 2: Base .tres files (`resources/moves/fighter_base/` and `resources/moves/attack_state/`)**

| Move | Startup | Active | Recovery | GDD Match? |
|------|---------|--------|----------|------------|
| LP | 4f | 2f | 6f | ✅ |
| **MP** | **6f** | 3f | 10f | **❌ -1f startup (GDD says 7f min)** |
| HP | 10f | 4f | 18f | ⚠️ 10f (GDD says 12f min) |
| LK | 5f | 3f | 8f | ✅ |
| **MK** | **7f** | 3f | 12f | **❌ -1f startup (GDD says 8f min)** |
| HK | 12f | 5f | 22f | ⚠️ 12f (GDD says 14f min) |

**Source 3: Character movesets (.tres)**

| Move | Kael | Rhena | Base File | Match? |
|------|------|-------|-----------|--------|
| St.LP | 4/2/6 | 4/2/6 | 4/2/6 | ✅ |
| St.HP | 12/4/16 | 12/5/18 | 10/4/18 | ⚠️ Startup differs |
| Cr.LK | 4/3/7 | 4/3/7 | 5/3/8 | ⚠️ Startup differs |
| St.HK | 14/4/18 | 14/5/20 | 12/5/22 | ⚠️ Startup differs |

### Issues Identified

**P1-001: Medium attack startup 1f faster than GDD spec**
- MP base .tres: 6f startup vs GDD minimum 7f
- MK base .tres: 7f startup vs GDD minimum 8f
- Impact: May break intended combo link windows (GDD calculates links using 7f MP startup)

**P1-002: Medium attacks missing from character movesets**
- Kael moveset: 4 normals (LP, HP, LK, HK) + 2 specials = 6 moves
- Rhena moveset: 4 normals (LP, HP, LK, HK) + 2 specials = 6 moves
- MP, MK, Cr.MP, Cr.MK, Cr.HP, Cr.HK, and all jump attacks have no moveset entries
- Impact: AnimationController cannot build hitbox animations for medium attacks

**P1-003: Base .tres vs character moveset frame data drift**
- HP startup: base=10f, Kael/Rhena=12f (character files are +2f)
- HK startup: base=12f, Kael/Rhena=14f (character files are +2f)
- HK recovery: base=22f, Kael=18f, Rhena=20f (all different)
- Risk: If code references base files instead of character files, wrong frame data loads

**P2-001: Duplicate .tres files**
- `resources/moves/fighter_base/` and `resources/moves/attack_state/` contain identical data
- Maintenance risk: changes to one won't propagate to the other

---

## Bugs Filed

| ID | Severity | Title | Status |
|----|----------|-------|--------|
| P1-001 | P1 | MP/MK base .tres startup frames 1f faster than GDD spec | 📋 Issue created |
| P1-002 | P1 | Medium attacks (MP/MK) missing from character moveset .tres files | 📋 Issue created |
| P1-003 | P1 | Frame data drift between base .tres and character moveset .tres | 📋 Issue created |
| P2-001 | P2 | Duplicate move .tres files in fighter_base/ and attack_state/ | Logged (not blocking) |

---

## Overall Assessment

### What Shipped Well
1. **41/41 animation poses** with distinct procedural `_draw()` per character — no gaps, no placeholders
2. **Character identity** is strong at every level: proportions, palettes, VFX spread, particle behavior
3. **VFX architecture** is cleanly decoupled via EventBus — zero direct fighter/stage coupling
4. **Stage escalation** uses dual-axis reactivity (round number + ember gauge) with smooth cubic transitions
5. **Hitbox sync** is frame-perfect via AnimationPlayer keyframes on `disabled` and `monitoring` properties
6. **EventBus** has comprehensive signal coverage (35 signals) with clear ownership

### What Needs Follow-Up
1. **Frame data alignment** — Resolve discrepancies between GDD spec, base .tres, and character .tres before combo tuning begins
2. **Complete movesets** — Add MP, MK, crouching, and air attack entries to character moveset files
3. **Hit reaction variants** — GDD specifies 4 hit types (light/heavy/crouch/air); code consolidates to single `hit` pose. Future polish.

### Recommendation
**Ship Sprint 1. Begin Sprint 2 gameplay tuning.** The P1 frame data issues are tuning problems, not architectural ones — the system is built correctly, the numbers just need alignment. Address P1-001 through P1-003 as first Sprint 2 tasks before combo implementation.

---

*Report filed by Ackbar, QA Lead. "It's a PASS... but keep your eyes on those frame data channels."*
