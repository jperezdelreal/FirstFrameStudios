# Decision: SceneContext Pattern Enforcement in Flora

**Date:** 2025-01-XX  
**Author:** Solo (Lead Architect)  
**Context:** flora repository (jperezdelreal/flora) Issue #23  
**Status:** Implemented  

## Decision

Enforced the SceneContext architectural pattern across all Scene implementations in the Flora project. All Scene.init() and Scene.update() methods must accept SceneContext instead of direct Application references.

## Rationale

**Problem:**  
GardenScene was implementing Scene interface incorrectly by accepting `Application` directly in init() instead of the SceneContext wrapper. This caused TypeScript build failures and deploy workflow blockage.

**Solution:**  
Updated GardenScene to conform to the SceneContext pattern:
- `init(app: Application)` → `init(ctx: SceneContext)`
- `update(delta: number)` → `update(delta: number, ctx: SceneContext)`
- All Application references changed to `ctx.app`
- Scene stage access changed to `ctx.sceneManager.stage`

## Benefits

1. **Consistent Architecture:** All scenes access shared resources through SceneContext
2. **Better Testability:** SceneContext can be mocked more easily than Application
3. **Dependency Injection:** Scenes receive input, assets, and sceneManager without tight coupling
4. **Type Safety:** TypeScript enforces the pattern at compile time

## Implementation Details

**Files Modified:**
- `src/scenes/GardenScene.ts`

**Changes:**
- Import SceneContext type
- Updated init() signature to accept SceneContext
- Updated update() signature to accept SceneContext
- Changed all `app.*` references to `ctx.app.*`
- Changed scene stage access to use `ctx.sceneManager.stage`

## Verification

- ✅ TypeScript compilation passes (`npx tsc --noEmit`)
- ✅ Production build succeeds (`npm run build`)
- ✅ Deploy workflow unblocked

## Future Considerations

When implementing new Scenes in Flora:
1. Always implement Scene interface with correct signatures
2. Use SceneContext for all shared resource access
3. Run TypeScript type check early in development to catch signature mismatches
4. Reference BootScene.ts or GardenScene.ts as pattern examples

## Related

- Issue: jperezdelreal/flora#23
- PR: jperezdelreal/flora#24
- Pattern defined in: src/core/SceneManager.ts
