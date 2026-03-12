# Milestone Completion Checklist

## Metadata
- **Confidence:** medium
- **Domain:** Agile Process, DevOps, Team Operations
- **Last validated:** 2026-03-08
- **Source:** Ashfall M1+M2 retrospective + Joaquín/Mace directives

## Pattern

A milestone is not complete until all work is merged, tracked, celebrated, and the team is ready for the next cycle. This checklist ensures nothing falls through the cracks.

### The 8-Step Post-Milestone Process

#### 1. Merge All PRs for the Milestone

**Owner:** Jango (Pull Request Lead)  
**Timeline:** As each PR is ready; typically over 2–4 hours

**Steps:**
- All feature branches must be created from **latest main** (verify with `git log --oneline -1`)
- PRs must include `Closes #N` in the **body** (not the title)
- All PRs must have at least 1 approval from Jango (code review lead)
- Merge via GitHub UI with "Create a merge commit" (preserves PR history)
- If a PR has conflicts, rebase onto main and push: `git rebase main && git push --force-with-lease`
- If rebasing is too complex (multiple unrelated commits), use cherry-pick fallback

**Success criteria:**
- All feature branches are gone from `origin`
- All milestone issues have their corresponding PRs merged
- Main branch has clean, linear history

#### 2. Verify Issues Auto-Closed (Audit `Closes #N`)

**Owner:** Jango or Mace (Scribe)  
**Timeline:** Immediately after all PRs merge (5–10 minutes)

**Steps:**
1. Go to GitHub → Issues → Filter by milestone (e.g., "M2 — Visual Polish")
2. For each closed issue, verify it shows "Closed via PR #XYZ"
3. If an issue was closed manually (not via PR), document why in the issue comment
4. If an issue was NOT closed but should be, investigate:
   - PR body didn't include `Closes #N` → reopen PR, add it to body, re-merge
   - Issue was addressed by cherry-pick → add comment: "Closed via cherry-pick of commit abc123"

