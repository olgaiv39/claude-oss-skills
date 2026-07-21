---
name: public-code-review
description: Review the current diff or a specified set of files as public open-source code. Use before publishing or merging to check code quality, public-repository safety (secrets and private data), documentation trustworthiness, and maintainability. Reports issues; does not fix them unless asked.
disable-model-invocation: true
---

# public-code-review

Review the current diff, or a clearly specified set of files, as public
open-source code. Do not automatically fix issues unless explicitly requested.

Read the first of these files that exists, then follow it, before running
any commands:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, do not scan the filesystem; apply these core constraints:
run one expensive command at a time, prefer targeted tests before full
suites, disable watch mode, and run full validation only at milestones.

## Code quality

Check for: unnecessary abstractions, unnecessary layers, duplicated logic,
dead code, unused exports, oversized functions, excessive comments, unclear
naming, unrelated changes, speculative error handling, avoidable complexity.

## Public repository safety

Check for: secrets, credentials, tokens, private keys, wallet seed material,
personal information, private email addresses, internal URLs, client or
employer names, confidential project terminology, proprietary data, copied
private code, generated artifacts, unexpected binaries, unsafe example
configuration.

## Trustworthiness

Check that:

- README claims match implemented behavior.
- Mock and demo data are clearly identified.
- Known limitations are visible.
- Benchmark or performance claims have evidence.
- Security claims are appropriately limited.
- The project does not call itself production-ready without justification.
- Generated text does not fabricate tests, metrics, integrations, or
  compatibility.

## Maintainability

Check that: setup is understandable, structure is predictable, errors are
actionable, dependencies are justified, changed code is testable, and
architecture is proportionate to project size.

## Output

Group findings into:

- **Blocking issues**
- **Recommended cleanup**
- **Acceptable trade-offs**
- **Files requiring human review**

Do not fix anything unless the user explicitly asks.
