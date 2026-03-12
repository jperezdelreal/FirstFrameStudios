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
- **Status:** TODO_ID=f75ad846, IN_PROGRESS_ID=47fc9ee4, DONE_ID=98236657
- **Priority:** P0_CRITICAL=38fd4273, P1_HIGH=20e2e5b2, P2_MEDIUM=8c7ac9b8, P3_LOW=3bb7974e
- **Game:** FFS_HUB=a24517eb, COMEROSQUILLAS=8d8c8880, FLORA=b5296bb8, SQUAD_MONITOR=f56d595a
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
