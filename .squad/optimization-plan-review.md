# Pre-Autonomy Review — Ralph Watch Readiness

> Fecha: 2026-03-12 | Solicitado por: Jose (Founder)
> Fuentes: 5 rondas diagnosticas (12 agentes) + diagnostico Solo (dry-run) + verificacion manual
> Contexto: 33 mejoras del optimization-plan.md implementadas. Este documento evalua si estamos listos para Ralph Watch autonomo.

---

## Veredicto

**LISTO CON CAVEATS.** Ralph-watch funciona (dry-run verificado por Solo). Los bloqueantes son de higiene: labels incorrectos, workflows no desplegados, refs Godot en config activos.

```
Dry-run exitoso:
  [ralph] Ralph Watch v3 - First Frame Studios (Night/Day Mode)
  Mode: day | DryRun: YES | MaxRounds: 1
  [sync] Hub -> 3 downstream: all up to date
  [sched] Hub #189,#188,#187: SKIPPED (needs-research)
  [sched] Flora #9: SELECTED (P1, squad:wedge)
  Round 1 complete (4.5s)
```

---

## 1. Hub (FirstFrameStudios)

**Branch:** `squad/172-governance-safeguards` (necesita merge a main)

| Area | Estado | Detalle |
|------|--------|---------|
| Governance T0-T3 | OK | Completa, 17.9KB |
| Identity (10 files) | OK | Todos presentes, now.md actualizado |
| Charters activos | OK | Solo, Jango, Mace, Scribe, Ackbar |
| Skills (43 dirs) | WARN | 4 skills Godot no archivadas |
| Casting registry | WARN | Boba="active" pero en _alumni; Nien/Leia/Bossk no en registry |
| Workflows (24) | FAIL | ralph-heartbeat-notify y pr-body-check fallando |
| squad.agent.md | OK | v0.8.25, identico en 4 repos (MD5: B789E063) |
| Copilot-instructions | OK | 3.8KB, sin refs stale |
| Ralph-watch.ps1 | OK | Multi-repo, governance-aware, dry-run pasa |

**Ficheros sobre limites:**

| Fichero | Tamano | Limite | Accion |
|---------|--------|--------|--------|
| decisions.md | 10.3KB | 5KB (G1) | Archivar + fix duplicado P0-P3 |
| solo/history.md | 35.9KB | 12KB | Summarizar |
| jango/history.md | 33.9KB | 12KB | Summarizar |
| ackbar/history.md | 13.1KB | 12KB | Summarizar |

**Ackbar inconsistencia:**

| Fuente | Status |
|--------|--------|
| team.md Members | AUSENTE |
| registry.json | "active" |
| charter.md | Existe (en agents/, no _alumni) |
| routing.md + ceremonies.md | Referenciado |

Decision necesaria: add a Members o hibernate.

**Stale Godot/Ashfall en ficheros ACTIVOS:**

| Fichero | Refs | Impacto |
|---------|------|---------|
| .github/pull_request_template.md | 5/5 checkboxes GDScript | ALTO -- cada PR lo muestra |
| ceremonies.md | Integration Gate + Godot Smoke Test | ALTO -- agentes las leen |
| CONTRIBUTING.md | 12+ refs (labels, ejemplos, style guides) | ALTO -- onboarding |
| .gitignore | .godot/, *.import, *.uid | BAJO -- vestigial |
| .editorconfig | [*.gd] section | BAJO -- vestigial |
| CODEOWNERS | games/ashfall/ | BAJO -- path no existe |

Refs en archivos pasivos (analysis/, _alumni/, skills/_archived/, decisions-archive.md, blog) estan correctamente aislados -- NO TOCAR.

**Issues abiertos completados:**

| # | Titulo | Labels | Accion |
|---|--------|--------|--------|
| 189 | Design priority system P0-P3 | squad:solo, go:needs-research | CERRAR |
| 188 | Phase 6: Implement guardrails G1-G14 | squad:solo, squad:ackbar | CERRAR |
| 187 | Phase 5: Reduce GitHub Actions cron | squad:jango, squad:wedge | CERRAR |

**Estructura legacy:** `games/ComeRosquillas/` dentro del hub (viola modelo hub declarado). `squad.config.ts` permite `games/**`. Decision founder pendiente.

---

## 2. ComeRosquillas

**Branch:** main (OK) | **Upstream synced:** 2026-07-24 (OK)

| Area | Estado |
|------|--------|
| Team (Moe,Barney,Lenny,Nelson) | OK |
| Charters, routing, ceremonies | OK |
| Squad workflows (11) | OK |
| Squad labels locales | OK (moe,barney,lenny,nelson,ralph) |
| Git state | Clean |

