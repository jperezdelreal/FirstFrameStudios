# Game Pages Template

## Confidence: low

## Purpose
Reusable pattern for creating GitHub Pages showcase sites for FFS game repos. Each game gets its own Pages site with consistent structure but game-specific branding.

## Architecture
- Each game repo has an Astro site in `docs/`
- Same stack as FFS hub: Astro 6 + Tailwind CSS v4
- Deployed via GitHub Actions on push to main
- Game files served from `/play/` path (copied to `docs/public/play/` during build)

## Site Structure
```
docs/
  src/
    layouts/GameLayout.astro    # Adapted from FFS BaseLayout
    pages/
      index.astro               # Showcase: hero, play button, about, changelog
      play.astro                # Full-screen game embed
    styles/global.css           # Tailwind with game-specific @theme colors
  public/
    play/                       # Game files copied here during build
      index.html
      js/
      assets/
  astro.config.mjs              # base: '/{repo-name}'
  package.json
```

## Branding Customization
Each game overrides these CSS theme variables:
- `--color-primary`: Main game color (FFS uses #8b5cf6 purple)
- `--color-primary-light`: Lighter variant
- `--color-primary-dark`: Darker variant
- `--color-accent`: Secondary accent color
- Background stays dark (#0f0d1a) for consistency

## Consistent Elements (DO NOT change per game)
- Dark theme background
- Header/footer layout structure
- "A First Frame Studios game" in footer with link to hub
- Font: system sans-serif, antialiased
- Mobile responsive design
- GitHub link in header

## Game-Specific Elements (MUST customize per game)
- Color palette (via CSS @theme variables)
- Game title, emoji, tagline
- Hero section content
- Screenshots/media
- Changelog entries
- Game embed path

## GitHub Actions Workflow
Trigger: push to main
Steps:
1. Checkout
2. Setup Node 22
3. Copy game files to docs/public/play/
4. Install deps (cd docs && npm ci)
5. Build (cd docs && npm run build)
6. Upload artifact (actions/upload-pages-artifact with docs/dist/)
7. Deploy (actions/deploy-pages)

## Hub Integration
- FFS hub site (index.astro) project cards should link to game Pages URL
- Pattern: `https://jperezdelreal.github.io/{repo-name}/`
- Hub footer also lists game links

## Examples
- ComeRosquillas: golden/orange theme, donut emoji, arcade tagline
- Flora: green/emerald theme, leaf emoji, cozy roguelite tagline
