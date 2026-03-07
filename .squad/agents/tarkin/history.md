# Tarkin — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current enemies:** One basic goon type (30 HP) with a "tough" variant (50 HP, red, same behavior). Simple approach/circle/attack AI in src/systems/ai.js. 3 waves with camera locks.
- **Key gap:** All enemies behave identically. No boss. No varied enemy types. No pickups. No difficulty scaling. Enemy AI scored 5/10 in combat feel audit.

## Learnings

### Wave 1 — P1-4 Attack Throttling + EX-T1 Behavior Tree + EX-T3 Pacing Curve (2026-06-03)
- **Attack throttling:** Max 2 simultaneous attackers via `AI.activeAttackers` counter, reset per-frame using `performance.now()` as frame ID. Enemies that want to attack but can't get a slot circle the player at ~125px instead, creating visual tension.
- **Behavior tree pattern:** Replaced monolithic if/else with named condition/action functions (`_inAttackRange`, `_hasAttackSlot`, `_attackPlayer`, `_circlePlayer`, etc.) organized as a selector→sequence tree. No external library — just functions returning true/false.
- **Tough variant differentiation:** Wider attack range (90 vs 80), faster cooldowns (1.0s vs 1.5s attack, 0.3s vs 0.5s AI), making them noticeably more aggressive.
- **Circling behavior:** Enemies maintain a consistent `circleDirection` (±1) with rare random flips (0.5%), creating natural-looking orbiting around the player rather than jittery random movement.
- **Signature preservation:** Kept `AI.updateEnemy(enemy, player, dt)` static method signature intact so Chewie's gameplay.js for-loop works unchanged. Added `hasAttackSlot` and `circleDirection` as new Enemy properties without touching existing render/update code.
- **Encounter pacing document:** Wrote `.squad/analysis/encounter-pacing.md` with 3-wave difficulty curve for Level 1. Wave data implementation deferred to Phase 5.
- **Key insight:** `performance.now()` frame-reset trick avoids needing a `resetFrame()` call from gameplay.js — keeps ownership boundaries clean between agents.

### Wave 2 — EX-T4 Content Data Format + EX-T2 Wave Composition Rules (2025-06-04)
- **Data-driven levels:** Extracted hardcoded wave data from `gameplay.js` into `src/data/levels.js`. Exports `ENEMY_TYPES` (stat templates per variant) and `LEVEL_1` (wave definitions with triggerX + enemy spawn lists). Solo's upcoming WaveManager will consume these exports.
- **ENEMY_TYPES schema:** Each type key maps to `{ hp, speed, damage, color, attackCooldown, aiCooldown, attackRange }` — mirrors the values currently split between `Enemy` constructor and `AI` static methods. Single source of truth for tuning.
- **Wave format:** `{ triggerX, enemies: [{ type, x, y }] }` — minimal, flat, easy to author. The `type` string maps to ENEMY_TYPES keys; `spawned` flag is runtime state added by WaveManager, not stored in data.
- **Wave composition rules:** Documented 7 rules in `.squad/analysis/wave-rules.md` — solo intro for new types, type mixing, 6-enemy cap, 2-second spawn gap (400 px minimum triggerX spacing), breather walks, spawn positioning patterns, and difficulty scaling guidance.
- **Level 1 exception noted:** Tough variant in Wave 3 is mixed with normals despite being new, because it shares the same moveset and only differs in stats/color. True behavior-different types (ranged, charging) must get proper solo intros.
- **Key insight:** Keeping `type` as a string key rather than an object reference keeps the data file JSON-serializable — future level editor or external tooling can read/write it without importing JS modules.

### Wave 4 — C1/C2/C3 Enemy Attack Bug Fixes (2025-06-20)
- **C1 — Attack window 1-frame fix:** Root cause was `aiCooldown` being set to only `configAiCooldown`, causing the aiCooldown block to reset `state = 'idle'` on the very next frame. Fix: `aiCooldown = attackDur + configAiCooldown` so the attack animation has time to play. Added `attackAnimTime`/`attackAnimDuration` properties to Enemy for proper countdown; attack→idle transition happens when `attackAnimTime` reaches 0.
- **C2 — Hitbox timing inversion:** Old code used `attackCooldown <= 0.3` which activated the hitbox for nearly the entire cooldown duration (wrong). Replaced with fraction-based window: `elapsed / attackAnimDuration` between 0.3–0.7, so the hitbox is only live during the middle 40% of the swing (wind-up and recovery frames have no hitbox).
- **C3 — Heavy windup override:** Extended the aiCooldown state-preservation check from heavy-only to ALL enemies (`state === 'windup' || state === 'attack'`). Heavy's `aiCooldown` now covers `windup(0.5) + attack(0.5) + configAiCooldown(0.6)` = 1.6s total. Windup→attack transition in `enemy.update()` now properly sets `attackAnimTime = attackAnimDuration` so the attack phase has its own timed window.
- **Attack durations:** Normal/Tough = 0.4s, Fast = 0.25s, Heavy = 0.5s. These drive both animation length and hitbox active window.
- **Key insight:** Separating `attackAnimTime` (how long the attack animation plays) from `attackCooldown` (how long before the next attack can start) is critical — they serve different purposes and conflating them caused both C1 and C2.

