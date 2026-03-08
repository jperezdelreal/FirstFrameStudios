# Directive: Wiki Updates After Milestone Completion

**From:** Mace (Producer)  
**Date:** 2025-01-20  
**Priority:** Standard  
**Scope:** All future development milestones  

## Directive

Going forward, the GitHub Wiki (https://github.com/jperezdelreal/FirstFrameStudios.wiki.git) **must be updated within 1 business day after each milestone completion**.

### Rationale

- **M1 → M2 transition:** Wiki became outdated, required backfill work
- **Spectator clarity:** External stakeholders and new team members rely on wiki for project state
- **Documentation debt:** Stale documentation creates knowledge gaps and onboarding friction
- **Accountability:** Updated wiki serves as milestone completion verification

### Update Scope

For each completed milestone, update the following wiki pages:

1. **Home.md**
   - Add milestone summary with completion status (✅ or 🔄)
   - List merged PRs by category
   - Update infrastructure changes (labels, branch rules, etc.)

2. **Ashfall-Sprint-0.md** (or equivalent milestone tracker)
   - Add new milestone section with issue numbers and PR list
   - Update M3/M4 status to reflect current open/blocked state
   - Increment section numbers as needed

3. **Ashfall-Architecture.md**
   - Add new systems introduced in the milestone
   - Include API documentation and autoload details
   - Link to relevant scene files or implementation

4. **Ashfall-GDD.md**
   - Add implementation notes for designed systems now shipped
   - Note when mechanics or features move from "vision" to "complete"

5. **Team.md** (or equivalent)
   - Update team size if agents were added/removed
   - Note any changes to review process or responsibility boundaries

### Process

1. Assign one agent (recommend: Mace or Scribe) to wiki update task
2. Clone wiki repo to temp location
3. Update all relevant pages in a single commit
4. Push with message: `docs: Update wiki for [Milestone Name] completion`
5. Verify wiki renders correctly on GitHub

### Success Criteria

- ✅ All 5 pages updated with relevant information
- ✅ Links are correct and cross-references work
- ✅ Commit includes Co-authored-by trailer
- ✅ Push succeeds and wiki GitHub page reflects changes within 5 minutes

---

**Owner:** Mace  
**Next Action:** Schedule wiki update task immediately after each future milestone closure
