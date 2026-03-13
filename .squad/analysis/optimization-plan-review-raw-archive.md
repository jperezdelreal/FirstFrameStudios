# optimization-plan-review-raw.md — Full Archive

> Archived version. Compressed operational copy at `optimization-plan-review-raw.md`.

---

# FFS Optimization Plan Review — Pre-Flight Diagnostic

> Diagnóstico completo de los 4 repos antes de habilitar Ralph Watch autónomo.
> Fecha: 2026-03-12 | Solicitado por: José (Founder)
> Contexto: Las 33 mejoras del optimization-plan.md están implementadas (✅ Done).
> Objetivo: ¿Estamos listos para Ralph Watch autónomo?
> Fuentes: Diagnóstico coordinador (5 agentes paralelos) + diagnóstico Solo (dry-run)

---

## Veredicto Ejecutivo

**🟡 LISTO CON CAVEATS — necesita higiene antes de lanzar.**

Ralph-watch funciona correctamente (dry-run verificado). Los fallos en logs (96%) son históricos, previos a la optimización. El script actual pasa el dry-run, filtra governance, hace upstream sync, y selecciona issues correctamente.

Los bloqueantes reales son de **higiene**: labels incorrectos, referencias Godot en ficheros activos, e issues completados aún abiertos.

| Dimensión | Estado | Bloqueante |
|-----------|--------|------------|
| Hub (.squad/) | 🟢 Saludable con warnings | No |
| ComeRosquillas | 🟢 Listo | No |
| Flora | 🔴 Merge conflict + labels equivocados | **Sí** |
| FFS Monitor | 🟡 Labels incompletos | **Sí** |
| Labels cross-repo | 🔴 Inconsistentes | **Sí** |
| Ralph-watch script | ✅ Dry-run exitoso | No |
| Ralph-watch logs históricos | ⚠️ 96% failure (pre-optimización) | No (histórico) |
| Issues hub #187-189 | ⚠️ Trabajo DONE pero issues abiertos | Cerrar |
| Stale Godot refs en config activos | 🟡 Confunden a agentes | Sí (medio) |

**Estimación para estar listo:** ~1-2 horas de trabajo (ver Fase de Remediación).

### Dry-Run Verificado (por Solo)

```
[ralph] Ralph Watch v3 - First Frame Studios (Night/Day Mode)
   Mode: day (sessions=1, interval=10m, maxIssues=3/session)
   DryRun: YES | MaxRounds: 1

Round 1:
  [pull] All 4 repos — would fetch/pull
  [sync] Hub -> ComeRosquillas, flora, ffs-squad-monitor — all up to date
  [sched] Hub issues #189, #188, #187 — SKIPPED (needs-research)
  [sched] Flora #9 — SELECTED (P1, squad:wedge)
  Session: jperezdelreal/flora -- 1 issue
    #9: [Sprint 0] Garden UI/HUD [P1]

Round 1 complete (4.5s). Stopped at MaxRounds.
```

---

## 1. FFS Hub (FirstFrameStudios)

### ✅ Lo que está bien (19/20 checks)

- Governance T0-T3 completa (17.9 KB, Constitution-grade)
- Identity completa (10 ficheros, ninguno vacío)
- 4 charters activos (Solo, Jango, Mace, Scribe) — todos bien definidos
- 10 agentes hibernados correctamente en `_alumni/`
- 43 skills, todas SKILL.md < 5KB (G2 cumplido)
- Casting state consistente (registry/policy/history)
- 24 workflows con paths correctos, crons ≥1h (G9 cumplido)
- `.gitattributes` con `merge=union` para append-only
- `copilot-instructions.md` completo (3.8 KB)
- `now.md` actualizado (2026-03-12)
- `config.json` válido, GitHub Discussions configurado
- ralph-watch.ps1 operativo (1,165 líneas, multi-repo, governance-aware)
- Orchestration log activo (51 entries recientes)

### ⚠️ Warnings

