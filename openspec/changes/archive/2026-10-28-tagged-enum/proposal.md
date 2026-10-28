## Why
An enum is read, written and described by its schema only in the form "key = constructor name": `{"rect": {"shape": {"width": 32, "height": 32}}}`. A common JSON form of a discriminated union is a flat object with a tag field: `{"kind": "rect", "width": 32, "height": 32}`. It cannot be expressed with an enum today; the workaround is one flat record with every field of every kind nullable, and its schema does not tell which fields belong to which kind.

## What Changes
- New metadata on an enum: `@:tagged("<tag>")`. Every constructor of such an enum takes exactly one argument, an anonymous structure (a typedef of a record): its branch. The JSON of `Shape.rect({width: 32, height: 32})` is `{"kind": "rect", "width": 32, "height": 32}`.
- `JsonParser`: reads the tag, then the other fields as the branch record, closed (an unknown field is an error).
- `JsonWriter`: writes the tag first, then the fields of the branch in declaration order.
- `JsonSchemaWriter`: a `oneOf` of closed branches, each with `properties.<tag> = {"const": "<ctor>"}`, and `"discriminator": {"propertyName": "<tag>"}` on the node. `@:default(...)` on a constructor is the `default` of its branch.
- Compile errors for a malformed tagged enum.
- An enum without `@:tagged` is unchanged.

## Capabilities
### New Capabilities
- `tagged-enum`: how an enum marked `@:tagged` is read, written and checked at compile time.
### Modified Capabilities
- `json-schema`: the schema of a tagged enum.

## Impact
`src/json2object/reader/DataBuilder.hx`, `src/json2object/writer/DataBuilder.hx`, `src/json2object/utils/schema/`, a new macro helper `src/json2object/utils/TaggedEnum.hx`, `tests/`. No change for existing types: the new code runs only for an enum with `@:tagged`.
