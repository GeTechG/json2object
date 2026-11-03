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
`JsonSchemaWriter` SHALL generate, for an enum marked `@:tagged("<tag>")`, a definition named by its type path holding `"discriminator": {"propertyName": "<tag>"}` and a `oneOf` with one closed object schema (`"type": "object"`, `"additionalProperties": false`) per constructor, in declaration order, whose `properties` are those of the branch record plus `<tag>: {"const": "<constructor>"}` and whose `required` is the tag and the required fields of the record.

#### Scenario: A tagged enum with a constructor default
- **WHEN** the schema of `@:tagged("kind") enum Shape { @:default({radius: 16}) circle(s:{radius:Float}); }` is generated
- **THEN** the definition `Shape` has `"discriminator": {"propertyName": "kind"}` and `oneOf` holds `{"type": "object", "additionalProperties": false, "properties": {"kind": {"const": "circle"}, "radius": {"type": "number"}}, "required": ["kind", "radius"], "default": {"kind": "circle", "radius": 16}}`

### Requirement: In display mode a schema writer is a stub with the same public API
`JsonSchemaWriter` and `VSCodeSchemaWriter` SHALL, when the `display` define is set, type as the class `json2object.utils.schema.SchemaWriterDisplayStub` instead of a class generated for the type, with the public API of a generated writer: the constructor with an optional `space`, the variable `space` and the read-only property `schema`. No schema SHALL be built, and `schema` SHALL be `null`. Without the `display` define, a writer SHALL generate its schema as usual.

#### Scenario: Typing a writer in display mode
- **WHEN** `new JsonSchemaWriter<Array<Int>>().schema` is typed with `-D display`
- **THEN** it compiles, as a `String`, and no schema type is built

#### Scenario: Completion on a writer
- **WHEN** completion is requested on a `new JsonSchemaWriter<T>()` value
- **THEN** it offers `schema` and `space`

### Requirement: A tagged enum branch carries the record's metadata and the constructor's doc
In the schema of a tagged enum, the field metadata of a branch record (`@:jignored`, `@:alias`, `@:optional`, field `@:default`, doc) SHALL apply as in any record schema, and the doc of the constructor SHALL be the `description` of its branch.

#### Scenario: Documented constructor with an optional field
- **WHEN** the schema of `@:tagged("kind") enum Shape { /** A circle */ circle(s:{radius:Float, @:optional var label:String}); }` is generated
- **THEN** the `circle` branch has `"description": "A circle"`, its `properties` hold `label`, and its `required` is `["kind", "radius"]`

### Requirement: A constructor default is the default of its branch
A `@:default(<record>)` on a constructor of a tagged enum SHALL be the `default` of its branch in the schema, written as the JSON of that value with the tag; it SHALL NOT make the branch fields optional.

#### Scenario: A default covering every field
- **WHEN** the schema of `@:tagged("kind") enum Shape { @:default({width: 32, height: 32}) rect(s:{width:Float, height:Float}); }` is generated
- **THEN** the `rect` branch has `"default": {"kind": "rect", "width": 32, "height": 32}` and its `required` still holds `width` and `height`
