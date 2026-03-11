# First Frame Studios — Tools

Autonomous infrastructure for the squad. These tools keep the development loop running without human intervention.

## ⚡ Quickstart — One Command

```powershell
# From repo root:
.\tools\ralph-watch.ps1
```

That's it. Ralph will:
1. Pull latest code
2. Run the scheduler (creates issues if any are due)
3. Spawn a Copilot session that works all `squad` / `status:todo` issues
4. Sleep 15 minutes, then repeat

**To test without side effects:**
```powershell
.\tools\ralph-watch.ps1 -DryRun -MaxRounds 1
```

---

## 🔄 How the Autonomous Loop Works

```
┌──────────────┐     ┌───────────┐     ┌──────────┐     ┌─────────┐
│ ralph-watch  │────▶│ scheduler │────▶│ copilot  │────▶│  sleep   │──┐
│ (outer loop) │     │ (cron)    │     │ (agents) │     │ (15 min) │  │
└──────────────┘     └───────────┘     └──────────┘     └─────────┘  │
       ▲                                                              │
       └──────────────────────────────────────────────────────────────┘
```

### ralph-watch.ps1
The outer loop. Runs indefinitely (or for N rounds with `-MaxRounds`).

| Flag | Default | Description |
|---|---|---|
| `-IntervalMinutes` | 15 | Minutes between rounds |
| `-DryRun` | off | Show what would happen, don't execute |
| `-MaxRounds` | 0 (∞) | Stop after N rounds |
| `-Repos` | `@(".")` | Repo paths to pull |

**Files it manages:**
- `tools/.ralph-heartbeat.json` — current status, round number, last result
- `tools/logs/ralph-YYYY-MM-DD.jsonl` — structured round logs (auto-rotated at 1MB)
- `~/.squad/ralph-watch.lock` — single-instance guard (auto-cleaned on exit)

### Scheduler (`tools/scheduler/`)
Cron-based task creator. Checked every ralph-watch round.

- **Config:** `tools/scheduler/schedule.json` — define tasks with cron expressions
- **State:** `tools/scheduler/.state.json` — tracks last-run times (prevents duplicates)
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

## 🧑 What You (Joaquín) Need to Do

1. **Start ralph-watch once** — run `.\tools\ralph-watch.ps1` in a terminal and leave it open
2. **Review PRs** — agents create PRs, Jango reviews, you approve/merge if needed
3. **Create issues** — label them `squad` + `status:todo` for agents to pick up
4. **Stop when done** — press `Ctrl+C` in the ralph-watch terminal

### What Runs Automatically
- Git pull (every round)
- Scheduler checks (creates issues on schedule)
- Copilot spawns and works issues
- Heartbeat updates
- Log rotation

---

## 🔧 Running Persistently

To keep ralph-watch running even after closing the terminal:

```powershell
# Option 1: Start in a new detached PowerShell window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; .\tools\ralph-watch.ps1" -WindowStyle Minimized

# Option 2: Just keep a terminal open (simplest)
.\tools\ralph-watch.ps1
```

To check if it's running:
```powershell
Get-Content tools\.ralph-heartbeat.json
```

To stop it:
```powershell
# Read the PID from heartbeat, then:
$hb = Get-Content tools\.ralph-heartbeat.json | ConvertFrom-Json
Stop-Process -Id $hb.pid -Force
```

---

## 📁 Legacy Tools

The following tools were built for previous projects (Ashfall/Godot) and are archived for reference:
- `check-autoloads.py`, `check-signals.py`, `check-scenes.py` — Godot validators
- `export-frame-data.py`, `import-frame-data.py` — Fighting game frame data pipeline
- `generate-collision-matrix.py`, `generate-test-scenes.py` — Godot scene generators
- `validate-project.py`, `watch-reload.py` — Godot project validators
- `check-gdd-compliance.py`, `generate-milestone-report.py` — Design doc tools
- `integration-gate.py` — Godot integration gate

---

**Maintained by:** Jango (Tool Engineer)
**Last updated:** 2026-07-24
