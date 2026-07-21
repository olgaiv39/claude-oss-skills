# claude-oss-skills

A set of practical Claude Code runbooks for developing public open-source
projects on resource-constrained hardware. Seven manually-invoked skills cover
the workflow from an empty directory to a deployed release, and two advisory
hooks keep execution cost low. Skills regulate code quality and execution cost;
hooks advise on individual Bash commands

## Purpose

Discourage generated-code clutter, unnecessary abstraction, excessive
comments, speculative architecture, heavy validation commands, and misleading
public documentation - while keeping CPU, RAM, disk, battery, and thermal use
low

## Skills and hooks

Two kinds of thing live here, and they operate at different layers:

- Workflow skills are procedural runbooks you invoke by command (`/oss-plan`,
  `/implement-minimal`, and so on). Each sets `disable-model-invocation: true`,
  so Claude never runs one on its own; you choose when to enter the runbook
- Advisory hooks are shell scripts that inspect a single Bash command
  (`block-expensive-command.sh`) or reduce command output
  (`filter-command-output.sh`). They act per command, not per workflow, and
  they only advise

## Design principles

- Small files, predictable structure, concise language
- Progressive disclosure: each `SKILL.md` routes; stack-specific commands,
  recovery recipes, and report formats live in `references/` and `templates/`
- Conservative shell scripting with no third-party dependencies
- Explicit limitations and truthful documentation
- Shared constraints live in one file; skills reference it instead of
  repeating it

## Directory structure

```text
claude-oss-skills/
├── README.md
├── LICENSE
├── skills/
│   ├── oss-bootstrap/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── templates/
│   ├── oss-plan/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── templates/
│   ├── implement-minimal/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── templates/
│   ├── test-and-debug/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── templates/
│   ├── dependency-review/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── templates/
│   ├── public-code-review/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── templates/
│   └── release-deploy/
│       ├── SKILL.md
│       ├── references/
│       └── templates/
├── shared/LOW_RESOURCE.md
├── hooks/
│   ├── filter-command-output.sh
│   └── block-expensive-command.sh
└── examples/
    ├── CLAUDE.md.example
    └── settings-hooks.example.json
```

Each skill keeps its `SKILL.md` short and moves detail into `references/`
(stack-specific commands, decision tables, recovery recipes) and `templates/`
(the exact report format each skill produces). This keeps the routing logic
readable and loads detail only when a branch needs it

## Skills

The seven skills form a path from an empty directory to a deployed release. Run
the one that matches the task; none activate on their own

- **oss-bootstrap** - Prepares a new or nearly empty repository into a clean
  publishable starting point, detecting the stack and never overwriting an
  existing README, LICENSE, or `.gitignore`
- **oss-plan** - Produces a short, reviewable implementation plan (problem,
  user flow, acceptance criteria, trust boundaries, files, validation, OSS and
  privacy risks, out-of-scope) before writing code
- **implement-minimal** - Implements the smallest complete change that
  satisfies the acceptance criteria; avoids speculative abstraction, unrelated
  changes, obvious comments, and unverified validation claims
- **test-and-debug** - Diagnoses a failing test, build, or runtime error by
  isolating the narrowest reproduction, classifying the failure, and applying
  the smallest fix
- **dependency-review** - Evaluates a proposed dependency and ends with a
  single decision: add, do not add, or defer pending evidence
- **public-code-review** - Reviews a diff or file set as public code across
  quality, repository safety, privacy and provenance, onboarding, and
  maintainability
- **release-deploy** - Runs the pre-release checklist, then follows the
  detected deployment target's path (GitHub repo, static site or Pages, Docker,
  Node or Python service, Archestra app, MCP server, or package registry),
  never publishing, tagging, pushing, or deploying without explicit intent

### Migrating from /release-check

`release-check` is now `release-deploy`. It keeps the same pre-publication
checklist and adds target-specific deployment paths, and it still never
commits, tags, pushes, publishes, or deploys without explicit intent. Update
any command, settings, or `CLAUDE.md` reference from `/release-check` to
`/release-deploy`, and remove a stale `.claude/skills/release-check` directory
from an earlier install

