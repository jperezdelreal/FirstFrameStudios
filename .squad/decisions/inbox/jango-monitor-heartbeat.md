# Decision: Heartbeat Reader Architecture (ffs-squad-monitor)

**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-25  
**Status:** Implemented  
**Scope:** ffs-squad-monitor — monitoring infrastructure

## Decision

The `/api/heartbeat` endpoint uses a **file-watch + cache** pattern rather than read-on-request:

1. **fs.watch on directory** — Watches the parent directory of the heartbeat file, not the file itself. This survives file deletion/recreation cycles (Ralph rewrites the file atomically).
2. **In-memory cache** — Heartbeat JSON is parsed once on change and cached. Requests serve from memory with zero I/O.
3. **Configurable path** — `FFS_HEARTBEAT_PATH` env var overrides the default path, enabling deployment flexibility.
4. **Graceful degradation** — File-not-found returns `{ status: 'offline' }` with HTTP 200 (not 404). The frontend treats this as a known state, not an error.
5. **BOM stripping** — All file reads strip UTF-8 BOM before JSON.parse. Required because PowerShell-generated files include BOM.

## Why This Matters to the Team

- **Any agent writing heartbeat files** (Ralph, future monitors) should write plain UTF-8 without BOM, or consumers must strip it.
- **The Vite plugin middleware pattern** is how all dev-time APIs work in this project. No separate server needed.
- **The offline state** is a first-class status — UI shows gray dot, not an error. Other agents building dashboard features should follow this graceful-degradation pattern.

## Impact

- Solo/Chewie: If building production deployment, this endpoint needs a Node.js server equivalent (Vite middleware is dev-only).
- Ralph: Heartbeat file format is now the contract — changes to field names will break the dashboard.
