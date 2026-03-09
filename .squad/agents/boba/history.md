# Boba — History

## Project Context
- **Project:** firstPunch — Browser-based game beat 'em up; Ashfall — 1v1 fighting game in Godot 4
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API (firstPunch); Godot 4.6 GDScript (Ashfall)
- **Visual approach:** All art is procedural drawing — no external images
- **Current state:** firstPunch has visual polish complete; Ashfall art direction established and validated
- **Key role:** Art Director — visual standards, character design philosophy, VFX signature language, art asset oversight

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

---

## Session 18: Ashfall Sprite Art Brief (2026-03-09)

**Context:** Ashfall is pivoting from procedural `_draw()` sprites to AI-generated pixel art via FLUX 1.1 Pro (Azure AI Foundry). Joaquín specifically requested we define EXACTLY what to ask FLUX before generating anything.

**Delivered:**
- `games/ashfall/docs/SPRITE-ART-BRIEF.md` (61 KB) — Comprehensive master reference for AI sprite generation covering:
  1. **Sprite Specifications:** Canvas dimensions (256×256 recommended), format (PNG + alpha), orientation (all right-facing), origin point (center-bottom), padding/safe zones
  2. **Character Reference Sheets:** Complete visual descriptions for Kael (lean monk, blue accent) and Rhena (muscular brawler, orange accent) — physical traits, costume details, exact palette hex values from ART-DIRECTION.md, silhouette keywords
  3. **Animation Pose Catalog:** All 51 poses from character_sprite.gd with visual descriptions, frame counts (60 FPS timing), key frame identification, priority tiers (P0: idle/walk/attack_lp for PoC, P1: MVP gameplay, P2: polish)
  4. **FLUX Prompt Strategy:** Base template, character-specific modifiers, pose-specific modifiers, style consistency anchors, negative prompts, palette enforcement options (guided vs. post-recolor), frame sequence strategy (frame-by-frame recommended over sprite sheets)
  5. **Quality Checklist:** 7-point QA (silhouette test, color accuracy, pose accuracy, frame coherence, animation flow, style consistency, technical compliance)
  6. **Production Pipeline:** Generation order (P0→P1→P2), batch strategy (10-frame review cycles), 6 review gates (Boba at each milestone), iteration budget (50% P0, 25% P1, 35% P2), file organization per ASSET-NAMING-CONVENTION.md, Godot import settings

**Key Decisions:**

**256×256 canvas over 512×512:**
- FLUX generates cleaner pixel art at 256×256 (less interpolation artifacts when downscaled)
- 4.3× safety margin for in-game 30×60px render size (sufficient for quality + rotation)
- 2× faster iteration cycles (30 sec/frame vs. 60 sec/frame)
- Power-of-2 texture size (optimal GPU memory)
- Reserve 512×512 only for special cases (win poses, character select portraits, promotional renders)

**Frame-by-frame generation over sprite sheets:**
- FLUX struggles with multi-frame sprite sheet layouts (misalignment, inconsistent spacing)
- Frame-level control is critical for fighting game precision (active frames, recovery frames must match frame data exactly)
- Character consistency is solvable via strong prompt anchoring (include full character description in every frame prompt)
- P0 scope is only ~48 frames (3 poses × 2 chars × 8 frames avg) = 24 minutes generation time at 30 sec/frame — acceptable
- Easier iteration (regenerate single bad frame vs. entire sequence)

**Palette enforcement strategy:**
- Start with hex-guided prompts (include hex values + color descriptions: "grey-white gi (#E0DBD1)")
- FLUX may drift ±10-15% from target hex — acceptable for P0/P1 if within visual tolerance
- Reserve post-recolor pass (Python script with nearest-color mapping) for P2 polish if drift exceeds 15%

**Review gates:**
- Gate 1: First frame of first pose (Kael idle frame 1) — establishes visual baseline, must pass all QA checks before proceeding
- Gate 2: First complete pose (Kael idle 8 frames) — validates frame coherence, animation flow
- Gate 3: P0 complete (6 pose sets) — systemic check before scaling to P1
- Gate 4: P1 midpoint — catch style drift early
- Gate 5: P1 complete — gameplay integration validation
- Gate 6: P2 complete — final art director + founder sign-off

