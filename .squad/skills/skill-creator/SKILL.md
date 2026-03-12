---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
has_reference: true
---

# Skill Creator

Create new skills and iteratively improve them through eval-driven development.

## Context

Use this skill when a user wants to create a new skill from scratch, improve an existing skill, run evaluations to benchmark skill quality, or optimize a skill's description for better triggering. The core loop is: understand intent → draft skill → test with evals → review with user → iterate.

## Core Patterns

### 1. Capture Intent
- Understand what the skill should do, when it should trigger, and expected output format
- If the conversation already contains a workflow, extract answers from history first
- Ask: What should it do? When should it trigger? What's the output format? Should we set up test cases?

### 2. Interview and Research
- Ask about edge cases, input/output formats, example files, success criteria, dependencies
- Check available MCPs for research; come prepared to reduce burden on the user
- Wait to write test prompts until this is ironed out

### 3. Write the SKILL.md
- **Frontmatter**: `name` + `description` (description is the primary trigger mechanism — make it slightly "pushy" to combat undertriggering)
- **Body**: Keep under 500 lines; use progressive disclosure (SKILL.md → reference files → scripts)
- **Style**: Use imperative form, explain the *why* behind instructions, avoid heavy-handed MUSTs
- **Structure**: `skill-name/` with `SKILL.md` (required), plus optional `scripts/`, `references/`, `assets/`

### 4. Test and Evaluate
- Write 2-3 realistic test prompts; confirm with user; save to `evals/evals.json`
- Spawn all runs (with-skill AND baseline) in parallel using subagents
- While runs execute, draft assertions for quantitative grading
- On completion, capture timing data and grade with `agents/grader.md`
- Generate eval viewer via `eval-viewer/generate_review.py` — ALWAYS do this before making your own edits
- Present results to user for qualitative review

### 5. Iterate
- Read user feedback; generalize improvements (don't overfit to test cases)
- Keep the skill lean — remove what isn't pulling its weight
- Look for repeated work across test runs → bundle into `scripts/`
- Rerun all test cases into `iteration-<N+1>/` with baselines; re-launch viewer
- Repeat until user is happy or feedback is all empty

### 6. Description Optimization (optional, after skill is finalized)
- Generate 20 trigger eval queries (mix of should-trigger and should-not-trigger)
- Review with user, then run optimization loop via `run_loop.py` / `run_eval.py`
- Apply the best-performing description

## Key Examples

**Eval JSON structure:**
```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

**Skill directory layout:**
```
skill-name/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

## Anti-Patterns

- **Don't skip the eval viewer.** Always run `generate_review.py` before revising the skill yourself — get results in front of the human first.
- **Don't overfit.** Skills will be used across many prompts; avoid fiddly changes that only fix specific test cases.
- **Don't use rigid ALWAYS/NEVER rules.** Explain reasoning instead so the model understands *why*.
- **Don't write assertions before running tests.** Draft them while runs are in progress, not before.
- **Don't forget baselines.** Always run without-skill baseline alongside with-skill runs for comparison.
- **Don't create malware or exploit skills.** Skills must not surprise the user in their intent.

## Reference Files

See `REFERENCE.md` for full details on evaluation steps, blind comparison, description optimization, platform-specific instructions, and advanced patterns.

- `agents/grader.md` — Assertion evaluation
- `agents/comparator.md` — Blind A/B comparison
- `agents/analyzer.md` — Win/loss analysis
- `references/schemas.md` — JSON schemas for evals, grading, etc.