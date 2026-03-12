# FFS Optimization Plan Review — Pre-Flight Diagnostic

> Diagnóstico completo de los 4 repos antes de habilitar Ralph Watch autónomo.
> Fecha: 2026-03-12 | Solicitado por: José (Founder)
> Contexto: Las 33 mejoras del optimization-plan.md están implementadas (✅ Done).
> Objetivo: ¿Estamos listos para Ralph Watch autónomo?

---

## Veredicto Ejecutivo

**❌ NO LANZAR RALPH WATCH AUTÓNOMO TODAVÍA.**

El hub está en buen estado (95% health), pero hay problemas cruzados que harían que Ralph entre en un loop de fallos:

| Dimensión | Estado | Bloqueante |
|-----------|--------|------------|
| Hub (.squad/) | 🟢 Saludable con warnings | No |
| ComeRosquillas | 🟢 Listo | No |
| Flora | 🔴 Merge conflict bloquea build | **Sí** |
| FFS Monitor | 🟡 Sin workflows ni labels | **Sí** |
| Labels cross-repo | 🔴 Inconsistentes | **Sí** |
| Ralph-watch logs | 🔴 96% failure rate | **Sí** |
| Issues hub sin labels | 🔴 Invisibles para Ralph | **Sí** |

**Estimación para estar listo:** ~2-3 horas de trabajo (ver Fase de Remediación).

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
| H2 | Solo `history.md` 33.5KB (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H3 | Jango `history.md` 33.1KB (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H4 | CODEOWNERS referencia `games/ashfall/` | Cosmético | Eliminar línea |

### ❌ Problemas

| # | Hallazgo | Impacto | Bloqueante |
|---|----------|---------|------------|
| H5 | Issues #187, #188, #189 sin labels | Ralph no los ve | **Sí** |

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
| C1 | Sin `copilot-instructions.md` | @copilot sin contexto local | Crear |
| C2 | Labels heredados de Star Wars (squad:chewie, etc.) | Cosmético, no rompe nada | Limpiar labels obsoletos |
| C3 | Sin `blocked-by:*` labels | Ralph no detecta dependencias | Crear labels |
| C4 | Sin `.github/squad.labels.json` | Labels ya existen en GitHub, pero no hay definición local | Crear fichero |

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
| F1 | `upstream.json` `last_synced: null` | Nunca sincronizado con hub | Ejecutar sync |
| F2 | Historiales vacíos (98 bytes, solo stub) | No hay learnings | Se poblará naturalmente |
| F3 | `decisions.md` vacío | Normal para squad nuevo | — |
| F4 | Sin directorio `.squad/skills/` | Hereda del hub | Crear si necesario |
| F5 | Labels GitHub son Star Wars pero equipo es Pokémon | Ralph no puede asignar al equipo local | **Crear labels Pokémon** |
| F6 | Falta label `P3` | Prioridad incompleta | Crear |
| F7 | Sin `blocked-by:*` labels | Ralph no detecta dependencias | Crear |
| F8 | Sin `copilot-instructions.md` | @copilot sin contexto | Crear |
| F9 | `bitECS` en team.md pero no en package.json | Confusión de stack | Limpiar referencia o instalar |

### ❌ Problemas

| # | Hallazgo | Impacto | Bloqueante |
|---|----------|---------|------------|
| F10 | **Merge conflict en `GardenScene.ts`** | Build roto, no compila | **Sí** |
| F11 | Sin squad-* workflows desplegados | No hay CI, triage, ni labels automáticos | **Sí** |

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
| M2 | Sin `copilot-instructions.md` | @copilot sin contexto | Crear |

### ❌ Problemas

| # | Hallazgo | Impacto | Bloqueante |
|---|----------|---------|------------|
| M3 | **Sin workflows en `.github/workflows/`** | No hay CI, triage, labels, heartbeat | **Sí** |
| M4 | **Solo 2 squad labels** (squad:jango, squad:wedge) — del equipo anterior | Ralph no puede asignar a Ripley/Dallas/Lambert/Kane | **Sí** |
| M5 | Faltan labels P0, P3 | Prioridades incompletas | **Sí** |
| M6 | Sin `blocked-by:*` labels | Sin tracking de dependencias | Sí (menor) |

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

### ❌ Estado de ejecución (0/10)

**Datos del log `ralph-2026-03-12.jsonl`:**

```
Total entries:    162
FAIL:             156 (96.3%)
OK:                 5 (3.1%)
MODE_CHANGE:        1 (0.6%)
Consecutive fails: 170+
```

- **Todos los fallos**: exit code 1, sin `errorDetail` capturado
- **Sin mecanismo de circuit breaker**: sigue en loop infinito de fallos
- **Causa probable**: Copilot CLI failing silently (auth, network, o prompt issue)

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

**Impacto**: Ralph no puede hacer triage correcto en Flora ni FFS Monitor. ComeRosquillas funciona pero sin dependency tracking.

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
| R1.4 | Crear labels squad:{member} para equipo local (Oak, Brock, Erika, Misty, Sabrina) | Flora | 10 min |
| R1.5 | Crear labels squad:{member} para equipo local (Ripley, Dallas, Lambert, Kane) | FFS Monitor | 10 min |
| R1.6 | Crear labels P0, P3 donde falten | Flora + FFS Monitor | 5 min |
| R1.7 | Crear labels `blocked-by:*` (5 tipos) | ComeRosquillas, Flora, FFS Monitor | 10 min |
| R1.8 | Etiquetar issues #187, #188, #189 con squad + squad:{member} + P-level | FFS Hub | 5 min |
| R1.9 | Diagnosticar por qué Copilot CLI falla (exit code 1) en ralph-watch | FFS Hub | 30 min |
| R1.10 | Añadir captura de stderr en ralph-watch logs | FFS Hub | 15 min |

**Total Fase R1: ~2 horas**

### Fase R2 — Importantes (hacer antes de dejar Ralph desatendido)

| # | Qué | Repo | Esfuerzo |
|---|-----|------|----------|
| R2.1 | Summarizar Solo history.md (33.5KB → <12KB) | FFS Hub | 20 min |
| R2.2 | Summarizar Jango history.md (33.1KB → <12KB) | FFS Hub | 20 min |
| R2.3 | Archivar decisions.md (8KB → <5KB) | FFS Hub | 10 min |
| R2.4 | Upstream sync (last_synced: null) | Flora | 10 min |
| R2.5 | Upstream sync (last_synced: null) | FFS Monitor | 10 min |
| R2.6 | Añadir circuit breaker a ralph-watch (parar tras 50 fallos consecutivos) | FFS Hub | 30 min |
| R2.7 | Crear `copilot-instructions.md` | ComeRosquillas, Flora, FFS Monitor | 15 min |

**Total Fase R2: ~2 horas**

### Fase R3 — Limpieza (nice-to-have)

| # | Qué | Repo | Esfuerzo |
|---|-----|------|----------|
| R3.1 | Limpiar labels Star Wars obsoletos | Flora | 5 min |
| R3.2 | Limpiar labels Star Wars heredados | ComeRosquillas | 5 min |
| R3.3 | Eliminar `games/ashfall/` de CODEOWNERS | FFS Hub | 2 min |
| R3.4 | Limpiar referencia bitECS de team.md (o instalar) | Flora | 5 min |
| R3.5 | Crear `.github/squad.labels.json` | ComeRosquillas | 5 min |

---

## Checklist Pre-Launch Ralph Watch

```
FASE R1 (BLOQUEANTE):
[ ] Flora: merge conflict resuelto, build pasa
[ ] Flora: squad workflows desplegados
[ ] FFS Monitor: squad workflows desplegados
[ ] Flora: labels squad:{oak,brock,erika,misty,sabrina} creados
[ ] FFS Monitor: labels squad:{ripley,dallas,lambert,kane} creados
[ ] Todos repos: labels P0-P3 completos
[ ] Todos repos: labels blocked-by:* creados
[ ] Hub: issues #187-189 etiquetados
[ ] Ralph-watch: copilot CLI funciona (exit code 0)
[ ] Ralph-watch: stderr capturado en logs

FASE R2 (ANTES DE DESATENDER):
[ ] Hub: Solo history <12KB
[ ] Hub: Jango history <12KB
[ ] Hub: decisions.md <5KB
[ ] Flora: upstream sincronizado
[ ] FFS Monitor: upstream sincronizado
[ ] Ralph-watch: circuit breaker implementado
[ ] Todos repos: copilot-instructions.md presente

POST-LAUNCH:
[ ] Ejecutar ralph-watch -DryRun -MaxRounds 3 (validar)
[ ] Ejecutar ralph-watch -MaxRounds 5 (real, supervisado)
[ ] Dejar ralph-watch autónomo en night mode
```

---

## Comparación: Estado Post-Optimization vs Ahora

| Métrica | Post-Optimization | Estado Actual | Veredicto |
|---------|-------------------|---------------|-----------|
| decisions.md | 3.8KB ✅ | 8KB ⚠️ | Necesita archive |
| Skills < 5KB | ✅ | ✅ | Mantenido |
| Agentes hub | 3 activos ✅ | 4 activos (+ Ackbar) | OK |
| Ceremonies | 1 auto-triggered ✅ | ✅ | Mantenido |
| Context per spawn | ~400-600 líneas | ⚠️ Histories inflados | Necesita summarize |
| GitHub Actions runs/mes | ~900 ✅ | ✅ | Mantenido (crons ≥1h) |
| Downstream repos funcionales | 3/3 ✅ | 1/3 ❌ | Flora roto, Monitor sin infra |

---

*Generado automáticamente por Squad Coordinator — diagnóstico de 5 agentes en paralelo.*
