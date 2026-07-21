---
name: dependency-review
description: Evaluate whether to add a new runtime or development dependency before adding it. Use whenever a new package is proposed. Weighs standard-library alternatives, cost, transitive impact, maintenance, license, and supply-chain risk, then decides add, do not add, or defer. Does not install anything.
disable-model-invocation: true
---

# dependency-review

Run this before adding any new runtime or development dependency.

Read the first of these files that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, do not scan the filesystem; apply these core constraints:
run one expensive command at a time, prefer targeted tests before full
suites, disable watch mode, and run full validation only at milestones.

## Evaluate

- Exact problem being solved.
- Whether the standard library or platform API is sufficient.
- Whether an existing project dependency already solves it.
- Approximate amount of local code avoided.
- Runtime cost.
- Installation and build cost.
- Transitive dependency impact.
- Maintenance activity.
- License compatibility.
- Security and supply-chain exposure.
- Effect on low-resource development.
- Effect on bundle or container size.

## Rules

- Prefer platform APIs, existing dependencies, and small local functions.
- Do not reimplement cryptography, wallet security, authentication protocols,
  or mature parsers merely to avoid a dependency.
- Do not install the dependency as part of this review.
- Do not modify project files as part of this review.

## Decision

End with exactly one decision:

- **add**
- **do not add**
- **defer pending evidence**
