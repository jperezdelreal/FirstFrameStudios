# Quality Gates & Definition of Done — First Frame Studios

**Author:** Solo (Lead / Chief Architect)  
**Date:** 2026-03-12  
**Context:** Phase 2 — Rewritten for web games. Covers HTML/JS/Canvas and TypeScript/Vite/PixiJS stacks.  
**Applies to:** All deliverables in web game projects, effective this phase.

---

## 1. Quality Gates

Every deliverable must pass the relevant gate(s) before it is accepted. Gates are cumulative — a gameplay feature touches Code, Design, and Integration gates. A gate failure **blocks merge**.

---

### 🌐 Web Code Quality Gate

A code deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| WC1 | **Browser console: zero errors, zero 404s** | No `console.error()`, no failed asset loads, no CORS warnings. Inspect in DevTools on main browsers (Chrome, Firefox, Safari). |
| WC2 | **Event flow audit passed** | Every event listener has a removal path. No memory leaks from dangling listeners. Event bus wired correctly. |
| WC3 | **All imports/dependencies resolve** | All `import` statements, asset paths, and module references resolve. No 404s in network tab. |
| WC4 | **Tested in browser AND exported build** | Runs correctly in dev server AND in production build. Build output verified on staging/production domain. |
| WC5 | **No dead/orphaned code** | Every module, listener, and handler is wired to a consumer. No commented-out integration stubs. |
| WC6 | **Cross-reviewed by a second engineer** | Solo reviews anything touching event bus, global state, or canvas rendering. Peer reviews game logic. Separate code review from QA. |
| WC7 | **Web style conventions followed** | Naming (camelCase), module organization, ES6+ patterns, and async handling match project standards. |
| WC8 | **Responsive layout verified** | Game responds to viewport changes. Test on desktop (1920×1080), tablet (768×1024), and mobile (360×640). |

**Gate owner:** Solo (Lead) + cross-review engineer.

---

### 🎮 Canvas/JS Quality Gate

A canvas/rendering deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| CG1 | **Game loop maintains 60 FPS** | Measured on target device. Frame time ≤ 16.67ms. Use `requestAnimationFrame` timing or canvas FPS counter. |
| CG2 | **No memory leaks** | Heap snapshot shows stable memory after 5+ minutes of play. No orphaned canvas contexts. Textures/sprites released on unload. |
| CG3 | **Input responsive (keyboard + touch)** | Keyboard events fire instantly. Touch events register within 100ms. Multi-touch handled correctly. Test on actual device or emulator. |
| CG4 | **Canvas cleanup on unload** | Canvas context released, listeners removed, animation frame cancelled. No memory retained after game/scene transition. |
| CG5 | **Rendering correct across browsers** | WebGL contexts initialize correctly. Canvas scale and DPI handled. Test on Chrome, Firefox, Safari (desktop + mobile). |
| CG6 | **Asset management verified** | Images loaded, spritesheet frames calculated correctly. No texture bleeding or scaling artifacts. |

**Gate owner:** Solo (Lead) for architecture. QA for performance verification.

---

### 🔷 TypeScript Quality Gate (TS/Vite/PixiJS projects)

A TypeScript deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| TS1 | **Strict mode: zero type errors** | `tsconfig.json` has `strict: true`. No `any` without justification comment. No implicit `any`. Run `tsc --noEmit`. |
| TS2 | **All type imports/exports valid** | Imported types resolve. No circular dependencies. Exports match consumers. |
| TS3 | **No `any` without comment** | If `any` is unavoidable (third-party library without types), justify with `// @ts-ignore: {reason}`. |
| TS4 | **Build produces no warnings** | `npm run build` (or equivalent) emits zero TypeScript warnings. Vite build clean. |
| TS5 | **Type coverage documented** | New public APIs have JSDoc with `@param` and `@returns`. Complex logic has inline type guards explained. |

**Gate owner:** Solo (Lead). Build verification by CI.

---

### 🎨 Design Quality Gate

A design deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| D1 | **Aligns with GDD** | Feature serves the core loop. If not in GDD, needs lead approval. |
| D2 | **Player feel tested** | Playtested: does this feel good to play? Keyboard/touch response, visual feedback, audio cues. |
| D3 | **Difficulty tested** | Playtested at intended difficulty. Clear time, damage, deaths recorded. Metrics in target range. |
| D4 | **Difficulty curve maintained** | New content doesn't spike or dead-zone difficulty. Tested in sequence. |
| D5 | **Player feedback clear** | Player sees what happened (hit, damage, state change). Visual + audio cues present. |
| D6 | **No degenerate strategies** | Playtester attempts exploits. If one strategy dominates, redesign. |

**Gate owner:** Lead (Design). Playtesting by team.

---

### 🔗 Integration Quality Gate

An integration deliverable is accepted when ALL of the following are true:

| # | Requirement | Rationale |
|---|-------------|-----------|
| I1 | **No regressions** | Regression checklist passes. All previously working features still work. |
| I2 | **All systems wired** | New modules imported, event handlers registered, game state connected. No isolated subsystems. |
| I3 | **Performance budget met** | FPS ≥ 60, frame time ≤ 16.67ms. Bundle size ≤ target. Load time ≤ target. Tested on target device. |
| I4 | **Module imports correct** | All `import` statements resolve. No circular dependencies. Build tree-shakes unused code. |
| I5 | **Game loads in browser** | Fresh page load: asset loads, canvas renders, game starts. No console errors. |
| I6 | **Persistent state integrity** | If feature touches localStorage/sessionStorage: save, reload, verify state survived. |

**Gate owner:** Solo (Lead) for architecture. QA for regression and integration.