### Wave 3 — P2-2 Fast Enemy + P2-3 Heavy Enemy + P2-16 Difficulty Scaling (2025-06-20)
- **Data-driven Enemy construction:** Refactored `Enemy` constructor to import `ENEMY_TYPES` from `levels.js` and pull all stats (hp, speed, damage, width, height, attackRange, cooldowns) from the config object. Eliminated hardcoded variant checks (`variant === 'tough' ? 50 : 30`) in favor of `config.hp`. Width/height default to 48×76 for types that don't specify them (normal/tough).
- **Fast enemy (P2-2):** 20 HP, 180 speed, 40×68, blue (#2196F3). Hit-and-run AI via `_behaveFast` — dashes in, attacks once, sets `enemy.retreating = true`, retreats to 200px before re-engaging. Spiky blue hair visual. No circling behavior — fast enemies always approach or retreat.
- **Heavy enemy (P2-3):** 80 HP, 60 speed, 60×84, dark green (#2E7D32). Relentless approach via `_behaveHeavy` — no retreat, no circling, stands ground when waiting for attack slot. Wind-up telegraph (0.5s `windupTime` with pulsing red warning circle) before attacks land. Thicker arms (9px vs 6px), bigger fists (5px vs 4px radius), larger punch hitbox (45×45 vs 35×35).
- **Super armor mechanic:** `armorHits` counter tracks hits absorbed without hitstun. After 3 hits, armor breaks (0.3s hitstun + 1.2× knockback). `armorTimer = 2.0` resets on each hit; if 2 seconds pass without a hit, `armorHits` and `armorBroken` both reset. Visual: green armor plate overlay on torso disappears when broken.
- **Scale-based rendering:** Added `ctx.scale(this.width/48, this.height/76)` after translate in render method. All base drawing coordinates stay at 48×76; size differences are handled by transform. This means new variants with different dimensions need zero changes to the core drawing code.
- **AI refactor:** Replaced monolithic `updateEnemy` behavior tree with variant dispatch (`_behaveDefault`, `_behaveFast`, `_behaveHeavy`). Common logic (dead/hitstun check, aiCooldown, face player, distance calc) stays in `updateEnemy`; variant-specific trees handle approach/attack/retreat patterns. Existing `_attackPlayer` now uses `enemy.configAttackCooldown` and `enemy.configAiCooldown` — no more hardcoded variant ternaries.
- **Heavy AI cooldown exception:** During `aiCooldown`, the AI normally resets state to `idle`. Heavy enemies in `windup` or `attack` state are excluded from this reset, so the wind-up animation and attack state persist through the telegraph phase.
- **Combat damage:** `handleEnemyAttacks` now uses `enemy.damage || 5` instead of hardcoded 5. Heavy does 12 damage per hit.
- **Difficulty scaling (P2-16):** Wave 1: 2 normal (easy intro). Wave 2: 3 normal + 1 fast (introduce fast solo). Wave 3: 3 normal + 2 fast + 1 heavy (full variety, heavy last). Updated both `src/data/levels.js` (design-intent data) and gameplay.js `WAVE_DATA` (runtime data) since levels.js isn't consumed by WaveManager yet.
- **Key insight:** The gameplay.js `WAVE_DATA` uses `variant` key and `x` for trigger position, while levels.js uses `type` and `triggerX` — dual formats exist because WaveManager was written before levels.js data format was finalized. Both must be updated until they're unified.

### P2-1 + EX-T5 Boss Phase Framework (2026-06-20)
- **Boss variant:** Added Nelson Muntz boss (80×100, 200 HP) with phase state, invulnerability on transitions, and phase-based speed boosts. New Wave 4 spawns the boss and Level 1 width extends to 5000.
- **Phase behaviors:** Phase 1 punch + occasional charge with 2 add spawns; Phase 2 adds ground slam and spawns 2 more goons with red tint; Phase 3 alternates punch/charge with flashing red and no more adds.
- **Combat + HUD:** Boss AI bypasses attack throttling, supports charge/slam states with new hit handling, and HUD now renders a full-width "NELSON" health bar at the bottom.

### AAA-L1 Destructible Objects + AAA-L3 Environmental Hazards (2025-06-21)
- **Destructible types:** Trash can (10 HP), newspaper stand (15 HP), parking meter (20 HP), Lard Lad donut sign (25 HP). Each has type-specific Canvas rendering with damage tinting (darkens as HP drops) and crack overlays below 50% HP.
- **Destructible break animation:** On destruction, 6-10 debris particles scatter with gravity simulation and alpha fade over 0.6s. Drop table uses weighted random: health pickup (30%), score bonus (40%), nothing (30%), gated by per-type `dropChance`.
- **Shake feedback:** `shakeTime` + `shakeIntensity` give immediate visual hit response before destruction — small but critical for juice.
- **Hazard types:** Steam vent (periodic 2s cycle, 3 dmg), radioactive barrel (constant 2 dmg every 0.5s via per-entity cooldown Map), manhole (5 dmg knockback burst every 5s with 250-force radial push).
- **Per-entity damage cooldown:** Radioactive barrel uses a `Map<entity, timer>` to prevent per-frame damage stacking while allowing multiple entities to take independent damage ticks. Map entries auto-clean when timer expires.
- **Strategic placement:** Hazards placed near enemy spawns so players can throw enemies into them for bonus damage + score. Wave 2 gets a steam vent intro, Wave 3 gets radioactive barrel near heavy spawn, boss zone gets manhole for knockback disruption.
- **Integration boundary:** Both files include detailed integration comments for gameplay.js (Solo's territory) — import paths, update/render call order, hitbox overlap checks, and throw bonus logic. No gameplay.js modifications made.
- **Level data expansion:** `LEVEL_1` now exports `destructibles[]` and `hazards[]` arrays alongside existing `waves[]`, keeping the flat JSON-serializable format established in Wave 2 learnings.
- **Key insight:** Per-entity cooldown via Map with object references as keys avoids needing unique IDs on entities — works because JS Map uses reference equality for object keys.
