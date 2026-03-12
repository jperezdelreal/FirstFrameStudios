# Flora PR #20 Review — Build Failure + Integration Gaps

**Date:** 2026-03-11  
**Reviewer:** Ackbar (QA/Playtester)  
**PR:** jperezdelreal/flora#20 — "feat: hazard system with pests and weather events"  
**Issue:** #7 (Priority P0)  
**Review Link:** https://github.com/jperezdelreal/flora/pull/20#issuecomment-4041007260

---

## Summary

The hazard system **core logic is architecturally sound and well-balanced**, but the PR is **not shippable** due to:
1. TypeScript compilation errors (blocker)
2. Missing UI/input integration (can't be playtested)
3. Incomplete acceptance criteria from issue #7

**Verdict:** ⛔ **Changes Requested**

---

## Critical Issues

### 1. TypeScript Build Failure (BLOCKER)

**Severity:** 🛑 Critical  
**Impact:** PR cannot be merged — CI build fails

**Error:**
```
src/main.ts(22,42): error TS2345: Argument of type 'GardenScene' is not assignable to parameter of type 'Scene'.
  Types of property 'init' are incompatible.
    Type '(app: Application<Renderer>) => Promise<void>' is not assignable to type '(ctx: SceneContext) => Promise<void>'.
```

**Root cause:** Scene interface expects `SceneContext` parameter, but GardenScene provides `Application<Renderer>`. This is **NOT** in the hazard system code — appears to be a bad merge or pre-existing issue on the branch.

**Required fix:** Resolve Scene/GardenScene type mismatch before re-review.

---

### 2. Missing Acceptance Criteria

From issue #7, these are **not implemented**:

#### ❌ Pest UI marker on affected plant tile
- **Expected:** Visual indicator (sprite, icon, debug circle) appears on infested plant
- **Actual:** No rendering code in PR
- **Impact:** Can't playtest pest spawning or removal

#### ❌ Player click-to-remove pest action
- **Expected:** InputManager integration to detect click on pest tile → call `HazardSystem.removePest(pestId)`
- **Actual:** No input wiring in PR
- **Impact:** Core interaction mechanic is unimplemented

#### ❌ Drought visual warning (sky color shift, UI alert)
- **Expected:** Visual feedback when drought is active (sky tint, weather icon, notification)
- **Actual:** No rendering code in PR
- **Impact:** Player can't see drought state during gameplay

**Note:** The **system logic exists** (drought multiplier, day tracking, state management), but without UI/input, this is backend-only code.

---

### 3. Pest Spawning Flow Unclear

**Code:**
```typescript
private spawnPests(): void {
  // No implementation needed here - spawning happens externally
  // This is a hook for future plant-targeting logic
}
```

**Issues:**
- `spawnPests()` is called during day advancement but does nothing
- `trySpawnPestOnPlant(plant)` exists but has no external caller
- What happens if there are 0 plants in the garden on day 6-8?

**Required fix:** Either:
1. Implement `spawnPests()` to iterate over plants and call `trySpawnPestOnPlant()`
2. Document the expected external integration point (e.g., "PlantSystem must call `trySpawnPestOnPlant` for each eligible plant")

---

## What Works Well

### ✅ Type Safety
- Strong TypeScript types throughout (`PestConfig`, `DroughtConfig`, `HazardData`)
- Proper type guards: `isPest()`, `isDrought()`, `getPestData()`, `getDroughtData()`
- No `any` casts found

### ✅ Architecture
- Clean System/Entity pattern following existing conventions
- Proper state management with `PestState` enum
- Config-driven design with tunable parameters
- Hazards stored in Map (efficient lookup by ID)

### ✅ Game Balance
All numbers feel fair for an MVP:
- **Pest damage:** 12/day (tunable via config)
- **Resistance:** 30% chance at >70% health (prevents determinism, feels fair)
- **Drought multiplier:** 1.5× water needs (punishing but not brutal)
- **Drought duration:** 2-3 days (short enough to recover)
- **Spawn window:** Day 6-8 (gives player time to learn systems)

### ✅ Difficulty Scaling
Elegant 0→1 ramp across seasons:
- Pest spawn chance: 0.5× → 1.2× (easy to hard)
- Drought intensity: 1.0× → 1.3× (water needs)
- Max hazards: 1 → 3 (early to late game)

### ✅ "Never Instant-Fail" Design
- Pests deal damage over time (not instant death)
- Drought increases needs (not instant withering)
- Resistance mechanic gives healthy plants a chance
- Players always have counterplay options

---

## Required Fixes (Before Approval)

1. **Fix TypeScript Scene/GardenScene errors** (blocker)
2. **Add pest visual indicators** (sprites, markers, or debug circles)
3. **Wire InputManager for click-to-remove pests** (interaction mechanic)
4. **Add drought visual warning** (sky tint, weather icon, UI notification)
5. **Clarify/implement pest spawning flow** (link to PlantSystem or document external hook)

---

## Decision Points for Team

### Should hazard rendering live in HazardSystem or a separate Renderer?

**Current state:** HazardSystem has no rendering logic  
**Options:**
1. Add `render(app)` method to HazardSystem (like PlantSystem pattern)
2. Create separate HazardRenderer component
3. Let GardenScene handle hazard rendering directly

**Recommendation:** Follow existing PlantSystem pattern — add rendering to HazardSystem for consistency.

---

### Should pest spawning be automatic or manual?

**Current state:** `spawnPests()` is empty, `trySpawnPestOnPlant()` requires external caller  
**Options:**
1. **Automatic:** HazardSystem fetches plants from PlantSystem and spawns pests autonomously
2. **Manual:** Caller (GardenScene or PlantSystem) must invoke `trySpawnPestOnPlant()` for each plant

**Recommendation:** Automatic spawning keeps HazardSystem self-contained. Pass PlantSystem reference during init or `onDayAdvance()`.

---

## QA Learnings

### Key Pattern Identified
**"Architecturally sound ≠ shippable"**

A system can have:
- ✅ Clean architecture
- ✅ Strong types
- ✅ Good balance
- ✅ Solid logic

...but still be **un-shippable** if it can't be playtested. "Does it compile?" and "Can I interact with it in-game?" are equally critical gates.

### Acceptance Criteria Completeness
Issue #7 explicitly listed:
- Pest UI marker ❌
- Click-to-remove action ❌
- Drought visual warning ❌

These should've been implemented alongside the system logic, not deferred. A hazard system without visuals is like a car engine without a dashboard — technically functional but practically unusable.

---

## Re-Review Criteria

I'll approve once:
1. ✅ Build passes (TypeScript errors resolved)
2. ✅ Pests have visual indicators in-game
3. ✅ Player can click to remove pests
4. ✅ Drought shows visual warning
5. ✅ Pest spawning flow is clear/implemented

The **core hazard logic is excellent** — it just needs to be wired into the game. Once integrated, I expect this to be a strong foundation for future hazard types (heat waves, frost, locusts, etc.).

---

**Next Steps:**
- Assignee (Tarkin?) should address the 5 required fixes
- Re-request review from Ackbar when ready
- Consider splitting into two PRs if rendering/input work is substantial (backend logic + frontend integration)
