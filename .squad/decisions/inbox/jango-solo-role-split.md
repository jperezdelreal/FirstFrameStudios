# 2026-03-09: Solo role split — ops moved to Mace

**By:** Joaquín (via Copilot)

## What

Solo's role narrowed to pure architecture review. Operational tasks (blocker tracking, branch rebasing, stale issue management) moved to Mace.

## Why

Solo was overloaded. "Architecture review is deep work" — can't do it well while also running ops:
- Switching context between architecture design and blocker tracking breaks focus
- Deep work on integration patterns requires uninterrupted thinking
- Ops tasks are transactional (check, flag, resolve) and interrupt flow
- Mace already owns producer/coordination responsibilities; ops is a natural extension

## Changes

1. **Solo's charter updated:** Removed all ops/coordination responsibilities. Focus now: architecture definition, integration patterns, code structure, design review
2. **Mace's charter updated:** Added blocker tracking, branch rebasing, stale issue cleanup, rebase coordination
3. **Routing.md updated:** Ops-related tasks now route to Mace
4. **Note in Solo's charter:** "Ops tasks (rebases, blocker tracking, stale issues) are Mace's responsibility. Focus on deep architecture work."

## Decision Authority

- **Solo:** Pure architecture review, system design, integration patterns, code structure decisions
- **Mace:** Ops backbone — blocker unblocking, branch validation, issue cleanup, rebase coordination
