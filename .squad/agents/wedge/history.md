# Wedge — History (formerly Hockney)

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

- Created comprehensive README.md with project overview, quick start guide, controls, and tech stack
- Included sections covering:
  - Project description (beat 'em up game inspired by The Simpsons Arcade, Final Fight, Streets of Rage)
  - Quick start instructions with local server options for ES modules
  - Controls mapping (WASD/arrows for movement, J/Z for punch, K/X for kick, Space for jump, Enter to start)
  - Tech stack (Pure HTML/CSS/JS, ES modules, HTML5 Canvas, Web Audio API)
  - Project structure showing src/engine, src/entities, src/systems, src/scenes, src/ui organization
  - 30-minute scope note explaining what was included (playable level, combat, enemy waves) vs. scoped out (multiple characters, power-ups, save system, multiple levels, sprite sheets, proper audio)

- Implemented localStorage high score persistence (P0-1):
  - Created `src/ui/highscore.js` utility with `getHighScore()`, `saveHighScore(score)`, `isNewHighScore(score)`
  - All localStorage access wrapped in try/catch for private browsing graceful fallback
  - Title screen shows "HIGH SCORE: {value}" in Simpsons yellow below controls (only if > 0)
  - Game over screen shows current score + high score below it
  - Level complete screen shows "NEW HIGH SCORE!" if beaten, otherwise shows existing high score
  - `saveHighScore()` returns boolean indicating if a new record was set — used to toggle display text
  - Used `highScoreSaved` flag in gameplay to prevent duplicate saves

- Implemented combo counter HUD display (P1-6):
  - Added `update(dt, player)` method to HUD for time-based combo animation state
  - Tracks previous combo count to detect combo growth and resets
  - Pop effect: text scales from 1.5x → 1.0x over 0.2s when combo increases
  - Color progression: Simpsons yellow (#FED90F) at 2 hits → orange at 3+ → red at 5+
  - Text size scales with combo count (36px base + 2px per combo hit, capped at +16px)
  - Quick fade-out (~0.25s) when combo drops below 2
  - Shows damage multiplier (x1.1, x1.2, etc.) in smaller text below the combo count
  - Used `ctx.save()`/`ctx.restore()` + `globalAlpha` for clean alpha-based fade without polluting canvas state
  - Wired `hud.update()` into gameplay scene's update loop right after player update
