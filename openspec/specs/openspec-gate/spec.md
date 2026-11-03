# openspec-gate Specification

## Purpose
Keep the OpenSpec tree valid at one pinned OpenSpec version: CI runs that version and fails on what `openspec validate --strict` and the archive leave unchecked.

## Requirements

### Requirement: OpenSpec runs at the pinned version
`openspec/cli.pin` SHALL hold exactly one OpenSpec version, and the CI `openspec` job SHALL run OpenSpec at that version.

#### Scenario: CI uses the pin
- **WHEN** `openspec/cli.pin` contains `1.16.0`
- **THEN** the `openspec` job runs `@fission-ai/openspec@1.16.0`

### Requirement: CI fails on any strict validation issue
The `openspec` CI job SHALL fail when `openspec validate --all --strict` reports an error or a warning.

#### Scenario: Over-long requirement
- **WHEN** a main spec holds a requirement whose text is longer than 500 characters
- **THEN** the `openspec` job fails

#### Scenario: Clean tree
- **WHEN** every main spec and active change validates under `--strict`
- **THEN** this step passes

### Requirement: Main specs have a real Purpose
The `openspec` CI job SHALL fail when the Purpose of a main spec under `openspec/specs/` begins with `TBD - created by archiving change`.

#### Scenario: Placeholder left by archive
- **WHEN** an archive creates a new main spec and its placeholder Purpose is committed
- **THEN** the `openspec` job fails and names the spec

### Requirement: Active changes are created by the CLI
The `openspec` CI job SHALL fail when a change directory under `openspec/changes/` other than `archive/` has no `.openspec.yaml`.

#### Scenario: Change written by hand
- **WHEN** `openspec/changes/foo/` holds `proposal.md` but no `.openspec.yaml`
- **THEN** the `openspec` job fails and names `openspec/changes/foo`

#### Scenario: Archived change without metadata
- **WHEN** a change under `openspec/changes/archive/` has no `.openspec.yaml`
- **THEN** this check does not fail on it

### Requirement: Committed skills match the pin
The `openspec` CI job SHALL fail when a committed OpenSpec skill (`.claude/skills/openspec-*/SKILL.md` or `.agents/skills/openspec-*/SKILL.md`) has no `generatedBy` or a `generatedBy` other than the version in `openspec/cli.pin`.

#### Scenario: Pin bumped without regenerating
- **WHEN** `openspec/cli.pin` says `1.17.0` and a skill says `generatedBy: "1.16.0"`
- **THEN** the `openspec` job fails and names the skill

### Requirement: Archived changes leave only human tasks open
The `openspec` CI job SHALL fail when a `tasks.md` of an archived change holds an unchecked task that is not marked `[human]` right after its number.

#### Scenario: Forgotten task
- **WHEN** an archived `tasks.md` holds `- [ ] 2.1 Add a test`
- **THEN** the `openspec` job fails and names the file and line

#### Scenario: Human task
- **WHEN** an archived `tasks.md` holds `- [ ] 3.1 [human] Check the editor`
- **THEN** this check does not fail on it
