# ComeRosquillas Game - Complete Code Analysis for Unit Testing

## 1. MAIN JS FILES & THEIR PURPOSES

### config.js (375 lines)
**Purpose**: Central configuration and constants management
**Key Contents**:
- Grid/Canvas constants: TILE=24, COLS=28, ROWS=31
- Cell type enums: WALL, DOT, EMPTY, POWER, GHOST_HOUSE, GHOST_DOOR
- Direction enums: UP, RIGHT, DOWN, LEFT with DX/DY arrays
- Game state enums: ST_START, ST_READY, ST_PLAYING, ST_DYING, ST_LEVEL_DONE, ST_GAME_OVER, ST_PAUSED, ST_CUTSCENE, ST_HIGH_SCORE_ENTRY
- Ghost modes: GM_SCATTER, GM_CHASE, GM_FRIGHTENED, GM_EATEN
- 4 Maze layouts: Springfield, Nuclear Plant, Kwik-E-Mart, Moe's Tavern
- Ghost configurations (Sr. Burns, Bob Patiño, Nelson, Snake)
- Timing constants: MODE_TIMERS, FRIGHT_TIME=360, BASE_SPEED=1.8
- Difficulty system: easy/normal/hard with multipliers
- Color palette (Simpsons themed)
- Functions: getMazeLayout(level), getDifficultySettings(), setDifficulty(level)

### game-logic.js (1222 lines, 55.97 KB)
**Purpose**: Main game orchestration and logic - THE CORE FILE FOR TESTING
**Key Class**: Game (single class)
**Module System**: Plain vanilla JavaScript with global variables (no modules)
**Exports**: Game class (global)

### game.js (old/alternate version)
**Purpose**: Appears to be an older wrapped version with IIFE pattern
**Status**: May be legacy - new version uses game-logic.js

### main.js (14 lines)
**Purpose**: Entry point - loads Game on window 'load' event
**Code**: 
\\\javascript
window.addEventListener('load', () => { new Game(); });
\\\

---

## 2. KEY FUNCTIONS IN game-logic.js (BY CATEGORY)

### Initialization & Setup
1. **constructor()** (lines 8-51)
   - Initializes canvas, context, sound, high scores
   - Sets up initial state (ST_START)
   - Initial properties: score=0, lives=3, level=1
   - Loads maze layout
   - Calls setupInput(), shows start screen

2. **setupInput()** (lines 54-97)
   - Listens for keyboard/arrow keys
   - Handles: Enter (start), P (pause), M (mute), S (settings)
   - Prevents default behavior for arrow keys

3. **initLevel()** (lines 268-296)
   - Loads current maze layout from config
   - Counts total dots in level (totalDots)
   - Sets dotsEaten=0
   - Calls initEntities()
   - Sets state to ST_READY

4. **initEntities()** (lines 297-331)
   - Initializes Homer position and properties
   - Initializes all 4 ghosts with starting positions
   - Sets up ghost mode timers
   - Initializes difficulty-based parameters
   - Sets frightTimer=0, ghostsEaten=0

5. **startNewGame()** (lines 254-265)
   - Resets: score=0, lives=3, level=1, ghostsEaten=0
   - Calls initLevel()
   - Sets state to ST_READY
   - Shows start screen message

---

### COLLISION DETECTION ✓

6. **checkCollisions()** (lines 831-857)
   **Purpose**: Detects Homer-Ghost collisions
   **Logic**:
   - Loops through all ghosts (skip if inHouse)
   - Calculates distance using Euclidean: dist = sqrt(dx² + dy²)
   - Collision threshold: dist < TILE * 0.8 (19.2 pixels)
   - **If ghost in GM_FRIGHTENED mode**:
     - Changes ghost to GM_EATEN
     - Sets ghost speed to eatenGhost speed (2x)
     - increments ghostsEaten counter
     - Calculates points: 200 * 2^(ghostsEaten-1) → [200, 400, 800, 1600, 3200...]
     - Adds score
     - Plays sound 'eatGhost'
     - Shows floating text with points
   - **If ghost NOT in GM_FRIGHTENED/GM_EATEN modes**:
     - Sets state to ST_DYING
     - Sets stateTimer=90
     - Plays 'die' sound
     - Returns (stops further ghost processing)

7. **checkDots()** (lines 535-582)
   **Purpose**: Detects Homer-Dot/Power-Up collision
   **Logic**:
   - Gets current tile at Homer's center position
   - **If cell === DOT (regular pellet)**:
     - Replaces maze cell with EMPTY
     - Adds 10 points
     - Increments dotsEaten
     - Plays 'chomp' sound (every 2 frames)
     - Shows particles
     - Calls checkExtraLife()
     - Spawns bonus at dotsEaten=70 and 170
   - **If cell === POWER (power pellet)**:
     - Replaces maze cell with EMPTY
     - Adds 50 points
     - Increments dotsEaten
     - Resets ghostsEaten=0 (resets multiplier)
     - Sets frightTimer = getLevelFrightTime()
     - Changes ALL non-EATEN ghosts to GM_FRIGHTENED
     - Reverses ghost directions
     - Sets ghost speeds to frightGhost speed
     - Plays 'power' sound
     - Shows Homer power quote
   - **If all dots eaten** (dotsEaten >= totalDots):
     - Sets state to ST_LEVEL_DONE
     - Calls sound.play('levelComplete')
     - Shows level complete message

