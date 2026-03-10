# Squad Ecosystem Audit — Comprehensive Feature Investigation

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-07-23  
**Status:** PROPOSED  
**Scope:** Squad CLI v0.8.25, all features vs. current adoption

---

## Executive Summary

We're running Squad v0.8.25 with a mature 16-member team (14 AI agents + Ralph + @copilot), 31 skills, 5 ceremonies, and 17 GitHub Actions workflows. After a thorough investigation of the CLI, docs site, and upstream Squad repo, I found **6 high-value features we should adopt now**, **4 worth adopting later**, and **3 to skip**. Our biggest gaps are: no `squad nap` hygiene (our history files are 69KB+), no SubSquads for parallel workstreams, and unused plugin marketplace.

---

## TOP 5 RECOMMENDATIONS — ADOPT NOW

| # | Feature | Why | Effort |
|---|---------|-----|--------|
| 1 | **`squad nap --deep`** | Our `.squad/` state is bloated (Solo history alone is 69KB). Context hygiene prevents agent confusion and token waste. | Trivial — one command |
| 2 | **SubSquads (Workstreams)** | Split Art Sprint vs. Gameplay vs. Audio into isolated Codespace lanes. Prevents merge conflicts and rate-limit bottleneck. | Small — create `streams.json` |
| 3 | **Add Joaquín as Human Team Member** | Formal approval gates for architecture decisions and ship/no-ship calls. Agents stop-and-wait instead of guessing. | Trivial — one prompt |
| 4 | **Enable `squad-heartbeat.yml` cron** | Ralph runs every 30 min unattended. Untriaged issues get auto-processed even when we're AFK. | Trivial — uncomment cron line |
| 5 | **`squad build --check` in CI** | Catch config drift between `squad.config.ts` and `.squad/` markdown. Prevents silent divergence. | Small — add workflow step |

---

## Full Feature Audit

### 1. Squad CLI Commands

| Command | What It Does | Status | Value | Effort | Recommendation |
|---------|-------------|--------|-------|--------|----------------|
| `squad init` | Initialize Squad | ✅ Active (done long ago) | — | — | Already done |
| `squad upgrade` | Update Squad-owned files | ✅ Active | High | Trivial | Keep running on new releases |
| `squad status` | Show active squad info | ✅ Active | Low | Trivial | Already available |
| `squad triage` | Scan and categorize issues | 🟡 Configured (via workflow) | High | Trivial | Use `squad triage --interval 10` for local persistent triage |
| `squad loop` | Ralph continuous work loop | 🟡 Configured (in-session only) | High | Small | Enable for sprint execution sessions |
| `squad hire` | Team creation wizard | ✅ Active | Medium | Trivial | Already used for team building |
| `squad copilot` | Add/remove @copilot agent | ✅ Active | Medium | Trivial | Already configured |
| `squad plugin` | Manage plugin marketplaces | ❌ Not set up | Medium | Small | Adopt later — see Plugin section |
| `squad export` | Export squad to JSON snapshot | ❌ Not used | Medium | Trivial | Use before major migrations |
| `squad import` | Import from export file | ❌ Not used | Medium | Trivial | Paired with export |
| `squad start` | Copilot with remote access | ❌ Not set up | Low | Medium | Adopt later — see RC section |
| `squad nap` | Context hygiene/compression | ❌ Not used | **High** | Trivial | **ADOPT NOW** |
| `squad doctor` | Health checks | ✅ Active (8/8 passing) | Medium | Trivial | Run periodically |
| `squad consult` | Personal squad on foreign repos | ❌ N/A for us | Low | — | Skip — we own our repos |
| `squad extract` | Extract learnings from consult | ❌ N/A | Low | — | Skip — paired with consult |
| `squad subsquads` | Multi-Codespace scaling | ❌ Not set up | **High** | Small | **ADOPT NOW** |
| `squad link` | Link to remote team root | ❌ Not set up | Medium | Small | Adopt later — useful for multi-repo |
| `squad build` | Compile squad.config.ts | 🟡 Have config, never built | **High** | Small | **ADOPT NOW** |
| `squad aspire` | .NET Aspire dashboard | ❌ Not set up | Low | Medium | Skip — not .NET project |
| `squad rc` | Remote Control bridge | ❌ Not set up | Low | Medium | Adopt later — nice for demos |
| `squad upstream` | Manage upstream Squad sources | ❌ Not set up | Medium | Small | Adopt later — multi-repo synergy |
| `squad migrate` | Convert between formats | ❌ Not needed | Low | — | Skip — already on SDK mode |
| `squad scrub-emails` | Remove PII | ✅ Available | Low | Trivial | Run if needed |

