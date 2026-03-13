# Holistic Foundations Re-Assessment — First Frame Studios

> Compressed from 29KB. Full: foundations-reassessment-archive.md

> **Author:** Solo (Lead / Chief Architect)
> **Date:** 2025-07-21
---

## 1. Document Consistency Check
### 1.1 Coherence Assessment
The six core documents tell a **largely coherent story**, and the coherence is genuinely impressive for a studio built incrementally. The narrative arc is:
### 1.2 Contradictions Found
| # | Location A | Location B | Contradiction | Severity |
| 1 | **company.md §6** says "12-specialist squad" | **team.md** lists 15 members (13 agents + Scribe + Ralph) | Headcount mismatch. Company.md was written before Scribe/Ralph and before Jango's addition. The public identity says 12; the operational roster says 15. | **Medium** |
| 2 | **company.md §6** lists departments with Scribe and Ralph in Operations | **team.md** has Ralph with no charter link (`—`) | Ralph is described in company.md as "Production & Pipeline Monitor" but has no charter, no history, and no operational existence. He's a ghost. | **High** |
| 3 | **quality-gates.md** header says "Applies to: All deliverables in Godot 4 projects, effective Sprint 0" | **growth-framework.md §1.2** says quality gates are "expressed as outcomes, not tool-specific checks" | The gates document is Godot-specific (GDScript style, export targets, `push_error()`, `preload()`), but growth-framework claims they're engine-agnostic. Both can't be true. The gates need an engine-agnostic base layer with Godot-specific additions. | **High** |
| 4 | **playbook §2.5** says minimum playable time budget is "3-4 sessions maximum" | **growth-framework §4.1** says the full new-genre protocol takes "~8 weeks" before production | These aren't contradictory exactly, but the playbook's Sprint 0 timeline (3-4 sessions) vs. the growth framework's 8-week pre-production creates confusion about what "starting" means. A team member could read either and get different expectations. | **Medium** |
---

## 2. Process Gaps
### 2.1 New Team Member Onboarding: Day 1 → Day N
**Status: PARTIALLY DOCUMENTED. No single onboarding path.**
| What Exists | Where | Quality |
| Reading list for new specialists | growth-framework §10.4 (5 documents in order) | Good — clear sequence |
| Principles as "read before writing code" | principles.md §How to Use | Good — explicit instruction |
| Charter per role | Each agent has one | Uneven — some are 3 lines, some are 45 lines |
| What Exists | Where | Quality |
| Phase retrospective process | playbook §3.2 (30-min session, skill extraction, history update) | Good |
---

## 3. Team Structure Gaps
### 3.1 Role Gaps (Roles We Need But Don't Have)
| Gap | Impact | When Needed | Recommendation |
| **No Release/Distribution Owner** | Nobody owns the process of getting a build to players. Jango owns build pipeline, but distribution (store pages, marketing assets, upload, pricing) is unassigned. | Before first public release | Assign to Jango (expand charter) or create Operations role. **Effort: S** |
| **No Dedicated Animator** | skills-audit flagged this. Nien (Character Artist) and Bossk (VFX) both touch animation but neither owns the animation pipeline end-to-end. As complexity grows, animation timing/feel falls between chairs. | When character count > 3 | Watch during Sprint 1. If animation becomes bottleneck, split from Nien. **Effort: N/A (monitor)** |
| **No Accessibility Specialist** | skills-audit listed `accessibility-design` as P2. No agent has accessibility in their charter. Given industry standards and player inclusivity, this is increasingly important. | Before public release | Add to Wedge's charter (natural domain extension). **Effort: S** |
| Agent | Current Load | Risk | Issue |
| **Solo** | Architecture + Leadership + Integration + Review + Decisions + Coordination with Jango | **High** | Solo is the single point of failure for every architectural decision, every code review of shared systems, every integration pass, and every priority call. Growth-framework §Risk 5 acknowledges this. No succession plan exists yet. |
| **Chewie** | 4 skills mapped (most of any agent per skills-audit) | **Medium** | Skills overlap will be reduced by the audit's merge recommendations. But Chewie owns engine systems across Canvas 2D AND Godot — when the transition happens, that's a dual workload. |
---

