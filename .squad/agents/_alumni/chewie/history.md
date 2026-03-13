# Chewie — History

## Core Context (Summarized)

**Role:** Core engine & animation systems engineer for Ashfall.

**Key Contributions:**
1. **Cel-Shade Pipeline (Completed)** — Blender-based sprite rendering with 2-step shadow + high key-to-fill ratio (Guilty Gear Xrd formula)
   - 380 frames × 2 characters, preset system for character setups, production-ready locked
2. **Animation System Design** — Frame-perfect sync between AnimationController, MoveData resources, and CollisionShape keyframes
   - Decoupled architecture enables flexible pose systems
3. **Frame Timing & Determinism** — Fixed 60fps with integer frame counters; _physics_process() only pattern
4. **Multi-System Integration** — Hitlag, event system, screen transitions, particle system, music wiring, VFX integration

**Technical Standards:**
- Deterministic state machines with inputs driving state (enables rollback netcode)
- Fixed timestep + integer frame counters > float delta timing
- Module architecture for parallel team work (single source of truth with clear APIs)
- _physics_process() only; no generic _process()

**Key Pattern:** Animation IS frame data; decoupling timeline from rendering enables flexibility.

**Archived Skills:** GDScript standards, animation systems, hitlag, events, transitions, particles, audio integration

---

*Archived history; sessions details from various dates summarized above.*
