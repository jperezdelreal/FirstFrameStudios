# Parallel Agent Workflow

## Metadata
- **Confidence:** high
- **Domain:** DevOps, Git, Multi-Agent Coordination
- **Last validated:** 2026-03-08
- **Source:** Ashfall M1+M2 parallel execution + github-pr-workflow SKILL + Solo integration audit
- **has_reference:** true

## Context

Five agents work simultaneously on the same codebase without blocking each other. Success requires strict file ownership (no two agents edit the same file), disciplined branching (always from latest main), and a mandatory integration gate after each wave of merges. Violations cause merge conflicts, orphaned code, and broken systems post-merge.

## Core Patterns

### Branching — Always from Latest Main
```powershell
git checkout main && git pull origin main
git checkout -b squad/{issue}-{name}
```
Verify ancestry: `git merge-base --is-ancestor HEAD origin/main` (exit 0 = safe). Branching from stale or non-main branches creates unreachable code and circular dependencies.

### File Ownership — One Owner Per File
No two agents edit the same file in parallel. Assign every file an explicit owner before the wave starts. If a shared edit is required: one agent edits → PR → merge → other agent pulls main → edits on new branch.

### Shared Config Gatekeeper
`project.godot` (or any shared config) is edited by exactly ONE designated agent per wave. That agent collects all requests (autoloads, input map, collision layers), commits them in a single PR, and all other branches rebase after merge.

### PR Template with Issue Closure
`Closes #N` must appear in the PR **body** (not title) for auto-close. Use the repo's PR template with Issue, Description, Changes, Testing, and Checklist sections.

### Integration Gate (Required Post-Wave)
After all wave PRs merge, an integration agent verifies: signals connected, autoloads ordered and instantiated, scene references valid, input map complete, collision layers match docs, state machines initialized, project runs end-to-end. **Next wave is blocked until gate passes.**

### Environment Setup
Refresh PATH before using `gh` CLI in spawned agents:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Commit Format
```
[M{N}] Brief description

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

## Key Examples

**Parallel wave kickoff:**
```powershell
# Each agent independently:
git checkout main && git pull origin main
git checkout -b squad/7-fighter-states
# ... implement assigned files only ...
git add -A && git commit -m "[M1] Add fighter state machine with 8 states

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push -u origin squad/7-fighter-states
gh pr create --title "[M1] Fighter state machine" --body "Closes #7
## Description
Implements 8 fighter states with frame-counted transitions.
## Testing
- All states tested in isolation" --base main
```

**Cherry-pick fallback** (when rebase would require 5+ conflict resolutions):
```powershell
git checkout main && git pull origin main
git cherry-pick abc123 def456
git push origin main
```
Prefer rebase+merge to preserve review trail; cherry-pick only as last resort.

## Anti-Patterns

- **Branching from feature branches** — creates orphaned code (M1+M2: PR #17 branched from scaffold branch after it merged, code became unreachable)
- **Multiple agents editing shared config** — 100% merge conflict rate (M1+M2: 4 agents all added autoloads to project.godot simultaneously)
- **Skipping integration gate** — systems compile individually but fail together (M1+M2: RoundManager never instantiated, orphaned signals, broken scene references)
- **`Closes #N` in PR title only** — issues don't auto-close; must be in body
- **Cherry-pick without documentation** — breaks review trail (M1+M2: PR #22 cherry-picked, closed but never formally merged)
- **Assuming `gh` is in PATH** — spawned agents inherit stale environment; always refresh first
