# Visual Excellence Research — 2D Game Art & SimpsonsKong Learnings

**Author:** Boba (Art Director)  
**Date:** 2026-06-03  
**Scope:** Industry research on 2D visual excellence + project retrospective

---

## Part 1 — Industry Research

### 1. What Award-Winning 2D Game Art Looks Like

The best 2D games share five traits regardless of art style:

| Game | Style | Why It Works |
|------|-------|-------------|
| **Cuphead** | 1930s rubber-hose animation | Hand-drawn frames at 24fps, watercolor backgrounds, every frame is a painting. Total commitment to one aesthetic — no style breaks. |
| **Hollow Knight** | Hand-drawn vector | Limited palette per biome (3–5 core colors), incredible silhouette clarity, environmental storytelling through art alone. Players recognize every area by color. |
| **Celeste** | Pixel art + particle effects | Tiny sprites with massive personality via animation. Dust clouds, hair movement, and trail effects convey weight and speed. Minimal pixels, maximum expressiveness. |
| **Dead Cells** | 3D-rendered-to-2D sprites | Fluid 60fps animation with anticipation/follow-through on every action. Procedural levels but hand-crafted animation quality. |
| **Streets of Rage 4** | Hand-painted digital | Bold outlines, flat shading with one highlight layer, limited palette per character. Readability at combat speed — every attack reads instantly. |

**Common excellence traits:**
1. **Commitment to one style** — no mixing pixel art with smooth vector or photorealism with cartoon. Style breaks destroy quality perception faster than low detail.
2. **Silhouette-first design** — every character, enemy, and prop is recognizable from silhouette alone. If you can't tell what it is in solid black, the design fails.
3. **Color restraint** — typically 4–6 core colors per character, 3–5 per environment zone. More colors ≠ better art; it means visual noise.
4. **Animation > detail** — a simple circle with perfect squash/stretch and timing looks better than a detailed static illustration. Motion sells quality.
5. **Background depth via atmospheric perspective** — far = desaturated + blurred, near = saturated + sharp. Costs nothing, adds huge perceived depth.

---

### 2. The Canvas 2D Art Ceiling — What's Actually Achievable

Canvas 2D is underestimated. With expert use, it can produce visuals that rival hand-drawn art for a specific style range:

**What Canvas 2D does WELL:**
- **Clean vector-style art:** Bezier curves, smooth outlines, crisp at any resolution. Think Hollow Knight's clean linework — achievable procedurally.
- **Flat-shaded cartoon:** The Simpsons/Adventure Time/Gravity Falls look — solid fills with outlines. This is Canvas 2D's sweet spot.
- **Gradient depth effects:** Sky gradients, health bar bevels, spotlight halos, atmospheric fog — all native Canvas operations.
- **Geometric particle effects:** Starbursts, speed lines, dust clouds, score popups — fast and memory-efficient.
- **Resolution independence:** Procedural art scales perfectly to any DPR/screen size. No blurry upscaling.

**What Canvas 2D CANNOT do well:**
- **Organic textures:** Wood grain, fabric weave, stone roughness — procedural noise is expensive and looks mechanical.
- **Complex hand-drawn frames:** Cuphead-style frame-by-frame animation is impossible procedurally. Each frame needs unique hand-crafted art.
- **Lighting/shadow systems:** Per-pixel lighting, normal maps, dynamic shadows — these require WebGL.
- **Large sprite counts:** 100+ unique on-screen elements with complex paths will tank performance.
- **Painterly/watercolor looks:** Soft blending, wet edges, paint texture — not Canvas 2D territory.

**The ceiling for a flat-shaded cartoon game is approximately Streets of Rage 4 clarity with Adventure Time rendering.** That's genuinely excellent for beat 'em ups.

**Performance ceiling:**
- ~20-30 complex path-drawn entities at 60fps on mid-range hardware
- ~50+ simple particle effects simultaneously
- Parallax backgrounds with 3-4 layers are free
- Text rendering (damage numbers, UI) is essentially free

