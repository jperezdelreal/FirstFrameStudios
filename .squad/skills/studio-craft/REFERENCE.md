# Studio Craft: The Meta-Skills of Game Studio Operation

> **Author:** Yoda (Game Designer) + Solo (Lead / Chief Architect)  
> **Date:** 2025-07  
> **Status:** Active — Living reference for how we run ourselves, not just make games.  
> **Confidence:** `low` (first observation from research, not yet validated across multiple projects)  
> **Source:** Industry research across Supergiant, Team Cherry, Sandfall, Larian, ConcernedApe, Nintendo, academic meta-analyses, and firstPunch lived experience.

---

## What This Skill Is

This is not about *making* games. This is about *running* a game studio. It captures the meta-knowledge: how we organize, decide, iterate, learn, and compound knowledge across projects. It's the operating system that makes a studio ship consistently instead of shipping once and disappearing.

**Every studio member should read this.** You need to understand not just what your domain does, but how the studio as a whole functions.

---

## 1. Creative Vision Management

### The Vision Keeper Role

**Pattern:** Every exceptional studio has ONE person (or a tiny nucleus of 2–3) who holds the creative vision. This person is not a bottleneck; they are a filter.

**What the Vision Keeper does:**
- Attends key reviews across all domains (art, audio, gameplay, UI, animation)
- Asks: "Does this feel like *this* game?" when decisions are ambiguous
- Breaks ties when domain owners disagree on aesthetic or design coherence
- Does NOT touch every asset or make every decision — they maintain coherence, not control

**Why it matters:**
A sound designer's perfect audio, an art director's distinctive style, and a programmer's elegant systems can feel disconnected without a unifying creative filter. They were made by different teams for different games. Vision needs a keeper.

**Implementation at FFS:**
- Per project, designate a Creative Director (Yoda as default for our first projects)
- The Creative Director attends code review, art review, audio review, and UI review
- Decision rights matrix explicitly states the Creative Director breaks design/aesthetic ties
- Creative Director role is a *filter*, not a bottleneck — they don't slow decisions, they unify them

---

## 2. Feature Triage Protocol — "Kill Your Darlings"

### The Core Loop Is Sacred. Everything Else Is Expendable.

**Pattern:** Feature creep is the #1 cause of indie game failure (per 155-postmortem meta-analysis). It doesn't matter how elegant a system is or how much work it took — if it doesn't strengthen the core loop, it should be cut ruthlessly.

**The Four-Test Framework:**

Every feature candidate passes four tests before greenlit. If it fails two or more, it's cut immediately.

