# Ashfall — Sprite Art Vision Guide

> **Author:** Yoda (Game Designer / Vision Keeper)  
> **Purpose:** Creative vision layer for FLUX 1.1 Pro sprite generation  
> **Status:** Sprint 2 Reference Document  
> **Last Updated:** 2026-03-09

This document defines **what Ashfall sprites should FEEL like**. It translates game design pillars and character personality into concrete guidance for AI-generated pixel art. Every FLUX prompt must serve this vision.

---

## Table of Contents

1. [Visual Identity Pillars for Sprites](#1-visual-identity-pillars-for-sprites)
2. [Character Personality in Poses](#2-character-personality-in-poses)
3. [Fighting Game Visual Language](#3-fighting-game-visual-language)
4. [Art Style Reference Board](#4-art-style-reference-board)
5. [Emotion & Intensity Scale](#5-emotion--intensity-scale)
6. [Consistency Rules](#6-consistency-rules)

---

## 1. Visual Identity Pillars for Sprites

These are Ashfall's 5 style pillars, translated from procedural art to pixel art sprite generation:

### Pillar 1: Silhouette First
**In pixel art this means:**
- **Thick, high-contrast outlines** (2-3 pixel black borders) — characters must read against ANY background
- **Distinct body proportions** — Kael is LEAN/TALL, Rhena is WIDE/COMPACT (see exact pixel ratios below)
- **Exaggerated pose angles** — Limbs extend far from body center to create clear negative space
- **No ambiguous overlap** — Every limb position must read as a distinct shape, even at 64×64px thumbnail

**FLUX Prompt Keywords:**  
`thick black outline, high contrast silhouette, bold character design, distinct body shape, exaggerated pose, clear negative space`

---

### Pillar 2: Readable Emotion
**In sprite form this means:**
- **Face detail matters** — Eyes and mouth must be visible even in small sprites (minimum 3×2 pixel eyes, 4px wide mouth)
- **Exaggerated expressions** — Kael's CALM vs Rhena's FIERCE must be obvious from facial features alone
- **Body language over subtlety** — Shoulders, spine angle, and head tilt communicate emotion as much as the face
- **Pose commitment** — Idle poses reflect personality (Kael: composed guard, Rhena: coiled aggression)

**FLUX Prompt Keywords:**  
`expressive face, visible emotions, body language, dynamic posing, character personality, exaggerated expressions`

**Character-Specific:**
- **Kael:** `calm focused eyes, neutral mouth, upright posture, disciplined stance, serene expression`
- **Rhena:** `fierce angry eyes, wide mouth, aggressive stance, coiled energy, intense expression`

---

### Pillar 3: Warm-Dominant Palette
**For sprite generation this means:**
- **Color temperature guidance** — The world of Ashfall is volcanic. Warm tones (oranges, reds, ambers) dominate.
- **Cool tones as accent only** — Kael's blue-ember aura is the ONLY significant cool element. It exists to contrast the warmth.
- **No pure black/white** — Darkest: `#1A0F0A`, Brightest: `#E0DBD1`. Everything stays within the warm-grounded palette.
- **Character palette identity:**
  - **Kael P1:** Grey-white gi (`#E0DBD1`), warm tan skin (`#D9B38C`), blue-ember accents (`#4073D9`)
  - **Rhena P1:** Dark red-black attire (`#331F1A`, `#73261A`), warm tan skin (`#BF8C66`), orange-ember accents (`#F28C1A`)

**FLUX Prompt Keywords:**  
`warm color palette, volcanic tones, amber lighting, orange and red dominance, no pure black or white, earthy colors`

**Character-Specific:**
- **Kael:** `grey white outfit, blue accents, warm tan skin, cool ember aura, disciplined color scheme`
- **Rhena:** `dark red clothing, orange accents, warm tan skin, hot ember aura, intense color scheme`

---

### Pillar 4: Procedural Elegance → Pixel Art Translation
**Original pillar was:** "Clean, intentional, efficient shapes." **In pixel art this becomes:**
- **Clean lines and curves** — No messy anti-aliasing halos. Intentional pixel placement.
- **Minimal unnecessary detail** — If a muscle line or clothing fold doesn't improve readability, cut it.
- **Geometric shapes as foundation** — Characters built from clear circles (head, joints), rectangles (torso, limbs), and triangles (feet, fists). Feels "constructed," not photo-traced.
- **Efficiency = clarity** — Every pixel serves the read. No noise.

**FLUX Prompt Keywords:**  
`clean pixel art, geometric shapes, minimal detail, clear linework, intentional design, no clutter, efficient shapes`

---

### Pillar 5: Escalating Intensity
**How this affects sprites:**
- **Question:** Do Round 1 vs Round 3 sprites need different variants, or is intensity handled by VFX overlay?
- **Answer:** Intensity is handled **primarily by VFX and stage art**, NOT by sprite variants. Sprites remain consistent across rounds.
- **Exception:** Character **ember aura glow** intensity scales with Ember meter (0 Ember = no glow, 100 Ember = bright glow/heat distortion). This is a VFX layer applied to sprites, not baked into the sprite itself.

**Design Intent:**  
Sprites are **emotionally consistent** — a "heavy punch windup" sprite always looks the same. The **context** (stage erupting, ember particles, screen effects) provides the escalation. This keeps sprite count manageable while still delivering the escalating intensity fantasy.

**FLUX Prompt Guidance:**  
Generate sprites at **baseline emotion/intensity**. VFX will add heat distortion, glow, particle overlays, and stage lighting shifts to escalate intensity during gameplay.

---

## 2. Character Personality in Poses

FLUX must capture **character personality through movement**. This is not about frame data — it's about ENERGY.

### Kael — The Cinder Monk (Disciplined Zoner)

**Personality in Motion:**  
Kael moves like a **martial arts master practicing forms alone**. Every motion is deliberate, controlled, precise. No wasted energy. His attacks SNAP into position rather than swing wildly. Recovery is clean — he returns to neutral stance smoothly, never off-balance.

**Idle Stance Energy:**
- Upright posture, spine straight
- Hands near chin in ready guard (not hanging low)
- Weight centered, not leaning
- Head facing forward, gaze steady
- Breathing calm — chest/shoulders relaxed

**Attack Wind-Up Characteristics:**
- **Minimal telegraphing** — Wind-ups are SMALL. Kael doesn't wind up like a baseball pitcher. A punch starts from guard position and extends.
- **Linear trajectories** — Strikes follow straight lines or clean arcs. No wild haymakers.
- **Controlled power** — Heavy attacks show commitment through EXTENSION (fully extended arm, locked elbow), not through exaggerated backswing.

**Recovery Poses:**
- Returns to guard position cleanly
- No stumbling or overextension
- Feet remain planted or step deliberately
- Body doesn't "flail" — every limb knows where it's going

**Contrast to Rhena:**  
Where Rhena EXPLODES into motion, Kael FLOWS into it. Where Rhena overcommits and bleeds momentum, Kael stops exactly where he intends. Kael is **economy of motion** — every pose feels efficient.

**FLUX Prompt Keywords for Kael:**  
`disciplined martial artist, controlled motion, upright posture, precise strikes, clean recovery, calm energy, efficient movement, minimal windup, linear attacks, centered stance, focused expression, no wasted motion`

---

### Rhena — The Wildfire (Explosive Rushdown)

**Personality in Motion:**  
Rhena moves like a **street brawler with something to prove**. Every motion is EXPLOSIVE, momentum-driven, committed. She winds up BIG because she's putting her whole body into it. Attacks SWING in wide arcs. Recovery shows momentum bleed — she has to catch herself, reset her footing. She's AGGRESSIVE.

**Idle Stance Energy:**
- LOW center of gravity — knees bent, weight forward
- Wide stance (feet shoulder-width+ apart)
- Fists raised and CLENCHED
- Head forward, chin down (ready to charge)
- Body COILED — looks like she's about to pounce
- Breathing intense — chest/shoulders tense, ready

**Attack Wind-Up Characteristics:**
- **BIG telegraphing** — Wind-ups are OBVIOUS. Rhena chambers back before exploding forward.
- **Wide arcs** — Punches swing in haymaker curves. Kicks rotate the hips.
- **Full-body commitment** — Shoulders, hips, legs all contribute. She's not just extending a limb — she's throwing her weight.
- **Overshoot on heavy attacks** — Body leans TOO FAR into the strike, showing she's all-in.

**Recovery Poses:**
- Momentum bleed — body continues moving slightly past strike endpoint
- Needs to CATCH balance — foot plants hard, arms swing out for stability
- Not sloppy, but ENERGETIC — she's resetting to charge again, not to stand still
- Expression shifts: attack face (teeth bared) → recovery face (quick breath, refocus)

**Contrast to Kael:**  
Where Kael STOPS exactly at the strike point, Rhena OVERSHOOTS and has to brake. Where Kael extends limbs precisely, Rhena SWINGS them. Where Kael's face stays calm, Rhena's face CHANGES EXPRESSION with every action (neutral → fierce → screaming → back to neutral).

**FLUX Prompt Keywords for Rhena:**  
`explosive street brawler, aggressive motion, low stance, coiled energy, wide swings, momentum-driven attacks, heavy commitment, fierce expression, energetic recovery, overshoot on impact, full-body strikes, intense body language, wild fighting style`

---

## 3. Fighting Game Visual Language

Ashfall follows **classic 2D fighter conventions** that FLUX-generated sprites MUST respect. These are genre expectations that communicate game state to players.

### Impact Frames (Freeze on Hit)
**What:** When an attack CONNECTS, both characters freeze for 1-2 frames to emphasize impact weight.  
**Sprite Requirement:**  
- **Attacker:** Pose shows FULL EXTENSION at strike endpoint. Fist/foot is BURIED in opponent's hurtbox. Face shows EFFORT (gritted teeth, focused eyes).
- **Defender:** Pose shows COMPRESSION — body recoils backward, head snaps in hit direction, limbs react to impact. Face shows PAIN (eyes wide, mouth open, grimace).

**FLUX Prompt Keywords:**  
`impact freeze frame, strike connection, full extension, body compression, recoil motion, pain expression, effort face, contact pose, hit reaction`

---

### Wind-Up Telegraphing (Startup Clarity)
**What:** Opponents need to SEE an attack coming to react. Startup poses must CLEARLY signal "this attack is about to happen."  
**Sprite Requirement:**  
- **Light attacks:** Minimal wind-up. Pose shifts FROM guard TO strike in ~4 frames. Subtle but readable.
- **Medium attacks:** VISIBLE wind-up. Body rotates, arm chambers back, weight shifts. 7-9 frames. Opponent can see and react.
- **Heavy attacks:** OBVIOUS wind-up. LARGE chamber motion — arm pulled WAY back, leg coiled, torso rotated. 12-14 frames. Screams "BIG ATTACK INCOMING."

**Design Rule:** Wind-up size scales with attack power. Heavy attacks are SUPPOSED to be reactable — the wind-up is the game telling you "block or dodge NOW."

**FLUX Prompt Keywords:**  
`attack windup, chambered strike, telegraphed motion, weight shift, coiled power, readable startup, obvious preparation, pre-attack pose`

---

### Recovery Vulnerability (How "Open" a Character Looks)
**What:** After an attack, the character is VULNERABLE. The sprite should LOOK vulnerable.  
**Sprite Requirement:**  
- **Light attack recovery:** Guard quickly returns. Limbs retract, body recenters. Looks "ready again" in 6-8 frames.
- **Medium attack recovery:** Slight overextension. Character is "out" for 10-14 frames. Limbs need to retract, body rebalances. Looks "off-balance" briefly.
- **Heavy attack recovery (WHIFF):** VERY vulnerable. Body is COMMITTED far forward/outward. Takes 16-22 frames to pull back. Looks WIDE OPEN — chest exposed, head forward, back foot trailing.

**Design Rule:** A whiffed heavy attack should LOOK punishable. The sprite communicates "I'm stuck here, hit me."

**FLUX Prompt Keywords:**  
`recovery pose, vulnerable stance, overextension, off-balance, exposed body, slow retraction, committed motion, punishable frame`

---

### Block Poses (Defense vs Aggression)
**What:** Blocking poses communicate defensive state.  
**Sprite Requirement:**  
- **Standing Block:** Arms raised in guard (forearms crossed in front of face/chest). Body upright but braced. Face shows CONCENTRATION (eyes alert, jaw set). NOT passive — this is ACTIVE defense.
- **Crouching Block:** Lower stance, arms guard low and mid. Knees bent deep. Head tucked slightly. Looks COMPACT and protected.

**NOT "Rigid Defense":** Ashfall blocking is ACTIVE, not passive turtling. Block poses should look like the character is BRACING FOR IMPACT, not hiding.

**FLUX Prompt Keywords:**  
`active block pose, defensive guard, braced stance, forearms raised, concentrated expression, protected posture, alert eyes, engaged defense`

---

### Hit Reactions (Hitstun Exaggeration)
**What:** When hit, characters REACT dramatically to show momentum shift and damage.  
**Sprite Requirement:**  
- **Light hit:** Small flinch. Head snaps back slightly, body compresses. Recovers quickly. Eyes widen, mouth opens.
- **Medium hit:** Clear recoil. Upper body leans back, feet slide backward slightly. Face shows pain (grimace, eyes squint).
- **Heavy hit/Launcher:** BIG reaction. Body LIFTS off ground or CRUMPLES. Head whips back, limbs flail outward, mouth opens wide (silent scream). This is DRAMATIC.

**Design Rule:** Hitstun reactions are EXAGGERATED. The opponent needs to FEEL the hit visually. Guilty Gear-level drama, not realistic minimalism.

**FLUX Prompt Keywords:**  
`hit reaction, recoil motion, pain expression, body compression, dramatic flinch, exaggerated damage, impact response, momentum shift, knocked back pose`

---

## 4. Art Style Reference Board

This section describes the **exact art style FLUX should aim for** in words. No image references — only descriptive language.

### Primary Style Target: HD Pixel Art / High-Res Sprite Art

**Description:**  
Think **The Last Blade 2**, **Guilty Gear XX**, or **Garou: Mark of the Wolves**. This is:
- **NOT 8-bit NES pixel art** (too low-resolution, not enough detail)
- **NOT 16-bit SNES pixel art** (close, but we want MORE detail)
- **YES to "HD pixel art"** or **"high-res sprite art"** — 64×64px characters with visible muscle contour, facial features, clothing folds, and anatomy detail. Feels hand-crafted, not procedurally blobby.

**Level of Detail:**
- **Faces:** Eyes have pupils. Mouths have shape (not just a line). Eyebrows are distinct. Facial expressions are CLEAR.
- **Bodies:** Muscle groups are defined (biceps, torso, thighs). NOT bodybuilder-level detail, but athletic anatomy is READABLE.
- **Clothing:** Fabric folds exist. Wraps show texture. Gi fabric has shadow contours. Torn edges look intentionally tattered.
- **Hands/Feet:** Fists are distinct shapes (knuckles visible). Boots have soles, laces, wear details.

---

### Rendering Style: Flat Color + Cel-Shaded Shadows

**Description:**  
- **Base colors are FLAT** — no gradients, no soft airbrush shading, no photorealistic rendering.
- **Shadows use cel-shading** — Hard-edged shadow shapes (2-3 tones max per surface). Shadows have DISTINCT boundaries, like anime/comic book inking.
- **Highlights are MINIMAL** — Small bright spots on fists (ember glow), hair (shine), or metal (boot buckles). Highlights are accent only, not realistic light simulation.
- **Outline is UNIFORM thickness** — 2-3 pixel black border around character. Internal lines (anatomy contours, clothing folds) are 1 pixel and DARK but not pure black.

**Example Description for FLUX:**  
"Flat color base with cel-shaded hard-edge shadows. Two-tone shading per body part. Clean black outline. Minimal highlights as accent. No gradients. No soft shading. Sharp shadow boundaries like anime."

---

### What to AVOID

**DO NOT generate:**
- **3D-rendered sprites** — No pre-rendered CGI look (like Donkey Kong Country or Killer Instinct 2013). Must feel hand-drawn.
- **Photorealistic sprites** — No realistic anatomy, photo textures, or soft lighting. This is stylized art.
- **Chibi / Super-deformed** — No "cute" proportions. Characters are athletic fighters, not SD mascots.
- **Hyper-detailed realism** — No individual skin pores, fabric weave, or photographic detail. Readable stylization over realism.
- **Rotoscoped motion** — No traced-from-video stiffness. Poses should feel POSED, not candid.
- **Blurry anti-aliasing halos** — Pixel edges should be CRISP. No AA glow around characters.

---

### Style Descriptor Summary for FLUX

**Positive prompts:**  
`HD pixel art sprite, high-resolution 2D fighter, hand-drawn style, flat color cel-shaded, clean black outline, detailed anatomy, expressive face, athletic build, sharp shadows, hard-edge shading, visible muscle contour, fabric folds, Last Blade 2 style, Guilty Gear XX style, Neo Geo fighting game aesthetic, 90s arcade fighter quality, SNK sprite art, 64x64 character detail`

**Negative prompts:**  
`3D render, photorealistic, CGI, chibi, super deformed, blurry, soft shading, gradient fill, rotoscoped, low detail, 8-bit NES, pixelated blur, anti-aliasing halo, stiff pose, generic anatomy`

---

## 5. Emotion & Intensity Scale

Character emotion and visual intensity must SCALE across action states. FLUX needs to generate sprites that match these emotional beats.

### Emotional Range by Action State

| State | Kael (Calm Discipline) | Rhena (Fierce Intensity) |
|-------|------------------------|---------------------------|
| **Idle** | Serene, focused. Eyes steady, mouth neutral. Breathing calm. Guard is UP but relaxed. "I'm ready, but not tense." | Coiled aggression. Eyes WIDE, mouth slightly open (ready to snarl). Breathing visible (chest heaves slightly). "I'm about to pounce." |
| **Walk Forward** | Purposeful stride. Eyes locked on opponent. Calm confidence. "I'm closing distance deliberately." | Stalking predator. Shoulders forward, fists TIGHT. Eyes fierce. "I'm coming for you." |
| **Walk Backward** | Controlled retreat. Guard stays high. Eyes still focused. "I'm spacing, not running." | Frustrated repositioning. Jaw clenched, eyes narrowed. "I'll get back in." |
| **Light Attack** | Sharp focus. Eyes narrow slightly, mouth stays neutral. "Precise strike." | Quick snap of aggression. Teeth show briefly, eyes flash. "Fast and mean." |
| **Medium Attack** | Controlled power. Brow furrows, mouth tightens. "Deliberate force." | Rising intensity. Mouth opens (beginning snarl), eyes wider. "Hitting HARD." |
| **Heavy Attack** | Peak controlled effort. Eyes WIDE with focus, mouth opens (sharp exhale). Brow creases. "Full commitment, but disciplined." | EXPLOSIVE fury. Mouth WIDE OPEN (screaming/snarling), eyes HUGE. Veins visible? Face RED with effort. "ALL IN." |
| **Special Move** | Intense focus. Eyes glow faintly (blue ember). Expression is STERN — this is serious. "Channeling power." | Wild ferocity. Eyes glow (orange ember). Face is FIERCE — bared teeth, wide eyes. "UNLEASHING." |
| **Ignition (Super)** | Transcendent calm intensity. Eyes BRIGHT blue glow. Face is RESOLVED — not angry, but CERTAIN. "This ends now." | Peak berserker. Eyes BLAZING orange. Face is SCREAMING — mouth open wide, total commitment. "BURN EVERYTHING." |
| **Blocking** | Concentrated defense. Eyes ALERT, mouth tight. "Reading you." | Frustrated bracing. Teeth GRITTED, eyes annoyed. "I'll get my turn." |
| **Hit (Taking Damage)** | Pain but controlled. Eyes WIDE (shock), mouth opens (grunt). Still looks composed. "That hurt, but I'm still here." | Raw pain reaction. Eyes CLENCH shut, mouth WIDE (yell). Face contorts. "DAMN that hurt!" |
| **Knockdown** | Momentary defeat. Eyes half-closed, expression neutral. Breath knocked out. "Recovering…" | Angry frustration. Eyes OPEN (pissed off), mouth snarling. "Get up NOW." |
| **KO (Defeat)** | Acceptance. Eyes closed, face calm even in loss. "I fought well." | Defiant fury even in loss. Eyes still OPEN (glaring), mouth twisted (growl). "This isn't over." |
| **Win (Victory)** | Quiet satisfaction. Small smile, eyes calm. Returns to neutral stance. "Good fight." | Triumphant roar. Arms raised, mouth WIDE (yelling victory), eyes BLAZING. "HELL YEAH!" |

---

### Intensity Scaling Rules

1. **Kael NEVER loses composure.** Even at peak intensity (Ignition, KO), his face shows CONTROL. Anger is focused, not wild.
2. **Rhena is ALWAYS intense.** Even idle, she looks ready to explode. At peak, she's full berserker.
3. **Ember glow = power state.** When Ember is high (75-100), characters' eyes and fists GLOW with their color (blue for Kael, orange for Rhena). This is VFX overlay but can be baked into "powered-up" sprite variants.
4. **Winning/losing tells story.** Victory and defeat poses MATTER. They're the punctuation on the fight narrative.

---

## 6. Consistency Rules

These elements **MUST remain constant across ALL frames, poses, and variants.** Inconsistency breaks visual identity.

### Kael — Non-Negotiable Constants

| Element | Rule |
|---------|------|
| **Body Proportions** | Head radius: 7px. Shoulder width: 12px. Torso width: 11px. Arm thickness: 3.5px. Leg thickness: 4px. Fist radius: 3px. Boot size: 6×5px. Height: 64px (idle stance). **NEVER DEVIATE.** |
| **Hair** | Dark brown/black. Tied back in ponytail. Hair cap covers top/sides, ponytail extends behind head. ALWAYS present, ALWAYS same shape. |
| **Outfit Colors** | P1: Grey-white gi (`#E0DBD1`), dark belt (`#332E26`), brown boots (`#4D4033`). Forearm wraps (`#A69980`). **NO color shifts.** |
| **Facial Features** | Eyes: horizontal dark lines (calm). Mouth: neutral straight line (default). Skin: warm tan (`#D9B38C`). |
| **Ember Color** | Blue (`#4073D9`). NEVER orange. NEVER red. Blue is Kael's identity. |
| **Silhouette** | LEAN and TALL. Vertical read. Narrow shoulders. If Kael ever looks "bulky," it's wrong. |

---

### Rhena — Non-Negotiable Constants

| Element | Rule |
|---------|------|
| **Body Proportions** | Head radius: 7px. Shoulder width: 14px. Torso width: 13px. Arm thickness: 4.5px. Leg thickness: 5px. Fist radius: 3.5px. Boot size: 7×6px. Height: 62px (idle stance, SHORTER than Kael due to low crouch). **NEVER DEVIATE.** |
| **Hair** | Dark red-brown (`#A6331A`), SHORT and WILD (spiky chaos). Never smooth. Never long. ALWAYS messy. |
| **Outfit Colors** | P1: Near-black tank (`#331F1A`), dark red pants (`#73261A`), dark boots (`#38261A`). Hand wraps (`#8C5940`). **NO color shifts.** |
| **Scars** | Burn scars on both arms. Diagonal scar lines, semi-transparent red-brown (`#99594D` @ 70%). ALWAYS visible. These are IDENTITY MARKERS. |
| **Facial Features** | Eyes: wide, fierce, dark (`#261A14`). Mouth: varies by emotion (snarl/yell/grin). Skin: warm tan (`#BF8C66`), slightly deeper than Kael. |
| **Ember Color** | Orange (`#F28C1A`). NEVER blue. NEVER cold tones. Orange/red-hot is Rhena's identity. |
| **Silhouette** | WIDE and COMPACT. Horizontal read. Broad shoulders, thick limbs. If Rhena ever looks "lean," it's wrong. |

---

### Universal Constants (Both Characters)

1. **Outline thickness: 2-3 pixels, black.** Uniform around character. Internal lines: 1 pixel, dark but not pure black.
2. **No perspective distortion.** Characters are side-view 2D fighters. No 3/4 angle, no foreshortening that breaks the plane.
3. **Feet always on ground plane (unless jumping).** No floating. Feet at Y=280px (stage floor).
4. **Facing direction consistency.** If generating "facing right" sprites, character's LEFT side is visible (right arm forward in neutral stance). FLUX must maintain this consistently.
5. **Pixel resolution target: 64×64px base.** Sprites may be larger (96×96px for full jump arc), but 64×64 is the reference size for detail level.
6. **Animation frame consistency.** If generating a multi-frame sequence (e.g., punch startup → active → recovery), CHARACTER SIZE AND POSITION must remain stable. No "growing" or "shifting" between frames.

---

## Appendix: Quick Reference Checklist for FLUX Prompts

### Before Generating ANY Sprite, Confirm:

- [ ] **Silhouette is distinct** — Can I tell Kael from Rhena by outline alone?
- [ ] **Proportions match spec** — Shoulder width, arm thickness, leg thickness correct?
- [ ] **Emotion matches action state** — Idle = calm/coiled, heavy attack = intense/explosive, etc.
- [ ] **Color palette is correct** — Kael = grey-white + blue, Rhena = dark red + orange?
- [ ] **Outline is thick and black** — 2-3 pixel border, no thin lines?
- [ ] **Style is HD pixel art** — Flat color + cel-shaded, NOT 3D render or chibi?
- [ ] **Pose telegraphs intent** — Can a player read "this is a heavy attack windup" immediately?
- [ ] **Consistency markers present** — Kael's ponytail? Rhena's scars? Correct ember color?

---

## Final Word: The Soul of Ashfall Sprites

**This is not about technical correctness.** FLUX can generate technically perfect pixel art that feels SOULLESS. Ashfall sprites must communicate:

- **Who these characters ARE** — Kael is disciplined calm, Rhena is explosive fury
- **What this fight FEELS like** — Volcanic intensity, escalating stakes, readable combat
- **Why this game is ASHFALL** — Not generic fighter #47. Warm palette, Ember identity, spectator clarity.

Every sprite is a frame in a story. The story is: *"Two warriors fighting in a volcanic forge, where every hit fuels the fire, and the fight itself becomes the spectacle."*

If a sprite doesn't serve that story, it doesn't belong in Ashfall.

---

**END OF VISION GUIDE**

> Next step: Boba (Art Director) will use this vision guide to write FLUX prompts in `SPRITE-ART-BRIEF.md`. Every prompt must reference this document to ensure creative alignment.
