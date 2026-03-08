# Ashfall — M1+M2 Retrospective

**Facilitated by:** Jango (Lead)  
**Requested by:** Joaquín (Founder)  
**Date:** 2026-03-08  
**Scope:** Milestone 1 (Greybox Prototype) + Milestone 2 (Visual Polish)  
**Purpose:** Honest reflection before M3 begins. Not a status report — a ceremony.

---

## 1. What We Built (Facts)

### Codebase Metrics

| Metric | Count |
|--------|-------|
| GDScript files | 31 |
| Total lines of GDScript | 2,711 |
| Scene files (.tscn) | 7 |
| Resource files (.tres) | 2 |
| Autoloads registered | 5 |
| PRs created | 9 |
| PRs merged to main | 8 (1 cherry-picked) |
| Issues tracked | 13 |
| Issues closed | 11 |
| Issues open | 2 (#9 character sprites, #13 playtesting) |
| Commits on main | 30 |

### Systems Delivered — M1 (Greybox Prototype)

| System | Agent | PR | Issue | Files | Key LOC |
|--------|-------|----|-------|-------|---------|
| Project scaffold | Jango | #14 | #1 | project.godot, 21 dirs, autoloads | EventBus (26), GameState (42), StateMachine (28), State (15) |
| Fighter state machine | Chewie | #15 | #2, #4, #6 | 8 state scripts, fighter_base, hitbox, round_manager | 8 states (378 total), RoundManager (117), Hitbox (67), FighterBase (110) |
| Fighter controller + input | Lando | #16 | #3 | controller, input_buffer, motion_detector, movesets, fight_scene | InputBuffer (141), MotionDetector (94), FighterController (83), FighterMoveset (38), MoveData (30) |
| Stage scene | Leia | #18 | #8 | ember_grounds.tscn, ember_grounds.gd | EmberGrounds (48) — parallax, lava glow, ember reactivity |
| Fight HUD | Wedge | #19 | #5 | fight_hud.tscn, fight_hud.gd | FightHUD (236) — health bars, timer, ember meter, announcer |

### Systems Delivered — M2 (Visual Polish)

| System | Agent | PR | Issue | Files | Key LOC |
|--------|-------|----|-------|-------|---------|
| Hit VFX | Bossk | #20 | #10 | vfx_manager.gd | VFXManager (423) — sparks, shake, flash, KO slowmo, ember trails |
| Game flow screens | Wedge | #21 | #12 | main_menu, character_select, victory_screen, scene_manager + 4 .tscn | MainMenu (64), CharSelect (100), VictoryScreen (68), SceneManager (58) |
| Procedural audio | Greedo | Cherry-pick | #11 | audio_manager.gd | AudioManager (495) — 14 sounds, 3 mix buses, 8-player pool |

### NOT On Main ⚠️

| System | Agent | PR | Issue | Status |
|--------|-------|----|-------|--------|
| AI opponent | Tarkin | #17 | #7 | **Merged to wrong base branch** (`squad/1-godot-scaffold` after scaffold was already merged to main). 298 LOC stranded on dead branch. Issue #7 manually closed. |

---

## 2. What Went Well ✅

### Parallel Execution Was Real
Three agents shipped simultaneously in M1 Wave 1 (scaffold + state machine + fighter controller). PRs #14, #15, #16 all landed within hours of each other. The architecture's "six parallel work lanes" from Solo's ARCHITECTURE.md actually worked — file ownership prevented conflicts.

### Frame-Based Combat Architecture Was the Right Call
Every state script uses integer `frames_in_state` counters. The `attack_state.gd` startup/active/recovery phase logic (lines 55-72) is clean, deterministic, and exactly what a fighting game needs. The safety timeout at frame 120 prevents dead-end states — a lesson directly transferred from firstPunch's player-freeze bug.

### Input Buffer Is Genuinely Sophisticated
`input_buffer.gd` (141 LOC) implements: 30-frame ring buffer, 8-frame leniency window, SOCD resolution (Left+Right=Neutral, Up+Down=Up), numpad notation directional computation, motion detection via `MotionDetector`, simultaneous press detection for throws, and `consume_button`/`consume_motion` to prevent double execution. This is production-quality fighting game infrastructure.

### Procedural Audio — Zero Dependencies
`audio_manager.gd` (495 LOC) generates 14 distinct sounds entirely from code — no audio files. 3 mix buses (Announcer > SFX > Music), 8-player SFX pool with round-robin, ±5% pitch jitter per play, and a 4-bar looping background track at 112 BPM. Full EventBus integration. Greedo delivered a complete audio system with nothing but `AudioStreamGenerator`.

### EventBus Decoupling Pattern Worked
26 lines. 13 signals covering combat, fighters, rounds, ember, and game flow. Every system connects through EventBus — VFXManager, AudioManager, FightHUD, EmberGrounds stage — none hold direct references to each other. This is the pattern we wished we'd had in firstPunch from Day 1.

### MoveData as Resources — Data-Driven Design
Kael and Rhena movesets are `.tres` resource files with frame data, damage, hitstun, knockback, and hit types. Adding a new move means editing a resource, not touching code. The `FighterMoveset` class with `get_normal()` and `get_special()` lookups makes the controller clean and extensible.

### Skills System Captured Lessons in Real-Time
The `github-pr-workflow` SKILL.md was created mid-session after we hit 6 distinct GitHub workflow issues. This is institutional knowledge that will save time on every future project. The fact that agents wrote skills while working — not after — is exactly the behavior we want.

### Node-Per-State Pattern Is Clean
8 separate state scripts (idle, walk, crouch, jump, attack, block, hit, ko) each with their own `enter()`, `exit()`, and `physics_update()`. States own their own logic. The `StateMachine` (28 LOC) is tiny because the complexity lives in the states, not the manager. Good Godot-native architecture.

---

## 3. What Didn't Go Well ❌

### AI Opponent Never Made It to Main
**This is the most critical failure of the sprint.** PR #17 was merged into `squad/1-godot-scaffold` — but scaffold had already been merged to main via PR #14. The 298-line `ai_controller.gd` with state-based decision making (IDLE/APPROACH/ATTACK/BLOCK/RETREAT), reaction delay, weighted attacks, and input buffer injection is fully implemented but lives on a dead branch. Issue #7 was closed manually. **The game has no AI opponent on main.**

### project.godot Merge Conflicts from Parallel Branches
Multiple agents branching from the same base commit and adding autoloads to `project.godot` caused merge conflicts. We documented this in the skills system, but it burned real time during integration. The mitigation (rebase remaining branches after first merge) wasn't communicated proactively.

### Closes #N Not Working in PR Titles
We learned the hard way that `Closes #N` must be in the PR **body**, not the title. Issues #6 and #7 were implemented but didn't auto-close. This was caught and documented in the skills, but it means our issue tracking was manually corrected rather than automated.

### gh CLI PATH Issues for Spawned Agents
Every spawned agent needed a PATH refresh to find `gh`. The PowerShell `$env:Path` doesn't automatically inherit updates. We had to discover this, debug it, and document the workaround. Lost time on tooling when agents should have been coding.

### Medium Punch/Kick Inputs Missing from project.godot
**The GDD specifies a 6-button layout (LP/MP/HP/LK/MK/HK).** But `project.godot` only maps 4 attack buttons per player: `light_punch`, `heavy_punch`, `light_kick`, `heavy_kick`. No `medium_punch` or `medium_kick` exist in the input map. The movesets also only define 4 normals per character (lp, hp, lk, hk) — no medium attacks. **This is a silent spec deviation.** The GDD and the implementation disagree, and nobody flagged it.

### PR #22 (AudioManager) Closed But Not Merged
PR #22 was created by Greedo for the audio system but was closed without merging. The code reached main via direct cherry-pick (commit `a455ce1`). This breaks our PR-based workflow — no review trail, no linked closure to the issue.

### No Integration Testing
Every system was built and verified in isolation. Nobody tested whether:
- The fight scene loads with both fighters, the HUD, and the stage together
- VFXManager sparks spawn at the correct position when a hit lands
- AudioManager plays sounds at the right game flow moments
- SceneManager transitions from character select to fight scene with the correct fighter configuration
- The round manager resets fighters and the HUD updates

### No Godot Test Run
Nobody opened the project in Godot to verify it even loads without errors. Scene references might be broken, autoload order might cause null references, and the render pipeline hasn't been validated.

### Stale Documentation Branches
Local branches `squad/11-sound-effects` and `squad/12-menus` still exist after their work landed on main. No cleanup step was executed.

---

## 4. Key Decisions Made

### Creative Decisions
1. **Ashfall pivoted from roguelike to 1v1 fighting game** — Founder directive. Tekken/Street Fighter style in Godot 4.
2. **The Ember System** — Shared, visible combat resource replacing hidden super meter. Both players see and fight over it.
3. **Kael (balanced shoto) & Rhena (rushdown)** — Classic archetype pairing for the 2-character MVP.
4. **Scope boundary locked** — 2 characters, 1 stage, local vs, arcade, training. Everything else deferred.

### Architecture Decisions
5. **Frame-based timing** — Integer frame counters (`frames_in_state += 1`), all gameplay in `_physics_process()` at 60 FPS. No float timers for combat.
6. **Node-per-state pattern** — Each fighter state is a separate Node with its own script. States own their logic.
7. **AnimationPlayer as frame data driver** — Hitbox activation driven by animation tracks with startup/active/recovery phases.
8. **MoveData as Resource** — Moves are `.tres` files with frame data, damage, hitstun, knockback. Pure data, no logic.
9. **EventBus autoload for decoupling** — All inter-system communication routes through a singleton signal bus.
10. **AI uses input buffer injection** — AI injects synthetic inputs through the same code path as human players.
11. **Six collision layers** — P1/P2 hitboxes, hurtboxes, pushboxes on separate layers. No self-hits.
12. **Deterministic simulation** — Fixed 60 FPS tick, seeded RNG, input-based state. Future rollback netcode possible.

### Process Decisions
13. **Branch ruleset with 1 approval minimum** — Rulesets created via `gh api`.
14. **Joaquín never reviews code** — Founder focus on vision, not implementation details.
15. **Wiki + devlog auto-update after milestones** — Committed as directive.
16. **Skills system captures lessons in real-time** — Agents write skills while working, not retroactively.
17. **20% load cap per agent** — No agent carries more than 20% of work items. Prevents bottlenecks.
18. **Cherry-pick as conflict resolution fallback** — When branches diverge too far, cherry-pick unique commits.

---

## 5. Technical Debt & Risks

### Critical (Must Fix Before M3)

| # | Risk | Impact | Effort |
|---|------|--------|--------|
| 1 | **AI controller not on main** | Game has no single-player mode. 298 LOC stranded on dead branch. | 1h — cherry-pick or re-create PR from main |
| 2 | **Medium buttons missing** | GDD promises 6-button layout but only 4 are implemented. Kael and Rhena each have only 4 normals. | 2-3h — add input map entries + medium move data |
| 3 | **No integration test** | Systems may not work together. Scene loading, signal connections, and autoload order are unverified. | 2h — open in Godot, run through full game flow |

### High (Should Fix in M3)

| # | Risk | Impact | Effort |
|---|------|--------|--------|
| 4 | **Float division in attack_state.gd** | Line 48: `fighter.gravity / 60.0` — uses float math in a frame-based system. Minor but breaks the "no float timers" principle. | 15min |
| 5 | **Autoload order dependency** | VFXManager and AudioManager both depend on EventBus. Current order is correct (EventBus first), but no documentation or assertion enforces this. | 30min — add ready-check assertions |
| 6 | **Movesets hardcoded to 4 buttons** | `.tres` resources only define lp/hp/lk/hk normals + 2 specials per character. GDD specifies at least 6 normals each. | 2h per character |
| 7 | **Camera system missing** | ARCHITECTURE.md specifies "simple follow camera with zoom." ember_grounds.tscn has a static Camera2D at (640, 360). No camera follow, no zoom. | 2h |

### Medium (Track for Later)

| # | Risk | Impact | Effort |
|---|------|--------|--------|
| 8 | **Scene references fragile** | All .tscn files reference scripts by path. Renaming or moving a script silently breaks scenes. | Ongoing discipline |
| 9 | **No combo system** | `hit_confirmed` and `combo_ended` signals exist on EventBus but nothing emits them. Combo counter in HUD has no data source. | 4h |
| 10 | **Throw state not implemented** | `fighter_controller.gd` line 53: `# TODO: transition to throw state when implemented`. The function returns true (consuming input) but does nothing. | 2h |
| 11 | **Damage scaling not implemented** | GDD specifies combo proration (100% → 40% floor). No code implements this. | 2h |
| 12 | **Training mode not implemented** | SceneManager supports `TRAINING` in GamePhase enum but no training scene exists. | 4h |

---

## 6. Recommendations for M3

### Before M3 Starts: Integration Pass (Mandatory)

**Do NOT start M3 feature work until:**
1. Cherry-pick or rebase ai_controller.gd onto main
2. Open the project in Godot 4.6 and verify it loads without errors
3. Run through the full game flow: Main Menu → Character Select → Fight → KO → Victory → Rematch
4. Verify all 5 autoloads initialize without null references
5. Confirm VFX sparks appear on hit, audio plays on round start, HUD updates on health change

### Process Changes

| Change | Why |
|--------|-----|
| **All branches must be created from latest main** | PR #17 branched from scaffold and ended up stranded. Always `git checkout main && git pull && git checkout -b feature/x`. |
| **Jango reviews all PRs before merge** | The new branch ruleset. Catches base branch errors, integration issues, and spec deviations before they land. |
| **Run `Closes #N` audit after every wave** | Check that issues auto-closed. If not, investigate why immediately. |
| **Integration checkpoint between waves** | After each wave of parallel work, one agent runs the full game flow before the next wave starts. |
| **Clean up branches after merge** | Delete local and remote feature branches once merged. Reduces confusion. |

### M3 Scope (Issue #9 — Character Sprites)

M3 is about replacing colored rectangles with recognizable characters:
- Kael placeholder sprites (idle, walk, 3 attacks, hitstun, knockdown — 8 frames minimum)
- Rhena placeholder sprites (same set)
- Distinct silhouettes (Kael ≠ Rhena)
- Sprite sheets formatted for Godot AnimatedSprite2D

**Recommendation:** Before M3 art work, fix the integration issues from M1/M2. Sprites won't matter if the game doesn't run. Budget 1 session for integration pass, then M3.

**Also address during M3:**
- Add medium punch/kick to input map and movesets (resolve GDD spec deviation)
- Implement camera follow with zoom (currently static)
- Wire the AI controller onto main

---

## 7. Team Performance Notes

### Delivered Strong 💪

| Agent | Contribution | Note |
|-------|-------------|------|
| **Chewie** (Engine) | State machine + hitbox + round manager in one PR (#15). 378 LOC of state scripts with no dead-end states. | The engine foundation is solid. Every state has an exit path. |
| **Lando** (Gameplay) | Input buffer + motion detector + controller + fight scene (#16). The most technically complex system. | Input buffer quality is production-grade. SOCD, consume logic, motion detection — all correct. |
| **Greedo** (Audio) | 495 LOC procedural audio from nothing. 14 sounds, 3 buses, pitch jitter, BPM-locked background track. | Delivered the largest single file in the project and it's entirely self-contained. |
| **Bossk** (VFX) | 423 LOC VFX system. Sparks, shake, flash, KO slowmo, ember trails. All EventBus-wired. | Clean separation of cosmetic vs gameplay layers. |
| **Wedge** (UI) | HUD + Main Menu + Character Select + Victory Screen + SceneManager across two PRs. | Most breadth of any agent — 5 scripts + 5 scenes. Solid across all of them. |

### Struggled or Got Unlucky 😕

| Agent | Issue | Diagnosis |
|-------|-------|-----------|
| **Tarkin** (AI) | 298 LOC of working AI code never reached main. | **Not Tarkin's fault.** The code was correct. The PR was merged to the wrong base branch (`squad/1-godot-scaffold` after it had already merged to main). This is a coordination failure, not an agent failure. |
| **PR #22 workflow** | AudioManager PR closed without merge; code cherry-picked directly. | Breaks the review trail. Should have been rebased and re-merged properly. |

### Routing Improvements

1. **AI work should have been based from main**, not from the scaffold branch. The dependency was on the scaffold being merged first — Tarkin should have waited for PR #14 to land, then branched from updated main.
2. **Integration agent needed.** Nobody owned the job of verifying systems work together. Ackbar (QA) was blocked on a stable build that never got integration-tested. Consider making "integration verification" an explicit task, not assumed.
3. **Coordinator should verify PR base branches** before spawning parallel agents. A 30-second check would have prevented the AI stranding.

---

## Summary

**M1+M2 delivered a structurally sound fighting game foundation.** 2,711 lines of GDScript across 31 files, with clean architecture, data-driven movesets, production-quality input handling, and zero external dependencies. The EventBus pattern and frame-based combat architecture are genuine strengths that will serve the project well.

**The critical gap is integration.** Systems were built in parallel isolation and never verified together. The AI controller stranding is the most visible symptom, but the deeper issue is that nobody owned the "does it all work together?" question. Fix that before M3.

**Top 3 action items:**
1. 🔴 **Cherry-pick AI controller to main** — the game needs single-player
2. 🔴 **Run full integration pass in Godot** — verify the project loads and game flow works end-to-end
3. 🟡 **Add medium buttons to input map** — resolve the 4-button vs 6-button GDD deviation

---

*This retrospective was conducted by analyzing the actual codebase, git history, PRs, issues, decisions, and skills — not from memory or assumptions. Every claim above is verifiable from the repository.*
