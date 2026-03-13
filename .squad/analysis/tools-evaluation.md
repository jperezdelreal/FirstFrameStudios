# Tools Evaluation — First Frame Studios

> Compressed from 35KB. Full: tools-evaluation-archive.md

**Evaluator:** Jango (Tool Engineer)  
**Date:** 2025-07-22  
---

## Executive Summary
**The Bottom Line:** First Frame Studios should NOT build generic tools right now. We should build two mission-critical tools and adopt or defer everything else. Here's why:
1. **We're Pre-scale.** With one shipped game (firstPunch) and one game in production (Godot transition), we don't yet have enough institutional knowledge to know what's truly reusable vs. what's project-specific.
---

## 1. EVALUATE: The Tool Categories
### Category A: Game Feel Tuning Dashboard
**BUILD vs BUY vs SKIP Analysis:**
| Criterion | Assessment |
| **Problem Statement** | During gameplay, designers want to tweak hitlag, screen shake, knockback force, timing windows without restarting. Currently: edit variables, restart, test, repeat. **Iteration cycle: 30-60 seconds per test.** |
| **Payoff** | High — Principle #1 (Player Hands First) is our core differentiator. Game feel is where we win. Faster iteration means faster learning. Estimated 2-3x speed improvement. |
| **Effort to Build** | Medium (1-2 days) — A floating debug panel with sliders for key values, connected to in-game systems via autoload. Requires input system hooks and some UI scaffolding. |
| **Godot Solution** | Godot has built-in `@export` hot-reload — change a value in the inspector, see it live in-game without restart. **Does the job for 80% of use cases.** Add a custom EditorPlugin dock for the remaining 20% (bulk parameter export/import, preset saving). |
| **Risk of NOT Building** | Medium — We'll be slower at feel iteration than we could be, but not blocked. |
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

## 2. BUILD vs BUY vs SKIP SUMMARY
### By Category:
| Tool | Category | Recommendation | When | Owner |
| Game Feel Tuning Dashboard | Optimization | BUY (EditorPlugin) | Sprint 0, Next Project | Jango (4-6h) |
| Animation Preview Tool | Optimization | SKIP | Phase 2+ (if animation velocity high) | — |
| Level Editor / Encounter Designer | Content | SKIP | Phase 2+ (if content-heavy) | — |
| Audio Mixer / Preview | Optimization | BUY (if Greedo requests) | On-demand | Jango or Greedo |
| Balance Spreadsheet Pipeline | **Critical** | **BUILD** | Sprint 0, Next Project | Jango (1 day) |
| CI/CD for Game Builds | **Critical** | **BUILD** | Sprint 0, Next Project | Chewie + Jango (4-6h) |
---

## 3. BUILD vs BUY ANALYSIS: The Two Critical Tools
### Tool #1: CI/CD for Game Builds (GitHub Actions)
**What:** Automated builds on every push. Generate Web + Windows executables. Upload to artifact storage (GitHub Releases / itch.io).
---
### Tool #2: Balance Spreadsheet → Game Data Pipeline
# resources/enemies/grunt_stats.tres

> Compressed from 35KB. Full: tools-evaluation-archive.md

# scripts/data/enemy_stats.gd

> Compressed from 35KB. Full: tools-evaluation-archive.md

# scenes/enemies/EnemyGrunt.gd

> Compressed from 35KB. Full: tools-evaluation-archive.md

---

## 4. TOOL ARCHITECTURE PRINCIPLES
If we build tools, they should follow these principles:
### Principle A: Godot-Specific, Not Engine-Agnostic
---
### Principle B: Editor Plugins > Standalone Tools
---
### Principle C: Modular, Not Monolithic
---
### Principle D: Integrated (Editor Plugins) vs. Standalone (Scripts) Trade-off
---
---

## 5. PRIORITY ROADMAP
### Sprint 0 (Next Godot Project)
**P0 (Must Have):**
---
### Phase 1 (Production Ramp)
---
### Phase 2+ (Content & Polish)
---
### ROI Ranking (Impact / Effort)
| Rank | Tool | Impact | Effort | ROI |
| 1 | CI/CD Builds | 10/10 | 4-6h | **Highest** |
| 2 | Balance Pipeline | 9/10 | 1 day | **Very High** |
---

## 6. HONEST ASSESSMENT: Should We Build Tools At All?
### The Case For NOT Building Tools Right Now
**The bottleneck isn't tools. It's team bandwidth.**
### The Case For Building Tools (Selective)
### Recommendation
---

## 7. ANTI-PATTERNS: What NOT to Do
### ❌ Anti-Pattern 1: "Build Reusable Tools Before Shipping One Game"
**Why it fails:**
---
### ❌ Anti-Pattern 2: "Build a Generic Tool That Works For All Projects"
---
### ❌ Anti-Pattern 3: "Require Tools to Be Fully Baked Before First Use"
---
### ❌ Anti-Pattern 4: "Separate Tool Ownership From Usage"
---

## 8. IMPLEMENTATION ROADMAP
### For Sprint 0 (Next Godot Project)
**Week 1:**
---
### For Phase 1 & Beyond
---

## 9. SUMMARY TABLE: Tools Decision Matrix
| Tool | Recommendation | Sprint 0? | Owner | Effort | Payoff | Rationale |
|------|---|---|---|---|---|---|
| **CI/CD Builds** | BUILD | Yes | Chewie + Jango | 4-6h | 10/10 | Enables async testing, highest ROI |
| **Balance Pipeline** | BUILD | Yes | Jango | 1 day | 9/10 | Unblocks designers, enables parallelism |
| **Game Feel Tuning** | BUY (EditorPlugin) | Yes (P1) | Jango | 4-6h | 8/10 | Nice-to-have; `@export` is 80% as good |
| **Linting + Validation** | BUILD | Yes (P1) | Jango | 2-3h | 8/10 | Catches errors early, enforces quality |
| **Audio Mixer** | BUY (if bottleneck) | No | Jango/Greedo | 1-2 days | 7/10 | Defer; only build if needed |
| **Animation Preview** | SKIP | No | — | 2-3 days | 6/10 | Only if animation velocity high |
---

## 10. CLOSING: The Honest Answer
**Should First Frame Studios build reusable tools?**
**Answer: Yes, but later. And selectively.**
---

## APPENDIX: Tool Roadmap Checklist
### Sprint 0 Checklist
- [ ] GitHub Actions workflow created and tested
### Phase 1 Checklist (As Needed)
### Post-Ship Checklist (After Game #1)
---