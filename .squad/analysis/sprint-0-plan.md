# Sprint 0 Plan — First Frame Studios (Godot 4)

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Context:** Closing readiness gap #3 from CEO Readiness Evaluation. Converting migration strategy into executable Sprint 0.  
**Prerequisite:** Project conventions skill filled by Jango (readiness gap #1).

---

## Sprint 0 Goal

> **"Playable character moving in a Godot scene with one attack."**

Open the game → move the character → punch an enemy → see it take damage. That's the entire scope. Everything else is Sprint 1.

---

## Success Criteria

Sprint 0 is **DONE** when all of the following are true:

- [ ] Godot project opens without errors
- [ ] Player character (CharacterBody2D) moves with WASD/arrow keys
- [ ] Player can perform a punch attack
- [ ] Punch creates a hitbox that detects collision with enemy hurtbox
- [ ] One enemy exists with basic approach AI (moves toward player)
- [ ] Enemy takes damage when punched (health decreases, visual feedback)
- [ ] HUD shows player health bar
- [ ] At least one hit sound plays on impact
- [ ] No crashes, no freezes, no dead-end states
- [ ] Ackbar has playtested and confirmed all criteria met

**The "First Frame" test:** Does it feel like a game in the first second of interaction? If the character moves and the punch connects with satisfying feedback, Sprint 0 succeeds.

---

## Agent Assignments

### 🏗️ Phase 1: Foundation (Parallel Start)

These tasks have no dependencies on each other and begin simultaneously.

| Agent | Task | Deliverable | Quality Gate |
|-------|------|-------------|-------------|
| **Jango** (Tool Engineer) | Project scaffolding | `project.godot` configured, folder structure (`scenes/`, `scripts/`, `assets/`, `resources/`), autoload singletons stubbed (`EventBus`, `GameState`), export presets (desktop + web), `.gitignore`, layer/mask assignments defined | Code C1, C3, C5, C7 |
| **Yoda** (Game Designer) | GDD outline for new project | GDD v0.1: core loop definition (500 words max), 30-second gameplay description, win/loss conditions, tone statement. Framework only — not a 44K-char doc. | Design D1, D2 |
| **Boba** (Art Director) | Art direction document | Color palette, style reference (3+ images), character proportion guide, environment mood, pixel density standard, animation frame counts per state | Art A1, A2, A3 |
| **Greedo** (Audio Designer) | Audio system setup | AudioBus layout (Master → SFX, Music, Ambient), one hit sound effect (with pitch randomization), AudioStreamPlayer2D test scene confirming spatial panning works | Audio AU1-AU6 |

### 🔍 Phase 1.5: Architecture Review

| Agent | Task | Deliverable | Depends On |
|-------|------|-------------|------------|
| **Solo** (Lead) | Architecture review of Jango's scaffolding | Written review: folder structure approved, autoload design approved, naming conventions verified, layer assignments confirmed. Approval or change requests. | Jango's scaffolding |

### 🎮 Phase 2: Core Gameplay (Starts after scaffolding approved)

| Agent | Task | Deliverable | Quality Gate | Reference |
|-------|------|-------------|-------------|-----------|
| **Chewie** (Engine Dev) | Player CharacterBody2D + movement | Player scene with CharacterBody2D, collision shape, movement script (WASD/arrows), gravity if side-view or Y-sort if top-down. Smooth acceleration/deceleration. Input mapping in project settings. | Code C1-C8 | `godot-4-manual` skill, `state-machine-patterns` skill |
| **Lando** (Gameplay Dev) | Punch attack with hitbox/hurtbox | Attack state in player state machine, Area2D hitbox activated during punch, enemy hurtbox (Area2D), damage signal on overlap, attack cooldown, basic animation state transition (idle → attack → idle). | Code C1-C8, Design D2, D5 | `beat-em-up-patterns` skill, `beat-em-up-combat` skill |
| **Nien** (Character Artist) | Player sprite placeholder | Spritesheet with minimum states: idle (2+ frames), walk (4+ frames), attack/punch (3+ frames), hit (2+ frames). Consistent with Boba's art direction. Can be simple — will iterate. | Art A1-A6 | Boba's art direction doc |
| **Tarkin** (Enemy/Content Dev) | One basic enemy with approach AI | Enemy scene with CharacterBody2D, hurtbox (Area2D), health property, AI script: detect player in range → move toward player → stop at attack range. Takes damage from player hitbox. Death state (remove from scene). | Code C1-C8, Design D1 | `state-machine-patterns` skill |

### 📊 Phase 3: Integration & Polish

| Agent | Task | Deliverable | Depends On |
|-------|------|-------------|------------|
| **Wedge** (UI/UX Dev) | Minimal HUD | Health bar (TextureProgressBar or custom), positioned top-left, updates via signal when player takes damage. Clean, readable at game camera zoom. | Chewie's player scene (for health signal) |
| **Ackbar** (QA/Playtester) | Test Sprint 0 deliverables | Smoke test all success criteria, regression checklist, feel report (combat responsiveness, movement weight, enemy approach behavior). Bug reports with severity ratings. | All Phase 2 deliverables |
| **Solo** (Lead) | Integration review | Verify all systems wired: player ↔ enemy damage, player ↔ HUD health, attack ↔ audio. State machine audit on player and enemy. Performance check. | All deliverables |

### 🟡 Phase 4: Available for Follow-Up

| Agent | Status | Notes |
|-------|--------|-------|
| **Leia** (Environment Artist) | On standby | Blocked until art direction is set AND a playable scene exists to place environment art into. Sprint 1 candidate: ground plane, background layers. |
| **Bossk** (VFX Artist) | On standby | Blocked until combat is working. Sprint 1 candidate: hit impact VFX, damage numbers. |

---

## Dependency Graph

```
Phase 1 (Parallel):
  Jango: Scaffolding ─────────┐
  Yoda: GDD outline           │ (independent)
  Boba: Art direction ─────┐  │
  Greedo: Audio setup      │  │
                           │  │
Phase 1.5:                 │  │
  Solo: Review scaffolding ◄──┘
                           │
Phase 2 (after scaffold):  │
  Chewie: Player movement ─┤
  Lando: Punch attack ─────┤── (need scaffold)
  Nien: Player sprites ◄───┘── (need art direction from Boba)
  Tarkin: Basic enemy ─────┤
                           │
Phase 3 (after gameplay):  │
  Wedge: HUD ◄────────────┤── (needs player health signal)
  Greedo: Wire hit sound ◄─┤── (needs attack signal)
  Ackbar: Test everything ◄┘
  Solo: Integration review
```

---

## Technical Decisions (Pre-Sprint)

These architectural choices are made now to avoid Sprint 0 debates:

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Physics** | CharacterBody2D with `move_and_slide()` | Standard Godot pattern for player-controlled characters. Built-in collision resolution. |
| **State machine** | GDScript enum + match statement | Simple, readable, debuggable. No custom StateMachine node until complexity warrants it. (Lesson: YAGNI from SimpsonsKong.) |
| **Hitbox/Hurtbox** | Area2D with collision layers | Hitboxes on layer 2, hurtboxes on layer 3. Clean separation. Signal-based detection (`area_entered`). |
| **Event system** | Autoload EventBus with typed signals | Central signal bus for cross-system communication (damage dealt, enemy died, health changed). Avoids direct node references. |
| **Camera** | Camera2D following player | Smoothing enabled. Limits set to level bounds. Simple — no fancy camera until Sprint 2+. |
| **Input** | Input map in Project Settings | Named actions: `move_left`, `move_right`, `move_up`, `move_down`, `attack`. No hardcoded keycodes. |
| **Scene tree** | Main scene → World → Player, Enemies, HUD | Flat hierarchy. Player and enemies are siblings under World. HUD is a CanvasLayer sibling. |

---

## Collision Layer Assignments

| Layer | Name | Used By |
|-------|------|---------|
| 1 | World | Ground, walls, boundaries |
| 2 | Player | Player CharacterBody2D |
| 3 | Enemy | Enemy CharacterBody2D |
| 4 | PlayerHitbox | Player attack Area2D |
| 5 | EnemyHurtbox | Enemy damage-receiving Area2D |
| 6 | EnemyHitbox | Enemy attack Area2D (Sprint 1+) |
| 7 | PlayerHurtbox | Player damage-receiving Area2D (Sprint 1+) |
| 8 | Pickup | Health pickups, power-ups (future) |

**Mask rules:** PlayerHitbox (layer 4) masks EnemyHurtbox (layer 5). EnemyHitbox (layer 6) masks PlayerHurtbox (layer 7). No friendly fire.

---

## Sprint 0 Timeline

| Phase | Duration | Milestone |
|-------|----------|-----------|
| Phase 1: Foundation | Session 1 | Scaffold exists, GDD outline written, art direction set |
| Phase 1.5: Review | Session 1 (end) | Scaffold approved by Solo |
| Phase 2: Core Gameplay | Sessions 2-3 | Player moves, punches, enemy takes damage |
| Phase 3: Integration | Session 3-4 | HUD wired, audio wired, all systems connected |
| Sprint 0 Complete | Session 4 | Ackbar's playtest passes all success criteria |

**Estimated total:** 3-4 sessions.

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Godot unfamiliarity causes slowdown | Medium | Medium | Agents reference `godot-4-manual` and `godot-beat-em-up-patterns` skills. Pair work for first Godot scenes. |
| State machine bug (repeat of SimpsonsKong) | Medium | High | State machine audit in quality gates (C2). Frame-by-frame trace required. |
| Scope creep ("just one more feature") | High | Medium | Sprint 0 goal is razor-sharp: move, punch, damage. Everything else is Sprint 1. Solo enforces. |
| Art direction delays block Nien | Low | Low | Nien can start with geometric placeholder (colored rectangles) while Boba finalizes direction. |
| Integration failures at Phase 3 | Medium | High | EventBus architecture defined upfront. Signal names agreed in Phase 1 scaffold. |

---

## Sprint 1 Preview (Not in scope — for planning only)

After Sprint 0 succeeds, Sprint 1 candidates:
- Enemy attacks player (reverse hitbox/hurtbox)
- Player death and respawn
- Combo system (punch → punch → kick)
- Environment art (ground, background parallax)
- Hit impact VFX (Bossk)
- Wave system (spawn groups of enemies)
- Game over / victory screen

---

*Sprint 0 is about proving the engine, not shipping the game. If the character moves well and the punch feels right, we've validated everything that matters. The rest is iteration.*

*— Solo, Lead / Chief Architect, First Frame Studios*
