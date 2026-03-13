# Quality Gates & Definition of Done — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-12  
---

## 1. Quality Gates
Every deliverable must pass the relevant gate(s) before it is accepted. Gates are cumulative — a gameplay feature touches Code, Design, and Integration gates. A gate failure **blocks merge**.
---
### 🌐 Web Code Quality Gate
| # | Requirement | Rationale |
| WC1 | **Browser console: zero errors, zero 404s** | No `console.error()`, no failed asset loads, no CORS warnings. Inspect in DevTools on main browsers (Chrome, Firefox, Safari). |
| WC2 | **Event flow audit passed** | Every event listener has a removal path. No memory leaks from dangling listeners. Event bus wired correctly. |
| WC3 | **All imports/dependencies resolve** | All `import` statements, asset paths, and module references resolve. No 404s in network tab. |
---
---
---
---
---

## 2. Definition of Done
A deliverable is **DONE** when all applicable items are checked:
- [ ] **Runs without errors** — Code builds, game launches, feature works as specified. Browser console shows zero errors/404s.
### When is something NOT done?
---

## 3. Bug Severity Matrix
| Severity | Definition | Examples | Ship Blocker? | Response |
|----------|-----------|----------|---------------|----------|
| 🔴 **CRITICAL** | Game unplayable or player stuck | Crash on load, infinite loop, player frozen, enemies never attack | ✅ BLOCKS SHIP | Drop everything, fix immediately |
| 🟠 **HIGH** | Core mechanic broken | Combat doesn't register hits, audio crashes, score not saved | ✅ BLOCKS SHIP | Fix within same session |
| 🟡 **MEDIUM** | Feature degraded but game playable | Animation glitch, HUD element misaligned, one enemy type broken | ⚠️ SHIP WITH KNOWN ISSUE | Fix in next sprint |
| 🟢 **LOW** | Minor polish issue | Slight hitbox mismatch, animation stiffness, minor audio pop | ❌ DOES NOT BLOCK | Backlog |
---

## 4. Review Process
### Code Review (Pre-Merge)
| Step | Who | What |
| 1 | Author | Creates branch, implements change, self-tests in browser |
| 2 | Cross-reviewer | Reads diff, traces event flow, checks gate WC1-WC8 (or TS1-TS5 for TypeScript) |
| 3 | QA | Runs smoke test + regression checklist, verifies no console errors/404s |
| 4 | Solo (if shared systems) | Architecture review for event bus, global state, canvas changes |
---

## 5. Playtest Protocols
### Quick Smoke Test (2 min — every change)
- [ ] Game loads in browser without errors
### Full Playtest (10 min — every milestone)
### Adversarial Playtest (15 min — before ship)
---