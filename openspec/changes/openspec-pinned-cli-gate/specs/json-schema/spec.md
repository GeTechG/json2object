## MODIFIED Requirements

### Requirement: The schema of a tagged enum is a oneOf of closed branches
`JsonSchemaWriter` SHALL generate, for an enum marked `@:tagged("<tag>")`, a definition named by its type path holding `"discriminator": {"propertyName": "<tag>"}` and a `oneOf` with one closed object schema (`"type": "object"`, `"additionalProperties": false`) per constructor, in declaration order, whose `properties` are those of the branch record plus `<tag>: {"const": "<constructor>"}` and whose `required` is the tag and the required fields of the record.

#### Scenario: A tagged enum with a constructor default
- **WHEN** the schema of `@:tagged("kind") enum Shape { @:default({radius: 16}) circle(s:{radius:Float}); }` is generated
- **THEN** the definition `Shape` has `"discriminator": {"propertyName": "kind"}` and `oneOf` holds `{"type": "object", "additionalProperties": false, "properties": {"kind": {"const": "circle"}, "radius": {"type": "number"}}, "required": ["kind", "radius"], "default": {"kind": "circle", "radius": 16}}`

## ADDED Requirements

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
