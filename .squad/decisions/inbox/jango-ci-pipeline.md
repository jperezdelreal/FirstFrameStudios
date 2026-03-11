# Decision: ComeRosquillas CI Pipeline Strategy

**Date:** 2025-01-XX  
**Decider:** Jango (Tool Engineer)  
**Context:** Issue #6 — Add CI pipeline with validation and deploy checks for ComeRosquillas game

## Decision

Implemented a lightweight CI pipeline for ComeRosquillas using GitHub Actions that validates JavaScript syntax, HTML structure, and game assets without adding build complexity to a vanilla HTML/JS project.

## Rationale

1. **Keep it Simple:** ComeRosquillas is a vanilla HTML/JS/Canvas game with no build step. Adding webpack, parcel, or other bundlers would be overkill and slow down development.

2. **Fast Feedback:** CI runs in ~30 seconds, providing immediate feedback on syntax errors and structural issues.

3. **PR Preview Comments:** Automated comments on PRs improve developer experience by showing validation results and deployment URLs in one place.

4. **Separation of Concerns:** 
   - CI validation runs on all PRs and main pushes
   - Deployment handled by existing `deploy-pages.yml` workflow
   - Did not interfere with Astro docs site deployment

5. **Node.js Native Tools:** Used `node --check` for JS validation instead of adding ESLint/linters. Can be extended later if needed.

## Alternatives Considered

1. **Add ESLint/Prettier:** Rejected for initial implementation — adds complexity and config files. Can be added later if code style becomes an issue.

2. **Use HTML validator service:** Rejected — adds external dependency and network call. Simple grep checks are sufficient for now.

3. **Add Playwright/Puppeteer tests:** Rejected — no test files exist yet. CI focuses on syntax validation first. Can add E2E tests in future sprints.

4. **Combine with squad-ci.yml:** Rejected — squad-ci.yml is squad-framework specific. Kept separate for clarity.

## Consequences

**Positive:**
- Fast CI runs (< 1 minute)
- Zero dependencies beyond Node.js
- Clear validation messages
- PR comments improve developer experience
- Does not break existing deployment workflow

**Negative:**
- No code style enforcement yet (no linter)
- No E2E tests yet (no browser automation)
- Manual grep checks could be replaced with proper HTML validator

**Neutral:**
- Can extend with ESLint, Prettier, Playwright later without major changes
- Current approach validates "does it run" not "is it good code"

## Follow-up

- Consider adding ESLint + Prettier if code style issues arise
- Add Playwright E2E tests when game stabilizes
- Consider adding lighthouse CI for performance checks
- Monitor CI run times — if they grow beyond 2 minutes, optimize

## Related

- PR: jperezdelreal/ComeRosquillas#9
- Issue: jperezdelreal/ComeRosquillas#6
- Workflow: `.github/workflows/ci.yml`
