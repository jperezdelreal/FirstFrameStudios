# Decision: GitHub Pages Blog Setup

**Author:** Jango (Tool Engineer)
**Date:** 2026-07-24
**Status:** Implemented

## Decision

Set up GitHub Pages for FirstFrameStudios as a Jekyll-powered studio dev blog, served from `/docs` on main branch.

## Rationale

- **Jekyll** chosen because GitHub Pages has native support — zero CI workflow needed, no build step to maintain
- **minima theme** — clean, readable, blog-focused. Can upgrade to `just-the-docs` later if we need more structure
- **`/docs` on main branch** — simpler than a `gh-pages` branch. All content lives alongside the codebase
- **Blog format** — dev diary posts in `_posts/` with frontmatter, auto-indexed on homepage

## What Was Created

- `docs/_config.yml` — Jekyll config with minima theme
- `docs/index.md` — Homepage with studio info, project links, team description
- `docs/about.md` — About page with philosophy and journey
- `docs/_posts/2026-03-11-studio-launch.md` — Launch announcement blog post
- `docs/Gemfile` — GitHub Pages gem dependencies

## URL

https://jperezdelreal.github.io/FirstFrameStudios/

## Impact

- All agents can now add blog posts by creating files in `docs/_posts/YYYY-MM-DD-title.md`
- Mace (Scribe) should own blog content going forward — dev diaries, milestone posts
- README.md updated with blog link in Quick Links