---

### 2. Plugin Marketplace

**Status:** ❌ Not set up  
**Value:** Medium  
**Effort:** Small

**What it is:** Community-curated bundles of agent templates, skills, and conventions from GitHub repos. Four marketplaces exist:

| Marketplace | URL | Relevance to Us |
|-------------|-----|-----------------|
| awesome-copilot | `github/awesome-copilot` | 🟡 Low — frontend/backend web focus, not game dev |
| anthropic-skills | `anthropics/skills` | 🟢 Medium — Claude optimization patterns could help |
| azure-cloud-dev | `github/azure-cloud-development` | 🔴 None — we don't use Azure |
| security-hardening | `github/security-hardening` | 🟡 Low — game doesn't handle sensitive data |

**Game dev gap:** No game development marketplace exists yet. None of the existing marketplaces have Godot, GDScript, game design, or fighting game plugins.

**Recommendation:** Adopt later. Consider **creating our own marketplace** repo (`FirstFrameStudios/squad-gamedev-plugins`) packaging our 31 skills as reusable plugins. This would be the first game-dev Squad marketplace.

**How to adopt:**
1. `squad plugin marketplace add anthropics/skills` — get Claude optimization patterns
2. Long-term: Package our skills into a public marketplace for the Squad community

---

### 3. SubSquads (Workstreams)

**Status:** ❌ Not set up  
**Value:** **HIGH**  
**Effort:** Small

**What it is:** Partitions work into labeled SubSquads so multiple Codespaces can work in parallel on different parts of the project. Each SubSquad targets a GitHub label and optionally restricts to certain directories.

**Why we need it:** Our 14-agent team has natural workstream boundaries:
- **Art Sprint** (`team:art`) — Boba, Leia, Bossk, Nien → `games/ashfall/assets/`, `tools/blender/`
- **Gameplay** (`team:gameplay`) — Lando, Tarkin, Chewie → `games/ashfall/scripts/`, `games/ashfall/scenes/`
- **Audio** (`team:audio`) — Greedo → `games/ashfall/audio/`
- **QA** (`team:qa`) — Ackbar, Jango → `games/ashfall/test/`

**Recommendation:** **ADOPT NOW**

**How to adopt:**
1. Create `.squad/streams.json`:
```json
{
  "streams": [
    {
      "name": "art-sprint",
      "labelFilter": "team:art",
      "folderScope": ["games/ashfall/assets/", "tools/"],
      "workflow": "branch-per-issue"
    },
    {
      "name": "gameplay",
      "labelFilter": "team:gameplay",
      "folderScope": ["games/ashfall/scripts/", "games/ashfall/scenes/"],
      "workflow": "branch-per-issue"
    },
    {
      "name": "audio",
      "labelFilter": "team:audio",
      "folderScope": ["games/ashfall/audio/"],
      "workflow": "branch-per-issue"
    }
  ]
}
```
2. Create GitHub labels: `team:art`, `team:gameplay`, `team:audio`
3. In each Codespace, activate: `squad subsquads activate art-sprint`

---

### 4. Human Team Members

**Status:** ❌ Not set up  
**Value:** **HIGH**  
**Effort:** Trivial

**What it is:** Adds real people to the Squad roster with 👤 Human badge. When work routes to a human, Squad pauses and waits for their input. Humans can't be spawned as sub-agents but can serve as reviewers and approval gates.

**Why we need it:** Joaquín is the founder but has no formal roster entry. Adding him creates explicit approval gates for:
- Architecture decisions (currently ad-hoc)
- Ship/no-ship calls at milestones
- Art direction sign-off
- Design review participation in ceremonies

**Recommendation:** **ADOPT NOW**

**How to adopt:**
1. In a Squad session: `"Add Joaquín (joperezd) as Founder and Creative Director"`
2. He appears on roster with 👤 badge
3. Update ceremonies to add Joaquín as participant in Design Review and Integration Gate
4. Routing: architecture decisions and milestone sign-offs route to Joaquín

