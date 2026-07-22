#!/bin/sh
# block-expensive-command.sh
# Advisory Claude Code PreToolUse policy hook for the Bash tool.
#
# Contract:
#   - Claude Code sends the hook payload as JSON on stdin.
#   - Reads .tool_name and .tool_input.command from that JSON.
#   - Non-Bash tools are allowed (exit 0).
#   - Allowed command:  exit 0
#   - Blocked command:  exit 2 (reason on stderr)
#   - Unparseable input or missing command: fail closed (exit 2).
#
# Override:
#   - A command that begins with a LITERAL leading `FULL_VALIDATION=1 `
#     assignment, or the FULL_VALIDATION=1 environment variable, bypasses ONLY
#     the 'validation' category (unscoped full test suites, full workspace
#     tests, broad workspace builds). It NEVER bypasses package installation,
#     watch mode, Docker Compose startup/rebuild, background execution,
#     destructive commands, or unclassifiable commands. Every segment of a
#     multi-segment command is still checked.
#   - The override is detected on the original command, before any wrapper
#     (env/sudo/...) is peeled, so `env FULL_VALIDATION=1 ...` does NOT
#     activate it.
#
# This is a best-effort advisory policy, not a sandbox. Operator detection
# tracks shell quoting/escaping but is not a full shell parser, so it can
# miss unusual commands. Claude Code permissions and human review remain
# necessary.

set -u

if ! command -v python3 >/dev/null 2>&1; then
    echo "block-expensive-command: python3 unavailable; failing closed" >&2
    exit 2
fi

