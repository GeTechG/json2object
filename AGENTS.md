# json2object — agent guide

Independent fork of `elnabo/json2object` (type safe Haxe/JSON (de)serializer). Its consumers pin it by commit; they do not dictate how it is worked on. This file is the source of truth here.

## Commits
- Every commit is **code** (library sources under `src/`, tests under `tests/`, upstream metadata) or **infrastructure** (the paths listed in `.github/infra-paths`: this file, `openspec/`, `tools/`, our CI and scripts). Never both — CI rejects a mixed commit.
- Code commit messages are written as for upstream `elnabo/json2object`: a plain imperative summary of the library change, no mention of consumers or their paths.
- OpenSpec artifacts (proposal, tasks, specs, archive) are infrastructure commits and never share a commit with code.
- An upstream PR is a cherry-pick of one task's code commits; keep them self-contained — they must build and pass the tests without any infrastructure commit.
- Changing the list of infrastructure paths is an infrastructure commit.

## Toolchain
- `bash tools/setup.sh` — run once per checkout or worktree, and again after adding or removing source files; restart Serena afterwards. It installs the pinned compiler behind the gitignored `.haxe` symlink, fetches the test libraries, writes the test config `.haxe-tests.hxml` and Serena's config under `.serena/`, and installs `ast-grep` with a Haxe grammar under `.ast-grep/`. Linux x86_64 only.
- **Build, type and run the tests only with this compiler**: `.haxe/haxe` with `HAXE_STD_PATH=.haxe/std`. Never the system Haxe 4.x.
- The compiler is a Haxe 5 build of `GeTechG/haxe`, pinned in `tools/haxe-build.pin` (`<build key> <sha256 of the archive>`). Changing the compiler is one commit that changes this file.
- Serena (`.mcp.json`, `.codex/config.toml`) navigates symbols through a language server on the same compiler. Its reference lists are not exhaustive, and shrink further when a module listed in `.serena/lsp.hxml` does not compile (`.haxe/haxe .serena/lsp.hxml --no-output` must exit 0): before a rename, check them against a text search. `tests/` is part of that config, so uses in tests are found (`BaseParser.fromJson`: all 13 test files). What the compiler never reports: a use of a `@:genericBuild` type (`JsonParser`, `JsonWriter` — every `new json2object.JsonParser<…>()` is typed as the class the macro builds, so these two have zero references; `JsonSchemaWriter` is found through its `#if display` stub, name path `JsonSchemaWriter[0]`), an enum constructor in a `case` pattern, and an `import` line.
- `ast-grep` (`.ast-grep/ast-grep`, config `sgconfig.yml`; version and grammar commit — `GeTechG/tree-sitter-haxe` — are pinned in `tools/setup.sh`) searches the Haxe code by shape. Three tools, three questions: Serena — where is this symbol and who references it; `ast-grep` — where does code of this shape occur, and a bulk rewrite by pattern (`.ast-grep/ast-grep run -p 'throw new $T($$$A)' -l haxe src`; add `-r '<replacement>'`, review the diff it prints, then `-U` to apply); a text search — a literal string, a non-Haxe file, and everything Serena does not report. A pattern that matches nothing may itself not parse as a Haxe fragment (`--debug-query=ast` shows an `ERROR` node): match by node kind instead (`--kind <kind>`, or a rule file). A search may miss code in a file the grammar cannot parse — `.ast-grep/ast-grep run --kind ERROR -l haxe .` lists them (none today) — and inside an `#if` branch that is not the first (`--kind conditional_inactive`; today only the `final`/`var` switch in `src/json2object/Error.hx`): confirm there with a text search.

## Checks
Run before pushing:
- `bash .github/scripts/check-commit-kinds-test.sh` — self-test of the commit-kind check.
- `bash .github/scripts/check-commit-kinds.sh origin/master..HEAD` — the check on your branch.
- `HAXE_STD_PATH=.haxe/std .haxe/haxe .haxe-tests.hxml` — the test suite on the interpreter, with the pinned compiler (see *Toolchain*); must end with `ALL TESTS OK`.

CI (`.github/workflows/ci.yml`) runs the same commit-kind check and test suite, plus the suite on Haxe 4.3.7 (job `test-haxe4`): upstream builds with Haxe 4, so code commits must stay green there too. That job is the one place Haxe 4 is used.

## Specs
`openspec/` holds this fork's own specs (`openspec/specs/`). Behaviour or rule changes go through `openspec/changes/`.

## Workflow
No pull requests: this fork is worked on solo. Work lives on branches and lands on `master` by rebase or merge; the only mandatory gate is green checks (see *Checks*) on the exact tree that lands. Work is scheduled by baton — load the `/baton` skill before filing or picking up an issue, or changing an issue's status, labels, `footprint` or blockers.

An issue runs the same seven steps, in order:

1. **OpenSpec change.** Branch `change/<ISSUE-KEY>-<openspec-name>` from `origin/master` — one task, one branch — and write the change under `openspec/changes/`. Skip the OpenSpec change — here and in step 3 — when the work is mechanical, i.e. nothing the project history needs a record of (docs, renames, config, a bug fix that returns behaviour to what a spec already states). Anything else that touches behaviour is not mechanical — the change is mandatory. A missing spec is never a reason to skip: when `openspec/specs/` does not yet cover the behaviour the task touches, the change adds that spec as a new capability, so the next task has it to work against. A skip is never silent: the report on the issue carries the line `OpenSpec skipped: <reason>`. The other steps stay. An issue labeled `gate:spec` stops here: push the artifacts, post a short plan on the issue, add `needs-human`; continue once the maintainer swaps it for `spec:approved`.
2. **Implement** the tasks.
3. **Test.** Verify the implementation against the change, then sync its specs and archive it as the **last commit of the branch** (never a separate push to `master`), rebase onto current `master` and run the checks. Unless the task is trivial (mechanical, or a few obvious lines), finish with a cross-review of the whole branch diff before the checks — `/ai-brainstorm:ai-review`, a judge from another model family — and fix or rebut its findings until clean.
4. **Human QA — only if the change has it.** Steps only a human can do are written `- [ ] N.M [human] …` in `tasks.md`; agents never tick them. If there are any, post them on the issue as a checklist a human can follow cold, add `needs-human` and stop; continue once the maintainer removes the label. No `[human]` tasks → skip.
5. **Merge** into `master`: `git merge --ff-only` for a single commit or a short linear series, `git merge --no-ff` for a multi-commit change. Push `master`. If `master` moved since the checks ran, rebase and run them again first.
6. **Clean up**: delete the branch (local and remote) and its worktree.
7. **Set the issue done.**

The maintainer decides architecture and end-user behaviour, nothing else — steps 1 (`gate:spec`) and 4 are the only points where an agent waits for a human. Work without an issue: mechanical edits may go straight to `master`.