8. **updateBonus()** (lines 590-607)
   **Purpose**: Handles bonus item collection
   **Logic**:
   - If bonus active and timer > 0:
     - Decrements bonusTimer
     - Checks distance to Homer
     - If distance < TILE * 0.8:
       - Adds points: [100, 300, 500, 700, 1000] cycled by level
       - Shows floating text
       - Deactivates bonus

---

### SCORE CALCULATION ✓

**Score system is inline, not a separate function:**

| Event | Points | Location |
|-------|--------|----------|
| Regular dot | 10 | checkDots() line 544 |
| Power pellet | 50 | checkDots() line 554 |
| Eaten ghost 1st | 200 | checkCollisions() line 842 |
| Eaten ghost 2nd | 400 | checkCollisions() line 842 |
| Eaten ghost 3rd | 800 | checkCollisions() line 842 |
| Eaten ghost 4th | 1600 | checkCollisions() line 842 |
| Bonus item | 100-1000 | updateBonus() line 602 (varies by level) |

**Formula for ghost eating**: \points = 200 * Math.pow(2, ghostsEaten - 1)\

**Extra life logic**: checkExtraLife() (lines 610-619)
- Checks if score >= difficulty.extraLifeThreshold
- If not already given (extraLifeGiven flag):
  - Increments lives
  - Plays 'extraLife' sound
  - Shows "EXTRA LIFE!" message
  - Updates HUD

---

### GAME STATE TRANSITIONS ✓

**States defined in config.js**:
- ST_START = 0 (start screen)
- ST_READY = 1 (countdown before level)
- ST_PLAYING = 2 (active gameplay)
- ST_DYING = 3 (Homer death animation)
- ST_LEVEL_DONE = 4 (level complete)
- ST_GAME_OVER = 5 (game finished)
- ST_PAUSED = 6 (paused)
- ST_CUTSCENE = 7 (story cutscene)
- ST_HIGH_SCORE_ENTRY = 8 (entering initials)

**State transitions in update()** (lines 393-459):
- **ST_READY** → ST_PLAYING (after stateTimer reaches 0)
- **ST_DYING** → (stateTimer--)
  - If timer <= 0:
    - If lives <= 0: check high score, go to ST_HIGH_SCORE_ENTRY or ST_GAME_OVER
    - Else: reinit entities, ST_READY (respawn on same level)
- **ST_LEVEL_DONE** → (stateTimer--)
  - If timer <= 0:
    - Check if level triggers cutscene
    - If yes: startCutscene()
    - If no: increment level, initLevel(), ST_READY
- **ST_CUTSCENE** → updateCutscene()
- **ST_PLAYING** → main game loop

**Input-driven transitions**:
- Enter/Space in ST_START → startNewGame()
- P key in ST_PLAYING → ST_PAUSED
- P key in ST_PAUSED → ST_PLAYING
- Any key in ST_CUTSCENE → skipCutscene()

---

### POWER-UP SYSTEM ✓

**Power-up activation** (in checkDots(), lines 552-571):
1. Detection: Check if cell === POWER
2. On collection:
   - Removes power from maze
   - Adds 50 points
   - Resets ghostsEaten=0 (for multiplier reset)
   - **Frightens all ghosts**:
     - Sets frightTimer = getLevelFrightTime()
     - Loops through ghosts:
       - If NOT in GM_EATEN mode: change to GM_FRIGHTENED
       - Reverse direction (OPP[g.dir])
       - Set speed = getSpeed('frightGhost')
       - Reset pathfinding cache

3. **Fright time calculation** (getLevelFrightTime(), lines 340-345):
   - Difficulty adjusted: \getLevelFrightTime() * difficulty.frightTimeMultiplier\
   - Base FRIGHT_TIME = 360 frames (6 seconds at 60fps)
   - Reduces by ~10% per level: \(8 - ramp * 0.5) * FRIGHT_TIME\

4. **During fright duration** (updateGhostMode(), lines 461-494):
   - frightTimer counts down each frame
   - While frightTimer > 0: ghosts stay in GM_FRIGHTENED
   - When frightTimer <= 0: restore ghosts to previous globalMode

5. **Ghost escape from fright** (moveGhost(), lines 657-667):
   - When eaten ghost returns home (col ≈ 14, row ≈ 12)
   - Re-enters ghost house
   - Mode reverts to GM_FRIGHTENED (if still active) or globalMode
   - Speed resets appropriately

---

## 3. MODULE SYSTEM DETECTION

### Module Type: **PLAIN VANILLA JAVASCRIPT WITH GLOBAL VARIABLES**

