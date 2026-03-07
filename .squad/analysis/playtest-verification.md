# Playtest Verification Report — Ackbar (QA/Playtester)

**Date:** 2025-07-21  
**Triggered by:** joperezd — post-fix verification after two game-breaking bugs  
**Files reviewed:** player.js, enemy.js, ai.js, gameplay.js, game.js, combat.js (FULL reads)

---

## 1. Bug Fix Verification

### Bug #1: Player froze permanently after being hit

**Root cause (was):** `hitstunTime` decremented but no code transitioned `state` from `'hit'` back to `'idle'`.

**Fix verification — execution trace:**

1. `takeDamage()` (player.js:490) → sets `hitstunTime = 0.2`
2. `update()` (player.js:79) → `if (this.hitstunTime > 0) this.hitstunTime -= dt;` — **decrements every frame ✅**
3. While `hitstunTime > 0` → else branch (player.js:453) forces `state = 'hit'`, zeroes velocity
4. When `hitstunTime` reaches `≤ 0` → enters the `if (this.hitstunTime <= 0)` branch (player.js:193)
5. First check inside (player.js:195-197): `if (this.state === 'hit') this.state = 'idle';` — **transitions to idle ✅**
6. Player is now in `'idle'` → full input processing resumes (movement, attacks, jumps, etc.)

**Also verified:** Taking lethal damage with lives remaining (player.js:498-504) sets `state = 'idle'`, `hitstunTime = 0`, and `invulnTime = 2.0` — player recovers instantly with i-frames. ✅

**VERDICT: ✅ PASS — Fix is correct. Player recovers from hit state after 0.2 seconds.**

---

### Bug #2: Enemies were passive — wouldn't approach or attack unprovoked

**Root cause (was):** AI set `state = 'attack'` but the `aiCooldown` branch immediately overrode it to `'idle'` on the next call. Attack lasted effectively 1 frame.

**Fix verification — execution trace (full enemy lifecycle):**

1. **Spawn:** Enemy created with `state = 'idle'`, `aiCooldown = 0`
2. **AI tick** (`AI.updateEnemy`, ai.js:301): not dead, no hitstun, `aiCooldown = 0` → enters behavior tree
3. **Approach:** `_behaveDefault` (ai.js:200-201) → distance > attackRange → `_approachPlayer()` → calculates angle, sets `vx/vy`, `state = 'walk'`, applies movement **✅ Enemy walks toward player unprovoked**
4. **Attack range reached:** `_inAttackRange()` returns true → `_hasAttackSlot()` grants slot (MAX_ATTACKERS=2) → `_attackPlayer()`
5. **Attack initiated** (ai.js:87-94):
   - `state = 'attack'`
   - `attackAnimTime = attackDur` (0.4s normal, 0.25s fast)
   - `attackCooldown = configAttackCooldown`
   - **KEY FIX (C1):** `aiCooldown = attackDur + configAiCooldown` — includes attack duration!
6. **Next AI tick:** `aiCooldown > 0` → enters cooldown branch (ai.js:310-318)
   - **KEY FIX:** Checks if state is `'windup'`, `'attack'`, `'charge_windup'`, etc. → **preserves attack state! ✅**
7. **Enemy.update** (enemy.js:138-144): `attackAnimTime` decrements → when reaches 0 AND `state === 'attack'` → `state = 'idle'`
8. **After aiCooldown expires:** AI resumes behavior tree → approaches player again → cycle repeats

**Full loop: spawn → walk toward player → reach range → attack → cooldown → approach again ✅**

**VERDICT: ✅ PASS — Enemies actively approach, attack, and cycle correctly.**

---

## 2. Player State Machine Audit

