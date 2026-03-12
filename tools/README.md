# First Frame Studios -- Tools

Autonomous infrastructure for the squad. These tools keep the development loop running without human intervention.

## Quickstart -- One Command

```powershell
# From repo root:
.\tools\ralph-watch.ps1
```

That's it. Ralph will:
1. Pull latest code across all 4 FFS repos
2. Run the scheduler (creates GitHub issues if any are due)
3. Spawn a Copilot session that works all `squad` / `status:todo` issues
4. Sleep 15 minutes, then repeat

**To test without side effects:**
```powershell
.\tools\ralph-watch.ps1 -DryRun -MaxRounds 1
```

---

## How the Autonomous Loop Works

```
ralph-watch (outer loop)
  |
  +--> git pull (all repos)
  +--> scheduler (cron-based issue creation)
  +--> copilot --agent squad (works issues, opens PRs)
  +--> heartbeat update + log entry
  +--> sleep (IntervalMinutes)
  +--> repeat
```

### ralph-watch.ps1 (v2)

The outer loop. Runs indefinitely (or for N rounds with `-MaxRounds`).

| Flag | Default | Description |
|---|---|---|
| `-IntervalMinutes` | 15 | Minutes between rounds |
| `-DryRun` | off | Show what would happen, don't execute |
| `-MaxRounds` | 0 (infinite) | Stop after N rounds (0 = run forever) |
| `-Repos` | All 4 FFS repos | Repo paths to pull (see below) |

Default repos: `.` (FirstFrameStudios), `../ComeRosquillas`, `../flora`, `../ffs-squad-monitor`.
Missing repos are skipped automatically with a warning.

**v2 Features:**
- **Failure alerts** -- after 3+ consecutive failures, writes structured alerts to `tools/logs/alerts.json`
- **Activity monitor** -- background runspace prints status every 30s while Copilot runs
- **Metrics parsing** -- extracts issues closed, PRs merged/opened from Copilot output
- **Multi-repo defaults** -- watches all 4 FFS repos by default
- **Single-instance guard** -- prevents two ralph-watch processes from running simultaneously

**Files it manages:**
- `tools/.ralph-heartbeat.json` -- current status, round number, metrics, last result
- `tools/logs/ralph-YYYY-MM-DD.jsonl` -- structured round logs (auto-rotated at 1MB)
- `tools/logs/alerts.json` -- failure alerts (last 50, written after 3+ consecutive failures)
- `~/.squad/ralph-watch.lock` -- single-instance guard (auto-cleaned on exit/crash)

### Scheduler (`tools/scheduler/`)
Cron-based task creator. Checked every ralph-watch round.

- **Config:** `tools/scheduler/schedule.json` -- define tasks with cron expressions
- **State:** `tools/scheduler/.state.json` -- tracks last-run times (prevents duplicates)
- **Engine:** `tools/scheduler/Invoke-SquadScheduler.ps1`

Current scheduled tasks:
| Task | Schedule | What it does |
|---|---|---|
| Daily Playtest | 6 PM weekdays | Creates issue for Ackbar to playtest ComeRosquillas |
| Weekly Retro | 4 PM Friday | Creates retro issue for Mace |
| Backlog Grooming | 10 AM Wednesday | Creates grooming issue for Mace |
| Browser Compat | 12 PM Monday | Creates browser testing issue for Ackbar |

To see all tasks: `.\tools\scheduler\Invoke-SquadScheduler.ps1 -List`

---

## Starting Ralph Watch

### Quick Start (interactive terminal)
```powershell
cd C:\Users\joperezd\GitHub Repos\FirstFrameStudios
.\tools\ralph-watch.ps1
```
Press `Ctrl+C` to stop.

### Persistent (minimized window, survives terminal close)
```powershell
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\joperezd\GitHub Repos\FirstFrameStudios'; .\tools\ralph-watch.ps1" -WindowStyle Minimized
```

### Custom interval or subset of repos
```powershell
# 5-minute interval, only hub repo
.\tools\ralph-watch.ps1 -IntervalMinutes 5 -Repos @(".")

# Test run: 3 rounds, no side effects
.\tools\ralph-watch.ps1 -DryRun -MaxRounds 3 -IntervalMinutes 0
```

### Check if it's running
```powershell
# Heartbeat file shows current status, round, and metrics
Get-Content tools\.ralph-heartbeat.json | ConvertFrom-Json

# Look for the process
Get-Process -Id (Get-Content tools\.ralph-heartbeat.json | ConvertFrom-Json).pid -ErrorAction SilentlyContinue
```

