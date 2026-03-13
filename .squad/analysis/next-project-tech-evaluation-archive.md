# next-project-tech-evaluation.md — Full Archive

> Archived version. Compressed operational copy at `next-project-tech-evaluation.md`.

---

# Next Project Tech Evaluation — "Nos Jugamos Todo"

**Author:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Context:** CEO recommended Phaser 3. User challenges: is that ambitious enough? Evaluate all options with brutal honesty.  
**Stakes:** "En el siguiente juego nos jugaremos todo" — this is the one that counts.

---

## Executive Summary

**Phaser 3 is a good engine. But "good" is not what you said you wanted. You said "nos jugamos todo."**

After building firstPunch from scratch — 1,931 LOC of custom engine, 28 source files, every system hand-crafted — I know exactly what Canvas 2D and browser JavaScript can do. I know the ceiling. And I'm telling you: **the ceiling exists, and it's lower than where we need to be if we're serious about competing.**

Phaser 3 raises that ceiling from our current 7/10 to maybe 8.5/10. It's a real improvement. But Godot 4 raises it to 9.5/10 AND opens doors (native export, console, desktop, mobile) that no browser engine can.

**My recommendation: Godot 4.** Not because Phaser is bad. Because Godot is the right weapon for the fight we're picking.

---

## The Reference Games — What Are We Competing Against?

Before evaluating engines, let's be honest about the quality bar:

| Game | Quality | Engine | Platform |
|------|---------|--------|----------|
| **TMNT: Shredder's Revenge** | 10/10 beat 'em up | Proprietary (Tribute Games) | PC, Console, Mobile |
| **Castle Crashers** | 9/10 | Custom (The Behemoth) | PC, Console |
| **Streets of Rage 4** | 9.5/10 | Custom (Guard Crush/Lizardcube) | PC, Console |
| **River City Girls** | 9/10 | Unity | PC, Console |
| **Fight'N Rage** | 8.5/10 | Custom (C++) | PC, Console |
| **Scott Pilgrim vs The World** | 9/10 | Custom (Tribute Games) | PC, Console |

**Pattern:** Every award-winning beat 'em up ships on native platforms. Zero browser-only games in this list. Zero Phaser games. Zero web-first games. This is not a coincidence — it's the market telling us where the quality bar lives.

---

## Tier 1: Web Frameworks (Browser-Only)

### Phaser 3

**What it is:** Complete 2D game framework. WebGL + Canvas 2D renderer, built-in physics, scene management, input, audio, tweens, cameras, tilemaps, animation. Massive community, excellent docs.

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Visual ceiling** | 8.5/10 | WebGL renderer enables shaders, filters, blend modes. Best browser games look polished-indie. No shipped beat 'em up at Shredder's Revenge quality. |
| **Performance ceiling** | ~1000 sprites @ 60fps | Browser-constrained. WebGL helps, but JS garbage collection causes micro-stutters. No native threading. |
| **Development speed** | ★★★★★ | Our squad knows JS. Rich ecosystem. Fast iteration. CDN import, no build step. Fastest time-to-playable. |
| **Learning curve** | ★★★★★ | Minimal. Squad already writes JS. Phaser API is clean. Biggest learning: Phaser's scene lifecycle vs our custom one. |
| **Export targets** | Web only | Desktop via Electron (adds ~100MB wrapper). Mobile via Capacitor/Cordova (performance suffers). No console without custom porting. |
| **Community & longevity** | ★★★★☆ | Active, well-maintained. Richard Davey is dedicated. But HTML5 game market is shrinking relative to native. |
| **Art pipeline** | ★★★★★ | Sprite sheets, Aseprite export, Spine plugin, texture atlases. Excellent. |
| **Audio** | ★★★☆☆ | Web Audio API wrapper. File-based. We'd lose our entire procedural audio system (931 LOC). No procedural synthesis equivalent. |
| **Squad fit** | ★★★★☆ | JS squad stays in comfort zone. Greedo loses procedural audio. Everyone else adapts easily. |

**The honest truth about Phaser:**
- It IS the best browser game framework. Period.
- But "best browser game" ≠ "best game." The browser is a constraint, not an advantage.
- Our procedural audio system (931 LOC, zero assets, formant synthesis, spatial audio, adaptive music) has NO Phaser equivalent. We'd have to go file-based, losing our most innovative system.
- No beat 'em up has ever won awards or achieved commercial success on Phaser. Not one. The genre demands tight frame timing, zero-latency input, and visual polish that browsers struggle with.
- Phaser's 1.2MB bundle + browser overhead = slower startup than native.

