# External boundaries

Any value that enters from a source you do not control is untrusted. Validate
it once at the boundary, then trust it internally. Do not re-wrap every
internal call.

## Boundaries and what to validate

- MCP tool responses: validate schema and types; handle a tool error result;
  never assume a field is present
- HTTP API responses: check status before parsing; validate body shape and
  field types; treat missing or extra fields as untrusted
- Environment variables: presence and format; never log a secret; fail with a
  clear message when a required variable is absent
- Files: existence, encoding, and size expectations; do not assume a path is
  inside the project
- Database records: nullability and type; a stored value can violate a newer
  schema assumption
- Wallet and chain data: balances, addresses, and signatures are attacker
  influenced; validate format and never trust a client-supplied amount
- LLM or codegen structured output: parse defensively; validate against the
  expected schema before use
- User-entered data: validate at entry; reject or normalize, do not silently
  coerce into an unsafe form

## For each boundary the increment touches, record

- What crosses it
- What is validated versus trusted after validation
- The failure behavior when validation fails
- Whether a secret is involved

## Rules

- Validate at the boundary once; internal code trusts the validated value
- When a boundary system is offline, use a mock and mark the live path as
  unvalidated in the report
- Route auth, wallet, and user-data validation decisions to human review
- Never log tokens, sessions, keys, or signatures
