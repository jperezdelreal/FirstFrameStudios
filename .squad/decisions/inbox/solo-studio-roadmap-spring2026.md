# Studio-Wide Roadmap — Spring 2026

**By:** Solo (Lead / Chief Architect)
**Date:** 2026-03-14
**Status:** Active
**Tier:** T1 (Lead authority)

## Decision

Defined studio-wide sprint roadmap across all 3 active FFS projects. 18 total issues created with full acceptance criteria, priority labels, and size estimates.

### Sprint Definitions

| Project | Sprint | Theme | ROADMAP Issue |
|---------|--------|-------|---------------|
| ComeRosquillas | Sprint 5 | Visual Spectacle & Engagement | #83 |
| Flora | Sprint 1 | Wow Factor & Deploy | #195 |
| FFS Squad Monitor | Sprint 3 | Architecture Consolidation | #119 |

### Studio Priority Order
1. **Flora** — Highest ROI. Excellent codebase needs only visual polish to become a showcase.
2. **ComeRosquillas** — Already deployed. Visual upgrade from procedural shapes to animated sprites.
3. **Squad Monitor** — Internal tool. Architecture cleanup prevents compounding debt.

### Key Architectural Observations
- Both games use procedural rendering (Canvas 2D / PixiJS Graphics) with no external art files. Visual quality standard requires upgrading to frame-based animation.
- ComeRosquillas game-logic.js (1,222 LOC) is a monolithic blocker — must split before adding features.
- Squad Monitor has 10 dead vanilla JS components alongside 16 active React components — architectural debt from rapid iteration.
- All issues designed for @copilot execution: concrete specs, file paths, acceptance criteria.

### Consequences
- Ralph-watch will pick up `go:ready` issues and create sessions
- Each project's perpetual-motion workflow should detect new roadmap items
- project-state.json should be updated in ComeRosquillas and Flora repos (sprint numbers)
- Hub issue #199 closed with full roadmap

### Rationale
Founder directive: "El Lead debe esforzarse en la definición de la estrategia y asegurar un roadmap potente." Visual Quality Standard requires games to be visually impressive — both games currently use placeholder/procedural visuals. Infrastructure cleanup (Monitor) prevents operational failures.
