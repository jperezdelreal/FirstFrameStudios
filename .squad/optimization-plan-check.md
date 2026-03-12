# Pre-Autonomy Diagnostic — FFS Ecosystem
> Date: 2026-03-12
> Checked by: Solo (Lead / Chief Architect)
> Purpose: Verify readiness for autonomous ralph-watch operation

## Summary Verdict
🟡 READY WITH CAVEATS

Ralph-watch infrastructure is solid — dry-run completes, all repos have squad rosters, upstream sync works, governance filters function. However, there are stale Godot/Ashfall references in hub config files, `decisions.md` exceeds the 5KB G1 limit (8.2KB), and downstream repos are missing `blocked-by:*` labels needed for dependency tracking. None are blockers, but the stale references will confuse agents if not cleaned.

---

## Hub: FirstFrameStudios

### Squad Infrastructure: ⚠️

| Check | Status | Detail |
|-------|--------|--------|
| `.squad/team.md` + `## Members` | ✅ | 6 members: Solo, Jango, Mace, Scribe, Ralph, @copilot |
| `.squad/decisions.md` < 5KB (G1) | ⚠️ | **8,231 bytes (8.0KB)** — 3KB over limit. Scribe should archive. |
| Agent charters | ✅ | solo, jango, mace, scribe, ackbar — all have charter.md |
| Orphan files in `.squad/` root (G13) | ✅ | 8 files, all standard (team.md, decisions.md, decisions-archive.md, routing.md, ceremonies.md, config.json, copilot-instructions.md, optimization-plan.md) |
| `.gitattributes` merge=union | ✅ | Configured for decisions.md, agents/*/history.md, log/**, orchestration-log/** |
| Hibernated agents in routing.md | ✅ | No references to hibernated agents |

### Ralph-Watch: ✅

| Check | Status | Detail |
|-------|--------|--------|
| `tools/ralph-watch.ps1` valid | ✅ | File exists, syntactically valid |
| `$repoGitHubMap` has all 4 repos | ✅ | FirstFrameStudios, ComeRosquillas, flora, ffs-squad-monitor |
| `$Repos` paths resolve | ✅ | `.`, `../ComeRosquillas`, `../flora`, `../ffs-squad-monitor` — all siblings |
| PREPARE MODE block in prompt | ✅ | `[PREPARE-ONLY]` marker + `PREPARE MODE` instruction block present |
| `Get-ScheduledIssues` checks `blocked-by:*` | ✅ | Detects blocked-by labels, skips blocked P3s, sorts blocked issues last |
| `Invoke-UpstreamSync` includes squad.agent.md | ✅ | Syncs: skills/, quality-gates.md, governance.md, decisions.md, squad.agent.md |
| `Test-HasSquadRoster` exists (G10) | ✅ | Checks `.squad/team.md` for `## Members` section; skips repos without roster |

**Dry-Run Output (MaxRounds=1):**
```
[ralph] Ralph Watch v3 - First Frame Studios (Night/Day Mode)
   Mode: day (sessions=1, interval=10m, maxIssues=3/session)
   DryRun: YES | MaxRounds: 1

Round 1:
  [pull] All 4 repos — would fetch/pull
  [sync] Hub -> ComeRosquillas, flora, ffs-squad-monitor — all up to date
  [sched] Hub issues #189, #188, #187 — SKIPPED (needs-research)
  [sched] Flora #9 — SELECTED (P1, squad:wedge)
  Session: jperezdelreal/flora -- 1 issue
    #9: [Sprint 0] Garden UI/HUD [P1]

Round 1 complete (4.5s). Stopped at MaxRounds.
```

✅ Dry-run successful. Governance filters working (skipped needs-research issues). Picked up Flora #9 correctly.

### GitHub State: ⚠️

| Item | Status | Detail |
|------|--------|--------|
| Open squad issues | ⚠️ | **3 hub issues (#187, #188, #189) are open but work is DONE** (Phase 5, Phase 6, Priority system all marked ✅ in optimization-plan.md). Should be closed. |
| Open PRs | ✅ | None in hub |
| Required labels | ⚠️ | Has squad:*, priority:p0-p2, P3, blocked-by:{issue,pr,decision,upstream,external}. **Missing: tier:t0-t3 labels** |

### Workflows: ✅

| Check | Status | Detail |
|-------|--------|--------|
| Total workflows | 25 | All active, none disabled |
| Cron intervals (G9: ≥1h) | ✅ | squad-heartbeat: hourly, ralph-notify: 4h, archive: weekly, digest: daily, drift: weekly |

No sub-1h cron intervals found. Compliant with G9.

### Stale References: ⚠️

| File | Issue | Severity |
|------|-------|----------|
| `CONTRIBUTING.md` | 6 Ashfall/Godot refs (branch examples, game labels, style guide link, engine list) | 🟡 Medium |
| `README.md` | 1 Ashfall row in project table | 🟡 Medium |
| `.squad/ceremonies.md` | 5 Godot refs — entire "Godot Smoke Test" ceremony still present | 🟡 Medium |
| `.github/pull_request_template.md` | "Tested in Godot editor" checkbox | 🟡 Medium |
| `.squad/skills/fighting-game-design/` | Ashfall-specific examples in SKILL.md and REFERENCE.md | 🟢 Low (contextual) |
| `.squad/skills/integration-discipline/` | Ashfall references as examples | 🟢 Low (contextual) |
| `.squad/analysis/*.md` | Godot/Ashfall in analysis docs | 🟢 Low (historical analysis) |
| `docs/src/content/blog/` | Ashfall in blog posts | 🟢 Low (published content, don't edit) |

**Impact:** ceremonies.md and PR template actively influence agent behavior. A Copilot session could see "Tested in Godot editor" and be confused. CONTRIBUTING.md is read by new agents.

---

## Downstream: ComeRosquillas

### Squad Infrastructure: ✅

| Check | Status | Detail |
|-------|--------|--------|
| `.squad/team.md` + `## Members` | ✅ | 5 agents: moe, barney, lenny, nelson, scribe + Ralph |
| `.squad/decisions.md` | ✅ | 234 bytes — empty ledger, well under 5KB |
| Agent charters | ✅ | All 5 agents have charter.md |
| Orphan files | ⚠️ | `.first-run` and `config.json` in root — minor, non-blocking |
| `.gitattributes` merge=union | ✅ | Properly configured |

### Upstream Connection: ⚠️

| Check | Status | Detail |
|-------|--------|--------|
| `upstream.json` | ✅ | Points to FirstFrameStudios hub, last synced 2026-07-24 |
| `.squad/upstream/` directory | ✅ | Has synced skills/, identity/, manifest.json |
| `.github/agents/squad.agent.md` | ✅ | Present (72.4KB) |
| Upstream quality-gates.md | ⚠️ | **Contains 4 Godot references** — stale upstream copy. Hub source is clean. Next sync will NOT fix this because upstream copy is a snapshot; hub quality-gates.md is already Godot-free. Issue is the cached copy in `.squad/upstream/`. |

### GitHub State: ✅

| Item | Status | Detail |
|------|--------|--------|
| Open squad issues | ✅ | None |
| Open PRs | ✅ | None |
| Labels | ⚠️ | Has squad:*, priority:p0-p3. **Missing: blocked-by:\*, tier:\* labels** |

### Stale References: ⚠️
- `.squad/upstream/identity/quality-gates.md` has Godot references (stale upstream cache)
- `.squad/upstream/identity/company.md` references hibernated agents in role definitions (contextual)

---

## Downstream: Flora

### Squad Infrastructure: ✅

| Check | Status | Detail |
|-------|--------|--------|
| `.squad/team.md` + `## Members` | ✅ | 6 agents: oak, brock, erika, misty, sabrina, scribe + Ralph |
| `.squad/decisions.md` | ✅ | 68 bytes — minimal header |
| Agent charters | ✅ | All 6 agents have charter.md |
| Orphan files | ✅ | Clean root — 5 essential files only |
| `.gitattributes` merge=union | ✅ | Properly configured |

### Upstream Connection: ⚠️

| Check | Status | Detail |
|-------|--------|--------|
| `upstream.json` | ✅ | Points to FirstFrameStudios hub |
| Last synced | ⚠️ | **`last_synced: null`** — never synced via ralph-watch. First real run will sync. |
| `.github/agents/squad.agent.md` | ✅ | Present (72.4KB) |

### GitHub State: ⚠️

| Item | Status | Detail |
|------|--------|--------|
| Open squad issues | ⚠️ | **#9 assigned to squad:wedge — Wedge is HIBERNATED in hub.** Flora has its own agents; this label maps to a hub agent name. Ralph correctly picks it up but the agent name mismatch could confuse. |
| Open PRs | ⚠️ | **PR #18** (feat: garden UI/HUD) — open, no labels, branch `squad/9-garden-hud` |
| Labels | ⚠️ | Has priority:p0-p2. **Missing: priority:p3, blocked-by:\*, tier:\***. Has labels for HIBERNATED hub agents (squad:chewie, lando, greedo, tarkin, yoda) — should be replaced with Flora-specific agent labels. |

### Stale References: ✅
- Migration log references hibernated agents (appropriate — documents the migration)
- GDD references Yoda as historical author (appropriate context)

---

## Downstream: ffs-squad-monitor

### Squad Infrastructure: ✅

| Check | Status | Detail |
|-------|--------|--------|
| `.squad/team.md` + `## Members` | ✅ | 5 agents: ripley, dallas, lambert, kane, scribe + Ralph |
| `.squad/decisions.md` | ✅ | 234 bytes — empty ledger |
| Agent charters | ✅ | All 5 agents have charter.md |
| Orphan files | ⚠️ | `.first-run` and `config.json` in root — minor |
| `.gitattributes` merge=union | ✅ | Properly configured |

### Upstream Connection: ⚠️

| Check | Status | Detail |
|-------|--------|--------|
| `upstream.json` | ✅ | Points to FirstFrameStudios hub |
| Last synced | ⚠️ | **`last_synced: null`** — never synced. First ralph-watch run will sync. |
| `.github/agents/squad.agent.md` | ✅ | Present (72.4KB) |

### GitHub State: ⚠️

| Item | Status | Detail |
|------|--------|--------|
| Open squad issues | ✅ | None |
| Open PRs | ✅ | None |
| Labels | ⚠️ | **Very incomplete.** Only has: squad, squad:jango, squad:wedge, priority:p1, priority:p2. **Missing: priority:p0, priority:p3, blocked-by:\*, tier:\*, most squad:agent labels for its own team (ripley, dallas, lambert, kane, scribe)** |

### Stale References: ✅
- No Ashfall, Godot, firstPunch, or hibernated agent references found.

---

## Blocking Issues (must fix before autonomous mode)

**None.** Ralph-watch will function correctly. The dry-run proved it can pull, sync, schedule, and filter issues properly. All repos have valid squad infrastructure.

## Recommended Fixes (non-blocking but should address)

### Priority: High (address in first sprint)

1. **Close hub issues #187, #188, #189** — all three correspond to completed optimization phases (5, 6, 7). They show as needs-research but work is done per optimization-plan.md.

2. **Archive `decisions.md` to get under 5KB (G1)** — currently 8.2KB. Scribe should move older decisions to `decisions-archive.md`.

3. **Clean stale Godot references from active config files:**
   - `.squad/ceremonies.md` — remove/rewrite "Godot Smoke Test" ceremony (marked for disable in Phase 1b but content still present)
   - `.github/pull_request_template.md` — remove "Tested in Godot editor" checkbox
   - `CONTRIBUTING.md` — remove Ashfall game label, Godot engine reference, Ashfall style guide link

4. **Create missing labels across downstream repos:**
   - All downstream: `blocked-by:{issue,pr,decision,upstream,external}`, `tier:t0`, `tier:t1`, `tier:t2`, `tier:t3`
   - Flora + ffs-squad-monitor: `priority:p3`
   - ffs-squad-monitor: `priority:p0`, `squad:{ripley,dallas,lambert,kane,scribe}`
   - Flora: Replace hub-agent labels (squad:chewie etc.) with Flora agent labels (squad:oak, squad:brock, etc.)
   - Hub: `tier:t0`, `tier:t1`, `tier:t2`, `tier:t3`

### Priority: Medium (address soon)

5. **Flora issue #9** — re-label from `squad:wedge` to the appropriate Flora agent (probably `squad:brock` or `squad:oak` for UI work). Wedge is a hub agent name.

6. **Flora PR #18** — add labels (at minimum `squad` label for tracking).

7. **ComeRosquillas upstream cache** — `.squad/upstream/identity/quality-gates.md` has stale Godot references. This is a cached copy; the hub source is clean. A forced re-sync or manual cleanup would fix it.

8. **README.md** — update Ashfall row to indicate "shelved" status or remove.

### Priority: Low (housekeeping)

9. **Remove `.first-run` from ComeRosquillas and ffs-squad-monitor** — squad init artifact, no longer needed.

10. **Flora/ffs-squad-monitor `upstream.json`** — `last_synced: null`. First ralph-watch live run will populate this automatically.

---

## Post-Merge Checklist
- [ ] Merge squad/172-governance-safeguards to main
- [ ] Close hub issues #187, #188, #189 (completed work)
- [ ] Archive decisions.md to get under 5KB (G1)
- [ ] Switch to main: `git checkout main`
- [ ] Start ralph-watch: `.\tools\ralph-watch.ps1`
- [ ] Verify first round completes successfully
- [ ] Check heartbeat: `cat tools\.ralph-heartbeat.json`
- [ ] Verify upstream sync ran on first round (Flora and ffs-squad-monitor)
- [ ] Create missing labels (blocked-by:*, tier:*, agent-specific) in downstream repos
- [ ] Clean Godot references from ceremonies.md, PR template, CONTRIBUTING.md
