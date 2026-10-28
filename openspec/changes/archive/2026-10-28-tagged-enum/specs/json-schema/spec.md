## ADDED Requirements

### Requirement: The schema of a tagged enum is a oneOf of closed branches
`JsonSchemaWriter` SHALL generate, for an enum marked `@:tagged("<tag>")`, a definition named by its type path holding a `oneOf` with one schema per constructor, in declaration order, and `"discriminator": {"propertyName": "<tag>"}`. Each branch SHALL be a closed object (`"type": "object"`, `"additionalProperties": false`) whose `properties` are those of the branch record plus `<tag>: {"const": "<constructor>"}`, and whose `required` is the tag and the required fields of the record. Field metadata of the record (`@:jignored`, `@:alias`, `@:optional`, field `@:default`, doc) SHALL apply as in any record schema, and the constructor's doc SHALL be the branch description. A `@:default(<record>)` on a constructor SHALL be the `default` of its branch, written as the JSON of that value with the tag; it SHALL NOT make the branch fields optional.

#### Scenario: A tagged enum with a constructor default
- **WHEN** the schema of `@:tagged("kind") enum Shape { @:default({radius: 16}) circle(s:{radius:Float}); }` is generated
- **THEN** the definition `Shape` has `"discriminator": {"propertyName": "kind"}` and `oneOf` holds `{"type": "object", "additionalProperties": false, "properties": {"kind": {"const": "circle"}, "radius": {"type": "number"}}, "required": ["kind", "radius"], "default": {"kind": "circle", "radius": 16}}`
