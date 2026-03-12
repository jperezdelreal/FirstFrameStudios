# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Architecture, integration review | Solo | Project structure, integration verification, decisions, architecture reviews |
| Tooling, CI/CD, workflows, build pipelines | Jango | GitHub workflows, ralph-watch, scheduler, Vite config, build automation |
| Ops, blockers, branch management | Mace | Blocker tracking, branch rebasing, stale issue cleanup |
| Sprint planning, timelines, workload | Mace | Sprint planning, milestone tracking, scope management |
| Feature triage, scope decisions | Mace | Scope decisions, feature evaluation |
| Async issue work (bugs, tests, features) | @copilot 🤖 | Well-defined tasks: HTML/JS/Canvas, TypeScript/Vite, PixiJS |
| Session logging | Scribe | Automatic — never needs routing |

## Multi-Repo Issue Routing

| Issue About | Goes To | Examples |
|-------------|---------|----------|
| ComeRosquillas gameplay/bugs | [jperezdelreal/ComeRosquillas](https://github.com/jperezdelreal/ComeRosquillas) | Ghost AI, scoring, maze layout, mobile controls |
| Flora gameplay/bugs | [jperezdelreal/flora](https://github.com/jperezdelreal/flora) | PixiJS systems, gardening mechanics, roguelite features |
| Squad Monitor features | [jperezdelreal/ffs-squad-monitor](https://github.com/jperezdelreal/ffs-squad-monitor) | Dashboard UI, heartbeat reader, log viewer |
| Studio infra / tooling | [jperezdelreal/FirstFrameStudios](https://github.com/jperezdelreal/FirstFrameStudios) | ralph-watch, scheduler, team changes, docs site |
| Cross-project process | [jperezdelreal/FirstFrameStudios](https://github.com/jperezdelreal/FirstFrameStudios) | Ceremonies, skills, team decisions, routing |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, evaluate @copilot fit, assign `squad:{member}` label | Lead |
| `squad:{name}` | Pick up issue and complete the work | Named member |
| `squad:copilot` | Assign to @copilot for autonomous work (if enabled) | @copilot 🤖 |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, the **Lead** triages it — analyzing content, evaluating @copilot's capability profile, assigning the right `squad:{member}` label, and commenting with triage notes.
2. **@copilot evaluation:** The Lead checks if the issue matches @copilot's capability profile (🟢 good fit / 🟡 needs review / 🔴 not suitable). If it's a good fit, the Lead may route to `squad:copilot` instead of a squad member.
3. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
4. When `squad:copilot` is applied and auto-assign is enabled, `@copilot` is assigned on the issue and picks it up autonomously.
5. Members can reassign by removing their label and adding another member's label.
6. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.

### Lead Triage Guidance for @copilot

When triaging, the Lead should ask:

1. **Is this well-defined?** Clear title, reproduction steps or acceptance criteria, bounded scope → likely 🟢
2. **Does it follow existing patterns?** Adding a test, fixing a known bug, updating a dependency → likely 🟢
3. **Does it need design judgment?** Architecture, API design, UX decisions → likely 🔴
4. **Is it security-sensitive?** Auth, encryption, access control → always 🔴
5. **Is it medium complexity with specs?** Feature with clear requirements, refactoring with tests → likely 🟡
6. **What is the priority?** (P0/P1/P2/P3) — Does this block production (P0)? Sprint commitment (P1)? Normal work (P2, default)? Polish (P3)?
7. **What are the dependencies?** — Does this depend on another open issue, a pending decision, upstream hub work, or a PR? If yes, add `blocked-by:*` label and document in issue body.

### Priority-Aware Routing

Ralph processes work in priority order: P0 Active > P1 Active > Untriaged > Assigned (by priority) > CI failures > Review feedback > Approved PRs > Blocked (prepare mode) > P3.

**Dependency labels** (required on all repos — Zone A):
| Label | Meaning |
|-------|---------|
| `blocked-by:issue` | Blocked by another issue (see body) |
| `blocked-by:pr` | Blocked by a PR merge (see body) |
| `blocked-by:decision` | Blocked by a pending decision (see body) |
| `blocked-by:upstream` | Blocked by hub/parent repo work (see body) |
| `blocked-by:external` | Blocked by third-party (see body) |

**Priority labels** (required on all repos — Zone A):
| Label | Meaning |
|-------|---------|
| `priority:P0` | Blocker — nothing advances without this |
| `priority:P1` | Sprint-critical — current sprint |
| `priority:P2` | Normal backlog (default if none assigned) |
| `priority:P3` | Nice-to-have |

Default priority: **P2** if no label assigned after triage.

## Integration & Quality Gates

| Work Type | Route To | Trigger |
|-----------|----------|---------|
| Integration verification (post-wave) | Solo (Architect) | After every parallel agent wave — verify systems connect, modules import correctly, app loads |
| Spec compliance in PR reviews | Jango (Tool Engineer) | Every PR that implements a spec-defined system — compare code against design doc before approving |
| Post-merge smoke test | Solo (Lead) | After milestone PRs merge — verify app loads, key flows work end-to-end |
| Branch management & base validation | Mace (Producer) | Before spawning parallel agents — verify all branches target main, base branch is current |

### Why These Exist

These gates were added after M1+M2 retrospective revealed that:
- **Integration was nobody's job.** Blockers reached code review undetected because no agent owned "do systems work together?"
- **Spec validation didn't happen.** Specs defined features that weren't fully implemented. Nobody compared code against the design doc before merging.
- **Nobody tested the game.** PRs merged without anyone testing in a browser. The game was never verified to run.
- **Branch management was unowned.** Code was stranded on dead branches because nobody validated the PR target branch.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. The Lead handles all `squad` (base label) triage.
8. **@copilot routing** — when evaluating issues, check @copilot's capability profile in `team.md`. Route 🟢 good-fit tasks to `squad:copilot`. Flag 🟡 needs-review tasks for PR review. Keep 🔴 not-suitable tasks with squad members.
9. **Multi-repo awareness** — check which repo the issue belongs to before routing. Game bugs go to game repos; infra/process goes to FFS hub.
