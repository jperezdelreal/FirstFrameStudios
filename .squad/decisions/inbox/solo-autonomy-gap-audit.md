## 2026-03-11: Autonomy Gap Audit — Planned vs Implemented
**By:** Solo (Lead Architect)
**Requested by:** Joaquín
**Status:** INFORMATIONAL — input to prioritization

### Context
Joaquín flagged frustration: the squad planned an autonomous execution model (from Tamir Dresher blog patterns, Option C hybrid architecture in `solo-upstream-subsquad-proposal.md`) but much of it remains unimplemented. This audit compares what was **planned** in the inbox decisions vs what **actually exists** in the repo.

---

### Source Documents Analyzed
1. `copilot-tamir-blog-learnings.md` — 16 operational patterns from Tamir's blog
2. `solo-upstream-subsquad-proposal.md` — Option C hybrid implementation plan (5 phases)
3. `copilot-directive-2026-03-11T0745-repo-autonomy.md` — Founder directive: agents can create repos autonomously

---

### Gap Matrix

| # | Pattern / Plan Item | Status | Evidence |
|---|---------------------|--------|----------|
| 1 | **GitHub Issues = Central Brain** | ✅ IMPLEMENTED | Issue templates exist (`.github/ISSUE_TEMPLATE/squad-task.yml`), triage workflow exists, labels created |
| 2 | **Ralph Outer Loop (`ralph-watch.ps1`)** | ⚠️ BUILT, NOT ACTIVATED | Script exists at `tools/ralph-watch.ps1` (fully implemented, single-instance guard, heartbeat, structured logging). **Never run persistently.** Heartbeat file exists but is likely stale. |
| 3 | **Maximize Parallelism in Ralph** | ❌ NOT TESTED | Ralph prompt exists but parallel agent spawning not validated in production runs |
| 4 | **Two-Way Communication via Webhooks** | ❌ NOT IMPLEMENTED | No webhook integration, no Teams/Slack adapter, no notification channel configured |
| 5 | **Auto-Scan External Inputs** | ❌ NOT IMPLEMENTED | No email/Teams/HackerNews scanning. No `teams-bridge` label usage. |
| 6 | **Podcaster for Long Content** | ❌ NOT IMPLEMENTED | No Edge TTS integration. Phase 5 item — correctly deferred. |
| 7 | **Self-Built Scheduler** | ⚠️ BUILT, NOT ACTIVATED | `tools/scheduler/Invoke-SquadScheduler.ps1` exists with cron evaluator. Needs `schedule.json` tasks defined and actual activation via ralph-watch. |
| 8 | **Squad Monitor Dashboard** | ❌ NOT IMPLEMENTED | Not installed (`dotnet tool install -g squad-monitor` never run). Phase 5 item. |
| 9 | **Side Project Repos** | ⚠️ AUTHORIZED, NOT USED | Founder directive grants autonomy for repo creation. No side repos created yet. |
| 10 | **GitHub Actions Ecosystem** | ✅ MOSTLY IMPLEMENTED | 20+ workflows exist: triage, heartbeat, daily-digest, drift-detection, archive-done, label-enforce, label-sync, CI, docs, preview, release. **Comprehensive.** |
| 11 | **Self-Approve PRs** | ❌ NOT CONFIGURED | No auto-merge setup. PRs require human review. |
| 12 | **Cross-Repo Contributions** | ❌ NOT STARTED | No upstream PRs to Squad repo or other tools |
| 13 | **`squad upstream` for inherited context** | ❌ NOT IMPLEMENTED | Option C planned studio-hub + game-repo inheritance. No `squad upstream` configured. ComeRosquillas lives inside FFS repo, not as a subsquad. |
| 14 | **Multi-repo management** | ❌ NOT IMPLEMENTED | ralph-watch supports `$Repos` param but only single repo in use |
| 15 | **TLDR Convention** | ⚠️ DOCUMENTED, NOT ENFORCED | Team knows the pattern. No automated enforcement. No CI check for TLDR in issue comments. |
| 16 | **Issue Template** | ✅ IMPLEMENTED | `.github/ISSUE_TEMPLATE/squad-task.yml` exists |

### Phase Tracking (from `solo-upstream-subsquad-proposal.md`)

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 0** | Restructure studio hub, TLDR convention | ⚠️ PARTIAL — hub exists, TLDR not enforced |
| **Phase 1** | Create game repo, squad init, squad upstream | ❌ NOT STARTED — ComeRosquillas absorbed into FFS, no subsquad |
| **Phase 2** | CI/CD, workflows, issue templates, project board | ✅ MOSTLY DONE — workflows are comprehensive |
| **Phase 3** | ralph-watch + scheduler | ⚠️ BUILT, NOT ACTIVATED |
| **Phase 4** | Game Sprint 0 — build the game | ⚠️ IN PROGRESS — ComeRosquillas exists (1636 LOC, playable) but no sprint structure |
| **Phase 5** | Podcaster + Squad Monitor | ❌ NOT STARTED (correctly — Phase 5) |

---

### Summary: What's Actually Blocking Autonomy

The infrastructure is **more built than it appears**. The real gap is **activation, not construction**:

1. **ralph-watch.ps1 needs to be started and left running.** The script is production-ready with single-instance guards, heartbeat, logging, and multi-repo support. It just hasn't been turned on.

2. **Scheduler needs tasks defined.** `Invoke-SquadScheduler.ps1` works but `schedule.json` needs actual recurring tasks (daily playtest, weekly retro, drift detection triggers).

3. **TLDR enforcement is cultural, not technical.** Agents write TLDRs when reminded. Need a lightweight CI check or prompt-level convention reinforcement.

4. **The subsquad/upstream model was abandoned** in favor of absorbing ComeRosquillas directly into FFS. This is fine for a single game but won't scale. Decision needed: is this the permanent model or a temporary expedient?

5. **Webhooks/notifications are the biggest true gap.** No way for the squad to proactively signal Joaquín when something important happens. This is the highest-leverage unbuilt feature.

### Recommended Priority Order
1. **P0:** Activate ralph-watch persistently (DevBox or local machine)
2. **P0:** Define schedule.json with 3-5 recurring tasks
3. **P1:** Install Squad Monitor (`dotnet tool install -g squad-monitor`)
4. **P1:** Add webhook notification for critical events (CI failure, PR merged)
5. **P2:** Evaluate subsquad model for ComeRosquillas vs monorepo approach
6. **P2:** Podcaster integration for long reports

---

*Filed by Solo. Issues created in GitHub for actionable items.*
