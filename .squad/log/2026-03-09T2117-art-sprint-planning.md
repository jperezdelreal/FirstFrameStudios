# Session Log: Art Sprint Planning — FLUX Pipeline Validated & Sprite Brief v3 Delivered

**Timestamp:** 2026-03-09T2117Z  
**Phase:** Art Sprint Planning & Infrastructure Validation Complete  
**Coordinator:** joperezd (via Copilot)  
**Status:** ✅ COMPLETED  

## Session Objectives

1. ✅ Validate three FLUX models live on Azure AI Foundry
2. ✅ Resolve Entra ID authentication (replace API key auth disabled by org policy)
3. ✅ Confirm sprite dimensions safe for 1080p game resolution
4. ✅ Consolidate all user directives into Sprite Art Brief v3
5. ✅ Lock production estimates and scope
6. ✅ Establish single source of truth for art asset generation

## Art Sprint Readiness Assessment

### Infrastructure Status: ✅ READY

**Three-Model FLUX Pipeline Validated:**

| Model | Capability | Rate Limit | Deployment | Status |
|-------|------------|------------|------------|--------|
| **FLUX 2 Pro** | Hero frames (1024×1024) | 4 req/min | ✅ Deployed | **VALIDATED** |
| **FLUX 1 Kontext Pro** | Production sprites + consistency (512×512) | 30 req/min | ✅ Deployed | **VALIDATED** |
| **FLUX 1.1 Pro** | Non-character assets (backgrounds, VFX) | 30 req/min | ✅ Deployed | **VALIDATED** |

**Authentication:** Entra ID Bearer token via Azure CLI (org policy disables API key auth).  
**Token Management:** ~1 hour expiry; auto-refresh implemented for batch sessions.

### Resolution & Oversampling: ✅ CONFIRMED

**Game Resolution:** 1920×1080 (1080p)  
**Sprite Dimension:** 512×512  
**Oversampling Factor:** 3.3× (safe against aliasing)  
**Risk Assessment:** LOW — sprites render well-proportioned at typical viewport distance.

### FLUX Capabilities Validated

1. **Text-to-image:** All models confirmed
2. **Image-to-image reference:** Kontext Pro + FLUX 2 Pro tested with hero frame input
3. **Rate limits:** Documented and production-scheduled
4. **Output formats:** PNG with transparency confirmed
5. **Max resolution:** 4.0 MP (FLUX 2 Pro), 1.0 MP (Kontext Pro), 1.6 MP (FLUX 1.1 Pro)

### Entra ID Auth Resolution: ✅ COMPLETED

**Problem:** Initial assumption was API key authentication.  
**Discovery:** Azure Policy disables API key auth organization-wide.  
**Solution:** Installed Azure CLI. Pipeline now uses:
```bash
az account get-access-token --resource https://cognitiveservices.azure.com
```
**Impact:** Zero delays; all team members use same Entra ID credentials.

## Key Directives Captured & Consolidated

All user input from this session merged into SPRITE-ART-BRIEF.md v3:

### 1. Resolution Directive (1080p)
- Game resolution is 1920×1080, NOT 720p
- 512×512 sprites confirmed appropriate
- 3.3× oversampling validates pixel fidelity

### 2. FLUX for Stages (Backgrounds)
- FLUX pipeline extends to environment art, not just character sprites
- ~10-15 images per stage (backgrounds, parallax layers)
- Much simpler than character generation: no frame-to-frame consistency needed, only style coherence
- Generated via FLUX 1.1 Pro with environment prompts

### 3. FLUX for HUD Art
- Life bars, character portraits, ember meter decorations: all FLUX-generated
- Text + dynamic data rendered in-engine
- Inspiration screenshots provided (Tekken, Street Fighter 6, etc.) — to be used as style reference in prompts
- Single model (FLUX 1.1 Pro) sufficient for UI asset generation

