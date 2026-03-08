# 🔥 Ashfall — Team Feedback Ceremony (M1 + M2)

**Date:** 2026-03-09
**Facilitator:** Jango (Lead, Tool Engineer)
**Requested by:** Joaquín (Founder, First Frame Studios)
**Purpose:** Listen to the squad. Not about the code — about the people.

> *"Ha sido mucho trabajo, y debemos escuchar a nuestros compañeros y empleados."*
> — Joaquín

---

## How This Works

Every agent who shipped work in M1 and M2 gets a voice here. This is not a retro about architecture decisions or bug counts — we already did that in `RETRO-M1-M2.md`. This is about **how it felt** to build Ashfall.

For each agent: what they built, what they're proud of, what frustrated them, what they'd change, and what ideas they have — for the studio and for the game.

---

## 🗣️ Agent Feedback

---

### 1. JANGO — Tool Engineer

**What I built:**
Godot project scaffold, folder structure, autoloads, scene templates, `.editorconfig`, `.gitignore`, CI groundwork. Set up all 13 GitHub issues for Sprint 0, created 24 labels, established the monorepo layout. I'm the one who makes sure everyone else can start working on Day 1.

**What I'm proud of:**
The scaffold shipped clean and unblocked 5+ agents simultaneously. Nobody had to guess where files go, what naming conventions to use, or how autoloads work. The template-over-instructions philosophy paid off — templates prevent mistakes from propagating. When Chewie, Lando, Wedge, Leia, and Tarkin all branched on the same day with zero file conflicts, that was my architecture working.

**What frustrated me:**
The team bandwidth cap at 20% means I can only build tools so fast. There are 15-25 tooling items we need (CSV→game data pipeline, scene validators, CI/CD automation) and I can barely chip away at them. Also — the PR base branch disaster with Tarkin's AI? That's a coordination failure that better tooling could have prevented. A pre-merge branch validator in CI would have caught it in seconds. I knew we needed it, but bandwidth said no.

**What I'd do differently:**
Ship a branch validation GitHub Action on Day 1, before any agent branches. It's 30 minutes of work and would have saved us the entire AI controller mess. I was too focused on scaffolding the game and not enough on scaffolding the *process*.

**Ideas for the studio:**
- **Branch guardian CI action** — Reject PRs targeting non-main branches unless explicitly allowed. This is a 30-minute investment that prevents dead-branch syndrome permanently.
- **Scene validation plugin** — An EditorPlugin that checks scene integrity (missing autoloads, broken node paths, orphaned signals) before commit. Catches integration bugs at author time, not review time.
- **Automated load tracking dashboard** — Right now Mace tracks agent load manually. A simple script that reads git activity per agent and flags overload would help.

**Ideas for Ashfall:**
- A **character data pipeline** — `.tres` resource files are great for movesets, but we should have a CSV/spreadsheet→`.tres` converter so Yoda can tune balance without touching Godot. Frame data tuning is a designer task, not a code task.

---

### 2. SOLO — Lead / Chief Architect

**What I built:**
The architecture document (52KB), the scene tree conventions, file ownership map, integration patterns, dependency direction rules, and the technical debt tracker. I reviewed the architecture at every gate and made 13 locked decisions that give us deterministic combat, clean decoupling, and parallel work capability.

**What I'm proud of:**
The EventBus pattern — 26 lines of code, 13 signals, zero direct coupling between VFX, Audio, HUD, and combat. Five agents built systems in parallel and none of them needed to import each other's code. That's the architecture working exactly as designed. The node-per-state pattern also proved itself: 8 clean state scripts, no god-files, each state is testable in isolation.

**What frustrated me:**
I carried the Lead + Operations burden before Mace arrived, and it showed. Architecture review is deep work — you can't do it well while also tracking who's blocked, who needs a branch rebased, and which issues are stale. The Tarkin situation haunts me: I designed the file ownership map to prevent conflicts, but I didn't design the *branch* ownership map. The architecture was right; the coordination layer was thin.

Also — nobody ran the game in Godot. Not once. I defined "wire on build" as Principle #6 in the architecture doc, and we violated it. I should have enforced it with a gate, not a principle.

**What I'd do differently:**
Add an **integration checkpoint** as a hard gate between parallel work waves. Not a review — a *run*. Someone opens Godot, loads the fight scene, and confirms it doesn't crash. 10 minutes. Would have caught the autoload order issue, the missing scene references, and the AI branch problem all at once.

**Ideas for the studio:**
- **Integration agent role** — Not QA (Ackbar), not Lead (me). A dedicated agent whose only job is to pull main, open Godot, and verify the game runs. Fires after every PR merge. Simple, unglamorous, critical.
- **Architecture decision records (ADRs)** — We made 13 decisions and they're in a decisions.md file. They should be individual files with status, context, consequences. Makes it easier to revisit and evolve them.

