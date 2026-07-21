# MCP server

Package and deploy a Model Context Protocol server. Verify it starts and
advertises its tools correctly; publish only on explicit intent.

## Prerequisites

- The pre-release checklist passed
- An MCP server manifest or entry describing the server and its tools
- The run command for the server, from the project scripts
- The intended distribution: a package registry, a container, or a repository

## Steps

1. Read the server manifest; confirm the declared tools match the implemented
   handlers
2. Confirm each tool declares its input schema and that responses are validated
   before return
3. Start the server locally with its documented transport and confirm it lists
   its tools
4. Exercise one representative tool call and confirm the response shape matches
   its declared schema
5. Confirm no secret is embedded and that any credential is read from
   configuration by name
6. Distribute through the chosen target's reference (package, Docker, or
   repository) only on explicit intent

## Validation

- The server starts and advertises the declared tools
- A representative tool call returns a schema-valid response
- Tool errors are handled and reported, not swallowed

## Explicit-intent gate

- Never publish the server or its package without a direct request
- Never embed a client secret or token in the server package
- Never widen a tool's declared capability to make a call succeed

## Common failures

- A declared tool with no implemented handler, or the reverse
- A tool response that does not match its declared schema
- A secret read from a hard-coded value instead of configuration
