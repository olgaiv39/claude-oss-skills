---
name: dependency-review
description: Evaluate whether to add a new runtime or development dependency to a public open-source project before adding it. Use whenever a new package is proposed. Weighs standard-library alternatives, cost, transitive impact, maintenance, license, supply-chain risk, and low-resource effect, then decides add, do not add, or defer. Does not install anything.
disable-model-invocation: true
---

# dependency-review

Decide whether to add a proposed dependency before it is added. Do not install
anything or modify project files while using this skill.

## Activate when

- A new runtime or development dependency is proposed
- An existing dependency upgrade would pull new transitive packages
- A failing build suggests adding a package to resolve it

## Do not activate when

- The package is already a project dependency and no version changes
- The task is a code change with no new dependency -> use `implement-minimal`
- The task is a failing test unrelated to dependencies -> use `test-and-debug`

## Required inputs

- The exact package name and, if known, the version or range
- The problem the dependency is meant to solve
- Whether it is a runtime or development dependency

## Low-resource policy

Read the first of these that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, apply this fallback: run one expensive command at a time,
prefer the narrowest validation, disable watch mode, reuse existing
environments, and run full validation only at a milestone boundary. Do not
scan the whole filesystem to locate the policy.

## Facts that must not be assumed

- The package manager and lockfile in use
- That the package is actively maintained
- That the license is compatible with public release
- The size of the transitive dependency tree

## Preflight

1. Identify the ecosystem and manifest ->
   [references/ecosystem-review.md](references/ecosystem-review.md)
2. Read the existing manifest to see current dependencies and conventions
3. Determine whether a current dependency or platform API already solves it

## Workflow

1. State the exact problem the dependency would solve
2. Check whether the standard library or platform API is sufficient
3. Check whether an existing project dependency already solves it
4. Estimate the local code avoided versus the code introduced
5. Assess the package per ecosystem signals ->
   [references/ecosystem-review.md](references/ecosystem-review.md)
6. Assess the low-resource impact ->
   [references/low-resource-impact.md](references/low-resource-impact.md)
7. Confirm license compatibility for public release
8. Weigh maintenance activity and supply-chain exposure
9. Reach exactly one decision
10. Produce the record using
    [templates/dependency-decision.md](templates/dependency-decision.md)
11. Stop; installation happens later under `implement-minimal` if approved

## Evaluation criteria

- The exact problem being solved
- Whether the standard library or platform API is sufficient
- Whether an existing project dependency already solves it
- Approximate amount of local code avoided
- Runtime cost
- Installation and build cost
- Transitive dependency impact ->
  [references/ecosystem-review.md](references/ecosystem-review.md)
- Maintenance activity and release recency
- License compatibility for public release
- Security and supply-chain exposure
- Effect on low-resource development ->
  [references/low-resource-impact.md](references/low-resource-impact.md)
- Effect on bundle or container size

## Rules

- Prefer platform APIs, existing dependencies, and small local functions
- Do not reimplement cryptography, wallet security, authentication protocols,
  or mature parsers merely to avoid a dependency
- Do not install the dependency as part of this review
- Do not modify project files as part of this review
- Do not run a command that downloads the package to inspect it

## Decision branches

- Standard library or an existing dependency suffices -> **do not add**
- The package is sound, licensed, and maintained, and it avoids substantial
  correct-by-construction code -> **add**
- Maintenance, license, or transitive impact is unclear ->
  **defer pending evidence** and name the evidence needed

## Stop conditions

- License compatibility cannot be confirmed
- The package or its transitive tree cannot be inspected without installing
- The decision requires human review (see below)

## Human review boundaries

- Any dependency touching cryptography, wallets, authentication, or key storage
- A copyleft or unclear license on a package intended for public release
- A package with an unknown or unverifiable maintainer or provenance

## Final report

Produce the record in the exact section order of
[templates/dependency-decision.md](templates/dependency-decision.md), ending
with exactly one decision: **add**, **do not add**, or
**defer pending evidence**. Then stop.
