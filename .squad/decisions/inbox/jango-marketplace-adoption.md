# Decision: Marketplace Skill Adoption

**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-23  
**Status:** Implemented

## Context

Our `.squad/skills/` directory contained 31 custom skills built in-house for our game dev workflow. The `github/awesome-copilot` and `anthropics/skills` repos offer community-maintained skills covering general development workflows (PRDs, refactoring, context mapping, commit conventions, issue management, etc.) that complement our domain-specific skills.

## Decision

Installed 9 marketplace skills into `.squad/skills/`:

| Skill | Source | Purpose |
|-------|--------|---------|
| `game-engine-web` | github/awesome-copilot | Web game engine patterns (HTML5/Canvas/WebGL) |
| `context-map` | github/awesome-copilot | Map relevant files before making changes |
| `create-technical-spike` | github/awesome-copilot | Time-boxed spike documents for research |
| `refactor-plan` | github/awesome-copilot | Sequenced multi-file refactor planning |
| `prd` | github/awesome-copilot | Product Requirements Documents |
| `conventional-commit` | github/awesome-copilot | Structured commit message generation |
| `github-issues` | github/awesome-copilot | GitHub issue management via MCP |
| `what-context-needed` | github/awesome-copilot | Ask what files are needed before answering |
| `skill-creator` | anthropics/skills | Create and iterate on new skills |

## Naming Convention

When a marketplace skill name collides with an existing local skill, the marketplace version gets a suffix (e.g., `game-engine` → `game-engine-web` because we already had `web-game-engine`).

## Also Fixed

- **squad.config.ts routing**: Was all `@scribe` placeholder. Now routes to correct agents per work type.
- **squad.config.ts casting**: Was wrong universe list. Now `['Star Wars']`.
- **squad.config.ts governance**: Enabled `scribeAutoRuns: true`, added `hooks` with write guards, blocked commands, and PII scrubbing.

## Risks

- Marketplace skills may diverge from upstream — no auto-update mechanism yet. Manual re-fetch needed.
- `skill-creator` from anthropics is large (33KB) — may need trimming if it causes context bloat.

## Follow-up

- Monitor which marketplace skills agents actually invoke — prune unused ones after 2 sprints.
- Consider building a `skill-sync` tool if we adopt more marketplace skills.
