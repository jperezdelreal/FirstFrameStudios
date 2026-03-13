# skills-audit.md — Full Archive

> Archived version. Compressed operational copy at `skills-audit.md`.

---

# Skills Audit — First Frame Studios

> **Author:** Ackbar (QA Lead / Playtester)
> **Date:** 2025-07-21
> **Scope:** All 12 skills in `.squad/skills/`
> **Context:** Studio expanded to 13 specialists. Vision spans multi-genre, multi-tech, multi-platform. Founder asked: "Are our skills solid? What's missing? What needs improvement?"

---

## A. Quality Assessment — Per Skill

### 1. `2d-game-art` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | 10 substantive patterns covering pipeline, style guide, color theory, animation, VFX, parallax, UI, procedural-to-sprite migration criteria |
| **Accuracy** | High | Canvas API patterns are correct; DPR handling, bezier curves, seeded random — all verified in firstPunch |
| **Actionability** | High | Copy-paste code examples for every pattern. An agent can read this and draw a character immediately |
| **Genre Independence** | Good | Mostly universal 2D art. Minor Canvas-specific lean, but patterns transfer to any 2D renderer |
| **Confidence** | `high` — **Justified.** Earned through shipped project |

**Strengths:** The "When to Switch from Procedural to Sprites" decision table is reference-quality. Style guide enforcement pattern is studio-grade.
**Weaknesses:** No mention of sprite sheet workflows, animation software pipelines (Aseprite, Spine), or 2D lighting techniques. Title says "2D game art" but content is 80% "procedural Canvas art." If we switch to sprites (which we will), most of this becomes historical reference, not active guidance.

---

### 2. `beat-em-up-combat` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | Attack lifecycle, hitbox/hurtbox, combo systems, enemy archetypes, boss phases, game feel checklist — comprehensive |
| **Accuracy** | High | Frame data targets align with genre conventions. Anti-patterns are real bugs from our codebase |
| **Actionability** | Very High | The frame data reference table alone is worth the entire skill. Checklist is immediately usable |
| **Genre Independence** | Correct | Properly genre-specific. This SHOULD be beat-em-up-only, and it is |
| **Confidence** | `low` — **Too conservative.** Should be `medium`. This skill is earned through shipped gameplay + thorough analysis from 4 agents |

**Strengths:** The game feel checklist (hitlag, knockback, screen shake, hit VFX, SFX, flash, slow-mo) is the single best pattern in our entire skills library. Enemy design vocabulary table is immediately actionable.
**Weaknesses:** Boss design section is theoretical — we haven't shipped a boss fight yet. Combo system patterns are "recommended" but unvalidated in code. Confidence should be bumped to `medium`.

---

### 3. `canvas-2d-optimization` ⭐⭐⭐ (Solid)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | Medium-High | HiDPI, sprite caching, text rendering, performance budgets, PixiJS migration criteria |
| **Accuracy** | High | DPR fix is battle-tested. Performance numbers are realistic |
| **Actionability** | High | Copy-paste DPR setup. Performance budget table is immediately useful |
| **Genre Independence** | Mixed | The optimization patterns are universal for Canvas 2D. But Canvas 2D itself is becoming legacy for us |
| **Confidence** | `low` — **Too conservative.** Should be `medium`. DPR patterns are proven |

**Strengths:** The "When to Consider PixiJS Migration" decision table is excellent — clear criteria, not opinion-based. Performance budget table prevents premature optimization debates.
**Weaknesses:** Significant overlap with `web-game-engine` (both cover DPR, renderer setup, Canvas patterns). If we move to Godot/Unity, this entire skill becomes archive-only. Migration cost estimates are unvalidated.

---

### 4. `game-qa-testing` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | Execution tracing, state machine audits, playtest protocols, bug severity matrix, regression testing, absence-of-code detection |
| **Accuracy** | High | Every pattern was learned from real bugs we shipped. Hard-won |
| **Actionability** | Very High | State machine audit table template is immediately usable. Regression checklist is runnable |
| **Genre Independence** | Good | 90% universal. The regression checklist is combat-flavored but the methodology is portable |
| **Confidence** | `low` — **Justified.** The methodology is proven, but the confidence is earned humility from the missed bugs. Keep it low as a reminder |

