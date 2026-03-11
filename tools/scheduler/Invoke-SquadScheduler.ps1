# Invoke-SquadScheduler.ps1 — Cron-based recurring task scheduler for Squad
# First Frame Studios — Adapted from Tamir Dresher's squad-personal-demo patterns
#
# Usage:
#   .\tools\scheduler\Invoke-SquadScheduler.ps1            # run due tasks
#   .\tools\scheduler\Invoke-SquadScheduler.ps1 -DryRun    # show due tasks without executing
#   .\tools\scheduler\Invoke-SquadScheduler.ps1 -List       # show all scheduled tasks

param(
    [switch]$DryRun,
    [switch]$List
)

$ErrorActionPreference = "Stop"

$schedulerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scheduleFile = Join-Path $schedulerDir "schedule.json"
$stateFile = Join-Path $schedulerDir ".state.json"

# --- Load schedule ---
if (-not (Test-Path $scheduleFile)) {
    Write-Host "ERROR: Schedule file not found: $scheduleFile" -ForegroundColor Red
    exit 1
}
$schedule = Get-Content $scheduleFile -Raw | ConvertFrom-Json

# --- Load state (last run times) ---
$state = @{}
if (Test-Path $stateFile) {
    $stateRaw = Get-Content $stateFile -Raw | ConvertFrom-Json
    foreach ($prop in $stateRaw.PSObject.Properties) {
        $state[$prop.Name] = [DateTime]::Parse($prop.Value)
    }
}

# --- Cron evaluator ---
# Matches: minute hour day-of-month month day-of-week
# Supports: exact numbers, * (any), ranges (1-5), comma lists (1,3,5)
function Test-CronField {
    param(
        [string]$Field,
        [int]$Value
    )
    if ($Field -eq "*") { return $true }

    foreach ($part in $Field.Split(",")) {
        if ($part -match "^(\d+)-(\d+)$") {
            $low = [int]$Matches[1]
            $high = [int]$Matches[2]
            if ($Value -ge $low -and $Value -le $high) { return $true }
        } elseif ($part -match "^\d+$") {
            if ([int]$part -eq $Value) { return $true }
        }
    }
    return $false
}

function Test-CronExpression {
    param(
        [string]$Expression,
        [DateTime]$Time
    )
    $fields = $Expression.Trim().Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
    if ($fields.Count -ne 5) {
        Write-Host "   ⚠️  Invalid cron expression: $Expression" -ForegroundColor Yellow
        return $false
    }

    $minute     = $fields[0]
    $hour       = $fields[1]
    $dayOfMonth = $fields[2]
    $month      = $fields[3]
    $dayOfWeek  = $fields[4]

    # PowerShell DayOfWeek: Sunday=0, Monday=1, ... Saturday=6 (matches cron convention)
    $dow = [int]$Time.DayOfWeek

    return (
        (Test-CronField $minute     $Time.Minute) -and
        (Test-CronField $hour       $Time.Hour) -and
        (Test-CronField $dayOfMonth $Time.Day) -and
        (Test-CronField $month      $Time.Month) -and
        (Test-CronField $dayOfWeek  $dow)
    )
}

function Test-TaskDue {
    param(
        [string]$TaskId,
        [string]$CronExpression,
        [DateTime]$Now
    )
    # Check if cron matches current time (truncated to minute)
    $currentMinute = $Now.Date.AddHours($Now.Hour).AddMinutes($Now.Minute)

    if (-not (Test-CronExpression -Expression $CronExpression -Time $currentMinute)) {
        return $false
    }

    # Check if already ran this minute
    if ($state.ContainsKey($TaskId)) {
        $lastRun = $state[$TaskId]
        $lastMinute = $lastRun.Date.AddHours($lastRun.Hour).AddMinutes($lastRun.Minute)
        if ($lastMinute -eq $currentMinute) {
            return $false
        }
    }

    return $true
}

# --- List mode ---
if ($List) {
    Write-Host ""
    Write-Host "📅 Squad Scheduler — Scheduled Tasks" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────" -ForegroundColor DarkGray
    foreach ($task in $schedule.tasks) {
        $status = if ($task.enabled) { "✅ enabled" } else { "⏸️  disabled" }
        $lastRun = if ($state.ContainsKey($task.id)) { $state[$task.id].ToString("yyyy-MM-dd HH:mm") } else { "never" }
        Write-Host "  $($task.name)" -ForegroundColor White
        Write-Host "    ID:       $($task.id)" -ForegroundColor Gray
        Write-Host "    Cron:     $($task.trigger.expression)" -ForegroundColor Gray
        Write-Host "    Status:   $status" -ForegroundColor Gray
        Write-Host "    Last Run: $lastRun" -ForegroundColor Gray
        Write-Host "    Action:   $($task.action.type)" -ForegroundColor Gray
        Write-Host ""
    }
    exit 0
}

# --- Main: evaluate and execute due tasks ---
$now = Get-Date
$dueTasks = 0

Write-Host "📅 Squad Scheduler — checking $(($schedule.tasks | Where-Object { $_.enabled }).Count) enabled tasks..." -ForegroundColor Cyan

foreach ($task in $schedule.tasks) {
    if (-not $task.enabled) { continue }
    if ($task.trigger.type -ne "cron") {
        Write-Host "   ⚠️  Unknown trigger type '$($task.trigger.type)' for task '$($task.id)', skipping" -ForegroundColor Yellow
        continue
    }

    $isDue = Test-TaskDue -TaskId $task.id -CronExpression $task.trigger.expression -Now $now

    if ($isDue) {
        $dueTasks++
        $dateStr = $now.ToString("yyyy-MM-dd")
        $title = $task.action.title -replace '\{date\}', $dateStr
        $body = $task.action.body -replace '\{date\}', $dateStr
        $labels = ($task.action.labels -join ",")

        Write-Host "   🎯 DUE: $($task.name)" -ForegroundColor Green

        if ($task.action.type -eq "github-issue") {
            if ($DryRun) {
                Write-Host "      [DRY RUN] Would create issue:" -ForegroundColor Yellow
                Write-Host "        Title:  $title" -ForegroundColor Yellow
                Write-Host "        Labels: $labels" -ForegroundColor Yellow
            } else {
                try {
                    Write-Host "      Creating issue: $title" -ForegroundColor Gray
                    gh issue create --title $title --body $body --label $labels 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "      ✅ Issue created" -ForegroundColor Green
                    } else {
                        Write-Host "      ❌ Failed to create issue (exit $LASTEXITCODE)" -ForegroundColor Red
                    }
                } catch {
                    Write-Host "      ❌ Error creating issue: $_" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "      ⚠️  Unknown action type: $($task.action.type)" -ForegroundColor Yellow
        }

        # Update state
        $state[$task.id] = $now
    }
}

# --- Save state ---
if (-not $DryRun -and $dueTasks -gt 0) {
    $stateOut = [ordered]@{}
    foreach ($key in $state.Keys) {
        $stateOut[$key] = $state[$key].ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    $stateOut | ConvertTo-Json | Out-File $stateFile -Encoding utf8 -Force
}

if ($dueTasks -eq 0) {
    Write-Host "   No tasks due right now." -ForegroundColor DarkGray
} else {
    Write-Host "   📊 $dueTasks task(s) processed." -ForegroundColor Cyan
}
