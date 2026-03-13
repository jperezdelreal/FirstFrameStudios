---
name: github-project-board
description: 'Manage First Frame Studios GitHub Project Board V2'
domain: "github"
confidence: "high"
has_reference: true
---

## Context
Central mission control for all FFS work across repos. Project #5 for jperezdelreal. Tracks Todo/In Progress/Done with custom fields: Priority, Game, Size, Sprint, Agent.

## Core Patterns

- **Project IDs:** `OWNER=jperezdelreal`, `PROJECT_NUMBER=5`, `PROJECT_ID=PVT_kwHODRyXic4BRbrR`
- **Status field:** `PVTSSF_lAHODRyXic4BRbrRzg_Qx64` — TODO=f75ad846, IN_PROGRESS=47fc9ee4, DONE=98236657
- **Priority field:** `PVTSSF_lAHODRyXic4BRbrRzg_Q5Dc` — P0_CRITICAL=38fd4273, P1_HIGH=20e2e5b2, P2_MEDIUM=8c7ac9b8, P3_LOW=3bb7974e
- **Game field:** `PVTSSF_lAHODRyXic4BRbrRzg_Q5GY` — FFS_HUB=a24517eb, COMEROSQUILLAS=8d8c8880, FLORA=b5296bb8, SQUAD_MONITOR=f56d595a
- **Size field:** `PVTSSF_lAHODRyXic4BRbrRzg_Q5DQ` — XS=205fdffe, S=0b8e3239, M=deea056b, L=b5b89803, XL=6c75640c
- **Workflow:** Check if on board → Add if needed → Set Game/Priority/Size/Agent/Sprint → Move to In Progress → Work → Move to Done

## Key Examples

**Add item:**
```bash
gh project item-add 5 --owner jperezdelreal --url <ISSUE_URL>
```

**Move to In Progress:**
```bash
gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTSSF_lAHODRyXic4BRbrRzg_Qx64 \
  --single-select-option-id 47fc9ee4
```

**Duplicate prevention (CRITICAL):**
```bash
gh search issues --owner jperezdelreal --state open "search terms"
gh project item-list 5 --owner jperezdelreal --format json | jq '...'
```

## Anti-Patterns

- **Creating issue without duplicate check** — Always search first
- **Not setting Game field** — Required for "By Game" board view
- **Forgetting to move status** — Keep board in sync with work state
