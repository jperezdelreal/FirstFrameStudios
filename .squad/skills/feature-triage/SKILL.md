# SKILL: Feature Triage — Kill Your Darlings With Discipline

> **Author:** Yoda (Game Designer / Vision Keeper)  
> **Date:** 2025-07-21  
> **Status:** Active — First formal triage process for First Frame Studios  
> **Confidence:** `low` (first documentation of the framework; will bump to `medium` after applying to first feature cycle)  
> **Source:** Principle #14 (Kill Your Darlings), studio-craft meta-analysis (Supergiant, Team Cherry, Nintendo, Larian), firstPunch prototype and postmortem data

---

## What This Skill Is

Feature triage is the formal process by which a studio decides **what to build, what to cut, what to simplify, and what to defer**. It is not a suggestion or a nice-to-have. It is the gating mechanism that prevents feature creep from destroying a project.

**Why this matters:** Feature creep is the #1 cause of indie game failure. A team with infinite discipline can ship an imperfect game. A team with unlimited features ships nothing.

**Core principle:** The core loop is sacred. Everything else is a candidate for the cut list.

---

## 1. The Core Question: "Is This Core Loop?"

Before any feature enters the triage process, it must answer ONE question:

### **Does this make the core 30-second loop better?**

**If YES:** Proceed to the four-test framework.  
**If NO:** Cut it immediately. Save it for the next game.

This is not a debate. This is not a filter to be refined. This is the gating question that every feature candidate must pass first.

#### What Counts as "Core 30-Second Loop"?

The core 30-second loop is the smallest repeating unit of core gameplay — what the player does every 30 seconds to perform the central action.

**Examples:**
- *Beat 'em up*: Attack → recover → move → attack again
- *Platformer*: Run → jump → land → run again  
- *Puzzle*: Piece falls → rotate → place → next piece spawns
- *RPG (combat)*: Select action → watch resolution → choose next action
- *Deck builder*: Draw card → decide play → execute → next turn

**If a feature does NOT strengthen any of these loops, it fails the core question immediately.**

#### Common Failures on the Core Question

- "I want to add a side mission system" — Does this strengthen the core combat loop? No. Cut.
- "I want procedural dialogue" — Does this strengthen the core puzzle-solving loop? No. Cut.
- "I want a fishing minigame" — Does this strengthen the core exploration loop? Maybe yes. Proceed to four-test framework. But if the answer is no, cut.

The Vision Keeper (Yoda) has final say on borderline cases.

---

## 2. The Four-Test Framework

Every feature candidate that passes the core question goes through four tests. **Fail 2+ tests = CUT. No debate.**

### Test 1: Core Loop Test

**Question:** Does it strengthen what the player does every 30 seconds?

**What "strengthen" means:**
- It makes the core action more interesting (new decision points, new risk/reward tradeoffs)
- It adds mechanical depth without breaking the rhythm
- It rewards the player for mastering the core loop better
- It does NOT distract from the core loop with parallel systems

**Examples that PASS:**
- "Enemy type B forces the player to use grab + throw, which they'd only use against type A before" — YES, this deepens the combat loop
- "New jump mechanic unlocks previously-unreachable areas" — YES, this expands platforming mastery
- "Boss fight uses core attack patterns the player already knows, but at higher pressure" — YES, this tests core loop mastery under stress

**Examples that FAIL:**
- "I'll add a resource management system parallel to combat" — NO, this splits the player's attention from the core loop
- "Random buff pickups that change what the player can do" — MAYBE, depends on if buffs create interesting decisions or just randomize outcomes
- "Cosmetic customization menu" — NO, unrelated to core loop

### Test 2: Player Impact Test

**Question:** Will a first-time player notice if this is missing?

**Interpretation:**
- If players play the game without this feature, would they feel like something is broken or absent?
- Not: "Would they like this if it existed?" but "Would they miss it if it doesn't?"

