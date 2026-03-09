# Ashfall — Art Direction Document

> **Status:** LOCKED (Sprint 1 M0)
> **Author:** Boba (Art Director)
> **Last Updated:** 2026-03-09
> **Approved By:** Boba (Art Director), Mace (Producer)

This document is the single source of truth for all visual decisions in Ashfall. Every character sprite, stage element, VFX effect, and UI component must conform to the direction established here. Changes require Art Director sign-off.

---

## Table of Contents

1. [Visual References & Style Pillars](#1-visual-references--style-pillars)
2. [Character Silhouettes](#2-character-silhouettes)
3. [Color Palettes](#3-color-palettes)
4. [VFX Character Themes](#4-vfx-character-themes)
5. [Procedural Asset Naming Convention](#5-procedural-asset-naming-convention)
6. [Animation Timing Guide](#6-animation-timing-guide)
7. [Stage Art Direction — EmberGrounds](#7-stage-art-direction--embergrounds)
8. [Technical Constraints](#8-technical-constraints)
9. [Appendix — Quick Reference Tables](#9-appendix--quick-reference-tables)

---

## 1. Visual References & Style Pillars

### Reference Games

| Reference | What We Take From It |
|---|---|
| **Guilty Gear XX** | Expressive character animation, strong silhouette readability, bold outlines, exaggerated poses that telegraph intent |
| **The Last Blade 2** | HD pixel art warmth, weapon-trail elegance, grounded martial-arts motion, atmospheric stage storytelling |

We are NOT making pixel art. Our art is **procedural GDScript `_draw()` code** — every pose is constructed from geometric primitives (ellipses, lines, polygons) at runtime. The references inform *feel*, not technique.

### Style Pillars

| Pillar | Description |
|---|---|
| **1. Silhouette First** | Every character must be identifiable by outline alone at 64×64px. If you squint and can't tell who's who, the design fails. |
| **2. Readable Emotion** | Pose and expression must communicate intent within 2 frames. Kael's calm vs Rhena's fury should be felt, not analyzed. |
| **3. Warm-Dominant Palette** | Ashfall is a volcanic world. Cool tones exist only as contrast (Kael's blue-ember accents). The overall palette leans warm — oranges, reds, ambers, obsidian. |
| **4. Procedural Elegance** | Art is code. Shapes should be clean, intentional, and efficient. No over-detailed geometry that tanks performance. Every draw call earns its place. |
| **5. Escalating Intensity** | Visual energy increases across rounds. Round 1 is dormant embers. Round 3 is volcanic eruption. This applies to stage, VFX density, and color saturation. |

### Rendering Approach

- All character art uses Godot's `_draw()` API via `CharacterSprite` base class
- Drawing primitives: `draw_polygon()`, `draw_circle()`, `draw_line()`, `draw_arc()`, custom helpers (`draw_ellipse()`, `draw_limb()`, `draw_fist()`, `draw_boot()`)
- No external PNG sprites for characters — everything is runtime geometry
- Stage elements also procedural (`_draw()` in stage scripts)
- Deterministic rendering: seeded RNG for procedural details (crack patterns, ember positions)

---

## 2. Character Silhouettes

### Design Philosophy

Kael and Rhena must be **instantly distinguishable** at every scale. Their body proportions, stances, and motion profiles are designed to read as different archetypes from the first frame.

### Kael — The Cinder Monk (Zoner)

**Silhouette Keywords:** Lean, upright, composed, narrow, precise

```
Body Profile (pixels from origin):
┌─────────────────────────────────┐
│  HEAD_R     = 7.0               │  Standard head
│  HEAD_Y     = -52.0             │  Tall stance
│  SHOULDER_W = 12.0              │  NARROW shoulders
│  TORSO_W    = 11.0              │  SLIM torso
│  ARM_THICK  = 3.5               │  Thin, defined arms
│  LEG_THICK  = 4.0               │  Lean legs
│  FIST_R     = 3.0               │  Small, precise fists
│  BOOT       = 6×5 px            │  Modest footwear
└─────────────────────────────────┘
```

**Visual Identity Markers:**
- Hair tied back (dark cap + ponytail line)
- Forearm wraps (2–3 horizontal detail lines)
- Grey-white gi with belt
- Calm, focused eyes (horizontal lines)
- Neutral mouth (straight line)
- Faint blue-ember aura on fists
- Upright posture; hands near chin in idle (guard stance)

**Animation Style:**
- Controlled, precise, clean lines
- Small wind-ups — moves snap into position
- Spacing-focused — reaches forward, retreats cleanly
- Recovery is deliberate, not frantic

### Rhena — The Wildfire (Rushdown)

**Silhouette Keywords:** Muscular, wide, coiled, aggressive, explosive

```
Body Profile (pixels from origin):
┌─────────────────────────────────┐
│  HEAD_R     = 7.0               │  Standard head
│  HEAD_Y     = -50.0             │  LOWER — stockier build
│  SHOULDER_W = 14.0              │  WIDE shoulders (+17% vs Kael)
│  TORSO_W    = 13.0              │  BROAD torso (+18% vs Kael)
│  ARM_THICK  = 4.5               │  THICK arms (+29% vs Kael)
│  LEG_THICK  = 5.0               │  THICK legs (+25% vs Kael)
│  FIST_R     = 3.5               │  BIGGER fists (+17% vs Kael)
│  BOOT       = 7×6 px            │  Heavy combat boots
└─────────────────────────────────┘
```

**Visual Identity Markers:**
- Wild short hair (chaotic spikes via `_draw_wild_hair()`)
- Sleeveless tank top with torn edges
- Burn scars on arms (diagonal scar lines)
- Dark red/black attire
- Angry/fierce eyes, wide-open mouth
- Orange-ember aura on fists (more saturated than Kael)
- Low center of gravity; wide stance in idle
- Multiple expression states: `_draw_head_fierce()`, `_draw_head_attacking()`, `_draw_head_screaming()`

**Animation Style:**
- Wide, aggressive wind-ups
- Messy, momentum-driven overshoot
- Big swings — moves carry weight
- Recovery has visible momentum bleed

### Silhouette Comparison

```
    KAEL                    RHENA
    ╭─╮                    ╭─╮
   ╭┤ ├╮                  ╭┤ ├╮
   │╰─╯│                 ╭┤╰─╯├╮       ← wider shoulders
   ├───┤                  ├─────┤       ← broader torso
   │   │                  │     │
   ├───┤                  ├─────┤
   │ │ │                  ││   ││       ← thicker legs
   ╰─┴─╯                 ╰┴───┴╯       ← bigger boots

  LEAN, TALL              WIDE, COMPACT
  12px shoulders          14px shoulders
  11px torso              13px torso
  3.5px arms              4.5px arms
```

**Squint Test:** At 64×64px, Kael reads as a vertical line (tall, narrow), Rhena reads as a horizontal block (wide, grounded). Pass/fail is binary — if silhouettes blur together, proportions must be adjusted.

---

## 3. Color Palettes

### Palette Architecture

Each character has two palettes: **P1** (default) and **P2** (alternate/mirror match). Palettes are stored as `Dictionary` in each character's sprite script and accessed via the `pal` variable from `CharacterSprite` base class.

All colors are specified as Godot `Color(r, g, b)` values (0.0–1.0 range). Hex equivalents are provided for external reference.

### Kael — Cool Discipline

#### P1 Palette (Default)

| Role | Color Value | Hex | Description |
|------|-------------|-----|-------------|
| Skin | `Color(0.85, 0.70, 0.55)` | `#D9B38C` | Warm tan |
| Hair | `Color(0.15, 0.12, 0.10)` | `#261F1A` | Dark brown |
| Outfit Primary | `Color(0.88, 0.86, 0.82)` | `#E0DBD1` | Grey-white gi |
| Outfit Secondary | `Color(0.70, 0.68, 0.64)` | `#B3ADA3` | Gi shadows |
| Accent | `Color(0.25, 0.45, 0.85)` | `#4073D9` | Blue-ember (cool) |
| Accent Glow | `Color(0.4, 0.6, 1.0, 0.6)` | `#6699FF` @ 60% | Ember highlight (blue-biased) |
| Eye | `Color(0.2, 0.2, 0.2)` | `#333333` | Dark, calm |
| Outline | `Color(0.12, 0.10, 0.08)` | `#1F1A14` | Near-black outline |
| Wrap | `Color(0.65, 0.60, 0.50)` | `#A69980` | Forearm wraps |
| Belt | `Color(0.20, 0.18, 0.15)` | `#332E26` | Dark belt |
| Boots | `Color(0.30, 0.25, 0.20)` | `#4D4033` | Brown boots |
| Sole | `Color(0.18, 0.15, 0.12)` | `#2E261F` | Boot sole |

#### P2 Palette (Warm Shift — Mirror Match)

| Role | Color Value | Hex | Description |
|------|-------------|-----|-------------|
| Skin | `Color(0.80, 0.65, 0.48)` | `#CCA67A` | Warmer tan |
| Hair | `Color(0.25, 0.15, 0.08)` | `#402614` | Reddish-brown |
| Outfit Primary | `Color(0.82, 0.75, 0.58)` | `#D1BF94` | Ochre gi |
| Outfit Secondary | `Color(0.68, 0.60, 0.45)` | `#AD9973` | Ochre shadows |
| Accent | `Color(0.85, 0.35, 0.15)` | `#D95926` | Red-ember (warm) |
| Accent Glow | `Color(1.0, 0.5, 0.2, 0.6)` | `#FF8033` @ 60% | Orange glow |
| Eye | `Color(0.2, 0.15, 0.1)` | `#33261A` | — |
| Outline | `Color(0.15, 0.10, 0.05)` | `#261A0D` | — |
| Wrap | `Color(0.55, 0.45, 0.30)` | `#8C734D` | — |
| Belt | `Color(0.25, 0.15, 0.08)` | `#402614` | — |
| Boots | `Color(0.35, 0.22, 0.12)` | `#59381F` | — |
| Sole | `Color(0.22, 0.14, 0.08)` | `#382414` | — |

### Rhena — Hot Intensity

#### P1 Palette (Default)

| Role | Color Value | Hex | Description |
|------|-------------|-----|-------------|
| Skin | `Color(0.75, 0.55, 0.40)` | `#BF8C66` | Warm tan |
| Hair | `Color(0.65, 0.20, 0.10)` | `#A6331A` | Dark red-brown (wild) |
| Outfit Primary | `Color(0.20, 0.12, 0.10)` | `#331F1A` | Near-black tank top |
| Outfit Secondary | `Color(0.45, 0.15, 0.10)` | `#73261A` | Dark red pants |
| Accent | `Color(0.95, 0.55, 0.10)` | `#F28C1A` | Orange-ember (hot) |
| Accent Glow | `Color(1.0, 0.6, 0.15, 0.6)` | `#FF9926` @ 60% | Orange-red glow |
| Eye | `Color(0.15, 0.10, 0.08)` | `#261A14` | Dark, angry |
| Outline | `Color(0.10, 0.06, 0.04)` | `#1A0F0A` | Dark outline |
| Wrap | `Color(0.55, 0.35, 0.25)` | `#8C5940` | Hand wraps (brown-tan) |
| Scar | `Color(0.60, 0.35, 0.30, 0.7)` | `#99594D` @ 70% | Burn scars (semi-transparent) |
| Belt | `Color(0.30, 0.18, 0.12)` | `#4D2E1F` | Dark belt |
| Boots | `Color(0.22, 0.15, 0.10)` | `#38261A` | Dark combat boots |
| Sole | `Color(0.12, 0.08, 0.05)` | `#1F140D` | Boot sole |
| Torn Edge | `Color(0.35, 0.20, 0.15)` | `#593326` | Torn sleeve edge color |

#### P2 Palette (Cool Shift — Mirror Match)

| Role | Color Value | Hex | Description |
|------|-------------|-----|-------------|
| Skin | `Color(0.72, 0.58, 0.45)` | `#B89473` | — |
| Hair | `Color(0.15, 0.20, 0.45)` | `#263373` | Blue-tinted |
| Outfit Primary | `Color(0.10, 0.12, 0.22)` | `#1A1F38` | Blue-black tank |
| Outfit Secondary | `Color(0.12, 0.18, 0.40)` | `#1F2E66` | Blue pants |
| Accent | `Color(0.20, 0.70, 0.95)` | `#33B3F2` | Cyan-frost (cool) |
| Accent Glow | `Color(0.3, 0.8, 1.0, 0.6)` | `#4DCCFF` @ 60% | Cyan glow |
| Eye | `Color(0.10, 0.10, 0.15)` | `#1A1A26` | — |
| Outline | `Color(0.05, 0.05, 0.10)` | `#0D0D1A` | — |
| Wrap | `Color(0.30, 0.35, 0.50)` | `#4D5980` | Blue-tinted wraps |
| Scar | `Color(0.40, 0.35, 0.50, 0.7)` | `#665980` @ 70% | Blue-tinted scars |
| Belt | `Color(0.15, 0.18, 0.28)` | `#262E47` | — |
| Boots | `Color(0.12, 0.14, 0.22)` | `#1F2438` | — |
| Sole | `Color(0.06, 0.07, 0.12)` | `#0F121F` | — |
| Torn Edge | `Color(0.18, 0.22, 0.35)` | `#2E3859` | — |

### Palette Rules

1. **P1 palettes are canon.** P2 exists only for mirror matches (same character vs same character).
2. **Accent color is identity.** Kael = blue. Rhena = orange. This carries through to VFX, damage numbers, and ember aura.
3. **Outline color is per-character**, not global. Kael's outline is warmer (`#1F1A14`), Rhena's is cooler/darker (`#1A0F0A`).
4. **Skin tones must remain distinct.** Kael is lighter tan, Rhena is deeper warm tan.
5. **No pure black (`#000000`) or pure white (`#FFFFFF`).** Darkest value: `#0D0D1A`. Brightest value: `#E0DBD1`. This keeps the visual within the warm-dominant world.

---

## 4. VFX Character Themes

### Philosophy

Every VFX effect in Ashfall is **character-tinted**. When Kael lands a hit, the sparks are blue. When Rhena lands a hit, the sparks are orange-red. This reinforces character identity during fast gameplay and lets spectators track who's winning the exchange.

VFX palettes are managed in `vfx_manager.gd` and triggered via `EventBus` signals.

### Kael VFX — Blue Ember (Controlled, Meditative)

**Behavior:** Upward-floating embers. Tight spread. Particles linger and fade gracefully.

| Parameter | Value | Description |
|---|---|---|
| Spark Start | `Color(0.5, 0.8, 1.0, 1.0)` / `#80CCFF` | Cool blue ignition |
| Spark End | `Color(1.0, 0.6, 0.2, 0.0)` / `#FF9933` @ 0% | Warm orange fade-out |
| Spark Base | `Color(0.4, 0.7, 1.0, 1.0)` / `#66B3FF` | Blue base color |
| Spread | 40° | Tight — controlled, disciplined |
| Velocity | 80–180 px/s | Moderate — measured |
| Gravity | `Vector3(0, -60, 0)` | Slight **upward** drift (embers float up) |
| Particle Bonus | +0 | Standard particle count |
| Damping | 20–40 | Low — particles linger |
| Scale | 1.5–2.5 px | Medium, consistent size |
| KO Start | `Color(0.5, 0.8, 1.0)` / `#80CCFF` | Blue |
| KO End | `Color(1.0, 0.6, 0.2, 0.0)` / `#FF9933` | Warm fade |
| Flash Color | `Color(3.0, 4.0, 5.0)` | HDR blue flash (hitstun overlay) |
| Damage Numbers | `Color(0.4, 0.85, 1.0)` / `#66D9FF` | Cyan |

### Rhena VFX — Red-Orange Ember (Explosive, Chaotic)

**Behavior:** Outward-bursting shards. Wide spread. Particles are fast, heavy, and dramatic.

| Parameter | Value | Description |
|---|---|---|
| Spark Start | `Color(1.0, 1.0, 0.9, 1.0)` / `#FFFFE6` | Hot white ignition |
| Spark End | `Color(1.0, 0.05, 0.0, 0.0)` / `#FF0D00` @ 0% | Deep red burnout |
| Spark Base | `Color(1.0, 0.4, 0.1, 1.0)` / `#FF661A` | Orange base color |
| Spread | 90° | **Wide** — explosive, uncontrolled |
| Velocity | 160–350 px/s | **Fast** — violent burst (+94% vs Kael) |
| Gravity | `Vector3(0, 300, 0)` | Strong **downward** (sparks shower down) |
| Particle Bonus | +4 | **Extra particles** — chaotic density |
| Damping | 15–35 | Rapid damping — quick burst, fast decay |
| Scale | 1.0–4.0 px | **High variance** — chaotic sizing |
| KO Start | `Color(1.0, 0.3, 0.0)` / `#FF4D00` | Hot orange |
| KO End | `Color(0.8, 0.0, 0.0, 0.0)` / `#CC0000` | Deep red |
| Flash Color | `Color(5.0, 2.0, 1.0)` | HDR red flash (hitstun overlay) |
| Damage Numbers | `Color(1.0, 0.3, 0.1)` / `#FF4D1A` | Orange |

### Neutral VFX (Non-Character-Specific)

**Block Spark** (same for all characters):

| Parameter | Value |
|---|---|
| Gradient Start | `Color(0.8, 0.9, 1.0, 1.0)` / `#CCE6FF` — white-blue |
| Gradient End | `Color(0.3, 0.5, 1.0, 0.0)` / `#4D80FF` @ 0% — deep blue |
| Base Color | `Color(0.7, 0.85, 1.0, 1.0)` / `#B3D9FF` |
| Particle Count | 6 |
| Lifetime | 0.25s |

### VFX Summary Table

| Effect | Particles | Lifetime | Character-Tinted? |
|--------|-----------|----------|--------------------|
| Hit Spark (Light) | 8 | 0.3s | ✅ Yes |
| Hit Spark (Medium) | 10 | 0.3s | ✅ Yes |
| Hit Spark (Special) | 12 | 0.3s | ✅ Yes |
| Block Spark | 6 | 0.25s | ❌ Neutral blue-white |
| KO Burst | 16–20 | 0.5s | ✅ Yes |
| KO Freeze | — | 100ms (6 frames) | N/A (game pause) |
| Screen Shake | — | 0.3–0.5s | N/A (camera) |
| Hitstun Flash | — | 2 frames | ✅ Yes (flash color) |

---

## 5. Procedural Asset Naming Convention

### Context

Ashfall does NOT use traditional PNG sprite sheets. All character art is procedural `_draw()` code. However, we maintain naming conventions for:

1. **Pose function names** in sprite scripts (`_draw_{pose}()`)
2. **State identifiers** used by `AnimationPlayer`, `StateMachine`, and `CharacterSprite.pose`
3. **Future export** — if we ever render sprites to PNG for marketing/wiki, the naming standard is ready

### Pose Function Naming

**Format:** `_draw_{state}()`

All pose names are **lowercase with underscores**. The `pose` property on `CharacterSprite` drives which `_draw_` function is called.

### State Name Reference

| Category | State Name | Notes |
|---|---|---|
| **Core Stances** | `idle` | Guard stance (looping) |
| | `walk` | Forward stride (looping) |
| | `walk_2` | Alternate stride phase (looping) |
| | `crouch` | Crouch transition + idle |
| **Air Movement** | `jump_up` | Jump ascent |
| | `jump_peak` | Jump apex |
| | `jump_fall` | Jump descent |
| | `dash` | Forward dash |
| | `backdash` | Backward dash |
| **Standing Attacks** | `attack_lp` | Light Punch |
| | `attack_mp` | Medium Punch |
| | `attack_hp` | Heavy Punch |
| | `attack_lk` | Light Kick |
| | `attack_mk` | Medium Kick |
| | `attack_hk` | Heavy Kick |
| **Crouching Attacks** | `crouch_lp` | Crouching Light Punch |
| | `crouch_mp` | Crouching Medium Punch |
| | `crouch_hp` | Crouching Heavy Punch |
| | `crouch_lk` | Crouching Light Kick |
| | `crouch_mk` | Crouching Medium Kick |
| | `crouch_hk` | Crouching Heavy Kick |
| **Air Attacks** | `jump_lp`, `jump_mp`, `jump_hp` | Air punches |
| | `jump_lk`, `jump_mk`, `jump_hk` | Air kicks |
| **Defense** | `block_standing` | Standing block |
| | `block_crouching` | Crouching block |
| **Damage** | `hit` | Hitstun reaction |
| | `ko` | Knockout |
| | `wakeup` | Recovery from knockdown |
| **Throws** | `throw_execute` | Throw animation (attacker) |
| | `throw_victim` | Throw animation (victim) |
| **Specials** | `special_1` through `special_4` | Character-specific specials |
| | `ignition` | Ultimate move (Ember spend) |
| **Round End** | `win` | Victory pose |
| | `lose` | Defeat pose |

### PNG Export Convention (Future Use)

If sprites are exported for marketing, documentation, or external tools:

```
Format: {character}_{state}_{frame:02d}.png
```

- **character:** lowercase (`kael`, `rhena`)
- **state:** matches state name table above
- **frame:** zero-padded two digits (`01`–`99`)

**Examples:**
```
kael_idle_01.png
kael_attack_hp_05.png
rhena_dash_03.png
rhena_special_1_08.png
```

### Sprite Script File Convention

```
Character sprites:  scripts/fighters/sprites/{character}_sprite.gd
Base class:         scripts/fighters/sprites/character_sprite.gd
VFX manager:        scripts/systems/vfx_manager.gd
Stage scripts:      scripts/stages/{stage_name}.gd
```

---

## 6. Animation Timing Guide

### Game Timing

| Parameter | Value |
|---|---|
| **Physics Tick Rate** | 60 FPS (fixed `_physics_process()`) |
| **Frame Duration** | 16.67ms (1/60th second) |
| **Timing Unit** | Integer frames (not float seconds) |
| **Animation Sync** | All animation timing must align with 60 FPS physics tick |

All frame counts below are in **game frames at 60 FPS**. One frame = 16.67ms.

### Frame Data — Attack Animations

Sourced from `games/ashfall/data/frame-data.csv`. These timings define the visual phases of each attack animation.

| Move | Startup | Active | Recovery | Total Frames | Hitstun | Blockstun |
|------|---------|--------|----------|--------------|---------|-----------|
| Light Punch (LP) | 4 | 2 | 6 | **12** | 10 | 6 |
| Medium Punch (MP) | 6 | 3 | 10 | **19** | 15 | 10 |
| Heavy Punch (HP) | 10 | 4 | 18 | **32** | 25 | 15 |
| Light Kick (LK) | 5 | 3 | 8 | **16** | 12 | 7 |
| Medium Kick (MK) | 7 | 3 | 12 | **22** | 18 | 11 |
| Heavy Kick (HK) | 12 | 5 | 22 | **39** | 30 | 18 |
| Special Move | 15 | 4 | 20 | **39** | 35 | 20 |
| Super Move (Ignition) | 8 | 20 | 40 | **68** | 60 | 40 |

### Animation Phase Visual Cues

| Phase | Visual Requirement |
|---|---|
| **Startup** | Wind-up motion. The character telegraphs the attack. Limbs draw back, weight shifts. Must be readable enough for opponents to react. |
| **Active** | Strike extended. Hitbox geometry visible. Peak of the attack pose. Maximum extension/impact frame. |
| **Recovery** | Return to neutral. The character is vulnerable. Limbs retract, balance recovers. Longer recovery = more punishable. |
| **Hitstun** | Opponent recoils. Head snaps back, body compresses. Duration determines combo potential. |
| **Blockstun** | Opponent absorbs. Guard pose held rigid, slight pushback. Shorter than hitstun (block is safe). |

### Non-Attack Animation Frame Counts

| Animation | Frame Count | Type | Notes |
|---|---|---|---|
| Idle | 6–8 | Loop | Subtle breathing/bob cycle |
| Walk | 8 | Loop | Full stride cycle |
| Walk 2 | 8 | Loop | Alternate phase |
| Crouch | 3 transition + 4 idle | Non-loop → Loop | Quick transition to low guard |
| Jump Up | 4 | Non-loop | Ascent |
| Jump Peak | 2 | Non-loop | Apex hang |
| Jump Fall | 4 | Non-loop | Descent |
| Dash | 4 | Non-loop | Forward burst |
| Backdash | 4 | Non-loop | Retreat |
| Block Standing | 2 | Non-loop | Guard snap |
| Block Crouching | 2 | Non-loop | Low guard snap |
| Hit (Light) | 3 | Non-loop | Quick recoil |
| Hit (Heavy) | 5 | Non-loop | Big recoil |
| Hit (Crouch) | 3 | Non-loop | Low recoil |
| Hit (Air) | 4 | Non-loop | Air stagger |
| KO | — | Terminal | Death state (no recovery) |
| Wakeup | 4 | Non-loop | Rising from knockdown |
| Throw Execute | 8 | Non-loop | Grab + slam |
| Throw Victim | 8 | Non-loop | Grabbed + slammed |
| Special 1–4 | 8–12 | Non-loop | Character-specific |
| Ignition | 16–24 | Non-loop | Ultimate — cinematic timing |
| Win | 12 | Non-loop | Victory pose |
| Lose | 8 | Non-loop | Defeat slump |

### Timing Rules for Sprite Authors

1. **Match frame data exactly.** If LP is 4 startup + 2 active + 6 recovery = 12 frames total, the visual must complete in 12 frames at 60 FPS.
2. **Startup must telegraph.** The wind-up phase communicates attack type. Light attacks have almost no wind-up. Heavy attacks have visible preparation.
3. **Active frame = peak extension.** This is the money frame — maximum limb extension, clear hitbox geometry.
4. **Recovery = vulnerability.** Show the character off-balance or resetting. This is where the opponent punishes.
5. **Idle breathing is subtle.** 1–2px vertical bob over 6–8 frames. Do not create distracting motion.
6. **Character differentiation in timing:** Kael's attacks are precise snaps (small arcs). Rhena's attacks are wide swings (large arcs, momentum overshoot).

---

## 7. Stage Art Direction — EmberGrounds

### Concept

The EmberGrounds is a volcanic caldera — cracked obsidian floor, distant volcanoes, rising embers, and a sky that transitions from cold darkness to fiery apocalypse across rounds. The stage is a **visual metaphor for escalating combat intensity**.

### Stage Dimensions

| Parameter | Value |
|---|---|
| Stage Width | 1280 px |
| Stage Height | 720 px |
| Floor Y | 560.0 px (ground surface) |
| P1 Spawn | (320, 560) — left side |
| P2 Spawn | (960, 560) — right side |

### Round Visual Escalation

The EmberGrounds transforms across three rounds, mirroring the Ember System's intensity.

#### Round 1 — Dormant

*The calm before the storm. Cold, quiet, barely alive.*

| Layer | Color Range |
|---|---|
| Sky | `#140805` → `#260F05` (near-black, faint warmth) |
| Lava Glow | Alpha: 0.08 (barely visible) |
| Volcano Silhouettes | `#0D0603` → `#120904` (dark shapes) |
| Ember Particles | Rate: 0.15/sec (sparse) |
| Smoke Density | 0.3 (thin haze) |
| Vignette | 0.0 (none) |

#### Round 2 — Warming

*Heat building. The ground awakens. Orange creeps in.*

| Layer | Color Range |
|---|---|
| Sky | `#260F05` → `#4D1A08` (warming) |
| Lava Glow | Alpha: 0.25 (visible glow) |
| Volcano Silhouettes | `#170A05` → `#331409` (emerging) |
| Ember Particles | Rate: 0.5/sec (moderate) |
| Smoke Density | 0.6 (thickening) |
| Vignette | 0.15 (subtle edge darkening) |

#### Round 3 — Eruption

*Full volcanic fury. Sky burns orange. Embers everywhere. Maximum drama.*

| Layer | Color Range |
|---|---|
| Sky | `#401405` → `#73240A` (full orange sky) |
| Lava Glow | Alpha: 0.55 (intense) |
| Volcano Silhouettes | `#170A05` → `#331409` (lit from below) |
| Ember Particles | Rate: 1.0/sec (dense) |
| Smoke Density | 1.0 (thick, atmospheric) |
| Vignette | 0.4 (dramatic edge framing) |

**Ember System Bonus:** When Ember meter is active, lava alpha gains +0.2 intensity. The stage literally reacts to gameplay momentum.

### Lava Floor (Cracked Obsidian)

Procedural generation using seeded RNG for deterministic rendering.

| Element | Details |
|---|---|
| Base Color | `Color(0.05, 0.04, 0.035)` / `#0D0A09` — dark obsidian |
| Crack Count | 16 procedural cracks (seed: 42) |
| Lava Pools | 5 pools (seed: 77) |
| Texture Patches | 20 surface variations (seed: 99) |
| Crack Glow | Animated pulse: `sin(time × 1.4 + phase) × glow_intensity` |
| Pool Pulse | `sin(time × 1.1 + phase) × glow_intensity` |

### Ember Particles

| Parameter | Value |
|---|---|
| Max Particles | 60 |
| Spawn Zone | x: 40–1240 px, y: 560 ± 5 px (near floor) |
| Drift | Horizontal wave: `sin(age × 2.5 + phase) × 6 px` |
| Velocity X | ±12 px/s (gentle drift) |
| Velocity Y | -45 to -90 px/s (upward float) |
| Size | 1.5–3.5 px radius |
| Lifetime | 2.5–5.0 seconds |
| Color | Orange-to-red gradient, fading with age: `fade = (1 - t)²` |
| Glow Layer | Outer glow at 2.5× radius, 12% alpha |

### Stage Art Rules

1. **No element should compete with fighters.** Stage is backdrop, not foreground. All stage elements sit behind fighters in Z-order.
2. **Escalation must be subtle.** Players should *feel* the change between rounds without being distracted by it. The shift happens during round transition screens, not mid-combat.
3. **Lava glow syncs with Ember meter.** This is the stage-gameplay connection. When Ember is active, the ground burns brighter.
4. **All procedural elements use seeded RNG.** Cracks, pools, and textures are deterministic. Same seed = same visual = no desyncs in future netplay.

---

## 8. Technical Constraints

| Constraint | Value | Rationale |
|---|---|---|
| Viewport | 1920×1080 | Display resolution (upgraded from 720p) |
| Stage Base Resolution | 1280×720 | Internal rendering resolution |
| Character Canvas | 128×128 px | Per-character draw area (scaled to ~200px on-screen) |
| Physics Tick | 60 FPS (16.67ms) | Deterministic simulation requirement |
| Max Particles | 60 (stage) + per-hit VFX | Performance budget |
| Rendering | `_draw()` / Canvas API | No external textures for characters |
| Outline Weight | Per-character (see palette `outline` key) | Softer than pure black — warmer aesthetic |
| Minimum Alpha | 0.0 (fully transparent) | VFX fade-out targets |
| HDR Flash Range | Up to 5.0 per channel | Hitstun flash uses HDR values for bloom effect |
| RNG Seeds | Floor cracks: 42, Pools: 77, Textures: 99 | Deterministic procedural content |

---

## 9. Appendix — Quick Reference Tables

### Character Comparison At-a-Glance

| Attribute | Kael | Rhena |
|---|---|---|
| Archetype | Zoner (spacing, control) | Rushdown (aggression, pressure) |
| Build | Lean, tall stance | Muscular, compact stance |
| Outfit | Grey-white gi, belt, wraps | Black tank (torn), red pants |
| Accent Color | Blue `#4073D9` | Orange `#F28C1A` |
| VFX Theme | Upward blue embers | Outward orange-red bursts |
| VFX Spread | 40° (tight) | 90° (wide) |
| VFX Velocity | 80–180 px/s | 160–350 px/s |
| VFX Gravity | Upward (-60) | Downward (+300) |
| Extra Particles | None | +4 per effect |
| Flash Color | Blue HDR | Red HDR |
| Damage Numbers | Cyan `#66D9FF` | Orange `#FF4D1A` |
| Animation Feel | Precise snaps, small arcs | Wide swings, momentum overshoot |
| Walk Speed | 200 px/s | 220 px/s |
| Idle Pose | Guard stance, hands near chin | Wide stance, low CoG |
| Expression | Calm, focused | Angry, fierce |

### Who Uses This Document

| Agent | Uses This For |
|---|---|
| **Nien** | Sprite creation — silhouettes, proportions, palette colors, pose list |
| **Leia** | Stage art — color tables, escalation rules, ember behavior |
| **Bossk** | VFX — character palettes, particle parameters, timing |
| **Chewie** | Animation playback — frame counts, timing sync, state names |
| **Mace** | Quality gate — compliance checks, naming convention enforcement |
| **Jango** | PR review — visual consistency verification |

---

*This document is LOCKED as of Sprint 1 M0. Any proposed changes must be submitted as a PR with Art Director (Boba) approval.*
