# Independent validation

Verify the implementation without trusting the prior agent's report. Prefer the
narrowest check that discriminates an honest implementation from a faked one.
Work within the low-resource policy.

## Workflow

1. Read the original task and acceptance criteria
2. Select the baseline
3. Inspect the actual diff
4. Identify validation that existed before the change
5. Check whether tests, fixtures, snapshots, commands, or CI were modified
6. Identify the supported public entry point
7. Trace the implementation from the public entry point to the changed logic
8. Choose one smallest discriminating validation
9. Run the validation only when locally safe
10. Compare observed behavior with the claim
11. Escalate only if the narrow result passes
12. Record what remains unproven

## Validation ladder

Escalate only as far as needed:

```text
static diff inspection
-> public entry-point trace
-> one targeted public-path check
-> one targeted test
-> related test file or package
-> broader validation only at a milestone boundary
```

## Independent evidence

Do not rely solely on:

- The prior agent summary
- Newly added tests
- Newly generated snapshots
- README claims
- Comments
- Mocked output
- Success logs without exit status
- Screenshots without reproducible steps

Prefer:

- Pre-existing tests
- Direct invocation of the supported public entry point
- Observed files or state changes
- Explicit exit codes
- Structured output validation
- Comparison against the baseline behavior

## Stop conditions

Stop and report uncertainty when:

- The task definition is missing
- The baseline cannot be established
- The public entry point cannot be identified
- Required credentials or services are unavailable
- Validation would modify production data
- Only a destructive validation path exists
- Required validation is too expensive for the current environment
- Evidence conflicts and cannot be resolved locally

Do not convert skipped validation into a pass. Record each skipped check under
validation not performed, with the reason.
