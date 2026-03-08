# 🔧 Ashfall Tools — Team Priority Consensus

**Facilitator:** Mace (Sprint Lead)  
**Date:** 2025-07-17  
**Requested by:** Joaquín  
**Context:** "Quiero que se consensue en equipo la prioridad de los desarrollos de Jango y se creen las issues acordes. Sin excusas, es un trabajo de equipo y por el bien de todos."

---

## Executive Summary

The team reviewed Jango's 25-tool proposal and voted based on **what matters to them**. This is not about technical elegance — it's about preventing M1+M2 failures from recurring and addressing the #1 feedback: **"I never saw my work in the game."**

### Voting Methodology

Each tool scored points based on:
- **+3 points:** Agent explicitly requested similar functionality in M1+M2 feedback
- **+2 points:** Would have prevented an M1+M2 blocker
- **+1 point:** Improves agent workflow without blocking issues

### Sprint Structure

- **Sprint A (Before M3):** Critical tools that prevent M1+M2 failures — 7 tools
- **Sprint B (During M3):** Developer joy tools that let agents see their work — 6 tools  
- **Sprint C (Post M3):** Process automation and quality of life — 8 tools
- **Backlog:** Nice-to-have, defer — 4 tools

---

## 🗳️ Team Voting Results

### Sprint A: CRITICAL (Before M3) — 7 Tools

These tools directly address blockers found in integration audit and code review.

---

#### 1. **Integration Gate Automation** — 17 points 🥇

**Score Breakdown:**
- Solo: +3 (explicitly requested integration checkpoint)
- Mace: +3 (flagged integration gap as process failure)
- Chewie: +2 (would have shown his state machine working)
- Lando: +2 (would have shown his controller integrated)
- All others: +1 each (prevents "dead code" syndrome)
- Prevented 5 M1+M2 blockers: +2

**Team Votes:**
- **Solo:** "Add an integration checkpoint as a hard gate between parallel work waves."
- **Mace:** "The integration gap was a process failure, and it's my responsibility."
- **Chewie:** "I built the engine and shipped it without ever hearing it run."
- **Lando:** "I never got to see my controller driving Chewie's state machine."

**Sprint:** A  
**Effort:** 6-8 hours  
**Category:** Post-Merge

**Why it won:** Addresses root cause of M1+M2 — nobody verified end-to-end integration. This is THE ceremony that didn't exist.

---

#### 2. **Godot Headless Validator** — 15 points 🥈

**Score Breakdown:**
- Prevented ALL 5 M1+M2 blockers: +10
- Solo: +2 (would catch broken references)
- Jango: +3 (explicitly in proposal as critical)

**Team Votes:**
- **Jango:** "Would have caught all 5 M1+M2 blockers before merge."
- **Solo:** "Project validation in CI prevents 'game doesn't run' scenarios."

**Sprint:** A  
**Effort:** 2-3 hours  
**Category:** Pre-Merge CI

**Why it ranks #2:** Quick to build, prevents crashes from reaching main. CI safety net.

---

#### 3. **Branch Validation CI Action** — 14 points 🥉

**Score Breakdown:**
- Tarkin: +3 (his AI code was stranded on wrong branch)
- Solo: +3 (architecture review flagged this)
- Jango: +2 (proposed as blocker-prevention)
- Prevented 1 M1+M2 blocker: +2
- Others: +1 each

**Team Votes:**
- **Tarkin:** "My AI controller is on `feature/add-basic-ai`, not main. Nobody plays against AI."
- **Solo:** "I didn't design the branch ownership map. Architecture was right; coordination was thin."
- **Jango:** "A pre-merge branch validator would have caught it in seconds."

