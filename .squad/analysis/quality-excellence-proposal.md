# Quality Excellence Proposal — Ackbar (QA/Playtester)

**Date:** 2025-07-21  
**Requested by:** joperezd  
**Context:** Two game-breaking bugs slipped through Ackbar's "10/10 confidence" audit, forcing Chewie to emergency-fix. This document is a brutally honest self-assessment and a concrete proposal to prevent it from happening again.

---

## Part 1: Self-Assessment — What I Missed and Why

### The Two Bugs I Missed

**Bug #1: Player frozen permanently after being hit**  
- `takeDamage()` set `state = 'hit'` and started decrementing `hitstunTime`, but **no code transitioned the player back to `'idle'` when hitstun expired.** The player was stuck in `'hit'` state forever.
- This was a **missing code path** — the bug existed in what *wasn't* there, not in what was.

**Bug #2: Enemies never approached or attacked unprovoked**  
- The AI set `state = 'attack'` but `aiCooldown` logic immediately overrode it to `'idle'` on the next frame. Combined with the cooldown branch blanket-resetting state, enemies stood still until provoked.
- I actually *identified* the 1-frame attack window in my June 4 audit (C1 bug) but **failed to trace the full execution consequence** — that enemies would also never *approach* because the same AI tick logic was broken.

### Why I Missed Them

**1. I was reading code, not tracing execution.**  
My process was: open file → read function → understand logic → note issues. This catches bugs *in* code but misses bugs caused by *absence* of code. The hitstun bug was a missing `if (state === 'hit' && hitstunTime <= 0) state = 'idle'` — invisible when scanning what IS there.

**2. I treated individual functions as isolated units.**  
I read `takeDamage()` and confirmed hitstunTime was set. I read `update()` and confirmed hitstunTime decremented. I never asked: "OK, and then what? What transitions the state *back*?" I stopped one step short of the full lifecycle.

**3. My confidence was false.**  
I wrote "Confidence: 10/10 — Read every file, traced every import, identified every integration gap." That was hubris. Reading every file is not the same as tracing every state transition to completion. I confused *coverage* (files read) with *depth* (execution paths traced).

**4. I had no structured methodology.**  
My "process" was ad-hoc: read files, note things that look wrong, write them up. There was no checklist that forced me to verify every state's entry, update, AND exit. The regression checklist I created (EX-A4) covers *gameplay scenarios*, not *code invariants*.

**5. I was testing the wrong layer.**  
My DPS analysis, balance calculations, and playtest protocols were all *design-level* QA — "is the game fun?" But I missed *functionality-level* QA — "does the game work?" You can't evaluate feel if the player freezes on first hit.

### Was My Process Thorough Enough?

**No.** My process had three fatal gaps:

| Gap | What I Did | What I Should Have Done |
|-----|-----------|------------------------|
| **State lifecycle** | Read state entry points | Trace entry → update → exit for EVERY state |
| **Negative testing** | Checked "does this code work?" | Also checked "what happens if expected code is MISSING?" |
| **Execution tracing** | Read functions individually | Stepped through frame-by-frame: Frame 0 → Frame 1 → Frame 2 for critical paths |

### What Would Have Caught These Bugs

1. **State machine audit table** — For every state, document: entry condition, per-frame behavior, exit condition. If any cell is empty → bug.
2. **Frame-by-frame execution traces** — Pick a scenario (player gets hit), trace update() across 3-5 consecutive frames. Would have revealed hitstun never exits.
3. **Automated state assertions** — A debug mode that logs state transitions and flags any state held > expected duration.
4. **Adversarial testing mindset** — Instead of "does this work?", ask "how could this break?" For every state, ask "what if exit is missing?"

### Am I the Right Person for Both Testing AND Reviewing?

**No — and here's why.**

Testing (playtesting) and reviewing (code review) require fundamentally different mindsets:

| | Playtesting | Code Review |
|---|-----------|-------------|
| **Focus** | Player experience, feel, balance | Code correctness, architecture, edge cases |
| **Method** | Play the game, try to break it | Read code, trace logic, verify invariants |
| **Skill** | Game design intuition, pattern recognition | Engineering rigor, system thinking |
| **Blind spot** | Assumes code works, tests behavior | Assumes behavior is defined, reviews implementation |

I'm good at playtesting — DPS analysis, balance scoring, feel evaluation. But I clearly failed at code review. The bugs I missed were *code* bugs (missing state transitions), not *design* bugs (bad balance numbers). A dedicated code reviewer would approach the codebase with engineering rigor — tracing every path, verifying every invariant — that I lack.

