# visual-modernization-plan.md — Full Archive

> Archived version. Compressed operational copy at `visual-modernization-plan.md`.

---

# Visual Modernization Plan — firstPunch
**Author:** Boba (VFX/Art Specialist)  
**Date:** 2026-06-03  
**Status:** Active

---

## Executive Summary

**Gap:** The game reads as "retro-themed programmer art" rather than a "modern beat 'em up game with current graphics." While recent improvements (consistent 2px outlines, proper character shapes, Downtown background, VFX system) elevated visual quality from 30% to ~60%, significant gaps remain in character detail, animation, visual feedback, and UI polish.

**Target:** Arcade-quality 2D game beat 'em up — clean, readable, unmistakably game. Think *classic arcade beat 'em ups Game* (1991) updated with modern Canvas 2D techniques: bezier curves for organic shapes, gradients for depth, layered shading, smooth animation, particle effects, and polished UI.

**Implementation approach:** Canvas 2D API with bezier curves, quadratic curves, gradient fills, composite operations, and transform matrices. No external images — all procedural.

---

## 1. BRAWLER (Player Character)

### Current State
**Achieved (Wave 2):**
- ✅ 2px #222222 outlines on all body parts
- ✅ M-shaped hair (3 brown triangle spikes)
- ✅ Proper eyes (white sclera + black pupils, separately outlined)
- ✅ Overbite bump below chin
- ✅ Belly uses quadraticCurveTo for bulge
- ✅ Royal blue pants, off-white shirt, brown shoes
- ✅ Highlight layer on belly

