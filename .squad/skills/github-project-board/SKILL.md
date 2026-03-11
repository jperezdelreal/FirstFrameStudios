---
name: github-project-board
description: 'Manage the First Frame Studios GitHub Project Board V2. Use this skill to move issues between statuses (Todo, In Progress, Done, Blocked, Pending User), add items to the board, check item status, archive completed work, and prevent duplicate issues. Triggers on requests like "update board", "move issue to In Progress", "check project status", "archive done items", "add to board", or any project board management task.'
confidence: low
---

# GitHub Project Board — First Frame Studios

Central "mission control" board for all FFS work across repositories.

## Setup — REQUIRED FIRST TIME

Before this skill works, the project board must exist. If these IDs are still placeholders (`__PENDING__`), run the setup script:

```powershell
# 1. Ensure you have project scopes
gh auth refresh -s project,read:project

# 2. Create the project
gh project create --owner jperezdelreal --title "First Frame Studios" --format json

# 3. Get the project number
gh project list --owner jperezdelreal --format json

# 4. Get the field IDs (you need the Status field ID and its option IDs)
gh project field-list <PROJECT_NUMBER> --owner jperezdelreal --format json

# 5. Update the IDs below with real values
```

## Project IDs

> ⚠️ **Replace these placeholders** after running setup. See `setup-project-board.ps1`.

```
OWNER:           jperezdelreal
PROJECT_NUMBER:  5
PROJECT_ID:      PVT_kwHODRyXic4BRbrR
STATUS_FIELD_ID: PVTSSF_lAHODRyXic4BRbrRzg_Qx64

# Status option IDs (from field-list output)
TODO_ID:          f75ad846
IN_PROGRESS_ID:   47fc9ee4
DONE_ID:          98236657
BLOCKED_ID:       __PENDING__
PENDING_USER_ID:  __PENDING__
```

Once the project is created and IDs are filled in, update this section and remove the `__PENDING__` markers.

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
| **Blocked** | Waiting on external dependency or upstream issue |
| **Pending User** | Waiting for human review, decision, or input |

## Core Commands

### Get item ID for an issue on the board

```bash
# Find the item ID for an issue URL
gh project item-list <PROJECT_NUMBER> --owner jperezdelreal --format json \
  --jq '.items[] | select(.content.url == "ISSUE_URL") | .id'
```

### Add an issue to the board

```bash
gh project item-add <PROJECT_NUMBER> --owner jperezdelreal --url <ISSUE_URL>
```

### Move an item to a status

```bash
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <STATUS_OPTION_ID>
```

**Example — move to In Progress:**
```bash
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <IN_PROGRESS_ID>
```

### List all items on the board

```bash
gh project item-list <PROJECT_NUMBER> --owner jperezdelreal --format json
```

### Archive a done item

```bash
gh project item-archive <PROJECT_NUMBER> --owner jperezdelreal --id <ITEM_ID>
```

## Workflow

### When picking up an issue:
1. Check if the issue is already on the board (`item-list` + filter by URL)
2. If not on the board, add it (`item-add`)
3. Move to **In Progress** (`item-edit` with `IN_PROGRESS_ID`)
4. Do the work
5. When PR merges or issue closes → move to **Done** (`item-edit` with `DONE_ID`)

### When blocked:
- Move to **Blocked** and add a comment explaining what's blocking

### When waiting for human:
- Move to **Pending User** and add a comment explaining what's needed

## Duplicate Prevention

**BEFORE creating any new issue**, always:

1. Search existing open issues across all FFS repos:
   ```bash
   gh search issues --owner jperezdelreal --state open "search terms" --json number,title,url,repository
   ```
2. Check the project board for similar items:
   ```bash
   gh project item-list <PROJECT_NUMBER> --owner jperezdelreal --format json \
     --jq '.items[] | select(.content.title | test("keyword"; "i")) | {title: .content.title, url: .content.url}'
   ```
3. Only create a new issue if no existing issue covers the same work.
4. If a near-duplicate exists, comment on it or update it instead.

## Done Items Archiving

Issues that have been in **Done** status for 3+ days should be archived:

1. List done items:
   ```bash
   gh project item-list <PROJECT_NUMBER> --owner jperezdelreal --format json \
     --jq '.items[] | select(.fieldValues[] | select(.name == "Status" and .value == "Done"))'
   ```
2. For each done item older than 3 days:
   - Close the issue with a summary comment of what was accomplished
   - Archive the item from the board:
     ```bash
     gh project item-archive <PROJECT_NUMBER> --owner jperezdelreal --id <ITEM_ID>
     ```

## Tips

- Always read this skill BEFORE starting any project board operation
- The board is the single source of truth for what's in progress across all FFS repos
- If `gh project` commands fail with scope errors, run: `gh auth refresh -s project,read:project`
- When in doubt about an ID, re-run `gh project field-list` to get current values
- Keep the board in sync: every issue touch should update the board status
