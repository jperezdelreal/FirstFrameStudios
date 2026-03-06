# Greedo — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current audio:** 3 procedural sounds (punch, hit, KO) in src/engine/audio.js using oscillators
- **Key gap:** No kick/jump SFX, no background music, no sound variation, no audio events. Audio scored 80% but is misleadingly thin — only 3 sounds total.

## Learnings

### 2025-06-04: P0 Audio Sprint (3 items)
- **AudioContext resume**: Browsers suspend AudioContext until a user gesture. Added `resume()` method + one-time keydown/click listener in main.js. The flag `_resumed` prevents redundant resume calls. All existing playX() methods work transparently — no changes needed to callers.
- **Kick SFX**: Two-layer design — 80Hz→40Hz sine drop for the bass thud + lowpass-filtered noise burst for impact texture. Distinctly heavier than the punch (square wave at 150Hz). The noise buffer is created fresh each call (~2880 samples at 48kHz) — negligible cost.
- **Jump SFX**: 200Hz→400Hz ascending sine sweep over 0.08s at low volume (0.15). Subtle spring feel without being annoying on repeated jumps.
- **Wiring pattern**: player.update() already returns `{ type: 'punch' }` or `{ type: 'kick' }` — gameplay.js just wasn't checking the type. Jump detection uses frame-over-frame `prevJumpHeight` comparison (0→>0 = jump initiated). Clean, no changes to player.js needed.
- **Sound count**: Now at 5 procedural sounds (punch, hit, KO, kick, jump). Still no music or variation.

### 2025-06-04: Sound Variation + Layering + Priority (P1-3, EX-G3, EX-G4)
- **P1-3 Sound Variation**: Added `randomPitch(baseFreq, variance)` helper — applies ±20% random pitch offset to every sound on each play. `playHit()` now randomly selects between 3 intensity variants (light/medium/heavy) through the layered engine. Punch and kick also get per-call pitch randomization. No two hits sound identical anymore.
- **EX-G3 Hit Sound Layering**: `playLayeredHit(intensity)` fires 3 simultaneous components — bass body thud (sine ~70Hz, 0.08s), mid impact crack (bandpass-filtered noise at ~1400Hz, 0.04s), and high sparkle ping (sine ~2500Hz, 0.02s, very quiet). Intensity parameter (0-1) scales volume and controls whether sparkle layer fires (only above 0.5). `playHitLight()` and `playHitHeavy()` are convenience wrappers.
- **EX-G4 Sound Priority & Deduplication**: Per-type active sound counter (`_typeCounts`) with max 3 simultaneous SFX of same type. `canPlay(type, priority)` gate checks before every play — player sounds (PLAYER=2) always pass, enemy sounds (ENEMY=1) get dropped at limit. Per-frame pitch spread via `_pitchSpread()` adds +5%/+10% to 2nd/3rd sounds of same type within one frame to prevent phasing. `beginFrame()` resets per-frame tracking (callers should invoke once per game tick). `_trackSound()` uses setTimeout to auto-decrement counters after sound duration.
- **Interface preserved**: All original method signatures (`playPunch()`, `playHit()`, `playKO()`, `playKick()`, `playJump()`, `playSound()`, `resume()`) remain unchanged. New public methods added: `playHitLight()`, `playHitHeavy()`, `playLayeredHit()`, `beginFrame()`, `canPlay()`, `randomPitch()`.
- **Design note**: `beginFrame()` should be called by the game loop at the top of each frame for optimal dedup. Without it, pitch spread still works per-session but won't reset per-frame. No external files modified.

### 2025-06-04: Mix Bus Architecture (EX-G2)
- **Bus topology**: Four GainNodes created in constructor — `sfxBus`, `musicBus`, `uiBus` all connect to `masterBus`, which connects to `context.destination`. Standard DAW-style routing in Web Audio API.
- **SFX rerouting**: All 8 `this.context.destination` connections in existing play methods replaced with `this.sfxBus`. No behavioral change — sounds still play identically but now flow through the gain chain.
- **Volume controls**: `setSFXVolume()`, `setMusicVolume()`, `setUIVolume()`, `setMasterVolume()` with 0-1 clamping. Matching getters for all four buses. Ready for settings UI integration.
- **Default levels**: SFX=0.7 (slightly attenuated to leave headroom), Music=0.5 (background level), UI=1.0 (full for menu feedback), Master=1.0 (unity).
- **Music/UI buses ready but unused**: `musicBus` and `uiBus` have no sounds routed yet — they're infrastructure for upcoming background music (P2-1) and menu sound work. Future playMusic() and playUISound() methods should connect to those buses.
- **Interface preserved**: All existing method signatures unchanged. New public methods: `setSFXVolume()`, `setMusicVolume()`, `setUIVolume()`, `setMasterVolume()`, `getSFXVolume()`, `getMusicVolume()`, `getUIVolume()`, `getMasterVolume()`.
