---
name: integration-discipline
description: "Integration verification discipline for multi-agent parallel development"
domain: "process"
confidence: "medium"
source: "Ashfall M1+M2 root cause — 5 blockers, systems couldn't run"
has_reference: true
---

## Context
Multi-agent development creates invisible integration gaps. During Ashfall M1+M2, 2,711 LOC across 31 files couldn't run: RoundManager not instantiated, signals not wired, AI on dead branch, state machines won't start, GDD spec drift.

## Core Patterns

- **Integration gate after every parallel wave** — Hard gate, not suggestion. Owner: Solo (Architect)
- **Checklist:** Pull main, open Godot (no errors), verify autoload order, verify signals CONNECTED (not just defined), check cross-system wiring, run game flow end-to-end, document failures as blockers
- **Somebody must open and verify** — Explicit assigned task: open project, press play, navigate full flow (menu → fight → KO → victory)
- **Signals defined ≠ connected** — Grep for `.connect()` calls. Every signal needs ≥1 emitter AND ≥1 consumer
- **Spec validation before PR** — Compare implementation against GDD. Count items (buttons, features), flag deviations
- **Branch validation** — Feature from latest main, PR targets main, don't branch from unmerged dependencies

## Key Examples

**Integration checklist:**
```
□ Project loads in engine without errors
□ All autoloads initialize in dependency order
□ EventBus signals are connected, not just defined
□ Cross-system wiring works (VFX on hit, audio on events)
□ Primary game flow completes end-to-end
□ Document any failures as blocking issues
```

**M1+M2 lesson:** 298 LOC AI code merged to dead branch. 30-second branch check would have prevented.

## Anti-Patterns

- **Integration-last** — Integrate after EVERY wave, not after 5
- **"Someone else will wire it"** — Assign integration explicitly
- **No smoke test** — Always run the game after integration
- **Branching from unmerged dependencies** — Wait or branch from main
