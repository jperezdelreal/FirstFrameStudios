# QA Review: ffs-squad-monitor PRs #6 and #7

**Author:** Ackbar (QA/Playtester)  
**Date:** 2026-03-11  
**Status:** Proposed  
**Scope:** ffs-squad-monitor — affects Jango and Wedge

## Decisions

### 1. innerHTML Sanitization Standard
All `innerHTML` assignments that interpolate data should use `escapeHtml()`, even for server-controlled data. PR #7 is inconsistent — `repos.js` escapes, `heartbeat.js`/`log-viewer.js`/`timeline.js` don't. This should be a studio-wide coding standard for any web-facing project.

### 2. PR Merge Order: #6 before #7
PR #6 (Heartbeat Reader) should merge first. PR #7 (Dashboard UI) rewrites `monitor.js` completely and moves heartbeat rendering to `components/heartbeat.js`. After PR #7 merges, someone must add `offline: 'gray'` to the statusMap in `components/heartbeat.js` to preserve PR #6's offline status feature.

### 3. Both PRs Approved for Merge
- PR #6: Clean approval, no blocking issues
- PR #7: Approved with non-blocking notes (sanitization consistency, log viewer cache comment, EOF newline)

**Impact:** Jango and Wedge should coordinate merge order. The sanitization note applies to all future monitor dashboard work.

**Why:** Cross-PR coordination prevents broken features. Sanitization consistency prevents future XSS vectors if data sources ever change (e.g., external API data, user-submitted repo names).
