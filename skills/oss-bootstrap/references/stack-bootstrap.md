# Stack-specific bootstrap

Add the smallest publishable structure for the detected stack. Do not generate
a full framework, sample application, or CI pipeline. Create only missing
files. Every command below is conditional on the detected stack.

## Shared minimum

For any stack, a publishable repository needs:

- `README.md` with purpose, install, one runnable example, limitations
- `LICENSE` (confirm choice with the user)
- `.gitignore` covering the stack's build output and secret files
- One runnable or checkable path (test, example, or `--help`)

If any of these already exists, keep it and record it as preserved.

## Python

- Keep an existing `pyproject.toml`; if none exists and the user wants a
  package, add a minimal `[project]` table with name, version, and
  description only
- `.gitignore`: `__pycache__/`, `*.pyc`, `.venv/`, `dist/`, `build/`,
  `*.egg-info/`, `.pytest_cache/`
- Minimal validation: one `pytest` node if tests exist, else `python -c
  "import module"` or `python script.py --help`

## JavaScript or TypeScript

- Keep an existing `package.json`; if none exists and code is present, add a
  minimal manifest with `name`, `version`, `description`, and a `test` or
  `start` script that matches reality
- `.gitignore`: `node_modules/`, `dist/`, `build/`, `.next/`, `coverage/`,
  `*.log`, `.env`
- Minimal validation: the project's own test script on one file, or `node
  entry.js --help`

## Rust

- Keep an existing `Cargo.toml`; if none exists, `cargo init` is a candidate
  only when the user requests a package and Cargo is installed
- `.gitignore`: `/target`
- Minimal validation: `cargo check`, or one named test if tests exist

## Mixed stack

- Do not unify tooling
- Record each component's manager and validation path separately
- `.gitignore` unions the per-stack entries above

## Documentation-only

- `.gitignore`: editor and OS artifacts only
- Minimal validation: a Markdown link check is optional; at minimum confirm
  referenced files exist

## Claude Code skills repository

- Structure: `skills/<name>/SKILL.md`, optional `references/` and
  `templates/`, `shared/`, optional `hooks/`
- Each `SKILL.md` needs valid frontmatter and a precise description
- Minimal validation: confirm frontmatter parses and relative reference links
  resolve; if hooks are present, `sh -n` each hook script
