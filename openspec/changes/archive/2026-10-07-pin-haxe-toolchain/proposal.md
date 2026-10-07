## Why
The fork does not say which compiler builds it, and Serena is not wired up: an agent types the code with whatever Haxe 4.x the machine has and works without symbol navigation.

## What Changes
- The compiler is a Haxe 5 build of `GeTechG/haxe`, pinned in the tracked file `tools/haxe-build.pin`.
- One command, `bash tools/setup.sh`, prepares a checkout: it installs the pinned build behind the gitignored `.haxe` symlink, fetches the test libraries, writes the test config and wires Serena to a Haxe language server that talks to the same compiler.
- `AGENTS.md`: build, type and test only with the pinned compiler; language-server reference lists are checked against a text search before a rename.
- Serena is registered for Claude Code (`.mcp.json`) and Codex (`.codex/config.toml`).
- `tools/`, `.mcp.json` and `.codex/` become infrastructure paths.

## Capabilities
### New Capabilities
- `toolchain`: the pinned compiler, the setup command and the code navigation it provides.

## Impact
No library source changes. `tests/build/*.hxml` stay as upstream has them; the pinned compiler runs the generated `.haxe-tests.hxml` instead. CI (`.github/workflows/ci.yml`) is not touched by this change.
