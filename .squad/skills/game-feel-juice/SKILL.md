# SKILL: Game Feel & "Juice" — Universal Impact Feedback

The difference between "press button, thing happens" and "press button, FEEL the impact." Juice is the collection of feedback effects that make interactions satisfying. It is the #1 principle of modern game design and applies to every genre: beat 'em ups, platformers, fighters, RPGs, puzzles, 3D action, mobile games, everything.

---

name: "game-feel-juice"
description: "Juice patterns and feedback techniques — screen shake, hitlag, flash, particles, knockback, squash-and-stretch, sound sync, time manipulation"
domain: "game-design"
confidence: "medium"
source: "extracted from firstPunch combat implementation (Lando, Ackbar, Yoda) + genre research (Celeste, SoR4, Hollow Knight, Gungeon, Hades)"

---

## When to Use This Skill

- Implementing feedback effects for any player action (attack, jump, dash, collect, UI interaction)
- Tuning the "feel" of existing mechanics that work but feel lifeless
- Debugging "combat feels weightless" or "interaction feels flat"
- Designing impact effects for a new attack type, ability, or game event
- Reviewing game feel across a sprint for consistency and over/under-polishing
- Creating a game feel checklist before shipping a feature

## When NOT to Use This Skill

- Pure UI feedback (button states, progress bars) — see `ui-ux-patterns` (when available)
- Animation systems (skeletal rigs, blend trees) — see your engine's animation framework
- Audio pipelines (mixing, mastering, synthesis) — see procedural audio skills
- Juice is PART of these systems, not a replacement for them

---

## 1. What is "Juice"?

**Definition:** Juice is the collection of subtle, layered feedback effects that make an interaction feel impactful, responsive, and satisfying to the player. It transforms mechanical correctness into emotional resonance.

### Why Juice Matters (and Why It's Core, Not Polish)

The player's hands are the truth. Two milliseconds of input latency kills feel — not because it's technically wrong, but because the player's nervous system feels the disconnect. Similarly, an attack that deals damage but produces no visual or audio feedback feels powerless, even if the damage number is correct.

