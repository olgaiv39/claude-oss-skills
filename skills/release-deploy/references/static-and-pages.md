# Static site or GitHub Pages

Deploy a statically built site. Build locally once, verify output, then publish
only on explicit intent.

## Prerequisites

- The pre-release checklist passed
- The static-site build command, discovered from the project scripts
- The intended publish method: a Pages workflow or a manual push of built
  output

## Steps

1. Discover the build command from `package.json` scripts or the generator
   config; do not assume one
2. Run the production build once
3. Verify the build output directory exists and contains the expected entry
   file (for example `index.html`)
4. Check that internal links and asset paths resolve for the intended base path
5. If publishing via a Pages workflow, confirm the workflow already exists;
   creating CI is out of scope here
6. If publishing by pushing built output, follow
   [github-repository.md](github-repository.md) with explicit intent

## Validation

- The build exits zero and produces the expected entry file
- No broken internal links in the built output
- The base path matches the intended hosting location

## Explicit-intent gate

- Never push built output or trigger a deploy without a direct request
- Never change the configured base path or custom domain without confirmation

## Common failures

- Wrong base path produces broken asset URLs on the host
- Build output committed to the source tree by accident; keep it ignored
- A generator step that downloads packages; treat as an expensive action
