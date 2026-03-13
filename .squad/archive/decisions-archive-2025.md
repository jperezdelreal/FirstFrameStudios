# Decisions Archive — 2025

> Archived decisions from 2025. See `decisions.md` for active decisions.

## Quick Index

| Decision | Date |
|----------|------|
| Mace — Wiki Updates After Milestone Completion (2025-01-20) | 2025-01-20 |
| V2 Animation Consistency Audit (Boba) | 2025-01-27 |
| Full Details | 2025-07-15 |
| Full Details | 2025-07-15 |
| GitHub Actions Cron Reduction (2025-07-16) — ARCHIVED | 2025-07-16 |
| Lando — Integration Fixes (2025-07-17) | 2025-07-17 |
| Solo — Integration Audit (2025-07-17) | 2025-07-17 |
| Lando — Fighter Controller + Input Buffer Architecture (2025-07-21) | 2025-07-21 |
| Ashfall GDD v1.0 — Creative Foundation (Yoda) | 2025-07-21 |
| New Project Playbook Created (Solo) | 2025-07-21 |
| Skills System Needs Structural Investment Before Next Project (Ackbar) | 2025-07-21 |
| New Project Playbook Created (Solo) | 2025-07-21 |
| Skills System Needs Structural Investment Before Next Project (Ackbar) | 2025-07-21 |
| Chewie — Fighter Engine Infrastructure Decisions (2025-07-22) | 2025-07-22 |
| Walk/Kick Animation + Hit Reach Fix (Lando) | 2025-07-23 |
| Jango — GitHub Issues Infrastructure for Ashfall Sprint 0 (2025-07-24) | 2025-07-24 |
| 2025-07-24: Godot Build Pipeline Architecture — Jango (Tool Engineer) | 2025-07-24 |
| Ashfall Fighting Game Architecture (Solo) | 2025-08-03 |
| Successfully Downloaded (automated) |  |
| Pipeline Test Results |  |
| Test renders at: |  |
| Priority 1: More Quaternius Packs (browser) |  |
| Priority 2: KayKit Adventurers (browser) |  |
| Priority 3: Mixamo Characters (browser) |  |
| Test any FBX in pipeline: |  |
| 1. Tighter Camera Framing |  |
| 2. Root Motion Pinning (NEW) |  |
| 3. Animation-Aware Frame Stepping (NEW) |  |
| 1. Fixed-Timestep Game Loop (Accumulator Pattern) |  |
| 2. SceneContext Injection (No Global Singletons) |  |
| 3. Input Edge Detection Per Fixed Step |  |
| 4. Scene Transitions via Graphics Overlay |  |
| Summary |  |
| Key Decisions |  |
| Impact |  |
| Decision |  |
| Why |  |
| Context |  |
| Decision |  |
| Why |  |
| Trade-offs |  |
| Phase 1 — Canvas 2D Optimization (NOW, 8-12 hours, zero risk) |  |
| Phase 2 — Hybrid Canvas + PixiJS (LATER, 23-35 hours, if Phase 1 isn't enough) |  |
| Rejected Options |  |
| Why Not Phaser |  |
| Why Godot |  |
| Why Not Unity |  |
| The Score |  |
| Cost |  |
| Action Needed |  |
| Current Solo Charter |  |
| What Chief Architect Would Own |  |
| Overlap Analysis: **~80% overlap.** |  |
| What's Genuinely New |  |
| Verdict: **Do NOT create Chief Architect. Expand Solo's charter.** |  |
| Current Chewie Charter |  |
| What Tool Engineer Would Own |  |
| Overlap Analysis: **~40% overlap.** |  |
| What Chewie Already Does That's Tool-Adjacent |  |
| What's Genuinely New in Godot |  |
| Verdict: **YES, create Tool Engineer. This is a distinct role.** |  |
| Does Godot's Architecture Justify a Dedicated Tooling Role? |  |
| Godot's Scene-Signal Architecture Creates Unique Coordination Challenges |  |
| Current Roster (12 OT Characters) |  |
| Adding 1 New Role → 13 Characters |  |
| Options for the 13th Character |  |
| Recommendation: **Prequel is fine. Go with it.** |  |
| Chief Architect → Absorbed into Solo ✅ |  |
| Tool Engineer → NOT absorbable ❌ |  |
| Charter Draft for Tool Engineer |  |
| VERDICT: **NEEDS WORK** |  |
| VERDICT: **NEEDS WORK** |  |
| VERDICT: **FAIL** |  |
| Summary |  |
| Actionable Next Steps |  |
| What's Working |  |
| Recommendation |  |
| 1. Industry Standard for Game Studios |  |
| 2. FLUX Model Transparency Capabilities |  |
| 3. Chroma Key vs. AI Background Removal |  |
| 4. Best Chroma Key Color |  |
| 5. AI-Generated Sprite Pipeline Best Practices |  |
| Option A: Green Chroma Key → Color-Key Removal Script ✅ (Current) |  |
| Option B: LayerDiffuse for Direct Transparent Generation 🌟 (Premium) |  |
| Option C: Solid Color Background → rembg AI Removal |  |
| Option D: Hybrid Approach (Recommended Flexibility) |  |
| Primary Path: **OPTION A + OPTION B (Hybrid Progressive)** |  |
| 1. PNG Sprite Scale = 0.20 |  |
| 2. AnimatedSprite2D.flip_h for PNG sprite mirroring |  |
| 3. All 45+ poses mapped in _POSE_TO_ANIM |  |
| 4. fighter_base owns CharacterSprite reference |  |
| Timeline-Based Architecture |  |
| Reuse Existing Sprite Methods |  |
| Skip on Any Key |  |
| Black Background |  |
| Summary |  |
| Key Decisions |  |
| Impact |  |
| Decision |  |
| Why |  |
| Context |  |
| Decision |  |
| Why |  |
| Trade-offs |  |
| Phase 1 — Canvas 2D Optimization (NOW, 8-12 hours, zero risk) |  |
| Phase 2 — Hybrid Canvas + PixiJS (LATER, 23-35 hours, if Phase 1 isn't enough) |  |
| Rejected Options |  |
| Why Not Phaser |  |
| Why Godot |  |
| Why Not Unity |  |
| The Score |  |
| Cost |  |
| Action Needed |  |
| Current Solo Charter |  |
| What Chief Architect Would Own |  |
| Overlap Analysis: **~80% overlap.** |  |
| What's Genuinely New |  |
| Verdict: **Do NOT create Chief Architect. Expand Solo's charter.** |  |
| Current Chewie Charter |  |
| What Tool Engineer Would Own |  |
| Overlap Analysis: **~40% overlap.** |  |
| What Chewie Already Does That's Tool-Adjacent |  |
| What's Genuinely New in Godot |  |
| Verdict: **YES, create Tool Engineer. This is a distinct role.** |  |
| Does Godot's Architecture Justify a Dedicated Tooling Role? |  |
| Godot's Scene-Signal Architecture Creates Unique Coordination Challenges |  |
| Current Roster (12 OT Characters) |  |
| Adding 1 New Role → 13 Characters |  |
| Options for the 13th Character |  |
| Recommendation: **Prequel is fine. Go with it.** |  |
| Chief Architect → Absorbed into Solo ✅ |  |
| Tool Engineer → NOT absorbable ❌ |  |
| Charter Draft for Tool Engineer |  |
| Net Team Impact |  |
| Alternative 1: "Don't document. Trust people and relationships." |  |
| Alternative 2: "Create new structure for each new genre." |  |
| Alternative 3: "Write the framework after the second game ships." |  |
| 1. Fixed-Timestep Game Loop (Accumulator Pattern) |  |
| 2. SceneContext Injection (No Global Singletons) |  |
| 3. Input Edge Detection Per Fixed Step |  |
| 4. Scene Transitions via Graphics Overlay |  |
| Ralph-Watch Guardrails (G10 + G11) — ARCHIVED |  |

---

### Chewie — Fighter Engine Infrastructure Decisions (2025-07-22)
**Author:** Chewie (Engine Developer)  
**Status:** Proposed  
**Scope:** Ashfall — fighter state machine, hitbox/hurtbox, round manager

Technical architecture decisions for Ashfall combat engine:

1. **Simplified Collision Layers (4 instead of 6)** — Using scaffold's existing 4 layers (Fighters, Hitboxes, Hurtboxes, Stage) for local play. Will expand to 6-layer per-player scheme when needed for 2v2 or complex self-hit prevention.
2. **Node Names Without "State" Suffix** — States named "Idle", "Walk", "Attack" (not "IdleState"). Makes transition calls clean: `transition_to("idle")`.
3. **Frame-Phase Attack State (Temporary)** — AttackState uses frame counters for hitbox timing. Will switch to AnimationPlayer-driven activation when Tarkin creates MoveData resources.
4. **Dual Signal Emission in RoundManager** — Both local signals (for FightScene wiring) AND EventBus global signals (for UI/VFX/audio decoupling). Slight redundancy for significant decoupling benefit.
5. **Input Wrappers (Not InputBuffer Yet)** — Placeholder thin wrappers over Input singleton, keyed by player_id. Lando will replace with full InputBuffer system per ARCHITECTURE.md.

**Impact:** Lando extends these with motion detection. Tarkin creates MoveData resources. Wedge wires signal connections. Solo reviews collision expansion path.

---

---

### Lando — Fighter Controller + Input Buffer Architecture (2025-07-21)
**Author:** Lando (Gameplay Developer)  
**Status:** Implemented  
**Scope:** Ashfall — input system and fighter gameplay layer

Core input system decisions:

1. **InputBuffer Routes ALL Input** — All fighter input flows through InputBuffer ring buffer (8-frame / 133ms leniency). Enables buffered inputs, motion detection, consume mechanics, AI injection, deterministic replay.
2. **Controller Handles Attacks, States Handle Movement** — FighterController owns attack priority (throw > specials > normals). States handle movement transitions (idle ↔ walk ↔ crouch ↔ jump). Separation prevents rewriting state logic.
3. **Motion Priority: Complex Beats Simple** — DP (→↓↘) beats QCF (↓↘→). Priority order: double_qcf > hcf/hcb > dp > qcf/qcb. Matches SF6/Guilty Gear standard.
4. **MoveData as Pure Resource** — Moves are `.tres` resource files. Designers tune frame data in Inspector without touching GDScript. Each character's moveset is exportable.
5. **8-Frame Input Leniency** — Sweet spot: generous enough for casual players, tight enough for precision-play pros. Tunable via `InputBuffer.INPUT_LENIENCY`.
6. **SOCD Resolution** — Left+Right = Neutral, Up+Down = Up (jump priority). FGC standard.

**Why:** "Player Hands First" — InputBuffer is the invisible engineering separating responsive from broken feeling.

---

---

### Lando — Integration Fixes (2025-07-17)
**Author:** Lando  
**Status:** PR Created  
**Scope:** Input & collision domain integration

Fixed integration issues:
1. **Removed Orphaned Throw Inputs** — p1_throw / p2_throw defined in project.godot but never read. Throws use LP+LK simultaneous press (fighter_controller.gd).
2. **Updated Collision Layer Documentation** — ARCHITECTURE.md documented 6-layer scheme never implemented. Updated to reflect actual 4-layer shared scheme in code.
3. **Fixed Stage Collision Layers** — Stage StaticBody2D now on Layer 4 (Stage), fighters detect Layer 4. Was working by accident with default Layer 1.
4. **Input Buffer Configuration Exported** — Converted BUFFER_SIZE, INPUT_LENIENCY, SIMULTANEOUS_WINDOW to @export for runtime Godot Inspector tuning.

**Impact:** Collision detection now explicit. Input buffer easily tunable for playtesting.

---

---

### Jango — GitHub Issues Infrastructure for Ashfall Sprint 0 (2025-07-24)
**Author:** Jango (Tool Engineer)  
**Status:** Implemented  
**Scope:** Ashfall project tracking — affects all agents

GitHub Issues setup as PM backbone for Sprint 0 in jperezdelreal/FirstFrameStudios:

1. **Milestone:** "Ashfall Sprint 0" groups all sprint work
2. **24 Labels:** Structured filtering system:
   - `game:ashfall` — per-game filter (monorepo support)
   - `priority:p0/p1/p2` — critical path tiers
   - `type:feature/infrastructure/art/audio/design/qa` — work categories
   - `squad:{agent}` — 14-agent ownership (one per agent)
3. **13 Issues (#1–#13):** Critical path tasks from SPRINT-0.md with full descriptions

**Why:** Every agent filters by their squad label. Milestone view shows sprint progress. Acceptance criteria self-validate completion. `game:ashfall` label future-proofs for multi-game monorepo.

---

---

### Solo — Integration Audit (2025-07-17)
**Agent:** Solo (Architect)  
**Status:** Completed  
**Verdict:** ⚠️ WARN — Project loads, no launch blockers, but issues need attention

**Autoload Check:** ✅ PASS — All 5 autoloads exist in dependency order (EventBus → GameState → VFXManager → AudioManager → SceneManager). Note: RoundManager exists but not registered as autoload.

**Scene References:** ✅ PASS — All 7 .tscn files have valid ext_resource references. Both .tres resource files valid.

**State Machine:** ✅ PASS — All 8 fighter states exist (Idle, Walk, Crouch, Jump, Attack, Block, Hit, KO). Base class inheritance correct.

**Input Map vs Controller:** ⚠️ WARN — Orphaned `p1_throw` / `p2_throw` in project.godot but never read (throws use LP+LK). Low impact, spec divergence.

**Collision Layers:** ⚠️ WARN — ARCHITECTURE.md documents 6-layer per-player scheme never implemented. Actual code uses 4-layer shared scheme. Alignment needed.

**Null Safety:** ⚠️ WARN — 8 `get_node()` calls without null checks. Should add defensive guards before M3.

**GDD Compliance:** ✅ SPOT CHECK PASS — Ember System, 6-button layout, deterministic simulation verified in code.

---

---

### Mace — Wiki Updates After Milestone Completion (2025-01-20)
**Author:** Mace (Producer)  
**Decision:** GitHub Wiki must be updated within 1 business day after each milestone completion

**Update Scope:**
1. **Home.md** — Milestone summary, completion status, merged PRs by category, infrastructure changes
2. **Ashfall-Sprint-0.md** — New milestone section, issue numbers, PR list, M3/M4 status
3. **Ashfall-Architecture.md** — New systems introduced, API docs, autoload details, scene links
4. **Ashfall-GDD.md** — Implementation notes, mechanics moved to "complete"
5. **Team.md** — Team size changes, review process updates

**Process:**
1. Assign one agent (Mace or Scribe) to wiki update task
2. Clone wiki repo to temp location
3. Update all pages in single commit
4. Push with: `docs: Update wiki for [Milestone Name] completion`
5. Verify wiki renders on GitHub

**Success Criteria:**
- ✅ All 5 pages updated
- ✅ Links correct, cross-references work
- ✅ Commit includes Co-authored-by trailer
- ✅ Push succeeds, wiki reflects changes within 5 minutes

**Owner:** Mace

---

---

### 2025-07-24: Godot Build Pipeline Architecture — Jango (Tool Engineer)

**Status:** Implemented (PR #111)

**Decision:** Automated builds and releases for Ashfall.

**Key Decisions:**

1. **Export Presets Versioned** — Needed for CI/CD (no credentials, only relative paths)
2. **Manual Godot Installation** — wget for Godot 4.6 (explicit version control)
3. **Tag-Triggered Releases** — Push v* tag → automatic build and GitHub Release
4. **Windows Desktop Only** — Initially. Can add Linux/Mac/Web later.
5. **Cross-Compilation on Ubuntu** — Linux runner exports Windows .exe

**Architecture:**
```
Tag push (v0.1.0) → GitHub Actions → Install Godot + templates 
  → Export to .exe → Zip → Create GitHub Release
```

**Deliverables:**
- `games/ashfall/export_presets.cfg` — Windows preset
- `.github/workflows/godot-release.yml` — Build workflow
- Root `.gitignore` updated

**Impact:**
- Developers: Create releases by pushing tag
- Players: Download and play without Godot
- QA: Test via manual workflow dispatch
- Future: Pipeline reusable for other projects

**Testing:** Merge PR #111 → test manual dispatch → create v0.0.1-test tag → validate

---

---

---

---

### Ashfall GDD v1.0 — Creative Foundation (Yoda)
**Author:** Yoda (Game Designer / Vision Keeper)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Ashfall project — all agents building on this game

Game Design Document for Ashfall (`games/ashfall/docs/GDD.md`), a 1v1 fighting game built in Godot 4. The GDD covers vision/pillars, core mechanics, 2 characters, 1 stage, game flow, controls, AI, art direction, audio direction, and scope boundary.

**Key Creative Decisions:**
1. **The Ember System** — Ashfall's signature mechanic. A visible, shared resource that replaces traditional hidden super meter. Both players can see and fight over it.
2. **6-Button Layout** — LP/MP/HP/LK/MK/HK with macro buttons for throw and dash. Street Fighter lineage, not Tekken.
3. **Kael & Rhena** — Balanced shoto vs rushdown. Classic archetype pairing that naturally teaches fighting game fundamentals.
4. **Deterministic Simulation from Day 1** — Fixed 60fps, seeded RNG, input-based state. Enables future rollback netcode without rewrite.
5. **Combo Proration** — Damage scales down per hit in combo (100% → 40% floor). Max combo damage ~35-45% HP.
6. **Scope Boundary** — MVP = 2 characters, 1 stage, local vs, arcade, training. Everything else deferred.

**Impact on Team:** Scene structure and deterministic game loop defined. Frame data and combat system spec ready. AI behavior tree and difficulty parameters defined. All teams have clear design direction.

**Why:** Design translation of founder directive ("1v1 fighting game, 1 stage + 2 characters"). Scope boundary prevents team from building features outside core loop.

---

---

### Ashfall Fighting Game Architecture (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-08-03  
**Status:** Proposed

Technical architecture defined in `games/ashfall/docs/ARCHITECTURE.md`. Key decisions:

1. **Frame-based timing** — Integer frame counters, not float timers. All gameplay in `_physics_process()` at 60 FPS fixed tick.
2. **Node-based state machine** — Each fighter state is separate Node with independent script.
3. **AnimationPlayer as frame data** — Hitbox activation driven by AnimationPlayer tracks (startup/active/recovery frames).
4. **MoveData as Resource** — Moves are `.tres` resource files with frame data, damage, hitstun, knockback. Pure data, no logic.
5. **AI uses input buffer** — AI injects synthetic inputs; same code path as human fighters.
6. **Six collision layers** — P1/P2 hitboxes, hurtboxes, pushboxes on separate layers. No self-hits.
7. **Six parallel work lanes** — File ownership ensures simultaneous work without conflicts.

**Impact:** All agents must read `games/ashfall/docs/ARCHITECTURE.md` before writing Ashfall code. Clear module boundaries enable 6 parallel work streams.

**Why:** Deterministic fighting games require frame-perfect timing. Module separation enables parallel development without cross-dependencies.

---

---

### V2 Animation Consistency Audit (Boba)
**Author:** Boba (Art Director)  
**Date:** 2025-01-27  
**Status:** 🔴 CRITICAL FAILURE

**Executive Summary**

Joaquín's assessment is 100% correct. V2 frames are unusable for animation. Each frame looks like a different character — fundamentally incompatible with frame-by-frame animation which requires consistency between frames.

**V1 Analysis: KAEL IDLE (8 frames)**

| Metric | Score | Notes |
|--------|-------|-------|
| **Character Identity** | 10/10 | Same face, same proportions, same person across all 8 frames |
| **Outfit Consistency** | 10/10 | Identical grey-white gi, dark belt, brown boots, arm wraps |
| **Color Palette** | 10/10 | Exact same hex values frame-to-frame |
| **Pose Readability** | 9/10 | Clear breathing cycle, smooth transitions implied |

**V1 TOTAL: 39/40 — Production-ready**

**V2 Analysis: KAEL (28 frames, 3 rows)**

| Metric | Score | Notes |
|--------|-------|-------|
| **Character Identity** | 2/10 | Different faces, different body types. Frame 1 and Frame 5 are NOT the same person. |
| **Outfit Consistency** | 1/10 | Red gi → green gi → brown gi → purple gi → grey gi. Belt: yellow → orange → purple → red → blue. No two frames match. |
| **Color Palette** | 1/10 | Complete chaos. 7+ different outfit colors in Row 1 alone. |
| **Pose Readability** | 3/10 | Poses exist but you'd never notice them over the color/identity changes |

**V2 KAEL TOTAL: 7/40 — Unusable**

**V2 RHENA TOTAL: 7/40 — Unusable**

**Root Cause Analysis**

The v2 process appears to have:

1. **No reference anchoring** — Each frame generated independently without enforcing the previous frame's appearance
2. **High variation sampling** — The AI model was likely allowed too much creative freedom per-frame
3. **No color palette lock** — Hair, outfit, belt colors re-rolled each generation
4. **No identity preservation** — Face and body treated as "character" concept rather than "this specific character"

**V1 succeeded because:** Likely used stronger reference conditioning or multiple passes with same seed/parameters.

**Impact Assessment**

Can V2 be animated? **NO.** Playing these frames sequentially would create a flickering nightmare.

Can V2 be salvaged? **Maybe partial.** If we cherry-pick only frames that match (maybe 3-4 per character). But honestly? **Start over with v1's methodology.**

**Recommendations**

1. **Immediate:** Abandon v2 approach. Do not invest more time in this direction.
2. **V3 Direction:** Return to v1's methodology. Whatever constraint/conditioning made v1 consistent, restore it.
3. **Process Change:** Before generating 28 frames, generate 3 and verify consistency. Fail fast.
4. **Scope Reduction:** Maybe we don't need 28 frames per animation. V1's 8 frames looked great. Quality > quantity.

---

---

## Key Paths
- Script: `games/ashfall/scripts/test/sprite_poc_test.gd`
- Batch: `games/ashfall/tools/screenshot.bat`
- Output: `games/ashfall/screenshot.png`

# Decision: Mixamo Character Sprite Rendering

**Author:** Chewie (Engine Developer)
**Date:** 2025-07-08
**Status:** COMPLETED

---

## Context

The founder selected two custom Mixamo characters (Kael and Rhena) with real clothing, proportions, and personality — replacing the generic Y-Bot placeholder. These models come with their own materials/textures from Mixamo's character system.

---

## Decision

**Render with original Mixamo materials (no cel-shade override).**

The pipeline previously used `--cel-shade --preset kael/rhena` to apply monochrome toon shading. For these production characters, we tested rendering WITHOUT cel-shade first — letting the model's own skin, clothing, and hair textures come through EEVEE's standard renderer.

**Result: Original materials render cleanly.** The characters look like themselves, with distinct clothing, skin tones, and hair. No need for the cel-shade fallback.

---

## Render Summary

| Character | Animation   | Source FBX     | Frames | Step | Output Directory                    |
|-----------|-------------|----------------|--------|------|-------------------------------------|
| Kael      | Idle        | Idle.fbx       | 30     | 2    | sprites/kael/idle/                  |
| Kael      | Walk        | Walking.fbx    | 16     | 2    | sprites/kael/walk/                  |
| Kael      | Punch       | Punching.fbx   | 13     | 5    | sprites/kael/punch/                 |
| Kael      | Kick        | Side Kick.fbx  | 13     | 5    | sprites/kael/kick/                  |
| Rhena     | Idle        | Idle.fbx       | 106    | 2    | sprites/rhena/idle/                 |
| Rhena     | Walk        | Walking.fbx    | 16     | 2    | sprites/rhena/walk/                 |
| Rhena     | Punch       | Hook Punch.fbx | 14     | 5    | sprites/rhena/punch/                |
| Rhena     | Kick        | Mma Kick.fbx   | 13     | 5    | sprites/rhena/kick/                 |

**Totals:** 221 frames rendered, 8 contact sheets generated.

---

## Notes

- Rhena's idle animation is 106 frames (212 source frames at step=2) — unusually long. May want to trim for in-game use.
- Root motion pinning (mixamorig:Hips X/Y zeroed) worked on all animations — no character drift.
- Renderer: BLENDER_EEVEE (not EEVEE_NEXT), standard 2-light rig (key 3.0 + fill 1.5).
- Contact sheets generated for visual review in each output directory.
- If the art direction later calls for unified cel-shade style, the `--cel-shade --preset` flags remain available.

# Decision: 3D Character Models Downloaded & Tested

**Date:** 2025-07-08  
**Author:** Chewie (Engine)  
**Status:** Results ready for founder review

---

---

## What Happened

Downloaded free CC0 3D character models and ran them through our Blender cel-shade pipeline.

---

### Successfully Downloaded (automated)
| Pack | Source | Characters | Format | Size |
|------|--------|-----------|--------|------|
| **Quaternius RPG Pack** | Google Drive | Monk, Warrior, Rogue, Ranger, Cleric, Wizard + weapons | FBX/Blend/glTF | ~15 MB |
| **Kenney Animated Characters 1-3** | kenney.nl | 3× characterMedium + animations | FBX | ~2 MB |
| **Kenney Mini Characters** | kenney.nl | 12 characters (6M/6F) | FBX/GLB | ~2.3 MB |

All saved to: `games/ashfall/assets/3d/characters/`

---

### Pipeline Test Results

**Quaternius Monk** → **WINNER for Kael base.** Fighting stance with fists raised, chibi proportions, cel-shade looks great. Already animated with combat idle.

**Quaternius Warrior** → Sword character with ponytail and armor. Great silhouette and personality. Animation includes attack sequence.

**Kenney models** → Too generic. Same mannequin problem as Y-Bot. Not recommended.

---

### Test renders at:
- `games/ashfall/assets/sprites/test_quaternius_monk/` (11 frames + contact sheet)
- `games/ashfall/assets/sprites/test_quaternius_warrior/` (15 frames + contact sheet)
- `games/ashfall/assets/sprites/test_kenney_kael_side/` (Kenney with Kael colors)

---

---

## Known Limitations

1. **Monochrome rendering** — Our cel-shade pipeline paints everything one color (Kael orange). Clothes, skin, hair all same tone. Needs per-material color work for production.
2. **Animation framing** — Characters with big motion (jumps, swings) can exit the camera frame. Pipeline auto-fit uses frame-1 bounds only.
3. **Mixamo retargeting needed** — Quaternius models have their own animations (idle/attack), but we need Mixamo martial arts library (punch, kick, walk, etc.) for the full moveset.

---

---

## 30-Second Download Guide (for Joaquin)

---

### Priority 1: More Quaternius Packs (browser)
These have the best fighting-game characters. Open in browser → click "Download" → save ZIP:

1. **Knight Pack** (animated knight with swords/helmets):
   `https://drive.google.com/drive/folders/1QVyfCJkq70mAwMIh1cGq1xfHp2LN5GmK`

2. **Animated Women** (4 female characters with animations):
   `https://drive.google.com/drive/folders/1c13R--fMqdR6r2MRlcKKsbPky0__T-yJ`

3. **Universal Base Characters** (6 models, 3 body types, 20 hairstyles):
   Visit `https://quaternius.itch.io/universal-base-characters` → click "Download" (free)

Save FBX files to: `games/ashfall/assets/3d/characters/`

---

### Priority 2: KayKit Adventurers (browser)
5 rigged/animated dungeon characters with 25+ weapons. CC0 license.
1. Visit `https://kaylousberg.itch.io/kaykit-adventurers`
2. Click "Download" → "No thanks, just take me to the downloads"
3. Download the free ZIP
4. Extract FBX files to `games/ashfall/assets/3d/characters/kaykit-adventurers/`

---

### Priority 3: Mixamo Characters (browser)
Your existing Mixamo account has built-in characters beyond Y-Bot:
1. Go to `https://mixamo.com` → log in
2. Click "Characters" tab (top-left)
3. Try: **Mery** (female), **Big Vegas** (stocky male), **Mutant** (creature)
4. Select any animation → Download as FBX
5. These come pre-rigged — drop directly into pipeline

---

### Test any FBX in pipeline:
```
"C:\Program Files\Blender Foundation\Blender 5.0\blender.exe" --background --python games/ashfall/tools/blender_sprite_render.py -- --input YOUR_MODEL.fbx --output games/ashfall/assets/sprites/test_output/ --character test --animation idle --size 512 --step 2 --cel-shade --preset kael --outline --contact-sheet
```

---

---

## Recommendation

**Use Quaternius Monk as Kael's base mesh.** It's already in the repo, already renders through our pipeline, has a fighting stance, and the chibi proportions give it character. Upload to Mixamo for the full martial arts animation set, then customize colors in Blender.

For Rhena, download the Quaternius Animated Women pack or KayKit Adventurers — both have female warrior characters that could work as a base.

# Sprite Pipeline V2 — Root Motion Pinning & Animation-Aware Stepping

**Author:** Chewie (Engine Developer)  
**Date:** 2025-07-23  
**Status:** Implemented  
**Scope:** Ashfall sprite rendering pipeline (`blender_sprite_render.py`)

---

## Changes Made

---

### 1. Tighter Camera Framing
- Ortho scale padding: **1.1× → 1.03×** of model bounds
- Character now fills ~97% of the 512×512 frame vs ~90% before
- Still auto-fits; `--ortho-scale` CLI override still available

---

### 2. Root Motion Pinning (NEW)
- Mixamo animations bake root motion into `mixamorig:Hips` bone
- New `pin_root_motion()` zeros X/Y translation each frame, keeps Z + rotations
- Runs after `frame_set()`, before `render()` — character stays centered
- Auto-detects root bone with fallback chain: mixamorig:Hips → Hips → Root → first parentless bone

---

### 3. Animation-Aware Frame Stepping (NEW)
- `ANIM_STEP_HINTS` dict maps animation keywords to optimal steps
- Attacks (punch/kick/heavy/special): **step=5** → ~13 frames (was 31 with step=2)
- Loops (idle/walk/run): **step=2** → 16-17 frames (unchanged)
- Auto-applied via `get_smart_step()`; user `--step` still works as override
- Key metric met: **no attack exceeds 15 frames**

---

## Frame Count Summary
| Animation | Old Frames | New Frames | At 15fps |
|-----------|-----------|------------|----------|
| idle      | 17        | 17         | 1.13s    |
| walk      | 16        | 16         | 1.07s    |
| punch     | 31        | 13         | 0.87s    |
| kick      | 31        | 13         | 0.87s    |

---

*Solo — Lead / Chief Architect, First Frame Studios*

# Decision: Sprite Test Viewer Updated for Cel-Shade Sprites

**Author:** Wedge (UI Dev)
**Date:** 2025-01-XX
**File:** `games/ashfall/scripts/test/sprite_poc_test.gd`

---

## What changed

Updated the test viewer to load cel-shade rendered sprites from the new directory structure (`res://assets/sprites/kael/` and `res://assets/sprites/rhena/`) instead of the outdated `res://assets/poc/v2/` path.

---

## Key decisions

1. **Auto-detect frame count** — Instead of hardcoding frame counts per animation, the viewer now loads frames sequentially (0000, 0001, ...) until a file is missing. This means new renders with different frame counts just work without code changes.

2. **Frame rate: 12fps loops, 15fps attacks** — Idle/walk use 12fps for a smooth but readable loop. Punch/kick use 15fps for snappier attack feel. These are standard fighting game rates.

3. **Replaced "lp" animation with punch/kick** — Old viewer had 3 anims (idle, walk, lp). New viewer has 4 (idle, walk, punch, kick) mapped to keys 1-4. K/R keys are now character-only (no longer doubled on 4/5).

4. **Background path changed to v1** — The `embergrounds_bg.png` only exists in `assets/poc/v1/`, not v2. Pointed the viewer there. This is still a placeholder BG — will need a proper stage asset eventually.

5. **Contact sheets ignored** — Each animation dir contains a `_sheet.png` contact sheet. The auto-detect loop naturally skips these since they don't match the `_NNNN.png` naming pattern.


---

---

# === ARCHIVED FROM decisions.md (2026-03-12) ===

# Squad Decisions

---

## Active Decisions

---

### New Project Playbook Created (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Studio-wide — affects how every future project starts

Created `.squad/identity/new-project-playbook.md` — the definitive, repeatable process for starting any new project at First Frame Studios, regardless of genre, tech stack, IP, or platform.

**What It Contains:**
1. **Pre-Production Phase** — Genre research protocol (7-12 reference games, analytical play, skill extraction), IP assessment (original vs licensed), 9-dimension tech selection framework, team skill transfer audit, competitive analysis
2. **Sprint 0 Foundation** — Engine-agnostic repo checklist, squad adaptation guide, genre skill creation, architecture proposal requirements, minimum playable formula per genre, quality gates adaptation
3. **Production Phases** — P0-P3 priority system, parallel lane planning, skill capture rhythm, cross-project knowledge transfer
4. **Technology Transition Checklist** — What transfers/rewrites/needs evaluation, migration mapping (Canvas→Godot as template), repeatable training protocol
5. **Language/Stack Flexibility Matrix** — 12 tech stacks compared, T-shirt migration sizing, the 70/30 rule (70% of our effectiveness is tech-agnostic)
6. **Anti-Bottleneck Patterns** — 7 firstPunch bottlenecks with preventions, 6 common studio patterns, serialize/parallelize guide, add-role vs add-skill decision matrix

**Key Decisions Within:**
- **8-point migration threshold:** Require 8+ point lead in 9-dimension matrix to justify engine migration
- **20% load cap:** No agent carries more than 20% of any phase's items
- **Module boundaries in Sprint 0:** Architecture proposal required before Phase 2 code begins
- **Wiring requirement:** Every infrastructure PR must include connection to at least one consumer

**Why:** The founder wants solid foundations so starting any new project is clear, repeatable, and bottleneck-free. firstPunch taught us everything in this playbook through real bugs, real bottlenecks, and real breakthroughs. Documenting it ensures we never repeat the investigation.

**Impact:**
- Every future project follows this playbook from Day 1
- Pre-production becomes a structured process, not ad-hoc discovery
- Technology transitions follow a proven 4-phase pattern
- Bottleneck patterns are identified and mitigated proactively
- New team members can read this document and understand how we start projects

---

### Skills System Needs Structural Investment Before Next Project (Ackbar)
**Author:** Ackbar (QA Lead)  
**Date:** 2025-07-21  
**Status:** Proposed

Conducted comprehensive audit of all 12 skills in `.squad/skills/`. Quality of individual skills is strong (7/12 rated ⭐⭐⭐⭐+), but coverage (5/10) and growth-readiness (4/10) are the weaknesses.

**Decision:**
Three actions should be taken before the next project kicks off:

1. **Create `game-feel-juice` skill (P0)** — Our #1 principle ("Player Hands First") has no dedicated skill. Game feel patterns are scattered across 3 skills. A unified, engine-agnostic game feel reference should be the first skill any new agent reads. Assign to Yoda + Lando.

2. **Create `ui-ux-patterns` skill (P1)** — Wedge is a domain owner with zero skills. Every game needs UI. This is the largest single-agent gap on the team. Assign to Wedge.

3. **Structural cleanup (P1)** — Split `godot-beat-em-up-patterns` (39KB, too large). Resolve overlaps: merge `canvas-2d-optimization` into `web-game-engine`, deduplicate `godot-tooling` vs `project-conventions`. Assign to Solo + Chewie.

**Impact:**
- **Yoda, Lando:** Create `game-feel-juice` skill
- **Wedge:** Create `ui-ux-patterns` skill  
- **Solo, Chewie:** Structural cleanup of overlapping skills
- **All agents:** 6 skills should have confidence bumped from `low` to `medium`
- **Full audit:** `.squad/analysis/skills-audit.md` contains per-skill ratings, gap analysis, and improvement recommendations

---

# Decision: Flora Core Engine Architecture

**Date:** 2025-07-16  
**Author:** Chewie (Engine Developer)  
**Issue:** #3 — Core Game Loop and Scene Manager Integration  
**Status:** ✅ Implemented (PR #13)  
**Repo:** jperezdelreal/flora

---

## Context

Flora needed foundational engine infrastructure before any gameplay could be built. The scaffold provided stubs for SceneManager and EventBus but no game loop, input handling, or asset loading.

---

## Decisions

---

### 1. Fixed-Timestep Game Loop (Accumulator Pattern)
- GameLoop wraps PixiJS Ticker but steps in fixed 1/60s increments via time accumulator
- Max 4 fixed steps per frame prevents spiral of death on lag spikes
- Provides `frameCount` for deterministic logic and `alpha` for render interpolation
- **Rationale:** Deterministic state updates enable future save/replay/netcode. Variable-delta game logic causes desync bugs.

---

### 2. SceneContext Injection (No Global Singletons)
- Scenes receive `SceneContext = { app, sceneManager, input, assets }` in `init()` and `update()`
- No global `window.game` or singleton pattern
- **Rationale:** Explicit dependencies are testable, refactorable, and don't create hidden coupling.

---

### 3. Input Edge Detection Per Fixed Step
- `InputManager.endFrame()` clears pressed/released sets after each fixed-step update
- Raw key state persists across frames; edges are consumed once
- **Rationale:** Variable frame rates can cause missed inputs if edges are cleared per render frame instead of per logic step.

---

### 4. Scene Transitions via Graphics Overlay
- Fade-to-black using a Graphics rectangle with animated alpha (ease-in-out)
- No render-to-texture or extra framebuffers
- **Rationale:** Simple, GPU-efficient, works on all PixiJS backends (WebGL, WebGPU, Canvas).

---

## Alternatives Rejected
1. **Raw Ticker.deltaTime for game logic** — Non-deterministic, causes physics/timing bugs
2. **Global singleton for input/assets** — Hidden dependencies, harder to test
3. **CSS transitions for scene fades** — Breaks when canvas is fullscreen, not composable with game rendering


---

---

## Decision: Game Vision & Design Document

**Author:** Yoda (Game Designer)  
**Date:** 2025  
**Type:** Design Authority  
**Status:** Proposed  
**Artifact:** `.squad/analysis/game-design-document.md`

---

---

### Summary

Created the comprehensive Game Design Document (GDD) for firstPunch — the team's north star for all design and implementation decisions.

---

### Key Decisions

#### Vision
firstPunch is a browser-based game beat 'em up where comedy IS the combat. Players should laugh, feel powerful, and immediately want to try the next character. Instant-play browser design means zero friction, 5-7 minute levels, and session-friendly pacing.

#### Four Design Pillars
1. **Comedy as a Core Mechanic** — Humor is in the gameplay systems (taunts, Ugh! moments, game-rated combo meter), not just cosmetic.
2. **Accessible Depth** — Button-mashers have fun; combo masters have a different kind of fun. Streets of Rage 4 principle.
3. **Team Synergy** — Co-op mechanics reward playing as the team together (team attacks, proximity buffs, team super).
4. **Downtown Is a Character** — Environments are interactive playgrounds with landmark gags, destructibles, and hazards.

#### Core Combat
- **PPK combo** as the bread-and-butter (42 damage/1.1s)
- **Health-cost specials** with recovery-by-attacking (SoR2/SoR4 model)
- **Grab/throw system** (Turtles in Time influence)
- **Dodge roll with i-frames** (modern standard)
- **Super meter** filled by damage and taunts
- **Jump attacks rebalanced** with landing lag to prevent air-spam dominance (balance analysis finding)

#### Characters (4 planned, Brawler first)
- Brawler: Power/All-Rounder, Rage Mode, Belly Bounce
- Kid: Speed, Skateboard Dash, Slingshot ranged, alter-ego super
- Defender: Range, Purse Swing, Hair Whip, Maternal Instinct passive
- Prodigy: Technical/CC, Saxophone Blast, Intellect Advantage dodge, Activist Rally super

#### game-Specific Mechanics
- **Rage Mode** (eat 3 donuts → Brawler power-up, creates heal vs. rage dilemma)
- **Ugh! Moments** (funny failure states at every level)
- **Couch Gag loading screens** (randomized, collectible transitions)
- **Downtown landmarks** as interactive combat elements
- **game food** as themed health pickups (Pink Donut, Burger Joint, Fire Cocktail)
- **Combat barks** (character quotes on gameplay events)

#### Balance Integration
Incorporated all 6 critical and 3 medium balance flags from Ackbar's analysis:
- Jump attack DPS capped at 38 (down from 50) via landing lag
- Enemy damage targets raised (8 base, up from 5)
- 2-attacker throttle as design principle, not performance compromise
- Knockback tuning to preserve PPK combo viability

#### Platform Constraints
Documented Canvas 2D limitations and "Future: Native/Engine Migration" items (shaders, skeletal animation, online multiplayer, advanced physics).

---

### Impact
Every team member now has a single reference for "what are we building and why." Design authority calls prevent scope creep and ensure coherence.

---

---

## High Score localStorage Key & Save Strategy

**Author:** Wedge  
**Date:** 2025-01-01  
**Status:** Implemented  
**Scope:** P0-1 — High Score Persistence

---

### Decision

- localStorage key is `firstPunch_highScore` — namespaced to avoid collisions if other games share the domain.
- High score is saved at the moment `gameOver` or `levelComplete` is triggered, not continuously during gameplay. A `highScoreSaved` flag prevents duplicate writes.
- `saveHighScore()` returns a boolean so the renderer can show "NEW HIGH SCORE!" vs the existing value — no extra localStorage read needed in the render loop for that decision.
- All localStorage access is wrapped in try/catch to gracefully handle private browsing or disabled storage (falls back to 0).
- Title screen only shows the high score label when value > 0, keeping a clean first-play experience.

---

### Why

- Single save point is simpler and avoids unnecessary writes during gameplay.
- Boolean return from save avoids coupling render logic to storage checks.
- Graceful fallback means the game never crashes due to storage restrictions.

---

---

## AudioContext Resume Pattern

**Author:** Greedo  
**Date:** 2025-06-04  
**Status:** Implemented

---

### Context
Web Audio API requires a user gesture before AudioContext can produce sound. The previous code created the context eagerly in the constructor, meaning audio could silently fail on first load in Chrome, Safari, and Firefox.

---

### Decision
- AudioContext is still created in the constructor (so `currentTime` etc. are available immediately)
- A `resume()` method checks `context.state === 'suspended'` and calls `context.resume()`
- `main.js` registers a one-time `keydown`/`click` listener that calls `audio.resume()` and removes itself
- All existing `playX()` methods continue to work without changes — they just produce no sound until the context is resumed

---

### Why
- Transparent fix: zero changes to any caller code
- One-time listener self-removes to avoid unnecessary event handling
- Works across all modern browsers (Chrome, Firefox, Safari, Edge)
- The title screen requires ENTER to start, so audio is always resumed before gameplay begins

---

### Trade-offs
- If a caller tries to play sound before any user interaction, it silently does nothing (acceptable — matches browser behavior)
- Could alternatively lazy-create the context on first `resume()`, but that would delay `currentTime` baseline — not worth the complexity

---

---

### Full Details

See `.squad/analysis/backlog-expansion.md` for complete item list, re-assignment tables, and load analysis.

# Decision Proposal: Rendering Technology

**From:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Priority:** High  
**Status:** Proposed

---

## Summary

Researched 5 rendering technology options to address the "cutre" (cheap-looking) graphics feedback. Full analysis in `.squad/analysis/rendering-tech-research.md`.

---

## Current Problem

- No HiDPI/Retina support → blurry text and shapes on modern displays
- ~100 canvas API calls per entity per frame → no headroom for richer art
- No GPU effects → flat, unpolished look (no glow, blur, bloom)
- Fixed 1280×720 → doesn't scale to larger screens

---

## Recommendation: Two-Phase Approach

---

### Phase 1 — Canvas 2D Optimization (NOW, 8-12 hours, zero risk)
1. **HiDPI fix** — scale canvas by `devicePixelRatio`. Fixes blurry signs immediately.
2. **Sprite caching** — pre-render entities to offscreen canvases, `drawImage()` each frame. 10× perf gain.
3. **Resolution-independent design** — internal 1920×1080, scale to any screen.

---

### Phase 2 — Hybrid Canvas + PixiJS (LATER, 23-35 hours, if Phase 1 isn't enough)
- Add PixiJS via CDN UMD (no build step needed)
- Keep procedural Canvas drawing → convert to PixiJS textures
- GPU filters for bloom, glow, distortion effects
- PixiJS ParticleContainer for particle storms

---

### Rejected Options
- **Full PixiJS rewrite** — similar cost to hybrid but loses procedural drawing flexibility
- **Phaser** — 50-74h rewrite, replaces working systems we've built, 1.2MB bundle
- **Three.js** — overkill for 2D, 80+h rewrite

---

## Impact
Phase 1 alone should transform the visual quality from "cutre" to "polished indie." Phase 2 adds AAA-level GPU effects if needed.

---

## Decision Needed
Approve Phase 1 implementation (HiDPI + sprite caching + resolution scaling). Phase 2 deferred until we evaluate Phase 1 results.



---

---

# Decision Inbox: Tech Ambition Evaluation

**From:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Priority:** P0 — Strategic Direction  
**Status:** Proposal — Awaiting Team Discussion

---

---

## Summary

Evaluated 5 engine options across 9 dimensions for the next project ("nos jugamos todo"). Full analysis in `.squad/analysis/next-project-tech-evaluation.md`.

---

## Recommendation: Godot 4

**Phaser 3 is a good engine. Godot 4 is the right weapon for the fight we're picking.**

---

### Why Not Phaser
- Web-only limits us to itch.io — no Steam, no mobile, no console
- Every award-winning beat 'em up ships native. Zero browser-only games in the competitive set.
- We'd lose our procedural audio system (931 LOC) — Phaser is file-based only
- Visual ceiling: 8.5/10 vs Godot's 9.5/10
- Performance ceiling: browser JS GC vs native binary

---

### Why Godot
- **Multi-platform:** Web + Desktop + Mobile + Console (via W4) from one codebase
- **2D is first-class:** Not a 3D engine with 2D bolted on (unlike Unity)
- **Free forever:** MIT license, no pricing surprises, no runtime fees
- **Our knowledge transfers:** Fixed timestep → `_physics_process`, event bus → signals, audio bus → AudioBus system, hitlag → `Engine.time_scale`. Concepts transfer, only syntax changes.
- **Procedural audio survives:** `AudioStreamGenerator` provides raw PCM buffer for Greedo's synthesis work
- **Built-in tools accelerate squad:** Animation editor, particle designer, shader editor, tilemap editor, debugger, profiler — every specialist gets real tools
- **Community exploding:** 100K+ GitHub stars, fastest-growing engine, backed by W4 Games

---

### Why Not Unity
- C# learning curve (2-3 months vs GDScript's 2-3 weeks)
- Heavy editor, slow iteration
- Pricing trust eroded
- Scene merge conflicts with 12-person squad

---

### The Score
| Engine | Total (9 dimensions) |
|--------|---------------------|
| **Godot 4** | **74/90** |
| Phaser 3 | 66/90 |
| Unity | 66/90 |
| Defold | 57/90 |

---

### Cost
- 2-3 week learning sprint before production velocity matches current level
- GDScript ramp-up (Python-like, approachable for JS devs)
- firstPunch engine code (1,931 LOC) doesn't transfer — but all architectural knowledge does

---

### Action Needed
- Squad discussion on engine choice
- If approved: 2-week learning sprint → 2-week prototype → production

—Chewie


---

---

# Decision: Evaluate 2 Proposed New Roles for Godot Transition

**Author:** Solo (Lead)
**Date:** 2025-07-22
**Status:** Recommendation
**Requested by:** joperezd

---

---

## Context

The team is transitioning from a vanilla HTML/Canvas/JS stack to Godot 4 for future projects. Two new roles are proposed: **Chief Architect** and **Tool Engineer**. The current squad is at 12/12 OT Star Wars character capacity (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien) plus Scribe and Ralph as support. This evaluation assesses whether these roles are genuinely new or absorbable into existing charters.

---

---

## 1. Does Solo Already Cover Chief Architect?

---

### Current Solo Charter
Solo's charter explicitly states:
- "Project architecture and structure decisions"
- "Code review and integration oversight"
- "Ensuring modules work together correctly"
- "Makes final call on architectural trade-offs"

---

### What Chief Architect Would Own
- Repo structure, game architecture, conventions
- Scene tree design, node hierarchy standards
- Code style guide, naming conventions
- Integration patterns (how modules connect)
- Reviews architecture decisions

---

### Overlap Analysis: **~80% overlap.**

Solo already owns architecture decisions, integration patterns, and code review. The skill assessment (Session 9) rates Solo as "Proficient" with strongest skill being "Strategic analysis and workload distribution." The architectural work Solo did — gameplay.js decomposition, CONFIG extraction, camera/wave-manager/background extraction — is exactly what a Chief Architect would do.

---

### What's Genuinely New
The ~20% that doesn't cleanly fit Solo today:
1. **Godot-specific scene tree design** — This is domain knowledge Solo doesn't have yet. But it's a *learning gap*, not a *role gap*. Solo will learn Godot's scene/node model the same way Solo learned Canvas 2D architecture.
2. **Code style guide / naming conventions** — This was identified as a gap: the `project-conventions` skill is an empty template (Low confidence, zero content). But writing a style guide is a one-time task, not a full-time role.
3. **Formal architecture reviews** — Solo does this informally. A Godot project with 12 agents would benefit from explicit review gates. But this is a *process improvement* for Solo's charter, not a new person.

---

### Verdict: **Do NOT create Chief Architect. Expand Solo's charter.**

**Rationale:** Splitting architectural authority creates a coordination problem worse than any it solves. Who has final say — Solo or Chief Architect? If Chief Architect overrides Solo on architecture, Solo becomes a project manager without teeth. If Solo overrides Chief Architect, the role is advisory and agents will learn to route around it. One voice on architecture is better than two voices that might disagree.

**What to do instead:**
- Add to Solo's charter: "Owns Godot scene tree conventions, node hierarchy standards, and code style guide"
- Solo's first Godot task: produce the architecture document (repo structure, scene tree patterns, naming conventions, signal conventions) *before* any agent writes code
- Fill the `project-conventions` skill with Godot-specific content (currently an empty template — this is the right vehicle)
- Add explicit architecture review gates to the squad workflow (Solo reviews scene tree structure on first PR from each agent)

---

---

## 2. Does Chewie Already Cover Tool Engineer?

---

### Current Chewie Charter
Chewie's charter states:
- "Game loop with fixed timestep at 60 FPS"
- "Canvas renderer with camera support"
- "Keyboard input handling system"
- "Web Audio API for sound effects"
- "Core engine architecture"
- "Owns: src/engine/ directory"

---

### What Tool Engineer Would Own
- Project structure in Godot (scene templates, base classes)
- Editor tools/plugins for the team
- Pipeline automation (asset import, build scripts)
- Scaffolding that prevents architectural mistakes
- Facilitating other agents' work

---

### Overlap Analysis: **~40% overlap.**

Chewie is an **engine developer** — builds runtime systems that the game uses at play-time. Tool Engineer builds **development-time** systems that *agents* use while working. These are fundamentally different audiences and different execution contexts.

| Dimension | Chewie (Engine Dev) | Tool Engineer |
|-----------|-------------------|---------------|
| **Audience** | The game (runtime) | The developers (dev-time) |
| **Output** | Game systems (physics, rendering, audio) | Templates, plugins, scripts, pipelines |
| **When it runs** | During gameplay | During development |
| **Godot equivalent** | Writing custom nodes, shaders, game systems | Writing EditorPlugins, export presets, GDScript templates |
| **Success metric** | Game runs well | Agents are productive and consistent |

---

### What Chewie Already Does That's Tool-Adjacent
- Chewie did create reusable infrastructure: SpriteCache, AnimationController, EventBus (though none were wired — Session 8 finding)
- Chewie's integration passes (FIP, AAA) were essentially tooling work — connecting systems together
- Chewie wrote the `web-game-engine` skill document — documentation that helps other agents

---

### What's Genuinely New in Godot
Godot creates significantly more tooling surface area than vanilla JS:
1. **EditorPlugin API** — Godot has a full plugin system for extending the editor. Custom inspectors, dock panels, import plugins, gizmos. This is a distinct skillset from game engine coding.
2. **Scene templates / inherited scenes** — Godot's scene inheritance model means base scenes need careful design. A bad base scene propagates mistakes to every child. This is architectural scaffolding work.
3. **Asset import pipelines** — Godot's import system (reimport settings, resource presets, `.import` files) needs configuration. Sprite atlases, audio bus presets, input map exports.
4. **GDScript code generation** — Template scripts for common patterns (state machines, enemy base class, UI panel base) that agents instantiate rather than write from scratch.
5. **Build/export automation** — Export presets, CI/CD for Godot builds, platform-specific settings.
6. **Project.godot management** — Autoload singletons, input map, layer names, physics settings. One wrong edit breaks everyone.

---

### Verdict: **YES, create Tool Engineer. This is a distinct role.**

**Rationale:** The overlap with Chewie is only ~40%, and critically, it's the wrong 40%. Chewie's strength is runtime systems — the skill assessment rates Chewie as "Expert" in "System integration and engine architecture." Tool Engineer is about *development-time* productivity. Asking Chewie to also write EditorPlugins, manage import pipelines, and create scaffolding templates would split Chewie's focus between two fundamentally different jobs: making the game work vs. making the team work.

**The lesson from firstPunch proves this:** The #1 technical debt finding (Session 8) was "214 LOC of unused infrastructure — working systems that aren't wired into anything." The multi-agent-coordination skill (Session 10) identified the core pattern: "agents build infrastructure but don't wire it." A Tool Engineer's explicit job would be closing this gap — building the scaffolding, templates, and automation that ensure new code arrives pre-wired.

---

---

## 3. Godot-Specific Needs Assessment

---

### Does Godot's Architecture Justify a Dedicated Tooling Role?

**Yes, and here's why it's MORE needed than in vanilla JS:**

In our Canvas/JS project, there was no editor, no import system, no scene tree, no project file, no plugin API. The "tooling" was just file organization and conventions. Godot introduces 5 entire systems that need tooling attention:

| Godot System | Tooling Work Required | Comparable JS Work |
|-------------|----------------------|-------------------|
| Scene tree + inheritance | Base scene design, node hierarchy templates, inherited scene conventions | None (we had flat file imports) |
| EditorPlugin API | Custom inspector panels, validation tools, asset preview widgets | None (no editor) |
| Resource system | .tres/.res management, resource presets, custom resource types | None (all inline) |
| Signal system | Signal naming conventions, connection patterns, signal bus architecture | We built EventBus (49 LOC) but never used it |
| Export/build system | Export presets, CI/CD, platform configs, feature flags | None (no build step) |

**Conservative estimate:** 15-25 tooling items in the first Godot project, ongoing maintenance as game scope grows. That's a full role's worth of work, comparable to Tarkin's content workload (18 items in firstPunch).

---

### Godot's Scene-Signal Architecture Creates Unique Coordination Challenges

In vanilla JS, a bad import path fails loudly at runtime. In Godot, a bad signal connection or incorrect node path fails *silently* — the signal just doesn't fire, the node reference returns null. Tool Engineer can build editor validation plugins that catch these at edit-time, before agents commit broken connections.

---

---

## 4. Team Size: 12/12 → 13 (Overflow Handling)

---

### Current Roster (12 OT Characters)
Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien

---

### Adding 1 New Role → 13 Characters
Since we're only recommending Tool Engineer (not Chief Architect), we need 1 new character, not 2.

---

### Options for the 13th Character

**Option A: Prequel character**
Use a prequel-era character: Qui-Gon, Mace, Padmé, Jango, Maul, Dooku, Grievous, Rex, Ahsoka, etc.

**Option B: Extended OT universe**
Characters from OT-adjacent media: Thrawn, Mara Jade, Kyle Katarn, Dash Rendar, etc.

**Option C: Rogue One / Solo film characters**
K-2SO, Chirrut, Jyn, Cassian, Qi'ra, Beckett, L3-37, etc.

---

### Recommendation: **Prequel is fine. Go with it.**

The Star Wars naming convention is a fun team identity feature, not a hard constraint. One prequel character doesn't break the theme. The convention already bent with Scribe and Ralph (non-Star Wars support roles).

**Suggested name: K-2SO** — the reprogrammed droid from Rogue One. Fitting for a Tool Engineer: originally built for one purpose, reprogrammed to serve the team. Technically OT-era (Rogue One is set immediately before A New Hope). Alternatively, **Lobot** — Lando's cyborg aide from Cloud City, literally an augmented assistant, pure OT.

---

---

## 5. Alternative: Absorb Into Existing Roles?

---

### Chief Architect → Absorbed into Solo ✅

This is straightforward. Solo's charter already covers 80% of this. The remaining 20% (Godot conventions, style guide, formal review gates) is a charter expansion, not a new person. Solo should:
1. Write the Godot architecture document as Sprint 0 deliverable
2. Fill the `project-conventions` skill with Godot-specific content
3. Add architecture review gates to the workflow

---

### Tool Engineer → NOT absorbable ❌

We evaluated 3 absorption candidates:

**Chewie?** No. Chewie is a runtime systems expert. EditorPlugins, import pipelines, and scaffolding templates are development-time concerns. Splitting Chewie's focus would degrade both game engine quality AND tooling quality. The skill assessment rates Chewie as the team's only Expert-level engineer — don't dilute that.

**Solo?** No. Solo is already the planning/coordination bottleneck. Adding hands-on tooling work would mean either slower planning cycles or rushed tools. Solo's weakness is already "follow-through on integration" (CONFIG.js never wired in). Adding more implementation to Solo's plate makes this worse.

**Yoda (Game Designer)?** No. Yoda defines *what* the game should be, not *how* the development environment works. Completely different domain.

**Distribute across all agents?** No. This is exactly the pattern that produced 214 LOC of unused infrastructure in firstPunch. When everyone is responsible for tooling, nobody is responsible for tooling. The multi-agent-coordination skill explicitly warns against this.

---

---

## Summary of Recommendations

| Proposed Role | Verdict | Action |
|--------------|---------|--------|
| **Chief Architect** | ❌ **Do NOT create** | Expand Solo's charter with Godot architecture responsibilities. Fill `project-conventions` skill. Add review gates. |
| **Tool Engineer** | ✅ **CREATE** | New role with distinct charter. Owns EditorPlugins, scene templates, import pipelines, scaffolding, build automation. Suggested name: Lobot or K-2SO. |

---

### Charter Draft for Tool Engineer

```

---

## Role
Tool Engineer for [Godot Project].

---

## Responsibilities
- Godot project structure setup and maintenance (project.godot, autoloads, layers)
- Scene templates and inherited scenes for common patterns
- Base class scripts (state machine, enemy base, UI panel base)
- EditorPlugin development (custom inspectors, validation tools, asset previews)
- Asset import pipeline configuration (sprite atlases, audio presets, resource types)
- Build/export automation and CI/CD pipeline
- Scaffolding tools that enforce architectural conventions
- Integration validation — ensuring agent work connects correctly

---

## Boundaries
- Owns: addons/ directory, project.godot configuration, export presets
- Creates templates that other agents instantiate
- Does NOT implement game logic, art, or audio — builds tools for those who do
- Coordinates with Solo on architectural standards (Solo defines WHAT, Tool Engineer builds HOW to enforce it)

---

## Model
Preferred: auto

---

---

## Decision: Kael FLUX Sprite PoC — Art Director Review

# Kael FLUX Sprite PoC — Art Director Review

**Reviewer:** Boba (Art Director)  
**Date:** 2025-07-22  
**Assets Reviewed:**  
- `games/ashfall/assets/poc/contact_idle.png` — 8 idle frames  
- `games/ashfall/assets/poc/contact_walk.png` — 8 walk frames  
- `games/ashfall/assets/poc/contact_lp.png` — 12 LP frames  

---

---

## 1. IDLE (8 frames)

| Criteria | Assessment |
|----------|------------|
| **Consistency** | ⚠️ Moderate issues. Skin tone varies (frames 4-5 warmer/more saturated than 1-3, 6-8). Arm wrap visibility shifts between frames. Overall proportions stable. |
| **Motion Flow** | ✅ Subtle breathing motion reads well. Good fighting game idle loop feel. |
| **Silhouette** | ✅ Strong. Guard stance clear, fists visible, head distinct from body. |
| **Background Removal** | ✅ Clean transparency, no visible halos or artifacts. |
| **Known Fix Check** | ❌ **FAIL: Kael is wearing brown boots/shoes** in all 8 frames. GDD specifies barefoot fire monk. This was flagged as a required fix. |

---

### VERDICT: **NEEDS WORK**
- **Blocker:** Regenerate barefoot. The boots break character identity.
- Minor: Color-correct skin tones for consistency across frames.

---

---

## 2. WALK (8 frames)

| Criteria | Assessment |
|----------|------------|
| **Consistency** | ✅ Good. All frames same character. Warm orange skin tone consistent. Sandal wraps match throughout. |
| **Motion Flow** | ⚠️ **Problem: Legs don't alternate.** Frames show subtle weight shift/bobbing but both legs stay mostly in same position. This will read as "bouncing in place" not "walking forward." |
| **Silhouette** | ✅ Clear guard stance silhouette maintained. Good fighting game readability. |
| **Background Removal** | ✅ Clean cuts, transparent background intact. |
| **Known Fix Check** | ✅ Barefoot with proper sandal wraps. ❌ Legs do NOT alternate as required. |

---

### VERDICT: **NEEDS WORK**
- **Blocker:** Walk cycle needs actual leg alternation. Current frames are more of a "bounce idle" than a walk.
- Positive: Footwear correct on this set (sandals/barefoot look).

---

---

## 3. LP — Light Punch (12 frames)

| Criteria | Assessment |
|----------|------------|
| **Consistency** | ❌ **SEVERE inconsistency.** Frames 1-6 and 7-12 look like two different characters. |
|  | • Frames 1-6: Pale skin, brown boots, taller/leaner proportions, realistic style |
|  | • Frames 7-12: Warm orange skin, sandals, stockier proportions, more stylized |
| **Motion Flow** | ⚠️ Within each row, motion is okay. Frame 4-5-6 show fire ember effect (good fire monk identity). Frames 7-12 show recovery to guard. But the jarring style break at frame 7 destroys readability. |
| **Silhouette** | ✅ Punch extension clear in both styles. Attack readable. |
| **Background Removal** | ✅ Clean on all frames. |
| **Known Fix Check** | ⚠️ Partial. Frames 7-12 are barefoot ✅, show recovery to guard ✅. But frames 1-6 still have boots ❌. |

---

### VERDICT: **FAIL**
- **Blocker:** Two completely different character styles spliced together. Cannot ship this.
- The fire ember effect on extended fist (frames 4-6) is actually great — keep that concept.
- Regenerate entire LP sequence with consistent character model matching the Walk sandal style.

---

---

## OVERALL PoC VERDICT: **NEEDS WORK**

---

### Summary
FLUX can produce quality fighting game sprites — the Walk set proves this. But the AI is generating inconsistent character interpretations across prompts. The IDLE and LP sets have boot/barefoot violations, and LP has a catastrophic style break mid-animation.

---

### Actionable Next Steps

1. **Standardize the reference.** Pick the Walk frames (7-12 of LP also match) as the canonical Kael look: warm orange skin, sandal wraps, stockier martial artist proportions.

2. **Regenerate IDLE** with explicit barefoot/sandal prompt, using Walk frames as img2img reference if FLUX supports it.

3. **Regenerate LP frames 1-6** to match the style of frames 7-12. The recovery half is good; the startup/active half is wrong.

4. **Walk leg alternation** — either regenerate with better motion description, or manually reorder/flip frames to create proper alternation.

5. **Color consistency pass.** When all sets are regenerated, do a final color grade to lock skin tone, gi color, and wrap color across all animations.

---

### What's Working
- Background removal (rembg) is excellent — clean transparency throughout
- Fighting game silhouettes are clear and readable
- Fire monk identity comes through when prompted correctly (ember effect on LP)
- The "correct" Kael (Walk, LP 7-12) has good martial artist energy

---

### Recommendation
Do NOT proceed to full animation set production until barefoot + consistent style is locked. One more PoC iteration with tighter prompting should get us there. Consider creating a Kael reference sheet PNG that gets fed into every generation prompt.

---

---

*— Boba, Art Director*


---

---

## Decision: PoC Art Sprint — Founder Verdict

---

## Decision: AI Sprite Background Generation Research

# AI Sprite Background Generation Research
**Researcher:** Boba (Art Director)  
**Date:** 2025  
**Objective:** Determine best approach for AI-generated fighting game sprite backgrounds

---

---

## Executive Summary

After researching industry practices, academic literature, and available technologies, we have **four viable options** for background handling in our FLUX-based sprite pipeline. The current approach (green chroma key) is **industry-standard and proven**, but emerging alternatives offer quality improvements with proper setup.

**Primary Recommendation:** Continue with **Option A (Green chroma key)** as the baseline, with **Option B (LayerDiffuse for transparent generation)** as the premium path if we want native alpha support.

---

---

## Research Findings

---

### 1. Industry Standard for Game Studios
Game studios adopting AI-generated assets follow a consistent pattern:
- **Export format:** All assets generated as PNG with transparency
- **Background handling:** Most use chroma key (green screen) generation followed by color removal
- **Post-processing:** ~80-90% AI generation, then 10-20% human artist cleanup
- **Consistency method:** Detailed prompts, reference images, and prompt structure standardization
- **Workflow:** Rapid iteration → in-engine testing → quality control → final polish

**Key Finding:** The industry hasn't settled on a single "best" approach—instead, they use what works for their constraints. Choice depends on setup complexity, desired quality, and timeline.

---

---

### 2. FLUX Model Transparency Capabilities

**Standard FLUX (as-is):** Cannot natively generate transparent backgrounds with alpha channels. Standard FLUX outputs RGB images only.

**Technical Solution Available:** LayerDiffuse-Flux enables native RGBA generation
- Specialized fork of FLUX trained to explicitly predict alpha channels
- Produces true transparent backgrounds (not post-processed removal)
- Preserves soft edges, glows, and semi-transparency better than any removal method
- Requires: Custom weights + moderate setup in ComfyUI/Forge
- Available: Open-source on GitHub (FireRedTeam/LayerDiffuse-Flux)

**Workaround (Post-Processing):** Transparify method—generate on black AND white backgrounds, then mathematically reconstruct alpha channel (effective but adds generation overhead).

---

---

### 3. Chroma Key vs. AI Background Removal

| Aspect | Green Chroma Key | AI Removal (rembg) |
|--------|-----------------|-------------------|
| **Edge Quality** | Sharp, precise (if lighting controlled) | Very good (modern models), minor artifacts possible |
| **Real-Time** | Yes | No (~5-15s per image) |
| **Soft Edges** | Requires careful spill management | Naturally handles hair, transparency |
| **Glows/Reflections** | Can remove unintentionally | Preserved better by modern AI |
| **Setup Required** | High (consistent lighting) | Low (any image) |
| **Batch Processing** | Predictable results | Requires per-image tuning sometimes |
| **Hair/Complex Objects** | Struggles without manual cleanup | Modern models (BiRefNet, BRIA RMBG 2.0) excel |
| **Flexibility** | Rigid (must use chroma) | Works on any background |

**Winner by Category:**
- **Best for predictable, batch sprite generation:** Chroma key (when studio-controlled)
- **Best for edge quality on complex objects:** AI removal with modern models (BRIA RMBG 2.0, BiRefNet)
- **Best for flexibility:** AI removal (works on any background)
- **Best for professional/polished results:** Chroma key (if perfectly lit; AI removal for hands-off)

**Conclusion:** Chroma key is cleaner IF you control lighting/environment perfectly. AI removal is more practical for flexible workflows and actually superior on complex geometry (fabric, hair, transparent items).

---

---

### 4. Best Chroma Key Color

**For Digital/Game Art:** GREEN is the standard
- Digital sensors are most sensitive to green (highest detail capture)
- Reflects more light (easier to light evenly)
- Distinct from skin tones
- Widely available, affordable
- **Your current choice (#00FF00) is industry-standard**

**Blue Screen:** Use only if green elements are in your character/props
- Less spill (reflects less light)
- Better in low-light scenes
- Digital cameras less sensitive (slightly less detail)

**Magenta:** Rarely used in game art
- Too close to skin tones
- Not standard tooling support
- Only use in special edge cases

**Recommendation:** Stay with green. Your #00FF00 is correct.

---

---

### 5. AI-Generated Sprite Pipeline Best Practices

**Standard Pipeline Architecture (Industry):**
1. **Frontend:** Upload/prompt interface
2. **Backend:** Workflow orchestration (Azure AI Foundry in our case)
3. **AI Service:** FLUX model on Azure
4. **Output:** PNG with transparent background
5. **Post-Processing:** Cleanup (5-10% of frames need touch-up)
6. **QC:** In-engine testing before final export

**Consistency Maintenance (Fighting Games Specific):**
- Use character reference images as conditioning
- Maintain strict prompt structure across all generations
- Pre-define animation set: idle, walk, punch, kick, block, hit, crouch
- Frame count: 8-16 frames per action (adjust for smoothness)
- Export as sprite sheets with consistent frame dimensions

**Key Success Factors:**
1. **Detailed Prompts:** "Pixel art sprite, [character], [pose], [action], [style], [orientation]"
2. **Batch Generation:** Generate all frames of one action before moving to next
3. **Version Control:** Store base generations separately from final polished versions
4. **Rapid Iteration:** Small test sets → in-engine → feedback → regen
5. **Manual Touch-Up:** Budget time for 10-20% hand cleanup (blinking pixels, anatomy fixes, weapon placement)

---

---

## Decision Options Analyzed

---

### Option A: Green Chroma Key → Color-Key Removal Script ✅ (Current)
**Process:**
1. Prompt FLUX with character on #00FF00 background
2. Export PNG
3. Run automated color-key script (strips green, generates alpha)
4. Manual cleanup as needed

**Pros:**
- Industry-standard, proven method
- Fast iteration (no model retraining)
- Consistent results with stable prompting
- Works with standard FLUX
- Simple automated pipeline
- Minimal computational overhead

**Cons:**
- Requires perfect lighting control in generation prompt
- Green spill can occur on edges
- Not ideal for semi-transparent elements (glass, glow effects)
- Less flexible (must use green background in prompt)

**Estimated Timeline:** Weeks 1-4 (immediate implementation)
**Quality Level:** Production-ready (with 10-15% touch-up)
**Complexity:** Low
**Best For:** Rapid prototyping, consistent batching, controlled lighting scenarios

---

---

### Option B: LayerDiffuse for Direct Transparent Generation 🌟 (Premium)
**Process:**
1. Set up LayerDiffuse-Flux fork in ComfyUI/Azure environment
2. Prompt FLUX to generate with native alpha channel
3. Export PNG with true transparency
4. Minimal cleanup needed

**Pros:**
- Native alpha output (true transparency, not removal)
- Preserves soft edges, glows, halos better
- Better for complex geometry (fabric folds, hair strands)
- No color spill issues
- More flexible prompting (no need to specify green background)
- Superior for semi-transparent elements

**Cons:**
- Requires custom weights/model setup
- Moderate setup complexity (ComfyUI integration)
- Less widely adopted (fewer references/examples)
- Potential compatibility questions with Azure AI Foundry
- Unknown validation time on first implementation

**Estimated Timeline:** Weeks 2-5 (prototyping) + setup validation
**Quality Level:** Premium/polished (5% touch-up only)
**Complexity:** Moderate
**Best For:** Final production assets, characters with complex materials, premium quality push

---

---

### Option C: Solid Color Background → rembg AI Removal
**Process:**
1. Prompt FLUX with character on solid white/gray background
2. Export PNG
3. Run rembg (AI segmentation model) for background removal
4. Manual cleanup as needed

**Pros:**
- Works without special setup (rembg is free/open-source)
- No need to modify FLUX prompts
- Modern models (BRIA RMBG 2.0) handle complex edges well
- Great for hair, transparent, and fabric elements
- Flexible (any background color works)

**Cons:**
- Adds processing step (~5-15s per image)
- May require per-image tuning for difficult cases
- Minor artifacts possible (white halos, residual pixels)
- Quality inconsistent across diverse character designs
- Not real-time (slower batch processing)
- Additional cloud API calls or local GPU time

**Estimated Timeline:** Weeks 1-3 (minimal setup)
**Quality Level:** Good (varies; 15-25% touch-up)
**Complexity:** Very Low
**Best For:** Flexible/experimental workflows, characters with non-standard designs

---

---

### Option D: Hybrid Approach (Recommended Flexibility)
**Process:**
1. **Primary:** Green chroma key (Option A) for 80% of characters
2. **Secondary:** LayerDiffuse (Option B) for complex characters (fabric-heavy, transparent elements)
3. **Fallback:** rembg (Option C) for experimental/special cases

**Pros:**
- Leverages best-of-breed for each scenario
- Fast production for standard characters
- Premium quality for hero characters
- Handles edge cases gracefully
- Scalable as pipeline matures

**Cons:**
- Requires managing multiple workflows
- Slight learning curve for team
- More decision points (which method for which character?)

**Estimated Timeline:** Weeks 1-5 (staggered implementation)
**Quality Level:** Production-to-Premium (depends on route chosen)
**Complexity:** Moderate
**Best For:** Scaling production, diverse character roster, mature pipeline

---

---

## Recommendation

---

### Primary Path: **OPTION A + OPTION B (Hybrid Progressive)**

**Phase 1 (Now):** Continue with Option A
- Use green chroma key as production baseline
- Optimize prompting for clean edges
- Build automated color-key removal script
- Target: 70-80% production-ready on first pass

**Phase 2 (After 2-3 weeks evaluation):** Add Option B
- Set up LayerDiffuse-Flux in parallel Azure instance
- Test on 5-10 complex characters (fabric, glowing effects)
- Validate output quality vs. Option A
- Document workflow for team

**Phase 3 (Optional):** Keep Option C as fallback
- Use rembg only for edge cases or experimental characters
- Don't overcomplicate pipeline with it as primary path

---

---

## Action Items for Joaquín

1. **Validate Azure Compatibility:** Confirm LayerDiffuse-Flux can integrate with your Azure AI Foundry setup (may need custom container/weights)
2. **Chroma Key Script:** Build/adapt color-key removal (simple Python: detect green pixels, set alpha=0, export PNG)
3. **Prompt Template:** Standardize your FLUX prompts for fighting game sprites (I can provide template)
4. **Batch Test:** Generate 10-15 characters with Option A, measure edge quality and touch-up time
5. **Reference Asset:** Create a "Character Visual Bible" (style guide + color palette) for consistency

---

---

## Summary Table: Quick Reference

| Option | Timeline | Complexity | Quality | Best For | Current Viability |
|--------|----------|-----------|---------|----------|------------------|
| A: Chroma Key | Weeks 1-4 | Low | Good (85%) | Batch production | ✅ **Start Now** |
| B: LayerDiffuse | Weeks 2-5 | Moderate | Premium (95%) | Complex characters | 🔄 Prototype Phase 2 |
| C: rembg | Weeks 1-3 | Very Low | Fair-Good (75%) | Edge cases | ⚠️ Fallback Only |
| D: Hybrid | Weeks 1-5 | Moderate | Excellent | Production at scale | 🌟 **Final Goal** |

---

---

## Closing Notes

Your current approach (green chroma key) is **not only standard—it's the right starting point**. The industry converges on this for good reason: speed, predictability, and control. The only reason to shift is if you hit quality ceilings on complex characters.

LayerDiffuse represents the **next evolution** in transparent asset generation, and since it's emerging now, early adoption could give you a competitive advantage in asset quality. However, it's not a "must-have"—it's a quality multiplier.

**Proceed with confidence on Option A. Plan for Option B as a Phase 2 enhancement.**


---

---

## Decision: Art Pipeline Workflow — Approval Gate + Design Iterations

---

# Decision: Automated Visual Test Pipeline for Fight Scene

**Author:** Ackbar (QA/Playtester)  
**Date:** 2025-07-23  
**Status:** Implemented  
**Scope:** Ashfall fight scene QA automation

---

## Context

The team cannot visually verify the fight scene without manually launching Godot and playing. This blocks AI-based visual analysis and makes regression testing slow and inconsistent.

---

## Decision

Built a 3-file automated visual test pipeline that captures 7 screenshots of simulated gameplay:

1. **`scripts/test/fight_visual_test.gd`** — Coroutine-based test controller that:
   - Instances the fight scene, waits for FIGHT state via `RoundManager.announce`
   - Simulates 7 gameplay steps using `Input.action_press/release`
   - Captures screenshots with the proven `RenderingServer.frame_post_draw` pattern
   - Saves to both `res://` (project) and `user://` (absolute) paths
   
2. **`scenes/test/fight_visual_test.tscn`** — Minimal scene wrapper
3. **`tools/visual_test.bat`** — One-click launcher

---

## Key Design Choices

- **Coroutine sequencing over state machine** — `await _wait_frames()` is more readable than tracking step/frame counters in `_process`. Each test step reads as plain English.
- **Signal-based fight detection** — Connects to `RoundManager.announce("FIGHT!")` instead of hardcoding a frame delay. Survives intro timing changes.
- **Tap inputs for attacks, hold for movement** — Attacks press for 1 frame then release (matches real player behavior). Movement holds for the full step duration.
- **Dual output paths** — `res://` for in-project agent access, `user://` for external tool access (CI, Python scripts, etc.)

---

## Impact

- Any team member or CI system can run `visual_test.bat` to get 7 annotated screenshots
- AI agents can analyze screenshots for visual regressions without manual playtesting
- Pattern is extensible — add new steps to the `_run_test_sequence()` coroutine


---

---

# Decision: PNG Sprite Integration Standards

**Author:** Chewie (Engine Developer)
**Date:** 2025-07-17
**Scope:** Ashfall sprite system (character_sprite.gd, fighter_base.gd)

---

## Decisions Made

---

### 1. PNG Sprite Scale = 0.20
`_PNG_SPRITE_SCALE` set to 0.20 (512px → 102px rendered height, ~1.7x collision box). This provides proper visual presence with the fight scene's dynamic Camera2D zoom (0.75–1.3 range over a 1920×1080 viewport).

---

### 2. AnimatedSprite2D.flip_h for PNG sprite mirroring
When PNG sprites are active, CharacterSprite.flip_h uses the child AnimatedSprite2D's native `flip_h` property instead of parent `scale.x`. This avoids transform accumulation issues between parent scale and child offset. Procedural _draw() still uses parent `scale.x`.

---

### 3. All 45+ poses mapped in _POSE_TO_ANIM
Every pose the state machine can emit has an entry in `_POSE_TO_ANIM`. Non-attack poses (hit, block, jump, ko, etc.) map to "idle". Throws/specials map to "punch" or "kick". This guarantees no fallthrough to procedural _draw() when PNG sprites are loaded.

---

### 4. fighter_base owns CharacterSprite reference
`fighter_base.gd` now finds and stores a `character_sprite: CharacterSprite` reference (by type, not by name). This enables direct facing control from `_update_facing()` alongside the SpriteStateBridge, and ensures correct facing from the first frame via explicit `_update_facing()` call in `fight_scene._ready()`.

---

## Impact
- Any future CharacterSprite poses added to the state machine MUST also be added to `_POSE_TO_ANIM`.
- New characters extending CharacterSprite automatically inherit these fixes.
- The fight_scene.gd now documents all P1/P2 controls in a header comment block.


---

---

# Decision: CommunicationAdapter for GitHub Discussions

**Author:** Jango  
**Date:** 2025-07-23  
**Status:** Implemented (partial — category creation requires manual step)

---

## Context

Joaquín wants an automated devblog where Scribe and Ralph post session summaries to GitHub Discussions after each session. This provides public visibility into what the Squad is working on without manual effort.

---

## Decision

1. **Channel:** GitHub Discussions (native to the repo, no external services needed)
2. **Config:** Added `communication` block to `.squad/config.json` with:
   - `channel: "github-discussions"`
   - `postAfterSession: true` — Scribe posts after every session
   - `postDecisions: true` — Decision merges get posted
   - `postEscalations: true` — Blockers get visibility
   - `repository: "jperezdelreal/FirstFrameStudios"`
   - `category: "Squad DevLog"` — dedicated category for automated posts
3. **Scribe charter updated** with Communication section defining format, content, and emoji convention
4. **Test post created** at https://github.com/jperezdelreal/FirstFrameStudios/discussions/151

---

## Manual Action Required

⚠️ **Joaquín must create the "Squad DevLog" discussion category manually:**
1. Go to https://github.com/jperezdelreal/FirstFrameStudios/settings → Discussions
2. Click "New category"
3. Name: `Squad DevLog`
4. Description: `Automated session logs from the Squad AI team`
5. Format: `Announcement` (only maintainers/bots can post, others can comment)
6. Emoji: 🤖

The GitHub API does not support creating discussion categories programmatically. Until this category is created, posts should use "Announcements" as a fallback.

---

## Alternatives Considered

- **GitHub Issues:** Too noisy, mixes with real bugs/tasks
- **Wiki:** Good for reference docs, bad for chronological updates
- **External blog:** Unnecessary dependency, discussions are built-in

---

## Impact

- Scribe: New responsibility — post to Discussions after session logging
- Ralph: Can use same channel for heartbeat/status updates
- All agents: Session work becomes publicly visible


---

---

# Decision: Marketplace Skill Adoption

**Author:** Jango (Tool Engineer)  
**Date:** 2025-07-23  
**Status:** Implemented

---

## Context

Our `.squad/skills/` directory contained 31 custom skills built in-house for our game dev workflow. The `github/awesome-copilot` and `anthropics/skills` repos offer community-maintained skills covering general development workflows (PRDs, refactoring, context mapping, commit conventions, issue management, etc.) that complement our domain-specific skills.

---

## Decision

Installed 9 marketplace skills into `.squad/skills/`:

| Skill | Source | Purpose |
|-------|--------|---------|
| `game-engine-web` | github/awesome-copilot | Web game engine patterns (HTML5/Canvas/WebGL) |
| `context-map` | github/awesome-copilot | Map relevant files before making changes |
| `create-technical-spike` | github/awesome-copilot | Time-boxed spike documents for research |
| `refactor-plan` | github/awesome-copilot | Sequenced multi-file refactor planning |
| `prd` | github/awesome-copilot | Product Requirements Documents |
| `conventional-commit` | github/awesome-copilot | Structured commit message generation |
| `github-issues` | github/awesome-copilot | GitHub issue management via MCP |
| `what-context-needed` | github/awesome-copilot | Ask what files are needed before answering |
| `skill-creator` | anthropics/skills | Create and iterate on new skills |

---

## Naming Convention

When a marketplace skill name collides with an existing local skill, the marketplace version gets a suffix (e.g., `game-engine` → `game-engine-web` because we already had `web-game-engine`).

---

## Also Fixed

- **squad.config.ts routing**: Was all `@scribe` placeholder. Now routes to correct agents per work type.
- **squad.config.ts casting**: Was wrong universe list. Now `['Star Wars']`.
- **squad.config.ts governance**: Enabled `scribeAutoRuns: true`, added `hooks` with write guards, blocked commands, and PII scrubbing.

---

## Risks

- Marketplace skills may diverge from upstream — no auto-update mechanism yet. Manual re-fetch needed.
- `skill-creator` from anthropics is large (33KB) — may need trimming if it causes context bloat.

---

## Follow-up

- Monitor which marketplace skills agents actually invoke — prune unused ones after 2 sprints.
- Consider building a `skill-sync` tool if we adopt more marketplace skills.


---

---

### Walk/Kick Animation + Hit Reach Fix (Lando)
**Author:** Lando (Gameplay Developer)  
**Date:** 2025-07-23  
**Status:** IMPLEMENTED & VERIFIED  
**Scope:** Animation system, combat reach, hitbox cleanup

#### Problem
Founder tested manually and reported three critical issues:
1. Walk animation not playing — character moves but sprite stays in idle pose
2. Kick animation not playing — pressing kick keys shows punch pose instead
3. Hits don't connect visually — punches don't reach the opponent despite hitbox detection working

#### Root Causes Found

**Walk animation (Issue #1):**
`FighterAnimationController._ready()` accessed `fighter.state_machine` which is an `@onready` variable — null during sibling `_ready()` due to Godot's init ordering (children before parent). The `state_changed` signal was never connected, so the AnimationPlayer stayed on "idle" forever, overwriting all pose changes.

**Kick animation (Issue #2):** Three compounding bugs:
- `_move_to_pose()` mapped kick buttons (lk/mk/hk) to punch poses (attack_lp/mp/hp)
- `_get_attack_pose()` used case-sensitive matching (`"lk" in "Standing LK"` → false)
- Both movesets had no standing LK (only Crouching LK with `requires_crouch=true`)

**Hit reach (Issue #3):**
Fighters at x=200 and x=440 (240px gap). Hitbox extends 176px from origin, hurtbox starts 48px from target. Maximum reachable gap is 224px — the 240px gap exceeded it by 16px.

#### Changes Made
| File | Change |
|------|--------|
| `fighter_animation_controller.gd` | Access StateMachine node directly; fix `_move_to_pose()` kick mapping; stop AnimationPlayer on fallback instead of playing "hit" |
| `sprite_state_bridge.gd` | Add `.to_lower()` to move name in `_get_attack_pose()` |
| `character_sprite.gd` | Fix `flip_h` setter to use `AnimatedSprite2D.flip_h` for PNG sprites |
| `fight_scene.tscn` | Move Fighter2 from x=440 to x=400 |
| `kael_moveset.tres` | Add Standing LK (5f/3f/8f, 35 dmg) |
| `rhena_moveset.tres` | Add Standing LK (4f/3f/8f, 35 dmg) |
| `attack_state.gd` | Use `set_deferred` for hitbox deactivation during physics callbacks |
| `hitbox.gd` | Use `set_deferred` in `deactivate()` |

#### Verification
- `visual_test.bat`: 7/7 screenshots captured, walk shows `pose=walk → anim=walk`, kick shows `pose=attack_lk → anim=kick`, punch connects (`[Hitbox] HIT!`), no physics errors, no animation flickering
- `play.bat --quit-after 8`: Clean run, PNG sprites load for both characters

#### Known Remaining Issues
- AnimationMixer warning about string blending for "Ember Shot" (harmless, Godot internal)
- Throw animation has similar AnimationPlayer vs SpriteStateBridge pose conflict (not reported, lower priority)


---

---

# Decision: Instance FightHUD in fight_scene.tscn (not runtime)

**Date:** 2025-07-22
**Author:** Wedge (UI/UX Developer)
**Status:** Implemented

---

## Context

The FightHUD (`scenes/ui/fight_hud.tscn`) was fully implemented but never added to the fight scene tree. The fight scene had Stage, Fighters, and Camera2D — no HUD.

---

## Decision

Instance `fight_hud.tscn` directly in `fight_scene.tscn` rather than loading at runtime in GDScript.

**Reasons:**
1. The HUD is fully self-contained — it connects all 11 EventBus signals in its own `_ready()` via `_wire_signals()`. No external setup needed.
2. Scene-tree instancing is visible in the Godot editor, making the scene hierarchy inspectable.
3. The CanvasLayer (layer=10) ensures it renders above everything regardless of camera — no z-index coordination required.
4. `@onready` references resolve before `_ready()` runs, so fight_scene.gd can set name labels immediately.

---

## What Changed

- `fight_scene.tscn`: Added ext_resource for `fight_hud.tscn`, instanced as `FightHUD` child node
- `fight_scene.gd`: Added `@onready var hud` reference, set P1/P2 name labels from `SceneManager.p1_character`/`p2_character`

---

## Signal Verification

All 11 EventBus signals the HUD connects to are defined and emitted by existing systems (fight_scene.gd, RoundManager, ComboTracker). No missing signals.



---

---

## Tags

`infrastructure`, `notifications`, `discord`, `github-actions`, `webhooks`, `rate-limiting`


# Decision: autonomy-model.md Created as Reference Document

**Author:** Solo (Lead / Chief Architect)
**Date:** 2025-07-25
**Tier:** T1 (`.squad/` content refactor — Lead authority)
**Status:** Executed

---

## Decision

Created `.squad/identity/autonomy-model.md` to rescue operational content from governance v1 (Domains 2, 6, 7) that was intentionally cut from governance-v2.md for brevity.

---

## Rationale

Governance v2 reduced v1 from 1051 → 237 lines. The zone summary tables survived, but detailed rationale, configuration inheritance mechanics, hub/downstream responsibilities, and per-repo autonomy profiles were cut. These are needed by agents for day-to-day decisions about what they can and can't do locally.

---

## Scope

- **Reference doc only** — governance.md remains the authority on tiers and zones.
- **147 lines, tables over prose** — no philosophy paragraphs.
- **No duplication** — doesn't repeat what v2 already says well; adds the WHY and HOW.

---

## Content

Zone A/B/C rationale tables, Zone B extension example, Configuration Inheritance (cascades + local), Inheritance Conflict Resolution (4 rules), Hub Responsibilities (5), Downstream Responsibilities (6), Conflict Resolution (4 rules), Autonomy by Repository (4 repos).


# Decision: SceneContext Pattern Enforcement in Flora

**Date:** 2025-01-XX  
**Author:** Solo (Lead Architect)  
**Context:** flora repository (jperezdelreal/flora) Issue #23  
**Status:** Implemented

---

## Decision

Enforced the SceneContext architectural pattern across all Scene implementations in the Flora project. All Scene.init() and Scene.update() methods must accept SceneContext instead of direct Application references.

---

## Rationale

**Problem:**  
GardenScene was implementing Scene interface incorrectly by accepting `Application` directly in init() instead of the SceneContext wrapper. This caused TypeScript build failures and deploy workflow blockage.

**Solution:**  
Updated GardenScene to conform to the SceneContext pattern:
- `init(app: Application)` → `init(ctx: SceneContext)`
- `update(delta: number)` → `update(delta: number, ctx: SceneContext)`
- All Application references changed to `ctx.app`
- Scene stage access changed to `ctx.sceneManager.stage`

---

## Benefits

1. **Consistent Architecture:** All scenes access shared resources through SceneContext
2. **Better Testability:** SceneContext can be mocked more easily than Application
3. **Dependency Injection:** Scenes receive input, assets, and sceneManager without tight coupling
4. **Type Safety:** TypeScript enforces the pattern at compile time

---

## Implementation Details

**Files Modified:**
- `src/scenes/GardenScene.ts`

**Changes:**
- Import SceneContext type
- Updated init() signature to accept SceneContext
- Updated update() signature to accept SceneContext
- Changed all `app.*` references to `ctx.app.*`
- Changed scene stage access to use `ctx.sceneManager.stage`

---

## Verification

- ✅ TypeScript compilation passes (`npx tsc --noEmit`)
- ✅ Production build succeeds (`npm run build`)
- ✅ Deploy workflow unblocked

---

## Future Considerations

When implementing new Scenes in Flora:
1. Always implement Scene interface with correct signatures
2. Use SceneContext for all shared resource access
3. Run TypeScript type check early in development to catch signature mismatches
4. Reference BootScene.ts or GardenScene.ts as pattern examples

---

## Files

- **Created:** `.squad/identity/governance-v2.md` (237 lines)
- **NOT modified:** `.squad/identity/governance.md` (v1 untouched)


# Cutscene System Architecture for ComeRosquillas

**Date:** 2025-01-XX  
**Agent:** Wedge (UI/UX Developer)  
**Project:** ComeRosquillas  
**Issue:** #5 - Simpsons-themed intermission cutscenes

---

## Decision

Implemented a timeline-based cutscene system using a dedicated game state (ST_CUTSCENE) with declarative actor spawning and simple action processing.

---

## Context

ComeRosquillas needed Pac-Man-style intermission cutscenes between levels to add personality and humor. The game already had a state machine and rich sprite rendering methods for characters.

---

## Design Choices

---

### Timeline-Based Architecture
- Cutscenes defined as `{duration, timeline: [{frame, action, params}]}` objects
- Events trigger at specific frames (e.g., frame 0, 30, 60)
- Actors stored in array with position, velocity, and type
- Update loop advances frame counter and spawns/updates actors

**Why:** Declarative timelines are easier to author and modify than imperative animation code. Non-programmers can add cutscenes by editing data.

---

### Reuse Existing Sprite Methods
- Called Sprites.drawHomer(), _drawBurns(), _drawNelson(), drawDonut(), drawDuff()
- No new rendering code needed
- Actors positioned in screen space, not grid space

**Why:** DRY principle — sprites already looked good, no need to redraw. Maintains visual consistency with gameplay.

---

### Skip on Any Key
- Any keypress during ST_CUTSCENE calls skipCutscene()
- Immediately transitions to next level via endCutscene()

**Why:** Player agency — some players want to skip, others want to watch. Match arcade conventions.

---

### Black Background
- Full black canvas instead of game maze
- Focuses attention on animated sprites

**Why:** Simplicity and performance. No need to render maze during cutscenes. Classic arcade aesthetic.

---

## Trade-offs

- **Pro:** Easy to add new cutscenes without touching logic code
- **Pro:** Minimal performance impact (just sprite drawing)
- **Pro:** Consistent with existing codebase patterns (state machine)
- **Con:** Timeline format is rigid — complex branching/looping would require new actions
- **Con:** No audio/dialogue system yet (could extend action types)

---

## Alternatives Considered

1. **Sprite sheets + frame-by-frame animation** — Too heavyweight for a Pac-Man clone
2. **Video files** — Would break "no external assets" constraint
3. **CSS animations** — Mixing canvas and DOM would complicate rendering

---

## Future Extensions

- Add 'sound' action type to trigger SFX at specific frames
- Add 'camera' action for pan/zoom effects
- Support looping cutscenes (e.g., attract mode)
- Add cutscene editor UI (stretch goal)

---

## Files Modified

- `js/config.js` — Added ST_CUTSCENE, CUTSCENE_LEVELS, CUTSCENES data
- `js/game-logic.js` — Added cutscene methods, state handling, skip logic



---

---

## Decision: Game Vision & Design Document

**Author:** Yoda (Game Designer)  
**Date:** 2025  
**Type:** Design Authority  
**Status:** Proposed  
**Artifact:** `.squad/analysis/game-design-document.md`

---

---

### Summary

Created the comprehensive Game Design Document (GDD) for firstPunch — the team's north star for all design and implementation decisions.

---

### Key Decisions

#### Vision
firstPunch is a browser-based game beat 'em up where comedy IS the combat. Players should laugh, feel powerful, and immediately want to try the next character. Instant-play browser design means zero friction, 5-7 minute levels, and session-friendly pacing.

#### Four Design Pillars
1. **Comedy as a Core Mechanic** — Humor is in the gameplay systems (taunts, Ugh! moments, game-rated combo meter), not just cosmetic.
2. **Accessible Depth** — Button-mashers have fun; combo masters have a different kind of fun. Streets of Rage 4 principle.
3. **Team Synergy** — Co-op mechanics reward playing as the team together (team attacks, proximity buffs, team super).
4. **Downtown Is a Character** — Environments are interactive playgrounds with landmark gags, destructibles, and hazards.

#### Core Combat
- **PPK combo** as the bread-and-butter (42 damage/1.1s)
- **Health-cost specials** with recovery-by-attacking (SoR2/SoR4 model)
- **Grab/throw system** (Turtles in Time influence)
- **Dodge roll with i-frames** (modern standard)
- **Super meter** filled by damage and taunts
- **Jump attacks rebalanced** with landing lag to prevent air-spam dominance (balance analysis finding)

#### Characters (4 planned, Brawler first)
- Brawler: Power/All-Rounder, Rage Mode, Belly Bounce
- Kid: Speed, Skateboard Dash, Slingshot ranged, alter-ego super
- Defender: Range, Purse Swing, Hair Whip, Maternal Instinct passive
- Prodigy: Technical/CC, Saxophone Blast, Intellect Advantage dodge, Activist Rally super

#### game-Specific Mechanics
- **Rage Mode** (eat 3 donuts → Brawler power-up, creates heal vs. rage dilemma)
- **Ugh! Moments** (funny failure states at every level)
- **Couch Gag loading screens** (randomized, collectible transitions)
- **Downtown landmarks** as interactive combat elements
- **game food** as themed health pickups (Pink Donut, Burger Joint, Fire Cocktail)
- **Combat barks** (character quotes on gameplay events)

#### Balance Integration
Incorporated all 6 critical and 3 medium balance flags from Ackbar's analysis:
- Jump attack DPS capped at 38 (down from 50) via landing lag
- Enemy damage targets raised (8 base, up from 5)
- 2-attacker throttle as design principle, not performance compromise
- Knockback tuning to preserve PPK combo viability

#### Platform Constraints
Documented Canvas 2D limitations and "Future: Native/Engine Migration" items (shaders, skeletal animation, online multiplayer, advanced physics).

---

### Impact
Every team member now has a single reference for "what are we building and why." Design authority calls prevent scope creep and ensure coherence.

---

---

## High Score localStorage Key & Save Strategy

**Author:** Wedge  
**Date:** 2025-01-01  
**Status:** Implemented  
**Scope:** P0-1 — High Score Persistence

---

### Decision

- localStorage key is `firstPunch_highScore` — namespaced to avoid collisions if other games share the domain.
- High score is saved at the moment `gameOver` or `levelComplete` is triggered, not continuously during gameplay. A `highScoreSaved` flag prevents duplicate writes.
- `saveHighScore()` returns a boolean so the renderer can show "NEW HIGH SCORE!" vs the existing value — no extra localStorage read needed in the render loop for that decision.
- All localStorage access is wrapped in try/catch to gracefully handle private browsing or disabled storage (falls back to 0).
- Title screen only shows the high score label when value > 0, keeping a clean first-play experience.

---

### Why

- Single save point is simpler and avoids unnecessary writes during gameplay.
- Boolean return from save avoids coupling render logic to storage checks.
- Graceful fallback means the game never crashes due to storage restrictions.

---

---

## AudioContext Resume Pattern

**Author:** Greedo  
**Date:** 2025-06-04  
**Status:** Implemented

---

### Context
Web Audio API requires a user gesture before AudioContext can produce sound. The previous code created the context eagerly in the constructor, meaning audio could silently fail on first load in Chrome, Safari, and Firefox.

---

### Decision
- AudioContext is still created in the constructor (so `currentTime` etc. are available immediately)
- A `resume()` method checks `context.state === 'suspended'` and calls `context.resume()`
- `main.js` registers a one-time `keydown`/`click` listener that calls `audio.resume()` and removes itself
- All existing `playX()` methods continue to work without changes — they just produce no sound until the context is resumed

---

### Why
- Transparent fix: zero changes to any caller code
- One-time listener self-removes to avoid unnecessary event handling
- Works across all modern browsers (Chrome, Firefox, Safari, Edge)
- The title screen requires ENTER to start, so audio is always resumed before gameplay begins

---

### Trade-offs
- If a caller tries to play sound before any user interaction, it silently does nothing (acceptable — matches browser behavior)
- Could alternatively lazy-create the context on first `resume()`, but that would delay `currentTime` baseline — not worth the complexity

---

---

### Full Details

See `.squad/analysis/backlog-expansion.md` for complete item list, re-assignment tables, and load analysis.

# Decision Proposal: Rendering Technology

**From:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Priority:** High  
**Status:** Proposed

---

## Summary

Researched 5 rendering technology options to address the "cutre" (cheap-looking) graphics feedback. Full analysis in `.squad/analysis/rendering-tech-research.md`.

---

## Current Problem

- No HiDPI/Retina support → blurry text and shapes on modern displays
- ~100 canvas API calls per entity per frame → no headroom for richer art
- No GPU effects → flat, unpolished look (no glow, blur, bloom)
- Fixed 1280×720 → doesn't scale to larger screens

---

## Recommendation: Two-Phase Approach

---

### Phase 1 — Canvas 2D Optimization (NOW, 8-12 hours, zero risk)
1. **HiDPI fix** — scale canvas by `devicePixelRatio`. Fixes blurry signs immediately.
2. **Sprite caching** — pre-render entities to offscreen canvases, `drawImage()` each frame. 10× perf gain.
3. **Resolution-independent design** — internal 1920×1080, scale to any screen.

---

### Phase 2 — Hybrid Canvas + PixiJS (LATER, 23-35 hours, if Phase 1 isn't enough)
- Add PixiJS via CDN UMD (no build step needed)
- Keep procedural Canvas drawing → convert to PixiJS textures
- GPU filters for bloom, glow, distortion effects
- PixiJS ParticleContainer for particle storms

---

### Rejected Options
- **Full PixiJS rewrite** — similar cost to hybrid but loses procedural drawing flexibility
- **Phaser** — 50-74h rewrite, replaces working systems we've built, 1.2MB bundle
- **Three.js** — overkill for 2D, 80+h rewrite

---

## Impact
Phase 1 alone should transform the visual quality from "cutre" to "polished indie." Phase 2 adds AAA-level GPU effects if needed.

---

## Decision Needed
Approve Phase 1 implementation (HiDPI + sprite caching + resolution scaling). Phase 2 deferred until we evaluate Phase 1 results.



---

---

# Decision Inbox: Tech Ambition Evaluation

**From:** Chewie (Engine Dev)  
**Date:** 2025-07-15  
**Priority:** P0 — Strategic Direction  
**Status:** Proposal — Awaiting Team Discussion

---

---

## Summary

Evaluated 5 engine options across 9 dimensions for the next project ("nos jugamos todo"). Full analysis in `.squad/analysis/next-project-tech-evaluation.md`.

---

## Recommendation: Godot 4

**Phaser 3 is a good engine. Godot 4 is the right weapon for the fight we're picking.**

---

### Why Not Phaser
- Web-only limits us to itch.io — no Steam, no mobile, no console
- Every award-winning beat 'em up ships native. Zero browser-only games in the competitive set.
- We'd lose our procedural audio system (931 LOC) — Phaser is file-based only
- Visual ceiling: 8.5/10 vs Godot's 9.5/10
- Performance ceiling: browser JS GC vs native binary

---

### Why Godot
- **Multi-platform:** Web + Desktop + Mobile + Console (via W4) from one codebase
- **2D is first-class:** Not a 3D engine with 2D bolted on (unlike Unity)
- **Free forever:** MIT license, no pricing surprises, no runtime fees
- **Our knowledge transfers:** Fixed timestep → `_physics_process`, event bus → signals, audio bus → AudioBus system, hitlag → `Engine.time_scale`. Concepts transfer, only syntax changes.
- **Procedural audio survives:** `AudioStreamGenerator` provides raw PCM buffer for Greedo's synthesis work
- **Built-in tools accelerate squad:** Animation editor, particle designer, shader editor, tilemap editor, debugger, profiler — every specialist gets real tools
- **Community exploding:** 100K+ GitHub stars, fastest-growing engine, backed by W4 Games

---

### Why Not Unity
- C# learning curve (2-3 months vs GDScript's 2-3 weeks)
- Heavy editor, slow iteration
- Pricing trust eroded
- Scene merge conflicts with 12-person squad

---

### The Score
| Engine | Total (9 dimensions) |
|--------|---------------------|
| **Godot 4** | **74/90** |
| Phaser 3 | 66/90 |
| Unity | 66/90 |
| Defold | 57/90 |

---

### Cost
- 2-3 week learning sprint before production velocity matches current level
- GDScript ramp-up (Python-like, approachable for JS devs)
- firstPunch engine code (1,931 LOC) doesn't transfer — but all architectural knowledge does

---

### Action Needed
- Squad discussion on engine choice
- If approved: 2-week learning sprint → 2-week prototype → production

—Chewie


---

---

# Decision: Evaluate 2 Proposed New Roles for Godot Transition

**Author:** Solo (Lead)
**Date:** 2025-07-22
**Status:** Recommendation
**Requested by:** joperezd

---

---

## Context

The team is transitioning from a vanilla HTML/Canvas/JS stack to Godot 4 for future projects. Two new roles are proposed: **Chief Architect** and **Tool Engineer**. The current squad is at 12/12 OT Star Wars character capacity (Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien) plus Scribe and Ralph as support. This evaluation assesses whether these roles are genuinely new or absorbable into existing charters.

---

---

## 1. Does Solo Already Cover Chief Architect?

---

### Current Solo Charter
Solo's charter explicitly states:
- "Project architecture and structure decisions"
- "Code review and integration oversight"
- "Ensuring modules work together correctly"
- "Makes final call on architectural trade-offs"

---

### What Chief Architect Would Own
- Repo structure, game architecture, conventions
- Scene tree design, node hierarchy standards
- Code style guide, naming conventions
- Integration patterns (how modules connect)
- Reviews architecture decisions

---

### Overlap Analysis: **~80% overlap.**

Solo already owns architecture decisions, integration patterns, and code review. The skill assessment (Session 9) rates Solo as "Proficient" with strongest skill being "Strategic analysis and workload distribution." The architectural work Solo did — gameplay.js decomposition, CONFIG extraction, camera/wave-manager/background extraction — is exactly what a Chief Architect would do.

---

### What's Genuinely New
The ~20% that doesn't cleanly fit Solo today:
1. **Godot-specific scene tree design** — This is domain knowledge Solo doesn't have yet. But it's a *learning gap*, not a *role gap*. Solo will learn Godot's scene/node model the same way Solo learned Canvas 2D architecture.
2. **Code style guide / naming conventions** — This was identified as a gap: the `project-conventions` skill is an empty template (Low confidence, zero content). But writing a style guide is a one-time task, not a full-time role.
3. **Formal architecture reviews** — Solo does this informally. A Godot project with 12 agents would benefit from explicit review gates. But this is a *process improvement* for Solo's charter, not a new person.

---

### Verdict: **Do NOT create Chief Architect. Expand Solo's charter.**

**Rationale:** Splitting architectural authority creates a coordination problem worse than any it solves. Who has final say — Solo or Chief Architect? If Chief Architect overrides Solo on architecture, Solo becomes a project manager without teeth. If Solo overrides Chief Architect, the role is advisory and agents will learn to route around it. One voice on architecture is better than two voices that might disagree.

**What to do instead:**
- Add to Solo's charter: "Owns Godot scene tree conventions, node hierarchy standards, and code style guide"
- Solo's first Godot task: produce the architecture document (repo structure, scene tree patterns, naming conventions, signal conventions) *before* any agent writes code
- Fill the `project-conventions` skill with Godot-specific content (currently an empty template — this is the right vehicle)
- Add explicit architecture review gates to the squad workflow (Solo reviews scene tree structure on first PR from each agent)

---

---

## 2. Does Chewie Already Cover Tool Engineer?

---

### Current Chewie Charter
Chewie's charter states:
- "Game loop with fixed timestep at 60 FPS"
- "Canvas renderer with camera support"
- "Keyboard input handling system"
- "Web Audio API for sound effects"
- "Core engine architecture"
- "Owns: src/engine/ directory"

---

### What Tool Engineer Would Own
- Project structure in Godot (scene templates, base classes)
- Editor tools/plugins for the team
- Pipeline automation (asset import, build scripts)
- Scaffolding that prevents architectural mistakes
- Facilitating other agents' work

---

### Overlap Analysis: **~40% overlap.**

Chewie is an **engine developer** — builds runtime systems that the game uses at play-time. Tool Engineer builds **development-time** systems that *agents* use while working. These are fundamentally different audiences and different execution contexts.

| Dimension | Chewie (Engine Dev) | Tool Engineer |
|-----------|-------------------|---------------|
| **Audience** | The game (runtime) | The developers (dev-time) |
| **Output** | Game systems (physics, rendering, audio) | Templates, plugins, scripts, pipelines |
| **When it runs** | During gameplay | During development |
| **Godot equivalent** | Writing custom nodes, shaders, game systems | Writing EditorPlugins, export presets, GDScript templates |
| **Success metric** | Game runs well | Agents are productive and consistent |

---

### What Chewie Already Does That's Tool-Adjacent
- Chewie did create reusable infrastructure: SpriteCache, AnimationController, EventBus (though none were wired — Session 8 finding)
- Chewie's integration passes (FIP, AAA) were essentially tooling work — connecting systems together
- Chewie wrote the `web-game-engine` skill document — documentation that helps other agents

---

### What's Genuinely New in Godot
Godot creates significantly more tooling surface area than vanilla JS:
1. **EditorPlugin API** — Godot has a full plugin system for extending the editor. Custom inspectors, dock panels, import plugins, gizmos. This is a distinct skillset from game engine coding.
2. **Scene templates / inherited scenes** — Godot's scene inheritance model means base scenes need careful design. A bad base scene propagates mistakes to every child. This is architectural scaffolding work.
3. **Asset import pipelines** — Godot's import system (reimport settings, resource presets, `.import` files) needs configuration. Sprite atlases, audio bus presets, input map exports.
4. **GDScript code generation** — Template scripts for common patterns (state machines, enemy base class, UI panel base) that agents instantiate rather than write from scratch.
5. **Build/export automation** — Export presets, CI/CD for Godot builds, platform-specific settings.
6. **Project.godot management** — Autoload singletons, input map, layer names, physics settings. One wrong edit breaks everyone.

---

### Verdict: **YES, create Tool Engineer. This is a distinct role.**

**Rationale:** The overlap with Chewie is only ~40%, and critically, it's the wrong 40%. Chewie's strength is runtime systems — the skill assessment rates Chewie as "Expert" in "System integration and engine architecture." Tool Engineer is about *development-time* productivity. Asking Chewie to also write EditorPlugins, manage import pipelines, and create scaffolding templates would split Chewie's focus between two fundamentally different jobs: making the game work vs. making the team work.

**The lesson from firstPunch proves this:** The #1 technical debt finding (Session 8) was "214 LOC of unused infrastructure — working systems that aren't wired into anything." The multi-agent-coordination skill (Session 10) identified the core pattern: "agents build infrastructure but don't wire it." A Tool Engineer's explicit job would be closing this gap — building the scaffolding, templates, and automation that ensure new code arrives pre-wired.

---

---

## 3. Godot-Specific Needs Assessment

---

### Does Godot's Architecture Justify a Dedicated Tooling Role?

**Yes, and here's why it's MORE needed than in vanilla JS:**

In our Canvas/JS project, there was no editor, no import system, no scene tree, no project file, no plugin API. The "tooling" was just file organization and conventions. Godot introduces 5 entire systems that need tooling attention:

| Godot System | Tooling Work Required | Comparable JS Work |
|-------------|----------------------|-------------------|
| Scene tree + inheritance | Base scene design, node hierarchy templates, inherited scene conventions | None (we had flat file imports) |
| EditorPlugin API | Custom inspector panels, validation tools, asset preview widgets | None (no editor) |
| Resource system | .tres/.res management, resource presets, custom resource types | None (all inline) |
| Signal system | Signal naming conventions, connection patterns, signal bus architecture | We built EventBus (49 LOC) but never used it |
| Export/build system | Export presets, CI/CD, platform configs, feature flags | None (no build step) |

**Conservative estimate:** 15-25 tooling items in the first Godot project, ongoing maintenance as game scope grows. That's a full role's worth of work, comparable to Tarkin's content workload (18 items in firstPunch).

---

### Godot's Scene-Signal Architecture Creates Unique Coordination Challenges

In vanilla JS, a bad import path fails loudly at runtime. In Godot, a bad signal connection or incorrect node path fails *silently* — the signal just doesn't fire, the node reference returns null. Tool Engineer can build editor validation plugins that catch these at edit-time, before agents commit broken connections.

---

---

## 4. Team Size: 12/12 → 13 (Overflow Handling)

---

### Current Roster (12 OT Characters)
Solo, Chewie, Lando, Wedge, Boba, Greedo, Tarkin, Ackbar, Yoda, Leia, Bossk, Nien

---

### Adding 1 New Role → 13 Characters
Since we're only recommending Tool Engineer (not Chief Architect), we need 1 new character, not 2.

---

### Options for the 13th Character

**Option A: Prequel character**
Use a prequel-era character: Qui-Gon, Mace, Padmé, Jango, Maul, Dooku, Grievous, Rex, Ahsoka, etc.

**Option B: Extended OT universe**
Characters from OT-adjacent media: Thrawn, Mara Jade, Kyle Katarn, Dash Rendar, etc.

**Option C: Rogue One / Solo film characters**
K-2SO, Chirrut, Jyn, Cassian, Qi'ra, Beckett, L3-37, etc.

---

### Recommendation: **Prequel is fine. Go with it.**

The Star Wars naming convention is a fun team identity feature, not a hard constraint. One prequel character doesn't break the theme. The convention already bent with Scribe and Ralph (non-Star Wars support roles).

**Suggested name: K-2SO** — the reprogrammed droid from Rogue One. Fitting for a Tool Engineer: originally built for one purpose, reprogrammed to serve the team. Technically OT-era (Rogue One is set immediately before A New Hope). Alternatively, **Lobot** — Lando's cyborg aide from Cloud City, literally an augmented assistant, pure OT.

---

---

## 5. Alternative: Absorb Into Existing Roles?

---

### Chief Architect → Absorbed into Solo ✅

This is straightforward. Solo's charter already covers 80% of this. The remaining 20% (Godot conventions, style guide, formal review gates) is a charter expansion, not a new person. Solo should:
1. Write the Godot architecture document as Sprint 0 deliverable
2. Fill the `project-conventions` skill with Godot-specific content
3. Add architecture review gates to the workflow

---

### Tool Engineer → NOT absorbable ❌

We evaluated 3 absorption candidates:

**Chewie?** No. Chewie is a runtime systems expert. EditorPlugins, import pipelines, and scaffolding templates are development-time concerns. Splitting Chewie's focus would degrade both game engine quality AND tooling quality. The skill assessment rates Chewie as the team's only Expert-level engineer — don't dilute that.

**Solo?** No. Solo is already the planning/coordination bottleneck. Adding hands-on tooling work would mean either slower planning cycles or rushed tools. Solo's weakness is already "follow-through on integration" (CONFIG.js never wired in). Adding more implementation to Solo's plate makes this worse.

**Yoda (Game Designer)?** No. Yoda defines *what* the game should be, not *how* the development environment works. Completely different domain.

**Distribute across all agents?** No. This is exactly the pattern that produced 214 LOC of unused infrastructure in firstPunch. When everyone is responsible for tooling, nobody is responsible for tooling. The multi-agent-coordination skill explicitly warns against this.

---

---

## Summary of Recommendations

| Proposed Role | Verdict | Action |
|--------------|---------|--------|
| **Chief Architect** | ❌ **Do NOT create** | Expand Solo's charter with Godot architecture responsibilities. Fill `project-conventions` skill. Add review gates. |
| **Tool Engineer** | ✅ **CREATE** | New role with distinct charter. Owns EditorPlugins, scene templates, import pipelines, scaffolding, build automation. Suggested name: Lobot or K-2SO. |

---

### Charter Draft for Tool Engineer

```

---

## Role
Tool Engineer for [Godot Project].

---

## Responsibilities
- Godot project structure setup and maintenance (project.godot, autoloads, layers)
- Scene templates and inherited scenes for common patterns
- Base class scripts (state machine, enemy base, UI panel base)
- EditorPlugin development (custom inspectors, validation tools, asset previews)
- Asset import pipeline configuration (sprite atlases, audio presets, resource types)
- Build/export automation and CI/CD pipeline
- Scaffolding tools that enforce architectural conventions
- Integration validation — ensuring agent work connects correctly

---

## Boundaries
- Owns: addons/ directory, project.godot configuration, export presets
- Creates templates that other agents instantiate
- Does NOT implement game logic, art, or audio — builds tools for those who do
- Coordinates with Solo on architectural standards (Solo defines WHAT, Tool Engineer builds HOW to enforce it)

---

## Model
Preferred: auto
```

---

### Net Team Impact

| Metric | Before | After |
|--------|--------|-------|
| Team size | 12 + 2 support | 13 + 2 support |
| Architectural authority | Solo (implicit) | Solo (explicit, expanded charter) |
| Tooling ownership | Nobody (distributed, often dropped) | Tool Engineer (dedicated) |
| Star Wars theme integrity | Pure OT | OT + 1 Rogue One/OT-adjacent character |
| Risk of unwired infrastructure | High (proven pattern) | Low (Tool Engineer's explicit job) |

---

---

*Solo — Lead*



---

---

## Archived: yoda-growth-framework decision


# Decision: Studio Growth Framework Created

**Date:** 2025  
**Author:** Yoda (Game Designer)  
**Status:** Complete  
**Scope:** Studio meta-architecture and scaling strategy  

---

---

## The Decision

First Frame Studios has created a comprehensive **Growth Framework** (`.squad/identity/growth-framework.md`) that documents how the studio will evolve from a single-game team to a multi-game, multi-genre studio without breaking under its own weight.

---

---

## Why Now?

The founder's directive: **"amplitud de miras"** (breadth of vision). firstPunch proved we can ship one game. But the studio must be built to absorb new genres, new platforms, new team members, and new challenges without fundamental restructuring.

At growth inflection points, studios either:
1. **Scale vertically** — Add more layers of management, more process overhead, more bureaucracy. This works at massive scale but kills small teams.
2. **Scale horizontally** — Add more teams, same structure, shared knowledge base. This requires documenting everything so knowledge compounds.

First Frame Studios chooses **horizontal scaling** with a documented foundation.

---

---

## Core Insight: The 70/30 Rule

**70% of what makes First Frame Studios effective is PERMANENT and tech/genre agnostic:**
- Leadership principles (decision-making algorithms)
- Quality gates and definition of done (outcome-based standards)
- Team structure and domain ownership model
- Design methodology (research → GDD → backlog → build → retrospective → skills)
- Company identity and values

**30% is ADAPTIVE and changes per project:**
- Engine-specific skills (Canvas 2D vs. Godot 4 vs. Unreal)
- Genre-specific skills (beat 'em up combat vs. platformer physics vs. fighting game netcode)
- Code patterns and architecture (specific to tech stack)
- Art pipelines (sprites vs. models vs. vector)

This ratio means: **New genres, new platforms, and new teams don't break us. They're absorbed by the permanent 70%.**

---

---

## What the Framework Delivers

1. **Skill Architecture** — How knowledge compounds across projects: universal skills (state machines, game feel), genre verticals (beat 'em up, future platformer/fighting), tech stack skills, and maturity levels.

2. **Team Elasticity** — Core roles (Game Designer, Lead, Engine, Gameplay, QA) are permanent. New roles emerge per project scope. New genres may require new specialist roles (e.g., Level Designer for platformer, Netcode Engineer for fighting game).

3. **Genre Onboarding Protocol** — Two playbooks:
   - **First genre:** 8 weeks (research → GDD template → minimum playable → skill creation → team assessment → architecture spike)
   - **Returning to genre:** 4 weeks (read existing skills, check for updates, start with institutional advantage)

4. **Technology Independence** — GDD, principles, quality gates, and team charters are engine-agnostic. Only engine-specific skills, build pipelines, and architecture docs are locked to a platform. If Canvas 2D becomes obsolete, we port to Godot 4. The 70% carries forward unchanged.

5. **Risk Mitigation** — Six risks that force restructuring if ignored (knowledge-in-head, engine lock-in, single-genre limit, process scalability, key person dependency, platform obsolescence). For each, the documented prevention.

6. **Growth Milestones** — Five stages: Single Genre → Second Genre → Multi-Genre → Multi-Platform → Studio Scale. The framework explains what each stage proves and what risks it mitigates.

---

---

## Trade-Offs and Alternatives

---

### Alternative 1: "Don't document. Trust people and relationships."
- **Pro:** Faster in the short term. Less "bureaucracy."
- **Con:** Catastrophic when people leave. Knowledge dies. Studio must rehire and retrain. At Stage 2 or 3, this breaks the studio.
- **Why we didn't choose this:** firstPunch already taught us that institutional memory (decisions.md, skills, history.md) is what compounds. We can't rely on people staying; we have to rely on documented patterns.

---

### Alternative 2: "Create new structure for each new genre."
- **Pro:** Each genre gets optimized structure.
- **Con:** Restructuring overhead kills momentum. Team churn. Principles become inconsistent. By Stage 3 (multi-genre), the studio becomes a chaos of different cultures.
- **Why we didn't choose this:** The framework proves that one squad structure can absorb any genre. Efficiency comes from consistent structure, not specialized structure.

---

### Alternative 3: "Write the framework after the second game ships."
- **Pro:** We'll have more data.
- **Con:** The second game will be chaotic and slow because the team won't have a shared mental model of how to scale. Decision-making will be ad-hoc. We'll make preventable mistakes.
- **Why we didn't choose this:** Writing the framework *now*, from firstPunch's lessons, gives us a hypothesis to test with the second game. If the hypothesis holds, the second game will be faster. If it breaks, we'll learn why and update the framework.

---

---

## Implementation

The Growth Framework is **not** a change to current operations. It is a **description of how we already work** (from firstPunch) plus a **set of protocols for what comes next**.

**Immediate actions:**
1. ✅ Growth Framework created and archived at `.squad/identity/growth-framework.md`
2. ✅ Learnings appended to `.squad/agents/yoda/history.md`
3. 🔲 Distributed to team and discussed in next studio meeting
4. 🔲 Used as the foundation for the next project's onboarding

**When the second project starts:**
1. Team reads the relevant sections (Sections 2–4: Skill Architecture, Team Elasticity, Genre Onboarding Protocol)
2. Follow the Genre Onboarding Protocol (8 weeks of research/planning before Sprint 0)
3. Document findings in the retrospective and update the framework with what we learned

---

---

## Reversibility

**This is highly reversible.** The Growth Framework is a description of intent, not a constraint. If the team discovers that the framework is wrong, we update it. If the 70/30 ratio doesn't hold, we change the ratio. If the genre onboarding protocol doesn't work, we redesign it.

The only part that's non-reversible is: **Committing to documentation as the source of truth.** Once we've organized institutional knowledge around written skills and decision logs, we can't go back to "knowledge in people's heads" without losing everything. But that's the direction we've already chosen (with firstPunch's GDD, skills, and decisions.md), so this isn't a new commitment.

---

---

## Success Criteria

The Growth Framework succeeds if:

1. **Second game launches faster than first** — Research, planning, and architecture spikes take 4 weeks instead of 8 (because we have existing knowledge).
2. **No reshuffling of team structure** — We don't need to reorganize roles or create new departments to ship the second game.
3. **Skills compound** — We can point to at least two transferable patterns from beat 'em up that accelerated the second game's development.
4. **New genres don't break quality** — The second game ships at the same quality bar as firstPunch without working weekends or hiring crisis staff.
5. **Framework survives contact with reality** — We update the framework based on what we learned. Some claims will be wrong; that's OK.

---

---

## Related Decisions

- [Yoda — Game Vision](../yoda-game-vision.md) — The GDD and design principles that shape all games
- [Solo — Team Expansion](../solo-team-expansion.md) — The squad structure that this framework describes
- [Company Identity](../identity/company.md) — Section 7 (Genre Strategy — Vertical Growth) is the narrative version of this framework

---

---

## Notes for Future Readers

If you're reading this in Year 2 or beyond:

1. **Check if the 70/30 rule held.** Did 70% of the studio's effectiveness remain constant across genres? Or did the split change? Document your findings.
2. **Check if the genre onboarding protocol worked.** Did the second genre take 8 weeks (first time) or 4 weeks (returning)? What was faster? What was slower?
3. **Check if team elasticity proved correct.** Did new roles emerge as predicted? Did the core structure absorb them, or did the team need to restructure?
4. **Update the framework with what you learned.** Stamp the date and note what changed.

This framework is a hypothesis. Your job is to test it, refine it, and make it true.

---

---

**Co-authored-by:** Copilot <223556219+Copilot@users.noreply.github.com>


---

---

### New Project Playbook Created (Solo)
**Author:** Solo (Lead / Chief Architect)  
**Date:** 2025-07-21  
**Status:** Proposed  
**Scope:** Studio-wide — affects how every future project starts

Created `.squad/identity/new-project-playbook.md` — the definitive, repeatable process for starting any new project at First Frame Studios, regardless of genre, tech stack, IP, or platform.

**What It Contains:**
1. **Pre-Production Phase** — Genre research protocol (7-12 reference games, analytical play, skill extraction), IP assessment (original vs licensed), 9-dimension tech selection framework, team skill transfer audit, competitive analysis
2. **Sprint 0 Foundation** — Engine-agnostic repo checklist, squad adaptation guide, genre skill creation, architecture proposal requirements, minimum playable formula per genre, quality gates adaptation
3. **Production Phases** — P0-P3 priority system, parallel lane planning, skill capture rhythm, cross-project knowledge transfer
4. **Technology Transition Checklist** — What transfers/rewrites/needs evaluation, migration mapping (Canvas→Godot as template), repeatable training protocol
5. **Language/Stack Flexibility Matrix** — 12 tech stacks compared, T-shirt migration sizing, the 70/30 rule (70% of our effectiveness is tech-agnostic)
6. **Anti-Bottleneck Patterns** — 7 firstPunch bottlenecks with preventions, 6 common studio patterns, serialize/parallelize guide, add-role vs add-skill decision matrix

**Key Decisions Within:**
- **8-point migration threshold:** Require 8+ point lead in 9-dimension matrix to justify engine migration
- **20% load cap:** No agent carries more than 20% of any phase's items
- **Module boundaries in Sprint 0:** Architecture proposal required before Phase 2 code begins
- **Wiring requirement:** Every infrastructure PR must include connection to at least one consumer

**Why:** The founder wants solid foundations so starting any new project is clear, repeatable, and bottleneck-free. firstPunch taught us everything in this playbook through real bugs, real bottlenecks, and real breakthroughs. Documenting it ensures we never repeat the investigation.

**Impact:**
- Every future project follows this playbook from Day 1
- Pre-production becomes a structured process, not ad-hoc discovery
- Technology transitions follow a proven 4-phase pattern
- Bottleneck patterns are identified and mitigated proactively
- New team members can read this document and understand how we start projects

---

### Skills System Needs Structural Investment Before Next Project (Ackbar)
**Author:** Ackbar (QA Lead)  
**Date:** 2025-07-21  
**Status:** Proposed

Conducted comprehensive audit of all 12 skills in `.squad/skills/`. Quality of individual skills is strong (7/12 rated ⭐⭐⭐⭐+), but coverage (5/10) and growth-readiness (4/10) are the weaknesses.

**Decision:**
Three actions should be taken before the next project kicks off:

1. **Create `game-feel-juice` skill (P0)** — Our #1 principle ("Player Hands First") has no dedicated skill. Game feel patterns are scattered across 3 skills. A unified, engine-agnostic game feel reference should be the first skill any new agent reads. Assign to Yoda + Lando.

2. **Create `ui-ux-patterns` skill (P1)** — Wedge is a domain owner with zero skills. Every game needs UI. This is the largest single-agent gap on the team. Assign to Wedge.

3. **Structural cleanup (P1)** — Split `godot-beat-em-up-patterns` (39KB, too large). Resolve overlaps: merge `canvas-2d-optimization` into `web-game-engine`, deduplicate `godot-tooling` vs `project-conventions`. Assign to Solo + Chewie.

**Impact:**
- **Yoda, Lando:** Create `game-feel-juice` skill
- **Wedge:** Create `ui-ux-patterns` skill  
- **Solo, Chewie:** Structural cleanup of overlapping skills
- **All agents:** 6 skills should have confidence bumped from `low` to `medium`
- **Full audit:** `.squad/analysis/skills-audit.md` contains per-skill ratings, gap analysis, and improvement recommendations

---

# Decision: Flora Core Engine Architecture

**Date:** 2025-07-16  
**Author:** Chewie (Engine Developer)  
**Issue:** #3 — Core Game Loop and Scene Manager Integration  
**Status:** ✅ Implemented (PR #13)  
**Repo:** jperezdelreal/flora

---

## Context

Flora needed foundational engine infrastructure before any gameplay could be built. The scaffold provided stubs for SceneManager and EventBus but no game loop, input handling, or asset loading.

---

## Decisions

---

### 1. Fixed-Timestep Game Loop (Accumulator Pattern)
- GameLoop wraps PixiJS Ticker but steps in fixed 1/60s increments via time accumulator
- Max 4 fixed steps per frame prevents spiral of death on lag spikes
- Provides `frameCount` for deterministic logic and `alpha` for render interpolation
- **Rationale:** Deterministic state updates enable future save/replay/netcode. Variable-delta game logic causes desync bugs.

---

### 2. SceneContext Injection (No Global Singletons)
- Scenes receive `SceneContext = { app, sceneManager, input, assets }` in `init()` and `update()`
- No global `window.game` or singleton pattern
- **Rationale:** Explicit dependencies are testable, refactorable, and don't create hidden coupling.

---

### 3. Input Edge Detection Per Fixed Step
- `InputManager.endFrame()` clears pressed/released sets after each fixed-step update
- Raw key state persists across frames; edges are consumed once
- **Rationale:** Variable frame rates can cause missed inputs if edges are cleared per render frame instead of per logic step.

---

### 4. Scene Transitions via Graphics Overlay
- Fade-to-black using a Graphics rectangle with animated alpha (ease-in-out)
- No render-to-texture or extra framebuffers
- **Rationale:** Simple, GPU-efficient, works on all PixiJS backends (WebGL, WebGPU, Canvas).

---

## Alternatives Rejected
1. **Raw Ticker.deltaTime for game logic** — Non-deterministic, causes physics/timing bugs
2. **Global singleton for input/assets** — Hidden dependencies, harder to test
3. **CSS transitions for scene fades** — Breaks when canvas is fullscreen, not composable with game rendering


---

---

### GitHub Actions Cron Reduction (2025-07-16) — ARCHIVED

Reduced scheduled workflow frequency to lower monthly GitHub Actions run volume from ~4,320 to ~900.
- squad-heartbeat.yml: */15 * * * * → 0 * * * * (720 runs/month)
- squad-notify-ralph-heartbeat.yml: */30 * * * * → 0 */4 * * * (180 runs/month)
- Event triggers unchanged; only scheduled polling reduced.

---

### Ralph-Watch Guardrails (G10 + G11) — ARCHIVED

Two safeguards in ralph-watch.ps1 to prevent wasted cycles and ensure downstream repo currency.
- G10 — Roster Check: Ralph skips repos without .squad/team.md containing ## Members section
- G11 — Upstream Sync: After git pull, hub syncs .squad/skills/, quality-gates.md, governance.md, decisions.md to downstream repos with .squad/ directory; auto-commits as "chore: upstream sync from hub"
- Both features support DryRun mode; ASCII-safe logging for Windows PowerShell 5.1

---

