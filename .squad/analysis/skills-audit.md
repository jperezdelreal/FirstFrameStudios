# Skills Audit — First Frame Studios

> Compressed from 30KB. Full: skills-audit-archive.md

> **Author:** Ackbar (QA Lead / Playtester)
> **Date:** 2025-07-21
---

## A. Quality Assessment — Per Skill
### 1. `2d-game-art` ⭐⭐⭐⭐ (Excellent)
| Criterion | Score | Notes |
| **Depth** | High | 10 substantive patterns covering pipeline, style guide, color theory, animation, VFX, parallax, UI, procedural-to-sprite migration criteria |
| **Accuracy** | High | Canvas API patterns are correct; DPR handling, bezier curves, seeded random — all verified in firstPunch |
| **Actionability** | High | Copy-paste code examples for every pattern. An agent can read this and draw a character immediately |
| **Genre Independence** | Good | Mostly universal 2D art. Minor Canvas-specific lean, but patterns transfer to any 2D renderer |
| **Confidence** | `high` — **Justified.** Earned through shipped project |
---
| Criterion | Score | Notes |
---
---
---
---
---
---
---
---
---
---
---

## B. Gap Analysis — Missing Skills
### P0 — Needed Now
| Skill Name | Description | Why P0 |
| `game-feel-juice` | Universal game feel systems: screen shake, hitlag, knockback, flash, slow-mo, camera emphasis. Engine-agnostic principles + implementation per engine | Referenced in growth-framework.md but never created. Our principles say "game feel is the core product." We have game feel patterns scattered across `beat-em-up-combat` and `godot-beat-em-up-patterns` but no unified, genre-agnostic skill |
| `game-design-methodology` | Genre research process, GDD templates, reference game analysis, mechanic prototyping, balance framework | Our design process is described in growth-framework.md and principles.md but has no structured skill. Yoda needs a codified design methodology skill to onboard to new genres consistently |
| `input-handling` | Input buffering, coyote time, action mapping, gamepad support, touch input, accessibility (remapping) | Input patterns are scattered across `web-game-engine` and `godot-4-manual`. Critical for every game we make. Needs its own universal skill |
| Skill Name | Description | Why P1 |
| `level-design-fundamentals` | Level layout grammar, pacing curves, teach-by-doing, camera placement, difficulty ramping. Genre-agnostic foundations | Growth-framework lists this for platformer vertical but the fundamentals apply to every genre. We have no level design knowledge documented |
| `ui-ux-patterns` | Menu flow, HUD design, accessibility standards (WCAG for games), onboarding flow, information hierarchy, responsive layouts | Wedge's entire domain has zero skills. UI/UX is critical for every game and we have nothing |
---

## C. Improvement Recommendations
### Skills Rated ⭐⭐⭐ (Solid — Need Improvement)
#### `canvas-2d-optimization` → Needs Clarification of Scope
| Issue | Fix | Owner | Effort |
| Overlaps heavily with `web-game-engine` (DPR, renderer setup) | Merge rendering patterns into `web-game-engine`; keep `canvas-2d-optimization` focused purely on performance | Chewie | M |
| Performance budget conflict (300 vs 500 calls/frame between skills) | Reconcile targets — one authoritative budget table | Chewie | S |
| Canvas 2D is becoming legacy tech for us | Add a clear "Maturity: Archive" header when we commit to Godot. Don't delete, but mark as historical | Solo | S |
| Issue | Fix | Owner | Effort |
| Beat-em-up content leaks into general engine sections | Rename Section 4 from "Scene Architecture for Beat 'Em Up" to "Scene Architecture" with beat-em-up as one example | Chewie | S |
---

## D. Structural Assessment
### Naming Convention Consistency
| Skill | Follows `{domain}-{topic}` | Notes |
| `2d-game-art` | ✅ | Could be `game-art-2d` for alphabetical grouping |
| `beat-em-up-combat` | ✅ `{genre}-{topic}` | Correct |
| `canvas-2d-optimization` | ✅ `{engine}-{topic}` | Correct |
| `game-qa-testing` | ✅ | Correct |
| `godot-4-manual` | ⚠️ | Manual is unusual — should be `godot-4-fundamentals` or `godot-4-reference` |
| `godot-beat-em-up-patterns` | ✅ `{engine}-{genre}-{topic}` | Correct |
---

## E. Overall Verdict
### Scores (1-10)
| Dimension | Score | Rationale |
| **Coverage** | 5/10 | 12 skills cover ~50% of what a multi-genre studio needs. 6/13 agents have zero skills. Critical gaps in game design methodology, UI/UX, input handling, level design, release management |
| **Quality** | 7.5/10 | The skills we HAVE are genuinely good. 8 out of 12 rated ⭐⭐⭐⭐ or better. `project-conventions` is reference-quality. No skill is bad enough to need a rewrite |
| **Organization** | 6/10 | Naming is mostly consistent. But 3 high-severity overlaps, one 39KB mega-skill, 2 ambiguous names, and no clear agent→skill mapping table |
| **Growth-Readiness** | 4/10 | Our skills are 70% Canvas-2D/beat-em-up-specific. The growth-framework describes a multi-genre, multi-engine future but our actual skills don't support it yet. Universal skills (state machines, QA, coordination, conventions) are strong. Engine-specific and genre-specific skills need to be rebuilt for each new technology |
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