# 2026-03-09: Asset naming convention

**By:** Joaquín (via Copilot)

## What
All game assets follow the naming pattern: `{character}_{action}_{variant}.png` in `assets/sprites/{character}/`. This prevents naming mismatches between sprite creators and code consumers.

## Why
M3 will have Nien creating sprites while Chewie/Lando reference them in code. Without a shared convention, names will diverge and create integration friction.

## Details
- Character names: lowercase, no spaces (kael, rhena)
- Actions: lowercase, matches state names (idle, walk, jump, punch, kick, throw, hit, ko, block)
- Variants: attack strength suffix (lp, mp, hp, lk, mk, hk) — omit for non-attack states
- Spritesheets: `{character}_{action}_sheet.png`
- Stage assets: `assets/stages/{stage_name}/{element}.png`

See `ASSET-NAMING-CONVENTION.md` for full reference.
