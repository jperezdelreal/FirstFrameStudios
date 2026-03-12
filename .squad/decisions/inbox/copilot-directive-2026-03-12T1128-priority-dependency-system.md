### 2026-03-12T11:28: Priority & Dependency System Proposal
**By:** Joaquín (Founder, via Copilot)
**Status:** Proposal — needs Solo design session
**Why:** Governance has Tiers (who approves) but no Priorities (what runs first) or dependency tracking. This causes risk of wasted work when T2 tasks run ahead of unresolved T1 decisions.

## Gap Analysis

1. **No priority labels** — P0-P3 don't exist in issues or routing
2. **No dependency tracking** — Ralph assigns work without checking if prerequisites are met
3. **No "prepare but don't merge" mode** — agents implement and merge; no draft-hold state
4. **Lead triage doesn't evaluate dependencies** — Solo assigns `squad:{member}` but not `blocked-by`
5. **No emergency vs sprint distinction** in Ralph's work queue
6. **Tier ≠ Priority** — T0 is not always P0; T2 can be P0 (critical bug)

## Proposed Model

### Priority (execution order)
| Priority | Meaning | Ralph behavior |
|----------|---------|----------------|
| P0 | Blocker — nothing advances without this | Process FIRST. Hold other assignments |
| P1 | Sprint-critical — affects current sprint | Parallel with P0 prep, but no merge until P0 resolved |
| P2 | Normal backlog | Standard queue |
| P3 | Nice-to-have | Last in queue |

### Dependency Rule
> If a T2 task depends on a pending T1 decision, the agent may PREPARE (scaffold, tests, spike) but NOT MERGE production code until the T1 decision is approved.

### Implementation Points
- GitHub labels: `priority:P0`, `priority:P1`, `priority:P2`, `priority:P3`
- GitHub labels: `blocked-by:#N` or `needs-decision:T1`
- Lead triage step: evaluate dependencies before assigning `squad:{member}`
- Ralph Step 2: check `blocked-by` before spawning agents
- Spawn prompt addition: `BLOCKED: This issue is blocked by #N. You may prepare (tests, scaffold) but do NOT merge.`

## Needs Design By
Solo (Lead) — T1 decision. Full design in a dedicated session covering:
- Governance §2 update (priority definitions)
- Ralph reference update (dependency-aware scanning)
- Lead triage checklist update
- Label automation (sync-squad-labels.yml)
