---
name: release-deploy
description: Prepare a public open-source project for release and deploy it to a detected target. Use at a release or submission boundary to verify setup, docs, secrets, tests, lint, build, and licenses, then follow the target-specific deployment path. Runs expensive checks sequentially. Never publishes, tags, commits, pushes, or deploys without explicit user intent.
disable-model-invocation: true
---

# release-deploy

Prepare a project for release, then deploy it to the target the project
actually uses. Run the pre-release checks first. Never commit, tag, push,
publish, or deploy without explicit user intent for that specific action.

## Activate when

- The project is at a release or submission boundary
- A verified build needs to be shipped to a deployment target
- A package needs to be published to a registry

## Do not activate when

- Code is still being written or fixed -> use `implement-minimal` or
  `test-and-debug`
- The change only needs a review, not a release -> use `public-code-review`
- The repository does not exist yet -> use `oss-bootstrap`

## Required inputs

- Confirmation that this is a release boundary
- The intended deployment target, if known
- Explicit intent for any commit, tag, push, publish, or deploy action

## Low-resource policy

Read the first of these that exists, then follow it. Full validation runs only
at this boundary:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, apply this fallback: run one expensive command at a time,
prefer the narrowest validation first, disable watch mode, reuse existing
environments, and run full validation only at this milestone. Do not scan the
whole filesystem to locate the policy.

## Context-efficiency policy

Read the first of these that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/CONTEXT_EFFICIENCY.md`
- `$HOME/.claude/shared/CONTEXT_EFFICIENCY.md`

If neither exists, apply this fallback: select files before reading; use
targeted searches and bounded ranges; do not preload references; do not reread
unchanged files; finish one atomic increment and stop; create a compact handoff
before context is exhausted.

## Facts that must not be assumed

- The deployment target; detect it, do not guess
- The build, test, and publish commands
- That credentials for a target are present and valid
- That the user wants any push, publish, or deploy performed now

## Preflight

1. `git status --short` and `git log --oneline -5` for current state
2. Confirm the working tree is clean, or report what is uncommitted
3. Detect the deployment target ->
   [references/target-detection.md](references/target-detection.md)
4. Read the low-resource policy; plan expensive checks sequentially

## Workflow

1. Run the pre-release checklist and record each item's result ->
   [templates/deployment-checklist.md](templates/deployment-checklist.md)
2. Run expensive checks one at a time: full tests, lint, typecheck, build
3. If any blocking check fails, stop and report; do not deploy
4. Detect the deployment target ->
   [references/target-detection.md](references/target-detection.md)
5. Follow the target-specific reference for its steps and gates
6. For every commit, tag, push, publish, or deploy, require explicit intent
   for that action before running it
7. Record what was performed and what was intentionally not performed
8. Produce the report using
   [templates/release-report.md](templates/release-report.md)
9. Stop

## Pre-release checklist

Verify where applicable; record each as passed, failed, skipped, or requires
human review ->
[templates/deployment-checklist.md](templates/deployment-checklist.md)

- Clean-clone setup instructions
- README accuracy
- LICENSE present and correct
- `.gitignore` covers generated and secret files
- `.env.example` present and free of real secrets
- No secret exposure
- No personal or proprietary data exposure
- Targeted tests for changed areas
- Full test suite
- Lint
- Type checking
- Production build
- Demo or mock mode behaves as documented
- No broken documentation links
- Dependency licenses compatible and attribution complete
- Known limitations documented
- No unsupported production claims
- No accidental generated files or binaries

## Deployment targets

Detect the target, then follow its reference. Each reference states its
prerequisites, steps, validation, and the explicit-intent gate before any
irreversible action.

- GitHub repository ->
  [references/github-repository.md](references/github-repository.md)
- Static site or GitHub Pages ->
  [references/static-and-pages.md](references/static-and-pages.md)
- Docker image or container ->
  [references/docker.md](references/docker.md)
- Node service ->
  [references/node-service.md](references/node-service.md)
- Python service ->
  [references/python-service.md](references/python-service.md)
- Archestra app ->
  [references/archestra-app.md](references/archestra-app.md)
- MCP server ->
  [references/mcp-server.md](references/mcp-server.md)
- Package registry (npm, PyPI, crates) ->
  [references/package-release.md](references/package-release.md)

## Low-resource execution

- Run expensive checks sequentially, never in parallel
- Begin with targeted checks, then the full suite once
- Never run watchers or duplicate builds
- Never start unrelated services
- Record checks that could not be run; do not treat a skip as a pass

## Decision branches

- The target cannot be detected -> stop and ask; do not guess a target
- A blocking check fails -> stop and report; do not deploy
- Credentials for the target are absent -> stop; do not prompt for or store them
- The user has not confirmed intent for a push, publish, or deploy -> prepare
  the action and stop before executing it

## Stop conditions

- Any blocking pre-release check fails
- The deployment target requires credentials that are not present
- The user has not given explicit intent for the irreversible action
- The target cannot be determined from the repository

## Human review boundaries

- Any publish, tag, push, or deploy to a public destination
- Any action using deployment or registry credentials
- Any change to production configuration or DNS
- Version-number selection for a release

## Final report

Produce the report in the exact section order of
[templates/release-report.md](templates/release-report.md), listing checks as
passed, failed, skipped, or requires human review, and clearly separating
actions performed from actions intentionally not performed. Then stop.
