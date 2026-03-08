# SimpsonsKong

A browser-based beat 'em up arcade game inspired by **The Simpsons Arcade**, **Final Fight**, and **Streets of Rage**. Fight your way through waves of enemies in Springfield with pure JavaScript, HTML5 Canvas, and Web Audio.

## Quick Start

Simply open `index.html` in a modern web browser. No build step, no npm, no server needed.

**Note:** Some browsers may restrict ES modules from `file://` URLs. If you encounter module loading errors, start a local server:

```bash
# Using Node.js
npx serve .

# Using Python 3
python -m http.server
```

## Controls

| Action | Keys |
|--------|------|
| **Move** | `WASD` or Arrow Keys (4-directional on 2.5D plane) |
| **Punch** | `J` or `Z` |
| **Kick** | `K` or `X` |
| **Jump** | `Space` |
| **Start Game** | `Enter` |

## Tech Stack

- **Pure HTML/CSS/JavaScript** (ES modules)
- **HTML5 Canvas** for rendering
- **Web Audio API** for sound effects
- No external dependencies
- No build process required

## Project Structure

```
SimpsonsKong/
├── index.html              # Entry point
├── styles.css              # Page styling and canvas layout (16:9 letterboxing)
├── squad.config.ts         # Squad AI team configuration
├── src/
│   ├── engine/             # Core game loop and physics
│   ├── entities/           # Character and enemy definitions
│   ├── systems/            # Input handling, collision, rendering
│   ├── scenes/             # Title screen and gameplay scenes
│   └── ui/                 # HUD rendering (health bars, score)
└── README.md               # This file
```

## About This Project

**SimpsonsKong** was built under a 30-minute time constraint to demonstrate rapid game development with vanilla JavaScript.

### What's Included ✅
- Playable level with Springfield setting
- Combat system (punch and kick mechanics)
- Enemy waves with AI behavior
- Health and score tracking
- Title screen and game over states

### What Was Scoped Out ⏰
- Multiple playable characters
- Power-ups and special items
- Save/continue system
- Multiple levels
- Sprite sheets and animations
- Full audio track and voice lines

Despite the tight timeline, the game provides a complete arcade experience in pure JavaScript.

## License

MIT