**Ceiling comparison:**
- Can we make a Castle Crashers-quality game in Phaser? **Maybe 85% of the way.** The art and animation could match, but the performance headroom, input latency, and platform reach would fall short.
- Can we make a Shredder's Revenge-quality game in Phaser? **No.** Not at that level of visual fidelity, entity count, and frame-perfect combat.

### PixiJS + Custom

**Same rendering ceiling as Phaser** (same underlying WebGL). More control, less framework overhead, but we'd be rebuilding what Phaser gives us for free (scene management, input, physics). We already proved this approach works with firstPunch — it would just be a better version of what we have.

**Verdict:** If we stay web-only, use Phaser, not PixiJS + custom. We already did the "build everything yourself" experiment. Time to leverage a framework. But the real question is: should we stay web-only?

---

## Tier 2: Cross-Platform Game Engines

### Godot 4 ⭐ RECOMMENDED

**What it is:** Free, open-source, cross-platform game engine. GDScript (Python-like) or C# for logic. First-class 2D engine (not a 3D engine with 2D bolted on). Exports to web, Windows, macOS, Linux, Android, iOS. Console export via third-party (W4 Games).

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Visual ceiling** | 9.5/10 | Native GPU rendering, custom shaders (GLSL), particle systems, 2D lighting with normal maps, post-processing. Dome Keeper, Cassette Beasts, Brotato prove the quality. |
| **Performance ceiling** | 1000+ sprites @ 60fps native | Native binary, no browser overhead. Jolt physics engine integrated. 40% faster 2D rendering in 4.4 vs earlier. GC-free with C#. |
| **Development speed** | ★★★★☆ | GDScript has a learning curve (2-3 weeks for JS devs). But the scene/node system accelerates feature development enormously after ramp-up. Built-in animation editor, tilemap editor, particle designer reduce tool-hopping. |
| **Learning curve** | ★★★☆☆ | GDScript is Python-like — approachable for our squad. C# available for performance-critical paths. Scene/node paradigm is different from our module system but arguably better for game dev. 2-3 week ramp for productivity, 2-3 months for mastery. |
| **Export targets** | ★★★★★ | Web, Windows, macOS, Linux, Android, iOS native exports from the editor. Console via W4 Games partnership. This is the single biggest advantage over Phaser. |
| **Community & longevity** | ★★★★★ | Exploding post-Unity pricing controversy. 100K+ GitHub stars. Corporate backing (W4 Games). Foundation funding. Will absolutely exist in 5-10 years. Fastest-growing engine in the industry. |
| **Art pipeline** | ★★★★★ | Sprite sheets, Aseprite import plugin, Spine plugin, built-in animation editor with onion skinning, tilemap editor with auto-tiling, particle system with visual editor. Better pipeline than Phaser. |
| **Audio** | ★★★★☆ | Built-in audio bus system (matches our mix bus architecture!), AudioStreamPlayer, spatial audio, audio effects (reverb, EQ, compression, chorus, distortion built-in). Supports WAV/OGG/MP3 assets. We CAN still do procedural audio via AudioStreamGenerator — it provides a raw sample buffer we can fill programmatically. Greedo's synthesis skills transfer. |
| **Squad fit** | ★★★★☆ | 2-3 week ramp-up for GDScript. But after that, the built-in tools (animation editor, particle designer, shader editor, debugger, profiler) make every squad member more productive. Boba gets a real animation editor. Leia gets a real tilemap editor. Greedo gets an audio bus system that mirrors our custom one. |

**Why Godot is the ambitious choice:**

1. **2D is first-class, not an afterthought.** Godot was built for 2D from the ground up. The 2D physics, rendering, and tooling are not 3D systems with the Z-axis removed. This matters enormously for a beat 'em up where pixel-perfect collision, Y-sorting, and hitbox precision are critical.

2. **The scene/node system is perfectly suited to beat 'em ups.** Each enemy type = a scene. Each attack = a composition of hitbox + animation + SFX nodes. Each level = a scene with wave spawners. This is more natural than our current "import everything into gameplay.js" pattern.

3. **Built-in animation editor.** Our squad currently defines animations in code (frame arrays, timing objects). Godot's AnimationPlayer lets Boba and Nien create, preview, and tune animations visually with onion skinning. This is a massive productivity multiplier for a sprite-heavy game.

4. **Shader support out of the box.** Godot's shader language is simplified GLSL. Heat haze, water ripple, CRT effects, chromatic aberration, hit flash shaders — all trivial. Our current Canvas 2D ceiling (7/10 visual quality) becomes 9.5/10.

