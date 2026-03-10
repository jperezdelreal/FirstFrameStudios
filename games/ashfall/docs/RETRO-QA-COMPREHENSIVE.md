# Ashfall — Comprehensive QA Retrospective

**Author:** Ackbar (QA Lead)  
**Date:** 2026-03-28  
**Scope:** Sprints 0–2 (ashfall-v0.1.0 → v0.3.0)  
**Method:** Full codebase analysis, git forensics, bug catalog review, test infrastructure audit  
**Verdict:** Architecture is excellent. Testing was almost entirely absent. We shipped bugs we should have caught in minutes.

---

## PART I — QUALITY METRICS

### Bug Summary Across All Sprints

| Metric | Value |
|--------|-------|
| Total bugs cataloged | **35** |
| P0 (blocking) | 7 (20%) |
| P1 (high) | 9 (26%) |
| P2 (medium) | 10 (29%) |
| Unrated/Info | 9 (26%) |
| Bugs shipped from Sprint 0 → found Sprint 1 | **13** |
| Integration gate failures | 3 |
| Godot 4.6 type safety bugs | 9 |
| Fix attempts for character select input | **6 commits across 3 PRs** |
| Time to fix character select input | **~4 hours** |
| Total P0/P1 in final v0.3.0 build | **0** |

### Bug Discovery Method

| Method | Bugs Found | % of Total | Cost |
|--------|-----------|-----------|------|
| Playtesting (Ackbar, M4 gate) | 10 | 29% | Late discovery, high fix cost |
| Retrospective analysis (RETRO-M1-M2) | 13 | 37% | Very late — post-sprint |
| Developer self-catch (type safety) | 9 | 26% | Proactive, but scattered |
| Integration gate (automated) | 3 | 9% | Correct timing, low coverage |

**Key finding:** **66% of all bugs were found by humans doing manual review**, not by any automated process. Only 9% were caught by automation. This ratio is inverted from where it should be.

### Bug Category Distribution

| Category | Count | % | Worst Bug |
|----------|-------|---|-----------|
| Integration failures | 9 | 26% | AI controller stranded on dead branch for 3 months |
| Type safety (Godot 4.6) | 9 | 26% | Compile errors blocking project load |
| Combat pipeline | 5 | 14% | Empty hitbox geometry — zero attacks dealt damage |
| Input system | 4 | 11% | Character select completely unresponsive in exports |
| Frame data drift | 4 | 11% | 3 conflicting sources of truth for move data |
| Round/match management | 3 | 9% | Timer draw creates infinite round loop |
| Export/platform | 1 | 3% | Tab→space corruption during merge |

---

## PART II — BUG PATTERNS (Fighting Game Specific)

### Pattern 1: "Looks Right, Plays Wrong" — The Empty Hitbox Bug

**The single most damning bug in the project.**

- `Hitboxes` Node2D existed in both fighter scenes
- `attack_state.gd:_activate_hitboxes()` correctly iterated children
- The iteration loop body never executed because **there were no children**
- Every attack animation played perfectly. Zero damage was ever dealt.
- Only throws worked (they bypass hitbox detection)
- Code review passed this. PR review passed this. Nobody pressed Play.

**Why this is a fighting-game-specific problem:** In most genres, "enemy takes no damage" is immediately obvious. In a fighting game with state machines, animation controllers, and frame data pipelines, the attack *looks* like it's working — the startup/active/recovery phases transition, the animation plays, the VFX system is wired. The actual collision detection failure is invisible without runtime testing.

**Impact:** Attacks were non-functional for **24 hours** across 2 sprints until the M4 playtest caught it.

### Pattern 2: Latent Crash Chains — take_damage Signature Mismatch

- `fighter_base.gd` defined `take_damage(amount, knockback, hitstun_frames)` — 3 params
- `fight_scene.gd:_on_hit_landed()` called `take_damage(damage)` — 1 param
- `throw_state.gd` called `take_damage(damage, kb, hitstun)` — 3 params (correct)
- The bug was **invisible** because hitboxes were empty (Pattern 1)
- Fixing the hitbox bug would **immediately trigger a crash** on first hit