## 4. Knowledge Transfer Risks
### 4.1 First Thing That Breaks on a New Godot Project
If we started a Godot project tomorrow, here's what would fail, in order:
### 4.2 Playbook Walk-Through: Owner & Output Verification
| Playbook Step | Owner | Output Defined? | Clear? |
| **1.1 Genre Research** | Yoda | `analysis/{genre}-research.md` | ✅ Yes |
| **1.2 IP Assessment** | Not explicitly assigned | "IP assessment document" | ⚠️ No owner named. Should be Yoda + Solo. |
| **1.3 Tech Selection** | Chewie leads, Solo synthesizes | `analysis/tech-evaluation-{project}.md` | ✅ Yes |
| **1.4 Team Assessment** | Not explicitly assigned | "Skill transfer matrix, gap analysis, training plan" | ⚠️ Owner not named. Should be Solo. |
---

## 5. What's Working Well
### ✅ Strengths to Preserve (Do Not Change)
1. **The 12 Leadership Principles are exceptional.** They're operational (not aspirational), they have anti-patterns, they reference real failures, and they have a clear hierarchy (Player Hands First wins all tiebreakers). This is the strongest document in the system.
---

## 6. Prioritized Top 5 Actions
| # | Action | Why It's Top Priority | Owner | Effort | Impact |
|---|--------|----------------------|-------|--------|--------|
| **1** | **Update all 10 stale/skeletal/missing agent charters** to be studio-scoped, engine-agnostic, and skill-linked | 6 charters reference firstPunch-specific code/tech, 4 are skeletal, 1 is missing. These are the documents agents read FIRST. If they're wrong, everything downstream is confused. | Solo (author) + each agent (review) | **M** | 🔴 Critical — blocks clean project start |
| **2** | **Update team.md and routing.md to be studio-scoped** instead of firstPunch-scoped | team.md header says "firstPunch — Browser-based game beat 'em up arcade game." routing.md references "Web Audio API." These are studio-level documents wearing project-level clothing. | Solo | **S** | 🔴 Critical — identity confusion |
| **3** | **Create onboarding guide** (`.squad/identity/onboarding-guide.md`) | No Day 1 → Day N path exists. Growth-framework names 5 docs to read; nothing else. New agents have no setup instructions, no dev environment guide, no "how we work" orientation. | Solo + Scribe | **S** | 🟠 High — blocks team scaling |
| **4** | **Resolve ceremonies contradiction** — align ceremonies.md operational config with growth-framework's 4-ceremony rhythm | Two documents define different ceremony sets. A new team member doesn't know which is real. ceremonies.md needs the 4 scheduled ceremonies from the growth framework added. | Solo + Yoda | **S** | 🟠 High — process confusion |
| **5** | **Create release-management process** (skill + playbook section) | Zero documentation on how to ship a game to players. No versioning, no distribution, no release checklist, no hotfix process. We can build games but can't describe how we deliver them. | Solo + Jango | **M** | 🟠 High — blocks first release |
| # | Action | Owner | Effort |
---

## 7. Overall Foundations Score
### **Score: 7.5 / 10**
### Justification
| Dimension | Score | Weight | Rationale |
| **Identity & Vision** | 9/10 | High | company.md, mission-vision.md, and principles.md are excellent. Name, tagline, DNA, visual identity — all cohesive and genre-agnostic. This is publishing-quality studio identity work. |
| **Process & Methodology** | 7/10 | High | Playbook and growth-framework are strong. But 3 process gaps exist (onboarding, release management, project selection) and ceremonies are contradictory. |
| **Quality Standards** | 8/10 | High | Quality gates, DoD, bug severity matrix, playtest protocols — all production-ready. Minor issue: Godot-specific framing vs. engine-agnostic aspiration. |
| **Team Structure** | 7/10 | High | 15 agents with clear domains and routing. But 10/15 charters are stale or skeletal. Ralph is a ghost. Solo is a SPOF. |
| **Knowledge System** | 7/10 | Medium | Skills system is well-designed and growing (15 skills now, up from 12). But 4 agents still have zero skills. Tribal knowledge risk in Solo's history.md. |
---