5. **Native performance.** No browser overhead. No JS garbage collection stuttering. No WebGL context limits. No tab-switching throttling. The game runs at native speed.

6. **Platform reach.** Web export for itch.io distribution. Desktop builds for Steam. Mobile for Google Play / App Store. Console via W4 Games. One codebase, every platform that matters.

7. **Procedural audio survives.** `AudioStreamGenerator` provides a raw PCM buffer. Greedo can port our oscillator-based synthesis to fill that buffer programmatically. We keep our zero-asset audio philosophy if we want, or go hybrid (procedural SFX + file-based music).

**The honest risk:**
- 2-3 weeks of reduced velocity while the squad learns GDScript and the editor
- Our 1,931 LOC engine doesn't transfer — but the KNOWLEDGE does (fixed timestep, state machines, audio bus design)
- GDScript is not JavaScript — some squad members may resist
- Console export requires W4 Games partnership (not free)

### Unity (C#)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Visual ceiling** | 9.5/10 | URP + 2D Lights + Shader Graph. River City Girls proves Unity 2D can reach top-tier beat 'em up quality. |
| **Performance ceiling** | ★★★★★ | Burst Compiler, Jobs system, native C# performance. Handles massive entity counts trivially. |
| **Development speed** | ★★★☆☆ | Heavy editor, slow iteration. C# is new for our squad. Asset store accelerates some work but adds dependency management. |
| **Learning curve** | ★★☆☆☆ | C# is a bigger jump from JS than GDScript. Unity's component system, prefab workflow, and editor conventions take weeks to internalize. The editor itself is intimidating for new users. |
| **Export targets** | ★★★★★ | Everything including console (with license). The gold standard for multi-platform. |
| **Community & longevity** | ★★★★☆ | Still industry standard but trust eroded after pricing controversy. Alternatives (Godot, Unreal) gaining ground. Will exist but may not be the default choice in 5 years. |
| **Art pipeline** | ★★★★★ | Sprite editor, animation controller, 2D tilemap, particle system, Spine integration. Excellent. Asset store for pre-built components. |
| **Audio** | ★★★★☆ | FMOD/Wwise integration, built-in mixer, spatial audio. File-based. No procedural synthesis support without custom native plugins. |
| **Squad fit** | ★★☆☆☆ | C# is a significant language shift. Heavy editor slows iteration. 12-person squad in Unity requires version control discipline (scene merge conflicts are notorious). The editor is a collaboration bottleneck. |

**Why NOT Unity for our squad:**
1. **C# is too big a jump.** Our squad thinks in JavaScript. GDScript is Python-like (2-week ramp). C# is Java-like (2-month ramp). The velocity hit is real.
2. **Editor overhead.** Unity's editor is heavy, slow to start, and requires significant RAM. Our squad's current workflow (text editor + browser + reload) is blazing fast.
3. **Pricing uncertainty.** After the runtime fee controversy, Unity's business model is unpredictable. Godot is free forever.
4. **Overkill for 2D beat 'em up.** Unity's strength is its universality. For pure 2D, Godot's tooling is better and lighter.
5. **Scene merge conflicts.** Unity scenes are binary/YAML blobs. With 12 agents working in parallel, merge conflicts would destroy velocity.

**Unity IS the right choice if:** we were building a 3D game, or needed console export on day 1, or had C# experience, or were joining a studio that uses Unity. None of those apply to us.

### Defold (Lua)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Visual ceiling** | 8/10 | Clean 2D rendering, good performance. But visual ceiling is below Godot — limited shader support, simpler particle system. Games like Craftomation 101 look good but not stunning. |
| **Performance ceiling** | ★★★★★ | Tiny binaries (<5MB), exceptional mobile performance. King's internal engine — optimized for millions of installs. |
| **Development speed** | ★★★☆☆ | Lua is unusual. Message-passing architecture is elegant but unfamiliar. Fewer tutorials and examples than Godot/Unity. |
| **Learning curve** | ★★★☆☆ | Lua is simple but the message-passing paradigm and Defold's specific patterns take time. Smaller community = fewer answers on Stack Overflow. |
| **Export targets** | ★★★★★ | Web, desktop, mobile, console (Nintendo Switch confirmed). Excellent cross-platform. |
| **Community & longevity** | ★★★☆☆ | Backed by King (Activision Blizzard). Stable but niche. Community is small, helpful, but limited. Won't disappear but won't explode either. |
| **Art pipeline** | ★★★★☆ | Sprite sheets, atlas support, built-in animation. Less robust than Godot's visual tools. |
| **Audio** | ★★★☆☆ | Basic audio playback. No built-in bus system. No procedural synthesis. |
| **Squad fit** | ★★☆☆☆ | Lua is a bigger culture shift than GDScript. Message-passing is very different from our current direct-call architecture. The squad would need to learn both a language AND a paradigm. |

