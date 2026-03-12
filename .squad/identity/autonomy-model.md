# Autonomy Model — First Frame Studios

> **Reference document.** Governance authority lives in `governance.md`.
> This doc explains **HOW** the autonomy zones, inheritance, and responsibilities work.
> For tier definitions and zone summaries, see `governance.md` §2–3.

---

## Zone A — Hub-Controlled (No Local Override)

| Element | Hub File | Why Hub-Controlled |
|---------|----------|--------------------|
| Studio identity | `identity/company.md` | One name, one tagline, one DNA — everywhere |
| Leadership principles | `identity/principles.md` | Decision-making framework must be consistent across all projects |
| Approval tiers (T0–T3) | `identity/governance.md` | Authority model cannot vary per repo |
| Team roster & charters | `team.md`, `agents/*/charter.md` | One source of truth for who does what |
| Bug severity definitions | `identity/quality-gates.md` §3 | CRITICAL/HIGH/MEDIUM/LOW/COSMETIC mean the same thing everywhere |
| Decision authority model | `identity/governance.md` §4 | Who approves what cannot be ambiguous |
| Mission and vision | `identity/mission-vision.md` | Strategic direction is studio-level |

**Enforcement:** Hub version is authoritative. Downstream contradictions must be removed or corrected.

---

## Zone B — Hub-Defaults with Local Extension

| Element | Hub Default | Local Extension Allowed |
|---------|-------------|------------------------|
| Quality gates | Code, Art, Audio, Design, Integration gates | Add game-specific gates (e.g., frame data validation) |
| Definition of Done | 8-item checklist (`quality-gates.md` §2) | Add items, never remove |
| Ceremonies | Studio-wide ceremonies | Add project-specific ceremonies |
| Routing table | `routing.md` assignments | Add project-specific routing rules |
| Commit conventions | `CONTRIBUTING.md` format | Add project-specific scopes |
| CI/CD workflows | Hub-level workflows | Add game-specific pipelines |
| Label system | `game:*`, `squad:*`, `priority:*`, `type:*` | Add game-specific labels |

**Rule of Extension:** Local config must be a **superset** of hub defaults, never a subset. If the hub requires cross-review before merge, a game repo cannot waive that — but can require *additional* reviewers.

**Example — Flora TypeScript strict gate:**
```
## Additional: TypeScript Strict Mode Gate (extends hub defaults)
| # | Requirement |
|---|-------------|
| TS1 | Zero TypeScript errors with strict: true — no any casts without justification |
| TS2 | All public functions have JSDoc |
```

---

## Zone C — Locally Owned

| Element | Rationale |
|---------|-----------|
| Game code & architecture | Each game has its own codebase and implementation |
| Game design documents (GDD) | Creative vision is per-project |
| Game-specific assets | Art, audio, levels — all project-specific |
| Technology stack & build config | Each game can use a different engine/framework |
| Sprint planning & backlog | Sprints are per-project with per-project velocity |
| Release schedule & deployment | Each game ships on its own timeline |
| Local documentation (README, CHANGELOG) | Describes the specific project |
| Project-specific tools, plugins, MCP | Total freedom within project scope |
| Branch strategy | `main` vs `master`, release branches — local decision |

**Boundary:** The moment a local decision affects another repo (shared library, cross-repo skill, hub dashboard change), it crosses from Zone C to Zone B or T1 authority.

---

## Configuration Inheritance

### What Cascades

| Element | Hub Path | Inheritance Mode |
|---------|----------|------------------|
| Principles | `.squad/identity/principles.md` | **Mandatory** |
| Studio identity | `.squad/identity/company.md` | **Mandatory** |
| Quality gate structure | `.squad/identity/quality-gates.md` | **Mandatory minimum** — extend only |
| Definition of Done | `.squad/identity/quality-gates.md` §2 | **Mandatory minimum** — add items only |
| Bug severity matrix | `.squad/identity/quality-gates.md` §3 | **Mandatory** |
| Governance | `.squad/identity/governance.md` | **Mandatory** |
| Team roster | `.squad/team.md` | **Mandatory** |
| Agent charters | `.squad/agents/*/charter.md` | **Mandatory** |
| Studio-wide skills | `.squad/skills/*/SKILL.md` | **Available** — consumed on demand |
| Routing table | `.squad/routing.md` | **Default** — repos add local rules |
| Ceremonies | `.squad/ceremonies.md` | **Mandatory** |

### What Stays Local

| Element | Examples |
|---------|----------|
| Game code | `src/`, `scripts/`, `scenes/` |
| Game design docs | `docs/GDD.md` |
| Build configuration | `vite.config.ts`, `project.godot`, `tsconfig.json` |
| Package management | `package.json`, `package-lock.json` |
| CI/CD workflows | `.github/workflows/*.yml` |
| Game assets | `assets/`, `sprites/`, `audio/` |
| Sprint backlog | GitHub Issues + Project Board |
| Release artifacts | Build outputs, deployment configs |

### Inheritance Conflict Resolution

| Conflict Type | Resolution |
|---------------|------------|
| **Mandatory** element | Hub wins. Downstream file removed or updated. |
| **Mandatory minimum** element | Downstream must meet or exceed hub standard. Below = non-compliant. |
| **Available** element | No conflict possible — skills consumed on demand, not enforced. |
| **Default** element | Downstream's local version takes precedence but must include hub defaults as subset. |

---

## Hub Responsibilities

1. **Keep shared infrastructure current.** Skills, quality gates, governance must evolve with the studio.
2. **Don't become a bottleneck.** If T1 approvals slow development, tier calibration needs adjustment.
3. **Serve downstream needs.** If multiple repos need the same thing, it belongs in the hub.
4. **Maintain backward compatibility.** Hub changes must not break downstream. Breaking changes require T1 + migration plan.
5. **Stay lean.** No game code, no assets, no builds. Only infrastructure.

## Downstream Responsibilities

1. **Maintain valid upstream relationship.** `squad upstream` to hub must be configured and functional.
2. **Respect Zone A elements.** Identity, principles, tiers — not optional.
3. **Extend, not weaken, Zone B elements.** Local gates must be a superset of hub gates.
4. **Capture knowledge for the hub.** Generalizable lessons → propose as hub skill.
5. **Follow the approval tier system.** T0/T1 changes go through hub process, not local workarounds.
6. **Report status.** Active projects maintain heartbeat data for squad monitor.

---

## Conflict Resolution

| Situation | Resolution |
|-----------|------------|
| Zone A disagreement | Hub wins. No discussion. |
| Zone B disagreement | Hub sets the floor; project can exceed but not go below. |
| Zone C disagreement | Project wins. Hub has no authority. |
| Ambiguous zone | Solo (Lead) makes the call. If disputed → Founder decides. |

---

## Autonomy by Repository

| Repository | Autonomy Profile | Notes |
|------------|------------------|-------|
| **FirstFrameStudios** (Hub) | N/A — IS the authority | All Zone A and Zone B defaults originate here |
| **ComeRosquillas** | High autonomy | Mature HTML/JS game; follows hub principles, minimal hub infra integration |
| **Flora** | Standard autonomy | Vite+TS+PixiJS stack; uses hub skills and quality gates with local TS extensions |
| **ffs-squad-monitor** | Low autonomy (tool) | Studio infrastructure tool; closely coupled to hub data formats and team defs |