### 4. Multi-Asset Scope Confirmed
- **Character Sprites:** ~1,020 frames (Kontext Pro with hero frame reference)
- **Stage Art:** ~10-15 per stage × 5 stages = ~75 images (FLUX 1.1 Pro)
- **HUD Assets:** ~30-50 UI elements (FLUX 1.1 Pro)
- **Title Screen:** 1-2 cinematic frames (FLUX 2 Pro for quality)

## Sprite Production Pipeline Locked

### Phase 1: Hero Frame Approval
1. Generate hero frame per character (FLUX 2 Pro, 1024×1024)
2. Boba (Art Director) reviews and approves
3. Downscale to 512×512 for reference image input

### Phase 2: Pose Production
1. For each of 51 animation poses:
   - Generate 8-10 frames using Kontext Pro with approved hero frame as reference
   - Batch at 30 req/min (sustainable rate)
2. Raw generation time: ~34 minutes
3. QA review + iteration: ~90 minutes

### Phase 3: Asset Generation
1. Stage backgrounds (FLUX 1.1 Pro)
2. HUD elements with style reference (FLUX 1.1 Pro)
3. Title screen cinematic (FLUX 2 Pro)

**Total Estimated Timeline:** ~2 hours for P0 character sprites + assets = 510 frames/character (Modern Indie Fighter tier).

## Decisions Consolidated & Locked

1. **SPRITE-ART-BRIEF.md v3 is definitive** — No further revisions for P0/P1. All agents reference this document.

2. **Hero Frame Gate Active** — Production cannot begin without Boba approval of character identity.

3. **512×512 is standard** — All sprite generation targets this resolution. Confirmed safe for 1080p.

4. **Multi-model workflow deployed** — Each model assigned optimal role based on capability + rate limit.

5. **Entra ID auth standard** — All team members authenticate via Azure CLI. API key auth unsupported.

6. **Production scope includes HUD + stages** — Art sprint delivers complete visual system, not just character sprites.

7. **Inspiration screenshots integrated** — Tekken/SF6 references in docs/screenshots/Inspiration → inform FLUX prompts for style consistency.

## Risk Mitigation

- **Character Consistency:** Kontext Pro's reference image propagation (proven technique, better than v2's prompt-only approach)
- **Consistency Gate:** If >30% of frames require regeneration, decision to evaluate local SD + ComfyUI triggered
- **Rate Limits:** 30 req/min enforces disciplined scheduling, prevents API spam
- **Quality Bottleneck:** Boba approval gate ensures no production begins without validated hero frame
- **Auth Hardening:** Entra ID prevents credential leakage; no API keys in environment

## Team Readiness

✅ **Boba (Art Director):** Has SPRITE-ART-BRIEF.md v3 + knows approval requirements  
✅ **Coordinator:** Infrastructure validated, auth resolved, 3 models tested  
✅ **Chewie/Bossk (Gameplay):** Can integrate sprites in parallel once file naming locked  
✅ **Mace (Producer):** Production timeline confirmed realistic — 2 hours for full sprite set  
✅ **All Agents:** Single source of truth established (SPRITE-ART-BRIEF.md v3)

## PoC Scope Confirmed (P0)

| Asset | Frames | Model | Status |
|-------|--------|-------|--------|
| Hero Frames (2 chars) | 2 | FLUX 2 Pro | Ready |
| Animation Loops (51 poses × 2 chars) | ~1,020 | Kontext Pro | Ready |
| Stage Backgrounds (sample) | 10 | FLUX 1.1 Pro | Ready |
| HUD Assets (sample) | 15 | FLUX 1.1 Pro | Ready |
| Title Screen | 1-2 | FLUX 2 Pro | Ready |
| **Total P0** | **~1,050** | **3 Models** | **✅ GO** |

---

**Status:** Art sprint planning complete. FLUX pipeline validated. Sprite brief finalized. All directives consolidated. Production ready to begin post-Boba hero frame approval.

**Next Phase:** Character hero frame generation → Boba approval → Batch pose production (Kontext Pro) → Parallel asset generation (FLUX 1.1 Pro) → QA + delivery.
