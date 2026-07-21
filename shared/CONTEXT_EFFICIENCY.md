# Context-efficiency policy

Spend context deliberately. This policy governs how much to read, retain, and
carry forward so a task can finish before context runs out. It is separate from
the low-resource policy, which governs compute cost. Apply both.

### Select before reading

- Identify the exact decision or change first, then read for it
- List the files likely required before opening any of them
- Prefer `git diff`, `git status`, a bounded `find`, and a targeted `rg` over
  opening files blindly
- Inspect changed files before unrelated files
- Do not scan the full repository without a concrete reason

### Read progressively

- Read headings, search matches, and bounded ranges before whole files
- Read a complete file only when the excerpts are insufficient
- Do not reread content you already inspected and that has not changed
- Open only the reference selected by the current workflow branch
- Do not preload every reference or template

### Keep working context compact

- Reuse facts already established instead of rederiving them
- Summarize large files and logs rather than pasting them in full
- Preserve exact paths, commands, errors, and acceptance criteria verbatim
- Omit empty report sections and repeated policy prose
- Prefer one evidence-bearing excerpt over several redundant ones

### Control scope

- Complete one atomic increment before starting another
- Do not expand scope for visible nearby improvements
- Record unrelated findings without implementing them
- Do not start a new phase unless the current session can finish it

### Context checkpoints

When context is limited:

1. Stop broad exploration
2. Finish or revert the current atomic change
3. Run the narrowest relevant validation
4. Record a compact handoff
5. Stop before beginning another phase

Handoff format:

```text
Goal
Baseline
Confirmed facts
Files changed
Validation performed
Validation not performed
Open blockers
Exact next action
```

### Stop conditions

Stop and request a new session or direction when:

- Remaining context is insufficient to complete the current phase safely
- Required facts cannot be recovered without rereading most of the repository
- Multiple unrelated workflows have been mixed into one session
- A reliable handoff is safer than another partial change

Do not claim exact token counts unless Claude Code exposes them directly.