**Performance Budget Reference (Web):**

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| FPS | ≥ 60 | < 55 | < 45 |
| Frame time | ≤ 16.67ms | > 18ms | > 22ms |
| Bundle size (gzipped) | ≤ 500KB | > 600KB | > 800KB |
| Initial load time | ≤ 3s | > 4s | > 6s |
| Time to interactive | ≤ 2s | > 3s | > 5s |
| Memory (heap) | ≤ 150MB | > 200MB | > 300MB |

---

## 2. Definition of Done

A deliverable is **DONE** when all applicable items are checked:

- [ ] **Runs without errors** — Code builds, game launches, feature works as specified. Browser console shows zero errors/404s.
- [ ] **Cross-reviewed** — Reviewed by at least one other agent. Code review for code, design review for design.
- [ ] **QA tested** — Team has tested for functionality using regression checklist + smoke test.
- [ ] **Playtested for feel** — Tested by agent or human for game feel. "Does it feel good?" is separate from "does it work?"
- [ ] **No known regressions** — All previously passing tests/checks still pass. No existing features broken.
- [ ] **History.md updated** — Agent's history file updated with learnings, decisions, and outcomes.
- [ ] **Decision documented** — If an architectural, design, or process choice was made, it's logged in `decisions/` with context.
- [ ] **Quality gate(s) passed** — All applicable gates from Section 1 above have been satisfied.

### When is something NOT done?

A deliverable is **not done** if any of these are true, regardless of code completeness:
- It works in dev but hasn't been tested in production build
- It was self-reviewed only (author reviewed their own work)
- It creates memory leaks or listeners that aren't cleaned up
- It creates code that isn't wired to any consumer (dead module, orphaned handler)
- It changes difficulty but wasn't playtested for balance
- It touches shared systems (event bus, global state, canvas) without Solo's review
- It causes 404s or console errors in browser DevTools

---

## 3. Bug Severity Matrix

| Severity | Definition | Examples | Ship Blocker? | Response |
|----------|-----------|----------|---------------|----------|
| 🔴 **CRITICAL** | Game unplayable or player stuck | Crash on load, infinite loop, player frozen, enemies never attack | ✅ BLOCKS SHIP | Drop everything, fix immediately |
| 🟠 **HIGH** | Core mechanic broken | Combat doesn't register hits, audio crashes, score not saved | ✅ BLOCKS SHIP | Fix within same session |
| 🟡 **MEDIUM** | Feature degraded but game playable | Animation glitch, HUD element misaligned, one enemy type broken | ⚠️ SHIP WITH KNOWN ISSUE | Fix in next sprint |
| 🟢 **LOW** | Minor polish issue | Slight hitbox mismatch, animation stiffness, minor audio pop | ❌ DOES NOT BLOCK | Backlog |
| ⚪ **COSMETIC** | Visual-only, no gameplay impact | Pixel alignment, color shade, font weight | ❌ DOES NOT BLOCK | Backlog |

**Severity dispute rule:** If two agents disagree on severity, the higher rating wins. CRITICAL and HIGH bugs require unanimous "fixed" verdict from both reviewer and QA.

---

## 4. Review Process

### Code Review (Pre-Merge)

| Step | Who | What |
|------|-----|------|
| 1 | Author | Creates branch, implements change, self-tests in browser |
| 2 | Cross-reviewer | Reads diff, traces event flow, checks gate WC1-WC8 (or TS1-TS5 for TypeScript) |
| 3 | QA | Runs smoke test + regression checklist, verifies no console errors/404s |
| 4 | Solo (if shared systems) | Architecture review for event bus, global state, canvas changes |
| 5 | Merge | Only after all required approvals |

### Cross-Review Assignments

| Author | Reviewer | Scope |
|--------|----------|-------|
| Flora (TypeScript) | Solo (Lead) | TypeScript code, module structure, build |
| ComeRosquillas (Vanilla JS) | Solo (Lead) | Canvas rendering, event handling, input systems |
| Frontend/UI | Solo (Lead) | DOM/responsive layout, event listeners, cleanup |
| Game Logic | Solo (Lead) | Game loop, collision, difficulty, playtesting |
| Solo (Lead) | Flora + ComeRosquillas leads | Architecture, event bus, cross-game patterns |

**Principle:** No code merges without a second pair of eyes. The author's blind spot is the reviewer's opportunity.

---

## 5. Playtest Protocols

### Quick Smoke Test (2 min — every change)

- [ ] Game loads in browser without errors
- [ ] Canvas renders correctly
- [ ] Player can move with keyboard/touch
- [ ] Player can perform primary action (attack, interact, etc.)
- [ ] At least one game mechanic responds correctly
- [ ] Player takes damage/loses state and recovers
- [ ] No console errors or 404s in DevTools

### Full Playtest (10 min — every milestone)

- [ ] Complete all available content
- [ ] Record clear time, final score/state, deaths/failures
- [ ] Rate game feel/responsiveness (1-10, keyboard + touch)
- [ ] Rate difficulty (1-10)
- [ ] Note visual/audio glitches
- [ ] Test on at least 2 browsers (Chrome, Firefox, Safari)
- [ ] Run full regression checklist

### Adversarial Playtest (15 min — before ship)

- [ ] Spam every action type rapidly (keyboard + touch)
- [ ] Click/tap every interactive element
- [ ] Resize window during gameplay (test responsiveness)
- [ ] Pause/unpause game repeatedly
- [ ] Let game run for 5+ minutes (check for memory leaks)
- [ ] Attempt to overflow score, break collision, trigger exploits
- [ ] Test on real device (mobile, tablet) and emulator

---

*This document is a living standard. Update as the team learns. Every bug that slips through is a signal to strengthen a gate.*

*— Solo, Lead / Chief Architect, First Frame Studios*
