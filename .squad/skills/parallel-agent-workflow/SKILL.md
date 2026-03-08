# Parallel Agent Workflow

## Metadata
- **Confidence:** high
- **Domain:** DevOps, Git, Multi-Agent Coordination
- **Last validated:** 2026-03-08
- **Source:** Ashfall M1+M2 parallel execution + github-pr-workflow SKILL + Solo integration audit (validates necessity)

## Pattern

Five agents working simultaneously on the same codebase without blocking each other. This requires discipline around branching, file ownership, and merge workflow.

### 1. All Agents Branch from LATEST main

**Critical:** Before any agent creates a feature branch, they must pull the latest main and verify they're at HEAD.

**Workflow:**
```powershell
git checkout main
git pull origin main
git log --oneline -1                    # Verify you're at latest
git checkout -b squad/{issue}-{name}    # Create feature branch from LATEST
```

**Why this matters:**
- If an agent branches from an old main commit, their PR will have merge conflicts with newer commits
- If an agent branches from a non-main branch (e.g., `squad/1-godot-scaffold`), they may end up on a dead branch or create circular dependencies
- **Evidence from M1+M2:** PR #17 (AI opponent) branched from `squad/1-godot-scaffold` AFTER scaffold was already merged to main. The AI code was correct but unreachable.

**Verification:**
```powershell
git merge-base --is-ancestor HEAD origin/main
# If this returns exit code 0, your branch is descended from main. Safe to go.
# If exit code 1, you branched from something else. Rebase onto main.
```

### 2. Each Agent Owns Specific Files — No Two Agents Edit the Same File

File ownership prevents simultaneous edits to the same file, which cause merge conflicts.

**From Ashfall architecture:**

| File | Owner | Reason |
|------|-------|--------|
| `project.godot` | Jango (gatekeeper) | Shared by entire project; only ONE agent modifies it per wave |
| `src/fighters/fighter_base.gd` | Chewie | Defines base class for all fighters |
| `src/fighters/states/*.gd` (8 files) | Chewie | All fighter state logic |
| `src/input/fighter_controller.gd` | Lando | Translates input → fighter actions |
| `src/input/input_buffer.gd` | Lando | Frame-based input buffering |
| `src/input/motion_detector.gd` | Lando | Converts stick input to numpad notation |
| `src/systems/event_bus.gd` | Solo | Singleton signal bus |
| `src/systems/game_state.gd` | Solo | Game phase tracking |
| `src/scenes/stages/ember_grounds.tscn` | Leia | Stage scene and script |
| `src/scenes/ui/fight_hud.tscn` | Wedge | HUD scene and script |
| `src/systems/vfx_manager.gd` | Bossk | All visual effects |
| `src/systems/audio_manager.gd` | Greedo | All audio synthesis + playback |
| `src/ai/ai_controller.gd` | Tarkin | AI opponent logic |

**Rule:** Two agents never edit the same file in parallel. If agent A owns `fighter_controller.gd`, agent B cannot touch it without coordinating with A.

**When files MUST be shared (rare):**
1. Pre-coordinate in `.squad/decisions/inbox/` who edits what and in what order
2. One agent makes the edit, creates PR, waits for merge
3. Other agent pulls updated main, then makes their edit on a new branch from latest main

**Verification:**
```powershell
git diff --name-only main..HEAD   # List files changed on this branch
# Verify none of these files are "owned" by another active agent
```

### 3. project.godot Is the #1 Conflict Source — Designate ONE Agent Per Wave

`project.godot` is a single INI file that holds autoloads, input map, physics config, and rendering settings. Multiple agents adding entries in parallel branches causes 100% merge conflicts.

**Evidence from M1+M2:**
- Agents Chewie, Lando, Wedge, Greedo all created autoload entries (EventBus, GameState, VFXManager, AudioManager)
- All 4 branches added to the same [autoloads] section
- Merging sequentially required rebasing each branch after each merge

**Rule:** Exactly ONE agent per wave modifies `project.godot`. All other agents work around it.

**Workarounds if you need to add an autoload but aren't the designated agent:**
- Instead of adding to `project.godot`, have Jango add it in a single PR that stages all autoloads at once
- You create the script; Jango registers it in one coordinated commit
- Alternative: Register the autoload at runtime in `_enter_tree()` (not recommended, but possible)

