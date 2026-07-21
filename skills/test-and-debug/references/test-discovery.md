# Test discovery

Find the project's real test and build commands before running anything. Do not
assume a runner. Prefer an existing project script, an already-installed local
binary, or the documented command in the README. Do not run a command that may
download a missing package.

## Discovery inputs

- Existing scripts: `package.json` scripts, `Makefile`, `justfile`,
  `pyproject.toml`, `tox.ini`, `Cargo.toml`
- Existing test layout and file naming
- The documented test command in the README or CONTRIBUTING
- Configured formatter and linter (`.eslintrc`, `ruff.toml`, `rustfmt.toml`)

## Narrow reproduction by stack

Illustrative only; confirm the runner first, then select the narrowest target.

### JavaScript / TypeScript

    # single file through the project's own script
    npm test -- path/to/file.test.ts
    pnpm test path/to/file.test.ts
    # type check via the project's own typecheck script, or an already
    # installed local compiler; do not use npx, which may download a package
    npm run typecheck
    ./node_modules/.bin/tsc --noEmit

### Python

    # single test node
    pytest tests/test_module.py::test_case
    # single file, no cache
    pytest tests/test_module.py -p no:cacheprovider

### Rust

    # one test by name
    cargo test module::tests::case_name
    # one workspace package
    cargo test -p crate_name

## Ordering

- Reproduce with the narrowest command that still triggers the failure
- Escalate to the related test file only after the single case is understood
- Reserve the full suite and full build for the milestone that ends the work

## When discovery fails

- If no test command can be found, stop and report; do not invent one
- If the documented command downloads packages, note it as an expensive action
  and do not run it without explicit intent
