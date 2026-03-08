# SKILL: Game QA & Testing

Quality assurance patterns specific to games. The core lesson: reading code is not testing. You must trace execution paths frame-by-frame, play the game, and verify that every state machine actually exits.

---
name: "game-qa-testing"
description: "QA patterns for games — execution tracing, state machine audits, playtest protocols, bug severity, regression testing"
domain: "testing"
confidence: "low"
source: "earned — extracted from firstPunch QA process (Ackbar's self-assessment, missed bugs, quality excellence proposal)"
---

## When to Use This Skill
- Performing QA on a game (any genre, any stage)
- Reviewing combat, AI, or state machine code
- Running playtests (structured or ad-hoc)
- Creating regression test suites
- Prioritizing bugs for fix vs. ship-with-known-issues

## When NOT to Use This Skill
- Unit testing pure functions (standard testing practices apply)
- UI/UX testing for non-game applications
- Performance testing (see canvas-2d-optimization skill)

---

## Core Patterns

### 1. Trace Execution, Don't Just Read Code

**THE methodology lesson.** Ackbar read every file in the codebase and reported "10/10 confidence" — then missed two game-breaking bugs. Reading `if (state === 'hit')` looks correct. Tracing frame-by-frame reveals the exit condition is never reached.

```
❌ Reading (what most reviewers do):
   "I see takeDamage() sets state to 'hit'. I see hitstunTime decrements.
    Looks correct." → MISSED: no code transitions 'hit' back to 'idle'

✅ Tracing (what catches bugs):
   Frame 0: Player in 'idle', HP=100
   Frame 1: Enemy attacks → takeDamage(10) → state='hit', hitstunTime=0.3
   Frame 2: update(0.016) → hitstunTime=0.284... state still 'hit'
   ...
   Frame 19: hitstunTime ≈ 0 → WHERE IS THE TRANSITION? → 🐛 BUG FOUND
```

**Rule:** For every state machine, trace at least one complete path from entry to exit. If you can't reach exit in <60 frames, the state has a bug.

### 2. State Machine Audit Checklist

For every entity in the game, build this table:

```
┌──────────┬─────────────────┬───────────────────┬────────────────┬──────────┐
│ State    │ Entry Condition │ Per-Frame Behavior│ Exit Path(s)   │ Timeout  │
├──────────┼─────────────────┼───────────────────┼────────────────┼──────────┤
│ idle     │ Default         │ Accept input      │ walk, attack.. │ None (∞) │
│ attack   │ Attack pressed  │ Run phases        │ idle (timer)   │ 2.0s     │
│ hit      │ takeDamage()    │ Decrement timer   │ idle (timer≤0) │ 1.0s     │
│ ...      │ ...             │ ...               │ ...            │ ...      │
└──────────┴─────────────────┴───────────────────┴────────────────┴──────────┘
```

**What to look for:**
- Empty "Exit Path" column → **dead-end state** (CRITICAL bug)
- No timeout for timed states → potential infinite state
- Exit condition references a timer that doesn't decrement → unreachable exit
- Two systems independently set the state → potential override conflict

### 3. Frame-by-Frame Mental Simulation

Pick the 5 most critical scenarios and trace them mentally at the frame level:

| Scenario | Start State | Trigger | Expected End State | Frames |
|----------|------------|---------|-------------------|--------|
| Player takes damage | idle | enemy attack lands | hit → idle | ~18f |
| Player attacks | idle | attack input | attack (startup→active→recovery) → idle | ~15f |
| Enemy attacks player | enemy idle | AI decision + range check | enemy windup → attack → idle | ~20f |
| Player dies | any | HP ≤ 0 | dead → respawn or game over | ~60f |
| Boss phase transition | boss phase 1 | HP ≤ 66% | invuln → phase 2 idle | ~120f |

**For each scenario, verify:**
- The trigger actually fires (distance threshold met, timer reached zero)
- Each intermediate state transitions correctly
- The entity reaches a stable end state (not stuck mid-animation)
- No other system overrides the state mid-transition

### 4. The "Play It, Don't Review It" Principle

Code review finds syntax bugs. Playing finds game-feel bugs. Both are necessary; neither is sufficient alone.

**Testing layers (all required):**

| Layer | Method | Catches | Time |
|-------|--------|---------|------|
| **Code trace** | Frame-by-frame mental sim | Dead-end states, missing transitions | 5-10 min/entity |
| **Smoke test** | Launch game, play 30 seconds | Crashes, major regressions | 2 min |
| **Feature test** | Test specific new feature | Feature doesn't work as designed | 5 min |
| **Regression test** | Run regression checklist | Broken existing features | 5 min |
| **Adversarial test** | Try to break the game | Edge cases, exploits | 10-15 min |
| **Full playtest** | Play full level naturally | Balance, pacing, feel | 10 min |

**Adversarial playtest tactics:**
- Spam attack during knockback (should be blocked)
- Jump at screen edges (no clipping)
- Pause mid-attack (state valid on resume)
- Die while attacking (hitbox should clear)
- Hit during invulnerability (should be ignored)
- Multi-enemy death on same frame (all counted)
- Grab + enemy dies simultaneously (no crash)

