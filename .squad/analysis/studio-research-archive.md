# studio-research.md — Full Archive

> Archived version. Compressed operational copy at `studio-research.md`.

---

# Studio Research: Patterns from the Industry's Best

> **Author:** Yoda (Game Designer)
> **Date:** 2025
> **Status:** Active — Living research document. Updated as new industry insights emerge.
> **Method:** Web research across 15+ sources per theme. Studios studied: Sandfall Interactive, Supergiant Games, Team Cherry, ConcernedApe, Larian Studios, FromSoftware. Recent hits studied: Balatro, Palworld, Lethal Company. Academic sources: GDC Vault, Jesse Schell (GDC 2025), 155-postmortem meta-analysis, Raph Koster, Jesse Schell books.

---

## How to Read This Document

This document is organized by **theme**, not by studio. Each pattern is a principle we can learn from — illustrated by real studios, real games, and real data. Where a pattern confirms something we already do at First Frame Studios, it's noted. Where it challenges us, it's flagged.

---

## 1. The Singular Creative Vision

**Pattern:** Every exceptional studio has ONE person (or a tiny nucleus of 2-3) who holds the creative vision. Not a committee. Not a democratic vote. A creative director whose taste is the filter through which everything passes.

### Evidence

| Studio | Vision Holder | Role |
|--------|--------------|------|
| Sandfall Interactive | Guillaume Broche | Creative Director — chose Belle Époque art direction, oversaw every aesthetic decision |
| Supergiant Games | Greg Kasavin + Amir Rao | Creative Director + Studio Director — Kasavin writes all narrative; Rao guards the process |
| Team Cherry | Ari Gibson + William Pellen | Co-directors — Gibson owns art/animation, Pellen owns gameplay/enemy design |
| ConcernedApe | Eric Barone | Everything — solo dev, sole vision holder by definition |
| Larian Studios | Swen Vincke | CEO/Creative Director — personally championed BG3's scope and player agency |
| FromSoftware | Hidetaka Miyazaki | President/Director — his design philosophy *is* the Soulslike genre |

### The Insight

Creative vision is not a luxury. It is the *product*. When Miyazaki says "difficulty is engagement," that's not a design spec — it's the soul of every FromSoftware game. When Broche chose Belle Époque France over generic fantasy, Expedition 33 became visually unforgettable. The vision holder doesn't need to touch every asset — they need to touch every *decision*.

### Validation for FFS

Our Principle #3 ("The IP Is the Soul") captures half of this. But we lack a formal **Creative Director role** with explicit veto power over aesthetic and design coherence. Our domain ownership model distributes decision-making — which is great for execution, but risky for vision coherence across domains.

**Gap identified:** We need a "Vision Keeper" function, not just domain owners.

---

## 2. Intentionally Small Teams

**Pattern:** The best indie studios resist growth. They stay small on purpose, even after massive success.

### Evidence

- **Sandfall Interactive:** 30-33 core members. After Expedition 33 became a GOTY contender, they publicly stated they will NOT grow. "33 team members and a dog" is their ideal.
- **Supergiant Games:** 20-25 people across all titles. Everyone wears multiple hats. They've never scaled up despite Hades selling millions.
- **Team Cherry:** 3 people made Hollow Knight (15M+ copies sold). Silksong is still being made by essentially the same tiny team.
- **ConcernedApe:** 1 person. Stardew Valley (30M+ copies). He still develops solo.

### The Insight

Small teams have structural advantages that large teams cannot replicate:
1. **Decision speed:** No approval chains. Ideas go from concept to prototype in days, not months.
2. **Communication clarity:** Everyone knows everything. No information silos.
3. **Creative coherence:** Fewer voices means a purer creative vision.
4. **Accountability:** No hiding. Every person's work is visible.
5. **Passion density:** Small teams self-select for people who truly care. There's no room for passengers.

Sandfall's hiring process (200+ interviews for ~30 positions) reveals that staying small requires *extreme selectivity*. They hired juniors from Reddit and SoundCloud based on raw talent and passion, not credentials.

### Validation for FFS

Our 12-specialist squad model is well-sized. The risk is the opposite: are we spreading 12 roles too thin? When Ackbar audited our skills, coverage was 5/10. That suggests some roles may lack depth rather than breadth.

