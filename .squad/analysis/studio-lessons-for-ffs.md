# Studio Lessons for First Frame Studios

> **Author:** Yoda (Game Designer)
> **Date:** 2025
> **Status:** Active — Action items for immediate studio improvement.
> **Source:** `.squad/analysis/studio-research.md` (comprehensive industry research)

---

## Purpose

This document maps the most impactful findings from our industry research to specific, actionable improvements for First Frame Studios. It answers four questions:
1. Which principles should we add or modify?
2. Which skills are missing?
3. Which processes should we adopt?
4. What should we STOP doing?

---

## 1. Principles to Add or Modify

### ADD: "The Vision Has a Keeper"

**Source:** Every studio studied — Miyazaki, Vincke, Kasavin, Broche, Barone — has one creative vision holder.

**What it means:** Designate a Creative Director per project with explicit authority over aesthetic coherence, narrative voice, and design identity. Domain owners execute within their domains. The Vision Keeper ensures all domains serve the same game.

**Why we need it:** Our domain ownership model (Principle #7) distributes execution well but doesn't guarantee vision coherence. When the sound designer, the art director, and the gameplay programmer each make independent "correct" decisions, the results can feel disconnected without a unifying filter.

**Proposed principle language:**
> *"Every project has one Vision Keeper — the person who decides not what each system does, but whether all systems feel like the same game. Domain owners own quality. The Vision Keeper owns identity."*

### MODIFY: Principle #4 "Ship the Playable" → Add Iteration Minimum

**Source:** Supergiant, Larian, and the 155-postmortem meta-analysis all show that iteration count correlates with quality.

**Current gap:** We say "ship the playable" but don't specify how many iteration cycles a mechanic needs before it's considered done.

**Proposed addition:**
> *"No core mechanic ships after fewer than 3 iteration cycles. Each cycle includes: build → playtest → measure → revise. If a mechanic feels right on the first try, you haven't tested it hard enough."*

### MODIFY: Principle #10 "Measure the Fun" → Add Developer Joy

**Source:** Larian (Vincke walked away from BG4 because the team wasn't excited), Diablo II postmortem (morale crash nearly killed the project), 155-postmortem meta-analysis (team morale in top 5 success factors).

**Proposed addition:**
> *"Measure the team's fun too. If the developers aren't excited about what they're building, that's a design signal — not a morale problem. Developer joy is a leading indicator of game quality. Track it in retrospectives."*

---

## 2. Missing Skills

### CRITICAL: Streamability/Shareability Design

**Source:** Balatro, Lethal Company, Palworld — the 2024-2025 breakout hits were all inherently watchable.

**Gap:** We have no skill or framework for designing moments that are entertaining to watch, not just play. In the streaming/TikTok era, a game's marketing effectiveness is partially determined by its design.

**Action:** Create a `streamability-design` skill covering:
- Designing for emotional peaks (triumph, surprise, humor, failure)
- Visual clarity for viewers (not just players)
- Emergent moment generation (systemic interactions that produce unexpected results)
- "Clip-worthy" moment frequency per play session

### HIGH: Feature Triage Protocol

**Source:** 155-postmortem meta-analysis (#1 failure cause: scope creep), Valve's cutting discipline, Nintendo's playtest-driven cutting, Sid Meier's rapid prototype + cut process.

**Gap:** We identify items as "Quick Wins," "Medium Effort," and "Future/Migration" — but we don't have a formal kill protocol for features that aren't working.

**Action:** Create a `feature-triage` skill with the 4-test framework:
1. Core loop test — does it strengthen the core loop?
2. Player impact test — would a first-time player miss it?
3. Cost-to-joy ratio — dev hours vs. player delight
4. Coherence test — does it feel like *this* game?

### MEDIUM: AI-Assisted Development Workflow

**Source:** 2024-2025 AI tool landscape — code generation, asset creation, QA automation.

**Gap:** We don't use AI tools systematically. The industry is moving fast; studios that integrate AI into their pipeline gain 30-40% efficiency on routine tasks.

**Action:** Evaluate and integrate:
- GitHub Copilot / Cursor for boilerplate code
- AI image generators for concept art exploration
- AI-powered QA for automated regression testing
- Clear policy: AI generates options, humans make choices

---

## 3. Processes to Adopt

### Process 1: Five-Minute Test (Immediate)

**Source:** Balatro (hook in 30 seconds), Hollow Knight (movement mastery in 5 minutes), Lethal Company (fun in first group session), our own Principle #1.

**What:** Every playable build is tested by someone who has NEVER played the game. Their experience in the first 5 minutes is documented:
- Time to first fun moment
- Time to confusion (if any)
- Time to first "I want to keep playing" signal
- Specific friction points

**Who:** Ackbar (QA Lead) owns this process.

### Process 2: All Disciplines from Sprint 0 (Next Project)

**Source:** Supergiant (every discipline from Day 1), Sandfall (4 musicians embedded from start), Team Cherry (composer played the game during development).

**What:** When a new project kicks off, every domain owner participates from Sprint 0. No domain is "added later." The sound designer, the art director, the UI designer — all present from the first playable build.

**Why:** Art, audio, and narrative designed in isolation from gameplay feel bolted on. Designed together from the start, they become inseparable from the experience.

**Integration with playbook:** Update `.squad/identity/new-project-playbook.md` to mandate all-domain Sprint 0 participation.

### Process 3: Formal Postmortem Protocol (Before Next Project)

**Source:** 155-postmortem meta-analysis, Diablo II postmortem, GDC best practices.

**What:** Run a "5 things that went right / 5 things that went wrong" postmortem on SimpsonsKong. Document:
- Each squad member contributes their top 3 right/wrong items
- Items are synthesized into studio-level lessons
- Actionable items are added to the next project's Sprint 0 checklist

**Who:** Solo (Lead) facilitates. Every squad member participates.

### Process 4: Design Lenses Review (Ongoing)

**Source:** Jesse Schell's *Art of Game Design* (100+ lenses), GDC 2025 studio principles talk.

**What:** Add 5 key lenses to our design review process (in addition to our 12 principles):
1. **The Lens of Surprise** — What will surprise the player? Surprise is the root of fun.
2. **The Lens of Endogenous Value** — Is this valuable *within the game*, or only abstractly?
3. **The Lens of Flow** — Is the challenge-skill ratio keeping the player in flow?
4. **The Lens of the Player** — Who exactly is the player, and what do they want?
5. **The Lens of Fun-as-Learning** — What new pattern is the player learning here?

---

## 4. What We Should STOP Doing

### STOP: Treating all 12 principles as equally weighted in every context

**Insight:** Schell's GDC talk shows that effective principles have clear hierarchy and application contexts. Our principles are strong but we apply them uniformly. Some contexts need different emphasis:
- Pre-production: Principles #2 (Research), #3 (IP), #5 (Feel It) should dominate
- Production: Principles #4 (Ship), #9 (Infrastructure), #10 (Measure) should dominate
- Polish: Principles #1 (Player Hands), #8 (Bugs), #11 (Constraints) should dominate

**Action:** Create a "Principle Priority Matrix" per project phase.

### STOP: Assuming internal-only production is always best

**Insight:** Sandfall, Supergiant, and Balatro all used strategic external support (outsourced QA, publishers for marketing, external agencies for non-core work) while maintaining creative control internally.

**Action:** For the next project, identify which work is "core vision" (stays inside) vs. "support execution" (candidates for external help). Early candidates: platform QA, localization, marketing asset creation.

### STOP: Skipping the "developer joy" check

**Insight:** Vincke walked away from guaranteed revenue (BG4) because the team wasn't excited. The 155-postmortem study shows team morale is a top-5 success predictor. We track process adherence but not creative excitement.

**Action:** Add a simple 1-5 "How excited are you about what we're building right now?" check to every retrospective. Scores below 3 trigger a design review, not a pep talk.

### STOP: Designing only for the player (not the viewer)

**Insight:** The 2024-2025 hits (Balatro, Lethal Company, Palworld) were as fun to watch as to play. We design exclusively for the person holding the controller.

**Action:** Add "Is this watchable?" to our design evaluation criteria. For beat 'em ups specifically: big hits, comedy moments, combo chains, and dramatic failures are inherently streamable if we design for emotional peaks.

---

## Priority Summary

| Priority | Action | Owner | Timeline |
|----------|--------|-------|----------|
| P0 | Add "Vision Keeper" principle + role | Yoda | Before next project |
| P0 | Run SimpsonsKong postmortem (5/5 format) | Solo + All | Before next project |
| P0 | Institute Five-Minute Test protocol | Ackbar | Immediate |
| P1 | Create `feature-triage` skill | Yoda + Solo | Next sprint |
| P1 | Create `streamability-design` skill | Yoda + Boba | Next sprint |
| P1 | Modify Principle #4 (add iteration minimum) | Yoda | Next sprint |
| P1 | Modify Principle #10 (add developer joy) | Yoda | Next sprint |
| P1 | Update playbook: all disciplines from Sprint 0 | Solo | Before next project |
| P2 | Create Principle Priority Matrix (per phase) | Yoda | Next quarter |
| P2 | Evaluate AI tools for pipeline integration | Chewie + McManus | Next quarter |
| P2 | Add Design Lenses to review process | Yoda | Next quarter |
| P3 | Identify outsourcing candidates for next project | Solo | Pre-production |
