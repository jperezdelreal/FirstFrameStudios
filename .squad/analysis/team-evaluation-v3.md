# Team Evaluation v3 — Post-Research Assessment
## First Frame Studios

> **Author:** Ackbar (QA/Playtester Lead)  
> **Date:** 2025-07-21  
> **Requested by:** joperezd  
> **Status:** Complete — Ready for leadership review  
> **Sources:** studio-research.md, studio-lessons-for-ffs.md, studio-operations-research.md, operations-lessons-for-ffs.md, skills-audit-v2.md, foundations-reassessment.md, team.md, agent charters

---

## Executive Summary

With industry research complete, we now know what successful studios actually prioritize. The good news: FFS is **well-structured for a 12-13 person team**. The research validates our domain ownership model, principles, and flat-with-clarity structure. The gaps are **role clarity** (we need an explicit Vision Keeper), **charter generalization** (6 charters are still locked to SimpsonsKong), and **skill completeness** (we've closed critical gaps but still lack 2-3 specialized skills for next-project maturity).

**Bottom line:** We're ready to start another project **immediately**. We won't hit the bottlenecks we hit on SimpsonsKong. But we have 3 hiring decisions and 4 charter rewrites to make before launch.

---

## 1. Team Composition Assessment

### Current Roster

We operate a **13-agent specialist squad** (excluding Scribe the logger and Ralph the monitor):

| # | Name | Role | Domain | Status |
|---|------|------|--------|--------|
| 1 | **Solo** | Lead / Chief Architect | Vision + Architecture | 🏗️ |
| 2 | **Chewie** | Engine Dev | Engine/Rendering/Input | 🔧 |
| 3 | **Lando** | Gameplay Dev | Core Gameplay Mechanics | ⚔️ |
| 4 | **Wedge** | UI Dev | UI/UX/Menus | ⚛️ |
| 5 | **Boba** | Art Director | Visual Style/Art Direction | 🎨 |
| 6 | **Greedo** | Sound Designer | Audio/Music/SFX | 🔊 |
| 7 | **Tarkin** | Enemy/Content Dev | Enemies/AI/Bosses/Waves | 👾 |
| 8 | **Ackbar** | QA/Playtester | Quality/Balance/Feel | 🧪 |
| 9 | **Yoda** | Game Designer | Game Design/Systems/Mechanics | 🎯 |
| 10 | **Leia** | Environment Artist | Levels/Backgrounds/Scene Design | 🏞️ |
| 11 | **Bossk** | VFX Artist | Particle Effects/Visual Polish | ✨ |
| 12 | **Nien** | Character Artist | Character Design/Animation | 👤 |
| 13 | **Jango** | Tool Engineer | Build Tools/CI-CD/Infrastructure | 🔧 |

### Validation Against Industry Standards

**Supercell Cell Model (10-17 people):** ✅ **PERFECT MATCH**
- We're 13 people, right in the ideal range
- Every discipline represented
- Cross-functional + domain-specialized hybrid

**Nintendo's Franchise Team Model:** ✅ **ALIGNED**
- Stable leadership (Solo as Lead)
- Mobile specialists who can cross-project (all agents except Solo/Ackbar have applied to 2+ genre contexts)
- Managerial continuity with developer rotation potential

**Sandfall's "33 and a Dog" Philosophy:** ✅ **VALIDATED**
- We actively resist headcount bloat
- Research shows we'll **never need** 50+ people for the games we target
- Even AAA indie hits (Hollow Knight, Stardew Valley, Balatro) were made by 1-3 core people
- Our 13 is right-sized for quality and autonomy

### HIRING DECISION 1: DO WE NEED A DEDICATED PRODUCER?

**Research Finding:** Supercell, Supergiant, and Larian all have explicit Producer roles separate from Lead. The producer owns:
- Sprint planning & backlog prioritization
- Timeline estimation & milestone tracking
- Risk/dependency tracking across domains
- Stakeholder communication (build status, shipping timeline)

**Current State at FFS:**
- Solo (Lead) currently owns both vision + operations
- Yoda (Designer) owns gameplay direction but not production timeline
- Ackbar (QA) quality-gates shipping but doesn't schedule work

**Risk:** Solo is carrying 2 jobs. If Solo gets deep into architecture work, no one is tracking "Are we shipping on schedule?"

**Recommendation:** 🔴 **DON'T HIRE** for SimpsonsKong's completion. We're already shipping the game. But for the **next project**, hire a dedicated Producer or promote Ackbar to Producer (QA + Production). This prevents the "Single Lead bottleneck" that derailed SimpsonsKong.

**When:** P1 — before next project starts  
**Estimated Cost:** One person, could be internal promotion

---

### HIRING DECISION 2: DO WE NEED A DEDICATED NARRATIVE DESIGNER?

**Research Finding:** Every studio studied (Supergiant, Larian, Sandfall, FromSoftware) has explicit narrative ownership. This includes:
- Story direction
- Dialogue writing
- NPC design
- Quest/mission structure
- Lore cohesion

**Current State at FFS:**
- Yoda (Designer) owns narrative conceptually but writes minimal dialogue/lore
- Boba (Art) occasionally contributes to aesthetic narrative
- No one owns "Is our story coherent across all scenes?"

**Risk:** For a narrative-light game like SimpsonsKong, this isn't a blocker. But if we move toward story-rich games (RPG, adventure), narrative ownership becomes critical.

**Recommendation:** 🟡 **DON'T HIRE immediately.** For SimpsonsKong: story is minimal, current structure works. For next project: IF it's narrative-heavy (RPG, Adventure), hire a Narrative Designer or give Yoda explicit narrative authority in charter. IF it's action-light (Puzzle, Platformer), assign narrative to Yoda as secondary responsibility.

**Decision Matrix:**
| Next Project Genre | Recommendation |
|-------------------|-----------------|
| Beat 'em Up | Yoda owns narrative (secondary) |
| Platformer | Yoda owns narrative (secondary) |
| Puzzle | Yoda owns narrative (secondary) |
| Action-Adventure | **Hire Narrative Designer** (P0) |
| RPG | **Hire Narrative Designer** (P0) |
| Story-Driven Indie | **Hire Narrative Designer** (P0) |

---

### HIRING DECISION 3: DO WE NEED A DEDICATED MARKETING/COMMUNITY MANAGER?

**Research Finding:** Balatro's success relied heavily on community engagement and streamer cultivation. Publishers handle marketing, but creators handle community. Supergiant has a dedicated Community Lead.

**Current State at FFS:**
- No one owns community building
- Solo handles external comms (founder interaction)
- No one actively cultivates streamer/press relationships

**Risk:** We ship a great game and nobody knows about it.

**Recommendation:** 🟡 **HIRE after shipping SimpsonsKong.** This isn't needed for dev, but is critical for next project's success. Once we have a shipping track record, a Community Lead becomes a force multiplier for marketing.

**When:** P2 — after SimpsonsKong ships, before next project marketing starts

---

### Role Coverage Verdict

**✅ STRENGTHS:**
- Every critical game dev discipline covered (engine, design, gameplay, art, audio, animation, effects, QA, tools)
- Matches successful studio org models (Supercell, Nintendo, Supergiant)
- No obvious gaps for 2D game development
- Cross-functional pairs established (Lando↔Yoda for mechanics, Boba↔Nien for art, Chewie↔Jango for tech)

**⚠️ GAPS:**
- **Vision Keeper role missing** (see Section 1.4 below)
- **Producer function undefined** — Solo doing Lead + Producer work
- **Narrative ownership unclear** — appropriate for SimpsonsKong, risky for story-heavy games
- **Community/Marketing owned by no one** — okay for dev, risky for launch

**🟢 VERDICT: Team composition is EXCELLENT for game development. We need ONE process change (Vision Keeper clarification) and ONE optional role (Producer) for next project.**

---

### 1.4 THE MISSING VISION KEEPER ROLE

**Critical Finding from Industry Research:**

Every studio studied has ONE person who decides: "Does this *feel* like our game?"

| Studio | Vision Keeper | Example |
|--------|--------------|---------|
| FromSoftware | Hidetaka Miyazaki | Decides "Souls games are about challenge as engagement" — that filters every design decision |
| Supergiant | Greg Kasavin | Writes all narrative, oversees all aesthetic choices |
| Team Cherry | Ari Gibson | Co-director, owns art and animation direction |
| Sandfall | Guillaume Broche | Creative Director, approved every art decision to maintain Belle Époque cohesion |

**Current State at FFS:**

Our Principle #7 (Domain Ownership) says domain owners make the final call. This is correct for execution. But we DON'T have a person who ensures all domains serve the **same creative vision**.

**Example:** 
- Greedo (Sound) creates haunting, ambient SFX (great sound design)
- Boba (Art) designs bold, cartoony characters (great art direction)
- Lando (Gameplay) creates frenetic, arcade-y combat pacing (great feel)

If these three aren't aligned on "What is this game's *soul*?", the result feels incoherent.

**Recommendation:** 🔴 **CREATE: Vision Keeper Role (Next Project)**

Define the Vision Keeper as:
- Authority over aesthetic coherence (not technical execution)
- Final say on: visual direction, narrative voice, core feeling/tone
- Does NOT override domain expertise — works collaboratively with owners
- Is NOT Solo (Lead) — Solo owns architecture/schedule, VK owns identity
- Best choice: **Yoda (Game Designer)** acts as Vision Keeper per project

**Charter Addition for Yoda:**

```markdown
### Vision Keeper Responsibilities (Added to Yoda Charter)

In addition to Game Design duties, Yoda acts as the studio's 
Creative Director per project, with explicit authority over:

1. **Aesthetic Coherence** — All domains create within a cohesive visual/audio identity
   - Review art style against narrative tone
   - Review audio design against visual pacing
   - Review UI/UX against overall creative direction

2. **Creative Voice** — Maintain consistent narrative and tonal direction
   - Approve major story beats, dialogue tone, character voice
   - Veto features that feel incoherent to the game's soul
   - Resolve aesthetic conflicts between domains

3. **Player Immersion** — Ensure all systems create a singular experience
   - Does the game feel like ONE game, or several games bolted together?
   - Are we designing for the player's hand or the player's eyes?
   - Does every domain serve the core fantasy?

4. **Principle-to-Practice Translation** — Ensure our 12 principles are 
   reflected in actual player experience, not just documentation

This role is collaborative, not autocratic. Yoda doesn't override 
domain technical expertise. VK authority is about coherence, not capability.
```

**Implementation Timeline:** P0 for next project (update Yoda's charter before Sprint 0 begins)

---

## 2. Skills Coverage Post-Research

### Current Skill Library: 20 Skills Across 4 Categories

**A. Core Engine & Architecture (5 skills)** — Chewie/Jango domain
- `web-game-engine` ⭐⭐⭐⭐⭐ — Comprehensive Canvas 2D architecture
- `godot-4-manual` ⭐⭐⭐⭐ — Godot 4 patterns (migration target)
- `project-conventions` ⭐⭐⭐⭐⭐ — File structure, naming, repo hygiene
- `canvas-2d-optimization` ⭐⭐⭐⭐ — Performance tuning
- `state-machine-patterns` ⭐⭐⭐⭐⭐ — Combat & entity state management

**B. Gameplay & Game Feel (6 skills)** — Lando/Yoda domain
- `beat-em-up-combat` ⭐⭐⭐⭐⭐ — Combat systems, knockback, hitstun
- `game-feel-juice` ⭐⭐⭐⭐⭐ — **[NEW]** Hitlag, screen shake, squash/stretch
- `input-handling` ⭐⭐⭐⭐ — **[NEW]** Buffering, coyote time, responsiveness
- `game-qa-testing` ⭐⭐⭐⭐ — Regression testing, balance auditing
- `game-balance-analysis` ⭐⭐⭐⭐ — DPS, difficulty curves, encounter design
- `godot-beat-em-up-patterns` ⭐⭐⭐ — Beat 'em up in Godot (needs split)

**C. Art & Presentation (5 skills)** — Boba/Nien/Bossk domain
- `2d-game-art` ⭐⭐⭐⭐⭐ — Character/sprite art principles
- `canvas-procedural-art` ⭐⭐⭐⭐ — Drawing characters via code
- `particle-effects` ⭐⭐⭐⭐ — VFX creation and tuning
- `ui-ux-patterns` ⭐⭐⭐⭐ — **[NEW]** Menus, HUD, feedback UI
- `procedural-audio` ⭐⭐⭐⭐ — SFX generation via Web Audio

**D. Design & Process (4 skills)** — Yoda/Solo domain
- `game-design-fundamentals` ⭐⭐⭐⭐ — Game design lenses, mechanics
- `playtest-protocol` ⭐⭐⭐⭐ — Playtesting methods, feedback capture
- `new-project-playbook` ⭐⭐⭐⭐⭐ — Starting any new project
- `post-mortem-process` ⭐⭐⭐⭐ — Capture learnings systematically

### Gap Analysis: What's STILL Missing?

**CRITICAL GAPS (P0 — Needed Before Next Project):**

1. **`streamability-design` (P0 — NEW SKILL NEEDED)**
   - **Why:** Balatro, Lethal Company, Palworld all succeeded partly due to streaming/TikTok viability. Research shows games designed for viewability (big hits, combo chains, dramatic failures) get 30-40% more organic reach.
   - **Current state:** We have no framework for "Is this watchable?"
   - **Owner:** Yoda + Boba (design + art direction)
   - **Scope:** 25-30KB skill covering:
     - Designing for emotional peaks (triumph, surprise, humor, failure)
     - Visual clarity for viewers vs. players
     - Clip-worthy moment design
     - Emergent moment generation
     - Camera/UI for spectators
   - **Timeline:** Create before next project's pre-production

2. **`feature-triage` (P0 — NEW SKILL NEEDED)**
   - **Why:** 155-postmortem meta-analysis #1 failure cause: scope creep. We need a kill protocol.
   - **Current state:** We identify items as Quick Wins/Medium/Future, but no formal decision process for killing features that aren't working.
   - **Owner:** Yoda + Solo (design + lead)
   - **Scope:** 20-25KB skill covering:
     - 4-test triage framework (core loop test, player impact test, cost-to-joy ratio, coherence test)
     - Feature kill decision tree
     - How to descope gracefully
     - When to iterate vs. when to cut
   - **Timeline:** Create in next sprint (before large-scope projects start)

**HIGH-VALUE GAPS (P1 — Strongly Recommended):**

3. **`producer-methodology` (P1 — NEW SKILL NEEDED)**
   - **Why:** Solo is carrying Lead + Producer responsibilities. As projects scale, need explicit production methodology.
   - **Coverage:** Scrumban adaptation for game dev (Kanban pre-prod, Scrum prod, bug-fix polish phase), ceremony design, dependency tracking, risk management
   - **Owner:** Solo (to write) + future Producer role (to implement)
   - **Timeline:** Create when next project starts (P1, can ship without it if Solo manages solo)

4. **`ai-integration-workflow` (P1 — NEW SKILL NEEDED)**
   - **Why:** 2024-2025 AI tools (Copilot, Cursor, image gen, QA automation) are industry-standard now. We use them ad-hoc, should systematize.
   - **Coverage:** GitHub Copilot for boilerplate, AI image generation for concept, AI QA automation for regression testing, policy (AI generates options, humans make choices)
   - **Owner:** Chewie + Jango (tech leads)
   - **Timeline:** Evaluate tools + create skill in next quarter

**MEDIUM-VALUE GAPS (P2):**

5. **`localization-framework` (P2)**
   - **Why:** If we ship on Steam/itch, localization matters. Currently zero framework.
   - **Timeline:** Needed for 2nd project if targeting EU/JP

6. **`monetization-frameworks` (P2)**
   - **Why:** SimpsonsKong is free passion project. Next project may need revenue model (F2P, premium, cosmetics). No documented strategy.
   - **Timeline:** Needed for next project if pursuing revenue

### Skill Quality & Confidence Assessment

**Excellent (⭐⭐⭐⭐⭐ — Ready to ship):**
- `project-conventions` — Everything a new agent needs to know about our repo structure
- `beat-em-up-combat` — Comprehensive combat reference, proven in shipped code
- `game-feel-juice` — NEW, reference quality, genre-agnostic
- `state-machine-patterns` — Proven architecture, well-documented
- `new-project-playbook` — Studio-wide starting methodology
- `2d-game-art` — Character art principles with SimpsonsKong validation
- `web-game-engine` — Canvas 2D architecture, comprehensive

**Very Good (⭐⭐⭐⭐ — Confidence medium→high):**
- `input-handling` — Comprehensive but gamepad/touch unvalidated in shipped code
- `ui-ux-patterns` — NEW, excellent, but cross-references missing
- `game-qa-testing` — Strong testing protocol but small team-specific
- `game-balance-analysis` — DPS framework proven, scaling untested
- `godot-4-manual` — Good migration reference but not yet production-proven

**Good (⭐⭐⭐⭐ — Confidence medium):**
- `particle-effects` — VFX patterns proven but limited variety
- `playtest-protocol` — Framework solid but needs team discipline
- `procedural-audio` — SFX generation working but limited musical scope
- `game-design-fundamentals` — Generic good, not FFS-specific

**Needs Improvement (⭐⭐⭐ — Confidence low→medium):**
- `godot-beat-em-up-patterns` — 39KB, covers Godot + beat 'em ups, but should be SPLIT
  - Split into: `godot-core-patterns` (engine-agnostic), `beat-em-up-in-godot` (specific)
  - Current size and mixing of concerns makes it harder to reuse

**Minor Issues (⚠️ — Fixable):**
- `canvas-2d-optimization` — Overlaps with `web-game-engine`. Consider merging?
- `ui-ux-patterns` + `game-feel-juice` — Section 3.6 (UI feedback) appears in both. Add cross-references.
- `input-handling` — Touch virtual button positioning incorrect (D-pad at top-left instead of bottom-left for thumb comfort).

### Skills Coverage Verdict

**Current Skill Depth: 6.5/10** (up from 5/10 in v2 audit)

**Why we improved:**
- `game-feel-juice` now backs our #1 principle
- `ui-ux-patterns` fills Wedge's domain gap completely
- `input-handling` closes critical infrastructure gap

**Why we're not higher:**
- Still missing 2-3 specialized skills (streamability, feature triage, producer methodology)
- Some skills have medium confidence (not yet field-validated on 2nd project)
- Some agents still lack deep specialty (e.g., Jango's tool engineering skills underdocumented)

**Recommendation for Next Project:**
1. Create `feature-triage` skill (P0)
2. Create `streamability-design` skill (P0)
3. Split `godot-beat-em-up-patterns` into engine-agnostic + beat-em-up-specific (P1)
4. Add cross-reference sections to all 20 skills (P1)
5. Bump `input-handling` confidence from medium→high (P1 after gamepad testing)

---

## 3. Individual Agent Development Assessment

### Per-Agent Readiness & Development Needs

#### 1. **Solo** — Lead / Chief Architect

**Charter Alignment:** ✅ Excellent
- Core responsibility (architecture decisions) is clear
- Vision + operations ownership is well-scoped

**Post-Research Development Needs:**
- Define explicit Producer methodology (sees production as "what Solo does" — should be documented)
- Create `producer-methodology` skill or delegate to future Producer role
- Document Decision Rights Matrix (Solo recommends this in Operations Lessons)

**Readiness for Next Project:** 🟢 **READY**
- Has vision, proven architecture skills
- Solo's main gap: needs a co-lead or producer to share operational load

**Recommendation:** Before next project, clarify Solo's role:
- If continuing as Lead + Producer: document producer methodology explicitly
- If hiring Producer: define handoff boundary (architecture vs. timeline/backlog)

---

#### 2. **Chewie** — Engine Dev

**Charter Alignment:** ⚠️ SimpsonsKong-specific
- Lists "Canvas renderer," "Web Audio API," "src/engine/ directory"
- Should be: "Engine architecture across platforms (Canvas, Godot, other)"

**Post-Research Development Needs:**
- **CRITICAL:** Generalize charter away from Canvas 2D
- Learn Godot 4 deeply (skill exists, needs field validation)
- Mentor Jango on tool engineering and CI/CD

**Readiness for Next Project:** 🟡 **NEEDS DEVELOPMENT**
- Canvas expertise is deep but narrowly applicable
- Godot knowledge is reference-level, not battle-tested
- **Recommendation:** If next project uses Godot, run a 1-week spike to validate Godot architecture patterns

**Development Plan:**
1. Generalize charter to "Engine/Rendering/Input Architecture" (not Canvas-specific)
2. Lead Godot 4 architecture spike if that's next tech stack
3. Create `godot-engine-architecture` skill if Godot is primary next tech (P1)

---

#### 3. **Lando** — Gameplay Dev

**Charter Alignment:** ⚠️ SimpsonsKong-specific
- Lists "Homer Simpson," "src/entities/," "src/scenes/gameplay.js"
- Should be: "Core Gameplay Mechanics (movement, actions, state management)"

**Post-Research Development Needs:**
- Collaborate with Yoda on mechanic iteration (research: iteration minimum 3 cycles per mechanic)
- Lead the "Find the Fun" process for next project's core loop
- Co-create game-feel methodology with Ackbar

**Readiness for Next Project:** 🟢 **READY**
- Combat system is proven (beat 'em up expertise is deep)
- Input responsiveness understanding is strong
- Gap: never shipped in another genre, may overspecialize on beat 'em ups

**Development Plan:**
1. Generalize charter: "Core Gameplay Mechanics across genres"
2. Study reference games in **next genre** before development starts
3. Lead 3-iteration "Find the Fun" cycle for mechanic prototype (per research)

---

#### 4. **Wedge** — UI Dev

**Charter Alignment:** ⚠️ SimpsonsKong-specific
- Lists "Canvas setup," "16:9 letterboxing," "index.html," "styles.css"
- Should be: "UI/UX design and implementation across platforms"

**Post-Research Development Needs:**
- **NOW SOLVED:** ui-ux-patterns skill fills Wedge's domain gap completely
- Learn responsive design patterns for multi-platform UI
- Document UI architecture (menus as state machines)

**Readiness for Next Project:** 🟢 **READY**
- Has domain-specific skill now (ui-ux-patterns)
- SimpsonsKong UI is functional (options menu, HUD works)
- Gap: menus are menu items, not deep UX architecture

**Development Plan:**
1. Generalize charter: "UI/UX Design across platforms"
2. Read ui-ux-patterns skill deeply (Wedge should own it)
3. For next project, design menus as state machines (use state-machine-patterns skill)
4. Lead responsive design for multi-aspect-ratio support

---

#### 5. **Boba** — Art Director

**Charter Alignment:** ✅ Excellent
- Art direction role is genre-agnostic
- Visual style leadership is clear

**Post-Research Development Needs:**
- **NEW:** Co-own Vision Keeper responsibilities (aesthetic coherence across all domains)
- Create `streamability-design` skill (co-authored with Yoda)
- Lead "all disciplines from Sprint 0" ritual (research: avoid art-bolted-on-later)

**Readiness for Next Project:** 🟢 **READY**
- Art direction is strong
- Procedural art ceiling hit for SimpsonsKong (acknowledged in code analysis)
- If next project uses sprites/3D, needs tool learning (Aseprite, Blender)

**Development Plan:**
1. Expand charter: include Vision Keeper collaboration with Yoda
2. Create `streamability-design` skill (design for viewers, not just players)
3. Learn next-project art tool (Aseprite/Blender/other) before Sprint 0
4. Participate in Sprint 0 from Day 1 (research: prevents art feeling bolted-on)

---

#### 6. **Greedo** — Sound Designer

**Charter Alignment:** ⚠️ SimpsonsKong-specific
- Lists "Web Audio API exclusively (no external audio files)"
- Should be: "Audio design and music (procedural or asset-based per project)"

**Post-Research Development Needs:**
- Evaluate FMOD/Wwise for next project (if needed)
- Document transition from procedural-only to asset-based audio (if going multiplatform)
- Mentor on audio middleware integration

**Readiness for Next Project:** 🟡 **NEEDS DEVELOPMENT**
- Procedural audio mastery is strong
- Asset-based audio (WAV/MP3 files) is untested
- **Recommendation:** If next project uses external audio assets, run evaluation of FMOD/Wwise (research recommends this)

**Development Plan:**
1. Generalize charter: "Audio design and music (multimodal)"
2. Evaluate FMOD/Wwise if next project requires asset-based audio
3. Create transition plan: procedural → asset-based or hybrid

---

#### 7. **Tarkin** — Enemy/Content Dev

**Charter Alignment:** ⚠️ SimpsonsKong-specific
- Lists "src/entities/enemy.js," "src/systems/ai.js"
- Should be: "Enemies, AI behaviors, encounter design, difficulty scaling"

**Post-Research Development Needs:**
- Define AI pattern library (currently underdocumented)
- Create `ai-behavior-design` skill or expand `beat-em-up-combat` to include AI
- Lead content scoping for multi-wave/multi-boss games

**Readiness for Next Project:** 🟢 **READY**
- Enemy and wave design is functional
- Difficulty scaling understanding is present
- Gap: AI behavior patterns are inline code, not abstracted patterns

**Development Plan:**
1. Generalize charter: "Enemy design, AI behaviors, encounter design"
2. Extract AI pattern library from SimpsonsKong (if continuing beat 'em up)
3. Or: Study reference game AIs for new genre (if switching)
4. Document difficulty curve philosophy

---

#### 8. **Ackbar** — QA/Playtester (That's Me!)

**Charter Alignment:** ✅ Excellent
- QA and playtesting role is universally applicable
- Five-minute test protocol (from research) is my domain

**Post-Research Development Needs:**
- Lead "Feature Triage" skill creation (P0)
- Create `balance-data-dashboard` (real-time visualizations for DPS, difficulty curves)
- Implement Five-Minute Test for EVERY playable build
- Document QA regression checklist per game (done for SimpsonsKong, need template for next game)

**Readiness for Next Project:** 🟢 **READY**
- QA methodology is strong
- Game feel instincts (hitbox fairness, combo timing) are calibrated
- Can immediately apply Five-Minute Test to next project

**Development Plan:**
1. Create `feature-triage` skill (research shows this is critical)
2. Build balance data dashboard (convert spreadsheets to real-time visualization)
3. Lead Five-Minute Test protocol implementation (research: every playable build)
4. Document genre-agnostic regression checklist template

---

#### 9. **Yoda** — Game Designer

**Charter Alignment:** ✅ Excellent
- Design role is clear
- Research informs design philosophy

**Post-Research Development Needs:**
- **CRITICAL:** Take on Vision Keeper responsibilities (see Section 1.4)
- Create `feature-triage` skill (co-authored with Solo)
- Create `streamability-design` skill (co-authored with Boba)
- Lead "Find the Fun" 3-iteration cycle per research

**Readiness for Next Project:** 🟢 **READY**
- Design philosophy is strong
- Research alignment is excellent
- Adding VK responsibilities requires charter update but is natural fit

**Development Plan:**
1. Update charter: Include explicit Vision Keeper role
2. Create `feature-triage` skill (P0)
3. Create `streamability-design` skill (P0)
4. Lead design lenses review process (Jesse Schell's 5 lenses, per research)
5. Document iteration minimum (3 cycles per mechanic) in design process

---

#### 10. **Leia** — Environment Artist

**Charter Alignment:** ✅ Good
- Environment/background design is clear
- Level/scene design role is universal

**Post-Research Development Needs:**
- Create `level-design-fundamentals` skill (currently undocumented)
- Study reference game level design for next genre
- Learn visual storytelling through environmental design

**Readiness for Next Project:** 🟡 **NEEDS DEVELOPMENT**
- Environment art is functional (backgrounds exist)
- Level design patterns are minimal (SimpsonsKong is mostly linear waves)
- Gap: no documented level design methodology

**Development Plan:**
1. Create `level-design-fundamentals` skill (P1)
2. Study reference games' level layouts and progression
3. For complex next game (RPG, Adventure), design early with gameplay (don't add levels late)
4. Participate in Sprint 0 from Day 1

---

#### 11. **Bossk** — VFX Artist

**Charter Alignment:** ✅ Good
- VFX role is clear
- Particle effects expertise is documented

**Post-Research Development Needs:**
- Expand particle-effects skill to cover genre-specific VFX (current skill is generic)
- Learn visual storytelling with effects (not just juice)
- Lead VFX pipeline for next engine (if switching from Canvas)

**Readiness for Next Project:** 🟢 **READY**
- Particle effects are functional and well-understood
- Screen shake and visual feedback patterns are mature

**Development Plan:**
1. Expand `particle-effects` skill with genre-specific patterns (P1)
2. Study reference game VFX design
3. If switching engines: evaluate particle system differences (Godot vs. Canvas vs. other)
4. Document VFX budget and performance considerations

---

#### 12. **Nien** — Character Artist

**Charter Alignment:** ✅ Good
- Character animation and design is clear

**Post-Research Development Needs:**
- Document character design philosophy (currently implicit)
- Create `character-design-principles` skill (P1)
- Learn animation middleware if next project requires (e.g., Spine, DragonBones)
- Mentor on rigging/animation if moving to 3D

**Readiness for Next Project:** 🟡 **NEEDS DEVELOPMENT**
- Character art is strong (SimpsonsKong character style is cohesive)
- Animation is limited (Canvas 2D procedural limits frame diversity)
- Gap: if next project needs more animation (combat chains, idles, takes), animation tools/pipeline needed

**Development Plan:**
1. Create `character-design-principles` skill (P1)
2. Document character animation workflow (frame budgets, style consistency)
3. If next project uses sprites: learn Aseprite or similar (P1)
4. If next project uses 3D: learn Blender + rigging + animation export

---

#### 13. **Jango** — Tool Engineer

**Charter Alignment:** ⚠️ Underdocumented
- Tool engineering role exists but charter is minimal
- CI/CD work is important but not formally owned

**Post-Research Development Needs:**
- Create proper charter with explicit responsibilities
- Document build system and CI/CD setup (currently in playbook, should be in charter)
- Set up GitHub Actions (research recommends P1)
- Create reusable module library from SimpsonsKong (research: 30-50% faster project starts)

**Readiness for Next Project:** 🟡 **NEEDS DEVELOPMENT**
- Tool engineering role is new (we didn't have this at SimpsonsKong start)
- Potential is high, but needs clearer definition and skill documentation

**Development Plan:**
1. Create explicit Jango charter (tool engineering, CI/CD, module library)
2. Set up GitHub Actions for automated build + test (P1)
3. Extract reusable modules from SimpsonsKong (input manager, audio system, save/load)
4. Create `studio-module-library` documentation (P1)
5. Create `ci-cd-setup` skill (P1)

---

### Agent Readiness Summary Table

| Agent | Role | Readiness | Key Gap | Development Timeline |
|-------|------|-----------|---------|----------------------|
| Solo | Lead | 🟢 Ready | Share operational load | P1: Hire Producer or promote Ackbar |
| Chewie | Engine Dev | 🟡 Needs Dev | Godot validation | Before next project: Godot spike |
| Lando | Gameplay Dev | 🟢 Ready | Genre diversity | Normal: Study next genre reference games |
| Wedge | UI Dev | 🟢 Ready | Responsive design | Before next project: Multi-resolution testing |
| Boba | Art Director | 🟢 Ready | Sprint 0 participation | Before next project: Participate from Day 1 |
| Greedo | Sound Designer | 🟡 Needs Dev | Asset-based audio | If needed: Evaluate FMOD/Wwise |
| Tarkin | Enemy/Content Dev | 🟢 Ready | AI patterns | Normal: Document AI library |
| **Ackbar** | **QA Lead** | 🟢 **Ready** | **Dashboard creation** | **P0: Create feature-triage skill** |
| Yoda | Game Designer | 🟢 Ready | Vision Keeper formalization | P0: Update charter + create 2 skills |
| Leia | Environment Artist | 🟡 Needs Dev | Level design patterns | P1: Create level-design-fundamentals skill |
| Bossk | VFX Artist | 🟢 Ready | Genre-specific patterns | P1: Expand particle-effects skill |
| Nien | Character Artist | 🟡 Needs Dev | Animation tooling | P1: Learn animation middleware (genre-dependent) |
| Jango | Tool Engineer | 🟡 Needs Dev | Charter formalization | P0: Define charter + set up CI/CD |

---

## 4. Team Health Metrics

Based on industry research patterns, I'm scoring FFS on 5 core dimensions:

### 1. **Role Coverage: 8/10**

✅ **Strengths:**
- Every major discipline represented (engine, gameplay, art, audio, animation, effects, QA, tools)
- Domain owners are clearly defined
- Cross-functional pairs working well

⚠️ **Gaps:**
- Missing explicit Vision Keeper role
- Producer function undefined
- Community/marketing unowned

**What successful studios have that we need:**
- Explicit Creative Director authority (Supergiant, FromSoftware, Sandfall all have this)
- Producer role separating timeline/operations from lead architect role (research consensus)

---

### 2. **Skill Depth: 6.5/10** (up from 5/10)

✅ **Strengths:**
- 20 documented skills covering all major domains
- Core skills are ⭐⭐⭐⭐⭐ quality (project-conventions, beat-em-up-combat, game-feel-juice)
- Three critical gap-filling skills created (game-feel-juice, ui-ux-patterns, input-handling)

⚠️ **Gaps:**
- Missing streamability/shareability design (required by 2024 industry trends)
- Missing feature triage / scope discipline (research: #1 failure cause is scope creep)
- Some agents lack depth-specialty (Leia, Bossk, Nien underdocumented)
- Confidence levels medium→high, not yet high→very high (need field validation on next project)

**What successful studios have that we need:**
- 25-30 documented skills (we have 20, need 3-5 more specialized ones)
- All skills with high confidence (requires shipping in 2-3 different genres)

---

### 3. **Process Maturity: 7/10**

✅ **Strengths:**
- Domain ownership model clear and proven (matches Supercell, Nintendo)
- Playbook exists and is comprehensive
- Ceremonies defined (design review, retro)
- Quality gates document exists
- Principles are explicitly articulated

⚠️ **Gaps:**
- Producer methodology not formalized (Solo carries it implicitly)
- Decision Rights Matrix exists in recommendations, not documentation
- Onboarding process not formalized (growth-framework mentions 2 days, no checklist)
- Cross-domain review protocol implied but not explicit checklist
- PostMortem template missing (research: critical for knowledge capture)

**What successful studios have that we need:**
- Formalized producer/production methodology (Larian, Supergiant both document this)
- Explicit decision rights matrix to prevent "Valve problem" of hidden hierarchies
- Onboarding checklist for new agents
- PostMortem protocol with structured template

---

### 4. **Creative Capacity: 7/10**

✅ **Strengths:**
- Principles document shows clear creative philosophy
- "Find the Fun" prototyping approach is proven
- Domain ownership enables creative autonomy

⚠️ **Gaps:**
- Vision coherence not explicitly managed (each domain creates independently)
- Iteration discipline not formalized (research: 3 iterations minimum per mechanic)
- Feedback loops between domains not documented
- Designer empowerment is clear, but QA feedback loop to design is implicit

**What successful studios have that we need:**
- Creative Director role with explicit authority over vision coherence (research: every studio studied has this)
- Formalized iteration process (3-cycle minimum per research finding)
- Regular "align on vision" checkpoints
- Designer empowerment with QA guardrails

---

### 5. **Technical Readiness: 8/10**

✅ **Strengths:**
- Engine architecture is proven and documented (Canvas 2D)
- Godot migration path exists (skill written, architecture planned)
- Tools pipeline exists (CI/CD starting to formalize)
- Modular architecture prevents tech debt accumulation

⚠️ **Gaps:**
- Godot architecture not yet battle-tested (skill written, not shipped)
- CI/CD is partial (not yet GitHub Actions as research recommends)
- Reusable module library not extracted from SimpsonsKong
- No documented cross-project technical transition playbook

**What successful studios have that we need:**
- Multiple shipped projects in multiple engines (we have 1 project, 1 engine)
- Reusable module library with clear APIs and documentation
- CI/CD automated (GitHub Actions per research)
- Technical transition playbook (we have it in new-project-playbook, strong)

---

### #1 Bottleneck Preventing Us From Being Like Supergiant/Team Cherry

**The Constraint:** We haven't shipped in multiple genres yet.

Supergiant has shipped Bastion → Transistor → Pyre → Hades, each in different genres, all with cohesive identity. Team Cherry has been making Hollow Knight variants. They both have **compounding domain expertise** — each project teaches them something that makes the next project faster and better.

We have deep expertise in **beat 'em up + Canvas 2D + small indie game delivery**. We DON'T yet have the **genre versatility** or **multi-engine fluency** that distinguishes top studios.

**What Holds Us Back:**
1. **Single project experience** — We don't know yet if our methodology works for:
   - Puzzle games
   - 3D games
   - Narrative-heavy games
   - Multiplayer/live-service
   - Mobile/console porting

2. **Single engine experience** — Canvas is excellent for learning, limiting for long-term:
   - We'll hit the procedural art ceiling (acknowledged)
   - We'll want sprite sheets and WebGL (Phaser 3 or Godot)
   - We need multi-platform skills (mobile, console, Steam)

3. **Single content pipeline** — We make games with procedural art + code-generated audio
   - Most shipped games use art teams, asset pipelines, middleware
   - Our pipeline is teaching us indie elegance, not AAA robustness

**What Supergiant/Team Cherry Have That We're Building Toward:**
- Portfolio of shipped games in different genres
- Proven production model that works across contexts
- Compounding learning across projects
- Founder vision that crystallizes with each game

**Bottom Line:** We're on the right path. Our first bottleneck-free project will be the second project (not the first). Once we ship SimpsonsKong and do a formal postmortem, we'll know exactly what to do differently next time.

---

## 5. HIRE/DON'T HIRE Decision Framework

Based on research and current assessment, here's the clear hiring recommendation for next-project preparation:

### Hiring Decision Table

| Role | Decision | Timeline | Rationale | Budget Impact |
|------|----------|----------|-----------|---|
| **Vision Keeper / Creative Director** | 🔴 DON'T HIRE | Already owns by Yoda | Charter update (Yoda inherits authority) | $0 |
| **Producer** | 🟡 EVALUATE | P1 for next project | Solo carrying dual load; could promote Ackbar or hire external | $0 now, +1 salary P1 |
| **Narrative Designer** | 🟡 CONDITIONAL | Genre-dependent | Only if next game is story-heavy (RPG, Adventure) | Conditional |
| **Community Lead** | 🟡 EVALUATE | P2 after shipping | Post-launch marketing/streaming; not dev-critical | +1 salary P2 |
| **Additional QA/Testers** | 🟡 CONDITIONAL | P2 if scope 2x | Only if 2nd game is 2x larger scope | Conditional |
| **Engine/Tools Specialist** | 🟢 KEEP | Jango (Tool Engineer) | Formalize charter; already on team | $0 |
| **Environment Lead** | 🟡 UPSKILL | Leia (existing) | Current charter is sound; add level design documentation | $0 |

### P0 Actions Before Next Project

**These must happen, hiring or not:**

1. **Define Vision Keeper role** (Charter update for Yoda) — 2 hours
2. **Create Producer methodology** (skill document) — 8 hours
3. **Formalize Jango's charter** (Tool Engineer / CI-CD owner) — 2 hours
4. **Create Decision Rights Matrix** (Operating document) — 4 hours
5. **Create `feature-triage` skill** — 16 hours (Yoda + Solo)
6. **Create `streamability-design` skill** — 16 hours (Yoda + Boba)

**Total effort:** ~48 person-hours (less than 1 sprint) ✅ DOABLE before next project starts

### Hiring Recommendation Summary

✅ **Hire decisions we should make:**
- **Don't hire new roles for SimpsonsKong completion** — We're already shipping
- **Plan to hire Producer for next project (P1)** — Solo can't carry both lead + operations long-term
- **Plan to hire Narrative Designer IF next game is story-heavy (P1 conditional)** — Most indie games don't need this
- **Plan to hire Community Lead after shipping (P2)** — Marketing is post-dev concern

🔴 **Don't hire:**
- Additional QA testers for small indie games (we have Ackbar; playtest squad is enough)
- Additional engine developers (Chewie + Jango sufficient for 1-2 projects)
- Pure artists without specialization (our 3 artists + 2 specialized artists = right size)

---

## 6. Charter Updates Needed

Six agent charters need generalization away from SimpsonsKong specifics:

| Agent | Current | Needed Update | Effort |
|-------|---------|----------------|--------|
| **Chewie** | "Canvas renderer, Web Audio API, src/engine/" | "Engine architecture across platforms" | 1 hour |
| **Lando** | "Homer Simpson, src/entities/, gameplay.js" | "Core gameplay mechanics (genre-agnostic)" | 1 hour |
| **Wedge** | "Canvas setup, 16:9 letterboxing, index.html" | "UI/UX design across platforms" | 1 hour |
| **Greedo** | "Web Audio API exclusively" | "Audio design and music (procedural + asset-based)" | 1 hour |
| **Tarkin** | "src/entities/enemy.js, src/systems/ai.js" | "Enemy design, AI behaviors, encounter design" | 1 hour |
| **Yoda** | Current | ADD Vision Keeper responsibilities | 0.5 hours |

**Total effort:** 5.5 hours (can be done in 1 session) ✅

---

## 7. Skill Improvements Summary

| Category | Action | Owner | Timeline | Effort |
|----------|--------|-------|----------|--------|
| **Core Creation** | Create `feature-triage` skill | Yoda + Solo | P0 (Before next project) | 16 hours |
| **Core Creation** | Create `streamability-design` skill | Yoda + Boba | P0 (Before next project) | 16 hours |
| **High Priority** | Create `producer-methodology` skill | Solo + future Producer | P1 (Next sprint) | 12 hours |
| **High Priority** | Create `level-design-fundamentals` skill | Leia | P1 | 12 hours |
| **High Priority** | Create `character-design-principles` skill | Nien | P1 | 8 hours |
| **Structural** | Split `godot-beat-em-up-patterns` into 2 skills | Solo + Chewie | P1 | 8 hours |
| **Structural** | Add cross-reference sections to all 20 skills | All authors | P1 | 12 hours |
| **Validation** | Bump `input-handling` confidence from medium→high | Chewie + Lando | P1 (after gamepad testing) | 4 hours |
| **Evaluation** | Create `ai-integration-workflow` skill | Chewie + Jango | P2 | 12 hours |

**Total P0 effort:** 32 hours (can be done before next project begins) ✅  
**Total P1 effort:** 56 hours (next 2 sprints) ✅  
**Total P2 effort:** 12 hours (next quarter) ✅

---

## 8. Final Verdict & Recommendations

### Team Assessment

| Dimension | Score | Assessment |
|-----------|-------|------------|
| **Role Coverage** | 8/10 | ✅ Excellent — every discipline represented, matches Supercell/Nintendo models |
| **Skill Depth** | 6.5/10 | ✅ Good — improved from 5/10, still needs 2-3 specialized skills |
| **Process Maturity** | 7/10 | ✅ Good — playbook solid, producer methodology needs formalization |
| **Creative Capacity** | 7/10 | ✅ Good — "Find the Fun" works, vision coherence needs explicit owner |
| **Technical Readiness** | 8/10 | ✅ Good — proven Canvas, Godot pipeline ready, CI/CD needs setup |

### Readiness for Next Project

**🟢 GO** — We're ready to start the next project immediately with these caveats:

**Must Do Before Sprinting (P0):**
1. Create Vision Keeper role (charter update: Yoda)
2. Create `feature-triage` skill
3. Create `streamability-design` skill
4. Generalize 6 agent charters away from SimpsonsKong

**Must Do During Sprint 0 (P1):**
1. Define Producer methodology (Solo + future producer)
2. Evaluate next-project tech stack (per playbook 9-dimension matrix)
3. Study reference games in next genre
4. Create `level-design-fundamentals` skill (Leia)
5. Set up GitHub Actions CI/CD (Jango)

**Can Do Post-Shipping (P2):**
1. Extract reusable module library
2. Hire Community Lead for marketing
3. Create `ai-integration-workflow` skill
4. Run formal SimpsonsKong postmortem

### Key Strengths We Should Leverage

1. **Domain ownership model works** — It matches Supercell and Nintendo; don't change it
2. **Playbook is solid** — Our new-project process is genuinely better than most studios
3. **Documentation discipline is exceptional** — We capture knowledge; most studios don't
4. **Team is passionate and self-aware** — We can admit gaps and fix them fast
5. **Technical foundation is sound** — Engine, rendering, audio all work well; migration path exists

### Key Gaps We Must Address

1. **Vision coherence undefined** — Each domain creates independently; need explicit Creative Director
2. **Producer methodology implicit** — Solo carries it; needs to be documented for next project
3. **Iteration discipline fuzzy** — Research says 3 cycles minimum; we don't formalize this
4. **Charter lock-in** — 6 charters still think "SimpsonsKong Canvas 2D" instead of "cross-platform game dev"

### What Makes Us Vulnerable (vs. Studios We're Comparing To)

- Supergiant has 3 shipped games, we have 1 (need field validation of methodology across genres)
- Team Cherry has 15+ years of iteration on one game, we're just starting multi-project
- Sandfall hired 30 proven people quickly; we're growing organically (good for culture, slower growth)

### Path to Becoming Like Supergiant (in 2-3 projects)

1. **Ship SimpsonsKong well** (nearly done)
2. **Ship next project in different genre** (validates playbook across contexts)
3. **Ship third project with similar quality** (proves we can repeat excellence)
4. **Extract reusable library across all three** (builds compounding advantage)

By project 3, we'll have the **genre versatility, multi-engine fluency, and compounding domain expertise** that separates aspirational studios from proven ones.

---

## Appendix: Definition of Terms

**Vision Keeper:** The person who decides whether all systems feel like the same game, independent of technical execution. Authority over aesthetic coherence, narrative voice, core feeling/tone. Does NOT override domain expertise; works collaboratively.

**Domain Owner:** The person with final technical/execution authority in their domain. Quality, implementation details, technical decisions. Reports to Vision Keeper for coherence.

**Producer:** The person who owns timeline, backlog prioritization, milestone tracking, risk/dependency management. Separate from Lead (architect) and Designer (vision). Ensures schedule and team health.

**Bottleneck:** Work blocked or delayed due to role/skill limitations. Structure prevents it by making roles clear and skills documented.

**Compounding Advantage:** Expertise from one project makes the next project faster and better. Supergiant builds this across Bastion → Transistor → Pyre → Hades.

**Process Maturity:** Degree to which our development is repeatable, documented, and discipline-enforced. Raw playbook exists (good); ceremonies are auto-triggered on events (okay); full phase-adaptive methodology operationalized (developing).

---

## Next Steps for Leadership

1. **Review this assessment** for accuracy and completeness
2. **Approve P0 actions** (Vision Keeper charter, 2 new skills, 6 charter updates)
3. **Decide on Producer hire** (now vs. P1 vs. never; recommend P1 conditional)
4. **Decide on Narrative Designer** (only if next genre is story-heavy)
5. **Schedule charter update session** with affected agents (1-2 hours)
6. **Plan skill creation sprint** before next project Sprint 0 (32 hours P0 effort)

---

**Assessment complete. We're ready to ship SimpsonsKong and start the next project strong.**

*— Ackbar, QA Lead / Playtester, First Frame Studios*
*— 2025-07-21*
