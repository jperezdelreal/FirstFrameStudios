# Send Discord Notification Helper Script
# First Frame Studios -- Tool for ralph-watch.ps1 and other automation
#
# Sends a notification to Discord webhook with rate limiting
# ASCII-safe (no emojis) for PowerShell compatibility
#
# Usage:
#   .\tools\send-discord-notification.ps1 -EventType "Ralph Round" -Summary "Round 42 completed" -Link "https://..."
#   .\tools\send-discord-notification.ps1 -EventType "CI Failure" -Summary "Build failed" -Link "..." -Color 15158332

param(
    [Parameter(Mandatory=$true)]
    [string]$EventType,
    
    [Parameter(Mandatory=$true)]
    [string]$Summary,
    
    [Parameter(Mandatory=$true)]
    [string]$Link,
    
    [int]$Color = 5814783,  # Default blue color
    
    [string]$WebhookUrl = $env:DISCORD_WEBHOOK_URL,
    
    [int]$MaxPerHour = 10
)

# Check if webhook URL is configured
if (-not $WebhookUrl) {
    Write-Warning "DISCORD_WEBHOOK_URL not configured. Set environment variable or pass -WebhookUrl parameter."
    exit 1
}

# Rate limiting check
$rateLimitFile = Join-Path $PSScriptRoot ".discord-rate-limit"
$currentTime = [int][double]::Parse((Get-Date -UFormat %s))
$hourAgo = $currentTime - 3600

# Create rate limit file if it doesn't exist
if (-not (Test-Path $rateLimitFile)) {
    $currentTime | Out-File -FilePath $rateLimitFile -Encoding ASCII
}
else {
    # Read existing timestamps and filter to last hour
    $timestamps = Get-Content $rateLimitFile | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
    $recentTimestamps = $timestamps | Where-Object { $_ -gt $hourAgo }
    
    # Check rate limit
    if ($recentTimestamps.Count -ge $MaxPerHour) {
        Write-Warning "Rate limit exceeded: $($recentTimestamps.Count) notifications in the last hour (max $MaxPerHour)"
        exit 0  # Soft exit - not an error, just skipped
    }
    
    # Append current timestamp
    $currentTime | Out-File -FilePath $rateLimitFile -Append -Encoding ASCII
    
    # Clean up old entries (keep last 20 for efficiency)
    $allTimestamps = Get-Content $rateLimitFile | Where-Object { $_ -match '^\d+$' } | Select-Object -Last 20
    $allTimestamps | Out-File -FilePath $rateLimitFile -Encoding ASCII
}

# Map event types to text prefixes (ASCII-safe, no emojis)
$emoji = switch -Wildcard ($EventType) {
    "*CI Failure*" { "[FAIL]" }
    "*PR Merged*" { "[MERGE]" }
    "*Priority*" { "[ALERT]" }
    "*Ralph*" { "[RALPH]" }
    default { "[INFO]" }
}

# Build Discord embed JSON
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$jsonPayload = @{
    embeds = @(
        @{
            title = "$emoji $EventType"
            description = $Summary
            url = $Link
            color = $Color
            timestamp = $timestamp
        }
    )
} | ConvertTo-Json -Depth 3

# Send to Discord webhook
try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $jsonPayload -ContentType "application/json"
    Write-Host "[OK] Discord notification sent: $EventType"
}
catch {
    Write-Warning "Failed to send Discord notification: $_"
    exit 1
}
