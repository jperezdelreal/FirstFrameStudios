---
name: github-project-board
description: 'Manage the First Frame Studios GitHub Project Board V2. Use this skill to move issues between statuses (Todo, In Progress, Done), set Priority/Game/Size/Sprint/Agent fields, add items to the board, check item status, archive completed work, and prevent duplicate issues. Triggers on requests like "update board", "move issue to In Progress", "check project status", "archive done items", "add to board", "set priority", or any project board management task.'
confidence: high
---

# GitHub Project Board — First Frame Studios

Central "mission control" board for all FFS work across repositories.

## Project IDs

```
OWNER:           jperezdelreal
PROJECT_NUMBER:  5
PROJECT_ID:      PVT_kwHODRyXic4BRbrR
```

## Built-in Fields

### Status (Single Select)
```
FIELD_ID:         PVTSSF_lAHODRyXic4BRbrRzg_Qx64
TODO_ID:          f75ad846
IN_PROGRESS_ID:   47fc9ee4
DONE_ID:          98236657
```

## Custom Fields

### Priority (Single Select)
```
FIELD_ID:         PVTSSF_lAHODRyXic4BRbrRzg_Q5Dc
P0_CRITICAL:      38fd4273    # Blocks everything
P1_HIGH:          20e2e5b2    # Must do this sprint
P2_MEDIUM:        8c7ac9b8    # Should do soon
P3_LOW:           3bb7974e    # Nice to have
```

### Game (Single Select) — groups issues by repo/project
```
FIELD_ID:         PVTSSF_lAHODRyXic4BRbrRzg_Q5GY
FFS_HUB:          a24517eb    # Studio infrastructure
COMEROSQUILLAS:   8d8c8880    # Arcade game
FLORA:            b5296bb8    # Cozy roguelite
SQUAD_MONITOR:    f56d595a    # Dashboard tool
```

### Size (Single Select) — effort estimate
```
FIELD_ID:         PVTSSF_lAHODRyXic4BRbrRzg_Q5DQ
XS:               205fdffe    # < 1 hour
S:                0b8e3239    # 1-3 hours
M:                deea056b    # 3-8 hours
L:                b5b89803    # 1-2 days
XL:               6c75640c    # 3+ days
```

### Sprint (Text)
```
FIELD_ID:         PVTF_lAHODRyXic4BRbrRzg_Q5DY
```
Use format: `S1`, `S2`, etc. Free text — set manually.

### Agent (Text)
```
FIELD_ID:         PVTF_lAHODRyXic4BRbrRzg_Q5GU
```
Name of the squad agent working the item (e.g., `Ralph`, `Jango`).

## Views

| View | Layout | Purpose |
|------|--------|---------|
| **Sprint Board** | Board | Default Kanban — current sprint status |
| **By Game** | Board | Issues grouped by Game field (create manually in UI) |
| **Priority** | Table | All items sorted by priority (create manually in UI) |
| **Roadmap** | Table | Timeline view (create manually in UI) |

> **Note:** Views cannot be created via the GitHub API. Create "By Game", "Priority", and "Roadmap" views manually in the GitHub Projects UI.

## Repositories Tracked

| Repo | Purpose |
|------|---------|
| `jperezdelreal/FirstFrameStudios` | Studio Hub — infra, skills, tooling |
| `jperezdelreal/ComeRosquillas` | Game — Pac-Man arcade clone |
| `jperezdelreal/flora` | Game — roguelite |
| `jperezdelreal/ffs-squad-monitor` | Tool — squad monitor dashboard |

## Status Columns

| Status | When to use |
|--------|-------------|
| **Todo** | Issue exists, not yet started |
| **In Progress** | Agent or human is actively working on it |
| **Done** | Work complete, PR merged or issue closed |

## Core Commands

### Get item ID for an issue on the board

```bash
gh project item-list 5 --owner jperezdelreal --format json \
  --jq '.items[] | select(.content.url == "ISSUE_URL") | .id'
```

### Add an issue to the board

```bash
gh project item-add 5 --owner jperezdelreal --url <ISSUE_URL>
```

### Move an item to a status

```bash
gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTSSF_lAHODRyXic4BRbrRzg_Qx64 \
  --single-select-option-id <STATUS_OPTION_ID>
```

### Set Priority on an item

```bash
gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTSSF_lAHODRyXic4BRbrRzg_Q5Dc \
  --single-select-option-id <PRIORITY_OPTION_ID>
```

### Set Game (repo) on an item

```bash
gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTSSF_lAHODRyXic4BRbrRzg_Q5GY \
  --single-select-option-id <GAME_OPTION_ID>
```

### Set Size on an item

```bash
gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTSSF_lAHODRyXic4BRbrRzg_Q5DQ \
  --single-select-option-id <SIZE_OPTION_ID>
```

### Set Sprint or Agent (text fields)

```bash
gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTF_lAHODRyXic4BRbrRzg_Q5DY \
  --text "S1"

gh project item-edit \
  --project-id PVT_kwHODRyXic4BRbrR \
  --id <ITEM_ID> \
  --field-id PVTF_lAHODRyXic4BRbrRzg_Q5GU \
  --text "Ralph"
```

### List all items on the board

```bash
gh project item-list 5 --owner jperezdelreal --format json
```

### Archive a done item

```bash
gh project item-archive 5 --owner jperezdelreal --id <ITEM_ID>
```

## Workflow

### When picking up an issue:
1. Check if the issue is already on the board (`item-list` + filter by URL)
2. If not on the board, add it (`item-add`)
3. Set **Game** field based on which repo the issue is from
4. Set **Priority** and **Size** fields
5. Set **Agent** to the working agent name and **Sprint** to current sprint
6. Move to **In Progress** (`item-edit` with `IN_PROGRESS_ID`)
7. Do the work
8. When PR merges or issue closes → move to **Done**

## Duplicate Prevention

**BEFORE creating any new issue**, always:

1. Search existing open issues across all FFS repos:
   ```bash
   gh search issues --owner jperezdelreal --state open "search terms" --json number,title,url,repository
   ```
2. Check the project board for similar items:
   ```bash
   gh project item-list 5 --owner jperezdelreal --format json \
     --jq '.items[] | select(.content.title | test("keyword"; "i")) | {title: .content.title, url: .content.url}'
   ```
3. Only create a new issue if no existing issue covers the same work.

## Done Items Archiving

Issues in **Done** status for 3+ days should be archived:

```bash
gh project item-archive 5 --owner jperezdelreal --id <ITEM_ID>
```

## Tips

- Always read this skill BEFORE starting any project board operation
- The board is the single source of truth for what's in progress across all FFS repos
- If `gh project` commands fail with scope errors, run: `gh auth refresh -s project,read:project`
- When in doubt about an ID, re-run `gh project field-list 5 --owner jperezdelreal --format json`
- When adding a new item, always set the **Game** field based on the source repo
- Keep the board in sync: every issue touch should update the board status
