# Decision: Movement is Free in Flora

**Author:** Lando (Gameplay Developer)
**Date:** 2026-07-25
**Status:** Implemented
**Scope:** Flora — Player Controller (PR #21)

## Decision

Movement does not consume action points. Only tool use (water, harvest, remove-pest) costs actions and can trigger day advancement.

## Rationale

With 3 actions/day on an 8×8 grid, charging AP for movement made the game unplayable — the player could only move 3 tiles before the day auto-advanced. The acceptance criteria states "using tool ends turn (advances day)," confirming movement should be free. This is a core feel decision: exploration should feel unrestricted, while resource management applies to tool actions.

## Impact

- Players can freely explore the garden each day
- Strategic decisions are about *where* and *when* to use tools, not whether to move
- Day advancement is exclusively tied to tool action success
