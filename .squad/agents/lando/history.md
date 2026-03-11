# Lando — History (formerly McManus)

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

### Flora Player Controller Implementation (2026-03-11)
- **Task**: Implemented player controller with movement and tool actions for Flora issue #6
- **Tech Stack**: Vite + TypeScript + PixiJS v8, strict mode TypeScript
- **Files Created**:
  - `src/entities/Player.ts` — Player entity with grid position, selected tool, action points, movement state
  - `src/config/tools.ts` — Tool definitions (water, harvest, remove-pest) with validation and execution logic
  - `src/systems/PlayerSystem.ts` — Handles keyboard/click input, movement animation, tool action execution
  - `src/ui/ToolBar.ts` — Three-button tool selector UI with hover states and selection highlighting
- **Architecture Patterns**:
  - Player entity uses immutable state snapshots (getState() returns readonly copy)
  - Movement uses grid coordinates (row/col) with smooth animated transitions between tiles
  - Tool system uses strategy pattern: each tool has validate/execute methods
  - Input handling separates keyboard movement (WASD/arrows) from click-to-move
  - Action points system: 3 actions per day, tool use consumes action, day advances when actions depleted
- **Game Feel Details**:
  - Movement uses easeInOutCubic interpolation over 0.3s for smooth tile-to-tile transitions
  - Player rendered as blue circle (16px radius) with outline
  - Tool bar positioned at bottom center with 80x80px buttons showing emoji icons
  - Selected tool highlights with blue background (0x4a9eff)
  - Action feedback shows message in info text for 2 seconds
- **Integration Points**:
  - PlayerSystem hooks into existing InputManager for keyboard events
  - GridSystem click events route to PlayerSystem for click-to-move
  - Tool actions validate against Tile and Plant state before executing
  - Day advancement callback triggers plant growth updates
- **Scene Architecture**: GardenScene now receives SceneContext (app, input, assets, sceneManager) via Scene interface, ensuring all scenes have consistent access to core systems
- **Build/Deploy**: Used git worktrees for parallel safety (flora-wt-6), built with TypeScript + Vite, created PR #21 to main branch
- **Known Gaps**: Plant rendering not yet implemented (plants exist in memory but not visually), no pathfinding for non-adjacent tiles (click-to-move only works on same row/col)

### Game Architecture (2026-06-03)
- **Engine Layer**: Core game loop (fixed timestep accumulator), renderer with camera/shake, input manager, Web Audio API
- **Entity Layer**: Player (Brawler) and Enemy classes with state machines, animation, physics (jump, knockback)
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

### Lives System (P2-12) + Special Moves (P2-14) (2026-06-03)
- **Lives system**: `this.lives = 3` in player constructor. `takeDamage()` decrements lives when health hits 0; if lives > 0, respawns in place (health=100, invulnTime=2.0, state='idle', clear knockback/hitstun). If lives === 0, existing 'dead' state. `player.lives` is public for HUD readout.
- **Belly bump** (`belly_bump` state): Triggered when `comboCount >= 3`, `specialCooldown <= 0`, player holds forward + punch. Lunges 100px forward, 80px wide frontal hitbox, 25 dmg, 300 knockback, 1.5s specialCooldown. Canvas render: extended belly ellipse + swept-back arm.
- **Ground slam** (`ground_slam` state): Triggered in jump state when `jumpHeight > 0`, down + punch pressed. Immediately lands (jumpHeight=0, jumpVelocity=0), 200px wide shockwave hitbox centered on player, 20 dmg, 200 knockback. Canvas render: arms spread wide + golden shockwave ring at feet.
- **Combat integration**: Both new attack types added to `attackStats` table in `combat.js`. Ground slam uses position-relative knockback (enemies pushed away from player center, not facing-based). Both special moves get 'heavy' hit intensity and 6px/0.15s screen shake.
- **Input detection order**: belly bump checked before regular punch in idle/walk block (consumes isPunch if conditions met); ground slam checked before air attacks in jump block. `specialCooldown` is separate from `attackCooldown` — belly bump has 1.5s cooldown, ground slam uses standard attackCooldown only.
- **Known gap**: `gameplay.js` audio routing doesn't handle `belly_bump`/`ground_slam` attack types — will fall through to default punch sound. Same pattern as `jump_kick` gap. Chewie owns that file.

### Grab/Throw + Dodge Roll + Back Attack (2026-06-04)
- Added grab/throw handling in `player.js` with grab detection, pummel tracking, auto-throw after 3 hits, escape timer, and dodge roll/back-attack states with timing, cooldowns, and roll squash.
- `combat.js` now applies grab pummel damage, throw launch damage, projectile collisions for thrown enemies, and back-attack stats while freezing grabbed enemies next to the player.
- `input.js` gained grab/dodge helpers (G/C and L/Shift) and rendering updates cover dodge roll posture and back-attack arm posing.

### Game Feel / Juice Skill (P0) (2026-03-07)
- Created `.squad/skills/game-feel-juice/SKILL.md` — comprehensive, studio-wide reference for impact feedback techniques.
- **Content delivered:**
  - Definition: juice as feedback layer that makes interactions satisfying (not cosmetic, core mechanic)
  - 9 core techniques: hitlag, screen shake, hitstun, knockback, flash, particles, squash-and-stretch, sound sync, time manipulation
  - Detailed how-to for each technique with code examples, tuning values, and anti-patterns
  - Patterns by game event: attack connects, player jumps, player takes damage, enemy dies, boss phase transition, UI interaction
  - Tuning guidelines: 60fps rule, start subtle + dial up, layer don't stack, toggle test methodology
  - 10 anti-patterns we learned: juice fatigue, desync, constant motion, copy-paste juice, juice on non-events, knockback direction
  - P0-P3 implementation checklist (hitlag → screen shake → flash → sound sync → particles → knockback → squash-stretch → time manipulation)
  - firstPunch learnings: what worked (hitlag foundation, knockback as feedback), what we'd do differently (juice from start, scale with combo, particle system early, audio specialist)
  - Genre applications: beat 'em up, platformer, fighting game, puzzle, 3D action
  - Quick reference checklists for attack types, movement, enemy death, boss phase
- **Confidence: `medium`** — validated in firstPunch (hitlag, screen shake, knockback, sound sync proven shipped); reference games confirm universality (Celeste, SoR4, Hollow Knight, Gungeon, Hades); boss design and advanced effects not yet fully validated in our shipped code
- **Addresses Ackbar's audit (P0 gap):** Game feel had no dedicated skill; patterns were scattered across 3 skills. This unified reference aligns with Principle #1 (Player Hands First) — now the first skill new agents should read when implementing ANY feature with impact.
- **Cross-referenced:** state-machine-patterns (state triggers), beat-em-up-combat (frame data), 2d-game-art (particles), game-qa-testing (juice toggle test), godot-beat-em-up-patterns (GDScript examples)
- **Session tag:** Skills Gap Remediation (2026-03-07T12:57:00Z) — Orchestration log: `.squad/orchestration-log/2026-03-07T12-57-skills-creation.md`
