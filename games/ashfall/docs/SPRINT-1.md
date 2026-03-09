# Sprint 1 — Art Phase

**Sprint Owner:** Mace (Producer)  
**Sprint Theme:** Replace Procedural Placeholder Art with HD Pixel Art  
**Sprint Duration:** 2026-03-10 to 2026-03-20 (estimated 2 weeks)  
**Target Ship Date:** 2026-03-20  

---

## Sprint 1 Goal

Replace placeholder procedural art (green/blue rectangles) with final HD pixel art for characters, stage, and visual effects. End-to-end art pipeline: art direction → character sprites (all ~45 animation states per fighter) → stage background → character-specific VFX → AnimationPlayer integration → visual quality playtest.

---

## Scope (LOCKED)

### In Scope (Sprint 1)
- **Character Sprites:** Kael & Rhena — all ~45 animation states each (P0: core gameplay, P1: special moves, P2: polish)
  - P0 states: crouch idle + transition, jump (arc/peak/fall), standing + crouching block, punch attacks (LP/MP/HP standing + crouch), kick attacks (LK/MK/HK standing + crouch)
  - P1 states: Kael Ember Shot + Rising Cinder, Rhena Blaze Rush + Flashpoint
  - P2 states: throw execute, thrown victim, wake-up, forward dash, back dash, win pose, lose pose
  - **Resolution:** 128×128 px per frame (native), art direction locked before sprite creation
  - **Format:** PNG with transparency, frame naming per asset naming convention (see below)
  - **Delivery:** Sprites load at native resolution; no scaling; no placeholder rectangles visible

- **Stage Background (EmberGrounds):** Final multi-round visual progression
  - Round 1: Dormant volcano (cool color palette, minimal embers)
  - Round 2: Warming lava (orange glow, more ember particles)
  - Round 3: Full eruption (bright/hot lighting, maximum particles)
  - EventBus integration for round state changes (round_started signal)
  - Smooth color + particle transitions (1-2s lerp between rounds)
  - **Delivery:** Stage visually escalates 1→2→3; compatible with CharacterSprite 128×128 framing

- **Art Direction Document:** Finalized style guide
  - Character silhouettes (Kael zoner, Rhena rushdown — visually distinct)
  - Color palettes locked (Kael warm/meditation, Rhena sharp/aggressive)
  - Sprite animation timing guide (frames per pose)
  - VFX palette direction (character-specific themes)
  - Naming convention for all art assets (documented, enforced)
  - **Delivery:** Shared with Nien, Leia, Bossk as reference; signed off by Boba

- **Character-Specific VFX Palettes:** Visual effects differentiation
  - **Kael:** Ember particles (float upward, warm orange/yellow, round shapes)
  - **Rhena:** Burst particles (explode outward, red/white, angular shards)
  - VFXManager parametrized by character_id
  - Test bench validates both character palettes in VFX test scene
  - **Delivery:** VFX Manager updated; both character palettes functional and tested

- **AnimationPlayer Integration:** All sprites connected to engine
  - Chewie wires CharacterSprite frame output → AnimationPlayer playback
  - All ~45 states per fighter respond to game state changes (idle → walk → attack → hit → ko)
  - No timing gaps; transitions smooth (frame-perfect)
  - Integration gate passes (0 orphaned animation signals)
  - **Delivery:** Full 1v1 match playable with final art; no placeholder fallback

- **Visual Quality Playtest:** Ackbar QA sign-off
  - Ackbar completes full 1v1 match with final art
  - Silhouette test: both fighters visually distinct at glance
  - No visual glitches (sprite clipping, animation stutters, particle overlaps)
  - Playtest verdict: **PASS** (required to close sprint)

### Out of Scope (Sprint 2+)
- Audio (SFX, music, announcer) — Sprint 3 (Audio Phase)
- UI/UX polish (menus, HUD refinement, transitions) — Sprint 2 (UI Phase)
- Training mode (frame data, input history) — Deferred post-launch
- Additional characters or stages — Phase 5+ (Expansion)
- Story mode, cinematics, online multiplayer — Out of current roadmap

---

## Team & Agents

