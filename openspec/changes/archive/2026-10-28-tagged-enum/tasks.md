## 1. Library
- [x] 1.1 Macro helper: read and check `@:tagged`, list the branches of a tagged enum, fail the build on a malformed one
- [x] 1.2 Reader: a tagged enum is read from a flat object with a tag field, the branch closed
- [x] 1.3 Writer: tag first, then the branch fields in declaration order
- [x] 1.4 Schema: `oneOf` of closed branches with the tag as `const`, `discriminator`, constructor `@:default` as the branch `default`

## 2. Tests
- [x] 2.1 Reader: every branch, any field order, missing / non-string / unknown tag, unknown field, missing required field, `@:optional` field, a value that is not an object
- [x] 2.2 Writer and roundtrip, field order
- [x] 2.3 Schema of a tagged enum
- [x] 2.4 Compile errors: constructor without argument, with several, a non-structure argument, a branch field named as the tag, a non-string `@:tagged` argument

## 3. Verify
- [x] 3.1 The suite ends with `ALL TESTS OK` on the pinned compiler
- [x] 3.2 The suite ends with `ALL TESTS OK` on Haxe 4 (4.3.6 locally; CI runs 4.3.7)

## 4. Review
- [x] 4.1 Cross-model review of the branch (codex): one finding, a reused parser kept its previous value on an invalid tag; fixed, re-review clean
