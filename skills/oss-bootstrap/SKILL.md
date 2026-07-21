---
name: oss-bootstrap
description: Prepare a new public open-source repository, or convert a small existing directory into a clean publishable starting point. Use for an empty or nearly empty repo, a first local commit, or a first remote push. Do not use for routine feature work or releasing an established project. Never commits, creates a remote, or pushes unless explicitly requested.
disable-model-invocation: true
---

# oss-bootstrap

Prepare the smallest publishable repository from a new or nearly empty
directory. Inspect before writing. Never overwrite existing README, LICENSE,
or `.gitignore`, and never commit, add a remote, or push without an explicit
request.

## Activate when

- Starting a new open-source project
- The repository is empty or nearly empty
- Converting a private prototype into a clean public starting point
- Preparing the first local commit or first remote push

## Do not activate when

- Doing routine feature work in an established repository -> use `implement-minimal`
- Releasing or deploying an existing project -> use `release-deploy`
- Migrating a large repository or history
- Copying a proprietary codebase into public Git

## Required inputs

- Target directory (confirm before any write)
- Intended project type, if the user already knows it
- Whether this session may commit, add a remote, or push (default: no)
- Chosen license, if the user already has one

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

- Whether Git is already initialized
- The default branch name
- That the directory is empty
- The stack, package manager, or test runner
- That files with common names are safe to overwrite
- That a remote exists or is empty

## Preflight

1. Confirm the absolute target directory with the user
2. Run `git rev-parse --is-inside-work-tree` to detect an existing repo
3. List top-level entries without reading large binaries
4. If the directory already contains a substantial project, stop and hand off
   to `oss-plan` or `public-code-review`

## Workflow

1. Confirm the target directory
2. Detect Git state and existing files -> see
   [references/project-detection.md](references/project-detection.md)
3. Classify the project: Python, JavaScript or TypeScript, Rust, mixed stack,
   documentation-only, or a Claude Code skills repository
4. Identify existing manifests and conventions; do not replace them
5. Define the smallest publishable structure for that stack ->
   [references/stack-bootstrap.md](references/stack-bootstrap.md)
6. Scan for public-release risks: secrets, personal information, proprietary
   names, private URLs, accidental binaries, generated output
7. Select or confirm license, README, `.gitignore`, `.env.example` (only when
   secrets are required), and a minimal validation path
8. Create only missing files; never overwrite an existing README, LICENSE, or
   `.gitignore`
9. Preserve executable permissions on existing scripts
10. Prepare the staged diff and verify the exact file list ->
    [references/git-first-publish.md](references/git-first-publish.md)
11. Commit only when explicitly requested
12. Add a remote only when explicitly requested
13. Push only when explicitly requested
14. Produce the report ->
    [templates/bootstrap-report.md](templates/bootstrap-report.md)

## Decision branches

- Existing README, LICENSE, or `.gitignore` present -> keep it, record it as
  preserved, and note any gap instead of rewriting
- Secret or private data found -> stop, report the exact path and line, do not
  stage it, do not commit
- Binary or generated output found -> propose a `.gitignore` entry, do not add
  it to the commit
- No test or runnable path exists -> add the minimal validation described for
  the stack; do not scaffold a framework
- Git already initialized with commits -> do not re-initialize; treat as an
  existing project

## Validation escalation

Run the narrowest available check for the detected stack, in this order, only
as far as needed to prove the repo is runnable:

```text
syntax or parse check on created files
single smoke test or example run
stack lint or typecheck on changed files only
```

Do not run a full build or full suite during bootstrap.

## Stop conditions

- Target directory is ambiguous or unconfirmed
- A secret or private datum would be committed
- An existing README, LICENSE, or `.gitignore` would be overwritten
- Git would be initialized in the wrong directory
- The user has not authorized commit, remote, or push for those steps

## Human review boundaries

- Final license choice
- Whether the project name and contents are cleared for public release
- Remote URL and account ownership
- Any file the risk scan flagged as uncertain

## Final report

Fill in [templates/bootstrap-report.md](templates/bootstrap-report.md) with
detected type, created files, preserved files, skipped files, validation
performed, unresolved public-release risks, Git operations performed, Git
operations not performed, and the next manual action.
