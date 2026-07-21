# Git first-publish sequences

Safe command sequences for the first commit and first push. Run each phase
only when the user has explicitly requested that phase. Inspect between
phases.

## Initialize (only if not already a work tree)

```sh
git rev-parse --is-inside-work-tree 2>/dev/null || git init
git symbolic-ref HEAD refs/heads/main   # name the initial branch
```

Confirm the working directory is the intended target before running `git
init`. Never init in a parent directory.

## Branch naming

- Prefer `main` for the default branch
- If commits already exist on another name, do not rename silently; report it

## Stage and inspect

```sh
git add -A
git status --short
git diff --cached --stat
```

Verify the exact file list. If a secret, binary, or generated path appears,
unstage it with `git restore --staged <path>` and fix `.gitignore` before
continuing.

## Executable mode check

```sh
git ls-files -s -- hooks scripts | grep -E '^100644' || true
```

Mode `100755` is executable, `100644` is not. If a script that must run lost
its bit, set it with `chmod +x <file>` and re-stage. Do not change modes on
files that are not meant to be executable.

## First commit (only when requested)

```sh
git commit -m "Initial commit"
```

If it reports `nothing to commit`, nothing was staged; return to staging.

## Add a remote (only when requested)

SSH:

```sh
git remote add origin git@github.com:<owner>/<repo>.git
```

HTTPS:

```sh
git remote add origin https://github.com/<owner>/<repo>.git
```

Confirm owner and repository name with the user first.

## First push (only when requested)

```sh
git push -u origin main
```

## Common errors

- `nothing to commit` -> nothing staged; run `git add` and re-inspect
- wrong branch name -> `git branch -m <old> main` before the first push
- `remote origin already exists` -> inspect `git remote -v`; use `git remote
  set-url origin <url>` instead of adding
- SSH authorization failure (`Permission denied (publickey)`) -> stop; the
  user must load an SSH key; do not switch to HTTPS silently
- non-empty remote (`Updates were rejected`) -> stop; do not force push;
  reconcile with `git pull --rebase` only after the user confirms the remote
  contents are expected