**If you ARE the designated agent for project.godot edits:**
1. Coordinate with other agents before branching
2. Collect all their requests: "add this autoload," "add this input," "add this collision layer"
3. Add them all in one commit to `project.godot`
4. Create a single PR titled `[M{N}] Update project.godot: autoloads, input map, physics config`
5. Include detailed PR body explaining every change
6. After merge, all other branches rebase: `git rebase main && git push --force-with-lease`

**Verification:**
```powershell
git log --oneline origin/main | grep "project.godot"
# Should see only 1–2 commits per milestone modifying project.godot
```

### 4. Use the PR Template — Include `Closes #N` in the Body

Every PR must follow GitHub's PR template and include the GitHub issue closure syntax.

**Template (from `.github/pull_request_template.md`):**

```markdown
## Issue
Closes #7

## Description
[Brief summary of what this PR does]

## Changes
- [Specific change 1]
- [Specific change 2]

## Testing
- [How to verify this works]

## Checklist
- [ ] Code follows project conventions
- [ ] No merge conflicts
- [ ] project.godot verified (if applicable)
- [ ] Godot project opens without errors (if applicable)
```

**Critical:**
- `Closes #7` MUST be in the PR **body**, not the title
- GitHub only auto-closes issues when `Closes`, `Fixes`, or `Resolves` appears in the PR description
- If you put `Closes #7` only in the title, the issue does NOT auto-close when the PR merges

**Example workflow:**
```powershell
gh pr create \
  --title "[M2] Audio Manager: procedural SFX synthesis" \
  --body "Closes #11

## Description
Implements 14 distinct game sounds via AudioStreamGenerator. No external audio files.

## Changes
- audio_manager.gd (495 LOC): sound generation, pitch jitter, BPM-locked background track
- 3 mix buses: Announcer > SFX > Music

## Testing
- Tested all 14 sounds in isolation
- Tested mix bus routing with EventBus signals
- Verified EventBus integration" \
  --base main
```

**Verification:**
1. Create the PR
2. Check that the GitHub PR page shows "Closes #11" in the description
3. Merge the PR
4. Verify issue #11 auto-closes (you'll see "Closed via PR #22" in the issue timeline)

### 5. Refresh `$env:Path` Before Using gh CLI

When spawned agents or subshells need to use `gh` CLI, the PowerShell `$env:Path` may not be inherited from the parent session. The gh binary may not be found.

**Symptom:**
```powershell
gh pr create ...
# gh: command not found
```

**Fix:** Refresh PATH at the start of any agent session that uses gh:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

gh --version  # Verify it works now
gh pr list    # Should show PRs
```

**Why this happens:**
- The user's PowerShell session may have gh in PATH
- But when a sub-agent is spawned (via Copilot task spawning), its PowerShell environment doesn't automatically inherit the latest PATH
- Environment variables need to be refreshed from the Windows registry (Machine + User scopes)

**Prevention:**
- Any time you use gh CLI, start with the PATH refresh command above
- Don't assume gh is available; verify with `gh --version` after refreshing

### 6. Cherry-Pick as Conflict Resolution Fallback

When a PR branch has diverged too far from main (multiple merge conflicts, complex rebasing required), cherry-picking is cleaner than rebasing.

**When to use cherry-pick:**
- A PR has multiple small, independent commits that could apply cleanly to main
- The branch includes commits from other unmerged branches (creates circular dependency)
- Rebasing would require resolving 5+ merge conflicts across many files
- The original PR is already reviewed and approved; you just need the code on main

**Workflow:**

1. **Close the original PR** with a comment:
   ```
   Closing in favor of cherry-pick approach. Will apply commits abc123..def456 onto main to avoid complex rebasing.
   ```

2. **Cherry-pick the commits:**
   ```powershell
   git checkout main
   git pull origin main
   git cherry-pick abc123 def456  # Pick specific commits from the closed branch
   ```

3. **Verify the cherry-picks applied cleanly:**
   ```powershell
   git log --oneline -5  # Should show the picked commits at the top
   git diff HEAD~2 HEAD  # Verify the changes look correct
   ```

4. **Push to main:**
   ```powershell
   git push origin main
   ```

5. **Verify the issue closes:**
   - If the original PR had `Closes #N` in the description, the issue auto-closes
   - If it didn't, manually close the issue with a comment referencing the cherry-pick commit

**Evidence from M1+M2:**
- PR #22 (AudioManager) was cherry-picked instead of merged via PR
- This broke the review trail; the PR was closed but never merged to main
- Code reached main, but without a linked PR or review history
- **Better approach:** Rebase PR #22, re-push, let GitHub detect the commit as already reviewed