**This is a trap pattern.** Fix one bug, spring the next. Fighting games have deep call chains (input → buffer → state → animation → hitbox → collision → damage → hitstun → VFX → audio) where bugs mask each other.

### Pattern 3: Frame Data Drift — Three Sources of Truth

Frame data existed in three places:

| Source | LP Startup | HP Startup | HP Recovery |
|--------|-----------|-----------|-------------|
| GDD.md | 4–5f | 12–14f | 16–22f |
| Base .tres (fighter_base/) | 4f | **10f** ❌ | 18f |
| Kael moveset .tres | 4f | 12f | **16f** |
| Rhena moveset .tres | 4f | 12f | **18f** |

- GDD says HP startup is 12–14f. Base .tres says 10f. Character files say 12f.
- HK recovery: base=22f, Kael=18f, Rhena=20f — all three differ.
- MP/MK startup: base .tres is 1f faster than GDD minimum.
- **Duplicate .tres files** in `fighter_base/` and `attack_state/` contained identical data — changes to one don't propagate.

**Why this matters for fighting games:** 1 frame of startup difference changes combo links, punish windows, and tier lists. Frame data drift is a balance-destroying bug class unique to fighting games.

### Pattern 4: Spec Deviation Compound — 4 Buttons vs 6 Buttons

- GDD specifies 6-button layout: LP/MP/HP/LK/MK/HK
- `project.godot` only mapped 4 attack buttons per player (no MP/MK)
- `input_buffer.gd:_read_raw_input()` only captured LP/HP/LK/HK
- Both character movesets only defined 4 normals + 2 specials
- This deviation existed from Day 1 of Sprint 0 through Sprint 2

**Timeline of awareness:**
- Sprint 0, Day 1: Implemented with 4 buttons
- Sprint 0, Day 3: RETRO-M1-M2.md flagged it as "silent spec deviation"
- Sprint 1, Day 1: Playtest report flagged it as P1-002
- Sprint 2: Medium buttons added to project.godot but `input_buffer.gd` still only captures 4
- **Net result:** 3 sprints, 3 separate flags, issue still not fully resolved

### Pattern 5: State Machine Edge Cases

- **Timer draw infinite loop:** Equal HP at timer expiry → no winner → round resets → same outcome → infinite loop. With the hitbox bug (no damage dealt), this was the **default game state**.
- **GameState score desync:** `RoundManager.scores` tracked independently from `GameState.scores`. HUD read from GameState (always 0-0). Victory screen read from GameState (always "0 - 0").
- **Triple K.O. announcement:** `fight_hud`, `round_manager`, and `ko_state` all independently announced "K.O!" — resetting the animation timer each time.

### Pattern 6: Editor vs Export Divergence

- Custom `ui_accept`/`ui_cancel` overrides with `physical_keycode:0` worked in editor
- Windows exports rejected the same input — character select was completely unresponsive
- Took **6 fix attempts** across 5 commits and 3 PRs over ~4 hours
- Root cause: `physical_keycode` ≠ `keycode` in Godot's input system; export builds are stricter

---

## PART III — TESTING COVERAGE ANALYSIS

### What Testing Infrastructure Exists

