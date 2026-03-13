# Decisions Log

## Core Context
This log captures architectural, process, and operational decisions made across the squad. Entries are merged from orchestration logs and decision inbox. Older entries (>14 days) are archived per G1.

---

## Studio Directives

### 2026-03-13T20:44Z: User directive — Strategic Leadership
**By:** Joaquin Perez del Real (via Copilot)
**Status:** APPROVED
**What:** El Lead debe esforzarse en la definición de la estrategia y asegurar un roadmap potente. La visión estratégica y la calidad del roadmap son prioridad del Lead.
**Why:** User request — captured for team memory. Solo (Lead) should prioritize strategic definition and ensure strong, well-defined roadmaps for all projects.

---

## Active Decisions

### 2026-03-13T20:12Z: Cross-repo communication rule
**By:** jperezdelreal (via SS Coordinator)
**Tier:** T0
**Status:** ✅ ACTIVE
**What:** No repo may make direct git commits to another repo's branch. ALL cross-repo communication goes through GitHub Issues. Each repo's Squad session owns its git state exclusively. This prevents push conflicts when multiple Ralph Go sessions run concurrently.
**Rule:** Use `gh issue create`, `gh issue comment`, `gh pr review` — NEVER `gh api repos/.../contents -X PUT`.

---

### 2026-03-13T19:58Z: Ralph Refueling Behavior
**By:** jperezdelreal (via SS Coordinator)
**Tier:** T1
**Status:** ✅ ACTIVE
**What:** When Ralph detects an empty board (no open issues with squad labels, no open PRs), instead of idling he MUST:
1. Check if a "Define next roadmap" issue already exists: `gh issue list --label roadmap --state open --limit 1`
2. If none exists → create one: `gh issue create --title "📋 Define next roadmap" --label roadmap --label "squad:{lead-name}" --body "Board is empty. Lead: define the next 3 features for this repo's roadmap. Max 3 features, well-scoped, @copilot-ready."`
3. If one already exists → skip, just report "📋 Roadmap issue already open, waiting for Lead."
**Why:** Prevents the autonomous pipeline from ever fully stopping. Complements perpetual-motion.yml (reactive) with proactive refueling.

---

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
