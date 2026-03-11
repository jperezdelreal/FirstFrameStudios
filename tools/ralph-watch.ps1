# Ralph Watch — Autonomous Squad Agent Outer Loop
# First Frame Studios — Adapted from Tamir Dresher's squad-personal-demo
#
# Launches Ralph in a persistent loop: pull latest, run scheduler, spawn Copilot, log results.
# To stop: Ctrl+C
#
# Usage:
#   .\tools\ralph-watch.ps1                          # default 15-min interval
#   .\tools\ralph-watch.ps1 -IntervalMinutes 5       # 5-min interval
#   .\tools\ralph-watch.ps1 -DryRun                  # show what would happen
#   .\tools\ralph-watch.ps1 -MaxRounds 3             # stop after 3 rounds (testing)
#   .\tools\ralph-watch.ps1 -Repos @(".", "../other-repo")

param(
    [int]$IntervalMinutes = 15,
    [switch]$DryRun,
    [int]$MaxRounds = 0,
    [string[]]$Repos = @(".")
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
$schedulerScript = Join-Path $scriptRoot "scheduler\Invoke-SquadScheduler.ps1"
$maxLogBytes = 1048576  # 1MB

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
    # Stale lock from a crashed process — clean it up
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

# --- Ralph prompt ---
$ralphPrompt = @'
Ralph, Go!
MAXIMIZE PARALLELISM: For every round, identify ALL actionable issues and spawn agents for ALL of them simultaneously.
Scan repo for issues labeled 'squad' or 'status:todo'. Work them all.
After completing work, report what was done.
'@

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
        [string]$Phase = "round"
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
    }
    ($entry | ConvertTo-Json -Compress) | Add-Content -Path $logPath -Encoding utf8

    # Log rotation: if file exceeds 1MB, rotate to .1
    if ((Test-Path $logPath) -and ((Get-Item $logPath).Length -gt $maxLogBytes)) {
        $rotated = $logPath -replace '\.jsonl$', '.1.jsonl'
        Move-Item $logPath $rotated -Force -ErrorAction SilentlyContinue
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

# --- Main loop ---
$round = 0

Write-Host ""
Write-Host "[ralph] Ralph Watch - First Frame Studios" -ForegroundColor Cyan
Write-Host "   Interval:  $IntervalMinutes minutes" -ForegroundColor Gray
Write-Host "   Repos:     $($Repos -join ', ')" -ForegroundColor Gray
Write-Host "   Heartbeat: $heartbeatFile" -ForegroundColor Gray
Write-Host "   Logs:      $logsDir" -ForegroundColor Gray
Write-Host "   Lock:      $lockFile" -ForegroundColor Gray
if ($DryRun)    { Write-Host "   Mode:      DRY RUN" -ForegroundColor Yellow }
if ($MaxRounds) { Write-Host "   MaxRounds: $MaxRounds" -ForegroundColor Yellow }
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

while ($true) {
    $round++
    $roundStart = Get-Date
    $timestamp = $roundStart.ToString('yyyy-MM-ddTHH:mm:ss')

    Write-Host "[$timestamp] >> Round $round starting..." -ForegroundColor Green
    Update-Heartbeat -Status "running" -Round $round

    # Step 1: Pull latest code for each repo
    foreach ($repo in $Repos) {
        $resolvedPath = Resolve-Path $repo -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            Invoke-GitPull -RepoPath $resolvedPath.Path
        } else {
            Write-Host "   [!] Repo path not found: $repo" -ForegroundColor Yellow
        }
    }

    # Step 2: Run scheduler
    Invoke-Scheduler

    # Step 3: Spawn Copilot CLI
    $exitCode = 0
    try {
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would spawn: copilot -p `"$($ralphPrompt.Substring(0, 60))...`"" -ForegroundColor Yellow
            $exitCode = 0
        } else {
            Write-Host "   [>>] Spawning Copilot session..." -ForegroundColor Cyan
            copilot -p $ralphPrompt
            $exitCode = $LASTEXITCODE
        }

        $roundEnd = Get-Date
        $duration = ($roundEnd - $roundStart).TotalSeconds

        if ($exitCode -eq 0) {
            Write-RalphLog -Round $round -Status "OK" -ExitCode $exitCode -DurationSeconds $duration
            Update-Heartbeat -Status "idle" -Round $round -Extra @{ lastDuration = [math]::Round($duration, 1); lastStatus = "OK" }
            Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [OK] Round $round complete ($([math]::Round($duration, 1))s)" -ForegroundColor Green
        } else {
            Write-RalphLog -Round $round -Status "FAIL" -ExitCode $exitCode -DurationSeconds $duration
            Update-Heartbeat -Status "idle" -Round $round -Extra @{ lastDuration = [math]::Round($duration, 1); lastStatus = "FAIL" }
            Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [FAIL] Round $round failed, exit code $exitCode ($([math]::Round($duration, 1))s)" -ForegroundColor Red
        }
    } catch {
        $roundEnd = Get-Date
        $duration = ($roundEnd - $roundStart).TotalSeconds
        Write-RalphLog -Round $round -Status "ERROR" -ExitCode -1 -DurationSeconds $duration
        Update-Heartbeat -Status "idle" -Round $round -Extra @{ lastDuration = [math]::Round($duration, 1); lastStatus = "ERROR" }
        Write-Host "[$($roundEnd.ToString('yyyy-MM-ddTHH:mm:ss'))] [!] Round $round exception: $_" -ForegroundColor Red
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
