#!/bin/sh
# filter-command-output.sh
# Standalone pipe utility (not a native Claude Code hook) that reduces large
# command output before it reaches Claude.
#
# Usage:
#   filter-command-output.sh EXIT_STATUS
#
#   - EXIT_STATUS is required: the original command's exit status (0-255).
#   - Reads raw command output from stdin.
#   - Saves the complete input to a retained temporary log.
#   - Prints a concise summary: bounded context around failure markers and a
#     bounded tail, plus the full log path.
#   - Exits with the supplied EXIT_STATUS on success. If the filter itself
#     cannot process the log, it exits 2 instead of the supplied status.
#
# A pipeline cannot recover an upstream exit status; the caller must pass it.
# See README.md for a safe single-execution invocation example.
#
# Memory is bounded: the log is read from disk in two passes and only a
# bounded amount of context and tail is buffered, so memory does not grow
# with total log length. The full log remains on disk.

set -u

CONTEXT_BEFORE="${CONTEXT_BEFORE:-3}"
CONTEXT_AFTER="${CONTEXT_AFTER:-3}"
TAIL_LINES="${TAIL_LINES:-40}"
MAX_MATCH_BLOCKS="${MAX_MATCH_BLOCKS:-20}"

is_uint() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) return 0 ;;
    esac
}

if [ "$#" -lt 1 ]; then
    echo "usage: filter-command-output.sh EXIT_STATUS" >&2
    exit 2
fi

status="$1"
if ! is_uint "$status" || [ "$status" -gt 255 ]; then
    echo "filter-command-output: EXIT_STATUS must be an integer 0-255" >&2
    exit 2
fi

# Validate tunable bounds so a bad value cannot produce a misleading summary.
if ! is_uint "$CONTEXT_BEFORE" || [ "$CONTEXT_BEFORE" -gt 1000 ]; then
    echo "filter-command-output: CONTEXT_BEFORE must be an integer 0-1000" >&2
    exit 2
fi
if ! is_uint "$CONTEXT_AFTER" || [ "$CONTEXT_AFTER" -gt 1000 ]; then
    echo "filter-command-output: CONTEXT_AFTER must be an integer 0-1000" >&2
    exit 2
fi
if ! is_uint "$TAIL_LINES" || [ "$TAIL_LINES" -gt 100000 ]; then
    echo "filter-command-output: TAIL_LINES must be an integer 0-100000" >&2
    exit 2
fi
if ! is_uint "$MAX_MATCH_BLOCKS" || [ "$MAX_MATCH_BLOCKS" -gt 100000 ]; then
    echo "filter-command-output: MAX_MATCH_BLOCKS must be an integer 0-100000" >&2
    exit 2
fi

log_file=$(mktemp "${TMPDIR:-/tmp}/claude-cmd-output.XXXXXX") || {
    echo "filter-command-output: cannot create temp file" >&2
    exit 2
}

cat > "$log_file" || {
    echo "filter-command-output: failed to read input" >&2
    exit 2
}

# Non-empty detection independent of a trailing newline: -s is true for any
# file with at least one byte.
if [ ! -s "$log_file" ]; then
    echo "filter-command-output: no output received (status $status)"
    echo "Full log: $log_file"
    exit "$status"
fi

# Pass A: stream the log, collect up to MAX_MATCH_BLOCKS marker line numbers,
# and emit the final line count plus merged context ranges. Memory is bounded
# by MAX_MATCH_BLOCKS, not by total log length.
meta=$(awk -v before="$CONTEXT_BEFORE" -v after="$CONTEXT_AFTER" \
    -v maxblocks="$MAX_MATCH_BLOCKS" '
{
    low = tolower($0)
    if (m < maxblocks && low ~ /error|failed|failure|exception|panic|traceback|stack trace/) {
        marks[++m] = NR
    }
}
END {
    print NR
    lastend = 0
    for (k = 1; k <= m; k++) {
        c = marks[k]
        s = c - before; if (s < 1) s = 1
        e = c + after; if (e > NR) e = NR
        if (s <= lastend) s = lastend + 1
        if (s > e) continue
        print s " " e
        lastend = e
    }
}' "$log_file") || {
    echo "filter-command-output: failed to summarize log; full log at $log_file" >&2
    exit 2
}

# First line of meta is the total line count; the rest are "start end" ranges.
total_lines=$(printf '%s\n' "$meta" | sed -n '1p')
ranges=$(printf '%s\n' "$meta" | sed -n '2,$p' | tr '\n' ';')

if ! is_uint "$total_lines"; then
    echo "filter-command-output: internal summarization error; full log at $log_file" >&2
    exit 2
fi

# Tail start line: the last TAIL_LINES lines of the log.
if [ "$TAIL_LINES" -eq 0 ]; then
    tail_start=$((total_lines + 1))
else
    tail_start=$((total_lines - TAIL_LINES + 1))
    if [ "$tail_start" -lt 1 ]; then
        tail_start=1
    fi
fi

echo "=== Command output summary ($total_lines lines, status $status) ==="

# Pass B: stream again, printing context lines inline and buffering the tail.
# A source line that already appears in a context range is not repeated in the
# tail, so the same source line number is never emitted twice. Tail buffer is
# bounded by TAIL_LINES.
awk -v ranges="$ranges" -v tstart="$tail_start" -v tailn="$TAIL_LINES" '
BEGIN {
    nr = 0
    if (length(ranges) > 0) {
        cnt = split(ranges, parts, ";")
        for (p = 1; p <= cnt; p++) {
            if (parts[p] == "") continue
            split(parts[p], se, " ")
            nr++
            rs[nr] = se[1] + 0
            re[nr] = se[2] + 0
        }
    }
}
function in_ctx(n,   p) {
    for (p = 1; p <= nr; p++) {
        if (n >= rs[p] && n <= re[p]) return 1
    }
    return 0
}
{
    if (in_ctx(NR)) {
        if (!ctx_header) { print "--- failure context ---"; ctx_header = 1 }
        print NR ": " $0
    } else if (tailn > 0 && NR >= tstart) {
        tb[++tc] = NR ": " $0
    }
}
END {
    if (nr == 0) {
        print "(no failure markers found)"
    }
    if (tc > 0) {
        print "--- last " tailn " lines ---"
        for (i = 1; i <= tc; i++) print tb[i]
    }
}' "$log_file" || {
    echo "filter-command-output: failed to render summary; full log at $log_file" >&2
    exit 2
}

echo "=== Full log: $log_file ==="

exit "$status"