**Strengths:** The "Trace Execution, Don't Just Read Code" pattern is the most important lesson we've learned as a studio. Absence-of-code detection technique is genuinely novel. Confidence calibration rule (max 8/10 without full audit) is wisdom.
**Weaknesses:** The 10-item regression checklist is combat-specific (attack strings, hitboxes). Needs a generic version for non-combat games. No automated testing patterns (unit tests, integration tests). No CI/CD QA integration patterns.

---

### 5. `godot-4-manual` (+ Part 2) ⭐⭐⭐ (Solid)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | 12 sections across two files covering nodes, GDScript, signals, scene architecture, physics, animation, input, audio, tilemaps, project org, patterns, migration mapping |
| **Accuracy** | Medium-High | Content aligns with Godot 4.x docs. Some patterns may lag behind 4.3+ changes (TileMapLayer replacing TileMap) |
| **Actionability** | High | Migration mapping table (Section 12) is the crown jewel — any agent porting from JS can use it immediately |
| **Genre Independence** | Mixed | Framed as "for firstPunch port" but content is 80% universal Godot 4. Beat-em-up examples leak into general sections unnecessarily |
| **Confidence** | Part 1: `low` (no header), Part 2: `medium` — **Part 2 is correct, Part 1 should match** |

**Strengths:** The JS → Godot migration table is reference-quality and unique to our studio's specific path. Section 4 (Scene Architecture) gives a complete, ready-to-use scene tree. Two-part split keeps file sizes manageable.
**Weaknesses:** Beat-em-up content leaks into what should be engine-general material (Section 4 is titled "Scene Architecture for Beat 'Em Up" — should be generic with beat-em-up as one example). Missing Godot 4.3+ features (TileMapLayer, improved AnimationMixer). No coverage of Godot's debugging tools, profiler, or remote debugging. The two-part split is awkward — should either be reorganized or properly cross-linked.

---

### 6. `godot-beat-em-up-patterns` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | Very High | 39KB, 1308 lines — the largest skill by far. Covers combat, AI, movement, levels, UI in exhaustive Godot-native detail |
| **Accuracy** | High | GDScript patterns follow Godot best practices. Hitbox/hurtbox, collision layers, knockback, hitlag — all correctly implemented |
| **Actionability** | Very High | Every pattern is copy-paste GDScript. An agent could build a working beat-em-up prototype from this skill alone |
| **Genre Independence** | Correct | Properly genre-specific AND engine-specific. This is exactly what a `{engine}-{genre}-{topic}` skill should be |
| **Confidence** | `low` — **Too conservative.** Should be `medium`. The patterns are authored from proven skills (beat-em-up-combat + state-machine-patterns) translated into GDScript |

**Strengths:** Attack throttling via Godot groups is an elegant, Godot-native solution. The hitbox/hurtbox pattern with collision layers is production-ready. Camera lock zones with wave spawning is a complete, wirable system.
**Weaknesses:** At 39KB, this is too large. Should be split into 3-4 focused skills (`godot-combat`, `godot-enemy-ai`, `godot-level-flow`, `godot-movement-2.5d`). The sheer size makes it hard to find specific patterns quickly. Some patterns duplicate `beat-em-up-combat` content in GDScript form — could reference instead of repeat.

---

### 7. `godot-tooling` ⭐⭐⭐ (Solid)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | Medium-High | EditorPlugins, scene templates, autoloads, resources, GDScript style, CI/CD |
| **Accuracy** | High | Patterns follow Godot 4 conventions correctly |
| **Actionability** | High | Plugin skeleton, template hierarchy, CI/CD YAML — all directly usable |
| **Genre Independence** | Good | Mostly engine-general tooling. Scene templates lean beat-em-up (entity_base, enemy_base) but the pattern is universal |
| **Confidence** | `low` — **Justified.** Synthesized, not battle-tested. No Godot project has been shipped yet |

**Strengths:** The anti-patterns section is excellent — "Build It, Don't Wire It" and "Everyone Owns project.godot" are real patterns from our experience. CI/CD with `barichello/godot-ci` is practical.
**Weaknesses:** Significant overlap with `project-conventions` (both cover GDScript style, folder structure, naming). EditorPlugin section is introductory — no complex examples. No coverage of Godot's debugging tools, GDScript LSP integration, or editor customization beyond plugins.

