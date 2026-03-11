# collect-daily-metrics.ps1 -- Daily studio productivity metrics collector
# First Frame Studios -- Jango (Tool Engineer)
#
# Collects issues opened/closed, PRs opened/merged, active contributors,
# and ralph-watch round metrics across all FFS repos.
#
# Usage:
#   .\tools\collect-daily-metrics.ps1                   # collect for today
#   .\tools\collect-daily-metrics.ps1 -Date 2026-03-11  # collect for a specific date
#   .\tools\collect-daily-metrics.ps1 -DryRun           # preview without writing file
#
# Output: tools/metrics/YYYY-MM-DD.json
#
# Requirements: gh CLI authenticated, PowerShell 5.1+
# ASCII-safe: no emojis or unicode characters in this script.

param(
    [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
    [switch]$DryRun,
    [string]$Owner = "jperezdelreal",
    [string[]]$RepoNames = @(
        "FirstFrameStudios",
        "ComeRosquillas",
        "flora",
        "ffs-squad-monitor"
    )
)

# --- Configuration ---
$epoch = [datetime]::Parse("2026-03-11T16:31:48Z").ToUniversalTime()
$targetDate = [datetime]::Parse($Date)
$dayNumber = [math]::Floor(($targetDate - $epoch.Date).TotalDays)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$metricsDir = Join-Path $scriptRoot "metrics"
$logsDir = Join-Path $scriptRoot "logs"
$outputFile = Join-Path $metricsDir "$Date.json"

# Ensure output directory exists
if (-not (Test-Path $metricsDir)) {
    New-Item -ItemType Directory -Path $metricsDir -Force | Out-Null
}

Write-Host "[collect-daily-metrics] Collecting metrics for $Date (day $dayNumber)" -ForegroundColor Cyan

# --- Helper: Query GitHub for repo metrics ---
function Get-RepoMetrics {
    param(
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$TargetDate
    )

    $fullRepo = "$RepoOwner/$RepoName"
    $nextDay = ([datetime]::Parse($TargetDate)).AddDays(1).ToString('yyyy-MM-dd')

    Write-Host "  [repo] $fullRepo ..." -ForegroundColor Gray

    # Issues opened today
    $issuesOpened = 0
    try {
        $result = gh issue list -R $fullRepo --state all --json createdAt --search "created:$TargetDate..$TargetDate" -L 200 2>$null
        if ($result) {
            $parsed = $result | ConvertFrom-Json
            $issuesOpened = ($parsed | Where-Object {
                $_.createdAt -and $_.createdAt.Substring(0, 10) -eq $TargetDate
            } | Measure-Object).Count
        }
    } catch {
        Write-Host "    [warn] Could not fetch issues opened for $fullRepo" -ForegroundColor Yellow
    }

    # Issues closed today
    $issuesClosed = 0
    try {
        $result = gh issue list -R $fullRepo --state closed --json closedAt -L 200 --search "closed:$TargetDate..$TargetDate" 2>$null
        if ($result) {
            $parsed = $result | ConvertFrom-Json
            $issuesClosed = ($parsed | Where-Object {
                $_.closedAt -and $_.closedAt.Substring(0, 10) -eq $TargetDate
            } | Measure-Object).Count
        }
    } catch {
        Write-Host "    [warn] Could not fetch issues closed for $fullRepo" -ForegroundColor Yellow
    }

    # PRs opened today
    $prsOpened = 0
    try {
        $result = gh pr list -R $fullRepo --state all --json createdAt --search "created:$TargetDate..$TargetDate" -L 200 2>$null
        if ($result) {
            $parsed = $result | ConvertFrom-Json
            $prsOpened = ($parsed | Where-Object {
                $_.createdAt -and $_.createdAt.Substring(0, 10) -eq $TargetDate
            } | Measure-Object).Count
        }
    } catch {
        Write-Host "    [warn] Could not fetch PRs opened for $fullRepo" -ForegroundColor Yellow
    }

    # PRs merged today
    $prsMerged = 0
    try {
        $result = gh pr list -R $fullRepo --state merged --json mergedAt --search "merged:$TargetDate..$TargetDate" -L 200 2>$null
        if ($result) {
            $parsed = $result | ConvertFrom-Json
            $prsMerged = ($parsed | Where-Object {
                $_.mergedAt -and $_.mergedAt.Substring(0, 10) -eq $TargetDate
            } | Measure-Object).Count
        }
    } catch {
        Write-Host "    [warn] Could not fetch PRs merged for $fullRepo" -ForegroundColor Yellow
    }

    # Active contributors (from commits on that date)
    $contributors = @()
    try {
        $result = gh api "repos/$fullRepo/commits?since=${TargetDate}T00:00:00Z&until=${nextDay}T00:00:00Z&per_page=100" 2>$null
        if ($result) {
            $commits = $result | ConvertFrom-Json
            $contributors = @($commits | ForEach-Object {
                if ($_.author -and $_.author.login) { $_.author.login }
                elseif ($_.commit -and $_.commit.author -and $_.commit.author.name) { $_.commit.author.name }
            } | Where-Object { $_ } | Sort-Object -Unique)
        }
    } catch {
        Write-Host "    [warn] Could not fetch contributors for $fullRepo" -ForegroundColor Yellow
    }

    return [ordered]@{
        issues_opened = $issuesOpened
        issues_closed = $issuesClosed
        prs_opened    = $prsOpened
        prs_merged    = $prsMerged
        contributors  = $contributors
    }
}

# --- Helper: Parse ralph-watch logs for the target date ---
function Get-RalphMetrics {
    param([string]$TargetDate)

    $ralphLog = Join-Path $logsDir "ralph-$TargetDate.jsonl"
    $result = [ordered]@{
        rounds           = 0
        duration_minutes = 0
        issues_processed = 0
        prs_merged       = 0
    }

    if (-not (Test-Path $ralphLog)) {
        Write-Host "  [ralph] No log file found for $TargetDate" -ForegroundColor Yellow
        return $result
    }

    Write-Host "  [ralph] Parsing $ralphLog ..." -ForegroundColor Gray

    try {
        $lines = Get-Content $ralphLog -ErrorAction Stop
        $totalDuration = 0
        $totalIssues = 0
        $totalPRs = 0
        $roundCount = 0

        foreach ($line in $lines) {
            if (-not $line.Trim()) { continue }
            try {
                $entry = $line | ConvertFrom-Json
            } catch {
                continue
            }

            # Count completed rounds
            if ($entry.phase -eq "round" -and $entry.status -eq "OK") {
                $roundCount++
                $totalDuration += $entry.duration
            }

            # Extract metrics if present
            if ($entry.metrics) {
                if ($entry.metrics.issuesClosed) {
                    $totalIssues += [int]$entry.metrics.issuesClosed
                }
                if ($entry.metrics.prsMerged) {
                    $totalPRs += [int]$entry.metrics.prsMerged
                }
            }
        }

        $result.rounds = $roundCount
        $result.duration_minutes = [math]::Round($totalDuration / 60, 1)
        $result.issues_processed = $totalIssues
        $result.prs_merged = $totalPRs
    } catch {
        Write-Host "  [ralph] Error parsing log: $_" -ForegroundColor Red
    }

    return $result
}

# --- Main: Collect metrics from all repos ---
$repoMetrics = [ordered]@{}
$allContributors = @()

$totals = [ordered]@{
    issues_opened = 0
    issues_closed = 0
    prs_opened    = 0
    prs_merged    = 0
}

foreach ($repoName in $RepoNames) {
    $metrics = Get-RepoMetrics -RepoOwner $Owner -RepoName $repoName -TargetDate $Date
    $repoMetrics[$repoName] = [ordered]@{
        issues_opened = $metrics.issues_opened
        issues_closed = $metrics.issues_closed
        prs_opened    = $metrics.prs_opened
        prs_merged    = $metrics.prs_merged
    }
    $totals.issues_opened += $metrics.issues_opened
    $totals.issues_closed += $metrics.issues_closed
    $totals.prs_opened    += $metrics.prs_opened
    $totals.prs_merged    += $metrics.prs_merged
    $allContributors += $metrics.contributors
}

$uniqueContributors = @($allContributors | Sort-Object -Unique)
$totals["active_contributors"] = $uniqueContributors.Count

# --- Collect ralph-watch metrics ---
$ralphMetrics = Get-RalphMetrics -TargetDate $Date

# --- Build output ---
$output = [ordered]@{
    date         = $Date
    day_number   = $dayNumber
    epoch        = "2026-03-11T16:31:48Z"
    repos        = $repoMetrics
    ralph        = $ralphMetrics
    totals       = $totals
    contributors = $uniqueContributors
}

$json = $output | ConvertTo-Json -Depth 5

if ($DryRun) {
    Write-Host ""
    Write-Host "[DRY RUN] Would write to: $outputFile" -ForegroundColor Yellow
    Write-Host $json
} else {
    $json | Set-Content -Path $outputFile -Encoding utf8
    Write-Host ""
    Write-Host "[collect-daily-metrics] Written to: $outputFile" -ForegroundColor Green
}

# --- Summary ---
Write-Host ""
Write-Host "=== Daily Metrics Summary ($Date, Day $dayNumber) ===" -ForegroundColor Cyan
Write-Host "  Issues opened: $($totals.issues_opened)  |  closed: $($totals.issues_closed)" -ForegroundColor White
Write-Host "  PRs opened:    $($totals.prs_opened)  |  merged: $($totals.prs_merged)" -ForegroundColor White
Write-Host "  Contributors:  $($uniqueContributors.Count) ($($uniqueContributors -join ', '))" -ForegroundColor White
Write-Host "  Ralph rounds:  $($ralphMetrics.rounds)  |  duration: $($ralphMetrics.duration_minutes)m  |  issues: $($ralphMetrics.issues_processed)  |  PRs: $($ralphMetrics.prs_merged)" -ForegroundColor White
Write-Host ""