1. **Core loop test** — Does it strengthen the core loop or distract from it?
   - Example (Beat 'em up): Does this enemy type create interesting combat decisions, or does it just change the numbers?
   - Example (Puzzle): Does this mechanic teach a new pattern the player will need later, or is it a one-off?

2. **Player impact test** — Would a first-time player miss it if we cut it?
   - If the answer is "no, they wouldn't notice," it's probably not core.
   - If the answer is "yes, it's essential," it passes.

3. **Cost-to-joy ratio** — Development hours vs. player delight. Is it worth it?
   - A feature that takes 40 hours and produces 2 hours of player delight fails this test.
   - A feature that takes 4 hours and produces 10 hours of cumulative joy passes.

4. **Coherence test** — Does it feel like *this* game, or does it feel bolted on?
   - Example: A realistic inventory system in a stylized cartoon beat 'em up fails coherence, even if it's well-executed.
   - Example: A health-cost special move in a beat 'em up passes coherence because it reinforces the risk/reward theme.

**The Cutting Decision:**

- Features that pass all four tests: greenlit
- Features that pass three: require Creative Director review before greenlit
- Features that pass two or fewer: cut immediately, save for a future game
- Playtests are the final arbiter. If players don't notice it, don't understand it, or don't enjoy it, cut it — even if it passes the four tests on paper

**Why it's hard:**
Sunk cost fallacy is the killer. "But we already spent two weeks on this feature." Sunk cost is not justification. Killing a half-built feature early saves 100 hours of polish and integration work.

**Integration at FFS:**
- Every backlog item includes the four-test assessment before it enters production
- During playtests, if a feature doesn't pass the "player impact" test in real gameplay, it gets cut
- Cutting a feature is celebrated, not mourned — it's the team making the game better

---

## 3. Playtest-Driven Iteration Methodology

### Iteration Count Correlates With Quality

**Pattern:** From Supergiant, Larian, and the meta-analysis: iteration count correlates with game quality. Fewer iterations = lower quality. First instincts correlate with overconfidence.

**The Iteration Cycle:**

Every core mechanic ships after **3+ iteration cycles minimum**. Each cycle:

```
Build → Playtest → Measure → Revise
```

1. **Build** — Implement the mechanic in a playable build (even rough/incomplete)
2. **Playtest** — Get hands on it. Record player behavior, listen to player commentary
3. **Measure** — Capture data (timing, balance metrics, player feedback)
4. **Revise** — Make changes informed by the data, not instinct

**Why three iterations minimum:**
- Iteration 1 reveals the mechanic's existence and basic problems
- Iteration 2 reveals the mechanic's interaction with other systems
- Iteration 3 reveals the mechanic's balance and feel edge cases
- Before Iteration 3, you don't understand the mechanic well enough to ship it

**The Overconfidence Trap:**
"This feels right on the first try" usually means you haven't tested it hard enough. The best iteration cyles are the ones where the second playtest reveals something that contradicts the first.

**Integration at FFS:**
- Every mechanic has an "iteration target" — a number of cycles before it ships (3+ for core mechanics, 1–2 for supporting systems)
- Playtests are scheduled at the end of each iteration cycle, not just occasionally
- Playtest data is documented and compared across cycles to track convergence toward "done"

---

## 4. Postmortem Discipline — Institutionalizing Lessons

### Every Project Requires a Formal Postmortem

**Pattern:** Studios that do postmortems ship better games. Studios that skip them repeat the same mistakes.

**The Postmortem Process:**

After every major milestone (Vertical Slice, Beta, Gold) and at the end of every project:

1. **Individual reflection** — Every squad member contributes 5 things that went right and 5 things that went wrong
   - Anonymous submission prevents seniority bias and political posturing
   - Honest answers are more valuable than polished ones

2. **Synthesis** — Facilitate a discussion to synthesize individual items into studio-level lessons
   - Look for patterns. "Communication was poor" is not a lesson. "We need daily async standups" is.
   - Assign owners to lessons so they don't languish as vague observations

3. **Documentation** — Publish findings in a searchable document
   - Lessons are tagged with the principle they validate or violate
   - Actionable items go into the next project's Sprint 0 checklist
   - Non-actionable insights go into squad history for context

4. **Follow-up** — Verify that owner's lessons from the last postmortem were addressed
   - If a lesson was identified but not actioned, ask why and adjust
   - This closes the feedback loop and prevents repeated inaction

**Why it's hard:**
Postmortems require vulnerability. Admitting mistakes feels risky. But studios without postmortems repeat their mistakes invisibly. Studios with postmortems learn at the studio level, not just the individual level.

**Integration at FFS:**
- Postmortem is a mandatory ceremony after every major milestone
- Findings are stored in `.squad/agents/{agent-name}/history.md` and `.squad/decisions.md`
- Each agent is accountable for lessons they own; status is tracked in retrospectives
- Never say "we'll just remember for next time" — if it's important, it's written down

---

## 5. Developer Joy as a Metric

### If the Team Stops Being Excited, That's a Design Signal

**Pattern:** Swen Vincke (Larian Studios) walked away from guaranteed BG4 revenue because the team wasn't excited. The 155-postmortem meta-analysis confirms: team morale is a top-5 success factor.

**Why it matters:**
Developer joy is not separate from game quality. If the developers aren't excited about what they're building, the game won't be exciting either. Excitement compounds — excited developers innovate, take smart risks, and solve problems creatively. Demoralized developers optimize for "done," not "great."

**How to measure it:**
- Add a simple 1-5 "How excited are you about what we're building right now?" check to every retrospective
- Track the trend across sprints
- Scores below 3 trigger a *design review*, not a pep talk

**What low excitement signals:**
- The mechanic being built isn't resonating with the team's instincts
- The deadline is unrealistic given the quality bar
- The core loop doesn't feel fun to the people who live in it 8 hours a day
- The vision isn't clear enough for the team to believe in the outcome

**What to do about it:**
- Don't ignore it or dismiss it as mood
- Ask: "What about this design isn't working for you?"
- Revise the design or the scope, not the team's attitude
- Remember: the team's job is to love the game. If they don't, fix the game

**Integration at FFS:**
- Every retrospective includes the 1-5 excitement check
- Ackbar (QA Lead) tracks excitement trends across projects
- If excitement drops below 3, a design/scope review is triggered
- Excitement is a *leading indicator* of quality — measure it like you measure FPS

---

## 6. Decision Rights Matrix

### Every Decision Type Has a Clear Owner

**Pattern:** Valve's "Flatland" cautionary tale: flat structures without explicit decision rights create invisible hierarchies worse than explicit ones.

**How it works:**
For every decision type, document three things:
- **Who Decides** — The person with final authority in this area
- **Who Advises** — The people who get consulted (but don't override the decision)
- **Who Is Informed** — Everyone else who needs to know the outcome

**Example matrix for FFS:**

| Decision Type | Who Decides | Who Advises | Who Is Informed |
|--------------|-------------|-------------|-----------------|
| Architecture / tech stack | Solo (Lead) | Chewie, McManus | All |
| Game design / mechanics | Yoda (Creative Director) | Lando, Ackbar | All |
| Art direction / visual identity | Boba (Art Director) | Yoda | All |
| Sound design / audio identity | Greedo (Audio Designer) | Yoda | All |
| Enemy/content design | Tarkin (Content Designer) | Yoda, Lando | All |
| UI/UX | Wedge (UI Engineer) | Yoda | All |
| Quality / ship readiness | Ackbar (QA Lead) | All domain owners | Founder |
| Scope / timeline / priority | Founder + Solo (Lead) | Yoda, Ackbar | All |

**Why it matters:**
- Principle #7 (Domain Owners, Not Domain Silos) says domain owners make final calls. But without explicit rights, people guess or argue.
- Explicit rights prevent invisible hierarchies and hidden power brokers
- Clear rights enable parallel work — no one waits for ambiguous approval

**Integration at FFS:**
- Decision rights are documented per project and reviewed with every new team member
- When a decision is unclear, the first step is: "Who owns this decision type per the matrix?"
- If the matrix doesn't cover a decision type, add it during the next retrospective

---

## 7. The Scrumban Approach — Phase-Adaptive Methodology

### Pre-Production: Kanban. Production: Scrum. Polish: Focused Bug-Fix Sprints.

**Pattern:** The best creative game studios don't use pure Scrum or pure Kanban. They adapt based on the phase.

**Why pure Scrum fails for game dev:**
- Creative work (art, design, prototyping) doesn't fit fixed sprints
- Estimation is guesswork; creative tasks surprise you
- Playtest results invalidate estimates mid-sprint

**Why pure Kanban fails at scale:**
- No timeboxed delivery cadence means unclear shipping deadlines
- No sprint ceremony means decisions drift without forcing reflection
- No WIP limits on urgent work leads to thrashing

**The Scrumban Adaptation:**

#### Pre-Production Phase (Concept → Vertical Slice)
- **Use Kanban** — continuous flow with WIP limits
- Board columns: `Backlog → In Progress → Playtesting → Done`
- WIP limit: 2 items per person maximum
- Daily async standups (text-based, 5 minutes max)
- Weekly playtest session as the primary review ceremony
- Rationale: Creative work doesn't fit fixed sprints. Kanban's continuous flow respects the inherent unpredictability of design and prototyping.

#### Production Phase (Post-Vertical-Slice → Beta)
- **Use 2-week Scrum sprints** — structured delivery cadence
- Sprint planning: select items from prioritized backlog (P0 first)
- Daily async standups continue
- Sprint review: playtest the build, not just show diffs
- Sprint retrospective: score each principle 1–5 (per our principles document)
- Rationale: Scope is defined, architecture is proven. Scrum's timeboxing ensures delivery pace while iteration remains playtest-driven.

#### Polish Phase (Beta → Gold)
- **Use 1-week bug-fix sprints** — focused cycles
- Only P0 bugs and critical feel issues enter the sprint
- No new features — only fixes and polish
- Ship-readiness assessed by Ackbar (QA) after each sprint
- Rationale: The game is feature-complete; iteration is tight. Weekly cycles force discipline and prevent late-game thrashing.

**Key adaptations for FFS:**

1. **Playtest sessions replace sprint reviews** — The build is the review (Principle #4)
2. **Retrospectives score our principles** — Which did we honor? Which did we violate? This makes retros actionable, not vague
3. **Async standups, not meetings** — Text-based daily updates preserve focus time for a small team
4. **"Find the fun" gates** — Before any mechanic leaves pre-production, it must pass a team playtest. If the team can't articulate why it's fun, it goes back to prototyping

---

## 8. The 20% Load Cap (Anti-Crunch Insurance)

### No Agent Carries More Than 20% of Any Phase's Items

**Pattern:** Academic research confirms: overloaded individuals are the #1 predictor of indie game crunch and burnout.

**How it works:**
- Count all items in the current phase's backlog (P0–P3)
- No single agent should be assigned more than 20% of those items
- If any agent exceeds 20%, stop and redistribute work before continuing

**Why 20%?**
- 20% of a sprint is defensible work for a specialist. It leaves room for:
  - Collaboration with other domains
  - Ad-hoc problem-solving
  - Playtest iteration cycles
  - Skill development / cross-training
  - Buffer for unexpected issues
- 25%+ consistently leads to overload, poor decisions, and burnout

**Implementation:**
- Ralph (Production Monitor) audits load distribution every sprint
- If overload is detected, the team stops to rebalance before continuing
- This is not kindness — it's anti-crunch insurance

---

## 9. Cross-Domain Review Protocol

### Domain Changes That Affect Other Domains Require a 5-Minute Review

**Pattern:** From Nintendo's cross-pollination success: developers attending each other's work catches problems early and spreads knowledge.

**How it works:**
Every domain change that affects another domain requires a quick review:
- Sound reviews gameplay changes (does the new mechanic need SFX?)
- Gameplay reviews AI changes (does the new behavior break the core loop?)
- QA reviews everything that ships (is it fair? is it clear?)
- Art reviews animation changes (does the timing match the visual style?)

**Why 5 minutes:**
- A full code review takes 30 minutes. A cross-domain check is 5 minutes max.
- The reviewer is asking: "Does this create work for me? Does this break my assumptions?" Not: "Is this the best implementation?"
- It's implied by Principle #7 (Domain Owners attend each other's reviews) but should be a documented checklist item

---

## 10. Portfolio Thinking — 2–3 Games in 5 Years

### Avoid Betting the Studio on One Game

**Pattern:** From the Stanford GSB "One-Hit Wonders vs. Hit Makers" study: the indie industry's 70% failure rate means portfolio diversification is survival strategy, not luxury.

**Recommended portfolio:**
- **Target:** 2–3 games in first 5 years
- **Scoping:** 12–18 month development per game (pre-production + production + polish)
- **Between-release sustainability:** Contract work, porting, DLC for shipped games, community building
- **Never bet the studio on one game.** If one game fails, the studio survives. If all resources are in one project and it fails, the studio is over.

**How it affects hiring and planning:**
- Hire generalists who can move between genres
- Build reusable infrastructure from every project
- Document lessons from every shipping so the next project is faster
- Maintain a portfolio backlog of ideas for future projects

---

## 11. Knowledge Capture & Compounding

### Every Project Teaches the Next

**Pattern:** Supergiant, Nintendo, and Sandfall all institutionalize learning. Studios that compound knowledge ship better games. Studios that don't, repeat investigations.

**The knowledge capture ritual:**

After every major milestone and at the end of every project:
1. **Extract reusable code modules** into a studio library with documented API and known limitations
2. **Document lessons** in the decision log and retrospective findings
3. **Update or create skills** for permanent reference
4. **Tag insights** with the principle they validate or violate
5. **Schedule capture sessions** for tacit knowledge (the stuff people know but haven't written down)

**Integration at FFS:**
- Scribe (Documentation Lead) owns knowledge capture processes
- Every module extracted from a shipped project is documented
- Every decision is logged before it's "forgotten" and re-investigated later
- Skills are treated as living documents — they evolve as we learn

---

## 12. The Confidence Rating

Every studio-craft principle in this document is marked with a confidence level:

- **🟢 High confidence** — Validated across multiple projects, backed by extensive research, proven in practice
- **🟡 Medium confidence** — Validated in firstPunch, supported by multiple studios' approaches, not yet tested in different genres
- **🔴 Low confidence** — First observation from research, not yet validated across multiple projects at FFS

**This skill is marked `low` confidence** because it represents our *first* observation from industry research, not yet proven across multiple projects. As we ship more games and validate these patterns, confidence increases.

When confidence is low, read the patterns for inspiration but be ready to adapt. When confidence is high, treat them as studio law.

---

## Summary Table

| Meta-Skill | Purpose | Owner | When Used |
|----------|---------|-------|-----------|
| **Creative Vision Management** | Ensure all domains feel like the same game | Creative Director (Yoda) | Every design review; every aesthetic decision |
| **Feature Triage** | Kill features that don't serve the core loop | Domain owners + Creative Director | Backlog prioritization; design reviews |
| **Playtest-Driven Iteration** | Ensure quality through measurable iteration cycles | Ackbar (QA) + all domains | Every core mechanic before ship |
| **Postmortem Discipline** | Institutionalize lessons so we don't repeat mistakes | Solo (Lead) + all agents | After every major milestone; before next project |
| **Developer Joy Metric** | Use team excitement as a leading indicator of game quality | Ackbar (tracks in retros) | Every retrospective |
| **Decision Rights Matrix** | Eliminate ambiguity about who decides what | Solo (maintains matrix) | Every decision; every new project |
| **Scrumban Methodology** | Adapt to phase-specific needs (pre-prod Kanban, prod Scrum) | Ralph (enforces cadence) | Every sprint; every phase transition |
| **20% Load Cap** | Prevent crunch and overload | Ralph (audits load) | Every sprint |
| **Cross-Domain Review** | Catch problems early; spread knowledge | All domain owners | Every domain change |
| **Portfolio Thinking** | Spread risk across multiple projects | Founder + Solo | Long-term planning |
| **Knowledge Capture** | Compound studio capability across projects | Scribe (manages process) | After every milestone; every shipped game |

---

*This skill should be read by every agent before their first sprint. It's not optional philosophy — it's how we operate as a studio.*