**Examples that PASS:**
- "Health bar" — YES, without it the player has no feedback on damage taken
- "Attack animation" — YES, without it the player doesn't know if an action registered
- "Enemy knockback from hits" — YES, without it combat feels unresponsive

**Examples that FAIL:**
- "Combo counter" — MAYBE — does the player *need* this for core gameplay, or is it nice-to-have?
- "Pause menu" — YES, players expect this
- "Difficulty slider" — MAYBE — is this feature gate core content or optional accessibility?

**The test:** If you release without this feature and players don't complain, it fails this test.

### Test 3: Cost-to-Joy Ratio

**Question:** How much development time versus how much player delight?

**This is not intuition. This is estimation.**

For every feature, estimate:
- **Dev time:** Hours to build, test, bug-fix, and integrate. Include QA time.
- **Joy delivered:** Cumulative hours of player engagement or emotional satisfaction from this feature.

**The ratio:**
- **Excellent:** 4 hours dev time → 10+ hours of joy (ratio 1:2.5 or better)
- **Good:** 20 hours dev time → 40+ hours of joy (ratio 1:2 or better)
- **Acceptable:** 40 hours dev time → 100+ hours of joy (ratio 1:2.5 or better)
- **Poor:** 40 hours dev time → 5 hours of joy (ratio 1:0.125) — CUT
- **Terrible:** "It's already half done" with unknown joy potential — CUT

**Why this test is hard:**
Sunk cost fallacy screams loudest here. "But we already spent two weeks on this!" That is exactly why cutting early matters. Finishing something doesn't improve joy; it just burns more time.

**Practical examples:**
- "New enemy type takes 20 hours to code and balance. Playtests show they're interesting in 8-10 encounters. That's ~2 hours of core engagement per playthrough. For a game played 5 times that's ~10 hours total joy from 20 hours of work. Ratio 1:0.5. Consider cutting unless this scales to 40+ hours of joy."
- "Attack buffering takes 8 hours to implement and test. It removes ~30 frustrations per player session (based on playtest data). That scales across the entire game. Ratio exceeds 1:3. PASS."

### Test 4: Coherence Test

**Question:** Does it feel like *this* game, or does it feel bolted on?

**What coherence means:**
- Visual style matches the world
- Mechanical language is consistent (tone, pacing, decision-making patterns)
- It reinforces the game's core identity and themes
- A player could not mistake this feature for belonging to a different game

**Examples that PASS:**
- A health-cost special move in a beat 'em up (reinforces risk/reward theme, familiar mechanical language)
- A limited grab range that rewards positioning (fits the spatial combat identity)
- A stamina system that makes every action a commitment (reinforces the "dangerous world" theme)

**Examples that FAIL:**
- A realistic inventory tetris system in a stylized cartoon beat 'em up (tone mismatch)
- A "loot randomizer" in a game about mastery and consistency (breaks the design theme)
- A moral choice system in a game about pure arcade action (distracts from the core mechanical identity)
- A procedural dungeon generator in a game with hand-crafted encounters (breaks the pacing and difficulty balance story)

**The test:** If you removed the feature and replaced it with something else, would the game feel more coherent or less?

---

## 3. The Cutting Decision Matrix

```
Passes 4/4 tests?       → GREENLIT — Build it
Passes 3/4 tests?       → REVIEW — Vision Keeper decides (1 hour review max)
Passes 2/2 tests?       → GREENLIT — But requires simplification pass (find 20% that delivers 80%)
Passes 1/4 tests?       → CUT — No debate
Passes 0/4 tests?       → CUT — No debate, ship it in the next game
Fails 2+ tests?         → CUT — No debate
```

**What "review" means for 3-test passes:**
- Vision Keeper reads the feature spec (1 page max)
- Vision Keeper asks: "Does cutting this hurt the game?" vs "Does keeping this improve the game?"
- Decision: GREENLIT with conditions, or CUT
- No redebt is allowed — if the Vision Keeper says CUT, it's CUT

