# Onboarding review

Review the change from the position of a new reader who has only the public
repository. The goal is that a newcomer can understand and run the project.

## Checks

- The README states what the project is and what it is not
- The documented setup steps match the actual manifest and scripts
- The documented run and test commands exist and are correct
- The example configuration is safe to copy and clearly marked as an example
- New public behavior added by the diff is reflected in the docs
- Removed or renamed behavior is not still described as present
- Directory layout in the docs matches the tree the diff produces

## Findings

- A setup or run step that no longer works is a blocking finding
- Docs describing behavior the diff removed is a blocking finding
- Missing but non-blocking guidance is recommended cleanup
- A documented simplification a maintainer accepted is an acceptable trade-off
