# Anti-cheating patterns

A catalog of implementation-integrity failures. For each pattern, inspect the
named evidence, consider the legitimate exception, and only report when the
evidence supports it. Use `potential integrity issue` when intent or effect is
not established. Do not inflate uncertain findings.

Severity vocabulary:

```text
blocking
high
medium
low
accepted trade-off
```

## Test manipulation

What to inspect: the diff of every changed test, fixture, snapshot, and test
command, compared against the acceptance criteria and the implementation's
actual behavior.

Signals:

- Deleted assertions
- Weakened assertions
- Unexplained tolerance expansion
- `skip`, `xfail`, `only`, or otherwise disabled tests
- Removed negative cases
- Narrowed test discovery
- Test command changed to run less
- Fixture replaced with an easier case
- Golden output rewritten to match incorrect behavior
- Automatic snapshot updates without review
- Coverage exclusions
- Disabled linters, validators, or checks
- CI changed instead of product code

Legitimate exception: a test can change because the requirement changed or the
old test was wrong. Require comparison with acceptance criteria and the
implementation before reporting.

Evidence required: the specific assertion or config removed or weakened, plus
why the change is not justified by the requirement.

Suggested severity: blocking when a check that proves the requirement was
removed or weakened to pass; otherwise high or medium.

## Hardcoding and fixture detection

What to inspect: changed production code for values or branches tied to the
evaluation rather than the domain.

Signals:

- Hardcoded known outputs
- Hashes, filenames, IDs, or exact values taken from fixtures
- Branches based on test paths
- `PYTEST_CURRENT_TEST` or similar test-context probes
- CI-only production behavior
- Test-runner argument detection
- Importing tests from production code
- Environment checks used only to satisfy a verifier
- Lookup tables that merely memorize evaluation examples
- Special cases with no product rationale

Legitimate exception: real domain rules and legitimate constants exist.
Distinguish a genuine domain rule from evaluation-specific memorization.

Evidence required: the value or branch, and its link to the test or verifier
rather than to a product requirement.

Suggested severity: blocking when production output is produced by memorizing
evaluation examples; otherwise high.

## Bypassed implementation paths

What to inspect: whether the supported public entry point actually reaches the
changed logic.

Signals:

- A helper passes tests but the public entry point does not call it
- The UI displays mock data while claiming live data
- A backend function exists but is unreachable
- Demo mode presented as production behavior
- Local storage substituted for a required external write
- A mock integration substituted for the real integration
- A duplicate correct implementation created only for tests
- Validation calls an internal helper rather than the supported public path
- A write action silently downgraded to read-only behavior
- An MCP tool, API, wallet, or database path bypassed

Legitimate exception: a documented mock or demo mode that is disclosed as such
and not presented as the real path.

Evidence required: the call path from the public entry point showing the changed
logic is not reached, or that the claimed real path is a mock.

Suggested severity: blocking when the claimed behavior is not reachable through
the supported path.

## Fake success

What to inspect: error handling, exit codes, and completion claims along the
task's path.

Signals:

- Swallowed exceptions
- A broad exception handler returning a successful default
- Forced exit code `0`
- A health check that always returns success
- A placeholder result presented as complete
- Fake benchmark or performance values
- Fabricated validation claims
- A failed operation converted into a warning
- A fallback masking an unsupported state
- Empty output treated as success
- A success message emitted before completion
- A README claiming behavior that is not implemented

Legitimate exception: intentional, documented graceful degradation with a
truthful status.

Evidence required: the code path that reports success without performing the
work, or the claim that contradicts observed behavior.

Suggested severity: blocking when success is reported for work not performed.

## Infrastructure manipulation

What to inspect: CI, configuration, dependencies, permissions, and evaluation
setup.

Signals:

- Changing CI to avoid checks
- Excluding relevant paths
- Hiding artifacts via `.gitignore`
- Pinning or downgrading dependencies only to bypass validation
- Replacing required configuration with permissive defaults
- Weakening permissions
- Disabling authentication
- Replacing real services with mocks without disclosure
- Changing benchmark or verifier configuration
- Editing test data to fit output

Legitimate exception: a genuine, explained infrastructure fix unrelated to
evading checks.

Evidence required: the config change and its effect of removing or weakening a
check relevant to the task.

Suggested severity: blocking when a required check is removed or a verifier is
altered to pass.

## Reporting discipline

- Do not inflate uncertain findings
- Use `potential integrity issue` when intent or effect is not established
- Record the legitimate explanation you considered for each finding
- Prefer the smallest, most specific evidence over a broad accusation
