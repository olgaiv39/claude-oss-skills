# Execution planning

Plan work as a sequence of runnable states, not a pile of edits.

## Vertical slicing

A vertical slice touches every layer needed for one observable behavior:
input, logic, output, and a way to verify it. Prefer one thin slice that runs
end to end over several horizontal layers that do not run on their own.

Test: after the slice, can a user or a single command observe the new
behavior. If not, the slice is too horizontal.

## Dependency ordering

- Order steps so each step compiles and runs before the next begins
- Put shared types or contracts first only when a later step cannot exist
  without them
- Defer anything not required by the current slice
- If step B needs step A's output, sequence A then B; never interleave
  half-finished layers

## Milestone boundaries

A milestone is a point where full validation is justified: slice complete,
feature complete, or release. Between milestones, validate narrowly. Schedule
expensive actions (full suite, full build, container build) only at
milestones.

## Maintaining runnable states

- After each step the project builds and the narrow check passes
- Do not leave the tree in a state where the only proof of correctness is a
  full-suite run
- If a refactor is required, isolate it as its own step with its own narrow
  validation, separate from feature work

## Estimating local cost

Mark each planned action as cheap or expensive:

- Cheap: single test, single file typecheck, `--help`, one module import
- Expensive: full suite, full build, container build, install, dev server

Keep expensive actions rare and batched at milestones.

## Convention discovery inputs

- Existing scripts (`package.json`, `Makefile`, `pyproject.toml`, `justfile`)
- Existing test layout and naming
- Existing formatter and linter config
- The documented test command in the README