**Playtests are the final arbiter:**
Even if a feature passes all four tests on paper, if playtests show:
- Players don't notice it
- Players don't understand it
- Players don't enjoy it
- It breaks other systems

**CUT IT IMMEDIATELY**, even if it's "almost done." "Almost done" doesn't mean it's worth finishing.

---

## 4. Scope Management Patterns

Even features that pass the four tests can be too large. Use these patterns to right-size before greenlit.

### Pattern 1: MoSCoW Method

Break every feature into four categories:

**MUST HAVE (Core Loop):**
- What is the minimum version that strengthens the core loop?
- This is the "greenlit" version. Build this first.

**SHOULD HAVE (Depth):**
- What adds interesting variation without changing core?
- Add this if time permits after MUST.

**COULD HAVE (Polish):**
- What makes it feel more complete but doesn't change gameplay?
- Add this as a bonus if sprint has headroom.

**WON'T HAVE (Future Game):**
- What belongs in a sequel or expansion?
- Save it explicitly. Don't let it contaminate this project.

**Example (New Enemy Type):**
- MUST: Basic attack pattern, one weakness pattern, 3-hit health
- SHOULD: Unique knockback response, 2 variants for difficulty scaling
- COULD: Custom death animation, voice line, special taunt
- WON'T: Full AI behavior tree with learning, post-game boss variant, lore codex

### Pattern 2: Timebox, Don't Estimate

**Bad practice:** "This feature will take 40 hours."  
**Good practice:** "This feature gets one 1-week timebox. We build the MUST version in 5 days, reserve 2 days for bugs and integration. If the vision is clear by day 3, we add SHOULD features. If not, we cut, simplify, and ship."

**Why:** Estimation bias is massive. Timeboxing forces scope clarity. Scope creep happens in the "we're almost done, let's add..." space. Timeboxing eliminates that space.

### Pattern 3: Vertical Slice (One Thing Deep)

**Mistake:** Build a little bit of every feature, spread resources thin, everything ships at 60% quality.  
**Right way:** Build ONE feature completely (100% quality, full testing, full integration), then move to the next.

**For features that pass triage:**
1. Build MUST version completely
2. Test and bug-fix until it's solid
3. Integrate fully into the game
4. Only then move to next feature

This creates a quality ratchet: once a feature ships, the quality bar is set. New features must meet it.

### Pattern 4: The Rule of 3

**If a feature needs more than 3 sprints, it's too big. Split it.**

Why 3?
- Sprint 1: Build core, discover unknowns
- Sprint 2: Fix unknowns, test, iterate
- Sprint 3: Polish, integrate, validate

Anything that spans 4+ sprints either:
- Should have been split into smaller features (each passing triage individually)
- Is not core loop and should be cut
- Has scope creep built in

**How to split:**
- Feature X takes 5 sprints → Split into X.1 (core, 2 sprints) and X.2 (depth, 3 sprints)
- Each piece passes triage independently
- X.2 can be deferred to next phase if time is tight

---

## 5. When to Cut vs When to Simplify vs When to Defer

### Cut
**Decision:** This feature doesn't strengthen the core loop or fails 2+ tests.

**Process:**
1. Vision Keeper or Triage Lead makes the cut decision
2. Feature is logged in decisions.md with reason
3. Feature spec is filed in "next game" reference folder (not backlog)
4. Team celebrates the cut (you just saved 40-100 hours)

**Never revisit a cut decision unless:**
- Playtests explicitly show players miss it
- Design changes (e.g., new mechanic emerges that relies on this feature)

### Simplify
**Decision:** This feature passes tests but scope is too large. Find the 20% that delivers 80%.

**Process:**
1. Triage Lead works with designer to identify MUST version
2. SHOULD/COULD/WON'T split
3. Greenlit MUST version goes to production
4. SHOULD/COULD deferred or backlog

