# FFS Squad Optimization Plan

> Diagnóstico completo + decisiones aprobadas por Joaquín (Founder).
> Diagnóstico raw en `files/plan-diagnostic-backup.md`.
> Modelo validado con Brady (upstream-inheritance docs) y Tamir (Ralph Loop article).

---

## Contexto

FFS creció orgánicamente desde Ashfall (Godot) hasta un estudio multi-repo de web games sin limpiar la infraestructura. 33 hallazgos, 14 guardrails, 1 resuelto, 30 con decisión tomada, 2 sin acción necesaria.

**Modelo downstream (validado con Brady):** Upstream hereda CONTEXTO (skills, decisions, wisdom), no AGENTES. Cada repo tiene su propio squad local autónomo. ralph-watch centralizado (validado con Tamir).

---

## Hallazgos + Decisiones

### ✅ Resuelto

| # | Hallazgo | Resolución |
|---|----------|------------|
| 1 | decisions.md 104KB contaminado | Solo limpió a 93 líneas / 3.8KB (commit 3c3f947). G1 previene. |

### 🔴 Críticos — pendientes de ejecución

| # | Hallazgo | Decisión | Guardrail |
|---|----------|----------|-----------|
| 2 | Skills enciclopédicas (600KB, 42 dirs) | Reestructurar: SKILL.md max 5KB + REFERENCE.md bajo demanda. No archivar nada. Template define estructura. | G2 |
| 5 | 10 agentes game-specific en hub | Hibernar 6 (Chewie, Lando, Wedge, Greedo, Tarkin, Yoda). Hub = Solo + Jango + Mace + Scribe + Ralph + @copilot. | G5 |
| 14/24 | quality-gates.md 100% Godot hereda downstream | Reescribir para web (HTML/JS/Canvas + TS/Vite/PixiJS). Propagar via upstream sync. | G4+G11 |
| 17 | now.md en DOS lugares | Mantener identity/now.md (spawn template). Reemplazar contenido con .squad/now.md (más limpio). Eliminar duplicado. | G7 |
| 23 | TRES modelos downstream inconsistentes | squad init en ComeRosquillas + ffs-squad-monitor. Flora: verificar charters. | G10 |
| 30 | squad.agent.md 3 copias distintas | Sync automático: hub → template → downstream. | G8 |

### 🟡 Mejoras — pendientes de ejecución

| # | Hallazgo | Decisión | Guardrail |
|---|----------|----------|-----------|
| 3 | wisdom.md en CADA spawn | Quitar del spawn template default. Solo bajo demanda explícito. | — |
| 4 | now.md fecha alucinada | Resuelto con #17 (unificar + limpiar). | G7 |
| 6 | Scribe charter boilerplate | Reescribir con tareas reales. | — |
| 7 | 4 ceremonies obsoletas | Deshabilitar Integration Gate, Godot Smoke Test, Art Review, Spec Validation. | G6 |
| 8 | Quality gates Ashfall en web | Resuelto con #14 (reescribir). | G4 |
| 9 | Scribe 7 tareas overkill | Core: merge inbox + orchestration log + git commit. Resto bajo demanda. | — |
| 10/18/19/20 | File chaos en .squad/ root | Limpieza general: duplicados, huérfanos, logs >30 días. | G3+G13 |
| 16/25 | company.md opciones rechazadas hereda | Limpiar: solo First Frame Studios. | G12 |
| 22 | Scribe charter gigante en templates | Eliminar scribe-charter.md de root (5.1KB). | — |
| 31 | squad.config.ts "First Punch" | Actualizar a "First Frame Studios". | G14 |
| 32 | GitHub Actions 4,320 runs/mes | Heartbeat 15min→1h, notify 30min→4h. De 4,320 → 900 runs/mes. | G9 |

### ⚪ Sin acción necesaria