## Hooks

Both hooks are plain POSIX shell and require no third-party packages

### block-expensive-command.sh

Advisory Claude Code `PreToolUse` policy hook for the Bash tool

- Input: the hook payload as JSON on stdin. The script reads `tool_name` and
  `tool_input.command` (via Python 3 standard library) and inspects only the
  Bash command, not the raw JSON text
- Non-Bash tools are allowed (exit 0)
- Allowed command: exit 0. Blocked command: exit 2, with a bounded reason and,
  where possible, a targeted alternative, on stderr
- Fails closed (exit 2) if Python 3 is unavailable, the JSON cannot be parsed,
  or `tool_input.command` is missing or not a string

Override: a command that begins with a leading `FULL_VALIDATION=1 ` assignment
(optional leading whitespace), or the `FULL_VALIDATION=1` environment variable
in the hook process, bypasses only the recognized full-validation checks -
unscoped full test suites, full workspace tests, and broad workspace builds.
It does not bypass any other policy category: package installation, watch
mode, Docker Compose startup or rebuild, background execution, destructive
commands, and unclassifiable commands (such as nested shells) are still
blocked, and both override forms behave identically in this respect. Every
segment of a multi-segment command is checked, so an override on an earlier
segment does not make a later blocked segment acceptable (for example,
`FULL_VALIDATION=1 npm test && npm install lodash` is still blocked). The two
forms differ only in scope: the leading assignment applies to one command; the
environment variable applies to every command the hook sees while it is set. A
later occurrence such as `echo FULL_VALIDATION=1 && npm test` does not activate
the override

Blocks (without override): unscoped `pytest` / `npm test` / `pnpm test` /
`yarn test`, `cargo test --workspace`, broad workspace builds,
`docker compose up --build`, starting all Compose services, recognized common
package-install and dependency-modifying commands, explicit watch mode,
background execution requested either by an unquoted `&` operator or by the
`tool_input.run_in_background` field being `true`. Always blocks (even with
override): `rm -rf` / `rm -fr`, destructive `git reset --hard` /
`git clean -f...`, `mkfs` / `dd` to a raw device, direct `cp` / `mv` / `tee`
writes to a raw device, raw disk redirects, and similar destructive patterns.
Destructive detection inspects the normalized command and its meaningful
arguments, so `echo rm -rf`, `grep "mkfs" README.md`, and `printf "dd if="` are
allowed

Recognized package managers: `npm`, `pnpm`, `yarn`, `pip` / `pip3` (including
`python -m pip`, even after interpreter options such as `-I`, `-S`, or
`-X dev`), `cargo add`, `apt` / `apt-get`, `brew`, `gem`, `go get`, `uv`
(`add`, `sync`, `pip install`, `tool install`), `poetry` (`add`, `install`,
`update`), and `bun` (`install`, `add`, `i`). Ordinary `uv run`, `poetry run`,
and `bun run` are not treated as installs. Unusual or unsupported package
managers may not be detected, because the hook is advisory

Raw-device write coverage includes paths under `/dev/sd`, `/dev/disk`,
`/dev/nvme`, and `/dev/mmcblk`, for `mkfs`, `dd` (`of=/dev/...`), a `cp` / `mv`
final destination on such a path, a `tee` file argument on such a path, and
unquoted redirects to such a path. Reading from a device into a normal file
(for example `cp /dev/sdb backup.img`) is allowed. This is not exhaustive
device protection

Shell operators are found with a small quote- and escape-aware scanner rather
than by comparing tokens, so `cd repo&&npm test` (no spaces) is split, while a
quoted or escaped operator such as `echo "&"`, `printf '%s' 'a;b'`, or
`echo \&` is treated as literal text, not a connector. A single unquoted `&`
is backgrounding and is blocked

Background execution is also blocked when the tool payload sets
`run_in_background` to the JSON boolean `true`; an absent field or `false` is
allowed, and any other value (including the strings `"true"`/`"false"`) fails
closed. The `FULL_VALIDATION=1` override never bypasses this

