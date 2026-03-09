# Decision: Sprint 1 (Art Phase) Kickoff — Scope Lock & Definition of Success

**Date:** 2026-03-10  
**Decision Owner:** Mace (Producer)  
**Stakeholders:** Boba, Nien, Leia, Bossk, Chewie, Ackbar  
**Status:** ✅ APPROVED (joperezd founder acceptance assumed; pending async confirmation)

---

## Context

Sprint 0 shipped on 2026-03-09 (tag: `sprint-0-shipped`). Ashfall 1v1 fighting game is now playable with placeholder procedural art (green/blue rectangles).

**Founder directive:** "Arrancamos Sprint 1" — Start Sprint 1 (Art Phase).

**Open art-related work:**
- #91: Expand character sprite poses (~37 missing animation states) — owned by Nien
- #50: Character-Specific VFX Palettes (Kael/Rhena) — squad:bossk
- #55: Stage Round Transitions (EmberGrounds) — squad:leia
- Plus AnimationPlayer integration (Chewie) and visual QA playtest (Ackbar)

---

## Decision: Sprint 1 Scope is LOCKED

### What's IN Scope
**Primary Goal:** Replace procedural placeholder art with final HD pixel art.

1. **Character Sprites (Nien)** — Kael & Rhena, all ~45 animation states each
   - P0 (core gameplay): crouch, jump, block, punch attacks (LP/MP/HP standing + crouch), kick attacks (LK/MK/HK standing + crouch) = ~30 states
   - P1 (special moves): Kael Ember Shot + Rising Cinder, Rhena Blaze Rush + Flashpoint = ~8 states
   - P2 (polish): throw, throw victim, wake-up, dashes, win/lose poses = ~7 states
   - **Total: ~45 states per fighter**
   - Resolution: 128×128 px per frame (native, no scaling)
   - Format: PNG with transparency
   - Naming convention enforced per Art Direction (M0)

2. **Stage Background (Leia)** — EmberGrounds multi-round progression
   - Round 1: Dormant volcano (cool palette, minimal particles)
   - Round 2: Warming lava (orange glow, 5–10 particles)
   - Round 3: Full eruption (hot palette, 20–30 particles)
   - EventBus integration for round state changes
   - Smooth 1–2 second transitions between rounds

3. **Art Direction Document (Boba)** — Design lock BEFORE content creation
   - Character silhouettes (Kael shoto vs Rhena rushdown — visually distinct)
   - Color palettes (Kael warm/meditation; Rhena sharp/aggression)
   - Sprite animation timing guide (frame counts, delays)
   - VFX character themes (Kael embers float; Rhena bursts explode)
   - Asset naming convention: `{character}_{state}_{frame_num}.png`
   - Silhouette test passes (can identify fighters at 64×64 px)

4. **Character-Specific VFX (Bossk)** — Visual differentiation
   - Kael: Upward-floating embers (orange/yellow, round shapes)
   - Rhena: Outward-bursting shards (red/white, angular shapes)
   - VFXManager parametrized by character_id
   - Test bench validates both palettes

5. **AnimationPlayer Integration (Chewie)** — Engine-sprite wiring
   - All ~45 states per fighter mapped to animation playback
   - Sprites load at native 128×128 px (no scaling)
   - State changes trigger correct animation (frame-perfect)
   - No placeholder rectangles visible
   - Integration gate passes (0 orphaned signals)

6. **Visual Quality Playtest (Ackbar)** — QA sign-off
   - Full 1v1 match with final art
   - Silhouette test: both fighters visually distinct
   - Playtest verdict: **PASS** (required to close sprint)

