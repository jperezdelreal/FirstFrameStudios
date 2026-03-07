# Squad Leadership Principles

> **Author:** Yoda (Game Designer)
> **Date:** 2025
> **Status:** Active — Every squad member references these when making tradeoffs.

These are not aspirations. They are commandments. When two priorities conflict, these principles decide. When a feature is ambiguous, these principles clarify. When a deadline looms, these principles tell you what to cut and what to protect.

---

## 1. Player Hands First

**The player's feeling in the first 10 seconds matters more than any system behind it.**

Every technical decision, every architecture choice, every animation frame exists to produce a sensation in the player's hands. If the player presses a button and feels power, we succeeded. If they press a button and feel delay, we failed — regardless of how clean the code is.

**In practice:**
- When choosing between a technically correct timestep and one that *feels* responsive, prioritize feel. Measure input latency, not just frame rate.
- Playtest every gameplay change by *playing*, not by reading diffs. A small timing change looks trivial in code and transforms the game in hands.
- Game feel systems (screen shake, hitlag, feedback effects) are not polish — they are the core product. Budget time for them like you'd budget time for collision detection.

**Anti-pattern:** "The architecture is clean and the frame timing is perfect, but nobody on the team has actually played the last build." If you're reviewing code instead of playing the game, you've lost the thread.

---

## 2. Research Before Reinvention

**Study the genre's history of solved problems before solving them again.**

The landmark titles in any genre have already answered most of our design questions. We are not smarter than decades of iteration. We are *faster* — because we've done the homework.

**In practice:**
- Before designing any system, find three reference games that implemented it. Document what worked and what didn't. *Then* design.
- When debating a mechanic, cite specific games. A reference to a proven design is an argument. "I think this would be cool" is a guess.
- Maintain a genre research document as a living reference for each project. When we play a new game in the genre, add findings.

**Anti-pattern:** "I have an original idea for how this system should work" — without having played the games that already explored this design space. Originality is earned through mastery, not ignorance.

*In SimpsonsKong, this meant studying nine landmark beat 'em ups before writing a line of combat code. SoR4's health-cost specials, Turtles in Time's throw spectacle, Shredder's Revenge's taunt mechanic — 35 years of solved problems saved us months of design mistakes.*

---

## 3. The IP Is the Soul

**When working with an IP, it isn't a skin stretched over a generic game — it's the DNA of every design decision.**

Character mechanics should flow from personality, not from generic archetypes. Environments should feel like places fans have visited, not tilesets. Every mechanic must pass the test: "Does this feel authentic to the source material?" If the answer is "it could be any IP," redesign it.

**In practice:**
- Character moves are designed from personality first, numbers second. Ask "What would this character do?" before "What are their damage values?"
- Environmental interactions reference the source material. Props and set pieces should feel specific, not generic.
- Failure states, idle animations, and small moments are where IP authenticity shines brightest. Invest in them.

**Anti-pattern:** "I added a generic dash attack to the character." Why a dash? Does this character *dash*? The verb matters. The character dictates the mechanic, not the other way around.

*In SimpsonsKong, this meant Homer's belly bounce instead of a generic dash — Homer being Homer. Bart's taunt as a bratty provocation, not a generic meter button. Springfield as a place fans recognized in every pixel.*

---

## 4. Ship the Playable

**A playable build where you can do the core action teaches more than a design document with fifty pages.**

The bias is always toward *running software*. Get it on the target platform. Get hands on it. Let the build tell you what's wrong.

**In practice:**
- Every feature starts with the smallest playable version. Polish comes from iteration, not from planning polish upfront.
- Deploy to a testable build after every meaningful change. If it can't be played, it doesn't count as progress.
- When debating two approaches, prototype both quickly rather than debating at length. The build will tell you who's right.

**Anti-pattern:** "I spent three days designing this system on paper and I'm ready to implement." Three days of design without a single playtest is three days of untested assumptions. Build day one. Design around what you learn on day two.

*In SimpsonsKong, we went from zero to a playable build in 30 minutes. That rough, imperfect prototype revealed more about combat feel than any amount of planning.*

---

## 5. Feel It Before You Code It

**Play games in the genre before implementing any mechanic. Your hands know things your brain doesn't.**

Before writing a system, *play* games that do it well. Before designing AI, *fight* enemies that feel satisfying. Before adding feedback effects, *feel* the difference between subtle and dramatic. Your muscle memory holds design insights that no document can capture.

