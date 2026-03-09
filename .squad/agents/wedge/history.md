# Wedge — History (formerly Hockney)

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

## firstPunch Context
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Domain Skill: ui-ux-patterns (P1, 2026-03-07)

**Status:** Complete

Created `.squad/skills/ui-ux-patterns/SKILL.md` — a universal, genre-agnostic Game UI/UX design framework covering:

- **Information Hierarchy & Glance Test:** The 4-tier model (Tier 1: Health, Tier 2: Actions, Tier 3: Progress, Tier 4: Reference). Player should understand state in <0.5 seconds.
- **Diegetic vs Non-Diegetic UI:** When UI exists in the world vs outside it; aesthetic consistency rules.
- **HUD Positioning & Timing:** Safe zones (40px margins), aspect ratio adaptation, state-based visibility (gameplay vs pause vs cutscene).
- **Menu Design Patterns:** Title screen (navigation flow, audio feedback), pause menu (ESC toggle, zero state loss), options menu (sliders + difficulty + controls display), game over screen (high score comparison, input delay).
- **In-Game Feedback UI:** Damage numbers (color-coded, floating, animated), combo counters (scaling, timeout, glow), score displays (rolling animation, zero-padded), health bars (player always visible, enemy contextual), wave progress indicators.
- **Responsive Design for Games:** DPR scaling (HiDPI support), letterboxing (aspect ratio preservation), text sizing (10px minimum logical, responsive scaling formula), layout adaptation for 4:3/16:9/16:10/21:9 aspect ratios.
- **Animation & Transitions:** Menu transitions (fade, slide, scale+bounce), HUD element entrance/exit (slide+fade, emphasis pulses), button feedback (0.95x press state), no instant cuts (0.3-0.5s is standard).
- **Accessibility Basics:** Colorblind modes (don't use color alone; add symbols/patterns), text contrast ratios (4.5:1 WCAG AA minimum), button prompts (show current control scheme), subtitle/caption support.
- **Anti-Patterns:** UI overload (apply hierarchy), invisible state (always provide feedback), modal trap (ESC always exits), mouse-first action games (keyboard/gamepad primary), unscaled HUD (responsive layout), no input feedback (SFX on menu nav), instant state changes (animate everything), color-only info (add icons).
- **firstPunch Learnings:** What shipped (arcade HUD, style meter, title screen, pause menu, options menu, game over screen, level intro, enemy health bars, wave progress, HiDPI support, high score persistence), what worked (hierarchy, dark panels, rolling score, menu SFX, button feedback, letterboxing), what to improve (boss health bar separate, accessibility audit, rebindable controls, loading screen framework, text sizing algorithm, tutorial system).

**Confidence: `medium`** — Earned through shipped features in firstPunch. Patterns are universally applicable to any game genre. Validated in one project; ready for cross-project use.

**Cross-game applicability:** Directly transfers to RPGs (HUD hierarchy applies), puzzle games (information hierarchy), platformers (simple HUD), strategy games (complex HUD, same principles), roguelikes (combo counter → run timer), racing games (different Tier structure, same framework).

**Key insight:** UI is not optional polish — it's the primary interface between player and game state. Every design decision should answer: "Can a player glance once and understand their situation?" If not, apply hierarchy. If still not, add feedback (visual + audio). If still not, simplify.

**Session tag:** Skills Gap Remediation (2026-03-07T12:57:00Z) — P1 gap from Ackbar audit. Orchestration log: `.squad/orchestration-log/2026-03-07T12-57-skills-creation.md`

## Learnings

- Created comprehensive README.md with project overview, quick start guide, controls, and tech stack
- Included sections covering:
  - Project description (beat 'em up game inspired by classic arcade beat 'em ups, Final Fight, Streets of Rage)
  - Quick start instructions with local server options for ES modules
  - Controls mapping (WASD/arrows for movement, J/Z for punch, K/X for kick, Space for jump, Enter to start)
  - Tech stack (Pure HTML/CSS/JS, ES modules, HTML5 Canvas, Web Audio API)
  - Project structure showing src/engine, src/entities, src/systems, src/scenes, src/ui organization
  - 30-minute scope note explaining what was included (playable level, combat, enemy waves) vs. scoped out (multiple characters, power-ups, save system, multiple levels, sprite sheets, proper audio)
- **UI _process vs _physics_process (#122, #123, #126):** Gameplay-affecting HUD (fight_hud) must use `_physics_process` for frame-synced updates per Rule 7. Cosmetic-only animations (menu glow, victory glow) can stay `_process` since delta is acceptable for visual interpolation. When converting timers to frame-based, replace float constants with integer frame counts (e.g., `GHOST_DELAY: float = 0.5` → `GHOST_DELAY_FRAMES: int = 30` at 60 FPS). Use `git worktree` when multiple squad agents are concurrently modifying the same repo to avoid branch-switching conflicts.

- Implemented localStorage high score persistence (P0-1):
  - Created `src/ui/highscore.js` utility with `getHighScore()`, `saveHighScore(score)`, `isNewHighScore(score)`
  - All localStorage access wrapped in try/catch for private browsing graceful fallback
  - Title screen shows "HIGH SCORE: {value}" in character yellow below controls (only if > 0)
  - Game over screen shows current score + high score below it
  - Level complete screen shows "NEW HIGH SCORE!" if beaten, otherwise shows existing high score
  - `saveHighScore()` returns boolean indicating if a new record was set — used to toggle display text
  - Used `highScoreSaved` flag in gameplay to prevent duplicate saves

- Implemented combo counter HUD display (P1-6):
  - Added `update(dt, player)` method to HUD for time-based combo animation state
  - Tracks previous combo count to detect combo growth and resets
  - Pop effect: text scales from 1.5x → 1.0x over 0.2s when combo increases
  - Color progression: character yellow (#FED90F) at 2 hits → orange at 3+ → red at 5+
  - Text size scales with combo count (36px base + 2px per combo hit, capped at +16px)
  - Quick fade-out (~0.25s) when combo drops below 2
  - Shows damage multiplier (x1.1, x1.2, etc.) in smaller text below the combo count
  - Used `ctx.save()`/`ctx.restore()` + `globalAlpha` for clean alpha-based fade without polluting canvas state
  - Wired `hud.update()` into gameplay scene's update loop right after player update

- Implemented Game Over Screen improvements (P1-13):
  - Added dark semi-transparent overlay (rgba 0,0,0,0.7) behind game over text for readability
  - Shows "NEW HIGH SCORE!" banner in character yellow when high score is beaten
  - Displays current score and high score below GAME OVER text
  - Added 0.5s `gameOverTimer` delay before accepting ENTER input to prevent accidental skip
  - High score already saved on game over via existing `highScoreSaved` flag

- Implemented Pause Menu (P1-20):
  - Added `isPause()` and `isQuit()` helper methods to Input class (Escape and Q keys)
  - ESC toggles `this.paused` state — when paused, update loop returns early (no movement/combat)
  - Pause check runs before other input processing so game inputs are blocked while paused
  - Dark overlay (0.6 alpha) with "PAUSED" title, "Press ESC to Resume", "Press Q to Quit"
  - Q while paused calls `switchScene('title')` for clean quit-to-title

- Implemented Enemy Health Bars (P1-18):
  - Extended `hud.render()` signature to accept `enemies` array and `cameraX` for world-to-screen conversion
  - Health bars only render for damaged enemies (health < maxHealth) and skip dead enemies
  - 30px wide × 4px tall bars positioned above enemy head (enemy.y - 10), offset by cameraX
  - Dark red (#8B0000) background with green (#00FF00) fill proportional to health percentage
  - Updated gameplay render call to pass enemies and cameraX to HUD

- Implemented Level Intro Text (P2-17):
  - Added `introActive`, `introTimer` (2s), `introElapsed` state to gameplay `onEnter()`
  - During intro: update loop returns early after counting elapsed time — no entity updates
  - Render draws dark overlay (0.8 alpha) with "STAGE 1" (72px bold yellow with stroke) and "DOWNTOWN" (28px white with stroke)
  - Alpha fades in over first 0.3s, holds, fades out over last 0.3s using `ctx.globalAlpha`
  - Input is consumed and discarded during intro to prevent premature actions
  - Uses `ctx.save()`/`ctx.restore()` to isolate globalAlpha and text state

- Implemented Title Screen Polish (P2-10):
  - Added gradient sky background (dark purple → blue) replacing flat #87CEEB
  - Scrolling Downtown skyline: 20 procedurally-generated buildings with random height/width/shade, window dots, wrapping via modulo
  - Brawler silhouette at right side using basic canvas shapes (arc for head, ellipse for body, rects for legs, arc for belly bump) in subtle yellow (0.18 alpha)
  - Yellow star particles: spawned randomly (~2.5/sec), float upward with drift, fade out over time, cleaned up when off-screen
  - Moved title to top third (18% height), controls to 75% height, "Press ENTER" centered at 55% with pulsing glow (`shadowBlur` + `globalAlpha` sine wave)
  - Added "A firstPunch Production" credit line at very bottom in small subtle white text
  - High score display repositioned below controls

- Modernized HUD to arcade quality (hud.js):
  - Replaced flat health bar with rounded-corner gradient bar (green→yellow→red) with glossy highlight overlay and edge glow
  - Added dark inset background (`#1a0000`) with `_roundRect()` helper for all rounded shapes
  - Mini Brawler head icons: yellow circle head, white eyes with pupils, mouth arc — used for avatar next to health bar and lives display
  - "BRAWLER" label in bold `Arial Black` with dark stroke outline for readability
  - Score display redesigned: "SCORE" label in small text above, zero-padded 7-digit number below in large bold yellow (#FED90F) with dark outline
  - Score lerp: `displayedScore` smoothly ticks toward actual score at 12% per frame via `Math.ceil((score - displayedScore) * 0.12)`
  - Lives display: small Brawler head icons rendered via `_drawPlayerIcon()`, count driven by `player.lives`
  - Semi-transparent dark panels (rgba 0,0,0,0.55) with rounded corners behind health and score areas
  - Combo counter enhanced: added `comboGlowTime` and `shadowBlur` pulse effect (sine wave oscillation) for glow on hit combos
  - Enemy health bars upgraded to rounded rectangles with gradient fill and subtle white border
  - All fonts switched to `"Arial Black", Arial, sans-serif` for bold arcade feel

- Modernized Title Screen to arcade quality (title.js):
  - Title text now uses manual `ctx.strokeText`/`fillText` with double-stroke technique (8px dark outer + 4px brown inner + yellow fill) and drop shadow offset
  - Subtitle "BEAT 'EM UP" rendered with thick dark outline for depth
  - High score moved to prominent position (38% height) with star decorations (★) and outlined yellow text
  - Controls section completely redesigned with key cap icons: `_drawKey()` draws 3D-looking rounded rectangles with gradient faces, shadow depth, and white labels
  - Controls organized in two rows inside a semi-transparent panel: movement keys (WASD / arrows) and action keys (J/Z Punch, K/X Kick, SPACE Jump)
  - "Press ENTER" glow pulse enhanced with `lineJoin: 'round'` and `Arial Black` font
  - Gradient sky deepened (added `#0d0d2b` at top for darker night feel)
  - All text rendering switched from `renderer.strokeText()`/`renderer.fillTextCentered()` helpers to direct `ctx` calls for finer control over outlines, shadows, and layering

- CSS enhancements (styles.css):
  - Added `box-shadow: inset 0 0 80px 30px rgba(0,0,0,0.5)` on `#gameCanvas` for subtle vignette effect
  - Added `cursor: none` on both `body` and `#gameCanvas` to hide cursor during gameplay

- Implemented Style/Combo Scoring Meter (AAA-C4):
  - Vertical style meter bar on left side of HUD (22x100px) with rounded panel background
  - Fills based on unique attack types used (punch, kick, jump_attack, special) via `player.styleTypes` Set
  - Formula: `min(100, uniqueTypes * 18 + comboCount * 2)` — variety is king, combo length helps
  - 5 retro-themed thresholds with distinct colors: "Meh" (grey 0-20%), "Not Bad" (yellow 20-40%), "Radical!" (orange 40-60%), "Excellent!" (green 60-80%), "Best. Combo. Ever." (gold 80-100%, pulsing glow)
  - Score multiplier per threshold: 1x → 1.5x → 2x → 3x → 5x, shown below meter and in combo display
  - Resets on damage — tracked via `prevHealth` in HUD and `player.styleTypes.clear()` in gameplay
  - Natural decay (15/sec) when not actively comboing, smooth fill lerp (12% per frame)
  - Added `styleTypes` Set to Player entity, populated with type on each attack
  - HUD panel shifted right (x:42) to make room for the style meter column

- Implemented Options/Settings Menu (AAA-U1):
  - Created `src/scenes/options.js` with full scene lifecycle
  - 3 volume sliders (Master, SFX, Music) — hold left/right to adjust at 0.8/sec, wired to `audio.set*Volume()`
  - Difficulty selector with 3 modes: "Chill Mode (Easy)" / "Normal" / "Ringleader (Hard)" — stored on `game.difficulty`
  - Read-only controls display showing all key bindings in two-column layout
  - BACK button with pulsing selection indicator
  - Navigation via up/down arrows, adjustment via left/right, ESC or ENTER on BACK to exit
  - Selection highlight with yellow border glow on focused item
  - Dark gradient background with rounded panel matching HUD aesthetic
  - Footer hint showing navigation controls

- Title screen menu system (AAA-U1):
  - Replaced "Press ENTER to Start" with selectable menu: "START GAME" / "OPTIONS"
  - `menuIndex` tracks selection, up/down arrows navigate, ENTER confirms
  - Selected item shows pulsing yellow glow with `▸ ◂` indicators, unselected items dimmed
  - Audio feedback via `playMenuSelect()` and `playMenuConfirm()`
  - Title constructor now accepts `audio` parameter for UI sounds
  - Updated `main.js` to pass audio to TitleScene and register OptionsScene

- Pause menu → Options navigation:
  - Added "Press O for Options" to pause overlay
  - `isOptions()` helper added to Input class (KeyO)
  - Scene suspend/resume mechanism: `game._suspendScene` flag skips onExit cleanup, `game._resumeScene` flag skips onEnter reinitialization
  - Gameplay state (player, enemies, score, music) preserved across options round-trip
  - Returns to paused state after options exit

- Implemented Wave/Progress Indicator (AAA-U4):
  - Small progress dots at top-center of HUD with dark rounded background
  - Each wave shown as circle: filled yellow = completed, pulsing outline = current, outlined grey = remaining
  - Current wave circle has expanding pulse ring animation
  - "WAVE" label below dots
  - Wave info computed in gameplay render: last spawned index, completed count based on enemy presence
  - HUD `render()` signature extended with optional `waveInfo` parameter
  - `game.difficulty` property added to Game constructor (default: 'normal')

- Fixed text rendering crispness and CSS canvas scaling:
  - Removed `image-rendering: crisp-edges` and `image-rendering: pixelated` from `styles.css` — replaced with `image-rendering: auto` for smooth procedural art upscaling
  - Added `drawCrispText()` helper function at top of `hud.js` — wraps `ctx.save/restore`, rounds x/y to integers via `Math.round()`, supports outline/stroke, configurable font/color/align/baseline
  - Replaced all direct HUD text draws (BRAWLER label, health text, LIVES, SCORE label, score value, BRUISER boss bar text) with `drawCrispText()` calls
  - Rounded combo counter positions (`rcx`, `rcy`) and multiplier text positions
  - Rounded enemy health bar positions (`bx`, `by`) for pixel-perfect alignment
  - Rounded style meter text positions (STYLE label, threshold label, multiplier) and WAVE label
  - Rounded all title screen text positions: title, subtitle, high score, menu items, controls panel, credits
  - Bumped title font from 72px → 76px and subtitle from 28px → 30px for HiDPI readability
  - Set `ctx.imageSmoothingEnabled = true` at start of HUD render
  - Pre-computed `hw = Math.round(w / 2)` in title.js for consistent centered text alignment
  - Increased BRAWLER label font from 13px → 14px, health text from 11px → 12px, SCORE label from 11px → 12px

- **Bug #94 — HUD round dots not syncing (PR #98):**
  - Root cause: RoundManager maintained its own `scores` array but never synced to `GameState.scores`. The HUD reads `GameState.scores` via `_on_round_ended`, so dots always showed 0-0.
  - Fix: Added `GameState.scores` sync in RoundManager after every score mutation (KO, time-over winner, and draw paths).
  - Also wired `EventBus.round_draw` to the HUD — draw rounds previously had no HUD handler, so dots wouldn't update on draws either.
  - **Lesson:** When two systems track the same data (RoundManager.scores vs GameState.scores), the authoritative source must sync to the shared singleton. UI should always read from the single source of truth (GameState), never from system-local state.
