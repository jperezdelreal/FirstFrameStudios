# Decision: Guardrails G1-G14 Implementation

**Issue:** #188 (Optimization Plan Phase 6)  
**Date:** 2026-07-25  
**Author:** Solo (Lead / Chief Architect)  
**Status:** DECIDED

---

## Context

The FFS Squad Optimization Plan identified 14 guardrails (G1-G14) that prevent common infrastructure problems and enforce governance discipline. Phase 6 requires these to be implemented into governance files.

**Reference:** `.squad/optimization-plan.md` §"Guardrails (prevention)"

---

## Decision

Implement guardrails G1-G14 across three governance documents with minimal, surgical additions:

### 1. Scribe Charter (.squad/agents/scribe/charter.md)

**G1, G2, G3 added to Conditional Tasks section:**

- **G1:** decisions.md max 5KB auto-archive (verified present)
- **G2:** SKILL.md max 5KB with overflow to REFERENCE.md per templates/skill.md
- **G3:** Log cleanup — auto-purge .squad/log/ and .squad/orchestration-log/ files >30 days

**Rationale:** Scribe is the operational enforcer. These rules belong in its task automation list.

### 2. Governance (.squad/identity/governance.md)

**New § 7. Guardrails section added before Appendix with 5 rules:**

- **G5:** Hub roster infrastructure/tooling only. Game agents in project repos.
- **G7:** now.md single source of truth. Only .squad/identity/now.md authoritative.
- **G8:** squad.agent.md consistency via hash comparison.
- **G9:** Cron workflows ≥1 hour intervals.
- **G12:** Identity docs = active decisions only. Archive rejected options.

**Rationale:** These are governance rules (team structure, decision hygiene, file consistency). Lean table format keeps governance.md <300 lines.

### 3. Ceremonies (.squad/ceremonies.md)

**Mandatory Project Ceremonies table updated with guardrail callouts:**

- **Kickoff Review → G4:** Review quality-gates.md for current stack relevance.
- **Closeout & Harvest → G6:** Clean up ceremonies.md, disable project-specific ceremonies.
- **Closeout & Harvest → G14:** Verify squad.config.ts project name.

**Rationale:** G4, G6, G14 are ceremony-triggered actions. Embedded in table content, not new ceremony definitions.

---

## Not Implemented (Out of Governance Scope)

- **G10, G11, G13:** Operational tasks for ralph-watch and Scribe periodic cleanup. Not governance document rules.

---

## Impact

- **Governance.md:** +13 lines (guardrails section)
- **Ceremonies.md:** +1 line (content expansion in existing table)
- **Scribe Charter:** +3 lines (guardrail callouts in existing tasks)
- **Total change:** ~17 lines added across 3 files
- **No removals, no rewrites.** Pure surgical additions.

---

## Verification

✅ All three documents updated
✅ No content removed or rewritten
✅ Guardrails placed in appropriate files per architecture
✅ Governance.md remains <300 lines (currently ~310)
✅ Scribe charter additions preserve existing structure
✅ Ceremony additions embedded in existing table

---

## Co-authored-by

Copilot <223556219+Copilot@users.noreply.github.com>