| Layer | Tool | Automated? | Blocks Merge? | Coverage |
|-------|------|-----------|---------------|----------|
| GDScript lint (no `:=` dict, `_physics_process`, return types) | integration-gate.yml | ✅ CI | ✅ Yes | Pattern-based, 3 rules |
| Branch target validation | branch-validation.yml | ✅ CI | ✅ Yes | PR must target main |
| PR body check (issue reference) | pr-body-check.yml | ✅ CI | ⚠️ Warning | Checks for `Closes #N` |
| project.godot hotspot guard | godot-project-guard.yml | ✅ CI | ⚠️ Warning | Checklist on project.godot changes |
| Autoload dependency order | check-autoloads.py | 🔧 Manual/gate | ⚠️ Warning | Topological sort of autoload deps |
| Signal wiring validator | check-signals.py | 🔧 Manual/gate | ⚠️ Warning | Orphaned signal detection |
| Scene integrity checker | check-scenes.py | 🔧 Manual/gate | ⚠️ Warning | Missing scripts, collision layers |
| GDD compliance checker | check-gdd-compliance.py | 🔧 Manual | ❌ No | Spec vs implementation diff |
| Integration gate orchestrator | integration-gate.py | 🔧 Manual | ⚠️ Warn on signals | Runs all validators in sequence |
| Unit tests (EventBus) | test_eventbus.gd | 🎮 In-engine | ❌ No | 5 tests, signal exists + emission |
| Unit tests (GameState) | test_gamestate.gd | 🎮 In-engine | ❌ No | 7 tests, state transitions + ember |
| VFX/Audio test bench | test_bench.gd | 🎮 Interactive | ❌ No | Manual VFX/audio trigger |
| Test index (hub) | test_index.gd | 🎮 Interactive | ❌ No | Links to test scenes |
| Frame data export/import | export/import-frame-data.py | 🔧 Manual | ❌ No | CSV ↔ .tres pipeline |

### What Testing Is MISSING

| Gap | Impact | Would Have Caught |
|-----|--------|-------------------|
| **No runtime game flow test** | The game was never verified to run end-to-end | Empty hitboxes, take_damage crash, score desync, infinite loop |
| **No hitbox/hurtbox collision test** | Combat pipeline untested | P0-001 (empty hitboxes), P0-002 (take_damage crash) |
| **No Windows export test in CI** | Export-only bugs shipped in 3 tagged releases | Character select input failure (6 fix attempts) |
| **No frame data consistency validator** | 3 sources of truth drifted silently | Frame data mismatches, missing medium attacks |
| **No combo/damage pipeline test** | Combo proration, damage scaling never verified | Combo counter has no data source |
| **No edge case test matrix** | Timer draw, equal HP, double KO untested | Infinite round loop (P1-002) |
| **No AI behavior test** | AI never uses special moves, only normals | P2-003 (AI limited to 4 buttons) |
| **No state machine transition test** | State transitions verified by inspection, not automation | Crouch position offset accumulation risk |
| **No signal contract test** | Signals defined without emitters/consumers | 6 orphaned signals (3 integration gate failures) |
| **No regression test suite** | Fixed bugs have no guard against reintroduction | All 35 bugs could recur |
| **No headless Godot test run** | Project load errors only found when someone opens the editor | Godot 4.6 type inference failures |

### Test File Reality Check

The `tests/` directory contains **a single `.gitkeep` file**. All "test" scripts live in `scripts/test/` and are **in-engine scene scripts**, not automated tests. Of the 11 test files:

| File | Type | Assertions | Automated? | CI? |
|------|------|-----------|-----------|-----|
| test_eventbus.gd | Unit test | 5 tests, 20+ assertions | Scene-based (F5 to run) | ❌ |
| test_gamestate.gd | Unit test | 7 tests, 14+ assertions | Scene-based | ❌ |
| test_roundmanager.gd | Stub | TBD | ❌ | ❌ |
| test_inputbuffer.gd | Stub | TBD | ❌ | ❌ |
| test_audiomanager.gd | Stub | TBD | ❌ | ❌ |
| test_vfxmanager.gd | Stub | TBD | ❌ | ❌ |
| test_scenemanager.gd | Stub | TBD | ❌ | ❌ |
| test_bench.gd | Interactive tool | 0 (manual VFX/audio triggers) | ❌ | ❌ |
| test_index.gd | Test hub | 0 (scene loader) | ❌ | ❌ |
| fight_visual_test.gd | Visual PoC | 0 | ❌ | ❌ |
| sprite_poc_test.gd | Visual PoC | 0 | ❌ | ❌ |