**The Juice Principle (from Principle #1 — Player Hands First):**
> The first 10 seconds of player hands matter more than any system behind it. When the player presses a button, they should feel power, impact, or consequence immediately. If they feel delay, disconnection, or weightlessness, the game has failed — regardless of how correct the underlying code is.

Juice is not a cosmetic layer on top of core mechanics. It IS core mechanics in the player's hands.

### The Evidence

- **Celeste** (2018): Every movement has micro-feedback (particle puffs on dash, screen tilt, sound layer swells). Removing any single effect feels like something broke.
- **Streets of Rage 4** (2020): The hitlag freeze (6 frames on heavy hits) is why combat feels weighty. Remove the freeze, keep the damage number, and the game feels floaty.
- **Hollow Knight** (2017): Enemy knockback and recoil are *feedback*, not punishment. They tell the player: "Your strike had impact."
- **Enter the Gungeon** (2016): Each weapon fires with distinct particle patterns, flash colors, and knockback arcs. Identical damage values would feel completely different without juice variation.

**Rule:** Test this yourself. Build a game feature with juice, then disable all juice effects via a debug toggle. Play both versions. The difference IS your feature's quality, not an afterthought.

---

## 2. Core Juice Techniques (Genre-Agnostic)

These 10 techniques are the building blocks of juice. Master these, layer them together, and any game feels satisfying.

### 2.1 Screen Shake

**What:** The camera jiggles/oscillates on impact.

**When:**
- Enemy takes damage (small: 2-3px amplitude)
- Player takes damage (medium: 3-5px amplitude, red tint + screen shake together)
- Large impact: explosion, boss phase transition, critical hit (large: 5-10px amplitude)
- Do NOT shake for: UI interactions, ambient effects, constant background motion

**How:**
```javascript
// Camera shake: perlin noise or sine wave, decay over time
applyScreenShake(amplitude, duration) {
    this.shakeAmount = amplitude;
    this.shakeTimeRemaining = duration;  // typically 0.1-0.15s (6-9 frames at 60fps)
    this.shakeFrequency = 20;  // Hz — how fast the shake oscillates
}

update(dt) {
    if (this.shakeTimeRemaining > 0) {
        const phase = Math.sin(Date.now() * this.shakeFrequency * 0.001) * this.shakeAmount;
        this.camera.x += phase;
        
        // Decay: amplitude reduces over duration
        this.shakeAmount *= Math.exp(-3 * dt / this.shakeTimeRemaining);
        this.shakeTimeRemaining -= dt;
    } else {
        // Smooth return to center
        this.camera.x += (0 - this.camera.x) * 0.2;
    }
}
```

**Tuning Guidelines:**
- At 60fps, amplitude 2-3px with frequency 20Hz = subtle and feels impact-y
- Amplitude 5-8px = dramatic (reserve for critical hits, deaths, phase transitions)
- Duration 0.1-0.2s is the sweet spot. Longer = nausea. Shorter = imperceptible.
- Decay should be exponential, not linear. The tail should taper smoothly, not stop abruptly.
- **Anti-pattern:** Screen shakes constantly. If EVERYTHING shakes, nothing feels special. Juice must punctuate.

### 2.2 Hitlag / Freeze Frames

**What:** The game pauses for 2-6 frames the instant a hit connects.

**Why it's THE most important juice effect:** Freezes let the player feel the impact before animation carries them away. It's the single most powerful technique for combat feel. Every frame-based fighting game, every action game, uses hitlag. This is not optional.

**How:**
```javascript
// During attack hit detection:
if (attackHitbox.intersects(targetHurtbox)) {
    // FREEZE only the attacker + target, NOT the whole game
    attacker.frozen = true;
    target.frozen = true;
    this.hitlagFramesRemaining = 4;  // 4 frames = 67ms at 60fps
    
    // After hitlag expires, both unfreeze and apply knockback/hitstun
    setTimeout(() => {
        attacker.frozen = false;
        target.frozen = false;
        target.applyKnockback(...);
        target.applyHitstun(...);
    }, hitlagFramesRemaining * (1000/60));
}

// In entity update:
update(dt) {
    if (this.frozen) return;  // Skip all logic while frozen
    // ... normal movement, animation, state updates
}
```

**Tuning Guidelines:**
- Light attacks: 2-3 frames. Heavy attacks: 4-6 frames.
- Vary by damage weight: tiny hit (2f) < normal hit (4f) < heavy hit (6f)
- **Critical rule:** Freeze the attacker + target, NOT the whole game. Other entities continue moving/animating. Only the impact pair pauses.
- **Anti-pattern:** No hitlag. The hit feels invisible. Add hitlag to your first attack and feel the difference.
- **Anti-pattern:** Hitlag on every interaction (button press, menu selection). Save it for high-impact moments only.

### 2.3 Hitstun

**What:** After being hit, the target enters a stunned state and cannot act for 0.3-0.8 seconds (depending on attack weight).

**Relationship to Hitlag:** 
- Hitlag (2-6 frames) = the shared freeze at impact moment
- Hitstun (0.3-0.8s) = the stunned state that follows, where only the target is frozen

**How:**
```javascript
takeDamage(damage) {
    this.health -= damage;
    this.state = 'hit';
    
    // Hitstun duration: scale with damage or attack type
    this.hitstunDuration = 0.3 + (damage / 100) * 0.5;  // 0.3-0.8s depending on damage
    this.hitstunTimeRemaining = this.hitstunDuration;
}

update(dt) {
    if (this.state === 'hit') {
        this.hitstunTimeRemaining -= dt;
        
        if (this.hitstunTimeRemaining <= 0) {
            this.state = 'idle';  // Explicit exit path (state machine rule)
        }
        
        return;  // Cannot act while in hitstun
    }
    
    // ... normal update logic
}
```

**Tuning Guidelines:**
- Light hit: 0.2s hitstun. Medium: 0.4s. Heavy: 0.6-0.8s.
- Hitstun should be long enough that the target can't immediately counter. Too short = feels trivial.
- Hitstun enables **combo windows**: if hitstun > 0.3s, the attacker has time to chain into another attack.
- **Combo math:** If hitstun = 0.4s and next attack startup = 0.15s, the combo window = 0.25s. Design accordingly.

### 2.4 Knockback

**What:** The target is pushed away from the attacker on hit impact.

**Why it matters:** Knockback is a visual/kinetic representation of attack weight. A 20-damage attack that sends you flying FEELS more impactful than a 40-damage attack that barely moves you.

**How:**
```javascript
// In combat system:
applyKnockback(target, attacker, knockbackForce) {
    // Direction: push target away from attacker
    const directionX = target.x > attacker.x ? 1 : -1;
    
    // Apply velocity (knockback isn't instant — it's momentum over frames)
    target.velocity.x = directionX * knockbackForce;
    target.velocity.y = -knockbackForce * 0.3;  // Slight upward bounce
    
    // Target decelerates via physics (friction)
    // Don't stop knockback instantly — let gravity and friction handle it
}

// Physics update (every frame):
if (this.onGround) {
    this.velocity.x *= 0.85;  // Friction: reduces knockback velocity each frame
} else {
    this.velocity.x *= 0.95;  // Air has less friction
}

this.x += this.velocity.x * dt;
this.y += this.velocity.y * dt;
```

**Knockback by Attack Type (examples):**

| Attack | Knockback Force | Knockback Distance | Feel |
|--------|-----------------|-------------------|------|
| Light jab | 100 | 20-30px | Pushback, not flight |
| Heavy punch | 250 | 50-80px | Solid impact, sliding stop |
| Kick | 200 | 60-100px | Spin knockback, bounce |
| Special | 400+ | 100-150px | Dramatic launch, airborne |
| Grab throw | 500 | 120-180px | Ragdoll momentum |

**Tuning Guidelines:**
- Knockback should be proportional to attack weight, not necessarily to damage. A 20-damage heavy attack can knock further than a 30-damage light attack.
- Include upward velocity (the bounce) on medium/heavy knockback. It feels more dynamic than pure horizontal knockback.
- Vary knockback by enemy type: light enemies fly further, heavy enemies slide shorter distances.
- **Anti-pattern:** Instant knockback stop. If knockback goes from 300px/s to 0 in one frame, it feels jerky. Decelerate over 0.3-0.5s.

### 2.5 Flash / Color Effects

**What:** The hit target briefly turns white (or flashes a color) to indicate damage taken.

**How:**
```javascript
takeDamage(damage) {
    this.health -= damage;
    this.flashColor = { r: 255, g: 255, b: 255 };  // White flash
    this.flashTimeRemaining = 0.1;  // 6 frames at 60fps
}

update(dt) {
    if (this.flashTimeRemaining > 0) {
        this.flashTimeRemaining -= dt;
    }
}

render() {
    // Tint the entity sprite/canvas drawing with the flash color
    if (this.flashTimeRemaining > 0) {
        ctx.globalAlpha = this.flashTimeRemaining / 0.1;  // Fade the flash
        ctx.fillStyle = 'white';
        ctx.fillRect(this.x, this.y, this.width, this.height);
        ctx.globalAlpha = 1.0;
    }
    
    // Draw entity normally
    this.drawBody(ctx);
}
```

**Flash Variations:**

| Situation | Flash Color | Duration | Notes |
|-----------|-------------|----------|-------|
| Normal hit | White | 0.067s (4f) | Standard impact feedback |
| Heavy hit | Bright white | 0.1s (6f) | Longer = bigger hit |
| Damage taken | Red | 0.15-0.2s | Distinct from outgoing hits |
| Invincibility | Blue blink | 0.1s on/off | On-off-on pattern, 3 blinks |
| Poison/DoT | Green | 0.05s (3f) | Repeated every 0.5s while poisoned |
| Critical hit | Yellow | 0.12s (7f) | Stands out from normal |

**Tuning Guidelines:**
- Flash duration 3-7 frames (50-117ms). Longer flashes feel jarring, shorter feel imperceptible.
- **Critical rule:** White flash only on IMPACT. Not on the entire duration of the hit state. Flash = the moment, not the aftermath.
- Overlapping flashes: if multiple hits connect in quick succession, the flash should accumulate or extend, not reset each time.
- **Anti-pattern:** Constant color shift. Makes the game feel chaotic. Flash should be a punctuating effect, not persistent.

### 2.6 Particle Bursts

**What:** 2-6 small visual elements (sparks, dust, debris) emit from the hit point.

**When:**
- Impact: attack connects
- Environment: wall hit, slide, landing
- Abilities: dash start, jump takeoff, ability activation
- Destruction: object breaks, enemy dies

**How:**
```javascript
// Spawn particles on hit
spawnImpactParticles(x, y, count = 4) {
    for (let i = 0; i < count; i++) {
        const angle = (Math.PI * 2 * i) / count + (Math.random() - 0.5) * 0.5;
        const speed = 100 + Math.random() * 150;  // px/s
        
        const particle = {
            x: x,
            y: y,
            vx: Math.cos(angle) * speed,
            vy: Math.sin(angle) * speed,
            age: 0,
            lifetime: 0.3,  // 0.3s = 18 frames
            size: 2 + Math.random() * 3
        };
        
        this.particles.push(particle);
    }
}

// Update and render particles
updateParticles(dt) {
    for (let p of this.particles) {
        p.age += dt;
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.vy += 200 * dt;  // Gravity
        
        if (p.age > p.lifetime) {
            // Remove dead particles
            this.particles.splice(this.particles.indexOf(p), 1);
        }
    }
}

renderParticles(ctx) {
    for (let p of this.particles) {
        const fadeOut = 1 - (p.age / p.lifetime);  // Alpha over lifetime
        ctx.globalAlpha = fadeOut;
        ctx.fillStyle = 'rgba(255, 200, 100, 0.8)';  // Warm impact color
        ctx.fillRect(p.x, p.y, p.size, p.size);
    }
    ctx.globalAlpha = 1.0;
}
```

**Tuning Guidelines:**
- Count: 3-5 particles per hit is usually right. 50 particles = visual noise. Less is more.
- Speed: 100-300 px/s is typical. Slower = drifting (good for dust). Faster = sharp impact (good for sparks).
- Lifetime: 0.2-0.5s. Particles that linger too long clutter the screen.
- Spread: particles should radiate outward from impact point, with slight randomness. No two particles identical.
- Gravity: most particles should fall (simulate drops/sparks falling). Don't add gravity to "dust" particles.
- **Anti-pattern:** One particle burst per attack. Vary the count and spread by attack type. A kick should burst differently than a punch.

### 2.7 Squash & Stretch

**What:** Entities briefly scale up/down on impact, movement, or landing to add weight and life to animations.

**Why:** Squash and stretch convey mass, momentum, and elasticity. A character who just jumped should stretch upward (elongate), then squash on landing (compress). An entity taking knockback should squash briefly, then decompress.

**How:**
```javascript
// On jump start:
this.scaleX = 0.95;
this.scaleY = 1.05;  // Squash (compress) downward on takeoff
this.squashTimeRemaining = 0.1;

// While jumping (mid-air):
this.scaleX = 1.0;
this.scaleY = 1.1;  // Stretch (elongate) upward in air

// On landing:
this.scaleX = 1.05;
this.scaleY = 0.9;  // Squash (compress) on impact
this.squashTimeRemaining = 0.15;

// Recover to normal over time:
if (this.squashTimeRemaining > 0) {
    this.squashTimeRemaining -= dt;
    const lerpFactor = this.squashTimeRemaining / 0.15;
    
    // Interpolate scale back to (1, 1)
    this.scaleX = 1.0 + (this.scaleX - 1.0) * lerpFactor;
    this.scaleY = 1.0 + (this.scaleY - 1.0) * lerpFactor;
}

// Render with scale applied:
ctx.save();
ctx.scale(this.scaleX, this.scaleY);
this.drawBody(ctx);
ctx.restore();
```

**Squash & Stretch by Event:**

| Event | Scale | Duration | Feel |
|-------|-------|----------|------|
| Jump takeoff | 0.95x, 1.05y | 0.1s | Coiling, stored energy |
| Airborne | 1.0x, 1.1y | Ongoing | Elongation, weightlessness |
| Landing | 1.05x, 0.9y | 0.15s | Impact compression |
| Knockback hit | 0.9x, 1.1y | 0.2s | Vertical stretch from impact |
| Dash start | 0.95x, 1.05y | 0.08s | Quick compression, release |
| Damage taken | 0.85x, 1.15y | 0.2s | Significant recoil |
| Death | 0.5x, 1.5y → 0x | 0.4s | Collapse, then fade |

**Tuning Guidelines:**
- Squash/stretch should be **subtle:** 5-15% scale change, not 50%.
- Duration should match the event significance: light events 0.1s, heavy events 0.2s.
- Always recover to scale (1, 1) smoothly. Abrupt snap-back feels mechanical.
- **Anti-pattern:** Constant squash and stretch. Apply it to *discrete* events (land, hit, dash), not ongoing states.
- **Contrast:** If the player jumps with squash, they should see stretch in the air, then squash on landing. The contrast is what sells the weight.

### 2.8 Sound Sync (Audio-Visual Timing)

**What:** Sound effects MUST be frame-synced with visual feedback. Even 2-3 frames of desync feels wrong to the player's nervous system.

**Why:** The human brain processes audio and visual information in parallel. A 33ms (2-frame) delay between sound and image registers as "wrong" — not consciously, but proprioceptively.

**How:**
```javascript
// On attack impact (SAME LINE OF CODE):
const hitResult = checkHitDetection(...);

if (hitResult.hit) {
    // Hitlag freeze
    this.applyHitlag(4);  // 4 frames
    
    // Flash
    target.applyFlash(0.1);
    
    // Particles
    this.spawnImpactParticles(target.x, target.y, 4);
    
    // SOUND — fired at the SAME time as visual effects
    this.audioEngine.playSound('impact', {
        volume: hitResult.damage / 100,  // Louder for bigger hits
        pan: target.x,  // Spatial audio = hit location
        pitch: 0.8 + (hitResult.damage / 100) * 0.4  // Vary pitch by damage
    });
    
    // Knockback
    target.applyKnockback(hitResult.knockbackForce);
}
```

**Anti-Patterns & Fixes:**

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Sound in update, visual in render | 16-17ms desync | Play sound immediately on event, not deferred |
| Separate audio timing logic | Sound delayed | Consolidate: same function triggers all |
| Using `setTimeout()` for audio | Variable latency | Use frame-synced audio system (Web Audio API, Godot's built-in audio) |
| Different volumes/pitches per hit | Inconsistency | Scale audio parameters by hit type (damage, attack), not randomize |

**Audio Feedback Design:**

| Hit Type | Sound Profile | Volume | Pitch | Pan |
|----------|--------------|--------|-------|-----|
| Light jab | Sharp click | 0.6 | High (1.2) | Spatial (hit location) |
| Heavy punch | Deep thud | 0.9 | Low (0.8) | Spatial |
| Kick | Swish + impact | 0.8 | Medium (1.0) | Spatial |
| Special | Chime + bass | 1.0 | Multi-layer | Center |
| Block | Metallic ping | 0.5 | High (1.3) | Spatial |
| Player hit | Sharp sting | 0.7 | High (1.1) | Spatial |

**Tuning Guideline:** Record a video of the game with sound OFF, then watch. Can you tell WHAT happened (attack connected vs blocked vs miss) from the visual effects alone? If not, the feedback is insufficient.

### 2.9 Time Manipulation (Slow-Mo & Speed-Up)

**What:** Temporarily scaling the game's `dt` (delta time) to slow or speed up the world around a critical moment.

**When:**
- Slow-mo on kill (0.2-0.3 time scale for 0.3-0.5s, then ramp back to 1.0)
- Slow-mo on dodge/critical hit (0.4-0.6 time scale for 0.15-0.25s)
- Speed-up on critical failure (1.2-1.5 time scale briefly)
- Use sparingly — every slow-mo must feel earned

**How:**
```javascript
applySlowMo(targetTimeScale = 0.2, duration = 0.3) {
    this.slowMoDuration = duration;
    this.slowMoDurationMax = duration;
    this.targetTimeScale = targetTimeScale;
}

update(realDt) {
    if (this.slowMoDuration > 0) {
        this.slowMoDuration -= realDt;  // Slow-mo timer counts in REAL time
        
        // Ramp time scale: stay at target for most of duration, then ramp back
        if (this.slowMoDuration < 0.1) {
            // Ease back to 1.0
            this.timeScale = 1.0 + (this.targetTimeScale - 1.0) * (this.slowMoDuration / 0.1);
        } else {
            this.timeScale = this.targetTimeScale;
        }
    } else {
        this.timeScale = 1.0;
    }
    
    // Game update uses dt * timeScale
    const gameDt = realDt * this.timeScale;
    this.updateGame(gameDt);
}
```

**Time Scale Effects (Examples):**

| Event | Time Scale | Duration | Notes |
|-------|-----------|----------|-------|
| Boss phase transition | 0.1 | 0.5s | Dramatic pause for setup |
| Dodge success | 0.5 | 0.2s | World slows as player escapes |
| Critical hit / finisher | 0.2 | 0.3s | Impact moment feels weighty |
| Enemy death | 0.15 | 0.4s | Ragdoll in slow-mo |
| Narrow dodge | 0.3 | 0.25s | "That was close" feeling |
| Speedup on error | 1.3 | 0.2s | Brief acceleration on failure |

**Tuning Guidelines:**
- Slow-mo should be **rare**. Every slow-mo trivializes impact if overused.
- Time scale 0.1-0.2 = very dramatic (boss intros, phase changes)
- Time scale 0.3-0.5 = moderate (key moments, critical hits)
- Time scale 0.6-0.8 = subtle (barely noticeable, use for minor emphasis)
- Ramp back to 1.0 smoothly (0.1-0.15s) or it feels like a hitch.
- **Anti-pattern:** Constant slow-mo. Slows skill expression, feels cheap.
- **Rule:** Slow-mo is flavor for already-satisfying moments. It doesn't fix bad mechanics.

---

## 3. Patterns by Game Event

Here's how to apply juice to common gameplay moments. Each pattern is a starting point — tune values based on your game's tone.

### 3.1 Attack Connects (Melee Hit)

**Goal:** Make the player FEEL the impact.

**The Layered Pattern:**

```javascript
// Pseudo-code order of operations (same frame):
1. Hitlag (freeze both attacker + target, 4f)
2. Screen shake (3px, 0.1s)
3. Hit flash (target turns white, 0.067s)
4. Knockback velocity applied (300 px/s)
5. Sound (impact SFX, volume scaled to damage)
6. Particles (4 sparks radiating outward)
7. Hitstun state entered (0.4s)
8. Score/combo counter increments (visual feedback on HUD)
```

**Code Example (Beat 'Em Up):**

```javascript
Combat.handlePlayerAttack(attackState, target) {
    const attackStats = {
        'punch': { damage: 10, knockback: 150, hitlag: 3 },
        'kick': { damage: 15, knockback: 250, hitlag: 4 },
        'special': { damage: 25, knockback: 400, hitlag: 5 }
    };
    
    const stats = attackStats[attackState] || attackStats['punch'];
    
    // 1. Hitlag
    this.applyHitlag(stats.hitlag);
    
    // 2. Screen shake
    this.camera.shake(3, 0.1);
    
    // 3. Flash
    target.flash(0.067);
    
    // 4. Knockback
    target.velocity.x = (target.x > player.x ? 1 : -1) * stats.knockback;
    
    // 5. Sound
    this.audio.play('hit_impact', { pitch: 0.9 + (stats.damage / 30) * 0.2 });
    
    // 6. Particles
    this.particles.burst(target.x, target.y, 4);
    
    // 7. Hitstun
    target.state = 'hit';
    target.hitstunTime = 0.4;
    
    // 8. Combo tracking
    player.comboCount++;
}
```

**Variation by Attack Weight:**

| Attack Type | Hitlag | Shake (px) | Knockback | Particles | Hitstun | Feel |
|------------|--------|-----------|-----------|-----------|---------|------|
| Light jab | 2f | 1-2 | 100 | 2 | 0.2s | Sharp, quick |
| Medium punch | 4f | 3 | 200 | 4 | 0.4s | Solid, impactful |
| Heavy attack | 6f | 5 | 350 | 6 | 0.6s | Weighty, devastating |
| Grab/throw | 4f | 4 | 300 | 5 | N/A (throw launches) | Satisfying grab |

### 3.2 Player Jumps

**Goal:** Convey takeoff power, airtime weightlessness, and landing impact in sequence.

**Three Phases:**

**Phase 1: Takeoff (frame 0-3)**
```javascript
// On jump input
this.state = 'jump';
this.jumpVelocity = 400;  // px/s upward
this.scaleX = 0.95;       // Squash downward
this.scaleY = 1.05;
this.squashTime = 0.08;
this.audio.play('jump_whoosh', { pitch: 0.95 });
this.particles.burst(this.x, this.y + 20, 2, 'dust');
```

**Phase 2: Airborne (frame 4+)**
```javascript
// While jumping
this.scaleY = 1.1 + (this.jumpVelocity / 400) * 0.1;  // Stretch upward
this.scaleX = 1.0;  // Return to normal width
```

**Phase 3: Landing (frame when y >= ground)**
```javascript
// Landing
this.scaleX = 1.05;  // Stretch horizontally
this.scaleY = 0.85;  // Squash on impact
this.squashTime = 0.12;
this.audio.play('land_thud', { pitch: 0.8 });
this.camera.shake(2, 0.08);
this.particles.burst(this.x, this.y + this.height, 4, 'dust');
this.state = 'idle';
```

**Anti-Pattern:** No landing feedback. Jump with only takeoff and airborne feel, but no landing impact = float feeling.

### 3.3 Player Takes Damage

**Goal:** Make the player feel vulnerable and hurt, not just lose numbers.

**The Pattern:**

```javascript
takeDamage(damage) {
    this.health -= damage;
    
    // 1. Red flash (distinct from hit feedback)
    this.flashColor = 'red';
    this.flashTime = 0.15;
    
    // 2. Screen shake (asymmetric — hit from which direction?)
    const hitDirection = (this.x < attacker.x) ? -1 : 1;
    this.camera.shake(4 * Math.abs(hitDirection), 0.12);
    
    // 3. Knockback (player pushed back)
    this.velocity.x = hitDirection * 200;
    
    // 4. Invulnerability / hitstun
    this.state = 'hit';
    this.hitstunTime = 0.4;
    this.invulnTime = 2.0;  // Longer invuln than hitstun
    this.invulnBlink = 0.08;  // Blink every 80ms
    
    // 5. Sound (different from impact SFX)
    this.audio.play('player_hit_pain', { pitch: 0.95 });
    
    // 6. Particle burst (blood/impact, not sparks)
    this.particles.burst(this.x, this.y, 3, 'blood');
}

update(dt) {
    // Invulnerability blink
    if (this.invulnTime > 0) {
        this.invulnTime -= dt;
        this.blinkTimer -= dt;
        
        if (this.blinkTimer <= 0) {
            this.blinkTimer = this.invulnBlink;
            this.visible = !this.visible;  // Toggle visibility
        }
    }
}
```

**Damage Intensity by Severity:**

| Damage Type | Flash Color | Screen Shake | Knockback | Hitstun | Particle Type | Audio Pitch |
|-------------|-------------|--------------|-----------|---------|---------------|-------------|
| Light hit | Red (faint) | 2px | 100 | 0.2s | Spark/dust | High (1.1) |
| Medium hit | Red | 3-4px | 200 | 0.4s | Impact dust | Normal (1.0) |
| Heavy hit | Red (bright) | 5px | 300 | 0.6s | Blood/debris | Low (0.85) |
| Critical hit | Red+Yellow | 6px | 400 | 0.8s | Burst | Very low (0.7) |

### 3.4 Enemy Dies

**Goal:** Reward the player with a satisfying moment of victory.

**The Pattern:**

```javascript
takeDamage(damage) {
    this.health -= damage;
    
    if (this.health <= 0) {
        // 1. Large hitlag (6-8 frames)
        this.game.applyHitlag(7);
        
        // 2. Intense screen shake (6px, 0.2s)
        this.game.camera.shake(6, 0.2);
        
        // 3. Death animation (ragdoll physics, fall state)
        this.state = 'dead';
        this.velocity.y = -200;  // Launch upward briefly
        this.rotationVelocity = 720;  // Spin
        
        // 4. Particle burst (larger, more particles)
        this.game.particles.burst(this.x, this.y, 8, 'explosion');
        
        // 5. Audio (victory chime + bass hit)
        this.game.audio.play('enemy_death_chime', { pitch: 1.2 });
        this.game.audio.play('bass_thud', { volume: 0.7 });
        
        // 6. Score/XP popup (visual reward feedback)
        this.game.ui.showScorePopup(this.scoreValue, this.x, this.y);
        
        // 7. Slow-mo (optional, for dramatic moments)
        this.game.applySlowMo(0.15, 0.5);
        
        // 8. Remove from game
        setTimeout(() => { this.remove(); }, 1.0);
    }
}
```

**Enemy Death Intensity:**

| Enemy Type | Hitlag | Screen Shake | Particles | Slow-Mo | Audio Layers | Feel |
|-----------|--------|--------------|-----------|---------|--------------|------|
| Small mook | 4f | 2px | 4 | No | Single hit | Quick, crisp |
| Medium enemy | 6f | 4px | 6 | Maybe | Hit + chime | Satisfying |
| Boss | 8f | 6px | 10+ | Yes | Hit + chime + fanfare | VICTORY |

### 3.5 Boss Phase Transition

**Goal:** Build dramatic tension, pause for setup, telegraph the new phase.

**The Pattern:**

```javascript
transitionPhase(newPhaseNumber) {
    // 1. Dramatic pause (slow-mo)
    this.game.applySlowMo(0.1, 0.6);
    
    // 2. Camera zoom (emphasize boss)
    this.game.camera.zoomTo(1.5, 0.4);
    
    // 3. Screen shake (held, building tension)
    this.game.camera.shake(2, 0.6, { hold: true });
    
    // 4. Boss animation change (telegraph new behavior)
    this.state = 'phase_' + newPhaseNumber;
    this.playAnimation('phase_transition');
    
    // 5. Audio (dramatic music swell, warning sound)
    this.game.audio.stop('combat_music');
    this.game.audio.play('phase_transition_warning', { volume: 0.8 });
    this.game.audio.play('combat_music_phase_' + newPhaseNumber);
    
    // 6. Visual indicator (text/icon telegraph)
    this.game.ui.showPhaseAlert('PHASE ' + newPhaseNumber);
    
    // Return to normal after pause
    setTimeout(() => {
        this.game.camera.returnToNormal(0.3);
        this.game.camera.shake(0, 0);  // Stop shaking
    }, 0.6);
}
```

### 3.6 UI Interaction

**Goal:** Make buttons and menus feel responsive and alive.

**Button Press Pattern:**

```javascript
class Button {
    onMouseDown() {
        // 1. Scale squash (compressed)
        this.scale = 0.9;
        
        // 2. Sound (click)
        this.game.audio.play('ui_click', { pitch: 1.1, volume: 0.6 });
        
        // 3. Callback (execute button action)
        this.callback();
    }
    
    onMouseUp() {
        // 4. Scale bounce (decompress)
        this.scale = 1.0 + 0.1;  // Overshoot
        this.scaleLerpTime = 0.15;
    }
    
    update(dt) {
        // Ease scale back to 1.0
        if (this.scaleLerpTime > 0) {
            this.scaleLerpTime -= dt;
            this.scale = 1.0 + (0.1 * (this.scaleLerpTime / 0.15));
        }
    }
}
```

**Menu Transition Pattern:**

```javascript
transitionMenu(fromScene, toScene) {
    // 1. Exit transition (slide out)
    this.tweenPosition(fromScene, { x: -500 }, 0.3);
    
    // 2. Audio (transition whoosh)
    this.game.audio.play('menu_transition', { pitch: 1.1 });
    
    // 3. Enter transition (slide in)
    toScene.position.x = 500;  // Start off-screen
    this.tweenPosition(toScene, { x: 0 }, 0.3);
    
    // 4. Optional: dim the background
    this.tweenAlpha(fromScene, 0.3, 0.2);
}
```

---

## 4. Tuning Guidelines

### The 60fps Rule

At 60fps, **1 frame = 16.67ms**.

Most juice effects should last **2-8 frames (33-133ms)**:
- 2f (33ms) = almost instantaneous (flash, short particles)
- 4f (67ms) = perceptible, quick (hitlag, land squash)
- 6f (100ms) = noticeable, snappy (screen shake, long flash)
- 8f (133ms) = feels slow if longer (use for dramatic moments only)

**Rule:** If an effect lasts > 300ms, it's not juice — it's animation.

### Start Subtle, Then Dial Up

**The Juice Dial:**
1. Implement juice at 50% of what you think is right
2. Test it in-game
3. If it feels weak, increase amplitude by 20-30%
4. Repeat until it feels right
5. **Never** go above 150% of baseline

This applies to:
- Screen shake amplitude (start 2px, dial to 3-5px)
- Flash duration (start 4f, dial to 6-8f)
- Knockback force (start 200px/s, dial to 250-350px/s)
- Particle count (start 2, dial to 4-6)

**Anti-pattern:** "This needs MORE juice" → add 50% amplitude all at once. Now your game feels chaotic. Increment by 10-20% each time.

### Layer, Don't Stack

**Stacking (wrong):** One big dramatic effect
```
Attack connects → Massive screen shake (10px) → Done
```

**Layering (right):** 3-4 subtle effects combine
```
Attack connects →
  + Hitlag (4f)
  + Screen shake (3px)
  + Flash (white, 6f)
  + Knockback (steady deceleration)
  + Particles (3 sparks)
  + Sound (impact + sustain layer)
```

The combination is > sum of parts. Each effect alone is subtle. Together, they're punchy.

### Toggle Test: The Gold Standard

**Create a debug toggle that disables ALL juice effects:**

```javascript
class GameConfig {
    enableJuice = true;  // Toggle this in debug menu
}

// In every juice effect:
if (!config.enableJuice) return;

applyHitlag(frames) {
    if (!config.enableJuice) return;
    // ... apply hitlag
}

applyScreenShake(amplitude, duration) {
    if (!config.enableJuice) return;
    // ... apply shake
}
```

**Then play the game with juice ON and OFF:**

- **No juice:** Does the game feel slow, unresponsive, weightless?
- **With juice:** Does it feel snappy, impactful, alive?

**If the difference is < 30%, your juice implementation is weak.** If it's > 50%, you're over-juicing.

Target: **40-50% improvement from juice alone** (relative to baseline mechanics).

---

## 5. Anti-Patterns

Mistakes we made so you don't:

### 5.1 Juice Fatigue

**Problem:** EVERYTHING shakes, flashes, and showers particles. After 10 seconds, the player is numb to all feedback.

**Symptom:** "The game feels chaotic and I can't tell what's important."

**Fix:**
- Reserve dramatic juice (large screen shake, slow-mo, long hitstun) for critical moments
- Scale juice by event significance
  - Normal enemy hit: 2-3px shake, 3f flash
  - Boss hit: 5-6px shake, 7f flash
  - Boss phase transition: 6-8px shake, slow-mo, 1s pause

### 5.2 Desync (Audio-Visual)

**Problem:** Sound effect plays 3 frames AFTER the visual impact. The moment feels broken.

**Symptom:** "The hit feels delayed" or "something's off but I can't tell what"

**Fix:**
- Sound and visual MUST be triggered on the same frame
- Never use `setTimeout()` for juice audio (variable latency)
- Use frame-synced audio system (Web Audio API, Godot's built-in)

**Test:** Record a gameplay clip without sound, add sound in post. Does it look in-sync? If not, your game code has timing issues.

### 5.3 Constant Motion

**Problem:** Screen shake never stops. Background is in perpetual motion.

**Symptom:** "I'm getting nauseous" or "I can't read the screen because it won't stop moving"

**Fix:**
- Shake must have a clear start and end (duration parameter)
- Between juice moments, the game should be STILL
- Rule: If shake lasts > 0.3s, it's too long

### 5.4 Copy-Paste Juice

**Problem:** Every hit has the same particle effect, same sound, same knockback. All attacks feel identical.

**Symptom:** "The game feels repetitive" or "attacks don't feel distinct"

**Fix:**
- Vary juice by attack type:
  - Punch: white flash, spark particles, low-mid audio pitch
  - Kick: yellow-orange flash, dust particles, lower audio pitch
  - Special: multi-color flash, larger particle burst, unique audio layer

| Attack | Flash Color | Particles | Audio | Knockback | Feel |
|--------|------------|-----------|-------|-----------|------|
| Punch | White | Sparks | Sharp click | 200 | Quick jab |
| Kick | Yellow | Dust | Deep thud | 300 | Spinning impact |
| Special | Rainbow/multi | Burst | Multi-layer | 400 | Powerful |

### 5.5 Juice on Non-Events

**Problem:** Applying full juice effects to trivial actions (menu clicks, low-damage hits, ambient effects)

**Symptom:** "Everything feels over-designed. Nothing stands out."

**Fix:**
- Reserve full juice (hitlag + screen shake + particles) for **meaningful** events
- Categorize events by significance:
  - **Critical:** Boss phase, player death, major victory → Full juice
  - **Major:** Normal enemy hit, player hit, important ability → 70% juice
  - **Minor:** UI click, low-damage tick → 30% juice
  - **Ambient:** Background animation, idle movement → 0% juice

### 5.6 Ignoring Knockback Direction

**Problem:** Enemies always knock back the same direction, regardless of where they were hit from.

**Symptom:** "Physics feels wrong. Something pushed the enemy sideways even though I hit them from above."

**Fix:**
- Knockback direction should always be AWAY from attacker
- Include bounce/upward velocity on some attacks
- Scale knockback by attack type and enemy weight

```javascript
// RIGHT:
knockbackDirection = normalize(target.position - attacker.position);
target.velocity = knockbackDirection * knockbackForce;

// WRONG:
target.velocity = { x: fixedKnockback, y: 0 };  // Always same direction
```

---

## 6. Implementation Checklist

A priority-ordered list. Implement in this order. Each unlocks the next.

### P0 (Essential)

- [ ] **Hitlag** (highest ROI)
  - Freeze attacker + target for 2-6 frames on hit
  - Test without it: combat feels weightless
  - Estimated effort: 1-2 hours
  - Code: `applyHitlag(frames)` that pauses entity update

- [ ] **Screen Shake** (amplifies impact)
  - Jiggle camera on critical events (hit, land, death)
  - 2-5px amplitude, 0.1-0.2s duration
  - Estimated effort: 1-2 hours
  - Code: camera offset += sin(time) * amplitude

### P1 (High-Value)

- [ ] **Hit Flash** (visual confirmation of impact)
  - White flash on target, 0.067-0.1s duration
  - Fade in and out smoothly
  - Estimated effort: 30 minutes
  - Code: `target.flash()` with white tint + alpha fade

- [ ] **Sound Sync** (audio-visual bond)
  - Play impact sound frame-synced with visual effects
  - Vary pitch/volume by damage
  - Estimated effort: 30 minutes (if audio system already exists)
  - Code: same event trigger for visual + audio

### P2 (Noticeable)

- [ ] **Particles** (visual flair)
  - 3-5 sparks/dust per hit, radiating outward
  - Lifetime 0.2-0.5s with gravity
  - Estimated effort: 2-3 hours (simple particle system)
  - Code: spawn particles on event, update position/lifetime, fade alpha

- [ ] **Knockback Physics** (communicate weight)
  - Velocity-based knockback with friction/decay
  - Include upward bounce on heavy hits
  - Estimated effort: 1 hour (integrate with physics)
  - Code: `target.velocity = knockbackForce * direction`

### P3 (Polish)

- [ ] **Squash & Stretch** (animation life)
  - Scale entities on jump takeoff/landing, hit, dash
  - 5-10% scale change, 0.1-0.2s duration
  - Estimated effort: 1 hour
  - Code: `entity.scale = lerp(current, target, dt / duration)`

- [ ] **Time Manipulation** (dramatic moments)
  - Slow-mo on kill, dodge, critical hits (optional)
  - 0.1-0.5 time scale, 0.3-0.5s duration
  - Estimated effort: 1-2 hours
  - Code: `gameState.timeScale *= dt_multiplier` in update loop

---

## 7. firstPunch Learnings

What we learned building juice into our first beat 'em up:

### What Worked

1. **Hitlag as the foundation:** Adding 4-6 frame hitlag to attacks instantly transformed combat from floaty to weighty. Single biggest ROI change.

2. **Screenspace feedback hierarchy:**
   - White flash (immediate visual confirmation on hit)
   - Screen shake (felt impact across the screen)
   - Knockback decay (shows momentum and deceleration)
   - Sound sync'd to first frame of flash
   - Particles as garnish (not the main story)

   Together these create a complete feedback loop. Remove any one, and something feels wrong.

3. **Knockback as game feel, not punishment:** Early on, we thought knockback was balance-only (prevent cheap hits). Wrong. Knockback IS feedback. How far an enemy flies tells the player how hard they hit. Combo finisher knockback (1.5x) physically LOOKS more impactful than regular hits.

4. **Audio is half the juice:** Without sound, impact feedback is incomplete. Even a single audio layer (click on light hit, thud on heavy hit) transforms the feel.

### What We'd Do Differently

1. **Implement juice from the start, not at the end:**
   - Early builds were unpolished, so team thought "we'll add juice later"
   - By the time juice was prioritized, combat architecture was set
   - Fix: Budget juice time in P0, not P3

2. **Juice scales with combo count:**
   - Early combos felt repetitive (same juice every hit)
   - We scaled screen shake by combo number (combo hit 1 = 2px shake, hit 3 = 4px, hit 5 = 6px)
   - Creates visual momentum and rewards extended combos
   - Do this from the start

3. **Particle system needed from the start:**
   - Added particles late, had to retrofit
   - If built in early, could have tuned particle appearance and lifetime alongside other juice
   - Build particle system as part of core engine, not as an afterthought

4. **Sound design requires a dedicated specialist:**
   - Procedural audio (Web Audio API) is powerful, but timing/tuning is domain-specific
   - We had sound designer (Greedo) late; if added earlier, audio juice would be higher quality
   - Lesson: Audio domain ownership unlocks higher juice quality

### Our Confidence

Hitlag, screen shake, hit flash, knockback, and sound sync are **proven in shipped code**. We validated them through iteration and playtesting. Game feel checklist in `beat-em-up-combat` skill is derived from this project.

Squash & stretch, particles, and time manipulation are **proven in reference games** (Celeste, SoR4, Hollow Knight) but less extensively validated in our codebase. We'd call them "medium confidence" — likely to work, but not yet hardened by our own iteration.

---

## 8. Genre Applications

This skill is **universal**, but here's how to apply it to specific genres:

### Beat 'Em Up (Our Domain)

- Hitlag: Essential (defines combo feel)
- Knockback: Essential (communicates weight)
- Screen shake: Medium (only on major hits)
- Slow-mo: Rare (boss transitions only)

### Platformer

- Jump feedback: Squash on takeoff + stretch in air + squash on landing (THE essential feedback)
- Knockback: On enemy hit, rarely on environmental hazards
- Time manipulation: Slow-mo on narrow dodge (felt satisfying in Celeste)
- Particles: Landing dust, dash clouds

### Fighting Game (3v3 Arena Style)

- Hitlag: Very high (defines feel at 60fps+)
- Screen shake: Asymmetric (varies by hit location)
- Knockback: Short bursts (keep characters on screen)
- Combo juice: Scales with combo counter

### Puzzle Game

- Apply juice sparingly: match/clear events, level completion
- Avoid constant motion (retains puzzle clarity)
- Use particle bursts as success feedback

### 3D Action (Third-Person)

- Camera movement as juice (not just screen shake)
- Knockback in camera-relative space (not world space)
- Audio spatialization (3D position of impact sound)
- Squash & stretch on character models (rigged deformation)

---

## 9. Cross-References

- **state-machine-patterns** — Juice often triggers state changes (hit → hitstun → idle). Design states with juice in mind.
- **beat-em-up-combat** — Frame data targets; hit timing; anti-patterns from our codebase
- **2d-game-art** — Canvas drawing techniques for particles and visual effects
- **game-qa-testing** — Test juice with the toggle test (see section 4.2). Include juice in regression checklists.
- **godot-beat-em-up-patterns** — Implementation examples in GDScript (camera shake, hitstun, knockback)

---

## 10. Quick Reference: The Juice Checklist

Use this checklist when shipping any game feature with impact:

### Before Shipping an Attack Type

- [ ] Hitlag (freeze on impact)
- [ ] Flash (white or color tint)
- [ ] Screen shake (camera jiggle)
- [ ] Knockback (push target away)
- [ ] Hitstun (target cannot act briefly)
- [ ] Sound (frame-synced audio)
- [ ] Particles (3-5 elements radiating out)
- [ ] Score/feedback (UI confirmation)

### Before Shipping a Movement Action (jump, dash, dodge)

- [ ] Squash on takeoff
- [ ] Stretch while moving
- [ ] Squash on landing
- [ ] Particle burst (dust, dash trail)
- [ ] Sound (whoosh, impact)
- [ ] Visual polish (animation transition)

### Before Shipping an Enemy Death

- [ ] Large hitlag (6-8 frames)
- [ ] Screen shake (5-6px)
- [ ] Particle burst (8+ elements)
- [ ] Death animation (ragdoll, fall)
- [ ] Audio (chime + bass)
- [ ] Score popup
- [ ] Optional: slow-mo + camera zoom

### Before Shipping a Boss Phase

- [ ] Audio (music shift, warning sound)
- [ ] Visual (animation change, UI alert)
- [ ] Camera (zoom, pan)
- [ ] Slow-mo pause (build drama)
- [ ] Particle effect (transition visual)

---

## Confidence Level: `medium`

This skill is validated through:
- **Shipped project:** firstPunch combat implementation (Lando, Ackbar, Yoda)
- **Reference analysis:** Celeste, Streets of Rage 4, Hollow Knight, Enter the Gungeon, Hades (genre research for beat 'em ups + action games)
- **Industry consensus:** Game feel patterns are standard across AAA studios, proven over 30+ years of action game design

The patterns are applicable universally — tested in diverse genres (platformer, beat 'em up, roguelike, action RPG). Not every pattern applies equally (e.g., time manipulation is rare in puzzles), but core techniques (hitlag, screen shake, knockback) are proven across all genres.

**Why not higher?** Boss design, complex time manipulation, and advanced particle effects are referenced from other games but not extensively validated in our own shipped code. Confidence bumps to `high` after we ship a full game with all juice systems tuned and balanced.