| Area | Estado | Accion |
|------|--------|--------|
| blocked-by labels | FALTAN | Crear 5 tipos |
| copilot-instructions.md | FALTA (.github/ y .squad/) | Crear |
| Heartbeat cron | DESHABILITADO (comentado) | Re-habilitar |
| sync-squad-labels.yml | Desincronizado (p lowercase, sin P3, sin blocked-by) | Sync con hub |
| Labels Star Wars heredados | squad:chewie,solo,jango etc. | Limpiar (cosmetic) |
| Upstream cache quality-gates.md | Refs Godot (hub source limpia) | Re-sync |

---

## 3. Flora

**Branch:** main (OK) | **Upstream synced:** NUNCA (null)

| Area | Estado |
|------|--------|
| Team (Oak,Brock,Erika,Misty,Sabrina) | OK |
| Charters, routing, ceremonies | OK |
| copilot-instructions.md | OK (.github/) |
| 35 ficheros TypeScript (juego real) | OK |
| Git state | Clean |

| Area | Estado | Accion |
|------|--------|--------|
| **Merge conflict GardenScene.ts** | BLOQUEANTE | Resolver |
| **0 squad workflows** | BLOQUEANTE | Desplegar desde templates |
| **Labels squad:{local}** | TODOS FALTAN (solo tiene Star Wars) | Crear oak,brock,erika,misty,sabrina |
| Label P3 | FALTA (tiene P0,P1,P2) | Crear |
| blocked-by labels | FALTAN | Crear 5 tipos |
| Issue #9 label | squad:wedge (agente hub hibernado) | Re-etiquetar a agente local |
| PR #18 | Sin labels | Etiquetar |
| GDD.md sign-off | "Solo reviews", "Jango plans" | Cambiar a Oak |
| Flora CI/deploy | Todas FAILURE (por merge conflict) | Se arregla con R1.1 |

---

## 4. FFS Squad Monitor

**Branch:** `squad/13-real-data` (necesita merge a master) | **Upstream synced:** NUNCA (null)
**Nota:** Usa `master` como default branch (otros repos usan `main`)

| Area | Estado |
|------|--------|
| Team (Ripley,Dallas,Lambert,Kane) | OK |
| Charters, routing, ceremonies | OK |
| Build Vite | OK (289ms, sin errores) |
| Git state | Clean |

| Area | Estado | Accion |
|------|--------|--------|
| **0 squad workflows** | BLOQUEANTE | Desplegar desde templates |
| **Labels squad:{local}** | TODOS FALTAN (solo tiene jango,wedge) | Crear ripley,dallas,lambert,kane |
| **SQUAD_AGENTS en vite.config.js** | CRITICO -- hardcoded Star Wars (12 agentes) | Actualizar con todos los squads |
| Labels P0, P3 | FALTAN (solo P1,P2) | Crear |
| blocked-by labels | FALTAN | Crear 5 tipos |
| copilot-instructions.md | FALTA | Crear |

---

## 5. Cross-Repo: Labels

| Label | Hub | ComeRosq | Flora | Monitor |
|-------|-----|----------|-------|---------|
| squad | OK | OK | OK | OK |
| squad:{local} | OK (13) | OK (4) | FALTAN 5 | FALTAN 4 |
| P0 | OK | OK | OK | FALTA |
| P1 | OK | OK | OK | OK |
| P2 | OK | OK | OK | OK |
| P3 | OK | OK | FALTA | FALTA |
| blocked-by:* | OK (5) | FALTAN | FALTAN | FALTAN |
| tier:t0-t3 | FALTAN | FALTAN | FALTAN | FALTAN |

## 6. Cross-Repo: Workflows

| Workflow | Hub | ComeRosq | Flora | Monitor |
|----------|-----|----------|-------|---------|
| squad-triage | OK | OK | FALTA | FALTA |
| squad-heartbeat | OK | OK (cron off) | FALTA | FALTA |
| squad-issue-assign | OK | OK | FALTA | FALTA |
| sync-squad-labels | OK | OK (desync) | FALTA | FALTA |
| squad-ci | OK | OK | FALTA | FALTA |

## 7. Casting Inconsistencies

| Agente | team.md | registry.json | Carpeta | Fix |
|--------|---------|---------------|---------|-----|
| Ackbar | AUSENTE | active | agents/ackbar/ | Decidir: add o hibernate |
| Boba | Hibernated | active | _alumni/ | registry -> retired |
| Nien | Hibernated | NO EXISTE | _alumni/ | Anadir como retired |
| Leia | Hibernated | NO EXISTE | _alumni/ | Anadir como retired |
| Bossk | Hibernated | NO EXISTE | _alumni/ | Anadir como retired |

---

## Plan de Remediacion

