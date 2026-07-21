# Failure classification

Classify the failure before attempting a fix. The class determines the
reproduction, the evidence needed, and the recovery.

## Assertion failure (wrong result)

- Signal: the code runs but produces the wrong value
- Reproduce: the single asserting test
- Evidence: expected versus actual value at the assertion
- Danger: fixing the test to match wrong output instead of fixing the code

## Error or exception (crash)

- Signal: an unhandled exception or non-zero exit
- Reproduce: the single failing case
- Evidence: the stack trace and the first frame inside project code
- Danger: catching and swallowing the error instead of fixing the cause

## Build or compile failure

- Signal: the build or compiler stops before tests run
- Reproduce: compile only the affected module or file where supported
- Evidence: the first compiler error, not the cascade after it
- Danger: chasing later errors that disappear once the first is fixed

## Type or lint failure

- Signal: typecheck or linter reports a violation
- Reproduce: run the checker on the changed file only
- Evidence: the rule name and the exact line
- Danger: disabling the rule instead of resolving the violation

## Flaky or nondeterministic failure

- Signal: passes and fails without code change
- Reproduce: run the single test several times in isolation
- Evidence: whether it depends on order, time, randomness, or shared state
- Danger: adding a sleep or retry that hides a real race

## Environment or dependency failure

- Signal: fails due to a missing tool, version mismatch, or absent env var
- Reproduce: inspect the environment, not the code
- Evidence: the missing name and the expected version or value
- Danger: installing or upgrading without routing to `dependency-review`

## External-system or boundary failure

- Signal: fails on an HTTP call, MCP tool, wallet, or database access
- Reproduce: isolate the boundary call, prefer a mock or recorded response
- Evidence: status, response shape, or connection error at the boundary
- Danger: assuming the remote system is correct and the local code is wrong,
  or the reverse, without evidence

## Timeout or resource-exhaustion failure

- Signal: the run hangs, times out, or exhausts memory
- Reproduce: the narrowest case, with a bounded timeout
- Evidence: where it blocks; whether input size drives it
- Danger: raising the timeout instead of finding the blocking cause
