### 2026-03-11: Upstream + SubSquad + Blog Patterns Architecture Proposal
**By:** Solo (Lead Architect) + Jango (Tool Engineer)
**Status:** AWAITING FOUNDER APPROVAL
**What:** Complete implementation plan for incorporating Tamir Dresher blog patterns + upstream + subsquad into FFS workflow.

**Architecture Decision: Option C — Hybrid (RECOMMENDED)**
- `FirstFrameStudios/` = Studio hub (parent squad with identity, skills, principles)
- `jperezdelreal/flora` = Game repo (subsquad, inherits via `squad upstream`)
- Scales to future games: new repo + `squad upstream add FirstFrameStudios`
- 11 FLORA agents active, 3 hibernated (Leia, Bossk, Nien)

**Implementation Phases:**
- Phase 0: Restructure studio hub, TLDR convention (Day 1)
- Phase 1: Create FLORA repo, squad init, squad upstream (Day 1-2)
- Phase 2: CI/CD, workflows, issue templates, project board (Day 2-3)
- Phase 3: ralph-watch + scheduler (Day 3-4)
- Phase 4: FLORA Sprint 0 — build the game! (Day 4+)
- Phase 5: Podcaster + Squad Monitor (Week 2+)

**Tooling Priority:**
- DO FIRST: Issue template, heartbeat cron, TLDR convention, archive/notify workflows (~5h)
- DO NEXT: ralph-watch.ps1, scheduler, daily-digest, drift-detection (~24h)
- DO LATER: Squad Monitor, Podcaster (~5h)

**Full plans available in session context. Awaiting Joaquín's go/no-go.**
