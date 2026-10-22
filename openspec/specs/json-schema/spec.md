# json-schema Specification

## Purpose
The JSON schema `JsonSchemaWriter` generates for a Haxe type.

## Requirements

### Requirement: A typedef alias of a non-structure type has the schema of the aliased type
`JsonSchemaWriter` SHALL generate, for a field whose type is a typedef alias of a type that is not a structure or class (such as `Null<Float>`, `Float`, `String`, `Array<Int>`), the same schema as for a field of the aliased type, with the typedef's doc, if any, as the description. No definition SHALL be added for the alias. An `@:optional` field and an `@:default` value SHALL be handled as for the aliased type.

#### Scenario: An alias of a nullable float with a default
- **WHEN** the schema of `{@:default(5.) var m:MaybeFloat;}` is generated, with `typedef MaybeFloat = Null<Float>`
- **THEN** it compiles, and equals the schema of `{@:default(5.) var m:Null<Float>;}`

#### Scenario: An alias of a primitive
- **WHEN** the schema of `{var m:MyFloat;}` is generated, with `typedef MyFloat = Float`
- **THEN** it equals the schema of `{var m:Float;}`

### Requirement: A typedef alias of a structure is a definition
`JsonSchemaWriter` SHALL generate, for a typedef alias of a structure, a definition named by its type path (`tests.SimpleDefault`), referenced where the alias is used.

#### Scenario: A field of a structure typedef
- **WHEN** the schema of `tests.SimpleDefault`, a typedef of an anonymous structure, is generated
- **THEN** the schema has a definition `tests.SimpleDefault`, and the root refers to it
