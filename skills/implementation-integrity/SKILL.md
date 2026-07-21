---
name: implementation-integrity
description: Audit an implementation for unnecessary artifacts, test manipulation, hardcoded shortcuts, fake success, bypassed product paths, and unsupported completion claims
disable-model-invocation: true
---

# implementation-integrity

Audit whether an implementation honestly satisfies the requested task through
the real product path, with only necessary artifacts and evidence that
supports its completion claims. This is a read-only audit; do not repair,
delete, regenerate, commit, or deploy while using this skill.

Central question:

> Did the agent solve the requested task honestly through the real
> implementation path, with only necessary artifacts and evidence that supports
> its completion claims?

This skill does not replace `test-and-debug`, `public-code-review`, or
`release-deploy`. Intended sequence:

```text
implement-minimal -> test-and-debug -> implementation-integrity
-> public-code-review -> release-deploy
```

## When to use

- After implementation and targeted debugging are complete
- Before public review, release, deployment, benchmark submission, or hackathon
  submission
- For AI-generated code
- For benchmark and verifier-based tasks
- For MCP integrations
- For generated applications
- For test assignments and open-source contributions

## When not to use

- Before any implementation exists -> use `oss-plan` or `implement-minimal`
- As a general style review -> use `public-code-review`
- As a substitute for debugging a known failure -> use `test-and-debug`
- As permission to inspect unrelated private files
- As a guarantee that no hidden cheating exists; it audits the tested scope only

## Required inputs

Use, in order of preference:

1. Explicit task text and acceptance criteria supplied by the user
2. An approved execution plan
3. A supplied issue, specification, or benchmark prompt
4. A clearly identified commit or diff range

If acceptance criteria are unavailable, do not invent them. Provisional criteria
may be derived from explicit repository evidence, but must be labelled as
inferred. If there is no usable task definition or baseline, stop and request
the missing input.

## Baseline selection

Define the comparison baseline before reviewing. Support:

- Uncommitted work: compare the working tree and index against `HEAD`
- One commit: compare the specified commit against its parent
- Branch or PR work: compare against an explicitly supplied base branch or
  merge base
- Supplied diff range: use that exact range

Do not silently choose a remote branch or fetch from the network. Record the
selected baseline in the report.

## Low-resource policy

Read the first of these that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, continue with these built-in constraints: inspect changed
files before the wider repository, run one command at a time, use targeted
validation first, avoid watchers, avoid full builds and full suites unless
required at a milestone, bound large output, do not install tools, and do not
use subagents merely for speed.

## Preflight

1. Confirm the task and acceptance criteria
2. Select the baseline
3. Inspect `git status`
4. Inventory changed, added, deleted, renamed, untracked, permission-changed,
   and symlinked paths
5. Identify test, fixture, snapshot, CI, manifest, lockfile, `.gitignore`, and
   documentation changes
6. Identify the public entry point affected by the task
7. State which validation can be performed locally
8. Stop if the baseline or task definition is insufficient

## Audit phases

Run these phases in order:

```text
Phase 1 - scope and changed-file inventory
Phase 2 - artifact necessity audit
Phase 3 - test and validation integrity
Phase 4 - implementation-path integrity
Phase 5 - fake-success and bypass audit
Phase 6 - requirement-to-evidence mapping
Phase 7 - independent targeted validation
Phase 8 - verdict and human-review boundary
```

- Phase 2 uses
  [references/artifact-audit.md](references/artifact-audit.md)
- Phases 3 to 5 use
  [references/anti-cheating-patterns.md](references/anti-cheating-patterns.md)
- Phase 7 uses
  [references/independent-validation.md](references/independent-validation.md)

## Required outputs

Produce, using
[templates/integrity-report.md](templates/integrity-report.md):

- Baseline
- Task and acceptance criteria
- Changed-file inventory
- Artifact classification
- Integrity findings
- Potential cheating patterns
- Requirement-to-evidence mapping
- Independent validation performed
- Validation not performed
- Publication blockers
- Items requiring human judgment
- One exact verdict

## Exact verdicts

End with exactly one:

```text
integrity confirmed for tested scope
integrity partially confirmed
integrity not confirmed
blocking integrity issue found
```

Do not return `integrity confirmed for tested scope` unless all of the
following hold:

- At least one real public entry point was checked
- Changed tests and validation configuration were inspected
- Acceptance criteria were mapped to implementation evidence
- No blocking integrity issue was found

## Default behavior

This skill is a read-only audit. It must not automatically modify
implementation code, delete artifacts, update snapshots, rewrite tests, change
tolerances, alter CI, edit `.gitignore`, install dependencies, regenerate
outputs, commit, push, deploy, or publish. After the audit, perform any repair
separately with `implement-minimal`.

## Stop conditions

- No usable task definition or baseline
- The public entry point cannot be identified
- Required credentials or services are unavailable for validation
- Only a destructive validation path exists
- Evidence conflicts and cannot be resolved locally

Do not convert skipped validation into a pass.

## Human review boundaries

- A finding whose intent or effect cannot be established locally
- Any suspected manipulation of auth, wallet, or user-data handling
- A verdict that depends on validation that could not be run
- Whether an inferred acceptance criterion is acceptable

## Final report

Produce the report in the exact section order of
[templates/integrity-report.md](templates/integrity-report.md), ending with one
verdict. Then stop; repairs happen separately under `implement-minimal`.
