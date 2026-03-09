# Design-to-Implementation Checklist

When implementing a feature, align code with design:

- [ ] **GDD Section Referenced** — Note which GDD section(s) this feature implements
- [ ] **Architecture Pattern** — Confirm this uses the right pattern (signals, nodes, managers, etc.)
- [ ] **Signals Identified** — List required signals and wire them in the implementation
- [ ] **Autoloads Checked** — Verify any required autoloads exist in project settings; add if missing
- [ ] **Collision Layers Set** — If physics-related, verify collision matrix and layers are correct per COLLISION-MATRIX.md
- [ ] **Documentation Updated** — Add/update relevant sections in ARCHITECTURE.md or GDD.md

**Time: ~2 minutes to verify**

This ensures code stays aligned with team decisions and reduces rework.