**Example:**
- Original: "Boss fight with 4 phases, each using new mechanics"
- Simplified: "Boss fight with 2 phases, each reinforcing mastered mechanics"
- This cuts dev time 50%, keeps 90% of the intended feel

### Defer
**Decision:** This feature passes tests but timing is wrong (milestone blocker, dependency chain, team capacity).

**Process:**
1. Feature is greenlit
2. Added to "Next Phase" section of backlog (not "Someday")
3. Scheduled for specific phase (Alpha, Beta, etc.)
4. Dependency chain is documented (what must ship first?)

**Important:** "Defer" is different from "maybe later." Deferred features are scheduled, tracked, and have explicit reasons. "Maybe later" features die in the backlog.

### Never: The "Someday" Graveyard
**Anti-pattern:** "That's a cool idea, let's add it to the backlog."

This is where features go to die. Six months later, the backlog has 200 items, 150 are "someday," nobody knows what they are, and they weight down planning.

**Instead:**
- Pass triage → Scheduled and tracked
- Fail triage → Cut, logged with reason, filed in "next game" reference
- No "someday" list

---

## 6. Common Scope Traps (Why Features Explode)

### Trap 1: "It's Almost Done" (Sunk Cost)

**What happens:** Team spent 2 weeks on a feature. It passes tests but scope is unclear. "We're almost done, we should ship it."

**The danger:** "Almost done" doesn't mean "ship quality." It usually means "we hit a checkpoint but there's 3 more weeks of work." Shipping unfinished features creates tech debt and broken player expectations.

**The fix:** Triage the current state, not the imagined final state. If 2 weeks of work produced something that fails coherence or cost-to-joy tests, the answer is still cut or simplify.

### Trap 2: "Players Expect This" (Assumption)

**What happens:** Designer assumes without playtesting. "Players expect a pause menu, so we need this." "Multiplayer is standard, so we need it."

**The danger:** Assumptions are wrong 60% of the time. Building features on assumptions burns scope.

**The fix:** Playtests must validate before triage. If a feature is proposed based on "players expect," the answer is: "Show us playtest data showing players miss it when it's gone."

### Trap 3: "It Would Be Cool If..." (Cool ≠ Core)

**What happens:** Cool idea doesn't strengthen core loop. Gets added anyway because the team loves it.

**The danger:** "Cool" features don't deliver joy when they distract from the core loop. They're distracting.

**The fix:** Cool ideas go through triage like everything else. If they fail core loop test, they're deferred.

### Trap 4: "Competitor X Has This" (Feature Parity)

**What happens:** Another game has feature X, so we need it too.

**The danger:** Their core loop isn't yours. Their game's identity isn't yours. Copying features breaks coherence and dilutes your identity.

**The fix:** Ask the four triage tests. If it fails, the fact that competitors have it is irrelevant. Find your own voice.

### Trap 5: "It's Just a Small Addition" (Compound Scope)

**What happens:** Five "small additions" each taking 4 hours. Total scope: 20 hours of "small stuff" that compounds into full feature.

**The danger:** Small additions aren't tracked, don't go through triage, and accumulate silently.

**The fix:** **Every addition, no matter how small, must pass a fast-track triage**. "Add knockback to enemy attacks" = proposal. Does it pass core loop test? If yes, it's 4 hours of committed scope. If no, it's cut.

---

## 7. The Triage Process at First Frame Studios

### WHO Triages?

**Core Triage Team:**
- **Vision Keeper (Yoda):** Makes final calls on ambiguous cases, ensures coherence
- **Producer (Mace):** Estimates dev time, tracks capacity, makes go/no-go calls on schedule impact
- **Relevant Domain Lead (Solo, Chewie, Lando, Wedge, Greedo, Tarkin, Boba):** Owns the domain where feature lands, can detail technical complexity

**For routine features:** Producer + Domain Lead triage, Vision Keeper informed (but no explicit review needed).

