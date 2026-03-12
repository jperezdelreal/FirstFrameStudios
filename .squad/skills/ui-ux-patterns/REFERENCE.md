# SKILL: Game UI/UX Design Patterns

Game UI and UX design patterns applicable to any game genre, any engine, any platform. Covers HUD design, menu systems, information hierarchy, responsive scaling, animations, accessibility, and anti-patterns learned from building firstPunch.

---

name: "ui-ux-patterns"
description: "Game UI/UX design patterns — HUD systems, menu flow, information hierarchy, responsive layouts, animations, accessibility"
domain: "user-experience"
confidence: "medium"
source: "earned — built arcade HUD, title screen, pause menu, options menu, level intro, game over screen, progress indicators, enemy health bars in firstPunch"
origin: "firstPunch (2026)"

---

## When to Use This Skill

- Designing or implementing UI for any game type (action, RPG, puzzle, strategy, etc.)
- Laying out HUD elements (health, score, abilities, resources)
- Building menu systems (title screen, pause, options, game over)
- Implementing responsive canvas/viewport scaling
- Creating feedback UI (damage numbers, combo counters, status effects)
- Designing for accessibility (color blindness, text readability, input options)
- Animating UI elements (transitions, state changes, emphasis)
- Debugging "UI is hard to read" or "menu navigation feels sluggish"

## When NOT to Use This Skill

- Web app UI (different information hierarchy and interaction model entirely)
- 3D game UI overlays (camera projection is a separate skill)
- Narrative/dialog systems (story sequencing is a separate skill)

---

## Core Patterns

### 1. The Information Hierarchy: Player State at a Glance

The **"glance test"**: A player should understand their current state in <0.5 seconds without looking away from the action.

**Universal hierarchy (applies to ALL games):**

```
TIER 1 (Most important — always visible, primary focus area)
  ├─ Player health / shields
  └─ Immediate threat indicator

TIER 2 (Supporting action — visible but secondary)
  ├─ Resources (ammo, mana, energy)
  ├─ Active abilities / cooldowns
  └─ Current objective / target

TIER 3 (Context and progression — visible but not urgent)
  ├─ Score / points
  ├─ Combo / multiplier
  ├─ Level / wave progress
  └─ Time / timer

TIER 4 (Reference — hidden until needed)
  ├─ Mini-map
  ├─ Inventory
  └─ Stats sheet
```

**Application rules:**

- **Size scales with importance:** Tier 1 is 20-30% of screen. Tier 2 is 10-15%. Tier 3 is 5-10%. Tier 4 is 0% (hidden).
- **Color and contrast:** Tier 1 elements use brightest, most saturated colors. Tier 3 uses muted tones.
- **Position:** Tier 1 stays in primary viewing area (center, top, high-attention zones). Tier 4 occupies corners, edges.
- **On damage:** Only Tier 1 and 2 flash/pulse. Tier 3 stays calm.

**Anti-pattern (firstPunch lesson):** Showing all stats equally sized and colored makes players miss critical information. Early HUD prototype displayed score and combo with same visual weight as health — players died confused about their actual HP value.

**Example layout (action game):**

```
┌─────────────────────────────────┐
│ HEALTH (Tier 1, top-left, 25%)  │
├─────────────────────────────────┤
│ Ammo (Tier 2, 10%) │  Combo (Tier 3, 5%)
│ Ability 1 (12%)    │  Score (3%)
│ Ability 2 (8%)     │  Progress (2%)
└─────────────────────────────────┘
```

### 2. Diegetic vs Non-Diegetic UI

Two types of UI exist in games. Understanding the difference prevents clashing aesthetics.

**Diegetic UI** — Exists *within* the world. The character can see/interact with it.
- Holographic HUD on the character's suit
- Dashboard readout visible on screen
- Health bar floating above an enemy
- Damage numbers in world space

**Non-diegetic UI** — Exists outside the world. Only the player sees it.
- Screen edge vignette (darkening)
- UI panels that overlay the screen
- Score counter in corner
- Pause menu
- Damage indicators (screen edge flash)

**Design rule:** Pick one aesthetic and stick with it. Mixing diegetic armor HUD with non-diegetic score text creates visual confusion.

**firstPunch approach:** Mostly non-diegetic (arcade-style HUD in corners, menus overlay screen) with diegetic elements (enemy health bars float in world, damage numbers appear at impact location). Consistent because both use the same retro-inspired art style.

**Example clarity:**

| Element | Game | Style | Why |
|---------|------|-------|-----|
| Health bar | Action shooter | Non-diegetic panel | Shooter HUD is a known convention; players expect floating bars |
| Damage numbers | Beat 'em up | Diegetic (world space) | Floating numbers at hit location feel connected to action |
| Crosshair | FPS | Non-diegetic (screen center) | Crosshair is aiming tool, not world object |
| Enemy health bar | RPG | Diegetic (above enemy head) | Players expect to see health floating over the creature |

### 3. HUD Design: Position and Timing

**Positioning rules:**

```
Safe zones (always visible, even on narrow screens or letterboxed):
  ┌─────────────────────────────┐
  │   40px margin on all sides   │  Tier 1 fits here
  │  ┌────────────────────────┐  │
  │  │                        │  │  Tier 2 uses edges
  │  │                        │  │
  │  │                        │  │
  │  │                        │  │  Tier 3 uses far corners
  │  │                        │  │
  │  │                        │  │
  │  └────────────────────────┘  │
  │   40px margin on all sides   │
  └─────────────────────────────┘
```

