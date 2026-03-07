# Quality Gates & Definition of Done — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Context:** Closing readiness gap #2 from CEO Readiness Evaluation. Incorporates Ackbar's Quality Excellence Proposal findings.  
**Applies to:** All deliverables in Godot 4 projects, effective Sprint 0.

---

## 1. Quality Gates

Every deliverable must pass the relevant gate(s) before it is accepted. Gates are cumulative — a gameplay feature touches Code, Design, and Integration gates. A gate failure **blocks merge**.

---

### 🔧 Code Quality Gate

A code deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| C1 | **Compiles and runs without errors or warnings** | No `push_error()`, no orphan nodes, no null reference crashes. Zero-warning policy. |
| C2 | **State machine audit passed** | Every state has a documented entry condition, per-frame behavior, AND exit condition. No dead-end states. (Lesson: SimpsonsKong Bug #1 — player frozen in `hit` state because exit path was missing.) |
| C3 | **All imports/dependencies valid** | Every `preload()`, `load()`, `@onready`, and `class_name` reference resolves. No dangling references to deleted scenes or scripts. |
| C4 | **Tested in Godot editor AND exported build** | Runs correctly in editor play mode AND at least one export target (desktop or web). Editor-only code paths caught here. |
| C5 | **No unused infrastructure** | Every system created must be wired into at least one consumer. No orphan autoloads, no dead signals, no comment-only integration contracts. (Lesson: 214 LOC of unwired infrastructure in SimpsonsKong.) |
| C6 | **Cross-reviewed by a second engineer** | Chewie reviews Lando's code, Lando reviews Chewie's. Solo reviews anything touching autoloads, scene tree structure, or signal bus. (Recommendation from Ackbar's quality proposal: separate code review from QA.) |
| C7 | **GDScript style conventions followed** | Naming, indentation, signal naming, and file organization match `project-conventions` skill document. |
| C8 | **Frame-by-frame trace completed for critical paths** | For state transitions, combat interactions, and AI behaviors: trace at least 3 consecutive frames of execution. Document in PR description. |

**Gate owner:** Solo (Lead) + cross-review engineer.

---

### 🎨 Art Quality Gate

An art deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| A1 | **Consistent with art direction document** | Matches Boba's art direction for palette, style, proportions, and mood. |
| A2 | **Proper resolution and format** | Sprites at project-standard resolution (defined per project). PNG for sprites, `.tres` for Godot resources. No upscaled raster, no mismatched pixel density. |
| A3 | **Cohesive style across all assets in scene** | New art doesn't clash with existing art in the same scene. Side-by-side comparison required. |
| A4 | **Readable at game camera zoom** | Character silhouettes identifiable at default camera zoom. Test at smallest supported resolution. |
| A5 | **Animation frames complete** | All required animation states have frames (idle, walk, attack, hit, death at minimum for characters). No placeholder frames in shipped animations. |
| A6 | **Import settings correct** | Filter mode, atlas packing, and compression match project conventions. No blurry pixel art from wrong filter settings. |

**Gate owner:** Boba (Art Director). Advisory review from Ackbar (first-impression score).

---

### 🔊 Audio Quality Gate

An audio deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| AU1 | **Mix levels balanced** | No sound effect drowns out others. Music sits below SFX in the mix. Master bus peaks below 0dB. |
| AU2 | **No clipping or distortion** | All audio streams tested at max simultaneous playback (worst-case scenario). No digital clipping. |
| AU3 | **Spatial panning correct** | Sounds positioned in 2D space pan appropriately with camera movement. Left-side events sound left, right-side events sound right. |
| AU4 | **AudioBus routing verified** | Every AudioStreamPlayer routed to the correct bus (SFX, Music, Ambient). Volume sliders in options affect the correct bus. |
| AU5 | **No audio leaks** | Sounds stop when their source is removed. No phantom audio continuing after scene transitions. |
| AU6 | **Variation implemented for repeated sounds** | Hit sounds, footsteps, and other frequent SFX have at least 2 variations OR pitch randomization to avoid machine-gun repetition. |

**Gate owner:** Greedo (Audio). Technical review by Chewie for AudioBus wiring.

---

### 🎮 Design Quality Gate

A design deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| D1 | **Aligns with GDD** | Feature serves the core loop defined in the Game Design Document. If it doesn't appear in the GDD, it needs Yoda's sign-off before implementation. |
| D2 | **Serves player experience** | Passes the "Player Hands First" test: does this make the game feel better to play? Evaluated by playtesting, not by reading code. |
| D3 | **Difficulty tested** | Playtested at intended difficulty. Clear time, damage taken, and deaths recorded. Metrics fall within target ranges (defined per encounter/wave). |
| D4 | **Difficulty curve maintained** | New content doesn't create difficulty spikes or dead zones. Tested in sequence, not isolation. |
| D5 | **Player feedback clear** | Player can tell what happened and why. Hits have impact feedback, damage has visual/audio cue, state changes are communicated. |
| D6 | **No degenerate strategies** | Playtester attempts to cheese the mechanic. If one strategy dominates all others, redesign. (Lesson: jump-attack dominance in SimpsonsKong.) |

**Gate owner:** Yoda (Game Designer). Playtesting by Ackbar.

---

### 🔗 Integration Quality Gate

An integration deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| I1 | **No regressions** | Ackbar's regression checklist passes. All previously working features still work after the change. |
| I2 | **All systems wired** | New systems connected to their consumers. Signals connected. Autoloads accessible. No isolated subsystems. |
| I3 | **Performance budget met** | Frame time ≤ 16.67ms (60 FPS target). No metric in critical range. Tested with max entity count for the current milestone. |
| I4 | **Scene tree clean** | No orphan nodes, no nodes in wrong groups, no duplicate autoloads. Scene tree matches architectural diagram. |
| I5 | **Export targets verified** | Game runs on all target export platforms without platform-specific bugs. |
| I6 | **Save/load integrity** | If feature touches persistent state: save, quit, reload, verify state survived. |

**Gate owner:** Solo (Lead) for architecture. Ackbar (QA) for regression and playtesting.

**Performance Budget Reference (Godot 4):**

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| FPS | ≥ 60 | < 55 | < 45 |
| Frame time | ≤ 16.67ms | > 18ms | > 22ms |
| Active nodes | ≤ 200 | > 300 | > 500 |
| Physics bodies | ≤ 30 | > 50 | > 80 |
| Draw calls | ≤ 50 | > 80 | > 120 |
| Memory | ≤ 100MB | > 150MB | > 250MB |
| Scene load time | ≤ 1s | > 2s | > 4s |

---

## 2. Definition of Done

A deliverable is **DONE** when all applicable items are checked:

- [ ] **Runs without errors** — Code compiles, game launches, feature works as specified
- [ ] **Cross-reviewed** — Reviewed by at least one other agent (code review for code, art review for art, design review for design)
- [ ] **QA tested** — Ackbar has tested for functionality using regression checklist + smoke test
- [ ] **Playtested for feel** — Tested by a human or agent for game feel, not just correctness. "Does it feel good?" is a separate question from "does it work?"
- [ ] **No known regressions** — All previously passing tests/checks still pass. No existing features broken.
- [ ] **History.md updated** — Agent's history file updated with learnings, decisions, and outcomes from this work
- [ ] **Decision documented** — If an architectural, design, or process choice was made, it's logged in `decisions/` with context and rationale
- [ ] **Quality gate(s) passed** — All applicable gates from Section 1 above have been satisfied

### When is something NOT done?

A deliverable is **not done** if any of these are true, regardless of code completeness:
- It works in the editor but hasn't been tested in an exported build
- It was self-reviewed only (author reviewed their own work)
- It introduces a state with no exit path
- It creates infrastructure that isn't wired to any consumer
- It changes difficulty but wasn't playtested for balance
- It touches shared systems (autoloads, signals, scene tree) without Solo's review

---

## 3. Bug Severity Matrix

| Severity | Definition | Examples | Ship Blocker? | Response |
|----------|-----------|----------|---------------|----------|
| 🔴 **CRITICAL** | Game unplayable or player stuck | Crash on load, infinite loop, player frozen, enemies never attack | ✅ BLOCKS SHIP | Drop everything, fix immediately |
| 🟠 **HIGH** | Core mechanic broken | Combat doesn't register hits, audio crashes, score not saved | ✅ BLOCKS SHIP | Fix within same session |
| 🟡 **MEDIUM** | Feature degraded but game playable | Animation glitch, HUD element misaligned, one enemy type broken | ⚠️ SHIP WITH KNOWN ISSUE | Fix in next sprint |
| 🟢 **LOW** | Minor polish issue | Slight hitbox mismatch, animation stiffness, minor audio pop | ❌ DOES NOT BLOCK | Backlog |
| ⚪ **COSMETIC** | Visual-only, no gameplay impact | Pixel alignment, color shade, font weight | ❌ DOES NOT BLOCK | Backlog |

**Severity dispute rule:** If two agents disagree on severity, the higher rating wins. CRITICAL and HIGH bugs require unanimous "fixed" verdict from both reviewer and QA.

---

## 4. Review Process

### Code Review (Pre-Merge)

| Step | Who | What |
|------|-----|------|
| 1 | Author | Creates branch, implements change, self-tests |
| 2 | Cross-reviewer | Reads diff, traces affected state machines, checks gate C1-C8 |
| 3 | Ackbar (QA) | Runs smoke test + regression checklist |
| 4 | Solo (if shared systems) | Architecture review for autoloads, signals, scene tree changes |
| 5 | Merge | Only after all required approvals |

### Cross-Review Assignments

| Author | Reviewer | Scope |
|--------|----------|-------|
| Chewie (Engine) | Lando (Gameplay) | Engine code, physics, rendering |
| Lando (Gameplay) | Chewie (Engine) | Combat, AI, player mechanics |
| Wedge (UI/UX) | Chewie or Lando | HUD, menus, input handling |
| Tarkin (Enemy/Content) | Lando (Gameplay) | Enemy behavior, encounter design |
| Greedo (Audio) | Chewie (Engine) | AudioBus wiring, stream management |
| Solo (Lead) | Chewie (Engine) | Architecture, autoloads, shared systems |

**Principle:** No code merges without a second pair of eyes. The author's blind spot is the reviewer's opportunity.

---

## 5. Playtest Protocols

### Quick Smoke Test (2 min — every change)

- [ ] Game loads without errors
- [ ] Player can move in all directions
- [ ] Player can attack
- [ ] At least one enemy reacts correctly
- [ ] Player takes damage and recovers
- [ ] No audio glitches

### Full Playtest (10 min — every milestone)

- [ ] Complete all available content
- [ ] Record clear time, final HP, deaths
- [ ] Rate combat feel (1-10)
- [ ] Rate difficulty (1-10)
- [ ] Note visual/audio issues
- [ ] Run full regression checklist

### Adversarial Playtest (15 min — before ship)

- [ ] Spam every attack type rapidly
- [ ] Walk into every boundary
- [ ] Pause/unpause during every state
- [ ] Let enemies hit player repeatedly
- [ ] Stand still and observe AI for 30 seconds
- [ ] Attempt to break every system

---

*This document is a living standard. Update as the team learns. Every bug that slips through is a signal to strengthen a gate.*

*— Solo, Lead / Chief Architect, First Frame Studios*
