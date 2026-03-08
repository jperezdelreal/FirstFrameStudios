# SKILL: Multi-Agent Coordination

How to work on shared codebases with multiple AI agents. Every pattern here was learned from 72+ agent spawns on firstPunch — including 214 LOC of unwired infrastructure, duplicate function definitions, and state machine overwrites caused by parallel edits.

---
name: "multi-agent-coordination"
description: "Coordination patterns for multi-agent development — file ownership, integration contracts, conflict prevention"
domain: "process"
confidence: "low"
source: "earned — extracted from firstPunch multi-agent session (72+ spawns, 12 agents, 101 backlog items)"
---

## When to Use This Skill
- Multiple agents are editing the same codebase simultaneously
- Planning work distribution across agents (wave planning)
- Reviewing or integrating changes from multiple agents
- Debugging issues caused by parallel edits
- Onboarding new agents to an existing multi-agent project

## When NOT to Use This Skill
- Single agent working alone on isolated files
- Read-only analysis tasks (no code changes)
- Sequential agent work with no parallelism

---

## Core Patterns

### 1. File Ownership Boundaries

**Rule: One agent per file per wave.** Two agents editing the same file in the same wave will produce conflicts, overwrites, or duplicated code.

```
Wave 1:
  Agent A → player.js, combat.js        ✅ Distinct files
  Agent B → enemy.js, ai.js             ✅ Distinct files
  Agent C → player.js                   ❌ CONFLICT with Agent A

Wave 2:
  Agent A → enemy.js (integration)      ✅ Agent B is done with it
  Agent B → hud.js                      ✅ New file
```

**The god-file problem:** Large files like `gameplay.js` (695 LOC, touched by every feature) become bottlenecks. Solution: decompose into thin wiring files that import modules. Each module can be owned by a different agent.

```
// ❌ BOTTLENECK — everyone needs gameplay.js
gameplay.js (695 LOC) — camera, waves, background, combat, all inline

// ✅ DECOMPOSED — each module independently ownable
gameplay.js (100 LOC) — imports and wires systems
camera.js — Agent A owns
wave-manager.js — Agent B owns
background.js — Agent C owns
```

### 2. Integration Contract Pattern

**The #1 waste pattern:** Agents build infrastructure (EventBus, AnimationController, SpriteCache, CONFIG — 214 LOC total) but don't wire it into any consumer. The system works in isolation but has zero effect on the game.

**Rule: Every infrastructure PR must wire into at least one consumer.**

```javascript
// Agent builds the system AND writes integration instructions:

// === INTEGRATION CONTRACT ===
// To wire VFX impacts into combat:
//   1. Import: import { VFX } from '../systems/vfx.js';
//   2. In Combat.handleHit(): VFX.spawnImpactSpark(target.x, target.y);
//   3. In gameplay.update(): vfx.update(dt);
//   4. In gameplay.render(): vfx.render(ctx);
// ============================
```