---

### 8. `multi-agent-coordination` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | File ownership, integration contracts, drop-box pattern, integration passes, conflict patterns |
| **Accuracy** | High | Every pattern earned from 72+ agent spawns. Real war stories |
| **Actionability** | Very High | The code review checklist for multi-agent changes is immediately usable |
| **Genre Independence** | Excellent | 100% genre-agnostic. Works for any multi-agent software project |
| **Confidence** | `low` — **Too conservative.** Should be `medium`. This skill is battle-tested across our entire development history |

**Strengths:** The integration contract pattern is our most valuable process innovation. "When to Serialize vs. Parallelize" decision table is clear and correct. The 214-LOC unwired infrastructure stat is a powerful cautionary tale.
**Weaknesses:** Missing patterns for: async agent communication (beyond drop-box), conflict resolution when two agents disagree, skill versioning/ownership. No patterns for scaling beyond 13 agents.

---

### 9. `procedural-audio` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | Bus topology, 6 synthesis patterns, variation system, adaptive music, spatial audio |
| **Accuracy** | High | Web Audio API usage is correct. Frequency cheat sheet is a genuine reference |
| **Actionability** | Very High | Every synthesis pattern has working code. Frequency cheat sheet is immediately usable |
| **Genre Independence** | Good | Core synthesis patterns are universal. Spatial audio section is web-specific |
| **Confidence** | No header — **Should be `medium`.** The 21-sound system was shipped |

**Strengths:** The frequency cheat sheet is unique — I haven't seen this in any other game dev reference. Layered hit pattern (bass + mid + high) is genuinely useful game audio advice. sfxBus swap technique for spatial audio is clever.
**Weaknesses:** 100% Web Audio API. No coverage of audio in Godot, Unity, or any other engine. No patterns for working with audio files (mixing, mastering, format selection). The adaptive music scheduler is partially documented ("see full implementation" placeholder). Missing: audio for accessibility (captions, mono mix, volume presets).

---

### 10. `project-conventions` ⭐⭐⭐⭐⭐ (Reference Quality)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | Very High | 519 lines covering GDScript style, file naming, scene conventions, folder structure, Git workflow, documentation standards, review checklist, 8 anti-patterns |
| **Accuracy** | High | Follows Godot official style guide faithfully. Git conventions are standard |
| **Actionability** | Excellent | Every section is a "do exactly this" specification. No ambiguity |
| **Genre Independence** | Excellent | 100% genre-agnostic. Pure project hygiene |
| **Confidence** | `high` — **Justified.** This is a standards document, not a technique. Standards don't need battle-testing; they need clarity, and this has it |

**Strengths:** The only skill I'd rate 5 stars. Complete, unambiguous, and immediately enforceable. The well-structured GDScript example at the end is a perfect reference. Anti-patterns section catches real mistakes we've made. Review checklist is comprehensive without being burdensome.
**Weaknesses:** Godot-specific. When we use Unity or Unreal, we'll need analogous convention docs. Minor: no mention of code review processes (PR review, pair review, async review). No release/versioning conventions.

---

### 11. `state-machine-patterns` ⭐⭐⭐⭐ (Excellent)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | High | Exit paths, transition tables, guard conditions, timeouts, timer separation, testing |
| **Accuracy** | High | Every pattern maps to a real bug we shipped and fixed |
| **Actionability** | Very High | The transition table template is the single most useful debugging tool we have |
| **Genre Independence** | Excellent | 100% universal. Works for any game, any engine, any genre |
| **Confidence** | `low` — **Too conservative.** Should be `medium`. These patterns prevented recurrence of our two worst bugs |

**Strengths:** Timer separation pattern (the conflation anti-pattern) is the highest-impact lesson from firstPunch. The state machine audit checklist is QA gold. "Missing negative code" anti-pattern is genuinely insightful.
**Weaknesses:** Only covers flat state machines. No patterns for hierarchical state machines (HSM), behavior trees, or pushdown automata — all of which we'll need for complex AI in future games. Code examples are JavaScript-only; should include GDScript equivalents or reference the Godot skill.

---