### R1 -- Bloqueantes (~2h)

| # | Que | Repo |
|---|-----|------|
| 1 | Mergear squad/172-governance-safeguards a main | Hub |
| 2 | Resolver merge conflict GardenScene.ts | Flora |
| 3 | Desplegar squad workflows | Flora |
| 4 | Desplegar squad workflows | Monitor |
| 5 | Crear labels squad:{oak,brock,erika,misty,sabrina} | Flora |
| 6 | Crear labels squad:{ripley,dallas,lambert,kane} | Monitor |
| 7 | Crear labels P3 (Flora) + P0,P3 (Monitor) | Flora+Monitor |
| 8 | Crear labels blocked-by:* (5 tipos) | ComeRosq+Flora+Monitor |
| 9 | Cerrar issues #187,#188,#189 | Hub |
| 10 | Re-etiquetar Flora #9 a agente local | Flora |
| 11 | Resolver inconsistencia Ackbar | Hub |
| 12 | Reescribir PR template (GDScript -> web) | Hub |
| 13 | Actualizar SQUAD_AGENTS en vite.config.js | Monitor |

### R2 -- Pre-desatender (~2.5h)

| # | Que | Repo |
|---|-----|------|
| 1 | Archivar decisions.md (10.3KB -> <5KB) + fix duplicado | Hub |
| 2 | Summarizar historiales Solo/Jango/Ackbar -> <12KB | Hub |
| 3 | Limpiar ceremonies.md (Godot Smoke Test + Integration Gate) | Hub |
| 4 | Limpiar CONTRIBUTING.md (12+ refs stale) | Hub |
| 5 | Debug workflows fallando (ralph-heartbeat-notify, pr-body-check) | Hub |
| 6 | Crear copilot-instructions.md | ComeRosq+Monitor |
| 7 | Crear labels tier:t0-t3 | Todos |
| 8 | Archivar 4 skills stale a _archived/ | Hub |
| 9 | Fix registry.json (Boba->retired, anadir Nien/Leia/Bossk) | Hub |
| 10 | Re-habilitar heartbeat cron | ComeRosq |
| 11 | Sync sync-squad-labels.yml con hub | ComeRosq |
| 12 | Limpiar .gitignore + .editorconfig (Godot patterns) | Hub |
| 13 | Flora GDD.md sign-off Solo/Jango -> Oak | Flora |

### R3 -- Limpieza

| # | Que | Repo |
|---|-----|------|
| 1 | Mergear/cerrar squad/13-real-data | Monitor |
| 2 | Limpiar 27 stashes | Hub |
| 3 | Limpiar branches sin mergear (20+) | Todos |
| 4 | Anadir Issue Source a team.md | ComeRosq+Monitor |
| 5 | Regenerar squad.labels.json | Hub |
| 6 | Limpiar labels Star Wars obsoletos | Flora+ComeRosq |
| 7 | DECISION: mover ComeRosquillas fuera de games/ | Hub (Founder) |
| 8 | Si R3.7 si: eliminar games/** de squad.config.ts | Hub |
| 9 | Eliminar games/ComeRosquillas/docs/ duplicado | Hub |
| 10 | Renombrar master -> main | Monitor |
| 11 | Eliminar games/ashfall de CODEOWNERS | Hub |

---

## Checklist

```
R1 (no lanzar sin completar):
[ ] Hub: merge branch a main
[ ] Hub: Ackbar decision
[ ] Hub: PR template rewrite
[ ] Hub: cerrar #187-189
[ ] Flora: merge conflict
[ ] Flora: workflows
[ ] Flora: labels locales + P3
[ ] Flora: re-etiquetar #9
[ ] Monitor: workflows
[ ] Monitor: labels locales + P0,P3
[ ] Monitor: SQUAD_AGENTS vite.config.js
[ ] Todos downstream: blocked-by labels

R2 (antes de dejar solo):
[ ] Hub: decisions.md <5KB
[ ] Hub: historiales <12KB
[ ] Hub: ceremonies.md limpio
[ ] Hub: CONTRIBUTING.md limpio
[ ] Hub: debug workflows
[ ] Hub: skills stale archived
[ ] Hub: registry.json fixed
[ ] Hub: .gitignore + .editorconfig
[ ] ComeRosq: heartbeat cron
[ ] ComeRosq: sync labels workflow
[ ] ComeRosq+Monitor: copilot-instructions
[ ] Flora: GDD.md sign-off
[ ] Todos: tier labels

Post-launch:
[ ] checkout main/master en repos divergidos
[ ] ralph-watch -DryRun -MaxRounds 1
[ ] ralph-watch -MaxRounds 3 (supervisado)
[ ] verificar heartbeat + upstream sync
[ ] night mode autonomo
```
