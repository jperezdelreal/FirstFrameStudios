# ASHFALL — Sprint 0 Plan

**Status:** Active  
**Sprint Duration:** 1 week (foundation phase)  
**Owner:** Mace (Producer)  
**Project:** Ashfall — 1v1 fighting game in Godot 4  
**Scope:** 1 stage + 2 characters + basic AI + round system + game flow  
**Approval:** joperezd (Founder)

---

## 1. Sprint 0 Goal: Definition of Done

**Vision:** By end of Sprint 0, Ashfall has shipped its **foundations**. Game is **architecture-sound**, **design-locked**, and **ready for content** (Phase 2+).

**Deliverables:**
1. ✅ Game Design Document (GDD) — character archetypes, mechanics, balance pillars, core loop
2. ✅ Architecture Proposal — systems, data flow, state machines, integration contracts
3. ✅ Godot project scaffold — folder structure, autoloads, scenes, physics ready
4. ✅ Core systems foundation — fixed timestep, frame timing, state machine base, input buffer
5. ✅ Art direction document — visual style for characters, stage, effects
6. ✅ Two rectangles fighting — basic movement, attack hitboxes, knockback, hitstun (NO art yet)
7. ✅ Playable build — two characters vs. each other + basic AI opponent

**Non-Goals (explicitly OUT):**
- Character sprites/animations (Phase 2)
- Stage background/environment art (Phase 2)
- Menu system / character select (Phase 3)
- Sound/music (Phase 4)
- Online/networking (Phase 5+)
- Story mode or advanced AI (Phase 5+)
- Additional characters or stages (Post-MVP)

---

## 2. Work Breakdown & Team Assignment

All tasks follow Scrumban (work-in-progress limit of 3 per agent). Each agent owns their domain and commits to public deliverables by sprint end.

### **Yoda — Game Design Document** (Vision Keeper)
- **Goal:** Design lock the fighting game's core mechanics, characters, and balance
- **Deliverables:**
  - GDD: 1-page + detailed mechanics appendix
  - Character archetypes (Fighter A: aggressive/rushdown, Fighter B: defensive/zoner or grappler pattern)
  - Core loop definition (movement → positioning → attack → damage → round → victory)
  - Balance pillars (e.g., "rushdown advantage at close range, zoner advantage at distance")
  - Hit confirm system (which attacks combo into which?)
  - Damage values and hitstun frames
  - Special attack cost/meter system (if any)
- **Dependencies:** None (can start immediately)
- **Acceptance:** GDD is signed off by joperezd, unambiguous for all agents

### **Solo — Architecture Proposal** (Lead Architect)
- **Goal:** Define system structure, state machines, and integration contracts
- **Deliverables:**
  - Architecture Proposal document (4-8 pages)
  - Core systems: Fighter state machine, Combat resolver, Input buffer, Physics/knockback, Frame timer
  - Data flow diagram (input → buffer → state → physics → rendering)
  - Integration contracts between systems (what each system accepts/outputs)
  - Hitbox representation & collision system
  - Score/health/timer management
  - Scene structure (Player scene, AI scene, Stage scene, Manager scene)
  - Decision rationale for Godot-specific choices
- **Dependencies:** Yoda's GDD (for mechanical requirements)
- **Acceptance:** Architecture is approved by Solo, clear enough for Phase 2 implementation

### **Jango — Project Scaffold** (Tool Engineer)
- **Goal:** Build the Godot project structure and core autoloads
- **Deliverables:**
  - Folder structure:
    - `/src/fighters/` (fighter scenes, scripts)
    - `/src/stages/` (stage scenes, collision data)
    - `/src/systems/` (core gameplay systems)
    - `/src/ui/` (HUD, menus)
    - `/src/vfx/` (particle effects, screen shake)
    - `/src/audio/` (SFX, music)
    - `/assets/` (images, fonts)
    - `/docs/` (design docs, architecture)
  - Autoloads: GameManager, InputBuffer, Physics, Timer, EventBus
  - Physics setup: RigidBody2D for fighters, raycast/hitbox detection
  - Input polling system (keyboard state tracking)
  - Scene hierarchy templates (fighter prefab, stage prefab)
  - Build/run instructions (Godot 4.x)
- **Dependencies:** Solo's architecture (for system structure)
- **Acceptance:** Project compiles, empty scenes exist, autoloads load correctly

