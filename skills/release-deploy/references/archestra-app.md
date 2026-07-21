# Archestra app

Package and deploy an app for the Archestra platform. Follow the project's own
Archestra manifest and documented packaging; do not infer platform steps that
the repository does not specify.

## Prerequisites

- The pre-release checklist passed
- An Archestra app manifest or the project's documented Archestra packaging
- The build command the manifest or docs specify
- Any required platform credentials, confirmed present by the user

## Steps

1. Read the app manifest to learn the declared entry, permissions, and any
   required configuration
2. Confirm the manifest declares no secret inline and references configuration
   by name only
3. Run the documented build or package command once
4. Verify the produced artifact matches what the manifest declares
5. Confirm required configuration is documented for the operator and absent as
   real values from the tree
6. Publish or deploy to the platform only through the documented method and only
   on explicit intent

## Validation

- The manifest parses and its declared entry exists
- The package or artifact builds without error
- No secret or private configuration value is embedded

## Explicit-intent gate

- Never publish to the platform without a direct request
- Never embed platform credentials in the repository or the artifact
- Never widen declared permissions to make a build pass

## Common failures

- The manifest declares an entry that the build does not produce
- Required configuration is undocumented, so the app fails on install
- Permissions declared broader than the app actually needs
