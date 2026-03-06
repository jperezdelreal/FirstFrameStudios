# Lando — History (formerly McManus)

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

### Game Architecture (2026-06-03)
- **Engine Layer**: Core game loop (fixed timestep accumulator), renderer with camera/shake, input manager, Web Audio API
- **Entity Layer**: Player (Homer) and Enemy classes with state machines, animation, physics (jump, knockback)
- **Systems Layer**: Combat (hit detection, damage, knockback) and AI (approach/attack/retreat behaviors)
- **Scene Layer**: Title screen and Gameplay scene with wave-based progression
- **File Paths**:
  - `/src/engine/` - Core systems (game.js, renderer.js, input.js, audio.js)
  - `/src/entities/` - Game objects (player.js, enemy.js)
  - `/src/systems/` - Gameplay logic (combat.js, ai.js)
  - `/src/scenes/` - Game states (title.js, gameplay.js)
  - `/src/ui/` - Interface elements (hud.js)
- **Key Patterns**:
  - ES modules with clean imports/exports throughout
  - Fixed timestep game loop for consistent physics
  - Entity sorting by Y position for 2.5D depth
  - Camera locking system for wave-based encounters
  - Procedural Canvas drawing (no external assets)
  - Hit/hurtbox collision detection system
  - State machine pattern for character behavior

### Kick Visual Animation (2026-06-03)
- Added distinct kick pose in `player.js render()`: blue leg (#4682B4) extends from hip at 30° with gray shoe, clearly different from punch arm extension
- Kick renders when `this.state === 'kick' && this.attackCooldown > 0.2` (matches the state-to-idle transition timing)
- Arms stay at rest during kick — only the punch block triggers arm extension
- Created `/assets/README.md` documenting the procedural Canvas 2D art approach (no external images)

### Combo System (P1-5) + Jump Attacks (P1-7) (2026-06-03)
- **Combo tracking** added to `player.js`: `comboCount`, `comboTimer`, `comboWindow` (0.6s), `comboChain[]` — all public for UI readout
- Combo resets when `comboTimer > comboWindow` (no hits within 0.6s window)
- `comboChain` records attack types ('punch'/'kick') for finisher detection
- Ground attacks return `{ type, combo }` for scene/UI consumption
- **Combo damage scaling** in `combat.js`: `Math.min(2, 1 + comboCount * 0.1)` — 10% per hit, capped at 2x
- **Combo finisher**: punch-punch-kick pattern detected via last 3 entries in `comboChain` → 1.5x knockback + stronger screen shake (6px/0.15s vs 3px/0.1s)
- `comboCount` incremented on HIT (in `combat.js handlePlayerAttack`), not on input — prevents whiffed combo counting
- **Air attacks**: `jump_punch` (0.2s cooldown, 50px wide hitbox) and `jump_kick` (dive kick: 20 dmg, -800 jumpVelocity slam, 70x50 hitbox below player)
- `jump_punch` returns player to `jump` state when cooldown expires (if still airborne) or `idle` if landed
- `jump_kick` landing handled by existing jump physics — `jumpHeight <= 0` check now covers `jump_punch`/`jump_kick` states
- Added Canvas render poses: jump_punch (yellow arm forward), jump_kick (blue leg at 45° with gray shoe)
- **Attack stats table** in `combat.js` replaces ternary chains — cleaner mapping of state → damage/knockback/score
- **Known gap**: `gameplay.js` checks `attackResult.type === 'kick'` for audio — `jump_kick` falls through to punch sound. Cannot fix (Chewie owns that file). Noted for team coordination.