| Agent | Role | Deliverable | Effort | Start | Status |
|-------|------|-------------|--------|-------|--------|
| **Nien** | Character Artist | Kael + Rhena final sprites (all ~45 states) | 60h | M1 | Blocked until M0 (art direction) |
| **Leia** | Environment Artist | EmberGrounds final background + round transitions | 20h | M1 | Blocked until M0 (art direction) |
| **Boba** | Art Director | Art direction doc + silhouette validation + character naming convention | 16h | M0 (Day 1) | Ready to start |
| **Bossk** | VFX Artist | Kael + Rhena character-specific VFX palettes | 12h | M2 | Blocked until M1 (sprites) |
| **Chewie** | Engine Dev | AnimationPlayer integration (sprite → animation state wiring) | 24h | M2 | Blocked until M1 (sprites) |
| **Ackbar** | QA Lead | Visual quality playtest + silhouette validation + final verdict | 8h | M4 | Playtest scheduled Day 20 |

**Total Sprint Effort:** ~140 hours  
**Team Capacity (6 agents × 2 weeks × 20% load cap):** ~96 hours available  
**Risk:** Over capacity by ~44 hours. Mitigations:
1. Reduce sprite frame count if P2 states (throw/pose) cause bottleneck (de-scope to P0+P1 only = ~35 states)
2. Leia parallelizes with Nien on round transitions while Nien works on frame 25+
3. Bossk starts VFX sketch work while Nien completes Kael sprites (no wait)

---

## Dependency Graph & Milestone Gates

```
M0: Art Direction Locked (Boba)
    ├─ Silhouettes defined
    ├─ Color palettes finalized
    ├─ Sprite animation timing guide
    ├─ VFX character themes documented
    └─ Naming convention published
         │
         ├──→ M1: Character Sprites Drafted (Nien)
         │       ├─ Kael ~45 frames (P0+P1 complete, P2 in progress)
         │       ├─ Rhena ~45 frames (P0+P1 complete, P2 in progress)
         │       └─ Naming convention enforced
         │            │
         │            ├──→ M2: Sprites + VFX Ready (Bossk + Chewie)
         │            │       ├─ Kael + Rhena VFX palettes tested
         │            │       ├─ AnimationPlayer wired
         │            │       └─ Integration gate passes
         │            │            │
         │            └──→ M2b: Stage Background Final (Leia)
         │                   ├─ All 3 rounds visually complete
         │                   ├─ Round transitions smooth
         │                   └─ Compatible with character framing
         │                        │
         └──→ M3: Visual Integration Complete (Chewie + Bossk)
                ├─ Full 1v1 match playable with final art
                ├─ No placeholder rectangles anywhere
                ├─ All animation states responsive
                └─ 0 orphaned animation signals
                     │
                     └──→ M4: Ackbar Visual Playtest PASS (Ackbar)
                            ├─ Silhouette test: both fighters distinct
                            ├─ 1v1 match completion verified
                            ├─ Verdict: PASS (required)
                            └─ Sprint 1 Shipped
```

---

## Work Breakdown (Detailed per Agent)

### M0 — Art Direction Locked (Boba, Day 1–2)

**Deliverable:** `games/ashfall/docs/ART-DIRECTION.md`

**Acceptance Criteria:**
- [ ] Character silhouettes locked (Kael shoto, Rhena rushdown — visually distinct)
- [ ] Color palettes finalized (Kael: warm meditation theme; Rhena: sharp explosion theme)
- [ ] Sprite animation timing guide (frame count per pose, delays between poses)
- [ ] VFX character themes documented (Kael embers floating up; Rhena bursts exploding)
- [ ] Asset naming convention defined and enforced:
  - Format: `{character}_{state}_{frame_num}.png` (e.g., `kael_idle_01.png`, `rhena_attack_lp_03.png`)
  - Frame numbers 01–99 (left-zero-padded)
  - States use lowercase (idle, walk_fwd, walk_bak, crouch_idle, jump_up, jump_peak, jump_fall, punch_lp, etc.)
- [ ] Silhouette test passes (can distinguish both fighters at 64×64 px squint distance)

**Owner:** Boba (Art Director)  
**Blockers:** None (start immediately)  
**Dependency Output:** Nien, Leia, Bossk all reference this doc before creating assets

---

### M1 — Character Sprites Drafted (Nien, Day 3–12)

**Deliverable:** All Kael + Rhena sprites in `games/ashfall/assets/sprites/characters/`

