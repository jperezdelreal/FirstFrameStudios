# Orchestration: Jango — Build Pipeline & Viewport Update

**Date:** 2026-03-09T1150Z  
**Agent:** Jango (Tool Engineer)  
**Mode:** Background + Sync (lightweight)  
**Project:** Ashfall (Godot 4.6)

## Tasks Executed

### 1. Build Pipeline (Background Mode)
**Task:** Create Godot export preset + GitHub Actions release workflow  
**Status:** SUCCESS — PR #111

**Deliverables:**
- `games/ashfall/export_presets.cfg` — Windows Desktop export preset (Godot 4.6)
- `.github/workflows/godot-release.yml` — Automated build and GitHub Release workflow
- Root `.gitignore` updated to allow export_presets.cfg, ignore builds/

**Architecture:**
- Tag push (v*) → GitHub Actions triggers
- Installs Godot 4.6 + export templates
- Exports Windows .exe from games/ashfall/
- Creates GitHub Release with zip download
- Cross-compilation: Ubuntu runner → Windows .exe

**Key Decision:** Version export_presets.cfg (non-standard but necessary for CI/CD)

---

### 2. Viewport Update (Sync Mode)
**Task:** Update viewport resolution 1280x720 → 1920x1080  
**Status:** SUCCESS

**Change:**
- `games/ashfall/project.godot` [display] section
- `window/size/viewport_width`: 1280 → 1920
- `window/size/viewport_height`: 720 → 1080

**Rationale:** Founder directive — 720p is outdated for 2026 game standards; 1080p provides better visual clarity for fighting game action.

---

## Decision Artifacts Created
- `.squad/decisions/inbox/jango-build-pipeline.md` — Full build pipeline architecture decision
- `.squad/decisions/inbox/copilot-directive-2026-03-09T1247Z.md` — Viewport resolution directive captured
