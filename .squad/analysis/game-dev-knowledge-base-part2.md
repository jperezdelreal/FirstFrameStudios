# Game Development Knowledge Base — Part 2

> Compressed from 36KB. Full: game-dev-knowledge-base-part2-archive.md

**Author:** Yoda (Game Designer)  
**Date:** 2025-07-15  
---

## Discipline 6: Visual Design
### Core Principles
Color in games is never decorative — it is *informational*. Every hue on screen must answer one of three questions for the player: "What am I?", "What hurts me?", and "What do I want?" The game IP gives us a head start here because its palette is iconic and instantly readable: character yellow (#FED90F), Downtown Sky Blue (#87CEEB), and Joe's Bar Purple (#663399) are burned into cultural memory. A game designer's job is to exploit that recognition ruthlessly.
### Best Practices
### Common Mistakes
### firstPunch Application
---

## Discipline 7: UX/UI Design
### Core Principles
**Juiciness** is the philosophy that every player action should produce a response that feels disproportionately satisfying. A punch isn't just collision detection — it's a hit spark, a screen shake, a damage number floating upward, a hitstun freeze, an audio crunch, and the enemy sliding backward. Remove any one of these and the punch feels 30% weaker. Our combat system layers six feedback channels simultaneously: visual (sparks, trails), kinetic (knockback, screen shake), temporal (hitlag freeze 2–3 frames), numeric (damage numbers), auditory (impact SFX), and chromatic (screen flash). Juiciness isn't polish — it's the difference between "responsive" and "dead" controls. It ships in P0 or the game doesn't ship.
### Best Practices
### Common Mistakes
### firstPunch Application
---

## Discipline 8: Technical Architecture
### Core Principles
**The game loop is the heartbeat** — get it wrong and every system built on top inherits the arrhythmia. There are three loop patterns: variable timestep (simple but non-deterministic), fixed timestep with interpolation (deterministic, smooth rendering), and fixed timestep with accumulator (deterministic, simpler to implement). We chose the accumulator pattern: `while (accumulator >= fixedDelta) { update(dt); accumulator -= fixedDelta; }` with a 0.25s frame time cap to prevent death spirals after tab-switch. This gives us deterministic physics at 60 FPS regardless of display refresh rate. The key insight: hitlag, zoom, and time scale operate on *real* delta time while gameplay operates on *scaled* delta time — they live in different temporal layers within the same loop.
### Best Practices
### Common Mistakes
### firstPunch Application
---

## Discipline 9: Quality Assurance
### Core Principles
**Playtesting is a science, not an opinion.** A playtest session has a hypothesis ("players will discover the combo system within 30 seconds"), a controlled environment (specific build, specific hardware, no coaching), observation methods (screen recording, input logging, verbal think-aloud), and measurable outcomes (time to first combo, death count in wave 1, player-reported fun rating). Without structure, playtesting degenerates into "my friend played it and said it was fine." The designer's ego must be absent from the room — you're testing the *game*, not defending your decisions.
### Best Practices
### Common Mistakes
### firstPunch Application
---

## Discipline 10: Production & Process
### Core Principles
**Vertical slice methodology** means building one complete, polished slice of the game before expanding horizontally. For firstPunch, the vertical slice was: one character (Brawler), one level section (Downtown street), one enemy type (normal goon), complete with combat, movement, VFX, audio, and HUD. This slice proves the game *works* — it has the loop of move → fight → advance → fight harder. Only after the slice feels good do you add enemy variants, level sections, and additional characters. The temptation is always to add breadth (more enemies! more levels! more characters!) before the core slice is polished. Resist this: a game with one perfect level and three broken ones ships worse than a game with one perfect level and nothing else.
### Best Practices
### Common Mistakes
### firstPunch Application
---

## Cross-Discipline Synthesis
These five disciplines form a feedback loop: **Visual Design** creates the world players see, **UX/UI Design** ensures players can navigate and understand that world, **Technical Architecture** makes both possible at 60 FPS, **Quality Assurance** verifies everything works correctly, and **Production & Process** coordinates the humans (and agents) building it all. The common thread across all five is *intentionality*: every color choice, every HUD element, every architectural pattern, every test case, and every scope decision should trace back to a player experience goal. firstPunch's strongest lesson is that constraints (Canvas 2D, zero dependencies, procedural art, small team) don't limit quality — they focus it. The game feels good to play not despite its limitations but because every decision was made within known boundaries, leaving no room for half-measures.