**Total automated test assertions that run in CI: 0.**  
**Total test assertions that exist at all: ~34 (EventBus + GameState only).**  
**Systems with zero test coverage:** RoundManager, InputBuffer, AudioManager, VFXManager, SceneManager, FighterBase, AttackState, HitBox, all fighter states, ComboTracker, CameraController, AI Controller.

---

## PART IV — WHAT WORKED IN TESTING

### 1. Integration Gate (Static Analysis) ✅

The Python-based integration gate (`integration-gate.py`) orchestrating 4 validators caught real issues:
- **3 integration gate failures** across Sprint 1 flagged orphaned signals before they caused runtime errors
- `check-autoloads.py` correctly validated autoload dependency ordering
- `check-signals.py` detected 6 orphaned signals that would have caused silent failures
- `check-scenes.py` verified collision layer configuration

**Verdict:** This was the most valuable testing investment. Static analysis caught bugs that code review missed. But it only covers structural correctness, not runtime behavior.

### 2. Structured Playtest Reports ✅

Ackbar's playtest reports were the project's primary quality gate:
- **M4 Gate Report:** Found P0-001 (empty hitboxes), P0-002 (take_damage crash), P1-001 (score desync), P1-002 (infinite loop) — all in one code-level review
- **Sprint 1 Report:** Found P1 frame data discrepancies, verified 41/41 sprite poses, validated VFX/EventBus wiring
- **Sprint 2 Report:** Verified 78 EventBus signal references across 13 files, zero mismatches

**Verdict:** Manual expert analysis caught the most critical bugs. But this doesn't scale — you can't playtest every PR.

### 3. GDScript Standards Document ✅

After Sprint 1's 9 type safety bugs, `GDSCRIPT-STANDARDS.md` codified 16 rules. Result:
- Sprint 1: **10 emergency type safety commits**
- Sprint 2: **0 type safety commits**

**Verdict:** Documented standards + CI enforcement eliminated an entire bug class. The `:=` inference rule and `absf()`/`absi()` convention prevented repeat failures.

### 4. Code Audit as Quality Gate ✅

`SPRINT-1-CODE-AUDIT.md` audited 53 files, found 16 issues (1 critical, 7 warning, 8 info). 70% of files were clean. This established patterns for prevention:
- `_process` vs `_physics_process` inconsistency → lint rule
- Missing `is_instance_valid()` checks → review checklist item
- Unsafe `:=` inference → GDSCRIPT-STANDARDS rule

---

## PART V — WHERE TESTING FAILED

### 1. 🔴 Zero Runtime Testing in CI

No Godot headless test run ever executed in CI. The `generate-test-scenes.py` tool creates test scenes, but:
- No CI workflow runs `godot --headless --script test_runner.gd`
- No test runner aggregates results across test scenes
- Tests require manually pressing F5 in the Godot editor
- The 2 complete test suites (EventBus, GameState) have **never been run in CI**

**Cost:** Every bug that required "open Godot and press Play" was discovered late.

### 2. 🔴 No Combat Pipeline Test

The core game mechanic — "press button → hitbox activates → collides with hurtbox → damage dealt → health decreases" — was **never tested end-to-end**.

A single test asserting "LP deals 30 damage" would have caught:
- P0-001: Empty hitbox geometry (no damage dealt)
- P0-002: take_damage signature mismatch (crash on hit)
- P1-001: Score desync (wrong HUD display)
- P1-002: Timer draw infinite loop (no damage = equal HP always)

**4 bugs. 1 test. All preventable.**

### 3. 🔴 No Export Testing Until It Broke

Character select input was broken in Windows exports for **3 tagged releases** (v0.1.3, v0.1.4). Nobody ran a Windows export until a human tried to play the game.

The `godot-release.yml` workflow builds and publishes executables but **never runs them**. There's no smoke test: "does the .exe launch? does the main menu load? can I select a character?"

### 4. 🔴 Stub Tests Create False Confidence

7 of 11 test files are stubs — they exist as scenes but contain no assertions. The `test_index.gd` hub lists them, implying coverage that doesn't exist. A developer checking "do we have tests for RoundManager?" would see `test_roundmanager.tscn` and assume yes.

