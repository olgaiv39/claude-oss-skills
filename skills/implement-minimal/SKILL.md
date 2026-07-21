---
name: implement-minimal
description: Implement the smallest complete change that satisfies the current acceptance criteria for a public open-source project. Use when writing or editing code after a plan exists. Avoids speculative abstraction, unrelated changes, obvious comments, and unverified validation claims.
disable-model-invocation: true
---

# implement-minimal

Central rule:

> Implement the smallest complete change that satisfies the current
> acceptance criteria.

Read the first of these files that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, do not scan the filesystem; apply these core constraints:
run one expensive command at a time, prefer targeted tests before full
suites, disable watch mode, and run full validation only at milestones.

## Before editing

State clearly:

- Files to modify.
- Files to create.
- New dependencies (each requires `dependency-review` first).
- Targeted validation you will run.

## Implementation rules

- Do not change unrelated files.
- Do not silently rewrite entire modules.
- Do not introduce an interface for a single implementation.
- Do not introduce factories, repositories, providers, adapters, managers,
  registries, or service layers without a demonstrated current need.
- Do not extract helpers used only once unless it materially improves clarity.
- Do not create generic utilities for possible future use.
- Do not add fallback behavior not required by acceptance criteria.
- Do not add defensive branches for impossible or unsupported states.
- Prefer existing project conventions.
- Validate external data at system boundaries.
- Keep internal data models compact.
- Separate business logic from UI only where it improves testing or clarity.
- Avoid unrelated formatting churn and broad renaming.
- Preserve public APIs unless the task explicitly changes them.
- Do not add dependencies without running `dependency-review`.
- Do not claim validation that was not run.

## Comment policy

- Comments may explain non-obvious constraints, trade-offs, external
  behavior, security decisions, or mathematical assumptions.
- Comments must not narrate the next line, function name, loop, condition,
  assignment, or obvious control flow.
- Prefer clear names and small functions over explanatory comments.
- Remove stale comments only in code you directly modify, and only when safe.

## After implementation

Report:

- Implemented.
- Deliberately not implemented.
- Validation performed.
- Validation not performed.
- Known limitations.
- Files requiring human review.
