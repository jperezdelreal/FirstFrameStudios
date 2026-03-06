# Ackbar — History

## Project Context
- **Project:** SimpsonsKong — Browser-based Simpsons beat 'em up
- **User:** joperezd
- **Stack:** HTML + CSS + JS (ES modules), HTML5 Canvas, Web Audio API
- **Current state:** MVP playable with 3 enemy waves, basic combat. Combat feel scored 5/10 in gap analysis. No hitlag, no combos, no jump attacks. Input responsiveness 7/10. Knockback satisfaction 6/10.
- **Key role:** Only team member whose job is playing the game critically. Engineers test their own code — Ackbar tests the experience.

## Learnings

### 2026-06-03: Frame Data Extraction & Debug Overlay (EX-A1, EX-A2)
- Created `src/debug/debug-overlay.js` — toggle-able hitbox/state overlay (backtick key). Draws hurtboxes (green), attack hitboxes (red), entity state labels, FPS counter, entity count. Ready for integration into gameplay.js by another agent.
- Created `.squad/analysis/frame-data.md` — full combat data reference extracted from source.
- **Key finding: Enemy attacks are effectively 1-frame active.** The AI sets `state='attack'` but immediately reverts to `idle` next frame due to `aiCooldown` logic. This is likely why combat feels too easy (gap analysis scored 5/10). Enemies barely threaten the player.
- **No combo system exists.** `player.comboCount` is not a real property — confirmed by reading player.js. Debug overlay handles this gracefully (only renders if property exists).
- **Kick visual outlasts its hitbox** by 0.05s — potential player confusion where the animation shows but damage window has closed.
- **Zero startup on all attacks** — both player and enemy attacks produce hitboxes on the same frame as input. No wind-up frames. Makes combat feel reactive but lacks weight.
- Player knockback decays at 0.90×/frame, enemy at 0.85×/frame — enemies slide further proportionally, contributing to the "scatter" feel.
