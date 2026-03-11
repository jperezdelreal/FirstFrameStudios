# Setup GitHub Project Board V2 for First Frame Studios
# Run this script once to create the board and populate IDs in the SKILL.md
#
# Prerequisites:
#   gh auth refresh -s project,read:project
#
# Usage:
#   .\tools\setup-project-board.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

$owner = "jperezdelreal"
$title = "First Frame Studios"
$skillFile = Join-Path $PSScriptRoot "..\.squad\skills\github-project-board\SKILL.md"

Write-Host "`n=== First Frame Studios — Project Board Setup ===" -ForegroundColor Cyan

# Step 1: Create the project
Write-Host "`n[1/5] Creating project board..." -ForegroundColor Yellow
$createResult = gh project create --owner $owner --title $title --format json 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Failed with --owner flag, trying without..." -ForegroundColor Yellow
    $createResult = gh project create --title $title --format json 2>&1
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Could not create project. Output: $createResult" -ForegroundColor Red
    Write-Host "  Make sure you ran: gh auth refresh -s project,read:project" -ForegroundColor Yellow
    exit 1
}
$project = $createResult | ConvertFrom-Json
$projectNumber = $project.number
$projectId = $project.id
Write-Host "  Created! Number: $projectNumber, ID: $projectId" -ForegroundColor Green

# Step 2: Get field IDs
Write-Host "`n[2/5] Getting field IDs..." -ForegroundColor Yellow
$fields = gh project field-list $projectNumber --owner $owner --format json 2>&1 | ConvertFrom-Json
$statusField = $fields.fields | Where-Object { $_.name -eq "Status" }
if (-not $statusField) {
    Write-Host "  ERROR: No Status field found!" -ForegroundColor Red
    exit 1
}
$statusFieldId = $statusField.id
Write-Host "  Status field ID: $statusFieldId" -ForegroundColor Green

# Step 3: Get status option IDs
Write-Host "`n[3/5] Reading status options..." -ForegroundColor Yellow
$options = $statusField.options
$optionMap = @{}
foreach ($opt in $options) {
    $optionMap[$opt.name] = $opt.id
    Write-Host "  $($opt.name) => $($opt.id)" -ForegroundColor Gray
}

# Add custom status options if missing
$requiredStatuses = @("Todo", "In Progress", "Done", "Blocked", "Pending User")
foreach ($status in $requiredStatuses) {
    if (-not $optionMap.ContainsKey($status)) {
        Write-Host "  Adding missing status: $status" -ForegroundColor Yellow
        # Note: gh CLI may not support adding options directly. 
        # The user may need to add these via the GitHub UI.
        Write-Host "  ⚠ Cannot add '$status' via CLI. Add it manually in the GitHub Project Settings." -ForegroundColor Yellow
    }
}

# Step 4: Add all open issues to the board
Write-Host "`n[4/5] Adding open issues to the board..." -ForegroundColor Yellow
$repos = @(
    "jperezdelreal/FirstFrameStudios",
    "jperezdelreal/ComeRosquillas",
    "jperezdelreal/flora",
    "jperezdelreal/ffs-squad-monitor"
)
$addedCount = 0
foreach ($repo in $repos) {
    $issues = gh issue list --repo $repo --state open --json url --limit 100 2>&1 | ConvertFrom-Json
    foreach ($issue in $issues) {
        Write-Host "  Adding: $($issue.url)" -ForegroundColor Gray
        gh project item-add $projectNumber --owner $owner --url $($issue.url) 2>&1 | Out-Null
        $addedCount++
    }
}
Write-Host "  Added $addedCount issues to the board" -ForegroundColor Green

# Step 5: Update SKILL.md with real IDs
Write-Host "`n[5/5] Updating SKILL.md with real IDs..." -ForegroundColor Yellow
if (Test-Path $skillFile) {
    $content = Get-Content $skillFile -Raw
    $content = $content -replace 'PROJECT_NUMBER:\s+__PENDING__', "PROJECT_NUMBER:  $projectNumber"
    $content = $content -replace 'PROJECT_ID:\s+__PENDING__', "PROJECT_ID:      $projectId"
    $content = $content -replace 'STATUS_FIELD_ID:\s+__PENDING__', "STATUS_FIELD_ID: $statusFieldId"
    
    if ($optionMap.ContainsKey("Todo"))        { $content = $content -replace 'TODO_ID:\s+__PENDING__',         "TODO_ID:          $($optionMap['Todo'])" }
    if ($optionMap.ContainsKey("In Progress")) { $content = $content -replace 'IN_PROGRESS_ID:\s+__PENDING__',  "IN_PROGRESS_ID:   $($optionMap['In Progress'])" }
    if ($optionMap.ContainsKey("Done"))        { $content = $content -replace 'DONE_ID:\s+__PENDING__',         "DONE_ID:          $($optionMap['Done'])" }
    if ($optionMap.ContainsKey("Blocked"))     { $content = $content -replace 'BLOCKED_ID:\s+__PENDING__',      "BLOCKED_ID:       $($optionMap['Blocked'])" }
    if ($optionMap.ContainsKey("Pending User")){ $content = $content -replace 'PENDING_USER_ID:\s+__PENDING__', "PENDING_USER_ID:  $($optionMap['Pending User'])" }
    
    $content | Set-Content $skillFile -Encoding utf8
    Write-Host "  SKILL.md updated!" -ForegroundColor Green
} else {
    Write-Host "  SKILL.md not found at: $skillFile" -ForegroundColor Red
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "Project Number: $projectNumber"
Write-Host "Project URL: https://github.com/users/$owner/projects/$projectNumber"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Check the board in GitHub: https://github.com/users/$owner/projects/$projectNumber"
Write-Host "  2. Add missing status columns (Blocked, Pending User) in Project Settings if needed"
Write-Host "  3. Verify SKILL.md has real IDs (no __PENDING__ markers left)"
Write-Host ""
