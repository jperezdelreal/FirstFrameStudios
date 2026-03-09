# Ashfall — M4 Gate Playtest Report (Sprint 0 Ship Verification)

**Playtester:** Ackbar (QA/Playtester)
**Date:** 2025-07-25
**Build:** main branch, post-PR #89 (signal wiring) + PR #90 (placeholder sprites)
**Method:** Code-level playtest — full trace of game flow, combat pipeline, state machine, balance data, AI, HUD, and round management.

---

## Verdict: PASS WITH NOTES

The Sprint 0 prototype infrastructure is **architecturally excellent**. Full game flow works end-to-end (menu → select → fight → victory → rematch). 9 fighter states transition correctly. Frame-based determinism is solid. Input system uses proper FGC conventions. EventBus decoupling is clean. Balance numbers are reasonable.

**However**, normal attacks cannot deal damage due to empty hitbox geometry, and the damage pipeline has a latent crash bug. The game flow still technically completes via throws and timer expiry, but **two P0 bugs and two P1 bugs must be fixed before M5.**

---

## Bugs Found

### P0-001: Empty Hitbox Geometry — Attacks Cannot Connect

**Severity:** P0 (Blocker)
**Location:** `scenes/fighters/kael.tscn` line 57, `scenes/fighters/rhena.tscn` line 57
**Description:** The `Hitboxes` Node2D in both fighter scenes has **no child Area2D nodes**. When `attack_state.gd:_activate_hitboxes()` iterates `fighter.hitboxes.get_children()`, the loop body never executes. No Hitbox instances exist → no `area_entered` signals → `EventBus.hit_landed` never emits → **no attack ever deals damage**.
**Reproduction:**

1. Start VS CPU match
2. Walk into range and press any attack button (U, I, J, K)
3. Attack animation plays but opponent takes no damage
4. Health bar never moves from attacks

**Impact:** The entire damage pipeline via normal/special attacks is non-functional. Only throws can deal damage (throw_state.gd calls take_damage directly). The round timer (99s) becomes the only reliable round-resolution mechanism.
**Fix:** Add Hitbox Area2D child nodes under the `Hitboxes` node in each fighter scene, with CollisionShape2D geometry positioned relative to AttackOrigin.

---

### P0-002: `take_damage` Signature Mismatch — Latent Crash

**Severity:** P0 (Blocker — latent, activates when P0-001 is fixed)
**Location:** `scripts/fight_scene.gd` lines 69, 76
**Description:** `fighter_base.gd:86` defines `take_damage(amount: int, knockback: Vector2, hitstun_frames: int)` with **3 required parameters**. But `fight_scene.gd:_on_hit_landed()` calls `target.take_damage(chip)` (line 69) and `target.take_damage(scaled_damage)` (line 76) with **only 1 argument**. This will produce a GDScript runtime error when the call is reached.
**Reproduction:**

1. Fix P0-001 (add hitbox geometry)
2. Land any attack
3. Game crashes: "Invalid call. Nonexistent function 'take_damage' with 1 argument(s)" (or similar arity error)

**Note:** `throw_state.gd:137` correctly passes all 3 arguments: `_grabbed_opponent.take_damage(THROW_DAMAGE, kb, THROW_HITSTUN)`. Only the fight_scene hit pipeline is broken.
**Fix:** Extract `knockback_force` and `hitstun_duration` from the `move` dictionary and pass them:
```gdscript
var kb: Vector2 = move.get("knockback_force", Vector2.ZERO)
var hs: int = move.get("hitstun_duration", 12)
target.take_damage(scaled_damage, kb, hs)
```

---

### P1-001: GameState.scores Never Updated — HUD/Victory Display Wrong

**Severity:** P1 (Major)
**Location:** `scripts/systems/round_manager.gd` line 105, `scripts/fight_scene.gd`
**Description:** `RoundManager` maintains its own `scores` array and increments it on KO (line 105). But `GameState.scores` is never updated — `GameState.advance_round()` is never called from anywhere. The HUD's `_on_round_ended` (fight_hud.gd:222) reads `GameState.scores`, which stays `[0, 0]`. The victory screen (victory_screen.gd:37-38) also reads `GameState.scores`.
**Reproduction:**

1. Win a round via throw or timer
2. Observe round dots in HUD — always show 0 wins for both players
3. Win the match → victory screen shows "Kael 0 - 0 Rhena"

