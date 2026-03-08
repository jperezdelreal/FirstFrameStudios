# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Game engine, loop, timing, systems | Chewie | Game loop, renderer, input, animation system, event bus, particles |
| Player mechanics, combat, combos | Lando | Player entity, combo system, jump attacks, special moves, grab/throw |
| Enemy AI, bosses, content, pickups | Tarkin | Enemy types, boss patterns, wave design, pickups, difficulty, levels |
| UI, canvas, HUD, menus, screens | Wedge | HUD, title screen, game over, pause, score displays, transitions |
| VFX, art, characters, backgrounds | Boba | Character art, backgrounds, impact VFX, animations, particles |
| Audio, SFX, music, sound design | Greedo | Sound effects, procedural music, audio events, Web Audio API |
| QA, playtesting, balance, feel | Ackbar | Playtesting, combat feel, balance tuning, regression, edge cases |
| Tooling, scaffolding, templates, conventions | Jango | EditorPlugins, scene templates, GDScript style guide, build/export automation, project.godot config, linting, asset pipelines |
| Architecture, integration, review | Solo | Project structure, code review, integration, decisions, scene tree conventions, architecture reviews |
| Scope & priorities | Solo | What to build next, trade-offs, backlog prioritization |
| Sprint planning, timelines, workload | Mace | Sprint planning, milestone tracking, scope management, developer joy, release planning |
| Feature triage, scope decisions | Yoda + Mace | Vision Keeper (Yoda) + Producer (Mace) evaluate features against four-test framework |
| Async issue work (bugs, tests, small features) | @copilot 🤖 | Well-defined tasks matching capability profile |
| Session logging | Scribe | Automatic — never needs routing |

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

## Integration & Quality Gates

| Work Type | Route To | Trigger |
|-----------|----------|---------|
| Integration verification (post-wave) | Solo (Architect) | After every parallel agent wave — verify systems connect, signals wired, project loads |
| GDD spec compliance in PR reviews | Jango (Tool Engineer) | Every PR that implements a GDD-specified system — compare code against GDD before approving |
| Post-merge smoke test | Ackbar (QA/Playtester) | After milestone PRs merge — open Godot, run full game flow, verify end-to-end |
| Branch management & base validation | Mace (Producer) | Before spawning parallel agents — verify all branches target main, base branch is current |

### Why These Exist

These gates were added after M1+M2 retrospective revealed that:
- **Integration was nobody's job.** 5 blockers (RoundManager not instantiated, signals not wired, state machine won't start) reached code review undetected because no agent owned "do systems work together?"
- **Spec validation didn't happen.** GDD specified 6 buttons, only 4 were implemented. Nobody compared code against the GDD before merging.
- **Nobody tested the game.** 8 PRs merged across two milestones without anyone opening Godot. The project was never verified to run.
- **Branch management was unowned.** AI controller (298 LOC) was stranded on a dead branch because nobody validated the PR target branch.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. The Lead handles all `squad` (base label) triage.
8. **@copilot routing** — when evaluating issues, check @copilot's capability profile in `team.md`. Route 🟢 good-fit tasks to `squad:copilot`. Flag 🟡 needs-review tasks for PR review. Keep 🔴 not-suitable tasks with squad members.