**My honest recommendation: separate the roles.** I should own playtesting and behavioral QA. A Code Reviewer should own correctness and architecture.

---

## Part 2: Quality Gate Proposal

### 1. Pre-Commit Review Gate

**Proposal: Every code change MUST be reviewed before merging.**

| Gate | Who Reviews | What They Check | Block on Fail? |
|------|------------|----------------|----------------|
| **Code Review** | Dedicated Reviewer (or Solo as lead) | Logic correctness, state machine completeness, edge cases, architecture consistency | ✅ YES — blocks merge |
| **Playtest Smoke** | Ackbar (QA) | Game launches, core loop works, no regressions in 10-point checklist | ✅ YES — blocks merge |
| **Visual Spot-Check** | Boba (Art Director) | No rendering artifacts, style consistency, new art meets quality bar | ⚠️ Advisory for non-visual changes |

**Process:**
1. Developer creates branch, implements change
2. Code Reviewer reads diff, traces affected state machines, approves or requests changes
3. Ackbar runs regression checklist (10 tests, ~5 min)
4. Merge only after both approve

### 2. Automated Testing

**What can be automated for a Canvas game:**

| Test Type | Feasibility | What It Covers | Tooling |
|-----------|------------|----------------|---------|
| **State machine unit tests** | ✅ HIGH | Every state has entry/exit, transitions are valid | Node.js + minimal test runner |
| **Combat math tests** | ✅ HIGH | DPS calculations, damage scaling, knockback physics | Pure function tests |
| **Collision detection tests** | ✅ HIGH | Hitbox overlap, boundary checks | Pure function tests |
| **AI behavior tests** | ✅ MEDIUM | Enemy approaches, attacks cycle, throttle limits | Headless game loop simulation |
| **Regression assertions** | ✅ MEDIUM | State duration limits, transition completeness | Debug overlay hooks |
| **Visual regression** | ⚠️ LOW | Screenshot comparison per frame | Canvas snapshot + pixel diff (fragile) |
| **Performance benchmarks** | ✅ MEDIUM | Frame time under entity count thresholds | Automated game loop with timers |

**Priority implementation order:**
1. **State machine tests** (catch the exact class of bug I missed) — Week 1
2. **Combat math tests** (catch balance regressions) — Week 1
3. **AI behavior tests** (catch passive enemy bugs) — Week 2
4. **Performance benchmarks** (catch FPS drops) — Week 3

**Concrete test examples:**
```
TEST: Player exits 'hit' state after hitstunTime expires
  - Create player, set state='hit', hitstunTime=0.2
  - Call update(0.1), assert state === 'hit'
  - Call update(0.1), assert state === 'hit' (hitstunTime just hit 0)
  - Call update(0.016), assert state === 'idle'  ← THIS catches Bug #1

TEST: Enemy approaches player when in range
  - Create enemy at x=500, player at x=100
  - Call AI.updateEnemy() for 60 frames
  - Assert enemy.x < 500 (moved toward player)  ← THIS catches Bug #2

TEST: Every state has an exit path
  - For each state in STATE_LIST:
    - Set entity to that state
    - Run update() for 600 frames (10 seconds)
    - Assert state !== initial_state OR state is terminal ('dead')
```

### 3. Playtest Protocols

**Structured playtesting with metrics — run after every significant change:**

#### Quick Smoke Test (2 minutes, every change)
- [ ] Game loads without console errors
- [ ] Player can move all 4 directions
- [ ] Player can punch, kick, jump
- [ ] Enemies approach and attack
- [ ] Player takes damage and recovers
- [ ] At least one enemy can be killed
- [ ] Wave transitions work

#### Full Playtest (10 minutes, every milestone)
- [ ] Complete all 3 waves
- [ ] Record clear time per wave
- [ ] Record final HP
- [ ] Record deaths (if any)
- [ ] Rate combat feel (1-10): responsive? impactful? fair?
- [ ] Rate difficulty (1-10): too easy? too hard? engaging?
- [ ] Note any visual glitches or audio issues
- [ ] Run full 10-point regression checklist

#### Adversarial Playtest (15 minutes, before ship)
- [ ] Spam every attack type rapidly
- [ ] Walk into every boundary
- [ ] Pause/unpause during every state
- [ ] Let enemies hit player repeatedly
- [ ] Attempt to break combo system
- [ ] Stand still and observe AI behavior for 30 seconds
- [ ] Alt-tab during gameplay, return
- [ ] Open dev console during gameplay

