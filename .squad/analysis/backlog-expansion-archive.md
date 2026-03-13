# backlog-expansion.md — Full Archive

> Archived version. Compressed operational copy at `backlog-expansion.md`.

---

# firstPunch — Backlog Expansion (Specialist Team)

**Author:** Solo (Lead / Architect)  
**Date:** 2026-06-03  
**Context:** Team expanded from 4 (Solo, Chewie, Lando, Wedge) to 8 specialists (+Boba, Greedo, Tarkin, Ackbar). This document adds domain-specific items the original engineer-only team missed and re-assigns existing items to correct owners.

---

## 1. Existing Item Re-assignments

Items from the original 52-item backlog that should transfer to new specialist owners. Original owner shown for traceability.

### → Boba (VFX/Art Specialist)

| Original # | Item | Was | Now | Rationale |
|-------------|------|-----|-----|-----------|
| P1-2 | Hit impact VFX | Lando | **Boba** | VFX design, not gameplay logic |
| P1-9 | Brawler walk cycle | Lando | **Boba** (art) + Lando (hookup) | Art frames are Boba's domain; Lando wires to animation controller |
| P1-10 | Brawler attack animations | Lando | **Boba** (art) + Lando (hookup) | Same split — art vs mechanics |
| P1-11 | Enemy death animation | Lando | **Boba** | Visual effect, not AI/gameplay |
| P2-4 | Brawler redesign | Lando | **Boba** | Pure character art |
| P2-5 | Background overhaul | Lando | **Boba** | Environmental art |
| P2-9 | KO text effects | Wedge | **Boba** | VFX, not UI layout |
| P2-10 | Animated title screen | Wedge | **Boba** (art) + Wedge (layout) | Shared — Boba does animation art, Wedge does screen structure |
| P2-13 | Score pop-ups | Wedge | **Boba** | Floating VFX, not HUD element |

### → Greedo (Sound Designer)

| Original # | Item | Was | Now | Rationale |
|-------------|------|-----|-----|-----------|
| P0-4 | Kick sound effect | Chewie | **Greedo** | Sound design, not engine work |
| P0-5 | Jump sound effect | Chewie | **Greedo** | Sound design |
| P1-3 | Sound variation | Chewie | **Greedo** | Audio design pattern |
| P1-12 | Background music (procedural) | Chewie | **Greedo** | Music composition |
| P2-11 | Wave fanfares | Chewie | **Greedo** | Audio design |
| P3-11 | Full SFX library | Chewie | **Greedo** | Sound design at scale |
| P3-12 | Procedural music system | Chewie | **Greedo** | Music system design |

### → Tarkin (Enemy/Content Dev)

| Original # | Item | Was | Now | Rationale |
|-------------|------|-----|-----|-----------|
| P1-4 | Enemy attack throttling | Lando | **Tarkin** | Enemy coordination is content/AI design |
| P2-1 | Boss enemy | Lando | **Tarkin** | Boss design is content, not player mechanics |
| P2-2 | Fast enemy type | Lando | **Tarkin** | Enemy type design |
| P2-3 | Heavy enemy type | Lando | **Tarkin** | Enemy type design |
| P2-7 | Weapon pickups | Lando | **Tarkin** | Content/level design |
| P2-8 | Food/health pickups | Lando | **Tarkin** | Content/level design |
| P2-16 | Difficulty scaling | Lando | **Tarkin** | Content tuning |
| P3-5 | Ranged enemy type | Lando | **Tarkin** | Enemy type design |
| P3-6 | Shield enemy type | Lando | **Tarkin** | Enemy type design |
| P3-7 | Multiple levels | Lando | **Tarkin** | Level/content authoring |
| P3-9 | Environmental hazards | Lando | **Tarkin** | Level design |
| P3-10 | Destructible objects | Lando | **Tarkin** | Content objects |

### Load Impact Summary

| Role | Before (of 52) | After Re-assignment | Change |
|------|-----------------|---------------------|--------|
| Solo (Lead) | 2 | 2 | — |
| Chewie (Engine) | 11 | 4 | -7 (audio items freed) |
| Lando (Gameplay) | 26 | 10 | -16 (art + enemies + content freed) |
| Wedge (UI) | 9 | 6 | -3 (VFX items freed) |
| Boba (VFX/Art) | 0 | 9 | +9 |
| Greedo (Sound) | 0 | 7 | +7 |
| Tarkin (Enemy/Content) | 0 | 12 | +12 |
| Ackbar (QA) | 0 | 0 | Validates all items |

