# 📑 Index & Navigation Guide

Welcome to the FirstFrameStudios Error Handling Implementation!

This document helps you navigate all the files and understand what each one does.

## 📚 Where to Start

**New to the project?** Start here:
1. **Read:** `README.md` - Complete overview
2. **Review:** `BACKEND_CHECKLIST.md` - API requirements
3. **Open:** `index.html` - See it in action
4. **Implement:** Backend endpoints
5. **Customize:** Adjust colors and timeouts

## 📂 File Organization

### Core Library Files
These are the foundation of the error handling system:

```
src/lib/
├── api.js                 # API layer with connection state
└── error-boundary.js      # Global error catcher
```

**When to use:**
- `api.js` - Making API calls, checking connection state, subscribing to changes
- `error-boundary.js` - Catching uncaught errors, accessing error history

### Component Files
These are the UI components that display data and handle errors:

```
src/components/
├── connection-status.js   # Shows network status (green/yellow/red)
├── heartbeat.js           # System health check every 30s
├── timeline.js            # Activity timeline every 5s
├── log-viewer.js          # SSE logs with auto-reconnect
├── cross-repo-board.js    # Repository dashboard every 10s
├── studio-pulse.js        # Studio metrics every 15s
└── agent-activity.js      # Agent tracking every 3s
```

**Component refresh rates:**
- `agent-activity.js` - 3 seconds (most frequent)
- `timeline.js` - 5 seconds
- `cross-repo-board.js` - 10 seconds
- `studio-pulse.js` - 15 seconds
- `heartbeat.js` - 30 seconds (least frequent)
- `log-viewer.js` - Real-time (SSE)
- `connection-status.js` - Real-time (updates on API calls)

### Application Files

```
src/
├── monitor.js             # Main app - initializes all components
├── index.html             # Example HTML template
└── styles.css             # All styling (13 KB)
```

### Documentation

```
src/
├── README.md              # Start here - full architecture
├── IMPLEMENTATION.md      # Quick reference guide
├── TROUBLESHOOTING.md     # Debug common issues
├── BACKEND_CHECKLIST.md   # API specifications
└── ARCHITECTURE.md        # System diagrams
```

## 🎯 Quick Answers

### "How do I make an API call?"
→ Use `src/lib/api.js`
```javascript
import { apiGet } from './src/lib/api.js';
const data = await apiGet('/api/endpoint');
```
See: `README.md` section "Usage"

### "How do I check the connection state?"
→ Use `src/lib/api.js`
```javascript
import { getConnectionState } from './src/lib/api.js';
const state = getConnectionState();  // 'operational', 'degraded', or 'offline'
```
See: `README.md` section "Connection State Tracking"

### "How do I subscribe to connection changes?"
→ Use `src/lib/api.js`
```javascript
import { onConnectionStateChange } from './src/lib/api.js';
const unsubscribe = onConnectionStateChange((state) => {
  console.log('Connection state:', state);
});
```
See: `README.md` section "Connection Status Component"

### "What API endpoints do I need?"
→ See `BACKEND_CHECKLIST.md`
1. GET /api/heartbeat
2. GET /api/timeline
3. GET /api/logs (SSE)
4. GET /api/cross-repo-board
5. GET /api/studio-pulse
6. GET /api/agent-activity

### "How do I test error handling?"
→ See `TROUBLESHOOTING.md` section "Testing Error Handling"
- Disable an endpoint
- Check browser console
- Verify error state appears
- Click retry button to recover

### "How do I customize the colors?"
→ Edit `src/styles.css`
Look for CSS variables at top:
```css
:root {
  --color-operational: #10b981;  /* Green */
  --color-degraded: #f59e0b;     /* Amber */
  --color-offline: #ef4444;      /* Red */
}
```
See: `styles.css` lines 1-10

### "How do I change refresh intervals?"
→ Edit component files (e.g., `src/components/heartbeat.js`)
Look for `setInterval(refresh, 30000);`
Change 30000 to desired milliseconds

### "How do I add authentication?"
→ Modify `src/lib/api.js`
Add auth headers to `fetchWithTimeout()`:
```javascript
headers: {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${token}`
}
```
See: `BACKEND_CHECKLIST.md` section "Security"

### "How do I send errors to a logging service?"
→ Modify `src/lib/api.js` and `src/lib/error-boundary.js`
Implement `window.__errorLog()`:
```javascript
window.__errorLog = (error) => {
  // Send to your logging service
  fetch('/api/log-error', { method: 'POST', body: JSON.stringify(error) });
};
```

## 📖 Documentation Index

### README.md
**What:** Complete architecture and usage guide
**Read when:** First time using the system
**Length:** 11 KB
**Contains:** Overview, components, patterns, API specs

### IMPLEMENTATION.md
**What:** Quick reference and pattern summary
**Read when:** Need quick lookup
**Length:** 11 KB
**Contains:** File listing, patterns, refresh rates, CSS classes

### TROUBLESHOOTING.md
**What:** Common issues and debug guide
**Read when:** Something isn't working
**Length:** 9 KB
**Contains:** 10+ issues, debug commands, fixes

### BACKEND_CHECKLIST.md
**What:** API endpoint specifications
**Read when:** Implementing backend
**Length:** 12 KB
**Contains:** Endpoint specs, examples, CORS, security

### ARCHITECTURE.md
**What:** System diagrams and data flow
**Read when:** Need to understand design
**Length:** 16 KB
**Contains:** Diagrams, flows, timelines, dependencies

## 🔗 File Dependencies

```
index.html
    └─ monitor.js
        ├─ lib/api.js
        ├─ lib/error-boundary.js
        ├─ components/connection-status.js
        ├─ components/heartbeat.js
        ├─ components/timeline.js
        ├─ components/log-viewer.js
        ├─ components/cross-repo-board.js
        ├─ components/studio-pulse.js
        ├─ components/agent-activity.js
        └─ styles.css