### 12. `web-game-engine` ⭐⭐⭐ (Solid)

| Criterion | Score | Notes |
|-----------|-------|-------|
| **Depth** | Medium-High | 8 systems covered (game loop, renderer, input, audio, animation, events, particles, sprite cache) |
| **Accuracy** | High | Patterns match our shipped codebase |
| **Actionability** | High | Each system has a working code skeleton |
| **Genre Independence** | Good | Engine infrastructure is genre-agnostic. Architecture is universal |
| **Confidence** | No header — **Should be `medium`.** We shipped a game on this engine |

**Strengths:** Fixed-timestep game loop pattern is correct and well-explained. HiDPI propagation warning is critical knowledge. The "dual-update for visual systems" matrix is excellent.
**Weaknesses:** Heavy overlap with `canvas-2d-optimization` (DPR handling, renderer) and `procedural-audio` (audio bus, synthesis). If we leave Canvas 2D, this becomes archive-only. Performance targets differ from `canvas-2d-optimization` (budget mismatch: <300 calls here vs <500 there). Missing: touch input, gamepad support, mobile considerations.

---

## B. Gap Analysis — Missing Skills

### P0 — Needed Now

| Skill Name | Description | Why P0 |
|------------|-------------|--------|
| `game-feel-juice` | Universal game feel systems: screen shake, hitlag, knockback, flash, slow-mo, camera emphasis. Engine-agnostic principles + implementation per engine | Referenced in growth-framework.md but never created. Our principles say "game feel is the core product." We have game feel patterns scattered across `beat-em-up-combat` and `godot-beat-em-up-patterns` but no unified, genre-agnostic skill |
| `game-design-methodology` | Genre research process, GDD templates, reference game analysis, mechanic prototyping, balance framework | Our design process is described in growth-framework.md and principles.md but has no structured skill. Yoda needs a codified design methodology skill to onboard to new genres consistently |
| `input-handling` | Input buffering, coyote time, action mapping, gamepad support, touch input, accessibility (remapping) | Input patterns are scattered across `web-game-engine` and `godot-4-manual`. Critical for every game we make. Needs its own universal skill |

### P1 — Needed for Next Project

| Skill Name | Description | Why P1 |
|------------|-------------|--------|
| `level-design-fundamentals` | Level layout grammar, pacing curves, teach-by-doing, camera placement, difficulty ramping. Genre-agnostic foundations | Growth-framework lists this for platformer vertical but the fundamentals apply to every genre. We have no level design knowledge documented |
| `ui-ux-patterns` | Menu flow, HUD design, accessibility standards (WCAG for games), onboarding flow, information hierarchy, responsive layouts | Wedge's entire domain has zero skills. UI/UX is critical for every game and we have nothing |
| `animation-systems` | Sprite sheet workflows, skeletal animation, animation state machines, 12 principles of animation for games, timing/spacing | Our `2d-game-art` mentions animation basics but doesn't cover workflows, tools, or state machine integration. Nien needs this |
| `automated-testing` | Unit testing game systems, integration tests, state machine verification, CI/CD test gates, regression automation | `game-qa-testing` is manual-only. As we scale, manual QA won't catch everything. We need automated testing patterns |
| `release-management` | Build pipelines, versioning, distribution (itch.io, Steam, web), playtesting distribution, hotfix process | No skill covers how to ship a game to players. Completely missing from our knowledge base |

### P2 — Future (2+ Projects Out)

| Skill Name | Description | Why P2 |
|------------|-------------|--------|
| `narrative-design` | Dialogue systems, branching narratives, environmental storytelling, character voice consistency | Not needed until we make a story-driven game. Action RPG or narrative game would require it |
| `3d-fundamentals` | Camera orbiting, spatial combat, depth perception, lock-on systems, 3D lighting basics | Listed in growth-framework for future 3D action vertical. Not needed until then |
| `networking-multiplayer` | Rollback netcode, client-server architecture, state synchronization, lag compensation | Listed for fighting game vertical. Not needed until we go online |
| `localization` | String externalization, RTL support, cultural adaptation, font coverage, QA for localized builds | Needed when we ship internationally. Low priority for first few projects |
| `accessibility-design` | Colorblind modes, control remapping, difficulty options, subtitle systems, screen reader support | Should arguably be P1, but current scope is small enough to handle ad-hoc. Will become critical at scale |
| `procedural-content-generation` | Wave/level generation, loot tables, enemy variation, randomized encounters | Listed for Action RPG vertical. Not needed until then |
| `performance-profiling` | Engine-agnostic profiling methodology, budget management, optimization strategies per platform | We have Canvas-specific perf patterns. Need a universal profiling skill for multi-engine work |

