# firstPunch — Backlog Expansion (Specialist Team)

> Compressed from 17KB. Full: backlog-expansion-archive.md

**Author:** Solo (Lead / Architect)  
**Date:** 2026-06-03  
---

## 1. Existing Item Re-assignments
Items from the original 52-item backlog that should transfer to new specialist owners. Original owner shown for traceability.
### → Boba (VFX/Art Specialist)
| Original # | Item | Was | Now | Rationale |
| P1-2 | Hit impact VFX | Lando | **Boba** | VFX design, not gameplay logic |
| P1-9 | Brawler walk cycle | Lando | **Boba** (art) + Lando (hookup) | Art frames are Boba's domain; Lando wires to animation controller |
| P1-10 | Brawler attack animations | Lando | **Boba** (art) + Lando (hookup) | Same split — art vs mechanics |
| P1-11 | Enemy death animation | Lando | **Boba** | Visual effect, not AI/gameplay |
| P2-4 | Brawler redesign | Lando | **Boba** | Pure character art |
---

## 2. Expanded Team Additions
New items that specialists would identify from their domain expertise. These are gaps that an engineer-only team wouldn't see.
### 2.1 Boba (VFX/Art) — 8 New Items
| # | Item | Priority | Complexity | Dependencies | Description |
| EX-B1 | Art direction & color palette | P1 | S | None | Define cohesive visual style guide before any art work: primary palette (character yellow, Downtown greens/blues), outline weight, shading approach (flat vs cell-shaded), lighting direction. All subsequent art references this. Without it, art will look inconsistent across characters, backgrounds, and effects. |
| EX-B2 | Character ground shadows | P1 | S | None | Oval shadow sprite under every character. Scales smaller/lighter as character rises during jumps. Critical for 2.5D depth readability — without shadows, players can't tell where characters will land. |
| EX-B3 | Enemy attack telegraph VFX | P1 | S | P1-8 | Visual wind-up indicator before enemy attacks: brief flash, exclamation mark, or color shift. Players need ~300ms of visual warning to react fairly. Without this, enemy damage feels cheap. |
| EX-B4 | Attack motion trails | P2 | M | P1-8, P1-10 | Semi-transparent arc trails behind fists/feet during attacks. 3-4 frame afterimage that fades. Standard in modern beat 'em ups for making attacks feel fast and readable. |
| EX-B5 | Enemy spawn-in effects | P2 | S | P2-6 | Enemies shouldn't just appear. Dust cloud + drop-in from above, or shadow-on-ground → land effect. Gives player warning and feels polished. |
---

## 3. Summary
### Backlog Growth
| | Original | Re-assigned | New | Total |
| Items | 52 | 0 (moved, not added) | **33** | **85** |
| P0 | 5 | — | +1 | **6** |
| P1 | 20 | — | +14 | **34** |
| P2 | 17 | — | +14 | **31** |
| P3 | 14 | — | +1 | **15** |
| Owner | New Items | Key Theme |