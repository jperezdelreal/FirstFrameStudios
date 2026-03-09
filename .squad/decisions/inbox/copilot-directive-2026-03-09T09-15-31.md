### 2026-03-09T09-15-31: User directives — backlog automation, team autonomy, role overload

**By:** Joaquin (via Copilot)

**Directive 1 — Backlog sync must be automated (CI/CD):**
The backlog audit should not be manual. Create a CI/CD workflow that scans code for TODOs/FIXMEs and docs for undocumented work items, then auto-creates GitHub issues. This should run naturally as part of the development cycle.

**Directive 2 — Lead autonomy on team bandwidth:**
The Lead (Jango) should have full authority to read team bottlenecks and adjust workload distribution without needing CEO approval. The bandwidth restriction that limited Jango to 20% tooling was a mistake — the Lead must be empowered to make these calls independently.

**Directive 3 — Automate Mace's wiki/devblog updates:**
Jango proposed a script to automate wiki and devblog updates (currently Mace's manual responsibility). Joaquin wants this implemented.

**Directive 4 — Solo is overloaded, needs role split:**
Solo's feedback revealed he's doing architecture review + tracking blockers + rebasing + stale issue management. Architecture review is deep work that can't be done well alongside ops tasks. Consider splitting Solo's role or adding a dedicated integration/ops agent.

**Directive 5 — ADRs and Godot integration testing:**
Solo proposed ADRs (Architecture Decision Records) and a dedicated integration agent that runs actual Godot game sessions for validation. Both should be evaluated and implemented.

**Why:** User request — captured for team memory
