# json2object — agent guide

Independent fork of `elnabo/json2object` (type safe Haxe/JSON (de)serializer). Its consumers pin it by commit; they do not dictate how it is worked on. This file is the source of truth here.

## Commits
- Every commit is **code** (library sources under `src/`, tests under `tests/`, upstream metadata) or **infrastructure** (the paths listed in `.github/infra-paths`: this file, `openspec/`, our CI and scripts). Never both — CI rejects a mixed commit.
- Code commit messages are written as for upstream `elnabo/json2object`: a plain imperative summary of the library change, no mention of consumers or their paths.
- OpenSpec artifacts (proposal, tasks, specs, archive) are infrastructure commits and never share a commit with code.
- An upstream PR is a cherry-pick of one task's code commits; keep them self-contained — they must build and pass the tests without any infrastructure commit.
- Changing the list of infrastructure paths is an infrastructure commit.

## Checks
Run before pushing:
- `bash .github/scripts/check-commit-kinds-test.sh` — self-test of the commit-kind check.
- `bash .github/scripts/check-commit-kinds.sh origin/master..HEAD` — the check on your branch.
- `haxe tests/build/build_interp.hxml` — the test suite on the interpreter (needs `haxelib install hxjsonast` and `haxelib install utest`); must end with `ALL TESTS OK`. Haxe version is pinned in `.github/workflows/ci.yml`.

## Specs
`openspec/` holds this fork's own specs (`openspec/specs/`). Behaviour or rule changes go through `openspec/changes/`.

## Delivery
- **One task — one branch**, cut from `master`. A branch carries one task only; a second task gets its own branch.
- Deliver through a PR to `master`; never push to `master` directly.
