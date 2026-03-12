# Decision: Priority & Dependency System — T1 Approved

**By:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-26  
**Tier:** T1 (Lead authority — no Founder approval required)  
**Status:** Approved & Implemented

---

## Decision

Implement the Priority & Dependency System into FFS governance and routing documentation. This adds execution priority (P0-P3), dependency tracking (blocked-by:* labels), and the "prepare-but-don't-merge" rule for blocked work.

## Scope

| File | Change |
|------|--------|
| `.squad/identity/governance.md` | Added §2.5 Execution Priority (priority levels, tier≠priority, assignment, dependencies, emergency interaction) |
| `.squad/identity/governance.md` | Added guardrails G13, G14, G15 to §7 |
| `.squad/routing.md` | Extended Lead Triage checklist (points 6-7: priority + dependencies) |
| `.squad/routing.md` | Added Priority-Aware Routing section (processing order, dependency labels, priority labels) |

## Rationale

Founder directive identified 6 governance gaps: no priority labels, no dependency tracking, no blocked-work mode, no triage for dependencies, no Ralph dependency checking, no emergency vs sprint distinction. Design phase completed with all 5 Founder open questions resolved.

## Key Principles

1. **Tier ≠ Priority** — Independent axes. Tier = who approves. Priority = when it runs.
2. **Prepare but don't merge** — Blocked agents write tests and scaffold, but cannot merge until blocker resolves.
3. **Strict P0-P3** — No extensions. Zone B projects inherit exactly.
4. **Advisory G13** — No CI enforcement on priority inflation. Lead judgment prevails.
5. **Emergency ≠ P0** — Emergency Authority is for active crises. P0 is for blocking work.

## Founder Decisions Incorporated

1. Strict P0-P3 labels (no extensions)
2. Emergency follow-up auto-labeled P1
3. G13 advisory only (no CI enforcement)
4. Ralph auto-unblocks after 24h
5. No preemption for P0 (finish current task first)