---

### 3. Sprite Art vs. Procedural — Honest Comparison

| Factor | Procedural Canvas | Sprite Sheets |
|--------|------------------|---------------|
| **Setup time** | Zero — start drawing immediately | Hours — need art pipeline, asset loading, atlas packing |
| **Iteration speed** | Change a number, see it live | Re-export, re-pack, reload |
| **Resolution** | Perfect at any DPR/size | Fixed resolution, blurry if scaled up |
| **Art ceiling** | Flat-shaded cartoon (good) | Unlimited — any style the artist can draw |
| **Animation quality** | Limited by math (sine waves, transforms) | Unlimited — each frame hand-crafted |
| **Consistency** | Guaranteed — same code = same style | Requires discipline across artists/frames |
| **File size** | Zero assets, pure code | Can be large (sprite atlases) |
| **Character detail** | Diminishing returns past ~100 draw calls | Detail is "free" — it's just pixels |
| **Production speed (after setup)** | Slow for complex art (hours per character) | Fast for skilled artists (minutes per variant) |
| **Team scalability** | Hard — code conflicts, coordination | Easy — artists work on separate files |

**When procedural wins:**
- Prototyping and game jams (zero asset pipeline)
- Simple geometric styles (Geometry Dash, Super Hexagon)
- Infinite variation (procedural levels, random NPCs)
- Resolution-independent UIs and HUDs
- Particle effects and VFX (always procedural, even in sprite-based games)

**When sprites win:**
- Any style beyond flat-shaded cartoon
- Frame-by-frame character animation
- Team projects with dedicated artists
- Games with many unique characters/enemies
- When art quality is the primary selling point

**The crossover point:** When a single procedural character takes >200 lines of render code and >2 hours to build, sprites would have been faster. SimpsonsKong hit this threshold at Homer's Wave 6 redesign (~300 lines, ~3 hours).

---

### 4. Animation Excellence — The 12 Principles Applied to Game Art

Disney's 12 principles of animation aren't just for film — they're the difference between "programmer art that moves" and "art that feels alive."

**The Big 4 for games (highest impact):**

#### Squash & Stretch
- **Landing:** Character compresses vertically (0.8× height, 1.2× width) for 2-3 frames, then springs back.
- **Jumping:** Character stretches vertically at peak (1.2× height, 0.9× width).
- **Attacks:** Fist/foot stretches toward target during contact frame.
- **Implementation:** `ctx.scale(scaleX, scaleY)` before drawing. Timer-driven return to 1.0. ~10 lines of code for massive quality improvement.

#### Anticipation
- **Attacks:** Wind-up frame before strike — arm pulls back, body leans away. Player reads the attack 100ms before impact.
- **Jumps:** 1-2 frame crouch before leaving ground.
- **Importance for gameplay:** Anticipation IS telegraph. It makes enemies readable and combat fair.
- **Implementation:** State machine with `windup` → `active` → `recovery` phases per action.

#### Follow-Through & Overlapping Action
- **Hair/clothing:** Homer's belly should lag behind his movement direction by 1-2 frames.
- **Arm swing:** Arms continue past strike point, decelerate, return.
- **Landing dust:** Particles continue outward after character has stopped.
- **Implementation:** Secondary properties with damped spring physics. `velocity += (target - current) * stiffness - velocity * damping`.

#### Timing & Spacing
- **Fast attacks:** 1 frame anticipation, 1 frame active, 2 frames recovery (4 total = snappy).
- **Heavy attacks:** 4 frames anticipation, 2 frames active, 4 frames recovery (10 total = weighty).
- **Implementation:** Frame counters per action with easing curves. Ease-out for attacks (fast start, slow end). Ease-in for wind-ups (slow start, fast end).

**Secondary principles (nice-to-have):**
- **Exaggeration:** Make the belly bigger, the punch wider, the KO stars larger than realistic. Games need to read at speed.
- **Secondary action:** Breathing idle (belly rise/fall), blinking, weight-shift between feet. Makes characters feel alive even when player isn't pressing buttons.
- **Arcs:** Arms swing in arcs, not straight lines. Jumps are parabolic. Everything curves.

