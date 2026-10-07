## Why
On the pinned Haxe 5 compiler `UInt` is a typedef to `haxe.UInt32`; the library recognises an unsigned integer only as the abstract `UInt` of module `UInt`. A `UInt` is therefore read as an `Int` (values above 2147483647 are rejected) and written as a signed number (`4294967295` becomes `-1`). `tests.UIntTest` fails on the pinned compiler.

## What Changes
- The reader and the writer treat `haxe.UInt32` as an unsigned integer, as they treat `UInt` on Haxe 4.
- `tests.UIntTest` also checks the written text, which a read-write-read round trip does not see.
- `AGENTS.md`: the known `UIntTest` failure is no longer an exception in *Checks*.

## Capabilities
### New Capabilities
- `uint`: how an unsigned 32-bit integer is read from and written to JSON.

## Impact
`src/json2object/reader/DataBuilder.hx`, `src/json2object/writer/DataBuilder.hx`, `tests/UIntTest.hx`. No change of behaviour on Haxe 4.
