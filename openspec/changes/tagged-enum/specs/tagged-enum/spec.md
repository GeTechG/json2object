## ADDED Requirements

### Requirement: A tagged enum is a flat object with a tag field
An enum marked `@:tagged("<tag>")`, whose every constructor takes one anonymous-structure argument (its branch), SHALL be represented in JSON as one object: the field `<tag>` holding the constructor name as a string, and the fields of the branch record beside it. An enum without `@:tagged` SHALL keep its current representation.

#### Scenario: A value of a tagged enum
- **WHEN** `Shape.rect({width: 32, height: 32})` of `@:tagged("kind") enum Shape { rect(s:{width:Float, height:Float}); circle(s:{radius:Float}); }` is written
- **THEN** the JSON is `{"kind": "rect", "width": 32, "height": 32}`

### Requirement: Reading a tagged enum
A `JsonParser` of a tagged enum SHALL read a JSON object whose tag field, in any position, is a string naming a constructor, and read the other fields as the record of that constructor's branch, as any record is read: a missing required field is reported as uninitialized, an `@:optional` field may be absent, field metadata applies. The branch SHALL be closed: a field the branch does not declare SHALL be reported as an unknown variable. A missing tag or a tag that is not a string SHALL be reported as an incorrect type of the tag variable, and a string that names no constructor as an incorrect enum value; both errors SHALL name the tag and the constructor names (`Shape.kind (rect | circle)`), and the value is then `null`. A JSON value that is not an object (other than `null`) SHALL be reported as an incorrect type.

#### Scenario: Any field order
- **WHEN** `{"width": 32, "kind": "rect", "height": 16}` is parsed as `Shape`
- **THEN** no error is reported and the value is `rect({width: 32, height: 16})`

#### Scenario: An unknown constructor name
- **WHEN** `{"kind": "square"}` is parsed as `Shape`
- **THEN** an `IncorrectEnumValue("square", "Shape.kind (rect | circle)", _)` error is reported and the value is `null`

#### Scenario: A field of another branch
- **WHEN** `{"kind": "circle", "radius": 3, "width": 1}` is parsed as `Shape`
- **THEN** an `UnknownVariable("width", _)` error is reported

### Requirement: Writing a tagged enum
A `JsonWriter` of a tagged enum SHALL write the tag field first, then the fields of the branch in their declaration order, with the same rules for each field as a record (`@:jignored`, `@:alias`, `ignoreNullOptionals`).

#### Scenario: Roundtrip
- **WHEN** a tagged enum value is written and the output parsed back
- **THEN** no error is reported and the value equals the original

### Requirement: A malformed tagged enum fails the build
The build SHALL fail, with a message naming the enum and, where it applies, the constructor, when an enum marked `@:tagged` is used with a `JsonParser`, `JsonWriter` or `JsonSchemaWriter` and: the `@:tagged` argument is not one string constant holding an identifier; a constructor takes no argument or more than one; a constructor argument is not an anonymous structure; or a branch record declares a field whose name (or `@:alias`) is the tag.

#### Scenario: A constructor without an argument
- **WHEN** a `JsonParser` of `@:tagged("kind") enum E { a; }` is compiled
- **THEN** the build fails with a message naming `E` and `a`
