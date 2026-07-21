---
name: public-code-review
description: Review the current diff or a specified set of files as public open-source code before publishing or merging. Use to check code quality, public-repository safety (secrets and private data), documentation trustworthiness, provenance, onboarding, and maintainability. Reports grouped findings; does not fix them unless asked.
disable-model-invocation: true
---

# public-code-review

Review the current diff, or a clearly specified set of files, as public
open-source code. Report findings; do not fix anything unless the user
explicitly asks.

## Activate when

- Code is about to be published or merged to a public repository
- A diff needs a safety and quality pass before release
- An external contribution needs review before acceptance

## Do not activate when

- A test or build is failing and needs a fix -> use `test-and-debug`
- The change has not been implemented yet -> use `implement-minimal`
- The task is packaging and shipping a release -> use `release-deploy`

## Required inputs

- The diff to review, or an explicit list of files
- Whether the target repository is already public
- The project's stated license

## Low-resource policy

Read the first of these that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, apply this fallback: run one expensive command at a time,
prefer the narrowest validation, disable watch mode, reuse existing
environments, and run full validation only at a milestone boundary. Do not
scan the whole filesystem to locate the policy.

## Context-efficiency policy

Read the first of these that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/CONTEXT_EFFICIENCY.md`
- `$HOME/.claude/shared/CONTEXT_EFFICIENCY.md`

If neither exists, apply this fallback: select files before reading; use
targeted searches and bounded ranges; do not preload references; do not reread
unchanged files; finish one atomic increment and stop; create a compact handoff
before context is exhausted.

## Facts that must not be assumed

- That the diff is the whole change; confirm the scope under review
- That secrets scanning tooling is installed
- That README claims match current behavior
- That copied code is licensed for redistribution

## Preflight

1. `git status --short` and `git diff --stat` to bound the review scope
2. Confirm whether the review is the working diff, a staged diff, or a file list
3. Read the license so compatibility findings are accurate

## Workflow

1. Establish the exact set of files and hunks under review
2. Run the review passes in order ->
   [references/review-passes.md](references/review-passes.md)
3. Run the privacy and provenance pass ->
   [references/privacy-provenance.md](references/privacy-provenance.md)
4. Run the onboarding pass ->
   [references/onboarding-review.md](references/onboarding-review.md)
5. Classify each finding into one output group
6. Produce the report using
   [templates/public-review-report.md](templates/public-review-report.md)
7. Stop; do not apply fixes unless the user asks

## Review passes

Run these passes; each names what to look for ->
[references/review-passes.md](references/review-passes.md)

- Code quality
- Public-repository safety (secrets and private data)
- Trustworthiness of documentation and claims
- Maintainability
- Privacy and provenance ->
  [references/privacy-provenance.md](references/privacy-provenance.md)
- Onboarding ->
  [references/onboarding-review.md](references/onboarding-review.md)

## Decision branches

- A secret, key, or private datum is present -> **blocking**, and flag it for
  immediate rotation in human review
- A README claim contradicts behavior -> **blocking** until reconciled
- Copied code lacks a compatible license or attribution -> **blocking**
- A quality issue does not affect safety or correctness ->
  **recommended cleanup**
- A deliberate, explained compromise -> **acceptable trade-off**

## Stop conditions

- The scope under review cannot be established
- The review would require running an unavailable external system
- A finding needs a human decision the reviewer cannot make (see below)

## Human review boundaries

- Any detected secret, key, or private datum, regardless of apparent validity
- Auth, wallet, or user-data handling changes
- License or provenance questions on copied or bundled material

## Final report

Produce the report in the exact section order of
[templates/public-review-report.md](templates/public-review-report.md), with
findings grouped as **Blocking issues**, **Recommended cleanup**,
**Acceptable trade-offs**, and **Files requiring human review**. Do not fix
anything unless the user explicitly asks.
