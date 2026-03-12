# Multi-Repo Governance — First Frame Studios

> **Author:** Solo (Lead / Chief Architect)
> **Date:** 2025
> **Status:** Active — Governs all cross-repo operations, authority tiers, and hub-downstream relationships.
> **Scope:** Studio-wide. Applies to the FFS hub and all downstream game repositories.

---

## Overview

First Frame Studios operates a **hub-and-spoke multi-repo architecture**. The hub repository (`FirstFrameStudios`, abbreviated FFS) contains studio infrastructure — identity, principles, skills, team definitions, quality gates, ceremonies, and governance. It contains **no game code**. Each game or tool lives in its own downstream repository with a `squad upstream` relationship pointing back to the hub.

This document defines nine domains of governance that together answer every question about authority, autonomy, flow, and coordination across the multi-repo ecosystem.

### Hub Philosophy

> FFS must be 99% autonomous. The founder decides WHAT games to make, not HOW. The hub is the Bible — everything downstream inherits and respects it. Each game breathes FFS values but has creative freedom.

### Current Repositories

| Repository | Type | Stack | Description |
|------------|------|-------|-------------|
| **FirstFrameStudios** | Hub | N/A (infrastructure only) | Studio identity, principles, skills, team definitions, governance, quality gates, ceremonies |
| **ComeRosquillas** | Game (downstream) | HTML/JS arcade | Arcade game — lightweight browser-based project |
| **Flora** | Game (downstream) | Vite + TypeScript + PixiJS | Garden/nature simulation game with modern tooling |
| **ffs-squad-monitor** | Tool (downstream) | Vite dashboard | Studio monitoring dashboard — heartbeat, logs, repo status |

### The Upstream Relationship

Every downstream repo has a `squad upstream` configuration that points to the FFS hub. This relationship means:

- **Identity cascades down.** The studio name, tagline, principles, and core DNA flow from the hub to every game repo.
- **Skills cascade down.** Studio-wide skills (state machines, game feel, multi-agent coordination) are available to all downstream repos. Genre-specific skills are additive per project.
- **Quality gates cascade down.** The studio's Definition of Done and quality gate structure apply everywhere. Game repos may add project-specific gates but cannot weaken studio gates.
- **Team definitions cascade down.** Agent charters, roles, and the routing table originate in the hub.
- **Governance cascades down.** This document governs every repo in the ecosystem.

```
                    ┌─────────────────────────┐
                    │   FirstFrameStudios      │
                    │   (Hub — NO game code)   │
                    │                          │
                    │  • Identity & Principles │
                    │  • Skills & Knowledge    │
                    │  • Quality Gates         │
                    │  • Team & Charters       │
                    │  • Governance (this doc) │
                    │  • Ceremonies            │
                    └──────────┬──────────────┘
                               │ squad upstream
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
     ┌────────────┐   ┌────────────┐   ┌────────────────┐
     │ComeRosquillas│ │   Flora    │   │ffs-squad-monitor│
     │ (HTML/JS)  │   │(Vite+TS+  │   │  (Vite dash)   │
     │            │   │  PixiJS)   │   │                │
     │ Game code  │   │ Game code  │   │ Tool code      │
     │ Local config│  │ Local config│  │ Local config   │
     │ Local docs │   │ Local docs │   │ Local docs     │
     └────────────┘   └────────────┘   └────────────────┘
```

---

## Domain 1: Approval Tiers (T0–T3)

### Philosophy

Not all changes carry equal risk. A typo fix in a README and a new repository creation require fundamentally different levels of scrutiny. The T0–T3 tier system provides a clear, graduated authority model that prevents bottlenecks on low-risk work while ensuring high-risk decisions get appropriate oversight.

### Tier Definitions

#### T0 — Founder-Only

**Authority:** Joaquin (Founder) exclusively. No delegation.

T0 changes are irreversible or foundational decisions that shape the studio's identity, structure, or strategic direction. These are the decisions that, if made poorly, cannot be easily undone and would require rebuilding rather than patching.

> *"FFS must be 99% autonomous. Founder decides WHAT games, not HOW."*

