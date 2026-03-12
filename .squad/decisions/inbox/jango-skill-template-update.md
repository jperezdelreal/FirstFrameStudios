# Decision: Skill Template Update — SKILL.md + REFERENCE.md Split

**Date**: 2025-01-30  
**Author**: Jango (Tool Engineer)  
**Status**: Implemented  
**Issue**: #185

## Context

The original skill template defined only a single SKILL.md file with no size constraints. As skills accumulate detailed patterns and examples, they can exceed optimal context window usage during agent operations.

## Decision

Updated `.squad/templates/skill.md` to formalize a two-file structure:

1. **SKILL.md** (max 5KB):
   - Frontmatter with `has_reference` boolean field
   - Concise sections: Context (2-3 sentences), Core Patterns (bullets), Key Examples (1-2 only), Anti-Patterns (short list)
   - G2 guardrail enforced via template note

2. **REFERENCE.md** (on-demand, no size limit):
   - Deep Dive — expanded pattern explanations
   - Full Examples — complete code samples, edge cases
   - Implementation Guide — step-by-step when applicable
   - Further Reading — external resources

## Rationale

- **Performance**: 5KB SKILL.md fits comfortably in agent context; REFERENCE.md loaded only when needed
- **Clarity**: Separation forces skill authors to distill essential vs. detailed content
- **Scalability**: As knowledge base grows, reference material doesn't bloat primary skill files

## Impact

- All new skills should follow this template
- Existing skills can be refactored as needed to split large files
- The `has_reference` field enables tooling to determine when to load reference content