**Recommendation:**
- Only use cherry-pick if normal rebase + merge would require >3 hours of conflict resolution
- Prefer rebasing + re-merging when possible (maintains review trail)

### 7. Commit Message Format

Every commit should include a clear message and the Co-authored-by trailer.

**Format:**
```
[M{N}] Brief description of the change

Detailed explanation if needed. Keep to 72 characters per line.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Examples from M1+M2:**

```
[M1] Add fighter state machine with 8 states

Implements idle, walk, crouch, jump, attack, block, hit, ko states.
Each state has enter(), exit(), and physics_update() with frame counting.
Timeout safety nets prevent dead-end states.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

```
[M2] Integrate audio manager with EventBus

Connects AudioManager to combat signals: hit, round_start, ko.
Implements procedural sound generation: 14 sounds, 3 mix buses, pitch jitter.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### 8. Integration Gate After Every Wave — REQUIRED

**Critical pattern (validated by Solo integration audit):** After merging a parallel wave of PRs, an integration agent (architect or tech lead) MUST verify the systems connect. This is NOT optional — it gates the next wave of work.

**Evidence from M1+M2:** Multiple systems were built in parallel (RoundManager, EventBus, GameState, AudioManager, VFXManager), merged to main, and then discovered to have integration gaps:
- RoundManager was never instantiated → round system non-functional
- Signals defined but not emitted in all necessary places
- Autoload order dependencies not tested
- Collision layers documented incorrectly vs implemented
- Scene references broken after script refactors

**Post-wave integration checklist (required gate):**

Before approving any work on the next milestone:

- [ ] **Signals connected**: Every EventBus signal emitted in one system is connected and consumed in at least one other system. No orphaned signals.
- [ ] **Autoloads ordered**: All systems are in correct dependency order in `project.godot` [autoloads]. EventBus first, flow managers (RoundManager) early, consumers late.
- [ ] **Autoloads instantiated**: Game-critical autoloads (RoundManager, GameState) are registered in `project.godot` AND initialized (e.g., `RoundManager.start_match(fighter1, fighter2)` is called).
- [ ] **Scenes reference valid scripts**: All `ext_resource` paths in `.tscn` and `.tres` files resolve to existing files. No red "broken reference" icons in Godot editor.
- [ ] **Input map complete**: All inputs defined in GDD are registered in `project.godot` [input_map]. Controller code doesn't reference non-existent inputs.
- [ ] **Collision layers match docs**: Documentation accurately describes the collision scheme used in `project.godot` and scene files. All physics nodes have explicit collision_layer and collision_mask set.
- [ ] **State machines initialized**: Every state machine has an explicit `initial_state` set in the scene or transitions to it in `_ready()`. Fighters don't freeze on spawn.
- [ ] **Project opens in Godot**: Load the project in Godot 4.6, play a test round, verify all systems initialize without errors and game runs end-to-end.

**Workflow:**
1. All PRs in wave merge to main
2. Integration agent (Solo) checks out main and runs the integration checklist
3. If any item fails, file issues and block next wave until fixed
4. If all items pass, document the pass in `.squad/decisions/` and clear the gate
5. Only then can the next wave of parallel work begin

**Time investment:** 20–30 minutes per integration gate. Prevents shipping broken systems post-merge and keeps velocity high.

## Parallel Execution Checklist

Before starting parallel work on a milestone:

- [ ] Latest main has been pulled by all agents
- [ ] File ownership is documented (who owns what)
- [ ] Designated agent for project.godot edits is chosen
- [ ] Integration architect is assigned to run post-wave gate
- [ ] Each agent knows their issue number and feature scope
- [ ] All agents will use the PR template with `Closes #N`
- [ ] All agents will refresh `$env:Path` before using gh CLI
- [ ] After first wave merges, integration gate runs BEFORE next wave starts
- [ ] Remaining branches will rebase before merging (if rebase conflicts occur)

## When to Apply

- Any time agents create parallel feature branches
- Any time multiple agents work on the same milestone
- Before merging any PR that modifies shared files (project.godot, autoloads, input map)
- When coordinating CI/CD or infrastructure changes

## Key Takeaway

**Parallel work is possible because of clear file ownership and disciplined branching.** All agents branch from latest main, own specific files, designate one gatekeeper for shared config, and follow the PR template. This avoids merge conflicts and keeps the main branch clean.
