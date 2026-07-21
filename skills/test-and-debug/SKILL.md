---
name: test-and-debug
description: Diagnose and repair a failing test, build, or runtime error in a public open-source project using the narrowest reproduction and validation. Use when something is broken and the cause is not yet known. Classifies the failure, isolates a reproduction, applies the smallest fix, and confirms with a targeted check. Does not add features.
disable-model-invocation: true
---

# test-and-debug

Diagnose a failure, isolate the narrowest reproduction, apply the smallest fix,
and confirm with a targeted check. Do not add features or refactor unrelated
code while using this skill.

## Activate when

- A test, build, typecheck, or runtime path is failing
- The cause of a failure is not yet known
- A previously passing check now fails

## Do not activate when

- The change is a new feature with no failure yet -> use `implement-minimal`
- No plan exists for a non-trivial change -> use `oss-plan`
- The failure is a dependency install or version conflict only ->
  use `dependency-review`

## Required inputs

- The failing command or the observed error
- Access to the repository to reproduce and inspect
- Whether the failure is new or pre-existing, if known

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
- That the failure is deterministic
- That the failure is caused by the most recent change
- That an external system the code calls is currently reachable

## Preflight

1. `git status --short` and `git diff --stat` to see uncommitted work
2. `git log --oneline -5` to see recent changes that may correlate
3. Discover the project's test and build commands ->
   [references/test-discovery.md](references/test-discovery.md)
4. Capture the exact failing command and its output

## Workflow

1. Reproduce the failure with the narrowest command that triggers it ->
   [references/test-discovery.md](references/test-discovery.md)
2. Classify the failure ->
   [references/failure-classification.md](references/failure-classification.md)
3. Isolate: reduce to the single test, input, or code path that fails
4. Form one hypothesis about the cause and the smallest evidence to confirm it
5. Confirm the cause before editing; do not fix by guessing
6. Apply the smallest fix for that cause ->
   [references/recovery-recipes.md](references/recovery-recipes.md)
7. Re-run the narrow reproduction; confirm it passes
8. Run the related test file to check for a regression in the same area
9. If the fix changed public behavior, note the documentation impact
10. Inspect `git diff` and remove debugging scaffolding and stray edits
11. Produce the report using
    [templates/debug-report.md](templates/debug-report.md)
12. Stop after the fix is confirmed

## Failure classification

Classify before fixing; the class determines the recovery ->
[references/failure-classification.md](references/failure-classification.md)

- Assertion failure (wrong result)
- Error or exception (crash)
- Build or compile failure
- Type or lint failure
- Flaky or nondeterministic failure
- Environment or dependency failure
- External-system or boundary failure
- Timeout or resource-exhaustion failure

## Recovery actions

Match the recovery to the class; apply the smallest one that resolves the
confirmed cause ->
[references/recovery-recipes.md](references/recovery-recipes.md)

## Validation escalation

```text
narrow reproduction command
single failing test
related test file
changed-file lint or typecheck
full suite only at the milestone that ends the work
```

Do not run the full suite to find which test fails; find it with the narrow
command first.

## Stop conditions

- The failure cannot be reproduced locally after one focused attempt
- The failure depends on an unavailable external system with no mock
- The fix would require changing a public API or auth path without approval
- The root cause remains unconfirmed after one hypothesis-and-evidence pass

## Human review boundaries

- A fix that touches auth, wallet, or user-data handling
- A fix that changes a public API surface
- A fix that can only be validated against an unavailable live system

## Final report

Produce the report in the exact section order of
[templates/debug-report.md](templates/debug-report.md), then stop.
