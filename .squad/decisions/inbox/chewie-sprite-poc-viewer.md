# Decision: Sprite PoC Test Viewer

**Author:** Chewie (Engine Developer)
**Date:** 2026-07-22
**Status:** Implemented
**Scope:** Test tooling — `games/ashfall/scenes/test/` and `games/ashfall/scripts/test/`

## What

Created a standalone test scene (`sprite_poc_test.tscn` + `sprite_poc_test.gd`) that loads and displays the PoC sprites generated for Kael. Plays idle (8fps), walk (10fps), and LP (60fps) animations over the Embergrounds background with keyboard controls.

## Files Created

- `games/ashfall/scenes/test/sprite_poc_test.tscn` — Minimal Node2D scene
- `games/ashfall/scripts/test/sprite_poc_test.gd` — All logic, data-driven animation config

## Design Choices

1. **Fully programmatic scene** — Script creates all nodes in `_ready()`. The .tscn is just a root Node2D with the script attached. Zero manual editor work needed; easy to diff and review.
2. **Data-driven ANIM_CONFIG** — Adding new animations (walk_back, MP, HP, etc.) requires only a new dictionary entry and the PNG files. No code changes.
3. **Runtime texture filter** — Set `TEXTURE_FILTER_NEAREST` on the AnimatedSprite2D node instead of modifying `.import` files. Keeps the viewer self-contained without affecting other scenes that might use these assets.
4. **Center-bottom origin** — `offset = Vector2(0, -256)` so the node position represents feet. Matches fighting game convention where character position = ground contact point.
5. **LP auto-return** — Non-looping animations return to idle via `animation_finished` signal, driven by the `loop` flag in config.
6. **Scale 0.4** — Renders the 512×512 sprite at ~205px on a 1080p screen. Reasonable fighting game character size. The 30×60 collision box proportions (1:2 ratio) will be handled by the collision system, not the visual scale.

## How to Run

Set `sprite_poc_test.tscn` as the main scene in Godot editor (Project → Project Settings → Run → Main Scene), or run it directly via Scene → Run Current Scene (F6) with the scene open.

## Impact

Test-only. No production code affected. No autoloads required (the viewer is self-contained). Other agents can use this pattern for future sprite/animation test viewers.
