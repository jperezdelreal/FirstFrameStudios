# Ralph Watch v4 -- Simplified Autonomous Squad Agent Loop
# First Frame Studios -- Tamir-style rewrite
#
# v4: Multi-repo via prompt scope, not script complexity.
# Squad agent handles parallelism and issue scheduling internally.
# Dropped: night/day mode, issue pre-fetching, activity monitors, PR dedup tracking.
# Kept: lock file, JSONL logging, heartbeat, alerts, session timeout, circuit breaker,
#       upstream sync, project lifecycle, scheduler integration.
#
# Usage:
#   .\tools\ralph-watch.ps1                        # default: 5min interval
#   .\tools\ralph-watch.ps1 -DryRun                # show what would happen
#   .\tools\ralph-watch.ps1 -MaxRounds 3           # stop after 3 rounds
#   .\tools\ralph-watch.ps1 -IntervalMinutes 10    # custom interval

param(
    [int]$IntervalMinutes = 5,
    [switch]$DryRun,
    [int]$MaxRounds = 0
)

# --- UTF-8 console fix for Windows PowerShell ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# --- Paths ---
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$lockFile = Join-Path $env:USERPROFILE ".squad\ralph-watch.lock"
$heartbeatFile = Join-Path $scriptRoot ".ralph-heartbeat.json"
$logsDir = Join-Path $scriptRoot "logs"
$alertsFile = Join-Path $logsDir "alerts.json"
$schedulerScript = Join-Path $scriptRoot "scheduler\Invoke-SquadScheduler.ps1"
$stopFile = Join-Path $scriptRoot ".ralph-stop"
$maxLogBytes = 1048576  # 1MB

# Failure tracking
$consecutiveFailures = 0
$alertThreshold = 3
$circuitBreakerThreshold = 10
$circuitBreakerTrips = 0
$maxCircuitBreakerTrips = 3

# Downstream repo names (siblings of hub)
$downstreamRepoNames = @("ComeRosquillas", "flora", "ffs-squad-monitor")

# Repo name-to-GitHub mapping (used by Check-ProjectLifecycle)
$repoGitHubMap = @{
    "FirstFrameStudios" = "jperezdelreal/FirstFrameStudios"
    "ComeRosquillas"    = "jperezdelreal/ComeRosquillas"
    "flora"             = "jperezdelreal/flora"
    "ffs-squad-monitor" = "jperezdelreal/ffs-squad-monitor"
}

# Ensure directories exist
$squadUserDir = Join-Path $env:USERPROFILE ".squad"
if (-not (Test-Path $squadUserDir)) { New-Item -ItemType Directory -Path $squadUserDir -Force | Out-Null }
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }

# --- Single-instance guard ---
if (Test-Path $lockFile) {
    $lockContent = Get-Content $lockFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($lockContent -and $lockContent.pid) {
        $existing = Get-Process -Id $lockContent.pid -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "ERROR: Ralph watch is already running (PID $($lockContent.pid), started $($lockContent.started))" -ForegroundColor Red
            Write-Host "Kill it first: Stop-Process -Id $($lockContent.pid) -Force" -ForegroundColor Yellow
            exit 1
        }
    }
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}
[ordered]@{
    pid     = $PID
    started = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
    directory = $repoRoot
} | ConvertTo-Json | Out-File $lockFile -Encoding utf8 -Force

# Pre-flight: verify copilot CLI
if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    Write-Host "[FATAL] 'copilot' CLI not found in PATH." -ForegroundColor Red
    exit 1
}

# Clean up lock on exit
Register-EngineEvent PowerShell.Exiting -Action { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue } | Out-Null
trap { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue; break }

# --- Prompt (static, multi-repo scope) ---
$prompt = @'
Ralph, Go! MAXIMIZE PARALLELISM: For every round, identify ALL actionable issues
and spawn agents for ALL of them simultaneously as background tasks -- do NOT work
on issues one at a time. If there are 5 actionable issues, spawn 5 agents in one turn.
PR comments, new issues, merges -- do as much as possible in parallel per round.

MULTI-REPO WATCH: Scan ALL First Frame Studios repos for squad-labeled issues:
- jperezdelreal/FirstFrameStudios (hub)
- jperezdelreal/ComeRosquillas (game)
- jperezdelreal/flora (game)
- jperezdelreal/ffs-squad-monitor (tooling)