**Key principle:** Never assume the full viewport is safe. Consoles, mobile phones, and browser window resizing can all crop edges. Test on 4:3, 16:10, and 21:9 aspect ratios.

**Timing rules (when to hide/show HUD):**

| State | HUD Visibility | Reason |
|-------|----------------|--------|
| **Gameplay** | Full HUD visible | Player needs all information for action |
| **Cutscene** | Hide HUD (fade over 0.5s) | Narrative clarity; no game state changes during cinematic |
| **Dialog** | Show only Tier 1 (health) | Player can still take damage; everything else paused |
| **Pause menu** | Hide HUD (frozen) | Menu overlays game; HUD becomes irrelevant |
| **Title screen** | Hide game HUD (show menu HUD instead) | Different context entirely |
| **Game over** | Show final state (score, high score) | Post-game review before restart |

**Anti-pattern:** Showing full HUD during cutscenes. Dialogue doesn't have frame data or health importance — hiding it refocuses player attention on narrative.

### 4. Menu Design Patterns

All game menus follow the same structural pattern, regardless of genre.

#### 4.1 Title Screen

**Mandatory elements:**

- **Game title** — Large, readable, branded (no small text)
- **Menu options** — Start Game, Options, Quit (minimum; may include Continue if save exists)
- **Visual identity** — Background art, colors, fonts that establish tone
- **Controls hint** — "Press UP/DOWN to navigate, ENTER to select" (keyboard/gamepad-first, not mouse-first)
- **Credits** — Developer/studio name, copyright (small text, bottom or separate screen)

**Navigation rules:**

- **Keyboard/gamepad primary:** UP/DOWN arrows to navigate, ENTER to select, ESC to go back
- **Mouse secondary:** Optional for menus, but action games should NOT require mouse navigation
- **Selection indicator:** Clear visual highlight (glow, border, color change, scale) on focused item
- **Audio feedback:** Play menu-select SFX on navigate, menu-confirm SFX on select
- **No accidental skips:** Add 0.2-0.3s delay after selection before action fires (prevents double-taps)

**Screen flow:**

```
Title Screen
  ├─→ Start Game → Fade transition → Gameplay
  ├─→ Options → Submenu (Settings) → Back to Title
  ├─→ Continue → Resume from save → Gameplay
  └─→ Quit → Close application
```

**firstPunch example:**
- Yellow "FIRST PUNCH" title with dark stroke
- Menu items centered vertically, pulsing glow on selected item
- UP/DOWN to navigate, ENTER to select
- Credits at bottom: "A firstPunch Production"
- HIGH SCORE display above menu with ★ decorations
- Controls panel showing key bindings

#### 4.2 Pause Menu

**Mandatory elements:**

- **"PAUSED" indicator** — Large, unmistakable text
- **Resume option** — Primary action, frictionless (one key press: ESC or gamepad button)
- **Options access** — Secondary action (O key or Options menu item)
- **Quit to title** — Tertiary action (Q key or Quit menu item)
- **Input hint** — "Press ESC to Resume", "Press O for Options", "Press Q to Quit"
- **Dark overlay** — Semi-transparent (0.5-0.7 alpha) behind text for readability over gameplay

**Rules:**

