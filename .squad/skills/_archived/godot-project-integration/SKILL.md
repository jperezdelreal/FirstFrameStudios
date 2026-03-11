# Godot 4 Project Integration

## Metadata
- **Confidence:** high
- **Domain:** Godot, Game Architecture, Multi-Agent Development
- **Last validated:** 2026-03-08
- **Source:** Ashfall M1+M2 retrospective + Solo integration audit + Jango code review (both confirm patterns)

## Pattern

Godot projects have structural requirements that become dangerous when multiple agents modify them in parallel. The following patterns protect project stability during multi-agent development.

### 1. Autoload Ordering Is a Dependency Chain

Autoloads in `project.godot` [autoloads] section initialize in the order they appear. Systems that depend on other autoloads must load after their dependencies.

**Correct order (from M1+M2):**
```ini
[autoloads]
EventBus="*res://src/systems/event_bus.gd"     # First — no dependencies
GameState="*res://src/systems/game_state.gd"   # Second — depends on EventBus
RoundManager="*res://src/systems/round_manager.gd" # Third — depends on GameState, manages round lifecycle
VFXManager="*res://src/systems/vfx_manager.gd" # Fourth — depends on EventBus + GameState
AudioManager="*res://src/systems/audio_manager.gd" # Fifth — depends on EventBus
SceneManager="*res://src/systems/scene_manager.gd" # Sixth — depends on EventBus + GameState
```

**Critical pattern (validated by Jango code review):** Systems that manage game flow (RoundManager, SceneManager) MUST be registered as autoloads, not instantiated per-scene. Otherwise:
- Game state doesn't persist across scene reloads
- Round transitions can't be queried from other systems
- Victory/defeat logic can't access round state

