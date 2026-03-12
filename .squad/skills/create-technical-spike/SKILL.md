---
name: create-technical-spike
description: 'Create time-boxed technical spike documents for critical development decisions'
domain: "process"
confidence: "medium"
has_reference: true
---

## Context
Time-boxed research for critical technical questions that must be answered before development. Each spike focuses on single decision with clear deliverables and timelines.

## Core Patterns

- **File naming:** `[category]-[short-description]-spike.md` in `docs/spikes/`
- **Structure:** Title, Summary (objective, why, timebox, deadline), Research Questions, Investigation Plan, Technical Context, Research Findings, Decision, Status History
- **Categories:** API Integration, Architecture & Design, Performance, Platform, Security, User Experience
- **Success criteria:** This spike is complete when: [specific criteria], [recommendation documented], [proof of concept]
- **Research strategy:** Phase 1 (gather info) → Phase 2 (validate/test) → Phase 3 (decide/document)

## Key Examples

**Spike frontmatter:**
```yaml
---
title: "API Copilot Integration Spike"
category: "Technical"
status: "🔴 Not Started"
priority: "High"
timebox: "1 week"
created: 2026-03-10
owner: "Jango"
tags: ["technical-spike", "api", "research"]
---
```

**Status progression:** 🔴 Not Started → 🟡 In Progress → 🟢 Complete

## Anti-Patterns

- **Multiple questions per spike** — One decision per document
- **No time box** — Research expands infinitely
- **No proof of concept** — Recommendation without evidence
- **No follow-up actions** — Decision made but not implemented
