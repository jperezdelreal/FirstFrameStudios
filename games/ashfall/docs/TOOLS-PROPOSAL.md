# 🔧 First Frame Studios — Tools Proposal

**Author:** Jango (Lead, Tool Engineer)  
**Date:** 2026-03-09  
**Status:** UNLEASHED by Joaquín  
**Context:** "Jango tiene grandísimas ideas para generar tools y automatizar. Quiero que no tenga esa limitación del 20% de bandwidth. Quiero que Jango proponga tools, scripts y lo que se le ocurra para mejorar y facilitar la vida a sus compañeros y a nuestra empresa."

---

## Executive Summary

This proposal outlines **25 automation tools** to transform First Frame Studios from a team shipping code to a **machine that ships games**. These tools would have prevented all 5 M1+M2 integration blockers and addressed the #1 team feedback: "I never saw my work in the game."

**Philosophy:** Tools should prevent mistakes from happening, not just detect them afterward.

### Impact Categories

| Category | Tool Count | Prevented Issues |
|----------|------------|------------------|
| **Pre-Flight** (before code) | 5 | Spec drift, GDD compliance, dependency conflicts |
| **Pre-Commit** (during dev) | 6 | Scene integrity, signal wiring, autoload order |
| **Pre-Merge** (in CI/CD) | 5 | Branch targets, build validation, PR format |
| **Post-Merge** (integration) | 4 | Dead code, system wiring, integration gaps |
| **Continuous** (always on) | 5 | Stale branches, decision inbox, ownership tracking |

---

## 🔴 TIER 1: INTEGRATION KILLERS (What Would Have Prevented M1+M2 Failures)

These tools directly address the 5 blockers found in Jango's pre-M3 code review.

---

### 1. **Godot Headless Validator** (Pre-Merge)

**One-line:** Validates that `project.godot` loads without errors in CI pipeline.

**Impact:** 🔴 **CRITICAL** — Would have caught all 5 M1+M2 blockers before merge  
**Effort:** ⚡ **Quick** (2-3 hours)  
**Who benefits:** Everyone — prevents "game doesn't run" scenarios  

**How it works:**
- GitHub Action that runs after every PR and merge to main
- Uses `godot --headless --check-only` to load the project
- Parses Godot output for errors: missing autoloads, broken scene references, script errors
- Fails CI if project can't load
- Posts error summary as PR comment

**Technical approach:**
```yaml
# .github/workflows/godot-validate.yml
- name: Validate Godot Project
  run: |
    godot --headless --check-only --path games/ashfall/
    if [ $? -ne 0 ]; then
      echo "❌ Project validation failed"
      exit 1
    fi
```

**Root cause addressed:** M1+M2 Blocker #5 (autoload order), Blocker #1 (missing RoundManager instantiation)

---

### 2. **Autoload Dependency Analyzer** (Pre-Commit Hook)

**One-line:** Verifies autoload order matches dependency graph and all files exist.

**Impact:** 🔴 **CRITICAL** — Autoload order violations crash the game  
**Effort:** ⏱️ **Medium** (4-6 hours)  
**Who benefits:** All system owners (Chewie, Wedge, Bossk, Greedo, Lando)

**How it works:**
- Parses `project.godot` [autoload] section
- Extracts dependencies from each autoload script (e.g., `EventBus` must load before `GameState`)
- Builds dependency graph and validates topological order
- Checks that all autoload file paths exist
- Pre-commit hook blocks commits with invalid autoload config
- Can auto-fix simple ordering issues

**Technical approach:**
```python
# tools/validate_autoloads.py
def parse_autoloads(project_godot_path):
    # Extract autoload order
def extract_dependencies(script_path):
    # Parse GDScript for autoload references
def validate_order(autoloads, deps):
    # Topological sort, detect cycles
def suggest_fix(current, correct):
    # Generate corrected [autoload] section
```

**Root cause addressed:** M1+M2 Blocker #5 (SceneManager loads before RoundManager exists)

---

### 3. **Signal Wiring Validator** (Pre-Commit Hook)

**One-line:** Ensures every `emit_signal()` has a corresponding `.connect()` somewhere.

**Impact:** 🟡 **HIGH** — Silent signal failures are invisible bugs  
**Effort:** ⏱️ **Medium** (5-6 hours)  
**Who benefits:** All agents — prevents "I emitted but nobody listened"

**How it works:**
- Scans all `.gd` files for `signal` definitions and `emit_signal()` calls
- Scans for `.connect()` calls that wire those signals
- Flags signals that are emitted but never connected
- Generates report: "fighter_base.gd emits 'knocked_out' but no script connects to it"
- Runs as pre-commit hook or CI step

**Technical approach:**
```python
# tools/validate_signals.py
def find_signal_definitions(gd_files):
    # Parse: signal health_changed(old, new)
def find_emits(gd_files):
    # Parse: emit_signal("health_changed", ...)
def find_connects(gd_files, tscn_files):
    # Parse: node.signal_name.connect(...)
def report_unwired_signals(signals, emits, connects):
    # Cross-reference and flag gaps
```

