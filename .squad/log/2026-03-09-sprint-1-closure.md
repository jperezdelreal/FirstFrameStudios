# SESSION LOG: Sprint 1 Debt Resolution Wave + Build Pipeline

**Date:** 2026-03-09  
**Session Type:** Issue Closure + Infrastructure  
**Scope:** All 6 outstanding Sprint 1 issues closed before Sprint 2 kickoff

## Summary

Sprint 1 debt resolution completed ahead of sprint boundary. All 6 outstanding issues (Art Direction, Frame Data Bugs, Character Sprite Completion) closed via merged PRs. Concurrent infrastructure work (Build Pipeline, Viewport Upgrade) delivers release-ready tooling.

## Issue Closure

### Art Direction Document (#102) — Boba
**PR #113** — `games/ashfall/docs/ART-DIRECTION.md` (634 lines)
- Visual identity standards (hand-drawn, expressive, high-contrast)
- Color palette system with primary/secondary/highlight/shadow
- Character design philosophy (Kael controlled vs Rhena explosive)
- Animation philosophy (procedural + state-driven)
- VFX signature language (special moves visually distinct)
- UI/HUD standards and implementation roadmap
- **Impact:** Establishes visual standards for all future art assets (stages, effects, UI). Nien's character work built on these specs.

### P0 Frame Data Bugs (#108, #109, #110) — Lando
**PR #114** — 3 critical gameplay fixes
- Issue #108: Medium Punch startup corrected (6→5f, total 11f vs 12f)
- Issue #109: Medium Kick animation glitch fixed (missing frames 4-5 in active window)
- Issue #110: HP/HK damage equalized (HP 120→100, HK 85→100), HK knockback normalized to pure vertical
- Medium attacks (MP/MK) added to both character movesets (were missing from initial resources)
- **Impact:** All P0 blockers cleared. Playtest can proceed with frame-accurate medium attacks, smooth animations, balanced damage. Medium attack inclusion brings movesets to full 6 normals + 2 specials spec.

### Character Sprite Completion (#99, #100) — Nien
**PR #115** — 6 final poses per character, 41→47 total
- Kael: throw_startup, throw_whiff, hit_heavy, hit_crouching, hit_air, knockdown_fall
- Rhena: throw_startup, throw_whiff, hit_heavy, hit_crouching, hit_air, knockdown_fall
- SpriteStateBridge routing: hit → hit_heavy/hit_crouching/hit_air, ko → knockdown_fall/ko
- Personality differentiation validated: Kael controlled in adversity, Rhena explosive
- **Impact:** Character art complete for Sprint 2. All GDD animation specs delivered. Readiness for next phase (special move VFX, stage design).

## Infrastructure & Pipeline

### Build Pipeline (#111) — Jango
**PR #111** — Automated release workflow + Godot export preset
- `games/ashfall/export_presets.cfg` — Windows Desktop export preset (Godot 4.6)
- `.github/workflows/godot-release.yml` — Tag push (v*) → GitHub Actions → export + release
- Godot 4.6 + export templates installed automatically in CI
- Cross-compilation: Ubuntu runner → Windows .exe
- GitHub Release creation with downloadable zip
- **Key Decision:** Version export_presets.cfg in git (non-standard, but necessary for CI/CD reproducibility)
- **Impact:** Release automation ready. Version tags trigger automatic builds.

### Viewport Resolution (#112) — Jango
**PR #112** — Upgrade 720p → 1080p
- `games/ashfall/project.godot` [display] section
- `window/size/viewport_width`: 1280 → 1920
- `window/size/viewport_height`: 720 → 1080
- **Rationale:** Founder directive — 720p is outdated for 2026; 1080p provides visual clarity for fighting game action
- **Impact:** Game now rendered at modern resolution. No gameplay logic affected.

## Decision Artifacts Merged

Two pending decisions merged into `.squad/decisions.md`:

### Decision 1: Jango — Build Pipeline Architecture
**Date:** 2026-03-09T1150Z

Complete build pipeline architecture:
- GitHub Actions trigger on version tags (v* pattern)
- Godot 4.6 export templates installed in CI
- Windows .exe exported from games/ashfall/ directory
- GitHub Release created with downloadable zip package
- Version export_presets.cfg in git for CI reproducibility

**Governance:** All releases must reference game name + version (e.g., "ashfall-v0.1.0", "Ashfall v0.1.0", "Ashfall-v0.1.0-windows.zip")

### Decision 2: Copilot Directive — Release Naming Convention
**Date:** 2026-03-09T1257Z

User directive (joperezd): All releases (tags and GitHub Releases) must always reference the game name and version. No generic version-only names.
- Tag format: `{game}-v{version}` (e.g., `ashfall-v0.1.0`)
- Release title format: `{Game} v{version}` (e.g., `Ashfall v0.1.0`)
- Zip format: `{Game}-v{version}-windows.zip` (e.g., `Ashfall-v0.1.0-windows.zip`)

**Why:** FirstFrameStudios monorepo may host multiple games; releases must be unambiguous about which game they belong to.

## Sprint Boundary Status

**Sprint 1 Deliverables (Complete):**
✅ Art Direction document (ART-DIRECTION.md)  
✅ P0 frame data bugs fixed (MP/MK/damage)  
✅ Character sprite animation completed (47 poses)  
✅ Build pipeline created (GitHub Actions + export)  
✅ Viewport upgraded to 1080p  

**Outstanding Debt:** 0 issues  

**Ready for Sprint 2:** Yes. All foundation work complete. Character art, frame data, art direction, and build tooling shipped and validated.

## Notes

- Nien's SpriteStateBridge routing pattern (hit → variants based on context) becomes reusable template for future games
- Lando's frame data work validates GDD specs in live gameplay — no mismatches between design doc and implementation
- Boba's art direction document will be reference for stage artist onboarding (Phase 2)
- Jango's build pipeline enables automated releases — version tags now trigger builds automatically
- Release naming convention centralized — all future agents must follow {game}-v{version} pattern