---

## C. Improvement Recommendations

### Skills Rated ⭐⭐⭐ (Solid — Need Improvement)

#### `canvas-2d-optimization` → Needs Clarification of Scope

| Issue | Fix | Owner | Effort |
|-------|-----|-------|--------|
| Overlaps heavily with `web-game-engine` (DPR, renderer setup) | Merge rendering patterns into `web-game-engine`; keep `canvas-2d-optimization` focused purely on performance | Chewie | M |
| Performance budget conflict (300 vs 500 calls/frame between skills) | Reconcile targets — one authoritative budget table | Chewie | S |
| Canvas 2D is becoming legacy tech for us | Add a clear "Maturity: Archive" header when we commit to Godot. Don't delete, but mark as historical | Solo | S |

#### `godot-4-manual` → Needs Genre Decoupling and Updates

| Issue | Fix | Owner | Effort |
|-------|-----|-------|-------|
| Beat-em-up content leaks into general engine sections | Rename Section 4 from "Scene Architecture for Beat 'Em Up" to "Scene Architecture" with beat-em-up as one example | Chewie | S |
| Missing Godot 4.3+ features (TileMapLayer, AnimationMixer) | Update with latest Godot 4.x API changes | Chewie | M |
| Two-part split is awkward with no cross-linking | Add "See Part 2 for..." references, or merge into a single well-organized file | Chewie | S |
| Inconsistent confidence between parts | Align both to `medium` | Chewie | S |

#### `godot-tooling` → Needs Deduplication

| Issue | Fix | Owner | Effort |
|-------|-----|-------|--------|
| Duplicates GDScript style and folder structure from `project-conventions` | Remove duplicated sections. Reference `project-conventions` instead. Keep only tooling-specific content (EditorPlugins, CI/CD, build automation) | Solo | M |
| EditorPlugin section is introductory | Add at least one complex example (scene validator, hitbox visualizer) | Chewie | M |

#### `web-game-engine` → Needs Scope Clarity

| Issue | Fix | Owner | Effort |
|-------|-----|-------|--------|
| Overlaps with `canvas-2d-optimization` and `procedural-audio` | Clearly mark this as "the architecture skill" and reference the others for deep dives. Or merge the rendering parts of `canvas-2d-optimization` in | Chewie | M |
| Missing confidence header | Add `confidence: medium` to frontmatter | Chewie | S |
| No touch/gamepad/mobile input patterns | Add or reference `input-handling` skill when created | Lando | S |

---

## D. Structural Assessment

### Naming Convention Consistency

| Skill | Follows `{domain}-{topic}` | Notes |
|-------|----------------------------|-------|
| `2d-game-art` | ✅ | Could be `game-art-2d` for alphabetical grouping |
| `beat-em-up-combat` | ✅ `{genre}-{topic}` | Correct |
| `canvas-2d-optimization` | ✅ `{engine}-{topic}` | Correct |
| `game-qa-testing` | ✅ | Correct |
| `godot-4-manual` | ⚠️ | Manual is unusual — should be `godot-4-fundamentals` or `godot-4-reference` |
| `godot-beat-em-up-patterns` | ✅ `{engine}-{genre}-{topic}` | Correct |
| `godot-tooling` | ✅ `{engine}-{topic}` | Correct |
| `multi-agent-coordination` | ✅ | Correct |
| `procedural-audio` | ✅ | Correct |
| `project-conventions` | ✅ | Correct |
| `state-machine-patterns` | ✅ | Correct |
| `web-game-engine` | ⚠️ | Ambiguous — is this about web engines in general, or our custom engine? Should be `canvas-2d-engine` or `browser-game-architecture` |

**Overall:** Naming is ~83% consistent. Two skills have slightly ambiguous names.

### Overlaps Between Skills