### 5. 🔴 No Regression Guards

35 bugs were cataloged. Zero have regression tests. Every fix is one refactor away from reintroduction. The timer draw infinite loop, the take_damage crash, the empty hitbox geometry — none are guarded.

### 6. ⚠️ Integration Gate Warnings Don't Block

Signal wiring failures are treated as warnings, not errors. The gate passes with orphaned signals. This means:
- A developer can merge code that defines a signal nobody listens to
- The gate's output says "PASS" when it should say "WARN — review required"
- Sprint 1's integration gate failures (#83, #88, #107) were all signal-related

---

## PART VI — FIGHTING GAME QA CHALLENGES

### Why Fighting Games Are Uniquely Hard to Test

1. **Frame-level precision matters.** A 1-frame startup difference changes combo links. Tests must validate integer frame counts, not "approximately correct" timing.

2. **State machine complexity.** 9 states × 2 players × multiple transitions = combinatorial explosion. Each state has enter/exit/physics_update hooks. Missing a `super()` call or a state timeout = stuck character.

3. **Interaction testing > unit testing.** The value isn't "does idle_state work?" — it's "can I cancel LP recovery into MP startup in a 3-frame window?" Interactions between systems matter more than isolated correctness.

4. **Visual correctness ≠ functional correctness.** The empty hitbox bug proves this. Animations play, VFX are wired, the game looks correct. But zero damage is dealt. You can't screenshot-test combat.

5. **Balance is a bug class.** Frame data drift isn't a crash, but it's a game-breaking issue. 1f too fast on a medium punch might enable an infinite combo. Balance testing requires frame-data validation tools.

6. **Input systems have deep pipelines.** Input → buffer → SOCD resolution → motion detection → state machine → animation → hitbox → collision → damage → hitstun → VFX → audio. A bug at any stage is masked by the stages below it.

7. **Edge cases are the default state.** In most games, "both players have exactly equal HP when the timer expires" is an edge case. In a fighting game, it's a round-1 timeout when neither player attacks. This was literally the default state with the hitbox bug.

8. **Export behavior ≠ editor behavior.** Godot's editor is more permissive than export builds. Input systems, type inference, and process modes can all differ. Fighting games ship as executables, not editor projects.

---

## PART VII — LESSONS & RECOMMENDATIONS

### Lesson 1: Integration Testing Is the #1 Priority

**The pattern is clear across all 35 bugs:**
- Systems worked in isolation
- Systems broke when combined
- Nobody verified the combination until late

13 of 35 bugs (37%) were introduced in Sprint 0 and not discovered until Sprint 1+. The average bug lag time was 1 day — but one bug (AI stranding) took 3 months.

**Recommendation:** Integration testing must happen within each sprint, not deferred to the next one. Add a mandatory "smoke test" ceremony after each wave of parallel work.

### Lesson 2: You Need Exactly 5 Tests to Catch 80% of Bugs

If the project had these 5 tests from Day 1, they would have caught 22 of 35 bugs:

| Test | Assertions | Bugs Caught |
|------|-----------|-------------|
| **1. Game flow smoke test** | Menu → Select → Fight → KO → Victory → Rematch completes | AI stranding, scene transitions, SceneManager wiring |
| **2. Combat damage test** | LP press → hitbox activates → hurtbox overlap → HP decreases by correct amount | Empty hitbox, take_damage crash, frame data drift |
| **3. Round resolution test** | KO → score increments → HUD updates → correct winner after best-of-3 | Score desync, timer draw infinite loop, triple KO announce |
| **4. Input pipeline test** | All 6 buttons (LP/MP/HP/LK/MK/HK) produce attacks for both players | Missing medium buttons, standing LK phantom attack, input buffer gaps |
| **5. Export launch test** | .exe launches → main menu renders → character select navigable with keyboard | Export input failures, type inference failures, tab corruption |

### Lesson 3: Static Analysis Works — Expand It

