# Dependency decision

Package:
- <name and version or range>

Type:
- <runtime | development>

Problem it solves:
- <the exact problem>

Alternatives considered:
- Standard library or platform API: <sufficient | insufficient, why>
- Existing project dependency: <covers it | does not>
- Small local function: <feasible | not feasible, why>

Ecosystem assessment:
- Maintenance: <active | stale | unknown>
- License: <SPDX id> -> <compatible | incompatible | unclear>
- Transitive impact: <shallow | large | unknown>
- Supply-chain notes: <post-install scripts | native build | none>

Low-resource impact:
- Install and build cost: <cheap | expensive>
- Runtime and size cost: <negligible | notable>

Code avoided versus introduced:
- <estimate>

Decision:
- **add** | **do not add** | **defer pending evidence**

Evidence still required (if deferred):
- <what must be confirmed before deciding>

Human review required:
- <crypto | wallet | auth | copyleft license | unverifiable provenance | none>
