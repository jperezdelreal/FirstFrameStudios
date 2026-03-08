# Tools Evaluation — First Frame Studios
**Evaluator:** Jango (Tool Engineer)  
**Date:** 2025-07-22  
**Status:** Complete Analysis & Recommendations  
**Requested by:** joperezd (Founder)  

---

## Executive Summary

**The Bottom Line:** First Frame Studios should NOT build generic tools right now. We should build two mission-critical tools and adopt or defer everything else. Here's why:

1. **We're Pre-scale.** With one shipped game (firstPunch) and one game in production (Godot transition), we don't yet have enough institutional knowledge to know what's truly reusable vs. what's project-specific.

2. **Our real bottleneck isn't tools—it's team bandwidth.** Our 20% load-cap principle means every agent is already fully allocated. Building tools without trimming scope elsewhere forces crunch.

3. **Some tools multiply team capacity by 2-3x.** The two tools recommended (CI/CD + Reusable Module Library) directly enable parallel work and reduce rework. Everything else is optimization of already-functional workflows.

4. **Our advantages don't come from tools—they come from process.** The new-project playbook, skills system, decision matrix, and domain ownership model ARE our tools. Before we build code tools, we should ship one project with these processes to prove they work.

---

## 1. EVALUATE: The Tool Categories

### Category A: Game Feel Tuning Dashboard

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | During gameplay, designers want to tweak hitlag, screen shake, knockback force, timing windows without restarting. Currently: edit variables, restart, test, repeat. **Iteration cycle: 30-60 seconds per test.** |
| **Payoff** | High — Principle #1 (Player Hands First) is our core differentiator. Game feel is where we win. Faster iteration means faster learning. Estimated 2-3x speed improvement. |
| **Effort to Build** | Medium (1-2 days) — A floating debug panel with sliders for key values, connected to in-game systems via autoload. Requires input system hooks and some UI scaffolding. |
| **Godot Solution** | Godot has built-in `@export` hot-reload — change a value in the inspector, see it live in-game without restart. **Does the job for 80% of use cases.** Add a custom EditorPlugin dock for the remaining 20% (bulk parameter export/import, preset saving). |
| **Risk of NOT Building** | Medium — We'll be slower at feel iteration than we could be, but not blocked. |
| **Recommendation** | **BUY/ADOPT.** Use Godot's native `@export` hot-reload + EditorPlugin with a parameter preset system. Jango creates this as a small EditorPlugin (4-6 hours) for next project Sprint 0. This is a skill-building exercise, not a "fill urgent need" exercise. |

---

### Category B: Animation Preview Tool

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | Animators need to preview animations WITH hitboxes, hurtboxes, and collision shapes overlaid. Currently: Play scene, hope hitbox is correct, iterate. No visibility into spatial alignment at key frames. |
| **Payoff** | Medium — Saves 10-15% of animation iteration time. One-time setup cost, reusable across all projects. |
| **Effort to Build** | Medium (2-3 days) — EditorPlugin that displays hitbox/hurtbox overlays during `AnimationPlayer` playback. Requires hooking into AnimationPlayer's frame signals. |
| **Godot Solution** | Godot 4.2+ has built-in AnimationPlayer preview in the editor. Manually add Area2D shapes to preview the collision geometry. **Does the job for 95% of use cases.** |
| **Risk of NOT Building** | Low — Animation workflow is not our current bottleneck. |
| **Recommendation** | **SKIP (for now).** Only build this when we have an Animator role with high velocity and animation iteration is proven to be a bottleneck. For Godot projects with small teams, the inspector-based workflow is sufficient. |

---

