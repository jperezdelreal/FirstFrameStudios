# Chewie — Fighter Engine Infrastructure Decisions

**Author:** Chewie (Engine Developer)  
**Date:** 2025-07-22  
**Status:** Proposed  
**Scope:** Ashfall — fighter state machine, hitbox/hurtbox, round manager

## Decisions Made

### 1. Simplified Collision Layers (4 instead of 6)
The ARCHITECTURE.md specifies 6 per-player collision layers (P1 hitbox, P2 hitbox, P1 hurtbox, P2 hurtbox, pushbox). I used the scaffold's existing 4 layers (Fighters, Hitboxes, Hurtboxes, Stage) since the task scoped it this way and the simplified setup works for local play. When we need per-player collision isolation (e.g., for 2v2 or preventing self-hits in complex scenarios), we expand to the 6-layer scheme. The Hitbox class already auto-prevents self-hits via owner_fighter comparison.

### 2. Node Names Without "State" Suffix
State machine nodes are named "Idle", "Walk", "Attack" etc. (not "IdleState", "WalkState"). This makes `transition_to("idle")` calls clean and matches the architecture doc's transition call patterns. The state_machine stores them lowercase: `states["idle"]`, `states["walk"]`.

### 3. Frame-Phase Attack State (Temporary)
The AttackState uses internal frame counters (startup/active/recovery) for hitbox activation. This is scaffolding — the ARCHITECTURE.md's intended design uses AnimationPlayer tracks to drive hitbox timing. When Tarkin creates MoveData resources with animation references, the AttackState should switch to animation-driven hitbox activation. The frame-phase approach works now and demonstrates the pattern.

### 4. Dual Signal Emission in RoundManager
RoundManager emits both local signals (for direct `connect()` wiring in fight_scene.gd) AND EventBus global signals. This lets Solo wire the fight scene directly while UI/VFX/audio systems can listen via EventBus without needing scene-tree references. Slight redundancy, but the decoupling benefit outweighs it.

### 5. Input Wrappers (Not InputBuffer)
Fighter states read input via `Fighter.is_input_pressed()` / `is_input_just_pressed()` thin wrappers over Godot's Input singleton. These are placeholder — Lando will replace them with the InputBuffer system from the architecture doc. The wrappers are keyed by player_id prefix so P1/P2 already work independently.

## Impact on Other Agents

- **Lando (Gameplay):** Build the fighter controller on top of this infrastructure. Replace input wrappers with InputBuffer. Extend states with motion-input detection, cancel windows, combo logic.
- **Tarkin (Content):** Create MoveData .tres resources. When ready, AttackState needs to accept MoveData args and use AnimationPlayer instead of frame counters.
- **Wedge (UI):** Wire health bars to `Fighter.took_damage` signal. Wire round announcements to `RoundManager.announce` / `EventBus.announce`.
- **Solo (Architecture):** Review collision layer approach — expand to 6-layer when needed.
- **Jango (Tools):** No project.godot changes needed for now. When 6-layer collision is adopted, Jango updates layer names.
