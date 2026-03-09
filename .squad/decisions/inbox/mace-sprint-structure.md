# Sprint Structure & Terminology (Mace Decision)

**Date:** 2026-03-09  
**Owner:** Mace (Producer)  
**Audience:** joperezd (Founder), Solo (Lead), Team  
**Status:** APPROVED & DOCUMENTED

---

## Problem Statement

**Terminology Confusion:** Team has been mixing "Milestone Gates" (M0-M4, checkpoints *within* a sprint) with "Sprints" (major phases like Sprint 0, 1, 2...). This causes:
1. Ambiguous communication ("Is M4 the sprint end or a sprint within a sprint?")
2. Difficulty planning beyond Sprint 0 (do we have 4 phases per sprint, or are phases separate from sprints?)
3. Unclear scope boundaries (what belongs in "Art Phase" vs "UI Phase"?)

**Founder Directive:** Clarify terminology and define consistent sprint structure for Ashfall + future FFS projects.

---

## Terminology Definitions (LOCKED)

### Milestone Gates (M0, M1, M2, M3, M4...)
**Definition:** Checkpoints *within a single sprint* that validate a specific piece of work.  
**Scope:** Smaller than sprint scope; gates are dependencies.  
**Frequency:** Multiple per sprint (typically 4-5 gates per sprint).  
**Example:** In Sprint 0, M0 was "GDD + Architecture approved"; M1 was "buildable scaffold"; M4 was "ship gate".

### Sprints (Sprint 0, 1, 2, 3...)
**Definition:** Major work phases, each with a complete Definition of Success, aligned to content phases.  
**Scope:** Large; includes multiple milestone gates, multiple teams working in parallel.  
**Frequency:** One sprint at a time (though planning for next sprint overlaps).  
**Example:** Sprint 0 (Foundation) delivered a playable 1v1 prototype with core systems. Sprint 1 (Art Phase) will deliver final character art, stage art, animations.

### Key Distinction
- **Milestone Gates** = technical validation checkpoints (did the code/design meet requirements?)
- **Sprints** = content phases (what kind of work are we shipping this phase?)

---

## Ashfall Sprint Structure (LOCKED)

| Sprint | Phase | Duration | Focus | Gate Success Criteria |
|--------|-------|----------|-------|----------------------|
| **Sprint 0** | Foundation | 1 week | Architecture → playable 1v1 prototype → ship | M0: Design approved; M1: Code scaffold; M2: Gameplay loop; M3: HUD/Flow; M4: Ship gate ✅ |
| **Sprint 1** | Art Phase | TBD | Final character art, stage art, animation | M0: Art direction locked; M1: Character sprite sheets; M2: Stage assets; M3: Animation rigging; M4: Art ship |
| **Sprint 2** | UI/UX | TBD | Menu polish, training mode, character select UX | M0: UI spec; M1: Menu layout; M2: Training mode flow; M3: Cosmetics; M4: UX ship |
| **Sprint 3** | Audio + VFX | TBD | SFX, music, particles, screen effects | M0: Audio spec; M1: SFX recording/synthesis; M2: Music composition; M3: Particle polish; M4: Audio ship |
| **Sprint 4+** | Polish | TBD | Advanced AI, netcode, story mode, balance | M0: Feature spec; M1: Implementation; M2: Testing; M3: Tuning; M4: Ship |

---

## Milestone Gate Types (By Phase)

### Sprint 0 (Foundation)
- **M0:** GDD + Architecture approved (design + code contracts)
- **M1:** Buildable scaffold (compiles, runs, loads menu)
- **M2:** Gameplay loop (fighters move, attack, take damage)
- **M3:** Game flow (menu → select → fight → victory)
- **M4:** Ship gate (playtested, P0-free, playable 1v1)

### Sprint 1 (Art Phase)
- **M0:** Art direction locked + asset pipeline defined
- **M1:** Character sprite sheets completed (idle, walk, jump, attacks, hit, block, KO)
- **M2:** Stage background + props completed
- **M3:** Animation rigging + transitions smooth
- **M4:** Art assets integrated, game visually polished, ship ready

### Sprint 2 (UI/UX Phase)
- **M0:** UI/UX spec approved (layout, fonts, colors, interactions)
- **M1:** Menu layouts coded (main, character select, settings)
- **M2:** Training mode flow implemented
- **M3:** Polish pass (animations, transitions, visual feedback)
- **M4:** UX ship gate (playtested, no UI blockers)