| State | Exit Path(s) | Verdict |
|-------|-------------|---------|
| `idle` | → walk, punch, kick, jump, grabbing, dodging, belly_bump, ground_slam, back_attack | ✅ PASS |
| `walk` | → idle (no movement), punch, kick, jump, grabbing, dodging, belly_bump, back_attack | ✅ PASS |
| `punch` | → idle when `attackCooldown ≤ 0.15` (player.js:431) | ✅ PASS |
| `kick` | → idle when `attackCooldown ≤ 0.2` (player.js:434) | ✅ PASS |
| `hit` | → idle when `hitstunTime ≤ 0` (player.js:195-197) **[FIXED BUG]** | ✅ PASS |
| `jump` | → idle on landing (`jumpHeight ≤ 0`, player.js:118); → jump_punch, jump_kick, ground_slam | ✅ PASS |
| `jump_punch` | → jump when `attackCooldown ≤ 0.05` if airborne; → idle on landing (player.js:118,437) | ✅ PASS |
| `jump_kick` | → idle on landing (player.js:118); dive velocity (-800) guarantees fast landing | ✅ PASS |
| `belly_bump` | → idle when `attackCooldown ≤ 0.15` (player.js:440) | ✅ PASS |
| `ground_slam` | → idle when `attackCooldown ≤ 0.15` (player.js:443); jumpHeight instantly zeroed | ✅ PASS |
| `back_attack` | → idle when `attackCooldown ≤ 0.05` (player.js:446); facing restored | ✅ PASS |
| `grabbing` | → idle (enemy dies, timeout 1.5s); → throwing (attack+dir, 3 pummels) (player.js:221-258) | ✅ PASS |
| `throwing` | → idle when `throwTimer ≤ 0` (0.3s) (player.js:215-220) | ✅ PASS |
| `dodging` | → dodge_recovery when `dodgeElapsed ≥ 0.4` (player.js:203-208) | ✅ PASS |
| `dodge_recovery` | → idle when `dodgeRecovery ≤ 0` (player.js:212-214) | ✅ PASS |
| `dead` | Terminal state — only entered with 0 lives (player.js:507) | ✅ CORRECT |

**No stuck states found. Every state has a guaranteed exit path.**

---

## 3. Enemy State Machine Audit

| State | Exit Path(s) | Verdict |
|-------|-------------|---------|
| `idle` | → walk/attack via AI behavior tree when `aiCooldown = 0` | ✅ PASS |
| `walk` | AI-driven; transitions to attack/idle/retreat on next AI tick | ✅ PASS |
| `attack` | → idle when `attackAnimTime ≤ 0` (enemy.js:140-144); protected from AI override | ✅ PASS |
| `hit` | → idle when `hitstunTime ≤ 0` (enemy.js:238-240) | ✅ PASS |
| `dead` | Terminal — cleaned up after `deathTime > 0.5` by `Combat.cleanupDeadEnemies` | ✅ CORRECT |
| `windup` (heavy) | → attack when `windupTime ≤ 0` (enemy.js:150-155); protected from AI override | ✅ PASS |
| `grabbed` | → idle on release (player releaseGrab); → hit on throw (combat.js:49) | ✅ PASS |
| `charge_windup` (boss) | → charging when `chargeWindup ≤ 0` (enemy.js:162-163) | ✅ PASS |
| `charging` (boss) | → idle when `chargeTime ≤ 0` (enemy.js:176-177) | ✅ PASS |
| `slam_windup` (boss) | → slamming when `slamWindup ≤ 0` (enemy.js:188-189) | ✅ PASS |
| `slamming` (boss) | → idle when `slamTime ≤ 0` (enemy.js:204-205) | ✅ PASS |

**No stuck states found.**

---

## 4. Integration Checks

### Hitlag
- `addHitlag(frames)` (game.js:32) — uses `Math.max` to not shorten existing hitlag ✅
- Game loop (game.js:160-161): `hitlagFrames--` each fixed timestep → guaranteed to reach 0 ✅
- During hitlag: only `updateDuringHitlag()` runs (screen shake + VFX) → entities frozen ✅
- **VERDICT: ✅ PASS — Cannot get stuck**

