## 1. Library
- [ ] 1.1 Macro helper: read and check `@:tagged`, list the branches of a tagged enum, fail the build on a malformed one
- [ ] 1.2 Reader: a tagged enum is read from a flat object with a tag field, the branch closed
- [ ] 1.3 Writer: tag first, then the branch fields in declaration order
- [ ] 1.4 Schema: `oneOf` of closed branches with the tag as `const`, `discriminator`, constructor `@:default` as the branch `default`

## 2. Tests
- [ ] 2.1 Reader: every branch, any field order, missing / non-string / unknown tag, unknown field, missing required field, `@:optional` field, a value that is not an object
- [ ] 2.2 Writer and roundtrip, field order
- [ ] 2.3 Schema of a tagged enum
- [ ] 2.4 Compile errors: constructor without argument, with several, a non-structure argument, a branch field named as the tag, a non-string `@:tagged` argument

## 3. Verify
- [ ] 3.1 The suite ends with `ALL TESTS OK` on the pinned compiler
- [ ] 3.2 The suite ends with `ALL TESTS OK` on Haxe 4