**Fix:** Either sync RoundManager scores to GameState, or have RoundManager call `GameState.advance_round(winner_index)` after each round.

---

### P1-002: Equal-HP Timer Draw Creates Infinite Round Loop

**Severity:** P1 (Major)
**Location:** `scripts/systems/round_manager.gd` lines 116-125
**Description:** When the round timer expires and both fighters have equal HP, `_time_over()` computes `winner_index` but skips `scores[winner_index] += 1` due to the `if f0_hp != f1_hp` guard. No score increments → `_check_match_over` finds no winner → transitions to `ROUND_RESET` → new round starts → same outcome. The game loops infinitely.
**Reproduction:**

1. Start VS CPU match
2. Don't attack (or both fighters take equal damage from throws)
3. Wait for 99-second timer to expire
4. Round resets. Timer expires again. Repeat forever.

**Impact:** With P0-001 (no hitbox damage), most rounds will end in timer draws at equal HP, making this the **default game state** in the current build.
**Fix:** Award the round to the player with more HP, or if truly equal, either award to P1 (home advantage) or add a sudden-death/draw mechanism. At minimum, increment `current_round` to prevent infinite looping (already done in `_check_match_over` → `ROUND_RESET` path, but rounds with no winner never advance toward match end).

---

### P1-003: Missing Medium Punch / Medium Kick Buttons in Moveset

**Severity:** P1 (Minor functional gap)
**Location:** Input map in `project.godot`, `input_buffer.gd`
**Description:** `project.godot` defines `p1_medium_punch` (Y key) and `p1_medium_kick` (H key) input actions. But `input_buffer.gd:_read_raw_input()` only captures `lp`, `hp`, `lk`, `hk` — no `mp` or `mk`. The GDD specifies a 6-button layout (LP/MP/HP/LK/MK/HK), but only 4 buttons are functional. Pressing Y or H does nothing.
**Impact:** Players expecting the advertised 6-button layout will find 2 buttons unresponsive. Not a crash, but a visible gap.
**Fix:** Add `mp` and `mk` to `_read_raw_input()`, add MP/MK entries to both character movesets.

---

### P2-001: Standing LK Produces Phantom Attack

**Severity:** P2 (Minor)
**Location:** `resources/movesets/kael_moveset.tres`, `resources/movesets/rhena_moveset.tres`
**Description:** Both movesets define LK only as a crouching normal (`requires_crouch = true`). `FighterMoveset.get_normal("lk", false)` returns null. FighterController skips it, but `idle_state.gd:_any_attack_pressed()` still detects the button and transitions to attack with empty args → default 3/3/8 frame animation with no MoveData.
**Reproduction:** Press J (LK) while standing → 14-frame animation plays with no damage and no visual feedback.
**Fix:** Add standing LK entries to both movesets, or filter idle_state transitions through FighterController.

---

### P2-002: Duplicate ComboTracker Instances

**Severity:** P2 (Minor)
**Location:** `project.godot` line 27, `scripts/fight_scene.gd` lines 78-85
**Description:** ComboTracker is registered as an autoload singleton AND manually instantiated as a scene child in fight_scene.gd. Both connect to `EventBus.hit_landed`, causing duplicate signal processing. `combo_updated` and `combo_ended` fire twice per event.
**Fix:** Remove either the autoload registration or the manual instantiation. Since fight_scene.gd references the autoload via `ComboTracker.get_combo_count()`, remove the local instantiation.

---

### P2-003: AI Never Uses Special Moves

**Severity:** P2 (Minor — acceptable for Sprint 0)
**Location:** `scripts/fighters/ai_controller.gd`
**Description:** AI only injects basic buttons (`lp`, `hp`, `lk`, `hk`) and never performs motion inputs. It cannot execute QCF, DP, or any special move. This limits the AI to normals and throws.
**Fix:** Add QCF/DP motion injection sequences to the AI decision tree for higher-aggression moments.

---

### P2-004: Triple K.O. Announcement

**Severity:** P2 (Cosmetic)
**Location:** Multiple files
**Description:** When a fighter is KO'd, "K.O.!" is announced up to 3 times:
1. `fight_hud._on_fighter_ko` → announces "K.O.!"
2. `round_manager._on_fighter_ko` → `EventBus.announce.emit("K.O.!")`
3. `ko_state.gd` → after 120 frames, `EventBus.announce.emit("K.O.!")` again