- **Zero state loss:** All game state (player position, enemies, score, music) preserved during pause
- **Instant response:** <50ms from ESC press to pause rendering (no animation delay that feels sluggish)
- **No options input while paused:** If player enters Options, pause should suspend (don't exit on options close)
- **One input to unpause:** ESC key both pauses AND unpauses (toggle)

**Anti-pattern (firstPunch lesson):** Initial pause menu required selecting "Resume" via menu navigation. Felt sluggish. Changed to ESC toggle — infinite improvement in feel.

#### 4.3 Options / Settings Menu

**Mandatory sections:**

| Section | Controls | Ranges | Why |
|---------|----------|--------|-----|
| **Audio** | Master Volume, SFX Volume, Music Volume | 0-100% sliders | Volume is the #1 adjustable setting players expect |
| **Difficulty** | Easy / Normal / Hard (or 3-6 presets) | Per-game | Balance affects all players; should be changeable mid-game on pause menu |
| **Controls** | Display current keybindings | Read-only or rebindable | Action games need flexible input; let players remap |
| **Display** | Brightness, Contrast (if appropriate to engine) | 0-100% sliders | Accommodates screen variability |
| **Accessibility** | Color blind mode, text size, captions toggle | Binary or enum | See section 6 for details |

**Navigation rules:**

- UP/DOWN to navigate between options
- LEFT/RIGHT to adjust values
- ENTER to open rebind dialog (if rebindable controls)
- ESC to close options and return to previous state

**Selection feedback:**

- Focused item: Yellow border glow (or your game's highlight color)
- Value change: Immediate visual feedback (bar fills/empties, label updates)
- No confirmation needed for slider changes (instant application)

**firstPunch example:**
- Three volume sliders (Master, SFX, Music) with hold-left/hold-right for continuous adjustment (0.8/sec)
- Difficulty selector: "Chill Mode (Easy)", "Normal", "Ringleader (Hard)"
- Read-only controls display showing all keybindings in two columns
- BACK button with pulsing selection indicator
- Dark gradient background matching game aesthetic

#### 4.4 Game Over / Results Screen

**Mandatory elements:**

- **"GAME OVER" or "LEVEL COMPLETE"** — Unmistakable large text
- **Final score** — Prominent, zero-padded (e.g., "SCORE: 0004250")
- **High score comparison** — "NEW HIGH SCORE!" if beaten, else "HIGH SCORE: {value}"
- **Stats summary** — Optional: enemies defeated, accuracy %, time taken, etc.
- **Call-to-action** — "Press ENTER to Retry" or "Press ENTER to Continue"
- **Dark overlay** — 0.7+ alpha for readability

**Rules:**

- **Brief pause before accepting input:** Add 0.5s delay before accepting ENTER (prevents accidental skip on game-over press)
- **No score rollup animation during initial display** — Show final score instantly, then animate it a second time if the player replays
- **High score already saved:** Save happens at game-over event, not at this screen (this screen just displays)
- **Clear navigation:** ENTER is the only input; no menu complexity

**Anti-pattern:** Showing unpadded scores (e.g., "SCORE: 4250" instead of "SCORE: 0004250"). Zero-padding makes scores scannable and arcade-authentic.

### 5. In-Game Feedback UI

Feedback is how the game communicates state changes to the player. Every significant action (damage, level-up, resource gain/loss) should have VISIBLE and AUDIO feedback.

#### 5.1 Damage Numbers

**Format:**

```javascript
// Floating text that spawns at hit location and fades upward
const damageNumber = {
    x: hitX,
    y: hitY,
    value: damage,
    lifetime: 1.0,  // seconds
    age: 0,
    fontSizeBase: 24,  // scales with damage
    color: determineDamageColor(damage)
};
```

**Color coding:**

| Damage Type | Color | Why |
|-------------|-------|-----|
| Light hit (0-10 dmg) | Yellow (#FFD700) | Weak hit, visual clarity |
| Medium hit (11-25 dmg) | Orange (#FFA500) | Standard hit |
| Heavy hit (26-50 dmg) | Red (#FF4444) | Strong hit, higher priority |
| Crit / Bonus (50+ dmg) | Gold (#FFD700) + glow | Rare, celebration feedback |
| Heal | Green (#00FF00) | Positive, distinct |

**Scaling rules:**

- **Font size:** Base (24px) + 1px per 10 damage (so 50 damage = 30px)
- **Position offset:** Randomize X ±20px to prevent overlap (multiple hits stack left/right)
- **Rise speed:** 60px/sec upward over lifetime
- **Alpha fade:** Linear fade to 0 over last 0.3s of lifetime
- **Pop effect:** On spawn, scale from 1.5x → 1.0x over 0.1s for emphasis

**Anti-pattern:** Static position (damage number doesn't move). Floating text must animate to feel like feedback, not a static label.

#### 5.2 Combo Counter

**Requirements:**

- **Position:** Centered on screen or right-of-center (prominent but not blocking player action)
- **Format:** "COMBO x15" (word + multiplier) with actual damage multiplier below ("x1.5")
- **Color progression:**
  - 1-2 hits: Muted (grey, 0.5 alpha)
  - 3-4 hits: character yellow (#FED90F)
  - 5-7 hits: Orange (#FF9500)
  - 8+ hits: Red (#FF0000) with pulsing glow
- **Size scaling:** Base font (36px) + 2px per combo hit (so 10-hit combo = 56px)
- **Animation:** Pop effect on increment (scale 1.5x → 1.0x over 0.1s), color transition smooth

**Timeout rules:**

- **Reset on damage:** Combo drops to 0 when player takes damage
- **Reset on time:** If >2 seconds since last hit, combo decays
- **Fast fade-out:** When combo resets, alpha falls to 0 over 0.25s

**firstPunch implementation:**
- `comboGlowTime` tracks when last hit occurred
- `displayCombo` lerps toward actual combo for smooth visual update
- Glow pulse uses sine wave oscillation on `shadowBlur`
- Multiplier formula: 1.0 + (comboCount * 0.1) up to 5x cap

#### 5.3 Score Display

**Requirements:**

- **Zero-padded counter:** Always 7 digits (e.g., "0001234")
- **Label:** "SCORE" text above or to the side
- **Rolling animation:** When score increases, animate from old value to new value over 0.5-1.0s (not instant jump)
- **Increment formula:** Each frame: `displayedScore += (targetScore - displayedScore) * 0.12` (smooth acceleration)
- **Color:** character yellow (#FED90F) with dark outline for readability

**Anti-pattern:** Instant score jump. Animated tick-up (rolling counter) is arcade tradition and feels more rewarding.

#### 5.4 Health Bars

**Player health bar:**

- **Always visible:** Never fade or hide
- **Position:** Top-left or center-top (primary focus area, per information hierarchy)
- **Size:** 150-200px wide × 20-30px tall (readable, not huge)
- **Format:** 
  - Dark background with rounded corners
  - Green fill that depletes left-to-right (or transitions yellow → orange → red as health drops)
  - Optional: Health text label ("HEALTH: 75/100")
- **Animation:** Smooth lerp of fill width over 0.2s when damage taken (instant health drop looks janky)
- **Flash effect:** White flash or inversion during 1-frame of damage (visual confirmation)

**Enemy health bars (conditional):**

- **Only visible when damaged:** Enemies at full health show no bar
- **Position:** Above enemy head, offset by camera position to stay world-locked
- **Size:** 30-50px wide × 4-6px tall (small, not distracting)
- **Color:** Red background + green fill (simple, clear)
- **Auto-fade:** Disappear 3-5 seconds after last damage (player doesn't need ongoing awareness)
- **Boss exception:** Boss health bars can be permanent and larger (150px), positioned top-center

**Anti-pattern (firstPunch lesson):** Fixed-width bar that doesn't scale with damage taken (player can't judge how much damage they did). Bars must be proportional.

#### 5.5 Progress / Wave Indicators

**Visual pattern:**

```
●  ●  ●  ●  ●  (dots or circles)
█  ⊙  ○  ○  ○  (filled / pulsing / outlined)
```

- **Completed waves:** Filled solid circle (e.g., yellow)
- **Current wave:** Pulsing outline with expanding ring animation
- **Remaining waves:** Grey outline
- **Label:** "WAVE" text below dots

**Position:** Top-center of screen, small (not intrusive)

**Rules:**

- **Update immediately on wave change:** No animation delay on completion
- **Pulsing effect:** Ring expands from center over 0.5s, repeats continuously during current wave
- **Max 5-10 waves per level:** More than that and dots become unreadable (switch to progress bar instead)

**Anti-pattern:** Using same visual for all states (player can't distinguish completed vs pending).

### 6. Responsive Design for Games

The #1 challenge in game UI: screens are not all the same size. 16:9, 16:10, 4:3, 21:9, mobile — all possible.

#### 6.1 Canvas Scaling and Letterboxing

**Golden rule:** Design at a reference resolution (e.g., 1280×720), then scale proportionally.

**Setup pattern:**

```javascript
// 1. Set CSS to fill viewport
const canvas = document.querySelector('#gameCanvas');
canvas.style.width = '100%';
canvas.style.height = '100%';

// 2. Match canvas resolution to window, respecting devicePixelRatio
function resizeCanvas() {
    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    
    const ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
    
    // 3. Letterbox or pillarbox to maintain aspect ratio
    const refAspect = 1280 / 720;  // 16:9
    const actualAspect = rect.width / rect.height;
    
    if (actualAspect > refAspect) {
        // Window is wider than ref: pillarbox (black bars left/right)
        viewport.width = rect.height * refAspect;
        viewport.height = rect.height;
        viewport.x = (rect.width - viewport.width) / 2;
        viewport.y = 0;
    } else {
        // Window is taller than ref: letterbox (black bars top/bottom)
        viewport.width = rect.width;
        viewport.height = rect.width / refAspect;
        viewport.x = 0;
        viewport.y = (rect.height - viewport.height) / 2;
    }
}

window.addEventListener('resize', resizeCanvas);
resizeCanvas();
```

**Key rules:**

- **DPR scaling is non-negotiable:** Without it, your game looks blurry on HiDPI (Retina) displays. This is the #1 visual quality issue.
- **Aspect ratio preservation:** Always maintain 16:9 (or your chosen ratio) to prevent distortion.
- **Letterbox over distortion:** If screen doesn't match your aspect, add black bars rather than stretch/squash the game.

**Anti-pattern (firstPunch lesson):** Skipping DPR scaling makes text and procedural art look cheap on modern monitors. Always set `ctx.scale(dpr, dpr)` after resizing.

#### 6.2 HUD Layout for Different Aspect Ratios

**16:9 (standard):**
```
┌─────────────────────────┐
│ Health  │        │  Score
│ (left)  │ GAME   │  (right)
│         │  AREA  │
└─────────────────────────┘
```

**16:10 (slightly taller):**
- Same as 16:9, but more vertical space below action area (use for Tier 3 info)

**4:3 (boxy):**
- Health and score move closer to center to fit safe zone
- Thin vertical gameplay area in center (pillarbox effect)
- Combo counter and damage numbers still center-positioned

**21:9 (ultrawide):**
- Menu items and action prompts still center-positioned
- Minimap or secondary info panels can expand into left/right "extra" space

**Mobile / Tall (portrait):**
- Flip layout to vertical: health at top, score below, action area centered
- Menu items stack vertically
- NOT SUPPORTED for action games (requires gamepad/keyboard; mobile users don't play beat 'em ups)

**Rule:** Always test at aspect ratios 4:3, 16:9, 16:10, and 21:9. Tablet tests too if supporting mobile.

#### 6.3 Text Sizing for Readability

**Minimum text sizes (logical, before DPR scaling):**

| Element | Min Size | Typical | When < Min |
|---------|----------|---------|-----------|
| Menu items | 12px | 16-20px | Illegible on phones; skip mobile |
| HUD labels (SCORE, HEALTH) | 10px | 12-14px | Will be hard to read |
| Health values (e.g., "75/100") | 10px | 11-12px | Borderline |
| Damage numbers | 20px | 24-28px | Too small to see in chaos |
| Title text | 40px | 60-80px | Wastes screen space |

**Scaling formula for responsive text:**

```javascript
// Scale text based on viewport height
const baseHeight = 720;  // your reference height
const screenHeight = viewport.height;
const scale = screenHeight / baseHeight;

// Apply to font sizes
const labelFontSize = Math.max(10, 12 * scale);  // never smaller than 10px
const titleFontSize = Math.max(40, 76 * scale);  // never smaller than 40px
```

**Anti-pattern:** Hardcoded pixel sizes that don't scale. Text that works at 1920×1080 will be tiny at 1280×720.

### 7. Animation & Transitions

Every menu transition, HUD element entrance, and state change should animate. Instant cuts feel cheap.

#### 7.1 Menu Transitions

**Fade transition (most common):**

```javascript
// Out of current menu
for frame in 0..30:
    alpha = 1.0 - (frame / 30)
    renderMenu(alpha)

// Switch scene

// Into new menu
for frame in 0..30:
    alpha = frame / 30
    renderMenu(alpha)
```

**Duration:** 0.3-0.5 seconds (300-500ms). Longer feels sluggish; shorter feels jarring.

**Slide transition (more polished):**

```javascript
// Slide out left, slide in from right
const direction = -1;  // -1 = left, 1 = right
for frame in 0..30:
    t = frame / 30;
    offsetX = direction * (1 - t) * 500;  // 500px slide distance
    alpha = 1 - t;
    renderMenuAt(offsetX, alpha);
```

**Scale + fade transition (bouncy):**

```javascript
// Scale up + fade in with ease-out
for frame in 0..20:
    t = frame / 20;
    easeOut = 1 - (1 - t) * (1 - t);  // ease-out curve
    scale = 0.8 + (easeOut * 0.2);  // scale from 0.8x to 1.0x
    alpha = easeOut;
    ctx.scale(scale, scale);
    renderMenu(alpha);
```

**Anti-pattern:** Instant menu swap. Games that cut instantly between screens feel unpolished, even if everything else is perfect.

#### 7.2 HUD Element Animations

**Entrance animation (new UI element appears):**

```javascript
// Slide in from top, fade
const slideDistance = 50;
const duration = 0.3;
for frame in 0..18:
    t = frame / 18;
    offsetY = -slideDistance * (1 - t);  // slide from -50px to 0
    alpha = t;
    renderElement(offsetY, alpha);
```

**Exit animation (UI element disappears):**

```javascript
// Fade + scale down
const duration = 0.25;
for frame in 0..15:
    t = frame / 15;
    scale = 1 - (t * 0.3);  // scale from 1.0 to 0.7
    alpha = 1 - t;
    renderElement(scale, alpha);
```

**Emphasis animation (highlight a change):**

```javascript
// Pulse using sine wave
amplitude = 0.1;  // ±10% scale
for frame in 0..60:
    t = (frame / 60) * Math.PI * 2;  // full cycle
    scale = 1 + (Math.sin(t) * amplitude);
    renderElement(scale);
```

**Button feedback:**

```javascript
// Press feedback: scale down on press, scale up on release
if (buttonPressed) {
    scale = 0.95;  // pressed state
} else {
    scale = 1.0;   // default
}
// Smooth transition over 0.1s
currentScale += (targetScale - currentScale) * 0.1;
renderButton(currentScale);
```

**Anti-pattern:** Animations longer than 0.5s feel sluggish. Keep transitions snappy (0.2-0.3s is ideal).

### 8. Accessibility Basics

Good accessibility makes games better for EVERYONE, not just players with disabilities.

#### 8.1 Color Blind Modes

**Protanopia (Red Blind):** Can't see red; sees world as blue-yellow spectrum.
- **Problem:** Red vs green health bar indistinguishable
- **Solution:** Use blue/yellow instead of red/green; or add patterns (striped vs solid)

**Deuteranopia (Green Blind):** Can't see green; sees world as red-blue spectrum.
- **Problem:** Green combo counter vs neutral background hard to see
- **Solution:** Increase contrast; use magenta/cyan or red/blue combinations

**Tritanopia (Blue Blind, rare):** Can't see blue.
- **Problem:** Blue UI on white background nearly invisible
- **Solution:** Avoid blue entirely; use red/green/yellow

**Design rule: Never use color alone to convey information.**

```javascript
// WRONG: Color-only feedback
if (damaged) {
    barColor = '#FF0000';  // only change is color
}

// RIGHT: Color + symbol feedback
if (damaged) {
    barColor = '#FF0000';
    drawIcon('⚠');  // add symbol
    playDamageSFX();  // add audio
}
```

**Colorblind mode implementation:**

```javascript
// Settings option toggles this
if (settings.colorblindMode === 'deuteranopia') {
    HEALTH_BAR_COLOR = '#0066FF';  // blue instead of green
    DAMAGE_COLOR = '#FF9900';  // orange instead of red
    COMBO_COLOR = '#FFFF00';  // yellow stays yellow
}
```

#### 8.2 Text Readability

**Contrast ratio (WCAG standard for games):**

- **7:1** — AAA standard (excellent, highly legible)
- **4.5:1** — AA standard (good, meets minimum)
- **3:1** — Minimum (avoid if possible)

**Check contrast:** Use WebAIM contrast checker (put hex codes in, get ratio).

**Common failures:**

| Combination | Ratio | Verdict |
|---|---|---|
| Yellow text on white | 1.07:1 | ✗ UNREADABLE |
| Dark grey on black | 2.1:1 | ✗ FAIL |
| White on dark blue | 5.5:1 | ✓ PASS |
| White on black | 21:1 | ✓ EXCELLENT |

**Text rendering best practices:**

```javascript
// 1. Use outline (stroke) for readability over any background
ctx.lineWidth = 3;
ctx.strokeStyle = '#000000';
ctx.lineJoin = 'round';
ctx.strokeText('TEXT', x, y);

// 2. Fill with high-contrast color
ctx.fillStyle = '#FFFFFF';
ctx.fillText('TEXT', x, y);

// 3. Never render text smaller than 10px logical (12px for main UI)
const minSize = 10;
const fontSize = Math.max(minSize, baseSize * scale);

// 4. Use sans-serif fonts (easier to read on screens than serif)
ctx.font = `bold ${fontSize}px Arial, sans-serif`;
```

#### 8.3 Button Prompts and Control Scheme Display

**Mandatory:** Show what buttons do, in the player's current control scheme.

```javascript
// Detect control scheme
const controls = detectGamepad() ? 'gamepad' : 'keyboard';

// Display appropriate button image/text
if (controls === 'keyboard') {
    drawButtonPrompt('SPACE', 'Jump');  // show key cap
    drawButtonPrompt('J or Z', 'Punch');
} else {
    drawButtonPrompt('A', 'Jump');  // Xbox button labels
    drawButtonPrompt('X', 'Punch');
}
```

**Button prompt format:**

```
[KEY_CAP_IMAGE] ACTION_NAME
```

- Key cap: Render as small rounded rectangle with letter inside (or use controller button image)
- Action name: Text description of what button does
- Position: At bottom of menu, above navigation hints

**firstPunch example:**
```
Movement: WASD / Arrow Keys
Punch: J or Z
Kick: K or X
Jump: SPACE
Special: E
```

#### 8.4 Subtitle and Caption Support

**When to include subtitles:**

- Any voiced dialogue (NPC conversations)
- Ambient VO (radio chatter, announcements)
- Critical story moments
- Boss intros / cutscenes

**Format:**

```
Speaker: "Dialogue text in game language."
[SOUND DESCRIPTION if no dialogue]
```

**Example:**

```
Brawler: "Ugh!"
[explosion sound]
Defender: "Brawler, be careful!"
```

**Implementation:**

```javascript
if (settings.subtitles === true) {
    displaySubtitle(currentDialog.speaker, currentDialog.text);
}
```

**Rule:** Captions are for hearing-impaired players. Always include them as an option.

### 9. Anti-Patterns

Mistakes that break UI/UX, learned from firstPunch and industry observation.

#### 9.1 "UI Overload"

**The problem:** Showing all information at once makes the screen overwhelming.

**Example:**
```
HEALTH: 75/100 | MANA: 50/100 | STAMINA: 90/100 | XP: 3450/5000
SCORE: 012450 | COMBO: x15 | MULTIPLIER: x2.3 | WAVE: 3/5
ABILITY_1: (cooldown) | ABILITY_2: (cooldown) | ABILITY_3: (cooldown)
```

**Fix:** Apply information hierarchy (section 1). Show only Tier 1 (health) and Tier 2 (current action resource). Hide the rest until needed.

**Result:**
```
HEALTH: 75/100 | COMBO: x15
```
(Cleaner, faster to glance, less cognitive load)

#### 9.2 "Invisible State"

**The problem:** Player doesn't know what's happening — no visual feedback.

**Examples:**
- Button press with no response (no highlight, no SFX)
- Damage dealt with no numbers or effect
- Combo broken with no warning
- Health gone with no death animation

**Fix:** Every significant state change needs feedback (visual + audio).

```javascript
// BAD: No feedback
if (buttonPressed('attack')) {
    player.dealDamage(target);  // no SFX, no VFX
}

// GOOD: Full feedback
if (buttonPressed('attack')) {
    player.dealDamage(target);
    vfx.spawnImpactSpark(target.x, target.y);
    audio.playHitSound(damageAmount);
    renderer.shake(2, 3);
    damageNumbers.spawn(target.x, target.y, damageAmount);
}
```

#### 9.3 "Modal Trap"

**The problem:** Player opens a menu and can't easily get back (unclear how to exit, no visible back button, confusing navigation).

**Examples:**
- Inventory menu with no "close" button
- Submenu that doesn't support ESC
- Dialog box that requires clicking a button to dismiss (on consoles with no mouse)

**Fix:** Every menu must have an obvious exit method.

```javascript
// Good: Clear exit paths
const pauseMenu = {
    options: ['Resume (ESC)', 'Options (O)', 'Quit (Q)'],
    handleInput(input) {
        if (input.isEscape()) { game.resume(); }
        if (input.isKey('o')) { switchScene('options'); }
        if (input.isKey('q')) { switchScene('title'); }
    }
};
```

**Rule:** ESC should ALWAYS close the current menu and return to the previous state.

#### 9.4 "Mouse-First Action Game"

**The problem:** UI requires mouse interaction in an action game. Players are fighting AND managing menus = impossible.

**Example:**
- Pause menu with clickable buttons (no keyboard support)
- Ability slots requiring mouse hover
- Skill tree requiring precise mouse clicks

**Fix:** Keyboard/gamepad must be primary. Mouse is optional.

```javascript
// WRONG: Mouse-dependent
const menuItem = document.querySelector('.menu-option');
menuItem.addEventListener('click', () => { /* select */ });

// RIGHT: Input-agnostic
const menuItem = {
    onSelect: () => { /* select */ },
    handleInput(input) {
        if (input.wasPressed('select')) { this.onSelect(); }
    }
};
```

#### 9.5 "Unscaled HUD"

**The problem:** HUD elements are hardcoded to pixel positions, so they disappear or overlap when aspect ratio changes.

**Example:**
- Health bar only visible on 16:9 screens
- Score text overlaps with combo text on 4:3 aspect ratio

**Fix:** All HUD layout should be responsive (see section 6.1).

```javascript
// WRONG: Hardcoded positions
ctx.drawText('HEALTH', 20, 20);
ctx.drawBar(20, 40, 150, 30);  // bar at specific pixels

// RIGHT: Position relative to viewport
const margin = viewport.width * 0.02;  // 2% margin
const labelX = margin;
const labelY = margin;
ctx.drawText('HEALTH', labelX, labelY);
ctx.drawBar(labelX, labelY + 20, viewport.width * 0.2, 30);
```

#### 9.6 "No Input Feedback"

**The problem:** Menu navigation feels sluggish because there's no audio feedback.

**Example:**
- Player presses UP arrow 10 times and hears nothing
- Selecting an option produces no sound

**Fix:** Play SFX on navigation and selection.

```javascript
if (input.wasPressed('up')) {
    menuIndex = (menuIndex - 1 + menuItems.length) % menuItems.length;
    audio.playMenuSelect();  // ← add this
}

if (input.wasPressed('select')) {
    selectMenuItem(menuIndex);
    audio.playMenuConfirm();  // ← add this
}
```

**Anti-pattern (firstPunch lesson):** Early menus had no audio. Added SFX and menu navigation instantly felt tighter and more responsive.

#### 9.7 "Instant State Changes"

**The problem:** UI elements appear/disappear instantly, feeling disruptive.

**Example:**
- Health bar vanishes instantly when healing
- Combo counter appears instantly on first hit
- Game over overlay cuts in with no fade

**Fix:** Animate all state changes (see section 7).

```javascript
// WRONG: Instant appearance
if (enemyDefeated) {
    hud.showEnemyDefeated = true;  // instant
}

// RIGHT: Fade in
if (enemyDefeated) {
    hud.enemyDefeatedTimer = 0;
    hud.enemyDefeatedAlpha = 0;
    // Then animate: enemyDefeatedAlpha += dt; if reaches 1, mark visible
}
```

### 10. firstPunch Learnings

What we built, what worked, what we'd improve.

#### Built & Shipped

✓ **Arcade-style HUD:** Health bar (with gradient fill and glossy highlight), score display (with rolling counter animation), lives display (with mini Brawler icons)

✓ **Combo/Style Meter:** Vertical style meter (22×100px) with 5 retro-themed thresholds and 5x multiplier on "Best. Combo. Ever."

✓ **Title Screen:** Gradient sky, scrolling skyline, Brawler silhouette, yellow star particles, menu selection system, high score display with ★ decorations

✓ **Pause Menu:** ESC toggle (instant response), "Press O for Options", "Press Q for Quit", dark overlay

✓ **Options Menu:** 3 volume sliders, difficulty selector, read-only controls display, BACK button with pulsing indicator

✓ **Game Over Screen:** "GAME OVER" text, final score, high score comparison ("NEW HIGH SCORE!"), 0.5s input delay to prevent accidental skip

✓ **Level Intro Text:** "STAGE 1" + "DOWNTOWN" with fade-in/out over 2s

✓ **Enemy Health Bars:** Appear when damaged (red background + green fill), auto-fade 3s after last hit, scale-proportional to health

✓ **Wave Progress Indicator:** Dots at top-center (filled = completed, pulsing = current, grey = remaining)

✓ **HiDPI Support:** DPR scaling, crisp text rendering, no blurriness on Retina displays

✓ **High Score Persistence:** localStorage with try/catch for private browsing graceful fallback

#### What Worked Well

1. **Glance-test hierarchy:** 5 seconds into gameplay, player instantly knows health/combo/score/progress
2. **HUD panels with semi-transparent dark backgrounds:** Massive readability improvement
3. **Score rolling animation:** Players feel reward more viscerally than instant jump
4. **Combo glow pulse:** Sine-wave oscillation on shadowBlur makes combo feel "alive" when building
5. **Menu sound effects:** Toggling play/pause/options instant 50% increase in perceived responsiveness
6. **Button press scale feedback:** 0.95x scale on press, return on release — feels satisfying without being exaggerated
7. **Letterboxing at 16:9 aspect ratio:** Preserved game design integrity on all screen sizes

#### What We'd Improve / Lessons Learned

1. **Boss health bar separate from enemies:** Enemies have small bars; boss should have larger, always-visible bar at top-center with name label. Current code treats all enemy bars identically.

2. **Accessibility audit:** No formal colorblind testing. We assumed color palette worked for deuteranopia (orange/yellow/red) but never validated.

3. **Subtitle system:** No dialogue in game, so skipped captions. But framework exists for future games.

4. **Rebindable controls:** Currently hardcoded. Settings menu shows keys but can't change them. Should be priority for next action game.

5. **Loading screen:** No load time currently, but framework needed for future projects. Should show tips or mini-game during load.

6. **Text sizing algorithm:** Used static logical pixel sizes. Should have had responsive scaling formula for better mobile support (though game doesn't target mobile).

7. **Drag-and-drop UI:** No inventory or drag-able UI elements. Would need mouse support (accepted limitation for action game).

8. **Tutorial/onboarding:** Jumped straight to title screen. Should have intro sequence teaching controls. Options menu shows keys but no in-game tutorial.

---

## Checklist: Before Shipping Any UI

- [ ] Information hierarchy clear (Tier 1 obvious, Tier 4 hidden)
- [ ] All important state has visual feedback (health change, damage, combo change)
- [ ] All state changes animated (no instant cuts)
- [ ] HUD readable on 4:3, 16:9, 16:10, 21:9 aspect ratios
- [ ] Text minimum 10px logical size (12px for main UI)
- [ ] Text contrast ratio ≥4.5:1 (WCAG AA minimum)
- [ ] All menu navigation works with keyboard/gamepad (mouse optional)
- [ ] ESC closes menus and returns to previous state
- [ ] Menu selection has audio feedback (SFX on navigate, on confirm)
- [ ] Button presses have visual feedback (highlight, scale, or glow)
- [ ] Pause menu available on ESC during gameplay
- [ ] Game state preserved during pause (no loss of score, enemies, progress)
- [ ] Game over screen shows score and high score
- [ ] HUD elements use rounded corners and semi-transparent panels (consistent style)
- [ ] DPR scaling applied (HiDPI support)
- [ ] Colorblind mode exists (even if basic: swap colors, add icons/patterns)
- [ ] Button prompts display current control scheme (keyboard vs gamepad)

---

## Anti-Pattern Checklist: Things NOT to Do

- [ ] ✗ Showing all information equally sized (fix: apply hierarchy)
- [ ] ✗ State change with no feedback (fix: add VFX + SFX + animation)
- [ ] ✗ Menu that's hard to exit (fix: ESC always goes back)
- [ ] ✗ Mouse-first UI in action game (fix: keyboard/gamepad primary)
- [ ] ✗ Hardcoded HUD positions (fix: responsive layout)
- [ ] ✗ Menu navigation with no SFX (fix: play sounds on input)
- [ ] ✗ Instant UI state changes (fix: fade/slide animations)
- [ ] ✗ Color-only information (fix: add icons, patterns, or symbols)
- [ ] ✗ Text below 10px logical (fix: scale responsively)
- [ ] ✗ No DPR scaling (fix: apply `ctx.scale(dpr, dpr)`)

---

## Examples from firstPunch

### Good: HUD Layout with Information Hierarchy

```javascript
// Tier 1: Health (always visible, primary)
hud.render(ctx, player, enemies) {
    const healthBarX = 22;
    const healthBarY = 22;
    const healthBarWidth = 150;
    // ... draw health bar (largest, brightest)
    
    // Tier 2: Combo (secondary, pulsing)
    const comboX = viewport.width / 2;
    const comboY = 60;
    // ... draw combo counter (medium size, glow effect)
    
    // Tier 3: Score (visible but muted)
    const scoreX = viewport.width - 180;
    const scoreY = 22;
    // ... draw score (smaller, less saturated)
    
    // Tier 3: Wave progress (top center, minimal)
    const waveX = viewport.width / 2 - 50;
    const waveY = 20;
    // ... draw wave dots (tiny, low importance)
}
```

### Good: Responsive Text Sizing

```javascript
function drawCrispText(ctx, text, x, y, fontSize, color, options = {}) {
    const minSize = options.minSize || 10;
    const finalSize = Math.max(minSize, fontSize);
    
    ctx.save();
    ctx.font = `bold ${finalSize}px Arial, sans-serif`;
    ctx.fillStyle = color;
    ctx.textAlign = options.align || 'left';
    ctx.textBaseline = options.baseline || 'top';
    
    // Snap to integer pixel for crispness
    const finalX = Math.round(x);
    const finalY = Math.round(y);
    
    if (options.stroke) {
        ctx.strokeStyle = options.strokeColor || '#000000';
        ctx.lineWidth = options.strokeWidth || 2;
        ctx.strokeText(text, finalX, finalY);
    }
    ctx.fillText(text, finalX, finalY);
    ctx.restore();
}
```

### Good: Menu Navigation with Feedback

```javascript
class TitleScene {
    onEnter(audio) {
        this.audio = audio;
        this.menuIndex = 0;
        this.menuItems = ['START GAME', 'OPTIONS'];
    }
    
    handleInput(input) {
        if (input.isMovingUp()) {
            this.menuIndex = (this.menuIndex - 1 + this.menuItems.length) % this.menuItems.length;
            this.audio.playMenuSelect();
        }
        if (input.isMovingDown()) {
            this.menuIndex = (this.menuIndex + 1) % this.menuItems.length;
            this.audio.playMenuSelect();
        }
        if (input.wasPressed('select')) {
            this.selectMenu(this.menuIndex);
            this.audio.playMenuConfirm();
        }
    }
    
    selectMenu(index) {
        if (index === 0) {
            game.switchScene('gameplay');
        } else if (index === 1) {
            game.switchScene('options');
        }
    }
}
```

---

## Cross-Game Applicability

This skill transfers directly to:

- **RPGs:** HUD applies (health, mana, abilities, inventory)
- **Puzzle games:** Information hierarchy applies (remaining moves, score, best time)
- **Platformers:** Simple HUD (health, collectibles) + pause menu
- **Strategy games:** Complex HUD required (unit status, resources, map) — scale hierarchy accordingly
- **Roguelikes:** Combo counter becomes "run timer", health bar stays the same
- **Racing games:** HUD is gear, speed, position — different Tier structure but same principles apply

The framework adapts; the principles remain constant.
