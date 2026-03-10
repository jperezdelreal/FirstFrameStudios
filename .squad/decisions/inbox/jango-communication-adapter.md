# Decision: CommunicationAdapter for GitHub Discussions

**Author:** Jango  
**Date:** 2025-07-23  
**Status:** Implemented (partial — category creation requires manual step)

## Context

Joaquín wants an automated devblog where Scribe and Ralph post session summaries to GitHub Discussions after each session. This provides public visibility into what the Squad is working on without manual effort.

## Decision

1. **Channel:** GitHub Discussions (native to the repo, no external services needed)
2. **Config:** Added `communication` block to `.squad/config.json` with:
   - `channel: "github-discussions"`
   - `postAfterSession: true` — Scribe posts after every session
   - `postDecisions: true` — Decision merges get posted
   - `postEscalations: true` — Blockers get visibility
   - `repository: "jperezdelreal/FirstFrameStudios"`
   - `category: "Squad DevLog"` — dedicated category for automated posts
3. **Scribe charter updated** with Communication section defining format, content, and emoji convention
4. **Test post created** at https://github.com/jperezdelreal/FirstFrameStudios/discussions/151

## Manual Action Required

⚠️ **Joaquín must create the "Squad DevLog" discussion category manually:**
1. Go to https://github.com/jperezdelreal/FirstFrameStudios/settings → Discussions
2. Click "New category"
3. Name: `Squad DevLog`
4. Description: `Automated session logs from the Squad AI team`
5. Format: `Announcement` (only maintainers/bots can post, others can comment)
6. Emoji: 🤖

The GitHub API does not support creating discussion categories programmatically. Until this category is created, posts should use "Announcements" as a fallback.

## Alternatives Considered

- **GitHub Issues:** Too noisy, mixes with real bugs/tasks
- **Wiki:** Good for reference docs, bad for chronological updates
- **External blog:** Unnecessary dependency, discussions are built-in

## Impact

- Scribe: New responsibility — post to Discussions after session logging
- Ralph: Can use same channel for heartbeat/status updates
- All agents: Session work becomes publicly visible
