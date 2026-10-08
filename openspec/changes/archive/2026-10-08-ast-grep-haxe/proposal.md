## Why
An agent in this checkout cannot search the code by its shape: `ast-grep` knows no Haxe without a grammar, and the project ships neither the grammar nor a config. Serena answers "who references this symbol", a text search answers "where is this string"; "where does code of this shape occur" has no tool.

## What Changes
- `bash tools/setup.sh` also installs `ast-grep` at a pinned version (the npm package `@ast-grep/cli`: node and npm are already required for the language server) and builds the `GeTechG/tree-sitter-haxe` grammar at a pinned commit, both into the shared per-pin cache, and links them as the gitignored `.ast-grep/ast-grep` and `.ast-grep/haxe.so`. The setup now needs a C compiler (`cc`).
- `sgconfig.yml` at the root registers the grammar as the language `haxe` for `*.hx`.
- `AGENTS.md`: when to use `ast-grep`, when Serena, when a text search.
- `sgconfig.yml` becomes an infrastructure path.

## Capabilities
### Modified Capabilities
- `toolchain`: the setup command also provides structural search.

## Impact
No library source changes. No lint rules and no check stage: those wait for a convention worth checking.
