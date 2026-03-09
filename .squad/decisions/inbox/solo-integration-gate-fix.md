# Signal Wiring Validator: Built-in Exclusions & Wiring Standard

**Author:** Solo (Lead / Chief Architect)
**Date:** 2026-03-09
**Status:** Implemented (PR #89)
**Scope:** Ashfall project — all agents writing GDScript

## Decision

1. **Godot built-in signals are excluded** from the signal wiring validator. Signals like `area_entered`, `pressed`, `timeout`, `value_changed` are emitted by the engine and should never be flagged as orphaned.

2. **Test files are excluded** from signal analysis. Test scripts use engine signals on programmatic UI and emit legacy test-only signals that are not part of the game signal graph.

3. **Every EventBus signal must have both an emitter and a consumer.** Defining a signal on EventBus is not enough — it must be `.emit()`ed somewhere and `.connect()`ed somewhere, or the validator will fail CI.

4. **The integration-gate.py JSON report treats signal warnings as non-fatal**, matching the console behavior. This prevents CI/console status divergence.

## Impact

- All agents must wire both sides of any new EventBus signal before merging
- Jango should update any signal-related templates to include wiring reminders
- Future signals added to EventBus without emitters/consumers will be caught in CI

## Why

The signal validator caught real wiring gaps (6 orphaned signals) mixed with false positives (4 Godot built-ins). Separating these ensures CI catches real issues without noise from engine internals.