**Takeaway:** Don't add headcount. Deepen expertise per role. Sandfall's model of hiring for passion and raw talent over experience is worth adopting.

---

## 3. The Hybrid Production Model

**Pattern:** Small core team + strategic outsourcing for non-core work = AAA quality at indie scale.

### Evidence

- **Sandfall Interactive:** Core 30 people handled design, art direction, and programming. Outsourced QA, localization, marketing, and some animation to external agencies. Result: AAA visual quality on a sub-$10M budget.
- **Supergiant Games:** Small core team, but brought in Darren Korb (composer) and Jen Zee (art director) as integral long-term collaborators — blurring the line between "core" and "external."
- **Balatro:** Solo developer (LocalThunk) for gameplay. Publisher Playstack handled marketing, ports, and community management. LocalThunk retained creative control.

### The Insight

The hybrid model works because it preserves what matters (creative control, vision coherence, iteration speed) while offloading what doesn't need the core team's attention (QA at scale, localization, marketing campaigns, platform ports).

The key discipline: **outsource execution, never outsource judgment.** The creative decisions stay inside. The mechanical work goes outside.

### Relevance to FFS

We currently do everything internally. As we scale to more ambitious projects, we should identify which work is "core vision" (must stay inside) vs. "core execution" (can be supported externally). Candidates for outsourcing: localization, platform-specific QA, marketing asset creation.

---

## 4. Iterative Development as Religion

**Pattern:** The best studios don't design then build. They build then discover.

### Evidence

- **Supergiant Games (Hades):** Used Early Access as a "pilot episode" — shipping an incomplete game to learn what resonated. Iterated for 2 years based on real player feedback. The narrative loop (Zagreus escaping the Underworld) was refined to integrate with the roguelike structure through dozens of iteration cycles.
- **Team Cherry (Hollow Knight):** Started as a game jam prototype ("Beneath the Surface" theme). Every new idea was prototyped rapidly and added if it worked. This created scope creep risk but also produced the game's extraordinary depth and interconnectedness.
- **Larian Studios (BG3):** Embraced Early Access. Player feedback directly shaped act structure, companion behavior, and combat balance. Vincke: "If you don't have developer joy, you can't make anything good."
- **Balatro:** LocalThunk iterated obsessively on the core loop, testing with small groups, refining modifier balance and UI before public launch.

### The Insight

Iteration is not just a process — it's a *philosophy*. These studios share a belief that:
1. The game knows what it wants to be better than the designer does.
2. Plans are hypotheses, not contracts.
3. Player feedback is data, not opinion.
4. The first version of anything is wrong. The tenth version might be right.

Supergiant's Greg Kasavin calls their early builds "pilot episodes" — a mental model that treats the first release as a beginning, not a product.

### Validation for FFS

Our Principle #4 ("Ship the Playable") captures this. But we lack a formal **iteration protocol** — how many cycles does a mechanic go through before it's considered "done"? The postmortem meta-analysis (155 games) found that insufficient iteration was one of the top 5 causes of game failure.

**Gap identified:** We need a minimum iteration count per mechanic type.

---

## 5. Art, Music, and Story as Core Systems

**Pattern:** In the best studios, art, audio, and narrative are not polish. They are architecture.

### Evidence

- **Supergiant Games:** Darren Korb (composer) and Greg Kasavin (writer) are involved from Day 1 of every project. Music and narrative are not applied after gameplay is done — they co-evolve with mechanics. In Hades, the narrative *is* the progression system.
- **FromSoftware:** Miyazaki's environmental storytelling (item descriptions, spatial narrative, cryptic NPCs) is the primary storytelling medium. The lore is not cutscenes bolted on — it's woven into level geometry, enemy placement, and item text.
- **Team Cherry:** Christopher Larkin's soundtrack was composed in tandem with level creation. Each area's music captures its atmosphere because the composer played the game as it was being built.
- **Sandfall Interactive:** 4 musicians embedded in the team. Art direction driven by Belle Époque cultural research, not generic fantasy tropes.

### The Insight

When art, audio, and narrative are treated as "polish" (applied last), they feel like polish — decorative, detachable, forgettable. When they're treated as core systems (designed and iterated alongside gameplay), they become inseparable from the experience.

**Supergiant's rule:** Every discipline is involved from production start, not just pre-production. There is no "art pass" or "audio pass" — there is continuous integration of all disciplines.

