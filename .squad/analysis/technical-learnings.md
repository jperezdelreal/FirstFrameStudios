# Technical Learnings — firstPunch Engine

> Compressed from 27KB. Full: technical-learnings-archive.md

**Author:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
---

## 1. What We Built — Engine Systems Inventory
| System | File | LOC | Purpose | Quality |
|--------|------|-----|---------|---------|
| **Game Loop** | `game.js` | 191 | Fixed-timestep loop, scene management, hitlag, zoom, slow-mo, screen transitions | ★★★★★ — Clean, battle-tested, handles edge cases |
| **Renderer** | `renderer.js` | 112 | HiDPI-aware Canvas 2D wrapper, camera, screen shake, zoom transforms | ★★★★☆ — Solid. Could add resolution-independent scaling |
| **Input** | `input.js` | 127 | Keyboard input with pressed/held/released tracking + attack buffering | ★★★★★ — Clean API, buffer system is production-quality |
| **Audio** | `audio.js` | 931 | Procedural SFX synthesis, mix bus architecture, spatial audio, ambience | ★★★★★ — Most ambitious system. Fully procedural, zero assets |
| **Music** | `music.js` | 260 | Procedural background music, 3-layer adaptive intensity, beat scheduler | ★★★★☆ — Impressive for procedural. Limited musical range |
| **Animation** | `animation.js` | 84 | Data-only frame controller, frame events, lag-spike recovery | ★★★★★ — Perfect separation of concerns. Tiny and correct |
---

## 2. What Worked Well
### 2.1 Fixed-Timestep Game Loop
The `while (accumulator >= fixedDelta)` pattern in `game.js` was rock-solid from day one. Benefits:
### 2.2 Data-Only Animation Controller
### 2.3 Procedural Audio Architecture
### 2.4 Event Bus Simplicity
---

## 3. What Broke
### 3.1 Hitlag Integration — The Invisible Bug
**Problem:** After adding hitlag, VFX effects froze during hit freeze because `updateDuringHitlag()` wasn't calling `vfx.update(dt)`. Effects would hang mid-animation for 2-3 frames.
### 3.2 State Machine Gap — Player Freeze After Hit
### 3.3 Enemy AI Distance Threshold Gap
### 3.4 Music Crash on AudioContext Restrictions
---

## 4. What Phaser Gives for Free
For each of our custom systems, here's the Phaser 3 equivalent and what we'd gain/lose:
| Our System | LOC | Phaser 3 Equivalent | What We'd Gain | What We'd Lose |
| `game.js` (loop + scenes) | 191 | `Phaser.Game` + Scene lifecycle | Built-in preload/create/update, scene stacking, sleep/wake | Custom hitlag, slow-mo, transition timing |
| `renderer.js` | 112 | `Phaser.Cameras.Scene2D` | Zoom, shake, fade, follow, scroll — all built-in with easing | Direct canvas control, custom save/restore |
| `input.js` | 127 | `Phaser.Input.Keyboard` | Combo detection, duration tracking, key binding UI | Our attack buffer system (would need re-impl) |
| `audio.js` | 931 | `Phaser.Sound.WebAudioSoundManager` | Asset-based audio with spatial, pooling, sprite sheets | ALL procedural synthesis — Phaser is file-based |
| `music.js` | 260 | `Phaser.Sound` + markers | Layer crossfading, volume control | Procedural adaptive music — no equivalent |
| `animation.js` | 84 | `Phaser.Animations` | Sprite sheet support, global animation manager | Our data-agnostic frame controller |
---

## 5. Canvas 2D Ceiling
### What Canvas 2D Cannot Do Well
1. **Real-time blur/glow on many elements** — `ctx.filter = 'blur()'` triggers software rendering, ~2-5ms per element. Unusable for >3 simultaneous blurs.
### What Canvas 2D Does Surprisingly Well
### Realistic Ceiling
---

## 6. HiDPI Learnings
### The Problem
Canvas renders at CSS pixels by default. On a 2× Retina display, a 1280×720 canvas renders at 1280×720 physical pixels, then gets upscaled to 2560×1440 by the browser. Every shape, line, and text glyph is 4× blurry. **This was the single biggest visual quality issue.**
### The Fix (5 lines of code)
### What Broke
### The Solution Pattern
---

## 7. Performance Patterns
### 7.1 Sprite Caching — The Big Win
**Before:** ~100 Canvas API calls per entity per frame × 20 entities = 2000 calls/frame.  
### 7.2 Offscreen Canvas vs ImageBitmap
### 7.3 When NOT to Optimize
### 7.4 Object Pooling (Future)
---

## 8. Audio Learnings
### 8.1 Web Audio API Architecture
**Mix bus hierarchy is essential.** We built:
### 8.2 Procedural Synthesis Techniques
### 8.3 Sound Priority & Deduplication
### 8.4 Adaptive Music
---

## 9. Architecture Evolution
### Phase 1: Monolith (`gameplay.js`)
Everything in one file: player logic, enemy AI, combat, rendering, audio triggers, wave management, UI. ~2000 lines. Worked for rapid prototyping but became unmaintainable.
### Phase 2: Engine/Game Split
### Phase 3: System Integration via Hooks
### Key Insight: The Wiring File
---

## 10. For the Next Project
### Day 1 Decisions That Save Weeks
1. **Set up HiDPI from the start.** The 5-line DPR fix should be in your renderer constructor before you draw a single pixel. Retrofitting it means hunting down every `canvas.width` reference.
### Framework vs Custom — Decision Framework
### File Organization That Scales
### Testing Strategy From the Start
---

## Appendix: Performance Numbers
| Metric | Before Optimization | After Sprite Cache + HiDPI |
|--------|--------------------|-----------------------------|
| Canvas API calls/frame (20 entities) | ~2,500 | ~200 |
| Frame render time | ~12ms | ~2ms |
| Max entities at 60fps | ~30 | ~100+ |
| Particle cap before drops | ~200 | ~500 |
| Audio nodes (combat scene) | 15-25 | 15-25 (unchanged) |
| Memory (sprite cache, 50 entries) | — | ~8MB (offscreen canvases) |