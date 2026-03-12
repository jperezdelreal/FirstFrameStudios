### 2026-03-12T14:35Z: Founder decisions for remediation
**By:** Jose (Founder) via Copilot

**Decision 1 - Ackbar:** HIBERNATE. Mover a _alumni, registry -> retired, limpiar refs en routing/ceremonies. Hub no necesita QA dedicado.

**Decision 2 - ComeRosquillas en games/:** BORRAR del hub. Ya tiene su propio repo (jperezdelreal/ComeRosquillas). Eliminar games/ComeRosquillas/ + quitar games/** de squad.config.ts allowedWritePaths.

**Decision 3 - PR template:** Reescribir con checklist web generico:
- No console errors in browser dev tools
- Tested in Chrome + Firefox
- Responsive (mobile viewport checked)
- No new lint warnings
- Integration gate CI passes

**Why:** Pre-autonomy cleanup. Todas las decisiones tomadas por Jose, recomendadas por Coordinator.
