# Erika — Systems Dev History

## Learnings

### 2024-12-03: Garden UI/HUD Implementation (Issue #9)

**Architecture Decisions:**
- Created comprehensive UI system with 5 new components: HUD, SeedInventory, PlantInfoPanel, DaySummary, and PauseMenu
- Integrated all components into GardenScene with proper lifecycle management (init, update, destroy)
- Used session tracking (Map for harvested seeds, Set for new discoveries) to enable end-of-season summary
- Implemented keyboard shortcuts (Escape for pause, I for inventory) with event listeners in setupKeyboardShortcuts()

**Key Patterns:**
- All UI components follow consistent pattern: Container wrapper, position() method, getContainer(), destroy()
- Semi-transparent panels (alpha 0.85-0.95) with rounded corners for cozy aesthetic
- Color-blind friendly design: combine colors with patterns/icons (rarity patterns: ●, ●●, ●●●, ★)
- Progress bars with color-coded states (red<33%, yellow 33-66%, green>66%)
- Tooltip positioning with edge detection to keep panels on screen

**File Structure:**
- `/src/ui/` — all UI components (HUD, SeedInventory, PlantInfoPanel, DaySummary, PauseMenu, ToolBar, Encyclopedia, etc.)
- `/src/ui/index.ts` — barrel exports for clean imports
- `/src/scenes/GardenScene.ts` — main scene orchestrating all systems and UI
- `/src/config/plants.ts` — plant configs with ALL_PLANTS array and PLANT_BY_ID lookup

**PixiJS v8 Patterns:**
- `new Text({ text, style })` object syntax (not positional args)
- Graphics method chaining: `rect()`, `fill()`, `stroke()`, `roundRect()`
- `eventMode = 'static'` for interactive elements
- `container.visible` for show/hide, `container.alpha` for fade effects

**Plant System API:**
- `PlantState` properties: `daysGrown`, `health`, `waterState` (enum: WET/DRY), `growthStage`, `config`
- `plantSystem.getPlantAt(x, y)` — get plant at grid coords
- `plantSystem.harvestPlant(x, y)` — returns `{ success, seeds, plantId, isNewDiscovery }`
- `plant.getState()` — returns readonly PlantState snapshot
- `plant.getConfig()` — returns PlantConfig

**Grid System:**
- `grid.getTilePosition(row, col)` — converts grid to local container coords
- `gridSystem.getContainer().position` — get grid container world position
- Combine both for screen-space tooltip positioning

**Player System:**
- `player.getCurrentDay()` — current in-game day (1-12)
- `player.getActionsRemaining()` / `player.getState().maxActions` — action tracking
- `player.getSelectedTool()` — current tool selection

**User Preferences:**
- Cozy, minimal aesthetic — avoid screen clutter
- Readable text (14px+ font size, high contrast)
- Color-blind friendly (icons + patterns, not color alone)
- Semi-transparent UI panels for visibility over gameplay

**Technical Notes:**
- Frame counter tracking: `frameCounter % (GAME.TARGET_FPS * 30)` for day progress (30 sec/day)
- Season end detection: `day >= 12 && !daySummary.isVisible()` triggers summary
- Pause state: `isPaused` flag blocks update() logic but not rendering
- Encyclopedia integration: `encyclopediaSystem.onDiscovery()` callback for tracking new finds

**PR:** #25 — Closed issue #9 with full acceptance criteria met