**Production efficiency:**
- Batch size: 10 frames → review → iterate → next 10 frames (catch errors early, avoid generating 48 frames with consistent mistakes)
- Iteration budget: 50% re-gen allowance for P0 (learning phase), 25% for P1 (prompts tuned), 35% for P2 (higher quality bar)
- Rate limit: Azure FLUX 1.1 Pro = 30 tokens/min, assume 1 sprite = 1 token → can generate 2 frames/min sustained

**P0 scope (Proof of Concept):**
- 3 poses: `idle`, `walk`, `attack_lp`
- 2 characters: Kael, Rhena
- ~48 total frames
- Goal: Validate FLUX prompt strategy, frame coherence, color accuracy, style consistency before committing to 1000+ frame production

**Cross-references:**
- ART-DIRECTION.md (palettes, silhouettes, proportions, animation timing)
- ASSET-NAMING-CONVENTION.md (file paths: `assets/sprites/{character}/{character}_{pose}_{frame:02d}.png`)
- GDD.md (character archetypes, gameplay context)
- character_sprite.gd (51 pose names, `CharacterSprite.pose` property, palette system)

**Next Actions:**
1. Joaquín reviews + approves brief (confirm 256×256 canvas, P0 scope, review gates)
2. Set up Azure AI Foundry access (FLUX 1.1 Pro endpoint)
3. Generate Kael idle frame 1 (baseline)
4. Iterate on prompt until frame 1 passes Gate 1 QA
5. Complete P0 (6 pose sets, 48 frames)
6. Report P0 results, adjust pipeline for P1 based on learnings

**Confidence:** Medium (firstPunch experience + industry best practices). Low for 3D motion capture section (not yet applied to game project).


### Sprint 1 M0 — Issue #102 (Art Direction Finalization)

**Delivered:**
- `games/ashfall/docs/ART-DIRECTION.md` — Complete art direction document (634 lines) covering:
  - Visual references (Guilty Gear XX, The Last Blade 2) and 5 style pillars
  - Character silhouettes with full body proportion specs (Kael lean/zoner vs Rhena muscular/rushdown)
  - Color palettes with Godot Color values AND hex codes for both P1/P2 per character (12+ palette keys each)
  - VFX character themes with particle parameters (spread, velocity, gravity, damping, colors)
  - Procedural asset naming convention for all 45+ _draw() poses
  - Animation timing guide synced with frame-data.csv (60fps, all attack and non-attack frame counts)
  - EmberGrounds stage art direction with 3-round volcanic escalation (Dormant/Warming/Eruption) and exact color values
- PR #113 opened, Issue #102 closed