| Skills | Overlap Area | Severity | Action |
|--------|-------------|----------|--------|
| `canvas-2d-optimization` ↔ `web-game-engine` | DPR handling, renderer setup, Canvas patterns | **High** | Merge rendering patterns into one. Keep optimization as a focused perf skill |
| `godot-tooling` ↔ `project-conventions` | GDScript style guide, folder structure, naming conventions | **High** | Remove duplicated content from `godot-tooling`. Reference `project-conventions` |
| `beat-em-up-combat` ↔ `godot-beat-em-up-patterns` | Combat patterns repeated in GDScript form | **Medium** | `godot-beat-em-up-patterns` should reference `beat-em-up-combat` for design rationale, not repeat it |
| `game-qa-testing` ↔ `state-machine-patterns` | State machine audit checklists appear in both | **Low** | Acceptable — different perspectives (QA vs implementation). Add cross-references |
| `procedural-audio` ↔ `web-game-engine` | Audio bus setup, synthesis patterns | **Medium** | `web-game-engine` should reference `procedural-audio` for depth |

### Skill/Agent Mapping

| Agent | Primary Skills | Gap |
|-------|---------------|-----|
| **Yoda** (Game Design) | `beat-em-up-combat` | No `game-design-methodology` skill |
| **Solo** (Lead) | `multi-agent-coordination`, `project-conventions` | No `release-management` skill |
| **Chewie** (Engine) | `web-game-engine`, `canvas-2d-optimization`, `godot-4-manual`, `godot-tooling` | 4 skills = most of any agent. Overlap problem |
| **Lando** (Gameplay) | `beat-em-up-combat`, `state-machine-patterns` | No `input-handling` skill |
| **Wedge** (UI/UX) | *None* | **Critical gap.** Zero skills for a domain owner |
| **Boba** (Art Director) | `2d-game-art` | Missing `animation-systems` |
| **Leia** (Environment) | *None* | No environment-specific skill |
| **Nien** (Character Art) | *None* | No character-specific skill |
| **Bossk** (VFX) | *None* | No VFX-specific skill |
| **Greedo** (Audio) | `procedural-audio` | Only Web Audio. No engine-agnostic audio design skill |
| **Tarkin** (Content/AI) | `godot-beat-em-up-patterns` | No `enemy-ai-patterns` (universal) skill |
| **Ackbar** (QA) | `game-qa-testing` | No `automated-testing` skill |
| **Scribe** (Docs) | *None* | No documentation methodology skill |
| **Ralph** (Production) | *None* | No production/pipeline skill |

**Finding:** 6 out of 13 agents have ZERO associated skills. That's a 46% coverage gap.

### Should Any Skills Be Merged, Split, or Reorganized?

| Action | Skills | Rationale |
|--------|--------|-----------|
| **MERGE** | `canvas-2d-optimization` INTO `web-game-engine` | High overlap, both Canvas-specific. One skill covers our custom engine completely |
| **SPLIT** | `godot-beat-em-up-patterns` INTO 3-4 skills | 39KB/1308 lines is unwieldy. Split into `godot-combat-patterns`, `godot-enemy-ai`, `godot-level-flow`, `godot-movement-2.5d` |
| **RENAME** | `godot-4-manual` → `godot-4-fundamentals` | "Manual" implies completeness. "Fundamentals" sets correct expectations |
| **RENAME** | `web-game-engine` → `browser-game-architecture` | Clearer scope |
| **DEDUPLICATE** | `godot-tooling` referencing `project-conventions` | Remove duplicated GDScript style/naming sections |

---

## E. Overall Verdict

### Scores (1-10)

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| **Coverage** | 5/10 | 12 skills cover ~50% of what a multi-genre studio needs. 6/13 agents have zero skills. Critical gaps in game design methodology, UI/UX, input handling, level design, release management |
| **Quality** | 7.5/10 | The skills we HAVE are genuinely good. 8 out of 12 rated ⭐⭐⭐⭐ or better. `project-conventions` is reference-quality. No skill is bad enough to need a rewrite |
| **Organization** | 6/10 | Naming is mostly consistent. But 3 high-severity overlaps, one 39KB mega-skill, 2 ambiguous names, and no clear agent→skill mapping table |
| **Growth-Readiness** | 4/10 | Our skills are 70% Canvas-2D/beat-em-up-specific. The growth-framework describes a multi-genre, multi-engine future but our actual skills don't support it yet. Universal skills (state machines, QA, coordination, conventions) are strong. Engine-specific and genre-specific skills need to be rebuilt for each new technology |

