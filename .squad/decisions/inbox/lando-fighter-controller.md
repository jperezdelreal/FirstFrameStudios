# Decision: Fighter Controller + Input Buffer Architecture

**Author:** Lando (Gameplay Developer)  
**Date:** 2025-07-21  
**Status:** Implemented  
**Scope:** Ashfall — input system and fighter gameplay layer

## Decisions Made

### 1. InputBuffer Routes ALL Input
All fighter input now flows through the InputBuffer ring buffer, replacing direct `Input.is_action_*()` calls. This gives us:
- Buffered input leniency (8 frames / 133ms)
- Motion detection from directional history
- Button consume to prevent double-execution
- AI injection via the same code path as human input
- Deterministic replay potential (buffer IS the input record)

### 2. Controller Handles Attacks, States Handle Movement
The FighterController owns attack priority resolution (throw > specials > normals). States continue to handle their own movement transitions (idle ↔ walk ↔ crouch ↔ jump). This separation means the controller adds motion detection VALUE without rewriting existing state logic.

### 3. Motion Priority: Complex Beats Simple
When the buffer contains both a DP (→↓↘) and a QCF (↓↘→), the DP wins because it's checked first. This matches industry standard (SF6, Guilty Gear) and prevents accidental fireballs when you mean dragon punch. Priority order: double_qcf > hcf/hcb > dp > qcf/qcb.

### 4. MoveData as Pure Resource
Moves are `.tres` resource files with frame data, not code. This means:
- Designers can tune frame data in the Godot inspector without touching GDScript
- Each character's moveset is a single exportable resource
- Combat balance is data-driven, not code-driven

### 5. 8-Frame Input Leniency
The GDD specifies 8 frames (133ms). This is the sweet spot: generous enough that casual players don't feel the game "eats" inputs, tight enough that pros feel precision matters. This is tuneable via `InputBuffer.INPUT_LENIENCY`.

### 6. SOCD Resolution
Left+Right = Neutral, Up+Down = Up (jump priority). Matches FGC standard and prevents illegal directional states.

## Impact on Team
- **Chewie/Solo:** InputBuffer is now the input source of truth. Any new system that reads input should go through the buffer, not `Input.*` directly.
- **Tarkin:** MoveData resources are ready for frame data tuning. Add new moves by creating .tres files.
- **AI agent:** Use `inject_direction()` and `inject_button()` on the InputBuffer — same code path as human players.
- **Ackbar:** Input leniency, motion windows, and priority values are constants at the top of their files — easy to find and tune during playtesting.

## Why
"Player Hands First" — the input buffer is what separates a fighting game that feels responsive from one that feels broken. The 8-frame window, motion priority, and consume system are the invisible engineering that makes QCF+Punch feel like you meant it.