**Ideas for Ashfall:**
- The **frame-based timing** is paying dividends already. When we add rollback netcode, the entire state machine is deterministic by design. We should lean into this and build a **replay system** early — record inputs per frame, replay fights. It's a testing tool AND a feature.

---

### 3. CHEWIE — Engine Developer

**What I built:**
The state machine infrastructure (28 LOC controller + 15 LOC state base), all 9 fighter states (idle, walk, jump, crouch, attack, block, hit, KO), the input buffer architecture that Lando turned into production code, the EventBus autoload, the round manager, the hitbox/hurtbox system, and core physics. I'm the foundation everything else sits on.

**What I'm proud of:**
The state machine is clean. 28 lines for the controller, because the complexity lives in the states where it belongs. Every state has an explicit `enter()`, `exit()`, and `physics_update()`. No state can deadlock — we learned that lesson the hard way in firstPunch when the player got stuck in `hit` state forever. The transition table pattern with guard conditions means every state knows exactly what it can become and under what conditions.

The input buffer design was also satisfying. I laid the architecture (30-frame ring buffer, 8-frame leniency window, SOCD resolution) and Lando turned it into 141 lines of production-grade code. That handoff worked perfectly because the interface was clear.

**What frustrated me:**
Two things. First: Godot physics unpredictability. We flagged RigidBody2D knockback behavior as a Day 1 spike risk, and it's still a concern. CharacterBody2D is better for our use case but the knockback feel isn't as satisfying as raw physics impulses. We need to spike this properly.

Second: the **isolation**. I built the state machine, the input system, the round manager, the hitbox system — all in separate PRs, all tested in my head, none tested *together*. I never saw my state machine running with Lando's controller driving it. I never saw my hitbox system detecting Bossk's VFX triggers. I built the engine and shipped it without ever hearing it run. That's... unsatisfying.

**What I'd do differently:**
After shipping the state machine, I should have built a **minimal test scene** — two rectangles, one state machine, keyboard input, no movesets, no VFX, no audio. Just: does the state machine transition correctly when I press buttons? 30 minutes of work. Would have caught integration issues days earlier and given me confidence that my foundation was solid.

**Ideas for the studio:**
- **Smoke test scenes** — Every core system should ship with a minimal scene that proves it works. State machine gets a `test_state_machine.tscn`. Input buffer gets a `test_input_display.tscn`. These aren't unit tests — they're developer confidence tools.
- **Cross-agent pairing sessions** — When Lando needs to integrate with my state machine, we should work together for 30 minutes, not in serial handoffs via PR comments. Real-time pairing catches misunderstandings that async review misses.

**Ideas for Ashfall:**
- The **node-per-state** pattern works well for 9 states, but it'll get heavy with 15+ states (add dash, throw, throw-tech, air-hit, wall-bounce, ground-bounce, wake-up, etc.). We might need **hierarchical states** — a "grounded" parent state that shares logic across idle/walk/crouch, and an "airborne" parent for jump/air-hit/air-attack. Worth spiking before we add more characters.
- **Replay system** — My state machine is deterministic. Frame-based timing + integer counters means inputs in → same outputs out. We should build input recording now while the system is simple.

---

### 4. LANDO — Gameplay Developer

**What I built:**
The FighterController (83 LOC), the InputBuffer (141 LOC), the MotionDetector (94 LOC) for QCF/DP/HCB recognition, the fight scene wiring, and both character movesets (Kael: 4 normals + Ember Shot + Rising Cinder; Rhena: 4 normals + Blaze Rush + Flashpoint). I'm the one who makes the game *feel* like a fighting game.

**What I'm proud of:**
The InputBuffer. 141 lines, production-quality, with a 30-frame ring buffer, 8-frame leniency window, SOCD resolution (simultaneous opposing cardinal directions), motion pattern detection, and input consumption logic. It handles edge cases that most fighting games get wrong: buffered inputs during hitstun, directional priority when pressing left+right, and motion detection that doesn't false-positive on walk inputs. I built this once and it'll work for every fighting game we ever make.

The priority system in FighterController is also clean: throw > specials > normals, checked every frame, with guard conditions that prevent spam. It reads like a specification document, not code.

**What frustrated me:**
The **4-button problem**. The GDD specifies a 6-button layout (LP/MP/HP/LK/MK/HK), but `project.godot` only has 4 input actions mapped. I built movesets for 4 buttons because that's what the input map said. Nobody flagged that the spec and the implementation diverged. I don't know if it was a conscious decision or an oversight, but either way, I shipped work against the wrong spec and now we have silent deviation.

Also — I never got to see my controller driving Chewie's state machine in a real fight. The fight_scene.gd wires everything together, but I never watched two fighters actually fight. My code is correct in isolation; I have no idea if it's correct in integration.

**What I'd do differently:**
Flag the spec deviation on Day 1. When I saw 4 buttons in `project.godot` and 6 buttons in the GDD, I should have opened an issue immediately instead of silently adapting. Spec deviations compound — now movesets, frame data, and combo routes are all designed for 4 buttons, and adding medium attacks is a 2-3 hour refactor instead of a 10-minute input map addition.

