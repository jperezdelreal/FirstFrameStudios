# Jango — M1+M2 Retrospective Action Items

**Author:** Jango (Lead)  
**Date:** 2026-03-08  
**Status:** Proposed  
**Scope:** Ashfall — Pre-M3 mandatory actions

Full retrospective at `games/ashfall/docs/RETRO-M1-M2.md`.

## Top 3 Action Items

### 1. 🔴 Cherry-pick AI Controller to Main (P0)
**Owner:** Jango or Tarkin  
**Why:** `ai_controller.gd` (298 LOC) was merged to `squad/1-godot-scaffold` after scaffold was already on main. The game has no single-player opponent. Issue #7 was closed but the code never landed.  
**Action:** Cherry-pick commits `70bccc8` and `d4d396a` from `remotes/origin/squad/7-ai-opponent` onto main, or recreate the PR from a main-based branch.

### 2. 🔴 Full Integration Pass in Godot (P0)
**Owner:** Ackbar (QA) + Jango  
**Why:** All 8 systems were built in parallel isolation. No one verified the project opens in Godot, autoloads initialize, scenes load, or game flow works end-to-end. Scene references, signal connections, and autoload order are unvalidated.  
**Action:** Open project in Godot 4.6. Walk through Main Menu → Character Select → Fight → KO → Victory → Rematch. File bugs for anything broken.

### 3. 🟡 Add Medium Buttons to Input Map (P1)
**Owner:** Jango + Lando  
**Why:** GDD specifies 6-button layout (LP/MP/HP/LK/MK/HK) but project.godot only maps 4 buttons per player (no medium punch/kick). Movesets also only define 4 normals per character. Silent spec deviation.  
**Action:** Add `p1_medium_punch`, `p1_medium_kick`, `p2_medium_punch`, `p2_medium_kick` to project.godot. Create medium attack MoveData for both Kael and Rhena.

## Process Change: Pre-M3 Gate
No M3 feature work begins until items 1 and 2 are complete. Characters sprites on broken infrastructure helps nobody.
