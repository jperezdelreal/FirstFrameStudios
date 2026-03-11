### 2026-03-11: Learnings from Tamir Dresher's "Organized by AI" blog
**By:** Joaquín (via Copilot) — team reading assignment
**Source:** https://www.tamirdresher.com/blog/2026/03/10/organized-by-ai
**What:** Key patterns from a power-user who runs Squad as his daily productivity system.

#### Operational Patterns We Should Adopt

1. **GitHub Issues = Central Brain.** All Squad discussion happens IN issue comments. Agents always write TLDR at top of every comment. The founder reviews TLDRs, writes instructions in comments, sets status back to "Todo." Everything is documented, searchable, nothing lost.

2. **Ralph Outer Loop (`ralph-watch.ps1`).** Wraps Ralph in a persistent PowerShell loop that: (a) pulls latest code before each round, (b) spawns fresh Copilot sessions each time, (c) has heartbeat files, structured logging, failure alerts. Runs on machine or DevBox unattended.

3. **Maximize Parallelism in Ralph.** Prompt explicitly says: "If there are 5 actionable issues, spawn 5 agents in one turn." Don't work issues one at a time.

4. **Two-Way Communication via Webhooks.** Squad sends Teams/Slack messages for critical events (CI failures, PR merges, blocking issues). Uses Adaptive Cards with styled formatting. Rule: only send when genuinely newsworthy, never spam.

5. **Auto-Scan External Inputs.** Squad reads emails (Outlook COM), Teams messages, and tech news (HackerNews, Reddit). Creates GitHub issues automatically for actionable items. Labels like `teams-bridge` distinguish auto-created from manual.

6. **Podcaster for Long Content.** Converts markdown reports to audio via Edge TTS. Listen to 3000-word reports while walking. Auto-triggered after significant deliverables (>500 words).

7. **Self-Built Scheduler.** `Invoke-SquadScheduler.ps1` — cron-based triggers for recurring tasks (daily scans, weekly reports). Maintains state file. Runs before each Ralph round.

8. **Squad Monitor Dashboard.** Real-time .NET tool showing agent activity, token usage, costs. Open-sourced at github.com/tamirdresher/squad-monitor. `dotnet tool install -g squad-monitor`.

9. **Side Project Repos.** Squad creates their own repos for tools/utilities that shouldn't clutter the main repo. Links back to main project.

10. **GitHub Actions Ecosystem.** Workflows for: triage, heartbeat (5 min), daily digest, docs auto-gen, drift detection (weekly), archive done issues (7 days), notifications, label enforcement, label sync from team.md.

11. **Self-Approve PRs (Personal Repos).** For personal repos, Squad creates, reviews, and merges their own PRs. Human only jumps in for areas they care about or flagged reviews.

12. **Cross-Repo Contributions.** Squad naturally contributes back upstream to tools they use (PRs to Squad repo itself).

#### Philosophy Shifts

- **"I don't manage tasks anymore. I manage decisions."** — The human focuses on decisions, Squad does everything else.
- **"AI is the first approach that meets me where I am."** — AI adapts to human chaos, not the other way around.
- **"The boundary between using a tool and building a tool dissolved."** — Squad evolved its own tools (monitor, scheduler, tunnel) as needs arose.
- **Squad as brain extension, not replacement.** — User still makes all important decisions. AI remembers, does tedious work, keeps systems running.

#### Applicable to First Frame Studios

- We should adopt the **GitHub Issues as backbone** pattern — all agent work documented in issue comments with TLDRs
- We should explore **ralph-watch.ps1** for unattended operation during long builds/sprints
- **Squad Monitor** could give Joaquín visibility into what agents are doing during long parallel spawns
- The **Podcaster** pattern could help Joaquín consume long analysis docs (we generate a LOT of analysis)
- **GitHub Actions workflows** (triage, heartbeat, daily digest) would automate our current manual processes
- The **self-built scheduler** pattern would enable recurring tasks (daily playtest, weekly retro)