**Key result:** Lando drops from 26 items (50% of backlog, critical bottleneck) to 10 items focused purely on player mechanics — combos, jump attacks, special moves, grab/throw. This is the single biggest structural improvement.

---

## 2. Expanded Team Additions

New items that specialists would identify from their domain expertise. These are gaps that an engineer-only team wouldn't see.

### 2.1 Boba (VFX/Art) — 8 New Items

| # | Item | Priority | Complexity | Dependencies | Description |
|---|------|----------|-----------|--------------|-------------|
| EX-B1 | Art direction & color palette | P1 | S | None | Define cohesive visual style guide before any art work: primary palette (character yellow, Downtown greens/blues), outline weight, shading approach (flat vs cell-shaded), lighting direction. All subsequent art references this. Without it, art will look inconsistent across characters, backgrounds, and effects. |
| EX-B2 | Character ground shadows | P1 | S | None | Oval shadow sprite under every character. Scales smaller/lighter as character rises during jumps. Critical for 2.5D depth readability — without shadows, players can't tell where characters will land. |
| EX-B3 | Enemy attack telegraph VFX | P1 | S | P1-8 | Visual wind-up indicator before enemy attacks: brief flash, exclamation mark, or color shift. Players need ~300ms of visual warning to react fairly. Without this, enemy damage feels cheap. |
| EX-B4 | Attack motion trails | P2 | M | P1-8, P1-10 | Semi-transparent arc trails behind fists/feet during attacks. 3-4 frame afterimage that fades. Standard in modern beat 'em ups for making attacks feel fast and readable. |
| EX-B5 | Enemy spawn-in effects | P2 | S | P2-6 | Enemies shouldn't just appear. Dust cloud + drop-in from above, or shadow-on-ground → land effect. Gives player warning and feels polished. |
| EX-B6 | Foreground parallax layer | P2 | M | P2-5 | Lampposts, chain-link fences, fire hydrants that scroll PAST the camera in front of action at 1.3x speed. Adds dramatic depth. Background overhaul only covers layers behind the action. |
| EX-B7 | Consistent entity rendering style | P1 | M | EX-B1 | Implement shared rendering approach: consistent outline thickness, shadow/highlight placement, proportional style guide. Ensures Brawler, enemies, and pickups look like they belong in the same game. |
| EX-B8 | Environmental background animations | P3 | M | P2-5 | Animated background elements: drifting clouds, flickering neon signs (Joe's Bar, Quick Stop), blowing newspaper, steam from manholes. Backgrounds feel alive instead of static paintings. |

### 2.2 Greedo (Sound Designer) — 8 New Items

| # | Item | Priority | Complexity | Dependencies | Description |
|---|------|----------|-----------|--------------|-------------|
| EX-G1 | Audio context initialization | P0 | S | None | Web Audio API requires user gesture before playing sounds. Add proper "Click to Start" or first-keypress audio unlock. Without this, sound silently fails on first play in most browsers. The current code may already handle this, but it needs explicit verification and a robust fallback. |
| EX-G2 | Audio mix bus architecture | P1 | M | None | Separate gain nodes for SFX, Music, and UI channels routed through a master bus. Individual volume sliders in pause menu. Without mix buses, SFX and music compete at the same level, and players can't adjust balance. |
| EX-G3 | Hit sound layering | P1 | S | None | Layer 2-3 simultaneous components per hit: bass body thud (sine 60-80Hz) + mid impact crack (noise burst) + high sparkle (high-freq ping). Current single-oscillator hits sound thin and flat. This is the audio equivalent of hitlag for feel. |
| EX-G4 | Sound priority & deduplication | P1 | S | None | When 5 enemies get hit in one frame, don't play 5 overlapping identical sounds. Implement: max 3 simultaneous SFX of same type, slight pitch spread on duplicates, priority queue (player sounds > enemy sounds > ambient). Prevents audio mud. |
| EX-G5 | Player vocal sounds | P2 | M | None | Procedural "effort" sounds: grunt on punch (short noise burst), exertion on kick (longer), "oof" on damage (descending tone), landing thud on jump. Even simple synthesized vocals add massive character. |
| EX-G6 | Enemy vocal sounds | P2 | M | None | Per-enemy-type audio identity: grunts on attack, pain sounds on hit (pitch varies by enemy size), death sound (descending wail). Enemies feel like characters instead of silent punching bags. |
| EX-G7 | Spatial audio panning | P2 | S | None | Pan sounds left/right based on entity X position relative to camera center. Enemies attacking from the right sound right. Adds subconscious positional awareness, especially useful when enemies are off-screen. |
| EX-G8 | Combat music intensity layers | P2 | M | P1-12 | Music system with 2-3 intensity layers: ambient bass when walking, add drums when enemies spotted, add melody during active combat. Crossfade between layers based on game state. More nuanced than P3-12's full procedural system — this is the practical first step. |

### 2.3 Tarkin (Enemy/Content Dev) — 9 New Items

| # | Item | Priority | Complexity | Dependencies | Description |
|---|------|----------|-----------|--------------|-------------|
| EX-T1 | Enemy behavior tree upgrade | P1 | M | None | Replace simple state machine AI with lightweight behavior tree: selector → sequence nodes for approach/attack/retreat. Enables complex enemy behaviors (flank if ally attacking, retreat if low HP, gang-up logic) without spaghetti state transitions. Foundation for all enemy variety. |
| EX-T2 | Wave composition design rules | P1 | S | None | Document and implement spawn rules: never spawn a new enemy type alongside others (introduce solo first), mix melee + ranged, cap total on-screen enemies at 6, minimum 2-second gap between spawns. Prevents unfair wave compositions. |
| EX-T3 | Encounter pacing curve | P1 | S | None | Design the intensity shape for Level 1: easy intro wave (2 basics) → slightly harder (3 basics) → breather walk → new type intro (1 fast) → mixed wave → mini-boss → walk → final boss. Without intentional pacing, difficulty feels random. |
| EX-T4 | Content data format | P1 | M | P1-14 | Define JSON/object schema for levels, waves, and enemy definitions so content can be authored by editing data, not code. Schema: `{ waves: [{ trigger: x, enemies: [{ type, count, positions }] }] }`. Unlocks rapid content iteration. |
| EX-T5 | Boss phase framework | P2 | M | P2-1 | Generic boss phase system: health thresholds (75%, 50%, 25%) trigger phase transitions. Each phase has: attack pool, speed multiplier, visual change (color shift, particles), optional add spawns. Reusable for any boss across the game. |
| EX-T6 | Pickup drop table system | P2 | S | P2-7, P2-8 | Weighted probability tables for drops: enemy type × player health state → drop chances. Low-health player gets more food drops. Tough enemies drop weapons more often. Smart drops improve feel without explicit difficulty adjustment. |
| EX-T7 | Enemy group coordination | P2 | M | EX-T1, P1-4 | Beyond throttling (max 2 attack): assign group roles. One enemy is "attacker" (approaches aggressively), 1-2 are "flankers" (circle to sides), rest are "pressure" (close in slowly). Roles rotate on timer or when attacker gets hit. Fights feel choreographed, not random. |
| EX-T8 | Mini-boss encounters | P2 | M | EX-T1 | Mid-level tough enemy: single enhanced enemy (2x HP, unique attack like charge or ground slam) fought 1-on-1 between regular waves. Provides difficulty spike and preview of mechanics used by the final boss. Different from P2-1 (full boss) — this is a simpler mid-level challenge. |
| EX-T9 | Enemy intro sequences | P2 | S | EX-T2 | First appearance of each new enemy type gets a brief "showcase": camera pause, enemy enters alone, player fights it 1-on-1 before it appears in mixed waves. Teaches player the counter-strategy naturally. Standard beat 'em up design pattern that engineers rarely implement. |

### 2.4 Ackbar (QA/Playtester) — 8 New Items

| # | Item | Priority | Complexity | Dependencies | Description |
|---|------|----------|-----------|--------------|-------------|
| EX-A1 | Hitbox visualization debug mode | P1 | S | None | Toggle-able overlay (press ` key) showing all hitboxes (red), hurtboxes (green), and trigger zones (blue) in real-time. Essential for tuning combat fairness. Without visual hitboxes, balancing attack ranges is guesswork. |
| EX-A2 | Frame data documentation | P1 | S | None | Document every attack's startup frames, active frames, recovery frames, damage, knockback distance, and hitstun duration. Format as reference table. This is how fighting game devs balance — without it, tuning is ad hoc. |
| EX-A3 | Performance/feel debug overlay | P1 | S | None | Toggle-able debug HUD showing: current FPS, frame time (ms), entity count, active particles, collision checks/frame, input-to-render latency. Catches performance regressions before they ship. |
| EX-A4 | Edge case regression checklist | P1 | S | None | Document and test known edge cases: attack during knockback, jump at screen edge, pause during attack animation, die while attacking, enemy attack during hitstun, walk into camera lock boundary while jumping. Run checklist after every combat change. |
| EX-A5 | DPS balance analysis | P2 | S | P1-5 | Calculate theoretical and actual DPS for: punch spam, kick spam, optimal combo, jump attacks. Compare against enemy HP pools and wave total HP. Identify if any strategy is dominant or if enemies die too fast/slow. Drives numeric tuning. |
| EX-A6 | Playtest protocol & metrics | P2 | M | None | Structured playtest procedure: record deaths per wave, time per wave, health remaining at wave end, total score, combos landed vs dropped. Run 5+ playthroughs, aggregate data, identify difficulty spikes. Formal process prevents "feels fine to me" bias. |
| EX-A7 | Automated smoke test suite | P2 | M | P1-15 | Headless tests via event system: game initializes → player spawns → movement works → attack connects → enemy takes damage → enemy dies → score increments → wave clears → level completes. Catches regressions that manual play misses. Not a full test framework — just critical path verification. |
| EX-A8 | Input responsiveness audit | P2 | S | None | Measure and document actual input latency: keypress → state change → visual feedback. Test at 60fps, test during screen shake, test during hitlag. Verify attack buffering works (or document that it's intentionally absent). Players feel 1-frame delays even if they can't articulate why. |

---

## 3. Summary

### Backlog Growth

| | Original | Re-assigned | New | Total |
|---|----------|-------------|-----|-------|
| Items | 52 | 0 (moved, not added) | **33** | **85** |
| P0 | 5 | — | +1 | **6** |
| P1 | 20 | — | +14 | **34** |
| P2 | 17 | — | +14 | **31** |
| P3 | 14 | — | +1 | **15** |

**The backlog grows from 52 → 85 items (+63%).** This is expected — specialists see gaps in their domain that generalists miss. The growth is concentrated in P1 and P2 (foundational infrastructure and polish), not in stretch goals.

### New Items by Owner

| Owner | New Items | Key Theme |
|-------|-----------|-----------|
| Boba (VFX/Art) | 8 | Visual foundations (art direction, shadows, telegraphs) before art production |
| Greedo (Sound) | 8 | Audio infrastructure (mix bus, layering, priority) before sound content |
| Tarkin (Enemy/Content) | 9 | Content systems (behavior trees, data format, pacing) before content authoring |
| Ackbar (QA) | 8 | Development tools (hitbox viz, debug overlay, frame data) before testing |

### Pattern: Infrastructure Before Content

Every specialist's highest-priority additions are **systems and infrastructure**, not content. Boba wants art direction before drawing Brawler. Greedo wants mix buses before composing music. Tarkin wants data formats before designing levels. Ackbar wants debug tools before playtesting. This is the hallmark of experienced specialists — they build foundations first.

### Critical New P0 Item

**EX-G1: Audio context initialization** — Web Audio API silently fails without a user gesture. If this isn't handled, all audio work is wasted on first play. Greedo flags this as a P0 because it's a potential showstopper that engineers often overlook.

### Impact on Execution Phases

The original 6-phase plan holds, but phases get richer:

- **Phase 1 (P0):** Now includes audio context fix (EX-G1)
- **Phase 2 (P1 Feel):** Now includes art direction (EX-B1), ground shadows (EX-B2), enemy telegraphs (EX-B3), hit sound layering (EX-G3), sound priority (EX-G4), behavior trees (EX-T1), pacing curve (EX-T3), hitbox debug (EX-A1), frame data (EX-A2)
- **Phase 3 (P1 Infra):** Now includes mix bus (EX-G2), content data format (EX-T4), debug overlay (EX-A3), regression checklist (EX-A4), rendering style (EX-B7), wave rules (EX-T2)
- **Phase 4+ (P2):** Significantly richer with specialist polish items

The key insight: **more items doesn't mean more time** — the expanded team parallelizes. Boba, Greedo, Tarkin, and Ackbar all work simultaneously on their P1 items while Chewie, Lando, and Wedge continue on core mechanics.
