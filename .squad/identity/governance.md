# Governance — First Frame Studios

> **Version:** 2.0
> **Author:** Solo (Lead / Chief Architect)
> **Status:** Active — Approved by Founder 2026-03-12

---

## Quick Reference

### Tier Cheat Sheet

| Tier | Who Decides | What (summary) |
|------|-------------|-----------------|
| **T0** | Founder only | New game repos, `principles.md`, critical `.squad/` structural changes |
| **T1** | Lead (Solo) | Hub roster, tool repos, cross-repo architecture, quality gates, ceremonies, governance, `.squad/` content refactors |
| **T2** | Assigned agent | Feature work, bug fixes, game roster, project-scoped tools |
| **T3** | Any agent | Typos, formatting, comments |

### Zone Cheat Sheet

| Zone | Control | Rule |
|------|---------|------|
| **A** | Hub-controlled | No override — consume only |
| **B** | Hub-default | Extend, don't weaken |
| **C** | Locally owned | Project decides |

### Escalation Cheat Sheet

| Unsure about… | Ask… |
|----------------|------|
| Which tier applies | Solo (Lead) |
| Which repo owns an issue | Solo (Lead) |
| Whether Founder approval is needed | Solo (Lead) |
| Creative direction disputes | Yoda (Game Designer) |
| Production scheduling conflicts | Mace (Producer) |
| Studio strategic direction | Joaquín (Founder) |

---

## 1. Philosophy

FFS is 99% autonomous. The Founder decides **what games** to make, not how. The hub is the Bible — it contains no game code, only identity, principles, skills, quality gates, and governance. Every project inherits and respects FFS but has creative freedom.

Each game breathes FFS values. Each game owns its soul.

---

## 2. Approval Tiers

### T0 — Founder Only

Irreversible or paradigm-shifting decisions. **Exhaustive list — if it's not here, it's not T0:**

| T0 Action | Why |
|-----------|-----|
| Creating a new **game** repository | Founder's capricho — decides studio direction |
| Modifying `principles.md` | Foundational beliefs that shape all downstream decisions |
| Modifying `routing.md` tier definitions | Structural: changes who can approve what |
| Modifying `config.json` schema | Structural: breaks squad tooling if wrong |
| Changing decisions pipeline structure (`.squad/decisions/` workflow) | Structural: alters how decisions are proposed/approved |
| Changing agent folder naming conventions (`.squad/agents/` structure) | Structural: breaks agent discovery and charter loading |
| Changes to T0 scope itself | Meta: only Founder can change what requires Founder approval |

**Process:** Proposal → Solo reviews feasibility → Founder approves/rejects → Implementation → Logged in `decisions.md`.

**Veto:** Only the Founder can veto T0. No combination of agents can override.

### T1 — Lead Authority (Solo decides, NO Founder approval)

Significant, reversible decisions affecting multiple repos or studio-wide standards. T1 is **fully and permanently delegated** to the Lead.

| T1 Action | Notes |
|-----------|-------|
| Creating tool/utility repos | Infrastructure, not strategic direction |
| Hub roster changes (adding/removing hub agents) | Hub team composition |
| Cross-repo architecture decisions | Shared patterns, interfaces, contracts |
| Quality gate changes (`quality-gates.md`) | Studio-wide standards |
| Ceremony changes (`ceremonies.md`) | Studio-wide coordination |
| Skills: creation, publication, deprecation | Studio knowledge management |
| Governance changes (not modifying T0 scope) | Structural and content updates to this document |
| `.squad/` content refactors (reorganize folders, archive logs, consolidate files) | Housekeeping — no structural risk |
| Squad config changes (`squad.config.ts`) | Tooling configuration |
| New Project Playbook changes | Lifecycle standards |
| Sprint scope changes (cross-project) | With Mace alignment |
| Technology stack decisions for new projects | Technical direction |
| Upstream relationship model changes | Hub-downstream configuration |
| Cross-repo CI/CD pipelines | Shared infrastructure |

**Process:** Solo drafts → Affected agents consulted → Solo decides and documents → Implementation → Logged in `decisions.md`.

**Escalation:** Agents escalate to Solo (Lead). Solo is the ceiling for T1. Only Solo escalates to Founder, and only for T0 matters. No agent may bypass the Lead.

### T2 — Assigned Agent

Normal project-scoped work within charter boundaries. No hub approval needed.