**Defold verdict:** Excellent engine for mobile-first casual games. Wrong choice for a beat 'em up that needs rich visual effects, complex animation, and a large development squad. The community is too small, the visual ceiling too low, and the paradigm too unfamiliar for our team.

---

## Tier 3: The "Go Big or Go Home" Option

### Unreal Engine 5

**Assessment:** Paper 2D exists. Nobody uses it for shipping games. Unreal's 2D support is a checkbox feature, not a real toolset. The editor requires 50GB+ of disk space. Blueprint visual scripting is designed for 3D. C++ is the nuclear option.

**Lumen lighting on pixel art?** No. **Nanite for sprite rendering?** That's not how any of this works.

**Verdict:** Including this to demonstrate due diligence. It's the wrong answer and we all know it. Moving on.

---

## The 9-Dimension Evaluation Matrix

| Dimension | Phaser 3 | Godot 4 | Unity | Defold | UE5 |
|-----------|----------|---------|-------|--------|-----|
| **Visual ceiling** | 8.5/10 | 9.5/10 | 9.5/10 | 8/10 | N/A (wrong tool) |
| **Performance ceiling** | 7/10 (browser-limited) | 9/10 (native) | 10/10 (Burst/Jobs) | 9/10 (tiny binary) | N/A |
| **Development speed** | 10/10 (JS comfort) | 7/10 (learning curve, then fast) | 5/10 (C# + heavy editor) | 6/10 (Lua + paradigm shift) | 2/10 |
| **Learning curve** | 9/10 (minimal) | 7/10 (GDScript = 2-3 weeks) | 4/10 (C# = 2-3 months) | 5/10 (Lua + message-passing) | 2/10 |
| **Export targets** | 3/10 (web only) | 9/10 (all platforms) | 10/10 (everything) | 9/10 (all platforms) | 10/10 |
| **Community & longevity** | 7/10 (solid, web-focused) | 9/10 (exploding growth) | 8/10 (trust issues) | 5/10 (niche) | 10/10 |
| **Art pipeline** | 8/10 (good tooling) | 9/10 (built-in editors) | 9/10 (asset store) | 7/10 (adequate) | 6/10 (3D-first) |
| **Audio** | 5/10 (file-based only) | 8/10 (bus system + AudioStreamGenerator) | 7/10 (FMOD/Wwise) | 4/10 (basic) | 9/10 (overkill) |
| **Squad fit** | 9/10 (JS native) | 7/10 (GDScript approachable) | 4/10 (C# wall) | 4/10 (Lua + paradigm) | 2/10 |
| **TOTAL** | **66/90** | **74/90** | **66/90** | **57/90** | **N/A** |

**Godot wins by 8 points over both Phaser and Unity.**

The key differentiator: Godot scores high on BOTH development speed (after ramp-up) AND platform reach + visual ceiling. Phaser scores high on dev speed but low on platform reach. Unity scores high on platform reach but low on dev speed for our squad. Godot is the only option that's strong on both axes.

---

## The Key Question Answered

> If we're making a game we want to WIN AWARDS with, and "nos jugamos todo," is staying in the browser the right call? Or should we go native?

**Go native. Use Godot 4.**

Here's the brutal math:

1. **Every award-winning beat 'em up ships on native platforms.** Shredder's Revenge, Castle Crashers, Streets of Rage 4, River City Girls — all native. Zero browser games. The genre demands precision that browsers can't guarantee.

2. **The browser is a distribution channel, not a platform.** Godot exports to web too. We can have an itch.io web build AND a Steam desktop build AND a mobile build. Phaser only gives us option #1.

3. **Our squad's most innovative system (procedural audio) survives in Godot** via AudioStreamGenerator. In Phaser, we'd have to abandon it for file-based audio. That's going BACKWARDS.

4. **The learning curve is 2-3 weeks, not 2-3 months.** GDScript is Python-like. Our squad writes JavaScript. The conceptual gap is small. After the ramp, Godot's integrated tools (animation editor, particle designer, shader editor, debugger, profiler) make every squad member faster than they'd be in any text-editor + browser workflow.

5. **The knowledge we built transfers.** Fixed-timestep game loops, state machine design, audio bus architecture, hitlag systems, attack buffering, sprite caching, event-driven architecture — these are engine CONCEPTS, not engine CODE. They work the same in Godot.

6. **Free forever.** No pricing controversy. No runtime fees. No license audit. MIT license. Our game, our revenue, full stop.

---

## Phaser Is Not Wrong — It's Just Not "Nos Jugamos Todo"

I want to be clear: **Phaser 3 is a genuinely good engine.** If our goal were:
- Ship a fun web game for itch.io → Phaser is perfect
- Prototype fast and iterate in the browser → Phaser is ideal
- Keep the squad in their JS comfort zone → Phaser is safest
- Make something "good enough" → Phaser delivers

But "nos jugamos todo" means we're NOT playing it safe. It means:
- Ship on Steam AND itch.io AND mobile
- Visual quality that competes with Shredder's Revenge
- Performance that handles 60fps with 20+ enemies, particle storms, screen shake, and shader effects
- Sound design that pushes boundaries (keep our procedural synthesis)
- A game that could win an indie award

For THAT goal, Phaser is conformist. Godot is ambitious.

---

## Migration Plan — firstPunch Squad → Godot 4

### Phase 1: Learning Sprint (Week 1-2)
- Squad completes GDScript fundamentals (Godot docs + tutorials)
- Each specialist explores their domain in Godot:
  - Chewie: game loop, scene management, rendering pipeline
  - Lando: CharacterBody2D, input actions, state machines
  - Boba/Nien: AnimationPlayer, sprite sheets, Aseprite import
  - Greedo: AudioBus system, AudioStreamGenerator for procedural audio
  - Leia: TileMap, parallax backgrounds, level design tools
  - Bossk: GPUParticles2D, shaders, visual effects
  - Tarkin: enemy AI with navigation, behavior trees (Godot has plugins)
  - Wedge: Control nodes, UI system, themes
  - Ackbar: debugging tools, profiler, remote inspector
  - Yoda: game design docs, GDD authoring
  - Solo: project structure, autoloads, signal architecture

### Phase 2: Prototype (Week 3-4)
- Build a single-screen beat 'em up prototype in Godot
- One playable character, one enemy type, one background
- Validate: input responsiveness, hitbox system, Y-sorting, basic VFX
- Compare feel with firstPunch — must match or exceed

### Phase 3: Production (Week 5+)
- Full game development with Godot's integrated tools
- All institutional knowledge from firstPunch applied from day 1
- State machine exit transitions defined before implementation
- HiDPI + audio bus + event architecture from the start
- Clean scene/node structure enforced from project creation

### What Transfers Directly
| firstPunch Knowledge | Godot Equivalent |
|----------------------|-----------------|
| Fixed-timestep loop | `_physics_process(delta)` — built in |
| State machines | Same pattern, AnimationTree for complex ones |
| Audio bus hierarchy | AudioBus system — built in, visual editor |
| Event bus (pub/sub) | Signals — Godot's native equivalent, stronger typed |
| Sprite caching | Texture management — built in |
| Hitlag / time scale | `Engine.time_scale` — built in |
| Screen shake / zoom | Camera2D properties — built in |
| Scene transitions | SceneTree.change_scene_to_packed() + AnimationPlayer |
| Attack buffering | Input.is_action_just_pressed() + buffer pattern |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| GDScript learning takes longer than 3 weeks | Medium | Medium | C# available as fallback for complex systems |
| Squad resists leaving JavaScript | Low-Medium | High | Show Godot's integrated tools — the productivity gains sell themselves |
| Web export quality is lower than Phaser | Low | Low | Godot web export is solid; can always publish native as primary |
| Console export requires W4 Games ($) | Certain | Low | Not needed at launch. Ship on Steam/itch.io first, console later |
| Godot 4 has breaking changes in minor versions | Medium | Medium | Pin to a stable release (4.4.x), don't chase bleeding edge |

---

## Final Verdict

| Goal | Best Engine | Why |
|------|------------|-----|
| Ship fast, stay comfortable | **Phaser 3** | JS squad, zero learning curve, web-first |
| Compete with the best, "nos jugamos todo" | **Godot 4** | Native performance, multi-platform, built-in tools, free |
| Enterprise/console-first | **Unity** | Proven console pipeline, asset store, industry standard |
| Mobile-first casual | **Defold** | Tiny binaries, King's backing, mobile-optimized |

**We said "nos jugamos todo." The answer is Godot 4.**

Not because it's trendy. Not because Unity had a pricing scandal. Because it's the only engine that gives our 12-person squad the visual ceiling, performance headroom, platform reach, and development tools to make a game that can stand next to Shredder's Revenge and not look embarrassed.

Phaser would get us 85% there. Godot gets us 100%.

The 15% gap is the difference between "hey, nice browser game" and "this is a GAME."

—Chewie, Engine Dev