---

### 5. SDK-First Mode & `squad build`

**Status:** 🟡 Have `squad.config.ts`, never run `squad build`  
**Value:** **HIGH**  
**Effort:** Small

**What it is:** `squad.config.ts` is the single source of truth. `squad build` compiles it into `.squad/` markdown. `squad build --check` validates sync in CI.

**Current gap:** We have a `squad.config.ts` that defines models, routing, and casting — but our `.squad/` markdown files were created independently. The config and the markdown may have **silently diverged**. Our config is also incomplete — it doesn't define agents, ceremonies, hooks, or skills.

**Recommendation:** **ADOPT NOW** (partial — build validation, not full migration)

**How to adopt:**
1. Run `squad build --dry-run` to see what would be generated vs. what exists
2. Expand `squad.config.ts` to include all agents, ceremonies, hooks
3. Add `squad build --check` to CI workflow (add step to `squad-ci.yml`)
4. Optionally: `squad build --watch` for live rebuilds during development
5. Add `defineHooks()` for governance: allowed write paths, blocked commands, PII scrubbing

---

### 6. `squad watch` / Ralph Persistent Polling

**Status:** 🟡 Ralph exists on roster, no persistent polling  
**Value:** High  
**Effort:** Trivial

**What it is:** `squad watch --interval 10` runs Ralph as a local watchdog, checking GitHub every N minutes for untriaged issues, stale PRs, CI failures. Three layers: in-session (`Ralph, go`), local watchdog (`squad watch`), cloud heartbeat (GitHub Actions cron).

**Current gap:** We use Ralph in-session only. The heartbeat workflow exists but cron is commented out. No local watchdog.

**Recommendation:** Adopt now — enable heartbeat cron, use `squad watch` during sprint sessions.

**How to adopt:**
1. Edit `.github/workflows/squad-heartbeat.yml` — uncomment the cron schedule (e.g., `'*/30 * * * *'`)
2. During sprints, run `squad watch --interval 10` in a background terminal
3. Ensure `gh` CLI is authenticated with Classic PAT (scopes: `repo`, `project`)

---

### 7. `squad doctor` Deep Checks

**Status:** ✅ Active (8/8 passing)  
**Value:** Medium  
**Effort:** Trivial

**What it is:** Validates squad setup — checks files, config, health. Already passing all 8 checks.

**Recommendation:** Keep running periodically, especially after `squad upgrade`.

---

### 8. Ceremonies

**Status:** ✅ 5 configured (Design Review, Retrospective, Integration Gate, Spec Validation, Godot Smoke Test)  
**Value:** Medium  
**Effort:** Small

**What the docs offer:** The docs show ceremonies are flexible — any trigger, any schedule, custom agendas. Built-in types are Design Review and Retrospective, but you can create any custom ceremony.

**Ceremonies we could add:**

| Ceremony | Trigger | Value |
|----------|---------|-------|
| **Sprint Planning** | Manual, start of sprint | High — Mace + Yoda + Solo plan the sprint |
| **Daily Standup** | Schedule (cron `0 9 * * 1-5`) | Medium — agents report blockers |
| **Art Review** | After art PRs merged | Medium — Boba reviews visual consistency |
| **Security Review** | Before release builds | Low — less critical for single-player game |

**Recommendation:** Add Sprint Planning ceremony now; Daily Standup adopt later (requires `squad loop` active).

**How to adopt:** Add to `.squad/ceremonies.md`:
```markdown
## Sprint Planning

| Field | Value |
|-------|-------|
| **Trigger** | manual |
| **When** | before |
| **Condition** | start of new sprint |
| **Facilitator** | Mace (Producer) |
| **Participants** | Mace + Yoda + Solo + Joaquín |
| **Time budget** | focused |
| **Enabled** | ✅ yes |
```

---

### 9. GitHub Actions Workflows

**Status:** 17 workflows installed — 12 active, 5 template stubs  
**Value:** High  
**Effort:** Varies