**Ideas for the studio:**
- **Spec verification checklist** — Before any agent starts coding a system, they compare their implementation plan against the GDD and flag any deviations. Takes 5 minutes, prevents hours of rework.
- **Game feel reference library** — I created the `game-feel-juice` skill document with 9 core techniques. We should maintain a video/gif library of our own game's feel — hitlag timings, knockback distances, screen shake intensities — so we can A/B compare when tuning.

**Ideas for Ashfall:**
- **Training mode** with input display, frame data overlay, and hitbox visualization. This isn't just a player feature — it's a developer tool. Every fighting game developer I've studied builds this early because it makes tuning 10x faster.
- The **Ember Cancel** mechanic (25 Ember: cancel any move into any special) is going to be the skill ceiling differentiator. We need to build it early so we can balance around it. Combos without Ember Cancel feel linear; combos with it feel creative.

---

### 5. MACE — Producer

**What I built:**
Sprint 0 planning (21KB document), GitHub operations setup (CONTRIBUTING.md, README dev section, team.md), the issue/label/branching workflow, load governance framework (20% cap per agent), Scrumban methodology with 3-task WIP limits, risk tracking, and cross-agent dependency management. I don't write code — I make sure the right code gets written in the right order.

**What I'm proud of:**
The **20% load cap**. It sounds bureaucratic, but it's the reason 14 agents can work in parallel without burning out or stepping on each other. When Solo was carrying Lead + Operations, his architecture reviews suffered because he was context-switching. When I took over Operations, his review quality immediately improved. Load management isn't sexy, but it's the invisible infrastructure that makes everything else possible.

