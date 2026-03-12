# Ralph Watch v3 -- Autonomous Squad Agent Outer Loop (Night/Day Mode)
# First Frame Studios -- Adapted from Tamir Dresher's squad-personal-demo
#
# Launches Ralph in a persistent loop with automatic night/day scheduling.
# Night mode: aggressive parallel sessions (weeknights 21-07, weekends 24h)
# Day mode: conservative single session (weekdays 07-21)
# To stop: Ctrl+C
#
# v3 features:
#   - Night/day mode auto-detection via system clock
#   - Night mode: more issues per session + shorter interval (not parallel)
#   - Governance filter: skips T0 and T1 issues (require formal approval process)
#   - Governance: ralph must NEVER auto-merge PRs (all PRs need Lead/Founder review)
#   - Governance: issue labels inherited by PRs (no zero-label PRs)
#   - Priority-based scheduling: P0 > P1 > P2 > P3, then repo issue count
#   - Remote URL validation before each round
#   - Mid-round heartbeat updates
#   - All v2 features: failure alerts, activity monitor, metrics parsing
#
# Usage:
#   .\tools\ralph-watch.ps1                          # auto mode, all FFS repos
#   .\tools\ralph-watch.ps1 -Mode night              # force night mode
#   .\tools\ralph-watch.ps1 -Mode day                # force day mode
#   .\tools\ralph-watch.ps1 -DryRun                  # show what would happen
#   .\tools\ralph-watch.ps1 -MaxRounds 3             # stop after 3 rounds (testing)
#   .\tools\ralph-watch.ps1 -NightSessions 3         # 3 parallel sessions at night
#   .\tools\ralph-watch.ps1 -Repos @(".", "../other-repo")

param(
    [ValidateSet("auto", "night", "day")]
    [string]$Mode = "auto",
    [int]$NightSessions = 2,
    [int]$DaySessions = 1,
    [int]$NightInterval = 2,
    [int]$DayInterval = 10,
    [int]$MaxIssuesPerSession = 0,
    [switch]$DryRun,
    [int]$MaxRounds = 0,
    [string[]]$Repos = @(
        ".",                    # FirstFrameStudios hub
        "../ComeRosquillas",    # Game repo
        "../flora",             # Game repo
        "../ffs-squad-monitor"  # Monitor repo
    )
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
$maxLogBytes = 1048576  # 1MB
$consecutiveFailures = 0
$alertThreshold = 3
$circuitBreakerThreshold = 10

# Repo name-to-GitHub mapping for issue queries
$repoGitHubMap = @{
    "FirstFrameStudios" = "jperezdelreal/FirstFrameStudios"
    "ComeRosquillas"    = "jperezdelreal/ComeRosquillas"
    "flora"             = "jperezdelreal/flora"
    "ffs-squad-monitor" = "jperezdelreal/ffs-squad-monitor"
}

# Game repos get scheduling priority over hub/tool repos
$gameRepoNames = @("ComeRosquillas", "flora")

# Ensure directories exist
$squadUserDir = Join-Path $env:USERPROFILE ".squad"
if (-not (Test-Path $squadUserDir)) { New-Item -ItemType Directory -Path $squadUserDir -Force | Out-Null }
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }

# --- Mode detection ---
function Get-OperatingMode {
    if ($script:Mode -ne "auto") { return $script:Mode }
    $now = Get-Date
    $dow = $now.DayOfWeek
    $hour = $now.Hour
    # Weekend = always night mode
    if ($dow -eq [DayOfWeek]::Saturday -or $dow -eq [DayOfWeek]::Sunday) { return "night" }
    # Weekday: 21:00-06:59 = night, 07:00-20:59 = day
    if ($hour -ge 21 -or $hour -lt 7) { return "night" }
    return "day"
}

# Derive interval and session count from current mode
function Get-ModeConfig {
    $opMode = Get-OperatingMode
    $sessions = if ($opMode -eq "night") { $script:NightSessions } else { $script:DaySessions }
    $interval = if ($opMode -eq "night") { $script:NightInterval } else { $script:DayInterval }
    # Max issues per session: parameter override, else mode default
    $maxIssues = $script:MaxIssuesPerSession
    if ($maxIssues -le 0) {
        $maxIssues = if ($opMode -eq "night") { 5 } else { 3 }
    }
    return @{
        Mode       = $opMode
        Sessions   = $sessions
        Interval   = $interval
        MaxIssues  = $maxIssues
    }
}

$lastMode = ""

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
    # Stale lock from a crashed process -- clean it up
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}

# Write lock
[ordered]@{
    pid     = $PID
    started = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
    directory = $repoRoot
} | ConvertTo-Json | Out-File $lockFile -Encoding utf8 -Force

# Pre-flight: verify copilot CLI is available
if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    Write-Host "[FATAL] 'copilot' CLI not found in PATH. Install GitHub Copilot CLI first." -ForegroundColor Red
    exit 1
}

# Clean up lock on exit
Register-EngineEvent PowerShell.Exiting -Action { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue } | Out-Null
trap { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue; break }

