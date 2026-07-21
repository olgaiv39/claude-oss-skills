# Debug report

Failing command:
- <the exact command and observed error>

Failure class:
- <assertion | exception | build | type/lint | flaky | environment | boundary | timeout>

Narrow reproduction:
- <the smallest command that triggers the failure>

Confirmed root cause:
- <cause, with the evidence that confirmed it>

Fix applied:
- <file> - <the smallest change made>

Validation performed:
- <narrow reproduction command> -> <passed>
- <related test file> -> <passed | not run>

Validation not performed:
- <check> -> <why, e.g. live system unavailable>

Documentation impact:
- <changed doc lines, or none>

Remaining risk:
- <flaky class, unvalidated live path, or none>

Files requiring human review:
- <path> -> <reason: auth | wallet | user data | public API | unvalidated live path>
