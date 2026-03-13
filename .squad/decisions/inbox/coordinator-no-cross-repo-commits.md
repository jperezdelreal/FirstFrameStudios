### 2026-03-13T20:12Z: Cross-repo communication rule
**By:** jperezdelreal (via SS Coordinator)
**Tier:** T0
**Status:** ✅ ACTIVE
**What:** No repo may make direct git commits to another repo's branch. ALL cross-repo communication goes through GitHub Issues. Each repo's Squad session owns its git state exclusively. This prevents push conflicts when multiple Ralph Go sessions run concurrently.
**Rule:** Use `gh issue create`, `gh issue comment`, `gh pr review` — NEVER `gh api repos/.../contents -X PUT`.