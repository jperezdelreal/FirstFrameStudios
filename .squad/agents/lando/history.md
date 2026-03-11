# Lando — History (formerly McManus)

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Goal:** Ship playable beat 'em up level in 30 minutes

## Learnings

### Historical Work (Sessions 1-15)

- Game Architecture (2026-06-03)
- Kick Visual Animation (2026-06-03)
- Combo System (P1-5) + Jump Attacks (P1-7) (2026-06-03)
- Lives System (P2-12) + Special Moves (P2-14) (2026-06-03)
- Grab/Throw + Dodge Roll + Back Attack (2026-06-04)
- Game Feel / Juice Skill (P0) (2026-03-07)
- Fighter Controller + Input Buffer (Issue #3) (2025-07-21)
- P0 Combat Bug Fixes (#92, #93) (2026-03-09)
- Frame Data Alignment (#108, #109, #110) (2026-03-09)
- Issue #108 — Medium Punch Startup Too Slow
- Issue #109 — Medium Kick Animation Glitch
- Issue #110 — HP/HK Damage & Directional Inconsistency
- Medium Attacks Added to Movesets
- Character Select P0 Fix v2 (2026-03-09)
- 2026-03-11 — Combat Code Fixes (#130, #132, #135)

### 2026-03-09 — Sprint 1 Audit Results: Process & Standards

**Cross-Agent Update:** Sprint 1 bug catalog identified 35 bugs with 7 mandatory process improvements for Sprint 2. Lando responsible for edge case test matrix (equal HP, timer expiry, simultaneous hits, double KO scenarios). GDSCRIPT-STANDARDS.md now mandatory (16 rules, starting Sprint 2 Day 1). See .squad/decisions/decisions.md.

### Sprint 2 Phase 4 — Combat Feel Tuning & Input Audit (2026-03-09)
- **Context:** Sprint 2 Phase 4 — fine-tune hitstun, blockstun, knockback for combat impact, verify input responsiveness.
- **PR:** #150 (squad/phase4-combat-feel), 28 files changed.
- **Critical Fix — Block damage pipeline was broken:** fight_scene.gd called `take_damage(chip, Vector2.ZERO, 0)` on blocked hits, which bypassed blockstun entirely by transitioning from block→hit(0 frames)→idle instantly. Fixed by adding `take_block_damage()` to fighter_base.gd and routing blocked hits through it, properly re-entering block_state with correct blockstun frames and pushback.
- **Block pushback tuning:** Scale factor reduced from 0.3 to 0.06 (GDD §2.6: 4-12px). Old value gave 24-54px pushback — 5x too much. Added attacker pushback on block (both fighters separate).
- **MoveData→Hitbox wiring gap fixed:** attack_state._activate_hitboxes() was enabling the hitbox but never setting its damage/knockback/hitstun from the current MoveData. All hits used default hitbox exports instead of per-move frame data. Now wires _current_move values into hitbox on activation.
- **blockstun_duration added to hit pipeline:** hitbox.gd now exports blockstun_duration and includes it in hit_data dict. attack_state wires MoveData.blockstun_frames into it. fight_scene reads it for proper block handling.
- **6-button input gap closed:** Added mp/mk to input_buffer._read_raw_input(), _empty_frame(), fighter_controller.BUTTON_PRIORITY (hk>hp>mk>mp>lk>lp), fighter_base.is_input_just_pressed(), and idle/crouch _any_attack_pressed(). Medium attacks are now accessible in gameplay (pending input action mapping in project.godot).
- **Reference .tres GDD alignment:** All 18 files across fighter_base/, attack_state/, block_state/ updated to match GDD §2.5: LP 12/8, MP 16/12, HP 22/16, LK 12/8, MK 16/12, HK 22/16. Previous values drifted by 1-8 frames.
- **Key Learnings:**
  - The block damage pipeline was fully broken — chip hits were exiting block state immediately. Always trace the full signal chain (hitbox→EventBus→fight_scene→fighter_base→state_machine) end-to-end when auditing combat feel. A "feels wrong" complaint often hides a completely non-functional system.
  - hitbox.gd exports are defaults, not authoritative. The authoritative frame data lives in MoveData .tres and must be wired at activation time by attack_state. Without this wiring, all attacks hit identically regardless of move type.
  - Block pushback math: knockback × 0.06 with decel 10.0 gives approximately (knockback × 0.06) pixels total push, killed in 1 frame. This matches GDD 4-12px range for knockback values 60-200.
  - abs() → absf() is still getting missed in new code (fighter_base.gd line 83). Grep for `abs(` periodically — the Variant return type causes export crashes per GDSCRIPT-STANDARDS Rule 2.


### Three Critical Gameplay Bug Fixes (2026-07-22)
- **Bug 1 — Facing direction at startup:** The `flip_h` setter in `character_sprite.gd` had an `if flip_h != value` guard that prevented the setter body from executing when the desired value matched the default (false). For Kael (P1, should face right = flip_h false), the AnimatedSprite2D.flip_h was never explicitly set because the guard blocked it. Fix: removed the guard entirely so flip_h always propagates. Also hide the legacy `Sprite2D` node (``) when PNG sprites are active to prevent visual conflicts.
- **Bug 2 — CPU doesn't attack/move:** The `AIController` class existed in `ai_controller.gd` but was never wired to Fighter2. Additionally, `PROTECTED_STATES` listed names like `attackstate`, `hitstate`, `kostate` which don't match the actual state node names (`attack`, `hit`, `ko`). Fix: corrected PROTECTED_STATES to match scene-tree names and wired AIController to Fighter2 in `fight_scene.gd` with Normal difficulty.
- **Bug 3 — Walk animation not showing:** One-frame delay between state transition and AnimationPlayer evaluation. When the state machine transitions to walk, the AnimationPlayer's property track doesn't evaluate until the next physics frame. Fix: added `_set_initial_pose()` in `FighterAnimationController` that immediately sets the CharacterSprite pose on state change, closing the gap.
- **Key Pattern:** Property setter guards (`if value != old_value`) are dangerous for initialization. The first assignment may match the default, causing the setter body to never run. For critical visual properties like facing direction, always propagate unconditionally.
- **Key Pattern:** When checking state names against a whitelist/blacklist, always verify the actual node names in the scene tree. State names are derived from `Node.name.to_lower()`, not class names.

### Combat System Hitbox Scaling Fix (2026-03-10)
- **Root Cause — 3 bugs compounding to break all combat:**
  1. **Hitboxes/hurtboxes still sized for old 60px procedural sprites.** When PNG sprites were introduced at 0.55 × 512px = ~282px, the collision shapes in kael.tscn, rhena.tscn, and fighter_base.tscn were never scaled up. Body collision (30×60), hurtbox (26×56), and hitbox (36×24) were invisible specks relative to the new character visuals. Characters looked like they were touching but their collision shapes were 4.7× too small to overlap.
  2. **Hitbox CollisionShape never flipped with facing direction.** attack_origin.position.x was flipped in _update_facing(), but the actual hitbox CollisionShape2D position stayed at +X regardless of facing. When facing left (e.g., Rhena facing Kael), the hitbox extended AWAY from the opponent.
  3. **All positions (body center, hurtbox center, hitbox offset, attack origin) were calibrated for 60px sprites.** Center of a 60px sprite is y=-30; center of a 282px sprite is y=-141. Even if the shapes were larger, they'd be positioned at ankle height.
- **Fix applied (3.67× scale factor to match sprite ratio):**
  - Body collision: 30×60 → 110×220, position (0,-30) → (0,-110)
  - Hurtbox: 26×56 → 96×206, position (0,-28) → (0,-103)
  - Hitbox: 36×24 → 132×88, position (30,-30) → (110,-110)
  - AttackOrigin: (30,-30) → (110,-110)
  - Legacy Sprite2D position: (0,-30) → (0,-141)
  - Applied to kael.tscn, rhena.tscn, and fighter_base.tscn
  - Hitbox flipping added to attack_state._activate_hitboxes(): `shape.position.x = absf(shape.position.x) * fighter.facing_direction`
  - Debug print added to hitbox._on_area_entered() for hit confirmation
- **Verified:** visual_test.bat shows `[Hitbox] HIT! Fighter1 → Fighter2 | dmg=50` — damage registers, health bar drops, damage number renders. Walk animation confirmed working with PNG sprites.
- **AI Controller:** Already wired correctly in fight_scene.gd (from prior fix). No changes needed.
- **Key Learning:** When sprite assets change scale, ALL collision-related values must be audited together: shape sizes, shape positions, marker positions, and directional flipping. It's not just the shapes — it's the entire spatial coordinate system that's calibrated to the old art scale. A partial update (e.g., scaling shapes but not positions) would still fail.

### Animation & Combat Bug Fix Session (2025-07-23)
- **Root cause — walk/kick not animating:** FighterAnimationController._ready() tried to connect to fighter.state_machine.state_changed, but fighter.state_machine is @onready (null during sibling _ready). Signal never connected → AnimationPlayer stayed on "idle" animation forever, overwriting all SpriteStateBridge pose changes. Fix: access StateMachine node directly via fighter.get_node_or_null("StateMachine").
- **Root cause — kick mapped to punch poses:** Two bugs: (1) _move_to_pose() mapped "lk"/"mk"/"hk" buttons to punch poses (attack_lp/mp/hp). Fixed to return attack_lk/mk/hk. (2) _get_attack_pose() in SpriteStateBridge used case-sensitive string matching ("lk" in move_name) but move names were "Standing LK" (uppercase). Added .to_lower() to move name.
- **Missing standing LK:** Both Kael and Rhena movesets only had Crouching LK (requires_crouch=true). Standing LK input silently failed — no move found, no attack executed. Added Standing LK to both movesets (5f startup, 3f active, 8f recovery, 35 dmg).
- **Hits not connecting visually:** Fighters at x=200/x=440 (240px gap). Hitbox max reach: 176px from origin. Hurtbox starts 48px before target origin. Required gap ≤ 224px. Moved Fighter2 to x=400 (200px gap → 24px overlap).
- **AnimationController attack fallback:** _play_attack_from_state() fell through to play_animation("hit") when move wasn't found, causing AnimationPlayer to set pose="hit" every frame, fighting with SpriteStateBridge. Changed fallback to stop AnimationPlayer and clear _current_anim.
- **PNG sprite flip_h:** flip_h setter always used parent scale.x, but for PNG sprites the AnimatedSprite2D child inherits parent scale → double-flip. Now uses _animated_sprite.flip_h when PNG sprites are active.
- **Hitbox deactivation during physics callback:** attack_state._deactivate_hitboxes() and hitbox.deactivate() set monitoring/disabled directly during area_entered signal → Godot error. Changed to set_deferred/call_deferred.
- **Key learning — @onready timing:** In Godot 4, @onready vars are set right before the declaring node's _ready(). Sibling nodes' _ready() runs earlier (children before parent, siblings in tree order). Never access another node's @onready vars from a sibling's _ready() — access the node directly instead.
- **Key learning — AnimationPlayer vs SpriteStateBridge conflict:** Both systems set CharacterSprite.pose each frame. AnimationPlayer runs after SpriteStateBridge in tree order, so it wins. When AnimationController can't find the right animation, stopping the AnimationPlayer lets SpriteStateBridge take over cleanly.

### ComeRosquillas High Score System Implementation (2026-03-11)

- **Project:** ComeRosquillas — HTML/JS/Canvas Pac-Man-style game themed on The Simpsons
- **Task:** Implement high score persistence and leaderboard (Issue #3)
- **No build step:** Pure HTML/JS/Canvas game with script tags, no framework
- **Key integration points:**
  - **Game state management:** Added ST_HIGH_SCORE_ENTRY = 7 to config.js game state constants
  - **localStorage pattern:** HighScoreManager class wraps localStorage in try/catch for graceful private browsing fallback. Always validates parsed JSON structure before trusting it (check array + validate all entries have required string/number types).
  - **Input handling for UI:** Game uses keydown event listener with e.code checks (not e.key). For high score entry, hijacked the main input handler to route ST_HIGH_SCORE_ENTRY to handleHighScoreInput() before other state checks. Arrow keys cycle through 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ' string (modulo for wrap), left/right move cursor position (0-2), Enter confirms.
  - **HTML overlay messaging:** Game uses msgEl (div#message) positioned absolute over canvas. showHighScoreEntry() sets innerHTML with inline styles (color, font-size, text-decoration for cursor highlight). Added CSS @keyframes pulse animation by injecting style element into document.head (check for duplicate with getElementById guard).
  - **HUD updates:** updateHUD() called after every score change. Extended it to set highScoreEl.textContent from highScores.getHighScore(). HUD uses inline spans with IDs (scoreDisplay, highScoreDisplay, levelDisplay, livesIcons).
  - **Game over flow:** In ST_DYING state handler when lives hit 0, check highScores.isHighScore(score) → route to ST_HIGH_SCORE_ENTRY (show initials entry) or ST_GAME_OVER (standard message). After initials entry confirms, call highScores.addScore() → get rank → transition to ST_GAME_OVER with rank in message.
  - **Start screen enhancement:** showStartScreen() calls highScores.getScores() and dynamically builds HTML string for top 10 table. Append it to msgEl.innerHTML subtitle section.
- **Key pattern — localStorage graceful degradation:** Never assume localStorage is available. Wrap getItem/setItem in try/catch and return empty array / log warning on exceptions. Private browsing, storage quota exceeded, and browser security policies can all throw. The game must function without high scores.
- **Key pattern — HTML message overlays in Canvas games:** When you can't render complex UI in canvas easily (text input, styled tables), use positioned HTML divs over the canvas. The game already had this pattern with msgEl for title/game-over screens — extending it for high score entry and leaderboard tables was natural.
- **Key pattern — State machine integration:** The game uses numeric constants for states (ST_START, ST_PLAYING, etc.) and a single this.state property. Adding high score entry meant: (1) new constant in config.js, (2) new state handler in update loop (if state === X), (3) input routing in setupInput keydown listener. Keep the flow: dying → high score check → entry or game over → back to start screen.

### Flora — 8x8 Garden Grid System (Issue #4, 2026-03-11)
- **Project Context:** Flora is a cozy gardening roguelite (Vite + TypeScript + PixiJS v8). Core game loop and scene manager merged before this work.
- **Implementation:** Created GardenGrid entity (8×8 tile array with state management), Tile entity (empty/occupied/pest states, soil quality 0–100%, moisture), and GridSystem for PixiJS rendering with click detection.
- **PixiJS v8 patterns:**
  - Container-based scene hierarchy: SceneManager.stage → scene containers → system containers
  - eventMode = 'static' + custom hitArea for grid-level click detection
  - FederatedPointerEvent.global → toLocal() for translating viewport coords to grid space
  - Graphics.clear() → rebuild shapes per frame for dynamic state changes
  - Color interpolation for visual feedback: lerp between 0x3d2817 (poor soil) → 0x6b4423 (rich soil) based on soil quality percentage
- **Grid interaction model:** Click detection maps pointer position to grid coordinates via getTileAtPosition(x, y, gridX, gridY), returns Tile or null. Selection highlight renders as stroke-only Graphics rect over selected tile, updated per-frame from selectedTile reference.
- **Key pattern — Separation of data and rendering:** Tile holds pure state (row, col, state enum, soil quality, moisture). GardenGrid manages tile array and spatial queries. GridSystem owns PixiJS rendering and user input. Clean split makes grid state testable without rendering concerns.
- **Tile state persistence:** All tile state lives in Tile instances stored in GardenGrid.tiles[][] 2D array. State persists naturally across game loop frames since grid is held by scene. No manual serialization needed for within-season persistence.
- **Viewport centering:** centerInViewport() calculates grid pixel dimensions (cols × tileSize, rows × tileSize) and sets container.x/y to center in screen. Responsive to window resize if called from scene resize handler.
- **PR:** #17 (squad/4-garden-grid), merged to main. Built successfully with TypeScript strict mode, all acceptance criteria met.