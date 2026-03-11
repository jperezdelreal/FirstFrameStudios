# Squad Monitor Dashboard — Component Architecture

**Author:** Wedge (UI/UX Developer)  
**Date:** 2025-07-24  
**Status:** Implemented  
**Scope:** ffs-squad-monitor project

## Decision

The squad monitor dashboard uses a component-based vanilla JS architecture without frameworks. Each UI section (heartbeat, log-viewer, repos, timeline, settings, connection-status) is an independent ES module under `src/components/`. Shared concerns (API calls, scheduling, utilities) live in `src/lib/`.

## Key Patterns

1. **Component contract:** Each component exports `refresh*()` (async, called by scheduler) and optionally `init*()` (called once for DOM event binding).
2. **Centralized API client** (`src/lib/api.js`): All fetch calls go through `safeFetch()`. Connectivity is tracked centrally; components subscribe via `onConnectionChange()`.
3. **Configurable Scheduler** (`src/lib/scheduler.js`): Manages polling intervals with `register()`, `setInterval()`, `pause()`, `resume()`. UI settings panel wired to scheduler.
4. **CSS custom properties** in `src/styles.css`: All colors, fonts, radii defined as `--tokens`. Dark theme matches GitHub aesthetic. No CSS framework.

## Why

- Vanilla JS keeps bundle small (8KB gzipped) and avoids framework lock-in for a dashboard that may be maintained by any agent.
- Component pattern provides clear ownership boundaries — each file is independently testable and replaceable.
- Scheduler abstraction means polling intervals are runtime-configurable without code changes.

## Impact

- Any agent adding new dashboard sections should follow the component pattern (export `refresh*` + `init*`, use `lib/api.js` for fetches).
- CSS changes should use existing custom properties, not hardcoded colors.
- The `master` branch is the default branch for this repo (not `main`).
