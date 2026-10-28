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

### Requirement: The schema of a tagged enum is a oneOf of closed branches
`JsonSchemaWriter` SHALL generate, for an enum marked `@:tagged("<tag>")`, a definition named by its type path holding a `oneOf` with one schema per constructor, in declaration order, and `"discriminator": {"propertyName": "<tag>"}`. Each branch SHALL be a closed object (`"type": "object"`, `"additionalProperties": false`) whose `properties` are those of the branch record plus `<tag>: {"const": "<constructor>"}`, and whose `required` is the tag and the required fields of the record. Field metadata of the record (`@:jignored`, `@:alias`, `@:optional`, field `@:default`, doc) SHALL apply as in any record schema, and the constructor's doc SHALL be the branch description. A `@:default(<record>)` on a constructor SHALL be the `default` of its branch, written as the JSON of that value with the tag; it SHALL NOT make the branch fields optional.

#### Scenario: A tagged enum with a constructor default
- **WHEN** the schema of `@:tagged("kind") enum Shape { @:default({radius: 16}) circle(s:{radius:Float}); }` is generated
- **THEN** the definition `Shape` has `"discriminator": {"propertyName": "kind"}` and `oneOf` holds `{"type": "object", "additionalProperties": false, "properties": {"kind": {"const": "circle"}, "radius": {"type": "number"}}, "required": ["kind", "radius"], "default": {"kind": "circle", "radius": 16}}`
