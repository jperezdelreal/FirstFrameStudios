# Backend Implementation Checklist

## API Endpoints to Create

Use this checklist to implement the required backend endpoints.

### ✅ 1. GET /api/heartbeat
**Purpose:** System health check

**Required Response:**
```json
{
  "uptime": "2h 30m",
  "status": "healthy"
}
```

**Optional Fields:**
```json
{
  "uptime": "2h 30m",
  "status": "healthy",
  "timestamp": "2024-03-12T10:30:00Z",
  "memory": "256MB",
  "cpu": "15%"
}
```

**Error Response:**
```json
{
  "error": "Service temporarily unavailable"
}
```

**Refresh Interval:** Every 30 seconds

**Implementation Notes:**
- Should respond quickly (< 1s)
- Can include system metrics if available
- Component shows error state if endpoint fails

---

### ✅ 2. GET /api/timeline
**Purpose:** Activity event timeline

**Required Response:**
```json
{
  "events": [
    {
      "timestamp": "2024-03-12T10:30:00Z",
      "title": "Build completed",
      "description": "Main branch build successful"
    },
    {
      "timestamp": "2024-03-12T10:15:00Z",
      "title": "Tests passed",
      "description": "1,247 tests passed in 45s"
    }
  ]
}
```

**Required Fields:**
- `events` - Array of event objects
- `events[].timestamp` - ISO 8601 timestamp
- `events[].title` - Short event title

**Optional Fields:**
- `events[].description` - Longer description

**Error Response:**
```json
{
  "error": "Could not fetch timeline data"
}
```

**Refresh Interval:** Every 5 seconds

**Implementation Notes:**
- Return most recent events first
- Can return empty array if no events
- Component handles up to 100 events efficiently

---

### ✅ 3. GET /api/logs (Server-Sent Events)
**Purpose:** Real-time log streaming via SSE

**Required Headers:**
```
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

**Required Response Format:**
```
data: {"message": "Service started"}

data: {"message": "Processing request from 192.168.1.1"}

data: {"message": "Build completed successfully"}

```

**Notes:**
- Must be newline-delimited JSON
- Keep connection open for streaming
- Send periodic messages (every 30s minimum if no activity)
- Implement server-side ping if needed

**Error Handling:**
- Connection failures trigger exponential backoff
- Max 10 reconnection attempts
- Shows "Connection Error" after max retries

**Refresh Interval:** Real-time (streaming)

**Implementation Notes:**
- SSE auto-reconnects on connection loss
- Browser handles reconnection automatically
- Each message must be format: `data: {...}\n\n`
- Can send multiple events per second

**Example Node.js Implementation:**
```javascript
app.get('/api/logs', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  // Send log message
  res.write(`data: ${JSON.stringify({ message: 'Log entry' })}\n\n`);
  
  // Keep connection alive
  const interval = setInterval(() => {
    res.write(`data: ${JSON.stringify({ message: 'Heartbeat' })}\n\n`);
  }, 30000);
  
  req.on('close', () => clearInterval(interval));
});
```

---

### ✅ 4. GET /api/cross-repo-board
**Purpose:** Repository status dashboard

**Required Response:**
```json
{
  "repositories": [
    {
      "name": "AI-Core",
      "status": "active",
      "description": "Core AI engine",
      "issues": 12,
      "pullRequests": 3
    },
    {
      "name": "Game-Engine",
      "status": "active",
      "description": "Game development engine",
      "issues": 28,
      "pullRequests": 5
    }
  ]
}
```

**Required Fields:**
- `repositories` - Array of repository objects
- `repositories[].name` - Repository name
- `repositories[].status` - One of: 'active', 'inactive', 'maintenance'

**Optional Fields:**
- `repositories[].description` - Repository description
- `repositories[].issues` - Number of open issues
- `repositories[].pullRequests` - Number of open PRs
- `repositories[].lastUpdated` - Last commit timestamp

**Error Response:**
```json
{
  "error": "Could not fetch repository data"
}
```

**Refresh Interval:** Every 10 seconds

**Implementation Notes:**
- Can fetch from GitHub API
- Cache results to avoid rate limiting
- Component displays in grid layout
- Status colors: active (green), inactive (gray), maintenance (yellow)

---

### ✅ 5. GET /api/studio-pulse
**Purpose:** Studio activity metrics

**Required Response:**
```json
{
  "activeAgents": 3,
  "operations": 12,
  "status": "active",
  "lastUpdated": "2024-03-12T10:30:00Z"
}
```

**Required Fields:**
- `activeAgents` - Number of currently active agents
- `operations` - Total operations in progress
- `status` - One of: 'idle', 'active', 'busy'

**Optional Fields:**
- `lastUpdated` - ISO 8601 timestamp
- `metrics` - Additional metrics object

**Error Response:**
```json
{
  "error": "Studio metrics unavailable"
}
```

**Refresh Interval:** Every 15 seconds

**Implementation Notes:**
- Shows graceful error (no blocking)
- Retries automatically in background
- Component doesn't show manual retry button
- Can be slower to respond than other endpoints

---

### ✅ 6. GET /api/agent-activity
**Purpose:** AI agent status and activity tracking

**Required Response:**
```json
{
  "agents": [
    {
      "name": "CodeGenerator",
      "status": "active",
      "currentTask": "Writing utils functions",
      "lastActivityTime": "2024-03-12T10:29:50Z",
      "progress": 75
    },
    {
      "name": "Analyzer",
      "status": "idle",
      "currentTask": "Waiting for input",
      "lastActivityTime": "2024-03-12T10:25:00Z",
      "progress": 0
    }
  ]
}
```

**Required Fields:**
- `agents` - Array of agent objects
- `agents[].name` - Agent name
- `agents[].status` - One of: 'active', 'idle', 'busy', 'error'

**Optional Fields:**
- `agents[].currentTask` - Current task description
- `agents[].lastActivityTime` - Last activity timestamp
- `agents[].progress` - Progress percentage (0-100)
- `agents[].lastError` - Error message if failed

**Error Response:**
```json
{
  "error": "Could not fetch agent activity"
}
```

**Refresh Interval:** Every 3 seconds (most frequent)

**Implementation Notes:**
- Updates most frequently of all components
- Can query agent system or background job manager
- Component shows error state if fetch fails
- Status badges: active (green), idle (gray), busy (blue), error (red)

---

## CORS Headers Required

For all endpoints to work from frontend:

```javascript
// Node.js / Express
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  next();
});
```

Or for production (specific origin):
```javascript
res.header('Access-Control-Allow-Origin', 'https://yourdomain.com');
```

---

## Response Format Requirements

### Success Response
```json
{
  "field1": "value1",
  "field2": "value2"
}
```

### Error Response
Must include `error` field:
```json
{
  "error": "Descriptive error message"
}
```

Any response with an `error` field will trigger error state in component.

---

## Implementation Examples

### Express.js

```javascript
// Heartbeat
app.get('/api/heartbeat', (req, res) => {
  const uptime = formatUptime(process.uptime());
  res.json({ uptime, status: 'healthy' });
});