**Remaining gaps:**
- **Stubble:** Brawler has a perpetual 5 o'clock shadow on his chin — not rendered
- **Ears:** No ears visible (game characters have small rounded ears at head sides)
- **Hands:** Arms end abruptly — no defined hands/fingers (should be 3-fingered gloves)
- **Body proportions:** Head-to-body ratio ~1:2.5 specified in art-direction, but current measurements are ~40px head on 80px total height = 1:2 ratio (head too big)
- **Animation:** Arm bob is simple sine wave — no squash/stretch, no anticipation, no secondary motion
- **Walk cycle:** State changes to 'walk' but visual is identical to idle (legs don't animate)
- **Shirt details:** No collar, no pocket, flat color only
- **Facial expression:** Mouth is static arc — no variation for states (idle smile vs attack grimace)

### Target State
Brawler should read as **unmistakably the Brawler** at a glance:
- Iconic silhouette: beer gut, overbite, M-hair, stubble, short limbs
- Recognizable colors: #FED90F skin, #F5F5F5 shirt, #4169E1 pants
- Expressive animation: squash on landing, stretch on jump, anticipation before attacks
- Clean modern rendering: smooth bezier curves, gradient shading, crisp outlines

### Implementation Plan

#### 1.1 Stubble (Chin Shadow)
**Gap:** Brawler's 5 o'clock shadow is a key character trait — missing.

**Canvas technique:**
```javascript
// In player.js render(), after overbite bump
// Small arc of dots along jawline
ctx.fillStyle = '#888888';
const stubbleY = 32;
for (let sx = 28; sx <= 36; sx += 2) {
    const yOffset = Math.abs(sx - 32) * 0.15; // arc follows jawline
    ctx.beginPath();
    ctx.arc(sx, stubbleY + yOffset, 0.8, 0, Math.PI * 2);
    ctx.fill();
}
```

**Effort:** 10 min — simple loop of small circles along jaw curve

---

#### 1.2 Ears
**Gap:** Brawler needs small rounded ears at head sides for IP authenticity.

**Canvas technique:**
```javascript
// In player.js render(), before eyes
// Left ear
ctx.fillStyle = '#FED90F';
ctx.beginPath();
ctx.arc(18, 20, 5, -0.5, 1.5); // half-circle on left side
ctx.fill();
ctx.stroke();
// Right ear
ctx.beginPath();
ctx.arc(46, 20, 5, Math.PI - 0.5, Math.PI + 1.5);
ctx.fill();
ctx.stroke();
// Inner ear detail (darker shade)
ctx.fillStyle = '#E8C000';
ctx.beginPath();
ctx.arc(19, 21, 2, 0, Math.PI * 2);
ctx.fill();
ctx.beginPath();
ctx.arc(45, 21, 2, 0, Math.PI * 2);
ctx.fill();
```

**Effort:** 15 min — two half-circles with inner detail arcs

---

#### 1.3 Hands (3-Fingered Cartoon Gloves)
**Gap:** Arms end abruptly — Brawler should have defined 3-fingered hands.

**Canvas technique:**
```javascript
// Replace current arm rectangle drawing with:
// Right arm (from elbow to hand)
ctx.fillStyle = '#FED90F';
ctx.beginPath();
ctx.rect(46, 40 - armBob, 8, 15);
ctx.fill();
ctx.stroke();

// Right hand (3 fingers)
ctx.beginPath();
// Palm
ctx.arc(50, 56 - armBob, 4, 0, Math.PI * 2);
ctx.fill();
ctx.stroke();
// 3 sausage fingers
ctx.fillRect(48, 57 - armBob, 2, 4);
ctx.fillRect(50, 58 - armBob, 2, 4);
ctx.fillRect(52, 57 - armBob, 2, 4);
ctx.stroke();

// Repeat for left arm
```

**Effort:** 30 min — apply to both arms, adjust during all attack animations

---

#### 1.4 Facial Expressions (State-Driven Mouths)
**Gap:** Mouth is static — should react to state (smile when idle, grimace when attacking, "Ugh!" when hit).

**Canvas technique:**
```javascript
// In player.js render(), replace static mouth with:
ctx.strokeStyle = '#222222';
ctx.lineWidth = 1.5;

if (this.state === 'hit' || this.state === 'dead') {
    // Ugh! mouth (O-shape)
    ctx.beginPath();
    ctx.arc(32, 28, 4, 0, Math.PI * 2);
    ctx.stroke();
} else if (this.state === 'punch' || this.state === 'kick' || 
           this.state === 'belly_bump' || this.state === 'ground_slam') {
    // Aggressive grimace (wide arc, teeth clenched)
    ctx.beginPath();
    ctx.arc(32, 27, 6, 0.2, Math.PI - 0.2);
    ctx.stroke();
    // Teeth line
    ctx.beginPath();
    ctx.moveTo(27, 29);
    ctx.lineTo(37, 29);
    ctx.stroke();
} else {
    // Idle smile (current implementation)
    ctx.beginPath();
    ctx.arc(32, 27, 5, 0.15, Math.PI - 0.15);
    ctx.stroke();
}
// Overbite bump code remains below mouth
```

**Effort:** 20 min — 3 mouth variants tied to state

---

#### 1.5 Walk Cycle Animation
**Gap:** Walk state exists but legs don't animate — Brawler slides on locked legs.

**Canvas technique:**
```javascript
// In player.js render(), replace static legs/shoes with:
if (this.state === 'walk') {
    const legPhase = Math.sin(this.animTime * 10);
    const leftLegY = 65;
    const rightLegY = 65;
    
    // Left leg (forward/back bob)
    ctx.fillStyle = '#4169E1';
    ctx.save();
    ctx.translate(22, leftLegY);
    ctx.rotate(legPhase * 0.15); // swing forward/back
    ctx.fillRect(-4, 0, 8, 13);
    ctx.fill();
    ctx.stroke();
    ctx.restore();
    
    // Left shoe
    ctx.fillStyle = '#8B4513';
    ctx.fillRect(16 + legPhase * 3, 78, 14, 5);
    ctx.stroke();
    
    // Right leg (opposite phase)
    ctx.fillStyle = '#4169E1';
    ctx.save();
    ctx.translate(38, rightLegY);
    ctx.rotate(-legPhase * 0.15);
    ctx.fillRect(-4, 0, 8, 13);
    ctx.fill();
    ctx.stroke();
    ctx.restore();
    
    // Right shoe
    ctx.fillStyle = '#8B4513';
    ctx.fillRect(34 - legPhase * 3, 78, 14, 5);
    ctx.stroke();
} else {
    // Static legs (current idle drawing)
    // ... existing code ...
}
```

**Effort:** 45 min — animated legs + shoes with phase-offset sine wave

---

#### 1.6 Body Proportions Adjustment
**Gap:** Head is too large relative to body (1:2 instead of 1:2.5).

**Fix:**
- Increase body height from 80px to 90px (head remains 40px → 1:2.25 ratio, closer to spec)
- Adjust all y-coordinates in render() proportionally
- Update this.height in constructor to 90

**Canvas technique:** Arithmetic adjustment to all hard-coded y values.

**Effort:** 30 min — careful coordinate adjustment across all body parts + attack animations

---

#### 1.7 Shirt Details (Collar + Pocket)
**Gap:** Shirt is flat white blob — needs collar and pocket for detail.

**Canvas technique:**
```javascript
// In player.js render(), after shirt fill+stroke
// Collar (V-shape at neck)
ctx.strokeStyle = '#DDDDDD';
ctx.lineWidth = 1.5;
ctx.beginPath();
ctx.moveTo(24, 36);
ctx.lineTo(32, 40);
ctx.lineTo(40, 36);
ctx.stroke();

// Pocket (small rectangle on upper-left chest)
ctx.strokeStyle = '#DDDDDD';
ctx.lineWidth = 1;
ctx.beginPath();
ctx.rect(20, 42, 6, 6);
ctx.stroke();
```

**Effort:** 10 min — two small path segments

---

#### 1.8 Squash/Stretch on Jump Land
**Gap:** Jump land has no impact — Brawler should squash on landing for juice.

**Canvas technique:**
```javascript
// In player.js render(), detect landing frame
const wasAirborne = this.prevJumpHeight > 0;
const justLanded = wasAirborne && this.jumpHeight === 0;

if (justLanded) {
    this.landSquashTime = 0.1; // 100ms squash
}

if (this.landSquashTime > 0) {
    this.landSquashTime -= dt; // decrement in update()
    const squashFactor = 1 - (this.landSquashTime / 0.1) * 0.2; // 80% → 100%
    ctx.scale(1 / squashFactor, squashFactor); // wider, shorter
}

this.prevJumpHeight = this.jumpHeight;
```

**Effort:** 20 min — add timer property, scale transform, track prev jump height

---

### Summary: Brawler Upgrades
**Total effort:** ~3 hours  
**Impact:** High — Brawler becomes instantly recognizable, expressive, and polished

---

## 2. ENEMIES

### Current State
**Achieved (Wave 2):**
- ✅ 2px #222222 outlines
- ✅ White sclera + black pupils (upgraded from flat black rects)
- ✅ Angry V-shaped eyebrows
- ✅ Tough variant gets red bandana
- ✅ Fast variant gets spiky hair
- ✅ Heavy variant gets crew cut + armor plate
- ✅ Fists at arm ends (4px circles)
- ✅ Extended attack fist (5px circle at reach)
- ✅ Highlights on head and body

**Remaining gaps:**
- **Character identity:** Enemies are "generic thugs" — should be recognizable Downtown citizens (Drunkard, thug, street thug, etc.) or clear archetypes (biker, mob goon, factory worker)
- **Body language:** All enemies stand identical — no slouch for drunk, no hunch for thug, no wide stance for heavy
- **Walk animation:** No leg movement during walk state (same as Brawler issue)
- **Clothing details:** Body is solid color — no shirt/pants distinction, no belt, no pockets
- **Attack anticipation:** Wind-up exists for heavy, but visual telegraph is weak (just red pulse)
- **Facial expressions:** Enemies never change expression — should grimace when attacking, wince when hit
- **Variant visual clarity:** Fast/tough/heavy/normal differentiated by color + one head detail — needs more (body shape, posture, accessories)

### Target State
Enemies should be **visually distinct Downtown archetypes**:
- Drunkard (drunk): slouched posture, beer belly, stubble, disheveled
- Tough (biker/thug): leather vest, bandana, muscular arms
- Fast (hooligan): lean, hoodie or cap, running pose
- Heavy (mob enforcer): wide stance, suit jacket, slicked hair

Each type should have **unique silhouette, posture, and details** so player recognizes them at a glance.

### Implementation Plan

#### 2.1 Drunkard (Normal Variant)
**Gap:** Normal enemy is "generic purple guy" — should be a recognizable character for Downtown authenticity.

**Canvas technique:**
```javascript
// Replace current normal enemy head with:
// Drunkard's balding head (fringe hair on sides)
ctx.fillStyle = '#FFB6C1'; // skin
ctx.beginPath();
ctx.arc(24, 18, 12, 0, Math.PI * 2);
ctx.fill();
ctx.stroke();

// Brown hair fringe (sides only — bald on top)
ctx.fillStyle = '#6B4423';
ctx.beginPath();
ctx.arc(14, 20, 4, -0.5, 1.5); // left fringe
ctx.fill();
ctx.stroke();
ctx.beginPath();
ctx.arc(34, 20, 4, Math.PI - 1.5, Math.PI + 0.5); // right fringe
ctx.fill();
ctx.stroke();

// Stubble (the drunkard always unshaven)
ctx.fillStyle = '#888888';
for (let sx = 18; sx <= 30; sx += 2) {
    ctx.beginPath();
    ctx.arc(sx, 24, 0.7, 0, Math.PI * 2);
    ctx.fill();
}

// Beer belly (bigger than current body)
ctx.fillStyle = '#7B3F00'; // brown shirt
ctx.beginPath();
ctx.moveTo(16, 30);
ctx.quadraticCurveTo(10, 50, 16, 65); // left side bulge
ctx.lineTo(32, 65);
ctx.quadraticCurveTo(38, 50, 32, 30); // right side bulge
ctx.closePath();
ctx.fill();
ctx.stroke();

// Slouched posture: translate y down by 3px before rendering
```

**Effort:** 45 min — redesign head, body, posture

---

#### 2.2 Tough Variant (Biker Thug)
**Gap:** Tough has bandana but otherwise identical to normal — needs leather vest, tattoos, muscular build.

**Canvas technique:**
```javascript
// Keep bandana, add:
// Leather vest (dark brown over beige tank top)
ctx.fillStyle = '#8B7355'; // beige tank
ctx.fillRect(16, 32, 16, 20);
ctx.stroke();

ctx.fillStyle = '#3A2010'; // dark leather vest (open front)
ctx.beginPath();
ctx.rect(14, 32, 6, 20); // left panel
ctx.fill();
ctx.stroke();
ctx.beginPath();
ctx.rect(28, 32, 6, 20); // right panel
ctx.fill();
ctx.stroke();

// Tattoo (skull outline on right bicep)
ctx.strokeStyle = '#000000';
ctx.lineWidth = 1;
ctx.beginPath();
ctx.arc(36, 42, 3, 0, Math.PI * 2);
ctx.stroke();
ctx.fillRect(34, 44, 4, 2); // jaw

// Thicker arms (9px width instead of 6px)
const armW = 9;
```

**Effort:** 30 min — vest panels, tattoo detail, arm width increase

---

#### 2.3 Fast Variant (Teen Hooligan)
**Gap:** Fast has spiky hair but body identical to normal — needs hoodie, lean build, forward-leaning posture.

**Canvas technique:**
```javascript
// Keep spiky hair, add:
// Hoodie (bright color, drawstrings)
ctx.fillStyle = '#FF6B35'; // orange hoodie
ctx.beginPath();
ctx.arc(24, 18, 14, 0.8, Math.PI - 0.8); // hood behind head
ctx.fill();
ctx.stroke();

ctx.fillRect(14, 28, 20, 30); // hoodie body
ctx.stroke();

// Drawstrings
ctx.strokeStyle = '#FFFFFF';
ctx.lineWidth = 1;
ctx.beginPath();
ctx.moveTo(20, 30);
ctx.lineTo(20, 36);
ctx.moveTo(28, 30);
ctx.lineTo(28, 36);
ctx.stroke();

// Lean build: reduce body width from 20px to 16px
// Forward-leaning posture: rotate entire body by -0.1 rad
ctx.save();
ctx.translate(24, 50);
ctx.rotate(-0.1);
// ... draw body ...
ctx.restore();
```

**Effort:** 35 min — hoodie shape, lean posture transform

---

#### 2.4 Heavy Variant (Mob Enforcer)
**Gap:** Heavy has crew cut + armor but reads as "green guy" — needs suit jacket, wide stance, intimidating bulk.

**Canvas technique:**
```javascript
// Keep crew cut, replace armor plate with:
// Suit jacket (dark grey, white shirt underneath)
ctx.fillStyle = '#4A4A4A'; // dark suit
ctx.beginPath();
ctx.rect(10, 30, 28, 35); // wider body (was 20px, now 28px)
ctx.fill();
ctx.stroke();

// White shirt collar
ctx.fillStyle = '#FFFFFF';
ctx.beginPath();
ctx.moveTo(18, 30);
ctx.lineTo(24, 34);
ctx.lineTo(30, 30);
ctx.lineTo(30, 36);
ctx.lineTo(18, 36);
ctx.closePath();
ctx.fill();
ctx.stroke();

// Tie
ctx.fillStyle = '#8B0000'; // dark red tie
ctx.beginPath();
ctx.moveTo(24, 34);
ctx.lineTo(22, 50);
ctx.lineTo(26, 50);
ctx.closePath();
ctx.fill();
ctx.stroke();

// Wide stance: legs spread 4px wider apart
ctx.fillRect(12, 65, 7, 11); // left leg (was 16)
ctx.fillRect(29, 65, 7, 11); // right leg (was 25)
```

**Effort:** 40 min — suit jacket, collar, tie, leg spacing

---

#### 2.5 Enemy Walk Cycles
**Gap:** Same as Brawler — enemies slide without leg animation.

**Canvas technique:** Same approach as Brawler walk cycle (§1.5) — sine wave leg phase, opposite foot positioning.

**Effort:** 30 min per variant (2 hours total for 4 variants)

---

#### 2.6 Attack Wind-Up (All Variants)
**Gap:** Heavy has wind-up state but visual is weak (pulsing red circle). All variants should telegraph attacks clearly.

**Canvas technique:**
```javascript
// In enemy.js render(), when state === 'windup' or attackCooldown > 0.3:
// Pull arm back (anticipation pose)
ctx.fillStyle = '#FFB6C1';
ctx.beginPath();
ctx.rect(0, 38, 10, 8); // arm pulled behind body
ctx.fill();
ctx.stroke();

// Speed lines behind fist
ctx.strokeStyle = '#FFFFFF';
ctx.lineWidth = 2;
ctx.globalAlpha = 0.6;
ctx.beginPath();
ctx.moveTo(-8, 42);
ctx.lineTo(-18, 42);
ctx.moveTo(-8, 38);
ctx.lineTo(-18, 38);
ctx.stroke();
ctx.globalAlpha = 1;

// Exclamation point above head (warning symbol)
ctx.fillStyle = '#FF3333';
ctx.font = 'bold 16px Arial';
ctx.fillText('!', 24, 0);
```

**Effort:** 25 min — apply to all enemy states

---

### Summary: Enemy Upgrades
**Total effort:** ~5 hours  
**Impact:** High — enemies become recognizable Downtown characters, combat reads clearer

---

## 3. DOWNTOWN BACKGROUND

### Current State
**Achieved (Wave 4):**
- ✅ Three-layer parallax (far: Factory, mid: buildings, near: road)
- ✅ Sky gradient (#87CEEB → #B0E0E6)
- ✅ Puffy clouds (overlapping circles, tiling)
- ✅ Quick Stop with red awning + text
- ✅ Joe's Bar with neon sign + grimy window
- ✅ Downtown houses (3 colors, triangle roofs, cross-bar windows)
- ✅ Factory cooling towers with steam, smokestack with red stripes
- ✅ Road with yellow dashes, curb, sidewalk, fire hydrants

**Remaining gaps:**
- **Landmark clarity:** Factory reads as "grey industrial building" — needs iconic pink/purple color scheme and cartoon-style simplification
- **Building variety:** 5-building pattern is good but repeats visibly — needs 8-10 building types for less obvious tiling
- **Depth cues:** No atmospheric perspective (distant objects should be hazier, desaturated)
- **Foreground elements:** No trash cans, benches, lampposts, or street clutter for visual interest
- **Sky dynamism:** Clouds drift but sky is static — should have subtle color shifts (dawn/day/dusk cycling)
- **Ground texture:** Road is flat grey — should have cracks, patches, grime for realism

### Target State
Downtown should feel **lived-in and recognizable**:
- Factory is iconic pink/purple with yellow cooling tower tops (show's visual)
- 8-10 building types including iconic locations (player house, neighbor's house, church steeple, school)
- Atmospheric perspective: far layer is desaturated/hazy, near layer is saturated/sharp
- Foreground clutter: trash cans, fire hydrants, benches, lampposts, mailboxes
- Ground texture: cracks, oil stains, leaf litter

### Implementation Plan

#### 3.1 Factory Color Correction
**Gap:** Factory is grey — should be pink/purple with yellow accents (show's iconic look).

**Canvas technique:**
```javascript
// In background.js _drawPowerPlant(), replace colors:
ctx.fillStyle = '#C59CC9'; // light purple cooling tower 1
// ... tower 1 trapezoid ...
ctx.fillStyle = '#B18BB5'; // darker purple cooling tower 2

ctx.fillStyle = '#FFFFAA'; // yellow steam circle (was grey)
ctx.beginPath();
ctx.arc(x + 65, groundY - 185, 30, 0, Math.PI * 2);
ctx.fill();

ctx.fillStyle = '#A57BA9'; // main building purple-grey
ctx.fillRect(x + 40, groundY - 90, 80, 90);
```

**Effort:** 5 min — palette swap on existing shapes

---

#### 3.2 Additional Building Types
**Gap:** 5-building pattern tiles visibly — needs 8-10 types.

**Add:**
- **742 Evergreen Terrace (player house):** orange/salmon walls, red door, garage
- **neighbor's house:** green walls, pristine trim, picket fence suggestion
- **City School:** brick red, tall, flagpole
- **Church steeple:** white, tall pointed roof, cross on top
- **burger joint:** bright red/yellow, restaurant logo outline

**Canvas technique:**
```javascript
// In background.js BUILDINGS array, add:
{ type: 'city_house', w: 160, h: 115, color: '#FFA07A' },
{ type: 'neighbor_house', w: 140, h: 110, color: '#90EE90' },
{ type: 'school', w: 200, h: 150, color: '#B85450' },
{ type: 'church', w: 120, h: 180, color: '#FFFFFF' },
{ type: 'burger joint', w: 180, h: 130, color: '#FF4444' },

// Add drawing functions:
_drawCityHouse(ctx, x, groundY, b) {
    // Salmon walls, red door, brown garage, upper window
    // ... similar structure to _drawHouse() ...
}
// ... etc for each new type
```

**Effort:** 2 hours — 5 new building types with unique details

---

#### 3.3 Atmospheric Perspective
**Gap:** All layers have same saturation/clarity — distant objects should be hazy.

**Canvas technique:**
```javascript
// In background.js _farLayer(), apply global alpha:
ctx.save();
ctx.globalAlpha = 0.65; // far layer 65% opacity (hazy)
// ... draw factory ...
ctx.restore();

// In _midLayer():
ctx.save();
ctx.globalAlpha = 0.85; // mid layer 85% opacity (slightly hazy)
// ... draw buildings ...
ctx.restore();

// Near layer (ground) stays at 1.0 alpha (fully opaque)
```

**Effort:** 5 min — wrap existing layers in save/restore with globalAlpha

---

#### 3.4 Foreground Clutter (Trash Cans, Benches, Lampposts)
**Gap:** Ground layer is empty except fire hydrants — needs visual interest.

**Canvas technique:**
```javascript
// In background.js _ground(), add after fire hydrants:
const clutter = [
    { type: 'trash_can', spacing: 400 },
    { type: 'bench', spacing: 500 },
    { type: 'lamppost', spacing: 350 },
];

for (const item of clutter) {
    const startX = Math.floor(left / item.spacing) * item.spacing;
    for (let ix = startX; ix < right; ix += item.spacing) {
        if (ix + 20 >= left && ix <= right) {
            this._drawClutter(ctx, item.type, ix, HORIZON + 10);
        }
    }
}

_drawClutter(ctx, type, x, y) {
    switch(type) {
        case 'trash_can':
            // Metal cylinder (grey) with lid
            ctx.fillStyle = '#808080';
            ctx.fillRect(x, y, 12, 18);
            ctx.fillStyle = '#606060';
            ctx.fillRect(x - 2, y - 3, 16, 4); // lid
            ctx.strokeStyle = OUTLINE;
            ctx.lineWidth = 1;
            ctx.strokeRect(x, y, 12, 18);
            break;
        case 'bench':
            // Brown wood slats, black metal legs
            ctx.fillStyle = '#8B4513';
            ctx.fillRect(x, y + 6, 30, 4); // seat
            ctx.fillRect(x, y, 30, 3); // backrest
            ctx.fillStyle = '#222222';
            ctx.fillRect(x + 2, y + 3, 2, 10); // left leg
            ctx.fillRect(x + 26, y + 3, 2, 10); // right leg
            break;
        case 'lamppost':
            // Black pole, yellow globe on top
            ctx.fillStyle = '#222222';
            ctx.fillRect(x + 4, y, 3, 25); // pole
            ctx.fillStyle = '#FFEB3B';
            ctx.beginPath();
            ctx.arc(x + 5.5, y - 3, 6, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 1;
            ctx.stroke();
            break;
    }
}
```

**Effort:** 45 min — 3 clutter types with spacing logic

---

#### 3.5 Ground Texture (Cracks, Patches)
**Gap:** Road is flat grey — should have wear details.

**Canvas technique:**
```javascript
// In background.js _ground(), after road fill:
// Random cracks (dark lines)
ctx.strokeStyle = '#404040';
ctx.lineWidth = 1;
ctx.setLineDash([3, 5]); // dashed line
const crackStart = Math.floor(left / 200) * 200;
for (let cx = crackStart; cx < right; cx += 200) {
    const crackY = HORIZON + 50 + (Math.sin(cx * 0.01) * 20);
    ctx.beginPath();
    ctx.moveTo(cx, crackY);
    ctx.lineTo(cx + 50, crackY + 10);
    ctx.stroke();
}
ctx.setLineDash([]); // reset

// Oil stains (dark grey ellipses)
ctx.fillStyle = 'rgba(40, 40, 40, 0.3)';
const stainStart = Math.floor(left / 300) * 300;
for (let sx = stainStart; sx < right; sx += 300) {
    ctx.beginPath();
    ctx.ellipse(sx + 20, HORIZON + 70, 15, 8, Math.random(), 0, Math.PI * 2);
    ctx.fill();
}
```

**Effort:** 20 min — procedural crack/stain generation

---

### Summary: Background Upgrades
**Total effort:** ~3.5 hours  
**Impact:** Medium-High — Downtown becomes instantly recognizable, depth feels professional

---

## 4. VISUAL EFFECTS (VFX)

### Current State
**Achieved (Waves 1, 3, 4):**
- ✅ Hit effects: starburst with 6 radiating rays, white center flash, 3 intensity tiers
- ✅ KO effects: larger starburst + 5 orbiting star particles
- ✅ KO text: random phrase (POW!, WHAM!, etc.), 40px yellow, ±15° rotation
- ✅ Damage numbers: 3 visual tiers (normal/combo/finisher), drift upward, scale fade
- ✅ Ground shadows: oval shadow that scales/fades with jump height
- ✅ All effects use #222222 outline for consistency

**Remaining gaps:**
- **Dust clouds:** No landing dust when jump lands or heavy attack hits ground
- **Speed lines:** Mentioned in art-direction.md ("speed lines behind moving characters") but not implemented
- **Screen shake:** Camera offset exists but not wired to heavy hits
- **Hitstop/freeze frames:** No brief pause on heavy hits for impact feel
- **Particle trails:** No motion blur or trailing particles on fast attacks (kick, dash)
- **Impact ripples:** Ground slam has shockwave ring but no expanding ripple effect
- **Combo trail:** No visual flourish when combo count increases (e.g., sparkle burst)

### Target State
VFX should be **arcade-quality juicy feedback**:
- Every hit feels impactful (screen shake, hitstop, particle burst)
- Motion is clear (speed lines, trails, dust clouds)
- Combos feel rewarding (sparkle burst on increment, escalating intensity)
- Heavy attacks have weight (ripples, screen shake, extended hitstop)

### Implementation Plan

#### 4.1 Landing Dust Clouds
**Gap:** Jump land has no visual feedback — should kick up dust.

**Canvas technique:**
```javascript
// In vfx.js, add:
static createDustCloud(vfxInstance, x, y, intensity = 'light') {
    const radius = intensity === 'heavy' ? 35 : 20;
    const particles = intensity === 'heavy' ? 8 : 5;
    const maxLifetime = 0.3;
    
    const angles = [];
    for (let i = 0; i < particles; i++) {
        angles.push({
            angle: (Math.PI / particles) * i + Math.PI, // upward spread
            speed: 30 + Math.random() * 20,
            size: 3 + Math.random() * 3,
        });
    }
    
    return {
        x, y,
        lifetime: maxLifetime,
        maxLifetime,
        render(ctx, progress) {
            ctx.save();
            ctx.fillStyle = '#A0826D'; // tan dust color
            for (const p of angles) {
                const dist = p.speed * progress * maxLifetime;
                const px = x + Math.cos(p.angle) * dist;
                const py = y + Math.sin(p.angle) * dist;
                const alpha = 1 - progress * progress;
                ctx.globalAlpha = alpha * 0.6;
                ctx.beginPath();
                ctx.arc(px, py, p.size * (1 - progress * 0.5), 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.restore();
        },
    };
}

// In gameplay.js, call when player lands:
if (player.jumpHeight === 0 && player.prevJumpHeight > 50) {
    vfx.addEffect(VFX.createDustCloud(vfx, player.x + 32, player.y + 70, 'light'));
}
```

**Effort:** 30 min — new effect factory + integration

---

#### 4.2 Speed Lines (Behind Fast Movement)
**Gap:** Fast attacks (kick, dash) have no motion indicators.

**Canvas technique:**
```javascript
// In vfx.js, add:
static createSpeedLines(vfxInstance, x, y, direction, count = 5) {
    const maxLifetime = 0.15;
    const lineLength = 40;
    
    const lines = [];
    for (let i = 0; i < count; i++) {
        lines.push({
            offsetX: (Math.random() - 0.5) * 30,
            offsetY: (Math.random() - 0.5) * 20,
        });
    }
    
    return {
        x, y, direction,
        lifetime: maxLifetime,
        maxLifetime,
        render(ctx, progress) {
            const alpha = 1 - progress;
            ctx.save();
            ctx.globalAlpha = alpha * 0.7;
            ctx.strokeStyle = '#FFFFFF';
            ctx.lineWidth = 2;
            ctx.lineCap = 'round';
            
            for (const line of lines) {
                const lx = x + line.offsetX;
                const ly = y + line.offsetY;
                ctx.beginPath();
                ctx.moveTo(lx, ly);
                ctx.lineTo(lx - direction * lineLength, ly);
                ctx.stroke();
            }
            ctx.restore();
        },
    };
}

// In gameplay.js, call during kick attack:
if (player.state === 'kick' && player.attackCooldown > 0.4) {
    vfx.addEffect(VFX.createSpeedLines(vfx, player.x, player.y + 40, player.facing, 5));
}
```

**Effort:** 30 min — new effect factory + integration in 3-4 attack states

---

#### 4.3 Screen Shake (Heavy Hits)
**Gap:** Camera offset exists but not triggered by heavy hits.

**Canvas technique:**
```javascript
// In camera.js (or renderer.js), add:
this.shakeTime = 0;
this.shakeIntensity = 0;

applyShake(intensity = 10, duration = 0.15) {
    this.shakeIntensity = intensity;
    this.shakeTime = duration;
}

update(dt) {
    if (this.shakeTime > 0) {
        this.shakeTime -= dt;
        this.offsetX = (Math.random() - 0.5) * this.shakeIntensity;
        this.offsetY = (Math.random() - 0.5) * this.shakeIntensity;
    } else {
        this.offsetX = 0;
        this.offsetY = 0;
    }
    // ... existing camera update logic ...
}

render(ctx) {
    ctx.save();
    ctx.translate(this.offsetX, this.offsetY);
    // ... existing render code ...
    ctx.restore();
}

// In gameplay.js, call on heavy hits:
if (damageAmount >= 15) {
    camera.applyShake(8, 0.1);
}
if (enemy.state === 'dead') {
    camera.applyShake(12, 0.15);
}
```

**Effort:** 25 min — camera shake system + integration in 5-6 hit scenarios

---

#### 4.4 Hitstop (Freeze Frames on Heavy Hits)
**Gap:** No brief pause on impact — attacks feel floaty.

**Canvas technique:**
```javascript
// In gameplay.js (or game.js), add:
this.hitstopTime = 0;

update(dt) {
    if (this.hitstopTime > 0) {
        this.hitstopTime -= dt;
        return; // skip all update logic during hitstop
    }
    
    // ... existing update logic ...
    
    // When heavy hit lands:
    if (damageAmount >= 15) {
        this.hitstopTime = 0.05; // 50ms freeze (3 frames at 60fps)
    }
}
```

**Effort:** 15 min — hitstop timer + conditional update skip

---

#### 4.5 Impact Ripples (Ground Slam)
**Gap:** Ground slam has shockwave ring but no expanding ripple for extra juice.

**Canvas technique:**
```javascript
// In vfx.js, add:
static createImpactRipple(vfxInstance, x, y, maxRadius = 100) {
    const maxLifetime = 0.4;
    
    return {
        x, y, maxRadius,
        lifetime: maxLifetime,
        maxLifetime,
        render(ctx, progress) {
            const radius = maxRadius * progress;
            const alpha = 1 - progress;
            
            ctx.save();
            ctx.strokeStyle = '#FFD700';
            ctx.lineWidth = 4;
            ctx.globalAlpha = alpha * 0.8;
            ctx.beginPath();
            ctx.arc(x, y, radius, 0, Math.PI * 2);
            ctx.stroke();
            
            // Second inner ripple
            ctx.globalAlpha = alpha * 0.5;
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(x, y, radius * 0.6, 0, Math.PI * 2);
            ctx.stroke();
            ctx.restore();
        },
    };
}

// In gameplay.js, call on ground slam land:
if (player.state === 'ground_slam' && justLanded) {
    vfx.addEffect(VFX.createImpactRipple(vfx, player.x + 32, player.y + 70, 100));
}
```

**Effort:** 25 min — new effect + integration

---

#### 4.6 Combo Sparkle Burst
**Gap:** Combo count increments silently — should have visual celebration.

**Canvas technique:**
```javascript
// In vfx.js, add:
static createComboBurst(vfxInstance, x, y) {
    const maxLifetime = 0.3;
    const sparkles = [];
    for (let i = 0; i < 10; i++) {
        sparkles.push({
            angle: Math.random() * Math.PI * 2,
            speed: 60 + Math.random() * 40,
            size: 2 + Math.random() * 2,
        });
    }
    
    return {
        x, y,
        lifetime: maxLifetime,
        maxLifetime,
        render(ctx, progress) {
            ctx.save();
            ctx.fillStyle = '#FED90F';
            for (const s of sparkles) {
                const dist = s.speed * progress * maxLifetime;
                const sx = x + Math.cos(s.angle) * dist;
                const sy = y + Math.sin(s.angle) * dist;
                const alpha = 1 - progress;
                ctx.globalAlpha = alpha;
                ctx.beginPath();
                ctx.arc(sx, sy, s.size, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.restore();
        },
    };
}

// In gameplay.js, call when combo increments:
if (player.comboCount > prevCombo) {
    vfx.addEffect(VFX.createComboBurst(vfx, player.x + 32, player.y + 40));
}
```

**Effort:** 25 min — new effect + integration

---

### Summary: VFX Upgrades
**Total effort:** ~2.5 hours  
**Impact:** High — combat feels significantly more satisfying and juicy

---

## 5. UI & HUD

### Current State
**Achieved:**
- ✅ Player health bar (top-left) with label, red background, green fill, white border
- ✅ Score (top-right) in white 28px font
- ✅ Combo counter (center screen) with scale animation, color shifts (yellow/orange/red), damage multiplier display
- ✅ Enemy health bars (above damaged enemies) — red background, green fill, black border

**Remaining gaps:**
- **Health bar style:** Bar is functional but generic — should be arcade-styled (thicker border, beveled corners, inner glow)
- **Portrait icon:** No Brawler portrait next to health bar (arcade standard)
- **Lives display:** Lives tracked but not visually shown (should be Brawler head icons in top-left)
- **Special move indicator:** Special move exists but no UI for cooldown (should show belly bump availability)
- **Wave indicator:** No visual cue for which wave player is on ("WAVE 2" banner)
- **Damage flash:** HUD doesn't react to player taking damage (health bar should shake/flash red)
- **Combo meter bar:** Combo timer tracked but no visual bar showing time remaining until reset
- **Score popup:** Score increments silently — should show "+50" popup at kill location
- **Boss health bar:** No special UI for boss enemies (should have large bar at top of screen)

### Target State
HUD should be **clear, arcade-styled, and informative**:
- Health bar has thick beveled border, inner glow, portrait icon
- Lives shown as Brawler head icons (3-5 lives)
- Special move cooldown bar fills up (empty when on cooldown)
- Combo timer bar shows time remaining (yellow → red as it expires)
- Wave number banner appears at wave start
- Score popups appear at enemy death location
- Boss health bar at top of screen (different style than player bar)

### Implementation Plan

#### 5.1 Arcade-Style Health Bar (Beveled Border + Glow)
**Gap:** Health bar is flat rectangle — should have depth.

**Canvas technique:**
```javascript
// In hud.js render(), replace health bar drawing with:
const barWidth = 200;
const barHeight = 30;
const barX = 20;
const barY = 20;

// Outer bevel (dark grey)
ctx.fillStyle = '#333333';
ctx.fillRect(barX - 3, barY - 3, barWidth + 6, barHeight + 6);

// Inner bevel (light grey)
ctx.fillStyle = '#666666';
ctx.fillRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2);

// Background (dark red)
ctx.fillStyle = '#4A0000';
ctx.fillRect(barX, barY, barWidth, barHeight);

// Health fill with inner glow
const healthPercent = player.health / player.maxHealth;
const grad = ctx.createLinearGradient(barX, barY, barX, barY + barHeight);
grad.addColorStop(0, '#00FF00');
grad.addColorStop(0.5, '#00CC00');
grad.addColorStop(1, '#009900');
ctx.fillStyle = grad;
ctx.fillRect(barX, barY, barWidth * healthPercent, barHeight);

// Highlight shine (top edge)
ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
ctx.fillRect(barX, barY, barWidth * healthPercent, 4);

// Thick white border
ctx.strokeStyle = '#FFFFFF';
ctx.lineWidth = 4;
ctx.strokeRect(barX, barY, barWidth, barHeight);
```

**Effort:** 20 min — replace flat bar with gradient + bevel layers

---

#### 5.2 Brawler Portrait Icon
**Gap:** No visual indicator of who the player is (arcade standard shows character portrait).

**Canvas technique:**
```javascript
// In hud.js render(), before health bar:
const portraitX = barX - 45;
const portraitY = barY;
const portraitSize = 40;

// Portrait background (dark grey circle)
ctx.fillStyle = '#333333';
ctx.beginPath();
ctx.arc(portraitX + 20, portraitY + 15, 22, 0, Math.PI * 2);
ctx.fill();
ctx.strokeStyle = '#FFFFFF';
ctx.lineWidth = 3;
ctx.stroke();

// Simplified Brawler head
ctx.fillStyle = '#FED90F'; // yellow skin
ctx.beginPath();
ctx.arc(portraitX + 20, portraitY + 15, 18, 0, Math.PI * 2);
ctx.fill();

// Eyes (dots)
ctx.fillStyle = '#000000';
ctx.beginPath();
ctx.arc(portraitX + 15, portraitY + 13, 2, 0, Math.PI * 2);
ctx.fill();
ctx.beginPath();
ctx.arc(portraitX + 25, portraitY + 13, 2, 0, Math.PI * 2);
ctx.fill();

// Mouth (small arc)
ctx.strokeStyle = '#000000';
ctx.lineWidth = 1;
ctx.beginPath();
ctx.arc(portraitX + 20, portraitY + 18, 4, 0.2, Math.PI - 0.2);
ctx.stroke();
```

**Effort:** 25 min — simplified Brawler portrait with basic features

---

#### 5.3 Lives Display (Brawler Head Icons)
**Gap:** Lives tracked but not shown visually.

**Canvas technique:**
```javascript
// In hud.js render(), below health bar:
const livesY = barY + barHeight + 10;
ctx.fillStyle = '#FFFFFF';
ctx.font = 'bold 14px Arial';
ctx.fillText('LIVES:', barX, livesY);

for (let i = 0; i < player.lives; i++) {
    const iconX = barX + 50 + (i * 30);
    // Draw simplified Brawler head (yellow circle)
    ctx.fillStyle = '#FED90F';
    ctx.beginPath();
    ctx.arc(iconX, livesY - 5, 10, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = '#222222';
    ctx.lineWidth = 2;
    ctx.stroke();
    // Eyes (tiny dots)
    ctx.fillStyle = '#000000';
    ctx.fillRect(iconX - 3, livesY - 6, 2, 2);
    ctx.fillRect(iconX + 1, livesY - 6, 2, 2);
}
```

**Effort:** 15 min — loop to draw lives as mini-portraits

---

#### 5.4 Special Move Cooldown Bar
**Gap:** Belly bump is on cooldown but player has no visual indicator.

**Canvas technique:**
```javascript
// In hud.js render(), below lives:
const specialY = livesY + 25;
ctx.fillStyle = '#FFFFFF';
ctx.font = 'bold 14px Arial';
ctx.fillText('SPECIAL:', barX, specialY);

const specialBarW = 120;
const specialBarH = 10;
const specialBarX = barX + 70;
const specialBarY = specialY - 10;

// Background (dark grey)
ctx.fillStyle = '#333333';
ctx.fillRect(specialBarX, specialBarY, specialBarW, specialBarH);

// Fill (yellow when ready, grey when on cooldown)
const cooldownPercent = Math.max(0, 1 - (player.specialCooldown / 1.5));
ctx.fillStyle = cooldownPercent >= 1 ? '#FED90F' : '#666666';
ctx.fillRect(specialBarX, specialBarY, specialBarW * cooldownPercent, specialBarH);

// Border
ctx.strokeStyle = '#FFFFFF';
ctx.lineWidth = 2;
ctx.strokeRect(specialBarX, specialBarY, specialBarW, specialBarH);

// "READY!" text when available
if (cooldownPercent >= 1 && player.comboCount >= 3) {
    ctx.fillStyle = '#00FF00';
    ctx.font = 'bold 12px Arial';
    ctx.fillText('READY!', specialBarX + specialBarW + 5, specialY);
}
```

**Effort:** 20 min — cooldown bar with fill animation

---

#### 5.5 Wave Indicator Banner
**Gap:** No visual cue for wave number.

**Canvas technique:**
```javascript
// In gameplay.js, add:
this.waveBannerTime = 0;

// When new wave starts:
startWave(waveIndex) {
    this.currentWave = waveIndex;
    this.waveBannerTime = 2.0; // show banner for 2 seconds
    // ... existing wave start logic ...
}

update(dt) {
    if (this.waveBannerTime > 0) this.waveBannerTime -= dt;
    // ... rest of update ...
}

// In hud.js render(), add after combo counter:
if (gameplay.waveBannerTime > 0) {
    const alpha = Math.min(1, gameplay.waveBannerTime / 0.5); // fade in over 0.5s
    const cx = this.renderer.width / 2;
    const cy = this.renderer.height / 2 - 150;
    
    ctx.save();
    ctx.globalAlpha = alpha;
    
    // Banner background (dark semi-transparent)
    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
    ctx.fillRect(cx - 150, cy - 30, 300, 60);
    
    // Border
    ctx.strokeStyle = '#FED90F';
    ctx.lineWidth = 4;
    ctx.strokeRect(cx - 150, cy - 30, 300, 60);
    
    // Wave text
    ctx.fillStyle = '#FED90F';
    ctx.font = 'bold 40px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(`WAVE ${gameplay.currentWave}`, cx, cy);
    
    ctx.restore();
}
```

**Effort:** 30 min — banner rendering + fade-in timer

---

#### 5.6 Score Popup (At Enemy Death)
**Gap:** Score increments silently — should show "+50" floating text at kill location.

**Canvas technique:**
```javascript
// In vfx.js, add:
static createScorePopup(vfxInstance, x, y, points) {
    const maxLifetime = 1.0;
    const startY = y;
    
    return {
        x, y: startY,
        lifetime: maxLifetime,
        maxLifetime,
        render(ctx, progress) {
            const alpha = 1 - progress;
            const yOffset = progress * maxLifetime * 50; // drift up 50px/s
            const drawY = startY - yOffset;
            const scale = 1 + progress * 0.3; // grow slightly
            
            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.font = `bold ${Math.round(24 * scale)}px Arial`;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            
            // Outline
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 3;
            ctx.strokeText(`+${points}`, x, drawY);
            
            // Fill (yellow)
            ctx.fillStyle = '#FED90F';
            ctx.fillText(`+${points}`, x, drawY);
            ctx.restore();
        },
    };
}

// In gameplay.js, call on enemy death:
vfx.addEffect(VFX.createScorePopup(vfx, enemy.x + enemy.width / 2, enemy.y - 20, 50));
```

**Effort:** 20 min — new VFX effect + integration

---

#### 5.7 Combo Timer Bar
**Gap:** Combo timer tracked but not visualized — player doesn't know when combo will reset.

**Canvas technique:**
```javascript
// In hud.js render(), when combo > 1:
if (player.comboCount > 1) {
    const timerPercent = 1 - (player.comboTimer / player.comboWindow);
    const barW = 150;
    const barH = 6;
    const barX = cx - barW / 2;
    const barY = cy + fontSize * 0.7 + 35;
    
    // Background
    ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
    ctx.fillRect(barX, barY, barW, barH);
    
    // Timer fill (yellow → red as it expires)
    const r = Math.floor(255 * (1 - timerPercent));
    const g = Math.floor(255 * timerPercent);
    ctx.fillStyle = `rgb(${r}, ${g}, 0)`;
    ctx.fillRect(barX, barY, barW * timerPercent, barH);
    
    // Border
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 1;
    ctx.strokeRect(barX, barY, barW, barH);
}
```

**Effort:** 15 min — bar below combo counter

---

### Summary: UI/HUD Upgrades
**Total effort:** ~2.5 hours  
**Impact:** High — HUD becomes informative, arcade-authentic, and visually appealing

---

## 6. TITLE SCREEN

### Current State
**Achieved:**
- ✅ Gradient sky background (#1a1a40 → #87CEEB)
- ✅ Scrolling skyline buildings with window dots
- ✅ Ground strip
- ✅ Brawler silhouette (iconic standing pose, basic shapes, yellow tint)
- ✅ Floating star particles (yellow, drift upward)
- ✅ Title "FIRST PUNCH" (72px yellow, outlined)
- ✅ Subtitle "BEAT 'EM UP" (32px white)
- ✅ "Press ENTER to Start" (pulsing glow)
- ✅ Controls text
- ✅ High score display
- ✅ Credits line

**Remaining gaps:**
- **Brawler silhouette clarity:** Brawler is very faint (18% alpha) — should be 40-50% for better visibility
- **Animation:** Brawler silhouette is static — should have subtle idle breathing animation
- **Logo style:** Title text is plain Arial — should have comic-book outline style (thicker stroke, yellow/orange gradient fill)
- **Background dynamism:** Skyline scrolls but no parallax clouds, no flickering windows
- **Character showcase:** Only Brawler shown — could show 2-3 enemy silhouettes in background for context
- **Menu options:** Single "Press ENTER" — could have "NEW GAME / HIGH SCORES / CONTROLS" selectable menu

### Target State
Title screen should **immediately communicate "game arcade beat 'em up"**:
- Bold comic-style logo (thick outline, gradient fill, slight rotation/scale pulse)
- Animated Brawler silhouette (breathing, blinking, occasional arm movement)
- Parallax clouds drifting behind buildings
- Enemy silhouettes in background (Drunkard, tough guy)
- Selectable menu options with arcade-style selector (blinking arrow)
- Flickering windows on buildings for life

### Implementation Plan

#### 6.1 Brawler Silhouette Clarity + Breathing Animation
**Gap:** Brawler is too faint and static.

**Canvas technique:**
```javascript
// In title.js render(), replace Brawler silhouette alpha and add breathing:
const breathe = Math.sin(this.blinkTime * 2) * 0.05; // subtle scale pulse
ctx.fillStyle = 'rgba(254, 217, 15, 0.45)'; // increased from 0.18

ctx.save();
ctx.translate(hx, hy - 60);
ctx.scale(1 + breathe, 1 - breathe * 0.5); // expand/contract

// Head (large round)
ctx.beginPath();
ctx.arc(0, -55, 32, 0, Math.PI * 2);
ctx.fill();

// Body (rounded rect approximation)
ctx.beginPath();
ctx.ellipse(0, 5, 26, 42, 0, 0, Math.PI * 2);
ctx.fill();

// Belly bump
ctx.beginPath();
ctx.arc(6, 5, 22, -0.5, 1.2);
ctx.fill();

// Legs
ctx.fillRect(-18, 42, 14, 20);
ctx.fillRect(4, 42, 14, 20);

ctx.restore();
```

**Effort:** 15 min — adjust alpha, add scale transform with sine wave

---

#### 6.2 Comic-Style Logo (Thick Outline + Gradient Fill)
**Gap:** Logo is plain text — should be bold comic style.

**Canvas technique:**
```javascript
// In title.js render(), replace title rendering:
const logoX = w / 2;
const logoY = h * 0.18;

ctx.save();
ctx.font = 'bold 80px Arial'; // increased from 72px
ctx.textAlign = 'center';
ctx.textBaseline = 'middle';

// Outer shadow (black, offset)
ctx.fillStyle = '#000000';
ctx.fillText('FIRST PUNCH', logoX + 4, logoY + 4);

// Thick outline (dark grey)
ctx.strokeStyle = '#222222';
ctx.lineWidth = 10;
ctx.lineJoin = 'round';
ctx.strokeText('FIRST PUNCH', logoX, logoY);

// Inner outline (white for pop)
ctx.strokeStyle = '#FFFFFF';
ctx.lineWidth = 4;
ctx.strokeText('FIRST PUNCH', logoX, logoY);

// Gradient fill (yellow → orange)
const grad = ctx.createLinearGradient(logoX, logoY - 40, logoX, logoY + 40);
grad.addColorStop(0, '#FFEB3B');
grad.addColorStop(1, '#FF9800');
ctx.fillStyle = grad;
ctx.fillText('FIRST PUNCH', logoX, logoY);

ctx.restore();
```

**Effort:** 20 min — layered stroke + gradient fill

---

#### 6.3 Enemy Silhouettes (Background Showcase)
**Gap:** Only Brawler shown — enemies should appear in background.

**Canvas technique:**
```javascript
// In title.js render(), after Brawler silhouette:
// Drunkard silhouette (left side, smaller, hazier)
const bruiserX = w * 0.15;
const bruiserY = h - 110;
ctx.fillStyle = 'rgba(150, 80, 150, 0.25)'; // purple tint, faint

ctx.save();
ctx.translate(bruiserX, bruiserY);

// Head
ctx.beginPath();
ctx.arc(0, -45, 20, 0, Math.PI * 2);
ctx.fill();

// Body (wider, beer belly)
ctx.beginPath();
ctx.ellipse(0, -10, 18, 28, 0, 0, Math.PI * 2);
ctx.fill();

// Legs
ctx.fillRect(-12, 12, 10, 15);
ctx.fillRect(2, 12, 10, 15);

ctx.restore();

// Tough guy silhouette (right side, aggressive pose)
const toughX = w * 0.22;
const toughY = h - 115;
ctx.fillStyle = 'rgba(200, 50, 50, 0.25)'; // red tint, faint

ctx.save();
ctx.translate(toughX, toughY);

// Head
ctx.beginPath();
ctx.arc(0, -48, 18, 0, Math.PI * 2);
ctx.fill();

// Body (lean forward)
ctx.save();
ctx.rotate(-0.1);
ctx.fillRect(-10, -30, 20, 30);
ctx.restore();

// Fist extended (attacking pose)
ctx.beginPath();
ctx.arc(18, -20, 6, 0, Math.PI * 2);
ctx.fill();

ctx.restore();
```

**Effort:** 30 min — 2 enemy silhouettes with basic shapes

---

#### 6.4 Parallax Clouds (Behind Buildings)
**Gap:** Skyline scrolls but no atmospheric clouds.

**Canvas technique:**
```javascript
// In title.js render(), before skyline drawing:
// Draw 2-3 large clouds drifting slowly at 0.3× skyline speed
const cloudOffset = (this.skylineOffset * 0.3) % 800;
const cloudShapes = [
    { baseX: 100, y: 120, scale: 1.2 },
    { baseX: 500, y: 80, scale: 1.0 },
];

ctx.save();
ctx.globalAlpha = 0.15;
ctx.fillStyle = '#FFFFFF';

for (const c of cloudShapes) {
    const cx = ((c.baseX - cloudOffset) % 800 + 800) % 800;
    const r = 35 * c.scale;
    // Puffy cloud (overlapping circles)
    ctx.beginPath();
    ctx.arc(cx, c.y, r, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(cx - r * 0.7, c.y + r * 0.2, r * 0.8, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(cx + r * 0.7, c.y + r * 0.15, r * 0.75, 0, Math.PI * 2);
    ctx.fill();
}

ctx.restore();
```

**Effort:** 20 min — 2-3 large cloud shapes with parallax scroll

---

#### 6.5 Flickering Windows
**Gap:** Building windows are static — should flicker randomly for life.

**Canvas technique:**
```javascript
// In title.js render(), replace window drawing loop:
for (let wy = h - 120 - b.h + 12; wy < h - 120; wy += 18) {
    for (let wx = drawX + 8; wx < drawX + b.w - 8; wx += 14) {
        // Random flicker: 90% lit, 10% dark
        const lit = Math.random() > 0.1;
        ctx.fillStyle = lit 
            ? 'rgba(255, 220, 80, 0.3)' 
            : 'rgba(80, 60, 20, 0.2)';
        ctx.fillRect(wx, wy, 6, 8);
    }
}
```

**Effort:** 5 min — simple random check per window

---

### Summary: Title Screen Upgrades
**Total effort:** ~1.5 hours  
**Impact:** Medium — title screen becomes more dynamic and visually engaging

---

## 7. ANIMATION SYSTEM (NEW)

### Current State
**Gap:** All animation is ad-hoc (sine waves, timers) — no structured animation system.

**Problem:**
- Walk cycles are manual transforms
- Attack animations are hard-coded state checks
- No easing curves, no keyframe system
- Difficult to add complex multi-step animations

### Target State
**Animation system architecture:**
```javascript
// src/systems/animation.js
class Animation {
    constructor(frames, loop = false) {
        this.frames = frames; // [{ time: 0.0, values: {...} }, ...]
        this.loop = loop;
        this.time = 0;
        this.playing = false;
    }
    
    play() { this.playing = true; this.time = 0; }
    stop() { this.playing = false; }
    
    update(dt) {
        if (!this.playing) return;
        this.time += dt;
        if (this.time >= this.getTotalDuration()) {
            if (this.loop) this.time = 0;
            else this.stop();
        }
    }
    
    getValue(property) {
        // Interpolate between keyframes
        // ... implementation ...
    }
}
```

**Usage:**
```javascript
// Define walk cycle as keyframe animation
const walkCycle = new Animation([
    { time: 0.0, values: { leftLegAngle: 0, rightLegAngle: 0 } },
    { time: 0.15, values: { leftLegAngle: 0.15, rightLegAngle: -0.15 } },
    { time: 0.3, values: { leftLegAngle: 0, rightLegAngle: 0 } },
    { time: 0.45, values: { leftLegAngle: -0.15, rightLegAngle: 0.15 } },
], true);

// In player.js:
if (this.state === 'walk') {
    this.walkAnim.play();
    this.walkAnim.update(dt);
    leftLegAngle = this.walkAnim.getValue('leftLegAngle');
    rightLegAngle = this.walkAnim.getValue('rightLegAngle');
}
```

### Implementation Plan
**Effort:** 4 hours — build animation system, migrate walk cycles, add attack anticipation animations  
**Impact:** High — enables complex animations, easier to add new moves, more polished feel

**Status:** Deferred to P2 — current manual animations functional, system upgrade not critical path

---

## 8. OVERALL CONSISTENCY

### Current State
**Achieved:**
- ✅ Consistent 2px #222222 outlines across player, enemies, buildings
- ✅ Consistent color palette (#FED90F yellow, #87CEEB sky, etc.)
- ✅ Consistent VFX style (starburst hits, floating text)

**Remaining gaps:**
- **Lighting direction:** Highlights on characters are random — should be consistent top-left light source
- **Shadow consistency:** Player/enemies use VFX.drawShadow() but buildings don't cast shadows
- **Outline thickness:** Most elements use 2px but some UI text uses 3-6px stroke
- **Color saturation:** Some elements (skyline) are very desaturated, others (Brawler) are highly saturated — inconsistent visual hierarchy

### Target State
**Unified visual rules:**
1. **Light source:** Top-left 45° angle — all highlights on upper-left, shadows lower-right
2. **Outline hierarchy:** UI text 4-6px, characters 2px, small details 1px
3. **Saturation hierarchy:** Foreground (player/enemies) highly saturated, mid-ground (buildings) 70% saturation, background (skyline) 40% saturation
4. **Shadow casting:** Ground-level entities cast VFX.drawShadow(), buildings cast simple drop shadows on ground

### Implementation Plan

#### 8.1 Lighting Direction Consistency
**Gap:** Highlights are placed arbitrarily on different body parts.

**Fix:** In player.js and enemy.js, move all highlights to upper-left of each shape:
```javascript
// Example: Brawler's belly highlight
ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
ctx.beginPath();
ctx.arc(26, 44, 10, Math.PI * 0.75, Math.PI * 0.25); // upper-left arc only
ctx.fill();
```

**Effort:** 30 min — adjust all highlight positions in player.js and enemy.js

---

#### 8.2 Building Shadows
**Gap:** Buildings float without ground connection.

**Canvas technique:**
```javascript
// In background.js _drawBuilding(), before building fill:
// Drop shadow (simple dark ellipse on ground)
ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
ctx.beginPath();
ctx.ellipse(
    x + b.w / 2,        // shadow centered under building
    groundY + 5,        // slightly below ground line
    b.w * 0.4,          // shadow width
    8,                  // shadow height (flat oval)
    0, 0, Math.PI * 2
);
ctx.fill();
```

**Effort:** 15 min — add shadow call before each building type draw

---

#### 8.3 Saturation Hierarchy
**Gap:** Skyline buildings and foreground characters have similar saturation.

**Fix:** Adjust building colors in BUILDINGS array:
```javascript
// Before (full saturation):
{ type: 'house', w: 120, h: 100, color: '#E8C48A' },

// After (70% saturation):
{ type: 'house', w: 120, h: 100, color: '#D9C5A7' },
```

Apply desaturation formula: `newColor = mix(originalColor, grey, 0.3)`

**Effort:** 20 min — recalculate 8-10 building colors with desaturation

---

### Summary: Consistency Upgrades
**Total effort:** ~1 hour  
**Impact:** Medium — subtle but makes entire game feel more cohesive

---

## PRIORITY MATRIX

### P0 — Critical (Must-Have for "Modern")
1. **Brawler facial expressions** (§1.4) — 20 min — High impact, low effort
2. **Walk cycle animation** (§1.5) — 45 min — Immediately visible, core polish
3. **Landing dust clouds** (§4.1) — 30 min — Juice, makes movement feel grounded
4. **Screen shake on heavy hits** (§4.3) — 25 min — Huge impact feel improvement
5. **Lives display** (§5.3) — 15 min — Standard arcade UI, currently confusing when player dies
6. **Score popup** (§5.6) — 20 min — Feedback for kills, arcade standard

**Total P0 effort:** ~2.5 hours  
**Impact:** Transforms core gameplay feel from "functional" to "polished"

---

### P1 — High Value (Modern Standard)
1. **Brawler hands** (§1.3) — 30 min — Character detail
2. **Brawler stubble + ears** (§1.1, §1.2) — 25 min — IP authenticity
3. **Enemy character identity** (§2.1–§2.4) — 2.5 hours — Downtown feel
4. **Factory color correction** (§3.1) — 5 min — Instant recognition
5. **Additional building types** (§3.2) — 2 hours — Downtown landmarks
6. **Speed lines** (§4.2) — 30 min — Motion clarity
7. **Hitstop** (§4.4) — 15 min — Attack impact feel
8. **Combo sparkle burst** (§4.6) — 25 min — Reward feedback
9. **Arcade-style health bar** (§5.1) — 20 min — UI polish
10. **Special move cooldown bar** (§5.4) — 20 min — Player information

**Total P1 effort:** ~6.5 hours  
**Impact:** Elevates game from "polished" to "modern arcade quality"

---

### P2 — Nice-to-Have (Advanced Polish)
1. **Body proportions adjustment** (§1.6) — 30 min
2. **Squash/stretch on landing** (§1.8) — 20 min
3. **Shirt details** (§1.7) — 10 min
4. **Enemy walk cycles** (§2.5) — 2 hours
5. **Attack wind-up telegraph** (§2.6) — 25 min
6. **Atmospheric perspective** (§3.3) — 5 min
7. **Foreground clutter** (§3.4) — 45 min
8. **Ground texture** (§3.5) — 20 min
9. **Impact ripples** (§4.5) — 25 min
10. **Brawler portrait icon** (§5.2) — 25 min
11. **Wave indicator banner** (§5.5) — 30 min
12. **Combo timer bar** (§5.7) — 15 min
13. **Comic-style logo** (§6.2) — 20 min
14. **Enemy silhouettes on title** (§6.3) — 30 min
15. **Consistency upgrades** (§8.1–§8.3) — 1 hour

**Total P2 effort:** ~6.5 hours  
**Impact:** Final 10% polish, professional-grade details

---

### P3 — Future Enhancements
1. **Animation system** (§7) — 4 hours — Infrastructure for future content
2. **Title screen menu system** (§6.6, not detailed) — 2 hours
3. **Boss health bar** (§5 gap, not detailed) — 1 hour
4. **Parallax clouds on title** (§6.4) — 20 min
5. **Flickering windows** (§6.5) — 5 min

**Total P3 effort:** ~7.5 hours

---

## TOTAL EFFORT ESTIMATE

| Priority | Effort | Items |
|----------|--------|-------|
| P0       | 2.5 hr | 6 items — Core polish |
| P1       | 6.5 hr | 10 items — Modern standard |
| P2       | 6.5 hr | 15 items — Advanced polish |
| P3       | 7.5 hr | 5 items — Future enhancements |
| **TOTAL** | **23 hr** | **36 items** |

---

## IMPLEMENTATION ROADMAP

### Wave 1 (P0 — Core Polish) — 2.5 hours
**Goal:** Make core gameplay feel modern and juicy

1. Brawler facial expressions
2. Walk cycle animation
3. Landing dust clouds
4. Screen shake on heavy hits
5. Lives display
6. Score popup

**Validation:** Game feels polished and responsive. Player understands health/lives state.

---

### Wave 2 (P1 High-Priority Visual Upgrades) — 6.5 hours
**Goal:** Recognizable Downtown, detailed characters, arcade UI

1. Brawler hands, stubble, ears (character detail)
2. Enemy character identity (Drunkard, biker, hooligan, enforcer)
3. Factory color + additional buildings (Downtown landmarks)
4. Speed lines, hitstop, combo burst (combat feel)
5. Arcade health bar, special cooldown bar (UI polish)

**Validation:** Characters read as game universe. Combat feels arcade-quality.

---

### Wave 3 (P2 Advanced Polish) — 6.5 hours
**Goal:** Final 10% — professional-grade details

1. Body proportions, squash/stretch, shirt details (micro-details)
2. Enemy walk cycles, attack telegraph (enemy polish)
3. Atmospheric perspective, clutter, ground texture (environment depth)
4. Impact ripples, portrait icon, wave banner (final touches)
5. Consistency upgrades (unified visual rules)

**Validation:** Game looks like a commercial product. No visual rough edges.

---

### Wave 4 (P3 Future) — 7.5 hours
**Goal:** Infrastructure and long-term enhancements

1. Animation system (enables complex future animations)
2. Title screen menu, boss UI, atmospheric effects

**Validation:** Ready for content expansion and advanced features.

---

## CANVAS 2D TECHNIQUES REFERENCE

### Bezier Curves (Organic Shapes)
```javascript
// Smooth belly bulge
ctx.beginPath();
ctx.moveTo(18, 35);
ctx.quadraticCurveTo(52, 58, 46, 65); // control point creates curve
ctx.lineTo(18, 65);
ctx.quadraticCurveTo(12, 58, 16, 48);
ctx.closePath();
```

### Gradients (Depth and Lighting)
```javascript
// Radial gradient for spotlight effect
const grad = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);
grad.addColorStop(0, '#FFFFFF');
grad.addColorStop(1, '#FED90F');
ctx.fillStyle = grad;

// Linear gradient for sky
const grad = ctx.createLinearGradient(0, 0, 0, height);
grad.addColorStop(0, '#87CEEB');
grad.addColorStop(1, '#B0E0E6');
```

### Composite Operations (Layered Effects)
```javascript
// Additive blending for glow
ctx.globalCompositeOperation = 'lighter';
ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
ctx.arc(x, y, radius, 0, Math.PI * 2);
ctx.fill();
ctx.globalCompositeOperation = 'source-over'; // reset
```

### Transform Matrices (Animation)
```javascript
// Rotate arm around shoulder pivot
ctx.save();
ctx.translate(shoulderX, shoulderY);
ctx.rotate(angle);
ctx.fillRect(0, 0, armLength, armWidth); // arm extends from pivot
ctx.restore();
```

### Clipping Paths (Complex Masks)
```javascript
// Mask drawing area to character silhouette
ctx.save();
ctx.beginPath();
ctx.arc(x, y, radius, 0, Math.PI * 2);
ctx.clip();
// All subsequent draws are clipped to circle
ctx.fillRect(x - 50, y - 50, 100, 100);
ctx.restore();
```

### Path Operations (Boolean Shapes)
```javascript
// Create compound path (punch out center)
ctx.beginPath();
ctx.arc(x, y, outerRadius, 0, Math.PI * 2);
ctx.arc(x, y, innerRadius, 0, Math.PI * 2, true); // counterclockwise = hole
ctx.fill('evenodd'); // or 'nonzero'
```

---

## CONCLUSION

**Current state:** 60% modern — consistent outlines, proper shapes, Downtown background, functional VFX

**Target state:** 95% modern — expressive characters, recognizable Downtown, arcade-quality UI, juicy combat feedback

**Gap:** 36 items across 4 priority tiers, ~23 hours total effort

**Recommended approach:**
1. **Immediate:** P0 items (2.5 hours) — transforms feel from functional to polished
2. **Short-term:** P1 items (6.5 hours) — achieves "modern arcade quality" target
3. **Medium-term:** P2 items (6.5 hours) — final 10% professional polish
4. **Long-term:** P3 items (7.5 hours) — infrastructure for future content

**Key insight:** Visual modernization is not about switching to 3D or external assets — it's about **applying modern Canvas 2D techniques** (bezier curves, gradients, layered effects, transforms) to **character detail, animation, feedback, and UI polish**. The game already has solid foundations (outlines, colors, basic shapes); the gap is in **micro-details, expressiveness, and juice**.

Every item in this plan is achievable with pure Canvas 2D API. No external dependencies, no asset loading complexity — just procedural drawing upgraded from "programmer art" to "professional 2D art."
