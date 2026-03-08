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
3. **Title:** Clear, specific description (e.g., "Fix camera jitter on dodge roll")
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
- `squad/88-ashfall-gdd-characters`
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
[ashfall] Fix Kael forward dash knockback distance

- Reduced knockback multiplier from 1.8x to 1.4x
- Verified balance against Rhena dash range
- Updated move data resource with new parameters

Fixes #42
Co-authored-by: Lando <lando@firstframe.dev>
```

```
[first-punch] Add screen shake on heavy attacks

- Integrated ShakeEffect system into CombatSystem
- Amplitude scales with damage dealt
- Verified camera remains centered after shake

Fixes #88
Co-authored-by: Lando <lando@firstframe.dev>
```

## Label System

Labels organize work by game, type, and priority. Apply these to every issue:

### Game Tags (required, one per issue)
- `game:ashfall` — Work on Ashfall fighting game
- `game:first-punch` — Work on First Punch beat 'em up
- `game:cinder` — Work on Cinder platformer (future)
- `game:pulse` — Work on PULSE rhythm-action (future)

### Squad Tags (required)
- `squad:engine` — Engine/Infrastructure work (Chewie, Jango)
- `squad:gameplay` — Gameplay mechanics & feel (Lando, Ackbar)
- `squad:art` — Visual assets & direction (Boba, Nien, Leia, Bossk)
- `squad:audio` — Sound design & music (Greedo)
- `squad:content` — Enemy design & encounters (Tarkin)
- `squad:ui` — User interface (Wedge)
- `squad:architecture` — System design & structure (Solo)
- `squad:tooling` — Build tools, CI/CD (Jango)

### Type Tags (optional)
- `type:feature` — New functionality
- `type:bug` — Issue to fix
- `type:refactor` — Code quality improvement
- `type:docs` — Documentation
- `type:design` — Design/spec work

### Priority Tags (optional)
- `priority:p0` — Critical / Blocking
- `priority:p1` — High / Next
- `priority:p2` — Medium / When ready
- `priority:p3` — Low / Future

### Status Tags (auto-applied by workflow)
- `status:ready` — Issue is refined, can be started
- `status:in-progress` — Work actively happening
- `status:blocked` — Waiting on external dependency
- `status:review` — PR opened, awaiting review

## How Squad Agents Pick Up Work

Squad agents watch GitHub for issues with `squad:*` labels matching their expertise:

1. **Squad polls Issues** — Daily check for issues with their label
2. **Filters by game** — Focuses on current sprint game (e.g., `game:ashfall`)
3. **Picks highest priority** — Orders by `priority:p0 > p1 > p2 > p3`
4. **Creates branch** — Names it `squad/{issue-number}-{slug}`
5. **Opens PR** — Links back to issue (`Fixes #XX` in body)
6. **Merges when approved** — Closes issue automatically

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

Squad agents review PRs for:

- **Correctness** — Does it solve the issue?
- **No Regressions** — Did it break existing functionality?
- **Load Compliance** — Does it respect the 20% load cap?
- **Documentation** — Are changes documented?
- **Test Coverage** — Are new features tested?

See individual game style guides:
- [Ashfall (Godot 4)](games/ashfall/STYLE.md)
- [First Punch (Canvas 2D)](games/first-punch/STYLE.md)

## Workflow Dependencies

If your issue depends on another issue:

1. Add comment: `Depends on #XX` (or whatever issue number)
2. Milestone label: `milestone:phase-1`
3. Mace (Producer) tracks critical path issues

## Load Capacity

Squad agents maintain **20% load cap** per phase. If your PR would push someone over:

1. Comment on PR: ⚠️ Load concern
2. Mace reviews & reallocates or defers
3. No merges until load is balanced

See `.squad/agents/{agent}/charter.md` for individual load tracking.

## Studio Tools & Infrastructure

- **Godot 4** — Engine for Ashfall
- **Canvas 2D** — Engine for First Punch (no build step)
- **GitHub Actions** — Automated builds & tests
- **GitHub Issues** — Work tracking
- **GitHub Projects** — Sprint planning
- **.squad/ folder** — Team charters, decisions, skill library

## Questions?

- **Process:** Check `.squad/team.md` for team structure
- **Architecture:** See `.squad/decisions.md` for technology choices
- **Design:** Review `.squad/identity/` for studio playbooks
- **Specific game:** See `games/{game}/docs/` for design docs