**For high-impact features:** Full Triage Team meets, feature is presented, four tests are applied, decision is made in <1 hour.

### WHEN Triages Happen?

1. **Sprint Planning** — Every 2-week cycle, new features are triaged before greenlit
2. **When a Feature Is Proposed** — Outside sprint planning, feature enters a "proposal queue" and gets triaged within 48 hours
3. **Mid-Sprint Pivots** — If something breaks and requires a workaround, the workaround goes through fast-track triage (30 min)

### HOW: The Triage Process

**Pre-Triage (Designer):**
1. Write 1-page feature spec (name, description, target loop, why it matters)
2. Make 3 reference game examples (games that do something similar)
3. Rough time estimate (4h / 1 sprint / 3 sprints / 5+ sprints)

**Triage Meeting (15-30 min):**
1. Designer presents spec (5 min max)
2. Triage team applies four tests in order (10 min)
3. Decision is made (5 min)
4. Decision is logged (decision.md + backlog + project management tool)

**Post-Triage (Producer/Designer):**
1. If greenlit: Schedule in production calendar
2. If cut: Log reason, file spec in "next game" folder
3. If deferred: Add to phase backlog with dependencies documented

### APPEAL: Disagreement Protocol

**If an agent disagrees with a cut decision:**
1. They have the right to write a 1-paragraph appeal (max 5 sentences)
2. Appeal must present **new evidence** — either playtest data, new cost-to-joy analysis, or design change that addresses failed tests
3. Vision Keeper reads appeal (if compelling, runs a 1-hour fast-track retriage)
4. Vision Keeper has final say
5. Decision is final. No re-appeals.

**Example appeal:** "We cut the combo system because it failed cost-to-joy (40h / 5h joy). But I found an existing combo framework from [reference game] that cuts implementation to 12h. Retest as 12h / 20h joy (ratio 1:1.67). Request retriage."

---

## 8. Anti-Patterns (What Kills Triage Discipline)

### Anti-Pattern 1: "Design by Addition"

**Symptom:** When something is broken, the instinct is to add a new feature/system to fix it, instead of improving the existing one.

**Example:** "Combat feels slow → Add a haste buff system" instead of "Speed up attack recovery by 10%"

**Fix:** Ask: "Can we fix this by improving an existing system?" If yes, do that. If no, then design new features.

### Anti-Pattern 2: "Feature Parity Hunting"

**Symptom:** Team looks at competitors, creates a checklist, and feels pressure to match every feature.

**Fix:** Your identity comes from what you *don't* have, not what you do. Cut ruthlessly. Let competitors have the checklist features. You have the coherence.

### Anti-Pattern 3: "Gold Plating"

**Symptom:** Non-critical features get polished to 95% quality while core features are at 70%.

**Fix:** Quality ratchet: core systems ship first and at high quality. Only after core is solid do you polish secondary features.

### Anti-Pattern 4: "Scope Creep by Consensus"

**Symptom:** In meetings, everyone adds "just one thing" and nobody objects. Scope doubles invisibly.

**Fix:** Every proposal, even in planning meetings, gets a quick-pass triage. "Just add knockback" = proposal = must pass core loop test. If yes, it's logged as committed scope. If no, it's rejected in the room.

### Anti-Pattern 5: "Build It Because We Have Time"

**Symptom:** Sprint has headroom, so team builds a feature without triage or planning.

**Fix:** Sprint headroom goes to:
1. Bugs (always priority)
2. Polish on shipped features (quality ratchet)
3. Technical debt (if blocking velocity)
4. Only then: additional features (which still need fast-track triage)

---

## 9. Decision Documentation Template

Every triage decision is logged in `.squad/decisions.md` with this format:

