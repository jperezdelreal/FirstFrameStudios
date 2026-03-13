# Lando — History

## Core Context (Summarized)

**Role:** Frame data & gameplay systems engineer for Ashfall and Flora.

**Key Contributions:**
1. **Frame Data Architecture** — Comprehensive move definitions (startup, active, recovery frames, hitbox/hurtbox shapes, damage values, knockback)
   - MoveData resources drive animation + collision + damage
   - Frame-perfect sync between collision shapes and animation keyframes via _physics_process()
2. **Gameplay Systems** — Hitbox detection, damage calculation, knockback physics, combo system, state machine transitions
3. **Flora Game Development** — Multi-system integration for browser-based tactical RPG
4. **Performance Optimization** — Deterministic 60fps loops; pre-computed collision shapes

**Technical Standards:**
- Frame data IS law (all timing driven by move definitions, not animation duration)
- Integer frame counters drive all timing; _physics_process() only
- Hitbox/hurtbox architecture: separate layers for each attack type
- Knockback vectors calculated from move definitions

**Archived Skills:** Frame data systems, collision architecture, damage systems, state machines, performance profiling

---

*Archived history; sessions details from various dates summarized above.*