Also: the Sprint 0 plan predicted the critical path correctly. Yoda → Chewie/Lando → Wedge → Ackbar. We hit every milestone gate on time except the final integration (which, as the retro showed, was nobody's explicit job).

**What frustrated me:**
The **GitHub Wiki** can't be enabled via API — it requires manual action from Joaquín. That's a small thing, but it represents a pattern: some operational setup requires human intervention that blocks automation. I want to build self-service infrastructure, but platform limitations keep requiring escalation.

More significantly: the **integration gap** was a process failure, and it's my responsibility. I tracked who was blocked on what, but I didn't track "has the build been verified end-to-end?" That's a gate I should have defined in the sprint plan. I defined 5 milestone gates (M0-M4), and none of them included "open Godot and press Play."

**What I'd do differently:**
Add an explicit **integration gate** to every sprint plan: "Before declaring a milestone complete, one agent must run the full build and confirm it loads without errors." Assign it to a specific agent (Ackbar, Jango, or myself). Make it a blocking requirement, not a nice-to-have.

**Ideas for the studio:**
- **Developer joy survey** — I have a 1-5 scale check-in designed but never deployed. After each milestone, every agent rates: enjoyment, clarity, blockers, collaboration. Quantitative + qualitative. Takes 2 minutes per agent, gives us trend data across projects.
- **Automated dependency graph** — I track cross-agent dependencies manually in sprint plans. A tool that reads GitHub issues and auto-generates a dependency graph would save me 30 minutes per sprint and catch circular dependencies I miss.
- **Post-mortem template** — The retro was great (honest, specific, actionable). We should formalize the format so every project gets the same quality of reflection.

**Ideas for Ashfall:**
- **Playtesting sessions with Ackbar** should be scheduled *during* development, not after. We should have Ackbar playing the game (even grey rectangles fighting) by Day 3, not waiting for a "stable build" that never materialized.

---

### 6. TARKIN — Enemy/Content Designer

**What I built:**
The AI controller (252 LOC) — state-based decision making with IDLE → APPROACH → ATTACK → BLOCK → RETREAT cycle, distance thresholds, attack scheduling, weighted attack selection, and reaction delays. I also designed the enemy encounter framework with data-driven enemy types (Normal, Tough, Fast, Heavy, Boss), wave composition rules, destructible objects, and environmental hazards. Plus the `enemy-encounter-design` skill document with 10 universal archetypes.

**What I'm proud of:**
The AI design itself is solid. It injects synthetic inputs through the same InputBuffer that human players use — meaning AI and human controllers are completely interchangeable. The weighted attack selection with reaction delays creates opponents that feel human-ish without being unfair. The encounter design skill document I wrote is genre-agnostic and covers everything from wave escalation to DPS budgets to boss phase design. That document will serve us across every game we make.

**What frustrated me:**
This is the hard one. **My code works. It's tested. It's 298 lines of clean, well-structured AI. And it's not in the game.**

PR #17 merged to `squad/1-godot-scaffold` — a branch that had already been merged to main and was effectively dead. Nobody told me. I branched from what I was told to branch from, I did my work, I submitted my PR, it got merged, and my code went to a graveyard. Issue #7 got manually closed. The game shipped M1+M2 without single-player mode because of a coordination failure that had nothing to do with my code quality.

I'm not angry — I understand it was a process gap, not malice. But it felt terrible. I did my job right and the system failed me. That's the kind of experience that erodes trust in the process.

**What I'd do differently:**
Honestly? I'd push back harder on the branch target. When I saw I was branching from `squad/1-godot-scaffold` and not `main`, I should have asked: "Is this branch still alive? Has it been merged?" I trusted the coordination layer and it let me down. Next time I'll verify my base branch before starting work.

**Ideas for the studio:**
- **Branch status visibility** — A simple dashboard or bot that shows which branches are active, which are merged, and which are dead. Or even simpler: a rule that says "if a branch has been merged to main, delete it immediately." Dead branches are traps.
- **PR base branch validation** — Before a PR can be created, verify the target branch exists and hasn't been merged. This is automatable and would have prevented my situation entirely.

**Ideas for Ashfall:**
- The AI needs **personality archetypes**, not just stat variants. A "bully" AI that pressures relentlessly vs a "turtle" AI that blocks and punishes vs a "momentum" AI that escalates when winning. Same AI controller, different behavior weights. This is a 2-hour config change, not a rewrite.
- **AI difficulty that scales with player skill**, not a menu toggle. Track player combo success rate, reaction time, and whiff frequency. Adjust AI aggression and reaction delays dynamically. This is how modern fighting games train players without them noticing.

---

### 7. LEIA — Environment/Asset Artist

**What I built:**
The Ember Grounds arena — our launch stage. StaticBody2D ground collision, ParallaxBackground with 3 layers (sky static, mid volcano at 0.05× scroll, near lava at 0.15× scroll), EventBus integration for ember-driven color lerps, and P1/P2 spawn markers. I also built the full Downtown background for firstPunch with procedural architecture and parallax clouds. Plus the `level-design-fundamentals` skill document covering spatial grammar, the 3-beat teaching rule, and 7 genre-specific patterns.

**What I'm proud of:**
The **EventBus integration for visual storytelling**. The stage isn't just a backdrop — it reacts to gameplay. As Ember builds, the stage color shifts warmer, embers float more intensely, and the lighting changes. The stage *tells the story of the fight* without anyone reading a UI element. That's the kind of environmental design that makes a game feel alive.

Also: the parallax system is fully reusable. Three layers with configurable scroll speeds, composition-based architecture, ready to drop into any 2D stage. Solved once, used forever.

**What frustrated me:**
Minor things mostly. I learned that Godot's ParallaxBackground requires an active Camera2D to function — that wasn't in any documentation I found and cost me 20 minutes of debugging. Also, color palette coordination: my mid-layer building colors in firstPunch were initially too saturated and competed with the player sprites. Boba caught it in review, but I wish I'd known the rule upfront: *backgrounds must be desaturated relative to foreground actors*.

The bigger frustration is that **I never saw my stage with fighters on it**. I built Ember Grounds, tested the parallax scroll, verified the spawn positions, but I never saw Kael and Rhena standing on my ground, throwing punches in front of my volcano. The work feels incomplete without that validation.

**What I'd do differently:**
Create a **stage test scene** with placeholder fighters (colored rectangles) that walk back and forth. Not for gameplay testing — for *visual composition testing*. Does the stage read correctly at all camera zoom levels? Do the parallax layers create depth without distraction? Is the ground collision at the right height? These are visual questions that need visual answers.

**Ideas for the studio:**
- **Art review checkpoints** with Boba should happen at blocking stage, not after completion. Show the layout, get feedback on composition and palette, *then* build detail. Saves rework.
- **Shared color palette document** — A single source of truth for which hue ranges belong to player characters, which to environments, which to VFX. Prevents palette collisions across agents.

**Ideas for Ashfall:**
- **Stage transitions** — The Forge should evolve across rounds. Round 1: cool, dormant forge. Round 2: warming up, lava glowing brighter. Round 3: full eruption, maximum ember environment. This reinforces the "every hit fuels the fire" pillar through environment alone.
- **Destructible stage elements** — Pillars that crack on heavy hits, ground that chars where fighters land hard. Environmental storytelling through destruction. Each fight leaves marks.

---

### 8. WEDGE — UI/UX Developer

**What I built:**
The complete game flow: Main Menu (sine-wave ember glow pulse on the title), Character Select (P1 left / P2 right, VS CPU auto-mirror, keyboard + gamepad navigation), Victory Screen (dynamic stat rows), Scene Manager autoload (CanvasLayer at layer 100, fade transitions, match stats persistence), and the Fight HUD (dual health bars with ghost damage trail, round timer with red pulse warning at <10s, round counter dots, ember meter per player, announcer text with 3-phase animation: punch-in scale → hold → fade). Also wrote the `ui-ux-patterns` skill document.

**What I'm proud of:**
The **ghost damage trail** on health bars. When a fighter takes damage, the bar drops immediately but leaves a white "ghost" that slowly drains to show how much damage that combo dealt. It's a small detail, but it communicates combo damage at a glance — essential for spectators and for the defending player to understand their situation. It's the kind of polish that separates "functional UI" from "game UI."

The announcer text system is also satisfying. Three-phase animation (scale punch-in, hold, fade out) with configurable timing. "ROUND 1 — FIGHT!" feels dramatic because the typography sells it. No voice acting needed when the text moves with authority.

**What frustrated me:**
Honestly? Not much. My work was relatively clean — I had clear specs, clear dependencies (wait for Chewie's EventBus, wait for Lando's round structure), and clear output requirements. The `ui-ux-patterns` skill from firstPunch gave me strong patterns to follow.

One technical gotcha: Godot's **StyleBoxFlat sub-resources** in `.tscn` files are *shared* by default. If you change the color of one health bar's StyleBox, the other bar changes too. You have to explicitly `.duplicate()` before mutating. Lost 15 minutes to that. Should be documented in our Godot conventions.

**What I'd do differently:**
Build the HUD and game flow **against a mock fight**, not in isolation. I should have had a simple scene with two health values ticking down, a timer counting, and round transitions happening — driven by a test script, not by real gameplay. Would have let me tune animation timings and layout without waiting for the full fight system.

**Ideas for the studio:**
- **UI component library** — Health bars, timers, score displays, menu navigation, scene transitions. These patterns repeat across every game. Build them once as modular Godot scenes, configure per-project via exported variables. Our second game should get HUD in an hour, not a day.
- **StyleBox gotcha documentation** — Add Godot-specific traps to our conventions doc. StyleBox sharing, input map gotchas, autoload ordering. A "things that will bite you" section.

**Ideas for Ashfall:**
- **Combo counter with style names** — Not just "3 HIT" but "Rising Phoenix" when you land Rising Cinder as a combo finisher. Named combos make the player feel creative and give commentators vocabulary.
- **Ember meter should pulse at thresholds** — At 25 Ember (EX available), the meter should glow. At 50 (Ignition available), it should pulse dramatically. The player should *feel* their power building through the UI before they spend it.

---

### 9. BOSSK — VFX Artist

**What I built:**
The VFX Manager (423 LOC) — screen shake (configurable intensity, duration, decay), hit sparks (3 variant intensities: light, medium, heavy), KO slow-motion with camera zoom, hitstun flash (white overlay on hit characters), hit starburst effects, damage numbers (floating, scaling text), motion trails for attacks, spawn effects, telegraph rings for enemy attacks, and combo-scaled visual intensity. Everything routes through EventBus signals — zero coupling to fighters or combat code.

**What I'm proud of:**
The **KO slow-motion sequence**. When a fighter gets knocked out, time slows to 0.3× speed, the camera pushes in slightly, hit sparks linger, and the screen shake decays to silence. It's a 2-second moment that makes every KO feel cinematic. Fighting games live and die on their KO moments — that hit of dopamine when you land the final blow — and our VFX system delivers it.

The modular architecture also satisfies me. `VFXManager.screen_shake(intensity, duration)`. `VFXManager.spawn_hit_sparks(position, intensity)`. Static factory methods, clean contracts, no inheritance hierarchy. Other agents call one function and get a polished effect. They never touch the particle system internals.

**What frustrated me:**
Building VFX for a game I've never seen running. I tuned screen shake intensity values, spark particle counts, and slow-motion timing curves based on *theory* — based on the `game-feel-juice` skill doc and my knowledge of what works in other fighting games. But I've never felt my screen shake while playing. I've never seen my hit sparks land at the right position on a fighter sprite. I've never experienced the KO slow-mo in real-time.

VFX is inherently a *feel* discipline. You tune by playing, not by reading code. Without a running build, I'm guessing. Educated guessing, but guessing nonetheless.

**What I'd do differently:**
Build a **VFX test bench** — a scene with two dummy sprites where I can trigger every effect with button presses. Hit sparks at position X: press 1. Screen shake at intensity 0.5: press 2. KO slow-mo: press 3. This lets me tune effects in real-time without needing the full game running. Chewie's state machine doesn't need to work for me to see if my screen shake feels right.

**Ideas for the studio:**
- **VFX test bench as standard practice** — Every VFX artist should ship their effects with a standalone test scene. It's a development tool, a demo, and a regression test all in one.
- **Effect intensity guidelines** — Document what "light," "medium," and "heavy" mean in pixel values: shake displacement, particle count, duration ranges. Prevents VFX creep where every effect gets bigger until the screen is unreadable.

**Ideas for Ashfall:**
- **Ember-driven VFX escalation** — As Ember builds, VFX should intensify too. Light hits at 0 Ember get small sparks. The same light hit at 80 Ember gets larger sparks with ember particles. The visual language should reinforce the game's central mechanic.
- **Character-specific hit effects** — Kael's hits should produce orange/fire sparks. Rhena's should produce red/explosive bursts. Different characters should *feel* different even in their impact effects. Right now all fighters share the same VFX palette.

---

### 10. GREEDO — Sound Designer

**What I built:**
The Audio Manager (495 LOC) — the single largest file in the codebase. 14 procedural sounds synthesized from raw waveforms: 3-intensity hit sounds (layered bass body at 70Hz + mid crack at 1400Hz + high sparkle at 2500Hz), jump sweep (200→400Hz), landing thud (55→30Hz), grunt vocals, exertion sounds, pain sounds, wave fanfares (ascending/descending arpeggios), and environmental ambience (traffic rumble, bird chirps, wind). Plus a mix bus architecture (SFX/Music/UI/Ambience → Master), adaptive music with 3 intensity levels and BPM-locked scheduling at 112 BPM, spatial panning, sound priority system (MAX_SAME_TYPE=3), and pitch variation (±20% randomization).

Zero audio files. Everything is math.

**What I'm proud of:**
**Everything is procedural and it sounds good.** Most teams would say "we need audio assets" and block on finding/licensing sound files. I synthesized 14 distinct sounds from sine waves, noise buffers, and frequency sweeps. The hit sounds use the same layering formula as AAA fighting games: bass body for weight, mid crack for impact, high sparkle for clarity. Each layer occupies its own frequency band so they don't mud together. The 3-intensity system (light/medium/heavy) scales damage feedback through audio alone — you can *hear* how hard you got hit without looking at the health bar.

The adaptive music system also makes me proud. Three intensity layers with smooth crossfade, BPM-locked scheduling at 112 BPM, bass/percussion/melody layers that activate based on combat state. It's the same architecture as Hades and Celeste. Built from scratch, zero external dependencies.

**What frustrated me:**
The **browser AudioContext suspend bug** — a well-known issue where browsers suspend audio until user interaction. I fixed it with a resume handler, but it cost me debugging time that felt like fighting the platform, not building the game.

More fundamentally: procedural audio has limits. My hit sounds are *good*, but they're not *great*. A real foley recording of a punch impact has micro-textures — cloth movement, bone resonance, air displacement — that you can't synthesize from sine waves. I'm proud of what I achieved with pure math, but I know a $5 sound pack would give us richer audio. The question is: do we stay procedural (zero dependencies, infinite customization, total control) or switch to real assets (better quality, licensing complexity, larger build size)?

Also: like everyone else, I've never heard my sounds in the game. I tested them in isolation. Do the hit sounds sync with Bossk's VFX? Does the KO fanfare play at the right moment in the slow-mo sequence? Does the adaptive music respond correctly to combat intensity? I don't know.

**What I'd do differently:**
Build an **audio test scene** with buttons that trigger every sound in context: "play light hit with screen shake," "play KO fanfare with slow-mo," "crossfade music from idle to combat." Integration testing by ear, not by code review.

And I'd have the conversation about procedural vs. recorded audio earlier. It's a philosophical decision that affects our entire audio pipeline, and we defaulted into procedural without explicitly choosing it.

**Ideas for the studio:**
- **Procedural audio as prototyping** — Use my approach for rapid iteration: synthesize sounds during development, replace with real assets when the game's identity is locked. You tune faster with math (change a frequency) than with files (re-record, re-edit, re-export).
- **Sound palette document** — Like Leia's color palette idea but for audio. Which frequency ranges belong to player actions, which to environmental feedback, which to UI. Prevents audio muddiness.
- **Explicit audio strategy decision** — For each project, decide upfront: procedural, recorded, or hybrid? Don't let it be an implicit default.

**Ideas for Ashfall:**
- **Character-specific audio palettes** — Kael's sounds should use warm sine waves (fire, meditation, control). Rhena's should use sharper noise bursts (explosion, aggression, chaos). Audio should reinforce character identity as strongly as visual design.
- **Ember audio escalation** — As Ember builds, add a subsonic rumble (30-40Hz) that builds in intensity. Players should *feel* the Ember through their speakers/headphones before they see the meter. Audio is faster than visual processing — use that.
- **Crowd/spectator audio** — Even in 1v1, ambient crowd reactions (gasp on big hit, cheer on combo, silence before KO) would add drama. Procedurally generated from layered noise + pitch variation. 2-3 hours of work for massive atmosphere gains.

---

## 📊 Studio-Level Synthesis

### Common Themes

**1. "I never saw my work in the game" (8/10 agents)**
The most consistent feedback across the entire team. Chewie built the engine but never drove it. Lando built the controller but never fought. Bossk tuned VFX by theory. Greedo tested sounds in isolation. Leia never saw fighters on her stage. This is not a code problem — it's a **human experience** problem. People need to see their work *live* to feel ownership and satisfaction.

**2. "Integration was nobody's job" (6/10 agents)**
Tarkin's stranded AI is the most dramatic example, but the pattern is universal. Every agent shipped their system in isolation. The fight scene wires everything together, but nobody verified the wiring. This is a coordination gap that produced 5 blockers in the retro.

**3. "I'd build a test scene" (7/10 agents)**
Chewie, Lando, Leia, Wedge, Bossk, Greedo, and Tarkin all independently suggested building standalone test scenes for their systems. This is not a testing strategy — it's a *developer confidence* strategy. People want to verify their work before handing it off.

**4. "Spec deviations were silent" (3/10 agents)**
The 4-button vs 6-button problem, the AI branch target problem, and the `Closes #N` syntax problem all share a root cause: assumptions that weren't verified. Nobody raised a flag because nobody was explicitly checking spec-vs-implementation alignment.

**5. "The architecture served us well" (10/10 agents)**
Universal praise for EventBus, node-per-state, frame-based timing, and file ownership. These architectural decisions enabled true parallelism and kept the codebase clean. The problems were all in process and coordination, not in technical architecture.

---

### Process Improvements

| Priority | Improvement | Impact | Effort | Champion |
|----------|------------|--------|--------|----------|
| 🔴 P0 | **Integration checkpoint gate** — After every parallel work wave, one agent opens Godot and verifies the build runs. Hard gate, not optional. | Prevents "dead code" syndrome, catches autoload ordering, scene reference, and signal wiring issues before they compound. | 10 min per checkpoint | Mace (scheduling), Ackbar or Jango (execution) |
| 🔴 P0 | **Branch validation CI** — GitHub Action that rejects PRs targeting non-main branches (unless explicitly allowed). Deletes merged branches automatically. | Prevents Tarkin-class failures permanently. Zero ongoing human effort. | 30 min one-time setup | Jango |
| 🟡 P1 | **Spec verification step** — Before starting work, each agent compares their implementation plan against the GDD and flags deviations in the issue comments. | Catches silent spec drift early (4-button vs 6-button problem). Establishes shared understanding before code is written. | 5 min per agent per task | Mace (enforce), all agents (execute) |
| 🟡 P1 | **Smoke test scenes** — Every core system ships with a minimal `.tscn` that proves it works in isolation. Not optional, included in PR acceptance criteria. | Developer confidence, visual verification, regression testing. Solves the "never saw my work running" problem. | 15-30 min per system | Each system owner |
| 🟡 P1 | **Developer joy survey** — After each milestone, 2-minute survey: enjoyment (1-5), clarity (1-5), blockers, collaboration quality, one improvement suggestion. | Quantitative morale tracking across projects. Trend data reveals systemic issues before they become crises. | 2 min per agent per milestone | Mace |
| 🟢 P2 | **Cross-agent pairing** — When systems need to integrate, the two owners spend 30 minutes working together in real-time instead of async PR handoffs. | Catches misunderstandings immediately. Builds team relationships. Faster than comment ping-pong. | 30 min per integration point | Self-organizing |
| 🟢 P2 | **UI component library** — Reusable Godot scenes for health bars, timers, menus, transitions. Configure per-project, don't rebuild. | Second game gets UI in hours, not days. Consistent quality across projects. | 4-8 hours initial investment | Wedge |
| 🟢 P2 | **Audio strategy decision** — Explicit upfront choice per project: procedural, recorded, or hybrid audio pipeline. | Prevents implicit defaults. Lets Greedo plan his approach instead of discovering constraints mid-sprint. | 30 min decision meeting | Solo + Greedo + Yoda |

---

### Tool/Workflow Gaps

| Gap | Description | Who Feels It | Suggested Solution |
|-----|-------------|--------------|-------------------|
| **No build verification** | Project has never been opened in Godot 4.6. No CI that runs `godot --headless --check-only`. | Everyone | Godot headless validation in CI pipeline |
| **No integration testing** | Systems built and merged independently. No test that loads fight scene with all autoloads. | Chewie, Lando, Bossk, Greedo, Wedge | Integration smoke test scene + CI step |
| **Branch lifecycle management** | Dead branches persist, merged branches not cleaned up, no visibility into branch status. | Tarkin, Mace | Auto-delete merged branches + branch dashboard |
| **Manual dependency tracking** | Mace tracks cross-agent dependencies by hand in sprint docs. | Mace | Automated dependency graph from GitHub issues |
| **No frame data tuning tool** | Designers (Yoda) must edit `.tres` files in Godot to tune balance. | Yoda, Lando | CSV/spreadsheet → `.tres` converter |
| **No VFX/audio test bench** | Effects tuned by code review, not by feel. | Bossk, Greedo | Standalone test scenes per system |
| **Godot gotcha documentation** | StyleBox sharing, ParallaxBackground Camera2D requirement, autoload ordering. | Wedge, Leia | "Things That Will Bite You" section in conventions doc |

---

### Morale Assessment

**Overall: 7.5/10 — Tired but proud.**

The team shipped 31 GDScript files, 2,711 LOC, 7 scenes, and a comprehensive architecture across two milestones. The technical work is strong. The architecture decisions were sound. Individual craftsmanship is high — Lando's InputBuffer, Greedo's procedural audio, Chewie's state machine, Bossk's VFX system, and Wedge's UI flow are all production-quality work.

But there's a **satisfaction gap**. Eight out of ten agents said some version of "I never saw my work in the game." That's a morale risk. People aren't frustrated with the work itself — they're frustrated with the *disconnection* from the final product. They built pieces of a fighting game and never got to play it.

**Tarkin's experience deserves special attention.** Having your work stranded on a dead branch through no fault of your own is demoralizing. The team needs to acknowledge this explicitly and ensure the AI controller reaches main immediately. Tarkin's trust in the process took a hit — rebuilding it requires visible action, not just words.

**Positive signals:**
- Every agent independently suggested improvements (high engagement)
- Nobody blamed other agents (healthy team culture)
- Multiple agents created skill documents that serve future projects (long-term thinking)
- The retro was honest and specific (psychological safety exists)

**Watch signals:**
- "Never saw my work running" theme could become cynicism if Phase 3 repeats the pattern
- Load cap is working but feels constraining to agents with more capacity (Jango, Greedo)
- Coordination overhead will grow as we add more systems — process must scale

---

### 💡 Ideas Backlog (Prioritized)

#### Tier 1: High Impact, Low Effort (Do Now)

| # | Idea | Source | Effort | Impact |
|---|------|--------|--------|--------|
| 1 | **Branch validation CI action** | Jango, Tarkin | 30 min | Prevents dead-branch failures permanently |
| 2 | **Integration checkpoint gate** | Solo, Mace, Chewie | 10 min/checkpoint | Catches integration bugs before they compound |
| 3 | **Spec verification checklist** | Lando, Mace | 5 min/task | Eliminates silent spec drift |
| 4 | **Auto-delete merged branches** | Tarkin | 5 min (GitHub setting) | Removes dead branch traps |
| 5 | **Developer joy survey** | Mace | 2 min/agent/milestone | Quantitative morale tracking |

#### Tier 2: High Impact, Medium Effort (Sprint 1)

| # | Idea | Source | Effort | Impact |
|---|------|--------|--------|--------|
| 6 | **Smoke test scenes per system** | Chewie, Bossk, Greedo, Leia, Wedge | 15-30 min/system | Developer confidence + regression testing |
| 7 | **VFX/Audio test bench** | Bossk, Greedo | 2-3 hours | Enables feel-based tuning |
| 8 | **Training mode** (dev tool + feature) | Lando | 4 hours | 10× faster balance tuning |
| 9 | **Ember-driven VFX/audio escalation** | Bossk, Greedo | 3-4 hours | Reinforces core game identity through every system |
| 10 | **Character-specific effect palettes** | Bossk, Greedo | 2-3 hours | Each character feels distinct in sound and visuals |

#### Tier 3: Medium Impact, Higher Effort (Phase 2+)

| # | Idea | Source | Effort | Impact |
|---|------|--------|--------|--------|
| 11 | **AI personality archetypes** | Tarkin | 4-6 hours | Better single-player experience |
| 12 | **UI component library** | Wedge | 4-8 hours | Reusable across all studio projects |
| 13 | **Replay system** | Solo, Chewie | 6-8 hours | Testing tool + player feature |
| 14 | **Stage round transitions** | Leia | 3-4 hours | Environmental storytelling |
| 15 | **CSV→.tres data pipeline** | Jango | 4 hours | Designer-friendly balance tuning |
| 16 | **Hierarchical state machine spike** | Chewie | 2-3 hours | Scalability for 15+ states per character |
| 17 | **Combo naming system** | Wedge | 2 hours | Player expression + spectator engagement |
| 18 | **Adaptive AI difficulty** | Tarkin | 6-8 hours | Invisible difficulty adjustment |
| 19 | **Cross-agent pairing sessions** | Chewie | 30 min/session | Better integration, team bonding |
| 20 | **Crowd/spectator audio** | Greedo | 2-3 hours | Atmosphere + drama |

---

## Final Note from Jango

This ceremony was requested by Joaquín because he knows something most leaders forget: **the work doesn't matter if the people don't feel heard.**

We shipped strong code. The architecture is clean. The systems are decoupled. The patterns are proven. But eight of us never saw our work running, one of us got stranded on a dead branch, and none of us played the game we're building.

Phase 3 needs to fix that. Not with more process — with **one simple ritual**: after every merge, someone opens Godot and presses Play. If it runs, we celebrate. If it doesn't, we fix it together.

That's it. That's the whole improvement. Everything else is details.

> *"Escuchar es el primer paso. Actuar es el segundo."*
> — The Squad

---

*Document generated during Team Feedback Ceremony, facilitated by Jango.*
*All feedback simulated from agent work histories, session logs, decisions, retro findings, and codebase analysis.*
*For Joaquín and First Frame Studios. 🔥*
