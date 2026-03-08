# GitHub Operations Setup Decision

**Date:** 2026-03-08  
**Author:** Mace (Producer)  
**Status:** Implemented  
**Scope:** GitHub-centric project operations for FirstFrameStudios

## What Was Done

1. **README.md Development Section** ✅
   - Added "Development" section linking to:
     - Issues Board: https://github.com/jperezdelreal/FirstFrameStudios/issues
     - Project Board creation guide (via GitHub UI)
     - Wiki link
     - Workflow diagram (Issue → Branch → PR → Review → Merge)
     - Reference to CONTRIBUTING.md

2. **CONTRIBUTING.md Created** ✅
   - Complete work flow documentation
   - Branch naming convention: `squad/{issue-number}-{slug}`
   - Commit message format with examples
   - Label system explanation:
     - Game tags: `game:ashfall`, `game:first-punch`, `game:cinder`, `game:pulse`
     - Squad tags: `squad:engine`, `squad:gameplay`, `squad:art`, `squad:audio`, `squad:content`, `squad:ui`, `squad:architecture`, `squad:tooling`
     - Type tags: `type:feature`, `type:bug`, `type:refactor`, `type:docs`, `type:design`
     - Priority tags: `priority:p0`, `priority:p1`, `priority:p2`, `priority:p3`
     - Status tags: `status:ready`, `status:in-progress`, `status:blocked`, `status:review`
   - How Squad agents pick up work (via labels and polling)
   - PR process standards
   - Code review expectations
   - Load capacity governance (20% cap)

3. **team.md Updated** ✅
   - Added "Issue Source" section:
     - Repository: jperezdelreal/FirstFrameStudios
     - Connected: 2026-03-08
     - Filters: game:ashfall (current sprint)

4. **GitHub Wiki Status** ⏳
   - Wiki cannot be enabled via GitHub API (restricted endpoint)
   - **Manual Action Required:** Repository owner (joperezd) must:
     1. Go to https://github.com/jperezdelreal/FirstFrameStudios/settings
     2. Scroll to "Features" section
     3. Check "Wikis" checkbox
     4. Save
     5. Create initial home page: https://github.com/jperezdelreal/FirstFrameStudios/wiki/_new
        - Title: "Home"
        - Content: Link to `.squad/identity/`, design docs, architecture guides

## Why These Changes

- **Centralized Visibility:** All work flows through GitHub Issues → Squad agents pick up via labels
- **Clear Workflow:** CONTRIBUTING.md removes ambiguity; squad agents know exactly how to work
- **Scalability:** Label system (`game:*`, `squad:*`, `priority:*`) supports multi-project, multi-agent parallelism
- **Governance:** Load tracking + 20% cap prevents bottlenecks (proven in Ashfall Sprint 0 plan)
- **Discoverability:** README Development section is first thing people see; drives traffic to processes

## Decisions Made

1. **Label-driven work allocation** — Squad agents query GitHub Issues by label, not manual assignment
2. **Branch naming ties to issues** — `squad/{issue-number}` enables automatic linking and visibility
3. **Wiki is optional, not critical** — Processes documented in CONTRIBUTING.md; Wiki can host GDDs, ARCHs, playbooks separately
4. **Load cap governance in CONTRIBUTING.md** — Team understands 20% rule and how Mace enforces it
5. **Game-tagged filtering** — Current sprint (`game:ashfall`) can be filtered; future games (`game:cinder`, `game:pulse`) follow same model

## Integration Points

- **Solo (Lead):** Understands branch strategy ties to issues; can code-review PRs linking to issues
- **Yoda (Designer):** GDDs go to Wiki; can be referenced in issues via `Depends on design doc: #WIKI_URL`
- **Lando, Chewie, others:** Pick up issues via `squad:{role}` labels; follow CONTRIBUTING.md workflow
- **Jango (Tools):** Can automate GitHub Actions to validate branch naming, commit format, load tracking

## Risk Mitigation

1. **Wiki not enabled immediately?** → No impact; all critical docs are in repo (`.squad/`, game docs). Wiki can be enabled later.
2. **Squad agents don't find issues?** → Establish daily standup in #ashfall Slack; clarify which agent owns which label search
3. **Load cap enforcement?** → Mace monitors PR titles/labels daily; blocks merges if agent would exceed 20%

## Follow-Up Actions

- [ ] **joperezd:** Enable Wiki in repo settings
- [ ] **joperezd:** Create Wiki home page linking to `.squad/identity/`, GDDs, ARCHITECTURE docs
- [ ] **Solo:** Train agents on branch naming + commit format (run through examples in #ashfall)
- [ ] **Jango:** (Optional) Create GitHub Actions workflow to validate branch name format on PR creation
- [ ] **Mace:** Begin daily standup in #ashfall, call out load balance issues proactively

## Learned Patterns

- **GitHub Issues as source of truth** — Works if labels are consistent. Recommend wiki/labeling standards doc (this CONTRIBUTING.md).
- **Squad label filtering enables massive parallelism** — 14-agent team can work simultaneously if they know their label space
- **Branch naming matters** — `squad/{issue}` creates visibility; enables automatic linking in PRs, commits, discussions
- **Commit convention enables history tracing** — "Fixes #XX" + agent co-authored-by means later audits are clean and attributable