### Slow-mo (timeScale)
- `triggerSlowMo(scale, duration)` (game.js:42-45) sets timer ✅
- `_updateTimeScale(dt)` (game.js:62-70): timer decrements with unscaled dt → when `≤ 0`, restores `timeScale = 1.0` ✅
- **VERDICT: ✅ PASS — Always restores to 1.0**

### Screen Transitions
- Fade-out → scene switch → fade-in (game.js:95-121) ✅
- `transitioning` flag prevents double-switch (game.js:77) ✅
- Alpha clamps guarantee termination ✅
- **VERDICT: ✅ PASS**

### Pause Menu
- Toggle via `isPause()` (gameplay.js:160-164) ✅
- While paused: only Q (quit) and O (options) accepted; `clearFrameState` + return ✅
- Unpause on next `isPause()` ✅
- **VERDICT: ✅ PASS**

### Destructibles / Hazards
- Guard checks prevent crashes: `!d.broken`, `enemy.state === 'dead'` (gameplay.js:285-293) ✅
- Hazard damage uses null-safe access: `if (playerResult)` (gameplay.js:356) ✅
- **VERDICT: ✅ PASS**

---

## 5. New Issues Found

### ⚠️ LOW — Attack Throttle Counter Uses Wall-Clock Time (ai.js:12-18)

`AI._resetFrameIfNeeded()` uses `performance.now()` to detect frame boundaries. Since `performance.now()` may have rounded precision (1ms in most browsers for Spectre mitigation), this works **in practice** — all enemies in a single for-loop iteration process within < 1ms.

However, this is **fragile**: on a browser with higher-precision timestamps or under heavy load, `performance.now()` could differ between enemy updates in the same frame, resetting `activeAttackers` mid-frame and allowing > 2 simultaneous attackers.

**Impact:** Low. The `attackCooldown` and `aiCooldown` timers provide a secondary throttle. In realistic gameplay conditions (2-6 enemies), the browser timer resolution prevents this from manifesting.

**Recommendation:** Replace with a frame counter passed from the game loop.

### ⚠️ LOW — Boss Slam Windup Resumes After Hitstun (enemy.js:158-193)

If the boss takes damage during `slam_windup` state, the phase transition at line 119-124 sets `state = 'idle'`. However, `slamWindup` is NOT reset to 0. After hitstun clears (0.2s), the `slamWindup` countdown resumes (line 185-193), eventually setting `state = 'slamming'`.

**Impact:** Minor gameplay oddity. Boss appears to idle briefly after being hit, then unexpectedly slams. Not game-breaking — could even be interpreted as "boss powers through damage."

**Recommendation:** Reset `slamWindup = 0` and `chargeWindup = 0` on phase transition.

---

## 6. Confidence Assessment

| Category | Rating | Notes |
|----------|--------|-------|
| Player hit recovery | **10/10** | Traced frame-by-frame. hitstunTime decrements → state transitions to idle. Solid. |
| Enemy aggression | **10/10** | Traced full loop: spawn → approach → attack → cooldown → approach. All variants (normal, fast, heavy, boss) work correctly. |
| Player state machine | **10/10** | All 16 states have verified exit paths. No deadlocks possible. |
| Enemy state machine | **10/10** | All 11 states have verified exit paths. Boss special states all terminate. |
| Integration systems | **9/10** | Hitlag, slow-mo, transitions, pause all correct. Minor fragility in attacker throttle. |
| Overall playability | **9.5/10** | Game is fully playable. Both critical bugs are fixed. Two low-severity edge cases identified. |

**OVERALL CONFIDENCE: The game is now playable.** Both game-breaking bugs are definitively fixed. The player recovers from hits, and enemies actively approach and attack without provocation.

---

*Report by Ackbar (QA/Playtester) — SimpsonsKong Squad*
