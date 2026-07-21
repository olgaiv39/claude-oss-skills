# Recovery recipes

Apply the smallest recovery that resolves the confirmed cause. Confirm the
cause with evidence before editing. Match the recipe to the class from
[failure-classification.md](failure-classification.md).

## Assertion failure

- Confirm which side is wrong: the code or the expectation
- Fix the code when the expectation encodes the correct requirement
- Change the test only when the requirement itself changed, and say so
- Re-run the single test, then the related file

## Error or exception

- Trace to the first project frame in the stack
- Fix the cause at that frame; do not wrap the call in a broad catch
- Add boundary validation only if the input crossed a trust boundary
- Re-run the single case

## Build or compile failure

- Resolve the first reported error only, then recompile
- Do not batch-edit later errors before confirming they persist

## Type or lint failure

- Resolve the violation in the code; do not disable the rule
- If a rule is genuinely wrong for the project, route that decision to review

## Flaky or nondeterministic failure

- Remove the source of nondeterminism: order dependence, shared state,
  real time, or unseeded randomness
- Do not paper over a race with a sleep or a retry loop
- Re-run the isolated test several times to confirm stability

## Environment or dependency failure

- For a missing env var, provide a clear failure message at the boundary
- For a version mismatch or missing package, stop and route to
  `dependency-review`; do not install silently

## External-system or boundary failure

- Reproduce against a mock or recorded response
- Validate the response shape at the boundary; handle the error result
- Mark the live path as unvalidated when the system is offline

## Timeout or resource-exhaustion failure

- Find the blocking call or unbounded growth; fix the cause
- Bound the work or the input; do not merely raise the timeout

## After any recovery

- Remove debugging prints, temporary logs, and scaffolding
- Re-run the narrow reproduction, then the related test file
- Record any documentation impact if public behavior changed
