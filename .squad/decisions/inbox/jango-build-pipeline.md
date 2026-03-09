# Decision: Godot Build Pipeline Architecture

**Date:** 2025-07-24  
**Author:** Jango (Tool Engineer)  
**Status:** Implemented  
**PR:** #111

## Context
Ashfall (Godot 4.6 fighting game) needed automated builds and releases. Users should be able to download a playable .exe from GitHub Releases without needing the Godot editor.

## Decision

### 1. Export Presets Are Versioned
- **Conventional approach:** `export_presets.cfg` is typically in `.gitignore` because it can contain local paths or personal settings
- **Our approach:** Version it in the repo so CI/CD can read the preset configuration
- **Rationale:** Our preset contains only project-relative paths and metadata, no credentials or machine-specific config. CI/CD needs it to know how to export.

### 2. Manual Godot Installation (Not chickensoft-games/setup-godot)
- Used `wget` to download Godot 4.6 stable and export templates directly from godotengine/godot releases
- **Rationale:** Explicit version control and guaranteed 4.6 support. The chickensoft action is excellent but may lag behind latest Godot releases.
- **Trade-off:** More verbose workflow, but predictable and transparent

### 3. Tag-Triggered Releases
- Workflow triggers on `v*` tags (e.g., `v0.1.0`, `v1.0.0`)
- **Developer workflow:**
  1. Tag commit: `git tag v0.1.0`
  2. Push tag: `git push origin v0.1.0`
  3. GitHub Actions builds and publishes release automatically
- **Rationale:** Clean separation between development commits and releases. Tags are immutable markers of release points.

### 4. Single Platform (Windows Desktop) Initially
- Only Windows .exe export in Sprint 1
- **Future:** Can add Linux/Mac/Web exports as needed
- **Rationale:** Start simple, validate the pipeline with one platform, then expand

### 5. Cross-Compilation on Ubuntu Runners
- GitHub Actions runs on `ubuntu-latest`
- Godot on Linux exports Windows .exe using the Windows export template
- **Rationale:** Standard GitHub Actions approach; Godot's export templates include the Windows runtime, so cross-compilation just works

## Alternatives Considered

### Alternative 1: Use chickensoft-games/setup-godot
- **Pros:** Cleaner workflow syntax, well-maintained action
- **Cons:** May not support Godot 4.6 yet (action needs updating for each Godot release)
- **Verdict:** Deferred. Revisit after 4.6 is officially supported.

### Alternative 2: Keep export_presets.cfg Ignored
- **Approach:** Generate the preset dynamically in CI/CD
- **Cons:** More fragile (CI script becomes the source of truth), harder to test locally
- **Verdict:** Rejected. Versioning the preset is simpler and more reliable.

### Alternative 3: Build on Windows Runners
- **Approach:** Use `windows-latest` runner to build natively
- **Cons:** Slower startup, unnecessary (cross-compilation works fine)
- **Verdict:** Rejected. Ubuntu is faster and cross-compilation is a Godot strength.

## Impact
- **Developers:** Can create releases by pushing a tag
- **Players:** Can download and play Ashfall without Godot editor
- **QA:** Can test release builds before tagging (via manual workflow dispatch)
- **Future projects:** Pipeline is reusable (just update paths in export_presets.cfg)

## Implementation
- `games/ashfall/export_presets.cfg` — Windows Desktop preset
- `.github/workflows/godot-release.yml` — Build and release workflow
- Root `.gitignore` updated to allow `export_presets.cfg`, ignore `builds/`

## Testing Plan
1. Merge PR #111
2. Test manual workflow dispatch (Actions → Godot Build & Release → Run workflow)
3. If successful, create test tag `v0.0.1-test` to validate tag-triggered release
4. Delete test release if needed
