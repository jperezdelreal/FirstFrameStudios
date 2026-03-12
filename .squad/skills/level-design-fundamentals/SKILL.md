# SKILL: Level Design Fundamentals

Universal level architecture for every genre. Levels teach, test, and reward. Spatial grammar, pacing, flow, environmental storytelling, and playtesting methodology.

---

name: "level-design-fundamentals"
description: "Universal level design principles covering spatial grammar, pacing, flow, environmental storytelling, genre-specific patterns, and playtesting"
domain: "game-design"
confidence: "low"
source: "firstPunch beat 'em up + genre research (Super Metroid, Dark Souls, Portal, Celeste, Hollow Knight, BotW)"
has_reference: true

---

## Context

Use when designing levels, planning progression, tuning difficulty curves, or debugging "level feels slow/frustrating." Applicable to platformer, action, RPG, puzzle, horror genres. Not for narrative systems, AI, puzzle mechanics, or art asset creation.

## Core Patterns

### The Level is the Teacher (Nintendo School)
Level structure teaches. Not text or cutscenes. Example: SMB 1-1 teaches jump by presenting gap → player learns "jump over obstacles" without dialogue.

### Three Level Purposes
1. **Teach:** Introduce one concept. Threat low, failure is learning.
2. **Test:** Combine known concepts under pressure. Threat high.
3. **Reward:** Celebrate mastery with spectacle/narrative. Challenge low.

**Rhythm:** Teach → Test → Reward → (repeat with higher stakes).

### Six Core Space Types
1. **Safe:** No threats, clear sightlines, breathing room. Use after major tests.
2. **Danger:** Active threats, limited escapes, high intensity.
3. **Transition:** Move between safe/danger. Control pacing (10-20s).
4. **Arena/Encounter:** Structured combat with clear boundaries.
5. **Reward:** Celebrate completion with treasure, story, vista.
6. **Sequencing:** SAFE → TRANSITION → DANGER → REWARD → (loop)

### The 3-Beat Rule (Teaching Through Repetition)
1. **Introduce:** Solo, safe arena, obvious mechanic.
2. **Repeat with variation:** Multiple instances, slight changes.
3. **Combine:** Mix with previous mechanics.

## Key Examples

### Pacing: Roller Coaster Model
Intensity follows curve, not plateau. Build tension → release → build higher → bigger release. Never stay at max (>1min = exhaustion) or plateau at medium (>2min = boredom).

### Environmental Storytelling
Show, don't tell. Dark Souls: skeleton with sword at cliff bottom = "someone fell here." No exposition needed.

### Breadcrumbing
Guide without markers. Visual direction (bright ahead), enemy placement (where danger is, progression is), architectural flow (narrow passage leads forward).

## Anti-Patterns

- **The Corridor:** Long linear path, no choices. Fix: Add variety, mini-challenges, keep <30s.
- **Empty Space:** Nothing to do. Fix: Add detail, rewards, enemies, or reduce space.
- **Difficulty Wall:** Sudden spike, no preparation. Fix: Gradual ramp, introduce threats at low stress first.
- **Backtrack Hell:** Traverse long distances repeatedly. Fix: Add shortcuts, new content on revisit, fast travel.
- **Copy-Paste Rooms:** Identical layouts repeated. Fix: Add variation, different arrangements, contextual details.

**Full details:** See REFERENCE.md for spatial grammar details, intensity mapping, genre-specific patterns (platformer, beat 'em up, Metroidvania, RPG, puzzle, 3D action, horror), camera design, secrets, and complete process workflows.