| Workflow | Status | Action Needed |
|----------|--------|---------------|
| **squad-heartbeat.yml** | 🟡 Active but cron disabled | **Uncomment cron** — enables unattended triage |
| **squad-triage.yml** | ✅ Active | Working — routes `squad`-labeled issues |
| **squad-issue-assign.yml** | ✅ Active | Working — acknowledges `squad:*` labels |
| **sync-squad-labels.yml** | ✅ Active | Working — syncs labels from roster |
| **squad-label-enforce.yml** | ✅ Active | Working — enforces mutual exclusivity |
| **pr-body-check.yml** | ✅ Active | Working — warns if no `Closes #N` |
| **branch-validation.yml** | ✅ Active | Working — PRs must target main |
| **squad-main-guard.yml** | ✅ Active | Working — blocks `.squad/` on protected branches |
| **squad-promote.yml** | ✅ Active | Working — dev→preview→main promotion |
| **integration-gate.yml** | ✅ Active | Working — GDScript linting on PRs to main |
| **godot-project-guard.yml** | ✅ Active | Working — warns on project.godot changes |
| **godot-release.yml** | ✅ Active | Working — exports Godot builds on tags |
| **squad-ci.yml** | ⚠️ Template stub | Needs build/test commands configured |
| **squad-docs.yml** | ⚠️ Template stub | Needs docs build configured |
| **squad-release.yml** | ⚠️ Template stub | Needs release process configured |
| **squad-insider-release.yml** | ⚠️ Template stub | Needs insider build configured |
| **squad-preview.yml** | ⚠️ Template stub | Needs preview validation configured |

**Recommendation:** Enable heartbeat cron now. The 5 template stubs need Godot-specific build commands — configure `squad-ci.yml` to run GDScript linting and Godot export checks on PRs.

---

### 10. Remote Squad Mode (`squad link`)

**Status:** ❌ Not set up  
**Value:** Medium (for future multi-repo)  
**Effort:** Small

**What it is:** Links project to a remote team root — shared team identity (casting, charters, decisions) across multiple repos while keeping project-specific state local.

**Relevance:** Useful when we have multiple game repos sharing the same studio team. Currently single-repo.

**Recommendation:** Adopt later — when we start a second game project, `squad link` lets the new repo inherit our team without duplicating configuration.

---

### 11. Skills System

**Status:** ✅ 31 skills active  
**Value:** High (already delivering value)  
**Effort:** N/A

**Current skills (31):** 2d-game-art, animation-for-games, beat-em-up-combat, canvas-2d-optimization, code-review-checklist, enemy-encounter-design, feature-triage, fighting-game-design, game-audio-design, game-design-fundamentals, game-feel-juice, game-qa-testing, gdscript-godot46, github-pr-workflow, godot-4-manual, godot-beat-em-up-patterns, godot-project-integration, godot-tooling, input-handling, integration-discipline, level-design-fundamentals, milestone-completion-checklist, multi-agent-coordination, parallel-agent-workflow, procedural-audio, project-conventions, squad-conventions, state-machine-patterns, studio-craft, ui-ux-patterns, web-game-engine

**Best practices from docs:**
- **Confidence lifecycle:** Low → Medium → High. Confidence only goes up.
- **Earned vs. Starter:** Starter skills (`squad-*`) get overwritten on upgrade. Earned skills are protected.
- **Team-wide:** All agents read all skills. Not per-agent.
- **Portable:** Skills survive export/import.

**Recommendation:** Audit confidence levels — ensure battle-tested skills are at High. Consider consolidating overlapping skills (e.g., `beat-em-up-combat` + `fighting-game-design`).

---

### 12. Adding Joaquín as Human Member

See **Item 4** above — full details in the Human Team Members section.

---

### 13. `squad rc` (Remote Control)

**Status:** ❌ Not set up  
**Value:** Low (for now)  
**Effort:** Medium

**What it is:** Spawns Copilot CLI in a PTY, mirrors terminal via WebSocket + devtunnel. Phone scans QR code → full terminal on mobile. 7-layer security (devtunnel auth, session tokens, ticket-based WS auth, rate limiting, secret redaction, connection limits, audit logging).

**Cool factor:** High. **Practical value for us:** Low. We work from desktop. Could be useful for demos or monitoring long runs from phone.

**Recommendation:** Skip for now. Adopt when doing live demos or conference talks.

**Prerequisites if adopted:** `winget install Microsoft.devtunnel` → `devtunnel user login` → `squad start --tunnel`

---

### 14. Upstream Inheritance (`squad upstream`)

**Status:** ❌ Not set up  
**Value:** Medium (future)  
**Effort:** Small

