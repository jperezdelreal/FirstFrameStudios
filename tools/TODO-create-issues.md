# TODO: Create GitHub Issues for Tool Priority

**Status:** Documents committed and pushed to main ✅  
**Next Action:** Create 18 GitHub issues for prioritized tools

---

## Prerequisites

Install GitHub CLI if not already installed:
```powershell
winget install GitHub.cli
# OR download from: https://cli.github.com/
```

Then authenticate:
```powershell
gh auth login
```

---

## Option 1: Automated Script (Recommended)

Run the prepared script that handles idempotency:

```powershell
cd C:\Users\joperezd\FirstFrameStudios
.\tools\create_tool_issues.ps1
```

This script:
- ✅ Checks for existing issues before creating (prevents duplicates)
- ✅ Creates all 18 issues with proper labels and bodies
- ✅ Organizes by Sprint A/B/C
- ✅ Uses priority labels (critical/high/medium)

---

## Option 2: Manual Creation

If you prefer to create issues manually via GitHub UI, reference these documents:
- **Full specs:** `games/ashfall/docs/TOOLS-PRIORITY.md`
- **Summary:** `games/ashfall/docs/TOOLS-PRIORITY-SUMMARY.md`

### Issues to Create (18 total)

#### Sprint A — Critical Priority (4 issues needed)
Existing: #33 (Integration Gate), #34 (Branch Validation), #35 (Godot Headless Validator)

Need to create:
- [ ] #36: Autoload Dependency Analyzer
- [ ] #37: Scene Integrity Checker  
- [ ] #38: Test Scene Generator
- [ ] #39: Signal Wiring Validator

#### Sprint B — High Priority (6 issues needed)
- [ ] #40: VFX/Audio Test Bench
- [ ] #41: GDD Diff Reporter
- [ ] #42: Collision Layer Matrix Generator
- [ ] #43: Frame Data CSV Pipeline
- [ ] #44: Live Reload Watcher
- [ ] #45: PR Body Validator

#### Sprint C — Medium Priority (8 issues needed)
- [ ] #46: Branch Staleness Detector
- [ ] #47: Decision Inbox Merger
- [ ] #48: File Ownership Matrix Generator
- [ ] #49: Skills Browser CLI
- [ ] #50: Auto-Delete Merged Branches
- [ ] #51: Integration Test Manifest
- [ ] #52: project.godot Lock Coordinator
- [ ] #53: Parallel Wave Planner

---

## Issue Labels to Use

For each sprint:
- **Sprint A:** `type:tooling`, `game:ashfall`, `priority:critical`
- **Sprint B:** `type:tooling`, `game:ashfall`, `priority:high`
- **Sprint C:** `type:tooling`, `game:ashfall`, `priority:medium`

---

## After Creating Issues

1. Update `tools/create_tool_issues.ps1` with actual issue numbers (if created manually)
2. Link issues in project board or milestone
3. Assign Sprint A tools to Jango (uncapped bandwidth)
4. Block M3 feature work until Sprint A deploys

---

## Verification Checklist

After running the script or creating manually:

```powershell
# Check all tool issues were created
gh issue list --repo jperezdelreal/FirstFrameStudios --label "type:tooling" --state open
```

Expected: 21 tool issues total (3 existing + 18 new)

---

**Document prepared by:** Mace (Sprint Lead)  
**Date:** 2025-07-17
