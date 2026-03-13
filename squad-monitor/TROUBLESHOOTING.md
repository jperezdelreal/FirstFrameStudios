# Troubleshooting Guide

## Common Issues and Solutions

### 1. Components Not Showing

**Symptom:** All components show "loading" indefinitely

**Possible Causes:**
- Backend API endpoints not running
- CORS issues preventing API calls
- Wrong endpoint URLs

**Solutions:**
```javascript
// Check if API is responding
import { apiGet } from './lib/api.js';
try {
  const data = await apiGet('/api/heartbeat');
  console.log('API working:', data);
} catch (error) {
  console.error('API error:', error);
}

// Check connection state
import { getConnectionState } from './lib/api.js';
console.log('Connection state:', getConnectionState());
```

### 2. Continuous Error States

**Symptom:** Components show error state repeatedly

**Possible Causes:**
- API endpoint returning `{ error: "message" }`
- API endpoint timing out (>10 seconds)
- API returning invalid JSON

**Solutions:**
```javascript
// Check error boundary errors
import { errorBoundary } from './lib/error-boundary.js';
console.log('Recent errors:', errorBoundary.getErrors());

// Check specific component logs
// Open browser console and look for [timestamp] error messages
```

### 3. Log Viewer Not Connecting

**Symptom:** Log viewer shows "Connection Error" or "Reconnecting..."

**Possible Causes:**
- SSE endpoint not available
- Server not sending proper SSE headers
- Max retries (10) reached

**Solutions:**
```javascript
// Check if SSE endpoint responds
fetch('/api/logs').then(r => {
  console.log('SSE endpoint headers:', r.headers);
  console.log('Content-Type:', r.headers.get('content-type'));
  // Should be 'text/event-stream'
});

// Verify SSE format: data: {"message": "..."}
```

**SSE Endpoint Must:**
- Return `Content-Type: text/event-stream`
- Send data as: `data: {"message": "..."}\n\n`
- Keep connection alive or implement ping

### 4. Retry Button Not Working

**Symptom:** Clicking retry button doesn't fetch new data

**Possible Causes:**
- Component marked as closed/destroyed
- Global retry function not set up
- API still failing silently

**Solutions:**
```javascript
// Check if retry function exists
window.__retryHeartbeat?.();
window.__retryTimeline?.();
window.__retryCrossRepoBoard?.();
window.__retryAgentActivity?.();

// Check browser console for errors
// Look for "Component error:" messages
```

### 5. Connection Status Always "Offline"

**Symptom:** Connection status shows red "Offline" permanently

**Possible Causes:**
- All API requests failing
- Network is actually offline
- Browser fetch failing

**Solutions:**
```javascript
// Test basic fetch
fetch('/api/heartbeat')
  .then(r => r.json())
  .then(d => console.log('Fetch works:', d))
  .catch(e => console.error('Fetch failed:', e));

// Check if navigator.onLine
console.log('Browser online:', navigator.onLine);

// Test from browser DevTools Console
navigator.onLine; // Should be true
```

### 6. Memory Leaks / Continuous Growth

**Symptom:** Browser memory usage keeps increasing

**Possible Causes:**
- Intervals not cleared on cleanup
- Event listeners not removed
- Error history growing too large
- SSE connection not closed

**Solutions:**
```javascript
// Ensure cleanup is called
const monitor = await initMonitor();
monitor.cleanup(); // Call before leaving page

// Verify intervals cleared
setInterval(refreshData, 5000);
// Should stop when monitor.cleanup() called

// Check error history size
import { errorBoundary } from './lib/error-boundary.js';
errorBoundary.clearErrors(); // Manual clear if needed
```

### 7. Timeouts on Slow Networks

**Symptom:** API requests always timeout (> 10 seconds)

**Possible Causes:**
- Slow backend response
- Large response data
- Network latency

**Solutions:**
```javascript
// Current timeout is 10 seconds (10000ms)
// In src/lib/api.js, change:
// const API_TIMEOUT = 10000; // Increase this value

// Monitor request times
// Check Network tab in DevTools to see actual response times

// Consider optimizing backend
// - Add caching
// - Reduce response size
// - Add pagination
```

### 8. CORS Errors

**Symptom:** Console shows "CORS policy" error

**Possible Causes:**
- Backend not allowing cross-origin requests
- Missing CORS headers

**Solutions:**
```javascript
// Backend must include CORS headers
// Add to your server:
res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
```

### 9. Log Viewer Missing Some Logs

**Symptom:** Log viewer only shows last 100 entries

**This is by design!**

**Reason:** Performance optimization

