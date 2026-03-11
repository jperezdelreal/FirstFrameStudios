# ComeRosquillas Modularization Architecture Decision

**Date:** 2026-03-11  
**Author:** Chewie (Engine Developer)  
**Issue:** #1 — Modularize game.js monolith

## Context

The ComeRosquillas game had a 1789-line game.js monolith containing all code: constants, audio, rendering, game logic, and initialization. This made parallel development difficult and code navigation challenging.

## Decision

Split game.js into focused modules organized by responsibility:

### Module Structure

```
js/
├── config.js              # Constants, maze data, colors (114 lines)
├── main.js                # Entry point (13 lines)
├── engine/
│   ├── audio.js           # SoundManager class (166 lines)
│   └── renderer.js        # Sprites static class (720 lines)
└── game-logic.js          # Game class (791 lines)
```

### Load Order

Dependencies flow cleanly through the module graph:

```
config.js (no deps)
  ↓
audio.js (uses config constants)
  ↓
renderer.js (uses config constants, COLORS)
  ↓
game-logic.js (uses all modules)
  ↓
main.js (instantiates Game)
```

Loaded via `<script>` tags in index.html in this exact order.

## Rationale

### Why This Structure?

1. **Config as Foundation:** Pure data with zero dependencies enables all other modules to import constants safely
2. **Engine Separation:** Audio and rendering are orthogonal concerns — separate files enable parallel work
3. **Static Renderer:** Sprites class uses static methods (no instance state) — simplifies testing and eliminates object allocation
4. **Game as Orchestrator:** Game class depends on all modules but exports clean game loop interface

### Why No Bundler?

- Vanilla JS project with simple dependency chain
- `<script>` tags provide explicit load order
- No build step keeps development friction low
- Global namespace is intentional and controlled

### Why Keep Renderer Large?

720 lines in renderer.js might seem large, but:
- All drawing code in one place (single responsibility)
- Each sprite draw function is self-contained
- Pattern consistency across 4 ghost character renderers
- Easier to find/modify rendering code than splitting further

## Alternatives Considered

1. **ES Modules with `type="module"`:** Rejected because it requires export/import syntax changes and relative path handling. Current global approach is simpler.

2. **Split renderer by entity type:** (player.js, ghosts.js, maze.js, particles.js) Rejected because drawing code is tightly coupled to config constants and often shares helper functions.

3. **Bundle with Webpack/Vite:** Rejected to keep zero-build-step simplicity for HTML/JS game. Browser can handle 5 small files efficiently.

## Consequences

### Positive

- **Maintainability:** Each module has clear responsibility
- **Parallel Development:** Team can work on audio, rendering, and game logic simultaneously
- **Testing:** Static methods in Sprites are easily testable
- **Onboarding:** New developers can understand one module at a time

### Negative

- **Global Namespace:** All classes/constants are global. Risk of naming conflicts if not careful.
- **Load Order Dependency:** index.html must maintain correct script order. Easy to break.
- **No Tree-Shaking:** Browser loads all code even if unused. (Not a concern for 1804-line game.)

## Implementation Notes

- Original game.js backed up as `game.js.backup`
- Zero gameplay changes — all functionality preserved
- Module headers added for clarity (15-line overhead total)
- PR #10 created with full testing validation

## Future Work

- Consider ES modules when browser support stabilizes
- Extract maze data to JSON file if maze editing becomes frequent
- Add JSDoc comments for better IDE autocomplete
- Split game-logic.js if it grows beyond 1000 lines
