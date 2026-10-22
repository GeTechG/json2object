## 1. Library
- [x] 1.1 Schema builder: inline the schema of a typedef alias of a non-structure type, without a definition
- [x] 1.2 Schema builder: pass `@:optional` through a typedef alias and a lazy type
- [x] 1.3 Test: schemas of fields typed by aliases of `Null<Float>`, `Float`, `String`, with and without `@:default`

## 2. Verify
- [x] 2.1 The suite ends with `ALL TESTS OK` on the pinned compiler
- [x] 2.2 The suite ends with `ALL TESTS OK` on Haxe 4 (4.3.6 locally; CI runs 4.3.7)