The integration gate's 3 CI rules eliminated entire bug classes:
- No `:=` with dict/array → eliminated type inference bugs in Sprint 2
- No `_process` in gameplay → prevented timing bugs
- Explicit return types → caught API mismatches

**Add these rules to the integration gate:**
- Verify hitbox geometry exists in all fighter scenes
- Verify `take_damage` call signatures match across all callers
- Verify frame data consistency across .tres files
- Verify all EventBus signals have both emitter and consumer
- Verify no duplicate autoload/local instantiation

### Lesson 4: Stub Tests Are Worse Than No Tests

7 stub test files create the illusion of coverage. A developer asks "are we testing RoundManager?" and sees `test_roundmanager.tscn`. The answer appears to be yes. It's actually no.

**Recommendation:** Delete stub test files or replace them with at minimum 1 assertion each. A test file with zero assertions is technical debt disguised as infrastructure.

### Lesson 5: Fighting Game QA Requires Frame-Data Tooling

The `export-frame-data.py` and `import-frame-data.py` pipeline is excellent for balance workflows. But there's no **validation** step:
- No tool checks GDD spec ranges against .tres values
- No tool detects frame data drift between duplicate .tres files
- No tool validates combo link math (is LP → MP actually possible given the frame advantage?)

**Recommendation:** Build `check-frame-data.py` that:
1. Parses GDD.md for spec ranges
2. Reads all .tres move data files
3. Flags values outside GDD ranges
4. Detects duplicates with conflicting values
5. Calculates frame advantage and flags impossible combo links

### Lesson 6: Headless Godot Testing Must Be in CI

Godot 4 supports `--headless` mode. The project already uses it for export builds in `godot-release.yml`. Extend this to:

```yaml
# In integration-gate.yml
- name: Run Godot headless tests
  run: |
    godot --headless --path games/ashfall --script res://scripts/test/test_runner.gd --quit
```

This requires a `test_runner.gd` that:
1. Loads each test scene
2. Collects pass/fail counts
3. Outputs JUnit-compatible results
4. Returns exit code 1 on any failure

### Lesson 7: The "Does It Run?" Gate Was Missing

The most basic quality gate — "does the game load without errors?" — didn't exist until Sprint 2. Between Sprint 0 and Sprint 2, nobody opened Godot to verify the project loaded.

**Recommendation:** Add a pre-merge check that:
1. Opens the Godot project headlessly
2. Verifies all autoloads initialize
3. Loads the main scene
4. Reports any GDScript errors

This is a 5-minute CI step that would have caught all 9 type safety bugs.

---

## PART VIII — RECOMMENDED QA STRUCTURE

### Testing Pyramid for a Fighting Game

```
                    ┌─────────────────┐
                    │   Manual QA     │  ← Playtesting, feel calibration
                    │  (Per sprint)   │     Balance validation
                    ├─────────────────┤
                │   Integration    │  ← Game flow, combat pipeline
                │   Tests (CI)     │     Round resolution, input pipeline
                ├─────────────────────┤
            │     System Tests        │  ← EventBus, GameState, RoundManager
            │     (Headless Godot)    │     InputBuffer, ComboTracker
            ├─────────────────────────────┤
        │       Static Analysis (CI)          │  ← Lint rules, signal wiring
        │       Frame Data Validation         │     Scene integrity, type safety
        └─────────────────────────────────────┘
```

### Testing Gates (In Order of Priority)

| Gate | When | Blocks? | Tool |
|------|------|---------|------|
| **G0: Project loads** | Every PR | ✅ Yes | `godot --headless --import` |
| **G1: Static analysis** | Every PR | ✅ Yes | integration-gate.yml (current 3 rules + expansions) |
| **G2: Unit tests pass** | Every PR | ✅ Yes | `godot --headless --script test_runner.gd` |
| **G3: Smoke test** | Every PR to main | ✅ Yes | Automated: menu → fight → KO → victory |
| **G4: Combat pipeline** | PRs touching combat code | ✅ Yes | LP deals correct damage, HP decreases |
| **G5: Frame data valid** | PRs touching .tres files | ✅ Yes | `check-frame-data.py` |
| **G6: Export builds** | Release tags | ✅ Yes | `godot --headless --export-release` + launch test |
| **G7: Playtest report** | Per sprint | ⚠️ Advisory | Manual playtesting with survey |

