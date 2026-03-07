# Decision: Studio Growth Framework Created

**Date:** 2025  
**Author:** Yoda (Game Designer)  
**Status:** Complete  
**Scope:** Studio meta-architecture and scaling strategy  

---

## The Decision

First Frame Studios has created a comprehensive **Growth Framework** (`.squad/identity/growth-framework.md`) that documents how the studio will evolve from a single-game team to a multi-game, multi-genre studio without breaking under its own weight.

---

## Why Now?

The founder's directive: **"amplitud de miras"** (breadth of vision). SimpsonsKong proved we can ship one game. But the studio must be built to absorb new genres, new platforms, new team members, and new challenges without fundamental restructuring.

At growth inflection points, studios either:
1. **Scale vertically** — Add more layers of management, more process overhead, more bureaucracy. This works at massive scale but kills small teams.
2. **Scale horizontally** — Add more teams, same structure, shared knowledge base. This requires documenting everything so knowledge compounds.

First Frame Studios chooses **horizontal scaling** with a documented foundation.

---

## Core Insight: The 70/30 Rule

**70% of what makes First Frame Studios effective is PERMANENT and tech/genre agnostic:**
- Leadership principles (decision-making algorithms)
- Quality gates and definition of done (outcome-based standards)
- Team structure and domain ownership model
- Design methodology (research → GDD → backlog → build → retrospective → skills)
- Company identity and values

**30% is ADAPTIVE and changes per project:**
- Engine-specific skills (Canvas 2D vs. Godot 4 vs. Unreal)
- Genre-specific skills (beat 'em up combat vs. platformer physics vs. fighting game netcode)
- Code patterns and architecture (specific to tech stack)
- Art pipelines (sprites vs. models vs. vector)

This ratio means: **New genres, new platforms, and new teams don't break us. They're absorbed by the permanent 70%.**

---

## What the Framework Delivers

1. **Skill Architecture** — How knowledge compounds across projects: universal skills (state machines, game feel), genre verticals (beat 'em up, future platformer/fighting), tech stack skills, and maturity levels.

2. **Team Elasticity** — Core roles (Game Designer, Lead, Engine, Gameplay, QA) are permanent. New roles emerge per project scope. New genres may require new specialist roles (e.g., Level Designer for platformer, Netcode Engineer for fighting game).

3. **Genre Onboarding Protocol** — Two playbooks:
   - **First genre:** 8 weeks (research → GDD template → minimum playable → skill creation → team assessment → architecture spike)
   - **Returning to genre:** 4 weeks (read existing skills, check for updates, start with institutional advantage)

4. **Technology Independence** — GDD, principles, quality gates, and team charters are engine-agnostic. Only engine-specific skills, build pipelines, and architecture docs are locked to a platform. If Canvas 2D becomes obsolete, we port to Godot 4. The 70% carries forward unchanged.

5. **Risk Mitigation** — Six risks that force restructuring if ignored (knowledge-in-head, engine lock-in, single-genre limit, process scalability, key person dependency, platform obsolescence). For each, the documented prevention.

6. **Growth Milestones** — Five stages: Single Genre → Second Genre → Multi-Genre → Multi-Platform → Studio Scale. The framework explains what each stage proves and what risks it mitigates.

---

## Trade-Offs and Alternatives

### Alternative 1: "Don't document. Trust people and relationships."
- **Pro:** Faster in the short term. Less "bureaucracy."
- **Con:** Catastrophic when people leave. Knowledge dies. Studio must rehire and retrain. At Stage 2 or 3, this breaks the studio.
- **Why we didn't choose this:** SimpsonsKong already taught us that institutional memory (decisions.md, skills, history.md) is what compounds. We can't rely on people staying; we have to rely on documented patterns.

### Alternative 2: "Create new structure for each new genre."
- **Pro:** Each genre gets optimized structure.
- **Con:** Restructuring overhead kills momentum. Team churn. Principles become inconsistent. By Stage 3 (multi-genre), the studio becomes a chaos of different cultures.
- **Why we didn't choose this:** The framework proves that one squad structure can absorb any genre. Efficiency comes from consistent structure, not specialized structure.

### Alternative 3: "Write the framework after the second game ships."
- **Pro:** We'll have more data.
- **Con:** The second game will be chaotic and slow because the team won't have a shared mental model of how to scale. Decision-making will be ad-hoc. We'll make preventable mistakes.
- **Why we didn't choose this:** Writing the framework *now*, from SimpsonsKong's lessons, gives us a hypothesis to test with the second game. If the hypothesis holds, the second game will be faster. If it breaks, we'll learn why and update the framework.

---

## Implementation

The Growth Framework is **not** a change to current operations. It is a **description of how we already work** (from SimpsonsKong) plus a **set of protocols for what comes next**.

**Immediate actions:**
1. ✅ Growth Framework created and archived at `.squad/identity/growth-framework.md`
2. ✅ Learnings appended to `.squad/agents/yoda/history.md`
3. 🔲 Distributed to team and discussed in next studio meeting
4. 🔲 Used as the foundation for the next project's onboarding

**When the second project starts:**
1. Team reads the relevant sections (Sections 2–4: Skill Architecture, Team Elasticity, Genre Onboarding Protocol)
2. Follow the Genre Onboarding Protocol (8 weeks of research/planning before Sprint 0)
3. Document findings in the retrospective and update the framework with what we learned

---

## Reversibility

**This is highly reversible.** The Growth Framework is a description of intent, not a constraint. If the team discovers that the framework is wrong, we update it. If the 70/30 ratio doesn't hold, we change the ratio. If the genre onboarding protocol doesn't work, we redesign it.

The only part that's non-reversible is: **Committing to documentation as the source of truth.** Once we've organized institutional knowledge around written skills and decision logs, we can't go back to "knowledge in people's heads" without losing everything. But that's the direction we've already chosen (with SimpsonsKong's GDD, skills, and decisions.md), so this isn't a new commitment.

---

## Success Criteria

The Growth Framework succeeds if:

1. **Second game launches faster than first** — Research, planning, and architecture spikes take 4 weeks instead of 8 (because we have existing knowledge).
2. **No reshuffling of team structure** — We don't need to reorganize roles or create new departments to ship the second game.
3. **Skills compound** — We can point to at least two transferable patterns from beat 'em up that accelerated the second game's development.
4. **New genres don't break quality** — The second game ships at the same quality bar as SimpsonsKong without working weekends or hiring crisis staff.
5. **Framework survives contact with reality** — We update the framework based on what we learned. Some claims will be wrong; that's OK.

---

## Related Decisions

- [Yoda — Game Vision](../yoda-game-vision.md) — The GDD and design principles that shape all games
- [Solo — Team Expansion](../solo-team-expansion.md) — The squad structure that this framework describes
- [Company Identity](../identity/company.md) — Section 7 (Genre Strategy — Vertical Growth) is the narrative version of this framework

---

## Notes for Future Readers

If you're reading this in Year 2 or beyond:

1. **Check if the 70/30 rule held.** Did 70% of the studio's effectiveness remain constant across genres? Or did the split change? Document your findings.
2. **Check if the genre onboarding protocol worked.** Did the second genre take 8 weeks (first time) or 4 weeks (returning)? What was faster? What was slower?
3. **Check if team elasticity proved correct.** Did new roles emerge as predicted? Did the core structure absorb them, or did the team need to restructure?
4. **Update the framework with what you learned.** Stamp the date and note what changed.

This framework is a hypothesis. Your job is to test it, refine it, and make it true.

---

**Co-authored-by:** Copilot <223556219+Copilot@users.noreply.github.com>