| # | Hallazgo | Motivo |
|---|----------|--------|
| 11 | decisions-archive.md 592KB | No se carga en spawns. Monitorear. |
| 15 | identity/ 192KB | Reference docs. No se cargan en spawns. |
| 21 | squad.agent.md 72.6KB | Necesario. Costo fijo. |
| 26 | squad.agent.md en downstream | Necesario. Sync resuelve drift (#30). |
| 27 | Workflow templates 66KB/repo | By design (squad CLI). |
| 28 | ralph-watch 1000 líneas | Funcional. Solo fixes puntuales (G10, G11). |
| 29 | 24 workflows | Reducir crons (#32). Event-triggered necesarios. |
| 33 | ralph-watch prompt lean sistema no | Resuelto por #1 (decisions) y #2 (skills). |

---

## Guardrails (prevención)

| # | Regla | Dónde |
|---|-------|-------|
| G1 | decisions.md max 5KB, auto-archive | Scribe template |
| G2 | SKILL.md max 5KB, largo → REFERENCE.md | Skill template + agent spawn |
| G3 | Logs auto-purge >30 días | Scribe template |
| G4 | Quality gates review en cada Kickoff | Kickoff ceremony |
| G5 | Hub roster = solo infra/tooling | governance.md |
| G6 | Ceremonies cleanup al archivar proyecto | Closeout ceremony |
| G7 | now.md single source + freshness check | Coordinator session start |
| G8 | squad.agent.md hash check en Scribe | Scribe commit hook |
| G9 | Cron workflows max 1h interval | Directive |
| G10 | ralph-watch skip repos sin Members | ralph-watch.ps1 |
| G11 | Upstream sync antes de cada repo session | ralph-watch.ps1 |
| G12 | Identity docs: sin opciones rechazadas | governance.md |
| G13 | .squad/ root: no archivos huérfanos | Scribe periodic check |
| G14 | squad.config.ts project name actual | Closeout ceremony |

---

## Orden de ejecución

### Fase 1 — Hub cleanup (sin dependencias, paralelizable)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 1a | Hibernar 6 game agents del hub roster (#5) | Solo/Jango | ✅ Done |
| 1b | Deshabilitar 4 ceremonies obsoletas (#7) | Solo | ✅ Done |
| 1c | Limpieza .squad/ root: duplicados, huérfanos (#10/18/19/20/22) | Jango | ✅ Done |
| 1d | Unificar now.md (#17) | Jango | ✅ Done |
| 1e | Fix squad.config.ts "First Punch" (#31) | Jango | ✅ Done |
| 1f | Quitar wisdom.md del spawn template (#3) | Solo | ✅ Done |

### Fase 2 — Content rewrite (requiere revisión)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 2a | Reescribir quality-gates.md para web (#14/24) | Solo | ✅ Done |
| 2b | Limpiar company.md opciones rechazadas (#16/25) | Yoda/Solo | ✅ Done |
| 2c | Reescribir Scribe charter (#6) | Solo | ✅ Done |
| 2d | Actualizar Scribe spawn template a 3 core tasks (#9) | Solo | ✅ Done |

### Fase 3 — Skills reestructuración (más trabajo)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 3a | Actualizar skill template (SKILL.md + REFERENCE.md structure) | Jango | ✅ Done |
| 3b | Reestructurar skills existentes (42 dirs → SKILL.md max 5KB cada uno) | Jango + agente por dominio | ✅ Done |

### Fase 4 — Ecosystem (cross-repo)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 4a | squad init en ComeRosquillas (#23) | Nueva sesión en ComeRosquillas | ✅ Done |
| 4b | squad init en ffs-squad-monitor (#23) | Nueva sesión en ffs-squad-monitor | ✅ Done |
| 4c | Verificar Flora charters son TS/PixiJS-specific (#23) | Nueva sesión en Flora | ✅ Done |
| 4d | Sync squad.agent.md hub → template → downstream (#30) | Jango | ✅ Done |
| 4e | Upstream sync en downstream repos (#24) | ralph-watch o manual | ✅ Done |

### Fase 5 — Workflows & ralph-watch (infra)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 5a | Reducir squad-heartbeat a 1h (#32) | Jango | ✅ Done |
| 5b | Reducir ralph-notify a 4h (#32) | Jango | ✅ Done |
| 5c | Añadir roster check a ralph-watch (G10) | Jango | ✅ Done |
| 5d | Añadir upstream sync a ralph-watch (G11) | Jango | ✅ Done |

### Fase 6 — Guardrails (post-cleanup)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 6a | Implementar G1-G3 en Scribe spawn template | Solo | ✅ Done |
| 6b | Implementar G5 + G12 en governance.md | Solo | ✅ Done |
| 6c | Implementar G4 + G6 + G14 en ceremonies.md | Solo | ✅ Done |
| 6d | Implementar G7 en coordinator session start (squad.agent.md) | Solo | ✅ Done |
| 6e | Implementar G8 en Scribe commit hook | Jango | ✅ Done |

### Fase 7 — Priority & Dependency System (governance evolution)

| Task | Qué | Quién | Estado |
|------|-----|-------|--------|
| 7a | Definir prioridades P0-P3 en governance.md | Solo | ✅ Done |
| 7b | Implementar dependency tracking (labels `blocked-by`, `needs-decision`) | Solo + Jango | ✅ Done |
| 7c | Actualizar Ralph para chequear dependencias antes de asignar | Jango | ✅ Done |
| 7d | Actualizar Lead triage con evaluación de dependencias | Solo | ✅ Done |
| 7e | Implementar "prepare but don't merge" mode en spawn template | Solo/Jango | ✅ Done |
| 7f | Crear labels P0-P3 + blocked-by en GitHub (hub + downstream) | Jango | ✅ Done |

> **Prerequisito:** Solo diseña la propuesta completa en issue #189 antes de implementar.

---

## Impacto esperado post-ejecución

| Métrica | Antes | Después |
|---------|-------|---------|
| decisions.md | ~~104KB~~ → 3.8KB ✅ | 3.8KB (G1 mantiene <5KB) |
| Skills cargadas por spawn | 30-180KB | <15KB (SKILL.md only) |
| Agentes hub | 10 | 3 (Solo + Jango + Mace) |
| Ceremonies auto-triggered | 4 | 1 (Design Review) |
| Context per spawn | ~3,000-5,000 líneas | ~400-600 líneas |
| GitHub Actions runs/mes | 4,320 | ~900 |
| Downstream repos funcionales | 1/3 (Flora) | 3/3 |