# --- Ralph prompt template ---
# Base prompt shared by all sessions; session-specific repos/issues injected at runtime
$ralphPromptBase = @'
Ralph, Go!

MAXIMIZE PARALLELISM: For every round, identify ALL actionable issues and spawn agents for ALL of them simultaneously. Do NOT work issues one at a time.

SCOPE: You are working ONLY on the following repository:
{REPO_SCOPE}

ISSUE ALLOWLIST (work ONLY these issues in priority order):
{ISSUE_LIST}

GOVERNANCE: Do NOT touch issues labeled "tier:t0" or "tier:t1". T0 and T1 require formal approval (Solo proposes, Founder approves). Only work tier:t2 and tier:t3 (or unlabeled) issues.

For each repo, check: issues labeled 'squad' or with 'squad:{member}' labels, open PRs, draft PRs, CI failures.

ISSUE LIFECYCLE: For each issue you pick up:
1. Create branch squad/{issue-number}-{slug}
2. Do the work (read the issue body for acceptance criteria)
3. Commit referencing the issue (Closes #{number})
4. Push and open PR via gh pr create
5. LABEL INHERITANCE: Copy ALL labels from the source issue to the PR.
   Use: gh pr edit <number> --add-label "label1" --add-label "label2"
   This ensures PRs are never created with 0 labels.
6. Work in the repo directory for that issue

PR MANAGEMENT: Check for PRs needing attention:
- CHANGES_REQUESTED: address review feedback
- CI failing: fix the build
- DO NOT auto-merge PRs. Ralph must NEVER run "gh pr merge".
  All PRs require Lead/Founder review before merge.
  After opening a PR, move the issue to "In Review" and move on.

PREPARE MODE (blocked issues):
Issues marked [PREPARE-ONLY] are blocked by dependencies (blocked-by:* labels).
For these issues, you may ONLY:
  - Write tests (TDD approach -- document expected behavior)
  - Scaffold code structure (empty functions, interfaces, module stubs)
  - Write spike code to explore the problem space
  - Open a Draft PR with [WIP] prefix in the title
You must NOT:
  - Mark the PR as Ready for Review
  - Merge to main
  - Close the issue
  - Run "gh pr merge" on these issues
After preparing, move the issue to "Blocked" on the project board and comment:
  "Prepared in prepare-mode (blocked by dependencies). Tests/scaffold ready. Waiting for blocker resolution."

PROJECT BOARD: Read .squad/skills/github-project-board/SKILL.md BEFORE starting.
Update the GitHub Project board status for every issue you touch.
BEFORE spawning an agent, move the issue to In Progress on the board.
When work completes and PR merges, move to Done.
When blocked or waiting for user, move to Blocked or Pending User.

DUPLICATE PREVENTION: Before creating any new issue, check existing open issues first.
Search across all FFS repos: gh search issues --owner jperezdelreal --state open "keywords"
Do NOT create duplicates for things already tracked.

DONE ITEMS ARCHIVING: Check for issues in Done status for 3+ days.
Close them with a summary comment of what was accomplished.
Archive them from the project board.

AFTER completing work, report counts: issues closed, PRs merged, PRs opened.
COMMIT all .squad/ changes before finishing.
'@

# --- Helper: Build repo-scoped prompt ---
function Build-SessionPrompt {
    param(
        [string]$RepoFullName,
        [string[]]$IssueLines
    )
    $issueText = if ($IssueLines.Count -gt 0) {
        $IssueLines -join "`n"
    } else {
        "(No pre-fetched issues -- scan the repo for squad-labeled issues)"
    }
    $prompt = $ralphPromptBase -replace '\{REPO_SCOPE\}', "- $RepoFullName" -replace '\{ISSUE_LIST\}', $issueText
    return $prompt
}

# --- Helper: Update heartbeat file ---
function Update-Heartbeat {
    param(
        [string]$Status,
        [int]$Round,
        [hashtable]$Extra = @{}
    )
    $modeConfig = Get-ModeConfig
    $heartbeat = [ordered]@{
        timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        status    = $Status
        round     = $Round
        pid       = $PID
        mode      = $modeConfig.Mode
        sessions  = $modeConfig.Sessions
        interval  = $modeConfig.Interval
        maxIssues = $modeConfig.MaxIssues
        repos     = $Repos
        consecutiveFailures = $script:consecutiveFailures
    }
    foreach ($key in $Extra.Keys) { $heartbeat[$key] = $Extra[$key] }
    $heartbeat | ConvertTo-Json -Depth 4 | Out-File $heartbeatFile -Encoding utf8 -Force
}

# --- Helper: Append structured log entry (JSONL) ---
function Write-RalphLog {
    param(
        [int]$Round,
        [string]$Status,
        [int]$ExitCode,
        [double]$DurationSeconds,
        [string]$Phase = "round",
        [hashtable]$Metrics = @{},
        [string]$LogMode = ""
    )
    $logFileName = "ralph-$(Get-Date -Format 'yyyy-MM-dd').jsonl"
    $logPath = Join-Path $logsDir $logFileName
    $modeConfig = Get-ModeConfig

    $entry = [ordered]@{
        timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        round     = $Round
        phase     = $Phase
        status    = $Status
        mode      = if ($LogMode) { $LogMode } else { $modeConfig.Mode }
        sessions  = $modeConfig.Sessions
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

# --- Helper: Write failure alert to alerts.json ---
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

    # Load existing alerts or start fresh
    $alerts = @()
    if (Test-Path $alertsFile) {
        try {
            $existing = Get-Content $alertsFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($existing -is [System.Array]) { $alerts = @($existing) }
            elseif ($existing) { $alerts = @($existing) }
        } catch { $alerts = @() }
    }
    $alerts += $alert

    # Keep only last 50 alerts
    if ($alerts.Count -gt 50) {
        $alerts = $alerts | Select-Object -Last 50
    }

    $alerts | ConvertTo-Json -Depth 4 | Out-File $alertsFile -Encoding utf8 -Force
    Write-Host "   [ALERT] Written to $alertsFile" -ForegroundColor Red
}

# --- Helper: Parse metrics from copilot output ---
function Get-SessionMetrics {
    param([string]$Output)
    $metrics = @{
        issuesClosed = 0
        prsMerged    = 0
        prsOpened    = 0
        commitsCount = 0
    }
    if (-not $Output) { return $metrics }

    # Match patterns like "closed 3 issues", "2 issues closed", "issues closed: 5"
    if ($Output -match '(\d+)\s+issues?\s+closed') { $metrics.issuesClosed = [int]$Matches[1] }
    elseif ($Output -match 'closed\s+(\d+)\s+issues?') { $metrics.issuesClosed = [int]$Matches[1] }
    elseif ($Output -match 'issues?\s+closed[:\s]+(\d+)') { $metrics.issuesClosed = [int]$Matches[1] }

    # Match patterns like "merged 2 PRs", "3 PRs merged"
    if ($Output -match '(\d+)\s+PRs?\s+merged') { $metrics.prsMerged = [int]$Matches[1] }
    elseif ($Output -match 'merged\s+(\d+)\s+PRs?') { $metrics.prsMerged = [int]$Matches[1] }
    elseif ($Output -match 'PRs?\s+merged[:\s]+(\d+)') { $metrics.prsMerged = [int]$Matches[1] }

    # Match patterns like "opened 1 PR", "2 PRs opened"
    if ($Output -match '(\d+)\s+PRs?\s+opened') { $metrics.prsOpened = [int]$Matches[1] }
    elseif ($Output -match 'opened\s+(\d+)\s+PRs?') { $metrics.prsOpened = [int]$Matches[1] }
    elseif ($Output -match 'pull\s+requests?\s+opened[:\s]+(\d+)') { $metrics.prsOpened = [int]$Matches[1] }

    # Match commit counts
    if ($Output -match '(\d+)\s+commits?') { $metrics.commitsCount = [int]$Matches[1] }

    return $metrics
}

# --- Helper: Start background activity monitor ---
# Creates a runspace that prints periodic status while copilot runs,
# preventing a silent terminal during long sessions.
function Start-ActivityMonitor {
    param([int]$Round)

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $runspace

    [void]$ps.AddScript({
        param($round, $logsDir)
        $tick = 0
        while ($true) {
            Start-Sleep -Seconds 30
            $tick++
            $elapsed = $tick * 30
            $mins = [math]::Floor($elapsed / 60)
            $secs = $elapsed % 60
            $ts = (Get-Date -Format 'HH:mm:ss')

            # Check if today's log has new entries (sign of copilot activity)
            $todayLog = Join-Path $logsDir "ralph-$(Get-Date -Format 'yyyy-MM-dd').jsonl"
            $lineCount = 0
            if (Test-Path $todayLog) {
                $lineCount = (Get-Content $todayLog -ErrorAction SilentlyContinue | Measure-Object).Count
            }

            Write-Host "   [$ts] [monitor] Round $round active -- ${mins}m ${secs}s elapsed, $lineCount log entries today" -ForegroundColor DarkCyan
        }
    })
    [void]$ps.AddArgument($Round)
    [void]$ps.AddArgument($logsDir)

    $handle = $ps.BeginInvoke()
    return @{ PowerShell = $ps; Handle = $handle; Runspace = $runspace }
}

# --- Helper: Stop background activity monitor ---
function Stop-ActivityMonitor {
    param($Monitor)
    if ($Monitor -and $Monitor.PowerShell) {
        try {
            $Monitor.PowerShell.Stop()
            $Monitor.PowerShell.Dispose()
        } catch { }
    }
    if ($Monitor -and $Monitor.Runspace) {
        try { $Monitor.Runspace.Close() } catch { }
    }
}

# --- Helper: Git pull for a repo ---
function Invoke-GitPull {
    param([string]$RepoPath)
    Push-Location $RepoPath
    try {
        Write-Host "   [pull] Pulling latest in $RepoPath..." -ForegroundColor Gray
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would run: git fetch origin; git pull --rebase --autostash" -ForegroundColor Yellow
        } else {
            # Ensure we are on the default branch before pulling
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

# --- Helper: Run scheduler ---
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

# --- Helper: Validate git remote URL for a repo ---
function Test-RemoteUrl {
    param([string]$RepoPath)
    Push-Location $RepoPath
    try {
        $remoteUrl = git remote get-url origin 2>$null
        if (-not $remoteUrl) {
            Write-Host "   [!] No remote origin in $RepoPath" -ForegroundColor Yellow
            return $false
        }
        # Must point to jperezdelreal org
        if ($remoteUrl -notmatch 'jperezdelreal/') {
            Write-Host "   [BLOCK] Remote URL corrupted in $RepoPath : $remoteUrl" -ForegroundColor Red
            return $false
        }
        return $true
    } finally {
        Pop-Location
    }
}

# --- Helper: Verify repo is on correct branch after copilot session ---
function Test-RepoBranch {
    param([string]$RepoPath)
    Push-Location $RepoPath
    try {
        $currentBranch = git branch --show-current 2>$null
        $defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
        if ($defaultBranch) {
            $defaultBranch = $defaultBranch -replace 'refs/remotes/origin/', ''
        } else {
            $defaultBranch = "main"
        }
        # Squad branches are OK (squad/* pattern); only warn if on unexpected branch
        if ($currentBranch -ne $defaultBranch -and $currentBranch -notmatch '^squad/') {
            Write-Host "   [warn] $RepoPath on unexpected branch: $currentBranch" -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
}

# --- Helper: Get repo name from local path ---
function Get-RepoName {
    param([string]$RepoPath)
    $resolved = Resolve-Path $RepoPath -ErrorAction SilentlyContinue
    if ($resolved) { return (Split-Path $resolved.Path -Leaf) }
    return (Split-Path $RepoPath -Leaf)
}

# --- Helper: Check if repo has squad roster (G10) ---
function Test-HasSquadRoster {
    param([string]$RepoPath)
    $teamMdPath = Join-Path $RepoPath ".squad\team.md"
    if (-not (Test-Path $teamMdPath)) { return $false }
    try {
        $content = Get-Content $teamMdPath -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return $false }
        # Check for ## Members section (case-insensitive)
        return $content -match '(?m)^## Members'
    } catch {
        return $false
    }
}

# --- Helper: Sync hub content to downstream repos (G11) ---
function Invoke-UpstreamSync {
    param(
        [string]$HubPath,
        [string]$DownstreamPath
    )
    $downstreamName = Get-RepoName -RepoPath $DownstreamPath
    
    # Don't sync if downstream doesn't have .squad/ directory
    $downstreamSquadDir = Join-Path $DownstreamPath ".squad"
    if (-not (Test-Path $downstreamSquadDir)) {
        Write-Host "   [sync] Skipping $downstreamName -- no .squad/ directory" -ForegroundColor DarkGray
        return
    }

    Write-Host "   [sync] Syncing hub -> $downstreamName..." -ForegroundColor Cyan

    # Files and directories to sync from hub to downstream
    $syncItems = @(
        @{ Type = "Directory"; Path = ".squad\skills" },
        @{ Type = "File"; Path = ".squad\identity\quality-gates.md" },
        @{ Type = "File"; Path = ".squad\identity\governance.md" },
        @{ Type = "File"; Path = ".squad\decisions.md" },
        @{ Type = "File"; Path = ".github\agents\squad.agent.md" }
    )

    $syncedCount = 0
    foreach ($item in $syncItems) {
        $sourcePath = Join-Path $HubPath $item.Path
        $destPath = Join-Path $DownstreamPath $item.Path
        
        # Skip if source doesn't exist in hub
        if (-not (Test-Path $sourcePath)) {
            Write-Host "      [sync] Skipping $($item.Path) -- not found in hub" -ForegroundColor DarkGray
            continue
        }

        try {
            if ($script:DryRun) {
                Write-Host "      [DRY RUN] Would sync: $($item.Path)" -ForegroundColor Yellow
                $syncedCount++
            } else {
                # Ensure destination directory exists
                $destDir = Split-Path $destPath -Parent
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }

                if ($item.Type -eq "Directory") {
                    # Copy directory contents (not the dir itself) to avoid nested duplication
                    if (-not (Test-Path $destPath)) {
                        New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                    }
                    Copy-Item -Path "$sourcePath\*" -Destination $destPath -Recurse -Force -ErrorAction Stop
                } else {
                    # Copy single file
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

    # Check if there are changes to commit
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
                git push origin 2>&1 | Out-Null
                Write-Host "   [sync] $downstreamName : synced $syncedCount files, committed and pushed" -ForegroundColor Green
            }
        }
    } finally {
        Pop-Location
    }
}

# --- Helper: Fetch and filter issues for scheduling ---
# Returns array of issue objects sorted by priority, then repo issue count, then game > hub
function Get-ScheduledIssues {
    param(
        [string[]]$RepoNames,
        [int]$TotalMaxIssues
    )
    $allIssues = @()
    $repoIssueCounts = @{}

    foreach ($repoName in $RepoNames) {
        # G10: Check if repo has squad roster before fetching issues
        $repoPath = $script:Repos | Where-Object { (Get-RepoName $_) -eq $repoName } | Select-Object -First 1
        if ($repoPath) {
            $resolvedPath = Resolve-Path $repoPath -ErrorAction SilentlyContinue
            if ($resolvedPath -and -not (Test-HasSquadRoster -RepoPath $resolvedPath.Path)) {
                Write-Host "   [roster] Skipping $repoName -- no squad roster (missing .squad\team.md or ## Members section)" -ForegroundColor DarkYellow
                continue
            }
        }

        $ghRepo = $repoGitHubMap[$repoName]
        if (-not $ghRepo) { continue }

        Write-Host "   [sched] Fetching issues from $ghRepo..." -ForegroundColor DarkGray
        try {
            $raw = gh issue list -R $ghRepo --state open --label "squad" --json number,title,labels --limit 30 2>$null
            if (-not $raw) { continue }
            $issues = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            if (-not $issues) { continue }

            $repoIssueCounts[$repoName] = $issues.Count

            foreach ($issue in $issues) {
                $labelNames = @()
                if ($issue.labels) {
                    $labelNames = @($issue.labels | ForEach-Object {
                        if ($_ -is [string]) { $_ } elseif ($_.name) { $_.name } else { "$_" }
                    })
                }

                # Governance filter: skip T0 entirely, skip T1 unless approved
                # Issues without tier label default to T2 (safe to work)
                # Take the MOST RESTRICTIVE (lowest-numbered) tier if multiple labels exist
                $tier = "t2"
                $tierNum = 2
                foreach ($l in $labelNames) {
                    if ($l -match '^tier:t(\d)$') {
                        $t = [int]$Matches[1]
                        if ($t -lt $tierNum) { $tierNum = $t; $tier = "t$t" }
                    }
                }
                if ($tier -eq "t0") {
                    Write-Host "      [gov] Skipping #$($issue.number) ($($issue.title)) -- tier:t0 needs founder approval" -ForegroundColor DarkYellow
                    continue
                }
                if ($tier -eq "t1") {
                    Write-Host "      [gov] Skipping #$($issue.number) ($($issue.title)) -- tier:t1 needs Solo+Founder approval" -ForegroundColor DarkYellow
                    continue
                }
                # Skip issues marked as needing research (not ready for implementation)
                if ($labelNames -contains "go:needs-research") {
                    Write-Host "      [gov] Skipping #$($issue.number) ($($issue.title)) -- needs-research, not ready" -ForegroundColor DarkYellow
                    continue
                }

                # Extract priority (default P3 if not labeled)
                $priority = 3
                foreach ($l in $labelNames) {
                    if ($l -match '^priority:p(\d)$') {
                        $priority = [int]$Matches[1]
                        break
                    }
                }

                # Check for blocked-by:* labels
                $isBlocked = $false
                foreach ($l in $labelNames) {
                    if ($l -match '^blocked-by:') {
                        $isBlocked = $true
                        break
                    }
                }

                # Skip blocked P3 issues entirely
                if ($isBlocked -and $priority -ge 3) {
                    Write-Host "      [dep] Skipping #$($issue.number) ($($issue.title)) -- blocked P3, not worth preparing" -ForegroundColor DarkYellow
                    continue
                }

                $isGame = $gameRepoNames -contains $repoName
                $allIssues += [PSCustomObject]@{
                    Number    = $issue.number
                    Title     = $issue.title
                    RepoName  = $repoName
                    GhRepo    = $ghRepo
                    Priority  = $priority
                    IsGame    = $isGame
                    IsBlocked = $isBlocked
                    Labels    = $labelNames
                }
            }
        } catch {
            Write-Host "   [!] Failed to fetch issues from ${ghRepo}: $_" -ForegroundColor Yellow
        }
    }

    # Sort: blocked last, then priority ASC (P0 first), repo issue count DESC, game repos first
    $sorted = $allIssues | Sort-Object @(
        @{ Expression = { $_.IsBlocked }; Ascending = $true },
        @{ Expression = { $_.Priority }; Ascending = $true },
        @{ Expression = { $repoIssueCounts[$_.RepoName] }; Ascending = $false },
        @{ Expression = { $_.IsGame }; Ascending = $false }
    )

    if ($TotalMaxIssues -gt 0) {
        $sorted = $sorted | Select-Object -First $TotalMaxIssues
    }
    return @($sorted)
}

# --- Helper: Group issues by repo for session assignment ---
# Each session gets exactly 1 repo (never mix repos)
function Get-SessionAssignments {
    param(
        [object[]]$Issues,
        [int]$SessionCount,
        [int]$MaxPerSession
    )
    # Group by repo, maintain priority order within each group
    $byRepo = @{}
    foreach ($issue in $Issues) {
        $repo = $issue.RepoName
        if (-not $byRepo.ContainsKey($repo)) { $byRepo[$repo] = @() }
        $byRepo[$repo] += $issue
    }

    # Sort repo groups by their highest-priority issue
    $repoOrder = $byRepo.Keys | Sort-Object {
        ($byRepo[$_] | Measure-Object -Property Priority -Minimum).Minimum
    }

    $assignments = @()
    $sessionIdx = 0
    foreach ($repo in $repoOrder) {
        if ($sessionIdx -ge $SessionCount) { break }
        $repoIssues = $byRepo[$repo] | Select-Object -First $MaxPerSession
        $assignments += @{
            Repo   = $repo
            GhRepo = $repoGitHubMap[$repo]
            Issues = @($repoIssues)
        }
        $sessionIdx++
    }
    return ,@($assignments)
}

# --- Helper: Run a single copilot session ---
function Invoke-CopilotSession {
    param(
        [string]$RepoFullName,
        [object[]]$Issues,
        [int]$SessionId,
        [int]$Round
    )
    # Build issue lines for prompt (include labels for PR label inheritance)
    $issueLines = @()
    foreach ($iss in $Issues) {
        $labelStr = ""
        if ($iss.Labels -and $iss.Labels.Count -gt 0) {
            $labelStr = " labels:($($iss.Labels -join ', '))"
        }
        $blockStr = if ($iss.IsBlocked) { " [PREPARE-ONLY]" } else { "" }
        $issueLines += "- #$($iss.Number): $($iss.Title) [P$($iss.Priority)]$blockStr$labelStr"
    }
    $prompt = Build-SessionPrompt -RepoFullName $RepoFullName -IssueLines $issueLines

    Write-Host "   [session $SessionId] Spawning copilot for $RepoFullName ($($Issues.Count) issues)..." -ForegroundColor Cyan
    foreach ($line in $issueLines) {
        Write-Host "      $line" -ForegroundColor DarkGray
    }

    $output = copilot --agent squad --yolo -p $prompt 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    return @{
        Output   = $output
        ExitCode = $exitCode
        Repo     = $RepoFullName
    }
}

# --- (Invoke-ParallelSessions removed: Start-Job causes copilot CLI serialization failures) ---

# --- Validate repos: filter to only those that exist ---
$validRepos = @()
$skippedRepos = @()
foreach ($repo in $Repos) {
    $resolved = Resolve-Path $repo -ErrorAction SilentlyContinue
    if ($resolved) {
        $validRepos += $repo
    } else {
        $skippedRepos += $repo
    }
}
if ($validRepos.Count -eq 0) {
    Write-Host "[!] No valid repo paths found. Falling back to current directory." -ForegroundColor Yellow
    $validRepos = @(".")
}

# Build list of valid repo names for issue scheduling
$validRepoNames = @()
foreach ($repo in $validRepos) {
    $name = Get-RepoName -RepoPath $repo
    if ($repoGitHubMap.ContainsKey($name)) {
        $validRepoNames += $name
    }
}

# --- Main loop ---
$round = 0
$initMode = Get-ModeConfig

Write-Host ""
Write-Host "[ralph] Ralph Watch v3 - First Frame Studios (Night/Day Mode)" -ForegroundColor Cyan
Write-Host "   Mode:      $($initMode.Mode) (sessions=$($initMode.Sessions), interval=$($initMode.Interval)m, maxIssues=$($initMode.MaxIssues)/session)" -ForegroundColor Gray
Write-Host "   Repos:     $($validRepos -join ', ')" -ForegroundColor Gray
if ($skippedRepos.Count -gt 0) {
    Write-Host "   Skipped:   $($skippedRepos -join ', ') (not found)" -ForegroundColor Yellow
}
Write-Host "   Heartbeat: $heartbeatFile" -ForegroundColor Gray
Write-Host "   Logs:      $logsDir" -ForegroundColor Gray
Write-Host "   Alerts:    $alertsFile" -ForegroundColor Gray
Write-Host "   Lock:      $lockFile" -ForegroundColor Gray
if ($DryRun)    { Write-Host "   DryRun:    YES" -ForegroundColor Yellow }
if ($MaxRounds) { Write-Host "   MaxRounds: $MaxRounds" -ForegroundColor Yellow }
Write-Host "   Press Ctrl+C to stop (waits for current round to finish)" -ForegroundColor Gray
Write-Host "   To stop after current round: create file tools\.ralph-stop" -ForegroundColor Gray
Write-Host ""

$stopFile = Join-Path $PSScriptRoot ".ralph-stop"
if (Test-Path $stopFile) { Remove-Item $stopFile -Force }

try {
while ($true) {
    $round++
    $roundStart = Get-Date
    $timestamp = $roundStart.ToString('yyyy-MM-ddTHH:mm:ss')
    $modeConfig = Get-ModeConfig
    $currentMode = $modeConfig.Mode
    $sessionCount = $modeConfig.Sessions
    $intervalMinutes = $modeConfig.Interval
    $maxIssuesPerSess = $modeConfig.MaxIssues

    # Log mode transitions
    if ($lastMode -ne "" -and $lastMode -ne $currentMode) {
        Write-Host "[$timestamp] [mode] Transition: $lastMode -> $currentMode" -ForegroundColor Magenta
        Write-RalphLog -Round $round -Status "MODE_CHANGE" -ExitCode 0 -DurationSeconds 0 -Phase "mode-transition" -LogMode $currentMode
    }
    $lastMode = $currentMode

    Write-Host "[$timestamp] [>>] Round $round starting (mode=$currentMode, sessions=$sessionCount, interval=${intervalMinutes}m, maxIssues=$maxIssuesPerSess)..." -ForegroundColor Green
    Update-Heartbeat -Status "running" -Round $round

    # Step 1: Validate remote URLs for all repos
    $remoteOk = $true
    foreach ($repo in $validRepos) {
        $resolvedPath = Resolve-Path $repo -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            if (-not (Test-RemoteUrl -RepoPath $resolvedPath.Path)) {
                $remoteOk = $false
                Write-Host "   [BLOCK] Skipping round $round -- remote URL validation failed" -ForegroundColor Red
                break
            }
        }
    }
    if (-not $remoteOk) {
        Write-RalphLog -Round $round -Status "BLOCKED" -ExitCode -1 -DurationSeconds 0 -Phase "remote-validation"
        $consecutiveFailures++
        if ($consecutiveFailures -ge $alertThreshold) {
            Write-FailureAlert -Round $round -Failures $consecutiveFailures -ExitCode -1 -ErrorMessage "Remote URL validation failed"
        }
        Write-Host "   Next round in $intervalMinutes minutes..." -ForegroundColor Gray
        Start-Sleep -Seconds ($intervalMinutes * 60)
        continue
    }

    # Step 2: Pull latest code for each repo
    foreach ($repo in $validRepos) {
        $resolvedPath = Resolve-Path $repo -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            Invoke-GitPull -RepoPath $resolvedPath.Path
        } else {
            Write-Host "   [!] Repo path not found: $repo" -ForegroundColor Yellow
        }
    }

    # Step 2.5: Upstream sync (G11) - sync hub content to downstream repos
    if ($validRepos.Count -gt 0) {
        $hubPath = Resolve-Path $validRepos[0] -ErrorAction SilentlyContinue
        if ($hubPath) {
            $hubName = Get-RepoName -RepoPath $hubPath.Path
            # Sync to all downstream repos (skip the hub itself)
            foreach ($repo in $validRepos | Select-Object -Skip 1) {
                $downstreamPath = Resolve-Path $repo -ErrorAction SilentlyContinue
                if ($downstreamPath) {
                    Invoke-UpstreamSync -HubPath $hubPath.Path -DownstreamPath $downstreamPath.Path
                }
            }
        }
    }

    # Step 3: Run scheduler
    Invoke-Scheduler

    # Step 4: Fetch and schedule issues with governance filter
    $totalMaxIssues = $sessionCount * $maxIssuesPerSess
    $exitCode = 0
    $copilotOutput = ""
    $metrics = @{ issuesClosed = 0; prsMerged = 0; prsOpened = 0; commitsCount = 0 }
    $monitor = $null

    try {
        if ($DryRun) {
            Write-Host "   [DRY RUN] Fetching issues for scheduling..." -ForegroundColor Yellow
            $scheduledIssues = Get-ScheduledIssues -RepoNames $validRepoNames -TotalMaxIssues $totalMaxIssues
            $assignments = Get-SessionAssignments -Issues $scheduledIssues -SessionCount $sessionCount -MaxPerSession $maxIssuesPerSess
            Write-Host "   [DRY RUN] Would run $($assignments.Count) session(s) with $($scheduledIssues.Count) issue(s) total" -ForegroundColor Yellow
            foreach ($a in $assignments) {
                Write-Host "   [DRY RUN]   Session: $($a.GhRepo) -- $($a.Issues.Count) issues" -ForegroundColor Yellow
                foreach ($iss in $a.Issues) {
                    $lbls = if ($iss.Labels) { $iss.Labels -join ', ' } else { '(none)' }
                    Write-Host "   [DRY RUN]     #$($iss.Number): $($iss.Title) [P$($iss.Priority)] labels:[$lbls]" -ForegroundColor Yellow
                }
            }
            $exitCode = 0
            $copilotOutput = "[DRY RUN] No output captured"
        } else {
            # Fetch and prioritize issues
            $scheduledIssues = Get-ScheduledIssues -RepoNames $validRepoNames -TotalMaxIssues $totalMaxIssues
            $assignments = Get-SessionAssignments -Issues $scheduledIssues -SessionCount $sessionCount -MaxPerSession $maxIssuesPerSess

            if ($assignments.Count -eq 0) {
                Write-Host "   [info] No actionable issues found across repos. Skipping copilot session." -ForegroundColor DarkGray
                $exitCode = 0
                $copilotOutput = "No issues to work on"
            } else {
                # Run all assignments sequentially (night or day)
                # Night mode = more issues + shorter interval, NOT parallel Start-Job
                # (Start-Job causes prompt serialization failures with copilot CLI)
                if ($assignments.Count -gt 1) {
                    Write-Host "   [night] Running $($assignments.Count) session(s) sequentially..." -ForegroundColor Magenta
                }

                $allOutput = @()
                $worstExit = 0
                $sessionNum = 0
                foreach ($a in $assignments) {
                    $sessionNum++
                    $monitor = Start-ActivityMonitor -Round $round
                    Update-Heartbeat -Status "running" -Round $round -Extra @{ phase = "session-$sessionNum-of-$($assignments.Count)" }
                    $result = Invoke-CopilotSession -RepoFullName $a.GhRepo -Issues $a.Issues -SessionId $sessionNum -Round $round
                    if ($result.Output) { $allOutput += $result.Output }
                    if ($result.ExitCode -ne 0) { $worstExit = $result.ExitCode }
                    Stop-ActivityMonitor -Monitor $monitor
                    $monitor = $null
                }
                $copilotOutput = $allOutput -join "`n---SESSION BOUNDARY---`n"
                $exitCode = $worstExit
            }
            if ($false) {
                # REMOVED: old day-mode path and parallel sessions path
            }

            # Parse metrics from copilot output
            $metrics = Get-SessionMetrics -Output $copilotOutput

            # Post-session: verify repos are on correct branches
            foreach ($repo in $validRepos) {
                $resolvedPath = Resolve-Path $repo -ErrorAction SilentlyContinue
                if ($resolvedPath) {
                    Test-RepoBranch -RepoPath $resolvedPath.Path
                }
            }
        }

        $roundEnd = Get-Date
        $duration = ($roundEnd - $roundStart).TotalSeconds

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
                metrics      = $metrics
            }
            Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [FAIL] Round $round failed, exit code $exitCode ($([math]::Round($duration, 1))s)" -ForegroundColor Red

            # Failure alert after threshold
            if ($consecutiveFailures -ge $alertThreshold) {
                Write-Host "   [ALERT] $consecutiveFailures consecutive failures -- writing alert" -ForegroundColor Red
                Write-FailureAlert -Round $round -Failures $consecutiveFailures -ExitCode $exitCode
            }
            # Circuit breaker: pause 1 hour after too many consecutive failures
            if ($consecutiveFailures -ge $circuitBreakerThreshold) {
                Write-Host "   [CIRCUIT BREAKER] $consecutiveFailures consecutive failures. Pausing 1 hour." -ForegroundColor Red
                Write-RalphLog -Round $round -Status "CIRCUIT_BREAKER" -ExitCode $exitCode -DurationSeconds 0 -Phase "cooldown"
                Start-Sleep -Seconds 3600
                $consecutiveFailures = 0
            }
        }
    } catch {
        # Ensure monitor is stopped on exception
        if ($monitor) { Stop-ActivityMonitor -Monitor $monitor }

        $consecutiveFailures++
        $roundEnd = Get-Date
        $duration = ($roundEnd - $roundStart).TotalSeconds
        Write-RalphLog -Round $round -Status "ERROR" -ExitCode -1 -DurationSeconds $duration
        Update-Heartbeat -Status "idle" -Round $round -Extra @{
            lastDuration = [math]::Round($duration, 1)
            lastStatus   = "ERROR"
        }
        Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [!] Round $round exception: $_" -ForegroundColor Red

        # Failure alert after threshold
        if ($consecutiveFailures -ge $alertThreshold) {
            Write-Host "   [ALERT] $consecutiveFailures consecutive failures -- writing alert" -ForegroundColor Red
            Write-FailureAlert -Round $round -Failures $consecutiveFailures -ExitCode -1 -ErrorMessage "$_"
        }
    }

    # Check MaxRounds limit
    if ($MaxRounds -gt 0 -and $round -ge $MaxRounds) {
        Write-Host ""
        Write-Host "[end] Reached MaxRounds ($MaxRounds). Stopping." -ForegroundColor Cyan
        break
    }

    # Check stop file (graceful stop after round)
    if (Test-Path $stopFile) {
        Write-Host ""
        Write-Host "[end] Stop file detected (tools/.ralph-stop). Stopping gracefully." -ForegroundColor Cyan
        Remove-Item $stopFile -Force -ErrorAction SilentlyContinue
        break
    }

    Write-Host "   Next round in $intervalMinutes minutes..." -ForegroundColor Gray
    Write-Host ""

    # Sleep in 10s chunks so Ctrl+C is responsive
    $sleepTotal = $intervalMinutes * 60
    $slept = 0
    while ($slept -lt $sleepTotal) {
        $chunk = [Math]::Min(10, $sleepTotal - $slept)
        Start-Sleep -Seconds $chunk
        $slept += $chunk
        # Check stop file during sleep too
        if (Test-Path $stopFile) {
            Write-Host ""
            Write-Host "[end] Stop file detected during sleep. Stopping gracefully." -ForegroundColor Cyan
            Remove-Item $stopFile -Force -ErrorAction SilentlyContinue
            $slept = $sleepTotal + 1  # break out
        }
    }
    if ($slept -gt $sleepTotal) { break }
}
} finally {
    # Cleanup on exit (Ctrl+C or normal stop)
    Write-Host ""
    Write-Host "[ralph] Shutting down..." -ForegroundColor Yellow
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    Update-Heartbeat -Status "stopped" -Round $round
    Write-Host "[ralph] Ralph Watch stopped. Round $round was the last." -ForegroundColor Cyan
}
