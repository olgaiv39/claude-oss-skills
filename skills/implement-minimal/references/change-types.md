# Change types

Route the increment by its kind. Each branch names what to discover, where the
implementation boundary is, the narrow validation, the common failure, and the
stop condition.

## New feature slice

- Discover: the acceptance criterion and the nearest existing feature to mirror
- Boundary: touch only the layers the observable behavior needs
- Validate: the single test or command that exercises the new behavior
- Common failure: the slice is horizontal and does not run on its own
- Stop: the behavior cannot be observed by one command or test

## Bug fix

- Discover: a failing case that reproduces the bug before any edit
- Boundary: change only the code path that produces the wrong result
- Validate: the reproducing test, now passing, plus the previously passing
  neighbor test
- Common failure: fixing a symptom while the cause remains
- Stop: the bug cannot be reproduced locally

## Integration with an external system

- Discover: the exact request, response shape, and error modes of the system ->
  [external-boundaries.md](external-boundaries.md)
- Boundary: validate the response at the boundary, then trust it internally
- Validate: a targeted test against a mock or recorded response
- Common failure: trusting response fields without validating shape
- Stop: the system is offline and no mock or recorded response exists

## Refactoring in isolation

- Discover: the behavior that must stay identical
- Boundary: no behavior change; structure only, in its own step
- Validate: the existing tests for the touched code, unchanged, still passing
- Common failure: mixing a refactor with a feature or fix in one step
- Stop: the refactor cannot be separated from feature work

## UI change

- Discover: the existing component pattern and state source
- Boundary: presentation and its direct state; do not rewire business logic
- Validate: the component test or a single render check
- Common failure: duplicating business logic into the view layer
- Stop: the change requires a new state architecture

## CLI change

- Discover: the existing argument parser and command layout
- Boundary: the one command or flag being added or changed
- Validate: invoke the command with `--help` and one representative argument set
- Common failure: breaking an existing flag or default
- Stop: the change alters a documented flag contract without approval

## Configuration change

- Discover: how config is currently loaded and defaulted
- Boundary: the one setting; keep existing defaults working
- Validate: load the config once with and without the new setting
- Common failure: making a previously optional setting required
- Stop: the change would break existing deployments' config

## Documentation-affecting behavior change

- Discover: which README or docs section describes the current behavior
- Boundary: change code first, then the matching doc lines only
- Validate: the behavior test, then a read-through of the changed doc lines
- Common failure: updating docs for behavior that did not actually change
- Stop: the behavior change is larger than one slice; return to `oss-plan`
