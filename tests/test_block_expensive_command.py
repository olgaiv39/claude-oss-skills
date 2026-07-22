"""Regression tests for hooks/block-expensive-command.sh.

The hook is treated as a black-box executable. Synthetic Claude Code
PreToolUse JSON payloads are sent on stdin. Fixture command strings are never
executed by the test; they only travel inside the JSON payload the hook reads.

Contract under test (from the hook header):
  - Allowed command:                  exit 0
  - Blocked command:                  exit 2 (concise reason on stderr)
  - Non-Bash tool:                    exit 0
  - Unparseable input or no command:  exit 2 (fail closed)
"""

import json
import subprocess
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
HOOK = REPO_ROOT / "hooks" / "block-expensive-command.sh"

ALLOWED = 0
BLOCKED = 2

# Commands the hook must allow (exit 0). These strings are payload data only.
ALLOWED_COMMANDS = [
    "grep -w error logfile",
    "pytest tests/test_small.py -q",
    "cargo test test_name",
    "docker compose up -d api",
    "CI=1 pytest tests/test_small.py -q",
    "FULL_VALIDATION=1 npm test",
    "FULL_VALIDATION=1 cargo test --workspace",
    'echo "rm -rf"',
    "cp /dev/sdb backup.img",
    # Scoped pytest wrappers follow the scoped/full policy: a targeted path
    # is allowed.
    "python -m pytest tests/test_small.py -q",
    "python3 -m pytest tests/test_small.py -q",
    "uv run pytest tests/test_small.py -q",
    # The override bypasses only the validation category, including the
    # full-suite pytest wrappers.
    "FULL_VALIDATION=1 python -m pytest",
    "FULL_VALIDATION=1 python3 -m pytest",
    "FULL_VALIDATION=1 uv run pytest",
]

# Commands the hook must block (exit 2). These strings are payload data only.
BLOCKED_COMMANDS = [
    "pytest",
    "npm test",
    "npm install lodash",
    "CI=1 npm install lodash",
    "python3 -I -m pip install foo",
    "uv add package",
    "poetry install",
    "bun install",
    "docker compose up -d",
    "docker compose up --build api",
    "sleep 10&",
    "rm -rf build",
    "git -C repo clean -fdx",
    "cp image.iso /dev/sdb",
    "FULL_VALIDATION=1 npm install lodash",
    "FULL_VALIDATION=1 docker compose up -d",
    "FULL_VALIDATION=1 rm -rf build",
    # Multiline commands are unclassifiable and fail closed.
    "echo ok\nrm -rf build",
    "echo ok\nnpm install lodash",
    "echo ok\npytest",
    # Obvious shell control / compound-command constructs fail closed.
    'eval "rm -rf build"',
    "{ rm -rf build; }",
    "if true; then rm -rf build; fi",
    # Implicit package execution and installation paths.
    "npx prettier --write .",
    "npm exec --yes prettier -- --write .",
    "pnpm dlx prettier --write .",
    "yarn dlx prettier --write .",
    "uvx ruff check .",
    "pipx install black",
    "cargo install cargo-watch",
    "go install example.com/tool@latest",
    # Common pytest wrappers, unscoped full runs.
    "python -m pytest",
    "python3 -m pytest",
    "uv run pytest",
]

# The override bypasses only the validation category; it must never bypass the
# package or unclassifiable categories. These strings are payload data only.
OVERRIDE_STILL_BLOCKED_COMMANDS = [
    # Package / implicit-execution paths.
    "FULL_VALIDATION=1 npx prettier --write .",
    "FULL_VALIDATION=1 uvx ruff check .",
    "FULL_VALIDATION=1 pipx install black",
    "FULL_VALIDATION=1 cargo install cargo-watch",
    "FULL_VALIDATION=1 go install example.com/tool@latest",
    # Unclassifiable: shell control and multiline.
    'FULL_VALIDATION=1 eval "rm -rf build"',
    "FULL_VALIDATION=1 echo ok\npytest",
]


def run_hook(stdin_text):
    """Run the block hook with the given raw stdin and return CompletedProcess."""
    return subprocess.run(
        [str(HOOK)],
        input=stdin_text,
        capture_output=True,
        text=True,
        timeout=30,
    )


def bash_payload(command, run_in_background=None):
    """Build a Bash PreToolUse JSON payload string."""
    tool_input = {"command": command}
    if run_in_background is not None:
        tool_input["run_in_background"] = run_in_background
    return json.dumps({"tool_name": "Bash", "tool_input": tool_input})


class TestAllowedCommands(unittest.TestCase):
    def test_allowed_commands_exit_zero(self):
        for command in ALLOWED_COMMANDS:
            with self.subTest(command=command):
                result = run_hook(bash_payload(command))
                self.assertEqual(
                    result.returncode,
                    ALLOWED,
                    msg=f"expected allow (0); stderr={result.stderr!r}",
                )


class TestBlockedCommands(unittest.TestCase):
    def test_blocked_commands_exit_two_with_reason(self):
        for command in BLOCKED_COMMANDS:
            with self.subTest(command=command):
                result = run_hook(bash_payload(command))
                self.assertEqual(
                    result.returncode,
                    BLOCKED,
                    msg=f"expected block (2); stderr={result.stderr!r}",
                )
                # A concise reason must exist; exact wording is not asserted.
                self.assertTrue(
                    result.stderr.strip(),
                    msg="blocked command must emit a concise reason on stderr",
                )


class TestOverrideDoesNotBypass(unittest.TestCase):
    def test_override_does_not_bypass_package_or_unclassifiable(self):
        for command in OVERRIDE_STILL_BLOCKED_COMMANDS:
            with self.subTest(command=command):
                result = run_hook(bash_payload(command))
                self.assertEqual(
                    result.returncode,
                    BLOCKED,
                    msg=f"expected block (2); stderr={result.stderr!r}",
                )
                self.assertTrue(result.stderr.strip())


class TestStructuredInput(unittest.TestCase):
    def test_run_in_background_true_is_blocked(self):
        result = run_hook(bash_payload("grep -w error logfile", run_in_background=True))
        self.assertEqual(result.returncode, BLOCKED)
        self.assertTrue(result.stderr.strip())

    def test_run_in_background_false_allows_safe_command(self):
        result = run_hook(bash_payload("grep -w error logfile", run_in_background=False))
        self.assertEqual(result.returncode, ALLOWED)

    def test_non_boolean_background_value_is_blocked(self):
        # Build the payload by hand so the value is a non-boolean type.
        payload = json.dumps(
            {
                "tool_name": "Bash",
                "tool_input": {
                    "command": "grep -w error logfile",
                    "run_in_background": "yes",
                },
            }
        )
        result = run_hook(payload)
        self.assertEqual(result.returncode, BLOCKED)
        self.assertTrue(result.stderr.strip())

    def test_invalid_json_is_blocked(self):
        result = run_hook("this is not json")
        self.assertEqual(result.returncode, BLOCKED)
        self.assertTrue(result.stderr.strip())

    def test_missing_command_is_blocked(self):
        payload = json.dumps({"tool_name": "Bash", "tool_input": {}})
        result = run_hook(payload)
        self.assertEqual(result.returncode, BLOCKED)
        self.assertTrue(result.stderr.strip())

    def test_non_bash_tool_is_allowed(self):
        # A non-Bash event is allowed even if it carries a blockable command.
        payload = json.dumps(
            {"tool_name": "Read", "tool_input": {"command": "pytest"}}
        )
        result = run_hook(payload)
        self.assertEqual(result.returncode, ALLOWED)


if __name__ == "__main__":
    unittest.main()
