# Flora Sprint 0 PR Review Decisions

**Author:** Solo (Lead / Chief Architect)
**Date:** 2026-03-11
**Status:** Active
**Scope:** Flora project — Sprint 0 integration

## Decisions Made

### 1. PR #20 Hazard System — Approved
Tarkin's hazard system is architecturally sound and ready to merge. Clean config→entity→system separation. Integration wiring (tile state updates on pest spawn) will be handled by Solo in a dedicated integration pass.

### 2. PR #21 Player Controller — Changes Requested
Three fixes required before merge:
- **Movement must not consume actions** — only tool use costs action points (per GDD §3)
- **ToolBar deselect callback bug** — onToolSelect never fires with null when toggling off
- **System interface conformance** — PlayerSystem needs `readonly name` property

### 3. Integration Gap Identified: Pest ↔ Tile State
Neither PR #20 nor PR #21 updates Tile.state to TileState.PEST when pests spawn. The remove-pest tool checks tile.hasPest(). Solo will wire this in the Sprint 0 integration PR.

### 4. Architecture Pattern Confirmation
Flora's Sprint 0 code correctly follows established patterns:
- SceneContext injection (no singletons)
- Fixed-timestep accumulator
- Entity/System interfaces
- Config-as-data for extensibility

## Impact on Team
- **Tarkin:** PR #20 can merge as-is
- **Lando:** PR #21 needs 3 targeted fixes, then re-review
- **Solo:** Will create integration PR to wire HazardSystem ↔ GardenScene ↔ tile state
- **Yoda:** Should confirm pest spawn behavior (one-shot per season vs. ongoing pressure)