### Top 3 Most Urgent Actions

1. **Create `game-feel-juice` skill (P0)** — Game feel is our #1 principle and our studio's identity. We have game feel patterns scattered across 3 skills but no unified, engine-agnostic reference. This should be the first skill any new agent reads. **Owner: Yoda + Lando. Effort: M.**

2. **Create `ui-ux-patterns` skill (P1)** — Wedge is a domain owner with ZERO skills. Every game needs UI. This is a team gap, not a nice-to-have. **Owner: Wedge. Effort: L.**

3. **Split `godot-beat-em-up-patterns` and resolve overlaps (P1)** — A 39KB skill is unusable in practice. Split it, deduplicate `godot-tooling` vs `project-conventions`, and merge `canvas-2d-optimization` into `web-game-engine`. This structural cleanup makes the entire skills library more navigable. **Owner: Solo + Chewie. Effort: M.**

### Overall Assessment

**The team's knowledge base is NOT ready for the next project — but it's 60% of the way there.**

What we have is good. Really good, in some cases. The universal skills (`state-machine-patterns`, `game-qa-testing`, `multi-agent-coordination`, `project-conventions`) are strong and will transfer to any genre or engine. The beat-em-up vertical is well-documented.

What's missing is breadth. We're a 13-specialist studio with skills for 7 of them. We have deep Canvas 2D knowledge but no Godot validation. We have combat design patterns but no level design, no UI/UX, no input handling, no release management. The growth-framework describes a studio that can absorb new genres — but the skills system hasn't caught up to that ambition yet.

**The honest verdict:** Our skills are like a fighter with a devastating right hook but no footwork. The punch lands hard — but we need to move, too.

**Confidence in this audit: 8/10.** I read every skill file line by line, cross-referenced against the growth framework and company identity, and evaluated against the studio's stated multi-genre ambitions. The one area I'm less confident in is the accuracy assessment of Godot patterns — we haven't shipped a Godot project, so those patterns are theoretical.

---

## Appendix: Rating Summary

| # | Skill | Rating | Confidence (Current → Recommended) |
|---|-------|--------|-------------------------------------|
| 1 | `2d-game-art` | ⭐⭐⭐⭐ | `high` → `high` ✅ |
| 2 | `beat-em-up-combat` | ⭐⭐⭐⭐ | `low` → `medium` ⬆️ |
| 3 | `canvas-2d-optimization` | ⭐⭐⭐ | `low` → `medium` ⬆️ |
| 4 | `game-qa-testing` | ⭐⭐⭐⭐ | `low` → `low` ✅ (intentional humility) |
| 5 | `godot-4-manual` | ⭐⭐⭐ | `low`/`medium` → `medium` ⬆️ |
| 6 | `godot-beat-em-up-patterns` | ⭐⭐⭐⭐ | `low` → `medium` ⬆️ |
| 7 | `godot-tooling` | ⭐⭐⭐ | `low` → `low` ✅ |
| 8 | `multi-agent-coordination` | ⭐⭐⭐⭐ | `low` → `medium` ⬆️ |
| 9 | `procedural-audio` | ⭐⭐⭐⭐ | (none) → `medium` ⬆️ |
| 10 | `project-conventions` | ⭐⭐⭐⭐⭐ | `high` → `high` ✅ |
| 11 | `state-machine-patterns` | ⭐⭐⭐⭐ | `low` → `medium` ⬆️ |
| 12 | `web-game-engine` | ⭐⭐⭐ | (none) → `medium` ⬆️ |

**Distribution:** 0 × ⭐, 0 × ⭐⭐, 4 × ⭐⭐⭐, 7 × ⭐⭐⭐⭐, 1 × ⭐⭐⭐⭐⭐

No skill needs a rewrite. That's good. But 4 skills need structural improvement, and at least 8 new skills need to be created before we're a multi-genre studio in practice, not just in aspiration.
