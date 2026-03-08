# Tool Priority Summary — For Joaquín

**Date:** 2025-07-17  
**Facilitator:** Mace  
**Context:** Team consensus voting on Jango's 25-tool proposal

---

## ✅ Status: CONSENSUS REACHED

The team voted on all 25 tools. Prioritization complete. Ready for implementation.

---

## 🎯 Top 3 Tools (Start Immediately)

### 🥇 #1: Integration Gate Automation (17 points)
**Why:** Would have caught ALL 5 M1+M2 blockers  
**Impact:** Prevents "dead code" syndrome permanently  
**Effort:** 6-8 hours  
**Status:** Issue #33 already created

### 🥈 #2: Godot Headless Validator (15 points)
**Why:** Makes "does the project load?" a pre-merge requirement  
**Impact:** Catches crashes before they reach main  
**Effort:** 2-3 hours (quick win!)  
**Status:** Issue #35 already created

### 🥉 #3: Branch Validation CI (14 points)
**Why:** Prevents Tarkin-style dead branch disasters  
**Impact:** Zero dead branches, zero ongoing effort  
**Effort:** 30 minutes (trivial setup!)  
**Status:** Issue #34 already created

---

## 📊 Sprint Breakdown

| Sprint | Phase | Tool Count | Timeline | Priority |
|--------|-------|------------|----------|----------|
| **A** | Before M3 | 7 tools | 1 week | Critical |
| **B** | During M3 | 6 tools | 2 weeks | High |
| **C** | Post M3 | 8 tools | 3 weeks | Medium |
| **Backlog** | Defer | 4 tools | TBD | Low |

---

## 🔴 Sprint A: MUST HAVE (Before M3)

These tools prevent M1+M2 failures from recurring:

1. **Integration Gate Automation** (17 pts) — Root cause fix
2. **Godot Headless Validator** (15 pts) — CI safety net
3. **Branch Validation CI** (14 pts) — 30 min, permanent fix
4. **Autoload Dependency Analyzer** (13 pts) — Prevents crashes
5. **Scene Integrity Checker** (12 pts) — Validates references
6. **Test Scene Generator** (11 pts) — **Moved from B due to team demand**
7. **Signal Wiring Validator** (10 pts) — Catches unwired signals

**Why Test Scene Generator moved to Sprint A:**  
8/10 agents cited "I never saw my work in the game" as their #1 frustration. Developer satisfaction is not optional.

---

## 🟡 Sprint B: HIGH VALUE (During M3)

Developer joy and process quality:

8. **VFX/Audio Test Bench** (9 pts) — Bossk/Greedo can tune effects
9. **GDD Diff Reporter** (8 pts) — Catches spec deviations
10. **Collision Layer Matrix Generator** (7 pts) — Auto-gen docs
11. **Frame Data CSV Pipeline** (7 pts) — Designer balance tool
12. **Live Reload Watcher** (6 pts) — Faster iteration
13. **PR Body Validator** (6 pts) — Process quality

---

## 🟢 Sprint C: QUALITY OF LIFE (Post M3)

Process automation (8 tools, 3-week timeline). See full document for details.

---

## 💡 Key Insights from Team Voting

### What the team REALLY wants:

1. **"Let me see my work"** — 8/10 agents never saw their code running
2. **"Catch my mistakes early"** — Pre-commit hooks > post-merge cleanup
3. **"Don't make me guess"** — Auto-generated docs > stale docs
4. **"Protect me from process failures"** — CI gates > manual checklists

### What surprised us:

- **Test Scene Generator** scored higher than expected (moved to Sprint A)
- **Branch Validation** is trivial (30 min) but critical (prevents Tarkin scenario)
- **Integration Gate** is unanimous — every agent voted for it

---

## 🚀 Recommended Action Plan

### Phase 1: Immediate (This Week)

1. **Jango:** Uncapped bandwidth per your directive
2. **Deploy top 3 tools in 48 hours:**
   - Branch Validation CI (30 min) — Ship today
   - Godot Headless Validator (2-3 hours) — Ship tomorrow
   - Integration Gate (6-8 hours) — Ship by end of week
3. **Block M3 feature work** until Sprint A tools deploy

### Phase 2: Sprint A Completion (1 Week)

- Complete remaining 4 Sprint A tools
- Every core system gets a test scene
- Pre-commit hooks catch mistakes before review

### Phase 3: Parallel with M3 (2 Weeks)

- Jango returns to 20% bandwidth
- Deploy Sprint B tools during M3 development
- Developer experience improvements

---

## 📈 Success Metrics

### Sprint A (Before M3):
- ✅ Zero PRs merge to wrong branch
- ✅ Zero project load failures reach main
- ✅ Every agent can see their work running
- ✅ Integration gate runs after every merge

### Sprint B (During M3):
- ✅ Bossk/Greedo tune effects without full game
- ✅ Spec deviations caught within 24 hours
- ✅ Collision docs auto-generated

### Sprint C (Post M3):
- ✅ Process fully automated
- ✅ Zero manual coordination overhead

---

## 🤝 Team Alignment

**This is team consensus.** Every agent's vote counted equally. The tools that prevent shared pain rose to the top.

**No agent can override this prioritization.** This is the team's decision, not Jango's alone.

---

## 📝 Next Steps

1. ✅ **DONE:** Team voting complete
2. ✅ **DONE:** Priority document written (games/ashfall/docs/TOOLS-PRIORITY.md)
3. ⏳ **TODO:** Create 18 GitHub issues (Sprint A + B + C)
4. ⏳ **TODO:** Jango begins Sprint A implementation
5. ⏳ **TODO:** M3 feature freeze until Sprint A deploys

---

## 📄 Full Documentation

- **Full priority document:** `games/ashfall/docs/TOOLS-PRIORITY.md`
- **Tool proposals:** `games/ashfall/docs/TOOLS-PROPOSAL.md`
- **Team feedback:** `games/ashfall/docs/TEAM-FEEDBACK-M1M2.md`
- **Integration audit:** `.squad/decisions/inbox/solo-integration-audit.md`

---

**Prepared by:** Mace (Sprint Lead)  
**Approved by:** Team consensus  
**Status:** ✅ Ready for your approval

> *"Es un trabajo de equipo y por el bien de todos."* — Joaquín
