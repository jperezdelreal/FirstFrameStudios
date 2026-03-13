# DPS Balance Analysis & Playtest Protocol — firstPunch

> Compressed from 21KB. Full: balance-analysis-archive.md

**Analyzed by:** Ackbar (QA/Playtester)  
**Date:** 2026-06-04  
---

## PART 1: DPS CALCULATIONS
### 1.1 Player DPS by Attack Type
#### Punch Spam (Cooldown-Limited)
| Attack | DPS | Knockback | Active Time | Use Case |
| Punch Spam | 33.3 | 150 | 0.30s | Steady damage, safest |
| Kick Spam | 30 | 250 | 0.50s | Spacing/zone control |
| PPK Combo | 39.1 | 375 (finisher) | 1.10s | Optimal damage (if enemies don't knockback away) |
| Jump Punch | 50 | 150 | 0.20s | Gap closing, burst |
| Jump Kick | 50 | 300 | 0.40s | Gap closing + knockback control |
---
---
---
---
---

## PART 2: BALANCE FLAGS
### ⚠️ CRITICAL ISSUES
#### 1. **Jump Attacks Are Overpowered**
---
### 🟡 MEDIUM ISSUES
---
### 🟢 MINOR ISSUES
---

## PART 3: PLAYTEST PROTOCOL
### Phase 1: Mental Playthrough Framework
Each playthrough follows a structured script:
---
### Playthrough 1: "Aggressive Punch Spam" (Baseline)
---
### Playthrough 2: "Optimal PPK Combos" (Skill-Based)
---
### Playthrough 3: "Jump Attack Spam" (Overpowered)
---
---
---
---
| Strategy | Time | Health | Clear? | Notes |
| Punch Spam | 7.3s | 85 HP | ✓ | Trivial, safe, slow |
| PPK Combo | 5.3s | 95 HP | ✓ | Skill-based, spacing-dependent |
---

## PART 4: DIFFICULTY ASSESSMENT
### Current State: 3/10 (Too Easy)
**Evidence:**
### Desired State: 5-6/10 (Medium Difficulty)
### Required Changes (Priority Order)
---

## PART 5: REGRESSION CHECKLIST
Before deploying balance changes, verify these 5 tests:
### Test 1: Enemy Attack Lands
### Test 2: Dual Aggression Throttling
### Test 3: PPK Combo Damage Scaling
### Test 4: Jump Attack Landing Lag (If Added)
---

## CONCLUSION
**Current Balance State:** Too easy, jump attacks dominant, enemy threat minimal.
**Key Findings:**
---