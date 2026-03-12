# SKILL: Game UI/UX Design Patterns

Game UI/UX design patterns applicable to any genre, engine, platform. Covers HUD design, menu systems, information hierarchy, responsive scaling, animations, and accessibility.

---

name: "ui-ux-patterns"
description: "Game UI/UX design patterns — HUD systems, menu flow, information hierarchy, responsive layouts, animations, accessibility"
domain: "user-experience"
confidence: "medium"
source: "firstPunch arcade HUD, menus, feedback UI"
has_reference: true

---

## Context

Use when designing/implementing UI, laying out HUD elements, building menus, implementing responsive scaling, creating feedback UI (damage numbers, combos), designing for accessibility, or animating UI. Not for web app UI, 3D overlays, or narrative/dialog systems.

## Core Patterns

### Information Hierarchy (Glance Test < 0.5s)
**Tier 1:** Player health, immediate threat. 20-30% screen, brightest, always visible.
**Tier 2:** Resources, abilities, objective. 10-15% screen.
**Tier 3:** Score, combo, progress. 5-10% screen, muted.
**Tier 4:** Mini-map, inventory. 0% (hidden until needed).

Size scales with importance. Tier 1 brightest, Tier 4 hidden/corners.

### HUD Design
**Safe zones:** 40px margin all sides. Test on 4:3, 16:9, 21:9.
**Visibility:** Gameplay (full HUD), cutscene (hide, fade 0.5s), dialog (Tier 1 only), pause (hide), game over (final state).

### Menu Design
**Title Screen:** Title (large), options (Start/Options/Quit), controls hint, credits.
**Navigation:** UP/DOWN, ENTER select, ESC back. Selection indicator + audio feedback.

**Pause Menu:** "PAUSED", Resume, Options, Quit. ESC toggles. Dark overlay (0.5-0.7 alpha).

**Options:** Audio (Master/SFX/Music sliders), Difficulty, Controls, Display, Accessibility. LEFT/RIGHT adjust, ESC closes.

**Game Over:** "GAME OVER", final score, high score, stats, "Press ENTER to Retry", 0.5s input delay.

## Key Examples

### Feedback UI
**Damage Numbers:** Float at hit location, fade up. Light: yellow. Medium: orange. Heavy: red. Crit: gold + glow. Base 24px + 1px per 10 damage. Rise 60px/s, fade 0.3s.

**Combo Counter:** Center/right. "COMBO x15" + multiplier. Color by count (grey → yellow → orange → red + pulse). Base 36px + 2px per hit. Pop 1.5× → 1.0× (0.1s). Reset on damage/2s timeout.

**Health Bars (Player):** Top-left, 150-200px × 20-30px. Dark bg + green fill. Lerp 0.2s on damage. Flash white 1f on hit.

**Enemy Health:** Above head, 30-50px × 4-6px. Visible when damaged. Red bg + green fill. Fade 3-5s. Boss: permanent, 150px, top-center.

### Responsive Scaling
**Reference:** 1280×720 (16:9).
**DPR scaling:** `ctx.scale(devicePixelRatio, devicePixelRatio)`.
**Aspect:** Letterbox/pillarbox to maintain ratio. Never distort.
**Text:** Min 10px logical (12px main UI). Scale: `(screenHeight / 720) * baseSize`.

## Anti-Patterns

- **UI Overload:** Show all info. Fix: Apply hierarchy (Tier 1 + 2 only).
- **Invisible State:** No feedback. Fix: Visual + audio on every state change.
- **Modal Trap:** Can't exit. Fix: ESC always closes/returns.
- **Mouse-First Action:** Requires mouse. Fix: Keyboard/gamepad primary.
- **Unscaled HUD:** Hardcoded positions. Fix: Relative to viewport (%, not px).
- **No Input Feedback:** Silent navigation. Fix: SFX on navigate + confirm.
- **Instant Changes:** No animation. Fix: Fade/slide 0.2-0.3s.

**Full details:** See REFERENCE.md for complete hierarchy rules, menu patterns (title, pause, options, game over), feedback UI (damage, combo, score, health, progress), responsive design (canvas scaling, letterboxing, text sizing), animation patterns, accessibility (colorblind, contrast, prompts, subtitles), firstPunch learnings, and shipping checklist.