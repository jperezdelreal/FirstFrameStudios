# Ashfall Sprint 1 — Lessons Learned

> What went wrong, why, and what we'll do differently in Sprint 2.

**Compiled by:** Jango (Tool Engineer)  
**Date:** 2026-03-11  
**Sources:** Git commit history, closed issues #63-110, integration gate logs, playtest reports, team retrospectives

---

## Executive Summary

Sprint 1 (Art Phase) delivered 41 animation states per character, VFX integration, stage art, and AnimationPlayer wiring. The visual deliverables **passed** QA playtest. However, the sprint revealed **systematic type safety bugs** that caused ~10 emergency fixes in v0.2.0 and multiple character select input failures across 6+ commits.

The core lessons:
1. **Godot 4.6 type inference is NOT Python-like** — `:=` from dictionaries, arrays, or `abs()` produces `Variant`, not the expected type
2. **Input handling in exports ≠ input handling in editor** — Custom keycode handling breaks in Windows builds
3. **Frame data drift compounds** — Three sources of truth (GDD, base .tres, character .tres) diverged silently
4. **Integration testing was reactive, not proactive** — Tools caught issues after merge, not before PR

Sprint 2 will adopt **explicit typing everywhere**, input via native Godot UI nodes, single-source frame data, and pre-merge integration gate enforcement.

---

## Lesson 1: Godot 4.6 Type Inference Fails Silently with `:=`

### What Happened
Between March 9-10 (v0.2.0 release), ~10 commits fixed "proactive type safety" issues with explicit type annotations. Pattern:

```gdscript
# BEFORE (inferred as Variant, not float)
var round_num := parts[1].to_int()
var fc := palette.flash_color
var grab_offset := 40.0 * fighter.facing_direction

# AFTER (explicit type)
var round_num: int = parts[1].to_int()
var fc: Color = palette.flash_color
var grab_offset: float = 40.0 * fighter.facing_direction
```

**Affected files:**
- `audio_manager.gd` (2 fixes — array indexing, to_int() return)
- `vfx_manager.gd` (1 fix — Dictionary key access for Color)
- `character_select.gd` (2 fixes — CHARACTERS array access)
- `throw_state.gd` (2 fixes — math expressions, abs() return)
- `kael_sprite.gd` + `rhena_sprite.gd` (94 fixes — outline Color variables)
- `round_manager.gd` (2 fixes — array comparison results)

**Commits:**
- `6076e0c` — audio_manager, round_manager
- `e76e2c6` — vfx_manager Color type
- `f54779d` — character_select Dictionary
- `c6fdc1c` — throw_state float + absf()
- `21df376` — 94 Color types in sprite files + method rename

### Root Cause
**Godot 4.6 does not infer types from:**
1. **Dictionary/Array element access** — `dict["key"]` or `array[0]` always returns `Variant`
2. **Math operations** — `40.0 * x` infers `Variant` if `x` is not explicitly typed
3. **Function return values without explicit type annotations** — `abs(x)` returns `Variant` unless declared `-> float`

The `:=` operator uses compile-time type inference. When the RHS is `Variant`, the LHS becomes `Variant` — even if runtime value is int/float/Color. This causes:
- Silent type mismatches in function calls expecting concrete types
- Runtime errors in exported builds (stricter than editor mode)
- Null reference errors when Godot expects typed objects

### Impact
- **10 emergency commits** in v0.2.0 cycle (all tagged "proactive" or "fix")
- **3-4 hours** of developer time hunting "why does this work in editor but not export?"
- **Cascading fixes** — once pattern discovered, mass audit required across 31 .gd files
- **Confidence hit** — if type system doesn't work as expected, what else breaks silently?

### Prevention for Sprint 2

**RULE 1: Never use `:=` for Dictionary, Array, or abs() values**

```gdscript
# ❌ WRONG — infers Variant
var x := dict["key"]
var y := array[0]
var dist := abs(a - b)

# ✅ CORRECT — explicit type
var x: float = dict["key"]
var y: int = array[0]
var dist: float = absf(a - b)  # Use absf() for floats, absi() for ints
```

**RULE 2: Use absf()/absi() instead of abs()**

Godot 4.6 has type-specific absolute value functions:
- `absf(x)` → `float`
- `absi(x)` → `int`
- `abs(x)` → `Variant` (legacy compatibility)

