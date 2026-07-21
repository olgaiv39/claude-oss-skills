# Deployment checklist

Record each applicable item as passed, failed, skipped, or requires human
review. Do not treat a skipped item as passing.

## Repository hygiene

- Clean-clone setup instructions: <result>
- README accuracy: <result>
- LICENSE present and correct: <result>
- `.gitignore` covers generated and secret files: <result>
- `.env.example` present and free of real secrets: <result>

## Safety

- No secret exposure: <result>
- No personal or proprietary data exposure: <result>
- No accidental generated files or binaries: <result>

## Correctness

- Targeted tests for changed areas: <result>
- Full test suite: <result>
- Lint: <result>
- Type checking: <result>
- Production build: <result>
- Demo or mock mode behaves as documented: <result>

## Documentation and licensing

- No broken documentation links: <result>
- Dependency licenses compatible: <result>
- Attribution complete: <result>
- Known limitations documented: <result>
- No unsupported production claims: <result>

## Target-specific

- Deployment target detected: <target>
- Target prerequisites met: <result>
- Credentials present (not stored): <present | absent | not applicable>
