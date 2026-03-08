# Operations Lessons for First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Proposed — Ready for founder review  
**Depends on:** `.squad/analysis/studio-operations-research.md` (full research backing)  
**Scope:** Actionable recommendations for how FFS should operate, organized by decision area.

---

## Executive Summary

After researching how the industry's best studios organize, develop, and sustain themselves, I've mapped findings against our current structure, principles, and playbook. The good news: FFS is already doing many things right — our domain ownership model, knowledge documentation habit, and "find the fun" prototyping philosophy align with proven industry patterns. The gaps are operational: we need clearer methodology, smarter tooling, and a documented business strategy.

---

## 1. Organizational Structure — What Should We Change?

### Current State
FFS operates as a 12-specialist squad with clear domain ownership (Principle #7). Each domain has a dedicated owner. This is already better than most indie studios.

### Recommendations

#### ✅ KEEP: Domain Ownership Model
Our model maps closely to the Supercell cell structure and Nintendo's franchise-team approach. Key validation:
- Supercell cells (10–17 people) match our 12-person squad size
- Nintendo's "stable leadership, mobile developers" pattern mirrors our structure
- Academic research confirms that role clarity is a direct antecedent of psychological safety

#### ⚠️ ADD: Explicit Decision Rights Matrix
Valve's cautionary tale shows that flat structures without explicit decision rights create invisible hierarchies. We should document:

| Decision Type | Who Decides | Who Advises | Who Is Informed |
|--------------|-------------|-------------|-----------------|
| Architecture / tech stack | Solo (Lead) | Chewie, McManus | All |
| Game design / mechanics | Yoda | Lando, Ackbar | All |
| Art direction / visual identity | Boba | Yoda | All |
| Sound design | Greedo | Yoda | All |
| Enemy/content design | Tarkin | Yoda, Lando | All |
| UI/UX | Wedge | Yoda | All |
| Quality / ship readiness | Ackbar | All domain owners | Founder |
| Scope / timeline / priority | Founder + Solo | Yoda, Ackbar | All |

**Why:** Principle #7 says domain owners make the final call. But we've never written down which decisions belong to which owner. This matrix eliminates the "Valve problem" of unspoken power dynamics.

#### ⚠️ ADD: Cross-Domain Review Protocol
Nintendo's cross-pollination success comes from developers attending each other's work. We should formalize:
- Every domain change that affects another domain requires a 5-minute review from the affected domain owner
- Sound reviews gameplay changes (does the new mechanic need SFX?). Gameplay reviews AI changes (does the new behavior break the core loop?). QA reviews everything that ships.
- This is already implied by Principle #7 ("domain owners attend each other's reviews") but should be a documented checklist item

#### 🟢 VALIDATED: 20% Load Cap Rule
Our existing playbook rule (no agent carries >20% of any phase's items) is directly supported by research on small-team dynamics. Overloaded individuals are the #1 predictor of crunch in indie studios.

---

## 2. Development Methodology — What Fits Us Best?

### Current State
We have a milestone system in our playbook (Concept → Prototype → Alpha → Beta → Gold) and priority-based backlog (P0–P3). But we don't have a documented sprint/iteration methodology.

### Recommendation: "Scrumban" — Adapted for FFS

Based on research, the methodology that best fits a 12-person creative game studio is **phase-adaptive Scrumban**:

#### Pre-Production Phase (Concept → Vertical Slice)
- **Use Kanban** — continuous flow with WIP limits
- Creative work (design, prototyping, art exploration) doesn't fit fixed sprints
- Board columns: `Backlog → In Progress → Playtesting → Done`
- WIP limit: 2 items per person maximum
- Daily async standups (text-based, not meetings)
- Weekly playtest session as the primary review ceremony

#### Production Phase (Post-Vertical-Slice → Beta)
- **Use 2-week Scrum sprints** — structured delivery cadence
- Sprint planning: select items from prioritized backlog (P0 first)
- Sprint review: playtest the build, not just show diffs
- Sprint retrospective: score each principle 1–5 (per our principles document)
- Daily async standups continue

#### Polish Phase (Beta → Gold)
- **Use focused bug-fix sprints** — 1-week cycles
- Only P0 bugs and critical feel issues
- Ship-readiness assessed by Ackbar (QA) after each sprint
- No new features — only fixes and polish

#### Key Adaptations for FFS
1. **Playtest sessions replace sprint reviews.** The build is the review (Principle #4: Ship the Playable)
2. **Retrospectives score our principles.** Which did we honor? Which did we violate? This makes retros actionable, not vague
3. **Async standups, not meetings.** Text-based daily updates preserve focus time for a small team
4. **"Find the fun" gates.** Before any mechanic leaves pre-production, it must pass a team playtest. If the team can't articulate why it's fun, it goes back to prototyping

---

## 3. Tools We Should Evaluate or Build

### Evaluate (Buy/Adopt)

| Tool | Purpose | Why Now |
|------|---------|---------|
| **Godot Engine** | Next project's game engine | Already identified in playbook as likely migration target. Open source, no licensing fees, strong 2D/3D |
| **Codecks** | Project management | Designed specifically for game dev. Card-based, supports Kanban+Scrum hybrid. Better than generic tools (Jira, Trello) for game teams |
| **FMOD / Wwise** | Audio middleware | Greedo's sound design work would benefit from professional audio tooling. Both have free indie tiers |
| **Aseprite** | Pixel/sprite art | If our next project uses sprite-based art, Aseprite is the industry standard for indie studios |
| **Git LFS or Perforce** | Large asset version control | Essential when we move to a real art pipeline with sprite sheets, audio files, and level data |
| **GitHub Actions** | CI/CD | We're already on GitHub. Adding automated build + test on every commit is the highest-leverage infrastructure investment |

### Build (Custom Internal Tools)

| Tool | Purpose | Why Build |
|------|---------|-----------|
| **Game Feel Tuning Panel** | Real-time parameter adjustment during play (hitlag, screen shake, knockback, timing windows) | This is our core differentiator (Principle #1: Player Hands First). No off-the-shelf tool tunes game feel as well as a custom debug overlay |
| **Balance Data Dashboard** | Visualize DPS, health curves, difficulty progression in real-time | Principle #10 (Measure the Fun) requires data, not vibes. A custom dashboard surfaces balance issues faster than spreadsheets |
| **Reusable Module Library** | Audio system, input manager, save/load, UI framework, scene transitions | Extract from SimpsonsKong and future projects. Research shows 30–50% faster project starts. This IS Principle #12 in action |

### Don't Build
- Game engine (use Godot/Unity/Unreal)
- Version control (use Git)
- Art tools (use Blender/Aseprite)
- CI/CD infrastructure (use GitHub Actions)

---

## 4. Crunch Prevention — Structural Safeguards

Based on academic research and Supergiant's model, crunch is a structural failure, not a personal one. FFS should embed these anti-crunch patterns:

1. **Flexible timelines over fixed release dates.** Set target windows, not hard dates. Announce release dates only after Beta milestone is passed
2. **20% load cap is non-negotiable.** If any agent exceeds 20% of phase items, stop and redistribute before continuing
3. **Scope cutting protocol:** When behind schedule, cut P3 items first, then P2. Never cut P0/P1. Never add hours — always cut scope
4. **Mandatory retrospective after every milestone.** Ask: "Did anyone work unsustainable hours? Why? What structural change prevents it next time?"
5. **Phase-adaptive methodology prevents end-of-cycle crunches.** Iterative development with continuous integration means no "big bang" integration phase

---

## 5. Knowledge Management — Strengthening Our Advantage

### Current State
FFS already does knowledge management better than most studios. We have:
- Skills system (12 documented skills)
- Decision log (`.squad/decisions.md`)
- Agent history files
- Principles document
- New Project Playbook

This is a genuine competitive advantage. Research confirms that studios with centralized knowledge repositories outperform those relying on individual memory.

### Recommendations to Strengthen

1. **Post-project module extraction ritual.** After every shipped project, spend 1–2 weeks extracting reusable code modules into a studio library. Document API, usage patterns, known limitations. This converts project knowledge into studio assets

2. **Quarterly knowledge audit.** Ackbar should audit:
   - Are skills being referenced? (if not, they're dead weight)
   - Are decisions being followed? (if not, update or remove them)
   - What tacit knowledge exists that isn't documented? (schedule capture sessions)

3. **Onboarding test.** New agents should be able to read our documentation and pass a "first week" competency check. If they can't, the docs have gaps. This keeps documentation honest

4. **Cross-project postmortem.** After SimpsonsKong's completion, run a formal postmortem that produces a searchable document. Every lesson should be tagged with the principle it validates or violates

---

## 6. Business Model Considerations

### For SimpsonsKong (Current Project)
- **Model:** Free browser game (passion project / learning vehicle)
- **Revenue:** None expected — this is our "tuition"
- **Value:** Institutional knowledge, team capability development, portfolio piece

### For Future Projects — Document These Decisions Early

| Question | Recommended Default | When to Deviate |
|----------|-------------------|-----------------|
| Revenue model? | Premium (one-time purchase) | Only go F2P if game design requires live-service |
| Early Access? | Yes, for PC projects | Use Supergiant's model: genuine development tool, not just pre-sales |
| Publisher? | Self-publish first, evaluate publishers after playable demo exists | Seek publisher if marketing budget >2x development budget |
| Crowdfunding? | Only if community already exists | Never crowdfund a first game with no audience |
| Platform? | PC first (Steam), then expand | Console ports as revenue extension of proven games |
| Scope? | 12–18 month projects | Avoid 3+ year development cycles until studio has shipped 3+ games |

### Portfolio Strategy
Based on research (Stanford GSB "One-Hit Wonders vs. Hit Makers" study):
- **Target: 2–3 games in first 5 years** (middle path between portfolio diversification and quality investment)
- **Each game scoped to 12–18 months** of development (pre-production + production + polish)
- **Between-release sustainability:** Contract work, porting, DLC for shipped games, community building
- **Never bet the studio on one game.** The 70% indie failure rate means portfolio diversification is survival strategy, not luxury

---

## 7. Priority Actions (Ranked)

These are the specific next steps, ordered by impact:

| Priority | Action | Owner | Effort |
|----------|--------|-------|--------|
| **P0** | Document Decision Rights Matrix (Section 1) | Solo | 1 session |
| **P0** | Adopt Scrumban methodology (Section 2) and document in playbook | Solo + Ackbar | 1 session |
| **P1** | Set up GitHub Actions CI for current repo | Chewie | 2–4 hours |
| **P1** | Build game feel tuning panel (debug overlay) | Lando + Chewie | 1–2 days |
| **P1** | Evaluate Codecks or similar game-dev project management tool | Solo | 1 hour |
| **P2** | Create balance data dashboard | Ackbar + Lando | 1–2 days |
| **P2** | Begin reusable module extraction from SimpsonsKong | Chewie + Greedo | 2–3 days |
| **P2** | Evaluate Godot for next project (formal 9-dimension matrix) | Solo + Chewie | 1 session |
| **P3** | Formalize cross-domain review checklist | Ackbar | 1 hour |
| **P3** | Document business model framework in playbook | Solo + Founder | 1 session |
| **P3** | Run SimpsonsKong postmortem and publish findings | All agents | 1 session |

---

## Closing Note

The research validates what SimpsonsKong taught us through experience: small teams win through clarity (who decides what), discipline (structured iteration, not hero-mode), and compounding knowledge (every project makes the next one better). The industry's best studios — Supergiant, Nintendo, Supercell — all share these traits regardless of their size or structure.

What separates FFS from most indie studios is that we already document our lessons. The next step is to operationalize them: turn principles into processes, turn knowledge into reusable tools, and turn one successful project into a studio that ships consistently.

*— Solo, Lead / Chief Architect, First Frame Studios*
