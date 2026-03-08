# Ashfall Tools — Wave 1

This directory contains development and validation tools for the Ashfall project.

## Wave 1 Tools (Sprint A Quick Wins)

### 🔧 Tool 1: Branch Validation CI Action
**Location:** `.github/workflows/branch-validation.yml`  
**Purpose:** Prevents PRs from targeting incorrect branches  
**How it works:** Automatically checks that all PRs target `main` branch

**Usage:**
- Runs automatically on every PR
- Blocks merge if PR targets wrong branch
- No manual action required

---

### 🔧 Tool 2: PR Body Validator
**Location:** `.github/workflows/pr-body-check.yml`  
**Purpose:** Reminds developers to link PRs to issues  
**How it works:** Checks for "Closes #N" pattern in PR body and posts a warning if missing

**Usage:**
- Runs automatically when PR is opened or edited
- Posts a friendly reminder comment if issue reference is missing
- Does NOT block merge (warning only)

---

### 🔧 Tool 3: Autoload Dependency Analyzer
**Location:** `tools/check-autoloads.py`  
**Purpose:** Validates autoload order in `project.godot` matches dependency graph  
**Impact:** Prevents M1+M2 Blocker #5 (autoload order violations)

**Usage:**
```bash
# From repo root
python tools/check-autoloads.py
```

**What it checks:**
- ✅ All autoload script files exist
- ✅ Autoload order respects dependencies (e.g., EventBus loads before systems that use it)
- ✅ No circular dependencies
- 💡 Suggests correct order if validation fails

**Example output:**
```
============================================================
🔧 AUTOLOAD DEPENDENCY ANALYZER
============================================================

📋 Found 6 autoload(s):
   - EventBus: scripts/systems/event_bus.gd
   - GameState: scripts/systems/game_state.gd
   ...

✅ EventBus: File exists
✅ GameState: File exists
...

🔍 Dependency Analysis:
   EventBus: No dependencies
   GameState depends on: EventBus
   ...

✅ Autoload order is valid!
============================================================
✅ ALL CHECKS PASSED
============================================================
```

---

### 🔧 Tool 4: Signal Wiring Validator
**Location:** `tools/check-signals.py`  
**Purpose:** Scans all GDScript files to find signal definitions, emissions, and connections  
**Impact:** Prevents M1+M2 Blocker #2 (signals emitted but not wired)

**Usage:**
```bash
# From repo root
python tools/check-signals.py
```

**What it analyzes:**
- 📝 Signal definitions (`signal my_signal`)
- 📤 Signal emissions (`.emit()` calls)
- 📥 Signal connections (`.connect()` calls)
- ⚠️  Orphaned signals (emitted but never connected, or vice versa)

**Example output:**
```
================================================================================
🔌 SIGNAL WIRING VALIDATOR
================================================================================

📂 Found 32 GDScript file(s)

🔍 Scanning for signals...
   Found 22 unique signal(s)

================================================================================
📊 SIGNAL WIRING MATRIX
================================================================================

✅ fighter_ko
   📝 Defined in: games\ashfall\scripts\systems\event_bus.gd
   📤 Emitted in: games\ashfall\scripts\fight_scene.gd
   📥 Connected in: 
      - games\ashfall\scripts\systems\vfx_manager.gd
      - games\ashfall\scripts\systems\audio_manager.gd

⚠️  ember_spent
   📝 Defined in: games\ashfall\scripts\systems\event_bus.gd
   📤 Emitted in: games\ashfall\scripts\systems\game_state.gd
   ⚠️  WARNING: Signal is emitted but never connected

================================================================================
📈 SUMMARY
================================================================================

✅ Healthy signals (emitted AND connected): 11
⚠️  Orphaned emissions (emitted but not connected): 1
⚠️  Orphaned connections (connected but not emitted): 7
```

**Exit codes:**
- `0`: All signals properly wired
- `1`: Warnings detected (orphaned signals found)

---

## Running All Checks

```bash
# Check autoloads
python tools/check-autoloads.py

# Check signal wiring
python tools/check-signals.py
```

---

## What's Next?

**Wave 2** (Sprint A remainder):
- Integration Gate Automation
- Godot Headless Validator (CI)
- Scene Integrity Checker
- Test Scene Generator

**Wave 3** (Sprint B):
- VFX/Audio Test Bench
- GDD Diff Reporter
- Collision Layer Matrix Generator
- Frame Data CSV Pipeline
- Live Reload Watcher

---

## Issues Closed

- Closes #34 (Branch Validation CI Action)
- Closes #36 (Autoload Dependency Analyzer)
- Closes #39 (Signal Wiring Validator)
- Closes #44 (PR Body Validator)

---

**Built by:** Jango (Lead & Tool Engineer)  
**Sprint:** A — Wave 1  
**Status:** ✅ SHIPPED
