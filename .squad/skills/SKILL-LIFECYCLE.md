# Skill Lifecycle

> How skills are created, promoted, and maintained across the studio.

## Skill Categories

| Category | Owned By | Example |
|----------|----------|---------|
| Studio-wide | Hub `.squad/skills/` | multi-agent-coordination, state-machine-patterns |
| Genre-specific | Hub (originated in project) | fighting-game-frame-data, pixijs-patterns |
| Local knowledge | Downstream repo | Architecture notes, debugging logs, project-specific config docs |

## Promotion Rule

If a local document contains knowledge that would benefit future projects, it MUST be generalized and promoted to a hub skill. Solo (Lead) decides whether knowledge is studio-worthy or project-specific.

Flow: Game Repo (learning) → Hub Skill (captured) → Future Game Repos (consumed)

## Lifecycle Phases

| Phase | Action | Authority |
|-------|--------|-----------|
| Creation | Agent identifies reusable pattern | T1 (Lead) for new hub skills |
| Authoring | Domain expert writes SKILL.md | T2 (assigned agent) |
| Review | Solo reviews for accuracy and scope | T1 (Lead) |
| Publication | Committed to hub .squad/skills/ | T1 (Lead) |
| Consumption | Downstream repos access via upstream | Automatic |
| Update | Expert updates with new learnings | T2 minor, T1 structural |
| Deprecation | Marked superseded or archived | T1 (Lead) |

## Confidence Levels

| Level | Meaning | Trigger |
|-------|---------|---------|
| low | First observation | Agent noticed a pattern worth capturing |
| medium | Confirmed | Multiple agents/sessions validated independently |
| high | Established | Consistently applied, well-tested, team-agreed |

Confidence only goes up, never down.

## Cascade Mechanics

Agents in downstream repos have access to:
1. All hub skills (via upstream relationship)
2. All local documentation (in their repo)
3. Their charter and history (from hub agent definitions)

Skills don't need copying to downstream repos. The upstream relationship makes them available.
