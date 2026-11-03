## 1. Pinned CLI and skills

- [ ] 1.1 Add `openspec/cli.pin` with `1.16.0` — check: `[ "$(cat openspec/cli.pin)" = "$(openspec --version)" ]`
- [ ] 1.2 Add `.claude/` and `.agents/` to `.github/infra-paths` (own commit) — check: `bash .github/scripts/check-commit-kinds-test.sh`
- [ ] 1.3 Generate the OpenSpec skills with the pinned CLI (`openspec init --tools claude,codex --profile custom`; propose, explore, continue, apply, update, ff, sync, archive, bulk-archive, verify) and commit them — check: `ls .claude/skills/openspec-* .agents/skills/openspec-*` lists ten skills in each, all `generatedBy: "1.16.0"`
- [ ] 1.4 AGENTS.md: the pin, the global install, the CI invocation, the one-commit bump, and that a change is created with `openspec new change` — check: reading

## 2. CI job

- [ ] 2.1 Add the `openspec` job to `.github/workflows/ci.yml`: the pinned CLI through `npm exec`, `openspec validate --all --strict`, the Purpose placeholder, `.openspec.yaml` of active changes, `generatedBy` of the skills, open non-`[human]` tasks of archived changes — check: the job is green on this branch; the script of the job run locally fails on a planted defect of each kind
- [ ] 2.2 AGENTS.md *Checks*: the OpenSpec check and how to run it locally — check: reading

## 3. Artifact rules

- [ ] 3.1 `openspec/config.yaml`: `rules.specs`, `rules.tasks`, `operations.apply` / `operations.archive` guidance pointing at AGENTS.md *Workflow* — check: `openspec instructions specs --change openspec-pinned-cli-gate` shows the rules; the job's config check passes

## 4. Main specs under `--strict`

- [ ] 4.1 Split the over-long requirements of `json-schema` and `tagged-enum` (this change's delta specs) — check: after sync, `openspec validate --all --strict` and `openspec validate --archived` report nothing

## Workflow follow-up

- Cross-review of the branch (`/ai-brainstorm:ai-review`), verify, sync specs and archive as the last commit of the branch.
- Merge into `master` after the checks, delete the branch and worktree, set J2O-26 done.
