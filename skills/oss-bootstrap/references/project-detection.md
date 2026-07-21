# Project and repository detection

Detect stack and repository state from files that already exist. Do not guess
from directory names alone.

## Git state

- Inside a work tree: `git rev-parse --is-inside-work-tree` prints `true`
- Has commits: `git rev-parse HEAD` succeeds
- Current branch: `git branch --show-current`
- Configured remotes: `git remote -v`

Interpretation:

- Not a work tree -> Git init is a candidate step (only if requested)
- Work tree with no commits -> first commit is a candidate step
- Work tree with commits -> treat as existing project, do not re-init

## Emptiness

- List entries: `ls -A`
- Treat a directory with only `.git`, `LICENSE`, or a short README as nearly
  empty
- Treat a directory with source trees, manifests, or lockfiles as populated

## Stack signals

Match on concrete files:

- Python: `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements*.txt`,
  `*.py`
- Node or TypeScript: `package.json`, `tsconfig.json`, `pnpm-lock.yaml`,
  `yarn.lock`, `bun.lockb`, `package-lock.json`
- Rust: `Cargo.toml`, `Cargo.lock`, `src/main.rs`, `src/lib.rs`
- Documentation-only: only `*.md`, images, and no runnable source
- Claude Code skills repository: `skills/*/SKILL.md`, `shared/LOW_RESOURCE.md`,
  `hooks/*.sh`
- Mixed stack: two or more of the above manifest families present

If signals conflict, report the ambiguity and ask which stack is primary.

## Package manager resolution

- Node: presence of a specific lockfile selects the manager
  (`package-lock.json` npm, `pnpm-lock.yaml` pnpm, `yarn.lock` Yarn,
  `bun.lockb` Bun); if only `package.json` exists, ask
- Python: `uv.lock` uv, `poetry.lock` Poetry, `requirements.txt` pip; else ask
- Rust: Cargo

## Convention discovery

- Line endings and indent from existing files
- Existing `.editorconfig`, formatter, or linter config
- Existing test directory layout (`tests/`, `__tests__/`, `test/`, `src` with
  `#[cfg(test)]`)
- Existing scripts in `package.json`, `Makefile`, or `pyproject.toml`

Record what exists. Adopt existing conventions instead of imposing new ones.

## Risk pre-scan inputs

Collect candidate paths for the risk scan in the parent skill:

- Files larger than a few hundred KB (possible accidental binaries)
- `*.env`, `*.pem`, `*.key`, `id_rsa`, `credentials*`, `*.p12`
- Build output directories (`dist/`, `build/`, `target/`, `.next/`,
  `node_modules/`)
