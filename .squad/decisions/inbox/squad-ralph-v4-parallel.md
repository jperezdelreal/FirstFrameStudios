### 2026-03-13T06:20Z: Ralph v4 — Per-Repo Parallel Architecture (Proposal)
**By:** Squad (Coordinator), requested by Joaquin
**Status:** PROPOSAL — awaiting Founder review
**What:** Replace ralph-watch v3's centralized sequential loop with a per-repo parallel architecture. Each repo gets its own autonomous worker process (`ralph-worker.ps1`) running its own copilot sessions independently. An orchestrator (`ralph-parallel.ps1`) handles shared infra (upstream sync, scheduler, lifecycle) and renders a unified dashboard.

**Why:** v3 processes repos sequentially — worst case 120 min for a full round across 4 repos. Parallel workers bring that to ~35 min (longest single session + sleep). 3.4x throughput improvement. Error isolation: a circuit breaker in one repo doesn't halt the others.

**Key decisions in proposal:**
- Workers are separate PowerShell processes (not runspaces) — fully isolated, crash-safe
- No shared state between workers — each has own heartbeat, logs, circuit breaker
- Cross-repo priority sorting eliminated — each repo runs its own P0→P3 sort independently
- IPC via stop files (`.ralph-stop` global, `.ralph-stop-{repo}` per-worker)
- Night/day mode still uniform across all workers
- Migration: extract worker → build orchestrator → thin wrapper → deprecate v3

**Open questions:**
1. Per-repo interval overrides? (hot repos faster, cold repos slower)
2. Copilot CLI concurrency limits? (need to test)
3. Dashboard: single terminal vs multi-tab?
