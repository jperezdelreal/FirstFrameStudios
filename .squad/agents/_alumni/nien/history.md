# Nien — History

## Core Context (Summarized)

**Role:** Level design & visual effects engineer for Ashfall and Flora.

**Key Contributions:**
1. **Ashfall Level Design** — EmberGrounds stage with 5 parallax layers, escalation system wired to round_started signal (dormant/warming/eruption states)
   - Dual-axis reactivity: round progress + ember gauge visual feedback
   - Lava, embers, smoke, vignette all interpolate independently
2. **VFX Manager Architecture** — Connects to 7 EventBus signals (hit_landed, hit_blocked, hit_confirmed, fighter_ko, ember_changed, ember_spent, round_started)
   - 10+ VFX types with character-specific palettes
   - Zero direct coupling to fighters; event-driven spawning
3. **Flora Visual Effects** — Spell effects, terrain reactions, character abilities
4. **Performance** — Deterministic VFX timing via _physics_process(); event-driven dedup

**Technical Standards:**
- EventBus-decoupled VFX (no direct fighter references)
- Character-specific palette system for visual identity
- Frame-synchronized effects (no float timers)
- Parallel layer systems for depth

**Archived Skills:** Level design, VFX systems, parallax architecture, event-driven effects, visual hierarchy

---

*Archived history; sessions details from various dates summarized above.*
