# Ashfall Sprint 2 — Visual Quality & Code Hardening

> Sprint 2 Focus: **"Guilty Gear quality, not 1982"** — visual polish, code hardening, game feel.
> Bar: At LEAST Sega Mega Drive quality (Streets of Rage 2 era). The game must look like a REAL game.

## Sprint Goal

Transform Ashfall from a functional prototype into a visually compelling fighting game. Fix all Sprint 1 code quality issues, then deliver the founder's top 5 visual priorities.

## Founder Priorities (in order)
1. Camera zoom fix — dynamic framing like a real fighter
2. Sprite detail upgrade — higher quality character art
3. Stage/floor art — Ember Grounds must look impressive
4. HUD/health bars — polished UI elements
5. AI aggressiveness — AI should fight back, not be a punching bag

## Phases

### Phase 0: Code Hardening ✅ COMPLETE
- 14 code quality issues fixed (#122-#135)
- 8 PRs merged: VFX determinism, null safety, type annotations, CI gate, PR template, test infrastructure
- Integration gate GitHub Action live

### Phase 1: Camera & Sprites ✅ COMPLETE
- Dynamic camera zoom (PR #144) — distance-based zoom, fighting game framing margins
- Sprite detail upgrade (PR #147) — 11 new palette colors, detailed anatomy, clothing, ember VFX per character

### Phase 2: Stage & VFX ✅ COMPLETE
- Ember Grounds art upgrade (PR #145) — cracked obsidian floor, lava channels, 3-round progression, parallax
- Hit feedback VFX (PR #146) — hit sparks (light/medium/heavy), screen shake, KO slow-mo, Ember stage integration

### Phase 3: HUD & UI Polish 🔄 IN PROGRESS
- Health bar redesign with ghost damage
- Round indicators (best of 3)
- Timer with urgency at <10s
- Combo counter
- Round announcer text ("ROUND 1", "FIGHT!", "K.O.")
- Ember meter display
- Owner: Wedge

### Phase 4: AI & Game Feel 🔄 IN PROGRESS
- AI aggressiveness with 3 difficulty levels (Easy/Normal/Hard) — Owner: Tarkin ✅ DONE (PR #148)
- Combat feel tuning (hitstun, knockback, input validation) — Owner: Lando 🔄
- Frame data validation — Owner: Yoda + Jango

### Phase 5: Integration & Ship
- Full integration test (Ackbar)
- Playtest verdict
- Windows export test
- Release tag: ashfall-v0.3.0

## Process Improvements Adopted
1. Every agent reads GDSCRIPT-STANDARDS.md before coding
2. Never use `:=` for Dictionary, Array, or abs() values
3. Use `absf()`/`absi()` instead of `abs()`
4. Integration gate runs BEFORE merge
5. Test UI in Windows export before tagging
6. Single source of truth for frame data

## Definition of Done
- All phases complete
- Ackbar playtest: PASS or PASS WITH NOTES
- Zero P0 bugs
- Windows export works
- 60 FPS maintained
- Git tag `ashfall-v0.3.0`
