# Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          MONITOR APPLICATION                             │
│                                                                           │
│  src/index.html                                                          │
│  ├── CSS Styles (src/styles.css)                                        │
│  └── JavaScript (src/monitor.js)                                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        MONITOR INITIALIZATION                            │
│                                                                           │
│  src/monitor.js                                                          │
│  ├── Initialize Error Boundary (error-boundary.js)                      │
│  ├── Initialize Components                                              │
│  │   ├── Connection Status                                              │
│  │   ├── Heartbeat (30s)                                                │
│  │   ├── Timeline (5s)                                                  │
│  │   ├── Log Viewer (SSE)                                               │
│  │   ├── Cross-Repo Board (10s)                                         │
│  │   ├── Studio Pulse (15s)                                             │
│  │   └── Agent Activity (3s)                                            │
│  └── Setup Global Retry Functions                                       │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
        ┌──────────────────┐  ┌──────────────┐  ┌──────────────┐
        │  Error Boundary  │  │  Components  │  │  API Layer   │
        │                  │  │              │  │              │
        │ • Catch Errors   │  │ • Render UI  │  │ • Fetch API  │
        │ • Log History    │  │ • Show State │  │ • SSE        │
        │ • Callbacks      │  │ • Retry      │  │ • Timeout    │
        └──────────────────┘  └──────────────┘  └──────────────┘
                                                        │
                                                        ▼
                                        ┌───────────────────────────┐
                                        │    Connection State       │
                                        │  (operational/degraded)   │
                                        │       /offline)           │
                                        └───────────────────────────┘
                                                        │
                                                        ▼
                                        ┌───────────────────────────┐
                                        │  Backend API Endpoints    │
                                        │                           │
                                        │ • /api/heartbeat          │
                                        │ • /api/timeline           │
                                        │ • /api/logs (SSE)         │
                                        │ • /api/cross-repo-board   │
                                        │ • /api/studio-pulse       │
                                        │ • /api/agent-activity     │
                                        └───────────────────────────┘
```

## Data Flow for Components with Error Handling

```
User Interface (HTML)
         │
         ▼
Component Constructor
         │
    ┌────┴────┐
    ▼         ▼
 Fetch    Handle
 Data     Errors
    │         │
    ├─────────┤
    │         │
    ▼         ▼
Success   renderError()
State     │
│         ├─ Error Icon (❌)
│         ├─ Error Message
├─ Call  └─ Retry Button
│ Render       │
│ Component    └─ On Click: Call refresh()
│
└─ Show UI
   with Data
```

## SSE Log Viewer with Exponential Backoff

```
Start Connection
       │
       ▼
Connect to /api/logs
       │
       ├─────────────────┬────────────────┐
       ▼                 ▼                ▼
    Success         Network Error    Connection Closed
       │                 │                  │
       ▼                 ▼                  ▼
   Receive         Exponential         Retry Count
   Messages        Backoff             Check
       │                 │                  │
       ▼                 ▼                  ▼
  Update UI      1s ──► 2s ──► 4s ──► 8s ──► 30s
       │                 │
       └─────────────────┘
                 │
                 ▼
          Max Retries (10)?
          /           \
        NO            YES
        │              │
        │              ▼
        │         Show Error
        │         State
        └─────────┘
```

## Error Handling Flow

```
API Call (apiGet/Post/Put/Delete/SSE)
         │
         ▼
    Try Block
         │
    ┌────┴─────┐
    ▼          ▼
 Success    Error
    │          │
    ▼          ▼
Set State   Classify
OPERATIONAL Error Type
    │          │
    │     ┌────┴────┬──────────┐
    │     ▼         ▼          ▼
    │  Timeout   Network   Other
    │     │         │        │
    │     ▼         ▼        ▼
    │  DEGRADED  OFFLINE  DEGRADED
    │     │        │        │
    └─────┴────────┴────────┘
            │
            ▼
       Log Error
    (timestamp,
     context,
     error)
            │
            ▼
    Throw Error to
    Component
            │
    ┌───────┴────────┐
    ▼                ▼
 Component      Doesn't Handle
 Catches       (Global Handler)
 Error              │
    │               ▼
    ▼        Error Boundary
 Show Error   Catches It
 State             │
    │              ▼
    └───── Log Error History
         │
         ▼
    Call Error
    Callbacks
```

## Component State Diagram

```
COMPONENT LIFECYCLE

┌──────────────────────────────────────────────────────────┐
│                                                          │
│  1. CREATING                                            │
│     ├─ Set isClosed = false                             │
│     ├─ Create DOM elements                              │
│     └─ Set up event listeners                           │
│                                                          │
│  2. INITIALIZING                                        │
│     ├─ First refresh() call                             │
│     ├─ Fetch initial data                               │
│     └─ Set up periodic refresh interval                 │
│                                                          │
│  3. RUNNING                                             │
│     ├─ Periodic refresh (every N seconds)               │
│     ├─ On Success: Render component with data           │
│     ├─ On Error: Call renderError() and show UI         │
│     └─ User can click retry to call refresh() again     │
│                                                          │
│  4. CLEANING UP                                         │
│     ├─ component.cleanup() called                       │
│     ├─ Set isClosed = true                              │
│     ├─ Clear interval                                   │
│     ├─ Close connections (SSE)                          │
│     └─ Remove event listeners                           │
│                                                          │
│  5. CLOSED                                              │
│     └─ All operations stop                              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Connection State Updates

