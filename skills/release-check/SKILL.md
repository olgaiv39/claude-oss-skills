---
name: release-check
description: Final pre-publication and pre-submission review for a public open-source project. Use at a release or submission boundary to verify setup, documentation accuracy, secret and privacy exposure, tests, lint, build, licenses, and claims. Runs expensive checks sequentially. Does not publish, tag, commit, push, or release.
disable-model-invocation: true
---

# release-check

Final review before publishing or submitting. Do not publish, tag, commit,
push, or release anything.

Read the first of these files that exists, then follow it. Full validation
runs only at this boundary:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, do not scan the filesystem; apply these core constraints:
run one expensive command at a time, prefer targeted tests before full
suites, disable watch mode, and run full validation only at milestones.

## Checklist

Where applicable, verify:

- Clean-clone setup instructions.
- README accuracy.
- LICENSE present and correct.
- `.gitignore` covers generated and secret files.
- `.env.example` present and free of real secrets.
- No secret exposure.
- No personal or proprietary data exposure.
- Targeted tests for changed areas.
- Full test suite.
- Lint.
- Type checking.
- Production build.
- Demo or mock mode behaves as documented.
- No broken documentation links.
- Screenshots or demo assets are accurate.
- Dependency licenses are compatible.
- Attribution is complete.
- Known limitations are documented.
- No unsupported production claims.
- No accidental generated files or binaries.
- Consistency between documentation and actual behavior.

## Low-resource execution

- Run expensive checks sequentially.
- Begin with targeted checks.
- Run full validation only at this release or submission boundary.
- Never run watchers.
- Never run duplicate builds.
- Never start unrelated services.
- Record checks that could not be run.
- Do not treat skipped checks as passing.

## Output

Report each item as one of:

- **passed**
- **failed**
- **skipped**
- **requires human review**
