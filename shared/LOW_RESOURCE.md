# Low-Resource Execution Policy

Assume the development machine has limited CPU, RAM, disk space, battery,
and thermal headroom. Optimize every action to avoid wasted computation.

## Core rules

- Run at most one expensive command at a time.
- Prefer targeted tests before full suites.
- Use one test worker where the runner supports it.
- Disable watch mode.
- Avoid broad repository scans; search specific directories and file types.
- Read large files and logs in bounded chunks, not all at once.
- Do not start all Docker Compose services when one service is sufficient.
- Do not rebuild Docker images for unrelated changes.
- Do not run a development server and a production build at the same time.
- Do not run several package managers or compilers in parallel.
- Reuse existing environments and caches.
- Do not install optional tooling without explicit need.
- Stop processes started only for validation.
- Save full logs to a temporary file and return only useful failure context.
- Run full validation only at milestone boundaries.
- Do not use subagents or agent teams merely for speed.

## Targeted validation examples

These are illustrative, not guarantees. Do not assume a project uses a
specific runner. Inspect the project first, then prefer an existing project
script, an already-installed local binary, or the repository's documented test
command, and select the narrowest supported target. Do not run commands that
may download a missing package.

### JavaScript / TypeScript

    # use the project's own test script with a single file
    npm test -- path/to/file.test.ts
    pnpm test path/to/file.test.ts

### Python

    # single test node
    pytest tests/test_module.py::test_case

    # single file
    pytest tests/test_module.py -p no:cacheprovider

### Rust

    # one test by name
    cargo test module::tests::case_name

    # one package in a workspace
    cargo test -p crate_name

## Milestone boundaries

Full suites, full builds, and full lint runs belong at milestone boundaries
(feature completion, release, or submission), not after every small edit.
