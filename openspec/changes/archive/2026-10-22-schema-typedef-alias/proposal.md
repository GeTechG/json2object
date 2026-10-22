## Why
`JsonSchemaWriter` aborts the build with `Uncaught exception Null Access` (in `JsonTypeTools._toExpr`) on any field whose type is a typedef alias of a type that is not a structure: `typedef MaybeFloat = Null<Float>`, `typedef MyFloat = Float`, an alias of `String` or of `Array<Int>`. For such an alias the schema builder registers a definition under the alias name without a schema, and writing the definitions dereferences it. Found through a field `@:default(5.) var m:MaybeFloat`; the `@:default` plays no part.

## What Changes
- The schema of a typedef alias of a non-structure type is the schema of the aliased type, inlined (with the typedef's doc as its description); no definition is created for the alias. An alias of a structure keeps its definition, named by its type path.
- `@:optional` is kept through a typedef alias and a lazy type, so an `@:optional` field typed by an alias of `Null<T>` gets the same schema as an `@:optional` field of type `Null<T>`.
- A test in `tests.StructureTest` for fields typed by such aliases.

## Capabilities
### New Capabilities
- `json-schema`: the JSON schema `JsonSchemaWriter` generates for a Haxe type.

## Impact
`src/json2object/utils/schema/DataBuilder.hx`, `tests/`. Behaviour changes only for types that failed to compile.