| T2 Action | Notes |
|-----------|-------|
| Feature implementation, bug fixes | Sprint backlog work |
| Game-specific content and assets | Creative work within GDD |
| Game repo roster changes (adding/removing project agents) | Project-scoped, doesn't affect hub |
| Project-specific tools, plugins, MCP connections | Total freedom within the project |
| Forking/cloning existing tools for project use | Low-risk exploration |
| Local config, CI/CD, documentation | Project-owned files |
| Game-specific quality gates (stricter than hub) | Extend, don't weaken |

**Boundaries:** Cannot modify hub files. Cannot change cross-repo contracts. Must follow studio quality gates. Escalate to T1 if cross-repo impact discovered.

### T3 — Any Agent

Cosmetic improvements only. Zero risk of breaking anything.

Typos, formatting, comments, broken links, missing annotations, `.gitignore` entries.

**Boundaries:** No code logic. No config values. No new files. No `.squad/identity/` files. When in doubt → T2.

### Tier Decision Matrix

Use top-to-bottom. First "Yes" wins.

| Question | If Yes → |
|----------|----------|
| Does this create a new **game** repository? | T0 |
| Does this modify `principles.md`? | T0 |
| Does this change `routing.md` tier definitions, `config.json` schema, decisions pipeline structure, or agent folder naming conventions? | T0 |
| Does this change T0 scope itself? | T0 |
| Does this create a new **tool/utility** repository? | T1 |
| Does this affect multiple repositories? | T1 |
| Does this change studio-wide standards (quality gates, skills, ceremonies)? | T1 |
| Does this add/remove an agent from the **hub** roster? | T1 |
| Does this refactor `.squad/` content (folders, logs, files)? | T1 |
| Does this change governance (without modifying T0 scope)? | T1 |
| Does this add/remove an agent from a **game repo** roster? | T2 |
| Does this create project-specific tools, plugins, or MCP connections? | T2 |
| Does this involve implementing a feature, fixing a bug, or creating content? | T2 |
| Does this change any code logic or configuration? | T2 |
| Is this purely cosmetic (typo, formatting, comment)? | T3 |
| None of the above? | Ask Solo |

**Conflict rule:** When a change spans multiple tiers, the **highest tier wins**.

### Repo Creation Tiers

| Repo Type | Tier | Who Decides |
|-----------|------|-------------|
| **Game repo** | T0 | Founder only — changes studio direction |
| **Tool/utility repo** | T1 | Lead (Solo) — infrastructure decision |
| **Fork/experimental repo** | T2 | Assigned agent — low-risk exploration |

### Delegation Rules

| Rule | Detail |
|------|--------|
| Founder can delegate T0 | Temporary, documented in writing, for specific decisions only |
| T1 is fully delegated to Lead | Permanent. No Founder approval for any T1 decision |
| Lead can delegate T1 | May designate domain expert as T1 authority for their domain |
| T2 cannot be delegated | Assigned agent owns the work; can seek help but not hand off |
| T3 is distributed | Anyone can do T3 work |

---

## 2.5. Execution Priority

Approval Tiers (§2) determine **who decides**. Execution Priority determines **when work runs**. These are independent axes.

### Priority Levels

| Priority | Name | Definition | Execution Rule |
|----------|------|------------|----------------|
| **P0** | Blocker | Nothing else advances until this is resolved. System-wide halt. | Ralph processes FIRST. Holds all other assignments until P0 is resolved or transitioned. |
| **P1** | Sprint-Critical | Must complete in current sprint. Directly blocks sprint goals. | Ralph processes after P0, before P2. Parallel execution allowed. |
| **P2** | Normal Backlog | Standard work queue. Important but not time-sensitive. | Ralph processes in FIFO order. **Default priority if none assigned.** |
| **P3** | Nice-to-Have | Low-impact improvements. Process when capacity available. | Ralph processes last. May be deferred indefinitely. |

### Tier ≠ Priority

| Example | Tier | Priority | Explanation |
|---------|------|----------|-------------|
| Create new game repo | T0 | P2 | Founder approval required (T0), but scheduled for Q2 (P2). High authority, low urgency. |
| Production bug in game | T2 | P0 | Agent has authority (T2), but it's a blocker (P0). Low authority, high urgency. |
| Governance v2 design | T1 | P0 | Solo decides (T1), but 3 agents are blocked waiting (P0). Medium authority, high urgency. |

### Priority Assignment

The **Lead** (Solo) assigns priority during triage. Default: P2 if none assigned.

**Decision tree:**

