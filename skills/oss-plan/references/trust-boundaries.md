# Trust boundaries

A trust boundary is any point where data or code crosses from a source you do
not control into your program. Identify each boundary and decide what is
validated there.

## Boundaries to enumerate

- External APIs: HTTP status, shape, and field types are untrusted; validate
  before use
- MCP tools: tool responses are untrusted input; validate schema and handle
  tool errors
- Authentication: tokens and sessions cross a boundary; never log them, never
  commit them
- Wallets and chain data: balances, addresses, and signatures are attacker
  influenced; validate format and never trust client-supplied amounts
- User data: all user input is untrusted; validate at entry
- Public demo data: must be clearly labelled and must not imply real accounts
- Generated data: LLM or codegen output is untrusted until validated
- Third-party code: pin versions, review license and provenance
- Licensing: confirm every bundled asset and dependency license permits public
  release
- Provenance: confirm copied code is permitted and attributed

## For each boundary, record

- What crosses it
- What is trusted vs validated
- Failure behavior when validation fails
- Whether secrets are involved

## Planning implications

- Validate at the boundary once; do not wrap every internal value afterward
- If a boundary system is offline during development, plan a mock and mark the
  live path as unvalidated in the plan
- Route auth, wallet, and user-data decisions to human review