### Stop it
```powershell
# Option 1: Ctrl+C in the ralph-watch terminal

# Option 2: Kill by PID from heartbeat
$hb = Get-Content tools\.ralph-heartbeat.json | ConvertFrom-Json
Stop-Process -Id $hb.pid -Force
```

### Prerequisites
- PowerShell 5.1+ (ships with Windows)
- `gh` CLI authenticated (`gh auth status`)
- `copilot` CLI extension installed (`gh extension list` should show copilot)
- Sibling repos cloned: `../ComeRosquillas`, `../flora`, `../ffs-squad-monitor` (optional -- missing repos are skipped)

---

## What You (Joaquin) Need to Do

1. **Start ralph-watch once** -- run `.\tools\ralph-watch.ps1` in a terminal and leave it open
2. **Review PRs** -- agents create PRs, Jango reviews, you approve/merge if needed
3. **Create issues** -- label them `squad` + `status:todo` for agents to pick up
4. **Stop when done** -- press `Ctrl+C` in the ralph-watch terminal

### What Runs Automatically
- Git pull across all repos (every round)
- Scheduler checks (creates issues on schedule)
- Copilot spawns and works issues
- Heartbeat updates (`tools/.ralph-heartbeat.json`)
- Log rotation (1MB per file)
- Failure alerting (after 3+ consecutive failures)

---

## Legacy Tools

The following tools were built for previous projects (Ashfall/Godot) and are archived for reference:
- `check-autoloads.py`, `check-signals.py`, `check-scenes.py` -- Godot validators
- `export-frame-data.py`, `import-frame-data.py` -- Fighting game frame data pipeline
- `generate-collision-matrix.py`, `generate-test-scenes.py` -- Godot scene generators
- `validate-project.py`, `watch-reload.py` -- Godot project validators
- `check-gdd-compliance.py`, `generate-milestone-report.py` -- Design doc tools
- `integration-gate.py` -- Godot integration gate

---

## Discord Webhook Notifications

The squad can now send Discord notifications for critical events. Notifications are rate-limited to 10 per hour to prevent spam.

### Setup

1. **Create a Discord webhook:**
   - In Discord: Server Settings → Integrations → Webhooks → New Webhook
   - Copy the webhook URL

2. **Configure GitHub secret:**
   ```bash
   # Add the webhook URL as a repository secret
   gh secret set DISCORD_WEBHOOK_URL
   # Paste webhook URL when prompted
   ```

3. **Verify workflows:**
   - Go to Actions tab in GitHub
   - Workflows should be enabled automatically

### What Gets Notified

| Event | Trigger | Workflow |
|-------|---------|----------|
| CI Failure on main | Any workflow fails on main branch | `squad-notify-ci-failure.yml` |
| PR Merged | Pull request merged to main | `squad-notify-pr-merged.yml` |
| Priority Issue | Issue labeled `priority:p0` or `priority:critical` | `squad-notify-priority-issue.yml` |
| Ralph Round | Ralph completes a round (checked every 30 min) | `squad-notify-ralph-heartbeat.yml` |

### Manual Notifications from Scripts

Use the helper script from PowerShell:

```powershell
# Send a notification from ralph-watch or other automation
.\tools\send-discord-notification.ps1 `
  -EventType "Ralph Round" `
  -Summary "Round 42 completed in night mode (3 issues closed)" `
  -Link "https://github.com/jperezdelreal/FirstFrameStudios/actions" `
  -Color 3066993

# Set webhook URL via environment variable
$env:DISCORD_WEBHOOK_URL = "your-webhook-url"
.\tools\send-discord-notification.ps1 -EventType "Test" -Summary "Hello!" -Link "https://example.com"
```

Color codes (decimal):
- Red (failures/alerts): `15158332`
- Green (success): `5763719`
- Blue (info): `3066993`
- Gray (neutral): `5814783`

### Rate Limiting

- Max 10 notifications per hour (enforced in workflows and script)
- Older notifications are tracked in `.github/.discord-rate-limit` (workflows) or `tools/.discord-rate-limit` (scripts)
- Rate limit exceeded = notification silently skipped with warning log

### Troubleshooting

**No notifications arriving:**
1. Check webhook URL is configured: `gh secret list` (should show `DISCORD_WEBHOOK_URL`)
2. Check workflow runs in Actions tab for errors
3. Verify Discord webhook is active in server settings

**Too many notifications:**
- Rate limit prevents spam (max 10/hour)
- Adjust triggers in workflow files if needed

---

**Maintained by:** Jango (Tool Engineer)
**Last updated:** 2026-03-12
