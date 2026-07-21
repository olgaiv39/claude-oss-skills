# Release report

Release boundary:
- <feature release | submission | package version X.Y.Z>

Pre-release checks:
- Passed: <list>
- Failed: <list, or none>
- Skipped: <list with reason, or none>
- Requires human review: <list, or none>

Deployment target:
- <GitHub repo | static/Pages | Docker | Node service | Python service | Archestra app | MCP server | package registry>

Target validation:
- <build/start/pack result>

Actions performed:
- <commit | push | tag | publish | deploy> - <detail>, or none

Actions intentionally not performed:
- <commit | push | tag | publish | deploy> -> <awaiting explicit intent | blocked by failed check>

Credentials:
- <present and used | absent, action stopped | not applicable> (never stored)

Remaining limitations:
- <unvalidated live path, or none>

Human review required:
- <publish | push | tag | deploy | version selection | production config | none>

Next manual action:
- <the single concrete step the user should take>
