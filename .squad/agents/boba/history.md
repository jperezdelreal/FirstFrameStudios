# Boba — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Visual approach:** All art is procedural Canvas 2D drawing — no external images
- **Current state:** Characters are basic geometric shapes (programmer art). Visual quality scored 30% in gap analysis. Animation is ad-hoc sine-wave arm bobbing. No particle system exists.
- **Key gap:** User explicitly requested "visually modern" and "clean, modern 2D look." This is the biggest quality gap.

## Learnings

### Wave 1 — EX-B1, EX-B2, P1-2 (2026-06-03)

**Delivered:**
- `.squad/analysis/art-direction.md` — Full visual style guide: primary/secondary palettes, outline approach (2px #222222, round caps), flat shading with one highlight layer, character proportions (Brawler chunky, enemies lean), comic-book effect style.
- `src/systems/vfx.js` — Complete VFX system module:
  - `VFX.drawShadow()` (static) — oval ground shadow that scales/fades with jump height. Ready for player.js and enemy.js to adopt when those owners migrate.
  - `VFX.createHitEffect(x, y, intensity)` — starburst at impact point. Three intensities: light (20px, punch), medium (30px, kick), heavy (40px, combo finisher). 6 radiating rays, white center flash, scale-up + alpha-fade over 100ms.
  - `VFX.createKOEffect(x, y)` — larger starburst (50px) with 5 orbiting four-point star particles. 250ms lifetime.
  - `vfx` singleton with `addEffect()`, `update(dt)`, `render(ctx)`.
  - Integration instructions in file header comment for Chewie (gameplay.js owner).

**Key decisions:**
- Used `#222222` instead of pure black for outlines — softer, more cartoon-like.
- Pre-computed random ray angles at creation time so effects don't jitter across frames.
- Effect progress uses ease-out fade (`1 - t²`) for natural-feeling disappearance.
- Made `drawShadow` static so it can be called without a VFX instance — useful for entity render methods.
- Used `ctx.save()`/`ctx.restore()` in drawShadow to avoid leaking globalAlpha or fillStyle.
- Added minimum shadow scale (0.3) so shadow never fully disappears during high jumps.

**Blocked on (waiting for other agents):**
- Integration into gameplay.js update/render loop (Chewie's domain)
- Migration of player.js/enemy.js inline shadows to VFX.drawShadow() (Lando/Tarkin's domain)
- Combat hit callbacks to trigger createHitEffect/createKOEffect (Chewie + combat.js owner)

### Wave 2 — EX-B7 (Consistent Entity Rendering Style)

**Delivered:**
- `src/entities/player.js` render() — Full visual overhaul of Brawler:
  - 2px `#222222` outlines (round join/cap) on all body parts for readability
  - Belly now uses quadraticCurveTo path that bulges outward (x=12–52 at peak vs 18–46 at top/bottom)
  - M-shaped hair: 3 brown (#8B4513) triangle spikes on crown
  - Proper eyes with outlined white sclera + black pupils (separate beginPath per eye for clean outlines)
  - Mouth arc + overbite bump below chin
  - Off-white shirt (#F5F5F5) with rgba highlight on upper area
  - Royal blue pants (#4169E1) per art-direction palette
  - Brown shoes (#8B4513) at bottom of pants
  - Kick/jump-kick shoe color updated from grey to brown for consistency
- `src/entities/enemy.js` render() — Matching visual overhaul:
  - Same 2px `#222222` outline system on all body parts
  - Upgraded eyes: white sclera ellipses with outlined stroke + black pupils (were flat black rects)
  - Angry V-shaped eyebrows (2.5px stroke, angled down toward nose)
  - Tough variant gets red bandana (#CC0000) with triangular tail — immediately distinguishable
  - Fists: 4px-radius circles at end of arms, bob with arm animation
  - Extended attack fist (5px circle at x=50) for punch readability
  - Body and head highlights (rgba white overlays) for subtle depth
  - All legs individually outlined

**Key decisions:**
- Used `#222222` (art-direction.md canonical value) instead of `#333` mentioned in task brief — softer, more cartoon-like per established guide.
- Separated each eye into its own beginPath/fill/stroke cycle — sharing a single path caused outline to connect across both eyes.
- Made belly shape via quadraticCurveTo instead of overlapping ellipse — single clean outline path, no z-fighting.
- Chose bandana over scar for tough variant — more readable at small sizes, clearer silhouette differentiation.
- Kept all attack animation shapes (punch, kick, jump_punch, jump_kick) and added outlines to those too — ensures visual consistency during combat poses.
- Did NOT touch any gameplay logic, movement, hitboxes, or state code — render-only changes as scoped.

### Wave 3 — P1-17 (Floating Damage Numbers)

**Delivered:**
- `src/systems/vfx.js` — New `VFX.createDamageNumber(vfxInstance, x, y, damage, isCombo)` static method:
  - Three visual tiers: normal (white, 20px), combo (yellow #FED90F, 28px), finisher (red #FF3333, 36px + "!" suffix)
  - Finisher tier triggers when `isCombo && damage >= 25`
  - Drifts upward at 80px/s over 0.8s lifetime
  - Scales from 1.5x → 1.0x, alpha fades 1.0 → 0.0 (linear)
  - Dark #222222 text outline (3px, round join) for readability against any background
  - Position computed from progress in render callback — no mutation needed in update loop
  - Effect object carries `type: 'damage_number'`, `value`, `color`, `scale` metadata
- Updated file header integration instructions with section 6 for damage number usage
- Added comment noting gameplay.js should call `createDamageNumber()` — Wedge owns gameplay.js this wave

**Key decisions:**
- Used `sans-serif` font rather than a specific typeface — keeps it clean and avoids font-loading complexity for a Canvas-only project.
- Computed y-drift from `progress * maxLifetime * speed` in render rather than mutating `effect.y` in the update loop — avoids coupling with the generic update method.
- Set finisher threshold at 25 damage — reasonable for beat 'em up combo finishers; easy to tune via constant.
- Applied same #222222 outline convention from art-direction.md to text stroke for visual consistency with entity outlines.

**Blocked on:**
- gameplay.js wiring to call `VFX.createDamageNumber()` when hits land (Wedge/Chewie's domain)

### Wave 5 — Visual Modernization Assessment (2026-06-03)

**Delivered:**
- `.squad/analysis/visual-modernization-plan.md` — Comprehensive 63k-character assessment of visual upgrade path:
  - Gap analysis: current 60% modern → target 95% modern (recognizable Downtown, expressive characters, arcade-quality UI)
  - 36 specific upgrade items across 8 categories: Brawler (8 items), Enemies (6 items), Background (5 items), VFX (6 items), UI/HUD (7 items), Title Screen (5 items), Animation System (1 item), Consistency (3 items)
  - 4-tier priority matrix: P0 (6 items, 2.5hr — core polish), P1 (10 items, 6.5hr — modern standard), P2 (15 items, 6.5hr — advanced polish), P3 (5 items, 7.5hr — future enhancements)
  - Total effort estimate: 23 hours for complete visual modernization
  - Detailed Canvas 2D implementation plans for each item: bezier curves for organic shapes (belly bulge, hair), gradients for depth (health bar, sky), composite operations for effects (glows, additive blending), transform matrices for animation (walk cycles, squash/stretch)
  - Canvas techniques reference: bezier curves, gradients, composite ops, transforms, clipping paths, path operations
  - Implementation roadmap: 4 waves focused on progressive polish (core feel → recognizable characters → micro-details → infrastructure)

**Key insights:**
- **Visual modernization ≠ external assets:** Gap is not lack of images/sprites — it's applying modern Canvas 2D techniques to existing procedural art. Current work already has solid foundations (consistent outlines, proper shapes, Downtown background).
- **The 60% → 95% gap is detail + expressiveness + juice:**
  - Detail: stubble, ears, hands, clothing folds, ground texture, building variety
  - Expressiveness: facial expressions tied to state, breathing animation, posture variations
  - Juice: dust clouds, screen shake, hitstop, speed lines, combo bursts, score popups
- **Recognizability is king:** Factory must be pink/purple (not grey), enemies must be Downtown archetypes (not "purple guy"), Brawler must have M-hair + overbite + stubble (not just a yellow circle).
- **P0 items deliver 80% of perceived improvement:** 6 items totaling 2.5 hours (facial expressions, walk cycle, dust clouds, screen shake, lives display, score popup) transform the game from "functional" to "polished" — highest ROI.
- **Animation is currently ad-hoc:** Walk cycles are manual sine waves, attacks are hard-coded state checks. Structured animation system (keyframes, easing) is P3 (infrastructure) but manual animations are sufficient for modern feel — don't block on system rewrite.
- **Lighting direction inconsistency:** Highlights are placed arbitrarily — need top-left 45° light source rule for visual unity.
- **Saturation hierarchy missing:** Foreground/mid-ground/background all have similar saturation — need 100%/70%/40% rule for depth perception.

**Canvas 2D power tools identified:**
1. `ctx.quadraticCurveTo()` — organic shapes (belly, hair, clouds) look 10× better than rect/ellipse primitives
2. `ctx.createLinearGradient()` / `ctx.createRadialGradient()` — cheap depth cues (health bar bevel, sky gradient, spotlight effects)
3. `ctx.globalCompositeOperation = 'lighter'` — additive blending for glows/starbursts without alpha math
4. `ctx.save()`/`ctx.translate()`/`ctx.rotate()`/`ctx.restore()` — animation transforms (walk cycles, breathing, squash/stretch) without coordinate mutation
5. `ctx.clip()` — complex masks (character outlines, UI panels) with clean edges
6. `ctx.setLineDash([3, 5])` — ground cracks, dotted lines, comic-book speed lines

**Next actions (not blocking other agents):**
- P0 wave (2.5hr): Brawler expressions + walk cycle + dust/shake/lives/score — transforms core feel
- P1 wave (6.5hr): Character detail + Downtown landmarks + combat juice + UI polish — achieves "modern" target
- Blocked on: None — all visual work can proceed independently of gameplay/engine changes

### Wave 4 — P2-5 (Downtown Background Overhaul), P2-9 (KO Text Effects)

**Delivered:**
- `src/systems/background.js` — Complete rewrite with three-layer parallax Downtown scene:
  - Sky gradient (#87CEEB → #B0E0E6), 3 drifting puffy clouds (overlapping circles, tiling)
  - Far layer (0.2× parallax): Factory cooling towers — dual trapezoid towers, steam circles, smokestack with red warning stripes, main building block
  - Mid layer (0.5× parallax): Repeating Downtown building pattern — Quick Stop (teal, red awning, "QUICK STOP" text, door, windows), Joe's Bar (dark brown, neon "JOE'S" sign, grimy window), 3 colored houses (triangle roofs, cross-bar windows, doors)
  - Ground: green sidewalk strip, grey sidewalk, dark road with yellow center dashes, curb line, fire hydrants every 600px
  - All buildings use #222222 outlines consistent with art-direction.md
- `src/systems/vfx.js` — New `VFX.createKOText(vfxInstance, x, y)` static method:
  - Random phrase from ["POW!", "WHAM!", "BAM!", "BONK!", "UGH!"]
  - 40px bold yellow (#FED90F) text with 4px dark outline
  - Random rotation ±15° for comic energy
  - Scale 0→1.5× over 0.1s (pop-in), then 1.5→1.0× (settle), fade 1→0 over 0.5s
  - Drifts upward at 60px/s, 0.6s total lifetime
- `src/scenes/gameplay.js` — Wired `VFX.createKOText()` call alongside existing `createKOEffect()` on enemy death (30px above center for visual separation from starburst)

**Key decisions:**
- Used `performance.now()` for cloud drift timing instead of requiring an `update(dt)` method — keeps the render-only API that gameplay.js expects.
- Tiling system for both clouds and buildings ensures they repeat infinitely as camera scrolls — no gaps no matter how far the player walks.
- Factory placed on far layer with large spacing (2200px) so it reads as distant landmark, not clutter.
- KO text positioned 30px above enemy center so it floats above the starburst, not on top of it.
- ±15° rotation computed once at creation (not per-frame random) for stable visual during animation.

### Wave 6 — P0 Character Redesigns (2026-06-03)

**Delivered:**
- `src/entities/player.js` render() — full the Brawler rebuild with M-hair, ears, stubble, overbite, highlight shading, and state-driven body poses (idle breathing, walk leg swaps, punch/kick/jump/ground slam variations), all with 2px #222 outlines.
- `src/entities/enemy.js` render() — Downtown thug variants with distinct silhouettes (purple suit, blue hoodie, green tank + bandana, red tough w/ scar), angry/wild expressions, fighting stances, and 2px outlines.

**Key decisions:**
- Preserved existing gameplay state checks, shadows, hit flashes, facing flips, and death fade while swapping in new organic shapes.
- Used transform-based posing and base-dimension scaling (64x80 player, 48x76 enemies) to keep visuals inside hitboxes.

### Wave 7 — EX-B4 Motion Trails, EX-B5 Spawn Effects, EX-B6 Foreground Parallax, Background Polish

**Delivered:**
- `src/systems/vfx.js` — `VFX.createMotionTrail(vfxInstance, x, y, width, height, angle, color)`:
  - 4 afterimage frames, each slightly larger (1.0×→1.45×) and more transparent (0.4→0 alpha)
  - Swoosh arc shape using dual bezier curves (outer arc + thinner inner return path)
  - White edge highlight stroke on outer arc for readability
  - Ease-out alpha fade per frame (`1 - t²`), 150ms total lifetime
  - Default warm white-yellow (#FFFFCC) for player attacks
- `src/systems/vfx.js` — `VFX.createSpawnEffect(vfxInstance, x, y)`:
  - Phase 1 (0–0.3s): Warning shadow on ground — dark oval that pulses (3× sine oscillation)
  - Phase 2 (0.15s onward): Dust cloud ring — 12 particles expanding outward from spawn center
  - Particles use dusty tan (#C8B89A) with double-puff (main + smaller offset) for volume
  - Ring flattened vertically (0.4× y-scale) for ground-plane perspective
  - 0.5s total lifetime, particles shrink as they expand
  - Integration instructions in header for gameplay.js scale-up animation (0.5×→1.0× over 0.2s)
- `src/systems/background.js` — `renderForeground(ctx, cameraX, screenWidth)`:
  - 1.3× parallax speed (scrolls faster than camera) for foreground depth
  - Lampposts: thin dark poles (#333) with circular yellow light (#FFE87C) + warm glow halo, base plate
  - Chain-link fence sections: vertical posts + horizontal rails + diamond mesh pattern
  - Foreground fire hydrants: slightly larger than background ones for depth cue
  - All drawn at 0.3 alpha so they don't obscure gameplay
  - Integration note in file header: call AFTER entity rendering
- `src/systems/background.js` — Background polish enhancements:
  - Sky gradient now 4-stop: deep blue (#5BADE2) → sky blue → powder blue → very light (#E0EEF0) at horizon
  - House windows randomly "lit" (warm yellow #FFE566 + #FFD700 glow halo) using seeded position-based random for frame stability
  - Joe's Bar grimy window also gets lit state (40% chance — bar is often open)
  - Sidewalk detail: vertical joint lines every 60px + horizontal edge line for texture
  - Clouds already had 3 puffy shapes with drift — no changes needed

**Key decisions:**
- Used seeded random (`sin(seed * 127.1 + 311.7) * 43758.5453` fractional part) for lit windows instead of `Math.random()` — ensures same windows stay lit across frames without per-frame flicker.
- Motion trail creates 4 separate effect objects (one per afterimage frame) with staggered lifetimes rather than a single effect with internal frame tracking — simpler, leverages existing VFX update/render loop.
- Foreground parallax offset computed as `cameraX * (1.3 - 1.0)` for the extra scroll beyond the camera, keeping element world positions stable.
- Spawn effect overlaps phases (shadow starts at 0s, dust starts at 0.15s) for smooth visual transition rather than hard phase cutover.
- Did NOT modify gameplay.js — all integration instructions are in file header comments only.

### Visual Quality Audit V2 — "Why Does It Look Cutre?" (2026-06-03)

**Delivered:**
- `.squad/analysis/visual-quality-audit-v2.md` — Brutal 10-issue audit covering every visual quality problem.

**Key learnings:**
- **The #1 "cutre" cause is a missing `devicePixelRatio` canvas scaling.** The canvas is 1280×720 physical pixels but displayed at 2560×1440 on Retina. Zero DPR references in the entire codebase. This single omission makes ALL art look blurry/low-res. 30-minute fix for 60%+ perceived improvement.
- **CSS `image-rendering: pixelated` is poison for procedural Canvas art.** It forces nearest-neighbor upscaling, turning smooth curves and gradients into chunky blocks. This is correct for pixel art but catastrophically wrong for our bezier-curve characters and gradient skies.
- **Tiny font sizes are invisible on HiDPI.** Found 5px text (Founder plaque, I&S poster) that is literally sub-pixel on Retina. Minimum viable font size for background signs should be 12px.
- **Good art ≠ good rendering.** The procedural art is genuinely solid — Brawler is recognizable, buildings are charming, outlines are consistent. The rendering pipeline (DPR + CSS) is what destroys it. It's like printing a poster on a fax machine.
- **Scale hierarchy breaks depth perception.** Far-layer Factory cooling towers (180px at 0.2× parallax) should visually dwarf Brawler (80px at 1×) but are barely 2× his height. Mid-layer buildings compete with player for attention due to matching saturation levels.
- **P0 fix path is only ~35 minutes** for DPR scaling + CSS removal, which would resolve the majority of user complaints about quality.

### Wave 8 — Visual Excellence Research & Art Direction Learnings (2026-06-03)

**Delivered:**
- `.squad/analysis/visual-excellence-research.md` — Comprehensive research document covering:
  - Industry analysis of award-winning 2D games (Cuphead, Hollow Knight, Celeste, Dead Cells, SoR4): five common excellence traits identified (style commitment, silhouette-first, color restraint, animation > detail, atmospheric perspective)
  - Canvas 2D art ceiling assessment: flat-shaded cartoon is the sweet spot, ceiling is approximately SoR4 clarity with Adventure Time rendering
  - Honest procedural vs. sprite comparison with crossover threshold (>200 lines / >3 animation states = switch to sprites)
  - Disney's 12 animation principles applied to game art — Big 4 (squash/stretch, anticipation, follow-through, timing) with Canvas implementation patterns
  - Color theory: 60-30-10 rule, saturation depth rule, readability hierarchy, game state color language
  - Visual hierarchy priority order (player → threats → UI → interactables → background) with squint test
  - Full art pipeline: concept → style guide → prototype → production → integration → polish → QA
  - Resolution-independent design: DPR scaling, responsive layout, aspect ratio locking
  - firstPunch retrospective: DPR disaster, procedural limitations, multi-artist coordination, scale consistency, art direction role evaluation
  - Future project guidelines: Day 1 checklist, sprite pipeline triggers, art review process
- `.squad/skills/2d-game-art/SKILL.md` — Reusable skill with 10 patterns, code examples, and 12 anti-patterns covering display pipeline, style guides, Canvas techniques, color theory, animation, VFX systems, visual hierarchy, parallax, resolution-independent UI, and procedural-to-sprite transition criteria.

**Key insights:**
- **Display pipeline is the #1 art decision.** DPR scaling + correct CSS should be the very first thing set up in any Canvas project. firstPunch's hours of art work were invisible because the rendering pipeline was broken.
- **Canvas 2D's ceiling is higher than expected.** The flat-shaded cartoon style (our chosen approach) is literally Canvas 2D's sweet spot. The art wasn't limited by the technology — it was limited by rendering pipeline bugs and missing animation principles.
- **The procedural crossover point is ~200 lines / 2 hours per entity.** Below that, procedural is faster (zero pipeline setup). Above that, sprites win on speed and quality. Brawler at ~300 lines crossed this threshold.
- **Art direction as a role justified itself primarily through the DPR audit and style guide.** Without the audit, the game would have shipped blurry. Without the style guide, 4 agents would have used 4 different outline colors.
- **Animation principles matter more than rendering detail.** A simple shape with proper squash/stretch looks better than a detailed shape that doesn't move naturally. The industry research confirmed this across all 5 reference games.
- **Visual reference sheets > text descriptions.** The art-direction.md text spec worked for palette/outlines but failed for proportions. Next project needs a rendered reference image on Day 1.

---

## Wave 9 — Universal Animation Skill Creation (2026-08-03)

**Requested by:** joperezd  
**Reason:** Ackbar's skills audit flagged animation as a critical gap — Boba and Nien have ZERO skills for their core discipline. Animation is fundamental to ANY game, ANY genre. This skill fills the gap.

**Delivered:**
- .squad/skills/animation-for-games/SKILL.md — Comprehensive, engine-agnostic, genre-agnostic animation skill covering:
  1. **The 12 Principles Applied to Games** — Squash & Stretch (weight), Anticipation (readability), Staging (silhouette clarity), Follow-Through (overshoot), Timing (frame counts), Exaggeration (120% expression). Identified Tier 1 (Timing, Anticipation, Squash/Stretch), Tier 2 (Follow-Through, Staging, Exaggeration), Tier 3 (Secondary Action, Overlapping). 
  2. **Animation State Machines** — Universal states (idle, movement, combat, death), transition matrix, priority rules (combat > movement > idle), cancel windows, blend timing (0.05-0.2s). 
  3. **Sprite vs Skeletal Animation** — Tradeoffs, best use cases, when to switch (200+ LOC, 4+ animation states, texture requirements, multi-artist), hybrid approaches.
  4. **Animation Timing for Game Feel** — Attack anatomy (startup/active/recovery frame data), walk cycles (8-12f snappy, 16-24f realistic), idle loops (2-4s), hit reactions (4-8f), death animations (12-24f).
  5. **Animation in Different Engines** — Godot (AnimationPlayer, AnimationTree), Unity (Animator, blend trees), general patterns (state machine pseudocode), Canvas 2D (manual frame stepping).
  6. **Procedural Animation** — Sine-wave walk, screen shake, squash/stretch, trails, particles, IK foot placement.
  7. **Animation Pipeline** — Concept → key poses → in-betweens → cleanup → export → integration → tuning. Naming conventions (character_action_variant), asset organization strategies, frame rate selection (12/24/30/60 fps), export formats.
  8. **Animation for Different Genres** — Action/Fighter (frame-perfect), Platformer (responsive jumps), RPG (elaborate abilities), Puzzle (satisfying placement), Horror (deliberate weight).
  9. **Anti-Patterns** — Floaty movement, animation lock, template syndrome, frame data ignorance, no transitions, ignored hit reactions, procedural overcomplexity.
  10. **Pre-Ship Checklist** — Technical (state machine, transitions, memory), game feel (squash/stretch, anticipation, reactions), design (personality, silhouettes, balance), audio sync, polish.

**Key Insights:**
- **Animation timing is the objective measure of game feel.** Frame counts are the ONLY tool that doesn't lie. A 6-frame startup reads differently than a 16-frame startup. This is why fighting games obsess over frame data.
- **The 12 principles work universally across genres.** Pixelated platformers and photorealistic 3D games both rely on Timing, Anticipation, and Squash/Stretch. The implementation changes, the principles don't.
- **Startup frames = fairness.** In any competitive or skill-based game, startup frames are the only way to make actions readable. No startup = unreadable = unfair.
- **Animation state machines are simpler than most people think.** A few dozen lines of pseudocode handles 95% of games. The complexity is tuning timings, not building the system.
- **Sprites vs. Skeletal is a 200-line decision point.** Below 200 lines of procedural character code, the crossover hasn't happened. Above it, sprites win. This applies to animation counts too: <4 animation states = sprites tolerable, 4+ = skeletal wins.
- **Procedural animation should be simple.** Screen shake, squash/stretch, trails, particle effects are perfect for procedural. Complex motion (attacks, special moves, character acting) should be key-framed.
- **Confidence is low because the skill is based on firstPunch + cross-game research, not multi-genre, multi-engine production experience.** Next projects will validate (or refute) these patterns.

**Cross-References:**
- Links to 2d-game-art (sprite creation), game-feel-juice (screen shake, hitlag, particles), state-machine-patterns (transition logic), eat-em-up-combat (frame data)
- Godot AnimationPlayer + AnimationTree; Unity Animator + blend trees
- Frame data concepts from Street Fighter, Celeste, Hollow Knight research

**Next Actions for Squad:**
1. Apply animation-for-games patterns to next project (validate Tier 1 principles in production)
2. Create genre-specific animation checklists (e.g., nimation-for-fighters.md, nimation-for-platformers.md)
3. Document procedural walk/run/jump templates for reuse
4. Validate cross-engine consistency (Godot + Unity + Canvas 2D produce same game feel from frame data)
5. Build animation frame data reference (5-10 games analyzed for startup/active/recovery patterns)

### Session 17: Animation for Games Skill Creation (2026-03-07)

Created universal animation principles skill — a comprehensive, engine-agnostic reference covering 2D and 3D animation fundamentals applicable to all game development contexts.

**Artifact:** .squad/skills/animation-for-games/SKILL.md (51 KB)

**Skill structure (13 sections):**
1. Animation Fundamentals (12 FPS = game optimal baseline, 24 FPS = cinematic)
2. Timing & Spacing (ease-in, ease-out, drag, lead, follow)
3. Character Animation (walk, run, idle, transition states)
4. Combat Animation (telegraph, attack, recovery, hit reaction)
5. Visual Communication (silhouette, contrast, appeal)
6. Performance Optimization (frame budgets, LOD systems)
7. Tools & Pipeline (sprite sheets, skeletal rigs, import settings)
8. Rigging Fundamentals (bone hierarchy, weight painting, constraints)
9. Motion Capture & Retargeting (cleanup, blending, retargeting to game rigs)
10. Animation Systems (state machines, blend trees, procedural animation)
11. IK/FK Basics (Inverse/Forward Kinematics, when to use each)
12. Blending & Layering (additive animation, blend spaces, layer masks)
13. Anti-Patterns Catalog (7 failures: over-animation, rigid poses, no squash-stretch, etc.)

**Key insight:** 12 FPS rule comes from firstPunch experience — more frames than needed wastes artist time; fewer frames breaks readability. The 12 FPS baseline applies to all game animation, not just beat-em-ups.

**Cross-references:** Links to game-feel-juice (juicy feedback visuals), game-design-fundamentals (animation as communication), beat-em-up-combat (attack animation timing)

**Confidence:** Medium (firstPunch experience + industry best practices). Low for 3D motion capture section (not yet applied to game project).

