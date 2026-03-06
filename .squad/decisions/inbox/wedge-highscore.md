# Decision: High Score localStorage Key & Save Strategy

**Author:** Wedge  
**Date:** 2025-01-01  
**Status:** Implemented  
**Scope:** P0-1 — High Score Persistence

## Decision

- localStorage key is `simpsonsKong_highScore` — namespaced to avoid collisions if other games share the domain.
- High score is saved at the moment `gameOver` or `levelComplete` is triggered, not continuously during gameplay. A `highScoreSaved` flag prevents duplicate writes.
- `saveHighScore()` returns a boolean so the renderer can show "NEW HIGH SCORE!" vs the existing value — no extra localStorage read needed in the render loop for that decision.
- All localStorage access is wrapped in try/catch to gracefully handle private browsing or disabled storage (falls back to 0).
- Title screen only shows the high score label when value > 0, keeping a clean first-play experience.

## Why

- Single save point is simpler and avoids unnecessary writes during gameplay.
- Boolean return from save avoids coupling render logic to storage checks.
- Graceful fallback means the game never crashes due to storage restrictions.
