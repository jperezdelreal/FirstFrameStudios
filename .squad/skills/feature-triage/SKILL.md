# SKILL: Feature Triage — Kill Your Darlings With Discipline

> **Author:** Yoda (Game Designer / Vision Keeper)  
> **Date:** 2025-07-21  
> **Status:** Active  
> **Confidence:** `low`  
> **Source:** Principle #14 (Kill Your Darlings), studio-craft meta-analysis, firstPunch postmortem  
> **has_reference:** true

---

## Context

Feature triage is the gating mechanism that prevents feature creep from destroying a project. Every feature candidate must prove it strengthens the core 30-second gameplay loop before earning development time. The core loop is sacred — everything else is a candidate for the cut list.

---

## Core Patterns

### The Gate Question

Before triage: **"Does this make the core 30-second loop better?"** If NO → cut immediately. If YES → proceed to the four-test framework.

The core 30-second loop is the smallest repeating gameplay unit (e.g., attack → recover → move → attack again).

### The Four-Test Framework

Every feature that passes the gate question faces four tests. **Fail 2+ tests = CUT. No debate.**

| Test | Question | Pass Example | Fail Example |
|------|----------|-------------|-------------|
| **Core Loop** | Does it strengthen what the player does every 30 seconds? | New enemy type forces new combo usage | Resource management system parallel to combat |
| **Player Impact** | Will a first-time player notice if this is missing? | Health bar, attack animations | Combo counter, cosmetic menu |
| **Cost-to-Joy** | Dev hours vs player delight hours? (target ratio ≥ 1:2) | Attack buffering: 8h dev → scales across entire game | 40h dev → 5h joy = CUT |
| **Coherence** | Does it feel like *this* game or bolted on? | Health-cost special move in a beat 'em up | Inventory tetris in a cartoon brawler |

### Decision Matrix

```
4/4 pass → GREENLIT — Build it
3/4 pass → REVIEW — Vision Keeper decides (1 hour max)
2/4 pass → CUT or SIMPLIFY — Find the 20% that delivers 80%
1/4 pass → CUT — No debate
0/4 pass → CUT — Save for next game
```

Playtests are the final arbiter — even features passing all tests get cut if players don't notice, understand, or enjoy them.

### Cut / Simplify / Defer

- **Cut:** Fails tests → log reason in decisions.md, file spec in "next game" folder, celebrate the saved hours
- **Simplify:** Passes tests but too large → apply MoSCoW (MUST/SHOULD/COULD/WON'T), build only MUST version
- **Defer:** Passes tests but wrong timing → schedule to specific phase with documented dependencies

Never use a "someday" backlog. Features either pass triage and get scheduled, or they're cut and filed.

### Scope Right-Sizing

- **MoSCoW split:** Every feature breaks into MUST (core loop minimum), SHOULD (depth), COULD (polish), WON'T (next game)
- **Timebox:** Don't estimate — allocate a fixed timebox, build MUST first, add SHOULD only if vision is clear by midpoint
- **Vertical slice:** Build one feature to 100% quality before starting the next (quality ratchet)
- **Rule of 3:** If a feature needs 4+ sprints, split it. Each piece passes triage independently

---

## Key Examples

**Example: Triage a "Combo System"**
1. Gate question: Does it strengthen the core combat loop? → YES (deepens attack mastery)
2. Core Loop: PASS — adds decision points to combat rhythm
3. Player Impact: MAYBE — players may not miss it, but mastery players will
4. Cost-to-Joy: 40h dev / 5h joy = ratio 1:0.125 → FAIL
5. Coherence: PASS — fits the beat 'em up identity
6. **Result: 2/4 pass → CUT.** But if implementation drops to 12h (reusable framework found), appeal for retriage at 12h/20h joy ratio.

**Example: MoSCoW for New Enemy Type**
- MUST: Basic attack pattern, one weakness, 3-hit health
- SHOULD: Unique knockback, 2 difficulty variants
- COULD: Custom death animation, voice line
- WON'T: Full AI behavior tree, post-game boss variant, lore codex

---

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **Design by Addition** | Something broken → add new system instead of fixing existing one | Ask: "Can we fix this by improving what exists?" |
| **Feature Parity Hunting** | Pressure to match competitor checklists | Their core loop isn't yours. If it fails your tests, it's irrelevant |
| **Gold Plating** | Secondary features at 95% while core is at 70% | Quality ratchet: core ships first at high quality |
| **Scope Creep by Consensus** | Everyone adds "just one thing" in meetings | Every addition = proposal = must pass fast-track triage |
| **"It's Almost Done"** | Sunk cost drives finishing over cutting | Triage the current state, not the imagined final state |
| **"Build It, We Have Time"** | Sprint headroom → untriaged features | Headroom priority: bugs → polish → tech debt → triaged features only |

---

> *See REFERENCE.md for the complete framework including triage process roles, meeting structure, appeal protocol, decision documentation template, and success metrics.*
