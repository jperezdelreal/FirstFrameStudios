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

## Ashfall Art Sprint Directives (2026-03-09)

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