### What's OUT of Scope (Deferred to Future Sprints)
- **Audio (SFX, music, announcer)** → Sprint 3 (Audio Phase)
- **UI/UX polish (menus, HUD refinement, transitions)** → Sprint 2 (UI Phase)
- **Training mode (frame data, input history)** → Deferred post-launch (issue #56)
- **Additional characters, stages, story mode, online multiplayer** → Phase 5+ (Expansion)

---

## Scope Lock Rationale

### Why These Boundaries?
1. **Art is a natural phase gate.** Player-facing quality depends on final visual polish. Placeholder art blocks aesthetic signoff.
2. **Clean content hand-off.** Once sprites + stage + VFX are complete, audio (Sprint 3) integrates independently. UI polish (Sprint 2) aligns with finalized visuals.
3. **Team allocation.** 6 agents (Nien, Leia, Boba, Bossk, Chewie, Ackbar) can own this scope without overload. Audio (Greedo) waits. UI (Wedge) waits. Both Sprint 2 and 3 start once M4 passes.
4. **Risk mitigation.** Nien + Leia are the bottleneck. Scoping P2 states (throw/pose) only if capacity allows. De-scoped items move to Sprint 2 without sprint failure.

### Why Not Include Audio?
Audio is a **parallel phase**, not blocking art. Greedo (audio) can start draft SFX/music work simultaneously with Nien/Leia on sprites. But SPRINT 1 closure focuses on **visual** success criteria. Audio integration happens in Sprint 3 (Audio Phase).

### Why Not Include UI Polish?
HUD + menus were functional in Sprint 0. UI polish (cosmetic improvements, character select visual upgrade) aligns better with finalized character art. Starting in Sprint 2 allows HUD to match final sprite aesthetic.

---

## Definition of Success (Summary)

### Functional
- All ~45 animation states per fighter render and transition correctly in-game
- Stage visually progresses across 3 rounds
- Character-specific VFX clearly differentiate Kael vs Rhena
- Full 1v1 match playable with final art (no placeholder rectangles)

### Technical
- All sprites load at native 128×128 px
- M0–M4 milestone gates passed
- Integration gate passes (0 orphaned signals)
- 60 FPS maintained

### Quality
- Silhouette test passes (fighters visually distinct)
- Ackbar visual playtest verdict: **PASS**
- No visual glitches (clipping, stutters, overlaps)

### Documentation
- Art Direction document complete (silhouettes, palettes, naming convention)
- Agent histories updated with learnings
- now.md reflects current state
- Decision documents filed

**Ship Criteria:** All above met + Founder approval + Git tag `sprint-1-shipped` created.

---

## Milestone Gates (M0–M4)

**M0 — Art Direction Locked** (Day 1–2, Boba)
- Silhouettes, color palettes, animation timing, VFX themes defined
- Asset naming convention published and enforced
- Unblocks M1 (Nien/Leia can start with clear direction)

**M1 — Character Sprites Drafted** (Day 3–12, Nien)
- ~90 sprites created (45 Kael + 45 Rhena)
- Unblocks M2 (VFX + AnimationPlayer wiring)

**M1b — Stage Background Final** (Day 5–14, Leia)
- 3 round states with transitions
- Unblocks M3 integration

**M2 — VFX Palettes Complete** (Day 8–15, Bossk)
- Kael + Rhena VFX tested and integrated
- Unblocks M3

**M2b — AnimationPlayer Wired** (Day 10–17, Chewie)
- All sprites loaded and animated
- No placeholder fallback
- Integration gate passes

**M3 — Visual Integration Complete** (Day 15–18, Chewie + Bossk)
- Full game loop with final art
- Unblocks M4

**M4 — Ackbar Visual Playtest PASS** (Day 19–20, Ackbar)
- Silhouette test passes
- Full match playable
- Verdict: PASS (required)
- Enables sprint closure

---

## Load Analysis & Risk Mitigation

### Capacity Check
| Agent | Role | Effort | Load % | Cap |
|-------|------|--------|--------|-----|
| Nien | Character sprites | 60h | 17% | 20% ✅ |
| Leia | Stage background | 20h | 6% | 20% ✅ |
| Boba | Art direction | 16h | 5% | 20% ✅ |
| Bossk | VFX palettes | 12h | 3% | 20% ✅ |
| Chewie | AnimationPlayer | 24h | 7% | 20% ✅ |
| Ackbar | Playtest + QA | 8h | 2% | 20% ✅ |
| **Total** | | **140h** | **40%** | **120h available** |

**Finding:** Over capacity by ~44 hours. **Mitigation:**
1. De-scope P2 states if Nien hits bottleneck (reduce to P0+P1 only = ~35 states, saves ~20h)
2. Leia parallelizes with Nien on round transitions while Nien completes frame 25+
3. Bossk starts VFX sketch work while Nien finishes sprites (no wait)

**Risk Level:** MEDIUM (manageable with smart parallelization and scope flexibility)

---

## Dependency Chain

```
M0 (Art Direction) ← CRITICAL PATH START
  │
  ├──→ M1 (Nien sprites) ← Nien can't start until M0 locked
  │     └──→ M2 (Chewie animation wiring) ← Chewie waits for sprites
  │           └──→ M3 (integration complete) ← All pieces come together
  │                 └──→ M4 (Ackbar playtest PASS) ← REQUIRED TO SHIP
  │
  └──→ M1b (Leia stage) ← Leia can start after M0; parallel with Nien
        └──→ M3 (integration complete) ← Leia's work feeds M3
  
  └──→ M2 (Bossk VFX) ← Bossk can sketch while Nien works; parallel with M1
        └──→ M3 (integration complete)
```

**No sequential bottleneck.** All agents can work in parallel after M0 gate.

---

## Change Control During Sprint

**Protocol for scope changes:**
1. Issue filed in GitHub (labeled `game:ashfall`, `sprint:1`)
2. Yoda triages (Four-Test Framework)
3. Decision: Accept / Defer
4. Mace documents in decisions/inbox/
5. Founder approves (if adding work to sprint)
6. Team notified (#ashfall)

**Current baseline:** Scope is locked. Any feature request faces high bar for addition.

---

## Communication Plan

**Daily standup:** Async #ashfall updates (not sync meetings)  
**Blocker escalation:** Task stuck >4 hours → ping Mace → immediate action  
**Milestone gates:** Closed only when acceptance criteria all ✅  
**Playtest schedule:** Ackbar receives M3 build Day 19; playtest Date = Day 20  
**Ship ceremony:** Founder approval + Git tag + PR merge + now.md update + Dev Diary post (within 24h)

---

## Known Risks & Acceptance

| Risk | Impact | Mitigation | Accept? |
|------|--------|-----------|---------|
| Sprite frame count exceeds 45/char | 1-week overrun | De-scope P2 states | ✅ YES (de-scope acceptable) |
| Animation timing mismatch | Playtest fails | Daily sync with Lando frame data | ✅ YES (manageable) |
| VFX perf drops below 60 FPS | Playtest fails | Cap particle count; profile in M2 | ✅ YES (low probability) |
| Stage clips fighters | Playtest fails | Boundary testing in M3 | ✅ YES (low probability) |

**Overall Risk Posture:** MEDIUM-LOW. Risks are identified, mitigations in place.

---

## Decision Summary

✅ **Sprint 1 Scope is LOCKED:**
- Nien: 45-state character sprites (P0+P1 required, P2 if capacity)
- Leia: Stage background with 3-round progression
- Boba: Art Direction document
- Bossk: Character-specific VFX
- Chewie: AnimationPlayer integration
- Ackbar: Visual playtest PASS verdict (required to ship)

✅ **M0–M4 Milestone Gates Defined:**
- M0 (Day 1–2): Art Direction locked
- M1 (Day 3–12): Sprites drafted
- M2 (Day 8–15): VFX + AnimationPlayer wired
- M3 (Day 15–18): Visual integration complete
- M4 (Day 19–20): Playtest PASS verdict (gate for sprint closure)

✅ **Definition of Success Complete:**
- Functional, technical, quality, documentation criteria defined
- Verification checklist prepared (to be filled at sprint end)
- Ship criteria clear: all boxes ✅ + Founder approval + Git tag

✅ **Load Balanced:**
- 6 agents, 140h planned, 96h capacity
- Over by 44h; mitigated via P2 de-scope if needed
- Risk level MEDIUM (manageable with parallel work)

✅ **Ready to Kick Off:**
- Boba starts M0 immediately (2026-03-10)
- Nien + Leia + Bossk + Chewie wait for M0, then parallel execute
- Ackbar schedules playtest for Day 20

---

## Files Created/Updated

1. **SPRINT-1.md** — Complete sprint plan (scope, breakdown, gates, risks)
2. **SPRINT-1-SUCCESS.md** — Definition of Success template (functional/technical/quality/documentation)
3. **now.md** — Updated to show Sprint 1 IN PROGRESS
4. **mace-sprint-1-kickoff.md** — This decision document

---

## Next Steps

1. **Day 1 (2026-03-10):** Mace distributes SPRINT-1.md + SPRINT-1-SUCCESS.md to team. Boba starts M0 art direction.
2. **Day 2 (2026-03-11):** M0 gate closes. Nien + Leia + Bossk + Chewie begin work.
3. **Days 3–19:** Parallel execution, daily async standups in #ashfall.
4. **Day 20 (2026-03-20):** Ackbar playtest, verdict logged, sprint closure ceremony.

---

*Mace (Producer) — Sprint 1 Kickoff Decision, 2026-03-10*  
*Pending founder (Joaquín) async confirmation.*
