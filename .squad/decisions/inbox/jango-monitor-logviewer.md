# Decision: SSE for Log Streaming in Squad Monitor

**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-25  
**Scope:** ffs-squad-monitor — log viewer component  
**Status:** Implemented (PR #8)

## Decision

Use Server-Sent Events (SSE) for streaming structured logs from `tools/logs/` to the dashboard, with client-side filtering.

## Context

Issue #2 required a log viewer that tails JSONL log files and displays them with filtering. Two transport options: SSE or WebSocket.

## Rationale

1. **SSE chosen over WebSocket** — Log streaming is one-directional (server→client). SSE is simpler, has native browser reconnection via `EventSource`, and requires no additional dependencies. WebSocket would add bidirectional overhead for a unidirectional use case.

2. **Client-side filtering** — All log entries are streamed to the client and filtered in JavaScript. Current log volumes (tens of entries per day) make server-side filtering unnecessary complexity. If volumes grow significantly, we can add server-side filtering to the SSE endpoint via query params.

3. **Byte offset tracking for tailing** — The SSE endpoint tracks the last-read byte position per log file, reading only new bytes on each `fs.watch` event. This prevents duplicate entries and keeps memory usage constant regardless of log file size.

4. **Log level derivation** — Since JSONL logs don't have an explicit `level` field, we derive it: `exitCode === 0` → info, `exitCode !== 0` → error, `consecutiveFailures > 0 && exitCode === 0` → warn. This convention should be documented if other tools start writing logs.

## Impact

- Future log-producing tools should follow the `{agent}-{YYYY-MM-DD}.jsonl` naming convention to be auto-discovered by the viewer
- Log entries should include `timestamp`, `exitCode`, and optionally `consecutiveFailures` for proper level derivation