### **Chewie — Core Systems** (Engine Dev)
- **Goal:** Implement the foundational systems that make combat work
- **Deliverables:**
  - **Fixed timestep loop** — 60 FPS, deterministic frame timing
  - **Input buffer** — 8-frame circular buffer, last-input-wins conflict resolution
  - **State machine base** — Idle, Moving, Attacking, Hitstun, BlockStun (if blocking exists)
  - **Physics engine** — Velocity + acceleration, gravity, ground detection, knockback application
  - **Frame timer & hitstun** — Invulnerability frames, knockdown duration
  - **Hit resolution** — Detect when attacker's hitbox overlaps defender's hurtbox, apply damage
  - **Score/round management** — Track health, round wins, match state (round start, in-progress, end)
  - **Camera system** — Simple follow camera, zoom out if fighters apart, zoom in if close
  - **Integration:** All systems talk via contracts (InputBuffer.getLastInput() → Fighter.applyInput())
  - No AI logic yet (that's Tarkin's job)
- **Dependencies:** Jango's scaffold (for scene structure) + Solo's architecture (for contracts)
- **Acceptance:** Two rectangles can move around, attack, hit each other, take damage, go into hitstun

### **Lando — Fighter Controller & Input** (Gameplay Dev)
- **Goal:** Make fighting feel responsive and punchy
- **Deliverables:**
  - **Fighter controller** — Reads input, applies movement, triggers attacks, respects hitstun
  - **Attack system** — Light/medium/heavy (or special) attack buttons, attack startup/active/recovery frames
  - **Movement** — Walk forward/backward, jump, dash (if designed)
  - **Hit confirm** — Detect combos (attack A into attack B), combo counter on-screen
  - **Knockback & hitstun feel** — Weight, animation smoothing, knockdown states
  - **Input responsiveness validation** — Test input lag, confirm acceptable latency
  - **Damage scaling** — Consecutive hits do less damage (combo scaling)
  - Integration with Chewie's physics and input buffer
  - Integration with Wedge's HUD (pass combo count, hitstun state)
- **Dependencies:** Chewie's core systems + Yoda's mechanics (for move design)
- **Acceptance:** Playtest shows movement feels weighty, attacks have clear startup/active/recovery, combos reward precision

### **Wedge — HUD & Game Flow** (UI Dev)
- **Goal:** Build minimal UI and round/match flow
- **Deliverables:**
  - **Health bars** — Fighter 1 + Fighter 2, clear position, damage feedback
  - **Round counter** — Shows current round and round wins
  - **Match timer** — 99 second timer, counts down, color changes at 10s
  - **Combo counter** — Shows active combo count (e.g., "3x")
  - **Victory screen** — Simple text (Fighter 1 wins! / Fighter 2 wins!)
  - **Game flow** — Start button → round begin → countdown (3, 2, 1, fight!) → round in-progress → round end (ko or timeout) → next round or match end
  - **Simple pause menu** — Pause, resume, quit to menu
  - Integration with Chewie's score system (read health, timer, round wins)
  - Integration with Lando's combo counter
  - No character select yet (Phase 3)
- **Dependencies:** Chewie's score/timer system + Lando's combo system
- **Acceptance:** UI is readable, clear win/loss/ko conditions, game flow is intuitive

