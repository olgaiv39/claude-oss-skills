# Artifact audit

Determine whether each changed or generated artifact is necessary for the task.
Use narrow Git commands and changed-path inspection only. Do not scan the entire
filesystem.

## Inventory

Cover:

- Tracked changes
- Staged changes
- Untracked files
- Ignored files relevant to the task
- Renamed and deleted files
- Executable-mode changes
- Symlinks
- Manifests and lockfiles
- Tests and fixtures
- Snapshots and golden files
- CI and validation configuration
- `.gitignore`
- Documentation
- Binaries and large files

Suggested narrow commands (run one at a time, bound output):

```text
git status --short
git diff --stat <baseline>
git diff --name-status <baseline>
git diff --summary <baseline>
git ls-files --others --exclude-standard
```

## Suspicious artifacts

Watch for:

- `dist`
- `build`
- `coverage`
- Caches
- Logs
- Dumps
- Temporary files
- `.bak`, `.old`, `.orig`, `.rej`
- Archives
- Downloaded models or datasets
- Local environment files
- Duplicate configuration
- Generated documentation
- Placeholders
- Vendored dependencies
- Hidden scratch files
- Unexplained screenshots
- Large binaries
- Snapshots without meaningful review
- Generated files committed without source or a reproduction path

## Artifact classification

Classify every suspicious artifact as exactly one of:

```text
required source artifact
required test artifact
required documentation artifact
required release artifact
reproducible generated artifact
local-only artifact
unexplained artifact
publication blocker
```

## Necessity test

For each changed file, answer:

- Which requirement does it support?
- Is it used by the real implementation or validation path?
- Could the task be complete without it?
- Is it reproducible?
- Should it be committed?
- Does it expose private or generated material?

Record the answers in a table:

```text
Path | Change type | Claimed purpose | Requirement | Necessary | Evidence | Classification
```

## Judgment rules

- Do not classify a file as unnecessary only because it is generated; a
  generated file with a committed source and reproduction path can be required
- Do not accept an artifact only because the previous agent created it
- When necessity cannot be established from evidence, classify it as
  `unexplained artifact` and route it to human judgment rather than guessing
