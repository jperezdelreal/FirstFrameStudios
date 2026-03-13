# FFS Optimization Plan Review — Pre-Flight Diagnostic

> Compressed from 29KB. Full: optimization-plan-review-raw-archive.md

> Diagnóstico completo de los 4 repos antes de habilitar Ralph Watch autónomo.
> Fecha: 2026-03-12 | Solicitado por: José (Founder)
---

## Veredicto Ejecutivo
**🟡 LISTO CON CAVEATS — necesita higiene antes de lanzar.**
Ralph-watch funciona correctamente (dry-run verificado). Los fallos en logs (96%) son históricos, previos a la optimización. El script actual pasa el dry-run, filtra governance, hace upstream sync, y selecciona issues correctamente.
| Dimensión | Estado | Bloqueante |
| Hub (.squad/) | 🟢 Saludable con warnings | No |
| ComeRosquillas | 🟢 Listo | No |
| Flora | 🔴 Merge conflict + labels equivocados | **Sí** |
| FFS Monitor | 🟡 Labels incompletos | **Sí** |
| Labels cross-repo | 🔴 Inconsistentes | **Sí** |
---

## 1. FFS Hub (FirstFrameStudios)
### ✅ Lo que está bien (19/20 checks)
- Governance T0-T3 completa (17.9 KB, Constitution-grade)
### ⚠️ Warnings
| # | Hallazgo | Impacto | Acción |
| H1 | `decisions.md` a 8KB (límite G1: 5KB) | Spawn tokens extra | Archivar entries >14 días |
| H2 | Solo `history.md` **35.9KB** (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H3 | Jango `history.md` **33.9KB** (límite: 12KB) | Spawn tokens extra | Scribe summarize |
| H4 | Ackbar `history.md` **13.1KB** (límite: 12KB) | Spawn tokens extra | Scribe summarize |
---

## 2. ComeRosquillas
### ✅ Lo que está bien
- `## Members` header correcto — 5 agentes (Moe, Barney, Lenny, Nelson, Scribe)
### ⚠️ Warnings
| # | Hallazgo | Impacto | Acción |
| C1 | Sin `copilot-instructions.md` (ni en `.github/` ni en `.squad/`) | @copilot sin contexto local | Crear en `.github/` |
| C2 | Labels heredados de Star Wars (squad:chewie, solo, jango, etc.) | Cosmético, no rompe nada | Limpiar labels obsoletos |
| C3 | Sin `blocked-by:*` labels | Ralph no detecta dependencias | Crear labels |
| C4 | Sin `.github/squad.labels.json` | Labels ya existen en GitHub, pero no hay definición local | Crear fichero |
---

## 3. Flora
### ✅ Lo que está bien
- `## Members` header correcto — 6 agentes (Oak, Brock, Erika, Misty, Sabrina, Scribe)
### ⚠️ Warnings
| # | Hallazgo | Impacto | Acción |
| F1 | `upstream.json` `last_synced: null` | Nunca sincronizado con hub | Primer ralph-watch run lo hará |
| F2 | Historiales vacíos (98 bytes, solo stub) | No hay learnings | Se poblará naturalmente |
| F3 | `decisions.md` vacío | Normal para squad nuevo | — |
| F4 | Sin directorio `.squad/skills/` | Hereda del hub | Crear si necesario |
---

## 4. FFS Squad Monitor
### ✅ Lo que está bien
- `## Members` header correcto — 5 agentes (Ripley, Dallas, Lambert, Kane, Scribe)
### ⚠️ Warnings
| # | Hallazgo | Impacto | Acción |
| M1 | `upstream.json` `last_synced: null` | Nunca sincronizado | Ejecutar sync |
| M2 | Sin `copilot-instructions.md` (ni `.github/` ni `.squad/`) | @copilot sin contexto | Crear |
| M3 | **En branch `squad/13-real-data`**, no en `master` | Divergido del default branch | Mergear o cerrar |
| # | Hallazgo | Impacto | Bloqueante |
---

## 5. Ralph-watch.ps1 — Estado Operativo
### ✅ Arquitectura del script (9/10)
| Feature | Estado |
| Multi-repo (4 repos) | ✅ |
| `## Members` header check | ✅ |
| Upstream sync antes de cada repo (G11) | ✅ |
| Governance tier filtering (skip T0/T1) | ✅ |
| Git remote URL validation | ✅ |
| Night/day mode auto-detection | ✅ |
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
---

## Plan de Remediación
### Fase R1 — Bloqueantes (hacer ANTES de Ralph Watch)
| # | Qué | Repo | Esfuerzo |
| R1.1 | Resolver merge conflict `GardenScene.ts` | Flora | 15 min |
| R1.2 | Desplegar squad workflows a `.github/workflows/` | Flora | 15 min |
| R1.3 | Desplegar squad workflows a `.github/workflows/` | FFS Monitor | 15 min |
| R1.4 | Crear labels squad:{oak,brock,erika,misty,sabrina} | Flora | 10 min |
| R1.5 | Crear labels squad:{ripley,dallas,lambert,kane} | FFS Monitor | 10 min |
| R1.6 | Crear labels P3 (Flora) + P0,P3 (FFS Monitor) | Flora + FFS Monitor | 5 min |
---

## Checklist Pre-Launch Ralph Watch (DEFINITIVO — actualizado con datos frescos)
```
FASE R1 (BLOQUEANTE — no lanzar sin completar):
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
---

## 8. Hallazgos adicionales (deep-dive round 2)
Hallazgos descubiertos en la segunda ronda de exploración que ninguno de los diagnósticos anteriores detectó.
### 🔴 Ackbar — Inconsistencia de roster (CRÍTICO)
| Fuente | Status Ackbar |
| `.squad/team.md` `## Members` | ❌ **AUSENTE** |
| `.squad/casting/registry.json` | ✅ `"status": "active"` |
| `.squad/agents/ackbar/charter.md` | ✅ Existe (en agents/, no en _alumni/) |
| `.squad/routing.md` | ✅ Referenciado (smoke test) |
| `.squad/ceremonies.md` | ✅ Referenciado (Integration Gate, Godot Smoke Test) |
# DISABLED: Cron heartbeat commented out pre-migration

> Compressed from 29KB. Full: optimization-plan-review-raw-archive.md

# schedule:

> Compressed from 29KB. Full: optimization-plan-review-raw-archive.md

#   - cron: '*/30 * * * *'

> Compressed from 29KB. Full: optimization-plan-review-raw-archive.md

---

## 9. Hallazgos finales (sweep exhaustivo de stale refs)
### 🔴 ffs-squad-monitor: SQUAD_AGENTS hardcodeado en vite.config.js (CRITICO)
El dashboard tiene `SQUAD_AGENTS` en `vite.config.js:17-30` con los 12 agentes Star Wars del hub antiguo. Parsea logs y renderiza UI con nombres que no existen en ningun subsquad actual. Ningun agente Simpsons/Pokemon/Alien aparece.
### 🟡 Flora GDD.md referencia agentes hub
### 🟡 Hub structural remnants
| Hallazgo | Fichero | Impacto |
| .gitignore tiene patrones Godot | `.gitignore:4-7` | Bajo |
| .editorconfig tiene `[*.gd]` | `.editorconfig:18-20` | Bajo |
| `games/` con ComeRosquillas dentro del hub | `games/ComeRosquillas/` | Medio -- viola modelo hub |
---

## Plan de Remediacion DEFINITIVO
### Fase R1 -- Bloqueantes (ANTES de Ralph Watch) -- ~2h
| # | Que | Repo |
| R1.1 | Resolver merge conflict GardenScene.ts | Flora |
| R1.2 | Desplegar squad workflows | Flora |
| R1.3 | Desplegar squad workflows | FFS Monitor |
| R1.4 | Crear labels squad:{oak,brock,erika,misty,sabrina} | Flora |
| R1.5 | Crear labels squad:{ripley,dallas,lambert,kane} | FFS Monitor |
| R1.6 | Crear labels P3 (Flora) + P0,P3 (FFS Monitor) | Flora + FFS Monitor |
---