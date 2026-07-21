# Ecosystem review

Assess the package with the signals of its own ecosystem. Do not install it to
inspect it; use the manifest, the registry page, and the repository.

## Identify the manifest and lockfile

- JavaScript / TypeScript: `package.json` with `package-lock.json`,
  `pnpm-lock.yaml`, `yarn.lock`, or `bun.lockb`
- Python: `pyproject.toml`, `requirements.txt`, `poetry.lock`, `uv.lock`
- Rust: `Cargo.toml` with `Cargo.lock`

Match the project's existing manager; do not introduce a second one.

## Signals to read without installing

- Latest release date and release cadence
- Open-issue and maintenance activity
- Declared license in the manifest and the repository
- Number and weight of transitive dependencies
- Whether the package ships prebuilt binaries or native build steps
- Whether install runs post-install scripts

## Transitive impact

- A small direct package with a large transitive tree still carries the whole
  tree's license, maintenance, and supply-chain exposure
- Prefer a package with a shallow, well-maintained dependency graph
- A native or binary dependency raises install cost and platform risk

## License compatibility for public release

- Confirm the license permits public redistribution under the project's license
- Treat copyleft or unclear licenses as a human-review boundary
- Confirm any bundled asset inside the package is also compatibly licensed

## Supply-chain exposure

- Prefer packages with a verifiable maintainer and source repository
- Treat a recently republished or renamed package with caution
- Post-install scripts and network access during install are risk signals