```
User Makes API Call
         │
    ┌────┴────┐
    ▼         ▼
Before    During
State:    Call:
(any)     abort? ──────┐
                       │
    After Call:        │
    ┌──────────────────┤
    ▼                  ▼
Success            Failure
    │                  │
    ▼                  ▼
Set           Classify
OPERATIONAL   Failure
    │          /       \
    │      Network  Timeout/Other
    │      Error         │
    │      │              ▼
    │      ▼         Set DEGRADED
    │   Set OFFLINE      │
    │      │              │
    └──────┴──────────────┘
           │
           ▼
    Notify All
    Listeners
           │
           ▼
    Connection Status
    Component Updates
    (Changes color)
           │
           ▼
    All Other Components
    Can See New State
```

## Error Boundary - Global Error Catching

```
Uncaught Error Occurs
(in app or dependency)
         │
    ┌────┴─────┐
    ▼          ▼
window   Unhandled
error    Promise
event    Rejection
    │          │
    └────┬─────┘
         │
         ▼
Error Boundary
Listener
         │
    ┌────┴──────────────┐
    ▼                   ▼
Capture         Maintain
Error:          Error History
├─ Type         (max 50)
├─ Message          │
├─ Stack            ▼
├─ Timestamp    Notify
└─ Context      Callbacks
                    │
                    ▼
              Send to Remote
              Logging Service
              (optional)
                    │
                    └─ window.__errorLog()
```

## File Dependencies

```
index.html
    │
    └─► monitor.js
         │
         ├─► lib/error-boundary.js
         │
         ├─► lib/api.js
         │   ├─ getConnectionState()
         │   ├─ onConnectionStateChange()
         │   ├─ apiGet/Post/Put/Delete()
         │   └─ openSSE()
         │
         ├─► components/connection-status.js
         │   └─ Subscribes to: onConnectionStateChange()
         │
         ├─► components/heartbeat.js
         │   └─ Uses: apiGet()
         │
         ├─► components/timeline.js
         │   └─ Uses: apiGet()
         │
         ├─► components/log-viewer.js
         │   └─ Uses: openSSE()
         │
         ├─► components/cross-repo-board.js
         │   └─ Uses: apiGet()
         │
         ├─► components/studio-pulse.js
         │   └─ Uses: apiGet()
         │
         ├─► components/agent-activity.js
         │   └─ Uses: apiGet()
         │
         └─► styles.css
             (Global styling for all components)
```

## Refresh Rate Timeline

```
0s      3s      5s      10s     15s     30s
│       │       │       │       │       │
│  ┌────┼───────┼───────┼───────┼───────┼───┐ Timeline
│  │    │       │       │       │       │   │ (5s)
│  └────┼───────┼───────┼───────┼───────┼───┘
│
│  ┌────┼───────┼───────┼───────┼───────┼───┐ Agent Activity
│  │    │       │       │       │       │   │ (3s)
│  └────┼───────┼───────┼───────┼───────┼───┘
│
│  ┌────┼───────┼───────┼───────┼───────┼───┐ Cross-Repo Board
│  │    │       │       │       │       │   │ (10s)
│  └────┼───────┼───────┼───────┼───────┼───┘
│
│  ┌────┼───────┼───────┼───────┼───────┼───┐ Studio Pulse
│  │    │       │       │       │       │   │ (15s)
│  └────┼───────┼───────┼───────┼───────┼───┘
│
│  ┌────┼───────┼───────┼───────┼───────┼───┐ Heartbeat
│  │    │       │       │       │       │   │ (30s)
│  └────┼───────┼───────┼───────┼───────┼───┘
│
└───────┴───────┴───────┴───────┴───────┴─────►
```

## Color Legend

- 🟢 **Green** (#10b981) - Operational/Success
- 🟡 **Yellow** (#f59e0b) - Degraded/Warning
- 🔴 **Red** (#ef4444) - Offline/Error
- ⚫ **Gray** (#6b7280) - Idle/Inactive

## File Size Reference

```
Total: 92.22 KB

Largest:
  styles.css           12.86 KB │████████████
  BACKEND_CHECKLIST    11.82 KB │███████████
  README               11.29 KB │███████████
  IMPLEMENTATION       10.71 KB │██████████
  TROUBLESHOOTING       9.20 KB │█████████

Components:
  agent-activity.js     3.40 KB │███
  cross-repo-board.js   3.18 KB │███
  log-viewer.js         3.91 KB │████
  timeline.js           3.06 KB │███
  heartbeat.js          2.36 KB │██
  studio-pulse.js       2.88 KB │██

Core:
  api.js                4.41 KB │████
  error-boundary.js     2.12 KB │██
  monitor.js            3.55 KB │███
  connection-status.js  1.62 KB │██
```
