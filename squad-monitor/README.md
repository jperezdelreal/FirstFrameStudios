# Monitor Application - Error Handling Implementation

## Overview

This monitoring application includes comprehensive error handling across all components with the following features:

- **Connection state tracking** (operational, degraded, offline)
- **Error boundaries** for catching component errors
- **Retry mechanisms** with exponential backoff
- **Error states** for all data-fetching components
- **Graceful degradation** for non-critical features
- **Error logging** and monitoring

## Project Structure

```
src/
├── lib/
│   ├── api.js              # API utilities with connection state tracking
│   └── error-boundary.js   # Global error boundary
├── components/
│   ├── connection-status.js    # Connection status indicator (operational/degraded/offline)
│   ├── log-viewer.js           # Log viewer with SSE reconnection & exponential backoff
│   ├── heartbeat.js            # System heartbeat component
│   ├── timeline.js             # Activity timeline component
│   ├── cross-repo-board.js     # Cross-repository dashboard
│   ├── studio-pulse.js         # Studio activity pulse (graceful error handling)
│   └── agent-activity.js       # Agent activity tracker
├── monitor.js              # Main application entry point
└── styles.css              # Global styles including error states
```

## Key Features

### 1. API Layer (`src/lib/api.js`)

**Connection State Tracking:**
- `OPERATIONAL`: Normal operation
- `DEGRADED`: Experiencing issues but still functional
- `OFFLINE`: No connectivity

**Timeout Protection:**
- All requests have a 10-second timeout
- Aborted requests set state to DEGRADED

**Error Logging:**
- All errors logged with timestamp and context
- Can integrate with remote logging service via `window.__errorLog`

**Methods:**
```javascript
import { apiGet, apiPost, apiPut, apiDelete, openSSE } from './lib/api.js';

// Usage
const data = await apiGet('/api/endpoint');
const response = await apiPost('/api/endpoint', { data });
const eventSource = openSSE('/api/stream', onMessage, onError);
```

### 2. Error Boundary (`src/lib/error-boundary.js`)

**Global Error Handling:**
- Catches uncaught exceptions
- Catches unhandled promise rejections
- Maintains error history (last 50 errors)
- Notifies all registered error handlers

**Usage:**
```javascript
import { errorBoundary, initErrorBoundary } from './lib/error-boundary.js';

// Initialize
initErrorBoundary();

// Subscribe to errors
errorBoundary.onError((error) => {
  console.log('Error caught:', error);
});

// Query errors
const allErrors = errorBoundary.getErrors();
const lastError = errorBoundary.getLastError();
```

### 3. Component Error States

All data-fetching components follow this pattern:

```javascript
function renderError(error) {
  const errorEl = document.createElement('div');
  errorEl.className = 'error-state';
  errorEl.innerHTML = `
    <div class="error-icon">❌</div>
    <div class="error-message">Could not load [ComponentName]</div>
    <button class="retry-button">Retry</button>
  `;
  
  errorEl.querySelector('.retry-button').addEventListener('click', () => {
    refresh();
  });
  
  content.innerHTML = '';
  content.appendChild(errorEl);
  
  // Store retry function globally
  window.__retry[ComponentName] = refresh;
}
```

### 4. Component Types

#### Critical Components (Show Error State with Retry)
- **Heartbeat** - System health check
- **Timeline** - Activity timeline
- **Cross-Repo Board** - Repository dashboard
- **Agent Activity** - Agent status tracking

All refresh every 3-30 seconds and show error state if API fails.

#### Non-Critical Component (Graceful Degradation)
- **Studio Pulse** - Shows "activity unavailable" message and retries automatically without blocking

#### Real-time Component (Reconnection Strategy)
- **Log Viewer** - Uses SSE with exponential backoff:
  - Delays: 1s → 2s → 4s → 8s → 30s
  - Max retries: 10
  - Shows "Connecting..." / "Reconnecting..." / "Connection Error" states

### 5. Log Viewer SSE Reconnection

The Log Viewer implements exponential backoff reconnection:

```javascript
const RECONNECT_DELAYS = [1000, 2000, 4000, 8000, 30000]; // 1s, 2s, 4s, 8s, 30s
const MAX_RETRIES = 10;

// After each failed connection, delays increase exponentially
// Max single delay: 30s
// Max total attempts: 10
// After 10 failures, shows error state with manual retry
```

### 6. Connection Status Component

Real-time indicator showing connection state:
- 🟢 **Green (Operational)**: All systems functioning normally
- 🟡 **Yellow (Degraded)**: Some issues but still working
- 🔴 **Red (Offline)**: No connectivity

Updates automatically when `apiGet`, `apiPost`, `apiPut`, `apiDelete`, or `openSSE` is called.

### 7. Monitor Initialization (`src/monitor.js`)

The main application:

```javascript
import initMonitor from './monitor.js';

// Initialize all components and error handling
const monitor = await initMonitor();

// Cleanup when done
monitor.cleanup();
```

**Automatically initializes:**
1. Error boundary (global error catching)
2. Connection status indicator
3. All data components
4. Error logging

**Wraps refresh functions** to catch errors during manual retries.

## Styling (`src/styles.css`)

### Color Scheme
- **Operational**: #10b981 (green)
- **Degraded**: #f59e0b (amber)
- **Offline**: #ef4444 (red)
- **Error**: #ef4444 (red)

### Key Classes