**Common gotchas:**
- `Closes #N` in PR title alone does NOT auto-close (must be in body)
- `Closes #N` in commit message alone does NOT auto-close
- Only works if the PR is merged to main (not if it's closed without merge)

**Success criteria:**
- 100% of closed issues show "Closed via PR #XYZ" in their timeline
- Zero manual issue closures without documentation

#### 3. Update GitHub Wiki (Automatic — Mace)

**Owner:** Mace (Producer)  
**Timeline:** Within 24 hours of milestone completion  
**Directive:** `mace-wiki-updates.md`

Mace's responsibility (automatic, not requested by team). Wiki must be updated for:
- Home.md — Add milestone summary, merged PR count, completion status (✅)
- Ashfall-Sprint-0.md — Add new milestone section with issue numbers and PR list
- Ashfall-Architecture.md — Add new systems, link to scene files
- Ashfall-GDD.md — Mark designed systems as "complete"
- Team.md — Update team size if agents were added/removed

**Verification:** Wiki renders without 404 links, cross-references work.

#### 4. Post Dev Diary to GitHub Discussions (Automatic — Mace)

**Owner:** Mace (Producer)  
**Timeline:** Within 24 hours of milestone completion  
**Directive:** `mace-devlog-process.md`

Mace's responsibility (automatic, not requested by team). Discussion post includes:
- **Title:** `🔥 Dev Diary #{Milestone}: {Milestone Title}` (e.g., `🔥 Dev Diary #2: Visual Polish`)
- **Content:** The Pitch + What We Shipped + By The Numbers + What's Next + The Meta + CTA
- **Tone:** Passionate, transparent, slightly irreverent — behind-the-scenes documentary, not corporate
- **Visibility:** Public-facing marketing for First Frame Studios

Post in the "General" discussion category. Link from wiki milestone entry.

#### 5. Run Retrospective Ceremony (Facilitated — Jango)

**Owner:** Jango (Lead)  
**Timeline:** Within 48 hours of milestone completion  
**Frequency:** After every milestone (M1, M2, M3, M4, etc.)

**Purpose:** Honest reflection, not a status report. Identify what worked, what failed, and what to do differently.

**Process:**
1. Jango schedules 90-minute meeting with core team (architects, leads, QA)
2. Review the retrospective template (see examples: `games/ashfall/docs/RETRO-M1-M2.md`)
3. Discuss:
   - What we built (facts, metrics, delivered systems)
   - What went well (architectural decisions, team wins, technical strengths)
   - What didn't go well (bottlenecks, integration failures, process gaps)
   - Key decisions made (creative, architecture, process)
   - Technical debt & risks (critical, high, medium)
   - Recommendations for next milestone (process changes, scope adjustments)
   - Team performance (who delivered, who struggled, why)
4. Document findings in `games/ashfall/docs/RETRO-M{X}.md`
5. Extract action items and file them in `.squad/decisions/inbox/` for team awareness

**Output:** Public retrospective document + action items + process improvements

#### 6. Clean Up Stale Branches

**Owner:** Jango (Pull Request Lead)  
**Timeline:** After all PRs merge (10–15 minutes)

**Steps:**
1. List all feature branches on main:  
   `git --no-pager branch -r | grep squad/`
2. Delete merged branches locally and remotely:  
   ```powershell
   git branch -d squad/1-godot-scaffold
   git push origin --delete squad/1-godot-scaffold
   ```
3. If a branch was never merged, decide:
   - Keep for M3/M4 work? → Document in `.squad/decisions/inbox/`
   - Abandoned? → Delete with comment in GitHub (explain why)
4. Verify main is clean:  
   `git --no-pager log --oneline -1 origin/main`

**Success criteria:**
- Zero stale branches on origin
- Local branches match origin
- Milestone issues reference only merged PRs

#### 7. Update `.squad/identity/now.md` with New Focus

**Owner:** Solo (Chief Architect)  
**Timeline:** After all items 1–6 complete (30 minutes)

**Content to update:**

```markdown
# Now

## Current Focus
Ashfall — 1v1 Fighting Game (Godot 4)

## Status
- M1 (Greybox Prototype): ✅ COMPLETE
- M2 (Visual Polish): ✅ COMPLETE  
- M3 (Character Sprites): 🔜 NEXT — Issue #9
- M4 (Playtesting): 📋 PLANNED — Issue #13

## Recent Retrospective
[SUMMARY OF M1+M2 KEY DECISIONS]

## Active Directives
- Joaquín never reviews code — Jango handles all PR reviews
- Wiki updates after each milestone — Mace's responsibility (automatic)
- Dev Diary posts after each milestone — Mace's responsibility (automatic)
- Post-milestone checklist: merge → close issues → wiki → devlog → retro → cleanup
```

**Key fields:**
- **Current Focus:** Project name + genre/engine
- **Status:** Milestone list with completion indicators (✅ COMPLETE, 🔜 NEXT, 📋 PLANNED, ❌ BLOCKED)
- **Recent Retrospective:** 1–2 sentences summarizing the biggest lessons from the completed milestone
- **Active Directives:** Team agreements that persist across milestones (review authority, automation, process gates)

This file is the single source of truth for what the team is doing RIGHT NOW.

#### 8. Create Issues for Next Milestone

**Owner:** Yoda (Game Designer) + Solo (Architect)  
**Timeline:** Within 24 hours of milestone completion  
**Format:** Each milestone gets a GitHub project board + issues

**Process:**
1. Review the retrospective action items (item 5)
2. Identify blocking issues that MUST be fixed before next milestone (P0)
3. Define the next milestone scope (feature list, issue list, acceptance criteria)
4. Create GitHub issues:
   - **Title:** `[M{N}] {Feature}` (e.g., `[M3] Character Sprites — Kael`)
   - **Body:** Acceptance criteria, links to design documents, blocking issues
   - **Labels:** `milestone-{N}`, `type:feature` or `type:bugfix`
   - **Milestone:** Next milestone in the dropdown
5. Create a GitHub project board if it doesn't exist: `Ashfall M{N}`
6. Add all issues to the project board in "To Do" column
7. Link related issues with "Related to" or "Depends on" in the issue body

**Success criteria:**
- Next milestone has 6–12 well-defined issues
- Each issue has acceptance criteria and an estimated owner
- All blocking issues from the retrospective are filed as P0
- Team can start work immediately when next milestone begins

---

## Timeline Example (M2 → M3)

| Time | Step | Owner | Output |
|------|------|-------|--------|
| **14:00** | Merge all PRs (#20, #21, #22) | Jango | Main has 8 new systems |
| **14:15** | Verify `Closes #N` worked | Mace | 11 issues show "Closed via PR" |
| **14:30** | (Mace updates wiki automatically) | Mace | Wiki reflects M2 completion |
| **15:00** | (Mace posts dev diary automatically) | Mace | Discussion post live |
| **16:00** | Run 90-min retrospective | Jango | RETRO-M2.md + action items documented |
| **17:30** | Clean up stale branches | Jango | 3 branches deleted, main is clean |
| **18:00** | Update now.md | Solo | Team knows what's next |
| **18:30** | File M3 issues | Yoda + Solo | 8 issues in M3 board, ready to start |
| **19:00** | ✅ Milestone closed, team ready for M3 | — | Full ceremony complete |

---

## When to Apply

- After every milestone completion (M1, M2, M3, M4, etc.)
- After every sprint or major delivery cycle
- When transitioning from one focus area to another
- When team composition changes

## Key Takeaway

**A milestone isn't done when the code merges. It's done when the team has closure, the next work is planned, and there are no loose ends.** This 8-step process takes 4–6 hours total and prevents post-milestone chaos.
