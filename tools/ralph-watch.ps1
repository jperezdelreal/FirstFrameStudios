# Ralph Watch v2 -- Autonomous Squad Agent Outer Loop
# First Frame Studios -- Adapted from Tamir Dresher's squad-personal-demo
#
# Launches Ralph in a persistent loop: pull latest, run scheduler, spawn Copilot, log results.
# To stop: Ctrl+C
#
# v2 features (inspired by Tamir's ralph-watch.ps1):
#   - Failure alerts: tracks consecutive failures, writes to tools/logs/alerts.json after 3+
#   - Background activity monitor: runspace tails copilot output while session runs
#   - Multi-repo defaults: watches all 4 FFS repos by default
#   - Metrics parsing: extracts issues closed, PRs merged from copilot output
#
# Usage:
#   .\tools\ralph-watch.ps1                          # default 15-min interval, all FFS repos
#   .\tools\ralph-watch.ps1 -IntervalMinutes 5       # 5-min interval
#   .\tools\ralph-watch.ps1 -DryRun                  # show what would happen
#   .\tools\ralph-watch.ps1 -MaxRounds 3             # stop after 3 rounds (testing)
#   .\tools\ralph-watch.ps1 -Repos @(".", "../other-repo")

param(
    [int]$IntervalMinutes = 15,
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
    # Stale lock from a crashed process -- clean it up
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}

# Write lock
[ordered]@{
    pid     = $PID
    started = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
    directory = $repoRoot
} | ConvertTo-Json | Out-File $lockFile -Encoding utf8 -Force

# Clean up lock on exit
Register-EngineEvent PowerShell.Exiting -Action { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue } | Out-Null
trap { Remove-Item $lockFile -Force -ErrorAction SilentlyContinue; break }

# --- Ralph prompt (multi-repo aware) ---
$repoList = ($Repos | ForEach-Object { "  - $_" }) -join "`n"
$ralphPrompt = @"
Ralph, Go!
MAXIMIZE PARALLELISM: For every round, identify ALL actionable issues and spawn agents for ALL of them simultaneously.

MULTI-REPO WATCH: You are watching multiple repositories. Scan ALL of them for work:
$repoList

For each repo, check for issues labeled 'squad' or 'status:todo'. Work them all across every repo.
After completing work, report what was done. Include counts: issues closed, PRs merged, PRs opened.
"@

# --- Helper: Update heartbeat file ---
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
        interval  = $IntervalMinutes
        repos     = $Repos
        consecutiveFailures = $script:consecutiveFailures
    }
    foreach ($key in $Extra.Keys) { $heartbeat[$key] = $Extra[$key] }
    $heartbeat | ConvertTo-Json | Out-File $heartbeatFile -Encoding utf8 -Force
}

# --- Helper: Append structured log entry (JSONL) ---
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

# --- Main loop ---
$round = 0

Write-Host ""
Write-Host "[ralph] Ralph Watch v2 - First Frame Studios" -ForegroundColor Cyan
Write-Host "   Interval:  $IntervalMinutes minutes" -ForegroundColor Gray
Write-Host "   Repos:     $($validRepos -join ', ')" -ForegroundColor Gray
if ($skippedRepos.Count -gt 0) {
    Write-Host "   Skipped:   $($skippedRepos -join ', ') (not found)" -ForegroundColor Yellow
}
Write-Host "   Heartbeat: $heartbeatFile" -ForegroundColor Gray
Write-Host "   Logs:      $logsDir" -ForegroundColor Gray
Write-Host "   Alerts:    $alertsFile" -ForegroundColor Gray
Write-Host "   Lock:      $lockFile" -ForegroundColor Gray
if ($DryRun)    { Write-Host "   Mode:      DRY RUN" -ForegroundColor Yellow }
if ($MaxRounds) { Write-Host "   MaxRounds: $MaxRounds" -ForegroundColor Yellow }
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

while ($true) {
    $round++
    $roundStart = Get-Date
    $timestamp = $roundStart.ToString('yyyy-MM-ddTHH:mm:ss')

    Write-Host "[$timestamp] [>>] Round $round starting..." -ForegroundColor Green
    Update-Heartbeat -Status "running" -Round $round

    # Step 1: Pull latest code for each repo
    foreach ($repo in $validRepos) {
        $resolvedPath = Resolve-Path $repo -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            Invoke-GitPull -RepoPath $resolvedPath.Path
        } else {
            Write-Host "   [!] Repo path not found: $repo" -ForegroundColor Yellow
        }
    }

    # Step 2: Run scheduler
    Invoke-Scheduler

    # Step 3: Spawn Copilot CLI with activity monitor
    $exitCode = 0
    $copilotOutput = ""
    $metrics = @{}
    $monitor = $null

    try {
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would spawn: copilot -p `"$($ralphPrompt.Substring(0, 60))...`"" -ForegroundColor Yellow
            Write-Host "   [DRY RUN] Activity monitor would run in background" -ForegroundColor Yellow
            Write-Host "   [DRY RUN] Would parse metrics from copilot output" -ForegroundColor Yellow
            $exitCode = 0
            $copilotOutput = "[DRY RUN] No output captured"
            $metrics = @{ issuesClosed = 0; prsMerged = 0; prsOpened = 0; commitsCount = 0 }
        } else {
            Write-Host "   [>>] Spawning Copilot session..." -ForegroundColor Cyan

            # Start activity monitor in background runspace
            $monitor = Start-ActivityMonitor -Round $round
            Write-Host "   [monitor] Background activity monitor started" -ForegroundColor DarkCyan

            # Capture copilot output for metrics parsing
            $copilotOutput = copilot -p $ralphPrompt 2>&1 | Out-String
            $exitCode = $LASTEXITCODE

            # Stop the activity monitor
            Stop-ActivityMonitor -Monitor $monitor
            $monitor = $null
            Write-Host "   [monitor] Activity monitor stopped" -ForegroundColor DarkCyan

            # Parse metrics from copilot output
            $metrics = Get-SessionMetrics -Output $copilotOutput
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
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
        break
    }

    Write-Host "   Next round in $IntervalMinutes minutes..." -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds ($IntervalMinutes * 60)
}
