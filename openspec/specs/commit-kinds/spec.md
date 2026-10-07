# commit-kinds Specification

## Purpose
Keep every commit either upstreamable code or fork infrastructure, so an upstream PR is a cherry-pick of one task's code commits.

## Requirements

### Requirement: A commit is code or infrastructure, never both
Infrastructure is the set of paths listed in `.github/infra-paths` (paths absent from upstream); every other path is code. CI SHALL reject any non-merge commit that touches both kinds.

#### Scenario: Mixed commit
- **WHEN** a commit changes `src/json2object/reader/DataBuilder.hx` and `AGENTS.md`
- **THEN** the `commit-kinds` CI job fails and names the commit

#### Scenario: OpenSpec artifact next to code
- **WHEN** a commit changes `tests/MapTest.hx` and a file under `openspec/changes/`
- **THEN** the `commit-kinds` CI job fails and names the commit

#### Scenario: Single-kind commit
- **WHEN** a commit changes only code paths, or only infrastructure paths
- **THEN** the check passes

### Requirement: The check proves itself
`.github/scripts/check-commit-kinds-test.sh` SHALL build a throwaway repository with a mixed commit and fail unless the check rejects it; CI runs it before the real check.

#### Scenario: Check stops rejecting mixed commits
- **WHEN** `.github/scripts/check-commit-kinds.sh` accepts the mixed commit of the throwaway repository
- **THEN** `.github/scripts/check-commit-kinds-test.sh` exits non-zero with `FAIL: mixed commit accepted`