**RULE 3: Explicit return types on all functions**

```gdscript
# ❌ WRONG — return type inferred as Variant
func get_distance(a, b):
    return abs(a - b)

# ✅ CORRECT — explicit return type
func get_distance(a: float, b: float) -> float:
    return absf(a - b)
```

**RULE 4: Pre-commit type audit**

Add to integration gate:
```python
# Check for risky type inference patterns
risky_patterns = [
    r'var \w+ := .*\[',           # := with array/dict access
    r'var \w+ := abs\(',           # := with abs()
    r'var \w+ := .*\.get\(',       # := with Dictionary.get()
]
```

---

## Lesson 2: Custom Input Actions Break in Exports

### What Happened
Character select screen went through **6 fix attempts** across 10 days:

1. **c476a0b** — "accepts Enter/Space and arrow keys"
2. **7e3f67e** — "uses direct key events, bypasses action map"
3. **c552290** — "uses direct key events (v2)"
4. **7a5f3d4** — "input + CI import step (v3)"
5. **c72cd81** — "remove custom ui_* overrides that broke keyboard in exports"
6. **2655e2b** — "replace keycode input with Button nodes" (FINAL FIX)

**Problem pattern:**
- Custom `ui_*` action overrides with `physical_keycode:0` and `keycode:0` worked in editor
- Windows exports ignored Enter and arrow keys (Space/Tab still worked via engine hardcoding)
- Custom `_input()` with `InputEventKey` matching worked in editor, failed in exports

### Root Cause

**Godot's input system has three layers:**
1. **Engine built-ins** (ui_accept, ui_cancel, ui_left/right/up/down) — hardcoded C++ with editor + export support
2. **project.godot input map** — custom actions for game-specific controls
3. **_input() handlers** — raw event processing

**What broke:**
- Overriding `ui_*` actions in `project.godot` **replaces** engine defaults, doesn't extend them
- Setting `physical_keycode:0` and `keycode:0` creates invalid input events that editor tolerates but exports reject
- Custom `_input()` with `InputEventKey` bypasses Godot's focus system — works with keyboard but fails with controller/accessibility

**Why main menu worked:** Used native `Button` nodes with `grab_focus()` and `pressed.connect()` — Godot handles keyboard/controller/focus internally.

### Impact
- **6 PRs** to fix one screen (character select)
- **10 days** of back-and-forth (March 9-19)
- **3 tags** published with broken input (v0.1.3, v0.1.4 attempts)
- **Windows export testing** added to integration gate after this failure

### Prevention for Sprint 2

**RULE 1: Never override engine ui_* actions**

Godot's built-in `ui_accept`, `ui_cancel`, `ui_left`, `ui_right`, `ui_up`, `ui_down` already map:
- Enter, Space → accept
- Escape → cancel
- Arrow keys → directional
- Joypad buttons → equivalents

Use them as-is. Add game-specific actions separately:

```ini
# ✅ CORRECT — game actions, don't touch ui_*
[input]
p1_punch={...}
p1_kick={...}
```

**RULE 2: Use Button nodes for menus, not custom _input()**

```gdscript
# ❌ WRONG — bypasses focus system
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ENTER:
            _on_select()

# ✅ CORRECT — native Button with signals
@onready var button := $SelectButton
func _ready() -> void:
    button.pressed.connect(_on_select)
    button.grab_focus()  # Handles keyboard + controller
```

**RULE 3: Test in Windows export before tagging**