### Category C: Level Editor / Encounter Designer

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | Current: Designers build levels in the scene editor manually, placing enemies and props one by one. Tedious, error-prone, hard to iterate on wave composition. |
| **Payoff** | High for content-heavy games (RPGs, roguelikes with 50+ levels). **Low for our current scope** (firstPunch has 5 waves, next project TBD). |
| **Effort to Build** | Large (XL) — A proper encounter designer requires: UI for spawning rules, wave composition, difficulty scaling, balance presets. This is 3-5 days of work. |
| **Godot Solution** | Godot's scene editor IS the level editor. For encounter design, a custom EditorPlugin with a dockable UI panel is viable (1-2 days). Not a full "Game Maker-style" level editor, but good enough. |
| **Risk of NOT Building** | Medium if the next project is content-heavy (50+ encounters). Low if it's a focused, short game like firstPunch. |
| **Recommendation** | **SKIP (for now).** Only build this if the next project is explicitly content-heavy AND is past Sprint 0 architecture. For game feel games (our current strength), level iteration happens in the editor. If next project needs this, raise it as a P1 Sprint 0 tooling task and Jango evaluates whether to build or recommend a third-party solution. |

---

### Category D: Audio Mixer / Preview Tool

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | Greedo (Sound Designer) needs to mix buses, preview audio with game state (hitlag, slow-mo), and balance SFX/music levels. Currently: Edit audio parameters in code/config, export, test in-game. |
| **Payoff** | High for Greedo's workflow — saves 20-30% of audio iteration time. Medium for team (audio is 1 person's work). |
| **Effort to Build** | Medium (1-2 days) — EditorPlugin with a dockable mixer UI, connected to Godot's AudioBusLayout system. |
| **Godot Solution** | Godot 4 has a built-in Audio Mixer in the editor. It's functional but not real-time during gameplay. For in-game audio testing, use `@export` variables on an AudioManager autoload. |
| **Third-party** | FMOD Studio (free indie tier, $200 if exceeded limits) or Wwise (free for indie < $200k revenue). Both are overkill for current scope. |
| **Risk of NOT Building** | Low to Medium — Audio is not a bottleneck yet. Greedo has firstPunch's Web Audio API experience; Godot's audio system is adequate. |
| **Recommendation** | **BUY/ADOPT if Greedo requests it; otherwise SKIP.** If Godot's built-in mixer proves too limited, evaluate FMOD/Wwise. But don't build custom audio tooling yet — the problem isn't big enough. If a future project has complex interactive audio (dynamic music, branching sequences), revisit this decision. |

---

### Category E: Balance Spreadsheet → Game Data Pipeline

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | Balance data (enemy HP, attack damage, loot tables, difficulty curves) lives in spreadsheets (JSON/CSV or Excel). Designer exports, developer imports into game. Manual, error-prone, versioning nightmare. |
| **Payoff** | High — Eliminates manual copying, prevents sync bugs, enables designers to iterate without code. **Principle #10 (Measure the Fun) requires data flow.** |
| **Effort to Build** | Small to Medium (1 day) — A Python/GDScript script that reads CSV/JSON, validates schema, exports to Godot resources. Single-direction pipeline initially (spreadsheet → `.tres` files). |
| **Godot Solution** | Create custom Resource types (e.g., `EnemyStats`, `WaveDefinition`) and define them in `.tres` files. Designers edit via inspector. Optionally: write a CSV importer script. **This is 80% of what a full pipeline does.** |
| **Existing Tools** | Gamesparks (spreadsheet import), Codecks (has data integration), or roll-your-own importer script. |
| **Risk of NOT Building** | Medium — Without this, balance iteration is slow. Designers can't iterate independently. |
| **Recommendation** | **BUILD (Small).** This is perfect for Jango's role: infrastructure that unblocks other agents. Create a simple CSV importer that reads a balance sheet (enemy_stats.csv) and generates `.tres` resources. Check this into the project repo. 1 day of work in Sprint 0. This is low-effort, high-leverage. **This IS a tool worth building because it directly enables concurrent work by Tarkin (Enemy Design).** |

---

