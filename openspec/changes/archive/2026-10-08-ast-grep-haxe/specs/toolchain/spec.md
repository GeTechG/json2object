## MODIFIED Requirements

### Requirement: One command prepares a checkout
`bash tools/setup.sh` SHALL, in a fresh checkout or worktree, install the pinned compiler and point the gitignored `.haxe` symlink at it, fetch the test libraries, write the test config `.haxe-tests.hxml`, configure Serena, and provide `ast-grep` with the Haxe grammar under the gitignored `.ast-grep/`. Downloads and builds SHALL live in a per-user cache shared by all checkouts, one directory per pin, and the command SHALL write only gitignored files in the checkout.

#### Scenario: Fresh worktree
- **WHEN** `bash tools/setup.sh` has run in a fresh worktree
- **THEN** `.haxe/haxe --version` reports the pinned build and `git status` shows no change

#### Scenario: Second checkout
- **WHEN** the command runs in another checkout with the same pins
- **THEN** it downloads and builds nothing

## ADDED Requirements

### Requirement: Code is searchable by shape
The setup command SHALL install `ast-grep` at the version pinned in `tools/setup.sh` as `.ast-grep/ast-grep`, and build the `GeTechG/tree-sitter-haxe` grammar at the commit pinned there as `.ast-grep/haxe.so`. The tracked `sgconfig.yml` at the root SHALL register that library as the language `haxe` for `*.hx` files. `AGENTS.md` SHALL say when to use `ast-grep`, when Serena and when a text search.

#### Scenario: Searching by pattern
- **WHEN** `.ast-grep/ast-grep run -p 'throw new $T($$$A)' -l haxe src` runs after setup
- **THEN** it reports every `throw new …(…)` expression of `src/`

#### Scenario: Files the grammar cannot parse
- **WHEN** `.ast-grep/ast-grep run --kind ERROR -l haxe .` reports a file
- **THEN** a structural search may miss code in that file, and the result is confirmed with a text search
