# Blog Automation

## Confidence: low

## Purpose
Automated blog post generation for the FFS hub site. Game milestones and ceremonies produce blog posts that chronicle studio activity.

## Triggers
Blog posts are generated when:
1. **Ceremony completion** — After any ceremony (retro, design review, kickoff), Scribe generates a summary blog post
2. **Milestone closure** — When a GitHub milestone is closed in any game repo, Ralph detects it and triggers a post
3. **Release tags** — When a game repo creates a release tag (v0.1, v1.0, etc.), a blog post is generated
4. **Manual request** — User says "write a blog post about X"

## Blog Post Format
Posts are Astro content collections at `docs/src/content/blog/` in the FFS hub repo.

File naming: `{YYYY-MM-DD}-{slug}.md`

Frontmatter:
```yaml
---
title: "ComeRosquillas v0.2 — New Power-ups!"
date: 2026-03-11
tags: ["comerosquillas", "release"]
game: "ComeRosquillas"
author: "Squad"
---
```

## Content Guidelines
- Keep posts SHORT (200-400 words max)
- Lead with what's new/interesting for players
- Include 1-2 screenshots or GIFs if available
- End with "Play it now" link to game's Pages
- Tone: excited but genuine, not corporate

## Automation Flow
```
Game repo event (milestone/release/ceremony)
  → Ralph detects during work-check cycle
  → Ralph spawns Scribe with blog post task
  → Scribe writes .md to docs/src/content/blog/ in FFS hub
  → Scribe creates PR to FFS hub
  → Push to main triggers Astro rebuild
  → Blog post live on GitHub Pages
```

## Cross-Repo Mechanics
- Ralph monitors ALL game repos (configured in ralph-watch.ps1)
- Blog posts are written to FFS HUB repo (not game repos)
- Scribe needs write access to FFS hub for blog PRs
- Alternative: ceremony facilitator writes the post directly during the ceremony

## Ralph Integration
In ralph-watch.ps1, the Ralph prompt should include:
"Check for closed milestones and new releases across game repos. When found, generate a blog post summarizing the achievement and submit as PR to the FFS hub docs/src/content/blog/ directory."

## What NOT to Blog
- Internal tooling changes (unless significant)
- Routine PR merges
- Agent reassignments or squad mechanics
- Anything that requires user approval first
