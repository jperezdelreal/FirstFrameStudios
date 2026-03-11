# Mace — History

## Learnings

### Historical Work (Sessions 1-8)

- Sprint 1 Closure — Art Phase Shipped (2026-03-20)
- Sprint 1 Kickoff — Art Phase Planning (2026-03-10)
- Sprint 0 Closure & Definition of Success Framework (2026-03-09)
- Documentation Audit & Milestone Status Sync (2026-03-09)
- Ashfall Sprint 0 Plan (2026-[TBD])
- Sprint 0 Plan Delivered
- Key Governance Decisions Locked
- Team Composition Notes

### Sprint 0 Deliverables
| Agent | Deliverable | Status |
|-------|-------------|--------|
| **Yoda** | Game Design Document | ✅ Completed |
| **Solo** | Architecture Proposal | ✅ Completed |
| **Jango** | Godot project scaffold | Blocked on M0 approval |
| **Chewie** | Core gameplay systems | Blocked on M0 approval |
| **Lando** | Fighter controller | Blocked on M0 approval |
| **Wedge** | HUD + game flow | Blocked on M0 approval |
| **Boba** | Art direction document | Blocked on M0 approval |
| **Tarkin** | Basic AI opponent | Blocked on M0 approval |
| **Ackbar** | Playtesting & feedback | Scheduled Day 4 |

### Critical Gates & Milestones
- **M0 (Day 2):** GDD + Architecture approval. Design locks strategy upstream.
- **M1-M3 (Days 3-5):** Sequential but overlapping gates. Each unblocks next team without waterfall.
- **M4 (Day 7):** Stable playable build required. Ship gate.

### Risk Mitigation
1. **Godot physics behavior** — Day 1 spike test on RigidBody2D knockback. If unpredictable, pivot to kinematic early.
2. **GDD clarity** — Day 1 completion. Yoda → Solo same-day sign-off prevents cascading rework.
3. **Playtesting feedback loop** — Mid-sprint (Day 4) testing catches feel issues. 2-3 day buffer before Day 7 ship.

### Integration with Yoda & Solo
- **Yoda (Creative Director):** Knows Mace's phased plan. Four-Test Framework will govern feature triage. Has Creative Director tie-breaker authority.
- **Solo (Lead Architect):** Knows Mace's load cap + Scrumban methodology. Architecture supports 6 parallel work lanes. M0 gate validates design + code contracts before Phase 1 code begins.

### Status
✅ Sprint 0 plan locked. All governance documented. Team ready for M0 approval and parallel execution.

---

## Yoda & Solo Partnership Notes

**Cross-team visibility:** Mace now aware of Yoda's GDD creative lock (Ember System, scope boundary, deterministic simulation requirement). Sprint 0 plan enforces this scope with governance protocol. No feature creep possible.

**Cross-team visibility:** Mace now aware of Solo's architecture (6 parallel work lanes, module boundaries, resource-driven design). Sprint 0 phased plan aligns with architectural parallelism. Phased expansion (Balance → Art → Audio) matches architecture's frame-locked determinism.