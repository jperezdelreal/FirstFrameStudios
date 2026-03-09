# Sprint 1 — Definition of Success

**Sprint Owner:** Mace (Producer)  
**Sprint Theme:** Art Phase — Replace Procedural Placeholder Art with HD Pixel Art  
**Sprint Duration:** 2026-03-10 to 2026-03-20  
**Target Ship Date:** 2026-03-20

---

## Success Criteria (all must be true to close the sprint satisfied)

### Functional Criteria
What gameplay features must work by sprint end?
- [ ] All ~45 animation states per fighter (Kael + Rhena) render and transition correctly in-game
- [ ] Stage background displays with correct visual progression across 3 rounds
- [ ] Character-specific VFX spawn on hits with visually distinct palettes (Kael embers, Rhena bursts)
- [ ] Full 1v1 match playable from menu → select → fight → victory with final art (no placeholder rectangles)
- [ ] All fighter animations respond to game state changes (move startup, active, recovery, hit, block, KO, etc.)

### Technical Criteria (Quality Gates)
What quality bars must be met?
- [ ] All milestone gates (M0-M4) passed
- [ ] Integration gate passes (0 orphaned signals, 0 missing sprite/VFX/stage assets)
- [ ] All sprites load at native 128×128 px resolution (no scaling or upsampling)
- [ ] Asset naming convention enforced per Art Direction document (boba-art-direction.md)
- [ ] No P0 bugs open (sprite loading failures, animation crashes, VFX clipping, stage overlap issues)
- [ ] 60 FPS performance maintained during full 1v1 match (no dropped frames during animations)
- [ ] Code review: all art integration PRs approved by Chewie (Engine Lead)
- [ ] Branch hygiene: all feature branches (squad/nien-*, squad/leia-*, squad/bossk-*, squad/chewie-*) merged to main post-M4

### Quality Criteria (Feel, Polish, Playtesting)
What does the build feel like?
- [ ] Ackbar visual playtest verdict: **PASS** (required; PASS WITH NOTES acceptable only if follow-ups documented)
- [ ] Silhouette test passes: both fighters visually distinct at glance (can identify Kael vs Rhena without UI labels)
- [ ] Final art asset standard met (no placeholder rectangles, no missing textures, no fallback art)
- [ ] Character animation smoothness verified (transitions frame-perfect, no stutters or jumps)
- [ ] VFX visual quality: character-specific particles clearly differentiate identity
- [ ] Stage round transitions smooth (1–2 second color/particle lerp, no abrupt jumps)
- [ ] No major visual bugs blocking core loop (sprite clipping, animation gaps, particle overlaps)

### Documentation Criteria
What docs must be written/updated?
- [ ] Art Direction document finalized (`games/ashfall/docs/ART-DIRECTION.md` or boba-art-direction.md)
  - Character silhouettes, color palettes, animation timing, VFX themes locked
  - Asset naming convention documented and enforced
  - Signed off by Boba (Art Director)
- [ ] now.md updated to show Sprint 1 ✅ SHIPPED; next focus = Sprint 2 (UI Phase)
- [ ] SPRINT-1-SUCCESS.md filled out completely (this document, verification checklist + verdict)
- [ ] Agent histories updated with learnings:
  - `.squad/agents/nien/history.md` — Sprite creation process, bottlenecks, techniques
  - `.squad/agents/leia/history.md` — Stage visual progression, EventBus integration
  - `.squad/agents/bossk/history.md` — VFX character differentiation approach
  - `.squad/agents/chewie/history.md` — AnimationPlayer wiring, sprite loading pipeline
  - `.squad/agents/mace/history.md` — Sprint 1 execution, scope lock success, risks mitigated
