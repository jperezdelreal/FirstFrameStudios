---
name: github-issues
description: 'Create, update, and manage GitHub issues using MCP tools and gh CLI'
domain: "github"
confidence: "high"
has_reference: true
---

## Context
Manage GitHub issues for bug reports, features, tasks. MCP tools for reads, `gh api` for writes (create/update/comment). Issue types preferred over labels for categorization.

## Core Patterns

- **Creating issues:** Use `gh api repos/{owner}/{repo}/issues -X POST -f title="..." -f body="..." -f type="Bug"`
- **Issue types > labels** — Use `type` param (Bug, Feature, Task) instead of labels when available
- **Body structure:** Use templates (Bug Report, Feature Request, Task) from references/templates.md
- **Title guidelines:** Specific, actionable, <72 chars. No redundant prefixes when type is set
- **Updating issues:** `gh api repos/{owner}/{repo}/issues/{number} -X PATCH -f state=closed`
- **Optional params:** `-f type`, `-f labels[]`, `-f assignees[]`, `-f milestone`

## Key Examples

**Bug report:**
```bash
gh api repos/owner/repo/issues -X POST \
  -f title="Login crashes with SSO" \
  -f type="Bug" \
  -f body="## Description
The login page crashes when using SSO.

## Steps to Reproduce
1. Navigate to login
2. Click 'Sign in with SSO'
3. Page crashes

## Expected/Actual
Should redirect to dashboard / Page unresponsive"
```

**Feature request:**
```bash
gh api repos/owner/repo/issues -X POST \
  -f title="Add dark mode support" \
  -f type="Feature" \
  -f labels[]="high-priority"
```

## Anti-Patterns

- **Using `gh issue create` for types** — CLI doesn't support `--type` flag. Use `gh api`
- **Type in title when using type param** — Redundant `[Bug]` prefix
- **Guessing missing info** — Ask user for critical context
- **Not linking related issues** — Use `Related to #123`