PYPROG=$(cat <<'PY'
import sys, os, json, re, shlex

# Raw block-device path prefixes. Writing directly to these bypasses the
# filesystem and is treated as destructive. This is not an exhaustive list of
# device nodes.
RAW_DEVICE_PREFIXES = ('/dev/sd', '/dev/disk', '/dev/nvme', '/dev/mmcblk')

def is_raw_device_path(p):
    return p.startswith(RAW_DEVICE_PREFIXES)

# A leading POSIX shell assignment token: NAME=VALUE with a valid variable
# name. The value is treated as opaque metadata and never expanded.
_ASSIGN_RE = re.compile(r'[A-Za-z_][A-Za-z0-9_]*=')

def is_env_assignment(tok):
    return _ASSIGN_RE.match(tok) is not None

def block(reason, alt=None):
    sys.stderr.write("BLOCKED: " + reason + "\n")
    if alt:
        sys.stderr.write("Try instead: " + alt + "\n")
    sys.exit(2)

raw = sys.stdin.read()
try:
    data = json.loads(raw)
except Exception:
    sys.stderr.write("block-expensive-command: unparseable hook JSON; failing closed\n")
    sys.exit(2)

if not isinstance(data, dict):
    sys.stderr.write("block-expensive-command: unexpected hook payload; failing closed\n")
    sys.exit(2)

if data.get("tool_name") != "Bash":
    sys.exit(0)

tool_input = data.get("tool_input")
if not isinstance(tool_input, dict):
    sys.stderr.write("block-expensive-command: missing tool_input; failing closed\n")
    sys.exit(2)

command = tool_input.get("command")
if not isinstance(command, str) or command.strip() == "":
    sys.stderr.write("block-expensive-command: missing command string; failing closed\n")
    sys.exit(2)

# Literal multiline commands are unclassifiable: this hook classifies one
# command at a time and does not parse multiple lines, heredocs, or escaped
# line continuations. Fail closed even under the override.
if "\n" in command or "\r" in command:
    block("multiline command is unclassifiable",
          "run one directly classifiable command at a time")

# Background execution requested through the tool input itself. A literal JSON
# boolean true is blocked; anything other than absent/false (including the
# strings "true"/"false") fails closed. The override never bypasses this.
if "run_in_background" in tool_input:
    rib = tool_input.get("run_in_background")
    if rib is True:
        block("background execution (run_in_background)", "run in the foreground, one command at a time")
    if rib is not False:
        sys.stderr.write("block-expensive-command: run_in_background must be a JSON boolean; failing closed\n")
        sys.exit(2)

# Override only when FULL_VALIDATION=1 is a literal leading assignment on the
# ORIGINAL command, or set in the hook environment. Detect before any wrapper
# normalization so `env FULL_VALIDATION=1 ...` cannot activate it.
override = os.environ.get("FULL_VALIDATION") == "1"
work = command.strip()
mprefix = re.match(r'FULL_VALIDATION=1(?:\s+|$)', work)
if mprefix:
    override = True
    work = work[mprefix.end():].strip()

if work == "":
    sys.exit(0)

# Fork bomb is a structural signature, not an argument value.
if ':(){' in work or ':|:&' in work:
    block("fork bomb", "do not run this")


def has_device_redirect(raw):
    """Detect an UNQUOTED redirection whose target is a raw disk device
    (see RAW_DEVICE_PREFIXES). Quoted data arguments are ignored, so
    `echo ">/dev/sda"` is not flagged."""
    i = 0
    n = len(raw)
    in_single = False
    in_double = False
    while i < n:
        c = raw[i]
        if in_single:
            if c == "'":
                in_single = False
            i += 1
            continue
        if in_double:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == '"':
                in_double = False
            i += 1
            continue
        if c == '\\':
            i += 2
            continue
        if c == "'":
            in_single = True
            i += 1
            continue
        if c == '"':
            in_double = True
            i += 1
            continue
        if c == '>':
            j = i + 1
            if j < n and raw[j] == '>':
                j += 1
            while j < n and raw[j] in ' \t':
                j += 1
            tail = raw[j:]
            if is_raw_device_path(tail):
                return True
        i += 1
    return False


def has_command_substitution(raw):
    """Detect executable shell substitution outside single quotes: $(...)
    command substitution, backtick substitution, and <(...) / >(...) process
    substitution. Honors single quotes, double quotes, and backslash escaping.
    Arithmetic $((...)) and parameter expansion ${...} are not substitution."""
    i = 0
    n = len(raw)
    in_single = False
    in_double = False
    while i < n:
        c = raw[i]
        if in_single:
            if c == "'":
                in_single = False
            i += 1
            continue
        if c == '\\':
            # Escapes the next char in unquoted and double-quoted contexts.
            i += 2
            continue
        if in_double:
            if c == '"':
                in_double = False
                i += 1
                continue
            if c == '`':
                return True
            if c == '$' and raw[i + 1:i + 2] == '(' and raw[i + 2:i + 3] != '(':
                return True
            i += 1
            continue
        if c == "'":
            in_single = True
            i += 1
            continue
        if c == '"':
            in_double = True
            i += 1
            continue
        if c == '`':
            return True
        if c == '$' and raw[i + 1:i + 2] == '(' and raw[i + 2:i + 3] != '(':
            return True
        if c in '<>' and raw[i + 1:i + 2] == '(':
            return True
        i += 1
    return False


def scan_segments(s):
    """Split a command string into segments on unquoted shell control
    operators (& && | || ;), honoring single quotes, double quotes and
    backslash escaping. Returns (segments, operators, unbalanced)."""
    segs = []
    ops = []
    cur = []
    i = 0
    n = len(s)
    in_single = False
    in_double = False
    unbalanced = False
    while i < n:
        c = s[i]
        if in_single:
            cur.append(c)
            if c == "'":
                in_single = False
            i += 1
            continue
        if in_double:
            if c == '\\' and i + 1 < n:
                cur.append(c)
                cur.append(s[i + 1])
                i += 2
                continue
            cur.append(c)
            if c == '"':
                in_double = False
            i += 1
            continue
        if c == '\\':
            # Escaped next char is literal, never an operator.
            cur.append(c)
            if i + 1 < n:
                cur.append(s[i + 1])
                i += 2
            else:
                i += 1
            continue
        if c == "'":
            in_single = True
            cur.append(c)
            i += 1
            continue
        if c == '"':
            in_double = True
            cur.append(c)
            i += 1
            continue
        # Redirection guard: >& and &> are redirections, not backgrounding.
        # A digit or > immediately before '&' (e.g. 2>&1, >&2) means redirect.
        if c == '&':
            prev = s[i - 1] if i > 0 else ''
            nxt = s[i + 1] if i + 1 < n else ''
            if prev == '>' or nxt == '>':
                cur.append(c)
                i += 1
                continue
            if nxt == '&':
                ops.append('&&')
                segs.append(''.join(cur)); cur = []
                i += 2
                continue
            ops.append('&')
            segs.append(''.join(cur)); cur = []
            i += 1
            continue
        if c == '|':
            nxt = s[i + 1] if i + 1 < n else ''
            if nxt == '|':
                ops.append('||')
                segs.append(''.join(cur)); cur = []
                i += 2
                continue
            ops.append('|')
            segs.append(''.join(cur)); cur = []
            i += 1
            continue
        if c == ';':
            ops.append(';')
            segs.append(''.join(cur)); cur = []
            i += 1
            continue
        cur.append(c)
        i += 1
    if in_single or in_double:
        unbalanced = True
    segs.append(''.join(cur))
    return segs, ops, unbalanced


segments_raw, operators, unbalanced = scan_segments(work)
if unbalanced:
    block("command has unbalanced quotes", "simplify the command")


def tokenize(seg):
    try:
        return shlex.split(seg)
    except ValueError:
        block("command could not be parsed safely", "simplify the command")


# Wrapper normalization. Peel known-safe wrappers to reach the real command.
# Reject wrappers we cannot classify rather than silently allowing them.
NESTED_SHELLS = {'sh', 'bash', 'zsh', 'dash', 'ksh'}

# Obvious shell control / compound-command tokens. If a normalized segment
# begins with one of these we cannot classify it with confidence, so we fail
# closed. This is a conservative guard, not a recursive shell parser.
SHELL_CONTROL_TOKENS = {
    'eval', '{', 'if', 'then', 'elif', 'else', 'fi',
    'for', 'while', 'until', 'case', 'esac', 'do', 'done',
    'select', 'function',
}


def normalize_wrappers(tokens):
    """Return (tokens, reject_reason). reject_reason set means block."""
    guard = 0
    while tokens and guard < 40:
        guard += 1
        # Peel leading environment assignments (VAR=value ...). Values are
        # ignored metadata; the first non-assignment token is the executable.
        j = 0
        while j < len(tokens) and is_env_assignment(tokens[j]):
            j += 1
        if j > 0:
            tokens = tokens[j:]
            continue
        cmd = tokens[0]
        rest = tokens[1:]
        if cmd in NESTED_SHELLS:
            # A nested shell invocation with -c hides an inner command.
            if any(a == '-c' for a in rest):
                return tokens, "nested shell -c is too complex to classify"
            # Bare `sh script.sh` etc. is not something we can classify.
            return tokens, "nested shell invocation is too complex to classify"
        if cmd == 'env':
            j = 0
            while j < len(rest):
                a = rest[j]
                if a.startswith('-'):
                    # env options (e.g. -i, -u NAME) are too varied to trust.
                    return tokens, "env with options is too complex to classify"
                if '=' in a and not a.startswith('='):
                    j += 1
                    continue
                break
            if j >= len(rest):
                return tokens, "env sets variables but runs no command"
            tokens = rest[j:]
            continue
        if cmd == 'sudo':
            j = 0
            while j < len(rest) and rest[j].startswith('-'):
                # sudo options can take values; too varied to trust.
                return tokens, "sudo with options is too complex to classify"
            if j >= len(rest):
                return tokens, "sudo runs no command"
            tokens = rest[j:]
            continue
        if cmd == 'nohup':
            if not rest:
                return tokens, "nohup runs no command"
            tokens = rest
            continue
        if cmd == 'command':
            j = 0
            while j < len(rest) and rest[j].startswith('-'):
                j += 1
            if j >= len(rest):
                return tokens, "command builtin runs no command"
            tokens = rest[j:]
            continue
        if cmd == 'time':
            j = 0
            while j < len(rest) and rest[j].startswith('-'):
                j += 1
            if j >= len(rest):
                return tokens, "time runs no command"
            tokens = rest[j:]
            continue
        if cmd == 'nice':
            j = 0
            while j < len(rest):
                a = rest[j]
                if a == '-n':
                    j += 2
                    continue
                if a.startswith('-'):
                    j += 1
                    continue
                break
            if j >= len(rest):
                return tokens, "nice runs no command"
            tokens = rest[j:]
            continue
        break
    return tokens, None


GIT_VALUE_OPTS = {'-C', '-c', '--git-dir', '--work-tree', '--namespace',
                  '--exec-path', '--config-env'}


def git_subcommand(rest):
    """Return (subcommand, args) after skipping git global options, or
    (None, []) if none found."""
    i = 0
    while i < len(rest):
        a = rest[i]
        if a.startswith('-'):
            if '=' in a:
                i += 1
                continue
            if a in GIT_VALUE_OPTS:
                i += 2
                continue
            i += 1
            continue
        return a, rest[i + 1:]
    return None, []


def seg_is_destructive(tokens):
    """Inspect the normalized executable (tokens[0]) and its meaningful
    arguments, not arbitrary substrings, so quoted data is never matched."""
    if not tokens:
        return False
    cmd = tokens[0]
    # Recursive forced removal, only when rm is the actual command.
    if cmd == 'rm':
        flags = [t for t in tokens[1:] if t.startswith('-')]
        joined = ''.join(f.lstrip('-') for f in flags)
        has_r = 'r' in joined or '--recursive' in tokens
        has_f = 'f' in joined or '--force' in tokens
        if has_r and has_f:
            return True
    # Filesystem creation is inherently a raw-device operation.
    if cmd == 'mkfs' or cmd.startswith('mkfs.'):
        return True
    # dd writing to a raw device (of=/dev/...).
    if cmd == 'dd':
        for t in tokens[1:]:
            if t.startswith('of=/dev/'):
                return True
    # cp/mv whose final destination argument is a raw device. Reading FROM a
    # device into a normal file (device not last) is not flagged.
    if cmd in ('cp', 'mv'):
        args = tokens[1:]
        if args and is_raw_device_path(args[-1]):
            return True
    # tee writing to a raw device (any non-option file argument).
    if cmd == 'tee':
        for t in tokens[1:]:
            if t.startswith('-'):
                continue
            if is_raw_device_path(t):
                return True
    if cmd == 'git':
        sub, sargs = git_subcommand(tokens[1:])
        if sub == 'clean':
            for f in sargs:
                if f.startswith('-') and 'f' in f.lstrip('-'):
                    return True
        if sub == 'reset' and '--hard' in sargs:
            return True
    return False


COMPOSE_VALUE_OPTS = {'-f', '--file', '-p', '--project-name', '--profile',
                      '--env-file', '--project-directory', '--ansi',
                      '--parallel', '--host', '-H'}

# `up`-subcommand options that consume a following value when given in the
# separated form (e.g. `--scale api=2`, `--attach api`). In `--opt=value`
# form the value is attached, so no extra token is consumed.
COMPOSE_UP_VALUE_OPTS = {'--scale', '--attach', '--no-attach',
                         '--exit-code-from', '--timeout', '-t',
                         '--wait-timeout', '--pull'}

# `up`-subcommand flag options that never consume a value.
COMPOSE_UP_FLAG_OPTS = {'-d', '--detach', '--wait',
                        '--abort-on-container-exit',
                        '--abort-on-container-failure',
                        '--always-recreate-deps', '--force-recreate',
                        '--no-recreate', '--no-build', '--remove-orphans',
                        '--renew-anon-volumes', '--quiet-pull', '--no-color'}


def classify_compose_up(up_args):
    """Return a (reason, alt) tuple to block, or None to allow.

    Separates `up` value-consuming options, flag-only options, and explicit
    service names so that an option value is never miscounted as a service.
    Exactly one explicit service is required; a rebuild (--build) is blocked;
    an option missing its value is treated as malformed."""
    if '--build' in up_args:
        return ("docker compose up with rebuild", "start one service without --build")
    i = 0
    services = []
    while i < len(up_args):
        a = up_args[i]
        if a.startswith('-'):
            if '=' in a:
                # --opt=value: value attached, consume one token.
                i += 1
                continue
            if a in COMPOSE_UP_VALUE_OPTS:
                if i + 1 >= len(up_args):
                    return ("docker compose up option missing its value",
                            "provide the option value, or start one service")
                i += 2
                continue
            if a in COMPOSE_UP_FLAG_OPTS:
                i += 1
                continue
            return ("docker compose up has an unrecognized option",
                    "start one service with recognized options only")
        services.append(a)
        i += 1
    if not services:
        return ("docker compose up starts all services", "docker compose up <one-service>")
    if len(services) > 1:
        return ("docker compose up starts multiple services", "docker compose up <one-service>")
    return None  # exactly one named service, no rebuild


def classify_compose(tokens):
    """If tokens is a docker compose invocation, return (reason, alt) to
    block or None to allow. Return False if not a compose command."""
    cmd = tokens[0]
    if cmd == 'docker' and tokens[1:2] == ['compose']:
        rest = tokens[2:]
    elif cmd == 'docker-compose':
        rest = tokens[1:]
    else:
        return False
    # Skip compose global options (some take a value) to find the subcommand.
    i = 0
    while i < len(rest):
        a = rest[i]
        if a.startswith('-'):
            if '=' in a:
                i += 1
                continue
            if a in COMPOSE_VALUE_OPTS:
                i += 2
                continue
            i += 1
            continue
        break
    sub = rest[i] if i < len(rest) else None
    if sub != 'up':
        return None  # non-up compose commands are not classified as expensive
    return classify_compose_up(rest[i + 1:])


# Per-manager global options that appear BEFORE the subcommand. Value options
# consume the following token (separated form); flag options do not. Options in
# `--opt=value` form carry their own value. Unrecognized leading options are
# rejected rather than skipped, so a hidden subcommand cannot slip through.
NPM_VALUE_OPTS = {'--prefix', '--workspace', '-w', '--loglevel', '--location'}
NPM_FLAG_OPTS = {'--silent', '--global', '-g', '--quiet'}

PNPM_VALUE_OPTS = {'--dir', '-C', '--filter', '-F', '--loglevel'}
PNPM_FLAG_OPTS = {'--workspace-root', '-w', '--silent'}

YARN_VALUE_OPTS = {'--cwd'}
YARN_FLAG_OPTS = {'--silent', '--verbose'}

PIP_VALUE_OPTS = {'--python', '--log', '--cache-dir', '--proxy', '--timeout',
                  '--retries'}
PIP_FLAG_OPTS = {'--isolated', '--require-virtualenv', '--user', '--no-input',
                 '-q', '--quiet', '-v', '--verbose'}

PKG_MANAGERS = {
    'npm': (NPM_VALUE_OPTS, NPM_FLAG_OPTS, {'install', 'i', 'ci', 'add'}),
    'pnpm': (PNPM_VALUE_OPTS, PNPM_FLAG_OPTS, {'add', 'install', 'i'}),
    'yarn': (YARN_VALUE_OPTS, YARN_FLAG_OPTS, {'add', 'install'}),
    'pip': (PIP_VALUE_OPTS, PIP_FLAG_OPTS, {'install'}),
    'pip3': (PIP_VALUE_OPTS, PIP_FLAG_OPTS, {'install'}),
}

# Managers whose install detection does not need global-option normalization.
GENERIC_INSTALL = {
    'apt': {'install'}, 'apt-get': {'install'},
    'brew': {'install'},
    'gem': {'install'},
    'go': {'get', 'install'},
    'poetry': {'add', 'install', 'update'},
    'bun': {'install', 'add', 'i'},
}


def skip_pkg_options(rest, value_opts, flag_opts):
    """Skip leading global options to reach a package-manager subcommand.
    Returns (subcommand, args, error). error set => malformed/unrecognized,
    subcommand None with no error => no subcommand present."""
    i = 0
    while i < len(rest):
        a = rest[i]
        if a.startswith('-'):
            if '=' in a:
                i += 1
                continue
            if a in value_opts:
                if i + 1 >= len(rest):
                    return (None, [], "package-manager option missing its value")
                i += 2
                continue
            if a in flag_opts:
                i += 1
                continue
            return (None, [], "unrecognized package-manager option layout")
        return (a, rest[i + 1:], None)
    return (None, [], None)


def pkg_install_reason(tokens):
    """Classify a package-manager install after normalizing leading global
    options. Returns ('package-install', reason, alt),
    ('unclassifiable', reason, alt), or None."""
    if not tokens:
        return None
    cmd = tokens[0]
    rest = tokens[1:]

    ALT_INSTALL = "run dependency-review before installing"

    # Implicit package execution / dependency runners fetch and run packages,
    # so treat them like installation. Always blocked (not 'validation').
    if cmd in ('npx', 'uvx'):
        return ("package-install", "implicit package execution", ALT_INSTALL)
    if cmd == 'pipx' and rest[:1] in (['install'], ['run']):
        return ("package-install", "package installation", ALT_INSTALL)
    if cmd == 'npm' and rest[:1] == ['exec']:
        return ("package-install", "implicit package execution", ALT_INSTALL)
    if cmd in ('pnpm', 'yarn') and rest[:1] == ['dlx']:
        return ("package-install", "implicit package execution", ALT_INSTALL)

    # `python -m pip ...` routes to pip; `python -c ...` is unclassifiable.
    # Conservatively skip supported interpreter options before `-m pip`, so
    # `python3 -I -m pip install ...` is still detected.
    if cmd in ('python', 'python3'):
        i = 0
        found = False
        while i < len(rest):
            a = rest[i]
            if a == '-c':
                return ("unclassifiable", "inline python (-c) is too complex to classify",
                        "run a single, directly classifiable command")
            if a == '-m':
                if rest[i + 1:i + 2] == ['pip']:
                    cmd = 'pip'
                    rest = rest[i + 2:]
                    found = True
                    break
                return None
            if a in ('-X', '-W'):
                i += 2
                continue
            if a.startswith('-'):
                i += 1
                continue
            return None
        if not found:
            return None

    # uv: block dependency-modifying subcommands; leave `uv run` alone.
    if cmd == 'uv':
        if rest[:1] in (['add'], ['sync']):
            return ("package-install", "package installation", ALT_INSTALL)
        if rest[:2] in (['pip', 'install'], ['tool', 'install']):
            return ("package-install", "package installation", ALT_INSTALL)
        return None

    # cargo accepts a +toolchain selector before the subcommand.
    if cmd == 'cargo':
        if rest[:1] and rest[0].startswith('+'):
            rest = rest[1:]
        if rest[:1] in (['add'], ['install']):
            return ("package-install", "package installation",
                    "run dependency-review before installing")
        return None

    if cmd not in PKG_MANAGERS:
        return None

    value_opts, flag_opts, installs = PKG_MANAGERS[cmd]
    sub, _sargs, err = skip_pkg_options(rest, value_opts, flag_opts)
    if err:
        return ("unclassifiable", err, "run a single, directly classifiable command")
    # Bare yarn (no subcommand) installs all dependencies.
    if cmd == 'yarn' and sub is None:
        return ("package-install", "package installation",
                "run dependency-review before installing")
    if sub in installs:
        return ("package-install", "package installation",
                "run dependency-review before installing")
    return None


def classify_expensive(tokens):
    """Return (category, reason, alt) or None. Categories other than
    'validation' are always blocked; 'validation' may be bypassed only by the
    FULL_VALIDATION override."""
    if not tokens:
        return None
    cmd = tokens[0]
    rest = tokens[1:]

    # Common pytest wrappers route to the pytest scoped/full policy below.
    # Kept intentionally narrow: only these exact wrapper prefixes, not general
    # python or `uv run` interpretation.
    if cmd in ('python', 'python3') and rest[:2] == ['-m', 'pytest']:
        cmd = 'pytest'
        rest = rest[2:]
    elif cmd == 'uv' and rest[:2] == ['run', 'pytest']:
        cmd = 'pytest'
        rest = rest[2:]

    # Watch mode (only in relevant contexts; a bare -w is allowed).
    if '--watch' in tokens:
        return ("watch", "watch mode", "run a single, non-watch command")
    if cmd == 'cargo' and rest[:1] == ['watch']:
        return ("watch", "cargo watch", "run one targeted 'cargo test <name>'")
    if cmd in ('watchexec', 'nodemon'):
        return ("watch", "watch runner", "run a single, non-watch command")

    # Docker Compose (handles global options and value options).
    comp = classify_compose(tokens)
    if comp is not False and comp is not None:
        return ("compose", comp[0], comp[1])

    # Unscoped full test suites (validation).
    if cmd == 'pytest':
        targets = [t for t in rest if not t.startswith('-')]
        if not targets:
            return ("validation", "full pytest run", "pytest path/to/test_file.py::test_case")
    if cmd in ('npm', 'pnpm', 'yarn'):
        after = None
        if 'test' in rest:
            after = rest[rest.index('test') + 1:]
        elif rest[:2] == ['run', 'test']:
            after = rest[2:]
        if after is not None:
            targets = [t for t in after if t != '--' and not t.startswith('-')]
            if not targets:
                return ("validation", "full " + cmd + " test run", "test a single file or path")
    if cmd == 'cargo' and rest[:1] == ['test'] and ('--workspace' in rest or '--all' in rest):
        return ("validation", "full workspace test run", "cargo test -p <crate>")

    # Broad builds (validation).
    if cmd == 'cargo' and rest[:1] == ['build'] and ('--workspace' in rest or '--all' in rest):
        return ("validation", "broad workspace build", "build only the changed target")
    if cmd == 'make' and '-j' in rest:
        return ("validation", "unbounded parallel build (make -j)", "make -j<N> <target>")
    if cmd == 'bazel' and rest[:1] == ['build'] and '//...' in rest:
        return ("validation", "broad recursive bazel build", "build a specific target")

    # Package installation. Managers with global options (npm/pnpm/yarn/pip/
    # cargo, plus `python -m pip`) are normalized precisely; others use a
    # simple subcommand check.
    pkg = pkg_install_reason(tokens)
    if pkg is not None:
        return pkg
    if cmd in GENERIC_INSTALL and rest[:1] and rest[0] in GENERIC_INSTALL[cmd]:
        return ("package-install", "package installation", "run dependency-review before installing")

    return None


# Executable shell substitution is unclassifiable; always blocked, even under
# override. Checked on the whole command so it is caught within any segment.
if has_command_substitution(work):
    block("shell command or process substitution",
          "run one classifiable command without $(...), backticks, or <()/>()")

# An unquoted redirection to a raw device is destructive, checked on the raw
# segment before tokenization strips the redirect.
for rseg in segments_raw:
    if has_device_redirect(rseg):
        block("raw device write", "avoid device-level operations here")

# Tokenize and normalize each segment.
segments = []
for seg in segments_raw:
    toks = tokenize(seg)
    if not toks:
        continue
    norm, reject = normalize_wrappers(toks)
    if reject:
        # Unclassifiable (e.g. nested shell): always blocked, even override.
        block(reject, "run a single, directly classifiable command")
    # Obvious shell control / compound-command constructs are unclassifiable
    # and always blocked, even under the override.
    if norm and norm[0] in SHELL_CONTROL_TOKENS:
        block("shell control or compound-command construct",
              "run a single, directly classifiable command")
    segments.append(norm)

# Destructive commands are always blocked, even under override.
for seg in segments:
    if seg_is_destructive(seg):
        block("destructive command", "operate on specific paths, or use a soft/dry-run variant")

# Background '&' launches parallel work; always blocked, even under override.
if '&' in operators:
    block("parallel/background command with '&'", "run one command at a time")

# Every segment is classified. The override bypasses only the 'validation'
# category; package-install, watch, and compose are always blocked.
for seg in segments:
    r = classify_expensive(seg)
    if r is None:
        continue
    category, reason, alt = r
    if category == "validation" and override:
        continue
    block(reason, alt)

sys.exit(0)
PY
)

python3 -S -c "$PYPROG"
