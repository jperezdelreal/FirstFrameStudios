# Decision: Autonomous Infrastructure Pivot to ComeRosquillas

**Author:** Jango (Tool Engineer)
**Date:** 2026-07-24
**Status:** Implemented

## Context
The autonomous loop infrastructure (ralph-watch, scheduler, heartbeat) was built during the FLORA planning phase but never became operational. The studio focus has shifted to ComeRosquillas (Homer's Donut Quest), a web game at `games/comerosquillas/` using HTML/JS/Canvas.

## Decision
1. **now.md** points to ComeRosquillas as the active project (not FLORA)
2. **Scheduler tasks** reference web-game workflows (browser playtest, browser compat) instead of Godot builds
3. **Backlog grooming** is enabled (was disabled)
4. **tools/README.md** documents how to start the autonomous loop with one command
5. **Legacy Godot tools** remain in `tools/` for reference but are documented as archived

## Consequences
- Any agent reading `now.md` will know the active game is ComeRosquillas
- The scheduler will create web-game-appropriate issues when ralph-watch runs
- Joaquín can start the full loop with `.\tools\ralph-watch.ps1`

## Team Impact
- **All agents:** now.md context is current — no confusion about FLORA vs ComeRosquillas
- **Ackbar:** Playtest issues now include browser checklist instead of Godot build instructions
- **Mace:** Backlog grooming is back on the schedule (Wednesdays)
- **Ralph:** Loop is verified operational — just needs to be started