---

### 5. Color Theory for Games

#### Palette Design
- **Start with 5 colors maximum per entity.** Add colors only when gameplay requires distinction.
- **Use HSB, not RGB, for palette construction.** Keep Saturation consistent within a palette (e.g., all at 70-80%) and vary Hue for variety.
- **One accent color per palette.** Homer's accent is `#FED90F` yellow. Enemy accent is the variant color. UI accent is gold.

#### The 60-30-10 Rule
- **60%** dominant color (background, large surfaces) — low saturation, sets mood
- **30%** secondary color (mid-ground, characters) — medium saturation, provides structure
- **10%** accent color (UI, effects, key objects) — high saturation, draws the eye

#### Readability Hierarchy
1. **Lightest/brightest elements read first** — use for player character and important UI
2. **Highest contrast against background reads second** — use for enemies and interactables
3. **Mid-tones blend into mid-ground** — use for background detail that shouldn't distract
4. **Desaturated/dark elements recede** — use for far backgrounds and decorative elements

#### Saturation Depth Rule
- **Foreground:** 100% saturation (player, enemies, effects)
- **Mid-ground:** 60-70% saturation (buildings, props)
- **Far background:** 30-40% saturation (mountains, sky details, distant structures)
- This automatically creates depth without explicit z-ordering or perspective

#### Color for Game States
- **Danger:** Red hue shift, increased saturation, possible vignette
- **Power-up/heal:** Green/gold flash, brief brightness increase
- **Invincibility:** Desaturation or hue cycling (makes player visually distinct)
- **Low health:** Pulsing red overlay at screen edges, desaturated background

---

### 6. Visual Hierarchy in Gameplay — How Players Read the Screen

Players process the screen in a priority order that art direction must respect:

```
Priority 1: PLAYER CHARACTER → always visible, always readable
Priority 2: IMMEDIATE THREATS → enemies in attack range, projectiles
Priority 3: UI FEEDBACK → health, score, combo counter, damage numbers
Priority 4: INTERACTIVE OBJECTS → pickups, doors, switches
Priority 5: ENVIRONMENTAL CONTEXT → background, atmosphere, setting
```

**Rules for maintaining hierarchy:**
1. **Player must contrast with everything.** If background is blue, player can't be blue. SimpsonsKong gets this right — Homer's yellow pops against every background color.
2. **Enemies must contrast with background but not outshine player.** Slightly lower saturation or smaller size than player.
3. **UI must be in screen-space, not world-space** (except damage numbers, which are world-anchored but short-lived).
4. **Effects must not obscure gameplay.** VFX should use additive blending or low alpha so entities remain visible through explosions/impacts.
5. **Background must not compete.** Animated background elements (swaying trees, flickering lights) should be slow and subtle. Fast background motion draws the eye away from gameplay.

**The "squint test":** Squint at your game until it's blurry. If you can still identify the player, enemies, and health bar, your visual hierarchy works. If everything blends together, you need more contrast between layers.

---

### 7. Art Pipeline for Web Games

#### From Concept to Screen

```
1. CONCEPT (paper/digital sketch)
   ↓ Define silhouette, proportions, key colors
2. STYLE GUIDE (art-direction.md)
   ↓ Lock palette, outline rules, shading model, proportion reference
3. PROTOTYPE (rough Canvas code or quick sprite)
   ↓ Prove it works in-game at target size, test readability
4. PRODUCTION (final render code or sprite sheet)
   ↓ Full detail, all animation states, edge cases
5. INTEGRATION (wire into game systems)
   ↓ Connect to state machine, test at 60fps
6. POLISH (VFX, juice, secondary animation)
   ↓ Add particles, squash/stretch, screen shake
7. QA (visual audit)
   ↓ Check at multiple resolutions, DPR values, screen sizes
```

