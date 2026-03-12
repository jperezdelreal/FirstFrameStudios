# Decisions Log

## Core Context
This log captures architectural, process, and operational decisions made across the squad. Entries are merged from orchestration logs and decision inbox. Older entries (>14 days) are archived per G1.

---

## Active Decisions

### 2026-03-12T18:17Z: User directive — Premium barra libre
**By:** Joaquin Perez del Real (via Copilot)
**Status:** APPROVED
**What:** Premium requests (premium models) have unlimited budget — use them freely whenever it makes sense. This applies to ALL FFS repos (Hub, ComeRosquillas, Flora, ffs-squad-monitor). No need to justify or hold back.
**Why:** User request — captured for team memory

---

### 2026-03-12T18:00Z: Garden UI/HUD Architecture Decision
**By:** Erika (Systems Dev)
**Status:** APPROVED
**Context:** Issue #9 — Garden UI/HUD Implementation
**What:** Implemented comprehensive UI system for FLORA's garden scene with 5 new components (HUD, SeedInventory, PlantInfoPanel, DaySummary, PauseMenu) following consistent architectural pattern.
**Decision:**
- Container wrappers with position() and getContainer() methods
- destroy() for cleanup
- Semi-transparent panels (alpha 0.9-0.95)
- Rounded corners (8-16px radius)
- Color-blind friendly: Icons + patterns alongside colors
- Keyboard shortcuts centralized in setupKeyboardShortcuts()
- UI lifecycle managed in GardenScene (init, update, destroy)

**Alternatives Rejected:**
- Separate UI Scene Layer (adds complexity)
- React/DOM-based UI (PixiJS native preferred)
- Single monolithic HUD class (breaks SRP)

**Why:** Complete UI coverage for core gameplay loop with excellent UX, accessibility, and extensibility.

---

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