**Examples (exhaustive — T0 is deliberately minimal):**
- Creating a new game repository (deciding what NEW GAMES to build — the founder's only "capricho")
- Modifying studio principles (`principles.md`) — these are foundational and shape all decisions downstream

That's it. Nothing else belongs at T0. If it's not "what new game to build" or "what the studio believes," it's not T0.

**Process:**
1. Proposer (any agent) writes a decision proposal to `.squad/decisions/inbox/`
2. Solo (Lead) reviews for technical feasibility and impact assessment
3. Joaquin (Founder) approves or rejects with documented rationale
4. If approved, the proposer or Solo implements and commits
5. Scribe logs the decision in session history

**Veto:** Only Joaquin can veto a T0 decision. A T0 decision cannot be overridden by any combination of agents.

---

#### T1 — Lead Authority

**Authority:** Solo (Lead) decides. T1 is fully delegated to the Lead — no founder approval required.

T1 changes are significant decisions that affect multiple repos, multiple agents, or the studio's technical direction. They are reversible but expensive to undo. They require architectural judgment. The hub is the Bible — Solo has full authority over it.

**Examples:**
- Creating a new tool/utility repository (e.g., ffs-metrics-dashboard, ffs-release-bot) — Lead decides
- Cross-repo architectural decisions (e.g., standardizing on a shared event bus pattern across all games)
- Changing quality gates or the Definition of Done (`quality-gates.md`)
- Major features that span multiple repositories (e.g., a shared component library used by Flora and ComeRosquillas)
- Adding new studio-wide skills to the hub
- Changing the routing table or issue routing rules (`routing.md`)
- Modifying ceremonies that apply across repos (`ceremonies.md`)
- Changing the New Project Playbook (`new-project-playbook.md`)
- Changing the squad configuration (`squad.config.ts`)
- Promoting an agent to a new role or changing charter scope
- Creating or modifying cross-repo CI/CD pipelines
- Deciding which configuration cascades vs. stays local (Domain 7)
- Changing the upstream relationship model for any downstream repo
- Major refactors to hub infrastructure (`.squad/` directory structure)
- Adding or removing agents from the **FFS Hub roster** — hub team composition
- Sprint scope changes that affect multiple agents or repos
- Structural changes to governance (this document) — unless they modify T0 scope (which remains T0)

**Process:**
1. Solo drafts the proposal with impact assessment across all affected repos
2. Affected agents are consulted (async review, comments on the proposal)
3. Solo reviews, decides, and documents rationale
4. Solo implements or delegates implementation
5. Changes are committed to the hub first, then cascade to downstream repos as needed
6. Scribe logs the decision

**Escalation:** If any agent disagrees with a T1 decision, they may appeal to the Founder. Joaquin (Founder) retains override authority but does not participate in routine T1 approvals.

---

#### T2 — Assigned Agent

**Authority:** The agent assigned to the work, within their domain and repository.

T2 changes are normal development work — features, bug fixes, content creation, and system implementation. They are scoped to a single repo and a single domain. The assigned agent has full authority to make decisions within the boundaries of their charter, the GDD, the architecture document, and the quality gates.

**Examples:**
- Implementing a feature from the sprint backlog (e.g., Lando implementing a combo system in a game repo)
- Fixing a bug within an agent's domain (e.g., Greedo fixing an audio leak)
- Creating game-specific content (e.g., Tarkin designing enemy AI behaviors)
- Writing or updating game-specific documentation (e.g., architecture docs for a specific game)
- Configuring game-specific build settings
- Adding game-specific quality gates that are stricter than studio defaults
- Refactoring within a single module that doesn't change public interfaces
- Creating game-specific CI/CD workflows
- Updating local configuration files in a downstream repo
- Writing tests for code within their domain
- Adding or removing agents in a **game repo roster** — project-scoped, does not affect hub
- Creating project-specific tools, plugins, or MCP connections — total freedom within the project repo
- Forking or cloning an existing tool for project use

**Process:**
1. Agent picks up the issue (via `squad:{agent}` label or sprint assignment)
2. Agent creates a branch following naming convention: `squad/{issue-number}-{slug}`
3. Agent implements, self-tests, and creates a PR
4. Cross-reviewer reviews per the review process in `quality-gates.md`
5. If shared systems are touched, Solo reviews (architecture gate)
6. Agent merges after required approvals
7. Agent updates their `history.md` with learnings

**Boundaries:**
- Cannot change files outside their domain without consulting the domain owner
- Cannot modify hub files (`.squad/identity/`, `.squad/skills/`, etc.) — those require T1
- Cannot change cross-repo contracts or interfaces — those require T1
- Must follow studio quality gates and Definition of Done
- Must reference the issue number in commits

**Escalation:** If a T2 change reveals it needs cross-repo impact, the agent escalates to Solo for T1 assessment.

---

#### T3 — Any Agent

**Authority:** Any agent on the team, no approval required beyond standard PR review.

T3 changes are low-risk improvements that make things better without any chance of breaking things. They don't require domain expertise or architectural judgment.

**Examples:**
- Fixing typos in documentation
- Formatting and style corrections (whitespace, indentation)
- Adding code comments for clarity
- Updating README files with corrected information
- Minor documentation improvements (grammar, clarity, broken links)
- Adding missing JSDoc/GDDoc annotations
- Fixing broken markdown formatting
- Updating copyright years or dates
- Correcting label names or issue templates
- Adding missing entries to `.gitignore`

**Process:**
1. Agent makes the change
2. Agent creates a PR (or commits directly to a non-protected branch)
3. Any other agent can approve the PR
4. Merge

**Boundaries:**
- Cannot change any code logic, even "obvious" fixes (those are T2)
- Cannot change configuration values (those are T2)
- Cannot add new files (those are T2 minimum)
- Cannot modify `.squad/identity/` files (those are T1 minimum)
- If in doubt, escalate to T2

---

### Tier Decision Matrix

Use this matrix when you're unsure which tier applies:

| Question | If Yes → | If No → |
|----------|----------|---------|
| Does this create a new **game** repository? | T0 | Continue ↓ |
| Does this modify studio principles (`principles.md`)? | T0 | Continue ↓ |
| Does this create a new **tool/utility** repository? | T1 | Continue ↓ |
| Does this affect multiple repositories? | T1 | Continue ↓ |
| Does this change studio-wide standards (quality gates, skills)? | T1 | Continue ↓ |
| Does this change cross-repo contracts or interfaces? | T1 | Continue ↓ |
| Does this change the routing table or ceremonies? | T1 | Continue ↓ |
| Does this refactor `.squad/` directory structure? | T1 | Continue ↓ |
| Does this add or remove an agent from the **FFS Hub** roster? | T1 | Continue ↓ |
| Does this change governance (without modifying T0 scope)? | T1 | Continue ↓ |
| Does this add or remove an agent from a **game repo** roster? | T2 | Continue ↓ |
| Does this create project-specific tools, plugins, or MCP connections? | T2 | Continue ↓ |
| Does this involve implementing a feature, fixing a bug, or creating content? | T2 | Continue ↓ |
| Does this change any code logic or configuration? | T2 | Continue ↓ |
| Is this purely documentation, formatting, or cosmetic? | T3 | Ask Solo |

**When tiers conflict:** If a change spans multiple tiers, the **highest tier wins**. A documentation change (T3) that also modifies a quality gate (T1) is a T1 change.

---

### Repo Creation Tiers

Not all repository creation carries the same weight. The tier depends on what the repo represents:

| Repo Type | Tier | Who Decides | Rationale |
|-----------|------|-------------|-----------|
| **Game repo** | T0 | Founder only | New games change studio direction — this is the founder's only "capricho" |
| **Tool/utility repo** (e.g., ffs-squad-monitor, ffs-release-bot) | T1 | Lead (Solo) decides | Tools are infrastructure, not strategic direction changes |
| **Fork/experimental repo** (clone of existing tool, proof-of-concept) | T2 | Assigned agent, if issue justifies | Low-risk exploration that doesn't commit studio resources |

---

## Domain 2: Autonomy Levels

### Philosophy

Downstream repos are not satellites mindlessly mirroring the hub. They are independent creative projects that benefit from shared infrastructure. The autonomy model defines what each repo controls locally vs. what it inherits from the hub.

### Three Autonomy Zones

#### Zone A — Hub-Controlled (No Local Override)

These elements are defined in the hub and cascade to all downstream repos without modification. Downstream repos **cannot** override, weaken, or opt out of these.

| Element | Hub File | Rationale |
|---------|----------|-----------|
| Studio identity | `identity/company.md` | One studio name, one tagline, one DNA — everywhere |
| Leadership principles | `identity/principles.md` | Decision-making framework must be consistent across all projects |
| Approval tiers (T0–T3) | `identity/governance.md` | Authority model cannot vary per repo |
| Team roster & charters | `team.md`, `agents/*/charter.md` | One source of truth for who does what |
| Bug severity definitions | `identity/quality-gates.md` §3 | CRITICAL/HIGH/MEDIUM/LOW/COSMETIC mean the same thing everywhere |
| Decision authority model | `identity/governance.md` §9 | Who approves what cannot be ambiguous |
| Mission and vision | `identity/mission-vision.md` | Strategic direction is studio-level |
| Growth framework | `identity/growth-framework.md` | How the studio evolves is not per-project |

**Enforcement:** If a downstream repo contains a file that contradicts a Zone A element, the hub version is authoritative. The downstream file should be removed or updated to reference the hub.

---

#### Zone B — Hub-Defaults with Local Extension

These elements cascade from the hub as defaults, but downstream repos **may extend** them — adding stricter requirements, additional gates, or project-specific ceremonies. They may **not** weaken or remove hub defaults.

| Element | Hub Default | Local Extension Allowed |
|---------|-------------|------------------------|
| Quality gates | Code, Art, Audio, Design, Integration gates | Add game-specific gates (e.g., "Fighting game frame data validation gate" for Ashfall) |
| Definition of Done | 8-item checklist in `quality-gates.md` §2 | Add project-specific DoD items (e.g., "Deterministic replay test passes") |
| Ceremonies | Design Review, Retrospective | Add project-specific ceremonies (e.g., "Weekly balance playtest" for a fighting game) |
| Routing table | `routing.md` agent assignments | Add project-specific routing rules (e.g., "All Ember System issues → Lando") |
| Commit conventions | `CONTRIBUTING.md` format | Add project-specific commit scopes (e.g., `feat(ember):`, `fix(kael):`) |
| CI/CD | Hub-level workflows (if any) | Add game-specific build/test/deploy workflows |
| Label system | `game:*`, `squad:*`, `priority:*`, `type:*` | Add game-specific labels (e.g., `character:kael`, `system:ember`) |

**Rule of Extension:** A downstream repo's local configuration must be a **superset** of the hub default, never a subset. If the hub requires cross-review before merge, a game repo cannot waive that requirement. It can, however, require *additional* reviewers.

**Example — Flora adding a stricter gate:**
```markdown
# Flora — Local Quality Gates (extends hub defaults)

## All hub gates apply (see FirstFrameStudios/identity/quality-gates.md)

## Additional: TypeScript Strict Mode Gate
| # | Requirement | Rationale |
|---|-------------|-----------|
| TS1 | Zero TypeScript errors with `strict: true` | Flora uses strict TS; no `any` casts without documented justification |
| TS2 | All public functions have JSDoc | TypeScript project requires documented interfaces |
```

---

#### Zone C — Locally Owned (Hub Does Not Control)

These elements are fully owned by each downstream repo. The hub has no authority over them and does not cascade defaults.

| Element | Owner | Rationale |
|---------|-------|-----------|
| Game code | Downstream repo | Each game has its own codebase, architecture, and implementation |
| Game design documents (GDD) | Downstream repo | Creative vision is per-project |
| Architecture documents | Downstream repo | Technical architecture varies by engine, stack, and game requirements |
| Game-specific assets | Downstream repo | Art, audio, levels — all project-specific |
| Technology stack choice | Downstream repo (T1 for new projects) | Each game can use a different engine/framework |
| Sprint planning & backlog | Downstream repo | Sprints are per-project with per-project velocity |
| Game-specific configuration | Downstream repo | `tsconfig.json`, `project.godot`, `vite.config.ts` — all local |
| Release schedule | Downstream repo | Each game ships on its own timeline |
| Local documentation | Downstream repo | README, CHANGELOG, local contributing guide |
| Branch strategy | Downstream repo | `main` vs `master`, release branches, etc. |
| Game-specific labels | Downstream repo | Beyond the studio standard label set |

**Boundary:** The moment a local decision affects another repo (e.g., a shared library, a cross-repo skill, a change to the monitor dashboard that affects all repos), it crosses from Zone C to Zone B or T1 authority.

---

### Autonomy by Repository

| Repository | Autonomy Profile | Notes |
|------------|------------------|-------|
| **FirstFrameStudios** (Hub) | N/A — this IS the authority | All Zone A and Zone B defaults originate here |
| **ComeRosquillas** | High autonomy | Mature HTML/JS project; follows hub principles but has minimal hub infrastructure integration |
| **Flora** | Standard autonomy | Modern Vite+TS+PixiJS stack; uses hub skills and quality gates with local TypeScript extensions |
| **ffs-squad-monitor** | Low autonomy (tool) | Studio infrastructure tool; closely coupled to hub data formats and team definitions |

---

## Domain 3: Skill Flow

### Philosophy

Skills are the studio's institutional knowledge — documented patterns, techniques, and lessons that compound across projects. The hub is the single source of truth for studio-wide skills. Game repos consume skills; they don't duplicate them.

### Skill Categories

#### Studio-Wide Skills (Hub-Owned)

These skills live in `FirstFrameStudios/.squad/skills/` and are available to all downstream repos via the upstream relationship.

| Skill | Scope | Example Consumers |
|-------|-------|-------------------|
| `multi-agent-coordination` | Integration contracts, file ownership, conflict prevention | All repos |
| `state-machine-patterns` | State machine design across any engine | All game repos |
| `project-conventions` | Naming, file structure, organizational patterns | All repos |
| `game-feel-juice` | Hitlag, screen shake, feedback loops — engine-agnostic | All game repos |
| `canvas-2d-optimization` | Browser Canvas 2D performance patterns | ComeRosquillas |
| `combat-system-design` | Hit detection, damage, combos, frame data | Fighting and beat-em-up games |
| `procedural-audio-synthesis` | Web Audio API, procedural SFX generation | Games with procedural audio |
| `godot-patterns` | Godot 4 scene tree, signals, exports | Godot-based games |
| `balance-methodology` | Data-driven balance, A/B testing, target ranges | All game repos |
| `ui-ux-patterns` | Menu flow, HUD, accessibility, onboarding | All repos with UI |

#### Genre-Specific Skills (Hub-Owned, Project-Originated)

When a project develops genre-specific expertise, that knowledge is captured as a skill in the hub — not in the game repo. This ensures the knowledge persists even if the game repo is archived.

**Flow:**
```
Game Repo (learning)  →  Hub Skill (captured)  →  Future Game Repos (consumed)
     Flora                  pixijs-patterns          Future PixiJS projects
     Ashfall         fighting-game-frame-data        Future fighting games
     ComeRosquillas    arcade-game-patterns          Future arcade games
```

**Example:** During Ashfall development, the team learns critical patterns about frame data, input buffering, and rollback-friendly architecture. These are captured as skills in the hub:

```
FirstFrameStudios/.squad/skills/
  fighting-game-frame-data/SKILL.md
  rollback-architecture/SKILL.md
  input-buffering-patterns/SKILL.md
```

When a future fighting game starts, it inherits all of these skills automatically via `squad upstream`.

#### Local Knowledge (Downstream-Owned)

Game repos may have local documentation that isn't generalized enough to be a hub skill. These stay local:

- Architecture decision records specific to one game
- Implementation notes tied to a specific codebase
- Debugging logs and session-specific findings
- Game-specific configuration documentation

**Promotion Rule:** If a local document contains knowledge that would benefit future projects, it should be generalized and promoted to a hub skill. Solo (Lead) makes the call on whether knowledge is studio-worthy or project-specific.

### Skill Cascade Mechanics

When an agent works in a downstream repo, they have access to:

1. **All hub skills** — via the `squad upstream` relationship
2. **All local documentation** — in the downstream repo
3. **Their charter and history** — from the hub's agent definitions

Skills don't need to be copied into downstream repos. The upstream relationship makes them available. If a downstream repo needs a skill that doesn't exist in the hub, the agent requests it (T1 for new skills).

### Skill Lifecycle

| Phase | Action | Authority |
|-------|--------|-----------|
| **Creation** | Agent identifies a pattern worth documenting | T1 (Lead decides) for new hub skills |
| **Authoring** | Domain expert writes the skill document | T2 (assigned agent) |
| **Review** | Solo reviews for accuracy, scope, and hub-worthiness | T1 (Lead) |
| **Publication** | Skill committed to hub `.squad/skills/` | T1 (Lead decides) |
| **Consumption** | Downstream repos access via upstream | Automatic |
| **Update** | Domain expert updates based on new learnings | T2 for minor updates, T1 for structural changes |
| **Deprecation** | Skill marked as superseded or archived | T1 (Lead decides) |

---

## Domain 4: Ceremonies

### Philosophy

Ceremonies are structured team interactions that prevent drift, surface problems early, and maintain alignment across repos. In a multi-repo studio, some ceremonies are repo-local and some span the entire organization.

### Ceremony Types

#### Studio-Wide Ceremonies (Hub-Governed)

These ceremonies involve agents working across multiple repos and are defined in the hub.

##### 1. Cross-Repo Design Review

| Field | Value |
|-------|-------|
| **Trigger** | Any change that affects more than one repository |
| **Frequency** | As needed (T1 changes always trigger this) |
| **Facilitator** | Solo (Lead) |
| **Participants** | All agents affected by the cross-repo change |
| **Duration** | Focused (15–30 min equivalent) |
| **Output** | Decision record in hub `.squad/decisions/` |

**Agenda:**
1. Proposer presents the change and its cross-repo impact
2. Each affected repo's primary agent assesses local impact
3. Interface contracts and migration plan agreed
4. Risk assessment: what breaks if this goes wrong?
5. Approval path confirmed (T0 or T1)

**Example:** Solo proposes standardizing the heartbeat file format across all downstream repos. This triggers a Cross-Repo Design Review because it affects ffs-squad-monitor (consumer), and every game repo (producers).

##### 2. Studio Retrospective

| Field | Value |
|-------|-------|
| **Trigger** | Major milestone completion, project completion, or quarterly |
| **Frequency** | At least quarterly, plus after every major milestone |
| **Facilitator** | Mace (Producer) or Solo (Lead) |
| **Participants** | All active agents |
| **Duration** | Extended (45–60 min equivalent) |
| **Output** | Lessons logged in hub, action items assigned |

**Agenda:**
1. Each repo lead reports: What went well? What didn't? What surprised us?
2. Cross-repo patterns identified (are the same problems appearing in multiple repos?)
3. Hub infrastructure assessment: Are skills, quality gates, and governance serving us?
4. Action items assigned with owners and timelines
5. Principle scorecard: Rate each principle 1–5 for the period

**Example:** After Ashfall's Sprint 0 completes, a Studio Retrospective reviews what worked across all repos — did the hub's quality gates catch real issues? Did skill cascade work? Did the approval tiers cause bottlenecks or prevent problems?

##### 3. Skill Harvest

| Field | Value |
|-------|-------|
| **Trigger** | End of a development phase or project |
| **Frequency** | At every phase completion |
| **Facilitator** | Solo (Lead) |
| **Participants** | All agents who worked on the phase |
| **Duration** | Focused (20–30 min equivalent) |
| **Output** | New or updated skills in hub `.squad/skills/` |

**Agenda:**
1. Each agent reports: What did I learn that's worth keeping?
2. Solo triages: Is this a hub skill (generalizable) or local knowledge (project-specific)?
3. Hub skills assigned to domain experts for authoring
4. Existing skills updated with new learnings

##### 4. Hub Health Check

| Field | Value |
|-------|-------|
| **Trigger** | Quarterly or when a new downstream repo is created |
| **Frequency** | Quarterly minimum |
| **Facilitator** | Solo (Lead) + Jango (Tool Engineer) |
| **Participants** | Solo, Jango, Mace |
| **Duration** | Focused (15–20 min equivalent) |
| **Output** | Hub maintenance tasks logged as issues |

**Agenda:**
1. Are all upstream relationships healthy? (Each downstream repo can resolve hub references)
2. Are skills current? (Any skills that reference deprecated patterns or technologies)
3. Are quality gates producing value? (Are they catching real issues or just adding friction?)
4. Are approval tiers well-calibrated? (Too many bottlenecks at T1? Too many risky changes slipping through at T3?)
5. Is the decisions log up to date?

---

#### Repo-Local Ceremonies (Downstream-Governed)

These ceremonies happen within a single repo and are owned by that repo's team.

| Ceremony | Scope | Owner | Trigger |
|----------|-------|-------|---------|
| **Sprint Planning** | Per-game sprint backlog | Mace + game lead | Sprint start |
| **Design Review** (local) | Single-repo architecture or feature | Solo or domain lead | Multi-agent task within the repo |
| **Code Review** | Pre-merge review | Cross-reviewer (per quality gates) | Every PR |
| **Playtest Session** | Game feel and balance testing | Ackbar | Every milestone build |
| **Retrospective** (local) | Per-repo reflection | Mace | Sprint end, build failure, or rejection |

**Rule:** Repo-local ceremonies cannot contradict studio-wide ceremony decisions. If a Studio Retrospective produces an action item, repo-local sprint planning must accommodate it.

---

#### Mandatory Ceremonies

Certain ceremonies are **required** at specific project milestones, regardless of repo type or team composition.

| Milestone | Ceremony Required | Content |
|-----------|-------------------|---------|
| **Project START** | Kickoff Review | Team assignment, skills assessment, architecture plan, upstream relationship verification |
| **Project MIDPOINT** | Mid-Project Health Check | Skills assessment, team member evaluation, course correction, hub alignment check |
| **Project END** | Closeout & Harvest | Final team member evaluation, skill harvest, lessons learned, hub skill promotion |

**Skills Assessment:** At each mandatory ceremony, every active agent's skills are evaluated against the project's needs. Gaps are identified and addressed (training, reassignment, or skill creation).

**Team Member Evaluation:** Performance, collaboration quality, and growth trajectory are reviewed. Results inform future team composition decisions.

---

### Project Autonomy Model

Each project (game or tool) has **total freedom** to create its own tools, plugins, and MCP connections within its repository. This is T2 authority — no hub approval needed for project-scoped tooling.

**The Escalation Rule:** If a project-specific tool has **cross-repo application** (i.e., another project could benefit from it), the owning team must escalate to FFS hub level:

1. **Inherit from hub** — if the hub already has an equivalent, use it instead of building locally
2. **Create a new tool repo** — if no equivalent exists, propose a new tool repository (T1: Lead decides)

**Examples:**
- Flora creates a PixiJS debug overlay → stays local (T2, project-specific)
- Flora creates a multi-repo heartbeat monitor → escalate to FFS, create tool repo (T1)
- ComeRosquillas builds a custom sprite packer → stays local (T2)
- ComeRosquillas builds a CI/CD dashboard useful to all repos → escalate to FFS (T1)

---

## Domain 5: Project Lifecycle

### Philosophy

Every project — whether a game, a tool, or an internal system — has a lifecycle. The governance model must account for creation, active development, maintenance, hibernation, and archival. Each phase has different authority requirements and different relationships to the hub.

### Lifecycle Phases

```
  ┌─────────┐     ┌─────────┐     ┌─────────────┐     ┌───────────┐     ┌──────────┐
  │ Proposal │────▶│ Sprint 0│────▶│   Active     │────▶│Maintenance│────▶│ Archived │
  │  (T0)    │     │  (T1)   │     │Development   │     │           │     │  (T0)    │
  │          │     │         │     │  (T2/T1)     │     │  (T2/T3)  │     │          │
  └─────────┘     └─────────┘     └─────────────┘     └─────┬─────┘     └──────────┘
                                                             │
                                                             ▼
                                                       ┌───────────┐
                                                       │Hibernation│
                                                       │   (T1)    │
                                                       └───────────┘
```

#### Phase 1: Proposal (T0 — Founder-Only)

A new project begins with a proposal. Only the Founder can approve creating a new repository.

**Required Artifacts:**
- Project concept (genre, scope, platform, IP)
- Technology recommendation (from New Project Playbook's 9-dimension matrix)
- Team skill transfer audit (what existing skills apply? what's new?)
- Estimated team allocation (which agents, at what capacity?)
- Success criteria (what does "done" look like?)

**Process:**
1. Any agent can draft a project proposal
2. Solo (Lead) reviews for technical feasibility and team capacity
3. Yoda (Game Designer) reviews for creative viability and studio alignment
4. Joaquin (Founder) approves or rejects
5. If approved, Jango (Tool Engineer) scaffolds the repo with `squad upstream` to hub

#### Phase 2: Sprint 0 (T1 — Lead Authority)

Sprint 0 is the foundation-laying phase. All architectural and structural decisions are made here.

**Required Artifacts (before leaving Sprint 0):**
- Game Design Document (GDD) — owned by Yoda
- Architecture Document — owned by Solo
- Sprint Plan — owned by Mace
- `squad upstream` configured and verified
- Hub quality gates confirmed applicable (or local extensions documented)
- CI/CD pipeline configured
- GitHub Issues + Labels + Milestone created
- At least one playable build

**Authority:** T1 for all Sprint 0 decisions. Solo (Lead) decides. This is the most governance-heavy phase because mistakes here compound.

#### Phase 3: Active Development (T2 with T1 escalation)

The normal development phase. Agents work on features, fix bugs, and ship builds.

**Governance:**
- Day-to-day work is T2 (assigned agent authority)
- Cross-repo changes escalate to T1
- Sprint scope changes require Mace + Solo alignment
- Quality gates enforced on every merge

**Cadence:**
- Sprint planning at sprint start
- Playtest sessions at every milestone
- Skill harvest at phase boundaries
- Retrospective at sprint end

#### Phase 4: Maintenance (T2/T3)

A shipped game enters maintenance. Active feature development stops. Only bug fixes, balance patches, and minor polish remain.

**Governance:**
- Bug fixes are T2 (assigned agent)
- Documentation updates are T3 (any agent)
- No new features without T1 approval (re-entering Active Development)
- Reduced team allocation (agents focus on other active projects)

#### Phase 5a: Hibernation (T1)

A project that isn't actively maintained but might resume later. The repo stays intact but development pauses.

**Governance:**
- T1 to enter hibernation (Solo decides)
- Hub skills captured from the project before hibernation (Skill Harvest ceremony)
- Upstream relationship maintained (hub changes still cascade, but no one is working downstream)
- No active sprints, no active issues
- T1 to exit hibernation (requires re-assessment of team capacity and technology currency)

**Example:** ComeRosquillas enters hibernation after its arcade game is shipped and stable. The HTML/JS skills learned are captured in the hub. The repo stays on GitHub but no active development occurs. If the studio wants to build another HTML/JS arcade game later, they can reactivate it.

#### Phase 5b: Archival (T0 — Founder-Only)

A project is permanently archived. The repo becomes read-only.

**Governance:**
- T0 to archive (Founder-only, irreversible decision)
- All skills must be harvested to the hub before archival
- All decision records must be migrated to the hub
- Repo is archived on GitHub (read-only, visible but not editable)
- Upstream relationship is severed (hub no longer cascades to this repo)

**Process:**
1. Solo conducts a final Skill Harvest — every transferable lesson is captured
2. Scribe ensures all session history and decisions are preserved in the hub
3. Joaquin confirms archival
4. Jango archives the repo on GitHub
5. Hub references to the project are updated to note "Archived"

---

## Domain 6: Hub-Downstream Authority Model

### Philosophy

The hub exists to serve downstream repos, not to control them. The authority model is designed to maximize downstream autonomy while maintaining studio coherence. The hub controls *what* the studio believes and *how* it operates. Downstream repos control *what* they build and *how* they build it.

### Authority Matrix

| Domain | Hub Authority | Downstream Authority |
|--------|--------------|---------------------|
| **Studio identity** | Full (Zone A) | None — consume only |
| **Principles** | Full (Zone A) | None — consume only |
| **Quality gates** | Sets minimum bar (Zone B) | May extend, not weaken |
| **Skills** | Owns and publishes (Zone A) | Consumes; requests new skills via T1 |
| **Team definitions** | Full (Zone A) | None — consume only |
| **Ceremonies** | Defines studio-wide ceremonies (Zone B) | Defines local ceremonies; extends studio ones |
| **Game design** | None (Zone C) | Full — downstream owns GDD, creative vision |
| **Game architecture** | Solo reviews (T1 for Sprint 0) | Downstream owns after Sprint 0 approval |
| **Game code** | None (Zone C) | Full — downstream owns all implementation |
| **Technology stack** | Approves (T1 for new projects) | Downstream owns local tooling and config |
| **Sprint planning** | None (Zone C) | Full — downstream owns schedule and scope |
| **Release decisions** | None (Zone C) | Full — downstream decides when to ship |
| **CI/CD** | May provide shared workflows (Zone B) | Downstream configures and extends locally |
| **Issue tracking** | Defines label standards (Zone B) | Downstream manages own issues and boards |

### Hub Responsibilities

The hub must:
1. **Keep shared infrastructure current.** Skills, quality gates, and governance must evolve with the studio.
2. **Not become a bottleneck.** If T1 approvals are slowing down development, the tier calibration needs adjustment.
3. **Serve downstream needs.** If multiple downstream repos need the same thing, it should be in the hub.
4. **Maintain backward compatibility.** Hub changes should not break downstream repos. If a breaking change is necessary, it's a T1 decision with a migration plan.
5. **Stay lean.** The hub contains no game code, no assets, no builds. Only infrastructure.

### Downstream Responsibilities

Each downstream repo must:
1. **Maintain a valid upstream relationship.** The `squad upstream` to the hub must be configured and functional.
2. **Respect Zone A elements.** Studio identity, principles, approval tiers — these are not optional.
3. **Extend, not weaken, Zone B elements.** Local quality gates must be a superset of hub gates.
4. **Capture knowledge for the hub.** When a project learns something generalizable, propose it as a hub skill.
5. **Follow the approval tier system.** T0/T1 changes go through the hub process, not local workarounds.
6. **Report status.** Active projects maintain heartbeat data for the squad monitor.

### Conflict Resolution

When the hub and a downstream repo disagree:

1. **On Zone A matters:** Hub wins. No discussion.
2. **On Zone B matters:** Hub sets the floor; downstream can argue for a higher standard but cannot go below.
3. **On Zone C matters:** Downstream wins. Hub has no authority.
4. **On ambiguous matters:** Solo (Lead) makes the initial call. If disputed, Joaquin (Founder) decides.

---

## Domain 7: Configuration Inheritance

### Philosophy

Configuration inheritance determines what settings, standards, and definitions cascade from the hub to downstream repos and what stays local. The goal is to minimize redundancy (don't repeat quality gates in every repo) while maximizing local flexibility (don't force every repo into identical tooling).

### What Cascades (Inherited from Hub)

These elements are authoritative in the hub and apply to all downstream repos:

| Element | Hub Path | Inheritance Mode |
|---------|----------|-----------------|
| Studio principles | `.squad/identity/principles.md` | **Mandatory** — all repos follow these |
| Studio identity | `.squad/identity/company.md` | **Mandatory** — name, tagline, DNA are universal |
| Quality gate structure | `.squad/identity/quality-gates.md` | **Mandatory minimum** — repos extend, not weaken |
| Definition of Done | `.squad/identity/quality-gates.md` §2 | **Mandatory minimum** — repos add items, not remove |
| Bug severity matrix | `.squad/identity/quality-gates.md` §3 | **Mandatory** — severity definitions are universal |
| Governance (this doc) | `.squad/identity/governance.md` | **Mandatory** — authority model is universal |
| Team roster | `.squad/team.md` | **Mandatory** — one roster, one truth |
| Agent charters | `.squad/agents/*/charter.md` | **Mandatory** — agent roles don't change per repo |
| Studio-wide skills | `.squad/skills/*/SKILL.md` | **Available** — agents access as needed |
| Routing table | `.squad/routing.md` | **Default** — repos may add local routing rules |
| Ceremonies (studio-wide) | `.squad/ceremonies.md` | **Mandatory** — studio ceremonies apply everywhere |
| Growth framework | `.squad/identity/growth-framework.md` | **Mandatory** — evolution strategy is studio-level |
| New Project Playbook | `.squad/identity/new-project-playbook.md` | **Mandatory for new projects** — followed at creation |
| Mission and vision | `.squad/identity/mission-vision.md` | **Mandatory** — strategic direction is universal |

### What Stays Local (Not Inherited)

These elements are owned by each downstream repo and are not controlled by the hub:

| Element | Example Path | Rationale |
|---------|-------------|-----------|
| Game code | `src/`, `scripts/`, `scenes/` | Implementation is project-specific |
| Game design docs | `docs/GDD.md` | Creative vision is per-project |
| Architecture docs | `docs/ARCHITECTURE.md` | Technical architecture varies |
| Build configuration | `vite.config.ts`, `project.godot`, `tsconfig.json` | Tooling varies per stack |
| Package management | `package.json`, `package-lock.json` | Dependencies are per-project |
| CI/CD workflows | `.github/workflows/*.yml` | Build/test/deploy is per-project |
| Local README | `README.md` | Describes the specific project |
| Local CONTRIBUTING | `CONTRIBUTING.md` | May extend hub conventions |
| Game assets | `assets/`, `sprites/`, `audio/` | All assets are project-specific |
| Sprint backlog | GitHub Issues + Project Board | Sprint scope is per-project |
| Release artifacts | Build outputs, deployment configs | Deployment is per-project |
| Local ceremonies | Per-project ceremonies beyond studio ones | Additional ceremonies are fine |
| Game-specific labels | Beyond `game:*`, `squad:*`, `priority:*`, `type:*` | Local labels supplement the standard set |

### Inheritance Conflict Resolution

If a downstream repo contains a file that contradicts hub inheritance:

1. **Mandatory elements:** Hub wins. Downstream file should be removed or updated.
2. **Mandatory minimum elements:** Downstream must meet or exceed hub standard. Anything below is non-compliant.
3. **Available elements:** No conflict possible — skills are consumed on demand, not enforced.
4. **Default elements:** Downstream's local version takes precedence, but must include hub defaults as a subset.

### Configuration Sync Process

When the hub updates a cascading configuration:

1. Solo (Lead) makes the hub change (T1 process)
2. Solo identifies which downstream repos are affected
3. Affected repo leads are notified
4. Each downstream repo updates their local extensions if needed
5. Jango (Tool Engineer) verifies upstream relationships are healthy

**Example — Hub updates quality gates:**
```
Hub change: Add new Integration Quality Gate requirement I7 (accessibility check)

Downstream impact:
  - ComeRosquillas: Needs to add accessibility testing to their CI
  - Flora: Already has accessibility testing; just update documentation reference
  - ffs-squad-monitor: Dashboard tool — accessibility gate applies to UI components
```

---

## Domain 8: Issue Routing

### Philosophy

Issues are the atoms of work. In a multi-repo studio, knowing where an issue belongs — which repo, which agent, which priority — is critical for velocity. The routing system must handle issues that originate in one repo but affect another, issues that span repos, and issues that belong to the hub itself.

### Issue Origin and Destination

#### Single-Repo Issues (Most Common)

Issues that originate and resolve within a single repo.

**Flow:**
```
Issue created in Flora → Labeled `squad` → Lead triages → Labeled `squad:lando` → Lando works it
```

**Process:**
1. Issue is created in the downstream repo (by any agent, user, or automated process)
2. Issue gets the `squad` label (marks it as "awaiting triage")
3. Solo (Lead) triages: reviews content, assigns priority (`priority:p0/p1/p2`), assigns agent (`squad:{agent}`), assigns type (`type:{category}`)
4. Assigned agent picks up the issue in their next session
5. Agent works the issue, references it in commits (`fixes #N`)
6. Issue closed when DoD is met

#### Cross-Repo Issues

Issues that originate in one repo but require changes in another (or multiple) repos.

**Flow:**
```
Bug reported in Flora → Root cause is in hub quality gates → Issue migrated to hub → T1 process
```

**Process:**
1. Issue is created in the originating repo
2. During triage, Solo identifies cross-repo impact
3. If the fix is in a different repo, Solo creates a linked issue in the target repo
4. Original issue references the target issue: "Depends on FirstFrameStudios#42"
5. If the fix requires hub changes, it follows the T1 approval process
6. Both issues are closed when the fix is verified end-to-end

**Examples:**

| Scenario | Origin | Target | Tier |
|----------|--------|--------|------|
| Bug in Flora caused by outdated skill reference | Flora | Hub (update skill) | T1 |
| Feature in ffs-squad-monitor needs new heartbeat field | Monitor | All downstream repos (emit new field) | T1 |
| Bug in ComeRosquillas game code | ComeRosquillas | ComeRosquillas | T2 |
| Typo in hub principles noticed during Flora work | Flora | Hub (fix typo) | T3 |
| New game repo request | Any | Hub (create repo) | T0 |

#### Hub Issues

Issues that affect the hub itself — infrastructure, governance, skills, identity.

**Flow:**
```
Issue created in hub → Classified by domain → Tier assigned → Process followed
```

| Hub Issue Type | Tier | Example |
|---------------|------|---------|
| New skill proposal | T1 | "Create `fighting-game-frame-data` skill from Ashfall learnings" |
| Quality gate update | T1 | "Add accessibility requirement to Integration gate" |
| Governance update (not modifying T0 scope) | T1 | "Add new approval tier for automated changes" |
| Governance update (modifying T0 scope) | T0 | "Change what decisions require Founder approval" |
| Team roster change (hub) | T1 | "Add new agent: Padme (Narrative Designer)" |
| Documentation fix | T3 | "Fix broken link in principles.md" |
| Skill update | T2 | "Update `state-machine-patterns` with Godot 4 examples" |
| Ceremony change | T1 | "Add monthly cross-repo sync ceremony" |

### Issue Labels (Studio Standard)

All repos use this base label set. Repos may add local labels but must include these:

| Category | Labels | Color | Usage |
|----------|--------|-------|-------|
| **Game** | `game:{name}` | Green (#0E8A16) | Filter by game in monorepo or multi-repo |
| **Priority** | `priority:p0`, `priority:p1`, `priority:p2` | Red/Orange/Yellow | P0 = critical path, P1 = sprint, P2 = backlog |
| **Type** | `type:feature`, `type:bug`, `type:infrastructure`, `type:art`, `type:audio`, `type:design`, `type:qa`, `type:docs` | Blue/Purple/Pink | Work category |
| **Squad** | `squad:{agent}` | Teal (#006B75) | Agent assignment |
| **Status** | `status:blocked`, `status:in-review`, `status:needs-info` | Gray tones | Workflow state (optional) |
| **Cross-repo** | `cross-repo` | Red (#B60205) | Flags issues that affect multiple repos |

### Escalation Path

When an agent is unsure where an issue belongs:

```
Agent unsure → Tag with `squad` (awaiting triage)
    → Solo (Lead) triages
        → Single repo? → Assign to repo + agent (T2)
        → Cross-repo? → Create linked issues + T1 process
        → Hub issue? → Create in hub + assign tier
        → Unclear? → Solo makes judgment call, documents rationale
```

---

## Domain 9: Decision Authority

### Philosophy

Clear decision authority prevents two failure modes: **paralysis** (nobody knows who can decide, so nothing happens) and **overreach** (someone makes a decision they don't have authority for, causing downstream problems). Every decision in the studio has exactly one authority — there is always one person who makes the final call.

### Decision Authority Matrix

| Decision Category | Primary Authority | Approval Required | Tier |
|-------------------|------------------|-------------------|------|
| **New game repository** | Joaquin (Founder) | — | T0 |
| **Principle changes** (`principles.md`) | Joaquin (Founder) | Solo recommends | T0 |
| **Repository archival** | Joaquin (Founder) | — | T0 |
| **Changes to T0 scope itself** | Joaquin (Founder) | Solo recommends | T0 |
| **Cross-repo architecture** | Solo (Lead) | — (Lead authority) | T1 |
| **Quality gate changes** | Solo (Lead) | — (Lead authority) | T1 |
| **New studio skill** | Solo (Lead) | — (Lead authority) | T1 |
| **Ceremony changes** | Solo (Lead) | — (Lead authority) | T1 |
| **Playbook changes** | Solo (Lead) | — (Lead authority) | T1 |
| **Hub roster changes** | Solo (Lead) | — (Lead authority) | T1 |
| **Governance changes** (not T0 scope) | Solo (Lead) | — (Lead authority) | T1 |
| **Technology stack** (new projects) | Solo (Lead) | — (Lead authority) | T1 |
| **Tool repo creation** | Solo (Lead) | — (Lead authority) | T1 |
| **`.squad/` infrastructure refactors** | Solo (Lead) | — (Lead authority) | T1 |
| **Sprint scope** (per-project) | Mace (Producer) | Solo aligns | T1 |
| **Mission/vision changes** | Joaquin (Founder) | Yoda advises | T0 |
| **Studio identity** (name, tagline, DNA) | Joaquin (Founder) | — | T0 |
| **Game creative vision** | Yoda (Game Designer) | — (Zone C) | T2 |
| **Game architecture** (post-Sprint 0) | Solo (Lead) | — (Zone C) | T2 |
| **Art direction** (per-project) | Boba (Art Director) | Yoda aligns | T2 |
| **Audio direction** (per-project) | Greedo (Audio Designer) | Yoda aligns | T2 |
| **Feature implementation** | Assigned agent | Cross-review | T2 |
| **Bug fixes** | Assigned agent | Cross-review | T2 |
| **Enemy/content design** | Tarkin (Content Dev) | Yoda aligns | T2 |
| **QA methodology** | Ackbar (QA Lead) | Solo reviews | T2 |
| **UI/UX design** | Wedge (UI/UX Dev) | Yoda aligns | T2 |
| **Tooling** | Jango (Tool Engineer) | Solo reviews | T2 |
| **Production scheduling** | Mace (Producer) | Solo aligns | T2 |
| **Session logging** | Scribe | — (automatic) | T2 |
| **Documentation typo fixes** | Any agent | Any reviewer | T3 |
| **Formatting corrections** | Any agent | Any reviewer | T3 |
| **Comment additions** | Any agent | Any reviewer | T3 |

### The "One Voice" Principle

For any given domain, there is exactly one voice that makes the final call:

| Domain | One Voice | Backup |
|--------|-----------|--------|
| Architecture | Solo | Chewie (for engine-specific) |
| Game Design | Yoda | Joaquin (for vision disputes) |
| Art Direction | Boba | Yoda (for aesthetic coherence) |
| Audio | Greedo | Yoda (for aesthetic coherence) |
| Code Quality | Solo | Ackbar (for testing methodology) |
| Production | Mace | Solo (for priority conflicts) |
| Studio Direction | Joaquin | — (no backup; Founder is final) |

### Decision Records

Every T0 and T1 decision must be recorded in the hub's `.squad/decisions.md` with:

1. **Author** — who proposed the decision
2. **Date** — when the decision was made
3. **Status** — Proposed / Active / Implemented / Superseded
4. **Scope** — which repos and agents are affected
5. **What was decided** — clear, actionable description
6. **Why** — rationale that explains the reasoning
7. **Impact** — who needs to change what

T2 decisions are recorded in the agent's `history.md` and in commit messages. T3 decisions need no explicit record beyond the commit.

### Delegation Rules

| Rule | Description |
|------|-------------|
| **Founder can delegate T0** | Joaquin may grant Solo temporary T0 authority for specific decisions (documented in writing) |
| **T1 is fully delegated to Lead** | T1 authority is permanently delegated to Solo (Lead) — no founder approval required for any T1 decision |
| **Lead can delegate T1** | Solo may designate a domain expert as T1 authority for their domain (e.g., Yoda for principle-adjacent changes) |
| **T2 cannot be delegated** | The assigned agent must do the work; they can seek help but not hand off ownership |
| **T3 is inherently distributed** | Anyone can do T3 work; no delegation needed |

### Emergency Authority

In time-critical situations (production outage, critical bug in a shipped game, security vulnerability):

1. **Any agent** may make an emergency fix without normal approval
2. The fix must be the **minimum viable change** — no feature work under emergency cover
3. **Within 24 hours**, the emergency change must be retroactively reviewed at the appropriate tier
4. The emergency and its handling are logged as a learning in the next retrospective

**Example:** A critical bug is discovered in ComeRosquillas that crashes the game on load. Any agent with access can push an emergency fix. Within 24 hours, Solo reviews the fix, confirms it's minimal and correct, and logs the incident.

---

## Appendix A: Quick Reference Card

### Tier Cheat Sheet

| Tier | Who Decides | Examples (3-word summary) |
|------|-------------|--------------------------|
| **T0** | Founder only | New game, principles |
| **T1** | Lead (Solo) | Tool repos, cross-repo, quality gates, hub roster, .squad refactors, governance |
| **T2** | Assigned agent | Feature work, bug fix, game roster, project tools |
| **T3** | Any agent | Typo fix, formatting, comment addition |

### Zone Cheat Sheet

| Zone | Control | Rule |
|------|---------|------|
| **A** | Hub-controlled | No override — consume only |
| **B** | Hub-default | Extend, don't weaken |
| **C** | Locally-owned | Downstream decides |

### Escalation Cheat Sheet

| If you're unsure about... | Ask... |
|---------------------------|--------|
| Which tier applies | Solo (Lead) |
| Which repo owns an issue | Solo (Lead) |
| Whether a change needs Founder approval | Solo (Lead) |
| Whether a local change affects other repos | Solo (Lead) |
| Creative direction disputes | Yoda (Game Designer) |
| Production scheduling conflicts | Mace (Producer) |
| Anything about the studio's future direction | Joaquin (Founder) |

---

## Appendix B: Governance Evolution

This document is itself governed by the tier system:

- **Changes that modify T0 scope** (what requires Founder approval): **T0** — Founder-only
- **Structural changes** (new domains, new tiers, new authority levels that don't modify T0 scope): **T1** — Lead (Solo) authority
- **Content updates** (clarifying existing rules, adding examples, updating repo list): **T1** — Lead (Solo) authority
- **Formatting and typo fixes**: **T3** — Any agent

The governance document is reviewed during every Hub Health Check ceremony (quarterly minimum). Changes are proposed via the standard decision process.

### Version History

| Date | Change | Tier | Author |
|------|--------|------|--------|
| 2025 | Initial creation — 9 domains of multi-repo governance | T0 | Solo (Lead / Chief Architect) |
| 2026-03-11 | Founder vision applied — T0 minimized, repo creation tiers, mandatory ceremonies, project autonomy model, hub philosophy | T0 | Solo (Lead / Chief Architect), per Founder directives |
| 2026-07-25 | T0 ultra-minimized (only new games + principles.md). T1 becomes Lead-only authority — founder removed from T1 approvals. Hub roster changes, .squad/ refactors, governance changes moved to T1. Delegation rules updated. | T0 | Solo (Lead / Chief Architect), per Founder directives |

---

*This document is the constitutional layer of First Frame Studios. It doesn't tell us what to build — it tells us how to decide, who decides, and how decisions flow across our multi-repo ecosystem. Every repo, every agent, every sprint operates within this framework.*

*When in doubt, read the principles. When the principles conflict, Player Hands First wins. When authority is unclear, ask Solo. When Solo is unsure, ask Joaquin.*

*— Solo, Lead / Chief Architect, First Frame Studios*
