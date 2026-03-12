# Cutscene System Architecture for ComeRosquillas

**Date:** 2025-01-XX  
**Agent:** Wedge (UI/UX Developer)  
**Project:** ComeRosquillas  
**Issue:** #5 - Simpsons-themed intermission cutscenes

## Decision

Implemented a timeline-based cutscene system using a dedicated game state (ST_CUTSCENE) with declarative actor spawning and simple action processing.

## Context

ComeRosquillas needed Pac-Man-style intermission cutscenes between levels to add personality and humor. The game already had a state machine and rich sprite rendering methods for characters.

## Design Choices

### Timeline-Based Architecture
- Cutscenes defined as `{duration, timeline: [{frame, action, params}]}` objects
- Events trigger at specific frames (e.g., frame 0, 30, 60)
- Actors stored in array with position, velocity, and type
- Update loop advances frame counter and spawns/updates actors

**Why:** Declarative timelines are easier to author and modify than imperative animation code. Non-programmers can add cutscenes by editing data.

### Reuse Existing Sprite Methods
- Called Sprites.drawHomer(), _drawBurns(), _drawNelson(), drawDonut(), drawDuff()
- No new rendering code needed
- Actors positioned in screen space, not grid space

**Why:** DRY principle — sprites already looked good, no need to redraw. Maintains visual consistency with gameplay.

### Skip on Any Key
- Any keypress during ST_CUTSCENE calls skipCutscene()
- Immediately transitions to next level via endCutscene()

**Why:** Player agency — some players want to skip, others want to watch. Match arcade conventions.

### Black Background
- Full black canvas instead of game maze
- Focuses attention on animated sprites

**Why:** Simplicity and performance. No need to render maze during cutscenes. Classic arcade aesthetic.

## Trade-offs

- **Pro:** Easy to add new cutscenes without touching logic code
- **Pro:** Minimal performance impact (just sprite drawing)
- **Pro:** Consistent with existing codebase patterns (state machine)
- **Con:** Timeline format is rigid — complex branching/looping would require new actions
- **Con:** No audio/dialogue system yet (could extend action types)

## Alternatives Considered

1. **Sprite sheets + frame-by-frame animation** — Too heavyweight for a Pac-Man clone
2. **Video files** — Would break "no external assets" constraint
3. **CSS animations** — Mixing canvas and DOM would complicate rendering

## Future Extensions

- Add 'sound' action type to trigger SFX at specific frames
- Add 'camera' action for pan/zoom effects
- Support looping cutscenes (e.g., attract mode)
- Add cutscene editor UI (stretch goal)

## Files Modified

- `js/config.js` — Added ST_CUTSCENE, CUTSCENE_LEVELS, CUTSCENES data
- `js/game-logic.js` — Added cutscene methods, state handling, skip logic