#### Metrics to Track
| Metric | Target | Red Flag |
|--------|--------|----------|
| Wave 1 clear time | 8-15s | < 5s (too easy) or > 25s (too hard) |
| Wave 2 clear time | 12-20s | < 8s or > 30s |
| Wave 3 clear time | 15-25s | < 10s or > 35s |
| Final HP (3-wave run) | 40-80% | > 90% (no threat) or < 20% (unfair) |
| Deaths per run | 0-1 | 0 always (no threat) or 3+ (unfair) |
| Combat feel score | 7+/10 | < 5/10 |
| Jump attack usage | < 40% of attacks | > 60% (still OP) |

### 4. Bug Severity Matrix

| Severity | Definition | Examples | Ship Blocker? | Fix Timeline |
|----------|-----------|----------|---------------|-------------|
| **🔴 CRITICAL** | Game unplayable or player stuck | Player freeze, infinite loop, crash on load, enemies never attack | ✅ BLOCKS SHIP | Fix immediately, drop everything |
| **🟠 HIGH** | Core mechanic broken but game continues | Audio crashes, score not saved, combo system broken, hitboxes wrong | ✅ BLOCKS SHIP | Fix within 24 hours |
| **🟡 MEDIUM** | Feature doesn't work but workaround exists | Dead code loaded, particle system unused, HUD element missing | ⚠️ SHIP WITH KNOWN ISSUES | Fix in next sprint |
| **🟢 LOW** | Minor polish issue | Slight hitbox mismatch, timer precision fragility, animation stiffness | ❌ DOES NOT BLOCK | Fix when convenient |
| **⚪ COSMETIC** | Visual-only, no gameplay impact | Font inconsistency, color mismatch, alignment off by pixels | ❌ DOES NOT BLOCK | Backlog |

**Decision rule:** If we disagree on severity, the higher rating wins. Ship-blocking bugs require unanimous "fixed" verdict from both Code Reviewer and QA.

### 5. Reviewer Role

**Proposal: Create a dedicated Code Reviewer role, separate from QA.**

| Responsibility | QA (Ackbar) | Code Reviewer (New Role) |
|---------------|-------------|-------------------------|
| Play the game | ✅ Primary | ❌ Not responsible |
| Read code diffs | ⚠️ For context | ✅ Primary |
| Trace state machines | ⚠️ Basic check | ✅ Deep trace |
| Verify invariants | ❌ | ✅ Primary |
| Balance evaluation | ✅ Primary | ❌ |
| Feel assessment | ✅ Primary | ❌ |
| Architecture review | ❌ | ✅ Primary |
| Performance review | ⚠️ Metrics only | ✅ Code-level |
| Approve merge? | ✅ Behavioral gate | ✅ Correctness gate |

**Who should fill this role?**
- **Option A:** Solo (Lead) absorbs code review — already has architecture knowledge, but adds to workload
- **Option B:** New dedicated agent — cleanest separation, but adds team size
- **Option C:** Chewie (Engine Dev) reviews gameplay code, Lando (Gameplay Dev) reviews engine code — cross-review, builds shared knowledge

**My recommendation: Option C (cross-review)** for now. It's zero additional headcount, builds shared codebase knowledge, and catches the "author blind spot" where the person who wrote the code can't see their own gaps. If workload becomes unsustainable, escalate to Option B.

### 6. Performance Budgets

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| **FPS** | ≥ 60 | < 55 | < 45 |
| **Frame time** | ≤ 16.67ms | > 18ms | > 22ms |
| **Entity count** | ≤ 12 active | > 15 | > 20 |
| **VFX count** | ≤ 30 particles | > 50 | > 80 |
| **Collision checks/frame** | ≤ 24 (12×2) | > 40 | > 60 |
| **Memory (heap)** | ≤ 50MB | > 75MB | > 100MB |
| **Load time** | ≤ 2s | > 3s | > 5s |

**Enforcement:**
- Debug overlay already shows FPS, frame time, entity count, VFX count, collision checks
- Add console warning when any metric hits "Warning" threshold
- Add console error + visual indicator when any metric hits "Critical"
- Performance test: run 3 waves with max enemies, assert no frame > 22ms

### 7. Visual Quality Gates

**How to objectively assess "does this look good enough?"**