### 5. Bug Severity Matrix

| Severity | Definition | Ship? | Examples |
|----------|-----------|-------|----------|
| 🔴 **CRITICAL** | Game unplayable or player permanently stuck | ❌ NEVER | Player freeze, infinite loop, crash on start, enemies never attack |
| 🟠 **HIGH** | Core mechanic broken, major feature fails | ❌ FIX FIRST | Combo system broken, hitboxes wrong, audio crashes game, score doesn't save |
| 🟡 **MEDIUM** | Feature partially works, workaround exists | ⚠️ SHIP WITH NOTES | Dead code paths, unused particles, missing HUD element, minor VFX glitch |
| 🟢 **LOW** | Polish issue, minor visual/audio imperfection | ✅ SHIP | Slight hitbox mismatch, timer precision edge case, font size slightly off |

**Triage rules:**
- CRITICAL + HIGH = must fix before ship. No exceptions.
- MEDIUM = document as known issue. Fix in next pass if time allows.
- LOW = log for future polish. Don't block ship.

**Confidence calibration:** After the source IPKong "10/10 confidence" miss, never rate confidence above 8/10 unless you have:
1. Completed the state machine audit table for ALL entities
2. Traced at least 5 critical scenarios frame-by-frame
3. Run the adversarial playtest checklist
4. Played the full level start to finish

### 6. Regression Testing After Every Combat Change

Combat systems are tightly coupled. Changing one attack's frame data can break combos, enemy responses, and score calculations.

**10-item regression checklist (~5 minutes):**

```
□ 1. Light attack string completes (3-hit combo finishes)
□ 2. Jump attack lands and transitions to idle on landing
□ 3. Player takes damage and recovers (not stuck in 'hit')
□ 4. Invulnerability frames active after damage (no double-hit)
□ 5. Enemy approaches and attacks (not passive, not instant)
□ 6. Combo counter increments on hit, resets on timeout
□ 7. Player can't attack during hitstun (guard condition works)
□ 8. Score increments on enemy kill
□ 9. Wave progresses after all enemies defeated
□ 10. Game doesn't crash during 30-second play session
```

**When to run it:**
- After ANY change to player.js, enemy.js, combat.js, or ai.js
- After integration passes that wire new systems
- Before marking any combat-related task as "done"
- Before shipping

### 7. Absence-of-Code Bug Detection

The hardest bugs to find are missing code, not broken code. You're looking for something that doesn't exist.

**Pattern:** Check what SHOULD happen, not what DOES happen:
```
For each state transition in the design doc:
  → Is there code implementing this transition?
  → If yes, does it actually execute (is it reachable)?
  → If no, that's the bug.
```

**firstPunch examples of absence bugs:**
- Player freeze: `'hit' → 'idle'` transition was designed but never coded
- Enemy passivity: attack duration logic existed but was overridden by AI before executing
- Audio: 8 methods implemented but 0 callers (methods exist, wiring doesn't)

**Technique:** Compare the state transition table against the actual code. Every row in the table should map to a line of code. Missing mappings are potential CRITICAL bugs.

---

## Anti-Patterns

1. **Reading ≠ Testing** — Reading `if (state === 'hit')` looks correct. Only frame-by-frame tracing reveals the exit is unreachable. Read for understanding, trace for verification.

2. **Coverage confidence** — "I read every file" does not mean "I found every bug." File coverage ≠ path coverage. Focus on tracing critical paths, not scanning files.

3. **Testing the happy path only** — Testing "player attacks enemy, enemy dies" misses the bugs that occur on edge cases (attack during hitstun, die while grabbing, jump at boundaries).

4. **Subjective-only assessment** — "Combat feels good" is not QA. Measure DPS, frame data, and state durations. Quantitative findings plus subjective feel.

5. **False positive over-reporting** — Reporting bugs that don't actually exist wastes fix time and reduces trust. Verify bugs by reproducing them before reporting. (firstPunch: C5 bug was retracted as false positive.)

6. **No regression after combat changes** — Combat is coupled. Changing jab frame data can break combo timing. Run the 10-item checklist after every change.

7. **Overconfidence after review** — Never rate confidence above 8/10 without completing state machine audit + adversarial playtest + full level playthrough.

---

## Checklist

### Before Reporting "QA Complete":

- [ ] State machine audit table built for ALL entities (player, each enemy type, boss)
- [ ] Every state has a documented exit path (no empty cells)
- [ ] 5+ critical scenarios traced frame-by-frame
- [ ] Adversarial playtest completed (spam, edge cases, simultaneous events)
- [ ] Full level played start to finish (no crashes, correct pacing)
- [ ] 10-item regression checklist passed
- [ ] Bug severity matrix applied (CRITICAL/HIGH must be fixed)
- [ ] Quantitative data collected (DPS, frame timings, entity counts)
- [ ] Absence-of-code check completed (design doc → code mapping)
- [ ] Confidence rated honestly (max 8/10 without full audit completion)