**Error States:**
- `.error-state` - Standard error display with icon and retry button
- `.error-graceful` - Non-critical error that auto-retries (Studio Pulse)
- `.error-notification` - Toast-style error notification
- `.critical-error-overlay` - Full-screen critical error

**Connection Status:**
- `.connection-status` - Status indicator container
- `.connection-status-operational` - Green state
- `.connection-status-degraded` - Yellow state
- `.connection-status-offline` - Red state

**Log Viewer:**
- `.log-stream-badge` - Connection status badge
- `.log-stream-badge.connected` - Green, pulsing
- `.log-stream-badge.reconnecting` - Amber, animated reconnect
- `.log-stream-badge.error` - Red, static

**Buttons:**
- `.retry-button` - Standard retry button with hover effects

### Animations

- `pulse` - 2s opacity animation for connected indicators
- `heartbeat` - 1s scale animation for heartbeat component
- `blink` - 1s opacity blink for reconnecting indicators
- `slideIn` - 0.3s animation for error notifications
- `fadeIn` - 0.3s animation for error overlays

## Usage Example

### HTML

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="/src/styles.css">
</head>
<body>
  <div id="connection-status"></div>
  <div id="heartbeat"></div>
  <div id="timeline"></div>
  <div id="log-viewer"></div>
  <div id="cross-repo-board"></div>
  <div id="studio-pulse"></div>
  <div id="agent-activity"></div>

  <script type="module">
    import initMonitor from '/src/monitor.js';
    
    await initMonitor();
  </script>
</body>
</html>
```

### Individual Component Usage

```javascript
// Import specific components
import { initHeartbeat } from './components/heartbeat.js';
import { initConnectionStatus } from './components/connection-status.js';

// Initialize individual components
const heartbeat = initHeartbeat('#heartbeat');
const status = initConnectionStatus('#connection-status');

// Cleanup
heartbeat.cleanup();
status.cleanup();
```

## Error Handling Patterns

### Pattern 1: Try-Catch in API Layer

```javascript
export async function apiGet(endpoint) {
  try {
    const response = await fetchWithTimeout(endpoint, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    return await response.json();
  } catch (error) {
    logError(`GET ${endpoint}`, error);
    throw error;
  }
}
```

### Pattern 2: Component Error State

```javascript
async function refresh() {
  if (isClosed) return;
  try {
    const data = await apiGet('/api/endpoint');
    renderComponent(data);
  } catch (error) {
    console.error('Component error:', error);
    renderError(error);
  }
}
```

### Pattern 3: Exponential Backoff

```javascript
function reconnect() {
  const delayIndex = Math.min(retryCount, RECONNECT_DELAYS.length - 1);
  const delay = RECONNECT_DELAYS[delayIndex];
  
  setTimeout(() => {
    retryCount++;
    connect();
  }, delay);
}
```

### Pattern 4: Global Error Catching

```javascript
window.addEventListener('error', (event) => {
  errorBoundary.captureError({
    type: 'uncaught_error',
    message: event.message,
    stack: event.error?.stack
  });
});
```

## API Endpoints Expected

The monitor expects these endpoints to be available:

```
GET  /api/heartbeat              → { uptime?: string }
GET  /api/timeline               → { events: Array<Event> }
GET  /api/logs (SSE)             → { message: string }
GET  /api/cross-repo-board       → { repositories: Array<Repo> }
GET  /api/studio-pulse           → { activeAgents: number, operations: number, status: string }
GET  /api/agent-activity         → { agents: Array<Agent> }
```

If an endpoint returns `{ error: ... }`, the component displays an error state.

## Testing Error Handling

### Test Connection States

```javascript
import { ConnectionState, setConnectionState } from './lib/api.js';

// Simulate offline
window.__testOffline = () => {
  // This would be called from connection state change
};
```

### Test Error States

```javascript
// Make a request that fails
await apiGet('/api/nonexistent');  // Will trigger error state

// Access error history
import { errorBoundary } from './lib/error-boundary.js';
console.log(errorBoundary.getErrors());
```

### Test SSE Reconnection

```javascript
import { initLogViewer } from './components/log-viewer.js';

// Create log viewer
const logViewer = initLogViewer('#log-viewer', '/api/logs');

// Simulate connection failure - it will automatically reconnect
// with exponential backoff
```

## Performance Considerations

1. **Timeouts**: All API requests timeout at 10 seconds
2. **Update Intervals**: 
   - Agent Activity: 3s (most frequent)
   - Timeline: 5s
   - Cross-Repo Board: 10s
   - Heartbeat: 30s (least frequent)
3. **Error History**: Keeps last 50 errors in memory
4. **Log Entries**: Keeps last 100 log entries in view
5. **Reconnection**: Max 10 attempts with exponential backoff

## Future Enhancements

1. **Remote Error Logging**: Integrate with Sentry, LogRocket, etc.
2. **Error Analytics**: Track error patterns and frequencies
3. **Circuit Breaker**: Implement circuit breaker pattern for failing endpoints
4. **Metrics**: Send performance metrics to monitoring service
5. **Persistent Storage**: Store error history in IndexedDB
6. **User Notifications**: More sophisticated error notifications
7. **Health Checks**: Periodic health check pings

## Cleanup

All components support cleanup for proper resource management:

```javascript
const monitor = await initMonitor();

// Later, when done
monitor.cleanup();
```

This will:
- Close all event sources
- Clear all intervals
- Remove all event listeners
- Clean up DOM elements
