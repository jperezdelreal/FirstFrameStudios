# Decision: Instance FightHUD in fight_scene.tscn (not runtime)

**Date:** 2025-07-22
**Author:** Wedge (UI/UX Developer)
**Status:** Implemented

## Context

The FightHUD (`scenes/ui/fight_hud.tscn`) was fully implemented but never added to the fight scene tree. The fight scene had Stage, Fighters, and Camera2D — no HUD.

## Decision

Instance `fight_hud.tscn` directly in `fight_scene.tscn` rather than loading at runtime in GDScript.

**Reasons:**
1. The HUD is fully self-contained — it connects all 11 EventBus signals in its own `_ready()` via `_wire_signals()`. No external setup needed.
2. Scene-tree instancing is visible in the Godot editor, making the scene hierarchy inspectable.
3. The CanvasLayer (layer=10) ensures it renders above everything regardless of camera — no z-index coordination required.
4. `@onready` references resolve before `_ready()` runs, so fight_scene.gd can set name labels immediately.

## What Changed

- `fight_scene.tscn`: Added ext_resource for `fight_hud.tscn`, instanced as `FightHUD` child node
- `fight_scene.gd`: Added `@onready var hud` reference, set P1/P2 name labels from `SceneManager.p1_character`/`p2_character`

## Signal Verification

All 11 EventBus signals the HUD connects to are defined and emitted by existing systems (fight_scene.gd, RoundManager, ComboTracker). No missing signals.
