# Python service

Prepare a Python service for deployment. Verify it installs and starts; deploy
only on explicit intent through the project's documented method.

## Prerequisites

- The pre-release checklist passed
- The dependency manager in use (pip, uv, or Poetry), from the manifest and
  lockfile
- The application entry point (ASGI/WSGI app or CLI daemon)
- The documented deployment method for this service

## Steps

1. Confirm the dependency manager from the manifest and lockfile; use only that
   one
2. Create or reuse a virtual environment; do not install into the system
   interpreter
3. Install pinned dependencies with the project's manager
4. Start the service locally and confirm it serves its documented endpoint or
   runs its documented command
5. Confirm required environment variables are documented and not present as
   real values in the tree
6. Deploy only through the documented method and only on explicit intent

## Validation

- Dependencies install from the pinned set without error
- The app imports and starts
- No secret is committed; `.env` is ignored

## Explicit-intent gate

- Never deploy without a direct request
- Never write production secrets into the repository
- Never install into the global interpreter for a project task

## Common failures

- A manifest and lockfile that disagree on versions
- An entry point that imports a missing optional dependency at start
- Undocumented env vars so a clean environment fails to boot
