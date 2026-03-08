# Godot 4 Project Integration

## Metadata
- **Confidence:** medium
- **Domain:** Godot, Game Architecture, Multi-Agent Development
- **Last validated:** 2026-03-08
- **Source:** Ashfall M1+M2 retrospective

## Pattern

Godot projects have structural requirements that become dangerous when multiple agents modify them in parallel. The following patterns protect project stability during multi-agent development.

### 1. Autoload Ordering Is a Dependency Chain

Autoloads in `project.godot` [autoloads] section initialize in the order they appear. Systems that depend on other autoloads must load after their dependencies.

**Correct order (from M1+M2):**
```ini
[autoloads]
EventBus="*res://src/systems/event_bus.gd"     # First — no dependencies
GameState="*res://src/systems/game_state.gd"   # Second — depends on EventBus
VFXManager="*res://src/systems/vfx_manager.gd" # Third — depends on EventBus + GameState
AudioManager="*res://src/systems/audio_manager.gd" # Fourth — depends on EventBus
RoundManager="*res://src/systems/round_manager.gd" # Fifth — depends on GameState
```

**Rule:** EventBus loads first. Any system that connects signals must load after EventBus is ready. Verify the order before merging any PR that adds an autoload.

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

### 3. Scene References Must Match Scripts

Godot scenes (.tscn files) hold references to scripts and nodes using relative file paths. If a script is renamed, moved, or deleted, the scene silently loads with a broken reference (red icon in editor, null reference at runtime).

**Rule:** After creating or renaming scripts, verify all scenes that reference them still load correctly.

**Example (from M1+M2):**
- `fight_scene.tscn` references `FighterController.gd` at line 80: `script = SubResource( "GDScript_abcd1234" )`
- If `FighterController.gd` is moved or renamed without updating the scene, the script link breaks
- Scene loads, but controller is null → fighter doesn't respond to input

**Prevention:**
- Use %UniqueName pattern for UI nodes — they're referenced by name instead of path
- Avoid renaming scripts. If you must, refactor the scenes that depend on them in the same PR
- After creating a new scene, open it in Godot and verify no red "missing script" indicators appear

### 4. Collision Layers Are Documentation + Discipline

Godot's collision layer/mask system is silent. Layers are just bit flags; there's no name mapping by default. Incorrect layer assignment causes physics to silently fail (no collisions, or wrong collisions).

**From Ashfall architecture:**
```
Layer 1: Player 1 (fighters)
Layer 2: Player 2 (fighters)
Layer 3: Hitboxes (attack boxes)
Layer 4: Hurtboxes (can be hit)
Layer 5: Pushboxes (stage collision)
Layer 6: Environment (walls, floor)
```

**Rule:** Document collision layer assignments in ARCHITECTURE.md and verify them before merging any physics-related PR.

**Discipline:**
- Fighter1 CharacterBody2D: Layer 1 only
- Fighter2 CharacterBody2D: Layer 2 only
- All Hitbox Area2Ds: Layer 3
- All Hurtbox Area2Ds: Layer 4
- Hitboxes detect Hurtboxes: Layer 3 mask detects Layer 4
- Hurtboxes are hit by Hitboxes: Layer 4 mask detects Layer 3

**Verification:** Open the scene in Godot, select each physics body, and visually confirm layer assignment in the Inspector.

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

**From M1+M2 retrospective:**
- 8 systems were built in parallel and merged without integration testing
- Nobody opened the project in Godot to verify it loads
- Autoload order dependency, scene reference breakage, and input map gaps were invisible until someone ran the editor

**Verification workflow:**
1. Check out the feature branch locally
2. Open Godot 4.6 and load the project
3. Check the Output console for errors
4. Verify all 5 autoloads initialize (look for initialization logs or breakpoints)
5. Open the FightScene and verify:
   - Both fighters load without red icons
   - HUD loads without red icons
   - Stage loads without red icons
   - No null reference warnings in the Output
6. Play a test round: confirm fighters spawn, input works, collision happens
7. Only then approve and merge the PR

**Time investment:** 3–5 minutes per PR. Saves hours of debugging integration issues after the fact.

## When to Apply

- Any time agents create parallel feature branches with autoload changes
- Any time project.godot is modified (input map, autoloads, physics config, rendering settings)
- Any time scripts are renamed or scene files are modified
- Before merging any PR that affects gameplay systems (input, physics, rendering)
- Before marking a milestone complete (do a full integration pass)

## Key Takeaway

**Godot projects are fragile under concurrent modification.** Enforce single-agent writes to `project.godot`, verify autoload order, validate scenes in the editor, and test integration before merging. The 10 minutes spent verifying a build prevents hours of post-merge debugging.
