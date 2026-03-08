# Game Development Knowledge Base — Part 2

**Author:** Yoda (Game Designer)  
**Date:** 2025-07-15  
**Project:** firstPunch — Browser-based game beat 'em up  
**Scope:** Disciplines 6–10 of 10. Cross-project institutional knowledge.  
**Companion:** Part 1 covers Disciplines 1–5.

---

## Discipline 6: Visual Design

### Core Principles

Color in games is never decorative — it is *informational*. Every hue on screen must answer one of three questions for the player: "What am I?", "What hurts me?", and "What do I want?" The game IP gives us a head start here because its palette is iconic and instantly readable: character yellow (#FED90F), Downtown Sky Blue (#87CEEB), and Joe's Bar Purple (#663399) are burned into cultural memory. A game designer's job is to exploit that recognition ruthlessly.

**Depth through parallax** is one of the cheapest ways to make a 2D game feel expensive. The human eye infers depth from differential motion — objects closer move faster, objects farther move slower. Our four-layer parallax system (far at 0.2×, mid at 0.5×, near at 1.0×, foreground at 1.3×) creates convincing depth without a single 3D calculation. The foreground layer at 1.3× is the secret weapon: lampposts and fences sliding *past* the player create a "looking through a window" effect that most 2D games skip entirely.

**Particle design** must serve readability first, spectacle second. Hit sparks (#FFD700 gold, #FFFFEE off-white, #FFA500 orange) need to pop against Downtown's muted pastels without obscuring the combat. Dust clouds (#C4A46C browns) should ground characters to the pavement. Death debris can be flamboyant because the threat is already resolved.

**Screen composition** in a scrolling beat 'em up demands that the action zone (where punches land) occupies the center 40% of the screen horizontally. HUD elements anchor to corners. Enemy spawn telegraphs need to be visible in peripheral vision. Our 1280×720 logical resolution gives us roughly 512px of "combat stage" — enough for two characters exchanging blows with breathing room.

**Resolution independence** means designing to a logical coordinate system and scaling to the display. Our renderer multiplies by `devicePixelRatio` so art drawn at 1280×720 looks crisp on 4K screens. The trap is pixel-snapping: fractional coordinates create fuzzy lines on Canvas 2D. Always `Math.round()` positions before drawing.

### Best Practices

- **Establish a palette document early.** We use enemy-type colors (purple/normal, red/tough, blue/fast, green/heavy, orange/boss) as gameplay language. Players learn threat levels through color before they read any UI.
- **Layer parallax from back-to-front, paint in that order.** Background → midground → entities → foreground → UI → debug. Violating this order causes visual z-fighting that's hard to debug.
- **Cap particle counts.** Canvas 2D has a hard wall around ~50 simultaneous particles before frame drops appear. Budget particles per effect and enforce global caps.
- **Use consistent outline thickness.** Our 3px black text stroke and entity outlines (#222222) create a "cartoon cel" look that unifies procedural art. Without this, Canvas shapes look flat and disconnected.
- **Motion trails should match attack type.** Punch trails in warm yellow (#FFD700), kick trails in cool blue (#4488FF), special trails in danger red (#FF3333). This reinforces the combat language through color.

### Common Mistakes

- **Palette bloat.** Adding colors ad hoc until the game looks like a paint store. Every new color needs justification against the existing palette.
- **Parallax direction reversal.** Our original bug had backgrounds scrolling at 1.3× (faster than player) instead of 0.3× — making far objects move *toward* the player. This breaks spatial intuition instantly.
- **Ignoring value contrast.** Colors that look distinct on a calibrated monitor may merge on a cheap laptop. Test in grayscale: if you can't distinguish elements, your value contrast is too low.
- **Over-designing procedural art.** Each character takes ~400 LOC of Canvas drawing code. At some point, the cost of adding visual detail exceeds the value. We hit this ceiling — it's our strongest argument for migrating to sprite sheets.
- **Particles that outlive their purpose.** A hit spark lasting 500ms obscures the next attack. Particles should communicate and vanish: 150–250ms is the sweet spot for combat feedback.

### firstPunch Application

Our procedural art style (zero external assets, pure Canvas 2D drawing) creates both a unique aesthetic identity and a hard production ceiling. Each new character requires ~400 LOC of body-part rendering: head circle, body rectangle, limbs with joint positioning. The Downtown background system generates Quick Stop, houses (#E8C48A, #C46B6B, #8FBC8F, #D4A574), the Factory, and City School through layered rectangles with color variation. This works *because* the source IP has a simple, flat visual style — the IP and the technology constraint aligned beautifully. Our VFX system (15+ effect types in vfx.js at 1300+ LOC) compensates for static character art with dynamic motion trails, starbursts, damage numbers, and screen flashes. The lesson: if your characters can't animate fluidly, make the *world* react fluidly to them.

### Future Learnings

- **Sprite sheet migration** is inevitable for character roster expansion. Phaser 3's texture atlas system would replace ~1200 LOC of procedural drawing for Kid/Defender/Prodigy alone.
- **Shader effects** (glow, color grading, distortion) require WebGL. Canvas 2D's `globalCompositeOperation` is a partial substitute but can't replicate bloom or chromatic aberration.
- **Resolution-independent UI** should use a separate coordinate system from gameplay. When zoom effects scale the game camera, HUD elements must remain stable — our current approach handles this but would break with more complex UI layouts.
- **Visual hierarchy testing**: screenshot the game in grayscale and at 50% size. If you can still identify player, enemies, and pickups, your visual design is sound.

---

## Discipline 7: UX/UI Design

### Core Principles

**Juiciness** is the philosophy that every player action should produce a response that feels disproportionately satisfying. A punch isn't just collision detection — it's a hit spark, a screen shake, a damage number floating upward, a hitstun freeze, an audio crunch, and the enemy sliding backward. Remove any one of these and the punch feels 30% weaker. Our combat system layers six feedback channels simultaneously: visual (sparks, trails), kinetic (knockback, screen shake), temporal (hitlag freeze 2–3 frames), numeric (damage numbers), auditory (impact SFX), and chromatic (screen flash). Juiciness isn't polish — it's the difference between "responsive" and "dead" controls. It ships in P0 or the game doesn't ship.

**Information hierarchy in HUDs** follows a strict priority: (1) player health — always visible, always in a consistent screen position, (2) combo/score — visible during action, fades when idle, (3) contextual prompts — appears only when relevant, (4) system info — debug overlay toggled by backtick, hidden by default. The cardinal sin of HUD design is showing the player information they don't need right now. Every UI element that's always visible creates cognitive load that competes with gameplay.

**Menu flow** should follow the "one-button-deeper" principle: each menu press takes you one level deeper, and escape/back always returns exactly one level. Our flow is Title → Gameplay → Pause → Options, with consistent input mapping at every level. Menu transitions (our fade-out/fade-in system) communicate state changes — a hard cut between screens feels like a bug, not a feature.

**Accessibility** in game UI means more than colorblind modes (though those matter). It means readable font sizes (our 3px text stroke ensures legibility at all resolutions), sufficient contrast ratios, and input schemes that don't require simultaneous button presses. Attack buffering (150ms window) is an accessibility feature disguised as a combat mechanic: it forgives imprecise timing without the player knowing they're being helped.

**Onboarding without tutorials** is the gold standard. Players should learn by doing, not reading. Our title scene shows key cap icons for controls (WASD, JKXZ, Space, Enter) — this is a concession, not ideal. The ideal is environmental teaching: the first enemy should be slow enough that mashing punch works, teaching the player that J is attack. The second wave introduces a tougher enemy that requires the combo timing the player accidentally discovered. Progressive complexity replaces instruction manuals.

### Best Practices

- **Every HUD element earns its screen space.** If a player never looks at it during combat, it shouldn't be there during combat. Health bar: yes. Score: can fade. Lives remaining: show on death.
- **Lerp all numeric displays.** Our score counter smoothly interpolates to the new value rather than jumping. This turns number changes into animations that the eye tracks naturally.
- **Combo counters must pulse and scale.** A static "5 HIT" text doesn't communicate momentum. Our counter scales up on each hit and adds a glow pulse — the UI *celebrates* with the player.
- **Menu navigation must be instantaneous.** Frame-perfect response to menu inputs. The game loop can have 3-frame hitlag for dramatic effect; the menu cannot have 1 frame of input delay.
- **Test UI at minimum and maximum expected resolution.** 1280×720 on a laptop and 3840×2160 on a 4K monitor. If text is unreadable at either extreme, the scaling system is broken.

### Common Mistakes

- **Tutorial text walls.** "Press J to punch, K to kick, X to grab, Z to special, Space to jump, Shift to dash." Players' eyes glaze over. Introduce one mechanic at a time through gameplay encounters.
- **HUD elements that obscure gameplay.** A health bar in the center of the screen, overlapping the combat zone, is worse than no health bar at all.
- **Inconsistent button mapping across screens.** If J is "confirm" in gameplay (attack), it should be "confirm" in menus too. Our current menu uses Enter for confirm — acceptable because menus are a different interaction mode, but worth unifying in future projects.
- **Missing feedback on invalid actions.** When the player presses attack during knockback and nothing happens, there's no audio or visual cue explaining why. A subtle "bonk" sound or UI flash says "I heard you, but not right now" — far better than silence.
- **Forgetting the pause state.** Pausing during an attack animation, then unpausing, must resume exactly where it left off. State corruption during pause/unpause is a classic UX bug category.

### firstPunch Application

Our juiciness stack is already competitive with commercial titles: hitlag (2–3 frame freeze), screen shake, motion trails (4-frame afterimage), damage numbers (with combo scaling), hit sparks (light/medium/heavy intensity), KO starbursts with orbiting stars, and speed lines for dashes. The style meter tracks unique attack variety, rewarding players for using their full moveset. The combo counter pulses and scales. What we're missing: (1) *negative* feedback — there's no juice for getting hit beyond i-frame blinking, (2) environmental reactions — destructibles break but the world doesn't *flinch*, (3) audio juice — we have procedural SFX but lack hit sound *variation* (the same crunch 50 times becomes invisible). The debug overlay (FPS, entity count, collision checks, VFX count) is excellent developer UX — toggled with backtick, never shown to players. Our HUD draws health, score, and combo counter with proper layering priority.

### Future Learnings

- **Haptic feedback** (gamepad rumble via Gamepad API) would add a physical feedback channel we currently lack entirely.
- **Dynamic HUD opacity**: fade HUD elements to 30% opacity during uninterrupted combat, restore to 100% when health changes or combo breaks. Reduces visual noise during flow state.
- **Accessibility audit checklist**: colorblind simulation, font size at minimum resolution, single-handed play test, screen reader compatibility for menus. Should be a standard pre-ship gate.
- **Onboarding replay value**: players who replay should skip tutorials automatically. Track "has the player ever thrown a punch?" in a lightweight progress flag.

---

## Discipline 8: Technical Architecture

### Core Principles

**The game loop is the heartbeat** — get it wrong and every system built on top inherits the arrhythmia. There are three loop patterns: variable timestep (simple but non-deterministic), fixed timestep with interpolation (deterministic, smooth rendering), and fixed timestep with accumulator (deterministic, simpler to implement). We chose the accumulator pattern: `while (accumulator >= fixedDelta) { update(dt); accumulator -= fixedDelta; }` with a 0.25s frame time cap to prevent death spirals after tab-switch. This gives us deterministic physics at 60 FPS regardless of display refresh rate. The key insight: hitlag, zoom, and time scale operate on *real* delta time while gameplay operates on *scaled* delta time — they live in different temporal layers within the same loop.

**ECS vs OOP** is the defining architectural decision for any game. Entity-Component-System separates data (components) from logic (systems), enabling composition over inheritance. Pure OOP ties behavior to class hierarchies, making cross-cutting concerns (like "everything that takes damage") require awkward base classes or mixins. We landed in the middle: our entities are OOP objects (Player, Enemy classes) but our logic lives in stateless system modules (combat.js, ai.js, camera.js, wave-manager.js). This "OOP entities + system functions" hybrid gives us the readability of classes with the composability of systems. For a team of our size and a game of our scope, this is the right trade-off. A 200-entity bullet hell would demand full ECS; a 10-entity beat 'em up does not.

**State machines** govern entity behavior. Player states (idle, walk, attack, hit, dead, jump, grab, dodge) form a directed graph where each state defines valid transitions. The state machine prevents impossible combinations (attacking while dead) and makes debugging trivial: "what state was the entity in when the bug occurred?" Our AI system extends this with a lightweight behavior tree: enemies evaluate distance, attack cooldowns, and the 2-attacker throttle to choose their next state. State machines are the single most important pattern in game programming — they make complex behavior predictable.

**Performance optimization** in Canvas 2D follows a strict hierarchy: (1) don't draw what's off-screen (frustum culling), (2) batch similar draw calls, (3) cache complex shapes to offscreen canvases (our SpriteCache), (4) minimize state changes (font, fillStyle, globalAlpha), (5) reduce particle counts. Our debug overlay tracks FPS, entity count, and collision checks in real-time. The rule: measure before optimizing, and optimize the measured bottleneck, not the suspected one.

**Canvas 2D vs WebGL vs frameworks** represents a technology spectrum. Canvas 2D: zero setup, no build tools, immediate-mode rendering, ~50 particle cap, no shaders. WebGL: GPU-accelerated, shader support, complex setup, requires matrix math or a framework. Frameworks (Phaser 3, PixiJS): abstract rendering backend, provide scene graphs, asset pipelines, and physics — but add dependency weight and learning curves. Our decision to use raw Canvas 2D was correct for prototyping speed and zero-dependency simplicity. The decision has a shelf life: adding characters, complex animations, or visual effects beyond our current 15-type VFX system pushes us toward Phaser 3 + WebGL.

### Best Practices

- **Separate engine from game.** Our `src/engine/` (9 files, 1931 LOC) provides infrastructure; `src/systems/` and `src/entities/` contain game-specific logic. This boundary means the engine could power a different game without modification.
- **Fixed timestep is non-negotiable for physics.** Variable timestep causes different jump heights at different frame rates — a game-breaking inconsistency.
- **EventBus decouples systems.** Our events.js (48 LOC) enables pub/sub communication. Combat doesn't need to know about VFX — it emits 'enemy-hit', and VFX subscribes. Currently underutilized (gameplay.js still makes 40+ direct calls), but the architecture is correct.
- **Config-driven tuning.** Our CONFIG object centralizes magic numbers. Changing `ENEMY_ATTACK_COOLDOWN` in one place affects all enemies. This is essential for balance iteration.
- **Profile before you optimize.** The debug overlay showing collision check counts prevented us from optimizing the wrong system. The actual bottleneck was particle rendering, not collision detection.

### Common Mistakes

- **The God Object.** Our gameplay.js (695 LOC) touches every system — it's the #1 technical debt item. Wiring the EventBus would break this into decoupled handlers. The lesson: a "coordinator" file that grows unchecked becomes the system it was meant to coordinate.
- **Premature framework adoption.** Choosing Phaser 3 on day one would have added a learning curve, build pipeline, and dependency management before we had a single punch animation. Vanilla JS let us ship gameplay in 30 minutes. The framework should solve problems you've already encountered.
- **State machine spaghetti.** Without explicit transition tables, states can transition to anywhere. "Can the player attack from the grab state?" becomes a question that requires reading code instead of checking a table. Define transitions declaratively.
- **Ignoring the accumulator residual.** The leftover `accumulator` value after the while-loop represents sub-frame time. Ignoring it causes micro-stutter. Interpolating render positions by `accumulator / fixedDelta` produces buttery-smooth visuals. We don't currently interpolate — a future improvement.
- **Over-engineering for scale you don't have.** Object pooling, spatial hashing, and quad trees are essential at 1000 entities. At 10 entities, they're complexity without benefit. Design for your current order of magnitude, refactor at the next.

### firstPunch Application

Our architecture is a pragmatic hybrid that serves our scope. The game loop (game.js, 191 LOC) is production-quality: fixed timestep, death spiral prevention, hitlag/zoom/slow-mo as temporal layers, and clean scene transitions. The entity model (Player 64×80px, Enemy with 5 variants) uses OOP with state machine behavior — appropriate for our entity count. The system separation (combat.js, ai.js, camera.js, background.js, vfx.js, wave-manager.js) keeps logic modular. The renderer (112 LOC) is HiDPI-aware with camera transforms and screen shake. Unused infrastructure (EventBus 49 LOC, AnimationController 85 LOC, SpriteCache 35 LOC, CONFIG 45 LOC) totals 214 LOC of working code waiting to be wired — this is the highest-priority technical debt alongside the gameplay.js decomposition. The zero-dependency constraint (`<script type="module">` only, no npm, no bundler) enables instant local development but limits access to ecosystem tools.

### Future Learnings

- **Phaser 3 migration** would replace ~800 LOC of infrastructure (loop, renderer, input, camera, particles, animation) with GPU-accelerated equivalents while preserving ~3500 LOC of game logic. This is a known quantity, not a guess.
- **WebGL shader effects** (bloom, color grading, CRT scanlines) are impossible in Canvas 2D. Even PixiJS as a rendering backend (without full Phaser) would unlock these.
- **Render interpolation** (using accumulator residual) would eliminate micro-stutter at high refresh rates. Low effort, high visual impact.
- **Spatial partitioning** becomes necessary if enemy counts exceed ~20 per screen. Grid-based is simplest; quad-tree is overkill for a 2D beat 'em up.

---

## Discipline 9: Quality Assurance

### Core Principles

**Playtesting is a science, not an opinion.** A playtest session has a hypothesis ("players will discover the combo system within 30 seconds"), a controlled environment (specific build, specific hardware, no coaching), observation methods (screen recording, input logging, verbal think-aloud), and measurable outcomes (time to first combo, death count in wave 1, player-reported fun rating). Without structure, playtesting degenerates into "my friend played it and said it was fine." The designer's ego must be absent from the room — you're testing the *game*, not defending your decisions.

**Bug categorization** determines fix priority. We use a four-tier system: **P0 (Blocker)** — game crashes, save corruption, infinite loops, softlocks. Ship cannot proceed. **P1 (Critical)** — gameplay-breaking but workaround exists. Combat doesn't register hits, enemies stop attacking, player clips through floor. **P2 (Major)** — noticeable but non-breaking. Visual glitches, audio desync, UI misalignment, balance issues (enemy too easy/hard). **P3 (Minor)** — cosmetic. Pixel-off alignment, slight color inconsistency, text typo. The iron rule: all P0s fixed before any P2 work begins. Severity is about *player impact*, not developer difficulty.

**Automated testing in games** is harder than in business software because "correct" is subjective. A unit test can verify that `applyDamage(50)` reduces health by 50, but it can't verify that the hit *feels* good. The strategy is to automate the objective and playtest the subjective: automated tests for math (damage formulas, combo calculations, state transitions), manual playtests for feel (hitlag duration, screen shake intensity, animation timing). Our debug overlay (FPS, entity count, collision checks) is a lightweight automation — it continuously validates performance without a test runner.

**Balance testing** requires systematic comparison, not intuition. Frame data analysis (our frame-data.md documents startup, active, recovery, and DPS for every attack) turns "this move feels too strong" into "this move has 42 DPS vs the target of 38." Balance bugs are the hardest to categorize because they're invisible to non-expert players and game-ruining for expert players. The solution: define numeric targets for every combat parameter *before* implementation, then measure actual values against targets.

**Regression strategies** prevent fixed bugs from returning. Every P0/P1 fix should generate a regression test case (our regression-checklist.md has 12+ scenarios). The checklist pattern works: after every combat system change, run through "Attack During Knockback," "Jump at Screen Edge," "Pause During Attack Animation," and others. Each test has expected behavior, test steps, pass criteria, and fail criteria. If a test takes more than 60 seconds to execute manually, it's a candidate for automation.

### Best Practices

- **Record every playtest.** Screen capture with input overlay. You'll reference these recordings during design debates — "the player paused for 3 seconds looking for the health bar" is more convincing than "I think the health bar is hard to find."
- **Bug reports need reproduction steps.** "Combat is broken" is not a bug report. "Enemy does not take damage when hit with jump kick at the left screen boundary during wave 3" is. Minimum viable bug report: steps to reproduce, expected behavior, actual behavior, frequency (always/sometimes/rare).
- **Separate feel bugs from logic bugs.** "Enemy takes wrong damage" is logic — unit-testable. "Enemy hit doesn't feel impactful" is feel — requires playtest and VFX/audio tuning. Different bugs, different fix methodologies.
- **Balance in spreadsheets, feel in-game.** DPS calculations, health pools, and damage ratios belong in calculable models. Hitlag duration, screen shake intensity, and knockback curves must be tuned by playing.
- **Regression test after every merge.** Our 12-scenario checklist takes ~8 minutes to run manually. This is the cheapest insurance against shipping broken builds.

### Common Mistakes

- **Testing only the happy path.** "Player punches enemy, enemy takes damage" passes. But what about: player punches during enemy invulnerability? Player punches at exact screen boundary? Player punches during scene transition? Edge cases are where bugs live.
- **Fixing bugs without understanding root cause.** Adding a `if (health < 0) health = 0` check might mask an integer overflow in the damage calculation. Fixes should address causes, not symptoms.
- **Balance tuning by committee.** "Let's make the boss easier because I died" is not balance methodology. Compare actual difficulty metrics (average attempts to clear, time-to-kill) against target metrics, then adjust specific parameters.
- **Skipping regression after "small" changes.** The parallax direction fix (changing 1.3× to 0.3×) was a one-line change. Without regression testing, we wouldn't have caught that it also affected foreground element positioning. Small changes have large blast radii.
- **No baseline build.** Without a "known good" build to compare against, you can't tell if a bug is new or pre-existing. Tag stable builds in version control. Our commit history serves this purpose, but explicit "QA-passed" tags would be better.

### firstPunch Application

Our QA infrastructure is lightweight but effective for our scale. The debug overlay (debug-overlay.js, toggled with backtick) provides real-time performance monitoring: FPS, entity count, collision checks, VFX count, and world-space bounding box visualization. The regression checklist (regression-checklist.md) covers 12+ critical combat/movement scenarios with detailed pass/fail criteria. Balance analysis (balance-analysis.md, frame-data.md) provides numeric targets: PPK combo at 42 DPS/1.1s is the combat foundation, jump DPS capped at 38, all six critical flags from Ackbar's audit addressed. Playtest verification (playtest-verification.md) documents structured play sessions. What we lack: (1) automated test runner — no Jest, no Mocha, no unit tests for damage formulas or state transitions, (2) input replay — we can't record and replay a gameplay session for deterministic regression testing, (3) continuous integration — no automated build verification on commit. These gaps are acceptable for a solo/small-team project but would be blockers for a production team.

### Future Learnings

- **Input replay system** (record frame-by-frame inputs, replay deterministically against new builds) is the single highest-value QA investment for a fixed-timestep game. Our deterministic loop makes this feasible.
- **Automated screenshot comparison** catches visual regressions that manual playtests miss. Capture reference screenshots at key moments, diff against new builds pixel-by-pixel.
- **Telemetry-driven balance**: if the game had analytics (heatmaps of player death locations, attack usage frequency, average combo length), balance tuning would be data-driven instead of intuition-driven.
- **Fuzz testing for state machines**: randomly inject input sequences and verify no state becomes unreachable or stuck. If `attack → hit → dead → ???` ever leads to an undefined state, the fuzz tester catches it.

---

## Discipline 10: Production & Process

### Core Principles

**Vertical slice methodology** means building one complete, polished slice of the game before expanding horizontally. For firstPunch, the vertical slice was: one character (Brawler), one level section (Downtown street), one enemy type (normal goon), complete with combat, movement, VFX, audio, and HUD. This slice proves the game *works* — it has the loop of move → fight → advance → fight harder. Only after the slice feels good do you add enemy variants, level sections, and additional characters. The temptation is always to add breadth (more enemies! more levels! more characters!) before the core slice is polished. Resist this: a game with one perfect level and three broken ones ships worse than a game with one perfect level and nothing else.

**Feature freeze and polish** are two distinct phases that most indie projects blur together. Feature freeze means: no new mechanics, no new systems, no new content types. Everything added after freeze is tuning, fixing, or removing. Polish is the work of making existing features feel *finished*: adjusting hitlag from 3 frames to 2, tightening knockback curves, adding that extra particle burst on KO, ensuring the combo counter pulses at exactly the right rate. Polish is not the absence of work — it's the hardest, most taste-dependent work in game development. Our squad principle "Ship It Then Perfect It" encodes this: launch the vertical slice, then enter an unbounded polish phase on what exists.

**Scope cutting** is a skill, not a failure. Every game ships with features that were planned and cut. The discipline is cutting *early* (before implementation cost is sunk) and cutting *whole features* (not half-implementing everything). Our GDD identifies the game at ~75% MVP with explicit gaps: no grab/throw system yet, no specials system, no dodge roll, no enemy variety beyond basic types. Each of these is a discrete feature that can be cut entirely without leaving broken stubs. The worst scope management leaves half-built systems in the codebase — they confuse developers and tease players with promises the game can't keep.

**Retrospectives** transform experience into institutional knowledge. After each milestone (prototype, vertical slice, alpha, beta, ship), the team asks three questions: "What worked?", "What didn't?", and "What will we do differently next time?" The answers become decision documents (our decisions.md) and learnings (our history.md files per agent). The key discipline: retrospectives must produce *action items*, not just feelings. "Communication was hard" becomes "We will use the EventBus pattern for inter-system communication in the next project" or "Decision inbox files will be reviewed within 24 hours."

**Multi-agent coordination** is the production challenge unique to our squad structure. Nine specialists (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda) each own a domain but share a codebase. Coordination requires: (1) clear domain boundaries (decisions.md documents who owns what), (2) a shared backlog with priority tiers (P0–P3), (3) dependency tracking (Tarkin's enemy content depends on Lando's combat system), (4) a single source of truth for game design direction (the GDD). The bottleneck we solved: McManus (engine) was blocking four downstream agents. Adding Tarkin and Greedo created parallel workstreams that reduced the critical path. The lesson: in a multi-agent team, the limiting factor is almost never individual speed — it's the dependency graph.

### Best Practices

- **Define "done" for every feature before starting.** "Add enemy variety" is not a task. "Add Tough enemy type: 150% health, 120% damage, dark red (#8B0000) palette, same AI as normal but with 2× attack cooldown" is a task with a verifiable completion state.
- **Maintain a priority matrix, not a priority list.** Our P0 (ship-blocking), P1 (core experience), P2 (quality-of-life), P3 (nice-to-have) tiers let the team make independent decisions about what to work on next without constant re-prioritization meetings.
- **Track shipped vs planned.** Our codebase analysis found 13 AAA backlog items already shipped but still on the backlog. The backlog is a living document — prune it or it becomes fiction.
- **Time-box scope discussions.** "Should we add multiplayer?" is a 10-minute conversation, not a 2-hour design session. The answer is almost always "not this project" — capture the idea for future reference and move on.
- **Document architectural decisions with rationale.** Our decisions.md records not just *what* we decided but *why*. When a future developer asks "why didn't we use Phaser 3?", the answer is documented: prototyping speed, zero-dependency constraint, and the decision to capture it as a future-project learning.

### Common Mistakes

- **Scope creep disguised as polish.** "Let's add a new combo system" during polish phase is not polish — it's a new feature. Guard the feature freeze boundary ruthlessly.
- **Skipping the vertical slice.** Building all enemies before the first enemy feels good to fight. Building all levels before the first level is fun to traverse. Building all characters before the first character has satisfying controls. The slice proves viability; everything else is expansion.
- **Retrospectives without action items.** "The parallax was hard to get right" is an observation. "Next project: define parallax layer speeds in a config file, not hardcoded, and test at three scroll speeds before committing" is a learnable action. Observations without actions are venting sessions.
- **Ignoring the dependency graph.** Starting work on enemy AI patterns before the combat system handles damage correctly creates rework. Map dependencies explicitly (our todo_deps table) and sequence work accordingly.
- **Solo heroics instead of parallel streams.** One developer doing engine + gameplay + content + art sequentially takes 4× longer than four specialists working in parallel with clear interfaces. Our squad expansion from 4 to 9 agents was the single biggest production velocity improvement.

### firstPunch Application

firstPunch's production history is a case study in vertical slice methodology done right. The initial prototype (Brawler punching goons on a Downtown street) was playable in 30 minutes. Every subsequent milestone expanded from that working core: combat feel → enemy variety → VFX layer → audio layer → wave system → boss encounters. The squad structure evolved organically: started with 4 core roles, identified bottlenecks through gap analysis on a 52-item backlog, expanded to 9 roles with explicit domain ownership. Key production artifacts that work: decisions.md (architectural record), history.md per agent (institutional memory), the analysis folder (20+ research documents covering beat 'em up genre, balance, frame data, visual direction, audio, technical learnings, and regression testing). Key production gaps: no formal sprint/milestone structure, no burndown tracking, no definition-of-done checklists per feature, and the backlog drifted (13 items completed but not marked done). The "Phaser 3 & Future Tech" decision is exemplary scope management: recognizing that a technology improvement is valuable but out-of-scope for the current project, capturing it as institutional knowledge rather than attempting a mid-project migration.

### Future Learnings

- **Milestone gates** (prototype → vertical slice → alpha → beta → release candidate → ship) should be formally defined with entry/exit criteria. "Is the vertical slice done?" needs a checklist, not a feeling.
- **Automated backlog reconciliation**: a script that cross-references backlog items against codebase features would prevent the "13 shipped items still on backlog" drift.
- **Cross-project knowledge transfer**: this knowledge base document *is* the mechanism. Each new project should start by reading the previous project's knowledge base, not by reinventing production process from scratch.
- **Multi-agent workflow patterns**: the squad discovered that domain-owner parallelism with shared decision documents scales better than sequential handoffs. This pattern should be the default for all future projects, with the dependency graph as the coordination mechanism rather than status meetings.

---

## Cross-Discipline Synthesis

These five disciplines form a feedback loop: **Visual Design** creates the world players see, **UX/UI Design** ensures players can navigate and understand that world, **Technical Architecture** makes both possible at 60 FPS, **Quality Assurance** verifies everything works correctly, and **Production & Process** coordinates the humans (and agents) building it all. The common thread across all five is *intentionality*: every color choice, every HUD element, every architectural pattern, every test case, and every scope decision should trace back to a player experience goal. firstPunch's strongest lesson is that constraints (Canvas 2D, zero dependencies, procedural art, small team) don't limit quality — they focus it. The game feels good to play not despite its limitations but because every decision was made within known boundaries, leaving no room for half-measures.
