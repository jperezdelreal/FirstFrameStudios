## Ashfall — Game Flow Screens (Issue #12, PR TBD)
**Date:** 2025-07-23
**Branch:** `squad/12-menus`
**Files:** `scenes/ui/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scenes/ui/character_select.tscn`, `scripts/ui/character_select.gd`, `scenes/ui/victory_screen.tscn`, `scripts/ui/victory_screen.gd`, `scripts/systems/scene_manager.gd`, `project.godot`

Built the complete game flow UI for Ashfall. Key deliverables:

- **Main Menu:** "ASHFALL" title with sine-wave ember glow pulse (warm white ↔ orange outline), 4 buttons (VS CPU, VS Player, Options, Quit) with dark volcanic panel styling + ember-orange borders. Options panel overlays with Master/SFX/Music volume sliders (placeholder — no audio bus wired yet). First Frame Studios credit at bottom. Full keyboard/gamepad navigation via focus neighbors. ESC closes options.

- **Character Select:** Two-panel layout (P1 left, P2 right) with VS in center. Colored rectangles as portrait placeholders (Kael = blue, Rhena = red). P1 navigates with A/D (p1_left/p1_right), confirms with U (p1_light_punch), cancels with L (p1_block). P2 uses arrow keys and numpad. In VS CPU mode, P2 auto-picks the opposite character. Shows character name + archetype ("Balanced" / "Rushdown"). 0.5s delay after both confirm before fade transition. ESC backs out or deconfirms.

- **Victory Screen:** "[NAME] WINS!" in gold with glow pulse. Dynamic stat rows (rounds, total damage, longest combo, ember spent) built from SceneManager.match_stats dictionary. Rematch and Main Menu buttons with focus neighbors.

- **Scene Manager (autoload):** CanvasLayer at layer 100 with ColorRect overlay for fade-to-black transitions (0.4s each direction via Tween). Stores game_mode ("vs_cpu"/"vs_player"), p1/p2 character selections, and match_stats across scene changes. Methods: `goto_main_menu()`, `goto_character_select(mode)`, `goto_fight()`, `goto_victory(winner, stats)`, `rematch()`. Listens to EventBus.scene_change_requested for decoupled scene transitions.

- **project.godot updates:** Set `run/main_scene` to `res://scenes/ui/main_menu.tscn`. Added `SceneManager` to autoload list.

**Learnings:**
- Scene manager as CanvasLayer autoload at layer 100 keeps fade overlay above all game content including the fight HUD (layer 10).
- Tween chain (fade in → swap scene → fade out → re-enable input) prevents input during transitions without manual state tracking.
- Character select uses `wrapi()` for index cycling — cleaner than modulo with boundary checks.
- VS CPU mode auto-mirrors character selection (picks opposite of P1) — no P2 input handling needed.
- All buttons use unique_name_in_owner for `%Name` access pattern, matching fight_hud.tscn conventions.
- Dark volcanic palette (bg: 0.04/0.03/0.06, panels: 0.06-0.12 with ember-orange borders) carries the Ashfall art direction from GDD into menus.

---


## Project Context
- **Project:** Ashfall (1v1 fighting game, Godot 4) + firstPunch (browser beat 'em up)
- **User:** joperezd


## Ashfall — Fight HUD (Issue #5, PR #19)
**Date:** 2025-07-22  
**Branch:** `squad/5-hud`  
**Files:** `scenes/ui/fight_hud.tscn`, `scripts/ui/fight_hud.gd`

Built the complete fight HUD for Ashfall. Key deliverables:

- **Health bars (P1 left, P2 right):** Smooth lerp drain animation + ghost damage trail (white bar behind green, 0.5s delay then 400px/s drain). Dynamic colour shift: green → yellow → red as HP drops. P2 bar fills right-to-left (mirrored). Both use overlapping ProgressBars — ghost bar behind with dark background, health bar on top with transparent background.

- **Round timer:** 99-second countdown in a dark rounded panel at top-center between health bars. Red pulse warning animation when under 10 seconds (sine-wave lerp between warm white and red).

- **Round counter:** Dot indicators (● filled, ○ empty) below timer. P1 dots in blue, P2 dots in red. Synced from GameState.scores on round_ended signal.

- **Ember meter:** Per-player bars below health bars (max 100, per GDD Ember System). Fill direction mirrors health bars. Glow pulse animation at 75+ ember (sine-wave between orange and bright amber). Darkened fill below 50.

- **Announcer:** "ROUND X" / "FIGHT!" / "K.O." centered on screen at 72px with 8pt black outline. Three-phase animation: punch-in scale (2.5x → 1x over 0.15s with ease curve), hold for ~1s, fade-out over 0.3s.

- **Signal wiring:** All updates flow through EventBus autoload — zero direct coupling to fighters or round manager. Connects to: fighter_damaged, fighter_ko, round_started, round_ended, match_ended, timer_updated, announce, ember_changed.

**Learnings:**
- StyleBoxFlat sub-resources in .tscn are shared between nodes — must duplicate before per-bar colour mutation (used `_ensure_own_fill()` pattern with meta flag)
- Ghost damage trail = two stacked ProgressBars: ghost behind with dark background + health on top with StyleBoxEmpty background. Clean visual separation without custom draw calls.
- CanvasLayer layer=10 for HUD. mouse_filter=IGNORE on all elements to prevent input interception.
- Building .tscn files by hand requires careful attention to layout_mode (1=anchors for Control children, 2=container for Container children) and anchors_preset values.

---


