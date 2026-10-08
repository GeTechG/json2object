## 1. Setup
- [x] 1.1 `tools/setup.sh`: install the pinned `ast-grep` and build the pinned grammar into the shared cache, link `.ast-grep/`
- [x] 1.2 `sgconfig.yml` with the `haxe` custom language
- [x] 1.3 `.gitignore`: `.ast-grep`
- [x] 1.4 `.github/infra-paths`: `sgconfig.yml`

## 2. Rules
- [x] 2.1 `AGENTS.md`: `ast-grep` in the toolchain section — when it, when Serena, when a text search

## 3. Verify
- [x] 3.1 Empty cache: one command, `.ast-grep/ast-grep --version` is the pinned version, `git status` shows no change
- [x] 3.2 `throw new $T($$$A)` over `src` matches the same lines as a text search for `throw new`
- [x] 3.3 Number of tracked `.hx` files with an `ERROR` node is known
