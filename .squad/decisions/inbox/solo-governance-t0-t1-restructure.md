# Decision: Governance T0/T1 Restructure — Founder Directives Applied

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-25  
**Status:** Implemented  
**Tier:** T0 (modifies T0 scope)  
**Scope:** Studio-wide — affects all repos, all agents, all approval flows

## What Was Decided

Per explicit Founder directives from Joaquín:

### 1. T0 Ultra-Minimized
T0 now contains **only two items**:
- Creating a new game repository (the founder's "capricho")
- Modifying studio principles (`principles.md`)

**Removed from T0:**
- Hub roster changes → moved to T1
- `.squad/` directory refactors → moved to T1
- Technology pivots → moved to T1
- Governance changes (unless modifying T0 scope) → moved to T1

### 2. T1 = Lead Authority Only
T1 no longer requires Founder approval. Solo (Lead) has full, permanent authority over all T1 decisions. The Founder does not participate in routine T1 approvals.

**What this means:**
- Solo can create tool repos, change quality gates, add/remove hub agents, refactor `.squad/`, update ceremonies, modify governance, and make all cross-repo architectural decisions without waiting for Founder sign-off.
- Agents may appeal T1 decisions to the Founder, but this is an exception path, not the default.

### 3. Delegation Rules Updated
New permanent rule: "T1 is fully delegated to Lead — no founder approval required for any T1 decision."

### 4. Governance Self-Governance Updated
- Changes to governance that don't modify T0 scope: T1 (Lead authority)
- Changes to governance that modify T0 scope: T0 (Founder only)

## Why

Joaquín's directive: **"FFS must be 99% autonomous. The founder decides WHAT games to make, not HOW."**

The previous governance had the Founder as a bottleneck on every T1 decision — tool repos, quality gates, skills, ceremonies, sprint scope, roster changes. This created an approval funnel through a single human for decisions that are reversible and within the Lead's domain expertise.

The hub is the Bible. Solo is its steward. The Founder's role is strategic direction (new games, principles), not operational governance.

## Impact

| Who | What Changes |
|-----|-------------|
| **Solo (Lead)** | Full T1 authority — no more "propose and wait for Founder" |
| **All agents** | T1 proposals go to Solo only. Faster turnaround on cross-repo decisions |
| **Joaquín (Founder)** | Only involved in T0 (new games, principles, archival, T0 scope changes) |
| **Mace (Producer)** | Sprint scope changes need Solo alignment, not Solo + Joaquín |
| **Jango (Tool Engineer)** | Tool repo creation approved by Solo only |

## Files Modified

- `.squad/identity/governance.md` — 20+ edits across all 9 domains + appendices
- `.squad/agents/solo/history.md` — learning entry added
