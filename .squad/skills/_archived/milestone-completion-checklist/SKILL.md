---
name: "milestone-completion-checklist"
description: "8-step post-milestone process for team closure, tracking, and next-cycle planning"
domain: "process"
confidence: "medium"
source: "Ashfall M1+M2 retrospective + Joaquín/Mace directives"
has_reference: true
---

## Context
A milestone isn't done when code merges — it's done when team has closure, next work is planned, and no loose ends. 8-step process takes 4-6 hours total, prevents post-milestone chaos.

## Core Patterns

1. **Merge all PRs** — From latest main, include `Closes #N` in body, ≥1 approval, merge commit method
2. **Verify auto-close** — All closed issues show "Closed via PR #XYZ". If not, investigate
3. **Update wiki (Mace automatic)** — Home.md, Sprint.md, Architecture.md, GDD.md, Team.md
4. **Post dev diary (Mace automatic)** — GitHub Discussions: pitch, shipped, numbers, next, meta, CTA
5. **Run retrospective (Jango facilitated)** — 90min meeting, document in `RETRO-M{X}.md`, extract action items to `.squad/decisions/inbox/`
6. **Clean stale branches** — Delete merged branches locally and remotely. Document if kept
7. **Update `.squad/identity/now.md`** — Current focus, status (✅/🔜/📋), recent retrospective, active directives
8. **Create next milestone issues** — Review retro actions, define scope, create 6-12 issues with acceptance criteria

## Key Examples

**Timeline (M2→M3):**
- 14:00 — Merge all PRs
- 14:15 — Verify `Closes #N`
- 16:00 — 90min retrospective
- 17:30 — Clean branches
- 18:00 — Update now.md
- 18:30 — File M3 issues
- 19:00 — ✅ Complete

**Common gotcha:** `Closes #N` in PR title alone doesn NOT auto-close. Must be in body.

## Anti-Patterns

- **Skipping retrospective** — Lessons lost, same mistakes repeat
- **Stale branches accumulate** — Confusion about what's merged
- **No next milestone planning** — Team blocked waiting for direction
- **Manual wiki/diary without check** — Forgotten or duplicated
