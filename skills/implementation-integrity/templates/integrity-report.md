# Implementation Integrity Report

## Verdict

<one of: integrity confirmed for tested scope | integrity partially confirmed | integrity not confirmed | blocking integrity issue found>

## Task and acceptance criteria

- <criterion, marked (supplied) or (inferred)>

## Baseline

- <working tree vs HEAD | commit vs parent | branch vs supplied base | supplied diff range>

## Changed-file inventory

- <path> - <added | modified | deleted | renamed | untracked | mode change | symlink>

## Artifact audit

| Path | Purpose | Requirement | Necessary | Evidence | Classification |
| --- | --- | --- | --- | --- | --- |
| <path> | <claimed purpose> | <requirement> | <yes/no> | <evidence> | <classification> |

## Integrity findings

| Severity | File | Location | Evidence | Integrity risk | Legitimate explanation considered | Smallest repair |
| --- | --- | --- | --- | --- | --- | --- |
| <severity> | <file> | <location> | <evidence> | <risk> | <explanation> | <repair> |

## Potential cheating patterns

- <pattern> -> <evidence, or potential integrity issue: unresolved intent>

## Requirement-to-evidence mapping

| Acceptance criterion | Public implementation path | Validation evidence | Result | Remaining uncertainty |
| --- | --- | --- | --- | --- |
| <criterion> | <public path> | <evidence> | <met | not met | unproven> | <uncertainty> |

## Independent validation performed

- <command or trace> -> <observed result and exit status>

## Validation not performed

- <check> -> <reason it was skipped>

## Publication blockers

- <blocker, or none>

## Requires human judgment

- <item, or none>

## Remaining uncertainty

- <what this audit did not establish>
