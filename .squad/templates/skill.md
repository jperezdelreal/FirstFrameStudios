# SKILL.md Template

> **G2 Guardrail**: SKILL.md max 5KB. Detailed content goes in REFERENCE.md (loaded on-demand).

---
name: "{skill-name}"
description: "{what this skill teaches agents}"
domain: "{e.g., testing, api-design, error-handling}"
confidence: "low|medium|high"
source: "{how this was learned: manual, observed, earned}"
has_reference: false  # Set to true if REFERENCE.md exists
tools:
  # Optional — declare MCP tools relevant to this skill's patterns
  # - name: "{tool-name}"
  #   description: "{what this tool does}"
  #   when: "{when to use this tool}"
---

## Context
{2-3 sentences max: when and why this skill applies}

## Core Patterns
{Essential patterns, conventions, approaches — bullet points, concise}

## Key Examples
{1-2 critical code examples only — keep minimal}

## Anti-Patterns
{Short list: what to avoid}

---

# REFERENCE.md Template (Optional)

Create REFERENCE.md alongside SKILL.md for detailed content. Set `has_reference: true` in frontmatter.

## Deep Dive
{Expanded explanations of each pattern from Core Patterns}

## Full Examples
{Complete code examples, edge cases, variations}

## Implementation Guide
{Step-by-step instructions when applicable}

## Further Reading
{Links, resources, documentation}
