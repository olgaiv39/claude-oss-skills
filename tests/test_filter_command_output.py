"""Regression tests for hooks/filter-command-output.sh.

The hook is treated as a black-box pipe utility. Each test uses a private
TMPDIR so the retained log can be inspected and is cleaned up afterward. Log
content is passed as inert stdin data and is never executed by the test.

Contract under test (from the hook header):
  - Usage: filter-command-output.sh EXIT_STATUS  (status 0-255 required)
  - Saves full input to a retained temp log and prints its path.
  - Prints bounded failure context and a bounded tail.
  - Exits with the supplied EXIT_STATUS on success; exits 2 if the filter
    itself cannot process the input or a bound/argument is invalid.
"""

import os
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
HOOK = REPO_ROOT / "hooks" / "filter-command-output.sh"

FULL_LOG_RE = re.compile(r"Full log:\s+(\S+)")
NUMBERED_LINE_RE = re.compile(r"^(\d+):", re.MULTILINE)


class FilterHookTestCase(unittest.TestCase):
    def setUp(self):
        # Private TMPDIR so the hook writes its retained log where the test can
        # inspect and remove it.
        self._tmp = tempfile.TemporaryDirectory()
        self.tmpdir = self._tmp.name

    def tearDown(self):
        self._tmp.cleanup()

    def run_hook(self, exit_status, stdin_text, extra_env=None):
        env = dict(os.environ)
        env["TMPDIR"] = self.tmpdir
        if extra_env:
            env.update(extra_env)
        return subprocess.run(
            [str(HOOK), str(exit_status)],
            input=stdin_text,
            capture_output=True,
            text=True,
            env=env,
            timeout=30,
        )

    def full_log_path(self, stdout):
        match = FULL_LOG_RE.search(stdout)
        self.assertIsNotNone(match, msg="output must contain a full-log path")
        return match.group(1)


class TestBasicContract(FilterHookTestCase):
    def test_empty_input_returns_supplied_status(self):
        result = self.run_hook(0, "")
        self.assertEqual(result.returncode, 0)
        self.assertIn("Full log:", result.stdout)

    def test_successful_input_returns_status_zero(self):
        result = self.run_hook(0, "all good here\nsecond line\n")
        self.assertEqual(result.returncode, 0)

    def test_failing_input_returns_status_seven(self):
        result = self.run_hook(7, "some output\nmore output\n")
        self.assertEqual(result.returncode, 7)

    def test_input_without_final_newline_is_processed(self):
        result = self.run_hook(0, "line without trailing newline")
        self.assertEqual(result.returncode, 0)
        self.assertIn("line without trailing newline", result.stdout)


class TestSummaryContent(FilterHookTestCase):
    def test_failure_markers_appear_in_output(self):
        stdin_text = "starting\nfatal error occurred\ndone\n"
        result = self.run_hook(7, stdin_text)
        self.assertEqual(result.returncode, 7)
        self.assertIn("failure context", result.stdout)
        self.assertIn("fatal error occurred", result.stdout)

    def test_output_contains_retained_full_log_path(self):
        result = self.run_hook(3, "content line\nanother line\n")
        self.assertEqual(result.returncode, 3)
        log_path = self.full_log_path(result.stdout)
        self.assertTrue(Path(log_path).is_file(), msg="retained log must exist")


class TestInvalidArguments(FilterHookTestCase):
    def test_invalid_exit_status_returns_two(self):
        result = self.run_hook("abc", "content\n")
        self.assertEqual(result.returncode, 2)
        self.assertTrue(result.stderr.strip())

    def test_invalid_bound_environment_variable_returns_two(self):
        result = self.run_hook(0, "content\n", extra_env={"CONTEXT_BEFORE": "abc"})
        self.assertEqual(result.returncode, 2)
        self.assertTrue(result.stderr.strip())


class TestBoundingAndSafety(FilterHookTestCase):
    def test_large_input_produces_bounded_output(self):
        # Many lines, no failure markers: only the bounded tail is displayed.
        line_count = 5000
        stdin_text = "".join(f"routine line {i}\n" for i in range(line_count))
        result = self.run_hook(0, stdin_text)
        self.assertEqual(result.returncode, 0)
        numbered = NUMBERED_LINE_RE.findall(result.stdout)
        # Default TAIL_LINES is 40; displayed numbered lines stay bounded well
        # below the input size.
        self.assertLessEqual(len(numbered), 60)
        self.assertLess(len(numbered), line_count)

    def test_context_and_tail_do_not_duplicate_source_lines(self):
        # Place a marker inside the tail window so its context range overlaps
        # the tail. The hook must not emit the same source line twice.
        lines = [f"line {i}" for i in range(1, 46)]
        lines[43] = "line 44 error here"  # marker within the last 40 lines
        stdin_text = "\n".join(lines) + "\n"
        result = self.run_hook(7, stdin_text)
        self.assertEqual(result.returncode, 7)
        numbered = NUMBERED_LINE_RE.findall(result.stdout)
        self.assertEqual(
            len(numbered),
            len(set(numbered)),
            msg="a source line number was emitted more than once",
        )

    def test_command_looking_text_is_not_executed(self):
        sentinel = Path(self.tmpdir) / "sentinel_should_not_exist"
        # Command-looking text is inert log data; the hook must not run it.
        stdin_text = f"error: failure\ntouch {sentinel}\n$(touch {sentinel})\n"
        result = self.run_hook(7, stdin_text)
        self.assertEqual(result.returncode, 7)
        self.assertFalse(
            sentinel.exists(),
            msg="log content must never be executed by the filter",
        )


if __name__ == "__main__":
    unittest.main()