### Category F: CI/CD for Game Builds

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | Exporting builds is manual: `File → Export → Select preset → Wait → Zip → Upload`. Error-prone (forgot to increment version?), not reproducible, no test runs. |
| **Payoff** | Very High — Automated builds mean every commit can generate a playable build. Enables rapid testing, cloud storage, historical versions. **Multiplies QA efficiency.** Ackbar can test the latest build without waiting for manual export. |
| **Effort to Build** | Medium to Large (1-2 days) — GitHub Actions workflow + Godot CI docker image. Not complex, but requires testing. |
| **Existing Solution** | GitHub Actions (free for public repos, generous free tier for private). Plug-and-play with Godot. |
| **Risk of NOT Building** | High — As team scales, manual builds become bottlenecks. No historical artifact storage means no quick rollback. |
| **Recommendation** | **BUILD.** This is a **P0 priority for next Godot project Sprint 0.** Chewie + Jango own this. GitHub Actions + barichello/godot-ci Docker image. 4-6 hours setup time. Payoff: Every commit exports Web + Windows builds. Ackbar gets playable artifacts for testing without waiting. This multiplies team throughput. **This is the single highest-ROI tool on this list.** |

---

### Category G: Asset Pipeline (Import, Optimize, Validate)

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | Artists create sprites/audio in external tools. Import into Godot. Godot auto-detects import settings (usually wrong). Manual tweaks required. Inconsistent compression, metadata, naming. |
| **Payoff** | Medium — Saves 5-10% of asset iteration time. High confidence in import quality. **Prevents "why does this sprite look worse after import?" moments.** |
| **Effort to Build** | Medium to Large (2-3 days) — Custom Godot import scripts + validation EditorPlugin. Requires understanding of Godot's Resource system. |
| **Godot Solution** | Godot has import presets per file type. Set once, apply to all assets. **Covers 70% of use cases.** For advanced features (sprite sheet detection, auto-slicing), requires scripting. |
| **Third-party** | Aseprite (sprite art), Blender (3D assets) — these do what they do well. Godot's importers are solid. |
| **Risk of NOT Building** | Low to Medium — Only a bottleneck if art velocity is very high and import settings are frequently wrong. |
| **Recommendation** | **SKIP (for now).** Set up import presets in Sprint 0 (1 hour). If Boba reports that asset reimporting is a bottleneck, Jango builds a validation EditorPlugin (2 days). For first project, the built-in importers are adequate. |

---

### Category H: Playtest Recording (Capture Input + Replay)

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | During playtests, testers encounter bugs but can't reliably reproduce them. Would be valuable to record inputs + game state and replay. |
| **Payoff** | High for QA efficiency — **Ackbar could record, then review bug replays in isolation.** Saves time chasing "I can't reproduce it." Enables slow-mo analysis of timing bugs. |
| **Effort to Build** | Large (2-3 days) — Requires hooking into input system, saving state snapshots, replay playback. Non-trivial. |
| **Godot Solution** | Godot's GDScript can record `Input` events, but state snapshot/replay is custom work. Possible but not a first-weekend project. |
| **Risk of NOT Building** | Medium — QA cycle is slower without this. But firstPunch shipped without it. |
| **Recommendation** | **SKIP (for now).** Only build if Ackbar identifies that bug reproduction is a consistent bottleneck in Phase 2+. For Sprint 0 and early production, manual testing and "try to reproduce" is acceptable. Revisit if playtest feedback velocity slows. |

---

### Category I: Bug Reporting Tool (Screenshot + Game State Capture)

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | QA submits bugs with no context. Developers can't replicate. Example: "The enemy got stuck." Where? What level? What state machine? |
| **Payoff** | High for issue triage — Context dramatically speeds up bug fix. Reduces "can't reproduce" conversations. |
| **Effort to Build** | Medium (1-2 days) — EditorPlugin + in-game UI with screenshot capture + JSON dump of game state (player position, enemy states, etc.). |
| **Godot Solution** | Use Godot's `Image.save_png()` for screenshots. Manually structure a bug report JSON. Not a polished tool, but functional. |
| **Third-party** | Some game engines have built-in screenshot tools. Godot doesn't. |
| **Risk of NOT Building** | Medium — Slows bug triage. But not a ship-blocker. |
| **Recommendation** | **SKIP (for now).** For Sprint 0, require QA to provide: (1) what they were doing, (2) what happened, (3) what should have happened, (4) screenshot if possible. This is adequate. Only build a structured bug capture tool if QA reports that context-gathering is a bottleneck in Phase 2+. |

---

### Category J: Code Generators / Scaffolding