### Validation for FFS

Our Knowledge Base Part 1 explicitly states: "Audio and animation aren't polish — they're core systems." But our practice may not match. Greedo (Sound Designer) was added later in the squad's evolution. Do we involve audio from Sprint 0, or does it come in after gameplay is established?

**Gap identified:** Formalize "all disciplines from Sprint 0" as a process requirement, not just a principle.

---

## 6. The Five-Minute Hook

**Pattern:** If the player isn't having fun in the first 5 minutes, nothing else matters.

### Evidence

- **Balatro:** The core loop (play poker hands, modify them with Jokers) is understandable in 30 seconds and compelling in 2 minutes. The publisher's marketing strategy was built around this: "Get it in streamers' hands. The game sells itself in 60 seconds of gameplay."
- **Lethal Company:** Group fun is immediate. Drop in, explore, scream, laugh. Zero tutorial. Zero prerequisite knowledge.
- **Palworld:** "Pokémon with guns" is a concept that sells itself in a single sentence. The hook is the premise, not the depth.
- **Hollow Knight:** The first area teaches movement, jumping, and combat through level design alone — no text tutorials, no HUD callouts. Within 5 minutes, you *feel* the game's weight and rhythm.

### The Insight

The 2024-2025 indie hits share a brutal truth: **players decide in the first 5 minutes whether to continue.** In the age of streaming and TikTok, games must be watchable, shareable, and immediately comprehensible.

This doesn't mean games must be simple. It means the core feeling must be accessible fast. Depth can layer on over hours — but the hook lands in minutes.

### Validation for FFS

Our Principle #1 ("Player Hands First") and our company name ("First Frame Studios") both encode this. We're philosophically aligned. The question is execution: do we test our first 5 minutes as rigorously as our late-game systems?

**Action:** Institute a "Five-Minute Test" — every build is evaluated by someone who has never played it, and their experience in the first 5 minutes is documented.

---

## 7. Designing for Streamability

**Pattern:** The most successful 2024-2025 games were designed — consciously or unconsciously — to be entertaining to *watch*, not just play.

### Evidence

- **Balatro:** Publisher Playstack's marketing strategy bypassed traditional trailers entirely. They sent keys to mid-tier streamers first. Watching someone's reaction to a perfect Joker combo was more compelling than any produced trailer.
- **Lethal Company:** Became a viral sensation through group streaming. The emergent humor of co-op horror (screaming, betrayal, unexpected deaths) made it endlessly watchable.
- **Palworld:** Meme-ready concept + visual absurdity = organic social media virality.

### The Insight