Executable shell substitution is unclassifiable and always blocked, even under
the override: `$(...)` command substitution, backtick substitution, and
`<(...)` / `>(...)` process substitution are detected outside single quotes
with quote- and escape-awareness. Quoted or escaped forms such as `echo '$('`,
`printf '%s' '<(cmd)'`, and `echo \$\(literal` are treated as literal text, and
arithmetic `$((...))` and parameter expansion `${...}` are not substitution

Wrappers are peeled to reach the real command: `env`, `sudo`, `command`,
`time`, `nice`, and `nohup` are normalized (so `sudo npm test` classifies as
`npm test` and `command yarn install` as `yarn install`), while nested shells
such as `bash -c "..."` are rejected as too complex rather than allowed.
Leading environment assignments (`VAR=value`, valid POSIX names only) are
peeled before and after wrapper normalization, so `CI=1 npm install` and
`sudo CI=1 npm install` still classify as package installation; assignment
values are ignored metadata and never expanded. Only a literal leading
`FULL_VALIDATION=1` on the original command (or the environment variable)
activates the override, so `env FULL_VALIDATION=1 npm test` and a later
`CI=1 FULL_VALIDATION=1 npm test` do not

Git global options before the subcommand are recognized, so
`git -C repo clean -fdx` and `git --git-dir=.git reset --hard` are still seen
as destructive

Docker Compose: options are not service names. Global options before `up`
(including value options such as `-f FILE`, `--project-name NAME`, and
`--profile NAME`) are skipped, and `up` options are parsed by kind so an
option value is never counted as a service. Value-consuming `up` options such
as `--scale api=2`, `--attach api`, `--exit-code-from api`, and
`--wait-timeout 30` consume their value; flag-only options such as `-d` and
`--wait` do not. `docker compose up -d` is blocked (full stack);
`docker compose up -d api` and `docker compose -f compose.yml up -d api` are
allowed (one named service, no build); `docker compose up --scale api=2 api` is
allowed, while `docker compose up --scale api=2` (no explicit service),
`docker compose up -d api worker`, `docker compose --profile dev up -d`,
`docker compose up --build api`, and an `up` option missing its value are
blocked. Unrecognized `up` options are rejected rather than allowed

Watch detection is context-aware (`--watch`, `cargo watch`, `watchexec`,
`nodemon`), so a plain `-w` flag such as `grep -w error logfile` is allowed

Limitations: this is best-effort advisory policy using a quote-aware operator
scanner plus conservative per-segment tokenization (Python `shlex`), not a full
shell parser or sandbox. It can miss obfuscated or unusual commands and may
occasionally flag a safe one. Claude Code permissions and human review remain
necessary

### filter-command-output.sh

Standalone pipe utility (not a native Claude Code hook) that reduces large
command output before it reaches Claude. Claude Code hooks receive structured
JSON on stdin, whereas this script expects raw command output, so it is used
inside your own commands

Contract:

```sh
filter-command-output.sh EXIT_STATUS
```

- `EXIT_STATUS` is required and must be an integer 0-255: the original
  command's exit status. A pipeline cannot recover an upstream status, so the
  caller must supply it
- Reads raw command output from stdin. Input with no trailing newline still
  counts as output (emptiness is checked by size, not by counting newlines)
- Saves the complete input to a retained temporary log (not deleted by the
  script)
- Prints context around failure markers (`error`, `failed`, `failure`,
  `exception`, `panic`, `traceback`, `stack trace`), a bounded tail, and the
  full log path
- Bounds memory: the log is read from disk in two passes and only a bounded
  amount of context and tail is buffered, so memory does not grow with total
  log length. The full log remains on disk
- De-duplicates by source line number: a line already shown in a failure
  context is not repeated in the tail. Identical text from genuinely different
  source lines may still appear more than once
- Validates its tunable bounds (`CONTEXT_BEFORE`, `CONTEXT_AFTER`,
  `TAIL_LINES`, `MAX_MATCH_BLOCKS`) as non-negative integers; an invalid value
  or `EXIT_STATUS` produces a concise error and exit 2, not a misleading
  summary
- Exits with the supplied `EXIT_STATUS` on success; if the filter itself fails
  to process the log, it exits 2 instead

Safe single-execution example (the command runs once):

