# GitHub repository

Publish source to a GitHub repository. Every network or history-changing action
requires explicit intent for that specific action.

## Prerequisites

- The pre-release checklist passed
- The working tree is clean or the remaining changes are intended for this
  release
- A remote destination the user has confirmed

## Steps

1. Confirm the current branch and that it holds the intended commits
2. Confirm a remote: inspect `git remote -v`
3. If no remote exists, stop and confirm the exact remote URL with the user
   before adding it
4. Confirm the push is intended for this branch and remote
5. Only after explicit intent, push the confirmed branch to the confirmed
   remote
6. If a GitHub release or tag is wanted, confirm the version and that a tag is
   intended, then create it only on explicit request

## Validation

- `git status` shows the branch tracking the intended remote after push
- The pushed ref matches the local ref that was reviewed

## Explicit-intent gate

- Never add a remote, push, tag, or create a release without a direct request
  for that action
- Never force-push
- Never push to `main` or `master` without confirmation

## Common failures

- No commits on the branch: nothing to publish; stop and report
- Remote already exists and differs: stop; do not overwrite
- Authentication failure: report it; do not store or prompt for credentials
- Non-empty remote with divergent history: stop; do not force