GOVERNANCE: Do NOT touch issues labeled "tier:t0" or "tier:t1". Only work tier:t2+.

ISSUE LIFECYCLE: For each issue:
1. Create branch squad/{issue-number}-{slug}
2. Do the work (read issue body for acceptance criteria)
3. Commit referencing the issue (Closes #{number})
4. Push and open PR via gh pr create
5. LABEL INHERITANCE: Copy ALL labels from issue to PR
6. Work in the repo directory for that issue

PR MANAGEMENT:
- CHANGES_REQUESTED: address review feedback
- CI failing: fix the build
- DO NOT auto-merge PRs. Ralph must NEVER run "gh pr merge".
- All PRs require Lead/Founder review before merge.

PR REVIEW RULES:
- REJECTING: use "gh pr review --request-changes" (NEVER --comment for rejections)
- APPROVING: use "gh pr review --approve" (NEVER --comment for approvals)

PROJECT BOARD: Read .squad/skills/github-project-board/SKILL.md BEFORE starting.
Update board status for every issue you touch.

DUPLICATE PREVENTION: Before creating any issue, check existing opens first.
DONE ITEMS ARCHIVING: Close Done items older than 3 days with summary comment.

AFTER completing work, report counts: issues closed, PRs merged, PRs opened.
COMMIT all .squad/ changes before finishing.
'@

# ========================================================================
# Helper Functions
# ========================================================================

function Write-RalphLog {
    param(
        [int]$Round,
        [string]$Status,
        [int]$ExitCode,
        [double]$DurationSeconds,
        [string]$Phase = "round",
        [hashtable]$Metrics = @{}
    )
    $logFileName = "ralph-$(Get-Date -Format 'yyyy-MM-dd').jsonl"
    $logPath = Join-Path $logsDir $logFileName

    $entry = [ordered]@{
        timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        round     = $Round
        phase     = $Phase
        status    = $Status
        exitCode  = $ExitCode
        duration  = [math]::Round($DurationSeconds, 1)
        consecutiveFailures = $script:consecutiveFailures
    }
    if ($Metrics.Count -gt 0) {
        $entry["metrics"] = $Metrics
    }
    ($entry | ConvertTo-Json -Compress) | Add-Content -Path $logPath -Encoding utf8

    # Log rotation: if file exceeds 1MB, rotate to .1
    if ((Test-Path $logPath) -and ((Get-Item $logPath).Length -gt $maxLogBytes)) {
        $rotated = $logPath -replace '\.jsonl$', '.1.jsonl'
        Move-Item $logPath $rotated -Force -ErrorAction SilentlyContinue
    }
}

function Update-Heartbeat {
    param(
        [string]$Status,
        [int]$Round,
        [hashtable]$Extra = @{}
    )
    $heartbeat = [ordered]@{
        timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        status    = $Status
        round     = $Round
        pid       = $PID
        interval  = $script:IntervalMinutes
        consecutiveFailures = $script:consecutiveFailures
    }
    foreach ($key in $Extra.Keys) { $heartbeat[$key] = $Extra[$key] }
    $heartbeat | ConvertTo-Json -Depth 4 | Out-File $heartbeatFile -Encoding utf8 -Force
}

function Write-FailureAlert {
    param(
        [int]$Round,
        [int]$Failures,
        [int]$ExitCode,
        [string]$ErrorMessage = ""
    )
    $alert = [ordered]@{
        timestamp   = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        level       = "CRITICAL"
        type        = "consecutive_failures"
        round       = $Round
        failures    = $Failures
        exitCode    = $ExitCode
        message     = "$Failures consecutive failures at round $Round (exit $ExitCode)"
        errorDetail = $ErrorMessage
    }

    $alerts = @()
    if (Test-Path $alertsFile) {
        try {
            $existing = Get-Content $alertsFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($existing -is [System.Array]) { $alerts = @($existing) }
            elseif ($existing) { $alerts = @($existing) }
        } catch { $alerts = @() }
    }
    $alerts += $alert
    if ($alerts.Count -gt 50) { $alerts = $alerts | Select-Object -Last 50 }

    $alerts | ConvertTo-Json -Depth 4 | Out-File $alertsFile -Encoding utf8 -Force
    Write-Host "   [ALERT] Written to $alertsFile" -ForegroundColor Red
}

function Get-SessionMetrics {
    param([string]$Output)
    $metrics = @{
        issuesClosed = 0
        prsMerged    = 0
        prsOpened    = 0
        commitsCount = 0
    }
    if (-not $Output) { return $metrics }

    if ($Output -match '(\d+)\s+issues?\s+closed') { $metrics.issuesClosed = [int]$Matches[1] }
    elseif ($Output -match 'closed\s+(\d+)\s+issues?') { $metrics.issuesClosed = [int]$Matches[1] }
    elseif ($Output -match 'issues?\s+closed[:\s]+(\d+)') { $metrics.issuesClosed = [int]$Matches[1] }

    if ($Output -match '(\d+)\s+PRs?\s+merged') { $metrics.prsMerged = [int]$Matches[1] }
    elseif ($Output -match 'merged\s+(\d+)\s+PRs?') { $metrics.prsMerged = [int]$Matches[1] }
    elseif ($Output -match 'PRs?\s+merged[:\s]+(\d+)') { $metrics.prsMerged = [int]$Matches[1] }

    if ($Output -match '(\d+)\s+PRs?\s+opened') { $metrics.prsOpened = [int]$Matches[1] }
    elseif ($Output -match 'opened\s+(\d+)\s+PRs?') { $metrics.prsOpened = [int]$Matches[1] }
    elseif ($Output -match 'pull\s+requests?\s+opened[:\s]+(\d+)') { $metrics.prsOpened = [int]$Matches[1] }

    if ($Output -match '(\d+)\s+commits?') { $metrics.commitsCount = [int]$Matches[1] }

    return $metrics
}

function Get-RepoName {
    param([string]$RepoPath)
    $resolved = Resolve-Path $RepoPath -ErrorAction SilentlyContinue
    if ($resolved) { return (Split-Path $resolved.Path -Leaf) }
    return (Split-Path $RepoPath -Leaf)
}

function Test-HasSquadRoster {
    param([string]$RepoPath)
    $teamMdPath = Join-Path $RepoPath ".squad\team.md"
    if (-not (Test-Path $teamMdPath)) { return $false }
    try {
        $content = Get-Content $teamMdPath -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return $false }
        return $content -match '(?m)^## Members'
    } catch {
        return $false
    }
}