```markdown
### [Feature Name] (Triage Decision)
**Author:** [Proposer]  
**Date:** YYYY-MM-DD  
**Status:** Greenlit / Cut / Deferred / Simplified  

**Four Tests:**
1. Core Loop Test: [PASS/FAIL + reasoning]
2. Player Impact Test: [PASS/FAIL + reasoning]
3. Cost-to-Joy Ratio: [X hours / Y hours of joy] — [PASS/FAIL]
4. Coherence Test: [PASS/FAIL + reasoning]

**Decision:** [GREENLIT / CUT / DEFERRED / SIMPLIFIED]

**If simplified:**
- MUST version: [description]
- SHOULD version: [description, deferred to phase X]
- COULD version: [description, backlog]

**If deferred:**
- Reason: [why timing is wrong]
- Phase: [Alpha / Beta / Post-Launch]
- Dependencies: [what must ship first]

**If cut:**
- Reason: [which tests failed, why]
- Next game: [filed in reference folder]

**Appeal:** [If any agent appealed, note outcome here]
```

---

## 10. Integration with firstPunch Backlog

**Current state:** firstPunch backlog has 52+ items. Many should never have made the backlog.

**Action:**
1. Retroactive triage on existing backlog (Solo + Yoda, 4 hours)
2. Apply four tests to every item
3. Reclassify: "Core" (must ship) / "Next Game" (cut) / "Deferred" (post-launch)
4. Result: 52 items → ~25 core items + ~15 next-game reference + ~12 deferred

**This is not blame.** It's clarity. The backlog grew without a gating mechanism. Now it has one.

---

## Quick Reference: Triage Checklist

**Before proposing a feature, ask yourself:**

- [ ] Does this strengthen the core 30-second loop? (If NO, stop here — cut it)
- [ ] Would players notice if we shipped without it? (Core Loop Test)
- [ ] How many hours to build? How many hours of player joy? (Cost-to-Joy Test)
- [ ] Does it feel like our game or bolted-on? (Coherence Test)
- [ ] Can I describe the MUST version in 2 sentences?

**If you answer "I don't know" to any of these, the feature is not ready for triage. Do more design work.**

---

## How to Use This Skill

1. **Before Sprint Planning:** Review this document with the Producer and Domain Leads
2. **When a Feature Is Proposed:** Designer reads section 1-2 and self-assesses before proposing
3. **During Triage Meeting:** Use section 7 as the meeting framework
4. **After a Cut Decision:** Use section 4-5 to find the simplified version (if one exists)
5. **When Disagreement Arises:** Use section 8's appeal protocol
6. **End of Project:** Audit how many features passed triage vs how many were cut. The ratio tells you if your triage was rigorous enough.

---

## Success Metrics

**You know this skill is working when:**

✓ Average feature time-to-greenlit drops from 1 week to 2-3 days (clearer criteria, faster decisions)  
✓ Backlog shrinks by 30% in first triage cycle (lots of features were candidates for cutting anyway)  
✓ Zero "it's almost done" decisions (triage happens before the work, not after)  
✓ Playtests show higher feature coherence (fewer "bolted on" systems)  
✓ Post-project retrospective shows "we shipped focused, cut ruthlessly, and quality improved"  

**You know it's not working when:**

✗ Features still ship without going through triage  
✗ "Someday" backlog still grows invisibly  
✗ Scope creep by consensus still happens in planning meetings  
✗ Appeals happen every sprint (triage criteria need refinement)  

---

## Confidence Levels & When to Bump This

**Current:** `low` — First formal documentation, not yet tested across a full feature cycle.

**Bump to `medium`:** After first project applies this process to 3+ features and ships a feature that demonstrably benefited from triage discipline.

**Bump to `high`:** After second project uses this across all 10+ backlog items and the backlog/quality metrics improve.

---

**Author's Note (Yoda):**

Every studio has features they regret shipping. Every developer has spent weeks polishing something they wish they'd cut. This skill exists so First Frame Studios is not that studio. We are disciplined. We cut ruthlessly. We keep only what serves the game. And because we do, every game we ship is focused, coherent, and beloved.

The hardest cut is the one you make early.