**What it is:** Declares external Squad sources to inherit skills, decisions, casting policy, and routing. Supports local paths, git repos, and export snapshots. "Closest-wins" — later entries override.

**Relevance:** If we publish our game-dev skills as a marketplace/upstream repo, other game studios could inherit our expertise. We could also inherit from a community game-dev Squad if one emerges.

**Recommendation:** Adopt later — after creating our marketplace repo.

---

### 15. Context Hygiene (`squad nap`)

**Status:** ❌ Never run  
**Value:** **HIGH**  
**Effort:** Trivial

**What it is:** Compresses, prunes, and archives `.squad/` state. `--deep` does thorough cleanup. `--dry-run` previews.

**Why critical:** Solo's history.md alone is 69KB. decisions.md is 85KB. These bloated files consume agent context tokens and slow down every session. `squad nap --deep` will compress old sessions, prune archived decisions, and keep only active state.

**Recommendation:** **ADOPT NOW — run immediately.**

**How to adopt:**
1. `squad nap --dry-run` — preview what gets cleaned
2. `squad nap --deep` — full cleanup
3. Commit the cleaned state
4. Run monthly or after major milestones

---

### 16. Export/Import

**Status:** ❌ Not used  
**Value:** Medium  
**Effort:** Trivial

**What it is:** `squad export` creates a portable JSON snapshot of the entire team. `squad import` restores it.

**Recommendation:** Run `squad export` before any major upgrade or restructuring. Keep as backup/portability insurance.

---

### 17. Consult Mode

**Status:** ❌ N/A  
**Value:** Low for us  
**Effort:** N/A

**What it is:** Brings personal squad to repos you don't own (OSS, client work) without leaving traces.

**Recommendation:** Skip — we own our repos. Possibly useful if Joaquín contributes to OSS Godot projects.

---

### 18. .NET Aspire Dashboard

**Status:** ❌ Not set up  
**Value:** Low  
**Effort:** Medium

**What it is:** OpenTelemetry observability dashboard. Designed for .NET projects.

**Recommendation:** Skip — we're a Godot/GDScript project, not .NET.

---

## Summary Matrix

| Feature | Status | Value | Effort | Action |
|---------|--------|-------|--------|--------|
| `squad nap --deep` | ❌ | HIGH | Trivial | **ADOPT NOW** |
| SubSquads | ❌ | HIGH | Small | **ADOPT NOW** |
| Human Members (Joaquín) | ❌ | HIGH | Trivial | **ADOPT NOW** |
| Heartbeat cron | 🟡 | HIGH | Trivial | **ADOPT NOW** |
| `squad build --check` CI | 🟡 | HIGH | Small | **ADOPT NOW** |
| Sprint Planning ceremony | ❌ | HIGH | Small | **ADOPT NOW** |
| Ralph `squad watch` | 🟡 | High | Trivial | Adopt soon |
| Plugin marketplace | ❌ | Medium | Small | Adopt later |
| `squad link` | ❌ | Medium | Small | Adopt later (multi-repo) |
| `squad upstream` | ❌ | Medium | Small | Adopt later |
| Export/import | ❌ | Medium | Trivial | Adopt later |
| Skill confidence audit | ✅ | Medium | Small | Adopt later |
| `squad rc` | ❌ | Low | Medium | Skip |
| Aspire dashboard | ❌ | Low | Medium | Skip |
| Consult mode | ❌ | Low | — | Skip |

---

## Implementation Order

**Phase 1 — This sprint (immediate):**
1. Run `squad nap --deep` to clean bloated state
2. Add Joaquín as human team member
3. Uncomment heartbeat cron in `squad-heartbeat.yml`
4. Add Sprint Planning ceremony to `ceremonies.md`
5. Run `squad build --dry-run` to assess config drift

**Phase 2 — Next sprint:**
6. Create `.squad/streams.json` for SubSquads
7. Set up `squad build --check` in CI
8. Run `squad export` as backup
9. Configure `squad-ci.yml` with GDScript lint commands

**Phase 3 — Future:**
10. Create `FirstFrameStudios/squad-gamedev-plugins` marketplace
11. Set up `squad link` when second game starts
12. Explore `squad upstream` for cross-studio knowledge sharing

---

*Solo — Lead / Chief Architect, First Frame Studios*