| # | Hallazgo | Impacto | Acción |
|---|----------|---------|--------|
| H1 | `decisions.md` a 8KB (límite G1: 5KB) | Spawn tokens extra | Archivar entries >14 días |
| H2 | Solo `history.md` **35.9KB** (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H3 | Jango `history.md` **33.9KB** (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H4 | Ackbar `history.md` **13.1KB** (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H5 | CODEOWNERS referencia `games/ashfall/` | Cosmético | Eliminar línea |
| H6 | Faltan labels `tier:t0-t3` en GitHub | Governance tiers no rastreables por label | Crear labels |

### ❌ Problemas

| # | Hallazgo | Impacto | Bloqueante |
|---|----------|---------|------------|
| H7 | Issues #187, #188, #189: trabajo DONE pero issues abiertos (tienen labels squad + go:needs-research) | Ralph los salta por `needs-research` pero deberían cerrarse | **Cerrar** |
| H8 | Issue #174 "Daily Digest" abierto con label `digest` | Ruido en backlog | Cerrar o ignorar |
| H9 | **Stale Godot refs en ficheros ACTIVOS** que influyen en agentes: | Confunden a agentes en cada sesión | **Sí (medio)** |

**Detalle H9 — Refs Godot en ficheros activos (hallado por Solo):**

| Fichero | Issue | Severidad |
|---------|-------|-----------|
| `.squad/ceremonies.md` | "Godot Smoke Test" ceremony aún presente (5 refs Godot) | 🟡 Medio — agentes la ven |
| `.github/pull_request_template.md` | Checkbox "Tested in Godot editor" | 🟡 Medio — PRs lo muestran |
| `CONTRIBUTING.md` | 6 refs Ashfall/Godot (branch examples, labels, style guide) | 🟡 Medio — nuevos agentes lo leen |
| `README.md` | Fila Ashfall en tabla de proyectos | 🟢 Bajo |
| `.squad/skills/fighting-game-design/` | Ejemplos Ashfall (contextual) | 🟢 Bajo |
| `docs/src/content/blog/` | Ashfall en posts (publicado, no editar) | 🟢 Bajo |

---

## 2. ComeRosquillas

### ✅ Lo que está bien

- `## Members` header correcto — 5 agentes (Moe, Barney, Lenny, Nelson, Scribe)
- Universo: The Simpsons (casting consistente)
- Routing completo, ceremonies configuradas
- Todos los charters presentes y detallados
- Historiales bajo 12KB (< 1KB cada uno)
- upstream.json con `last_synced: 2026-07-24`, 6 contenidos sincronizados
- Upstream directory con manifest.json + identity + skills
- 13 squad workflows desplegados
- `.gitattributes` configurado
- GitHub labels squad completos (squad:moe, squad:barney, etc.)
- 0 issues abiertas (backlog limpio)

### ⚠️ Warnings

| # | Hallazgo | Impacto | Acción |
|---|----------|---------|--------|
| C1 | Sin `copilot-instructions.md` (ni en `.github/` ni en `.squad/`) | @copilot sin contexto local | Crear en `.github/` |
| C2 | Labels heredados de Star Wars (squad:chewie, solo, jango, etc.) | Cosmético, no rompe nada | Limpiar labels obsoletos |
| C3 | Sin `blocked-by:*` labels | Ralph no detecta dependencias | Crear labels |
| C4 | Sin `.github/squad.labels.json` | Labels ya existen en GitHub, pero no hay definición local | Crear fichero |
| C5 | Upstream cache `.squad/upstream/identity/quality-gates.md` tiene refs Godot | Hub source ya está limpia, pero copia cacheada es stale | Re-sync forzado o limpiar manual |
| C6 | Heartbeat cron **DESHABILITADO** (comentado "pre-migration") | Sin heartbeat automático | Re-habilitar |
| C7 | `sync-squad-labels.yml` desincronizado del hub (P lowercase, sin blocked-by) | Labels no se sincronizan correctamente | Sincronizar con versión hub |

### ❌ Problemas

Ninguno bloqueante.

---

## 3. Flora

### ✅ Lo que está bien

- `## Members` header correcto — 6 agentes (Oak, Brock, Erika, Misty, Sabrina, Scribe)
- Universo: Pokémon (casting consistente, migrado desde Star Wars)
- 35 ficheros TypeScript con código real de juego
- Routing y ceremonies configurados
- Todos los charters presentes
- `.gitattributes` configurado
- Quality gates completas (216 líneas)
- 1 orchestration log entry (migración)

### ⚠️ Warnings

| # | Hallazgo | Impacto | Acción |
|---|----------|---------|--------|
| F1 | `upstream.json` `last_synced: null` | Nunca sincronizado con hub | Primer ralph-watch run lo hará |
| F2 | Historiales vacíos (98 bytes, solo stub) | No hay learnings | Se poblará naturalmente |
| F3 | `decisions.md` vacío | Normal para squad nuevo | — |
| F4 | Sin directorio `.squad/skills/` | Hereda del hub | Crear si necesario |
| F5 | Labels GitHub son Star Wars (squad:chewie,lando,wedge,tarkin,greedo,jango,solo,yoda) pero equipo es Pokémon | Ralph no puede asignar al equipo local — **TODOS 5 labels locales FALTAN** | **Crear labels Pokémon** |
| F6 | Falta label `P3` (tiene P0, P1, P2) | Prioridad incompleta | Crear |
| F7 | Sin `blocked-by:*` labels | Ralph no detecta dependencias | Crear |
| F8 | ~~Sin `copilot-instructions.md`~~ **CORRECCIÓN: SÍ existe en `.github/copilot-instructions.md`** ✅ | — | — |
| F9 | `bitECS` en team.md pero no en package.json | Confusión de stack | Limpiar referencia o instalar |
| F10 | **Issue #9 asignado a `squad:wedge`** — Wedge es agente HUB hibernado, no de Flora | Ralph lo selecciona pero el nombre no mapea al equipo local | **Re-etiquetar a squad:misty o squad:brock** |
| F11 | **PR #18 abierto sin labels** (feat: garden UI/HUD, branch `squad/9-garden-hud`) | PR invisible para tracking | Añadir label `squad` |

### ❌ Problemas

| # | Hallazgo | Impacto | Bloqueante |
|---|----------|---------|------------|
| F12 | **Merge conflict en `GardenScene.ts`** | Build roto, no compila | **Sí** |
| F13 | Sin squad-* workflows desplegados | No hay CI, triage, ni labels automáticos | **Sí** |

---

## 4. FFS Squad Monitor

### ✅ Lo que está bien

- `## Members` header correcto — 5 agentes (Ripley, Dallas, Lambert, Kane, Scribe)
- Universo: Alien 1979 (casting consistente)
- Routing completo, ceremonies configuradas
- Todos los charters presentes (23-52 líneas)
- Build pasa (Vite, 289ms, sin errores)
- Git limpio, branches activas
- `.gitattributes` configurado
- Templates completos (19 ficheros + 11 workflows)
- 0 issues abiertas

### ⚠️ Warnings

| # | Hallazgo | Impacto | Acción |
|---|----------|---------|--------|
| M1 | `upstream.json` `last_synced: null` | Nunca sincronizado | Ejecutar sync |
| M2 | Sin `copilot-instructions.md` (ni `.github/` ni `.squad/`) | @copilot sin contexto | Crear |
| M3 | **En branch `squad/13-real-data`**, no en `master` | Divergido del default branch | Mergear o cerrar |

### ❌ Problemas

| # | Hallazgo | Impacto | Bloqueante |
|---|----------|---------|------------|
| M4 | **Sin workflows en `.github/workflows/`** (templates existen pero no desplegados) | No hay CI, triage, labels, heartbeat | **Sí** |
| M5 | **Solo 2 squad labels** (squad:jango, squad:wedge) — del equipo anterior | Ralph no puede asignar a Ripley/Dallas/Lambert/Kane — **TODOS 4 labels locales FALTAN** | **Sí** |
| M6 | Faltan labels P0, P3 (solo tiene P1, P2) | Prioridades incompletas | **Sí** |
| M7 | Sin `blocked-by:*` labels | Sin tracking de dependencias | Sí (menor) |
| M8 | Usa `master` como default branch (todos los demás usan `main`) | Potencial confusión en scripts | Bajo |

---

## 5. Ralph-watch.ps1 — Estado Operativo

### ✅ Arquitectura del script (9/10)

| Feature | Estado |
|---------|--------|
| Multi-repo (4 repos) | ✅ |
| `## Members` header check | ✅ |
| Upstream sync antes de cada repo (G11) | ✅ |
| Governance tier filtering (skip T0/T1) | ✅ |
| Git remote URL validation | ✅ |
| Night/day mode auto-detection | ✅ |
| UTF-8 encoding | ✅ |
| Sin paths hardcodeados | ✅ |
| Sin referencias a repos antiguos | ✅ |

### ⚠️ Logs históricos (pre-optimización, NO el estado actual)

**Datos del log `ralph-2026-03-12.jsonl`:**

```
Total entries:    162
FAIL:             156 (96.3%)
OK:                 5 (3.1%)
MODE_CHANGE:        1 (0.6%)
Consecutive fails: 170+
```

- Estos fallos son de **antes** de la optimización (decisions.md 104KB, prompts inflados, etc.)
- **El dry-run POST-optimización funciona correctamente** (ver Veredicto Ejecutivo)
- Recomendación: limpiar logs antiguos antes del primer run real para no contaminar métricas

---

## 6. Consistencia de Labels Cross-Repo

| Label Type | FFS Hub | ComeRosquillas | Flora | FFS Monitor |
|------------|---------|----------------|-------|-------------|
| `squad` | ✅ | ✅ | ✅ | ✅ |
| `squad:{local-members}` | ✅ (13) | ✅ (moe, barney, lenny, nelson) | ❌ Star Wars, no Pokémon | ❌ Solo jango, wedge |
| `P0` | ✅ | ✅ | ✅ | ❌ |
| `P1` | ✅ | ✅ | ✅ | ✅ |
| `P2` | ✅ | ✅ | ✅ | ✅ |
| `P3` | ✅ | ✅ | ❌ | ❌ |
| `blocked-by:*` | ✅ (5 tipos) | ❌ | ❌ | ❌ |
| `tier:t0-t3` | ❌ | ❌ | ❌ | ❌ |

**Impacto**: Ralph no puede hacer triage correcto en Flora ni FFS Monitor. ComeRosquillas funciona pero sin dependency tracking. Ningún repo tiene labels de tier.

---

## 7. Workflows Cross-Repo

| Workflow | FFS Hub | ComeRosquillas | Flora | FFS Monitor |
|----------|---------|----------------|-------|-------------|
| squad-triage.yml | ✅ | ✅ | ❌ | ❌ |
| squad-issue-assign.yml | ✅ | ✅ | ❌ | ❌ |
| sync-squad-labels.yml | ✅ | ✅ | ❌ | ❌ |
| squad-heartbeat.yml | ✅ | ✅ | ❌ | ❌ |
| squad-ci.yml | ✅ | ✅ | ❌ | ❌ |
| squad-label-enforce.yml | ✅ | ✅ | ❌ | ❌ |
| squad-main-guard.yml | ✅ | ✅ | ❌ | ❌ |

**Flora y FFS Monitor no tienen workflows squad desplegados.** Los templates existen en `.squad/templates/workflows/` pero nunca se copiaron a `.github/workflows/`.

---

## Plan de Remediación

### Fase R1 — Bloqueantes (hacer ANTES de Ralph Watch)

| # | Qué | Repo | Esfuerzo |
|---|-----|------|----------|
| R1.1 | Resolver merge conflict `GardenScene.ts` | Flora | 15 min |
| R1.2 | Desplegar squad workflows a `.github/workflows/` | Flora | 15 min |
| R1.3 | Desplegar squad workflows a `.github/workflows/` | FFS Monitor | 15 min |
| R1.4 | Crear labels squad:{oak,brock,erika,misty,sabrina} | Flora | 10 min |
| R1.5 | Crear labels squad:{ripley,dallas,lambert,kane} | FFS Monitor | 10 min |
| R1.6 | Crear labels P3 (Flora) + P0,P3 (FFS Monitor) | Flora + FFS Monitor | 5 min |
| R1.7 | Crear labels `blocked-by:*` (5 tipos) | ComeRosquillas, Flora, FFS Monitor | 10 min |
| R1.8 | **Cerrar issues #187, #188, #189** (tienen labels, trabajo completado) | FFS Hub | 2 min |
| R1.9 | Re-etiquetar Flora #9 de `squad:wedge` a agente Flora local | Flora | 2 min |
| R1.10 | **Resolver inconsistencia Ackbar** (añadir a Members O hibernar) | FFS Hub | 5 min |
| R1.11 | **Reescribir PR template** (5/5 checkboxes son GDScript/Godot → web) | FFS Hub | 10 min |
| R1.12 | **Mergear `squad/172-governance-safeguards` a main** | FFS Hub | 5 min |

**Total Fase R1: ~1.5 horas**

### Fase R2 — Importantes (antes de dejar Ralph desatendido)

| # | Qué | Repo | Esfuerzo |
|---|-----|------|----------|
| R2.1 | Summarizar Solo history.md (**35.9KB** → <12KB) | FFS Hub | 20 min |
| R2.2 | Summarizar Jango history.md (**33.9KB** → <12KB) | FFS Hub | 20 min |
| R2.3 | Summarizar Ackbar history.md (**13.1KB** → <12KB) | FFS Hub | 10 min |
| R2.4 | Archivar decisions.md (**10.3KB** → <5KB) + eliminar duplicado P0-P3 | FFS Hub | 15 min |
| R2.5 | Limpiar refs Godot de `ceremonies.md` (Integration Gate + Godot Smoke Test) | FFS Hub | 5 min |
| R2.6 | Limpiar refs Ashfall/Godot de `CONTRIBUTING.md` (6 refs) | FFS Hub | 10 min |
| R2.7 | Crear `copilot-instructions.md` en `.github/` | ComeRosquillas + FFS Monitor | 15 min |
| R2.8 | Crear labels `tier:t0-t3` | Todos repos | 10 min |
| R2.9 | Archivar 4 skills stale (code-review-checklist, project-conventions, fighting-game-design, beat-em-up-combat) | FFS Hub | 5 min |
| R2.10 | Fix registry.json: Boba → `retired`, añadir Nien/Leia/Bossk como `retired` | FFS Hub | 5 min |
| R2.11 | Re-habilitar heartbeat cron | ComeRosquillas | 5 min |
| R2.12 | Sincronizar `sync-squad-labels.yml` con hub (P uppercase + blocked-by) | ComeRosquillas | 10 min |
| R2.13 | Debug workflows fallando (ralph-heartbeat-notify, pr-body-check) | FFS Hub | 20 min |

**Total Fase R2: ~2.5 horas**

### Fase R3 — Limpieza (nice-to-have)

| # | Qué | Repo | Esfuerzo |
|---|-----|------|----------|
| R3.1 | Limpiar labels Star Wars obsoletos | Flora | 5 min |
| R3.2 | Limpiar labels Star Wars heredados | ComeRosquillas | 5 min |
| R3.3 | Eliminar `games/ashfall/` de CODEOWNERS | FFS Hub | 2 min |
| R3.4 | Limpiar referencia bitECS de team.md (o instalar) | Flora | 5 min |
| R3.5 | Crear `.github/squad.labels.json` | ComeRosquillas | 5 min |
| R3.6 | Re-sync forzado upstream cache ComeRosquillas (quality-gates.md stale) | ComeRosquillas | 5 min |
| R3.7 | Eliminar `.first-run` | ComeRosquillas, FFS Monitor | 1 min |
| R3.8 | Actualizar README.md fila Ashfall | FFS Hub | 2 min |

---

## Checklist Pre-Launch Ralph Watch (DEFINITIVO — actualizado con datos frescos)

```
FASE R1 (BLOQUEANTE — no lanzar sin completar):
[ ] Hub: Mergear squad/172-governance-safeguards a main
[ ] Hub: Resolver inconsistencia Ackbar (add to Members o hibernate)
[ ] Hub: Reescribir PR template (5/5 checkboxes GDScript/Godot → web)
[ ] Hub: Cerrar issues #187-189 (tienen labels, trabajo DONE)
[ ] Flora: Resolver merge conflict GardenScene.ts (VERIFICADO: aún presente)
[ ] Flora: Desplegar squad workflows a .github/workflows/ (VERIFICADO: 0 workflows)
[ ] Flora: Crear labels squad:{oak,brock,erika,misty,sabrina} (VERIFICADO: todos faltan)
[ ] Flora: Re-etiquetar #9 de squad:wedge a agente local
[ ] Flora: Crear label P3 (tiene P0,P1,P2)
[ ] FFS Monitor: Desplegar squad workflows a .github/workflows/ (VERIFICADO: ninguno)
[ ] FFS Monitor: Crear labels squad:{ripley,dallas,lambert,kane} (VERIFICADO: todos faltan)
[ ] FFS Monitor: Crear labels P0, P3 (solo tiene P1,P2)
[ ] Todos downstream: Crear labels blocked-by:* (5 tipos) (VERIFICADO: ningún repo los tiene)

FASE R2 (ANTES DE DESATENDER):
[ ] Hub: Archivar decisions.md (10.3KB → <5KB) + fix duplicado P0-P3
[ ] Hub: Summarizar Solo (35.9KB), Jango (33.9KB), Ackbar (13.1KB) history.md → <12KB
[ ] Hub: Limpiar ceremonies.md (Integration Gate + Godot Smoke Test refs)
[ ] Hub: Limpiar CONTRIBUTING.md (6 refs Ashfall/Godot)
[ ] Hub: Debug workflows fallando (ralph-heartbeat-notify, pr-body-check)
[ ] Hub: Archivar 4 skills stale a _archived/
[ ] Hub: Fix registry.json (Boba→retired, añadir Nien/Leia/Bossk como retired)
[ ] ComeRosquillas: Re-habilitar heartbeat cron (VERIFICADO: comentado)
[ ] ComeRosquillas: Sincronizar sync-squad-labels.yml con hub
[ ] ComeRosquillas + FFS Monitor: Crear copilot-instructions.md en .github/
[ ] Todos repos: Crear labels tier:t0-t3

POST-LAUNCH:
[ ] git checkout main en hub (actualmente en squad/172-governance-safeguards)
[ ] git checkout master en FFS Monitor (actualmente en squad/13-real-data)
[ ] ralph-watch.ps1 -DryRun -MaxRounds 1 (ya verificado ✅ por Solo)
[ ] ralph-watch.ps1 -MaxRounds 3 (real, supervisado)
[ ] Verificar heartbeat: cat tools\.ralph-heartbeat.json
[ ] Verificar upstream sync en Flora y FFS Monitor
[ ] Dejar ralph-watch autónomo en night mode

FASE R3 (CUANDO HAYA TIEMPO):
[ ] Limpiar 27 stashes en hub
[ ] Limpiar branches squad/* sin mergear (20+ across repos)
[ ] FFS Monitor: considerar renombrar master → main
[ ] Regenerar squad.labels.json (solo define 9/40+ labels)
[ ] Limpiar labels Star Wars obsoletos en Flora + ComeRosquillas
[ ] Añadir Issue Source a team.md en ComeRosquillas + FFS Monitor
[ ] Flora PR #18: añadir labels
```

---

## Comparación: Estado Post-Optimization vs Ahora

| Métrica | Post-Optimization | Estado Actual | Veredicto |
|---------|-------------------|---------------|-----------|
| decisions.md | 3.8KB ✅ | **10.3KB** ❌ | Necesita archive urgente |
| Skills < 5KB | ✅ | ✅ | Mantenido |
| Agentes hub | 3 activos ✅ | 4 activos (+ Ackbar inconsistente) | ⚠️ Ver §8 |
| Ceremonies | 1 auto-triggered ✅ | ⚠️ Stale Godot ceremonies | Necesita limpieza |
| Context per spawn | ~400-600 líneas | ⚠️ Histories inflados | Necesita summarize |
| GitHub Actions runs/mes | ~900 ✅ | ⚠️ Hub workflows fallando | Necesita debug |
| Downstream repos funcionales | 3/3 ✅ | 1/3 ❌ | Flora roto, Monitor sin infra |

---

## 8. Hallazgos adicionales (deep-dive round 2)

Hallazgos descubiertos en la segunda ronda de exploración que ninguno de los diagnósticos anteriores detectó.

### 🔴 Ackbar — Inconsistencia de roster (CRÍTICO)

Ackbar aparece como "active" en 4 de 5 ficheros de referencia, pero **NO está en team.md**:

| Fuente | Status Ackbar |
|--------|---------------|
| `.squad/team.md` `## Members` | ❌ **AUSENTE** |
| `.squad/casting/registry.json` | ✅ `"status": "active"` |
| `.squad/agents/ackbar/charter.md` | ✅ Existe (en agents/, no en _alumni/) |
| `.squad/routing.md` | ✅ Referenciado (smoke test) |
| `.squad/ceremonies.md` | ✅ Referenciado (Integration Gate, Godot Smoke Test) |

**Impacto**: Workflows que leen `## Members` para crear labels (`sync-squad-labels.yml`) no crearán `squad:ackbar`. Ralph no puede asignarle issues.

**Decisión necesaria**: ¿Ackbar debería estar activo o hibernado? Si activo → añadir a Members. Si hibernado → mover a `_alumni/`, actualizar registry a "retired", limpiar refs en routing/ceremonies.

### 🟡 Boba — registry dice "active" pero está en `_alumni/`

Boba aparece como `"status": "active"` en `registry.json` pero su carpeta está en `.squad/agents/_alumni/boba/` y aparece en la sección Hibernated de team.md. El registry debería decir `"retired"`.

### 🟡 Nien, Leia, Bossk — en `_alumni/` y team.md pero NO en registry

Estos 3 agentes tienen carpeta en `_alumni/`, aparecen en team.md Hibernated, pero **no existen en `registry.json`** en absoluto. Deberían tener entries con `"status": "retired"` para preservar el historial de nombres.

**Resumen de inconsistencias de casting:**

| Agente | team.md | registry.json | Carpeta | Corrección |
|--------|---------|---------------|---------|------------|
| Ackbar | ❌ Ausente | `active` | `agents/ackbar/` | Decidir: add a Members o hibernate |
| Boba | Hibernated ✅ | `active` ❌ | `_alumni/` ✅ | Cambiar registry a `retired` |
| Nien | Hibernated ✅ | ❌ NO EXISTE | `_alumni/` ✅ | Añadir a registry como `retired` |
| Leia | Hibernated ✅ | ❌ NO EXISTE | `_alumni/` ✅ | Añadir a registry como `retired` |
| Bossk | Hibernated ✅ | ❌ NO EXISTE | `_alumni/` ✅ | Añadir a registry como `retired` |

### 🔴 decisions.md realmente a 10.3KB (no 8KB)

El tamaño real es **10,322 bytes** — el doble del límite G1 de 5KB. Contiene:
- 26 entries, la mayoría de marzo 2026 (>136 días de antigüedad)
- Una entrada **duplicada**: "Priority & Dependency System (P0-P3)" aparece DOS veces
- Solo 2 entries recientes (julio 2026)

### 🔴 PR template es ENTERAMENTE Godot

No es solo un checkbox — el **checklist completo** es GDScript:
```
- [ ] Follows GDSCRIPT-STANDARDS.md (no := with dict/array, explicit types)
- [ ] No _process for gameplay logic (use _physics_process)
- [ ] Integration gate CI passes
- [ ] Tested in Godot editor
- [ ] Windows export tested (for UI changes)
```

Cada PR que se abra muestra este checklist. Los agentes lo leen y se confunden.

### 🔴 Hub workflows FALLANDO

Últimos 5 runs del hub:
| Workflow | Estado |
|----------|--------|
| squad-notify-ralph-heartbeat | ❌ FAILURE |
| pr-body-check | ❌ FAILURE |
| squad-notify-ralph-heartbeat | ❌ FAILURE |
| pr-body-check | ❌ FAILURE |
| Squad Notify - CI Failure | SKIPPED |

**Estos workflows fallan en CADA push** — necesitan debug.

### 🟡 ComeRosquillas heartbeat DESHABILITADO

El cron en `squad-heartbeat.yml` está **comentado** con nota "pre-migration":
```yaml
# DISABLED: Cron heartbeat commented out pre-migration
# schedule:
#   - cron: '*/30 * * * *'
```

Sin heartbeat, Ralph no puede recibir triggers automáticos en ComeRosquillas.

### 🟡 ComeRosquillas sync-squad-labels.yml DESINCRONIZADO del hub

| Diferencia | Hub | ComeRosquillas |
|------------|-----|----------------|
| Priority labels | `P0, P1, P2, P3` (mayúsculas) | `p0, p1, p2` (minúsculas, sin P3) |
| blocked-by labels | ✅ Definidos (5 tipos) | ❌ NO definidos |
| Colores | Esquema A | Esquema B diferente |

### 🟡 squad.labels.json incompleto

El fichero `.github/squad.labels.json` del hub solo define **9 de ~40+ labels**. Solo tiene `blocked-by:*` y `priority:P*`. Faltan: `squad:*`, `go:*`, `release:*`, `type:*`, `signal:*`.

### 🟡 Git state — repos en branches equivocados

| Repo | Branch actual | Debería estar en |
|------|--------------|------------------|
| FirstFrameStudios | `squad/172-governance-safeguards` | `main` (hay que mergear) |
| ffs-squad-monitor | `squad/13-real-data` | `master` (hay que mergear) |
| ComeRosquillas | `main` ✅ | — |
| Flora | `main` ✅ | — |

Además: FFS hub tiene **27 stashes** y **20+ branches sin mergear**.

### 🟡 ffs-squad-monitor usa `master`, no `main`

Todos los otros repos usan `main`. Monitor usa `master`. Potencial confusión en scripts que asumen `main`.

### 🟡 Flora CI/deploy FALLANDO

Las últimas 5 runs de CI y deploy en Flora son **todas FAILURE**. Probablemente por el merge conflict en GardenScene.ts.

### ✅ Correcciones a diagnósticos anteriores

| Lo que se dijo | Realidad |
|----------------|----------|
| "Flora no tiene copilot-instructions.md" | ✅ SÍ tiene: `.github/copilot-instructions.md` (comprehensivo, PixiJS v8) |
| "Flora no tiene squad.agent.md" | Correcto — no tiene `.github/agents/squad.agent.md` (intencional según config) |
| "squad.agent.md podría haber drifteado" | ✅ **IDÉNTICO** en los 4 repos (MD5: `B789E063`) |
| "bitECS está mal referenciado" | ⚠️ Mixto — Flora team.md y quality-gates.md lo mencionan, pero no está en package.json |

### 🟡 Skills stale no archivadas

4 skills en `.squad/skills/` (no en `_archived/`) referencian Godot/Ashfall:
- `code-review-checklist` → "GDScript game systems"
- `project-conventions` → "Godot 4 projects"
- `fighting-game-design` → Ashfall-specific
- `beat-em-up-combat` → First Punch-specific

### 🟡 Issue Source falta en 2 subsquads

ComeRosquillas y ffs-squad-monitor no tienen sección `## Issue Source` en team.md. Ralph-watch puede funcionar sin ella (usa `$repoGitHubMap` hardcoded), pero es buena higiene.


---

## 9. Hallazgos finales (sweep exhaustivo de stale refs)

### 🔴 ffs-squad-monitor: SQUAD_AGENTS hardcodeado en vite.config.js (CRITICO)

El dashboard tiene `SQUAD_AGENTS` en `vite.config.js:17-30` con los 12 agentes Star Wars del hub antiguo. Parsea logs y renderiza UI con nombres que no existen en ningun subsquad actual. Ningun agente Simpsons/Pokemon/Alien aparece.

### 🟡 Flora GDD.md referencia agentes hub

`docs/GDD.md:386-387`: "Solo reviews" / "Jango plans" -- deberian ser Oak (Lead local).

### 🟡 Hub structural remnants

| Hallazgo | Fichero | Impacto |
|----------|---------|---------|
| .gitignore tiene patrones Godot | `.gitignore:4-7` | Bajo |
| .editorconfig tiene `[*.gd]` | `.editorconfig:18-20` | Bajo |
| `games/` con ComeRosquillas dentro del hub | `games/ComeRosquillas/` | Medio -- viola modelo hub |
| `games/ComeRosquillas/docs/` site Astro duplicado | nested docs/ | Bajo |
| `squad.config.ts` permite `games/**` | `squad.config.ts:73` | Medio |
| CONTRIBUTING.md squad roles con agentes hibernados | `:103-108` | Medio |

### 🟢 Refs stale correctamente archivadas (NO TOCAR)

`.squad/analysis/` (40+ docs), `skills/_archived/godot-*` (6 dirs), `agents/_alumni/` (10 agentes), `decisions-archive.md`, `docs/blog/` -- todo correctamente aislado.

---

## Plan de Remediacion DEFINITIVO

### Fase R1 -- Bloqueantes (ANTES de Ralph Watch) -- ~2h

| # | Que | Repo |
|---|-----|------|
| R1.1 | Resolver merge conflict GardenScene.ts | Flora |
| R1.2 | Desplegar squad workflows | Flora |
| R1.3 | Desplegar squad workflows | FFS Monitor |
| R1.4 | Crear labels squad:{oak,brock,erika,misty,sabrina} | Flora |
| R1.5 | Crear labels squad:{ripley,dallas,lambert,kane} | FFS Monitor |
| R1.6 | Crear labels P3 (Flora) + P0,P3 (FFS Monitor) | Flora + FFS Monitor |
| R1.7 | Crear labels blocked-by:* (5 tipos) | Todos downstream |
| R1.8 | Cerrar issues #187-189 (trabajo DONE) | FFS Hub |
| R1.9 | Re-etiquetar Flora #9 a agente local | Flora |
| R1.10 | Resolver inconsistencia Ackbar | FFS Hub |
| R1.11 | Reescribir PR template (GDScript -> web) | FFS Hub |
| R1.12 | Mergear squad/172-governance-safeguards a main | FFS Hub |
| R1.13 | Actualizar SQUAD_AGENTS en vite.config.js | FFS Monitor |

### Fase R2 -- Importantes (antes de desatender) -- ~2.5h

| # | Que | Repo |
|---|-----|------|
| R2.1 | Archivar decisions.md (10.3KB -> <5KB) + fix duplicado | FFS Hub |
| R2.2 | Summarizar Solo/Jango/Ackbar history.md -> <12KB | FFS Hub |
| R2.3 | Limpiar ceremonies.md refs Godot | FFS Hub |
| R2.4 | Limpiar CONTRIBUTING.md (12+ refs stale) | FFS Hub |
| R2.5 | Debug workflows fallando | FFS Hub |
| R2.6 | Crear copilot-instructions.md | ComeRosquillas + FFS Monitor |
| R2.7 | Crear labels tier:t0-t3 | Todos repos |
| R2.8 | Archivar 4 skills stale | FFS Hub |
| R2.9 | Fix registry.json (Boba + 3 missing) | FFS Hub |
| R2.10 | Re-habilitar heartbeat cron | ComeRosquillas |
| R2.11 | Sync sync-squad-labels.yml | ComeRosquillas |
| R2.12 | Limpiar .gitignore + .editorconfig | FFS Hub |
| R2.13 | Flora GDD.md sign-off -> Oak | Flora |

### Fase R3 -- Limpieza + Decisiones estrategicas

| # | Que | Repo |
|---|-----|------|
| R3.1 | Mergear/cerrar squad/13-real-data | FFS Monitor |
| R3.2 | Limpiar 27 stashes | FFS Hub |
| R3.3 | Limpiar branches sin mergear (20+) | Todos repos |
| R3.4 | Issue Source en team.md | ComeRosquillas, FFS Monitor |
| R3.5 | Regenerar squad.labels.json | FFS Hub |
| R3.6 | Limpiar labels Star Wars obsoletos | Flora, ComeRosquillas |
| R3.7 | DECISION: mover ComeRosquillas fuera de games/ | FFS Hub -- Founder |
| R3.8 | Si R3.7 si -> eliminar games/** de squad.config.ts | FFS Hub |
| R3.9 | Eliminar games/ComeRosquillas/docs/ duplicado | FFS Hub |
| R3.10 | Renombrar master -> main | FFS Monitor |
| R3.11 | Eliminar games/ashfall de CODEOWNERS | FFS Hub |

---

Generado por Squad Coordinator -- 5 rondas diagnosticas (12 agentes + verificacion manual).
Fuentes: optimization-plan-review + optimization-plan-check (Solo) + deep-dive rounds 2-4.
Ultima verificacion: 2026-03-12T14:20Z.
