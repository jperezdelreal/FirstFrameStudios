# Decision Record Template

> Use this format for all T0 and T1 decisions recorded in `.squad/decisions.md`.
> T2 decisions are recorded in agent `history.md` and commit messages. T3 needs no record.

## Template

### {DATE}: {Decision Title}

**Author:** {who proposed}
**Tier:** T0 | T1
**Status:** Proposed | Active | Implemented | Superseded
**Scope:** {which repos and agents are affected}

**What:** {clear, actionable description of the decision}

**Why:** {rationale — explain the reasoning}

**Impact:** {who needs to change what}

---

## Usage Notes

- Agents write proposals to `.squad/decisions/inbox/{agent}-{slug}.md` using this format
- Scribe merges approved decisions into `.squad/decisions.md`
- T0 decisions require Founder approval before status changes to Active
- T1 decisions require Lead (Solo) approval
- Status "Superseded" must reference the replacing decision