The announcer text overwrites each time, so it's not visually noticeable, but it resets the animation timer and fires redundant audio cues.
**Fix:** Remove the announce from ko_state.gd (RoundManager already handles it).

---

## Balance Observations

### Kael vs Rhena Frame Data Comparison

| Move | Kael (Startup/Active/Recovery/Dmg) | Rhena (Startup/Active/Recovery/Dmg) | Delta |
|------|-------------------------------------|--------------------------------------|-------|
| St.LP | 4/2/6 = 12f, 30 dmg | 4/2/6 = 12f, 30 dmg | Identical |
| St.HP | 12/4/16 = 32f, 100 dmg | 12/5/18 = 35f, 110 dmg | Rhena +10 dmg, +3f total |
| Cr.LK | 4/3/7 = 14f, 30 dmg | 4/3/7 = 14f, 35 dmg | Rhena +5 dmg |
| St.HK | 14/4/18 = 36f, 110 dmg | 14/5/20 = 39f, 120 dmg | Rhena +10 dmg, +3f total |
| QCF Special | 18/6/12 = 36f, 70 dmg (Ember Shot) | 14/5/12 = 31f, 80 dmg (Blaze Rush) | Rhena 5f faster, +10 dmg |
| DP Special | 5/8/22 = 35f, 120 dmg (Rising Cinder) | 6/6/24 = 36f, 130 dmg (Flashpoint) | Kael 1f faster, Rhena +10 dmg |

### Frame Advantage Analysis (first-active-frame hit)

| Move | Kael on Hit | Kael on Block | Rhena on Hit | Rhena on Block |
|------|-------------|---------------|--------------|----------------|
| St.LP | +5 | +1 | +5 | +1 |
| St.HP | +3 | -3 | +4 | -1 |
| St.HK | +1 | -5 | +4 | -1 |
| QCF | +4 (Ember Shot) | +1 | +6 (Blaze Rush) | +2 |
| DP | +2 (Rising Cinder) | -11 | +0 (Flashpoint) | -12 |

### Balance Assessment

**Overall: Slightly Rhena-favored but structurally sound.**

1. **Rhena's normals outperform Kael's in raw damage** (+5 to +10 per move) with only marginally longer recovery (+2-3 frames). For a rushdown archetype, this is correct — she should reward aggression. But the Rhena-favored frame advantage on HP (+4 vs +3) and HK (+4 vs +1) is notable.

2. **Kael's zoner identity is underserved.** Ember Shot (QCF+LP, 18f startup) is his only spacing tool, but it has no projectile behavior — it's melee-range with no hitbox geometry anyway. For Kael to fulfill "balanced shoto" he needs a functional projectile. Currently he's just a slower Rhena.

3. **Walk speed differentiation is good.** Rhena is 10% faster (220/187 vs 200/170), reinforcing rushdown. Kael's slower back-walk (170) fits a character who wants to hold ground.

4. **DPS at 1000 HP.** LP spam: 150 dmg/sec for both. Optimal HP usage: Kael 187.5, Rhena 188.6. At these rates, a pure-damage KO takes ~5-6 seconds of constant hitting. With proration floor at 40%, combo damage drops significantly after hit 3. This creates healthy round pacing (expect 20-40 second rounds with blocking/movement).

5. **Combo proration math is correct.** [1.0, 0.8, 0.65, 0.5, 0.4] with floor at index 4. A 5-hit Kael LP combo: 30 + 24 + 19.5 + 15 + 12 = 100.5 damage (vs. 150 unscaled). 33% damage reduction — standard for fighting games.

6. **Throw at 120 damage is strong.** It's higher than any normal and represents 12% of max HP. Combined with 70px range, 5f startup, and throw-tech option, throws are a meaningful threat. Good.

### Specific Tuning Recommendations

| Parameter | Current | Recommended | Reason |
|-----------|---------|-------------|--------|
| Kael St.HP recovery | 16f | 14f | Give Kael better frame advantage (+5 on hit) to compensate for lower damage |
| Kael Ember Shot startup | 18f | 14f | Match Blaze Rush speed — Kael's zoner tool shouldn't be slower than Rhena's rush tool |
| Rhena St.HK on-block | -1 | -4 | Currently too safe for 120-damage heavy; should be punishable |
| Rhena Blaze Rush on-block | +2 | -2 | A rushdown special that's +2 on block is oppressive; make it risky |
| Timer draw resolution | None | Award to higher-HP player; true draw = P1 advantage | Prevents infinite loop (P1-002) |

