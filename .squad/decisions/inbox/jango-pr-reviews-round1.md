# PR Review Round 1 — CI Workflow Maintenance Decision

**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Context:** Reviewed 3 PRs across Flora and ComeRosquillas repos  
**Decision Status:** Team-wide policy

## Problem

ComeRosquillas PR #14 (multiple maze layouts) has CI failures despite correct implementation. Root cause: CI workflow (`.github/workflows/ci.yml`) checks for old monolithic structure (`js/game.js`) but the codebase was modularized in PR #10 (5 modules: config.js, audio.js, renderer.js, game-logic.js, main.js). The CI workflow was never updated to match the new structure.

## Decision

**CI workflows must be updated in the same PR that introduces structural changes.**

When a PR modifies project structure (file moves, modularization, build system changes), the author must:
1. Update CI workflow checks to match the new structure
2. Update any path references in workflows (artifact paths, script checks, HTML validation)
3. Verify CI passes before marking the PR ready for review

## Rationale

1. **Prevents Silent Breakage** — If modularization PR merges without CI updates, subsequent PRs fail with confusing errors unrelated to their changes
2. **Atomic Changes** — Structure + CI updates belong together logically (same architectural change)
3. **Review Clarity** — Reviewers can see the full impact of structural changes (code + tooling) in one PR
4. **Rollback Safety** — If a structural change needs to be reverted, the CI workflows revert with it

## Example: ComeRosquillas Modularization

**PR #10 (Modularization):**
- Split `js/game.js` (1789 lines) → 5 modules (config.js, audio.js, renderer.js, game-logic.js, main.js)
- Updated `index.html` to load modular scripts
- ❌ **Did NOT update** `.github/workflows/ci.yml` (still checked for `js/game.js`)

**PR #14 (Maze Layouts):**
- Added 4 maze templates to `config.js`
- Updated `game-logic.js` to rotate mazes
- ✅ Code quality excellent, spec compliance perfect
- ❌ CI fails: workflow checks for `js/game.js` reference in HTML (no longer exists)

**Impact:**
- PR #14 blocked on CI fix unrelated to maze implementation
- Reviewer (Jango) had to diagnose CI workflow mismatch
- Developer must add CI fix to maze PR or create separate PR

## Required CI Update for ComeRosquillas

Update `.github/workflows/ci.yml`:

```yaml
# Line 36-44: HTML structure check
- name: Check HTML structure
  run: |
    # Check for required HTML elements
    if ! grep -q '<canvas id="gameCanvas">' index.html; then
      echo "❌ Missing gameCanvas element!"
      exit 1
    fi
    
    # Check for modular script structure (not monolithic game.js)
    if ! grep -q 'src="js/config.js"' index.html; then
      echo "❌ Missing config.js script reference!"
      exit 1
    fi
    
    if ! grep -q 'src="js/main.js"' index.html; then
      echo "❌ Missing main.js script reference!"
      exit 1
    fi

# Lines 77-93: Verify game assets
- name: Verify game assets
  run: |
    # Check for required directories
    if [ ! -d "js" ]; then
      echo "❌ js/ directory not found!"
      exit 1
    fi
    
    # Check for core modular files
    if [ ! -f "js/config.js" ]; then
      echo "❌ js/config.js not found!"
      exit 1
    fi
    
    if [ ! -f "js/game-logic.js" ]; then
      echo "❌ js/game-logic.js not found!"
      exit 1
    fi
    
    if [ ! -f "js/main.js" ]; then
      echo "❌ js/main.js not found!"
      exit 1
    fi
```

## Alternatives Considered

1. **Separate CI Update PR** — Creates extra PR overhead, doesn't prevent breakage
2. **Manual CI Bypass** — Unsafe, breaks automation trust
3. **Post-Merge CI Fix** — Main branch broken between merge and fix

## Consequences

✅ **Benefits:**
- CI always matches codebase structure
- Structural PRs are fully self-contained
- Reviewers see complete architectural impact
- Subsequent PRs don't inherit structural CI failures

⚠️ **Tradeoffs:**
- Structural PRs have higher complexity (code + tooling changes)
- Requires PR authors to understand CI workflows
- May need CI workflow documentation for developers

## Action Items

1. **ComeRosquillas PR #14:** Developer adds CI workflow fix to the PR, re-runs CI, then merge
2. **Squad Documentation:** Add "CI Workflow Maintenance" section to contribution guidelines
3. **PR Template:** Add checklist item: "If this PR changes project structure, update CI workflows"
4. **Ralph Watch:** Add CI workflow check to PR review automation (detect structure changes, flag missing CI updates)

## Related Decisions

- **2026-03-11: ComeRosquillas CI Pipeline Strategy** — Lightweight CI for vanilla JS games (no bundler)
- **2026-03-11: ComeRosquillas Modularization Architecture** — 5-module split with clean DAG

## Status

**ACTIVE** — Policy applies to all future PRs across all FFS repos (FirstFrameStudios, ComeRosquillas, Flora, ffs-squad-monitor)
