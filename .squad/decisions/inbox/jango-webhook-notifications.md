# Decision: Discord Webhook Notifications Architecture

**Date:** 2026-03-12  
**Author:** Jango (Tool Engineer)  
**Status:** Implemented  
**Related:** Issue #163, PR #171

## Context

The squad needed proactive notifications for critical events (CI failures, PR merges, priority issues, Ralph rounds) to keep Joaquin informed without requiring constant manual checking of GitHub.

## Decision

Implement Discord webhook notifications via GitHub Actions workflows with strict rate limiting and simple, spam-free design.

## Architecture

### Reusable Workflow Pattern
- **squad-notify-discord.yml** is the core reusable workflow
- All event-specific workflows call this with inputs (event_type, summary, link, color)
- Centralizes notification logic, rate limiting, and Discord API interaction

### Rate Limiting
- **Max 10 notifications per hour** (hard limit)
- Enforced at both workflow level and PowerShell script level
- Rate limit file tracks timestamps of last 20 notifications
- Silently skips notifications when limit exceeded (logs warning)

### Event Coverage
| Event | Trigger | Workflow |
|-------|---------|----------|
| CI Failure on main | workflow_run (completed + failure) | squad-notify-ci-failure.yml |
| PR Merged | pull_request (closed + merged) | squad-notify-pr-merged.yml |
| Priority Issue | issues (labeled + p0/critical) | squad-notify-priority-issue.yml |
| Ralph Round | schedule (*/30) + heartbeat check | squad-notify-ralph-heartbeat.yml |

### ASCII-Safe Design
- **No emojis** in PowerShell scripts (Windows compatibility)
- Text prefixes instead: `[FAIL]`, `[MERGE]`, `[ALERT]`, `[RALPH]`, `[INFO]`
- Discord embeds support emojis natively (if webhook sender adds them manually)

### Security
- Webhook URL stored in GitHub secret `DISCORD_WEBHOOK_URL`
- Never hardcoded or committed to repo
- PowerShell script reads from environment variable `$env:DISCORD_WEBHOOK_URL`

## Alternatives Considered

**1. Slack webhook** -- More complex setup, requires workspace admin approval  
**2. Email notifications** -- No immediate visibility, requires SMTP config  
**3. GitHub Discussions posts** -- Too noisy, not real-time  
**4. Teams webhook** -- Organizational restrictions, harder to test  

**Why Discord:** Free, simple webhook URL, no auth complexity, instant delivery, Joaquin already uses it.

## Implementation Details

### Heartbeat Round Detection
Ralph heartbeat workflow runs every 30 minutes but only notifies when round number increases:
- Reads `tools/.ralph-heartbeat.json` for current round
- Compares to `.github/.ralph-last-notified-round` (last notified round)
- Only sends notification if current > last
- Updates last notified round on successful send

### Color Codes (Decimal)
- Red (failures/alerts): `15158332`
- Green (success): `5763719`
- Blue (info): `3066993`
- Gray (neutral): `5814783`

### Rate Limit Cleanup
- Keeps last 20 timestamps in rate limit file
- Auto-cleans on every send (tail -n 20 pattern)
- Prevents file growth over time

## Trade-offs

**Pros:**
- Simple setup (one webhook URL, one secret)
- Instant notifications (Discord delivers in <1 second)
- Rate limiting prevents spam
- Reusable workflow reduces duplication
- PowerShell script allows ralph-watch integration

**Cons:**
- Requires Discord webhook URL (manual setup step)
- Rate limit may skip notifications during bursts (acceptable — prevents spam)
- Heartbeat checks every 30 min (not instant, but acceptable for background updates)

## Success Criteria

✅ Webhook endpoint configured (Discord webhook via secret)  
✅ Notification on: CI failure on main branch  
✅ Notification on: PR merged to main  
✅ Notification on: Issue labeled priority:p0 or priority:critical  
✅ Notification on: Ralph round completed (via heartbeat check)  
✅ Notifications include: event type, link, 1-line summary  
✅ Rate limiting: max 10 notifications per hour  
✅ GitHub Actions workflow integration  

## Lessons Learned

1. **Reusable workflows** simplify event-triggered notification patterns
2. **Rate limiting at the source** (before API call) is more reliable than relying on external limits
3. **ASCII-safe constraint** matters for PowerShell — emojis break on some Windows systems
4. **Heartbeat round tracking** prevents duplicate notifications on scheduled checks
5. **workflow_run event** is the cleanest way to catch all CI failures (wildcards work: workflows: ["*"])

## Related Decisions

- Ralph Watch v2 (#167) -- provides heartbeat file for round completion detection
- Daily Metrics Collector (#164) -- could extend to send daily summary notifications

## Tags

`infrastructure`, `notifications`, `discord`, `github-actions`, `webhooks`, `rate-limiting`
