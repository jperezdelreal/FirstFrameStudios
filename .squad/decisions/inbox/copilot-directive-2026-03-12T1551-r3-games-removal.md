### 2026-03-12T15:51Z: Founder directive — Remove games/ComeRosquillas/ from Hub
**By:** Joaquin Perez del Real (via Copilot)
**What:** Eliminate `games/ComeRosquillas/` directory from FFS Hub repo. The game lives in its own repo (jperezdelreal/ComeRosquillas). Also remove `games/**` from squad.config.ts allowedWritePaths. This enforces the hub-and-spoke model: no game code in hub.
**Why:** User request — captured for team memory. Resolves R3.7+R3.8+R3.9 from optimization-plan-review.md.