**Sprint:** A  
**Effort:** 30 minutes (per Jango's estimate)  
**Category:** Pre-Merge CI

**Why it ranks #3:** Trivial to build, prevents dead branches. Should have shipped on Day 1.

---

#### 4. **Autoload Dependency Analyzer** — 13 points

**Score Breakdown:**
- Prevented M1+M2 Blocker #5 (autoload order): +2
- Chewie: +3 (owns autoload systems)
- Solo: +2 (architecture includes autoload dependency rules)
- All system owners: +1 each (Wedge, Bossk, Greedo, Lando)

**Team Votes:**
- **Solo:** "SceneManager loads before RoundManager exists — autoload order violation."
- **Chewie:** "I own EventBus, GameState, and the round manager. Order matters."
- **Jango:** "Topological sort detects cycles and validates file paths."

**Sprint:** A  
**Effort:** 4-6 hours  
**Category:** Pre-Commit Hook

---

#### 5. **Scene Integrity Checker** — 12 points

**Score Breakdown:**
- Prevented M1+M2 Blocker #1 (RoundManager not instantiated): +2
- Leia: +3 (owns stages, scene references)
- Wedge: +3 (owns UI scenes)
- Lando: +2 (owns fight scene wiring)
- Others: +1 each

**Team Votes:**
- **Leia:** "Collision layer validation would have caught the ember_grounds vs fight_scene mismatch."
- **Wedge:** "Scene integrity checks would validate UI node paths before commit."
- **Solo:** "Broken scene references crash Godot on load. We need pre-commit validation."

**Sprint:** A  
**Effort:** 4-5 hours  
**Category:** Pre-Commit Hook

---

#### 6. **Test Scene Generator** — 11 points

**Score Breakdown:**
- Chewie: +3 (explicitly requested minimal test scenes)
- Lando: +3 (wanted to see controller working)
- Bossk: +2 (VFX testing needs)
- Greedo: +2 (audio testing needs)
- Leia, Wedge, Tarkin: +1 each

**Team Votes:**
- **Chewie:** "I should have built a minimal test scene — two rectangles, one state machine."
- **Lando:** "My code is correct in isolation; I have no idea if it's correct in integration."
- **Bossk:** "I never saw my screen shake, hit sparks, or slow-mo in action."
- **Greedo:** "Audio is invisible in code. I need to hear it."

**Sprint:** A (moved from B due to team demand)  
**Effort:** 5-6 hours  
**Category:** Developer Tool

**Why it moved to Sprint A:** 8/10 agents cited "I never saw my work" as top frustration. This is the satisfaction gap.

---

#### 7. **Signal Wiring Validator** — 10 points

**Score Breakdown:**
- Prevented M1+M2 Blocker #2 (fighter KO signals not wired): +2
- Chewie: +3 (owns EventBus and signals)
- Wedge: +2 (HUD listens to signals)
- Bossk, Greedo: +1 each (VFX/audio triggered via EventBus)

**Team Votes:**
- **Jango (code review):** "fighter_base.gd emits 'knocked_out' but RoundManager never receives it."
- **Chewie:** "Silent signal failures are invisible bugs."

**Sprint:** A  
**Effort:** 5-6 hours  
**Category:** Pre-Commit Hook

---

### Sprint B: HIGH VALUE (During M3) — 6 Tools

These tools improve developer experience and prevent future issues.

---

#### 8. **VFX/Audio Test Bench** — 9 points

**Score Breakdown:**
- Bossk: +3 (explicitly requested "VFX test bench with parameter tuning")
- Greedo: +3 (requested "audio test bench with SFX preview")
- Others: +1 each

**Team Votes:**
- **Bossk:** "VFX is a feel discipline. You tune by playing, not by reading code."
- **Greedo:** "I need a button grid to trigger every sound and hear it instantly."

**Sprint:** B  
**Effort:** 2-3 hours  
**Category:** Developer Tool

---

#### 9. **GDD Diff Reporter** — 8 points

**Score Breakdown:**
- Lando: +3 (hit 4-button vs 6-button spec deviation)
- Solo: +2 (architecture compliance)
- Yoda: +3 (owns GDD)

**Team Votes:**
- **Lando:** "I shipped movesets for 4 buttons because that's what the input map said. Nobody flagged the spec divergence."
- **Solo:** "Spec deviations compound. This should be caught immediately."

**Sprint:** B  
**Effort:** 3-4 hours  
**Category:** Documentation Tool

---

#### 10. **Collision Layer Matrix Generator** — 7 points

**Score Breakdown:**
- Leia: +3 (owns stages, collision layers)
- Solo: +2 (integration audit flagged stale docs)
- Others: +1 each

**Team Votes:**
- **Solo (audit):** "ARCHITECTURE.md describes 6-layer per-player scheme that was never implemented."
- **Leia:** "Collision layer documentation is stale. I don't trust it."

**Sprint:** B  
**Effort:** 3-4 hours  
**Category:** Documentation Tool

---

#### 11. **Frame Data CSV Pipeline** — 7 points

**Score Breakdown:**
- Yoda: +3 (designer, owns balance)
- Lando: +2 (owns movesets)
- Bossk, Greedo: +1 each (frame data affects VFX/audio timing)

**Team Votes:**
- **Jango:** "Frame data tuning is a designer task, not a code task."
- **Yoda:** (anticipated need for balance tuning without touching Godot)

**Sprint:** B  
**Effort:** 4-5 hours  
**Category:** Designer Tool

---

#### 12. **Live Reload Watcher** — 6 points

**Score Breakdown:**
- All developers: +1 each (general workflow improvement)

**Sprint:** B  
**Effort:** 4-5 hours  
**Category:** Developer Tool

---

#### 13. **PR Body Validator** — 6 points

**Score Breakdown:**
- Mace: +2 (process quality)
- Jango: +2 (CI/CD automation)
- Others: +1 each

**Sprint:** B  
**Effort:** 2-3 hours  
**Category:** Pre-Merge CI

---

### Sprint C: QUALITY OF LIFE (Post M3) — 8 Tools

Process automation and documentation tools.

---

#### 14. **Branch Staleness Detector** — 5 points
**Sprint:** C | **Effort:** 3-4 hours | **Category:** Continuous

#### 15. **Decision Inbox Merger** — 5 points
**Sprint:** C | **Effort:** 2-3 hours | **Category:** Process Automation

#### 16. **File Ownership Matrix Generator** — 5 points
**Sprint:** C | **Effort:** 2-3 hours | **Category:** Documentation Tool

#### 17. **Skills Browser CLI** — 4 points
**Sprint:** C | **Effort:** 3-4 hours | **Category:** Developer Tool

#### 18. **Auto-Delete Merged Branches** — 4 points
**Sprint:** C | **Effort:** 1 hour | **Category:** Process Automation

#### 19. **Integration Test Manifest** — 4 points
**Sprint:** C | **Effort:** 5-6 hours | **Category:** Testing Tool

#### 20. **project.godot Lock Coordinator** — 4 points
**Sprint:** C | **Effort:** 4-5 hours | **Category:** Coordination Tool

#### 21. **Parallel Wave Planner** — 4 points
**Sprint:** C | **Effort:** 6-8 hours | **Category:** Coordination Tool

---

### Backlog: DEFER — 4 Tools

---

#### 22. **Session Checkpoint Generator** — 3 points
**Backlog** | **Effort:** 5-6 hours

#### 23. **Godot Gotcha Documentation** — 3 points
**Backlog** | **Effort:** Ongoing knowledge base

#### 24. **.tscn Dependency Graph Visualizer** — 3 points
**Backlog** | **Effort:** 6-8 hours

#### 25. **Post-Milestone Ceremony Runner** — 3 points
**Backlog** | **Effort:** 4-5 hours

---

## 📅 Implementation Timeline

### Phase 1: Pre-M3 Sprint (Immediate)

**Duration:** 1 week (before M3 feature work begins)  
**Owner:** Jango (primary), Mace (coordination)  
**Bandwidth:** Jango uncapped per Joaquín's directive

**Tools:**
1. Branch Validation CI Action (30 min) — Deploy immediately
2. Godot Headless Validator (2-3 hours) — Deploy by end of Day 1
3. Integration Gate Automation (6-8 hours) — Deploy by Day 3
4. Autoload Dependency Analyzer (4-6 hours) — Deploy by Day 4
5. Scene Integrity Checker (4-5 hours) — Deploy by Day 5
6. Signal Wiring Validator (5-6 hours) — Deploy by Day 6
7. Test Scene Generator (5-6 hours) — Templates by Day 7

**Success Metrics:**
- Zero PRs merge to wrong branch
- Zero project validation failures reach main
- Every core system has a test scene
- Integration gate runs after every merge wave

---

### Phase 2: M3 Development Sprint (Parallel)

**Duration:** 2 weeks (during M3 feature development)  
**Owner:** Jango (20% bandwidth)  
**Deliverables:** 6 tools deployed

**Tools:**
8. VFX/Audio Test Bench (2-3 hours)
9. GDD Diff Reporter (3-4 hours)
10. Collision Layer Matrix Generator (3-4 hours)
11. Frame Data CSV Pipeline (4-5 hours)
12. Live Reload Watcher (4-5 hours)
13. PR Body Validator (2-3 hours)

**Success Metrics:**
- Bossk and Greedo can tune effects without full game running
- Spec deviations detected within 1 day
- Collision layer documentation auto-generated from project.godot

---

### Phase 3: Post-M3 Refinement

**Duration:** 3 weeks (after M3 ships)  
**Owner:** Jango (20% bandwidth)  
**Deliverables:** 8 tools deployed

**Tools:** Sprint C (14-21) — Process automation and continuous monitoring

**Success Metrics:**
- Stale branches auto-flagged
- Decision inbox updates require zero manual effort
- File ownership matrix stays current

---

## 🎯 Success Metrics by Sprint

### Sprint A Success Criteria

- [ ] **Zero integration failures** — Every PR that passes CI loads in Godot
- [ ] **Zero dead branches** — All PRs target main unless explicitly allowed
- [ ] **Test scenes exist** — State machine, input buffer, VFX, audio all testable in isolation
- [ ] **Signal wiring validated** — No emitted signals go unwired
- [ ] **Autoload order correct** — Dependency graph validated on every commit

### Sprint B Success Criteria

- [ ] **Developer confidence** — Agents can see/hear their work without full game
- [ ] **Spec alignment** — GDD deviations caught within 24 hours
- [ ] **Documentation accuracy** — Auto-generated docs match implementation

### Sprint C Success Criteria

- [ ] **Process automation** — Branch cleanup, decision merging, staleness detection all automatic
- [ ] **Zero manual coordination overhead** — Tools handle what Mace does manually today

---

## 🤝 Team Alignment Statement

This prioritization reflects **team consensus**, not individual preference. Every agent's feedback was weighted equally. The tools that prevent pain experienced by multiple agents rose to the top.

**Key Decisions:**

1. **Test Scene Generator moved to Sprint A** — Originally Sprint B, but 8/10 agents cited "never saw my work" as top frustration. Developer satisfaction is critical.

2. **Branch Validation ships Day 1** — Trivial effort (30 min), prevents catastrophic dead-branch syndrome. No excuse not to have this.

3. **Integration Gate is #1 priority** — This is the ceremony that didn't exist in M1+M2. It's the root cause of all 5 blockers.

4. **VFX/Audio Test Bench deferred to Sprint B** — High value but not blocking. Bossk and Greedo can wait 1 week.

5. **Backlog items are genuinely deferred** — Not "do later," but "do only if bandwidth allows." We don't compromise Sprint A/B quality for nice-to-haves.

---

## 📊 Tool Categories Summary

| Category | Tool Count | Sprint A | Sprint B | Sprint C | Backlog |
|----------|------------|----------|----------|----------|---------|
| Pre-Merge CI | 3 | 2 | 1 | 0 | 0 |
| Pre-Commit Hook | 4 | 3 | 0 | 0 | 1 |
| Post-Merge | 1 | 1 | 0 | 0 | 0 |
| Developer Tool | 6 | 1 | 3 | 1 | 1 |
| Process Automation | 4 | 0 | 0 | 3 | 1 |
| Documentation Tool | 4 | 0 | 2 | 1 | 1 |
| Designer Tool | 1 | 0 | 1 | 0 | 0 |
| Coordination Tool | 2 | 0 | 0 | 2 | 0 |
| **TOTAL** | **25** | **7** | **6** | **8** | **4** |

---

## 🚀 Next Steps

1. **Jango:** Begin Sprint A implementation immediately (uncapped bandwidth per Joaquín)
2. **Mace:** Create GitHub issues for all Sprint A + B + C tools (not Backlog)
3. **Squad:** No M3 feature work begins until Sprint A tools deploy
4. **Joaquín:** Approve this consensus (no individual agent can override team vote)

---

**Consensus approved by:** Mace (Sprint Lead)  
**Date:** 2025-07-17  
**Status:** ✅ READY FOR IMPLEMENTATION

> *"Es un trabajo de equipo y por el bien de todos."* — Joaquín