1. Does this block production or prevent all progress? → **P0**
2. Is this a sprint commitment or critical for current milestone? → **P1**
3. Is this low-impact polish or future work? → **P3**
4. Otherwise → **P2** (default)

### Dependencies and Blocked Work

Issues may be blocked by decisions, other issues, PRs, or upstream work. Blocked issues are labeled with `blocked-by:*` (see routing.md for dependency model).

**Prepare-but-don't-merge rule:** When an issue is blocked, the assigned agent may:

✅ **Allowed (Prepare):**
- Write tests (TDD approach)
- Scaffold code structure (empty functions, interfaces)
- Write spike code to explore problem space
- Open Draft PR with `[WIP]` prefix

❌ **Forbidden (until blocker resolved):**
- Mark PR as Ready for review
- Merge to main
- Close the issue

### Priority and Emergency Authority

Emergency Authority (§4) overrides Priority. A production outage triggers Emergency Authority (immediate fix, retroactive review), not P0 (which would wait for next Ralph cycle). After emergency fix merges, follow-up work is automatically labeled P1 (sprint-critical). Lead may escalate to P0 if truly blocking.

**Rule:** Emergency Authority is for active production crises requiring immediate action. P0 is for blocking work that prevents the team from making progress. They rarely overlap.

---

## 3. Autonomy Zones

### Zone A — Hub-Controlled (No Override)

| Element | Hub File |
|---------|----------|
| Studio identity (name, tagline, DNA) | `identity/company.md` |
| Leadership principles | `identity/principles.md` |
| Approval tiers (this document) | `identity/governance.md` |
| Team roster & charters | `team.md`, `agents/*/charter.md` |
| Bug severity definitions | `identity/quality-gates.md` §3 |
| Decision authority model | This document §4 |
| Mission and vision | `identity/mission-vision.md` |

**Enforcement:** Hub version is authoritative. Downstream contradictions must be removed or corrected.

### Zone B — Hub-Default with Local Extension

| Element | Local Extension Allowed |
|---------|------------------------|
| Quality gates & Definition of Done | Add stricter gates; cannot weaken |
| Ceremonies | Add project-specific ceremonies |
| Routing table | Add local routing rules |
| Commit conventions | Add project-specific scopes |
| CI/CD workflows | Add game-specific pipelines |
| Label system | Add game-specific labels |

**Rule of Extension:** Local config must be a **superset** of hub defaults, never a subset.

### Zone C — Locally Owned

| Element | Owner |
|---------|-------|
| Game code, architecture, GDD | Project repo |
| Game-specific assets (art, audio, levels) | Project repo |
| Technology stack & build config | Project repo |
| Sprint planning & backlog | Project repo |
| Release schedule & deployment | Project repo |
| Local documentation (README, CHANGELOG) | Project repo |
| Project-specific tools, plugins, MCP | Project repo |

### Conflict Resolution

| Situation | Resolution |
|-----------|------------|
| Zone A disagreement | Hub wins. No discussion. |
| Zone B disagreement | Hub sets the floor; project can exceed but not go below. |
| Zone C disagreement | Project wins. Hub has no authority. |
| Ambiguous zone | Solo (Lead) makes the call. If disputed → Founder decides. |

**Project autonomy:** Total freedom for tools/plugins/MCP within project scope. If a tool has cross-repo value → escalate: inherit from hub or create a new tool repo (T1).

---

## 4. Decision Authority

### Decision Authority Matrix

| Decision | Authority | Tier |
|----------|-----------|------|
| New game repository | Founder | T0 |
| `principles.md` changes | Founder | T0 |
| Critical `.squad/` structural changes (see §2 T0 list) | Founder | T0 |
| T0 scope changes | Founder | T0 |
| Cross-repo architecture | Solo (Lead) | T1 |
| Quality gate changes | Solo (Lead) | T1 |
| New/deprecated studio skills | Solo (Lead) | T1 |
| Ceremony changes | Solo (Lead) | T1 |
| Hub roster changes | Solo (Lead) | T1 |
| Tool repo creation | Solo (Lead) | T1 |
| Governance changes (not T0 scope) | Solo (Lead) | T1 |
| `.squad/` content refactors | Solo (Lead) | T1 |
| Technology stack (new projects) | Solo (Lead) | T1 |
| Sprint scope (cross-project) | Mace + Solo alignment | T1 |
| Game creative vision | Yoda (Game Designer) | T2 |
| Feature implementation | Assigned agent | T2 |
| Bug fixes | Assigned agent | T2 |
| Game repo roster changes | Project lead | T2 |
| Project-scoped tools/plugins | Assigned agent | T2 |
| Typo/formatting fixes | Any agent | T3 |