#### Tools for Web Game Art
- **Concept/design:** Figma (free, collaborative), Aseprite (pixel art), Procreate (iPad)
- **Sprite sheets:** TexturePacker, ShoeBox (free), Aseprite (built-in export)
- **Color palettes:** Lospec (curated game palettes), Coolors (generator), Adobe Color
- **Canvas debugging:** Chrome DevTools Canvas inspection, custom debug overlay
- **Animation preview:** Sprite sheet viewer extensions, or in-game debug mode with frame stepping
- **Version control for art:** Git LFS for sprite sheets, or separate art repo

#### Key Pipeline Decisions (Make on Day 1)
1. **Procedural or sprite-based?** Decide before writing render code.
2. **Target resolution + DPR?** Set canvas scaling before any art goes in.
3. **Outline style?** Thick (3px+), thin (1-2px), or none. Changing later rewrites every entity.
4. **Palette?** Lock 10-15 colors. Every new color needs justification.
5. **Proportion reference?** One reference sheet showing all entities at correct relative scale.

---

### 8. Resolution-Independent Design

#### The Problem
A 1280×720 canvas on a 2560×1440 Retina display looks blurry because each canvas pixel maps to a 2×2 block. This is the #1 cause of "cutre" (tacky/cheap) appearance in web games.

#### The Solution — DPR Scaling

```javascript
const dpr = window.devicePixelRatio || 1;
canvas.width = canvas.clientWidth * dpr;
canvas.height = canvas.clientHeight * dpr;
ctx.scale(dpr, dpr);
// Now draw at logical pixels — Canvas handles physical pixel mapping
```

#### Design Rules for Resolution Independence
1. **All measurements in logical pixels.** A character is "80px tall" regardless of DPR. The canvas scaling handles physical pixels.
2. **Never use `image-rendering: pixelated`** for procedural art. It forces nearest-neighbor upscaling that turns smooth bezier curves into chunky blocks. Only use for actual pixel art.
3. **Minimum line width = 1 logical pixel.** Below that, lines disappear on standard displays and appear inconsistently on HiDPI.
4. **Minimum font size = 10px logical.** Below that, text is illegible on any display. For background decorative text, 12px minimum.
5. **Test at DPR 1, 2, and 3.** Most development happens on DPR 2 (Retina). DPR 1 (standard monitors) and DPR 3 (high-end phones) need verification.
6. **Handle resize events.** Recalculate `canvas.width`/`canvas.height` on `window.resize` and re-apply `ctx.scale(dpr, dpr)`.

#### Responsive Layout for Games
- **Aspect ratio lock:** Pick one (16:9, 4:3) and letterbox/pillarbox the rest. Don't stretch.
- **Viewport-relative UI:** Position HUD elements as % of screen, not fixed pixel positions.
- **Scale game world to fit:** Calculate a `gameScale` factor based on `min(screenWidth/designWidth, screenHeight/designHeight)` and apply to all rendering.

---

## Part 2 — SimpsonsKong Learnings

### The devicePixelRatio Disaster

**What happened:** The canvas was set to 1280×720 physical pixels but displayed in a CSS container that could be 2560×1440 on Retina screens. Zero `devicePixelRatio` references existed in the entire codebase. Additionally, `image-rendering: pixelated` was applied via CSS, forcing nearest-neighbor upscaling.

**The result:** Every carefully crafted bezier curve, every smooth gradient, every anti-aliased outline was rendered at half resolution and then blocky-upscaled. Hours of procedural art work was invisible to users because the rendering pipeline destroyed it.

**The fix:** 30 minutes. Set `canvas.width = clientWidth * dpr`, `canvas.height = clientHeight * dpr`, apply `ctx.scale(dpr, dpr)`, remove `image-rendering: pixelated`. Instant 60%+ perceived quality improvement.

**The lesson:** **Rendering pipeline > art quality.** A masterpiece printed on a fax machine looks terrible. Before spending any time on art, verify the display pipeline is correct. DPR scaling should be the FIRST thing set up in any Canvas project. Not the last.