function Invoke-GitPull {
    param([string]$RepoPath)
    Push-Location $RepoPath
    try {
        Write-Host "   [pull] Pulling latest in $RepoPath..." -ForegroundColor Gray
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would run: git fetch origin; git pull --rebase --autostash" -ForegroundColor Yellow
        } else {
            $defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
            if ($defaultBranch) {
                $defaultBranch = $defaultBranch -replace 'refs/remotes/origin/', ''
            } else {
                $defaultBranch = "main"
            }
            $currentBranch = git branch --show-current 2>$null
            if ($currentBranch -ne $defaultBranch) {
                Write-Host "      [fix] Switching from '$currentBranch' to '$defaultBranch'" -ForegroundColor Yellow
                git stash 2>&1 | Out-Null
                git checkout $defaultBranch 2>&1 | Out-Null
                git stash drop 2>&1 | Out-Null
            }
            git fetch origin 2>&1 | Out-Null
            git pull --rebase --autostash 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
        }
    } finally {
        Pop-Location
    }
}

function Invoke-Scheduler {
    if (Test-Path $schedulerScript) {
        Write-Host "   [sched] Running Squad Scheduler..." -ForegroundColor Gray
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would run: $schedulerScript" -ForegroundColor Yellow
            & $schedulerScript -DryRun
        } else {
            & $schedulerScript
        }
    } else {
        Write-Host "   [sched] Scheduler not found, skipping" -ForegroundColor DarkGray
    }
}