**Validated lifecycle issue (Jango review, issue #1):** If RoundManager is built but never instantiated (not in autoloads AND not added as child to FightScene), the entire round system is non-functional. The code exists but never runs.

**Rule:** EventBus loads first. Any system that connects signals must load after EventBus is ready. Any system that manages game state or flow (RoundManager) must load early as an autoload, and must be instantiated AND started (e.g., `round_manager.start_match(fighter1, fighter2)`).

**Anti-pattern:** Two agents both adding autoloads in parallel branches causes merge conflicts in the exact same lines of the [autoloads] section.

**Mitigation:**
- Only ONE agent per wave modifies `project.godot`
- If multiple autoloads are needed in the same wave, designate one agent to add them all
- After the first PR with autoload changes merges, remaining branches MUST rebase before merge
- Alternative: Use a shared integration branch where one agent stages all autoload additions, others rebase onto it

### 2. project.godot Is the #1 Merge Conflict Hotspot

`project.godot` is a single INI file shared by the entire project. Multiple agents adding entries to [autoloads], [debug], [input_map], or [rendering] in parallel branches creates 100% merge conflicts.

**Evidence:** During M1+M2, agents Chewie, Lando, Wedge, and Greedo all branched from the same base commit and added autoloads. Merging sequentially required rebasing each branch after each merge.

**Rule:** Designate exactly ONE agent per wave to modify `project.godot`. All other agents must work around it (e.g., create scene-specific input handling instead of global project.godot entries).

**When adding to project.godot:**
- Create a detailed PR description explaining every change
- Include the diff showing line-by-line additions
- Test locally that the project still opens in Godot without errors
- After merge, all remaining branches rebase from updated main before merging

### 3. Scene References Must Match Scripts + NEW: Signal Wiring Verification

Godot scenes (.tscn files) hold references to scripts and nodes using relative file paths. If a script is renamed, moved, or deleted, the scene silently loads with a broken reference (red icon in editor, null reference at runtime).

**Validated signal wiring issue (Jango review + Solo audit):** EventBus can define a signal (e.g., `signal fighter_knocked_out`), and a system like RoundManager can listen for it (via `EventBus.fighter_knocked_out.connect(...)`), but if no OTHER system actually **emits** the signal, the connection is orphaned. The code compiles and runs, but the signal never fires.

**Critical new pattern:** After parallel work, verify every `EventBus.emit_signal()` call has at least one corresponding `.connect()` in another system.

**Verification checklist for signal wiring:**
1. Search for all `emit_signal()` calls in combat systems: `grep -r "emit_signal" src/`
2. For each emission like `EventBus.emit_signal("fighter_knocked_out", fighter)`:
   - Search for all corresponding `.connect()` calls: `grep -r "\.connect" src/`
   - Verify at least one other system connects to this signal
   - Trace the callback to confirm it does meaningful work (not just `push_print` for debugging)
3. Verify the emitting system runs before the connected system (dependency order)
4. Example validation from Jango review:
   - Fighter emits `knocked_out` ✅
   - FightScene forwards to EventBus via `EventBus.emit_signal` ✅
   - RoundManager listens to EventBus signal ✅
   - RoundManager transitions round state ✅
   - Audio plays via EventBus signal ✅

**Rule:** Signals are NOT optional side effects. Every signal wired into EventBus must have at least one consumer in another system. Otherwise, the signal is dead code.

**Rule:** Before merging a PR that adds signals, verify:
1. The signal is declared in EventBus
2. It is emitted exactly where it should be (e.g., on fighter KO, not on every frame)
3. It is connected and consumed in at least one dependent system
4. Do NOT merge signals without consumers; they're debt

**Prevention:**
- Use %UniqueName pattern for UI nodes — they're referenced by name instead of path
- Avoid renaming scripts. If you must, refactor the scenes that depend on them in the same PR
- After creating a new scene, open it in Godot and verify no red "missing script" indicators appear
- After adding a signal, run `git diff` and search the codebase for `.connect()` calls to that signal

### 4. Collision Layers: Reality vs Documentation

Godot's collision layer/mask system is silent. Layers are just bit flags; there's no name mapping by default. Incorrect layer assignment causes physics to silently fail (no collisions, or wrong collisions).

**Critical validation from Solo audit + Jango review:**
- Actual implementation uses **4 shared layers** (Fighters, Hitboxes, Hurtboxes, Stage)
- Documentation may specify a different scheme (e.g., 6 per-player layers)
- Scene files may use incorrect default layers (layer 1) instead of intended layer
- **Mismatch found in Ashfall M2:** `ARCHITECTURE.md` documented 6-layer scheme; actual code uses 4-layer scheme from `project.godot`

**Rule 1: Document the ACTUAL collision scheme used in `project.godot`, not aspirational schemes.**

```ini
# project.godot [2d_physics] section (source of truth)
2d_physics/layer_1="Fighters"        # All fighters (shared layer)
2d_physics/layer_2="Hitboxes"        # Attack boxes
2d_physics/layer_3="Hurtboxes"       # Can-be-hit bodies
2d_physics/layer_4="Stage"           # Walls, floor, environment
```

**Rule 2: Every collision-capable node must explicitly set both layer AND mask in scene files.**

**Required pattern (verify in `.tscn` files with XPath or visual inspection):**
- Fighter CharacterBody2D: `collision_layer = 1` (Fighters), `collision_mask = 1 | 4` (Fighters + Stage)
- Hitbox Area2D: `collision_layer = 2` (Hitboxes), `collision_mask = 4` (detects Hurtboxes)
- Hurtbox Area2D: `collision_layer = 4` (Hurtboxes), `collision_mask = 2` (detects Hitboxes)
- Stage StaticBody2D: `collision_layer = 8` (Stage), `collision_mask = 0` (stage doesn't need to collide with itself)

**Anti-pattern:** Relying on default collision layers (1, 1) — even if it works accidentally, it violates the documented scheme and breaks when scene structure changes.

**Verification:** 
1. Open the scene in Godot
2. Select each physics node (CharacterBody2D, Area2D, StaticBody2D)
3. In Inspector, check that `collision_layer` and `collision_mask` match the documented scheme
4. Look for any node with layer=1 that should be on a different layer

### 5. Input Map Must Include All GDD-Specified Inputs

The Game Design Document specifies player inputs (buttons, keys, analog). Every input must have a corresponding entry in `project.godot` [input_map] section.

**From Ashfall GDD → Implementation Gap (M1+M2):**
- GDD specifies: 6-button layout (LP, MP, HP, LK, MK, HK)
- `project.godot` [input_map] only defined: 4 buttons per player (LP, HP, LK, HK)
- **Silent spec deviation:** Medium punch and medium kick inputs don't exist
- Result: Movesets only define 4 normals instead of 6

**Rule:** Before merging any PR that implements a combat system, verify that `project.godot` [input_map] includes every button specified in the GDD.

**Verification checklist:**
1. Read the GDD section on player inputs
2. Count distinct inputs required
3. Search `project.godot` for `[input_map]` and verify each input exists
4. Check that input variable names match what the controller code expects
5. Add missing inputs to `project.godot` and MoveData resource files

### 6. Use %UniqueName Pattern for UI Node References

Godot's `%UniqueName` pattern allows nodes to be referenced by internal name instead of tree path. This makes scenes more resilient to structural changes.

**From fight_hud.tscn (M1+M2):**
```gdscript
@onready var health_p1 = %HealthBar_P1  # Finds node with unique_name_in_owner = HealthBar_P1
@onready var timer = %RoundTimer
@onready var combo_counter = %ComboCounter
```

Instead of:
```gdscript
@onready var health_p1 = $VBoxContainer/HealthBar_P1  # Path-based, breaks if structure changes
```

**Rule:** For any new UI scene, mark important nodes with `%UniqueName` in the editor, then reference them by name in the script. Reduces scene restructuring breakage.

**How to set it:**
1. Select the node in the scene tree
2. In the Inspector, find "Unique Name in Owner" checkbox
3. Enable it
4. The node appears with a `%` prefix in the tree view
5. In scripts, use `@onready var foo = %NodeName`

### 7. Always Test That the Project Opens in Godot Before Merging

**Critical:** No PR with changes to autoloads, project.godot, or scene files should merge without verification that the project opens in Godot 4.6 without errors.

**From M1+M2 retrospective + confirmed by Solo audit + Jango review:**
- 8 systems were built in parallel and merged without integration testing
- Nobody opened the project in Godot to verify it loads
- Autoload order dependency, scene reference breakage, and input map gaps were invisible until someone ran the editor
- RoundManager was built but never instantiated, making the round system non-functional until discovered post-merge

**Verification workflow:**
1. Check out the feature branch locally
2. Open Godot 4.6 and load the project
3. Check the Output console for errors
4. Verify all autoloads initialize (look for initialization logs or breakpoints)
5. Open the main gameplay scene and verify:
   - All game-critical nodes load without red icons
   - All state machines initialize with a valid current_state
   - No null reference warnings in the Output
6. **Critical new check:** Verify that integration systems (RoundManager, GameState, EventBus) are actually instantiated and wired:
   - If RoundManager is a child node in the scene, open it and confirm it exists as a scene node
   - If it's an autoload, verify it's in project.godot [autoloads] section
   - Run a test match and confirm round transitions happen (INTRO → READY → FIGHT → KO)
7. Only then approve and merge the PR

**Time investment:** 5–8 minutes per PR. Saves hours of debugging integration issues and prevents shipping non-functional systems post-merge.

## When to Apply

- Any time agents create parallel feature branches with autoload changes
- Any time project.godot is modified (input map, autoloads, physics config, rendering settings)
- Any time scripts are renamed or scene files are modified
- Before merging any PR that affects gameplay systems (input, physics, rendering)
- Before marking a milestone complete (do a full integration pass)

## Key Takeaway

**Godot projects are fragile under concurrent modification.** Enforce single-agent writes to `project.godot`, verify autoload order, validate scenes in the editor, and test integration before merging. The 10 minutes spent verifying a build prevents hours of post-merge debugging.
