# Contributing to First Frame Studios

Welcome to our squad-driven game development process. This guide explains how we work at First Frame Studios.

## Work Flow

All work at First Frame Studios follows a GitHub-centered flow:

```
1. Issue Created (with labels)
       ↓
2. Squad Agent Picks Up Work
       ↓
3. Branch Created (squad/{issue-number}-{slug})
       ↓
4. Development & Commits
       ↓
5. Pull Request Opened
       ↓
6. Automated Checks & Squad Review
       ↓
7. Merge to main
```

## Creating an Issue

1. Go to [Issues](https://github.com/jperezdelreal/FirstFrameStudios/issues)
2. Click "New Issue"
3. **Title:** Clear, specific description (e.g., "Fix canvas rendering lag on resize")
4. **Labels:** Apply appropriate labels (see [Label System](#label-system) below)
5. **Body:** Include:
   - Problem statement or user story
   - Acceptance criteria
   - Related issues or dependencies
6. Create

## Branch Naming

When creating a branch for an issue:

```
squad/{issue-number}-{slug}
```

**Examples:**
- `squad/42-player-knockback-tuning`
- `squad/105-canvas-memory-leak`

This naming convention:
- Ties code back to issues automatically
- Makes work visible in PRs
- Enables cross-repo tracking

## Commit Message Format

Use clear, descriptive commit messages:

```
[Game/System] Brief description

- Bullet point of what changed
- Another change or why

Fixes #42
Co-authored-by: [Agent Name] <agent+email@github>
```

**Examples:**
```
[ComeRosquillas] Fix canvas resize handling

- Added debounce to resize event listener
- Prevent rendering during resize operations
- Verified canvas dimensions update correctly

Fixes #42
Co-authored-by: Solo <solo@firstframe.dev>
```

```
[Flora] Add particle system for power-ups

- Implemented PixiJS particle emitter for collectibles
- Particle color matches power-up type
- Performance tested with 100+ simultaneous particles

Fixes #88
Co-authored-by: Jango <jango@firstframe.dev>
```

## Label System

Labels organize work by agent, priority, tier, and blockers. Apply these to every issue:

### Squad Tags (required for agent pickup)
Agent-based labels for work assignment:
- `squad:solo` — Architecture, system design, integration
- `squad:jango` — Tooling, CI/CD, build configuration
- `squad:mace` — Production, sprint planning, blocker tracking
- `squad:ralph` — Autonomous monitoring agent
- `squad:copilot` — General development support

### Priority Tags (required for scheduling)
Priority determines execution order:
- `priority:P0` — Blocker — Critical issue preventing progress
- `priority:P1` — Sprint-critical — Must ship this sprint
- `priority:P2` — Normal — Default priority for most work
- `priority:P3` — Nice-to-have — Low priority, future work

### Tier Tags (approval authority)
Tier determines who approves the work:
- `tier:t0` — Founder approval required (new games, principles changes)
- `tier:t1` — Lead approval (Solo decides, no founder escalation)
- `tier:t2` — Agent autonomy (implement and merge)
- `tier:t3` — Documentation/polish (no review needed)

### Blocked-By Tags (dependency tracking)
Five types of blockers:
- `blocked-by:issue` — Waiting on another issue to close
- `blocked-by:pr` — Waiting on PR to merge
- `blocked-by:decision` — Waiting on team decision
- `blocked-by:upstream` — Waiting on external dependency/library
- `blocked-by:external` — Waiting on 3rd party (vendor, API, etc.)

## How Squad Agents Pick Up Work

Ralph monitors the repository and assigns issues to squad agents:

1. **Ralph monitors Issues** — Scans for ready work across hub and downstream repos
2. **Checks dependencies** — Filters out issues with `blocked-by:*` labels where blockers are still open
3. **Sorts by priority** — Orders by `priority:P0 > P1 > P2 > P3`
4. **Assigns to agent** — Based on `squad:{member}` label
5. **Agent creates branch** — Names it `squad/{issue-number}-{slug}`
6. **Agent opens PR** — Links back to issue (`Fixes #XX` in body)
7. **Reviews and merges** — Closes issue automatically on merge

## Pull Request Process

1. **Push branch** to remote
2. **Create Pull Request** with:
   - Title: Same as issue title
   - Body: Link to issue (`Fixes #XX`)
   - Assignee: The squad member(s) doing the work
   - Labels: Same labels as issue
3. **Verify checks pass** — GitHub Actions runs automated tests
4. **Wait for review** — Squad Lead (Solo) or domain expert reviews
5. **Address feedback** — Push new commits to same branch
6. **Merge** — Squash or rebase to keep history clean

## Code Review Standards

Jango (Tool Engineer) reviews PRs for:

- **Correctness** — Does it solve the issue?
- **No Regressions** — Did it break existing functionality?
- **Documentation** — Are changes documented?
- **Test Coverage** — Are new features tested?
- **Standards Compliance** — Does it follow project conventions?

## Workflow Dependencies

If your issue depends on another issue:

1. Add a `blocked-by:*` label (issue, pr, decision, upstream, or external)
2. Add `## Dependencies` section in issue body listing what it's waiting on
3. Ralph automatically tracks blockers and prepares (but doesn't merge) blocked work
4. When blocker resolves, Ralph auto-unblocks after 24h (Lead can re-block if needed)

## Studio Tools & Infrastructure

- **HTML/JS/Canvas** — ComeRosquillas (vanilla web game, no bundler)
- **TypeScript/Vite/PixiJS** — Flora (modern web game with bundler)
- **GitHub Actions** — Automated builds, tests, and deployments
- **GitHub Issues** — Work tracking
- **GitHub Projects** — Sprint planning
- **.squad/ folder** — Team charters, decisions, skill library

## Questions?

- **Process:** Check `.squad/team.md` for team structure
- **Architecture:** See `.squad/decisions.md` for technology choices
- **Design:** Review `.squad/identity/` for studio playbooks
- **Game-specific docs:** Each game has its own repository with dedicated documentation
