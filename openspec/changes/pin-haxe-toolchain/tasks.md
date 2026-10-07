## 1. Compiler
- [x] 1.1 `tools/haxe-build.pin` with the build key and archive checksum
- [x] 1.2 `tools/setup.sh`: download, verify, install into the shared cache, link `.haxe`
- [x] 1.3 Fetch the test libraries by commit and write `.haxe-tests.hxml`

## 2. Serena
- [x] 2.1 Build the language server from source into the shared cache
- [x] 2.2 Generate the display config with every module of the source classpaths
- [x] 2.3 Write `.serena/project.local.yml` (and a minimal `project.yml` when missing), never over foreign overrides
- [x] 2.4 `.mcp.json` and `.codex/config.toml`

## 3. Rules
- [x] 3.1 `AGENTS.md`: toolchain section, checks on the pinned compiler
- [x] 3.2 `.github/infra-paths`: `tools/`, `.mcp.json`, `.codex/`
- [x] 3.3 `.gitignore`: `.haxe`, `.haxe-tests.hxml`

## 4. Verify
- [x] 4.1 Fresh worktree, empty cache: one command, `.haxe/haxe --version` is the pinned build
- [x] 4.2 `.haxe/haxe .serena/lsp.hxml --no-output` exits 0
- [x] 4.3 Serena `find_referencing_symbols` on a source symbol matches a text search; the server log has `Using --server-connect`
