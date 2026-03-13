# firstPunch — AAA-Level Gap Analysis & Prioritized Backlog

> Compressed from 38KB. Full: aaa-gap-analysis-archive.md

**Author:** Solo (Lead)  
**Date:** 2026-06-04  
---

## 1. Current State vs AAA Standard
Rating scale: 1 (broken) → 5 (functional prototype) → 7 (solid indie) → 10 (award-winning browser beat 'em up).
| Area | Score | Assessment |
| **Combat Feel** | 5/10 | Hitlag + screen shake + knockback exist (great foundation). Missing: grab/throw system, dodge roll, juggle physics, attack buffering, directional specials. Combo system is basic (counter + timer). No risk/reward loops (health-cost specials, taunt meter). Beat 'em up research says grab/throw is in ALL 9 reference games — we have zero. |
| **Enemy Variety** | 4/10 | 4 variants (normal, fast, heavy, boss) with behavior tree AI. Good AI architecture. Missing: ranged, shield, aerial, grappler, summoner types. Research says 6-9 enemy types minimum. Boss has 3 phases (good) but only 1 boss total. No mini-bosses. Enemy intro sequences absent. |
| **Visual Quality** | 5.5/10 | Procedural Canvas art with consistent outlines. Boba's VFX system adds hit effects, KO text, damage numbers, motion trails, spawn effects. Missing: walk cycle animations, squash/stretch, facial expressions, unique enemy silhouettes, attack anticipation frames. Backgrounds have parallax but lack Downtown landmark density. |
| **Audio Quality** | 6/10 | Layered hit sounds (bass+mid+sparkle), mix bus architecture, pitch variation, priority system, spatial panning, procedural music with 3 intensity layers. Missing: vocal barks (Ugh!, Radical!), environmental ambience, dynamic crowd reactions, retro-themed SFX library. Bugs: some audio hooks not connected (wave fanfares, landing, vocals partially wired). |
| **Level Design** | 3/10 | Single level with 4 waves. Wave data is hardcoded arrays. No environmental interaction (destructibles, throwable objects, hazards). No set pieces. No level intro/outro cinematics beyond a basic timer. Research says beat 'em ups need 6-8 encounters per level with walk → encounter → walk pacing. We have 4 flat waves. |
| **UI/UX** | 6/10 | Health bar, score, combo counter, boss health bar, lives icons, enemy health bars all present and polished. Title screen is atmospheric. Missing: options menu, pause menu buttons, wave progress indicator, special cooldown display, score breakdown on game over, scene transitions, character select screen. |
---

## 2. New AAA-Tier Backlog Items
Items NOT in the existing 85-item backlog. Organized by domain.
### 2.1 Combat AAA (Lando + Yoda)
| # | Item | Owner | Complexity | Dependencies | Description |
| AAA-C1 | Grab/throw system | Lando | XL | P1-8 (animation controller) | Proximity grab input when near enemy. Grab state: pummel (mash attack for damage) or throw (directional input + attack). Thrown enemies damage other enemies on collision. Foundation for the genre's most satisfying micro-interaction. Every reference game has this. |
| AAA-C2 | Dodge roll with i-frames | Lando | L | None | Dedicated dodge input (double-tap direction or dedicated key). 0.3s animation with 0.15s i-frames in the middle. Recovery frames prevent spam. Brawler's dodge: stumbling belly roll. Each future character gets unique dodge animation. |
| AAA-C3 | Juggle physics system | Lando | L | P1-8 | Launched enemies become physics objects. Hit airborne enemies to keep them up. Wall/floor bounce states. Simplified to 2-3 bounce states (not full simulation) for Canvas performance. Skill expression layer for advanced players. |
| AAA-C4 | Style/combo scoring meter | Yoda + Wedge | M | None | Visible meter that fills with variety: different attacks, no repeats, grabs, throws, juggles, air combos. Resets on damage. retro-themed ratings: "Boring" → "Meh" → "Radical!" → "Excellent!" → "Best. Combo. Ever." Drives replayability and score chasing. |
| AAA-C5 | Taunt mechanic | Lando + Yoda | M | None | Dedicated taunt button. Builds super meter faster but leaves player vulnerable for ~1s. Brawler: eats invisible donut. Animation must be cancellable on hit. Risk/reward that "game characters are MADE for." |
---

## 3. "Future: Engine Migration" Items
Things that CANNOT be done well on Canvas 2D + vanilla JS. These are explicitly OUT OF SCOPE for the current tech stack but documented for a potential future migration.
| # | Item | Why Canvas 2D Can't | Target Tech | Impact |
| FUT-1 | Shader-based effects (glow, bloom, blur) | Canvas 2D has no programmable shaders. `filter` CSS property is slow and limited. Real-time bloom/blur requires fragment shaders. | WebGL / PixiJS / Phaser | Would enable hit glow halos, boss aura effects, screen-wide bloom on super moves, motion blur on dashes. |
| FUT-2 | Skeletal animation (Spine-like) | Canvas 2D procedural drawing means redrawing every frame from code. Skeletal animation requires bone hierarchies with interpolation, which is impractical without a runtime. | Spine / DragonBones + WebGL | Would enable fluid character animation, blend trees, IK for grab poses, cloth physics on Defender's dress. |
| FUT-3 | WebGL rendering pipeline | Canvas 2D is CPU-rendered and single-threaded. At 20+ entities with VFX, particle systems, and parallax layers, CPU becomes the bottleneck. | WebGL / PixiJS | Would enable GPU-accelerated rendering, sprite batching, 100+ particles without frame drops, post-processing pipeline. |
| FUT-4 | Online multiplayer | Requires WebSocket/WebRTC infrastructure, server-authoritative game state, input prediction, rollback netcode. Far beyond vanilla JS scope. | Node.js server + WebSocket | Would enable 2-4 player online co-op — the genre's killer feature. |
| FUT-5 | Sprite sheet asset pipeline | Current approach: procedural Canvas drawing. Real sprite sheets need: asset loading, atlas packing, frame extraction, async load management. | PixiJS / custom loader | Would enable imported pixel art, artist-drawn sprites, animation editors like Aseprite integration. |
| FUT-6 | Advanced particle system | Canvas 2D particles are CPU-limited. GPU particle systems can handle 1000+ particles with physics at zero CPU cost. | WebGL compute / PixiJS particles | Would enable weather effects (rain, snow), massive explosion debris, environmental particle fog. |
---

## 4. Prioritized Execution Plan
### Phase A: Combat Excellence — "Make it feel award-worthy"
**Goal:** Every punch, kick, grab, and dodge feels incredible. This is the foundation everything else is built on.  
| # | Item | Owner | Size | Deps | Priority |
| A-1 | Fix C1-C3 critical bugs (enemy attacks) | Lando + Tarkin | S | None | ★★★ Blocker |
| A-2 | Grab/throw system (AAA-C1) | Lando | XL | A-1 | ★★★ Core |
| A-3 | Dodge roll with i-frames (AAA-C2) | Lando | L | None | ★★★ Core |
| A-4 | Attack buffering (AAA-C9) | Chewie | M | None | ★★★ Core |
| A-5 | Back attack (AAA-C8) | Lando | S | None | ★★☆ High |
---

## 5. Complete Backlog Summary
### Item Count by Phase
| Phase | New Items (this doc) | Carried from existing 85 | Total |
| A (Combat) | 11 new AAA-C items | 8 existing (EX-T1-T3, EX-A1-A2, EX-A8, P1-4, P1-5) | 19 |
| B (Visual) | 8 new AAA-V items | 14 existing (EX-B1-B8, P1-8-P1-10, P2-4-P2-5) | 22 |
| C (Content) | 14 new AAA items | 11 existing (EX-T4-T9, P2-1-P2-3, P3-5-P3-7) | 25 |
| D (Polish) | 15 new AAA items | 12 existing (EX-G1-G8, EX-A4-A7, P1-12) | 27 |
| E (Future) | 8 items | 0 | 8 |
| **Total** | **56 new** | **45 carried** | **101 active + 8 future** |
---

## 6. What "Award-Winning" Looks Like
Based on the genre research, an award-winning browser beat 'em up needs:
1. **Combat that feels incredible** — Every hit has weight (hitlag + shake + particles + sound). Grab/throw for crowd control. Dodge for defense. Combos for expression. ✅ Achievable in Phase A.
---