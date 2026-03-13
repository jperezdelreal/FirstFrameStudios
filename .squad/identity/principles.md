# Squad Leadership Principles

> Compressed from 19KB. Full version: principles-archive.md

> **Author:** Yoda (Game Designer)
> **Date:** 2025
> **Status:** Active — Every squad member references these when making tradeoffs.
---

## 1. Player Hands First

**The player's feeling in the first 10 seconds matters more than any system behind it.**
Every technical decision, every architecture choice, every animation frame exists to produce a sensation in the player's hands. If the player presses a button and feels power, we succeeded. If they press a button and feel delay, we failed — regardless of how clean the code is.
**In practice:**
---

## 2. Research Before Reinvention

**Study the genre's history of solved problems before solving them again.**
The landmark titles in any genre have already answered most of our design questions. We are not smarter than decades of iteration. We are *faster* — because we've done the homework.
**In practice:**
---

## 3. The IP Is the Soul

**When working with an IP, it isn't a skin stretched over a generic game — it's the DNA of every design decision.**
Character mechanics should flow from personality, not from generic archetypes. Environments should feel like places fans have visited, not tilesets. Every mechanic must pass the test: "Does this feel authentic to the source material?" If the answer is "it could be any IP," redesign it.
**In practice:**
---

## 4. Ship the Playable

**A playable build where you can do the core action teaches more than a design document with fifty pages.**
The bias is always toward *running software*. Get it on the target platform. Get hands on it. Let the build tell you what's wrong.
**In practice:**
---

## 5. Feel It Before You Code It

**Play games in the genre before implementing any mechanic. Your hands know things your brain doesn't.**
Before writing a system, *play* games that do it well. Before designing AI, *fight* enemies that feel satisfying. Before adding feedback effects, *feel* the difference between subtle and dramatic. Your muscle memory holds design insights that no document can capture.
**In practice:**
---

## 6. The Player Can't See Your Architecture

**They can't see your module boundaries, your state machines, or your design patterns. They feel the result.**
A perfectly architected game that stutters during core gameplay is worse than a messy game where everything flows. Architecture serves feel. Modularity serves iteration speed. Clean code serves the team. None of these serve the player directly — only the *output* does. Never confuse the scaffold with the building.
**In practice:**
---

## 7. Domain Owners, Not Domain Silos

**Every specialist owns their domain completely — but no domain exists in isolation.**
The sound designer owns the audio pipeline end-to-end. The gameplay designer owns the mechanics. The art director owns the visual identity. Ownership means: you make the final call, you maintain the quality bar, you spot problems before anyone asks. But ownership doesn't mean isolation — every domain must understand its neighbors.
**In practice:**
---

## 8. Bugs Are a Broken Promise

**Every bug is a promise we made to the player and then broke. Treat them accordingly.**
A game-breaking bug isn't a technical issue — it's a moment where a player tried to play and the game said "no." Bugs aren't items on a backlog. They're broken promises. The severity of a bug is measured by how badly it breaks the player's trust.
**In practice:**
---

## 9. Infrastructure Unlocks Content

**The animation system, the audio pipeline, the entity framework — these aren't features. They're force multipliers.**
When we build a system, we don't ship a feature. We ship the *ability to ship features*. Every new character, every new enemy, every new ability now costs a fraction of what it would have cost before. Infrastructure is an investment with compound returns. The question isn't "does this system ship content today?" — it's "does this system make the next 20 pieces of content faster?"
**In practice:**
---

## 10. Measure the Fun

**Metrics, balance data, and tuning spreadsheets aren't bureaucracy — they're how we turn "feels right" into "is right."**
Intuition starts the design. Measurement validates it. Every core gameplay parameter should have a number, a target, and a reason. "It feels balanced" is a hypothesis. Data confirms or refutes it.
**In practice:**
---

## 11. Constraints Are Creative Fuel

**Every platform, every engine, every budget has hard walls. These aren't limitations — they're the boundaries that make us inventive.**
Nintendo built the Game Boy with 4 shades of green and made Pokémon. Constraints force creative decisions. When an effect is impossible in our tech stack, we don't mourn the limitation — we design around it. The result is often more distinctive than the "obvious" solution would have been.
**In practice:**
---

## 12. Every Project Teaches the Next

**We are not a studio that builds one game. We are a studio that builds a *capability* to build games. Every decision compounds.**
Lessons from evaluating frameworks, from discovering a tech stack's ceiling, from expanding the team, from shipping bugs — none of these are project-specific. They're *studio-specific*. We carry them forward to every future project.
**In practice:**

## 13. Creative Vision Has a Keeper

**Every project has one Vision Keeper — the person who decides not what each system does, but whether all systems feel like the same game.**
Domain owners execute within their domains and own quality within those domains. But without a unifying creative filter, a sound designer's perfect audio, an art director's distinctive style, and a programmer's elegant systems can feel disconnected — like they were made by different teams for different games.
The Vision Keeper is not a bottleneck. They don't touch every asset or make every decision. Instead, they attend key reviews across domains and ask: "Does this feel like *this* game?" Their taste is the unifying force.
---

## 14. Kill Your Darlings With Discipline

**The core loop is sacred. Everything else is a candidate for the cut list.**
Feature creep is the #1 cause of indie game failure. It doesn't matter how elegant a system is or how much work it took — if it doesn't strengthen the core loop, it should be cut ruthlessly. This requires a formal protocol, not just discipline. Without a protocol, features survive based on sunk cost and advocacy, not merit.
**In practice:**
---

## 15. Every Project Requires a Postmortem

**After every project milestone and at the end of every project, run a formal postmortem. Institutionalize the lessons or they will be repeated.**
Postmortems aren't therapy sessions or blame hunts. They are the mechanism by which a studio turns hard-won experience into compounded advantage. Studios that do postmortems ship better games. Studios that skip them repeat the same mistakes.
**In practice:**
---

## How to Use These Principles

1. **When designing a feature:** Check it against Principles 1 (Player Hands First), 3 (IP Is the Soul), and 10 (Measure the Fun).
2. **When making a technical decision:** Check it against Principles 6 (Player Can't See Architecture), 9 (Infrastructure Unlocks Content), and 11 (Constraints Are Creative Fuel).
3. **When two principles conflict:** Player Hands First (#1) wins. Always. If forced to choose between shipping fast (#4) and quality (#8), the tiebreaker is: "Which choice results in a better player experience *this week*?"