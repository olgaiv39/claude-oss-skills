---
name: oss-plan
description: Produce a short, reviewable implementation plan before writing substantial code for a public open-source project. Use when starting or extending a project, before code generation, to define scope, trust boundaries, validation, and open-source and privacy risks. Do not write code while using this skill.
disable-model-invocation: true
---

# oss-plan

Produce a short implementation plan before any substantial code generation.
Do not create code while using this skill.

Read the first of these files that exists, then follow it:

- `${CLAUDE_PROJECT_DIR}/.claude/shared/LOW_RESOURCE.md`
- `$HOME/.claude/shared/LOW_RESOURCE.md`

If neither exists, do not scan the filesystem; apply these core constraints:
run one expensive command at a time, prefer targeted tests before full
suites, disable watch mode, and run full validation only at milestones.

## Plan contents

Write a concise plan with these sections:

1. **Problem** — the concrete problem being solved.
2. **Primary user flow** — the main path a user takes end to end.
3. **Acceptance criteria** — testable conditions for "done".
4. **Data sources and trust boundaries** — where data enters, what is
   trusted, what must be validated.
5. **Files expected to change** — existing files you will edit.
6. **Files expected to be created** — new files.
7. **Validation commands** — targeted commands to verify the change.
8. **Open-source and privacy risks** — see checklist below.
9. **Out of scope** — work explicitly excluded from this change.

## Open-source and privacy risks

Identify whether any proposed code or data may be confidential, proprietary,
personal, or otherwise unsuitable for a public repository. Flag secrets,
internal URLs, client or employer names, and copied private code.

## Behavioral rules

- Do not create code while planning.
- Do not invent future requirements.
- Do not introduce abstractions for hypothetical features.
- Do not propose unrelated refactoring.
- Prefer one complete vertical slice over broad partial work.
- Keep the plan short enough to review in a few minutes.
- Distinguish confirmed requirements from assumptions; label assumptions.

## Output

Present the plan for review. Stop after the plan. Implementation happens
under `implement-minimal`, not here.