**If you need more:**
```javascript
// In src/components/log-viewer.js, change:
// while (logs.children.length > 100) {
//   logs.removeChild(logs.firstChild);
// }
// Change 100 to your preferred limit
```

### 10. Exponential Backoff Taking Too Long

**Symptom:** Log viewer takes 30+ seconds to retry after failure

**This is by design!**

**Delays:** 1s → 2s → 4s → 8s → 30s (max 30s between retries)

**If you want faster retries:**
```javascript
// In src/components/log-viewer.js, change:
// const RECONNECT_DELAYS = [1000, 2000, 4000, 8000, 30000];
// to something like:
// const RECONNECT_DELAYS = [500, 1000, 2000, 5000];
```

---

## Debug Commands

### In Browser Console

```javascript
// Check all connection states
import { getConnectionState } from '/src/lib/api.js';
console.log('Connection:', getConnectionState());

// Get all errors
import { errorBoundary } from '/src/lib/api.js';
console.log('Errors:', errorBoundary.getErrors());

// Test API endpoint
import { apiGet } from '/src/lib/api.js';
apiGet('/api/heartbeat').then(d => console.log(d)).catch(e => console.error(e));

// Force SSE reconnect
window.__retryAgentActivity?.();

// Trigger error to test error boundary
window.__testError = () => { throw new Error('Test error'); };
__testError();
```

### Check Network Activity

1. Open DevTools → Network tab
2. Look for:
   - `/api/heartbeat` - Should return 200
   - `/api/logs` - Should show "pending" (SSE streaming)
   - Response content-type should be `application/json` or `text/event-stream`

### Check Console for Patterns

**Normal Operation:**
```
✓ No error messages
✓ "Monitor initialized successfully"
✓ Connection state changes visible
```

**Error Operation:**
```
✗ "[timestamp] GET /api/endpoint: Error: ..."
✗ "SSE reconnecting in Xms (attempt Y/10)"
✗ "Component error: Error: ..."
```

---

## Performance Optimization

### Reduce Refresh Rates

```javascript
// In component file (e.g., heartbeat.js):
// Change from: refreshInterval = setInterval(refresh, 30000);
// To:         refreshInterval = setInterval(refresh, 60000); // 60 seconds
```

### Reduce Log History

```javascript
// In src/components/log-viewer.js:
// Change from: while (logs.children.length > 100)
// To:         while (logs.children.length > 50)
```

### Reduce Error History

```javascript
// In src/lib/error-boundary.js:
// Change from: if (this.errors.length > 50)
// To:         if (this.errors.length > 20)
```

---

## Testing Scenarios

### Test Offline Mode
```javascript
// In DevTools, set Network throttling to "Offline"
// All components should show "Offline" state
// Log viewer should attempt reconnection
```

### Test Slow Network
```javascript
// In DevTools, set Network throttling to "Slow 3G"
// Watch for 10-second timeouts
// Monitor exponential backoff behavior
```

### Test Error Handling
```javascript
// Make backend return error:
// GET /api/heartbeat → { error: "Service unavailable" }
// Component should show error state with retry button
```

### Test Recovery
```javascript
// After error state appears:
// Fix backend issue
// Click retry button
// Component should recover
```

---

## Browser Compatibility

**Required Features:**
- ✅ ES6 modules (`import`/`export`)
- ✅ Fetch API
- ✅ EventSource (SSE)
- ✅ AbortController (for timeouts)
- ✅ Arrow functions

**Supported Browsers:**
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- iOS Safari 14+

**Not Supported:**
- ❌ Internet Explorer (use polyfills)
- ❌ Very old browsers

---

## Getting Help

1. **Check console errors** - Most issues visible here
2. **Check Network tab** - Verify API responses
3. **Check error boundary** - `errorBoundary.getErrors()`
4. **Review README.md** - Complete documentation
5. **Check individual component comments** - Implementation details

---

## Common Fixes Quick Reference

| Issue | Fix | File |
|-------|-----|------|
| Slow timeouts | Increase `API_TIMEOUT` | `src/lib/api.js` |
| Too many retries | Reduce `MAX_RETRIES` | `src/components/log-viewer.js` |
| Memory growth | Call `monitor.cleanup()` | `src/monitor.js` |
| Missing logs | Increase log limit | `src/components/log-viewer.js` |
| Long backoff delays | Reduce `RECONNECT_DELAYS` | `src/components/log-viewer.js` |
| Slow polling | Increase refresh interval | Component files |
| CORS errors | Add CORS headers | Backend |
| SSE not working | Set proper headers | Backend |