**BUILD vs BUY vs SKIP Analysis:**

| Criterion | Assessment |
|-----------|-----------|
| **Problem Statement** | When Tarkin creates a new enemy, he copies an existing enemy template and modifies it. Tedious. Would be faster to run a generator: `jango generate-enemy EnemyGrunt`. |
| **Payoff** | Medium — Saves 5-10 minutes per new enemy. High velocity = higher payoff. But templates also solve 90% of the problem. |
| **Effort to Build** | Small to Medium (4-8 hours) — A Godot EditorScript that prompts for enemy name, AI type, attack pattern, then generates a `.tscn` + `.gd` inheriting from templates. |
| **Godot Solution** | Scene templates (the feature, not our project templates) + inheritance. Copy → Modify. **This is 95% as good as a generator.** |
| **Risk of NOT Building** | Very Low — Bottleneck only if content creation velocity is very high. Not a concern for our current scope. |
| **Recommendation** | **SKIP (for now).** Scene templates + inheritance are sufficient for first two projects. If Tarkin reports that "copy enemy, rename, modify" is a bottleneck, Jango builds a generator (1 day of work). Not a priority. |

---

## 2. BUILD vs BUY vs SKIP SUMMARY

### By Category:

| Tool | Category | Recommendation | When | Owner |
|------|----------|-----------------|------|-------|
| Game Feel Tuning Dashboard | Optimization | BUY (EditorPlugin) | Sprint 0, Next Project | Jango (4-6h) |
| Animation Preview Tool | Optimization | SKIP | Phase 2+ (if animation velocity high) | — |
| Level Editor / Encounter Designer | Content | SKIP | Phase 2+ (if content-heavy) | — |
| Audio Mixer / Preview | Optimization | BUY (if Greedo requests) | On-demand | Jango or Greedo |
| Balance Spreadsheet Pipeline | **Critical** | **BUILD** | Sprint 0, Next Project | Jango (1 day) |
| CI/CD for Game Builds | **Critical** | **BUILD** | Sprint 0, Next Project | Chewie + Jango (4-6h) |
| Asset Pipeline | Optimization | SKIP | Phase 2+ (if art bottleneck) | — |
| Playtest Recording | QA Enhancement | SKIP | Phase 2+ (if QA bottleneck) | — |
| Bug Reporting Tool | QA Enhancement | SKIP | Phase 2+ (if triage bottleneck) | — |
| Code Generators | Workflow | SKIP | Phase 3+ (if content velocity high) | — |

---

## 3. BUILD vs BUY ANALYSIS: The Two Critical Tools

### Tool #1: CI/CD for Game Builds (GitHub Actions)

**What:** Automated builds on every push. Generate Web + Windows executables. Upload to artifact storage (GitHub Releases / itch.io).

