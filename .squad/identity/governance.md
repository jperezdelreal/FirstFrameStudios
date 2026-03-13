# Governance — First Frame Studios

> **Version:** 3.0
> **Upstream:** Syntax Sorcery (see `upstream.json`)
> **Status:** Active — Aligned with SS governance 2026-03-14

---

## Quick Reference

### Tier Cheat Sheet

| Tier | Who Decides | What (summary) |
|------|-------------|-----------------|
| **T0** | Founder only | New game repos, `principles.md`, critical `.squad/` structural changes |
| **T1** | Lead (Solo) | Hub roster, tool repos, cross-repo architecture, quality gates, ceremonies, governance, `.squad/` content refactors |
| **T2** | Assigned agent | Feature work, bug fixes, game roster, project-scoped tools |
| **T3** | Auto-approved | Scribe ops, history updates, log entries, typos, formatting |

### Zone Cheat Sheet

| Zone | Control | Rule |
|------|---------|------|
| **A** | Hub-controlled | No override — consume only |
| **B** | Hub-default | Extend, don't weaken |
| **C** | Locally owned | Project decides |

### Escalation

Agent → Solo (Lead) → Founder (T0 only). No agent bypasses the Lead.

---

## Approval Tiers

### T0 — Founder Only
Irreversible or paradigm-shifting. Exhaustive list:
- Creating new **game** repositories
- Modifying `principles.md`
- Modifying `routing.md` tier definitions, `config.json` schema
- Changing decisions pipeline structure, agent folder conventions
- Changes to T0 scope itself

### T1 — Lead Authority (Solo, NO Founder approval)
Significant, reversible decisions. Fully delegated to Lead.
- Tool/utility repos, hub roster, cross-repo architecture
- Quality gates, ceremonies, skills, governance (not T0 scope)
- `.squad/` content refactors, squad config, technology stack
- Sprint scope (cross-project, with Mace alignment)

### T2 — Assigned Agent
Normal project-scoped work within charter boundaries.
- Feature work, bug fixes, game content/assets
- Game repo roster, project-specific tools/plugins/MCP
- Local config, CI/CD, documentation

### T3 — Auto-approved
Zero risk. Typos, formatting, comments, broken links, log entries, history appends.

---

## Execution Priority

| Priority | Name | Rule |
|----------|------|------|
| **P0** | Blocker | System-wide halt. Ralph processes FIRST. |
| **P1** | Sprint-Critical | Must complete this sprint. After P0. |
| **P2** | Normal | Standard queue. **Default.** |
| **P3** | Nice-to-Have | Process when capacity available. |

Tiers = who decides. Priority = when it runs. Independent axes.

---

## Autonomy Zones

**Zone A (Hub-controlled):** Identity, principles, governance, team roster, quality gates, mission/vision. Hub is authoritative.

**Zone B (Hub-default + extension):** Quality gates, ceremonies, routing, commit conventions, CI/CD, labels. Local can add stricter rules, never weaken.

**Zone C (Locally owned):** Game code, GDD, assets, tech stack, sprint planning, release schedule, project docs/tools.

---

## Guardrails

| ID | Rule |
|----|------|
| G5 | Hub roster = infrastructure only. Game agents in project repos. |
| G7 | `now.md` is single source of current focus. |
| G8 | `squad.agent.md` consistent across hub and downstream (Scribe checks drift). |
| G9 | Cron workflows: 1h+ intervals only. |
| G12 | Identity docs: active decisions only, no rejected alternatives. |
| G13 | Priority inflation advisory: warn at >20% P0/P1. |
| G14 | Blocked issues need `## Dependencies` section. |
| G15 | P0 blocked >3 days → Lead escalation. |

---

> Full governance archive: `identity/governance-archive.md`
> Upstream governance: Syntax Sorcery `decisions.md` § Governance