### Regression Test Requirements

Every P0/P1 bug from the catalog should have a regression test:

| Bug | Regression Test |
|-----|----------------|
| Empty hitbox geometry | Assert: LP → hurtbox overlap → damage > 0 |
| take_damage signature | Assert: `take_damage` called with 3 args from fight_scene |
| Timer draw infinite loop | Assert: equal HP at timeout → round advances |
| Score desync | Assert: GameState.scores matches RoundManager after round end |
| Character select unresponsive | Assert: `ui_accept` fires in export build |
| Type inference (`:=` dict) | Lint rule in CI (already implemented) |
| AI stranded on dead branch | Branch validation (already implemented) |
| Medium buttons missing | Assert: MP/MK input → attack state transition |

---

## PART IX — WHAT I'D DO DIFFERENTLY FROM DAY 1

### Day 1 Checklist (If Starting Over)

1. **Before any code:** Set up `godot --headless` CI that imports the project and verifies zero errors
2. **Before any combat code:** Write the combat pipeline test (press LP → damage dealt → HP decreases)
3. **Before any moveset .tres files:** Write `check-frame-data.py` that validates against GDD ranges
4. **Before any signal definitions:** Establish rule: no signal without emitter + consumer in same PR
5. **Before any parallel agent work:** Define integration checkpoint ceremony
6. **Before any tagged release:** Add export-and-launch smoke test to CI

### Cost of Not Testing

| What We Spent | Hours | What Testing Would Have Cost |
|---------------|-------|------------------------------|
| Fixing empty hitboxes + take_damage chain | 3h | 30min test + 0h fix |
| Character select input (6 attempts) | 4h | 1h export test + 30min fix |
| Type safety proactive sweep (94 Color annotations) | 6h | 30min CI rule + 0h fix |
| Timer draw investigation + fix | 2h | 15min edge case test + 15min fix |
| Signal wiring fixes (3 gate failures) | 4h | 1h signal contract test + 30min fix |
| **Total reactive fixing** | **19h** | **3h 45min preventive testing** |

**We spent 5x more time fixing bugs than it would have cost to prevent them.**

---

## SUMMARY

### The Good
- Architecture is genuinely excellent (EventBus decoupling, frame-based determinism, data-driven movesets)
- Static analysis integration gate caught real bugs and eliminated the type safety bug class
- Structured playtest reports were the primary quality gate and caught every P0 bug
- Zero P0/P1 bugs in final v0.3.0 build
- 70% of files passed code audit with zero issues

### The Bad
- **0 automated test assertions run in CI** across 3 sprints and 5,000+ LOC
- 66% of bugs found by humans, not automation
- 7 stub test files create false confidence
- `tests/` directory contains only a `.gitkeep`
- No runtime testing, no combat testing, no export testing in CI
- The game's core mechanic (attacks dealing damage) was non-functional for 24+ hours

### The Ugly
- 13 bugs shipped from Sprint 0 into Sprint 1 — a full sprint of latent defects
- AI controller stranded on dead branch for **3 months**
- Character select input took **6 fix attempts** because nobody tested exports
- Frame data had **3 conflicting sources of truth** with nobody noticing for 2 sprints
- Every bug in the catalog was preventable with basic testing

### Bottom Line

**This project has production-quality architecture and prototype-quality testing.**

The code is clean, the patterns are correct, the systems are well-designed. But the testing story is: "We built everything, then checked if it worked." That's backwards. For Sprint 3 and beyond, the testing story needs to be: "Nothing merges until we prove it works."

The trap is set. The hitboxes are fixed. Now we need the tests to make sure they stay fixed.

---

*— Ackbar, QA Lead. "It's a trap — and every trap needs a test."*
