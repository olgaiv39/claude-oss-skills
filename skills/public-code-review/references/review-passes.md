# Review passes

Run each pass over the files under review. Record findings; do not fix them.

## Code quality

Look for:

- Unnecessary abstractions and layers introduced for a single caller
- Duplicated logic that should reuse an existing function
- Dead code and unused exports
- Oversized functions that hide separate responsibilities
- Excessive or obvious comments
- Unclear naming that obscures intent
- Unrelated changes mixed into the diff
- Speculative error handling for states that cannot occur
- Avoidable complexity where a direct form exists

## Public-repository safety

Look for:

- Secrets, credentials, tokens, API keys, private keys
- Wallet seed material or private key fragments
- Personal information or private email addresses
- Internal URLs, hostnames, or infrastructure identifiers
- Client, employer, or confidential project names
- Proprietary data or copied private code
- Generated artifacts, build output, or unexpected binaries
- Unsafe example configuration that implies real accounts

Any hit here is a blocking finding and a human-review item.

## Trustworthiness

Check that:

- README claims match implemented behavior
- Mock and demo data are clearly labelled as such
- Known limitations are visible, not hidden
- Benchmark or performance claims carry evidence
- Security claims are appropriately limited in scope
- The project does not call itself production-ready without justification
- Generated text does not fabricate tests, metrics, integrations, or
  compatibility that do not exist

## Maintainability

Check that:

- Setup is understandable from the README alone
- Structure is predictable for a new reader
- Errors are actionable, not silent or generic
- Dependencies are justified (route new ones to `dependency-review`)
- Changed code is testable
- Architecture is proportionate to the project's size
