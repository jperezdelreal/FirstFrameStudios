# P0 Combat Pipeline Integration Fix

**Author:** Lando (Gameplay Developer)
**Date:** 2026-03-09
**Status:** Proposed
**Scope:** Ashfall combat system — affects all agents touching hit/damage pipeline

## Decision

The combat damage pipeline (hitbox → EventBus.hit_landed → fight_scene → take_damage) was broken at two independent points: missing collision geometry and mismatched function signatures. Both bugs existed since the initial implementation because hitbox.gd, fight_scene.gd, and fighter_base.gd were authored by different agents without a live integration test.

## Key Fixes
1. **Hitbox geometry** must be defined in the scene file, not left empty. CollisionShape2D with RectangleShape2D (36x24) added under Hitboxes/Hitbox.
2. **take_damage signature** aligned: fight_scene.gd now passes all 3 args (damage, knockback_force, hitstun_frames) from the hit_data dictionary.

## Team Impact
- **All agents:** When building cross-module pipelines (emitter → signal → consumer), the full chain must be tested end-to-end before the PR merges. Signal signatures and scene node hierarchies are the most common mismatch points.
- **Tarkin:** When wiring AnimationPlayer-driven hitbox activation, the Hitbox node + CollisionShape2D now exist in fighter_base.tscn. Per-move hitbox sizing can override the default 36x24 shape via MoveData or AnimationPlayer tracks.
- **Ackbar:** The hit_data dictionary keys used are `knockback_force` and `hitstun_duration` (matching hitbox.gd's emit). Any future additions to hit_data should be documented.

## Why
Two P0 bugs blocking Sprint 0 ship. Both were integration seams — individually correct modules that failed when connected. This is our most common bug pattern in multi-agent development.
