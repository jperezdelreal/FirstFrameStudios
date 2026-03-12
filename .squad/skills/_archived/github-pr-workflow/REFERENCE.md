# GitHub PR Workflow

## Metadata
- **Confidence:** medium
- **Domain:** DevOps, GitHub, CI/CD
- **Last validated:** 2026-03-08

## Pattern

### 1. Parallel branches cause autoload conflicts in Godot
When multiple agents branch from the same base commit and each adds autoloads to project.godot, merging them sequentially creates conflicts in the [autoloads] section. Each agent adds their line to the same spot.

**Mitigation:** After merging the first PR, rebase remaining branches before merging. Or have agents coordinate to add autoloads in separate commits on a shared integration branch.

### 2. Closes #N must be in the PR body, not the title
GitHub only auto-closes issues when Closes #N, Fixes #N, or Resolves #N appears in the **PR body** (description). Putting it only in the PR title or commit message title does NOT reliably close the issue on merge.

**Rule:** Always include Closes #N in the PR body when creating PRs via gh pr create --body.

### 3. gh CLI PATH not inherited by spawned agents
When the coordinator installs or finds gh CLI, spawned agents may not have it in their PATH. The $env:Path in PowerShell sessions doesn't automatically refresh.

**Fix:** Refresh PATH at the start of every agent spawn that needs gh:
`powershell
C:\Program Files\PowerShell\7;C:\Program Files\Eclipse Adoptium\jdk-11.0.28.6-hotspot\bin;C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\windows\System32\WindowsPowerShell\v1.0\;C:\windows\System32\OpenSSH\;C:\Program Files\NVIDIA Corporation\NVIDIA NvDLISR;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Program Files\Git\cmd;C:\Program Files\nodejs\;C:\Program Files\PowerShell\7\;C:\Users\joperezd\AppData\Local\Microsoft\WindowsApps;C:\Users\joperezd\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\joperezd\AppData\Local\PowerToys\DSCModules\;C:\Users\joperezd\AppData\Local\Python\bin;C:\Users\joperezd\AppData\Roaming\npm = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
`

### 4. GitHub Projects v2 cannot be created programmatically
The Projects v2 API is GraphQL-only. Neither gh CLI nor the GitHub MCP server supports creating Projects. Users must create them manually from the GitHub web UI. The API CAN add/move items to existing projects.

### 5. Branch protection rulesets via API
Rulesets can be created via gh api repos/{owner}/{repo}/rulesets --method POST. Key fields:
- ypass_actors with ctor_id: 5 (RepositoryRole: Admin) allows admin bypass
- equired_status_checks should reference the check context name (e.g., "test")
- Use --admin flag on gh pr merge when admin bypass is needed

### 6. Cherry-pick as conflict resolution fallback
When a PR branch has too many diverged commits (e.g., it includes commits from other unmerged branches), cherry-picking the unique commit(s) onto main is cleaner than rebasing. Close the original PR with a comment explaining the merge method.

### 7. GitHub Discussions: ALWAYS check before creating (idempotency guard)
🔴 **CRITICAL — brand-facing content.** The Dev Diary is public marketing for the studio. Duplicates look unprofessional.

Agents MUST check if a Discussion with the same title already exists before creating one. The `gh discussion create` command does NOT check for duplicates — it will happily create 3 identical posts.

**Guard pattern (mandatory before any `gh discussion create`):**
```powershell
# Check if discussion already exists
$existing = gh api graphql -f query='{ repository(owner: "jperezdelreal", name: "FirstFrameStudios") { discussions(first: 10, orderBy: {field: CREATED_AT, direction: DESC}) { nodes { title } } } }' | ConvertFrom-Json
$title = "🔥 Dev Diary #2: ..."
$alreadyExists = $existing.data.repository.discussions.nodes | Where-Object { $_.title -eq $title }
if ($alreadyExists) { Write-Host "Discussion already exists — skipping"; return }
# Only then create
gh discussion create --repo jperezdelreal/FirstFrameStudios --category "General" --title $title --body "..."
```

**Rule:** Never retry a `gh discussion create` on failure without checking if the first attempt actually succeeded silently. API calls can return errors but still create the resource.

**Cleanup:** If duplicates are found, delete via GraphQL mutation:
```powershell
gh api graphql -f query='mutation { deleteDiscussion(input: {id: "DISCUSSION_NODE_ID"}) { discussion { id } } }'
```

### 8. Idempotency applies to ALL GitHub resource creation
The same guard-before-create pattern from #7 applies to:
- **Issues:** Check by title before `gh issue create`
- **Labels:** Check existing labels before `gh label create`
- **PRs:** Check by head branch before `gh pr create`
- **Discussions:** Check by title before `gh discussion create`

API calls can silently succeed on retry. Always verify state before creating.

## When to Apply
- Any time agents create parallel feature branches
- Any time agents create PRs via `gh pr create`
- Any time `gh` CLI is needed in spawned agent sessions
- When setting up branch protection or GitHub infrastructure
- **ALWAYS before creating Discussions, issues, or any public-facing content**