---

### Procedural Art Limitations — What Took Hours vs. Minutes

**Hours spent on procedural that sprites would solve faster:**
- Homer's full body render: ~300 lines, ~3 hours. A sprite sheet of 8 poses would take a skilled artist ~1 hour and look better.
- Enemy variants: ~200 lines each × 4 variants = ~800 lines, ~6 hours. Sprite palette swaps would take ~30 minutes per variant.
- Springfield buildings: ~150 lines per building type. Pre-drawn building sprites would take ~20 minutes each and have texture/detail that procedural can't match.

**Things procedural did WELL:**
- VFX (starbursts, damage numbers, trails) — always better procedural. Dynamic, resolution-independent, zero asset overhead.
- Shadows and ground effects — simple ovals/gradients, no asset needed.
- UI elements (health bars, score display) — procedural is perfect for dynamic UI.
- Background parallax sky/clouds — gradients and circles are ideal.

**The crossover rule we discovered:** If a visual element has >3 animation states AND >100 lines of render code, it should be a sprite sheet. If it has ≤2 states OR is purely geometric, keep it procedural.

---

### Multi-Artist Coordination — How 4 Art Roles Worked

SimpsonsKong had four agents touching visuals: Boba (art direction + VFX), Lando (player entity), Tarkin (enemy entities), and implicitly whoever owned background.js.

**What worked:**
- **art-direction.md as single source of truth** — the palette table, outline spec (`#222222`, 2px, round caps), and shading model were referenced by every agent. Consistency happened because the rules were written down, not verbal.
- **VFX as a shared module** — `vfx.js` provided common effects (shadows, hit effects, damage numbers) that all entities used. No duplication, consistent style.
- **Render-only scope** — art changes were explicitly scoped to `render()` methods. No art agent touched gameplay logic, preventing cross-domain bugs.

**What didn't work:**
- **Scale/proportion drift** — Homer was 64×80, enemies were 48×76, but the art direction spec said 1:2.5 head ratio for Homer and "taller/leaner" for enemies. In practice, proportions drifted because there was no visual reference sheet — just text descriptions.
- **No visual review step** — changes were reviewed as code diffs, not screenshots. A bezier curve change that looks correct in code can look terrible on screen. Need in-game screenshot reviews.
- **Blocked integration** — art assets (VFX functions, render changes) were delivered but integration into gameplay.js was blocked on another agent. Art sat unused for waves.
- **Style conflicts in edge cases** — the art-direction.md covered main cases but not edge cases (what color is a fist during a punch? what opacity is a dying enemy?). Each agent made different assumptions.

**Recommendation:** For multi-artist projects, produce a **visual reference sheet** (rendered screenshots, not code) showing every entity at correct scale side by side. Update it every wave. Review art changes via screenshots, not diffs.

---

### Scale/Proportion Consistency — The Car/Building/Character Problem

**The issue:** When Homer (80px) stands next to a building (150px), the building is less than 2× his height — making Homer look like a giant. When the Power Plant cooling towers (180px) appear on the far parallax layer, they should dwarf everything but were barely larger than mid-layer buildings.

**Root causes:**
1. **No proportion reference existed.** Each entity was drawn in isolation with arbitrary pixel dimensions. Nobody checked relative scale until everything was on screen together.
2. **Parallax confuses scale.** A 180px tower at 0.2× parallax scrolls slower (correct) but doesn't appear smaller (incorrect). Need to also reduce rendered size for far objects.
3. **Canvas coordinate systems are entity-local.** Each entity draws at (0,0) and gets translated. Easy to lose track of absolute size when every render() starts at origin.

**Fix:** Create a **scale reference constant** in config:
```
PLAYER_HEIGHT: 80,  // reference unit
ENEMY_HEIGHT: 76,   // 95% of player (slightly shorter for most, taller for heavy)
BUILDING_HEIGHT: 240, // 3× player height
POWER_PLANT_HEIGHT: 400, // 5× player height  
TREE_HEIGHT: 160,   // 2× player height
```
All entities derive their dimensions from these constants. Change `PLAYER_HEIGHT` and everything scales proportionally.

