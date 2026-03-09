# Ackbar Sprint 1 Visual Playtest Verdict

**Author:** Ackbar (QA Lead / Playtester)  
**Date:** 2025-07-22  
**Scope:** Sprint 1 Art Phase — PRs #103, #104, #105, #106  
**Status:** Proposed

---

## Verdict: ✅ PASS WITH NOTES

Sprint 1 art deliverables meet quality bar for shipping. All 41 animation states implemented per character with distinct procedural art. VFX wired to EventBus. Stage escalation functional. AnimationPlayer integration correct. Characters visually distinct.

### Three P1 issues require follow-up before Sprint 2 gameplay tuning:

1. **P1-001:** MP/MK base .tres startup frames are 1f faster than GDD spec (6f/7f vs 7f/8f). Must align before combo link math.
2. **P1-002:** Medium attacks (MP, MK, crouching, air variants) missing from character moveset .tres files. Only 6 moves per character (LP, HP, LK, HK + 2 specials).
3. **P1-003:** Frame data drift between `resources/moves/fighter_base/` .tres and character-specific `resources/movesets/` .tres. HP startup: base=10f vs character=12f. Risk of wrong data loading.

### Impact on Team:
- **Yoda:** Review GDD frame data ranges vs implementation — confirm intended values
- **Solo/Chewie:** Resolve which .tres source is authoritative (base vs character moveset)
- **Mace:** Track P1-001 through P1-003 as Sprint 2 blockers before combo tuning

### Why:
Sprint 1 success criteria require Ackbar visual playtest pass. PASS WITH NOTES is acceptable per SPRINT-1-SUCCESS.md ("PASS WITH NOTES acceptable only if follow-ups documented"). All follow-ups documented with GitHub issues.

Full report: `games/ashfall/docs/PLAYTEST-REPORT-SPRINT1.md`