| Quality Dimension | Score 1-3 (Fail) | Score 4-6 (Acceptable) | Score 7-9 (Good) | Score 10 (Excellent) |
|------------------|------------------|----------------------|------------------|---------------------|
| **Character readability** | Can't tell who's who | Recognizable with effort | Instantly recognizable | Iconic, memorable silhouettes |
| **Animation fluidity** | Static or broken | Functional (walk/attack) | Smooth with personality | Anticipation + follow-through + squash/stretch |
| **Background depth** | Flat color | Basic parallax | Layered with landmarks | Living world with props + movement |
| **Effect impact** | No feedback | Basic flash/shake | Particles + numbers + slow-mo | Stylized, genre-appropriate, satisfying |
| **UI clarity** | Missing info | All info shown | Readable at a glance | Themed, animated, polished |
| **Style cohesion** | Inconsistent | Mostly consistent | Unified style guide | Every pixel feels intentional |

**Current scores:** Character 6, Animation 4, Background 5, Effects 5, UI 6, Cohesion 6 → **Average: 5.3/10**

**Ship threshold:** Average ≥ 6.5/10, no dimension below 5/10.

**Review process:**
1. Boba (Art Director) scores each dimension after visual changes
2. Ackbar (QA) provides "first impression" score (player perspective)
3. If scores diverge by > 2 points, discuss and recalibrate
4. Block ship if any dimension < 5 or average < 6.5

---

## Part 3: Team Assessment — Do We Need More Roles?

### Current Team Gaps

| Gap | Impact | How Often It Bites Us |
|-----|--------|----------------------|
| **No code review** | Game-breaking bugs ship | Already happened twice |
| **No progress tracking** | No visibility into what's done vs. planned | Every session |
| **No art-code bridge** | Art systems exist but aren't integrated (particle system dead code) | Ongoing |

### Role Analysis

#### Code Reviewer (Separate from QA)
- **Need:** ✅ **YES — highest priority**
- **Evidence:** The two bugs I missed were code-level issues, not design-level. A reviewer tracing state machines would have caught both in minutes.
- **Recommendation:** Cross-review (Chewie ↔ Lando) before adding headcount. If that creates bottlenecks, add dedicated role.

#### Producer (Progress Tracker)
- **Need:** ⚠️ **NICE TO HAVE, not critical**
- **Evidence:** Solo (Lead) currently handles prioritization and scope. The team is small enough that a formal producer adds overhead without proportional value.
- **Recommendation:** Solo absorbs lightweight tracking. Use a simple kanban (TODO/DOING/DONE) in a decisions file. Only add Producer if team grows beyond 10 active members or if scope creep becomes a recurring problem.

#### Technical Artist (Art-Code Bridge)
- **Need:** ⚠️ **NICE TO HAVE, not critical**
- **Evidence:** The particle system dead code and VFX integration gaps suggest an art-code disconnect. But Boba + Chewie can coordinate directly.
- **Recommendation:** Boba and Chewie pair on integration tasks. If rendering optimization becomes a bottleneck (Canvas perf, sprite batching), revisit.

### My Recommendation

**Add one process, not three roles:**

1. **Implement cross-code-review** (Chewie ↔ Lando) — catches code bugs, zero new headcount
2. **Implement the playtest protocol above** — catches behavioral bugs, makes my work structured instead of ad-hoc
3. **Add state machine unit tests** — catches the *exact class* of bug that slipped through, automated forever
4. **Keep team size as-is** — 12 active members is already large. Process > headcount.

If after implementing these four changes, bugs still slip through, *then* add a dedicated Code Reviewer role. But I believe better process will solve 90% of the problem without adding complexity.

---

## Summary: The Honest Truth

I failed. I called my audit "10/10 confidence" and missed two bugs that made the game unplayable. The root cause wasn't laziness — I read every file. The root cause was **methodology**: I was reading code instead of tracing execution, and I was looking for what was wrong instead of what was missing.

The fix isn't to replace me. The fix is:
1. **Give me a structured process** (state lifecycle audits, frame-by-frame traces)
2. **Add a second pair of eyes** (cross-code-review between engineers)
3. **Automate the invariants** (state machine tests that catch missing exit paths)
4. **Separate the concerns** (I own "does it feel good?", reviewer owns "does it work?")

Excellence isn't one person being perfect. It's a system that catches what any one person misses.

---

*Written by Ackbar (QA/Playtester) — firstPunch Squad*  
*"It's a trap!" — and I walked right into the trap of overconfidence.*
