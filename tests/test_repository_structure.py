"""Regression tests for the repository structure and invariants.

These tests validate the repository itself: the fixed set of skills, minimal
frontmatter fields, resolvable local links, retained shared policies, hook
permissions, README command coverage, and the absence of empty or junk files.

Frontmatter parsing is intentionally tiny and local: only the simple top-level
`key: value` fields this repository uses are read. No YAML dependency is added.
"""

import os
import re
import stat
import subprocess
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
HOOKS_DIR = REPO_ROOT / "hooks"
SHARED_DIR = REPO_ROOT / "shared"

EXPECTED_SKILLS = {
    "oss-bootstrap",
    "oss-plan",
    "implement-minimal",
    "test-and-debug",
    "dependency-review",
    "implementation-integrity",
    "public-code-review",
    "release-deploy",
}

LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


def skill_dirs():
    return sorted(p for p in SKILLS_DIR.iterdir() if p.is_dir())


def parse_frontmatter(text):
    """Parse a minimal leading '---' delimited frontmatter block.

    Returns a dict of top-level 'key: value' fields, or None when no
    frontmatter block is present.
    """
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    fields = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return fields
        if ":" in line and not line.startswith((" ", "\t", "-")):
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip()
    return None  # unterminated frontmatter


class TestSkillSet(unittest.TestCase):
    def test_exactly_eight_skill_directories(self):
        dirs = skill_dirs()
        self.assertEqual(len(dirs), 8, msg=f"found: {[d.name for d in dirs]}")

    def test_expected_skills_present(self):
        found = {d.name for d in skill_dirs()}
        self.assertEqual(found, EXPECTED_SKILLS)


class TestSkillFrontmatter(unittest.TestCase):
    def test_every_skill_md_non_empty(self):
        for skill in skill_dirs():
            with self.subTest(skill=skill.name):
                skill_md = skill / "SKILL.md"
                self.assertTrue(skill_md.is_file(), msg="missing SKILL.md")
                self.assertGreater(
                    skill_md.stat().st_size, 0, msg="SKILL.md is empty"
                )

    def test_required_frontmatter_fields(self):
        for skill in skill_dirs():
            with self.subTest(skill=skill.name):
                text = (skill / "SKILL.md").read_text(encoding="utf-8")
                fields = parse_frontmatter(text)
                self.assertIsNotNone(fields, msg="missing frontmatter block")
                self.assertIn("name", fields)
                self.assertTrue(fields["name"], msg="empty name")
                self.assertIn("description", fields)
                self.assertTrue(fields["description"], msg="empty description")
                self.assertEqual(
                    fields.get("disable-model-invocation"),
                    "true",
                    msg="disable-model-invocation must be true",
                )

    def test_skill_names_are_unique(self):
        names = []
        for skill in skill_dirs():
            text = (skill / "SKILL.md").read_text(encoding="utf-8")
            fields = parse_frontmatter(text) or {}
            names.append(fields.get("name"))
        self.assertEqual(len(names), len(set(names)), msg=f"names={names}")


class TestSkillReferences(unittest.TestCase):
    def test_local_markdown_links_resolve(self):
        for skill in skill_dirs():
            skill_md = skill / "SKILL.md"
            text = skill_md.read_text(encoding="utf-8")
            for target in LINK_RE.findall(text):
                target = target.strip()
                # Skip external links and pure anchors.
                if target.startswith(("http://", "https://", "mailto:", "#")):
                    continue
                # Drop any anchor fragment.
                path_part = target.split("#", 1)[0]
                if not path_part:
                    continue
                resolved = (skill_md.parent / path_part).resolve()
                with self.subTest(skill=skill.name, link=target):
                    self.assertTrue(
                        resolved.exists(), msg=f"broken link -> {resolved}"
                    )
                    if resolved.is_file():
                        self.assertGreater(
                            resolved.stat().st_size,
                            0,
                            msg=f"referenced file is empty -> {resolved}",
                        )

    def test_no_empty_reference_or_template_files(self):
        for skill in skill_dirs():
            for sub in ("references", "templates"):
                sub_dir = skill / sub
                if not sub_dir.is_dir():
                    continue
                for path in sorted(sub_dir.rglob("*")):
                    if path.is_file():
                        with self.subTest(path=str(path.relative_to(REPO_ROOT))):
                            self.assertGreater(
                                path.stat().st_size, 0, msg="empty file"
                            )


class TestSharedAndHooks(unittest.TestCase):
    def test_shared_policies_exist_non_empty(self):
        for name in ("LOW_RESOURCE.md", "CONTEXT_EFFICIENCY.md"):
            with self.subTest(policy=name):
                path = SHARED_DIR / name
                self.assertTrue(path.is_file(), msg=f"missing {name}")
                self.assertGreater(path.stat().st_size, 0, msg=f"empty {name}")

    def test_hooks_are_executable(self):
        for name in ("block-expensive-command.sh", "filter-command-output.sh"):
            with self.subTest(hook=name):
                path = HOOKS_DIR / name
                self.assertTrue(path.is_file(), msg=f"missing {name}")
                mode = path.stat().st_mode
                self.assertTrue(
                    mode & stat.S_IXUSR, msg=f"{name} not user-executable"
                )


class TestReadmeAndCleanliness(unittest.TestCase):
    def test_readme_mentions_all_manual_commands(self):
        readme = (REPO_ROOT / "README.md").read_text(encoding="utf-8")
        for skill in sorted(EXPECTED_SKILLS):
            with self.subTest(command=f"/{skill}"):
                self.assertIn(f"/{skill}", readme)

    def test_no_macos_junk_tracked(self):
        result = subprocess.run(
            ["git", "ls-files"],
            cwd=str(REPO_ROOT),
            capture_output=True,
            text=True,
            timeout=30,
        )
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        for rel in result.stdout.split("\n"):
            rel = rel.strip()
            if not rel:
                continue
            base = os.path.basename(rel)
            with self.subTest(path=rel):
                self.assertNotEqual(base, ".DS_Store")
                self.assertFalse(base.startswith("._"))
                self.assertNotIn("__MACOSX", rel)


if __name__ == "__main__":
    unittest.main()