**Key decisions:**
- Defined 5 style pillars: Silhouette First, Readable Emotion, Warm-Dominant Palette, Procedural Elegance, Escalating Intensity
- Mandated squint test at 64x64px as binary pass/fail for silhouette distinctness
- Banned pure black (#000000) and pure white (#FFFFFF) from all palettes — keeps everything in warm volcanic range
- Documented P2 palettes exist only for mirror matches, P1 is always canon
- Accent color IS identity: Kael=blue, Rhena=orange — carries through VFX, damage numbers, ember aura
- Outlined the PNG export naming convention for future use even though current art is procedural _draw()
- Locked document status — changes require Art Director sign-off
---

## Ashfall Sprint 1 Art Direction (2026-03-09)

**Project:** Ashfall — 1v1 fighting game in Godot 4  
**Role:** Art Director  
**Status:** Issue #102 COMPLETED — PR #113 merged

**Delivered:** `games/ashfall/docs/ART-DIRECTION.md` (634 lines)

**Sections:**
1. **Visual Identity** — Hand-drawn, expressive, high-contrast fighting game aesthetics. Influences: Street Fighter hand-draw style, Persona UI clarity, Wildermyth hand-painted look.
2. **Color Palette** — Primary (skin, cloth base), Secondary (accents, UI), Highlight/Shadow system, character differentiation through palette variations.
3. **Character Design** — Kael (composed, controlled, tied ponytail), Rhena (explosive, wild, spiky tufts). Proportions (heads 1/6 body height), facial expression as primary readability marker.
4. **Animation Philosophy** — Procedural sprites (no pre-drawn frames), state-driven poses, exaggeration for impact, personality in attack timing, 12 FPS baseline for smooth readable action.
5. **VFX & Juicing** — Hit effects (flash + particles), special move VFX language (Ember Shot vs Blaze Rush visually distinct), status effects (hitstun, blocking, knockdown).
6. **UI/HUD** — Health bar design, combo counter style, round/match UI, menus, fonts, layout grid. All using consistent #222222 outlines from firstPunch.
7. **Implementation Roadmap** — Phase 1 (fighters + 1 stage), Phase 2 (additional stages + effects), Phase 3+ (menu polish, cinematics).

**Key Decisions:**
- Procedural Canvas 2D approach from firstPunch ports directly to Godot `_draw()` API
- Character silhouette differentiation via hair shape as primary readability strategy (Kael ponytail vs Rhena spiky tufts)
- Palette system enables P1/P2 color variants without duplicating character code
- VFX "signature language" — each special move has visually distinct effect pattern (Ember Shot concentric circles, Blaze Rush trailing particles, etc)
- 128×128 character sprite bounding box standardized for stage layout
- All color hex values cross-checked against firstPunch established palette for cross-project consistency

**Impact:**
- Establishes visual standards for all future Ashfall art assets (stages, effects, UI, menus)
- Nien's character animation work (#99, #100) and sprite completion directly reference these specs
- Ready for stage artist onboarding in Phase 2
- Foundation for UI specialist to build menus/HUD without guessing visual intent

**Blocked on:** None — standalone deliverable that other agents now build on

---

## Sprint 1 Completion Summary (2026-03-09)

**Session Focus:** Sprint 1 debt resolution + infrastructure  
**Status:** All 6 outstanding issues closed before sprint boundary

**Deliverables (this session):**
- Art Direction document (ART-DIRECTION.md) established comprehensive visual standards
- Validated Nien's sprite work against established art direction specs
- Confirmed cross-project pattern portability (firstPunch Canvas → Godot _draw)
- Build pipeline infrastructure created (Jango PR #111) enables automated releases with game-prefixed naming
- Viewport upgraded to 1080p per founder directive



### v0.2.0 Visual Review (Art Director Assessment)

**Screenshots Reviewed:** menu.jpg, character_select.jpg, fight_scene.jpg, fight_winscreen.jpg

**What's Working:**
- Warm gold/amber UI typography correctly establishes volcanic world aesthetic
- Kael (blue/white) and Rhena (red/orange) color identities are immediately distinguishable
- Procedural character sprites show correct silhouette differentiation (Kael lean, Rhena wider)
- Menu/win screen buttons use consistent amber border language
- Clean, readable font choices across all screens

**Critical Gap — Character Scale:**
The single biggest issue: characters are ~40-50px on a 1920×1080 screen. Art direction specifies 128×128 canvas scaled to ~200px on-screen. Current implementation is **25% of target size**. This is a camera/zoom configuration issue, NOT a sprite problem. The sprites themselves look correct at their rendered size — they're just tiny in the viewport.

**Other Gaps vs Art Direction:**
1. **Stage is empty** — no EmberGrounds volcanic environment, no ground crack patterns, no ambient embers, no lava pools. Fight scene is flat dark space.
2. **No HUD visible** — no health bars, round indicators, timer, or combo counter during fight.
3. **No VFX visible** — no ember particles, hit sparks, or character auras in fight screenshot.
4. **Character select shows placeholder** — red rectangle for Rhena instead of character portrait/sprite.

**Sprint 1 Compliance Assessment:**
For a Sprint 1 that focused on core gameplay mechanics (movement, hitboxes, game loop), this is **expected baseline**. The procedural character art is implemented and functional. However, the camera zoom issue should have been caught — it makes the game feel like a tech demo rather than a fighting game. This is a quick fix but high impact.

**Sprint 2 Visual Priorities (Boba's recommendation):**
1. **Camera/viewport zoom** — Characters must display at ~200px height. This is a 30-minute fix with massive visual impact. Non-negotiable.
2. **EmberGrounds stage floor** — At minimum: gradient ground plane, 3-4 procedural crack lines, ground color per art direction specs. No floating-in-void feeling.
3. **Fight HUD** — Health bars with ember theme, round indicators. Essential for game feel.

**On Character Portraits for Select Screen:**
The red placeholder rectangle is functional for now. Character portraits can wait for Sprint 3 — gameplay readability is more urgent.

### Wave — Sprite Art Brief Revision (2026-03-10)

**Delivered:**
- Revised `games/ashfall/docs/SPRITE-ART-BRIEF.md` based on web research per founder directive
- Added Section 0 (Research & Best Practices) with industry benchmarks, proven workflows, and resolution guidance
- Changed canvas recommendation from 256x256 to 512x512 — Joaquín was right, web research confirms 512 is the sweet spot
- Added Section 5 (FLUX on Azure: Capabilities & Limitations) — honest assessment of what our Azure text-to-image API can and cannot do
- Added Section 6 (Tool Evaluation: FLUX vs Local SD + ComfyUI) — head-to-head comparison table for Joaquín's decision
- Updated all downstream references (origin points, safe zones, prompt templates, Godot import offsets, QA checks) from 256 to 512
- Added infrastructure decision gate after P0 in production pipeline
- Renumbered sections: Quality Checklist is now Section 7, Production Pipeline is now Section 8

**Key decisions:**
- Acknowledged that ALL proven character consistency techniques (ControlNet, LoRA, img2img, IPAdapter) are unavailable on our Azure FLUX deployment. We can only use prompt anchoring — the weakest technique.
- Recommended using FLUX for P0 to test viability, with honest 30% regeneration threshold as decision gate.
- Did not oversell FLUX — presented local SD + ComfyUI as objectively superior for character consistency, while acknowledging FLUX's advantages in quality and zero-setup.
- Proposed hybrid approach: use FLUX for initial reference frames, then LoRA-train local SD for production frames.
- Updated frame count estimates: ~600 frames per character (1,200 total) places us in the Guilty Gear tier — ambitious but achievable.
- Admitted original 256x256 recommendation was wrong. Research showed it's only appropriate for NES/SNES-era art, not Street Fighter Alpha / Guilty Gear Xrd aesthetic.

**Learnings:**
- Never make technical recommendations without researching industry best practices first. The founder was right to push back.
- FLUX on Azure is a text-to-image API black box. The features that matter most for our use case (identity consistency across frames) simply don't exist on this deployment.
- The "just use detailed prompts" approach to character consistency is unproven for production sprite sets. We need to be honest about risks.
- 512x512 is the modern standard for AI sprite generation. 256 was a speed optimization that sacrificed too much detail.

### SPRITE-ART-BRIEF v3 — Definitive Multi-Model Brief (2026-03-11)

**Delivered:**
- Rewrote `games/ashfall/docs/SPRITE-ART-BRIEF.md` from scratch — v3 final, ~51KB (down from 73KB).
- Restructured around 3 validated FLUX models (FLUX 2 Pro, Kontext Pro, FLUX 1.1 Pro) with exact Azure endpoints, model params, rate limits.
- Designed three-model production pipeline: FLUX 2 Pro → hero frames at 1024×1024, Kontext Pro → bulk sprite production at 512×512 with `input_image` reference, FLUX 1.1 Pro → non-character assets.
- Added real production time estimates: ~34 min raw generation for 1,020 frames, ~2 hours with QA cycles.
- Revised frame count: ~1,020 total frames (51 poses × 2 chars × ~10 avg), down from ~1,200 (more realistic average).
- Introduced seed strategy for reproducibility (Kael: 1000–1999, Rhena: 2000–2999).
- Added hero frame gate — FLUX 2 Pro generates reference, Boba approves, then Kontext Pro produces all variants.
- Removed speculative sections (Tool Evaluation FLUX vs local SD, research section) — replaced with validated infrastructure.
- Kept character reference sheets, full pose catalog with frame counts, quality checklist, and file organization from v2.

**Key decisions:**
- Kontext Pro's `input_image` parameter changes everything. We are no longer limited to prompt anchoring. Character consistency risk drops from High to Medium.
- FLUX 2 Pro at 4 req/min is reserved exclusively for hero frames — too slow for bulk production but maximum quality for reference images.
- Hero frame approval is the pipeline's critical gate. No pose production begins until Boba signs off on the canonical character image.
- Removed the FLUX vs Local SD comparison section. With Kontext Pro reference propagation, the prompt-only weakness from v2 is mitigated. We proceed with Azure.

**Learnings:**
- Three models, three roles. Don't use the best model for everything — use each model where its strengths matter most.
- Rate limits define workflow architecture. 4/min for quality, 30/min for throughput — design the pipeline to match.
- The `input_image` parameter on Kontext Pro is the single most important capability for our use case. It transforms the pipeline from "hope for consistency" to "propagate identity."
- Always verify infrastructure before writing specs. v1 and v2 were written against assumptions. v3 is written against validated API calls.
