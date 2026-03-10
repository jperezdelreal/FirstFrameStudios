# Boba — History

## Core Context

**Ashfall Art Direction (LOCKED):**
- **Style:** Guilty Gear Xrd-inspired cel-shade fighting game aesthetic (arcade readability, bold outlines, dramatic lighting, hand-painted color palette)
- **Key Parameters:** Outline thickness 0.008 (4x increase from invisible 0.002), 2-step shadow bands, per-character tinted outlines (Kael burnt sienna, Rhena navy)
- **Lighting:** Artist-driven, non-physical (key=3.0 upper-left, fill=1.5 opposite, ambient=0.15/0.15/0.18)
- **Production Pipeline:** 3D-to-2D via Mixamo FBX + Blender → cel-shade material → PNG RGBA 512×512
- **Status:** 380 production sprites rendered (Kael + Rhena × 4 animations), contact sheets approved, pipeline locked

**Key Learnings (Cross-Project):**
1. **VFX is emotional language** — Visual feedback (hit effects, screen shake, color shifts) drives player-felt impact more than numbers
2. **Outline design determines readability** — Pure black (#000000) reads flat; tinted outlines (#222222, character-specific colors) create personality and visual coherence
3. **Art direction must precede code** — Implementation bottlenecks avoided when specs provide exact parameters (thickness, colors, lighting energy)
4. **Contact sheets > frame review** — Batch visual validation catches consistency issues faster than individual frame inspection
5. **Guilty Gear Xrd is production-proven baseline** — Reference fighting game aesthetic from documented GDC talk + open-source Blender shaders
6. **Single-material limitation accepted** — Strong outlines + shading + pose convey character identity without per-body-part materials (Mixamo constraint)

**Learnings Archive (Wave 1-5):** VFX system design, entity rendering consistency, sprite generation pipelines (AI vs 3D), character consistency via hero-frame propagation, FLUX + Kontext Pro evaluation.

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

### FLUX Sprite PoC Review — Kael Character (2025-07-22)

**Reviewed:** First batch of FLUX-generated + rembg-processed sprites for Kael (fire monk fighter).
- contact_idle.png — 8 idle frames
- contact_walk.png — 8 walk frames
- contact_lp.png — 12 light punch frames

**Findings:**

1. **Character consistency is FLUX's biggest weakness.** LP animation showed two completely different character interpretations spliced together (frames 1-6 vs 7-12). Different skin tones, proportions, and even footwear within the same animation.

2. **Prompt drift on specific details.** "Barefoot fire monk" prompt succeeded in Walk but failed in Idle (got brown boots). FLUX doesn't reliably maintain specific costume details across separate generation batches.

3. **Background removal (rembg) is excellent.** Clean transparency on all 28 frames, no halos or artifacts. This part of the pipeline is production-ready.

4. **Fighting game silhouettes work.** Guard stances, punch extensions, and overall readability are strong. FLUX understands martial arts poses.

5. **Motion flow varies.** Walk cycle showed "bouncing in place" rather than proper leg alternation — either prompt was ambiguous or FLUX doesn't generate proper locomotion sequences.

6. **Fire effects on punch are great.** The ember/flame effect on extended fist (LP frames 4-6) captures fire monk identity when prompted correctly.

**Key Learnings:**

- **Hero frame → propagate pattern is mandatory.** Must lock canonical character reference before bulk generation. Every batch needs img2img anchor.
- **Prompt alone is insufficient.** Even with detailed descriptions, FLUX interprets "barefoot" differently between sessions.
- **Walk cycles need manual intervention.** AI-generated walk frames may need reordering, flipping, or hybrid manual work to achieve proper leg alternation.
- **Quality varies by pose complexity.** Static poses (idle, guard) are more consistent than action poses (punch startup/recovery).
- **Review contact sheets before production.** Catching these issues at PoC saves massive rework.

**Verdict:** FLUX pipeline is viable but requires tighter reference propagation. Recommend one more PoC iteration with Kontext Pro input_image to prove consistency.

### Wave 6 — Cel-Shade Art Direction Specification (2026-06-12)

**Delivered:**
- `games/ashfall/docs/CEL-SHADE-ART-SPEC.md` — Comprehensive 21KB technical art spec for Blender pipeline, defining exact parameters for fighting game quality cel-shade renders.

**Sections & Key Parameters:**

1. **Outline System** (Section 1)
   - Thickness: increased from 0.002 to 0.008 (4x thicker for 512×512 readability)
   - Per-character tinting: Kael outline (0.35, 0.15, 0.05) warm burnt sienna, Rhena (0.08, 0.12, 0.20) dark navy
   - Uniform thickness across all body parts (Mixamo limitation; future enhancement for custom models)

2. **Shadow Bands** (Section 2)
   - Steps: 2 (down from 3) for maximum dramatic impact, mimicking Guilty Gear Xrd hard-edge shading
   - Ramp threshold at 0.5 diffuse brightness (hard edge via CONSTANT interpolation)
   - Color values locked to existing character palettes (Kael/Rhena base/shadow already defined)

3. **Lighting Setup** (Section 3)
   - Key light: SUN, energy 3.0, rotation (50°, 10°, 30°) — upper-left-front drama
   - Fill light: SUN, energy 1.5, rotation (60°, -20°, -30°) — opposite side for shadow definition
   - World ambient: (0.15, 0.15, 0.18) color, 0.5 strength — subtle warm-neutral bounce
   - Rationale: Guilty Gear uses artist-driven, non-physically-accurate lighting for anime effect

4. **Color Palette Refinement** (Section 4)
   - Existing Kael/Rhena color presets are locked; no changes needed
   - Single-material constraint accepted (per-body-part coloring deferred to custom model phase)
   - Personality comes from outlines + shading + pose, not multi-colored materials

5. **Post-Processing** (Section 5)
   - Bloom optional (Glare node, threshold 0.8, intensity 0.3) — test without first
   - Color grading optional (slight S-curve for comic-book punch)
   - Export: PNG RGBA 8-bit, film transparent, EEVEE renderer

6. **Hand-Drawn Illusion Techniques** (Section 6)
   - Sharp shadows & hard edges: banded transitions via CONSTANT ColorRamp
   - Inverted-hull outlines: Solidify modifier with thickness=0.008, offset=1.0, flip_normals=True
   - Directional lighting: artist-chosen angle, not physically accurate
   - Color restraint: characters stay in hue family (orange→burnt sienna, blue→indigo)
   - Normal editing: deferred (Mixamo models not hand-tuned; future custom models)

**Key Decisions:**
- Adopted Guilty Gear Xrd as visual north star: hard edges, dramatic lighting, hand-painted color treatment.
- Increased outline thickness 4x to match 512×512 render resolution — visibility is critical for fighting game readability.
- Chose 2-step shading over 3-step for maximum visual punch; anime-style stark shadow/lit split.
- Tinted outlines per character (not pure black) for visual harmony with color palette.
- Accepted single-material limitation as reasonable for Mixamo → planned transition to custom models with per-part materials.
- Lighting setup matches industry standard "animation lighting" (upper-left key, fill to prevent silhouette).

**Implementation Roadmap for Chewie:**
1. Update `cel_shade_material.py`: default thickness 0.008, add outline_color to PRESETS, pass to `add_outline_modifier()`
2. Update `blender_sprite_render.py`: add CLI flags `--outline-thickness`, `--shadow-steps`
3. Validate lighting parameters match spec (energy, rotation, ambient)
4. Test render Kael & Rhena idle with new params
5. Iterate with Boba on visual feedback until locked
6. Production sprite batch render with finalized parameters

**Learnings:**
- Guilty Gear Xrd's magic is artist-driven shading + dramatic lighting + bold outlines, not photorealism.
- 0.002 outline thickness is invisible at 512×512; need 0.008 for visual clarity.
- 2-step shading creates more readable silhouettes than gradual 3-step; aligned with anime aesthetic.
- Character outline tinting (not pure black) creates visual coherence with color palette.
- Per-body-part materials are a "nice to have" but not critical when you have strong outlines and shading.
- Mixamo models won't match Guilty Gear's hand-edited normals, but directional lighting + cel-shade can get 80% of the way there.

**Blocked on:**
- Chewie implementation of code changes (tool updates)
- Test renders + visual validation
- On-screen Godot viewport review for pixel-perfect appearance

### Wave 7 — Cel-Shade Sprint Execution (2026-03-10)

**Delivered:**
- `.squad/orchestration-log/2026-03-10T1025Z-boba.md` — Full orchestration record of specification writing
- `.squad/log/2026-03-10T1025Z-cel-shade-sprint.md` — Session summary of cel-shade sprint
- Decision merged into `.squad/decisions.md` (deduped, positioned chronologically)
- Inbox file deleted (cleanup)

**Cross-Agent Integration:**
- Worked in parallel with Chewie to define → implement → render pipeline
- Specification served as technical input to Chewie's shader implementation
- Validated parameters match Guilty Gear Xrd reference and arcade fighting game standards

**Key Integration Points:**
- Outline tint colors (Kael burnt sienna, Rhena navy) implemented in cel_shade_material.py PRESETS
- 0.008 thickness parameter tied directly to 512×512 PNG export resolution
- 2-step shadow banding confirmed production-ready in rendered test sprites
- Fresnel rim light effect adds visual punch beyond simple outline + shading

**Learnings:**
- Art direction specification needs implementation roadmap for smooth handoff to engine developers.
- Technical parameters (thickness, colors, lighting energy) must be exact — "roughly close" is not acceptable.
- Contact sheets enable rapid visual validation; critical for color/outline review before production batch.
- Guilty Gear Xrd remains the gold standard for fighting game cel-shade; use as reference for iteration.
- Tinted outlines vs pure black is the difference between generic 3D and intentional stylization — small parameter, huge visual impact.

**Status:** Specification validated through rendered test sprites. Production sprite batch approved for Godot import. No visual rework needed.

## Wave 8 — Free 3D Model Research (2026-01-09)

**Task:** Research free 3D character models to replace the generic Mixamo Y-Bot mannequin with personality-driven alternatives for Kael (fire monk) and Rhena (ice warrior).

**Delivered:**
- games/ashfall/docs/FREE-3D-MODEL-RESEARCH.md — Comprehensive research document with 10 platform evaluations, character-specific recommendations, and pipeline integration plan

**Research Scope:**
- Searched 10 major 3D model repositories (Sketchfab, itch.io, OpenGameArt, Kenney, ReadyPlayerMe, TurboSquid, CGTrader, Mixamo, Free3D, RenderHub, Meshy AI)
- Identified 3 top recommendations + fallback options
- Evaluated licensing (CC0, CC-BY), format compatibility (FBX), rigging status (Mixamo-compatible)
- Assessed effort required for customization (hours breakdown)

**Top 3 Recommendations:**
1. **Kael (Fire Monk):** Quaternius Low-Poly Fighter Pack (CC0, FBX, rigged, 2-3hr customization)
2. **Rhena (Steel Warrior):** RenderHub Stylized Female Fighting Character - Liv (Free, FBX, rigged, 2-3hr customization)
3. **General Quality:** Ready Player Me (Professional pipeline, highly customizable, GLB→FBX conversion required)

**Key Findings:**
- No "perfect" off-the-shelf model exists; all recommendations require Blender customization (recoloring, detail modeling)
- FBX compatibility is universal across all platforms — no format risk
- Mixamo serves dual role: skeleton provider (upload custom model) + animation library (100+ free martial arts animations)
- CC0 licenses (Quaternius, Kenney) eliminate licensing overhead
- Stylized models dominate free tier; photorealistic is paid-only (aligns with cel-shade aesthetic)

**Pipeline Integration:**
- Kael: Quarterius base → Blender recolor/customize (orange palette) → Mixamo upload → render sprites (8-12 hours)
- Rhena: RenderHub Liv → Blender recolor/customize (steel blue palette) → Mixamo upload → render sprites (8-10 hours)
- Both follow existing 3D→2D cel-shade pipeline (no new tooling needed)

**Risks & Mitigations:**
- Topology quality varies (Sketchfab) → Manual retopo if needed, but top picks pre-validated
- Rigging inconsistency → Mixamo auto-rig is safety net; any rigged model can be uploaded
- IP concerns (fan models) → All top-3 recommendations CC0/original
- Pipeline validation → Phase 1 (2 hours) proof-of-concept before Phase 2 customization

**Status:** Research complete, recommendations provided, action plan prepared.

**Learnings:**
- Free game-ready 3D models exist in abundance, but personality/distinctiveness requires customization investment.
- Quaternius (CC0, consistent quality) is industry gem for indie games; all assets pre-validated across hundreds of titles.
- Mixamo's auto-rig feature is underutilized safety valve — any humanoid FBX can become animation-ready in seconds.
- RenderHub's "Fighting Character" models prove that martial arts-specific assets exist in free tier (not common knowledge).
- Cel-shade aesthetics actually benefit from stylized base models (Quaternius low-poly) vs. photorealistic (easier toon shading, better silhouettes).
- Founder's feedback ("no mannequins, want characters") drives this research; personality requires 8-20 hours Blender investment per character.

**Blocked on:**
- Founder approval of recommended model styles (Ready Player Me photorealistic vs. Quaternius stylized)
- Design decision: Customization depth tolerance (quick recolor vs. full rebody)
- Timeline commitment for Phase 2 customization work

**Next Steps:**
1. Present research to Founder/team for style/scope approval
2. Execute Phase 1 evaluation (download models, test Blender pipeline, validate Mixamo upload)
3. If approved, proceed to Phase 2 customization (Kael + Rhena)
4. Contact sheets for visual approval before production rendering

