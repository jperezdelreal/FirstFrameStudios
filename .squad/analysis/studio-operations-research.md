# Studio Operations Research — Industry Best Practices & Academic Findings

> Compressed from 27KB. Full: studio-operations-research-archive.md

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
---

## 1. Studio Organization Models
### 1.1 Flat vs. Hierarchical Structures
**Finding:** Most successful indie studios (3–15 people) use flat or minimally hierarchical structures. Direct communication, shared ownership, and creative freedom are the primary advantages. As teams grow past 10–20 members, a lightweight hierarchy (lead roles, not management layers) becomes necessary for coordination without bureaucracy.
### 1.2 The Pod/Cell Model (Supercell, Riot Games)
### 1.3 Nintendo EAD/EPD Model
### 1.4 Valve's "Flatland" — Lessons and Warnings
---

## 2. Development Methodologies
### 2.1 Agile in Game Development
**Finding:** Agile works in game development, but never in textbook form. Studios adapt Scrum and Kanban to fit creative work's inherent unpredictability. The most successful approach is "Scrumban" — Scrum's sprint structure for implementation work, Kanban's continuous flow for creative work.
### 2.2 The Milestone System
| Milestone | Purpose | Fidelity | Team Size |
| **Concept** | Vision, pillars, USP, pitch doc | Documents only | 2–4 senior |
| **Prototype** | Validate core mechanics, prove fun | Low (placeholder art) | 3–6 |
| **Vertical Slice** | Prove quality bar, secure funding | Near-final (small scope) | 5–10 |
| **Alpha** | Feature-complete, start-to-finish playable | Medium (some placeholder) | Full team |
---

## 3. Academic Research on Game Development
### 3.1 Team Dynamics and Psychological Safety
**Finding:** Psychological safety — the shared belief that a team is safe for interpersonal risk-taking — is the single strongest predictor of creative team performance in software development, with even greater impact in game development's cross-disciplinary context.
### 3.2 Crunch Culture: Causes, Effects, and Avoidance
### 3.3 Predictors of Game Quality
| Factor | Impact on Quality | Key Insight |
| **Team size** | Positive correlation, diminishing returns | Larger teams bring resources but risk coordination overhead |
| **Budget** | Enables quality but doesn't guarantee it | Poor resource management negates budget advantage |
| **Development time** | More time = more polish, but crunch negates gains | Disciplined time management matters more than raw hours |
---

## 4. Tools & Infrastructure That Scale
### 4.1 Build vs. Buy Decision Framework
**Finding:** Indie studios should buy/adopt tools for everything except their core differentiator. Custom tools should only be built when they create a competitive advantage that off-the-shelf solutions cannot provide.
| Need | Buy/Adopt | Build |
| Game engine | ✅ (Godot, Unity, Unreal) | ❌ (never for an indie) |
| Version control | ✅ (Git, Perforce) | ❌ |
| Art pipeline | ✅ (Blender, Aseprite) | ❌ |
| Audio tools | ✅ (FMOD, Wwise) | ❌ |
| CI/CD | ✅ (GitHub Actions, TeamCity) | ❌ |
---

## 5. Business Models & Sustainability
### 5.1 Revenue Models Comparison
| Model | Upfront Revenue | Ongoing Revenue | Risk | Best For |
| **Premium** | ✅ High | ❌ Low (DLC helps) | Frontloaded, drops fast | Complete experiences, strong IP |
| **Free-to-Play** | ❌ None | ✅ High (if successful) | Requires live ops infrastructure | Mobile, competitive multiplayer |
| **Early Access** | ✅ Moderate | ✅ Moderate (during dev) | Must deliver regular updates | PC, iterative development |
| **Crowdfunding** | ✅ Moderate | ❌ None | <25% campaign success rate | Niche/passionate audiences |
| **Publisher Deal** | ✅ High (funding) | 🟡 Split revenue (70/30 or 80/20) | Loss of some control | Marketing-dependent games |
| **Subscription (Game Pass)** | ✅ Guaranteed payment | 🟡 Platform-dependent | Lower per-user revenue | Catalog diversification |
---

## Sources & References
### Studio Organization
- Gamedeveloper.com — "Veteran devs claim smaller teams could mean more successful games"
### Development Methodology
### Academic Research
### Tools & Infrastructure