---
name: implement-minimal
description: Implement the smallest complete change that satisfies the current acceptance criteria for a public open-source project. Use when writing or editing code after a plan or a clear acceptance criterion exists. Avoids speculative abstraction, unrelated changes, obvious comments, and unverified validation claims. Keeps the project runnable after the increment.
disable-model-invocation: true
---

# implement-minimal

Central rule:

> Implement the smallest complete change that satisfies the current
> acceptance criteria, and leave the project runnable.

Do not expand scope, add speculative structure, or refactor unrelated code
while using this skill.

## Activate when

- A plan or a single clear acceptance criterion exists and code must change
- The next step is one runnable increment
- The change is larger than a one-line edit but smaller than a full feature

## Do not activate when

- No plan or acceptance criterion exists yet -> use `oss-plan`
- The repository does not exist yet -> use `oss-bootstrap`
- A test or build is failing and the cause is unknown -> use `test-and-debug`
- The change only adds or upgrades a dependency -> use `dependency-review`

## Required inputs

- The acceptance criterion for this increment
- Access to the repository to inspect status, conventions, and diff
- The targeted validation command for the affected code

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
- That existing tests pass right now
- That an external API, wallet, or MCP tool is reachable
- That a dependency is already approved

## Preflight

1. `git status --short` and `git diff --stat` to see current work in progress
2. If unrelated uncommitted changes exist, stop and report before editing
3. Identify the affected files and the convention they already follow ->
   [references/change-types.md](references/change-types.md)
4. Identify any external input the change reads ->
   [references/external-boundaries.md](references/external-boundaries.md)

## Workflow

1. Restate the single acceptance criterion this increment satisfies
2. Inspect `git status` and `git diff` for in-progress work
3. Discover conventions from neighboring files and existing scripts
4. Identify the one runnable increment that satisfies the criterion
5. Before editing, state files to modify, files to create, any new dependency,
   and the targeted validation command
6. If a new dependency is required, stop and route to `dependency-review`
7. Implement only that increment, following existing conventions
8. Validate external input at the boundary once ->
   [references/external-boundaries.md](references/external-boundaries.md)
9. Run the targeted validation for the changed code only
10. If validation fails, repair only failures caused by this increment; an
    unrelated pre-existing failure is a stop-and-report condition
11. Inspect `git diff` and remove churn, stray edits, and obvious comments
12. Update docs only when public behavior changed
13. Produce the report using
    [templates/implementation-report.md](templates/implementation-report.md)
14. Stop after the increment

## Implementation rules

- Do not change unrelated files
- Do not silently rewrite entire modules
- Do not introduce an interface for a single implementation
- Do not introduce factories, repositories, providers, adapters, managers,
  registries, or service layers without a demonstrated current need
- Do not extract a helper used only once unless it materially improves clarity
- Do not create generic utilities for possible future use
- Do not add fallback behavior not required by the acceptance criterion
- Do not add defensive branches for impossible or unsupported states
- Do not add architecture for anticipated future requirements
- Prefer existing project conventions over introducing new ones
- Validate external data at system boundaries, not at every internal call
- Avoid unrelated formatting churn and broad renaming
- Preserve public APIs unless the task explicitly changes them
- Do not claim validation that was not run

## Comment policy

- Comments may explain a non-obvious constraint, trade-off, external behavior,
  security decision, or mathematical assumption
- Comments must not narrate the next line, a function name, a loop, a
  condition, an assignment, or obvious control flow
- Prefer clear names and small functions over explanatory comments
- Remove a stale comment only in code you directly modify, and only when safe

## Change-type branches

Route by the kind of change; each branch names its own discovery,
implementation boundary, validation, and stop condition ->
[references/change-types.md](references/change-types.md)

- New feature slice
- Bug fix
- Integration with an external system
- Refactoring in isolation
- UI change
- CLI change
- Configuration change
- Documentation-affecting behavior change

## Validation escalation

Run the smallest check that proves the increment:

```text
single test or command
related test file
changed-file lint or typecheck
related integration path
full suite only at the milestone that ends the work
```

Never run the full suite after every edit.

## Stop conditions

- The increment cannot be validated cheaply
- A pre-existing unrelated failure blocks the targeted validation
- The change requires a new dependency not yet reviewed
- The acceptance criterion is ambiguous after one clarification pass

## Human review boundaries

- Any change to auth, wallet, or user-data handling
- Any change to a public API surface
- Any validation that could only be run against an unavailable live system

## Final report

Produce the report in the exact section order of
[templates/implementation-report.md](templates/implementation-report.md), then
stop. Broader review happens under `public-code-review`.