**Comment-based integration contracts** (seen in firstPunch's vfx.js, destructible.js, hazard.js) are effective lightweight API docs. They tell the integrator exactly what to do without requiring coordination meetings.

**Ideal flow:**
1. Builder agent creates the system + writes integration comments
2. Builder wires it into one consumer (proves it works)
3. Integration agent (or builder in the next wave) wires remaining consumers

### 3. Drop-Box Pattern for Shared Decisions

Agents need to communicate decisions without real-time coordination. Use a decisions inbox directory.

```
.squad/decisions/inbox/
  solo-backlog-expansion.md     — Solo's backlog decisions
  ackbar-qa-findings.md         — Ackbar's bug reports
  yoda-design-mandates.md       — Yoda's design decisions
  tarkin-enemy-balance.md       — Tarkin's balance changes
```

**Format:**
```markdown
# Decision: {Title}
**Author:** {Agent name}
**Date:** {ISO date}
**Status:** proposed | accepted | rejected

## Context
{Why this decision is needed}

## Decision
{What was decided}

## Impact
{Which agents/files are affected}
```

**Rule:** Decisions inbox is append-only during a wave. The Lead reviews between waves and accepts/rejects. No agent modifies another agent's decision file.

### 4. Integration Passes After Parallel Work

After every parallel wave, run an integration pass before starting the next wave.

```
Wave N: 4 agents work in parallel on separate files
         ↓
Integration Pass: 1 agent (ideally the engine owner) verifies:
  □ All new systems are imported and called
  □ No duplicate function definitions across files
  □ State machines haven't been overwritten
  □ Data formats are consistent (no WAVE_DATA vs LEVEL_1 drift)
  □ Game still runs without errors
  □ Game still plays correctly (quick smoke test)
         ↓
Wave N+1: Next set of parallel tasks
```

**firstPunch lesson:** Chewie (Engine Dev) did 3 major integration passes. Without them, 8+ features would have shipped broken because builders didn't wire their systems.

---

## Common Conflict Patterns

### Duplicate Function Definitions
Two agents independently add a helper with the same name:
```javascript
// Agent A adds to utils.js:
function clamp(val, min, max) { return Math.max(min, Math.min(max, val)); }

// Agent B adds to math-helpers.js:
function clamp(value, lo, hi) { return Math.max(lo, Math.min(hi, value)); }
```
**Prevention:** Maintain a shared utilities manifest. Before adding a helper, check if it exists.

### State Machine Overwrites
Agent A adds `'dodge'` state to player. Agent B adds `'grab'` state. Both modify the `update()` switch statement — last write wins.
```javascript
// Agent A's version:
case 'dodge': this.updateDodge(dt); break;

// Agent B's version (overwrites A — 'dodge' case is gone):
case 'grab': this.updateGrab(dt); break;
```
**Prevention:** Each agent adds their state handler in a separate method file. The main `update()` switch is the integration point — only one agent touches it per wave.

### Data Format Drift
Two agents create enemy/level data in different formats:
```javascript
// Agent A (wave-manager.js):
const WAVE_DATA = [{ x: 400, type: 'grunt', count: 3 }];

// Agent B (levels.js):
const LEVEL_1 = { waves: [{ position: 400, enemyType: 'grunt', quantity: 3 }] };
```
**Prevention:** Data schemas are defined once in a shared config, documented in a skill or convention file. Second agent reads existing format before creating new data.

---

## Code Review Checklist for Multi-Agent Changes

Before merging any wave of parallel agent work:

```
Structural:
  □ No duplicate function/class definitions across files
  □ No circular imports introduced
  □ Shared files (gameplay.js, config.js) edited by at most 1 agent
  □ All new exports are imported somewhere (no dead code)

Integration:
  □ Every new system has ≥1 consumer wired up
  □ Integration contracts (comments) are present for unwired systems
  □ Event bus subscriptions match published event names
  □ Data formats consistent (no schema drift between files)

State:
  □ State machines haven't been partially overwritten
  □ New states added to transition tables
  □ Guard conditions updated to include new states
  □ No two agents set the same state variable from different code paths

Runtime:
  □ Game loads without console errors
  □ Game plays through one full wave without crashes
  □ New features are visually/audibly present (not just code-present)
  □ No regressions in existing features (quick smoke test)
```

---

## When to Serialize vs. Parallelize

| Serialize (one agent at a time) | Parallelize (multiple agents) |
|-------------------------------|-------------------------------|
| Editing the same file | Editing completely separate files |
| Feature depends on another feature's output | Features are independent |
| State machine changes (transition tables) | Visual/audio polish (no shared state) |
| Integration/wiring passes | New standalone systems |
| Bug fixes in shared code | New enemy types, new UI screens |
| Architecture refactors | Content creation (levels, art, sound) |

**Default assumption:** If unsure, serialize. The cost of a conflict (debugging, re-work, subtle state corruption) far exceeds the cost of waiting one wave.

---

## Anti-Patterns

1. **Build without wiring** — Creating infrastructure (EventBus, CONFIG, SpriteCache) without integrating it into any consumer. The system exists but has zero effect. 214 LOC of this in firstPunch.

2. **Two agents, one file** — Parallel edits to the same file produce overwrites, lost code, or merge conflicts. One agent per file per wave, always.

3. **Known gap without escalation** — Agent documents "gameplay.js audio routing doesn't handle X" but doesn't push for resolution. Document AND escalate to the Lead or the file owner. Logged gaps that sit forever are worse than undocumented ones (they create false confidence).

4. **Integration-last** — All agents build in parallel for 5 waves, then try to integrate everything at once. Integrate after EVERY wave. Small integration passes are 10× cheaper than big-bang integration.

5. **Assuming another agent wired it** — "I built the audio method, Chewie will wire it." Unless explicitly assigned, assume no one will wire your code. Wire one consumer yourself.

6. **Editing the god file** — A 695-LOC file that everyone needs to touch is a coordination bottleneck. Decompose it before parallelizing work.

7. **No smoke test between waves** — Agents produce code that passes in isolation but breaks when combined. Always run the game after each integration pass.

---

## Checklist

Before starting a parallel wave:

- [ ] File ownership assigned (one agent per file)
- [ ] God files decomposed (no file >200 LOC touched by >1 agent)
- [ ] Shared data formats documented (one schema, one source of truth)
- [ ] Decision inbox created for cross-agent communication
- [ ] Integration agent assigned for post-wave pass

Before merging wave output:

- [ ] No duplicate definitions across files
- [ ] Every new system wired to ≥1 consumer
- [ ] Integration contracts present for unwired systems
- [ ] State machines verified (no overwrites, no missing states)
- [ ] Game runs and plays correctly (smoke test)
- [ ] No data format drift between agents
