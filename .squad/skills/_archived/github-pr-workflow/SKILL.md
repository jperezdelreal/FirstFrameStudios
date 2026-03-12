---
name: github-pr-workflow
description: "GitHub PR workflow patterns and gotchas for multi-agent development"
domain: "devops"
confidence: "medium"
source: "Ashfall M1+M2 PR merge learnings"
has_reference: true
---

## Context
PR workflow lessons from multi-agent Godot development. Parallel branches cause autoload conflicts, `Closes #N` must be in body, gh CLI PATH issues, cherry-pick as conflict fallback.

## Core Patterns

- **`Closes #N` in PR body** — NOT title or commit message. Only body reliably auto-closes issue on merge
- **Parallel autoload conflicts** — Multiple agents adding to same project.godot section. Mitigation: rebase after first PR merge
- **gh CLI PATH not inherited** — Refresh PATH at agent spawn: `C:\Program Files\PowerShell\7;C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin;C:\Program Files\Eclipse Adoptium\jdk-11.0.28.6-hotspot\bin;C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\windows\System32\WindowsPowerShell\v1.0\;C:\windows\System32\OpenSSH\;C:\Program Files\NVIDIA Corporation\NVIDIA NvDLISR;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Program Files\Git\cmd;C:\Program Files\nodejs\;C:\Program Files\PowerShell\7\;C:\Program Files\GitHub CLI\;C:\Users\joperezd\AppData\Local\Microsoft\WindowsApps;C:\Users\joperezd\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\joperezd\AppData\Local\PowerToys\DSCModules\;C:\Users\joperezd\AppData\Local\Python\bin;C:\Users\joperezd\AppData\Roaming\npm = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")`
- **Branch protection via API** — `gh api repos/{owner}/{repo}/rulesets --method POST` with `bypass_actors` and `required_status_checks`
- **Cherry-pick fallback** — When PR has too many diverged commits, cherry-pick unique commits onto main, close original PR with explanation
- **Discussion idempotency (CRITICAL)** — ALWAYS check if title exists before `gh discussion create`. Brand-facing content, duplicates unprofessional

## Key Examples

**Idempotency guard for Discussions:**
```powershell
 = gh api graphql -f query='{ repository(owner: "X", name: "Y") { discussions(first: 10) { nodes { title } } } }' | ConvertFrom-Json
 = .data.repository.discussions.nodes | Where-Object { .title -eq  }
if () { Write-Host "Discussion exists"; return }
gh discussion create --title  --body "..."
```

**Cherry-pick workflow:**
```bash
git checkout main
git cherry-pick <commit-sha>
git push origin main
# Close original PR with explanation
```

## Anti-Patterns

- **`Closes #N` in title only** — Doesn't auto-close issue
- **Retry without existence check** — API can succeed silently
- **Branching from unmerged feature** — Creates dead branch trap
- **No rebase after parallel merge** — Autoload conflicts accumulate
