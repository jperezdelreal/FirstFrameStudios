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
