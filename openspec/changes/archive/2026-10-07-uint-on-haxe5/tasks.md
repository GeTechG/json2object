## 1. Library
- [x] 1.1 Reader: select the unsigned parser and the `0` default for `haxe.UInt32`
- [x] 1.2 Writer: write `haxe.UInt32` as an unsigned number
- [x] 1.3 `tests.UIntTest`: assert the written text of a value above 2147483647

## 2. Rules
- [x] 2.1 `AGENTS.md`: drop the known `UIntTest` failure from *Checks*

## 3. Verify
- [x] 3.1 The suite ends with `ALL TESTS OK` on the pinned compiler
- [x] 3.2 The suite ends with `ALL TESTS OK` on Haxe 4 (`tests/build/build_interp.hxml`, 4.3.6 locally; CI runs 4.3.7 on `master`)