---

## Feel Assessment

### Input Responsiveness: 8/10
- 8-frame buffer (133ms) is generous for casuals, tight enough for pros — **industry standard**
- SOCD resolution correct (L+R=neutral, U+D=up priority)
- Motion detection with 15-frame window and proper priority (DP > QCF) is solid
- Button consume logic prevents double execution
- Only dock: no dash/run mechanic limits the burst-movement feel

### Attack Feel: 4/10 (currently broken)
- Frame data structure is excellent: startup/active/recovery windows are properly implemented
- Attack phases (startup → active → recovery) transition cleanly in attack_state.gd
- BUT zero hitbox geometry means nothing connects — can't evaluate hit feedback
- VFX/audio would fire on hit_landed (properly wired) — can't be tested
- Hitstun/blockstun frame math is correct in code; numbers are reasonable

### Movement Feel: 7/10
- Walk speed asymmetry (forward > backward) adds defensive commitment — good
- Jump arc at 520 force / 900 gravity ≈ 35 frames (0.58s) is standard and feels purposeful
- Air control at 50% walk speed gives meaningful drift without being floaty
- Jump direction commitment on enter is correct fighting game design
- Landing detection at frame 3+ prevents instant re-jump (good)
- Missing: dash, run, air dash — expected for Sprint 0

### State Machine Robustness: 9/10
- All 9 states have proper enter/exit hooks
- Safety timeouts on every state (120-180 frame caps) prevent stuck states
- KO state is terminal (no exit, only round reset) — correct
- Crouch hurtbox scaling with position offset restore on exit — clean
- Block → idle/crouch transitions respect held input — good feel
- Only concern: crouch_state position offset (+10 then -10) could accumulate if enter/exit called asymmetrically

### VFX/Audio Integration: 8/10
- Hit sparks, block sparks, KO burst all properly wired to EventBus
- Screen shake with exponential decay feels good on paper (2/5/8 intensity tiers)
- KO slow-motion at 0.3× for 0.5s is dramatic
- Hitstun flash (2-frame HDR white) is industry-standard
- Procedural audio with pitch jitter is clever — prevents repetition fatigue
- Ember trail particles scale with meter value — nice visual feedback loop
- 8-player SFX pool with round-robin + steal is robust

---

## Recommendations for Next Sprint

### Must-Fix (before M5)
1. **Add hitbox geometry** to Kael and Rhena scenes — even simple rectangles at AttackOrigin position
2. **Fix take_damage call** in fight_scene.gd to pass all 3 args from hit_data
3. **Sync RoundManager.scores → GameState.scores** (or call GameState.advance_round)
4. **Handle timer draw** — award round to HP leader, or implement sudden death

### Should-Fix
5. Wire MP and MK buttons through the full pipeline (input → buffer → moveset → attacks)
6. Add standing LK to both movesets
7. Remove duplicate ComboTracker instantiation
8. Deduplicate K.O. announcements
9. Implement Kael's Ember Shot as a projectile (not melee) to differentiate from Rhena

### Nice-to-Have
10. Forward dash (double-tap forward) for both characters
11. AI special move execution
12. Cancel routes between normals (target combos)
13. Air normals during jump state

---

## Test Scene Inventory

9 test scenes verified present:
- `test_audiomanager.tscn` — AudioManager autoload
- `test_bench.tscn` — general benchmark
- `test_eventbus.tscn` — EventBus signal wiring
- `test_gamestate.tscn` — GameState mutations
- `test_index.tscn` — test menu/index
- `test_inputbuffer.tscn` — InputBuffer detection
- `test_roundmanager.tscn` — RoundManager lifecycle
- `test_scenemanager.tscn` — SceneManager transitions
- `test_vfxmanager.tscn` — VFXManager effects

**Gap:** No test scene for hitbox/hurtbox collision, combo proration, or AI behavior. These are the areas where P0 bugs live.

---

*Ackbar out. The trap is set — fix the hitboxes and the take_damage crash will spring. Fix both and this prototype ships clean.*
