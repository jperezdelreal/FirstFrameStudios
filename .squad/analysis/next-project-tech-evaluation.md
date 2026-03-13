# Next Project Tech Evaluation — "Nos Jugamos Todo"

> Compressed from 23KB. Full: next-project-tech-evaluation-archive.md

**Author:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
---

## Executive Summary
**Phaser 3 is a good engine. But "good" is not what you said you wanted. You said "nos jugamos todo."**
After building firstPunch from scratch — 1,931 LOC of custom engine, 28 source files, every system hand-crafted — I know exactly what Canvas 2D and browser JavaScript can do. I know the ceiling. And I'm telling you: **the ceiling exists, and it's lower than where we need to be if we're serious about competing.**
---

## The Reference Games — What Are We Competing Against?
Before evaluating engines, let's be honest about the quality bar:
| Game | Quality | Engine | Platform |
| **TMNT: Shredder's Revenge** | 10/10 beat 'em up | Proprietary (Tribute Games) | PC, Console, Mobile |
| **Castle Crashers** | 9/10 | Custom (The Behemoth) | PC, Console |
| **Streets of Rage 4** | 9.5/10 | Custom (Guard Crush/Lizardcube) | PC, Console |
| **River City Girls** | 9/10 | Unity | PC, Console |
| **Fight'N Rage** | 8.5/10 | Custom (C++) | PC, Console |
| **Scott Pilgrim vs The World** | 9/10 | Custom (Tribute Games) | PC, Console |
---

## Tier 1: Web Frameworks (Browser-Only)
### Phaser 3
**What it is:** Complete 2D game framework. WebGL + Canvas 2D renderer, built-in physics, scene management, input, audio, tweens, cameras, tilemaps, animation. Massive community, excellent docs.
| Criterion | Score | Notes |
| **Visual ceiling** | 8.5/10 | WebGL renderer enables shaders, filters, blend modes. Best browser games look polished-indie. No shipped beat 'em up at Shredder's Revenge quality. |
| **Performance ceiling** | ~1000 sprites @ 60fps | Browser-constrained. WebGL helps, but JS garbage collection causes micro-stutters. No native threading. |
| **Development speed** | ★★★★★ | Our squad knows JS. Rich ecosystem. Fast iteration. CDN import, no build step. Fastest time-to-playable. |
| **Learning curve** | ★★★★★ | Minimal. Squad already writes JS. Phaser API is clean. Biggest learning: Phaser's scene lifecycle vs our custom one. |
| **Export targets** | Web only | Desktop via Electron (adds ~100MB wrapper). Mobile via Capacitor/Cordova (performance suffers). No console without custom porting. |
---

## Tier 2: Cross-Platform Game Engines
### Godot 4 ⭐ RECOMMENDED
**What it is:** Free, open-source, cross-platform game engine. GDScript (Python-like) or C# for logic. First-class 2D engine (not a 3D engine with 2D bolted on). Exports to web, Windows, macOS, Linux, Android, iOS. Console export via third-party (W4 Games).
| Criterion | Score | Notes |
| **Visual ceiling** | 9.5/10 | Native GPU rendering, custom shaders (GLSL), particle systems, 2D lighting with normal maps, post-processing. Dome Keeper, Cassette Beasts, Brotato prove the quality. |
| **Performance ceiling** | 1000+ sprites @ 60fps native | Native binary, no browser overhead. Jolt physics engine integrated. 40% faster 2D rendering in 4.4 vs earlier. GC-free with C#. |
| **Development speed** | ★★★★☆ | GDScript has a learning curve (2-3 weeks for JS devs). But the scene/node system accelerates feature development enormously after ramp-up. Built-in animation editor, tilemap editor, particle designer reduce tool-hopping. |
| **Learning curve** | ★★★☆☆ | GDScript is Python-like — approachable for our squad. C# available for performance-critical paths. Scene/node paradigm is different from our module system but arguably better for game dev. 2-3 week ramp for productivity, 2-3 months for mastery. |
| **Export targets** | ★★★★★ | Web, Windows, macOS, Linux, Android, iOS native exports from the editor. Console via W4 Games partnership. This is the single biggest advantage over Phaser. |
---

## Tier 3: The "Go Big or Go Home" Option
### Unreal Engine 5
**Assessment:** Paper 2D exists. Nobody uses it for shipping games. Unreal's 2D support is a checkbox feature, not a real toolset. The editor requires 50GB+ of disk space. Blueprint visual scripting is designed for 3D. C++ is the nuclear option.
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
---

## The Key Question Answered
> If we're making a game we want to WIN AWARDS with, and "nos jugamos todo," is staying in the browser the right call? Or should we go native?
**Go native. Use Godot 4.**
---

## Phaser Is Not Wrong — It's Just Not "Nos Jugamos Todo"
I want to be clear: **Phaser 3 is a genuinely good engine.** If our goal were:
- Ship a fun web game for itch.io → Phaser is perfect
---

## Migration Plan — firstPunch Squad → Godot 4
### Phase 1: Learning Sprint (Week 1-2)
- Squad completes GDScript fundamentals (Godot docs + tutorials)
### Phase 2: Prototype (Week 3-4)
### Phase 3: Production (Week 5+)
### What Transfers Directly
| firstPunch Knowledge | Godot Equivalent |
| Fixed-timestep loop | `_physics_process(delta)` — built in |
| State machines | Same pattern, AnimationTree for complex ones |
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