function Invoke-UpstreamSync {
    param(
        [string]$HubPath,
        [string]$DownstreamPath
    )
    $downstreamName = Get-RepoName -RepoPath $DownstreamPath

    $downstreamSquadDir = Join-Path $DownstreamPath ".squad"
    if (-not (Test-Path $downstreamSquadDir)) {
        Write-Host "   [sync] Skipping $downstreamName -- no .squad/ directory" -ForegroundColor DarkGray
        return
    }

    Write-Host "   [sync] Syncing hub -> $downstreamName..." -ForegroundColor Cyan

    # NOTE: decisions.md is NOT synced -- each repo has its own local decisions.
    $syncItems = @(
        @{ Type = "Directory"; Path = ".squad\skills" },
        @{ Type = "File"; Path = ".squad\identity\quality-gates.md" },
        @{ Type = "File"; Path = ".squad\identity\governance.md" },
        @{ Type = "File"; Path = ".github\agents\squad.agent.md" }
    )

    $syncedCount = 0
    foreach ($item in $syncItems) {
        $sourcePath = Join-Path $HubPath $item.Path
        $destPath = Join-Path $DownstreamPath $item.Path

        if (-not (Test-Path $sourcePath)) {
            Write-Host "      [sync] Skipping $($item.Path) -- not found in hub" -ForegroundColor DarkGray
            continue
        }

        try {
            if ($script:DryRun) {
                Write-Host "      [DRY RUN] Would sync: $($item.Path)" -ForegroundColor Yellow
                $syncedCount++
            } else {
                $destDir = Split-Path $destPath -Parent
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }

                if ($item.Type -eq "Directory") {
                    if (-not (Test-Path $destPath)) {
                        New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                    }
                    Copy-Item -Path "$sourcePath\*" -Destination $destPath -Recurse -Force -ErrorAction Stop
                } else {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force -ErrorAction Stop
                }
                $syncedCount++
            }
        } catch {
            Write-Host "      [sync] Failed to sync $($item.Path): $_" -ForegroundColor Yellow
        }
    }

    if ($syncedCount -eq 0) {
        Write-Host "   [sync] $downstreamName : no files to sync" -ForegroundColor DarkGray
        return
    }

    Push-Location $DownstreamPath
    try {
        $status = git status --porcelain 2>$null
        if (-not $status) {
            Write-Host "   [sync] $downstreamName : already up to date" -ForegroundColor DarkGray
        } else {
            if ($script:DryRun) {
                Write-Host "   [DRY RUN] Would commit upstream sync in $downstreamName" -ForegroundColor Yellow
            } else {
                git add .squad/ .github/agents/ 2>&1 | Out-Null
                git commit -m "chore: upstream sync from hub`n`nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" 2>&1 | Out-Null
                $pushOutput = git push origin 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "   [!] Git push failed in ${downstreamName}: $pushOutput" -ForegroundColor Yellow
                } else {
                    Write-Host "   [sync] $downstreamName : synced $syncedCount files, committed and pushed" -ForegroundColor Green
                }
            }
        }
    } finally {
        Pop-Location
    }
}