**Why Build:**
- Enables QA testing without manual export steps
- Creates reproducible, versioned builds
- Multiplies team throughput (QA doesn't wait, parallel testing possible)
- Prevents human error (wrong export preset, version number bugs)

**Effort:** 4-6 hours (Chewie for Godot expertise, Jango for tooling integration)

**Integration Points:**
- GitHub Actions workflow (checked into `.github/workflows/`)
- Godot project configured for headless export
- Artifacts uploaded to GitHub Releases or itch.io
- Slack notification on build success/failure

**Success Metric:** Every commit on `main` auto-generates a playable build within 5 minutes. Ackbar can test the latest without waiting for manual export.

**Sample Workflow:**
```yaml
name: Build Godot Project
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.3
    steps:
      - uses: actions/checkout@v4
      - name: Import assets
        run: godot --headless --import
      - name: Export Web
        run: godot --headless --export-release "Web" build/web/index.html
      - name: Export Windows
        run: godot --headless --export-release "Windows Desktop" build/windows/game.exe
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: builds
          path: build/
```

---

### Tool #2: Balance Spreadsheet → Game Data Pipeline

**What:** CSV importer that reads balance data (enemy HP, attack damage, loot tables, difficulty curves) and generates Godot `.tres` resource files.

**Why Build:**
- Unblocks designers from code (they can iterate independently)
- Prevents sync bugs (one source of truth)
- Enables rapid balance iteration (edit spreadsheet, export, test)
- Scales to future projects

**Effort:** 1 day (Jango)

**Integration Points:**
- CSV file (e.g., `data/balance/enemies.csv`)
- Python or GDScript importer script
- Output: `resources/enemies/grunt_stats.tres`, `resources/enemies/boss_stats.tres`, etc.
- Version controlled in repo

**Example Spreadsheet Format:**
```
name,health,attack_damage,attack_cooldown,detection_range,speed
Grunt,100,10,1.5,300,150
ShotgunGrunt,80,15,2.0,250,120
Boss,300,20,1.0,400,100
```

**Example Output Resource:**
```gdscript
# resources/enemies/grunt_stats.tres
[gd_resource type="Resource" script_class="EnemyStats"]
resource_name = "GruntStats"
display_name = "Grunt"
max_health = 100
attack_damage = 10
attack_cooldown = 1.5
detection_range = 300
speed = 150
```

**Sample Importer Script:**
```python
#!/usr/bin/env python3
import csv
import json

def import_balance_data(csv_path, output_dir):
    with open(csv_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['name'].lower()
            # Generate .tres file
            tres_content = f'''[gd_resource type="Resource" script_class="EnemyStats"]
resource_name = "{name}_stats"
display_name = "{row['name']}"
max_health = {int(row['health'])}
attack_damage = {int(row['attack_damage'])}
attack_cooldown = {float(row['attack_cooldown'])}
detection_range = {float(row['detection_range'])}
speed = {float(row['speed'])}
'''
            with open(f"{output_dir}/{name}_stats.tres", "w") as out:
                out.write(tres_content)

if __name__ == "__main__":
    import_balance_data("data/balance/enemies.csv", "resources/enemies")
```

**Integration with Game:**
```gdscript
# scripts/data/enemy_stats.gd
class_name EnemyStats
extends Resource

@export var display_name: String = ""
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.5
@export var detection_range: float = 300.0
@export var speed: float = 150.0
```

```gdscript
# scenes/enemies/EnemyGrunt.gd
class_name EnemyGrunt
extends EnemyBase

@export var stats_resource: EnemyStats = preload("res://resources/enemies/grunt_stats.tres")

func _ready() -> void:
    max_health = stats_resource.max_health
    speed = stats_resource.speed
    # ... etc
```

**Success Metric:** Tarkin can edit `data/balance/enemies.csv`, run `./scripts/import_balance.py`, and new `.tres` files are generated. Game picks up changes automatically on reload.

---

## 4. TOOL ARCHITECTURE PRINCIPLES

If we build tools, they should follow these principles:

### Principle A: Godot-Specific, Not Engine-Agnostic

**Decision:** Tools should be Godot 4 first, not generic.

**Why:**
- We're committed to Godot for next 2-3 projects (per playbook)
- Generic tools require 2-3x more infrastructure
- Godot-specific tools are tighter, faster to build
- If we ever switch engines again, re-implement is cheaper than maintaining generic tools

**Example:** The balance spreadsheet importer generates `.tres` files, not JSON/XML. Godot-specific. On Phaser 3, we'd write a different importer for its asset format. That's OK.

---

### Principle B: Editor Plugins > Standalone Tools

**Decision:** When possible, build EditorPlugins, not standalone executables.

**Why:**
- EditorPlugins live in the project (`addons/squad_tools/`)
- No external dependency to install
- Agents see tools in their daily workflow (editor dock panels)
- Easier to version control and share across projects
- Tighter integration with project state

**Example:** Game feel tuning → EditorPlugin with dock panel. NOT a separate app.

**Exception:** CI/CD tools live outside the editor (GitHub Actions, build scripts). This is acceptable because they're infrastructure, not workflow tools.

---

### Principle C: Modular, Not Monolithic

**Decision:** Tools should be single-purpose. One tool = one job.

**Why:**
- Single-purpose tools are easier to test, debug, and extend
- Clear ownership (Jango owns EditorPlugins, Chewie owns build infrastructure)
- Easier to adopt/adapt for future projects

**Anti-pattern:** A "Master Debug Panel" that does game feel tuning, balance visualization, and bug capture all in one. Too much scope, too hard to maintain.

---

### Principle D: Integrated (Editor Plugins) vs. Standalone (Scripts) Trade-off

**For EditorPlugins:**
- **Integrated** = live in `addons/squad_tools/`, auto-load when editor starts
- **Owned by:** Jango, shared across all agents
- **Update workflow:** Git pull latest, editor auto-reloads plugin
- **Example:** Game feel tuning dashboard, balance validator

**For Standalone Scripts/Tools:**
- **Standalone** = live in `scripts/tools/` or `../tools/` outside project
- **Owned by:** Whoever needs them (Chewie for build, Jango for import)
- **Update workflow:** Update script, re-run
- **Example:** Balance importer, CI/CD workflow

---

### Principle E: Versioning & Reuse Across Projects

**Decision:** Tools should be designed for reuse.

**How:**
1. **EditorPlugins:** Live in the project repo under `addons/squad_tools/`. When starting a new project, copy the entire `addons/squad_tools/` folder from the previous project.

2. **Scripts/Tools:** Live in a separate `studio-tools` repo (or as Git submodules). When starting a new project, `git submodule add` the tools repo into `tools/`.

3. **Documentation:** Every tool has a README in its directory explaining:
   - What it does
   - How to use it
   - Known limitations
   - Who to contact if bugs

**Example Directory Structure:**
```
firstPunch/
├── addons/squad_tools/      # EditorPlugins (copied to next project)
│   ├── game_feel_tuner/
│   ├── balance_validator/
│   └── README.md
├── scripts/tools/           # Standalone scripts
│   ├── balance_importer.py
│   └── README.md

[Next Project]
├── addons/squad_tools/      # Copy from firstPunch
└── scripts/tools/           # Git submodule or copy
```

---

## 5. PRIORITY ROADMAP

### Sprint 0 (Next Godot Project)

**P0 (Must Have):**
1. **CI/CD Setup** — GitHub Actions + automated Web/Windows builds (Chewie + Jango, 4-6h)
   - Multiplies QA efficiency
   - Enables rapid iteration
   - Unblocks parallel work

2. **Balance Spreadsheet Pipeline** — CSV importer (Jango, 1 day)
   - Unblocks Tarkin
   - Enables concurrent balance iteration
   - Scales to future projects

**P1 (Should Have):**
3. **Game Feel Tuning EditorPlugin** — Parameter override dock (Jango, 4-6h)
   - Optional; `@export` hot-reload is 80% as good
   - But nice-to-have for efficiency
   - Good skill-building for Jango

4. **GDScript Linting + Scene Validation** — Pre-commit checks (Jango, 2-3h)
   - Catch errors before they compound
   - Set quality standard
   - Automated enforcement of conventions

---

### Phase 1 (Production Ramp)

**P2 (Can Defer to Phase 2):**
5. **Audio Mixer EditorPlugin** — IF Greedo reports bottleneck (Jango, 1-2 days)
   - Conditional: only if audio iteration is slow
   - Otherwise, use built-in Godot mixer

---

### Phase 2+ (Content & Polish)

**P3 (Conditional, Build Only If Bottleneck Appears):**
6. **Animation Preview Tool** — IF animation iteration slows (Jango, 2-3 days)
7. **Encounter Designer** — IF level editing becomes bottleneck (Jango, 3-5 days)
8. **Playtest Recording** — IF bug reproduction becomes bottleneck (Jango, 2-3 days)
9. **Bug Reporting Tool** — IF issue triage becomes bottleneck (Jango, 1-2 days)
10. **Code Generators** — IF enemy/content creation velocity is very high (Jango, 1 day)

---

### ROI Ranking (Impact / Effort)

| Rank | Tool | Impact | Effort | ROI |
|------|------|--------|--------|-----|
| 1 | CI/CD Builds | 10/10 | 4-6h | **Highest** |
| 2 | Balance Pipeline | 9/10 | 1 day | **Very High** |
| 3 | Game Feel Tuning | 8/10 | 4-6h | **High** |
| 4 | Linting + Validation | 8/10 | 2-3h | **High** |
| 5 | Audio Mixer | 7/10 (conditional) | 1-2 days | **Medium** |
| 6-10 | Everything else | 5-7/10 | 1-5 days | **Low-Medium** |

---

## 6. HONEST ASSESSMENT: Should We Build Tools At All?

### The Case For NOT Building Tools Right Now

**The bottleneck isn't tools. It's team bandwidth.**

Evidence:
- firstPunch shipped without any custom tools (used Godot's built-in features + minimal infrastructure)
- Our 20% load cap means every agent is fully allocated
- The things that hurt our velocity most aren't missing tools — they're architectural decisions made in first 30 minutes (unwired infrastructure, god-scene, missing conventions)

**Our real advantages are:**
1. **Clear domain ownership** (Principle #7) — everyone knows who decides what
2. **Shared principles** (12 documented principles) — team alignment without micromanagement
3. **Reusable knowledge** (skills system, playbook, decisions log) — new projects don't start from zero
4. **Iterative development** (weekly playtests, retrospectives) — we catch problems early

These aren't tools. They're processes. And they're worth more than any code tool.

### The Case For Building Tools (Selective)

**But:** Some tools DO multiply team capacity.

1. **CI/CD Builds** — Enables async QA testing (Ackbar doesn't wait for manual export). **2x feedback loop speed.**
2. **Balance Pipeline** — Unblocks designers from code. **Tarkin works in parallel, not serialized after code changes.** 2-3x design iteration speed.

These tools aren't nice-to-have. They're structural multipliers.

### Recommendation

**Build only the two critical tools. Defer everything else.**

If in Phase 2 we discover:
- "Animation iteration is slow" → Build animation preview tool
- "Level design is bottlenecked" → Build encounter designer
- "QA can't reproduce bugs" → Build bug capture tool

But don't speculate. Build what hurts.

---

## 7. ANTI-PATTERNS: What NOT to Do

### ❌ Anti-Pattern 1: "Build Reusable Tools Before Shipping One Game"

**Why it fails:**
- You don't know what's reusable until you've shipped twice
- "Reusable" tools often become project-specific (tool assumes a design pattern that changes per game)
- Wastes bandwidth that should go to shipping

**What we do instead:**
- Ship firstPunch
- Ship next Godot game
- After game #2, examine what code was truly reused → extract it and formalize as tools

---

### ❌ Anti-Pattern 2: "Build a Generic Tool That Works For All Projects"

**Why it fails:**
- Web games (Phaser) have different asset pipelines than Godot games
- Top-down games need different balance tools than first-person games
- A "one-size-fits-all" tool becomes bloated and unmaintainable

**What we do instead:**
- Build Godot-specific tools
- Document the pattern
- If we migrate to a different engine, re-implement the tool for that engine
- Accept that tool diversity is fine (it's the pattern that transfers, not the code)

---

### ❌ Anti-Pattern 3: "Require Tools to Be Fully Baked Before First Use"

**Why it fails:**
- Tools improve with use
- Agents discover edge cases the tool needs to handle
- Too-polished tools become over-engineered

**What we do instead:**
- Ship the tool at MVP (minimum viable product)
- Collect feedback from agents using it
- Iterate on the tool in parallel with game development
- Document known limitations upfront

---

### ❌ Anti-Pattern 4: "Separate Tool Ownership From Usage"

**Why it fails:**
- Jango builds a tool that Greedo uses but doesn't understand
- Greedo finds a bug but doesn't report it (assumes it's his fault)
- Tool sits unmaintained because owner is unaware of problems

**What we do instead:**
- Tool owner works with end users during development (user-centered design)
- End user can run the tool, understand it, modify it if needed
- Regular feedback loops (weekly check-ins: "Is the tool helping?")

---

## 8. IMPLEMENTATION ROADMAP

### For Sprint 0 (Next Godot Project)

**Week 1:**
- [ ] Chewie + Jango: Set up GitHub Actions workflow (4-6h)
- [ ] Jango: Create balance spreadsheet importer (1 day)
- [ ] Jango: Create GDScript linting config (2h)

**Week 2:**
- [ ] Jango: Build basic game feel tuning EditorPlugin (4-6h)
- [ ] Jango: Build scene validation EditorPlugin (2-3h)

**Deliverables:**
- `addons/squad_tools/` with game_feel_tuner and scene_validator plugins
- `.github/workflows/godot-build.yml` for CI/CD
- `scripts/tools/balance_importer.py`
- `data/balance/` with example spreadsheet

**Time Investment:** ~2-3 days of Jango's Sprint 0 (well within his allocation)

---

### For Phase 1 & Beyond

**Conditional on bottleneck reports:**
- Jango monitors: Is animation slow? Is encounter design manual drudgery? Is QA blocked on bug reproduction?
- If any bottleneck appears, raise it in sprint retro
- If consensus agrees, Jango builds the tool
- Time-box: 1-2 days max (or defer to next phase)

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
| **Encounter Designer** | SKIP | No | — | 3-5 days | 7/10 | Only if content-heavy game |
| **Playtest Recording** | SKIP | No | — | 2-3 days | 8/10 | Only if bug reproduction blocked |
| **Bug Reporting** | SKIP | No | — | 1-2 days | 7/10 | Only if triage bottleneck |
| **Code Generators** | SKIP | No | — | 1 day | 5/10 | Only if content velocity very high |

---

## 10. CLOSING: The Honest Answer

**Should First Frame Studios build reusable tools?**

**Answer: Yes, but later. And selectively.**

**Now (Sprint 0):**
- Build two mission-critical tools: **CI/CD** and **Balance Pipeline**
- These unblock team capacity and enable parallelism
- Everything else is optimization (nice-to-have, not blocking)

**After Game #1 Ships:**
- Extract reusable modules (audio system, input manager, UI framework) into a studio library
- Document patterns and APIs
- These become the "tools" for Game #2 (pre-built systems, not editor toys)

**After Game #2 Ships:**
- Look at what tools would have saved the most time
- Now you know what's truly reusable
- Build those tools for Game #3

**The Risk of NOT Building Tools:**
- QA testing slows (manual builds)
- Design iteration slows (no balance pipeline)
- But: **game ships anyway** (just slower)

**The Risk of Building Too Many Tools:**
- Distraction from making games (the core work)
- Tools become unmaintained (too many to keep up with)
- False confidence that tools solve the bottleneck (they don't — design and execution do)

**First Frame Studios' strength is not tools. It's clarity, process, and shared principles.** Use tools to amplify those strengths, not replace them.

---

## APPENDIX: Tool Roadmap Checklist

### Sprint 0 Checklist

- [ ] GitHub Actions workflow created and tested
- [ ] Godot project exports successfully on every commit
- [ ] Artifacts uploaded to GitHub Releases
- [ ] Balance spreadsheet importer created and documented
- [ ] Example balance CSV created
- [ ] Import script runs without errors
- [ ] Generated `.tres` files load into game correctly
- [ ] GDScript linting configured (`.gdlintrc`)
- [ ] Scene validation EditorPlugin created (basic checks: unique names, signal connections)
- [ ] Game feel tuning EditorPlugin created (parameter override dock)
- [ ] All tools documented with README files
- [ ] All tools version-controlled in project repo

### Phase 1 Checklist (As Needed)

- [ ] Monitor Greedo's audio workflow — if slow, evaluate audio mixer tool
- [ ] Monitor Boba's art import workflow — if slow, evaluate asset pipeline tool
- [ ] Monitor Tarkin's enemy creation — if slow, evaluate code generator
- [ ] Collect feedback on existing tools every sprint retro

### Post-Ship Checklist (After Game #1)

- [ ] Extract reusable modules into studio library
- [ ] Document module APIs and integration patterns
- [ ] Create `studio-library/` repo (separate from game projects)
- [ ] Plan how Game #2 will import and use library modules

---

**Document prepared by:** Jango, Tool Engineer  
**Status:** Ready for Founder Review  
**Next Step:** Discuss priorities with Solo + Chewie before Sprint 0 begins.

