# Node service

Prepare a Node service for deployment. Verify it builds and starts; deploy only
on explicit intent through the project's documented method.

## Prerequisites

- The pre-release checklist passed
- The package manager in use (npm, pnpm, Yarn, or Bun), from the lockfile
- The build and start scripts, from `package.json`
- The documented deployment method for this service

## Steps

1. Confirm the package manager from the lockfile; use only that one
2. Install with the frozen-lockfile form of that manager if a clean install is
   required for the build
3. Run the build script once if the service has a build step
4. Start the service locally and confirm it serves its documented endpoint
5. Confirm required environment variables are documented in `.env.example` and
   absent from the tree as real values
6. Deploy only through the documented method and only on explicit intent

## Validation

- The build exits zero
- The service starts and answers a health or documented route
- No secret is committed; `.env` is ignored

## Explicit-intent gate

- Never deploy to a hosting provider without a direct request
- Never write production environment values into the repository
- Never run a dev server and a production build at the same time

## Common failures

- Mixed package managers producing an inconsistent lockfile
- A missing build step so the start script serves stale output
- Required env vars undocumented, so a clean deploy fails to boot