**Acceptance Criteria:**
- [ ] **Kael sprites complete:** ~45 frames across all P0, P1, P2 states
  - P0: idle, walk_fwd, walk_bak, crouch_idle, crouch_transition, jump_up, jump_peak, jump_fall, block_stand, block_crouch, punch_lp (stand + crouch), punch_mp (stand + crouch), punch_hp (stand + crouch), kick_lk (stand + crouch), kick_mk (stand + crouch), kick_hk (stand + crouch) = ~30 frames
  - P1: ember_shot (charge, fire), rising_cinder (startup, active, recovery) = ~8 frames
  - P2: throw_execute, throw_victim, wake_up, dash_fwd, dash_bak, win_pose, lose_pose = ~7 frames
  - **Total: ~45 frames**

- [ ] **Rhena sprites complete:** ~45 frames (same states as Kael)
  - Same structure as Kael
  - **Total: ~45 frames**

- [ ] **Quality gates:**
  - 128×128 px per frame (native resolution, no downscaling)
  - PNG format with transparency
  - Naming convention enforced (boba's M0 doc)
  - Silhouettes visually distinct (Kael lean/sharp, Rhena muscular/compact)
  - Animation flow smooth (no visual jumps between poses)

- [ ] **File organization:**
  - `games/ashfall/assets/sprites/characters/kael/` contains all Kael PNG files
  - `games/ashfall/assets/sprites/characters/rhena/` contains all Rhena PNG files
  - No duplicate frames; no empty directories

**Owner:** Nien (Character Artist)  
**Blockers:** M0 (art direction must be locked)  
**Dependency Output:** Chewie + Bossk can start integration work once Nien completes first batch (e.g., P0 states for Kael = 30 frames)

**Risk Mitigation:**
- If P2 states cause bottleneck (throw/wake-up complexity), de-scope to P0+P1 only (keep ~35 states). P2 moves to Sprint 2 polish phase.
- Leia can start EmberGrounds work in parallel (doesn't depend on Nien).

---

### M1b — Stage Background Final (Leia, Day 5–14)

**Deliverable:** Updated `games/ashfall/scripts/stages/ember_grounds.gd` + stage asset files

**Acceptance Criteria:**
- [ ] **Round 1 visual state:** Dormant volcano
  - Cool color palette (blues, grays, dark volcanic rock)
  - Minimal ember particles (0–2 floating embers)
  - Static background, low intensity lighting

- [ ] **Round 2 visual state:** Warming lava
  - Transitional color palette (orange glow increases)
  - More ember particles (5–10 floating embers)
  - Lava surface starts to glow

- [ ] **Round 3 visual state:** Full eruption
  - Hot color palette (bright orange, yellow, red highlights)
  - Maximum ember particles (20–30 particles)
  - Screen edges glow; stage becomes visually intense

- [ ] **Technical implementation:**
  - EventBus integration: listens to `round_started` signal
  - Color lerp transitions between rounds (1–2 second smooth fade)
  - Particle emission rate adjusts per round (0→5→20 particles/sec)
  - Compatible with 128×128 character sprite framing (stage doesn't overlap or hide fighters)

- [ ] **Testing:**
  - Full 3-round match: stage escalates visually 1→2→3
  - Round transitions are smooth (no abrupt color jumps)
  - Particles don't clip through fighters
  - EmberGrounds.gd integration gate passes

**Owner:** Leia (Environment Artist)  
**Blockers:** M0 (art direction for color palette + VFX themes)  
**Dependency Output:** Used in M3 visual integration; required for M4 playtest

---

### M2 — Character-Specific VFX Palettes (Bossk, Day 8–15)

**Deliverable:** Updated `games/ashfall/scripts/vfx/vfx_manager.gd` + VFX test scene

**Acceptance Criteria:**
- [ ] **Kael VFX palette:**
  - Ember particles spawn on hit (float upward, warm orange/yellow, round shapes)
  - Particle physics: slow upward drift (~50 px/s), fade over 1 second
  - Color: orange RGB(255, 165, 0) → yellow RGB(255, 255, 100)
  - Shape: round/circular embers
  - Emission count: 3–5 per hit

- [ ] **Rhena VFX palette:**
  - Burst particles spawn on hit (explode outward, red/white, angular shards)
  - Particle physics: fast radial spread (~200 px/s), fade over 0.5 second
  - Color: red RGB(255, 0, 0) → white RGB(255, 255, 255)
  - Shape: angular shards/fragments
  - Emission count: 8–12 per hit

- [ ] **Technical implementation:**
  - VFXManager accepts `character_id` parameter (new signature: `spawn_hit_vfx(position, character_id)`)
  - Character-specific particle behavior defined per character
  - Test scene: side-by-side VFX comparison (Kael vs Rhena)
  - Integration gate passes (0 orphaned VFX signals)

- [ ] **Testing:**
  - VFX test bench loads both character particles
  - Visual inspection: VFX clearly differentiate character identity
  - Particle counts consistent per hit
  - No visual glitches (particles clipping, overlaps, stutters)

**Owner:** Bossk (VFX Artist)  
**Blockers:** M1 (Nien's sprites needed for placement reference)  
**Dependency Output:** Used in M3 + M4; required for visual identity completion

---

### M2b — AnimationPlayer Integration (Chewie, Day 10–17)

**Deliverable:** Updated `games/ashfall/scripts/fighters/character_sprite.gd` + wired AnimationPlayer

**Acceptance Criteria:**
- [ ] **All animation states wired:**
  - Every fighter state (idle, walk, crouch, block, attack, hit, ko, etc.) mapped to sprite frame sequence
  - AnimationPlayer animations created for all ~45 states per fighter
  - Sprite frame playback synchronized with game state changes

- [ ] **Frame-perfect animation transitions:**
  - No gaps between poses
  - State changes trigger correct animation (attack starts at frame 0, not mid-animation)
  - Hit knockback/stun animations cut off previous action correctly
  - KO animation plays to completion (no interrupt)

- [ ] **Asset integration:**
  - Sprites load from disk at 128×128 px (no scaling)
  - Naming convention enforced (boba's M0 doc)
  - No placeholder rectangles visible anywhere in fight scene
  - All ~90 sprites (45 Kael + 45 Rhena) load without errors

- [ ] **Technical gates:**
  - Integration gate passes (0 orphaned animation signals, 0 missing sprite references)
  - CI tests: all sprite files found, all animation states respond to game events
  - Performance: animation playback at 60 FPS (no dropped frames)

**Owner:** Chewie (Engine Dev)  
**Blockers:** M1 (Nien's sprites must be created and named correctly)  
**Dependency Output:** Required for M3 + M4; unblocks Ackbar playtest

---

### M3 — Visual Integration Complete (Chewie + Bossk, Day 15–18)

**Deliverable:** Full 1v1 match with final art

**Acceptance Criteria:**
- [ ] **Sprites + VFX + Stage all present:**
  - 1v1 fight scene contains no placeholder rectangles
  - All sprites render correctly (no missing textures, no fallback art)
  - VFX particles spawn on hits with character-specific palettes
  - Stage background displays with correct round state

- [ ] **Full game loop playable:**
  - Menu → Character Select → Fight Scene (with final art) → Victory → Rematch/Exit
  - Both fighters fully animated (all ~45 states each)
  - Animations respond to all game events (move startup, active, recovery, hit, block, ko, etc.)

- [ ] **Quality gates:**
  - No visual glitches (sprite clipping, animation stutters, particle overlaps)
  - Animation timing matches game mechanics (hitstun duration, knockback travel, block recovery)
  - 60 FPS maintained during play (no stutters, no frame drops)
  - Integration gate passes (0 orphaned signals, 0 missing assets)

**Owner:** Chewie (Lead) + Bossk  
**Blockers:** M1 (sprites), M2 (VFX), M1b (stage)  
**Dependency Output:** Enables M4 playtest

---

### M4 — Ackbar Visual Playtest PASS (Ackbar, Day 19–20)

**Deliverable:** `SPRINT-1-SUCCESS.md` + Playtest Report

**Acceptance Criteria:**
- [ ] **Silhouette test:** Both fighters visually distinct at glance (can identify Kael vs Rhena without UI labels)
- [ ] **Full 1v1 match:** Ackbar completes full match (3 rounds, winner declared) with no visual crashes
- [ ] **Visual quality verdict:** No major glitches observed (sprite clipping, animation stutters, particle overlaps)
- [ ] **Playtest verdict:** **PASS** (required to close sprint; PASS WITH NOTES acceptable only if critical follow-ups documented for Sprint 2)
- [ ] **Documentation:** Final success criteria all checked; lessons learned logged

**Owner:** Ackbar (QA Lead)  
**Blockers:** M3 (integration complete)  
**Dependency Output:** Enables Sprint 1 ship ceremony

---

## Open Issues Being Addressed

| Issue | Title | Owner | Sprint 1 Action |
|-------|-------|-------|-----------------|
| #91 | Expand character sprite poses (~37 missing states) | Nien | All ~45 states per fighter delivered in M1 |
| #50 | Character-Specific VFX Palettes (Kael/Rhena) | Bossk | Kael + Rhena palettes implemented in M2 |
| #55 | Stage Round Transitions (EmberGrounds) | Leia | All 3 rounds + transitions implemented in M1b |
| #9 | Character-Specific Placeholder Sprites | ~~Nien~~ | ✅ CLOSED (Sprint 0) — M1 replaces with final art |

---

## Scope Lock & Change Control

**Scope is LOCKED.** Any feature request during Sprint 1 follows this protocol:

1. **Request filed** in GitHub issues (labeled `game:ashfall`, `sprint:1`)
2. **Yoda triages** (Four-Test Framework: core loop impact, player impact, cost-to-joy, coherence)
3. **Decision:** Accept (add to sprint) / Defer (move to Sprint 2+)
4. **Mace documents** in `.squad/decisions/inbox/`
5. **Joperezd approves** (if adding work, check against 20% load cap)
6. **Team notified** (#ashfall Slack ping)

**Current load:** 140 hours planned; 96 hours capacity (6 agents × 20% × 2 weeks). **Over by 44 hours.** Mitigation: de-scope P2 states if necessary.

---

## Success Criteria Summary

✅ **Functional:**
- All ~45 animation states per fighter implemented and responsive in-game
- Stage visually progresses across 3 rounds with smooth transitions
- Character-specific VFX clearly differentiate Kael vs Rhena

✅ **Technical:**
- All sprites load at native 128×128 px (no scaling)
- M0–M4 gates all passed
- Integration gate passes (0 orphaned signals, 0 missing assets)
- 60 FPS performance maintained

✅ **Quality:**
- Silhouette test: both fighters visually distinct
- Ackbar visual playtest verdict: **PASS**
- No placeholder rectangles visible

✅ **Documentation:**
- Art Direction document (boba-art-direction.md) finalized
- Asset naming convention published and enforced
- Sprint 1 Success document (SPRINT-1-SUCCESS.md) completed
- Lessons learned logged

---

## Critical Path & Timeline

```
2026-03-10 (Day 1):   M0 Art Direction locked (Boba)
2026-03-11–12:        Nien + Leia start sprites + stage (M1, M1b)
2026-03-13:           Bossk starts VFX sketch work (parallel, no wait)
2026-03-14:           Chewie starts AnimationPlayer wiring (M1 sprite batch 1 ready)
2026-03-15:           M2 VFX implementation complete (Bossk)
2026-03-17:           M2b Stage background final (Leia)
2026-03-18:           M3 Integration complete (Chewie + Bossk verify)
2026-03-19:           Final bug fixes + polish
2026-03-20:           M4 Ackbar visual playtest + PASS verdict
2026-03-20:           Sprint 1 shipped (tag: sprint-1-shipped)
```

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|-----------|
| Sprite frame count exceeds 45/char | Sprint overruns by 1 week | HIGH | De-scope P2 states (throw/pose) to Sprint 2; lock P0+P1 at ~35 states |
| Animation timing doesn't match game mechanics | Playtest fails (hitstun doesn't align) | MEDIUM | Lando provides frame data; Chewie tests sync daily |
| VFX particles cause performance drop | 60 FPS not maintained | LOW | Bossk caps particle count; performance profiling in M2 |
| Stage background clips/overlaps fighters | Playtest fails | LOW | Leia references 128×128 frame boundary; Chewie tests placement in M3 |

---

## Escalation & Communication

**Daily standup:** Async written updates in #ashfall (not sync meetings)  
**Blocker escalation:** Any task stuck >4 hours → ping Mace immediately  
**Milestone gates:** Closed only when acceptance criteria all checked ✅  
**Playtest scheduling:** Ackbar receives final build Day 19; playtest Date = Day 20  

---

## Definition of Success

See `SPRINT-1-SUCCESS.md` for detailed success criteria, verification checklist, and ship ceremony.

**Short version:**
- All animation states render and transition correctly
- Sprites load at native 128×128 px (no placeholder rectangles)
- Characters visually distinct (silhouette test passes)
- Ackbar visual playtest verdict: **PASS**
- All documentation current
- Git tag: `sprint-1-shipped` created

---

*Mace (Producer) — Sprint 1 Kickoff Plan, 2026-03-10*