### One Voice (Final Call per Domain)

| Domain | Final Call | Backup |
|--------|-----------|--------|
| Studio direction | Joaquín (Founder) | — |
| Architecture | Solo (Lead) | — |
| Game design | Yoda | Joaquín for vision disputes |
| Art direction | Boba | Yoda for aesthetic coherence |
| Audio direction | Greedo | Yoda for aesthetic coherence |
| Code quality | Solo | Ackbar for testing methodology |
| Production | Mace | Solo for priority conflicts |

### Emergency Authority

Any agent may make an emergency fix (production outage, critical bug, security vulnerability) without normal approval. Constraints:

1. **Minimum viable change** — no feature work under emergency cover.
2. **Retroactive review within 24 hours** at the appropriate tier.
3. **Logged** as a learning in the next retrospective.

---

## 5. Mandatory Ceremonies

| Milestone | Ceremony | Content |
|-----------|----------|---------|
| **Project START** | Kickoff | Team assignment, skills assessment, architecture plan, upstream verification |
| **Project MIDPOINT** | Health Check | Skills assessment, team evaluation, course correction, hub alignment |
| **Project END** | Closeout | Final evaluation, skill harvest, lessons learned, hub skill promotion |

**At every ceremony:** Skills assessment for all active agents against project needs. Team member evaluation for performance, collaboration, and growth. Results inform future team composition.

See `ceremonies.md` for full ceremony definitions, triggers, and agendas.

---

## 6. Cross-References

| Topic | Document |
|-------|----------|
| Ceremonies (definitions & triggers) | `ceremonies.md` |
| Issue routing & triage | `routing.md` |
| Quality gates & Definition of Done | `identity/quality-gates.md` |
| Project lifecycle & Sprint 0 checklist | `identity/new-project-playbook.md` |
| Skills catalog | `.squad/skills/` |
| Team roster & charters | `team.md`, `agents/*/charter.md` |
| Decision log | `decisions.md` |

**This document is the constitution. Those documents are the operating manuals.**

---

## 7. Guardrails

These rules prevent common infrastructure problems and keep governance enforceable.

| Guardrail | Rule |
|-----------|------|
| **G5** | Hub roster is infrastructure/tooling only. No game-specific agents on hub. Game agents live in their project repos. |
| **G7** | now.md is the single source of current focus. Only .squad/identity/now.md is authoritative. Remove any duplicate now.md files. Coordinator checks freshness at session start. |
| **G8** | squad.agent.md must be consistent across hub and downstream repos. Scribe checks for drift during commits (hash comparison). |
| **G9** | Cron-triggered workflows must use intervals of 1 hour or longer. No sub-hour polling. |
| **G12** | Identity documents must not contain rejected options or historical alternatives. Keep only the active decision. Archive rejected options to decisions-archive.md. |
| **G13** | Priority inflation guardrail (advisory). Ralph warns when >20% of open issues are labeled P0 or P1. Lead decides whether to re-triage. No CI enforcement. |
| **G14** | Blocked issues must have a `## Dependencies` section in the issue body documenting the blocker and what "prepare mode" work is allowed. |
| **G15** | P0 items blocked for >3 days trigger escalation. Lead must intervene: resolve blocker, downgrade priority, or escalate to Founder. |

---

## Appendix: Governance Evolution

### How to Change This Document

| Change Type | Tier | Authority |
|-------------|------|-----------|
| Changes to T0 scope (what requires Founder approval) | T0 | Founder |
| Structural changes to tiers or zones | T0 | Founder |
| Content updates, examples, clarifications | T1 | Lead (Solo) |
| Typos and formatting | T3 | Any agent |

Reviewed during every Hub Health Check (quarterly minimum).

### Version History

| Date | Change | Tier | Author |
|------|--------|------|--------|
| 2025 | v1 — Initial 9-domain governance | T0 | Solo |
| 2026-03-11 | v1.1 — Founder vision: T0 minimized, repo tiers, ceremonies, project autonomy | T0 | Solo, per Founder |
| 2026-07-25 | v1.2 — T0 ultra-minimized, T1 Lead-only authority, delegation rules | T0 | Solo, per Founder |
| 2026-07-25 | v2.0 — Full rewrite: 1051→~240 lines. Constitution format. Zero redundancy. | T0 | Solo, per Founder |