```sh
capture_file=$(mktemp)

your_command >"$capture_file" 2>&1
status=$?

hooks/filter-command-output.sh "$status" <"$capture_file"
filter_status=$?

rm -f "$capture_file"
exit "$filter_status"
```

Here `your_command` runs once, the filter creates its own retained full log,
the temporary capture file may be deleted after filtering, and the filter
returns the original command status. Do not wrap this in `set -e` in a way that
skips the capture-file cleanup after a non-zero command

Tunable bounds via environment: `CONTEXT_BEFORE`, `CONTEXT_AFTER`,
`TAIL_LINES`, `MAX_MATCH_BLOCKS`

## Installation (manual)

Nothing here installs or activates itself. Installation copies `skills`,
`hooks`, and `shared` into a `.claude` directory. The examples below are
illustrative and **must not be run as-is** - read them first

The installed layout should be:

```text
.claude/
├── skills/
├── hooks/
└── shared/
```

Install conservatively: check every exact destination first, stop on the first
conflict, and never replace an existing skill, hook, shared policy, or settings
file. This example copies into a project's `.claude` and refuses to overwrite:

```sh
# Project install. Run from the bundle root. Adjust DEST for a user install
# by setting DEST="$HOME/.claude".
DEST=".claude"

# 1. Check every destination path first; stop on the first conflict.
#    -e misses broken symlinks, so -L is also checked.
for rel in skills/oss-bootstrap skills/oss-plan skills/implement-minimal \
           skills/test-and-debug skills/dependency-review \
           skills/public-code-review skills/release-deploy \
           hooks/filter-command-output.sh hooks/block-expensive-command.sh \
           shared/LOW_RESOURCE.md; do
    if [ -e "$DEST/$rel" ] || [ -L "$DEST/$rel" ]; then
        echo "conflict: $DEST/$rel already exists; aborting" >&2
        exit 1
    fi
done

# 2. Create only missing parent directories.
mkdir -p "$DEST/skills" "$DEST/hooks" "$DEST/shared"

# 3. Copy only after all checks passed (no -f, no overwrite).
cp -R skills/. "$DEST/skills/"
cp hooks/filter-command-output.sh hooks/block-expensive-command.sh "$DEST/hooks/"
cp shared/LOW_RESOURCE.md "$DEST/shared/"
# Make only the two bundle hooks executable; do not touch other hooks.
chmod +x "$DEST/hooks/filter-command-output.sh" \
         "$DEST/hooks/block-expensive-command.sh"
```

For a user-level install, set `DEST="$HOME/.claude"` and run the same checks

Optional symlink install (single source of truth) - check every destination
first, stop on the first conflict, and only then create links; this bundle
does not create symlinks for you. A broken (dangling) symlink counts as a
conflict, so `-e || -L` is used rather than `-e` alone:

```sh
# Run from the bundle root. Adjust DEST for a user install
# by setting DEST="$HOME/.claude".
DEST=".claude"
SRC="$(pwd)"

rels="skills/oss-bootstrap skills/oss-plan skills/implement-minimal \
      skills/test-and-debug skills/dependency-review \
      skills/public-code-review skills/release-deploy \
      hooks/filter-command-output.sh hooks/block-expensive-command.sh \
      shared/LOW_RESOURCE.md"

# 1. Check every destination first; stop on the first conflict.
#    Treat an existing file, directory, or broken symlink as a conflict.
for rel in $rels; do
    if [ -e "$DEST/$rel" ] || [ -L "$DEST/$rel" ]; then
        echo "conflict: $DEST/$rel already exists; aborting" >&2
        exit 1
    fi
done

# 2. Create only missing parent directories.
mkdir -p "$DEST/skills" "$DEST/hooks" "$DEST/shared"

# 3. Link only after all checks passed (no -f, no overwrite).
for rel in $rels; do
    ln -s "$SRC/$rel" "$DEST/$rel"
done
```

A symlink install points Claude Code at the source hook files, so the source
`hooks/filter-command-output.sh` and `hooks/block-expensive-command.sh` must
keep their executable permission (they ship as `0755`). The copy install runs
`chmod +x` on the destination copies as a defensive measure; the symlink path
relies on the source permission bits, so do not clear them