**In practice:**
- Every sprint involving a new mechanic begins with a play session of reference games. This is not a break — this is work.
- When a mechanic feels wrong but you can't articulate why, play a reference game that does it right. The contrast will make the problem obvious.
- Record clips of reference games during play sessions. "Make it feel like THIS" is clearer than any design spec.

**Anti-pattern:** "I implemented this mechanic based on the GDD spec." Did you *play* games that do this well first? Specs describe mechanics. Playing reveals feel.

---

## 6. The Player Can't See Your Architecture

**They can't see your module boundaries, your state machines, or your design patterns. They feel the result.**

A perfectly architected game that stutters during core gameplay is worse than a messy game where everything flows. Architecture serves feel. Modularity serves iteration speed. Clean code serves the team. None of these serve the player directly — only the *output* does. Never confuse the scaffold with the building.

**In practice:**
- When an architectural refactor competes with a gameplay improvement for sprint time, the gameplay improvement wins unless the refactor unblocks three or more future features.
- Measure success by player-facing metrics: input latency, gameplay flow, visual clarity, emotional impact. Not by code coverage or module count.
- The camera system, the core loop timing, and the animation pipeline are architecture that the player *does* feel. Invest there. The file directory structure is architecture the player *never* feels. Don't gold-plate it.

**Anti-pattern:** "I refactored the entity system into a proper ECS with 12 components." Does the game feel better? "No, but the code is much cleaner." Then you spent sprint time on developer comfort, not player delight.

---

## 7. Domain Owners, Not Domain Silos

**Every specialist owns their domain completely — but no domain exists in isolation.**

The sound designer owns the audio pipeline end-to-end. The gameplay designer owns the mechanics. The art director owns the visual identity. Ownership means: you make the final call, you maintain the quality bar, you spot problems before anyone asks. But ownership doesn't mean isolation — every domain must understand its neighbors.

**In practice:**
- When a domain needs a decision, the domain owner decides. No committee. No consensus-seeking on details that have a clear owner.
- Domain owners attend each other's reviews. The sound designer reviews gameplay changes (does the new mechanic need new SFX timing?). The gameplay designer reviews AI changes (does the new behavior break the core loop?).
- When a domain is too broad for one owner, split it. Overloaded owners produce mediocre work in multiple areas instead of excellent work in one.

**Anti-pattern:** "That's not my module." If a player-facing bug exists, it's every specialist's concern. Domain ownership means you own quality in your area — it doesn't mean you ignore quality elsewhere.

*In SimpsonsKong, we learned this when art direction needed its own dedicated owner, separate from sprite implementation and VFX.*

---

## 8. Bugs Are a Broken Promise

**Every bug is a promise we made to the player and then broke. Treat them accordingly.**

A game-breaking bug isn't a technical issue — it's a moment where a player tried to play and the game said "no." Bugs aren't items on a backlog. They're broken promises. The severity of a bug is measured by how badly it breaks the player's trust.

**In practice:**
- Player-blocking bugs (freeze, crash, softlock) are P0. Full stop. Drop everything. No feature work until the player can play.
- "It works on my machine" is not a resolution. It works when *every* player path through the game works. Edge cases are player experiences too.
- After every bug fix, ask: "What process failed that let this ship?" Fix the process, not just the code.

**Anti-pattern:** "We'll fix it in the next sprint." The player experiencing the bug doesn't have a sprint schedule. If the game breaks, the player walks away and never comes back. That's not a backlog item — that's a lost player.

*In SimpsonsKong, a player freeze bug and passive AI bug shipped because no single owner caught them. That taught us: bugs are everyone's problem, and "next sprint" is too late.*

---

## 9. Infrastructure Unlocks Content

**The animation system, the audio pipeline, the entity framework — these aren't features. They're force multipliers.**

When we build a system, we don't ship a feature. We ship the *ability to ship features*. Every new character, every new enemy, every new ability now costs a fraction of what it would have cost before. Infrastructure is an investment with compound returns. The question isn't "does this system ship content today?" — it's "does this system make the next 20 pieces of content faster?"

**In practice:**
- Before building a one-off, ask: "Will I build something like this again?" If yes, build the system. If no, build the shortcut.
- Infrastructure work must specify its "unlock list" — what content becomes possible or faster after this ships.
- Audit infrastructure quarterly: is the team actually using it? Infrastructure nobody uses is waste, not investment.

