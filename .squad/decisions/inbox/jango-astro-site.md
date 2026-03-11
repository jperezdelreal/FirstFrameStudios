### 2026-03-11: Replace Jekyll Docs with Astro Site (Jango)
**Date:** 2026-03-11  
**Author:** Jango (Tool Engineer)  
**Requested by:** Joaquín  
**Status:** ✅ Implemented

**Context:**
Joaquín wanted a site inspired by Brady Gaster's Squad docs (https://bradygaster.github.io/squad/) — modern, dark, polished. The existing Jekyll setup in docs/ was a bare minima theme with limited appeal for a game studio.

**Decision:**
Replaced Jekyll with Astro 6 + Tailwind CSS v4. Created a full studio site with:
- Landing page: hero, feature cards, project cards, "how it works" steps, archived games
- Blog section with Astro content collections (glob loader)
- BaseLayout with glassmorphism header, mobile nav, dark theme
- GitHub Actions workflow for automated deployment to GitHub Pages

**Rationale:**
- **Astro** — static site generator with near-zero JS shipped, great for content sites
- **Tailwind CSS v4** — utility-first CSS, rapid iteration without separate CSS files
- **Dark theme** — game studios look better dark; matches the industry aesthetic
- **Content collections** — type-safe blog posts, easy to add more posts over time
- **GitHub Actions** — automated deploy on push to main (only when docs/ changes)

**Technical Notes:**
- `@astrojs/tailwind` integration does NOT support Astro 6 (peer dep: astro ≤5). Use `@tailwindcss/vite` plugin directly in `astro.config.mjs`
- Content collections in Astro 5+/6 require `glob` loader from `astro/loaders`, not `type: 'content'`
- Site config: `site: 'https://jperezdelreal.github.io'`, `base: '/FirstFrameStudios'`

**Links:**
- Site: https://jperezdelreal.github.io/FirstFrameStudios/
- Workflow: `.github/workflows/deploy-pages.yml`
- Inspiration: https://bradygaster.github.io/squad/