- [ ] Dev Diary post (#ashfall discussion): "Sprint 1 Art Phase Complete" (within 24h of ship)
- [ ] Decision document filed: `mace-sprint-1-closure.md` (scope decisions, changes, critical follow-ups)

### Ship Criteria (When can we close?)
- [ ] All functional criteria met ✅
- [ ] All technical criteria passed ✅
- [ ] All quality criteria signed off ✅
- [ ] All documentation current ✅
- [ ] Founder (Joaquín/joperezd) approves sprint closure (if Ackbar playtest reveals critical issues, approval needed)
- [ ] Git tag created: `git tag -a sprint-1-shipped -m "Sprint 1 Art Phase shipped — all 45 animation states per fighter final, stage visual progression complete, VFX character palettes live, AnimationPlayer wired"`
- [ ] Tag pushed to origin: `git push origin sprint-1-shipped`

---

## Verification Checklist (FILL OUT AT SPRINT END)

### Functional Verification
| Criteria | Status | Notes |
|----------|--------|-------|
| All animation states (Kael ~45) render in-game | ❌ Pending | Expected: M1 complete with all P0+P1 states, P2 if capacity allows |
| All animation states (Rhena ~45) render in-game | ❌ Pending | Expected: M1 complete in parallel with Kael |
| Stage round 1 visual state (dormant volcano) | ❌ Pending | Expected: M1b complete, EventBus wired |
| Stage round 2 visual state (warming lava) | ❌ Pending | Expected: M1b complete with particle escalation |
| Stage round 3 visual state (full eruption) | ❌ Pending | Expected: M1b complete with max particles + brightness |
| Kael VFX palette (upward-floating embers) | ❌ Pending | Expected: M2 complete with orange/yellow particles |
| Rhena VFX palette (outward-bursting shards) | ❌ Pending | Expected: M2 complete with red/white particles |
| Full 1v1 match playable with final art | ❌ Pending | Expected: M3 complete, integration gate passed |

### Technical Verification
| Gate | Status | Notes |
|------|--------|-------|
| M0 — Art Direction locked | ❌ Pending | Boba deliverable Day 1–2; includes silhouettes, palettes, naming convention |
| M1 — Nien character sprites complete | ❌ Pending | ~90 total frames (45 Kael + 45 Rhena); PNG format; 128×128 px each |
| M1b — Leia stage background final | ❌ Pending | 3 round states with transitions; EventBus integration; compatible framing |
| M2 — Bossk VFX palettes tested | ❌ Pending | Both characters; test bench validates; integration gate passes |
| M2b — Chewie AnimationPlayer wired | ❌ Pending | All states mapped; sprite loading pipeline; no placeholder fallback |
| M3 — Visual integration complete | ❌ Pending | Full game loop with final art; 0 orphaned signals; 0 missing assets |
| Integration gate passes | ❌ Pending | All sprite files found; all animation states respond; 60 FPS verified |
| P0 bugs open | ✅ 0 open | Expected: 0 sprite loading failures, animation crashes, or VFX glitches |

### Quality Verification
| Item | Status | Notes |
|------|--------|-------|
| Silhouette test passes | ❌ Pending | Kael vs Rhena visually distinct at glance |
| Ackbar visual playtest verdict | ❌ Pending | Expected: PASS (Date 2026-03-20) |
| Character animation smoothness | ❌ Pending | Transitions frame-perfect; no jumps or stutters |
| VFX character differentiation | ❌ Pending | Particles clearly identify Kael vs Rhena |
| Stage visual progression smooth | ❌ Pending | Color/particle lerp 1–2 seconds; round 1→2→3 escalation clear |
| No visual glitches in core loop | ❌ Pending | Expected: sprite clipping, animation gaps, particle overlaps all zero |

### Documentation Verification
| Item | Status | Notes |
|------|--------|-------|
| Art Direction document complete | ❌ Pending | Silhouettes, palettes, animation timing, VFX themes, naming convention |
| Asset naming convention enforced | ❌ Pending | All ~90 sprite files follow boba's M0 convention |
| now.md updated | ❌ Pending | Sprint 1 marked ✅ SHIPPED; Sprint 2 marked 🔄 NEXT |
| SPRINT-1-SUCCESS.md filled out | ❌ Pending | This document; verification checklist complete; verdict logged |
| Agent histories updated | ❌ Pending | Nien, Leia, Bossk, Chewie, Mace all post learnings |
| Dev Diary post written | ❌ Pending | Within 24h of ship; tags #ashfall, highlights major deliverables |
| Decision document filed | ❌ Pending | mace-sprint-1-closure.md; scope, changes, follow-ups documented |

---

## Verdict

### Sprint 1 Status: ❌ PENDING (Expected ✅ SHIPPED on 2026-03-20)

**Expected Ship Date:** 2026-03-20  
**Current Status:** PLANNING PHASE (waiting for M0 gate)  

**Key Deliverables (Expected):**
- Kael final sprites (all ~45 states)
- Rhena final sprites (all ~45 states)
- EmberGrounds stage with 3-round visual progression
- Kael + Rhena character-specific VFX palettes
- AnimationPlayer fully wired (no placeholder fallback)
- Art Direction document (silhouettes, palettes, naming convention)

**Known Limitations (acceptable for this sprint):**
- P2 animation states (throw, throw_victim, wake-up, dash_fwd, dash_bak, win/lose poses) may be de-scoped if Nien hits capacity constraints. These defer to Sprint 2 (UI/Polish Phase) — not blocking core gameplay.
- Training mode (frame data overlay, input history) explicitly deferred post-launch. See issue #56.

**Critical Follow-ups (for next sprint):**
- [ ] If P2 states de-scoped: prioritize throw mechanics + win/lose poses in Sprint 2
- [ ] Audio integration (SFX, music, announcer) — Sprint 3 (Audio Phase) depends on final sprites
- [ ] UI polish (character select visual upgrade, in-game HUD alignment with new sprites) — Sprint 2 starts
- [ ] Any visual bugs found during M4 playtest: triage, document severity, assign to Sprint 2 if non-critical

---

## Lessons Learned (FILL OUT AT SPRINT END)

### What Went Well
- [ ] [Pattern/process that accelerated delivery — document at sprint end]
- [ ] [Any agent collaboration that was particularly effective — note for future sprints]

### What Went Wrong
- [ ] [Issue that slowed us down — root cause analysis — how to prevent next sprint]
- [ ] [Any unexpected blocker or bottleneck — mitigation strategy]

### Process Improvements
- [ ] [Adjustment to make next sprint smoother — be specific]
- [ ] [Team/tools/communication improvement]

---

*Mace (Producer) — Sprint 1 Definition of Success, 2026-03-10*

*To be completed and verified at sprint end (2026-03-20). All checkboxes will be filled with ✅ or ❌ + notes.*