**Root cause addressed:** M1+M2 Blocker #2 (fighter KO signals not wired to RoundManager)

---

### 4. **Scene Integrity Checker** (Pre-Commit Hook)

**One-line:** Validates `.tscn` files for broken node paths, missing scripts, invalid autoload references.

**Impact:** 🟡 **HIGH** — Scene errors crash Godot on load  
**Effort:** ⏱️ **Medium** (4-5 hours)  
**Who benefits:** Scene owners (Leia, Wedge, Lando)

**How it works:**
- Parses `.tscn` files (Godot's text scene format)
- Checks `script = ExtResource(...)` references point to existing files
- Validates `node_path = NodePath("...")` references match scene tree
- Confirms autoload references (e.g., `EventBus`) are defined in `project.godot`
- Validates collision layers/masks exist in project settings
- Runs as pre-commit hook

**Technical approach:**
```python
# tools/validate_scenes.py
def parse_tscn(file_path):
    # Extract ExtResource, NodePath, autoload refs
def validate_script_refs(scene_data, project_root):
    # Check script files exist
def validate_node_paths(scene_data):
    # Ensure NodePaths match scene tree
def validate_autoloads(scene_data, project_godot):
    # Confirm autoloads are defined
```

**Root cause addressed:** M1+M2 Blocker #1 (RoundManager not instantiated in fight_scene.tscn)

---

### 5. **Integration Gate Automation** (Post-Merge)

**One-line:** Runs end-to-end smoke test after every PR merge wave, blocks next wave if fails.

**Impact:** 🔴 **CRITICAL** — This is the ceremony that didn't exist in M1+M2  
**Effort:** ⏱️ **Medium** (6-8 hours)  
**Who benefits:** Everyone — prevents "dead code" syndrome

**How it works:**
- Triggers automatically after 2+ PRs merge from same wave
- Runs integration checklist from `.squad/ceremonies.md`:
  1. Pull latest main
  2. Open project in Godot headless
  3. Load fight scene
  4. Verify all autoloads initialize
  5. Check Output console for errors
  6. Run primary game flow (menu → select → fight → victory)
  7. Validate cross-system wiring (VFX on hit, audio on events, HUD updates)
- Posts pass/fail report to #integration Slack channel
- Blocks new feature work if integration fails

**Technical approach:**
```python
# tools/integration_gate.py
def detect_merge_wave(github_api):
    # Check if 2+ PRs merged in last hour from same milestone
def run_integration_checklist():
    # Execute each gate step
def open_godot_headless():
    # godot --headless --script integration_test.gd
def validate_game_flow():
    # Load scenes, check for crashes
def post_results(slack_webhook, pass_fail, errors):
    # Notify team
```

**Root cause addressed:** All 5 M1+M2 blockers — integration was never verified

---

## 🟡 TIER 2: DEVELOPER JOY (What Would Have Solved "I Never Saw My Work Running")

These tools address the #1 team feedback: 8/10 agents never saw their work in the game.

---

### 6. **Test Scene Generator** (Developer Tool)

**One-line:** Auto-generates minimal test scenes for every core system.

**Impact:** 🟡 **HIGH** — Solves the satisfaction gap  
**Effort:** ⏱️ **Medium** (5-6 hours)  
**Who benefits:** All system owners (Chewie, Lando, Bossk, Greedo, Wedge, Leia)

**How it works:**
- Template system for common test patterns:
  - State machine: two colored rectangles with keyboard input
  - VFX: button grid that triggers each effect at mouse position
  - Audio: button grid with waveform visualizer
  - Input buffer: on-screen display of buffered inputs
  - Stage: fighters as colored rectangles walking on stage
- One command generates boilerplate test scene
- Agents customize for their specific system
- Test scenes live in `tests/scenes/` and are excluded from builds

**Technical approach:**
```bash
# tools/generate_test_scene.sh
./generate_test_scene.sh state_machine
# Creates: tests/scenes/test_state_machine.tscn + test_state_machine.gd
# Template includes: debug text, button inputs, visual feedback
```

**Team feedback addressed:** Chewie, Lando, Leia, Wedge, Bossk, Greedo, Tarkin all suggested this

---

### 7. **VFX/Audio Test Bench** (Developer Tool)

**One-line:** Standalone scene with button grid to trigger every effect in real-time.

**Impact:** 🟡 **HIGH** — Enables feel-based tuning instead of theory-based  
**Effort:** ⚡ **Quick** (2-3 hours)  
**Who benefits:** Bossk (VFX), Greedo (Audio)

**How it works:**
- Scene with 3x5 button grid
- Each button triggers a different effect: screen shake, hit sparks, KO slow-mo, etc.
- Sliders for intensity/duration parameters
- Real-time parameter tuning with instant visual/audio feedback
- "Export Config" button saves values to script constants
- Works without full game running

**Technical approach:**
```gdscript
# tests/scenes/test_bench.gd
func _ready():
    $ButtonGrid/ScreenShake.pressed.connect(func():
        VFXManager.screen_shake(
            $Sliders/Intensity.value, 
            $Sliders/Duration.value
        )
    )
```

**Team feedback addressed:** Bossk: "VFX is a feel discipline. You tune by playing, not by reading code."

---

### 8. **Live Reload Watcher** (Developer Tool)

**One-line:** Auto-reloads Godot scene when `.gd` files change, like web dev hot reload.

**Impact:** 🟢 **MEDIUM** — Faster iteration cycle  
**Effort:** ⏱️ **Medium** (4-5 hours)  
**Who benefits:** All developers

**How it works:**
- File system watcher monitors `.gd` and `.tscn` files
- On change, sends signal to Godot EditorPlugin
- Plugin reloads current scene automatically
- Preserves runtime state where possible
- Configurable: enable/disable per-project

**Technical approach:**
```python
# tools/live_reload_watcher.py (runs alongside Godot)
import watchdog
def on_file_changed(event):
    if event.src_path.endswith(('.gd', '.tscn')):
        send_godot_reload_signal()

# addons/live_reload/plugin.gd (EditorPlugin)
func _on_reload_signal():
    get_editor_interface().reload_scene_from_path(current_scene)
```

**Team feedback addressed:** General workflow improvement for tight iteration loops

---

### 9. **Frame Data CSV Pipeline** (Designer Tool)

**One-line:** Converts CSV spreadsheet to `.tres` resource files for movesets and balance.

**Impact:** 🟡 **HIGH** — Empowers Yoda to tune balance without touching Godot  
**Effort:** ⏱️ **Medium** (4-5 hours)  
**Who benefits:** Yoda (Design), Lando (Moveset), all balance-focused work

**How it works:**
- Yoda edits `character_moves.csv` in Google Sheets or Excel:
  ```csv
  character,move_name,startup,active,recovery,damage,knockback,ember_cost
  kael,light_punch,4,2,8,50,200,0
  kael,rising_cinder,8,4,16,120,400,25
  ```
- Script converts CSV → `.tres` resource files
- Validates data (startup > 0, damage > 0, etc.)
- Generates move resource with all frame data
- One command updates all character movesets

**Technical approach:**
```python
# tools/csv_to_tres.py
import csv
def parse_move_csv(csv_path):
    # Read CSV, validate columns
def generate_tres(move_data):
    # Write Godot .tres format:
    # [resource]
    # script = ExtResource("moveset_resource.gd")
    # move_name = "light_punch"
    # ...
def convert_all(csv_path, output_dir):
    # Process entire CSV → games/ashfall/resources/moves/
```

**Team feedback addressed:** Jango: "Frame data tuning is a designer task, not a code task."

---

### 10. **Session Checkpoint Generator** (Process Tool)

**One-line:** Auto-generates checkpoint summary: what changed, what to test, dependencies.

**Impact:** 🟢 **MEDIUM** — Helps agents resume work after interruptions  
**Effort:** ⚡ **Quick** (2-3 hours)  
**Who benefits:** All agents, especially multi-tasking scenarios

**How it works:**
- Reads git diff since last checkpoint
- Extracts changed files, added signals, new scenes
- Identifies dependencies (e.g., "modified EventBus → may affect VFXManager")
- Generates markdown summary:
  ```markdown
  ## Checkpoint: 2026-03-09 14:32
  **Changed:** fighter_base.gd (added knockback logic)
  **Added signals:** damage_taken(amount)
  **Dependencies:** HUD, VFXManager, AudioManager
  **Next steps:** Wire damage_taken to HUD health bar
  ```
- Saves to `.checkpoints/YYYY-MM-DD_HHMM.md`

**Technical approach:**
```python
# tools/generate_checkpoint.py
def get_git_diff(since_commit):
    # git diff --name-only
def extract_signals(changed_files):
    # Parse .gd files for new signals
def infer_dependencies(changed_files, codebase):
    # Check which files import changed files
def generate_summary(data):
    # Write markdown checkpoint
```

**Team feedback addressed:** Helps context-switching between tasks

---

## 🟢 TIER 3: PROCESS AUTOMATION (What Makes the Studio Run Like a Machine)

These tools automate repetitive process work and reduce coordination overhead.

---

### 11. **PR Body Validator** (Pre-Merge CI)

**One-line:** Enforces PR format: "Closes #N" in body (not title), required sections filled.

**Impact:** 🟡 **HIGH** — Ensures PRs are traceable and well-documented  
**Effort:** ⚡ **Quick** (1-2 hours)  
**Who benefits:** Mace (Operations), all reviewers

**How it works:**
- GitHub Action parses PR body text
- Checks for required sections:
  - "Closes #N" or "Fixes #N" in body (GitHub auto-closes issues)
  - Description section (what changed)
  - Testing section (how it was verified)
- Validates issue number exists and is open
- Fails CI if format incorrect
- Posts comment with template if missing

**Technical approach:**
```yaml
# .github/workflows/pr-validate.yml
- name: Validate PR Body
  run: |
    python tools/validate_pr_body.py \
      --pr-number ${{ github.event.pull_request.number }} \
      --body "${{ github.event.pull_request.body }}"
```

**Root cause addressed:** M1+M2 retro: "Closes #N" syntax errors caused issues not to auto-close

---

### 12. **Branch Staleness Detector** (Continuous)

**One-line:** Alerts team to PRs and branches older than N days.

**Impact:** 🟢 **MEDIUM** — Prevents work from getting lost  
**Effort:** ⚡ **Quick** (2 hours)  
**Who benefits:** Mace (Operations), PR authors

**How it works:**
- Daily cron job via GitHub Actions
- Queries GitHub API for:
  - Open PRs older than 7 days
  - Branches with no commits in 14 days
  - Branches merged but not deleted
- Posts report to Slack #dev channel
- Tags PR authors for stale PRs
- Can auto-close "wontfix" PRs after 30 days with label

**Technical approach:**
```python
# tools/detect_stale_branches.py
def get_open_prs(repo, days=7):
    # GitHub API: pulls?state=open&sort=updated&direction=asc
def get_stale_branches(repo, days=14):
    # GitHub API: branches + last commit date
def post_slack_report(stale_items):
    # Slack webhook with summary
```

**Team feedback addressed:** Tarkin's dead branch scenario would have been caught day 1

---

### 13. **Decision Inbox Merger** (Process Automation)

**One-line:** Automates Scribe's job of merging decision files from inbox to archive.

**Impact:** 🟢 **LOW** — Saves Scribe time, but not critical  
**Effort:** ⚡ **Quick** (2 hours)  
**Who benefits:** Scribe (Mace), decision authors

**How it works:**
- Scans `.squad/decisions/inbox/*.md`
- For each file, checks status: "Status: accepted"
- If accepted, moves to `.squad/decisions/archive/YYYY-MM-DD_title.md`
- Updates decision index in `.squad/decisions/INDEX.md`
- Runs weekly or on-demand
- Can be triggered by PR merge

**Technical approach:**
```python
# tools/merge_decisions.py
def scan_inbox(inbox_path):
    # Find all .md files
def check_status(decision_file):
    # Parse front matter for "Status: accepted"
def move_to_archive(file, archive_path):
    # Rename with date prefix
def update_index(decisions):
    # Generate INDEX.md with all decisions
```

**Team feedback addressed:** Mace mentioned this is tedious manual work

---

### 14. **GDD Diff Reporter** (Documentation Tool)

**One-line:** Shows what changed in GDD since last milestone, highlights spec drift.

**Impact:** 🟡 **HIGH** — Catches silent spec changes  
**Effort:** ⚡ **Quick** (2-3 hours)  
**Who benefits:** Yoda (Design), all implementers

**How it works:**
- Tags GDD at milestone completion: `git tag gdd-m1`
- On milestone start, runs diff: `git diff gdd-m1..HEAD docs/GDD.md`
- Highlights added/removed requirements
- Generates report: "Combat section changed: 6-button → 4-button"
- Posts to Slack at milestone kickoff
- Ensures team sees GDD changes explicitly

**Technical approach:**
```python
# tools/gdd_diff_report.py
def get_gdd_changes(tag_from, tag_to):
    # git diff tag_from..tag_to docs/GDD.md
def parse_sections(diff):
    # Extract changed sections (Combat, Progression, etc.)
def highlight_requirements(section_diff):
    # Identify added (+) and removed (-) requirements
def generate_report(changes):
    # Markdown report of what changed
```

**Root cause addressed:** 4-button vs 6-button spec drift happened silently

---

### 15. **File Ownership Matrix Generator** (Documentation Tool)

**One-line:** Auto-generates who built what, based on git blame and authorship.

**Impact:** 🟢 **MEDIUM** — Helps coordination and code review assignments  
**Effort:** ⚡ **Quick** (2 hours)  
**Who benefits:** Mace (Operations), all reviewers

**How it works:**
- Runs `git blame` on all files in repo
- Aggregates lines-of-code per author per file
- Generates ownership matrix:
  ```markdown
  ## File Ownership Matrix
  | File | Primary Owner | Contributors |
  |------|---------------|--------------|
  | fighter_base.gd | Chewie (82%) | Lando (18%) |
  | input_buffer.gd | Lando (100%) | |
  | vfx_manager.gd | Bossk (95%) | Wedge (5%) |
  ```
- Updates on milestone completion
- Helps assign reviewers: "Chewie should review fighter changes"

**Technical approach:**
```bash
# tools/generate_ownership_matrix.sh
for file in $(find games/ashfall/scripts -name "*.gd"); do
  git blame --line-porcelain $file | grep "^author " | sort | uniq -c
done
```

**Team feedback addressed:** Solo's file ownership map idea from feedback ceremony

---

## 🟣 TIER 4: QUALITY OF LIFE (Small Wins, Big Impact)

Quick wins that improve daily workflow.

---

### 16. **Collision Layer Matrix Generator** (Documentation Tool)

**One-line:** Extracts collision layers from `project.godot`, generates visual matrix.

**Impact:** 🟢 **LOW** — Nice reference, but not critical  
**Effort:** ⚡ **Quick** (1 hour)  
**Who benefits:** Physics implementers (Chewie, Lando)

**How it works:**
- Parses `project.godot` for collision layer definitions
- Generates markdown table of which layers interact:
  ```markdown
  ## Collision Layer Matrix
  |         | Player | Enemy | Hitbox | Hurtbox | Stage |
  |---------|--------|-------|--------|---------|-------|
  | Player  | ❌     | ❌    | ❌     | ✅      | ✅    |
  | Enemy   | ❌     | ❌    | ❌     | ✅      | ✅    |
  | Hitbox  | ❌     | ❌    | ❌     | ✅      | ❌    |
  | Hurtbox | ✅     | ✅    | ✅     | ❌      | ❌    |
  | Stage   | ✅     | ✅    | ❌     | ❌      | ❌    |
  ```
- Updates whenever `project.godot` changes
- Saves to `docs/COLLISION_LAYERS.md`

**Technical approach:**
```python
# tools/generate_collision_matrix.py
def parse_layers(project_godot):
    # Extract [layer_names] section
def generate_matrix(layers):
    # Cross-reference which layers collide
def write_markdown(matrix):
    # Render table
```

**Team feedback addressed:** Helpful reference, low effort

---

### 17. **Skills Browser CLI** (Developer Tool)

**One-line:** Lists all squad skills with confidence levels and search.

**Impact:** 🟢 **LOW** — Convenient reference  
**Effort:** ⚡ **Quick** (1 hour)  
**Who benefits:** All agents

**How it works:**
- CLI tool: `./skills list`
- Scans `.squad/skills/` directory
- Parses each `SKILL.md` for confidence level
- Outputs table:
  ```
  SKILL                          CONFIDENCE    LAST UPDATED
  godot-beat-em-up-patterns      high          2026-03-08
  integration-discipline         medium        2026-03-09
  state-machine-patterns         high          2026-03-07
  ```
- Search: `./skills search "combat"`
- Can output JSON for other tools

**Technical approach:**
```python
# tools/skills.py
def list_skills(skills_dir):
    # Find all SKILL.md files
def parse_confidence(skill_file):
    # Extract confidence level from front matter
def search_skills(query, skills_dir):
    # Grep through skill content
```

**Team feedback addressed:** Makes skill knowledge more accessible

---

### 18. **Branch Validation CI Action** (Pre-Merge CI)

**One-line:** Rejects PRs targeting non-main branches unless explicitly allowed.

**Impact:** 🔴 **CRITICAL** — Prevents Tarkin-class dead branch failures  
**Effort:** ⚡ **Quick** (30 min)  
**Who benefits:** Everyone — prevents coordination disasters

**How it works:**
- GitHub Action triggered on PR open/update
- Checks PR base branch
- If base != `main` and no `allow-branch-target` label, fail CI
- Posts comment: "⚠️ This PR targets branch `{branch}` instead of `main`. Is this intentional?"
- Requires explicit label to merge to non-main branches

**Technical approach:**
```yaml
# .github/workflows/branch-validation.yml
name: Validate PR Base Branch
on: pull_request
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Check base branch
        run: |
          if [[ "${{ github.event.pull_request.base.ref }}" != "main" ]]; then
            echo "❌ PR targets non-main branch: ${{ github.event.pull_request.base.ref }}"
            exit 1
          fi
```

**Root cause addressed:** Tarkin's AI controller PRs all targeted `dev/ai-integration` instead of `main`

---

### 19. **Auto-Delete Merged Branches** (Process Automation)

**One-line:** GitHub setting + Action to delete branches after PR merge.

**Impact:** 🟢 **MEDIUM** — Prevents branch clutter  
**Effort:** ⚡ **Quick** (5 min)  
**Who benefits:** Everyone — cleaner repo

**How it works:**
- Enable GitHub repo setting: "Automatically delete head branches"
- Backup GitHub Action for non-default deletions
- Keeps `main` and `dev/*` branches with protection rules
- Deletes feature branches after merge

**Technical approach:**
- GitHub Settings → General → Pull Requests → ✅ Automatically delete head branches
- Done. No code needed.

**Root cause addressed:** Tarkin's dead branches would have been deleted after merge

---

### 20. **Godot Gotcha Documentation** (Knowledge Base)

**One-line:** Centralized doc of Godot platform traps and how to avoid them.

**Impact:** 🟢 **MEDIUM** — Saves debugging time  
**Effort:** ⚡ **Quick** (2 hours to start, ongoing)  
**Who benefits:** All Godot developers

**How it works:**
- Living document: `docs/GODOT_GOTCHAS.md`
- Agents add entries when they hit traps:
  ```markdown
  ### StyleBoxFlat Sub-Resource Sharing
  **Problem:** StyleBox in .tscn files are shared by default. Changing one changes all.
  **Solution:** Call `.duplicate()` before mutating: `var style = $Panel.get_theme_stylebox("panel").duplicate()`
  **Affected:** Wedge (health bars)
  ```
- Categories: UI, Physics, Autoloads, Scenes, Signals
- Searchable index

**Technical approach:**
- Just a markdown file, no tooling
- Updated as team discovers issues

**Team feedback addressed:** Wedge: "StyleBox gotcha cost me 15 minutes. Should be documented."

---

## 🔵 TIER 5: AGENT COORDINATION (Multi-Agent Workflow Tools)

Tools that help parallel work waves coordinate safely.

---

### 21. **project.godot Lock Coordinator** (Coordination Tool)

**One-line:** Prevents two agents from modifying `project.godot` in parallel.

**Impact:** 🟡 **HIGH** — Merge conflicts in project.godot are painful  
**Effort:** ⏱️ **Medium** (3-4 hours)  
**Who benefits:** All agents modifying project settings

**How it works:**
- Before any PR that touches `project.godot`, agent must "claim lock"
- Lock system tracks: who has lock, when claimed, which PR
- Lock stored in `.squad/locks/project_godot.lock` (committed to repo)
- Pre-commit hook checks: "Does my PR modify project.godot? Do I have lock?"
- Fails commit if no lock
- Lock auto-releases when PR merges
- Dashboard shows current lock holder

**Technical approach:**
```python
# tools/lock_coordinator.py
def claim_lock(resource, agent_name, pr_number):
    # Check if locked, create lock file
def check_lock(resource, agent_name):
    # Pre-commit: validate lock holder
def release_lock(resource):
    # Post-merge: remove lock file
def list_locks():
    # Dashboard of current locks
```

**Team feedback addressed:** Solo's parallel work coordination concerns

---

### 22. **Parallel Wave Planner** (Coordination Tool)

**One-line:** Uses file ownership matrix to assign conflict-free agent work.

**Impact:** 🟡 **HIGH** — Maximizes parallelism, minimizes merge conflicts  
**Effort:** ⏱️ **Medium** (5-6 hours)  
**Who benefits:** Mace (Operations), all agents in parallel waves

**How it works:**
- Input: list of GitHub issues for next wave
- For each issue, extracts likely file changes (based on description)
- Checks file ownership matrix for conflicts
- Generates conflict-free assignment:
  ```
  Wave 3 Plan (5 agents, 0 conflicts):
  - Chewie: #45 (state machine) → files: fighter_base.gd, states/*
  - Lando: #46 (input) → files: input_buffer.gd, input_handler.gd
  - Bossk: #47 (VFX) → files: vfx_manager.gd
  - Greedo: #48 (audio) → files: audio_manager.gd
  - Wedge: #49 (HUD) → files: fight_hud.gd
  ✅ No file overlaps detected
  ```
- If conflicts detected, suggests alternative groupings

**Technical approach:**
```python
# tools/plan_parallel_wave.py
def extract_file_impact(issue):
    # Parse issue description for file mentions
def check_conflicts(assignments, ownership_matrix):
    # Detect file overlap
def suggest_grouping(issues, ownership):
    # Optimize for max parallelism + min conflicts
```

**Team feedback addressed:** Solo's file ownership map → parallel work optimization

---

### 23. **Integration Test Manifest** (Testing Tool)

**One-line:** Defines what to verify after each parallel wave completes.

**Impact:** 🟡 **HIGH** — Makes integration gate systematic  
**Effort:** ⏱️ **Medium** (3-4 hours)  
**Who benefits:** Integration gate runner (Ackbar, Jango)

**How it works:**
- YAML manifest: `.squad/integration_tests/wave_N.yml`
  ```yaml
  wave: 3
  systems: [state_machine, input, vfx, audio, hud]
  tests:
    - name: "State machine transitions"
      scene: tests/scenes/test_state_machine.tscn
      steps:
        - press: ui_right
        - expect: state == "walk"
        - press: ui_up
        - expect: state == "jump"
    - name: "Hit detection"
      scene: scenes/fight_scene.tscn
      steps:
        - spawn: [fighter1, fighter2]
        - press: ui_punch
        - expect: fighter2.health < 1000
  ```
- Tool executes tests in Godot headless mode
- Posts pass/fail report

**Technical approach:**
```python
# tools/run_integration_tests.py
def parse_manifest(yaml_file):
    # Load test definition
def execute_test(test, godot_path):
    # Run Godot with test scene + script
def validate_expectations(test, output):
    # Check assertions
```

**Team feedback addressed:** Makes integration gate repeatable and systematic

---

### 24. **.tscn Dependency Graph Visualizer** (Documentation Tool)

**One-line:** Generates visual graph of which scenes reference which scenes.

**Impact:** 🟢 **LOW** — Nice visualization, but not critical  
**Effort:** ⏱️ **Medium** (3-4 hours)  
**Who benefits:** Architects (Solo), scene designers

**How it works:**
- Parses all `.tscn` files
- Extracts scene dependencies (e.g., `fight_scene.tscn` instantiates `fighter_base.tscn`)
- Generates Graphviz DOT file
- Renders SVG: `docs/scene_dependency_graph.svg`
- Shows which scenes are "roots" vs "leaves"
- Helps understand scene hierarchy at a glance

**Technical approach:**
```python
# tools/generate_scene_graph.py
def parse_scene_deps(tscn_file):
    # Extract ExtResource type="PackedScene"
def build_graph(scenes, deps):
    # Create directed graph
def render_graphviz(graph):
    # Generate DOT format → SVG
```

**Team feedback addressed:** Solo's architecture visualization needs

---

### 25. **Post-Milestone Ceremony Runner** (Process Automation)

**One-line:** Automated checklist for milestone completion: wiki update, devlog, retro, GDD tag.

**Impact:** 🟢 **MEDIUM** — Reduces ceremony overhead  
**Effort:** ⏱️ **Medium** (4-5 hours)  
**Who benefits:** Mace (Operations), all agents

**How it works:**
- Triggered manually: `./tools/complete_milestone.sh M3`
- Interactive checklist:
  ```
  Milestone M3 Completion Checklist
  ☐ Tag GDD: git tag gdd-m3
  ☐ Generate GDD diff report (since gdd-m2)
  ☐ Update wiki with milestone deliverables
  ☐ Post devlog to team Slack
  ☐ Schedule retrospective ceremony
  ☐ Run integration smoke test
  ☐ Archive decisions from inbox
  ☐ Generate file ownership matrix
  ☐ Close milestone GitHub project
  ```
- Each step can be automated or manual
- Tracks completion in `.squad/milestones/M3_completion.yml`

**Technical approach:**
```bash
# tools/complete_milestone.sh
echo "☐ Tag GDD"
read -p "Press enter when done..."
git tag gdd-$1 && echo "✅ Tagged"

echo "☐ Generate GDD diff"
python tools/gdd_diff_report.py --from gdd-m2 --to gdd-$1
```

**Team feedback addressed:** Makes milestone ceremonies systematic and trackable

---

## Implementation Roadmap

### Phase 1: Integration Killers (Week 1)
**Goal:** Prevent M1+M2 failures from recurring

1. **Branch Validation CI** (30 min) — Quick win, huge impact
2. **Auto-Delete Merged Branches** (5 min) — Trivial setup
3. **Godot Headless Validator** (2-3 hours) — Critical CI step
4. **Autoload Dependency Analyzer** (4-6 hours) — Prevents crashes
5. **Signal Wiring Validator** (5-6 hours) — Catches integration gaps

**Week 1 Output:** 5 tools live, 100% of M1+M2 blockers preventable

---

### Phase 2: Developer Joy (Week 2)
**Goal:** Solve "I never saw my work running"

6. **Test Scene Generator** (5-6 hours) — Template system
7. **VFX/Audio Test Bench** (2-3 hours) — Tuning environment
8. **PR Body Validator** (1-2 hours) — Quick CI win
9. **Branch Staleness Detector** (2 hours) — Continuous monitoring
10. **GDD Diff Reporter** (2-3 hours) — Spec drift detection

**Week 2 Output:** 5 more tools, developers can test in isolation

---

### Phase 3: Process Automation (Week 3)
**Goal:** Reduce coordination overhead

11. **Integration Gate Automation** (6-8 hours) — The ceremony as code
12. **Scene Integrity Checker** (4-5 hours) — Pre-commit validation
13. **Frame Data CSV Pipeline** (4-5 hours) — Designer empowerment
14. **Decision Inbox Merger** (2 hours) — Automate Scribe work
15. **File Ownership Matrix** (2 hours) — Documentation automation

**Week 3 Output:** 5 more tools, ceremonies become automated

---

### Phase 4: Quality of Life (Week 4)
**Goal:** Small wins, daily workflow improvements

16. **Collision Layer Matrix** (1 hour)
17. **Skills Browser CLI** (1 hour)
18. **Godot Gotcha Documentation** (2 hours to start)
19. **Session Checkpoint Generator** (2-3 hours)
20. **Live Reload Watcher** (4-5 hours)

**Week 4 Output:** 5 more tools, better daily experience

---

### Phase 5: Coordination Tools (Week 5)
**Goal:** Enable safe parallel work at scale

21. **project.godot Lock Coordinator** (3-4 hours)
22. **Parallel Wave Planner** (5-6 hours)
23. **Integration Test Manifest** (3-4 hours)
24. **.tscn Dependency Visualizer** (3-4 hours)
25. **Post-Milestone Ceremony Runner** (4-5 hours)

**Week 5 Output:** 5 final tools, coordination becomes systematic

---

## Success Metrics

### Quantitative
- **Integration blockers:** 5 in M1+M2 → 0 in M3+ (target)
- **Dead branches:** 1 in M1+M2 (Tarkin) → 0 in M3+
- **PR format violations:** ~30% → 0% (enforced by CI)
- **Stale branches:** Unknown → 0 branches >14 days
- **GDD drift incidents:** 1 in M1+M2 (4-button vs 6-button) → 0 in M3+

### Qualitative
- **Developer satisfaction:** "I never saw my work" → "I test my work daily"
- **Integration confidence:** "Hope it works" → "Know it works"
- **Coordination overhead:** Manual tracking → Automated monitoring
- **Onboarding time:** New agents get test benches + guardrails from Day 1

---

## Top 5 Tools by Impact

### 🥇 #1: Integration Gate Automation
**Why:** This is the ceremony that didn't exist. Would have caught all 5 M1+M2 blockers.  
**Impact:** Transforms "hope it integrates" into "verify it integrates"  
**ROI:** 6-8 hours investment, prevents days of integration debugging  

### 🥈 #2: Branch Validation CI + Auto-Delete
**Why:** Prevents Tarkin-class coordination disasters permanently.  
**Impact:** Zero ongoing effort, eliminates entire class of failures  
**ROI:** 30 minutes investment, prevents multi-day recovery scenarios  

### 🥉 #3: Godot Headless Validator
**Why:** CI gate that ensures project loads before merge.  
**Impact:** "Does the project load?" becomes a pre-merge requirement  
**ROI:** 2-3 hours investment, catches crashes before they reach main  

### 4️⃣ #4: Test Scene Generator + VFX/Audio Test Bench
**Why:** Solves "I never saw my work running" for 8/10 agents.  
**Impact:** Developer joy → better retention and higher quality work  
**ROI:** 7-9 hours investment, improves team satisfaction permanently  

### 5️⃣ #5: Signal Wiring Validator + Scene Integrity Checker
**Why:** Pre-commit hooks that prevent integration bugs from being written.  
**Impact:** Catches bugs at author time, not review/integration time  
**ROI:** 9-11 hours investment, reduces review cycles and integration failures  

---

## Risk Assessment

### What Could Go Wrong?

**"Tools become maintenance burden"**
- Mitigation: Start with low-maintenance tools (CI scripts, git hooks)
- All tools must be documented and have clear owners
- If a tool breaks and nobody fixes it in 2 weeks, delete it

**"Tools slow down development"**
- Mitigation: Pre-commit hooks must run <5 seconds
- CI steps must run <2 minutes
- Any tool that adds >10% to workflow time gets re-evaluated

**"Tools don't get used"**
- Mitigation: Make tools required (CI enforcement) or incredibly convenient (CLI shortcuts)
- Gather feedback after 1 month: what's helping? what's annoying?

**"Over-automation reduces learning"**
- Mitigation: Tools should teach, not hide. Error messages explain *why* something failed
- "Godot gotcha documentation" captures lessons, doesn't just block behavior

---

## Alternatives Considered

### Option A: Manual Process Only
**Pros:** No tool development time  
**Cons:** M1+M2 proved this fails at scale. Humans forget checklists.  
**Verdict:** ❌ Rejected — integration failures too costly

### Option B: Full CI/CD + Test Coverage
**Pros:** Industry standard, comprehensive  
**Cons:** Godot testing ecosystem is immature. Would take months to set up properly.  
**Verdict:** ⏸️ Future work — start with smoke tests, grow into full coverage

### Option C: Buy Commercial Tools
**Pros:** Professional support, polished UX  
**Cons:** Godot ecosystem lacks commercial tooling. Would need to build custom anyway.  
**Verdict:** ❌ Not viable — Godot is too niche

---

## Resource Requirements

### Jango's Time (Unleashed)
- **Phase 1-2:** 25-30 hours (2 weeks full-time)
- **Phase 3-5:** 30-35 hours (2 more weeks)
- **Total:** 55-65 hours (4 weeks full-time, 100% bandwidth)

### Team Time
- **Learning curve:** 2 hours per agent (tool intro + documentation)
- **Ongoing:** <5 min per agent per day (pre-commit hooks, CI checks)
- **Ceremonies:** Integration gate becomes automated (saves 30 min per wave)

### Infrastructure
- **GitHub Actions:** Free tier sufficient (< 2000 min/month)
- **Storage:** Negligible (<50MB for all tools)
- **Dependencies:** Python 3.x, Godot CLI, git (already installed)

---

## Conclusion

First Frame Studios can become the **most efficient AI game studio** by investing 4 weeks into automation. These 25 tools would have prevented every M1+M2 integration failure and solved the #1 team feedback issue.

The philosophy: **tools should make mistakes impossible, not just detectable**.

Jango is ready to build this. Joaquín has removed the bandwidth limit. Let's ship a studio that runs like a machine.

> *"Automatizar es el primer paso. Escalar es el segundo."*
> — Jango

---

**Next Steps:**
1. ✅ Review this proposal with Joaquín
2. Create GitHub issues for Top 3 tools (Branch Validation, Godot Headless, Integration Gate)
3. Begin Phase 1 implementation (Week 1 sprint)
4. Gather team feedback after each phase
5. Iterate based on what works

**Questions for Joaquín:**
- Priority order: Should Jango focus on Phase 1-2 (integration + joy) first?
- Team involvement: Should other agents contribute tool code, or is this 100% Jango?
- Timeline: 4 weeks full-time, or spread across milestones?

---

*Proposal written by Jango, Tool Engineer at First Frame Studios.*  
*Unleashed by Joaquín. For the team. For the craft. For the games we'll build.*  
🔥🔧
