# Target detection

Detect the deployment target from the repository. Do not guess. If more than
one signal matches, report the candidates and confirm before proceeding.

## Signals

- GitHub repository publish: no remote yet, or a `.git` with no public origin,
  and the goal is to publish the source ->
  [github-repository.md](github-repository.md)
- Static site or Pages: a static build output (`dist/`, `build/`, `public/`,
  `_site/`), a static-site generator config, or an existing
  `.github/workflows` Pages job -> [static-and-pages.md](static-and-pages.md)
- Docker: a `Dockerfile` or `compose.yaml`/`docker-compose.yml` ->
  [docker.md](docker.md)
- Node service: `package.json` with a `start` script and a server entry point,
  no static-only output -> [node-service.md](node-service.md)
- Python service: `pyproject.toml` or `requirements.txt` with a server entry
  (ASGI/WSGI app, CLI daemon) -> [python-service.md](python-service.md)
- Archestra app: an Archestra app manifest or the project's documented
  Archestra packaging -> [archestra-app.md](archestra-app.md)
- MCP server: an MCP server manifest, an `mcp` entry, or a server that speaks
  the Model Context Protocol -> [mcp-server.md](mcp-server.md)
- Package release: a publishable manifest intended for a registry
  (`package.json` with a name for npm, `pyproject.toml` for PyPI, `Cargo.toml`
  for crates) -> [package-release.md](package-release.md)

## Resolution rules

- Prefer an explicitly documented deployment method in the README over an
  inferred one
- A repository can have several valid targets (for example a package that also
  ships a Docker image); confirm which one this release is for
- If no signal matches, stop and ask; do not invent a target

## What not to assume

- That a `Dockerfile` means the release goes to a container registry now
- That a `package.json` name means the user wants to publish to npm now
- That credentials for any target are present