function Check-ProjectLifecycle {
    param([string[]]$RepoNames)

    foreach ($repoName in $RepoNames) {
        $ghRepo = $repoGitHubMap[$repoName]
        if (-not $ghRepo) { continue }

        # Hub exception: FirstFrameStudios does not use lifecycle
        if ($repoName -eq "FirstFrameStudios") { continue }

        try {
            $stateB64 = gh api "repos/$ghRepo/contents/.squad/project-state.json" --jq '.content' 2>$null
            if (-not $stateB64 -or $LASTEXITCODE -ne 0) { continue }
        } catch { continue }

        try {
            $stateRaw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($stateB64))
            $state = $stateRaw | ConvertFrom-Json
        } catch {
            Write-Host "   [lifecycle] $repoName -- failed to parse project-state.json, skipping" -ForegroundColor Yellow
            continue
        }

        $phase = $state.phase
        $sprint = [int]$state.sprint
        $designDoc = $state.design_doc
        Write-Host "   [lifecycle] $repoName -- phase=$phase, sprint=$sprint" -ForegroundColor DarkGray

        # Find Lead from team.md
        $leadName = "solo"
        try {
            $teamB64 = gh api "repos/$ghRepo/contents/.squad/team.md" --jq '.content' 2>$null
            if ($teamB64 -and $LASTEXITCODE -eq 0) {
                $teamRaw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($teamB64))
                if ($teamRaw -match '(?m)\|\s*\*{0,2}(\w+)\*{0,2}\s*\|[^|]*Lead') {
                    $leadName = $Matches[1].ToLower()
                }
            }
        } catch { }

        if ($phase -eq "closeout") {
            Write-Host "   [lifecycle] $repoName -- closeout phase, no auto action" -ForegroundColor DarkGray
            continue
        }

        if ($phase -eq "sprint-planning") {
            $existingCeremony = gh issue list -R $ghRepo --state open --search "[CEREMONY]" --json title --limit 10 2>$null
            $hasExisting = $false
            if ($existingCeremony) {
                $parsed = $existingCeremony | ConvertFrom-Json -ErrorAction SilentlyContinue
                foreach ($iss in $parsed) {
                    if ($iss.title -match '^\[CEREMONY\]|^\[ROADMAP\]') { $hasExisting = $true; break }
                }
            }
            if (-not $hasExisting) {
                $nextSprint = $sprint + 1
                $body = "Sprint Planning ceremony triggered. Lead: read the design doc at ``$designDoc``, compare with open issues, create Sprint $nextSprint issues. See .squad/ceremonies.md for the full process."
                $labels = "squad,squad:$leadName,ceremony:sprint-planning,go:ready"

                $requiredLabels = @(
                    @{ name = "ceremony:sprint-planning"; color = "0E8A16"; description = "Sprint Planning ceremony trigger" },
                    @{ name = "go:ready"; color = "0E8A16"; description = "Ready for implementation" }
                )
                foreach ($lbl in $requiredLabels) {
                    gh label create $lbl.name --repo $ghRepo --color $lbl.color --description $lbl.description 2>$null
                }

                Write-Host "   [lifecycle] $repoName -- creating Sprint Planning ceremony issue" -ForegroundColor Cyan
                if (-not $DryRun) {
                    gh issue create -R $ghRepo --title "[CEREMONY] Sprint Planning" --body $body --label $labels 2>$null
                } else {
                    Write-Host "   [lifecycle] [DRY RUN] Would create: [CEREMONY] Sprint Planning (labels: $labels)" -ForegroundColor Yellow
                }
            }
        }
        elseif ($phase -eq "sprinting") {
            $sprintLabel = "sprint:$sprint"
            $openIssues = gh issue list -R $ghRepo --state open --label $sprintLabel --json number --limit 1 2>$null
            $hasOpen = $false
            if ($openIssues) {
                $parsed = $openIssues | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($parsed -and $parsed.Count -gt 0) { $hasOpen = $true }
            }

            if (-not $hasOpen) {
                Write-Host "   [lifecycle] $repoName -- all sprint:$sprint issues closed, transitioning to sprint-planning" -ForegroundColor Cyan

                if (-not $DryRun) {
                    $fileMeta = gh api "repos/$ghRepo/contents/.squad/project-state.json" --jq '.sha' 2>$null
                    if ($fileMeta -and $LASTEXITCODE -eq 0) {
                        $newState = @{ phase = "sprint-planning"; sprint = $sprint + 1; design_doc = $designDoc } | ConvertTo-Json -Compress
                        $newContentB64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($newState))
                        $updateBody = @{
                            message = "chore: transition to sprint-planning (sprint $($sprint + 1))"
                            content = $newContentB64
                            sha = $fileMeta
                        } | ConvertTo-Json -Compress
                        $updateBody | gh api -X PUT "repos/$ghRepo/contents/.squad/project-state.json" --input - 2>$null | Out-Null

                        $nextSprint = $sprint + 1
                        $body = "Sprint Planning ceremony triggered. Lead: read the design doc at ``$designDoc``, compare with open issues, create Sprint $nextSprint issues. See .squad/ceremonies.md for the full process."
                        $labels = "squad,squad:$leadName,ceremony:sprint-planning,go:ready"

                        $requiredLabels = @(
                            @{ name = "ceremony:sprint-planning"; color = "0E8A16"; description = "Sprint Planning ceremony trigger" },
                            @{ name = "go:ready"; color = "0E8A16"; description = "Ready for implementation" }
                        )
                        foreach ($lbl in $requiredLabels) {
                            gh label create $lbl.name --repo $ghRepo --color $lbl.color --description $lbl.description 2>$null
                        }

                        Write-Host "   [lifecycle] $repoName -- creating Sprint Planning ceremony issue" -ForegroundColor Cyan
                        gh issue create -R $ghRepo --title "[CEREMONY] Sprint Planning" --body $body --label $labels 2>$null
                    }
                } else {
                    Write-Host "   [lifecycle] [DRY RUN] Would transition $repoName to sprint-planning (sprint $($sprint + 1))" -ForegroundColor Yellow
                    Write-Host "   [lifecycle] [DRY RUN] Would create: [CEREMONY] Sprint Planning" -ForegroundColor Yellow
                }
            }
        }
    }
}

# ========================================================================
# Main Loop
# ========================================================================

# Resolve downstream repos that exist locally
$parentDir = Split-Path $repoRoot -Parent
$existingDownstream = @()
foreach ($name in $downstreamRepoNames) {
    $path = Join-Path $parentDir $name
    if (Test-Path $path) { $existingDownstream += $path }
}