### Sprint 3 (Audio+VFX Phase)
- **M0:** Audio spec locked (SFX list, music style, ambience)
- **M1:** SFX pool completed (hit, block, KO, move sounds)
- **M2:** Music composition + in-game integration
- **M3:** Particle effects + screen shake polish
- **M4:** Audio ship gate (no sound clipping, music loops correctly)

### Sprint 4+ (Polish & Expansion)
- **M0:** Feature spec (which features to add/refine)
- **M1:** Implementation
- **M2:** Testing + balance
- **M3:** Refinement
- **M4:** Ship gate (ready for next content release)

---

## Scope Lock Protocol (Per Sprint)

At **sprint start** (Day 1-2):
1. Creative Director (Yoda) and Lead (Solo) define the sprint theme (Art, UI, Audio, etc.)
2. Mace drafts the Definition of Success (using SPRINT-SUCCESS-TEMPLATE.md)
3. Team reviews and approves
4. **Scope is locked** — no feature creep allowed mid-sprint

At **sprint end** (Day 6-7):
1. Verify all criteria met (or document exceptions)
2. Playtest and get verdict
3. File decision document with verdict
4. Create git tag (`sprint-N-shipped`)
5. Begin planning Sprint N+1

---

## Communication Standards

- **In discussions:** "Sprint 0" when talking about phases; "M2 gate" when talking about validation checkpoints
- **In documentation:** Always clarify "Sprint [N] — Definition of Success" vs "M[X] Milestone Gate"
- **In retrospectives:** Distinguish "what slowed down the phase (sprint level)" from "what blocked a specific milestone (gate level)"
- **In planning:** Sprints are planned months ahead (roadmap); milestones are planned sprint-by-sprint (execution)

---

## Owner Responsibilities

- **Mace (Producer):** Owns sprint schedule, milestone definitions, scope lock, Definition of Success framework
- **Solo (Lead Architect):** Owns technical gate validation (M0-M4 code review, integration pass)
- **Yoda (Creative Director):** Owns creative gate validation (M0 design, art direction, balance verdicts)
- **Ackbar (QA):** Owns playtest gate (M4 verdict, bug triage, feel assessment)
- **joperezd (Founder):** Approves sprint scope, final ship decision, major scope changes

---

## Workflow Example (Sprint 1 Kickoff)

**Day 1-2 of Sprint 1:**
1. Yoda + Solo + Mace align on Art Phase scope (2 characters, 1 stage)
2. Mace creates `.squad/decisions/inbox/mace-sprint1-definition.md` with Definition of Success
3. Team approves scope
4. Art phase begins

**Day 3-5:**
1. Nien, Boba, Leia work on character art (parallel streams)
2. Mace monitors load (each agent tracks 20% cap per phase)
3. M1 gate: character sprite sheets completed

**Day 5-6:**
1. Solo integration pass: sprites loaded in Godot, animations rigged, no crashes
2. M3 gate: animation transitions smooth

**Day 6-7:**
1. Ackbar playtests: "Feel is good, no visual gaps"
2. M4 gate: art assets ship-ready
3. Mace files decision: "Sprint 1 — Art Phase SHIPPED"
4. Create tag: `sprint-1-shipped`

---

## Benefits of This Structure

1. **Clarity:** Stakeholders (founder, team) know exactly what "Sprint 0 complete" means (all M0-M4 gates passed + playtest verdicted)
2. **Scalability:** Template works for 2-phase sprints or 8-phase epics; gates adapt
3. **Parallel Planning:** While executing Sprint N, team can plan Sprint N+1 without confusion
4. **Knowledge Reuse:** Each sprint documents learnings, feeds into next sprint's Definition of Success
5. **Release Readiness:** M4 gate = ship criteria; no ambiguity on "is this done?"

---

## Future Revisions

This framework is locked for Ashfall Sprints 0-4. Revisions after Phase 4 (e.g., netcode sprint) will be re-evaluated based on:
- Team feedback on gate granularity
- Actual vs estimated phase durations
- Scope creep patterns observed
- Founder input on roadmap cadence

---

*Mace (Producer) — Locked 2026-03-09*