Settings activation is a separate manual merge (see below). Do not replace an
existing `settings.json` or `settings.local.json` with the example file

## Manual activation

- Skills are discovered from `.claude/skills/` or `~/.claude/skills/`. All
  seven skills set `disable-model-invocation: true`, so they are procedural
  workflows that you invoke manually by command; Claude does not activate them
  automatically:

  ```text
  /oss-bootstrap
  /oss-plan
  /implement-minimal
  /test-and-debug
  /dependency-review
  /public-code-review
  /release-deploy
  ```

- To enable the command-policy hook, merge the object in
  `examples/settings-hooks.example.json` into your existing Claude Code
  settings file yourself. It is not activated automatically, and it must not
  replace a complete settings file

- The example is project-scoped: its command path uses
  `${CLAUDE_PROJECT_DIR}/.claude/hooks/block-expensive-command.sh`, which
  resolves only inside a project that has the hook installed under its
  `.claude`. For a user-level install (the bundle copied to `$HOME/.claude`),
  that variable does not point at your home directory, so change the command
  path to the absolute location instead, for example
  `$HOME/.claude/hooks/block-expensive-command.sh`. Do not assume the
  project-scoped example works unchanged for a user-level install

## Low-resource rationale

See `shared/LOW_RESOURCE.md`. The bundle assumes limited CPU, RAM, disk,
battery, and thermal capacity, so it favors targeted validation, single-worker
tests, no watch mode, and full validation only at milestone boundaries

## Usage examples

- Start a new repository: run `/oss-bootstrap`, review the created files, then
  commit yourself
- Start a feature: run `/oss-plan`, review the plan, then `/implement-minimal`
- When a test or build breaks: run `/test-and-debug`
- Before adding a package: run `/dependency-review`
- Before merging: run `/public-code-review`
- Before publishing or deploying: run `/release-deploy`

## Example configuration

`examples/settings-hooks.example.json` wires only `block-expensive-command.sh`
as a `PreToolUse` hook matching `Bash`. It uses `${CLAUDE_PROJECT_DIR}` so the
path resolves inside a project, and the command wraps the expanded path in
double quotes so it still works if `${CLAUDE_PROJECT_DIR}` contains spaces. It
does not wire `filter-command-output.sh` (a pipe utility, not a native hook)

The file is a fragment, not a complete settings file. Merge the `hooks` object
into your existing settings by hand; do not overwrite `settings.json` or
`settings.local.json` with it. Fields beyond `matcher`, `type`, and `command`
are intentionally omitted to stay compatible across versions; add `timeout` or
an `if` filter yourself only if your Claude Code version supports them

## Limitations

- The bundle does not guarantee secure or correct code
- The hooks are not a sandbox and do not catch every risky command
- Users must review generated code
- Public repositories require manual privacy, licensing, and provenance
  review
- The example configuration is not activated automatically
- No telemetry or network access is included

## Uninstall

Remove the copied files. Review each path first and adjust `.claude` to
`$HOME/.claude` for a user-level install. These commands name every path
explicitly and avoid `rm -rf`: `rm -r --` removes the seven skill directories,
and `rm -f --` removes the exact hook and shared-policy files

```sh
rm -r -- .claude/skills/oss-bootstrap .claude/skills/oss-plan \
         .claude/skills/implement-minimal .claude/skills/test-and-debug \
         .claude/skills/dependency-review .claude/skills/public-code-review \
         .claude/skills/release-deploy
rm -f -- .claude/hooks/filter-command-output.sh \
         .claude/hooks/block-expensive-command.sh \
         .claude/shared/LOW_RESOURCE.md
```

Then remove any hook entry you added to your Claude Code settings

## Security note

These skills and hooks guide behavior; they do not enforce security. Treat
them as advisory. Review all generated code and configuration before trusting
it, especially for anything published publicly

## Contributing

Keep contributions small and consistent with the rules this bundle promotes:
concise files, no speculative abstraction, no obvious comments, truthful
documentation, and explicit limitations

## License

MIT. See `LICENSE`