**Evidence**:
1. **No ES6 modules**: No \import\/\xport\ statements
2. **No CommonJS**: No \module.exports\ or \equire()\
3. **Global scope**: All variables/classes directly accessible
4. **Script loading order in index.html**:
   \\\html
   <script src="js/config.js"></script>
   <script src="js/engine/audio.js"></script>
   <script src="js/engine/renderer.js"></script>
   <script src="js/engine/high-scores.js"></script>
   <script src="js/engine/touch-input.js"></script>
   <script src="js/game-logic.js"></script>
   <script src="js/main.js"></script>
   \\\
5. **Class export**: Game class instantiated directly on window load
6. **Dependencies**: game-logic.js depends on globals from config.js
7. **Strict mode**: Uses \'use strict'\ but within each file scope

### Global Variables Used:
- Config constants: TILE, COLS, ROWS, CANVAS_W/H
- Enums: WALL, DOT, UP, DOWN, LEFT, RIGHT, ST_*, GM_*
- Helper functions: getMazeLayout(), getDifficultySettings()
- Classes: SoundManager (from audio.js), HighScoreManager (from high-scores.js)
- Classes: Sprites (from renderer.js), TouchInput (from touch-input.js)

---

## 4. EXISTING TEST INFRASTRUCTURE

**Status**: ✗ **NO TEST FILES FOUND**

Checked patterns:
- ✗ No \	est/\ directories
- ✗ No \__tests__/\ directories
- ✗ No \*.test.js\ files
- ✗ No \*.spec.js\ files

**package.json test script**:
\\\json
"test": "echo \"Error: no test specified\" && exit 1"
\\\

**Dependencies**: 
- Only devDependency: "@bradygaster/squad-cli": "^0.8.25"
- **No test framework installed** (no Jest, Mocha, Vitest, etc.)

---

## 5. TESTABLE FUNCTIONS SUMMARY

### Pure Logic Functions (Easiest to Test):
1. **getSpeed(type, ghost)** - Speed calculations
2. **getDifficultyRamp()** - Difficulty progression
3. **getLevelFrightTime()** - Fright duration calc
4. **getLevelModeTimers()** - Ghost mode timing
5. **isWalkable(col, row, isGhost)** - Tile walkability check
6. **tileAt(px, py)** - Pixel to tile conversion
7. **centerOfTile(col, row)** - Tile center position
8. **getChaseTarget(g)** - Ghost target AI
9. **bfsNextDirection()** - Pathfinding algorithm

### State Mutation Functions (Need State Setup):
1. **checkCollisions()** - Ghost collision logic
2. **checkDots()** - Dot collection & scoring
3. **checkExtraLife()** - Extra life threshold
4. **updateBonus()** - Bonus collection
5. **updateGhostMode()** - Mode switching
6. **moveHomer()** - Player movement
7. **moveGhost(g)** - Ghost movement

### Integration Functions (Need Full Setup):
1. **update()** - Main game update loop
2. **initLevel()** - Level initialization
3. **initEntities()** - Entity setup
4. **startNewGame()** - Game start

---

## 6. KEY FUNCTIONS FOR TESTING REQUIREMENTS

Based on issue requirements, focus on testing:

### ✓ Collision Detection (checkCollisions)
- Homer-Ghost collision with distance formula
- Ghost mode checking (Frightened vs Normal)
- Score accumulation (200 * 2^n formula)
- Multiple ghost elimination in one power-up

### ✓ Score Calculation (inline in checkDots/checkCollisions)
- Regular dot: +10
- Power pellet: +50
- Ghost eating: 200, 400, 800, 1600, 3200
- Bonus items: 100-1000 by level
- Extra life at threshold

### ✓ Game State Transitions (update)
- ST_START → ST_READY → ST_PLAYING → ST_DYING
- ST_LEVEL_DONE transitions with cutscene detection
- ST_PAUSED pause/resume
- ST_GAME_OVER conditions

### ✓ Power-up System (checkDots)
- Power pellet detection
- Ghost frightening logic
- Fright timer management
- Ghost escape mechanism

---

## 7. TESTING NOTES

**Challenge #1: Global Dependencies**
- Game class relies on global config constants
- Need to ensure config.js is loaded before tests
- Mock or setup SoundManager, HighScoreManager, Sprites

**Challenge #2: Canvas & DOM**
- Game initializes canvas and DOM elements
- Tests need to mock document.getElementById()
- Mock canvas 2D context

**Challenge #3: Async Loops**
- Main game loop uses requestAnimationFrame
- May need to mock or use fake timers

**Challenge #4: Random Elements**
- Ghost AI includes random selection in FRIGHTENED mode
- Quotes are randomly selected
- Use Math.seedrandom or mock Math.random()

**Recommended Approach**:
1. Use Jest (most common for JS)
2. Mock DOM elements and canvas
3. Test pure functions first (getSpeed, etc.)
4. Test collision/scoring logic with state setup
5. Use fake timers for time-dependent tests