### **Boba — Art Direction** (Art Director)
- **Goal:** Define visual identity, style guide, color palette
- **Deliverables:**
  - **Art Direction Document:**
    - Visual style (realistic / stylized / cel-shaded / minimalist?)
    - Color palette (foreground fighter colors, background, effects)
    - Character silhouette reference (distinctive shapes for two characters)
    - Stage mood (arena / street / dojo / digital?)
    - Effect style (impact vfx, sparks, screen shake intensity)
    - HUD visual identity (font, colors, layout philosophy)
  - **Sprite templates** (low-fidelity stand-in for testing proportions)
  - **Stage mockup** (low-res background, stage boundaries)
  - **Quality bar** — Define success criteria for Phase 2 art pass
  - NO final art assets yet (that's Phase 2 for Nien/Leia)
- **Dependencies:** Yoda's character archetypes (for personality reference)
- **Acceptance:** Art direction is cohesive, Nien/Leia have clear target for Phase 2

### **Nien — Character Sprites/Animations** (Character Artist)
- **Status:** Phase 2 work. In Sprint 0, **blocked** (waiting for art direction + final character design from Yoda)
- **Phase 2 goal:** Create idle/walk/attack/hitstun/hit sprites for 2 fighters

### **Leia — Stage Background & Environment** (Environment Artist)
- **Status:** Phase 2 work. In Sprint 0, **blocked** (waiting for art direction + game flow from Wedge)
- **Phase 2 goal:** Create stage background, boundaries, lighting

### **Bossk — Hit Effects & VFX** (VFX Artist)
- **Status:** Phase 4 work. In Sprint 0, **blocked** (waiting for core systems and art direction)
- **Phase 4 goal:** Impact sparks, screen shake, hitstun visual feedback

### **Greedo — Audio (SFX & Music)** (Sound Designer)
- **Status:** Phase 4 work. In Sprint 0, **blocked** (waiting for stable build + mechanics locked)
- **Phase 4 goal:** Hit SFX, announcer callouts, round timer beeps, background music

### **Tarkin — AI Opponent Behavior** (Enemy/Content Dev)
- **Status:** Partially included in Sprint 0. Lightweight AI for playtesting.
- **Deliverables:**
  - **Basic AI controller** — Reads opponent state (distance, health, attacking)
  - **Simple decision tree** — Approach at range < X, attack at optimal range, retreat if low health
  - **No combo AI yet** — Just basic attacks and movement
  - Can be improved in Phase 4
  - Integration with Chewie's fighter state machine and Lando's attack system
- **Dependencies:** Chewie's core systems + Lando's fighter controller
- **Acceptance:** AI opponent moves, attacks, takes damage. Game is playable 1v1

### **Ackbar — Playtesting & Feel Calibration** (QA Lead)
- **Goal:** Validate Sprint 0 build is fun and mechanically sound
- **Deliverables:**
  - **Playtesting sessions** (2-3x during sprint, once complete):
    - Test input responsiveness (is it snappy?)
    - Test hit confirm (are combos discoverable?)
    - Test balance (is either character overpowered?)
    - Test AI (does it feel like a real opponent?)
    - Collect feedback on knockback, hitstun, movement feel
  - **Feedback report** — What feels good, what needs tuning, ranking of priorities for Phase 1
  - **Balance recommendations** — Damage values, hitstun frames, movement speed
  - Verify no crashes or major bugs
- **Dependencies:** Chewie + Lando + Tarkin (stable build)
- **Acceptance:** Build is playable end-to-end, feedback drives Phase 1 priorities

### **Mace — Sprint Planning & Coordination** (Producer)
- **Goal:** Deliver this plan, coordinate handoffs, manage blockers
- **Deliverables:**
  - This SPRINT-0.md document
  - Daily standup (async, in Discord #ashfall channel)
  - Dependency tracking — flag blockers immediately
  - Developer joy checks (1-point survey at mid-sprint + end-sprint)
  - Risk mitigation (see Section 4)
  - Scope enforcement — kill features that creep
  - End-of-sprint retro + learnings capture
- **Dependencies:** All agents (coordinator role)
- **Acceptance:** All deliverables shipped on time, team morale tracked, decisions documented

---

## 3. Dependencies & Critical Path

```
Yoda (GDD) ──┐
             ├─→ Lando (Fighter Controller) ───┐
Solo (Arch)  │                                  │
             ├─→ Chewie (Core Systems) ────────┤
Jango (Scaf) │                                  ├─→ Tarkin (AI) ────┐
             └─→ Boba (Art Direction) ────┐    │                    │
                                          │    │                    ├─→ Ackbar (Playtest)
                                          └─→ Wedge (HUD/Flow) ─────┤
                                               │                    │
                                               └────────────────────┘

Legend:
→ = "blocks" (successor waits for predecessor)
```

**Critical Path (longest chain):**  
Yoda → Lando/Chewie → Wedge → Ackbar (5-6 days, overlapping parallel work)

**Non-blocking work (can start Day 1):**
- Jango (scaffold) — minimal dependencies, unblocks everyone
- Solo (architecture) — can draft in parallel with Yoda
- Boba (art direction) — references GDD but doesn't block code

**Milestone gates:**
- **M0 Gate (Day 2):** Yoda GDD complete + Solo architecture approved (allows Chewie/Lando to start)
- **M1 Gate (Day 3):** Jango scaffold + Chewie core systems up (Lando can integrate)
- **M2 Gate (Day 4):** Lando controller working, AI started
- **M3 Gate (Day 5):** Wedge HUD integrated, game flow playable
- **M4 Gate (Day 6-7):** Full playtest build, balance tuning, ship

---

## 4. Risk Management

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| **Godot physics unexpected** | Medium | High | Chewie does spike test Day 1 (RigidBody2D knockback behavior). If issues, pivot to kinematic approach early. |
| **Input buffer complexity overrun** | Low | Medium | Input buffer is 8-frame circular array — proven pattern from firstPunch. Template exists in skills. Chewie has spike test Day 1. |
| **GDD ambiguity delays others** | Medium | High | Yoda completes GDD Day 1. Solo reviews same day. Any gaps surface immediately. Blocking gate at M0. |
| **AI too hard for scope** | Medium | Medium | Tarkin's AI is *simple* — state-based, not learning. Just approach/attack/retreat. Can ship as "dumb but fair" and improve Phase 4. |
| **Playtesting finds major feel issues** | High | High | Ackbar playtests mid-sprint (Day 4) with rough build. If feel is wrong, Lando has Days 5-7 to adjust. Tuning values (hitstun, knockback) are fast iterations. |
| **Team overload on parallel work** | Low | Medium | 20% load cap enforced. Mace monitors task count. Tarkin's AI is Phase 4 extension (not required for M4 gate). |
| **Scope creep (adding online/story)** | Low | High | This plan explicitly limits scope. Mace kills any feature not in Section 1 deliverables. "Out of scope for Sprint 0" is the answer. |

**Mitigation Strategy:**
- Day 1: All spike tests (Godot physics, input buffer, GDD clarity)
- Day 2-3: Hard gate reviews (Yoda → Solo, Jango, Chewie)
- Day 4: Mid-sprint playtest (catch feel issues early)
- Day 5-7: Tuning loop (balance, bug fixes, ship)

---

## 5. Scope Fence — What Is Explicitly OUT

**Sprint 0 scope is locked to Section 1 deliverables. The following are OUT:**

- ❌ Character select menu (Phase 3)
- ❌ Ranked/leaderboard (Post-MVP)
- ❌ Online multiplayer (Phase 5+)
- ❌ Story mode / character intros (Phase 5+)
- ❌ Advanced AI (learning, adaptive difficulty) — Phase 4
- ❌ Character sprites (Phase 2)
- ❌ Stage background art (Phase 2)
- ❌ Sound effects, music, announcer (Phase 4)
- ❌ Particle effects / screen shake polish (Phase 4)
- ❌ Advanced input systems (motion capture, pad customization) (Phase 4+)
- ❌ Additional characters or stages (Post-MVP)
- ❌ Tutorial / teaching systems (Phase 3+)

**Decision rule:** If it's not in Section 2 deliverables, it's out. Mace enforces this ruthlessly.

---

## 6. Definition of "Done"

Each task is done when:

1. ✅ **Deliverable is complete** — All items in that agent's list shipped
2. ✅ **Code is reviewed** — For code, peer review by another agent or Solo
3. ✅ **Integration test passes** — Code integrates with upstream/downstream systems without breaking
4. ✅ **Acceptance criteria met** — Acceptance criteria in task description are verified
5. ✅ **Documented** — What the code does is clear (comments on complex logic, architecture doc updated)
6. ✅ **Committed to git** — Code is in the repo with clear commit messages

**Slack acceptance:** Task owner posts "Done: [task name]" in #ashfall with a 1-line summary

---

## 7. Schedule & Milestones

| Date | Milestone | Gate | Owner |
|------|-----------|------|-------|
| **Day 1** | Pre-production complete (GDD draft, arch draft, spike tests) | M0: GDD+Arch approved | Yoda, Solo |
| **Day 2** | Scaffold + core systems foundation | M1: Project buildable | Jango, Chewie |
| **Day 3** | Fighter controller integrated, basic AI started | M2: Movement+attacks work | Lando, Tarkin |
| **Day 4** | HUD integrated, full game flow | M3: Game is playable 1v1 | Wedge |
| **Day 4 PM** | Mid-sprint playtest (catch feel issues) | Feedback → tuning list | Ackbar |
| **Day 5-6** | Balance tuning, bug fixes, polish | M4: Stable build ready | All |
| **Day 7** | Final playtest, ship, retro | Sprint 0 complete | Mace + team |

**Working hours:** Flexible (async-first team). Standups daily 8am PT (written, not sync meeting).

---

## 8. Metrics & Success Criteria

### **Quantitative:**
- [ ] Deliverables shipped: 8/8 (GDD, Arch, Scaffold, Core, Controller, HUD, AI, Playtest report)
- [ ] Build stability: Zero crashes during playtest
- [ ] Code review: 100% of code reviewed before merge
- [ ] Task completion: ≥95% of committed tasks done by end-of-sprint
- [ ] Bugs filed: Ackbar files bugs, 90% are fixed before ship

### **Qualitative:**
- [ ] GDD is unambiguous (no follow-up questions from team)
- [ ] Architecture is sound (solo approves, no major refactors needed in Phase 1)
- [ ] Game feels fun (Ackbar feedback is positive on core loop)
- [ ] Fighter controls are responsive (input lag < 1 frame, movement feels weighty)
- [ ] AI feels like an opponent (Ackbar reports AI is challenging but fair)

### **Team Health:**
- [ ] Developer joy survey (1-5): ≥3.5 average
- [ ] No agent overloaded (all < 20% load cap)
- [ ] Knowledge transfer clear (team understands architecture, GDD, pipelines)
- [ ] Blockers resolved (no task stuck > 1 day without escalation to Mace)

---

## 9. Escalation & Communication

**Daily standup:** Async post in #ashfall by 9am PT
- What did you ship yesterday?
- What's blocking you today?
- Do you need help?

**Mid-sprint check-in (Day 4):** Mace reviews progress, plays build, collects feedback

**End-of-sprint retro (Day 7):** Team writes learnings, identifies process improvements for Phase 1

**Blocker escalation:** If any task is stuck > 4 hours, post in #ashfall and ping Mace immediately. Mace unblocks or reallocates work.

---

## 10. Learnings & Decisions Log

This section will be updated as decisions are made during Sprint 0.

### Key Decisions

#### Decision: 1v1 fighting game scope (locked)
- **Date:** 2026-[TBD]
- **Scope:** 1 stage, 2 characters, basic AI, round system
- **Why:** Clear MVP for 1-week sprint. Proves Godot fighting game architecture. Enough content to playtesting hit feel and balance.
- **Out-of-scope:** Online, story, multiple characters/stages, advanced AI → Phase 5+

#### Decision: Godot 4 as engine (locked)
- **Date:** From user request
- **Why:** Godot 4 is battle-tested for 2D action games, good GDScript support, cross-platform export
- **Trade-offs:** Less mature than Unity for VFX, but acceptable for MVP

#### Decision: 20% load cap + Scrumban (locked)
- **Date:** Studio policy (studio-craft skill)
- **Why:** No single agent becomes a bottleneck; parallel work maximizes velocity
- **Enforcement:** Mace tracks task count, reallocates if anyone over 20%

#### Decision: Playtesting mid-sprint (locked)
- **Date:** Studio policy (studio-craft skill)
- **Why:** Early feedback catches feel issues before they compound. Allows 2-3 days for tuning.

---

## Appendix: Agent Load Tracking

| Agent | Sprint 0 Tasks | Load % | Status |
|-------|---|---|---|
| Yoda | GDD | 15% | In Progress |
| Solo | Architecture | 15% | In Progress |
| Jango | Scaffold | 15% | In Progress |
| Chewie | Core Systems | 20% | In Progress |
| Lando | Fighter Controller | 15% | Blocked (awaiting GDD) |
| Wedge | HUD/Flow | 15% | Blocked (awaiting Chewie) |
| Boba | Art Direction | 10% | In Progress |
| Nien | (Phase 2) | 0% | Blocked |
| Leia | (Phase 2) | 0% | Blocked |
| Bossk | (Phase 4) | 0% | Blocked |
| Greedo | (Phase 4) | 0% | Blocked |
| Tarkin | Basic AI | 10% | Blocked (awaiting Chewie) |
| Ackbar | Playtesting | 5% | Standby (mid-sprint) |
| Mace | Sprint Planning & Coordination | 20% | In Progress |

**Total team load:** ~155% (overlapped parallel work — expected). No single agent exceeds 20%.

---

## Appendix: Reference Materials

- `.squad/skills/studio-craft/SKILL.md` — Scrumban, feature triage, developer joy
- `.squad/identity/new-project-playbook.md` — Pre-production protocol, tech decisions
- `.squad/decisions.md` — First Frame Studios governance and architecture patterns
- `games/ashfall/docs/` — GDD, Architecture Proposal, Art Direction (to be written by agents)

---

**Document Owner:** Mace  
**Last Updated:** [TBD on sprint start]  
**Next Review:** End of Sprint 0 (Day 7)

---
