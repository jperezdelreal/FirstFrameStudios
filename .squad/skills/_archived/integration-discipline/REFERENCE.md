# Integration Discipline

## Metadata
- **Confidence:** medium
- **Domain:** Process, Multi-Agent Development, Quality Assurance
- **Last validated:** 2026-03-09
- **Source:** Ashfall M1+M2 root cause analysis — 5 blockers, 3 WARN items, AI controller stranded on dead branch

## Pattern

Multi-agent parallel development creates integration gaps that are invisible until someone tries to run the game. Individual systems can be well-built in isolation but completely broken in combination. This skill defines the discipline required to catch integration failures early.

### Why This Skill Exists

During Ashfall M1+M2, the team shipped 2,711 LOC across 31 files with strong individual quality — but the game **couldn't run**. Five blockers were found in code review:

1. **RoundManager not instantiated** — Nobody owned "wire FightScene to RoundManager." The script existed but was never added to the scene or started.
2. **Signals not wired** — EventBus had 13 signals defined, but critical consumer connections (KO → RoundManager) were never made. Defined ≠ connected.
3. **AI stranded on dead branch** — 298 LOC of working AI code merged to a branch that had already been merged to main. Branch management was nobody's job.
4. **State machine won't start** — If `initial_state` isn't set in the scene, fighters freeze on spawn. Nobody tested this because nobody opened Godot.
5. **4 buttons vs 6 (GDD spec drift)** — GDD specified 6-button layout, only 4 were implemented. Nobody validated code against the GDD before merging.

**Root cause:** Integration, spec validation, and smoke testing were assumed but unassigned. No ceremony, no owner, no gate.

---

## Core Patterns

### 1. Integration Gate After Every Parallel Wave

After every wave of parallel agent work (2+ PRs merged), run an integration verification before starting the next wave. This is a **hard gate**, not a suggestion.

**Owner:** Solo (Architect)

**Checklist:**
- Pull latest main — clean working tree
- Open the project in Godot — no import errors, no missing autoloads
- Verify all autoloads initialize in correct dependency order
- Verify EventBus signals are **connected**, not just **defined**
- Check that cross-system wiring works (VFX triggers on hit, audio plays on events, HUD updates on state changes)
- Run through the primary game flow end-to-end
- Document any integration failures as blocking issues

**Anti-pattern:** "Integration-last" — all agents build for 5 waves, then try to integrate everything at once. Integrate after EVERY wave. Small integration passes are 10× cheaper than big-bang integration.

### 2. Somebody Must Open the Project and Verify It Runs

This sounds obvious. It wasn't done for 8 PRs across two milestones. Make it an explicit, assigned task.

**Owner:** Ackbar (QA/Playtester) for milestone smoke tests; Solo for post-wave checks.

**The test:**
1. `git checkout main && git pull`
2. Open Godot 4.x — project loads without errors
3. Press Play — main scene loads
4. Navigate the full game flow: menu → character select → fight → KO → victory
5. If any step crashes, fails, or behaves incorrectly → P0 blocking issue

**Time investment:** 5-10 minutes. Prevents days of debugging.

### 3. Signals Defined ≠ Signals Connected

EventBus (or any signal bus) having a signal defined is only half the work. Someone must **connect** each signal to its consumers. This is the most common integration gap in Godot multi-agent development.

**Verification:**
- For every signal in EventBus, grep the codebase for `.connect(` calls
- Every signal should have at least one emitter (`emit_signal()`/`.emit()`) and at least one consumer (`.connect()`)
- Signals with zero consumers are dead code — either connect them or remove them
- Signals with zero emitters are aspirational — document when they'll be wired

**M1+M2 example:** `EventBus.fighter_ko` was defined and emitted, but RoundManager never connected to it because RoundManager was never instantiated in FightScene.

### 4. Spec Validation Before PR Approval

Before merging any PR that implements a GDD-specified system, compare the implementation against the GDD.

**Owner:** Jango (PR Reviewer)

**Checklist:**
1. Identify the GDD section(s) relevant to this PR
2. Compare: button counts, feature lists, behavior specs, data formats
3. Flag any deviations — intentional deviations must be documented as decisions
4. Block PRs with unintentional spec drift until resolved

**M1+M2 example:** GDD specified LP/MP/HP/LK/MK/HK (6 buttons). Implementation had LP/HP/LK/HK (4 buttons). Nobody compared code against GDD. The deviation compounded across movesets, frame data, and combo routes — turning a 10-minute fix into a 2-3 hour refactor.

### 5. Branch Validation: All PRs Must Target Main

Before an agent starts work, verify:
- The feature branch is created from **latest main** (`git checkout main && git pull && git checkout -b feature/x`)
- The PR targets `main`, not a stale feature branch
- If a dependency branch hasn't merged yet, **wait** — don't branch from it

**Owner:** Mace (Producer) validates before spawning parallel agents.

**M1+M2 example:** Tarkin branched from `squad/1-godot-scaffold` after it had already been merged to main. PR #17 merged to a dead branch. 298 LOC of working AI code never reached main. A 30-second check would have prevented this entirely.

**Rule:** If a branch has been merged to main, delete it immediately. Dead branches are traps.

---

## When to Apply

- After every parallel agent wave (2+ PRs from same wave)
- Before any PR merge that touches gameplay systems
- Before declaring any milestone complete
- When spawning parallel agents (validate branch targets)
- When reviewing PRs (validate GDD compliance)

## Key Takeaway

**Integration is not automatic. It requires an owner, a checklist, and a gate.** The most dangerous assumption in multi-agent development is "someone else will wire it together." Assign integration explicitly. Test it explicitly. Gate on it explicitly.