---

### Art Direction as a Role — Was It Worth Having?

**Yes, emphatically.** Without an art direction role:
- Each agent would pick their own outline color (some `#000`, some `#333`, some `#222`)
- Palette would drift (enemy red might clash with UI red)
- Shading model would be inconsistent (some entities with gradients, some flat)
- VFX style would fragment (different impact effects per entity)

**What the art director role provided:**
1. **Style guide** — locked palette, outline spec, shading model before any art was produced
2. **Quality audits** — caught DPR issue, scale problems, saturation hierarchy gaps
3. **Shared systems** — VFX module prevented every agent from inventing their own effects
4. **Modernization roadmap** — prioritized 36 upgrade items by impact/effort, preventing random polish

**What would change next time:**
- **Visual reference sheet on Day 1** — not just text descriptions but rendered reference images
- **Screenshot-based review** — every art PR includes before/after screenshots
- **DPR/rendering pipeline audit before ANY art work** — the #1 lesson from this project
- **Explicit edge-case coverage** — the style guide should cover intermediate states (hit flash color, death animation opacity, wind-up visual, etc.)

---

## Part 3 — Future Project Guidelines

### Day 1 Art Decisions Checklist

Before writing a single line of render code:

- [ ] **Target resolution:** What is the design resolution? (e.g., 1280×720 logical pixels)
- [ ] **DPR handling:** Is `devicePixelRatio` scaling implemented? (Do this FIRST)
- [ ] **CSS rendering mode:** Confirm NO `image-rendering: pixelated` for procedural art
- [ ] **Art approach:** Procedural Canvas, sprite sheets, or hybrid? Decision is final.
- [ ] **Color palette:** Lock 10-15 colors with specific hex codes. Document in style guide.
- [ ] **Outline style:** Width (px), color (hex), cap style, join style. One standard for ALL entities.
- [ ] **Shading model:** Flat? One highlight? Full gradient? Pick one and enforce.
- [ ] **Proportion reference:** All entities drawn at correct relative scale in one reference image.
- [ ] **Animation approach:** Transform-based (scale/rotate/translate) or frame-based (sprite states)?
- [ ] **VFX style:** Comic-book? Realistic particles? Minimal? Document with examples.

### Sprite Sheet Pipeline — When to Switch

**Trigger conditions for switching from procedural to sprites:**
1. A single entity's `render()` exceeds 200 lines
2. An entity needs >4 distinct animation poses
3. The art style requires textures, gradients, or details that procedural can't efficiently produce
4. A second artist joins the project (sprites are parallelizable, code is not)
5. Production speed matters more than resolution independence

**Pipeline setup (if switching):**
1. Choose tool: Aseprite (pixel), Figma (vector), Procreate (hand-drawn)
2. Set up atlas packing: TexturePacker or Aseprite's built-in sheet export
3. Implement sprite loader: `Image()` + `drawImage()` with source rect
4. Define animation data format: JSON with frame indices, durations, origins
5. Build sprite animation player: frame counter, timing, looping
6. Convert entities one at a time — don't big-bang switch

### Art Review Process

**Per-change review:**
1. Before/after screenshots at 1× and 2× DPR
2. Side-by-side comparison at gameplay zoom level (not zoomed in)
3. Squint test: still readable when blurred?
4. Motion test: does it look right during gameplay, not just standing still?

**Per-wave audit:**
1. Full-screen screenshot with all entity types visible
2. Proportion check: are relative sizes correct?
3. Palette check: any colors not in the style guide?
4. Saturation hierarchy: foreground > mid > far?
5. Performance check: still 60fps with all effects active?

**Per-milestone audit:**
1. Play the game for 5 minutes as a first-time user
2. Record video and watch at 2× speed — visual issues jump out
3. Compare against art direction targets — what's hit, what's missed?
4. Update style guide with any new decisions made during development