# Build repo names list for lifecycle check
$allRepoNames = @("FirstFrameStudios")
foreach ($path in $existingDownstream) {
    $name = Get-RepoName -RepoPath $path
    if ($repoGitHubMap.ContainsKey($name)) { $allRepoNames += $name }
}

Write-Host ""
Write-Host "[ralph] Ralph Watch v4 - First Frame Studios (Simplified)" -ForegroundColor Cyan
Write-Host "   Interval:    $IntervalMinutes minutes" -ForegroundColor Gray
Write-Host "   Hub:         $repoRoot" -ForegroundColor Gray
Write-Host "   Downstream:  $($existingDownstream.Count) repos found" -ForegroundColor Gray
Write-Host "   Heartbeat:   $heartbeatFile" -ForegroundColor Gray
Write-Host "   Logs:        $logsDir" -ForegroundColor Gray
Write-Host "   Lock:        $lockFile" -ForegroundColor Gray
if ($DryRun)    { Write-Host "   DryRun:      YES" -ForegroundColor Yellow }
if ($MaxRounds) { Write-Host "   MaxRounds:   $MaxRounds" -ForegroundColor Yellow }
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host "   To stop after current round: create file tools\.ralph-stop" -ForegroundColor Gray
Write-Host ""

$round = 0
if (Test-Path $stopFile) { Remove-Item $stopFile -Force }

