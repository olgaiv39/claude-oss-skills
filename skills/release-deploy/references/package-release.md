# Package registry release

Publish a package to npm, PyPI, or crates. Publishing is irreversible for a
given version; require explicit intent and confirm the version first.

## Prerequisites

- The pre-release checklist passed
- The registry and the exact version to publish, confirmed with the user
- Registry credentials present in the environment, not to be created or stored
- A clean build from source

## Steps by ecosystem

Confirm the ecosystem, then follow only its path.

### npm

1. Confirm `name`, `version`, and `files`/`.npmignore` in `package.json`
2. Confirm the package includes only intended files (inspect the pack list)
3. Build once if a build step exists
4. Publish only on explicit intent, with the confirmed version

### PyPI

1. Confirm `name` and `version` in `pyproject.toml`
2. Build the distribution artifacts once
3. Confirm the built artifacts contain only intended files
4. Upload only on explicit intent, to the confirmed index

### crates

1. Confirm `name` and `version` in `Cargo.toml`
2. Verify the package builds and packages cleanly
3. Publish only on explicit intent, with the confirmed version

## Validation

- The build and package step exits zero
- The package contents include only intended files, no secrets or local env
- The version has not already been published

## Explicit-intent gate

- Never publish without a direct request naming the version
- Never bump or pick a version number without confirmation
- Never publish over an existing version or yank without a direct request

## Common failures

- A packaging include list that ships local env files or build caches
- A version already present on the registry
- Missing registry credentials; report it, do not store or prompt to persist