```

## 🎯 Common Tasks

### Task: Implement a new component
1. Create file in `src/components/`
2. Use pattern from `src/components/heartbeat.js`
3. Import in `src/monitor.js`
4. Add HTML element to `src/index.html`
5. Add styles to `src/styles.css`
6. Test error state

### Task: Add a new API endpoint
1. Create backend endpoint
2. Update `src/lib/api.js` if special handling needed
3. Create component or integrate into existing
4. Test with `src/index.html`

### Task: Debug connection issues
1. Open browser DevTools → Network tab
2. Look for `CORS` or failed requests
3. Check `CORS` headers in backend
4. See `TROUBLESHOOTING.md` section "CORS Errors"

### Task: Optimize performance
1. Reduce refresh intervals in components
2. Reduce log history in `src/components/log-viewer.js`
3. Reduce error history in `src/lib/error-boundary.js`
4. See `TROUBLESHOOTING.md` section "Performance Optimization"

### Task: Customize styling
1. Edit `src/styles.css`
2. Update CSS variables at top
3. Modify component classes
4. Test on different screen sizes

## 📊 Component Reference

| Component | File | Interval | Error State | Type |
|-----------|------|----------|-------------|------|
| Connection Status | connection-status.js | Real-time | N/A | Indicator |
| Heartbeat | heartbeat.js | 30s | Retry | Poll |
| Timeline | timeline.js | 5s | Retry | Poll |
| Cross-Repo Board | cross-repo-board.js | 10s | Retry | Poll |
| Studio Pulse | studio-pulse.js | 15s | Graceful | Poll |
| Agent Activity | agent-activity.js | 3s | Retry | Poll |
| Log Viewer | log-viewer.js | Real-time | Auto-Retry | SSE |

## 🔌 API Endpoint Reference

| Endpoint | Method | Interval | Response |
|----------|--------|----------|----------|
| /api/heartbeat | GET | 30s | { uptime, status } |
| /api/timeline | GET | 5s | { events: [...] } |
| /api/logs | GET (SSE) | Real-time | data: {...}\n\n |
| /api/cross-repo-board | GET | 10s | { repositories: [...] } |
| /api/studio-pulse | GET | 15s | { agents, operations, status } |
| /api/agent-activity | GET | 3s | { agents: [...] } |

See `BACKEND_CHECKLIST.md` for full specifications.

## ⚡ Error Handling Quick Reference

### Error States
- **Operational** (🟢) - All systems working
- **Degraded** (🟡) - Issues but functional
- **Offline** (🔴) - No connectivity

### Retry Types
- **Manual** - Click button to retry
- **Auto (Backoff)** - Exponential backoff: 1s→30s
- **Graceful** - Silent auto-retry

### Global Retry Functions
```javascript
window.__retryHeartbeat()
window.__retryTimeline()
window.__retryCrossRepoBoard()
window.__retryAgentActivity()
```

### Error Access
```javascript
import { errorBoundary } from './src/lib/error-boundary.js';
errorBoundary.getErrors();     // All errors
errorBoundary.getLastError();  // Last error
errorBoundary.clearErrors();   // Clear history
```

## 🚀 Deployment Checklist

- [ ] Review README.md
- [ ] Implement 6 backend endpoints
- [ ] Set CORS headers
- [ ] Test all components
- [ ] Test error states
- [ ] Customize colors/timeouts
- [ ] Set up error logging
- [ ] Test on mobile
- [ ] Deploy to production
- [ ] Monitor error logs

## 📞 Support

### Can't find something?
1. Check this index
2. Search in `TROUBLESHOOTING.md`
3. Check `README.md` table of contents
4. Look at code comments

### Something not working?
1. Check browser console for errors
2. Check Network tab for API calls
3. Review `TROUBLESHOOTING.md`
4. Check `BACKEND_CHECKLIST.md` for API format

### Want to modify something?
1. Find the component/file
2. Review code comments
3. Check documentation
4. Make changes
5. Test thoroughly

---

**Last Updated:** 2024
**Total Files:** 18
**Total Size:** 115 KB
**Status:** ✅ Complete and ready for use

Happy coding! 🎉