**Anti-pattern:** "I built a beautiful system that supports 200 variations." How many do we use? "Three." Then you built infrastructure for a game you're not making. Build for the game you *are* making, and expand when the game demands it.

---

## 10. Measure the Fun

**Metrics, balance data, and tuning spreadsheets aren't bureaucracy — they're how we turn "feels right" into "is right."**

Intuition starts the design. Measurement validates it. Every core gameplay parameter should have a number, a target, and a reason. "It feels balanced" is a hypothesis. Data confirms or refutes it.

**In practice:**
- Every key value, timing window, and cooldown has a target range in the GDD. Deviations require justification.
- Playtest sessions produce data, not just vibes. "It felt slow" becomes a measured metric with a target range.
- Balance changes are A/B tested where possible. Change a value, play both versions, measure the outcome that matters, choose the one that produces better player behavior.

**Anti-pattern:** "It feels balanced to me." Balanced for whom? The developer who's played 200 hours or the new player on their first run? Measurement reveals what feel obscures. Your calibration is not the player's calibration.

*In SimpsonsKong, when balance analysis showed jump attacks dealing 50 DPS above the 45 target, we didn't say "it feels fine." We measured, identified the problem, and tuned to 38 DPS. That discipline made combat fair for new players, not just veterans.*

---

## 11. Constraints Are Creative Fuel

**Every platform, every engine, every budget has hard walls. These aren't limitations — they're the boundaries that make us inventive.**

Nintendo built the Game Boy with 4 shades of green and made Pokémon. Constraints force creative decisions. When an effect is impossible in our tech stack, we don't mourn the limitation — we design around it. The result is often more distinctive than the "obvious" solution would have been.

**In practice:**
- When a desired feature is impossible within the current constraints, design around it. Find what *is* expressive within the boundaries.
- "Can we do this on our target platform?" is the first question for every feature. If the answer is "barely," simplify the design until the answer is "confidently."
- When a constraint bites unexpectedly, fix the interaction, don't abandon the platform. Constraints are partners, not enemies.

**Anti-pattern:** "We should switch to a different engine/platform for better capabilities." Better capabilities for *what*? Define the player experience gap first. If the gap can be closed within the current tech (and it often can), stay. Platform migrations destroy velocity and compound expertise.

*In SimpsonsKong, Canvas 2D with no shaders and no skeletal animation forced us toward snappy sprite work and procedural audio — a visual and audio identity we wouldn't have found if we'd had unlimited tools.*

---

## 12. Every Project Teaches the Next

**We are not a studio that builds one game. We are a studio that builds a *capability* to build games. Every decision compounds.**

Lessons from evaluating frameworks, from discovering a tech stack's ceiling, from expanding the team, from shipping bugs — none of these are project-specific. They're *studio-specific*. We carry them forward to every future project.

**In practice:**
- After every major milestone, run a retrospective. Document what worked, what failed, and what we'd do differently. Store it in squad history, not just memory.
- When making a technology or process decision, check if a past project already answered this question. Read the decision log before reopening closed questions.
- Build tools and systems that transfer. The animation system, the audio pipeline, the balance framework — these aren't one-game features, they're studio assets.

**Anti-pattern:** "Let's re-evaluate that technology/approach for the next project." We already evaluated it. We documented why we chose what we chose. Learning means not repeating the investigation.

*SimpsonsKong taught us: Phaser's overhead exceeded its benefit for our scope. Procedural art has a ceiling at ~400 LOC/character. Domain splitting unlocks parallelism. Testing is a team responsibility. These lessons travel with us.*

---

## How to Use These Principles

1. **When designing a feature:** Check it against Principles 1 (Player Hands First), 3 (IP Is the Soul), and 10 (Measure the Fun).
2. **When making a technical decision:** Check it against Principles 6 (Player Can't See Architecture), 9 (Infrastructure Unlocks Content), and 11 (Constraints Are Creative Fuel).
3. **When two principles conflict:** Player Hands First (#1) wins. Always. If forced to choose between shipping fast (#4) and quality (#8), the tiebreaker is: "Which choice results in a better player experience *this week*?"
4. **When onboarding a new squad member:** They read this document before writing a single line of code.
5. **When running a retrospective:** Score each principle 1-5 for the sprint. Which did we honor? Which did we violate? The pattern reveals our blindspots.