// Timeline (simulated)
app.get('/api/timeline', (req, res) => {
  const events = [
    { timestamp: new Date().toISOString(), title: 'Request received' }
  ];
  res.json({ events });
});

// Server-Sent Events
app.get('/api/logs', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  res.write(`data: ${JSON.stringify({ message: 'Connected' })}\n\n`);
  
  const interval = setInterval(() => {
    res.write(`data: ${JSON.stringify({ message: 'Heartbeat' })}\n\n`);
  }, 30000);
  
  req.on('close', () => clearInterval(interval));
});

// Cross-Repo Board
app.get('/api/cross-repo-board', (req, res) => {
  const repos = [
    { name: 'AI-Core', status: 'active', issues: 12, pullRequests: 3 }
  ];
  res.json({ repositories: repos });
});

// Studio Pulse
app.get('/api/studio-pulse', (req, res) => {
  res.json({
    activeAgents: 3,
    operations: 12,
    status: 'active',
    lastUpdated: new Date().toISOString()
  });
});

// Agent Activity
app.get('/api/agent-activity', (req, res) => {
  const agents = [
    { name: 'CodeGen', status: 'active', currentTask: 'Writing code', progress: 75 }
  ];
  res.json({ agents });
});
```

### Python / Flask

```python
from flask import Flask, jsonify, Response
from datetime import datetime
import json

@app.route('/api/heartbeat')
def heartbeat():
    return jsonify({
        'uptime': '2h 30m',
        'status': 'healthy'
    })

@app.route('/api/logs')
def logs():
    def generate():
        yield f'data: {json.dumps({"message": "Connected"})}\n\n'
        
    return Response(
        generate(),
        mimetype='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive'
        }
    )
```

---

## Testing Checklist

- [ ] All endpoints return correct JSON format
- [ ] Error responses include `error` field
- [ ] CORS headers present for cross-origin requests
- [ ] Timeouts handled gracefully (< 10 seconds)
- [ ] SSE endpoint keeps connection alive
- [ ] SSE endpoint uses `text/event-stream` content type
- [ ] SSE messages formatted as `data: {...}\n\n`
- [ ] All endpoints respond within reasonable time
- [ ] Error states tested (return 500, timeout, network error)
- [ ] Retry behavior verified (manual retry buttons work)
- [ ] SSE reconnection tested (close connection, verify reconnect)

---

## Environment Variables

Consider using environment variables for configuration:

```javascript
// .env file
API_BASE_URL=http://localhost:3000
SSE_ENDPOINT=http://localhost:3000/api/logs
HEARTBEAT_INTERVAL=30000
LOG_VIEWER_MAX_RETRIES=10
```

Update frontend URLs:
```javascript
// In src/lib/api.js or monitor.js
const API_BASE = process.env.API_BASE_URL || 'http://localhost:3000';
```

---

## Performance Targets

| Endpoint | Target Response Time | Max Response Time |
|----------|----------------------|-------------------|
| /api/heartbeat | < 100ms | 1s |
| /api/timeline | < 500ms | 5s |
| /api/logs (SSE) | Immediate | N/A (streaming) |
| /api/cross-repo-board | < 500ms | 5s |
| /api/studio-pulse | < 500ms | 5s |
| /api/agent-activity | < 200ms | 3s |

**Note:** Frontend timeout is 10s for all requests except SSE.

---

## Monitoring & Alerting

Consider tracking:
- Response times per endpoint
- Error rate per endpoint
- SSE connection uptime
- Total errors logged

This helps identify issues before users notice them.

---

## Security Considerations

1. **Authentication:** Add if endpoints contain sensitive data
2. **Rate Limiting:** Prevent abuse of polling endpoints
3. **Input Validation:** Validate all parameters
4. **CORS:** Use specific origin in production
5. **HTTPS:** Use TLS in production
6. **Error Messages:** Don't expose internal errors to frontend

---

## Deployment Checklist

- [ ] Update API endpoints for production URL
- [ ] Add authentication if needed
- [ ] Configure CORS properly
- [ ] Enable HTTPS
- [ ] Add rate limiting
- [ ] Monitor response times
- [ ] Set up error logging
- [ ] Test all components with real data
- [ ] Verify error states work correctly
- [ ] Test on slow/unreliable networks
- [ ] Test on mobile devices
