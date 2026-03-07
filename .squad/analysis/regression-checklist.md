# Regression Test Checklist - Combat & Movement

QA playtest checklist to run after every combat system change. Each test verifies critical edge cases that could cause state corruption, clipping, or unexpected behavior.

---

## 1. Attack During Knockback

**Expected Behavior:** Player should NOT be able to attack while being knocked back. Attack inputs should be blocked until knockback completes.

**How to Test:**
1. Let an enemy hit the player
2. While the player is in knockback state, immediately press attack button
3. Observe if attack animation plays or is blocked

**Pass Criteria:**
- ✅ Player cannot initiate attack during knockback
- ✅ Attack button input is ignored/buffered until knockback ends
- ✅ No state corruption (player remains in knockback state)

**Fail Criteria:**
- ❌ Player animation breaks (flickering between states)
- ❌ Attack plays while knockback active
- ❌ Player is not actually knocked back (immunity issue)

---

## 2. Jump at Screen Edge

**Expected Behavior:** Player should not clip through camera boundary when jumping near the edge.

**How to Test:**
1. Move player to the far right edge of the level
2. Jump upward or perform jump kick
3. Watch collision with camera boundary

**Pass Criteria:**
- ✅ Player cannot move past rightmost camera lock position
- ✅ Y position changes normally during jump
- ✅ Jump trajectory is not affected

**Fail Criteria:**
- ❌ Player clips through right edge
- ❌ Camera constraint only applies to grounded movement
- ❌ Jump arc is warped

---

## 3. Pause During Attack Animation

**Expected Behavior:** If game pauses mid-attack, state should remain valid when unpausing.

**How to Test:**
1. Player starts punch/kick attack
2. During the attack animation, open pause menu (if implemented)
3. Resume game
4. Check if attack completes or state is corrupted

**Pass Criteria:**
- ✅ Attack resumes and completes normally
- ✅ Hitbox remains valid
- ✅ Combo counter continues properly

**Fail Criteria:**
- ❌ Attack animation resets or loops
- ❌ Player locks in attack state forever
- ❌ Hitbox disappears or becomes invalid

---

## 4. Die While Attacking

**Expected Behavior:** Death should override attack state immediately. Player should not deal damage after becoming dead.

**How to Test:**
1. Player is attacking an enemy
2. While attack is animating, take a hit that kills the player
3. Verify that the attack hitbox does not persist

**Pass Criteria:**
- ✅ Player transitions to dead state immediately
- ✅ Attack hitbox is cleared (enemy not hit if attack wasn't active)
- ✅ No lingering damage from the incomplete attack

**Fail Criteria:**
- ❌ Death is delayed until attack animation completes
- ❌ Hitbox persists after death
- ❌ Player can still hit enemies while dead

---

## 5. Enemy Attack During Hitstun

**Expected Behavior:** Enemies CAN attack during player hitstun (this is by design). Invulnerability frames protect the player.

**How to Test:**
1. Hit an enemy (player gets hitstun)
2. While player is hitstun, let other enemies attack
3. Check if player takes damage or is protected

**Pass Criteria:**
- ✅ Enemies can initiate attacks during player hitstun
- ✅ Invulnerability frames prevent damage
- ✅ Hitstun duration is consistent

**Fail Criteria:**
- ❌ Enemies attack but player takes no invuln frames
- ❌ Invuln frames don't protect properly
- ❌ Hitstun state is cleared prematurely

---

## 6. Walk Into Camera Lock Boundary While Jumping

**Expected Behavior:** Y position constraint should not apply mid-air. Only X constraint (camera lock) matters.

**How to Test:**
1. Move toward right edge while jumping
2. Observe if player stops falling or is constrained vertically
3. Land after jump

**Pass Criteria:**
- ✅ Player can move through horizontal constraint while jumping
- ✅ Gravity applies normally during jump
- ✅ Y position unrestricted mid-air

**Fail Criteria:**
- ❌ Player stops falling mid-jump (Y constraint active)
- ❌ Jump height is reduced near boundary
- ❌ Landing position is wrong

---

## 7. Combo Timer Across Wave Boundaries

**Expected Behavior:** Combo should reset when the current wave clears (all enemies dead).

**How to Test:**
1. Build combo to 3+ hits
2. Defeat last enemy in wave
3. Check combo counter when next wave spawns

**Pass Criteria:**
- ✅ Combo resets to 0 when wave clears
- ✅ Combo timer does not persist across waves
- ✅ First hit of new wave starts fresh combo

**Fail Criteria:**
- ❌ Combo count carries over to new wave
- ❌ Combo timer continues running during wave transition
- ❌ Combo multiplier affects damage in new wave incorrectly

---

## 8. Multiple Enemies Dying Same Frame

**Expected Behavior:** Score should count correctly when multiple enemies die simultaneously.

**How to Test:**
1. Position player attack to hit 2+ enemies simultaneously
2. Perform finisher (punch-punch-kick combo) or area attack
3. Check score increment

**Pass Criteria:**
- ✅ Score increases for each enemy hit (additive)
- ✅ Combo count increases for each hit
- ✅ Screen shake magnitude increases with hit count

**Fail Criteria:**
- ❌ Score only counts one enemy
- ❌ Combo doesn't increment for all hits
- ❌ Only one enemy death is registered

---

## 9. Jump Kick Into Ground

**Expected Behavior:** After jump kick lands, player should return to idle/fall state cleanly. Landing detection should work.

**How to Test:**
1. Perform jump kick attack
2. Let kick connect (or miss)
3. Land on ground after jump
4. Verify state transitions to idle

**Pass Criteria:**
- ✅ Player returns to grounded state after kick lands
- ✅ Can move or attack immediately after landing
- ✅ No animation loop or state lock

**Fail Criteria:**
- ❌ Player stays in kick state after landing
- ❌ Stuck in mid-air (Y velocity not reset)
- ❌ Landing detection fails

---

## 10. High Score Save During Level Complete Transition

**Expected Behavior:** High score should persist and be saved when level completes, even during state transitions.

**How to Test:**
1. Play level and get a high score
2. Defeat final enemy/clear level
3. Close game or navigate away
4. Reopen game and verify high score is still there

**Pass Criteria:**
- ✅ High score is saved to storage (localStorage/file)
- ✅ Score persists across game sessions
- ✅ New score > old high score triggers update

**Fail Criteria:**
- ❌ Score only saved if you explicitly visit score screen
- ❌ High score lost on game close
- ❌ Level complete transition clears score before save

---

## Test Execution Notes

- Run tests in order after each combat/state system change
- Use debug overlay (` key) to verify entity states and frame times
- Document any failures with reproduction steps
- If a test fails, revert last change and re-test
- Parallel test runs are acceptable if using separate enemies/scenarios