"Streamability" is not a marketing gimmick. It's a design consideration. Games that produce unexpected, emotional, shareable moments are inherently more marketable in the social media age. This means:
1. Emergent situations (not scripted spectacles) create authentic reactions.
2. Emotional peaks (triumph, surprise, horror, laughter) are more watchable than steady competence.
3. Visual clarity (viewers must understand what's happening) is a design constraint, not just an accessibility feature.

### Relevance to FFS

We haven't discussed streamability as a design dimension. For a beat 'em up, "spectacle combat" (big hits, screen shake, combo chains, comedic moments) is inherently streamable — but only if the pacing creates peaks and valleys, not a flat line of constant action.

**New consideration:** Add "Is this moment shareable/watchable?" as a design lens for key mechanics.

---

## 8. Developer Joy and Sustainable Pace

**Pattern:** Studios that burn out their teams ship worse games. Studios where developers are genuinely excited ship better ones.

### Evidence

- **Larian Studios:** Swen Vincke declined to make BG3 DLC or Baldur's Gate 4 because "our hearts weren't in it anymore." They moved to a new project where they found "developer joy" again. This is a studio that walked away from guaranteed revenue to protect creative excitement.
- **Balatro:** LocalThunk was open about the mental and physical health costs of solo development. Despite commercial success, he documented the stress, burnout, and anxiety of the process.
- **Supergiant Games:** Known for maintaining a sustainable work culture. No crunch reports. Team members have been at the studio for 10+ years — unusual longevity in game development.
- **155-postmortem meta-analysis:** "Team morale" and "team communication" were among the top 5 factors in successful projects. Morale dips early in development (as seen in Diablo II's postmortem) correlate with later quality problems.

### The Insight

"Developer joy" is not soft. It is a *leading indicator of game quality*. Excited developers take creative risks. Burned-out developers take shortcuts. Vincke's decision to abandon the most commercially safe sequel in gaming history (BG4) because the team wasn't excited is the most radical validation of this principle in the industry.

### Relevance to FFS

We don't have a formal mechanism for measuring team morale or creative excitement. Our retrospective framework scores principles, but doesn't explicitly track whether the team is *enjoying the work*.

**Gap identified:** Add a "developer joy" check to retrospectives. If the team isn't excited about what they're building, that's a design signal, not a morale problem.

---

## 9. The Power of Constraints

**Pattern:** The most distinctive games emerge from studios that embraced their limitations rather than fighting them.

### Evidence

- **Team Cherry:** Unity + 2D + 3 people → forced them into a hand-drawn, interconnected world with no procedural generation. The constraint produced Hollow Knight's iconic art style and meticulous level design.
- **ConcernedApe:** Solo dev + pixel art + XNA framework → forced deep system integration. Every mechanic connects because one person built everything. The constraint produced Stardew Valley's legendary cohesion.
- **Sandfall Interactive:** Sub-$10M budget → forced smart outsourcing and lean team structure. The constraint produced the hybrid production model that other studios now cite as a template.
- **FromSoftware (early):** Limited technology → forced environmental storytelling over cutscenes. The constraint produced the most distinctive narrative approach in modern gaming.

### Validation for FFS

Our Principle #11 ("Constraints Are Creative Fuel") is one of our strongest. firstPunch's Canvas 2D constraints directly shaped our visual identity and procedural audio approach. This research confirms we're on the right track.

**Reinforcement:** This principle is not just correct — it's the single most common trait of studios that punch above their weight.

---

## 10. Research as Competitive Advantage

**Pattern:** Studios that study their genre before building outperform those that design from instinct alone.

### Evidence

- **Supergiant Games:** Each new game explores a new genre. Before Hades, they studied roguelikes extensively. Before Pyre, they studied party-based RPGs and sports games. The research isn't casual — it's structured play and analysis of reference titles.
- **FromSoftware:** Miyazaki's designs draw explicitly from King's Field (FromSoft's own history), Ghosts and Goblins (difficulty philosophy), and Castlevania (world structure). He has articulated exactly which predecessors influenced which design decisions.
- **Sandfall Interactive:** Studied Belle Époque art, French cultural history, and the turn-based RPG genre before writing a line of code. The cultural research is why Expedition 33 doesn't look like "another JRPG."

### Validation for FFS

Our Principle #2 ("Research Before Reinvention") is one of our founding beliefs. Our beat 'em up research document analyzed 9 landmark titles. This research confirms that the best studios in the world do exactly what we do.

**Reinforcement:** We're aligned with industry best practice. The opportunity is to deepen the rigor: structured play sessions with documented findings, not just "play these games and discuss."

---

## 11. Cutting Features Is a Skill

**Pattern:** Great studios cut ruthlessly. Average studios ship bloated.

### Evidence

- **Valve:** Famously cuts large chunks of content that don't meet their gameplay bar, even late in development. Half-Life 2 had entire levels and weapons cut after extensive playtesting.
- **Nintendo:** Relentless internal playtesting. Features that aren't "fun" are delayed or cut without sentiment. Shigeru Miyamoto's "upending the tea table" (ちゃぶ台返し) — completely rethinking a project late in development — is legendary.
- **Sid Meier:** "Rapid prototyping + iterative cutting." Features that don't work are removed quickly, before they accumulate cost.
- **155-postmortem meta-analysis:** "Scope creep" was the #1 most cited failure cause. "Willingness to cut features early" was among the top success factors.
- **ConcernedApe:** Despite 4.5 years of solo development, Stardew Valley shipped as a focused farming RPG — not the sprawling "everything simulator" it could have become.

### The Insight

Feature triage frameworks used by successful studios:
1. **Core loop test:** Does this feature strengthen the core gameplay loop? If not, it's a candidate for cutting.
2. **Player impact test:** Will a first-time player notice if this feature is missing? If not, cut it.
3. **Cost-to-joy ratio:** How much development time does this feature require vs. how much player joy does it produce?
4. **Coherence test:** Does this feature feel like it belongs in *this* game, or could it be in any game?

### Validation for FFS

Our backlog analysis found 13 items that had already shipped but weren't pruned. We identified 14 items as "Future/Migration." We're learning to cut — but we don't have a formal feature triage framework.

**Gap identified:** Create a feature triage protocol using the 4 tests above.

---

## 12. Early Access and Community as Co-Designers

**Pattern:** The most successful recent games used early access or community feedback as a core design tool, not just a marketing strategy.

### Evidence

- **Hades (Supergiant):** 2 years of Early Access. The narrative structure, weapon balance, and character relationships were all refined through player feedback cycles.
- **Baldur's Gate 3 (Larian):** Early Access shaped act structure, companion behavior, romance options, and combat mechanics. Player data directly influenced design decisions.
- **Lethal Company:** Rapid early access iteration. Developer responded to community bugs and feature requests at a pace that built fierce loyalty.
- **Hollow Knight:** Free content updates post-launch (Grimm Troupe, Godmaster, etc.) built on community enthusiasm and feedback.

### The Insight

Early Access is not "releasing an unfinished game." It's a design methodology:
1. Ship the core loop first. Let players validate it.
2. Layer content and systems based on what players actually enjoy.
3. Build community ownership — players who contribute feedback become evangelists.
4. Reduce launch risk by validating market fit before "1.0."

### Relevance to FFS

firstPunch is browser-based — inherently easy to share for playtesting. We could adopt an informal "early access" approach: structured external playtests with documented feedback cycles.

---

## 13. AI as Force Multiplier (2024-2026)

**Pattern:** AI tools are not replacing developers — they're amplifying what small teams can do.

### Evidence (2024-2025 landscape)

| Tool Category | Examples | Impact |
|---------------|----------|--------|
| Code generation | GitHub Copilot, Cursor | 30-40% faster for routine code tasks |
| Art/asset creation | Midjourney, Stable Diffusion, Meshy | Rapid concept art, texture generation, 3D model drafts |
| Procedural content | Unity ML-Agents, custom generators | Entire worlds with biomes, layouts, balanced encounters |
| Writing/narrative | ChatGPT, Inklewriter | Draft dialogues, quest structures, backstories |
| QA/testing | AI-powered QA bots | Automated regression testing, balance detection |

### The Insight

AI doesn't replace the vision holder — it amplifies them. An artist using AI to generate 50 concept variations in an hour, then hand-selecting and refining the best one, produces more distinctive work than either the AI or the artist alone. The key discipline: **AI generates options. Humans make choices.**

The risk: AI-generated content can feel generic if not filtered through a strong creative vision. The studios that use AI best are those with the strongest taste — they use AI to explore faster, not to replace judgment.

### Relevance to FFS

We should explore AI tools for:
1. **Concept art iteration** — generate visual options for characters, environments, and UI
2. **Procedural SFX variation** — AI-generated sound variants for hit impacts, environmental ambience
3. **Playtesting analysis** — automated analysis of playtest sessions for balance insights
4. **Boilerplate code generation** — routine systems, utility functions, test scaffolding

We should NOT use AI for: creative direction, narrative voice, game feel tuning, or any decision that defines our identity.

---

## 14. Studio Principles as Management Infrastructure

**Pattern:** The most resilient studios have written, explicit principles that guide decision-making — not just culture fit.

### Evidence

- **Jesse Schell (GDC 2025, "Game Studio Principles: A Case Study"):** After 20+ years leading Schell Games (zero layoffs, long team tenure), Schell shared his studio's 18 guiding principles. Key insights:
  - Principles must be **authentic** — reflecting real beliefs, not corporate jargon
  - Principles serve as tools for **hard decisions, coaching, hiring, conflict resolution, and onboarding**
  - Barriers to stating principles (pride, cynicism, fear of sounding "corny") must be overcome with **bravery and sincerity**
  - Every team member should have both a **project lead** (delivery) and a **discipline lead** (growth) — matrix management
  - Information flows must be **designed, not accidental** — including emotional information, not just facts

- **Schell's Management Model:** Producer (deadlines/delivery) + Director (creative vision) = "two parents" per project. This ensures operational and creative needs are both served.

### Validation for FFS

We already have 12 strong principles. Schell's GDC talk validates our approach but adds nuances we lack:
1. **Matrix management** (project lead + discipline lead per person) — we have domain ownership but not dual reporting
2. **Affective hubs** (people who facilitate emotional communication) — we track process but not team feelings
3. **Principles as hiring tools** — we don't yet use our principles explicitly in onboarding/hiring decisions

**Gaps identified:** Dual-lead structure, emotional information flow, principles-driven hiring.

---

## 15. Postmortem Discipline

**Pattern:** Studios that run honest postmortems after every project compound their learning. Studios that don't repeat mistakes.

### Evidence

- **155-postmortem meta-analysis (academic study of Gamasutra postmortems):**
  - Top "went right" factors: good team communication, strong leadership, clear vision, testing, willingness to cut features
  - Top "went wrong" factors: scope creep, poor scheduling, unproven technology, inadequate playtesting, poor team communication
  - The same mistakes appear across 20+ years of postmortems — studios that don't read past postmortems repeat the same errors

- **Diablo II postmortem:** Team morale crashed early ("didn't want to make another Diablo"). The project only recovered when the team reignited passion through creative breakthroughs mid-development. Lesson: early buy-in is not optional.

- **Structure that works:** "5 things that went right / 5 things that went wrong" + actionable lessons for the next project. Brutal honesty over sugar-coating.

### Validation for FFS

Our Principle #12 ("Every Project Teaches the Next") encodes this. We have decision logs and history files. But we haven't run a formal "5/5 postmortem" on firstPunch yet.

**Action:** Run a formal firstPunch postmortem before starting the next project.

---

## 16. Essential Reading for Game Designers

### Books Referenced by Successful Designers

| Book | Author | Core Framework | Who Uses It |
|------|--------|---------------|-------------|
| **The Art of Game Design: A Book of Lenses** | Jesse Schell | 100+ "lenses" (questions/perspectives) for examining games holistically | University curricula, AAA and indie designers |
| **A Theory of Fun for Game Design** | Raph Koster | "Fun = Learning" — games are engaging when they teach new patterns | Will Wright (SimCity), university curricula |
| **Understanding Comics** | Scott McCloud | Visual storytelling theory — applicable to game narrative and UI | Referenced by Schell and Koster as cross-discipline inspiration |
| **Flow: The Psychology of Optimal Experience** | Mihaly Csikszentmihalyi | Flow state theory — the psychological basis for game engagement | Core framework for difficulty curve design |

### Key Frameworks

1. **Schell's Lenses:** Examine every design decision from multiple perspectives (psychology, aesthetics, technology, business, narrative, player experience). Prevents tunnel vision.

2. **Koster's Fun-as-Learning:** A game stops being fun when the player stops learning new patterns. Design implication: introduce new patterns at a pace that matches the player's mastery rate.

3. **Flow Theory (Csikszentmihalyi):** The optimal experience zone between boredom (too easy) and anxiety (too hard). Every game's difficulty curve is an attempt to keep the player in flow.

### Relevance to FFS

We should integrate Schell's Lenses into our design review process. Currently, we evaluate features against our 12 principles. Adding 3-5 key lenses (Player Experience, Surprise, Endogenous Value, Flow) would deepen our design critique.

---

## Sources

### Studios Researched
- Sandfall Interactive — playersforlife.com, notebookcheck.net, icy-veins.com, unrealengine.com
- Supergiant Games — gamedaily.biz, gamedeveloper.com, gamerant.com, gamespublisher.com
- Team Cherry — nintendo.com, starget-global.com, abc.net.au, theconversation.com
- ConcernedApe — gamedeveloper.com, gamedesigning.org, en.wikipedia.org
- Larian Studios — ign.com, shacknews.com, thegamer.com, eurogamer.net
- FromSoftware — gameinformer.com, notebookcheck.net, eurogamer.net, sabukaru.online

### Industry Analysis
- GDC Vault (gdcvault.com) — Jesse Schell GDC 2025 talk
- 155-postmortem meta-analysis — Microsoft Research / University of Waterloo
- Gamedeveloper.com — postmortem archive, Balatro marketing analysis
- Polygon, Insider Gaming — Balatro development diary, developer wellness

### Books
- Jesse Schell, *The Art of Game Design: A Book of Lenses*
- Raph Koster, *A Theory of Fun for Game Design*
- Mihaly Csikszentmihalyi, *Flow: The Psychology of Optimal Experience*
