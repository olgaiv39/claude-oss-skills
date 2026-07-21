---
name: oss-plan
description: Produce an execution plan before writing substantial code for a public open-source project. Use when starting or extending a feature to define the narrowest end-to-end slice, validation per step, trust boundaries, deployment path, and public-repository risks. Keeps the project runnable after every step. Does not write implementation code.
disable-model-invocation: true
---

# oss-plan

Produce an execution plan that keeps the project runnable after every
meaningful step. Do not write implementation code while using this skill.

## Activate when

- Starting a new feature or a non-trivial change
- Scope, sequencing, or trust boundaries are unclear
- A change will touch multiple files or an external system

## Do not activate when

- The change is a one-line fix with obvious validation -> use `implement-minimal`
- The repository does not exist yet -> use `oss-bootstrap`
- You are debugging a failure -> use `test-and-debug`

## Required inputs

- The feature or change request
- Access to the repository to inspect status and conventions
- Any external systems the feature must touch

## Low-resource policy

Read the first of these that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, apply this fallback: run one expensive command at a time,
prefer the narrowest validation, disable watch mode, reuse existing
environments, and run full validation only at a milestone boundary. Do not
scan the whole filesystem to locate the policy.

## Facts that must not be assumed

- The test runner, package manager, or build tool
- That an external API, wallet, or MCP tool is available offline
- That existing tests pass right now
- The deployment target

Separate confirmed facts from assumptions and label every assumption.

## Preflight

1. `git status --short` and `git log --oneline -5` for current state
2. `git diff --stat` for uncommitted work in progress
3. Identify project conventions ->
   [references/execution-planning.md](references/execution-planning.md)
4. Identify external systems and trust boundaries ->
   [references/trust-boundaries.md](references/trust-boundaries.md)

## Workflow

1. Inspect current status and recent diff
2. Discover project conventions and existing validation commands
3. Identify the narrowest end-to-end path that delivers observable value
4. Separate confirmed requirements from assumptions
5. Map external systems, inputs, and trust boundaries
6. Define targeted validation for each increment
7. Mark which actions are locally expensive and schedule them at milestones
8. Identify when another skill is required (dependency-review, implement-minimal,
   test-and-debug, release-deploy)
9. Produce the plan using
   [templates/execution-plan.md](templates/execution-plan.md)
10. Stop after the plan

## Decision branches

- The slice needs a new dependency -> note it and require `dependency-review`
  before implementation, do not assume approval
- The slice depends on an offline external system -> plan a mock boundary and
  mark the live path as unvalidated
- Acceptance cannot be validated cheaply -> narrow the slice until it can
- The change is larger than one vertical slice -> split into sequenced slices,
  each runnable on its own

## Validation escalation

For each increment, specify the smallest check that proves it:

```text
single test or command
related test file
changed-file lint or typecheck
related integration path
full suite only at the milestone that ends the plan
```

Never plan a full-suite run after every edit.

## Stop conditions

- Requirements remain contradictory after one clarification pass
- The narrowest slice still cannot be validated locally
- The plan would require an unavailable external system with no mock

## Human review boundaries

- Trust-boundary decisions involving auth, wallets, or user data
- Any assumption that changes scope materially
- Deployment target selection

## Final report

Produce the plan in the exact section order of
[templates/execution-plan.md](templates/execution-plan.md). Present it for
review and stop; implementation happens under `implement-minimal`.
