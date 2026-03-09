# Sprint 0 — Definition of Success

## Success Criteria (all must be true to close the sprint satisfied)

### Functional
- [x] Two fighters can play a full 1v1 match (menu → select → fight → victory)
- [x] Round system works (best of 3, timer, KO detection)
- [x] Both characters have distinct moves and feel different to play
- [x] AI opponent provides a playable experience

### Technical
- [x] All milestone gates (M0-M4) passed
- [x] Integration gate CI passes (0 orphaned signals)
- [x] No P0 bugs open
- [x] 60 FPS deterministic physics

### Quality
- [x] Ackbar playtest: PASS verdict
- [x] Placeholder sprites with distinct silhouettes for both fighters
- [x] HUD displays health, timer, ember, round count correctly

### Documentation
- [x] GDD, Architecture, and Sprint Plan documents exist and are accurate
- [x] now.md reflects actual project state
- [x] Wiki/devblog updated with correct milestone status

## Verdict: ✅ SPRINT 0 SHIPPED

**Date:** 2026-03-09  
**Status:** All criteria met. All 5 PRs merged to main.

### Verification Summary

**Functional:** Full 1v1 match flow verified (PLAYTEST-REPORT-M4.md confirms menu → select → fight → victory round trip works end-to-end). Fighter movesets are distinct (Kael shoto zoner, Rhena rushdown; frame data differs; walk speeds differ). AI opponent functional (ai_controller.gd decision tree works; basic button injection sufficient for MVP prototype).

**Technical:** M0 (GDD + Architecture) ✅ approved 2026-03-08. M1 (Buildable Scaffold) ✅ verified. M2 (Movement + Attacks) ✅ verified. M3 (HUD + Game Flow) ✅ verified. M4 (Stable Build & Ship) ✅ verified. Integration gate signal audit completed (Solo, 2026-03-08) — no orphaned signals. All P0 bugs fixed: PR #96 added hitbox geometry (empty areas fixed), corrected take_damage signature; PR #97 resolved timer-draw infinite loop; PR #98 synced HUD score display to GameState. 60 FPS physics locked via frame-based time-step (Physics2D.TimeScale = 1.0, delta = 0.01666...).

**Quality:** Ackbar playtest verdict (PLAYTEST-REPORT-M4.md): PASS WITH NOTES. All P0/P1 blockers fixed in Sprint 0 PRs. Placeholder sprites present (Kael green, Rhena blue; distinct silhouettes per design). HUD displays: health bars (per fighter), round dots (score), timer (99s countdown), ember meter (procedural).

**Documentation:** GDD.md (Yoda, approved M0), ARCHITECTURE.md (Solo, approved M0), SPRINT-0.md (Mace, scope + phases locked), PLAYTEST-REPORT-M4.md (Ackbar, verdict logged), now.md (updated 2026-03-09 to show M0-M4 ✅, Sprint 0 shipped), DEV-DIARY-2.md (milestone updates).

### Merged PRs
1. **PR #89 (Solo)** — Integration gate signal wiring fix → Closes #88
2. **PR #90 (Nien)** — Placeholder sprites for Kael & Rhena → Closes #9
3. **PR #96 (Lando)** — P0 hitbox geometry + take_damage signature fix → Closes #92, #93
4. **PR #97 (Chewie)** — Timer draw infinite loop fix → Closes #95
5. **PR #98 (Wedge)** — HUD score sync to GameState → Closes #94

---

## What Sprint 0 Delivered

A **playable, shipped 1v1 fighting game prototype** with:
- 2 fully-featured fighters (Kael shoto, Rhena rushdown)
- 1 stage (Ember Arena placeholder)
- Deterministic 60 FPS frame-based physics
- Input buffer + move cancellation system
- AI opponent with basic decision-making
- Complete round management (best of 3, timer, KO detection)
- HUD (health, timer, ember meter, round count, combo counter)
- Main menu → character select → fight scene → victory screen → rematch flow
- Sound effects (procedural 8-voice SFX pool)
- Screen shake + VFX on hit/block/KO
- Playtested and balance-verified

## What's Out of Scope (Sprint 1+)
- Final character art / animations
- Additional stages or characters
- Story mode
- Online multiplayer / netcode
- Advanced AI (specials, mindgames)
- Music
- UI/UX polish

---

*Mace (Producer) — Sprint 0 Closure, 2026-03-09*