try {
while ($true) {
    $round++
    $roundStart = Get-Date
    $timestamp = $roundStart.ToString('yyyy-MM-ddTHH:mm:ss')

    Write-Host "[$timestamp] [>>] Round $round starting..." -ForegroundColor Green
    Update-Heartbeat -Status "running" -Round $round

    try {
        # Step 1: Git pull (hub + downstream)
        Invoke-GitPull -RepoPath $repoRoot
        foreach ($path in $existingDownstream) {
            Invoke-GitPull -RepoPath $path
        }

        # Step 2: Upstream sync (hub -> downstream)
        foreach ($path in $existingDownstream) {
            Invoke-UpstreamSync -HubPath $repoRoot -DownstreamPath $path
        }

        # Step 3: Run scheduler
        Invoke-Scheduler

        # Step 4: Check project lifecycle
        Check-ProjectLifecycle -RepoNames $allRepoNames

        # Step 5: Copilot session
        $exitCode = 0
        $copilotOutput = ""

        if ($DryRun) {
            Write-Host "   [DRY RUN] Would run: copilot --agent squad --yolo -p <prompt>" -ForegroundColor Yellow
            $copilotOutput = "[DRY RUN] No output captured"
        } else {
            Write-Host "   [copilot] Running session (blocking, Tamir-style)..." -ForegroundColor Cyan
            $copilotOutput = copilot --agent squad --yolo -p $prompt 2>&1 | Out-String
            $exitCode = $LASTEXITCODE
        }

        # Step 6: Log result + heartbeat
        $roundEnd = Get-Date
        $duration = ($roundEnd - $roundStart).TotalSeconds
        $metrics = Get-SessionMetrics -Output $copilotOutput

        if ($exitCode -eq 0) {
            $consecutiveFailures = 0
            Write-RalphLog -Round $round -Status "OK" -ExitCode $exitCode -DurationSeconds $duration -Metrics $metrics
            Update-Heartbeat -Status "idle" -Round $round -Extra @{
                lastDuration = [math]::Round($duration, 1)
                lastStatus   = "OK"
                metrics      = $metrics
            }
            $metricsLine = "issues=$($metrics.issuesClosed) prs_merged=$($metrics.prsMerged) prs_opened=$($metrics.prsOpened)"
            Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [OK] Round $round complete ($([math]::Round($duration, 1))s) [$metricsLine]" -ForegroundColor Green
        } else {
            $consecutiveFailures++
            Write-RalphLog -Round $round -Status "FAIL" -ExitCode $exitCode -DurationSeconds $duration -Metrics $metrics
            Update-Heartbeat -Status "idle" -Round $round -Extra @{
                lastDuration = [math]::Round($duration, 1)
                lastStatus   = "FAIL"
            }
            Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [FAIL] Round $round failed, exit code $exitCode ($([math]::Round($duration, 1))s)" -ForegroundColor Red

            if ($consecutiveFailures -ge $alertThreshold) {
                Write-FailureAlert -Round $round -Failures $consecutiveFailures -ExitCode $exitCode
            }

            # Circuit breaker
            if ($consecutiveFailures -ge $circuitBreakerThreshold) {
                $circuitBreakerTrips++
                if ($circuitBreakerTrips -ge $maxCircuitBreakerTrips) {
                    Write-Host "   [CIRCUIT BREAKER] Trip $circuitBreakerTrips/$maxCircuitBreakerTrips. Shutting down." -ForegroundColor Red
                    Write-RalphLog -Round $round -Status "CIRCUIT_BREAKER_SHUTDOWN" -ExitCode $exitCode -DurationSeconds 0 -Phase "shutdown"
                    break
                }
                Write-Host "   [CIRCUIT BREAKER] Trip $circuitBreakerTrips/$maxCircuitBreakerTrips. Pausing 1 hour." -ForegroundColor Red
                Write-RalphLog -Round $round -Status "CIRCUIT_BREAKER" -ExitCode $exitCode -DurationSeconds 0 -Phase "cooldown"
                Start-Sleep -Seconds 3600
                $consecutiveFailures = 0
            }
        }
    } catch {
        $consecutiveFailures++
        $roundEnd = Get-Date
        $duration = ($roundEnd - $roundStart).TotalSeconds
        Write-RalphLog -Round $round -Status "ERROR" -ExitCode -1 -DurationSeconds $duration
        Update-Heartbeat -Status "idle" -Round $round -Extra @{
            lastDuration = [math]::Round($duration, 1)
            lastStatus   = "ERROR"
        }
        Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [!] Round $round exception: $_" -ForegroundColor Red

        if ($consecutiveFailures -ge $alertThreshold) {
            Write-FailureAlert -Round $round -Failures $consecutiveFailures -ExitCode -1 -ErrorMessage "$_"
        }
        if ($consecutiveFailures -ge $circuitBreakerThreshold) {
            $circuitBreakerTrips++
            if ($circuitBreakerTrips -ge $maxCircuitBreakerTrips) {
                Write-Host "   [CIRCUIT BREAKER] Trip $circuitBreakerTrips/$maxCircuitBreakerTrips. Shutting down." -ForegroundColor Red
                Write-RalphLog -Round $round -Status "CIRCUIT_BREAKER_SHUTDOWN" -ExitCode -1 -DurationSeconds 0 -Phase "shutdown"
                break
            }
            Write-Host "   [CIRCUIT BREAKER] Trip $circuitBreakerTrips/$maxCircuitBreakerTrips. Pausing 1 hour." -ForegroundColor Red
            Write-RalphLog -Round $round -Status "CIRCUIT_BREAKER" -ExitCode -1 -DurationSeconds 0 -Phase "cooldown"
            Start-Sleep -Seconds 3600
            $consecutiveFailures = 0
        }
    }

    # Check MaxRounds
    if ($MaxRounds -gt 0 -and $round -ge $MaxRounds) {
        Write-Host ""
        Write-Host "[end] Reached MaxRounds ($MaxRounds). Stopping." -ForegroundColor Cyan
        break
    }

    # Check stop file
    if (Test-Path $stopFile) {
        Write-Host ""
        Write-Host "[end] Stop file detected. Stopping gracefully." -ForegroundColor Cyan
        Remove-Item $stopFile -Force -ErrorAction SilentlyContinue
        break
    }

    # Sleep (responsive to Ctrl+C and .ralph-stop)
    Write-Host "   Next round in $IntervalMinutes minutes..." -ForegroundColor Gray
    Write-Host ""
    $sleepTotal = $IntervalMinutes * 60
    $slept = 0
    while ($slept -lt $sleepTotal) {
        $chunk = [Math]::Min(10, $sleepTotal - $slept)
        Start-Sleep -Seconds $chunk
        $slept += $chunk
        if (Test-Path $stopFile) {
            Write-Host ""
            Write-Host "[end] Stop file detected during sleep. Stopping gracefully." -ForegroundColor Cyan
            Remove-Item $stopFile -Force -ErrorAction SilentlyContinue
            $slept = $sleepTotal + 1
        }
    }
    if ($slept -gt $sleepTotal) { break }
}
} finally {
    Write-Host ""
    Write-Host "[ralph] Shutting down..." -ForegroundColor Yellow
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    Update-Heartbeat -Status "stopped" -Round $round
    Write-Host "[ralph] Ralph Watch stopped. Round $round was the last." -ForegroundColor Cyan
}