Added to integration gate (tool #5 Godot headless validator):
```bash
# Export Windows build and verify input events fire
godot --headless --export-release "Windows Desktop" builds/test.exe
# Run automated input test
python tools/test-exported-input.py builds/test.exe
```

**RULE 4: Follow main_menu.gd pattern everywhere**

Main menu worked on first try because it used:
- Native `Button` nodes (`@onready var start_button := $Panel/StartButton`)
- `grab_focus()` on first button
- `focus_neighbor_*` properties for arrow key navigation
- `button.pressed.connect()` signals
- `_unhandled_input()` for Escape (catches after focus system)

Character select fixed when it adopted this exact pattern (commit `2655e2b`).

---

## Lesson 3: Frame Data Drift — Three Sources of Truth Diverged

### What Happened
Playtest report (PLAYTEST-REPORT-SPRINT1.md) found frame data discrepancies:

**GDD spec (design intent):**
- MP startup: 7-9f
- MK startup: 8-9f

**Base .tres files (`resources/moves/fighter_base/`):**
- MP startup: **6f** (1f too fast)
- MK startup: **7f** (1f too fast)

**Character movesets (`resources/movesets/kael_moveset.tres`):**
- St.HP startup: Kael=12f, base=10f (2f difference)
- St.HK startup: Kael=14f, base=12f (2f difference)
- HK recovery: Kael=18f, Rhena=20f, base=22f (all different)

**Also:** Medium attacks (MP/MK) completely missing from character movesets — only 4 normals per character instead of 6-button GDD spec.

### Root Cause

**Three sources of frame data with no single authority:**
1. **GDD.md** — Designer intent, human-readable ranges
2. **`resources/moves/fighter_base/*.tres`** — Engine defaults (Godot Resource files)
3. **`resources/movesets/{kael,rhena}_moveset.tres`** — Character-specific overrides

**No validation** that:
- Base .tres matches GDD ranges
- Character .tres inherits or overrides base .tres correctly
- Movesets include all GDD-specified moves (6 buttons, not 4)

**Why it happened:**
- Base .tres created first (M1) from rough GDD numbers
- GDD refined after base files shipped (M2)
- Character movesets created by copying 4 moves, never expanded to 6
- No automated diff tool between GDD → .tres

### Impact
- **3 P1 bugs** filed by QA (issues #108, #109, #110)
- **Combo tuning blocked** — if frame data wrong, hitstun/blockstun calculations wrong
- **Designer frustration** — "I spec 7f MP startup, why does game have 6f?"
- **Balance testing invalid** — competitive tuning requires accurate frame data

### Prevention for Sprint 2

**RULE 1: Single source of truth — Character movesets only**

Delete `resources/moves/fighter_base/` entirely. Every character defines complete moveset:

```
resources/movesets/
  kael_moveset.tres    # 18 normals + 2 specials = 20 moves
  rhena_moveset.tres   # 18 normals + 2 specials = 20 moves
```

**RULE 2: Frame data CSV pipeline (Tool #11)**

GDD writes frame data to CSV:
```csv
character,move,startup,active,recovery,damage
Kael,St.LP,4,2,6,30
Kael,St.MP,7,3,10,50
```

Tool converts CSV → .tres on save. Designers edit spreadsheet, engine uses .tres.

**RULE 3: Frame data validator in integration gate**

```python
# Validate all GDD-specified moves exist in movesets
required_moves = ["lp", "mp", "hp", "lk", "mk", "hk"]  # × 3 stances
for character in ["kael", "rhena"]:
    moveset = load_tres(f"resources/movesets/{character}_moveset.tres")
    for move in required_moves:
        assert move in moveset, f"{character} missing {move}"
```

**RULE 4: GDD frame data as YAML (machine-readable)**

Move frame data from prose tables to structured YAML in GDD:

```yaml
frame_data:
  light:
    startup: [4, 5]
    active: [2, 3]
    recovery: [6, 8]
```

Validator loads YAML and checks .tres files against ranges.

---

## Lesson 4: Integration Gate Was Reactive, Not Proactive

### What Happened
Integration gate (tool #6) was created mid-Sprint 0 after 5 critical blockers merged (PR #32). It caught:
- Orphaned signals (6 signals defined but never emitted)
- Autoload dependency issues (VFXManager loaded before EventBus)
- Scene reference errors (fighter_base.tscn referenced missing scripts)

**But:** Integration gate ran **after merge**, not before. Issues caught post-merge required:
- Emergency fix PRs (#88, #89)
- Version rollback consideration
- Team interruption from Sprint 1 art work

### Root Cause
Integration gate was **manual execution** (`python tools/integration-gate.py`) documented in process but not enforced:

```bash
# Recommended workflow (not enforced):
1. Agent creates PR
2. Jango reviews code
3. Someone runs integration gate  # ← "Someone" = nobody
4. PR merges if gate passes
```

**Why it wasn't run:**
- No GitHub Action to run automatically
- Not part of PR merge checklist
- Assumed someone would remember
- Tool was new; team still learning workflow

### Impact
- **2 emergency fix PRs** after Sprint 0 merge wave
- **Signal wiring bugs** discovered by tool, not by testing
- **Autoload race conditions** not caught until runtime errors
- **Team morale hit** — "We have tools, why didn't they prevent this?"

### Prevention for Sprint 2

**RULE 1: Integration gate runs on every PR**

GitHub Action `.github/workflows/integration-gate.yml`:

```yaml
name: Integration Gate
on:
  pull_request:
    branches: [main]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run integration gate
        run: python tools/integration-gate.py
      - name: Post results
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: '❌ Integration gate FAILED. See job logs.'
            })
```

**RULE 2: Gate failure blocks merge**

Branch protection rule: Require "Integration Gate" status check to pass.

**RULE 3: Pre-merge checklist in PR template**

```markdown
## Pre-Merge Checklist
- [ ] Integration gate passing (automated)
- [ ] Code reviewed by Jango
- [ ] GDScript linting clean
- [ ] No Godot editor errors/warnings
- [ ] Windows export tested (if UI changes)
```

**RULE 4: Integration gate runs locally before push**

Pre-commit hook `.git/hooks/pre-push`:

```bash
#!/bin/bash
echo "Running integration gate..."
python tools/integration-gate.py
if [ $? -ne 0 ]; then
    echo "❌ Integration gate failed. Fix issues before pushing."
    exit 1
fi
```

---

## Lesson 5: Node Method Name Conflicts Were Silent Until Export

### What Happened
Commit `21df376` renamed `draw_ellipse()` to `draw_ellipse_outlined()` in character sprite files:

> "rename draw_ellipse to avoid Node2D conflict, explicit Color types for outline vars"

**Problem:** `Node2D` base class has a built-in `draw_ellipse()` method. Custom implementation in `character_sprite.gd` shadowed it. Editor didn't warn, but export builds crashed with "method signature mismatch" errors.

### Root Cause
Godot allows method overriding without explicit `override` keyword (unlike C++/C#). Name collision between:
- `Node2D.draw_ellipse(center: Vector2, radius: Vector2, color: Color)`
- Custom `CharacterSprite.draw_ellipse(...)` with different signature

Editor tolerated shadowing. Export builds enforced strict signature matching.

### Impact
- **1 emergency fix** before v0.2.0 ship
- **94 call site updates** across kael_sprite.gd (47×) and rhena_sprite.gd (47×)
- **Discovery pattern:** "It works in editor, breaks in export" (again)

### Prevention for Sprint 2

**RULE 1: Prefix custom draw methods with underscore**

```gdscript
# ❌ WRONG — shadows Node2D.draw_ellipse()
func draw_ellipse(center: Vector2, rx: float, ry: float) -> void:
    pass

# ✅ CORRECT — clearly custom
func _draw_ellipse_outlined(center: Vector2, rx: float, ry: float) -> void:
    pass
```

**RULE 2: Check method names against base class**

```bash
# Before implementing custom draw/input/physics methods:
grep -r "func draw_" /path/to/godot/source/scene/2d/
grep -r "func _input" /path/to/godot/source/scene/main/
```

**RULE 3: Add to GDScript linting rules**

GDScript linter (tool #1) should warn:
- Custom methods shadowing Node/Node2D/Control built-ins
- Public methods starting with `_` (reserved for Godot virtuals)

---

## Process Improvements

### 1. Pre-Merge Integration Gate (Mandatory)
**What:** Run integration gate as GitHub Action on every PR.  
**Why:** Catches signal wiring, autoload order, scene references before merge.  
**Owner:** Jango (Tool Engineer) implements Action, all agents benefit.  
**ETA:** Sprint 2 Day 1

### 2. Windows Export Testing (Selective)
**What:** Export Windows build and test input/UI for PRs touching input_map, UI scenes, or _input() handlers.  
**Why:** Editor ≠ export for input handling.  
**Owner:** Ackbar (QA) defines test protocol, CI runs it.  
**ETA:** Sprint 2 Week 1

### 3. Frame Data CSV Pipeline (Tool #11)
**What:** Designers edit frame_data.csv, tool auto-generates .tres files, commit both.  
**Why:** Single source of truth, version controlled, designer-friendly.  
**Owner:** Jango builds tool, Yoda (Designer) owns CSV.  
**ETA:** Sprint 2 Week 2

### 4. Type Safety Pre-Commit Check
**What:** Grep for risky `:=` patterns before commit, warn developer.  
**Why:** Prevent Godot 4.6 type inference bugs at source.  
**Owner:** Jango adds to integration gate.  
**ETA:** Sprint 2 Day 1

### 5. GDScript Standards Document
**What:** Team-wide coding standards with examples and rationale (see GDSCRIPT-STANDARDS.md).  
**Why:** Every rule links to Sprint 1 bug that motivated it.  
**Owner:** Jango (this document).  
**ETA:** Complete (this sprint)

---

## Tooling Improvements

### Tool #1: GDScript Linter Enhancement
**Add checks for:**
- `:=` with dictionary/array access
- `:=` with `abs()` (suggest `absf()`/`absi()`)
- Method names shadowing Node/Node2D built-ins
- Missing explicit return types on functions

### Tool #6: Integration Gate CI Workflow
**Convert manual script to automated GitHub Action:**
- Runs on every PR (not just post-merge)
- Blocks merge if gate fails
- Posts detailed failure report as PR comment

### Tool #11: Frame Data CSV → .tres Pipeline
**New tool for Sprint 2:**
- Reads `design/frame_data.csv`
- Generates `resources/movesets/{char}_moveset.tres`
- Validates against GDD YAML frame data spec
- Runs on file watch or pre-commit

### Tool #13: Export Build Validator
**New tool for Sprint 2:**
- Exports Windows build in CI
- Runs automated input test (simulates Enter, arrows, Escape)
- Compares input event handling: editor vs export
- Fails PR if input behavior differs

---

## Key Metrics — Sprint 1 Bug Landscape

| Metric | Count | Notes |
|--------|-------|-------|
| **Total fix commits** | 23 | Filtered by `--grep="fix"` |
| **Type safety fixes** | 10 | v0.2.0 proactive annotation commits |
| **Input handling fixes** | 6 | Character select iterations |
| **Integration blockers** | 5 | PR #32 emergency fixes |
| **Frame data bugs** | 3 | Issues #108, #109, #110 |
| **Closed bug issues** | 7 | Labels: `type:bug`, state: closed |
| **Days to fix char select** | 10 | March 9-19 (6 PRs) |
| **Emergency releases** | 3 | v0.1.3, v0.1.4, v0.1.5 input fixes |

---

## Sprint 2 Success Criteria

Sprint 2 will be considered successful if:

1. **Zero type inference bugs** — No `:=` with dict/array/abs() in any merged PR
2. **Zero input export failures** — All UI uses Button nodes, no custom keycode handling
3. **Zero frame data drift** — GDD ↔ CSV ↔ .tres validated by tool #11
4. **Integration gate passes before merge** — Not after (GitHub Action enforced)
5. **Fewer than 3 fix commits** — Down from 23 in Sprint 1

These are **leading indicators**, measurable during sprint, not post-mortem.

---

## Recommendations for Team

### For Developers
1. Read `GDSCRIPT-STANDARDS.md` before writing Sprint 2 code
2. Run integration gate locally before pushing (`python tools/integration-gate.py`)
3. When in doubt: explicit types everywhere, native UI nodes for input
4. Test in Windows export if touching input_map or UI

### For Code Reviewers (Jango)
1. Flag any `:=` with `[`, `.get()`, or `abs()` in PR
2. Flag any `_input()` handlers for UI (suggest Button nodes)
3. Flag any method names matching Node2D built-ins
4. Verify integration gate passed before approving

### For QA (Ackbar)
1. Windows export test protocol for UI PRs (tool #13)
2. Frame data validation checklist (GDD vs game behavior)
3. Input accessibility test (keyboard, controller, Steam Deck)

### For Designer (Yoda)
1. Own `design/frame_data.csv` as single source of truth
2. Update GDD frame data as YAML, not prose tables
3. Review tool #11 CSV→.tres pipeline output before commit

---

## Conclusion

Sprint 1 delivered **production-quality art** but revealed **systematic technical debt** in type safety, input handling, and data validation. These weren't one-off bugs — they were **patterns** that will repeat if not addressed.

The team now has:
- **13 tools** to catch issues proactively
- **Clear coding standards** with rationale
- **Automated validation** in CI/CD pipeline
- **Lessons learned** from 23 fix commits

Sprint 2 will measure success by **prevention**, not reaction. If we do this right, the next retrospective will be boring — and that's the goal.

---

*"We learn more from bugs than from features. Sprint 1 taught us Godot 4.6's sharp edges. Sprint 2 will show we learned the lesson."*

— Jango, Tool Engineer
