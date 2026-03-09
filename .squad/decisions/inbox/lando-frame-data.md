# Decision: Frame Data Authority and Base .tres Consolidation

**Author:** Lando (Gameplay Developer)
**Date:** 2026-03-09
**Context:** Issues #108, #109, #110 — Sprint 1 playtest frame data bugs

## Decision

**Character moveset .tres files are the authoritative runtime source for frame data.** Base .tres files (fighter_base/, attack_state/, block_state/) are reference/validation data only.

## Rationale

- fighter_base/ and attack_state/ contain identical data — redundancy invites drift
- Character movesets already contain character-specific tuning (e.g., Rhena HP active=5f vs Kael HP active=4f)
- FighterMoveset.get_normal() is the runtime lookup path — base .tres are never loaded at runtime

## Recommendation

1. Consolidate fighter_base/ and attack_state/ into a single directory (or remove one)
2. Add a validation script that checks character moveset values against GDD ranges
3. Consider auto-generating base .tres from frame-data.csv to prevent manual drift

## Impact

- Affects: Chewie (state machine references), Tarkin (animation frame data), Yoda (GDD updates)
- No runtime behavior change — this is a data organization decision
