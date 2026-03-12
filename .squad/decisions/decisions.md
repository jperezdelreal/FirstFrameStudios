# Decisions Log

## Core Context
This log captures architectural, process, and operational decisions made across the squad. Entries are merged from orchestration logs and decision inbox. Older entries (>14 days) are archived per G1.

---

## Active Decisions

### 2026-03-12T15:51Z: Founder directive — Remove games/ComeRosquillas/ from Hub
**By:** Joaquin Perez del Real (via Copilot)
**Status:** APPROVED
**What:** Eliminate `games/ComeRosquillas/` directory from FFS Hub repo. The game lives in its own repo (jperezdelreal/ComeRosquillas). Also remove `games/**` from squad.config.ts allowedWritePaths. This enforces the hub-and-spoke model: no game code in hub.
**Why:** User request — captured for team memory. Resolves R3.7+R3.8+R3.9 from optimization-plan-review.md.

### 2026-03-12T14:35Z: Founder decisions for remediation
**By:** Jose (Founder) via Copilot
**Status:** APPROVED

**Decision 1 - Ackbar:** HIBERNATE. Mover a _alumni, registry -> retired, limpiar refs en routing/ceremonies. Hub no necesita QA dedicado.

**Decision 2 - ComeRosquillas en games/:** BORRAR del hub. Ya tiene su propio repo (jperezdelreal/ComeRosquillas). Eliminar games/ComeRosquillas/ + quitar games/** de squad.config.ts allowedWritePaths.

**Decision 3 - PR template:** Reescribir con checklist web generico:
- No console errors in browser dev tools
- Tested in Chrome + Firefox
- Responsive (mobile viewport checked)
- No new lint warnings
- Integration gate CI passes

**Why:** Pre-autonomy cleanup. Todas las decisiones tomadas por Jose, recomendadas por Coordinator.
