# Decision: Flora PR Reviews Round 2

**Author:** Solo (Lead Architect)
**Date:** 2026-03-12
**Scope:** Flora project — Sprint 0

## Context

Reviewed Flora PRs #18 (Garden UI/HUD) and #19 (Audio Foundation) as architecture gate reviews.

## Decisions

### 1. UI Component Pattern — Approved
Flora UI components extend PixiJS Container with show/hide/destroy lifecycle. Callback-based parent-child communication is acceptable for now; EventBus integration deferred to when cross-module communication is needed.

### 2. Singleton AudioManager — Approved with Advisory
The `audioManager` singleton export is approved for Sprint 0. Audio is inherently global (one AudioContext per page). However, when gameplay systems integrate audio (e.g., garden events triggering SFX), the AudioManager should be instantiated in bootstrap and injected via SceneContext to maintain testability and consistency with Flora's DI pattern.

### 3. Procedural SFX over Asset Files — Endorsed
Greedo's approach of synthesizing all SFX procedurally via Web Audio API (no .mp3/.wav files) is the right call for Sprint 0. Zero asset pipeline, full configurability, and good enough for prototype validation. Asset-based audio can be explored post-Sprint 0 if the sound design needs more richness.

## Impact
- Wedge and Greedo can merge their PRs
- Future audio integration should use DI over singleton import
- UI components should migrate to EventBus when gameplay wiring begins
